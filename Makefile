# Makefile for Simix

# compliers
AS	:= as
LD	:= ld
CC	:= gcc
QEMU	:= qemu-system-i386

# flags
#ASFLAGS := -I./include
LDFLAGS := --oformat binary -e _start -Ttext 0x7c00 
CCFLAGS := -Wall -Werror -ffreestanding -I./include

# execute binarys
BOOT 	:= boot/boot.bin

# targets
all: $(BOOT)

boot: $(BOOT)

clean:
	rm -rf $(BOOT)

# 假设floppy已存在当前目录
images:
	dd if=$(BOOT) of=a.img bs=512 count=1 conv=notrunc

simulation:
	$(QEMU) -drive format=raw,file=a.img


$(BOOT): boot/boot.S
	$(CC) $(CCFLAGS) -c $< -o boot/boot.o 
	$(LD) $(LDFLAGS) -o $@ boot/boot.o


