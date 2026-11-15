# Runoff Flowgrid Generation

The PRZM runoff source calculation is field-based, but the landscape model still needs a representation of flow direction and connectivity between fields or cells. In xOffFieldSoilRisk, this information is supplied as a flow grid in the scenario package and is connected to the `RunOffPrzm` component through the `Fields_FlowGrid` input.

## Scenario representation

The scenario metadata in `scenario/<scenario-name>/geo/package.xinfo` declares a supplementary flow-grid asset. In the NRW scenario, the package file includes:

```xml
<supplementary>
    <flow_grid deviatingExtent="confirmed">flow.tif</flow_grid>
    <land_use_raster>lulc.tif</land_use_raster>
    <analysis_distance_groups>AnalysisBuffer.tif</analysis_distance_groups>
</supplementary>
```

This is not the PRZM soil profile itself. It is the lateral routing basis used by the landscape model to determine how runoff moves across cells and how exported loads are routed away from the field.

## Derivation from a DEM

The project code shows that the flow grid is typically derived from a DEM during scenario preparation. In `model/core/components/LandscapeScenarioPreparation.py`, the preparation component reads a DEM, clips it to the scenario extent, and computes a flow-direction raster using a local neighbourhood rule. The generated raster is written to `flow.tif`.

If no DEM is available, the component falls back to a generic west-to-east flow raster rather than leaving the scenario without a flow grid.

## Why this matters for PRZM runoff

The distinction between runoff generation and flow-grid generation is important:

- PRZM computes runoff volume, dissolved pesticide mass, and sediment-associated pesticide mass at the field boundary.
- The flow grid provides the landscape routing context that tells the model how those exports move across cells or fields.
- Therefore, the flow grid is a structural landscape input, while the PRZM runoff equation is the source term.

In the current implementation, flow-grid generation and runoff generation are therefore related but conceptually separate: the DEM-derived flow field defines connectivity, while PRZM computes the field-edge runoff and resulting pesticide export.

## Relevant project files

- [scenario/NRW1/geo/package.xinfo](../../scenario/NRW1/geo/package.xinfo)
- [model/core/components/LandscapeScenarioPreparation.py](../../model/core/components/LandscapeScenarioPreparation.py)
- [model/variant/RunOffPrzm/RunOffPrzm.py](../../model/variant/RunOffPrzm/RunOffPrzm.py)
