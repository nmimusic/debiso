# DebISO - Debian/Ubuntu Remix Creator
----
# What's this?
A Bash script for remixed Debian/Ubuntu and Debian/Ubuntu-based distro.

# How to install
## 1. Install Dependencies
### Debian/Ubuntu-based
```bash
sudo apt install binutils debootstrap dosfstools grub-efi-amd64-bin grub-pc-bin mtools squashfs-tools unzip xorriso
```

### Fedora-based
```bash
sudo dnf install binutils debootstrap dosfstools grub-efi-x64 grub-pc mtools squashfs-tools unzip xorriso
```

### Arch/Manjaro-based
```bash
sudo pacman -S binutils debootstrap dosfstools grub mtools squashfs-tools unzip xorriso
```

## 2. Download Latest Release
Download tarball from `https://github.com/nmimusic/debiso/releases`, and extract it.

## 3. Execute
When you make Debian remix sample...
```bash
cd debiso
sudo ./mkdebiso -p configs/debian-sample
```

Also, when you make Ubuntu remix sample...
```bash
cd debiso
sudo ./mkdebiso -p configs/ubuntu-sample
```

## Customise your own profile
See [usage](https://github.com/nmimusic/debiso/wiki/usage)

# License
The scripts and components are licensed under 3-clause BSD License. See  also [LICENSE](LICENSE).
