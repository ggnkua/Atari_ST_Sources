/* Copyright (c) 1988,89,91 by Sozobon, Limited.  Author: Tony Andrews
 *
 * Permission is granted to anyone to use this software for any purpose
 * on any computer system, and to redistribute it freely, with the
 * following restrictions:
 * 1) No charge may be made other than reasonable charges for reproduction.
 * 2) Modified versions must be clearly marked as such.
 * 3) The authors are not responsible for any harmful consequences
 *    of using this software, even if they result from defects in it.
 */

static	char	Version[] =
"cc: version 2.0  Copyright (c) 1988,89,91 by Sozobon, Limited.";

/*
 * cc - C compiler driver program
 *
 * Parses command line for options and file names. Then calls the
 * various passes of the compiler as needed.
 */

#include <stdio.h>
#if	MINIX || UNIXHOST
#include <sys/types.h>
#include <sys/stat.h>
#include <signal.h>
#include <errno.h>
#else
#include <types.h>
#include <stat.h>
#include <osbind.h>
#endif

#if	MINIX || UNIXHOST
#define	SEPCHAR	'/'
#else
#define	SEPCHAR	'\\'
#endif

#ifndef	MINIX
#define	rindex	strrchr
#define	index	strchr
#endif

#ifndef	TRUE
#define	FALSE	(0)
#define	TRUE	!FALSE
#endif

#define	MAXOPT	16	/* max. number of options to any one pass */

/*
 * Compiler pass information
 */
#if	MINIX || UNIXHOST
#define	CC	"hcc"
#else
#define	CC	"hcc.ttp"
#endif

char	*hccopt[MAXOPT];
int	hcc_cnt = 0;		/* number of options to hcc */

/*
 * Optimizer information
 */
#if	MINIX || UNIXHOST
#define	OPT	"top"
#else
#define	OPT	"top.ttp"
#endif

char	*topopt[MAXOPT];
int	top_cnt = 0;		/* number of options to top */

/*
 * Assembler information
 */
#if	MINIX || UNIXHOST
#define	ASM	"jas"
#define	CPP	"cpp"
#else
#define	ASM	"jas.ttp"
#endif

/*
 * Loader information
 */
#ifdef	MINIX
#define	LD	"sld"
#else
#ifdef 	UNIXHOST
#define LD	"xld"
#else
#define	LD	"ld.ttp"
#endif
#endif
char	*lsize = NULL;			/* process size (from the =N option) */

#ifdef	MINIX
#define	CSU	(pflag ? "mcrtso.o"    : "crtso.o")	/* C startup code */
#define	LIBC	(pflag ? "libp/libc.a" : "libc.a")	/* C runtime library */
#define	LIBM	(pflag ? "libp/libm.a" : "libm.a")	/* math library */
#else
#define	CSU	(pflag ? "dstartp.o" : "dstart.o")	/* C startup code */
#define	LIBC	(pflag ? "dlibsp.a"  : "dlibs.a")	/* C runtime library */
#define	LIBM	(pflag ? "libmp.a"   : "libm.a")	/* math library */
#endif

/*
 * Path information
 */

char	*path;		/* where to find executables */
char	*lib = NULL;	/* where to find library stuff */
char	*tmp = NULL;	/* where to put temporary files */

/*
 * Temp file names
 */
char	Sfile[128];	/* temp file for assembly code */
char	OSfile[128];	/* temp file for optimized assembly */
char	Lfile[128];	/* the loader command file */

/*
 * Default paths for executables and libraries
 */
#ifdef	MINIX
#define	DEFPATH		"/usr/sozobon/bin"
#define	DEFLIB		"/usr/sozobon/lib"
#define	DEFTMP		"/tmp"
#else
#ifdef UNIXHOST
#define	DEFPATH		"/home/hans/sozobon/bin"
#define	DEFLIB		"/home/hans/sozobon/lib"
#define	DEFTMP		"/tmp"
#else
#define	DEFPATH		"\\sozobon\\bin"
#define	DEFLIB		"\\sozobon\\lib"
#define	DEFTMP		"."
#endif
#endif

/*
 * Boolean options
 */
int	mflag = 0;	/* generate a load map */
int	vflag = 0;	/* show what we're doing w/ version numbers */
int	nflag = 0;	/* ...but don't really do it */
int	Sflag = 0;	/* generate assembly files */
int	cflag = 0;	/* generate ".s" files only */
int	Oflag = 0;	/* run the optimizer */
int	sflag = 0;	/* don't generate a symbol table in executables */
int	pflag = 0;	/* enable execution profiling */
int	rflag = 0;	/* enable floating point (Real numbers) */
int	fflag = 0;	/* scan given file for file names */
int	tflag = 0;	/* don't remove temporary files */
int	gflag = 0;	/* disable certain confusing optimizations */

/*
 * We build lists of the various file types we're given. Within each
 * type, MAXF says how many we can deal with.
 */
#define	MAXF	60

int	ncfiles = 0;	/* .c files */
char	*cfiles[MAXF];

int	nsfiles = 0;	/* .s files */
char	*sfiles[MAXF];

int	nofiles = 0;	/* .o files */
char	*ofiles[MAXF];

int	nlfiles = 0;	/* .a or .lib files (or files with no suffix) */
char	*lfiles[MAXF];

#ifdef	MINIX
#define	DEFOUT	"a.out"		/* default output file */
#else
#define	DEFOUT	"a.ttp"		/* default output file */
#endif

char	*output = NULL;		/* output file */

/*
 * Argument vectors for the programs we'll run.
 */
#define	MAXARG		60

char	*av[MAXARG];
int	ac;

#define	BEGARG()	(ac = 0)
#define	ADDARG(x)	(av[ac++] = (x))
#define	ENDARG()	(av[ac++] = NULL)

extern	int	errno;

int	got_sig = FALSE;	/* TRUE if we got a signal */

usage()
{
#define	P(s)	fprintf(stderr, s)

	P("Sozobon C Compiler Options:\n");
	P("-c           compile, but don't link\n");
	P("-S           don't assemble, leave .s files around (-A)\n");
	P("-O           run the assembly code optimizer\n");
	
	P("-v           show what cc is doing\n");
	P("-n           like -v, but don't really run anything\n");
	P("-f file      read a list of input files from 'file'\n");
	P("-Tdir        put temp files in 'dir' (-K)\n");
	P("-t           don't remove temp files when done (-H)\n");
	P("-p           enable execution profiling\n");
	P("-g           compile program for use with the debugger\n");
	
	P("-Ilib        add dir. 'lib' to the header search list\n");
	P("-Dsym        define the pre-processor symbol 'sym' as 1\n");
	P("-Dsym=val    or as 'val'\n");
	P("-Usym        un-define the built-in symbol 'sym'\n");
	
	P("-o file      use the file 'f' for the loader output (-X)\n");
	P("-r           link the floating point library (-Q)\n");
	P("-lxx         load the library libxx.a (-J)\n");
	P("-m           generate a load map\n");
	P("-s           don't generate a symbol table (-Y)\n");
	
	P("=nnn         make the stack/heap size nnn bytes (Minix only)\n");
	P("-R           ignored (for Minix compatibility)\n");
	P("-w           ignored (for Minix compatibility)\n");

#undef	P

	exit(1);
}

main(argc, argv)
int	argc;
char	*argv[];
{
#if MINIX || UNIXHOST
	int	catch();		/* signal handler */
#endif
	extern	char	*chsuf();
	register int	i;
	register char	*s;
	register int	endopt;
	int	domsg = FALSE;

	if (argc == 1)
		usage();

#ifdef	MINIX
	/*
	 * This is one of the places where ACK blew it. We have to check
	 * to see if we're in the background before setting up our own
	 * signal handler. ACK catches the signal anyway, so interrupting
	 * a foreground process kills any background compiles, too.
	 */
	if (signal(SIGINT, SIG_IGN) != SIG_IGN)
		signal(SIGINT, catch);
#endif
#ifdef UNIXHOST
	signal(SIGINT, catch);
#endif

	for (i=1; i < argc ;i++) {
		if (argv[i][0] == '-') {	/* option */
			endopt = FALSE;
			for (s = &argv[i][1]; *s && !endopt ;s++) {
				switch (*s) {
				case 'c': case 'C':
					cflag = TRUE;
					break;

				case 'S': case 'a': case 'A':
					Sflag = TRUE;
					break;

				case 'v': case 'V':
					vflag = TRUE;
					break;

				case 'n': case 'N':
					nflag = TRUE;
					break;

				case 'm': case 'M':
					mflag = TRUE;
					break;

				case 's': case 'y': case 'Y':
					sflag = TRUE;
					break;

				case 'r': case 'q': case 'Q':
					rflag = TRUE;
					break;

				case 'p': case 'P':
					pflag = TRUE;
					break;

				case 'g': case 'G':
					gflag = TRUE;
					break;

				case 'o': case 'x': case 'X':
					output = argv[++i];
					endopt = TRUE;
					break;

				case 'l': case 'j': case 'J':
					keeplib(s+1);
					endopt = TRUE;
					break;

				case 'f': case 'F':
					getfiles(argv[++i]);
					endopt = TRUE;
					break;

				/*
				 * Minix compatibility
				 */
				case 'R':	/* ignored */
				case 'w': case 'W':
					break;

				case 'T': case 'k': case 'K':
					tmp = s+1;
					endopt = TRUE;
					break;

				case 't': case 'h': case 'H':
					tflag = TRUE;
					break;

				/*
				 * Options for other passes.
				 */
				case 'I':	/* compiler options */
				case 'D':
				case 'U':
					hccopt[hcc_cnt++] = argv[i];
					endopt = TRUE;
					break;

				case 'z': case 'Z':
					*s = 'O';
					/* fall through */

				case 'O':
					/*
					 * Enable the optimizer, possibly with
					 * options specifically for it.
					 */
					Oflag = TRUE;
					if (s[1] != '\0')
						topopt[top_cnt++] = argv[i];
					endopt = TRUE;
					break;

				default:
					usage();
				}
			}
		} else if (argv[i][0] == '=') {	/* heap/stack size for ld */
			lsize = argv[i];
		} else				/* input file */
			keepfile(argv[i]);
	}
	doinit();

	if ((ncfiles + nsfiles) > 1)
		domsg = TRUE;

	if (vflag && !nflag)
		printf("%s\n", Version);

	for (i = 0; i < ncfiles ;i++) {
		if (domsg)
			printf("%s:\n", cfiles[i]);
		docomp(cfiles[i]);
		doopt(cfiles[i]);
		doasm(cfiles[i], TRUE);
	}

	for (i = 0; i < nsfiles ;i++) {
		if (domsg)
			printf("%s:\n", sfiles[i]);
		doasm(sfiles[i], FALSE);
	}

	dold();		/* run the loader */

	exit(0);
}

/*
 * doinit() - set up some variables before getting started
 */
doinit()
{
	char	*getenv();

	if ((path = getenv("PATH")) == NULL)
		path = DEFPATH;

	if ((lib = getenv("LIB")) == NULL)
		lib = DEFLIB;

	if (tmp == NULL) {
		if ((tmp = getenv("TMPDIR")) == NULL)
			tmp = DEFTMP;
	}

	sprintf(Sfile, "%s%cC%05d.s",   tmp, SEPCHAR, getpid());
	sprintf(OSfile, "%s%cCO%05d.s", tmp, SEPCHAR, getpid());
	sprintf(Lfile, "%s%cCL%05d.ld", tmp, SEPCHAR, getpid());
}

#if	MINIX || UNIXHOST
catch()
{
	signal(SIGINT, catch);

	got_sig = TRUE;
}
#endif

/*
 * getfiles(f) - read file names from the given file
 */
getfiles(f)
char	*f;
{
	char	*strsave();
	char	name[64];
	FILE	*fp;

	if ((fp = fopen(f, "r")) == NULL) {
		fprintf(stderr, "cc: can't open file '%s'\n", f);
		return;
	}

	while (scanf("%s", name))
		keepfile(strsave(name));

	fclose(fp);
}

/*
 * keeplib(l) - save a library reference
 *
 * Given an option like "-lm", keeplib saves a reference to a library file
 * named "libm.a". The usual places will be searched for the library when
 * the time comes. keeplib() should be called with the "-l" stripped off.
 */
keeplib(l)
char	*l;
{
	char	*strsave();
	char	name[32];

	sprintf(name, "lib%s.a", l);

	keepfile(strsave(name));
}

/*
 * keepfile(f) - remember the filename 'f' in the appropriate place
 */
keepfile(f)
char	*f;
{
	char	*p, *rindex();

	if ((p = rindex(f, '.')) == NULL) {	/* no suffix */
		lfiles[nlfiles++] = f;
		return;
	}

	if ((strcmp(p, ".c") == 0) || (strcmp(p, ".C") == 0)) {
		cfiles[ncfiles++] = f;
		return;
	}
	if ((strcmp(p, ".s") == 0) || (strcmp(p, ".S") == 0)) {
		sfiles[nsfiles++] = f;
		return;
	}
	if ((strcmp(p, ".o") == 0) || (strcmp(p, ".O") == 0)) {
		ofiles[nofiles++] = f;
		return;
	}
	if ((strcmp(p, ".a") == 0) || (strcmp(p, ".A") == 0)) {
		lfiles[nlfiles++] = f;
		return;
	}
	fprintf(stderr, "cc: unknown file suffix '%s'\n", f);
	exit(1);
}

/*
 * chsuf(f, suf) - change the suffix of file 'f' to 'suf'.
 *
 * Space for the new string is obtained using malloc().
 */
char *
chsuf(f, suf)
char	*f;
char	*suf;
{
	char	*malloc();
	char	*s, *p;

	p = s = malloc(strlen(f) + strlen(suf) + 1);

	strcpy(p, f);

	for (; *p ; p++) {
		if (*p == '.')
			break;
	}

	while (*suf)
		*p++ = *suf++;

	*p = '\0';

	return s;
}

/*
 * isfile(f) - return true if the given file exists
 */
int
isfile(f)
char	*f;
{
	struct	stat	sbuf;

	if (stat(f, &sbuf) < 0)
		return FALSE;

	return TRUE;
}

/*
 * findfile(e, b)
 *
 * Finds a file in one of the directories given in the environment
 * variable whose value is pointed to by 'e'. Looks for the file
 * given by the name 'b'.
 *
 * Returns a pointer to a static area containing the pathname of the
 * file, if found, NULL otherwise.
 */
char *
findfile(e, b)
char	*e;
register char	*b;
{
	static	char	file[256];
	char	env[256];
	register char	*p;

	/*
	 * Make a copy of the value of the env. variable. Convert all
	 * delimiters to nulls.
	 */
	if (e != NULL) {
		strcpy(env, e);
		for (p = env; *p ;p++) {
#if	MINIX || UNIXHOST
			if (*p == ':')
#else
			if (*p == ';' || *p == ',')
#endif
				*p = '\0';
		}
		p[1] = '\0';		/* double null terminator */
	} else
		env[1] = env[0] = '\0';

	p = env;
	/*
	 * An initial null means to try the current directory.
	 */
	if (*p == '\0') {
		if (isfile(b))
			return b;
		p++;
	}

	while (*p) {
		sprintf(file, "%s%c%s", p, SEPCHAR, b);
		if (isfile(file))
			return file;

		while (*p++ != '\0')
			;
	}
	return NULL;		/* give up */
}

#if	MINIX || UNIXHOST
/*
 * docmd(path, argv) - run a command
 *
 * We check for an interrupt before and after executing the command.
 * The sub-processes we run are the only very time-consuming thing we
 * do in 'cc', so there's not much point in checking for signals in
 * other places. When a signal comes in, we just delete the temp files.
 */
int
docmd(path, argv)
char	*path;
char	*argv[];
{
	void	cleanup();
	int	i;
	int	pid, status;
	char	buf[512];
	int	dosystem = FALSE;

	if (vflag || nflag) {
		fprintf(stderr, "%s", path);
		for (i=1; argv[i] != NULL ;i++)
			fprintf(stderr, " %s", argv[i]);
		fputc('\n', stderr);
		fflush(stderr);
		if (nflag)
			return 0;
	}
	/*
	 * Figure out whether exec() is okay or we need a shell.
	 */
	for (i=1; argv[i] != NULL ;i++)
		if (argv[i][0] == '>' || argv[i][0] == '<')
			dosystem = TRUE;

	if (got_sig)
		cleanup();

	if (dosystem) {
		strcpy(buf, path);
		for (i=1; argv[i] != NULL ;i++) {
			strcat(buf, " ");
			strcat(buf, argv[i]);
		}
		return system(buf);
	} else {

		/*
		 * Fork and exec the command.
		 */

		if ((pid = fork()) < 0) {
			fprintf(stderr, "cc: can't fork\n");
			return -1;
		}
	
		if (pid == 0) {			/* the child */
			execv(path, argv);
			fprintf(stderr, "cc: Can't exec '%s'\n", path);
			exit(1);
		} else {			/* the parent */
			if (wait(&status) == -1 && errno != EINTR) {
				fprintf(stderr,"cc: wait failed (%d)\n", errno);
				return -1;
			} else if ((status & 0xff) == 0)
				return (status >> 8);
		}
	}
	if (got_sig)
		cleanup();

	return -1;
}

void
cleanup()
{
	unlink(Sfile);
	unlink(OSfile);
	unlink(Lfile);

	exit(1);
}

#else

/*
 * docmd(path, argv) - run a command
 */
int
docmd(path, argv)
char	*path;
char	*argv[];
{
	int	i;
	char	cmdline[130];
	char	*cmd;

	cmd = &cmdline[1];
	*cmd = '\0';

	for (i=1; argv[i] != NULL ;i++) {
		if (i > 1)
			strcat(cmd, " ");
		strcat(cmd, argv[i]);
	}
	cmdline[0] = strlen(cmd);

	if (vflag || nflag) {
		fprintf(stderr, "%s %s\n", path, cmd);
		fflush(stderr);
		if (nflag)
			return 0;
	}

	i = Pexec(0, path, cmdline, 0L);

	return i;
}
#endif

/*
 * docomp(f) - run the compiler on the given .c file
 */
docomp(f)
char	*f;
{
	int	i;
	char	*cpath, *sf;
	char	tbuf[128];
	char	sbuf[128];
	int	notmp;		/* don't use temp directory */

	/*
	 * Don't use a temp directory if all we want is the assembly file,
	 * and we're not optimizing.
	 */
	notmp = (Sflag && !Oflag);

	if ((cpath = findfile(path, CC)) == NULL) {
		fprintf(stderr, "cc: can't find compiler program '%s'\n", CC);
		exit(1);
	}

	BEGARG();
	ADDARG(CC);

	if (!notmp) {
		sprintf(tbuf, "-T%s", tmp);
		ADDARG(tbuf);
	}

	if (pflag)
		ADDARG("-P");

	for (i=0; i < hcc_cnt ;i++)
		ADDARG(hccopt[i]);

	ADDARG(f);
	ENDARG();

	sf = chsuf(f, ".s");
	if (notmp)
		strcpy(sbuf, sf);
	else
		sprintf(sbuf, "%s%c%s", tmp, SEPCHAR, sf);

	free(sf);

	if (docmd(cpath, av)) {
		fremove(sbuf);
		fprintf(stderr, "cc: compiler failed\n");
		exit(1);
	}

	if (!notmp)
		frename(sbuf, Sfile);		/* fix the temp file name */
}

/*
 * doopt(f) - run the optimizer
 *
 * Only optimize files that were produced by the compiler.
 */
doopt(f)
char	*f;
{
	int	i;
	char	*opath;
	char	*sf;
	char	*of;		/* the output file name */

	if (!Oflag)
		return;

	if ((opath = findfile(path, OPT)) == NULL) {
		fprintf(stderr, "cc: can't find optimizer program '%s'\n", OPT);
		exit(1);
	}

	sf = chsuf(f, ".s");

	BEGARG();
	ADDARG(OPT);

	for (i=0; i < top_cnt ;i++)
		ADDARG(topopt[i]);

	/*
	 * The -g option turns off certain optimizations that make the
	 * debugger more difficult to use. These mostly involve messing
	 * with the stack frame, and make it harder to get accurate
	 * stack backtraces while stepping through a program.
	 */
	if (gflag)
		ADDARG("-g");

	ADDARG(Sfile);			/* the input file */

	of = (Sflag) ? sf : OSfile;	/* what's the output file name? */

	ADDARG(of);
	ENDARG();

	if (docmd(opath, av)) {
		if (Sflag) {	/* error is fatal if we wanted the assembly */
			fremove(Sfile);
			fremove(of);
			fprintf(stderr, "cc: optimizer failed (aborting)\n");
			exit(1);
		} else {	/* try to press on... */
			/*
			 * We continue by pretending we optimized the
			 * assembly file when we really didn't.
			 */
			frename(Sfile, of);
			fprintf(stderr, "cc: optimizer failed (continuing)\n");
		}
	}
	free(sf);
	fremove(Sfile);
}

/*
 * doasm() - run the assembler
 *
 * If 'istmp' is TRUE, the file we were given is a temporary. If we aren't
 * working on a temp file, we may need to run the assembly through the C
 * preprocessor. If the first character in the file is '#', we do it.
 */
doasm(f, istmp)
char	*f;
int	istmp;
{
	char	*strrchr(), *getenv();
	int	i;
	char	*dpath;
	char	*sf;		/* file.s */
	char	*infile;	/* the assembler input file */
	char	*outfile;	/* the assembler output */

	if (Sflag)
		return;

	outfile = chsuf(f, ".o");

	/*
	 * We want the -o option to be able to specify the output file
	 * from the assembler. This only makes sense if -c is given, and
	 * there is only one input file.
	 */
	if (cflag && (output != NULL) && ((ncfiles+nsfiles) == 1))
		outfile = output;

	/*
	 * Assume a temp file for now. May change...
	 */
	infile = (Oflag) ? OSfile : Sfile;

	/*
	 * If this isn't a temp file, we may have to run the C preprocessor
	 * on it. If the first character of the file isn't '#', then we can
	 * skip it and just run the assembler.
	 */
	if (!istmp) {

#ifdef	MINIX
		int	fd;
		char	c;

		if ((fd = open(f, 0)) < 0) {
			fprintf(stderr, "cc: can't open file '%s'\n", f);
			exit(1);
		}
		if (read(fd, &c, 1) != 1) {
			fprintf(stderr, "cc: can't read file '%s'\n", f);
			exit(1);
		}
		close(fd);

		if (c == '#') {
			if ((dpath = findfile(lib, CPP)) == NULL) {
				fprintf(stderr,
					"cc: can't find C preprocessor '%s'\n",
					CPP);
				exit(1);
			}
			BEGARG();
			ADDARG(dpath);
	
			/*
			 * The -P option removes "#file" and "#line" directives
			 * from the generated output.
			 */
			ADDARG("-P");
	
			/*
			 * Include any pre-processor directives (-D, -I, or -U)
			 */
			for (i=0; i < hcc_cnt ;i++)
				ADDARG(hccopt[i]);
	
			ADDARG(f);
			ADDARG(">");
			ADDARG(Sfile);
			ENDARG();
	
			if (docmd(dpath, av)) {
				fprintf(stderr,
					"cc: preprocessor failed '%s'\n", f);
				fremove(Sfile);
				exit(1);
			}
			infile = Sfile;
		} else
			infile = f;
#else
		infile = f;
#endif
	}

	if ((dpath = findfile(path, ASM)) == NULL) {
		fprintf(stderr, "cc: can't find assembler program '%s'\n", ASM);
		exit(1);
	}


	BEGARG();
	ADDARG(ASM);

	ADDARG(infile);
	ADDARG("-o");
	ADDARG(outfile);
	ENDARG();

	if (docmd(dpath, av)) {
		fprintf(stderr, "cc: assembler failed '%s'\n", infile);
		if (infile != f)
			fremove(infile);
		exit(1);
	}
	free(outfile);

	if (infile != f)
		fremove(infile);
}

/*
 * dold() - run the loader
 */
dold()
{
	FILE	*fp, *fopen();
	int	i;
	char	*lpath;
	char	*s;
	char	*l;

	if (cflag || Sflag)
		return;

	/*
	 * Construct loader command file
	 */
	if ((fp = fopen(Lfile, "w")) == NULL) {
		fprintf(stderr, "cc: can't open loader temp file\n");
		exit(1);
	}

	if ((lpath = findfile(lib, CSU)) == NULL) {
		fprintf(stderr, "cc: can't find C startup code '%s'\n", CSU);
		exit(1);
	}
	fprintf(fp, "%s\n", lpath);

	for (i = 0; i < ncfiles ;i++) {
		s = chsuf(cfiles[i], ".o");
		fprintf(fp, "%s\n", s);
		free(s);
	}
	for (i = 0; i < nsfiles ;i++) {
		s = chsuf(sfiles[i], ".o");
		fprintf(fp, "%s\n", s);
		free(s);
	}
	for (i = 0; i < nofiles ;i++)
		fprintf(fp, "%s\n", ofiles[i]);

	for (i = 0; i < nlfiles ;i++) {
		if (isfile(lfiles[i])) {
			fprintf(fp, "%s\n", lfiles[i]);
		} else {
			lpath = findfile(lib, lfiles[i]);
			if (lpath == NULL) {
				fprintf(stderr, "cc: can't find library '%s'\n", lfiles[i]);
				exit(1);
			}
			fprintf(fp, "%s\n", lpath);
		}
	}

	if (rflag) {
		if ((lpath = findfile(lib, LIBM)) == NULL) {
			fprintf(stderr, "cc: can't find floating point library '%s'\n", LIBM);
			exit(1);
		}
		fprintf(fp, "%s\n", lpath);
	}

	if ((lpath = findfile(lib, LIBC)) == NULL) {
		fprintf(stderr, "cc: can't find C runtime library '%s'\n",LIBC);
		exit(1);
	}
	fprintf(fp, "%s\n", lpath);

	fclose(fp);

	if ((lpath = findfile(path, LD)) == NULL) {
		fprintf(stderr, "cc: can't find loader program '%s'\n", LD);
		exit(1);
	}

	BEGARG();
	ADDARG(LD);
	ADDARG("-p");
	ADDARG("-b");
	if (lsize != NULL)
		ADDARG(lsize);
	if (mflag)
		ADDARG("-m");
	if (!sflag)
		ADDARG("-t");
	if (rflag) {
		ADDARG("-u");
		ADDARG("__printf");
		ADDARG("-u");
		ADDARG("__scanf");
	}
	ADDARG("-o");
	ADDARG((output != NULL) ? output : DEFOUT);
	ADDARG("-f");
	ADDARG(Lfile);

	if (docmd(lpath, av)) {
		fprintf(stderr, "cc: loader failed\n");
		fremove(Lfile);
		fremove(output);
		exit(1);
	}

	for (i = 0; i < ncfiles ;i++) {
		s = chsuf(cfiles[i], ".o");
		fremove(s);
		free(s);
	}

	for (i = 0; i < nsfiles ;i++) {
		s = chsuf(sfiles[i], ".o");
		fremove(s);
		free(s);
	}

	fremove(Lfile);
}

int
frename(f1, f2)
char	*f1, *f2;
{
	if (vflag || nflag)
		fprintf(stderr, "mv %s %s\n", f1, f2);

#if	MINIX || UNIXHOST
	unlink(f2);
	link(f1, f2);
	unlink(f1);
#else
	rename(f1, f2);
#endif
}

fremove(f)
char	*f;
{
	if (vflag || nflag)
		fprintf(stderr, "rm %s\n", f);

	if (!tflag)
		unlink(f);
}

char *
strsave(string)
char	*string;
{
	char	*malloc(), *strcpy();

	return (strcpy(malloc((unsigned)(strlen(string)+1)), string));
}
