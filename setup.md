# Guide for New Developer

This is the guide for new developer to setup and configure their
environment in order to initiate development.

## Project Objective

The overarching aim of the methodological team is to build

> A Simple, Robust and Accurate Scientific System with Minimal Human
  Intervention.


or

![lasso](https://cloud.githubusercontent.com/assets/1054320/14507619/bdc021e0-01c3-11e6-9ee5-483d8a0b70b1.png)


Where y is the true value, and X are the inputs. The beta coefficients
are the human input that translate data and inputs to fitted
values. The goal is to minimise the error, subject to minimising the
input from both humana manipulation and only develop the minimal
functionalities that improves the system.



## File Organisation
First create a *Github* folder for all future Github related projects.

Create a *sws_project* folder in the Github folder for all SWS related
projects, all individual projects such as **faoswsProduction** should
reside inside this folder.

The folder will also contain configuration and setup files to run the
environment.

You should have the similar structure
```
sws_project/
├── faoswsBalancing
├── faoswsDataQuality
├── faoswsFeed
├── faoswsFlag
├── faoswsFood
├── faoswsImputation
├── faoswsIndustrial
├── faoswsLoss
├── faoswsProduction
├── faoswsSeed
├── faoswsStandardization
├── faoswsStock
├── faoswsTourist
├── faoswsTradeTmp
├── faoswsUtil
├── .Rbuildignore
├── .Renviron
├── .Rhistory
└── Standards
```

## Install R Studio

## Install Git
Additional tools will be required if on Windows.

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

Then we can install the faosws package, ensure you have local
connection. This package is developed by the Engineering team, and is
the work horse package to extract and save data.

```r
install.packages("faosws", repos="http://hqlprsws1.hq.un.fao.org/fao-sws-cran/")
```

We can then install two in-house package which all projects depends
on. The `faoswsFlag` package contains standard functions to perform
flag manipulation, while the `faoswsUtil` package provides a standard
to basic manipulations and freindly helper functions.


```r
install_github(repo = "SWS-Methodology/faoswsFlag")
install_github(repo = "SWS-Methodology/faoswsUtil")
```

## Obtain Authentication

Authentication is required to access certain resources, please contact
the following team to obtain access to respective resources.

### Engineering
* Access to the SWS shared workspace.
* Access to the system, both the QA and the Production server.
* Grant access to datasets.

### Team A
* Obtain access to the SWS-Methodology Github repositories.


## Repository Structure

Below is a brief description of the structure of the repositories.


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

## Documentations

Before dewelling into development, it is important to understand the
practices and standards governed by the SWS team and recommended to go
through the following documentations.

### Project Information
Each projects will have the following files

Purpose of the project - README.md

Overall explaination of the project - vignettes

Code documentation - R manual


### Before you start writing codes:

[R Coding Standards](https://google.github.io/styleguide/Rguide.xml)

[How to Write R Modules for SWS](https://)