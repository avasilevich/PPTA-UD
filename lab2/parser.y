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

%union {
	int index;
	double num;
}

/* delcare tokens */
%token<num> NUMBER
%token<num> INTEGER

%%

/* test */
assignment: 
		| NUMBER { }
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