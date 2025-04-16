# Welcome to xOffFieldSoilRisk
asdf jklö

Welcome to the xOffFieldSoilRisk (xOSR) documentation. This documentation provides an **introduction** and will walk new users through **how to get started** with the xOffFieldSoilRisk landscape model, including explanations for **sample scenarios** and their use.

## Publication (Open Access)

An introduction to the topic is given in an open access publication in IEAM: [A spatiotemporally explicit modeling approach for more realistic exposure and risk assessment of off-field soil organisms](https://onlinelibrary.wiley.com/doi/10.1002/ieam.4798).  
The xOffFieldSoilRisk approach has been presented at different scientific conferences: (xxx include pdfs of the presentations.) 

## Background (v0.1)

The authorization process of plant protection products (PPPs) includes comprehensive regulatory risk assessment (RA) for nontarget species, including soil organisms. The European Food Safety Authority (EFSA) has released a scientific opinion on [“addressing the state of the science on RA of PPPs for in-soil organisms” (EFSA PPR Panel, 2017)](https://www.efsa.europa.eu/en/efsajournal/pub/4690), in which spray-drift depositions and runoff are identified as the most relevant potential exposure routes of off-field soil organisms, whereby the term “off-field” refers to areas outside the agricultural field boundaries, that is, essentially to (semi-) natural areas present in cultivated landscapes.  

<img src="img/off-field-soil definition.png" alt="Illustration of Off-Field-Soil definition" width="700"/>  

Illustration of Off-Field-Soil definition  

The EFSA PPR Panel (2017) outlined a first approach to estimate off-field soil exposure. The conservative character of the approach and the necessity for model and scenario development are indicated in EFSA PPR Panel (2017): “In the absence of appropriate off-field exposure scenarios… Since such models are not yet available for regulatory purposes at the European level, the simplifying assumption is made that the individual exposure routes can be assessed separately. Results of the different entry routes should then be summed, which is a conservative assumption because it neglects the different dynamic behavior of the processes.”  

## Introduction (v0.1)

With the background above, the aims for the present work are to **develop a model approach to appropriately combine off-field soil exposure due to runoff and drift** and to develop example **scenarios** based on real-world conditions.  
xOffFieldSoilRisk is built on the basis of the [**xLandscape**](xLandscape/xLandscape-intro.md#xlandscape) **framework**. xLandscape provides a modular approach to develop landscape models which operate spatiotemporally explicit. xLandscape is open source.  
In its initial version, xOffFieldSoil has been composed using exposure models which are established in the regulatory scientific exposure assessment of pesticides in Europe (eg, [FOCUSsw](https://esdac.jrc.ec.europa.eu/projects/focus-dg-sante)). However, these models are not open sources and come with limitations for their spatiotemporally explicit operation with a large number of local conditions as typical at landscape-level. Thus, future versions of xOffFieldSoilRisk are intended to consider exposure modules adapted for landscape-level application.  

## Concepts

### Model Outcome for Risk Assessments

Basically, **xOffFieldSoilRisk model outcome is intended to be directly used in off-field-soil RAs**. Correspondingly, raw spatiotemporally explicit model outcome needs to be 

1. aggregated to ready-to-use exposure endpoints for established RA tiers, or
1. directly fed into effect models (eg, TKTD, Folsomia, Earthworms, xxx).

In its initial use, xOSR is intended (1)  
stepwise aggregated  , understanding the oucome is important  
Python code, implemented as Jupyter notebooks. 
address [Specific Protection Goals](https://www.efsa.europa.eu/en/efsajournal/pub/1821).    

aggregation levels

### Model Use for Research&Development

Even in the context regulatory risk assessment and risk management of pesticides, a range of research questions and implementation needs are open. context xxx more realism, holistic view to risk, risk mitigation and management
Explicit landscape modelling using real-world data can significantly contribute to required developments.  

- Development of consistent lower tier approaches from a reasonably realistic 'Reference Scenario' level. 



## Implementation

### xOffFieldSoilRisk Model

 FIGURE 2 xOffFieldSoil model scheme. The model is composed of components (boxes in the central panel, e.g., xDrift; Bub et al., 2020). Components provide
 major model functionality (e.g., spray‐drift or runoff exposure calculation) and are built by wrapping existing models (e.g., PRZM) or by developing new ones
 (e.g., “RunoffFilter1”). The implementation of xOffFieldSoil is based on a generic modular landscape modeling framework (Schad, 2013). The light gray boxes
 represent xOffFieldSoil components that were not used in the case study, although they do exist or are under development (full scheme in Supporting
 Information: Figure S1, https://github.com/xlandscape/xOffFieldSoilRisk). Preparation and analysis panels contain tools, for example, for data preparation and risk analysis of model outcome (Supporting Information: Table S1) and operate closely with the framework, yet are not part of the core xOffFieldSoil model. PRZM, Pesticide Root Zone Model

### Framework Characteristics

xOSR can be seen as a ready-to-use model to calculated exposure (and effects) of off-field-soil organisms for regions of pre-prepared geoinformation (see [Scenarios](#scenarios)).  
However, in order to enable its use for a range of purposes of modelling xxx[modular](#modular-design) characteristic, you can also look at xOSR from a **framework perspective**.

### Modular Design

Modelling the exposure (and effects) of off-field-soil organisms in landscapes requires a **range of disciplines, information types and sub-models**. xxx  
Accordingly, **fundamental building blocks (elements, modules)** were identified and implemented as separate components in xOSR. An illustration is shown in the figure below.  


Key modules are:

- **Land use/land cover** (LULC) information: 

This modularity enables to basically use any type of data, information and sub-models which are approriate to a specific bee (pollinator) forage modelling purpose. Example data inputs and parameterisations are introduced in the [Scenario](#scenarios) section.


### xOffFieldSoilRisk Landscape Model

The modular landscape model to for spatiotemporally explicit simulation of bee (pollinator) forage, xOffFieldSoilRisk (xOSR), was built using the **landscape modelling framework** [xLandscape](xLandscape/xLandscape-intro.md#xlandscape). The framework allows to compose individual modules, called *Components* to a landscape models, that operates spatiotemporally explicit.  
The components represent and encapsulate distinct functionality. Any component can be replaced by more or less complex ones.  
Adding components adds functionality. For xOSR, a version exists that comprises the use of pesticides (PPPs) and the environmental exposure (figure below). Again, each exposure route and process is represented by a specific component (which can be replaced to manage model complexity).  

<img src="img/xOffFieldSoilRisk model.png" alt="xOffFieldSoilRisk" width="700"/>  

Composition of the xOffFieldSoilRisk landscape model (v0.9) including components to model PPP use and environmental exposure.

#### Runoff Component

#### Environmental Data

### Tiered Approach

xxx Depending on the purpose of bee (pollinator) forage modelling,  

1. off-the-shelf data: covering large geographic regions
1. best-available data, including manual processing
1. contemporary data generation: high-resolution drone mapping
1. field study: best possible landscape mapping, bee forage quantification and modelling

## Scenarios

## Application

## Acknowledgements (v0.1)
The development of the xOSR landscape model was initiated by Thorsten Schad (tschadwork@gmail.com). It's realisation was only possibly due to the contribution of colleagues listed below and the sponsoring by Bayer AG.  

| Role / Activity   | Person      |
|-------|----------|
| Idea and Initiative | Thorsten Schad (Bayer)  |
| Demand Evaluation   | Gregor Ernst, Thomas Preuss, Thorsten Schad (all Bayer)  | 
| Goals and Requirements   | Thorsten Schad, Sascha Bub (RPTU)  | 
| Design   | Thorsten Schad, Sascha Bub  | 
| Implementation   | xOffFieldSoilRisk landscape model: Sascha Bub, Thorsten Schad. Runoff-Component: Joachim Kleinmann, Magnus Wang, Sascha Bub, Thorsten Schad. Analysis: Sascha Bub, Claire Holmes (AAS), Thorsten Schad  | 
| Testing   | Thorsten Schad, Theo Schad (Bayer Intern), Sascha Bub, Chris Holmes (AAS)  | 
| Scenarios   | Thorsten Schad, Sascha Bub  | 
| Publication   | see 'Author Contribution' in  [IEAM 4798](https://onlinelibrary.wiley.com/doi/10.1002/ieam.4798) and section [Publication](#publication-open-access) above| 

## References

[(EFSA PPR Panel, 2017)](https://www.efsa.europa.eu/en/efsajournal/pub/4690). 2017. Scientific Opinion addressing the state of the science on risk assessment of plant protection products for in‐soil organisms. EFSA Journal. Wiley Online Library. 

Valery E Forbes, Annika Agatz, Roman Ashauer, Kevin R Butt, Yvan Capowiez, Sabine Duquesne, Gregor Ernst, Andreas Focks, Andre Gergs, Mark E Hodson, Martin Holmstrup, Alice SA Johnston, Mattia Meli, Dirk Nickisch, Silvia Pieper, Kim J Rakel, Melissa Reed, Joerg Roembke, Ralf B Schäfer, Pernille Thorbek, David J Spurgeon, Erik Van den Berg, Cornelis AM Van Gestel, Mathilde I Zorn, Vanessa Roeben, **Mechanistic Effect Modeling of Earthworms in the Context of Pesticide Risk Assessment: Synthesis of the FORESEE Workshop**, Integrated Environmental Assessment and Management, Volume 17, Issue 2, 1 March 2021, Pages 352–363, https://doi.org/10.1002/ieam.4338


## next Section: Get Started

[Get Started](getstarted/getstarted.md#intro)
