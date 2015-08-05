# Makefile for Simix

# compliers
AS	:= as
LD	:= ld
CC	:= gcc
QEMU	:= qemu-system-i386

# flags
#ASFLAGS := -I./include
LDFLAGS := --oformat binary -e _start -Ttext 0x7c00 
CCFLAGS := -pipe -Wall -Wextra -ffreestanding -I./include

# execute binarys and images
BOOT 	:= boot/boot.bin
IMAGES	:= a.img            # 假设a.img已存在且为fat12格式

# targets
all: $(BOOT) $(IMAGES)

boot: $(BOOT)

images: $(IMAGES)

clean:
	rm -rf $(BOOT)

simulation:
	$(QEMU) -drive format=raw,file=a.img



$(IMAGES): $(BOOT)
	dd if=$(BOOT) of=a.img bs=512 count=1 conv=notrunc

$(BOOT): boot/boot.S
	$(CC) $(CCFLAGS) -c $< -o boot/boot.o 
	$(LD) $(LDFLAGS) -o $@ boot/boot.o


