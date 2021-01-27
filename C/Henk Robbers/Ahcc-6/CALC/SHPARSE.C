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

/*
 *		SHPARSE.C
 */

#include <string.h>
#include <ctype.h>
#include <math.h>

#include "common/aaaa_lib.h"
#include "common/F_x.h"
#include "sheet.h"

static SH_SHEET cell;
static bool isformula;

int colspace,rowspace;

int fdenotation_space(int big, int root)
/* Returns the width in spaces of number denotation
	( root: number of digits in system )
	( big: biggest number that must fit in the space) */
{
	return big ? log(big+1)/log(root)+1 : 1;
}

int abs(int a) { return a < 0 ? -a : a; }
int alert_msg(char *t, ...);
void send_msg(char *t, ...);

static void *Ides = nil;

IDES * find_ide(char *s)
{
	IDES *id = Ides;
	char *ide = is_label(s, nil);

	while (id)
	{
		if (strcmp(ide, id->name) eq 0)
			return id;

		id = id->next;
	}

	return nil;
}

double shrange(Token o, Token l, Token r)
{
	int i, j, a, lr, rr, lc, rc, step;
	double low = 0,high = 0;
	CELLP c;

	l.v = 0.0;
	a = 0;
	step = abs(o.step);

	if (step eq 0)
		step = 1;

	lr = rr = l.row;
	if (r.row < l.row)
		lr = r.row;
	else
		rr = r.row;

	lc = rc = l.col;
	if (r.col < l.col)
		lc = r.col;
	else
		rc = r.col;

	for (i = lc; i <= rc; i += step)
		for (j = lr; j <= rr; j += step)
			if (    i >= 0 and i < MAXCOLS
			    and j >= 0 and j < MAXROWS
			   )
				if ( (c = pget_c(cell, i, j)) ne nil)
					if (c->attr eq FORM or c->attr eq VAL)
					{
						if (a eq 0)			/* first */
						{
							low  = c->val;
							high = c->val;
						}
						if (c->val > high)
							high = c->val;
						if (c->val < low)
							low = c->val;
						a += 1;
						l.v += c->val;
					}

#if AVRG
	if (o.t eq AVRG and a > 0)
		return l.v / a;
#endif
#if COUNT
	if (o.t eq COUNT)
		return a;
#endif
#if MAXIM
	if (o.t eq MAXIM)
		return high;
#endif
#if MINIM
	if (o.t eq MINIM)
		return low;
#endif
	return l.v;
}

static
bool relname(char **input, int *col, int *row, int ccol, int crow)
{
	int c = 0, r = 0;
	char *s = *input, *save = s;

	s = get_int(++s, &c);

	if (*s eq ',')
	{
		s++;
		s = get_int(s, &r);
	}

	Cur.name = save;

	if (*s eq ']')
	{
		*input = ++s;

		c += ccol;
		r += crow;

		if (    c >= 0
		    and c <  MAXCOLS
		    and r >= 0
		    and r <  MAXROWS)
		{
			*col = c;
			*row = r;
#if 0
{
	/* for testing strtra, strrep & alert_secure.  */
	char o[128];
	char *t = "12a45b78c0";
	alert_text("relname:|'%s'", alert_secure(127, save) );
	strcpy(o, t);
	strrep(127, o, "a3b6c9");
	alert_text("strrep: |'%s'-->|'%s'", t, o);
}
#endif
			return true;
		}
	}

	*input = s;
	return false;
}

bool letter(uchar *s)
{
	return *s >= 'a' and *s <= 'z';
}

bool digit(uchar *s)
{
	return *s >= '0' and *s <= '9';
}


global
char *  absname(char **input, int *pl, int *col, int *row)
{
	short len, c = 0, r = 0;
	char *s = *input, *start, *ss, numstring[10];
	short l = 0;
	start = s;
	ss = s;
	loop(len,colspace)
		if (letter((uchar *)s)) s++; else break;

	if (len)
	{
		l = len;
		strncpy(numstring, start, len);
		numstring[len] = '\0';
		c = crbv(numstring, 'a');
		if (c < MAXCOLS)
		{
			start = s;
			loop(len, rowspace)
				if (digit((uchar *)s)) s++; else break;

			if(len)
			{
				l += len;
				strncpy(numstring, start, len);
				numstring[len] = '\0';
				r = cdbv(numstring)-1;
				if(r < MAXROWS)
				{
					*col = c;
					*row = r;
					*input = s;
					if (pl)
						*pl = l;
					Cur.name = ss;
					return ss;
				}
			}
		}
	}

	*input = s;
	Cur.name = "X";
	return nil;
}

global
bool cellname(char **input, int *col, int *row, int ccol, int crow)
/* Returns true if the string starts with a cell name, false otherwise.
   Also returns the column and row of the cell name. */
{
	char *s = *input;
	if (*s eq '[')		/* relative name */
		return relname(input, col, row, ccol, crow);
	else
		return absname(input, nil, col, row) ne nil;
}

static
double get_val(int col, int row)
{
	CELLP c = pget_c(cell, col, row);
	if (c)
		return c->val;
	else
		return 0.0;
}

PARSE_NEXT shnext
{
	bool iscell = false;
	char *save;

	Cur=BADTOK;

	while (*Pos eq ' ')
	Pos++;

	if (*Pos eq 0)
	{
		Cur = eoln;
		return Cur;
	}

	save = Pos;

	iscell = cellname(&Pos, &Cur.col, &Cur.row, sh.col, sh.row);

	if (iscell)
	{
		CELLP c = pget_c(cell, Cur.col, Cur.row);
		Cur.t = NUM;
		Cur.p = PRIMARY;
		Cur.name = "N";
		isformula = true;
		if (c)
			Cur.v = c->val;
		else
			Cur.v  = 0.0;
	othw
		Pos = parselook(save);

		if (Cur.t eq IDE)
		{
			IDES *id = find_ide(Cur.name);
			if (id)
			{
				Cur.t = NUM;
				Cur.p = PRIMARY;
				Cur.col = id->col;
				Cur.row = id->row;
				Cur.v = 0;
				isformula = true;
			}
			else
				Cur = bad_tok("undefined ide");
		}
		elif (Cur.t eq LHELM or Cur.t eq FHELM)
		{
		/* Helmoltz formula of a resonator */
			double c2 = 343.0*343,	/* speed of sound in air of 20 degr C, squared */
				   pi = M_PI, O , V, f, l;
			if (Cur.t eq LHELM)		/* produces pipe length */
			{
				O = get_val(sh.col, sh.row - 1);
				V = get_val(sh.col, sh.row - 2);
				f = get_val(sh.col, sh.row - 3);
				Cur.v =((c2*O)/(4*pi*pi*f*f*V))-.5*sqrt(pi*O);
			}
			else
			if (Cur.t eq FHELM)		/* produces frequency */
			{
				l = get_val(sh.col, sh.row - 1);
				O = get_val(sh.col, sh.row - 2);
				V = get_val(sh.col, sh.row - 3);
				Cur.v=sqrt((c2*O)/(4*pi*pi*V*((sqrt(pi*O)/2)+l)));
			}
			Cur.t = NUM;
			isformula = true;
		}
	}
	return Cur;
}

CELLP get_c(int col, int row)
{
	return pget_c(cell, col, row);
}

double shderef(Token r, int *attr)
{
	CELLP p = pget_c(cell, r.col, r.row);
	*attr = 0;
	if (p)
	{
		Token n;
		char *save = Pos;
		char *t = p->text;
		while(*t >= 'a' and *t <= 'z') t++;		/* simple lower case 'name=' */
		if (*t eq '-' and *(t+1) eq '>')
		{
			t+=2;
			Pos = t;
			n = F_x(10, 2, t);
			if (Cur.p ne EOLN)
				n = bad_tok("<-text");
			if (is_bad(n))
				*attr = BAD;
			Pos = save;
			return n.v;
		}
		elif (*t eq ':' and *(t+1) eq ':')
			return p->val;
	}
	return r.v;
}

double shparse(SH_SHEET c, IDES *ides, char *s, unsigned int *attr)
{
	Token n;
	isformula = false;

	cell=c;

	Ides = ides;
	parsedef(shnext, nil);

	n = F_x(10, 2, s);

	if (Cur.p ne EOLN)		/* other things after what is actually */
		n = bad_tok("txt");	/* itself a valid expression, */
							/* must be treated as text */
	if (n.t eq NUM and isformula)
		*attr = FORM;
	else
		if (n.t eq NUM)
			*attr = VAL;
		else
			*attr = TXT,n.v = 0.0;

	return n.v;
}
