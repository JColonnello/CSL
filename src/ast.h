#pragma once

#include "list.h"
enum DataType
{
	TYPE_NONE,
	TYPE_FLOAT,
	TYPE_VECTOR,
	TYPE_MATRIX,
	TYPE_LOGIC,
};

void generateOutput(List *translations);
const char *getTypeString(enum DataType type);
