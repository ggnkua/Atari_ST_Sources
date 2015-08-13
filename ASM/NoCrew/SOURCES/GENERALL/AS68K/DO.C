#include <stdio.h>
#include <ctype.h>
#include "as.h"
#include "table.h"
#include "lookup.h"
#include "regs.h"

#define	cpid(x)	((x)<<9)	/* coprocessor id field */

#ifdef PMMU
int     Ppid    = cpid(0);	/* PMMU coprocessor ID */
#endif

extern int Size;
extern char Label[];
extern char Line[];
extern char *Optr;
extern int Pc;
extern int Lflag;
extern int Fwdsize;
extern int Old_pc;
extern int P_total;
extern int P_force;
char *next_str();

struct opts {   /* a list of allowed options */
	char    *opt_name;
	int     (*opt_func)();
	};

int o_list(),o_nolist(),o_null();

struct opts opt_list[] = {
	"l",            o_list,
	"list",         o_list,
	"nol",          o_nolist,
	"nolist",       o_nolist,
	"brl",          o_null,
	0,              0
	};

#ifdef FLOAT

int     Fpid    = cpid(1);	/* floating point coprocessor ID */
int o_fpid(),o_round(),o_prec();

struct opts fopt_list[] = {
	"id",           o_fpid,
	"round",        o_round,
	"prec",         o_prec,
	0,              0
	};
#endif

/* range checking categories */
#define UBYTE   0       /* unsigned byte */
#define SBYTE   1       /* signed byte */
#define XBYTE   2       /* extended byte */
#define UWORD   3       /* unsigned word */
#define SWORD   4       /* signed word */
#define XWORD   5       /* extended word */
#define QUK     6       /* quick value 1-8 */
#define LOW3    7       /* 3 bit field */
#define LOW4    8       /* 4 */
#define LOW5    9       /* 5 */
#define	LOW6	10	/* 6 */
#define LOW7    11      /* 7 */
#define LOW7S   12      /* 7, signed */

struct ranges {
	int     r_min;  /* minimum value allowed */
	int     r_max;  /* max. allowed */
	int     r_mask; /* return value mask */
	};

struct ranges ckrange[] = {
	0,      MAXUBYTE,       0x00FF,
	MINBYTE,MAXBYTE,        0x00FF,
	MINBYTE,MAXUBYTE,       0x00FF,
	0,      MAXUWORD,       0xFFFF,
	MINWORD,MAXWORD,        0xFFFF,
	MINWORD,MAXUWORD,       0xFFFF,
	1,      8,              0x0007,
	0,      7,              0x0007,
	0,      15,             0x000F,
	0,      31,             0x001F,
	0,	63,		0x003F,
	0,      127,            0x007F,
	-64,    63,             0x007F,
	};

/*
 *      localinit --- machine specific initialization
 */
localinit()
{
	register struct regs *r;

	/* install register names in symbol table */
	for(r=iregs; r<&iregs[NIREGS]; r++)
		install(r->r_name,r->r_value,r->r_type);
}

/*
 *      do_op --- process mnemonic
 */
do_op(class,op,op2)
int class;	/* mnemonic class */
int op;         /* base opcode */
int op2;        /* second opcode (e.g. F-lines) */
{
	extern struct ea Eas[];
	register struct ea *ea1 = &Eas[0];
	register struct ea *ea2 = &Eas[1];
	register struct ea *ea3 = &Eas[2];
	register struct ea *ea4 = &Eas[3];
	register int tmp;
	register int dist;      /* distance on branches */
	register int rlist;     /* bit map of register list */
	char    *ptmp;

	switch(class){
	case INH:               /* inherent */
		eword(op);
		break;

	case RXRY:              /* Rx and Ry, no size */
		eword( op + (ea2->reg<<9) + ea1->reg );
		break;

	case RXRYS:             /* Rx and Ry, sized */
		eword( op + (ea2->reg<<9) + size76() + ea1->reg );
		break;

	case RXRYR:             /* Rx and Ry, reversed */
		eword( op + (ea1->reg<<9) + ea2->reg );
		break;

	case RXRYP:             /* Rx and Ry, pack/unpack */
		eword( op + (ea2->reg<<9) + ea1->reg );
		eword(check(ea3->const,UWORD));
		break;

	case EAREG:             /* ea to register */
		eword( op + (ea2->reg<<9) + modreg(ea1) );
		finish(ea1);
		break;

	case EAREGS:            /* ea to register, sized */
		eword( op + (ea2->reg<<9) + size76() + modreg(ea1));
		finish(ea1);
		break;

	case REGEA:             /* register to ea */
		eword( op + (ea1->reg<<9) + modreg(ea2));
		finish(ea2);
		break;

	case REGEAS:            /* register to ea, signed */
		eword( op + (ea1->reg<<9) + size76() + modreg(ea2));
		finish(ea2);
		break;

	case IMMEAS:            /* immediate to ea, sized */
		eword( op + size76() + modreg(ea2) );
		if(Size==L)
			elong(ea1->const);
		else
			eword(ea1->const);
		finish(ea2);
		break;

	case QUKEA:             /* quick immediate to ea */
		if( (Size&B) && ea2->type==AN )
			error("Byte not allowed to address reg.");
		eword( op + (check(ea1->const,QUK)<<9) + size76() + modreg(ea2) );
		finish(ea2);
		break;

	case IMMB:              /* immediate byte */
		eword(op);
		eword(check(ea1->const,UBYTE));
		break;

	case IMMW:              /* immediate word */
		eword(op);
		eword(check(ea1->const,XWORD));
		break;

	case IMMWS:             /* immediate word, signed */
		eword(op);
		eword(check(ea1->const,SWORD));
		break;

	case IMM3:              /* immediate value, 3 bits */
		eword( op + check(ea1->const,LOW3) );
		break;

	case IMM4:              /* immediate value, 4 bits */
		eword( op + check(ea1->const,LOW4) );
		break;

	case RSHIFT:            /* register shift */
		eword( op + (ea1->reg<<9) + size76() + ea2->reg );
		break;

	case QSHIFT:            /* immediate (quick fmt) shift */
		eword( op + (check(ea1->const,QUK)<<9) + size76() + ea2->reg);
		break;

	case EA:                /* ea */
		eword( op + modreg(ea1) );
		finish(ea1);
		break;

	case EAREV:             /* ea, reversed */
		eword( op + modreg(ea2) );
		finish(ea2);
		break;

	case EAS:               /* ea, sized */
		eword( op + size76() + modreg(ea1) );
		finish(ea1);
		break;

	case BCC:               /* conditional branches */
		dist = ea1->const - (Pc+2);
		if(Size==U && ea1->force )
			Size = Fwdsize;
		if(Size==U){
			if( dist<MINWORD || dist>MAXWORD )
				Size = L;
			else if( dist<MINBYTE || dist>MAXBYTE)
				Size = W;
			else
				Size = B;
			}
		switch(Size){
		case B:
			if( dist==0 || dist== -1)
				error("Bad branch destination");
			eword( op + check(dist,SBYTE) );
			break;
		case W:
			eword(op);
			eword(check(dist,SWORD));
			break;
		case L:
			eword(op+0xFF);
			elong(dist);
			break;
			}
		break;

	case BIT:               /* single bit manipulation */
		eword( op + modreg(ea2) );
		eword( check(ea1->const,LOW5) );
		finish(ea2);
		break;

	case BITFLD:            /* bit fields */
		eword( op + modreg(ea1) );
		eword( bitfld(ea2,0) );        /* {Dn/#:Dn/#} formatted word */
		finish(ea1);
		break;

	case BITFLD2:           /* bit fields, second format */
		if( ea2->type == FIELD ){
			eword( op + modreg(ea1) );
			eword( bitfld(ea2,ea3->reg) ); /* {Dn/#:Dn/#} formatted word */
			finish(ea1);
			}
		else{   /* bfins is backwards */
			eword( op + modreg(ea2) );
			eword( bitfld(ea3,ea1->reg) ); /* {Dn/#:Dn/#} formatted word */
			finish(ea2);
			}
		break;

	case CALLM:             /* callm */
		eword( op + modreg(ea2) );
		eword(check(ea1->const,UBYTE));
		finish(ea2);
		break;

	case CAS:               /* cas */
		eword( op + size109b() + modreg(ea3) );
		eword( (ea2->reg<<6) + ea1->reg );
		finish(ea3);
		break;

	case CAS2:              /* cas2 */
		eword( op + size109b() );
		if(ea3->stat)
			ea3->reg += 8;
		eword( (ea3->reg<<12) + (ea2->reg<<6) + ea1->reg);
		if(ea3->stat2)
			ea3->reg2 += 8;
		eword( (ea3->reg2<<12) + (ea2->reg2<<6) + ea1->reg2);
		break;

	case CHK:               /* chk */
		if( Size != L )
			op |= 0x0080;
		eword( op + (ea2->reg<<9) + modreg(ea1) );
		finish(ea1);
		break;

	case CHK2:              /* chk2,cmp2 */
		eword( op + size109() + modreg(ea1) );
		eword( op2 + adreg(ea2) );
		finish(ea1);
		break;

	case DBCC:              /* dbcc */
		dist = ea2->const - (Old_pc+2);
		eword(op + ea1->reg );
		eword(check(dist,SWORD));
		break;

	case MULDIV:            /* multiplies and divides */
		eword( op + modreg(ea1) );
		if( ea2->type == DN )
			ea2->reg2 = ea2->reg;
		eword( op2 + (ea2->reg2<<12) + ea2->reg);
		finish(ea1);
		break;

	case REG:               /* register */
		eword(op + ea1->reg);
		break;

	case MOVEU:             /* move to/from USP */
		if( ea1->type == CN ){
			if( ea1->reg != USP )
				error("USP Required");
			eword( op + ea2->reg);
			}
		else{
			if( ea2->reg != USP )
				error("USP Required");
			eword( op + ea1->reg);
			}
		break;

	case REGIMM:            /* register with immediate */
		eword(op + ea1->reg);
		if( Size == L)
			elong(ea2->const);
		else
			eword(ea2->const);
		break;

	case MOVE:              /* move */
		tmp = modreg(ea2);
		tmp = ((tmp&7)<<3) + ((tmp>>3)&7);      /* reverse modreg */
		eword( op + (tmp<<6) + modreg(ea1) );
		finish(ea1);
		finish(ea2);
		break;

	case MOVEC:             /* movec */
		eword(op);
		if( ea1->type == CN )
			eword( adreg(ea2) + ea1->reg );
		else
			eword( adreg(ea1) + ea2->reg );
		break;

	case MOVEQ:             /* move quick */
		eword(op + (ea2->reg<<9) + check(ea1->const,SBYTE) );
		break;

	case MOVEMO:            /* movem register to memory */
		if(ea1->type == IMMED)
			rlist = ea1->const;
		else
			rlist = getrlist(ea1);
		if( ea2->type == PREDEC )
			rlist = reverse(rlist)>>16;	/* assumes int=32bits */
		eword( op + modreg(ea2) );
		eword(rlist);
		finish(ea2);
		break;

	case MOVEMI:            /* movem memory to register */
		if(ea2->type == IMMED)
			rlist = ea2->const;
		else
			rlist = getrlist(ea2);
		/* predec not possible here */
		eword(op + modreg(ea1));
		eword(rlist);
		finish(ea1);
		break;

	case MOVEPO:            /* movep out */
		if(ea2->itype != D16AN )
			error("Simple indexing only");
		eword(op + (ea1->reg<<9) + ea2->reg);   /* NOT modreg(ea2) */
		finish(ea2);
		break;

	case MOVEPI:            /* movep in */
		if(ea1->itype != D16AN )
			error("Simple indexing only");
		eword(op + (ea2->reg<<9) + ea1->reg);   /* NOT modreg(ea1) */
		finish(ea1);
		break;

	case MOVES:             /* moves */
		op += size76();
		if( ea1->type == DN || ea1->type == AN ){
			eword( op + modreg(ea2) );
			eword( op2 + adreg(ea1) );
			finish(ea2);
			}
		else{
			eword( op + modreg(ea1) );
			eword( op2 + adreg(ea2) );
			finish(ea1);
			}
		break;

	case TRAPCC:            /* trapcc */
		eword(op + (Size==W ? 2 : 3));
		if( Size == L )
			elong(ea1->const);
		else
			eword(check(ea1->const,UWORD));
		break;

#ifdef FLOAT
	case FINH:              /* floating inherent */
		eword( op + Fpid );
		eword( op2 );
		break;

	case FEAREG:            /* floating ea to regiser */
		fsizchk(ea1);
		eword( op + Fpid + modreg(ea1) );
		eword( op2 + fsize() + (ea2->reg<<7) );
		finish(ea1);
		break;

	case FREGREG:           /* floating register to register */
		eword( op + Fpid );
		eword( op2 + (ea1->reg<<10) + (ea2->reg<<7) );
		break;

	case FMONAD:            /* floating register (monadic) */
		eword( op + Fpid );
		eword( op2 + (ea1->reg<<10) + (ea1->reg<<7) );
		break;

	case FBCC:              /* floating branch */
		eword( op + Fpid + (Size==L ? 0x40 : 0) );
		dist = ea1->const - Pc;
		if( Size == L )
			elong(dist);
		else
			eword(check(dist,SWORD));
		break;

	case FDBCC:             /* floating dbcc */
		eword( op + Fpid + ea1->reg);
		eword( op2 );
		dist = ea2->const - Pc;
		eword(check(dist,SWORD));
		break;

	case FEA:               /* floating ea */
		eword( op + Fpid + modreg(ea1) );
		finish(ea1);
		break;

	case FSCC:              /* floating scc */
		eword( op + Fpid + modreg(ea1) );
		eword(op2);
		finish(ea1);
		break;

	case FEAPAIR:           /* floating ea to floating reg pair */
		fsizchk(ea1);
		eword( op + Fpid + modreg(ea1) );
		eword( op2 + fsize() + (ea2->reg<<7) + ea2->reg2);
		finish(ea1);
		break;

	case FREGPAIR:          /* floating register to floating reg pair */
		eword( op + Fpid );
		eword( op2 + (ea1->reg<<10) + (ea2->reg<<7) + ea2->reg2);
		break;

	case FTSTEA:            /* floating test of ea */
		fsizchk(ea1);
		eword( op + Fpid + modreg(ea1) );
		eword( op2 + fsize() );
		finish(ea1);
		break;

	case FTSTREG:           /* floating test of register */
		eword( op + Fpid );
		eword( op2 + (ea1->reg<<10) );
		break;

	case FMOVE:             /* floating move */
		fsizchk(ea2);
		eword( op + Fpid + modreg(ea2) );
		if( ea3->type==EMPTY )
			eword( op2 + fsize() + (ea1->reg<<7) );
		else if(ea3->type==DYNK)
			eword( op2 + (ea1->reg<<7) + (ea3->reg<<3));
		else if(ea3->type==STATK)
			eword( op2 + (ea1->reg<<7) + check(ea3->const,LOW7S) );
		else
			fatal("Botch in FMOVE");
		finish(ea2);
		break;

	case FMOVECR:           /* floating move constant rom */
		eword(op + Fpid);
		eword( op2 + (ea2->reg<<7) + check(ea1->const,LOW7) );
		break;

	case FMOVEMI:           /* floating move memory to registers */
		/* predec not possible */
		eword( op + Fpid + modreg(ea1) );
		if( ea2->type == DN )
			ea2->reg <<= 4;
		eword(op2 + ea2->reg);
		finish(ea1);
		break;

	case FMOVEMO:           /* floating move registers to memory */
		if (ea2->type != PREDEC )
			op2 += 0x1000;
		if( ea1->type == FLIST && ea2->type==PREDEC )
			ea1->reg = (reverse(ea1->reg)>>24)&0xFF;
		if(ea1->type == DN )
			ea1->reg <<= 4;
		eword(op + Fpid + modreg(ea2));
		eword(op2 + ea1->reg);
		finish(ea2);
		break;

	case FMOVEMCI:          /* floating move memory to control regs */
		checkfclist(ea2->reg,ea1);
		eword(op + Fpid + modreg(ea1));
		eword(op2 + ea2->reg );
		finish(ea1);
		break;

	case FMOVEMCO:          /* floating move control regs to memory */
		checkfclist(ea1->reg,ea2);
		eword(op + Fpid + modreg(ea2));
		eword(op2 + ea1->reg );
		finish(ea2);
		break;

	case FTRAPCC:           /* floating trap on condition */
		eword(op + Fpid + (Size==W ? 2 : 3 ));
		eword(op2);
		if( Size == L )
			elong(ea1->const);
		else
			eword(check(ea1->const,UWORD));
		break;

	case FEQU:              /* floating point equate */
		warn("Not implemented");
		break;

	case FOPT:              /* floating point option set */
		do_opt(fopt_list);
		break;
#endif

#ifdef PMMU
	case PINH:              /* PMMU inherent */
		eword( op + Ppid );
		eword( op2 );
		break;

	case PBCC:              /* PMMU branch */
		eword( op + Ppid + (Size==L ? 0x40 : 0) );
		dist = ea1->const - Pc;
		if( Size == L )
			elong(dist);
		else
			eword(check(dist,SWORD));
		break;

	case PDBCC:             /* PMMU dbcc */
		eword( op + Ppid + ea1->reg);
		eword( op2 );
		dist = ea2->const - Pc;
		eword(check(dist,SWORD));
		break;

	case PFLUSH:            /* PFLUSH, PFLUSHG */
		if( ea3->type != EMPTY )
			op += modreg(ea3);
		eword( op + Ppid );
		eword( op2 + (check(ea2->const,LOW4)<<5) + pmmu_fc(ea1) );
		if(ea3->type != EMPTY)
			finish(ea3);
		break;

	case PEA:               /* PMMU with single EA */
		eword(op + Ppid + modreg(ea1));
		finish(ea1);
		break;

	case PLOAD:             /* PMMU load ATC entry */
		eword(op + Ppid + modreg(ea2));
		eword(op2 + pmmu_fc(ea1));
		finish(ea2);
		break;

	case PMOVEIF:           /* pmove, with no flush of ATC */
		switch(ea2->reg){
		case SRP:
		case CRP:
		case TT0:
		case TT1:
		case TC:
			break;
		default:
			error("Illegal register for pmovef");
			}
		/* FALL THROUGH */

	case PMOVEI:            /* PMMU load control reg */
		switch(ea2->reg){
		case CRP:
		case SRP:
		case DRP:
			if( ea2->type == DN )
				error("Reg. size mismatch");
			break;
		case PCSR:
			error("Read only register");
			break;
			}
		eword(op + Ppid + modreg(ea1));
		eword(op2 + ea2->reg );
		finish(ea1);
		break;

	case PMOVEO:            /* PMMU store control reg */
		switch(ea1->reg){
		case CRP:
		case SRP:
		case DRP:
			if( ea2->type == DN )
				error("Reg. size mismatch");
			break;
			}
		eword(op + Ppid + modreg(ea2));
		eword(op2 + ea1->reg );
		finish(ea2);
		break;

	case PSCC:              /* PMMU set on condition (also pflushr) */
		eword( op + Ppid + modreg(ea1));
		eword(op2);
		finish(ea1);
		break;

	case PTEST:             /* PMMU test logical address */
		eword( op + Ppid + modreg(ea2));
		if( ea4->type == AN )
			op2 += (ea4->reg+8)<<5;
		eword( op2 + (check(ea3->const,LOW3)<<10) + pmmu_fc(ea1) );
		finish(ea2);
		break;

	case PTRAPCC:           /* PMMU trap on condition */
		eword(op + Ppid + (Size==W ? 2 : 3 ));
		eword(op2);
		if( Size == L )
			elong(ea1->const);
		else
			eword(check(ea1->const,UWORD));
		break;

	case PVALID:            /* PMMU validate a pointer */
		eword(op + Ppid + modreg(ea2) );
		if( ea1->type == AN )
			eword( op2 + ea1->reg);
		else
			eword(op2);
		finish(ea2);
		break;
#endif

#ifdef COPROC
	case CPINH:             /* co-processor inherent */
		eword( op + cpid(ea1->const) );
		eword( check(ea2->const,LOW6) );
		break;

	case CPBCC:             /* co-processor branch on condition */
		eword( op + cpid(ea1->const)
			  + (Size==L ? 0x40 : 0)
			  + check(ea2->const,LOW6) );
		dist = ea3->const - Pc;
		if( Size == L )
			elong(dist);
		else
			eword(check(dist,SWORD));
		break;

	case CPDBCC:            /* co-processor dec & branch */
		eword( op + cpid(ea1->const) + ea2->reg);
		eword( check(ea2->const,LOW6) );
		dist = ea3->const - Pc;
		eword(check(dist,SWORD));
		break;

	case CPGEN:             /* co-processor generic */
		eword(op + cpid(ea1->const) + modreg(ea3));
		eword( ea2->const );
		finish(ea3);
		break;

	case CPEA:              /* co-processor, 1 ea (save/restore) */
		eword(op + cpid(ea1->const) + modreg(ea2));
		finish(ea2);
		break;

	case CPSCC:             /* co-processor set on condition */
		eword(op + cpid(ea1->const) + modreg(ea3));
		eword( check(ea2->const,LOW6) );
		finish(ea3);
		break;

	case CPTRAPCC:          /* co-processor trap on condition */
		eword(op + cpid(ea1->const) + (Size==W ? 2 : 3 ));
		eword( check(ea2->const,LOW6) );
		if( Size == L )
			elong(ea3->const);
		else
			eword(check(ea3->const,UWORD));
		break;
#endif

#ifdef PSEUDO
	case EQU:               /* equate */
		if(*Label){
			install(Label,ea1->const,SYM);
			Old_pc = ea1->const;    /* override normal */
			P_force++;
			}
		else
			error("EQU requires label");
		break;

	case DC:                /* define constants */
		while(ea1->type != EMPTY ){
			if( ea1->type == EXPR){
				switch(Size){
				case B: emit(ea1->const); break;
				case U:
				case W: eword(ea1->const); break;
				case L: elong(ea1->const); break;
					}
				}
			else{   /* must be STRING */
				ptmp = (char *)ea1->const;
				switch(Size){
				case B: while(*ptmp)emit(*ptmp++); break;
				case U:
				case W: while(*ptmp)eword(*ptmp++); break;
				case L: while(*ptmp)elong(*ptmp++); break;
					}
				free(ea1->const);
				}
			ea1++;
			}
		break;

	case OPT:               /* assembler options */
		do_opt(opt_list);
		break;

	case RORG:              /* relocatable org */
		warn("ORG assumed");
	case ORG:               /* origin */
		Old_pc = Pc = ea1->const;
		f_record();     /* flush out any bytes */
		P_force++;
		break;

	case DS:                /* define storage */
		switch(Size){
		case B: tmp = 1; break;
		case U:
		case W: tmp = 2; break;
		case L:
		case S: tmp = 4; break;
		case D: tmp = 8; break;
		case X:
		case P: tmp = 12; break;
			}
		if(ea1->const){
			tmp *= ea1->const;
			while(tmp--)
				emit(0);
			break;
			}
		ea1->const = tmp;       /* #items was zero, implies align */
		/* fall through to align code */

	case ALIGN:                     /* align Pc to boundary */
		if(ea1->const && (tmp=Pc%ea1->const)){
			tmp = ea1->const - tmp;
			while(tmp--)
				emit(0);
			}
		break;

	case INCLUDE:           /* process include file */
		make_pass(next_str());
		P_force = P_total = 0;
		Line[0] = '\n';
		break;

	case NULL_OP:           /* ignored mnemonic */
		break;
#endif

#ifdef M68HC16
	case LPSTOP:		/* lpstop */
		eword(op);
		eword(op2);
		eword(check(ea1->const,UWORD));
		break;

	case TABEA:		/* table, tablenr (ea) */
		eword( op  + modreg(ea1) );
		eword( op2 +  adreg(ea2) + size76() );
		finish(ea1);
		break;

	case TABREG:		/* table, tablenr (register pair) */
		eword( op + ea1->reg );
		eword( op2 + adreg(ea2) + size76() + ea1->reg2 );
		break;
#endif

	default:
		fatal("Error in Mnemonic table");
		}
}

/*
 *      fsizchk --- check that size of instruction matches src/dst
 */
fsizchk(e)
struct ea *e;
{
	if( (Size&(D|X|P)) && e->type==DN )
	    error("Bad size");
}

/*
 *      check --- verify that constant is within bounds
 */
check(const,type)
int const;
int type;
{
	char    cbuf[100];
	int     lo,hi;
	extern int Pass;

	if( Pass==2 ){
		lo = ckrange[type].r_min;
		hi = ckrange[type].r_max;
		if( const<lo || const>hi ){
			sprintf(cbuf,"Value not in range: [%d,%d]",lo,hi);
			warn(cbuf);
			}
		}
	return(const&ckrange[type].r_mask);
}

/*
 *      size76 --- compute opcode bits 7 and 6 from Size specifier
 */
size76()
{
	int s=0;

	switch(Size){
	case B: s = 0x00; break;
	case W:
	case U: s = 0x40; break;
	case L: s = 0x80; break;
	default:
		fatal("Bad size in size76");
		}
	return(s);
}

/*
 *      size109 --- compute opcode bits 10 and 9 from size specifier
 */
size109()
{
	int s=0;

	switch(Size){
	case B: s = 0x000; break;
	case W:
	case U: s = 0x200; break;
	case L: s = 0x400; break;
	default:
		fatal("Bad size in size109");
		}
	return(s);
}

/*
 *      size109b --- compute opcode bits 10 and 9 from size specifier (alternate)
 */
size109b()
{
	int s = 0;

	switch(Size){
	case B: s = 0x200; break;
	case W:
	case U: s = 0x400; break;
	case L: s = 0x600; break;
	default:
		fatal("Bad size in size109b");
		}
	return(s);
}

/*
 *      adreg --- return 4 bit encoding for An or Dn (shift left by 12)
 */
adreg(e)
struct ea *e;
{
	int r = e->reg;

	if( e->type == AN )
		r += 8;
	return( r<<12);
}

/*
 *	modreg --- generate mode/register field from ea structure
 *
 *	return is a 6-bit field suitable for adding to a base
 *	opcode.
 */
modreg(e)
register struct ea *e;
{
	register int mr = 0;

	switch(e->type){
	case DN:        mr = 000 + e->reg; break;
	case AN:        mr = 010 + e->reg; break;
	case ANI:       mr = 020 + e->reg; break;
	case PSTINC:    mr = 030 + e->reg; break;
	case PREDEC:    mr = 040 + e->reg; break;
	case INDEX:     mr = e->itype == D16AN ? 050+e->reg : 060+e->reg; break;
	case IMMED:     mr = 074; break;
	case EXPR:      mr = e->siz==L ? 071 : 070; break;
	case PCINDEX:   mr = e->itype == D16AN ? 072 : 073; break;
	default:
		fatal("Bad type in modreg");
		}
	return(mr);
}

/*
 *      finish --- generate post-words for an instruction
 */
finish(e)
struct ea *e;
{
	switch(e->type){
	case DN:
	case AN:
	case ANI:
	case PSTINC:
	case PREDEC:
		break;
	case PCINDEX:
		e->const -= Pc;
	case INDEX:
		switch(e->itype){
		case D16AN:
			eword(check(e->const,SWORD));
			break;
		case BRIEF:
			eword( genxreg(e) + check(e->const,SBYTE));
			break;
		case FULL:
			if( e->xn_sup && e->prepst ) /* reserved combination */
				e->prepst = 0;
			eword( genxreg(e) + 0x100 + (e->br_sup<<7) +
			       (e->xn_sup<<6) + (e->bdsiz<<4) +
			       (e->prepst<<2) + e->odsiz );
			switch( e->bdsiz ){
			case 1:
				break;  /* supressed */
			case 2:
				eword(check(e->const,SWORD));
				break;
			case 3:
				elong(e->const);
				break;
			default:
				fatal("finish1");
				}
			switch( e->odsiz ){
			case 0:		/* to allow An indirect w/ index */
			case 1:
				break;  /* supressed */
			case 2:
				eword(check(e->const2,SWORD));
				break;
			case 3:
				elong(e->const2);
				break;
			default:
				fatal("finish2");
				}
			break;
		default:
			fatal("finish3");
			}
		break;
	case IMMED:
		if( Size == L )
			elong(e->const);
		else
			eword(e->const);        /* note: no range check here */
		break;
	case EXPR:
		if( e->siz==L )
			elong(e->const);
		else
			eword(check(e->const,SWORD));
		break;
	default:
		fatal("finish4");
		}
}

/*
 *      genxreg --- generate index register spec for indexed postword
 */
genxreg(e)
struct ea *e;
{
	int     wrd;

	wrd = e->stat2 ? 0x8000 : 0x0000 ;
	wrd += e->reg2<<12;
	if( e->siz == L )
		wrd += (1<<11);
	wrd += e->scl<<9;
	return(wrd);
}

/*
 *      getrlist --- return register list mask for an EA
 */
getrlist(e)
struct ea *e;
{
	int rlist;

	switch(e->type){
	case AN:        rlist = 1<<(e->reg + 8);break;
	case DN:        rlist = 1<< e->reg;	break;
	case RLIST:     rlist = e->reg;		break;
	default:        fatal("getrlist");
		}
	return( rlist );
}

/*
 *      bitfld --- return bit field extension word
 */
bitfld(e,r)
struct ea *e;
int r;
{
	int     offset,width;

	if( e->type != FIELD )
		fatal("Botch in bitfld");

	if( e->stat )
		offset = check(e->const,LOW5);
	else
		offset = e->reg + 0x20;

	if( e->stat2 )
		width = check(e->const2,LOW5);
	else
		width = e->reg2 + 0x20;

	return( (r<<12) + (offset<<6) + width );
}

char    *stypes[] = { "Symbol: ",  "Status:  ", "Data:   ", "Address: ", "Control: ",
		      "Float:  ",  "Fcontrol:", "PCrel:  ", "ZPCrel:  ", "ZAddress:",
		      "ZData:  ",  "Pmmu:    " };

/*
 *      dump_regs --- print reserved register names & classes
 */
dump_regs()
{
	register struct regs *r;
	int     lasttype = 999;

	printf("Reserved Register Names:");
	for(r=iregs; r<&iregs[NIREGS]; r++){
		if( isupper(r->r_name[0]))
			continue;       /* skip uppercase duplicate names */
		if( r->r_type != lasttype ){
			lasttype = r->r_type;
			printf("\n%s\t",stypes[lasttype]);
			}
		printf("%s ",r->r_name);
		}
	printf("\n\n");
}

/*
 *      do_opt --- scan operands and compare against list of options
 */
do_opt(l)
struct opts *l;
{
	char    opt[100];
	char    arg[100];
	char    *p,*q;
	struct opts *lp;

	q = opt;
	arg[0] = '\0';
	while( (p=next_str()) != NULL ){
		while(*p){
			if( *p == '=' ){
				*q = '\0';
				q = arg;
				p++;
				}
			else
				*q++ = *p++;
			}
		*q = '\0';
		for(lp = l; lp->opt_name; lp++ ){
			if( strcmp(lp->opt_name,opt)==0){
				(*lp->opt_func)(arg);
				break;
				}
			}
		if(lp->opt_name)
			serror("Unrecognized OPT: %s",opt);
		}
}

/* opt functions */
o_list(){ Lflag=1; }
o_nolist(){ Lflag=0; }
o_null(){}

#ifdef FLOAT
/*
 *      fsize --- return encoded size for floating point ea
 */
fsize()
{
	int sz;

	switch(Size){
	case L: sz = 0x0000; break;
	case S: sz = 0x0400; break;
	case X: sz = 0x0800; break;
	case P: sz = 0x0C00; break;
	case W: sz = 0x1000; break;
	case D: sz = 0x1400; break;
	case B: sz = 0x1800; break;
/*      case P: sz = 0x1C00; break;     not used? */
	default:
		fatal("Bad size in fsize");
		}
	return(sz);
}

/*
 *      checkfclist --- look for invalid fclist combinations
 *
 *      Dn addressing allowed on ea only if there is a single register
 *      in the list.  An addressing is allowed only if the single
 *      register FPIAR is specified.
 */
checkfclist(r,e)
int r;  /* register list */
struct ea *e;
{
	if( e->type == AN && (r&(FPCR|FPSR)) )
		error("An addressing allowed only on FPIAR");
	else if(e->type==DN ){
		if(r != FPCR && r != FPSR && r != FPIAR )
			error("Only a single FP ctrl. reg may be selected");
		}
}

o_fpid(s)
char *s;
{
	int id;

	if( *s ){
		id = atoi(s);
		if( id<0 || id>7 )
			error("Bad Co-processor id");
		else
			Fpid = id;
		}
}

o_round(s){}
o_prec(s){}
#endif

#ifdef PMMU
/*
 *      pmmu_fc --- return encoding for function code specifier
 */
pmmu_fc(e)
struct ea *e;
{
	int fc;

	if(e->type == EXPR )
		fc = 0x10 + check(e->const,LOW4);
	else if( e->type == DN )
		fc = 0x8 + e->reg;
	else if( e->type == CN && e->reg == SFC )
		fc = 0;
	else if( e->type == CN && e->reg == DFC )
		fc = 1;
	else
		error("Bad Func. Code specifier");
	return(fc);
}
#endif

