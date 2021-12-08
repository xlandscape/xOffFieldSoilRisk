# Libraries
library(data.table)
library(openxlsx)
library(optparse)
library(pbapply)

initialize_parameters <- function(inputs, args = NULL) {
  if (is.null(args)) {
    arguments <- commandArgs(TRUE)
  }
  else {
    positional_match <- match(names(args), inputs$positional)
    arguments <- c(
      sapply(names(args)[is.na(positional_match)], function(x) paste0("--", x, "=", args[[x]]), USE.NAMES = FALSE),
      sapply(inputs$positional, function(x) args[[x]], USE.NAMES = FALSE)
    )
  }
  parsed_args <- parse_args(
    OptionParser(
      usage = paste("%prog [options]", paste(inputs$positional, collapse = " ")),
      option_list = inputs$optional
    ),
    arguments,
    positional_arguments = length(inputs$positional)
  )
  optional_arguments <- lapply(names(parsed_args$options), function(x) parsed_args$options[[x]])
  names(optional_arguments) <- names(parsed_args$options)
  positional_arguments <- as.list(parsed_args$args)
  names(positional_arguments) <- inputs$positional
  .libPaths(optional_arguments$rlibpath)
  pboptions(type = "timer")
  c(optional_arguments, positional_arguments)
}

intervals <- function(lower, upper, add.na = NULL) {
  d <- data.table(lower, upper)
  r <- d[, paste0("%between% c(", lower + 1e-4, ", ", upper, ")")]
  if (!is.null(add.na)) {
    r2 <- c(NA, r)
    names(r2) <- c(add.na, d[, paste0(lower, "-", upper)])
    r <- r2
  } else {
    names(r) <- d[, paste0(lower, "-", upper)]
  }
  attr(r, "data.class") <- class(numeric())
  class(r) <- c("x3scale", class(r))
  r
}

write_to_xlsx <- function(data, file, author = "X3 Risk Analysis") {
  wb <- createWorkbook(author)
  for (i in 1:length(data)) {
    if (is.character(data[[i]])) {
      addWorksheet(wb, names(data)[[i]])
      row <- 1
      for (paragraph in data[[i]]) {
        for (line in strwrap(paragraph, 80)) {
          writeData(wb, names(data)[[i]], line, 1, row)
          row <- row + 1
        }
      }
    } else if (is.data.frame(data[[i]])) {
      addWorksheet(wb, names(data)[[i]])
      writeDataTable(wb, names(data)[[i]], data[[i]])
    } else {
      sapply(1:length(data[[i]]), function(j) {
        addWorksheet(wb, names(data[[i]])[j])
        writeDataTable(wb, names(data[[i]])[j], data[[i]][[j]])
        TRUE
      })
    }
  }


  saveWorkbook(wb, file)
}

contourplots <- function(
  data, analysisScales, output, prefix = "QX(QT)--", suffix = "", threshold = 0, type = "contour") {
  cat("Contourplots\n")
  suppressMessages(pbsapply(1:nrow(analysisScales), function(i) {
    dat <- data[lulc == analysisScales[i, lulc] & distance == analysisScales[i, distance] & value >= threshold]
    p <- ggplot(dat, aes(s.percentile, t_percentile))
    if (type == "raster")
      p <- p + geom_raster(aes(fill = log10(value)))
    else if (type == "contour")
      p <- p + geom_contour(aes(z = log10(value), colour = ..level..))
    p <- p +
      xlab("Spatial percentile") +
      ylab("Temporal percentile") +
      ggtitle(
        paste(
          "Spatial and temporal percentiles of",
          analysisScales[i, lulc],
          "(log10) --",
          analysisScales[i, distance],
          "m"
        )
      ) +
      scale_x_continuous(breaks = 1:10 * 10) +
      scale_y_continuous(breaks = 1:10 * 10) +
      scale_color_gradient(low = "darkgreen", high = "red")
    if (type == "contour")
      direct.label(p, "bottom.pieces")
    ggsave(
      file.path(output, paste0(prefix, analysisScales[i, distance], "--", analysisScales[i, lulc], suffix, ".png")))
    TRUE
  }))
}

animate <- function(rasters, output, ffmpeg) {
  cat("Animate...\n")
  system2(ffmpeg, c("-i", shQuote(rasters, "cmd"), "-vcodec", "msmpeg4v2", shQuote(output, "cmd")))
}

load_raw_percentiles <- function(input) {
  cat("Loading raw percentiles\n")
  data_files <- list.files(input, "^.*\\.rds$", full.names = TRUE, recursive = TRUE)
  rbindlist(pblapply(data_files, readRDS))
}

analyze_percentiles <- function(perc) {
  cat("Analyzing...\n")
  perc[
    ,
    list(
      mean = mean(value),
      stddev = sd(value),
      upper_conf = mean(value) + qnorm(.975) * sd(value) / sqrt(.N),
      lower_conf = mean(value) - qnorm(.975) * sd(value) / sqrt(.N)
    ),
    list(distance, t_percentile, s.percentile)
  ]
}

filter_percentiles <- function(t.perc = c(.5, .75, .9, 1), s.perc = c(0, .01, .05, .1, .25, .5, .75, .9, .95, .99, 1)) {
  cat("Filtering percentiles\n")
  poi_t <- paste0(t.perc * 100, "%")
  poi_s <- paste0(s.perc * 100, "%")
  data <- pblapply(poi_t, function(poit) {
    x_mean <- dcast(
      percentiles[t_percentile == poit & `%in%`(s.percentile, poi_s)], distance ~ s.percentile, sum, value.var = "mean")
    x_lower <- dcast(
      percentiles[t_percentile == poit & `%in%`(s.percentile, poi_s)],
      distance ~ s.percentile,
      sum,
      value.var = "lower_conf"
    )
    x_upper <- dcast(
      percentiles[t_percentile == poit & `%in%`(s.percentile, poi_s)],
      distance ~ s.percentile,
      sum,
      value.var = "upper_conf"
    )
    x_mean[, characteristic := "mean"]
    x_lower[, characteristic := "lowerConf95"]
    x_upper[, characteristic := "upperConf95"]
    x <- rbindlist(list(x_mean, x_lower, x_upper))
    setkey(x, distance)
    setcolorder(x, c("distance", poi_s, "characteristic"))
    x
  })
  names(data) <- paste0("qx(qt", poi_t, ")")
  data
}

boxplots <- function(output, t.perc = c(.5, .75, .9, 1), s.perc = c(0, .01, .05, .1, .25, .5, .75, .9, .95, .99, 1)) {
  cat("Boxplots\n")
  poi_t <- paste0(t.perc * 100, "%")
  poi_s <- paste0(s.perc * 100, "%")
  pbsapply(poi_t, function(poit) {
    for (dist in unique(perc[, distance])) {
      data <- perc[distance == dist & t_percentile == poit & `%in%`(s.percentile, poi_s)]
      png(
        file.path(
          output, paste0("QX(QT", sub("%", "", poit, fixed = TRUE), ")_", dist, ".png")), width = 1024, height = 1024)
      boxplot(
        data[, value] ~ data[, as.numeric(sub("%", "", s.percentile, fixed = TRUE))],
        at = unique(data[, as.numeric(sub("%", "", s.percentile, fixed = TRUE))]),
        xlab = "Spatial percentile",
        ylab = params$options$dsname,
        main = paste0("QX(QT", poit, ") | ", dist)
      )
      dev.off()
    }
    TRUE
  })
}


# Define script inputs
inputs <- list(
  positional = c("input", "output"),
  optional = list(
    make_option("--dsname", default = "PecSoil", help = "The name of the dataset [default %default]"),
    make_option(
      "--rlibpath", default = .libPaths()[1], help = "The path containing the required R packages [default %default]")
))

# Initialize parameter list
params <- initialize_parameters(inputs)

# Load raw percentiles
perc <- load_raw_percentiles(params$input)

# Analyze percentiles
percentiles <- analyze_percentiles(perc)
write_to_xlsx(list(
  info = c(
    "Workbook description",
    "",
    paste(
      "This workbook contains aggregated raw data for the entire experiment. The data was processed in the following ",
      "way:"),
    paste(
      "1. Within every MonteCarlo run of the experiment, the",
      params$dsname,
      "of every 1 square meter cell of habitat was calculated for each day of the simulation."
    ),
    paste(
      "2. The",
      params$dsname,
      "of every 1 square meter was aggregated into percentiles over tim, using 1%-steps, for every MonteCarlo run."
    ),
    paste(
      "3. The temporally aggregated values were, for each MonteCarlo run, aggregated into percentiles over space",
          "using 1%-steps for different distance classes."
    ),
    paste(
      "4. The mean value, standard deviation and the 95% confidence interval for each combination of temporally and",
      "spatially aggregated",
      params$dsname,
      "values was calculated over the MonteCarlo runs for each distance class."
    ),
    "",
    paste(
      "The resulting values are given here, so that the columns distance, t_percentile and s.percentile idenmtify a",
      "distinct combination of distance class and spatial and temporal percentiles. The columns mean, stddev,",
      "upper_conf and lower_conf then give the accoridng statistics for this combination."
    )
  ),
  data = percentiles
), file.path(params$output, paste(params$dsname, "percentiles_raw.xlsx")))

# Filter and write percentiles
data <- filter_percentiles()
write_to_xlsx(list(
  info = c(
    "Workbook description",
    "",
    "This workbook contains aggregated data for the entire experiment. The data was processed in the following way:",
    paste(
      "1. Within every MonteCarlo run of the experiment, the",
      params$options$dsname,
      "of every 1 square meter cell of habitat was calculated for each day of the simulation."
    ),
    paste(
      "2. The",
      params$options$dsname,
      "of every 1 square meter was aggregated into the median, 75th percentile, 90th percentile and the maximum over",
      "time for every MonteCarlo run."
    ),
    paste(
      "3. The temporally aggregated values were, for each MonteCarlo run, further aggregated into different",
      "percentiles over space for different distance classes."
    ),
    paste(
      "4. The mean value and the 95% confidence interval for each combination of temporally and spatially aggregated",
      params$options$dsname,
      "values was calculated over the MonteCarlo runs for each distance class."
    ),
    "",
    paste(
      "The resulting values are given here, so that every temporal percentile has an own worksheet where the spatial",
      "percentiles for the according percentile appear as columns in the worksheet. The cells in the worksheet then",
      "contain the qxPX(qtPT) value where PT is given in the name of the worksheet and PX in the column header. The",
      "characteristic column indicates wheter the value given in the cell is the mean value over the MonteCarlo runs",
      "or the upper or lower boundary of the 95% confidence interval. The distance column refers to the distance class",
      "to which the values apply."
    )
  ),
  data = data
), file.path(params$output, paste(params$dsname, "percentiles.xlsx")))

# Boxplots
result <- boxplots(params$output)
