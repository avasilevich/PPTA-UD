%{

	#include <stdio.h>

	/* flex functions */
	extern int yylex(void);
	extern void yyterminate();

	void yyerror(const char *s);
%}

/* delcare tokens */

main(argc, argv)
int argc;
char **argv;
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