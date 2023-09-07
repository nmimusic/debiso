# How To Build The ISO Image
1. Edit configuration files in profile directory.
2. Execute ```sudo mkdebiso -p <profile directory>```
3. There are points where the input is required in the middle, and the necessary value is input by the keyboard.
4. An ISO image is created in the "out" directory.

# Configuration Files
```
profile directory/
├── calamares_config.d/
│   ├──branding/
│   ├──modules/
│   └──settings.conf
├── dirootfs/
│   └──root/
│      └──customise_dirootfs.d/
│         ├──preinstall.sh
│         └──postinstall.sh
├── grub/
├── sources.list.d/
├── trusted.gpg.d/
├── exclude_packages.arch
├── flatpak_packages.arch
├── packages.arch
├── ppa.arch
└── profiledef.sh
```

## profiledef.sh
Config file such as the ISO file name.

### List of variables
* DISTRO_NAME<br>Distro's name.
* DISTRO_UNAME<br>Distro's unix-name. It consists of a lowercase letter, a number from 0 to 9, and a hyphen or underscore.
* DISTRO_VERSION<br>Distro's version number.
* UPSTREAM<br>Upstream name: "debian" or "ubuntu".
* UPSTREAM_VERSION<br>Version codename of upstream. Tested version is bookworm and jammy.
* MIRROR_URL<br>Repository mirror URL.
* ARCH<br>Architecture. Only amd64 is supported.

## calamares-configs.d/ (create as needed)
If you don't install the Calamares config files from the deb package, put the configuration file in this directory.

## dirootfs/
Files to add to filesystem on live environment. For example, dconf, auto login settings, and desktop themes.

## sources.list.d/ (create as needed)
Directory in which to place the package repository lists. When adding external repositories, such as when operating your own repository, add the GPG keys in "trusted.gpg.d".

## sources.list
List of package repositories. When adding external repositories, such as when operating your own repository, add the GPG keys in "trusted.gpg.d".

## trusted.gpg.d/ (create as needed)
Directory in which to place the dearmored GPG keys described above.

## packages.arch
List of deb packages to install.

## flatpak_packages.arch (create as needed)
List of Flatpak packages to install. Only installation from Flathub is supported.

## exclude_packages.arch (create as needed)
List of deb packages to remove. Sometimes unwanted packages are installed (e.g. if you try to install LXQt, it somehow comes with Xfce and even GNOME), so it is better to have this list in order to remove such unnecessary packages after installation.

## ppa.arch (create as needed, only ubuntu-based)
List of personal package archives.

## dirootfs/root/customise_dirootfs.d/preinstall.sh (create as needed)
Script that runs before installing deb packages.

## dirootfs/root/customise_dirootfs.d/postinstall.sh (create as needed)
Script that runs after installing deb packages.
