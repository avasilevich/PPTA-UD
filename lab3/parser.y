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

	const bool DEBUG_MODE = true;

	extern int yylex();
	extern void yyerror(const char *s);

	void addMethod();
	void addClassVar(std::string name, std::string modificator, std::string type, double value, bool initizalized);
	void addMethodVar(std::string name, std::string modificator, std::string type, double value, bool initizalized);
	void setMethodVarValue(std::string name, double value);
	
	void setVarName(std::string varName);
	void setClassName(std::string className);
	
	void printClass();
	void printVar(YY_F::Variable var);
	void printMethod(YY_F::Method method);

	bool isClassVarExists(std::string varName);
	bool isNonVoidMethodExists(std::string methodName);
	bool isLocalMethodVarExists(std::string varName);
	bool isVariableInvalid(std::string varName);

	double getValueForVariable(std::string varName);
	double getReturnedValueOfMethod(std::string methodName);
	void printData(double value);

	void DivZeroError();
	void UnknownVarError(std::string s);
	void UnknownMethodError(std::string s);
	void ReturnTypeMethodError(std::string s);
	void InitializationVarError(std::string s);
	void DuplicateMethodError(std::string s);

	extern FILE* yyin;

	YY_F::OwnClass myClass;
	YY_F::Variable tempVar;
	YY_F::Method tMethod;

	std::map<std::string, YY_F::Variable> localMethodVars;
%}

%union {
	int     int_val;
	double  double_val;
	std::string* str_val;
	bool    bool_val;
}

/* delcare tokens */
%token<double_val> NUMBER
%token<str_val> VARIABLE PACKAGE_NAME PRINT FUNC_CALL
%token<str_val> MODIFICATOR TYPE STATIC
%token<int_val> ADD SUB DIV MUL ASSIGN
%token<int_val> LEFT_BKT RIGHT_BKT
%token<int_val> PACKAGE CLASS
%token<int_val> LEFT_BRACE RIGHT_BRACE
%token<int_val> COLON SEMI_COLON
%token<int_val> GT ST EQ NEQ GTE STE 
%token<int_val> AND OR NOT
%token<bool_val> BOOLEAN
%token<int_val> EOL

%token<int_val> INCREMENT DECREMENT
%token<int_val> SUM_AND_EQUAL SUB_AND_EQUAL MUL_AND_EQUAL DIV_AND_EQUAL
%token<int_val> COMMA
%token<int_val> LEFT_SQUARE_BKT RIGHT_SQUARE_BKT

%token IF ELSE FOR WHILE RETURN_ACTION DOT

%type <double_val> exp;
%type <double_val> subexp;
%type <double_val> lowerexp;
%type <double_val> assignment;
%type <double_val> return_action;

%type <bool_val> bool_exp;
%type <bool_val> bool_inner;
%type <bool_val> bool_subinner;
%type <bool_val> condition;

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
						| if_stmt
						| print_stmt
						;

class_var_declaration:	  MODIFICATOR TYPE assignment				{ addClassVar(tempVar.name, *$1, *$2, $3, tempVar.initizalized); 		}
						| TYPE assignment							{ addClassVar(tempVar.name, "private", *$1, $2, tempVar.initizalized); 	}
						| MODIFICATOR TYPE VARIABLE declaration_end { addClassVar(*$3, *$1, *$2, 0, false); 		}
						| TYPE VARIABLE declaration_end 			{ addClassVar(*$2, "private", *$1, 0, false); 	}
						;

func_declaration:	  	  MODIFICATOR func_sub_def			{ tMethod.modificator = *$1; addMethod(); 								}
						| MODIFICATOR STATIC func_sub_def 	{ tMethod.modificator = *$1; tMethod.isRootMethod = true; addMethod();	}
						| func_sub_def						{ tMethod.modificator = "private"; addMethod(); 						}
						;

return_action:			  RETURN_ACTION	exp declaration_end	{ $$ = $2; };	

func_sub_def: 			  TYPE VARIABLE LEFT_BKT RIGHT_BKT LEFT_BRACE func_lines return_action RIGHT_BRACE  { tMethod.returnType = *$1; tMethod.name = *$2; tMethod.returnValue = $7; } 
						| TYPE VARIABLE LEFT_BKT RIGHT_BKT LEFT_BRACE func_lines RIGHT_BRACE 				{ tMethod.returnType = *$1; tMethod.name = *$2; tMethod.returnValue = 0;  } 
						;

func_lines:				| func_lines common_line
						| common_line
						;

var_declaration: 	  	  TYPE assignment				{ addMethodVar(tempVar.name, "none", *$1, $2, tempVar.initizalized); }
						| assignment					{ setMethodVarValue(tempVar.name, $1); }
						| TYPE VARIABLE declaration_end	{ addMethodVar(*$2, "none", *$1, 0, false); }
						;

assignment:				  VARIABLE ASSIGN exp declaration_end		{ $$ = $3; tempVar.name = *$1; tempVar.initizalized = true; };

exp:			  	  	  exp ADD subexp	               			{ $$ = $1 + $3; }
 						| exp SUB subexp							{ $$ = $1 - $3; }
 						| subexp									{ $$ = $1; 		}
 						| bool_exp									{ $$ = $1; 		}
 						;

subexp:			  	  	  subexp MUL lowerexp						{ $$ = $1 * $3;										}		
						| subexp DIV lowerexp						{ if($3 == 0) DivZeroError(); else $$ = $1 / $3; 	}
						| lowerexp									{ $$ = $1; 									 		}
						;

lowerexp:		  	  	  LEFT_BKT exp RIGHT_BKT									{ $$ = $2; }
						| NUMBER													{ $$ = $1; }
						| VARIABLE 													{ if(!isVariableInvalid(*$1)) $$ = getValueForVariable(*$1); }
						| FUNC_CALL VARIABLE LEFT_BKT RIGHT_BKT						{ if(isNonVoidMethodExists(*$2)) $$ = getReturnedValueOfMethod(*$2); }
						;

bool_exp:   			  NOT bool_exp         		{ $$ = !$2;		 }
				        | bool_exp AND bool_inner 	{ $$ = $1 && $3; }
				        | bool_inner               	{ $$ = $1; 		 }
				        ;

bool_inner:   			  bool_inner OR bool_subinner   	{ $$ = $1 || $3; }
           				| bool_subinner            			{ $$ = $1;   	 }
           				;

bool_subinner: 			  BOOLEAN                   	{ $$ = $1; }
          				| condition                		{ $$ = $1; }
          				| LEFT_BKT bool_exp RIGHT_BKT	{ $$ = $2; }
          				; /* Expand an expression within parents */

condition:				  exp GT exp 	{ $$ = $1 > $3;	 }
						| exp GTE exp 	{ $$ = $1 >= $3; }
						| exp ST exp 	{ $$ = $1 < $3;	 }
						| exp STE exp 	{ $$ = $1 <= $3; }
						| exp EQ exp 	{ $$ = $1 == $3; }
						| exp NEQ exp 	{ $$ = $1 != $3; }
						;

if:						  IF LEFT_BKT condition RIGHT_BKT LEFT_BRACE func_lines RIGHT_BRACE	{ std::cout << "---------------------------------------------" << $3 << std::endl;  if($3) { $5; } };

if_else:				  if ELSE LEFT_BRACE func_lines RIGHT_BRACE { if(true) { $3; } };

else_if:				  ELSE if;

if_stmt:				  if
       					| if_else
        				| if else_if
        				;


print_stmt:				  PRINT LEFT_BKT exp RIGHT_BKT declaration_end	{ printData($3); /*printf("%.2f\n", $3);*/  };
package:				  PACKAGE PACKAGE_NAME declaration_end			{ myClass.package = *$2; };

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

void UnknownMethodError(std::string s) {
	printf("Error: %s method does not exist!\n", s.c_str());
}

void ReturnTypeMethodError(std::string s) {
	printf("Error: %s method has void return type!\n", s.c_str());
}

void InitializationVarError(std::string s) {
	printf("Error: %s is not initizalized!\n", s.c_str());
}

void DuplicateMethodError(std::string s) {
	printf("Error: %s is duplicated!\n", s.c_str());
}

void addMethod() {
	if(myClass.methods.count(tMethod.name)) {
		std::string retType1 = myClass.methods[tMethod.name].returnType;
		std::string retType2 = tMethod.returnType;

		if(!strcmp(retType1.c_str(), retType2.c_str())) {
			DuplicateMethodError(tMethod.name);
			localMethodVars.clear();
			return;
		}
	}

	tMethod.vars = localMethodVars;
	localMethodVars.clear();
	
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

void addMethodVar(std::string name, std::string modificator, std::string type, double value, bool initizalized) {
	YY_F::Variable var;
	
	var.name = name;
	var.modificator = modificator;
	var.type = type;
	var.value = value;
	var.initizalized = initizalized;

	localMethodVars.insert(std::pair<std::string,YY_F::Variable>(var.name, var));
	printVar(var);
}

void setMethodVarValue(std::string name, double value) {
	if (!isLocalMethodVarExists(name)) {
		UnknownVarError(name);
	} else {
		localMethodVars[name].value = value;
		localMethodVars[name].initizalized = true;
	}
}

void printVar(YY_F::Variable var) {
	std::cout << std::endl; 
	std::cout << "\n+++++++++++ Variable info ++++++++++" << std::endl;
	std::cout << "+ name: " << var.name << std::endl;
	std::cout << "+ modificator: " << var.modificator << std::endl;
	std::cout << "+ type: " << var.type << std::endl;
	std::cout << "+ value: " << var.value << std::endl;
	std::cout << "+ initizalized: " << (var.initizalized ? "yes" : "no") << "\n" << std::endl;
}

void printMethod(YY_F::Method method) {
	std::cout << std::endl; 
	std::cout << "\n----------- Method info ----------" << std::endl;
	std::cout << "+ name: " << method.name << std::endl;
	std::cout << "+ modificator: " << method.modificator << std::endl;
	std::cout << "+ returnType: " << method.returnType << std::endl;
	std::cout << "+ returnValue: " << method.returnValue << std::endl;
	std::cout << "+ isRoot: " << (method.isRootMethod ? "yes" : "no") << std::endl;
	std::cout << "+ vars (" << method.vars.size() << "): ";

	for (std::map<std::string, YY_F::Variable>::iterator it = method.vars.begin(); it != method.vars.end(); ++it)
    	std::cout << it->first << " | ";

    std::cout << "\n" << std::endl;
}

void printClass() {
	std::cout << "\n----------- Class info ----------" << std::endl;
	std::cout << "+ name: " << myClass.name << std::endl;
	std::cout << "+ package: " << myClass.package << std::endl;

	std::cout << "+ vars (" << myClass.vars.size() << "): ";
	for (std::map<std::string, YY_F::Variable>::iterator it = myClass.vars.begin(); it != myClass.vars.end(); ++it)
    	std::cout << it->first << " | ";

    std::cout << std::endl;

	std::cout << "+ methods (" << myClass.methods.size() << "): ";
	for (std::map<std::string, YY_F::Method>::iterator it = myClass.methods.begin(); it != myClass.methods.end(); ++it)
    	std::cout << it->first << " | ";
   
    std::cout << "\n" << std::endl;
}

void setClassName(std::string className) {
	myClass.name = className;
}

void setVarName(std::string varName) {
	tempVar.name = varName;
}

bool isClassVarExists(std::string varName) {
	return myClass.vars.count(varName);
}

bool isLocalMethodVarExists(std::string varName) {
	return localMethodVars.count(varName);
}

bool isNonVoidMethodExists(std::string methodName) {
	if(!myClass.methods.count(methodName)) {
		UnknownMethodError(methodName);
		return false;
	} else if(!strcmp("void", myClass.methods[methodName].returnType.c_str())) {
		ReturnTypeMethodError(methodName);
		return false;
	} else {
		return true;
	}
}

bool isVariableInvalid(std::string varName) {
	if (!isClassVarExists(varName) && !isLocalMethodVarExists(varName)) {
		UnknownVarError(varName);
		return true;
	} else if (isLocalMethodVarExists(varName) && !localMethodVars[varName].initizalized) {
		InitializationVarError(varName);
		return true;
	} else if (isClassVarExists(varName) && !myClass.vars[varName].initizalized) {
		InitializationVarError(varName);
		return true;
	} else {
		return false;
	}
}

double getValueForVariable(std::string varName) {
	if (isLocalMethodVarExists(varName)) {
		return localMethodVars[varName].value;
	} else {
		return myClass.vars[varName].value;
	}
}

double getReturnedValueOfMethod(std::string methodName) {
	return myClass.methods[methodName].returnValue;
}

void printData(double value) {
	if(DEBUG_MODE) {
		std::cout << value << std::endl;
	}
}