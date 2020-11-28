#include <statement.h>
#include <stdlib.h>

Statement *createAssignment(AssignmentTarget *target, Expression *expression, enum Operation op)
{
	Statement *statement = malloc(sizeof(Statement));
	AssignmentData *data = malloc(sizeof(AssignmentData));
	data->expression = expression;
	data->lvalue = target;
	data->op = op;

	statement->type = ST_ASSIGNMENT;
	statement->data = data;
	return statement;
}

Statement *createIf(Expression *condition, Statement *then, Statement *elseThen)
{
	Statement *statement = malloc(sizeof(Statement));
	IfData *data = malloc(sizeof(IfData));
	data->condition = condition;
	data->then = then;
	data->elseThen = elseThen;

	statement->type = ST_IF;
	statement->data = data;
	return statement;
}

Statement *createFor(Statement *declaration, Expression *condition, Statement *increment, Statement *body)
{
	if(declaration->type != ST_DECLARATION)
		return NULL;

	Statement *statement = malloc(sizeof(Statement));
	ForData *data = malloc(sizeof(ForData));
	data->declaration = declaration;
	data->condition = condition;
	data->increment = increment;
	data->body = body;

	statement->type = ST_FOR;
	statement->data = data;
	return statement;
}

Statement *createBlock(List *list)
{
	Statement *statement = malloc(sizeof(Statement));
	statement->type = ST_BLOCK;
	statement->data = list;
	return statement;
}

Statement *createSimple(enum StatementType type)
{
	Statement *statement = malloc(sizeof(Statement));
	statement->type = type;
	statement->data = NULL;
	return statement;
}

Statement *createDeclaration(enum DataType type, char *symbol, Expression *value)
{
	// if(value->type != type)
	// 	return NULL;

	Statement *statement = malloc(sizeof(Statement));
	DeclarationData *data = malloc(sizeof(DeclarationData));
	data->type = type;
	data->symbol = symbol;
	data->value = value;

	statement->type = ST_DECLARATION;
	statement->data = data;

	return statement;
}
