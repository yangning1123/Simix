# Makefile for Simix

# compliers
AS	:= as
LD	:= ld

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

$(BOOT): boot/boot.S
	$(AS) -o $@ $<


