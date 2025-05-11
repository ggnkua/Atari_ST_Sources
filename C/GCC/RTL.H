/* Register Transfer Language (RTL) definitions for GNU C-Compiler
   Copyright (C) 1987 Free Software Foundation, Inc.

This file is part of GNU CC.

GNU CC is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY.  No author or distributor
accepts responsibility to anyone for the consequences of using it
or for whether it serves any particular purpose or works at all,
unless he says so in writing.  Refer to the GNU CC General Public
License for full details.

Everyone is granted permission to copy, modify and redistribute
GNU CC, but only under the conditions described in the
GNU CC General Public License.   A copy of this license is
supposed to have been given to you along with GNU CC so you
can know your rights and responsibilities.  It should be in a
file named COPYING.  Among other things, the copyright notice
and this notice must be preserved on all copies.  */


/* Register Transfer Language EXPRESSIONS CODES */

#define RTX_CODE	enum rtx_code
enum rtx_code  {

#define DEF_RTL_EXPR(ENUM, NAME, FORMAT)   ENUM ,
#include "rtl.def"		/* rtl expressions are documented here */
#undef DEF_RTL_EXPR

  LAST_AND_UNUSED_RTX_CODE};	/* A convienent way to get a value for
				   NUM_RTX_CODE.
				   Assumes default enum value assignement.  */

#define NUM_RTX_CODE ((int)LAST_AND_UNUSED_RTX_CODE)
				/* The cast here, saves many elsewhere.  */

extern int rtx_length[];
#define GET_RTX_LENGTH(CODE)		(rtx_length[(int)(CODE)])

extern char *rtx_name[];
#define GET_RTX_NAME(CODE)		(rtx_name[(int)(CODE)])

extern char *rtx_format[];
#define GET_RTX_FORMAT(CODE)		(rtx_format[(int)(CODE)])


/* Get the definition of `enum machine_mode' */

#ifndef HAVE_MACHINE_MODES

#define DEF_MACHMODE(SYM, NAME, TYPE, SIZE, UNIT)  SYM,

enum machine_mode {
#include "machmode.def"
MAX_MACHINE_MODE };

#undef DEF_MACHMODE

#define HAVE_MACHINE_MODES

#endif /* not HAVE_MACHINE_MODES */

#ifndef NUM_MACHINE_MODES
#define NUM_MACHINE_MODES (int) MAX_MACHINE_MODE
#endif

/* Get the name of mode MODE as a string.  */

extern char *mode_name[];
#define GET_MODE_NAME(MODE)		(mode_name[(int)(MODE)])

enum mode_class { MODE_RANDOM, MODE_INT, MODE_FLOAT,
		  MODE_COMPLEX_INT, MODE_COMPLEX_FLOAT, MODE_FUNCTION };

/* Get the general kind of object that mode MODE represents
   (integer, floating, complex, etc.)  */

extern enum mode_class mode_class[];
#define GET_MODE_CLASS(MODE)		(mode_class[(int)(MODE)])

/* Get the size in bytes of an object of mode MODE.  */

extern int mode_size[];
#define GET_MODE_SIZE(MODE)		(mode_size[(int)(MODE)])

/* Get the size in bytes of the basic parts of an object of mode MODE.  */

extern int mode_unit_size[];
#define GET_MODE_UNIT_SIZE(MODE)	(mode_unit_size[(int)(MODE)])

/* Get the size in bits of an object of mode MODE.  */

#define GET_MODE_BITSIZE(MODE)  (BITS_PER_UNIT * mode_size[(int)(MODE)])

/* Get a bitmask containing 1 for all bits in a word
   that fit within mode MODE.  */

#define GET_MODE_MASK(MODE)  \
   ((GET_MODE_BITSIZE (MODE) >= HOST_BITS_PER_INT)  \
    ? -1 : ((1 << GET_MODE_BITSIZE (MODE)) - 1))

/* Common union for an element of an rtx.  */

typedef union rtunion_def
{
  int rtint;
  char *rtstr;
  struct rtx_def *rtx;
  struct rtvec_def *rtvec;
  enum machine_mode rttype;
} rtunion;

/* RTL expression ("rtx").  */

typedef struct rtx_def
{
#ifdef SHORT_ENUM_BUG
  unsigned short code;
#else
  /* The kind of expression this is.  */
  enum rtx_code code : 16;
#endif
  /* The kind of value the expression has.  */
  enum machine_mode mode : 8;
  /* 1 in an INSN if it can alter flow of control
     within this function.  Not yet used!  */
  unsigned int jump : 1;
  /* 1 in an INSN if it can call another function.  Not yet used!  */
  unsigned int call : 1;
  /* 1 in a MEM or REG if value of this expression will never change
     during the current function, even though it is not
     manifestly constant.
     1 in a SYMBOL_REF if it addresses something in the per-function
     constants pool.  */
  unsigned int unchanging : 1;
  /* 1 in a MEM expression if contents of memory are volatile.  */
  /* 1 in an INSN, CALL_INSN, JUMP_INSN, CODE_LABEL or BARRIER
     if it is deleted.  */
  /* 1 in a REG expression if corresponds to a variable declared by the user.
     0 for an internally generated temporary.  */
  unsigned int volatil : 1;
  /* 1 in a MEM referring to a field of a structure (not a union!).
     0 if the MEM was a variable or the result of a * operator in C;
     1 if it was the result of a . or -> operator (on a struct) in C.  */
  unsigned int in_struct : 1;
  /* 1 if this rtx is used.  This is used for copying shared structure.
     See `unshare_all_rtl'.
     This bit is used to detect that event.  */
  unsigned int used : 1;
  /* Nonzero if this rtx came from procedure integration.  */
  unsigned integrated : 1;
  /* The first element of the operands of this rtx.
     The number of operands and their types are controlled
     by the `code' field, according to rtl.def.  */
  rtunion fld[1];
} *rtx;

#define NULL_RTX (rtx) NULL

/* Define macros to access the `code' field of the rtx.  */

#ifdef SHORT_ENUM_BUG
#define GET_CODE(RTX)		((enum rtx_code) ((RTX)->code))
#define PUT_CODE(RTX, CODE)	((RTX)->code = ((short) (CODE)))
#else
#define GET_CODE(RTX)		((RTX)->code)
#define PUT_CODE(RTX, CODE)	((RTX)->code = (CODE))
#endif

#define GET_MODE(RTX)		((RTX)->mode)
#define PUT_MODE(RTX, MODE)	((RTX)->mode = (MODE))

/* RTL vector.  These appear inside RTX's when there is a need
   for a variable number of things.  The principle use is inside
   PARALLEL expressions.  */

typedef struct rtvec_def{
  unsigned num_elem;		/* number of elements */
  rtunion elem[1];
} *rtvec;

#define NULL_RTVEC (rtvec) NULL

#define GET_NUM_ELEM(RTVEC)		((RTVEC)->num_elem)
#define PUT_NUM_ELEM(RTVEC, NUM)	((RTVEC)->num_elem = (unsigned) NUM)

/* 1 if X is a REG.  */

#define REG_P(X) (GET_CODE (X) == REG)

/* 1 if X is a constant value that is an integer.  */

#define CONSTANT_P(X)   \
  (GET_CODE (X) == LABEL_REF || GET_CODE (X) == SYMBOL_REF		\
   || GET_CODE (X) == CONST_INT						\
   || GET_CODE (X) == CONST)

/* General accessor macros for accessing the fields of an rtx.  */

#define XEXP(RTX, N)	((RTX)->fld[N].rtx)
#define XINT(RTX, N)	((RTX)->fld[N].rtint)
#define XSTR(RTX, N)	((RTX)->fld[N].rtstr)
#define XVEC(RTX, N)	((RTX)->fld[N].rtvec)
#define XVECLEN(RTX, N)	((RTX)->fld[N].rtvec->num_elem)
#define XVECEXP(RTX,N,M)((RTX)->fld[N].rtvec->elem[M].rtx)

/* ACCESS MACROS for particular fields of insns.  */

/* Holds a unique number for each insn.
   These are not necessarily sequentially increasing.  */
#define INSN_UID(INSN)	((INSN)->fld[0].rtint)

/* Chain insns together in sequence.  */
#define PREV_INSN(INSN)	((INSN)->fld[1].rtx)
#define NEXT_INSN(INSN)	((INSN)->fld[2].rtx)

/* The body of an insn.  */
#define PATTERN(INSN)	((INSN)->fld[3].rtx)

/* Code number of instruction, from when it was recognized.
   -1 means this instruction has not been recognized yet.  */
#define INSN_CODE(INSN) ((INSN)->fld[4].rtint)

/* Set up in flow.c; empty before then.
   Holds a chain of INSN_LIST rtx's whose first operands point at
   previous insns with direct data-flow connections to this one.
   That means that those insns set variables whose next use is in this insn.
   They are always in the same basic block as this insn.  */
#define LOG_LINKS(INSN)		((INSN)->fld[5].rtx)

/* Holds a list of notes on what this insn does to various REGs.
   It is a chain of EXPR_LIST rtx's, where the second operand
   is the chain pointer and the first operand is the REG being described.
   The mode field of the EXPR_LIST contains not a real machine mode
   but a value that says what this note says about the REG:
     REG_DEAD means that the REG dies in this insn.
     REG_INC means that the REG is autoincremented or autodecremented.
   Note that one insn can have both REG_DEAD and REG_INC for the same register
   if the register is preincremented or predecremented in the insn
   and not needed afterward.  This can probably happen.
     REG_EQUIV describes the insn as a whole; it says that the
   insn sets a register to a constant value or to be equivalent to
   a memory address.  If the
   register is spilled to the stack then the constant value
   should be substituted for it.  The contents of the REG_EQUIV
   is the constant value or memory address, which may be different
   from the source of the SET although it has the same value. 
     REG_EQUAL is like REG_EQUIV except that the destination
   is only momentarily equal to the specified rtx.  Therefore, it
   cannot be used for substitution; but it can be used for cse.
     REG_RETVAL means that this insn copies the return-value of
   a library call out of the hard reg for return values.  This note
   is actually an INSN_LIST and it points to the first insn involved
   in setting up arguments for the call.  flow.c uses this to delete
   the entire library call when its result is dead.
     REG_WAS_0 says that the register set in this insn held 0 before the insn.
   The contents of the note is the insn that stored the 0.
   If that insn is deleted or patched to a NOTE, the REG_WAS_0 is inoperative.
   The REG_WAS_0 note is actually an INSN_LIST, not an EXPR_LIST.  */

#define REG_NOTES(INSN)	((INSN)->fld[6].rtx)

enum reg_note { REG_DEAD = 1, REG_INC = 2, REG_EQUIV = 3, REG_WAS_0 = 4,
		REG_EQUAL = 5, REG_RETVAL = 6 };

/* Extract the reg-note kind from an EXPR_LIST.  */
#define REG_NOTE_KIND(LINK) ((enum reg_note) GET_MODE (LINK))

/* The label-number of a code-label.  The assembler label
   is made from `L' and the label-number printed in decimal.
   Label numbers are unique in a compilation.  */
#define CODE_LABEL_NUMBER(INSN)	((INSN)->fld[3].rtint)

#define LINE_NUMBER NOTE

/* In a NOTE that is a line number, this is a string for the file name
   that the line is in.  */

#define NOTE_SOURCE_FILE(INSN)  ((INSN)->fld[3].rtstr)

/* In a NOTE that is a line number, this is the line number.
   Other kinds of NOTEs are identified by negative numbers here.  */
#define NOTE_LINE_NUMBER(INSN) ((INSN)->fld[4].rtint)

/* Codes that appear in the NOTE_LINE_NUMBER field
   for kinds of notes that are not line numbers.  */

#define NOTE_INSN_FUNCTION_BEG 0
#define NOTE_INSN_DELETED -1
#define NOTE_INSN_BLOCK_BEG -2
#define NOTE_INSN_BLOCK_END -3
#define NOTE_INSN_LOOP_BEG -4
#define NOTE_INSN_LOOP_END -5
/* This kind of note is generated at the end of the function body,
   just before the return insn or return label.
   In an optimizing compilation it is deleted by the first jump optimization,
   after enabling that optimizer to determine whether control can fall
   off the end of the function body without a return statement.  */
#define NOTE_INSN_FUNCTION_END -6
/* This kind of note is generated just after each call to `setjmp', et al.  */
#define NOTE_INSN_SETJMP -7

#define NOTE_DECL_NAME(INSN) ((INSN)->fld[3].rtstr)
#define NOTE_DECL_CODE(INSN) ((INSN)->fld[4].rtint)
#define NOTE_DECL_RTL(INSN) ((INSN)->fld[5].rtx)
#define NOTE_DECL_IDENTIFIER(INSN) ((INSN)->fld[6].rtint)
#define NOTE_DECL_TYPE(INSN) ((INSN)->fld[7].rtint)

/* In jump.c, each label contains a count of the number
   of LABEL_REFs that point at it, so unused labels can be deleted.  */
#define LABEL_NUSES(LABEL) ((LABEL)->fld[4].rtint)

/* In jump.c, each JUMP_INSN can point to a label that it can jump to,
   so that if the JUMP_INSN is deleted, the label's LABEL_NUSES can
   be decremented and possibly the label can be deleted.  */
#define JUMP_LABEL(INSN)   ((INSN)->fld[7].rtx)

/* Once basic blocks are found in flow.c,
   each CODE_LABEL starts a chain that goes through
   all the LABEL_REFs that jump to that label.
   The chain eventually winds up at the CODE_LABEL; it is circular.  */
#define LABEL_REFS(LABEL) ((LABEL)->fld[4].rtx)

/* This is the field in the LABEL_REF through which the circular chain
   of references to a particular label is linked.
   This chain is set up in flow.c.  */

#define LABEL_NEXTREF(REF) ((REF)->fld[1].rtx)

/* Once basic blocks are found in flow.c,
   Each LABEL_REF points to its containing instruction with this field.  */

#define CONTAINING_INSN(RTX) ((RTX)->fld[2].rtx)

/* For a REG rtx, REGNO extracts the register number.  */

#define REGNO(RTX) ((RTX)->fld[0].rtint)

/* For a CONST_INT rtx, INTVAL extracts the integer.  */

#define INTVAL(RTX) ((RTX)->fld[0].rtint)

/* For a SUBREG rtx, SUBREG_REG extracts the value we want a subreg of.
   SUBREG_WORD extracts the word-number.  */

#define SUBREG_REG(RTX) ((RTX)->fld[0].rtx)
#define SUBREG_WORD(RTX) ((RTX)->fld[1].rtint)

/* For a SET rtx, SET_DEST is the place that is set
   and SET_SRC is the value it is set to.  */
#define SET_DEST(RTX) ((RTX)->fld[0].rtx)
#define SET_SRC(RTX) ((RTX)->fld[1].rtx)

/* For an INLINE_HEADER rtx, FIRST_FUNCTION_INSN is the first insn
   of the function that is not involved in copying parameters to
   pseudo-registers.  FIRST_PARM_INSN is the very first insn of
   the function, including the parameter copying.
   We keep this around in case we must splice
   this function into the assembly code at the end of the file.
   FIRST_LABELNO is the first label number used by the function (inclusive).
   LAST_LABELNO is the last label used by the function (exclusive).
   MAX_REGNUM is the largest pseudo-register used by that function.

   We want this to lay down like an INSN.  The PREV_INSN field
   is always NULL.  The NEXT_INSN field always points to the
   first function insn of the function being squirreled away.  */

#define FIRST_FUNCTION_INSN(RTX) ((RTX)->fld[2].rtx)
#define FIRST_PARM_INSN(RTX) ((RTX)->fld[3].rtx)
#define FIRST_LABELNO(RTX) ((RTX)->fld[4].rtint)
#define LAST_LABELNO(RTX) ((RTX)->fld[5].rtint)
#define MAX_PARMREG(RTX) ((RTX)->fld[6].rtint)
#define MAX_REGNUM(RTX) ((RTX)->fld[7].rtint)
#define FUNCTION_ARGS_SIZE(RTX) ((RTX)->fld[8].rtint)

/* Generally useful functions.  */

extern rtx rtx_alloc ();
extern rtvec rtvec_alloc ();
extern rtx find_reg_note ();
extern rtx gen_rtx ();
extern rtx copy_rtx ();
extern rtvec gen_rtvec ();
extern rtvec gen_rtvec_v ();
extern rtx gen_reg_rtx ();
extern rtx gen_label_rtx ();
extern rtx gen_inline_header_rtx ();
extern rtx gen_lowpart ();
extern rtx gen_highpart ();
extern int subreg_lowpart_p ();
extern rtx make_safe_from ();
extern rtx memory_address ();
extern rtx get_insns ();
extern rtx get_last_insn ();
extern rtx gen_sequence ();
extern rtx expand_expr ();
extern rtx output_constant_def ();
extern rtx immed_real_const ();
extern rtx force_const_double_mem ();
extern rtx force_const_mem ();
extern rtx get_parm_real_loc ();
extern rtx assign_stack_local ();
extern rtx protect_from_queue ();
extern void emit_queue ();
extern rtx emit_move_insn ();
extern rtx emit_insn ();
extern rtx emit_jump_insn ();
extern rtx emit_call_insn ();
extern rtx emit_insn_before ();
extern rtx emit_insn_after ();
extern void emit_label ();
extern void emit_barrier ();
extern rtx emit_note ();
extern rtx prev_real_insn ();
extern rtx next_real_insn ();
extern rtx next_nondeleted_insn ();
extern rtx plus_constant ();
extern rtx find_equiv_reg ();
extern rtx delete_insn ();
extern rtx adj_offsetable_operand ();

extern int emit_to_sequence;

extern int asm_noperands ();
extern char *decode_asm_operands ();

#ifdef BITS_PER_WORD
/* Conditional is to detect when config.h has been included.  */
extern enum reg_class reg_preferred_class ();
#endif

extern rtx get_first_nonparm_insn ();

/* Standard pieces of rtx, to be substituted directly into things.  */
extern rtx pc_rtx;
extern rtx cc0_rtx;
extern rtx const0_rtx;
extern rtx const1_rtx;
extern rtx fconst0_rtx;
extern rtx dconst0_rtx;

/* All references to certain hard regs, except those created
   by allocating pseudo regs into them (when that's possible),
   go through these unique rtx objects.  */
extern rtx stack_pointer_rtx;
extern rtx frame_pointer_rtx;
extern rtx arg_pointer_rtx;
extern rtx struct_value_rtx;
extern rtx struct_value_incoming_rtx;
extern rtx static_chain_rtx;
extern rtx static_chain_incoming_rtx;
