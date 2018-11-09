%debug

%{
	#include <cstdio>
	#include <string>
	#include <cstring>
	#include <stdlib.h>
	#include <iostream>

	int labelCount = 0;
	int currentCycle = 0;
	int errors = 0;
	int tempLineIndex = 0;

	struct NodeValue
	{
		struct Node *node;
		struct Variable *var;
		struct Constant *constant;
		struct Method *method;
		struct VarListNode *classVars;
	};

	struct Node
	{
		int nodeType;
		struct NodeValue value;
		struct Node *left;
		struct Node *right;
	};

	struct Variable {
		std::string name;
		std::string type;
		std::string modificator;
		float value;
		bool initizalized;
	};

	struct Method {
		std::string name;
		std::string returnType;
		float returnValue;
		std::string modificator;
		bool isRootMethod;
		struct Node *operations;
		struct VarListNode *vars;
	};

	struct Constant
	{
	    char type;
		int strIndex;
	    union
	    {
	        unsigned int intValue;
	        char charValue;
	    } value;
	};

	struct MethodListNode
	{
	    struct Method *method;
	    struct MethodListNode *next;
	};

	struct VarListNode
	{
	    struct Variable *var;
	    struct VarListNode *next;
	};

	struct Variable *tempVar = NULL;
	struct Method *tempMethod = NULL;
	struct VarListNode *curVarList = NULL;
	struct VarListNode *classVarsList = NULL;

	struct MethodListNode* methodList = NULL;

	extern FILE* yyin;

	extern int yylex();
	extern void yyerror(const char *s);

	/* semantic functions */
	struct Node* getNode(char nodeType, struct Node* left, struct Node* right);
	struct Method* addMethod();
	struct VarListNode* addClassVarToList();
	struct VarListNode* addMethodVarToList();
	struct Variable* getLocalVar(std::string varName);
	struct Variable* getClassVar(std::string varName);
	struct Variable* getVar(std::string varName);

	/* show & print functions */
	void showClassInfo();
	void showClassMethods();
	void printOperations(struct Node *operations, int depth);
	void printSpaces(int num);
	void showMethodInfo(struct Method *method);
	void printVarDeclarations(struct VarListNode *varList);
	void printTree(struct Node *root);

	/* code generation functions */
	int generateCode();
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
%token IF ELSE FOR WHILE RETURN_ACTION DOT COMMA

//%type <double_val> return_action;

%start parse_tree

%%

parse_tree:				  package class_stmt;

class_stmt:		  	  	  MODIFICATOR class_sub_stmt
						| class_sub_stmt
						;

class_sub_stmt:			  CLASS VARIABLE LEFT_BRACE lines RIGHT_BRACE { /*setClassName(*$2); */ };

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
								std::cout << "line " << tempLineIndex << ": variable ";
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
						// TODO | if_stmt
						;


var_declaration:	common_var_first_part ASSIGN NUMBER SEMI_COLON
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
							tempMethod->returnType = *$<str>1.token; 
							tempMethod->name = *$<str>2.token; 
							tempMethod->returnValue = 0;
							tempLineIndex = $<str>2.index;
						};

statement:				  logic_expr 						{ $<node>$ = $<node>1; }
						| VARIABLE ASSIGN logic_expr
						{
							struct Variable* var = getLocalVar(*$<str>1.token);

							if(var == NULL)
							{
								struct Variable* classVar = getClassVar(*$<str>1.token);

								if(classVar == NULL)
								{
									std::cout << "line " << $<str>1.index << ": variable ";
									std::cout << $<str>1.token << " undeclared." << std::endl;
									
									$<node>$ = NULL;
									errors++;
								} else {
									$<node>$ = getNode(7, NULL, $<node>3);
									$<node>$->value.var = classVar;
								}
							} else {
								$<node>$ = getNode(7, NULL, $<node>3);
								$<node>$->value.var = var;
							}
						};

logic_expr:				  logic_or_expr 				{ $<node>$ = $<node>1; }
						| logic_expr NEQ logic_or_expr	{ $<node>$ = getNode(40, $<node>1, $<node>3); }
						| logic_expr ST logic_or_expr	{ $<node>$ = getNode(35, $<node>1, $<node>3); }
						| logic_expr GT logic_or_expr 	{ $<node>$ = getNode(36, $<node>1, $<node>3); }
						| logic_expr EQ logic_or_expr 	{ $<node>$ = getNode(39, $<node>1, $<node>3); }
						| logic_expr STE  logic_or_expr	{ $<node>$ = getNode(37, $<node>1, $<node>3); }
						| logic_expr GTE logic_or_expr 	{ $<node>$ = getNode(38, $<node>1, $<node>3); }
						;

logic_or_expr:		  	  logic_and_expr					{ $<node>$ = $<node>1; }
						| logic_or_expr OR logic_and_expr	{ $<node>$ = getNode(42, $<node>1, $<node>3); }
						;	

logic_and_expr:		  	  plus_expr						{ $<node>$ = $<node>1; }
						| logic_and_expr AND plus_expr	{ $<node>$ = getNode(43, $<node>1, $<node>3); }
						;

plus_expr:  			  mul_expr						{ $<node>$ = $<node>1; }
						| plus_expr ADD mul_expr		{ $<node>$ = getNode(30, $<node>1, $<node>3); }
						| plus_expr SUB mul_expr 		{ $<node>$ = getNode(31, $<node>1, $<node>3); }
						;

mul_expr: 				  unary_expr					{ $<node>$ = $<node>1; }
						| mul_expr MUL unary_expr   	{ $<node>$ = getNode(32, $<node>1, $<node>3); }
						| mul_expr DIV unary_expr 		{ $<node>$ = getNode(33, $<node>1, $<node>3); }
						;

unary_expr:				  addend 						{ $<node>$ = $<node>1; }
						| SUB unary_expr 				{ $<node>$ = getNode(45, NULL, $<node>2); }
						| unary_expr INCREMENT 			{ $<node>$ = getNode(46, NULL, $<node>1); }
						| unary_expr DECREMENT 			{ $<node>$ = getNode(47, NULL, $<node>1); }
						| NOT unary_expr 				{ $<node>$ = getNode(41, NULL, $<node>2); }
						;

addend:					VARIABLE
						{
							struct Variable* var = getVar(*$<str>1.token);

							if(var == NULL)
							{
								std::cout << "line " << $<str>1.index << ": variable ";
								std::cout << $<str>1.token << " undeclared." << std::endl;
								
								$<node>$ = NULL;
								errors++;
							} else {
								$<node>$ = getNode(0, NULL, NULL);
								$<node>$->value.var = var;
							}
						}
						| NUMBER
						{
							struct Constant* constant = (struct Constant*)malloc(sizeof(struct Constant));
							constant->type = 0;
							constant->value.intValue = $<number>1;
							
							$<node>$ = getNode(1, NULL, NULL);
							$<node>$->value.constant = constant;
						};

func_operators:			{ $<node>$ = NULL; }
						| func_operators common_line { $<node>$ = getNode(3, $<node>1, $<node>2); }
						;

print_stmt: 			PRINT LEFT_BKT VARIABLE RIGHT_BKT SEMI_COLON		
						{ 
							struct Variable *var = getVar(*$<str>3.token);

							if(var == NULL)
							{
								std::cout << "line " << $<str>1.index << ": variable ";
								std::cout << $<str>1.token << " undeclared." << std::endl;
								
								$<node>$ = NULL;
								errors++;
							} else {
								$<node>$ = getNode(12, NULL, NULL);
								$<node>$->value.var = var;
							}
						};

package:			    PACKAGE PACKAGE_NAME SEMI_COLON			{ /*myClass.package = *$2;*/ 	};

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

	showClassInfo();
	generateCode();
	return 0;
}

int generateCode()
{
	FILE *file;
	file = fopen("lab4.asm", "w");
	
	fprintf(file, "\n\nSECTION .data\n");	
	//writeALLVarDeclarations(file);
	fprintf(file, "\n\n\nSECTION .text\n\nglobal _main");	
	//writeFunctions(file);	
	
	fclose(file);
	return 1;
}

struct Node* getNode(char nodeType, struct Node* left, struct Node* right)
{
	struct Node* node = (struct Node*)malloc(sizeof(struct Node));
    
    node->nodeType = nodeType;
    node->left = left;
    node->right = right;

    return node;
}

struct VarListNode* addClassVarToList()
{	
	struct VarListNode *workNode = classVarsList;

	while(workNode)
	{
		std::string workNodeVarName = workNode->var->name;
		std::string tempVarName = tempVar->name;

		// if var already exists, then error will be shown
		if(!workNodeVarName.compare(tempVarName)) {
			return NULL;			
		}

		workNode = workNode->next;
	}

	// create empty list for vars
    struct VarListNode *listNode = (struct VarListNode *)malloc(sizeof(struct VarListNode));
    listNode->next = NULL;
    listNode->var = tempVar;
			
	workNode = classVarsList;

	// if list is not empty ==> add to end of list
    if(workNode)
    {
        while(workNode->next) {
            workNode = workNode->next;
        }
			
        workNode->next = listNode;
    } 
    else // add as first list item
    {
        classVarsList = listNode;
    }

	return listNode;
}

struct VarListNode* addMethodVarToList()
{
	struct VarListNode *workNode = curVarList;

	while(workNode)
	{
		// TODO add check "initialized" flag
		std::string workNodeVarName = workNode->var->name;
		std::string tempVarName = tempVar->name;

		// if local var already exists, then return null
		if(!workNodeVarName.compare(tempVarName)) {
			return NULL;			
		}

		workNode = workNode->next;
	}

	// create empty list for vars
    struct VarListNode *listNode = (struct VarListNode *)malloc(sizeof(struct VarListNode));
    listNode->next = NULL;
    listNode->var = tempVar;
			
	workNode = curVarList;

	// if list is not empty ==> add to end of list
    if(workNode)
    {
        while(workNode->next) {
            workNode = workNode->next;
        }
			
        workNode->next = listNode;
    } 
    else // add as first list item
    {
        curVarList = listNode;
    }

	return listNode;
}

struct Method* addMethod()
{
	struct MethodListNode* workNode = methodList;

	while(workNode)
    {
		std::string workNodeMethodName = workNode->method->name;
		std::string tempMethodName = tempMethod->name;

		// if method already exists, then error will be shown
		if(!workNodeMethodName.compare(tempMethodName)) {
			return NULL;			
		}

        workNode = workNode->next;
    }

    struct MethodListNode* methodNode = (struct MethodListNode*)malloc(sizeof(struct MethodListNode));
    methodNode->method = tempMethod;
    methodNode->next = NULL;

    workNode = methodList;

    if(workNode)
    {
        while(workNode->next) {
            workNode = workNode->next;
        }
			
        workNode->next = methodNode;
    }
    else
    {
        methodList = methodNode;
    }

    return tempMethod;
}

struct Variable* getLocalVar(std::string varName)
{
	struct VarListNode *varListHead = curVarList;

	while(varListHead)
	{
		if(!varName.compare(varListHead->var->name)) {
			return varListHead->var;
		}

		varListHead = varListHead->next;
	}

	return NULL;
}

struct Variable* getClassVar(std::string varName)
{
	struct VarListNode *varListHead = classVarsList;

	while(varListHead)
	{
		if(!varName.compare(varListHead->var->name)) {
			return varListHead->var;
		}

		varListHead = varListHead->next;
	}

	return NULL;
}

struct Variable* getVar(std::string varName)
{
	struct Variable* var = getLocalVar(varName);

	if(var == NULL) {
		var = getClassVar(varName);
	}

	return var;
}

void showClassInfo() 
{
	printf("\n++++++++++Class variables:++++++++++\n");
	printVarDeclarations(classVarsList);
	showClassMethods();
}

void showClassMethods()
{
	struct MethodListNode* workNode = methodList;

	printf("\n_______Class methods declarations:_______");

	if(workNode == NULL) {
		printf("\nEmpty list.");
		return;
	}

	while(workNode)
	{
		showMethodInfo(workNode->method);
		workNode = workNode->next;
	}
}

void showMethodInfo(struct Method *method)
{
	std::cout << "\n:::Method[" << method->name << "]:" << std::endl;
	std::cout << "Variable declarations:";

	printVarDeclarations(method->vars);
	
	std::cout << "\nOperations:";

	printOperations(method->operations, 0);
	printf("\n");
}

void printSpaces(int num)
{
	int i;
	printf("\n");
	for(i = 0; i < num; i++)
		printf("   ");
}

void printOperations(struct Node *operations, int depth)
{
	struct Node *rightNode;
	struct Node *workNode = operations;
	
	while(workNode)
	{
		printSpaces(depth);
		rightNode = workNode->right;

		if(rightNode)
		{
			switch(rightNode->nodeType)
			{
				case 7:
					std::cout << "assignment: " << rightNode->value.var->name << " = ";
					printTree(rightNode->right);
					break;
				case 9:  // for
					printf("FOR: ");
					printTree(rightNode->left); printf("; ");
					printTree(rightNode->right->left); printf("; ");
					printTree(rightNode->right->right);
					
					printOperations(rightNode->value.node, depth+1);						
					break;
				case 10: // if
					printf("IF: ");
					printTree(rightNode->value.node);
					printOperations(rightNode->left, depth+1);	
					
					if(rightNode->right)
					{
						printSpaces(depth);
						printf("ELSE:");
						printOperations(rightNode->right, depth+1);
					}
					break;
				case 11: // while
					printf("WHILE: ");
					printTree(rightNode->left);
					printOperations(rightNode->right, depth+1);
					break;
				case 12: // print
					printf("PRINT var: ");
					std::cout << rightNode->value.var->name;
					break;
				case 14: // function call
					std::cout << rightNode->value.method->name << "(..)";
					break;
				case 15: // return
					printf("RETURN ");
					printTree(rightNode->right);
					break;
				default:
					printTree(rightNode);
			}
		}
		
		workNode = workNode->left;
	}
}

void printVarDeclarations(struct VarListNode *varList)
{
	struct VarListNode* workNode = varList;

	if(workNode == NULL) {
		printf(" empty");
	}

	while(workNode)
	{
		struct Variable* var = workNode->var;

		std::cout << " " << var->name << "[" << var->type << "]";
		
		if(workNode->next != NULL)	{
			printf(",");
		}

		workNode = workNode->next;
	}

	printf(".\n");
}

void printTree(struct Node *root)
{
	if(!root) { return; }

	if((root->nodeType < 0) || (root->nodeType > 1 && root->nodeType < 14) 
		|| (root->nodeType > 14 && root->nodeType < 30)	|| (root->nodeType > 47)) 
	{
		return;	
	} 	
	  
	printTree(root->left);
	
	switch(root->nodeType)
	{
		case 30:
			printf("+");
			break;
		case 31:
			printf("-");
			break;
		case 32:
			printf("*");
			break;
		case 33:
			printf("/");
			break;
		case 34:
			printf("=");
			break;
		case 35:
			printf("<");
			break;
		case 36:
			printf(">");
			break;
		case 37:
			printf("<=");
			break;
		case 38:
			printf(">=");
			break;
		case 39:
			printf("==");
			break;
		case 40:
			printf("!=");
			break;
		case 41:
			printf("!");
			break;
		case 42:
			printf("||");
			break;
		case 43:
			printf("&&");
			break;
		case 45:
			printf("-");
			printTree(root->right); 
			return;
		case 14:
			printf("%s(..)", root->value.method->name.c_str());
			return;
		case 0:
			printf("%s", root->value.var->name.c_str());
			break;
		case 1:
			printf("%d", root->value.constant->value.intValue);
			break;
	}
		
	printTree(root->right);
}
