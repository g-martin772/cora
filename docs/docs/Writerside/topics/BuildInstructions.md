# BuildInstructions

## Windows:

1. Install [WLS2](https://learn.microsoft.com/en-us/windows/wsl/install-manual)
2. Grab a debian based distro from the Microsoft Store
3. Install the following packages:
    - `sudo apt install build-essential nasm genisoimage grub-pc-bin xorriso`
4. Install qemu for windows and add it to your path
5. Run `make run` in the root directory of the project from WSL