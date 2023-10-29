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
run: build 
	qemu-system-i386.exe -kernel $(IMAGE)
# iso: build
# 	mkdir -p build/iso
# 	dd if=/dev/zero of=build/iso/cora.img bs=1024 count=1440
# 	dd if=build/cora.bin of=build/iso/cora.img seek=0 count=1 conv=notrunc
# 	genisoimage -quiet -V 'CORA' -input-charset iso8859-1 -o build/cora.iso -b cora.img -hide build/iso/cora.img build/iso
# 	rm -rf build/iso
# run-iso: iso
# 	qemu-system-i386.exe -cdrom build/cora.iso
clean:
	rm -rf build