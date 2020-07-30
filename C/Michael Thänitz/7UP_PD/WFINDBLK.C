/*Sucht und markiert Block bei wiederge”ffneten Fenster*/
/*****************************************************************************
*
*											  7UP
*									  Modul: WFINDBLK.C
*									 (c) by TheoSoft '92
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <aes.h>

#include "windows.h"
#include "undo.h"

WINDOW *Wfindblk(WINDOW *wp, WINDOW **blkwp, LINESTRUCT **beg, LINESTRUCT **end)
{
	LINESTRUCT *line;		 /* markierten Block im neuen Fenster suchen */
	long bl=0L;
	extern LINESTRUCT *lastwstr;
	extern long lasthfirst,begline,endline;
	extern int cut;
	extern char searchstring[];

	if(wp && beg && end)
	{
		for(line=wp->fstr; line; line=line->next,bl++)
		{
			if(line->attr & SELECTED)
			{
				if(cut && *beg && *end)	  /* erst noch Ramblock l”schen */
					free_blk(wp,*beg);
				begline=endline=bl;
				lasthfirst=bl*wp->hscroll;
				lastwstr=line;

				(*beg)=(*end)=line;
				for(line=line->next; line && line->next; line=line->next)
				{
					if(!(line->attr & SELECTED))
					{
						if((*beg)->begcol==0 && (*end)->endcol==STRING_LENGTH)
							endline++;
						(*blkwp)=wp;
						return(wp);
					}
					else
					{
						endline++;
						(*end)=line;
					}
				}
				(*blkwp)=wp;
				return(wp);
			}
		}
		if(!cut) /* zumindest kein Block in diesem Fenster */
		{
			(*beg)=(*end)=NULL;
			begline=endline=0L;
		}
	}
	return(NULL);
}

int Wrestblk(WINDOW *wp, UNDO *undo, LINESTRUCT **beg, LINESTRUCT **end)
{
	register long i;
	LINESTRUCT *line;
	register int y;
	extern long begline, endline, lasthfirst;
	extern LINESTRUCT *lastwstr;
	
	if(wp)
	{
		lasthfirst=undo->wline*wp->hscroll;
		begline=undo->begline;
		endline=undo->endline;
		line=wp->fstr;
		for(i=0; i<undo->wline; i++, line=line->next)
			;
		lastwstr=line;
		for(i; i<begline; i++, line=line->next)
			;
		*end=*beg=line;
		(*beg)->begcol=undo->begcol;
		(*beg)->endcol=undo->endcol;
		for(i; i<endline; i++, line=line->next)
		{
			(*end)=line;
			(*end)->attr|=SELECTED;
			(*end)->begcol=undo->begcol;
			(*end)->endcol=undo->endcol+(undo->blktype==COLUMN?undo->begcol:0);
		}
		if(undo->blktype==COLUMN)
			wp->cspos=(wp->col+=undo->endcol);
		if((undo->blktype!=COLUMN) && ((*beg) != (*end))) /* mehr als eine zeile */
		{
			(*beg)->endcol=STRING_LENGTH;
			(*end)->begcol=0;
			for(line=(*beg)->next; line && line != (*end); line=line->next)
			{
				line->begcol=0;
				line->endcol=STRING_LENGTH;
			}
		}
  		endline--;
		if((*beg)->begcol==0 && (*end)->endcol>=(*end)->used)
			endline++;
		for(line=wp->wstr,i=0,y=wp->ywork;
			 line && y<(wp->ywork+wp->hwork-1);
			 line=line->next, i++, y+=wp->hscroll)
			if(line->attr & SELECTED)
			{
				mark_line(wp,line,i);
			}
		Wcuroff(wp);
		return(TRUE);
	}
	return(FALSE);
}
