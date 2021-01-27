/*  Copyright (c) 1993 - 2008 by Henk Robbers Amsterdam.
 *
 * This file is part of CALC.
 *
 * CALC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * CALC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with CALC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/* 	SHEET.C
 *	=======
 */
#define TRACE(a) alert_text("-= " #a " =-");
#define DATES 0

#define NC 1
#define loop_all loop(i, MAXCOLS) loop(j, MAXROWS)

#include <string.h>

#include "common/mallocs.h"
#include "common/aaaa_lib.h"
#include "common/hierarch.h"

#define FIXPC 0

#include "aaaa.h"
#include "common/cursor.h"
#include "common/files.h"
#include "common/options.h"
#include "common/config.h"
#include "common/wdial.h"
#include "common/ahcm.h"
#include "sheet.h"

/* All the fields keywords */
#define CRES "cre"
#define UPDS "upd"
#define COMS "com"
#define VALS "val"
#define CELS "cel"
#define TXTS "txt"
#define FORS "for"

extern int colspace,rowspace;

CINFO cinf_upd;
CINFI upd_cinf;

M_S cmen={false,false,0,0,0,0,0,0,0,nil,nil};

SH sh = {0};

static
OBJECT *ed=nil;

static
TEDINFO *c_str,*ty_str;

global
TEDINFO *ed_str,*co_str;

#if DATES
TEDINFO *newstr,*updstr;
#endif

#ifdef SH_LBLSTR
static
TEDINFO *lbl_str;
#endif

static fpos_t hp;

void hgetpos(FILE *f)
{
	hp = ftell(f);
}

void hsetpos(FILE *f)
{
	fseek(f, hp, SEEK_SET);		/* corrupts something with Pure C lib */
}

char sh_string[130], sh_tmpl[130];

Tdate defdate(void)
{
	Tdate dt;

	dt.dd.y = 1985-1980;
	dt.dd.m = 1;
	dt.dd.d = 1;

	return dt;
}

global
bool upd_cinf(IT *w, STMNR cu_y, short to_x, CINF *ci, short rich)
{
	if (to_x < 0)
		return false;			/* scroll! */

	ci->updn  = to_x;
	ci->pos.y = cu_y;
	ci->scrx  = to_x;
	ci->pos.x = to_x;
	return (ci->pos.x < w->view.sz.w - 1);
}

global
void cinf_upd(IT *w, CINF *ci)
{
	if (ci->pos.y > w->view.sz.h - 1)
		ci->pos.y = w->view.sz.h - 1;
	ci->scrx = ci->pos.x;
	ci->updn = ci->scrx;
}

global
BUTTON sheet_click		/* w,button,kstate,bclicks,mx,my */
{
	long bx, by;

	xy_to_unit(w, mx, my, &bx, &by);
	cur_off(w);
	upd_cinf(w, by, bx, &w->cu, LOW);
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

static
XSELECT sheet_wselect	/* IT *w,CINF *css,CINF *cse, STMNR top, STMNR bot	*/
{
	short hl = w->hl;
	STMNR sl, el;
	short
		sc, ec, si, ei,

		ww = w->norm.sz.w,
		hw = w->norm.sz.h,

		px1, py1, px2, py2;

	CINF ss = *css,
	     se = *cse;

	sl = ss.pos.y;
	sc = ss.scrx - w->norm.pos.x;
	el = se.pos.y;
	ec = se.scrx - w->norm.pos.x;

	if ( ss.pos.y >= bot )		return;
	if ( se.pos.y <  top )		return;

	if (C_cmp(&ss, &se) >= 0)	return;

	if (ec <= 0)				return;

	if (   sc < 0
	    or sc > ww
	    or sl < top)			return;

	if (ec <= 0  ) ec = ww, el--;
	if (ec >  ww ) ec = ww;
	if (el >  bot) el = bot, ec = ww - 1;

	si = sl - w->norm.pos.y,
	ei = el - w->norm.pos.y;

	if (si < 0)					return;

	if (ei > hw-1) ei=hw-1,ec=ww;

	px1 = w->ma.x + (sc*w->unit.w)  ;
	 py1= w->ma.y + (si*w->unit.h)  ;
	px2 = w->ma.x + (ec*w->unit.w)-1;
	 py2= w->ma.y + (ei*w->unit.h)-1;

	/* 02'14 HR select only columns */
	{
		hidem;
		vswr_mode(hl,3);
		vsf_color(hl,1);

		pbox(hl,px1,py1,px2,py2);
		vsf_color(hl,0);
		vswr_mode(hl,1);
		showm;
	}
}

global
SELECT sheet_select	/*	IT *w */
{
	if ( w->selection and w->wselect )
		(*w->wselect)
			(w,&w->ss,&w->se,w->norm.pos.y,w->norm.pos.y+w->norm.sz.h);
	else
		cur_on(w);
}

global
DESELECT sheet_deselect		/*  IT *w,CUR_TO rich	 rich is LOW or HIGH */
{
	if ( w->selection )
	{
		sheet_select(w);		/* ontschrijf */
		if (rich eq LOW)
			w->cu=w->ss;
		else
			w->cu=w->se;
		w->ss=cnil;
		w->se=cnil;
		w->selection = false;
	}
	else
		cur_off(w);
}


static
SHEET_ACT free_cell
{
	free(c);
}

static
void tab_loop(IT *w, SHEET_ACT *t, SHEET_ACT *s)
{
		CELLP c;
		int i,j;

		loop_all
		{
			if (t and w->wks.tab)
			{
				c=get_cell(w, i, j);
				if (c)
					(*t)(w, c);
			}
			if (s and sh.copies)
			{
				c=get_save(w, i, j);
				if (c)
					(*s)(w, c);
			}
		}
}

static
char *cell_str(int col,int row)
{
	static char s[DEFCOLW];

	sprintf(s,"%s%d",cbr(col,2,' ',LETTERS),row+1);
	return s;
}

global
char * is_label(char *s, int *ty)
{
	static char ide[128];
	char *st = ide;

	while (*s >= 'a' and *s <= 'z')
		*st++ = *s++;
	*st = 0;
	ide[31] = 0;

	if (ty)
	{
		if (*s eq '-' and *(s+1) eq '>')
			*ty = FUN;
		elif (*s eq ':' and *(s+1) eq ':')
			*ty = LAB;
		else
			*ty = 0;
	}

	return ide;
}

static
IDES * store_ide(IDES *ides, char *ide, int ty, int col, int row)
{
	IDES *id = ides;

	if (ty)
	{
		while (id)
		{
			if (strcmp(id->name, ide) eq 0)		/* replace old */
			{
				strcpy(id->name, ide);
				id->col = col;
				id->row = row;
				id->ty =ty;
				return ides;
			}
			id = id->next;
		}

		id = mmalloc(sizeof(IDES), "while allocating identifier","Abondoned", AH_IDE);
		if (id)
		{
			id->next = ides;
			strcpy(id->name, ide);
			id->col = col;
			id->row = row;
			id->ty = ty;
			ides = id;
		}
	}

	return ides;
}

static
void free_ides(IDES *ides)
{
	while(ides)
	{
		IDES *nx = ides->next;
		free(ides);
		ides = nx;
	}
}

SHEET_ACT calc_one	/* SH_CELL */
{
	IT *w = vw;
	int ty, i = c->col, j = c->row;
	char *s = c->text;
	char *ide = is_label(s, &ty);

	sh.col = i, sh.row = j;		/* for shparse-->shnext */
	c->ty = ty;

	if (ty)
		w->wks.ides = store_ide(w->wks.ides, ide, ty, i, j);

#if 1			/* N.B.!!!! test parser only */
	if (c->attr eq FORM)
#else
	if (!(c->attr eq VAL and *c->text eq 0))		/* mostly older sheets */
#endif
	{
		if (ty eq LAB)
			s += strlen(ide) + 2;
		c->val = shparse(w->wks.tab, w->wks.ides, s, &c->attr);
	}
}

static
void recalc(IT *w) { tab_loop(w, calc_one, nil); }

static
OB_PLACE sh_place
{
	w->dial.ob->x=w->ma.x-LEFTMARGIN;
	w->dial.ob->y=w->ma.y+w->ma.h+1;
	wdial_edob(w,w->dial.edob);
}

#if DATES
static Cstr Nodate = "no date";
#endif

static
void disp_edit(IT *w)
{
	int col=w->cu.scrx,
		row=w->cu.pos.y;
	CELLP c=get_cell(w,col,row);

	strcpy(c_str->text,cell_str(col,row));

	if (w->wks.editing)
	{
		strcpy(ed_str->text,w->wks.edstr);
		strcpy(co_str->text,w->wks.costr);
	}
	else
	if (c)
	{
		strcpy(co_str->text, c->comm);

		switch(c->attr)
		{
		case TXT:
			strcpy(ed_str->text,c->text);
			strcpy(ty_str->text,"text:");
		esac
		case VAL:
			if (c->text and *c->text)
				strcpy(ed_str->text,c->text);
			else
				sprintf(ed_str->text,"%g",c->val);
			strcpy(ty_str->text,"value:");
		esac
		case FORM:
			strcpy(ed_str->text,c->text);
			strcpy(ty_str->text,"formula:");
		esac
		case FUN:
			strcpy(ed_str->text,c->text);
			strcpy(ty_str->text,"function:");
		esac
		}
		strcpy(w->wks.edstr,ed_str->text);
		strcpy(w->wks.costr,co_str->text);

#if DATES
		if (c->cre.dd.m)
			sprintf(newstr->text, "%d/%d/%d",c->cre.dd.d,c->cre.dd.m, c->cre.dd.y +1980);
		else
			strcpy(newstr->text,Nodate);
		if (c->upd.dd.m and c->upd.dd.y ne 1985)
			sprintf(updstr->text, "%d/%d/%d", c->upd.dd.d,c->upd.dd.m,c->upd.dd.y +1980);
		else
			strcpy(updstr->text,Nodate);
#endif
	othw
		*ed_str->text=0;
		*co_str->text=0;
#if DATES
		*newstr->text=0;
		*updstr->text=0;
#endif
		*w->wks.edstr=0;
		*w->wks.costr=0;
		strcpy(ty_str->text,"empty:");
	}

	via (w->dial.place)(w);
}

static
void sh_dcell(IT *w, int i, int j, bool hide)		/* top and j starts at 1 */
{
	char s[MAXI+1];
	int x=w->ma.x+(i-w->norm.pos.x)*w->unit.w,		/* w in pixels ! */
		y=w->ma.y+(j-w->norm.pos.y)*w->unit.h,
		cm=w->unit.w/deskw.unit.w;

	CELLP c;

	c = get_cell(w, i, j);

	if (c)
	{
		switch(c->attr)
		{
		case TXT:
		case FUN:
			strcpy(s, c->text);
		esac
		case VAL:
			sprintf(s, "%g", c->val);
			*(s+cm)=0;
		esac
		case FORM:
			sprintf(s, "%g", c->val);
			*(s+cm) = 0;
		esac
		}

		if (hide)
			hidem;
		f_txt(v_hl, x, y, s);
		if (hide)
			showm;
	}
}

static bool letter(unsigned char *s)
{
	return *s >= 'a' and *s <= 'z';
}

/* Find any valid cellname in a string */
global
char * get_name(IT *w, char **p, int *l, int *col, int *row)
{
	char *s = *p, *ss;
	while (*s and !letter((uchar *)s)) s++;
	*p = s;
	if ((ss = absname(p, l, col, row)) ne nil)
		return ss;
	*p = s;
	return nil;		/* none or last */

}

#define An 1

global
char * dcol(unsigned short n)
{
	short l = colspace;
	static char x[32];
	char *a=&x[31];

	*a--=0;
	do
		*a--=(n%LETTERS)+'a';
	while ( --l>0 && (n/=LETTERS) > 0 );
	return a+1;
}

global
char * drow(unsigned short n)
{
	short l = rowspace;
	static char x[32];
	char *a=&x[31];

	*a--=0;
	n++;
	do
		*a--=(n%10)+'0';
	while ( (--l)>0 && (n/=10) > 0 );

	return a+1;
}

DRAW sh_disp		/*	(IT *w,RECT t2)	*/
{
	int i, j;

	hidem;
	cur_off(w);
	if (w->wks.editing)
		wdial_off(w);

	gspbox(v_hl,w->wa);

	if (w->norm.pos.x + w->norm.sz.w > (w->view.sz.w - 1) )
		w->norm.pos.x = w->view.sz.w - (w->norm.sz.w - 1);

	for(i = w->norm.pos.x; i < w->norm.pos.x + w->norm.sz.w; i++)
	{
		f_txt(v_hl,
				 w->ma.x + (i - w->norm.pos.x) * w->unit.w,
				 w->wa.y,
#if An
				 cbr(i,DEFCOLW/2-1,' ',LETTERS)
#else
				 cbdu(i,2,' ')
#endif
			 );

		for(j=w->norm.pos.y; j < w->norm.pos.y+w->norm.sz.h; j++)
		{
			if (i eq w->norm.pos.x)
				f_txt(v_hl,w->ma.x - LEFTMARGIN,
						 w->ma.y+(j-w->norm.pos.y)*w->unit.h,
#if An
						 cbdu(j+1,2,' ')
#else
						 cbdu(j,2,' ')
#endif
					 );
			sh_dcell(w,i,j,NO_HIDE);
		}
	}

	line(v_hl,
			w->wa.x,
			w->ma.y-1,
			w->wa.x+w->wa.w-1,
			w->ma.y-1);
	line(v_hl,
			w->ma.x-deskw.unit.w/2-1,
			w->ma.y,
			w->ma.x-deskw.unit.w/2-1,
			w->ma.y+w->ma.h-1);
	line(v_hl,
			w->wa.x,
			w->ma.y+w->ma.h,
			w->wa.x+w->wa.w-1,
			w->ma.y+w->ma.h);

	disp_edit(w);
	draw_ob(ed,0,t2,0);

	via (w->select)(w);		/* 02/14 HR */

	if (w->wks.editing)
		wdial_on(w);

	cur_on(w);
	showm;
}

ANTEVNT sh_evm		/* IT *w; bool w_on, short evmask */
{
	evmask|=MU_KEYBD|MU_M1;
	if (w_on)
		evmask|=MU_BUTTON;
	if (w->wks.editing)
		evmask=wdial_evm(w,w_on,evmask);
	return evmask;
}

static
SHEET_ACT unflag
{
	c->flags&=~ISMOD;
}

static
FILE *uf = nil;
char *attrs[]={"TXT","VAL","FOR","FUN"};

static
SHEET_ACT unloadcell		/* void *w, CELLP c */
{
	/* uf must be Fopen'ed */
	fprintf(uf, CELS "=%d/%d,", c->col, c->row);
#if DATES
	if (c->cre.dd.m and c->cre.dd.y ne 5)
	{
		fprintf(uf, CRES "=%d,", c->cre.d);
		fprintf(uf, UPDS "=%d,", c->upd.d);
	}
#endif

  	if (*c->comm)
	{
		char *p = c->comm;

		while (*p)
		{
			if (*p eq '|')
				*p='!';
			p++;
		}
		fprintf(uf, COMS "=%ld:%s|", strlen(c->comm), c->comm);
	}

	fprintf(uf, "\t%s=",attrs[c->attr]);
	switch(c->attr)
	{
	case FUN:
	case TXT:
		fprintf(uf,"%ld:%s",strlen(c->text),c->text);
	esac
	case VAL:
	{
		char *t = c->text;
		if (t eq nil)
			t = "";
		fprintf(uf, VALS "=%g," TXTS "=%ld:%s",
			c->val,strlen(t),t);
	}
	esac
	case FORM:
		fprintf(uf, VALS "=%g," FORS "=%ld:%s",
			c->val,strlen(c->text),c->text);
	esac
	}
	fprintf(uf,"\n");
}

static
void def_head(IT *w)
{
	struct sheet *k = &w->wks;

	k->head.cols     = MAXCOLS;
	k->head.rows     = MAXROWS;
	k->head.colwsize = DEFCOLW;
}

static
bool new_cell(IT *w, SH_SHEET t, CELLP c)
{
	CELLP new;
	char *ide; int ty;

	ide = is_label(c->text, &ty);

	if (ty)
		w->wks.ides = store_ide(w->wks.ides, ide, ty, c->col, c->row);

	c->ty = ty;
	c->flags=0;

	new = xmalloc(sizeof(SH_CELL), AH_CELL);
	if (new)
	{
		*new = *c;
		(*t)[c->col][c->row] = new;
	othw
		alertm("| Not enough memory | for cell %d/%d", c->col, c->row);
		return false;
	}
	return true;
}


static
short cols, rows, colwsize;

static
SH_CELL Cur;

static
OpEntry celltab[]=
{
	{"cell= {\n", 0,       nil  },
	{"col =%d\n", MAXD, &Cur.col  },
	{"row =%d\n", MAXD, &Cur.row  },
	{"atr =%d\n", MAXD, &Cur.attr },
	{"val =%g\n", MAXD, &Cur.val  },
	{"txt =%s\n", MAXI, &Cur.text },
	{"com =%s\n", MAXI, &Cur.comm },
	{"cre =%d\n", MAXD, &Cur.cre.d},
	{"upd =%d\n", MAXD, &Cur.upd.d},
	{"}      \n"},
	{"\0"}
};

static SH_SHEET this_t;
static IT *     this_w;
static FILE *file;

static
SHEET_ACT out_cell		/* void *w, FILE *fp, CELLP c */
{
	Cur = *c;
	saveconfig(file, celltab, 0);
}

static
CFGNEST cellcfg
{
	IT *w = this_w;		/* for new_cell */
	if (!w)
		alert_text("cellcfg !w this %lx", this_w);

	if (io eq 1)		/* output */
	{
		file = fp;
		tab_loop(w, out_cell, nil);
	othw
		memset(&Cur,0,sizeof(Cur));
		loadconfig(fp, celltab, 0);
		if (!Cur.cre.d)	/* absent */
			Cur.cre = defdate(), Cur.upd.d = 0;
		new_cell(w, this_t, &Cur);
	}
}

static
OpEntry calctab[]=
{
	{"cols=%d\n", MAXD, &cols},
	{"rows=%d\n", MAXD, &rows},
	{"wsiz=%d\n", MAXD, &colwsize},
	{"cell= {}\n", 0, cellcfg},
	{"\0"}
};

static
void savesheet(IT *w,char *fn,bool force)
{
	if (w->ismod or force)
	{
		def_head(w);
		uf = fopen(fn, "w");
		if (!uf)
			alertm(frstr(FNOP), fn);
		else
		{
			struct sheet *k = &w->wks;
			w->fl = 6;

			if (w->wks.Ver)	/* save according to version of input. */
			{
				this_w = w;
				cols     = k->head.cols;
				rows     = k->head.rows;
				colwsize = k->head.colwsize;
				saveconfig(uf, calctab, 0);
			othw
				fprintf(uf, "HR95sheet=%d/%d,cws=%d;\n",
					k->head.cols,
					k->head.rows,
					k->head.colwsize	);
				tab_loop(w, unloadcell, nil);
				fprintf(uf, "end_HR95sheet\n");
			}

			fclose(uf);

			tab_loop(w, unflag, nil);
			w->ismod = false;
			w->title.x=' ';
			w->title.u=' ';
			wi_title(w);
		}
	}
}

static
void savesheetas(IT *w)
{
	char *fn;
	if (w)
		if ( (fn = select_file(&idir,nil,&fsel," Save sheet as ...",&drive)) ne nil)
		{
			w->wks.Ver = 1;		/* Save as: explicit always new version. */
			set_V(w);
			savesheet(w,fn,true);
			strcpy(w->title.t,fn);
			wi_title(w);
		}
}

static
bool check_shsave(IT *w)
{
	if (w->ismod)
	{
		switch(form_alert(1, frstr(ALCHA)))		/* default button 2 in testfase anders 1 (Save) */
		{
		case 1:
			savesheet(w,w->title.t,true);
		case 2:
			return true;			/* close without save */
		case 3:
			return false;			/* cancel */
		}
	}
	return true;		/* yes can close */
}

static
bool close_sheet(IT *w, bool force)
{
	if (!(force or check_shsave(w)))
		return false;

	cur_off(w);
	w->cu = c1st;
	w->norm.pos.x = 0;

	free_ides(w->wks.ides);
	tab_loop(w, free_cell, free_cell);

	free(w->wks.tab);

	close_w(w);
	w->fl = 0;

	stmdelcur(&winbase);
/*	if (!w_handles(whs,no_dial))
		en_file(false);
*/	return true;
}

CLOSED sh_close
{
	if (close_sheet(w,false))		/* do not force */
		if (!w_handles(nil,no_dial))
			close_dials();
}

static
SHEET_ACT clear_one
{
	IT *w = vw;
	if (c->attr eq VAL)
	{
		if (c->ty)			/* keep the labels */
		{
			char *s = c->text;

			while (*s)
				if (*s eq ':' and *(s + 1) eq ':')
					break;
				else
					s++;

			if (*s eq ':')
			{
				*(s + 2) = '0';
				*(s + 3) = 0;
			}

			c->val = 0.0;
#if DATES
#if V6
			c->cre.dd.m = 		/* AHCC < v6 problem */
			c->upd.dd.m = 0;
#else
			c->cre.dd.m = 0;
			c->upd.dd.m = 0;
#endif
#endif
		othw
			free_cell(w, c);
			get_cell(w, c->col, c->row )= nil;
		}
		set_X(w);
	}
}
static
void do_shFile(IT *w, int choice)
{
	switch(choice)
	{
	case MNCSAVE:
		savesheet(w, w->title.t, false);	/* false = don't force */
	esac
	case MNCSAVES:
		savesheetas(w);
	esac
	case MNCRECALC:
		recalc(w);
		do_redraw(w, w->wa);
	esac
	case MNCLRV:
	{
		tab_loop(w, clear_one, nil);
		recalc(w);
		recalc(w);		/* twice can be useful */
		do_redraw(w, w->wa);
	}
	esac
	case MNCCLOSE:

		wmenu_tnormal(w,MTC1,true); /* before its gone */

		if (w)
			if (w->closed)
				(*w->closed)(w);
		return;
	}

	wmenu_tnormal(w,MTC1,true);
}

static
bool change_cell(IT *w, CELLP n, int ty, int col, int row, bool new)
{
	CELLP c;

	if (!n) return false;

	n->ty = ty;
	n->col = col;
	n->row = row;
	n->flags = ISMOD;
#if DATES
	n->upd.d = new ? 0 : Tgetdate();
	if (!n->cre.dd.m) n->cre = n->upd;
#endif
	c = mmalloc(sizeof(SH_CELL), "while allocating cell.", "action cancelled", AH_CHCELL);
	if (c)
	{
		CELLP o = get_cell(w, col, row);

		w->ismod = true;
		if (o)
			free_cell(w, o);
		get_cell(w, col, row) = c;
		*c = *n;
	}

	return c ne nil;
}

static
void free_save(void)
{
	if (sh.copies)
	{
		short i, j;
		loop_all
			if ((*sh.copies)[i][j])
				free((*sh.copies)[i][j]);
		free(sh.copies);
		sh.copies = nil;
	}
}

static
void make_save(void)
{
	short i, j;
	sh.copies = mmalloc(sizeof(SH_TAB), "while allocating buffer","Cancelled", AH_BUF);
	if (sh.copies)
		loop_all (*sh.copies)[i][j] = xcalloc(1, sizeof(SH_CELL), AH_BCELL);
}

static
RECT make_fro(IT *w)
{
	RECT r;
	if (w->selection)
	{
		r.x = w->ss.scrx;
		r.y = w->ss.pos.y;
		r.w = w->se.scrx  - r.x;
		r.h = w->se.pos.y - r.y;
	othw
		r.x = w->cu.scrx;
		r.y = w->cu.pos.y;
		r.w = 1;
		r.h = 1;
	}
	return r;
}

static
void rewrite_name(CELLP c, char *s, int l, int frox, int froy, int tox, int toy)
{
	short i;
	char ns[3*MAXI];

	loop(i, l)		/* skip old coord */
		if (*s eq 0)
			break;
		else
			*s++=0;

	strcpy(ns, c->text);
	strcat(ns, dcol(tox));
	strcat(ns, drow(toy));
	strcat(ns, s);

	ns[MAXI]=0;
	strcpy(c->text, ns);
}

static
void update_names(IT *w, int frox, int froy, int tox, int toy)
{
	int i, j, l, col, row;
	char *s, *ss;		/* end of name, begin of name */

	loop_all
	{
		CELLP c = get_cell(w, i, j);
		if (c)
			if (c->attr eq FORM)
			{
				s = c->text;
				if (s)
					while ((ss = get_name(w, &s, &l, &col, &row)) ne nil)
						if (col eq frox and row eq froy)
							rewrite_name(c, ss, l, frox, froy, tox, toy);
			}
	}
}

global
bool move_cell(IT *w, int frox, int froy, int tox, int toy)
{
	CELLP c = get_cell(w, frox, froy);
	bool calc = false;

	if (c)
	{
		sh.sbuf = *c;
		free_cell(w, c);
		get_cell(w, frox, froy) = nil;
		change_cell(w, &sh.sbuf, sh.sbuf.ty, tox, toy, false);
		update_names(w, frox, froy, tox, toy);
		calc = true;
	}
	return calc;
}

static
void do_shEdit(IT *w, int choice)
{
	RECT fro;
	CELLP c, t;
	bool calc = false;
	int i, j, k, l;

	sh.col = w->cu.scrx, sh.row = w->cu.pos.y;

	switch (choice)
	{
	case MNCCOPY:
	case MNCCUT:
	case MNCDEL:
		fro = make_fro(w);
		sh.copy_rect = fro;
		free_save();
		make_save();
		for(i = fro.x; i < fro.x + fro.w; i++)
			for (j = fro.y; j < fro.y + fro.h; j++)
			{
				t = get_save(w, i, j);
				c = get_cell(w, i, j);
				if (c and t)
				{
					*t = *c;
					if (choice ne MNCCOPY)		/* cut or delete */
					{
						free_cell(w, c);
						get_cell(w, i, j) = nil;
						w->ismod = true;
						calc = true;
					}
				}
			}
	esac;
	case MNCPASTE:
		fro = sh.copy_rect;
		if (sh.copy_rect.w and !w->selection)
			for(i = fro.x, k = w->cu.scrx; i < fro.x + fro.w; i++, k++)
				for (j = fro.y, l = w->cu.pos.y; j < fro.y + fro.h; j++, l++)
				{
					t = get_save(w, i, j);
					change_cell(w, t, t->ty, k, l, false);
					calc = true;
				}
	esac;
#ifdef MCSHL
	case MCSHL:
		via (w->deselect)(w, LOW);
		if (w->cu.scrx > 0)
		{
			for(i = w->cu.scrx; i < w->view.sz.w-1 ; i++)
				for (j = w->cu.pos.y; j < w->view.sz.h; j++)
					calc |= move_cell(w, i, j, i-1, j);
			upd_cinf(w, w->cu.pos.y, w->cu.scrx - 1, &w->cu, LOW);
		}
	esac;
	case MCSHU:
		via (w->deselect)(w, LOW);
		if (w->cu.pos.y > 0)
		{
			for (j = w->cu.pos.y; j < w->view.sz.h-1; j++)
				for(i = w->cu.scrx; i < w->view.sz.w; i++)
					calc |= move_cell(w, i, j, i, j-1);
			w->cu.pos.y--;
		}
	esac;
	case MCSHR:
		via (w->deselect)(w, LOW);
		for(i = w->view.sz.w - 1; i > w->cu.scrx; i--)
			for (j = w->cu.pos.y; j < w->view.sz.h; j++)
				calc |= move_cell(w, i-1, j, i, j);
		upd_cinf(w, w->cu.pos.y, w->cu.scrx + 1, &w->cu, LOW);
	esac;
	case MCSHD:
		via (w->deselect)(w, LOW);
		for (j = w->view.sz.h - 1; j > w->cu.pos.y; j--)
			for(i = w->cu.scrx; i < w->view.sz.w; i++)
				calc |= move_cell(w, i, j-1, i, j);
		w->cu.pos.y++;
	esac;
#endif
	}

	if (calc)
	{
		recalc(w);
		set_X(w);
		do_redraw(w,w->wa);
	}

	wmenu_tnormal(w,MTCEDIT,true);
}

static
MENU_DO do_wshmenu
{
#if defined MTC1
		if ( title eq MTC1		) do_shFile	(w, choice);
#endif

#if defined MTCEDIT
		if ( title eq MTCEDIT	) do_shEdit	(w, choice);
#endif
	return true;
}

/* 02'14 HR simple selection via shift_click. */
static
BUTTON sheet_sel
{
	long  bx,by;
	CINF ns = {0};
/*
	short obx = 0;
	long  oby = 0;
*/
	wind_update(BEG_MCTRL);

/*	do
	{
*/		xy_to_unit(w, mx,my, &bx,&by);
		w->selty = 0;
		via(w->deselect)(w, LOW);
		ns.updn = ns.scrx = ns.pos.x = bx;
		ns.pos.y = by;

		if (C_cmp(&ns, &w->cu) < 0)
		{
			w->se = w->cu;
			w->cu = ns;
			w->ss = ns;
			w->selection = true;
		}
		elif (C_cmp(&ns, &w->cu) > 0)
		{
			w->ss = w->cu;
			w->se = ns;
			w->selection = true;
		}
		else
			w->cu = ns;

#if 1		/* table :: include clicked element */
		w->se.pos.x++;
		w->se.scrx++;
		w->se.updn++;
		w->se.pos.y++;
#endif
		via (w->select)(w);

/*		graf_mkstate(&mx,&my,&button,&state);
		obx=bx;
		oby=by;

	}
	while(button);
*/
	wind_update(END_MCTRL);
}

static
BUTTON do_shbutton		/* (IT *w, short button, short kstate,
                                           short bclicks,
                                           short mx, short my);	*/
{
	if (!w->wks.editing)
	{
		if (kstate & NKF_SHIFT)
			sheet_sel(w, kstate, NKF_SHIFT, bclicks, mx, my);		/* 02'14 HR (calc sheet columns only!) */
		else
		{
			short bob = objc_find(w->dial.ob,0,MAX_DEPTH,mx,my);
			via(w->deselect)(w,LOW);
			w->wks.editing = (bob eq SH_EDSTR or bob eq SH_COSTR) ? w->dial.edob : 0;
			w->dial.edon = ON;
			wdial_xytoi(w,mx,my);	/* set appropriate variable in w */
			wdial_itotmpl(w);
			wdial_on(w);
		}
	}
	else
		wdial_button(w,button,kstate,bclicks,mx,my);

	if (!w->wks.editing)
	{
		wdial_off(w);
		w->dial.edon = OFF;
		keusaf(ed[SH_CSTR]);
		sheet_click(w,1,NO_DRAG,1,mx,my);  /* left button, no state or drag, 1 click */
		disp_edit(w);
		wdial_draw(w,0);
		w->wks.editing = bclicks eq 2 ? w->dial.edob : 0;
		if (bclicks eq 2 or button eq 2)		/* same as ESC */
		{
			w->wks.editing=w->dial.edob;
			w->dial.edon = ON;
			wdial_itotmpl(w);
			wdial_on(w);
		}
	}
}

static
KEYBD do_shkeybd 			/*	w,kcode		*/
{
	CUR_TO rich = HIGH; short k = kcode & 0xff;
	if (w->wks.editing)
		wdial_keybd(w,kcode);
	else
	{
		keusaf(ed[SH_CSTR]);
		if (kcode < 0 and k eq NK_ESC)
		{
			w->wks.editing = w->dial.edob;
			w->dial.edon = ON;
			wdial_itotmpl(w);
			wdial_on(w);
		othw
			if (k eq NK_UP or k eq NK_LEFT)
				rich = LOW;
			via (w->deselect)(w, rich);
			do_std_cursor(w, kcode);
			disp_edit(w);
			wdial_draw(w, 0);
			cur_on(w);
		}
	}
}

void maxs(long x, char *s, char *t)
{
	x--;
	if (strlen(t) > x) t[x] = 0;
	if (strlen(s) > x) s[x] = 0;
}

static
DEXIT sh_edend
{
	SH_CELL n;			/* new cell */
#if DATES
	CELLP   o;			/* old cell */
#endif
	double v;
	char *s = ed_str->text,
	     *t = co_str->text;

	w->wks.editing = 0;
	wdial_off(w);
	w->dial.edon = OFF;
	keusaf(ed[SH_CSTR]);

	if ( (obno&0xff) eq SH_CSTR)		/* exit with return or click on cell name */
	{
		int ty; char *ide;
		int col = w->cu.scrx,
			row = w->cu.pos.y;
#if DATES
		o = get_cell(w,col,row);
		if (o)
		{
			if (    strcmp(o->text, s) eq 0
			    and strcmp(o->comm, t) eq 0
			   )
			   return;
			n.cre  = o->cre;
		othw
			n.cre.d = Tgetdate();
			n.upd.d = 0;
		}
#endif

		maxs(MAXI, s, t);
		strcpy(n.text, s);
		strcpy(n.comm, t);

		if (*s)
		{
			ide = is_label(s, &ty);
			if (ty)
			{
				w->wks.ides = store_ide(w->wks.ides, ide, ty, col, row);
				if (ty eq LAB)
					s += strlen(ide) + 2;
			}

			sh.col = col, sh.row = row;		/* 11'07 HR */
			v = shparse(w->wks.tab, w->wks.ides, s, &n.attr);

			switch (n.attr)
			{
			case FUN:
			case TXT:
				n.val = 0;
			esac
			case VAL:
			case FORM:
				n.val = v;
			esac
			}

			strcpy(w->wks.edstr, s);
			strcpy(w->wks.costr, t);

#if DATES
			if (change_cell(w, &n, ty, col, row, o eq nil))
#else
			if (change_cell(w, &n, ty, col, row, false))
#endif
				set_X(w);
		othw								/* clear cell */
			CELLP c = get_cell(w, col, row);
			if (c)
			{
				free_cell(w, c);
				get_cell(w, col, row) = nil;
				set_X(w);
				w->ismod = true;
			}
		}

		recalc(w);
		do_redraw(w, w->wa);
	}
}

extern RECT jrect;


/* these are not written; they only start the recursion */
global
OpEntry wkstab[] =
{
	{"FILE= {}\n", 0, file_cfg, 0, 0},
	{"\0"}
};

void load_sheetconfig(void)			/* files only */
{
	FILE *fp;
	setfn = dir_plus_name(&ipath, cfgname());

	fp = fopen(setfn.s,"r");
	if (fp ne nil)
	{
		loadconfig(fp, wkstab,0);
		fclose(fp);
	}
}

void save_sheetconfig(void)
{
	FILE *fp = fopen(setfn.s,"w");
	if (fp ne nil)
	{
		saveconfig(fp,wkstab,0);
		fclose(fp);
	}
}

static
WINIT sheet_winit
{
	w->in = overlap();
	snapwindow(w,&w->in);	/* !!! gebruikt slechts w->v !!! */
								/* mooi he? */
	w->frem=wwa;
	snapwindow(w,&w->frem);		/* snap fulled height */
}

MUIS m_pijl		/* IT *w */
{
	graf_mouse(0,nil);
}
/*
static
RECT sheetmargin = {0,0,0,0};
*/
IT *create_sheetw(
			bool cre,
			Cstr name,
			char *info,
			int fl,
			long mapl
		)
{
	IT *w;
	WH unit = deskw.unit;

	unit.w *= DEFCOLW;

	w = create_IT	(	cre,
					name,
					fl,
					info,
					nil,
					WKIND | (diagnostics ? INFO : 0),
					CALC,
					nil,
					nil,
					ed,				/* object (edit regel) */
					sh_place,		/* place edit line after size or move or full */
					0,
					sheet_winit,
					sh_edend,
					nil,			/* antedraw */
					sh_disp,		/* draw */
					nil,				/* postdraw */
					sh_evm,			/* ante event */
					nil,
					nil,				/* disp line */
					nil,				/* ante, - */
					nil,				/* post  display	*/
					sh_close,
					close_sheet,
					nil,				/* stanard topping? */
					fullwindow,
					slidewindow,
					v_slider,
					arrowwindow,
					sizewindow,
					movewindow,
					do_shbutton,
					do_shkeybd,
					nil,				/* ed_key implicit (NO ROM sheets) */
					nil,				/* timer */
				#ifdef WMENU
					menu_draw,
					do_wshmenu,
					nil,
					&cmen,
				#else
					nil,
					do_wshmenu,
					nil,
					nil,
				#endif
					sheet_select,			/* NO selection (yet), only cursor */
					sheet_deselect,
					sheet_wselect,
					std_cursor,
					upd_cinf,
					cinf_upd,
					m_pijl,
					nil,
					mapl,
					unit,
					deskw.points,
					nil
				);
	if (w)
	{
		w->mgw.x = LEFTMARGIN+deskw.unit.w/2;
		w->mgw.y = TOPMARGIN+2;
		w->mgw.h = ed->h + 2; /* deskw.unit.h+2; */
	}

	return w;
}

static
SH_SHEET make_sheet(IT *w, FILE *fx)
{
	int i,j;
	SH_SHEET t = mmalloc(sizeof(SH_TAB), "while allocating table","Abondoned", AH_SHEET);

	if (t)
		loop_all (*t)[i][j]=nil;

	w->wks.ides = nil;
	w->wks.tab  = t;
	this_w = w;		/* ugly, but needed */
	this_t = t;

	if (!fx)
	{
		w->wks.Ver = 1;	/* New (empty) files are of course new format */
		set_V(w);
	}

	return t;
}

static
void check_l(IT *w, SH_CELL *c, unsigned int cl, char *str)
{
	short l = strlen(str);
	if (l ne cl)
		alert_text("%s|%d/%d,l=%d,cosize=%d",w->title.t,c->col,c->row,l,c->cosize);
}

static
unsigned int get_ty(SH_CELL *c, char *t)
{
	short ty = TXT;

	if   (strcmp(t,attrs[0]) eq 0)
		ty = TXT;
	elif (strcmp(t,attrs[1]) eq 0)
		ty = VAL;
	elif (strcmp(t,attrs[2]) eq 0)
		ty = FORM;
	else
		alert_text("%d/%d|no attr: '%s'", c->col, c->row, t);

	return ty;
}

unsigned int get_str(IT *w, FILE *fx, SH_CELL *c, char *key, char *delim, char *sto)
{
	char str[MAXI*2], f[32];
	unsigned int l;
	int scn;

	strcpy(f, key);
	strcat(f, "=%d:%");
	strcat(f, delim);
	hgetpos(fx);
	scn = fscanf(fx, f, &l, str);

	if (scn < 2)
		hsetpos(fx);
	else
	{
		check_l(w, c, l, str);
		strsncpy(sto, str, MAXI-1);
	}

	return l;
}

unsigned int get_tonl(FILE *fx, char *sto)
{
	unsigned int l;
	fscanf(fx,"%d:%[^\n]\n",&l,sto);
	return l;
}

#if FIXPC
static
void al32(char *opm, FILE *fx)
{
	char s[32]; /* fpos_t xp = hp; */
	hgetpos(fx);
	fgets(s, 31, fx);
	alert_text("al32:%s: | '%s'", opm, s);
	hsetpos(fx);
}
#endif

void skip(FILE *fx)
{
	char sk[1024];
	fscanf(fx,"%[^\n]\n",sk);
}

#if 0
static char fill[1024] = "";		/* in data */
#elif 0
static char fill[1024];				/* in bss */
#endif


void load_sheet(SH_SHEET t, IT *w, FILE *fx)
{
	SH_CELL c;
	char cellty[128];
	int scn;
#if FIXPC
	char str[32] = "";
#endif
	c.col= -1;
	c.row = -1;
	def_head(w);

	scn = fscanf(fx,"HR95sheet=%d/%d,cws=%d;\n",
		&w->wks.head.cols,
		&w->wks.head.rows,
		&w->wks.head.colwsize	);

	if (scn ne 3)
	{
		/* New format using OpEntry tables */
		w->wks.Ver = 1;
		set_V(w);
		fseek(fx, 0, SEEK_SET);
		loadconfig(fx, calctab, 0);
	othw
		w->wks.Ver = 0;
		set_V(w);
		do			/* Old (original) format */
		{
			bool cel;

			memset(&c, 0, sizeof(c) );

/* 09'17 HR: ';' at start of line is comment */
/* Remember calc's .cal format is entirely text based. */
			scn = getc(fx);

			if (scn eq ';')
			{
 				skip(fx);
				continue;
			othw
				ungetc(scn, fx);	/* there is no fungetc with Pure C */
			}

#if FIXPC
			{
				hgetpos(fx);
				fgets(str, 31, fx);
				hsetpos(fx);
			}
#endif
			scn = fscanf(fx, CELS "=%d/%d,",&c.col,&c.row);

			if (   scn ne 2
			    or (   c.col < 0
			        or c.col > MAXCOLS
			        or c.row < 0
			        or c.row > MAXROWS
			       )
			   )
			{
#if FIXPC
				hsetpos(fx);
				al32(str, fx);
#endif
			    break;
			}

/* newload.h has  #if's */

	#if  DATES
			hgetpos(fx);
			scn = fscanf(fx, CRES "=%d," UPDS "=%d,",  &c.cre.d, &c.upd.d);

			if (scn < 2)
			{
				c.cre = defdate();
				c.upd.d = 0;
				hsetpos(fx);
			}
	#endif

			c.cosize = get_str(w, fx, &c, COMS, "[^|]|", c.comm);

			scn = fscanf(fx," %[^=]=",cellty);	/* naar get_ty ? */

/* oldload.h has (very old) original load */

			c.attr = get_ty(&c, cellty);

			switch(c.attr)
			{
			case TXT:
				c.size = get_tonl(fx, c.text);
			break;
			case VAL:
				scn = fscanf(fx, VALS "=%lg",&c.val);
				if (scn > 0)
				{
					fscanf(fx,",");
					c.size = get_str(w, fx, &c, TXTS, "[^\n]\n", c.text);
				}
				else
					fscanf(fx,"%lg\n",&c.val);
			break;
			case FORM:
				fscanf(fx, VALS "=%lg," FORS "=", &c.val);
				c.size = get_tonl(fx, c.text);
			}

			cel = new_cell(w, t, &c);

			if (!cel)
				break;
		}od
	}

	fclose(fx);
}

FOPEN open_sheet		/* Cstr fn, short fl, void *q */
{
	FILE *fx = nil;
	IT *w;
	SH_SHEET t;

	if (!ed)
		rsrc_gaddr(0,SH_EDOB,&ed);

	c_str   = get_tedinfo(ed,SH_CSTR );
	ty_str  = get_tedinfo(ed,SH_TYSTR);
	ed_str  = get_tedinfo(ed,SH_EDSTR);
	co_str  = get_tedinfo(ed,SH_COSTR);
#if DATES
	newstr  = get_tedinfo(ed,SH_NEW  );
	updstr  = get_tedinfo(ed,SH_UPD  );
#endif

	if ( (w=create_sheetw(
				true,
				fn,
				" ",
				0,
				0
				)
		 ) eq nil )
	{
		alertwindow("sheet");
	}
	else
	{
		if ( (t=make_sheet(w, fx)) eq nil)
		{
			close_w(w);
		othw
			fx = fopen(fn,"r");
			if (fx)
				load_sheet(t, w, fx);
			w->ismod = false;
			w->view.sz.w = MAXCOLS;
			w->view.sz.h = MAXROWS;
			w->op=wind_open(w->wh, w->in.x, w->in.y, w->in.w, w->in.h);
			get_work(w);
			wind_set(w->wh,WF_TOP);
			w->wks.editing=0;
			rowspace=fdenotation_space(MAXROWS, 10     );
			colspace=fdenotation_space(MAXCOLS, LETTERS);
			cur_on(w);			/* because no timer for sheets */
		}
	}
}
