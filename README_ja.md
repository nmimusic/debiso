# DebISO - Debian/Ubuntuリミックス作成ソフト
----
# なにこれ
Debian/Ubuntuのリミックスや派生ディストロを作るBashスクリプトだ。

# How to install
## 1. 依存関係をインストールする
### Debian/Ubuntu系
```bash
sudo apt install binutils debootstrap dosfstools grub-efi-amd64-bin grub-efi-ia32-bin grub-pc-bin mtools squashfs-tools unzip xorriso
```

### Fedora系
```bash
sudo dnf install binutils debootstrap dosfstools grub-efi-ia32 grub-efi-x64 grub-pc mtools squashfs-tools unzip xorriso
```

### Arch/Manjaro系
```bash
sudo pacman -S binutils debootstrap dosfstools grub mtools squashfs-tools unzip xorriso
```

## 2. 最新リリースをダウンロードする
tarballを`https://github.com/njb-fm/debiso/releases`からダウンロードして解凍する。

## 3. 導入と実行
Debianリミックスのサンプルを作りたい場合…
```bash
cd debiso
sudo ./mkdebiso -p configs/debian_sample
```

Ubuntuリミックスのサンプルを作りたい場合…
```bash
cd debiso
sudo ./mkdebiso -p configs/debian_sample
```

# 君達自身のプロファイルを作ろう
See [usage](https://github.com/njb-fm/debiso/wiki/usage)

# ライセンス
スクリプトやコンポーネントは三条項BSDライセンスのもとで無償で配布しています。[LICENSE](LICENSE)も見てね。
