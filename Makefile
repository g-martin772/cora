BOOT=src/bootloader/bootloader.asm
MULTIBOOT=src/bootloader/multiboot.asm
KERNEL=$(wildcard src/kernel/*.c)
OBJ=$(patsubst src/kernel/%.c, build/%.o, $(KERNEL))
OBJ_D=$(patsubst src/kernel/%.c, build/%_d.o, $(KERNEL))
LINKER=src/linker.ld

IMAGE=build/cora.bin
ISO=build/cora.iso

all: build iso

bin_dir:
	mkdir -p build
$(OBJ): build/%.o: src/kernel/%.c bin_dir
	gcc -m32 -c $< -o $@ -std=gnu99 -ffreestanding -O2 -Wall -Wextra
$(OBJ_D): build/%.o: src/kernel/%.c bin_dir
	gcc -m32 -c $< -o $@ -std=gnu99 -ffreestanding -O2 -Wall -Wextra -ggdb
build: $(MULTIBOOT) $(OBJ) $(LINKER) bin_dir
	nasm -f elf32 $(MULTIBOOT) -o build/multiboot.o
	ld -m elf_i386 -T $(LINKER) build/multiboot.o $(OBJ) -o $(IMAGE) -nostdlib
build_debug: $(MULTIBOOT) $(OBJ) $(LINKER) bin_dir
	nasm -f elf32 $(MULTIBOOT) -o build/multiboot.o
	ld -m elf_i386 -T $(LINKER) build/multiboot.o $(OBJ_D) -o $(IMAGE) -nostdlib
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