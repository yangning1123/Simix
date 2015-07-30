# Makefile for Simix

# compliers
AS	:= as
LD	:= ld
QEMU	:= qemu-system-i386

# flags
#ASFLAGS :=
LDFLAGS := --oformat binary -e _start -Ttext 0x7c00 


# execute binarys
BOOT 	:= boot/boot.bin

# targets
all: $(BOOT)

boot: $(BOOT)

clean:
	rm -rf $(BOOT)

images:
	dd if=$(BOOT) of=a.img bs=512 count=1 conv=notrunc

run:
	$(QEMU) -drive format=raw,file=a.img


$(BOOT): boot/boot.S
	$(AS) $< -o boot.o
	$(LD) $(LDFLAGS) -o $@ boot.o


