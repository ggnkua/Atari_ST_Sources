/* Subroutines for insn-output.c for MIPS
   Contributed by A. Lichnewsky, lich@inria.inria.fr.
   Copyright (C) 1989 Free Software Foundation, Inc.

   $Id: out-mips.c,v 1.1 90/10/29 11:03:41 jeff Exp $

This file is part of GNU CC.

GNU CC is free software; you can redistribute it and/or modify
it under the terms of the GNU General Public License as published by
the Free Software Foundation; either version 1, or (at your option)
any later version.

GNU CC is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
GNU General Public License for more details.

You should have received a copy of the GNU General Public License
along with GNU CC; see the file COPYING.  If not, write to
the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.  */


#include <stdio.h>
extern void  my_print_rtx ();
extern void  abort_with_insn ();


/* Global variables for machine-dependent things.  */

char *reg_numchar[] = REGISTER_NUMCHAR;

/* When eliminating the frame pointer, this is the size of the frame
   aside from explicit stack slots.  */
int frame_stack_difference;

/* Return truth value of whether OP can be used as an operands
   where a 16 bit integer is needed  */

int
arith_operand (op, mode)
     rtx op;
     enum machine_mode mode;
{
  return (register_operand (op, mode)
	  || (GET_CODE (op) == CONST_INT && SMALL_INT (op)));
}

/* Return truth value of whether OP can be used as an operand in a two
   address arithmetic insn (such as set 123456,%o4) of mode MODE.  */

int
arith32_operand (op, mode)
     rtx op;
     enum machine_mode mode;
{
  return (register_operand (op, mode) || GET_CODE (op) == CONST_INT);
}

/* Return truth value of whether OP is a integer which fits in 16 bits  */

int
small_int (op, mode)
     rtx op;
     enum machine_mode mode;
{
  return (GET_CODE (op) == CONST_INT && SMALL_INT (op));
}


#if 0
				/* Used to allow constant expression known
				** only at assembly time
				*/
int
legitimize_constant_expr(expr)
     rtx expr;
{
  if (GET_CODE (expr) == PLUS
      ||
      GET_CODE (expr) == MINUS)
    return (BASIC_CONSTANT_P (XEXP (expr, 0))
	    && BASIC_CONSTANT_P (XEXP (expr, 1)));
  return 0;
}
#endif

char *
output_load_immediate (operands)
     rtx *operands;
{
  rtx xops[3];
  xops[0] = operands[0];
  xops[2] = gen_rtx (CONST_INT, VOIDmode, INTVAL (operands[1]));

  if ((INTVAL (operands[1]) >> 16)
      && (INTVAL (operands[1]) & 0xffff))
    {
      if (!((-INTVAL (operands[1])) >> 16))
	{
	  xops[1] = gen_rtx (CONST_INT, VOIDmode,
			     (INTVAL (operands[1])) & 0xffff);
	  output_asm_insn ("addi%:\t%0,$0,%x1\t#movsi low part of %2",
			   xops);
	}
      else
	{
	  xops[1] = gen_rtx (CONST_INT, VOIDmode,
			     (INTVAL (operands[1]))>>16);
	  output_asm_insn ("lui\t%0,%x1\t#movsi high part of %2", xops);
	  xops[1] = gen_rtx (CONST_INT, VOIDmode,
			     (INTVAL (operands[1])) & 0xffff);
	  output_asm_insn ("ori\t%0,%x1\t#movsi low part of %2", xops);
	}
    }
  else if (INTVAL (operands[1]) >> 16)
    {
      xops[1] = gen_rtx (CONST_INT, VOIDmode,
			 (INTVAL (operands[1]))>>16);
      output_asm_insn ("lui\t%0,%x1\t#movsi high part of %2", xops);
      xops[1] = gen_rtx (CONST_INT, VOIDmode,
			 (INTVAL (operands[1])) & 0xffff);
    }
  else
    {
      xops[1] = gen_rtx (CONST_INT, VOIDmode,
			 (INTVAL (operands[1])) & 0xffff);
      output_asm_insn ("ori\t%0,$0,%x1\t#movsi low part of %2",
		       xops);
    }
  return "";
}

				/* Used to obtain address of subregs      */
				/* when in memory. This takes mode and    */
				/* subreg number into account             */

rtx
addr_compensate (addr, submode, origmode, subnum)
     rtx addr;
     enum machine_mode submode;
     enum machine_mode origmode;
     int subnum;
{
  extern rtx change_address ();
  extern rtx plus_constant ();

  if (submode == QImode && origmode == SImode)
    {
#ifdef BYTES_BIG_ENDIAN
      return change_address (addr, QImode,
			     plus_constant (XEXP (addr, 0), 3 - subnum));
#else
      return change_address (addr, QImode,
			     plus_constant (XEXP (addr, 0), subnum));
#endif
    }
  else if (submode == HImode && origmode == SImode)
    {
#ifdef BYTES_BIG_ENDIAN
      return change_address (addr, HImode,
			     plus_constant (XEXP (addr, 0), 2 - 2*subnum));
#else
      return change_address (addr, HImode,
			     plus_constant (XEXP (addr, 0), subnum));
#endif
    }
  else
    abort_with_insn (addr, "addr_compensate does not support mode");
}




				/* VARARGS */
int function_suspect;
int varargs_suspect = 0;
int this_varargs_suspect;

				/* PARAMETER LIST CONSTRUCTION */


static struct
{
  enum arg_state nxs_if_f, nxs_if_g;
  short reg_if_f, reg_if_g;
}
  arg_state_table[(int) (ARG_STA_GGGG + 1)]  = ARG_STA_AUTOMA;



				/* For use in Frame/ Stack pointer management*/
char * current_function_name;
int current_function_total_framesize;
typedef CUMULATIVE_ARGS cumulative_args;

enum arg_state
function_arg_advance (cum, mode, type)
     cumulative_args *cum;
     enum machine_mode mode;
     int type;
{
  cum->arg_rec_state
    = (FP_REGS == PREFERRED_RELOAD_CLASS_FM (mode, GR_REGS)
       ? arg_state_table[(int)((cum->arg_rec_state))].nxs_if_f
       : arg_state_table[(int)((cum->arg_rec_state))].nxs_if_g);

  (cum->arg_num)++;
}

rtx
function_arg (cum, mode, type, named)
     cumulative_args *cum;
     enum machine_mode mode;
     int type;
     int named;
{
  int regnum;

  regnum
    = (FP_REGS == PREFERRED_RELOAD_CLASS_FM (mode, GR_REGS)
       ? arg_state_table[(int)((cum->arg_rec_state))].reg_if_f
       : arg_state_table[(int)((cum->arg_rec_state))].reg_if_g);

  if (mode == BLKmode)
    return 0;
  else if (regnum >= 0)
    return gen_rtx (REG, mode, regnum);
  else if (regnum == -2)
    {
      if (mode == SFmode)
	return gen_rtx (SUBREG, SFmode, gen_rtx (REG, DFmode, 6), 0);
      else
	return gen_rtx (REG, DFmode, 6);
    }
  else
    return 0;
}



static  rtx branch_cmp_op[2];
static  enum machine_mode branch_cmp_mode;

compare_collect (mode, op0, op1)
     enum machine_mode mode;
     rtx op0;
     rtx op1;
{
  if (TARGET_DEBUGD_MODE)
    {
      fprintf (stderr, "compare_collect mode = %d, operands::", mode);
      my_print_rtx (op0);
      my_print_rtx (op1);
    }
  branch_cmp_op[0] = op0;
  branch_cmp_op[1] = op1;
  branch_cmp_mode = mode;
}


compare_restore (operands, mode, insn)
     rtx *operands;
     enum machine_mode *mode;
     rtx insn;
{
  rtx  previous;
  rtx  prev_par;
  if (TARGET_DEBUGD_MODE)
    {
      fprintf (stderr, "compare_restore returning mode = %d, operands:%X,%X:",
	       branch_cmp_mode, branch_cmp_op[0], branch_cmp_op[1]);
      my_print_rtx (branch_cmp_op[0]);
      my_print_rtx (branch_cmp_op[1]);
    }

  if ((! branch_cmp_op[0]) && (! branch_cmp_op[1]))
    {
      /*  Signal that multiple branches following */
      /* a comparison have been found             */
      if (TARGET_DEBUGD_MODE)
	{
	  fprintf (stderr, "Not at ease in compare_restore\n");
	  my_print_rtx (insn);
	  my_print_rtx (PREV_INSN (insn));
	}
      /*  Find the previous comparison */
      while ((GET_CODE (PREV_INSN (insn))) == JUMP_INSN)
	{
	  insn = PREV_INSN (insn);
	  if (TARGET_DEBUGD_MODE)
	    my_print_rtx (PREV_INSN (insn));
	}

      previous =  PATTERN (PREV_INSN (insn));

      if ((GET_CODE (previous)) == PARALLEL)
	{
	  /*  Signal  that we have a very strange */
	  /* RTL construct,... usually generated  */
	  /* by the optimizer, that seems to      */
	  /* contradict the documentation         */

	  /* However, this construct holds the    */
	  /* correct information in a very reliable */
	  /* way */

	  branch_cmp_op[0] = XVECEXP (previous, 0, 0);
	  branch_cmp_op[1] = XVECEXP (previous, 0, 1);
	  /*	   warning ("Check branch optimization with -mdebugd");
	   */
	}
      else
	if (((GET_CODE (previous)) == SET)
	    &&
	    ((GET_CODE (XEXP (previous, 0))) == CC0)
	    &&
	    ((GET_CODE (XEXP (previous, 1))) == COMPARE))
	  {			/* Here we find the comparison info    */
	    /* in a more classical format          */

	    previous = XEXP (previous, 1);
	    branch_cmp_op[0] = XEXP (previous, 0);
	    branch_cmp_op[1] = XEXP (previous, 1);
	  }
      	else
	  {			/* Be prepared for other things popping out */
	    abort ();
	  }
    }



  if (!  branch_cmp_op[0])
    operands[0] = gen_rtx (REG, VOIDmode, 0);
  else
    operands[0] = branch_cmp_op[0];
  if (!  branch_cmp_op[1])
    operands[1] = gen_rtx (REG, VOIDmode, 0);
  else
    operands[1] = branch_cmp_op[1];
  *mode = branch_cmp_mode;

  branch_cmp_op[0] = NULL;
  branch_cmp_op[1] = NULL;

}

#if 0
				/* See flags.h and toplev.c */
extern int optimize;
extern int flag_combine_regs;
extern int flag_strength_reduce;
extern int flag_no_peephole;
extern int flag_inline_functions;
extern int flag_omit_frame_pointer;
extern char *main_input_filename;
extern char *asm_file_name;
				/* See c-tree.h  and c-decl.c */
extern int flag_signed_char;

#include <time.h>
#include <sys/types.h>
#include <sys/timeb.h>

void
print_options (out)
     FILE *out;
{
  char *a_time;
  long c_time;

  fprintf (out, " #OPTIONS:\t%s%s%s%s%s%s%s\n",
	   (TARGET_NOFIXED_OVFL ? " -dnofixed-ovfl":" -dfixed-ovfl"),
	   (optimize ? " optimize" : ""),
	   (flag_combine_regs ? " -fcombine-regs" : " !combine-regs"),
	   (flag_strength_reduce ? "" : " !strength_reduce"),
	   (flag_omit_frame_pointer ?"" :" !omit_frame_pointer"),
	   (flag_no_peephole ? "" : " peephole"),
	   (flag_inline_functions ?" inline-functions":""));
  fprintf (out, " #OPTIONS:\t%s%s\n",
	   (flag_signed_char ? " signed-char" : " !signed-char"),
	   (TARGET_GP_OPT    ? " gpOPT"      : " !gpOPT"));
  fprintf (out, " #Source:\t%s\n", main_input_filename);
  fprintf (out, " #Destination:\t%s\n", asm_file_name);
  c_time = time (0);
  a_time = ctime (&c_time);
  fprintf (out, " #Compiled:\t%s", a_time);
#ifdef __GNUC__
#ifndef __VERSION__
#define __VERSION__ "[unknown]"
#endif
  fprintf (out, " # (META)compiled by GNU C version %s.\n", __VERSION__);
#else
  fprintf (out, " # (META)compiled by CC.\n");
#endif
}

				/* DEBUGGING UTILITIES */
rtx al_log_insn_debug;

abort_show_logged ()
{
  if (al_log_insn_debug)
    my_print_rtx (al_log_insn_debug);
  abort ();
}

extern FILE *outfile;

void
my_print_rtx (in_rtx)
     register rtx in_rtx;
{
  FILE *old;
  old = outfile;

  outfile = stderr;
  print_rtx (in_rtx);
  fprintf (outfile, "\n");

  outfile = old;
}

void
my_print_insncode (insn)
     rtx insn;
{
  FILE *old;
  old = outfile;

  outfile = stderr;
  print_rtx (insn);
  fprintf (outfile, "\n");
  fprintf (outfile, "INSN_CODE (insn) = %X\n", INSN_CODE (insn));

  outfile = old;
}

void
abort_with_insn (insn, reason)
     rtx insn;
     char *reason;
{
  fprintf (stderr, "About to Abort::%s\n", reason);
  my_print_rtx (insn);
  abort ();
}
#endif

void
abort_with_insn ()
{
  abort ();
}

void
my_print_rtx (in_rtx)
     register rtx in_rtx;

{
  abort();
}

#include "tree.h"
				/* GET SECTION (DATA/SDATA) THRESHOLD */
int mips_section_threshold = -1;

extern char *tree_code_name[];

int
mips_section_get ()
{
  register int i;
  if (mips_section_threshold == -1)
    {
      i = TARGET_GVALUE;
      if (i >= 6) i += 3;
      if ((1 << i) != MIPS_GVALUE_DEFAULT)
	warning ("G value this run == %d\n", 1 << i);
      mips_section_threshold = 1 << i;
    }

  return mips_section_threshold;
}

int
mips_output_external (file, tree_exp, name)
     FILE *file;
     tree tree_exp;
     char *name;
{
  register int i;
  if (TARGET_GP_OPT
      && ((TREE_CODE (tree_exp)) != FUNCTION_DECL)
      &&
      ((i = int_size_in_bytes (TREE_TYPE (tree_exp))) > 0))
    {
      fputs ("\n#ifndef _gccx__", file);
      assemble_name (file, name);
      fputs ("\n.extern\t", (file));
      assemble_name ((file), (name));
      fprintf ((file), ", %d", i, (TREE_TYPE (tree_exp)));
      fputs ("\n#define _gccx__", file);
      assemble_name (file, name);
      fputs ("\n#endif\n ", file);
    }
  return 0;
}

extern char *asm_file_name;

int
mips_asm_file_end (file)
     FILE *file;
{
  if (TARGET_GP_OPT)
    {
      fprintf (file, "\n#else\n#ifndef %sRESCAN_GCC", "__x_");
      fprintf (file, "\n#define %sRESCAN_GCC\n#include \"%s\"", "__x_",
	       asm_file_name);
      fprintf (file, "\n#endif\n#endif\n");
    }
}
