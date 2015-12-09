# Makefile for Simix
include ./Makefile.vars

DIRS 		:= boot drivers init kernel

# 假设a.img已存在且为fat12格式
IMG		:= a.img   

all: 
	@for i in $(DIRS); do $(MAKE) -C $$i; done 

clean:
	@for i in $(DIRS); do $(MAKE) -C $$i clean; done

images: boot/boot.bin kernel/kernel.bin
	dd if=boot/boot.bin of=$(IMG) bs=512 count=1 conv=notrunc
	sudo mount $(IMG) /mnt/floppy
	sudo cp -v kernel/kernel.bin /mnt/floppy
	sudo umount /mnt/floppy


simulation:
	$(QEMU) -drive format=raw,file=$(strip $(IMG)),if=floppy
