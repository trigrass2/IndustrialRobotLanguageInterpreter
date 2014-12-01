# include the system specific Makefile
include Makefile.Linux
 
default: all

#all: rop2cc rop2ro
all: rop2cc 

clean:
#	-rm -f rop2ro rop2cc *.o absyntax/*.o Makefile.depend
	-rm -f  rop2cc *.o absyntax/*.o Makefile.depend
# make something everywhere (ie, in all Makefiles that have that target)
	find . -depth -mindepth 2 -maxdepth 2 -name Makefile -printf %h\\n | xargs -i make -C{} $@



#get warnings, debugging information and optimization
CXXFLAGS  = -Wall -pedantic -Wpointer-arith -Wwrite-strings
# CXXFLAGS += -Werror
CXXFLAGS += -ggdb -O3 -funroll-loops
# Note: if the optimizer crashes, we'll leave out the -O3 for those files

CXXFLAGS += -I.



LIBS  = absyntax/absyntax.o absyntax/visitor.o
LIBS += stage1_2/rop.y.o stage1_2/rop.flex.o

# rop2cc: main.o stage4/generate_cc/generate_cc.o stage4/stage4.o $(LIBS)
#	$(CXX) -o rop2cc main.o stage4/stage4.o stage4/generate_cc/generate_cc.o $(LIBS)

rop2cc: main.o $(LIBS)
	$(CXX) -o rop2cc main.o  $(LIBS)


#rop2ro: main.o stage4/generate_ro/generate_ro.o stage4/stage4.o $(LIBS)
#	$(CXX) -o rop2ro main.o stage4/stage4.o stage4/generate_ro/generate_ro.o $(LIBS)


#how to make things in subdirectories etc
../% /% absyntax/% stage1_2/% stage3/%  util/%:
	$(MAKE) -C $(@D) $(@F)

Makefile.depend depend:
	$(CXX) -MM -MG -I. *.cc \
	  | perl -pe 's/:/ Makefile.depend:/' > Makefile.depend

include Makefile.depend




