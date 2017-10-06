/*****************************************************************************
 * DLLUTIL - Standard routines for handling double-linked lists.
 ****************************************************************************/

#define DLLUTIL_INTERNALS
#include "dllutil.h"

#ifndef NULL
  #define NULL ((void*)0)
#endif

#ifndef TRUE
  #define TRUE	1
  #define FALSE 0
#endif

#define DLL_DEBUG(statement)  /* statement */

void *dl_insert(list, afteritem, newitem)
/*****************************************************************************
 *
 ****************************************************************************/
	register DlList    *list;
	register DllHeader *afteritem;
	register DllHeader *newitem;
{
	if (NULL == list || NULL == afteritem || NULL == newitem) {
		DLL_DEBUG(printf("NULL item pointer: dl_insert(%p, %p, %p);\n", list, afteritem, newitem));
		return NULL;
	}

	newitem->prev	= afteritem;
	newitem->next	= afteritem->next;
	afteritem->next = newitem;

	if (NULL == newitem->next) {
		list->tail = newitem;
	} else {
		newitem->next->prev = newitem;
	}
	return newitem;
}

void *dl_addhead(list, item)
/*****************************************************************************
 *
 ****************************************************************************/
	register DlList    *list;
	register DllHeader *item;
{
	if (NULL == list || NULL == item) {
		DLL_DEBUG(printf("NULL list or item pointer: dl_addhead(%p, %p);\n", list, item));
		return NULL;
	}

	item->prev = NULL;			/* first item in list has NULL backlink 	*/
	item->next = list->head;	/* connect item's fwdlink to next item      */
	list->head = item;			/* connect item to list head				*/

	if (NULL == item->next) {	/* if the item we just added is last/only	*/
		list->tail = item;		/* item, connect it to the list tail		*/
		list->cur  = item;		/* and to the current-item pointer			*/
	} else {
		item->next->prev = item;/* else connect next item's backlink        */
	}

	return item;
}

void *dl_addtail(list, item)
/*****************************************************************************
 *
 ****************************************************************************/
	register DlList    *list;
	register DllHeader *item;
{
	if (NULL == list || NULL == item) {
		DLL_DEBUG(printf("NULL list or item pointer: dl_addtail(%p, %p);\n", list, item));
		return NULL;
	}

	if (NULL == list->tail) {
		return dl_addhead(list, item);
	} else {
		return dl_insert(list, list->tail, item);
	}

}

void dl_remove(list, item)
/*****************************************************************************
 *
 ****************************************************************************/
	register DlList    *list;
	register DllHeader *item;
{
	if (NULL == list || NULL == item) {
		DLL_DEBUG(printf("NULL list or item pointer: dl_remove(%p, %p);\n", list, item));
		return;
	}

	if (list->cur == item) {
		if (NULL == item->next) {
			list->cur = item->prev;
		} else {
			list->cur = item->next;
		}
	}

	if (NULL == item->next) {
		list->tail = item->prev;
	} else {
		item->next->prev = item->prev;
	}

	if (NULL == item->prev) {
		list->head = item->next;
	} else {
		item->prev->next = item->next;
	}

}

void dl_freelist(list, freefunc)
/*****************************************************************************
 *
 ****************************************************************************/
	register DlList 	 *list;
#if __STDC__
	register void		 (*freefunc)(DlList *, void *);
#else
	register void		 (*freefunc)();
#endif
{
	register DllHeader	 *cur, *next;

	for (cur = list->head; cur != NULL; cur = next) {
		next = cur->next;
		(*freefunc)(list, cur);
	}
}

int dl_seek(list, count, whence)
/*****************************************************************************
 * seek to an item in a list, kinda like fseek().
 * returns TRUE if at either end of the list, FALSE if not at end.
 ****************************************************************************/
	register DlList *list;
	register long	count;
	int 			whence;
{
	register DllHeader	*cur, *next;
	register int		backwards;

	switch (whence) {
	  case 0:
		cur = list->head;
		backwards = FALSE;
		break;
	  default:
		DLL_DEBUG(printf("Unknown 'whence' type in dl_seek(), SEEK_CUR assumed.\n"));
		/* fall thru */
	  case 1:
		cur = list->cur;
		backwards = (count < 0) ? TRUE : FALSE;
		break;
	  case 2:
		cur = list->tail;
		backwards = TRUE;
		break;
	}

	if (NULL == cur)
		return TRUE;

	if (count < 0) {
		count = -count;
	}

	next = (backwards) ? cur->prev : cur->next;

	while (next && count) {
		cur  = next;
		next = (backwards) ? cur->prev : cur->next;
		--count;
	}

	list->cur = cur;
	return (next == NULL);
}

long dl_tell(list)
/*****************************************************************************
 * returns the index of the current item in the list.
 ****************************************************************************/
	register DlList *list;
{
	register DllHeader *cur = list->head;
	register long	   idx	= 0;

	while (cur && cur != list->cur) {
		++idx;
		cur = cur->next;
	}

	return idx;
}
