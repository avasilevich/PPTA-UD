#ifndef HELPERS_H
#define HELPERS_H

char* varDefinitions[100]; 
int varCounter = 0; 

/* Add a variable name to the memory store */
int addNewVariable(char* varName)
{
	int x;
	
	for (x = 0; x < varCounter; x++) {
		if (strcmp(varName, varDefinitions[x]) == 0) {
			return x;
		}
	}

	varCounter++;
	varDefinitions[x] = strdup(varName);
	
	return x;
}

void yyerror(const char *s)
{
	printf("ERROR: %s\n", s);
}

#endif