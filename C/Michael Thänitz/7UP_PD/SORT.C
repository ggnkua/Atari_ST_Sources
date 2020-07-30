/* Heap Sort */
/*****************************************************************************
*
*											  7UP
*										Modul: SORT.C
*									 (c) by TheoSoft '91
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

typedef struct
{
	int menu,item;
} UNDO;

extern UNDO undo;

typedef struct
{
	char *str;
	int used,len;
	long line; /* beinhaltet die sortierte Reihenfolge, z.B. 3,4,0,2,1 */
	int effect;
}SORTSTRUCT;

static int col;

/*
 * Heap sorting functions
 */

static _nswap(register char *pa, register char *pb, register long n)
{
	register char c;

	while(n--) {
		c = *pa;
		*pa++ = *pb;
		*pb++ = c;
	}
}

static _nsift(register char *base, register long i, register long n,
				  register long size, register int (*cmp)())
{
	register long j;
	register char *p;

	while((j = ((i << 1) + 1)) < n) {
		p = (base+size*j);
		if((j < (n - 1)) && ((*cmp)(p, p+size) < 0)) {
			++j;
			p += size;
		}
		if((cmp)((base+size*i), p) < 0) {
			_nswap((base+size*i), p, size);
			i = j;
		}
		else
			break;
	}
}

hsort(register char *base, register long num,
	   register long size, register int (*cmp)())
/*
 * Perform an N*log(N) heap-sort on an array starting at <base>
 * containing <num> elements of <size> bytes each.  The function
 * pointed to by <cmp> is used to compare elements.  Pointers to
 * two items in the array are passed to the function, which must
 * return a number representing their relationship as follows:
 *	 negative item1 < item2
 *	 0	  item1 == item2
 *	 positive item1 > item2
 * The hsort() function requires no extra storage, is not recursive,
 * and has an almost constant N*log(N) sort time.  In the average
 * case, it is about half as fast as qsort() on random data.  If
 * portability is a concern, it should be noted that qsort() is
 * almost always available, but hsort() is not.
 */
{
	register long i, j;

	for(i = ((num >> 1) - 1); (i > 0); --i)
		_nsift(base, i, num, size, cmp);
	i = num;
	while(i > 1) {
		_nsift(base, 0, i--, size, cmp);
		_nswap(base, (base+size*i), size);
	}
}

static int upcmp(SORTSTRUCT *a, SORTSTRUCT *b) /* aufsteigend */
{
	return(strcmp(a->str,b->str));
}

static int dncmp(SORTSTRUCT *a, SORTSTRUCT *b) /* absteigend */
{
	register int ret;
	ret=strcmp(a->str,b->str);
	return(-ret);
}

static int cupcmp(SORTSTRUCT *a, SORTSTRUCT *b) /* aufsteigend mit Spaltenangabe */
{
	return(strcmp(&a->str[col],&b->str[col]));
}

static int cdncmp(SORTSTRUCT *a, SORTSTRUCT *b) /* absteigend mit Spaltenangabe */
{
	register int ret;
	ret=strcmp(&a->str[col],&b->str[col]);
	return(-ret);
}

char __toupper(char c);

static int __stricmp(char *s, char *t)
{
	for(;(__toupper(*s) == __toupper(*t)); s++, t++)
		if(*s == '\0')
			return(0);
	return(__toupper(*s) - __toupper(*t));
}

static int upicmp(SORTSTRUCT *a, SORTSTRUCT *b) /* aufsteigend */
{
	return(__stricmp(a->str,b->str));
}

static int dnicmp(SORTSTRUCT *a, SORTSTRUCT *b) /* absteigend */
{
	register int ret;
	ret=__stricmp(a->str,b->str);
	return(-ret);
}

static int cupicmp(SORTSTRUCT *a, SORTSTRUCT *b) /* aufsteigend mit Spaltenangabe */
{
	return(__stricmp(&a->str[col],&b->str[col]));
}

static int cdnicmp(SORTSTRUCT *a, SORTSTRUCT *b) /* absteigend mit Spaltenangabe */
{
	register int ret;
	ret=__stricmp(&a->str[col],&b->str[col]);
	return(-ret);
}

long Wline(void *, void *);

void hndl_sort(WINDOW *wp, OBJECT *tree, LINESTRUCT **begcut, LINESTRUCT **endcut)
{
	long lines, chars;
	LINESTRUCT *line;
	register int ignore,grpblks;
	register long i,k,x;
	int exit_obj,a,b,c,d,e,f,g;
	GRECT rect;
	SORTSTRUCT *ss; /* Zeile  */
	SORTSTRUCT *gs; /* Gruppe */
	
	static LINESTRUCT *grpbegcut=NULL, *grpendcut=NULL;
	static long grpbegline=0, grpendline=0, grplen=0, grpline=0;
	static int group=FALSE;
	
	extern long begline, endline;

	if(wp && *begcut && *endcut)
	{
		a=tree[SORTUP].ob_state;
		b=tree[SORTDN].ob_state;
		c=tree[SORTIGNO].ob_state;
		sprintf(tree[SORTFROM].ob_spec.tedinfo->te_ptext,"%-4ld",Wline(wp,*begcut)+1);
		sprintf(tree[SORTTO  ].ob_spec.tedinfo->te_ptext,"%-4ld",Wline(wp,*endcut)+1);
		sprintf(tree[SORTCOL ].ob_spec.tedinfo->te_ptext,"%-3d",wp->w_state&COLUMN?(*begcut)->begcol+1:1);

      if(grpbegcut && grpendcut) /* erst jetzt Kriterium freigeben */
			tree[SORTKRIT].ob_state &=~DISABLED;
         
		form_exopen(tree,0);
		do
		{
			exit_obj=form_exdo(tree,0);
			switch(exit_obj)
			{
				case SORTHELP:
					form_alert(1,Asort[1]);
					objc_change(tree,exit_obj,0,tree->ob_x,tree->ob_y,tree->ob_width,tree->ob_height,tree[exit_obj].ob_state&~SELECTED,TRUE);
					break;
				case SORTLINE:
					if(!group) /* rcksetzen, wenn noch m”glich */
					{
						tree[SORTKRIT].ob_state &= ~SELECTED;
						tree[SORTKRIT].ob_state |= DISABLED;
						objc_update(tree,SORTKRIT,0);
						tree[SORTEXTRA].ob_state &= ~SELECTED;
						tree[SORTEXTRA].ob_state |= DISABLED;
						objc_update(tree,SORTEXTRA,0);
					}
					break;
				case SORTGROUP:
/*
					tree[SORTKRIT].ob_state &=~DISABLED;
					objc_update(tree,SORTKRIT,0);
*/
					tree[SORTEXTRA].ob_state &=~DISABLED;
					tree[SORTEXTRA].ob_state |= SELECTED;
					objc_update(tree,SORTEXTRA,0);
					break;
			}
		}
		while(!(exit_obj==SORTABBR || exit_obj==SORTOK));
		form_exclose(tree,exit_obj,0);
		if(exit_obj==SORTABBR)
		{
			tree[SORTUP].ob_state=a;
			tree[SORTDN].ob_state=b;
			tree[SORTIGNO].ob_state=c;
			tree[SORTLINE].ob_state|=SELECTED;
			tree[SORTGROUP].ob_state&=~SELECTED;
			tree[SORTKRIT].ob_state &=~SELECTED;
			tree[SORTKRIT].ob_state |=DISABLED;
			tree[SORTEXTRA].ob_state &=~SELECTED;
			tree[SORTEXTRA].ob_state |=DISABLED;
			grpbegcut=NULL;
			grpendcut=NULL;
			grpbegline=0L;
			grpendline=0L;
			grplen=0;
			grpline=0;
			group=FALSE;
			return;
		}
		if(!group && (tree[SORTGROUP].ob_state & SELECTED) && !(tree[SORTKRIT].ob_state & SELECTED))
		{
			if(tree[SORTEXTRA].ob_state&SELECTED)
				form_alert(1,Asort[2]);
			grpbegcut=*begcut;
			grpendcut=*endcut;
			grpbegline=begline;
			grpendline=endline;
			return;
		}
		if(!group && (tree[SORTGROUP].ob_state & SELECTED) &&  (tree[SORTKRIT].ob_state & SELECTED))
		{
			if(tree[SORTEXTRA].ob_state&SELECTED)
				form_alert(1,Asort[3]);
			Wblksize(wp,*begcut,*endcut,&grplen,&chars);
			group=TRUE;
			return;
		}
		if(group && (tree[SORTKRIT].ob_state & SELECTED))
		{
			grpline=begline%grplen; /* Zeilenoffset zum Gruppenbeginn */
		}
		ignore=(tree[SORTIGNO].ob_state&SELECTED);
		col=(*begcut)->begcol;
		if(group)
		{
			Wblksize(wp,grpbegcut,grpendcut,&lines,&chars);
			if((lines%grplen) == 0) /* ganzzahliges Vielfaches? */
			{
				grpblks=lines/grplen; /* Anzahl der Bl”cke */
#if GEMDOS
				if((gs=Malloc(lines*sizeof(SORTSTRUCT)))!=NULL)
#else
				if((gs=malloc(lines*sizeof(SORTSTRUCT)))!=NULL)
#endif
				{
#if GEMDOS
					if((ss=Malloc(grpblks*sizeof(SORTSTRUCT)))!=NULL)
#else
					if((ss=malloc(grpblks*sizeof(SORTSTRUCT)))!=NULL)
#endif
					{
						for(k=0,i=0,line=grpbegcut; i<lines && line!=grpendcut->next; i++,line=line->next)
						{
							if(tree[SORTGROUP].ob_state & SELECTED) /* ganze Gruppe */
							{
								gs[i].str    = line->string; /* Gruppe sichern */
								gs[i].used   = line->used;
								gs[i].len    = line->len;
								gs[i].effect = line->effect; /* Texteffekt */
							}
							if(((i-grpline)%grplen)==0) /* jede Zeile aus der Gruppe muž ganzzahlig teilbar sein */
							{
								ss[k].str    = line->string;
								ss[k].used   = line->used;
								ss[k].len    = line->len;
								ss[k].effect = line->effect;
								ss[k].line   = k;
								k++;
							}
						}

						/* immer Spaltenblocksortierung */
						if(tree[SORTDN].ob_state & SELECTED) /* absteigend */
							hsort(ss,grpblks,sizeof(SORTSTRUCT),ignore?cdncmp:cdnicmp);
						else											/* aufsteigend */
							hsort(ss,grpblks,sizeof(SORTSTRUCT),ignore?cupcmp:cupicmp);

						if(tree[SORTGROUP].ob_state & SELECTED) /* ganze Gruppe */
						{
							for(k=0,i=0,line=grpbegcut; i<lines && k<grpblks && line!=grpendcut->next; k++,i++)
							{
								for(x=0; x<grplen && line; x++,line=line->next)
								{
									line->string=gs[ss[k].line*grplen+x].str;
									line->used  =gs[ss[k].line*grplen+x].used;
									line->len	=gs[ss[k].line*grplen+x].len;
									line->effect=gs[ss[k].line*grplen+x].effect;
								}
							}
						}
						else /* nur Gruppenkriterium */
						{
							for(k=0,i=0,line=grpbegcut; i<lines && line!=grpendcut->next; i++,line=line->next)
							{
								if(((i-grpline)%grplen)==0) /* jede Zeile aus der Gruppe muž ganzzahlig teilbar sein */
								{
									line->string=ss[k].str;
									line->used  =ss[k].used;
									line->len	=ss[k].len;
									line->effect=ss[k].effect;
									k++;
								}
							}
						}
#if GEMDOS
						Mfree(ss);
#else
						free(ss);
#endif
						rect.g_x=wp->xwork;
						rect.g_y=wp->ywork+grpbegline*wp->hscroll-wp->hfirst;
						rect.g_w=wp->wwork;
						rect.g_h=(grpendline-grpbegline+1)*wp->hscroll;
						graf_mouse(M_OFF,0L);
						Wcursor(wp);
						Wredraw(wp,&rect);
						Wcursor(wp);
						graf_mouse(M_ON,0L);
						hide_blk(wp,*begcut, *endcut);
						undo.item=FALSE;
						wp->w_state|=CHANGED;
						Wcuron(wp);
						graf_mouse(ARROW,NULL);
					}
					else
						form_alert(1,Asort[0]);
#if GEMDOS
					Mfree(gs);
#else
					free(gs);
#endif
				}
				else
					form_alert(1,Asort[0]);
			}
			else
				form_alert(1,Asort[4]);
			tree[SORTLINE].ob_state|=SELECTED;
			tree[SORTGROUP].ob_state&=~SELECTED;
			tree[SORTKRIT].ob_state &=~SELECTED;
			tree[SORTKRIT].ob_state |=DISABLED;
			tree[SORTEXTRA].ob_state &=~SELECTED;
			tree[SORTEXTRA].ob_state |=DISABLED;
			grpbegcut=NULL;
			grpendcut=NULL;
			grpbegline=0L;
			grpendline=0L;
			grplen=0;
			grpline=0;
			group=FALSE;
		}
		else
		{
			Wblksize(wp,*begcut,*endcut,&lines,&chars);
#if GEMDOS
			if((ss=Malloc(lines*sizeof(SORTSTRUCT)))!=NULL)
#else
			if((ss=malloc(lines*sizeof(SORTSTRUCT)))!=NULL)
#endif
			{
				graf_mouse(BUSY_BEE,NULL);
				for(i=0,line=(*begcut); i<lines && line!=(*endcut)->next; i++,line=line->next)
				{
					ss[i].str =line->string;
					ss[i].used=line->used;
					ss[i].len =line->len;
					ss[i].effect =line->effect;
				}
				if(tree[SORTDN].ob_state & SELECTED) /* absteigend */
				{
					if(wp->w_state&COLUMN)
						hsort(ss,lines,sizeof(SORTSTRUCT),ignore?cdncmp:cdnicmp);
					else
						hsort(ss,lines,sizeof(SORTSTRUCT),ignore?dncmp:dnicmp);
				}
				else											/* aufsteigend */
				{
					if(wp->w_state&COLUMN)
						hsort(ss,lines,sizeof(SORTSTRUCT),ignore?cupcmp:cupicmp);
					else
						hsort(ss,lines,sizeof(SORTSTRUCT),ignore?upcmp:upicmp);
				}
				for(i=0,line=(*begcut); i<lines && line!=(*endcut)->next; i++,line=line->next)
				{
					line->string=ss[i].str;
					line->used  =ss[i].used;
					line->len	=ss[i].len;
					line->effect=ss[i].effect;
				}
#if GEMDOS
				Mfree(ss);
#else
				free(ss);
#endif
				rect.g_x=wp->xwork;
				rect.g_y=wp->ywork+begline*wp->hscroll-wp->hfirst;
				rect.g_w=wp->wwork;
				rect.g_h=(endline-begline+1)*wp->hscroll;
				graf_mouse(M_OFF,0L);
				Wcursor(wp);
				Wredraw(wp,&rect);
				Wcursor(wp);
				graf_mouse(M_ON,0L);
				hide_blk(wp,*begcut, *endcut);
				undo.item=FALSE;
				wp->w_state|=CHANGED;
				Wcuron(wp);
				graf_mouse(ARROW,NULL);
			}
			else
				form_alert(1,Asort[0]);
			tree[SORTLINE].ob_state|=SELECTED;
			tree[SORTGROUP].ob_state&=~SELECTED;
			tree[SORTKRIT].ob_state &=~SELECTED;
			tree[SORTKRIT].ob_state |=DISABLED;
			tree[SORTEXTRA].ob_state &=~SELECTED;
			tree[SORTEXTRA].ob_state |=DISABLED;
			grpbegcut=NULL;
			grpendcut=NULL;
			grpbegline=0L;
			grpendline=0L;
			grplen=0;
			grpline=0;
			group=FALSE;
		}
	}
}
