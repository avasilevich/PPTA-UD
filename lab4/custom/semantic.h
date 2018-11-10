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
	int value;
	bool initizalized;
};

struct Method {
	std::string name;
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

struct Method* getMainMethod()
{
	struct MethodListNode* workNode = methodList;

	while(workNode)
    {
		struct Method* method = workNode->method;

		if(method->isRootMethod) {
			return method;			
		}

        workNode = workNode->next;
    }

    return NULL;
}

struct Method* getMethod(std::string methodName)
{
	struct MethodListNode* workNode = methodList;

	while(workNode)
    {
		std::string workNodeMethodName = workNode->method->name;

		if(!workNodeMethodName.compare(methodName)) {
			return workNode->method;			
		}

        workNode = workNode->next;
    }

    return NULL;
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