#ifndef HELPERS_H
#define HELPERS_H

#include <iostream>
#include <stdlib.h>

void yyerror(const char *s)
{
	std::cout << s << std::endl;
	exit(1);
}


#endif // HELPERS_H