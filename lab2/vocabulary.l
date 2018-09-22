%option noyywrap
%option debug

%{
	#include "parser.tab.h"
	#include "./custom/helpers.h"
%}

%%

[ \t]
-?[0-9]+(\.[0-9]+)?		{ yylval.num = atof(yytext); return NUMBER;	}

"//".*                           	{ /* single-line comment */ }
"/*"[^*]*[*]+([^*/][^*]*[*]+)*"/"	{ /* multi-line comment */  }

Integer		{ return INTEGER;	}
Double		{ return DOUBLE;	}
String		{ return STRING;	}
void		{ return VOID;		}

package		{ return PACKAGE;	}
static		{ return STATIC;	}
class		{ return CLASS;		}
public		{ return PUBLIC;	}
private		{ return PRIVATE;	}
protected	{ return PROTECTED;	}

if			{ return IF;		}
else		{ return ELSE;		}
for			{ return FOR;		}
while		{ return WHILE;		}
do			{ return DO;		}
switch		{ return SWITCH;	}
case		{ return CASE;		}
default		{ return DEFAULT;	}

"+"			{ return SUM;	}
"-"			{ return SUB;	}
"*"			{ return MUL;	}
"/"			{ return DIV;	}
"="			{ return ASSIGN;	}

"++"		{ return INCREMENT;	}
"--"		{ return DECREMENT;	}

"+="		{ return SUM_AND_EQUAL; }
"-="		{ return SUB_AND_EQUAL; }
"*="		{ return MUL_AND_EQUAL; }
"/="		{ return DIV_AND_EQUAL; }

">"			{ return GREATER;	}
"<"			{ return LESS;		}
"!"			{ return NOT;		}

"=="		{ return EQUALS;			}
">="		{ return GREATER_OR_EQUALS;	}
"<="		{ return LESS_OR_EQUALS;	}
"!="		{ return NOT_EQUALS;		}

"&&"		{ return AND;	}
"||"		{ return OR;	}

"."			{ return DOT;				}
","			{ return COMMA;				}

":"			{ return COLON;				}
";"			{ return SEMI_COLON;		}

"("			{ return LEFT_BKT;			}
")"			{ return RIGHT_BKT;			}

"{"			{ return LEFT_BRACE;		}
"}"			{ return RIGHT_BRACE;		}

"["			{ return LEFT_SQUARE_BKT;	}
"]"			{ return RIGHT_SQUARE_BKT;	}

[a-zA-Z0-9]+	{ yylval.index = addNewVariable(yytext); return VARIABLE; /* add validation for existing variable name */ }
[\n]			{ return EOL; }
.				{ yyerror("Undefined symbol"); exit(1); }

%%