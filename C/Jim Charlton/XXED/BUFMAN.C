#include "stdio.h"
#include "gemdefs.h"
#include "obdefs.h"
#include "osbind.h"
#include "globals.h"
#include "xxed.h"
/*
Note:  Each window has its own file buffer.  This file buffer is composed
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
blocks
*/

/* add a member to the linked list at the end  */

linkbufptr addmember(thewin)
	windowptr	thewin;
{   
	linkbufptr newmem, amem;
	int c;	

	/* allocate space for the new member */
	newmem = (linkbufptr)malloc(sizeof(linkbuf));
	if(newmem == NULL) return NULL;  /* no more memory available  */

	/* initialize the newmem linkbuf */
	
	newmem->next = NULL;
	bzero(newmem->block,BLOCKSIZE);
    newmem->inuse = 0;
	/* insert into the linked list       */
	
	if(!thewin->headptr)	/* if thewin->headptr is NULL   */
	  thewin->headptr = newmem;
	else
	{  amem = thewin->headptr;
	  	   while(amem->next)
	         amem = amem->next;
	   amem->next = newmem;
	}  
      return(newmem);
}

/* insert a new linked buffer in the list for any list */

insert_member(bufptr)
	linkbufptr	bufptr;
{
	linkbufptr newmem;
	int totransfer, left, i;	

	/* allocate space for the new member */
	newmem = (linkbufptr)malloc(sizeof(linkbuf));
	if ( newmem == NULL)  /* no more memory available  */
		return(-1);
	/* initialize the newmem linkbuf and insert into list */
	
	newmem->next = bufptr->next;
	bzero(newmem->block,BLOCKSIZE);
    newmem->inuse = 0;
	bufptr->next = newmem;

	/* now split the contents of the block in bufptr between old & new */
	
	totransfer = bufptr->inuse - bufptr->inuse/2;
    left = bufptr->inuse/2;
/*	strncpy(newmem->block,bufptr->block+left,totransfer);	*/
	bcopy(bufptr->block+left,newmem->block,totransfer);
    newmem->inuse = totransfer;
    bufptr->inuse = left;
}

dispose_buf(thewin)
	windowptr 	thewin;
{
	int button;
	linkbufptr	amem;
	char str[160];

	if(thewin->changed == TRUE)
	{	sprintf(str,"[0][ | File %s | has been changed. | Do you want to SAVE | before closing? ][ YES | NO ]", thewin->title);
		button = form_alert(1, str);
		if(button == 1)
			handle_file(SAVE);
	}      

	 for (amem=thewin->headptr;amem;amem = thewin->headptr)
	{	dispose_member(thewin,amem);
    }

}
dispose_member(thewin,memtodel)
	windowptr	thewin;
	linkbufptr memtodel;
	
{	linkbufptr amem;
	int button;

	if(thewin->headptr)
	{
		if (thewin->headptr == memtodel)
	  		 thewin->headptr = thewin->headptr->next;
	  	else
      {	 for (amem = thewin->headptr;(amem->next != memtodel) ;amem=amem->next)
	 				if (!amem) break;
	    /* search list 'til find memtodel in amem->next or amem==NULL */
	    if(amem)
			   amem->next = amem->next->next;
	    else
			{	button = form_alert(1, "[1][ Internal Error: |  member to delete not in list. ][OK]");
			shutdown(2);
			}      
	   }		   	        
  	   	free((char *)memtodel); /* free up space of deleted member  */
	}  	   	
}	        	   	   
 
