#ifndef lint
static char yysccsid[] = "@(#)yaccpar	1.9 (Berkeley) 02/21/93";
#endif
#define YYBYACC 1
#define YYMAJOR 1
#define YYMINOR 9
#define yyclearin (yychar=(-1))
#define yyerrok (yyerrflag=0)
#define YYRECOVERING (yyerrflag!=0)
#define YYPREFIX "yy"
#line 9 "parser.y"
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include "lexer.h"
#include "symtabs.h"
#include "output.h"

/* Get bison to dump it's behaviour to stderr */
#define YYDEBUG 1
extern int yydebug;

/* The cheap and easy alternative... */
#define YYERROR_VERBOSE 1

#define YYPRINT(file, type, value) yyprint(file, type, value)
/*void yyprint(FILE *file, int type, YYSTYPE value);*/
int yyerror(char *s);

SymNode *alphabet_lookup(char *symbol);
STNode *goto_lookup(char *label);

#line 33 "parser.y"
typedef union {
	STNode *st;
	SymNode *sym;
	char *id;
	int dir;
} YYSTYPE;
#line 63 "parser.y"

/* The parser functions */
int yyparse();
int yyprint(FILE *file, int type, YYSTYPE value);

#line 47 "y.tab.c"
#define TAI 257
#define IF 258
#define THEN 259
#define GOTO 260
#define MOVE 261
#define PRINT 262
#define DIR 263
#define ONESQUARE 264
#define IDENT 265
#define COLON 266
#define COMMA 267
#define DQUOTE 268
#define LBRACE 269
#define PERIOD 270
#define RBRACE 271
#define SEMICOLON 272
#define YYERRCODE 256
short yylhs[] = {                                        -1,
    0,    3,    3,    2,    2,    2,    1,    4,    1,    5,
    1,    1,    1,    1,    6,    1,
};
short yylen[] = {                                         2,
    4,    2,    3,    1,    3,    2,    0,    0,    7,    0,
    4,    3,    2,    3,    0,    5,
};
short yydefred[] = {                                      0,
    0,    0,    0,    2,    0,    0,    3,    0,    0,    0,
    0,    0,   10,    0,    4,    0,    6,    0,   13,    0,
    0,    0,    0,    1,    0,    8,   14,   15,    0,   12,
    5,    0,    0,   11,    0,   16,    0,    9,
};
short yydgoto[] = {                                       2,
   15,   16,    3,   32,   22,   33,
};
short yysindex[] = {                                   -249,
 -264,    0, -248,    0, -242, -256,    0, -246, -240, -231,
 -228, -232,    0, -256,    0, -250,    0, -227,    0, -225,
 -224, -229, -241,    0, -244,    0,    0,    0, -244,    0,
    0, -226, -223,    0, -219,    0, -244,    0,
};
short yyrindex[] = {                                      0,
    0,    0,    0,    0,    0, -243,    0,    0,    0,    0,
    0,    0,    0, -239,    0,    0,    0,    0,    0,    0,
    0,    0,    0,    0, -260,    0,    0,    0, -260,    0,
    0,    0,    0,    0,    0,    0, -260,    0,
};
short yygindex[] = {                                      0,
  -22,   29,    0,    0,    0,    0,
};
#define YYTABLESIZE 45
short yytable[] = {                                       8,
    4,    9,   31,   10,   11,   12,   34,    1,   13,    7,
    7,    7,   14,    9,   38,   10,   11,   12,    5,   24,
   13,   25,    7,    6,   14,   17,    7,   18,    7,   30,
   25,    7,    7,   19,   20,   21,   29,   26,   27,   37,
   28,   35,   23,    0,   36,
};
short yycheck[] = {                                     256,
  265,  258,   25,  260,  261,  262,   29,  257,  265,  270,
  271,  272,  269,  258,   37,  260,  261,  262,  267,  270,
  265,  272,  265,  272,  269,  272,  270,  268,  272,  271,
  272,  271,  272,  265,  263,  268,  266,  265,  264,  259,
  265,  268,   14,   -1,  268,
};
#define YYFINAL 2
#ifndef YYDEBUG
#define YYDEBUG 0
#endif
#define YYMAXTOKEN 272
#if YYDEBUG
char *yyname[] = {
"end-of-file",0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,
0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,"TAI","IF","THEN","GOTO","MOVE",
"PRINT","DIR","ONESQUARE","IDENT","COLON","COMMA","DQUOTE","LBRACE","PERIOD",
"RBRACE","SEMICOLON",
};
char *yyrule[] = {
"$accept : program",
"program : declarations SEMICOLON statements PERIOD",
"declarations : TAI IDENT",
"declarations : declarations COMMA IDENT",
"statements : statement",
"statements : statements SEMICOLON statement",
"statements : error SEMICOLON",
"statement :",
"$$1 :",
"statement : IF DQUOTE IDENT $$1 DQUOTE THEN statement",
"$$2 :",
"statement : IDENT $$2 COLON statement",
"statement : LBRACE statements RBRACE",
"statement : GOTO IDENT",
"statement : MOVE DIR ONESQUARE",
"$$3 :",
"statement : PRINT DQUOTE IDENT $$3 DQUOTE",
};
#endif
#ifdef YYSTACKSIZE
#undef YYMAXDEPTH
#define YYMAXDEPTH YYSTACKSIZE
#else
#ifdef YYMAXDEPTH
#define YYSTACKSIZE YYMAXDEPTH
#else
#define YYSTACKSIZE 500
#define YYMAXDEPTH 500
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
short yyss[YYSTACKSIZE];
YYSTYPE yyvs[YYSTACKSIZE];
#define yystacksize YYSTACKSIZE
#line 96 "parser.y"

/* Lookup the alphabet and abort if symbol not found */
SymNode *alphabet_lookup(char *symbol)
{
  SymNode *sym = sym_lookup(&alphabet, symbol);

  if(sym == NULL) {
    /* error */
    yyerror(strcat("symbol \"", strcat(symbol, "\" not found.\n")));
    /* YYABORT;*/
  }
  return(sym);
}

STNode *goto_lookup(char *label)
{
  SymNode *sym = sym_lookup(&labels, label);

/*printf("GOTO(%s)\n", (sym == NULL) ? NULL : sym->name);*/

  if(sym == NULL) {
    sym_insert(&forwardrefs, strdup(label), st_last());
    return(st_GOTO(NULL));
  } else
    return(st_GOTO(sym->state));
}

/* Print out semantic values */
int yyprint(FILE *file, int type, YYSTYPE value)
{
  switch(type) {
  case DIR:
    fprintf(file, " %d", value.dir);
    break;
  case IDENT:
    fprintf(file, " %s", value.id);
    break;
  }
  return(0);
}

/* Trivial error handler */
int yyerror(char *s)
{
  printf("line %d: %s\n", line_num, s);
  return(0);
}

/* Fix forward-referencing GOTOs */
void postprocess()
{
  SymNode *node, *cur;
 
  for(node = forwardrefs; node != NULL; ) {
    if((cur = sym_lookup(&labels, node->name)) == NULL) {
      /* Label not defined */
      printf("turingol: label \"%s\" not defined.\n", node->name);
      exit(1);
    }

    node->state->data.dest = cur->state;
    cur = node;
    node = sym_traverse(&node);
    free(cur->name);
    free(cur);
  }

  forwardrefs = NULL;
}

void usage(char *name, char *err1, char *err2)
{
  printf("%s%s\nUsage: %s [-o outfile] [-r runfile] [-d] [sourcefile]\n", err1, err2, name);
  exit(1);
}

/*
handle command line parms:

"filename" == input filename			(default: stdin)
"-d" == debug
"-o filename" == output filename for tuples	(default: stdout)
"-r filename" == output filename for execution	(default: don't run)

*/

int main(int argc, char *argv[])
{
  int i;
  FILE *outfile = NULL, *runfile = stdout;

  yyin = stdin;
  if(argc > 1)
    for(i = 1; i < argc; i++) {
      if(argv[i][0] == '-') {
	if(!strcmp(argv[i], "-d"))
	  yydebug = 1;
	else if(!strcmp(argv[i], "-o")) {
	  if(++i < argc && outfile == stdout) {
	    if((outfile = fopen(argv[i], "w")) == NULL) {
	      /* file open error */
	      fprintf(stderr, "%s: cannot open file: %s, ", argv[0], argv[i]);
	      exit(1);
	    }
	  } else
	    usage(argv[0], "Bad option: ", argv[i - 1]);
	} else if(!strcmp(argv[i], "-r")) {
	  if(++i < argc && runfile == NULL) {
	    if((runfile = fopen(argv[i], "w")) == NULL) {
	      /* file open error */
	      fprintf(stderr, "%s: cannot open file: %s, ", argv[0], argv[i]);
	      exit(1);
	    }
	  } else
	    usage(argv[0], "Bad option: ", argv[i - 1]);
	} else
	  usage(argv[0], "Unknown option: ", argv[i]);
      } else {
	if((yyin = fopen(argv[i], "r")) == NULL) {
	  /* file open error */
	  fprintf(stderr, "%s: cannot open file: %s, ", argv[0], argv[i]);
	  exit(1);
	}
      }
    }

  st_init();
  i = yyparse();
  fclose(yyin);

  if(!i) {
    postprocess();
    if (outfile != NULL)
    {
	tuple_header(outfile);
	traverse_graph(outfile, tuple_out);
	fclose(outfile);
    }
    if(runfile != NULL) {
      st_run(runfile);
      fclose(runfile);
    }
    return(0);
  } else
    return(1);
}
#line 318 "y.tab.c"
#define YYABORT goto yyabort
#define YYREJECT goto yyabort
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
            printf("%sdebug: state %d, reading %d (%s)\n",
                    YYPREFIX, yystate, yychar, yys);
        }
#endif
    }
    if ((yyn = yysindex[yystate]) && (yyn += yychar) >= 0 &&
            yyn <= YYTABLESIZE && yycheck[yyn] == yychar)
    {
#if YYDEBUG
        if (yydebug)
            printf("%sdebug: state %d, shifting to state %d\n",
                    YYPREFIX, yystate, yytable[yyn]);
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
                    printf("%sdebug: state %d, error recovery shifting\
 to state %d\n", YYPREFIX, *yyssp, yytable[yyn]);
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
                    printf("%sdebug: error recovery discarding state %d\n",
                            YYPREFIX, *yyssp);
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
            printf("%sdebug: state %d, error recovery discards token %d (%s)\n",
                    YYPREFIX, yystate, yychar, yys);
        }
#endif
        yychar = (-1);
        goto yyloop;
    }
yyreduce:
#if YYDEBUG
    if (yydebug)
        printf("%sdebug: state %d, reducing by rule %d (%s)\n",
                YYPREFIX, yystate, yyn, yyrule[yyn]);
#endif
    yym = yylen[yyn];
    yyval = yyvsp[1-yym];
    switch (yyn)
    {
case 2:
#line 75 "parser.y"
{ sym_insert(&alphabet, strdup(yyvsp[0].id), NULL); }
break;
case 3:
#line 76 "parser.y"
{ sym_insert(&alphabet, strdup(yyvsp[0].id), NULL); }
break;
case 4:
#line 79 "parser.y"
{ yyval.st = yyvsp[0].st; }
break;
case 5:
#line 80 "parser.y"
{ yyval.st = yyvsp[0].st; }
break;
case 6:
#line 81 "parser.y"
{}
break;
case 7:
#line 84 "parser.y"
{ yyval.st = st_last(); }
break;
case 8:
#line 85 "parser.y"
{ yyval.st = st_StartIF(alphabet_lookup(yyvsp[0].id)); }
break;
case 9:
#line 86 "parser.y"
{ yyval.st = st_EndIF(yyvsp[-3].st); }
break;
case 10:
#line 87 "parser.y"
{ st_labelled(yyvsp[0].id); }
break;
case 11:
#line 87 "parser.y"
{ yyval.st = yyvsp[0].st; }
break;
case 12:
#line 88 "parser.y"
{ yyval.st = yyvsp[-1].st; }
break;
case 13:
#line 89 "parser.y"
{ yyval.st = goto_lookup(yyvsp[0].id); }
break;
case 14:
#line 90 "parser.y"
{ yyval.st = st_MOVE(yyvsp[-1].dir); }
break;
case 15:
#line 91 "parser.y"
{ yyval.sym = alphabet_lookup(yyvsp[0].id); }
break;
case 16:
#line 92 "parser.y"
{ yyval.st = st_PRINT(yyvsp[-1].sym); }
break;
#line 519 "y.tab.c"
    }
    yyssp -= yym;
    yystate = *yyssp;
    yyvsp -= yym;
    yym = yylhs[yyn];
    if (yystate == 0 && yym == 0)
    {
#if YYDEBUG
        if (yydebug)
            printf("%sdebug: after reduction, shifting from state 0 to\
 state %d\n", YYPREFIX, YYFINAL);
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
                printf("%sdebug: state %d, reading %d (%s)\n",
                        YYPREFIX, YYFINAL, yychar, yys);
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
#if YYDEBUG
    if (yydebug)
        printf("%sdebug: after reduction, shifting from state %d \
to state %d\n", YYPREFIX, *yyssp, yystate);
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
