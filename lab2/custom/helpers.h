#ifndef HELPERS_H
#define HELPERS_H

void yyerror(const char *s)
{
	printf("%s\n", s); exit(1);
}

#endif