%option noyywrap 
%option yylineno

%{
	#include <stdio.h>

	int yylval;
	int yylval_double;

    int yycolno = 1;
%}

%%
-?[0-9]+			{ yylval = atoi(yytext); printf("number '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);        }
-?[0-9]+\.[0-9]+	{ yylval_double = atof(yytext); printf("doule number '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }

"//".*                           	{ printf("comment '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);            }
"/*"[^*]*[*]+([^*/][^*]*[*]+)*"/"	{ printf("multi-line comment '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }

Integer		{ printf("type '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
Double		{ printf("type '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
String		{ printf("type '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
void		{ printf("type '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }

package		{ printf("%s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
static		{ printf("%s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
class		{ printf("%s was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
public		{ printf("modificator '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
private		{ printf("modificator '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
protected	{ printf("modificator '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }

if			{ printf("condition '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
else		{ printf("condition '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
for			{ printf("operator '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
while		{ printf("operator '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
do			{ printf("operator '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
switch		{ printf("operator '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
case		{ printf("operator '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
default		{ printf("operator '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }

"-"			{ printf("sub '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"+"			{ printf("sum '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"*"			{ printf("mul '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"/"			{ printf("div '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }

"++"		{ printf("increment '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"--"		{ printf("decrement '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }

"+="		{ printf("operator '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"-="		{ printf("operator '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"*="		{ printf("operator '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"/="		{ printf("operator '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }

"="			{ printf("operator '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
">"			{ printf("operator '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"<"			{ printf("operator '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"!"			{ printf("operator '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }

"=="		{ printf("operator '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
">="		{ printf("operator '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"<="		{ printf("operator '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"!="		{ printf("operator '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }

"&&"		{ printf("operator '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"||"		{ printf("operator '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }

"." 		{ printf("dot '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
","			{ printf("comma '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
":"			{ printf("colon '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
";"			{ printf("semicolon '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"("			{ printf("left bkt '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
")"			{ printf("right bkt '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"{"			{ printf("left brace '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"}"			{ printf("right brace '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"["			{ printf("left square bkt '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }
"]"			{ printf("right square bkt '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }

[a-zA-Z0-9]+\(\) { printf("functon '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext);       }
[a-zA-Z0-9]+     { printf("token '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }

\n	{ yycolno = 1; }
.	{ printf("token '%s' was found at line #%d and column #%d\n", yytext, yylineno, yycolno); yycolno += strlen(yytext); }

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
 
