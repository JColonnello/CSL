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
