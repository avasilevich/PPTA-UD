%option noyywrap 
%option yylineno

%{
	#include <stdio.h>

	int yylval;
	int yylval_double;

    int yycolno = 1;
%}

%%
-?[0-9]+         { yylval = atoi(yytext); printf("NUMBER %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
-?[0-9]+\.[0-9]+ { yylval_double = atof(yytext); printf("NUMBER %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"//"+[^\n]*      { printf("SINGLE-LINE COMMENT %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);}
"/*"[\w\s]*"*/"  { printf("MULTI-LINE COMMENT %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);  }

Integer		{ printf("%s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);  }
Double		{ printf("%s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);  }
String		{ printf("%s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);  }
void		{ printf("%s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);  }

func		{ printf("FUNCTION %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
import		{ printf("IMPORT %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
static		{ printf("STATIC %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
class		{ printf("CLASS %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
public		{ printf("MODIFICATOR %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
private		{ printf("MODIFICATOR %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }

"-"		{ printf("SUB %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"+"		{ printf("SUM %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"*"		{ printf("MUL %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"/"		{ printf("DIV %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }

"++"		{ printf("INCREMENT %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"--"		{ printf("DECREMENT %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }

"+="		{ printf("SUM_AND_EQUAL %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"-="		{ printf("SUB_AND_EQUAL %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"*="		{ printf("MUL_AND_EQUAL %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"/="		{ printf("DIV_AND_EQUAL %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }

"="		{ printf("EQUALS %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);  }
">"		{ printf("GREATER %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"<"		{ printf("LESS %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);    }
"!"		{ printf("NOT %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);     }

"=="		{ printf("EQUALS %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);	         }
">="		{ printf("GREATER_OR_EQUALS %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"<="		{ printf("LESS_OR_EQUALS %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);    }
"!="		{ printf("NOT_EQUALS %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);	 }

"&&"		{ printf("AND_OPERATOR %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"||"		{ printf("OR_OPERATOR %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);  }

"." 		{ printf("DOT %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);             }
","		{ printf("COMMA %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);            }
":"		{ printf("COLON %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);            }
";"		{ printf("SEMICOLON %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);        }
"("		{ printf("LEFT_BKT %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);         }
")"		{ printf("RIGHT_BKT %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);        }
"{"		{ printf("LEFT_BRACE %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);       }
"}"		{ printf("RIGHT_BRAC %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);       }
"["		{ printf("LEFT_SQUARE_BKT %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);  }
"]"		{ printf("RIGHT_SQUARE_BKT %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }

[a-zA-Z0-9]+\(\) { printf("FUNCTION NAME %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);  }
[a-zA-Z0-9]+     { printf("VARIABLE NAME %s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);  }
\n	             { yycolno = 1; }
.		         { printf("SYMBOL '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);            }

%%

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

	yylex();
}
 
