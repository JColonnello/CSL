#pragma once
#include <expressions.h>
#include <list.h>
#include <statement.h>

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

typedef struct FunctionDeclaration FunctionDeclaration;
struct FunctionDeclaration
{
	enum DataType returnType;
	char *name;
	List *params;
	Expression *returnDeclaration;
	Statement *body;
};

Expression *createCall(char *symbol, List *params);
ParameterDeclaration *createParamDecl(enum DataType type, char *name);
FunctionDeclaration *createFunctionDecl(enum DataType returnType, char *name, 
										List *params, Expression *retDecl, Statement *body);
