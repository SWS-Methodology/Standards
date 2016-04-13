# Guide for New Developer

This is the guide for new developer to setup and configure their
environment in order to initiate development.

## Project Objective

To build

> A Simple, Robust and Accurate Scientific System with Minimal Human
  Intervention.


or

![render](https://cloud.githubusercontent.com/assets/1054320/14500460/844bb9c2-01a2-11e6-9e90-095b7d5e96f6.png)



## File Organisation
First create a *Github* folder for all future Github related projects.

Create a *sws_project* folder in the Github folder for all SWS related
projects, all individual projects such as **faoswsProduction** should
reside inside this folder.

The folder will also contain configuration and setup files to run the
environment.


## Install R Studio

## Install Git
Additional tools will be required if on Windows.

## Install Essential R Packages

The following packages are the backbone of all SWS projects, and they
should be installed before proceeding.

First of all, we need to install devtools.

```r
install.packages("devtools")
```

Then we can install the faosws package, ensure you have local connection.
```r
install.packages("faosws", repos="http://hqlprsws1.hq.un.fao.org/fao-sws-cran/")
```

We can then install two in-house package which all projects depends on.
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

**NOTE (Michael): Add description of each folder.**


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