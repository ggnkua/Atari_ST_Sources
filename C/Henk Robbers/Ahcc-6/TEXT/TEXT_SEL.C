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

/* 	TXT_SEL.C
 *	=========
 */

#include <ctype.h>
#include <string.h>
#include "common/aaaa_lib.h"
#include "common/hierarch.h"

#include "aaaa.h"
#include "common/kit.h"
#include "cursor.h"
#include "text.h"
#include "text_sel.h"
#include "editor.h"
#include "common/cursor.h"

global
XSELECT text_wselect /*   *w,CINF *css,CINF *cse, STMNR top, STMNR bot  */
					 /*             start  -   end        van   -    tot  */
{
	short hl = w->vhl;
	short color = w->color;	/* NB!!!! color other than BLACK does not work well with vswr_mode(3) */
	STMNR sl, el;
	short
		sc, ec, si, ei,

		ww = w->norm.sz.w,
		hw = w->norm.sz.h,

		px,py,px1,py1,px2,py2;

	CINF ss=*css,
		 se=*cse;

	short xplusw=w->ma.x+w->ma.w-1;

	if ( ss.pos.y >= bot )			return;
	if ( se.pos.y <  top )			return;

	if (C_cmp(&ss, &se) >= 0)		return;

	hidem;
	vswr_mode(hl,3);
	vsf_color(hl,color);

	sl=ss.pos.y;
	sc=ss.scrx - w->norm.pos.x;
	el=se.pos.y;
	ec=se.scrx - w->norm.pos.x;

	if (sc < 0 ) sc=0;
	if (sc > ww) sc=0, sl++;
	if (ec <=0 ) ec=ww,el--;
	if (ec > ww) ec=ww;

	if (sl < top    ) sl = top,   sc = 0;
	if (el > bot - 1) el = bot-1, ec = ww;

	si = sl - w->norm.pos.y;
	ei = el - w->norm.pos.y;

	if (si < 0   ) si=0,   sc=0;
	if (ei > hw-1) ei=hw-1,ec=ww;

	px= w->ma.x;
	py= w->ma.y;

	px1=px+(sc*w->unit.w);
	py1=py+(si*w->unit.h);

	px2=px+(ec*w->unit.w)-1;
	py2=py+w->unit.h+(ei*w->unit.h)-1;

	if (ei eq si)
		pbox(hl,px1,py1,px2,py2);	/* fits in 1 line */
	else
	{
		if (sc > 0)
		{			/* incomplete line at top */
			pbox(hl,px1,py1,xplusw,py1+w->unit.h-1);
			px1  = px;
			py1 += w->unit.h;
			si++;
		}
		if ( si ne ei)
		{
			short nl=ei-si;
			if ( ec >= ww )
				nl++;			/* last line complete */
			if (nl)
			{					/* complete lines in between */
				pbox(hl,px1,py1,xplusw,py1+nl*w->unit.h-1);
				py1+=nl*w->unit.h;
				si+=nl;
			}
		}
		if ( si eq ei )			/* incomplete line at bottom */
			pbox(hl,px1,py1,px2,py2);
	}

	vsf_color(hl,0);
	vswr_mode(hl,1);
	showm;
}

global
SELECT text_select	/*	IT *w */
{	if ( w->selection and w->wselect)
		(*w->wselect)(w,&w->ss,&w->se,w->norm.pos.y,w->norm.pos.y+w->norm.sz.h);
	else
		cur_on(w);
}

global
DESELECT text_deselect		/*  IT *w,CUR_TO rich	 rich is LOW or HIGH */
{	if ( w->selection)
	{
		text_select(w);		/* ontschrijf */
		if (rich eq LOW)
			w->cu=w->ss;
		else
			w->cu=w->se;
		w->ss=cnil;
		w->se=cnil;
		w->selection = false;
	othw
		cur_off(w);
	}
}

global
SEL_CMP cmp_space { return chcl[T*f] eq WSP;  }
static
SEL_CMP cmp_quo   { return chcl[T*f] eq QUO;  }
static
SEL_CMP cmp_apos  { return chcl[T*f] eq APOS; }
static
SEL_CMP cmp_L_C   { return chcl[T*f] eq L_C;  }
static
SEL_CMP cmp_L_P   { return chcl[T*f] eq L_P;  }
static
SEL_CMP cmp_L_I   { return chcl[T*f] eq L_I;  }
static
SEL_CMP cmp_L_H   { return chcl[T*f] eq L_H;  }
static
SEL_CMP cmp_R_C   { return chcl[T*f] eq R_C;  }
static
SEL_CMP cmp_R_P   { return chcl[T*f] eq R_P;  }
static
SEL_CMP cmp_R_I   { return chcl[T*f] eq R_I;  }
static
SEL_CMP cmp_R_H   { return chcl[T*f] eq R_H;  }
global
SEL_CMP cmp_nonw  { return chcl[T*f] <  LOWEST_W; }
global
SEL_CMP cmp_word  { return chcl[T*f] >= LOWEST_W; }
static
SEL_CMP cmp_L_COM { return (mcmp_lcom(f) or mcmp_ncom(f)); }		/* // comment */
static
SEL_CMP cmp_R_COM { return (mcmp_rcom(f) or mcmp_ncom(f)); }
static
SEL_CMP cmp_N_COM { return mcmp_ncom(f); }
static
SEL_CMP cmp_other
{
	uchar c = chcl[T*f];
	return (   (c) < LOWEST_W
		   and is_hook(f) eq 0
		   and (c) ne WSP
		   and (c) ne QUO
		   and (c) ne APOS);
}

static
SEL_CMP cmp_hook
{
	short c = is_hook(f);

	if   ( c eq             hook  )
		hooklevel++;
	elif ( c eq (HIGHHOOK - hook) )
		hooklevel--;

	return (hooklevel eq 0) ? true : false;
}

#define noSHOOKS

#ifdef SHOOKS
char *hks[]=
{
	"",
	"#if",
	"do",
	"if",
	"case",
	"begin",
	"6",
	"7",
	"8",
	"9",
	"10",

	"-10",
	"-9",
	"-8",
	"-7",
	"-6",
	"end",
	"esac",
	"fi",
	"od",
	"#endif",
};
#endif

global
HOOKS hooks[N_WH];

static
short srch_whook(bool r, char *fs, char *fe)
{
	short i;

	loop(i,N_WH)
	{
		char *s = r ? hooks[i].swl : hooks[i].swr;	/* r: left or right */
		if (!*s)
			break;
		else
		{
			char *f = fs;
			while (*s ne 0 and (f ne fe or *s eq '*') )
			{
				if (*s eq '*')
					return i + 1;
				if (chcl[T*f] eq WSP)	/* this is for #   if   etc */
					f++;
				else
				{
					if (cfg.hookscase)
					{
						if (*s ne *f)
							break;
					othw
						if (tolower(*s) ne tolower(*f))
							break;
					}
				}
				s++,f++;
			}
			if (*s eq 0 and f eq fe)
				return i + 1;
		}
	}
	return 0;
}

static
short is_whook(char *fs, char *fe)
{
	short hk =     srch_whook(1,fs,fe);				/* left */
	if (!hk)
		if ( (hk = srch_whook(0,fs,fe)) ne 0)		/* right */
			hk = HIGH_WH - hk;
#ifdef SHOOKS
	if (hk)
		alert_msg(" %d | hk: %s | level %d | %s ",
			hk,hks[hk],hooklevel,fs);
#endif
	return hk;
}

static
SEL_WCMP cmp_whook
{
	short c = is_whook(fs,fe);

	if   (c eq            hook  )
		hooklevel++;
	elif (c eq (HIGH_WH - hook) )
		hooklevel--;

	return (hooklevel eq 0) ? true : false;
}

static
bool find_any(IT *w,SEL_CMP *cmp,NEXT_CH *nxt)
{
	while ( !(*cmp)(w->line+w->cu.pos.x) )
		if ( (*nxt)(w,&w->cu) eq FBOUND)
			return FBOUND;

	return true;
}

static
bool str_hook(IT *w,CINF *cf, SEL_CMP *cmp,NEXT_CH *nxt)
	/* N.B. left  hook is including hooks
			right hook is excluding hooks
				(needed more code if I wanted to avoid the latter) ;-)
				Turn a surprising effect into a convenience.
	*/
{
	while ( !(*cmp)(w->line+cf->pos.x) )
		if ( (*nxt)(w,cf) eq FBOUND)
			return false;
	cf->pos.x++;
	return true;
}

static
bool str_whook(IT *w,CINF *fs,CINF *fe,SEL_WCMP *cmp,NEXT_WD *nxt)
{
	while ( !(*cmp)(w->line + fs->pos.x, w->line + fe->pos.x) )
		if ( (*nxt)(w,fs,fe) eq FBOUND)
			return FBOUND;

	return true;
}

static
char *whty_to_str(short sel)
{
	short i = sel;
	if (i > TY_WH)
		i-=TY_WH;
	if (i < 1 or i > HIGH_WH)
		return "no whook";
	if (i > N_WH)
		return hooks[HIGH_WH - i - 1].swr;
	else
		return hooks[          i - 1].swl;
}

static
bool find_whook(IT *w, short sel, NEXT_WD *nxt)
{
	CINF fs = w->cu,
	     fe;

	while ((*nxt)(w,&fs,&fe) ne FBOUND)
		if (is_whook(w->line + fs.pos.x, w->line + fe.pos.x) eq sel)
			return w->cu = fs, true;
	ping;
	return false;
}

static
bool str_ncom(IT *w, CINF *fs, CINF *fe)
{
	*fe = *fs;
	fe->pos.x = strlen(w->line);	/* select upto end of line */
	return true;			/* always possible */
}

static
bool str_quote(IT *w, CINF *fs, CINF *fe, char quo)	/* per definition within 1 line */
{
	short l = fs->pos.x + 1;
	char *s = w->line + l;

	while (*s)
		if (chcl[T*s] eq quo)
			break;
		else
			s++,l++;
	if (*s)
	{
		fe->pos.x = l + 1;
		return true;		/* found 1 on right */
	}

	l = fs->pos.x;
	s = w->line + l - 1;
	while (l)
		if (chcl[T*s] eq quo)
			break;
		else
			s--,l--;
	if (l)
	{
		fs->pos.x = l;
		return true;
	}
	return false;
}

static
void get_htmh(IT *w, CINF ss, CINF se)
{
	char *to = w->html;
	if (se.pos.x - ss.pos.x > sizeof(w->html)-1)
		se.pos.x = ss.pos.x + sizeof(w->html)-1;
	while (ss.pos.x ne se.pos.x)
		*to++ = *(w->line + ss.pos.x), ss.pos.x++;
	*to = 0;
}

short cmpl(const char *s1, const char *s2, short l);

static
void right_html(IT *w, CINF fs, CINF *fe)
{
	short l = strlen(w->html);
	short lvl = 0;
	do{
		while ( !cmp_L_H(w->line+fs.pos.x) )
			if ( next_ch(w,&fs) eq FBOUND)
				return;
		if (	*(w->line + fs.pos.x+1) eq '/'
			and cmpl(w->line + fs.pos.x+2, w->html, l) eq 0
			and cmp_R_H(w->line + fs.pos.x+l+2)
			)
		{
			fs.pos.x+=l+3;
			if (lvl eq 0)
			{
				*fe = fs;
				break;
			}
			else
				lvl--;
		othw
			if (	cmpl(w->line + fs.pos.x+1, w->html, l) eq 0
				and !cmp_word(w->line + fs.pos.x+l+1)
				)
				lvl++;
			fs.pos.x++;
		}
	}od				/* do not change fe when nothing found :-) */
					/* then the plain <...> will remain selected */
}

static
void left_html(IT *w, CINF *fs, CINF fe)
{
	short l = strlen(w->html);
	short lvl = 0;
	do{
		while ( !cmp_L_H(w->line+fe.pos.x) )
			if ( prev_ch(w,&fe) eq FBOUND)
				return;

		if (	cmpl(w->line + fe.pos.x+1, w->html, l) eq 0
				and !cmp_word(w->line + fe.pos.x+l+1)
			)
		{
			if (lvl eq 0)
			{
				fe.pos.x+=l+1;
				while (	!cmp_R_H(w->line+fe.pos.x)
						and !cmp_L_H(w->line+fe.pos.x) )
					next_ch(w,&fe);
				next_ch(w,&fe);
				*fs = fe;
				break;
			}
			else
				lvl--;
		othw
			if (	*(w->line + fe.pos.x+1) eq '/'
				and cmpl(w->line + fe.pos.x+2, w->html, l) eq 0
				and cmp_R_H(w->line + fe.pos.x+l+2)
				)
				lvl++;
			prev_ch(w,&fe);
		}
	}od				/* do not change fs when nothing found :-) */
					/* then the plain <...> will remain selected */
}

global
bool select_thing(IT *w)
{
	bool selected = false;		/* deselect already done */
	CINF fs, fe, tfs, tfe;
	short sty = -1;

	find_current_line(w);				/* synchronize; ensure w->line is set correctly */

	fs = w->cu;
	fe = w->cu;

	hooklevel = 0;
	hook = is_hook(w->line + fs.pos.x);			/* select between hooks */

	selected = hook ne 0;
	if ( selected )
	{
		selected = hook <= L_HLEFT
					? str_hook(w, &fe, cmp_hook, next_ch)
					: str_hook(w, &fs, cmp_hook, prev_ch);
		if (hook eq R_COM)
			fe.pos.x -= 1, fs.pos.x += 1;				/* hack for right comment */
		sty = hook;
/* < implementation of html hooks (preliminary) */
		if (hook eq L_H or hook eq R_H)		/* < or > */
		{
			tfs = fs, tfe = fe;
			if (hook eq L_H and *(w->line + fs.pos.x+1) ne '/')
			{
				if (next_word(w,&tfs,&tfe))
				{
					get_htmh(w, tfs, tfe);		/* remember word in w->html */
					tfs = fe;
					right_html(w, tfs, &fe);
				}
			}
			elif (hook eq R_H and *(w->line + fs.pos.x) eq '/')
				if (next_word(w,&tfs,&tfe))
				{
					get_htmh(w,tfs,tfe);		/* remember word in w->html */
					prev_ch(w,&fs);
					fe = fs;
					left_html(w,&fs,fe);
				}
		}
/* > */
	}
	elif (chcl[T*(w->line+fs.pos.x)] eq QUO)
		selected = str_quote(w,&fs,&fe,QUO ), sty = QUO;
	elif (chcl[T*(w->line+fs.pos.x)] eq APOS)
		selected = str_quote(w,&fs,&fe,APOS), sty = APOS;
	elif (cmp_N_COM(w->line+fs.pos.x))						/* // comment */
		selected = str_ncom(w, &fs, &fe), sty = N_COM;
	elif ((selected = str_any(w,&fs,cmp_word,prev_ch))
			ne 0 )							/* select word */
	{
		next_ch(w,&fs);						/* skip the one not true at left */
		if (fs.pos.y ne fe.pos.y)
			find_line(w,fe.pos.y);
		str_any(w,&fe,cmp_word,next_ch);
		cat_hash(w,&fs);
		if (( hook = is_whook(w->line + fs.pos.x, w->line + fe.pos.x))
				ne 0 )
		{
			if (hook < N_WH)		/* hook is static for use by cmp_whook() */
			{
				tfs = fs;
				selected = str_whook(w,&tfs,&fe,cmp_whook,next_word);
			othw
				tfs = fs;
				tfe = fe;
				fe  = fs;
				selected = str_whook(w,&tfs,&tfe,cmp_whook,prev_word);
				fs = tfe;
			}
			sty = hook + TY_WH;
			if (selected eq FBOUND)
				selected = false;
		othw
			sty = LOWEST_W;
#if 0
			if (*(w->line+fe.pos.x) eq 0)	/* word at end of line ? */
			{
				if (fs.pos.x > 0 and cmp_space(w->line+fs.pos.x-1))
					fs.pos.x--;					/* include 1 leading space */
			othw
				if (cmp_space(w->line+fe.pos.x))
					fe.pos.x++;					/* include 1 trailing space */
			}
#endif
		}
	}
	elif ((selected = str_any(w,&fs,cmp_space,prev_ch))
			ne 0 )							/* select white space */
	{
		next_ch(w,&fs);						/* skip the one not true at left */
		if (fs.pos.y ne fe.pos.y)
			find_line(w,fe.pos.y);
		str_any(w,&fe,cmp_space,next_ch);
		sty = WSP;
	}
	elif ((selected = str_any(w,&fs,cmp_other,prev_ch))
			ne 0 )							/* select left of other */
	{
		if (fs.pos.y ne fe.pos.y)
			find_line(w,fe.pos.y);
		str_any(w,&fe,cmp_other,next_ch);	/* right of other */
		str_surr(w,&fs,&fe,cmp_space);		/* surrounding spaces */
		sty = STP;
	}

	if (selected)
	{
		x_to_s_t(w,&fs);
		x_to_s_t(w,&fe);
		w->ss=fs;
		w->se=fe;
		w->selty=sty;
		return true;
	}
	ping;
	return false;
}

static
bool is_nest(short selty)     { return selty >= LOWHOOK    and selty <  HIGHHOOK;      }
static
bool is_l_nest(short selty)	{ return selty >= LOWHOOK    and selty <= L_HLEFT;       }
static
bool is_r_nest(short selty)	{ return selty >  L_HLEFT    and selty <  HIGHHOOK;      }
static
bool is_w_nest(short selty)	{ return selty >  TY_WH      and selty <  TY_WH+HIGH_WH; }
static
bool is_lw_nest(short selty)	{ return selty >  TY_WH      and selty <= TY_WH+N_WH;    }
static
bool is_rw_nest(short selty)	{ return selty >  TY_WH+N_WH and selty <  TY_WH+HIGH_WH; }

global
bool select_line(IT *w, STMNR y)
{
	w->ss = c1st;
	w->se = c1st;
	if (y > w->view.sz.h - 1)
		y = w->view.sz.h - 1;
	elif (y < 0)
		y = 0;
	w->ss.pos.y = y;
	w->cu.pos.y = y++;
	w->se.pos.y = y;
	w->selty = SELLN;
	w->selection = true;
	return true;
}

global
bool set_line(IT *w, CINF *ss, CINF *se)
{
	STMNR y = w->cu.pos.y;
	*ss = c1st;
	*se = c1st;
	if (y > w->view.sz.h - 1)
		y = w->view.sz.h - 1;
	elif (y < 0)
		y = 0;
	ss->pos.y = y;
	se->pos.y = y+1;
	w->selection = true;
	return true;
}

global
bool txtsel_cursor(IT *w,short kcode)		/* kcode is < 0 !! */
{
	short k = kcode&0xff, disp;

	if (k eq NK_INS)	/* Ignore if not in the menu. */
		return true;


#if RTUN
	if ((k eq NK_ENTER or k eq NK_RET) and cfg.rtun)
		empty_undo(w);	/* FOR PETR STEHLIK */
#endif

	if ((kcode&NKF_SHIFT) and !(kcode&NKF_CTRL))
#if  MNFKEYS
		if (k >= NK_F1 and k <= NK_F10)
		{
			insert_fkey(w, k - NK_F1 + 10);
			return true;
		}
		else
#endif
		switch (k)
		{
			case NK_DOWN:
			{
				via (w->deselect)(w, HIGH);
				make_vis_top(w);				/* also sets top */
				disp = w->cu.pos.y - w->cu.pos.y;
				(*w->arrowd)(w, WA_DNPAGE, true);
				t_to_s_x(w, w->norm.pos.y + disp, w->cu.updn, &w->cu, LOW);
			}
			return true;

			case NK_UP:
			{
				via (w->deselect)(w, LOW);
				make_vis_top(w);				/* also sets top */
				disp = w->cu.pos.y - w->cu.pos.y;
				(*w->arrowd)(w, WA_UPPAGE, true);
				t_to_s_x(w, w->norm.pos.y + disp, w->cu.updn, &w->cu, LOW);
			}
			return true;

			case NK_LEFT:
				via (w->deselect)(w, LOW);
				w->cu.scrx = 0;
				w->cu.updn = 0;
				w->cu.pos.x = 0;
				make_vis_top(w);
			return true;

			case NK_RIGHT:
				via (w->deselect)(w,HIGH);
				t_to_s_x(w, w->cu.pos.y, w->view.sz.w, &w->cu, HIGH);
				make_vis_top(w);
			return true;

			case NK_CLRHOME:
			{
				via (w->deselect)(w,HIGH);
				if (w->base)
					stmfilast(w->base);		/* snel */
				w->cu.pos.y=w->view.sz.h - 1;
				t_to_s_x(w, w->cu.pos.y, w->view.sz.w, &w->cu, HIGH);
				make_vis_top(w);
			}
			return true;
		}
	elif ((kcode&NKF_SHIFT) and (kcode&NKF_CTRL) )
		switch (k)
		{
			case NK_DOWN:
				(*w->arrowd)(w,WA_DNLINE,true);
				return true;
			case NK_UP:
				(*w->arrowd)(w,WA_UPLINE,true);
				return true;
			case NK_LEFT:
				(*w->arrowd)(w,WA_LFLINE,true);
				return true;
			case NK_RIGHT:
				(*w->arrowd)(w,WA_RTLINE,true);
				return true;
		}
	elif (   (kcode&NKF_CTRL) ne 0
	      and (k eq NK_LEFT or k eq NK_RIGHT) )
	{
		bool ok  = false;
		short  sel = w->selection ? w->selty : -1;

		if (is_nest(sel) and (kcode&NKF_ALT) ne 0)	/* go deeper if built_in nest */
		{
			if (k eq NK_RIGHT)
			{
				via (w->deselect)(w,LOW);
				find_current_line(w);
				if (is_l_nest(sel))
				{
					next_ch(w,&w->cu);
					if (sel eq L_COM)				 /* 2 ch's */
						next_ch(w,&w->cu);
				}
			othw
				via (w->deselect)(w,HIGH);
				find_current_line(w);
				if (is_r_nest(sel))
				{
					prev_ch(w,&w->cu);
					if (sel eq R_COM)				 /* 2 ch's */
						prev_ch(w,&w->cu);
				}
			}
		}
		elif (is_w_nest(sel) and (kcode&NKF_LSH) ne 0)	/* go deeper if word nest */
		{
			CINF fe;
			if (k eq NK_RIGHT)
			{
				via (w->deselect)(w,LOW);
				find_current_line(w);
				next_word(w,&w->cu,&fe);
			othw
				via (w->deselect)(w,HIGH);
				find_current_line(w);
				prev_word(w,&w->cu,&fe);
			}
		}
		else
		{
			via (w->deselect)(w,k eq NK_RIGHT ? HIGH : LOW);	/* go same level if there */
			find_current_line(w);
		}

		if (sel < 0 or sel eq LOWEST_W)		/* selction of word that is not a hook */
		{
			CINF fs,fe;
			fs=w->cu;
			fe=fs;					/* wants an existing point in fe */
			ok = k eq NK_RIGHT
				? next_word(w,&fs,&fe)
				: prev_word(w,&fs,&fe);

			x_to_s_t(w,&fs);		/* for screen pos */
			if (sel >= 0 and ok)
			{
				x_to_s_t(w, &fe);
				w->ss = fs;
				w->se = fe;
				w->cu = k eq NK_LEFT ? fs : fe;	/* for complete visibility go over selected thing */
				w->selection = true;
				if (!make_vis_top(w))
					via (w->select)(w);			/* when not made visible */
			othw
				w->cu = fs;
				make_vis_top(w);
			}
		othw		/* repeat same selection type */
	/* bool str_any(IT *w,CINF *cf,SEL_CMP *cmp,NEXT_CH *nxt) */
			if (k eq NK_RIGHT)
			{
				if (sel > TY_WH)	/* word_ hooks */
				{
					sel -= TY_WH;
					if (sel > N_WH)
						sel = HIGH_WH - sel;
					if (find_whook(w,sel,next_word))
						ok = select_thing(w);
				}
				else
				switch (sel)
				{
				case STP:
					if ( find_any(w,cmp_other,next_ch) )
						ok = select_thing(w);
				break;
				case WSP:
					if ( find_any(w,cmp_space,next_ch) )
						ok = select_thing(w);
				break;
				case QUO:
					if ( find_any(w,cmp_quo,next_ch) )
						ok = select_thing(w);
				break;
				case APOS:
					if ( find_any(w,cmp_apos,next_ch) )
						ok = select_thing(w);
				break;
				case L_C:			/* left or right hook is type */
				case R_C:			/*  Its not important how the selection is reached */
					if (find_any(w,cmp_L_C,next_ch) )
						ok = select_thing(w);
				break;
				case L_P:
				case R_P:
					if (find_any(w,cmp_L_P,next_ch) )
						ok = select_thing(w);
				break;
				case L_I:
				case R_I:
					if (find_any(w,cmp_L_I,next_ch) )
						ok = select_thing(w);
				break;
				case L_H:
				case R_H:
					if (find_any(w,cmp_L_H,next_ch) )
						ok = select_thing(w);
				break;
				case L_COM:
				case R_COM:
				case N_COM:								/* // comment */
					if (find_any(w,cmp_L_COM,next_ch) )
						ok = select_thing(w);
				break;
				case SELLN:
					ok = select_line(w,w->cu.pos.y);	/* deselect already adjusted the l */
				break;
				}
			othw		/* NK_LEFT */
				prev_ch(w,&w->cu);
				if (sel > TY_WH)	/* word_ hooks */
				{
					sel -= TY_WH;
					if (sel <= N_WH)
						sel = HIGH_WH - sel;
					if (find_whook(w,sel,prev_word))
						ok = select_thing(w);
				}
				else
				switch (sel)
				{
				case STP:
					if ( find_any(w,cmp_other,prev_ch) )
						ok = select_thing(w);
				break;
				case WSP:
					if ( find_any(w,cmp_space,prev_ch) )
						ok = select_thing(w);
				break;
				case QUO:		/* the lack of orientation has a curious effect here */
					if ( find_any(w,cmp_quo,prev_ch) )
						ok = select_thing(w);
				break;
				case APOS:
					if ( find_any(w,cmp_apos,prev_ch) )
						ok = select_thing(w);
				break;
				case L_C:
				case R_C:
					if (find_any(w,cmp_R_C,prev_ch) )
						ok = select_thing(w);
				break;
				case L_P:
				case R_P:
					if (find_any(w,cmp_R_P,prev_ch) )
						ok = select_thing(w);
				break;
				case L_I:
				case R_I:
					if (find_any(w,cmp_R_I,prev_ch) )
						ok = select_thing(w);
				break;
				case L_H:
				case R_H:
					if (find_any(w,cmp_R_H,prev_ch) )
						ok = select_thing(w);
				break;
				case L_COM:
				case R_COM:
				case N_COM:							/* // comment */
					if (find_any(w,cmp_R_COM,prev_ch) )
						ok = select_thing(w);
				break;
				case SELLN:
					ok = select_line(w,w->cu.pos.y);	/* deselect already adjusted the l */
				break;
				}
			}
			if (ok)
			{
				w->cu=w->ss;	/* In these case allways want to see the beginning */
				w->selection = true;
				if (!make_vis_top(w))
					via (w->select)(w);			/* when not made visible */
			othw
				x_to_s_t(w,&w->cu);
				make_vis_top(w);
			}
		}
		return true;
	}
	else
	switch (k)
	{
	case NK_LEFT:
		if (w->selection)
		{
		 	via (w->deselect)(w,LOW);
		othw
			cur_off(w);
			w->cu.scrx--;
		}

		if (t_to_s_x(w,w->cu.pos.y,w->cu.scrx,&w->cu,LOW))
		{
			make_vis_top(w);
			return true;
		}
		w->cu.scrx = 0;
		if (w->cu.pos.y > 0)
			w->cu.updn = w->view.sz.w - 1;
		else
			w->cu.updn = 0;
	fall_thru					/* if scroll */
	case NK_UP:
		if (w->cu.pos.y > 0)
		{
			via (w->deselect)(w,LOW);
			w->cu.pos.y--;
			if (w->cu.pos.y eq w->norm.pos.y)
				(*w->arrowd)(w,WA_UPLINE, true);
			cur_off(w);
			t_to_s_x(w,w->cu.pos.y ,w->cu.updn, &w->cu, LOW);
			make_vis_top(w);
		}
	return true;
	case NK_RIGHT:
		if (w->selection)
		{
			via (w->deselect)(w,HIGH);
		othw
			cur_off(w);
			w->cu.scrx++;
		}
		if (t_to_s_x(w, w->cu.pos.y, w->cu.scrx, &w->cu, HIGH) )
		{
			make_vis_top(w);
			return true;
		}
		w->cu.updn = 0;
	fall_thru				/*	if scroll */
	case NK_DOWN:
		if (w->cu.pos.y < w->view.sz.h - 1)
		{
			via (w->deselect)(w,HIGH);
			/* 02'14 HR: I should have known better than using post increment */
			if (w->cu.pos.y++ eq w->norm.pos.y+w->norm.sz.h - 2)
				(*w->arrowd)(w,WA_DNLINE, true);
			cur_off(w);
			t_to_s_x(w, w->cu.pos.y, w->cu.updn, &w->cu, LOW);
			make_vis_top(w);
		}
	return true;
	case NK_CLRHOME:
		via (w->deselect)(w,LOW);
		w->cu = c1st;
		if (w->base)
			stmfifirst(w->base);		/* snel */
		make_vis_top(w);
	return true;
	default:
#if  MNFKEYS
		if (k >= NK_F1 and k <= NK_F10)
		{
			insert_fkey(w, k - NK_F1);
			return true;
		}
		else
#endif
			return false;
	}

	return false;			/* not processed */
}

global
KEYBD txtsel_keybd 			/*	w,kcode		*/
{
	cur_off(w);
	if (    kcode > 0
	    or (kcode <= 0 and !txtsel_cursor(w,kcode))	/* cursor handling */
	   )											/* 02'14 v5.1 ++ or (kcode <= 0 and !.....) ) */
		 do_key(w,kcode);	/* other keys */
	cur_on(w);
}

global
void scroll(IT *w, short *mx, short *my)
{
	short xplusw=w->ma.x+w->ma.w;

	if ( *mx < w->ma.x )
	{
		(*w->arrowd)(w,WA_LFLINE, true);
		*mx=w->ma.x;
	othw
		if ( *mx > xplusw )
		{
			(*w->arrowd)(w,WA_RTLINE, true);
			*mx=xplusw-1;
		}
	}
	if ( *my < w->ma.y )
	{
		(*w->arrowd)(w,WA_UPLINE, true);
		*my=w->ma.y;
	othw
		if ( *my > w->ma.y+w->ma.h )
		{
			(*w->arrowd)(w,WA_DNLINE, true);
			*my=w->ma.y+w->ma.h-1;
		}
	}
}

global
BUTTON txtsel_button		/* w,button,kstate,bclicks,mx,my */
{
	short state;
	bool shift = (kstate & (LSHIFT | RSHIFT)) ne 0,
		 cntrl = (kstate & CONTRL) ne 0;
	static long obx, oby;

	/* ALTERNATE-left-button or right-button same as double click */
	if ( (kstate & ALTERNATE) or (button & 2) )
		bclicks = 2;

	wind_update(BEG_MCTRL);

#if DRAGSELECTION
	if (    !w->drag
	    or  (w->drag and ! w->drag(w, button, kstate, bclicks, mx, my))
	   )
#endif
	{
		obx = -1;
		oby = -1;

		do
		{
			long bx, by;
			CINF ms, ns;

			xy_to_unit(w, mx, my, &bx, &by);

			if (bx ne obx or by ne oby)
			{
				STMC *curs;

				if (w->base)
				{
					curs = find_line(w,by);
					by   = curs->xn - 1;		/* if beyond last line in small files */
				}

				if (bclicks eq 2)
				{
					via (w->deselect)(w, LOW);

					if ( shift )
					{
						/* shift double click = select line */
						select_line(w, by);
					othw
						t_to_s_x(w, by, bx, &w->cu, LOW);
						select_thing(w);
					}
					w->selection = true;
					via (w->select)(w);
				}
				else
				if ( !(kstate&NO_DRAG) and (shift or (kstate&DRAG)) )
				{
					w->selty = SHIFT_DRAG;
					t_to_s_x(w, by, bx, &ms, LOW);

					if (!w->selection)
					{
						cur_off(w);
						if (C_cmp(&ms, &w->cu) > 0)
						{
							w->ss = w->cu;
							w->se = ms;
						othw
							w->ss = ms;
							w->se = w->cu;
						}
						w->selection = true;
						via (w->select)(w);
					}
					else
					if (C_cmp(&ms, &w->ss) < 0)
					{
						ns    = w->ss;
						w->ss = ms;
						w->selection = true;
						via (w->wselect)
							(w, &ms, &ns, w->norm.pos.y, w->norm.pos.y + w->norm.sz.h);
					}
					else
					if (C_cmp(&ms, &w->se) > 0)
					{
						ns    = w->se;
						w->se = ms;
						w->selection = true;
						via (w->wselect)
							(w, &ns, &ms, w->norm.pos.y, w->norm.pos.y + w->norm.sz.h);
					}
					else
					if (C_cmp(&ms, &w->ss) and C_cmp(&ms, &w->se))
					{
						ns=w->se;
						w->se=ms;
						w->selection = true;
						via (w->wselect)
							(w, &ms, &ns, w->norm.pos.y, w->norm.pos.y + w->norm.sz.h);
					}
					else
					if (C_cmp(&w->ss, &w->se) eq 0)
					{
						via (w->deselect)(w,LOW);
						cur_on(w);
					}
				othw
					via (w->deselect)(w,0);
					t_to_s_x(w, by, bx, &w->cu, LOW);
					cur_on(w);
				}

				if (cntrl)		/* make line top line */
				{
					w->norm.pos.y = bounce(w,by);
					via (w->slider)(w);
					cur_off(w);
					do_redraw(w, w->wa);
				}
			}

			graf_mkstate(&mx, &my, &button, &state);

			if ( button )			/* still down ? drag */
			{
				kstate |= DRAG;
				scroll(w, &mx, &my);
			}
			obx = bx;
			oby = by;
		} while (button);		/* drag */

#ifdef MTEDITOR
	#if BIP_CC
		if (help_stack eq nil)
	#endif
			empty_undo(w);
#endif
	}
	wind_update(END_MCTRL);
}

global
void printselection(IT *w)
{	FILE *   prt;
	STMDEF * d;
	STMC *   s;
	char tabbed[MAXL + 1];

	if (w and w->selection)
	{
		d   = w->base;
		prt = fopen("PRN:",  "w");
		s   = find_line(w, w->ss.pos.y);

		while (s and s->xn < w->se.pos.y)
		{
			short len = de_tab (
			               tabbed,
			               s->xtx,
			               w->loc.tabs,
			               w->loc.vistab,
			               w->loc.vistco,
			               MAXL          );
			fwrite(tabbed, len, 1L, prt);
			fwrite("\r\n", 2,   1L, prt);
			s = stmfinext(d);
		}
		fclose(prt);
	}
}

global
void select_and_get_word(IT *w, char *word)
{
	if (is_text(w))
	{
		if (!w->selection)
		{
			cur_off(w);
			select_thing(w);		/* may set w->selection */
			via (w->select)(w);
			make_visible(w,w->ss, false);
		}
		else
			find_line(w, w->ss.pos.y);

		if (w->selty eq LOWEST_W)
		{
			char *f = w->line + w->ss.pos.x;
			short l = w->line + w->se.pos.x - f;

			strsncpy(word, f, l+1);
		}
	}
}

#ifdef MTREPAIR
static
DESELECT unselect		/*  IT *w,CUR_TO rich	 rich is LOW or HIGH */
{	if ( w->selection)
	{	if (rich eq LOW)
			w->cu=w->ss;
		else
			w->cu=w->se;
		w->ss=cnil;
		w->se=cnil;
	}
}

static
void remove_parentheses(IT *w)
{
	CINF css,cse;

	css = w->ss;
	(*w->select)(w);
	(*w->deselect)(w,HIGH);
	find_current_line(w);
	prev_ch(w,&w->cu);
	ed_key(w,NKF_FUNC|NK_DEL);		/*  ')' */
	cur_off(w);
	cse = w->cu;
	w->cu = css;
	find_current_line(w);
	ed_key(w,NKF_FUNC|NK_DEL);		/* '('  */
	cur_off(w);
	w->ss = css;
	w->se = cse;
	if (css.pos.y eq cse.pos.y)
	{
		w->se.pos.x--;
		x_to_s_t(w,&w->se);
	}
}

/* These functions act like macros, they do excactly the things
	that would be done if performed via the keyboard */

global
bool repair_various(IT *w, short mt)		/* we know selection vectors are established in w */
{
	CINF css,cse;

	if (mt eq MNREPBL or mt eq MNREPCOMU or mt eq MNREPCOMD)
	{
	/*		    if (.....) { /* ...... */
	   -->      if (.....)
	 			{  /* ...... */

	   and then you can move the comment up or down. }}
	*/
		if (!w->selection)
			return false;

		if (w->selty eq L_C)
		{
			(*w->deselect)(w,LOW);
			find_current_line(w);
			prev_ch(w,&w->cu);		/* 1 before '{' */
			if (chcl[T*(w->line+w->cu.pos.x)] eq WSP)	/* if preceded by space remove all */
				select_thing(w);
			else
				next_ch(w,&w->cu);	/* back to '{' */
			ed_key(w,NKF_FUNC|NK_RET);		/* insert newline with indent if on and delete selected white space */
			select_thing(w); /* now reselect block */
			via (w->slider)(w);
			if (!make_vis_cur(w))
				do_redraw(w,w->wa);
			return true;
		}
		elif (w->selty eq L_COM)
		{
			CINF scu;
			(*w->deselect)(w,LOW);
			find_current_line(w);
			prev_ch(w,&w->cu);		/* 1 before comment */
			if (chcl[T*(w->line+w->cu.pos.x)] eq WSP)	/* if preceded by space remove all */
				select_thing(w),
				ed_key(w,NKF_FUNC|NK_DEL);		/* delete selected white space */
			select_thing(w);			/* back to comment */
			do_Buffer(w,MNCUT,0);
			w->cu.pos.y+= mt eq MNREPCOMU ? -1 : +1;
			find_current_line(w);
			txtsel_cursor(w,NKF_FUNC|NKF_LSH|NK_RIGHT);	/* to end of line */
			ed_key(w,NK_TAB);
			scu = w->cu;
			do_Buffer(w,MNPASTE,0);
			w->cu = scu;
			find_current_line(w);
			select_thing(w); 		/* now reselect comment */
			via (w->slider)(w);
			if (!make_vis_cur(w))
				do_redraw(w,w->wa);
			return true;
		}
	}
	elif (mt eq MNOTHW)
	{
		while (do_find(w,"else",nil,true,false,true,false,-1))
		{			/*	  z      zz  w   case  surr rich	*/
			cse = w->se;
			(*w->deselect)(w,LOW);
			find_current_line(w);
			prev_ch(w,&w->cu);
			if (chcl[T*(w->line+w->cu.pos.x)] eq WSP)
				select_thing(w),
				unselect(w,LOW);
			find_current_line(w);
			prev_ch(w,&w->cu);
			if (chcl[T*(w->line+w->cu.pos.x)] eq R_C)
			{
				css = w->cu;
				w->cu = cse;		/* after 'else' */
				find_current_line(w);
				next_ch(w,&w->cu);
				if (chcl[T*(w->line+w->cu.pos.x)] eq WSP)
					select_thing(w),
					unselect(w,HIGH);
				find_current_line(w);
				if (chcl[T*(w->line+w->cu.pos.x)] eq L_C)
				{
					next_ch(w,&w->cu);
					x_to_s_t(w,&w->cu);
					w->ss = css;
					w->se = w->cu;
					ed_key(w,'o');
					ed_key(w,'t');
					ed_key(w,'h');
					ed_key(w,'w');
					continue;
				}
			}
			unselect(w,HIGH);
			w->cu = cse;		/* after else */
			via (w->slider)(w);
			if (!make_vis_cur(w))
				do_redraw(w,w->wa);
		}
	}
	elif (mt eq MNELSE)
	{
		char *zz[]={"elif",nil};

		while (do_find(w,"else",zz,true,false,true,false,-1))
		{
			CINF wse = cnil;

			cse = w->se;
			css = cnil;
			(*w->deselect)(w,LOW);
			find_current_line(w);
			prev_ch(w,&w->cu);
			if (chcl[T*(w->line+w->cu.pos.x)] eq WSP)
			{
				select_thing(w);
				wse = w->se;
				unselect(w,LOW);
				find_current_line(w);
				css = w->cu;
				prev_ch(w,&w->cu);
			}
			if (chcl[T*(w->line+w->cu.pos.x)] eq R_C)
			{
				if (w->cu.pos.y eq cse.l)
				{
					find_current_line(w);
					next_ch(w,&w->cu);
					w->ss = css;
					w->se = wse;
					ed_key(w,NKF_FUNC|NK_RET);
					continue;
				}
			}
			w->cu = cse;		/* after else */
			via (w->slider)(w);
			if (!make_vis_cur(w))
				do_redraw(w,w->wa);
		}
	}
	elif (mt eq MNREPROTO)
	{
		char m[128], *s = m;
		strcpy(m, tmen.m[MNREPROTO].spec.free_string + 2);
		while(is_alpha(*s)) s++; *s = 0;

		while (do_find(w, m, nil, true, false, true, false, -1))
		{
			ed_key(w,NKF_FUNC|NK_DEL);
			select_thing(w);
			if (w->selty eq WSP)
				ed_key(w,NKF_FUNC|NK_DEL);
			find_current_line(w);
			select_thing(w);
			if (w->selty eq L_P)		/* I dont delete newlines */
				remove_parentheses(w);
		}
		via (w->slider)(w);
		if (!make_vis_cur(w))
			do_redraw(w,w->wa);
		return true;
	}
	elif (mt eq MNPRO1)		/* romove old style parameter tags */
	{
		if (do_find(w,"(",nil,false,true,false,false,-1))
		{
			(*w->deselect)(w,HIGH);
			ed_key(w,NKF_FUNC|NKF_CTRL|NK_DEL);	/* ^DEL  delete rest of line */
			if (!make_vis_cur(w))
				do_redraw(w,w->wa);
			return true;
		}
	}
	elif (mt eq MNPRO2)		/* ; --> , */
	{
		if (do_find(w,";",nil,false,false,false,false,-1))
		{
			replace(w,",",1);
			return true;
		}
	}
	elif (mt eq MNPRO3)		/* ; --> ) */
	{
		if (do_find(w,";",nil,false,false,false,false,-1))
		{
			replace(w,")",1);
			return true;
		}
	}
	elif (mt eq MNPAREN)
	{
		if (w->selty eq L_P)	/* remove () */
		{
			remove_parentheses(w);
			via (w->slider)(w);
			if (!make_vis_cur(w))
				do_redraw(w,w->wa);
			return true;
	/*	othw					 embrace selection by () */

		}
	}

	return false;
}
#endif