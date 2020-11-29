#include <list.h>
#include <stdlib.h>

struct List *List_init()
{
	struct List *list = calloc(1, sizeof(struct List));
	return list;
}

void List_add(List *list, void *data)
{
	struct Node *node = malloc(sizeof(struct Node));
	node->data = data;
	node->next = NULL;

	if(list->last != NULL) list->last->next = node;
	if(list->first == NULL) list->first = node;
	list->last = node;

	list->count++;
}