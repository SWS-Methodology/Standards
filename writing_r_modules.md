# Guide to Writing R Modules/Pulg-ins

## When Designing a Module:

Follow the Curly's Law

>  Do one thing and one thing only

Modulise the task as much as possible.  Try to do as little as
possible and rely on the packages as much as possible. The module are
intended to be srcipts which wraps the logic of the tasks.


## Structure of a Standard Module:

[Here](https://github.com/SWS-Methodology/Standards/tree/master/modules/hello_world) is an example of the structure

A standard module should have the following files
```
modules/
└── test_modules
    ├── R/
    ├── README.md
    ├── main.R
    ├── main.xml
    ├── sws.yml
    └── .gitattributes
```

* A main R file
* An xml file
* A README.md
* An R folder containing helper functions.
  * These may only contain R files which will be sourced before the main R file.

Follow the instructions of the
[faoswsModules](https://github.com/SWS-Methodology/faoswsModules) package to
start writing a module.


### Structure of the XML file

The structure of the XML should follow the [XML
Schema](https://workspace.fao.org/tc/sws/userspace/Shared%20Documents/R%20Development/rScript.xsd).

### What to Include in the README? 

The README.md must include the following information.

* The Purpose of the module

### The .gitattributes file

The file should have `export-ignore` for the files that should not be built into
the zip file.

```
README.md export-ignore
sws.yml.example export-ignore
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
 

## Managing Plugins On The Statistical Working Sysmte (SWS)

### Upload R-plugins

Create a zip file containing only the `main.R` and `main.xml` file for the
module.

If the module contains optional helpers file, they should be placed in the `R/`
folder and included in the zip.

Then upload the module to the statistical working system through the web
interface.

Click the **R plugins** button to manage R plugins.
![interface_view](https://cloud.githubusercontent.com/assets/1054320/15273000/8746a4a0-1a8b-11e6-8e09-3e525de7dd37.png)

Under the **plugins management** tab, upload the module (zip file) through the
upload functionality in the red box.

If the module has been approved, check the **core** box. This indicates the
module is a core module and can write directly back to the database.
![plugins_management](https://cloud.githubusercontent.com/assets/1054320/15273008/bc77a1ec-1a8b-11e6-806d-dfc5ca924dc7.png)


### Run R-plugins

To execute a module, we first need to select the dataset that the module will be
operating.

First create a new session for the module, or open from previous session.
![new_session](https://cloud.githubusercontent.com/assets/1054320/15273094/352580b6-1a8f-11e6-810c-6e4680dcf1a2.png)


Then select the corresponding domain and dataset the module will be executed.
This domain and dataset should have been included in the xml declaration,
otherwise the system will not be able to find the module.

![select_data](https://cloud.githubusercontent.com/assets/1054320/15273096/6695d510-1a8f-11e6-9862-f9ab908bcdc7.png)

Now select the keys, and run the query to view the data.

![select_keys](https://cloud.githubusercontent.com/assets/1054320/15273101/96afb39c-1a8f-11e6-9da1-06b5660f109a.png)

Click the button for **R plugins** to enter the menu for executing the R
modules.

![data_view](https://cloud.githubusercontent.com/assets/1054320/15273107/ad2758aa-1a8f-11e6-9c4f-8c2edfd0cdff.png)

Fill in the parameters and execute the module. The module can be executed in
**Synchronous** or **Scheduled** mode.

![execute_r_plugins](https://cloud.githubusercontent.com/assets/1054320/15273112/cd1633c0-1a8f-11e6-85f0-60bf87b92be1.png)
