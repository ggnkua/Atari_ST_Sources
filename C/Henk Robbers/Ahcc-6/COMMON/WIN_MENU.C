/*  Copyright (c) 1992 - present by Henk Robbers Amsterdam.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*	win_menu.c
 *	library functions for GEM programs using own or window menu's.
 *  Complete handling of shortcuts.
 */

#include <limits.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>

#include "aaaa_lib.h"
#include "win_menu.h"

static
short pull,title,			/* for menu_loop with find_pull & find_title */
      mbox_types[]={G_BOX,-1};

extern
short aes_flags;

static
bool menu_type(short ty, short types[])
{
	short i=0;
	if (!types)
		return true;
	while (types[i] > 0 and types[i] ne ty) i++;
	return types[i] eq ty;
}

global
void menu_print(OBJECT *m, short types[])
{
	short i=0;
	do
	{
		if(menu_type(m[i].type,types))
		{
			fprintf(stdprn,"ty:%3d\th:%3d\tn:%3d\tt:%3d\ti:%3d\t"
			,m[i].type,m[i].head,m[i].next,m[i].tail,i);
			if (   m[i].type eq G_STRING
				or m[i].type eq G_SHORTCUT
				or m[i].type eq G_TITLE)
				fprintf(stdprn,m[i].spec.free_string);
			fprintf(stdprn,"\n");
		}
	}
	while((m[i++].flags&LASTOB) eq 0);
}

global
void menu_init(M_S *ms, short item)
{
	rsrc_gaddr(0,item,&ms->m);

	ms->vhl=virt_handle;
	ms->dsk=screct;
	ms->evm_dir=0;
	ms->mn=0;
	ms->pn=0;
	ms->en=0;

	if (item and (aes_flags&GAI_GSHORTCUT))		/* mainmenu item must be zero */
	{
		OBJECT *o = ms->m;

		o[0].w=ms->dsk.w;	/* 05.17 OL v5.6 18'20 v6*/
		o[1].w=ms->dsk.w;

		do{
			if ((o->type&0xff) eq G_STRING)
				o->type = (o->type&0xff00)|G_SHORTCUT;
			if (o->flags&LASTOB)
				break;
			o++;
		}od
	}
}

global
RECT ob_rect(OBJECT *ob,short item)
{
	RECT r;
	objc_offset(ob,item,&r.x,&r.y);
	r.w=ob[item].w;
	r.h=ob[item].h;
	return r;
}

static
short pull_parent(OBJECT *m)
{
	return m[m[0].head].next;
}

static
MENU_ACT find_title			/*	M_S *ms,short titel,short item	*/
{
	if (item > 2 and titel eq title)
	{
		pull=item;
		return true;
	}
	return false;
}

static
short find_pull(M_S *ms)
{
	pull=-1;
	title=ms->mn;
	menu_loop(ms,find_title,mbox_types);
	return pull;
}

static
void menu_ent(M_S *ms)
{
	short hl=ms->vhl;
	hidem;
	vswr_mode(hl,3);		/* XOR */
	vsf_color(hl,1);		/* black */
	gspbox(hl,ob_rect(ms->m,ms->en));	/* gem struct RECT filled box */
	vswr_mode(hl,1);
	vsf_color(hl,0);
	showm;
}

global
short change_ob(OBJECT *m, short i, RECT cl, bool sta)
{
	return objc_change(m,i,0,
					cl.x,cl.y,cl.w,cl.h,
					sta,true);
}

global
bool menu_avail(M_S *ms, short i)
{
	return (ms->m[i].state&(DISABLED|HIDETREE)) eq 0;
}

global
void menu_dis(OBJECT *m, short item, bool enab)
{
	if (enab)
		m[item].state&=~DISABLED;
	else
		m[item].state|= DISABLED;
}

global
short menu_title(M_S *ms, bool state)
{

	short sta=state ? 0 : SELECTED;
	short rest=ms->m[ms->mn].state;
	rest &=~SELECTED;
	return (ms->mn and menu_avail(ms,ms->mn))
				? change_ob(ms->m,ms->mn,ms->b,sta|rest)
				: 1;
}

global
void menu_clear(M_S *ms)
{
	ms->en=0;
	if (ms->pn)
	{
		form_rest(ms->m,ms->pn,ms->vhl,ms->d);
		ms->pn=0;
	}
	if (ms->mn)
	{
		menu_title(ms,true);		/* normal */
		ms->mn=0;
	}
	ms->evm_dir=0;
}

static
void menu_pull(M_S *ms)
{
	ms->evm_dir=1;			/* next event als eruit */
	ms->r=ob_rect(ms->m,ms->mn);
	ms->en=0;
	if (menu_avail(ms,ms->mn))
	{
		ms->pn=find_pull(ms);
		menu_title(ms,false);		/* invers */
		ms->d=form_save(ms->m,ms->pn,ms->vhl);		/* is incl draw!!! */
	}
}

static
void menu_push(M_S *ms)
{
	form_rest(ms->m,ms->pn,ms->vhl,ms->d);
	ms->pn=0;
	ms->en=0;
	ms->d=nil;
}

global
bool menu_mouse(M_S *ms,short mx,short my)		/* NB evm_dir allreade switched */
{
	short k,p;

	if (!ms->mn)					/* into bar, no title on */
	{
		mouse(mx,my,k,p);	/* if mouse allready out again */
		ms->mn=objc_find(ms->m,2,2,mx,my);
		if (ms->mn > 0)
		{
			menu_pull(ms);
		othw
			menu_clear(ms);
			return false;
		}
		return true;
	}

	if (ms->en)		/* if an ent was on we now surely are out of it */
	{
		menu_ent(ms);
		ms->en=0;
	}

	if (ms->pn)
	{
		p=objc_find(ms->m,ms->pn,2,mx,my); /* mouse within pull */
		if (p > 0)
		{
			ms->r=ob_rect(ms->m,p);
			if (p ne ms->pn and menu_avail(ms,p))
			{
				ms->en=p;
				menu_ent(ms);
			}
			return true;
		}
	}

	p=objc_find(ms->m,2,2,mx,my);			/* title ? */

	if (p > 0)
	{
		ms->r=ob_rect(ms->m,p);
		if (p ne ms->mn)				/* other title ? */
		{
			if (ms->pn)
			{
				menu_push(ms);
				menu_title(ms,true);		/* normal */
			}
			ms->mn=p;
			menu_pull(ms);
		}
		ms->mn=p;
		return true;
	}

	if (my < ms->r.y + ms->r.h)
		menu_clear(ms);

	return false;
}

global
short menu_button(M_S *ms,short *mt)
{
	short i;
	if (!ms)
		return -1;
	i=ms->mn;
	*mt=ms->en;
	if (ms->pn)
		menu_push(ms);
	ms->mn=0;
	ms->en=0;
	return i;
}

/* keep pulldowns within screen.	*/
static
MENU_ACT menu_boxes		/* ms, titel, item */
{
	short x,y,x1,y1;
	OBJECT *menu=ms->m;
	menu[item].x=menu[1].x
	            +menu[2].x
	            +menu[titel].x;
	menu[item].y=0;					/* first: align */

	objc_offset(menu,item,&x,&y);
	x1=x+menu[item].w;
	y1=y+menu[item].h;
	if (x1 >= ms->dsk.w)
	{
		menu[item].x-=x1-(ms->dsk.w-1);
		menu[item].x&=0xfff8;
	}
	if (y1 >= ms->dsk.h)
		menu[item].y-=y1-(ms->dsk.h-1);
	return false;					/* don't stop */
}

global
void menu_place(M_S *ms, RECT men)
{
	ms->b=men;
	ms->m->x=((men.x/CHAR_BIT)+1)*CHAR_BIT;
	ms->m->y=men.y;
	ms->t=ob_rect(ms->m,2);		/* menu tree[2] is all titles */
	menu_loop(ms,menu_boxes,mbox_types); /* keep pull_downs within screen */
}

global
short menu_evm(M_S *ms, short evmask, short event)
{
	short d;
	short e=(event eq MU_M1 or event eq MU_M2) ? event : MU_M2;
	if (!ms->mn)
	{
		ms->evm_dir=0;
		ms->pn=0;
		ms->en=0;
		ms->r=ms->t;  /* only the titles */
		d=(ms->r.x+ms->r.w)-(ms->b.x+ms->b.w);
		if (d > 0)
			ms->r.w-=d;
		return e|evmask;
	othw
		return e|MU_BUTTON;		/* if menu on: then only these */
	}

}

global
DRAWM menu_draw		/*	M_S *ms, RECT men, RECT cl	*/
{
	if (ms->m)
	{
		short yplush=men.y+men.h-1;

		menu_place(ms,men);
		draw_ob(ms->m,1,cl);	/* bar only */
		hidem;
		vsl_color(ms->vhl, 1);	/* Someone (not ROM TOS) changed line color to white :-( */
		line(ms->vhl,men.x,         yplush,
		             men.x+men.w-1, yplush);
		showm;
	}
}

static
bool menu_loop(M_S *ms,MENU_ACT *act,short types[])
{
	OBJECT *m=ms->m;
	short i= m[0].head,
		pa    = m[i].head,
		titel = m[pa].head,
		pab   = m[i].next,
		box   = m[pab].head;
	bool ok=false;

	do
	{	if (menu_type(m[box].type,types))	/* for boxes */
		{	ok = (*act)(ms,titel,box);
			if (ok) return true;
		}

		i = m[box].head;
		do
		{	if (menu_type(m[i].type,types))	/* for entries */
			{	ok = (*act)(ms,titel,i);
				if (ok) return true;
			}
			if (m[i].next > 0 and m[i].next ne box)
				i = m[i].next;
			else
				break;
		} while (!ok);

		if (m[box].next > 0 and m[box].next ne pab)
			box   = m[box  ].next,
			titel = m[titel].next;
		else
			break;
	} while (!ok);
	return false;
}

static
short mmt, mmn;

static
M_KEY spec;

static
short mkey_types[]={G_STRING,G_SHORTCUT,-1};

static
MENU_ACT find_key		/*	M_S ms,short titel,short item	*/
{
	OBJECT *m=ms->m;
	char *s = m[item].spec.free_string;

	if (strstr(s,spec.c))
	{
		if (menu_avail(ms,item) and menu_avail(ms,titel))
		{
			ms->mn=titel;
			menu_title(ms,false);
			ms->mn=0;
			mmt = item;
		}
		else
			mmt = -item;	/* disabled entry: inhibit do_key() */
		mmn = titel;
		return true;
	}
	return false;
}

short alert_msg(char *t, ... );

static
char * to(char *d, const char *s)
{
	while(*s) *d++ = *s++;
	*d = 0;
	return d;
}

extern FILE *pmenukeys;

global
M_KEY m_key(short kcode)
/* construct string from key according to
	conventions for shortcuts in menu entries */
/* kcode is normalized by function 'normkey()' */
{
	static M_KEY key;
	char *s=key.c;
	short
		kc = kcode&0xff,
	    ks = kcode&NKF_SHIFT,
		fk;

	loop(fk,sizeof(M_KEY))
		key.c[fk]=0;

	*s++=' ';		/* surround with spaces for strstr() in find_key() above */

	fk = kc >= NK_F1 and kc <= NK_F10;

	if (kcode&(NKF_CTRL|NKF_ALT))
		kc=toupper(kc);			/* per convention */
	if (kcode&NKF_CTRL)
		*s++ = '^';
	if (kcode&NKF_ALT)
		*s++ = 7;					/* wit op zwart ruitje */
	if (ks and !fk and kcode < 0)	/* any shift with func not F.. */
		*s++ = 1;					/* pijltje omhoog */
	if ( kc eq ' ')
		kc ='';
	if (kcode > 0)					/* not one of above */
	{
		if (*s eq 0)
		  	*s++ = '<',				/* plain character */
			*s++ = kc,
			*s++ = '>';
	othw
		if (fk)
		{
			*s++='F';
			if (ks)
				if (kc eq NK_F10)
					*s++='2',*s++='0';
				else
					*s++='1',*s++=kc-NK_F1+'1';
			else
				if (kc eq NK_F10)
					*s++='1',*s++='0';
				else
					*s++=kc-NK_F1+'1';
		othw
			switch (kc)
			{
				case NK_ENTER:
					s = to(s, "ENT");
				break;
				case NK_RET:
					s = to(s, "NL");
					break;
				case NK_BS:
					s = to(s, "BS");
					break;
				case NK_CLRHOME:
					s = to(s, "HOME");
				break;
				case NK_UNDO:
					s = to(s, "UNDO");
				break;
				case NK_HELP:
					s = to(s, "HELP");
				break;
				case NK_INS:
					s = to(s, "INS");
				break;
				case NK_DEL:
					s = to(s, "DEL");
				break;
				case NK_ESC:
					s = to(s, "ESC");
				break;
				case NK_TAB:
					s = to(s, "TAB");
				break;
				default:
					if (key.c[1] eq 0)	/* normal shift that produces real upper case */
					{
						*s++='<';
						*s++=kc;
						*s++='>';
					}
					else
					{
						if (!kc)
							*s++ = 16;		/* 'digital' noaght */
						else
							*s++ = kc;
					}
			}
		}
	}

	if (*(s-1) ne ' ' )	/* if not yet */
		*s++ = ' ';

	*s = 0;				/* 10'12 HR */
	return key;
}


/*  short menu_keys(M_S *ms,M_KEY key,short *nmt) */
global
MENU_KS menu_keys
{
	mmt = 0;
	mmn = 0;
	if (key.c[0])
	{
		spec=key;
		menu_loop(ms,find_key,mkey_types);
	}

	*nmt = mmt;
	return mmn;
}
