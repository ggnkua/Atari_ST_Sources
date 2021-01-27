/*  Copyright (c) 1987 - 1991 by Han  Driesen Leiden.
 *            (c) 1996 - 2008 by Henk Robbers Amsterdam.
 *
 * This file is part of Atari Digger.
 *
 * Digger is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Digger is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Digger; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/* 	TTDISASS.H
 *	==========
 */

#define SOZOBON 1		/* ad hoc patches for disassembling BigLife.prg */

typedef long T_int;

typedef struct
{
	char n[8];
	uchar ty,d;
	long v;
} SYM;

typedef struct
{
	unsigned char ty;
	unsigned char sk;
	signed   short  nd;
} FIX;

#define TuC 0
#define PuC 1
#define is_DRI (dw->puc eq TuC)
#define is_PC  (dw->puc eq PuC)
#define WLONGS 600	/* 120 lines with 1 label & maximum of 4 operands */
#define ERASE(x) if (x) free(x),x=0
#define z dw->					/* via pointer zu dw */
								/*             ==    */
#define HISTN 256
#define HIGH_LV 0x7fffffff

#define WAS_DIS DIS_cfg

typedef enum
{
	ISNORMAL,
	ISINST,
	ISDATA,
	ISNAME,
	ISFIX,
	ISSYMBOL,
	ISLABEL
} MSGTY;

typedef enum
{
	MC000 = 0,
	MC020 = 1,
	MC030 = 2,
	MC040 = 4,
	MC060 = 8,
	MCCF  = 16
} MACHTY;

typedef enum
{
	FIX_0,
	FIX_end,
	FIX_step,
	FIX_text,
	FIX_data,
	FIX_bss,
	FIX_offs,

	FIX_glmod,
	FIX_glent,
	FIX_lcmod,
	FIX_lcent,

	FIX_labs,
	FIX_wabs,
	FIX_lpcrel,
	FIX_wpcrel,

	FIX_f,

	FIX_book = 32
} FIXUP_T;

typedef enum
{
	GST_escape = 0xfb,
	GST_source = 1,
	GST_comment,
	GST_org,
	GST_section,
	GST_offset,
	GST_xdef,
	GST_xref,
	GST_8,
	GST_9,
	GST_xa,
	GST_xb,
	GST_xc,
	GST_xd,
	GST_xe,
	GST_xf,
	GST_define,
	GST_11,
	GST_common,
	GST_end,
	GST_last
} FIXUP_GST;

typedef enum
{
	BRDISP,		/* pc */
	EA,			/* any */
	NREL,		/* absolute word (not relocatable) */
	REL			/* absolute long (relocatable) */
} OPTY;

extern PC  linef;
extern
long linef_max;

typedef struct rxy
{
	PC p,r;
	char ty,y,dum1,dum2;
	short x,x1;
} RXY;

#define NEW 0			/* test labels_multiple */

typedef struct
{
	long v;
	char *n;
	char ty;
	uchar d;
	short dum;
	long sz;
} LAB;

typedef struct
{
	ulong  no,hash,max;
	LAB  *lab;
} HSYM;

typedef enum	/* base displacement size values in exxt */
{
	bd_l = -3,		/* bd.l,pc */
	bd_w,			/* bd.w,pc */
	bd_z,			/* zpc use zero pc value */
	bd_no,			/* no exxt or fail */
	pc_w = 2,		/* simple pc relative */
	pc_l
} BD;

typedef struct diswin
{
	void *w;			/* pointer to IT structure (window&object info) */
	bool *rel, *lab, *dt;
	long reloff,
	     linef_max;					/* 151002 */
	LAB  *PL;
	SYM  *S;
	FIX  *F;
	RXY  *kp,*kpl,*kp0,*keep;
	PC   pc,dat,bss,
	     org,bot,top,
	     shift,rlc,
	     linef;						/* 151002 */
	PCB  nam;
	SYSHDR *os_base;				/* 151002 */
	Wstr
	     t1,t2,t3,t4,
	     pos1;
	HSYM L,WL,XL,CL,ML;

	TTD_CFG  *cf;
	TTD_PROF *cg;

	bool tosimg,				/* 151002 Tos img in file */
		 nl,sep,openline,modactive,
	     puc,prg,
	     dc,dcf,fil,movea,
	     coldfire;

	short
		mach,lbl_len,l,lf,spec, 
		prcol,					/* v 8.1 */
		lnr,berr, ty, sozobon;
} DW;

char *findname(char *fps,long ld,short nnr);

long signext(unsigned long l,short b);
bool is_entry(short ty);

typedef PC SYMBOLIC_REL(DW *dw,PC pc,BD bd);
typedef PC SYMBOLIC_ABS(DW *dw,PC pc, bool abs);

SYMBOLIC_ABS long_abs,  word_abs;

short disass(DW *dw);

/* De assembler routines */
void bset(bool *row,long bit);
void bclr(bool *row,long bit);
bool btst(bool *row,long bit);
void bchg(bool *row,long bit);

void bassign(bool *row,long bit,bool value);

void print(char *);
void prdec(long n);
void prhex(long n);
void prhexl(long n,long l);

long nonzero (void *);
long backzero(void *);

#define BTST(a,b) (((a)>>(b))&1)
#define BSETW(b) ((short)1<<(b))

PCB cdecl scanreloc(
		PC org,PC bss,PC top,
		PC rlc,PC limit,
		bool rel[],bool lab[]
		);
void cdecl
	scanlabx(
		long mopt,
		PC org,PC bss,PC top,long offset,
		bool mask[],bool maskx[],
		bool rel[],bool dt[],bool lab[]
		);
void cdecl
	scanlab(
		long mopt,
		PC org,PC bss,PC top,long offset,
		bool mask[],
		bool rel[],bool dt[],bool lab[]
		);
long cdecl
	findref(
		long mopt,
		PC org,PC bss,PC sto,PC rkey,
		bool mask[],bool rel[],bool dt[],
		PC start,PC sref
		);

long cdecl
	findrefx(
		long mopt,
		PC org,PC bss,PC sto,PC rkey,
		bool mask[],bool maskx[],
		bool rel[],bool dt[],
		PC sref,PC start
		);

typedef
void MARK(bool *row, long bitaddress);

MARK bytemark,byteclr,wordmark,wordclr,longmark,longclr,codemark,codeclr;
uint g2bool(bool *row, long bitaddress);
long g4bool(bool *row, long bitaddress);
typedef union { uchar m[2]; uint i; } B2;

extern char *pos,regel[],pcn[],bytes[],vis[],eolist[];
extern short eafail,tabgain,tabgain1;
extern FILE *ofile;
extern HSYM namA;		/* 5'99 RA */

#define TMAL 0			/* debug memory calculation errors */

#if TMAL
void *MMalloc(long l, char *id, XA_key key, long xxx);
#else
#define MMalloc(a,b,c,d) xmalloc(a,c)
#endif

/* between TTDIGST.C & TTDPAGE.C (analyse & display) */
void prconv(long v, short rdx, long l, char *pref);
void pdhex		(long v, long l, TTD_PROF *cg);
void psdhex		(long v, long l, TTD_PROF *cg);
void phex		(long v, short x, long l);
void pshex		(long v, short x, long l);
long label		(DW *dw, PC a,bool sep);
bool pure_local	(char *);
void ocl		(DW *dw, char *mnem,short l);
void oc			(DW *dw, char *mnem, short l);
void keep_label	(DW *dw, PCB a, short x);
void keep_end_label(DW *dw,short ty);
void tab		(DW *dw, char * t);
long address	(DW *dw, PCB a);

/* between all files */
char *dri_name  (char *, uchar, short);
char *pure_name (char *);
bool rel		(DW *dw, PCB x);
long skip		(FIX *);
void listnames	(char *fps,long ld);
bool alloc_hsym	(HSYM *s, short wl, char *txt);
ulong near_hi_p2(ulong in, bool t2);
char *ipff_init	(short m, bool nl, bool f, char *t,char *l,char **tt);
char *ipff_getp	(void);
void ipff_putp	(char *s);
short sk(void),skc(void),idec(void),str(char *);
long dec		(void),
     hex		(void),
     oct		(void);
void nstr		(char *w);
bool load_namA	(char *fn);
LAB *sort_names	(HSYM *s);
bool find_hname (DW *dw, HSYM *s, long a);
bool tosaddr	(long v,long l);
void free_hsym	(HSYM *s);
bool is_ram		(DW *dw);
void check_mod	(DW *dw);
long ttd_hash	(HSYM *s, long a);
