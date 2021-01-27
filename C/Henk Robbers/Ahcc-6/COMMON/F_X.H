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
 *		F_x.H
 */

#include "prelude.h"

#define has_LEFT 1
#define need_LEFT 0

typedef double Tmode;

enum
{
/* priorities */
	PRIMARY=-1,
	UNARY,
	BINARY,
/* terminators */
	RPAR=100,
	EOLN=-100,
/* primaries */
	BAD=-1,
	NAKS,
	NUM,
	IDE,
#if SHEET
	LHELM,			/* bip helmholtz giving pipe length */
	FHELM,			/*  "      "        "   Fb	   */
#endif
	LPAR,
	VX,				/* 10'17 HR: x variable, to be set outside in varx */
	VY,				/* 10'17 HR: y variable, to be set outside in vary */
#if ! SHEET
	VZ,				/* 05'18 HR: z variable, aka accumulator */
	/* The above names cannot be changed without recompilation
		of the parser (F_x.c) itself.
		The following names are used in the table only (parsetab.c) and can be changed
		in any way as long as you change parsetab.c accordingly,
		well keeping the whole thing consistent.
	*/
#endif
/* unaries  */
	SQRT,			/* Square root */
	CURT,			/* Cubic  root */
	SQR,
	ABS,
	RABS,
	SIN,
	COS,
	TAN,
	ASIN,
	ACOS,
	ATAN,
	SINH,
	COSH,
	ASINH,
	ACOSH,
	TANH,
	LOG10,
	LOG2,
	LN,
	EXP,
	INT,
	TORAD,
	TODEG,
#if SHEET
	DEREF,
/* binaries	*/
	LESS,
	LTEQ,
	GREAT,
	GTEQ,
	EQ,
	NEQ,
	OR,
	AND,
	QUEST,
	ELSE,
	MAXIM,
	MINIM,
#endif
	PLUS,			/* PLUS & MIN can also be unary	*/
	MIN,
	TIM,
	DIV,
	POW,
#if SHEET
	COUNT,
	AVRG,
	RANGE,
#endif
	LAATSTE
};

typedef struct
{
	int   t,p;
	char * name;
	Tmode v;
#if SHEET
	int   col,row,step;	/*	for use in calc.prg */
	bool  truth;		/*   "                  */
#endif
} Token;


#define is_bad(x) (x.t eq BAD)
#define is_op(x) (x.p >= UNARY)
#define is_un(x) (x.p eq UNARY)
#define is_bin(x) (x.p > UNARY)
#define is_prim(x) (x.p eq PRIMARY)

typedef Token PARSE_NEXT(void);

#define BADSTR {BAD,PRIMARY-10,"  bad_tok  ",HUGE_VAL}

Token F_x(double x, double y, char *s);

#if SHEET
	double shrange(Token o, Token l, Token r);
	double shderef(Token r, int *attr);
#endif

typedef struct parseinfo
{
	PARSE_NEXT *tok;
	Token c;
	char *str;
	Token (*tab)[];
} PARSE;

extern char * Pos;
extern Token  Cur;

char * parselook(char * s);
extern Token parsetab[],eoln,BADTOK;
extern PARSE parsepar;

void	parsedef	(PARSE_NEXT *, Token (*)[]);
Token	bad_tok		(char *s);
char *	get_int		(char *, int *);
char *	get_long	(char *, long *);
char *	get_flo		(char *, double *);
char *	get_hex		(char *, long *);
