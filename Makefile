# Makefile for Simix

# compliers
AS	:= as
LD	:= ld
CC	:= gcc
QEMU	:= qemu-system-i386

# flags
#ASFLAGS := -I./include
LDFLAGS := --oformat binary 
CCFLAGS := -pipe -Wall -Wextra -ffreestanding -I./include

# execute binarys and images
BOOT 	:= boot/boot.bin
LOADER  := boot/loader.bin
IMAGES	:= a.img            # 假设a.img已存在且为fat12格式

# targets
all: $(BOOT) $(LOADER) $(IMAGES)

boot: $(BOOT)
loader: $(LOADER)
images: $(IMAGES)

clean:
	rm -rf $(BOOT)
	rm -rf $(LOADER)

simulation:
	$(QEMU) -drive format=raw,file=a.img,if=floppy


$(IMAGES): $(BOOT) $(LOADER)
	dd if=$(BOOT) of=a.img bs=512 count=1 conv=notrunc
	sudo mount a.img /mnt/floppy
	sudo cp -v $(LOADER) /mnt/floppy/
	sudo umount /mnt/floppy

$(BOOT): boot/boot.S
	$(CC) $(CCFLAGS) -c $< -o boot/boot.o 
	$(LD) $(LDFLAGS) -Ttext 0x7c00 -o $@ boot/boot.o
$(LOADER): boot/loader.S
	$(CC) $(CCFLAGS) -c $< -o boot/loader.o
	$(LD) $(LDFLAGS) -Ttext 0x0 -o $@ boot/loader.o

