/*
 * File: ncode.c
 *
 * Code disassembly routines for IMP compiler
 *
 * Based partly on old GNU disassembly code
 *
 * Bob Eager   January 1995
 *
 */

/*#include "imp.h"*/
/*#include "global.h"*/
#include <stdio.h>
#include <assert.h>
#include <stdarg.h>
#include <stdlib.h>

#define	MAXUBUF		100		/* Size of internal output buffer */

/* Defines for extracting instruction bit fields from bytes */

#define	MOD(a)		(((a)>>6)&7)
#define	REG(a)		(((a)>>3)&7)
#define	RM(a)		((a)&7)
#define	SCALE(a)	(((a)>>6)&7)
#define	INDEX(a)	(((a)>>3)&7)
#define	BASE(a)		((a)&7)

/* Prototypes */

static	char		*addr_to_hex(int);
static	int		bytes(char);
static	void		decompile(void);
static	void		do_modrm(char);
static	void		do_sib(int);
static	void		floating_point(int);
static	unsigned char	getbyte(void);
static	int		modrm(void);
static	void		outhex(char, int, int, int, int);
static	void		percent(char, char);
static	void		reg_name(int, char);
static	int		sib(void);
static	void		ua_str(char *);
static	void		uprintf(char *, ...);
static	void		uputchar(char);

/* Local storage */

static	int		addrsize;	/* Size of addresses (always 32) */
static	unsigned int	col;		/* Output column */
static	int		do_size;	/* 1 to output sizes */
static	int		insl;		/* Length of current instruction */
static	unsigned char	*instbuf;	/* Start of instruction buffer */
static	unsigned int	inst_offset;	/* Offset of current instruction */
static	int		modrmv;		/* Flag for getting modrm byte */
static	int		must_do_size;	/* Local 'do_size' flag */
static	int		opsize;		/* Operand size (always 32) */
static	int		pc;		/* Offset of current byte in input */
static	int		prefix;		/* Segment override prefix byte */
static	int		sibv;		/* Flag for getting SIB byte */
static	char		ubuf[MAXUBUF];	/* Buffer for building output */
static	char		*ubufp;		/* Pointer to next byte in 'ubuf' */
static	int		wordop;		/* Dealing with word or byte operand */

/* Disassembly tables. The tokens signalled by a % character in the strings
   are interpreted as follows:

	First char after '%':
		A - direct address
		C - reg of r/m picks control register
		D - reg of r/m picks debug register
		E - r/m picks operand
		G - reg of r/m picks general register
		I - immediate data
		J - relative IP offset
		K - call/jmp distance
		M - r/m picks memory
		O - no r/m, offset only
		R - mod of r/m picks register only
		S - reg of r/m picks segment register
		T - reg of r/m picks test register
		X - DS:ESI
		Y - ES:EDI
		2 - prefix of two-byte opcode
		e - put in 'E' if use32 (second char is part of reg name)
		    put in 'W' for use16 or 'D' for use32 (second char is 'W')
		j - put in 'E' in JCXZ if prefix == 0x66
		f - floating point (second char is esc value)
		g - do r/m group 'n', n==0..7
		p - prefix
		s - size override (second char is a,o)
		d - put D if double arg, nothing otherwise (PUSHFD, POPFD &c)
		w - put W if word, D if double arg, nothing otherwise
		    (LODSW/LODSD)
		P - simple prefix

	Second char after '%':
		a - two words in memory (BOUND)
		b - byte
		c - byte or word
		d - dword
		e - qword
		f - far CALL/JMP
		n - near CALL/JMP
	        p - 32 or 48 bit pointer
		q - byte/word thingy
		s - six byte pseudo-descriptor
		v - word or dword
		w - word
		x - sign extended byte
		F - use floating regs in mod/rm
		1-8 - group number, ESC value, etc
*/

/* First byte decode. Each sixteen-item group handles a different first
   digit in the first byte. Watch out for AAD and AAM with odd operands. */

static	char	*opmap1[256] = {
/* 0 */
  "ADD %Eb,%Gb",      "ADD %Ev,%Gv",     "ADD %Gb,%Eb",    "ADD %Gv,%Ev",
  "ADD AL,%Ib",       "ADD %eAX,%Iv",    "PUSH ES",        "POP ES",
  "OR %Eb,%Gb",       "OR %Ev,%Gv",      "OR %Gb,%Eb",     "OR %Gv,%Ev",
  "OR AL,%Ib",        "OR %eAX,%Iv",     "PUSH CS",        "%2 ",
/* 1 */
  "ADC %Eb,%Gb",      "ADC %Ev,%Gv",     "ADC %Gb,%Eb",    "ADC %Gv,%Ev",
  "ADC AL,%Ib",       "ADC %eAX,%Iv",    "PUSH SS",        "POP SS",
  "SBB %Eb,%Gb",      "SBB %Ev,%Gv",     "SBB %Gb,%Eb",    "SBB %Gv,%Ev",
  "SBB AL,%Ib",       "SBB %eAX,%Iv",    "PUSH DS",        "POP DS",
/* 2 */
  "AND %Eb,%Gb",      "AND %Ev,%Gv",     "AND %Gb,%Eb",    "AND %Gv,%Ev",
  "AND AL,%Ib",       "AND %eAX,%Iv",    "%pE",            "DAA",
  "SUB %Eb,%Gb",      "SUB %Ev,%Gv",     "SUB %Gb,%Eb",    "SUB %Gv,%Ev",
  "SUB AL,%Ib",       "SUB %eAX,%Iv",    "%pC",            "DAS",
/* 3 */
  "XOR %Eb,%Gb",      "XOR %Ev,%Gv",     "XOR %Gb,%Eb",    "XOR %Gv,%Ev",
  "XOR AL,%Ib",       "XOR %eAX,%Iv",    "%pS",            "AAA",
  "CMP %Eb,%Gb",      "CMP %Ev,%Gv",     "CMP %Gb,%Eb",    "CMP %Gv,%Ev",
  "CMP AL,%Ib",       "CMP %eAX,%Iv",    "%pD",            "AAS",
/* 4 */
  "INC %eAX",         "INC %eCX",        "INC %eDX",       "INC %eBX",
  "INC %eSP",         "INC %eBP",        "INC %eSI",       "INC %eDI",
  "DEC %eAX",         "DEC %eCX",        "DEC %eDX",       "DEC %eBX",
  "DEC %eSP",         "DEC %eBP",        "DEC %eSI",       "DEC %eDI",
/* 5 */
  "PUSH %eAX",        "PUSH %eCX",       "PUSH %eDX",      "PUSH %eBX",
  "PUSH %eSP",        "PUSH %eBP",       "PUSH %eSI",      "PUSH %eDI",
  "POP %eAX",         "POP %eCX",        "POP %eDX",       "POP %eBX",
  "POP %eSP",         "POP %eBP",        "POP %eSI",       "POP %eDI",
/* 6 */
  "PUSHA%d ",         "POPA%d ",         "BOUND %Gv,%Ma",  "ARPL %Ew,%Rw",
  "%pF",              "%pG",             "%so",            "%sa",
  "PUSH %Iv",         "IMUL %Gv,%Ev,%Iv","PUSH %Ix",       "IMUL %Gv,%Ev,%Ib",
  "INSB",             "INS%eW",          "OUTSB",          "OUTS%eW",
/* 7 */
  "JO %Jb",           "JNO %Jb",         "JC %Jb",         "JNC %Jb",
  "JE %Jb",           "JNE %Jb",         "JBE %Jb",        "JA %Jb",
  "JS %Jb",           "JNS %Jb",         "JPE %Jb",        "JPO %Jb",
  "JL %Jb",           "JGE %Jb",         "JLE %Jb",        "JG %Jb",
/* 8 */
  "%g0 %Eb,%Ib",      "%g0 %Ev,%Iv",     "%g0 %Ev,%Ix",    "%g0 %Ev,%Ix",
  "TEST %Eb,%Gb",     "TEST %Ev,%Gv",    "XCHG %Eb,%Gb",   "XCHG %Ev,%Gv",
  "MOV %Eb,%Gb",      "MOV %Ev,%Gv",     "MOV %Gb,%Eb",    "MOV %Gv,%Ev",
  "MOV %Ew,%Sw",      "LEA %Gv,%M ",     "MOV %Sw,%Ew",    "POP %Ev",
/* 9 */
  "NOP",              "XCHG %eCX,%eAX",  "XCHG %eDX,%eAX", "XCHG %eBX,%eAX",
  "XCHG %eSP,%eAX",   "XCHG %eBP,%eAX",  "XCHG %eSI,%eAX", "XCHG %eDI,%eAX",
  "CBW",              "CWD",             "CALL %Ap",       "FWAIT",
  "PUSHF%d ",         "POPF%d ",         "SAHF",           "LAHF",
/* A */
  "MOV AL,%Oc",       "MOV %eAX,%Ov",    "MOV %Oc,AL",     "MOV %Ov,%eAX",
  "%P MOVSB",         "%P MOVS%w ",      "%P CMPSB",       "%P CMPS%w ",
  "TEST AL,%Ib",      "TEST %eAX,%Iv",   "%P STOSB",       "%P STOS%w ",
  "%P LODSB",         "%P LODS%w ",      "%P SCASB",       "%P SCAS%w ",
/* B */
  "MOV AL,%Ib",       "MOV CL,%Ib",      "MOV DL,%Ib",     "MOV BL,%Ib",
  "MOV AH,%Ib",       "MOV CH,%Ib",      "MOV DH,%Ib",     "MOV BH,%Ib",
  "MOV %eAX,%Iv",     "MOV %eCX,%Iv",    "MOV %eDX,%Iv",   "MOV %eBX,%Iv",
  "MOV %eSP,%Iv",     "MOV %eBP,%Iv",    "MOV %eSI,%Iv",   "MOV %eDI,%Iv",
/* C */
  "%g1 %Eb,%Ib",      "%g1 %Ev,%Ib",     "RET %Iw",        "RET",
  "LES %Gv,%Mp",      "LDS %Gv,%Mp",     "MOV %Eb,%Ib",    "MOV %Ev,%Iv",
  "ENTER %Iw,%Ib",    "LEAVE",           "RETF %Iw",       "RETF",
  "INT 03",           "INT %Ib",         "INTO",           "IRET",
/* D */
  "%g1 %Eb,1",        "%g1 %Ev,1",       "%g1 %Eb,CL",     "%g1 %Ev,CL",
  "AAM ; %Ib",        "AAD ; %Ib",       "SETALC",         "XLAT",
  "%f0",              "%f1",             "%f2",            "%f3",
  "%f4",              "%f5",             "%f6",            "%f7",
/* E */
  "LOOPNE %Jb",       "LOOPE %Jb",       "LOOP %Jb",       "J%jCXZ %Jb",
  "IN AL,%Ib",        "IN %eAX,%Ib",     "OUT %Ib,AL",     "OUT %Ib,%eAX",
  "CALL %Jv",         "JMP %Jv",         "JMP %Ap",        "JMP %Ks%Jb",
  "IN AL,DX",         "IN %eAX,DX",      "OUT DX,AL",      "OUT DX,%eAX",
/* F */
  "LOCK %p ",         0,                 "REPNE %p ",      "REPE %p ",
  "HLT",              "CMC",             "%g2",            "%g2",
  "CLC",              "STC",             "CLI",            "STI",
  "CLD",              "STD",             "%g3",            "%g4"
};

/* Second byte decode for first byte of 0F. */

static	char	*second[256] = {
/* 0 */
  "%g5",              "%g6",             "LAR %Gv,%Ew",    "LSL %Gv,%Ew",
  0,                  "LOADALL",         "CLTS",           "LOADALL",
  "INVD",             "WBINVD",          0,                0,
  0,                  0,                 0,                0,
/* 1 */
  "MOV %Eb,%Gb",      "MOV %Ev,%Gv",     "MOV %Gb,%Eb",    "MOV %Gv,%Ev",
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
/* 2 */
  "MOV %Rd,%Cd",      "MOV %Rd,%Dd",     "MOV %Cd,%Rd",    "MOV %Dd,%Rd",
  "MOV %Rd,%Td",      0,                 "MOV %Td,%Rd",    0,
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
/* 3 */
  "WRMSR",            0,                 "RDMSR",          0,
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
/* 4 */
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
/* 5 */
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
/* 6 */
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
/* 7 */
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
/* 8 */
  "JO %Jv",           "JNO %Jv",         "JB %Jv",         "JNB %Jv",
  "JZ %Jv",           "JNZ %Jv",         "JBE %Jv",        "JA %Jv",
  "JS %Jv",           "JNS %Jv",         "JP %Jv",         "JNP %Jv",
  "JL %Jv",           "JGE %Jv",         "JLE %Jv",        "JG %Jv",
/* 9 */
  "SETO %Eb",         "SETNO %Eb",       "SETC %Eb",       "SETNC %Eb",
  "SETZ %Eb",         "SETNZ %Eb",       "SETBE %Eb",      "SETNBE %Eb",
  "SETS %Eb",         "SETNS %Eb",       "SETP %Eb",       "SETNP %Eb",
  "SETL %Eb",         "SETGE %Eb",       "SETLE %Eb",      "SETG %Eb",
/* A */
  "PUSH FS",          "POP FS",          "CPUID",          "BT %Ev,%Gv",
  "SHLD %Ev,%Gv,%Ib", "shld %Ev,%Gv,CL", 0,                0,
  "PUSH GS",          "POP GS",          "RSM",            "BTS %Ev,%Gv",
  "SHRD %Ev,%Gv,%Ib", "SHRD %Ev,%Gv,CL", 0,                "IMUL %Gv,%Ev",
/* B */
  "CMPXCHG %Eb,%Gb",  "CMPXCHG %Ev,%Gv", "LSS %Mp",        "BTR %Ev,%Gv",
  "LFS %Mp",          "LGS %Mp",         "MOVZX %Gv,%Eb",  "MOVZX %Gv,%Ew",
  0,                  0,                 "%g7 %Ev,%Ib",    "BTC %Ev,%Gv",
  "BSF %Gv,%Ev",      "BSR %Gv,%Ev",     "MOVSX %Gv,%Eb",  "MOVSX %Gv,%Ew",
/* C */
  "XADD %Eb,%Gb",     "XADD %Ev,%Gv",    0,                0,
  0,                  0,                 0,                "CMPXCHG8B %Ee",
  "BSWAP EAX",        "BSWAP ECX",       "BSWAP EDX",      "BSWAP EBX",
  "BSWAP ESP",        "BSWAP EBP",       "BSWAP ESI",      "BSWAP EDI",
/* D */
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
/* E */
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
/* F */
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
  0,                  0,                 0,                0,
  0,                  0,                 0,                0
};

/* Group decode. */

static	char	*groups[8][8] = {   /* Group 0 is group 3 for %Ev set */
/* 0 (Group A) */
  { "ADD",            "OR",              "ADC",            "SBB",
    "AND",            "SUB",             "XOR",            "CMP"           },
/* 1 (Group B) */
  { "ROL",            "ROR",             "RCL",            "RCR",
    "SHL",            "SHR",             "SHL",            "SAR"           },
/* 2 (Group C) */
  { "TEST %Eq,%Iq",   "TEST %Eq,%Iq",    "NOT %Ev",        "NEG %Ev",
    "MUL %Ec",        "IMUL %Ec",        "DIV %Ec",        "IDIV %Ec" },
/* 3 (Group D) */
  { "INC %Eb",        "DEC %Eb",         0,                0,
    0,                0,                 0,                0               },
/* 4 (Group E) */
  { "INC %Ev",        "DEC %Ev",         "CALL %Kn%Ev",    "CALL %Kf%Ep",
    "JMP %Kn%Ev",     "JMP %Kf%Ep",      "PUSH %Ev",       0               },
/* 5 (Group F) */
  { "SLDT %Ew",       "STR %Ew",         "LLDT %Ew",       "LTR %Ew",
    "VERR %Ew",       "VERW %Ew",        0,                0               },
/* 6 (Group G) */
  { "SGDT %Ms",       "SIDT %Ms",        "LGDT %Ms",       "LIDT %Ms",
    "SMSW %Ew",       0,                 "LMSW %Ew",       0               },
/* 7 */
  { 0,                0,                 0,                0,
    "BT",             "BTS",             "BTR",            "BTC"           }
};

/* Floating point tables. */
/* Zero here means invalid.  If first entry starts with '*', use st(i) */
/* no assumed %EFs here.  Indexed by RM(modrm())                       */

static	char	*f0[]     = { 0,         0,         0,         0,
		              0,         0,         0,         0};
static	char	*fop_9[]  = { "*FXCH ST,%GF" };
static	char	*fop_10[] = { "FNOP",    0,         0,         0,
		              0,         0,         0,         0 };
static	char	*fop_12[] = { "FCHS",    "FABS",    0,         0,
		              "FTST",    "FXAM",    0,         0 };
static	char	*fop_13[] = { "FLD1",    "FLDL2T",  "FLDL2E",  "FLDPI",
		              "FLDLG2",  "FLDLN2",  "FLDZ",    0 };
static	char	*fop_14[] = { "F2XM1",   "FYL2X",   "FPTAN",   "FPATAN",
			      "FXTRACT", "FPREM1",  "FDECSTP", "FINCSTP" };
static	char	*fop_15[] = { "FPREM",   "FYL2XP1", "FSQRT",   "FSINCOS",
		              "FRNDINT", "FSCALE",  "FSIN",    "FCOS" };
static	char	*fop_21[] = { 0,         "FUCOMPP", 0,         0,
		              0,         0,         0,         0 };
static	char	*fop_28[] = { 0,         0,         "FCLEX",   "FINIT",
		              0,         0,         0,         0 };
static	char	*fop_32[] = { "*FADD %GF,ST" };
static	char	*fop_33[] = { "*FMUL %GF,ST" };
static	char	*fop_36[] = { "*FSUBR %GF,ST" };
static	char	*fop_37[] = { "*FSUB %GF,ST" };
static	char	*fop_38[] = { "*FDIVR %GF,ST" };
static	char	*fop_39[] = { "*FDIV %GF,ST" };
static	char	*fop_40[] = { "*FFREE %GF" };
static	char	*fop_42[] = { "*FST %GF" };
static	char	*fop_43[] = { "*FSTP %GF" };
static	char	*fop_44[] = { "*FUCOM %GF" };
static	char	*fop_45[] = { "*FUCOMP %GF" };
static	char	*fop_48[] = { "*FADDP %GF,ST" };
static	char	*fop_49[] = { "*FMULP %GF,ST" };
static	char	*fop_51[] = { 0,         "FCOMPP",  0,         0,
		              0,         0,         0,         0 };
static	char	*fop_52[] = { "*FSUBRP %GF,ST" };
static	char	*fop_53[] = { "*FSUBP %GF,ST" };
static	char	*fop_54[] = { "*FDIVRP %GF,ST" };
static	char	*fop_55[] = { "*FDIVP %GF,ST" };
static	char	*fop_60[] = { "FSTSW AX",0,         0,         0,
		              0,         0,         0,         0 };

 /* 0=use st(i), 1=undefined 0 in fop_* means undefined */

static	char	**fspecial[] = {
  0,        0,        0,        0,        0,        0,        0,        0,
  0,        fop_9,    fop_10,   0,        fop_12,   fop_13,   fop_14,   fop_15,
  f0,       f0,       f0,       f0,       f0,       fop_21,   f0,       f0,
  f0,       f0,       f0,       f0,       fop_28,   f0,       f0,       f0,
  fop_32,   fop_33,   f0,       f0,       fop_36,   fop_37,   fop_38,   fop_39,
  fop_40,   f0,       fop_42,   fop_43,   fop_44,   fop_45,   f0,       f0,
  fop_48,   fop_49,   f0,       fop_51,   fop_52,   fop_53,   fop_54,   fop_55,
  f0,       f0,       f0,       f0,       fop_60,   f0,       f0,       f0
};

/* Assumed " %EF" at end of each.  mod != 3 only */

static	char	*floatops[] = { 
/* 00 */
  "FADD",             "FMUL",            "FCOM",           "FCOMP",
  "FSUB",             "FSUBR",           "FDIV",           "FDIVR",
/* 08 */
  "FLD",              0,                 "FST",            "FSTP",
  "FLDENV",           "FLDCW",           "FSTENV",         "FSTCW",
/* 16 */
  "FIADD",            "FIMUL",           "FICOMW",         "FICOMPW",
  "FISUB",            "FISUBR",          "FIDIV",          "FIDIVR",
/* 24 */
  "FILD",             0,                 "FIST",           "FISTP",
  "FRSTOR",           "FLDT",            0,                "FSTPT",
/* 32 */
  "FADDQ",            "FMULQ",           "FCOMQ",          "FCOMPQ",
  "FSUBQ",            "FSUBRQ",          "FDIVQ",          "FDIVRQ",
/* 40 */
  "FLDQ",             0,                 "FSTQ",           "FSTPQ",
  0,                  0,                 "FSAVE",          "FSTSW",
/* 48 */
  "FIADDW",           "FIMULW",          "FICOMW",         "FICOMPW",
  "FISUBW",           "FISUBRW",         "FIDIVW",         "FIDIVR",
/* 56 */
  "FILDW",            0,                 "FISTW",          "FISTPW",
  "FBLDT",            "FILDQ",           "FBSTPT",         "FISTPQ"
};

FILE *listfp = stdout;
void ncode(unsigned char *, unsigned char *, unsigned int, char);
unsigned int hex_to_int(char *);

unsigned int hex_to_int(char *s) 
{
	unsigned int retval = 0;
	char ch;

	while(*s) {
		ch = *s;
		retval <<= 4;
		if(ch >= '0' && ch <= '9')
			retval += ch-'0';
		else {
			ch |= 32;
			if(ch >= 'a' && ch <= 'f')
				retval += ch-('a'-10);
		}
		s++;
	}
	return retval;
}


int main(int argc, char **argv)
{
	unsigned int start = 0, end = -1, address = 0; 
	unsigned int len, filelen;
	FILE *fp;
	char *buf;
	char is_32bit = 1;

	if(argc < 2) {
	  	fprintf(stderr, 	
		"usage: disasm file [-16] [-s start] [-e end] [-a address]\n");
		return 1;
	}
	
	argv++;
	fp = fopen(*argv, "rb");
	if(fp == NULL) {
		printf("cant open file %s\n", *argv);
		return 1;
	}
	if(argc > 2) {
		argv ++;
		argc -= 2;
		while(argc--) {
			if(!strcmp(*argv, "-s")) {
				argv++;
				start = hex_to_int(*argv);
				argc--;
			} 
			else if(!strcmp(*argv, "-e")) {
				argv++;
				end = hex_to_int(*argv);
				argc--;
			}
			else if(!strcmp(*argv, "-a")) {
				argv++;
				address = hex_to_int(*argv);
				argc--;
			}
			else if(!strcmp(*argv, "-16")) {
				is_32bit = 0;
			}
			else if(!strcmp(*argv, "-32")) {
				is_32bit = 1;
			}
			argv++;
		}
	}


	fseek(fp, 0L, 2);
	filelen = (unsigned int)ftell(fp);
	rewind(fp);

	fseek(fp, (long)start, 0);
	if(end == -1) 
		end = filelen;
	len = (end - start) + 16;
	if(len > filelen) len = filelen;
	
	printf("start: %05X\tend: %05X\taddress: %05X\n",
		start, end, address);
	buf = (char *)malloc(len);
	if(buf == NULL) {
		fprintf(stderr, "error: out of memory\n");
		return 1;
	}
	if(fread(buf, 1, len, fp) != len) {
		fprintf(stderr, "error reading file\n");
		return 1;
	}
	fclose(fp);
	ncode(buf, buf+(end-start)+1, address, is_32bit);
	free(buf);
	return 0;
}
	

/*
 * Main disassembly routine; 'start' is the address of the first byte
 * to be disassembled, and 'finish' is the address of the first byte
 * not to be disassembled. 'address' is the code address, to be included
 * as part of the listing; it can be any value you like.
 *
 */

void ncode(unsigned char *start, unsigned char *finish, unsigned int address,
	   char is_32bit)
{	int all = finish - start;	/* Number of bytes to disassemble */

	pc = 0;
	instbuf = start;
	do_size = 1;			/* Always output sizes */


	while(pc < all) {
		inst_offset = address + pc;
		fprintf(listfp, "%05X    ", inst_offset);
		addrsize = opsize = (is_32bit ? 32 : 16);
		decompile();
	}
	fputc('\n', listfp);
}


/*
 * Routine to output interpretation of the current instruction.
 *
 */

static void decompile(void)
{	int b;
	char *s;

	col = 0;
	prefix = 0;
	modrmv = -1;			/* No modrm byte yet */
	sibv = -1;			/* No SIB byte yet */
#if 0
	opsize = 32;
	addrsize = 32;
#endif
	ubufp = ubuf;			/* Reset internal buffer */
	insl = 0;			/* Reset instruction length */
	b = getbyte();
	wordop = b & 1;
	must_do_size = do_size;

	s = opmap1[b];			/* Do primary decode */
	if(s == 0) {			/* Invalid instruction? ... */
		uputchar('D');		/* ... then output byte define */
		uputchar('B');
		uputchar('\t');
		uprintf("%02X", b);
	} else {
		ua_str(s);		/* Valid instruction */
	}
	fprintf(listfp, "%*s", 15 - col, " ");
	col = 15 + strlen(ubuf);
	do {
		uputchar(' ');
		col++;
	} while (col < 43);
	fprintf(listfp, "%s\n", ubuf);
}


/*
 * Routine to return the next byte from the instruction stream.
 *
 */

static unsigned char getbyte(void)
{	unsigned char b;

	b = instbuf[pc++];
	fprintf(listfp, "%02X", b);	/* Print out byte */
	insl++;
	inst_offset++;
	col += 2;
	return(b);
}


/*
 * Routine to output a character to 'ubuf'.
 *
 */

static void uputchar(char ch)
{	*ubufp++ = ch;
	*ubufp = 0;
}


/*
 * Routine to output a formatted string to 'ubuf'.
 *
 */

static void uprintf(char *s, ...)
{	va_list ap;

	va_start(ap, s);
	vsprintf(ubufp, s, ap);
	va_end(ap);

	while(*ubufp) ubufp++;		/* Move to terminator */
}


/*
 * Routine to place decoded instruction into 'ubuf', using the decode
 * string 's'.
 *
 */

static void ua_str(char *s)
{	char ch;

	if(s == (char *) NULL) {
		uprintf("<invalid>");
	} else {
		while((ch = *s++) != 0) {
			if(ch == '%') {
				ch = *s++;
				percent(ch, *s++);
			} else {
				if(ch == ' ') ch = '\t';
				if(ch == '@') ch = ' ';
				uputchar(ch);
			}
		}
	}
}


/*
 * Main decode driver. Uses the specifier characters 'type' and 'subtype'
 * (found after a '%' in the decode string) to generate the correct output
 * in 'ubuf'.
 *
 */

static void percent(char type, char subtype)
{	unsigned int vofs = 0;
	char *name;
	int extend = (addrsize == 32) ? 4 : 2;
	unsigned char c;

	switch(type) {
		case 'A':		/* Direct address */
			outhex(subtype, extend, 0, addrsize, 0);
			break;

		case 'C':		/* reg(r/m) picks control reg */
			uprintf("CR%d", REG(modrm()));
			must_do_size = 0;
			break;

		case 'D':		/* reg(r/m) picks debug reg */
			uprintf("DR%d", REG(modrm()));
			must_do_size = 0;
			break;

		case 'E':		/* r/m picks operand */
			do_modrm(subtype);
			break;

		case 'G':		/* reg(r/m) picks register */
			if(subtype == 'f')
				reg_name(RM(modrm()), subtype);
			else
				reg_name(REG(modrm()), subtype);
			must_do_size = 0;
			break;

		case 'I':		/* Immediate data */
			outhex(subtype, 0, 0, opsize, 0);
			break;

		case 'J':		/* Relative IP offset */
			switch(bytes(subtype)) {/* Size of offset value */
				case 1:
					vofs = (unsigned int) (signed char) getbyte();
					break;

				case 2:
					vofs = getbyte();
					vofs += getbyte() << 8;
					vofs = (unsigned int) (signed short) vofs;
					break;

				case 4:
					vofs = (unsigned int) getbyte();
					vofs |= (unsigned int) getbyte() << 8;
					vofs |= (unsigned int) getbyte() << 16;
					vofs |= (unsigned int) getbyte() << 24;
					break;
			}
			name = addr_to_hex((int) (vofs + inst_offset));
			uprintf("%s", name);
			break;

		case 'K':
			switch(subtype) {
				case 'f':
					ua_str("FAR@");
					break;

				case 'n':
					ua_str("NEAR@");
					break;

				case 's':
					ua_str("SHORT@");
					break;
			}
			break;

		case 'M':		/* r/m picks memory */
			do_modrm(subtype);
			break;

		case 'O':		/* Offset only */
			ua_str("%p:[");
			outhex(subtype, extend, 0, addrsize, 0);
			uputchar(']');
			break;

		case 'P':		/* Prefix byte */
			ua_str("%p:");
			break;

		case 'R':		/* mod(r/m) picks register */
			reg_name(REG(modrm()), subtype);
			must_do_size = 0;
			break;

		case 'S':		/* reg(r/m) picks segment register */
			uputchar("ECSDFG"[REG(modrm())]);
			uputchar('S');
			must_do_size = 0;
			break;

		case 'T':		/* reg(r/m) picks T reg */
			uprintf("TR%d", REG(modrm()));
			must_do_size = 0;
			break;

		case 'X':		/* DS:SI type operator */
			uprintf("DS:[");
			if(addrsize == 32) uputchar('E');
			uprintf("SI]");
			break;

		case 'Y':		/* ES:DI type operator */
			uprintf("ES:[");
			if(addrsize == 32) uputchar('E');
			uprintf("DI]");
			break;

		case '2':		/* Extended decode with second byte */
			ua_str(second[getbyte()]);
			break;

		case 'g':		/* modrm group 'subtype' (0--7) */
			ua_str(groups[subtype-'0'][REG(modrm())]);
			break;

		case 'd':		/* Size of operand == dword? */
			if(opsize == 32) uputchar('D');
			uputchar(subtype);/* No real subtype; following char */
			break;

		case 'w':		/* Insert explicit size specifier */
			if(opsize == 32) uputchar('D');
			else uputchar('W');
			uputchar(subtype);/* No real subtype; following char */
			break;

		case 'e':		/* Extended reg name */
			if(opsize == 32) {
				if(subtype == 'w') uputchar('D');
				else {
					uputchar('E');
					uputchar(subtype);
				}
			} else uputchar(subtype);
			break;

		case 'f':		/* 80x87 opcode */
			floating_point(subtype-'0');
			break;

		case 'j':
			if(addrsize == 32 || opsize == 32) /* both of them?! */
				uputchar('E');
			break;

		case 'p':		/* Prefix byte */
			switch(subtype)  {
				case 'C':
				case 'D':
				case 'E':
				case 'F':
				case 'G':
				case 'S':
					prefix = subtype;
					c = getbyte();
					wordop = c & 1;
					ua_str(opmap1[c]);
					break;

				case ':':
					if(prefix) uprintf("%cS:", prefix);
					break;

				case ' ':
					c = getbyte();
					wordop = c & 1;
					ua_str(opmap1[c]);
					break;
			}
			break;

		case 's':		/* Size override */
			switch(subtype) {
				case 'a':
					addrsize = 48 - addrsize;
					c = getbyte();
					wordop = c & 1;
					ua_str(opmap1[c]);
					/* ua_str(opmap1[getbyte()]); */
					break;
				case 'o':
					opsize = 48 - opsize;
					c = getbyte();
					wordop = c & 1;
					ua_str(opmap1[c]);
					/* ua_str(opmap1[getbyte()]); */
					break;
			}
			break;
	}
}


/*
 * Routine to output an operand in hexadecimal.
 *
 */

static void outhex(char subtype, int extend, int optional, int defsize, int sign)
{	int i;
	int n = 0;
	int s = 0;
	int delta = 0;
	unsigned char buff[6];
	char *name;
	char signchar;

	switch(subtype) {
		case 'q':
			if(wordop) {
				if(opsize == 16) n = 2;
				else n = 4;
			} else n = 1;
			break;

		case 'a':
			break;

		case 'x':
			extend = 2;
			n = 1;
			break;

		case 'b':
			n = 1;
			break;

		case 'w':
			n = 2;
			break;

		case 'd':
			n = 4;
			break;

		case 's':
			n = 6;
			break;

		case 'c':
		case 'v':
			if(defsize == 32) n = 4;
			else n = 2;
			break;

		case 'p':
			if(defsize == 32) n = 6;
			else n = 4;
			s = 1;
			break;
	}

	for (i = 0; i < n; i++)
		buff[i] = getbyte();
	for (; i < extend; i++)
		buff[i] = (unsigned char) ((buff[i-1] & (unsigned char) 0x80) ?
			  0xff : 0);

	if(s) {
		uprintf("%02X%02X:", buff[n-1], buff[n-2]);
		n -= 2;
	}

	switch(n) {
		case 1:
			delta = *(signed char *) buff;
			break;
		case 2:
			delta = *(signed short *) buff;
			break;

		case 4:
			delta = *(signed int *) buff;
			break;
	}

	if(extend > n) {
		if(subtype != 'x') {
			if(delta < 0) {
				delta = -delta;
				signchar = '-';
			} else signchar = '+';
			if(delta || !optional)
				uprintf("%c%0*X", signchar, extend, delta);
		} else {
			if(extend == 2)
				delta = (unsigned short) delta;
				uprintf("%0.*X", 2*extend+1, delta);
		}
		return;
	}

	if((n == 4) && !sign) {
		name = addr_to_hex(delta);
		uprintf("%s", name);
		return;
	}

	switch(n) {
		case 1:
			delta = (int) (signed char) delta;
			if(sign && delta < 0) {
				delta = -delta;
				signchar = '-';
			} else signchar = '+';
			if(sign)
				uprintf("%c%02X",signchar, (unsigned char) delta);
			else
				uprintf("%02X", (unsigned char) delta);
			break;

		case 2:
			if(sign && (short) delta < 0) {
				signchar = '-';
				delta = -delta;
			} else signchar = '+';
			if(sign)
				uprintf("%c%04X", signchar, (short) delta);
			else
				uprintf("%04X", (unsigned short) delta);
			break;

		case 4:
			if(sign && delta < 0) {
				delta = -delta;
				signchar = '-';
			} else signchar = '+';
			if(sign)
				uprintf("%c%08X", signchar, delta);
			else
				uprintf("%08X", delta);
			break;
	}
}


/*
 * Routine to decode the modrm byte, and any resulting bytes.
 *
 */

static void do_modrm(char subtype)
{	int mod = MOD(modrm());
	int rm = RM(modrm());
	int extend = (addrsize == 32) ? 4 : 2;

	if(mod == 3) {		/* Specifies two registers */
		reg_name(rm, subtype);
		return;
	}

	if(must_do_size) {
		if(wordop) {
			if(addrsize == 32 || opsize == 32)
				ua_str("DWORD@PTR@");
			else
				ua_str("WORD@PTR@");
		} else ua_str("BYTE@PTR@");
	}

	if((mod == 0) && (rm == 5) && (addrsize == 32)) {
					/* Mem operand with 32 bit offset */
		ua_str("%p:[");
		outhex('d', extend, 0, addrsize, 0);
		uputchar(']');
		return;
	}

	if((mod == 0) && (rm == 6) && (addrsize == 16)) {
					/* 16 bit displacement */
		ua_str("%p:[");
		outhex('w', extend, 0, addrsize, 0);
		uputchar(']');
		return;
	}

	if((addrsize != 32) || (rm != 4)) ua_str("%p:[");

	if(addrsize == 16) {
		switch(rm) {
			case 0: uprintf("BX+SI"); break;
			case 1: uprintf("BX+DI"); break;
			case 2: uprintf("BP+SI"); break;
			case 3: uprintf("BP+DI"); break;
			case 4: uprintf("SI");    break;
			case 5: uprintf("DI");    break;
			case 6: uprintf("BP");    break;
			case 7: uprintf("BX");    break;
		}
	} else {
		switch(rm) {
			case 0: uprintf("EAX"); break;
			case 1: uprintf("ECX"); break;
			case 2: uprintf("EDX"); break;
			case 3: uprintf("EBX"); break;
			case 4: do_sib(mod);    break;
			case 5: uprintf("EBP"); break;
			case 6: uprintf("ESI"); break;
			case 7: uprintf("EDI"); break;
		}
	}

	switch(mod) {
		case 1:
			outhex('b', extend, 1, addrsize, 0);
			break;

		case 2:
			outhex('v', extend, 1, addrsize, 1);
			break;
	}
	uputchar(']');
}


/*
 * Routine to output a register name, based on a register number and
 * the register size.
 *
 */

static void reg_name(int regnum, char size)
{	if(size == 'f') {		/* Floating point register? */
		uprintf("ST(%d)", regnum);
		return;
	}

	if(((size == 'v') && (opsize == 32)) || (size == 'd'))
		uputchar('E');

	if((size == 'q' || size == 'b' || size == 'c') && !wordop) {
		uputchar("ACDBACDB"[regnum]);
		uputchar("LLLLHHHH"[regnum]);
	} else {
		uputchar("ACDBSBSD"[regnum]);
		uputchar("XXXXPPII"[regnum]);
	}
}


/*
 * Return the number of bytes in an operand described by the subtype
 * character 'ch'.
 *
 */

static int bytes(char ch)
{	switch(ch) {
		case 'b':
			return(1);

		case 'w':
			return(2);

		case 'd':
			return(4);

		case 'v':
			if(opsize == 32) return(4);
			else return(2);
	}
	return(0);
}


/*
 * Convert a 32-bit address to hexadecimal.
 *
 */

static char *addr_to_hex(int addr)
{	static char buffer[11];

	sprintf(buffer, "%08XH", addr);

	return(buffer);
}


/*
 * Handle floating point decode.
 *
 */

static void floating_point(int e1)
{	int esc = e1*8 + REG(modrm());

	if(MOD(modrm()) == 3) {
		if(fspecial[esc]) {
			if(fspecial[esc][0][0] == '*') {
				ua_str(fspecial[esc][0]+1);
			} else {
				ua_str(fspecial[esc][RM(modrm())]);
			}
		} else {
			ua_str(floatops[esc]);
			ua_str(" %EF");
		}
	} else {
		ua_str(floatops[esc]);
		ua_str(" %EF");
	}
}


/*
 * Routine to return the modrm byte. It may be requested more than once,
 * so we need to extract only one byte for multiple calls.
 *
 */

static int modrm(void)
{	if(modrmv == -1)
		modrmv = getbyte();
	return(modrmv);
}


/*
 * Routine to output the decode for the SIB byte.
 *
 */

static void do_sib(int m)
{	int s, i, b;

	s = SCALE(sib());
	i = INDEX(sib());
	b = BASE(sib());

	switch(b) {			/* Pick base */
		case 0: ua_str("%p:[EAX"); break;
		case 1: ua_str("%p:[ECX"); break;
		case 2: ua_str("%p:[EDX"); break;
		case 3: ua_str("%p:[EBX"); break;
		case 4: ua_str("%p:[ESP"); break;
		case 5:
			if(m == 0) {
				ua_str("%p:[");
				outhex('d', 4, 0, addrsize, 0);
			} else {
				ua_str("%p:[EBP");
			}
			break;
		case 6: ua_str("%p:[ESI"); break;
		case 7: ua_str("%p:[EDI"); break;
	}

	switch(i) {			/* and index */
		case 0: uprintf("+EAX"); break;
		case 1: uprintf("+ECX"); break;
		case 2: uprintf("+EDX"); break;
		case 3: uprintf("+EBX"); break;
		case 4:                  break;
		case 5: uprintf("+EBP"); break;
		case 6: uprintf("+ESI"); break;
		case 7: uprintf("+EDI"); break;
	}
	if(i != 4) {
		switch(s) {		/* and scale */
			case 0: uprintf("");   break;
			case 1: uprintf("*2"); break;
			case 2: uprintf("*4"); break;
			case 3: uprintf("*8"); break;
		}
	}
}


/*
 * Routine to return the SIB byte. It may be requested more than once,
 * so we need to extract only one byte for multiple calls.
 *
 */

static int sib(void)
{	if(sibv == -1)
		sibv = getbyte();
	return(sibv);
}

/*
 * End of file: ncode.c
 *
 */
