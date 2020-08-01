/*
 * C compiler
 * ==========
 *
 * Copyright 1989, 1990, 1991 Christoph van Wuellen.
 * Credits to Matthew Brandt.
 * All commercial rights reserved.
 *
 * This compiler may be redistributed as long there is no
 * commercial interest. The compiler must not be redistributed
 * without its full sources. This notice must stay intact.
 *
 * History:
 *
 * 1989   starting an 68000 C compiler, starting with material
 *        originally by M. Brandt
 * 1990   68000 C compiler further bug fixes
 *        started i386 port (December)
 * 1991   i386 port finished (January)
 *        further corrections in the front end and in the 68000
 *        code generator.
 *        The next port will be a SPARC port
 */

#include "config.h"

#define	MAX_WIDTH	60

#ifdef MC680X0
#ifdef TARGET_JAS

#include	"chdr.h"
#include	"expr.h"
#include	"gen.h"
#include	"cglbdec.h"

#ifdef MULTIPLE_ASSEMBLERS
#define PRIVATE	static
#undef	put_code
#undef	put_string
#undef	put_label
#undef	put_byte
#undef	put_char
#undef	put_word
#undef	put_long
#undef	put_pointer
#undef	put_short
#undef	put_storage
#undef	dumplits
#undef	put_external
#undef	put_global
#undef	put_align
#undef	nl
#undef	cseg
#undef	dseg
#undef	put_float
#undef	put_double
#undef	put_longdouble
#else
#define	PRIVATE
#endif /* MULTIPLE_ASSEMBLERS */

enum e_gt {
    bytegen, wordgen, longgen, floatgen, nogen
};
enum e_sg {
    noseg, codeseg, dataseg, bssseg
};

#if defined(__STDC__) || defined(__cplusplus)
#define P_(s) s
#else
#define P_(s) ()
#endif

/* out68k_jas.c */
static void putop P_((OPCODE));
static void putconst P_((EXPR *));
static void putlen P_((int));
static void putamode P_((ADDRESS *));
static void put_mask P_((REGMASK));
static void put_rmask P_((REGMASK));
static void put_smask P_((REGMASK));
static void putreg P_((int));
static void put_header P_((enum e_gt, SIZE));
static void seg P_((enum e_sg, char *));
static void bseg P_((void));
PRIVATE void put_string P_((char *));
PRIVATE void put_align P_((SIZE));
PRIVATE void put_long P_((long));
PRIVATE void nl P_((void));
PRIVATE void cseg P_((void));
PRIVATE void dseg P_((void));
PRIVATE void put_label P_((LABEL));
PRIVATE void put_external P_((char *));
PRIVATE void put_byte P_((int));
PRIVATE void put_char P_((int));

#undef P_

/* variable initialization */

static enum e_gt gentype = nogen;
static enum e_sg curseg = noseg;
static int       outcol = 0;
static SIZE	 align_type;

#define	prefix	"L"
#define comment	";"

static char *opl[] = {
	"move",		/* op_move */
	"moveq",	/* op_moveq */
	"add",		/* op_add */
	"add",		/* op_addi */
	"addq",		/* op_addq */
	"sub",		/* op_sub */
	"sub",		/* op_subi */
	"subq",		/* op_subq */
	"muls",		/* op_muls */
	"mulu",		/* op_mulu */
	"divs",		/* op_divs */
	"divu",		/* op_divu */
	"and",		/* op_and */
	"and",		/* op_andi */
	"or",		/* op_or */
	"or",		/* op_ori */
	"eor",		/* op_eor */
	"asl",		/* op_asl */
	"lsr",		/* op_lsr */
	"jmp",		/* op_jmp */
	"jsr",		/* op_jsr */
	"movem",	/* op_movem */
	"rts",		/* op_rts */
	"bra",		/* op_bra */
	"beq", 		/* op_beq */
	"bne",		/* op_bne */
	"blt",		/* op_blt */
	"ble",		/* op_ble */
	"bgt",		/* op_bgt */
	"bge",		/* op_bge */
	"bhi", 		/* op_bhi */
	"bcc", 		/* op_bhs */
	"bcs", 		/* op_blo */
	"bls", 		/* op_bls */
	"btst",		/* op_btst */
	"tst",		/* op_tst */
	"ext",		/* op_ext */
	"lea",		/* op_lea */
	"swap",		/* op_swap */
	"neg",		/* op_neg */
	"not",		/* op_not */
	"cmp",		/* op_cmp */
	"clr",		/* op_clr */
	"link",		/* op_link */
	"unlk",		/* op_unlk */
	"pea",		/* op_pea */
	"cmp",		/* op_cmpi */
	"dbra",		/* op_dbra */
	"asr",		/* op_asr */
	"rol",		/* op_rol */
	"ror",		/* op_ror */
	"seq", 		/* op_seq */
	"sne",		/* op_sne */
	"slt",		/* op_slt */
	"sle",		/* op_sle */
	"sgt",		/* op_sgt */
	"sge",		/* op_sge */
	"shi", 		/* op_shi */
	"scc", 		/* op_shs */
	"scs", 		/* op_slo */
	"sls", 		/* op_sls */
	"st",		/* op_st */
#ifdef TRAP_GEN
	"trap",		/* op_trap */
#endif /* TRAP_GEN */
	comment"line",	/* op_line */
	0,		/* op_label */
};

static void
putop(op)
    OPCODE       op;
{
  if (op >= OP_MIN && op <= OP_MAX && opl[op] != (char *)0)
    oprintf ("\t%s",opl[op]);
  else
    fatal(__FILE__,"putop","illegal opcode %d",op);
}

static void
putconst(offset)
/*
 * put a constant to the output file.
 */
    EXPR   *offset;
{

    switch (offset->nodetype) {
      case en_autocon:
      case en_icon:
	oprintf("%ld", offset->v.i);
	break;
#ifndef FLOAT_BOOTSTRAP
#ifdef FLOAT_MFFP
      case en_fcon:
	oprintf("$%lx", genffp(offset->v.f));
	break;
#endif /* FLOAT_MFFP */
#endif /* FLOAT_BOOTSTRAP */
      case en_labcon:
	oprintf(prefix"%u", (unsigned)offset->v.l);
	break;
      case en_nacon:
        oprintf("%s",outlate(offset->v.sp));
	break;
      case en_add:
	putconst(offset->v.p[0]);
	oprintf("+");
	putconst(offset->v.p[1]);
	break;
      case en_sub:
	putconst(offset->v.p[0]);
	oprintf("-");
	putconst(offset->v.p[1]);
	break;
      case en_uminus:
	oprintf("-");
	putconst(offset->v.p[0]);
	break;
      default:
	fatal(__FILE__,"putconst","illegal constant node %d",offset->nodetype);
	break;
    }
}

static void
putlen(l)
/*
 * append the length field to an instruction.
 */
    int             l;
{
    if (l == 0)
	return;
    oprintf(".");
    switch (l) {
      case 1:
	oprintf("b");
	break;
      case 2:
	oprintf("w");
	break;
      case 4:
	oprintf("l");
	break;
      default:
	fatal(__FILE__,"putlen","illegal length field %d",l);
	break;
    }
}

static void
putamode(ap)
/*
 * output a general addressing mode.
 */
    ADDRESS   *ap;
{
    switch (ap->mode) {
      case am_immed:
	oprintf("#");
	/*FALLTHRU*/
      case am_direct:
	putconst(ap->offset);
	break;
      case am_areg:
	oprintf("a%d", ap->preg);
	break;
      case am_dreg:
	oprintf("d%d", ap->preg);
	break;
      case am_ind:
	oprintf("(a%d)", ap->preg);
	break;
      case am_ainc:
	oprintf("(a%d)+", ap->preg);
	break;
      case am_adec:
	oprintf("-(a%d)", ap->preg);
	break;
      case am_indx:
	putconst(ap->offset);
	oprintf("(a%d)", ap->preg);
	break;
      case am_indx2:
	putconst(ap->offset);
	oprintf("(a%d,d%d.l)", ap->preg, ap->sreg);
	break;
      case am_indx3:
	putconst(ap->offset);
	oprintf("(a%d,a%d.l)", ap->preg, ap->sreg);
	break;
#ifdef JAS_PATCH
      case am_indx4:
	putconst(ap->offset);
	oprintf("(a%d,d%d.w)", ap->preg, ap->sreg);
	break;
#endif /* JAS_PATCH */
      case am_rmask:
	put_rmask((REGMASK) ap->offset->v.i);
	break;
      case am_smask:
	put_smask((REGMASK) ap->offset->v.i);
	break;
      case am_line:
	putconst(ap->offset);
	break;
      default:
	fatal(__FILE__,"putamode","illegal address mode %d",ap->mode);
	break;
    }
}

PRIVATE void
put_code(op, len, aps, apd)
/*
 * output a generic instruction.
 */
    ADDRESS   *aps, *apd;
    int             len;
    OPCODE       op;
{
    putop(op);
    putlen(len);
    if (aps != 0) {
	oprintf("\t");
	putamode(aps);
	if (apd != 0) {
	    oprintf(",");
	    putamode(apd);
	}
    }
    oprintf("\n");
}

static void
put_mask(mask)
/*
 * generate a register mask.
 */
    REGMASK	 mask;
{
    int		 i;
    BOOL	 pending = 0;
    if (mask & 1) {
	putreg(0);
	pending = 1;
    }
    for (i = 1; i <= 15; i++)
	if ((mask = mask >> 1) & 1) {
	    if (pending)
		oprintf("/");
	    putreg(i);
	    pending = 1;
	}
}

static void
put_smask(mask)
/*
 * generate a register mask for save.
 */
    REGMASK	 mask;
{
    put_mask(mask);
}

static void
put_rmask(mask)
/*
 * generate a register mask for restore.
 */
    REGMASK	 mask;
{
    put_mask(mask);
}

static void
putreg(r)
/*
 * generate a register name from a tempref number.
 */
    int             r;
{
    if (r < 8)
	oprintf("d%d", r);
    else
	oprintf("a%d", r - 8);
}

PRIVATE void
put_string(s)
/*
 * generate a named label.
 */
    char           *s;
{
    oprintf("%s:\n",outlate(s));
}

PRIVATE void
put_label(lab)
/*
 * output a compiler generated label.
 */
    LABEL	 lab;
{
    oprintf(prefix"%u:\n", (unsigned int)lab);
}


static void
put_header (gtype, al)
    enum e_gt gtype;
    SIZE al;
{
    static char *directive[] = {
	"dc.b\t",	/* bytegen */
	"dc.w\t",	/* wordgen */
	"dc.l\t",	/* longgen */
	};

    if (gentype != gtype || outcol >= MAX_WIDTH) {
	put_align(al);
	gentype = gtype;
	outcol = 15;
	oprintf("\t%s", directive[gtype]);
    } else
	oprintf(",");
}

PRIVATE void
put_byte(val)
    int             val;
{
    put_header(bytegen, (SIZE)AL_CHAR);
    oprintf("%d", val & 0x00ff);
    outcol += 4;
}

PRIVATE void
put_char(val)
    int             val;
{
    put_byte(val);
}

PRIVATE void
put_word(val)
    int             val;
{
    put_header(wordgen, (SIZE)AL_SHORT);
    oprintf("%d", val & 0xffff);
    outcol += 6;
}

#ifndef FLOAT_BOOTSTRAP
#ifdef FLOAT_IEEE
PRIVATE void
put_float(val)
    double val;
{
    unsigned long ul;
    ieee_single(val, &ul);
    put_long((long) ul);
}

PRIVATE void
put_double(val)
    double val;
{
    unsigned long ul[2];
    ieee_double(val, ul);
    put_long ((long) ul[0]);
    put_long ((long) ul[1]);
}
PRIVATE void
put_longdouble(val)
    double val;
{
    unsigned long ul[2];
    ieee_double(val, ul);
    put_long ((long) ul[0]);
    put_long ((long) ul[1]);
}
#endif /* FLOAT_IEEE */
#ifdef FLOAT_MFFP
PRIVATE void
put_float(val)
    double          val;
{
    put_long((long) genffp(val));
}

PRIVATE void
put_double(val)
    double val;
{
    put_long((long) genffp(val));
}

PRIVATE void
put_longdouble(val)
    double val;
{
    put_long((long) genffp(val));
}
#endif /* FLOAT_MFFP */
#endif /* FLOAT_BOOTSTRAP */

PRIVATE void
put_long(val)
    long            val;
{
    put_header (longgen, (SIZE)AL_LONG);
    oprintf("$%lx", val);
    outcol += 10;
}

#ifndef RELOC_BUG
PRIVATE void
put_short(node)
    EXPR   *node;
{
    put_header (wordgen, (SIZE)AL_SHORT);
    putconst(node);
    outcol += 10;
}
#endif /* RELOC_BUG */

PRIVATE void
put_pointer(node)
    EXPR   *node;
{
    put_header (longgen, (SIZE)AL_POINTER);
    putconst(node);
    outcol += 10;
}

PRIVATE void
put_storage(sp, al)
    SYM		*sp;
    SIZE	 al;
{
    bseg();
    put_align(al);
#if 0
    if (sp->storage_class == sc_static) {
	put_label (sp->value.l);
	oprintf("\tds.b\t");
    } else
	oprintf("\tcomm\t%s,", outlate(sp->name));
    oprintf("%ld\n", sp->tp->size);
#else 
    if (sp->storage_class == sc_static) {
	put_label (sp->value.l);
    } else
	put_string (sp->name);
    oprintf("\tds.b\t%ld\n", sp->tp->size);
#endif
}


PRIVATE void
dumplits()
/*
 * dump the string literal pool.
 * if we are producing single copies of strings (which should therefore
 * be read only we put them in the text segement - else in the data segment.
 */
{
    char           *cp;
    int             len;
    if (trad_option || IandD_option)
	dseg();
    else
	cseg();
    for ( ; strtab != 0; strtab = strtab->next) {
	nl();
	put_label(strtab->label);
	cp = strtab->str;
	for (len = strtab->len; len--; )
	    put_char(*cp++);
	put_byte(0);
    }
    nl();
}

/*ARGSUSED*/
PRIVATE void
put_external(s)
    char           *s;
/* put the definition of an external name in the ouput file */
{
    s = s;	/* keep the compiler happy */
}

PRIVATE void
put_global(s)
    char           *s;
/* put the definition of a global name in the output file */
{
    nl();
    oprintf("\tglobl\t%s\n", outlate(s));
}

PRIVATE void
put_align(al)
    SIZE             al;
/* align the following data */
{
    nl();
    if (al > align_type) {
	switch (al) {
	  case 2:
	  case 4:
	    oprintf("\teven\n");
	    break;
	}
    }
    align_type = al;
}

PRIVATE void
nl()
{
    static BOOL	init_done = 0;
    if (init_done == 0) {
#ifdef VERBOSE
	time_t time_of_day;
	VOIDCAST time (&time_of_day);
#endif /* VERBOSE */
	init_done++;
	oprintf(comment" Generated by %s v%s, %s (%s) from \"%s\"\n",
	    PROGNAME, VERSION, LAST_CHANGE_DATE, __DATE__, act_file);
#ifdef VERBOSE
	oprintf(comment" Compilation date/time: %s\n", ctime(&time_of_day));
#endif /* VERBOSE */
    } else if (outcol > 0) {
	oprintf("\n");
	gentype = nogen;
	outcol = 0;
    }
}

static void
seg(segtype, segname)
    enum e_sg	 segtype;
    char	*segname;
{
    nl();
    if (curseg != segtype) {
	oprintf("\t%s\n", segname);
	curseg = segtype;
	align_type = 0;
    }
}

PRIVATE void
cseg()
{
    seg(codeseg,"text");
}

PRIVATE void
dseg()
{
    seg(dataseg,"data");
}

static void
bseg()
{
    seg(bssseg,"bss");
}

#ifdef MULTIPLE_ASSEMBLERS
struct funcs jas68k_funcs = {
	put_code,
	put_string,
	put_label,
	put_byte,
	put_char,
	put_word,
	put_long,
	put_pointer,
#ifndef RELOC_BUG
	put_short,
#endif /* RELOC_BUG */
	put_storage,
	dumplits,
	put_external,
	put_global,
	put_align,
	nl,
	cseg,
	dseg,
#ifdef FLOAT_SUPPORT
	put_float,
	put_double,
	put_longdouble
#endif /* FLOAT_SUPPORT */
	};
#endif /* MULTIPLE_ASSEMBLERS */
#endif /* TARGET_JAS */
#endif /* MC680X0 */
