#include <functions.h>
#include <stdlib.h>
#include <stdio.h>

Expression *createCall(char *symbol, List *params)
{
	Expression *expression = malloc(sizeof(Expression));
	FunctionData *data = malloc(sizeof(FunctionData));
	data->params = params;
	data->symbol = symbol;

	*expression = (Expression)
	{
		.type = TYPE_NONE,
		.operation = OP_CALL,
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

FunctionDefinition *createFunctionDecl(enum DataType returnType, char *name, 
										List *params, Expression *retDecl, Statement *body)
{
	if(body != NULL && body->type != ST_BLOCK)
		return NULL;
	// if(retDecl->type != returnType)
	// 	return NULL;
	
	FunctionDefinition *decl = malloc(sizeof(FunctionDefinition));
	decl->returnType = returnType;
	decl->name = name;
	decl->params = params;
	decl->returnDeclaration = retDecl;
	decl->body = body;

	return decl;
}

void printStatement(Statement *statement, FunctionDefinition *parent);

void printParamDecl(List *list)
{
	printf("(");
	for(Node *node = list->first; node; node = node->next)
	{
		ParameterDeclaration *param = node->data;
		
		printf("%s %s", getTypeString(param->type), param->name);
		if(node->next)
			printf(", ");
	}
	printf(")");
}

void printFunctionDefinition(FunctionDefinition *function)
{
	printf("%s %s", getTypeString(function->returnType), function->name);
	printParamDecl(function->params);
	printf("\n");
	
	Statement *body = function->body ? function->body : createBlock(List_init());
	List_add(body->data, createSimple(ST_RET));
	printStatement(body, function);
	printf("\n");
}