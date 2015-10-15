# Makefile for Simix

# compliers
AS	:= as
LD	:= ld
CC	:= gcc
QEMU	:= qemu-system-i386

# variables
ENTRY	:= 0x80400

# flags
#ASFLAGS := -I./include
LDFLAGS := --oformat binary -m elf_i386 -s
CCFLAGS := -pipe -Wall -Wextra -ffreestanding -I./include -m32 -c

# execute binarys and images
BOOT 	:= boot/boot.bin
LOADER  := boot/loader.bin
KERNEL  := init/kernel.bin
IMAGES	:= a.img            # 假设a.img已存在且为fat12格式

# targets
all: $(BOOT) $(LOADER) $(KERNEL) $(IMAGES)

boot: $(BOOT)
loader: $(LOADER)
kernel: $(KERNEL)
images: $(IMAGES)

clean:
	rm -rf $(BOOT)
	rm -rf $(LOADER)
	rm -rf $(KERNEL)
	rm -rf boot/*.o
	rm -rf init/*.o

simulation:
	$(QEMU) -drive format=raw,file=a.img,if=floppy


$(IMAGES): $(BOOT) $(LOADER)
	dd if=$(BOOT) of=a.img bs=512 count=1 conv=notrunc
	sudo mount a.img /mnt/floppy
	sudo cp -v $(LOADER) /mnt/floppy
	sudo cp -v $(KERNEL) /mnt/floppy
	sudo umount /mnt/floppy

$(BOOT): boot/boot.S
	$(CC) $(CCFLAGS) $< -o boot/boot.o 
	$(LD) $(LDFLAGS) -Ttext 0x7c00 -o $@ boot/boot.o
$(LOADER): boot/loader.S
	$(CC) $(CCFLAGS) $< -o boot/loader.o
	$(LD) $(LDFLAGS) -Ttext 0x0 -o $@ boot/loader.o
$(KERNEL): init/start.S init/main.c
	$(CC) $(CCFLAGS) init/start.S -o init/start.o
	$(CC) $(CCFLAGS) init/main.c -o init/main.o
	$(LD) -Ttext $(ENTRY) -o $@ init/start.o init/main.o -m elf_i386 -s
