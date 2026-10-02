# LOKI Control Project - Application Template
Project to build the Linux OS image for generic target systems, with minimal configuration.

This repository is a prototype [LOKI](https://github.com/stfc-aeg/loki) project, a generic Embedded-Linux control
system that can be adapted to run application-specific control software based on the odin-control framework.

This template allows for the creation of an application repository with the following features:
- LOKI Core image build, including `odin-control` and dependencies
- Custom Application-specific Yocto layer (optional)
- Custom firmware (optional)

This project uses versions of LOKI v2.0.3+, and Xilinx toolchain 2023-2.

## Creating a Application from this Template

### 1. Create a new repository using this template

1. Browse to the [main page of this repo on GitHub](https://github.com/stfc-aeg/loki-embedded-application-template) **while logged in** and click the drop-down that says *Use this template*
2. Select *Create a new repository*
3. Give your project a unique name, by convention `projectname-embedded`
4. Click on *Create Repository*

### 2. Update your `README.md`

The `README` will be this one from the template repository- you will most likely want to update this to reflect the target project.

### 3. Pull your project locally

To develop on this project you will need to clone it locally on a machine that has the Xilinx 2023-2 toolchain.

```bash
git clone git@github.com:MYPROJECTNAME.git
cd MYPROJECTNAME
```

#### Environment Setup

Load the Xilinx 2023-2 toolchain.
To do this as DSSG, run:

```bash
module load xilinx/2023-2
vivado_env
vitis_env
petalinux_env
```

The Makefile will check tool versions are correct as part of the build.

### 4. Perform first-time configuration with `menuconfig`.

The first time you run the build tools, you will be prompted to set up the project with the `menuconfig`.

> [!NOTE]
> You will also need the tool `menuconfig` or the python module `menuconfig` (part of `kconfiglib`) installed on your system to run the project configuration tool the first time you set up your project. If you can't run `python -m menuconfig`, try `pip install --user kconfiglib`.

```bash
make
```

This should launch you into a TUI. Options can be navigated with direction arrows, and `?` will give you more information about some options.

1. Under toolchain configuration, check the tool version. The defaults are most likely fine here, but if you know you are not using the default firmware project you can prevent it from being needlessly pulled.
2. Under hardware configuration you can choose the directory name that will be used to run the firmware build Makefile, and where the build system will look for results. Again, defaults should be fine unless you're using a custom submodule or subdirectory. You can also choose to use pre-built firmware (XSA) under `Local Build /  Prebuilt Select`.
3. Under Software you can shoose if you would like to provide a custom FSBL/PMUFW. You almost certainly just want to stick with the core LOKI build, as this has now been brought under the control of PetaLinux
4. **MOST LIKELY CHANGES**
   1. Give your project a name- this should not be changed on a whim as it will be built into the image
   2. If you have a local Yocto layer for software for your application, tick the `Enable Application Yocto Layer` box. This will allow  you to specify a local directory name for it, and it will be included in the build.
   3. Optionally you can change the base TMPDIR root location. It is unlikely you want to do this
   4. You can disable the automatic unique temporary directory feature, but this is discouraged to prevent collisions.
  
From here, `q` will exit the generation; you should save the result.

> [!NOTE]
> Do not be alarmed if you see an error complaining about `config.mk`. This is a bug; the `make` command when executed for the build should run fine the second time.

This configuration will  now be saved in `.config`, a file which you should include in your repository so that settings persist.
You should not *need* to run the configuration again, but if you need to alter any settings (for example if you are adding a user layer for Yocto that wasn't initially included) run `menuconfig` or `python -m menuconfig` to re-enter the TUI.

### 5. Build the project

In future (and on a fresh clone of your project) this is the only step you should have to repeat.
Ensure (as above) you have the Xilinx tools loaded.

On first run (unless deactivated) the core repositories will be pulled automatically.

> [!WARNING]
> BEFORE YOU RUN THIS, make sure you have used ssh agent to load keys used for github clones. It will fail without prompt for a password.

#### **OPTIONAL:** Create Firmware Project Only (for editing)

If you are just building the project, it is not necessary to run this step separately; it will simply save time by only creating the Vivado project for `loki-firmware` and then stopping.

```bash
make firmware-project
```

This will create the `loki-firmware/firmware/firmware.xpr` project file, which can be opened in Vivado.

#### Whole Project

```bash
make
```

> [!NOTE]
> At this time, the FSBL / PMUFW is only being used as a prebuilt file, as the current LOKI 2023 toolchain is broken for Vitis.

On successive builds having modified only the control software, only the PetaLinux build should re-run.

The build files required for the board are in `./loki/os/petalinux-custom/build/images/linux/`:
- `image.ub` is the main Linux image. If there is an existing file, this can simply replace it to update the system
- `BOOT.BIN` is the customised U-Boot Bootloader, which is required but is unlikely to change unless the LOKI tag has been upated
- `boot.scr` is the U-Boot script, which is required but is unlikely to change unless the LOKI tag has been upated

### 6. Alter the project for your needs!

Go to https://github.com/stfc-aeg/loki/wiki/Yocto-Layer-for-Odin-Control to find out more about creating a new Yocto layer for your project.
You can then include the layer in the build from within the `menuconfig` TUI.

## How to Update to a later template

> [!WARNING]
> Be prepared to deal with merge conflicts! This should not commonly be performed unless there are serious compatibility issues in Makefiles or the build system.

First, check if you already have more than one remote:

```bash
git remote
```

If you see both `origin` and `template`, you are good to go.

Otherwise, run the following:

```bash
git remote add template git@github.com:stfc-aeg/loki-embedded-application-template.git
```

To merge the latest template into your current branch:

```bash
git fetch template
git merge template/master --allow-unrelated-histories
```

You will probably also want to ignore any changes to the `README.md` in favour of your own:

```bash
git reset README.md; git checkout -- README.md
```

> [!NOTE]
> Note that if the submodules have changed, you'll need to run `git submodule update --init --recursive` for them to actually be pulled.

Good luck!



