/* List:	Doubly-linked list library.
 * phil comeau 20-aug-87
 * last edited 09-jul-89 0002
 *
 * Copyright 1990 Antic Publishing Inc.
 */

#include <stdio.h>
#include <list.h>

/* ListCreate:	Create a new List. */
void ListCreate(list, cmpFunc)
register LIST *list;
int (*cmpFunc)();
{
	list->head.prev = NULL;
	list->head.next = NULL;
	list->head.contents = NULL;
	list->cmpFunc = cmpFunc;
}

/* ListDestroy:	Destroy a List. */
void ListDestroy(list, freeFunc)
LIST *list;
register void (*freeFunc)();
{
	register LISTNODE *pList, *tmp;

	for (pList = ListNext(&list->head); pList != NULL; pList = tmp) {

		/* Invoke the user function to release the item. */
		(*freeFunc)(ListContents(pList));

		/* Delete this node. */
		tmp = ListNext(pList);
		free(pList);
	}

	/* Initialize the List. */
	list->head.prev = NULL;
	list->head.next = NULL;
	list->head.contents = NULL;
}

/* ListAdd: Add an item to a List. Returns a pointer to item. */
char *ListAdd(list, item)
register LIST *list;
register char *item;
{
	register LISTNODE *pList, *pPrev, *newNode;

	/* Locate the proper place in the list for the new item.
	 * When the compare function returns a negative number,
	 * pList will point to the element that will follow the one
	 * being inserted.
	 */
	pPrev = &list->head;
	for (pList = ListNext(&list->head); pList != NULL &&
	    (*list->cmpFunc)(item, ListContents(pList)) >= 0;
	    pList = ListNext(pList)) {
		pPrev = ListNext(pPrev);
	}

	/* pPrev now points to the element preceding the one being 
	 * inserted. We insert the new element between pPrev and pList.
	 */
	newNode = (LISTNODE *)malloc(sizeof(LISTNODE));
	ListPrev(newNode) = pPrev;
	ListNext(newNode) = pList;
	ListContents(newNode) = item;
	if (pList != NULL) {

		/* The new element is being added at the end of the list,
		 * so there is no backward link that points to it.
		 */
		ListPrev(pList) = newNode;
	}
	ListNext(pPrev) = newNode;

	return (ListContents(newNode));
}

/* ListDelete:	Delete an item from a List. Returns a pointer to the deleted
 *		item, or NULL if the item wasn't found.
 */
char *ListDelete(list, item)
register LIST *list;
register char *item;
{
	register LISTNODE *pList;
	char *pItem;
	register int rc;

	/* Locate the desired item in the list. We need to continue searching
	 * until the item has been located or we determine that it isn't in
	 * the list. When compare returns 0, the item has been found. When
	 * compare returns a negative value, we have gone past the place in
	 * the list where the item would be if it existed, so we know the
	 * item isn't in the list and we can terminate the search.
	 */
	rc = -1;
	for (pList = ListNext(&list->head); pList != NULL &&
	    (rc = (*list->cmpFunc)(item, ListContents(pList))) > 0;
	    pList = ListNext(pList))
		;

	if (rc == 0) {

		/* The item was located in the list. Delete the element
		 * containing the item by adjusting its predecessor's link,
		 * then free the memory allocated to the element.
		 */
		pItem = ListContents(pList);
		ListNext(ListPrev(pList)) = ListNext(pList);
		if (ListNext(pList) != NULL) {

			/* The element is not at the end of the list, so we
			 * can adjust the forward link.
			 */
			ListPrev(ListNext(pList)) = ListPrev(pList);
		}
		free(pList);
		return (pItem);
	}

	/* The item to be deleted wasn't found. */
	return (NULL);
}

/* ListFind:	Locate an item in a List. Returns a pointer to the located
 *		item or NULL.
 */
char *ListFind(list, item)
register LIST *list;
register char *item;
{
	register LISTNODE *pList;
	register int rc;

	/* Locate the list element that contains the item being sought. */
	rc = -1;
	for (pList = ListNext(&list->head); pList != NULL &&
	    (rc = (*list->cmpFunc)(item, ListContents(pList))) > 0;
	    pList = ListNext(pList))
		;
	if (rc == 0) {
		return (ListContents(pList));
	}

	/* The item wasn't found */
	return (NULL);
}
