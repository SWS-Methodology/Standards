# Guide to Writing R Modules/Pulg-ins

Question (Michael):How should we version the module?

## When Designing a Module:

Follow the Curly's Law

>  Do one thing and one thing only

Modulise the task as much as possible.  Try to do as little as
possible and rely on the packages as much as possible. The module are
intended to be srcipts which wraps the logic of the tasks.


## Structure of a Standard Module:

A standard module should have the following structure
```
modules/
└── test_modules
    ├── R
    ├── README.md
    ├── test_module.R
    ├── test_module.xml
    └── .gitattributes
```

* A main R file
* An xml file
* A README.md
* An R folder containing helper functions.
  * These may only contain R files which will be sourced before the main R file.

### Structure of the Main R file

1. Loading required libraries and configurations
2. Define and extract the required data
3. Validate extracted data
4. Make a copy of the extracted data
5. Perform computation
6. Perform module testing
7. Check the modification of the data
8. Save data back
9. Message and results. This section should be standardised.

### Structure of the XML file

The structure of the XML should follow the [XML
Schema](https://workspace.fao.org/tc/sws/userspace/Shared%20Documents/R%20Development/rScript.xsd).

### What to Include in the README? 

The README.md must include the following information.

* The Purpose of the module
* What inputs it takes
* What inputs it ignores
* What inputs it modifies
* The tests performed and the requirements to fulfill

### The .gitattributes file

The file should contain the following line:
```
README.md export-ignore
```

This will tell `git archive` to ignore the file when building the zip file.


## Do's and Don'ts

### A Module Must

* Run to completion without errors when it is run
  * If an error is encountered, it must be handled by the code and an informative response must be given
  * Have every function used in the main script documented
  * This applies as well to other FAO packages called by the module

* Contain tests for the intended purpose. For example, if a module is
  intended to impute all the data, then before the data is saved, it
  should be tested for any missing values.

* Run the validation module, this is to ensure quality input. The
  validation should at least throw an warning when data are
  invalid. (There is a potential for confusion and complication when
  the invalid dataset is out of the selected scope.)
 

### A Module Must Not:

* Depend on reference to a specific user

* Rely on fixed csvs in the working folder (They should be Datatables)
  (Ad-hoc tables should be formalised where ever possible.)
 

### A Module Should:


* Only write to one dataset
* Return the selected session, this is for user experience.

* Define all necessary functions in the beginning of the module and
  use pipe as much as possible. This makes the module easier to debug
  and refactor, in addition functions which are transferable can then
  be moved to the
  [faoswsUtil](https://github.com/SWS-Methodology/faoswsUtil) package.
 

