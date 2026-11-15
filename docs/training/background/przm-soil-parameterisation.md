# PRZM Soil Parameterisation

## Purpose and scope

A new landscape scenario brings spatial information into xOffFieldSoilRisk, but the PRZM soil profile is currently parameterised in the **model run**, not discovered automatically from the scenario's GeoTIFF or shapefile attributes. This distinction is important:

- the scenario supplies the landscape geometry, feature identifiers, land-use information, flow grid, and analysis regions;
- the xOffField model parameterisation supplies the soil profile used by `RunOffPrzm`;
- PRZM uses that profile to calculate water movement, runoff, erosion, and pesticide fate for the modeled fields.

The current `RunOffPrzm` component uses `PRZM_Runoff` version 1.47 and is based on the FOCUS surface-water PRZM implementation. The soil inputs described here are therefore the inputs expected by the xOffField component and its PRZM_Runoff module. They are not a universal import format for every PRZM release.

## Conceptual workflow

When adapting xOffFieldSoilRisk to a new landscape, treat soil parameterisation as a chain from observations to a defensible model profile:

1. **Define the soil domain.** Decide which agricultural fields are represented, what soil mapping unit applies to each field, and whether one representative profile is adequate or several profiles are required.
2. **Collect or derive horizon data.** Obtain depths, bulk density, organic matter, sand, and silt for each horizon from a soil survey, laboratory measurements, or a documented pedotransfer workflow.
3. **Harmonise the data.** Convert units, align horizon boundaries, resolve missing values, and calculate clay only after checking that sand, silt, and clay use the same basis.
4. **Choose a model representation.** The current component expects one ordered profile of horizon arrays at the `other/soil_horizon` scale. If the landscape contains several distinct soil classes, decide whether to run separate parameterisations, extend the component interface, or use a documented representative profile.
5. **Map the profile into xOffField inputs.** Put the same number of horizon values into each required array, in top-to-bottom order.
6. **Check hydrologic consistency.** Verify that the soil profile, Curve Number, slope, crop properties, weather, and erosion parameters describe the same field conditions. Do not treat the Curve Number as a substitute for missing horizon data.
7. **Run a technical test.** Use a short simulation and inspect the generated PRZM input and output files before running a full Monte Carlo experiment.
8. **Document provenance and uncertainty.** Record the source dataset, sampling depth, averaging method, conversions, representative soil choice, and sensitivity ranges.

The goal is not to reproduce every centimetre of a soil survey. It is to create a traceable model profile whose resolution and parameters are appropriate for the runoff and pesticide questions being asked.

## Required PRZM soil inputs

The current `RunOffPrzm` interface accepts five horizon arrays. Each array must have the same number of entries, and entry $i$ in every array describes the same horizon. Values are ordered from the soil surface downward.

| xOffField input | Meaning | Unit | Scale and ordering |
| --- | --- | --- | --- |
| `Fields_SoilHorizonThicknesses` | Thickness of each horizon | `cm` | `other/soil_horizon`, top to bottom |
| `Fields_SoilHorizonBulkDensities` | Dry bulk density of each horizon | `g/cm^3` | `other/soil_horizon`, same order |
| `Fields_SoilHorizonOrganicMaterialContents` | Organic material content of each horizon | `%` | `other/soil_horizon`, same order |
| `Fields_SoilHorizonSandFractions` | Sand fraction of each horizon | `%` | `other/soil_horizon`, same order |
| `Fields_SoilHorizonSiltFractions` | Silt fraction of each horizon | `%` | `other/soil_horizon`, same order |

The component documentation defines these as lists at the `other/soil_horizon` scale. The number of horizons is inferred from the thickness sequence, so the other four sequences must contain exactly the same number of values.

Clay is not a separate current xOffField input. If clay is needed for quality control or for deriving another property, calculate it as:

$$
\mathrm{clay}\,[\%] = 100 - \mathrm{sand}\,[\%] - \mathrm{silt}\,[\%].
$$

This calculation is valid only when all three fractions are reported on the same basis and sum to approximately 100%. Do not silently combine mass fractions from one source with volume fractions from another.

## Example parameterisation

The following example describes a three-horizon profile. The values are illustrative and must not be copied into a scientific scenario without checking the local soil data.

```xml
<Fields_SoilHorizonThicknesses type="list[float]" scales="other/soil_horizon" unit="cm">
    30 30 40
</Fields_SoilHorizonThicknesses>
<Fields_SoilHorizonBulkDensities type="list[float]" scales="other/soil_horizon" unit="g/cm³">
    1.35 1.45 1.48
</Fields_SoilHorizonBulkDensities>
<Fields_SoilHorizonOrganicMaterialContents type="list[float]" scales="other/soil_horizon" unit="%">
    1.2 0.3 0.1
</Fields_SoilHorizonOrganicMaterialContents>
<Fields_SoilHorizonSandFractions type="list[float]" scales="other/soil_horizon" unit="%">
    5 6 5
</Fields_SoilHorizonSandFractions>
<Fields_SoilHorizonSiltFractions type="list[float]" scales="other/soil_horizon" unit="%">
    82 83 84
</Fields_SoilHorizonSiltFractions>
```

The corresponding horizon table is:

| Horizon | Depth interval | Thickness | Bulk density | Organic material | Sand | Silt | Derived clay |
| --- | --- | ---: | ---: | ---: | ---: | ---: | ---: |
| 1 | 0-30 cm | 30 cm | 1.35 g/cm³ | 1.2% | 5% | 82% | 13% |
| 2 | 30-60 cm | 30 cm | 1.45 g/cm³ | 0.3% | 6% | 83% | 11% |
| 3 | 60-100 cm | 40 cm | 1.48 g/cm³ | 0.1% | 5% | 84% | 11% |

The total modeled profile depth is:

$$
Z_{\mathrm{profile}} = \sum_{i=1}^{n} d_i,
$$

where $d_i$ is the thickness of horizon $i$. In the example:

$$
Z_{\mathrm{profile}} = 30 + 30 + 40 = 100\,\mathrm{cm}.
$$

A profile should extend far enough to represent the active PRZM soil domain required by the selected scenario and model settings. Avoid truncating the profile at an arbitrary data boundary without documenting the consequence for drainage and chemical storage.

## Mapping new soil data to a scenario

### Spatial scenario package

A new scenario is normally created below `scenario/<scenario-name>/`. Its `scenario.xproject` identifies the scenario and points to the geographic package. The `geo/package.xinfo` file identifies the spatial assets. In the schematic scenario, the package includes:

- `fields.shp` as the base landscape geometry;
- `ID` as the feature identifier;
- `LULCTypeID` as the feature type attribute;
- `fields.tif` as the land-use raster;
- `flow_dir.tif` as the flow grid; and
- `AnalysisBuffer.tif` as analysis distance groups.

For a new landscape, replace these assets with the corresponding data for the new region and keep the package metadata consistent. The flow grid must use the orientation and coding expected by the Landscape Model core. A soil raster can be added to the scenario package as provenance or for future extensions, but adding a raster alone does not currently populate the `Fields_SoilHorizon*` inputs.

### Soil-to-field mapping

For each modeled field, determine the soil mapping unit or profile that should represent it. Then choose one of the following supported workflows:

- **One representative profile:** use when the modeled fields are sufficiently homogeneous or when the study intentionally uses a common regulatory profile.
- **Separate model runs:** use when soil classes materially differ and each class requires its own PRZM parameterisation.
- **Component extension:** use when spatially varying soil profiles are scientifically required within one run. This requires changing the component/module interface and validating the new behavior; it cannot be achieved by adding an unreferenced soil file to `geo`.

The current five arrays are global profile arrays at the `other/soil_horizon` scale. They do not contain a field identifier. Therefore, do not place multiple field profiles end-to-end in one list and assume PRZM will associate them with fields. That would create one invalid or unintended profile.

## Technical preparation of soil data

### Horizon boundaries

Soil datasets often use different horizon boundaries. Before populating the arrays, create a harmonised table with one row per modeled horizon. If the source has more layers than the PRZM parameterisation needs, aggregate adjacent layers using documented rules. For thickness-weighted properties such as bulk density or a fraction, a weighted mean is usually more defensible than an unweighted mean:

$$
\bar{x} = \frac{\sum_{i=1}^{m} x_i d_i}{\sum_{i=1}^{m} d_i},
$$

where $x_i$ is the source property and $d_i$ is the thickness represented by source layer $i$. Do not average properties across clearly different soil horizons merely to reduce the list length.

### Bulk density and porosity

Bulk density must be supplied in `g/cm^3`, not particle density and not a percentage. A useful plausibility check is the approximate total porosity:

$$
\phi \approx 1 - \frac{\rho_b}{\rho_s},
$$

where $\rho_b$ is dry bulk density and $\rho_s$ is assumed particle density. With $\rho_s \approx 2.65\,\mathrm{g/cm^3}$, a mineral-soil bulk density of $1.35\,\mathrm{g/cm^3}$ implies approximately 49% porosity. This is a screening check, not a replacement for measured hydraulic properties.

### Organic matter versus organic carbon

Confirm whether the source reports organic matter (OM) or organic carbon (OC). They are not interchangeable. A commonly used approximation is:

$$
\mathrm{OM} \approx 1.724 \times \mathrm{OC},
$$

but the factor is method- and soil-dependent. The xOffField input is named `OrganicMaterialContents`; document the source convention and conversion used rather than applying this factor automatically.

### Texture closure and units

Check every horizon for:

- thickness greater than zero;
- bulk density greater than zero and within a plausible range;
- sand and silt between 0 and 100%;
- sand plus silt no greater than 100% within rounding tolerance;
- a non-negative derived clay fraction; and
- consistent dry-basis or wet-basis conventions.

A simple closure test is:

$$
\left|\mathrm{sand} + \mathrm{silt} + \mathrm{clay} - 100\right| \le \epsilon,
$$

where $\epsilon$ is the tolerance chosen for source rounding.

## Hydrologic consistency checks

Soil texture alone does not determine runoff. Review the profile together with the other `RunOffPrzm` inputs:

- `Fields_Slope` is a global average slope used for PRZM runoff and should be reasonably consistent with the scenario's terrain and flow grid.
- `Fields_FlowGrid` controls spatial flow routing after field export; it is not a replacement for the PRZM soil profile.
- `Options_MethodOfRunoffGeneration` selects the runoff-generation method and is configured as `PRZM` in the standard example.
- `CropParameters_*` affect interception, cover, roots, residue, and mitigation, all of which can alter runoff and erosion.
- Weather precipitation and evapotranspiration must use the temporal extent and units expected by the component.
- Curve Number and erosion parameters must describe the same land cover, soil condition, and management assumptions as the new profile.

Changing a soil profile without reviewing the Curve Number can produce an internally inconsistent scenario. Conversely, changing the Curve Number does not repair missing or unsuitable horizon properties.

## Validation checklist

Before a full run, verify:

1. The scenario package opens and `scenario.xproject` points to the intended `geo/package.xinfo`.
2. Geometry identifiers are unique and match the feature attributes used by the landscape package.
3. The flow grid covers the modeled landscape and uses the expected CRS, extent, and cell alignment.
4. Every soil array has the same number of values as `Fields_SoilHorizonThicknesses`.
5. Horizon values are ordered from the surface downward and units are explicit.
6. Sand, silt, and derived clay fractions close to 100% within the source tolerance.
7. The profile depth and resolution are justified for the simulation.
8. Slope, Curve Number, crop, weather, and erosion assumptions are mutually consistent.
9. A short test run completes and produces PRZM runoff output without unit or input-file errors.
10. The provenance table and sensitivity assumptions are stored with the scenario or experiment documentation.

## Provenance record

For each new soil profile, retain at least:

- source dataset, version, date, and spatial reference;
- field or soil mapping-unit identifiers;
- sampling depths and horizon harmonisation rules;
- definitions and laboratory methods for organic matter, texture, and bulk density;
- all unit conversions and rounding decisions;
- representative-profile selection and excluded data;
- Curve Number, slope, erosion, and crop assumptions; and
- the xOffField and `PRZM_Runoff` module versions used.

This record makes it possible to distinguish a change caused by new soil data from a change caused by a new PRZM release or a changed landscape-routing configuration.

## Sources

1. xOffFieldSoilRisk `RunOffPrzm` component documentation, including the `Fields_SoilHorizon*` input contract and module version.
2. European Commission Joint Research Centre. *PRZM_SW: FOCUS Surface Water PRZM model*. European Soil Data Centre, FOCUS DG SANTE. [PRZM_SW model documentation](https://esdac.jrc.ec.europa.eu/projects/przmsw).
3. European Commission Joint Research Centre. *FOCUS DG SANTE*. [FOCUS model and scenario documentation](https://esdac.jrc.ec.europa.eu/projects/focus-dg-sante).
4. USDA Natural Resources Conservation Service. *National Engineering Handbook, Part 630, Hydrology*. [NRCS National Engineering Handbook](https://www.nrcs.usda.gov/resources/guides-and-instructions/national-engineering-handbook).

The example values are instructional only. A scientific assessment must cite the actual soil survey or laboratory source, the profile harmonisation method, and the complete xOffField parameterisation.
