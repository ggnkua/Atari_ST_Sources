/*
 *  Symbol-table management
 *
 *    isym()			Initialize symbol table
 *    newsym(name, type)	Make a new symbol
 *    lookup(name, type, env)	Look up a symbol
 *    sym_decl(sym)		Put symbol on "order of declaration" list
 *    syg_fix()			Referenced, undefined symbols ==> global
 *    sy_assign(buf, const)	Assign numbers to symbols
 *    symtable()		Generate symbol table for listing file
 *    uc_string(string)		Convert string to upper-case
 *
 */
#include "as.h"
#define	NBUCKETS	256	/* number of hash buckets (power of 2) */


/*
 *  Imports
 */
extern int lsym_flag;		/* 1, include local symbols in object file */
extern char subttl[];		/* sub-title */
extern int as68_flag;		/* as68 kludge mode */

/*
 *  Exports
 */
int curenv;			/* current enviroment number */
SYM *sorder;			/* -> symbols, in order of reference */
SYM *sordtail;			/* -> last symbol in sorder list */
SYM *sdecl;			/* -> symbols, in order of declaration */
SYM *sdecltail;			/* -> last symbol in sdecl list */

static SYM *sytab[NBUCKETS];	/* user symbol-table header */


/*
 *  Initialize symbol-table.
 *
 */
isym()
{
	register int i;
	register SYM *sy;
	SYM *newsym();

	for (i = 0; i < NBUCKETS; ++i)
		sytab[i] = NULL;

	curenv = 1;			/* init local symbol enviroment */
	sorder = NULL;		/* init symbol-reference list */
	sordtail = NULL;
	sdecl = NULL;		/* init symbol-decl list */
	sdecltail = NULL;
}


/*
 *  Make a new symbol of type `type' in enviroment `envno';
 *    Assume the symbol doesn't already exist;
 *    Return a pointer to the symbol structure;
 *
 */
SYM *newsym(name, type, envno)
char *name;
int type;
int envno;
{
	register int hash;
	register SYM *sy;
	char *nstring();

	/* Allocate the symbol */
	sy = (SYM *)amem((long)(sizeof(SYM)));
	sy->sname = nstring(name);

	/* Fill-in the symbol */
	sy->stype = type;
	sy->senv = envno;
	sy->sattr = 0;
	sy->svalue = 0;

	/* Install symbol in symbol table */
	hash = syhash(name, envno);
	sy->snext = sytab[hash];
	sytab[hash] = sy;

	/* Append symbol to symbol-order list */
	if (sorder == NULL)
		sorder = sy;		/* add first symbol */
	else sordtail->sorder = sy;	/* or append to tail of list */

	sy->sorder = NULL;
	sordtail = sy;

	return sy;
}


/*
 *  Lookup the symbol `name', of the specified type,
 *  with the specified enviroment level.
 *
 */
SYM *lookup(name, type, envno)
register char *name;
register int type;
register int envno;
{
	register SYM *sy;
	register int k;
	register int sum;
	register char *s;

	/*
	 *  Pick a hash-bucket
	 *  (SAME algorithm as syhash())
	 */
	k = 0;
	s = name;
	for (sum = envno; *s;)
	{
		if (k++ == 1)
			sum += *s++ << 2;
		else sum += *s++;
	}

	sy = sytab[sum & (NBUCKETS-1)];

	/*
	 *  Do linear-search for symbol in bucket;
	 *    `strcmp()' is a bottleneck here, and it
	 *     should be written in assembly.
	 */
	while (sy != NULL)
		if (sy->stype == type &&	/* type, envno and name must match */
			  sy->senv == envno &&
			  *name == *sy->sname && /* fast check for first character */
			  !strcmp(name, sy->sname))
			break;
		else sy = sy->snext;

	return sy;			/* return NULL or matching symbol */
}


/*
 *  Hash the print-name and enviroment number
 *
 */
syhash(name, envno)
register char *name;
int envno;
{
	register int sum;
	register int k;

	k = 0;
	for (sum = envno; *name; ++name)
	{
		if (k++ == 1)
			sum += *name << 2;
		else sum += *name;
	}

	return (sum & (NBUCKETS-1));
}


/*
 *  Put symbol on "order-of-declaration" list of symbols
 *
 */
void sym_decl(sym)
SYM *sym;
{
	if (sym->sattr & SDECLLIST) return;		/* already on list */
	sym->sattr |= SDECLLIST;			/* mark "already on list" */

	if (sdecl == NULL)
		sdecl = sym;				/* first on decl-list */
	else sdecltail->sdecl = sym;		/* add to end of list */

	sym->sdecl = NULL;				/* fix up list's tail */
	sdecltail = sym;
}


/*
 *  Make all referenced, undefined symbols global
 *
 */
syg_fix()
{
	register SYM *sy;

#ifdef DO_DEBUG
	DEBUG printf("~syg_fix()\n");
#endif
	/*
	 *  Scan through all symbols;
	 *  if a symbol is REFERENCED but not DEFINED,
	 *  then make it global.
	 */
	for (sy = sorder; sy != NULL; sy = sy->sorder)
		if (sy->stype == LABEL &&
			  sy->senv == 0 &&
			  ((sy->sattr & (REFERENCED|DEFINED)) == REFERENCED))
			sy->sattr |= GLOBAL;
}


/*
 *  Assign numbers to symbols that are to be exported
 *  or imported.  The symbol number is put in `.senv'.
 *  Return the number of symbols that will be in the
 *  symbol table.
 *
 */
sy_assign(buf, constr)
register char *buf;
char *(*constr)();
{
	register SYM *sy;
	register int scount;

	scount = 0;

	if (buf == NULL)
		/*
		 *  Append all symbols not appearing on the .sdecl list
		 *  to the end of the .sdecl list.
		 */
		for (sy = sorder; sy != NULL; sy = sy->sorder) {
			/*
			 *  essentially the same as 'sym_decl()' above:
			 */
			if (sy->sattr & SDECLLIST) continue;	/* already on list */
			sy->sattr |= SDECLLIST;			/* mark "on the list" */

			if (sdecl == NULL) sdecl = sy;		/* first on decl-list */
			else sdecltail->sdecl = sy; 		/* add to end of list */

			sy->sdecl = NULL;				/* fix up list's tail */
			sdecltail = sy;
		}


	/*
	 *  Run through all symbols (now on the .sdecl list)
	 *  and assign numbers to them.  We also pick which
	 *  symbols should be global or not here.
	 *
	 */
	for (sy = sdecl; sy != NULL; sy = sy->sdecl)
		/*
		 *  Export or import external references,
		 *  and export COMMON blocks.
		 */
		if (sy->stype == LABEL &&
			  ((sy->sattr & (GLOBAL|DEFINED)) == (GLOBAL|DEFINED) ||
			   (sy->sattr & (GLOBAL|REFERENCED)) == (GLOBAL|REFERENCED)) ||
			  (sy->sattr & COMMON))
		{
			sy->senv = (WORD)scount++;
			if (buf != NULL) buf = (*constr)(buf, sy, 1);
		}
		else
			/*
			 *  Export vanilla labels (but don't make them global)
			 *
			 *  An exception is made for equates, which are not exported
			 *  unless they are referenced.
			 */
			if (sy->stype == LABEL &&
				  lsym_flag &&
				  (sy->sattr & (DEFINED|REFERENCED)) != 0 &&
				  (!as68_flag || *sy->sname != 'L') )
			{
				if ((sy->sattr & (EQUATED|REFERENCED)) == EQUATED) continue;
				sy->senv = (WORD)scount++;
				if (buf != NULL) buf = (*constr)(buf, sy, 0);
			}

	return scount;
}



/*
 *  Tags for marking symbol spaces
 *
 *	a = absolute
 *	t = text
 *	d = data
 *	! = "impossible!"
 *	b = BSS
 */
static char tdb_text[8] =
{
	'a', 't', 'd', '!', 'b', SPACE, SPACE, SPACE
};


/*
 *  Generate symbol table for listing file
 *
 */
symtable()
{
	register int i;
	register int j;
	register SYM *q;
	register SYM *p;
	register SYM *r;
	SYM *k;
	SYM **sy;
	SYM *colptr[4];
	char ln[150];
	char ln1[150];
	char ln2[20];
	char c, c1;
	WORD w;
	int colhei;
	extern int pagelen;

	colhei = pagelen - 5;

	/*
	 *  Allocate storage for list headers
	 *  and partition all labels.  Throw away
	 *  macros and macro arguments.
	 */
	sy = (SYM **)amem((LONG)(128 * sizeof(LONG)));
	for (i = 0; i < 128; ++i) sy[i] = NULL;

	for (i = 0; i < NBUCKETS; ++i)
		for (p = sytab[i]; p != NULL; p = k)
		{
			k = p->snext;
			j = *p->sname;
			r = NULL;
			if (p->stype != LABEL) continue; /* ignore non-labels */

			for (q = sy[j]; q != NULL; q = q->snext)
				if (strcmp(p->sname, q->sname) < 0)
					break;
				else r = q;

			if (r == NULL)
			{			/* insert at front of list */
				p->snext = sy[j];
				sy[j] = p;
			}
			else
			{			/* insert in middle or, or append to, list */
				p->snext = r->snext;
				r->snext = p;
			}
		}

	/*
	 *  Link all symbols onto one list again
	 */
	p = NULL;
	for (i = 0; i < 128; ++i)
		if ((r = sy[i]) != NULL)
		{
			if (p == NULL)
				q = r;
			else q->snext = r;

			while (q->snext != NULL)
				q = q->snext;

			if (p == NULL)
				p = r;
		}

	eject();
	strcpy(subttl, "Symbol Table");

	while (p != NULL)
	{
		for (i = 0; i < 4; ++i)
		{
			colptr[i] = p;
			for (j = 0; j < colhei; ++j)
				if (p == NULL)
					break;
				else p = p->snext;
		}

		for (i = 0; i < colhei; ++i)
		{
			*ln = EOS;
			if (colptr[0] == NULL)
				break;

			for (j = 0; j < 4; ++j)
			{
				if ((q = colptr[j]) == NULL)
					break;
				colptr[j] = q->snext;
				w = q->sattr;

				/*
				 * Pick a tag:
				 *
				 *	c	common
				 *	x	external reference
				 *	g	global (export)
				 *	space	nothing special
				 *
				 */
				c1 = SPACE;
				c = SPACE;

				if (w & COMMON) c = 'c';
				else if ((w & (DEFINED|GLOBAL)) == GLOBAL) c = 'x';
				else if (w & GLOBAL) c = 'g';

				c1 = tdb_text[w & TDB];
				if (c == 'x') strcpy(ln2, "external");
				else {
					sprintf(ln2, "%08lx", q->svalue);
					uc_string(ln2);
				}

				sprintf(ln1, "  %16s %s %c%c%c",
						q->sname,
						ln2,
						(w & EQUATED) ? 'e' : SPACE,
						c1, c);
				strcat(ln, ln1);
			}
			ship_ln(ln);
		}

		eject();
	}
}


/*
 *  Convert string to uppercase
 *
 */
uc_string(s)
register char *s;
{
	for (; *s; ++s)
		if (*s >= 'a' &&
			  *s <= 'z')
			*s -= 32;
}
