#pragma once
#include <expressions.h>
#include <list.h>

typedef struct FunctionData FunctionData;
struct FunctionData
{
	char *symbol;
	List *params;
};

Expression *createCall(char *symbol, List *params);
