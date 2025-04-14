# Welcome to xOffFieldSoilRisk

Welcome to the xOffFieldSoilRisk (xSR) documentation. This documentation provides an **introduction** and will walk new users through **how to get started** with the xOffFieldSoilRisk landscape model, including explanations for **sample scenarios** and their use.

## Publication (Open Access)

Please find an introduction to the topic here: [A spatiotemporally explicit modeling approach for more realistic exposure and risk assessment of off-field soil organisms](https://onlinelibrary.wiley.com/doi/10.1002/ieam.4798).  

## Background

The authorization process of plant protection products (PPPs) includes comprehensive regulatory risk assessment (RA) for nontarget species, including soil organisms. The European Food Safety Authority (EFSA) has released a scientific opinion on [“addressing the state of the science on RA of PPPs for in-soil organisms” (EFSA PPR Panel, 2017)](https://www.efsa.europa.eu/en/efsajournal/pub/4690), in which spray-drift depositions and runoff are identified as the most relevant potential exposure routes of off-field soil organisms, whereby the term “off-field” refers to areas outside the agricultural field boundaries, that is, essentially to (semi-) natural areas present in cultivated landscapes. The EFSA PPR Panel (2017) outlined a first approach to estimate off-field soil exposure. The conservative character of the approach and the necessity for model and scenario development are indicated in EFSA PPR Panel (2017): “In the absence of appropriate off-field exposure scenarios… Since such models are not yet available for regulatory purposes at the European level, the simplifying assumption is made that the individual exposure routes can be assessed separately. Results of the different entry routes should then be summed, which is a conservative assumption because it neglects the different dynamic behavior of the processes.”  
With this background, the aims for the present work are to develop a model approach to appropriately combine off-field soil exposure due to runoff and drift and to develop scenarios based on real-world conditions.  
  
## Intro

xOffFieldSoilRisk is a landscape model to simulate 
The entire process of modelling beeforage is of [modular design](#modular-design).  

## Concepts

### Framework Characteristics

xSR can be seen as a ready-to-use model, eg, to generate scenarios for the [BEEHAVE model](https://beehave-model.net/), for regions of pre-prepared geoinformation (see [Scenarios](#scenarios)).  
However, in order to enable its use for a range of purposes of modelling pollinator forage ([Background](#background)), for a range of foraging species and basically for any geographic region and scale, xSR was build to be open for any data inputs and sub-models. Eg, in case a bee forage modeller has data and models to simulate the occurrence of honeydew producers, this can be included in the xSR landscape model as a new component. So, besides its [modular](#modular-design) characteristic, you can also look at xSR from a **framework perspective**.

### Modular Design

Modelling the occurrence of bee forage in landscapes requires a **range of disciplines, information types and sub-models**. Nectar and pollen are produced by **flowering vegetation**, so vegetation type, plant species, their phenology and their specific nectar and pollen production (quantity, quality) is key data and information. Vegetation phenology depends on **environmental conditions**. Besides vegetation, bee forage does also occur as **honeydew**, which is produced by different insects (eg, Aphids probably the most well-known honeydew producers and often excrete large quantities, but also scale insects (Coccoidea), leafhoppers (Cicadellidae and others), Adelgids (Adelgidae), plant bugs (Heteroptera), whiteflies (Aleyrodidae), or mealybugs (Pseudococcidae)).  
Accordingly, for modelling pollinator forage at landscape scales, **fundamental building blocks (elements, modules)** were identified and implemented as separate components in xSR. An illustration is shown in the figure below.  

<img src="img/BeeForage modelling process with Beehave scenario.png" alt="xOffFieldSoilRisk modular design" width="1000"/>  

Distinct steps in bee forage modelling which define xSR components (building blocks/elements/modules).

Key modules are:

- **Land use/land cover** (LULC) information: an assembly of spatial data that represents essential LULC types that provide bee forage. The geodata layer is composed of any data that the modeller seems relevant and that can be acquired or generated at reasonable efforts, targeting the goals of the bee forage modelling work (study).
- **Vegetation and its phenology** (incl. honeydew producers): the module to translate LULC types to vegetation types and their phenology.
- **Bee forage modelling**: the module to generate beeforage(space, time, type).
- Parser: technical preparation of raw outcome as needed by the scenario clients (eg, the [BEEHAVE model](https://beehave-model.net/)).

A layered view to bee forage modelling adds to the illustration of the successive steps to deliver the ultimate bee forage information.  

<img src="img/BeeFOrage-Vegetation-Data layering.png" alt="xOffFieldSoilRisk modular design" width="700"/>  

Distinct data and information layers to derive bee forage (in space and time). (* *Sources* represent the occurrence of eg, honeydew producers)

This modularity enables to basically use any type of data, information and sub-models which are approriate to a specific bee (pollinator) forage modelling purpose. Example data inputs and parameterisations are introduced in the [Scenario](#scenarios) section.

#### xOffFieldSoilRisk Landscape Model

The modular landscape model to for spatiotemporally explicit simulation of bee (pollinator) forage, xOffFieldSoilRisk (xSR), was built using the **landscape modelling framework** [xLandscape](xLandscape/xLandscape-intro.md#xlandscape). The framework allows to compose individual modules, called *Components* to a landscape models, that operates spatiotemporally explicit.  
The components represent and encapsulate distinct functionality. Any component can be replaced by more or less complex ones.  
Adding components adds functionality. For xSR, a version exists that comprises the use of pesticides (PPPs) and the environmental exposure (figure below). Again, each exposure route and process is represented by a specific component (which can be replaced to manage model complexity).  

<img src="img/xSR.png" alt="xOffFieldSoilRisk modular design" width="700"/>  

Composition of the xOffFieldSoilRisk landscape model (v0.9). Its components are introduced in subsections below.

<img src="img/xSR & exposure and effects.png" alt="xOffFieldSoilRisk modular design" width="700"/>  

Composition of the xOffFieldSoilRisk landscape model (v0.9) including components to model PPP use and environmental exposure.

#### BeeForage Component

The BeeForage component models the occurrence of nectar and pollen in space and time. The outcome is stored in a multidimensional data store.  
The current version (v0.9) uses spatial data on vegetation types (units) and their phenology as base input, together with information on nectar and pollen production by these vegetation types. The core functionality of the BeeForage component is to match (model) nectar and pollen production for each of these vegetation types. In the current version, this is done by a simple lookup tables (with a honey bee focus):  

1. Assigning nectar and pollen production intensity classes (0-4) to vegetation type (by time).  
1. Assigning nectar and pollen production quantities to intensity classes.  

<img src="img/Vegetation-Phenology illustration.png" alt="xOffFieldSoilRisk modular design" width="700"/>  

Lookup table to assign nectar and pollen production intensity classes (0-4) to vegetation type (by time).

<img src="img/Nectar-Pollen quantification.png" alt="xOffFieldSoilRisk modular design" width="1000"/>  

Lookup table to assign nectar and pollen production quantities to intensity classes.

Both lookup tables are based on literature and expert judgement (xxx).  

This initial realisation of the BeeForage-Component can be enhanced and replaced by more sophisticated bee forage modelling, eg, using data-driven/AI or mechanistic models, together with corresponding geoinformation on the underlying vegetation.  
The BeeForage-Component can also be extended to model the occurrence of honeydew, again, if corresponding models, knowledge and data are available (and fit to each other).  

#### Vegetation

In our representation of vegetation (and its phenology), instead of employing an of-the-shelf land use/cover (LULC) dataset, we compose bee forage-providing land use/land cover elements from different sources. This composition is driven by the study purpose and related requirements (eg, level of detail, precision, certainty, scales), data availability, and given ressources. Eg, 

- a LULC base layer (eg, topographic geodata) is used to identify general LULC types (eg, arable, forest, orchards, grasslands, gardens, ruderal) and more bee forage specific types if possible (eg, apple, decidious woods, arable crop types)  
- Specific bee forage providing crop types are identified from satellite imagery (eg, oil seed rape)  
- Likewise, grassland characterisation can be done using satellite imagery based approaches (eg, hayfield, natural, intense sillage)  
- Further bee forage relevant vegetation can be constructed from LULC base layers and literature (eg, riparian, wood margins)  
- High-resolution landscape elements can be added from mapping (eg, hedges, groups of bee forage relevant trees, etc.) 

The user defines PPP uses in a ***Crop Protection Calender***, including application technology, and mitigation measures for reducing exposure (risk). The approach of using a *Crop Protection Calender* is based on agricultural practice, where pest control measures for a crop are typically planned based on experiance, PPP availability and other factors. Crop protection plans are made eg, by official plant protection advisory services, farmers, or PPP producers. Besides reflecting ag practice, the approach of a CPC also addresses modelling practice in risk assessment which typically focus on a certain indication, conducted over long time periods. Beyond these established uses, alternative CPCs can be used to assess the environmental impact of alternative pest control options, or to design new pest control means against established ones, considered as baselines.  

#### LULC

Land use/cover data provides typically builds the spatial base information on 

Vegetation mapping and modelling. [European Vegetation Archive (EVA)](https://euroveg.org/eva-database/)

#### Environmental Data

### Tiered Approach

xxx Depending on the purpose of bee (pollinator) forage modelling,  

1. off-the-shelf data: covering large geographic regions
1. best-available data, including manual processing
1. contemporary data generation: high-resolution drone mapping
1. field study: best possible landscape mapping, bee forage quantification and modelling

### xSR Simulation xxx: move to 'get started'

On each time step (eg, day) and field in a simulation, xSR checks if there are products to apply. If so, exact application details are determined based on model parameterisation (eg, deterministic or by sampling from  from distributions given by the user) and executed.  


## xOffFieldSoilRisk Landscape Model

## Scenarios

## Application

## Acknowledgements
The need and the development of the xSR landscape model was initiated by Thorsten Schad (tschadwork@gmail.com). It's realisation was only possibly due to the contribution of colleagues listed below and the sponsoring by Bayer AG.  

<img src="img/Contributions.png" alt="Contributors and Roles" width="800"/> xxx

## References
EFSA Guidance  
BioDT

[EFSA Bee Guidance](https://efsa.onlinelibrary.wiley.com/doi/10.2903/j.efsa.2021.6607)  
Pritsch
Westrich Die Wildbienen Deutschlands
