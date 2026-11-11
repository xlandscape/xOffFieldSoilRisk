# Runoff modelling approaches: PRZM, openLISEM and ZIN-AgriTra

## Executive summary

The three approaches operate at different modelling scales and answer different questions:

- **PRZM / FOCUS PRZM_SW** is primarily a one-dimensional, field-scale root-zone and pesticide-fate model. Runoff is generated at the field boundary, commonly with the SCS Curve Number method, while erosion is represented with a USLE-based routine. In the xOffFieldSoilRisk implementation, a separate spatial flow model distributes the field-edge export across the landscape.
- **openLISEM** is an event-based, physically based, spatially distributed catchment model. It represents rainfall excess, infiltration, surface storage, overland-flow routing and erosion on a raster grid. Its core strength is the spatial pattern and timing of runoff and sediment during individual storm events, rather than long-term pesticide fate in a layered soil profile.
- **ZIN-AgriTra** is a distributed agricultural-catchment reactive-transport model. It explicitly tracks water and substances through cells and pathways at minute-to-hour timesteps, including surface and subsurface export. It is the closest of the three to a catchment-scale pesticide and transformation-product assessment, but requires substantially more spatial, hydrological and substance parameterisation.

The main practical conclusion is that these are not interchangeable runoff modules. PRZM is strongest as a regulatory-style field source term and root-zone fate model; openLISEM is strongest for event runoff, flow connectivity and erosion patterns; ZIN-AgriTra is strongest when the assessment must follow pesticide parent compounds and transformation products through a connected agricultural catchment.

## Scope and terminology

This comparison uses **PRZM_SW / FOCUS PRZM_SW** where the European FOCUS implementation is intended, rather than assuming that every PRZM-family release has identical hydrology. The repository's `RunOffPrzm` component uses the `PRZM_Runoff` module and adds a spatially explicit surface-flow step. The third model is referred to as **ZIN-AgriTra**, which is also written as ZIN-AgriTra in the literature.

Here, "runoff modelling" includes four related questions:

1. How is rainfall converted into excess water?
2. How is that water routed laterally across fields and catchments?
3. How are sediment and erosion represented?
4. How are pesticide mass and transformation products attached to those water pathways?

## Comparison at a glance

| Dimension | PRZM / FOCUS PRZM_SW | openLISEM | ZIN-AgriTra |
| --- | --- | --- | --- |
| Primary scale | One-dimensional soil profile / field | Raster cells in a small catchment; event scale | Distributed agricultural catchment |
| Main purpose | Pesticide fate, leaching, runoff and erosion source term | Storm runoff, flood response, erosion and sediment redistribution | Pesticide and transformation-product export through a catchment |
| Typical time resolution | Daily hydrological timestep in FOCUS PRZM_SW | Sub-event timestep; selected to resolve a storm hydrograph | A few minutes to one hour, depending on setup |
| Spatial representation | Layered vertical profile; lateral routing is external or coupled | Explicit 2-D raster representation of surface processes | Explicit cell-by-cell mass balances and pathway routing |
| Runoff generation | SCS Curve Number approach, combined with a soil-water balance and surface storage | Rainfall excess from interception, infiltration and surface storage processes; spatially varying parameters | Distributed water balance with surface runoff, subsurface flow and drainage pathways |
| Lateral routing | Not the central PRZM calculation; xOffFieldSoilRisk supplies a flow grid and filtering/routing | Core capability; overland flow is routed over the grid | Core capability; surface and subsurface pathways are routed to the stream network |
| Erosion | USLE-based erosion routine in FOCUS PRZM_SW | Explicit event erosion and sediment detachment/transport processes | Catchment transport includes sediment/substance pathways, with emphasis on reactive pesticide export |
| Pesticide fate | Detailed layered-soil fate: sorption, degradation, volatilisation, plant processes and transport; limited TP scheme | Classic LISEM is a hydrology/erosion model; pesticide transport requires an extension or coupling | Reactive transport of parent compounds and TPs; up to three substances in the reviewed formulation, including two TPs |
| Main strength | Consistent, relatively efficient field-scale regulatory assessment | Spatially explicit storm response, flow connectivity and erosion hotspots | Integrated catchment-scale substance pathways and transformation products |
| Main limitation | Daily field source calculation does not by itself resolve catchment hydrographs or spatial flow paths; preferential flow is limited or absent in the FOCUS summary | Event-focused and parameter-intensive; not a complete long-term pesticide fate model by itself | High data and calibration demand; transformation schemes and unresolved application processes remain important uncertainties |

## 1. PRZM / FOCUS PRZM_SW

### Hydrological concept

FOCUS PRZM_SW is based on a one-dimensional finite-difference representation of a layered soil profile. The FOCUS implementation uses capacity-based water flow, commonly described as a daily-time-step tipping-bucket approach, with an option for Richards' equation below the root zone. The JRC description states that preferential flow, capillary rise and drainage are not considered in the standard FOCUS process summary [1].

Runoff is calculated with the **Soil Conservation Service Curve Number** technique. The Curve Number condenses soil hydrologic group, land cover, surface condition and antecedent moisture into an event runoff response. In simplified form:

$$
S = \frac{25400}{CN} - 254,
$$

$$
Q = \begin{cases}
0, & P \le I_a,\\
\frac{(P-I_a)^2}{P-I_a+S}, & P > I_a,
\end{cases}
$$

where $P$ is precipitation, $Q$ is direct runoff depth, $S$ is potential retention and $I_a$ is the initial abstraction. The exact implementation and parameterisation must follow the selected PRZM release and scenario; the equation alone does not make FOCUS PRZM_SW and PRZM5 equivalent.

### Erosion and pesticide export

FOCUS PRZM_SW uses a **Universal Soil Loss Equation** approach for erosion [1]. The pesticide module simulates processes such as advection, dispersion, diffusion, sorption, degradation, volatilisation, plant uptake and foliar washoff in the layered profile [1]. Runoff therefore acts both as a water export and as a carrier for dissolved and sediment-associated pesticide mass.

### Spatial interpretation in xOffFieldSoilRisk

The local `RunOffPrzm` component makes the architectural separation explicit: PRZM computes a field-scale runoff source, while the landscape model uses a flow grid to route exported water and pesticide between cells. Filtering can be represented with a Curve Number technique or VfsMOD. Consequently, the spatial pattern in xOffFieldSoilRisk is a coupled result, not a native two-dimensional PRZM hydrodynamic solution.

### Best fit and limitations

PRZM is a good fit when the main requirement is a reproducible field-edge source term, vertical pesticide fate and regulatory scenario consistency. It is less suitable when the controlling question is the sub-hourly shape of a storm hydrograph, flow concentration in rills or gullies, or the detailed redistribution of sediment across a connected catchment. The daily timestep and the FOCUS treatment of preferential flow are particularly important limitations for flashier runoff and rapid transport problems.

## 2. openLISEM

### Hydrological concept

LISEM was developed as a **single-event, physically based hydrological and soil-erosion model for drainage basins** [2]. The openLISEM lineage retains the central idea of solving spatially distributed surface processes on a raster grid. Each cell can carry spatially varying information such as elevation, land cover, soil properties, roughness, interception and surface storage.

The runoff sequence is event-oriented:

1. rainfall is applied over the grid;
2. interception and surface storage are evaluated;
3. infiltration and rainfall excess are calculated using soil and surface parameters;
4. excess water is routed laterally over the raster;
5. flow depth and velocity drive erosion, deposition and sediment transport.

In contrast to PRZM's field-edge source calculation, the location where runoff is generated and the path it takes are both first-class outputs of the model. The classic LISEM formulation uses physically based or semi-physically based infiltration and overland-flow equations, with routing commonly represented through a kinematic-wave style approach. The precise options depend on the openLISEM version and configuration, so a reproducible study should cite the version and input maps.

### Erosion and sediment transport

Erosion is not an afterthought in LISEM. Splash detachment, flow detachment, transport capacity, deposition and connectivity are represented as spatial event processes [2, 3]. This makes openLISEM useful for identifying runoff and sediment source areas, evaluating management measures and investigating how terrain and land cover reorganise a storm response.

### Pesticide transport

The original LISEM model family is primarily a hydrology and erosion model. It should not be treated as equivalent to a layered pesticide-fate model merely because it routes water and sediment. Pesticide transport requires a dedicated extension, such as an openLISEM pesticide implementation, or coupling to another fate model. This distinction matters for sorption, degradation, transformation products and long-term residue histories.

### Best fit and limitations

openLISEM is a good fit for event-scale questions: where runoff starts, how quickly it reaches a channel, which cells concentrate flow, and where erosion or deposition occurs. It needs detailed spatial input data and event rainfall, and its parameterisation can be demanding. It is not, by itself, the most direct replacement for PRZM's long-term vertical pesticide fate simulation.

## 3. ZIN-AgriTra

### Hydrological and transport concept

ZIN-AgriTra was designed as a **catchment-scale reactive transport model** for pesticides and transformation products in agricultural catchments. The reviewed formulation is fully distributed, uses time steps from a few minutes to one hour, and applies explicit mass balances per cell [4]. This temporal resolution is intended to retain fast runoff and drainage responses that are smoothed by daily field-scale models.

The model represents connected water and substance pathways through the agricultural landscape. Depending on the catchment setup, these can include:

- fast surface runoff;
- soil-matrix flow;
- preferential flow;
- tile-drain or other drainage export; and
- routing to streams and sampling locations.

The published headwater-catchment application extended a distributed hydrological model with pesticide and transformation-product fate and behaviour. It found that parent compounds and transformation products can have different export pathways: more mobile transformation products had larger subsurface contributions, while preferential and matrix-flow contributions changed over the modelling period [5]. This is a key conceptual difference from a runoff-only source term.

### Substance representation

The review describes a formulation capable of simulating up to three substances, of which two can be transformation products, with independently specified half-lives for the mixing layer and three soil layers [4]. The model therefore links hydrological residence times and flow paths to reactive chemical mass rather than routing a fixed concentration. Its transformation scheme is still simplified relative to the full range of environmental reactions, and application processes such as spray drift may remain outside the hydrological core.

### Best fit and limitations

ZIN-AgriTra is a good fit when the question is catchment export of pesticide parent compounds and transformation products, including the relative importance of surface, matrix, preferential and drainage pathways. It is more demanding than PRZM or a stand-alone event runoff model because it needs spatial catchment data, pathway parameterisation, substance properties and calibration or evaluation data. Its higher process detail does not remove uncertainty: the published review identifies preferential flow, transformation concepts and application conditions as important sources of error across this model class [4].

## 4. Interpretation for xOffFieldSoilRisk

The existing xOffFieldSoilRisk architecture sits between PRZM and the catchment models:

- `RunOffPrzm` retains PRZM's field-scale, layered-soil pesticide source calculation.
- A DEM-derived flow grid supplies lateral connectivity outside the PRZM soil calculation.
- Filtering between cells can be applied after source generation.

This is a pragmatic architecture for landscape risk screening and scenario comparison. It should not be interpreted as making the PRZM component hydrologically identical to openLISEM or ZIN-AgriTra. The models differ in what they calculate natively:

| Requirement | Most natural approach |
| --- | --- |
| Regulatory field-edge pesticide runoff and erosion | PRZM / FOCUS PRZM_SW |
| Daily-to-seasonal vertical fate in a layered soil profile | PRZM |
| Storm hydrograph and spatial runoff concentration | openLISEM |
| Spatial erosion and sediment source areas | openLISEM |
| Catchment pesticide and TP export by multiple pathways | ZIN-AgriTra |
| A practical landscape component using existing PRZM parameterisation | PRZM source + explicit routing/filtering, as in xOffFieldSoilRisk |

A model comparison should therefore keep the following outputs separate: field-edge runoff volume, routed discharge, sediment load, dissolved pesticide load, sediment-bound pesticide load, and catchment outlet concentration. Agreement in one of these quantities does not imply that the underlying runoff mechanisms are equivalent.

## Conclusions

1. **PRZM is profile-first and field-source oriented.** Its runoff and erosion routines are closely tied to pesticide fate in a layered soil profile. Spatial routing is a separate concern in the xOffFieldSoilRisk integration.
2. **openLISEM is event-first and landscape-process oriented.** It resolves where rainfall excess forms and how water and sediment move across a raster catchment during a storm.
3. **ZIN-AgriTra is catchment-reactive-transport oriented.** It resolves hydrological pathways and substance mass balances together at a temporal resolution suited to fast catchment processes.
4. The most important comparison axis is not simply "physical versus conceptual." It is the combination of **spatial scale, temporal resolution, native routing, erosion treatment and chemical-fate scope**.
5. For xOffFieldSoilRisk, PRZM remains the controlling field source calculation. openLISEM or ZIN-AgriTra would be alternative modelling approaches for a different modelling objective, not drop-in replacements without changes to inputs, calibration, outputs and interpretation.

## References

1. European Commission Joint Research Centre, European Soil Data Centre. **PRZM_SW: Short model description and FOCUS surface-water implementation**. https://esdac.jrc.ec.europa.eu/projects/przmsw (accessed 2026-09-10).
2. de Roo, A. P. J., Wesseling, C. G., and Ritsema, C. J. (1996). **LISEM: A single-event physically based hydrological and soil erosion model for drainage basins. I: Theory, input and output**. *Hydrological Processes*, 10(8), 1107-1117. https://doi.org/10.1002/(SICI)1099-1085(199608)10:8<1107::AID-HYP415>3.0.CO;2-4.
3. Takken, I., Beuselinck, L., Nachtergaele, J., Govers, G., Poesen, J., and Degraer, G. (1999). **Spatial evaluation of a physically-based distributed erosion model (LISEM)**. *Catena*, 37(3-4), 431-447. https://doi.org/10.1016/S0341-8162(99)00031-4.
4. Gassmann, M. (2021). **Modelling the fate of pesticide transformation products from plot to catchment scale - State of knowledge and future challenges**. *Frontiers in Environmental Science*, 9, 717738. https://doi.org/10.3389/fenvs.2021.717738.
5. Gassmann, M., Stamm, C., Olsson, O., Lange, J., Kümmerer, K., and Weiler, M. (2013). **Model-based estimation of pesticides and transformation products and their export pathways in a headwater catchment**. *Hydrology and Earth System Sciences*, 17, 5213-5228. https://doi.org/10.5194/hess-17-5213-2013.
6. Young, D. F. and Fry, M. M. (2014). **PRZM5: A model for predicting pesticide in runoff, erosion, and leachate: User manual**. U.S. Environmental Protection Agency. The FOCUS PRZM_SW page also lists this PRZM lineage and its earlier documentation.
7. de Roo, A. P. J., Jetten, V. G., Wesseling, C. G., and Ritsema, C. J. (1998). **LISEM: A physically-based hydrologic and soil erosion catchment model**. In *Modelling Soil Erosion, Sediment Transport and Closely Related Hydrological Processes*, IAHS Publication. https://doi.org/10.1007/978-3-642-58913-3_32.
