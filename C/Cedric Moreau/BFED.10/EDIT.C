/*
	file: edit.c
	utility:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
	comments: 
*/
#include <stddef.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#include "e:\proging\c\libs\malib\alert.h"

#include "bufman.h"
#include "edit.h"
#include "menu.h"
#include "onepage.h"
#include "send.h"

#include "bfed_rsc.h"

/* 
	globals vars
*/
int	ins	= 0;
int	inhex = 0;

/*
	name: delete_one
	utility: delete one byte
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void delete_one(windowptr thewin, long pos, int flag)
{
		/*	flag is 0 when saving the file in which case can delete last byte */
	if ( (thewin->position==thewin->flen-1) && flag)
		rsc_alert(LAST_BYTE);
	else
	{
		linkbufptr amem = thewin->headptr;
		char *addr, *addr2;
		
		while (amem->inuse <= pos)
		{
			pos -= amem->inuse;
			amem = amem->next;
		}
		addr = (char *)(amem->block+pos);
		for (addr2=addr;addr2<(char *)amem->block+amem->inuse;addr2++)
			*addr2 = *(addr2+1);  
	
		amem->inuse--;
		thewin->flen--; 
		if (thewin->position >= thewin->flen) 
			thewin->position = thewin->flen-1; 
		if (flag)	/* don't set to partial if deleting last byte in file	*/
			thewin->changed = TRUE;
	}
}

/*
	name: cutit
	utility: cut out the marked text
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void cutit(windowptr	thewin)
{
	linkbufptr amem;
	long pos = thewin->startmark;
	long togo = thewin->endmark - thewin->startmark + 1;
	int	inthis;
	
	if (pos <= thewin->flen)
	{
		amem = thewin->headptr;
		while (amem->inuse <= pos)
		{
			pos -= amem->inuse;
			amem = amem->next;
		}
		inthis = (int)(amem->inuse - pos);
	}
	
	if (togo > 0L)
	{	
		while (inthis < togo)
		{	
			amem->inuse = pos;
			if (!amem->inuse)
				dispose_member(thewin,amem);
			amem = amem->next;
			togo -= inthis;
			thewin->flen -= inthis;
			inthis = (int)(amem->inuse);
			pos = 0L;
		}
		
		if (togo > 0L)
		{
			memmove( amem->block+pos, amem->block+pos+togo,
					 amem->inuse-togo-pos );
			amem->inuse -= togo;
			thewin->flen -= togo;
		}
	}
	
	thewin->position = thewin->startmark;
	if (thewin->topchar >= thewin->position) 
		thewin->topchar = thewin->position&~0x7;	
}

/*
	name: copy
	utility: copy the marked text to the cutbuffer
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void copy(windowptr	thewin)
{
	linkbufptr	amem;
	long		pos = thewin->startmark;
	char		*addr;

	if (pos <= thewin->flen)
	{
		amem = thewin->headptr;
		while (amem->inuse <= pos)
		{
			pos -= amem->inuse;
			amem = amem->next;
		}
		addr = (char *)(amem->block+pos);
	}
	
	if (cutbuffer)
		free(cutbuffer);

	cutlength = thewin->endmark - thewin->startmark +1;

	if (cutlength > 0) /* bail out if end is before start */
	{
		cutbuffer = malloc((unsigned)(cutlength+2));
		if (cutbuffer)
		{
			long tocopy = cutlength;
			int bufbytes = (int)(amem->inuse - pos);
			char *addr2 = cutbuffer;
		
			while(tocopy > 0)
			{
				int	num = ((int)tocopy < bufbytes) ? (int)tocopy : bufbytes;

				memcpy( addr2, addr, (long)num );
				tocopy -= bufbytes;
				if (tocopy > 0)
				{
					amem = amem->next;
					addr = amem->block;
					bufbytes = (int)(amem->inuse);
					addr2 += num;
				}	
			}
			*(cutbuffer + cutlength ) = 0;
		}
		else
			rsc_alert(NOMEM_BUF);
	}
}		

/*
	name: paste
	utility: 	paste the cutbuffer into the file before the cursor
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void paste(windowptr	thewin)
{
	char *modeptr;

		/* paste will replace/overwrite if ins = FALSE otherwise inserts */
	modeptr = (ins?modein:moderp) + 2;	/* skip the 2 spaces */
		
	if (rsc_falert(PASTEMODE, modeptr) != 2)
	{
		if( !ins )
		{  /* cut out cutlength bytes */
			thewin->startmark = thewin->position;
			thewin->position += cutlength;
			thewin->position = thewin->position<thewin->flen-1 ?
								 thewin->position : thewin->flen-1;
			thewin->endmark = thewin->position -1;
			thewin->markson = TRUE;
			cutit(thewin);
			thewin->changed = TRUE;
				/* following code just clears the marks  */
			thewin->startmark = 1;
			thewin->endmark = 0;
			thewin->markson = FALSE;
		}
		insert_it( thewin, cutlength, cutbuffer );
		send_vslid(thewin);
		send_redraw(thewin);
	}
}

/*
	name: insert_it
	utility: insert_it() inserts incopy bytes from string pointed to by addr2
	into the file before the position of the cursor 
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void insert_it(windowptr thewin, long incopy, char *addr2)
{
	long pos;
	long insertpos = thewin->position;
	long tocopy = incopy;
	linkbufptr	amem;
	char *posaddr,*addr;
	int	havenow, num, tomoveup;
	
	while (tocopy > 0)
	{
			/* calculate amem that cursor is in */
		pos = insertpos;
		amem = thewin->headptr;
		while (amem->inuse < pos)
		{
			pos -= amem->inuse;
			amem = amem->next;
		}
		posaddr = (char *)(amem->block+pos);

		if (amem->inuse == BLOCKSIZE)
		{
				/* free up some space for the insert */
			if (insert_member(amem))  /* no more memory available  */
			{
				rsc_alert(NOMEM_1);
	 			break;
			}
				/* recalculate pos and amem */
			pos = insertpos;
			amem = thewin->headptr;
			while (amem->inuse <= pos)
			{
				pos -= amem->inuse;
				amem = amem->next;
			}
			posaddr = (char *)(amem->block+pos);
		}
	/* pos is now position of cursor in number of bytes from amem->block */

		addr = posaddr;
		havenow = BLOCKSIZE - (int)amem->inuse;
		num = ((int)tocopy < havenow) ? (int)tocopy : havenow;
		for(tomoveup = (int)(amem->inuse - pos-1);(int)tomoveup>-2;tomoveup--) 
			*(addr+tomoveup+num) = *(addr+tomoveup);
		memmove( addr, addr2, (long)num );
		amem->inuse += num;
		addr2 += num;
		insertpos += num;	
		tocopy -= num;
	}
	thewin->flen += incopy;
	thewin->changed = TRUE;
}

/*
	name: start_mark
	utility: 
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void start_mark(windowptr thewin)
{
	thewin->startmark = thewin->position;

	if( (thewin->startmark <= thewin->endmark)
			|| thewin->markson )
	{
		send_redraw(thewin);
		thewin->markson = TRUE;
		update_menu();
	}	
}

/*
	name: end_mark
	utility: 
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void end_mark(windowptr	thewin)
{	
	thewin->endmark = thewin->position<thewin->flen-1 ?
							 thewin->position : thewin->flen-2;

	if( (thewin->endmark >= thewin->startmark)
			|| thewin->markson )
	{
		send_redraw(thewin);
		thewin->markson = TRUE;
		update_menu();
	}
}

/*
	name: clear_marks
	utility: 
	comment: 
	parameters:
	return:
	date: 1989
	author: Jim Charlton
	modifications:
		1995: C. Moreau: 
*/
void clear_marks(windowptr	thewin)
{
	thewin->startmark = 1;
	thewin->endmark = 0;
	send_redraw(thewin);
/*	one_page(thewin); */
	thewin->markson = FALSE;
	update_menu();
}
