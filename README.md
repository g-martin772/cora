# Cora OS

Build Instructions for Windows:
1. Install [WLS2](..%2F..%2FUsers%2Fgmart%2FAppData%2FLocal%2FTemp%2FManual%20installation%20steps%20for%20older%20versions%20of%20WSL%20-%20Microsoft%20Learn.url)
2. Grab a debian based distro from the Microsoft Store
3. Install the following packages:
    - `sudo apt install build-essential nasm genisoimage`
4. Install qemu for windows and add it to your path
5. Run `make run` in the root directory of the project from WSL