#pragma once

typedef struct List List;
typedef struct Node Node;
struct List
{
	int count;
	Node *first, *last;
};
struct Node
{
	Node *next;
	void *data;
};

List *List_init();
void List_add(List *list, void *data);
