/*
 * XaAES - XaAES Ain't the AES (c) 1999 - 2003 H.Robbers
 *
 * A multitasking AES replacement for MiNT
 *
 * This file is part of XaAES.
 *
 * XaAES is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * XaAES is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/* HR: Input Parameters in Free Format */

#ifndef IPFF_H
#define IPFF_H

#ifndef PRELUDE_H
#include <prelude.h>
#endif

#define IPFF_L				32		/* name max */
#define Lval 1

typedef enum
{
	Bit,
	Number,
	String
} MODE;

typedef struct symbol
{
	struct symbol *next;
	char *name;
	MODE mode;
	bool assigntype;
	long val;
	char *s;
} SYMBOL;

typedef SYMBOL *GetSym(char *name);

char *ipff_init	(int m, int p, int f, char *t,char *l,char **tt);
void ipff_in(char *p);
char *ipff_line(long *);
char *ipff_getp(void);
void ipff_putp (char *s),nstr(char *),
     ipff_trail(char *);
int sk(void),skc(void),sk1(void),
    idec(void),ide(char *),
    lstr(char *, unsigned long);

int assign(void);
bool infix(void),
     is_ide(char *s);
long dec(void),hex(void),oct(void),bin(void);
bool truth(void);
char *Fload(const char *name, int *fh, long *l);
SYMBOL *new_sym(char *name, int atype, MODE mode, char *s, long v),
       *find_sym(char *name, GetSym *outer_sym),
       *fstr(char *to, int cas, int lval);
void free_sym(void);
void list_sym(void);

extern
GetSym *outer_sym;

#endif