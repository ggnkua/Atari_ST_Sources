/* List:	Definitions used by clients of the List doubly-linked list
 *		library.
 * phil comeau 12-jul-87
 * last edited 16-sep-89 0004
 *
 * Copyright 1990 Antic Publishing Inc.
 *
 */

#ifndef LIST_H
#define LIST_H

/* Types. */

/* LISTNODE:	Individual doubly-linked list node. */
typedef struct ListNode {
	struct ListNode *prev;	/* pointer to previous list node, or
				 * NULL if this is the list head
				 */
	struct ListNode *next;	/* pointer to next list node, or NULL if
				 * this is the last node.
				 */
	char *contents;		/* pointer to the user data contained in this
				 * node.
				 */
} LISTNODE;

/* LIST:	Contents of a List Object. */
typedef struct {
	LISTNODE head;		/* list head. */
	int (*cmpFunc)();	/* function that determines where in list
				 * each item belongs.
				 */
} LIST;

/* Macros. */

/* ListPrev:	Obtain pointer to previous LISTNODE. */
#define ListPrev(lst) ((lst)->prev)

/* ListNext:	Obtain pointer to next LISTNODE. */
#define ListNext(lst) ((lst)->next)

/* ListContents:	Obtain pointer to LISTNODE's contents. */
#define ListContents(lst) ((lst)->contents)
 
/* Function definitions. */
extern void ListCreate(), ListDestroy(), ListWalk();
extern char *ListAdd(), *ListDelete(), *ListFind();

#endif LIST_H
