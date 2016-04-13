## Getting Started
### To Start a New Project

Please follow this [guide](http://r-pkgs.had.co.nz/package.html) by Hadley

Use R Studio or the `devtool` to create the new project.

```
devtool::create(<new_project_name>)
```

### To Continue on Existing Project

Clone the Github Repository.

```
git clone <repository_link>
```

The <repository_link> can be copied from the red box shown below.

![screenshot from 2016-04-13 16 24 25](https://cloud.githubusercontent.com/assets/1054320/14496837/e2618c3e-0194-11e6-9f28-a14ec495b64a.png)


## Development Cycle


All new development should follow the steps below:

### 1. Create Github issue outlining the problem or improvement required.
### 2. Development

#### Git Workflow

Follow the guides below for managing the work flow.

[Simple Github Flow](https://guides.github.com/introduction/flow/)

More details of the work flow on this [blog.](http://scottchacon.com/2011/08/31/github-flow.html)


### 3. Deployment

#### Package

To deploy the package, first build the package.

```
R CMD build <repository>
```

then run the check on the built tar ball

```
R CMD check <tarball_file>
```

Make sure all the tests are passed without warning. Once the package
passess the check, a pull request can be issued.

**NOTE (Michael): The checking should also be implemented with
Continuous Integration**

Send the package to Sebastian to be installed and tested on the QA
server.

#### Modules

Zip up the modules which contains only allowed files specified in the
module standards.

Then upload the module to the server through the web interface.


### 4. Integration Test

After the module has been uploaded or the package has been installed,
run several tests to ensure the module or package passes existing
tests.

**NOTE (Michael): Need to set the criteria for integration test.**


All changes to funciton/module/packages should be tested on the QA
server before migrating to the Production server.

### 5. Send the Pull Request then Close the Issue

Code review will be conducted and investigate whether all changes
satisfy requirements and standards.

### 6. Merge the Branch

When the code has been reviewed and no error has been spotted
immediately, then we can merge the development branch back to the
master.