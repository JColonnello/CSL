#pragma once
#include <expressions.h>
#include <list.h>

typedef struct FunctionData FunctionData;
struct FunctionData
{
	char *symbol;
	List *params;
};

typedef struct ParameterDeclaration ParameterDeclaration;
struct ParameterDeclaration
{
	enum DataType type;
	char *name;
};

#include <statement.h>
typedef struct FunctionDefinition FunctionDefinition;
struct FunctionDefinition
{
	enum DataType returnType;
	char *name;
	List *params;
	Expression *returnDeclaration;
	Statement *body;
};

Expression *createCall(char *symbol, List *params);
ParameterDeclaration *createParamDecl(enum DataType type, char *name);
FunctionDefinition *createFunctionDecl(enum DataType returnType, char *name, 
										List *params, Expression *retDecl, Statement *body);
void printFunctionDefinition(FunctionDefinition *function);
