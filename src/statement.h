#pragma once
#include <member.h>
#include <expressions.h>

typedef struct Statement Statement;

enum StatementType
{
	ST_ASSIGNMENT,
	ST_BREAK,
	ST_RET,
	ST_IF,
	ST_FOR,
	ST_DECLARATION,
	ST_BLOCK,
};

struct Statement
{
	enum StatementType type;
	void *data;
};

typedef struct AssignmentData AssignmentData;
struct AssignmentData
{
	AssignmentTarget *lvalue;
	Expression *expression;
	enum Operation op;
};

typedef struct IfData IfData;
struct IfData
{
	Expression *condition;
	Statement *then;
	Statement *elseThen;
};

typedef struct ForData ForData;
struct ForData
{
	Statement *declaration;
	Expression *condition;
	Statement *increment;
	Statement *body;
};

typedef struct DeclarationData DeclarationData;
struct DeclarationData
{
	enum DataType type;
	char *symbol;
	Expression *value;
};

Statement *createAssignment(AssignmentTarget *target, Expression *expression, enum Operation op);
Statement *createIf(Expression *condition, Statement *then, Statement *elseThen);
Statement *createFor(Statement *declaration, Expression *condition, Statement *increment, Statement *body);
Statement *createBlock(List *list);
Statement *createSimple(enum StatementType type);
Statement *createDeclaration(enum DataType type, char *symbol, Expression *value);
