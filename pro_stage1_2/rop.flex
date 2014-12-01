
/*************************************************************/
/*************************************************************/
/*File Description  : Robot Program files interpreter with flex */
/*Author            : Wang Zhen                              */
/*Create Date       : 2014.06.20                             */
/*Last Update       : 2014.07.07                             */
/*************************************************************/
/*************************************************************/

/******************************************/
/******************************************/
/*Section 01  : Definitions...            */
/*Author      : Wang Zhen                 */
/*Create Date : 2014.06.20                */
/*Last Update : 2014.07.07               */
/******************************************/
/******************************************/

/******************************************/
/*Part 0101   : Lexical Parser Options... */
/*Author      : Wang Zhen                 */
/*Create Date : 2014.06.20                */
/*Last Update : 2014.07.07               */
/******************************************/

/* The lexical analyser will never work in interactive mode,
 * i.e., it will only process programs saved to files, and never
 * programs being written inter-actively by the user.
 * This option saves the resulting parser from calling the
 * isatty() function, that seems to be generating some compile
 * errors under some (older?) versions of flex.
 */
%option never-interactive

/* Have the lexical analyser use a 'char *pro_yytext' instead of an
 * array of char 'char pro_yytext[??]' to store the lexical token.
 */
%pointer

/* Have the generated lexical analyser keep track of the
 * line number it is currently analysing.
 * This is used to pass up to the syntax parser
 * the number of the line on which the current
 * token was found. It will enable the syntax parser
 * to generate more informatve error messages...
 */
%option yylineno

%option prefix = "pro_yy"

/***************************************************************/
/*Part 0102   : External Variable and Function declarations... */
/*Author      : Wang Zhen                                      */
/*Create Date : 2014.06.20                                     */
/*Last Update : 2014.07.07                                     */
/***************************************************************/

%{

/* Define TEST_MAIN to include a main() function.
 * Useful for testing the parser generated by flex.
 */
/*#define TEST_MAIN*/

/* Required for strdup() */
#include <string.h>

/* Required only for the declaration of abstract syntax classes
 * (class symbol_c; class token_c; class list_c;)
 * These will not be used in flex, but the token type union defined
 * in ro.tab.h contains pointers to these classes, so we must include
 * it here.
 */
#include "../absyntax/absyntax.hh"

/* generated by bison.
 * Contains the definition of the token constants, and the
 * token value type YYSTYPE (in our case, a 'const char *')
 */
#include "rop.y.hh"

/* Variable defined by the bison parser,
 * where the value of the tokens will be stored
 */
extern YYSTYPE pro_yylval;

/* The name of the file currently being parsed...
 * This variable is declared and read from the code generated by bison!
 */
extern const char *current_filename;

#define YY_NO_UNPUT

/* Variable defined by the bison parser.
 * It must be initialised with the location
 * of the token being parsed.
 * This is only needed if we want to keep
 * track of the locations, in order to give
 * more meaningful error messages!
 */
/*
extern YYLTYPE yylloc;
*/
/* Macro that is executed for every action.
 * We use it to pass the location of the token
 * back to the bison parser...
 */
/*
#define YY_USER_ACTION { 					\
	yylloc.first_line = yylloc.last_line = yylineno;	\
	yylloc.first_column = yylloc.last_column = 0;		\
	}
 */

//token_id_t get_identifier_token(const char *identifier_str);
int get_identifier_token(const char *identifier_str);
%}

/******************************************/
/*B 0   : Prelimenary constructs...       */
/*Author      : Wang Zhen                 */
/*Create Date : 2014.06.20                */
/*Last Update : 2014.07.07                */
/******************************************/

/*****************************/
/*  Whitespace and comments... */
/*****************************/
whitespace              [ \n\r\t\v]*
not_asterisk				[^*\n]
not_close_parenthesis_nor_asterisk	[^*/\n]
asterisk				"*"
comment_text            {not_asterisk}|(({asterisk}+){not_close_parenthesis_nor_asterisk})
line_comment            "//"{comment_text}*\n
lines_comment           "/*"(({comment_text}|\n)*)({asterisk}+)"/"
whitespace_comment      {whitespace}|{line_comment}|{lines_comment}

/*****************************************/
/* B.1.1 Letters, digits and identifiers */
/*****************************************/
letter           [A-Za-z]
digit            [0-9]
octal_digit      [0-7]
hex_digit        {digit}|[A-F]
identifier	 ({letter}|(_({letter}|{digit})))((_?({letter}|{digit}))*)

/*******************/
/* B.1.2 Constants */
/*******************/

/******************************/
/* B.1.2.1   Numeric literals */
/******************************/
integer          {digit}+
bit		 [0-1]
binary_integer   2#{bit}({bit}*)
octal_integer   8#{octal_digit}((_?{octal_digit})*)
hex_integer     16#{hex_digit}((_?{hex_digit})*)
EXP	         [Ee]([-+]?){integer}
real	         {integer}\.{integer}{EXP}?

/*******************************/
/* B.1.2.2   Character Strings */
/*******************************/
esc_char_u		$L|$N|$P|$R|$T
esc_char_l		$l|$n|$p|$r|$t
esc_char		$$|{esc_char_u}|{esc_char_l}
single_byte_char	(${hex_digit}{hex_digit})
/* WARNING:
 * This definition is only valid in ASCII...
 *
 * Flex includes the function print_char() that defines
 * all printable characters portably (i.e. whatever character
 * encoding is currently being used , ASCII, EBCDIC, etc...)
 * Unfortunately, we cannot generate the definition of
 * common_character_representation portably, since flex
 * does not allow definition of sets by subtracting
 * elements in one set from another set.
 * This means we must build up the defintion of
 * common_character_representation using only set addition,
 * which leaves us with the only choice of defining the
 * characters non-portably...
 */
common_character_representation		[\x20\x21\x23\x25\x26\x28-\x7E]|{esc_char}
character_representation 	        $'|\"|{single_byte_char}|{common_character_representation}
character_string	                \"({character_representation}*)\"


%%
       /*ATTENTION PLEASE! Comments should not be placed */
       /*at the first of lines!*/
       /*ATTENTION PLEASE! Comments should not be //! */
       /******************************************/
       /******************************************/
       /*Section 02  : Rules...                  */
       /*Author      : Wang Zhen                 */
       /*Create Date : 2014.06.20                */
       /*Last Update : 2014.07.07                */
       /******************************************/
       /******************************************/




       /******************************************/
       /******************************************/
       /******************************************/
       /******************************************/
       /*Part 0201   : First things first        */
       /*Author      : Wang Zhen                 */
       /*Create Date : 2014.06.10                */
       /*Last Update : 2014.07.10                */
       /******************************************/
       /******************************************/
       /******************************************/
       /******************************************/

	/*********************************/
	/* Handle all the state changes! */
	/*********************************/

	/***************************************/
	/* Next is to to remove all whitespace */
	/***************************************/

{whitespace_comment}   /* Eat any whitespace */







      /******************************************/
      /******************************************/
      /******************************************/
      /******************************************/
      /*Part 0202   : keywords...               */
      /*Author      : Wang Zhen                 */
      /*Create Date : 2014.06.10                */
      /*Last Update : 2014.07.10                */
      /******************************************/
      /******************************************/
      /******************************************/
      /******************************************/

        /******************************/
	/* B 1.2.1 - Numeric Literals */
	/******************************/

TRUE		return TRUE;
FALSE		return FALSE;

        /***********************************/
	/* B 2.1 Expressions               */
	/***********************************/

AND	      return AND;
XOR	      return XOR;
OR	      return OR;
NOT           return NOT;
"<"           return LT;
"<="          return LE;
">"           return GT;
">="          return GE;
"=="          return EQ;
"!="          return NE;

      /********************************/
      /* B 2.2  - Statements          */
      /********************************/

      /***********************************/
      /* B 2.2.1 - Assignment Statements */
      /***********************************/
=  	      return ASSIGN;

      /*******************************************/
      /* B 2.2.2 - Subprogram Control Statements */
      /*******************************************/
CALL          return CALL;

      /***********************************/
      /* B 2.2.3 - Selection Statements */
      /***********************************/
IF            return IF;
THEN          return THEN;
ELSE          return ELSE;
ELSEIF        return ELSEIF;
END_IF        return END_IF;

      /***********************************/
      /* B 2.2.4 - Iteration Statements */
      /***********************************/
WHILE         return WHILE;
DO            return DO;
END_WHILE     return END_WHILE;
LOOP          return LOOP;
END_LOOP      return END_LOOP;

        /******************************************/
        /******************************************/
        /******************************************/
        /******************************************/
        /*Part 0203   : Values...                 */
        /*Author      : Wang Zhen                 */
        /*Create Date : 2014.06.10                */
        /*Last Update : 2014.07.10                */
        /******************************************/
        /******************************************/
        /******************************************/
        /******************************************/

	/*****************************************/
	/* B 1.1 Identifiers                     */
	/*****************************************/

{identifier} 	{
		   pro_yylval.ID=strdup(pro_yytext);
                   /*printf("returning identifier...: %s, %d\n", yytext, get_identifier_token(yytext));*/
		   return get_identifier_token(yytext);
                }

	/******************************/
	/* B.1.2.1   Numeric literals */
	/******************************/
{integer}       {pro_yylval.ID=strdup(pro_yytext); return integer_token;}
{real}		{pro_yylval.ID=strdup(pro_yytext); return real_token;}
{binary_integer}	{pro_yylval.ID=strdup(pro_yytext); return binary_integer_token;}
{octal_integer} 	{pro_yylval.ID=strdup(pro_yytext); return octal_integer_token;}
{hex_integer} 		{pro_yylval.ID=strdup(pro_yytext); return hex_integer_token;}

	/*******************************/
	/* B.1.2.2   Character Strings */
	/*******************************/
{character_string} {pro_yylval.ID=strdup(pro_yytext); return character_string_token;}

        /* The end of the file ... */
<<EOF>>         {yyterminate();}
      





      /******************************************/
      /******************************************/
      /******************************************/
      /******************************************/
      /*Part 0204   : The leftovers...          */
      /*Author      : Wang Zhen                 */
      /*Create Date : 2014.06.10                */
      /*Last Update : 2014.07.10                */
      /******************************************/
      /******************************************/
      /******************************************/
      /******************************************/
     /* do the single character tokens...
      *  e.g.:  ':'  '('  ')'  ','  '+' '-' '*' '/'...
      */


.	       {return pro_yytext[0];}








%%

/******************************************/
/******************************************/
/*Section 03  : User Code...              */
/*Author      : Wang Zhen                 */
/*Create Date : 2014.06.20                */
/*Last Update : 2014.07.07                */
/******************************************/
/******************************************/

/*************************************************/
/*Part 0301   : Utility function definitions...  */
/*Author      : Wang Zhen                        */
/*Create Date : 2014.06.20                       */
/*Last Update : 2014.07.07                       */
/*************************************************/

/* Called by flex when it reaches the end-of-file */
int pro_yywrap(void)
{
  /* We reached the end of the input file... */

  /* Should we continue with another file? */
  /* If so:
   *   open the new file...
   *   return 0;
   */

  /* to we stop processing...
   *
   *   return 1;
   */


  return 1;  /* Stop scanning at end of input file. */
}

