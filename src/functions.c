#include <functions.h>
#include <stdlib.h>

Expression *createCall(char *symbol, List *params)
{
	Expression *expression = malloc(sizeof(Expression));
	FunctionData *data = malloc(sizeof(FunctionData));
	data->params = params;
	data->symbol = symbol;

	*expression = (Expression)
	{
		.type = TYPE_NONE,
		.data = data,
	};
	return expression;
}

ParameterDeclaration *createParamDecl(enum DataType type, char *name)
{
	ParameterDeclaration *decl = malloc(sizeof(ParameterDeclaration));
	decl->type = type;
	decl->name = name;

	return decl;
}

FunctionDeclaration *createFunctionDecl(enum DataType returnType, char *name, 
										List *params, Expression *retDecl, Statement *body)
{
	if(body != NULL && body->type != ST_BLOCK)
		return NULL;
	// if(retDecl->type != returnType)
	// 	return NULL;
	
	FunctionDeclaration *decl = malloc(sizeof(FunctionDeclaration));
	decl->returnType = returnType;
	decl->name = name;
	decl->params = params;
	decl->returnDeclaration = retDecl;
	decl->body = body;

	return decl;
}
