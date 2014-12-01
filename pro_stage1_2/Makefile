# include the system specific Makefile
include ../Makefile.Linux



default:	all

.PHONY: all

all: rop.flex.o rop.y.o

clean:
	-rm -f *.o Makefile.depend
	-rm -f rop.flex.c rop.y.cc rop.y.hh rop.y.output
	-rm -f test_flex

#get warnings, debugging information and optimization
CFLAGS  = -Wall -pedantic -Wpointer-arith -Wwrite-strings
# CFLAGS += -Werror

CFLAGS += -ggdb -O3 -funroll-loops
# Note: if the optimizer crashes, we'll leave out the -O3 for those files

CFLAGS += -I. -I../* -I../../absyntax

test_flex: rop.flex.c rop.y.hh
	$(CXX) -o test_flex.o -c rop.flex.c -DTEST_MAIN $(CFLAGS)
	$(CXX) -o test_flex test_flex.o
#	$(CXX) -o test_flex test_flex.o ../util/symtable.o -DTEST_MAIN

rop.flex.c: rop.flex
	flex -o rop.flex.c rop.flex

rop.flex.o: rop.y.hh rop.flex.c
	$(CXX) -c rop.flex.c  $(CFLAGS)

rop.y.hh rop.y.cc: rop.y
	bison -d -v -o rop.y.cc rop.y

rop.y.o: rop.y.cc rop.y.hh
	$(CXX) -c rop.y.cc  $(CFLAGS)





#how to make things from other directories if they are missing
../% /%:
	$(MAKE) -C $(@D) $(@F)
