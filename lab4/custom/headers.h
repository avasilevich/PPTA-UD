#include <cstdio>
#include <string>
#include <cstring>
#include <stdlib.h>
#include <iostream>

#define _VAR 0
#define _CONST 1
#define _ASSIGNMENT_OP 7
#define _IF_STMT 10
#define _PRINT_FUNC 12
#define _FUNC_CALL 14
#define _ADD_SYM 30
#define _SUB_SYM 31
#define _MUL_SYM 32
#define _DIV_SYM 33
#define _ASSIGN_SYM 34

#define _ST 35
#define _GT 36
#define _STE 37
#define _GTE 38
#define _EQ 39
#define _NEQ 40
#define _NOT 41
#define _OR 42
#define _AND 43

#define _SUB_OP 45

int errors = 0;
int tempLineIndex = 0;

/* semantic functions */
struct Node* getNode(char nodeType, struct Node* left, struct Node* right);
struct Method* addMethod();
struct Method* getMainMethod();
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