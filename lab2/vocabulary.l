%option noyywrap
%option debug

%{
	#include <cstdio>
	#include <string>
	
	#include "parser.tab.h"
	#include "./custom/helpers.h"
%}

%%

[ \t\n]+							; /* do nothing */
"//".*                           	; /* single-line comment */ 
"/*"[^*]*[*]+([^*/][^*]*[*]+)*"/"	; /* multi-line comment */  

public|protected|private 									{ yylval.str_val = new std::string(yytext); return MODIFICATOR; }
byte|short|int|long|float|double|char|String|boolean|void	{ yylval.str_val = new std::string(yytext); return TYPE;		}
-?[0-9]+(\.[0-9]+)?											{ yylval.double_val = atof(yytext); return NUMBER;				}

"true"		{ yylval.bool_val = true; return BOOLEAN;	}
"false"		{ yylval.bool_val = false; return BOOLEAN;	}

"System.out.println"   return PRINT;

"package"	return PACKAGE;
"class"		return CLASS;

"if"		return IF;
"else"		return ELSE;
"for"		return FOR;
"while"		return WHILE;

"+"			return ADD;
"-"			return SUB;
"*"			return MUL;
"/"			return DIV;
"="			return ASSIGN;

"++"		return INCREMENT;
"--"		return DECREMENT;

"+="		return SUM_AND_EQUAL;
"-="		return SUB_AND_EQUAL;
"*="		return MUL_AND_EQUAL;
"/="		return DIV_AND_EQUAL;

">"			return GREATER;
"<"			return LESS;
"!"			return NOT;

"=="		return EQUALS;
">="		return GREATER_OR_EQUALS;
"<="		return LESS_OR_EQUALS;
"!="		return NOT_EQUALS;

"&&"		return AND;
"||"		return OR;

"."			return DOT;
","			return COMMA;

":"			return COLON;
";"			return SEMI_COLON;
"("			return LEFT_BKT;
")"			return RIGHT_BKT;
"{"			return LEFT_BRACE;
"}"			return RIGHT_BRACE;
"["			return LEFT_SQUARE_BKT;
"]"			return RIGHT_SQUARE_BKT;

[a-zA-Z0-9]+		{ yylval.str_val = new std::string(yytext); return VARIABLE; 		}
[a-zA-Z0-9._]+		{ yylval.str_val = new std::string(yytext); return PACKAGE_NAME; 	}
.					{ yyerror("Undefined symbol"); }

%%