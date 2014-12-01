/**************************************************************/
/**************************************************************/
/*File Description  : Robot Data files interpreter with bison */
/*Author            : Wang Zhen                               */
/*Create Date       : 2014.06.20                              */
/*Last Update       : 2014.07.07                              */
/**************************************************************/
/**************************************************************/

/******************************************/
/******************************************/
/*Section 01  : Definitions...            */
/*Author      : Wang Zhen                 */
/*Create Date : 2014.06.20                */
/*Last Update : 2014.07.07                */
/******************************************/
/******************************************/

%{
/*******************************************************/
/*Part 0101   : Macro definitions and declarations of  */
/*              funtions and variables that are used   */
/*              in the actions in the grammar rules... */
/*Author      : Wang Zhen                              */
/*Create Date : 2014.06.20                             */
/*Last Update : 2014.07.07                             */
/*******************************************************/

/* required for strdup()  */
#include <string.h>	

/* declare the token parser generated by flex... */
int yylex(void);

/* declare the error handler defined at the end of this file */
void yyerror (const char *error_msg);

/* produce a more verbose parsing error message */
#define YYERROR_VERBOSE

/* Include debuging code.
 * Printing of debug info must then be activated by setting
 * the variable yydebug to 1.
 */
#define YYDEBUG 0

/* file with declaration of absyntax classes... */
#include "../absyntax/absyntax.hh"

/* file with declaration of token constants. Generated by bison! */
#include "rop.y.hh"

/* file with the declarations of symbol tables... */
#include "../util/symtable.hh"


/*********************************/
/* The global symbol tables...   */
/*********************************/
/* NOTE: declared static because they are not accessed
 *       directly by the lexical parser (flex), but rather
 *       through the function get_identifier_token()
 */

/* A symbol table to store library elements*/
/* e.g: <function_name,function_decl> (no function_decl)
        <program_name, program_decl> (every program file is a program that can be called by other programs)
 */
static symtable_c<int, BOGUS_TOKEN_ID> library_element_symtable;

/* A symbol table to store the declared variables of the program currently being parsed...
 */
static symtable_c<int, BOGUS_TOKEN_ID> variable_element_symtable;

/*************************/
/* global variables...   */
/*************************/
static symbol_c *tree_root = NULL;

/* The name of the file currently being parsed...
 * Note that flex accesses and updates this global variable
 */
const char *current_filename = NULL;

%}

/*******************************************************/
/*Part 0102   : Bison declarations that define         */
/*              terminal and nonterminal symbols,      */
/*              specify precedence, and so on...       */
/*Author      : Wang Zhen                              */
/*Create Date : 2014.06.20                             */
/*Last Update : 2014.07.07                             */
/*******************************************************/

/*******************************************/
/*  - Use another name      */
/*******************************************/

%name-prefix "pro_yy"

/*******************************************/
/*  -      */
/*******************************************/
%union {
    symbol_c 	*leaf;
    list_c	*list;
    char 	*ID;	/* token value */
}

/*****************************/
/*B 0 Prelimenary constructs... */
/*****************************/
%type <leaf> start
%token BOGUS_TOKEN_ID

%token <ID>    subprogram_name_token
%type <leaf>   subprogram_name 

%token <ID>    prev_declared_variable_name_token 
%type <leaf>   prev_declared_variable_name

/*******************************************/
/* B 1.1 - Identifiers */
/*******************************************/

%token <ID>	identifier_token

/*********************/
/* B 1.2 - Constants */
/*********************/
%type <leaf>   constant

/******************************/
/* B 1.2.1 - Numeric Literals */
/******************************/
%type <leaf>    numeric_literal

%token <ID>	binary_integer_token
%type <leaf>    binary_integer

%token <ID>	octal_integer_token
%type <leaf>    octal_integer

%token <ID>	hex_integer_token
%type <leaf>    hex_integer

%type <leaf>    integer_literal
%type <leaf>    non_negative_signed_integer

%token <ID>	integer_token 	
%type <leaf>    integer
 
%type <leaf>    real_literal
%type <leaf>    non_negative_signed_real

%token <ID>	real_token
%type <leaf>    real 

%type <leaf>    bit_string_literal
%type <leaf>    boolean_literal	

%token TRUE
%token FALSE

/*******************************/
/* B 1.2.2 - Character Strings */
/*******************************/
%token <ID>	character_string_token
%type <leaf>    character_string

/*********************/
/* B 1.4 - Variables */
/*********************/
%type <leaf>   symbolic_variable


/***********************/
/* B 2.1 - Expressions */
/***********************/
%type <leaf>   expression
%type <leaf>   xor_expression
%type <leaf>   and_expression
%type <leaf>   comparison
%type <leaf>   equ_expression
%type <leaf>   add_expression
%type <leaf>   term
%type <leaf>   power_expression
%type <leaf>   primary_expression
%type  <leaf>	unary_expression
%type  <leaf>	function_invocation

%token AND
%token XOR
%token OR
%token NOT
%token LT
%token LE
%token GT
%token GE
%token EQ
%token NE

/********************/
/* B 2.2 Statements */
/********************/
%type <list>   statement_list
%type <leaf>   statement

/*********************************/
/* B 2.2.1 Assignment Statements */
/*********************************/
%type <leaf>   assignment_statement
%token ASSIGN

/*****************************************/
/* B 2.2.2 Subprogram Control Statements */
/*****************************************/
%type <leaf>   subprogram_statement
%token CALL


/********************************/
/* B 2.2.3 Selection Statements */
/********************************/
%type <leaf>   selection_statement
%type <leaf>   if_statement
%type <list>   elseif_statement_list 
%type <leaf>   elseif_statement
%token IF
%token THEN
%token ELSE
%token ELSEIF
%token END_IF

/********************************/
/* B 2.2.4 Iteration Statements */
/********************************/
%type <leaf>   iteration_statement
%type <leaf>   while_statement
%type <leaf>   loop_statement
%token WHILE
%token DO
%token END_WHILE
%token LOOP
%token END_LOOP

/********************************/
/* B 2.2.5 Robot Statements */
/********************************/

%type  <leaf>   function_name
%type  <leaf>   robot_instruction_name
%token <ID>	standard_function_name_token
%token <ID>	standard_robot_instruction_token
%type <leaf>   robot_statement


/*********************************/
/* B 2.2.5 Param assignment list */
/*********************************/
%type <list>   param_assignment_list  
%type <leaf>   param

%type <leaf>   const_expression

%%
/******************************************/
/******************************************/
/*Section 02  : Grammar rules...          */
/*Author      : Wang Zhen                 */
/*Create Date : 2014.06.20                */
/*Last Update : 2014.07.07                */
/******************************************/
/******************************************/

/*********************************/
/* B 0 Prelimenary constructs... */
/*********************************/
start:
  statement_list	{$$ = $1;}
;
/*************************/
/* B 1 - Common elements */
/*************************/

/*********************/
/* B 1.2 - Constants */
/*********************/
constant:
  numeric_literal
| character_string
| bit_string_literal
| boolean_literal
;

/******************************/
/* B 1.2.1 - Numeric Literals */
/******************************/
numeric_literal:
  integer_literal
| real_literal
;


integer_literal: 
  non_negative_signed_integer
        {$$ = new integer_literal_c(new dint_type_name_c(), $1);}
| binary_integer
	{$$ = new integer_literal_c(new dint_type_name_c(), $1);}
| octal_integer
	{$$ = new integer_literal_c(new dint_type_name_c(), $1);}
| hex_integer
	{$$ = new integer_literal_c(new dint_type_name_c(), $1);}
;

non_negative_signed_integer:
  integer
| '+' integer   {$$ = $2;}
;

real_literal: non_negative_signed_real
    {$$ = new real_literal_c(new real_type_name_c(), $1);}
;

non_negative_signed_real:
  real
| '+' real	{$$ = $2;}
;

real:
  real_token		{$$ = new real_c($1);}
;

/* ATTENTION PLEASE! integer will prouce reduce/reduce conflicts! You can use
*            bit_string_literal:
*                bit_string_type_name '#' integer  
*	              {$$ = new bit_string_literal_c($1, $3);}
*to solve this bug!
*/
bit_string_literal:
  '#' integer    
        {$$ = new bit_string_literal_c(new dword_type_name_c(), $2);} 
| '#' binary_integer
	{$$ = new bit_string_literal_c(new dword_type_name_c(), $2);}
| '#' octal_integer
	{$$ = new bit_string_literal_c(new dword_type_name_c(), $2);}
| '#' hex_integer
	{$$ = new bit_string_literal_c(new dword_type_name_c(), $2);}
;

integer:	integer_token		{$$ = new integer_c($1);};
binary_integer:	binary_integer_token	{$$ = new binary_integer_c($1);};
octal_integer:	octal_integer_token	{$$ = new octal_integer_c($1);};
hex_integer:	hex_integer_token	{$$ = new hex_integer_c($1);};

boolean_literal:
  TRUE	{$$ = new boolean_literal_c(new bool_type_name_c(),
  				    new boolean_true_c());}
| FALSE	{$$ = new boolean_literal_c(new bool_type_name_c(),
				    new boolean_false_c());}
;

/*******************************/
/* B 1.2.2 - Character Strings */
/*******************************/
character_string:   character_string_token
        {$$ = new character_string_c($1);}
;

/*********************/
/* B 1.4 - Variables */
/*********************/
symbolic_variable:
/* NOTE: To be entirely correct, variable_name should be replacemed by
 *         prev_declared_variable_name | prev_declared_fb_name | prev_declared_global_var_name
 */
  prev_declared_variable_name
	{$$ = new symbolic_variable_c($1);}
;

prev_declared_variable_name: prev_declared_variable_name_token 
        {$$ = new identifier_c($1);};/*Attention please! This should not be placed at the first place of this part!*/
;

/***********************/
/* B 1.5.1 - Functions */
/***********************/

function_name:
  standard_function_name_token
	{$$ = new identifier_c($1);}
;

robot_instruction_name:
  standard_robot_instruction_token
	{$$ = new identifier_c($1);}
;


/***********************/
/* B 2.1 - Expressions */
/***********************/
expression:
  xor_expression
| expression OR xor_expression
	{$$ = new or_expression_c($1, $3);}
;

xor_expression:
  and_expression
| xor_expression XOR and_expression
	{$$ = new xor_expression_c($1, $3);}
;

and_expression:
  comparison
| and_expression AND comparison
	{$$ = new and_expression_c($1, $3);}
;

comparison:
  equ_expression
| comparison EQ equ_expression
	{$$ = new equ_expression_c($1, $3);}
| comparison NE equ_expression
	{$$ = new notequ_expression_c($1, $3);}
;

equ_expression:
  add_expression
| equ_expression LT add_expression
	{$$ = new lt_expression_c($1, $3);}
| equ_expression GT add_expression
	{$$ = new gt_expression_c($1, $3);}
| equ_expression LE add_expression
	{$$ = new le_expression_c($1, $3);}
| equ_expression GE add_expression
	{$$ = new ge_expression_c($1, $3);}
;


add_expression:
  term
| add_expression '+' term
	{$$ = new add_expression_c($1, $3);}
| add_expression '-' term
	{$$ = new sub_expression_c($1, $3);}
;


term:
  power_expression
| term '*' power_expression
	{$$ = new mul_expression_c($1, $3);}
| term '/' power_expression
	{$$ = new div_expression_c($1, $3);}
;

power_expression:
  unary_expression
;

unary_expression:
  primary_expression
| '-' primary_expression
	{$$ = new neg_expression_c($2);}
| NOT primary_expression
	{$$ = new not_expression_c($2);}
;

primary_expression:
  param
| '(' expression ')'
	{$$ = $2;}
|  function_invocation
;



/* intermediate helper symbol for primary_expression */
/* NOTE: function_name includes the standard function name 'NOT' !
 *       This introduces a reduce/reduce conflict, as NOT(var)
 *       may be parsed as either a function_invocation, or a
 *       unary_expression.
 *
 *       I (Mario) have opted to remove the possible reduction
 *       to function invocation, which means replacing the rule
 *           function_name '(' param_assignment_list ')'
 *       with
 *           function_name_no_NOT_clashes '(' param_assignment_list ')'
 *
 *       Notice how the new rule does not include the situation where
 *       the function NOT is called with more than one parameter, which
 *       the original rule does include! Callinf the NOT function with more
 *       than one argument is probably a semantic error anyway, so it
 *       doesn't make much sense to take it into account.
 *
 *       Nevertheless, if we were to to it entirely correctly,
 *       leaving the semantic checks for the next compiler stage,
 *       this syntax parser would need to include such a possibility.
 *
 *       We will leave this out for now. No need to complicate the syntax
 *       more than the specification does by contradicting itself, and
 *       letting names clash!
 */
function_invocation:
/*  function_name '(' param_assignment_list ')' */
  function_name '(' param_assignment_list ')'
	{$$ = new function_invocation_c($1, $3);}
;


/********************/
/* B 2.2 Statements */
/********************/

statement_list:
  /* empty */
  {if (tree_root == NULL)
      tree_root = new statement_list_c();
   $$ = (list_c *)tree_root;}
| statement_list statement ';'
  {$$ = $1; $$->add_element($2);}
| statement_list error ';'
  {
     $$ = $1;
     yyerrok;
  }
;

statement:
  robot_statement
| assignment_statement
| subprogram_statement
| selection_statement
| iteration_statement 
;



/*********************************/
/* B 2.2.1 Assignment Statements */
/*********************************/
assignment_statement:
  prev_declared_variable_name ASSIGN expression
	{$$ = new assignment_statement_c($1, $3);}
;

/*********************************/
/*B 2.2.2 Subprogram Statements */
/*********************************/
subprogram_statement:
  CALL subprogram_name {$$ = new subprogram_invocation_c($2);}
;

subprogram_name : subprogram_name_token
       {$$ = new identifier_c($1);}
;

/*********************************/
/*B 2.2.3 Selection Statements */
/*********************************/
selection_statement:
  if_statement
;


if_statement:
  IF expression THEN statement_list elseif_statement_list END_IF
	{$$ = new if_statement_c($2, $4, $5, NULL);}
| IF expression THEN statement_list elseif_statement_list ELSE statement_list END_IF
	{$$ = new if_statement_c($2, $4, $5, $7);}
;

/* helper symbol for if_statement */
elseif_statement_list:
  /* empty */
	{$$ = new elseif_statement_list_c();}
| elseif_statement_list elseif_statement
	{$$ = $1; $$->add_element($2);}
;

/* helper symbol for elseif_statement_list */
elseif_statement:
  ELSEIF expression THEN statement_list
	{$$ = new elseif_statement_c($2, $4);}
;

/********************************/
/*B 2.2.4  Iteration Statements */
/********************************/
iteration_statement:
  while_statement
| loop_statement
;


while_statement:
  WHILE expression DO statement_list END_WHILE
	{$$ = new while_statement_c($2, $4);}
;


loop_statement:
  LOOP const_expression DO statement_list END_LOOP
	{$$ = new loop_statement_c($2, $4);}
;

/*********************************/
/*B 2.2.5  Robot Statements */
/*********************************/
robot_statement:
  robot_instruction_name '(' param_assignment_list ')' {$$ = new robot_instruction_invocation_c($1, $3);}
;

/***********************************/
/* B 2.2.6 - Param assignment list */
/***********************************/
param_assignment_list:
  param
	{$$ = new param_assignment_list_c(); $$->add_element($1);}
| param_assignment_list ',' param
	{$$ = $1; $$->add_element($3);}
;

const_expression:
   integer
|  symbolic_variable
;

param:
  constant
| symbolic_variable
;



%%
/******************************************/
/******************************************/
/*Section 03  : User code...              */
/*Author      : Wang Zhen                 */
/*Create Date : 2014.06.20                */
/*Last Update : 2014.07.07                */
/******************************************/
/******************************************/
#include <stdio.h>	/* required for printf() */
#include <errno.h>
#include "../util/symtable.hh"

/* variables defined in code generated by flex... */
extern FILE *pro_yyin;
extern int pro_yylineno;
extern char *pro_yytext;

/* The following function is called automatically by bison whenever it comes across
 * an error. Unfortunately it calls this function before executing the code that handles
 * the error itself, so we cannot print out the correct line numbers of the error location
 * over here.
 * Our solution is to store the current error message in a global variable, and have all
 * error action handlers call the function print_err_msg() after setting the location
 * (line number) variable correctly.
 */

void pro_yyerror (const char *error_msg) {
  fprintf(stderr, "In file '%s': error %d: %s happen at line %d with the content is '%s'\n", current_filename, pro_yynerrs , error_msg, pro_yylineno, pro_yytext); 
}


int get_identifier_token(const char *identifier_str) {
//  std::cout << "get_identifier_token(" << identifier_str << "): \n";
  int token_id;

  if ((token_id = variable_element_symtable.find_value(identifier_str)) == variable_element_symtable.end_value())
    if ((token_id = library_element_symtable.find_value(identifier_str)) == library_element_symtable.end_value())
      return identifier_token;
  return token_id;
}


/*
 * Join two strings together. Allocate space with malloc(3).
 */
static char *strdup2(const char *a, const char *b) {
  char *res = (char *)malloc(strlen(a) + strlen(b) + 1);

  if (!res)
    return NULL;
  return strcat(strcpy(res, a), b);  /* safe, actually */
}

const char *standard_structure_type_names[] = {
//Position data types
"AXISPOS","CARTPOS","AXISPOSEXT","CARTPOSEXT","ROBAXISPOS","AUXAXISPOS","ROBCARTPOS",
//Reference system data types
"WORLDREFSYS","CARTREFSYS","CARTREFSYSEXT","CARTREFSYSAXIS",
//Tool data types
"TOOL","TOOLSTATIC",
//Overlapping data types
"OVLREL","OVLABS",
//Dynamic data types
"DYNAMIC",
//Percentage
"PERCENT","PERC200",

NULL

};

const char *standard_function_names[] = {
// 2.5.1.5.2  Numerical functions
//   Table 23 - Standard functions of one numeric variable
"ABS","SQRT","EXP","SIN","COS","TAN","ASIN","ACOS","ATAN",
// 2.5.1.5.3  Bit string functions
//   Table 25 - Standard bit shift functions
"SHL","SHR","ROR","ROL",

/* end of array marker! Do not remove! */
NULL

/* Note (a):
 *  This function has a name equal to a reserved keyword.
 *  This means that adding it here is irrelevant because the
 *  lexical parser will consider it the XXX token before
 *  it interprets it as an identifier and looks it up
 *  in the library elements symbol table.
 */
};

const char *standard_robot_instructions[] = {
//Robot instructions
//   Robot movements
"PTP","Lin","Circ",
//   Settings
"Dyn","DynOvr","Ovl","Ramp","RefSys","Tool","OriMode",
//   System functions
"WaitTime","Stop","Info","Warning","Error",
/* end of array marker! Do not remove! */
NULL

/* Note (a):
 *  This function has a name equal to a reserved keyword.
 *  This means that adding it here is irrelevant because the
 *  lexical parser will consider it the XXX token before
 *  it interprets it as an identifier and looks it up
 *  in the library elements symbol table.
 */
};

int stage1_2(const char *filename, symbol_c **tree_root_ref) {
 /* if by any chance the library is not complete, we
   * now add the missing reserved keywords to the list!!!
   */

//Adding standard functions
  for(int i = 0; standard_function_names[i] != NULL; i++)
    if (library_element_symtable.find_value(standard_function_names[i]) ==
        library_element_symtable.end_value())
      library_element_symtable.insert(standard_function_names[i], standard_function_name_token);

//Adding standard robot instructions
  for(int i = 0; standard_robot_instructions[i] != NULL; i++)
    if (library_element_symtable.find_value(standard_robot_instructions[i]) ==
        library_element_symtable.end_value())
      library_element_symtable.insert(standard_robot_instructions[i], standard_robot_instruction_token);

#if YYDEBUG
  pro_yydebug = 1;
#endif
  
//Handle recursive robot_directory
  FILE *in_file = NULL;

  if((in_file = fopen(filename, "r")) == NULL) {
    char *errmsg = strdup2("Error opening main file ", filename);
    perror(errmsg);
    free(errmsg);
    return -1;
  }

  /* now parse the input file... */
  pro_yyin = in_file;
  pro_yylineno = 1;
  current_filename = filename;
  if (pro_yyparse() != 0)
    exit(EXIT_FAILURE);

  if (pro_yynerrs > 0) {
    fprintf (stderr, "\nFound %d error(s). Bailing out!\n", pro_yynerrs /* global variable */);
    exit(EXIT_FAILURE);
  }

  if (tree_root_ref != NULL)
    *tree_root_ref = tree_root;

  fclose(in_file);
  return 0;
}

