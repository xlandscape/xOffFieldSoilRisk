## Table of Contents
* [About the project](#about-the-project)
  * [Built With](#built-with)
* [Getting Started](#getting-started)
  * [Prerequisites](#prerequisites)
  * [Installation](#installation)
* [Usage](#usage)
* [Roadmap](#roadmap)
* [Contributing](#contributing)
* [License](#license)
* [Contact](#contact)
* [Acknowledgements](#acknowledgements)


## About the project
Provided here are two R scripts that can be used to generate default reporting elements for XOffFieldSoilRisk simulation
runs.

### Built with
* Landscape Model core v1.4.1
* [R](https://cran.r-project.org) v3.5.1


## Getting Started
The R scripts are intended for the use within the XOffFieldSoilRisk Landscape Model. They can, however, also be used as
stand-alone R scripts in any context.

### Prerequisites
To use the R scripts within the XOffFieldSoilRisk, make sure that the model is set up according to the Landscape Model
`README` and that an `AnalysisObserver` is included in the model (see the `REDAME` of the `AnalysisObserver`).

### Installation
1. Copy the scripts into a sub-folder of XOffFieldSoilRisk, e.g., `model\variant\RiskAnalysis`.
2. Configure observers for the experiment and for the Monte Carlo run according to the [usage](#usage) section.


## Usage
Both scripts are called with a set of named and unnamed parameters that are either passed manually as command line 
arguments or automatically if configured as Landscape Model observers.

### `RiskAnalysis_MC.R`
This script performs analysis on a Monte Carlo run base. It first aggregates spatio-temporal values from a X3df file
into temporal percentiles ranging from 0 to 100 in one percent steps per spatial unit (one square-meter cells). For 
some of these temporal percentiles, namely the 50th, 75th, 90th, 95th and 100th, a map is plotted and saved to the
output folder. For further analysis, habitat types are considered individually and combined, and habitats are considered
entirely and within the following distance classes to the nearest field edge only: 0 m to 5 m, 0 m to 10 m, 0 m to 
20 m, 0 m to 50 m, 0 m to 100 m and 2 m to 5 m. For each combination of considered habitat type and distance class and
for each temporal percentile in one-percent steps, percentiles from the 0th to the 100th are calculated in one-percent
steps. The resulting table of spatio-temporally aggregated values per statistical population is written to the output 
folder. From this raw percentile table, all values relating to the 0th, 1st, 5th, 10th, 25th, 50th, 75th, 90th, 95th, 
99th and 100th spatial percentiles and to the 50th, 75th, 90th, 95th and 100th percentile are extracted and written to
another percentile table in the output folder for a more concise overview. For the same percentile combinations (and
per combination of habitat type and distance class), a raster plot and a contour plot are written into the output 
folder, once showing the entire percentile range from 0 to 100 percent and once only for the range of percentiles where
values larger than zero occur. If an according parameter is specified, the script does also prepare an animation
showing the spatial distribution of values over time. Finally, a co-occurrence of spray-drift and run-off analysis is
conducted that outputs the distribution of number of days between a spray-drift event (and, thus, an application) and
the next run-off event.

The following example shows how to run the script from the command lin with all arguments specified:
```cmd
Rscript.exe --vanilla RiskAnalysis_MC.R --dataset=DepositionToPecSoil/PecSoil --extent=LULC/Extent 
--ffmpeg=ffmpeg/ffmpeg.exe --habitats=LULC/HabitatLulcTypes --lulc=LULC/LulcRaster --rlibpath=./R-3.5.1/library
--runoff=RunOff/Exposure --spraydrift=SprayDrift/Exposure --crs=LULC/Crs C:\experiment\mc\store C:\experiment\mc\output
```

An XOffFieldSoilRisk configuration for the observer could look like this:
```xml
<Observer module="AnalysisObserver" class="AnalysisObserver">
    <Script>$(_X3DIR_)/../../variant/RiskAnalysis/RiskAnalysis_MC.R</Script>
    <Data>$(_MCS_BASE_DIR_)\$(_MC_NAME_)\store</Data>
    <Output_Folder>$(_MCS_BASE_DIR_)\$(_MC_NAME_)\analysis</Output_Folder>
    <Dataset>DepositionToPecSoil/PecSoil</Dataset>
    <Distance>LandscapeScenario/analysis_distance_groups</Distance>
    <Extent>LandscapeScenario/Extent</Extent>
    <Crs>LandscapeScenario/Crs</Crs>
    <Habitats>LandscapeScenario/habitat_types</Habitats>
    <Lulc>LandscapeScenario/land_use_raster</Lulc>
    <RLibPath>./R-3.5.1/library</RLibPath>
    <RunOff>RunOff/Exposure</RunOff>
    <SprayDrift>SprayDrift/Exposure</SprayDrift>
</Observer>
```
The parameters in detail are the following for the configuration (and the command line, respectively):
* `script` (first unnamed argument passed to the `Rscript` call): The path to the R script.
* `data` (first unnamed argument passed to the script): The file path where the `arr.dat` of the Monte Calo run is 
  located.
* `output_folder` (second unnamed argument passed to the script): The file path where output files are written to.
* `dataset`: The dataset containing the input data. This is a spatio-temporal array as created by the `base.Efate`
   component.
* `distance`: The dataset with distance groups. This is a two-dimensional matrix provided by the `base.Lulc` component
  and prepared by the scenario developer.
* `extent`: The dataset containing the spatial extent. This is a list of four values as output by the `base.Lulc` 
  component.
* `ffmpeg`: The path to the ffmpeg video encoder. This parameter is optional. if it is omitted, no animation is 
   generated.
* `habitats`: The dataset with the habitat types. This is a list of land-use / lnd-cover types that are considered 
  habitats as output by the `base.Lulc` component and prepared by the scenario developer.
* `lulc`: The dataset containing land-use / land-cover types per cell. This is a two-dimensional matrix provided by 
  the `base.Lulc` 
  component and prepared by the scenario developer.
* `rlibpath`: The path containing the required R packages. Can be used to load R packages from a specific path.
* `runoff`: The dataset containing run-off exposure. This is a two-dimensional matrix as provided by the `RunOffPrzm` 
  component.
* `spraydrift`: The dataset containing spray-drift exposure. This is a two-dimensional matrix as provided by the 
  `XSprayDrift` component.
* `crs`: The dataset containing the CRS. This is a PROJ4 representation of the coordinate system as output by the 
  `base.Lulc` component.

### `RiskAnalysis_Experiment.R`
This script performs analysis on an experiment base. First, it loads the raw percentiles of multiple Monte Carlo runs as
they are output by the `RiskAnalysis_MC.R` script. For these percentiles, expectation values and 95%-confidence 
intervals over Monte Carlo runs are then calculated and written to the output folder. Specific percentile combinations 
(same as in the `RiskAnalysis_MC.R` script) are extracted from the raw data and output as an overview table. Finally,
for the same combinations of temporal and spatial percentiles, box-plots showing the vales over Monte Carlo runs are
written to the output folder.

The following example shows how to run the script from the command lin with all arguments specified:
```cmd
Rscript.exe --vanilla RiskAnalysis_Experiment.R --dsname=DepositionToPecSoil/PecSoil --rlibpath=./R-3.5.1/library
C:\experiment\experiment C:\experiment\output
```

An XOffFieldSoilRisk configuration for the observer could look like this:
```xml
<Observer module="AnalysisObserver" class="AnalysisObserver">
    <Script>$(_X3DIR_)/../../variant/RiskAnalysis/RiskAnalysis_Experiment.R</Script>
    <Data>$(_EXP_BASE_DIR_)\$(SimID)\mcs</Data>
    <Output_Folder>$(_EXP_BASE_DIR_)\$(SimID)\analysis</Output_Folder>
    <DsName>PecSoil</DsName>
    <RLibPath>./R-3.5.1/library</RLibPath>
</Observer>
```
The parameters in detail are the following for the configuration (and the command line, respectively):
* `script` (first unnamed argument passed to the `Rscript` call): The path to the R script.
* `data` (first unnamed argument passed to the script): The file path under which the results of the `RiskAnalysis_MC.R`
  scripts run for individual Monte Carlo runs are located. All according files anywhere under this file path are used. 
* `output_folder` (second unnamed argument passed to the script): The file path where output files are written to.
* `dsname`: The name of the dataset. Is used to write descriptions to the generated tables.
* `rlibpath`: The path containing the required R packages. Can be used to load R packages from a specific path.


## Roadmap
The scripts are considered stable and no further development is currently planned. The use of `ReportingElements`, 
within compositions or within Jupyter notebooks is preferred over the use of the `AnalysisObserver`. The scripts do
also not make use of the `xRisk` R package, which is now the default way to access X3df data from within R.


## Contributing
Contributions are welcome. Please contact the authors (see [Contact](#contact)).


## License
Distributed under the CC0 License. See `LICENSE` for more information.


## Contact
Thorsten Schad - thorsten.schad@bayer.com
Sascha Bub - sascha.bub.ext@bayer.com


## Acknowledgements
* [Apply function progress bars](https://cran.r-project.org/web/packages/pbapply)
* [data.table](https://cran.r-project.org/web/packages/data.table)
* [Direct Labels](https://cran.r-project.org/web/packages/directlabels)
* [FFmpeg](https://ffmpeg.org)
* [ggplot2](https://cran.r-project.org/web/packages/ggplot2)
* [h5](https://cran.r-project.org/web/packages/h5)
* [matrixStats](https://cran.r-project.org/web/packages/matrxistats)
* [openxlsx](https://cran.r-project.org/web/packages/openxlsx)
* [optparse](https://cran.r-project.org/web/packages/optparse)
* [R GDAL bindings](https://cran.r-project.org/web/packages/rgdal)
* [raster](https://cran.r-project.org/web/packages/raster)
