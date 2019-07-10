#ifndef lint
char yysccsid[] = "@(#)yaccpar	1.4 (Berkeley) 02/25/90";
#endif
#line 2 "parse.y"
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
int Donelast = 0;	/* we're all out of files to parse */

/* flags for ys_flags */
#define TERMINAL 1
#line 39 "parse.y"
typedef union {
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
#line 55 "y_tab.c"
#define SITE 257
#define HOST 258
#define STRING 259
#define COST 260
#define NET 261
#define EOL 262
#define PRIVATE 263
#define DEAD 264
#define DELETE 265
#define FILETOK 266
#define ADJUST 267
#define YYERRCODE 256
short yylhs[] = {                                        -1,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    3,    3,    3,    8,    8,    8,    8,    8,    8,
    1,    1,    1,    2,    2,    4,    4,    4,    6,    6,
    6,    9,    9,    7,    7,    7,   15,   15,    5,    5,
    5,   16,   12,   12,   12,   11,   11,   10,   17,   20,
   20,   20,   21,   21,   22,   23,   18,   19,   24,   24,
   24,   25,   13,   26,   27,   13,   14,   14,   14,   14,
   14,   14,   14,
};
short yylen[] = {                                         2,
    0,    2,    3,    3,    3,    3,    3,    3,    3,    3,
    2,    3,    4,    2,    1,    1,    1,    1,    1,    1,
    1,    2,    2,    1,    3,    3,    3,    2,    5,    6,
    6,    1,    2,    1,    3,    2,    4,    3,    1,    3,
    2,    4,    1,    3,    2,    1,    3,    1,    4,    1,
    3,    2,    1,    3,    0,    0,    6,    4,    1,    3,
    2,    2,    0,    0,    0,    5,    1,    2,    3,    3,
    3,    3,    3,
};
short yydefred[] = {                                      0,
    0,    0,   11,   15,    2,    0,    0,    0,    0,    0,
   32,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,   55,    0,    3,    0,    4,    0,
    5,   24,    0,    0,    0,    0,    0,    0,    0,    6,
    7,    8,    9,   10,   39,   38,    0,    0,    0,   43,
    0,    0,    0,    0,   50,    0,   48,    0,    0,   59,
    0,   27,   22,    0,   26,   64,   12,   23,    0,   34,
    0,    0,   37,    0,    0,   42,    0,    0,   49,   56,
   62,    0,   58,   13,   25,    0,    0,    0,    0,   40,
   47,   44,   54,   51,    0,   60,   67,    0,    0,    0,
    0,   35,    0,   29,   57,    0,    0,    0,    0,    0,
    0,    0,   30,   31,   69,    0,    0,   72,   73,   66,
};
short yydgoto[] = {                                       2,
   36,   37,   12,   13,   47,   14,   71,   15,   16,   49,
   50,   51,   67,  100,   17,   18,   19,   20,   21,   54,
   55,   56,   95,   59,   60,   86,  112,
};
short yysindex[] = {                                   -234,
 -237,  -55,    0,    0,    0,  -96,  -93,  -78,  -74,  -72,
    0,  -41,  -36, -204,  -44, -109, -202, -178, -177, -176,
 -175, -104, -168, -167,    0, -166,    0,  -14,    0, -165,
    0,    0,  -51, -164, -163,   59, -161,   -5, -154,    0,
    0,    0,    0,    0,    0,    0,  -21,    0, -153,    0,
  -20,    0, -150,  -18,    0, -142,    0,   59,  -16,    0,
   59,    0,    0,   57,    0,    0,    0,    0, -154,    0,
  -15, -137,    0, -166, -168,    0, -166, -167,    0,    0,
    0, -166,    0,    0,    0,  -35,  -13, -135,  -38,    0,
    0,    0,    0,    0,   -2,    0,    0,  -35,  -35,   14,
   59,    0,   59,    0,    0,   28,   26,  -35,  -35,  -35,
  -35,   83,    0,    0,    0,   28,   28,    0,    0,    0,
};
short yyrindex[] = {                                      1,
    0,    0,    0,    0,    0,  -42,  -24,  -22,  -19,  -17,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,  -33,    0,  -32,
    0,    0,    0,    0, -103,  -31,  -40,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,  -37,    0,    0,
    0,  -29,    0,    0,    0,    0,    0,  -12,    0,    0,
  -31,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,  -11,    0,    0,  -10,    0,    0,   -9,    0,    0,
    0,   -4,    0,    0,    0,    0,    0,    3, -136,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,   84,
 -136,    0, -136,    0,    0,   31,    0,    0,    0,    0,
    0,    0,    0,    0,    0,   36,   37,    0,    0,    0,
};
short yygindex[] = {                                      0,
   99,   96,    0,    0,    0,    0,   61,    0,    0,   24,
   56,    0,   -6,  -45,    0,    0,    0,    0,    0,    0,
   54,    0,    0,    0,   51,    0,    0,
};
#define YYTABLESIZE 268
short yytable[] = {                                      21,
    1,   66,   28,   21,   99,   11,   46,   30,   34,   98,
   14,   28,   63,   39,   53,   34,   35,   16,   16,   33,
   46,    1,   72,   75,    3,   78,   22,   82,   88,   23,
   88,   63,   41,   45,   52,   17,   17,   18,   18,   61,
   19,   19,   20,   20,   24,   34,   36,   53,   25,   58,
   26,   81,  106,  107,   84,  110,  108,   31,  109,   40,
  111,    1,  116,  117,  118,  119,  115,  110,  108,  110,
  109,   68,  111,   68,  111,   68,   70,   71,   70,   71,
   70,   71,  104,   41,   42,   43,   44,   46,   48,   52,
   57,   62,   64,   65,  113,   53,  114,   91,   66,   68,
   93,   53,   70,   73,   76,   58,   79,   74,   83,   89,
   77,  101,   63,   41,   45,   52,   80,   69,   85,   90,
   61,  102,  105,  120,   65,   63,   61,   36,   63,   87,
   92,   94,   96,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,   38,   45,    0,    0,    0,    0,   33,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    0,    0,
    0,    0,    4,    0,    0,   32,    5,    6,    7,    8,
    9,   10,   32,    0,   16,    0,   33,    0,   16,    0,
   27,   21,  103,   48,   97,   29,    0,    0,   14,   28,
   63,   48,   17,    0,   18,    0,   17,   19,   18,   20,
    0,   19,   32,   20,    0,    0,   33,    0,    0,    0,
    0,    0,    0,    0,    0,    0,    0,    0,    1,    0,
    0,    0,    1,    1,    1,    1,    1,    1,
};
short yycheck[] = {                                      40,
    0,   40,   44,   44,   40,   61,   44,   44,   60,   45,
   44,   44,   44,  123,   44,   60,   61,   60,   61,  123,
  125,  256,   44,   44,  262,   44,  123,   44,   44,  123,
   44,   44,   44,   44,   44,   60,   61,   60,   61,   44,
   60,   61,   60,   61,  123,   60,   44,   24,  123,   26,
  123,   58,   98,   99,   61,   42,   43,  262,   45,  262,
   47,   61,  108,  109,  110,  111,   41,   42,   43,   42,
   45,   41,   47,   43,   47,   45,   41,   41,   43,   43,
   45,   45,   89,  262,  262,  262,  262,  125,  257,  257,
  257,  257,  257,  257,  101,  125,  103,   74,   40,  261,
   77,   78,  257,  125,  125,   82,  125,  261,  125,  125,
  261,  125,  125,  125,  125,  125,  259,  123,   62,  257,
  125,  257,  125,   41,   41,  262,   28,  125,   33,   69,
   75,   78,   82,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,  261,  257,   -1,   -1,   -1,   -1,  261,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,
   -1,   -1,  258,   -1,   -1,  257,  262,  263,  264,  265,
  266,  267,  257,   -1,  257,   -1,  261,   -1,  261,   -1,
  262,  262,  261,  261,  260,  262,   -1,   -1,  262,  262,
  262,  261,  257,   -1,  257,   -1,  261,  257,  261,  257,
   -1,  261,  257,  261,   -1,   -1,  261,   -1,   -1,   -1,
   -1,   -1,   -1,   -1,   -1,   -1,   -1,   -1,  258,   -1,
   -1,   -1,  262,  263,  264,  265,  266,  267,
};
#define YYFINAL 2
#ifndef YYDEBUG
#define YYDEBUG 0
#endif
#define YYMAXTOKEN 267
#if YYDEBUG
char *yyname[] = {
"end-of-file",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,"'('","')'","'*'","'+'","','","'-'",0,"'/'",0,0,0,0,0,0,0,0,0,0,0,0,
"'<'","'='","'>'",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"'{'",0,"'}'",0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,"SITE","HOST","STRING","COST","NET","EOL","PRIVATE","DEAD",
"DELETE","FILETOK","ADJUST",
};
char *yyrule[] = {
"$accept : map",
"map :",
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
"$$1 :",
"$$2 :",
"file : FILETOK '{' $$1 STRING $$2 '}'",
"adjust : ADJUST '{' adjlist '}'",
"adjlist : adjelem",
"adjlist : adjlist ',' adjelem",
"adjlist : adjlist ','",
"adjelem : usite cost",
"cost :",
"$$3 :",
"$$4 :",
"cost : '(' $$3 cexpr $$4 ')'",
"cexpr : COST",
"cexpr : '-' cexpr",
"cexpr : '(' cexpr ')'",
"cexpr : cexpr '+' cexpr",
"cexpr : cexpr '-' cexpr",
"cexpr : cexpr '*' cexpr",
"cexpr : cexpr '/' cexpr",
};
#endif
#define yyclearin (yychar=(-1))
#define yyerrok (yyerrflag=0)
#ifndef YYSTACKSIZE
#ifdef YYMAXDEPTH
#define YYSTACKSIZE YYMAXDEPTH
#else
#define YYSTACKSIZE 300
#endif
#endif
int yydebug;
int yynerrs;
int yyerrflag;
int yychar;
short *yyssp;
YYSTYPE *yyvsp;
YYSTYPE yyval;
YYSTYPE yylval;
#define yystacksize YYSTACKSIZE
short yyss[YYSTACKSIZE];
YYSTYPE yyvs[YYSTACKSIZE];
#line 236 "parse.y"

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
	
	if( Donelast == -1 && yywrap() )
		return EOF;

	if (Donelast || feof(stdin) && yywrap())
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
	Donelast = 0;		/* we're not at the end of the list */
	while (optind < Argc) {
		if (freopen((Cfile = Argv[optind++]), "r", stdin) != 0)
			return 0;
		sprintf(errbuf, "%s: %s", Argv[0], Cfile);
		perror(errbuf);
	}
	/* freopen(NULL_FILE, "r", stdin); */
	Donelast=1;	/* so maybe we are, sue me */
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
#line 623 "y_tab.c"
#define YYABORT goto yyabort
#define YYACCEPT goto yyaccept
#define YYERROR goto yyerrlab
int
yyparse()
{
    register int yym, yyn, yystate;
#if YYDEBUG
    register char *yys;
    extern char *getenv();

    if (yys = getenv("YYDEBUG"))
    {
        yyn = *yys;
        if (yyn >= '0' && yyn <= '9')
            yydebug = yyn - '0';
    }
#endif

    yynerrs = 0;
    yyerrflag = 0;
    yychar = (-1);

    yyssp = yyss;
    yyvsp = yyvs;
    *yyssp = yystate = 0;

yyloop:
    if (yyn = yydefred[yystate]) goto yyreduce;
    if (yychar < 0)
    {
        if ((yychar = yylex()) < 0) yychar = 0;
#if YYDEBUG
        if (yydebug)
        {
            yys = 0;
            if (yychar <= YYMAXTOKEN) yys = yyname[yychar];
            if (!yys) yys = "illegal-symbol";
            printf("yydebug: state %d, reading %d (%s)\n", yystate,
                    yychar, yys);
        }
#endif
    }
    if ((yyn = yysindex[yystate]) && (yyn += yychar) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yychar)
    {
#if YYDEBUG
        if (yydebug)
            printf("yydebug: state %d, shifting to state %d\n",
                    yystate, yytable[yyn]);
#endif
        if (yyssp >= yyss + yystacksize - 1)
        {
            goto yyoverflow;
        }
        *++yyssp = yystate = yytable[yyn];
        *++yyvsp = yylval;
        yychar = (-1);
        if (yyerrflag > 0)  --yyerrflag;
        goto yyloop;
    }
    if ((yyn = yyrindex[yystate]) && (yyn += yychar) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yychar)
    {
        yyn = yytable[yyn];
        goto yyreduce;
    }
    if (yyerrflag) goto yyinrecovery;
#ifdef lint
    goto yynewerror;
#endif
yynewerror:
    yyerror("syntax error");
#ifdef lint
    goto yyerrlab;
#endif
yyerrlab:
    ++yynerrs;
yyinrecovery:
    if (yyerrflag < 3)
    {
        yyerrflag = 3;
        for (;;)
        {
            if ((yyn = yysindex[*yyssp]) && (yyn += YYERRCODE) >= 0 &&
                    yyn <= YYTABLESIZE && yycheck[yyn] == YYERRCODE)
            {
#if YYDEBUG
                if (yydebug)
                    printf("yydebug: state %d, error recovery shifting\
 to state %d\n", *yyssp, yytable[yyn]);
#endif
                if (yyssp >= yyss + yystacksize - 1)
                {
                    goto yyoverflow;
                }
                *++yyssp = yystate = yytable[yyn];
                *++yyvsp = yylval;
                goto yyloop;
            }
            else
            {
#if YYDEBUG
                if (yydebug)
                    printf("yydebug: error recovery discarding state %d\n",
                            *yyssp);
#endif
                if (yyssp <= yyss) goto yyabort;
                --yyssp;
                --yyvsp;
            }
        }
    }
    else
    {
        if (yychar == 0) goto yyabort;
#if YYDEBUG
        if (yydebug)
        {
            yys = 0;
            if (yychar <= YYMAXTOKEN) yys = yyname[yychar];
            if (!yys) yys = "illegal-symbol";
            printf("yydebug: state %d, error recovery discards token %d (%s)\n",
                    yystate, yychar, yys);
        }
#endif
        yychar = (-1);
        goto yyloop;
    }
yyreduce:
#if YYDEBUG
    if (yydebug)
        printf("yydebug: state %d, reducing by rule %d (%s)\n",
                yystate, yyn, yyrule[yyn]);
#endif
    yym = yylen[yyn];
    yyval = yyvsp[1-yym];
    switch (yyn)
    {
case 12:
#line 80 "parse.y"
{
		struct link *l;

		l = addlink(yyvsp[-2].y_node , yyvsp[-1].y_s .ys_node, yyvsp[0].y_cost , yyvsp[-1].y_s .ys_net, yyvsp[-1].y_s .ys_dir);
		if (GATEWAYED(yyvsp[-1].y_s .ys_node))
			l->l_flag |= LGATEWAY;
		if (yyvsp[-1].y_s .ys_flag & TERMINAL)
			l->l_flag |= LTERMINAL;
	  }
break;
case 13:
#line 89 "parse.y"
{
		struct link *l;

		l = addlink(yyvsp[-3].y_node , yyvsp[-1].y_s .ys_node, yyvsp[0].y_cost , yyvsp[-1].y_s .ys_net, yyvsp[-1].y_s .ys_dir);
		if (GATEWAYED(yyvsp[-1].y_s .ys_node))
			l->l_flag |= LGATEWAY;
		if (yyvsp[-1].y_s .ys_flag & TERMINAL)
			l->l_flag |= LTERMINAL;
	  }
break;
case 15:
#line 101 "parse.y"
{yyval.y_node  = addnode(yyvsp[0].y_name );}
break;
case 16:
#line 102 "parse.y"
{yyval.y_node  = addnode("private");}
break;
case 17:
#line 103 "parse.y"
{yyval.y_node  = addnode("dead");}
break;
case 18:
#line 104 "parse.y"
{yyval.y_node  = addnode("delete");}
break;
case 19:
#line 105 "parse.y"
{yyval.y_node  = addnode("file");}
break;
case 20:
#line 106 "parse.y"
{yyval.y_node  = addnode("adjust");}
break;
case 21:
#line 109 "parse.y"
{
		yyval.y_s  = yyvsp[0].y_s ;
		yyval.y_s .ys_net = DEFNET;
		yyval.y_s .ys_dir = DEFDIR;
	  }
break;
case 22:
#line 114 "parse.y"
{
		yyval.y_s  = yyvsp[0].y_s ;
		yyval.y_s .ys_net = yyvsp[-1].y_net ;
		yyval.y_s .ys_dir = LRIGHT;
	  }
break;
case 23:
#line 119 "parse.y"
{
		yyval.y_s  = yyvsp[-1].y_s ;
		yyval.y_s .ys_net = yyvsp[0].y_net ;
		yyval.y_s .ys_dir = LLEFT;
	  }
break;
case 24:
#line 126 "parse.y"
{
		yyval.y_s .ys_node = addnode(yyvsp[0].y_name );
		yyval.y_s .ys_flag = 0;
	  }
break;
case 25:
#line 130 "parse.y"
{
		Tcount++;
		yyval.y_s .ys_node = addnode(yyvsp[-1].y_name );
		yyval.y_s .ys_flag = TERMINAL;
	  }
break;
case 26:
#line 137 "parse.y"
{alias(yyvsp[-2].y_node , addnode(yyvsp[0].y_name ));}
break;
case 27:
#line 138 "parse.y"
{alias(yyvsp[-2].y_node , addnode(yyvsp[0].y_name ));}
break;
case 29:
#line 142 "parse.y"
{fixnet(yyvsp[-4].y_node , yyvsp[-2].y_node , yyvsp[0].y_cost , DEFNET, DEFDIR);}
break;
case 30:
#line 143 "parse.y"
{fixnet(yyvsp[-5].y_node , yyvsp[-2].y_node , yyvsp[0].y_cost , yyvsp[-4].y_net , LRIGHT);}
break;
case 31:
#line 144 "parse.y"
{fixnet(yyvsp[-5].y_node , yyvsp[-3].y_node , yyvsp[0].y_cost , yyvsp[-1].y_net , LLEFT);}
break;
case 32:
#line 147 "parse.y"
{yyval.y_node  = 0;	/* anonymous net */}
break;
case 33:
#line 148 "parse.y"
{yyval.y_node  = yyvsp[-1].y_node ;	/* named net */}
break;
case 34:
#line 151 "parse.y"
{yyval.y_node  = addnode(yyvsp[0].y_name );}
break;
case 35:
#line 152 "parse.y"
{
		node *n;

		n = addnode(yyvsp[0].y_name );
		if (n->n_net == 0) {
			n->n_net = yyvsp[-2].y_node ;
			yyval.y_node  = n;
		}
	  }
break;
case 38:
#line 165 "parse.y"
{fixprivate();}
break;
case 39:
#line 168 "parse.y"
{addprivate(yyvsp[0].y_name )->n_flag |= ISPRIVATE;}
break;
case 40:
#line 169 "parse.y"
{addprivate(yyvsp[0].y_name )->n_flag |= ISPRIVATE;}
break;
case 46:
#line 180 "parse.y"
{deadlink(addnode(yyvsp[0].y_name ), (node *) 0);}
break;
case 47:
#line 181 "parse.y"
{deadlink(yyvsp[-2].y_node , yyvsp[0].y_node );}
break;
case 48:
#line 184 "parse.y"
{yyval.y_node  = addnode(yyvsp[0].y_name );}
break;
case 53:
#line 193 "parse.y"
{
		node *n;

		n = addnode(yyvsp[0].y_name );
		deletelink(n, (node *) 0);
		n->n_flag |= ISPRIVATE;
	  }
break;
case 54:
#line 200 "parse.y"
{deletelink(yyvsp[-2].y_node , yyvsp[0].y_node );}
break;
case 55:
#line 203 "parse.y"
{Scanstate = FILENAME;}
break;
case 56:
#line 203 "parse.y"
{Scanstate = OTHER;}
break;
case 57:
#line 203 "parse.y"
{
		Lineno = 0;
		Cfile = strsave(yyvsp[-2].y_name );
	}
break;
case 62:
#line 215 "parse.y"
{adjust(yyvsp[-1].y_node , yyvsp[0].y_cost );}
break;
case 63:
#line 217 "parse.y"
{yyval.y_cost  = DEFCOST;	/* empty -- cost is always optional */}
break;
case 64:
#line 218 "parse.y"
{Scanstate = COSTING;}
break;
case 65:
#line 218 "parse.y"
{Scanstate = OTHER;}
break;
case 66:
#line 219 "parse.y"
{yyval.y_cost  = yyvsp[-2].y_cost ;}
break;
case 68:
#line 223 "parse.y"
{yyval.y_cost  = -yyvsp[0].y_cost ;}
break;
case 69:
#line 224 "parse.y"
{yyval.y_cost  = yyvsp[-1].y_cost ;}
break;
case 70:
#line 225 "parse.y"
{yyval.y_cost  = yyvsp[-2].y_cost  + yyvsp[0].y_cost ;}
break;
case 71:
#line 226 "parse.y"
{yyval.y_cost  = yyvsp[-2].y_cost  - yyvsp[0].y_cost ;}
break;
case 72:
#line 227 "parse.y"
{yyval.y_cost  = yyvsp[-2].y_cost  * yyvsp[0].y_cost ;}
break;
case 73:
#line 228 "parse.y"
{
		if (yyvsp[0].y_cost  == 0)
			yyerror("zero divisor\n");
		else
			yyval.y_cost  = yyvsp[-2].y_cost  / yyvsp[0].y_cost ;
	  }
break;
#line 996 "y_tab.c"
    }
    yyssp -= yym;
    yystate = *yyssp;
    yyvsp -= yym;
    yym = yylhs[yyn];
    if (yystate == 0 && yym == 0)
    {
#ifdef YYDEBUG
        if (yydebug)
            printf("yydebug: after reduction, shifting from state 0 to\
 state %d\n", YYFINAL);
#endif
        yystate = YYFINAL;
        *++yyssp = YYFINAL;
        *++yyvsp = yyval;
        if (yychar < 0)
        {
            if ((yychar = yylex()) < 0) yychar = 0;
#if YYDEBUG
            if (yydebug)
            {
                yys = 0;
                if (yychar <= YYMAXTOKEN) yys = yyname[yychar];
                if (!yys) yys = "illegal-symbol";
                printf("yydebug: state %d, reading %d (%s)\n",
                        YYFINAL, yychar, yys);
            }
#endif
        }
        if (yychar == 0) goto yyaccept;
        goto yyloop;
    }
    if ((yyn = yygindex[yym]) && (yyn += yystate) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yystate)
        yystate = yytable[yyn];
    else
        yystate = yydgoto[yym];
#ifdef YYDEBUG
    if (yydebug)
        printf("yydebug: after reduction, shifting from state %d \
to state %d\n", *yyssp, yystate);
#endif
    if (yyssp >= yyss + yystacksize - 1)
    {
        goto yyoverflow;
    }
    *++yyssp = yystate;
    *++yyvsp = yyval;
    goto yyloop;
yyoverflow:
    yyerror("yacc stack overflow");
yyabort:
    return (1);
yyaccept:
    return (0);
}
