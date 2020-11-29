#include "functions.h"
#include <ast.h>
#include <stdio.h>

void generateOutput(List *translations)
{
	for(Node *node = translations->first; node; node = node->next)
	{
		FunctionDefinition *function = node->data;
		printFunctionDefinition(function);
	}
}

const char *getTypeString(enum DataType type)
{
	char *str;
	switch (type) 
	{
		case TYPE_FLOAT:
			str = "float";
			break;
		case TYPE_MATRIX:
			str = "mat4";
			break;
		case TYPE_NONE:
			str = "void";
			break;
		case TYPE_VECTOR:
			str = "vec4";
			break;
		case TYPE_LOGIC:
			break;
	}
	return str;
}
