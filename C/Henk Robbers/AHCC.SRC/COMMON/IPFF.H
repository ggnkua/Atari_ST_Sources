/*  Copyright (c) 1988 - present by Henk Robbers Amsterdam.
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

/* HR: Input Parameters in Free Format */

#ifndef IPFF_H
#define IPFF_H

#ifndef PRELUDE_H
#include "prelude.h"
#endif

#define IPFF_L				32		/* name max */

char *ipff_init	(short m, bool nl, bool f, char *t, char *l, char **tt);
void ipff_in(char *ptr);
char *ipff_line(long *);
char *ipff_getp(void);
void ipff_putp (char *s),nstr(char *),
     ipff_trail(char *);
short sk(void),skc(void),sk1(void),sknl(void),
    idec(void),str(char *),fstr(char *),
    lstr(char *, unsigned long);

short assign(void);
bool infix(void),
     is_ide(char *s);
long dec(void),hex(void),oct(void),bin(void);
bool truth(void);
bool look(char *, short);

#endif
