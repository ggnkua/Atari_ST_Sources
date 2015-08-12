/*
 *  Atari Macro Assembler (MADMAC)
 *  Commandline Interface
 *
 *  Copyright 1986, Atari Corp.
 *  All Rights Reserved.
 *
 */
#include <stdio.h>
#include <ctype.h>
#include "as.h"
#include "amode.h"
#include "sect.h"

#ifdef ST
#include <osbind.h>
#endif

#ifdef BSD
#include <sys/time.h>
#endif

#define	MAXARGV		100	/* maximum number of commandline args */
#define	LNSIZ		200	/* size of line input buffer (<256) */


/*
 *  Imports
 */
extern int errcnt;		/* = total number of errors */
extern LONG amemtot;		/* = total amount of memory requested */
extern int lnsave;		/* 1, copy lines as we read them */
extern int totlines;		/* total #lines assembled */
extern int pagelen;		/* #lines on page */


/*
 *  Switches and global variables
 *
 */
char *objfname;

int debug;			/* 1..9, enable various debugging levels */
int as68_flag;			/* 1, as68 kludge mode */
int glob_flag;			/* 1, assume undefined symbols are global */
int lsym_flag;			/* 1, include local symbols in object file */
int sbra_flag;			/* 1, warn about possible short branches */
int prg_flag;			/* !=0, produce .PRG executable (2=symbols) */
int verb_flag;			/* 1, be verbose about what's going on */
int m6502;			/* 1, assembling 6502 code */
int perm_verb_flag;		/* 1, permanently verbose (interactive mode) */
int obj_format;			/* ALCYON, MWC, etc... */
int mwc_uflag;			/* 1, in MWC mode, move '_' to end of names */

char *searchpath;		/* search path for include files */
char *firstfname;		/* -> first source filename */

int listing;			/* 1, do listing */
int list_flag;			/* 1, "-l" (listing) flag on commandline */
char *list_fname;		/* name of listing file */
int list_fd;			/* file to write listing to */

int err_flag;			/* 1, -e specified */
int err_fd;			/* file to write error messages to */
char *err_fname;		/* name of error message file */


char version[] = VERSION;
char defname[] = "noname.o";	/* default output filename */
static char security[] = "XXXX-123456789**";


/*
 *  Handle commandline
 *
 */
int main(argc, argv)
int argc;
char **argv;
{
	int status;

	perm_verb_flag = 0;		/* clobber "permanent" verbose flag */
	imem(1);			/* initialize break */
	if (argc > 1)
		status = process(argc-1, argv+1);	/* full commandline */
	else
	{				/* noisy interactive mode */
		status = 0;
		interactive();
	}

	return status;
}


/*
 *  Say something stupid,
 *  then prompt for commandline.
 *
 */
interactive()
{
	char ln[LNSIZ];
	char *argv[MAXARGV];
	register char *s;
	register int argcnt;
	register int i;

#ifdef ST
	LONG ticks, get_tick();
	extern LONG _break;
#endif

#ifdef BSD
	long tseconds;
	struct timeval tpstart;
	struct timeval tpfinish;
	struct timezone tz;
#endif


	/*
	 *  With no commandline, print a copyright message
	 *  and prompt for commandlines.
	 */
	s = "-----------------------------\n";
	printf("%sMADMAC  Atari Macro Assembler\nCopyright 1987    Atari Corp.\n",
		   s);
	printf("Version %s    %s lmd\n%s", version, MONTHYEAR, s);


	perm_verb_flag = 1;		/* enter permanent verbose mode */

	/*
	 *  Handle commandlines until EOF or we get an empty one
	 */
	for (;;)
	{
loop:
		printf("* ");
#ifdef ST
		*ln = LNSIZ;
		Cconrs(ln);
		putchar('\n');
		s = ln;
		for (i = ln[1] & 0xff; i--;)
			*s++ = s[2];
		*s = EOS;
#endif

#ifdef UNIX
		fflush(stdout);		/* make prompt visible */
		if (gets(ln) == NULL || !*ln)
			break;
#endif

		argcnt = 0;
		s = ln;
		while (*s)
			if (isspace(*s))
				++s;
			else
			{
				if (argcnt >= MAXARGV)
				{
					PRTERR0("Too many arguments\n");
					goto loop;
				}
				argv[argcnt++] = s;
				while (*s && !isspace(*s))
					++s;
				if (isspace(*s))
					*s++ = EOS;
			}
		if (argcnt == 0)		/* exit if no arguments */
			break;

		/*
		 *  Get time of start of assembly
		 */
#ifdef ST
		ticks = get_tick();
#endif
#ifdef BSD
		gettimeofday(&tpstart, &tz);
#endif

		process(argcnt, argv);
		if (errcnt)
			printf("%d assembly error%s\n", errcnt, (errcnt > 1) ? "s" : "");

#ifdef ST
		ticks = get_tick() - ticks;
		sprintf(ln, "%ldK used, %ldK left, %d lines, %ld.%ld seconds\n",
				(amemtot + 0x3ff) >> 10,
				(((LONG)(&ln)) - _break - 2048) >> 10,
				totlines,
				ticks/200,
				(ticks/20) % 10);
#endif

#ifdef BSD
		gettimeofday(&tpfinish, &tz);
		sprintf(ln, "%ldK used, %d lines, %ld seconds\n",
				(amemtot + 0x3ff) >> 10,
				totlines,
				tpfinish.tv_sec - tpstart.tv_sec);
#endif

#ifdef SYSV
		sprintf(ln, "%ldK used, %d lines\n",
				(amemtot + 0x3ff) >> 10,
				totlines);
#endif

		printf(ln);
	}
}


/*
 *  Process commandline arguments
 *  and do an assembly.
 *
 */
process(argc, argv)
int argc;
char **argv;
{
	register int argno;
	register int fd;
	register char *s;
	register SYM *sy;
	char fnbuf[FNSIZ];		/* filename buffer */
	SYM *lookup(), *newsym();


	/*
	 *  Initialize variables and switches
	 *
	 */
	firstfname = NULL;
	list_fname = NULL;
	err_fname = NULL;
	objfname = NULL;
	err_fd = ERROUT;
	searchpath = NULL;

	debug = 0;
	err_flag = 0;
	errcnt = 0;
	listing = 0;
	list_flag = 0;
	glob_flag = 0;
	sbra_flag = 0;
	prg_flag = 0;
	as68_flag = 0;
	verb_flag = perm_verb_flag;
	m6502 = 0;
	obj_format = ALCYON;
	mwc_uflag = 0;

	lsym_flag = 1;		/* include local symbols in object file */


	/*
	 *  Initialize modules
	 */
	imem(0);			/* re-initialize break */
	itoken();			/* tokenizer */
	isym();			/* symbol table */
	iexpr();			/* expression analyzer */
	isect();			/* section manager / code generator */
	imark();			/* mark tape-recorder */
	iprocln();			/* line processor */
	imacro();			/* macro processor */
	ilist();			/* listing generator */
	i6502();			/* 6502 assembler */


	/*
	 *  Process commandline arguments
	 *  and assemble source files.
	 *
	 */
	for (argno = 0; argno < argc; ++argno)
		if (*argv[argno] == '-')
			switch (argv[argno][1])
			{
				case 'o':		/* direct object file output */
				case 'O':
					if (argv[argno][2] != EOS) objfname = argv[argno] + 2;
					else {
						if (++argno >= argc) {
							PRTERR0("Missing argument to -o");
							++errcnt;
							return;
						}
						objfname = argv[argno];
					}
					break;

				case 'e':		/* redirect error message output */
				case 'E':
					err_fname = argv[argno] + 2;
					break;

				case 'l':		/* produce listing file */
				case 'L':
					list_fname = argv[argno] + 2;
					listing = 1;
					list_flag = 1;
					++lnsave;
					break;

				case 'y':		/* -y<pagelen> */
				case 'Y':
					pagelen = atoi(argv[argno]+2);
					if (pagelen < 10)
					{
						PRTERR0("-y: bad page length\n");
						++errcnt;
						return;
					}
					break;

				case EOS:		/* -: input is stdin */
					if (firstfname == NULL) /* kludge first filename */
						firstfname = defname;
#ifdef ST			/* should determine con: vs file */
					fd = open("con:", 0);
					include(fd, "(con:)");
#endif
#ifdef UNIX
					include(0, "(stdin)");
#endif
					assemble();
					break;

				case 'i':		/* -i<path>, set directory search path */
				case 'I':
					searchpath = argv[argno] + 2;
					break;

				case '6':		/* -6: as68 kludge mode (c68 back end) */
					as68_flag = 1;
					/*FALLTHROUGH*/

				case 'u':		/* -u: make undefined symbols .globl */
				case 'U':
					glob_flag = 1;
					break;

#ifdef ST
				case 'q':		/* -q: install, like a RAMdisk */
				case 'Q':
					termres();
					/*NOTREACHED*/
#endif

				case 'v':		/* -v: verbose flag */
				case 'V':
					verb_flag = 1;
					break;

				case 'd':		/* -dsymbol[=name]: define symbol */
				case 'D':
					for (s = argv[argno] + 2; *s != EOS;)
						if (*s++ == '=')
						{
							s[-1] = EOS;
							break;
						}

					if (argv[argno][2] == EOS)
					{
						PRTERR0("-d: empty symbol\n");
						++errcnt;
						return;
					}

					sy = lookup(argv[argno]+2);
					if (sy == NULL)
					{
						sy = newsym(argv[argno]+2, LABEL, 0);
						sy->svalue = 0;
					}
					sy->sattr = DEFINED|EQUATED|ABS;

					if (*s)
						sy->svalue = (VALUE)atoi(s);
					else sy->svalue = 0;
					break;

				case 'f':		/* -f<format> */
				case 'F':
					switch (argv[argno][2])
					{
						case EOS:
						case 'a':		/* -fa = Alcyon [the default] */
						case 'A':
							obj_format = ALCYON;
							break;

						case 'm':		/* -fm = Mark Williams */
						case 'M':
							obj_format = MWC;
							switch (argv[argno][3])
							{
								case 'u':	/* -fmu: move underscore to end of name */
								case 'U':
									mwc_uflag = 1;
									break;

								case '\0':
									break;

								default:
									PRTERR0("-fm: unknown modifier");
							}
							break;

						default:
							PRTERR0("-f: unknown object format specified\n");
							++errcnt;
							return;
					}
					break;

				case 'p':		/* -p: generate ".PRG" executable output */
				case 'P':
					/*
					 * -p		.PRG generation w/o symbols
					 * -ps	.PRG generation with symbols
					 */
					switch (argv[argno][2])
					{
						case EOS:
							prg_flag = 1;
							break;

						case 's':
						case 'S':
							prg_flag = 2;
							break;

						default:
							PRTERR0("-p: syntax error\n");
							++errcnt;
							continue;
					}
					break;

				case 's':		/* -s: warn about possible short branches */
				case 'S':
					sbra_flag = 1;
					break;

				case 'x':		/* -x: turn on debugging */
				case 'X':
#ifdef DO_DEBUG
					debug = 1;
					printf("~ Debugging ON\n");
#endif
					break;

				default:
					PRTERR1("Unknown switch: %s\n", argv[argno]);
					++errcnt;
					break;

			}
		else
		{
			/*
			 *  Record first filename.
			 */
			if (firstfname == NULL) /* record first filename */
				firstfname = argv[argno];

			strcpy(fnbuf, argv[argno]);
			fext(fnbuf, ".s", 0);
			fd = open(fnbuf, 0);
			if (fd < 0)
			{
				PRTERR1("Cannot open: %s\n", fnbuf);
				++errcnt;
				continue;
			}
			include(fd, fnbuf);
			assemble();
		}

	/*
	 *  Wind-up processing
	 *    o  save current section (no more code generation)
	 *    o  do auto-even of all sections
	 *    o  determine name of object file:
	 *          -  "foo.o" for linkable output;
	 *          -  "foo.prg" for GEMDOS executable (-p flag).
	 *
	 */
	savsect();
	autoeven(TEXT);
	autoeven(DATA);
	autoeven(BSS);

	if (objfname == NULL)
	{
		if (firstfname == NULL)
			firstfname = defname;
		strcpy(fnbuf, firstfname);
		fext(fnbuf, prg_flag ? ".prg" : ".o", 1);
		objfname = fnbuf;
	}


	/*
	 *  With one pass finished, go back and:
	 *    (1)   run through all the fixups and resolve forward references;
	 *    (1.5) ensure that remaining fixups can be handled by the linker
	 *          (`lo68' format, extended (postfix) format....)
	 *    (2)   generate the output file image and symbol table;
	 *    (3)   generate relocation information from left-over fixups.
	 *
	 */
	fixups();			/* do all fixups */
	stopmark();			/* stop mark tape-recorder */
	if (errcnt == 0)
	{
		if ((fd = creat(objfname, CREATMASK)) < 0)
			cantcreat(objfname);


		if (verb_flag)
		{
			s = prg_flag ? "executable" : "object";
			printf("[Writing %s file: %s]\n", s, objfname);
		}

		object(fd);
		close(fd);
		if (errcnt != 0)
			unlink(objfname);
	}

	if (list_flag)
	{
		if (verb_flag) printf("[Wrapping-up listing file]\n");
		listing = 1;
		symtable();
		close(list_fd);
	}

	if (err_flag)
		close(err_fd);

#ifdef DO_DEBUG
	DEBUG
			dump_everything();
#endif

	return errcnt;
}


/*
 *  Cannot create a file
 */
cantcreat(fn)
char *fn;
{
	PRTERR1("Cannot create: '%s'\n", fn);
	exit(1);
}


/*
 *  Auto-even a section
 */
autoeven(sect)
int sect;
{
	switchsect(sect);
	d_even();
	savsect();
}


/*
 *  Return `item'nth element of semicolon-seperated pathnames
 *  specified in the enviroment string `s'.  Copy the pathname
 *  to `buf'.  Return 0 if the `item'nth path doesn't exist.
 *
 *  [`item' ranges from 0 to N-1, where N = #elements in search path]
 *
 */
nthpath(env_var, itemno, buf)
char *env_var;
register int itemno;
register char *buf;
{
	register char *s;
	extern char *getenv();

	s = searchpath;
	if (s == NULL)
		s = getenv("MACPATH");

	if (s == NULL)
		return 0;

	while (itemno--)
		while (*s != EOS
			   && *s++ != ';')
			;

	if (*s == EOS)
		return 0;

	while (*s != EOS &&
		   *s != ';')
		*buf++ = *s++;
	*buf++ = EOS;

	return 1;
}
