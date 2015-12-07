# Makefile for bootloader
include ../Makefile.vars

# LDFLAGS for raw binary
LDFLAGS 	+= --oformat binary -N

# raw binarys
BOOTLOADER	:= boot.bin

# targets
all: boot

clean:
	rm -rf *.o *.bin

boot: boot.o
	$(LD) $(LDFLAGS) -Ttext 0x7c00 $< -o $(BOOTLOADER)
%.o: %.S
	$(CXX) $(CXXFLAGS) -c $< -o $@
