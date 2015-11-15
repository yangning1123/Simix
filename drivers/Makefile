# Makfefile for dirvers
include ../Makefile.vars

OBJECTS		:= Screen.o

all: $(OBJECTS)	
clean:
	rm -rf $(OBJECTS)

%.o: %.cpp
	$(CXX) $(CXXFLAGS) -c $< -o $@
