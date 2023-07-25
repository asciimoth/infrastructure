Installtion instruction

# Boot from installation usb
# Install some tools
```
$ nix-shell -p git micro gnupg
```
# Clone this repo
```
$ git clone https://github.com/asciimoth/infrastructure.git
```
# Import gpg key
```
$ gpg --import infrastructure/keys/moth.pub.gpg
```
# Init gpg card
```
$ gpg --card-status
```
# Decrypt password
```
$ echo "allow-loopback-pinentry" > ~/.gnupg/gpg-agent.conf
$ export PASSWORD=$(cat infrastructure/machines/pcLexell/luks_key.asc | gpg --pinentry-mode loopback --decrypt -)
```
# wipe disk if neded
```
$ sudo wipefs -a /dev/<disk ex sda>
```
# Create two partitions for bootloader and root
## For UEFI env
```
$ sudo fdisk /dev/<disk ex sda>
  g
  n
  enter
  enter
  +2G
  t
  1
  n
  enter
  enter
  enter
  w
```
## For virtualbox
```
$ sudo fdisk /dev/<disk ex sda>
  o
  n
  enter
  enter
  enter
  +2G
  n
  enter
  enter
  enter
  enter
  w
```
# Setup luks partition encrypted with password
```
$ echo "$PASSWORD" | sudo cryptsetup luksFormat -q /dev/<partition ex sda2>
$ echo "$PASSWORD" | sudo cryptsetup luksOpen /dev/<partition ex sda2> crypted -
```
# Create filesystems
```
$ sudo mkfs.fat -F 32 /dev/sda1
$ sudo mkfs.ext4 /dev/mapper/crypted
```
# Mount
```
$ sudo mount /dev/mapper/crypted /mnt
$ sudo mkdir -p /mnt/boot
$ sudo mount /dev/sda1 /mnt/boot
```
# Generate system config
```
$ sudo nixos-generate-config --root /mnt
```
# Copy config
```
$ sudo cp -r infrastructure /mnt/etc/
```
# Copy new configuration.nix and hardware-configuration.nix to config
```
$ sudo cp /mnt/etc/nixos/* /mnt/etc/infrastructure/machines/pcLexell/
```
# Edit generated config
```
$ sudo micro /mnt/etc/infrastructure/machines/pcLexell/configuration.nix 
```
# Install from config
```
$ sudo nixos-install --root /mnt --flake /mnt/etc/infrastructure#pcLexell
```
# Shutdown system
```
$ sudo shutdown now
```
