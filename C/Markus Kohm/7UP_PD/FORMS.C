/* Dialog Bibliothek */
/*****************************************************************************
*
*											  7UP
*										 Modul: FORMS.C
*									 (c) by TheoSoft '90
*
*****************************************************************************/
#include <portab.h>
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>
#if GEMDOS
#include <tos.h>
#else
#include <alloc.h>
#endif
#include <aes.h>
#include <vdi.h>

#include "7up.h"
#include "forms.h"
#include "windows.h"

#include "language.h"

#define Objc_edit(a,b,c,d,e,f) objc_edit(a,b,c,f,e)

#define FLAGS11 0x0800
#define FLAGS12 0x1000
#define FLAGS13 0x2000
#define FLAGS14 0x4000
#define FLAGS15 0x8000

#define SCROLLFIELD FLAGS11
#define UPARROW	  FLAGS12
#define DNARROW	  FLAGS13
#define SCROLLBOX	FLAGS14

#if GEMDOS
#define FMD_FORWARD  1
#define FMD_BACKWARD 2
#define FMD_DEFLT	 0
#else
#define ED_START		  0 /* editable text field definitions */
#define ED_INIT			1
#define ED_CHAR			2
#define ED_END			 3
#endif

#define AV_SENDKEY 0x4710

#define BACKDROP			0x2000  /* Fensterelement */
#define WM_BACKDROPPED	31		/* Message vom Eventhandler */
#define WF_BACKDROP		100	  /* Fenster setzen */

#define CR	 0x1C0D
#define ENTER 0x720D
#define TAB	0x0F09
#define UPARR 0x4800
#define DNARR 0x5000
#define F1	 0x3B00
#define F12	0x4600
#define UNDO  0x6100
#define HELP  0x6200

static FDB ps[MAX_DEPTH], /* Source = Screen */
			  pd[MAX_DEPTH], /* Dest.  = Buffer */
			  pb[MAX_DEPTH]; /* Box	 = Dialogbox */

int windials=FALSE;

static int FDBcount=-1;
int dial_handle=-1;

#define M_ENDLESS 0x0001
#define M_VALID	0x0002
#define M_REC	  0x0004
#define M_PLAY	 0x0008

extern OBJECT *divmenu,*winmenu;
extern int aeshandle,vdihandle,userhandle,xdesk,ydesk,wdesk,hdesk,windials,boxw,boxh;

int draw_rbutton();
int draw_checkbox();
int draw_alt();

#if GEMDOS
/* ------------------------------------------------------------------------- */
/* ----- VSCR von BIGSCREEN 2 ---------------------------------------------- */
/* ------------------------------------------------------------------------- */

typedef struct
{
	LONG cookie;	/* muž `VSCR' sein */
	LONG product;  /* Analog zur XBRA-Kennung */
	WORD version;  /* Version des VSCR-Protokolls, zun„chst 0x100 */
	WORD x,y,w,h;  /* Sichtbarer Ausschnitt des Bildschirms */
} INFOVSCR;


/* ------------------------------------------------------------------------- */
/* ----- di_fly.c ----- Flying Dials using Let em Fly! --------------------- */
/* ------------------------------------------------------------------------- */

#include "di_fly.h"

/* ------------------------------------------------------------------------- */

static LTMFLY	*letemfly = NULL;

/* ----- Cookie Jar -------------------------------------------------------- */

#endif

/*------------------------------------------------------------------------*/
/*																								*/
/*------------------------------------------------------------------------*/
void fwind_redraw(OBJECT *tree, int wh, int pxyarray[])
{
	int full[4],area[4],array[4],ret;

	wind_update(BEG_UPDATE);
	_wind_get( 0, WF_WORKXYWH,  &full[0], &full[1], &full[2], &full[3]);
	_wind_get(wh, WF_FIRSTXYWH, &area[0], &area[1], &area[2], &area[3]);
	while( area[2] && area[3] )
	{
		if(rc_intersect(full,area))
		{
			if(rc_intersect(pxyarray,area))
			{
				objc_draw(tree,ROOT,MAX_DEPTH,area[0],area[1],area[2],area[3]);
			}
		}
		_wind_get(wh, WF_NEXTXYWH,&area[0],&area[1],&area[2],&area[3]);
	}
	wind_update(END_UPDATE);
}

void fwind_move(OBJECT *tree, int wh, int buf[])
{
	int xwork,ywork,wwork,hwork;

	wind_set(wh,WF_CURRXYWH,buf[0],buf[1],buf[2],buf[3]);
	_wind_get(wh,WF_WORKXYWH,&xwork,&ywork,&wwork,&hwork);
	tree->ob_x=xwork;
	tree->ob_y=ywork;
}

static int is_obj_char(char *str)
{
	char *cp;
	if((cp=strchr(str,'_'))!=0L)
		return(__tolower(*(cp+1L)));
	return(0);
}

static int find_altbutton(OBJECT *tree, int fm_key)
{
	register int i;
	for(i=ROOT+2; !(tree[i].ob_flags & LASTOB); i++)
	{
		if(tree[i].ob_type == G_USERDEF &&
			!(tree[i].ob_flags&HIDETREE) &&
			!(tree[i].ob_state&DISABLED) &&
			!(tree[i].ob_flags&FLAGS15)) /* wg. Zeichensatztabelle */
		{
			if(fm_key ==
is_obj_char((char *)((TEDINFO *)tree[i].ob_spec.userblk->ub_parm)->te_ptext))
				return(i);
		}
	}
	if(tree[i].ob_type == G_USERDEF &&
		!(tree[i].ob_flags&HIDETREE) &&
		!(tree[i].ob_state&DISABLED) &&
		!(tree[i].ob_flags&FLAGS15)) /* wg. Zeichensatztabelle */
	{
			if(fm_key ==
is_obj_char((char *)((TEDINFO *)tree[i].ob_spec.userblk->ub_parm)->te_ptext))
				return(i);
	}
	return(-1);
}

char *stristr(char *, char *);

static int find_button(OBJECT *tree, char *string)
{
	register int i;
	for(i=ROOT+2; !(tree[i].ob_flags & LASTOB); i++)
	{
		if(!(tree[i].ob_flags&HIDETREE) && !(tree[i].ob_state&DISABLED))
		{
			if((tree[i].ob_type == G_USERDEF) && !(tree[i].ob_flags & FLAGS15))
			{
				if(stristr((char *)((TEDINFO *)tree[i].ob_spec.userblk->ub_parm)->te_ptext,string))
					return(i);
			}
			else
			{
				if(tree[i].ob_type == G_BOXTEXT)
					if(stristr(tree[i].ob_spec.tedinfo->te_ptext,string))
						return(i);
			}
		}
	}
	if(!(tree[i].ob_flags&HIDETREE) && !(tree[i].ob_state&DISABLED))
	{
		if((tree[i].ob_type == G_USERDEF) && !(tree[i].ob_flags&FLAGS15))
		{
			if(stristr((char *)((TEDINFO *)tree[i].ob_spec.userblk->ub_parm)->te_ptext,string))
				return(i);
		}
		else
		{
  			if(tree[i].ob_type == G_BOXTEXT)
				if(stristr(tree[i].ob_spec.tedinfo->te_ptext,string))
					return(i);
		}
	}
	return(-1);
}

static int find_fflag(OBJECT *tree, int start, int flag) /* first_flag */
{
	register int i;
	for(i=start; !(tree[i].ob_flags & LASTOB); i++)
	{
		if(tree[i].ob_flags & flag)
			return(i);
	}
	if(tree[i].ob_flags & flag)
		return(i);
	return(-1);
}

static int count_flag(OBJECT *tree, int start, int flag) /* first_flag */
{
	register int i,count=0;
	for(i=start; !(tree[i].ob_flags & LASTOB); i++)
	{
		if(tree[i].ob_flags & flag)
			count++;
	}
	if(tree[i].ob_flags & flag)
		count++;
	return(count);
}

static int find_lflag(OBJECT *tree, int start, int flag) /* last_flag */
{
	register int i,k;
	for(i=start; !(tree[i].ob_flags & LASTOB); i++)
	{
		if(tree[i].ob_flags & flag)
		{
			for(k=i; !(tree[k].ob_flags & LASTOB); k++)
			{
				if(!(tree[k].ob_flags & flag))
					return(k-1);
			}
			return(i);
		}
	}
	return(-1);
}

static int find_bflag(OBJECT *tree, int start, int flag) /* rckw„rts */
{
	register int i;
	for(i=start; i>=ROOT+2; i--)
	{
		if(tree[i].ob_flags & flag)
			return(i);
	}
	return(-1);
}

static int form_click(OBJECT *tree, int next_obj, int e_br, int *next_obj2)
{
	int fm_cont=TRUE;
	switch(next_obj)
	{
		case ROOT:
			break;
		case (-1):
#if GEMDOS
			Bconout(2,7);
#else
			v_sound(aeshandle, 440, 2);
#endif
			*next_obj2=0;
			break;
		default:
			fm_cont=form_button(tree,next_obj,e_br,next_obj2);
			break;
	}
	return(fm_cont);
}

static WORD find_obj(OBJECT *tree, WORD fm_start_obj, WORD fm_which)
{
	WORD fm_obj,fm_flag,fm_theflag,fm_inc;
	fm_obj=0;
	fm_flag=EDITABLE;
	fm_inc=1;
	switch(fm_which)
	{
		case FMD_BACKWARD: fm_inc=-1;
		case FMD_FORWARD:  fm_obj=fm_start_obj+fm_inc;break;
		case FMD_DEFLT:	 fm_flag=2;
			break;
	}
	while(fm_obj>=0)
	{
		fm_theflag=tree[fm_obj].ob_flags;
		if(fm_theflag&fm_flag)
			return(fm_obj);
		if(fm_theflag&LASTOB)
			fm_obj=-1;
		else
			fm_obj+=fm_inc;
	}
	return(fm_start_obj);
}

/*------------------------------------------------------------------------*/
/*																								*/
/*------------------------------------------------------------------------*/
static WORD fm_inifld(OBJECT *tree, WORD fm_start_fld)
{
	if(fm_start_fld==0)
		fm_start_fld=find_obj(tree,0,FMD_FORWARD);
	return(fm_start_fld);
}

static int _form_exdo(OBJECT *tree, WORD fm_start_fld)
{
	WORD obj,fm_edit_obj,fm_next_obj,fm_which,fm_cont,fm_idx,fm_kr2;
	WORD oldstate,i,txtcrsr=FALSE,x,y,diff,selected=FALSE;
	char ch;

	static int msgbuf[8];
	static MEVENT mevent=
	{
		MU_KEYBD|MU_BUTTON|MU_MESAG|MU_M1|MU_TIMER,
		2,1,1,
		1,0,0,1,1,
		0,0,0,0,0,
		msgbuf,
		0L,					/* bei Makro: 16L, */
		0,0,0,0,0,0,
	/* nur der Vollst„ndigkeit halber die Variablen von XGEM */
		0,0,0,0,0,
		0,
		0L,
		0L,0L
	};

#if GEMDOS
	KEYTAB *pkeytbl;
	char *kbdu, *kbds, *kbdc, chr;

	pkeytbl=Keytbl(-1L,-1L,-1L);
	kbdu=pkeytbl->unshift;
	kbds=pkeytbl->shift;
	kbdc=pkeytbl->capslock;
#else
	extern unsigned char b_keycod[];
	int scan;
#endif

	mevent.e_flags=MU_KEYBD|MU_BUTTON|MU_M1|MU_TIMER;
	if(windials && !(tree->ob_flags & FLAGS15))
		mevent.e_flags|=MU_MESAG;
	
	fm_next_obj=fm_inifld(tree,fm_start_fld);
	fm_edit_obj=0;
	fm_cont=TRUE;

	while(fm_cont)
	{
		if((fm_next_obj!=0)&&(fm_edit_obj!=fm_next_obj))
		{
			fm_edit_obj=fm_next_obj;
			fm_next_obj=0;
			Objc_edit(tree,fm_edit_obj,0,fm_idx,ED_INIT,&fm_idx);
		}
		mevent.e_m1.g_x=mevent.e_mx;
		mevent.e_m1.g_y=mevent.e_my;

		fm_which=evnt_event(&mevent);
/*
		wind_update(BEG_UPDATE);
*/
		if(fm_which & MU_MESAG)
		{
			if((msgbuf[0] != MN_SELECTED) && (msgbuf[0] < 50)) /* AP_TERM */
			{
				if(msgbuf[3]==dial_handle) /* Dialogfenster */
				{
					switch(msgbuf[0])
					{
						case WM_BACKDROPPED: /* nein, niemals */
							break;
						case WM_REDRAW:
							Objc_edit(tree,fm_edit_obj,0,fm_idx,ED_END,&fm_idx);
							fwind_redraw(tree,msgbuf[3],&msgbuf[4]);
							Objc_edit(tree,fm_edit_obj,0,fm_idx,ED_INIT,&fm_idx);
							break;
						case WM_MOVED:
							Objc_edit(tree,fm_edit_obj,0,fm_idx,ED_END,&fm_idx);
							fwind_move(tree,msgbuf[3],&msgbuf[4]);
							Objc_edit(tree,fm_edit_obj,0,fm_idx,ED_INIT,&fm_idx);
							break;
						case WM_TOPPED:
							wind_set(msgbuf[3],WF_TOP,0,0,0,0);
							break;
					}
				}
				else /* aber kein Schliežen oder Toppen */
					if(msgbuf[0]!=WM_CLOSED && msgbuf[0]!=WM_TOPPED)
					{
						Wwindmsg(Wp(msgbuf[3]),msgbuf);
					}
			}
		}
		if(fm_which & MU_KEYBD)
		{
			if(find_fflag(tree,ROOT+2,EDITABLE)>0)
				altnum(&mevent.e_ks,&mevent.e_kr);
			if(mevent.e_ks == K_ALT)
			{
#if GEMDOS
				fm_kr2= *(kbdu+(mevent.e_kr>>8 & 0xff));
#else
				scan=(mevent.e_kr>>8 & 0xff);
				for(i='a'; i<='z'; i++)
					if(scan==b_keycod[i-'a'])
					{
						fm_kr2=(char)(i);
						break;
					}
				/* ALT-Y und ALT-Z tauschen				 */
				if(mevent.e_ks & K_ALT && scan==44 && fm_kr2==121)
					fm_kr2=122;
				if(mevent.e_ks & K_ALT && scan==21 && fm_kr2==122)
					fm_kr2=121;
				if(scan>=120 && scan<=129)
					fm_kr2=scan-120+1+'0';
#endif
				fm_next_obj=find_altbutton(tree,__tolower(fm_kr2));
				switch(fm_next_obj)
				{
					case ROOT:
						break;
					case (-1):
						fm_next_obj=0;
						fm_cont=form_keybd(tree, fm_edit_obj, fm_next_obj, mevent.e_kr, &fm_next_obj, &mevent.e_kr);
						if(mevent.e_kr)
							Objc_edit(tree,fm_edit_obj,mevent.e_kr,fm_idx,ED_CHAR,&fm_idx);
						break;
					default:
						fm_cont=form_button(tree,fm_next_obj,mevent.e_br,&fm_next_obj);
						break;
				}
			}
			else
			{
				switch(mevent.e_kr)
				{
					case 0x4700: /* home */
						if(count_flag(tree,ROOT+2,EDITABLE)>1)
							goto WEITER3; /* kein Scrollen m”glich, weil EDITABLE */
						if((fm_next_obj=find_fflag(tree,ROOT+2,FLAGS11))>-1)
						{
							fm_cont=form_click(tree,fm_next_obj,1,&fm_next_obj);
							fm_next_obj=find_fflag(tree,ROOT+2,FLAGS12);
							fm_cont=form_click(tree,fm_next_obj,2,&fm_next_obj);
						}
						break;
					case 0x4737: /* clr */
						if(count_flag(tree,ROOT+2,EDITABLE)>1)
							goto WEITER3; /* kein Scrollen m”glich, weil EDITABLE */
						if((fm_next_obj=find_lflag(tree,ROOT+2,FLAGS11))>-1)
						{
							fm_cont=form_click(tree,fm_next_obj,1,&fm_next_obj);
							fm_next_obj=find_fflag(tree,ROOT+2,FLAGS13);
							fm_cont=form_click(tree,fm_next_obj,2,&fm_next_obj);
						}
						break;					
					case 0x4838: /* shift up */
						if(count_flag(tree,ROOT+2,EDITABLE)>1)
							goto WEITER3; /* kein Scrollen m”glich, weil EDITABLE */
						if((fm_next_obj=find_fflag(tree,ROOT+2,FLAGS11))>-1)
						{
							if(!(tree[fm_next_obj].ob_state & SELECTED))
								fm_cont=form_click(tree,fm_next_obj,1,&fm_next_obj);
							else
							{
								fm_next_obj=find_fflag(tree,ROOT+2,FLAGS12);
								fm_cont=form_click(tree,fm_next_obj,1,&fm_next_obj);
							}
						}
						break;
					case 0x4800: /* up */
						if(count_flag(tree,ROOT+2,EDITABLE)>1)
							goto WEITER3;
						if((fm_next_obj=find_fflag(tree,ROOT+2,FLAGS11))>-1)
						{
							for(i=fm_next_obj; !(tree[i].ob_flags & LASTOB); i++)
								if((tree[i].ob_flags & FLAGS11) && (tree[i].ob_state & SELECTED))
								{
									selected=TRUE;
									if(tree[i-1].ob_flags & FLAGS11)
									{
										fm_next_obj=--i;
										break;
									}
								}
							if(!selected)
								fm_next_obj=find_lflag(tree,ROOT+2,FLAGS11);
							else
								if(i!=fm_next_obj)
									fm_next_obj=find_fflag(tree,ROOT+2,FLAGS12);
						}
						fm_cont=form_click(tree,fm_next_obj,1,&fm_next_obj);
						break;
					case 0x5032: /* shift dn */
						if(count_flag(tree,ROOT+2,EDITABLE)>1)
							goto WEITER3; /* kein Scrollen m”glich, weil EDITABLE */
						if((fm_next_obj=find_lflag(tree,ROOT+2,FLAGS11))>-1)
						{
							if(!(tree[fm_next_obj].ob_state & SELECTED))
								fm_cont=form_click(tree,fm_next_obj,1,&fm_next_obj);
							else
							{
								fm_next_obj=find_fflag(tree,ROOT+2,FLAGS13);
								fm_cont=form_click(tree,fm_next_obj,1,&fm_next_obj);
							}
						}
						break;
					case 0x5000: /* dn */
						if(count_flag(tree,ROOT+2,EDITABLE)>1)
							goto WEITER3; /* kein Scrollen m”glich, weil EDITABLE */
						if((fm_next_obj=find_fflag(tree,ROOT+2,FLAGS11))>-1) /* gibt es eine Scrolliste? */
						{  /* erstes selektiertes Objekt suchen */
							for(i=fm_next_obj; !(tree[i].ob_flags & LASTOB); i++)
								if((tree[i].ob_flags & FLAGS11) && (tree[i].ob_state & SELECTED))
								{
									selected=TRUE; /* hier ist es! */
									if(tree[i+1].ob_flags & FLAGS11)
									{  /* ist das n„chste Objekt auch scrollbar? */
										fm_next_obj=++i; /* nur Cursor weitersetzen */
										break;
									}
								}
							if(!selected) /* Es wurde kein selektiertes Objekt gefunden */
								fm_next_obj=find_fflag(tree,ROOT+2,FLAGS11); /* erstes Objekt selektieren */
							else
								if(i!=fm_next_obj) /* es gibt ein sel. Objekt, es ist aber das letzte */
									fm_next_obj=find_fflag(tree,ROOT+2,FLAGS13); /* also Pfeil klicken */
						}
						fm_cont=form_click(tree,fm_next_obj,1,&fm_next_obj);
						break;
					case 0x4B00: /* lf */
					case 0x4B34: /* lf */
					case 0x4D00: /* rt */
					case 0x4D36: /* rt */
						if(count_flag(tree,ROOT+2,EDITABLE)>0)
							goto WEITER3;
						fm_next_obj=-1;
						fm_cont=form_click(tree,fm_next_obj,1,&fm_next_obj);
						break;
#if GEMDOS
					case HELP:
#else
					case F1:
#endif
						fm_next_obj=find_button(tree,KHILFE);
						fm_cont=form_click(tree,fm_next_obj,mevent.e_br,&fm_next_obj);
						break;
					case UNDO:
						if((fm_next_obj=find_button(tree,KABBRUCH))==-1)
							 fm_next_obj=find_button(tree,KNEIN);
						fm_cont=form_click(tree,fm_next_obj,mevent.e_br,&fm_next_obj);
						break;
					default:
WEITER3:
						if(
#if GEMDOS
							 !letemfly &&
#endif
							 mevent.e_kr==TAB && (mevent.e_ks & (K_RSHIFT|K_LSHIFT)) )
						{
							mevent.e_kr =UPARR;
						}
						fm_cont=form_keybd(tree, fm_edit_obj, fm_next_obj, mevent.e_kr, &fm_next_obj, &mevent.e_kr);
						if(mevent.e_kr)
						{
							Objc_edit(tree,fm_edit_obj,mevent.e_kr,fm_idx,ED_CHAR,&fm_idx);
						}
/* berflssig mit neuer Lib
						/* gegen Fehler GEMBIND, wg. KAOS 1.41 */
						if(!fm_cont && !fm_next_obj)
						{
							fm_next_obj=find_fflag(tree,ROOT+2,DEFAULT);
							if(fm_next_obj==-1)
								fm_cont=TRUE;
						}
*/
						break;
				}
			}
/* muž raus wg. Makrorecorder
			while(evnt_event(&mevent) == MU_KEYBD) /* Puffer l”schen */
				;
*/
		}
		if(fm_which & MU_BUTTON)
		{
			fm_next_obj=objc_find(tree,ROOT,MAX_DEPTH,mevent.e_mx,mevent.e_my);
			switch(fm_next_obj)
			{
				case ROOT:
					break;
				case (-1):
#if GEMDOS
					Bconout(2,7);
#else
					v_sound(aeshandle, 440, 2);
#endif
					fm_next_obj=0;
					break;
				default:
					fm_cont=form_button(tree,fm_next_obj,mevent.e_br,&fm_next_obj);
					if(!(fm_next_obj&FLAGS15) && (tree[fm_next_obj].ob_flags & EDITABLE))
					{
						diff=(tree[fm_next_obj].ob_spec.tedinfo->te_txtlen -
								tree[fm_next_obj].ob_spec.tedinfo->te_tmplen);
						objc_offset(tree,fm_next_obj,&x,&y);
						mevent.e_mx+=(diff*8);
						y=(mevent.e_mx-x)/8;
						if((mevent.e_mx-x)%8 >= 4)
							y++;
						if(y<0)
							y=0;
						if(y>strlen(tree[fm_next_obj].ob_spec.tedinfo->te_ptext))
							y=strlen(tree[fm_next_obj].ob_spec.tedinfo->te_ptext);

						Objc_edit(tree,fm_edit_obj,0,fm_idx,ED_END,&fm_idx);

						ch=tree[fm_next_obj].ob_spec.tedinfo->te_ptext[y];
						tree[fm_next_obj].ob_spec.tedinfo->te_ptext[y]=0;
						Objc_edit(tree,fm_next_obj,0,fm_idx,ED_INIT,&fm_idx);
						tree[fm_next_obj].ob_spec.tedinfo->te_ptext[y]=ch;
						fm_edit_obj = fm_next_obj;
					}
					break;
			}
WEITER1: ;
		}
		if(fm_which & MU_M1) /* evtl. Textcursor einstellen */
		{
			if(dial_handle>0)
			{
				if(wind_find(mevent.e_mx,mevent.e_my)!=dial_handle)
				{
					if(txtcrsr)
					{
						graf_mouse(ARROW,NULL);
						txtcrsr=FALSE;
					}
					goto WEITER2;
				}
			}	
			obj=objc_find(tree,ROOT,MAX_DEPTH,mevent.e_mx,mevent.e_my);
			switch(obj)
			{
				case ROOT:
				case (-1):
					if(txtcrsr)
					{
						graf_mouse(ARROW,NULL);
						txtcrsr=FALSE;
					}
					break;
				default:
					if(!txtcrsr &&  (tree[obj].ob_flags & EDITABLE)  /* editierbar */
									&& !(tree[obj].ob_state & DISABLED)  /* ! */
									&& !(tree[obj].ob_flags & HIDETREE)) /* ! */
					{
						graf_mouse(TEXT_CRSR,NULL);
						txtcrsr=TRUE;
					}
					if( txtcrsr && !(tree[obj].ob_flags & EDITABLE))
					{
						graf_mouse(ARROW,NULL);
						txtcrsr=FALSE;
					}
					break;
			}
WEITER2: ;
		}
		if((!fm_cont) || ((fm_next_obj != 0) && (fm_next_obj != fm_edit_obj)))
		{
			Objc_edit(tree,fm_edit_obj,mevent.e_kr,fm_idx,ED_END,&fm_idx);
		}
/*
		wind_update(END_UPDATE);
*/
	}
	graf_mouse(ARROW,NULL);
	return(fm_next_obj);
}

void form_open(OBJECT *tree,int modus)
{
#if MiNT
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
#endif
	form_dial(FMD_START,0,0,0,0,tree->ob_x-3,tree->ob_y-3,
										 tree->ob_width+6,tree->ob_height+6);
	if(modus)
		form_dial(FMD_GROW,0,0,0,0,tree->ob_x-3,tree->ob_y-3,
										 tree->ob_width+6,tree->ob_height+6);
	objc_draw(tree,ROOT,MAX_DEPTH,tree->ob_x-3,tree->ob_y-3,
											tree->ob_width+6,tree->ob_height+6);
}

int form_close(OBJECT *tree, int exit_obj,int modus)
{
	if(modus)
		form_dial(FMD_SHRINK,0,0,0,0,tree->ob_x-3,tree->ob_y-3,
										 tree->ob_width+6,tree->ob_height+6);
	form_dial(FMD_FINISH,0,0,0,0,tree->ob_x-3,tree->ob_y-3,
										 tree->ob_width+6,tree->ob_height+6);
	if(exit_obj > -1 /*&& exit_obj < 256*/)
		tree[exit_obj].ob_state &= ~SELECTED;
#if MiNT
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
#endif
	return(exit_obj);
}

static int _form_exopen(OBJECT *tree, int modus)
{
	long boxsize;
	int pxyarray[8];

	extern int work_out[];

	if(FDBcount==MAX_DEPTH)
		return(FALSE);

	vq_extnd(vdihandle,1,work_out);

	ps[FDBcount].fd_addr = pd[FDBcount].fd_addr = pb[FDBcount].fd_addr = NULL;
	pd[FDBcount].fd_w = pb[FDBcount].fd_w = tree->ob_width+6;
	pd[FDBcount].fd_h = pb[FDBcount].fd_h = tree->ob_height+6;
	pd[FDBcount].fd_wdwidth = pb[FDBcount].fd_wdwidth =
		pd[FDBcount].fd_w/16+ (pd[FDBcount].fd_w % 16 != 0);
	pd[FDBcount].fd_stand = pb[FDBcount].fd_stand = 0;
	pd[FDBcount].fd_nplanes = pb[FDBcount].fd_nplanes = work_out[4];
	pd[FDBcount].fd_r1 = pd[FDBcount].fd_r2 = pd[FDBcount].fd_r3 = 0;
	pb[FDBcount].fd_r1 = pb[FDBcount].fd_r2 = pb[FDBcount].fd_r3 = 0;

	boxsize=(long)pd[FDBcount].fd_wdwidth*2L*(long)pd[FDBcount].fd_h*(long)pd[FDBcount].fd_nplanes;
#if GEMDOS
	if((pd[FDBcount].fd_addr=Malloc(boxsize))==NULL) /* Speicher fr Bildschirm besorgen */
		return(FALSE);
	if((pb[FDBcount].fd_addr=Malloc(boxsize))==NULL) /* Speicher fr Bildschirm besorgen */
	{
		Mfree(pd[FDBcount].fd_addr);
		pd[FDBcount].fd_addr=NULL;
		return(FALSE);
	}
#else
	if((pd[FDBcount].fd_addr=farmalloc(boxsize))==NULL) /* Speicher fr Bildschirm besorgen */
		return(FALSE);
	if((pb[FDBcount].fd_addr=farmalloc(boxsize))==NULL) /* Speicher fr Bildschirm besorgen */
	{
		farfree(pd[FDBcount].fd_addr);
		pd[FDBcount].fd_addr=NULL;
		return(FALSE);
	}

#endif
	if(modus)
		form_dial(FMD_GROW,0,0,0,0,tree->ob_x-3,tree->ob_y-3,
										 tree->ob_width+6,tree->ob_height+6);

	graf_mouse(M_OFF,0L);
	pxyarray[0]=tree->ob_x-3;
	pxyarray[1]=tree->ob_y-3;
	pxyarray[2]=tree->ob_x+tree->ob_width-1+3;
	pxyarray[3]=tree->ob_y+tree->ob_height-1+3;
	pxyarray[4]=0;
	pxyarray[5]=0;
	pxyarray[6]=tree->ob_width-1+6;
	pxyarray[7]=tree->ob_height-1+6;
	vro_cpyfm(vdihandle,S_ONLY,pxyarray,&ps[FDBcount],&pd[FDBcount]);
	objc_draw(tree,ROOT,MAX_DEPTH,tree->ob_x-3,tree->ob_y-3,
											tree->ob_width+6,tree->ob_height+6);
	vro_cpyfm(vdihandle,S_ONLY,pxyarray,&ps[FDBcount],&pb[FDBcount]);
	graf_mouse(M_ON,0L);
	return(TRUE);
}

static int _form_exclose(OBJECT *tree, int exit_obj, int modus)
{
	int pxyarray[8];

	if(modus)
		form_dial(FMD_SHRINK,0,0,0,0,tree->ob_x-3,tree->ob_y-3,
										 tree->ob_width+6,tree->ob_height+6);

	graf_mouse(M_OFF,0L);
	pxyarray[0]=0;
	pxyarray[1]=0;
	pxyarray[2]=tree->ob_width-1+6;
	pxyarray[3]=tree->ob_height-1+6;
	pxyarray[4]=tree->ob_x-3;
	pxyarray[5]=tree->ob_y-3;
	pxyarray[6]=tree->ob_x+tree->ob_width-1+3;
	pxyarray[7]=tree->ob_y+tree->ob_height-1+3;
	vro_cpyfm(vdihandle,3,pxyarray,&pd[FDBcount],&ps[FDBcount]);
	graf_mouse(M_ON,0L);

	if(exit_obj > -1 /*&& exit_obj < 256*/)
		tree[exit_obj].ob_state &= ~SELECTED;
#if GEMDOS
	Mfree(pb[FDBcount].fd_addr);
	Mfree(pd[FDBcount].fd_addr);
#else
	farfree(pb[FDBcount].fd_addr);
	farfree(pd[FDBcount].fd_addr);
#endif
	pd[FDBcount].fd_addr=NULL;
	pb[FDBcount].fd_addr=NULL;

	return(exit_obj);
}

#if GEMDOS
static void set_menu(int enable)
{
	int id,obj;
	static int width=0;
	extern int gl_apid;
	#define THEACTIVE 2

	wind_update(BEG_UPDATE);
	if (enable)
	{
#ifdef GEISS
		winmenu [THEACTIVE].ob_width = width;
		menu_bar(winmenu,TRUE);
#else
		for(obj=ROOT+4; winmenu[obj].ob_type==G_TITLE; obj++)
			menu_ienable(winmenu,obj,TRUE);
		menu_ienable(winmenu,obj+2,TRUE);
		winmenu [THEACTIVE].ob_width = width;
/*
		if(_GemParBlk.global[0]>=0x0400)
		{
			id=menu_bar(winmenu,-1);
			if(id==gl_apid)
				menu_bar(winmenu,TRUE);
		}
		else
*/
			menu_bar(winmenu,TRUE);
#endif

	}
	else
		if (winmenu [THEACTIVE].ob_width != 0)
		{
#ifdef GEISS
			width = winmenu [THEACTIVE].ob_width;
			winmenu [THEACTIVE].ob_width = 0;
#else
			for(obj=ROOT+4; winmenu[obj].ob_type==G_TITLE; obj++)
				menu_ienable(winmenu,obj,FALSE);
			menu_ienable(winmenu,obj+2,FALSE);
			width = winmenu [THEACTIVE].ob_width;
			winmenu [THEACTIVE].ob_width = winmenu [ROOT+3].ob_x +
													 winmenu [ROOT+3].ob_width;
			menu_bar(winmenu,TRUE);
#endif
		} /* if, else */
	wind_update(END_UPDATE);
}

static void form_size(OBJECT *tree, int h)
{
	register int i;
	
	tree[ROOT].ob_state&=~OUTLINED;
	tree[ROOT].ob_spec.obspec.framesize=0;
	tree[ROOT+1].ob_flags|=HIDETREE;
	tree[ROOT+2].ob_flags|=HIDETREE;
/*
	if(!(tree->ob_flags & 0x0400))/* W„re Hilfedialog, aber kein Handle */
*/
	{
		tree[ROOT].ob_y+=(h/2);
		tree[ROOT].ob_height-=h;
		for(i=ROOT+1; i; i=tree[i].ob_next)
		{
			tree[i].ob_y-=h;
			if(tree[i].ob_next==ROOT)
				break;
		}
	}
}

static void form_resize(OBJECT *tree, int h)
{
	register int i;

	tree[ROOT].ob_state|=OUTLINED;
	tree[ROOT].ob_spec.obspec.framesize=2;
	tree[ROOT+1].ob_flags&=~HIDETREE;
	tree[ROOT+2].ob_flags&=~HIDETREE;
/*
	if(!(tree->ob_flags & 0x0400)) /* W„re Hilfedialog, aber kein Handle */
*/
	{
		tree[ROOT].ob_y-=(h/2);
		tree[ROOT].ob_height+=h;
		for(i=ROOT+1; i; i=tree[i].ob_next)
		{
			tree[i].ob_y+=h;
			if(tree[i].ob_next==ROOT)
				break;
		}
	}
}
#endif

int objc_sysvar(int ob_smode, int ob_swhich, 
					 int ob_sival1, int ob_sival2,
                int *ob_soval1, int *ob_soval2 )
{
	AESPB aespb=
	{
		_GemParBlk.contrl,
		_GemParBlk.global,
		_GemParBlk.intin,
		_GemParBlk.intout,
		_GemParBlk.addrin,
		_GemParBlk.addrout
	};

	_GemParBlk.intin [0] = ob_smode;
	_GemParBlk.intin [1] = ob_swhich;
	_GemParBlk.intin [2] = ob_sival1;
	_GemParBlk.intin [3] = ob_sival2;

	_GemParBlk.contrl[0]=48;
	_GemParBlk.contrl[1]=4;	
	_GemParBlk.contrl[2]=3;	
	_GemParBlk.contrl[3]=0;	
	_GemParBlk.contrl[4]=0;	

	_crystal(&aespb);

	*ob_soval1 = _GemParBlk.intout[1];
	*ob_soval2 = _GemParBlk.intout[2];

	return(_GemParBlk.intout[0]);
}

int mindestens_16_Farben(void)
{
	extern int work_out[];

	vq_extnd(vdihandle,1,work_out);
	return(work_out[4]>=4?TRUE:FALSE); /* 4 Farbplanes = 16 Farben*/
}

int form_exopen(OBJECT *tree, int modus)
{
#if GEMDOS
/*
	static int msgbuf[8];
	static MEVENT mevent=
	{
		MU_MESAG|MU_TIMER,
		0,0,0,
		0,0,0,0,0,
		0,0,0,0,0,
		msgbuf,
		0L,					/* bei Makro: 16L, */
		0,0,0,0,0,0,
	/* nur der Vollst„ndigkeit halber die Variablen von XGEM */
		0,0,0,0,0,
		0,
		0L,
		0L,0L
	};
*/
	INFOVSCR *infovscr;
	int mx,my,ret,kstate;
	int x,y,w,h;
	int wi_kind=NAME|MOVER;
	extern int dialbgcolor,actbutcolor; /* 3D-Look */
	
	graf_mouse(M_ON, NULL);/* nur bei eventgesteuerter Maus */

	graf_mkstate(&mx,&my,&ret,&kstate);
	if(divmenu[DIVZENT].ob_state&SELECTED)		 /* immer zentrieren */
		form_center(tree,&ret,&ret,&ret,&ret);

	if(divmenu[DIVFREE].ob_state&SELECTED)		 /* frei */
		;

	if(divmenu[DIVMAUS].ob_state&SELECTED)		 /* zur Maus */
		pop_excenter(tree,mx,my,&ret,&ret,&ret,&ret);

	if(!letemfly) /* Let 'em fly bernimmt das Fliegen, weil schneller */
		letemfly = (LTMFLY *)get_cookie('LTMF');
	if(letemfly && letemfly->config.bypass)
		letemfly=NULL;

	if(kstate & (K_LSHIFT|K_RSHIFT)) /* Bei gedrckter Controltaste... */
		form_center(tree,&ret,&ret,&ret,&ret);	 /* ...zentrieren */

	if((infovscr=(INFOVSCR *)get_cookie('VSCR'))!=NULL) /* BigScreen 2 */
	{
		if(infovscr->cookie=='VSCR')
		{
			tree->ob_x=infovscr->x+(infovscr->w-tree->ob_width)/2;
			tree->ob_y=infovscr->y+(infovscr->h-tree->ob_height)/2+ydesk;
		}
	}
	actbutcolor=WHITE;
	dialbgcolor=WHITE;
	if(_GemParBlk.global[0]>=0x0340 /*&& mindestens_16_Farben()*/)
	{  /* erst prfen, ob implementiert */
		if(objc_sysvar(0,4/*ACTBUTCOL*/,0,0,&actbutcolor,&ret)>0)
			objc_sysvar(0,5/*BACKGRCOL*/,0,0,&dialbgcolor,&ret);
		else
			actbutcolor=WHITE;
	}
	if(get_cookie('MagX'))
		wi_kind|=BACKDROP;
	if(windials && !(tree->ob_flags & FLAGS15) &&
		(dial_handle=wind_create(wi_kind,xdesk,ydesk,wdesk,hdesk))>0)
	{
		set_menu(FALSE);
		wind_set(dial_handle,WF_NAME,(char *)((TEDINFO *)tree[ROOT+2].ob_spec.userblk->ub_parm)->te_ptext);
		form_size(tree, 2*boxh);
		wind_calc(WC_BORDER,NAME|MOVER,tree->ob_x,tree->ob_y,tree->ob_width,tree->ob_height,&x,&y,&w,&h);
		if(y<ydesk) /* MOVER nicht in Menzeile */
		{
			tree->ob_y+=(ydesk-y);
			y=ydesk;
		}
		if(modus)
			form_dial(FMD_GROW,0,0,0,0,tree->ob_x,tree->ob_y,tree->ob_width,tree->ob_height);
		wind_open(dial_handle,x,y,w,h);
/*
		undotree=form_copy(tree,0);
*/
		return(dial_handle);
	}
	else
	{
	#if MiNT
		wind_update(BEG_UPDATE);
		wind_update(BEG_MCTRL);
	#endif
		if(letemfly)
			form_open(tree, modus);
		else
		{
			FDBcount++;
			if(!_form_exopen(tree, modus))
			{
				tree[ROOT+1].ob_flags|=HIDETREE;
				form_open(tree, modus);
			}
		}
/*
		undotree=form_copy(tree,0);
*/
		return(FDBcount);
	}
#else

	graf_mouse(M_ON, NULL);/* nur bei eventgesteuerter Maus */

#if MiNT
	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);
#endif
	if(tree[ROOT+1].ob_flags&TOUCHEXIT)
	{
		tree[ROOT+1].ob_flags&=~TOUCHEXIT;
		tree[ROOT+1].ob_flags|=HIDETREE;
	}
	form_open(tree, modus);
/*
	undotree=form_copy(tree,0);
*/
	return(FALSE);
#endif
}

int form_exclose(OBJECT *tree, int exit_obj, int modus)
{
/*
	if(undotree)
		free(undotree);
*/
#if GEMDOS
	if(dial_handle>0 && !(tree->ob_flags & FLAGS15))
	{
		wind_close(dial_handle);
		wind_delete(dial_handle);
		if(modus)
			form_dial(FMD_SHRINK,0,0,0,0,tree->ob_x,tree->ob_y,tree->ob_width,tree->ob_height);
		form_resize(tree, 2*boxh);
		if(exit_obj > -1)
			tree[exit_obj].ob_state &= ~SELECTED;
		set_menu(TRUE);
		dial_handle=-1;
	}
	else
	{
		if(letemfly)
			form_close(tree, exit_obj, modus);
		else
		{
			if(FDBcount<MAX_DEPTH && pd[FDBcount].fd_addr)
				_form_exclose(tree, exit_obj, modus);
			else
			{
				form_close(tree, exit_obj, modus);
				tree[ROOT+1].ob_flags&=~HIDETREE;
			}
			FDBcount--;
		}
#if MiNT
		wind_update(END_MCTRL);
		wind_update(END_UPDATE);
#endif
	}
#else
	form_close(tree, exit_obj, modus);
#if MiNT
	wind_update(END_MCTRL);
	wind_update(END_UPDATE);
#endif
#endif
	return(exit_obj);
}
#if GEMDOS
static void _form_trans(OBJECT *tree)
{
	int pxyarray[8];
	extern int xdesk,ydesk,wdesk,hdesk;

	graf_mouse(M_OFF,0L);
	pxyarray[0]=tree->ob_x-3;
	pxyarray[1]=tree->ob_y-3;
	pxyarray[2]=tree->ob_x+tree->ob_width-1+3;
	pxyarray[3]=tree->ob_y+tree->ob_height-1+3;
	pxyarray[4]=0;
	pxyarray[5]=0;
	pxyarray[6]=tree->ob_width-1+6;
	pxyarray[7]=tree->ob_height-1+6;
	vro_cpyfm(vdihandle,S_ONLY,pxyarray,&ps[FDBcount],&pb[FDBcount]);

	pxyarray[0]=0;
	pxyarray[1]=0;
	pxyarray[2]=tree->ob_width-1+6;
	pxyarray[3]=tree->ob_height-1+6;
	pxyarray[4]=tree->ob_x-3;
	pxyarray[5]=tree->ob_y-3;
	pxyarray[6]=tree->ob_x+tree->ob_width-1+3;
	pxyarray[7]=tree->ob_y+tree->ob_height-1+3;
	vro_cpyfm(vdihandle,S_ONLY,pxyarray,&pd[FDBcount],&ps[FDBcount]);
	graf_mouse(M_ON,0L);

	graf_mouse(FLAT_HAND,NULL);
	graf_dragbox(tree->ob_width,tree->ob_height,tree->ob_x,tree->ob_y,
					  xdesk+3,ydesk+3,wdesk-6,hdesk-6,&tree->ob_x,&tree->ob_y);
	graf_mouse(ARROW,NULL);

	graf_mouse(M_OFF,0L);
	pxyarray[0]=tree->ob_x-3;
	pxyarray[1]=tree->ob_y-3;
	pxyarray[2]=tree->ob_x+tree->ob_width-1+3;
	pxyarray[3]=tree->ob_y+tree->ob_height-1+3;
	pxyarray[4]=0;
	pxyarray[5]=0;
	pxyarray[6]=tree->ob_width-1+6;
	pxyarray[7]=tree->ob_height-1+6;
	vro_cpyfm(vdihandle,S_ONLY,pxyarray,&ps[FDBcount],&pd[FDBcount]);

	pxyarray[0]=0;
	pxyarray[1]=0;
	pxyarray[2]=tree->ob_width-1+6;
	pxyarray[3]=tree->ob_height-1+6;
	pxyarray[4]=tree->ob_x-3;
	pxyarray[5]=tree->ob_y-3;
	pxyarray[6]=tree->ob_x+tree->ob_width-1+3;
	pxyarray[7]=tree->ob_y+tree->ob_height-1+3;
	vro_cpyfm(vdihandle,S_ONLY,pxyarray,&pb[FDBcount],&ps[FDBcount]);
	graf_mouse(M_ON,0L);
}

static void _form_frame(OBJECT *tree)
{
	extern int xdesk,ydesk,wdesk,hdesk;
	int x,y,pxyarray[8];

	graf_mouse(FLAT_HAND,NULL);
	graf_dragbox(tree->ob_width,tree->ob_height,tree->ob_x,tree->ob_y,
					  xdesk+3,ydesk+3,wdesk-6,hdesk-6,&x,&y);
	graf_mouse(ARROW,NULL);

	graf_mouse(M_OFF,0L);

	pxyarray[0]=tree->ob_x-3;
	pxyarray[1]=tree->ob_y-3;
	pxyarray[2]=tree->ob_x+tree->ob_width-1+3;
	pxyarray[3]=tree->ob_y+tree->ob_height-1+3;
	pxyarray[4]=0;
	pxyarray[5]=0;
	pxyarray[6]=tree->ob_width-1+6;
	pxyarray[7]=tree->ob_height-1+6;
	vro_cpyfm(vdihandle,S_ONLY,pxyarray,&ps[FDBcount],&pb[FDBcount]);

	pxyarray[0]=0;
	pxyarray[1]=0;
	pxyarray[2]=tree->ob_width-1+6;
	pxyarray[3]=tree->ob_height-1+6;
	pxyarray[4]=tree->ob_x-3;
	pxyarray[5]=tree->ob_y-3;
	pxyarray[6]=tree->ob_x+tree->ob_width-1+3;
	pxyarray[7]=tree->ob_y+tree->ob_height-1+3;
	vro_cpyfm(vdihandle,S_ONLY,pxyarray,&pd[FDBcount],&ps[FDBcount]);

	tree->ob_x=x;
	tree->ob_y=y;

	pxyarray[0]=tree->ob_x-3;
	pxyarray[1]=tree->ob_y-3;
	pxyarray[2]=tree->ob_x+tree->ob_width-1+3;
	pxyarray[3]=tree->ob_y+tree->ob_height-1+3;
	pxyarray[4]=0;
	pxyarray[5]=0;
	pxyarray[6]=tree->ob_width-1+6;
	pxyarray[7]=tree->ob_height-1+6;
	vro_cpyfm(vdihandle,S_ONLY,pxyarray,&ps[FDBcount],&pd[FDBcount]);

	pxyarray[0]=0;
	pxyarray[1]=0;
	pxyarray[2]=tree->ob_width-1+6;
	pxyarray[3]=tree->ob_height-1+6;
	pxyarray[4]=tree->ob_x-3;
	pxyarray[5]=tree->ob_y-3;
	pxyarray[6]=tree->ob_x+tree->ob_width-1+3;
	pxyarray[7]=tree->ob_y+tree->ob_height-1+3;
	vro_cpyfm(vdihandle,S_ONLY,pxyarray,&pb[FDBcount],&ps[FDBcount]);
	graf_mouse(M_ON,0L);
}

static int _form_move(OBJECT *tree, int xdiff, int ydiff)
{
	int pxyarray[8];

	graf_mouse(M_OFF,0L);
	pxyarray[0]=tree->ob_x+xdiff-3; /* neuen Bereich sichern */
	pxyarray[1]=tree->ob_y+ydiff-3;
	pxyarray[2]=tree->ob_x+xdiff+tree->ob_width-1+3;
	pxyarray[3]=tree->ob_y+ydiff+tree->ob_height-1+3;
	pxyarray[4]=0;
	pxyarray[5]=0;
	pxyarray[6]=tree->ob_width-1+6;
	pxyarray[7]=tree->ob_height-1+6;
	vro_cpyfm(vdihandle,S_ONLY,pxyarray,&ps[FDBcount],&pb[FDBcount]);

	pxyarray[0]=tree->ob_x-3;		/* Box verschieben */
	pxyarray[1]=tree->ob_y-3;
	pxyarray[2]=tree->ob_x+tree->ob_width-1+3;
	pxyarray[3]=tree->ob_y+tree->ob_height-1+3;
	pxyarray[4]=tree->ob_x+xdiff-3;
	pxyarray[5]=tree->ob_y+ydiff-3;
	pxyarray[6]=tree->ob_x+xdiff+tree->ob_width-1+3;
	pxyarray[7]=tree->ob_y+ydiff+tree->ob_height-1+3;
	vro_cpyfm(vdihandle,S_ONLY,pxyarray,&ps[FDBcount],&ps[FDBcount]);

	pxyarray[0]=0;					  /* alten Hintergrund restaurieren */
	pxyarray[1]=0;
	pxyarray[2]=tree->ob_width-1+6;
	pxyarray[3]=tree->ob_height-1+6;
	pxyarray[4]=tree->ob_x-3;
	pxyarray[5]=tree->ob_y-3;
	pxyarray[6]=tree->ob_x+tree->ob_width-1+3;
	pxyarray[7]=tree->ob_y+tree->ob_height-1+3;
	vro_cpyfm(vdihandle,S_ONLY,pxyarray,&pd[FDBcount],&ps[FDBcount]);

	pxyarray[0]=0;				 /* Boxbuffer nach Destbuffer umkopieren */
	pxyarray[1]=0;
	pxyarray[2]=tree->ob_width-1+6;
	pxyarray[3]=tree->ob_height-1+6;
	pxyarray[4]=0;
	pxyarray[5]=0;
	pxyarray[6]=tree->ob_width-1+6;
	pxyarray[7]=tree->ob_height-1+6;
	vro_cpyfm(vdihandle,S_ONLY,pxyarray,&pb[FDBcount],&pd[FDBcount]);
	graf_mouse(M_ON,0L);

	tree->ob_x+=xdiff;
	tree->ob_y+=ydiff;
	return(TRUE);
}

static int _form_fly(register OBJECT *tree, register int xdiff, register int ydiff)
{
	register int pxyarray[8];

	if(abs(xdiff)>tree->ob_width+6-1 || abs(ydiff)>tree->ob_height+6-1)
		return(_form_move(tree,xdiff,ydiff));
											  /* verschieben wenn keine šberlappung */

	graf_mouse(M_OFF,0L);
	pxyarray[0]=tree->ob_x+xdiff-3; /* neuen zu berlappenden Bereich sichern */
	pxyarray[1]=tree->ob_y+ydiff-3;
	pxyarray[2]=tree->ob_x+xdiff+tree->ob_width+3-1;
	pxyarray[3]=tree->ob_y+ydiff+tree->ob_height+3-1;
	pxyarray[4]=0;
	pxyarray[5]=0;
	pxyarray[6]=tree->ob_width+6-1;
	pxyarray[7]=tree->ob_height+6-1;
	vro_cpyfm(vdihandle,S_ONLY,pxyarray,&ps[FDBcount],&pb[FDBcount]);

	pxyarray[0]=tree->ob_x-3;		 /* Box verschieben */
	pxyarray[1]=tree->ob_y-3;
	pxyarray[2]=tree->ob_x+tree->ob_width+3-1;
	pxyarray[3]=tree->ob_y+tree->ob_height+3-1;
	pxyarray[4]=tree->ob_x+xdiff-3;
	pxyarray[5]=tree->ob_y+ydiff-3;
	pxyarray[6]=tree->ob_x+xdiff+tree->ob_width+3-1;
	pxyarray[7]=tree->ob_y+ydiff+tree->ob_height+3-1;
	vro_cpyfm(vdihandle,S_ONLY,pxyarray,&ps[FDBcount],&ps[FDBcount]);

	if(xdiff<0)					/* frei werdende Rechtecke wieder restaurieren */
	{
		pxyarray[0]=tree->ob_width+6+xdiff;
		pxyarray[1]=0;
		pxyarray[2]=tree->ob_width+6-1;
		pxyarray[3]=tree->ob_height+6-1;
		pxyarray[4]=tree->ob_x+tree->ob_width+3+xdiff;
		pxyarray[5]=tree->ob_y-3;
		pxyarray[6]=tree->ob_x+tree->ob_width+3-1;
		pxyarray[7]=tree->ob_y+tree->ob_height+3-1;
		vro_cpyfm(vdihandle,S_ONLY,pxyarray,&pd[FDBcount],&ps[FDBcount]);
	}
	if(xdiff>0)
	{

		pxyarray[0]=0;
		pxyarray[1]=0;
		pxyarray[2]=xdiff-1;
		pxyarray[3]=tree->ob_height+6-1;
		pxyarray[4]=tree->ob_x-3;
		pxyarray[5]=tree->ob_y-3;
		pxyarray[6]=tree->ob_x-3+xdiff-1;
		pxyarray[7]=tree->ob_y+tree->ob_height+3-1;
		vro_cpyfm(vdihandle,S_ONLY,pxyarray,&pd[FDBcount],&ps[FDBcount]);

	}
	if(ydiff<0)
	{
		pxyarray[0]=0;
		pxyarray[1]=tree->ob_height+6+ydiff;
		pxyarray[2]=tree->ob_width+6-1;
		pxyarray[3]=tree->ob_height+6-1;
		pxyarray[4]=tree->ob_x-3;
		pxyarray[5]=tree->ob_y+tree->ob_height+3+ydiff;
		pxyarray[6]=tree->ob_x+tree->ob_width+3-1;
		pxyarray[7]=tree->ob_y+tree->ob_height+3-1;
		vro_cpyfm(vdihandle,S_ONLY,pxyarray,&pd[FDBcount],&ps[FDBcount]);
	}
	if(ydiff>0)
	{
		pxyarray[0]=0;
		pxyarray[1]=0;
		pxyarray[2]=tree->ob_width+6-1;
		pxyarray[3]=ydiff-1;
		pxyarray[4]=tree->ob_x-3;
		pxyarray[5]=tree->ob_y-3;
		pxyarray[6]=tree->ob_x+tree->ob_width+3-1;
		pxyarray[7]=tree->ob_y-3+ydiff-1;
		vro_cpyfm(vdihandle,S_ONLY,pxyarray,&pd[FDBcount],&ps[FDBcount]);
	}

	graf_mouse(M_ON,0L);

	pxyarray[0]=(xdiff>0?xdiff:0); /* Rest von Destbuffer nach Boxbuffer umkopieren */
	pxyarray[1]=(ydiff>0?ydiff:0);
	pxyarray[2]=tree->ob_width+6-1-(xdiff>0?0:-xdiff);
	pxyarray[3]=tree->ob_height+6-1-(ydiff>0?0:-ydiff);
	pxyarray[4]=(xdiff>0?0:-xdiff);
	pxyarray[5]=(ydiff>0?0:-ydiff);
	pxyarray[6]=tree->ob_width+6-1-(xdiff>0?xdiff:0);
	pxyarray[7]=tree->ob_height+6-1-(ydiff>0?ydiff:0);
	vro_cpyfm(vdihandle,S_ONLY,pxyarray,&pd[FDBcount],&pb[FDBcount]);

	pxyarray[0]=0; /* Boxbuffer nach Destbuffer umkopieren */
	pxyarray[1]=0;
	pxyarray[2]=tree->ob_width+6-1;
	pxyarray[3]=tree->ob_height+6-1;
	pxyarray[4]=0;
	pxyarray[5]=0;
	pxyarray[6]=tree->ob_width+6-1;
	pxyarray[7]=tree->ob_height+6-1;
	vro_cpyfm(vdihandle,S_ONLY,pxyarray,&pb[FDBcount],&pd[FDBcount]);
/*
	memmove(pd[FDBcount].fd_addr,pb[FDBcount].fd_addr,
		(long)pd[FDBcount].fd_wdwidth*2L*(long)pd[FDBcount].fd_h*(long)pd[FDBcount].fd_nplanes);
*/
	tree->ob_x+=xdiff;
	tree->ob_y+=ydiff;
	return(TRUE);
}
#endif
int form_exdo(OBJECT *tree, int start)
{
	int event,mx,my,oldx,oldy,mstate,ret,kstate,exit_obj;
	int lw,rw,uh,lh,pxy[4];
	extern int xdesk,ydesk,wdesk,hdesk,work_out[];
/*
	static MEVENT mevent=
	{
		MU_BUTTON|MU_M1,
		1,1,0,
		1,0,0,1,1,
		0,0,0,0,0,
		NULL,
		0L,
		0,0,0,0,0,0,
	/* nur der Vollst„ndigkeit halber die Variablen von XGEM */
		0,0,0,0,0,
		0,
		0L,
		0L,0L
	};
*/
#if GEMDOS
	vq_extnd(vdihandle,1,work_out);
	pxy[0]=xdesk;
	pxy[1]=ydesk;
	pxy[2]=xdesk+wdesk-1;
	pxy[3]=ydesk+hdesk-1;
	vs_clip(vdihandle,FALSE,pxy);
#endif
	do
	{
		exit_obj=_form_exdo(tree, start);
#if GEMDOS
		if((exit_obj&0x7FFF)==(ROOT+1))
		{
			if(letemfly && !letemfly->config.bypass) /* mit Let 'em fly, weil schneller ist. */
			{
				letemfly->di_fly(tree);
			}
			else
			{
				graf_mkstate(&mx,&my,&mstate,&kstate);
				oldx = mx;
				oldy = my;
				if(mstate&2)
					kstate=K_LSHIFT; /* auch wenn beide Maustasten gedrckt */
				if(kstate)
				{
					_form_trans(tree);
				}
				else
				{
					if(work_out[6]>2000)
					{
						lw=mx-tree->ob_x+3; /* wo steht die Maus in der Box? */
						rw=tree->ob_x+tree->ob_width+3-mx;
						uh=my-tree->ob_y+3;
						lh=tree->ob_y+tree->ob_height+3-my;
/*
				  		mevent.e_m1.g_x=mx;
				  		mevent.e_m1.g_y=my;
*/
						graf_mouse(FLAT_HAND,NULL);
						do
						{
							graf_mkstate(&mx, &my, &mstate, &ret);
							if(mx != oldx || my != oldy)
							{
								if(mx-lw<xdesk)
									mx=xdesk+lw;
								if(my-uh<ydesk)
									my=ydesk+uh;
								if(mx+rw>xdesk+wdesk)
									mx=xdesk+wdesk-rw;
								if(my+lh>ydesk+hdesk)
									my=ydesk+hdesk-lh;
								/* Flieg los, Huhn */
								_form_fly(tree,mx-oldx,my-oldy);
								oldx = mx;
								oldy = my;
							}
						}
						while(mstate);
/* geht nicht auf dem Falcon
						do
						{
							event=evnt_event(&mevent);
							if(event & MU_M1)
							{
								mx=mevent.e_mx;
								my=mevent.e_my;
	
								if(mx-lw<xdesk)
									mx=xdesk+lw;
								if(my-uh<ydesk)
									my=ydesk+uh;
								if(mx+rw>xdesk+wdesk)
									mx=xdesk+wdesk-rw;
								if(my+lh>ydesk+hdesk)
									my=ydesk+hdesk-lh;
	
								/* Flieg los, Huhn */
								_form_fly(tree,mx-mevent.e_m1.g_x,my-mevent.e_m1.g_y);
	
						  		mevent.e_m1.g_x=mx;
						 		mevent.e_m1.g_y=my;
					 		}
						}
						while(mevent.e_mb & 1); /* linke Maustaste gedrckt */
*/
						graf_mouse(ARROW,NULL);
					}
					else
						_form_frame(tree);
				}
			}
		}
#endif
	}
	while((exit_obj&0x7FFF)==(ROOT+1));
	return(exit_obj);
}

int form_hndl(OBJECT *tree,int start, int modus)
{
	int exit_obj;

	form_open(tree,modus);
	exit_obj=form_do(tree,start);
	form_close(tree,exit_obj,modus);
	return(exit_obj);
}

int form_exhndl(OBJECT *tree, int start, int modus)
{
	int exit_obj;
	form_exopen(tree,modus);
	exit_obj=form_exdo(tree, start);
	form_exclose(tree, exit_obj, modus);
	return(exit_obj);
}

void pop_excenter(OBJECT *tree, int mx, int my, int *x, int *y, int *w, int *h)
{
	extern int xdesk,ydesk,wdesk,hdesk;

	tree->ob_x = mx-tree->ob_width/2;
	if(tree->ob_x<xdesk+3)
		tree->ob_x=xdesk+3;
	tree->ob_y = my-tree->ob_height/2;
	if(tree->ob_y<ydesk+3)
		tree->ob_y=ydesk+3;
	if(tree->ob_x+tree->ob_width > wdesk-3)
		tree->ob_x=wdesk-tree->ob_width-3;
	if(tree->ob_y+tree->ob_height > ydesk+hdesk-3)
		tree->ob_y=ydesk+hdesk-tree->ob_height-3;
	*x=tree->ob_x;
	*y=tree->ob_y;
	*w=tree->ob_width;
	*h=tree->ob_height;
}

int pop_do(OBJECT *tree, int close_at_once)
{
	int mx,my,mouse_click,oum,noum,ret,x,y,w,h,event,leave,mobutton,bmsk=1;
/*	unsigned int key,kstate; */
	GRECT r;

	x=tree->ob_x;
	y=tree->ob_y;
	w=tree->ob_width;
	h=tree->ob_height;

	graf_mkstate (&mx, &my, &mobutton, &ret);

	noum=oum=objc_find(tree,0,8,mx,my);
	if(oum != -1)
		if((tree[oum].ob_flags & SELECTABLE) && !(tree[oum].ob_state & DISABLED))
			objc_change(tree,oum,0,x,y,w,h,tree[oum].ob_state|SELECTED,1);

	do
	{
		if(noum != -1)							  /* In Meneintrag */
		{
			objc_offset(tree,noum,&r.g_x,&r.g_y);
			r.g_w=tree[noum].ob_width;
			r.g_h=tree[noum].ob_height;
			leave = TRUE;
		} /* if */
		else										  /* Aužerhalb Pop-Up-Men */
		{
			objc_offset(tree,ROOT,&r.g_x,&r.g_y);
			r.g_w=w;
			r.g_h=h;
			leave = FALSE;
		} /* else */

		event=evnt_multi (/*MU_KEYBD|*/MU_BUTTON|MU_M1,
								1, bmsk, ~ mobutton & bmsk,
								leave, r.g_x, r.g_y, r.g_w, r.g_h,
								0, 0, 0, 0, 0,
								NULL, 0, 0,
								&mx, &my, &ret, &ret, &ret, &ret);
/*
		if(event&MU_BUTTON)
*/
			noum=objc_find(tree,0,MAX_DEPTH,mx,my);
/*
		if(event&MU_KEYBD)
		{
			MapKey(&kstate,&key);
			switch(key)
			{
				case 0x8048:/*up*/
					if(oum>ROOT+1)
						noum--;
					break;
				case 0x8050:/*dn*/
					if(!(tree[oum].ob_flags & LASTOB))
						noum++;
					break;
				case 0x8061:/*Undo*/
					noum=-1; /*kein break!*/
				case 0x400D:/*Enter*/
				case 0x000D:/*Return*/
					event|=MU_BUTTON;
					break;
			}
		}	
*/
		if(oum>0)
			objc_change(tree, oum,0,x,y,w,h,tree[ oum].ob_state&~SELECTED,1);
		if(noum>0)
			objc_change(tree,noum,0,x,y,w,h,tree[noum].ob_state| SELECTED,1);
		oum=noum;
	}
	while(!(event & MU_BUTTON));

	if (~ mobutton & bmsk) evnt_button (1, bmsk, 0x0000, &ret, &ret, &ret, &ret); /* Warte auf Mausknopf */

	if(oum>0)
		tree[oum].ob_state&=~SELECTED;
	return(oum);
}

int pop_exhndl(OBJECT *tree,int mx,int my,int modus)
{
	int exit_obj,ret;

	FDBcount++;
	wind_update(BEG_MCTRL);
	pop_excenter(tree,mx,my,&ret,&ret,&ret,&ret);
	_form_exopen(tree,0);
	exit_obj=pop_do(tree,modus);
	_form_exclose(tree,-1,0);
	evnt_button(1,1,0,&ret,&ret,&ret,&ret);
	wind_update(END_MCTRL);
	FDBcount--;
	return(exit_obj);
}

void form_write(OBJECT *tree, int item, char *string, int modus)
{
	int len;
	if(tree[item].ob_type==G_USERDEF)
	{
/*
		len=(int)((TEDINFO *)tree[item].ob_spec.userblk->ub_parm)->te_txtlen;
		strncpy((char *)((TEDINFO *)tree[item].ob_spec.userblk->ub_parm)->te_ptext,
			string,len);
		*(char *)((TEDINFO *)tree[item].ob_spec.userblk->ub_parm)->te_ptext[len]=0;
*/
		strcpy((char *)((TEDINFO *)tree[item].ob_spec.userblk->ub_parm)->te_ptext,string);
	}
	else
	{
/*
	   len=tree[item].ob_spec.tedinfo->te_txtlen;
		strncpy(tree[item].ob_spec.tedinfo->te_ptext,
			string,len);
		tree[item].ob_spec.tedinfo->te_ptext[len]=0;
*/
		strcpy(tree[item].ob_spec.tedinfo->te_ptext,string);
	}
	if(modus)
		objc_update(tree,item,0);
}

char *form_read(OBJECT *tree,int item, char *string)
{
	if(tree[item].ob_type==G_USERDEF)
		return(strcpy(string,(char *)((TEDINFO *)tree[item].ob_spec.userblk->ub_parm)->te_ptext));
	else
		return(strcpy(string,tree[item].ob_spec.tedinfo->te_ptext));
}
