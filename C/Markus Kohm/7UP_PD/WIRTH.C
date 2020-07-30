/* Analysiert ”ffnende und korrespondierende schlieáende Klammern */
/*****************************************************************************
*
*											  7UP
*                             Modul: WIRTH.C
*									 (c) by TheoSoft '90
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <string.h>
#include <aes.h>

#include "7up.h"
#include "forms.h"
#include "windows.h"

extern LINESTRUCT *lastwstr;
extern long		  lasthfirst,begline, endline;
extern int cut;

int Wirth(WINDOW *wp, LINESTRUCT *begcut ,LINESTRUCT *endcut ,char *begstr, char *endstr, long *lc, int *col)
{
   register LINESTRUCT *line;
	register char *cp;
	register int klammer=0, beglen, endlen;

	beglen=strlen(begstr);
	endlen=strlen(endstr);
	
   if(wp)
   {
		if(begcut)
		   line=begcut;
		else
			line=wp->fstr;
		*lc=(begcut && endcut)?begline:0L;
		while((endcut?(line!=endcut->next):line) && (klammer>=0))
		{
		   cp=line->string;
		   do
		   {
		      cp=strstr(cp,begstr);
		      if(cp)
		      {
		         klammer++;
		         cp+=beglen;
		      }
		   }
		   while(cp);
		   cp=line->string;
		   do
		   {
		      cp=strstr(cp,endstr);
		      if(cp)
		      {
		         klammer--;
		         cp+=endlen;
		      }
		   }
		   while(cp);
		   line=line->next;
		   (*lc)++;
		}
	}
	(*lc)--;
	*col=0;
	return(klammer);
}

int isfreepattern(OBJECT *tree, char *str)
{
	register int i;
	char pattern[11];

	if(*str)
	{
		for(i=FREE1BRACE; i<=FREE5BRACE; i+=3)
			if(tree[i].ob_state & SELECTED)
				if(strstr(form_read(tree,i+1,pattern),str))
					return(i+1);
	}
	return(FALSE);
}

int Wirth2(WINDOW *wp, LINESTRUCT **begcut, LINESTRUCT **endcut, char *begstr, char *endstr)
{
	LINESTRUCT *line,*begcutsave,*endcutsave;
	register char *cp;
	register int begin=0, end=0, beglen, endlen;
	long count=0;
	int i,y,begcolsave,endcolsave;
	
	beglen=strlen(begstr);
	endlen=strlen(endstr);
	
	if(wp)
	{
	   line=(*begcut);
	   begcutsave=line;
	   begcolsave=line->begcol;

      if((cp=strstr(line->string,begstr))!=NULL)
		   begcolsave=(int)(cp-line->string);

	   do
	   {
		   cp=line->string;
		   do
		   {
		      cp=strstr(cp,begstr);
		      if(cp)
		      {
		         begin++;
		         cp+=beglen;
		      }
		   }
		   while(cp);
		   cp=line->string;
		   do
		   {
		      cp=strstr(cp,endstr);
		      if(cp)
		      {
		         end++;
		         cp+=endlen;
		         endcutsave=line;
					endcolsave=(int)(cp-line->string);
		      }
		   }
		   while(cp);
		   count++;
		   line=line->next;
	   }
	   while(line && begin!=end);
	   if(/*line &&*/ begin==end && begin>0 && end>0)
	   {
			hide_blk(wp,*begcut,*endcut);
			lastwstr=wp->wstr;
			lasthfirst=wp->hfirst;
			begline=wp->row+wp->hfirst/wp->hscroll;
			endline=begline+count-1; /*19.3.94 eine Zeile zuviel*/

			(*begcut)=begcutsave;
			(*endcut)=endcutsave;
			if(*begcut == *endcut)
			{
				(*begcut)->begcol=begcolsave;
				(*endcut)->endcol=endcolsave;
			}
			else
			{			
				(*begcut)->begcol=begcolsave;
				(*begcut)->endcol=STRING_LENGTH;
				(*endcut)->begcol=0;
				(*endcut)->endcol=endcolsave;
			}
			for(line=(*begcut); line != (*endcut)->next; line=line->next)
			{
				line->attr|=SELECTED;										 /* attribut setzen */
			}
			if((*begcut) != (*endcut)) /* mehr als eine zeile */
				for(line=(*begcut)->next; line && line != (*endcut); line=line->next)
				{
					line->begcol=0;
					line->endcol=STRING_LENGTH;
				}
			graf_mouse(M_OFF,0L);
			Wcursor(wp);
			for(line=wp->wstr,i=0,y=wp->ywork;
				 line && y<(wp->ywork+wp->hwork-1);
				 line=line->next, i++, y+=wp->hscroll)
				if(line->attr & SELECTED)
				{
					mark_line(wp,line,i);
				}
			Wcuroff(wp);
			Wcursor(wp);
/*
			graf_mouse(M_ON,0L);
*/
			return(TRUE);
	   }
	}
	return(FALSE);
}
