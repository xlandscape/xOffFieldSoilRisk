library(optparse)
library(data.table)
library(directlabels)
library(ggplot2)
library(hdf5r)
library(matrixStats)
library(openxlsx)
library(pbapply)
library(terra, warn.conflicts = FALSE)

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

define_scales <- function(...) {
  x <- list(...)
  s <- as.data.table(expand.grid(x, stringsAsFactors = FALSE))
  r <- data.table::copy(s)
  for (col in names(r)) {
    r[, (col) := as.character(get(col))]
    if (attr(x[[col]], "data.class") == class(character()))
      r[, (col) := paste0('"', get(col), '"')]
    r[!is.na(get(col)), (col) := paste0(
      col,
      ifelse(any(startsWith(get(col), c("=", ">", "<", "%"))), " ", " == "),
      get(col))]
  }
  r <- r[, do.call(paste, c(.SD, sep = " & "))]
  s[, def := gsub(" & NA", "", r, fixed = TRUE)]
  for (col in names(s))
    s[, (col) := as.character(get(col))]
  for (i in seq_along(x)) {
    col <- names(x)[i]
    s[, (col) := names(x[[i]])[match(get(col), x[[i]])]]
  }
  s[, def := gsub("NA", "TRUE", def, TRUE)]
  class(s) <- c("x3scales", class(s))
  s
}

all_levels <- function(x, col, add.na = NULL) {
  v <- unique(x[, eval(substitute(col, environment()), x)])
  if (!is.null(add.na)) {
    v2 <- c(NA, v)
    names(v2) <- c(add.na, v)
    v <- v2
  } else {
    names(v) <- v
  }
  attr(v, "data.class") <- class(x[, eval(substitute(col, environment()), x)])
  class(v) <- c("x3scale", class(v))
  v
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

temporal_aggregation <- function(x3df, dataset, output, t.quantiles = seq(0, 1, .01), elements = 1e8) {
  cat("Preparing analysis...\n")
  hdf5 <- h5file(paste0(x3df, "/arr.dat"), "r")
  dataset <- hdf5[[dataset]]
  x_chunk_size <- ceiling(sqrt(elements / dataset$dims[3] / dataset$chunk_dims[1]))
  chunks <- data.table(
    expand.grid(seq(1, dataset$dims[2], x_chunk_size), seq(1, dataset$dims[3], dataset$chunk_dims[3])))
  chunks[
    ,
    c("Var3", "Var4") := list(
      ifelse(Var1 + x_chunk_size > dataset$dims[2], dataset$dims[2] - Var1 + 1, x_chunk_size),
      ifelse(Var2 + dataset$chunk_dims[3] > dataset$dims[3], dataset$dims[3] - Var2 + 1, dataset$chunk_dims[3])
    )
  ]
  chunks <- chunks[Var3 > 0 & Var4 > 0 & !(Var3 == 1 & Var4 == 1)]
  percentile_hdf <- h5file(output, "w")
  percentile_hdf$create_dataset(
    "t", dtype = h5types$float,
    dims = c(length(t.quantiles), dataset$dims[2], dataset$dims[3]),
    chunk_dims = c(1, dataset$chunk_dims[2], dataset$chunk_dims[3])
  )

  cat("Temporal aggregation\n")
  pblapply(
    1:nrow(chunks),
    function(i) {
      q <- apply(
        dataset$read(
          args = list(
            1:dataset$dims[1],
            chunks[i, Var1]:(chunks[i, Var1] + chunks[i, Var3] - 1),
            chunks[i, Var2]:(chunks[i, Var2] + chunks[i, Var4] - 1)
          ),
          drop = FALSE
        ),
        2:3,
        function(x) quantile(x, t.quantiles)
      )
      percentile_hdf[["t"]]$write(
        list(
          1:length(t.quantiles),
          chunks[i, Var1]:(chunks[i, Var1] + chunks[i, Var3] - 1),
          chunks[i, Var2]:(chunks[i, Var2] + chunks[i, Var4] - 1)
        ),
        q
      )
    }
  )
  h5close(hdf5)
  h5attr(percentile_hdf[["t"]], "percentiles") <- paste0(t.quantiles * 100, "%")
  percentile_hdf$flush()
  percentile_hdf$close()
  invisible(0)
}

risk_analysis_maps <- function(
  data, output, spatial_info, value_name = "Value", t.quantiles = c("50%", "75%", "90%", "95%", "100%")) {
  cat(paste0("Risk analysis maps max", value_name, "|t (x, MCrun)\n"))
  hdf <- h5file(data)
  perc <- h5attr(hdf[["t"]], "percentiles")
  r <- rast(
    xmin = spatial_info$extent[1],
    xmax = spatial_info$extent[1] + hdf[["t"]]$dims[2] * spatial_info$resolution,
    ymin = spatial_info$extent[3],
    ymax = spatial_info$extent[3] + hdf[["t"]]$dims[3] * spatial_info$resolution,
    crs = paste("EPSG", spatial_info$epsg, sep = ":"),
    resolution = spatial_info$resolution
  )
  pbsapply(t.quantiles, function(qt) {
    i <- which(perc == qt)
    values(r) <- hdf[["t"]][i,,]
    writeRaster(r, file.path(output, paste0(value_name, " QT", qt, ".tif")))
    TRUE
  })
  hdf$close()
}

get_spatial_info <- function(x3df, extent, epsg, resolution = 1) {
  hdf5 <- h5file(paste0(x3df, "/arr.dat"), "r")
  ext <- hdf5[[extent]][]
  epsg <- hdf5[[epsg]][]
  res <- resolution
  h5close(hdf5)
  list(extent = ext, epsg = epsg, resolution = res)
}

prepare_spatial_analysis_scales <- function(x3df, scales = list()) {
  cat("Preparing spatial analysis scales...\n")
  hdf5 <- h5file(paste0(x3df, "/arr.dat"), "r")
  data_qt <- lapply(scales, function(scale) t(hdf5[[scale]][,]))
  h5close(hdf5)
  data_qt
}

get_values <- function(x3df, dataset) {
  hdf5 <- h5file(paste0(x3df, "/arr.dat"), "r")
  result <- as.integer(strsplit(hdf5[[dataset]][], ", ", TRUE)[[1]])
  h5close(hdf5)
  result
}

risk_analysis_percentiles <- function(data, analysis_scales, s.quantiles = seq(0, 1, .01)) {
  rbindlist(lapply(setdiff(names(data), names(analysis_scales)), function(perc) {
    cols <- c(perc, setdiff(names(analysis_scales), "def"))
    cols
    d <- data[, ..cols]
    rbindlist(lapply(1:nrow(analysis_scales), function(i) {
      res <- d[
        eval(parse(text = analysis_scales[i, def])),
        list(s.percentile = paste0(s.quantiles * 100, "%"), value = quantile(get(perc), s.quantiles))
      ]
      res[, t_percentile := perc]
      res[, c(names(analysis_scales)) := as.list(analysis_scales[i])][, def := NULL]
    }))
  }))
}

risk_analysis_table <- function(
  data,
  value_name = "Value",
  s.quantiles = c(0, .01, .05, .1, .25, .5, .75, .9, .95, .99, 1),
  t.quantiles = c(.5, .75, .9, .95, 1)
) {
  cat(paste0("Risk analysis table < Xth%ile (max", value_name, "|t)|x >...\n"))
  sq <- paste0(s.quantiles * 100, "%")
  tq <- paste0(t.quantiles * 100, "%")
  overview <- dcast(
    data[`%in%`(s.percentile, sq) & `%in%`(t_percentile, tq)],
    lulc + distance + t_percentile ~ s.percentile,
    value.var = "value"
  )
  setcolorder(overview, c("lulc", "distance", "t_percentile", sq))
  overview
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
  data, analysis_scales, output, prefix = "QX(QT)--", suffix = "", threshold = 0, type = "contour") {
  cat("Contourplots\n")
  suppressMessages(pbsapply(1:nrow(analysis_scales), function(i) {
    dat <- data[lulc == analysis_scales[i, lulc] & distance == analysis_scales[i, distance] & value >= threshold]
    p <- ggplot(dat[value > 0], aes(s.percentile, t_percentile))
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
          analysis_scales[i, lulc],
          "(log10) --",
          analysis_scales[i, distance],
          "m"
        )
      ) +
      scale_x_continuous(breaks = 1:10 * 10) +
      scale_y_continuous(breaks = 1:10 * 10) +
      scale_color_gradient(low = "darkgreen", high = "red")
    if (type == "contour")
      direct.label(p, "bottom.pieces")
    ggsave(
      file.path(output, paste0(prefix, analysis_scales[i, distance], "--", analysis_scales[i, lulc], suffix, ".png")))
    TRUE
  }))
}

plot_per_timestep <- function(x3df, dataset, output, spatial_info, max.value) {
  cat("Plot per timestep\n")
  dir.create(output)
  r <- raster(
    xmn = spatial_info$extent[1],
    xmx = spatial_info$extent[2],
    ymn = spatial_info$extent[3],
    ymx = spatial_info$extent[4],
    crs = spatial_info$crs,
    resolution = spatial_info$resolution
  )
  hdf5 <- h5file(paste0(x3df, "/arr.dat"), "r")
  dataset <- hdf5[dataset]
  pbsapply(1:dataset$dims[3], function(t) {
    r[] <- as.vector(sqrt(dataset[t,,]))
    r[r <= 1e-5] <- NA
    png(filename = file.path(output, sprintf("%06d.png", t)), width = 1080, height = 1080)
    plot(
      flip(r, "y"),
      zlim = c(0, max.value),
      col = rev(rainbow(255, start = 0, end = 1 / 3, alpha = NULL)),
      main = paste0("t = ", t),
      colNA = "lightgrey"
    )
    dev.off()
    TRUE
  })
  h5close(hdf5)
}

animate <- function(rasters, output, ffmpeg) {
  cat("Animate...\n")
  system2(ffmpeg, c("-i", shQuote(rasters, "cmd"), "-vcodec", "msmpeg4v2", shQuote(output, "cmd")))
}

coocurrence_spray_drift_run_off <- function(x3df, spraydrift, runoff) {
  cat("Cooccurence of spray-drift and run-off events\n")
  hdf5 <- h5file(paste0(x3df, "/arr.dat"), "r")
  if (existsGroup(hdf5, spraydrift) & existsGroup(hdf5, runoff)) {
    dataset <- hdf5[[spraydrift]]
    events <- rbindlist(pblapply(1:dataset$dims[1], function(t) {
      data.table(t, spraydrift = any(hdf5[[spraydrift]][t,,] > 0), runoff = any(hdf5[[runoff]][t,,] > 0))
    }))
    days_run_off_after_spray_drift <- outer(events[runoff == TRUE, t], events[spraydrift == TRUE, t], "-")
    days_run_off_after_spray_drift[days_run_off_after_spray_drift < 0] <- Inf
    quantiles <- quantile(colMins(days_run_off_after_spray_drift), seq(0, 1, .05))
    result <- data.table(q = names(quantiles), days = quantiles)
    h5close(hdf5)
    result
  } else {
    cat("...skipped as not both spray-drift and runoff exposure were simulated\n")
    NULL
  }
}

# Define script inputs
inputs <- list(
  positional = c("x3df", "output"),
  optional = list(
    make_option(
      "--dataset",
      default = "DepositionToPecSoil/PecSoil",
      help = "The dataset containing the input data [default %default]"
    ),
    make_option(
      "--distance",
      default = "LULC/AnalysisDistanceGroups",
      help = "The dataset with distance groups [default %default]"
    ),
    make_option(
      "--extent", default = "LULC/Extent", help = "The dataset containing the spatial extent [default %default]"),
    make_option("--ffmpeg", help = "The path to the ffmpeg video encoder"),
    make_option(
      "--habitats", default = "LULC/HabitatLulcTypes", help = "The dataset with the habitat types [default %default]"),
    make_option(
      "--lulc", default = "LULC/LulcRaster", help = "The dataset containing LULC types per cell [default %default]"),
    make_option(
      "--rlibpath",
      default = "./R-3.5.1/library",
      help = "The path containing the required R packages [default %default]"
    ),
    make_option("--runoff", help = "The dataset containing run-off exposure"),
    make_option("--spraydrift", help = "The dataset containing spray-drift exposure"),
    make_option("--epsg", help = "The dataset containing the EPSG code of the CRS"),
    make_option(
      "--elements",
      default = 1e8,
      type = "integer",
      help = "The target number of elements processed simultaneously [default %default]"
    )
  )
)

# Initialize parameter list
params <- initialize_parameters(inputs)
value_name <- tail(strsplit(params$dataset, "/", TRUE)[[1]], 1)

# Temporal aggregation
percentile_hdf <- file.path(params$output, "percentiles.h5")
temporal_aggregation(params$x3df, params$dataset, percentile_hdf, elements = params$elements)

# Risk analysis maps
spatial_info <- get_spatial_info(params$x3df, params$extent, params$epsg)
result <- risk_analysis_maps(percentile_hdf, params$output, spatial_info, value_name)

# Prepare spatial analysis scales
habitats <- get_values(params$x3df, params$habitats)
data_qt <- prepare_spatial_analysis_scales(params$x3df, list(lulc = params$lulc, distance = params$distance))
analysis_scales <- define_scales(
  lulc = all_levels(data.table(lulc = c(data_qt[["lulc"]])), lulc, "all"),
  distance = intervals(c(0, 0, 0, 0, 0, 2), c(5, 10, 20, 50, 100, 5), "any")
)

# Risk analysis percentiles
cat(paste0("Risk analysis Xth%ile (max", value_name, "|t)|x (MCrun)\n"))
hdf <- h5file(percentile_hdf)
data_qtqx <- rbindlist(pblapply(1:hdf[["t"]]$dims[1], function(i) {
  d <- data.table(
    value = c(hdf[["t"]][i,,]),
    lulc = c(t(data_qt[["lulc"]])),
    distance = c(t(data_qt[["distance"]]))
  )[`%in%`(lulc, habitats)]
  setnames(d, "value", h5attr(hdf[["t"]], "percentiles")[i])
  d <- risk_analysis_percentiles(d, analysis_scales)
}))
hdf$close()
saveRDS(data_qtqx, file.path(params$output, paste0(value_name, ".qtqx.raw.rds")))

# Risk analysis table
overview <- risk_analysis_table(data_qtqx, value_name)
write_to_xlsx(list(
  info = c(
    "Workbook description",
    "",
    "This workbook contains aggregated data for this MonteCarlo run. The data was processed in the following way:",
    paste(
      "1. Within the MonteCarlo run, the",
      value_name,
      "of every 1 square meter cell of habitat was calculated for each day of the simulation."
    ),
    paste(
      "2. The",
      value_name,
      "of every 1 square meter was aggregated into the median, 75th percentile, 90th percentile and the maximum over",
      "time."
    ),
    paste(
      "3. The temporally aggregated values were further aggregated into different percentiles over space for",
      "different combintations of distance classes and LULC types."
    ),
    "",
    paste(
      "The resulting values are given here, so that the columns lulc, distance and t_percentile indicate a distinct",
      "combination of LULC type, distance class and temporal percentiles. In the remaining columns, for each",
      "considered spatial percentile, the aggreagted",
      value_name,
      "value is given."
    )
  ),
  data = overview
), file.path(params$output, paste(value_name, "QTQX.xlsx")))

# Contourplots
data_contour <- data_qtqx[
  ,
  c("t_percentile", "s.percentile") := list(
    as.numeric(sub("%", "", t_percentile, TRUE)),
    as.numeric(sub("%", "", s.percentile, TRUE))
  )
]
result <- contourplots(data_contour, analysis_scales, params$output, suffix = "--overview--raster", type = "raster")
result <- contourplots(
  data_contour,
  analysis_scales,
  params$output,
  suffix = "--detail--contour",
  threshold = data_qtqx[value > 0, median(value) / 10]
)
result <- contourplots(data_contour, analysis_scales, params$output, suffix = "--overview--contour")
result <- contourplots(
  data_contour,
  analysis_scales,
  params$output,
  suffix = "--detail--raster",
  threshold = data_qtqx[value > 0, median(value) / 10],
  type = "raster"
)

# Animation
if (!is.null(params$ffmpeg)) {
  plot_per_timestep(
    params$x3df, params$dataset, file.path(params$output, "raster"), spatial_info, data_qtqx[, sqrt(max(value))])
  animate(file.path(params$output, "raster", "%06d.png"), file.path(params$output, "animation.avi"), params$ffmpeg)
}

# Cooccurence of spray-drift and run-off events
result <- coocurrence_spray_drift_run_off(params$x3df, params$spraydrift, params$runoff)
if (!is.null(result)) {
  write_to_xlsx(list(
    info = c(
      "Workbook description",
      "",
      paste(
        "This workbook contains aggregated data for this MonteCarlo run. The data was processed in the following way:"),
      "1. All dates of spray-applications and of run-off events where loaded.",
      "2. The shortest number of days between spray-applications and following run-off events were calculated.",
      "",
      paste("The data worksheet shows for several percentiles the number of days between spray-application and next",
            "run-off event."
      )
    ),
    data = result
  ), file.path(params$output, paste(value_name, "Cooccurence sd - runoff.xlsx")))
}
