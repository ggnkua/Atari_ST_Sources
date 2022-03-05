
/*
 * Copyright (c) 1988 by Sozobon, Limited.  Author: Joseph M Treat
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 */

#include "jas.h"

#define SYMSZ 64
#define NHASH 373
#define SYMLOOP(x,y) for(x=0;x<SYMSZ&&full[x]>0;x++) for(y=0;y<full[x];y++)

/* ordering definitions */
#define O_SUPPRESS	000
#define O_STATIC	001
#define O_GLOBAL	002
#define O_UNDEF		004

long nsyms = 0;
SYM *table[NHASH];

SYM *sym_tab[SYMSZ];
short full[SYMSZ];
int level = 0;
extern int Lflag;

SYM *
newsym( )
{
	register SYM *p;

	if ( full[level] >= SYMSZ ) {
		if ( ++level >= SYMSZ )
			error( 0, "symbol table full" );
	}
	if (! sym_tab[level] ) {
		sym_tab[level] = ALLOC(SYMSZ,SYM);
		full[level] = 0;
	}
	p = &sym_tab[level][full[level]++];
	p->flags = 0;
	return p;
}

SYM *
lookup(name)
	register char *name;
{
	register int h;
	register SYM *p;

	h = hash( name );
	if ( p = table[h] ) {
		for ( ; p != (SYM *) NULL; p = p->next) {
			if (! strcmp( name, p->name ) ) {
				return p;
			}
		}
		p = newsym();
		p->name = STRCPY(name);
		p->next = table[h];
		table[h] = p;
		return p;
	}
	p = table[h] = newsym();
	p->name = STRCPY(name);
	return p;
}

symwalk(acc,fun)
	register int acc;
	register int (*fun)();
{
	register int lvl, i;
	register SYM *p;

	SYMLOOP(lvl,i) {
		p = &sym_tab[lvl][i];

		if (acc & p->access)
			(*fun)(p);
		}
}

putsym(p)
	register SYM *p;
{
	struct {
		char name[8];
		unsigned short flags;
		long value;
	} s;
	register int i;
	register char *cp;

	cp = p->name;
	for ( i = 0; i < 8 && *cp; )
		s.name[i++] = *cp++;
        for (; i < 8; )
   		s.name[i++] = '\0';

	s.value = p->value;

	s.flags = p->flags;
	if ( s.flags == DEFINED || s.flags == (DEFINED|GLOBAL) )
		s.flags |= EXTERN;

	output( (char *) &s, sizeof s, 1 );
}

dumpsym()
{
	/*
	 * don't generate static symbols
	 */
	if ( Lflag > 0 )
		symwalk( O_STATIC, putsym );
	symwalk( O_GLOBAL, putsym );
	symwalk( O_UNDEF, putsym );
}

setindex( p )
	SYM *p;
{
	p->index = nsyms++;
}

symindex()
{
	register int lvl, i;
	register SYM *p;

	SYMLOOP(lvl,i) {
		p = &sym_tab[lvl][i];
		p->access = 0;
		if ( (p->flags & DEFINED) == 0 ) {
			p->access = O_SUPPRESS;
		} else if ( (p->flags & (SEGMT|EQUATED)) &&
						! (p->flags & GLOBAL) ) {
			/*
			 * if a static symbol starts with an L,
			 * then it is truely invisible
			 */
			if ( p->flags & SEGMT &&
					Lflag <= 1 && *(p->name) == 'L' )
				p->access = O_SUPPRESS;
			else
				p->access = O_STATIC;
		} else if ( p->flags & (SEGMT|EQUATED) ) {
			p->access = O_GLOBAL;
		} else { /*  (p->flags & SEGMT) == UNK */
			p->access = O_UNDEF;
		}
	}
	nsyms = 0;
	/*
	 * don't generate static symbols
	 */
	if ( Lflag > 0 )
		symwalk( O_STATIC, setindex );
	symwalk( O_GLOBAL, setindex );
	symwalk( O_UNDEF, setindex );
}

int
hash(name)
	register char *name;
{
	register int val;

	for (val = 0; *name; name++)
		val += (int) *name;
	return val % NHASH;
}

fixsymval( addr, incr, segmt )
	register long addr, incr;
	unsigned short segmt;
{
	register int lvl, i;
	register SYM *p;

	SYMLOOP(lvl,i) {
		p = &sym_tab[lvl][i];

		if ( ( p->flags & SEGMT ) == segmt && p->value >= addr )
			p->value += incr;
	}
}
