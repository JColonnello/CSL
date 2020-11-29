#define _GNU_SOURCE
#include <expressions.h>
#include <functions.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

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
		
		case OP_NONE:
		case OP_CONST: case OP_CONSTRUCTOR: 
		case OP_SYMBOL: case OP_MEMBER:
		case OP_CALL:
			return NULL;
	}

	Expression *expression = malloc(sizeof(Expression));
	*expression = (Expression)
	{
		.type = resultType,
		.operation = operation,
		.op1 = op1,
		.op2 = op2,
		.op3 = op3,
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

const char *getOpString(enum Operation op)
{
	const char *values[] =
	{
		[OP_NONE] = "",
		[OP_PLUS] = "+",
		[OP_MINUS] = "-",
		[OP_PROD] = "*",
		[OP_DIV] = "/",
		[OP_MAX] = "max",
		[OP_MIN] = "min",
		[OP_LT] = "<",
		[OP_GT] = ">",
		[OP_LE] = "<=",
		[OP_GE] = ">=",
		[OP_DOUBLE_BARS] = "||",
		[OP_AND] = "&&",
		[OP_UMINUS] = "-",
		[OP_UPLUS] = "+",
		[OP_LENGTH] = "length",
	};
	return values[op];
}

void printConstructor(Expression *expression)
{
	printf("%s(", getTypeString(expression->type));
	List *params = expression->data;
	if(expression->type == TYPE_FLOAT || params->count == 1)
	{
		printExpression(params->first->data);
		printf(")");
		return;
	}

	int count = 0;
	for(Node *node=params->first; node != NULL; node = node->next)
	{
		Expression *param = node->data;
		printExpression(param);
		if(count < 3)
			printf(", ");
		if(param->operation == OP_MEMBER)
		{
			count += strlen(param->data);
		}
		else
			count++;
	}
	for(; count < 4; count++)
	{
		if(expression->type == TYPE_MATRIX)
			printf("vec4(0.)");
		else
			printf("0.");

		if(count < 3)
			printf(", ");
	}
	printf(")");
}

void printExpression(Expression *expression)
{
	switch (expression->operation)
	{
		case OP_CONSTRUCTOR:
			printConstructor(expression);
			break;
		case OP_CONDITIONAL:
			printExpression(expression->op1);
			printf(" ? ");
			printExpression(expression->op2);
			printf(" : ");
			printExpression(expression->op3);
			break;
		case OP_PLUS: case OP_MINUS:
		case OP_PROD: case OP_DIV:
		case OP_LT: case OP_GT: case OP_LE: case OP_GE:
		case OP_AND: case OP_DOUBLE_BARS:
			printExpression(expression->op1);
			printf(" %s ", getOpString(expression->operation));
			printExpression(expression->op2);
			break;
		case OP_MAX: case OP_MIN:
			printf("%s(", getOpString(expression->operation));
			printExpression(expression->op1);
			printf(", ");
			printExpression(expression->op2);
			printf(")");
			break;
		case OP_LENGTH:
			printf("%s(", getOpString(expression->operation));
			printExpression(expression->op1);
			printf(")");
			break;
		case OP_PARENTHESIS:
			printf("(");
			printExpression(expression->op1);
			printf(")");
			break;
		case OP_SYMBOL:
			printf("%s", (char*)expression->data);
			break;
		case OP_MEMBER:
		{
			char *member = expression->data;
			int len = strlen(member);
			if(len > 1)
			{
				printf("vec4(");
			}
			printExpression(expression->op1);
			printf(".%s", member);
			if(len > 1)
			{
				for(; len < 4; len++)
					printf(", 0.");
				printf(")");
			}
			break;
		}
		case OP_UPLUS: case OP_UMINUS:
			printf("%s", getOpString(expression->operation));
			printExpression(expression->op1);
			break;
		case OP_CONST:
		{
			char str[32];

			int count = snprintf(str, sizeof(str), "%.9f", *(float*)expression->data) - 1;
			int limit = strchrnul(str, '.') - str;
			for(; count > limit; count--)
			{
				if(str[count] == '0')
					str[count] = 0;
				else
					break;
			}
			printf("%s", str);
			break;
		}
		case OP_CALL:
		{
			FunctionData *data = expression->data;
			if(strcmp(data->symbol, "cross") == 0)
				printf("vec4(");
			printf("%s(", data->symbol);
			for(Node *node=data->params->first; node != NULL; node = node->next)
			{
				printExpression(node->data);
				if(strcmp(data->symbol, "cross") == 0)
					printf(".xyz");
				if(node->next)
					printf(", ");
			}
			printf(")");
			if(strcmp(data->symbol, "cross") == 0)
				printf(", 0.)");
			break;
		}
		case OP_NONE:
			break;
	}
}
