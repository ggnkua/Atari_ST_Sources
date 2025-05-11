
/*  A Bison parser, made from cexp.y  */

#define	INT	258
#define	CHAR	259
#define	NAME	260
#define	ERROR	261
#define	OR	262
#define	AND	263
#define	EQUAL	264
#define	NOTEQUAL	265
#define	LEQ	266
#define	GEQ	267
#define	LSH	268
#define	RSH	269
#define	UNARY	270

#line 109 "cexp.y"

#include "config.h"
#include <setjmp.h>
/* #define YYDEBUG 1 */

  int yylex ();
  void yyerror ();
  int expression_value;

  static jmp_buf parse_return_error;

  /* some external tables of character types */
  extern unsigned char is_idstart[], is_idchar[];


#line 125 "cexp.y"
typedef union {
  long lval;
  int voidval;
  char *sval;
} YYSTYPE;

#ifndef YYLTYPE
typedef
  struct yyltype
    {
      int timestamp;
      int first_line;
      int first_column;
      int last_line;
      int last_column;
      char *text;
   }
  yyltype;

#define YYLTYPE yyltype
#endif

#define	YYACCEPT	return(0)
#define	YYABORT	return(1)
#define	YYERROR	return(1)
#include <stdio.h>

#ifndef __STDC__
#define const
#endif



#define	YYFINAL		59
#define	YYFLAG		-32768
#define	YYNTBASE	33

#define YYTRANSLATE(x) ((unsigned)(x) <= 270 ? yytranslate[x] : 36)

static const char yytranslate[] = {     0,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,    29,     2,     2,     2,    27,    14,     2,    31,
    32,    25,    23,     9,    24,     2,    26,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     8,     2,    17,
     2,    18,     7,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,    13,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,    12,     2,    30,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     2,     2,     2,     2,     2,
     2,     2,     2,     2,     2,     1,     2,     3,     4,     5,
     6,    10,    11,    15,    16,    19,    20,    21,    22,    28
};

static const short yyrline[] = {     0,
   154,   159,   160,   165,   167,   169,   171,   176,   178,   180,
   182,   184,   186,   188,   190,   192,   194,   196,   198,   200,
   202,   204,   206,   208,   210,   212,   214,   216,   218
};

static const char * const yytname[] = {     0,
"error","$illegal.","INT","CHAR","NAME","ERROR","'?'","':'","','","OR",
"AND","'|'","'^'","'&'","EQUAL","NOTEQUAL","'<'","'>'","LEQ","GEQ",
"LSH","RSH","'+'","'-'","'*'","'/'","'%'","UNARY","'!'","'~'",
"'('","')'","start"
};

static const short yyr1[] = {     0,
    33,    34,    34,    35,    35,    35,    35,    35,    35,    35,
    35,    35,    35,    35,    35,    35,    35,    35,    35,    35,
    35,    35,    35,    35,    35,    35,    35,    35,    35
};

static const short yyr2[] = {     0,
     1,     1,     3,     2,     2,     2,     3,     3,     3,     3,
     3,     3,     3,     3,     3,     3,     3,     3,     3,     3,
     3,     3,     3,     3,     3,     5,     1,     1,     1
};

static const short yydefact[] = {     0,
    27,    28,    29,     0,     0,     0,     0,     1,     2,     4,
     5,     6,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     0,     0,     0,     0,     0,     0,     0,
     0,     0,     0,     7,     3,     0,    25,    24,    23,    22,
    21,    15,    16,    19,    20,    17,    18,    13,    14,    11,
    12,     8,     9,    10,     0,    26,     0,     0,     0
};

static const short yydefgoto[] = {    57,
     8,     9
};

static const short yypact[] = {    28,
-32768,-32768,-32768,    28,    28,    28,    28,    -3,    74,-32768,
-32768,-32768,    -2,    28,    28,    28,    28,    28,    28,    28,
    28,    28,    28,    28,    28,    28,    28,    28,    28,    28,
    28,    28,    28,-32768,    74,    53,    23,    90,   105,   119,
   132,   143,   143,   150,   150,   150,   150,   155,   155,   -22,
   -22,-32768,-32768,-32768,    28,    74,     8,     9,-32768
};

static const short yypgoto[] = {-32768,
    46,    -4
};


#define	YYLAST		182


static const short yytable[] = {    10,
    11,    12,    31,    32,    33,    14,    14,    58,    59,    35,
    36,    37,    38,    39,    40,    41,    42,    43,    44,    45,
    46,    47,    48,    49,    50,    51,    52,    53,    54,    34,
     1,     2,     3,    17,    18,    19,    20,    21,    22,    23,
    24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
    56,     4,    13,     0,     0,     0,     5,     6,     7,    15,
    55,     0,    16,    17,    18,    19,    20,    21,    22,    23,
    24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
    15,     0,     0,    16,    17,    18,    19,    20,    21,    22,
    23,    24,    25,    26,    27,    28,    29,    30,    31,    32,
    33,    18,    19,    20,    21,    22,    23,    24,    25,    26,
    27,    28,    29,    30,    31,    32,    33,    19,    20,    21,
    22,    23,    24,    25,    26,    27,    28,    29,    30,    31,
    32,    33,    20,    21,    22,    23,    24,    25,    26,    27,
    28,    29,    30,    31,    32,    33,    21,    22,    23,    24,
    25,    26,    27,    28,    29,    30,    31,    32,    33,    23,
    24,    25,    26,    27,    28,    29,    30,    31,    32,    33,
    27,    28,    29,    30,    31,    32,    33,    29,    30,    31,
    32,    33
};

static const short yycheck[] = {     4,
     5,     6,    25,    26,    27,     9,     9,     0,     0,    14,
    15,    16,    17,    18,    19,    20,    21,    22,    23,    24,
    25,    26,    27,    28,    29,    30,    31,    32,    33,    32,
     3,     4,     5,    11,    12,    13,    14,    15,    16,    17,
    18,    19,    20,    21,    22,    23,    24,    25,    26,    27,
    55,    24,     7,    -1,    -1,    -1,    29,    30,    31,     7,
     8,    -1,    10,    11,    12,    13,    14,    15,    16,    17,
    18,    19,    20,    21,    22,    23,    24,    25,    26,    27,
     7,    -1,    -1,    10,    11,    12,    13,    14,    15,    16,
    17,    18,    19,    20,    21,    22,    23,    24,    25,    26,
    27,    12,    13,    14,    15,    16,    17,    18,    19,    20,
    21,    22,    23,    24,    25,    26,    27,    13,    14,    15,
    16,    17,    18,    19,    20,    21,    22,    23,    24,    25,
    26,    27,    14,    15,    16,    17,    18,    19,    20,    21,
    22,    23,    24,    25,    26,    27,    15,    16,    17,    18,
    19,    20,    21,    22,    23,    24,    25,    26,    27,    17,
    18,    19,    20,    21,    22,    23,    24,    25,    26,    27,
    21,    22,    23,    24,    25,    26,    27,    23,    24,    25,
    26,    27
};
#define YYPURE 1

#line 2 "bison.simple"

/* Skeleton output parser for bison,
   copyright (C) 1984 Bob Corbett and Richard Stallman

		       NO WARRANTY

  BECAUSE THIS PROGRAM IS LICENSED FREE OF CHARGE, WE PROVIDE ABSOLUTELY
NO WARRANTY, TO THE EXTENT PERMITTED BY APPLICABLE STATE LAW.  EXCEPT
WHEN OTHERWISE STATED IN WRITING, FREE SOFTWARE FOUNDATION, INC,
RICHARD M. STALLMAN AND/OR OTHER PARTIES PROVIDE THIS PROGRAM "AS IS"
WITHOUT WARRANTY OF ANY KIND, EITHER EXPRESSED OR IMPLIED, INCLUDING,
BUT NOT LIMITED TO, THE IMPLIED WARRANTIES OF MERCHANTABILITY AND
FITNESS FOR A PARTICULAR PURPOSE.  THE ENTIRE RISK AS TO THE QUALITY
AND PERFORMANCE OF THE PROGRAM IS WITH YOU.  SHOULD THE PROGRAM PROVE
DEFECTIVE, YOU ASSUME THE COST OF ALL NECESSARY SERVICING, REPAIR OR
CORRECTION.

 IN NO EVENT UNLESS REQUIRED BY APPLICABLE LAW WILL RICHARD M.
STALLMAN, THE FREE SOFTWARE FOUNDATION, INC., AND/OR ANY OTHER PARTY
WHO MAY MODIFY AND REDISTRIBUTE THIS PROGRAM AS PERMITTED BELOW, BE
LIABLE TO YOU FOR DAMAGES, INCLUDING ANY LOST PROFITS, LOST MONIES, OR
OTHER SPECIAL, INCIDENTAL OR CONSEQUENTIAL DAMAGES ARISING OUT OF THE
USE OR INABILITY TO USE (INCLUDING BUT NOT LIMITED TO LOSS OF DATA OR
DATA BEING RENDERED INACCURATE OR LOSSES SUSTAINED BY THIRD PARTIES OR
A FAILURE OF THE PROGRAM TO OPERATE WITH ANY OTHER PROGRAMS) THIS
PROGRAM, EVEN IF YOU HAVE BEEN ADVISED OF THE POSSIBILITY OF SUCH
DAMAGES, OR FOR ANY CLAIM BY ANY OTHER PARTY.

		GENERAL PUBLIC LICENSE TO COPY

  1. You may copy and distribute verbatim copies of this source file
as you receive it, in any medium, provided that you conspicuously and
appropriately publish on each copy a valid copyright notice "Copyright
(C) 1985 Free Software Foundation, Inc."; and include following the
copyright notice a verbatim copy of the above disclaimer of warranty
and of this License.  You may charge a distribution fee for the
physical act of transferring a copy.

  2. You may modify your copy or copies of this source file or
any portion of it, and copy and distribute such modifications under
the terms of Paragraph 1 above, provided that you also do the following:

    a) cause the modified files to carry prominent notices stating
    that you changed the files and the date of any change; and

    b) cause the whole of any work that you distribute or publish,
    that in whole or in part contains or is a derivative of this
    program or any part thereof, to be licensed at no charge to all
    third parties on terms identical to those contained in this
    License Agreement (except that you may choose to grant more extensive
    warranty protection to some or all third parties, at your option).

    c) You may charge a distribution fee for the physical act of
    transferring a copy, and you may at your option offer warranty
    protection in exchange for a fee.

Mere aggregation of another unrelated program with this program (or its
derivative) on a volume of a storage or distribution medium does not bring
the other program under the scope of these terms.

  3. You may copy and distribute this program (or a portion or derivative
of it, under Paragraph 2) in object code or executable form under the terms
of Paragraphs 1 and 2 above provided that you also do one of the following:

    a) accompany it with the complete corresponding machine-readable
    source code, which must be distributed under the terms of
    Paragraphs 1 and 2 above; or,

    b) accompany it with a written offer, valid for at least three
    years, to give any third party free (except for a nominal
    shipping charge) a complete machine-readable copy of the
    corresponding source code, to be distributed under the terms of
    Paragraphs 1 and 2 above; or,

    c) accompany it with the information you received as to where the
    corresponding source code may be obtained.  (This alternative is
    allowed only for noncommercial distribution and only if you
    received the program in object code or executable form alone.)

For an executable file, complete source code means all the source code for
all modules it contains; but, as a special exception, it need not include
source code for modules which are standard libraries that accompany the
operating system on which the executable file runs.

  4. You may not copy, sublicense, distribute or transfer this program
except as expressly provided under this License Agreement.  Any attempt
otherwise to copy, sublicense, distribute or transfer this program is void and
your rights to use the program under this License agreement shall be
automatically terminated.  However, parties who have received computer
software programs from you with this License Agreement will not have
their licenses terminated so long as such parties remain in full compliance.

  5. If you wish to incorporate parts of this program into other free
programs whose distribution conditions are different, write to the Free
Software Foundation at 675 Mass Ave, Cambridge, MA 02139.  We have not yet
worked out a simple rule that can be stated here, but we will often permit
this.  We will be guided by the two goals of preserving the free status of
all derivatives of our free software and of promoting the sharing and reuse of
software.


In other words, you are welcome to use, share and improve this program.
You are forbidden to forbid anyone else to use, share and improve
what you give them.   Help stamp out software-hoarding!  */

/* This is the parser code that is written into each bison parser
  when the %semantic_parser declaration is not specified in the grammar.
  It was written by Richard Stallman by simplifying the hairy parser
  used when %semantic_parser is specified.  */

/* Note: there must be only one dollar sign in this file.
   It is replaced by the list of actions, each action
   as one case of the switch.  */

#define yyerrok		(yyerrstatus = 0)
#define yyclearin	(yychar = YYEMPTY)
#define YYEMPTY		-2
#define YYEOF		0
#define YYFAIL		goto yyerrlab;

#define YYTERROR	1

#ifndef YYIMPURE
#define YYLEX		yylex()
#endif

#ifndef YYPURE
#define YYLEX		yylex(&yylval, &yylloc)
#endif

/* If nonreentrant, generate the variables here */

#ifndef YYIMPURE

int	yychar;			/*  the lookahead symbol		*/
YYSTYPE	yylval;			/*  the semantic value of the		*/
				/*  lookahead symbol			*/

YYLTYPE yylloc;			/*  location data for the lookahead	*/
				/*  symbol				*/

int yynerr;			/*  number of parse errors so far       */

#ifdef YYDEBUG
int yydebug = 0;		/*  nonzero means print parse trace	*/
#endif

#endif  /* YYIMPURE */


/*  YYMAXDEPTH indicates the initial size of the parser's stacks	*/

#ifndef	YYMAXDEPTH
#define YYMAXDEPTH 200
#endif

/*  YYMAXLIMIT is the maximum size the stacks can grow to
    (effective only if the built-in stack extension method is used).  */

#ifndef YYMAXLIMIT
#define YYMAXLIMIT 10000
#endif


#line 165 "bison.simple"
int
yyparse()
{
  register int yystate;
  register int yyn;
  register short *yyssp;
  register YYSTYPE *yyvsp;
  YYLTYPE *yylsp;
  int yyerrstatus;	/*  number of tokens to shift before error messages enabled */
  int yychar1;		/*  lookahead token as an internal (translated) token number */

  short	yyssa[YYMAXDEPTH];	/*  the state stack			*/
  YYSTYPE yyvsa[YYMAXDEPTH];	/*  the semantic value stack		*/
  YYLTYPE yylsa[YYMAXDEPTH];	/*  the location stack			*/

  short *yyss = yyssa;		/*  refer to the stacks thru separate pointers */
  YYSTYPE *yyvs = yyvsa;	/*  to allow yyoverflow to reallocate them elsewhere */
  YYLTYPE *yyls = yylsa;

  int yymaxdepth = YYMAXDEPTH;

#ifndef YYPURE
  int yychar;
  YYSTYPE yylval;
  YYLTYPE yylloc;
#endif

#ifdef YYDEBUG
  extern int yydebug;
#endif


  YYSTYPE yyval;		/*  the variable used to return		*/
				/*  semantic values from the action	*/
				/*  routines				*/

  int yylen;

#ifdef YYDEBUG
  if (yydebug)
    fprintf(stderr, "Starting parse\n");
#endif

  yystate = 0;
  yyerrstatus = 0;
  yynerr = 0;
  yychar = YYEMPTY;		/* Cause a token to be read.  */

  /* Initialize stack pointers.
     Waste one element of value and location stack
     so that they stay on the same level as the state stack.  */

  yyssp = yyss - 1;
  yyvsp = yyvs;
  yylsp = yyls;

/* Push a new state, which is found in  yystate  .  */
/* In all cases, when you get here, the value and location stacks
   have just been pushed. so pushing a state here evens the stacks.  */
yynewstate:

  *++yyssp = yystate;

  if (yyssp >= yyss + yymaxdepth - 1)
    {
      /* Give user a chance to reallocate the stack */
      /* Use copies of these so that the &'s don't force the real ones into memory. */
      YYSTYPE *yyvs1 = yyvs;
      YYLTYPE *yyls1 = yyls;
      short *yyss1 = yyss;

      /* Get the current used size of the three stacks, in elements.  */
      int size = yyssp - yyss + 1;

#ifdef yyoverflow
      /* Each stack pointer address is followed by the size of
	 the data in use in that stack, in bytes.  */
      yyoverflow("parser stack overflow",
		 &yyss1, size * sizeof (*yyssp),
		 &yyvs1, size * sizeof (*yyvsp),
		 &yyls1, size * sizeof (*yylsp),
		 &yymaxdepth);

      yyss = yyss1; yyvs = yyvs1; yyls = yyls1;
#else /* no yyoverflow */
      /* Extend the stack our own way.  */
      if (yymaxdepth >= YYMAXLIMIT)
	yyerror("parser stack overflow");
      yymaxdepth *= 2;
      if (yymaxdepth > YYMAXLIMIT)
	yymaxdepth = YYMAXLIMIT;
      yyss = (short *) alloca (yymaxdepth * sizeof (*yyssp));
      bcopy ((char *)yyss1, (char *)yyss, size * sizeof (*yyssp));
      yyvs = (YYSTYPE *) alloca (yymaxdepth * sizeof (*yyvsp));
      bcopy ((char *)yyvs1, (char *)yyvs, size * sizeof (*yyvsp));
#ifdef YYLSP_NEEDED
      yyls = (YYLTYPE *) alloca (yymaxdepth * sizeof (*yylsp));
      bcopy ((char *)yyls1, (char *)yyls, size * sizeof (*yylsp));
#endif
#endif /* no yyoverflow */

      yyssp = yyss + size - 1;
      yyvsp = yyvs + size - 1;
#ifdef YYLSP_NEEDED
      yylsp = yyls + size - 1;
#endif

#ifdef YYDEBUG
      if (yydebug)
	fprintf(stderr, "Stack size increased to %d\n", yymaxdepth);
#endif

      if (yyssp >= yyss + yymaxdepth - 1)
	YYERROR;
    }

#ifdef YYDEBUG
  if (yydebug)
    fprintf(stderr, "Entering state %d\n", yystate);
#endif

/* Do appropriate processing given the current state.  */
/* Read a lookahead token if we need one and don't already have one.  */
yyresume:

  /* First try to decide what to do without reference to lookahead token.  */

  yyn = yypact[yystate];
  if (yyn == YYFLAG)
    goto yydefault;

  /* Not known => get a lookahead token if don't already have one.  */

  /* yychar is either YYEMPTY or YYEOF
     or a valid token in external form.  */

  if (yychar == YYEMPTY)
    {
#ifdef YYDEBUG
      if (yydebug)
	fprintf(stderr, "Reading a token: ");
#endif
      yychar = YYLEX;
    }

  /* Convert token to internal form (in yychar1) for indexing tables with */

  if (yychar <= 0)		/* This means end of input. */
    {
      yychar1 = 0;
      yychar = YYEOF;		/* Don't call YYLEX any more */

#ifdef YYDEBUG
      if (yydebug)
	fprintf(stderr, "Now at end of input.\n");
#endif
    }
  else
    {
      yychar1 = YYTRANSLATE(yychar);

#ifdef YYDEBUG
      if (yydebug)
	fprintf(stderr, "Next token is %d (%s)\n", yychar, yytname[yychar1]);
#endif
    }

  yyn += yychar1;
  if (yyn < 0 || yyn > YYLAST || yycheck[yyn] != yychar1)
    goto yydefault;

  yyn = yytable[yyn];

  /* yyn is what to do for this token type in this state.
     Negative => reduce, -yyn is rule number.
     Positive => shift, yyn is new state.
       New state is final state => don't bother to shift,
       just return success.
     0, or most negative number => error.  */

  if (yyn < 0)
    {
      if (yyn == YYFLAG)
	goto yyerrlab;
      yyn = -yyn;
      goto yyreduce;
    }
  else if (yyn == 0)
    goto yyerrlab;

  if (yyn == YYFINAL)
    YYACCEPT;

  /* Shift the lookahead token.  */

#ifdef YYDEBUG
  if (yydebug)
    fprintf(stderr, "Shifting token %d (%s), ", yychar, yytname[yychar1]);
#endif

  /* Discard the token being shifted unless it is eof.  */
  if (yychar != YYEOF)
    yychar = YYEMPTY;

  *++yyvsp = yylval;
#ifdef YYLSP_NEEDED
  *++yylsp = yylloc;
#endif

  /* count tokens shifted since error; after three, turn off error status.  */
  if (yyerrstatus) yyerrstatus--;

  yystate = yyn;
  goto yynewstate;

/* Do the default action for the current state.  */
yydefault:

  yyn = yydefact[yystate];
  if (yyn == 0)
    goto yyerrlab;

/* Do a reduction.  yyn is the number of a rule to reduce with.  */
yyreduce:
  yylen = yyr2[yyn];
  yyval = yyvsp[1-yylen]; /* implement default value of the action */

#ifdef YYDEBUG
  if (yydebug)
    {
      if (yylen == 1)
	fprintf (stderr, "Reducing 1 value via line %d, ",
		 yyrline[yyn]);
      else
	fprintf (stderr, "Reducing %d values via line %d, ",
		 yylen, yyrline[yyn]);
    }
#endif


  switch (yyn) {

case 1:
#line 155 "cexp.y"
{ expression_value = yyvsp[0].lval; ;
    break;}
case 3:
#line 161 "cexp.y"
{ yyval.lval = yyvsp[0].lval; ;
    break;}
case 4:
#line 166 "cexp.y"
{ yyval.lval = - yyvsp[0].lval; ;
    break;}
case 5:
#line 168 "cexp.y"
{ yyval.lval = ! yyvsp[0].lval; ;
    break;}
case 6:
#line 170 "cexp.y"
{ yyval.lval = ~ yyvsp[0].lval; ;
    break;}
case 7:
#line 172 "cexp.y"
{ yyval.lval = yyvsp[-1].lval; ;
    break;}
case 8:
#line 177 "cexp.y"
{ yyval.lval = yyvsp[-2].lval * yyvsp[0].lval; ;
    break;}
case 9:
#line 179 "cexp.y"
{ yyval.lval = yyvsp[-2].lval / yyvsp[0].lval; ;
    break;}
case 10:
#line 181 "cexp.y"
{ yyval.lval = yyvsp[-2].lval % yyvsp[0].lval; ;
    break;}
case 11:
#line 183 "cexp.y"
{ yyval.lval = yyvsp[-2].lval + yyvsp[0].lval; ;
    break;}
case 12:
#line 185 "cexp.y"
{ yyval.lval = yyvsp[-2].lval - yyvsp[0].lval; ;
    break;}
case 13:
#line 187 "cexp.y"
{ yyval.lval = yyvsp[-2].lval << yyvsp[0].lval; ;
    break;}
case 14:
#line 189 "cexp.y"
{ yyval.lval = yyvsp[-2].lval >> yyvsp[0].lval; ;
    break;}
case 15:
#line 191 "cexp.y"
{ yyval.lval = (yyvsp[-2].lval == yyvsp[0].lval); ;
    break;}
case 16:
#line 193 "cexp.y"
{ yyval.lval = (yyvsp[-2].lval != yyvsp[0].lval); ;
    break;}
case 17:
#line 195 "cexp.y"
{ yyval.lval = (yyvsp[-2].lval <= yyvsp[0].lval); ;
    break;}
case 18:
#line 197 "cexp.y"
{ yyval.lval = (yyvsp[-2].lval >= yyvsp[0].lval); ;
    break;}
case 19:
#line 199 "cexp.y"
{ yyval.lval = (yyvsp[-2].lval < yyvsp[0].lval); ;
    break;}
case 20:
#line 201 "cexp.y"
{ yyval.lval = (yyvsp[-2].lval > yyvsp[0].lval); ;
    break;}
case 21:
#line 203 "cexp.y"
{ yyval.lval = (yyvsp[-2].lval & yyvsp[0].lval); ;
    break;}
case 22:
#line 205 "cexp.y"
{ yyval.lval = (yyvsp[-2].lval ^ yyvsp[0].lval); ;
    break;}
case 23:
#line 207 "cexp.y"
{ yyval.lval = (yyvsp[-2].lval | yyvsp[0].lval); ;
    break;}
case 24:
#line 209 "cexp.y"
{ yyval.lval = (yyvsp[-2].lval && yyvsp[0].lval); ;
    break;}
case 25:
#line 211 "cexp.y"
{ yyval.lval = (yyvsp[-2].lval || yyvsp[0].lval); ;
    break;}
case 26:
#line 213 "cexp.y"
{ yyval.lval = yyvsp[-4].lval ? yyvsp[-2].lval : yyvsp[0].lval; ;
    break;}
case 27:
#line 215 "cexp.y"
{ yyval.lval = yylval.lval; ;
    break;}
case 28:
#line 217 "cexp.y"
{ yyval.lval = yylval.lval; ;
    break;}
case 29:
#line 219 "cexp.y"
{ yyval.lval = 0; ;
    break;}
}
   /* the action file gets copied in in place of this dollarsign */
#line 303 "bison.simple"

  yyvsp -= yylen;
  yyssp -= yylen;
#ifdef YYLSP_NEEDED
  yylsp -= yylen;
#endif

#ifdef YYDEBUG
  if (yydebug)
    {
      short *ssp1 = yyss - 1;
      fprintf (stderr, "state stack now", yyssp-yyss);
      while (ssp1 != yyssp)
	fprintf (stderr, " %d", *++ssp1);
      fprintf (stderr, "\n");
    }
#endif

  *++yyvsp = yyval;

#ifdef YYLSP_NEEDED
  yylsp++;
  if (yylen == 0)
    {
      yylsp->first_line = yylloc.first_line;
      yylsp->first_column = yylloc.first_column;
      yylsp->last_line = (yylsp-1)->last_line;
      yylsp->last_column = (yylsp-1)->last_column;
      yylsp->text = 0;
    }
  else
    {
      yylsp->last_line = (yylsp+yylen-1)->last_line;
      yylsp->last_column = (yylsp+yylen-1)->last_column;
    }
#endif

  /* Now "shift" the result of the reduction.
     Determine what state that goes to,
     based on the state we popped back to
     and the rule number reduced by.  */

  yyn = yyr1[yyn];

  yystate = yypgoto[yyn - YYNTBASE] + *yyssp;
  if (yystate >= 0 && yystate <= YYLAST && yycheck[yystate] == *yyssp)
    yystate = yytable[yystate];
  else
    yystate = yydefgoto[yyn - YYNTBASE];

  goto yynewstate;

yyerrlab:   /* here on detecting error */

  if (! yyerrstatus)
    /* If not already recovering from an error, report this error.  */
    {
      ++yynerr;
      yyerror("parse error");
    }

  if (yyerrstatus == 3)
    {
      /* if just tried and failed to reuse lookahead token after an error, discard it.  */

      /* return failure if at end of input */
      if (yychar == YYEOF)
	YYERROR;

#ifdef YYDEBUG
      if (yydebug)
	fprintf(stderr, "Discarding token %d (%s).\n", yychar, yytname[yychar1]);
#endif

      yychar = YYEMPTY;
    }

  /* Else will try to reuse lookahead token
     after shifting the error token.  */

  yyerrstatus = 3;		/* Each real token shifted decrements this */

  goto yyerrhandle;

yyerrdefault:  /* current state does not do anything special for the error token. */

#if 0
  /* This is wrong; only states that explicitly want error tokens
     should shift them.  */
  yyn = yydefact[yystate];  /* If its default is to accept any token, ok.  Otherwise pop it.*/
  if (yyn) goto yydefault;
#endif

yyerrpop:   /* pop the current state because it cannot handle the error token */

  if (yyssp == yyss) YYERROR;
  yyvsp--;
  yystate = *--yyssp;
#ifdef YYLSP_NEEDED
  yylsp--;
#endif

#ifdef YYDEBUG
  if (yydebug)
    {
      short *ssp1 = yyss - 1;
      fprintf (stderr, "Error: state stack now", yyssp-yyss);
      while (ssp1 != yyssp)
	fprintf (stderr, " %d", *++ssp1);
      fprintf (stderr, "\n");
    }
#endif

yyerrhandle:

  yyn = yypact[yystate];
  if (yyn == YYFLAG)
    goto yyerrdefault;

  yyn += YYTERROR;
  if (yyn < 0 || yyn > YYLAST || yycheck[yyn] != YYTERROR)
    goto yyerrdefault;

  yyn = yytable[yyn];
  if (yyn < 0)
    {
      if (yyn == YYFLAG)
	goto yyerrpop;
      yyn = -yyn;
      goto yyreduce;
    }
  else if (yyn == 0)
    goto yyerrpop;

  if (yyn == YYFINAL)
    YYACCEPT;

#ifdef YYDEBUG
  if (yydebug)
    fprintf(stderr, "Shifting error token, ");
#endif

  *++yyvsp = yylval;
#ifdef YYLSP_NEEDED
  *++yylsp = yylloc;
#endif

  yystate = yyn;
  goto yynewstate;
}
#line 221 "cexp.y"


/* During parsing of a C expression, the pointer to the next character
   is in this variable.  */

static char *lexptr;

/* Take care of parsing a number (anything that starts with a digit).
   Set yylval and return the token type; update lexptr.
   LEN is the number of characters in it.  */

/* maybe needs to actually deal with floating point numbers */

int
parse_number (olen)
     int olen;
{
  register char *p = lexptr;
  register long n = 0;
  register int c;
  register int base = 10;
  register len = olen;
  char *err_copy;

  extern double atof ();

  for (c = 0; c < len; c++)
    if (p[c] == '.') {
      /* It's a float since it contains a point.  */
      yyerror ("floating point numbers not allowed in #if expressions");
      return ERROR;
      
/* ****************
	 yylval.dval = atof (p);
	 lexptr += len;
	 return FLOAT;
		 ****************  */
    }
  
  if (len >= 3 && (!strncmp (p, "0x", 2) || !strncmp (p, "0X", 2))) {
    p += 2;
    base = 16;
    len -= 2;
  }
  else if (*p == '0')
    base = 8;
  
  while (len-- > 0) {
    c = *p++;
    n *= base;
    if (c >= '0' && c <= '9')
      n += c - '0';
    else {
      if (c >= 'A' && c <= 'Z') c += 'a' - 'A';
      if (base == 16 && c >= 'a' && c <= 'f')
	n += c - 'a' + 10;
      else if (len == 0 && c == 'l')
	;
      else {
	yyerror ("Invalid number in #if expression");
	return ERROR;
      }
    }
  }

  lexptr = p;
  yylval.lval = n;
  return INT;
}

struct token {
  char *operator;
  int token;
};


static struct token tokentab2[] = {
  {"&&", AND},
  {"||", OR},
  {"<<", LSH},
  {">>", RSH},
  {"==", EQUAL},
  {"!=", NOTEQUAL},
  {"<=", LEQ},
  {">=", GEQ},
  {NULL, ERROR}
};

/* Read one token, getting characters through lexptr.  */

int
yylex ()
{
  register int c;
  register int namelen;
  register char *tokstart;
  register struct token *toktab;

 retry:

  tokstart = lexptr;
  c = *tokstart;
  /* See if it is a special token of length 2.  */
  for (toktab = tokentab2; toktab->operator != NULL; toktab++)
    if (c == *toktab->operator && tokstart[1] == toktab->operator[1]) {
      lexptr += 2;
      return toktab->token;
    }

  switch (c) {
  case 0:
    return 0;
    
  case ' ':
  case '\t':
  case '\n':
    lexptr++;
    goto retry;
    
  case '\'':
    lexptr++;
    c = *lexptr++;
    if (c == '\\')
      c = parse_escape (&lexptr);
    yylval.lval = c;
    c = *lexptr++;
    if (c != '\'') {
      yyerror ("Invalid character constant in #if");
      return ERROR;
    }
    
    return CHAR;

    /* some of these chars are invalid in constant expressions;
       maybe do something about them later */
  case '/':
  case '+':
  case '-':
  case '*':
  case '%':
  case '|':
  case '&':
  case '^':
  case '~':
  case '!':
  case '@':
  case '<':
  case '>':
  case '(':
  case ')':
  case '[':
  case ']':
  case '.':
  case '?':
  case ':':
  case '=':
  case '{':
  case '}':
  case ',':
    lexptr++;
    return c;
    
  case '"':
    yyerror ("double quoted strings not allowed in #if expressions");
    return ERROR;
  }
  if (c >= '0' && c <= '9') {
    /* It's a number */
    for (namelen = 0;
	 c = tokstart[namelen], is_idchar[c] || c == '.'; 
	 namelen++)
      ;
    return parse_number (namelen);
  }
  
  if (!is_idstart[c]) {
    yyerror ("Invalid token in expression");
    return ERROR;
  }
  
  /* It is a name.  See how long it is.  */
  
  for (namelen = 0; is_idchar[tokstart[namelen]]; namelen++)
    ;
  
  lexptr += namelen;
  return NAME;
}


/* Parse a C escape sequence.  STRING_PTR points to a variable
   containing a pointer to the string to parse.  That pointer
   is updated past the characters we use.  The value of the
   escape sequence is returned.

   A negative value means the sequence \ newline was seen,
   which is supposed to be equivalent to nothing at all.

   If \ is followed by a null character, we return a negative
   value and leave the string pointer pointing at the null character.

   If \ is followed by 000, we return 0 and leave the string pointer
   after the zeros.  A value of 0 does not mean end of string.  */

int
parse_escape (string_ptr)
     char **string_ptr;
{
  register int c = *(*string_ptr)++;
  switch (c)
    {
    case 'a':
      return '\a';
    case 'b':
      return '\b';
    case 'e':
      return 033;
    case 'f':
      return '\f';
    case 'n':
      return '\n';
    case 'r':
      return '\r';
    case 't':
      return '\t';
    case 'v':
      return '\v';
    case '\n':
      return -2;
    case 0:
      (*string_ptr)--;
      return 0;
    case '^':
      c = *(*string_ptr)++;
      if (c == '\\')
	c = parse_escape (string_ptr);
      if (c == '?')
	return 0177;
      return (c & 0200) | (c & 037);
      
    case '0':
    case '1':
    case '2':
    case '3':
    case '4':
    case '5':
    case '6':
    case '7':
      {
	register int i = c - '0';
	register int count = 0;
	while (++count < 3)
	  {
	    if ((c = *(*string_ptr)++) >= '0' && c <= '7')
	      {
		i *= 8;
		i += c - '0';
	      }
	    else
	      {
		(*string_ptr)--;
		break;
	      }
	  }
	return i;
      }
    default:
      return c;
    }
}

void
yyerror (s)
     char *s;
{
  error (s);
  longjmp (parse_return_error, 1);
}

/* This page contains the entry point to this file.  */

/* Parse STRING as an expression, and complain if this fails
   to use up all of the contents of STRING.  */
/* We do not support C comments.  They should be removed before
   this function is called.  */

int
parse_c_expression (string)
     char *string;
{
  lexptr = string;
  
  if (lexptr == 0 || *lexptr == 0) {
    error ("empty #if expression");
    return 0;			/* don't include the #if group */
  }

  /* if there is some sort of scanning error, just return 0 and assume
     the parsing routine has printed an error message somewhere.
     there is surely a better thing to do than this.     */
  if (setjmp(parse_return_error))
    return 0;

  if (yyparse ())
    return 0;			/* actually this is never reached
				   the way things stand. */
  if (*lexptr)
    error ("Junk after end of expression.");

  return expression_value;	/* set by yyparse() */
}

#ifdef TEST_EXP_READER
/* main program, for testing purposes. */
main()
{
  int n;
  char buf[1024];
  extern int yydebug;
/*
  yydebug = 1;
*/
  initialize_random_junk ();

  for (;;) {
    printf("enter expression: ");
    n = 0;
    while ((buf[n] = getchar()) != '\n')
      n++;
    buf[n] = '\0';
    printf("parser returned %d\n", parse_c_expression(buf));
  }
}

/* table to tell if char can be part of a C identifier. */
char is_idchar[256];
/* table to tell if char can be first char of a c identifier. */
char is_idstart[256];
/* table to tell if c is horizontal space.  isspace() thinks that
   newline is space; this is not a good idea for this program. */
char is_hor_space[256];

/*
 * initialize random junk in the hash table and maybe other places
 */
initialize_random_junk()
{
  register int i;

  /*
   * Set up is_idchar and is_idstart tables.  These should be
   * faster than saying (is_alpha(c) || c == '_'), etc.
   * Must do set up these things before calling any routines tthat
   * refer to them.
   */
  for (i = 'a'; i <= 'z'; i++) {
    ++is_idchar[i - 'a' + 'A'];
    ++is_idchar[i];
    ++is_idstart[i - 'a' + 'A'];
    ++is_idstart[i];
  }
  for (i = '0'; i <= '9'; i++)
    ++is_idchar[i];
  ++is_idchar['_'];
  ++is_idstart['_'];
#ifdef DOLLARS_IN_IDENTIFIERS
  ++is_idchar['$'];
  ++is_idstart['$'];
#endif

  /* horizontal space table */
  ++is_hor_space[' '];
  ++is_hor_space['\t'];
}

error (msg)
{
  printf("error: %s\n", msg);
}
#endif
