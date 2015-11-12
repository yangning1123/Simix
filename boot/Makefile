# Makefile for bootloader
include ../Makefile.vars

# LDFLAGS for raw binary
LDFLAGS 	+= --oformat binary -Ttext

# raw binarys
BOOT 		:= boot.bin
LOADER  	:= loader.bin

# targets
all: boot loader

clean:
	rm -rf *.o *.bin

boot: boot.o
	$(LD) $(LDFLAGS) 0x7c00 $< -o $(BOOT)
loader: loader.o
	$(LD) $(LDFLAGS) 0x0 $< -o $(LOADER)
%.o: %.S
	$(CXX) $(CXXFLAGS) -c $< -o $@
