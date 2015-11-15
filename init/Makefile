# Makefile for init
include ../Makefile.vars

# LDFLAGS strip all
LDFLAGS		+= -s

# kernel binary
KERNEL  	:= kernel.bin

# objects
OBJECTS		:= start.o main.o

# targets
all: $(OBJECTS)
	$(LD) $(LDFLAGS) -T kernel.lds $(OBJECTS) -o $(KERNEL)

clean:
	rm -rf $(OBJECTS) $(KERNEL)

%.o: %.S
	$(CXX) $(CXXFLAGS) -c $< -o $@
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@
