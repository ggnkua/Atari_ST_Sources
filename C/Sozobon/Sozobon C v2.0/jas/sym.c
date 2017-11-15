
/*
 * Copyright (c) 1988,1991 by Sozobon, Limited.  Author: Joseph M Treat
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
extern int flag8;

#ifdef UNIXHOST
char *fixsym();
#define FSYMSZ	14
#endif

/*
 * this table is used to store long names
 */

char **flexnames = (char **) NULL; 
int *flexused = (int *) 0;
int flexsize = 0;

setname( p, name )
	SYM *p;
	char *name;
{
	int i, len = strlen( name );

	if ( flag8 || len <= 8 ) {
		strncpy( p->name.here, name, 8 );
		return;
	}
	if ( flexsize == 0 ) {
		flexused = ALLO(int);
		flexused[0] = 0;
		flexnames = ALLO(char *);
		flexnames[0] = ALLOC(1024,char);
		flexsize = 1;
	}
	if ( flexused[flexsize-1] + len + 1 > 1024 ) {
		flexsize++;
		flexused = REALLO(flexused,flexsize,int);
		flexused[flexsize-1] = 0;
		flexnames = REALLO(flexnames,flexsize,char *);
		flexnames[flexsize-1] = ALLOC(1024,char);
	}
	i = flexsize-1;
	p->name.stix[0] = 0;
	p->name.stix[1] = 1024 * i + flexused[i];
	strcpy( &flexnames[i][flexused[i]], name );
	flexused[i] += len + 1;
}

cpyname( dst, p )
	char dst[8];
	SYM *p;
{
	int i, j;

	if ( ! p->name.stix[0] ) {
		i = p->name.stix[1] / 1024;
		j = p->name.stix[1] % 1024;
		strncpy( dst, &flexnames[i][j], 8 );
		return;
	}
	for ( i = 0; p->name.here[i] && i < 8; i++ )
		dst[i] = p->name.here[i];
	for ( ; i < 8; i++ )
		dst[i] = (char) 0;
}

cmpname( p, name )
	SYM *p;
	char *name;
{
	if (flag8)
		return strncmp(name, p->name.here, 8);

	if ( ! p->name.stix[0] ) {
		int i, j;

		i = p->name.stix[1] / 1024;
		j = p->name.stix[1] % 1024;

		return strcmp( name, &flexnames[i][j] );
	}
	if (strlen(name) > 8)
		return 1;
	return strncmp( name, p->name.here, 8 );
}

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
			if (! cmpname( p, name ) ) {
				return p;
			}
		}
		p = newsym();
		setname( p, name );
		p->next = table[h];
		table[h] = p;
		return p;
	}
	p = table[h] = newsym();
	setname( p, name );
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
	int j, k;

	cpyname( s.name, p );

	s.value = p->value;

	s.flags = p->flags;
	if ( s.flags == DEFINED || s.flags == (DEFINED|GLOBAL) )
		s.flags |= EXTERN;

#ifndef UNIXHOST
	output( (char *) &s, sizeof s, 1 );
#else
	output( fixsym(&s), FSYMSZ, 1 );
#endif

	if (flag8 || p->name.stix[0])
		return;

	i = p->name.stix[1] / 1024;
	j = p->name.stix[1] % 1024;
	cp = &flexnames[i][j];

	j = strlen(cp);
	i = 8;
	while (j > i) {
		strncpy(s.name, &cp[i], 8);
		for (k=j-i; k<8; k++)
			s.name[k] = 0;
		s.flags = NAMEX;
		s.value = NAMEV;
#ifndef UNIXHOST
		output( (char *) &s, sizeof s, 1 );
#else
		output( fixsym(&s), FSYMSZ, 1 );
#endif
		i += 8;
	}
}

flexsym()
{
	struct {
		char name[8];
		unsigned short flags;
		long value;
	} s;

	strcpy(s.name, "SozobonX");
	s.value = NAMEV;
	s.flags = NAMEX;

#ifndef UNIXHOST
	output( (char *) &s, sizeof s, 1 );
#else
	output( fixsym(&s), FSYMSZ, 1 );
#endif
}

dumpsym()
{
	if (!flag8)
		flexsym();
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
	int i, j, n;
	char *cp;

	if (flag8 || p->name.stix[0])
		n = 1;
	else {
		i = p->name.stix[1] / 1024;
		j = p->name.stix[1] % 1024;
		cp = &flexnames[i][j];
		n = (strlen(cp) + 7) / 8;
	}

	p->index = nsyms;
	nsyms += n;
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
			char name[8];

			cpyname( name, p );

			if ( p->flags & SEGMT && Lflag <= 1 && name[0] == 'L' )
				p->access = O_SUPPRESS;
			else
				p->access = O_STATIC;
		} else if ( p->flags & (SEGMT|EQUATED) ) {
			p->access = O_GLOBAL;
		} else { /*  (p->flags & SEGMT) == UNK */
			p->access = O_UNDEF;
		}
	}
	if (flag8)
		nsyms = 0;
	else
		nsyms = 1;
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
	register int i;

	for (val = 0, i=0; i < 6 && *name; i++,name++)
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

