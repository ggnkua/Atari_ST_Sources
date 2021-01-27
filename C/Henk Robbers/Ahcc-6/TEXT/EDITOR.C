/* Copyright (c) 1990 - present by H. Robbers Amsterdam.
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

/* 	EDITOR.C
 *	========
 */

#include <string.h>

#include "common/aaaa_lib.h"
#include "aaaa.h"
#include "common/mallocs.h"
#include "common/kit.h"

#include "cursor.h"
#include "text.h"
#include "common/cursor.h"
#include "common/files.h"	/* mainly for write_out() */
#include "common/ahcm.h"

#define SHOVERFL 5				/* ch's overflow space with shift right */

/*  GLOBALS  */

OBJECT *edmenu;

#define MAXTABS 20

STMDEF shunt;					/* copy paste buffer */

#ifdef MNUNDO
static
STMDEF oldshunt;				/* and its undo buffer */
#endif

/*  COMMONS */

static
char *shuntmap="\0",			/* dummy bitmap */
	  ign[]="Ignored";

global
uchar fkeystr[FKS][FKL] =
{
#include "fkeytxt.h"
};

global
void dis_paste_etc(OBJECT *m,bool dis)
{
#ifdef MNABAN
	menu_dis(m,MNABAN, dis);
#endif
#ifdef MNCUT
	menu_dis(m,MNCUT,  dis);
#endif
#ifdef MNCOPY
	menu_dis(m,MNCOPY, dis);
#endif
#ifdef MNPASTE
	menu_dis(m,MNPASTE,dis);
#endif
#ifdef MTBUFFER
	menu_dis(m,MTBUFFER,dis);
#endif
}

static
void deletecur(STMDEF *m,STMC *s)
{
	if (!(s->xfg&ISMAP))
		xfree(s->xtx);
	stmdelcur(m);
}

static
char cop1[]="while copying";

global
STMC *copy_1(STMDEF *to,STMC *s,short f,short l,STMACC acc)
{
	char *c;
	STMC *sb;

	sb=stminsert(to,abs(acc));
	if (!sb)
	{
		mem_alert(cop1,ign);
		return nil;
	}
	m_alerted=false;
	if (acc < 0 and f eq 0 and l eq s->x_l and (s->xfg&ISMAP))
	{						/* if, for instance, for undo buf */
		sb->xtx=s->xtx;
		sb->xrm=s->xrm;
		sb->xfg=ISMAP;
	othw
		if ( (c= mmalloc(l+1,cop1,ign,AH_COPY1)) <= 0L)
			return nil;

		strmaxcpy(c, s->xtx+f, l);
		sb->xtx=c;
		sb->xfg=0;
		sb->xrm=0;
	}
	sb->x_l=l;
	sb->xun=0;
	return sb;
}

static
void putnl(char *t, char c)
{	short i=strlen(t);
	while (--i and t[i] eq c or t[i] eq ' ');
	t[++i]=0;
}

static
bool isnum (char c)
{	return c >= '0' and c <= '9';
}

static
short analtabs(short t[],char *tx)
{	short ot=0;
	while (*tx)
	{	t[ot]=0;
		while (*tx eq ' ')	tx++;
		if (*tx eq ',')
		{	tx++;
			while (*tx eq ' ')	tx++;
		}

		if (!isnum(*tx))
			break;

		while(isnum(*tx))
			t[ot]=t[ot]*10+(*tx++-'0');
		if (ot and t[ot] < t[ot-1])
			return 0;
		ot++;
	}
	t[ot]=MAXL+1;
	return ot;
}

global
void clear_undo(IT *w)
{
	if (w->old)
	{
		clearmal(w->old);
		stmclear(w->old);
	}
	w->undone=false;
}

static
WINIT buf_winit
{
	w->in.x = win.x + 2*(wwa.w/3);
	w->in.y = wwa.y;
	w->in.w = wwa.w - 2*(wwa.w/3);
	w->in.h = wwa.h;
	snapwindow(w,&w->in);	/* !!! gebruikt slechts w->v !!! */
								/* mooi he? */
	w->frem=wwa;
	snapwindow(w,&w->frem);		/* snap fulled height */
}

static
char *bufname(void)
{
	static MAX_dir nm;
	strcpy(nm, prg_name);
	strlwr(nm);
	strcat(nm, ".buf");
	return nm;
}

static
FCLOSE buf_delete
{
	if (cfg.a and !cfg.s)
		write_out(w, buffn.s);
	clearmal(w->base);
	stmclear(w->base);
	clear_undo(w);
	close_w(w);
	stmdelcur(&winbase);
	return true;
}

global
VpV end_buf		/* 07'20 HR: v6 */
{
	IT *w = get_it(-1, BUFF);
	
	if (w)
		buf_delete(w, true);
}

static
CLOSED close_buf	/* (IT *w) */
{
	cur_off(w);
	close_w(w);
}

global
void invoke_editor(OBJECT *m)
{
	edmenu=m;
	showchange=false;
	buffn = dir_plus_name(&ipath, bufname());

	/*  search/replace dialogue done in invoke_cursor	*/

	/* copy/paste buffer */
	{
		IT *w;
		STMC *eerste;

		if	( (w=editor_window(false,
					" Copy/paste buffer ",
					" ",
					KIND,
					0,
					BUFF,
					shuntmap,
					0L,
					do_tmenu,
					&tmen,
					ed_key,
					close_buf,
					buf_delete,
					text_full,
					txt_timer,
					buf_winit
					)
			   ) eq 0L
			 )
		{
			form_alert(1,frstr(IW));
			eruit(1);
		}
		w->view.sz.w = MAXL;
		w->base=&shunt;
		txtfreebase=stminit(&shunt,   txtfreebase,STMMODE,0,STMS, "Buffer");
#ifdef MNUNDO
		w->old=&oldshunt;
		txtfreebase=stminit(&oldshunt,txtfreebase,STMMODE,0,STMS, "Buffer_undo");
#endif
		w->map = Fload(buffn.s,nil,&w->mapl, AH_BUFFER);
		if (w->map)
			make_lines(w);
		else
		{
			eerste=stminsert(&shunt,FIRST);
			eerste->xtx=shuntmap;
			eerste->x_l=0;
			eerste->xrm=0;
			eerste->xfg=ISMAP;
		}
		renum(w);
	}
}

static short crich=0;

static
STMC *ficha(STMDEF *d)
{
	STMC *s;

	while ( (s = (crich ? stmfinext(d) : stmfiprior(d)) ) ne 0L)
		if (s->xfg&ISMOD)
			break;
	if (!s)
		crich^=1;
	return s;
}

static
void do_ficha(IT *w)
{
	STMC *s;

	if (!w->vc.pos.y)
		w->vc.pos.y=w->cu.pos.y;

	s=find_line(w,w->vc.pos.y);

	if ( (s=ficha(w->base)) eq 0L)
		if ( (s=ficha(w->base)) eq 0L)
		{
			ping;			/* no changes */
			return;
		}
	w->vc.pos.y=s->xn - 1;
	showchange=true;
	if (!make_visible(w,w->vc, false))
		do_redraw(w,w->wa);	/* if allready visible display now for
								the grey boxes */
	showchange=false;
	w->vc.pos.y=w->norm.pos.y;
	if (crich)
		w->vc.pos.y+=w->norm.sz.h;
}

static
bool is_changed(IT *w,bool *modified)
{
	STMDEF *m;
	STMC *s;
	char *b;

	m = w->base;
	if (!m)
	{
		*modified = false;	/* cached file */
		return false;		/* cannot have been changed */
	}

	b = w->map;
	s = stmfifirst(m);

	while (s)
	{
		if (s->xfg&ISMOD)
			break;
		s = stmfinext(m);
	}

	*modified = s ne 0L;

	if (s and !b)			/* modifications have been made */
		return true;		/* but there is no map to compare with */

	if (s and b)			/* modifications have been made */
	{						/* and there is a map to compare with */
		s = stmfifirst(m);
		while (s)
		{
			if ( strncmp(b, s->xtx, s->x_l) ne 0)
				return true;

			b += s->x_l;

			if (*b)
				return true;

			b++;

			if ((s->xfg & SGL_0) eq 0)
				if (*b eq 0) b++;				 /* allow for for \r &| \n */

			s = stmfinext(m);
		}
	}
	return false;		/* unchanged */
}

global
bool check_modified(char *fn)
{
	bool modified;
	IT *w = get_fn_it(fn);

	if (w and is_changed(w, &modified))
		return true;			/* open and modified */

	return false;
}

#ifdef MNUNDO
global
void to_undo(IT *w,STMC *s)
{
	STMDEF *m;
	STMACC acc=FIRST;
	STMC *cur;
	if (w)
	{
#if BIP_CC
		clear_help_stack();				/* cancel UNDO of HELP */
#endif
		m=w->old;
		if (	!m					/* no UNDO for this window */
			or (s->xfg&IN_UNDO)		/* allready in undo buffer */
			or  s->xun eq 0)		/* new inserted line */
			return;

		cur=stmfi_un(m,s->xun);		/* find undo nummer */
		if (cur)					/* if not empty anders FIRST */
		{
			if (s->xun > cur->xun)
				acc=NEXT;
			else
				if (s->xun < cur->xun)
					acc=PRIOR;
#if INTERNAL
				else	/* equal mag niet voorkomen want is al IN_UNDO */
				{
					form_alert(1,"[1][|Internal error: | unflagged in undo ][ Ok ]");
					acc=-1;
				}
#endif
		}

		if (acc > 0)
			if ( (cur = copy_1(m,s,0,s->x_l,-acc)) ne nil)	/* -acc do not force alloc of s->xtx */
			{									/* !!!! 9'97 !!!! afgeschaft; Gaat helemaal fout bij collect etcetera. */
				cur->xn=s->xn;
				cur->xun=s->xun;

/* The allocation of ISMOD here CAN NOT replace the others
	in this program because everything must work INDEPENDENT of
	whether there is an undo facility AT ALL.
	These are only for completeness.
*/
				s->xfg|=IN_UNDO|ISMOD;
				cur->xfg|=ISMOD;		/* for preservation later */
				stmfinext(m);
			}
	}
}

global
void cursor_undo(IT *w)	/* save */
{
	w->u.cu=w->cu;
	w->u.ss=w->ss;
	w->u.se=w->se;
	w->u.top=w->norm.pos.y;
	w->u.selty=w->selty;
	w->undone=false;

	if (w->title.u ne ' ')
	{
		w->title.u=' ';
		wi_title(w);
	}

}

global
void empty_undo(IT *w)
{
	if (w->old)
	{
		STMDEF *d=w->old;
		STBASE *b=&d->us;

		if (b->f and b->l)
		{
			STMDEF *m=w->base;
			STMC   *s;

			clear_undo(w);
			s=stmfifirst(m);
			while (s)
			{
				s->xfg&=~IN_UNDO;
				s->xun=s->xn;
				s=stmfinext(m);
			}
		}
		cursor_undo(w);			/* save internal state for later undo */
	}
}

static
void undo_cursor(IT *w)			/* restore */
{
	CINF  ex ;
	STMNR exl;
	short exi;

	ex     =w->cu;
	w->cu  =w->u.cu;
	w->u.cu=ex;

	ex     =w->ss;
	w->ss  =w->u.ss;
	w->u.ss=ex;

	ex     =w->se;
	w->se  =w->u.se;
	w->u.se=ex;

	exl           = w->norm.pos.y;
	w->norm.pos.y = w->u.top;
	w->u.top = exl;

	exi      =w->selty;
	w->selty =w->u.selty;
	w->u.selty=exi;

	w->undone = !w->undone;
	w->title.u=w->undone ? 'U' : ' ';
	w->title.x='*';
	wi_title(w);
}
#else
global
void clear_undo (IT *w) {}
global
void cursor_undo(IT *w) {}
global
void empty_undo (IT *w) {}
static
void undo_cursor(IT *w) {}
static
void to_undo(IT *w,STMC *s)	{}
#endif

static
void un_nl(IT *w, bool un_flag)
{
	STMDEF *m=w->base;
	STMC *s=stmfifirst(m);

	while (s)
	{
		char *u=s->xtx+s->x_l;
		if (un_flag)
			s->xfg&=~(ISMOD|IN_UNDO);
		if (s->xfg&ISMAP)			/* also if NOT collected */
		{
			if (*u eq '\r') *u++=0;
			if (*u eq '\n')	*u=0;
		}
		s=stmfinext(m);
	}
	if (un_flag)
	{
		w->title.x=' ';
		w->title.u=' ';
		wi_title(w);
		clear_undo(w);
	}
}

static
bool collect(IT *w)			/* new length in w->mapl, newmap in w->map */
{
	STMC *s,*last;
	STMDEF *m = w->base;
	long l;
	STMNR ls;
	char *c, *newmap;

	l = stmrenum(m, &ls);
	l += (ls - 1) * 2;				/* for \r\n */

	if ( ( newmap = fmalloc(l + 3, AH_COLLECT)) <= 0L)
	{
		alertm("newmap %lx", newmap);
		newmap = 0L;		/* No room for garbage collection */
	}
	else					/* can collect the chain into a single string
								(much faster type of write possible) */
	{
		c = newmap;
		last = stmfilast (m);
		s    = stmfifirst(m);
		while (s)
		{
			short ln = 0;
			char *d = s->xtx;
			char *new_user = c;

			while (*d)
				*c++ = *d++, ln++;

			if (w->loc.trail)			/* remove trailing space ? */
				while (ln > 0)
				{
					char e = *(c-1);
					if (e ne ' ' and e ne '\t')
						break;
					c--, ln--;
				}

			if (s ne last)
			{
				if (w->crlf)
					*c++ = '\r';				/* for fast write, remove later */
				*c++ = '\n';
			}

			if (!(s->xfg & ISMAP))
				free(s->xtx);

			s->xtx =new_user;
			s->xfg |= ISMAP;			/* retain modified status until unflag() */
			s->x_l  = ln;				/* converge to consistancy */
			s->xrm = 0;
			s = stmfinext(m);
		}

		clear_undo(w);		/* may contain s->xtx that lies within w->map */

		if (w->map)
			ffree(w->map);
		w->map=newmap;
		l = c - newmap;
		w->mapl = l;
		w->map[l]=0;
	}
	return newmap ne 0L;
}

global		/* Used by find_multiple & find_project
				also used by Cload if in shell */
char *condense(IT *w, long *mapl, void *base)		/* essentially a 'collect' with throw away result */
{
	STMC *s;
	STMDEF *m=w->base;
	long l;
	STMNR ls;
	char *c,*newmap;

	*mapl = 0;
	l=stmrenum(m,&ls);
	l+=(ls-1)*2;				/* for \r\n */

	if (base eq nil)
		base = &XA_file_base;

	newmap=XA_alloc(base, l+3, nil, AH_CONDENSE, -1);
	if (newmap)
	{
		c=newmap;
		s=stmfifirst(m);

		while (s)
		{
			char *d=s->xtx;

			while (*d)
				*c++=*d++;
			if (w->crlf)
				*c++='\r';				/* try make it real */
			*c++='\n';
			s=stmfinext(m);
		}
		l = c - newmap;
		*mapl=l;
		newmap[l]=0;
	}
	return newmap;
}

global
void savefile(IT *w,char *fn,bool force)
{
	bool modified,changed;

	if (!w)
		return;

	if (!w->base)		/* is internally created, must save, */
	{					/* and doesnt need collection */
		long c = Fdump(fn,&w->fl,w->mapl,w->map);
		if (c ne w->mapl)
			alertm(frstr(FNW), fn);
		return;
	}

	changed=is_changed(w,&modified);

	if (!changed and !force)
	{
		if (modified)
		{
			do_ficha(w);
			alertm(frstr(ALMOD));
		}
	othw
		empty_undo(w);
		if (modified or force)
		{
			if (collect(w))		/* that means bitmap is fragmented */
			{					/* and now there was room for collection */
				if (Fdump(fn,&w->fl,w->mapl,w->map) eq w->mapl)
					un_nl(w, true);		/* + un_flag */
				else
					un_nl(w, false);
				if (w->wh > 0 and w->op)
					do_redraw(w,w->wa);
				return;
			}
			/* There was no room to collect the chain into a single string */
			if (write_out(w, fn))
				un_nl(w, true);		/* + un_flag */
			else
				un_nl(w, false);
		}
	}
}

global
bool savesfile(IT *w)
{
	if (w)
	{
		char *fn;

		fn = select_file(&idir, nil, &fsel, " Save text file as ... ", &drive);

		if (fn)
		{
			savefile(w, fn, true);		/* true = force */
			if (w->ty ne BUFF and w->ty ne JRNL)
			{
				strcpy(w->title.t, fn);
				wi_title(w);
			}
			return true;
		}
	}
	return false;
}

global
void abandonfile(IT *w)
{
	bool modified;

	if (w)
		if (is_changed(w,&modified))
		{
			do_ficha(w);
			if (form_alert(1,frstr(ABCHA)) eq 1)
			{
				STMDEF *m=w->base;
				clear_undo(w);
				w->title.x=' ';
				w->title.u=' ';
				wi_title(w);
				via (w->deselect)(w,LOW);
				clearmal(m);
				stmclear(m);
				make_lines(w);
				renum(w);		/* mainly for avrg */
				w->norm.pos.y = 0;
				w->cu=c1st;
				do_redraw(w,w->wa);
				cur_on(w);
			}
		othw
			w->title.x=' ';
			wi_title(w);
		}
}

global
bool check_save(IT *w)
{
	bool modified;

	if (is_changed(w,&modified))
	{
		do_ficha(w);
		switch(form_alert(1,frstr(ALCHA)))		/* 2 in testfase anders 1 (Save) */
		{
		case 1:
			if (w->fl > 0 and !(w->ty eq BUFF or w->ty eq JRNL))
				savefile(w, w->title.t, true);
			else
				return savesfile(w);
		case 2:
			return true;			/* close without save */
		case 3:
			return false;			/* cancel */
		}
	}
	return true;		/* yes can close */
}

static
bool copy_txt(STMC *s,short l)		/* does not change the text */
{
	char *c,*d=s->xtx;

	if ( (c = mmalloc(l+1, "while inserting", ign, AH_COPY_TEXT)) <= 0L)
		return false;

	strcpy(c,d);
	if (!(s->xfg&ISMAP))
		free(s->xtx);
	s->xtx=c;
	s->xrm=l-s->x_l;
	s->xfg&=~ISMAP;
	return true;
}

global
bool split(IT *w,STMC *s,short f,short avrg)		/* s must be current */
{
/*	allways move to undo, also when f=0 or f=s->x_l,
 *	(only empty new line inserted, original line unchanged)
 *	because this line acts as indicater AND synchronizer for undo operation
 */
	char *c,*d;
	short a= s->x_l - f;
	STMDEF *m=w->base;
	STMC *new;

	if ((new=stminsert(m,NEXT)) eq 0L)
		return false;

	if ( (c = mmalloc(a + avrg + 1, "while splitting line",ign,AH_SPLIT_LINE)) <= 0L)
		return stmdelcur(m), false;

	set_X(w);

	to_undo(w,s);
	d = s->xtx + f;
	strcpy(c,d);						/* copy right part */

	if (s->xfg&ISMAP)
		if ( !copy_txt(s,s->x_l) )		/* new 1st line for left part */
			return stmdelcur(m),false;
		else
			*(s->xtx+f)=0;
	else
		*d=0;

	new->x_l  = a;
	s->x_l   -= a;
	s->xrm += a;
	s->xfg|=ISMOD;

	new->xtx = c;
	new->xrm = avrg;
	new->xfg = ISMOD;
	new->xun=0;
	return true;
}

static
short check_l(short l, short avrg)	/* tries to get as many in a line as possible */
{
	if (l > MAXL)
		return alertm(frstr(LLONG),strpar(MAXL)), -1;

	if (l + avrg < MAXL)
		l +=avrg;
	else
		l = MAXL;
	return l;
}

global
bool catenate(IT *w,STMDEF *m,STMC *s,short avrg)		/* s must be current */
{
	short l;
	char *c;
	STMC *nx;

	if (!s->x_l)	/* this line empty; just delete (but mark nx as modified) */
	{
		to_undo(w,s);
		deletecur(m,s);
		nx=stmfinext(m);
		if (!nx)
			nx=stmfilast(m);
		to_undo(w,nx);
		nx->xfg|=ISMOD;
		return true;
	}

	nx = stmfinext(m);

	if (!nx)
	{
		stmfilast(m);
		return false;
	}

	if (!nx->x_l)	/* next line empty; just delete (but mark s as modified) */
	{
		to_undo(w,nx);
		deletecur(m,nx);
		to_undo(w,s);
		s->xfg|=ISMOD;
		return true;
	}
							/* now nx and s are non empty */
	to_undo(w,s);
	to_undo(w,nx);
	if (s->xrm < nx->x_l)		/* in the MAP s->xrm is allways zero */
	{
		if ( (l=check_l(s->x_l + nx->x_l,avrg)) < 0)	/* adds avrg if possible */
			return false;
							/* old line into new */
		if ( (c=mmalloc(l+1,"while catenating lines",ign,AH_CREATE_LINE)) <= 0 )
			return false;

		strcpy(c,s->xtx);
		if (!(s->xfg&ISMAP))
			free(s->xtx);
		s->xtx = c;
		s->xfg&=~ISMAP;
		s->x_l += nx->x_l;
		s->xrm = l - s->x_l;
	othw
		c = s->xtx;
		s->x_l   += nx->x_l;
		s->xrm -= nx->x_l;
	}
	strcat(c,nx->xtx);					/* append next line */

	s->xfg |= ISMOD;
	deletecur(m,nx);	/* Note this must still be the obove formerly next */
	return true;
}

global
bool del_ch(IT *w,STMC *s,short f,short i)
{
	char *c,*d;

	if (i)
	{
		to_undo(w,s);
		if (s->xfg&ISMAP)
			if ( !copy_txt(s,s->x_l) )
				return false;
		d=s->xtx+f;
		c=d+i;
		while ( (*d++ = *c++) ne 0);	/* incl NL */
		s->x_l-=i;
		s->xrm+=i;
		s->xfg|=ISMOD;
	}
	return true;
}

static
bool delete_tail(IT *w)
{
	bool ok = true;
	short l;
	STMC *s = find_current_line(w);			/* because after make visible */
	l = strlen(w->line + w->cu.pos.x);
	if (l)
	{
		set_X(w);
		ok = del_ch(w,s,w->cu.pos.x,l);		/* incl to_und() */
		(*w->disp)(w,s,HIDE);			/* + hidem; */
	}
	return ok;
}

static
bool delete_front(IT *w)
{
	bool ok = true;
	STMC *s = find_current_line(w);				/* because after make visible */
	if (w->cu.pos.x)
	{
		set_X(w);
		ok = del_ch(w,s,0,w->cu.pos.x);		/* incl to_und() */
		w->cu.pos.x = 0;
		x_to_s_t(w,&w->cu);
		(*w->disp)(w,s,HIDE);			/* + hidem; */
	}
	return ok;
}

global
short _del_(IT *w, CINF ds, CINF de)
{
	STMDEF *m = w->base;
	STMC   *s = find_line(w,ds.pos.y);

	set_X(w);
	if (ds.pos.y eq de.pos.y and *(s->xtx+ds.pos.x) )
	{
		if ( !del_ch(w,s,ds.pos.x,de.pos.x-ds.pos.x) )
			return 0;
		return 1;
	othw
		short i=ds.pos.y;
		if ( !del_ch(w,s,ds.pos.x,s->x_l-ds.pos.x) )
			return 0;
		i++;
		if ( (s=stmfinext(m)) ne 0L)
		{
			while (s and i < de.pos.y)
			{
				to_undo(w,s);
				deletecur(m,s);
				s=stmfinext(m);
				i++;
			}
			if (s)
				if ( del_ch(w,s,0,de.pos.x) )
				{
					s=stmfiprior(m);
					catenate(w,w->base,s,w->avrg);
				}
		}
	}
	renum(w);
	return 2;
}

global
bool delete(IT *w)
{
	bool sel = w->selection;
	STMC *s;
	CINF ds,de;

	if (w->selection)
	{
		ds=w->ss;
		de=w->se;
		via (w->deselect)(w,LOW);
	othw
		ds=w->cu;
		de=cnil;
	}

	set_X(w);

	s=find_line(w,ds.pos.y);	/* because after make visible */

	if (!sel)		/* 1 ch  */
	{
		if (*(s->xtx+ds.pos.x) ne 0)
		{
			if ( !del_ch(w,s,ds.pos.x,1) )		/* incl to_und() */
				return false;
			(*w->disp)(w,s,HIDE);		/* + hidem; */
		othw				/* delete NL: catenate line with next */
			if (catenate(w,w->base,s,w->avrg))
			{
				renum(w);
				w->norm.pos.y = bounce(w,w->norm.pos.y);
				via (w->slider)(w);
				do_redraw(w,w->wa);
			}
		}
	othw		/* delete selection */
		short dr = _del_(w, ds, de);
		if (dr eq 1)					/* only within a single line */
			(*w->disp)(w,s,HIDE);		/* + hidem; */
		elif (dr eq 2)
		{
			w->norm.pos.y = bounce(w,w->norm.pos.y);
			via (w->slider)(w);
			do_redraw(w,w->wa);
		}
	}
	return true;
}

global
bool insert(IT *w,STMC *s,short f,short i,short code,short avrg)
{
	short l;
	if (i)
	{
		set_X(w);
		to_undo(w,s);
		if (i > s->xrm)		/* no space in line (in ISMAP is never space) */
			if ( (l=check_l(s->x_l+i,avrg)) < 0)	/* adds avrg if possible */
				return false;
			else
				if ( copy_txt(s,l) eq 0L)	/* alloc new larger line */
					return false;
		if (code&0xff)
		{
			short j  =s->x_l-f+i;		/* move incl NL */
			char *c=s->xtx+s->x_l;
			char *d=c+i;
			while(j--)
				*d--=*c--;
			*(s->xtx+f)=code&0xff;
			s->xrm-=i;
			s->x_l+=i;
			s->xfg|=ISMOD;
		}
		else
			return false;
	}
	return true;
}

#define T (unsigned char)

global
EDIT ed_key			/* 	IT *w,short kcode) */	/*	called from cursor.c */
{
	STMC *s;
	bool sel,nl,ok = false;
	short spn=0,
		k  = kcode&0xff;

	if (kcode < 0 and k eq NK_ESC)
	{
		cur_on(w);
		kcode = exotic(w->vhl,&wwa);	/* exotic() has his own inline rsc */
		if (kcode < 0)						/* Cancelled */
			return false;
		cur_off(w);
	}

#ifdef MNUNDO
	if (w->undone)		/* empty undo delayed so undo can be flipflopped */
		empty_undo(w);
#endif

	sel=w->selection ne 0;
	if (!sel)
		make_vis_top(w);

	if (kcode < 0 and k eq NK_BS)
	{
		if (w->cu.pos.y eq 0 and w->cu.pos.x eq 0)
			return false;

		if (!sel)
			txtsel_cursor(w,NK_LEFT|NKF_FUNC);

		delete(w);
		make_vis_top(w);
		return true;
	}

	if (kcode < 0 and (k eq NK_DEL or k eq 0x7f) )	/* 04'16 HR 0x7f for Aranym ? */
	{
		if ((kcode&NKF_CTRL) and !sel)
		{
			if (kcode&NKF_SHIFT)
				delete_front(w);
			else
				delete_tail(w);
		othw
			delete(w);
		}
		make_vis_top(w);
		return true;
	}

	if (sel)
		delete(w);

	s=find_current_line(w);

	nl = k eq NK_RET or k eq NK_ENTER;
	if ( kcode < 0 and nl )
	{
		spn = 0;
		if ( w->loc.ai )				/* if indent */
		{
			char *sp=s->xtx;
			while(spn < w->cu.pos.x)		/* count autospaces */
				if (chcl[T*sp] eq WSP)
					sp++,spn++;
				else
					break;
		}
		ok=split(w,s,w->cu.pos.x,w->avrg+spn);
		renum(w);
	othw
		if (k eq '`' and !(kcode&NKF_ALT))	/* '`' := ':=' */
		{									/* with alternate keep '`' */
			ok=insert(w,s,w->cu.pos.x,2,':',w->avrg);
			if (ok)
			{
				*(s->xtx+w->cu.pos.x+1)=  '=';
				x_to_s_t(w,&w->cu);
				txtsel_cursor(w,NK_RIGHT|NKF_FUNC);
			}
		}
		else
			ok=insert(w,s,w->cu.pos.x,1,kcode,w->avrg);
		x_to_s_t(w,&w->cu);
		(*w->disp)(w,s,HIDE);		/* + hidem; */
	}

	if (ok)
	{
		txtsel_cursor(w,NK_RIGHT|NKF_FUNC);	/* advance cursor */

		if ( nl )	/* if return/enter; indent delayed for correct
						sequence of action (especially CUR_RIHT) */
		{
			if ( w->loc.ai )	/* if indent */
			{
				STMC *nx=find_current_line(w);
				char *sn=nx->xtx;

				if (ok and spn)	/* spn: auto spaces */
				{
					char *sp=s->xtx;
					insert(w,nx,0,spn,'?',w->avrg);	/* dummy kcode <> 0 */
					w->cu.pos.x=spn;
					while (spn--) *sn++=*sp++;	/* fill */
					x_to_s_t(w,&w->cu);
				}
			}
			w->norm.pos.y = bounce(w,w->norm.pos.y);
			via (w->slider)(w);
			do_redraw(w,w->wa);
		}
	}
	return ok;
}

global
bool replace(IT *w, Cstr with, short l)
{
	if (!w->edit)
		alertm(frstr(ROMW));
	else
	if (delete(w) ne 0)
	{
		STMC *s=find_current_line(w);
		if (insert(w,s,w->cu.pos.x,l,'?',w->avrg))	/* may change s->xtx */
		{
			char *sn=s->xtx+w->cu.pos.x;

			w->ss=w->cu;
			w->se=w->cu;

			if (cfg.o.fbck)
				w->cu.pos.x+=l;
			w->se.pos.x+=l;

			while (l--) *sn++=*with++;

			x_to_s_t(w,&w->se);
			x_to_s_t(w,&w->cu);
			x_to_s_t(w,&w->ss);

			if (!make_visible(w, cfg.o.forw ? w->se : w->ss, true))
				(*w->disp)(w,s,HIDE);

			return true;
		}
	}
	return false;
}

#ifdef MNRETAB
#if 0
static
short tabulate(char *t, char *e, short tabn, short maxw)
{
	short i = 0;
	char *to = t, *te = e;

	while (*e and e-te < maxw)
	{
		if (*e ne ' ')
			*t++ = *e;
		else
		{
			bool sp  = true;
			short j  = i;
			char *oe = e;
			while (j < totab(i,tabn) )
			{
				j++;
				if (*oe++ ne ' ')
				{
					sp = false;
					break;
				}
			}

			if (j-i >= tabn and sp)
			{
				*t++ = '\t';
				i = j;
				e = oe;
				continue;
			}
			else
				*t++=*e;
		}
		e++;
		i++;
	}
	*t = 0;
	return t - to;
}
#else
/* tabulate only leading spaces */
static
short tabulate(char *t, char *e, short tabn, short maxw, bool lead)
{
	short i = 0;
	char *to = t, *te = e;
	bool finish = false;

	while (*e and e-te < maxw)
	{
		if (*e ne ' ' or finish)
		{
			*t++ = *e;
			finish = lead;
		}
		else
		{
			bool sp  = true;
			short j  = i;
			char *oe = e;
			while (j < totab(i,tabn) )
			{
				j++;
				if (*oe++ ne ' ')
				{
					sp = false;
					break;
				}
			}

			if (j-i >= tabn and sp)
			{
				*t++ = '\t';
				i = j;
				e = oe;
				continue;
			}
			else
				*t++=*e;
		}
		e++;
		i++;
	}
	*t = 0;
	return t - to;
}
#endif

static
bool re_tab(IT *w, STMC *s)
{
	char *d=s->xtx,*c;
	short l;
	char exp[MAXL+1],tabbed[MAXL+1];

	de_tab(tabbed,d,w->loc.tabp,' ',' ',MAXL+1);
	l = tabulate(exp, tabbed, w->loc.tabn, MAXL+1, w->loc.tabl);
	if (SCMP(1,exp,d) ne 0)
	{
		short sl = s->x_l+s->xrm;
		to_undo(w,s);
		if ((s->xfg&ISMAP) or sl < l )
		{
			if ( (c=mmalloc(l+SHOVERFL+1,"while retabbing",ign,AH_RETAB)) <= 0L)
				return false;
			if (s->xfg&ISMAP)
				free(d);
			strcpy(c,exp);
			s->xtx = c;
			s->xrm=SHOVERFL;
			s->xfg&=~ISMAP;
		othw
			strcpy(s->xtx,exp);
			s->xrm = sl - l;
		}
		s->x_l=l;
	}
	return true;
}
#endif

global
void do_repl(IT *w)
{
	short repl = get_repl();
	Cstr rep = get_repstr(),
		    find = get_fistr(butcur);

	while (dial_find(w,find))
	{
#ifdef MNUNDO
		if (w->undone)		/* empty undo delayed so undo can be flipflopped */
			empty_undo(w);
#endif
		if (!replace(w,rep,repl))
			break;

		if (!is_all() or break_in )
			break;
	}
}

#if SELECTION and defined MTREPAIR
global
void do_Repair(IT *w,short mt,short kstate)
{
	if (!w)
		return;
	repair_various(w,mt);
}
#endif

#if MNFKEYS
/* play the tape! */
global
void insert_fkey(IT *w, short i)
{
	uchar *fro = fkeystr[i];
	CINF save = w->cu;;
	if (*fro)
	{
		while (*fro)
		{
			short key = *fro;
			if (key eq '%')
				save = w->cu;
			else
			{
				if (key eq '\\' and *(fro + 1) eq 'n')
					key = NK_ENTER|NKF_FUNC,
					fro++;
				ed_key(w, key);
			}
			fro++;
		}
		w->cu = save;
	}
}
#endif

static
void change_case(IT *w, char *(*to_case)(char *s))
{
#if 0			/* Not shure if this is something I want */
	if (!w->selection)
	{
		CINF sv = w->cu;
		cur_off(w);
		select_thing(w);
		if (w->selty ne LOWEST_W)
		{
			w->cu = sv;
			w->selection = false;
		}
		else
			via (w->select)(w);
	}
#endif
	if (w->selection)			/* change selection to case reflected by to_case */
	{
		STMC *s;
		short
			fs = w->ss.pos.x,
		    fe = w->se.pos.x;
		long
			e  = w->se.pos.y + 1;

		make_visible(w, w->ss, true);
		s=find_line(w, w->ss.pos.y);

		if (w->se.pos.x eq 0)
			e -= 1;
		while (s->xn <= e)
		{
			if (s->x_l ne 0)
			{
				set_X(w);
				to_undo(w,s);
				if (copy_txt(s, s->x_l))
				{
					char c, *cs = s->xtx + ((s->xn eq e) ? fe : s->x_l);
					c = *cs;
					*cs = 0;
					(*to_case)(s->xtx + fs);
					*cs = c;
				}

				fs = 0;
			}

			s=stmfinext(w->base);
			if (!s) break;
		}

		if (!make_visible(w, w->se, true))
			do_redraw(w, w->wa);
	}
}

#ifdef MNENUM			/* experimentation */

static
char *def(char *s)
{
	static char rstr[IPFF_L + 2];

	ipff_init(0,0,0,nil,s,nil);
	if (sk() eq '#')
	{
		skc(), str(rstr);
		if (SCMP(2,rstr, "define") eq 0)
		{
			sk(), str(rstr);
			sk();
			return rstr;
		}
	}
	return nil;
}

static
void make_typed_enum(STMDEF *d)
{
	long i=0,old=-2;
	STMC *s = stmficur(d);
	char *tnm = def(s->xtx);		/* first define is tree name */
	i = idec();
	if (tnm)
	{
		char etype[128];
		strsncpy(etype, tnm, sizeof(etype));
		send_msg("\n\ntypedef enum\n{\n");
		send_msg("\t%s = %ld,\n", tnm, i);
		s = stmfinext(d);
		while (s)
		{
			char *nm;
			nm = def(s->xtx);
			if (nm)
			{
				i = dec();
				if (i <= old and i > 0)
					break;

				if (i ne old+1)
					send_msg("\t%s = %ld,\n", nm, i);
				else
					send_msg("\t%s,\n", nm);

				old = i;
			}
			s = stmfinext(d);
		}
		send_msg("} E_%s;\n\n", etype);
	}
}

static
void make_enum(STMDEF *d)
{
	long i=0,old=-2;
	STMC *s = stmficur(d);

	send_msg("\n\nenum\n{\n");

	while (s)
	{
		char *nm;
		nm = def(s->xtx);
		if (nm)
		{
			i = dec();
			if (i ne old+1)
				send_msg("\t%s = %ld,\n", nm, i);
			else
				send_msg("\t%s,\n", nm);

			old = i;
		}
		s = stmfinext(d);
	}
	send_msg("};\n\n");
}

#endif

global
void do_Edit(IT *w,short mt,short kstate)
{
	if (w)
		switch (mt)
		{
		#ifdef MNUNDO
			case MNUNDO:
#if defined MTPRJ && defined BIP_CC
			if (help_stack)
				restore_help_stack(w);
			else
#endif
			if (w->old)
			{
				STMDEF *m,*b=w->old;
				STMC   *s,*u=stmfifirst(b);
				STMNR
					m_un,b_un,	/* existing undo numbering */
					s_nr,s_un;	/* new numbering */

				if (!u)			/* undo empty: nothing to undo */
					break;

				m=w->base;
				s=stmfifirst(m);
				m_un=high(s);
				b_un=high(u);
				s_nr=1;
				s_un=1;

/* Exchange differences between m and b by means of classic collate */

				while (!(    m_un eq HIGH_VAL
					     and b_un eq HIGH_VAL)
					  )
				{
					if (!m_un)	/* inserted after last mouseclick */
					{
						STMFMODE acc = PRIOR;
						while (s and !m_un)
						{
							stmmove(b, m, acc);		/* move to undo */
							acc = NEXT;
							s->xun = s_un++;
							s = stmfinext(m);
							m_un = high(s);
						}
						stmfinext(b);			/* back to current b */
					}
					else
					if (m_un < b_un)
					{
						s->xn  = s_nr++;		/* keep numbering */
						s->xun = s_un++;
						s = stmfinext(m);		/* next m */
						m_un = high(s);
					}
					else
					if (m_un eq b_un)	/* exchange */
					{
						unsigned char
							sv_m=s->xfg&(~ISMAP),
							sv_b=u->xfg&(~ISMAP),
							sv_mm=s->xfg&ISMAP,
							sv_bm=u->xfg&ISMAP;
						stmmove(b,m,PRIOR);
						stmfinext(b);		/* orig b */
						stmmove(m,b,NEXT);
	/* now NB that s is now u and u is now s */
						s->xfg = sv_b|sv_mm;	/* retain flags, but inherit ISMAP */
						u->xfg = sv_m|sv_bm;
						s->xun = s_un;
						u->xun = s_un++;
						u->xn  = s_nr++;
						u = stmfinext(b);		/* next b */
						b_un = high(u);
						s = stmfinext(m);		/* next m */
						m_un = high(s);
					}
					else
					if (m_un > b_un)
					{
						STMFMODE acc = PRIOR;
						while (u and m_un > b_un)
						{
							stmmove(m, b, acc);
							acc = NEXT;
							u->xn  = s_nr++;
							u->xun = 0;			/* regard as new inserted lines for flip */
							u->xfg&=~IN_UNDO;
							u = stmfinext(b);
							b_un = high(u);
						}
						stmfinext(m);	/* back to current m */
					}
				}		/* while not both high value */

				w->view.sz.h = s_nr - 1;
				via (w->slider)(w);		/* for new w->n */
				undo_cursor(w);
				do_redraw(w, w->wa);
			}
			break;
		#endif
		#ifdef MNCRLF
			case MNCRLF:
				w->crlf = !w->crlf;
				via (w->set_menu)(w);
			break;
		#endif
		#ifdef MNFICHA
			case MNFICHA:
				do_ficha(w);
			break;
		#endif
		#ifdef MNREPL
			case MNREPL:
				kit_dial(w, 1, MNREPL);
			break;
		#endif
		#ifdef MNREPSAM
			case MNREPSAM:
				if (dial_find(w,get_fistr(butcur)))		/* selects when found */
				{
					Cstr rep = get_repstr();
					empty_undo(w);
					cur_off(w);
					replace(w,rep,get_repl());
					cur_on(w);
				}
			break;
		#endif
		#ifdef MNSHL
			case MNSHL:
			if (w->selection)
			{
				STMC *s;
				short j,
				    f = w->ss.pos.x;
				long e = w->se.pos.y + 1;

				empty_undo(w);
				make_visible(w, w->ss, true);
				s=find_line(w, w->ss.pos.y);

				if (w->se.pos.x eq 0)
					e -= 1;
				while (s->xn <= e)
				{
					short i = w->loc.tabs;
					char c, *dc = s->xtx + f;
					j = 0;
					do
					{
						c = *(dc + j);
						if (c eq '\t')
						{
							j++;
							break;
						}
						if (c eq 0 or c ne ' ')
							break;
						else
							j++;
					} while (j < i);

					if (!del_ch(w, s, f, j))
						break;

					f = 0;
					s = stmfinext(w->base);
					if (!s) break;
				}
				if (w->se.pos.x >= j)
					w->se.pos.x -= j;				/* last line */
				x_to_s_t(w, &w->se);
				x_to_s_t(w ,&w->ss);
				via (w->slider)(w);
				do_redraw(w, w->wa);
			}
			break;
		#endif
		#ifdef MNSHR
			case MNSHR:
			if (w->selection)
			{
				STMC *s;
				short f = w->ss.pos.x;
				long e = w->se.pos.y + 1;
				bool endl = w->se.pos.x eq 0;

				empty_undo(w);
				make_visible(w, w->ss, true);
				s=find_line(w, w->ss.pos.y);		/* NB: findline already increses zoek by 1 */

				if (endl)
					e -= 1;
				while (s->xn <= e)
				{
					if (s->x_l ne 0)
						if (!insert(w, s, f, 1, '\t', SHOVERFL))
							break;
					f=0;
					s=stmfinext(w->base);
					if (!s) break;
				}
				if (!endl)
					w->se.pos.x += 1;				/* last line */
				x_to_s_t(w, &w->se);
				x_to_s_t(w, &w->ss);
				via (w->slider)(w);
				do_redraw(w, w->wa);
			}
			break;
		#endif
		#ifdef MNRETAB
			case MNRETAB:
			if (w->selection)
			{
				STMC *s;
				long e = w->se.pos.y + 1;
				bool endl = w->se.pos.x eq 0;

				empty_undo(w);
				make_visible(w, w->ss, true);
				s=find_line(w, w->ss.pos.y);

				if (endl)
					e -= 1;
				while (s->xn <= e)
				{
					re_tab(w, s);
					s=stmfinext(w->base);
					if (!s) break;
				}
				if (!endl)
					w->se.pos.x += 1;				/* last line */
				x_to_s_t(w, &w->se);
				x_to_s_t(w, &w->ss);
				via (w->slider)(w);
				do_redraw(w, w->wa);
			}
			break;
		#endif
		#ifdef MNUPR
			case MNUPR:
				change_case(w, strupr);			/* change selection to upper case */
			break;
		#endif
		#ifdef MNLWR
			case MNLWR:
				change_case(w, strlwr);			/* change selection to lower case */
			break;
		#endif
		#ifdef MNENUM
			case MNENUM:		/* to journal */
			{
				STMDEF *d = w->base;
				if (d)
				{
					STMC *s;
					if (w->selection)
					{
						s = stmfinum(d, w->ss.pos.y);
						if (s)
						{
							char *tree = strstr(s->xtx,  "Formular");
							if (!tree)
								tree = strstr(s->xtx,  "Menuebaum");
							if (tree)
								make_typed_enum(d);
							else
								send_msg("No Formular or Menuebaum selected!\n");
						}
						break;
					othw
						s = stmfifirst(d);
						if (s)
						{
							char *tree;
							tree = strstr(s->xtx, "Resource");
							if (tree)
							{
								stmfinext(d);
								stmfinext(d);
								make_enum(d);
								break;
							}
						}
					}
				}
			}
			send_msg("This might not be a INTRFACE header file\n");
			break;
		#endif
		}
}


