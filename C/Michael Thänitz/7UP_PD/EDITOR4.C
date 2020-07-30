/* Texteingabe */
/*****************************************************************************
*
*											  7UP
*										Modul: EDITOR.C
*									 (c) by TheoSoft '90
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>
#include <aes.h>
#include <vdi.h>

#if GEMDOS
#include <tos.h>
#include <ext.h>
#else
#include <alloc.h>
#include <dir.h>
#endif

#include "alert.h"
#include "7up.h"
#include "forms.h"
#include "windows.h"

#include "undo.h"

#include "language.h"

void mark_line(WINDOW *wp, LINESTRUCT *str, int line);
LINESTRUCT *beg_blk(WINDOW *wp, LINESTRUCT *cutbeg, LINESTRUCT *cutend);
LINESTRUCT *end_blk(WINDOW *wp, LINESTRUCT **cutbeg, LINESTRUCT **cutend);
int cut_blk(WINDOW *wp, LINESTRUCT *cutbeg, LINESTRUCT *cutend);
int copy_blk(WINDOW *wp, LINESTRUCT *cutbeg, LINESTRUCT *cutend, LINESTRUCT **copybeg, LINESTRUCT **copyend);
void paste_blk(WINDOW *wp,LINESTRUCT *beg,LINESTRUCT *end);
int ins_char(WINDOW *wp,LINESTRUCT *line, int c); /* neues zeichen einfÅgen */
int ins_line(WINDOW *wp);								  /* neue zeile einfÅgen */
int backspace(WINDOW *wp,LINESTRUCT *line);		  /* zeichen lîschen */
int del_char(WINDOW *wp,LINESTRUCT *line);			/* zeichen lîschen */
int del_line(WINDOW *wp);								  /* zeile lîschen */
int cat_line(WINDOW *wp);								  /* zeilen verbinden */
void hide_blk(WINDOW *wp,LINESTRUCT *beg,LINESTRUCT *end);
void free_blk(WINDOW *wp,LINESTRUCT *line);
void shlf_line(WINDOW *wp, LINESTRUCT *begcut,  LINESTRUCT *endcut);
void shrt_line(WINDOW *wp, LINESTRUCT *begcut,  LINESTRUCT *endcut);
int adjust_best_position(WINDOW *wp);
refresh(WINDOW *wp, LINESTRUCT *line, int col, int row);

extern OBJECT *winmenu,*desktop;
extern int vdihandle,xdesk,ydesk,wdesk,hdesk;
extern int cut, clipbrd,umlautwandlung,tabbar,scaktiv;
extern int eszet,tabexp;
extern char alertstr[256];

#define CR 0x0D /* dÅrfen nicht verwendet werden */
#define LF 0x0A
#define VERTICAL	1
#define HORIZONTAL 2
#define DEZTAB '#'

LINESTRUCT *lastwstr;
long		  lasthfirst,begline,endline;
static WINDOW *copywindow;
/*
long *ckbd = NULL; /*Compose Keyboard von Pascal Fellerich*/
*/

void mark_line(WINDOW *wp, LINESTRUCT *str, int line)
{																  /* zeile markieren */
	register int pxyarray[4],area[4],full[4],clip[4];

	clip[0]=wp->xwork - wp->wfirst + str->begcol*wp->wscroll;
	clip[1]=wp->ywork + line * wp->hscroll;
	clip[2]=(str->endcol-str->begcol)*wp->wscroll;
	clip[3]=wp->hscroll;

#if MiNT
   wind_update(BEG_UPDATE);
#endif
	_wind_get(0, WF_WORKXYWH, &full[0], &full[1], &full[2], &full[3]);
	_wind_get(wp->wihandle, WF_FIRSTXYWH, &area[0], &area[1], &area[2], &area[3]);
	while( area[2] && area[3] )
	{
		if(rc_intersect(full,area))
		{
			if(rc_intersect(clip,area))
			{
				pxyarray[0]=area[0];
				pxyarray[1]=area[1];
				pxyarray[2]=area[0]+area[2]-1;
				pxyarray[3]=area[1]+area[3]-1;
				vs_clip(vdihandle,TRUE,pxyarray);
				vr_recfl(vdihandle,pxyarray);		/* schwarz markieren */
			}
		}
		_wind_get(wp->wihandle, WF_NEXTXYWH, &area[0], &area[1], &area[2], &area[3]);
	}
	vs_clip(vdihandle,FALSE,pxyarray);
#if MiNT
   wind_update(END_UPDATE);
#endif
}

refresh(register WINDOW *wp, LINESTRUCT *line, register int col, register int row)
{
	register int area[4];

	area[0]=wp->xwork + col * wp->wscroll;
	area[1]=wp->ywork + row * wp->hscroll;
	area[2]=wp->wwork - col * wp->wscroll;
	area[3]=wp->hscroll;
	Wredraw(wp,area);
}

int ins_char(WINDOW *wp, register LINESTRUCT *line, int c) /* zeichen einfÅgen */
{
	register long abscol;
	char *help;
	if(line->used < STRING_LENGTH)
	{
		abscol=wp->col+wp->wfirst/wp->wscroll; /* absolute position */
		if(abscol<=line->used)					  /* hîchstens zeilenende */
		{
			if(!(line->used < line->len))
			{
				if((line->len += NBLOCKS) > STRING_LENGTH)
					line->len = STRING_LENGTH;
				help=realloc(line->string, line->len +1);
				if(help!=NULL)
					line->string=help;
				else
				{
					return(FALSE);
				}
				line->string[line->used]=0;
			}
			if(wp->w_state & INSERT)									/* einfÅgen */
			{
				/* vom zeichen unter cursor rest nach rechts verschieben, insertmodus */
				memmove(&line->string[abscol+1],
						 &line->string[abscol],
						 strlen(&line->string[abscol]) +1);

				line->string[abscol]=c;			  /* zeichen setzen */
				line->used++;							/* lÑnge Ñndern */
				line->string[line->used]=0;		 /* ende setzen */
			}
			else											/* Åberschreiben */
			{
				line->string[abscol]=c;			  /* zeichen setzen */
				if(abscol==line->used)
				{
					line->used++;
					line->string[line->used]=0;	 /* ende setzen */
				}
			}
			return(TRUE);
		}
	}
	return(FALSE);
}

int ins_dezimal(WINDOW *wp, register LINESTRUCT *line, int c) /* zeichen einfÅgen */
{
	register long abscol;
	register int i;
	
	if(line->used < STRING_LENGTH)
	{
		abscol=wp->col+wp->wfirst/wp->wscroll; /* absolute position */
		if(abscol<=line->used)					  /* hîchstens zeilenende */
		{
			for(i=abscol-1; i>=0; i--)
				if(line->string[i] == ' ')
				{
					memmove(&line->string[i],&line->string[i+1],abscol-i-1);
					line->string[abscol-1]=c;
					return(TRUE);
				}
		}
	}
	return(FALSE);
}

int can_ins_dezimal(WINDOW *wp, register LINESTRUCT *line) /* prÅfen ob num-zeichen eingefÅgt werden kann */
{
	register long abscol;
	register int i;
	
	if(line->used < STRING_LENGTH)
	{
		abscol=wp->col+wp->wfirst/wp->wscroll; /* absolute position */
		if(abscol<=line->used)					  /* hîchstens zeilenende */
		{
			for(i=abscol-1; i>=0; i--)
				if(line->string[i] == ' ')
					return(TRUE);
		}
	}
	return(FALSE);
}

int ins_line(WINDOW *wp)			/* neue zeile einfÅgen */
{
	register LINESTRUCT *insline;
	register long abscol;
	char *help;

	if((insline=malloc(sizeof(LINESTRUCT)))==NULL) /* insert */
		return(FALSE);
	insline->prev=0L;
	insline->next=0L;
	if((insline->string=(char *)malloc(NBLOCKS+1))==NULL)
	{
		free(insline);
		return(FALSE);
	}
	insline->string[0]=0;
	insline->used=0;
	insline->len=NBLOCKS;
	insline->attr=0;
	insline->effect=TXT_NORMAL;

	if(wp->cstr) /* normale arbeitsweise */
	{
		abscol=wp->col+wp->wfirst/wp->wscroll; /* absolute position */
		if(wp->cstr->next)
		{
			insline->next=wp->cstr->next; /* ersten hinten verknÅpfen */
			wp->cstr->next->prev=insline;
		}
		wp->cstr->next=insline;			 /* dann vorne */
		insline->prev=wp->cstr;
		if(abscol < wp->cstr->used)
		{
			help=realloc(insline->string,strlen(&wp->cstr->string[abscol])+1);
			if(help != NULL)
				insline->string=help;
			else
			{
				form_alert(1,Aeditor[0]);
				_exit(-1); /* ohne atexit Vektor */
			}
			strcpy(insline->string,&wp->cstr->string[abscol]);
			insline->used=insline->len=strlen(insline->string);
			wp->cstr->string[abscol]=0;
			wp->cstr->used=strlen(wp->cstr->string);
			refresh(wp,wp->cstr,wp->col,wp->row);
		}
		wp->col=0;
		wp->cstr=insline;
	}
	else /* anfang des textes erzeugen */
	{
		wp->cstr=wp->wstr=wp->fstr=insline;
	}
	wp->hsize+=wp->hscroll;
	return(TRUE);
}

int cat_line(WINDOW *wp)
{
	register int i,diff;
	register char save;
	register long hfirst;
	register LINESTRUCT *help;
	char *temp;

	if(wp->cstr->prev)
	{
		if(wp->cstr->prev->used==0)
		{
			if(wp->cstr==wp->wstr) /* falls erste Zeile im Fenster */
			{
/* Koos Kuil 26.04.93 */
				if(Warrow(wp,WA_UPLINE))
				{
/* 
					wp->cstr=wp->cstr->next;
					wp->row=1;
*/
				}
			}
			wp->cstr=wp->cstr->prev;	  /* einfach vorherige zeile lîschen */
			wp->col=0;
			wp->row--;
			hfirst=wp->hfirst;						  /* letzte position merken */
			del_line(wp);
			if(wp->hfirst!=hfirst)		  		/* wurde anfang zurÅckversetzt */
			{
				if(wp->cstr->next)
				{
					wp->cstr=wp->cstr->next;	/* kann cursor versetzt werden */
					wp->row++;
				}
			}
			return(0);
		}
		else
		{
			if(wp->cstr==wp->wstr) /* falls erste Zeile im Fenster */
			{
/* Koos Kuil 26.04.93 */
				if(Warrow(wp,WA_UPLINE))
				{
/*
					wp->cstr=wp->cstr->next;
					wp->row=1;
*/
				}
			}
			if(wp->cstr->used > 0) /* umkopieren */
			{
				if((temp=realloc(wp->cstr->prev->string,wp->cstr->prev->used+wp->cstr->used+1))==NULL)
					return(FALSE);

				wp->cstr->prev->string=temp;

				diff = STRING_LENGTH - wp->cstr->prev->used;
				wp->col = wp->cstr->prev->used; /* cursor in die spalte hinter zeile */
				wp->row--;
				if(wp->cstr->used > diff)
				{
					save=wp->cstr->string[diff];
					wp->cstr->string[diff]=0;
				}
				strcat(wp->cstr->prev->string,wp->cstr->string);
				wp->cstr->prev->len=wp->cstr->prev->used=
					strlen(wp->cstr->prev->string);
				if(wp->cstr->used > diff)
				{
					wp->cstr->string[diff]=save;
				}
				wp->cstr=wp->cstr->prev;
				refresh(wp, wp->cstr,wp->col,wp->row);
				wp->cstr=wp->cstr->next;
				wp->row++;
				if(wp->cstr->used > diff)
				{
					strcpy(wp->cstr->string,&wp->cstr->string[diff]);
					wp->cstr->used=strlen(wp->cstr->string);
					refresh(wp, wp->cstr, 0, wp->row );
					wp->cstr=wp->cstr->prev;
				}
				else
				{
					hfirst=wp->hfirst;					  /* letzte position merken */
					temp=wp->cstr->next;
					del_line(wp);
					if(wp->hfirst==hfirst)		  /* wurde anfang zurÅckversetzt */
					{
						if(wp->cstr->prev && wp->cstr==temp)
						{
							wp->cstr=wp->cstr->prev;	/* kann cursor versetzt werden */
							wp->row--;
						}
					}
				}
			}
			else
			{
				hfirst=wp->hfirst;					  /* letzte position merken */
				temp=wp->cstr->next;
				del_line(wp);
				wp->col=wp->cstr->used;
				if(wp->hfirst==hfirst)		  /* wurde anfang zurÅckversetzt */
				{
					if(wp->cstr->prev && wp->cstr==temp)
					{
						wp->cstr=wp->cstr->prev;	/* kann cursor versetzt werden */
						wp->col=wp->cstr->used;
						wp->row--;
					}
				}
			}
			if(wp->col > wp->wwork/wp->wscroll-1)
			{
				i=wp->col/(wp->wwork/wp->wscroll);
				wp->col -= i*wp->wwork/wp->wscroll;
				while(i--)
					Warrow(wp,WA_RTPAGE);
			}
		}
	}
	return(FALSE);
}

int backspace(WINDOW *wp, register LINESTRUCT *line)
{											 /* zeichen links vom cursor lîschen */
	register long abscol;

	abscol=wp->col+wp->wfirst/wp->wscroll - 1; /* zeichen vor dem cursor, absolute position */

	/* vom zeichen unter cursor ein zeichen nach links schieben, zeichen...*/
	/* ... wird dabei automatisch gelîscht */
	strcpy(&line->string[abscol],&line->string[abscol+1]);
	line->used--;							  /* lÑnge kÅrzen */
	return(TRUE);
}

int del_char(WINDOW *wp, register LINESTRUCT *line)
{													  /* zeichen unter cursor lîschen */
	register long abscol;
	GRECT rect;

	abscol=wp->col+wp->wfirst/wp->wscroll; /* zeichen vor dem cursor, absolute position */
	if(!abscol && !line->used)
	{
		del_line(wp);
		return(TRUE); /* FALSE */
	}
	if(abscol < line->used)
	{
		strcpy(&line->string[abscol],&line->string[abscol+1]);
		line->used--;							  /* lÑnge kÅrzen */
		rect.g_x=wp->xwork + wp->col * wp->wscroll;
		rect.g_y=wp->ywork + wp->row * wp->hscroll;
		rect.g_w=wp->wwork - wp->col * wp->wscroll;
		rect.g_h=wp->hscroll;
		Wscroll(wp,HORIZONTAL,wp->wscroll,&rect);
		return(TRUE); /* FALSE */
	}
	else
		return(FALSE);
}

int del_line(WINDOW *wp)
{
	LINESTRUCT *begcut, *endcut;
	int savecol;

	if(! wp->cstr->prev && !wp->cstr->next) /* erste und einzige zeile */
	{
		wp->cstr->string[0]=0;
		wp->cstr->used=0;
		refresh(wp,wp->cstr,0,wp->row);
	}
	else
	{
		lastwstr=wp->wstr;
		lasthfirst=wp->hfirst;
		begcut=endcut=wp->cstr;	 /* anfang = ende */
		begline=wp->row+wp->hfirst/wp->hscroll;  /* zeilen = 1 */
		endline=begline+1;
		begcut->begcol=endcut->begcol=0;
		begcut->endcol=endcut->endcol=STRING_LENGTH;

		savecol=wp->col;
		cut=cut_blk(wp, begcut, endcut);	  /* cuten */
		free_blk(wp,begcut);					 /* hwds! */
		wp->col=savecol;
	}
	return(FALSE);
}

int del_eoln(WINDOW *wp)
{
	wp->cstr->string[wp->col+wp->wfirst/wp->wscroll]=0;
	wp->cstr->used=strlen(wp->cstr->string);
	refresh(wp, wp->cstr, wp->col, wp->row);
}

int adjust_best_position(WINDOW *wp) /* evtl. unten anpassen */
{
	register int i,fline,lline;
	if(wp->hfirst!=0 && wp->hfirst + wp->hwork > wp->hsize)
	{
		lline=wp->hfirst/wp->hscroll;	 /* erste zeile merken */
		wp->hfirst = wp->hsize-wp->hwork; /* neu setzen */
		if(wp->hfirst<0)
			wp->hfirst=0;
		fline=wp->hfirst/wp->hscroll;	  /* neue erste zeile */
		if(fline<lline)  /* kann nur kleiner sein, weil zurÅckpositioniert */
			for(i=fline; i<lline; i++)	 /* zeiger zurÅck setzen */
			{
				wp->wstr=wp->wstr->prev;	/* window und cursor */
			}
		return(TRUE);
	}
	return(FALSE);
}

int hndl_umbruch(OBJECT *tree, WINDOW *wp, int start)
{
   int umbruch=0;
	if(wp)
	{
		sprintf(tree[UMBRUCH].ob_spec.tedinfo->te_ptext,"%d",wp->umbruch-1);
		if(form_exhndl(tree,0,0)==UMBRABBR)
			return(wp->umbruch);
		umbruch=atoi(form_read(tree,UMBRUCH,alertstr))+1;
		if(umbruch<2)
			umbruch=2;
		if(umbruch>STRING_LENGTH)
			umbruch=STRING_LENGTH;
	}
	return(umbruch);
}

void blockformat(char *str, int diff) /* mit blanks expandieren */
{
	register int i,k,endlos=TRUE;

	if(diff<0)
		return;

	k=strlen(str);
	do
	{
		for(i=0; i<k; i++) /* fÅhrende Blanks Åberspringen */
			if(str[i]!=' ')
				break;
		for(i; i<k && diff; i++)
		{
			if(str[i]==' ' /*|| str[i]=='\t'*/)
			{
				memmove(&str[i+1],&str[i],strlen(&str[i])+1);
				str[i]=' ';
				i+=2;
				k++;
				diff--;
				endlos=FALSE;
			}
		}
		if(endlos)
		  break;
	}
	while(diff>0 && !endlos);
}

int findlastspace(char *str, int umbr, int abs)
{
	int saveabs;
	saveabs = abs;
	
	while(abs >= umbr) /* zurÅck zum Umbruch */
		abs--;
	while(str[abs] != ' ' && str[abs]!='\t' && abs>0)
		abs--;
	if(abs==0)
	{
		while(saveabs > umbr) /* zurÅck zum Umbruch */
		{
			if(str[saveabs] == ' ')
				return(saveabs);
			else
				saveabs--;
		}
	}
	return(abs/*?abs:umbr*/); /* 10.7.94 */
}

int ispossible(LINESTRUCT *line)  /* beim zweiten RETURN kein EinrÅcken */
{
	int i;
	if(line)
	{
		for(i=0; i<line->used; i++)
			if(line->string[i]!=' ')
				return(TRUE);
		return(FALSE);
	}
	return(TRUE);
}

int isgerman(char key)
{
	char *cp;
	static char german[]=
	{
		'Ñ','é','î','ô','Å','ö','û','·','_',0
	};
	cp=german;
	do
	{
		if(key == *cp)
			return(TRUE);
	}
	while(*++cp);
	return(FALSE);
}

static int _editor(register WINDOW *wp, int state, int key, LINESTRUCT **begcut, LINESTRUCT **endcut)
{
	Wcursor(wp);
	editor(wp,state,key,begcut,endcut);
	graf_mouse(M_OFF,NULL);
	Wcursor(wp);
}

int editor(register WINDOW *wp, int state, int key, LINESTRUCT **begcut, LINESTRUCT **endcut) /* zeicheneingabe auswerten */
{
	register int abscol,i,y,nexttab,prevtab;
	int clip[4],errcode=0,col,block=FALSE;
	GRECT rect;
	char *cp,outchar[2]=" ";

	static int dk[2]={0,0};

	if(wp)
	{
		/* markierten Block gleich ersetzen. Sichern in UNDOpuffer */
		if((char)key != 0x1B)	/* != ESC */
		{	
	      /* aktuelle Zeile fÅr Zeilenundo sichern */
			if((undo.cp  != wp->cstr->string) &&
				(undo.row != wp->hfirst/wp->hscroll+wp->row)) /* fÅr undo string retten */
			{	/* auch row merken, weil sich beim einfÅgen adresse Ñndert */
				strcpy(undo.string,wp->cstr->string);
				undo.cp =wp->cstr->string;
				undo.col=wp->col;
				undo.row=wp->row+wp->hfirst/wp->hscroll;
			}
			if(!cut && (*begcut) && (*endcut)) /* markierten Block lîschen */
			{
            if((*begcut)==wp->fstr && (*endcut)->next==NULL)
            {
               if(form_alert(2,Aeditor[6])==1)
                  return;
            }
     			if((*begcut) == (*endcut))
     			{
     			   if(endline != begline) /* ganze Zeile */
       			   undo.item=LINEPAST;
     			   else
     			      undo.item=LINEUNDO;
     			}
     			else
     			   undo.item=LINEPAST;
				hndl_blkfind(wp,(*begcut),(*endcut),SEARBEG);
				graf_mouse(M_OFF,0L);
				Wcursor(wp);
   			free_undoblk(wp,undo.blkbeg); /* Block weg */
				if((wp->w_state&COLUMN))
				{
					cut=cut_col(wp,(*begcut),(*endcut));
               undo.flag=copy_col(wp,(*begcut),(*endcut),&undo.blkbeg,&undo.blkend);
				}
				else
				{
					cut=cut_blk(wp,(*begcut),(*endcut));
               undo.flag=copy_blk(wp,(*begcut),(*endcut),&undo.blkbeg,&undo.blkend);
				}
				Wcuron(wp);
				Wcursor(wp);
/*
				graf_mouse(M_ON,0L);
*/
   			free_blk(wp,(*begcut)); /* Block weg */
   			if(undo.item==LINEPAST)
   			{
			   	strcpy(undo.string,wp->cstr->string); /* nochmal fÅr LINEPASTE */
		   		undo.cp =wp->cstr->string;
	   			undo.col=wp->col;
   				undo.row=wp->row+wp->hfirst/wp->hscroll;
				}
				block=TRUE;
			}
      }
		if(!(state & (K_CTRL|K_ALT)) && !(key & 0x8000))/* keine sondertaste (control) */
		{
			graf_mouse(M_OFF,0L);
			Wcursor(wp);
			wp->cspos=Wshiftpage(wp,0,wp->cstr->used);
			switch(key)
			{
				case 0x0009:	/*  tab  */
					wp->w_state|=CHANGED; /* es wurde editiert */
					if(!tabexp)
						goto INS_CHAR;
					if(!block)
					{
						undo.item=LINEUNDO;
						if(tabbar)
						{
							nexttab=Wgetnexttab(wp);
						}
						else
						{
							nexttab=wp->tab-(wp->col%wp->tab);
							nexttab=(nexttab ? nexttab : wp->tab);
						}
						if(wp->w_state & INSERT)
						{
							for(i=0; i<nexttab; i++)
							{
								if(ins_char(wp,wp->cstr,' '))
								{
									refresh(wp, wp->cstr, wp->col , wp->row);
									if(++wp->col > wp->wwork/wp->wscroll-1) /* scrollen */
									{
										wp->col--;
										if(Warrow(wp,WA_RTLINE))
											wp->col++;	  /*-=4;*/
									}
								}
							}
						}
						else
						{
							if((wp->col+=nexttab) > wp->wwork/wp->wscroll-1) /* scrollen */
							{
								wp->col-=nexttab;
								if(Warrow(wp,WA_RTLINE))
									wp->col;/*++*/  /*-=4;*/
							}
						}
					}
					break;
				case 0x0209:	/*  shift tab : eigentlich quatsch */
					if(tabbar)
					{
						prevtab=Wgetprevtab(wp, wp->toolbar);
					}
					else
					{
						prevtab=wp->col%wp->tab;
						prevtab=(prevtab ? prevtab : wp->tab);
					}
					wp->col-=prevtab;
					break;
				case 0x000D: /* RETURN */
				case 0x020D: /* S " */
				case 0x400D: /* ENTER auf Zehnerblock */
				case 0x420D: /* S " */
					undo.item=FALSE;
					if((wp->w_state & INSERT) || !wp->cstr->next)
					{
						if(ins_line(wp))
						{
							wp->w_state|=CHANGED; /* es wurde editiert */
							if(++wp->row > wp->hwork/wp->hscroll-1 )/* scrollen */
							{
								refresh(wp,wp->cstr,0,wp->row);
								Warrow(wp,WA_DNLINE);
								Wslide(wp,0,HSLIDE);
								wp->col=0;
							}
							else
							{
								rect.g_x=wp->xwork;
								rect.g_y=wp->ywork + (wp->row) * wp->hscroll;
								rect.g_w=wp->wwork;
								rect.g_h=wp->hwork - (wp->row) * wp->hscroll;
								Wscroll(wp,VERTICAL,-wp->hscroll,&rect);
								Wslide(wp,0,HSLIDE);
								wp->col=0;
							}
							if((wp->w_state & INDENT) && ispossible(wp->cstr->prev)) /* cursor einrÅcken, auto-indent */
							{
								for(i=0; i<wp->cstr->prev->used && wp->cstr->prev->string[i] == ' '; i++)
									if(ins_char(wp,wp->cstr,' '))
									{
										wp->col++;
									}
								refresh(wp, wp->cstr, 0, wp->row);
								if(wp->col==0) /* nicht eingerÅckt */
							      undo.item=BACKSPACE;
							}
						}
					}
					else
					{
						wp->col=0;
						if(wp->cstr->next)
						{
							if(++wp->row > wp->hwork/wp->hscroll-1 )/* scrollen */
							{
								Warrow(wp,WA_DNLINE);
							}
							else
								wp->cstr=wp->cstr->next; /* Cursor vor	 */
						}
					}
					undo.cp=NULL; /* lîschen, weil sonst fehlerhaft */
					undo.row=-1;
					break;
				case 0x007F: /* DELETE */
					wp->w_state|=CHANGED; /* es wurde editiert */
					if(!block)
					{
						undo.item=LINEUNDO;
						if(!del_char(wp,wp->cstr))
							if(wp->cstr->next)
							{
								undo.item=FALSE;
								wp->cstr=wp->cstr->next;
								wp->col=0;
								wp->row++;
								cat_line(wp);
								undo.item=RETURN;
							}
					}
					break;
				case 0x0008: /* BACKSPACE */
				case 0x0208: /* S " */
					wp->w_state|=CHANGED; /* es wurde editiert */
					if(!block)
					{
						if(!(wp->wfirst == 0 && wp->col == 0))
						{
							undo.item=LINEUNDO;
							backspace(wp,wp->cstr);
							wp->col--;
							rect.g_x=wp->xwork + wp->col * wp->wscroll;
							rect.g_y=wp->ywork + wp->row * wp->hscroll;
							rect.g_w=wp->wwork - wp->col * wp->wscroll;
							rect.g_h=wp->hscroll;
							Wscroll(wp,HORIZONTAL,wp->wscroll,&rect);
						}
						else
						{
							undo.item=RETURN;
							cat_line(wp);
						}
					}
					break;
				case 0x001B: /* ESC */
/*
					if(ckbd) /*CKBD geladen, Åberlassen wirs diesem Treiber*/
						goto DEADKEY;
*/
					if (!scaktiv) /* Shortcuts nicht aktiv */
						goto NODEADKEY;
						
					if(dk[0]!=0x1B)
						dk[0]=0x1B;
					else
						dk[0]=0;
					break;
					
/* GEMDOS */default:
INS_CHAR:
					key=(char)key;
/*
					if(ckbd) /*CKBD geladen, Åberlassen wirs diesem Treiber*/
						goto DEADKEY;
*/
					if (!scaktiv)  /* Shortcuts nicht aktiv */
						goto NODEADKEY;
						
					if(dk[0]==0x1B) /* ESC = deadkey */
					{
						if(!dk[1])
						{
							dk[1]=isdeadkey(key);
							if(!dk[1])
							{
								dk[0]=0;
								goto NODEADKEY;
							}
						}
						else
						{
                     cp=NULL;
							key=deadkey(dk[1],key,&cp);
							dk[0]=dk[1]=0;
							if(key) /* einzelnes Zeichen */
							   goto NODEADKEY;
							if(cp)  /* Shortcutzeichenkette */
							{
                        col=-1; /* zurÅcksetzen auf ungÅltig */
								while((*cp!='\r') && (*cp!=0))
								{
									Wcursor(wp);
/*
									graf_mouse(M_ON,NULL);
*/
                           if(*cp!='~')
   									editor(wp,0,(int)*cp,begcut,endcut);
   								else
   								   col=wp->col;
									graf_mouse(M_OFF,NULL);
									Wcursor(wp);
									cp++;
								}
								if(col>-1)    /* abfragen und setzen */
   								wp->col=col; /* Tilde in Shortcut */
 							}
						}
					}
					else
					{
NODEADKEY:
						if(!block)
							undo.item=LINEUNDO;
						if(key && key!=CR && key!=LF)
						{
							wp->w_state|=CHANGED; /* es wurde editiert  */
							if(umlautwandlung)    /* TeX-Umlautwandlung */
							{
								switch(key)
								{
									case 'Ñ':
										_editor(wp,0,'"',begcut,endcut);
										_editor(wp,0,'a',begcut,endcut);
										goto ENDE;
										break;
									case 'é':
										_editor(wp,0,'"',begcut,endcut);
										_editor(wp,0,'A',begcut,endcut);
										goto ENDE;
										break;
									case 'î':
										_editor(wp,0,'"',begcut,endcut);
										_editor(wp,0,'o',begcut,endcut);
										goto ENDE;
										break;
									case 'ô':
										_editor(wp,0,'"',begcut,endcut);
										_editor(wp,0,'O',begcut,endcut);
										goto ENDE;
										break;
									case 'Å':
										_editor(wp,0,'"',begcut,endcut);
										_editor(wp,0,'u',begcut,endcut);
										goto ENDE;
										break;
									case 'ö':
										_editor(wp,0,'"',begcut,endcut);
										_editor(wp,0,'U',begcut,endcut);
										goto ENDE;
										break;
									case 0x9E:    /*'û'*/
									case 0xE1:    /*'û'*/
										_editor(wp,0,'"',begcut,endcut);
										_editor(wp,0,'s',begcut,endcut);
										goto ENDE;
										break;
/*
									case 'Ñ':
										_editor(wp,0,'a',begcut,endcut);
										_editor(wp,0,'e',begcut,endcut);
										goto ENDE;
										break;
									case 'é':
										_editor(wp,0,'A',begcut,endcut);
										_editor(wp,0,'e',begcut,endcut);
										goto ENDE;
										break;
									case 'î':
										_editor(wp,0,'o',begcut,endcut);
										_editor(wp,0,'e',begcut,endcut);
										goto ENDE;
										break;
									case 'ô':
										_editor(wp,0,'O',begcut,endcut);
										_editor(wp,0,'e',begcut,endcut);
										goto ENDE;
										break;
									case 'Å':
										_editor(wp,0,'u',begcut,endcut);
										_editor(wp,0,'e',begcut,endcut);
										goto ENDE;
										break;
									case 'ö':
										_editor(wp,0,'U',begcut,endcut);
										_editor(wp,0,'e',begcut,endcut);
										goto ENDE;
										break;
									case 0x9E:    /*'û'*/
									case 0xE1:    /*'û'*/
										_editor(wp,0,'s',begcut,endcut);
										_editor(wp,0,'s',begcut,endcut);
										goto ENDE;
										break;
*/
								}
							}
							if(isnum(key) && (Wgettab(wp)==DEZTAB) && can_ins_dezimal(wp,wp->cstr))
							{
								if(ins_dezimal(wp,wp->cstr,key))
								{
									rect.g_x=wp->xwork;
									rect.g_y=wp->ywork + wp->row * wp->hscroll;
									rect.g_w=wp->wwork;
									rect.g_h=wp->hscroll;
									Wredraw(wp,&rect);
								}
							}
							else
							{
								if(ins_char(wp,wp->cstr,key))
								{
									if((wp->w_state & INSERT) && (wp->col+wp->wfirst/wp->wscroll < wp->cstr->used-1))
									{
										rect.g_x=wp->xwork + wp->col * wp->wscroll;
										rect.g_y=wp->ywork + wp->row * wp->hscroll;
										rect.g_w=wp->wwork - wp->col * wp->wscroll;
										rect.g_h=wp->hscroll;
										Wscroll(wp,HORIZONTAL,-wp->wscroll,&rect);
									}
									else
									{
										rect.g_x=wp->xwork + wp->col * wp->wscroll;
										rect.g_y=wp->ywork + wp->row * wp->hscroll;
										rect.g_w=wp->wscroll;
										rect.g_h=wp->hscroll;
										Wredraw(wp,&rect);
									}
									wp->col++;
								}
							}
  							col=abscol=wp->col+wp->wfirst/wp->wscroll;
							if(abscol >= wp->umbruch)
							{
								abscol=findlastspace(wp->cstr->string, wp->umbruch, abscol);
								if(abscol>0)
								{
									wp->cspos=wp->col=abscol-wp->wfirst/wp->wscroll+1;
									wp->cspos=Wshiftpage(wp,0,wp->cstr->used);
									Wcursor(wp);
/*
									graf_mouse(M_ON,NULL);
*/
									editor(wp,0,0x000D,begcut,endcut);
									graf_mouse(M_OFF,NULL);
									Wcursor(wp);

									wp->col+=(col-abscol)-wp->wfirst/wp->wscroll-1;

									if(wp->w_state & BLOCKSATZ)
									{
										blockformat(wp->cstr->prev->string, wp->umbruch-wp->cstr->prev->used);
										wp->cstr->prev->used=strlen(wp->cstr->prev->string);
										refresh(wp, wp->cstr->prev, 0, wp->row-1);
									}
								}
							}
						}
					}
					break;
			}
ENDE:
			wp->cspos=Wshiftpage(wp,0,wp->cstr->used);
	      Wcuron(wp);
			Wcursor(wp);
/*
			graf_mouse(M_ON,0L);
*/
		}
	}
	return(errcode);
}

WINDOW *twp;
void hndl_chartable(WINDOW *wp, OBJECT *tree)
{
	int c,ret,kstate,ende;
	long dummy=0;
	
	if(wp)
	{
		ende = FALSE;
		twp=wp;
		form_exopen(tree,0);
		do
		{
			c=(form_exdo(tree,0)&0x7FFF);
			switch(c)
			{
				case CHARHELP:
					form_alert(1,Aeditor[5]);
					objc_change(tree,c,0,tree->ob_x,tree->ob_y,
						tree->ob_width,tree->ob_height,tree[c].ob_state&~SELECTED,TRUE);
					break;
				case CHAROK:
					ende = TRUE;
					break;
				default:
					graf_mkstate(&ret,&ret,&ret,&kstate);
					if(kstate&(K_LSHIFT|K_RSHIFT))
					{
						sprintf(alertstr,Aeditor[1],
							(c-FCHAR)&0xff,(c-FCHAR)&0xff,(c-FCHAR)&0xff);
						if(form_alert(2,alertstr) == 2)
						{
							ende = TRUE;
						}
					}
					else
					{
						ende = TRUE;
					}
					objc_change(tree,c,0,
						tree->ob_x,tree->ob_y,tree->ob_width,tree->ob_height,
						NORMAL,TRUE);
					break;
			}
		}
		while(!ende);
		form_exclose(tree,c,FALSE);
		tree[FCHAR+256].ob_state&=~SELECTED;

		Wdefattr(wp);

		if(c>0 && c<(FCHAR+256))
			editor(wp,0,(c-FCHAR)&0xff,&dummy,&dummy);
	}
}

static MEVENT mevent=
{
	MU_TIMER|MU_KEYBD,
	2,1,1,
	0,0,0,0,0,
	0,0,0,0,0,
	NULL,
	0L,
	0,0,0,0,0,0,
/* nur der VollstÑndigkeit halber die Variablen von XGEM */
	0,0,0,0,0,
	0,
	0L,
	0L,0L
};

/* mit ALT-Taste Dezimalwert eingeben, nur GEMDOS */
int altnum(int *state, int *key)
{
#if GEMDOS
	char num[4];
	register int i=1,event;
/*
	if(ckbd) return(FALSE); /*Wenn Compose Keyboard geladen ist, raus.*/
*/
/* geht auch dann nicht
	if(_GemParBlk.global[0]>=0x0400) /* Falcon TOS kanns selbst */
		return(FALSE);
*/						 /* & geht nicht wg. Shift*/
	if((*state == K_ALT) && isdigit(*key))
	{  /*  1		2		3		4  */
		num[0]=num[1]=num[2]=num[3]=0;
		num[0]=(char)(*key);
      mevent.e_time=0;
		do
		{
			 event=evnt_event(&mevent);
			 if(event & MU_KEYBD)
			 {
				 if(!isdigit(mevent.e_kr))
					 return(FALSE);
				 num[i++]=(char)mevent.e_kr;
			 }
		}
		while(i<4 && (mevent.e_ks == K_ALT));
		if((i=atoi(num))>0)
		{
			*state=0;
			*key=i;
			return(TRUE);
		}
	}
#endif
	return(FALSE);
}

int special(WINDOW *wp, WINDOW **blkwp, int state, int key, LINESTRUCT **begcut, LINESTRUCT **endcut)
{
	LINESTRUCT *line;
	int ret=FALSE,i,mx,my,y,len,used,wordend;
	char *cp;
	unsigned char c;
	extern int exitcode;
	extern char errorstr[];
	extern OBJECT *markmenu,*divmenu;
	extern WINDOW _wind[];
   GRECT rect;
   
	if(wp) /* ab jetzt nur mit offenem Fenster */
	{
		if(!state)
		{
			switch(key)
			{
				case 0x8052: /* INSERT */
               graf_mouse(M_OFF,NULL);
               Wcursor(wp);
					Menu_icheck(winmenu,FORMINS,(wp->w_state^=INSERT)&INSERT?TRUE:FALSE);
					Wcuron(wp);
               Wcursor(wp);
/*
               graf_mouse(M_ON,NULL);
*/
					return(TRUE);
				case 0x8061: /* UNDO */
					do_undo(wp);
					return(TRUE);
				case 0x8062: /* HELP */
					if(!help())
					{
                  sprintf(alertstr,Aeditor[2],(char *)(divmenu[DIVHDA].ob_spec.index/*+16L*/));
						form_alert(1,alertstr);
					}
					return(TRUE);
			}
			return(FALSE);
		}
		if(state & (K_LSHIFT | K_RSHIFT))
		{
			switch(key)
			{
            case 0x8252: /* Shift Insert */
               return(TRUE);
				case 0x8261: /* Shift Undo */
					return(TRUE);
				case 0x8262: /* Shift Help = Compilerfehlermeldung anzeigen */
					if(*errorstr=='\"' && errorstr[strlen(errorstr)-1]=='\"')
					{
						if(wp->kind & INFO)
							wind_set(wp->wihandle,WF_INFO,errorstr);
						else
							form_alert(1,Aeditor[3]);
					}
					else
						form_alert(1,Aeditor[4]);
					return(TRUE);
				case 0x027F: /* Shift DELETE */
					if(cut)
						free_blk(wp,(*begcut));
					if(!wp->cstr->next && !wp->cstr->used)
						return(TRUE); /* die letzte Zeile ist leer, beenden! */
					undo.item=FALSE;
					if(!(*begcut) && !(*endcut))
					{
						mx=wp->xwork+wp->col*wp->wscroll+1;
						my=wp->ywork+wp->row*wp->hscroll+1;
						if(Wdclickline(wp,begcut,endcut,mx,my))
						{
							graf_mouse(M_OFF,0L);
							line=wp->cstr->next;
							if(line)
							{
	   						Wcursor(wp);
								free_undoblk(wp, undo.blkbeg);
								cut=cut_blk(wp,(*begcut),(*endcut));
								undo.flag=copy_blk(wp,(*begcut),(*endcut),&undo.blkbeg,&undo.blkend);
								wp->col=-wp->wfirst/wp->wscroll;
								wp->cspos=Wshiftpage(wp,0,wp->cstr->used);
								/* ^Y Korrektur am Textende */
								if(wp->cstr != line && wp->cstr->next)
									wp->cstr=wp->cstr->next;
								Wcuron(wp);
								Wcursor(wp);
								free_blk(wp,(*begcut));
							}
							else /* Cursor in letzter Zeile */
							{
	   						Wcursor(wp);
								free_undoblk(wp, undo.blkbeg);
								undo.flag=copy_blk(wp,(*begcut),(*endcut),&undo.blkbeg,&undo.blkend);
								wp->col=-wp->wfirst/wp->wscroll;
								wp->cspos=Wshiftpage(wp,0,wp->cstr->used);
							   wp->cstr->used=0;
							   wp->cstr->string[0]=0;
   							refresh(wp, wp->cstr, wp->col, wp->row);
   							Wcuron(wp);
	   						Wcursor(wp);
								hide_blk(wp,*begcut,*endcut);
							}
							undo.menu=WINEDIT;
							undo.item=EDITPAST;
/*
							graf_mouse(M_ON,0L);
*/
							return(TRUE);
						}
					}
				   break;
			}
			return(FALSE);
		}
		if(state & K_CTRL)
		{
/* 1.10.94 Dialog
			switch(key) /* ^F8 ist fast wie ^a, deshalb hier*/
			{
				/* Textformatierung ^F8  = linksbÅndig */
				/*                  ^F9  = zentriert   */
				/*                  ^F10 = rechtsbÅndig */
				case 0x8442: /* ^F8  */
				case 0x8443: /* ^F9  */
				case 0x8444: /* ^F10 */
					textformat2(wp, begcut, endcut, key, ...);
					return(TRUE);
					break;
			}
*/
			switch(__tolower((char)key))
			{
			   case 'y':
					if(cut)
						free_blk(wp,(*begcut));
					if(!wp->cstr->next && !wp->cstr->used)
						return(TRUE); /* die letzte Zeile ist leer, beenden! */
					undo.item=FALSE;
					if(!(*begcut) && !(*endcut))
					{
						mx=wp->xwork+wp->col*wp->wscroll+1;
						my=wp->ywork+wp->row*wp->hscroll+1;
						if(Wdclickline(wp,begcut,endcut,mx,my))
						{
							graf_mouse(M_OFF,0L);
							line=wp->cstr->next;
							if(line)
							{
	   						Wcursor(wp);
								free_undoblk(wp, undo.blkbeg);
								cut=cut_blk(wp,(*begcut),(*endcut));
								undo.flag=copy_blk(wp,(*begcut),(*endcut),&undo.blkbeg,&undo.blkend);
								wp->col=-wp->wfirst/wp->wscroll;
								wp->cspos=Wshiftpage(wp,0,wp->cstr->used);
								/* ^Y Korrektur am Textende */
								if(wp->cstr != line && wp->cstr->next)
									wp->cstr=wp->cstr->next;
								Wcuron(wp);
								Wcursor(wp);
								
								if(clipbrd)
								{
									mevent.e_time=250;
   								if(!(evnt_event(&mevent)&MU_KEYBD))
	   								write_clip(wp,(*begcut),(*endcut));
									free_blk(wp,(*begcut));
								}
							}
							else /* Cursor in letzter Zeile */
							{
	   						Wcursor(wp);
								free_undoblk(wp, undo.blkbeg);
								undo.flag=copy_blk(wp,(*begcut),(*endcut),&undo.blkbeg,&undo.blkend);
								wp->col=-wp->wfirst/wp->wscroll;
								wp->cspos=Wshiftpage(wp,0,wp->cstr->used);
							   wp->cstr->used=0;
							   wp->cstr->string[0]=0;
							   wp->w_state|=CHANGED;
   							refresh(wp, wp->cstr, wp->col, wp->row);
   							Wcuron(wp);
	   						Wcursor(wp);
   							if(clipbrd)
   							{
                           mevent.e_time=250;
   								if(!(evnt_event(&mevent)&MU_KEYBD))
   		   						write_clip(wp,(*begcut),(*endcut));
								}
								hide_blk(wp,*begcut,*endcut);
							}
							undo.menu=WINEDIT;
							undo.item=EDITPAST;
/*
							graf_mouse(M_ON,0L);
*/
							return(TRUE);
						}
					}
					break;
				case 'e': /* E */
					if(wp==*blkwp && *begcut && !(*endcut))  /* Reihenfolge NICHT vertauschen */
					{
						graf_mouse(M_OFF,0L);
						Wcursor(wp);
						*endcut=end_blk(wp,begcut,endcut);
						Wcuroff(wp);
						Wcursor(wp);
/*
						graf_mouse(M_ON,0L);
*/
						if(*endcut==NULL ||						  /* Fehler? oder	 */
						  ((*begcut)->begcol == (*begcut)->endcol)) /* gleiche Stelle? */
						{
							hide_blk(wp,*begcut,*endcut);
							*blkwp=NULL;
						}
						return(TRUE);
					}
					break;
            case 'a': /* A bei SysKey */
				case 'b': /* B */
					if(!cut)								 /* gibt es erst noch mÅll zu lîschen */
						hide_blk(wp,*begcut,*endcut);
					else
						free_blk(wp,*begcut);
					if(!(*begcut) && !(*endcut))
					{
						*begcut=beg_blk(wp,*begcut,*endcut);
						*endcut=NULL;
						cut=FALSE;
						*blkwp=wp;							 /* diesem Fenster gehîrt der Block */
						return(TRUE);
					}
					break;
				case '9': /* Durchfallen und exitcode immer erhîhen */
					exitcode++;
				case '8':
					exitcode++;
				case '7': 
					exitcode++;
				case '6':
					exitcode++;
				case '5':
					exitcode++;
				case '4':
					exitcode++;
				case '3':
					exitcode++;
				case '2':
					exitcode++;
				case '1':
					exitcode++;
				case '0': /* CTRL-Ziffernblock = Exitcode */
					if(exitcode)
					{
                  graf_mouse(M_ON, NULL);/* nur bei eventgesteuerter Maus */
/*
					   if(wp->w_state & CHANGED)
					   {
							if(!strcmp((char *)Wname(wp),NAMENLOS))
								write_file(wp,TRUE);
							else
   		   			   write_file(wp,FALSE);
   		   	   }
				   	for(i=1;i<MAXWINDOWS;i++)
			   		   _wind[i].w_state &= ~CHANGED;
*/
/* alles sichern MT 18.6.95 */
				   	for(i=1;i<MAXWINDOWS;i++)
			   		   if(_wind[i].w_state & CHANGED)
			   		   {
								if(!strcmp((char *)Wname(wp),NAMENLOS))
									write_file(wp,TRUE);
								else
   			   			   write_file(wp,FALSE);
				   		   _wind[i].w_state &= ~CHANGED;
			   		   }
		   			exit(exitcode);
					}
					break;
			}
			switch(key)
			{
            case 0x8452: /* ^Insert */
               return(TRUE);
            case 0x8461: /* ^Undo */
               return(TRUE);
            case 0x8462: /* ^Help */
               return(TRUE);
				case 0x0408: /* ^BACKSPACE */
					if(cut)
						free_blk(wp,(*begcut));
					if(!(*begcut) && !(*endcut))
					{
						wp->w_state|=CHANGED; /* es wurde editiert */
						lastwstr=wp->wstr;
						lasthfirst=wp->hfirst;
						begline=wp->row+wp->hfirst/wp->hscroll;
						endline=begline;
						*begcut=*endcut=wp->cstr;
						(*begcut)->endcol=(*endcut)->endcol=wp->col+wp->wfirst/wp->wscroll;
						for(wordend=(*begcut)->endcol; wordend>0; wordend--)
							if((*begcut)->string[wordend]==' ')
								break;
						for(wordend; wordend>0; wordend--)
							if((*begcut)->string[wordend-1]!=' ')
								break;
						(*begcut)->begcol=(*endcut)->begcol=wordend;
						(*begcut)->attr  =((*endcut)->attr|=SELECTED);

						if((*begcut)->begcol==0 && (*begcut)->endcol==wp->cstr->used)
							endline++; /* Rest der Zeile */

						graf_mouse(M_OFF,0L);
						Wcursor(wp);
/*GEMDOS*/			mark_line(wp,wp->cstr,wp->row);
						evnt_timer(25,0);
						cut=cut_blk(wp,(*begcut),(*endcut));
						free_undoblk(wp, undo.blkbeg);
						undo.flag=copy_blk(wp,(*begcut),(*endcut),&undo.blkbeg,&undo.blkend);
						Wcuron(wp);
						Wcursor(wp);
/*
						graf_mouse(M_ON,0L);
*/
						undo.menu=WINEDIT;
						undo.item=EDITPAST;
						return(TRUE);
					}
					break;
				case 0x047F: /* ^DELETE */
					if(cut)
						free_blk(wp,(*begcut));
					if(!(*begcut) && !(*endcut))
					{
						wp->w_state|=CHANGED; /* es wurde editiert */
						lastwstr=wp->wstr;
						lasthfirst=wp->hfirst;
						begline=wp->row+wp->hfirst/wp->hscroll;
						endline=begline;
						*begcut=*endcut=wp->cstr;
						(*begcut)->begcol=(*endcut)->begcol=wp->col+wp->wfirst/wp->wscroll;
						for(wordend=(*begcut)->begcol; wordend<wp->cstr->used; wordend++)
							if((*begcut)->string[wordend]==' ')
								break;
						for(wordend; wordend<wp->cstr->used; wordend++)
							if((*begcut)->string[wordend]!=' ')
								break;
						(*begcut)->endcol=(*endcut)->endcol=wordend;
						(*begcut)->attr  =((*endcut)->attr|=SELECTED);

						if((*begcut)->begcol==0 && (*begcut)->endcol==wp->cstr->used)
							endline++; /* Rest der Zeile */

						graf_mouse(M_OFF,0L);
						Wcursor(wp);
/*GEMDOS*/			mark_line(wp,wp->cstr,wp->row);
						evnt_timer(25,0);
						cut=cut_blk(wp,(*begcut),(*endcut));
						free_undoblk(wp, undo.blkbeg);
						undo.flag=copy_blk(wp,(*begcut),(*endcut),&undo.blkbeg,&undo.blkend);
						Wcuron(wp);
						Wcursor(wp);
/*
						graf_mouse(M_ON,0L);
*/
						undo.menu=WINEDIT;
						undo.item=EDITPAST;
						return(TRUE);
					}
					break;
			}
			return(FALSE);
		}
		if(state & K_ALT)
		{
			switch(__tolower((char)key))
			{
				case '1':				/* Textmarken anspringen */
				case '2':
				case '3':
				case '4':
				case '5':
					if(state & (K_LSHIFT|K_RSHIFT))
					{
						textmarker(wp,markmenu,0,state,(char)key-'1');
						return(TRUE);
					}
					break;
				case '~': /* ALT~ = linetoggle */
				   if(wp->cstr->next)
				   {
						wp->w_state		|= CHANGED; /* es wurde editiert */
						used				 = wp->cstr->next->used;
						len				 = wp->cstr->next->len;
						cp					 = wp->cstr->next->string;
						wp->cstr->next->string = wp->cstr->string,
						wp->cstr->next->used	  = wp->cstr->used;
						wp->cstr->next->len	  = wp->cstr->len;
						wp->cstr->used	= used;
						wp->cstr->len	 = len;
						wp->cstr->string = cp;
						graf_mouse(M_OFF,0L);
						Wcursor(wp);
						refresh(wp,wp->cstr,		  0,wp->row  );
						refresh(wp,wp->cstr->next,0,wp->row+1);
						Wcursor(wp);
/*
						graf_mouse(M_ON,0L);
*/
						undo.item=FALSE;
						return(TRUE);
					}
					break;
			}
			switch(key)
			{
/* 2.10.94
				/* Texteffekte */
				case 0x883E: /* ALT-F4 */
				case 0x883F: /* ALT-F5 */
				case 0x8840: /* ALT-F6 */
					switch(key)
					{
						case 0x883E: /* ALT-F4 */
							wp->cstr->effect  = TXT_NORMAL;
							break;
						case 0x883F: /* ALT-F5 */
							wp->cstr->effect ^= TXT_THICKENED;
							break;
						case 0x8840: /* ALT-F6 */
							wp->cstr->effect ^= TXT_SKEWED;
							break;
					}
					graf_mouse(M_OFF,0L);
					Wcursor(wp);
					rect.g_x=wp->xwork;
					rect.g_y=wp->ywork + wp->row * wp->hscroll;
					rect.g_w=wp->wwork;
					rect.g_h=wp->hscroll;
					Wredraw(wp,&rect);
			      Wcuron(wp);
					Wcursor(wp);
/*
					graf_mouse(M_ON,0L);
*/
					return(TRUE);				
*/
            case 0x8861: /* ALT-UNDO */
               return(TRUE);
				case 0x087F: /* ALT-DELETE, bis zum Ende der Zeile lîschen */
					if(cut)
						free_blk(wp,(*begcut));
					if(!(*begcut) && !(*endcut))
					{
						wp->w_state|=CHANGED; /* es wurde editiert */
						lastwstr=wp->wstr;
						lasthfirst=wp->hfirst;
						begline=wp->row+wp->hfirst/wp->hscroll;
						endline=begline;
						*begcut=*endcut=wp->cstr;
						(*begcut)->begcol=(*endcut)->begcol=wp->col+wp->wfirst/wp->wscroll;
						(*begcut)->endcol=(*endcut)->endcol=wp->cstr->used;
						(*begcut)->attr  =((*endcut)->attr|=SELECTED);
						if((*begcut)->begcol == 0) /* ganze Zeile */
							endline++;
						graf_mouse(M_OFF,0L);
						Wcursor(wp);
/*GEMDOS*/			mark_line(wp,wp->cstr,wp->row);
						evnt_timer(25,0);
						cut=cut_blk(wp,(*begcut),(*endcut));
						free_undoblk(wp, undo.blkbeg);
						undo.flag=copy_blk(wp,(*begcut),(*endcut),&undo.blkbeg,&undo.blkend);
						Wcuron(wp);
						Wcursor(wp);
/*
						graf_mouse(M_ON,0L);
*/
						undo.menu=WINEDIT;
						undo.item=EDITPAST;
						return(TRUE);
					}
					break;
			}
			return(FALSE);
		}
	}
	else
	{
		if(!state)
		{
			switch(key)
			{
				case 0x8062: /* Help */
					if(!help())
						form_alert(1,Aeditor[2]);
					return(TRUE);
				case 0x8061: /* UNDO */
					desel_icons(desktop,DESKICN1,DESKICNC,TRUE);
					return(TRUE);
			}
			return(FALSE);
		}
		if(state & K_CTRL)
		{
		   switch(__tolower((char)key))
		   {
				case '9': /* Durchfallen und exitcode immer erhîhen */
					exitcode++;
				case '8':
					exitcode++;
				case '7': 
					exitcode++;
				case '6':
					exitcode++;
				case '5':
					exitcode++;
				case '4':
					exitcode++;
				case '3':
					exitcode++;
				case '2':
					exitcode++;
				case '1':
					exitcode++;
				case '0': /* CTRL-Ziffernblock = Exitcode */
					if(exitcode)
					{
/*
                  graf_mouse(M_ON, NULL);/* nur bei eventgesteuerter Maus */
					   if(wp->w_state & CHANGED)
					   {
							if(!strcmp((char *)Wname(wp),NAMENLOS))
								write_file(wp,TRUE);
							else
   		   			   write_file(wp,FALSE);
   		   	   }
				   	for(i=1;i<MAXWINDOWS;i++)
			   		   _wind[i].w_state &= ~CHANGED;
		   			exit(exitcode);
*/
					}
					break;
			}
			return(FALSE);
		}
		if(state & K_ALT)
		{
			return(FALSE);
		}
	}
	return(FALSE);
}
