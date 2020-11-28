#include <member.h>
#include <stdlib.h>

AssignmentTarget *createAssignmentLValue(char *symbol, char *member)
{
	AssignmentTarget *target = malloc(sizeof(AssignmentTarget));
	target->symbol = symbol;
	target->member = member;

	return target;
}
