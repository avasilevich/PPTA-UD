%option noyywrap
%option debug

%{
	#include <cstdio>
	#include <string>
	
	#include "parser.tab.h"
	#include "./custom/helpers.h"
	int lineIndex = 1;
%}

%%

[ \t\n]+							; /* do nothing */
"//".*                           	; /* single-line comment */ 
"/*"[^*]*[*]+([^*/][^*]*[*]+)*"/"	; /* multi-line comment */  

public|protected|private 									{ yylval.str.token = new std::string(yytext); yylval.str.index = lineIndex; return MODIFICATOR; }
byte|short|int|long|float|double|char|String|boolean|void	{ yylval.str.token = new std::string(yytext); yylval.str.index = lineIndex; return TYPE;		}
-?[0-9]+(\.[0-9]+)?											{ yylval.number = atof(yytext); return NUMBER;				}
"this->"													{ return FUNC_CALL; 	}

"true"		{ yylval.bool_val = true; return BOOLEAN;	}
"false"		{ yylval.bool_val = false; return BOOLEAN;	}

"System.out.println"   return PRINT;

"package"	return PACKAGE;
"class"		return CLASS;
"static"	return STATIC;
"return"	return RETURN_ACTION;

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

"!"			return NOT;

">"			return GT;
"<"			return ST;
"=="		return EQ;
">="		return GTE;
"<="		return STE;
"!="		return NEQ;

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

[a-zA-Z0-9]+		{ yylval.str.token = new std::string(yytext); yylval.str.index = lineIndex; return VARIABLE; 		}
[a-zA-Z0-9._]+		{ yylval.str.token = new std::string(yytext); yylval.str.index = lineIndex; return PACKAGE_NAME; 	}
.					{ yyerror("Undefined symbol"); }

%%