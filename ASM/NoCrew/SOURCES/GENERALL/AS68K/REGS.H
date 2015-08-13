/* Register definitions */

/* movec registers */
#define SFC     0x000
#define DFC     0x001
#define CACR    0x002
#define USP     0x800
#define VBR     0x801
#define CAAR    0x802
#define MSP     0x803
#define ISP     0x804

/* floating point */
#define FPCR    (1<<12)
#define FPSR    (1<<11)
#define FPIAR   (1<<10)

/* memory management */
#define TC      0x4000
#define DRP     0x4400
#define SRP     0x4800
#define CRP     0x4C00
#define CAL     0x5000
#define VAL     0x5400
#define SCC     0x5800
#define AC      0x5C00
#define BAD0    0x7000
#define BAD1    0x7004
#define BAD2    0x7008
#define BAD3    0x700C
#define BAD4    0x7010
#define BAD5    0x7014
#define BAD6    0x7018
#define BAD7    0x701C
#define BAC0    0x7400
#define BAC1    0x7404
#define BAC2    0x7408
#define BAC3    0x740C
#define BAC4    0x7410
#define BAC5    0x7414
#define BAC6    0x7418
#define BAC7    0x741C
#define PSR     0x6000
#define PCSR    0x6400
#define TT0     0x0800	/* 68030 only */
#define TT1     0x0C00	/* 68030 only */

struct regs {
	char *r_name;
	char r_type;
	int  r_value;
	};

struct regs iregs[] = { /* pre-defined internal register names */
#ifdef M68020
"CAAR", CREG,   CAAR,
"caar", CREG,   CAAR,
"CACR", CREG,   CACR,
"cacr", CREG,   CACR,
"ISP",  CREG,   ISP,
"isp",  CREG,   ISP,
"MSP",  CREG,   MSP,
"msp",  CREG,   MSP,
#endif
"DFC",  CREG,   DFC,
"dfc",  CREG,   DFC,
"SFC",  CREG,   SFC,
"sfc",  CREG,   SFC,
"USP",  CREG,   USP,
"usp",  CREG,   USP,
"VBR",  CREG,   VBR,
"vbr",  CREG,   VBR,

/* extended indexed addressing registers */
"ZA0",  ZAREG,  0,
"za0",  ZAREG,  0,
"ZA1",  ZAREG,  1,
"za1",  ZAREG,  1,
"ZA2",  ZAREG,  2,
"za2",  ZAREG,  2,
"ZA3",  ZAREG,  3,
"za3",  ZAREG,  3,
"ZA4",  ZAREG,  4,
"za4",  ZAREG,  4,
"ZA5",  ZAREG,  5,
"za5",  ZAREG,  5,
"ZA6",  ZAREG,  6,
"za6",  ZAREG,  6,
"ZA7",  ZAREG,  7,
"za7",  ZAREG,  7,
"ZD0",  ZDREG,  0,
"zd0",  ZDREG,  0,
"ZD1",  ZDREG,  1,
"zd1",  ZDREG,  1,
"ZD2",  ZDREG,  2,
"zd2",  ZDREG,  2,
"ZD3",  ZDREG,  3,
"zd3",  ZDREG,  3,
"ZD4",  ZDREG,  4,
"zd4",  ZDREG,  4,
"ZD5",  ZDREG,  5,
"zd5",  ZDREG,  5,
"ZD6",  ZDREG,  6,
"zd6",  ZDREG,  6,
"ZD7",  ZDREG,  7,
"zd7",  ZDREG,  7,
"zpc",  ZPC,    0,
"ZPC",  ZPC,    0,

#ifdef FLOAT
"FP0",  FREG,   0,
"fp0",  FREG,   0,
"FP1",  FREG,   1,
"fp1",  FREG,   1,
"FP2",  FREG,   2,
"fp2",  FREG,   2,
"FP3",  FREG,   3,
"fp3",  FREG,   3,
"FP4",  FREG,   4,
"fp4",  FREG,   4,
"FP5",  FREG,   5,
"fp5",  FREG,   5,
"FP6",  FREG,   6,
"fp6",  FREG,   6,
"FP7",  FREG,   7,
"fp7",  FREG,   7,
"FPCR", FCREG,  FPCR,
"fpcr", FCREG,  FPCR,
"FPSR", FCREG,  FPSR,
"fpsr", FCREG,  FPSR,
"FPIAR",FCREG,  FPIAR,
"fpiar",FCREG,  FPIAR,
#endif

#ifdef PMMU
"AC",   PREG,   AC,
"ac",   PREG,   AC,
"BAC0", PREG,   BAC0,
"bac0", PREG,   BAC0,
"BAC1", PREG,   BAC1,
"bac1", PREG,   BAC1,
"BAC2", PREG,   BAC2,
"bac2", PREG,   BAC2,
"BAC3", PREG,   BAC3,
"bac3", PREG,   BAC3,
"BAC4", PREG,   BAC4,
"bac4", PREG,   BAC4,
"BAC5", PREG,   BAC5,
"bac5", PREG,   BAC5,
"BAC6", PREG,   BAC6,
"bac6", PREG,   BAC6,
"BAC7", PREG,   BAC7,
"bac7", PREG,   BAC7,
"BAD0", PREG,   BAD0,
"bad0", PREG,   BAD0,
"BAD1", PREG,   BAD1,
"bad1", PREG,   BAD1,
"BAD2", PREG,   BAD2,
"bad2", PREG,   BAD2,
"BAD3", PREG,   BAD3,
"bad3", PREG,   BAD3,
"BAD4", PREG,   BAD4,
"bad4", PREG,   BAD4,
"BAD5", PREG,   BAD5,
"bad5", PREG,   BAD5,
"BAD6", PREG,   BAD6,
"bad6", PREG,   BAD6,
"BAD7", PREG,   BAD7,
"bad7", PREG,   BAD7,
"CAL",  PREG,   CAL,
"cal",  PREG,   CAL,
"CRP",  PREG,   CRP,
"crp",  PREG,   CRP,
"DRP",  PREG,   DRP,
"drp",  PREG,   DRP,
"PCSR", PREG,   PCSR,
"pcsr", PREG,   PCSR,
"PSR",  PREG,   PSR,
"psr",  PREG,   PSR,
"SCC",  PREG,   SCC,
"scc",  PREG,   SCC,
"SRP",  PREG,   SRP,
"srp",  PREG,   SRP,
"TC",   PREG,   TC,
"tc",   PREG,   TC,
"VAL",  PREG,   VAL,
"val",  PREG,   VAL,
"TT0",  PREG,   TT0,
"tt0",  PREG,   TT0,
"TT1",  PREG,   TT1,
"tt1",  PREG,   TT1,
#endif

"A0",   AREG,   0,
"a0",   AREG,   0,
"A1",   AREG,   1,
"a1",   AREG,   1,
"A2",   AREG,   2,
"a2",   AREG,   2,
"A3",   AREG,   3,
"a3",   AREG,   3,
"A4",   AREG,   4,
"a4",   AREG,   4,
"A5",   AREG,   5,
"a5",   AREG,   5,
"A6",   AREG,   6,
"a6",   AREG,   6,
"A7",   AREG,   7,
"SP",   AREG,   7,
"a7",   AREG,   7,
"sp",   AREG,   7,
"D0",   DREG,   0,
"d0",   DREG,   0,
"D1",   DREG,   1,
"d1",   DREG,   1,
"D2",   DREG,   2,
"d2",   DREG,   2,
"D3",   DREG,   3,
"d3",   DREG,   3,
"D4",   DREG,   4,
"d4",   DREG,   4,
"D5",   DREG,   5,
"d5",   DREG,   5,
"D6",   DREG,   6,
"d6",   DREG,   6,
"D7",   DREG,   7,
"d7",   DREG,   7,
"CCR",  SREG,   CCR,
"ccr",  SREG,   CCR,
"SR",   SREG,   SR,
"sr",   SREG,   SR,
"PC",   PC,     0,
"pc",   PC,     0
};
#define NIREGS  (sizeof(iregs)/sizeof(iregs[0]))
