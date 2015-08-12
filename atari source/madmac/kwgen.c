/*
 *  keyword transition-table generation utility
 *
 *
 *----------------
 *
 * SYNOPSIS:	kw basename <file1 >file2
 *
 *  `-d' turns on debugging messages
 *
 *  Accepts a list of keywords and corresponding values.  Lines
 *  beginning with '#' are comments.  Values may be empty (resulting
 *  in a default value of the previous item's value plus 1, or zero
 *  if there is no previous item), decimal numbers, or characters
 *  enclosed between single quotes.
 *
 *	# this is a comment
 *	.byte 34
 *	.word 'A'
 *	.long
 *
 *  The `basename' is a string prepended to the beginning of each of
 *  the output array names, and should be one or two characters.
 *
 */
#include <stdio.h>
#include <ctype.h>
#include <stdlib.h>
#include <string.h>

/*
 *  Tunable definitions
 *
 */
#define TABSIZE 1024		/* state table size */
#define NSTRINGS 500		/* maximum number of keywords */
#define STRPOOLSIZ (NSTRINGS * 10) /* size of string pool */


/*
 *  Do not change these
 */
#define	EOS	'\0'		/* null */
#define UNUSED	-1		/* slot in ktab[] is unused */
#define MARKED	-2		/* slot in ktab[] is used, not assigned yet */


/*
 *  Table-building tables
 */
int kmax = 0;			/* largest index into ktab */
int ktab[TABSIZE];		/* next state number (or -1) */
int kcheck[TABSIZE];		/* check state number (or -1) */
int kaccept[TABSIZE];		/* accept (or -1) */
int kbase[TABSIZE];		/* ktab[] index for a state `i' */
int nstates;			/* number of states in kbase[] */

/*
 *  Temporary tables
 */
int tab[128];			/* tmp table for building ktab[] */
int accept[128];		/* tmp table for building accept[] */

struct name_entry {
	char *nstr;			/* -> name string */
	int nval;			/* = name's value */
} namtab[NSTRINGS];

int nnames;			/* number of keywords */
char strpool[STRPOOLSIZ];	/* pool for keyword text */
char *basename;			/* -> string to prepend to array names */
char uppername[100];		/* all-uppercase version of basename */
int debug = 0;			/* 1, enable debugging messages */


main(argc, argv)
int argc;
char **argv;
{
	register int i, j, k, w;
	char *s, *s1;
	int found1;
	int valid;
	int base;
	int state;
	int comp_entry();

	if (argc != 2)
	{
		panic("bad commandline");
	}

	basename = argv[1];
	for (s = basename, s1 = uppername; *s; ++s, ++s1)
		*s1 = toupper(*s);
	*s1 = EOS;

	/*
	 *  init tables
	 */
	for (i = 0; i < TABSIZE; ++i)
	{
		ktab[i] = -1;
		kcheck[i] = -1;
		kaccept[i] = -1;
	}
	nstates = 0;

	/*
	 *  read keyword list
	 *
	 */
	s = strpool;
	while (gets(s) != NULL)
	{
		if (*s == '#' || !*s)	/* ignore comment and empty lines */
			continue;

		namtab[nnames].nstr = s;
		while (*s && !isspace(*s))
			++s;

		if (!*s)
		{
			++s;
			goto empty;
		}

		if (*s && isspace(*s))
			*s++ = '\0';

		s1 = s;
		while (*s1 && isspace(*s1))
			++s1;

		if (!*s1)
		{
empty:			/* use previous entry + 1 */
			if (!nnames)		/* complain if no previous entry */
				namtab[nnames].nval = 0;
			else namtab[nnames].nval = namtab[nnames-1].nval + 1;
		}
		else if (isdigit(*s1))
			namtab[nnames].nval = atoi(s1);
		else if (*s1 == '\'')
			namtab[nnames].nval = *++s1;
		else if (*s1 == '=')
		{			/* same as previous entry */
			if (!nnames)		/* zero for first entry */
				namtab[nnames].nval = 0;
			else namtab[nnames].nval = namtab[nnames-1].nval;
		}
		else
		{
			fprintf(stderr, "bad expression at '%s'\n", namtab[nnames].nstr);
			exit(1);
		}

		++nnames;
		if (nnames >= NSTRINGS)
			panic("name table overflow");
		if (s >= &strpool[STRPOOLSIZ-100])
			panic("string table overflow");
	}

	qsort(namtab, nnames, sizeof(struct name_entry), comp_entry);

	/*
	 *  compute table start indices
	 */
	found1 = 1;

	for (k = 1; found1; ++k)
	{
		found1 = 0;

		for (w = 0; w <= nnames; ++w)
		{
			if (w == 0 ||
				  w == nnames ||
				  !nmatch(k-1, namtab[w].nstr, namtab[w-1].nstr))
			{
				if (w != 0 &&
					  valid != 0)
				{
					wiredown();

					if (k > 1)
					{
						state = 0;
						for (i = 0; i < k-2; ++i)
						{
							if (ktab[kbase[state] + *(namtab[w-1].nstr + i)] < 0)
								panic("table build error");
							else state = ktab[kbase[state] +
											  *(namtab[w-1].nstr + i)];
						}

						ktab[kbase[state] + *(namtab[w-1].nstr + k-2)] = nstates;
					}
					++nstates;
					found1 = 1;
				}

				for (i = 0; i < 128; ++i)
				{
					tab[i] = UNUSED;
					accept[i] = -1;
				}

				valid = 0;
			}

			if ( w >= nnames ||
				 strlen(namtab[w].nstr) < k)
			{
				continue;
			}

			tab[*(namtab[w].nstr + k-1)] = MARKED;
			if (*(namtab[w].nstr + k) == '\0')
			{
				accept[*(namtab[w].nstr + k-1)] = namtab[w].nval;
			}
			valid = 1;
		}
	}

	traverse(0);
	print_tables();

	return 0;
}


/*
 *  find position for set of characters;
 *
 */
wiredown()
{
	register int base;
	register int i;

	for (base = 0; base < TABSIZE-128; ++base)
	{
		for (i = 0; i < 128; ++i)
			if (ktab[base+i] != UNUSED &&
				  tab[i] == MARKED)
				break;
		if (i >= 128)
			break;
	}

	if (base >= TABSIZE-128)
		panic("Cannot build table (won't fit in tables)\n");

	for (i = 0; i < 128; ++i)
		if (tab[i] == MARKED)
		{
			ktab[base + i] = MARKED;
			kaccept[base + i] = accept[i];
			kcheck[base + i] = nstates;
		}
	kbase[nstates] = base;

	if (kmax < base)
		kmax = base;
}


print_tables()
{
	int i;

	printf("\n#ifdef DECL_%s\n", uppername);
	printf("/*\n *  keyword state-machine tables\n *\n */\n");
	dumptab("base", basename, kbase, nstates);
	dumptab("tab", basename, ktab, kmax + 128);
	dumptab("check", basename, kcheck, kmax + 128);
	dumptab("accept", basename, kaccept, kmax + 128);
	printf("#endif\n");
}


dumptab(tabname, tabprefix, table, tabsize)
char *tabname;
char *tabprefix;
int *table;
int tabsize;
{
	int i, j;

	printf("\nint %s%s[%d] = {\n",
		   tabprefix, tabname, tabsize);

	for (i = j = 0; i < tabsize; ++i)
	{
		printf(" %d", table[i]);
		if (i != tabsize-1)
			putchar(',');
		if (++j == 8)
		{
			j = 0;
			putchar('\n');
		}
	}
	if (j)
		putchar('\n');
	printf("};\n");
}


comp_entry(ent1, ent2)
struct name_entry *ent1;
struct name_entry *ent2;
{
	return strcmp(ent1->nstr, ent2->nstr);
}


nmatch(len, s1, s2)
int len;
char *s1;
char *s2;
{
	while (len--)
		if (*s1++ != *s2++)
			return 0;
	return 1;
}


char nam[128];
char *pnam;

traverse(state)
int state;
{
	register int base, i, j;
	char *s, c;

	if (state == 0)
	{
		printf("#ifdef DEF_%s\n", uppername);
		printf("/*\n *  Keyword definitions\n */\n");
		pnam = nam;
		*pnam = 0;
	}

	base = kbase[state];
	for (i = 0; i < 128; ++i)
		if (kcheck[base + i] == state)
		{
			*pnam++ = (char)i;
			*pnam = '\0';

			for (s = nam; *s; ++s)
				if (isupper(*s))
					break;

			if (kaccept[base + i] >= 0 &&
				  !isupper(*s))
			{
				printf("#define\t%s_", uppername);
				for (s = nam; (c = *s); ++s)
				{
					if (c == '.')
						c = '_';
					else if ((c >= 'a') && (c <= 'z'))
						c -= 32;
					printf("%c", c);
				}
				printf("\t%d\n", kaccept[base + i]);
			}

			if (ktab[base + i] >= 0)
				traverse(ktab[base + i]);
			*--pnam = '\0';
		}

	if (state == 0)
		printf("#endif\n");
}


panic(s)
char *s;
{
	fprintf(stderr, "Panic: %s\n", s);
	exit(1);
}
