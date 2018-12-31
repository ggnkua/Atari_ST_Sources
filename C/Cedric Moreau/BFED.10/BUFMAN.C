/********************************************
	file: bufman.c
	utility:
	date: 1989
	author: Jim Charlton
	modifications:
		1996: C. Moreau: 
	comments: Each window has its own file buffer.  This file buffer is composed
	 of a linked list of blocks.  addmember() adds a new block to the end of the
	 list of blocks in the buffer, or puts the first block into the list if
	 there were no blocks in the list.  The size of the blocks in the buffer
	 is set with the globabl constant BLOCKSIZE.  Using a linked list of blocks
	 for a buffer simplifies memory management and speeds up inserts and deletes
	 since only the block containing the data in question need be modified.
	 insert_member() inserts a block into the linked list and splits the data
	 in the previous block between it and the new block.  This leaves two half
	 filled blocks for insertions.  dispose_member() deletes a block out of the
	 list....  happens when all of the data in a block is deleted or cut.
	 dispose_buf() will delete the entire file buffer by deleting all of its
	 blocks.
*********************************************/

/********************************************
	includes
*********************************************/
#include <stddef.h>
#include <stdlib.h>
#include <string.h>

#include "e:\proging\c\libs\malib\alert.h"
#include "bufman.h"
#include "main.h"
#include "menu.h"
#include "wind.h"

#include "bfed_rsc.h"

/********************************************
	defines
*********************************************/

/********************************************
	locals vars declarations & definitions
*********************************************/

/********************************************
	globals vars declarations
*********************************************/
char	*cutbuffer = ( (void*) 0L );
long	cutlength = 0L;

/********************************************
	locals functions declarations
*********************************************/

/********************************************
	globals functions definitions
*********************************************/

/********************************************
	locals functions definitions
*********************************************/
/*
	name: addmember
	utility: add a member to the linked list at the end.
	comment: adds a new block to the end of the list of blocks in the buffer,
	 or puts the first block into the list if there were no blocks in the list.
	parameters: 
		windowptr thewin: ptr on window choosen.
	return: linkbufptr: ptr on new member added.
	date: 1989
	author: Jim Charlton
	modifications:
*/
linkbufptr addmember(windowptr thewin)
{   
		/* allocate space for the new member */
	linkbufptr newmem = (linkbufptr) malloc(sizeof(linkbuf));

	if (newmem)  /* if some memory available  */
	{
			/* initialize the newmem linkbuf */
		newmem->next = NULL;
		memset(newmem->block, '\0', (long) BLOCKSIZE);
		newmem->inuse = 0;
			/* insert into the linked list       */
		if(!thewin->headptr)
			thewin->headptr = newmem;
		else
		{
			linkbufptr amem = thewin->headptr;
		
			while(amem->next)
				amem = amem->next;
			amem->next = newmem;
		} 
	}
	return(newmem);
}

/*
	name: insert_member
	utility: insert a new linked buffer in the list for any list
	comment: inserts a block into the linked list and splits the data
	 in the previous block between it and the new block.
	parameters:
		linkbufptr bufptr: ptr on block to insert.
	return: int:
	date: 1989
	author: Jim Charlton
	modifications:
*/
int insert_member(linkbufptr bufptr)
{
		/* allocate space for the new member */
	linkbufptr newmem = (linkbufptr) malloc(sizeof(linkbuf));

	if (newmem)  /* if some memory available  */
	{
			/* initialize the newmem linkbuf and insert into list */
		int totransfer, left;	

		newmem->next = bufptr->next;
		memset(newmem->block, '\0', (long)BLOCKSIZE);
		newmem->inuse = 0L;
		bufptr->next = newmem;
	
			/* now split the contents of the block in bufptr between old & new */
		
		totransfer = (int)(bufptr->inuse)/2;
		left = (int)bufptr->inuse - totransfer;
		memmove(newmem->block,bufptr->block+left,(long)totransfer);
		newmem->inuse = totransfer;
		bufptr->inuse = left;
		return (0);
	}
	else
		return(-1);
}

/*
	name: dispose_buf
	utility: dispose of buffer
	comment: 
	parameters:
	return: FALSE to signify user-abort
	date: 1989
	author: Jim Charlton
	modifications:
*/
void dispose_buf(windowptr thewin)
{
	if (!thewin->form)
	{
		linkbufptr	amem;

		if(thewin->changed)
		{
			if(rsc_falert(SAVE_CLOSE, thewin->title))
				do_menu(FILE,SAVE);
		}      
	
		amem = thewin->headptr;
		while(amem)
		{
			dispose_member(thewin,amem);
			amem = thewin->headptr;		
		}
	}	
}

/*
	name: dispose_member
	utility: 
	comment: 
	parameters:
	return: 
	date: 1989
	author: Jim Charlton
	modifications:
*/
void dispose_member(windowptr thewin, linkbufptr memtodel)
{
	if(thewin->headptr)
	{
		if (thewin->headptr == memtodel)
	  		thewin->headptr = thewin->headptr->next;
	  	else
		{
			linkbufptr amem = thewin->headptr;
		
			while( (amem->next != memtodel) || !amem )
			{
				amem=amem->next;
			}
				/* search list 'til find memtodel in amem->next or amem==NULL */
			if (amem)
				amem->next = amem->next->next;
			else
			{
				rsc_alert(MEMB_LIST);
				shutdown(2);
			}      
		}		   	        
		free((char *) memtodel); /* free up space of deleted member  */
	}  	   	
}	        	   	   
 
