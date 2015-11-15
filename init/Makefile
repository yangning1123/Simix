# Makefile for init
include ../Makefile.vars

# LDFLAGS strip all
LDFLAGS		+= -s

# kernel binary
KERNEL  	:= kernel.bin

# drivers kernel, etc
DEP_DIRS	:= ../drivers 

# objects
OBJECTS		:= start.o main.o
DEP_OBJECTS	:= $(foreach dir, $(DEP_DIRS), $(dir)/*.o)

# targets
all: $(OBJECTS) 
	$(LD) $(LDFLAGS) -T kernel.lds $(OBJECTS) $(DEP_OBJECTS) -o $(KERNEL)

clean:
	rm -rf $(OBJECTS) $(KERNEL)

%.o: %.S
	$(CXX) $(CXXFLAGS) -c $< -o $@
%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@
