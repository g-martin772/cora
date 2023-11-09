BOOT=src/bootloader/bootloader.asm
MULTIBOOT=src/bootloader/multiboot.asm
KERNEL=src/kernel/kernel.c
LINKER=src/linker.ld

IMAGE=build/cora.bin
ISO=build/cora.iso

all: build

build: $(MULTIBOOT) $(KERNEL) $(LINKER)
	mkdir -p build
	nasm -f elf32 $(MULTIBOOT) -o build/multiboot.o
	gcc -m32 -c $(KERNEL) -o build/kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra
	ld -m elf_i386 -T $(LINKER) build/multiboot.o build/kernel.o -o $(IMAGE) -nostdlib
build_debug: $(MULTIBOOT) $(KERNEL) $(LINKER)
	mkdir -p build
	nasm -f elf32 $(MULTIBOOT) -o build/multiboot.o
	gcc -m32 -c $(KERNEL) -o build/kernel.o -std=gnu99 -ffreestanding -O2 -Wall -Wextra -ggdb
	ld -m elf_i386 -T $(LINKER) build/multiboot.o build/kernel.o -o $(IMAGE) -nostdlib
run: build 
	qemu-system-i386.exe -kernel $(IMAGE) -monitor stdio
debug: build_debug
	qemu-system-i386 -kernel $(IMAGE) -s -S &
	gdb -x .gdbinit
iso: build src/bootloader/grub.cfg
	mkdir -p build/iso/boot/grub
	cp $(IMAGE) build/iso/boot/grub/cora.bin
	cp src/bootloader/grub.cfg build/iso/boot/grub/grub.cfg
	grub-mkrescue -o $(ISO) build/iso
	rm -rf build/iso
run-iso: iso
	qemu-system-i386.exe -cdrom $(ISO)
clean:
	rm -rf build