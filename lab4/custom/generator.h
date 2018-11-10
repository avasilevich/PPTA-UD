int labelCount = 0;
int currentCycle = 0;

/* code generation functions */
int generateCode();

void writeALLVarDeclarations(FILE *file);
void writeMethodVarDeclarations(FILE *file, struct Method *method);
void writeClassVarDeclarations(FILE *file);
void writeMethods(FILE *file);
void writeMethodOperators(FILE *file, struct Method *method, struct Node *operators);
void writeLogicTree(FILE *file, struct Method* method, struct Node *root);

/* implementation */
int generateCode()
{
	FILE *file;
	file = fopen("lab4.asm", "w");

	fprintf(file, "extern printf");	

	fprintf(file, "\n\nSECTION .data\n");	
	fprintf(file, "\nformat db \"%%d\",10,0\n");

	writeALLVarDeclarations(file);

	fprintf(file, "\n\nglobal main");	
	fprintf(file, "\n\nSECTION .text\n");	
	writeMethods(file);	
	
	fclose(file);
	return 1;
}

void writeALLVarDeclarations(FILE *file)
{
	struct MethodListNode* workNode = methodList;

	writeClassVarDeclarations(file);

	while(workNode)
	{
		writeMethodVarDeclarations(file, workNode->method);	
		workNode = workNode->next;
	}
}

void writeMethodVarDeclarations(FILE *file, struct Method *method)
{
	struct VarListNode* workNode = method->vars;

	while(workNode)
	{
		struct Variable* var = workNode->var;
		fprintf(file, "\n%s_%s:  ", method->name.c_str(), var->name.c_str());
		fprintf(file, "dd %d", var->value);

		workNode = workNode->next;
	}
}

void writeClassVarDeclarations(FILE *file)
{
	struct VarListNode *workNode = classVarsList;

	while(workNode)
	{
		struct Variable* var = workNode->var;
		fprintf(file, "\nclass_var_%s:  ", var->name.c_str());
		fprintf(file, "dd %d", var->value);

		workNode = workNode->next;
	}

	fprintf(file, "\n");
}

void writeMethods(FILE *file)
{
	fprintf(file, "\n\nmain:");
	struct Method *mainMethod = getMainMethod();

	writeMethodOperators(file, mainMethod, mainMethod->operations);	
	fprintf(file, "\nret");	
	
	struct MethodListNode* workNode = methodList;

	while(workNode)
	{
		if(!workNode->method->isRootMethod) {
			fprintf(file, "\n\n%s:", workNode->method->name.c_str());
			writeMethodOperators(file, workNode->method, workNode->method->operations);
			fprintf(file, "\nret");
		}

		workNode = workNode->next;		
	}
}

void writeMethodOperators(FILE *file, struct Method *method, struct Node *operators)
{
	struct Node* rightNode;
	struct Node* workNode = operators;
	
	while(workNode)
	{		
		rightNode = workNode->right;

		if(rightNode)
		{  
			switch(rightNode->nodeType)
			{			
				case _ASSIGNMENT_OP:
					writeLogicTree(file, method, rightNode->right);
					fprintf(file, "\npop eax");
					fprintf(file, "\nmov [%s_%s], eax", method->name.c_str(), rightNode->value.var->name.c_str());
					break;
				case _PRINT_FUNC:
					fprintf(file, "\nmov eax, [%s_%s]", method->name.c_str(), rightNode->value.var->name.c_str());
					fprintf(file, "\npush eax");
					fprintf(file, "\npush format");
					fprintf(file, "\ncall printf");
					fprintf(file, "\npop eax\npop eax");
					break;
				case _IF_STMT:		
					{
						writeLogicTree(file, method, rightNode->value.node);
						int currentCount = ++labelCount;
						fprintf(file, "\npop eax\ncmp eax, 0");	

						if(rightNode->right) // if - else
						{
							fprintf(file, "\njz ELSE%d", currentCount);
							writeMethodOperators(file, method, rightNode->left);
							fprintf(file, "\njmp END%d\nELSE%d:", currentCount, currentCount);
							writeMethodOperators(file, method, rightNode->right);
							fprintf(file, "\nEND%d:", currentCount);
						}
						else // if
						{
							fprintf(file, "\njz END%d", currentCount);
							writeMethodOperators(file, method, rightNode->left);
							fprintf(file, "\nEND%d:", currentCount);
						}
						break;
					}			
				// case 11: // while
				// {
				// 	int currentCount = ++labelCount;
				// 	currentCycle = currentCount;
				// 	fprintf(file, "\nWhile_begin%d:", currentCount);
				// 	writeLogicTree(file, func, rightNode->left);
				// 	fprintf(file, "\npop eax\ncmp eax, 0");	
				// 	fprintf(file, "\njz End%d", currentCount);
					
				// 	writeOperators(file, func, rightNode->right);
				// 	fprintf(file, "\njmp While_begin%d", currentCount);
				// 	fprintf(file, "\nEnd%d:", currentCount);
				// 	break;
				// }
				case _CUSTOM_FUNC_CALL:
					writeLogicTree(file, method, rightNode);					
					break;
				// case 16: // break
				// 	fprintf(file, "\njmp End%d", currentCycle);	
				// 	break;
			}
		}
		
		//----------------------------------------------------
		workNode = workNode->left;
	}
}

void writeLogicTree(FILE *file, struct Method* method, struct Node *root)
{
	if(!root) { return; }
	char type = root->nodeType;

	if((type < 0) || (type > 1 && type < 14) || (type > 14 && type < 30) || (type > 47)) 
		return;

	if(type != 44 && type != 45 && type != 46 && type != 47 && type != 0 && type != 1 && type != 14 && type != 41)
	{
		writeLogicTree(file, method, root->left);
		writeLogicTree(file, method, root->right);
	}

	switch(type)
	{
		case _ADD_SYM:
			fprintf(file, "\npop eax\npop ebx\nadd eax, ebx\npush eax");
			break;
		case _SUB_SYM:
			fprintf(file, "\npop ebx\npop eax\nsub eax, ebx\npush eax");
			break;
		case _MUL_SYM:
			fprintf(file, "\npop eax\npop ebx\nmul ebx\npush eax");
			break;
		case _DIV_SYM:
			fprintf(file, "\npop ebx\npop eax\nmov edx, 0\ndiv ebx\npush eax");
			break;
		case _ST:
			labelCount++;
			fprintf(file, "\npop ebx\npop eax\ncmp eax, ebx\njl label%d\npush 0\njmp afterLabel%d", labelCount, labelCount);
			fprintf(file, "\nlabel%d: push 1\nafterLabel%d: ", labelCount, labelCount);
			break;
		case _GT:
			labelCount++;
			fprintf(file, "\npop ebx\npop eax\ncmp eax, ebx\njg label%d\npush 0\njmp afterLabel%d", labelCount, labelCount);
			fprintf(file, "\nlabel%d: push 1\nafterLabel%d: ", labelCount, labelCount);
			break;
		case _STE:
			labelCount++;
			fprintf(file, "\npop ebx\npop eax\ncmp eax, ebx\njle label%d\npush 0\njmp afterLabel%d", labelCount, labelCount);
			fprintf(file, "\nlabel%d: push 1\nafterLabel%d: ", labelCount, labelCount);
			break;
		case _GTE:
			labelCount++;
			fprintf(file, "\npop ebx\npop eax\ncmp eax, ebx\njge label%d\npush 0\njmp afterLabel%d", labelCount, labelCount);
			fprintf(file, "\nlabel%d: push 1\nafterLabel%d: ", labelCount, labelCount);
			break;
		case _EQ:
			labelCount++;
			fprintf(file, "\npop ebx\npop eax\ncmp eax, ebx\nje label%d\npush 0\njmp afterLabel%d", labelCount, labelCount);
			fprintf(file, "\nlabel%d: push 1\nafterLabel%d: ", labelCount, labelCount);
			break;
		case _NEQ:
			labelCount++;
			fprintf(file, "\npop ebx\npop eax\ncmp eax, ebx\njne label%d\npush 0\njmp afterLabel%d", labelCount, labelCount);
			fprintf(file, "\nlabel%d: push 1\nafterLabel%d: ", labelCount, labelCount);
			break;
		case _NOT:
			writeLogicTree(file, method, root->right); 
			labelCount++;
			fprintf(file, "\npop eax\ncmp eax, 0\njz label%d\npush 0\njmp afterLabel%d", labelCount, labelCount);
			fprintf(file, "\nlabel%d: push 1\nafterLabel%d: ", labelCount, labelCount);
			break;
		case _OR:
			fprintf(file, "\npop ebx\npop eax\nor eax, ebx\npush eax");
			break;
		case _AND:
			fprintf(file, "\npop ebx\npop eax\nand eax, ebx\npush eax");
			break;
		case _SUB_OP:
			writeLogicTree(file, method, root->right);
			fprintf(file, "\npop ebx\nmov eax, 0\nsub eax, ebx\npush eax");
			break;
		case _CUSTOM_FUNC_CALL:
			fprintf(file, "\ncall %s", root->value.method->name.c_str());
			break;
		case _PRINT_FUNC:
			fprintf(file, "\ncall printf");
			fprintf(file, "\add esp, %d", root->value.var->value);
			break;
		case _VAR:
			fprintf(file, "\nmov eax, 0\nmov al, [%s_%s]\npush eax", method->name.c_str(), root->value.var->name.c_str());
			break;
		case _CONST:
			fprintf(file, "\npush %d", root->value.constant->value.intValue);
			break;
	}
}