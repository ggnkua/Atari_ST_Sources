/* Copyright (c) 2004 - present by H. Robbers.
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

/* po.h
 *
 * built in handling for Pure C object format
 */

#define O_VERBOSE 0
#define F_VERBOSE 0
#define P_VERBOSE 0
#define L_VERBOSE 0

#include "common/qmem.h"

#define MAXAREAS 512

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
	FIX_wpcrel,			/* pc relative not reducable to byte */
	FIX_f,
	FIX_bpcrel,			/* pc relative for (pc,Xn) */
	FIX_wbra,			/* pc relative reducable to byte */
	FIX_sbra,
	FIX_HIGH,
	FIX_book = 32
} FIXUP_PC;

typedef enum
{
	DRI_abs,
	DRI_data,
	DRI_text,
	DRI_bss,
	DRI_symbol,
	DRI_l,
	DRI_w,
	DRI_pcrel,
	DRI_inst
} FIXUP_DRI;

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

#define VAL_step 256L		/* FIX_step unit */

#define PMAGIC  0x4efa		/* Pure C object */
#define PPMAGIC 0x001c
#define DMAGIC  0x601a		/* DRI object */
#define DLMAGIC 0xff65		/* DRI library */
#define GMAGIC  0xfb01		/* GST object or library */

typedef struct
{
	char n[8];
	uchar ty,d;
	long v;
} DRI_SYM;


typedef struct pc_h
{
	uint  magic,he;
	long limage,
	     lfixup,
	     lnames,
	     lsym,
	     res1,
	     res2,
	     hekp;
	char image[0];
} PC_H;

typedef struct dri_h
{
	uint  magic;
	long ltext,
	     ldata,
	     lbss,
	     lsym,
	     rltext,
	     rldata;
	short reserved;
	char image[0];
} DRI_H;

#define DRI_AREAS 3
#define ACHUNK 1024L		/* extra to number of __labels */

typedef struct gst_h
{
	uint magic;
	char gstmod[0];		/* a GST module is a character stream */
} GST_H;

typedef struct ar_h
{
	char  name[14];
	long  time;
	char  uid, gid;
	short fimode;
	long  size;
	short reserve;
} AR_H;

typedef struct ar_file
{
	AR_H  ah;
	DRI_H dri;
} AR_F;

typedef struct ar_header
{
	uint magic;
	AR_F f[0];		/* flexible row of archived files */
} AR_HEAD;

typedef union
{
	PC_H    pc;
	DRI_H   dri;
	AR_HEAD drilib;
	GST_H   gst;
} FHD;


#define PRGMAGIC 0x601a
typedef struct
{
	short ty;
	long text_len,
	     data_len,
	     bss_len,
	     sym_len,
	     res1,
	     flags;
	short absflag;
	char image[0];
} PRG_HD;

typedef struct ref
{
	struct ref *next, *prior,		/* list */
	           *less, *great,		/* binary search tree */
	           *parent;
	struct fixup *fx;
	int obty;
} REFS;

typedef struct refbase
{
	REFS *first, *last,
	     **ha_tree;
	char *name;
	bool hashed;
	short numhash;
	REFS *unhashed;
} REFBASE;

/* specific lists */

typedef struct
{
	uchar ty,
	      sk;
	signed short nnr;
} FIX;

typedef struct dri_symbol
{
	char name[8];
	uchar ty,			/* temp flag */
	      d;
	long v;
} DRI_SYMBOL;

typedef struct po_name
{
	short nr,
	      hash,
	      area_number,
	      tlab,
	      ty,
	      l;
	char *s;
}
PO_NAME;

typedef struct dri_vlist		/* need a v sorted pointer array to PO_NAME's */
{
	long v;
	uchar ty,d;
	PO_NAME *pn;
} VPO;

enum				/* flags for po_name.ty */
{
	TLAB = 1		/* temporary label: 2 underscores followed
					   by decimal didgits only */
};

#define is_tmplab(f) ((f)->name->ty & TLAB) ne 0

typedef struct
{
	short size, high;
	PO_NAME *base;			/* row for use with fix.nr */
	VPO     *sort;			/* row of sorted values (DRI) */
	PO_NAME *area[DRI_AREAS];		/* local names of the DRI areas */
} NAMEBASE;

typedef struct fixup
{
	struct fixup *next, *prior;
	char *start;
	struct area *in,			/* the fixup fixes in this area */
	            *out;			/* the fixup points to this area if local. */
	FIX fix;
	short target;
	long disp, step;
	PO_NAME *name;
} FIXUP;

typedef struct fixbase
{
	FIXUP *first, *last;
} FIXBASE;

typedef struct area
{
	struct area *next, *prior;
	Cstr name;
	char *out,					/* where in output */
	     *image;				/* where in memory */
	bool referenced;
	short target,				/* basic segment (FIX_text, FIX_data, FIX_bss, FIX_offs) */
	      class,				/* PO class: TEXT_class, DATA_clas, GDATA_class< STR_class, etc */
	      id;					/* area ID (number in input file) */
	long limage,
	     allo;
	struct flist *in;			/* in which file */
	FIXBASE fixups;
	REFBASE o_refs,				/* outside refs */
	        a_refs,				/* anonymous refs */
	        lbls;				/* branch labels ALWAYS local to area */
} AREA;

typedef struct areabase
{
	AREA *first, *last;
} AREABASE;

typedef enum
{
	DRI,
	PURE_C,
	GFA,
	GST,
	LIB = 0x100,
} OB_TY;

typedef struct flist
{
	struct flist *next, *prior;
	FHD *h;						/* was base */
	OB_TY obty;
	Cstr name;
	long size;
	FIXBASE fixups;
	NAMEBASE names;
	AREABASE areas;
	REFBASE l_ents;			/* local entries in file */
} FLIST;

typedef struct filebase
{
	FLIST *first, *last;
	char *image,
	     *to_image;	/* for collected writing */
	Cstr name;	/* output filename for new object or program */
} FILEBASE;

typedef struct hashname
{
	struct hashname *link;
	PO_NAME *n;
	char name[0];
} PO_TAB;			/* symbol table for PO_NAME's */

typedef enum
{
	IN_X,
	TO_S
} FLO_DIRECTION;

typedef struct
{
	bool
		in_module,
		in_func,
		setup_done;

	long
		num_files,
		num_areas,
		num_fixups,
		num_names,
		num_refs,
		po_names;

	short
		result;

	FILEBASE fbase;				/* files */

	AREA *area_now,
	     *code_std_areas[high_class];	/* standard areas binary code */

	PO_TAB **po_tab;					/* PO_NAME symbol table */
	PO_NAME *area_po_names[MAXAREAS]; 	/* direct access to area name by number */

} PO_COMMON;

extern PO_COMMON P;
extern short class_now;

extern short std_area_to_fix[];
extern S_path o_name;		/* ex out.c */

PO_NAME * new_po_name(NAMEBASE *nm, Cstr name, short area, short tlab, bool chklbl);
PO_NAME * get_po_name(NAMEBASE *nm, short number);
bool	o_setup		(void);
void	p_label		(XP, long offs, bool loc);
void	advance_b	(uchar w);
void	advance		(ushort w);
void	advance_l	(long w);
void	advance_m	(long size, void *m);
REFS *	get_label	(AREA *ar, Cstr name, short tlab);
void	branch_aheads(AREA *ar, FIXUP *ef);
AREA *	try_bsr		(FLIST *fl, AREA *this, Cstr name);
FIXUP *	o_fixup		(Cstr name, short area, short ty, short tlab);
void	o_func		(BP head, short class, short area);
void	o_block		(BP cb);
void	o_lab		(char *name);
void	o_brdisp	(OPND *op, short sz, ushort w1, short cc, short area);
void	o_branch	(OPND *op, short sz, short opcode, short cc, short area);
void	o_cpbranch	(OPND *op, short opcode, short cp, short cc, short size, short area, bool asm);
void	o_endproc	(void);
void	o_inst		(IP ip);
void	o_end		(short);
ushort	o_size		(IP ip);
ushort	o_move		(short sz);
ushort	o_ea		(OPND *op);
ushort	o_dst_ea	(OPND *op);
bool	is_number	(const OPND *op);
ushort	o_x			(short reg);
#if FLOAT
ushort	o_fsize		(IP ip);
bool	is_f		(IP ip);
void	o_cpgenx	(IP ip, short op);
void	o_cpgens	(IP ip, short op);
bool	ISFF		(OPND *op);
#endif
bool	no_cf		(IP ip);
ushort	o_X			(IP ip);
ushort	o_argX		(IP ip);
ushort	o_dst_X		(IP ip);
ushort	o_src_X		(IP ip);
void	operand_fixup(OPND *op);
void	o_ext		(IP ip, OPND *op, short size);
AREA *	o_area_setup(short class, short area, Cstr start_txt);
void	o_area_end	(void);
bool	o_AREA		(short area);
o_A		o_DS;
void	o_even		(void);
void	o_Qarith	(IP ip, ushort w1, ushort fop, FLO_DIRECTION to, ushort wq);
bool	can_quick	(IP ip);
void	o_Lmd		(IP ip, ushort w1, ushort w2, ushort size);
void	o_arith		(IP ip, ushort w1, ushort fop, FLO_DIRECTION to, bool havesz);
void	o_Aquick	(IP ip, ushort w1);
bool	ISAA		(OPND *op);
bool	ISDD		(OPND *op);
void	o_cond		(IP ip, ushort w1);
void	o_imm		(IP ip, ushort w1);
void	o_imma		(IP ip, ushort w1);
void	o_Qimma		(IP ip, ushort w1, ushort wq);
void	o_Iquick	(IP ip, ushort w1);
void	o_Qimm		(IP ip, ushort w1, ushort wq);
void	o_shiftx	(IP ip, ushort w1);
void	o_shifts	(IP ip, ushort w1);
void	o_genx		(IP ip, ushort w1, short fop);
void	o_gens		(IP ip, ushort w1, short fop);
void	o_jump		(IP ip, ushort w1);
void	o_move_cond	(IP ip);
void	o_move_eaea	(IP ip);
void	o_move_eadn	(IP ip, bool s);
void	o_cpdbcc	(IP ip, short cp, short cc);
void	o_cptrapcc	(IP ip, short cp, short cc);
