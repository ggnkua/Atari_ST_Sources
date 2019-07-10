#include <gemdefs.h>
#include <obdefs.h>
#include <osbind.h>
#include <stdio.h>
#include "xxed.h"  

#include "globals.h"


delete_one(thewin,pos,flag) /* delete one byte */
	windowptr	thewin;
	long		pos;
	int	flag;
{
		linkbufptr amem;
		char *addr, *addr2;
		int	button;

/*	flag is 0 when saving the file in which case can delete last byte */
	if( (thewin->position==thewin->flen-1) && flag) /* last byte */
	{	button = form_alert(1, "[1][ The last byte in the file is | a dummy byte and cannot be | changed or deleted. It is | not saved with the file. ][ OK ]");				
		return;
	}			 

		amem = thewin->headptr;
		while (amem->inuse<=pos)
			{	pos = pos - amem->inuse;
				amem = amem->next;
			}
		addr = (char *)(amem->block+pos);
	for (addr2=addr;addr2<(char *)amem->block+amem->inuse;addr2++)
		*addr2 = *(addr2+1);  

		amem->inuse--;
		thewin->flen--; 
	if(thewin->position>=thewin->flen) 
		thewin->position= thewin->flen-1; 
	if(flag)	/* don't set to partial if deleting last byte in file	*/
		thewin->changed = TRUE;
}

cutit(thewin) /* cut out the marked text   */
	windowptr	thewin;
{
	char		*addr;
	linkbufptr	amem;
	long		pos, togo;
	int			inthis, dummy;

	pos = thewin->startmark;
	    if (pos<=thewin->flen)
	{	amem = thewin->headptr;
		while (amem->inuse <= pos)
			{	pos = pos - amem->inuse;
				amem = amem->next;
			}
		inthis = amem->inuse - pos;
	}
	togo = thewin->endmark - thewin->startmark + 1;
	if(togo > 0)
	{	while (inthis < togo)
		{	amem->inuse = pos;
			if(amem->inuse==0)
				dispose_member(thewin,amem);
			amem = amem->next;
			togo -= inthis;
			thewin->flen -= inthis;
			inthis = amem->inuse;
			pos = 0;
		}
		if(togo > 0)
		{	bcopy(amem->block+pos+togo,amem->block+pos,
								(int)(amem->inuse-togo-pos));
			amem->inuse -= togo;
			thewin->flen -= togo;
		}
	}
	thewin->position = thewin->startmark;
	if(thewin->topchar >= thewin->position) 
		thewin->topchar = thewin->position&~0x7;   
}


copy(thewin) /* copy the marked text to the cutbuffer */
	windowptr	thewin;
{
	linkbufptr	amem;
	long		pos;
	long		tocopy;
	int			bufbytes, num, button;
	char		*addr, *addr2;

	pos = thewin->startmark;

	    if (pos<=thewin->flen)
	{	amem = thewin->headptr;
		while (amem->inuse <= pos)
			{	pos = pos - amem->inuse;
				amem = amem->next;
			}
		addr = (char *)(amem->block+pos);
	}
	

	if(cutbuffer) free(cutbuffer);
	cutlength = thewin->endmark - thewin->startmark +1;
	tocopy = cutlength;
	if (cutlength<=0) return; /* bail out if end is before start */
	cutbuffer = malloc((unsigned)(tocopy+2));

	if (cutbuffer == NULL)
	{	button = form_alert(1, "[1][ Sorry! | Out of memory creating cut buffer. ][OK]");
		return;
	}

	bufbytes = amem->inuse - pos;
	addr2 = cutbuffer;

	while(tocopy > 0)
		{	num = (tocopy < bufbytes) ? tocopy : bufbytes;
			bcopy(addr,addr2,num);
			tocopy -= bufbytes;
		if(tocopy > 0)
			{	amem = amem->next;
				addr = amem->block;
				bufbytes = amem->inuse;
				addr2 += num;
			}	
		}
	*(cutbuffer + cutlength ) = 0;
}		

paste(thewin) /* paste the cutbuffer into the file before the cursor */
	windowptr	thewin;
{
	insert_it(thewin,cutlength,cutbuffer);
	send_vslid(thewin);
	send_redraw(thewin);
}

/* insert_it() inserts incopy bytes from string pointed to by addr2
   into the file before the position of the cursor
*/

insert_it(thewin,incopy,addr2)
	windowptr	thewin;
	long	incopy;
	char	*addr2;
{
	long		pos, insertpos, tocopy;
	linkbufptr	amem;
	char		*posaddr,*addr,*addr3,*addr4;
	int			havenow, num, tomoveup, button, ret;

	insertpos = thewin->position;
	tocopy = incopy;
	while(tocopy>0)
	{
		/* calculate amem that cursor is in */
		pos = insertpos;
			{	amem = thewin->headptr;
				while (amem->inuse < pos)
				{	pos = pos - amem->inuse;
					amem = amem->next;
				}
			posaddr = (char *)(amem->block+pos);
			}
		if (amem->inuse == BLOCKSIZE)
		{
			ret = insert_member(amem);	/* free up some space for the insert */
		if (ret == -1)  /* no more memory available  */
	{   	button = form_alert(1, "[1][ Out of memory. | Partial insert. ][OK]");
	 		break;
	}	/* recalculate pos and amem */
			pos = insertpos;
			{	amem = thewin->headptr;
				while (amem->inuse <= pos)
				{	pos = pos - amem->inuse;
					amem = amem->next;
				}
			posaddr = (char *)(amem->block+pos);
			}
		}
	/* pos is now position of cursor in number of bytes from amem->block */

		addr = posaddr;
		havenow = BLOCKSIZE - amem->inuse;
		num = (tocopy < havenow) ? tocopy : havenow;
		for(tomoveup = amem->inuse - pos-1;tomoveup>-2;tomoveup--) 
			*(addr+tomoveup+num) = *(addr+tomoveup);
		bcopy(addr2,addr,num);
		amem->inuse += num;
		addr2 += num;
		insertpos += num;	
		tocopy -= num;
	}
	thewin->flen += incopy;
}

