/* Suchen und Ersetzen. Man beachte die for-Schleife in Z.815  */
/*****************************************************************************
*
*											  7UP
*										Modul: FINDREP.C
*									 (c) by TheoSoft '90
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <time.h>
#include <ctype.h>
#include <aes.h>
#include <vdi.h>

#include "alert.h"
#include "windows.h"
#include "forms.h"
#include "7UP.h"

#include "language.h"

#define POSITION_OFFSET (wp->hwork/wp->hscroll/4)
#define FSTRLEN			60

int adjust_best_position(WINDOW *wp); /* eventuell unten anpassen */
refresh(WINDOW *wp, LINESTRUCT *line, int col, int row);
char *match(char *first, char *what, char *how, int *len, char all, char one);
char *imatch(char *first, char *what, char *how, int *len, char all, char one);
char *grep(char *, char *, int *);
char *igrep(char *, char *, int *);

typedef struct
{
	int menu,item;
} UNDO;

extern UNDO undo;

extern OBJECT *findmenu,*replmenu,*gotomenu;
extern char alertstr[];
extern LINESTRUCT *lastwstr;
extern long begline,endline,lasthfirst;
extern int vdihandle,cut,or,kz,zz,fz,ur;

char searchstring[STRING_LENGTH+1];

void redraw(register WINDOW *wp, register LINESTRUCT *line, register long i, int replace)
{
	LINESTRUCT *help;
	int found=FALSE,pxy[4];
	long h,k,offset;

	graf_mouse(M_OFF,NULL);

	offset=POSITION_OFFSET;
	if(wp->hsize>wp->hwork)
	{
		h=wp->hfirst;
		for(k=0, help=wp->wstr; help && k<wp->hwork/wp->hscroll; k++, help=help->next)
		{
			if(help==line)
			{
				found=TRUE;
				break;
			}
		}
		if(found)
		{
			wp->cstr=line;
		}
		else
		{
			help=wp->fstr;  /* retten */
			wp->cstr=wp->wstr=wp->fstr;
			for(line=wp->fstr, k=0; k<i; line=line->next,k++)
			{
				wp->wstr=wp->wstr->next;
				wp->cstr=wp->cstr->next;
			}
			for(k=0; k<offset && wp->wstr->prev; k++, i--, wp->wstr=wp->wstr->prev)
				;
			wp->fstr=help;					  /* wieder herstellen */
			wp->hfirst = i * wp->hscroll;  /* anfang setzen */
			adjust_best_position(wp);		/* eventuell unten anpassen */
		}
		wp->row=0;
		for(line=wp->wstr; line!=wp->cstr; line=line->next)
			wp->row++;

		if(replace)
		{
			if(h==wp->hfirst)
			{
				for(line=wp->wstr, i=0; line!=wp->cstr; line=line->next, i++)
					;
				pxy[0]=wp->xwork;
				pxy[1]=wp->ywork+i*wp->hscroll;
				pxy[2]=wp->wwork;
				pxy[3]=wp->hscroll;
			}
			else
			{
				pxy[0]=wp->xwork;
				pxy[1]=wp->ywork;
				pxy[2]=wp->wwork;
				pxy[3]=wp->hwork;
			}
			Wredraw(wp,pxy);
		}
		else
		{
			if(h!=wp->hfirst)	/* redraw nîtig? */
			{
				pxy[0]=wp->xwork;
				pxy[1]=wp->ywork;
				pxy[2]=wp->wwork;
				pxy[3]=wp->hwork;
				Wredraw(wp,pxy);
			}
		}
	}
	else
	{
		wp->cstr=wp->fstr;
		wp->row=0;
		for(k=0; k<i; k++)
		{
			wp->cstr=wp->cstr->next;
			wp->row++;
		}
		if(replace)
		{
			pxy[0]=wp->xwork;
			pxy[1]=wp->ywork+i*wp->hscroll;
			pxy[2]=wp->wwork;
			pxy[3]=wp->hscroll;
			Wredraw(wp,pxy);
		}
	}
	Wslupdate(wp,1+2+4+8);
	graf_mouse(M_ON,NULL);
}

static int repl_string(LINESTRUCT *line, int index, int findstrlen, char *replstr, int replstrlen, int replall)
{
	char save;
	char *sp;
	char *help;
	int newlen;

	if(replstrlen==0)
	{
		strcpy(&line->string[index],&line->string[index+findstrlen]);
		line->used-=findstrlen;
		return(index);
	}
	if(replstrlen<findstrlen)
	{
		memmove(&line->string[index],replstr,replstrlen);
		strcpy(&line->string[index+replstrlen],&line->string[index+findstrlen]);
		line->used-=(findstrlen-replstrlen);
		return(index);
	}
	if(replstrlen==findstrlen)
	{
		if(replstrlen==1)
			line->string[index]=*replstr;
		else
			memmove(&line->string[index],replstr,replstrlen);
		return(index);
	}
	newlen=line->used+(replstrlen-findstrlen);
	if(!(newlen<line->len))
	{
		if(!(newlen<STRING_LENGTH))
			return(-1);
		if((help=realloc(line->string,newlen+1)) == NULL)
			return(-2);											 /* Fehler! */
		else
		{
			line->string=help;
			line->len=newlen;
		}
	}
	memmove(&line->string[index+replstrlen],
			  &line->string[index+findstrlen],
			  strlen(&line->string[index+findstrlen])+1);/*NULLBYTE*/
	memmove(&line->string[index],replstr,replstrlen);
	line->used=newlen;
	return(index);
}

int __isupper(char c)
{
	switch(c)
	{
		case 'é':
		case 'ô':
		case 'ö':
			return(TRUE);
		default:
			return(isupper(c));
	}
}

int __islower(char c)
{
	switch(c)
	{
		case 'Ñ':
		case 'î':
		case 'Å':
			return(TRUE);
		default:
			return(islower(c));
	}
}

int __toupper(int c)
{
	switch(c)
	{
		case 'Ñ':
		case 'é':
			return('é');
		case 'î':
		case 'ô':
			return('ô');
		case 'Å':
		case 'ö':
			return('ö');
		default:
			return(toupper(c));
	}
}

int __tolower(int c)
{
	switch(c)
	{
		case 'Ñ':
		case 'é':
			return('Ñ');
		case 'î':
		case 'ô':
			return('î');
		case 'Å':
		case 'ö':
			return('Å');
		default:
			return(tolower(c));
	}
}

int __strnicmp(char *s1, char *s2, int n)
{
	while((__toupper(*s1++) == __toupper(*s2++)) && --n)
		;
	return(n);
}

char *stristr(char *s1, char *s2)
{
	register int m;

	if(!*s1 || !*s2)
		return(NULL);

	m=strlen(s2);
	do
	{
		if(!__strnicmp(s1,s2,m))
			return(s1);
		s1++;
	}
	while(*s1);
	return(NULL);
}

char *strristr(char *s1, int index, char *s2, register int m)
{
	register int i,k;
	for(i=index,k=1; i>=0; i--,k++)
	{
		if(!__strnicmp(&s1[i],s2,m)) /* min(k,m) */
			return(&s1[i]);
	}
	return(NULL);
}

char *strrstr(char *s1, int index, const char *s2, register int m)
{
	register int i,k;
	for(i=index,k=1; i>=0; i--,k++)
	{
		if(!strncmp(&s1[i],s2,m)) /* min(k,m) */
			return(&s1[i]);
	}
	return(NULL);
}

int matchlen(char *str, char all) /* LÑnge des matchpattern */
{											/* Beispiel: "*n*w?r*"	 */
	char *cp1,*cp2;					 /*				^ ^	^	  */
	register int i,k;				  /*				| LÑnge = 3 */
											 /* Dieser STAR ist uninteressant */
	k=strlen(str);
	cp1=str;							  /* Anfang */
	cp2=&str[k-1];					  /* Ende	*/
	for(i=k-2; i>=0; i--)			 /* Letzter STAR */
		if(str[i]==all)
		{
			cp1=&str[i];
			break;
		}
	for(i=0, cp1; cp1 != cp2+1L; cp1++)
		if(*cp1 != all)
			i++;
	return(i);				/* Differenz = LÑnge */
}

int greplen(char *str)
{
	return(1);
}

void dialog_positionieren(WINDOW *wp, OBJECT *tree)
{
   int diff, ret;
   GRECT t1, t2;
	
	form_center(tree,&ret,&ret,&ret,&ret);

	memmove(&t1, &tree->ob_x, sizeof(GRECT));
	t1.g_x -= 3; 
	t1.g_y -= 3; 
	t1.g_w += 6;
	t1.g_h += 6;
	t2.g_x = wp->xwork+wp->col*wp->wscroll;
	t2.g_y = wp->ywork+wp->row*wp->hscroll;
	t2.g_w = wp->wscroll;
	t2.g_h = wp->hscroll;
	
	if(rc_intersect(&t1, &t2))
	{
      if((t2.g_y + t2.g_h/2) < (t1.g_y + t1.g_h/2)) 
			tree->ob_y += ((t2.g_y + t2.g_h - t1.g_y) + wp->hscroll);	/* Dialog tiefer setzen */
		else
			tree->ob_y -= ((t1.g_y + t1.g_h - t2.g_y) + wp->hscroll);
	}
}

static int msgbuf[8];
static MEVENT mevent=
{
	MU_MESAG|MU_TIMER,
	2,1,1,
	0,0,0,0,0,
	0,0,0,0,0,
	msgbuf,
	250L,
	0,0,0,0,0,0,
/* nur der VollstÑndigkeit halber die Variablen von XGEM */
	0,0,0,0,0,
	0,
	0L,
	0L,0L
};

int hndl_find(WINDOW *wp, LINESTRUCT **begcut, LINESTRUCT **endcut, int item)
{
	static long zeile=0;						 /* wiedereintrittsfester ZÑhler */
	static LINESTRUCT *line=0L;
	static WINDOW *oldwp=0L;
	static long oldsize=0L;
	static int index=0;

	LINESTRUCT *help;
	register long k,count=0;
	int kshift,ret,ask=FALSE,done=FALSE,exit_obj,normal=FALSE,
		 matched=FALSE,greped=FALSE,
		 replace=FALSE,inblk=FALSE,replall=FALSE,ignore=FALSE;
	int findstrlen,replstrlen,forward=TRUE;
	char *sp,one,all,*grepcp=NULL;
	char findstr[FSTRLEN+3],replstr[FSTRLEN+3];
	int y,pxy[4];
	int a,b,c,d,e,f,g,h,i,j,l,m,n;

	if(wp)
	{

		findmenu[FINDFORW-2].ob_flags|=HIDETREE; /* Richung */

		k=wp->hsize/wp->hscroll;
		if(!line || oldwp != wp || oldsize != k || item==SEARFIND)
		{  /* alles auf NULL, wenn anderes Fenster oder neues Suchen */
			index=0;
			oldwp=wp;
			oldsize=k;
		}

		/* wo steht der Cursor jetzt */
		line =wp->cstr;
		zeile=wp->row+wp->hfirst/wp->hscroll;
		index=wp->col+wp->wfirst/wp->wscroll;

		if(item == SEARFIND)							  /* FIND/REPLACE */
		{
			if((!(*begcut) && !(*endcut)) ||
				( (*begcut) && !(*endcut)) || /* offenes Blockende */
				(!(*begcut) &&  (*endcut)))	/* offener Blockanfang */
/*
			if(!(*begcut) && !(*endcut))
*/
			{
				findmenu[FINDBLK].ob_state &=~SELECTED;
				findmenu[FINDBLK].ob_state |= DISABLED;
			}
			if((*begcut) && (*endcut) && (*begcut)==(*endcut))
			{
				findmenu[FINDBLK].ob_state &=~DISABLED;
				findmenu[FINDBLK].ob_state &=~SELECTED;
			}
			if((*begcut) && (*endcut) && (*begcut)!=(*endcut))
			{
				findmenu[FINDBLK].ob_state &=~DISABLED;
				findmenu[FINDBLK].ob_state |= SELECTED;
			}
										/* Es soll im Block gesucht werden */
										/*					||					 */
			if((*begcut) && (*endcut) && (*begcut)==(*endcut) && (*endcut)->begcol<(*endcut)->used)
			{
				strncpy(searchstring,&(*begcut)->string[(*begcut)->begcol],(*begcut)->endcol-(*begcut)->begcol);
				searchstring[(*begcut)->endcol-(*begcut)->begcol]=0;
				searchstring[findmenu[FINDSTR].ob_spec.tedinfo->te_txtlen-1]=0;
			}
			if(*searchstring && !matched && !greped) /* nur dann! */
			{
				form_write(findmenu,FINDSTR,searchstring,FALSE);
				form_write(findmenu,FINDREPL,searchstring,FALSE);
			}
			a=findmenu[FINDMAT ].ob_state; /* Objektstati fÅr ABBRUCH merken */
			b=findmenu[FINDNORM].ob_state;
			c=findmenu[FINDGREP].ob_state;
			d=findmenu[FINDSUCH].ob_state;
			e=findmenu[FINDERS ].ob_state;
			f=findmenu[FINDBLK ].ob_state;
			g=findmenu[FINDANF ].ob_state;
			h=findmenu[FINDASK ].ob_state;
			i=findmenu[FINDALL ].ob_state;
			j=findmenu[FINDIGNO].ob_state;
			l=findmenu[FINDWORD].ob_state;
			m=findmenu[FINDFORW].ob_state;
			n=findmenu[FINDBACK].ob_state;
			form_exopen(findmenu,0);
			do
			{
				exit_obj=(form_exdo(findmenu,FINDSTR)&0x7FFF);
				switch(exit_obj)
				{
					case FINDFORW:
						findmenu[FINDGREP].ob_state &=~DISABLED;
						objc_update(findmenu,FINDGREP,0);
						findmenu[FINDMAT].ob_state &=~DISABLED;
						objc_update(findmenu,FINDMAT,0);
						findmenu[FINDANF].ob_state &=~DISABLED;
						objc_update(findmenu,FINDANF,0);
						break;
					case FINDBACK:
						findmenu[FINDNORM].ob_state |= SELECTED;
						objc_update(findmenu,FINDNORM,0);
						findmenu[FINDMAT].ob_state &=~SELECTED;
						findmenu[FINDMAT].ob_state |= DISABLED;
						objc_update(findmenu,FINDMAT,0);
						findmenu[FINDGREP].ob_state &=~SELECTED;
						findmenu[FINDGREP].ob_state |= DISABLED;
						objc_update(findmenu,FINDGREP,0);
						findmenu[FINDANF].ob_state &=~SELECTED;
						findmenu[FINDANF].ob_state |= DISABLED;
						objc_update(findmenu,FINDANF,0);
						break;
					case FINDMAT:
					case FINDGREP:
						findmenu[FINDFORW].ob_state |=SELECTED;
						objc_update(findmenu,FINDFORW,0);
						findmenu[FINDBACK].ob_state &=~SELECTED;
						findmenu[FINDBACK].ob_state |=DISABLED;
						objc_update(findmenu,FINDBACK,0);
						findmenu[FINDWORD].ob_state &=~SELECTED;
						findmenu[FINDWORD].ob_state |= DISABLED;
						objc_update(findmenu,FINDWORD,0);
						break;
					case FINDNORM:
						findmenu[FINDBACK].ob_state &=~DISABLED;
						objc_update(findmenu,FINDBACK,0);
						findmenu[FINDWORD].ob_state &=~DISABLED;
						objc_update(findmenu,FINDWORD,0);
						break;
					case FINDSUCH:
						if(findmenu[FINDNORM].ob_state & SELECTED)
						{
							findmenu[FINDWORD].ob_state &=~DISABLED;
							objc_update(findmenu,FINDWORD,0);
						}
						findmenu[FINDALL].ob_state&=~SELECTED;
						findmenu[FINDALL].ob_state|=DISABLED;
						objc_update(findmenu,FINDALL,0);
						findmenu[FINDASK].ob_state&=~SELECTED;
						findmenu[FINDASK].ob_state|=DISABLED;
						objc_update(findmenu,FINDASK,0);
						break;
					case FINDERS:
						if(findmenu[FINDNORM].ob_state & SELECTED)
						{  /* nicht bei match oder grep */
							findmenu[FINDWORD].ob_state &=~DISABLED;
							objc_update(findmenu,FINDWORD,0);
						}
						findmenu[FINDALL].ob_state&=~DISABLED;
						objc_update(findmenu,FINDALL,0);
						findmenu[FINDASK].ob_state&=~DISABLED;
						objc_update(findmenu,FINDASK,0);
						break;
					case FINDBLK:
						findmenu[FINDANF].ob_state&=~SELECTED;
						objc_update(findmenu,FINDANF,0);
						break;
					case FINDANF:
						line=wp->fstr;
						zeile=0;
						findmenu[FINDBLK].ob_state&=~SELECTED;
						objc_update(findmenu,FINDBLK,0);
						break;
					case FINDHELP:
						if(findmenu[FINDNORM].ob_state&SELECTED)
						{
							form_alert(1,Afindrep[0]);
						}
						if(findmenu[FINDMAT ].ob_state&SELECTED)
						{
							form_alert(1,Afindrep[1]);
						}
						if(findmenu[FINDGREP].ob_state&SELECTED)
						{
							if(form_alert(2,Afindrep[2])==2)
								if(form_alert(2,Afindrep[3])==2)
									form_alert(1,Afindrep[4]);
						}
						objc_change(findmenu,exit_obj,0,findmenu->ob_x,findmenu->ob_y,findmenu->ob_width,findmenu->ob_height,findmenu[exit_obj].ob_state&~SELECTED,TRUE);
						break;
					case FINDOK:
					case FINDABBR:
						done=TRUE;
						break;
				}
			}
			while(!done);
			form_exclose(findmenu,exit_obj,0);
			if(exit_obj==FINDABBR)
			{
				findmenu[FINDMAT ].ob_state=a;
				findmenu[FINDNORM].ob_state=b;
				findmenu[FINDGREP].ob_state=c;
				findmenu[FINDSUCH].ob_state=d;
				findmenu[FINDERS ].ob_state=e;
				findmenu[FINDBLK ].ob_state=f;
				findmenu[FINDANF ].ob_state=g;
				findmenu[FINDASK ].ob_state=h;
				findmenu[FINDALL ].ob_state=i;
				findmenu[FINDIGNO].ob_state=j;
				findmenu[FINDWORD].ob_state=l;
				findmenu[FINDFORW].ob_state=m;
				findmenu[FINDBACK].ob_state=n;
				return(FALSE);
			}
		}
		if(item==SEARNEXT || item==SEARSEL) /* WEITERSUCHEN */
		{
			if(findmenu[FINDBACK].ob_state & SELECTED) /* Richtung festlegen */
			{
				index=wp->col+wp->wfirst/wp->wscroll-1;
				forward=FALSE;
			}
			else
			{
				if(inblk) /* nur vorwÑrts */
					index=wp->col+wp->wfirst/wp->wscroll+1;
				forward=TRUE;
			}

			graf_mkstate(&ret, &ret, &ret, &kshift);
			if(kshift & (K_RSHIFT|K_LSHIFT)) /* Suchrichtungsumkehr */
			{
				if(forward)
				{
					if((findmenu[FINDSUCH].ob_state & SELECTED) &&
						(findmenu[FINDNORM].ob_state & SELECTED))
					{
						findmenu[FINDFORW].ob_state &= ~SELECTED;
						findmenu[FINDBACK].ob_state |=  SELECTED;
						findmenu[FINDANF ].ob_state &= ~SELECTED;
						findmenu[FINDANF ].ob_state |=  DISABLED;
						forward=FALSE;
						index--;
					}
				}
				else
				{
					if((findmenu[FINDSUCH].ob_state & SELECTED) &&
						(findmenu[FINDNORM].ob_state & SELECTED))
					{
						findmenu[FINDBACK].ob_state &= ~SELECTED;
						findmenu[FINDFORW].ob_state |=  SELECTED;
						findmenu[FINDANF ].ob_state &= ~DISABLED;
						forward=TRUE;
						index++;
					}
				}
			}
			if(item!=SEARSEL)
				if(!(findmenu[FINDBLK].ob_state & SELECTED)) /* !inblk */
				{
					if(!cut)
						hide_blk(wp,*begcut,*endcut);
					else
						free_blk(wp,*begcut);
				}
		}
		if(item==SEARSEL)
		{
			findmenu[FINDNORM].ob_state = SELECTED; /* alles auf null fÅr Find Selection */
			findmenu[FINDMAT ].ob_state = NORMAL;
			findmenu[FINDGREP].ob_state = NORMAL;

			findmenu[FINDSUCH].ob_state = SELECTED;
			findmenu[FINDERS ].ob_state = NORMAL;

			findmenu[FINDBLK ].ob_state = NORMAL;

			findmenu[FINDANF ].ob_state = NORMAL;
			findmenu[FINDASK ].ob_state = NORMAL;
			findmenu[FINDALL ].ob_state = NORMAL;

			/* FINDWORD und FINDIGNO sind erlaubt, FINDFORW und FINDBACK auch */

			if((*begcut) && (*endcut) && (*begcut)==(*endcut) && (*endcut)->begcol<(*endcut)->used)
			{	/* zurechtstutzen, auf korrekte LÑnge kÅrzen */
				strncpy(searchstring,&(*begcut)->string[(*begcut)->begcol],(*begcut)->endcol-(*begcut)->begcol);
				searchstring[(*begcut)->endcol-(*begcut)->begcol]=0;
				searchstring[findmenu[FINDSTR].ob_spec.tedinfo->te_txtlen-1]=0;
			}
			else
			{
				Wdclickword(wp,begcut,endcut,wp->xwork+wp->col*wp->wscroll+1,wp->ywork+wp->row*wp->hscroll+1);
			}
			if(*searchstring) /* nur dann! */
			{
				form_write(findmenu,FINDSTR,searchstring,FALSE);
				form_write(findmenu,FINDREPL,"",FALSE);
			}
		}

		form_read(findmenu,FINDSTR,findstr);			  /* sonst NEXT */
		form_read(findmenu,FINDREPL,replstr);

		if(!*findstr)			/* wenn nix zum Suchen da ist, beenden */
		{
			return(FALSE);
		}

		if(findmenu[FINDERS].ob_state & SELECTED)
		{
			replace=TRUE;
		}

		if(findmenu[FINDASK].ob_state & SELECTED)
		{
			ask=TRUE;
		}

		if(findmenu[FINDALL].ob_state & SELECTED)
		{
			replall=TRUE;
		}

		if(!(findmenu[FINDIGNO].ob_state & SELECTED))
		{
			ignore=TRUE;
		}

		if(findmenu[FINDWORD].ob_state & SELECTED)
		{  /* ein Blank vorn und hinten */
			memmove(&findstr[1],findstr,strlen(findstr)+1);
			findstr[0]=' ';
			strcat(findstr," ");
			memmove(&replstr[1],replstr,strlen(replstr)+1);
			replstr[0]=' ';
			strcat(replstr," ");
		}

		if(findmenu[FINDNORM].ob_state & SELECTED)
		{
			findstrlen=strlen(findstr);
			normal=TRUE;
		}

		if(findmenu[FINDMAT].ob_state & SELECTED)
		{
			one= *findmenu[FINDSINQ].ob_spec.tedinfo->te_ptext;
			all= *findmenu[FINDALLQ].ob_spec.tedinfo->te_ptext;
			if(!one || !all)
			{
				form_alert(1,Afindrep[5]);
				return(FALSE);
			}
			findstrlen=matchlen(findstr,all);
			matched=TRUE;
		}

		if(findmenu[FINDGREP].ob_state & SELECTED)
		{
			if(ignore)
			{
				if(!icompile(findstr)) /* immer kompilieren !!! */
				{
					form_alert(1,Afindrep[6]);
					return(FALSE);
				}
			}
			else
			{
				if(!compile(findstr)) /* immer kompilieren !!! */
				{
					form_alert(1,Afindrep[6]);
					return(FALSE);
				}
			}
			findstrlen=greplen(findstr);
			greped=TRUE;
		}

		if(findmenu[FINDANF].ob_state & SELECTED)
		{
			if(item==SEARFIND)
			{
				line=wp->fstr;
				zeile=0;
				index=0;
			}
		}

		if(findmenu[FINDBACK].ob_state & SELECTED)
		{
			forward=FALSE;
		}

		if(findmenu[FINDBLK].ob_state & SELECTED)
		{
			if((*begcut) && (*endcut))
			{
				inblk=TRUE;
				if(item==SEARFIND)
				{
					if(forward)
					{
						for(zeile=0,line=wp->fstr;
							 zeile<k && line!=(*begcut);
							 zeile++,line=line->next)
							;
						index=(*begcut)->begcol;	/* ab Blockbegin suchen */
					}
					else
					{
						for(zeile=0,line=wp->fstr;
							 zeile<k && line!=(*endcut)/*->next*/;
							 zeile++,line=line->next)
							;
						index=min((*endcut)->used-1,(*endcut)->endcol-1);	/* ab Blockende suchen */
					}
				}
			}
		}
		else
		{
			if(!cut)
				hide_blk(wp,*begcut,*endcut);
			else
				free_blk(wp,*begcut);
		}

		form_write(replmenu,REPLSTR,replstr,FALSE);
		if(replace)
			replstrlen=strlen(replstr);
		else
			replstrlen=0;

		graf_mouse(M_OFF,0L);
		Wcursor(wp);		 /* ausschalten */
		if(item==SEARFIND) /* Dialogbox wegrÑumen */
		{
			evnt_event(&mevent); /* Dummyaufruf um Redraw zu killen */
			Wredraw(wp,&msgbuf[4]);
		}
		graf_mouse(M_ON,0L);
#if OLDTOS
		if(!ask)
			graf_mouse(BUSY_BEE,0L);
#endif
		do
		{
			if(forward)
			{
				for(line, zeile;
					 zeile<k && line && (inblk?line!=(*endcut)->next:1);	 /* nur im Block wenn gewÅnscht */
					 line=line->next, zeile++,
					 index=(inblk?(line?line->begcol:0):0))
				{
					if(normal)
					{
						if(ignore)
						{	  /* stristr() unterscheidet nicht zwischen GRO· und klein */
							if(sp=stristr(&line->string[index],findstr))
							{
								if(inblk)
								{
									if((int)(sp - line->string)<=line->endcol)
										break;
								}
								else
									break;
							}
						}
						else
						{
							if(sp=strstr(&line->string[index],findstr))
							{
								if(inblk)
								{
									if((int)(sp - line->string)<=line->endcol)
										break;
								}
								else
									break;
							}
						}
					}
					if(matched)
					{
						if(ignore)
						{
							if(sp=imatch(line->string,&line->string[index],findstr,&findstrlen,all,one))
							{
								if(inblk)
								{
									if((int)(sp - line->string)<=line->endcol)
										break;
								}
								else
									break;
							}
						}
						else
						{
							if(sp=match(line->string,&line->string[index],findstr,&findstrlen,all,one))
							{
								if(inblk)
								{
									if((int)(sp - line->string)<=line->endcol)
										break;
								}
								else
									break;
							}
						}
					}
					if(greped)
					{
						if(ignore)
						{
							if(sp=igrep(&line->string[index],&line->string[index],&findstrlen))
							{
								if(inblk)
								{
									if((int)(sp - line->string)<=line->endcol)
										break;
								}
								else
									break;
							}
						}
						else
						{
							if(sp=grep(&line->string[index],&line->string[index],&findstrlen))
							{
								if(inblk)
								{
									if((int)(sp - line->string)<=line->endcol)
										break;
								}
								else
									break;
							}
						}
					}
				}
			}
			else /* rÅckwÑrts suchen */
			{
				for(line, zeile;
					 zeile>=0 && line && (inblk?line!=(*begcut)->prev:1);	 /* nur im Block wenn gewÅnscht */
					 line=line->prev, zeile--,
					 index=(inblk?(line?min(line->endcol-1,line->used-1):0):(line?line->used-1:0)))
				{
					if(normal)
					{
						if(ignore)
						{	  /* strristr() unterscheidet nicht zwischen GRO· und klein */
							if(sp=strristr(line->string,index,findstr,findstrlen))
							{
								if(inblk)
								{
									if((int)(sp - line->string)>=line->begcol)
										break;
								}
								else
									break;
							}
						}
						else
						{
							if(sp=strrstr(line->string,index,findstr,findstrlen))
							{
								if(inblk)
								{
									if((int)(sp - line->string)>=line->begcol)
										break;
								}
								else
									break;
							}
						}
					}
				}
			}
			if(zeile>=0 && zeile<k &&
				(inblk?(forward?line!=(*endcut)->next:line!=(*begcut)->prev):1))
			{
				index=(int)(sp - line->string);
				if(!replall || ask)
				{
					if(forward)
					{
						wp->cspos=wp->col=index+findstrlen-wp->wfirst/wp->wscroll;
						wp->cspos=Wshiftpage(wp,-findstrlen,line->used);
					}
					else
					{
						wp->cspos=wp->col=index - wp->wfirst/wp->wscroll;
						wp->cspos=Wshiftpage(wp,-findstrlen,line->used);
					}
					if(!inblk)
					{
						if(( (*begcut) && !(*endcut)) || /* offenes Blockende 	*/
							(!(*begcut) &&  (*endcut)))	/* offener Blockanfang 	*/
						{											/* nur Cursor setzen 	*/
							redraw(wp, line, zeile, FALSE);
							wp->cspos=wp->col=index-wp->wfirst/wp->wscroll;
						}
						else
						{
							Wcuroff(wp);
							redraw(wp, line, zeile, FALSE);
							*begcut=*endcut=line;
							(*begcut)->attr|=SELECTED;
							(*begcut)->begcol=index;
							(*begcut)->endcol=index+findstrlen;
							graf_mouse(M_OFF,NULL);
							mark_line(wp,line,zeile-wp->hfirst/wp->hscroll);
							graf_mouse(M_ON,NULL);
							begline=endline=wp->row+wp->hfirst/wp->hscroll;
							lasthfirst=wp->hfirst;
							lastwstr=wp->wstr;
						}
					}
					else
					{
						redraw(wp, line, zeile, FALSE);
						wp->cspos=wp->col=index-wp->wfirst/wp->wscroll;
					}
				}
				if(replace)
				{
					if(ask)
					{
						if(inblk)
						{
							graf_mouse(M_OFF,NULL);
							Wcursor(wp);				/* Cursor einschalten */
							graf_mouse(M_ON,NULL);
						}
						if(!greped) /* evtl. Wildcard nicht Åberschreiben */
							form_write(replmenu,REPLSTR,replstr,FALSE);
/*
						replmenu->ob_flags|=MOVEABLE; /* kein Windial!!! */
*/														  /* oder doch?		*/
						dialog_positionieren(wp, replmenu);
						switch(form_exhndl(replmenu,REPLSTR,FALSE))
						{
							case REPLABBR:
								replall=FALSE;
								break;
							case REPLNEIN:
								replstrlen=1;
								if(!inblk)
								{
									(*begcut)->attr&=~SELECTED;
									(*begcut)->begcol=0;
									(*begcut)->endcol=STRING_LENGTH;
									begline=endline=0L;
									*begcut=*endcut=NULL;
									cut=FALSE;
									redraw(wp, line, zeile, replace);
								}
								break;
							case REPLJA:
								form_read(replmenu,REPLSTR,replstr);
								if(greped)
								{
								   if((grepcp=strstr(replstr,"\\&"))!=NULL)
								   {
								      /* LÅcke erweitern */
								      memmove(&grepcp[findstrlen],
								              &grepcp[2],
								              strlen(&grepcp[2])+1);
								      /* Suchstring wieder einfÅgen */
								      memmove(&grepcp[0],
								              sp,
								              findstrlen);
								   }
								}
								replstrlen=strlen(replstr);
								index=repl_string(line,(int)(sp-line->string),findstrlen,replstr,replstrlen,replall);
								if(index<0)
								{
									switch(index)
									{
										case -1:
		  									sprintf(alertstr,Afindrep[7],STRING_LENGTH);
											break;
										case -2:
		  									sprintf(alertstr,Afindrep[16]);
											break;
									}
		 							form_alert(1,alertstr);
									index=(int)(sp - line->string);
									replall=FALSE;
								}
								else
								{
									if(inblk)
									{
										graf_mouse(M_OFF,NULL);
										Wcursor(wp);	  /* ausschalten */
										redraw(wp, line, zeile, replace);
										Wcursor(wp);	  /* einschalten */
										graf_mouse(M_ON,NULL);
									}
									else
									{
										line->attr&=~SELECTED;
										line->begcol=0;
										line->endcol=STRING_LENGTH;
										begline=endline=0L;
										*begcut=*endcut=NULL;
										cut=FALSE;
										redraw(wp, line, zeile, replace);
									}
									count++;
								}
								break;
						}
						if(inblk)
						{
							graf_mouse(M_OFF,NULL);
							Wcursor(wp);	/* ausschalten */
							graf_mouse(M_ON,NULL);
						}
					}
					else
					{
						if(greped)
						{
							form_read(findmenu,FINDREPL,replstr);
						   if((grepcp=strstr(replstr,"\\&"))!=NULL)
						   {
						      /* LÅcke erweitern */
						      memmove(&grepcp[findstrlen],
						              &grepcp[2],
						              strlen(&grepcp[2])+1);
						      /* Suchstring wieder einfÅgen */
						      memmove(&grepcp[0],
						              sp,
						              findstrlen);
								replstrlen=strlen(replstr);
						   }
						}
						if((index=repl_string(line,(int)(sp-line->string),findstrlen,replstr,replstrlen,replall))<0)
						{
							switch(index)
							{
								case -1: /* StringlÑnge */
  									sprintf(alertstr,Afindrep[7],STRING_LENGTH);
									break;
								case -2: /* Out of memory */
  									sprintf(alertstr,Afindrep[16]);
									break;
							}
							form_alert(1,alertstr);
							index=(int)(sp - line->string);
							replall=FALSE;
						}
						else
							count++;
					}
				}
				if(forward)
				{
					index += replace ? replstrlen : findstrlen;
					if(index > (inblk ? line->endcol-1 : line->used))
					{
						line=line->next;
						if (line)
							index=(inblk?line->begcol:0);
						else
						   index=0;
						zeile++;
					}
				}
				else
				{
					index--;
					if(index < (inblk ? line->begcol : 0))
					{
						line=line->prev;
						if (line)
							index=(inblk?min(line->endcol-1,line->used-1):line->used-1);
						else
						   index=0;
						zeile--;
					}
				}
			}
			else
			{
				if(!replace || ask)
				{
					form_alert(1,Afindrep[8]);
					inblk=FALSE; /* Cursor unsichtbar, wenn Block markiert */
				}
				if(replace && replall)
				{
					redraw(wp, line, forward?zeile-1:zeile+1, replace);
					if(!ask)
					{
						sprintf(alertstr,Afindrep[9],count);
						form_alert(1,alertstr);
					}
					replall=FALSE;
				}
				if(forward)
				{
					if(findmenu[FINDSUCH].ob_state & SELECTED &&
						findmenu[FINDNORM].ob_state & SELECTED)
					{
						findmenu[FINDFORW].ob_state &= ~SELECTED;
						findmenu[FINDBACK].ob_state |=  SELECTED;
						findmenu[FINDANF ].ob_state &= ~SELECTED;
						findmenu[FINDANF ].ob_state |=  DISABLED;
						findmenu[FINDMAT ].ob_state |=  DISABLED;
						findmenu[FINDGREP].ob_state |=  DISABLED;
						forward=FALSE;
					}
				}
				else
				{
					if(findmenu[FINDSUCH].ob_state & SELECTED &&
						findmenu[FINDNORM].ob_state & SELECTED)
					{
						findmenu[FINDBACK].ob_state &= ~SELECTED;
						findmenu[FINDFORW].ob_state |=  SELECTED;
						findmenu[FINDANF ].ob_state &= ~DISABLED;
						findmenu[FINDMAT ].ob_state &= ~DISABLED;
						findmenu[FINDGREP].ob_state &= ~DISABLED;
						forward=TRUE;
					}
				}
			}
		}
		while(replall);
		if(count)
		{
			wp->w_state|=CHANGED; /* es wurde editiert */
			if(!replall)			 /* nicht nîtig, weil schon... */
			{
				graf_mouse(M_OFF,0L);
				Wredraw(wp,&wp->xwork);
				graf_mouse(M_ON,0L);
			}
		}
		graf_mouse(M_OFF,0L);
		if((!(*begcut) && !(*endcut)) ||
			( (*begcut) && !(*endcut)) || /* offenes Blockende */
			(!(*begcut) &&  (*endcut)))	/* offener Blockanfang */
			Wcuron(wp);
		else
		{
			if(inblk && !replace)
				Wcuron(wp);
			else
				Wcuroff(wp);
		}
		Wcursor(wp);  /* einschalten */
		graf_mouse(M_ON,0L);
#if OLDTOS
		graf_mouse(ARROW,0L);
#endif
		return(TRUE);
	}
	return(FALSE);
}

void hndl_blkfind(WINDOW *wp, LINESTRUCT *begcut, LINESTRUCT *endcut, int item)
{
	LINESTRUCT *help;
	int y;
	if(wp)
	{
		if(item==SEARBEG)
		{
			for(help=wp->wstr, y=0;
				 help && y<wp->hwork/wp->hscroll;
				 help=help->next, y++)
				if(help==begcut)
				{
					graf_mouse(M_OFF,0L);
					Wcursor(wp);
					wp->cstr=help;
					wp->cspos=wp->col=help->begcol-wp->wfirst/wp->wscroll;
wp->cspos=Wshiftpage(wp,0,wp->cstr->used);
					Wcursor(wp);
					graf_mouse(M_ON,0L);
					return;
				}
			if(begcut)
			{
				wp->hfirst=0;
				for(help=wp->fstr; help!=begcut; help=help->next)
					wp->hfirst+=wp->hscroll;
				wp->wstr=wp->cstr=help;
				wp->cspos=wp->col=help->begcol-wp->wfirst/wp->wscroll;
wp->cspos=Wshiftpage(wp,0,wp->cstr->used);
				for(y=0; y<POSITION_OFFSET  && wp->wstr->prev;
					 y++, wp->wstr=wp->wstr->prev)
					wp->hfirst-=wp->hscroll;
				adjust_best_position(wp); /* eventuell unten anpassen */
				graf_mouse(M_OFF,0L);
				Wcursor(wp);
				Wredraw(wp,&wp->xwork);
				Wcursor(wp);
				graf_mouse(M_ON,0L);
			}
		}
		else
		{
			for(help=wp->wstr, y=0;
				 help && y<wp->hwork/wp->hscroll;
				 help=help->next, y++)
				if(help==endcut)
				{
					graf_mouse(M_OFF,0L);
					Wcursor(wp);
					wp->cstr=help;
					wp->cspos=wp->col=help->endcol-wp->wfirst/wp->wscroll;
wp->cspos=Wshiftpage(wp,0,wp->cstr->used);
					Wcursor(wp);
					graf_mouse(M_ON,0L);
					return;
				}
			if(endcut)
			{
				 if(begcut==endcut)
				 {
					 graf_mouse(M_OFF,0L);
					 Wcursor(wp);
					 wp->col+=endcut->endcol;
					 wp->cspos=wp->col;
wp->cspos=Wshiftpage(wp,0,wp->cstr->used);
					 Wcursor(wp);
					 graf_mouse(M_ON,0L);
					 return;
				 }
				 wp->hfirst=0;
				 for(help=wp->fstr; help!=endcut; help=help->next)
					 wp->hfirst+=wp->hscroll;
				 wp->wstr=wp->cstr=help;
				 wp->cspos=wp->col=endcut->endcol-wp->wfirst/wp->wscroll;
wp->cspos=Wshiftpage(wp,0,wp->cstr->used);
				 for(y=0; y<POSITION_OFFSET  && wp->wstr->prev;
					  y++, wp->wstr=wp->wstr->prev)
					 wp->hfirst-=wp->hscroll;
				 adjust_best_position(wp); /* eventuell unten anpassen */
				 graf_mouse(M_OFF,0L);
				 Wcursor(wp);
				 Wredraw(wp,&wp->xwork);
				 Wcursor(wp);
				 graf_mouse(M_ON,0L);
			}
		}
	}
}

int iserrfile(WINDOW *wp)
{
	register int k;
	if(wp)
	{
		k=strlen(wp->name);
		if(		  wp->name[k-4] =='.' &&
			toupper(wp->name[k-3])=='E' &&
			toupper(wp->name[k-2])=='R' &&
			toupper(wp->name[k-1])=='R')
			return(TRUE);
		if(		  wp->name[k-4] =='.' &&
			toupper(wp->name[k-3])=='L' &&
			toupper(wp->name[k-2])=='O' &&
			toupper(wp->name[k-1])=='G')
			return(TRUE);
	}
	return(FALSE);
}

int isregfile(WINDOW *wp)
{
	register int k;
	if(wp)
	{
		k=strlen(wp->name);
		if(        wp->name[k-4] =='.' && 
		   toupper(wp->name[k-3])=='R' &&
			toupper(wp->name[k-2])=='E' && 
			toupper(wp->name[k-1])=='G')
			return(TRUE);
	}
	return(FALSE);
}

int hndl_goto(WINDOW *wp, OBJECT *tree, long line)
{
  register LINESTRUCT *help;
  register long i,k,newpos;
  char string[10];
  
  extern LINESTRUCT *begcut,*endcut;

  if(wp)
  {
	  if(tree)
	  {
		  sprintf(string,"%ld",wp->hfirst/wp->hscroll+wp->row+1);
		  form_write(tree,GOTOLINE,string,FALSE);
		  if(form_exhndl(tree,GOTOLINE,FALSE)==GOTOABBR)
			  return(FALSE);
		  form_read(tree,GOTOLINE,string);
		  line=atol(string);
	  }
	  k=wp->hsize/wp->hscroll;
     i=line-1;
     if(TRUE)
	  {
		  if(i<0)
			  i=0;
		  if(i>(k-1))
			  i=k-1;
		  if(i == wp->row + wp->hfirst/wp->hscroll)
			  return(TRUE);
		  for(k=0, help=wp->fstr; k<i && help->next; k++, help=help->next)
			  ;
		  wp->wstr=wp->cstr=help;
		  for(k=0; k<POSITION_OFFSET  && wp->wstr->prev; k++, i--, wp->wstr=wp->wstr->prev)
			  ;
		  wp->hfirst=i*wp->hscroll;
		  adjust_best_position(wp); /* eventuell unten anpassen */
		  graf_mouse(M_OFF,0L);
		  Wcursor(wp);
/* Zeile gleich markieren, wenn nichts markiert oder ausgeschnitten ist */
		  if(/*line==-1 &&*/ tree && !begcut && !endcut)
		  {
			  if(cut)				/* gibt es erst noch mÅll zu lîschen */
				  free_blk(wp,begcut);
			  else
				  hide_blk(wp,begcut,endcut);
			  begcut=endcut=wp->cstr;
			  begcut->attr|=SELECTED;
			  begcut->begcol=0;
			  begcut->endcol=STRING_LENGTH;
			  begline=wp->row+wp->hfirst/wp->hscroll;
			  endline=begline+1;
			  wp->cspos=wp->col=0;
			  lasthfirst=wp->hfirst;
			  lastwstr=wp->wstr;
			  Wcuroff(wp);
		  }
		  Wredraw(wp,&wp->xwork);
		  Wcursor(wp);
		  graf_mouse(M_ON,0L);
	  }
/*
	  else
		  form_alert(1,Afindrep[10]);
*/
  }
  return(FALSE);
}

hndl_page(WINDOW *wp, OBJECT *tree, long line)
{
	long zeile;
	char string[10];
	
	if(wp)
	{
	  form_write(tree,ROOT+2,SUCHE_SEITE,FALSE);
	  strcpy((char* )tree[GOTOLINE-1].ob_spec.index,SEITE_____);
	  sprintf(string,"%ld",(wp->row+wp->hfirst/wp->hscroll)/zz+1);
	  form_write(tree,GOTOLINE,string,FALSE);
	  if(form_exhndl(tree,GOTOLINE,FALSE)==GOTOABBR)
	  {
		  form_write(tree,ROOT+2,SUCHE_ZEILE,FALSE);
		  strcpy((char *)tree[GOTOLINE-1].ob_spec.index,ZEILE_____);
		  return;
	  }
	  form_write(tree,ROOT+2,SUCHE_ZEILE,FALSE);
	  strcpy((char *)tree[GOTOLINE-1].ob_spec.index,ZEILE_____);
	  form_read(tree,GOTOLINE,string);
	  zeile=(atol(string)-1)*zz+1;
	  if(zeile<1)
		  zeile=1;
	  hndl_goto(wp,NULL,zeile);
	}
}

typedef struct
{
	long absrow,abscol;
	LINESTRUCT *line;
	char *string;
	WINDOW *wp;
} LINEMARK;

void gotomark(WINDOW *wp, LINEMARK *mark)
{
  register LINESTRUCT *help;
  register long i,k,newpos;
  char zeile[10];

  if(wp)
  {
	  if(wp!=mark->wp)
	  {
		  if(Wopen(mark->wp)) /* Fensterwechsel */
			  wp=mark->wp;
		  else
			  return;			 /* Fenster existiert nicht mehr */
	  }
	  for(k=0, help=wp->fstr; help; k++, help=help->next)
		  if(help==(LINESTRUCT *)mark->line && help->string==(char *)mark->string)
			  if(mark->abscol > help->used)
			  {
				  for(; help; k++, help=help->next)
					  if(mark->abscol <= help->used)
					  {
						  goto WEITER; /* kein break mîglich */
					  }
			  }
			  else
				  break;
WEITER:
	  if(help)
		  sprintf(zeile,"%ld",k+1);
	  else
		  sprintf(zeile,"%ld",mark->absrow+1);

	  if(hndl_goto(wp,NULL/*gotomenu*/,atol(zeile)))  /* redraw hinterherschicken */
	  {
		  graf_mouse(M_OFF,0L);
		  Wcursor(wp);
		  Wredraw(wp,&wp->xwork);
		  Wcursor(wp);
		  graf_mouse(M_ON,0L);
	  }
	  graf_mouse(M_OFF,0L);
	  Wcursor(wp);
	  wp->col=wp->cspos=mark->abscol-wp->wfirst/wp->wscroll;
wp->cspos=Wshiftpage(wp,0,wp->cstr->used);
	  Wcursor(wp);
	  graf_mouse(M_ON,0L);
  }
}

int inw(char c) /* In Word */
{							 /* ^  ^	 */
	return( ! (c && !isspace(c) && (isalnum(c) || isgerman(c))));
}

int find_next_letter(char *str, int col) /* fÅr control-cursor zum nÑchsten Wort */
{
	register int i,len;

	if(col==-1) /* Sonderfall wg. Zeilenwechsel */
	{
		if(!isspace(str[0]))
			return(0);
		col=0;
	}
	len=strlen(str);
	if(inw(str[col]))
	{
		for(i=col; i<len; i++)
			if(!inw(str[i]))
				break;
		return(i);
	}
	else
	{
		for(i=col; i<len; i++)
			if(inw(str[i]))
				break;
		for(i	 ; i<len; i++)
			if(!inw(str[i]))
				break;
		return(i);
	}
}

int find_prev_letter(char *str, int col) /* von Wort zu Wort mit CONTROL+CURSOR */
{
	register int i;
	if(!str[col])
	{
		if(inw(str[col-1]))
		{
			for(i=col; i>=0; i--)
				if(inw(str[i]))
					break;
			for(i	 ; i>=0; i--)
				if(!inw(str[i]))
					break;
			for(i	 ; i>=0; i--)
				if(inw(str[i]))
					break;
		}
		else
		{
			for(i=col; i>=0; i--)
				if(str[i] && inw(str[i]))
				{
					break;
				}
		}
		return(i+1);
	}
	if(inw(str[col]))
	{
		for(i=col; i>=0; i--)
			if(!inw(str[i]))
				break;
		for(i	 ; i>=0; i--)
			if(inw(str[i]))
				break;
	}
	else
	{
		if(inw(str[col-1]))
		{
			for(i=col; i>=0; i--)
				if(inw(str[i]))
					break;
			for(i	; i>=0; i--)
				if(!inw(str[i]))
					break;
			for(i	; i>=0; i--)
				if(inw(str[i]))
					break;
		}
		else
		{
			for(i=col; i>=0; i--)
				if(inw(str[i]))
					break;
		}
	}
	return(i+1);
}

void _strntog(char *str, int n)
{
	while(str && *str && n--)
	{
		if(__isupper(*str))
			*str=__tolower(*str);
		else
			*str=__toupper(*str);
		str++;
	}
}

void _strnupr(char *str, int n)
{
	while(str && *str && n--)
	{
		*str=__toupper(*str);
		str++;
	}
}

void _strnlwr(char *str, int n)
{
	while(str && *str && n--)
	{
		*str=__tolower(*str);
		str++;
	}
}

void _strncaps(char *str, int n)
{
	register int i;
	if(!str)
		return;
	if(*str)
		*str=__toupper(*str);
	i=find_next_letter(str,0);
	while(str[i] && i<n)
	{
		str[i]=__toupper(str[i]);
		i=find_next_letter(str,i);
	}
}

char *_findword(char *linebeg, char *pos, int *len)
{
	char *cp;

	if(isspace(*pos)) /* raus bei Blank */
		return(NULL);
		
	for(pos; !isspace(*pos) && pos>=linebeg; pos--)
		;
	pos++;
	cp=strchr(pos,' ');
	if(!cp) /* Zeilenende?, dann null suchen */
		cp=strchr(pos,0);
	if(cp)
	{
		*len=(int)((long)cp-(long)pos);
		return(pos);
	}
	else
		return(NULL);
}

void changeletters(WINDOW *wp, LINESTRUCT *beg, LINESTRUCT *end, int mode)
{
	int col,y1,y2,len;
	LINESTRUCT *line;
	GRECT rect;
	char *cp;

	if(wp)
	{
		if(!beg && !end)
		{									/* Wort suchen und als markieren Block */
			cp=_findword(wp->cstr->string, &wp->cstr->string[wp->col+wp->wfirst/wp->wscroll], &len);
			col=(int)((long)cp-(long)wp->cstr->string)-wp->wfirst/wp->wscroll;
			rect.g_x=wp->xwork+col*wp->wscroll;
			rect.g_y=wp->ywork+wp->row*wp->hscroll;
			rect.g_w=len*wp->wscroll;
			rect.g_h=wp->hscroll;
			switch(mode)
			{
				case EDITTOGL:
					_strntog(&wp->cstr->string[wp->col+wp->wfirst/wp->wscroll],1);
					rect.g_x=wp->xwork+wp->col*wp->wscroll;
					rect.g_w=wp->wscroll;
					break;
				case EDITBIG:
					_strnupr(cp,len);
					break;
				case EDITSMAL:
					_strnlwr(cp,len);
					break;
				case EDITCAPS:
					_strnlwr(cp,len);
					_strncaps(cp,len);
					break;
			}
			wp->w_state|=CHANGED;
			graf_mouse(M_OFF,0L);
			Wcursor(wp);
			Wredraw(wp,&rect);
			if(mode==EDITTOGL) /* gleich ein Zeichen weiterrÅcken */
			{
				wp->col++;
				wp->cspos++;
			}
			Wcuron(wp);
			Wcursor(wp);
/*
			graf_mouse(M_ON,0L);
*/
			return;
		}
		if(beg && end)
		{
			graf_mouse(BUSY_BEE,NULL);
			for(line=beg; line && line!=end->next; line=line->next)
			{
				if(line->begcol<line->used)
					switch(mode)
					{
						case EDITTOGL:
							_strntog(&line->string[line->begcol],line->endcol-line->begcol);
							break;
						case EDITBIG:
							_strnupr(&line->string[line->begcol],line->endcol-line->begcol);
							break;
						case EDITSMAL:
							_strnlwr(&line->string[line->begcol],line->endcol-line->begcol);
							break;
						case EDITCAPS:
							_strnlwr(&line->string[line->begcol],line->endcol-line->begcol);
							_strncaps(&line->string[line->begcol],line->endcol-line->begcol);
							break;
					}
			}
			wp->w_state|=CHANGED;
			for(line=wp->wstr,y1=wp->ywork;
				 line && y1<(wp->ywork+wp->hwork-1);
				 line=line->next, y1+=wp->hscroll)
				if(line->attr & SELECTED)
					break;
			for(y2=y1;
				 line && y2<(wp->ywork+wp->hwork-1);
				 line=line->next, y2+=wp->hscroll)
				if(!(line->attr&SELECTED))
					break;
			rect.g_x=wp->xwork;
			rect.g_y=y1;
			rect.g_w=wp->wwork;
			rect.g_h=y2-y1;
			graf_mouse(M_OFF,0L);
			Wcursor(wp);
			Wredraw(wp,&rect);
			Wcursor(wp);
/*
			graf_mouse(M_ON,0L);
*/
			graf_mouse(ARROW,NULL);
		}
	}
}

void gotobraceerror(WINDOW *wp, long line, int col, int diff, char Aerror[])
{
	sprintf(alertstr,Aerror,diff);
	form_alert(1,alertstr);
	hndl_goto(wp,NULL,line+1); /* Fehlerstelle */
	graf_mouse(M_OFF,0L); /* Cursor positionieren */
	Wcursor(wp);
	wp->cspos=wp->col=col-wp->wfirst/wp->wscroll;
	wp->cspos=Wshiftpage(wp,0,wp->cstr->used);
	Wcursor(wp);
	graf_mouse(M_ON,0L); /* Cursor positionieren */
}

int check_braces(OBJECT *tree, WINDOW *wp, LINESTRUCT *begcut, LINESTRUCT *endcut)
{
	int eckig=0, rund=0, geschweift=0, spitz=0, pkom=0, ckom=0;
	int i,ret,a,b,c,d,e,f,g,h,j,k,l,exit_obj,stop=FALSE;
	register LINESTRUCT *help;
	long line;
	char freebeg[11], freeend[11];

	char free1beg[11], free1end[11];
	char free2beg[11], free2end[11];
	char free3beg[11], free3end[11];
	char free4beg[11], free4end[11];
	char free5beg[11], free5end[11];
	
	if(wp)
	{
		a=tree[CBRACE].ob_state;
		b=tree[SBRACE].ob_state;
		c=tree[RBRACE].ob_state;
		d=tree[PBRACE].ob_state;
		e=tree[PKOMBRAC].ob_state;
		f=tree[CKOMBRAC].ob_state;
		g=tree[FREE1BRACE].ob_state;
		h=tree[FREE2BRACE].ob_state;
		j=tree[FREE3BRACE].ob_state;
		k=tree[FREE4BRACE].ob_state;
		l=tree[FREE5BRACE].ob_state;
		form_read(tree,FREE1BEG,free1beg);
		form_read(tree,FREE1END,free1end);
		form_read(tree,FREE2BEG,free2beg);
		form_read(tree,FREE2END,free2end);
		form_read(tree,FREE3BEG,free3beg);
		form_read(tree,FREE3END,free3end);
		form_read(tree,FREE4BEG,free4beg);
		form_read(tree,FREE4END,free4end);
		form_read(tree,FREE5BEG,free5beg);
		form_read(tree,FREE5END,free5end);
      
		form_exopen(tree,0);
		do
		{
			exit_obj=form_exdo(tree,0);
			if(exit_obj==BRACHELP)
			{
				form_alert(1,Afindrep[11]);
				objc_change(tree,exit_obj,0,tree->ob_x,tree->ob_y,tree->ob_width,tree->ob_height,tree[exit_obj].ob_state&~SELECTED,TRUE);
			}
		}
		while(exit_obj==BRACHELP);
		form_exclose(tree,exit_obj,0);

		if(exit_obj==BRACOK)
		{
#if OLDTOS
			graf_mouse(BUSY_BEE,NULL);
#endif
         line=(begcut && endcut)?begline:0L;
			for(help=begcut?begcut:wp->fstr; endcut?help!=endcut->next:help; help=help->next,line++)
			{
				for(i=0; i<help->used; i++)
				{
					switch(help->string[i])
					{
						case '(':
							rund++;
							if(help->string[i+1]=='*')
								pkom++; /* Pascal Kommentar */
							break;
						case ')':
							rund--;
							if(help->string[i-1]=='*')
								pkom--; /* Pascal Kommentar */
                     if(rund<0)
                        stop=TRUE;
							break;
						case '/':
							if(help->string[i+1]=='*')
								ckom++; /* C Kommentar */
							if(help->string[i-1]=='*')
								ckom--; /* C Kommentar */
                     if(ckom<0)
                        stop=TRUE;
							break;							
						case '{':
							geschweift++;
							break;
						case '}':
							geschweift--;
                     if(geschweift<0)
                        stop=TRUE;
							break;
						case '[':
							eckig++;
							break;
						case ']':
							eckig--;
                     if(eckig<0)
                        stop=TRUE;
							break;
						case '<':
							spitz++;
							break;
						case '>':
							spitz--;
                     if(spitz<0)
                        stop=TRUE;
							break;
					}
					if(stop)
					   break;
				}
				if(stop)
				   break;
			}
#if OLDTOS
			graf_mouse(ARROW,NULL);
#endif
			if((tree[CBRACE].ob_state & SELECTED) && geschweift)
			{
            gotobraceerror(wp, line, i, geschweift, Afindrep[12]);
			}
			if((tree[SBRACE].ob_state & SELECTED) && eckig)
			{
            gotobraceerror(wp, line, i, eckig, Afindrep[13]);
			}
			if((tree[RBRACE].ob_state & SELECTED) && rund)
			{
            gotobraceerror(wp, line, i, rund, Afindrep[14]);
			}
			if((tree[PBRACE].ob_state & SELECTED) && spitz)
			{
            gotobraceerror(wp, line, i, spitz, Afindrep[15]);
			}
			if((tree[PKOMBRAC].ob_state & SELECTED) && pkom)
			{
            gotobraceerror(wp, line, i, pkom, Afindrep[17]);
			}
			if((tree[CKOMBRAC].ob_state & SELECTED) && ckom)
			{
            gotobraceerror(wp, line, i, ckom, Afindrep[18]);
			}

	      for(i=FREE1BRACE; i<=FREE5BRACE; i+=3)
				if((tree[i].ob_state & SELECTED))
				{  /* freie Suchmuster */
	            form_read(tree,i+1,freebeg);
	            form_read(tree,i+2,freeend);
					Afindrep[19][12]=(char)((i-FREE1BRACE)/3+'1');
					Afindrep[20][12]=(char)((i-FREE1BRACE)/3+'1');
					ret=Wirth(wp,begcut,endcut,freebeg,freeend,&line,&a);
					if(ret>0)
					{
                  gotobraceerror(wp, line, a, ret, Afindrep[19]);
					}
					if(ret<0)
					{
                  gotobraceerror(wp, line, a, abs(ret), Afindrep[20]);
					}
				}
		}
		else
		{
			tree[CBRACE].ob_state=a;
			tree[SBRACE].ob_state=b;
			tree[RBRACE].ob_state=c;
			tree[PBRACE].ob_state=d;
  			tree[PKOMBRAC].ob_state=e;
			tree[CKOMBRAC].ob_state=f;
			tree[FREE1BRACE].ob_state=g;
			tree[FREE2BRACE].ob_state=h;
			tree[FREE3BRACE].ob_state=j;
			tree[FREE4BRACE].ob_state=k;
			tree[FREE5BRACE].ob_state=l;
			form_write(tree,FREE1BEG,free1beg,FALSE);
			form_write(tree,FREE1END,free1end,FALSE);
			form_write(tree,FREE2BEG,free2beg,FALSE);
			form_write(tree,FREE2END,free2end,FALSE);
			form_write(tree,FREE3BEG,free3beg,FALSE);
			form_write(tree,FREE3END,free3end,FALSE);
			form_write(tree,FREE4BEG,free4beg,FALSE);
			form_write(tree,FREE4END,free4end,FALSE);
			form_write(tree,FREE5BEG,free5beg,FALSE);
			form_write(tree,FREE5END,free5end,FALSE);
		}
	}
}
