/* Copyright (c) 1988 by Sozobon, Limited.  Author: Johann Ruegg
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 *
 *	main.c
 *
 *	Main routine, error handling, keyword lookup.
 */

#include <stdio.h>
#include "param.h"
#include "nodes.h"
#include "tok.h"

int lineno;
int nmerrors;
int oflags[26];
int xflags[26];
int pflag = 0;			/* enable profiling */
static int anydebug;
#define debug oflags['z'-'a']

FILE *input;
FILE *output;
#if CC68
FILE *fopenb();
#define fopen fopenb
#endif
char *inname;

#if NEEDBUF
char my_ibuf[BUFSIZ];
#endif

NODEP cur;

static	char *defines[] = {
	"MC68000",
	"mc68000",
	"SOZOBON",
	"ATARI_ST",
	"TOS",
	NULL
};

main(argc, argv)
char **argv;
{
	char	*p, *getenv();
	int shownames;
	int i;

	if (sizeof(NODE) & 3) {
		printf("sizeof NODE not mult of 4\n");
		exit(1);
	}

	/*
	 * Define the "built-in" macros
	 */
	for (i=0; defines[i] != NULL; i++)
		optdef(defines[i]);

	/*
	 * Parse the INCLUDE environment variable, if present.
	 */
	if ((p = getenv("INCLUDE")) != NULL)
		doincl(p);

	shownames = 0;
	if (isatty(0)) {
		write(1, "\33v", 2);
		setbuf(stdout, NULL);
	}
/* put author here */
	while (argc-- > 1) {
		argv++;
		if (argv[0][0] == '-')
			doopt(&argv[0][1]);
#if CC68
		else if (argv[0][0] == '+') {
			upstr(&argv[0][1]);
			doopt(&argv[0][1]);
		}
#endif
		else {
			if (argc > 1 || shownames) {
				shownames++;
				printf("%s:\n", argv[0]);
			}
			if (input != NULL)
				fclose(input);
			input = fopen(argv[0], ROPEN);
			if (input == NULL) {
				printf("Cant open %s\n", argv[0]);
				exit(1);
			}
#if NEEDBUF
			setbuf(input, my_ibuf);
#endif
			inname = argv[0];
			dofile();
		}
	}
	if (input == NULL) {
		input = stdin;
		output = stdout;
		inname = "<STDIN>";
		dofile();
	}
	exit(0);
}

doincl(s)
char	*s;
{
	char	*malloc(), *strcpy();
	char	buf[256];
	char	dir[128];
	register char	*p;

	strcpy(buf, s);

	/*
	 * Convert ',' and ';' to nulls
	 */
	for (p=buf; *p != '\0' ;p++)
		if (*p == ',' || *p == ';')
			*p = '\0';
	p[1] = '\0';			/* double null terminated */

	/*
	 * Grab each directory, make sure it ends with a backslash,
	 * and add it to the directory list.
	 */
	for (p=buf; *p != '\0' ;p++) {
		strcpy(dir, p);
		if (dir[strlen(dir)-1] != '\\')
			strcat(dir, "\\");

		optincl( strcpy(malloc((unsigned) (strlen(dir) + 1)), dir) );

		while (*p != '\0')
			p++;
	}
}

dofile()
{
	extern int nodesmade, nodesavail;
	char *scopy();
	extern NODEP deflist[], symtab[], tagtab;
	extern NODEP strsave;
	extern int level;
	int i;

	out_start(inname);
	inname = scopy(inname);
	lineno = 1;
	nmerrors = 0;
	advnode();

	level = 0;
	program();
	dumpstrs(strsave);

	out_end();
	if (cur && cur->e_token == EOFTOK)
		freenode(cur);
	sfree(inname);
	for (i=0; i<NHASH; i++) {
		if (debug>1 && deflist[i]) {
			printf("defines[%d]", i);
			printlist(deflist[i]);
		}
		freenode(deflist[i]);
		deflist[i] = NULL;
		if (debug && symtab[i]) {
			printf("gsyms[%d]", i);
			printlist(symtab[i]);
		}
		freenode(symtab[i]);
		symtab[i] = NULL;
	}
	if (debug) {
		printf("structs");
		printlist(tagtab);
	}
	freenode(tagtab);
	tagtab = NULL;
	freenode(strsave);
	strsave = NULL;
	if (nmerrors) {
		printf("%d errors\n", nmerrors);
		exit(1);
	}
	if (nodesmade != nodesavail) {
		printf("lost %d nodes!!!\n", nodesmade-nodesavail);
		exit(1);
	}
/*
	printf("Space = %ldK\n", ((long)nodesavail*sizeof(NODE))/1024);
*/
}

static	char	Version[] =
"hcc: version 1.01  Copyright (c) 1988 by Sozobon, Limited.";

doopt(s)
char *s;
{
	register char c;

	while ((c = *s++)) {
#ifdef	DEBUG
		if (c >= 'a' && c <='z') {
			oflags[c-'a']++;
			anydebug++;
		} else
#endif
		if (c >= 'A' && c <= 'Z') {
			switch (c) {
			case 'D':
				optdef(s);
				return;
			case 'U':
				optundef(s);
				return;
			case 'I':
				doincl(s);
				return;
			case 'P':
				pflag = 1;
				continue;
			case 'V':
				printf("%s\n", Version);
				continue;
			}
#ifdef	DEBUG
			xflags[c-'A']++;
			anydebug++;
#endif
		}
	}
}

errors(s,t)
char *s, *t;
{
	optnl();
	printf("error in %s on line %d: %s %s\n", inname, lineno, s,t);
	nmerrors++;
}

errorn(s,np)
char *s;
NODE *np;
{
	optnl();
	printf("error in %s on line %d: %s ", inname, lineno, s);
	put_nnm(np);
	putchar('\n');
	nmerrors++;
}

error(s)
char *s;
{
	optnl();
	printf("error in %s on line %d: %s\n", inname, lineno, s);
	nmerrors++;
}

warns(s,t)
char *s, *t;
{
	optnl();
	printf("warning in %s on line %d: %s %s\n", inname, lineno, s,t);
}

warnn(s,np)
char *s;
NODE *np;
{
	optnl();
	printf("warning in %s on line %d: %s ", inname, lineno, s);
	put_nnm(np);
	putchar('\n');
}

warn(s)
char *s;
{
	optnl();
	printf("warning in %s on line %d: %s\n", inname, lineno, s);
}

fatals(s,t)
char *s, *t;
{
	optnl();
	printf("fatal error in %s on line %d: %s %s\n", inname, lineno, s,t);
	exit(1);
}

fataln(s,np)
char *s;
NODE *np;
{
	optnl();
	printf("fatal error in %s on line %d: %s ", inname, lineno, s);
	put_nnm(np);
	putchar('\n');
	exit(1);
}

fatal(s)
char *s;
{
	optnl();
	printf("fatal error in %s on line %d: %s\n", inname, lineno, s);
	exit(1);
}

static
optnl()
{
	if (anydebug)
		putchar('\n');
}

struct kwtbl {
	char *name;
	int	kwval;
	int	kflags;
} kwtab[] = {
	/* must be sorted */
	{"asm", K_ASM},
	{"auto", K_AUTO},
	{"break", K_BREAK},
	{"case", K_CASE},
	{"char", K_CHAR},
	{"continue", K_CONTINUE},
	{"default", K_DEFAULT},
	{"do", K_DO},
	{"double", K_DOUBLE},
	{"else", K_ELSE},
	{"enum", K_ENUM},
	{"extern", K_EXTERN},
	{"float", K_FLOAT},
	{"for", K_FOR},
	{"goto", K_GOTO},
	{"if", K_IF},
	{"int", K_INT},
	{"long", K_LONG},
	{"register", K_REGISTER},
	{"return", K_RETURN},
	{"short", K_SHORT},
	{"sizeof", K_SIZEOF},
	{"static", K_STATIC},
	{"struct", K_STRUCT},
	{"switch", K_SWITCH},
	{"typedef", K_TYPEDEF},
	{"union", K_UNION},
	{"unsigned", K_UNSIGNED},
	{"void", K_VOID},
	{"while", K_WHILE},

	{0,0}
};

#define FIRST_C	'a'
#define LAST_C	'z'
struct kwtbl *kwstart[LAST_C-FIRST_C+1];

kw_init()
{
	register struct kwtbl *p;
	register c;

	for (p=kwtab; p->name; p++) {
		c = p->name[0];
		if (kwstart[c-FIRST_C] == 0)
			kwstart[c-FIRST_C] = p;
	}
}

kw_tok(tp)
NODE *tp;
{
	register struct kwtbl *kp;
	register char *nm;
	register i;
	static first = 0;

	nm = tp->n_name;
	if (first == 0) {
		kw_init();
		first = 1;
	}
	i = nm[0];
	if (i < FIRST_C || i > LAST_C)
		return;
	kp = kwstart[i-FIRST_C];
	if (kp)
	for (; kp->name; kp++) {
		i = strcmp(nm, kp->name);
		if (i == 0) {
			tp->e_token = kp->kwval;
			tp->e_flags = kp->kflags;
			return;
		} else if (i < 0)
			return;
	}
}

#if CC68
/* fix args since stupid lib makes all lower case */
upstr(s)
char *s;
{
	while (*s) {
		if (*s >= 'a' && *s <= 'z')
			*s += 'A'-'a';
		s++;
	}
}
downstr(s)
char *s;
{
	while (*s) {
		if (*s >= 'A' && *s <= 'Z')
			*s -= 'A'-'a';
		s++;
	}
}
#endif
