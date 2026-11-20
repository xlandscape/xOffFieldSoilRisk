# Understanding `mc.xml`

This guide explains [`model/variant/mc.xml`](../model/variant/mc.xml), the
Monte Carlo (MC) run configuration template used by xOffFieldSoilRisk. It
describes the configuration visible in the XML; it does not claim to document
the internal algorithms of each component.

## What it is for

`mc.xml` describes how to assemble and run **one MC model run**: which model
components participate, their settings, how their inputs connect to other
components, and where this run's data, logs, processing files, and analysis
are placed. An experiment can use this template for multiple individual MC
runs. Tokens such as `$(DT50)` and `$(_MC_NAME_)` are placeholders to be
resolved by the surrounding experiment; they are not all literal values or
paths.

In the project's normal workflow, users parameterize an experiment through a
`.xrun` file such as [`template.xrun`](../template.xrun). `mc.xml` is the model
composition template, rather than a results file or a complete scenario.

## Overall model flow

```text
Weather -------------------------------------------> RunOffPrzm --+
LandscapeScenario -> PPM applications -----------> RunOffPrzm    |
        |                     +-------------------> SprayDrift ---+--> EnvironmentalFate
        +-----------------------------------------> both pathways                 |
                                                                                  v
                                                                     DepositionToPecSoil
```

The two exposure pathways can be enabled independently. Both feed
`EnvironmentalFate` through conditional `FromOutput` connections. The fate
output then feeds `DepositionToPecSoil`; the analysis observer names
`DepositionToPecSoil/PecSoil` as its dataset.

## Top-level structure

| XML section | Purpose |
| --- | --- |
| `Observers` | Configures console messages, MC analysis, and a per-run log. |
| `Store` | Configures the `X3dfStore` and the per-run data-store path. |
| `Global` | Declares the simulation start and end dates. |
| `Composition` | Defines eight model components, their settings, and their data connections. |

### Observers and store

The `AnalysisObserver` points to
`$(_MODEL_DIR_)/variant/RiskAnalysis/RiskAnalysis_MC.R`. It reads data from the
per-run `store` folder, writes into the per-run `analysis` folder, and is
configured with these data paths:

| Analysis setting | Component output |
| --- | --- |
| `Dataset` | `DepositionToPecSoil/PecSoil` |
| `Distance` | `LandscapeScenario/analysis_distance_groups_values` |
| `Extent` | `LandscapeScenario/Extent` |
| `EPSG` | `LandscapeScenario/EPSG` |
| `Habitats` | `LandscapeScenario/habitat_types` |
| `Lulc` | `LandscapeScenario/land_use_raster_values` |
| `RunOff` | `RunOffPrzm/Exposure` |
| `SprayDrift` | `SprayDrift/Exposure` |

`Elements` is set to `100000000`, and `RLibPath` to `./R-4.1.1/library`. The XML
does not explain the interpretation of `Elements` or the base directory for
that relative library path.

The `LogFileObserver` targets
`$(_EXP_BASE_DIR_)\$(SimID)\log\mc_$(_MC_NAME_).log`. The `X3dfStore` uses
`$(_MCS_BASE_DIR_)\$(_MC_NAME_)\store`. Both the console and log observers set
`show_messages_get_values_ok` to `false`.

## How to read component configuration

A composition entry gives a component name plus its module and class. For
example:

```xml
<SprayDrift module="XSprayDrift" class="SprayDrift" enabled="$(SimulateSprayDriftExposure)">
```

An input can be a literal, a token, or a connection to another component's
output. For example, spray drift's `AppliedFields` input is connected to
`PPM/AppliedFields`:

```xml
<AppliedFields>
  <FromOutput component="PPM" output="AppliedFields"/>
</AppliedFields>
```

Attributes such as `type`, `unit`, and `scales` describe expected value type,
physical units, or scale. For example,
`type="float" unit="m" scales="global"` describes a global-scale float in
metres. Crop parameter lists use `element_names` to identify the crop list to
which their entries correspond.

Tokens such as `$(DT50)`, `$(ReportingThreshold)`, and
`$(_MCS_BASE_DIR_)\$(_MC_NAME_)` indicate values or paths to be supplied by
the run environment. References such as `$(:LandscapeScenario)` and
`$(:weather_$$(Weather))` are also unresolved references, not self-explanatory
literal paths. Their exact resolution rules are not defined by `mc.xml`.

## The eight components

### 1. `Weather` (`components.MarsWeather`)

Selects weather through `$(:weather_$$(Weather))`. The runoff component
receives precipitation, ET0, average temperature, wind speed, and radiation.
Each weather connection applies a `CoordinateTransform` configured with
`Transformation_type=date` and `Offset=1975-01-01`; the details of the
transformation are not specified here.

### 2. `LandscapeScenario` (`components.LandscapeScenario`)

Loads base landscape geometries through `$(:LandscapeScenario)` and uses the
namespace `urn:xOffFieldSoilRiskLandscapeScenarioPackageInfo`. Its geometry,
feature IDs and types, CRS, extent, habitat types, and flow grid provide
spatial inputs to other components. The analysis observer also references its
distance-group, extent, EPSG, habitat, and land-use outputs.

### 3. `PPM` (`CropProtection.xCropProtection`)

Configures pesticide applications from the per-run `CropProtection.xml` and
uses the namespace
`urn:xCropProtectionLandscapeScenarioParametrization`. Field identifiers,
field types, and geometries are supplied by `LandscapeScenario`.

The PPM outputs supply applied fields, application dates and rates, and
applied areas to exposure components; spray drift also receives technology
drift reductions. Other settings include:

| Setting | Value |
| --- | --- |
| Simulation dates | `$(SimulationStart)` to `$(SimulationEnd)` |
| `RandomSeed` | `0` |
| `OutputApplicationType` | `product` |
| `ProductDatabase` | `$(_EXP_BASE_DIR_)\$(SimID)\dummy.sqlite` |
| `XMLPath` | `$(_EXP_BASE_DIR_)\$(SimID)` |
| `MinimumAppliedArea` | `10` (no unit declared here) |

The PPM seed is distinct from spray drift's `$(RandomSeed)`; the XML does not
explain how different MC runs get their values.

### 4. `SprayDrift` (`XSprayDrift.SprayDrift`)

This optional pathway is controlled by `$(SimulateSprayDriftExposure)`. It
receives landscape geometries, CRS, extent, habitat types, and land-use types,
as well as PPM application outputs. Its `Exposure` output is connected to
environmental fate when the same flag is enabled.

Important configured values include:

| Setting | Value |
| --- | --- |
| Simulation dates | `2006-01-01` to `2015-12-31` |
| `FieldDistanceSD`, `EPDistanceSD`, `MinimumDistanceToField` | `0 m` each |
| `ReportingThreshold` | `$(ReportingThreshold)`, unit `g/ha` |
| `ApplySimpleDriftFiltering` | `$(VegetationDriftFiltering)` |
| `FilteringTypes`, `FilteringMinWidth`, `FilteringFraction` | Empty list, `999 m`, `0` |
| `WindDirection`, `SprayDriftModel`, `RandomSeed` | Run tokens |
| `SourceExposure`, `RautmannClass`, `SpatialOutputScale` | `NA`, `arable`, `1sqm` |
| AgDrift settings | Low boom height, fine droplet size, quantile `0.9` |

The filtering settings should be interpreted using the component's
documentation; the XML alone is not enough to derive their complete behaviour.

### 5. `RunOffPrzm` (`RunOffPrzm.RunOffPrzm`)

This optional pathway is controlled by `$(SimulateRunOffExposure)`. It takes
the five transformed weather series, spatial inputs from `LandscapeScenario`,
and application data from PPM. Its `Exposure` output is connected to
environmental fate when its pathway flag is enabled.

Selected model options are `Model_AdsorptionMethod=aged`,
`Model_SoilTemperatureSimulation=true`, and
`Options_MethodOfRunoffGeneration=PRZM`. Pre-simulated PRZM results are
enabled; one PRZM model per grid cell and VfsMod are disabled. The dates are
`2006-01-01` to `2015-12-31`, and the configured application method is
`foliar` with incorporation depth `5 cm`.

#### Runoff substance parameters

| Parameter | Value in the template |
| --- | --- |
| Substance name | `$(Substance)` |
| Soil DT50 | `$(DT50)`, days |
| Soil Koc | `$(KocSoil)`, cm³/g |
| Freundlich exponent | `$(FreundlichExponent)` |
| Plant uptake factor | `0`, 1/d |
| Foliage dissipation rate | `10`, 1/d |
| Foliar wash-off coefficient | `0.5`, 1/cm |
| Henry constant | `0`, unit `1` |
| Vapour pressure | `0.0001`, mPa |
| Molecular weight | `304`, g/mol |
| Water solubility | `60`, mg/L |
| Measurement temperature | `293`, K |
| Reference moisture for soil DT50 | `100%` |

These are configured inputs, not evidence that the values are appropriate for
every substance or landscape.

#### Runoff field, soil, and crop parameters

The field slope is `3%`; `Fields_InFieldMargin` uses `$(InFieldMargin)`. The
three entries in each soil list describe the three configured horizons:

| Soil property | Horizon values | Unit |
| --- | --- | --- |
| Thickness | `30 30 40` | cm |
| Bulk density | `1.35 1.45 1.48` | g/cm³ |
| Organic material content | `1.2 0.3 0.1` | % |
| Sand fraction | `5 6 5` | % |
| Silt fraction | `82 83 84` | % |

Crop-specific lists are associated with `RunOffPrzm/CropParameters_Crops` and
match the two crop entries, `Cereals,Winter|OffCrop`, in order:

| Crop parameter | Cereals,Winter | OffCrop | Unit |
| --- | --- | --- | --- |
| VfsMod lookup table | `none` | `$(:Vfs-Mod_lookup_table)` | — |
| Pan evaporation factor | `0.84` | `0.84` | 1 |
| Canopy interception | `0.15` | `0.15` | cm |
| Maximum coverage | `90` | `90` | % |
| Maximum height | `110` | `110` | cm |
| Maximum rooting depth | `130` | `130` | cm |
| Fallow | `0.9` | `0.9` | 1 |
| Cropping | `0.2` | `0.2` | 1 |
| Residues | `0.4` | `0.4` | 1 |
| Emergence date | `12-11` | `12-11` | — |
| Maturation date | `10-06` | `10-06` | — |
| Harvest date | `31-07` | `31-07` | — |
| Fallow date | `01-11` | `01-11` | — |
| Water mitigation | `0` | `-0.086` | 1 |
| Sediment mitigation | `0` | `-0.153` | 1 |

Although `Options_UseVfsMod` is `false`, the second crop still has a VfsMod
lookup reference. The XML alone does not establish whether that reference must
resolve while the option is disabled.

The runoff temporary-output path is `$(RunOffTempDir)\$(_MC_NAME_)`.
`Options_DeleteTemporaryGrids` and `Options_DeleteAllInterimResults` are
`true`; extended error information is enabled and the PRZM timeout is
`100 s`.

**Unit caution:** `$(ReportingThreshold)` is declared in `g/ha` for spray
drift and `mg` for runoff. These declarations must not be assumed equivalent:
the XML does not specify a conversion.

### 6. `EnvironmentalFate` (`components.EnvironmentalFate`)

Receives enabled exposure outputs from spray drift and runoff, along with
`$(DT50)` as `SoilDT50` in days. Its `Pec` output feeds
`DepositionToPecSoil`. The XML specifies the connections and input, not the
environmental-fate equations.

### 7. `DepositionToPecSoil` (`components.DepositionToPecSoil`)

Takes `EnvironmentalFate/Pec` as `Deposition` and sets soil bulk density to
`1.5 g/cm³` and depth to `5`. **No unit is declared for `Depth` in this XML.**
The component's input contract must be checked before interpreting or changing
that value. The analysis observer names the `PecSoil` output as its dataset.

### 8. `DeleteFolder` (`components.DeleteFolder`)

Targets `$(_MCS_BASE_DIR_)\$(_MC_NAME_)\processing`, the per-run processing
folder. It appears last in the composition. Because cleanup is configured,
do not assume intermediate files in that folder will remain after a run. The
processing folder is separate from the store, log, and analysis paths.

## Practical checklist

1. For ordinary experiment parameterization, start with `template.xrun`; edit
   `mc.xml` when the model composition or its fixed configuration needs to
   change.
2. Keep the dates in `Global`, `SprayDrift`, and `RunOffPrzm` aligned.
3. Check both exposure switches and their corresponding fate-input links.
4. Confirm that weather, scenario, crop-protection, temporary-directory, and
   R-library references resolve for the experiment.
5. Check list lengths, crop ordering, types, units, and component input
   contracts. In particular, do not infer a unit for `Depth` from the value
   alone or treat both reporting-threshold units as interchangeable.
6. Expect processing/interim cleanup; do not rely on temporary outputs for
   post-run inspection.
7. When investigating a run, check its log, store, and analysis outputs.

The companion [slide deck](mc-xml-guide-slides.pptx) summarizes the
configuration.
