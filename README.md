## Documentation
https://xlandscape.github.io/xOffFieldSoilRisk/

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
#### From zipfile
If someone provides you with a zipped version of xOffFieldSoilRisk, simply extract the archive into a folder on your 
hard drive. Simulation data and temporary files will be written to a sub-folder of this folder, so a fast hard-drive 
with lots of available space is preferable.

#### From Bayer GitLab using Sourcetree
The newest stable version of xOffFieldSoilRisk can always be found at the Bayer Gitlab. You can access the git 
repository with any git client, including command-line and graphical clients. The following is a step-by-step guide 
copy of xOffFieldSoilRisk using the graphical git client *Sourcetree*.

1. You need access to the Bayer GitLab xOffFieldSoilRisk repository. Please contact 
   [Thorsten Schad](mailto:thorsten.schad@bayer.com) for a respective account.
2. Login to the Bayer GitLab and navigate to *User Settings* > *Access Token*
   ([direct link](https://gitlab.bayer.com/-/profile/personal_access_tokens)).
3. Choose an arbitrary *Token name* and select *api* as the token scope. Click on *Create personal access token*.
4. The new token is displayed on top of the page under *Your new personal access token*. Take a note of this token as it
   will not be accessible again. If you ever lose your api token but want to connect from another client, you have to
   create a new one.
5. Download *Sourcetree* from the *Atlassian* website: 
   [https://www.sourcetreeapp.com/](https://www.sourcetreeapp.com/).
6. During setup of *Sourcetree*, you can skip the registration of a *Bitbucket* account. It is also not necessary to
   install the *Mercurial* tools. Under *Preferences*, provide your username and email address as they should appear in
   your commits to the git repository. They are not necessarily the same as your GitLab login credentials. When asked
   to load an SSH key, select "No" as for the GitLab repository, access will not use SSH.
7. After setting up, take the time to tweak some *Sourcetree* options under *Tools* > *Options*. Important options that
   are suggested to be changed are enabling of *Perform submodule actions recursively* in the *Git* tab and to make sure
   that an embedded git is used by pressing the *Embedded* button in the *Git* tab and confirming the download. The
   submodule recursive actions will make it much easier to update the repository later on and the embedded git will
   make sure that you use a current git version that supports all necessary features.
8. After closing the *Options* dialog, switch to the *Remote* tab and click on *Add an account*. Choose *GitLab EE* as
   *Hosting service* and *https://gitlab.bayer.com/* as *Host URL*. Leave the *Preferred Protocol* as *HTTPS*. Now click
   on the *Refresh Personal Access Token* button. Specify your GitLab login username as username, but **use the 
   previously generated api token** as password. Do not use your GitLab login password here. After specifying your 
   credentials, the open dialog should indicate *Authentication OK*. In this case, you can close the dialog.
9. You can now switch to the *Clone* tab to finally clone the repository. Under *Source Path / URL*, type in the
   xOffFieldSoilRisk endpoint which is *https://github.com/xlandscape/xOffFieldSoilRisk*. 
   After the input field looses focus, you might be asked to select a credential helper. You can select any option 
   here. Maybe you have to provide your username and api token as in the previous step, again. *Sourcetree* should now
   indicate that *This is a Git repository*.
10. Under *Destination Path*, specify the folder on your computer where the repository should be cloned into. The *Name*
    field should be automatically filled out and equal the name of the folder where the repository is cloned into. The
    *Local Folder* is fixed to *[Root]*. Under *Advanced Options* make sure that the *Checkout branch* is set to
    *master* to assure that you clone the latest stable version. **Make sure that the option *Recurse submodules* is
    enabled** to download the entire Landscape Model and not only part of its. Confirm everything with pressing the
    *Clone* button.
11. After cloning is finished, you can find your copy of the Landscape Model variant in the specified folder and can 
    start using it.
            


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
