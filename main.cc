/*
 ****************************************************************
 ****************************************************************
 ****************************************************************
 *********                                              *********
 *********                                              *********
 *********   O V E R A L L    A R C H I T E C T U R E   *********
 *********                                              *********
 *********                                              *********
 ****************************************************************
 ****************************************************************
 ****************************************************************

 The compiler works in 4(+1) stages:
 Stage 1   - Lexical analyser      - implemented with flex (iec.flex)
 Stage 2   - Syntax parser         - implemented with bison (iec.y)
 Stage 3   - Semantics analyser    - not yet implemented
 Stage 4   - Code generator        - implemented in C++
 Stage 4+1 - Binary code generator - gcc, javac, etc...


 Data structures passed between stages, in global variables:
 1->2   : tokens (int), and token values (char *)
 2->1   : symbol tables (defined in symtable.hh)
 2->3   : abstract syntax tree (tree of C++ classes, in absyntax.hh file)
 3->4   : Same as 2->3
 4->4+1 : file with program in c, java, etc...


 The compiler works in several passes:
 Pass 1: executes stages 1 and 2 simultaneously
 Pass 2: executes stage 3
 Pass 3: executes stage 4
 Pass 4: executes stage 4+1
*/



//#include <stdio.h>   // printf()

#include <stdlib.h>  // EXIT_FAILURE
#include "absyntax/absyntax.hh"  // symbol_c type

#include <string.h> //wangzhen 0702




/* A macro for printing out internal parser errors... */
#include <iostream> // required for std::cerr
#define ERROR error_exit(__FILE__,__LINE__)
void error_exit(const char *file_name, int line_no) {
  std::cerr << "\nInternal program error in file " << file_name
            << " at line " << line_no << "\n\n\n";
  exit(EXIT_FAILURE);
}



/* forward declarations... */
int stage1_2(const char *filename,  symbol_c **tree_root);
//int stage3(symbol_c *tree_root);
//int stage4(symbol_c *tree_root);


static void printusage(const char *cmd) {
  printf("%s [<input_file>] [-I <include_directory>]\n", cmd);
}



int main(int argc, char **argv) {
  symbol_c *tree_root;
  char * includedir = NULL;

  if (argc == 4) {
    if (strcmp(argv[2], "-I") != 0) {
      printusage(argv[0]);
      return EXIT_FAILURE;
    }
    includedir = argv[3];
    argc = 2;
  }

  if (argc != 2) {
    printusage(argv[0]);
    return EXIT_FAILURE;
  }

  /* 1st Pass */
  if (stage1_2(argv[1], &tree_root) < 0)
    return EXIT_FAILURE;

  /* 2nd Pass */
  /* not yet implemented... */
  /*
  if (stage3(tree_root) < 0)
    return EXIT_FAILURE;
  */

  /* 3rd Pass */
  /*if (stage4(tree_root) < 0)
    return EXIT_FAILURE;*/

  /* 4th Pass */
  /* Currently implemented in the Makefile! */

  return 0;
}


