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
	struct VarListNode *curVarList = NULL;

	struct MethodListNode* methodList = NULL;

	extern FILE* yyin;

	extern int yylex();
	extern void yyerror(const char *s);

	/* semantic functions */
	struct VarListNode* AddClassVarToList();

	/* show & print functions */
	void showClassMethods();
	void showMethodInfo(struct Method *method);
	void printVarDeclarations(struct VarListNode *varList);

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

%start parse_tree

%%

parse_tree:				  package class_stmt;

class_stmt:		  	  	  MODIFICATOR class_sub_stmt
						| class_sub_stmt
						;

class_sub_stmt:			  CLASS VARIABLE LEFT_BRACE lines RIGHT_BRACE { /*setClassName(*$2); printClass(); */ };

lines:					| lines line
						| line
						;

line:					| class_var_declaration
						{
							struct VarListNode *varList = AddClassVarToList();

							if(varList == NULL)	
							{				
								printf("\nline %d: variable %s redeclared\n", tempLineIndex, tempVar->name.c_str());
								errors++;
							}
						};

class_var_declaration: 	MODIFICATOR initialized_class_var 
						{
							tempVar->modificator = *$<str>1.token;
						}
						| MODIFICATOR not_initialized_class_var
						{
							tempVar->modificator = *$<str>1.token;
						}
						| initialized_class_var
						{
							tempVar->modificator = "private";
						}
						| not_initialized_class_var
						{
							tempVar->modificator = "private";
						};

not_initialized_class_var:	class_var_first_part SEMI_COLON
							{
								tempVar->initizalized = false;
							};

initialized_class_var:	class_var_first_part ASSIGN NUMBER SEMI_COLON
						{
							tempVar->value = $<number>3;
							tempVar->initizalized = true;
						};	

class_var_first_part:	TYPE VARIABLE
						{
							tempVar = (struct Variable *)malloc(sizeof(struct Variable));
							tempVar->type = *$<str>1.token;
							tempVar->name = *$<str>2.token;
							tempLineIndex = $<str>2.index;
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

	showClassMethods();
	
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

struct VarListNode* AddClassVarToList()
{	
	struct VarListNode *workNode = curVarList;

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
    struct  VarListNode *listNode = (struct VarListNode *)malloc(sizeof(struct VarListNode));
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

void showClassMethods()
{
	struct MethodListNode* workNode = methodList;

	while(workNode)
	{
		showMethodInfo(workNode->method);
		workNode = workNode->next;
	}
}

void showMethodInfo(struct Method *method)
{
	printf("\nMethod[%s]:", method->name.c_str());
	// printType(func->type);
	
	printf("\nVariable declarations: ");
	printVarDeclarations(method->vars);
	
	//printf("\nOperators: ");
	//printOperators(method->operations, 0);
	printf("\n\n");
}

void printVarDeclarations(struct VarListNode *varList)
{
	struct VarListNode* workNode = varList;

	while(workNode)
	{
		struct Variable* var = workNode->var;

		// printType(var->type);
		printf(" %s", var->name.c_str());
		
		if(workNode->next != NULL)	{
			printf(", ");
		}

		workNode = workNode->next;
	}
}