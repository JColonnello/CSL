#include <statement.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>
#include <functions.h>
#include <string.h>

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

void printTab(int tab)
{
	while(tab--)
		printf("\t");
}

bool isCompound(enum StatementType type)
{
	return 	type == ST_BLOCK || 
			type ==  ST_IF || 
			type == ST_FOR;
}

void printStatementLevel(Statement *statement, FunctionDefinition *parent, int tab)
{
	switch (statement->type)
	{
		case ST_BLOCK:
		{
			List *list = statement->data;
			printTab(tab);
			printf("{\n");
			for(Node *node = list->first; node; node = node->next)
			{
				Statement *child = node->data;
				printStatementLevel(child, parent, tab+1);
				if(!isCompound(child->type))
					printf(";");
				printf("\n");
			}
			printTab(tab);
			printf("}");
			break;
		}
		case ST_ASSIGNMENT:
		{
			printTab(tab);
			AssignmentData *data = statement->data;
			printf("%s", data->lvalue->symbol);
			char *member = data->lvalue->member;
			if(member)
			{
				printf(".%s", member);
			}
			printf(" %s= ", getOpString(data->op));
			if(member && data->op == OP_NONE && strlen(member) > 1)
			{
				printf("(");
				printExpression(data->expression);
				char suffix[] = "xyzw";
				suffix[strlen(member)] = 0;
				printf(").%s", suffix);
			}
			else
				printExpression(data->expression);
			break;
		}
		case ST_DECLARATION:
		{
			printTab(tab);
			DeclarationData *data = statement->data;
			printf("%s %s", getTypeString(data->type), data->symbol);
			if(data->value)
			{
				printf(" = ");
				printExpression(data->value);
			}
			break;
		}
		case ST_FOR:
		{
			printTab(tab);
			ForData *data = statement->data;
			printf("for (");
			printStatementLevel(data->declaration, parent, 0);
			printf("; ");
			printExpression(data->condition);
			printf("; ");
			printStatementLevel(data->increment, parent, 0);
			printf(")\n");
			printStatementLevel(data->body, parent, tab+1);
			printf("\n");
			break;
		}
		case ST_IF:
		{
			printTab(tab);
			IfData *data = statement->data;
			printf("if (");
			printExpression(data->condition);
			printf(")\n");
			printStatementLevel(data->then, parent, data->then->type == ST_BLOCK ? tab : tab+1);
			if(!isCompound(data->then->type))
				printf(";");
			printf("\n");
			if(data->elseThen)
			{
				printTab(tab);
				printf("else\n");
				printStatementLevel(data->elseThen, parent, data->elseThen->type == ST_BLOCK ? tab : tab+1);
				if(isCompound(data->elseThen->type))
					printf(";");
			}
			break;
		}
		case ST_RET:
		{
			printTab(tab);
			printf("return ");
			if(parent->returnDeclaration)
				printExpression(parent->returnDeclaration);
			break;
		}
		case ST_BREAK:
		{
			printTab(tab);
			printf("break");
			break;
		}
	}
}

void printStatement(Statement *statement, FunctionDefinition *parent)
{
	printStatementLevel(statement, parent, 0);
}
