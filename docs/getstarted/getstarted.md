## Introduction

As described in the [Introduction](../index.md#welcome-to-xofffieldsoilrisk-xsr), the initiation of the xSR development was due to new requirements in the off-field-soil RA. Consequently, the early versions of xSR addresses this purpose with the related user group, namely soil modelling and RA experts. As indicated in the [Outlook](../index.md#outlook) section, the intention of the development of xSR is to stepwise facilitate xSR use to extended user groups.  

xxx
1. Github users
1. Model users

## Installation

### Option 1: xSR Demo Model
As every component, xBF needs to be operated in a landscape modelling environment. An example landscape model using xBF was built in the [xLandscape](xLandscape/xLandscape-intro.md) framework, called **xSRDemo**.  
A user who just want to explore xBF or only needs the functionality of xBF should clone the repository [xSRDemo](https://github.com/xlandscape/xSRDemo/tree/main). Contact Sascha Bub ([sascha.bub@rptu.de](mailto:sascha.bub@rptu.de)) or Thorsten Schad ([thorsten.schad@bayer.com](mailto:thorsten.schad@bayer.com)) for access to the repository. Cloning steps vary based on the application being used, eg. [Sourcetree](https://support.atlassian.com/bitbucket-cloud/docs/clone-a-git-repository/) or [Visual Studio Code](https://learn.microsoft.com/en-us/azure/developer/javascript/how-to/with-visual-studio-code/clone-github-repository?tabs=activity-bar).  

After cloning the repository, a user will have everything necessary to start using xSR including sample scenarios and parametrization files.  

### Option 2: add xSR to any Landscape Model
As any other component, xBF is built to be used (together with other components) in the [xLandscape](xLandscape/xLandscape-intro.md) framework in order to build a landscape model. 

1. The Landscape Model must first be set up; see the Landscape Model Core's [README](https://github.com/xlandscape/LandscapeModel-Core/blob/master/README.md) for detailed instructions.
2. Create an xSR folder in *\core\components* if it does not already exist.
3. Copy the xSR component from [GitHub](https://github.com/xlandscape/xSRDemo/tree/main) into the xSR subfolder.
4. The file *mc.xml* contains information about the components that are used in the created [xLandscape](xLandscape/xLandscape-intro.md) model. Make use of the xSR component by adding the following lines:

``` xml
<xSR module="components" class="xSR">
    <xSRFilePath scales="global">
        $(_PROJECT_DIR_)\CropProtection\$(CropProtectionScenario).xml
    </xSRFilePath>
    <ParametrizationNamespace scales="global">
        urn:xSRLandscapeScenarioParametrization
    </ParametrizationNamespace>
    <SimulationStart type="date" scales="global">
        $(SimulationStart)
    </SimulationStart>
    <SimulationEnd type="date" scales="global">
        $(SimulationEnd)
    </SimulationEnd>
    <RandomSeed type="int" scales="global">
        0
    </RandomSeed>
    <OutputApplicationType>
        $(OutputApplicationType)
    </OutputApplicationType>
    <ProductDatabase>
        $(_PROJECT_DIR_)\$(ProductDatabase)
    </ProductDatabase>
    <Fields>
        <FromOutput component="LandscapeScenario" output="FeatureIds"/>
    </Fields>
    <LandUseLandCoverTypes>
        <FromOutput component="LandscapeScenario" output="FeatureTypeIds"/>
    </LandUseLandCoverTypes>
    <FieldGeometries>
        <FromOutput component="LandscapeScenario" output="Geometries"/>
    </FieldGeometries>
</xSR>
```


## Parameterisation

The *Templates* section provides examples for xSR [**Parameterisations**](../reference/glossary.md#parameterisation). *Parameterisation* refers to the actual xSR parameterisation, ie. building PPP use scenarios.  The templates are for learning purposes and can be used as building block for your own parameterisation.   

Note: the parameterisation makes use of XML as a necessary and sufficient representation of the natural complexity of the characteristics of real-world PPP applications in cultivated landscapes. We are fully aware that XML is not the ideal **user interface**. The development of a **graphical user interface (GUI)** is planned.  

The following templates are included in the current version of xCropProtection and are located in the *CropProtection/PPMCalendars* folder:

- Apple-spray-guide
    - Apple-spray-guide.xml: A parameterization of a recommended spray sequence for apples
- Demo-calendars
    - Active-substance-demo.xml: Demonstrates the application of one active substance
    - Active-substance-demo-2.xml: Demonstrates how to set the input scale of an application
    - Active-substance-demo-3.xml: Demonstrates a tank mix with two products (set the output scale to active substance in the user parameters)

## Getting started
File structure of [xSRDemo](https://github.com/xlandscape/xSRDemo/tree/main) after cloning:

``` { .yaml .no-copy }
├── CropProtection
│   ├── PPMCalendars
|   |   ├── Apple-spray-guide
│   │   ├── Demo-calendars
│   │   ├── Rummen
│   │   ├── Templates
│   └── ...
├── analysis
│   ├── ProductTypes.csv
│   ├── requirements.txt
│   ├── xBF_map_vis.ipynb
│   ├── xBF_plot_application_rate.ipynb
│   ├── xBF_total_loading.ipynb
│   └── xBF_write_csv.ipynb
├── docs
├── model
│   ├── core
│   ├── variant
│   │   ├── CropProtection
│   │   ├── experiment.xml
│   │   ├── mc.xml
│   │   └── package.xsd
├── scenario
│   ├── Demo-scenario
│   │   ├── Documentation
│   │   │   ├── scenario-geo-image.jpg
│   │   │   └── scenario-project.qgz
│   │   ├── geo
│   │   │   ├── (multiple shp files)
│   │   │   └── package.xinfo
│   │   └── scenario.xproject
│   ├── Rummen
│   │   ├── Documentation
│   │   │   ├── scenario-geo-image.jpg
│   │   │   └── scenario-project.qgz
│   │   ├── geo
│   │   │   ├── (multiple shp files)
│   │   │   └── package.xinfo
│   │   ├── weather
│   │   │   └── weather_mars-97100.csv
│   │   └── scenario.xproject
├── .gitignore
├── .gitmodules
├── README.md
├── __start__.bat
└── template.xrun files
```

To start xSR using the sample scenario, **drag *template.xrun* onto *__start_\_.bat***. This will start an xSR run using the demo scenario. Output of the model run can be found in the newly created *\run\Rummen-demo-scenario\mcs\\[mc run ID]\store\arr.dat*.

!!! note  
    **SimIDs need to be unique**. xSR will create a folder for each run using the SimID defined in *template.xrun*. The SimID cannot be the same as a folder already contained in the run folder. If you want to run a simulation with the same SimID you need to delete this folder first.

### Schematic Scenario Simulation

### xSR Simulation

On each time step (eg, day) and field in a simulation, xSR checks if there are products to apply. If so, exact application details are determined based on model parameterisation (eg, deterministic or by sampling from  from distributions given by the user) and executed.  

## Viewing and analyzing the output

### HDFView  

[xLandscape](xLandscape/xLandscape-intro.md) makes use of multidimensional data stores. At present, [HDF](xLandscape/xLandscape-intro.md#multidimensional-data-store) is being used.  

To view the raw output of xSR, open *\run\Rummen-demo-scenario\mcs\\[mc run ID]\store\arr.dat* with a HDF5 file viewer such as [HDFView](https://portal.hdfgroup.org/downloads/index.html). Expand the xSR folder.

<img src="img/hdf5-file-structure.PNG" alt="Screenshot of output file structure" width="280"/>

Right click on an item and click "Open" to view its attributes and data.

### Jupyter Notebooks

The ***analysis* folder** contains Jupyter notebooks which can analyze and visualize the output of xSR. *requirements.txt* lists python packages necessary to run the Jupyter notebooks in this folder.

#### *xBF_write_csv.ipynb*

*xBF_write_csv.ipynb* (version 2.0) **writes the contents of *arr.dat* to a csv file**. User parameters:

`xcrop_arrdat_path` : *C:\path\to\arr.dat*

`output_path` : *C:\path\to\output_file.csv*

In the last cell, comment or uncomment any of the following lines to change the columns written to the csv.

``` py
dfs.append(pandas.DataFrame(application_dates, columns=["ApplicationDates"]))
dfs.append(pandas.DataFrame(application_dates_day_month, columns=["ApplicationDayMonth"]))
dfs.append(pandas.DataFrame(applied_features_data, columns=["FeatureID"]))
dfs.append(pandas.DataFrame([feature_id_type_dict.get(x) for x in applied_features_data], columns=["FeatureLULC"]))
dfs.append(pandas.DataFrame(application_rates_data, columns=["ApplicationRates(g/ha)"]))
dfs.append(pandas.DataFrame(decode_PPP, columns=["AppliedPPP"]))
dfs.append(pandas.DataFrame(geom_project_area_ha, columns=["AppliedArea(ha)"]))
dfs.append(pandas.DataFrame(application_rates_data * geom_project_area_ha, columns=["AppliedMass(g)"]))
dfs.append(pandas.DataFrame(drift_reduction_data, columns=["TechnologyDriftReductions"]))
```

#### *xBF_plot_application_rate.ipynb*
*xBF_plot_application_rate.ipynb* (version 2.0) **plots application rates** (as a scatter plot) of all product applications in a user-defined year. User parameters:

`xcrop_arrdat_path` : *C:\path\to\arr.dat*

`year_to_chart` : only display data for this year

#### *xBF_total_loading.ipynb*
*xBF_total_loading.ipynb* (version 2.0) **charts the total loading over time** for a specific field and for all fields. Total loading is calculated by plotting a cumulative sum of mass applied to a field (or all fields). User parameters:

`xcrop_arrdat_path` : *C:\path\to\arr.dat*

`feature_to_chart` : ID of the field to chart. If a field ID is invalid, the notebook will plot the total loading of the first field it reads.

#### *xBF_map_vis.ipynb*
*xBF_map_vis.ipynb* (version 2.0) **visualizes applications on a map** with the ability to advance through time. Please note that while this code was designed to be as general as possible, users should be aware that the map visualization will need code modification and additional input to work with other scenarios. Any new product names and types must be added to ProductTypes.csv. Also, due to limitations of the mapping package it may not be possible to generate visualizations with large datasets or over long periods of time. User parameters:

`data_store_path` : *C:\path\to\arr.dat*

`input_shp_file_path` : *C:\path\to\LULC.shp*

`output_map_html_path` : *C:path\to\output\html_map.html*

`output_map_html_2_path` : *C:\path\to\output\html_map_2.html*

`product_table` : *C:...\xSR\analysis\ProductTypes.csv*. This table defines product names and their type.

