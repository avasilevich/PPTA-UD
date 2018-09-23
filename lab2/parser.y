%debug

%{
	#include <cstdio>
	#include <string>
	#include <stdlib.h>
	#include <map>
	#include "parser.tab.h"

	std::map<std::string, double> vars;   // map from variable name to value
	std::string package_name;

	/* flex functions */
	extern int yylex(void);
	extern void yyterminate();

	void Div0Error(void);
	void UnknownVarError(std::string s);
	void yyerror(const char *s);

	extern FILE* yyin;
%}

/* %union is used to specify a variety of data types. */
%union {
	int     int_val;
	double  double_val;
	std::string* str_val;
	bool    bool_val;
}

/* delcare tokens */
%token<double_val> NUMBER
%token<bool_val> BOOLEAN
%token<str_val> VARIABLE PACKAGE_NAME PRINT
%token<int_val> ADD SUB DIV MUL ASSIGN
%token<int_val> LEFT_BKT RIGHT_BKT
%token<int_val> PUBLIC PROTECTED PRIVATE
%token<int_val> PACKAGE CLASS STATIC
%token<int_val> INCREMENT DECREMENT
%token<int_val> SUM_AND_EQUAL SUB_AND_EQUAL MUL_AND_EQUAL DIV_AND_EQUAL
%token<int_val> GREATER LESS NOT
%token<int_val> EQUALS GREATER_OR_EQUALS LESS_OR_EQUALS NOT_EQUALS
%token<int_val> AND OR
%token<int_val> DOT COMMA
%token<int_val> COLON SEMI_COLON
%token<int_val> LEFT_BRACE RIGHT_BRACE
%token<int_val> LEFT_SQUARE_BKT RIGHT_SQUARE_BKT
%token<int_val> EOL

%token IF ELSE FOR WHILE TYPE

%type <double_val> exp;
%type <double_val> subexp;
%type <double_val> lowerexp;

%start parsetree

%%

parsetree:		package lines;

lines:			  lines line 
				| line
				;

line:			/* empty */
				| declaration
				| print_stmt
				;	

declaration:	  TYPE assignment
				| assignment
				;

assignment:		VARIABLE ASSIGN exp declaration_end			{ vars[*$1] = $3; delete $1; };

exp:			  exp ADD subexp	               			{ $$ = $1 + $3; }
 				| exp SUB subexp							{ $$ = $1 - $3; }
 				| subexp									{ $$ = $1; 		}
 				;

subexp:			  subexp MUL lowerexp						{ $$ = $1 * $3;									}		
				| subexp DIV lowerexp						{ if($3 == 0) Div0Error(); else $$ = $1 / $3; 	}
				| lowerexp									{ $$ = $1; 									 	}
				;

lowerexp:		  LEFT_BKT exp RIGHT_BKT					{ $$ = $2; }
				| NUMBER									{ $$ = $1; }
				| VARIABLE 									{ if (!vars.count(*$1)) UnknownVarError(*$1); else $$ = vars[*$1]; delete $1; }
				;

print_stmt:			PRINT LEFT_BKT exp RIGHT_BKT SEMI_COLON		{ printf("%.4f\n", $3); };
package:			PACKAGE PACKAGE_NAME SEMI_COLON				{ package_name = *$2; 	};

declaration_end:	SEMI_COLON;

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

void Div0Error(void) {
	printf("Error: division by zero\n"); exit(0);
}

void UnknownVarError(std::string s) {
	printf("Error: %s does not exist!\n", s.c_str()); exit(0);
}