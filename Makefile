all: build
build: ./src/bootloader/bootloader.asm
	mkdir -p build
	nasm -f bin ./src/bootloader/bootloader.asm -o build/cora.bin
run: build 
	qemu-system-i386.exe build/cora.bin
iso: build 
	mkdir -p build/iso
	dd if=/dev/zero of=build/iso/cora.img bs=1024 count=1440
	dd if=build/cora.bin of=build/iso/cora.img seek=0 count=1 conv=notrunc
	genisoimage -quiet -V 'CORA' -input-charset iso8859-1 -o build/cora.iso -b cora.img -hide build/iso/cora.img build/iso
	rm -rf build/iso
run-iso: iso 
	qemu-system-i386.exe -cdrom build/cora.iso
clean:
	rm -rf build