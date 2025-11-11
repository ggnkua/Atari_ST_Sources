extern char *malloc(), *realloc();
# define VAR 257
# define CONS 258
# define SIGN 259
# define AR_M_OP 260
# define RE_OP 261
# define END_C 262
# define COMMA 263

# line 10 "lp.y"
#include "defines.h" 
#include "globals.h"

/* globals */
char Last_var[NAMELEN];
int Rows;
int Lin_term_count;
double f;
int x;
int Sign;
int isign; 	/* internal_sign variable to make sure nothing goes wrong */
		/* with lookahead */
int make_neg;	/* is true after the relational operator is seen in order */
		/* to rember if lin_term stands before or after re_op */
#define yyclearin yychar = -1
#define yyerrok yyerrflag = 0
extern int yychar;
extern int yyerrflag;
#ifndef YYMAXDEPTH
#define YYMAXDEPTH 150
#endif
#ifndef YYSTYPE
#define YYSTYPE int
#endif
YYSTYPE yylval, yyval;
# define YYERRCODE 256

# line 165 "lp.y"

# include "lex.yy.c"
int yyexca[] ={
-1, 1,
	0, -1,
	-2, 0,
-1, 26,
	257, 12,
	-2, 28,
	};
# define YYNPROD 32
# define YYLAST 69
int yyact[]={

    42,    28,     7,    15,    47,    41,    43,    16,    46,    28,
    17,    27,     7,    15,    13,    19,     7,     8,    20,    26,
    15,    13,     7,     8,     6,    36,    34,    32,    12,    14,
    11,    24,     5,    10,    30,    18,     4,    38,    29,    35,
    25,    23,    37,    22,    21,     9,     3,     2,    31,     1,
     0,     0,     0,     0,     0,    33,     0,     0,    39,     0,
    40,     0,     0,     0,     0,     0,     0,    45,    44 };
int yypact[]={

 -1000, -1000,  -235,  -245,  -252, -1000, -1000, -1000,  -242,  -238,
 -1000,  -250, -1000, -1000, -1000,  -242, -1000, -1000,  -241, -1000,
  -230, -1000, -1000,  -231, -1000,  -232, -1000, -1000, -1000,  -255,
  -241, -1000, -1000, -1000, -1000,  -257, -1000,  -245,  -255, -1000,
 -1000, -1000, -1000,  -249,  -258, -1000, -1000, -1000 };
int yypgo[]={

     0,    49,    47,    46,    45,    44,    33,    30,    42,    41,
    31,    40,    39,    28,    38,    37,    29,    36,    35,    34 };
int yyr1[]={

     0,     2,     1,     4,     4,     8,     6,     5,     5,     9,
     9,    10,    11,    12,    12,    12,     7,    14,     7,    15,
     7,    13,    13,    17,    18,    17,    19,    17,    16,    16,
    16,     3 };
int yyr2[]={

     0,     1,     8,     2,     4,     1,    11,     0,     2,     2,
     4,     6,     3,     3,     5,     7,     2,     1,     6,     1,
     8,     2,     3,     2,     1,     6,     1,     8,     3,     5,
     7,     5 };
int yychk[]={

 -1000,    -1,    -2,    -3,   -17,   -16,   259,   257,   258,    -4,
    -6,    -7,   -13,   259,   -16,   258,   259,   262,   -18,   257,
   260,    -5,    -6,    -9,   -10,   -11,   257,   261,   259,   -14,
   -19,   -16,   257,   -10,   257,   -12,   257,    -8,   -15,   -13,
   -16,   262,   257,   263,    -7,   -13,   257,   262 };
int yydef[]={

     1,    -2,     0,     0,     0,    23,    24,    28,     0,     7,
     3,     0,    16,    17,    21,    22,    26,    31,     0,    29,
     0,     2,     4,     8,     9,     0,    -2,     5,    19,     0,
     0,    25,    30,    10,    12,     0,    13,     0,     0,    18,
    27,    11,    14,     0,     0,    20,    15,     6 };
typedef struct { char *t_name; int t_val; } yytoktype;
#ifndef YYDEBUG
#	define YYDEBUG	0	/* don't allow debugging */
#endif

#if YYDEBUG

yytoktype yytoks[] =
{
	"VAR",	257,
	"CONS",	258,
	"SIGN",	259,
	"AR_M_OP",	260,
	"RE_OP",	261,
	"END_C",	262,
	"COMMA",	263,
	"-unknown-",	-1	/* ends search */
};

char * yyreds[] =
{
	"-no such reduction-",
	"inputfile : /* empty */",
	"inputfile : objective_function constraints int_declarations",
	"constraints : constraint",
	"constraints : constraints constraint",
	"constraint : x_lineair_sum RE_OP",
	"constraint : x_lineair_sum RE_OP x_lineair_sum END_C",
	"int_declarations : /* empty */",
	"int_declarations : real_int_decls",
	"real_int_decls : int_declaration",
	"real_int_decls : real_int_decls int_declaration",
	"int_declaration : int_declarator vars END_C",
	"int_declarator : VAR",
	"vars : VAR",
	"vars : vars VAR",
	"vars : vars COMMA VAR",
	"x_lineair_sum : x_lineair_term",
	"x_lineair_sum : SIGN",
	"x_lineair_sum : SIGN x_lineair_term",
	"x_lineair_sum : x_lineair_sum SIGN",
	"x_lineair_sum : x_lineair_sum SIGN x_lineair_term",
	"x_lineair_term : lineair_term",
	"x_lineair_term : CONS",
	"lineair_sum : lineair_term",
	"lineair_sum : SIGN",
	"lineair_sum : SIGN lineair_term",
	"lineair_sum : lineair_sum SIGN",
	"lineair_sum : lineair_sum SIGN lineair_term",
	"lineair_term : VAR",
	"lineair_term : CONS VAR",
	"lineair_term : CONS AR_M_OP VAR",
	"objective_function : lineair_sum END_C",
};
#endif /* YYDEBUG */
#line 1 "/usr/lib/yaccpar"
/*	@(#)yaccpar 1.10 89/04/04 SMI; from S5R3 1.10	*/

/*
** Skeleton parser driver for yacc output
*/

/*
** yacc user known macros and defines
*/
#define YYERROR		goto yyerrlab
#define YYACCEPT	{ free(yys); free(yyv); return(0); }
#define YYABORT		{ free(yys); free(yyv); return(1); }
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
** static variables used by the parser
*/
static YYSTYPE *yyv;			/* value stack */
static int *yys;			/* state stack */

static YYSTYPE *yypv;			/* top of value stack */
static int *yyps;			/* top of state stack */

static int yystate;			/* current state */
static int yytmp;			/* extra var (lasts between blocks) */

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
	unsigned yymaxdepth = YYMAXDEPTH;

	/*
	** Initialize externals - yyparse may be called more than once
	*/
	yyv = (YYSTYPE*)malloc(yymaxdepth*sizeof(YYSTYPE));
	yys = (int*)malloc(yymaxdepth*sizeof(int));
	if (!yyv || !yys)
	{
		yyerror( "out of memory" );
		return(1);
	}
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

			(void)printf( "State %d, token ", yy_state );
			if ( yychar == 0 )
				(void)printf( "end-of-file\n" );
			else if ( yychar < 0 )
				(void)printf( "-none-\n" );
			else
			{
				for ( yy_i = 0; yytoks[yy_i].t_val >= 0;
					yy_i++ )
				{
					if ( yytoks[yy_i].t_val == yychar )
						break;
				}
				(void)printf( "%s\n", yytoks[yy_i].t_name );
			}
		}
#endif /* YYDEBUG */
		if ( ++yy_ps >= &yys[ yymaxdepth ] )	/* room on stack? */
		{
			/*
			** reallocate and recover.  Note that pointers
			** have to be reset, or bad things will happen
			*/
			int yyps_index = (yy_ps - yys);
			int yypv_index = (yy_pv - yyv);
			int yypvt_index = (yypvt - yyv);
			yymaxdepth += YYMAXDEPTH;
			yyv = (YYSTYPE*)realloc((char*)yyv,
				yymaxdepth * sizeof(YYSTYPE));
			yys = (int*)realloc((char*)yys,
				yymaxdepth * sizeof(int));
			if (!yyv || !yys)
			{
				yyerror( "yacc stack overflow" );
				return(1);
			}
			yy_ps = yys + yyps_index;
			yy_pv = yyv + yypv_index;
			yypvt = yyv + yypvt_index;
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

			(void)printf( "Received token " );
			if ( yychar == 0 )
				(void)printf( "end-of-file\n" );
			else if ( yychar < 0 )
				(void)printf( "-none-\n" );
			else
			{
				for ( yy_i = 0; yytoks[yy_i].t_val >= 0;
					yy_i++ )
				{
					if ( yytoks[yy_i].t_val == yychar )
						break;
				}
				(void)printf( "%s\n", yytoks[yy_i].t_name );
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

				(void)printf( "Received token " );
				if ( yychar == 0 )
					(void)printf( "end-of-file\n" );
				else if ( yychar < 0 )
					(void)printf( "-none-\n" );
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
					(void)printf( "%s\n", yytoks[yy_i].t_name );
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
						(void)printf( _POP_, *yy_ps,
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

					(void)printf( "Error recovery discards " );
					if ( yychar == 0 )
						(void)printf( "token end-of-file\n" );
					else if ( yychar < 0 )
						(void)printf( "token -none-\n" );
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
						(void)printf( "token %s\n",
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
			(void)printf( "Reduce by (%d) \"%s\"\n",
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
		
case 1:
# line 32 "lp.y"
{
  init_read();
  isign = 0;
  make_neg = 0;
} break;
case 5:
# line 49 "lp.y"
{
  store_re_op();
  make_neg = 1; 
} break;
case 6:
# line 55 "lp.y"
{
  if(Lin_term_count == 0)
    
    {
      fprintf(stderr, "WARNING line %d: constraint contains no variables\n",
	      yylineno);
      null_tmp_store();
    }
  if(Lin_term_count  > 1)
    Rows++;
  if(Lin_term_count == 1)
    store_bounds();
  Lin_term_count = 0;
  isign = 0 ; make_neg = 0;
} break;
case 12:
# line 83 "lp.y"
{/* check_decl(yytext);*/} break;
case 13:
# line 86 "lp.y"
{add_int_var(yytext);} break;
case 14:
# line 87 "lp.y"
{add_int_var(yytext);} break;
case 15:
# line 88 "lp.y"
{add_int_var(yytext);} break;
case 17:
# line 93 "lp.y"
{
  isign = Sign; 
} break;
case 19:
# line 99 "lp.y"
{
  isign = Sign; 
} break;
case 22:
# line 107 "lp.y"
{
  if (isign ^ (!make_neg))
    f = -f;
  rhs_store(f);
  isign = 0;
} break;
case 24:
# line 117 "lp.y"
{
  isign = Sign;
} break;
case 26:
# line 123 "lp.y"
{
  isign = Sign;
} break;
case 28:
# line 130 "lp.y"
{
  if (isign ^ make_neg)
    var_store(Last_var, Rows, (double)-1);
  else
    var_store(Last_var, Rows, (double)1);
  isign = 0;
} break;
case 29:
# line 139 "lp.y"
{
  if (isign ^ make_neg)
    f = -f;
  var_store(Last_var, Rows, f);
  isign = 0;
} break;
case 30:
# line 148 "lp.y"
{
  if (isign ^ make_neg)
    f = -f;
  var_store(Last_var, Rows, f);
  isign = 0;
} break;
case 31:
# line 158 "lp.y"
{
  Rows++;
  Lin_term_count  =  0;
  isign = 0;
  make_neg = 0;
} break;
	}
	goto yystack;		/* reset registers in driver code */
}
