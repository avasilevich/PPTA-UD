/* code generation functions */
int generateCode();
void writeALLVarDeclarations(FILE *file);
void writeMethodVarDeclarations(FILE *file, struct Method *method);
void writeClassVarDeclarations(FILE *file);
void writeMethods(FILE *file);


/* implementation */
int generateCode()
{
	FILE *file;
	file = fopen("lab4.asm", "w");
	
	fprintf(file, "\n\nSECTION .data\n");	
	writeALLVarDeclarations(file);
	fprintf(file, "\n\nSECTION .text\n\nglobal _main");	
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
	// TODO
}