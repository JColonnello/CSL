#pragma once

typedef struct AssignmentTarget AssignmentTarget;
struct AssignmentTarget
{
	char *symbol;
	char *member;
};

AssignmentTarget *createAssignmentLValue(char *symbol, char *member);
