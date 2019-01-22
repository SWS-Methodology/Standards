# Guide for New Developer

This is the guide for new developer to setup and configure their
environment in order to initiate development.

## File Organisation

This directory structure is optional, but is a helpfule guide to keep everything organised.

First create a **Github** folder for all future Github related work.

Create an **sws_project** folder in the Github folder for all SWS related
projects. The root folder will also contain configuration and setup files to run
the environment.

The **sws_project** folder will contain folders which correspond to a single project
and should have an associated Github repository. For each of the projects, if the
project exists already, then clone the repository from Github, otherwise start a
new project. For more information, refer to the
[workflow](workflow.md).

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
## Software installation

If you are on Windows and using a FAO computer, you can install R, R Studio, Rtools and MikTeX from the Software Center.

Open this [link](http://hqwprsccmapp1/CMApplicationCatalog/) in IE (or an IE tab extension in another browser), and search
for the appropriate software.

### Install R

Install R for your platform. If you're on Windows, this will be available in the Software Center. Otherwise, install the latest version from [the CRAN website](https://cran.r-project.org/). 

### Install R Studio (Optional)

Either install from the Software Center (Windows) or from [the RStudio website](https://www.rstudio.com/products/rstudio/download/).

This is **optional**, you are welcome to the IDE of your preference. Having said that, most projects have a .Rproj file which makes working with R Studio easier.

### Install Rtools (Windows only)

If you're running Windows, you may not have all the tools you need to compile packages. It's recommended to get `Rtools` from the Software Center. It includes `gcc` and `make` and all you need to compile packages in R.

### Install a LaTeX distribution

In Windows, the most popular is MiKTeX, but for Mac and Linux there are other ones such as [TeXLive](https://www.tug.org/texlive/acquire.html). This is mostly used for building pdf vignettes. 

### Install Git

If you are on Windows, you can install Git by downloading the portable [from their website](https://git-scm.com/download/win).

If you are unfamiliar with Git, we would suggest to take a quick [course](https://try.github.io/levels/1/challenges/1). There's also the excellent Pro Git book which is [available for free online](https://git-scm.com/book/en/v2/Getting-Started-About-Version-Control).

### Install Essential R Packages

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

The default version of faosws (currently available in github) cannot be used for the Prod env and it reqiuests a 
Given that Rcurl does not support the protoce TLS, a patch is requested to properly install 
faosws. The folowing steps are requested:

First: clone the bitbucket faosws repository and switch branch:

```r 
git clone "https://sdlc.fao.org/bitbucket/scm/sws/faosws.git"
git checkout dismiss-RCurl

```
The tar.gz file of the packeage faosws must be created: use twice the 7-zip. The first time to create the .tar file, 
the second one to create the .gizip.

Finally run the following code in the command line:

```
path/Rcmd.exe INSTALL --build faosws.tar.gz

```


Second: the curl library must be replaced with the one stored in the shared folder
````
T:\Team_working_folder\A\mongeau\tmp 
````

Note that you can easily find the folder where this library must replaced typing the following line in the command line:
```
.libPaths()

```



Note as well that all the other of our published packages and packages available on the Statistical Working System are contained in that repository and in the Bitbucket repository.

We can then install the development versions of the two in-house package on which all projects depend. The [faoswsFlag](https://github.com/SWS-Methodology/faoswsFlag) package contains standard functions to perform flag manipulation, while the [faoswsUtil](https://github.com/SWS-Methodology/faoswsUtil) package provides a standard to basic manipulations and friendly helper functions. 


```r
library(devtools)
install_github(repo = "SWS-Methodology/faoswsFlag")
install_github(repo = "SWS-Methodology/faoswsUtil")

```

Finally, install the [faoswsModules](https://github.com/SWS-Methodology/faoswsModules) package which contains helper functions to assist developers to write modules.

```r
install_github(repo = "SWS-Methodology/faoswsModules")
```

## Obtain Authentication

Authentication is required to access certain resources, please contact
the following teams to obtain access to respective resources.

### CIO
For these items, you'll have to use the Service Desk to file a ticket

* Access to T Drive
* Access to JIRA

### Engineering
* Access to the SWS shared workspace.
* Access to the system, both the QA and the Production server.
* Permissions to access datasets.
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

* The `vignettes` folder contains documentation which explains the logic
  and functionality of the package, it also includes workflow charts
  and any material that helps explaing the use of the package.

* The `module` is where all R modules/plug-ins should be placed.

For a more detailed explanation please refer to the [R package guide](http://r-pkgs.had.co.nz/package.html).


## The SWS Web Interface


There are two servers which exist for different functions. The QA server stands
for Quality and Assurance, and is used to test functionality and experiements
before going live on the Production server.

[QA Server](http://hqlqasws1.hq.un.fao.org:8080/sws)

[Production Server](http://intranet.fao.org/sws/)

The web interface will be mainly used to upload modules and provide a graphic
user interface to the data. To see how to upload modules and interact with the
Web Interface please see [here](https://).

## SWS Shared Drives

## Documentations

Before delving into development, it is important to understand the
practices and standards governed by the SWS team and it is recommended
to go through the following documentation.

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
