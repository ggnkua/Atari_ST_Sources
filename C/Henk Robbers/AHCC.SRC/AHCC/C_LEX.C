/* Copyright (c) 1990 - present by H. Robbers.
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

/*	A pretokenizer based on the C language.

	input: character string.
	output: aggragation of LEX_RECORD structures.

	Its concept is kept as simple as possible.
	A text is divided in:
		identifiers (letter + opt(letters + digits))
		numbers
		new line's
		consecutive white space (space or tab)
		C operator characters in 2 kinds: single or multiple
		consecutive punctuation (anything else)

	lines are spliced on encountering \ followed by newline or carriage return
	comments are skipped /* /* */ */ //
	A copy of the original can be produced (see testframe)

	Splicing may lead to LEX_RECORD's longer than 255, so strings ar split up
	accordingly and later (as ANSI allows) catenated again.

	Because everything is done in a single function it is extremely fast,
	making maximum use of registers.

	On a TT it takes 0.15 seconds for a 60Kb C source file.
	On a 3 GHz Aranym machine everything will appear to be instantaneous :-)

	Due to the nature of the process, the output cannot become larger then
	4 times the input:

	If every character changed catagory each character would result in:

	1 byte record length
	1 byte catagory
	1 byte of source
	1 byte null termination
*/

#include <stdio.h>
#include <string.h>
#include <tos.h>
#include "c_lex.h"

#ifdef TOK_FREQ
#include <stdlib.h>
#endif

void console(char *, ...);

#ifdef TOK_FREQ
static
char *catx[] =
{
	"eof",
	"ide",
	"oct",
	"dig",
	"hex",
	"spl",
	"nl ",
	"com",
	"op ",
	"mop",
	"op2",
	"op3",
	"X  ",
	"ws ",
	"quo",
	"apo",
	"cok",
	"Last",
	"???"
};

static
char *pcat(short c)
{
	if (c < 0 or c > Last)
		c = Last+1;
	return catx[c];
}

global
void pr_lex(LEX_RECORD *s, char *txt)
{
	console("LEX records '%s'\n", txt);
	while(s->cat ne eof)
	{
		size_t tl = strlen(s->text);

		if (s->rl - 3 ne tl)
			console("* %ld * %s[%3d]-=%s=-\n",tl, pcat(s->cat), s->rl, s->text), Cconin();
		else
			console("%s[%3d]-=%s=-\n", pcat(s->cat), s->rl, s->text);

		s = next_LEX(s);
	}
	console("****\n");
	Cconin();
}

typedef struct
{
	short c;
	long t;
} TFREQ;

static
TFREQ tok_freq[Last+1];

global
void zero_tok_freq(void)
{
	short i;
	rzero(tok_freq);
	for (i=0;i<=Last;i++) tok_freq[i].c = i;
}

StdCompare comp_freq
{
	TFREQ *e1 = p1, *e2 = p2;
	  if (e1->t > e2->t) return -1;
	elif (e1->t < e2->t) return  1;
	return 0;
}


global
void print_tok_freq(void)
{
	void send_msg(char *text, ...);
	short i;
	qsort(tok_freq, Last+1, sizeof(TFREQ), comp_freq);
	send_msg("\nLex token frequencies:\n");
	for(i = 0; i <= Last; i++)
		if (tok_freq[i].t)
			send_msg("%s: %ld\n", pcat(tok_freq[i].c), tok_freq[i].t);
}
#endif

/* selection & translation tables */
static
uchar C_simple[256] =	/* simple character catagorization */
{
	0,X,X,X,X,X,X,X,X,ws,nl,X,X,nl,X,X,
	X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,

/*     !    "   #  $   %   &   '   (  )   *   +  ,   -   .   /     */
	ws,mop,quo,mop,hex,mop,mop,apo,op,op,mop,mop,op,mop,mop,mop,

/*                                          :   ;   <   =   >  ?   */
	dig,dig,dig,dig,dig,dig,dig,dig,dig,dig,mop,op,mop,mop,mop,op,

/*  @   in embedded assembler: structure@member for offset */
	op,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,

/*                                              [   \  ]   ^   _   */
	ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,op,mop,op,mop,ide,

	X,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,

/*                                              {   |  }  ~        */
	ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,op,mop,op,op,X,

	ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,
	ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,ide,
	ide,ide,ide,ide,ide,ide,ide,ide,ide,X,X,X,X,X,X,X,
	ide,ide,ide,ide,ide,ide,ide,ide,ide,X,X,X,X,X,X,X,
	X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,
	X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,
	X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,
	X,X,X,X,X,X,X,X,X,X,X,X,X,X,X,X
};

global
uchar C_hex[256] =
{
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	'0','1','2','3','4','5','6','7','8','9',0,0,0,0,0,0,
	0,'a','b','c','d','e','f',0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,'a','b','c','d','e','f',0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};

global
uchar C_oct[256] =
{
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	'0','1','2','3','4','5','6','7',0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
	0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
};

#if SCONSPLIT
/* must not split a escape sequence !! */
uchar * split(uchar *t, uchar *s)	/* s points past a string */
{
	uchar *p;
	s--;
	p = s;
	while (*p ne '\\' and p >= t) p--;		/* find slash */
	if (*p eq '\\' and s - p < 4)
		return p-1;
	return s;
}

#endif

uint next_s(uchar **s)
{
	uint c = **s;
	if (**s) *s += 1;
	return c;
}

/* concise alternative of sprintf("%ld", l) */
size_t ltos(Wstr o, long l)
{
	char s[12], *a = s+11, *p = o;
	*a-- = 0;
	do *a--=l%10+'0'; while ((l/=10) != 0);
	a++;
	while(*a) *o++=*a++;
	return o - p;
}


global
long C_lexical(short which, Cstr name, bool I, Cstr input, LEX_RECORD *output, long *lines, VpPE *perr, bool nest_com, short lang)
{
	LEX_RECORD *out = output;
	uchar *s = (uchar *)input;
	long l, tot = 0, lineno = 1, incom = 0;
	short t, ti, nr = 0;
	while (*s)					/* input is a true C string */
	{
		char *o = out->text;
#if SCONSPLIT
		uchar *fro = s;
#endif
		uint c = *s++;
		t = ti = C_simple[c];	/* get category */
		out->cat = t;
		if (t eq nl)			/* new line: puts line number as data */
		{
			lineno++;
			if (c eq '\r' and *s eq '\n')
				s++;
			if ((long)o & 1)
				o++;
			*(long *)o = lineno;
			o += sizeof(long);

			if (lang eq 's' and *s eq '*')	/* assembler comment '*' must be first in a line */
			{
				while (*s)
				{
					if (*s eq '\n')
					{
						*o++ = ' ';
						out->cat = com;
						break;
					}
					s++;
				}
			}
		}
		else
		{
			if (t eq ide)
			{
				while (ti eq ide or ti eq dig)
				{
					*o++ = c;
					c = *s++;
					ti = C_simple[c];
				}
				s--;
				*o = 0;
			}
			else			/* punctuation or digits */
			{
				if (    t eq dig
				    and c eq '0'
				    and (*s eq 'x' or *s eq 'X')
				   )
				{
					*o++ = c;
					*o++ = *s++;
					while ((c= C_hex[*s]) ne 0)
						*o++ = c, *s++;
					out->cat = hex;
				}
				elif (t eq hex)
				{
					if (lang eq 's')		/* 10'14 v5.2 */
					{
						*o++ = '0';
						*o++ = 'x';
						while ((c= C_hex[*s]) ne 0)
							*o++ = c, *s++;
						out->cat = hex;
					othw					/* 10'14 v5.2 */
						out->cat = op;
						goto todef;
					}
				}
				elif (t eq mop and c eq '/' and *s eq '*')
				{
					short lvl = 0;
					incom = 1;

					s++;
					while (*s)
					{
						if (*s eq '\n')
							lineno++;
						if (nest_com and *s eq '/' and *(s+1) eq '*')	/* 01'10 HR ooofff nested comments ? */
							s += 2, lvl++;
						elif (*s eq '*' and *(s+1) eq '/')
						{
							s += 2;
							if (lvl eq 0)
							{
								incom = 0;
								break;
							}
							lvl--;
						}
						else
							s++;
					}

					*o++ = ' ';
					out->cat = com;
				}
				elif (t eq quo or t eq apo)
				{
					*o++ = c;
					while (*s)
					{
						if (*s eq '\r' or *s eq '\n')
						{
							if (*s eq '\r' and *(s+1) eq '\n')
								s++;
						/*	if (t eq apo) */
								break;
						}
						if (    *s eq '\\'
						    and (*(s+1) eq c or  *(s+1) eq '\\')
						   )
						{
							*o++ = *s++;
							*o++ = *s++;
						}
						elif (*s eq c)
						{
							*o++ = *s++;
							break;
						}
						elif (    *s eq '\\'
						      and (*(s+1) eq '\r' or *(s+1) eq '\n')
						     )
						{
							s++;
							if (*s eq '\r')
								s++;
							if (*s eq '\n')
								s++;
							lineno++;
						}
						else
							*o++ = *s++;
#if SCONSPLIT
						if (o - out->text > MAX_SCON - 2)	/* 07'15 v5.2 */
						{
							uchar *p;
						#if 1
							p = split(fro, s);
							o -= s-p-1;
						#else
							p = s-1;
						#endif
							*o++ = c;
							*p = c;
							s = p;
							break;
						}
#endif
					}
				}
				elif (lang eq 's' and t eq op and c eq ';')
				{
					while (*s)
					{
						if (*s eq '\n')
						{
							*o++ = ' ';
							out->cat = com;
							break;
						}
						s++;
					}
				}
				elif (t eq mop)		/* multiple tokens */
				{
					switch((c<<8)|*s)	/* its C_lex */
					{					/*     =     */
						case '//':
							s++;
							while (*s and *s ne '\n') s++;
							*o++ = ' ';
							out->cat = com;
						break;
						case '##':
							if (*(s+1) eq '#' and *(s+2) eq '#')
							{
								*o++ = c;
								*o++ = *s++;
								*o++ = *s++;
								*o++ = *s++;
								c = *s;
								ti = C_simple[c];
								out->cat = op3;
							othw
								*o++ = c;
								*o++ = *s++;
								c = *s;
								ti = C_simple[c];
								out->cat = op2;
							}
						break;
						case '>>':			/* trops */
						case '<<':
							if (*(s+1) eq '=')
							{
								*o++ = c;
								*o++ = *s++;
								*o++ = *s++;
								c = *s;
								ti = C_simple[c];
								out->cat = op3;
								break;
							}
							/* else fall thru: 2 are valid */
						case '==':
						case '++':
						case '+=':
						case '-=':
						case '--':
						case '->':
						case '*=':
						case '%=':
						case '/=':
						case '&&':
						case '&=':
						case '|=':
						case '||':
						case '!=':
						case '^=':
						case ':=':		/* although this isnt C, it is very usefull to be able to parse and warn it :-) */
						case '<=':
						case '>=':
	#if ROTOP
						case '<>':
						case '><':
	#endif
							*o++ = c;
							*o++ = *s++;
							c = *s;
							ti = C_simple[c];
							out->cat = op2;
						break;
						case '\\\r':		/* bloody splice spoils everything */
							if (*(s+1) eq '\n')
								s += 2;		/* \r\n */
							else
								s += 1;		/* \r only */
							lineno++;
						continue;	/* not a token */
						case '\\\n':		/* \n only */
							lineno++;
							s++;
						continue;			/* not a token */
						case '..':
							if (*(s+1) eq '.')
							{
								*o++ = c;
								*o++ = *s++;
								*o++ = *s++;
								c = *s;
								ti = C_simple[c];
								out->cat = op3;
								break;
							}
							/* else fall thru: .. not valid) */
						default:
						todef:				/* is a single */
							*o++ = c;
							c = *s;
							ti = C_simple[c];
							out->cat = op;
					}
				}
				elif (t eq op)		/* only 1 */
				{
					*o++ = c;
					c = *s;
					ti = C_simple[c];
				}
				else
				{
					while(ti eq t)
					{
						*o++ = c;
						c = *s++;
						ti = C_simple[c];
					}
					s--;
				}
			}
			*o++ = 0;	/* terminate all token teksts */
		}

		nr++;
		l = o - out->text + size_LEX;
		if (l > MAX_LEX and perr)
		{
			if (t ne ws)
				perr("[%d] token %d of size %ld is larger than %d characters", which, nr, o - out->text - 1, MAX_SCON);
			l = MAX_LEX;
			out->text[MAX_SCON] = 0;	/* 07'15 v5.2 */
		}

		out->rl = l;

#ifdef TOK_FREQ
		tok_freq[out->cat].t++;
#endif

		(char *)out += l;
		tot += l;

		ti = t;
	}

	out->rl = size_LEX;
	out->cat = eof;
	tot += size_LEX;

/* single insertion as a test of diff() */

	if (incom and perr)
		perr("EOF in comment");			/* 02'12 HR */

	if (lines)
		*lines = lineno;

	return tot;
}
