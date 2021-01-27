/*  Copyright (c) 1990 - present by Henk Robbers Amsterdam.
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

/* Library routines for AHCC et al. */

#define __MINT__

#include "hierarch.h"
#include "aaaa_lib.h"
#include <limits.h>
#include <stdio.h>

#include <string.h>
#include <ctype.h>
#include "mallocs.h"
#include "ahcm.h"

#define BIGS 128

static char matches(char c, char *f)	/* verb */
{
	while (*f)		/* must have pairs */
	{
		if (c eq *f)
			return *(f+1);		/* Ho! a match */

		f += 2;
	}

	/* no matches (noun) */
	return 0;
}

global
char * strtra(short max, char *d, char *s, char *f)	/* copying: */
{
	char *e, *sv = d;

	if (max >= BIGS)
		max = BIGS-1;

	e = s + max;

	while (*s and s < e)
	{
		char n = matches(*s, f);
		*d++ = n ? n : *s;
		 s++;
	}

	*d = 0;
	return sv;
}

global
void strrep(short max, char *s, char *f)	/* in situ: */
{
	char *e;

	if (max >= BIGS)
		max = BIGS-1;

	e = s + max;

	while (*s and s < e)
	{
		char n = matches(*s, f);
		if (n) *s = n;
		s++;
	}
}

/* the following function is mainly intended for use on strings
	for alert boxes ('[' and ']' disrupt the alert format).
 */

global
char * alert_secure(short max, char *s)		/* copying: */
{
	static char o[BIGS];
	char *e, *d = o;

	if (max >= BIGS)
		max = BIGS-1;

	e = s + max;

	while (*s and s < e)
	{
		if (*s  eq '[')
			*d++ = '{';
		elif(*s eq ']')
			*d++ = '}';
		else
			*d++ = *s;

		s++;
	}

	*d = 0;
	return o;
}

global
short alert_text(char *f, ... )		/* sort of original alert_text */
{
	char m[BIGS], *mp=m;
	va_list a;
	va_start(a,f);
	mp+=sprintf(mp,"[1][ ");
	mp+=vsprintf(mp,f,a);
	sprintf(mp," ][ Ok ]");
	va_end(a);
	return form_alert(1,m);
}

global
void alert_32(char *s, char *t)
{
	char ss[128];

	strncpy(ss, t, 32);
	s[32]=0;
	alert_text("%s|%s", s, ss);
}

global
short alert_qtext(bool stop, char *t, ... )
{
	char m[256], *mp=m;
	va_list a;
	va_start(a,t);
	if (*t ne '[')		/* This for security reasons only */
	{
		mp+=sprintf(mp,"[1][ ");
		mp+=vsprintf(mp,t,a);
		sprintf(mp,stop ? " ][ Ok | Stop]": " ][ Ok ]");
	}
	else
		vsprintf(mp,t,a);
	va_end(a);
	return form_alert(1,m);
}

short is_alpha(short c)
{
	return c == '_' || isalpha(c);
}

short is_alnum(short c)
{
	return c == '_' || isalnum(c);
}

short is_punct(short c)
{
	switch (c)
	{
	 	case ',':
	 	case '.':
	 	case '/':
	 	case '\\':
	 	case ']':
	 	case '[':
	 	case '}':
	 	case '{':
	 	case '(':
	 	case ')':
	 	/* Add any character you consider punctuation. */
	 	/* Remove any you dont. */
	 		return 1;
	 }
	 return 0;
}

/* check outline of outlined RECT rectangle against RECT bounds
   if snap, snap x on inline on hardware unit.
   Is rect > bounds, align upper left  */

static
RECT snapbox(short ol,short snap,RECT i,RECT o,
						short *xb,short *yb)	/* ol < CHAR_BIT */
{
	short nx;
	*xb=false;
	*yb=false;

	if (i.x     < o.x)
		i.x     = o.x,        *xb=true;

	if (i.x+i.w > o.x+o.w)
		i.x     = o.x+o.w-i.w,*xb=true;

	if (i.y     < o.y)
		i.y     = o.y,        *yb=true;

	if (i.y+i.h > o.y+o.h)
		i.y     = o.y+o.h-i.h,*yb=true;

	if (snap)
	{
		nx=i.x+ol;
		nx/=CHAR_BIT;
		nx*=CHAR_BIT;
		if (nx-ol < o.x)
			nx += CHAR_BIT,*xb=true;
		i.x=nx-ol;
	}

	return i;
}

static
PRB p_rat;
static
RECT ps;
static
RECT vr;
static
bool sn;
static
short form_outl, form_hndl = 0;

static
void snaprat(void)
{
	short xb,yb;

	p_rat.r.x += p_rat.dx;
	p_rat.r.y += p_rat.dy;

/* snap box op inline & check outline op bounds */

	ps=snapbox(form_outl,sn,p_rat.r,vr,&xb,&yb);

/* Niet plakkerig zijn aan de randen  ja? */
	if (xb)
		p_rat.r.x=ps.x;
	if (yb)
		p_rat.r.y=ps.y;
}

global
void mv_rat(RECT *ps,PRB *p)		/* absolute minimum (denk aan clipping) */
{
	ps->x+=p->dx;
	ps->y+=p->dy;
}

global
void mv_scrrat(RECT *ps,PRB *p)		/* check against screen without sticking */
{

	if (   ps->x+p->dx       < scr_grect.x
		or ps->x+ps->w+p->dx > scr_grect.x+scr_grect.w )
		p->o.x=ps->x;					/* do not stick on bound */
	else
		ps->x+=p->dx;

	if (   ps->y+p->dy       < scr_grect.y
		or ps->y+ps->h+p->dy > scr_grect.y+scr_grect.h )
		p->o.y=ps->y;
	else
		ps->y+=p->dy;
}

/* snap box op inline & check outline op bounds */
global
void mv_snaprat(short ol,bool snap,bool stick,RECT *ps,PRB *p,RECT o)
{
	short xb,yb;

	p->r.x+=p->dx;
	p->r.y+=p->dy;

/* snap box op inline & check outline op bounds */

	*ps=snapbox(ol,snap,p->r,o,&xb,&yb);

	if (!stick)
	{
/* Niet plakkerig zijn aan de randen  ja? */
		if (xb)
			p->r.x=ps->x;
		if (yb)
			p->r.y=ps->y;
	}
}

void form_set(RECT *dp,RECT *sc,OBJECT *db,short startob,MFDB *dump);

global
short aform_move(OBJECT *db,short hl,void *area,bool snap,
					  short edob,short *cured,short moveob, short undoob,
					  GRECT *vrijheid)
{
	short obno=0;

	MFDB schrm=MFDBnull;
	MFDB dump =MFDBnull;
	DRBVN pxy;

	form_hndl=hl;
	vr=*vrijheid;	/* form x,y,w,h  f.i. desktop or window work area */
	sn=snap;
	dump.fd_addr=area;

	while (true)
	{
		/* iedere keer vhgd 1e keer outline buiten scherm viel */
		form_set(&pxy.pv,&ps,db,0,&dump);
		pxy.pn=ps;

		if ( (obno=aform_do(db,edob,cured,moveob,undoob)) ne moveob) break;

		hidem;
		copy_gform(form_hndl,pxy,&dump,&schrm); /* herstel scherm */
		showm;

		movebox(form_hndl,&ps,&p_rat,true,snaprat);	/* ps nieuwe area */

		db->x=ps.x+form_outl;			/* nieuwe positie */
		db->y=ps.y+form_outl;

/* set en save nieuw schermgedeelte; nu voor hele box incl outline */
		form_set(&pxy.pn,&pxy.pv,db,0,&dump);

		hidem;
		copy_gform(form_hndl,pxy,&schrm,&dump);
		showm;
		draw_ob(db,0,ps,1);
	}
	return obno;
}

global
short form_move(OBJECT *db, short hl, void *area, bool snap,
				short edob, short moveob, short undoob, RECT *vrijheid)
{
	return aform_move(db, hl, area, snap,
	                  edob, nil, moveob, undoob, vrijheid);
}

global
void draw_ob(OBJECT *ob,short item,RECT cl,short which)
{
	objc_draw(ob,item,MAX_DEPTH,cl.x,cl.y,cl.w,cl.h);
/*	v_show_c(phys_handle,1);	*/	/* force (needed on some OS's HR: hmmm, AHCC now uses correct handle */
}

static
void form_set(RECT *dp,RECT *sc,OBJECT *db,short startob,MFDB *dump)
{
	short x,y;
	objc_offset(db,startob,&x,&y);
/*	form_outl=(db[startob].state&(OUTLINED|SHADOWED))?3:2;
*/	form_outl=3;
			/* minimaal een rand */

	sc->x=x-form_outl;					/* screen area */
	sc->y=y-form_outl;
	sc->w=db[startob].w+2*form_outl;
	sc->h=db[startob].h+2*form_outl;

/* wel ruimte voor complete outline reserveren ivm form_move */
	dump->fd_w=((sc->w>>4)+1)<<4;			/* veelvoud van 16 naar boven */
	dump->fd_h=sc->h;
	dump->fd_wdwidth=(dump->fd_w/16); /* 16=bits/short */
	dump->fd_nplanes=scr.planes;

/* als outline  buiten scherm valt */
	if ( x<form_outl ) sc->x=0;
	if ( y<form_outl ) sc->y=0;
	if ( sc->w+sc->x > scr.w  ) sc->w=scr.w-sc->x;
	if ( sc->h+sc->y > scr.h  ) sc->h=scr.h-sc->y;

	dp->x=0;								/* save area */
	dp->y=0;
	dp->w=sc->w;
	dp->h=sc->h;
}

static
char *sch_alert="[1][Not enough memory|for screen dump area. !][ Quit! ]";

#define TRACE(a) alert_text("-= " #a " =-");

global
void *form_save(OBJECT *db,short startob,short hl)			/* return dumparea */
{
	MFDB schrm=MFDBnull;
	MFDB dump =MFDBnull;
	DRBVN pxy;

	form_set(&pxy.pn,&pxy.pv,db,startob,&dump);   /* dump,scherm,object,MFDB*/
	dump.fd_addr=malloc( (long)dump.fd_wdwidth
	                          *dump.fd_h
	                          *scr.planes
	                          *sizeof(short)
	                     );
	if ( dump.fd_addr eq nil )
	{
		form_alert(1,sch_alert);
		return nil;
	}

	hidem;
	form_hndl=hl;
	copy_gform(hl,pxy,&schrm,&dump);
	showm;
	draw_ob(db,startob,pxy.pv,2);
	return dump.fd_addr;
}

global
void form_rest(OBJECT *db,short startob,short hl,void *area)
{
	MFDB schrm=MFDBnull;
	MFDB dump =MFDBnull;
	DRBVN pxy;

	if (area > 0)
	{
		dump.fd_addr=area;
		form_set(&pxy.pv,&pxy.pn,db,startob,&dump);

		hidem;
		copy_gform(hl,pxy,&dump,&schrm);
		showm;
		free(area);
	}
}

/* align dialogue box on dx, dy or around mouse position */
/* check against rectangle */
/* if snap, snap x on inline on hardware unit */

global
void form_align(OBJECT *d,bool snap, short dx, short dy, RECT *wwa)
{
	RECT in;
	short lx,ly;
	short o;

	if ((d->state&(OUTLINED|SHADOWED))) o = 3; else o=2;

	if (dx < 0)
	{
		mouse(dx,dy,lx,ly);			/* lx,ly dummy voor k,s */

		dx-=d->w/2;
		dy-=d->h/2;
	}
	in.x=dx-o;						/* o is for check against bounds */
	in.y=dy-o;
	in.w=d->w+o;
	in.h=d->h+o;

	in = snapbox(o,snap,in,*wwa,&lx,&ly);
	d->x=in.x+o;
	d->y=in.y+o;
}

global
short first_edob(OBJECT *o)
{
	short i = 0;
	while ((o[++i].flags&EDITABLE) eq 0)
		if (o[i].flags&LASTOB)
			return 0;		/* No editable fields */
	return i;
}

global
short last_edob(OBJECT *o)
{
	short i = 0, last = 0;
	do{
		if (o[++i].flags&EDITABLE)
			last = i;
		if (o[i].flags&LASTOB)
			return last;
	}od
}

global
short prev_edob(OBJECT *o,short ed)
{
	short i = ed;
	while (--i)
		if (o[i].flags&EDITABLE)
			return i;
	return ed;
}

global
short next_edob(OBJECT *o,short ed)
{
	short i = ed;
	while ((o[i].flags&LASTOB) eq 0)
		if ((o[++i].flags&EDITABLE) ne 0)
			return i;
	return ed;
}

global
short find_def(OBJECT *o)
{
	short i = 0, m = SELECTABLE|EXIT|DEFAULT;
	while ((o[++i].flags&m) ne m)
		if (o[i].flags&LASTOB)
			return 0;		/* No default exit fields */
	return i;
}

/* l is the true space for the destination string, so it includes the /0 ch */
global
void strsncpy(char *d, Cstr s, long l)
{
	if (l)
	{
		strncpy(d, s, l);
		*(d + l - 1) = 0;
	}
}

global
void s_to_xstr(OBJECT *ob, short item1, short item2, Cstr s)
{
	TEDINFO *t1 = ob[item1].spec.tedinfo,
			*t2 = ob[item2].spec.tedinfo;

	short l = strlen(s), tl = t1->txtlen-1;  /* cause is incl EOS */

	if (l > tl)
	{
		strmaxcpy(t1->text,s,tl);
		strcpy (t2->text,s+tl);
	othw
		strcpy(t1->text,s);
		*t2->text = 0;
	}
}

global
void xstr_to_s(OBJECT *ob, short item1, short item2, S_path *p)
{
	TEDINFO *t1 = ob[item1].spec.tedinfo,
			*t2 = ob[item2].spec.tedinfo;

	DIRcpy(p, t1->text);
	DIRcat(p, t2->text);
}

/* HR: This code now works for edit objects that are TOUCHEXIT */
/*   	It also uses right button as double click */
/* in AHCC used for DEBUG dialogue. No need for a window!! yeeh? */

static
short aform_cursor(OBJECT *db, short edob, short xob, short *idx)
{
	objc_edit(db,edob,0,idx,ED_END);
	objc_edit(db,xob, 0,idx,ED_INIT);
	return xob;
}

global
short aform_do(OBJECT *db,short start, short *cured, short movob,short undoob)
{
	short edob,nob,xob,mob,which,cont=1;
	short idx,mx,my,mb,ks,kr,br;

	if (start eq 0)
		edob = first_edob(db);
	else
		edob = start;

	wind_update(BEG_UPDATE);
	wind_update(BEG_MCTRL);

	if (edob)
		objc_edit(db,edob,0,&idx,ED_INIT);

	while (cont)
	{
		which=evnt_multi(
			MU_KEYBD|MU_BUTTON, 2,1,1, 0,0,0,0,0, 0,0,0,0,0, 0,0,0,
			&mx,&my,&mb, &ks,&kr,&br);

		if (which & MU_KEYBD)
		{
			if (kr eq 0x6100 and undoob)		/* UNDO */
			{
				cont = false;
				nob = undoob;
			othw
				cont = form_keybd(db,edob,0,kr,&xob,&kr);
				if (    xob ne 0
					and (db[xob].flags &  EDITABLE) ne 0
					and xob ne edob
				   )
					edob = aform_cursor(db,edob,xob,&idx);
				else
					nob = xob;

				if (kr)
					objc_edit(db,nob = edob,kr,&idx,ED_CHAR);
			}
		}

		if (which & MU_BUTTON)
		{
			nob=objc_find(db,0,MAX_DEPTH,mx,my);
			/* ALTERNATE-left-button or right-button same as double click */
			if ( (ks&ALTERNATE) or (mb&2) )
				br=2;
			if (nob < 0)
			{	ping; cont = true; continue; }
			if (movob and nob eq movob)	/* special case for form_move() */
				break;
			cont = form_button(db,nob,br,&mob);
			xob  = mob&0x7fff;		/* double click on TOUCHEXIT b15 = 1 */
			if (edob and (db[xob].flags & EDITABLE))
			{
				if (xob ne edob)
					edob = aform_cursor(db,edob,xob,&idx);
				nob  = mob;
			}
		}
	}

	if (edob)
		objc_edit(db,edob,0,&idx,ED_END);

	wind_update(END_MCTRL);
	wind_update(END_UPDATE);

	if (cured)
		*cured=edob;
	return nob;
}

static
MFORM flathand =
{	4,4,1,0,1,
 {	0x7A00, 0x7F40, 0xFFE0, 0xFFF0,
	0xFFF8, 0x3FFC, 0x0FFE, 0xC7FF,
	0xEFFF, 0xFFFF, 0xFFFF, 0x7FFF,
	0x3FFF, 0x0FFF, 0x03FE, 0x00FC },
 {	0x5000, 0x2A00, 0x1540, 0xCAA0,
	0x3550, 0x0AA8, 0x0404, 0x0252,
	0xC402, 0xAA01, 0x5001, 0x3001,
	0x0C01, 0x0300, 0x00C0, 0x0000 }
};

MOVE_MODE move_mode=HOLD;

static
bool cont_move(short m)
{
	if (move_mode eq CLICK)
		return (m eq 0);
	else
		return (m ne 0);
}

global
void movebox(short hl,RECT *d,PRB *p,short init,void (*rat)(void) )
{
	bool c=true;
	short x,y,ox,oy,k,s;

	vsl_udsty(hl,0x5555);
	vsl_type(hl,7);
	vsl_color(hl,1);
	vswr_mode(hl,3);
	if (init) gsbox(hl,*d);        /* teken */
	if ( move_mode eq CLICK)
		while ( mousek() );   /* loslaten */
	mouse(x,y,k,s);
	ox=x;
	oy=y;
	p->o=*d;
	p->r=*d;					/* reference box */
	graf_mouse(USER_DEF,&flathand);
	while (c)
	{
		mouse(x,y,k,s);
		p->dx=x-ox;
		p->dy=y-oy;

		(*rat)();		/* bepaalt nieuwe box in d met p.dx en p.dy */

		c=cont_move(s);
		if ( (d->x ne p->o.x or d->y ne p->o.y) and c)
		{
			gsbox(hl,p->o);		/* ontteken		*/
			gsbox(hl,*d);		/* teken nieuw	*/
			p->o=*d;			/* bewaar nieuw */
		}
		ox=x;
		oy=y;
	}
	gsbox(hl,*d);        /* ontteken */
	if (move_mode eq CLICK)
		if (s eq 1) p->sn=1; else p->sn=0; else p->sn=1;		/* no cancel option by button if HOLD */
	vswr_mode(hl,1);
	vsl_type(hl,1);
	if (move_mode eq CLICK) while ( mousek());   /* loslaten */
	mpijl;
}

global
short mousek(void)
{
	short x,y,k,s;
	mouse(x,y,k,s);	/* mouse uses AES (hence physical handle) */
	return k;
}

global
char * xcpy(char *d, char *s)
{
	while (*s) *d++ = *s++;
	*d = 0;
	return d;					/* return end of destination !!!!! not useless first. */
}

global
char * xcat(char *d, char *s)
{
	d += strlen(d);
	return xcpy(d, s);
}


global
void deftext(short h,short c,short s,short r,short g)
{
	short dd;
	vst_color(h,c);
	vst_effects(h,s);
	vst_rotation(h,r);
	vst_height(h,g,&dd,&dd,&dd,&dd);
}

global
void deffill(short h,short c,short a,short b,short v)
{
	vsf_interior(h,a);
	vsf_style(h,b);
	vsf_color(h,c);
	vsf_perimeter(h,v);
}

global
void box(short hl,short p,short q,short r,short s)
{
	short pxy[10];
	hidem;
	pxy[0]=p; pxy[2]=r; pxy[4]=r; pxy[6]=p; pxy[8]=p;
	pxy[1]=q; pxy[3]=q; pxy[5]=s; pxy[7]=s; pxy[9]=q+1;
    v_pline(hl,5,pxy);
    showm;
}

global
void line(short hl,short x,short y,short x1,short y1)
{
	short pxy[4];
	pxy[0]=x;pxy[2]=x1;
	pxy[1]=y;pxy[3]=y1;
	v_pline(hl,2,pxy);
}

global
void gsdline(short hl, RECT r)
{
	r.w-=1;
	line(hl, r.x, r.y  ,r.x+r.w, r.y  );
	line(hl, r.x, r.y+1,r.x+r.w, r.y+1);
}

global
void pbox(short h,short xl,short yl,short xr,short yr)
{
	short xy[4];

	xy[0]=xl;
	xy[1]=yl;
	xy[2]=xr;
	xy[3]=yr;
	v_bar(h,xy);
}

global
void gpbox(short hl,short x,short y,short w,short h)
{
	w+=x-1;
	h+=y-1;
	pbox(hl,x,y,w,h);
}

global
void gspbox(short hl,RECT r)
{
	r.w+=r.x-1;
	r.h+=r.y-1;
	pbox(hl,r.x,r.y,r.w,r.h);
}

global
void gsbox(short hl,RECT r)
{
	r.w+=r.x-1;
	r.h+=r.y-1;
	box(hl,r.x,r.y,r.w,r.h);
}

global
void clips(short hl,short m,short x,short y,short x1,short y1)
{
short pxy[4];

	pxy[0]=x;
	pxy[1]=y;
	pxy[2]=x1;
	pxy[3]=y1;
	vs_clip(hl,m,pxy);
}

global
void gsclip(short hl,short m,RECT r)
{
	r.w+=r.x-1;		/* --> x1 */
	r.h+=r.y-1;		/* --> y1 */
	clips(hl,m,r.x,r.y,r.w,r.h);
}

/*
 *	Pattern matching   Courtesy to the XaAES crew
 *
 *	Valid patterns are:
 *		?      Any single char
 *		*      A string of any char
 *		!X     Any char except for X
 *		[abcd] One of (any one of a,b,c or d)
 *	Examples:
 *		*      All files in dir
 *		a*     All files begining with 'a'
 *		*.c*   All files with a extension starting with c		/* HR */
 *		*.o    All '.o' files
 *		*.!o   All files with extension that is not 'o'
 *		!z*.?  All files not starting with 'z', and having a single character extension
 *		*.[co] All '.o' and '.c' files
 *		*.[ch]* files with a extension starting with c or h
 */

static
short to_upper(short c)
{
	return c|0x20;
}

global
bool match_pattern(Cstr t, Cstr pat)
{
	bool valid = true;

	while (    valid
		   and (   ( *t and *pat)
		   		or (!*t and *pat eq '*')
		   	   )
		  )
	{
		switch (*pat)
		{
		case '?':			/* Any character */
			t++;
			pat++;
			break;
		case '*':			/* String of any character */
			pat++;
			while(*t and (to_upper(*t) ne to_upper(*pat)))
				t++;
			break;
		case '!':			/* !X means any character but X */
			if (to_upper(*t) ne to_upper(pat[1]))
			{
				t++;
				pat += 2;
			} else
				valid = false;
			break;
		case '[':			/* [<chars>] means any one of <chars> */
			while((*(++pat) ne ']') and (to_upper(*t) ne to_upper(*pat)));
			if (*pat eq ']')
				valid = false;
			else
				while(*(++pat) ne ']');
			pat++;
			t++;			/* HR: yeah, this one was missing */
			break;
		default:
			if (to_upper(*t++) ne to_upper(*pat++))
				valid = false;
			break;
		}
	}

	return valid and to_upper(*t) eq to_upper(*pat);	/* includes both \0 */
}

static
short bracer = 0, lvl = 0;

static
bool opposite(uchar c, bool o)
{
	uchar op = 0;

	if (c eq '\'' or c eq '\"')
		op = c;
	elif (o)			/* opening bracer */
		switch (c)
		{
			case '<': op = '>'; break;
			case '(': op = ')'; break;
			case '{': op = '}'; break;
		}
	else				/* closing bracer */
		switch (c)
		{
			case '>': op = '<'; break;
			case ')': op = '('; break;
			case '}': op = '{'; break;
		}

	if (op)
		if (o)
			lvl--;
		else
			lvl++;

	return lvl <= 0;
}

static
bool brace(char **fro)
{
	char c = **fro;
	if   (bracer ne 0 and  c eq bracer)					/* end   bracing ? */
		bracer = 0, lvl = 0, (*fro)++;
	elif (bracer eq 0 and (c eq '\'' or c eq '\"') )	/* begin bracing ? */
		bracer = c, lvl = 1, (*fro)++;
	return bracer ne 0;
}

global
char * delimited_copy(short max, char *fro, char *to, uchar delim)
/* delim must NOT be '\'' or '\"' */
{
	char *st = to;
	while (*fro)
	{
		if (    (brace(&fro) or *fro ne delim)
		    and (to-st) < max
		   )
			*to++ = *fro++;
		else
			break;
	}

	if (*fro)
		fro++;
	*to = 0;

	return fro;
}

/*
 * isfile(f) - return true if the given file exists
 */
global
bool isfile(char *f)
{
	long fd = Fopen(f, FO_READ);

	if (fd < 0)
		return false;

	Fclose(fd);
	return true;
}

global
char *select_file(S_path *diry, S_path *opath, S_path *fkeus, char *opm, short *drive)
{
	static S_path new;
	short knop;

	if ( fsel_exinput(diry->s, fkeus->s, &knop, opm) ne 0 and knop ne 0 )
	{
		if (opath)
			DIRcpy(opath, diry->s);

		/* new is full name, diry gets dir only suitable for Dsetpath() */
		new = dir_plus_name(diry, fkeus->s);
		/* If you dont need that simply use diry */

		*drive = Dgetdrv();

		if ( *(new.s + 1) eq ':')		/* give short drivenr back */
			if ( *new.s >= 'a' )
				*drive = *new.s - 'a';
			else
				*drive = *new.s - 'A';

		return new.s;
	}
	else
		return nil;
}

static
char *uren[]   ={"twaalf ","een ","twee ","drie ","vier ","vijf ",
                 "zes ","zeven ","acht ","negen ","tien ","elf "},
	 *minuten[]={"","vijf over ","tien over ","kwart over ",
	             "tien voor half ","vijf voor half ","half ",
	             "vijf over half ","tien over half ","kwart voor ",
	             "tien voor ","vijf voor "},
	 *gew[]={"net ","geweest "},
	 *prec[]={"nu ","precies "},
	 *pmam[]={" goedemorgen! "," goedemiddag! "," goedenavond! "};

static
char
	 *hetis=" Het is ",
	 *bijna="bijna ",
	 *uur="uur ",
	 *tekst="                                                                              ";

static
long tijd;
static
short  mins,hrs;

static
void uurmin(void)
{
	tijd=Gettime();
	mins=(tijd & 0x07E0)>>5;
	hrs =(tijd & 0xF800)>>11;
}

global
char *ttijd()
{
	short i, j, k;
	char *concat[8];

	for (i=0; i<8; i++) concat[i] = "";
	uurmin();
	hrs = hrs mod 12;

	concat[0] = hetis;
	concat[5] = uren[(hrs + (mins>17 ? 1 : 0)) mod 12];
	if ((mins mod 5) eq 0)
	{
		concat[1] = prec[0];		/* nu .... precies */
		concat[7] = prec[1];
		concat[4] = minuten[(mins/5)];
	othw
		if ((mins mod 5) < 3 )
		{
			concat[1] = gew[0];	/* net ... geweest */
			concat[7] = gew[1];
			concat[4] = minuten[(mins/5)];
		othw
			concat[1] = bijna;	/* bijna ...       */
			concat[4] = minuten[( (mins/5)+1 ) mod 12];
		}
	}

	if (mins < 3 or mins > 57)
		concat[6] = uur;

	for (i=0, k=0; i<8; i++)
	{
		j = 0;
		while (concat[i][j] ne '\0')
			tekst[k++] = concat[i][j++];
	}
	tekst[k] = '\0';

	return tekst;
}

global
char *gtijd()
{
	uurmin();
/*	return (hrs<12?pmam[0]:(hrs<18?pmam[1]:pmam[2]));*/
	if   (hrs < 12) return pmam[0];
	elif (hrs < 18) return pmam[1];
	else            return pmam[2];
}

enum
{   EXOTIC,
    EXOMOVER,
    C000,
    C128,
    C160,
    C192,
    C224
};

#define CE EXOMOVER-EXOTIC

static
char emp[]="",
     s1[] =	" Exotic characters ",
     s2[] = "\177 \1 \2 \3 \4 \5 \6 \7 \10 \11 \12 \13 \14 \15 \16 \17 \20 \21 \22 \23 \24 \25 \26 \27 \30 \31 \32 \33 \34 \35 \36 \37 ",
     s3[] =	"€  ‚ ƒ „ … † ‡ ˆ ‰ Š ‹ Œ  Ž   ‘ ’ “ ” • – — ˜ ™ š › œ  ž Ÿ ",
     s4[] =	"  ¡ ¢ £ ¤ ¥ ¦ § ¨ © ª « ¬ ­ ® ¯ ° ± ² ³ ´ µ ¶ · ¸ ¹ º » ¼ ½ ¾ ¿ ",
     s5[] =	"À Á Â Ã Ä Å Æ Ç È É Ê Ë Ì Í Î Ï Ð Ñ Ò Ó Ô Õ Ö × Ø Ù Ú Û Ü Ý Þ ß ",
     s6[] =	"à á â ã ä å æ ç è é ê ë ì í î ï ð ñ ò ó ô õ ö ÷ ø ù ú û ü ý þ ÿ ";

#define W 32

static
TEDINFO t[] =
{
	s1, emp,emp, 3, 6, 2, 0x11A1, 0x0, -1, 20,1,
	s2, emp,emp, 3, 6, 0, 0x1180, 0x0, -1, 65,1,
	s3, emp,emp, 3, 6, 0, 0x1180, 0x0, -1, 65,1,
	s4, emp,emp, 3, 6, 0, 0x1180, 0x0, -1, 65,1,
	s5, emp,emp, 3, 6, 0, 0x1180, 0x0, -1, 65,1,
	s6, emp,emp, 3, 6, 0, 0x1180, 0x0, -1, 65,1
};

static
OBJECT exotics[] =
{
/*  hd    nx  tail 	  ty      flags     state      spec				 x,y, w ,h  */
	-1,EXOMOVER,C224,G_BOX,TOUCHEXIT, SHADOWED, 0xFF1100L,           0,0, 67,9,



	C000,
	-1,
	-1,
	G_BOXTEXT,
	NONE,
	NORMAL,
	(long)&t[EXOMOVER-CE],
	0,
	0,
	67,
	1,

	C128, -1, -1, G_TEXT,  TOUCHEXIT, NORMAL,   (long)&t[C000-    CE],2,2, 64,1,
	C160, -1, -1, G_TEXT,  TOUCHEXIT, NORMAL,   (long)&t[C128-    CE],2,3, 64,1,
	C192, -1, -1, G_TEXT,  TOUCHEXIT, NORMAL,   (long)&t[C160-    CE],2,4, 64,1,
	C224, -1, -1, G_TEXT,  TOUCHEXIT, NORMAL,   (long)&t[C192-    CE],2,5, 64,1,
	EXOTIC,-1,-1, G_TEXT,TOUCHEXIT|LASTOB,NORMAL,(long)&t[C224-   CE],2,6, 64,1
};

static
OBJECT *get_exotics(void)
{
	short x=0,y,w,h;
	static bool fixed=false;
	if (!fixed)
	{
		do
			rsrc_obfix(exotics,x);
		while ((exotics[x++].flags&LASTOB) eq 0);
		form_center(exotics,&x,&y,&w,&h);
		fixed=true;
	}
	return exotics;
}

global
short exotic(short hl,RECT *wwa)
{
	char *dump;
	short obno,mx,my,mk,ms,dx;
	TEDINFO *td;
	OBJECT *o=get_exotics();

	form_align(o,true,-1,-1,wwa);
	dump=form_save(o,0,hl);
	obno=form_move(o,hl,dump,true,0,EXOMOVER,0,wwa);
		 form_rest(o,0,hl,dump);

	mouse(mx,my,mk,ms);
	if ( obno >= C000 and obno <= C224 )
	{
		dx = o[0].x+o[C000].x;
		td=o[obno].spec.tedinfo;
		return *(td->text+(((mx-dx)/(o[C000].w/W))*2))&0xff;
	}
	return -1;
}

#define CBD\
	for (i=0;i<32;++i) x[i]=z;\
	a=&x[31];\
	*a--=0;\
	do{	*a--=n%10+'0'; }\
	while ( (l--) > 0 && (n/=10) != 0);

/* l is supposed to be the exact maximum no of digits that can be held */
global
char *cbd(short n,short l,short z)
{
	short sign=n;
	static char x[32]; char *a; short i;
	if (sign < 0) n=-n;

	CBD
	if ( sign<0 ) *a='-'; else *a=z;
	return a-l+1;

}

global
char *cbdl(long n,short l,short z)
{
	long sign=n;
	static char x[32]; char *a; short i;
	if (sign < 0) n=-n;

	CBD
	if ( sign<0 ) *a='-'; else *a=z;
	return a-l+1;

}

global
char *cbdu(unsigned short n,short l,short z)
{
	static char x[32]; char *a; short i;
	CBD
	return a-l+1;
}

global
char *cbdlu(unsigned long n,short l,short z)
{
	static char x[32]; char *a; short i;
	CBD
	return a-l+1;
}

global
char *cbx(unsigned long n,short l,short z)
{
	static char x[32];
	char *a;
	register short i;

	for (i=0;i<32;++i) x[i]=z;
	a=&x[31];
	*a--=0;
	do
	{
		char c;
		c=(n%16);
		*a--=c+(c<10?'0':'W');
	} while ( --l>0 && (n/=16) > 0 );

	return a-l+1;
}

global
char *cbr(unsigned long n,short l,short z,short r)
{
	static char x[32];
	char *a;
	register short i;

	for (i=0;i<32;++i) x[i]=z;
	a=&x[31];
	*a--=0;
	do
	{
		char c;
		c=(n%r);
		*a--=c+(r==LETTERS?'A':(c<10?'0':'w'));
	} while ( --l>0 && (n/=r) > 0 );

	return a-l+1;
}

#define CDBV(a) a n;short t;\
	n=0; t=0;\
	if ( *s=='-')\
	{ s++; t=1; }\
	while (*s>='0' && *s<='9')\
	{ n=10*n+*s++-'0'; }\
	if (t) return -n; else   return  n;

global
short cdbv(Cstr s) { CDBV(short) }
global
long cldbv(Cstr s) { CDBV(long ) }

global
long crbv(Cstr s,short r)
{
	long n=0;
	short c,b;
	b=r;
	if (r eq 'a' or r eq 'A') b=LETTERS;
	else
	if (r eq 'x' or r eq 'X' or r eq 16) b=16;
	else
		r='0',b=10;

	if (b eq 16)
		while ( (c=*s++) ne 0)
		{
			if   ( c >= '0' and c <= '9')
				n=b*n+(c-'0');
			elif ( c >= 'A' and c <= 'F')
				n=b*n+(c-'A'+10);
			elif ( c >= 'a' and c <= 'f')
				n=b*n+(c-'a'+10);
			else
				break;
		}
	else
		while ( (c=*s++) >= r and c<=r+b-1 )
			n=b*n+(c-r);
	return n;
}

typedef struct
{
	long id,val;
} COOKIE;

static
long stackcorr,			/* make _longframe globally available */
	 *sstack;

#define JAR			(long *)0x5a0L
#define ROM			(long *)0x4f2L
#define SFRAMEXT	(short  *)0x59eL

global
COOKIE * install_cookie_jar(long n)
{
	COOKIE *cookie=Malloc(sizeof(COOKIE) * n);

	if (!cookie)
		return nil;
	(long)sstack=Super(0L);
	*JAR=(long)cookie;
	Super(sstack);
	cookie->id=nil;
	cookie->val=n;
	return cookie;
}

global
bool new_cookie(long cook_id,long cook_val)
{
	COOKIE *cookie,*cookieo;
	short ncookie=0;
	long jarsize;
	SYSHDR *eerste_rom;

	(long)sstack=Super(0L);
	{
		eerste_rom=(SYSHDR *)*ROM;
		stackcorr=*SFRAMEXT ? 8 : 6;
		if (eerste_rom->os_version >= 0x0200)
			cookie=(COOKIE *)*JAR;
	}
	Super(sstack);

	if (eerste_rom->os_version >= 0x0200)	/* context voor cookie_jar */
	{
		cookieo=cookie;
		if (!cookie)
		{
			cookie=install_cookie_jar(16);
			ncookie=0;
		othw
			for
			(
				;
				cookie->id and cookie->id ne cook_id;
				cookie++,ncookie++
			);
		}

		if ( cookie->id )		/* reeds geinstalleerd */
			return false;

		if (cookie->val <= ncookie)
		{
			cookie=install_cookie_jar(cookie->val+8);
			for
			(
				;
				cookie->id;
				*cookie++=*cookieo++
			)
			cookie->id=0;
			cookie->val=cookieo->val+8;
		}
		jarsize=cookie->val;
		cookie->id=cook_id;
		cookie->val=cook_val;
		cookie++;
		cookie->id=nil;
		cookie->val=jarsize;
	}
	return true;
}

global
RECT fit_inside(RECT in, RECT out)
{
	short iew = in .x + in .w,
	      oew = out.x + out.w,
	      ieh = in .y + in .h,
	      oeh = out.x + out.h;

	if (in.w > out.w)
		in.w = out.w;
	if (in.h > out.h)
		in.h = out.h;

	if (iew > oew)
		in.x -= iew - oew;
	if (ieh > oeh)
		in.y -= ieh - oeh;

	if (in.x < out.x)
		in.x = out.x;
	if (in.y < out.y)
		in.y = out.y;
	return in;
}

global
bool get_cookie(long cookie, long *value)
{
	COOKIE *jar;

	(long)sstack = Super(0L);
	jar = *(COOKIE **)0x5a0L; /* JAR (long *)0x5a0L */
	Super(sstack);

	if (!jar)
		return false;

	while(jar->id)
	{
		if (jar->id eq cookie)
		{
			if (value)
				*value = jar->val;
			return true;
		}
		jar++;
	}
	return false;
}

global
bool is_outside(RECT o,RECT i)
{
	return (   o.x     < i.x
			or o.y     < i.y
			or o.x+o.w > i.x+i.w
			or o.y+o.h > i.y+i.h
		   );
}

global
bool intersects(RECT i, RECT o)
{
   short xl, yu, xr, yd;      /* left, upper, right, down */

   xl = max( i.x, o.x );
   yu = max( i.y, o.y );
   xr = min( i.x + i.w,
             o.x + o.w );
   yd = min( i.y + i.h,
             o.y + o.h );

   o.x = xl;
   o.y = yu;
   o.w = xr - xl;
   o.h = yd - yu;

   return( o.w > 0 && o.h > 0 );
}

global
bool is_inside(RECT i,RECT o)	/* i completely inside o */
{
	return (    i.x     >= o.x
			and i.y     >= o.y
			and i.x+i.w <= o.x+o.w
			and i.y+i.h <= o.y+o.h
		   );
}

global
bool m_inside(short x,short y,RECT o)
{
	return (    x >= o.x
			and y >= o.y
			and x <  o.x+o.w
			and y <  o.y+o.h
		   );
}

/* HR: This is  VERY,VERY bad designed function !!!!!!! */
global
short rc_intersect(RECT *r1,RECT *r2)
{
   short xl, yu, xr, yd;      /* left, upper, right, down */

   xl = max( r1->x, r2->x );
   yu = max( r1->y, r2->y );
   xr = min( r1->x + r1->w,
             r2->x + r2->w );
   yd = min( r1->y + r1->h,
             r2->y + r2->h );

   r2->x = xl;
   r2->y = yu;
   r2->w = xr - xl;
   r2->h = yd - yu;

   return( r2->w > 0 && r2->h > 0 );
}

global
const char * pluralis(short n) {	return n ne 1 ? "s" : ""; }

global
void pause(short n) { evnt_timer(1,0); }

/*
 *		Dumps a untyped piece of memory to a named file.
 */

long Fdump(char *fn, short *rfl, long l, void *map)
{
	long fl, wcnt = -1;

	fl=Fcreate(fn,0);
	if (fl > 0)
	{
		if (rfl)
			*rfl = fl;
		wcnt=Fwrite(fl,l,map);
		Fclose(fl);
	}
	return wcnt;
}

/*
 *		Loads a complete file in heap memory.
 */

global
char *Fload(Cstr name, short *fh, long *l, short which)
{
	long pl = 0, fl;
	char *bitmap = nil;
	if (l) *l = 0;
	fl  = fh ? *fh : -1;
	if (name)
		fl = Fopen(name,FO_READ);
	if (fl >= 0)
	{
		if (name)
			if (inq_xfs(name, nil) eq 0)
				strupr((Wstr)name);
		fl &= 0xffff;
		pl = Fseek(0L, fl, 2);
		Fseek(0L, fl, 0);
		bitmap = fcalloc(1, pl+4, which);	/* 03'09 seems to need a little margin for Qpfind c.s. */
		if (bitmap)
		{
			Fread(fl, pl, bitmap);
			*(bitmap + pl) = 0;
		}
		Fclose(fl);
		if (l) *l = pl;
	}
	if (fh) *fh = fl;
	return bitmap;
}

global
char *crlf(char *f)
{
	short i;

	i=strlen(f)-1;
	if (f[i] eq '\n') f[i--]=0;
	if (f[i] eq '\r') f[i  ]=0;
	return f;
}

static
short  dc_pl;		/* current plane number							*/
static
short  dc_row;		/* current row number							*/
static
long   dc_i;			/* byte index for this row and plane			*/
static
uchar *dc_p;			/* pointer to first word in this row and plane	*/

static
void next(void)
{
	/* prepare for next byte 	*/

	if ( (dc_i&1) eq 0 )					/* next byte even -> 				*/
	{
		dc_i+=scr.nword;					/*      next logical word in plane	*/
		if (dc_i >= scr.rdis)				/* next word in next plane ? ->		*/
		{
			if ( ++dc_pl >= scr.planes )	/*     Prepare for next plane	*/
			{
				dc_pl=0;
				dc_p+=scr.rdis;
				dc_row++;
			}
			dc_i=dc_pl+dc_pl;
		}
	}
}

global							/* Gets picture into screen buffer*/
void decompress(uchar *s,		/* screen buffer, must be long enough	*/
			    uchar *f,		/* filebuffer cq picture			*/
			    long l,			/* lengte significante informatie		*/
			    long max,		/* max output */
			    bool sta)		/* TRUE standard, FALSE Atari			*/
{
	uchar *stop=f+l;

	dc_row=0;
	dc_pl=0;
	dc_i=0;
	dc_p=s;

	if (sta)
	do
	{
		short prf;
		uchar c;

		prf=*f++;
		if ( prf>=0 and prf <= 127 )
		{
			while ( (prf--)>=0)
			{
				c=*f++;
				if (dc_i < max) dc_p[dc_i++]=c;
			}
		othw
			if ( prf>=129 and prf <=255 )
			{
				prf=-(prf|0xff00);
				c=*f++;
				while ( (prf--)>=0 )  dc_p[dc_i++]=c;
			}
		}
	} while ( dc_i < max and f < stop );
	else
	do
	{
		short prf;
		uchar c;

		prf=*f++;
		if ( prf>=0 and prf <= 127 )
		{
			while ( (prf--)>=0)
			{
				c=*f++;
				if ( dc_row<scr.h )
				{
					dc_p[dc_i++]=c;
					next();
				}
			}
		othw
			if ( prf>=129 and prf <=255 )
			{
				prf=-(prf|0xff00);
				c=*f++;
				while ( (prf--)>=0 )
				{
					dc_p[dc_i++]=c;
					next();
				}
			}
		}
	} while (  dc_row<scr.h and f < stop );
}

global
long compress(uchar *f,uchar *s,long l, bool sta)
{
	uchar c,n,*of;
	short prf;

	dc_row=0;
	dc_pl=0;
	dc_i=0;

	of=f;
	dc_p=s;

	c=dc_p[dc_i++];
	if (!sta)
		next();		/* interleaved planes */
	n=dc_p[dc_i];

	if (sta)
	while ( dc_i < l )
	{
		if ( c eq n )
		{
			prf=1;
			while ( c eq n and prf<127 )
			{
				c=dc_p[dc_i++];
				n=dc_p[dc_i];
				prf++;
			}
			*f++=-(prf-1);
			*f++=c;
			c=dc_p[dc_i++];
			n=dc_p[dc_i];
			if ( dc_i >=l ) break;
		othw
			uchar *pr=f++;

			prf=0;
			while ( c ne n and prf<127 )
			{
				*f++=c;
				c=dc_p[dc_i++];
				n=dc_p[dc_i];
				prf++;
			}
			*pr=prf-1;
		}
	}
	else
	while ( dc_row<scr.h )
	{
		if ( c eq n )
		{
			prf=1;
			while ( c eq n and prf<127 )
			{
				c=dc_p[dc_i++]; next(); n=dc_p[dc_i];
				prf++;
			}
			*f++=-(prf-1);
			*f++=c;
			c=dc_p[dc_i++]; next(); n=dc_p[dc_i];
			if ( dc_row>=scr.h ) break;
		othw
			uchar *pr=f++;

			prf=0;
			while ( c ne n and prf<127 )
			{
				*f++=c;
				c=dc_p[dc_i++]; next(); n=dc_p[dc_i];
				prf++;
			}
			*pr=prf-1;
		}
	}
	return (f-of);
}

/* ivm deze undefs helemaal achteraan houden */
#undef min
global
short min( short a, short b)
{	return a < b ? a : b; }
#undef max
global
short max( short a, short b)
{	return a > b ? a : b; }


static
bool no_percent(char *s)
{
	bool perc = false;
	while (*s)
	{
		if (*s eq '%')
			perc = true, *s = '$';
		s++;
	}
	return perc;
}

global
void saveconfig(FILE *fp, OpEntry *tab, short level)
{
	char s[150];

	while(tab->s.str[0])
	{
		short lvl = level;

		if (    tab->s.o.srt eq '{'
		    and tab->a       ne nil
		   )
			(*(CFGNEST *)tab->a)(fp, &tab, level, 1);
		elif (    tab->s.o.srt  ne '{'
		      and tab->s.str[0] ne '}'
		      and tab->max      >= 0
		      and tab->a        eq nil
		     )
			alert_text("CE: | wrong cfg | '%s' | %d,0x%08x", tab->s.str, tab->max, tab->a);
		elif (tab->max >= 0)
		{
			if (tab->s.o.srt eq '{' or tab->s.str[0] eq '}')
				lvl--;
			while (lvl-- > 0)
				fprintf(fp, "\t");

			switch (tab->s.o.srt)
			{
				case 's':
				{
					char *ss=tab->a;
					if (*ss eq 0)
					{
						tab++;
						continue;
					}

					while(*ss)
					{
						if (*ss eq ' ')
							*ss='@';
						ss++;
					}
					sprintf(s, tab->s.str, tab->a);
				}
				break;
	#if CAN_HN
				case 'h':
				{
					HI_NAME *hn = *(HI_NAME **)tab->a;
					hn_full(hn, s, &hn->vsep, false);
				}
				break;
	#endif
				case 'd':
				case 'c':
				{
					short *v = tab->a;
					sprintf(s, tab->s.str, *v);
				}
				break;
				case 'l':
				{
					long *v = tab->a;
					sprintf(s, tab->s.str, *v);
				}
				break;
#if FLOAT
				case 'g':
				{
					double *v = tab->a;
					sprintf(s, tab->s.str, *v);
				}
				break;
#endif
				default:
				{
					strcpy(s, tab->s.str);
				}
			}

			fputs(s, fp);
		}

		tab++;
	}
}

void console(char *, ...);
#define CFP 1
global
short CF(FILE *cf, OpEntry *tab)
{
	short n = 0;

	if (!tab)														return 10000;

#if CFP
	if (!cf)
		console("checking config tab\n\n");
#endif
	while (tab->s.str[0])
	{
#if CFP
		if (!cf)
			console(    "%s, %3d, %lx\n", tab->s.str, tab->max, tab->a);
		else
			fprintf(cf, "%s, %3d, %lx\n", tab->s.str, tab->max, tab->a);
#else
		if ( tab->s.o.srt eq '{')
		{
			if  (!tab->a)											return 100+n;
		}
		elif tab->max >= 0;
		{
			if (tab->s.o.srt eq 's')
			{
				if  (!tab->a)										return 200+n;
			}
#if CAN_HN
			elif (tab->s.o.srt eq 'h')
			{
				if  (!tab->a)										return 300+n;
			}
#endif
			elif ( tab->s.o.srt eq 'd'
			{
				if  (!tab->a)										return 400+n;
			}
			elif ( tab->s.o.srt eq 'c'
			     )
			{
				if  (!tab->a)										return 500+n;
			}
			elif (tab->s.o.srt eq 'g')
			{
				if  (!tab->a)										return 600+n;
			}
			elif (tab->s.o.srt eq 'l')
			{
				if  (!tab->a)										return 700+n;
			}
			else
																	return 10000;
		}
#endif
		n++;
		tab++;
	}

#if CFP
	if (!cf)
		console("=================================\n\n");
#endif
	return 0;
}

bool semi_colon = false;
static
void semicolon(char *s)
{
	while(*s)
	{
		if (*s eq ';')
		{
			*s = 0;
			break;
		}
		s++;
	}
}

static
char *nonwhite(char *s)
{
	while( *s ne 0 and (*s eq ' ' or *s eq '\t') ) s++;
	return s;
}

static
char *findis(char *s)
{
	while(*s)
		if (*s ne '=')
			s++;
		else
			break;

	return s;
}

static
void cfgcpy(char *d, char *s, short x)
{
	/* 01'17 v5.6 allow ';' */
	while (      x > 0
			and *s ne 0
			and *s ne ' '
			and *s ne '\t'
		  )
	{
		if (*s eq '@') *s = ' ';
		*d++=*s++, x--;
	}
	*d=0;
}

global
int denotation_space(long big, int root)
/* Returns the character space of a number denotation.
	root: number of digits in system.
	big: biggest number that must fit in the space. */
{
	short c = 1;
	long i = root;
	while (big >= i)
	{
		i *= root;
		c++;
	}

	return c;
}

#define KWSZ 4
global
bool loadconfig(FILE *fp, OpEntry *cfgtab, short level)
{
	short tel=0;
	char *s;

	char r[150];

	while (fgets(s=r, sizeof(r), fp) ne nil )
	{
		OpEntry *tab = cfgtab;

		crlf(s);
		if (semi_colon) semicolon(s);
		s = nonwhite(s);
		if (*s eq ';')
			continue;	/* comment only */
		if (*s eq 0)
			continue;	/* empty line */
		if (   *s eq '}'
		    or strncmp(s, "end",  3) eq 0
		    or strncmp(s, "****", 4) eq 0
		   )
			break;

		while(tab->s.str[0])
		{
			if ( strncmp(s, tab->s.str, KWSZ) eq 0 )
			{
				s=findis(s);
				if (*s eq 0)
					break;		/* keyword only: default: do nothing */
				if (*s eq '=')
					s=nonwhite(++s);

				if (tab->a and tab->max >= 0)

#if 1
				switch(tab->s.o.srt)
				{
				case 's':
					cfgcpy(tab->a, s, tab->max);
					break;
#	if CAN_HN
				case 'h':
				{
					HI_NAME *hn = *(HI_NAME **)tab->a;
					if (hn)
						hn_free(hn);
					*(HI_NAME **)tab->a = hn_make(s, ":\\.", 4);
				}
				break;
#	endif
				case 0x7b:	/* open brace */
					(*(CFGNEST *)tab->a)(fp, &tab, level, 0);
				break;
				case 'c':
					*(uint *)tab->a=*s++;
				break;
				case 'l':
					*(long *)tab->a=cldbv(s);
				break;
#	if __68881__
				case 'g':
					*(double *)tab->a=atof(s);
				break;
#	endif
				default:
					if   (strnicmp(s, "true",  4) eq 0 /* or strncmp(s, "TRUE",  4) eq 0 */)
						*(short *)tab->a=true;
					elif (strnicmp(s, "false", 5) eq 0 /* or strncmp(s, "FALSE", 5) eq 0 */)
						*(short *)tab->a=false;
					else
						*(short *)tab->a=cdbv(s);	/* this is the least dangerous; it is very likely to stop soon and it cannot corrupt memory. */
				}
#else
				if ( tab->s.o.srt eq 's' )
					cfgcpy(tab->a, s, tab->max);
#	if CAN_HN
				elif ( tab->s.o.srt eq 'h' )
				{
					HI_NAME *hn = *(HI_NAME **)tab->a;
					if (hn)
						hn_free(hn);
					*(HI_NAME **)tab->a = hn_make(s, ":\\.", 4);
				}
#	endif
				elif ( tab->s.o.srt eq 0x7b )	/* open brace */
					(*(CFGNEST *)tab->a)(fp, &tab, level, 0);
				elif (tab->s.o.srt eq 'c')
					*(uint *)tab->a=*s++;
				elif (tab->s.o.srt eq 'l')
					*(long *)tab->a=cldbv(s);
#	if __68881__
				elif (tab->s.o.srt eq 'g')
					*(double *)tab->a=atof(s);
#	endif
				elif (strncmp(s, "true",  4) eq 0 or strncmp(s, "TRUE",  4) eq 0)
					*(short *)tab->a=true;
				elif (strncmp(s, "false", 5) eq 0 or strncmp(s, "FALSE", 5) eq 0)
					*(short *)tab->a=false;
				else
					*(short *)tab->a=cdbv(s);	/* this is the least dangerous; it is very likely to stop soon and it cannot corrupt memory. */
#endif
				break;
			}
			tab++;
		}

		if (tab->s.str[0] eq 0)
		{
			tel++;
			alert_text("load: | unknown record type | %4s; ignored", s);
			if (tel > 4)
			{
				alert_text("This may not be a | config file at all; | loading abandoned");
				return false;
			}
		}
	}
	return true;
}

#define RC_LOW G_BOX
#define RC_HIGH G_SLIST

global
char * rc_types[] =
{
	"Box",
	"Text",
	"Boxtext",
	"Image",
	"Userdef",
	"Ibox",
	"Button",
	"Boxchar",
	"String",
	"Ftext",
	"Fboxtext",
	"Icon",
	"Title",
	"Cicon",
	"Swbutton",
	"Popup",
	"Wintitle",
	"Edit",
	"Shortcut",
	"Slist",
	"__________________________________"
};

global
char * rc_type(short t)
{
	if (t >= RC_LOW and t <= RC_HIGH)
		return rc_types[t - RC_LOW];
	sprintf(rc_types[RC_HIGH],"unknown type %d", t);
	return rc_types[RC_HIGH];
}

global
size_t rc_count(OBJECT *tree)
{
	OBJECT *this = tree;
	do { this++; } while ((this->flags&LASTOB) eq 0);
	return  this - tree;
}

global
BT * rc_get(OBJECT *tree, size_t *size)
{
	BT *tr = nil, *t;
	size_t obs = rc_count(tree);
	if (size) *size = obs;
	t = tr = xmalloc(obs*sizeof(BT), AH_RSRCGET);
	if (tr)
		while(obs--)
		{
			switch(tree->type)
			{
			case G_BUTTON:
				t->ty = tree->type;
				t->state = (tree->state&SELECTED) ne 0;
				strsncpy(t->text, tree->spec.free_string, MTX);
			break;
			case G_TEXT:
			case G_FTEXT:
			case G_BOXTEXT:
			case G_FBOXTEXT:
			{
				TEDINFO *ted = tree->spec.tedinfo;
				t->ty = tree->type;
				strsncpy(t->text, ted->text, MTX);
			}
			break;
			default:
				t->state = 0;
				t->ty = 0;
				t->text[0] = 0;
			}
			tree++;
			t++;
		}

	return tr;
}

global
void rc_put(OBJECT *tree, BT *t)
{
	size_t obs = rc_count(tree);
	while(obs--)
	{
		switch (t->ty)
		{
			case G_BUTTON:
				if (t->state&SELECTED)
					tree->state |=  SELECTED;
				else
					tree->state &= ~SELECTED;
			break;
			case G_TEXT:
			case G_FTEXT:
			case G_BOXTEXT:
			case G_FBOXTEXT:
			{
				if (t->state & MTUP)
				{
					TEDINFO *ted = tree->spec.tedinfo;
					strsncpy(ted->text, t->text, ted->txtlen);
				}
			}
		}
		tree++;
		t++;
	}
}

global
void rc_free(BT **t)
{
	xfree(*t);
	*t = nil;
}
