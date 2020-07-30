/* Textblîcke bearbeiten */
/*****************************************************************************
*
*											 7UP
*									  Modul: BLOCK.C
*									(c) by TheoSoft '90
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <aes.h>
#include <vdi.h>

#include "alert.h"

#include "7up.h"
#include "windows.h"

#include "undo.h"

#define VERTICAL	1
#define HORIZONTAL 2

void Wtxtdraw();
void mark_line(WINDOW *wp, LINESTRUCT *str, int line);
LINESTRUCT *beg_blk(WINDOW *wp, LINESTRUCT *cutbeg, LINESTRUCT *cutend);
LINESTRUCT *end_blk(WINDOW *wp, LINESTRUCT **cutbeg, LINESTRUCT **cutend);
int cut_blk(WINDOW *wp, LINESTRUCT *cutbeg, LINESTRUCT *cutend);
int copy_blk(WINDOW *wp, LINESTRUCT *cutbeg, LINESTRUCT *cutend, LINESTRUCT **copybeg, LINESTRUCT **copyend);
void paste_blk(WINDOW *wp,LINESTRUCT *beg,LINESTRUCT *end);
int cut_col(WINDOW *wp, LINESTRUCT *cutbeg, LINESTRUCT *cutend);
int copy_col(WINDOW *wp, LINESTRUCT *cutbeg, LINESTRUCT *cutend, LINESTRUCT **copybeg, LINESTRUCT **copyend);
void paste_col(WINDOW *wp,LINESTRUCT *beg,LINESTRUCT *end);
int ins_char(WINDOW *wp,LINESTRUCT *line, int c); /* neues zeichen einfÅgen */
int ins_line(WINDOW *wp);								 /* neue zeile einfÅgen */
int backspace(WINDOW *wp,LINESTRUCT *line);		 /* zeichen lîschen */
int del_char(WINDOW *wp,LINESTRUCT *line);			/* zeichen lîschen */
int del_line(WINDOW *wp);								 /* zeile lîschen */
int cat_line(WINDOW *wp);								 /* zeilen verbinden */
void hide_blk(WINDOW *wp,LINESTRUCT *beg,LINESTRUCT *end);
void free_blk(WINDOW *wp,LINESTRUCT *line);
void shlf_line(WINDOW *wp, LINESTRUCT *begcut,  LINESTRUCT *endcut);
void shrt_line(WINDOW *wp, LINESTRUCT *begcut,  LINESTRUCT *endcut);
int adjust_best_position(WINDOW *wp);
refresh(WINDOW *wp, LINESTRUCT *line, int col, int row);
void swap(int *, int *);

extern int vdihandle,xdesk,ydesk,wdesk,hdesk;
extern int /*clipbrd,*/cut;

extern LINESTRUCT *lastwstr;
extern long		lasthfirst;
extern long		begline,	 endline;
static WINDOW *copywindow;

LINESTRUCT *beg_blk(WINDOW *wp, LINESTRUCT *begcut, LINESTRUCT *endcut)
{
	if(!wp)
		return(NULL);
	if(cut)				  /* gibt es erst noch mÅll zu lîschen */
		free_blk(wp,begcut);
	else
		hide_blk(wp,begcut,endcut);
	lastwstr=wp->wstr;
	lasthfirst=wp->hfirst;
	begcut=wp->cstr;										/* blk beginn */
	begcut->begcol=wp->col+wp->wfirst/wp->wscroll; /* erste spalte */
	begcut->endcol=STRING_LENGTH;
	begline=wp->row+wp->hfirst/wp->hscroll;		  /* erste zeile */
	copywindow=wp;
	return(begcut);
}

LINESTRUCT *end_blk(WINDOW *wp, LINESTRUCT **begcut, LINESTRUCT **endcut)	/* blockende */
{
	register LINESTRUCT *help;
	register long i,y,line;

	*endcut=NULL;		 /* erstmal */
	if(!wp)
		return(NULL);
	if(wp!=copywindow)
		return(NULL);
	copywindow=NULL;

	if(*begcut && !(wp->w_state&COLUMN))									  /* mindestens eine zeile */
	{
		endline=wp->row+wp->hfirst/wp->hscroll;		  /* fÅr zeilendifferenz */
		*endcut=wp->cstr;									  /* ende markieren */
		(*endcut)->endcol=wp->col+wp->wfirst/wp->wscroll; /* letzte spalte */
		if(*begcut!=*endcut)				 /* Anfang nicht Åberschreiben */
			(*endcut)->begcol=0;
		if(*begcut==*endcut)
			if((*begcut)->begcol>(*endcut)->endcol)
				swap(&(*begcut)->begcol,&(*endcut)->endcol);
		if(begline>endline)
		{
/* Das fehlte hier!!! Erik Dick */
			lastwstr=wp->wstr;
			lasthfirst=wp->hfirst;

			help=*endcut;
			*endcut=*begcut;
			*begcut=help;

			line=begline;
			begline=endline;
			endline=line;

			(*begcut)->begcol=(*begcut)->endcol;
			(*begcut)->endcol=STRING_LENGTH;

			(*endcut)->endcol=(*endcut)->begcol;
			(*endcut)->begcol=0;
		}
		if((*endcut)->endcol==0)  /* wenn spalte=0, (*endcut) zurÅcksetzen... */
		{
			if((*endcut) != (*begcut))  /* ...wenn (*endcut) > (*begcut)					*/
			{
				(*endcut)=(*endcut)->prev;
				if((*begcut) != (*endcut))
					(*endcut)->begcol=0;
				(*endcut)->endcol=STRING_LENGTH;
				endline--;
			}
			else
				return(NULL);
		}
		if((*begcut)->begcol==0 && (*endcut)->endcol>=(*endcut)->used)
		{
			endline++;
		}
		for(help=(*begcut); help != (*endcut)->next; help=help->next)
		{
			help->attr|=SELECTED;										 /* attribut setzen */
		}
		if((*begcut) != (*endcut)) /* mehr als eine zeile */
			for(help=(*begcut)->next; help && help != (*endcut); help=help->next)
			{
				help->begcol=0;
				help->endcol=STRING_LENGTH;
			}
		for(help=wp->wstr,i=0,y=wp->ywork;
			 help && y<(wp->ywork+wp->hwork-1);
			 help=help->next, i++, y+=wp->hscroll)
			if(help->attr & SELECTED)
			{
				mark_line(wp,help,i);
			}
	}
	if((*begcut) && (wp->w_state&COLUMN)) /* Spaltenblock setzen */
	{
		endline=wp->row+wp->hfirst/wp->hscroll;		  /* fÅr zeilendifferenz */
		(*endcut)=wp->cstr;										/* ende markieren */
		(*endcut)->begcol=(*begcut)->begcol;
		(*begcut)->endcol=(*endcut)->endcol=wp->col+wp->wfirst/wp->wscroll; /* letzte spalte */
		if(begline>endline)
		{
			help=(*endcut);
			(*endcut)=(*begcut);
			(*begcut)=help;

			line=begline;
			begline=endline;
			endline=line;
		}
		if((*begcut)->begcol>(*endcut)->endcol)
			swap(&(*begcut)->begcol,&(*endcut)->endcol);
		for(help=(*begcut); help != (*endcut)->next; help=help->next)
		{
			help->attr|=SELECTED;										 /* attribut setzen */
		}
/*
		if((*begcut) != (*endcut)) /* mehr als eine zeile */
*/
			for(help=(*begcut); help && help != (*endcut)->next; help=help->next)
			{
				help->begcol=(*begcut)->begcol;
				help->endcol=(*endcut)->endcol;
			}
		for(help=wp->wstr,i=0,y=wp->ywork;
			 help && y<(wp->ywork+wp->hwork-1);
			 help=help->next, i++, y+=wp->hscroll)
			if(help->attr & SELECTED)
			{
				mark_line(wp,help,i);
			}
	}
	return(*endcut);
}

void mark_all(WINDOW *wp, LINESTRUCT **begcut, LINESTRUCT **endcut)
{
	register long i,y,maxlen=0;
	LINESTRUCT *help;
	long lines,chars;
	if(wp)
	{
		Wtxtsize(wp,&lines,&chars);
		if(lines && chars)
		{
			if(cut)				  /* gibt es erst noch mÅll zu lîschen */
				free_blk(wp,*begcut);
			else
				hide_blk(wp,*begcut,*endcut);
			if((wp->w_state&COLUMN))
			{
				for(help=wp->fstr; help; help=help->next)
					maxlen=max(help->used,maxlen);
			}
			lastwstr=wp->wstr;
			lasthfirst=wp->hfirst;
/* MT 12.5.95
			begline=1L;
			endline=1L;
*/
			begline=endline=0L;
			for(*begcut=help=wp->fstr; help; help=help->next)
			{
				endline++;
				help->attr|=SELECTED;
				help->begcol=0;
				help->endcol=((wp->w_state&COLUMN)?maxlen:STRING_LENGTH);
				*endcut=help;
			}
			for(help=wp->wstr,i=0,y=wp->ywork;
				 help && y<(wp->ywork+wp->hwork-1);
				 help=help->next, i++, y+=wp->hscroll)
			{
				if(help->attr & SELECTED)
					mark_line(wp,help,i);
			}
			return;
		}
	}
	*begcut=*endcut=NULL;
}

/* auszuschneidedenden Blockanfang und -ende verschieben bzw. kÅrzen */
static beg_end(LINESTRUCT *begcut, LINESTRUCT *endcut)/* korrekt */
{
	strcpy(begcut->string,&begcut->string[begcut->begcol]);
	endcut->string[min(endcut->used,endcut->endcol)-endcut->begcol]=0;
	begcut->used=strlen(begcut->string);
	endcut->used=strlen(endcut->string);
	begcut->begcol=0;			/* anfang erst zum schluû Ñndern */
	endcut->begcol=0;
}

static LINESTRUCT *newline(LINESTRUCT *begcut, LINESTRUCT *endcut)
{
	LINESTRUCT *new;

	if((new=malloc(sizeof(LINESTRUCT)))==NULL)
		return(NULL);							/* was ist wenn endcut NULL ist??? */
	if((new->string=malloc(begcut->begcol+(endcut->used-min(endcut->endcol,endcut->used))+1))==NULL)
	{
		free(new);
		return(NULL);
	}
	strncpy(new->string,begcut->string,begcut->begcol);
	strcpy(&new->string[begcut->begcol],&endcut->string[min(endcut->endcol,endcut->used)]);
	new->len=new->used=strlen(new->string);
	if(!new->used)
	{
		free(new->string);
		free(new);
		return(NULL);
	}
	new->prev=new->next=NULL;
	new->begcol=0;
	new->endcol=STRING_LENGTH;
	new->attr=0;
	new->effect=0;
	beg_end(begcut,endcut);		/* erste und letzte Zeile, */
											 /* verschieben bzw. kÅrzen */
	return(new);
}

static LINESTRUCT *newwstr(WINDOW *wp, long begline)
{
	LINESTRUCT *line;
	register long i;
	for(i=0,line=wp->fstr; i<begline; i++)
		line=line->next;
	return(line);
}

int cut_blk(WINDOW *wp, LINESTRUCT *beg,  LINESTRUCT *end)  /* ausschneiden */
{
	register LINESTRUCT *new,*help;
	register long i,y,lline=FALSE;
	int full[4],area[4];
	long hfirst;
	GRECT rect;

	if(!wp)
		return(FALSE);

	if(beg && end && endline>=begline ) /* anfang und ende mÅssen bekannt sein */
	{
		for(help=wp->wstr,i=0,y=wp->ywork;
			 help && y<(wp->ywork+wp->hwork-1);
			 help=help->next, i++, y+=wp->hscroll)
			if(help->attr & SELECTED)
				mark_line(wp,help,i);
		for(help=beg; help != end->next; help=help->next)
			help->attr&=~SELECTED;

		if(!beg->prev && !end->next) /* gesammten Text cuten */
		{
/**/
			wp->cspos=wp->col=wp->row=0;
/**/
			wp->hfirst=wp->hsize=0;
			if((wp->cstr=newline(beg,end))==NULL) /* neue Zeile, umkopieren  */
				ins_line(wp);
			else
				wp->hsize=wp->hscroll;
			wp->cstr->prev=wp->cstr->next=NULL;
			wp->fstr=wp->wstr=wp->cstr;
			Wredraw(wp,&wp->xwork);
			wp->w_state |= CHANGED;
			return(TRUE);
		}
/* entfernt, wurde massiv kritisiert
		if(isspace(end->string[end->endcol])) /* intelligent CUT */
		{
			for(i=end->endcol; i<wp->cstr->used; i++)
				if(isspace(end->string[i]))
					break;
			for(i; i<wp->cstr->used; i++)
				if(!isspace(end->string[i]))
					break;
			end->endcol=i;
		}
*/
		wp->cspos=wp->col=beg->begcol;/* beg->begcol geht in newline()/beg_end() verloren */
		wp->row=begline-wp->hfirst/wp->hscroll;
		if((new=newline(beg,end))!=NULL) /* neue Zeile, umkopieren  */
		{
			if(beg->prev)						 /* Zeile davor vorhanden */
			{
				beg->prev->next=new;		  /* Anfang verknÅpfen */
				new->prev=beg->prev;
				wp->cstr=new;						 /* cursor auf neuen Anfang */
			}
			else
			{
				wp->fstr=wp->wstr=wp->cstr=new;  /* erste Textzeile ist neu */
			}
			if(end->next)						 /* nachfolger vorhanden */
			{
				new->next=end->next;		  /* Ende verknÅpfen */
				end->next->prev=new;
			}
		}
		else											 /* keine neue Zeile */
		{
			if(beg->prev && end->next)  /* Text aus der Mitte */
			{
				beg->prev->next=end->next; /* Anfang... */
				end->next->prev=beg->prev; /* ... und Ende verknÅpfen */
				wp->cstr=end->next;			 /* Cursor setzen */
			}
			if(!beg->prev && end->next)	/* kein VorgÑnger, aber Nachfolger */
			{
				wp->fstr=wp->wstr=wp->cstr=end->next; /* Textanfang ausschneiden */
				wp->fstr->prev=NULL;
			}
			if(beg->prev && !end->next)	/* VorgÑnger, aber kein Nachfolger */
			{
				wp->cstr=beg->prev;			 /* Cursor setzen */
				wp->cstr->next=NULL;			  /* Ende markieren */
				wp->row--;
				lline=TRUE;
			 }
		}
/*  Neuberechnung der ersten Fensterzeile in AbhÑngigkeit der letzten Pos */
		wp->wstr=newwstr(wp,lasthfirst/wp->hscroll);

		wp->hsize-=(endline-begline) * wp->hscroll; /* LÑnge um Zeilendifferenz kÅrzen */
		hfirst=wp->hfirst;
		wp->hfirst=lasthfirst;							/* ...wiederherstellen  */

		if(!adjust_best_position(wp))				 /* Anfang muû nicht verschoben werden */
		{
			if(wp->hfirst==hfirst)						/* alte wp->wstr-position bleibt */
			{
				refresh(wp,wp->cstr,0,wp->row);
				if(begline!=endline)					 /* mehr als eine Zeile */
				{
					rect.g_x=wp->xwork;
					rect.g_y=wp->ywork + (wp->row+1) * wp->hscroll;
					rect.g_w=wp->wwork;
					rect.g_h=wp->hwork - (wp->row+1) * wp->hscroll;
					if(labs((endline-begline)*wp->hscroll) >= rect.g_h)
					{
						Wredraw(wp, &rect/*&wp->xwork*/);/* Bereich ganz neu zeichnen */
					}
					else
					{
						Wscroll(wp,VERTICAL,(endline-begline)*wp->hscroll,&rect);
					}
				}
			}
			else
			{
				Wredraw(wp,&wp->xwork);
			}
		}
		else
		{
			wp->row=begline-wp->hfirst/wp->hscroll; /* nochmal berechnen */
			if(endline-begline == 1)
			{
				rect.g_x=wp->xwork;
				rect.g_y=wp->ywork;
				rect.g_w=wp->wwork;
				rect.g_h=(wp->row) * wp->hscroll;
				Wscroll(wp,VERTICAL,-wp->hscroll,&rect);
				if(new)						 /* zusammengesetzte zeile */
					refresh(wp,new,0,wp->row);

/* Mu· drin bleiben, weil sonst vieles andere nicht mehr funktioniert */
				if((wp->cstr->prev && wp->cstr->next) || !lline)
				{								 /* cursor zurÅck positionieren */
					wp->cstr=wp->cstr->prev;
					wp->row--;
				}

			}
			else
			{
				Wredraw(wp,&wp->xwork);
			}
		}
		wp->w_state |= CHANGED;		  /* es wurde editiert */
		beg->prev=NULL;					 /* anfang und ende markieren */
		end->next=NULL;
		return(TRUE);
	}
	return(FALSE);
}

int copy_blk(WINDOW *wp, LINESTRUCT *beg,  LINESTRUCT *end,  LINESTRUCT **begcopy,  LINESTRUCT **endcopy)
{
	register LINESTRUCT *src,*dst,*help;
	register long i,y,len;

	if(!wp)
		return(FALSE);

	if(beg && end && endline>=begline)
	{
		for(help=wp->wstr,i=0,y=wp->ywork; help /*!= end->next*/ && y<(wp->ywork+wp->hwork-1); help=help->next, i++, y+=wp->hscroll)
			if(help->attr & SELECTED)
				mark_line(wp,help,i);
		for(help=beg; help != end->next; help=help->next)
			help->attr&=~SELECTED;

		*begcopy=NULL;
		if((dst=malloc(sizeof(LINESTRUCT))) != NULL) /* copy anfang */
		{
			*begcopy=dst;
			dst->prev=dst->next=NULL;
			for(src=beg; src != end->next; src=src->next) /* anzahl kopieren */
			{
				if(src->endcol<src->used)
					len=src->endcol-src->begcol;
				else
					len=src->used;
				if((dst->string=malloc(len + 1)) != NULL) /* allozieren  */
				{
					if(src->endcol<src->used)
					{
						strncpy(dst->string,&src->string[src->begcol],len);
						dst->string[len]=0;
					}
					else
						strcpy(dst->string,&src->string[src->begcol]);
					dst->len    = len;
					dst->used   = strlen(dst->string);
					dst->begcol = 0;
					dst->endcol = src->endcol;						 /*STRING_LENGTH;*/
					dst->attr   = (src->attr &= ~SELECTED);
					dst->effect = TXT_NORMAL;						/* attribute  */
					if(src != end)
					{
						help=dst;												 /* merken */
						if((dst->next=malloc(sizeof(LINESTRUCT))) != NULL) /* nÑchste zeile allozieren */
						{
							dst=dst->next;						  /* zeiger weiter */
							dst->prev=help;		  /* zeiger rÅckwÑrts verketten */
							dst->next=NULL;
							dst->attr   = 0;
							dst->effect = TXT_NORMAL;						/* attribute  */
						}
						else
							return(-1); /* kein RAM */
					}
					else
						break;
				}
				else
					return(-1);	  /* kein RAM */
			}
			dst->next=NULL; /* hier ist schluû */
			*endcopy=dst;
/* NEU: wenn CRLF erzeugt werden soll, also end->endcol=STRING_LENGTH */
/* Zeilenumbruch */
			if(src->endcol==STRING_LENGTH)
			{
				help=dst;													/* merken */
				if((dst->next=malloc(sizeof(LINESTRUCT))) != NULL) /* nÑchste zeile allozieren */
				{
					dst=dst->next;							 /* zeiger weiter */
					dst->prev=help;			 /* zeiger rÅckwÑrts verketten */
					dst->next=NULL;
					dst->attr=0;
					dst->effect=TXT_NORMAL;
					if((dst->string=malloc(NBLOCKS + 1)) != NULL)	/* allozieren  */
					{
						dst->string[0]=0;
						dst->len  = NBLOCKS;
						dst->used = 0;
						dst->begcol=0;
						dst->endcol=0;
						*endcopy=dst;
					}
					else /* zurÅck, weil kein RAM */
					{
						dst=dst->prev;
						free(dst->next);
						dst->next=NULL;
					}
				}
/*******/
			}
			return(TRUE);
		}
		return(-1);				  /* kein RAM */
	}
	return(FALSE);
}

void paste_blk(WINDOW *wp,LINESTRUCT *beg, LINESTRUCT *end)
{
	register LINESTRUCT *help;
	register int abscol;
	GRECT rect;
	long lines, chars, oldsize;
	char *help1,*help2;
	int full[4],area[4];

	if(!wp)
		return;
	if(beg && end)
	{
		abscol=wp->col+wp->wfirst/wp->wscroll; /* absolute Spalte */

		if(abscol>wp->cstr->used) /* beim neuformatieren */
			abscol=wp->cstr->used;

		if((help2=realloc(end->string,end->used+strlen(&wp->cstr->string[abscol])+1))==NULL)
			return;									  /* hinten zusammenkopieren */
		end->string=help2;

		strcat(end->string,&wp->cstr->string[abscol]);
		end->len=end->used=strlen(end->string);

		end->next=wp->cstr->next;
		if(wp->cstr->next)
			wp->cstr->next->prev=end;

		if((help1=realloc(wp->cstr->string,wp->cstr->used+beg->used+1))==NULL)
			return;										 /* vorn zusammenkopieren */
		wp->cstr->string=help1;

		strcpy(&wp->cstr->string[abscol],beg->string);
		wp->cstr->len=wp->cstr->used+beg->used;
		wp->cstr->used=strlen(wp->cstr->string);

		wp->cstr->next=beg->next;
		if(beg->next)
			beg->next->prev=wp->cstr;

		oldsize=wp->hsize;
		Wtxtsize(wp,&lines,&chars);
		wp->hsize=lines*wp->hscroll;

		refresh(wp,wp->cstr,wp->col,wp->row);
		rect.g_x=wp->xwork;
		rect.g_y=wp->ywork + (int)((wp->row+1) * wp->hscroll);
		rect.g_w=wp->wwork;
		rect.g_h=wp->hwork - (int)((wp->row+1) * wp->hscroll);
		if(wp->hsize-oldsize) /* !=0 */
		{
			if(labs(wp->hsize-oldsize) >= rect.g_h)
			{
				Wredraw(wp, &rect/*&wp->xwork*/); /* Bereich ganz neu zeichnen */
			}
			else
			{
				Wscroll(wp,VERTICAL,-(wp->hsize-oldsize),&rect);
			}
		}
		wp->w_state |= CHANGED;
	}
}

/**************************************************************************
*
*  Spaltenblockfunktionen
*
***************************************************************************/


int cut_col(WINDOW *wp, LINESTRUCT *beg,  LINESTRUCT *end)  /* ausschneiden */
{
	register long i,y,row,diff;
	static LINESTRUCT *begcopy,*endcopy;
	register LINESTRUCT *help;
	extern LINESTRUCT *begcut,*endcut;

	if(!wp)
		return(FALSE);

	if(beg && end && endline>=begline ) /* anfang und ende mÅssen bekannt sein */
	{
		if((cut=copy_col(wp,beg,end,&begcopy,&endcopy))>0)
		{
         wp->cspos=wp->col=beg->endcol-wp->wfirst/wp->wscroll; /* ans Ende setzen, wg. Block Åbertippen */
			diff=beg->endcol-beg->begcol;
			for(help=beg; help && help!=end->next; help=help->next)
			{
				if(help->endcol<help->used)
				{
					memmove(&help->string[help->begcol],&help->string[help->endcol],strlen(&help->string[help->endcol])+1);
				}
				else
				{
					if(help->begcol<help->used)/* evtl. Leerzeile berÅcksichtigen */
						help->string[help->begcol]=0;
				}
				help->used=strlen(help->string);
				help->attr&=~SELECTED;
			}
			for(help=wp->wstr,i=0,y=wp->ywork;
				 help && y<(wp->ywork+wp->hwork-1);
				 help=help->next, i++, y+=wp->hscroll)
				refresh(wp,help,beg->begcol-wp->wfirst/wp->wscroll,i);

			wp->col-=diff;
/**/
			wp->cspos-=diff;
/**/
			begcut=begcopy;
			endcut=endcopy;
			wp->w_state|=CHANGED;
			return(TRUE);
		}
	}
	return(FALSE);
}

void blank(char *s, int n)  /* evtl. mit blanks auffÅllen */
{
	register int k;
	k=strlen(s);
	if(k < n)
	{
		memset(&s[k],' ',n-k);
		s[n]=0;
	}
}

int copy_col(WINDOW *wp, LINESTRUCT *begcut,  LINESTRUCT *endcut,  LINESTRUCT **begcopy,  LINESTRUCT **endcopy)
{
	register LINESTRUCT *src,*dst,*help;
	register long i,y;
	if(!wp)
		return(FALSE);

	if(begcut && endcut && endline>=begline ) /* anfang und ende mÅssen bekannt sein */
	{
		for(help=wp->wstr,i=0,y=wp->ywork; help /*!= end->next*/ && y<(wp->ywork+wp->hwork-1); help=help->next, i++, y+=wp->hscroll)
			if(help->attr & SELECTED)
				mark_line(wp,help,i);
		for(help=begcut; help != endcut->next; help=help->next)
			help->attr&=~SELECTED;

		*begcopy=NULL;
		if((dst=malloc(sizeof(LINESTRUCT))) != NULL) /* copy anfang */
		{
			*begcopy=dst;
			dst->prev=dst->next=NULL;
			for(src=begcut; src != endcut->next; src=src->next) /* anzahl kopieren */
			{
				if((dst->string=malloc(src->endcol-src->begcol + 1)) != NULL)  /* allozieren  */
				{
					if(src->begcol < src->used)				/* block < stringlÑnge */
					{
						strncpy(dst->string,&src->string[src->begcol],
							src->endcol-src->begcol);		/* block herauskopieren */
						dst->string[src->endcol-src->begcol]=0;	  /* ende setzen */
						blank(dst->string,src->endcol-src->begcol);/* evtl. blanks */
					}
					else			/* block jenseits stringende, mit blanks fÅllen */
					{
						memset(dst->string,' ',src->endcol-src->begcol);
						dst->string[src->endcol-src->begcol]=0;
					}
					dst->used = dst->len = strlen(dst->string);	/* lÑnge		 */
/*
					fprintf(stderr,"%s\n",dst->string);
*/
					dst->begcol=0;			  /*src->begcol;*/
					dst->endcol=dst->used;	 /*src->endcol;*/
					dst->attr  =(src->attr &= ~SELECTED);							/* attribute  */
					dst->effect=TXT_NORMAL;
					if(src != endcut)
					{
						help=dst;													 /* merken */
						if((dst->next=malloc(sizeof(LINESTRUCT))) != NULL) /* nÑchste zeile allozieren */
						{
							dst=dst->next;							 /* zeiger weiter */
							dst->prev=help;			 /* zeiger rÅckwÑrts verketten */
							dst->next=NULL;
						}
						else
							return(-1);  /* kein RAM */
					}
					else
						break;
				}
				else
					return(-1);		/* kein RAM */
			}
			dst->next=NULL; /* hier ist schluû */
			*endcopy=dst;
			return(TRUE);
		}
		return(-1);					/* kein RAM */
	}
	return(FALSE);
}

char *strins(char *dst, char *ins, int idx)
{
	memmove(&dst[idx+strlen(ins)],&dst[idx],strlen(&dst[idx])+1);
	memmove(&dst[idx],ins,strlen(ins));
	return(dst);
}

static int ins_str(LINESTRUCT *dst, LINESTRUCT *src, int abscol) /* einfÅgen */
{
	char *help;
	int len;
	if(abscol < dst->used) /* jenachdem ob abscol > dst->used */
	{
		len=dst->used+src->used;
	}
	else
	{
		len=abscol+src->used;
	}
	if(dst->len < len)					/* neue lÑnge > alte */
	{
		if((help=realloc(dst->string,len+1))==NULL)
		{
			return(FALSE);
		}
		dst->string=help;
		dst->len=len;
	}
	if(abscol < dst->used)					 /* innerhalb des strings einfÅgen */
	{
		strins(dst->string, src->string, abscol);
	}
	else																 /* hinten anhÑngen */
	{
		memset(&dst->string[dst->used],' ',abscol-dst->used); /* blanks auffÅllen */
		dst->string[abscol]=0;
		strcat(dst->string,src->string);
	}
	dst->len=dst->used=strlen(dst->string);
	return(TRUE);
}

void paste_col(WINDOW *wp,LINESTRUCT *beg, LINESTRUCT *end)
{
	register LINESTRUCT *dst,*src;
	register long i,y,abscol,count=0;
	GRECT rect;

	if(!wp)
		return;

	if(beg && end)
	{
		abscol=wp->col+wp->wfirst/wp->wscroll;
		for(dst=wp->cstr,src=beg;
			 dst && src!=end->next;
			 dst=dst->next,src=src->next)
		{
			if(!ins_str(dst,src,abscol))
			{
				form_alert(1,Ablock[0]);
				break;
			}
			count++;
		}
		for(i=wp->row,dst=wp->cstr;
			 i<wp->row+count && i<wp->hwork/wp->hscroll && dst;
			 i++,dst=dst->next)
			refresh(wp,dst,wp->col,i);
		wp->w_state |= CHANGED;
	}
}

void hide_blk(WINDOW *wp, LINESTRUCT *beg, LINESTRUCT *end) /* blockmarkierung lîschen */
{
	register LINESTRUCT *help;
	extern LINESTRUCT *begcut,*endcut;
	extern char searchstring[];
	register long i,y;

	if(!wp)
		return;
	if(beg && end) /* naja, dÅrfte wohl klar sein */
	{
		graf_mouse(M_OFF,NULL);
		Wcursor(wp);
		for(help=wp->wstr,i=0,y=wp->ywork;
			 help && y<(wp->ywork+wp->hwork-1);
			 help=help->next, i++, y+=wp->hscroll)
			if(help->attr & SELECTED)
			{
				mark_line(wp,help,i);
			}
		for(help=wp->fstr; help; help=help->next)
		{
			help->attr&=~SELECTED;
			help->begcol=0;
			help->endcol=STRING_LENGTH;
		}
		cut=FALSE;
		begline=endline=NULL;
		begcut=endcut=NULL;/* in 7up.c auf NULL setzen, damit sind sie ungÅltig */
		*searchstring=0;
/**/
		Wcuron(wp);
/**/
		Wcursor(wp);
		graf_mouse(M_ON,NULL);
	}
}

void free_blk(WINDOW *wp,LINESTRUCT *line) /* block aus dem speicher lîschen */
{
	extern LINESTRUCT *begcut,*endcut;
	if(!wp)
		return;
	if(line)
	{
		do
		{
			if(line->string)
				free(line->string);
			if(line->prev)
				free(line->prev);
			if(line->next)
				line=line->next;
			else
			{
				free(line);
				line=NULL;
			}
		}
		while(line);
		cut=FALSE;
		begline=endline=NULL;
		begcut=endcut=NULL;/* in 7up.c auf NULL setzen, damit sind sie ungÅltig */
	}
}

void shlf_line(WINDOW *wp, LINESTRUCT *begcut,  LINESTRUCT *endcut)
{
	register LINESTRUCT *help;
	register long i,y,indent;
	int ret, kstate;
	
	if(!wp)
		return;
	if(begcut && endcut)
	{
		graf_mkstate(&ret, &ret, &ret, &kstate);
		if(kstate & (K_RSHIFT|K_LSHIFT)) 
		   indent=1;
		else
		   indent=wp->tab;
		graf_mouse(M_OFF,NULL);
		Wcursor(wp);
		wp->col=0;
		for(help=begcut; help != endcut->next; help=help->next)
		{
			if(help->attr & SELECTED)
			{
				for(i=0; i<indent; i++)
				{
					if((wp->w_state&COLUMN))
					{
						wp->col=help->begcol-wp->wfirst/wp->wscroll;
						if(!(wp->wfirst == 0 && wp->col == 0))
						{
							if(isspace(help->string[help->begcol-1]))
							{
								strcpy(&help->string[help->begcol-1],
										 &help->string[help->begcol]);
								help->used--;							 /* lÑnge kÅrzen */
								help->begcol--;
								help->endcol--;
							}
						}
					}
					else
					{
						wp->col=0;
						if(isspace(*help->string))
						{
							strcpy(help->string,&help->string[1]);
							help->used--;							 /* lÑnge kÅrzen */
						}
					}
				}
				wp->col--;
			}
		}
/*
		if(--wp->col < 0)
		{
			Wlpage(wp,wp->col+wp->wfirst/wp->wscroll-1);
			wp->col=0;
		}
*/
wp->cspos=Wshiftpage(wp,0,wp->cstr->used);
		for(i=0,help=wp->wstr,y=wp->ywork; help != endcut->next && y < (wp->ywork+wp->hwork); i++,help=help->next, y+=wp->hscroll)
			if(help->attr & SELECTED)
			{
				refresh(wp,help,0,i);
			}
		wp->w_state |= CHANGED;
		Wcursor(wp);
		graf_mouse(M_ON,NULL);
	}
}

void shrt_line(WINDOW *wp, LINESTRUCT *begcut,  LINESTRUCT *endcut)
{
	register LINESTRUCT *help;
	register long i,y,indent;
	int ret, kstate;
	
	if(!wp)
		return;
	if(begcut && endcut)
	{
		graf_mkstate(&ret, &ret, &ret, &kstate);
		if(kstate & (K_RSHIFT|K_LSHIFT)) 
		   indent=1;
		else
		   indent=wp->tab;
		graf_mouse(BUSY_BEE,NULL);
		wp->col=0;
		for(help=begcut; help != endcut->next; help=help->next)
		{
			wp->col=help->begcol-wp->wfirst/wp->wscroll;
			if(help->attr & SELECTED)
				for(i=0; i<indent; i++)
				{
					ins_char(wp,help,' ');
					if((wp->w_state&COLUMN))
					{
						help->begcol++;
						help->endcol++;
					}
				}
		}
		graf_mouse(ARROW,NULL);
		graf_mouse(M_OFF,NULL);
		Wcursor(wp);
		for(i=0,help=wp->wstr,y=wp->ywork; help != endcut->next && y < (wp->ywork+wp->hwork); i++,help=help->next, y+=wp->hscroll)
			if(help->attr & SELECTED)
			{
				refresh(wp,help,0 ,i);
			}
		wp->w_state |= CHANGED;
		Wcursor(wp);
		graf_mouse(M_ON,NULL);
	}
}
