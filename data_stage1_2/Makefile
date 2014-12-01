# include the system specific Makefile
include ../Makefile.Linux



default:	all

.PHONY: all

all: ro.flex.o ro.y.o

clean:
	-rm -f *.o Makefile.depend
	-rm -f ro.flex.c ro.y.cc ro.y.hh ro.y.output
	-rm -f test_flex

#get warnings, debugging information and optimization
CFLAGS  = -Wall -pedantic -Wpointer-arith -Wwrite-strings
# CFLAGS += -Werror

CFLAGS += -ggdb -O3 -funroll-loops
# Note: if the optimizer crashes, we'll leave out the -O3 for those files

CFLAGS += -I. -I../* -I../../absyntax

test_flex: ro.flex.c ro.y.hh
	$(CXX) -o test_flex.o -c ro.flex.c -DTEST_MAIN $(CFLAGS)
	$(CXX) -o test_flex test_flex.o
#	$(CXX) -o test_flex test_flex.o ../util/symtable.o -DTEST_MAIN

ro.flex.c: ro.flex
	flex -o ro.flex.c ro.flex

ro.flex.o: ro.y.hh ro.flex.c
	$(CXX) -c ro.flex.c  $(CFLAGS)

ro.y.hh ro.y.cc: ro.y
	bison -d -v -o ro.y.cc ro.y

ro.y.o: ro.y.cc ro.y.hh
	$(CXX) -c ro.y.cc  $(CFLAGS)





#how to make things from other directories if they are missing
../% /%:
	$(MAKE) -C $(@D) $(@F)
