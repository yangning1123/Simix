# Makefile for Simix
include ./Makefile.vars

DIRS 		:= boot drivers kernel



all: 
	@for i in $(DIRS); do $(MAKE) -C $$i; done 

clean:
	@for i in $(DIRS); do $(MAKE) -C $$i clean; done

images: boot/boot.bin kernel/kernel.bin
	dd if=boot/boot.bin of=$(IMG) bs=512 count=1 conv=notrunc
	sudo mount $(IMG) /mnt/floppy
	sudo cp -v kernel/kernel.bin /mnt/floppy
	sudo umount /mnt/floppy


debug:
	$(QEMU) $(QEMUFLAGS) -s -S 


simulation:
	$(QEMU) $(QEMUFLAGS)
