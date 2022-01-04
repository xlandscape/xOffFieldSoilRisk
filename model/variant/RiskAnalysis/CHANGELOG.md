# CHANGELOG
This list contains all additions, changes and fixes for the Risk Analysis R scripts.

## [12] - 2022-01-04
### Added
### Changed
### Fixed
- Wrong percentile tables due to non-aligned geospatial data

## [11] - 2021-12-30
### Added
### Changed
### Fixed
- Error when trying to analyze co-occurrence of spray-drift and runoff if not both were simulated

## [10] - 2021-12-30
### Added
### Changed
- Complete re-factory to reduce memory consumption for analysis of large scenarios
### Fixed

## [9] - 2021-12-08
### Added
### Changed
- Spell checking
### Fixed

## [8] - 2021-12-06
### Added
### Changed
- Reduced memory usage of `risk_analysis_percentiles` function
### Fixed

## [7] - 2021-10-18
### Added
### Changed
- Replaced `raster` by `terra` package in `RiskAnalysis_MC.R`
- Removed unneeded package imports in `RiskAnalysis_Experiment.R`
### Fixed

## [6] - 2021-10-15
### Added
### Changed
- Usage of `_MODULE_DIR_` system macro in `README`
### Fixed

## [5] - 2021-09-09
### Added
### Changed
- Modified RiskAnalysis to prevent warnings from concentrations of 0 in logarithmic contour-plots
### Fixed

## [4] - 2021-09-08
### Added
### Changed
- Complete re-factory of analysis scripts
- Re-factory of README.md
- Renamed LICENSE.txt to LICENSE
### Fixed

## [3] - 2020-12-02
### Added
- README, LICENSE, CHANGELOG and CONTRIBUTION.
### Changed
### Fixed


## [2]
### Added
### Changed
- Generic functions included within the scripts.

### Fixed


## [1]
### Added
- First release of the scripts independent of the AnalysisObserver.

### Changed
### Fixed