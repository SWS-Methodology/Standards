## Getting Started
### To Start a New Project

Please follow this [guide](http://r-pkgs.had.co.nz/package.html) by Hadley

Use R Studio or the `devtools` to create the new project.

```
devtools::create(<new_project_name>)
```

### To Continue on Existing Project

Clone the Github Repository.

```
git clone <repository_link>
```

The `<repository_link>` can be copied from the red box shown below.

![screenshot from 2016-04-13 16 24 25](https://cloud.githubusercontent.com/assets/1054320/14496837/e2618c3e-0194-11e6-9f28-a14ec495b64a.png)


## Development Cycle


All new development should follow the steps below:

### 1. Create Github Issue Outlining the Problem or Improvement Required.

![issues](https://cloud.githubusercontent.com/assets/1054320/14524205/95d3269a-0237-11e6-954b-4f0a762a65eb.png)

### 2. Development

#### Git Workflow

Follow the guides below for managing the work flow.

[Simple Github Flow](https://guides.github.com/introduction/flow/)

More details of the work flow on this [blog.](http://scottchacon.com/2011/08/31/github-flow.html)


### 3. Deployment

#### Package

Before deploying your package, make sure that you've decided on a version. We use [semantic versioning](http://semver.org/) with the format `major.minor.bugfix`. If your package isn't ready to be used in a production environment, your release should be `0.minor.bugfix`. If this is your first release, you should start with `0.1.0`. If you add new functionality, increase the `minor` version by one. If you're just fixing issues, increase the `bugfix` number by one. If you've released `1.0.0`, anything you do that breaks existing functionality should increase the `major` number. If not, just increase the `minor number`.

You should specify your package version in the `Version` field in the `DESCRIPTION` file. You should also change the `Date` field to have today's date.

##### Manual deployment

To deploy the package, first update the manuals with `roxygen`.
`<package_folder>` refers to the folder of the project (e.g. faoswsProduction).

```r
library(roxygen2)
roxygenise(<package_folder>)
```

Then build the package.

```
R CMD build <package_folder>
```

then run the check on the built tar ball

```
R CMD check <tarball_file>
```

Make sure all the tests are passed without warning. Once the package
passess the check, a pull request can be issued.

**NOTE (Michael): The checking should also be implemented with
Continuous Integration**


After the package has passed without any error, tag the `<version_number>`
with Git

```
git tag -a <version_number> -m <your_message>
git push –-tags
```

Then request Sebastin to install the package.

#### Modules

Simply upload the R module on to the Statistical Working System through the web
interface.

### 4. Integration Test

After the module has been uploaded or the package has been installed,
run several tests to ensure the module or package passes existing
tests.

**NOTE (Michael): Need to set the criteria for integration test.**


All changes to function/module/packages should be tested on the QA server before
migrating to the Production server.

### 5. Send the Pull Request then Close the Issue

Code review will be conducted and investigate whether all changes
satisfy requirements and standards.

### 6. Merge the Development Branch back to Master Branch

When the code has been reviewed and no error has been spotted
immediately, then we can merge the development branch back to the
master.
