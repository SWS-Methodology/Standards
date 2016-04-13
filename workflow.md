## To Start a New Project

Please follow this [guide](http://r-pkgs.had.co.nz/package.html) by Hadley

Use R Studio or the `devtool` to create the new project.

```
devtool::create(<new_project_name>)
```

## To Continue on Existing Project

Clone the Github Repository.

```
git clone <repository_link>
```

The *<repository_link>* can be copied from the red box shown below.

![screenshot from 2016-04-13 16 24 25](https://cloud.githubusercontent.com/assets/1054320/14496837/e2618c3e-0194-11e6-9f28-a14ec495b64a.png)


## Git Workflow

Follow the guides below for managing the work flow.

[Understanding the Github Flow](https://guides.github.com/introduction/flow/)

or If you prefer the web interface

[GitHub Flow in the Browser](https://help.github.com/articles/github-flow-in-the-browser/)

## Deployment

### Package

To deploy the package, first build the package.

```
R CMD build <repository>
```

then run the check on the built tar ball
```
R CMD check <tarball_file>
```

Make sure all the tests are passed without warning.

**NOTE (Michael): The checking should also be implemented with
Continuous Integration**

Send the package to Sebastian to be installed and tested on the QA
server.

### Modules

Zip up the modules which contains only allowed files specified in the
module standards.

Then upload the module to the server through the web interface.



## Development Workflow

All changes to funciton/module/packages should be tested on the QA
server before migrating to the production server.