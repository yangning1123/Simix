# Makfefile for dirvers
include ../Makefile.vars

OBJECTS		:= i8259.o

all: $(OBJECTS)	
clean:
	rm -rf $(OBJECTS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@
