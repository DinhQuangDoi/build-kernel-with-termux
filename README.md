### TG@dinhanhtu005
### Install Termux
- Download [Termux](https://termux.com) apk from [Here](https://f-droid.org/repo/com.termux_118.apk)
### Update Termux & install proot.
```
pkg update && pkg upgrade -y
pkg install proot-distro -y
```
### Install Ubuntu.
```
proot-distro install ubuntu
```
### Login to Ubuntu.
```
proot-distro login ubuntu --user root
```

### Update Ubuntu.
```
apt update && apt upgrade -y
```
### Install tool & compiler package required.
```
apt install git make gcc clang libssl-dev pkg-config flex bison libelf-dev libncurses-dev python3 python-is-python3 dos2unix curl unzip zip openjdk-17-jre -y
```
### Note: 

- Why gcc and clang native and not any other external compiler? of course no compiler is more suitable for proot more than the tools in its library, don't forget you are using a phone arm64 not an x86_64 device to do this.

- If you want to add user do it after update and install all necessary tools because the tools installation process will not be interrupted or encounter any error with user root(root@localhost:~#).


### Start compiling.
- Clone your kernel source.

- Let's "cd" to kernel scr and edit or create new script build.sh, you can also refer to my script and edit important parts like kernel name, device config name, path etc...
- For kernel cheat player: If you want your kernel to be able to execute drivers like QX, RT, GT or any other proprietary drivers you need to edit your device_defconfig, open and edit config with nano or you can find the path /data/data/com.termux/files/usr/var/lib/proot-distro/installed-rootfs/ubuntu/home/your-scr/ to delete line CONFIG_MODULE_SIG_FORCE=y & CONFIG_MODULE_SIG_SHA512=y then delete or comment CONFIG_MODULE_SIG=y like this # CONFIG_MODULE_SIG is not set.
```
  ./your-scrip-build.sh HOSTLDFLAGS="-L/usr/lib/aarch64-linux-gnu -Wl,-rpath=/usr/lib/aarch64-linux-gnu"`
```
- Hope this information will be useful to you.
- Good luck with your compilation!
