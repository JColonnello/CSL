#include <expressions.h>
#include <functions.h>
#include <stdlib.h>

Expression *createConstructor(enum DataType type, List *params)
{
	Expression *expression = malloc(sizeof(Expression));
	for(Node *param=params->first; param != NULL; param = param->next)
	{
		// if(type == TYPE_VECTOR && ((Expression*)param->data)->type != TYPE_FLOAT)
		// 	return NULL;
		// else if(type == TYPE_MATRIX && ((Expression*)param->data)->type != TYPE_VECTOR)
		// 	return NULL;
	}

	*expression = (Expression)
	{
		.type = type,
		.operation = OP_CONSTRUCTOR,
		.data = params
	};
	return expression;
}

Expression *createConstructorSingle(enum DataType type, Expression *param)
{
	// if(type == TYPE_FLOAT && param->type != TYPE_FLOAT)
	// 	return NULL;

	List *list = List_init();
	List_add(list, param);

	return createConstructor(type, list);
}

Expression *_createOperation(enum Operation operation, Expression *op1, Expression *op2, Expression *op3)
{
	int n = op3 ? 3 : op2 ? 2 : 1;
	enum DataType resultType = op1->type;

	switch (operation) 
	{
		case OP_CONDITIONAL:
			// if(op2->type != op3->type)
			// 	return NULL;
			break;
		case OP_PLUS: case OP_MINUS:
		case OP_PROD: case OP_DIV:
		case OP_MAX: case OP_MIN:
		case OP_UPLUS: case OP_UMINUS:
			// if(op1->type != op2->type || op1->type != TYPE_FLOAT)
			// 	return NULL;
			break;
		case OP_LT: case OP_GT: case OP_LE: case OP_GE:
			// if(op1->type != op2->type || op1->type != TYPE_FLOAT)
			// 	return NULL;
			resultType = TYPE_LOGIC;
			break;
		case OP_AND: case OP_DOUBLE_BARS:
			// if(op1->type != op2->type || op1->type != TYPE_LOGIC)
			// 	return NULL;
			resultType = TYPE_LOGIC;
			break;
		case OP_LENGTH:
			// if(op1->type != TYPE_VECTOR)
			// 	return NULL;
			resultType = TYPE_FLOAT;
		case OP_PARENTHESIS:
			break;
		
		case OP_CONST: case OP_CONSTRUCTOR: 
		case OP_SYMBOL: case OP_MEMBER:
			return NULL;
	}

	Expression *expression = malloc(sizeof(Expression));
	*expression = (Expression)
	{
		.type = resultType,
		.operation = operation,
	};
	return expression;
}

Expression *createFloat(float value)
{
	Expression *expression = malloc(sizeof(Expression));
	float *data = malloc(sizeof(float));
	*data = value;

	*expression = (Expression)
	{
		.type = TYPE_FLOAT,
		.operation = OP_CONST,
		.data = data,
	};
	return expression;
}

Expression *createMember(Expression *base, char *member)
{
	Expression *expression = malloc(sizeof(Expression));
	*expression = (Expression)
	{
		.type = TYPE_NONE,
		.operation = OP_MEMBER,
		.nOperations = 1,
		.op1 = base,
		.data = member,
	};

	return expression;
}

Expression *createSymbol(char *ident)
{
	Expression *expression = malloc(sizeof(Expression));
	*expression = (Expression)
	{
		.type = TYPE_NONE,
		.operation = OP_SYMBOL,
		.nOperations = 0,
		.data = ident,
	};

	return expression;
}
