/*  Copyright (c) 2013 - present by Henk Robbers Amsterdam.
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

/*
 * F_x.C
 *
 *	parse and evaluate  a expression in a string as a funxtion of x
 *  where x is passed as a parameter alongside the string.
 *
 *	There is also a variable y.
 *
 *	Values of both x and y must be passed to function F_x.
 *	Values <= 0 implement the defaults which are 10 for x and 2 for y (but see fu F_x below)ß.
 */

#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <ctype.h>
#include "f_x.h"

char * Pos;
Token Cur;
PARSE parsepar={nil};
Token eoln  ={BAD,EOLN,"eoln",HUGE_VAL};	/* dont put this one in the table */
Token BADTOK=BADSTR;
double varx,	/* to be set by routines that perform f(x) = (formula on x) for many x's */
       vary;	/* to be set by routines that perform f(y) = (formula on y) for many y's */
				/* or, of course, formulas that use both. */

static
bool is_end(char c)
{
	return c eq 0 or c eq '\r' or c eq '\n';
}

static
bool is_ws(char c)
{
	return c eq ' ' or c eq '\t';
}

static
#if __AHCC__
PARSE_NEXT parsenext		/* see f_x.h */
#else
Token parsenext(void)
#endif
{
	Cur=BADTOK;

	while (is_ws(*Pos)) Pos++;

	if (is_end(*Pos))
	{
		Cur = eoln;
		return Cur;
	}

	Pos = parselook(Pos);

	return Cur;
}

global
void parsedef(PARSE_NEXT *token, Token (*tab)[])
{
	parsepar.tok=token ? token : parsenext;
	parsepar.tab=tab ? tab : &parsetab;

	parsepar.c=BADTOK;
}

global
Token parsetab[]=
{
	{NUM,	PRIMARY,"pi",M_PI},
	{NUM,	PRIMARY,"e", M_E},
	{NUM,	PRIMARY,"r", 180/M_PI},
	{VX,	PRIMARY,"x", 0},
	{VY,	PRIMARY,"y", 0},
#if SHEET
	{LHELM,	PRIMARY,"lhelm"},
	{FHELM,	PRIMARY,"fhelm"},
#endif
	{RABS,	PRIMARY,"|" },
	{LPAR,	PRIMARY,"("	},
	{ABS,	UNARY,"abs" },
	{SQRT,	UNARY,"V"	},
	{SQRT,	UNARY,"sqrt"},
	{SQRT,	UNARY,"\xfb"},		/* real V graph */
	{SQR,	UNARY,"sqr"	},
	{SINH,	UNARY,"sinh"},
	{COSH,	UNARY,"cosh"},
	{TANH,	UNARY,"tanh"},
	{SIN,	UNARY,"sin"	},
	{COS, 	UNARY,"cos"	},
	{TAN,	UNARY,"tan"	},
	{ASINH, UNARY,"asinh"},
	{ACOSH, UNARY,"acosh"},
	{ASIN,	UNARY,"asin"},
	{ACOS,	UNARY,"acos"},
	{ATAN,	UNARY,"atan"},
	{LOG10,	UNARY,"log10"},
	{LN,	UNARY,"log"	},
	{LN,	UNARY,"ln"	},
	{EXP,	UNARY,"exp"	},
	{INT,	UNARY,"int" },
	{TORAD,	UNARY,"tor"	},
	{TODEG,	UNARY,"tod"	},
#if SHEET
	{DEREF, UNARY,"<-"	},
	{MAX,	BINARY+8,"max"},
	{ELSE,	BINARY+10,"!"},
	{QUEST,	BINARY+12,"?"},
#endif
	{OR,	BINARY+14,"|"},
	{OR,	BINARY+14,"or"},
	{AND,	BINARY+16,"&"},
	{AND,	BINARY+16,"and"},
#if SHEET
	{EQ,	BINARY+18,"="},
	{NEQ,	BINARY+18,"<>"},
	{LTEQ,	BINARY+20,"<="},
	{LESS,	BINARY+20,"<"},
	{GTEQ,	BINARY+20,">="},
	{GREAT,	BINARY+20,">"},
#endif
	{PLUS,	BINARY+23,"+"},		/* priority even: can also be unary */
	{MIN,	BINARY+23,"-"},		/* BINARY itself must be uneven!!	*/
	{TIM,	BINARY+26,"*"},
	{DIV,	BINARY+26,"/"},
	{POW,	BINARY+30,"^"},
#if SHEET
	{RANGE, BINARY+32,":"},
#endif
	{RPAR,	PRIMARY-2,")"},		/* stoppers */
	BADSTR						/* also table terminator */
};

global
Token bad_tok(char *s)
{
	Token r=BADTOK;
	r.name = s;
	return r;
}

static
bool can_un(int p)
{
	return p >= 0 and (p&1) eq 0;
}

static
char * sk(char *s)
{
	while (is_ws(*s)) s++;
	return s;
}

static
char * is_min(char *s, bool *sign)
{
	bool m = *s eq '-';
	if (m) s++;
	*sign = m;
	return s;
}

global
char * get_int(char *s, int *i)
{
	int j = 0; bool sign;
	*i = 0;
	s = is_min(s, &sign);
	while (*s and (*s >= '0' and *s <= '9'))
		j = j*10+(*s++-'0');
	*i = sign ? -j : j;
	return s;
}

global
char * get_long(char *s, long *i)
{
	long j = 0; bool sign;
	*i = 0;
	s = is_min(s, &sign);
	while (*s and (*s >= '0' and *s <= '9'))
		j = j*10+(*s++-'0');
	*i = j;
	*i = sign ? -j : j;
	return s;
}

global
char * get_flo(char *s, double *f)
{
	char * e;
	*f = strtod(s, &e);
	return (char *)e;
}

global
char * get_hex(char *s, long *l)
{
	long j = 0;
	*l = 0;
	while (*s)
	{
		uchar c = tolower(*s);
		if (c >= '0' and c <= '9')
			j = j*16+(c-'0');
		elif (c >= 'a' and c <= 'f')
			j = j*16+(c-'a'+10);
		else break;
		s++;
	}
	*l = j;
	return s;
}


global
char *parselook(char *s)
{
	char *save=s;
	char c = tolower(*s);
	if ( c eq 'h')		/* N.B. x is the builtin variable. */
	{
		long l;
		s++;
		s = sk(s);
		s = get_hex(s, &l);
		Cur.t = NUM;
		Cur.p = PRIMARY;
		Cur.v = l;
		Cur.name = save;
	}
	elif ( (c >= '0' and c <= '9') or c eq '.')
	{
		s = get_flo(s, &Cur.v);
		Cur.t = NUM;
		Cur.p = PRIMARY;
		Cur.name = save;
	othw
		Token *z=*parsepar.tab;
		while (z->t ne BAD)		/* table lookup */
		{
			char *cz=z->name;
			save=s;
			while (*cz)
			{
				if (*s eq 0  ) break;
				if (*s ne *cz) break;
				s++,cz++;
			}
			if (*cz eq 0)		/* must have been equal */
			{
				Cur=*z;			/* make a copy */
				if (Cur.t eq VX)
				{
					Cur.v = varx;
					Cur.t = NUM;
				}
				elif (Cur.t eq VY)
				{
					Cur.v = vary;
					Cur.t = NUM;
				}
				break;
			}
			else
				s=save;
			z++;
		}

		if (z->t eq BAD)			/* token not found (the real BAD from the table */
		{
			s = save;
/*			printf("BAD: got '%s'\n", s); */
			if (*s >= 'a' and *s <= 'z')
			{

				Cur.p = PRIMARY;
				Cur.name = s;
				while (*s >= 'a' and *s <= 'z')
					s++;
#if SHEET
				Cur.t = IDE;
#else
				Cur.t = BAD;
				*s = 0;
#endif
			}
			else
			{
#if 0
				/* The below bombs on MACOS
				 * Probably the string is put in read only memory by Xcode
				 */
				static char *e="'?': bad token";
				*(e + 1) = *s++;
#else
				static char e[] = "'?': bad token";
				e[1] = *s++;
#endif
				Cur = bad_tok(e);
			}
#if SHEET
		othw
	#if 0
			if (    z->t eq RANGE
			    and *s eq '%'
			   )
			{
				s++;
				s = get_int(s, &Cur.step);
			}
	#else
			if (z->t eq RANGE)
			{
				save = s;
				s = sk(s);
				if (*s eq '%')
				{
					s++;
					s = get_int(s, &Cur.step);
				}
				else
					s = save;
			}
	#endif
#endif
		}
	}

	return s;
}

static
Token parse_unop(Token o, Token r)
{
	if (is_bad(r))
		return r;
	switch(o.t)
	{
		case ABS:
		if (r.v < 0) r.v = -r.v;
		break;
		case MIN:
			r.v=-r.v;
		break;
		case PLUS:
			r.v=+r.v;
		break;
		case SQRT:
			r.v=sqrt(r.v);
		break;
		case SQR:
			r.v*=r.v;
		break;
		case SIN:
			r.v=sin(r.v);
		break;
		case COS:
			r.v=cos(r.v);
		break;
		case TAN:
			r.v=tan(r.v);
		break;
		case ASIN:
			r.v=asin(r.v);
		break;
		case ACOS:
			r.v=acos(r.v);
		break;
		case ATAN:
			r.v=atan(r.v);
		break;
		case SINH:
			r.v=sinh(r.v);
		break;
		case COSH:
			r.v=cosh(r.v);
		break;
		case ASINH:
			r.v=asinh(r.v);
		break;
		case ACOSH:
			r.v=acosh(r.v);
		break;
		case TANH:
			r.v=tanh(r.v);
		break;
		case LOG10:
			r.v=log10(r.v);
		break;
		case LN:
			r.v=log(r.v);
		break;
		case INT:
			r.v=floor(r.v);
		break;
		case EXP:
			r.v=exp(r.v);
		break;
		case TORAD:
			r.v*=M_PI/180;
		break;
		case TODEG:
			r.v*=180/M_PI;
		break;
#if SHEET
		case DEREF:
		{
			int attr;
			r.v = shderef(r, &attr);
			if (attr eq BAD)
				return bad_tok("bad dereference");
		}
		esac
#endif
		default:
			return bad_tok("bad unary operator");
	}
	o.t=NUM;
	o.p=PRIMARY;
	o.v=r.v;
	o.name="unary result";
	return o;
}

static
Token Binary(Token l, bool haveleft);	 /* recursion */

#if 0
static Token * ftok(short i)
{
	Token *t = parsetab;

	while(t->t ne BAD)
	{
		if (t->t eq i)
			return t;
		t++;
	}
	return &BADTOK;
}
#endif

static
Token Primary(void)
{
	return parsepar.tok();		/* get next token. */
}

static
Token parse_binop(Token o, Token l, Token r)
{
	double lv = l.v, rv = r.v;

	if (is_bad(l))
		return l;
	if (is_bad(r))
		return r;

	switch(o.t)
	{
		case MIN:
			lv-=rv;
		break;
		case PLUS:
			lv+=rv;
		break;
		case TIM:
			lv*=rv;
		break;
		case DIV:
			lv/=rv;
		break;
		case POW:
			lv=pow(lv,rv);
		break;
		case OR:
			lv=lv or rv;
		esac
		case AND:
			lv=lv and rv;
		esac
#if SHEET
		case RANGE:
			lv=shrange(o,l,r);
		esac
		case EQ:
			lv=lv eq rv;
		esac
		case NEQ:
			lv=lv ne rv;
		esac
		case LESS:
			lv=lv<rv;
		esac
		case LTEQ:
			lv=lv <= rv;
		esac
		case GREAT:
			lv=lv > rv;
		esac
		case GTEQ:
			lv=lv >= rv;
		esac
		case QUEST:
			if (lv)
				l.truth=2,
				lv=rv;
			else
				l.truth=1,
				lv=0;
			o.truth=l.truth;
		esac
		case ELSE:
			if (l.truth eq 0)
				return bad_tok("bad triadic operator");
			else
			if (l.truth eq 1)	/* ? yielded false */
				lv=rv;
			l.truth=0;
			o.truth=l.truth;
		esac
#endif
		default:
			return bad_tok("bad binary operator");
	}
	o.t=NUM;
	o.p=PRIMARY;
	o.v=lv;
	o.name="binary result";
	l.v = lv;
	return o;
}

static
Token Unary(void)
{
	Token o=Cur,r;

	if (can_un(o.p))
	{
		Primary();
		o.p=UNARY;
		r=Unary();
		r=parse_unop(o,r);
	othw						/* is primary */
		if (o.t eq LPAR)		/* left parenthesis */
		{
			r=Binary(Primary(),need_LEFT);		/* whole expression as primary */
			if (Cur.t ne RPAR and !is_bad(r))
				r=bad_tok("missing ')'");
		}
		elif (o.t eq RABS)		/* right stroke */
		{
			r=Binary(Primary(),need_LEFT);		/* whole expression as primary */
			if (Cur.t ne RABS and !is_bad(r))
				r=bad_tok("missing '|'");
			elif (r.v < 0)
				r.v = -r.v;
		}
		else
			r=o;
	}
	return r;
}

static
Token Binary(Token l, bool has_left)
{
	Token o,r;							/* operator, right part */

	if (!has_left)
		l=Unary(), Primary();			/* for left part */

	while (is_bin(Cur))
	{
		o=Cur, Primary();				/* for operator */
		r=Unary(), Primary();			/* for right part */

		if (is_bin(Cur))
		{
			if (Cur.p > o.p)			/* next is higher */
				r = Binary(r,has_LEFT);
			else
			if (Cur.p < o.p)			/* next is lower:  */
				if (has_left)			/* if not at root level */
					return parse_binop(o,l,r);		/* leave recursion */
		}
		l = parse_binop(o,l,r);	/* equal priority; evaluate left to right (iterative) */
	}
	return l;
}

/* A recursive descent parser and interpreterß */
global
Token F_x(double x, double y, char *s)
{
	if (!parsepar.tok)
		parsedef(nil, nil);
	varx = x > 0 ? x : 10;
	vary = y > 0 ? y :  2;
	Pos = s;
	return Binary(Primary(), need_LEFT);
}
