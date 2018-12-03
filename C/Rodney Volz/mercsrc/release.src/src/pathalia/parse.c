
# line 2 "parse.y"
/* pathalias -- by steve bellovin, as told to peter honeyman */
#ifndef lint
static char	*sccsid = "@(#)parse.y	9.10 88/09/07";
#endif /* lint */

#include "def.h"

/* scanner states (yylex, parse) */
#define OTHER		0
#define COSTING		1
#define NEWLINE		2
#define FILENAME	3

/* exports */
long Tcount;
extern void yyerror();

/* imports */
extern node *addnode(), *addprivate();
extern void fixprivate(), alias(), deadlink(), deletelink();
extern link *addlink();
extern int strcmp();
extern char *strsave();
extern int optind;
extern char *Cfile, *Netchars, **Argv;
extern int Lineno, Argc;

/* privates */
STATIC void fixnet(), adjust();
STATIC int yylex(), yywrap(), getword();
static int Scanstate = NEWLINE;	/* scanner (yylex) state */

/* flags for ys_flags */
#define TERMINAL 1

# line 38 "parse.y"
typedef union  {
	node	*y_node;
	Cost	y_cost;
	char	y_net;
	char	*y_name;
	struct {
		node *ys_node;
		Cost ys_cost;
		short ys_flag;
		char ys_net;
		char ys_dir;
	} y_s;
} YYSTYPE;
# define SITE 257
# define HOST 258
# define STRING 259
# define COST 260
# define NET 261
# define EOL 262
# define PRIVATE 263
# define DEAD 264
# define DELETE 265
# define FILETOK 266
# define ADJUST 267
#define yyclearin yychar = -1
#define yyerrok yyerrflag = 0
extern int yychar;
extern int yyerrflag;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
YYSTYPE yylval, yyval;
typedef int yytabelem;
# define YYERRCODE 256

# line 234 "parse.y"


void
#ifdef YYDEBUG
/*VARARGS1*/
yyerror(fmt, arg)
	char *fmt, *arg;
#else
yyerror(s)
	char *s;
#endif
{
	/* a concession to bsd error(1) */
	fprintf(stderr, "\"%s\", ", Cfile);
#ifdef YYDEBUG
	fprintf(stderr, "line %d: ", Lineno);
	fprintf(stderr, fmt, arg);
	putc('\n', stderr);
#else
	fprintf(stderr, "line %d: %s\n", Lineno, s);
#endif
}

/*
 * patch in the costs of getting on/off the network.
 *
 * for each network member on netlist, add links:
 *	network -> member	cost = 0;
 *	member -> network	cost = parameter.
 *
 * if network and member both require gateways, assume network
 * is a gateway to member (but not v.v., to avoid such travesties
 * as topaz!seismo.css.gov.edu.rutgers).
 *
 * note that members can have varying costs to a network, by suitable
 * multiple declarations.  this is a feechur, albeit a useless one.
 */
STATIC void
fixnet(network, nlist, cost, netchar, netdir)
	register node *network;
	node *nlist;
	Cost cost;
	char netchar, netdir;
{	register node *member, *nextnet;
	link *l;
	static int netanon = 0;
	char anon[25];

	if (network == 0) {
		sprintf(anon, "[unnamed net %d]", netanon++);
		network = addnode(anon);
	}
	network->n_flag |= NNET;

	/* insert the links */
	for (member = nlist ; member; member = nextnet) {

		/* network -> member, cost is 0 */
		l = addlink(network, member, (Cost) 0, netchar, netdir);
		if (GATEWAYED(network) && GATEWAYED(member))
			l->l_flag |= LGATEWAY;

		/* member -> network, cost is parameter */
		/* never ever ever crawl up from a domain*/
		if (!ISADOMAIN(network))
			(void) addlink(member, network, cost, netchar, netdir);

		nextnet = member->n_net;
		member->n_net = 0;	/* clear for later use */
	}
}

/* scanner */

#define QUOTE '"'
#define STR_EQ(s1, s2) (s1[2] == s2[2] && strcmp(s1, s2) == 0)
#define NLRETURN() {Scanstate = NEWLINE; return EOL;}

static struct ctable {
	char *cname;
	Cost cval;
} ctable[] = {
	/* ordered by frequency of appearance in a "typical" dataset */
	{"DIRECT", 200},
	{"DEMAND", 300},
	{"DAILY", 5000},
	{"HOURLY", 500},
	{"DEDICATED", 100},
	{"EVENING", 2000},
	{"LOCAL", 25},
	{"LOW", 5},	/* baud rate, quality penalty */
	{"DEAD", MILLION},
	{"POLLED", 5000},
	{"WEEKLY", 30000},
	{"HIGH", -5},	/* baud rate, quality bonus */
	{"FAST", -80},	/* high speed (>= 9.6 kbps) modem */
	/* deprecated */
	{"ARPA", 100},
	{"DIALED", 300},
	{0, 0}
};

STATIC int
yylex()
{	static char retbuf[128];	/* for return to yacc part */
	register int c;
	register char *buf = retbuf;
	register struct ctable *ct;
	register Cost cost;
	char errbuf[128];

	if (feof(stdin) && yywrap())
		return EOF;

	/* count lines, skip over space and comments */
	if ((c = getchar()) == EOF)
		NLRETURN();
    
continuation:
	while (c == ' ' || c == '\t')
		if ((c = getchar()) == EOF)
			NLRETURN();

	if (c == '#')
		while ((c = getchar()) != '\n')
			if (c == EOF)
				NLRETURN();

	/* scan token */
	if (c == '\n') {
		Lineno++;
		if ((c = getchar()) != EOF) {
			if (c == ' ' || c == '\t')
				goto continuation;
			ungetc(c, stdin);
		}
		NLRETURN();
	}

	switch(Scanstate) {
	case COSTING:
		if (isdigit(c)) {
			cost = c - '0';
			for (c = getchar(); isdigit(c); c = getchar())
				cost = (cost * 10) + c - '0';
			ungetc(c, stdin);
			yylval.y_cost = cost;
			return COST;
		}

		if (getword(buf, c) == 0) {
			for (ct = ctable; ct->cname; ct++)
				if (STR_EQ(buf, ct->cname)) {
					yylval.y_cost = ct->cval;
					return COST;
				}
			sprintf(errbuf, "unknown cost (%s), using default", buf);
			yyerror(errbuf);
			yylval.y_cost = DEFCOST;
			return COST;
		}

		return c;	/* pass the buck */

	case NEWLINE:
		Scanstate = OTHER;
		if (getword(buf, c) != 0)
			return c;
		/*
		 * special purpose tokens.
		 *
		 * the "switch" serves the dual-purpose of recognizing
		 * unquoted tokens only.
		 */
		switch(c) {
		case 'p':
			if (STR_EQ(buf, "private"))
				return PRIVATE;
			break;
		case 'd':
			if (STR_EQ(buf, "dead"))
				return DEAD;
			if (STR_EQ(buf, "delete"))
				return DELETE;
			break;
		case 'f':
			if (STR_EQ(buf, "file"))
				return FILETOK;
			break;
		case 'a':
			if (STR_EQ(buf, "adjust"))
				return ADJUST;
			break;
		}

		yylval.y_name = buf;
		return HOST;

	case FILENAME:
		while (c != EOF && isprint(c)) {
			if (c == ' ' || c == '\t' || c == '\n' || c == '}')
				break;
			*buf++ = c;
			c = getchar();
		}
		if (c != EOF)
			ungetc(c, stdin);
		*buf = 0;
		yylval.y_name = retbuf;
		return STRING;
	}

	if (getword(buf, c) == 0) {
		yylval.y_name = buf;
		return SITE;
	}

	if (index(Netchars, c)) {
		yylval.y_net = c;
		return NET;
	}

	return c;
}

/*
 * fill str with the next word in [0-9A-Za-z][-._0-9A-Za-z]+ or a quoted
 * string that contains no newline.  return -1 on failure or EOF, 0 o.w.
 */ 
STATIC int
getword(str, c)
	register char *str;
	register int c;
{
	if (c == QUOTE) {
		while ((c = getchar()) != QUOTE) {
			if (c == '\n') {
				yyerror("newline in quoted string\n");
				ungetc(c, stdin);
				return -1;
			}
			if (c == EOF) {
				yyerror("EOF in quoted string\n");
				return -1;
			}
			*str++ = c;
		}
		*str = 0;
		return 0;
	}

	/* host name must start with alphanumeric or `.' */
	if (!isalnum(c) && c != '.')
		return -1;

yymore:
	do {
		*str++ = c;
		c = getchar();
	} while (isalnum(c) || c == '.' || c == '_');

	if (c == '-' && Scanstate != COSTING)
		goto yymore;

	ungetc(c, stdin);
	*str = 0;
	return 0;
}

STATIC int
yywrap()
{	char errbuf[100];

	fixprivate();	/* munge private host definitions */
	Lineno = 1;
	while (optind < Argc) {
		if (freopen((Cfile = Argv[optind++]), "r", stdin) != 0)
			return 0;
		sprintf(errbuf, "%s: %s", Argv[0], Cfile);
		perror(errbuf);
	}
	freopen("/dev/null", "r", stdin);
	return -1;
}

STATIC void
adjust(n, cost)
	node *n;
	Cost cost;
{	link *l;

	n->n_cost += cost;	/* cumulative */

	/* hit existing links */
	for (l = n->n_link; l; l = l->l_next) {
		if ((l->l_cost += cost) < 0) {
			char buf[100];

			l->l_flag |= LDEAD;
			sprintf(buf, "link to %s deleted with negative cost",
							l->l_to->n_name);
			yyerror(buf);
		}
	}
}
yytabelem yyexca[] ={
-1, 0,
	0, 1,
	258, 1,
	262, 1,
	263, 1,
	264, 1,
	265, 1,
	266, 1,
	267, 1,
	61, 1,
	-2, 0,
-1, 1,
	0, -1,
	-2, 0,
-1, 61,
	261, 48,
	-2, 46,
-1, 65,
	261, 48,
	-2, 53,
	};
# define YYNPROD 74
# define YYLAST 226
yytabelem yyact[]={

    20,    25,    23,    93,    48,    38,    31,    30,    92,    29,
    37,    33,    37,    28,    27,    26,    21,    85,    82,    50,
    86,    57,    71,    65,    61,    37,    98,    96,    54,    52,
    49,    46,     2,    76,    88,    84,    81,    79,    76,   114,
    55,    44,    43,    42,    41,    40,    62,    90,    69,    47,
    74,    64,    60,    53,   120,   108,   106,   115,   107,    32,
   109,   108,   106,   108,   107,    48,   109,    34,   109,   105,
    73,    68,   103,    67,    63,    11,    10,     9,     8,     7,
     1,    59,    13,    45,    12,     6,    56,     5,     4,    66,
     0,    70,     0,     0,     0,    72,     0,     0,     0,     0,
     0,     0,     0,    51,     0,     0,     0,     0,     0,    77,
     0,     0,     0,     0,    97,    87,    83,    80,    78,    75,
    89,     0,     0,     0,     0,    94,     0,     0,     0,   100,
     0,    66,   102,     0,    99,    70,   101,   104,     0,     0,
   110,   111,     0,    39,     0,   112,     0,   113,     0,     0,
     0,     0,     0,    58,   116,   117,   118,   119,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,    19,     0,     0,
     0,     3,    14,    15,    16,    17,    18,    36,     0,    36,
     0,    35,     0,    35,     0,     0,     0,     0,     0,    24,
    22,     0,    36,    91,     0,    95 };
yytabelem yypact[]={

  -224,   -61,  -246, -1000,   -42,   -43,  -247,  -248,  -249,  -253,
  -255,  -256,   -50,  -118,   -78,   -79,   -80,   -81,   -82, -1000,
 -1000, -1000, -1000,   -48, -1000,  -226, -1000, -1000, -1000, -1000,
 -1000, -1000,    25,  -227,  -242,   -35, -1000,  -228,  -229,   -83,
  -104,  -233,  -234, -1000,  -235,    25, -1000, -1000, -1000, -1000,
 -1000, -1000,   -12,    -6, -1000,  -229,    -7, -1000, -1000,    -8,
 -1000, -1000,  -243,    -9, -1000, -1000,  -244,  -239,   -10, -1000,
    25, -1000, -1000,   -37, -1000,   -36,  -230,   -11, -1000,  -231,
 -1000,  -233,  -235, -1000,  -234,  -235, -1000, -1000,  -235, -1000,
    19, -1000,   -37,   -37, -1000,    25, -1000,    25, -1000, -1000,
 -1000, -1000, -1000,   -86, -1000,    16,   -37,   -37,   -37,   -37,
    21,    13, -1000, -1000, -1000, -1000,    21,    21, -1000, -1000,
 -1000 };
yytabelem yypgo[]={

     0,    59,    67,    88,    87,    86,    85,    53,    84,    82,
    46,    52,    81,    49,    47,    80,    79,    78,    77,    76,
    75,    74,    51,    73,    72,    71,    48,    70,    69 };
yytabelem yyr1[]={

     0,    15,    15,    15,    15,    15,    15,    15,    15,    15,
    15,    15,     3,     3,     3,     8,     8,     8,     8,     8,
     8,     1,     1,     1,     2,     2,     4,     4,     4,     6,
     6,     6,     9,     9,     7,     7,     7,    16,    16,     5,
     5,     5,    17,    12,    12,    12,    11,    11,    10,    18,
    21,    21,    21,    22,    22,    23,    24,    19,    20,    25,
    25,    25,    26,    13,    27,    28,    13,    14,    14,    14,
    14,    14,    14,    14 };
yytabelem yyr2[]={

     0,     0,     4,     6,     6,     6,     6,     6,     6,     6,
     6,     4,     7,     9,     4,     3,     3,     3,     3,     3,
     3,     3,     5,     5,     3,     7,     7,     7,     4,    11,
    13,    13,     3,     5,     3,     7,     4,     8,     7,     3,
     7,     4,     8,     2,     6,     4,     3,     7,     3,     8,
     2,     6,     4,     3,     7,     1,     1,    13,     8,     2,
     6,     4,     5,     1,     1,     1,    11,     2,     5,     7,
     7,     7,     7,     7 };
yytabelem yychk[]={

 -1000,   -15,   256,   262,    -3,    -4,    -6,   -16,   -17,   -18,
   -19,   -20,    -8,    -9,   263,   264,   265,   266,   267,   258,
    61,   262,   262,    44,   262,    44,   262,   262,   262,   262,
   262,   262,    -1,    61,    -2,   261,   257,    60,   123,   261,
   123,   123,   123,   123,   123,    -1,   257,   -13,    40,   257,
   261,    -2,   257,    -7,   257,   123,    -5,   125,   257,   -12,
   -11,   257,   -10,   -21,   -22,   257,   -10,   -23,   -25,   -26,
   -10,   257,   -13,   -27,    62,   125,    44,    -7,   125,    44,
   125,    44,   261,   125,    44,   261,   259,   125,    44,   -13,
   -14,   260,    45,    40,   -13,   261,   257,   125,   257,   -11,
   -10,   -22,   -10,   -24,   -26,   -28,    43,    45,    42,    47,
   -14,   -14,   -13,   -13,   125,    41,   -14,   -14,   -14,   -14,
    41 };
yytabelem yydef[]={

    -2,    -2,     0,     2,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,    16,    17,    18,    19,    20,    15,
    32,    11,     3,    14,     4,    28,     5,     6,     7,     8,
     9,    10,    63,    33,    21,     0,    24,     0,     0,     0,
     0,     0,     0,    55,     0,    63,    27,    12,    64,    26,
    23,    22,     0,     0,    34,     0,     0,    38,    39,     0,
    43,    -2,     0,     0,    50,    -2,     0,     0,     0,    59,
    63,    48,    13,     0,    25,    63,    36,     0,    37,    41,
    42,    45,     0,    49,    52,     0,    56,    58,    61,    62,
    65,    67,     0,     0,    29,    63,    35,    63,    40,    44,
    47,    51,    54,     0,    60,     0,     0,     0,     0,     0,
    68,     0,    31,    30,    57,    66,    70,    71,    72,    73,
    69 };
typedef struct { char *t_name; int t_val; } yytoktype;
#ifndef YYDEBUG
#	define YYDEBUG	0	/* don't allow debugging */
#endif

#if YYDEBUG

yytoktype yytoks[] =
{
	"SITE",	257,
	"HOST",	258,
	"STRING",	259,
	"COST",	260,
	"NET",	261,
	"EOL",	262,
	"PRIVATE",	263,
	"DEAD",	264,
	"DELETE",	265,
	"FILETOK",	266,
	"ADJUST",	267,
	"+",	43,
	"-",	45,
	"*",	42,
	"/",	47,
	"-unknown-",	-1	/* ends search */
};

char * yyreds[] =
{
	"-no such reduction-",
	"map : /* empty */",
	"map : map EOL",
	"map : map links EOL",
	"map : map aliases EOL",
	"map : map network EOL",
	"map : map private EOL",
	"map : map dead EOL",
	"map : map delete EOL",
	"map : map file EOL",
	"map : map adjust EOL",
	"map : error EOL",
	"links : host site cost",
	"links : links ',' site cost",
	"links : links ','",
	"host : HOST",
	"host : PRIVATE",
	"host : DEAD",
	"host : DELETE",
	"host : FILETOK",
	"host : ADJUST",
	"site : asite",
	"site : NET asite",
	"site : asite NET",
	"asite : SITE",
	"asite : '<' SITE '>'",
	"aliases : host '=' SITE",
	"aliases : aliases ',' SITE",
	"aliases : aliases ','",
	"network : nhost '{' nlist '}' cost",
	"network : nhost NET '{' nlist '}' cost",
	"network : nhost '{' nlist '}' NET cost",
	"nhost : '='",
	"nhost : host '='",
	"nlist : SITE",
	"nlist : nlist ',' SITE",
	"nlist : nlist ','",
	"private : PRIVATE '{' plist '}'",
	"private : PRIVATE '{' '}'",
	"plist : SITE",
	"plist : plist ',' SITE",
	"plist : plist ','",
	"dead : DEAD '{' dlist '}'",
	"dlist : delem",
	"dlist : dlist ',' delem",
	"dlist : dlist ','",
	"delem : SITE",
	"delem : usite NET usite",
	"usite : SITE",
	"delete : DELETE '{' dellist '}'",
	"dellist : delelem",
	"dellist : dellist ',' delelem",
	"dellist : dellist ','",
	"delelem : SITE",
	"delelem : usite NET usite",
	"file : FILETOK '{'",
	"file : FILETOK '{' STRING",
	"file : FILETOK '{' STRING '}'",
	"adjust : ADJUST '{' adjlist '}'",
	"adjlist : adjelem",
	"adjlist : adjlist ',' adjelem",
	"adjlist : adjlist ','",
	"adjelem : usite cost",
	"cost : /* empty */",
	"cost : '('",
	"cost : '(' cexpr",
	"cost : '(' cexpr ')'",
	"cexpr : COST",
	"cexpr : '-' cexpr",
	"cexpr : '(' cexpr ')'",
	"cexpr : cexpr '+' cexpr",
	"cexpr : cexpr '-' cexpr",
	"cexpr : cexpr '*' cexpr",
	"cexpr : cexpr '/' cexpr",
};
#endif /* YYDEBUG */


/*
** Skeleton parser driver for yacc output
*/

/*
** yacc user known macros and defines
*/
#define YYERROR		goto yyerrlab
#define YYACCEPT	return(0)
#define YYABORT		return(1)
#define YYBACKUP( newtoken, newvalue )\
{\
	if ( yychar >= 0 || ( yyr2[ yytmp ] >> 1 ) != 1 )\
	{\
		yyerror( "syntax error - cannot backup" );\
		goto yyerrlab;\
	}\
	yychar = newtoken;\
	yystate = *yyps;\
	yylval = newvalue;\
	goto yynewstate;\
}
#define YYRECOVERING()	(!!yyerrflag)
#ifndef YYDEBUG
#	define YYDEBUG	1	/* make debugging available */
#endif

/*
** user known globals
*/
int yydebug;			/* set to 1 to get debugging */

/*
** driver internal defines
*/
#define YYFLAG		(-1000)

/*
** global variables used by the parser
*/
YYSTYPE yyv[ YYMAXDEPTH ];	/* value stack */
int yys[ YYMAXDEPTH ];		/* state stack */

YYSTYPE *yypv;			/* top of value stack */
int *yyps;			/* top of state stack */

int yystate;			/* current state */
int yytmp;			/* extra var (lasts between blocks) */

int yynerrs;			/* number of errors */
int yyerrflag;			/* error recovery flag */
int yychar;			/* current input token number */



/*
** yyparse - return 0 if worked, 1 if syntax error not recovered from
*/
int
yyparse()
{
	register YYSTYPE *yypvt;	/* top of value stack for $vars */

	/*
	** Initialize externals - yyparse may be called more than once
	*/
	yypv = &yyv[-1];
	yyps = &yys[-1];
	yystate = 0;
	yytmp = 0;
	yynerrs = 0;
	yyerrflag = 0;
	yychar = -1;

	goto yystack;
	{
		register YYSTYPE *yy_pv;	/* top of value stack */
		register int *yy_ps;		/* top of state stack */
		register int yy_state;		/* current state */
		register int  yy_n;		/* internal state number info */

		/*
		** get globals into registers.
		** branch to here only if YYBACKUP was called.
		*/
	yynewstate:
		yy_pv = yypv;
		yy_ps = yyps;
		yy_state = yystate;
		goto yy_newstate;

		/*
		** get globals into registers.
		** either we just started, or we just finished a reduction
		*/
	yystack:
		yy_pv = yypv;
		yy_ps = yyps;
		yy_state = yystate;

		/*
		** top of for (;;) loop while no reductions done
		*/
	yy_stack:
		/*
		** put a state and value onto the stacks
		*/
#if YYDEBUG
		/*
		** if debugging, look up token value in list of value vs.
		** name pairs.  0 and negative (-1) are special values.
		** Note: linear search is used since time is not a real
		** consideration while debugging.
		*/
		if ( yydebug )
		{
			register int yy_i;

			printf( "State %d, token ", yy_state );
			if ( yychar == 0 )
				printf( "end-of-file\n" );
			else if ( yychar < 0 )
				printf( "-none-\n" );
			else
			{
				for ( yy_i = 0; yytoks[yy_i].t_val >= 0;
					yy_i++ )
				{
					if ( yytoks[yy_i].t_val == yychar )
						break;
				}
				printf( "%s\n", yytoks[yy_i].t_name );
			}
		}
#endif /* YYDEBUG */
		if ( ++yy_ps >= &yys[ YYMAXDEPTH ] )	/* room on stack? */
		{
			yyerror( "yacc stack overflow" );
			YYABORT;
		}
		*yy_ps = yy_state;
		*++yy_pv = yyval;

		/*
		** we have a new state - find out what to do
		*/
	yy_newstate:
		if ( ( yy_n = yypact[ yy_state ] ) <= YYFLAG )
			goto yydefault;		/* simple state */
#if YYDEBUG
		/*
		** if debugging, need to mark whether new token grabbed
		*/
		yytmp = yychar < 0;
#endif
		if ( ( yychar < 0 ) && ( ( yychar = yylex() ) < 0 ) )
			yychar = 0;		/* reached EOF */
#if YYDEBUG
		if ( yydebug && yytmp )
		{
			register int yy_i;

			printf( "Received token " );
			if ( yychar == 0 )
				printf( "end-of-file\n" );
			else if ( yychar < 0 )
				printf( "-none-\n" );
			else
			{
				for ( yy_i = 0; yytoks[yy_i].t_val >= 0;
					yy_i++ )
				{
					if ( yytoks[yy_i].t_val == yychar )
						break;
				}
				printf( "%s\n", yytoks[yy_i].t_name );
			}
		}
#endif /* YYDEBUG */
		if ( ( ( yy_n += yychar ) < 0 ) || ( yy_n >= YYLAST ) )
			goto yydefault;
		if ( yychk[ yy_n = yyact[ yy_n ] ] == yychar )	/*valid shift*/
		{
			yychar = -1;
			yyval = yylval;
			yy_state = yy_n;
			if ( yyerrflag > 0 )
				yyerrflag--;
			goto yy_stack;
		}

	yydefault:
		if ( ( yy_n = yydef[ yy_state ] ) == -2 )
		{
#if YYDEBUG
			yytmp = yychar < 0;
#endif
			if ( ( yychar < 0 ) && ( ( yychar = yylex() ) < 0 ) )
				yychar = 0;		/* reached EOF */
#if YYDEBUG
			if ( yydebug && yytmp )
			{
				register int yy_i;

				printf( "Received token " );
				if ( yychar == 0 )
					printf( "end-of-file\n" );
				else if ( yychar < 0 )
					printf( "-none-\n" );
				else
				{
					for ( yy_i = 0;
						yytoks[yy_i].t_val >= 0;
						yy_i++ )
					{
						if ( yytoks[yy_i].t_val
							== yychar )
						{
							break;
						}
					}
					printf( "%s\n", yytoks[yy_i].t_name );
				}
			}
#endif /* YYDEBUG */
			/*
			** look through exception table
			*/
			{
				register int *yyxi = yyexca;

				while ( ( *yyxi != -1 ) ||
					( yyxi[1] != yy_state ) )
				{
					yyxi += 2;
				}
				while ( ( *(yyxi += 2) >= 0 ) &&
					( *yyxi != yychar ) )
					;
				if ( ( yy_n = yyxi[1] ) < 0 )
					YYACCEPT;
			}
		}

		/*
		** check for syntax error
		*/
		if ( yy_n == 0 )	/* have an error */
		{
			/* no worry about speed here! */
			switch ( yyerrflag )
			{
			case 0:		/* new error */
				yyerror( "syntax error" );
				goto skip_init;
			yyerrlab:
				/*
				** get globals into registers.
				** we have a user generated syntax type error
				*/
				yy_pv = yypv;
				yy_ps = yyps;
				yy_state = yystate;
				yynerrs++;
			skip_init:
			case 1:
			case 2:		/* incompletely recovered error */
					/* try again... */
				yyerrflag = 3;
				/*
				** find state where "error" is a legal
				** shift action
				*/
				while ( yy_ps >= yys )
				{
					yy_n = yypact[ *yy_ps ] + YYERRCODE;
					if ( yy_n >= 0 && yy_n < YYLAST &&
						yychk[yyact[yy_n]] == YYERRCODE)					{
						/*
						** simulate shift of "error"
						*/
						yy_state = yyact[ yy_n ];
						goto yy_stack;
					}
					/*
					** current state has no shift on
					** "error", pop stack
					*/
#if YYDEBUG
#	define _POP_ "Error recovery pops state %d, uncovers state %d\n"
					if ( yydebug )
						printf( _POP_, *yy_ps,
							yy_ps[-1] );
#	undef _POP_
#endif
					yy_ps--;
					yy_pv--;
				}
				/*
				** there is no state on stack with "error" as
				** a valid shift.  give up.
				*/
				YYABORT;
			case 3:		/* no shift yet; eat a token */
#if YYDEBUG
				/*
				** if debugging, look up token in list of
				** pairs.  0 and negative shouldn't occur,
				** but since timing doesn't matter when
				** debugging, it doesn't hurt to leave the
				** tests here.
				*/
				if ( yydebug )
				{
					register int yy_i;

					printf( "Error recovery discards " );
					if ( yychar == 0 )
						printf( "token end-of-file\n" );
					else if ( yychar < 0 )
						printf( "token -none-\n" );
					else
					{
						for ( yy_i = 0;
							yytoks[yy_i].t_val >= 0;
							yy_i++ )
						{
							if ( yytoks[yy_i].t_val
								== yychar )
							{
								break;
							}
						}
						printf( "token %s\n",
							yytoks[yy_i].t_name );
					}
				}
#endif /* YYDEBUG */
				if ( yychar == 0 )	/* reached EOF. quit */
					YYABORT;
				yychar = -1;
				goto yy_newstate;
			}
		}/* end if ( yy_n == 0 ) */
		/*
		** reduction by production yy_n
		** put stack tops, etc. so things right after switch
		*/
#if YYDEBUG
		/*
		** if debugging, print the string that is the user's
		** specification of the reduction which is just about
		** to be done.
		*/
		if ( yydebug )
			printf( "Reduce by (%d) \"%s\"\n",
				yy_n, yyreds[ yy_n ] );
#endif
		yytmp = yy_n;			/* value to switch over */
		yypvt = yy_pv;			/* $vars top of value stack */
		/*
		** Look in goto table for next state
		** Sorry about using yy_state here as temporary
		** register variable, but why not, if it works...
		** If yyr2[ yy_n ] doesn't have the low order bit
		** set, then there is no action to be done for
		** this reduction.  So, no saving & unsaving of
		** registers done.  The only difference between the
		** code just after the if and the body of the if is
		** the goto yy_stack in the body.  This way the test
		** can be made before the choice of what to do is needed.
		*/
		{
			/* length of production doubled with extra bit */
			register int yy_len = yyr2[ yy_n ];

			if ( !( yy_len & 01 ) )
			{
				yy_len >>= 1;
				yyval = ( yy_pv -= yy_len )[1];	/* $$ = $1 */
				yy_state = yypgo[ yy_n = yyr1[ yy_n ] ] +
					*( yy_ps -= yy_len ) + 1;
				if ( yy_state >= YYLAST ||
					yychk[ yy_state =
					yyact[ yy_state ] ] != -yy_n )
				{
					yy_state = yyact[ yypgo[ yy_n ] ];
				}
				goto yy_stack;
			}
			yy_len >>= 1;
			yyval = ( yy_pv -= yy_len )[1];	/* $$ = $1 */
			yy_state = yypgo[ yy_n = yyr1[ yy_n ] ] +
				*( yy_ps -= yy_len ) + 1;
			if ( yy_state >= YYLAST ||
				yychk[ yy_state = yyact[ yy_state ] ] != -yy_n )
			{
				yy_state = yyact[ yypgo[ yy_n ] ];
			}
		}
					/* save until reenter driver code */
		yystate = yy_state;
		yyps = yy_ps;
		yypv = yy_pv;
	}
	/*
	** code supplied by user is placed in this switch
	*/
	switch( yytmp )
	{
		
case 12:
# line 79 "parse.y"
{
		struct link *l;

		l = addlink(yypvt[-2].y_node, yypvt[-1].y_s.ys_node, yypvt[-0].y_cost, yypvt[-1].y_s.ys_net, yypvt[-1].y_s.ys_dir);
		if (GATEWAYED(yypvt[-1].y_s.ys_node))
			l->l_flag |= LGATEWAY;
		if (yypvt[-1].y_s.ys_flag & TERMINAL)
			l->l_flag |= LTERMINAL;
	  } break;
case 13:
# line 88 "parse.y"
{
		struct link *l;

		l = addlink(yypvt[-3].y_node, yypvt[-1].y_s.ys_node, yypvt[-0].y_cost, yypvt[-1].y_s.ys_net, yypvt[-1].y_s.ys_dir);
		if (GATEWAYED(yypvt[-1].y_s.ys_node))
			l->l_flag |= LGATEWAY;
		if (yypvt[-1].y_s.ys_flag & TERMINAL)
			l->l_flag |= LTERMINAL;
	  } break;
case 15:
# line 100 "parse.y"
{yyval.y_node = addnode(yypvt[-0].y_name);} break;
case 16:
# line 101 "parse.y"
{yyval.y_node = addnode("private");} break;
case 17:
# line 102 "parse.y"
{yyval.y_node = addnode("dead");} break;
case 18:
# line 103 "parse.y"
{yyval.y_node = addnode("delete");} break;
case 19:
# line 104 "parse.y"
{yyval.y_node = addnode("file");} break;
case 20:
# line 105 "parse.y"
{yyval.y_node = addnode("adjust");} break;
case 21:
# line 108 "parse.y"
{
		yyval.y_s = yypvt[-0].y_s;
		yyval.y_s.ys_net = DEFNET;
		yyval.y_s.ys_dir = DEFDIR;
	  } break;
case 22:
# line 113 "parse.y"
{
		yyval.y_s = yypvt[-0].y_s;
		yyval.y_s.ys_net = yypvt[-1].y_net;
		yyval.y_s.ys_dir = LRIGHT;
	  } break;
case 23:
# line 118 "parse.y"
{
		yyval.y_s = yypvt[-1].y_s;
		yyval.y_s.ys_net = yypvt[-0].y_net;
		yyval.y_s.ys_dir = LLEFT;
	  } break;
case 24:
# line 125 "parse.y"
{
		yyval.y_s.ys_node = addnode(yypvt[-0].y_name);
		yyval.y_s.ys_flag = 0;
	  } break;
case 25:
# line 129 "parse.y"
{
		Tcount++;
		yyval.y_s.ys_node = addnode(yypvt[-1].y_name);
		yyval.y_s.ys_flag = TERMINAL;
	  } break;
case 26:
# line 136 "parse.y"
{alias(yypvt[-2].y_node, addnode(yypvt[-0].y_name));} break;
case 27:
# line 137 "parse.y"
{alias(yypvt[-2].y_node, addnode(yypvt[-0].y_name));} break;
case 29:
# line 141 "parse.y"
{fixnet(yypvt[-4].y_node, yypvt[-2].y_node, yypvt[-0].y_cost, DEFNET, DEFDIR);} break;
case 30:
# line 142 "parse.y"
{fixnet(yypvt[-5].y_node, yypvt[-2].y_node, yypvt[-0].y_cost, yypvt[-4].y_net, LRIGHT);} break;
case 31:
# line 143 "parse.y"
{fixnet(yypvt[-5].y_node, yypvt[-3].y_node, yypvt[-0].y_cost, yypvt[-1].y_net, LLEFT);} break;
case 32:
# line 146 "parse.y"
{yyval.y_node = 0;	/* anonymous net */} break;
case 33:
# line 147 "parse.y"
{yyval.y_node = yypvt[-1].y_node;	/* named net */} break;
case 34:
# line 150 "parse.y"
{yyval.y_node = addnode(yypvt[-0].y_name);} break;
case 35:
# line 151 "parse.y"
{
		node *n;

		n = addnode(yypvt[-0].y_name);
		if (n->n_net == 0) {
			n->n_net = yypvt[-2].y_node;
			yyval.y_node = n;
		}
	  } break;
case 38:
# line 164 "parse.y"
{fixprivate();} break;
case 39:
# line 167 "parse.y"
{addprivate(yypvt[-0].y_name)->n_flag |= ISPRIVATE;} break;
case 40:
# line 168 "parse.y"
{addprivate(yypvt[-0].y_name)->n_flag |= ISPRIVATE;} break;
case 46:
# line 179 "parse.y"
{deadlink(addnode(yypvt[-0].y_name), (node *) 0);} break;
case 47:
# line 180 "parse.y"
{deadlink(yypvt[-2].y_node, yypvt[-0].y_node);} break;
case 48:
# line 183 "parse.y"
{yyval.y_node = addnode(yypvt[-0].y_name);} break;
case 53:
# line 192 "parse.y"
{
		node *n;

		n = addnode(yypvt[-0].y_name);
		deletelink(n, (node *) 0);
		n->n_flag |= ISPRIVATE;
	  } break;
case 54:
# line 199 "parse.y"
{deletelink(yypvt[-2].y_node, yypvt[-0].y_node);} break;
case 55:
# line 202 "parse.y"
{Scanstate = FILENAME;} break;
case 56:
# line 202 "parse.y"
{Scanstate = OTHER;} break;
case 57:
# line 202 "parse.y"
{
		Lineno = 0;
		Cfile = strsave(yypvt[-2].y_name);
	} break;
case 62:
# line 214 "parse.y"
{adjust(yypvt[-1].y_node, yypvt[-0].y_cost);} break;
case 63:
# line 216 "parse.y"
{yyval.y_cost = DEFCOST;	/* empty -- cost is always optional */} break;
case 64:
# line 217 "parse.y"
{Scanstate = COSTING;} break;
case 65:
# line 217 "parse.y"
{Scanstate = OTHER;} break;
case 66:
# line 218 "parse.y"
{yyval.y_cost = yypvt[-2].y_cost;} break;
case 68:
# line 222 "parse.y"
{yyval.y_cost = -yypvt[-0].y_cost;} break;
case 69:
# line 223 "parse.y"
{yyval.y_cost = yypvt[-1].y_cost;} break;
case 70:
# line 224 "parse.y"
{yyval.y_cost = yypvt[-2].y_cost + yypvt[-0].y_cost;} break;
case 71:
# line 225 "parse.y"
{yyval.y_cost = yypvt[-2].y_cost - yypvt[-0].y_cost;} break;
case 72:
# line 226 "parse.y"
{yyval.y_cost = yypvt[-2].y_cost * yypvt[-0].y_cost;} break;
case 73:
# line 227 "parse.y"
{
		if (yypvt[-0].y_cost == 0)
			yyerror("zero divisor\n");
		else
			yyval.y_cost = yypvt[-2].y_cost / yypvt[-0].y_cost;
	  } break;
	}
	goto yystack;		/* reset registers in driver code */
}
