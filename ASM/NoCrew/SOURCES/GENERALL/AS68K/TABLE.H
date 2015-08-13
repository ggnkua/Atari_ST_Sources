#

/*
 *	table.h --- basic definitions for the mnemonic table
 *
 *      Table.c is generated using an awk program.  The mnemonic
 *	table consists of a base mnemonic, the number of templates
 *	to match against the operand field, and a pointer to the
 *	list of templates.  The templates consist of the allowed
 *      sizes that follow the mnemonic, and up to 4 ea classes
 *	for the instruction.  A successful match must match the
 *	type and number of operands.  Some pseudo ops are different,
 *	since they have an open-ended number of operands (e.g. ds,dc)
 *	These are marked in the table with a first EA type of MULTI.
 */

struct tmpl{	/* a template to match */
	char	sizes;	/* allowed sizes (bit map) */
	char    modes[4];       /* up to 4 EA fields may be specified */
	char	class;	/* opcode class */
	short   op;     /* base opcode */
	short   op2;    /* second opcode (F-line, etc) */
	};

struct mne{	/* a mnemonic */
	char    *mne_name;
	char    ntmpl;          /* number of templates to test */
	struct tmpl *ptmpl;     /* pointer to templates to test */
	};

/* sizes */
#define	B	0x01
#define W	0x02
#define L	0x04
#define S	0x08
#define D	0x10
#define X	0x20
#define P	0x40
#define U	0x80
/* composite sizes */
#define	bwlu	(B|W|L|U)
#define	bwlsdxp	(B|W|L|S|D|X|P)
#define	wlu	(W|L|U)
#define	bu	(B|U)
#define wu	(W|U)
#define	lu	(L|U)
#define	wl	(W|L)
#define xu      (X|U)
#define bwlsdxpu (B|W|L|S|D|X|P|U)
#define anysz    (B|W|L|S|D|X|P|U)

/* opcode classes */
#define INH             0
#define RXRY            1
#define RXRYS           2
#define RXRYR           3
#define RXRYP           4
#define EAREG           5
#define EAREGS          6
#define REGEA           7
#define REGEAS          8
#define IMMEAS          9
#define QUKEA           10
#define IMMB            11
#define IMMW            12
#define IMMWS           13
#define IMM3            14
#define IMM4            15
#define RSHIFT          16
#define QSHIFT          17
#define EA              18
#define EAREV           19
#define EAS             20
#define BCC             21
#define BIT             22
#define BITFLD          23
#define BITFLD2         24
#define CALLM           25
#define CAS             26
#define CAS2            27
#define CHK             28
#define CHK2            29
#define DBCC            30
#define MULDIV          40
#define REG             41
#define MOVEU           42      /* move to/from usp */
#define REGIMM          43
#define MOVE            44
#define MOVEC           45
#define MOVEQ           46
#define MOVEMO          47
#define MOVEMI          48
#define MOVEPO          49
#define MOVEPI          50
#define MOVES           51
#define TRAPCC          52

/* floating point classes */
#define FEAREG          53
#define FREGREG         54
#define FMONAD          55
#define FBCC            56
#define FDBCC           57
#define FINH            58
#define FEA             59
#define FSCC            60
#define FEAPAIR         61
#define FREGPAIR        62
#define FTSTEA          63
#define FTSTREG         64
#define FMOVE           65
#define FMOVECR         66
#define FMOVEMI         67
#define FMOVEMO         68
#define FMOVEMCI        69
#define FMOVEMCO        70
#define FTRAPCC         71

/* PMMU classes */
#define PINH            72
#define PBCC            73
#define PDBCC           74
#define PFLUSH          75
#define PEA             76
#define PLOAD           77
#define PMOVEI          78
#define PMOVEO          79
#define PSCC            80
#define PTEST           81
#define PTRAPCC         82
#define PVALID          83
#define PMOVEIF         84

/* generic co-processor classes */
#define CPINH           85
#define CPBCC           86
#define CPDBCC          87
#define CPGEN           88
#define CPEA            89
#define CPSCC           90
#define CPTRAPCC        91

/* 68hc16 specific classes */
#define	LPSTOP		92
#define	TABEA		93
#define	TABREG		94

/* pseudo op classes */
#define EQU             100
#define DC              101
#define OPT             102
#define ORG             103
#define DS              104
#define FEQU            105
#define FOPT            106
#define NULL_OP         107
#define ALIGN           108
#define INCLUDE         109
#define RORG            110

struct ea {
	char    type;
	char    itype;  /* when INDEX or PCINDEX, itype specifies sub-mode */
	int     reg;    /* An,Dn,Sp,FPn,Rc,FPc,Pn */
	int	reg2;	/* second register for reg. pairs */
	int	const;	/* #val, displacement, branch dest */
	int	const2;	/* second constant (on static bit field) */
	char    stat;   /* when type==FIELD, stat1==1 -> static */
	char    stat2;  /* when type==FIELD, stat2==1 -> static */
	char    br_sup; /* supress An or PC when set */
	char    xn_sup; /* supress Xn when set */
	char    bdsiz;  /* size and/or supress for base displacement */
	char    odsiz;  /* size and/or supress for outer displacement */
	char    siz;    /* size for indexed modes */
	char    scl;    /* scale for indexed modes */
	char    prepst; /* 0=pre or mem indir, 1=post */
	char    force;  /* const or bdsiz involved a forward ref */
	char    force2; /* const2 or odsiz involved a forward ref */
	};

/* Basic EA types */
#define EMPTY   0       /* not used, must be defined as zero */
#define DN      1       /* Dn */
#define AN      2       /* An, SP */
#define ANI     3       /* (An) */
#define PSTINC  4       /* (An)+ */
#define PREDEC  5       /* -(An) */
#define INDEX   6       /* mode == 05n or 06n */
#define EXPR    7       /* expression (labels, absolute addressing) */
#define IMMED   8       /* #expression */
#define PCINDEX 9       /* mode == 072 or 073 */

/* Other basic EA's, not used in general EA classes */
#define DPAIR   10      /* Dn:Dn */
#define RPAIR   11      /* (Rn):(Rn) */
#define RLIST   12      /* e.g. A0-A3/D5/D7 */
#define FIELD   13      /* {Dn/#:Dn/#} */
#define CN      14      /* control reg (including USP) */
#define CCR     15      /* condition code register */
#define SR      16      /* status register */
#define FN      17      /* FPn */
#define FCN     18      /* FPCR,FPSR,FPIAR */
#define FLIST   19      /* e.g. FP2-FP4/FP7 */
#define FPAIR   20      /* FPm:FPn */
#define FCLIST  21      /* FPCR/FPSR/FPIAR */
#define DYNK    22      /* dynamic K factor {Dn} */
#define STATK   23      /* static K factor {const} */
#define PN      24      /* PMMU register */
#define STRING  25      /* ASCII string */

/* composite EA types. can be one or more of the basic types */
#define RN      26      /* DN or AN */
#define ANYEA   27      /* any EA */
#define CONTROL 28      /* Control */
#define ALTMEM  29      /* Alterable memory (does not include Dn) */
#define DATALT  30      /* Data alterable */
#define ALTER   31      /* alterable (An not allowed on byte operations) */
#define DATA    32      /* Data */
#define CALTPR  33      /* Control Alterable, or predec */
#define CTLPST  34      /* Control, or postinc */
#define CTLALT  35      /* Control Alterable */
#define MEMORY  36      /* Memory */
#define PEA1    37      /* EXPR, DN or CN (Special for PMMU) */
#define MULTI   38      /* up to EAMAX of EXPR's */

/* indexed addressing mode types (e->itype) */
#define D16AN   1       /* d16 + (An) */
#define BRIEF   2       /* d8 + (An) + (Xn.siz*scl) */
#define FULL    3       /* full format */

/*
 *      For each basic EA type returned by scanea(), the remaining
 *      structure elements are set as follows:
 *
 *      Type    Sets
 *
 *      EMPTY   nothing
 *      DN      reg = 0-7
 *      AN      reg = 0-7
 *      ANI     reg = 0-7
 *      PSTINC  reg = 0-7
 *      PREDEC  reg = 0-7
 *      INDEX   see do_indexed() and/or oh_shit()
 *      EXPR    const = result of expr. eval, csiz: 0=none, 1=.W, 2=.L
 *      IMMED   const = immediate value
 *      PCINDEX see do_indexed() and/or oh_shit()
 *      DPAIR   reg = 1st reg#, reg2 = 2nd reg#
 *      RPAIR   reg = 1st reg#, reg2 = 2nd reg#,
 *              stat1 ? reg is An : reg is Dn
 *              stat2 ? reg2 is An : reg2 is Dn
 *      RLIST   reg = bit map of registers, A7=msb, D0=lsb
 *      FIELD   reg = 1st reg, reg2 = 2nd reg,
 *              const = 1st constant, const2 = 2nd constant,
 *              stat1 ? 1st is STATIC : 1st is Dynamic,
 *              stat2 ? 2nd is STATIC : 2nd is Dynamic
 *      CN      reg = control reg# as per movec encoding
 *      CCR     nothing
 *      SR      nothing
 *      FN      reg = 0-7
 *      FCN     reg = Fp control reg# as per fmovec encoding
 *      FLIST   reg = bit map of FP regs, FP7=msb, FP0=lsb
 *      FPAIR   reg = 1st fp reg, reg2 = 2nd fp reg
 *      FCLIST  reg = bit map as per fmovem encoding
 *      DYNK    reg = 0-7
 *      STATK   const = expression
 *      PN      reg = reg# as per second word on PMOVE
 *      STRING  const = ptr to character string
 */
