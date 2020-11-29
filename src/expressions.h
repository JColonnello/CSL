#pragma once
#include <list.h>
#include <ast.h>

typedef struct Expression Expression;

enum Operation
{
	OP_NONE,
	OP_CONSTRUCTOR,
	OP_CONDITIONAL,
	OP_PLUS,
	OP_MINUS,
	OP_PROD,
	OP_DIV,
	OP_MAX,
	OP_MIN,
	OP_LT,
	OP_GT,
	OP_LE,
	OP_GE,
	OP_EQ,
	OP_NE,
	OP_DOUBLE_BARS,
	OP_AND,
	OP_UMINUS,
	OP_UPLUS,
	OP_PARENTHESIS,
	OP_LENGTH,
	OP_CONST,
	OP_MEMBER,
	OP_SYMBOL,
	OP_CALL,
};

struct Expression
{
	int nOperations;
	enum DataType type;
	enum Operation operation;
	Expression *op1, *op2, *op3;
	void *data;
};

Expression *createConstructor(enum DataType type, List *params);
Expression *createConstructorSingle(enum DataType type, Expression *param);

#define createOp(oper, op1, op2, op3, ...) _createOperation(oper, op1, op2, op3)
#define createOperation(oper,...) createOp(oper, __VA_ARGS__, NULL, NULL, NULL)
Expression *_createOperation(enum Operation operation, Expression *op1, Expression *op2, Expression *op3);

Expression *createFloat(float value);
Expression *createMember(Expression *base, char *member);
Expression *createSymbol(char *ident);
const char *getOpString(enum Operation);
void printExpression(Expression *);
