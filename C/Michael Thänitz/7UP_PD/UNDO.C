/* simple UNDO/REDO Funktion */
/*****************************************************************************
*
*											  7UP
*										 Modul: UNDO.C
*									 (c) by TheoSoft '92
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <aes.h>

#include "alert.h"

#include "7up.h"
#include "windows.h"

#define LINEUNDO  (-1)
#define LINEPAST  (-2)
#define CUTLINE	(-3)
#define CUTPAST	(-4)
#define PASTCUT	(-5)
#define BACKSPACE (0x0008)
#define RETURN	 (0x000D)

/*
extern long lasthfirst,begline,endline;
*/
typedef struct
{
	int menu,item;
	LINESTRUCT *blkbeg, *blkend;  /* Fr PASTE */
	long wline, begline, endline; /* Fr CUT	*/
	int begcol, endcol;
	int blktype;						/* Blocktyp */
	char string[STRING_LENGTH+2]; /* Lineundo */
	char *cp;
	int row,col;
	int flag;							/* 0 oder -1 : Fehler */
} UNDO;

UNDO undo={FALSE,FALSE,NULL,NULL,0L,0L,0L,0,0,0,"",NULL,-1,-1,TRUE};

int Wrestblk(WINDOW *wp, UNDO *undo, LINESTRUCT **beg, LINESTRUCT **end);

void free_undoblk(WINDOW *wp, LINESTRUCT *line)
{
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
		undo.blkbeg=undo.blkend=NULL;
	}
}

static char savestr[STRING_LENGTH+2];

void store_undo(WINDOW *wp, UNDO *undo, LINESTRUCT *beg, LINESTRUCT *end, int menu, int item)
{												/* Ausschneideinformationen sichern */
	long lines, chars;
	if(wp)
	{
		Wblksize(wp,beg,end,&lines,&chars);
		undo->menu=menu;
		undo->item=item;
		undo->wline=wp->hfirst/wp->hscroll;
		undo->begline=wp->row+wp->hfirst/wp->hscroll;
		undo->begcol=wp->col+wp->wfirst/wp->wscroll;
		undo->endline=undo->begline+lines;
		undo->endcol=end->used;

		if(end->used==0)
		{  /* eine ganze Zeile mit Zeilenumbruch z.B. ^Y */
			undo->endline--;
			undo->endcol=STRING_LENGTH;
		}

		if(((undo->endline-undo->begline)==1) && (undo->endcol<STRING_LENGTH))
		{  /* ein Ausschnitt aus einer Zeile */
			undo->endcol=undo->begcol+end->used;
		}
/*
printf("\33H*%ld %ld %d %d %d*",
			  undo->begline,
			  undo->endline,
			  undo->begcol,
			  undo->endcol,
			  end->used);
form_alert(1,"[0][ ][OK]");
*/
		undo->endcol=min(undo->endcol,STRING_LENGTH);
		undo->blktype=wp->w_state&COLUMN;
	}
}

static void cut(WINDOW *wp)
{
	free_undoblk(wp,undo.blkbeg);
	Wrestblk(wp, &undo, &undo.blkbeg, &undo.blkend);
/*
printf("\33H*%ld %ld %d %d %d %d*",
			  begline,endline,
			  undo.blkbeg->begcol,
			  undo.blkbeg->endcol,
			  undo.blkend->begcol,
			  undo.blkend->endcol);
form_alert(1,"[0][ ][OK]");
*/
	evnt_timer(125,0);
	if(undo.blktype==COLUMN)
		cut_col(wp,undo.blkbeg,undo.blkend);
	else
		cut_blk(wp,undo.blkbeg,undo.blkend);
	Wcuron(wp);
	undo.menu=WINEDIT;
	undo.item=EDITPAST;
}

static void paste(WINDOW *wp)
{
	LINESTRUCT *begcopy=NULL, *endcopy=NULL;
	
	if((undo.flag=copy_blk(wp,undo.blkbeg,undo.blkend,&begcopy,&endcopy))>0)
	{
		store_undo(wp, &undo, begcopy, endcopy, WINEDIT, EDITCUT);
/*
printf("\33H*%ld %ld %d %d %d %d*",
			  begline,endline,
			  undo.blkbeg->begcol,
			  undo.blkbeg->endcol,
			  undo.blkend->begcol,
			  undo.blkend->endcol);
form_alert(1,"[0][ ][OK]");
*/
		if(undo.blktype==COLUMN)
			paste_col(wp,begcopy,endcopy);
		else
  			paste_blk(wp,begcopy,endcopy);
		undo.menu=WINEDIT;
		undo.item=EDITCUT;
	}
}

static void line(WINDOW *wp)
{
	char *cp;
	int savecol;

	strcpy(savestr,wp->cstr->string);
	if(wp->cstr->len < (strlen(undo.string)+1))
	{
		if(cp=realloc(wp->cstr->string,(strlen(undo.string)+1)))
		{
			wp->cstr->string=cp;
			wp->cstr->len=(strlen(undo.string)+1);
		}
		else
		{
			undo.item=FALSE;
			return;
		}
	}
	strcpy(wp->cstr->string,undo.string);
	wp->cstr->used=strlen(undo.string);
	savecol=wp->col;
	wp->col=undo.col;				  /* Cursor setzen */
	undo.col=savecol;
	refresh(wp, wp->cstr, max(0,(min(wp->col,savecol)-1)), wp->row);
	strcpy(undo.string,savestr);
	undo.item=LINEUNDO;
}

void do_undo(WINDOW *wp)										 /* Undo ausfhren */
{
	int msgbuf[8];
	LINESTRUCT *dummy=NULL;
	
	extern LINESTRUCT *begcut, *endcut;
	extern OBJECT *winmenu;
			
	if(wp)
	{
		if(undo.flag!=TRUE)
		{
			free_undoblk(wp, undo.blkbeg);
			form_alert(1,Aundo[0]);
			undo.item=FALSE;
			return;
		}
		graf_mouse(M_OFF,0L);
		Wcursor(wp);
		switch(undo.item)
		{
			case EDITCUT:
				cut(wp);
				break;
			case EDITPAST:
				paste(wp);
				break;
			case LINEUNDO:
				line(wp);
				break;
			case LINEPAST:
				line(wp);
				paste(wp);
				undo.item=CUTLINE;
				break;
			case CUTLINE:
				cut(wp);
				line(wp);
				undo.item=LINEPAST;
				break;
			case CUTPAST:
				Wrestblk(wp, &undo, &begcut, &endcut);
				evnt_timer(125,0);
				if(undo.blktype==COLUMN)
					cut_col(wp, begcut, endcut);
				else
					cut_blk(wp, begcut, endcut);
				free_blk(wp,begcut);
				Wcuron(wp);
				paste(wp);
				undo.item=FALSE;
				break;
			case PASTCUT:
				break;
			case WINCLOSE:
				msgbuf[0]=MN_SELECTED;
#if GEMDOS
				msgbuf[1]=_GemParBlk.global[2];
#else
				msgbuf[1]=gb.gb_pglobal[2];
#endif
				msgbuf[2]=Wh(wp);
				msgbuf[3]=undo.menu;
				msgbuf[4]=undo.item;
				menu_tnormal(winmenu,msgbuf[3],0);
				appl_write(msgbuf[1],16,msgbuf);
				break;	
		}
		wp->cspos=wp->col;
		Wcursor(wp);
		graf_mouse(M_ON,0L);
		switch(undo.item)
		{
			case BACKSPACE:
				editor(wp,0,BACKSPACE,&dummy,&dummy);
				undo.item=RETURN;
				break;
			case RETURN:
				editor(wp,0,RETURN,&dummy,&dummy);
				undo.item=BACKSPACE;
				break;
		}
	}
}
