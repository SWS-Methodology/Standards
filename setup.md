# Guide for New Developer

This is the guide for new developer to setup and configure their
environment in order to initiate development.

## File Organisation
First create a **Github** folder for all future Github related work.

Create a **sws_project** folder in the Github folder for all SWS related
projects. The root folder will also contain configuration and setup files to run
the environment.

The **sws_project** will contain folders which corresponds to a single project
and should have an associated Github repository. For each of the project, if the
project exist already, then clone the repository from Github, otherwise start a
new project. For more information, refer to the
[workflow](https://github.com/SWS-Methodology/Standards/blob/master/workflow.md).

You should organise the files in the following manner.

```
Github/
└── sws_project/
        ├── faoswsBalancing/
        ├── faoswsDataQuality/
        ├── faoswsFeed/
        ├── faoswsFlag/
        ├── faoswsFood/
        ├── faoswsImputation/
        ├── faoswsIndustrial/
        ├── faoswsLoss/
        ├── faoswsProduction/
        ├── faoswsSeed/
        ├── faoswsStandardization/
        ├── faoswsStock/
        ├── faoswsTourist/
        ├── faoswsTradeTmp/
        ├── faoswsUtil/
        ├── .Rbuildignore
        ├── .Renviron
        └── Standards/
```

## Install R Studio (Optional)

If you are on Windows and using a FAO computer, you can install R Studio from
the Software Center.

Open this [link](http://hqwprsccmapp1/CMApplicationCatalog/) in IE, and search
for R studio.

This is optional, you are welcome to the IDE of your preference.

## Install Git

If you are on windows, you can install Git by downloading the executables
[here](https://git-scm.com/download/win).

If you are unfamiliar with Git, we would suggest to take a quick
[course](https://try.github.io/levels/1/challenges/1)

More about Git [here](https://git-scm.com/book/en/v2/Getting-Started-About-Version-Control)

## Install Essential R Packages

The following packages are the backbone of all SWS projects, and they
should be installed before proceeding.

First of all, we need to install devtools, a package which contains
function to develop R packages.

```r
install.packages("devtools")
```

Next we can install the faosws package, ensure you have local
connection as the repository is not available publicly. This package
is developed by the Engineering team, and is the work horse package to
extract and save data.

```r
install.packages("faosws", repos="http://hqlprsws1.hq.un.fao.org/fao-sws-cran/")
```

We can then install two in-house package which all projects depends
on. The [faoswsFlag](https://github.com/SWS-Methodology/faoswsFlag)
package contains standard functions to perform flag manipulation,
while the [faoswsUtil](https://github.com/SWS-Methodology/faoswsUtil)
package provides a standard to basic manipulations and freindly helper
functions. 


```r
install_github(repo = "SWS-Methodology/faoswsFlag")
install_github(repo = "SWS-Methodology/faoswsUtil")

```

Finally, install the
[faoswsModules](https://github.com/SWS-Methodology/faoswsModules) which contains
helper function to assist developers to write modules.

```r
install_github(repo = "SWS-Methodology/faoswsModules")
```

## Obtain Authentication

Authentication is required to access certain resources, please contact
the following team to obtain access to respective resources.

### Engineering
* Access to the SWS shared workspace.
* Access to the system, both the QA and the Production server.
* Grant access to datasets.
* Access to the SWS shared drives.

### Team A
* Obtain access to the SWS-Methodology Github repositories.


## Setting Up the Test Environment

Follow the steps outline in the R manual.

```
help(GetTestEnvironment)
```

If the installation and setups are correct, then the example should be
able to be executed without an error.


## Repository Structure

Each project has its own repository which builds into a package and
has all associated modules and documentation.

Below is a brief description of the structure of the repositories. For
any new projects, the following folders are mandatory.


* The `R` directory contains various files with function definitions
  (but only function definitions - no code that actually runs).

* The `data` directory contains data used in the analysis. This is
  treated as read only; in paricular the R files are never allowed to
  write to the files in here. Depending on the project, these might be
  csv files, a database, and the directory itself may have
  subdirectories.

* The `man` folder contains all the automatically generated
  documentation. This folder should not be manually edited.

* The `test` folder contains unit tests which are executed during the
  checking of a package in order to determine whether the package
  fulfills all the requirements.

* `Vignettes` folder contains documentation which explains the logic
  and functionality of the package, it also includes workflow charts
  and any material that helps explaing the use of the package.

* The `module` is where all R modules/plug-ins should be placed.

For more detail explaination please refere to the [R package guide.](http://r-pkgs.had.co.nz/package.html)


## The SWS Web Interface


There are two servers which exist for different function. The QA server stands
for Quality and Assuarance, and is used to test functionality and experiements
before going live on the Production server.

[QA Server](http://hqlqasws1.hq.un.fao.org:8080/sws)

[Production Server](intranet.fao.org/sws/)

The web interface will be mainly used to upload moduels and provide a graphic
user interface to the data. To see how to upload module and interact with the
Web Interface please see [here](https://).

## SWS Shared Drives

## Documentations

Before dewelling into development, it is important to understand the
practices and standards governed by the SWS team and it is recommended
to go through the following documentations.

### Project Information

Each projects will have the following documentation

Purpose of the project - README.md

Overall explaination of the project - vignettes

Code documentation - R manual


### Before You Start Writing Codes:

[R Coding Standards](https://google.github.io/styleguide/Rguide.xml)

[SWS Workflow](https://github.com/SWS-Methodology/Standards/blob/master/workflow.md)

[How to Write R Modules for SWS](https://github.com/SWS-Methodology/Standards/blob/master/writing_r_modules.md)

[Dealing With Various Country and Commodity Classification](https://)

[Dealing with Flags](https://github.com/SWS-Methodology/Standards/blob/master/dealing_with_flags.md)

[Documentation Maintained by Engine](https://workspace.fao.org/tc/sws/userspace)

[QA Dataset Reference](http://hqlqasws1.hq.un.fao.org:8080/dataset_configuration.html)

[Production Dataset Reference](http://hqlprswsas1.hq.un.fao.org:8080/dataset_configuration.html)