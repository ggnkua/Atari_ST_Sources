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

/* 	CURSOR.C
 *	========
 */

#include <ctype.h>
#include "common/aaaa_lib.h"
#include "common/hierarch.h"

#include "aaaa.h"
#include "common/kit.h"
#include "cursor.h"
#include "text.h"
#include "text_sel.h"
#include "editor.h"
#include "common/cursor.h"

/*  table of character classes, each ch translates to a class.  */
/*  STP		= mostly punctuation */
/*  WSP		= white space */
/*  > WSP	= 'word' --> value */
/* other values: special characters; see <cursor.h> for TRANS_CH */

/*	string tbv AHCX test: })]>{([< */

TRANS_CH chcl[]=
{
	WSP,										/* hex(00) end string */
	STP,STP,STP,STP,STP,STP,STP,				/* hex(01) tm hex(07) */
	WSP,										/* hex(08) tab		 */
	WSP,										/* hex(09) HT		 */
	WSP,										/* hex(0A) LF		 */
	WSP,										/* hex(0B) VT		 */
	WSP,										/* hex(0C) FF		 */
	WSP,										/* hex(0D) CR		 */
	STP,STP,									/* hex(0E) en hex(0F) */
	STP,STP,STP,STP,STP,STP,STP,STP,
	STP,STP,STP,STP,STP,STP,STP,STP,			/* hex(10) tm hex(1F) */
	WSP,										/* hex(20) space	  */
	STP,										/* hex(21)			  */
	QUO,										/* hex(22) quote	  */
	'#',STP,STP,STP,							/* hex(23) tm hex(26) */
	APOS,										/* hex(27)            */
	L_P,R_P,									/* hex(28) en hex(29) () */
	STP,STP,STP,STP,STP,STP,					/* hex(2A) tm hex(2F) */
	'0','1','2','3','4','5','6','7','8','9',	/* hex(30) tm hex(39) */
	STP,STP,									/* hex(3A) en hex(3B) */
	L_H,										/* hex(3C)   < */
	STP,										/* hex(3D) 	 = */
	R_H,										/* hex(3E)   > */
	STP,STP,									/* hex (3F) en hex(40) */
	'A','B','C','D','E','F','G','H',
	'I','J','K','L','M','N',					/* hex(41) tm hex(4E) */
	'O','P','Q','R','S','T','U','V',
	'W','X','Y','Z', 							/* hex(4F) tm hex(5A) */
	L_I,										/* hex(5B)  [ */
	STP,										/* hex(5C)    */
	R_I,										/* hex(5D)  ] */
	STP,										/* hex(5C) */
	'_',										/* hex(5F) */
	STP,										/* hex(60) */
	'a','b','c','d','e','f','g','h',
	'i','j','k','l','m','n',					/* hex(61) tm hex(6E) */
	'o','p','q','r','s','t','u','v',
	'w','x','y','z',							/* hex(6F) tm hex(7A) */
	L_C,										/* hex(7B) { */
	STP,										/* hex(7C)   */
	R_C,										/* hex(7D) } */
	STP,STP,									/* hex(7E) en hex(7F) */

	'€','','‚','ƒ','„','…','†','‡','ˆ','‰','Š','‹','Œ','','Ž','',
	'','‘','’','“','”','•','–','—','˜','™','š',STP,STP,STP,STP,STP,
	' ','¡','¢','£','¤','¥','¦','§',STP,STP,STP,STP,STP,STP,STP,STP,
	'°','±','²','³','´','µ','¶','·','¸',STP,STP,STP,STP,STP,STP,STP,
	/* hebrew translates to lower case alpha and is then displayed bold */
	'À','Á',STP,'a','b','c','d','e','f','g','h','i','j','k','l','m',
	'n','o','p','q','r','s','t','u','v','w','x','y','z',STP,STP,STP,
	STP,STP,STP,STP,STP,STP,STP,STP,STP,STP,STP,STP,STP,STP,STP,STP,
	STP,STP,STP,STP,STP,STP,STP,STP,STP,STP,STP,STP,STP,STP,STP,STP
	/* hex(80) tm hex(FF) */
};

#define T (unsigned char)

global
TIMER txt_timer		/* IT *w */	/* for cursor */
{
	if (w->cup eq ON)
		cur_off(w);
	else
		cur_on(w);
}

global
void x_to_s_t(IT *w, CINF *ci)
{
	if (ci->pos.y > w->view.sz.h - 1)
		ci->pos.y = w->view.sz.h - 1;

#if WINTEXT
	if (is_text(w))
	{
		char *pm,*ps;

		find_line(w,ci->pos.y);		/* sets w->line */

		pm=w->line;
		ps=pm;

		ci->scrx = 0;

		while (pm < ps + ci->pos.x)
		{
			if (*pm eq '\t' and w->loc.tabs)
				ci->scrx = totab(ci->scrx, w->loc.tabs);
			else
				ci->scrx++;
			pm++;
		}
	}
	else
#endif
		ci->scrx = ci->pos.x;
	ci->updn = ci->scrx;
}

global
bool t_to_s_x(IT *w, STMNR cu_y, short to_x, CINF *ci, short rich)
{								/* rich = HIGH : CUR_RIGHT */
								/*   "    LOW  : all other */
	if (to_x < 0)
		return false;			/* scroll! */

	ci->updn  = to_x;
	ci->pos.y = cu_y;

#if WINTEXT
	if (is_text(w))
	{
		short p, c = 1;
		char *pm, *ps;

		to_x++;
		find_line(w,cu_y);
		pm = w->line;
		ps = pm;

		while (     c <  to_x			
		       and  c <=  w->view.sz.w
		       and (p  = *pm) ne 0
		      )
		{
			if (p eq '\t' and w->loc.tabs)
			{
				short t = totab(c-1, w->loc.tabs)+1;

				if ( t > to_x)
				{
					if (rich eq HIGH)
					{
						c = t;		 /* skip over tab */
						ci->updn = t - 1;
						pm++;
					}
					break;			 /* stay  on  tab */
				}
				c = t;
			}
			else
				c++;
			pm++;
		}

		ci->scrx  = c - 1;
		ci->pos.x = pm-ps;			/* physical pos in bitmap */
		return (p ne 0);			/* false for scrolling */
	}
	else
#endif
	/* no text: no weird tabulate thing */
	{
		ci->scrx  = to_x;	
		ci->pos.x = to_x;
		return (ci->pos.x < w->view.sz.w - 1);
	}
}

global
NEXT_CH next_ch			/*	IT *w,CINF *ci	*/
{
	short c;
	STMC *nx;
	STMDEF *d;
	char *p = w->line + ci->pos.x;
	if (ci->pos.y < 0)				/* only when prev_ch was beyond first char */
	{
		*ci=c1st;
		c = *w->line;
	othw
		if (!*p)
		{
			d = w->base;
			if ((nx = stmfinext(d)) eq 0L)
				return FBOUND;			/* allways translates to stopchar */
			ci->pos.y++;
			ci->pos.x = 0;
			p = nx->xtx;
			w->line = p;
			c = *p;
		othw
			ci->pos.x++;
			c = *(p + 1);
		}
	}
	if (!c)
		c = '\n';
	return c;
}

static
NEXT_CH forw_ch		/* stay within line */
{
	short c = *(w->line + ++ci->pos.x);
	if (!c)
		return FBOUND;
	return c;
}

global
NEXT_CH prev_ch
{
	STMC *		nx;
	STMDEF *	d;

	if (ci->pos.x > 0)		/*	if (ci->f-1 >= 0)	*/
		return *(w->line + --ci->pos.x);

	d = w->base;
	ci->pos.y--;
	if ((nx = stmfiprior(d)) eq 0L)
		return ci->pos.y = 0, FBOUND;	/* allways translates to stopchar */
	ci->pos.x = nx->xl;
	w->line = nx->xtx;
	return '\n';
}

static
NEXT_CH back_ch		/* stay within line */
{
	if (ci->pos.x > 0)
		return *(w->line + --ci->pos.x);
	return FBOUND;
}

global
short hook,hooklevel;

global
short is_hook(char *f)
{
	short hook = 0;
	uchar c;

	if   mcmp_lcom(f)
		hook = L_COM;
	elif mcmp_rcom(f)
		hook = R_COM;
	else
	{
		c=chcl[T*f];
		if (c >= L_C and c <= R_C)	/* {([<>])} */
			hook = c;
	}
	return hook;
}

global
bool str_any(IT *w, CINF *cf, SEL_CMP *cmp, NEXT_CH *nxt)
{
	if (   !(*cmp)(w->line+cf->pos.x) )
		return false;

	do
		if ( (*nxt)(w,cf) eq FBOUND)
			return FBOUND;
	while ( (*cmp)(w->line+cf->pos.x) );

	return true;
}

/*
static
bool is_eof(IT *w,CINF *f)
{
	STMC *sf;
	if (f->l eq 1 and f->pos.x eq 0)
		return true;
	if (f->l eq w->n and f->pos.x eq  ????)
		return true;
}
*/

global
void str_surr(IT *w, CINF *fs, CINF *fe, SEL_CMP *cmp)
{
	find_line(w,fs->pos.y);
	str_any(w,fs,cmp,prev_ch);			/* left surround */
	next_ch(w,fs);						/* skip the one not true at left */
	if (fs->pos.y ne fe->pos.y)
		find_line(w,fe->pos.y);
	str_any(w,fe,cmp,next_ch);			/* right surround	*/
}

global
void cat_hash(IT *w, CINF *fs)
{
	CINF tfs;

	if (chcl[T*(w->line+fs->pos.x)] eq '#')
		return;

	tfs = *fs;
	back_ch(w,&tfs);
	str_any(w,&tfs,cmp_space,back_ch);
	if (chcl[T*(w->line+tfs.pos.x)] eq '#')
		*fs = tfs;
}

static
bool str_hash(IT *w, CINF *fs)
{
	bool ok;
	CINF tfs;

	if (chcl[T*(w->line+fs->pos.x)] eq '#')
	{
		ok = forw_ch(w,fs);
		if (ok eq FBOUND)
			return true;
		tfs = *fs;
		str_any(w,&tfs,cmp_space,forw_ch);
		*fs = tfs;
	}
	ok = str_any(w,fs,cmp_word,next_ch);
/*	alert_msg("str_hash | ok %d ", ok);
*/	return ok;
}

global
NEXT_WD next_word	/*	IT *w; CINF *fs,*fe	*/
{
	bool ok;

	str_hash(w,fs);
	ok = str_any (w,fs,cmp_nonw,next_ch);	/* ok for FBOUND */
	if (ok ne FBOUND)
	{
		find_line(w,fs->pos.y);
		*fe = *fs;
		ok  = str_hash(w,fe);
	}
	return ok;
}

global
NEXT_WD prev_word	/*	IT *w; CINF *fs,*fe	*/
{
	bool ok = true;

	ok = prev_ch(w,fs);
	if (ok ne FBOUND)
	{
		if ( !str_any(w,fs,cmp_word,prev_ch) )	/* to start of word if not on */
		{
			str_any(w,fs,cmp_nonw,prev_ch);
			ok=str_any(w,fs,cmp_word,prev_ch);
		}
		if (ok)
		{
			next_ch(w,fs);
			find_line(w,fs->pos.y);
			*fe=*fs;
			ok = str_any(w,fe,cmp_word,next_ch);
			if (ok) cat_hash(w,fs);
		}
	}
	return ok;
}

global
bool do_key(IT *w,short kcode)		/* we know w is open and on top */
{
#ifdef MTEDITOR
	if (w->edit)
	{
		if (w->edit(w,kcode))
			return true;
	}
	else
		alertm(frstr(ROMW));
#endif

	return false;
}
global
BUTTON txt_click		/* w,button,kstate,bclicks,mx,my */
{
	long bx, by;

	xy_to_unit(w, mx, my, &bx, &by);

#if WINTEXT
	if (w->base)
	{
		STMC *curs=find_line(w,by);
		by=curs->xn - 1;		/* if beyond last line in small files */
	}
#endif
	cur_off(w);
	t_to_s_x(w, by, bx, &w->cu, LOW);
	cur_on(w);

	if (kstate&CONTRL)		/* make line top line */
	{
		w->norm.pos.y=by;
		w->norm.pos.y=bounce(w,by);
		via (w->slider)(w);
		cur_off(w);
		do_redraw(w,w->wa);
	}
}

global
KEYBD do_keybd 			/*	w,kcode		*/
{
	cur_off(w);
	if (kcode > 0 or !do_std_cursor(w,kcode))	/* cursor handling */
		 do_key(w,kcode);	/* other keys */
	cur_on(w);
}

global
Cstr compare(Cstr *zmm, Cstr zoek, bool kast)
{
	Cstr zm = *zmm;
	if (kast)
		while (*zoek)
			if ( *zm eq *zoek )
				zm++,zoek++;
			else
				break;	/* while *zoek */
	else
		while (*zoek)
			if ( tolower(*zm) eq tolower(*zoek) )
				zm++,zoek++;
			else
				break;	/* while *zoek */
	*zmm = zm;
	return zoek;
}

/* general find */
global
short Find(IT *w,						/* window info									*/
			Cstr z,						/* primary string    	(OR relations)			*/
			char *zz[],					/* secondary strings	  "      "				*/
			CINF cu,					/* in:  start position of search				*/
			CINF *ss, CINF *se,			/* out: start & end of found					*/
			FIND_OPTIONS *o
/*
			bool word,					/* letters & digits, but starting with a letter */
			bool begins,				/* idem but prefix								*/
			bool ends					/* idem but postfix								*/
			bool kast,					/* case sensitive								*/
			bool forw					/* direction: false = backward					*/
*/		)
{
	STMC *s;
	bool selected, first = true;
	Cstr zm, zocht, zoek, l;
	STMDEF *d;
	CINF ze,zs;

	if (*z eq 0)
		return false;

	selected = false;

	zs = cu;
	d = w->base;

	find_line(w,zs.pos.y);
	l=w->line+zs.pos.x;

	if (o->forw)
		do
		{
			if (o->wrd or o->wpre)
			{
				if (zs.pos.y < 0)
					zs = c1st, l = w->line;
				while (*l and mcmp_word(l))
					l++, zs.pos.x++;

				do				/* now *l is either 0 or non_word */
					if (*l eq 0)
					{
						if ((s = stmfinext(d)) eq nil)
							break;
						zs.pos.y++;
						zs.pos.x = 0;
						l = w->line = s->xtx;
					othw
						if (!first)
							l++, zs.pos.x++;
						else
							first = false;
					}
				while ( mcmp_nonw(l) );
			othw
				if (*l eq 0)		/* end of line */
				{
					if ( (s=stmfinext(d)) eq 0L)
						break;
					zs.pos.y++;
					zs.pos.x = 0;
					l = w->line = s->xtx;
				othw
					if (!first)
						l++, zs.pos.x++;
					else
						first = false;
				}
			}

			zm = l;
			zocht = z;
			zoek = compare(&zm, z, o->csens);
			if (*zoek)	/* z not found */
			{
				if (zz eq nil)
					continue;
				else			/* secondary strings */
				{
					short i = 0;
					while (zz[i])
					{
						zm = l;
						zocht = zz[i++];
						zoek = compare(&zm,zocht,o->csens);
						if (!*zoek)
							break;		/* found one */
					}
					if (*zoek)
						continue;		/* nothing found */
				}
			}

			if (   (!o->wrd or o->wpre)
				or ( o->wrd and mcmp_nonw(zm))
			   )
			{
				selected = true;
				break;
			}
		} while (stmnext(*d) ne (d->cyclic ? stmfirst(*d) : 0L) );
	else			/* BACKWRD */
		do
		{
			if (o->wrd)
			{
				while ( mcmp_word(l) )
					if (zs.pos.x > 0)
						l--,zs.pos.x--;			/* 08'15 v5.3 (was y--) */
					else
						break;

				do
					if (zs.pos.x eq 0)
					{
						zs.pos.y--;
						if ( (s=stmfiprior(d)) eq 0L)
							break;
						zs.pos.x=s->xl;
						l=w->line=s->xtx;
						l+=zs.pos.x;
					othw
						l--;
						zs.pos.x--;
					}
				while ( mcmp_nonw(l) );

				while ( mcmp_word(l) )
					if (zs.pos.x > 0)
						l--,zs.pos.x--;
					else
						break;
				if ( mcmp_nonw(l) )
					l++,zs.pos.x++;
			othw
				if (zs.pos.x eq 0)
				{
					zs.pos.y--;
					if ( (s=stmfiprior(d)) eq 0L)
						break;
					zs.pos.x=s->xl;
					l=w->line=s->xtx;
					l+=zs.pos.x;
				othw
					l--;
					zs.pos.x--;
				}
			}

			zm = l;
			zocht = z;
			zoek = compare(&zm,z,o->csens);
			if (*zoek)	/* z not found */
			{
				if (zz eq nil)
					continue;
				else			/* secondary strings */
				{
					short i = 0;
					while (zz[i])
					{
						zm = l;
						zocht = zz[i++];
						zoek = compare(&zm,zocht,o->csens);
						if (!*zoek)
							break;		/* found one */
					}
					if (*zoek)
						continue;		/* nothing found */
				}
			}

			if (   (!o->wrd and !o->wpre)
				or ( o->wrd and mcmp_nonw(zm))
				or ( o->wpre and mcmp_nonw((l - 1)))
			   )
			{
				selected = true;
				break;
			}
		} while (stmprior(*d) ne (d->cyclic ? stmlast(*d) : 0L));

	if (selected)
	{
		ze=zs;
		ze.pos.x=zs.pos.x+(zoek-zocht);
		x_to_s_t(w,&zs);
		x_to_s_t(w,&ze);
		*ss=zs;
		*se=ze;
	}
	return selected;
}


/*  find & select */
global
bool do_find(IT *w,Cstr z,char *zz[], bool surr, bool rev, FIND_OPTIONS *o)
/* bool word, bool beg, bool kast, bool surr, short forw) */
{
	CINF ss,se;
	CINF cu = w->selection
				? (o->forw
					? w->se
					: w->ss)
				: w->cu;

	if  (Find(w, z, zz, cu, &ss, &se, o))
	{
		via (w->deselect)(w,o->forw);	/* incl actual writing (reverse mode) */
		if ( surr )
		{
			prev_ch(w,&ss);
			str_surr(w,&ss,&se,cmp_space);
			x_to_s_t(w,&ss);
			x_to_s_t(w,&se);
		}
		w->ss=ss;
		w->se=se;
		w->cu = o->forw ? se : ss;
		w->selection = true;
		if (!make_vis_cur(w))
			via (w->select)(w);
		return true;
	othw
		if (rev)
			reverse_rich();
		return false;
	}
}

#if WINTEXT
/* find & select using find-dialogue options */
global
bool dial_find(IT *w, Cstr zoek)
{
	return do_find(w, zoek, nil, cfg.surr, true, &cfg.o);
	/*	cfg.o.wrd, cfg.o.wpre, cfg.o.csens, cfg.surr, cfg.o.forw); */
}
#endif

global
void invoke_cursor(OBJECT *m)
{
#ifdef KIT
	invoke_kit();
#endif

#ifdef MTEDITOR
	invoke_editor(m);
#endif
}
