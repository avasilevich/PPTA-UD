%debug

%{
	#include <cstdio>
	#include <string>
	#include <cstring>
	#include <stdlib.h>
	#include <map>
	#include <iostream>
	#include <vector>
	#include "./custom/definitions.h"

	extern int yylex();
	extern void yyerror(const char *s);

	void addMethod();
	void addClassVar(std::string name, std::string modificator, std::string type, double value, bool initizalized);
	void setVarName(std::string varName);
	void setClassName(std::string className);
	void printClass();
	void printVar(YY_F::Variable var);
	void printMethod(YY_F::Method method);

	void DivZeroError();
	void UnknownVarError(std::string s);
	void InitializationVarError(std::string s);

	extern FILE* yyin;

	std::string package_name;

	YY_F::OwnClass myClass;
	YY_F::Variable tempVar;
	YY_F::Method tMethod;
%}

%union {
	int     int_val;
	double  double_val;
	std::string* str_val;
	bool    bool_val;
}

/* delcare tokens */
%token<double_val> NUMBER
%token<str_val> VARIABLE PACKAGE_NAME PRINT
%token<str_val> MODIFICATOR TYPE
%token<int_val> ADD SUB DIV MUL ASSIGN
%token<int_val> LEFT_BKT RIGHT_BKT
%token<int_val> PACKAGE CLASS
%token<int_val> LEFT_BRACE RIGHT_BRACE
%token<int_val> COLON SEMI_COLON
%token<int_val> EOL

%token<bool_val> BOOLEAN
%token<int_val> INCREMENT DECREMENT
%token<int_val> SUM_AND_EQUAL SUB_AND_EQUAL MUL_AND_EQUAL DIV_AND_EQUAL
%token<int_val> GREATER LESS NOT
%token<int_val> EQUALS GREATER_OR_EQUALS LESS_OR_EQUALS NOT_EQUALS
%token<int_val> AND OR
%token<int_val> DOT COMMA
%token<int_val> LEFT_SQUARE_BKT RIGHT_SQUARE_BKT

%token IF ELSE FOR WHILE

%type <double_val> exp;
%type <double_val> subexp;
%type <double_val> lowerexp;
%type <double_val> assignment;

%start parse_tree

%%

parse_tree:				  package class_stmt;

class_stmt:		  	  	  MODIFICATOR class_sub_stmt
						| class_sub_stmt
						;

class_sub_stmt:			  CLASS VARIABLE LEFT_BRACE lines RIGHT_BRACE { setClassName(*$2); printClass(); };

lines:					| lines line
						| line
						;

line:					| class_var_declaration
						| func_declaration
						;

common_line:	  	  	  var_declaration
						| print_stmt
						;

class_var_declaration:	  MODIFICATOR TYPE assignment				{ addClassVar(tempVar.name, *$1, *$2, $3, tempVar.initizalized); 		}
						| TYPE assignment							{ addClassVar(tempVar.name, "private", *$1, $2, tempVar.initizalized); 	}
						| MODIFICATOR TYPE VARIABLE declaration_end { addClassVar(*$3, *$1, *$2, 0, false); 		}
						| TYPE VARIABLE declaration_end 			{ addClassVar(*$2, "private", *$1, 0, false); 	}
						;

func_declaration:	  	  MODIFICATOR func_sub_def	{ tMethod.modificator = *$1; addMethod(); 			}
						| func_sub_def				{ tMethod.modificator = "private"; addMethod(); 	}
						;

func_sub_def: 			  TYPE VARIABLE LEFT_BKT RIGHT_BKT LEFT_BRACE func_lines RIGHT_BRACE { tMethod.returnType = *$1; tMethod.name = *$2; };

func_lines:				| func_lines common_line
						| common_line
						;

var_declaration: 	  	  TYPE assignment
						| assignment
						;

assignment:				  VARIABLE ASSIGN exp declaration_end		{ $$ = $3; tempVar.name = *$1; tempVar.initizalized = true; };

exp:			  	  	  exp ADD subexp	               			{ $$ = $1 + $3; }
 						| exp SUB subexp							{ $$ = $1 - $3; }
 						| subexp									{ $$ = $1; 		}
 						;

subexp:			  	  	  subexp MUL lowerexp						{ $$ = $1 * $3;										}		
						| subexp DIV lowerexp						{ if($3 == 0) DivZeroError(); else $$ = $1 / $3; 	}
						| lowerexp									{ $$ = $1; 									 		}
						;

lowerexp:		  	  	  LEFT_BKT exp RIGHT_BKT					{ $$ = $2; }
						| NUMBER									{ $$ = $1; }
						| VARIABLE 									{ if (!myClass.vars.count(*$1)) UnknownVarError(*$1); else if (!myClass.vars[*$1].initizalized) InitializationVarError(*$1); else $$ = myClass.vars[*$1].value; }
						;

print_stmt:				  PRINT LEFT_BKT exp RIGHT_BKT SEMI_COLON	{ printf("%.2f\n", $3); };
package:				  PACKAGE PACKAGE_NAME SEMI_COLON			{ package_name = *$2; 	};

declaration_end:		  SEMI_COLON;

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

void DivZeroError() {
	printf("Error: division by zero\n");
}

void UnknownVarError(std::string s) {
	printf("Error: %s does not exist!\n", s.c_str());
}

void InitializationVarError(std::string s) {
	printf("Error: %s is not initizalized!\n", s.c_str());
}

void printClass() {
	std::cout << "----------- Class info ----------" << std::endl;
	std::cout << "+ name: " << myClass.name << std::endl;
}

void addMethod() {
	myClass.methods.insert(std::pair<std::string,YY_F::Method>(tMethod.name, tMethod));
	printMethod(tMethod);
}

void addClassVar(std::string name, std::string modificator, std::string type, double value, bool initizalized) {
	YY_F::Variable var;
	
	var.name = name;
	var.modificator = modificator;
	var.type = type;
	var.value = value;
	var.initizalized = initizalized;

	myClass.vars.insert(std::pair<std::string,YY_F::Variable>(var.name, var));
	printVar(var);
}

void printVar(YY_F::Variable var) {
	std::cout << std::endl; 
	std::cout << "+++++++++++ Variable info ++++++++++" << std::endl;
	std::cout << "+ name: " << var.name << std::endl;
	std::cout << "+ modificator: " << var.modificator << std::endl;
	std::cout << "+ type: " << var.type << std::endl;
	std::cout << "+ value: " << var.value << std::endl;
	std::cout << "+ initizalized: " << (var.initizalized ? "yes" : "no") << "\n" << std::endl;
}

void printMethod(YY_F::Method method) {
	std::cout << std::endl; 
	std::cout << "----------- Method info ----------" << std::endl;
	std::cout << "+ name: " << method.name << std::endl;
	std::cout << "+ modificator: " << method.modificator << std::endl;
	std::cout << "+ returnType: " << method.returnType << "\n" << std::endl;
}

void setClassName(std::string className) {
	myClass.name = className;
}

void setVarName(std::string varName) {
	tempVar.name = varName;
}