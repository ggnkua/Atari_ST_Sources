
# line 15 "gram.y"
#include "sc.h"

# line 18 "gram.y"
typedef union  {
    int ival;
    double fval;
    struct ent *ent;
    struct enode *enode;
    char *sval;
} YYSTYPE;
# define STRING 257
# define NUMBER 258
# define FNUMBER 259
# define WORD 260
# define COL 261
# define S_FORMAT 262
# define S_LABEL 263
# define S_LEFTSTRING 264
# define S_RIGHTSTRING 265
# define S_GET 266
# define S_PUT 267
# define S_MERGE 268
# define S_LET 269
# define S_WRITE 270
# define S_TBL 271
# define S_PROGLET 272
# define S_COPY 273
# define S_SHOW 274
# define K_FIXED 275
# define K_SUM 276
# define K_PROD 277
# define K_AVE 278
#define yyclearin yychar = -1
#define yyerrok yyerrflag = 0
extern int yychar;
extern short yyerrflag;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
YYSTYPE yylval, yyval;
# define YYERRCODE 256
short yyexca[] ={
-1, 1,
	0, -1,
	-2, 0,
-1, 83,
	60, 0,
	61, 0,
	62, 0,
	-2, 34,
-1, 85,
	60, 0,
	61, 0,
	62, 0,
	-2, 35,
-1, 86,
	60, 0,
	61, 0,
	62, 0,
	-2, 36,
-1, 96,
	60, 0,
	61, 0,
	62, 0,
	-2, 39,
-1, 97,
	60, 0,
	61, 0,
	62, 0,
	-2, 41,
-1, 98,
	60, 0,
	61, 0,
	62, 0,
	-2, 40,
	};
# define YYNPROD 43
# define YYLAST 267
short yyact[]={

  14,  69,  70,  71,  16,  55,   6,   3,   4,   5,
   7,   9,   8,   2,  10,  11,  49,  13,  12,  27,
  49,  54,  26,  43,  49,  20,  44,  43,  45,  53,
  44,  43,  45,  34,  44,  30,  45,  52,  51,  50,
  25,  24,  23,  22,  87,  21,  90,  42,  84,  67,
  33,  42, 105,  32,  65,  42,  31,  67,  59,  57,
  29,  58,  65,  60, 104,  94,  59,  57, 103,  58,
  56,  60,  36,  35,  95, 111,  62,  63,  64,  61,
 110, 109,  93,  67,  62,  63,  64,  61,  65,  39,
  67,  67,  59,  57,  92,  58,  65,  60,  38,  59,
  59,  57,  91,  58,  60,  60,  67,   1,   0,  48,
  62,  63,  64,  48,   0,   0,   0,  48,  62,  63,
  64,  61,  40,   0,   0,  15,  17,  18,  19,   0,
   0,  68,   0,   0,  73,  74,  28,   0,  75,  76,
  66,   0,  72,   0,   0,   0,   0,   0,  66,   0,
   0,  37,   0,   0,   0,   0,  78,  79,  80,  81,
  82,  83,  85,  86,  88,  89,  67,   0,   0,   0,
   0,   0,   0,   0,  66,  59,  57,   0,  58,  77,
  60,   0,  66,  96,   0,   0,  97,   0,   0,  98,
  67,   0,   0,   0, 102,  65,  67,   0,   0,  59,
  57,   0,  58,   0,  60,  59,  57,   0,  58,   0,
  60,   0,   0,   0,  99, 100, 101,  62,  63,  64,
   0,   0,   0,  62,  63,  64, 106, 107, 108,   0,
   0,   0,   0,   0,   0,   0,   0,   0,   0,   0,
   0,  46,  47,   0,  16,  46,  47,   0,  16,  46,
  47,   0,  16,   0,   0,   0,   0,   0,  41,   0,
   0,   0,  41,   0,   0,   0,  41 };
short yypact[]={

-256,-1000,-257,-257,-257,-257,-236,-212,-214,-215,
-216,-217,-239,-257,-1000,  -1,-223,  -5,  -8, -11,
-225,-1000,-1000,-1000,-1000,-1000,  15,  14,-257,  -9,
-1000,-218,-219,-220,-229,-240,-253,  12,  58,-1000,
-1000,  -9,-275,  -9,  -9,  -9,-1000,-1000,  -9,  -9,
-1000,-1000,-1000,-1000,-1000,-1000,-257,  -9,  -9,  -9,
  -9,  -9, -13,  -9, -17,  -9,  -9, -15,-1000,  62,
  54,  42,  24,-1000,-1000,-1000,-1000,-1000,  57,  57,
  73,  73,  16, 133,  -9, 133, 133,  -9, 163, 157,
  -9,-257,-257,-257,-1000,  -9, 133, 133, 133,  10,
   6,  -6,  50,-257,-257,-257,  40,  39,  34,-1000,
-1000,-1000 };
short yypgo[]={

   0, 122,  98,  89, 107 };
short yyr1[]={

   0,   4,   4,   4,   4,   4,   4,   4,   4,   4,
   4,   4,   4,   4,   4,   4,   3,   3,   3,   3,
   3,   3,   3,   3,   3,   3,   3,   3,   2,   2,
   2,   2,   2,   2,   2,   2,   2,   2,   2,   2,
   2,   2,   1 };
short yyr2[]={

   0,   4,   4,   4,   4,   4,   2,   2,   2,   2,
   2,   4,   4,   5,   0,   1,   1,   2,   7,   7,
   7,   3,   2,   2,   1,   1,   2,   2,   3,   3,
   3,   3,   1,   5,   3,   3,   3,   3,   3,   4,
   4,   4,   2 };
short yychk[]={

-1000,  -4, 269, 263, 264, 265, 262, 266, 268, 267,
 270, 271, 274, 273, 256,  -1, 261,  -1,  -1,  -1,
 261, 257, 257, 257, 257, 257, 261, 258,  -1,  61,
 258,  61,  61,  61, 258,  58,  58,  -1,  -2,  -3,
  -1, 275,  64,  40,  43,  45, 258, 259, 126,  33,
 257, 257, 257, 258, 261, 258,  58,  43,  45,  42,
  47,  63,  60,  61,  62,  38, 124,  33,  -3, 276,
 277, 278,  -2,  -3,  -3,  -3,  -3,  -1,  -2,  -2,
  -2,  -2,  -2,  -2,  61,  -2,  -2,  61,  -2,  -2,
  61,  40,  40,  40,  41,  58,  -2,  -2,  -2,  -1,
  -1,  -1,  -2,  58,  58,  58,  -1,  -1,  -1,  41,
  41,  41 };
short yydef[]={

  14,  -2,   0,   0,   0,   0,   0,   0,   0,   0,
   0,   0,   0,   0,  15,   0,   0,   0,   0,   0,
   0,   6,   7,   8,   9,  10,   0,   0,   0,   0,
  42,   0,   0,   0,   0,   0,   0,   0,   1,  32,
  16,   0,   0,   0,   0,   0,  24,  25,   0,   0,
   2,   3,   4,   5,  11,  12,   0,   0,   0,   0,
   0,   0,   0,   0,   0,   0,   0,   0,  17,   0,
   0,   0,   0,  22,  23,  26,  27,  13,  28,  29,
  30,  31,   0,  -2,   0,  -2,  -2,   0,  37,  38,
   0,   0,   0,   0,  21,   0,  -2,  -2,  -2,   0,
   0,   0,  33,   0,   0,   0,   0,   0,   0,  18,
  19,  20 };
#ifndef lint
static char yaccpar_sccsid[] = "@(#)yaccpar	4.1	(Berkeley)	2/11/83";
#endif not lint

#
# define YYFLAG -1000
# define YYERROR goto yyerrlab
# define YYACCEPT return(0)
# define YYABORT return(1)

/*	parser for yacc output	*/

#ifdef YYDEBUG
int yydebug = 0; /* 1 for debugging */
#endif
YYSTYPE yyv[YYMAXDEPTH]; /* where the values are stored */
int yychar = -1; /* current input token number */
int yynerrs = 0;  /* number of errors */
short yyerrflag = 0;  /* error recovery flag */

yyparse() {

	short yys[YYMAXDEPTH];
	short yyj, yym;
	register YYSTYPE *yypvt;
	register short yystate, *yyps, yyn;
	register YYSTYPE *yypv;
	register short *yyxi;

	yystate = 0;
	yychar = -1;
	yynerrs = 0;
	yyerrflag = 0;
	yyps= &yys[-1];
	yypv= &yyv[-1];

 yystack:    /* put a state and value onto the stack */

#ifdef YYDEBUG
	if( yydebug  ) printf( "state %d, char 0%o\n", yystate, yychar );
#endif
		if( ++yyps> &yys[YYMAXDEPTH] ) { yyerror( "yacc stack overflow" ); return(1); }
		*yyps = yystate;
		++yypv;
		*yypv = yyval;

 yynewstate:

	yyn = yypact[yystate];

	if( yyn<= YYFLAG ) goto yydefault; /* simple state */

	if( yychar<0 ) if( (yychar=yylex())<0 ) yychar=0;
	if( (yyn += yychar)<0 || yyn >= YYLAST ) goto yydefault;

	if( yychk[ yyn=yyact[ yyn ] ] == yychar ){ /* valid shift */
		yychar = -1;
		yyval = yylval;
		yystate = yyn;
		if( yyerrflag > 0 ) --yyerrflag;
		goto yystack;
		}

 yydefault:
	/* default state action */

	if( (yyn=yydef[yystate]) == -2 ) {
		if( yychar<0 ) if( (yychar=yylex())<0 ) yychar = 0;
		/* look through exception table */

		for( yyxi=yyexca; (*yyxi!= (-1)) || (yyxi[1]!=yystate) ; yyxi += 2 ) ; /* VOID */

		while( *(yyxi+=2) >= 0 ){
			if( *yyxi == yychar ) break;
			}
		if( (yyn = yyxi[1]) < 0 ) return(0);   /* accept */
		}

	if( yyn == 0 ){ /* error */
		/* error ... attempt to resume parsing */

		switch( yyerrflag ){

		case 0:   /* brand new error */

			yyerror( "syntax error" );
		yyerrlab:
			++yynerrs;

		case 1:
		case 2: /* incompletely recovered error ... try again */

			yyerrflag = 3;

			/* find a state where "error" is a legal shift action */

			while ( yyps >= yys ) {
			   yyn = yypact[*yyps] + YYERRCODE;
			   if( yyn>= 0 && yyn < YYLAST && yychk[yyact[yyn]] == YYERRCODE ){
			      yystate = yyact[yyn];  /* simulate a shift of "error" */
			      goto yystack;
			      }
			   yyn = yypact[*yyps];

			   /* the current yyps has no shift onn "error", pop stack */

#ifdef YYDEBUG
			   if( yydebug ) printf( "error recovery pops state %d, uncovers %d\n", *yyps, yyps[-1] );
#endif
			   --yyps;
			   --yypv;
			   }

			/* there is no state on the stack with an error shift ... abort */

	yyabort:
			return(1);


		case 3:  /* no shift yet; clobber input char */

#ifdef YYDEBUG
			if( yydebug ) printf( "error recovery discards char %d\n", yychar );
#endif

			if( yychar == 0 ) goto yyabort; /* don't discard EOF, quit */
			yychar = -1;
			goto yynewstate;   /* try again in the same state */

			}

		}

	/* reduction by production yyn */

#ifdef YYDEBUG
		if( yydebug ) printf("reduce %d\n",yyn);
#endif
		yyps -= yyr2[yyn];
		yypvt = yypv;
		yypv -= yyr2[yyn];
		yyval = yypv[1];
		yym=yyn;
			/* consult goto table to find next state */
		yyn = yyr1[yyn];
		yyj = yypgo[yyn] + *yyps + 1;
		if( yyj>=YYLAST || yychk[ yystate = yyact[yyj] ] != -yyn ) yystate = yyact[yypgo[yyn]];
		switch(yym){
			
case 1:
# line 59 "gram.y"
{ let (yypvt[-2].ent, yypvt[-0].enode); } break;
case 2:
# line 61 "gram.y"
{ label (yypvt[-2].ent, yypvt[-0].sval, 0); } break;
case 3:
# line 63 "gram.y"
{ label (yypvt[-2].ent, yypvt[-0].sval, -1); } break;
case 4:
# line 65 "gram.y"
{ label (yypvt[-2].ent, yypvt[-0].sval, 1); } break;
case 5:
# line 67 "gram.y"
{ fwidth[yypvt[-2].ival] = yypvt[-1].ival;
				  FullUpdate++;
				  modflg++;
				  precision[yypvt[-2].ival] = yypvt[-0].ival; } break;
case 6:
# line 71 "gram.y"
{ readfile (yypvt[-0].sval,1); } break;
case 7:
# line 72 "gram.y"
{ readfile (yypvt[-0].sval,0); } break;
case 8:
# line 73 "gram.y"
{ writefile (yypvt[-0].sval); } break;
case 9:
# line 74 "gram.y"
{ printfile (yypvt[-0].sval); } break;
case 10:
# line 75 "gram.y"
{ tblprintfile (yypvt[-0].sval); } break;
case 11:
# line 76 "gram.y"
{ showcol( yypvt[-2].ival, yypvt[-0].ival); } break;
case 12:
# line 77 "gram.y"
{ showrow( yypvt[-2].ival, yypvt[-0].ival); } break;
case 13:
# line 79 "gram.y"
{ copy(yypvt[-3].ent, yypvt[-2].ent, yypvt[-0].ent); } break;
case 16:
# line 83 "gram.y"
{ yyval.enode = new ('v', yypvt[-0].ent); } break;
case 17:
# line 84 "gram.y"
{ yyval.enode = new ('f', 0L, yypvt[-0].enode); } break;
case 18:
# line 86 "gram.y"
{ yyval.enode = new (O_REDUCE('+'), yypvt[-3].ent, yypvt[-1].ent); } break;
case 19:
# line 88 "gram.y"
{ yyval.enode = new (O_REDUCE('*'), yypvt[-3].ent, yypvt[-1].ent); } break;
case 20:
# line 90 "gram.y"
{ yyval.enode = new (O_REDUCE('a'), yypvt[-3].ent, yypvt[-1].ent); } break;
case 21:
# line 91 "gram.y"
{ yyval.enode = yypvt[-1].enode; } break;
case 22:
# line 92 "gram.y"
{ yyval.enode = yypvt[-0].enode; } break;
case 23:
# line 93 "gram.y"
{ yyval.enode = new ('m', 0L, yypvt[-0].enode); } break;
case 24:
# line 94 "gram.y"
{ yyval.enode = new ('k', (double) yypvt[-0].ival); } break;
case 25:
# line 95 "gram.y"
{ yyval.enode = new ('k', yypvt[-0].fval); } break;
case 26:
# line 96 "gram.y"
{ yyval.enode = new ('~', 0L, yypvt[-0].enode); } break;
case 27:
# line 97 "gram.y"
{ yyval.enode = new ('~', 0L, yypvt[-0].enode); } break;
case 28:
# line 100 "gram.y"
{ yyval.enode = new ('+', yypvt[-2].enode, yypvt[-0].enode); } break;
case 29:
# line 101 "gram.y"
{ yyval.enode = new ('-', yypvt[-2].enode, yypvt[-0].enode); } break;
case 30:
# line 102 "gram.y"
{ yyval.enode = new ('*', yypvt[-2].enode, yypvt[-0].enode); } break;
case 31:
# line 103 "gram.y"
{ yyval.enode = new ('/', yypvt[-2].enode, yypvt[-0].enode); } break;
case 33:
# line 105 "gram.y"
{ yyval.enode = new ('?', yypvt[-4].enode, new(':', yypvt[-2].enode, yypvt[-0].enode)); } break;
case 34:
# line 106 "gram.y"
{ yyval.enode = new ('<', yypvt[-2].enode, yypvt[-0].enode); } break;
case 35:
# line 107 "gram.y"
{ yyval.enode = new ('=', yypvt[-2].enode, yypvt[-0].enode); } break;
case 36:
# line 108 "gram.y"
{ yyval.enode = new ('>', yypvt[-2].enode, yypvt[-0].enode); } break;
case 37:
# line 109 "gram.y"
{ yyval.enode = new ('&', yypvt[-2].enode, yypvt[-0].enode); } break;
case 38:
# line 110 "gram.y"
{ yyval.enode = new ('|', yypvt[-2].enode, yypvt[-0].enode); } break;
case 39:
# line 111 "gram.y"
{ yyval.enode = new ('~', 0L, new ('>', yypvt[-3].enode, yypvt[-0].enode)); } break;
case 40:
# line 112 "gram.y"
{ yyval.enode = new ('~', 0L, new ('=', yypvt[-3].enode, yypvt[-0].enode)); } break;
case 41:
# line 113 "gram.y"
{ yyval.enode = new ('~', 0L, new ('<', yypvt[-3].enode, yypvt[-0].enode)); } break;
case 42:
# line 116 "gram.y"
{ yyval.ent = lookat(yypvt[-0].ival , yypvt[-1].ival); } break; 
		}
		goto yystack;  /* stack new state and value */

	}
