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

	if(method->operations != NULL) {
		printOperations(method->operations, 0);
	} else {
		printf(" empty.");
	}

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
				case _ASSIGNMENT_OP:
					std::cout << "assignment: " << rightNode->value.var->name << " = ";
					printTree(rightNode->right);
					break;
				case _IF_STMT:
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
				case _WHILE_STMT:
					printf("WHILE: ");
					printTree(rightNode->left);
					printOperations(rightNode->right, depth+1);
					break;
				case _PRINT_FUNC:
					printf("PRINT var: ");
					std::cout << rightNode->value.var->name;
					break;
				case _CUSTOM_FUNC_CALL:
					std::cout << rightNode->value.method->name << "(..)";
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

	if((root->nodeType < 0) || (root->nodeType > 1 && root->nodeType < _CUSTOM_FUNC_CALL) 
		|| (root->nodeType > _CUSTOM_FUNC_CALL && root->nodeType < _ADD_SYM) || (root->nodeType > 47)) 
	{
		return;	
	} 	
	  
	printTree(root->left);
	
	switch(root->nodeType)
	{
		case _ADD_SYM:
			printf("+");
			break;
		case _SUB_SYM:
			printf("-");
			break;
		case _MUL_SYM:
			printf("*");
			break;
		case _DIV_SYM:
			printf("/");
			break;
		case _ASSIGN_SYM:
			printf("=");
			break;
		case _ST:
			printf("<");
			break;
		case _GT:
			printf(">");
			break;
		case _STE:
			printf("<=");
			break;
		case _GTE:
			printf(">=");
			break;
		case _EQ:
			printf("==");
			break;
		case _NEQ:
			printf("!=");
			break;
		case _NOT:
			printf("!");
			break;
		case _OR:
			printf("||");
			break;
		case _AND:
			printf("&&");
			break;
		case _SUB_OP:
			printf("-");
			printTree(root->right); 
			return;
		case _CUSTOM_FUNC_CALL:
			printf("call %s()", root->value.method->name.c_str());
			return;
		case _VAR:
			printf("%s", root->value.var->name.c_str());
			break;
		case _CONST:
			printf("%d", root->value.constant->value.intValue);
			break;
	}
		
	printTree(root->right);
}
