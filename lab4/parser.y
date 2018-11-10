/*%debug*/

%{
	#include "./custom/headers.h"
	#include "./custom/semantic.h"
	#include "./custom/printers.h"
	#include "./custom/generator.h"
	
	extern FILE* yyin;

	extern int yylex();
	extern void yyerror(const char *s);
%}

%union {
    struct Node* node;
	struct 
	{
		std::string* token;
		int index;
	} str;
	
	bool bool_val;
	float number;
}

/* delcare tokens */
%token NUMBER VARIABLE PACKAGE_NAME PRINT FUNC_CALL
%token MODIFICATOR TYPE STATIC PACKAGE CLASS 
%token LEFT_BKT RIGHT_BKT LEFT_BRACE RIGHT_BRACE
%token COLON SEMI_COLON GT ST EQ NEQ GTE STE 
%token AND OR NOT BOOLEAN EOL INCREMENT DECREMENT
%token ADD SUB DIV MUL ASSIGN LEFT_SQUARE_BKT RIGHT_SQUARE_BKT
%token SUM_AND_EQUAL SUB_AND_EQUAL MUL_AND_EQUAL DIV_AND_EQUAL
%token IF ELSE FOR WHILE RETURN_ACTION BREAK DOT COMMA

%start parse_tree

%%

parse_tree:				package class_stmt;

class_stmt:		  	  	  MODIFICATOR class_sub_stmt
						| class_sub_stmt
						;

class_sub_stmt:		    CLASS VARIABLE LEFT_BRACE lines RIGHT_BRACE;

lines:					| lines line
						| line
						;

line:					| class_var_declaration
						{
							struct VarListNode *varList = addClassVarToList();

							if(varList == NULL)	
							{				
								std::cout << "line " << tempLineIndex << ": variable ";
								std::cout << tempVar->name << " redeclared." << std::endl;
								errors++;
							}

							tempVar = NULL;
						}
						| func_declaration LEFT_BRACE func_operators RIGHT_BRACE
						{
							struct Method* method = addMethod();
				
							if(method == NULL)
							{
								std::cout << "line " << tempLineIndex << ": method ";
								std::cout << tempMethod->name << " redeclared." << std::endl;
								errors++;
							}
							
							struct Node *tempNode = getNode(-1, NULL, NULL);
							tempNode->value.method = method;

							if(tempNode->value.method != NULL) {
								struct Method *m = tempNode->value.method;
								m->operations = $<node>3;
								m->vars = curVarList;
							}

							curVarList = NULL;
							tempMethod = NULL;
						};

common_line:	  	  	var_declaration
						{
							struct VarListNode *varList = addMethodVarToList();

							if(varList == NULL)	
							{				
								std::cout << "line " << tempLineIndex << ": local variable ";
								std::cout << tempVar->name << " redeclared." << std::endl;
								errors++;
							}

							tempVar = NULL;
						}
						| statement SEMI_COLON		{ $<node>$ = $<node>1; }
						| print_stmt				{ $<node>$ = $<node>1; }
						| if_stmt					{ $<node>$ = $<node>1; }
						| while_stmt				{ $<node>$ = $<node>1; }
						| BREAK	SEMI_COLON			{ $<node>$ = getNode(_BREAK, NULL, NULL); }
						;


var_declaration:		common_var_first_part ASSIGN NUMBER SEMI_COLON
						{
							tempVar->value = $<number>3;
							tempVar->initizalized = true;
						};

class_var_declaration: 	MODIFICATOR common_var_first_part ASSIGN NUMBER SEMI_COLON 
						{
							tempVar->modificator = *$<str>1.token;
							tempVar->value = $<number>4;
							tempVar->initizalized = true;
						}
						| MODIFICATOR common_var_first_part SEMI_COLON
						{
							tempVar->modificator = *$<str>1.token;
							tempVar->initizalized = false;
						}
						| common_var_first_part ASSIGN NUMBER SEMI_COLON
						{
							tempVar->modificator = "private";
							tempVar->value = $<number>4;
							tempVar->initizalized = true;
						}
						| common_var_first_part SEMI_COLON
						{
							tempVar->modificator = "private";
							tempVar->initizalized = false;
						};

common_var_first_part:	TYPE VARIABLE
						{
							tempVar = (struct Variable *)malloc(sizeof(struct Variable));
							tempVar->type = *$<str>1.token;
							tempVar->name = *$<str>2.token;
							tempLineIndex = $<str>2.index;
						};

func_declaration:	  	  MODIFICATOR func_sub_def			{ tempMethod->modificator = *$<str>1.token;  									}
						| MODIFICATOR STATIC func_sub_def 	{ tempMethod->modificator = *$<str>1.token; tempMethod->isRootMethod = true;	}
						| func_sub_def						{ tempMethod->modificator = "private"; 											}
						;

func_sub_def:			TYPE VARIABLE LEFT_BKT RIGHT_BKT					
						{ 
							tempMethod = (struct Method *)malloc(sizeof(struct Method));
							tempMethod->name = *$<str>2.token; 
							tempLineIndex = $<str>2.index;
						};

statement:				  logic_expr 							{ $<node>$ = $<node>1; }
						| VARIABLE ASSIGN logic_expr
						{
							struct Variable* var = getLocalVar(*$<str>1.token);

							if(var == NULL)
							{
								struct Variable* classVar = getClassVar(*$<str>1.token);

								if(classVar == NULL)
								{
									std::cout << "line " << $<str>1.index << ": variable ";
									std::cout << *$<str>1.token << " undeclared." << std::endl;
									
									$<node>$ = NULL;
									errors++;
								} else {
									$<node>$ = getNode(_ASSIGNMENT_OP, NULL, $<node>3);
									$<node>$->value.var = classVar;
								}
							} else {
								$<node>$ = getNode(_ASSIGNMENT_OP, NULL, $<node>3);
								$<node>$->value.var = var;
							}
						};

logic_expr:				  logic_or_expr 				{ $<node>$ = $<node>1; }
						| logic_expr NEQ logic_or_expr	{ $<node>$ = getNode(_NEQ, $<node>1, $<node>3); }
						| logic_expr ST logic_or_expr	{ $<node>$ = getNode(_ST, $<node>1, $<node>3); }
						| logic_expr GT logic_or_expr 	{ $<node>$ = getNode(_GT, $<node>1, $<node>3); }
						| logic_expr EQ logic_or_expr 	{ $<node>$ = getNode(_EQ, $<node>1, $<node>3); }
						| logic_expr STE  logic_or_expr	{ $<node>$ = getNode(_STE, $<node>1, $<node>3); }
						| logic_expr GTE logic_or_expr 	{ $<node>$ = getNode(_GTE, $<node>1, $<node>3); }
						;

logic_or_expr:		  	  logic_and_expr					{ $<node>$ = $<node>1; }
						| logic_or_expr OR logic_and_expr	{ $<node>$ = getNode(_OR, $<node>1, $<node>3); }
						;	

logic_and_expr:		  	  plus_expr						{ $<node>$ = $<node>1; }
						| logic_and_expr AND plus_expr	{ $<node>$ = getNode(_AND, $<node>1, $<node>3); }
						;

plus_expr:  			  mul_expr						{ $<node>$ = $<node>1; }
						| plus_expr ADD mul_expr		{ $<node>$ = getNode(_ADD_SYM, $<node>1, $<node>3); }
						| plus_expr SUB mul_expr 		{ $<node>$ = getNode(_SUB_SYM, $<node>1, $<node>3); }
						;

mul_expr: 				  unary_expr					{ $<node>$ = $<node>1; }
						| mul_expr MUL unary_expr   	{ $<node>$ = getNode(_MUL_SYM, $<node>1, $<node>3); }
						| mul_expr DIV unary_expr 		{ $<node>$ = getNode(_DIV_SYM, $<node>1, $<node>3); }
						;

unary_expr:				  addend 						{ $<node>$ = $<node>1; }
						| SUB unary_expr 				{ $<node>$ = getNode(_SUB_OP, NULL, $<node>2); }
						| NOT unary_expr 				{ $<node>$ = getNode(_NOT, NULL, $<node>2); }
						;

addend:					VARIABLE
						{
							struct Variable* var = getVar(*$<str>1.token);

							if(var == NULL)
							{
								std::cout << "line " << $<str>1.index << ": variable ";
								std::cout << *$<str>1.token << " undeclared." << std::endl;
								
								$<node>$ = NULL;
								errors++;
							} else {
								$<node>$ = getNode(_VAR, NULL, NULL);
								$<node>$->value.var = var;
							}
						}
						| NUMBER
						{
							struct Constant* constant = (struct Constant*)malloc(sizeof(struct Constant));
							constant->type = 0;
							constant->value.intValue = $<number>1;
							
							$<node>$ = getNode(_CONST, NULL, NULL);
							$<node>$->value.constant = constant;
						}
						| FUNC_CALL VARIABLE LEFT_BKT RIGHT_BKT
						{
							struct Method* method = getMethod(*$<str>2.token);
							
							if(method == NULL)	
							{			
								std::cout << "line " << $<str>2.index << ": method ";
								std::cout << *$<str>2.token << " undeclared." << std::endl;
								errors++;
							}
							else
							{
								$<node>$ = getNode(_CUSTOM_FUNC_CALL, NULL, NULL);
								$<node>$->value.method = method;
							}
						};

func_operators:			  { $<node>$ = NULL; }
						| common_line func_operators  
						{ 
							struct Node *operations = getNode(3, $<node>2, $<node>1); 
							$<node>$ =  operations;
						};

print_stmt: 			PRINT LEFT_BKT VARIABLE RIGHT_BKT SEMI_COLON		
						{ 
							struct Variable *var = getVar(*$<str>3.token);

							if(var == NULL)
							{
								std::cout << "line " << $<str>1.index << ": variable ";
								std::cout << *$<str>1.token << " undeclared." << std::endl;
								
								$<node>$ = NULL;
								errors++;
							} else {
								$<node>$ = getNode(_PRINT_FUNC, NULL, NULL);
								$<node>$->value.var = var;
							}
						};

if_stmt:				IF LEFT_BKT logic_expr RIGHT_BKT inside_code ELSE inside_code 
						{
							$<node>$ = getNode(_IF_STMT, $<node>5, $<node>7);	
							$<node>$->value.node = $<node>3;
						}
						| IF LEFT_BKT logic_expr RIGHT_BKT inside_code
						{
							$<node>$ = getNode(_IF_STMT, $<node>5, NULL);	
							$<node>$->value.node = $<node>3;
						};

while_stmt:				WHILE LEFT_BKT logic_expr RIGHT_BKT inside_code
						{
							$<node>$ = getNode(_WHILE_STMT, $<node>3, $<node>5);	
						};

inside_code:			  LEFT_BRACE func_operators RIGHT_BRACE 	{ $<node>$ = $<node>2; }
					    | common_line 								{ $<node>$ = getNode(3, NULL, $<node>1); }
					    ;

package:			    PACKAGE PACKAGE_NAME SEMI_COLON;

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

	if(errors > 0) { 
		return -1; 
	}	

	//showClassInfo();
	generateCode();
	return 0;
}