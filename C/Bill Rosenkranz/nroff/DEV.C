/*
 *	this is not complete. it still uses internal values (does not read
 *	/usr/lib/term/tabname)
 */

#include <stdio.h>
#include "nroff.h"

/*
 *	default prefix of tab files. files will be of the form "tabname"
 *	where name is the specific printing device (e.b. "atari", "epson").
 *	checks environment for TABDIR which would be path (e.g. "c:\lib\term"
 *	or ".", no trailing slash char!).
 *
 *	the dir is BSD-ish (which uses /usr/lib/term) rather than s5 (which
 *	i believe uses /usr/lib/nterm).
 */
#ifdef tabfull
# define TABFULL	tabfull
#endif
#ifdef tabpre
# define TABPRE		tabpre
#endif

#ifdef GEMDOS
# ifndef TABFULL
#  define TABFULL	"c:\\lib\\term\\tab\0                                "
# endif
# ifndef TABPRE
#  define TABPRE	"\\tab\0                "
# endif
#endif

#ifdef MINIX
# ifndef TABFULL
#  define TABFULL	"/usr/lib/term/tab"
# endif
# ifndef TABPRE
#  define TABPRE	"/tab"
# endif
#endif

#ifdef UNIX
# ifndef TABFULL
#  define TABFULL	"/usr/lib/term/tab"
# endif
# ifndef TABPRE
#  define TABPRE	"/tab"
# endif
#endif

struct escseq
{
	char	e_esc[2];
	char	e_map;
};


static struct escseq	altmap[256];		/* for altset */
static struct escseq	normmap[256];		/* for normal set */

char		       *kwdlist[] =
{
	"charset",
	"altset",
	0L
};

/*
 *	these MUST match index of entry in kwdlist[]
 */
#define KW_NONE		-1
#define KW_CHARSET	0
#define KW_ALTSET	1

char   *getenv ();
char   *malloc ();


/*------------------------------*/
/*	dev_init		*/
/*------------------------------*/
dev_init (name)
char   *name;
{
	FILE   *stream;
	char	mfile[256];
	char   *ptab;
	int	ret;


	/*
	 *   if no name, use defaults
	 */
	if (name == NULL_CPTR || *name == '\0')
	{
		return (0);
	}


	/*
	 *   build tab file name. start with lib
	 *
	 *   put c:\lib\term in environment so we can
	 *   read it here. else use default. if you want
	 *   file from cwd, "setenv TABDIR ." from shell.
	 *
	 *   we want file names like "tabname" (for -Tname)
	 */
	if (ptab = getenv ("TABDIR"))
	{
		/*
		 *   this is the lib path (e.g. "c:\lib\term")
		 */
		strcpy (mfile, ptab);

		/*
		 *   this is the prefix (i.e. "\tab")
		 */
		strcat (mfile, TABPRE);
	}
	else
		/*
		 *   use default lib/prefix (i.e.
		 *   "c:\lib\term\tab")
		 */
		strcpy (mfile, TABFULL);

	/*
	 *   finally, add extension (e.g. "name")
	 */
	strcat (mfile, name);

	/*
	 *   open file and read it
	 */
	if ((stream = fopen (mfile, "r")) == NULL_FPTR)
	{
		fprintf (stderr,
			"***%s: unable to open printer device file %s\n",
			myname, mfile);
		err_exit (-1);
	}

	ret = readtab (stream);

	fclose (stream);

	return (ret);
}


/*------------------------------*/
/*	dev_char		*/
/*------------------------------*/
int dev_char (c1, c2, c)		/* returns num chars
register char	c1;			/* first char in escape */
register char	c2;			/* second char in escape */
register char  *c;			/* ascii char to return */
{

/*
 *	handle specific output devices.
 *
 *	this will eventually read \lib\term\tab* files, but for now, we just
 *	use our ANSI/vt100 scheme. in future, main will call something to
 *	read -Tname (tabname) file, which would initialize a table of c1c2
 *	vs ascii char. this routine would then read that table and presumably
 *	return a string rather than a single char.
 */

	/*
	 *   special symbols
	 */
	if (c1 == 'e' && c2 == 'm') {*c = '-'; return (2);}	/* long dash */
	if (c1 == 'h' && c2 == 'y') {*c = ','; return (2);}	/* hyphen */
	if (c1 == 'b' && c2 == 'u') {*c = '*'; return (2);}	/* bullet */
	if (c1 == 's' && c2 == 'q') {*c = 0xef; return (2);}	/* square */
	if (c1 == 'r' && c2 == 'u') {*c = '_'; return (2);}	/* rule */
	if (c1 == 'u' && c2 == 'l') {*c = '^'; return (2);}	/* underrule */
	if (c1 == 'o' && c2 == 'l') {*c = ';'; return (2);}	/* overrule */
	if (c1 == 'r' && c2 == '2') {*c = 0x3f; return (2);}	/* thin rule */
	if (c1 == 'u' && c2 == '2') {*c = 0x9d; return (2);}	/* thin underrule */
	if (c1 == 'o' && c2 == '2') {*c = 0x40; return (2);}	/* thin overrule */
	if (c1 == '1' && c2 == '4') {*c = 0xac; return (2);}	/* 1/4 */
	if (c1 == '1' && c2 == '2') {*c = 0xab; return (2);}	/* 1/2 */
	if (c1 == '3' && c2 == '4') {*c = 0xad; return (2);}	/* 3/4 */
	if (c1 == 'd' && c2 == 'e') {*c = 0xf8; return (2);}	/* degree */
	if (c1 == 'd' && c2 == 'g') {*c = 0xbb; return (2);}	/* dagger */
	if (c1 == 'c' && c2 == 't') {*c = '$'; return (2);}	/* cent */
	if (c1 == 'r' && c2 == 'g') {*c = 0xbe; return (2);}	/* registered */
	if (c1 == 'c' && c2 == 'o') {*c = 0xbd; return (2);}	/* copyrite */
	if (c1 == 't' && c2 == 'm') {*c = 0xbf; return (2);}	/* tm */
	if (c1 == 's' && c2 == 'c') {*c = 0xdd; return (2);}	/* section */
	if (c1 == 'a' && c2 == 'a') {*c = 0x27; return (2);}	/* acute */
	if (c1 == 'g' && c2 == 'a') {*c = 0x60; return (2);}	/* grave */
	if (c1 == 's' && c2 == 'l') {*c = '/'; return (2);}	/* slash */
	if (c1 == '.' && c2 == '.') {*c = ':'; return (2);}	/* elipsis */
	if (c1 == 'P' && c2 == 'P') {*c = 0xbc; return (2);}	/* para */
	if (c1 == 'o' && c2 == 'q') {*c = '!'; return (2);}	/* open " */
	if (c1 == 'c' && c2 == 'q') {*c = '\"'; return (2);}	/* close " */
	if (c1 == 'd' && c2 == 'd') {*c = 0xba; return (2);}	/* dbl dagger */


	/*
	 *   greek
	 */
	if (c1 == '*' && c2 >= 'a' && c2 <= 'z')
	{
		/*
		 *   lower case
		 */
		if (c2 == 'a') {*c = 'a'; return (2);}	/* alpha */
		if (c2 == 'b') {*c = 'b'; return (2);}	/* beta */
		if (c2 == 'g') {*c = 'g'; return (2);}	/* gamma */
		if (c2 == 'd') {*c = 'd'; return (2);}	/* delta */
		if (c2 == 'e') {*c = 'e'; return (2);}	/* epsilon */
		if (c2 == 'z') {*c = 'z'; return (2);}	/* zeta */
		if (c2 == 'y') {*c = 'y'; return (2);}	/* eta */
		if (c2 == 'h') {*c = 'h'; return (2);}	/* theta */
		if (c2 == 'i') {*c = 'i'; return (2);}	/* iota */
		if (c2 == 'k') {*c = 'k'; return (2);}	/* kappa */
		if (c2 == 'l') {*c = 'l'; return (2);}	/* lambda */
		if (c2 == 'm') {*c = 'm'; return (2);}	/* mu */
		if (c2 == 'n') {*c = 'n'; return (2);}	/* nu */
		if (c2 == 'c') {*c = 'c'; return (2);}	/* xi */
		if (c2 == 'o') {*c = 'o'; return (2);}	/* omicron */
		if (c2 == 'p') {*c = 'p'; return (2);}	/* pi */
		if (c2 == 'r') {*c = 'r'; return (2);}	/* rho */
		if (c2 == 's') {*c = 's'; return (2);}	/* sigma */
		if (c2 == 't') {*c = 't'; return (2);}	/* tau */
		if (c2 == 'u') {*c = 'u'; return (2);}	/* upsilon */
		if (c2 == 'f') {*c = 'f'; return (2);}	/* phi */
		if (c2 == 'x') {*c = 'x'; return (2);}	/* chi */
		if (c2 == 'q') {*c = 'q'; return (2);}	/* psi */
		if (c2 == 'w') {*c = 'w'; return (2);}	/* omega */
	}
	if (c1 == '*' && c2 >= 'A' && c2 <= 'Z')
	{
		/*
		 *   upper case
		 */
		if (c2 == 'A') {*c = 'A'; return (2);}	/* Alpha */
		if (c2 == 'B') {*c = 'B'; return (2);}	/* Beta */
		if (c2 == 'G') {*c = 'G'; return (2);}	/* Gamma */
		if (c2 == 'D') {*c = 'D'; return (2);}	/* Delta */
		if (c2 == 'E') {*c = 'E'; return (2);}	/* Epsilon */
		if (c2 == 'Z') {*c = 'Z'; return (2);}	/* Zeta */
		if (c2 == 'Y') {*c = 'Y'; return (2);}	/* Eta */
		if (c2 == 'H') {*c = 'H'; return (2);}	/* Theta */
		if (c2 == 'I') {*c = 'I'; return (2);}	/* Iota */
		if (c2 == 'K') {*c = 'K'; return (2);}	/* Kappa */
		if (c2 == 'L') {*c = 'L'; return (2);}	/* Lambda */
		if (c2 == 'M') {*c = 'M'; return (2);}	/* Mu */
		if (c2 == 'N') {*c = 'N'; return (2);}	/* Nu */
		if (c2 == 'C') {*c = 'C'; return (2);}	/* Xi */
		if (c2 == 'O') {*c = 'O'; return (2);}	/* Omicron */
		if (c2 == 'P') {*c = 'P'; return (2);}	/* Pi */
		if (c2 == 'R') {*c = 'R'; return (2);}	/* Rho */
		if (c2 == 'S') {*c = 'S'; return (2);}	/* Sigma */
		if (c2 == 'T') {*c = 'T'; return (2);}	/* Tau */
		if (c2 == 'U') {*c = 'U'; return (2);}	/* Upsilon */
		if (c2 == 'F') {*c = 'F'; return (2);}	/* Phi */
		if (c2 == 'X') {*c = 'X'; return (2);}	/* Chi */
		if (c2 == 'Q') {*c = 'Q'; return (2);}	/* Psi */
		if (c2 == 'W') {*c = 'W'; return (2);}	/* Omega */
	}


	/*
	 *   box chars
	 */
	if (c1 == 'L' && c2 >= 'a' && c2 <= 'k')
	{
		/*
		 *   single line
		 */
		if (c2 == 'a') {*c = 0xd0; return (2);}	/**/
		if (c2 == 'b') {*c = 0xd1; return (2);}	/**/
		if (c2 == 'c') {*c = 0xd2; return (2);}	/**/
		if (c2 == 'd') {*c = 0xd3; return (2);}	/**/
		if (c2 == 'e') {*c = 0xd4; return (2);}	/**/
		if (c2 == 'f') {*c = 0xd5; return (2);}	/**/
		if (c2 == 'g') {*c = 0xd6; return (2);}	/**/
		if (c2 == 'h') {*c = 0xd7; return (2);}	/**/
		if (c2 == 'i') {*c = 0xd8; return (2);}	/**/
		if (c2 == 'j') {*c = 0xd9; return (2);}	/**/
		if (c2 == 'k') {*c = 0xda; return (2);}	/**/
	}
	if (c1 == 'L' && c2 >= 'A' && c2 <= 'Q')
	{
		/*
		 *   double line
		 */
		if (c2 == 'A') {*c = 0xc0; return (2);}	/**/
		if (c2 == 'B') {*c = 0xc1; return (2);}	/**/
		if (c2 == 'C') {*c = 0xc2; return (2);}	/**/
		if (c2 == 'D') {*c = 0xc3; return (2);}	/**/
		if (c2 == 'E') {*c = 0xc4; return (2);}	/**/
		if (c2 == 'F') {*c = 0xc5; return (2);}	/**/
		if (c2 == 'G') {*c = 0xc6; return (2);}	/**/
		if (c2 == 'H') {*c = 0xc7; return (2);}	/**/
		if (c2 == 'I') {*c = 0xc8; return (2);}	/**/
		if (c2 == 'J') {*c = 0xc9; return (2);}	/**/
		if (c2 == 'K') {*c = 0xca; return (2);}	/**/
		if (c2 == 'L') {*c = 0xcb; return (2);}	/**/
		if (c2 == 'M') {*c = 0xcc; return (2);}	/**/
		if (c2 == 'N') {*c = 0xcd; return (2);}	/**/
		if (c2 == 'O') {*c = 0xce; return (2);}	/**/
		if (c2 == 'P') {*c = 0xcf; return (2);}	/**/
		if (c2 == 'Q') {*c = 0x80; return (2);}	/**/
	}


	/*
	 *   number super/subscripts
	 */
	if (c1 == 'b' && c2 >= '0' && c2 <= '9')
	{
		if (c2 == '0') {*c = 0xa0; return (2);}	/* sub 0 */
		if (c2 == '1') {*c = 0xa1; return (2);}	/* sub 1 */
		if (c2 == '2') {*c = 0xa2; return (2);}	/* sub 2 */
		if (c2 == '3') {*c = 0xa3; return (2);}	/* sub 3 */
		if (c2 == '4') {*c = 0xa4; return (2);}	/* sub 4 */
		if (c2 == '5') {*c = 0xa5; return (2);}	/* sub 5 */
		if (c2 == '6') {*c = 0xa6; return (2);}	/* sub 6 */
		if (c2 == '7') {*c = 0xa7; return (2);}	/* sub 7 */
		if (c2 == '8') {*c = 0xa8; return (2);}	/* sub 8 */
		if (c2 == '9') {*c = 0xa9; return (2);}	/* sub 9 */
	}
	if (c1 == 'p' && c2 >= '0' && c2 <= '9')
	{
		if (c2 == '0') {*c = 0x30; return (2);}	/* super 0 */
		if (c2 == '1') {*c = 0x31; return (2);}	/* super 1 */
		if (c2 == '2') {*c = 0x32; return (2);}	/* super 2 */
		if (c2 == '3') {*c = 0x33; return (2);}	/* super 3 */
		if (c2 == '4') {*c = 0x34; return (2);}	/* super 4 */
		if (c2 == '5') {*c = 0x35; return (2);}	/* super 5 */
		if (c2 == '6') {*c = 0x36; return (2);}	/* super 6 */
		if (c2 == '7') {*c = 0x37; return (2);}	/* super 7 */
		if (c2 == '8') {*c = 0x38; return (2);}	/* super 8 */
		if (c2 == '9') {*c = 0x39; return (2);}	/* super 9 */
	}


	/*
	 *   arrows
	 */
	if (c1 == '-' && c2 == '>') {*c = 0x83; return (2);}	/* r arrow */
	if (c1 == '<' && c2 == '-') {*c = 0x84; return (2);}	/* l arrow */
	if (c1 == 'u' && c2 == 'a') {*c = 0x81; return (2);}	/* u arrow */
	if (c1 == 'd' && c2 == 'a') {*c = 0x82; return (2);}	/* d arrow */
	if (c1 == '>' && c2 >= 'a' && c2 <= 'k')
	{
		if (c2 == 'a') {*c = 0x85; return (2);}		/* arrow vert*/
		if (c2 == 'b') {*c = 0x86; return (2);}		/* arrow hor*/
		if (c2 == 'c') {*c = 0x87; return (2);}		/* arrow up r*/
		if (c2 == 'd') {*c = 0x88; return (2);}		/* arrow up l*/
		if (c2 == 'e') {*c = 0x89; return (2);}		/* arrow dn r*/
		if (c2 == 'f') {*c = 0x8a; return (2);}		/* arrow dn l*/
		if (c2 == 'g') {*c = 0x8b; return (2);}		/* arrow dn l*/
		if (c2 == 'h') {*c = 0x8c; return (2);}		/* arrow dn l*/
		if (c2 == 'i') {*c = 0x8d; return (2);}		/* arrow dn l*/
		if (c2 == 'j') {*c = 0x8e; return (2);}		/* arrow dn l*/
		if (c2 == 'k') {*c = 0x8f; return (2);}		/* arrow dn l*/
	}

	
	/*
	 *   math
	 */
	if (c1 == 'm' && c2 == 'u') {*c = '#'; return (2);}	/* mult */
	if (c1 == 'd' && c2 == 'i') {*c = 0xf6; return (2);}	/* divide */
	if (c1 == 'p' && c2 == 'l') {*c = '+'; return (2);}	/* plus */
	if (c1 == 'm' && c2 == 'i') {*c = '-'; return (2);}	/* minus */
	if (c1 == 'e' && c2 == 'q') {*c = '='; return (2);}	/* equal */
	if (c1 == '*' && c2 == '*') {*c = 0xf9; return (2);}	/* star */
	if (c1 == 'i' && c2 == '1') {*c = 0xf4; return (2);}	/* int top */
	if (c1 == 'i' && c2 == '2') {*c = 0xf5; return (2);}	/* int top */
	if (c1 == 's' && c2 == 'r') {*c = 0xfb; return (2);}	/* sq root */
	if (c1 == 'r' && c2 == 'n') {*c = 0xfa; return (2);}	/* root ext */
	if (c1 == '>' && c2 == '=') {*c = 0xf2; return (2);}	/* >= */
	if (c1 == '<' && c2 == '=') {*c = 0xf3; return (2);}	/* <= */
	if (c1 == '=' && c2 == '=') {*c = 0xf0; return (2);}	/* exactly = */
	if (c1 == '~' && c2 == '=') {*c = 0x28; return (2);}	/* ~= */
	if (c1 == 'a' && c2 == 'p') {*c = '~'; return (2);}	/* approx */
	if (c1 == '!' && c2 == '=') {*c = 0x29; return (2);}	/* != */
	if (c1 == '+' && c2 == '-') {*c = 0xf1; return (2);}	/* +- */
	if (c1 == 'c' && c2 == 'u') {*c = 0x91; return (2);}	/* cup */
	if (c1 == 'c' && c2 == 'a') {*c = 0x90; return (2);}	/* cap */
	if (c1 == 's' && c2 == 'b') {*c = 0x99; return (2);}	/* subset */
	if (c1 == 's' && c2 == 'p') {*c = 0x9a; return (2);}	/* superset */
	if (c1 == 'i' && c2 == 'b') {*c = 0x94; return (2);}	/* imp subset */
	if (c1 == 'i' && c2 == 'p') {*c = 0x95; return (2);}	/* imp superset*/
	if (c1 == 'i' && c2 == 'f') {*c = 0xdf; return (2);}	/* infinity */
	if (c1 == 'p' && c2 == 'd') {*c = 0x97; return (2);}	/* part deriv */
	if (c1 == 'g' && c2 == 'r') {*c = 0x93; return (2);}	/* gradient */
	if (c1 == 'n' && c2 == 'o') {*c = 0xaa; return (2);}	/* not */
	if (c1 == 'i' && c2 == 's') {*c = 0xec; return (2);}	/* integral */
	if (c1 == 'p' && c2 == 't') {*c = 0x98; return (2);}	/* prop to */
	if (c1 == 'e' && c2 == 's') {*c = 0x92; return (2);}	/* empty set */
	if (c1 == 'm' && c2 == 'o') {*c = 0x96; return (2);}	/* member of */
	if (c1 == 'b' && c2 == 'r') {*c = '|'; return (2);}	/* box rule */
	if (c1 == 'r' && c2 == 'h') {*c = 0x9f; return (2);}	/* r hand */
	if (c1 == 'l' && c2 == 'h') {*c = 0x9e; return (2);}	/* l hand */
	if (c1 == 'o' && c2 == 'r') {*c = 0x9b; return (2);}	/* or */
	if (c1 == 'c' && c2 == 'i') {*c = 0xee; return (2);}	/* circle */
	if (c1 == '>' && c2 == '>') {*c = 0xaf; return (2);}	/* >> */
	if (c1 == '<' && c2 == '<') {*c = 0xae; return (2);}	/* << */
	if (c1 == 'm' && c2 == '.') {*c = '.'; return (2);}	/* math dot */
	if (c1 == 'd' && c2 == 'l') {*c = 0xeb; return (2);}	/* math delta */
	if (c1 == '-' && c2 == '-') {*c = 0x86; return (2);}	/* divide bar */


	/*
	 *   large brackets, curly
	 */
	if (c1 == 'l' && c2 == 't') {*c = 0xe0; return (2);}	/* l top */
	if (c1 == 'l' && c2 == 'b') {*c = 0xe1; return (2);}	/* l bottom */
	if (c1 == 'r' && c2 == 't') {*c = 0xe2; return (2);}	/* r top */
	if (c1 == 'r' && c2 == 'b') {*c = 0xe3; return (2);}	/* r bottom */
	if (c1 == 'l' && c2 == 'k') {*c = 0xe4; return (2);}	/* l center */
	if (c1 == 'r' && c2 == 'k') {*c = 0xe5; return (2);}	/* r center */
	if (c1 == 'b' && c2 == 'v') {*c = 0xe6; return (2);}	/* bold vert */


	/*
	 *   large brackets, square (use bv, too)
	 */
	if (c1 == 'l' && c2 == 'f') {*c = 0xe7; return (2);}	/* l floor */
	if (c1 == 'r' && c2 == 'f') {*c = 0xe8; return (2);}	/* r floor */
	if (c1 == 'l' && c2 == 'c') {*c = 0xe9; return (2);}	/* l ceiling */
	if (c1 == 'r' && c2 == 'c') {*c = 0xea; return (2);}	/* r ceiling */

	if (c1 == '[' && c2 == '[') {*c = '['; return (2);}	/* larger [ */
	if (c1 == ']' && c2 == ']') {*c = ']'; return (2);}	/* larger ] */
	if (c1 == '{' && c2 == '{') {*c = '{'; return (2);}	/* larger { */
	if (c1 == '}' && c2 == '}') {*c = '}'; return (2);}	/* larger } */


	/*
	 *   misc
	 */
	if (c1 == 'd' && c2 == '1') {*c = 0xdb; return (2);}	/* dither 1 */
	if (c1 == 'd' && c2 == '2') {*c = 0xdc; return (2);}	/* dither 2 */


	/*
	 *   unknown, return strange char but advance input string ptr by
	 *   returning 2.
	 */
	*c = 0xde; 
	return (2);
}


#define SKIPWS		for (; *ps && (*ps == ' ' || *ps == '\t'); ps++)
#define SKIPWORD	for (; *ps && (*ps != ' ' && *ps != '\t'); ps++)
#define SKIPCOMMENT	if (*ps == '\0' || *ps == '\n' || *ps == '#')continue


/*------------------------------*/
/*	readtab			*/
/*------------------------------*/
readtab (stream)
FILE   *stream;
{
	char	lbuf[1024];
	char   *ps;
	char	c1,
		c2;
	int	i;

	while (1)
	{
		/*
		 *   get a line
		 */
		fgets (lbuf, 1023, stream);
		if (feof (stream))
			break;

		/*
		 *   skip whitespace, skip blank line or comment
		 */
		ps = lbuf;
		SKIPWS;
		SKIPCOMMENT;

		/*
		 *   look for keyword...
		 */
		switch (mchkw (ps))
		{
		case KW_CHARSET:
			/*
			 *   normal char set definition
			 */
			while (1)
			{
				/*
				 *   get a line
				 */
				fgets (lbuf, 1023, stream);
				if (feof (stream))
					break;
				ps = lbuf;
				SKIPWS;
				SKIPCOMMENT;

				/*
				 *   are we done? look for keywd
				 */
				if (mchkw (ps) >= 0)
					break;
			}
			break;

		case KW_ALTSET:
			/*
			 *   alt char set definition
			 */
			while (1)
			{
				/*
				 *   get a line
				 */
				fgets (lbuf, 1023, stream);
				if (feof (stream))
					break;
				ps = lbuf;
				SKIPWS;
				SKIPCOMMENT;

				/*
				 *   are we done? look for keywd
				 */
				if (mchkw (ps) >= 0)
					break;

				c1 = *ps++;
				c2 = *ps++;
				SKIPWS;
				SKIPWORD;
				SKIPWS;
				ps += 2;	/* skip 0x */
				i   = 0;
				if (*ps >= '0' && *ps <= '9')
					i = *ps - '0';
				else if (*ps >= 'a' && *ps <= 'f')
					i = *ps - 'a' + 10;
				else if (*ps >= 'A' && *ps <= 'F')
					i = *ps - 'A' + 10;
				ps++;
				if (*ps >= '0' && *ps <= '9')
					i = (i * 16) + *ps - '0';
				else if (*ps >= 'a' && *ps <= 'f')
					i = (i * 16) + *ps - 'a' + 10;
				else if (*ps >= 'A' && *ps <= 'F')
					i = (i * 16) + *ps - 'A' + 10;

				altmap[i].e_esc[0] = c1;
				altmap[i].e_esc[1] = c2;
				altmap[i].e_map    = i;
			}
			break;
		case KW_NONE:
			break;
		}
	}
}


/*------------------------------*/
/*	mchkw			*/
/*------------------------------*/
mchkw (ps)
char   *ps;
{
	char   *pkwdlist;
	char   *pkwd;
	int	i;
	char	kwd[20];

	/*
	 *   copy token at ps to kwd
	 */
	pkwd = kwd;
	while (*ps)
	{
		if (*ps == ' ' || *ps == '\t' || *ps == '\n')
			break;

		*pkwd++ = *ps++;
	}
	*pkwd = '\0';

	for (i = 0; ; i++)
	{
		pkwdlist = kwdlist[i];
		if (pkwdlist == NULL_CPTR)
			return (KW_NONE);
		if (!strcmp (kwd, pkwdlist))
			return (i);
	}
	return (KW_NONE);
}
