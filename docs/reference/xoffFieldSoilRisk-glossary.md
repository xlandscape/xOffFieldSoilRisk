# Glossary

This section provides a glossary on xOffFieldSoilRisk model and scenario specific topics.  
A general glossary on xLandscape basics is provided in the [xLandscape](xLandscape/xLandscape-glossary.md#Glossary) section. 

## Buffer

A distance ([m]) that is kept (has to be kept) to a certain entity during an agricultural activity. Buffers are typically used to implement risk mitigation means, eg, to reduce spray-drift depositions into habitats of non-target-organisms. To protect aquatic organisms no-spray buffers are defined as distance to water bodies (eg, a PPP is allowed to be spray no closer than 10 m distance to streams). To protect terrestric organisms, often in-field or in-crop buffers are defined (eg, spraying has to keep a 5 m distance from the cropped/field boundery).

## Configuration
As for each [xLandscape](../xLandscape/xLandscape-intro.md#xlandscape) component and landscape model, user simulation inputs and control settings are separated in two different levels, a *Configuration* and a [*Parameterisation*](#parameterisation) level:  
- the **configuration** of a component (like xCP) allows to change fundamental model behaviour (eg, minimum sprayed area, in-crop buffer calculation).
- the [*Parameterisation*](#parameterisation) level of a component represent the actual user interface, ie, the model parameters exposed to the user. Inputs made by the user in the parameterisation file define a landscape modelling [Experiment](#experiment).  

The decision on which model component parameters should be exposed as user interface in the [*Parameterisation*](#parameterisation) level depends on the purpose of the model and the user group. The assignment of model component parameters to either the configuration or the [Parameterisation](#parameterisation) level can be changed with minimum effort ([xLandscape-Parameters](../xLandscape/xLandscape-parameterisation.md#assign-parameters-to-parameter-level)).  

Both, *configuration* and [*Parameterisation*](#parameterisation) refer to direct user inputs (user interaction) and are separated from more extense data inputs like land use data, weather data or pesticide phys-chem properties. Typically, in the user inputs links to such databases to be used in a landscape modelling [Experiment](#experiment) are defined wheras the actual data are taken from these databases.  

## Experiment
The term *Experiment* has been introduced to [xLandscape](../xLandscape/xLandscape-intro.md#xlandscape) model simulations as an analogue to experimental setups.  
An *Experiment* has a single model parameterisation (including xCP parameterisation) and consists of a number of *Monte Carlo* runs. The latter are independent from each other, ie. in each *Monte Carlo Run* the defined variabilities (Probability Density Functions, PDFs) are independently sampled.  
As compared to experimental setups, the 'control' setup is basically assumed to be the no-PPP use, ie non-exposure situation. However, alternative baseline scenarios can be defined as separate *Experiments* (eg, representing alternative/'organic'/'biological' pest control measures) and their outcome considered in the (comparative) analysis.  

## In-/Off-field, In-/Off-crop
In regulatory risk assessment in Europe, protection goals and risk assessment approaches are different for in-field and off-field areas. Basically, the **in-field area** is given by the property of the farmer and its bounderies (as you might find on cadastral maps). In cultivated landscapes, **off-field areas** are typically represented by parts of the field margin (eg, between roads and fields), riparian zones, wood margins. When you see vegetation strips between two arable fields, these are caused due to the working space of the agricultural machinery but  do not represent off-field areas as the two arable properties directly border to each other.  
**In-crop** simply represents the currently cropped area. Likewise, **off-crop** represents all (currently) non-cropped area.  
**In-field off-crop** areas are such within the field (property) of a farmer, yet, are currently not cropped. Such areas occur as (in-field) field margins, in some cases just left as a fallow strip, in others of sown flowering strip (to support wildlife and forage for insects). Such in-field margins are also intended to reduce potential run-off of pesticide residues from the field into off-field areas and streams.  

<img src="../img/3a%20Off-Field%20Soil%20Risk%20Figure_1.png" width="800" height="250">  

*Illustration of In-/Off-Field vs. In-/Off-Crop definition. The scheme on the left shows the definition as occurring in official documents. The image on the right shows a typical field situation (Hessian, Germany)*  
<br>
<img src="../img/in-crop%20off-crop%20illustration.png" width="350" height="200">  
*Illustration of In-/Off-Field vs. In-/Off-Crop using a schematic scenario. The in-field (left part) is cropped (brown color), yet, has an in-field off-crop margin (light green). The off-field area (right part) is divided into two zones, representing two different land cover types in the expample (wood margin, wood core)*

## In-crop Buffer
As a *Risk Mitigation* option, typically to reduce spray-drift depositions into off-field areas, in-crop buffer represent a zone (distance [m]) from the cropped area boundery which must not be sprayed with the PPP of such a label instruction.  

<img src="../img/Illustration of in-crop buffer.png" width="350" height="200">
*Illustration of In-/Off-Field vs. In-/Off-Crop using a schematic scenario. The in-field (left part) is cropped (brown color), yet, has an in-field off-crop margin (light green) as well as an in-crop buffer (solid box). The cropped area within the in-crop buffer is allowed to be sprayed (solid box), whereas the cropped area outside is not. The off-field area (right part) is divided into two zones, representing two different land cover types in the expample (wood margin, wood core)*

## Monte Carlo Run
Monte Carlo simulations rely on random sampling drawn from probability distributions to obtain numerical results. They can be used to model phenomena with significant variability (and uncertainty) in inputs, such as calculating the possible exposure profile of pesticides in streams in a catchment and the variability of possible effects to aquatic organisms. A nested (2D) Monte Carlo approach allows to also assess consequences of uncertainties to model outcome.  

The [xLandscape](../xLandscape/xLandscape-intro.md#xlandscape) model is a numeric approach that works spatially and temporally explicit. Some phenomenons can be considered deterministic, eg, land use at a certain location and time (as derived from satellite data) or when using historic weather data. However, real-world phenomenons are sometimes not exactly known in space and time, eg, farming activities, catchment conditions or local wind conditions. In such cases, variability distributions can be derived (from data and/or expert judgement), modelled using Monte Carlo, in order to assess the range of possible consequences for the environment and for species. This is done in an xLandscape model by defining an [*Experiment*](#experiment) which consists of a number of Monte Carlo runs to sample the range of possible conditions of the defined real-world landscape system.  

## Parameterisation
As for each [xLandscape](../xLandscape/xLandscape-intro.md#xlandscape) component and landscape model, user simulation inputs and control settings are separated in two different levels, a *Configuration* and a [*Parameterisation*](#parameterisation) level:  
- the [*Configuration*](#configuration) of a component (like xCP) allows to change fundamental model behaviour (eg, minimum sprayed area, in-crop buffer calculation).
- the **parameterisation** level of a component represent the actual user interface, ie, the model parameters exposed to the user. Inputs made by the user in the parameterisation file define a landscape modelling [Experiment](#experiment).  

The decision on which model component parameters should be exposed as user interface in the *parameterisation* level depends on the purpose of the model and the user group. The assignment of model component parameters to either the [*Configuration*](#configuration) or the *parameterisation* level can be changed with minimum effort ([xLandscape-Parameters](../xLandscape/xLandscape-parameterisation.md#assign-parameters-to-parameter-level)).  

Both, [*Configuration*](#configuration) and *parameterisation* refer to direct user inputs (user interaction) and are separated from more extense data inputs like land use data, weather data or pesticide phys-chem properties. Typically, in the user inputs links to such databases to be used in a landscape modelling [Experiment](#experiment) are defined wheras the actual data are taken from these databases.

## Risk Mitigation / Risk Mitigation Measures
Regarding the use of PPPs and from an operational point of view, here *Risk Mitigation* basically refers to reducing exposure caused by PPP application. For more information have a look into the outcome of the [MAgPie Workshop](https://www.openagrar.de/receive/openagrar_mods_00027102 "Mitigating risks of Plant Protection Products in the environment").
  
In xCP, currently the following *Risk Mitigation* measures are implemented:
- no-spray buffer (typically defined in relation to water bodies)
- in-crop buffer (a distance a farmer has to keep from the cropped boundery when spraying)
- use of drift-reducing nozzles (sprayer technology to reduce drift)

## Scenario
In the context of risk assessment for pesticides, a *Scenario* refers to a set of conditions and assumptions used to model and predict the environmental fate and effects of pesticides. At lower tiers of the risk assessment procedure, *Scenarios* are designed to represent realistic worst-case situations to ensure that the risk assessments are protective of human health and the environment. When getting more realistic, at higher-tier risk assessment levels, *Scenarios* are intended to represent real-world conditions.  
Some key elements that define a scenario in this context:

1. **Abiotic Factors**: These include non-living environmental factors such as soil type, climate/weather, landscape topology, and water bodies. For example, a scenario might consider how a pesticide behaves in sandy soil under high rainfall conditions. 
2. **Biotic Factors**: These involve living organisms that might be affected by the pesticide, including plants, animals, and microorganisms. The scenario might assess the impact on a specific species or a group of species. 
3. **Agronomic Practices**: This includes farming practices such as land use, crop rotation, land management, irrigation, and pesticide application methods. Different practices can influence how pesticides are distributed and degraded in the environment. 
4. **Exposure Pathways**: Scenarios consider how habitats and species might be exposed to pesticides, such as through forage, water, or contact. 
5. **Temporal Aspects**: The timing of pesticide application, its persistence in the environment and temporal relationship to the occurrence of species are crucial. Scenarios might model short-term (acute) and long-term (chronic) exposures.  

By combining these factors, scenarios build a crucial basis to create a comprehensive picture of the potential risks associated with pesticide use.

In xCP, the term *PPP use scenario* is sometimes used to address a certain *Parameterisation* of xCP (as part of a landscape model). 
Likewise, modellers often talk about a *landscape scenario* meaning the certain geographic region for which eg, land use/cover, soil, weather and habitat conditions have been defined as basis for landscape-scale pesticide exposure and effect modelling. 

## Simulation
The term *Simulation* is not precisely defined and is used somehow colloquial with different meanings. This is not a problem as the actual meaning typically gets clear in its use context:  
- a model simulation can just mean to parameterise and run a model in general
- an xLandscape model simulation can mean to conduct an *Experiment*, ie, here the terms are used synonymously
- a *Simulation* can also address an individual *Monte Carlo* run of an xLandscape model [*Experiment*](#experiment). 

