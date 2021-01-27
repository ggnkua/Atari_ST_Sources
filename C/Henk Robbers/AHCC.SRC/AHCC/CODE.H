/* Copyright (c) 1988,1989 by Sozobon, Limited.  Author: Johann Ruegg
 *           (c) 1990 - present by H. Robbers.   ANSI upgrade.
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/*
 *	code.h
 */

#if C_DEBUG
	#define H(s) "\t;\t" #s
#else
	#define H(s)
#endif

typedef struct mtbl
{
	ulong
		restr;
	ushort
		needregs,
		needd,
		needa;
	Cstr template;
} MTBL;

typedef struct bop
{
	Cstr op;
	ushort opflags;
} BOPS;

/* restrictions for cando() */
/* Pure C cant handle long enums. */
#define LISTMP		0x00001L
#define RISTMP		0x00002L
#define NDASSOC		0x00004L
#define CANRL		0x00008L
#define CANLR		0x00010L
#define CANRD		0x00020L
#define CANDL		0x00040L
#define CANLD		0x00080L
#define CANDD		0x00100L
#define CANDR		0x00200L
#define CANIM		0x00400L
#define LISREGVAR	0x00800L
#define RISREGVAR	0x01000L
#define LISREG		0x02000L
#define RISREG		0x04000L
#define CANRM		0x08000L
#define CANLM		0x10000L
#define CANLRM		0x20000L
#define CANRLM		0x40000L
#define CANAI		0x80000L
#define CAN3Q		0x100000L

#define CANM (CANLM|CANRM)

/*
 *	defines of allowed operands
 *	'E' means Dreg or OREG or ONAME or (if on left) IMMediate
 *	'Q' means ICON which is 1 to 8
 *	ONE means ICON which is 1
 */

#define DopD	1
#define AopD	2
#define MopD	4
#define IopD	8

#define DopA	0x10
#define AopA	0x20
#define MopA	0x40
#define IopA	0x80

#define DopM	0x100
#define AopM	0x200
#define MopM	0x400
#define IopM	0x800

#define QopD	0x1000
#define ONEopM	0x2000
#define ASSOC	0x4000
#define REAL	0x8000

/* operand flags catagories*/
#define EopD	(DopD|MopD|IopD)
#define DopE	(DopD|DopM)
#define IopE	(IopD|IopM)
#define EopA	(DopA|MopA|IopA)

#if FLOAT

/* These are for the FPU (main difference is the association of the
	S (with < or >) so that we dont need ANY casting AT ALL.
	a fp reg is allways .x the source determines S */
#if COLDFIRE
/* 06'11 HR: must split CANM in left and right */
staticMTBL tblf2[] =
{
	{LISTMP|CANRL|		  CANRM, RETLEFT, 0,0,	"\tNx>S\t<A\t>A" H(tblf2 1) "\n"					},
	{LISTMP|CANRL,				 RETLEFT, 0,1,	"\tlmx \tR1\t>A\n\tNx>S\t<A\tR1." H(tblf2 1f) "\n"	},

	{RISTMP|CANLR|NDASSOC|CANLM, RETRIGHT,0,0,	"\tNx<S\t>A\t<A" H(tblf2 2) "\n"					},
	{RISTMP|CANLR|NDASSOC,		 RETRIGHT,0,1,	"\tlmx \tR1\t<A\n\tNx<S\t>A\tR1." H(tblf2 2f) "\n"	},

	{CANRD|				  CANM,  RETDREG, 0,0,	"\tldx<S\tA\t<A\n\tNx>S\tA\t>A" H(tblf2 3) "\n"		},
	{CANRD|				  CANLRM,RETDREG, 0,1,	"\tlmx  \tR1\t<A\n"
												"\tldx<S\tA\tR1.\n\tNx>S\tA\t>A" H(tblf2 3l) "\n"	},
	{CANRD|				  CANRLM,RETDREG, 0,1,	"\tlmx  \tR1\t>A\n"
												"\tldx<S\tA\t<A\n\tNx>S\tA\tR1." H(tblf2 3r) "\n"	},
	{CANRD,						 RETDREG, 0,1,	"\tlmx  \tR1\t<A\n\tldx<S\tA\tR1.\n"
	                                            "\tlmx  \tR1\t>A\n\tNx>S\tA\tR1." H(tblf2 3rl) "\n"	},

	{CANLD|NDASSOC|       CANLM, RETDREG, 0,0,	"\tldx>S\tA\t>A\n\tNx>S\tA\t<A" H(tblf2 4) "\n"		},
	{CANLD|NDASSOC|       CANLRM,RETDREG, 0,1,	"\tlmx  \tR1\t<A\n"
	                                            "\tldx>S\tA\tR1.\n\tNx>S\tA\t>A" H(tblf2 4l) "\n"	},
	{CANLD|NDASSOC|       CANRLM,RETDREG, 0,1,	"\tlmx  \tR1\t>A\n"
	                                            "\tldx>S\tA\tR1.\n\tNx>S\tA\tR1." H(tblf2 4r) "\n"	},
	{CANLD|NDASSOC,				 RETDREG, 0,1,	"\tlmx  \tR1\t>A\n\tldx>S\tA\tR1.\n"
	                                            "\tlmx  \tR1\t<A\n\tNx>S\tA\tR1." H(tblf2 4rl) "\n"	},
	{0}
};
#else
staticMTBL tblf2[] =
{
	{LISTMP|CANRL,			RETLEFT, 0,0,	"\tNx>S\t<A\t>A" H(tblf2 1) "\n"				},
	{RISTMP|CANLR|NDASSOC,	RETRIGHT,0,0,	"\tNx<S\t>A\t<A" H(tblf2 2) "\n"				},
	{CANRD,					RETDREG, 0,0,	"\tldx<S\tA\t<A\n\tNx>S\tA\t>A" H(tblf2 3) "\n"	},
	{CANLD|NDASSOC,			RETDREG, 0,0,	"\tldx>S\tA\t>A\n\tNx>S\tA\t<A" H(tblf2 4) "\n"	},
	{0}
};
#endif

#endif		/* FLOAT */

#if COLDFIRE
/* 06'11 HR: new code table tblasn. */
staticMTBL tblasn[] =
{
	{LISREG|CANRM|CANAI,	RETLEFT,	0, 0, "\tldx<S\t<A\t>A" H(assign 1) "\n"	},
	{LISREG,				RETLEFT,	0, 1, "\tlmx  \tR1\t>A\n\tldx<S\t<A\tR1." H(assign 1f) "\n"	},
	{RISREG|CANLM|CANAI,	RETLEFT,	0, 0, "\tsto<S\t>A\t<A" H(assign 2) "\n"	},
	{RISREG,				RETLEFT,	0, 1, "\tlmx  \tR1\t<A\n\tsto<S\t>A\tR1." H(assign 2f) "\n"	},
	{CANDD|CAN3Q|CANAI,		RETLEFT,	0, 0, "\tm3q<S\t\t>A,<A" H(assign 3q) "\n"	},
	{CANDD|CANM|CANAI,		RETLEFT,	0, 0, "\tmov<S\t\t>A,<A" H(assign 3) "\n"	},
	{CANDD,	 				RETLEFT,	1, 0, "\tldx<S\tR1\t>A\n\tsto<S\tR1\t<A" H(assign 3f) "\n"	},
	{0}
};

staticMTBL tbllmul[] =
{
	{CANRL|LISTMP|CANRM,	RETLEFT, 0,0,	"\tUmpxS\t<A\t>A" H(tbllmul 1) "\n"},
	{CANRL|LISTMP,			RETLEFT, 0,1,	"\tlmx \tR1\t>A\n\tUmpxS\t<A\tR1." H(tbllmul 1f) "\n"},
	{CANLR|RISTMP|CANLM,	RETRIGHT,0,0,	"\tUmpxS\t>A\t<A" H(tbllmul 2) "\n"},
	{CANLR|RISTMP,			RETRIGHT,0,1,	"\tlmx \tR1\t<A\n\tUmpxS\t>A\tR1." H(tbllmul 2f) "\n"},
	{CANRD       |CANRM,	RETDREG, 0,0,	"\tldx>S\tA\t>A\n\tUmpxS\tA\t<A" H(tbllmul 3) "\n"},
	{CANRD,					RETDREG, 0,1,	"\tldx<S\tA\t<A\n"
	                                        "\tlmx \tR1\t>A\n\tUmpxS\tA\tR1." H(tbllmul 3f) "\n"},
	{0}
};

staticMTBL tbllscale[] =
{
	{CANRL|LISTMP|CANRM,	RETLEFT, 0,0,	"\tUmpxS\t<A\t>A" H(tbllscale 1) "\n"},
	{CANRL|LISTMP,			RETLEFT, 0,1,	"\tlmx \tR1\t>A\n\tUmpxS\t<A\tR1." H(tbllscale 1f) "\n"},
	{CANLR|RISTMP|CANLM,	RETRIGHT,0,0,	"\tUmpxS\t>A\t<A" H(tbllscale 2) "\n"},
	{CANLR|RISTMP,			RETRIGHT,0,1,	"\tlmx \tR1\t<A\n\tUmpxS\t>A\tR1." H(tbllscale 2f) "\n"},
	{CANRD       |CANRM,	RETDREG, 0,0,	"\tldx<S\tA\t<A\n\tUmpxS\tA\t>A" H(tbllscale 3) "\n"},
	{CANRD,					RETDREG, 0,1,	"\tldx<S\tA\t<A\n"
											"\tlmx \tR1\t>A\n\tUmpxS\tA\tR1." H(tbllscale 3f) "\n"},
	{0}
};

staticMTBL tblldiv[] =
{
	{CANRL|LISTMP|CANRM,	RETLEFT,0,0,	"\tUdvxS\t<A\t>A" H(tblldiv 1) "\n"},
	{CANRL|LISTMP,	        RETLEFT,0,1,	"\tlmx \tR1\t>A\n\tUdvxS\t<A\tR1." H(tblldiv 1f) "\n"},
	{CANRD       |CANRM,	RETDREG,0,0,	"\tldxS\tA\t<A\n\tUdvxS\tA\t>A" H(tblldiv 2) "\n"},
	{CANRD,			        RETDREG,0,1,	"\tldxS\tA\t<A\n"
											"\tlmx \tR1\t>A\n\tUdvxS\tA\tR1." H(tblldiv 2f) "\n"},
	{0}
};

staticMTBL tbllmod[] =
{
	{CANRL|LISTMP|CANRM,	RETLEFT,1,0,	"\tUrmxS\tR1\t>A,<A\n\tldx.l\t<A\tR1" H(tbllmod 1f) "\n"},
	{CANRL|LISTMP,	        RETLEFT,1,1,	"\tlmx \tR2\t>A\n\tUrmxS\tR1\tR2.,<A\n\tldx.l\t<A\tR1" H(tbllmod 2f) "\n"},
	{CANRD       |CANRM,	RETDREG,1,0,	"\tldxS\tA\t<A\n\tUrmxS\tR1\t>A,A\n\tldx.l\tA\tR1" H(tbllmod 3f) "\n"},
	{CANRD,			        RETDREG,1,1,	"\tldxS\tA\t<A\n"
											"\tlmx \tR2\t>A\n\tUrmxS\tR1\tR2.,A\n\tldx.l\tA\tR1" H(tbllmod 4f) "\n"},
	{0}
};

staticMTBL tblasop[] =
{
	{CANIM|CANM,				RETLEFT,0,0,	"\tNiS\t\t>A,<A" H(tblas 1) "\n"},
	{CANLD|CANM|LISREGVAR,	RETLEFT,0,0,	"\tNxS\t<A\t>A" H(tblas 2) "\n"},
	{CANRL|CANM,				RETLEFT,0,0,	"\tNsS\t>A\t<A" H(tblas 3) "\n"},
	{CANDL,						RETLEFT,1,0,	"\tldxS\tR1\t>A\n\tNsS\tR1\tA" H(tblas 4) "\n"},

	/* only MUL, DIV and shifts should get to here */
	{CANRD,			RETDREG,0,0,	"\tldxS\tA\t<A\n\tNxS\tA\t>A\n\tstoS\tA\t<A" H(tblas 5) "\n"},
	{CANLD|NDASSOC,	RETDREG,0,0,	"\tldxS\tA\t>A\n\tNxS\tA\t<A\n\tstoS\tA\t<A" H(tblas 6) "\n"},
	{CANDD,			RETDREG,1,0,	"\tldxS\tA\t<A\n\tldxS\tR1\t>A\n\tNxS\tA\tR1\n\tstoS\tA\t<A" H(tblas 7) "\n"},
	{0}
};

/* The extra Dregs are allocated before the extra Aregs */
staticMTBL tblcf[] =
{
	{CANRL|CANRM,	0,0,0,	"\tcpx>S\t<A\t>A" H(tblc 1f) "\n"},
	{CANRL,	        0,0,1,	"\tlmx  \tR1\t>A\n\tcpx>S\t<A\tR1." H(tblc 2f) "\n"},
	{CANRD|CANRM,	0,1,0,	"\tldx<S\tR1\t<A\n\tcpx>S\tR1\t>A" H(tblc 3f) "\n"},
	{CANRD,	        0,1,1,	"\tldx<S\tR1\t<A\n\tlmx  \tR2\t>A\n\tcpx>S\tR1\tR2." H(tblc 4f) "\n"},
	{0}
};

#else

/* 06'11 HR: new code table tblasn. */
staticMTBL tblasn[] =
{
	{LISREG,		RETLEFT,	0, 0, "\tldx<S\t<A\t>A" H(assign n1) "\n"	},
	{RISREG,		RETLEFT,	0, 0, "\tsto<S\t>A\t<A" H(assign n2) "\n"	},
	{CANDD,  		RETLEFT,	0, 0, "\tmov<S\t\t>A,<A" H(assign n3) "\n"	},
	{0}
};

staticMTBL tbllmul[] =
{
	{CANRL|LISTMP,	RETLEFT, 0,0,	"\tUmpxS\t<A\t>A" H(tbllmul 1) "\n"},
	{CANLR|RISTMP,	RETRIGHT,0,0,	"\tUmpxS\t>A\t<A" H(tbllmul 2) "\n"},
	{CANRD,			RETDREG, 0,0,	"\tldx>S\tA\t>A\n\tUmpxS\tA\t<A" H(tbllmul 3) "\n"},
	{0}
};

staticMTBL tbllscale[] =
{
	{CANRL|LISTMP,	RETLEFT, 0,0,	"\tUmpxS\t<A\t>A" H(tbllscale 1) "\n"},
	{CANLR|RISTMP,	RETRIGHT,0,0,	"\tUmpxS\t>A\t<A" H(tbllscale 2) "\n"},
	{CANRD,			RETDREG, 0,0,	"\tldx<S\tA\t<A\n\tUmpxS\tA\t>A" H(tbllscale 3) "\n"},
	{0}
};

staticMTBL tblldiv[] =
{
	{CANRL|LISTMP,	RETLEFT,0,0,	"\tUdvxS\t<A\t>A" H(tblldiv 1) "\n"},
	{CANRD,			RETDREG,0,0,	"\tldxS\tA\t<A\n\tUdvxS\tA\t>A" H(tblldiv 2) "\n"},
	{0}
};

staticMTBL tbllmod[] =
{
	{CANRL|LISTMP,	RETLEFT,1,0,	"\tUrmxS\tR1\t>A,<A\n\tldx.l\t<A\tR1" H(tbllmod 1) "\n"},
	{CANRD,			RETDREG,1,0,	"\tldxS\tA\t<A\n\tUrmxS\tR1\t>A,A\n\tldx.l\tA\tR1" H(tbllmod 3) "\n"},
	{0}
};

staticMTBL tblasop[] =
{
	{CANIM,				RETLEFT,0,0,	"\tNiS\t\t>A,<A" H(tblas 1) "\n"},
	{CANLD|LISREGVAR,	RETLEFT,0,0,	"\tNxS\t<A\t>A" H(tblas 2) "\n"},
	{CANRL,				RETLEFT,0,0,	"\tNsS\t>A\t<A" H(tblas 3) "\n"},
	{CANDL,				RETLEFT,1,0,	"\tldxS\tR1\t>A\n\tNsS\tR1\tA" H(tblas 4) "\n"},

	/* only MUL, DIV and shifts should get to here */
	{CANRD,			RETDREG,0,0,	"\tldxS\tA\t<A\n\tNxS\tA\t>A\n\tstoS\tA\t<A" H(tblas 5) "\n"},
	{CANLD|NDASSOC,	RETDREG,0,0,	"\tldxS\tA\t>A\n\tNxS\tA\t<A\n\tstoS\tA\t<A" H(tblas 6) "\n"},
	{CANDD,			RETDREG,1,0,	"\tldxS\tA\t<A\n\tldxS\tR1\t>A\n\tNxS\tA\tR1\n\tstoS\tA\t<A" H(tblas 7) "\n"},
	{0}
};

#endif		/* COLDFIRE */

staticMTBL tbl2[] =
{
	{LISTMP|CANRL,			RETLEFT, 0,0,	"\tNxS\t<A\t>A" H(tbl2 1) "\n"},
	{RISTMP|CANLR|NDASSOC,	RETRIGHT,0,0,	"\tNxS\t>A\t<A" H(tbl2 2) "\n"},
	{CANRD,					RETDREG, 0,0,	"\tldxS\tA\t<A\n\tNxS\tA\t>A" H(tbl2 3) "\n"},
	{CANLD|NDASSOC,			RETDREG, 0,0,	"\tldxS\tA\t>A\n\tNxS\tA\t<A" H(tbl2 4) "\n"},
	/* only EOR and shifts get to here */
	{CANDL|LISTMP,			RETLEFT, 1,0,	"\tldxS\tR1\t>A\n\tNsS\tR1\tA" H(tbl2 5) "\n"},
	{CANDR|RISTMP|NDASSOC,	RETRIGHT,1,0,	"\tldxS\tR1\t<A\n\tNsS\tR1\tA" H(tbl2 6) "\n"},
	{CANDD,					RETDREG, 1,0,	"\tldxS\tA\t<A\n\tldx>S\tR1\t>A\n\tNxS\tA\tR1" H(tbl2 7) "\n"},	/* only shifts ?? */
	{0}
};

/* indexing.
   This table makes combining to extended operand modes
   much more straightforward.
*/
staticMTBL tblindex[] =
{
	{LISTMP|CANRL,	RETLEFT,0,0,	"\tNx>S\t<A\t>A" H(tbli 1) "\n"},
	{CANRD,			RETAREG,0,0,	"\tldxS\tA\t<A\n\tNx>S\tA\t>A" H(tbli 2) "\n"},
	{0}
};

staticMTBL tblmul[] =
{
	{CANRL|LISTMP,	RETLEFT, 0,0,	"\tUmpxS \t<A\t>A" H(tblmul 1) "\n"},
	{CANLR|RISTMP,	RETRIGHT,0,0,	"\tUmpxS \t>A\t<A" H(tblmul 2) "\n"},
	{CANRD,			RETDREG, 0,0,	"\tldx>S\tA\t>A\n\tUmpxS \tA\t<A" H(tblmul 3) "\n"},
	{0}
};

staticMTBL tblscale[] =
{
	{CANRL|LISTMP,	RETLEFT, 0,0,	"\tUscx \t<A\t>A" H(tblscale 1) "\n"},
	{CANLR|RISTMP,	RETRIGHT,0,0,	"\tUscx \t>A\t<A" H(tblscale 2) "\n"},
	{CANRD,			RETDREG, 0,0,	"\tldx<S\tA\t<A\n\tUscx \tA\t>A" H(tblscale 3) "\n"},
	{0}
};

staticMTBL tbldiv[] =
{
	{CANRL|LISTMP,	RETLEFT,0,0,	"\tmvs.w\t<A\t<A\n\tdvx \t<A\t>A" H(tbldiv 1) "\n"},
	{CANRD,			RETDREG,0,0,	"\tmvs.w\tA\t<A\n\tdvx \tA\t>A" H(tbldiv 2) "\n"},
	{0}
};

staticMTBL tblmod[] =
{
	{CANRL|LISTMP,	RETLEFT,0,0,	"\tmvs.w\t<A\t<A\n\tmdx \t<A\t>A\n\tswx \t<A\t" H(tblmod 1) "\n"},
	{CANRD,			RETDREG,0,0,	"\tmvs.w\tA\t<A\n\tmdx \tA\t>A\n\tswx \tA" H(tblmod 2) "\n"},
	{0}
};

staticMTBL tbludiv[] =
{
	{CANRD,			RETDREG,0,0,	"\tmvz  \tA\t<A\n\tudvx \tA\t>A" H(tbludiv 2) "\n"},
	{0}
};

staticMTBL tblumod[] =
{
	{CANRD,			RETDREG,0,0,	"\tmvz  \tA\t<A\n\tumdx \tA\t>A\n\tswx \tA" H(tblumod 2) "\n"},
	{0}
};

staticMTBL tblc[] =
{
	{CANIM,	0,0,0,	"\tcpi>S\t\t>A,<A" H(tblc 1) "\n"},
	{CANRL,	0,0,0,	"\tcpx>S\t<A\t>A" H(tblc 2) "\n"},
	{CANRD,	0,1,0,	"\tldx<S\tR1\t<A\n\tcpx>S\tR1\t>A" H(tblc 3) "\n"},
	{0}
};
/* not yet
staticMTBL tbleor[] =
{
	{CANIM,	RETLEFT,0,0,	"\teri>S\t\t>A,<A" H(tbleor 1) "\n"},
	{CANRL,	RETLEFT,0,0,	"\ters>S\t>A\t<A" H(tbleor 2) "\n"},
	{CANLD,	0,		1,0,	"\tldx<S\tR1\t<A\n\ters>S\tR1\t>A" H(tbleor 3) "\n"},
	{0}
};
*/

staticMTBL tblamul[] =
{
	{CANRL,			RETLEFT, 0,0,	"\tUmpx \t<A\t>A" H(tblamul 1) "\n"},
	{CANLR|RISTMP,	RETRIGHT,0,0,	"\tUmpx \t>A\t<A\n\tsto \t>A\t<A" H(tblamul 2) "\n"},
	{CANRD,			RETDREG, 0,0,	"\tldx  \tA\t<A\n\tUmpx \tA\t>A\n\tsto \tA\t<A" H(tblamul 3) "\n"},
	{0}
};

staticMTBL tbladiv[] =
{
	{CANRL,	RETLEFT,0,0,	"\tmvs.w\t<A\t<A\n\tdvx \t<A\t>A" H(tbladiv 1) "\n"},
	{CANRD,	RETDREG,0,0,	"\tmvs.w\tA\t<A\n\tdvx \tA\t>A\n\tsto  \tA\t<A" H(tbladiv 2) "\n"},
	{0}
};

staticMTBL tbluadiv[] =
{
	{CANRD,	RETDREG,0,0,	"\tmvz \tA\t<A\n\tudvx \tA\t>A\n\tsto \tA\t<A" H(tbluadiv) "\n"},
	{0}
};

staticMTBL tblamod[] =
{
	{CANRL,	RETLEFT,0,0,	"\tmvs.w\t<A\t<A\n\tmdx \t<A\t>A\n\tswx \t<A\t" H(tblamod 1) "\n"},
	{CANRD,	RETDREG,0,0,	"\tmvs.w\tA\t<A\n\tmdx \tA\t>A\n\tswx \tA\n\tsto \tA\t<A" H(tblamod 2) "\n"},
	{0}
};

staticMTBL tbluamod[] =
{
	{CANRD,	RETDREG,0,0,	"\tmvz \tA\t<A\n\tumdx \tA\t>A\n\tswx \tA\n\tsto \tA\t<A" H(tbluamod) "\n"},
	{0}
};


staticBOPS
/*	voor interchange code (denkbeeldige (risc?) computer met instr format F X OP)
	niettemin blijft deze tabel gebaseerd op: LopR, waarbij L is source en R is destination,
	hoe de uiteindelijke lezing er ook uit mag zien	*/

	 bop_cmpcf=	{"cp", 	EopD|     IopD|EopA|AopA|AopD},
	 bop_cmp=	{"cp",	EopD|     IopE|EopA|AopA|AopD},
	 bop_eor=	{"er",	     DopE|IopE},
	 bop_fcp=	{"cp",	EopD},
	 bop_mul=	{"mp",	EopD|                         ASSOC},
	 bop_div=	{"dv",	EopD},
	 bop_mod=	{"md",	EopD},
	 bop_and=	{"an",	EopD|DopE|IopE|     		  ASSOC},
	 bop_or=	{"or",	EopD|DopE|IopE|     		  ASSOC},
	 bop_add=	{"ad",	EopD|DopE|IopE|EopA|AopA|AopD|ASSOC},
	 bop_sub=	{"sb",	EopD|DopE|IopE|EopA|AopA|AopD},
	 bop_asl=	{"Vsl",	DopD|QopD|ONEopM},
	 bop_asr=	{"Vsr",	DopD|QopD|ONEopM},
	 bop_rol=	{"rol",	DopD|QopD},
	 bop_ror=	{"ror",	DopD|QopD},
	 bop_fadd=	{"ad",	EopD|ASSOC},
	 bop_fsub=	{"sb",	EopD},
	 bop_assign={"mv",	EopD|DopE}
	 ;
