# Makefile for init
include ../Makefile.vars


# entry for kernel
ENTRY		:= 0x80400

# kernel binary
KERNEL  	:= kernel.bin

# objects
OBJECTS		:= start.o main.o

# targets
all: $(OBJECTS)
	$(LD) $(LDFLAGS) -Ttext $(ENTRY) $(OBJECTS) -o $(KERNEL)

clean:
	rm -rf $(OBJECTS) $(KERNEL)

%.o: %.S
	$(CXX) $(CXXFLAGS) -c $< -o $@
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@
