# DebISO - Debian/Ubuntu Remix Creator
----
# What's this?
A Bash script for remixed Debian/Ubuntu and Debian/Ubuntu-based distro.

# How to install
## 1. Install Dependencies
### Debian/Ubuntu-based
```bash
sudo apt install binutils debootstrap dosfstools grub-efi-amd64-bin grub-efi-ia32-bin grub-pc-bin mtools squashfs-tools unzip xorriso
```

### Fedora-based (exclude Enterprise-like)
```bash
sudo dnf install binutils debootstrap dosfstools grub-efi-ia32 grub-efi-x64 grub-pc mtools squashfs-tools unzip xorriso
```

### Arch/Manjaro-based
```bash
sudo pacman -S binutils debootstrap dosfstools grub mtools squashfs-tools unzip xorriso
```

## 2. Clone this Git repository
```bash
git clone https://github.com/njb-fm/debiso.git ~/debiso
cd ~/debiso
```

## 3. Install and execute
When you make Debian remix sample...
```bash
sudo make install
sudo mkdebiso -p configs/debian_sample
```

Also, when you make Ubuntu remix sample...
```bash
sudo make install
sudo mkdebiso -p configs/debian_sample
```

# How to uninstall
```bash
cd ~/debiso
sudo make uninstall
```

## Customise your own profile
See [usage](https://github.com/njb-fm/debiso/wiki/usage)

# License
The scripts and components are licensed under 3-clause BSD License. See  also [LICENSE](LICENSE).
