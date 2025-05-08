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

## xOffFieldSoilRisk Documentation
https://xlandscape.github.io/xOffFieldSoilRisk/

## About the project
XOffFieldSoil is a modular model that simulates processes at a landscape-scale and allows assessing potential effects of
pesticide applications on off-field soil organisms. Its main features are:
* A modular structure that couples existing expert models like XDrift (spray-drift model based on Rautmann drift 
  values) and RunOffPrzm (PRZM-based implementation of spatial run-off distribution) and that allows to flexibly replace
  or add further modules. 
* A unified and consistent view on the environmental state of the simulated landscape that is shared among modules and
  available to risk-assessment. 
* Data semantics that explicitly express values and their physical units at different spatial and temporal scales plus 
  the ability of transient data transformations according to the requirements of used models.
* Computational scaling that allows to conduct Monte Carlo runs in different sizes of landscapes, ranging from small
  schematic setups to real-world landscapes. 

### Built with
XOffFieldSoil is composed of the following building blocks: 
* The Landscape Model core that provides the base functionality for managing experiments and exchanging data in a 
  landscape-scale context. See `\model\core\README` for further details.  
* The AnalysisObserver that implements default assessments of simulations, including the output of maps, plots and 
  tables. See `\model\variant\AnalysisObserver\README` for further details.
* RunOffPrzm, an PRZM-based implementation of spatial run-off distribution. See `\model\variant\RunOffPrzm\README` for 
  further details.
* XDrift, a spray-drift model based on Rautmann drift values (
  [https://doi.org/10.1016/j.softx.2020.100610](https://doi.org/10.1016/j.softx.2020.100610)). See 
  `\model\variant\XSprayDrift\README` for further details.
* An exemplary schematic landscape scenario consisting of a 100 m x 100 m habitat next to a 100 m x 100 m field. See 
  `\scenario\schematic-100x100\README` for further details.
* Two R risk analysis scripts. See `\model\variant\RiskAnalysis\README` for further details.  


## Getting Started
XOffFieldSoil is portable and is tested to run on a range of hardware.

### Prerequisites
XOffFieldSoil requires a 64-bit Windows to run.

### Installation
$(installation_notes)


## Usage
1. Open the `template.xrun` in any text editor and modify the parameters for the simulation to your needs. The 
   `template.xrun` contains in-line documentation to assist you in deciding for valid parameter values. **Please check
   especially that the parameter** `<RunOffTempDir>` **points to an existing directory**.
2. Save the modified `template.xrun` under a different name in the same directory, using a `.xrun` extension.
3. Drag and drop the saved parameterization file onto the `__start__.bat`.
4. Check the console window occasionally for successful conclusion of the simulation or for errors. Logfiles can be
   found under `\run\<name-of-your-experiment>\log`.
5. If the run was successful, you can find analysis results over the entire experiment under 
   `\run\<name-of-your-experiment>\analysis` and for individual Monte Carlo runs under 
   `\run\<name-of-your-experiment>\mcs\<MC-identifier>\analysis`.


## Roadmap
XOffFieldSoil is under continuous development. Future versions will include further and updated models. Usage of 
ontologies for semantic description of data are planned.


## Contributing
Contributions are welcome. Please contact the authors (see [Contact](#contact)).


## License
XOffFieldSoil is distributed under the CC0 License. See the according `LICENSE` files for more information. WinPRZM 
that is used by the RunOffPrzm component is an established open access model widely used in regulatory science. Its 
precise license conditions are not known, and it is provided here with consent of the PRZM model development team 
of Waterborne Environmental Inc., Marty Williams, Amy Ritter, Gerco Hoogeweg, J Mark Cheplick as well as Gerald Reinken 
(Bayer AG).


## Contact
Thorsten Schad - thorsten.schad@bayer.com
Sascha Bub - sascha.bub@xlandscape.org


## Acknowledgements
See `README`s of individual building blocks for acknowledgements of these parts. We thank the PRZM model development
team of Waterborne Environmental Inc., Marty Williams, Amy Ritter, Gerco Hoogeweg, J Mark Cheplick as well as Gerald 
Reinken (Bayer AG) for its consent to distribute WinPRZM together with XOffFieldSoil. 
