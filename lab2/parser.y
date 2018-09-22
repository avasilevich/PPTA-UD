%{
	#include <stdio.h>
	#include <stdlib.h>
	#include <string.h>
	#include <math.h>

	#include "parser.tab.h"

	/* flex functions */
	extern int yylex(void);
	extern void yyterminate();

	void yyerror(const char *s);

	extern FILE* yyin;
%}

/* %union is used to specify a variety of data types. */
%union {
	int index;
	double num;
}

/* delcare tokens */
%token<num> NUMBER
%token<num> DIV MUL SUM SUB ASSIGN
%token<num> LEFT_BKT RIGHT_BKT
%token<num> INTEGER DOUBLE STRING VOID
%token<num> PUBLIC PROTECTED PRIVATE
%token<num> PACKAGE
%token<num> CLASS
%token<num> STATIC
%token<num> IF ELSE
%token<num> FOR WHILE DO
%token<num> SWITCH CASE DEFAULT
%token<num> INCREMENT DECREMENT
%token<num> SUM_AND_EQUAL SUB_AND_EQUAL MUL_AND_EQUAL DIV_AND_EQUAL
%token<num> GREATER LESS NOT
%token<num> EQUALS GREATER_OR_EQUALS LESS_OR_EQUALS NOT_EQUALS
%token<num> AND OR
%token<num> DOT COMMA
%token<num> COLON SEMI_COLON
%token<num> LEFT_BRACE RIGHT_BRACE
%token<num> LEFT_SQUARE_BKT RIGHT_SQUARE_BKT
%token<num> VARIABLE
%token<num> EOL

/* priority for the operations */
%left SUB
%left ADD
%left MUL
%left DIV

%left LEFT_BKT RIGHT_BKT

%%

/* test */
assignment: 
		| PACKAGE { }
		;

%%

int main(int argc, char **argv)
{
	if(argc > 1) {
  		if(!(yyin = fopen(argv[1], "r"))) {
			perror(argv[1]);
			return 1;
		}
 	}

	yyparse();
}

/* Display error messages */
void yyerror(const char *s)
{
	printf("ERROR: %s\n", s);
}