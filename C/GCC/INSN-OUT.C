/* Generated automatically by the program `genoutput'
from the machine description file `md'.  */

#include "config.h"
#include "rtl.h"
#include "regs.h"
#include "conditions.h"
#include "insn-flags.h"
#include "insn-config.h"

#include "output.h"
#include "aux-output.c"


char *
output_0 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (FP_REG_P (operands[1]))
    return "fmove%.d %f1,%0";
  return output_move_double (operands);
}
}

char *
output_1 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  return output_move_double (operands);
}
}

char *
output_2 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
#ifdef ISI_OV
  /* ISI's assembler fails to handle tstl a0.  */
  if (! ADDRESS_REG_P (operands[0]))
#else
  if (TARGET_68020 || ! ADDRESS_REG_P (operands[0]))
#endif
    return "tst%.l %0";
  /* If you think that the 68020 does not support tstl a0,
     reread page B-167 of the 68020 manual more carefully.  */
  /* On an address reg, cmpw may replace cmpl.  */
#ifdef HPUX_ASM
  return "cmp%.w %0,%#0";
#else
  return "cmp%.w %#0,%0";
#endif
}
}

char *
output_3 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
#ifdef ISI_OV
  if (! ADDRESS_REG_P (operands[0]))
#else
  if (TARGET_68020 || ! ADDRESS_REG_P (operands[0]))
#endif
    return "tst%.w %0";
#ifdef HPUX_ASM
  return "cmp%.w %0,%#0";
#else
  return "cmp%.w %#0,%0";
#endif
}
}

char *
output_5 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  cc_status.flags = CC_IN_68881;
  if (FP_REG_P (operands[0]))
    return "ftst%.x %0";
  return "ftst%.s %0";
}
}

char *
output_6 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  cc_status.flags = CC_IN_68881;
  if (FP_REG_P (operands[0]))
    return "ftst%.x %0";
  return "ftst%.d %0";
}
}

char *
output_7 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (REG_P (operands[1])
      || (!REG_P (operands[0]) && GET_CODE (operands[0]) != MEM))
    { cc_status.flags |= CC_REVERSED;
#ifdef HPUX_ASM
      return "cmp%.l %1,%0";
#else
      return "cmp%.l %0,%1"; 
#endif
    }
#ifdef HPUX_ASM
  return "cmp%.l %0,%1";
#else
  return "cmp%.l %1,%0";
#endif
}
}

char *
output_8 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (REG_P (operands[1])
      || (!REG_P (operands[0]) && GET_CODE (operands[0]) != MEM))
    { cc_status.flags |= CC_REVERSED;
#ifdef HPUX_ASM
      return "cmp%.w %1,%0";
#else
      return "cmp%.w %0,%1"; 
#endif
    }
#ifdef HPUX_ASM
  return "cmp%.w %0,%1";
#else
  return "cmp%.w %1,%0";
#endif
}
}

char *
output_9 (operands, insn)
     rtx *operands;
     rtx insn;
{

#ifdef MOTOROLA
  return "cmpm.b (%1)+,(%0)+";
#else
  return "cmpmb %1@+,%0@+";
#endif

}

char *
output_10 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (REG_P (operands[1])
      || (!REG_P (operands[0]) && GET_CODE (operands[0]) != MEM))
    { cc_status.flags |= CC_REVERSED;
#ifdef HPUX_ASM
      return "cmp%.b %1,%0";
#else
      return "cmp%.b %0,%1";
#endif
    }
#ifdef HPUX_ASM
  return "cmp%.b %0,%1";
#else
  return "cmp%.b %1,%0";
#endif
}
}

char *
output_11 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  cc_status.flags = CC_IN_68881;
#ifdef HPUX_ASM
  if (REG_P (operands[0]))
    {
      if (REG_P (operands[1]))
	return "fcmp%.x %0,%1";
      else
        return "fcmp%.d %0,%f1";
    }
  cc_status.flags |= CC_REVERSED;
  return "fcmp%.d %1,%f0";
#else
  if (REG_P (operands[0]))
    {
      if (REG_P (operands[1]))
	return "fcmp%.x %1,%0";
      else
        return "fcmp%.d %f1,%0";
    }
  cc_status.flags |= CC_REVERSED;
  return "fcmp%.d %f0,%1";
#endif
}
}

char *
output_12 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  cc_status.flags = CC_IN_68881;
#ifdef HPUX_ASM
  if (FP_REG_P (operands[0]))
    {
      if (FP_REG_P (operands[1]))
	return "fcmp%.x %0,%1";
      else
        return "fcmp%.s %0,%f1";
    }
  cc_status.flags |= CC_REVERSED;
  return "fcmp%.s %1,%f0";
#else
  if (FP_REG_P (operands[0]))
    {
      if (FP_REG_P (operands[1]))
	return "fcmp%.x %1,%0";
      else
        return "fcmp%.s %f1,%0";
    }
  cc_status.flags |= CC_REVERSED;
  return "fcmp%.s %f0,%1";
#endif
}
}

char *
output_13 (operands, insn)
     rtx *operands;
     rtx insn;
{
 { return output_btst (operands, operands[1], operands[0], insn, 7); }
}

char *
output_14 (operands, insn)
     rtx *operands;
     rtx insn;
{
 { return output_btst (operands, operands[1], operands[0], insn, 31); }
}

char *
output_15 (operands, insn)
     rtx *operands;
     rtx insn;
{
 { return output_btst (operands, operands[1], operands[0], insn, 7); }
}

char *
output_16 (operands, insn)
     rtx *operands;
     rtx insn;
{
 { return output_btst (operands, operands[1], operands[0], insn, 31); }
}

char *
output_17 (operands, insn)
     rtx *operands;
     rtx insn;
{

{ operands[1] = gen_rtx (CONST_INT, VOIDmode, 7 - INTVAL (operands[1]));
  return output_btst (operands, operands[1], operands[0], insn, 7); }
}

char *
output_18 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (GET_CODE (operands[0]) == MEM)
    {
      operands[0] = adj_offsetable_operand (operands[0],
					    INTVAL (operands[1]) / 8);
      operands[1] = gen_rtx (CONST_INT, VOIDmode, 
			     7 - INTVAL (operands[1]) % 8);
      return output_btst (operands, operands[1], operands[0], insn, 7);
    }
  operands[1] = gen_rtx (CONST_INT, VOIDmode,
			 15 - INTVAL (operands[1]));
  return output_btst (operands, operands[1], operands[0], insn, 15);
}
}

char *
output_19 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (GET_CODE (operands[0]) == MEM)
    {
      operands[0] = adj_offsetable_operand (operands[0],
					    INTVAL (operands[1]) / 8);
      operands[1] = gen_rtx (CONST_INT, VOIDmode, 
			     7 - INTVAL (operands[1]) % 8);
      return output_btst (operands, operands[1], operands[0], insn, 7);
    }
  operands[1] = gen_rtx (CONST_INT, VOIDmode,
			 31 - INTVAL (operands[1]));
  return output_btst (operands, operands[1], operands[0], insn, 31);
}
}

char *
output_20 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  cc_status.flags = CC_Z_IN_NOT_N | CC_NOT_NEGATIVE;
  return "tst%.b %0";
}
}

char *
output_21 (operands, insn)
     rtx *operands;
     rtx insn;
{

{ register int log = exact_log2 (INTVAL (operands[1]));
  operands[1] = gen_rtx (CONST_INT, VOIDmode, log);
  return output_btst (operands, operands[1], operands[0], insn, 7);
}
}

char *
output_23 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (ADDRESS_REG_P (operands[0]))
    return "sub%.l %0,%0";
  return "clr%.l %0";
}
}

char *
output_25 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (GET_CODE (operands[1]) == CONST_INT)
    {
      if (operands[1] == const0_rtx
	  && (DATA_REG_P (operands[0])
	      || GET_CODE (operands[0]) == MEM))
	return "clr%.l %0";
      else if (DATA_REG_P (operands[0])
	       && INTVAL (operands[1]) < 128
	       && INTVAL (operands[1]) >= -128)
        {
#ifdef MOTOROLA
          return "moveq%.l %1,%0";
#else
	  return "moveq %1,%0";
#endif
	}
      else if (ADDRESS_REG_P (operands[0])
	       && INTVAL (operands[1]) < 0x8000
	       && INTVAL (operands[1]) >= -0x8000)
	return "move%.w %1,%0";
      else if (push_operand (operands[0], SImode)
	       && INTVAL (operands[1]) < 0x8000
	       && INTVAL (operands[1]) >= -0x8000)
        return "pea %a1";
    }
  else if ((GET_CODE (operands[1]) == SYMBOL_REF
	    || GET_CODE (operands[1]) == CONST)
	   && push_operand (operands[0], SImode))
    return "pea %a1";
  else if ((GET_CODE (operands[1]) == SYMBOL_REF
	    || GET_CODE (operands[1]) == CONST)
	   && ADDRESS_REG_P (operands[0]))
    return "lea %a1,%0";
  return "move%.l %1,%0";
}
}

char *
output_26 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (GET_CODE (operands[1]) == CONST_INT)
    {
      if (operands[1] == const0_rtx
	  && (DATA_REG_P (operands[0])
	      || GET_CODE (operands[0]) == MEM))
	return "clr%.w %0";
    }
  else if (CONSTANT_P (operands[1]))
    return "move%.l %1,%0";
  /* Recognize the insn before a tablejump, one that refers
     to a table of offsets.  Such an insn will need to refer
     to a label on the insn.  So output one.  Use the label-number
     of the table of offsets to generate this label.  */
  if (GET_CODE (operands[1]) == MEM
      && GET_CODE (XEXP (operands[1], 0)) == PLUS
      && (GET_CODE (XEXP (XEXP (operands[1], 0), 0)) == LABEL_REF
	  || GET_CODE (XEXP (XEXP (operands[1], 0), 1)) == LABEL_REF)
      && GET_CODE (XEXP (XEXP (operands[1], 0), 0)) != PLUS
      && GET_CODE (XEXP (XEXP (operands[1], 0), 1)) != PLUS)
    {
      rtx labelref;
      if (GET_CODE (XEXP (XEXP (operands[1], 0), 0)) == LABEL_REF)
	labelref = XEXP (XEXP (operands[1], 0), 0);
      else
	labelref = XEXP (XEXP (operands[1], 0), 1);
#if defined (MOTOROLA) && ! defined (SGS_3B1)
#ifdef SGS
      fprintf (asm_out_file, "\tset %s%d,.+2\n", "LI",
	       CODE_LABEL_NUMBER (XEXP (labelref, 0)));
#else
      fprintf (asm_out_file, "\t.set %s%d,.+2\n", "LI",
	       CODE_LABEL_NUMBER (XEXP (labelref, 0)));
#endif
#else
      ASM_OUTPUT_INTERNAL_LABEL (asm_out_file, "LI",
				 CODE_LABEL_NUMBER (XEXP (labelref, 0)));
#endif
    }
  return "move%.w %1,%0";
}
}

char *
output_27 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (GET_CODE (operands[1]) == CONST_INT)
    {
      if (operands[1] == const0_rtx
	  && (DATA_REG_P (operands[0])
	      || GET_CODE (operands[0]) == MEM))
	return "clr%.w %0";
    }
  return "move%.w %1,%0";
}
}

char *
output_28 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (operands[1] == const0_rtx)
    return "clr%.b %0";
  if (GET_CODE (operands[1]) == CONST_INT
      && INTVAL (operands[1]) == -1)
    return "st %0";
  if (GET_CODE (operands[1]) != CONST_INT && CONSTANT_P (operands[1]))
    return "move%.l %1,%0";
  if (ADDRESS_REG_P (operands[0]) || ADDRESS_REG_P (operands[1]))
    return "move%.w %1,%0";
  return "move%.b %1,%0";
}
}

char *
output_29 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (operands[1] == const0_rtx)
    return "clr%.b %0";
  return "move%.b %1,%0";
}
}

char *
output_30 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (FP_REG_P (operands[0]))
    {
      if (FP_REG_P (operands[1]))
	return "fmove%.x %1,%0";
      else if (ADDRESS_REG_P (operands[1]))
	return "move%.l %1,%-\n\tfmove%.s %+,%0";
      else if (GET_CODE (operands[1]) == CONST_DOUBLE)
	return output_move_const_single (operands);
      return "fmove%.s %f1,%0";
    }
  if (FP_REG_P (operands[1]))
    {
      if (ADDRESS_REG_P (operands[0]))
	return "fmove%.s %1,%-\n\tmove%.l %+,%0";
      return "fmove%.s %f1,%0";
    }
  return "move%.l %1,%0";
}
}

char *
output_31 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (FP_REG_P (operands[0]))
    {
      if (FP_REG_P (operands[1]))
	return "fmove%.x %1,%0";
      if (REG_P (operands[1]))
	{
	  rtx xoperands[2];
	  xoperands[1] = gen_rtx (REG, SImode, REGNO (operands[1]) + 1);
	  output_asm_insn ("move%.l %1,%-", xoperands);
	  output_asm_insn ("move%.l %1,%-", operands);
	  return "fmove%.d %+,%0";
	}
      if (GET_CODE (operands[1]) == CONST_DOUBLE)
	return output_move_const_double (operands);
      return "fmove%.d %f1,%0";
    }
  else if (FP_REG_P (operands[1]))
    {
      if (REG_P (operands[0]))
	{
	  output_asm_insn ("fmove%.d %f1,%-\n\tmove%.l %+,%0", operands);
	  operands[0] = gen_rtx (REG, SImode, REGNO (operands[0]) + 1);
	  return "move%.l %+,%0";
	}
      else
        return "fmove%.d %f1,%0";
    }
  return output_move_double (operands);
}

}

char *
output_32 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (FP_REG_P (operands[0]))
    {
      if (FP_REG_P (operands[1]))
	return "fmove%.x %1,%0";
      if (REG_P (operands[1]))
	{
	  rtx xoperands[2];
	  xoperands[1] = gen_rtx (REG, SImode, REGNO (operands[1]) + 1);
	  output_asm_insn ("move%.l %1,%-", xoperands);
	  output_asm_insn ("move%.l %1,%-", operands);
	  return "fmove%.d %+,%0";
	}
      if (GET_CODE (operands[1]) == CONST_DOUBLE)
	return output_move_const_double (operands);
      return "fmove%.d %f1,%0";
    }
  else if (FP_REG_P (operands[1]))
    {
      if (REG_P (operands[0]))
	{
	  output_asm_insn ("fmove.d %f1,%-\n\tmove%.l %+,%0", operands);
	  operands[0] = gen_rtx (REG, SImode, REGNO (operands[0]) + 1);
	  return "move%.l %+,%0";
	}
      else
        return "fmove%.d %f1,%0";
    }
  return output_move_double (operands);
}

}

char *
output_35 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (GET_CODE (operands[0]) == REG)
    return "move%.l %1,%0";
  if (GET_CODE (operands[1]) == MEM)
    operands[1] = adj_offsetable_operand (operands[1], 3);
  return "move%.b %1,%0";
}
}

char *
output_36 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (GET_CODE (operands[0]) == REG)
    return "move%.l %1,%0";
  if (GET_CODE (operands[1]) == MEM)
    operands[1] = adj_offsetable_operand (operands[1], 1);
  return "move%.b %1,%0";
}
}

char *
output_37 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (GET_CODE (operands[0]) == REG)
    return "move%.l %1,%0";
  if (GET_CODE (operands[1]) == MEM)
    operands[1] = adj_offsetable_operand (operands[1], 2);
  return "move%.w %1,%0";
}
}

char *
output_41 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (ADDRESS_REG_P (operands[0]))
    return "move%.w %1,%0";
  return "ext%.l %0";
}
}

char *
output_44 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (FP_REG_P (operands[0]) && FP_REG_P (operands[1]))
    {
      if (REGNO (operands[0]) == REGNO (operands[1]))
	{
	  /* Extending float to double in an fp-reg is a no-op.
	     NOTICE_UPDATE_CC has already assumed that the
	     cc will be set.  So cancel what it did.  */
	  cc_status = cc_prev_status;
	  return "";
	}
      return "fmove%.x %1,%0";
    }
  if (FP_REG_P (operands[0]))
    return "fmove%.s %f1,%0";
  if (DATA_REG_P (operands[0]) && FP_REG_P (operands[1]))
    {
      output_asm_insn ("fmove%.d %f1,%-\n\tmove%.l %+,%0", operands);
      operands[0] = gen_rtx (REG, SImode, REGNO (operands[0]) + 1);
      return "move%.l %+,%0";
    }
  return "fmove%.d %f1,%0";
}
}

char *
output_52 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (FP_REG_P (operands[1]))
    return "fintrz%.x %f1,%0";
  return "fintrz%.d %f1,%0";
}
}

char *
output_53 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (FP_REG_P (operands[1]))
    return "fintrz%.x %f1,%0";
  return "fintrz%.s %f1,%0";
}
}

char *
output_60 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (! operands_match_p (operands[0], operands[1]))
    {
      /* These insns can result from reloads to access
	 stack slots over 64k from the frame pointer.  */
      if (GET_CODE (operands[2]) == CONST_INT
	  && INTVAL (operands[2]) + 0x8000 >= (unsigned) 0x10000)
        return "move%.l %2,%0\n\tadd%.l %1,%0";
#ifdef SGS
      if (GET_CODE (operands[2]) == REG)
	return "lea (%1,%2.l),%0";
      else
	return "lea %c2(%1),%0";
#else /* not SGS */
#ifdef MOTOROLA
      if (GET_CODE (operands[2]) == REG)
	return "lea (%1,%2.l),%0";
      else
	return "lea (%c2,%1),%0";
#else /* not MOTOROLA (MIT syntax) */
      if (GET_CODE (operands[2]) == REG)
	return "lea %1@(0,%2:l),%0";
      else
	return "lea %1@(%c2),%0";
#endif /* not MOTOROLA */
#endif /* not SGS */
    }
  if (GET_CODE (operands[2]) == CONST_INT)
    {
      if (INTVAL (operands[2]) > 0
	  && INTVAL (operands[2]) <= 8)
	return "addq%.l %2,%0";
      if (INTVAL (operands[2]) < 0
	  && INTVAL (operands[2]) >= -8)
        {
	  operands[2] = gen_rtx (CONST_INT, VOIDmode,
			         - INTVAL (operands[2]));
	  return "subq%.l %2,%0";
	}
      if (ADDRESS_REG_P (operands[0])
	  && INTVAL (operands[2]) >= -0x8000
	  && INTVAL (operands[2]) < 0x8000)
	return "add%.w %2,%0";
    }
  return "add%.l %2,%0";
}
}

char *
output_62 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (GET_CODE (operands[2]) == CONST_INT)
    {
      if (INTVAL (operands[2]) > 0
	  && INTVAL (operands[2]) <= 8)
	return "addq%.w %2,%0";
    }
  if (GET_CODE (operands[2]) == CONST_INT)
    {
      if (INTVAL (operands[2]) < 0
	  && INTVAL (operands[2]) >= -8)
	{
	  operands[2] = gen_rtx (CONST_INT, VOIDmode,
			         - INTVAL (operands[2]));
	  return "subq%.w %2,%0";
	}
    }
  return "add%.w %2,%0";
}
}

char *
output_64 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (GET_CODE (operands[2]) == CONST_INT)
    {
      if (INTVAL (operands[2]) > 0
	  && INTVAL (operands[2]) <= 8)
	return "addq%.b %2,%0";
    }
  if (GET_CODE (operands[2]) == CONST_INT)
    {
      if (INTVAL (operands[2]) < 0 && INTVAL (operands[2]) >= -8)
       {
	 operands[2] = gen_rtx (CONST_INT, VOIDmode, - INTVAL (operands[2]));
	 return "subq%.b %2,%0";
       }
    }
  return "add%.b %2,%0";
}
}

char *
output_66 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (REG_P (operands[2]))
    return "fadd%.x %2,%0";
  return "fadd%.d %f2,%0";
}
}

char *
output_67 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (REG_P (operands[2]) && ! DATA_REG_P (operands[2]))
    return "fadd%.x %2,%0";
  return "fadd%.s %f2,%0";
}
}

char *
output_68 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (! operands_match_p (operands[0], operands[1]))
    {
      if (operands_match_p (operands[0], operands[2]))
	{
	  if (GET_CODE (operands[1]) == CONST_INT)
	    {
	      if (INTVAL (operands[1]) > 0
		  && INTVAL (operands[1]) <= 8)
		return "subq%.l %1,%0\n\tneg%.l %0";
	    }
	  return "sub%.l %1,%0\n\tneg%.l %0";
	}
      /* This case is matched by J, but negating -0x8000
         in an lea would give an invalid displacement.
	 So do this specially.  */
      if (INTVAL (operands[2]) == -0x8000)
	return "move%.l %1,%0\n\tsub%.l %2,%0";
#ifdef SGS
      return "lea %n2(%1),%0";
#else
#ifdef MOTOROLA
      return "lea (%n2,%1),%0";
#else /* not MOTOROLA (MIT syntax) */
      return "lea %1@(%n2),%0";
#endif /* not MOTOROLA */
#endif /* not SGS */
    }
  if (GET_CODE (operands[2]) == CONST_INT)
    {
      if (INTVAL (operands[2]) > 0
	  && INTVAL (operands[2]) <= 8)
	return "subq%.l %2,%0";
      if (ADDRESS_REG_P (operands[0])
	  && INTVAL (operands[2]) >= -0x8000
	  && INTVAL (operands[2]) < 0x8000)
	return "sub%.w %2,%0";
    }
  return "sub%.l %2,%0";
}
}

char *
output_74 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (REG_P (operands[2]))
    return "fsub%.x %2,%0";
  return "fsub%.d %f2,%0";
}
}

char *
output_75 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (REG_P (operands[2]) && ! DATA_REG_P (operands[2]))
    return "fsub%.x %2,%0";
  return "fsub%.s %f2,%0";
}
}

char *
output_76 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
#ifdef MOTOROLA
  return "muls.w %2,%0";
#else
  return "muls %2,%0";
#endif
}
}

char *
output_77 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
#ifdef MOTOROLA
  return "muls.w %2,%0";
#else
  return "muls %2,%0";
#endif
}
}

char *
output_79 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
#ifdef MOTOROLA
  return "mulu.w %2,%0";
#else
  return "mulu %2,%0";
#endif
}
}

char *
output_80 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
#ifdef MOTOROLA
  return "mulu.w %2,%0";
#else
  return "mulu %2,%0";
#endif
}
}

char *
output_82 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (REG_P (operands[2]))
    return "fmul%.x %2,%0";
  return "fmul%.d %f2,%0";
}
}

char *
output_83 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (REG_P (operands[2]) && ! DATA_REG_P (operands[2]))
    return "fsglmul%.x %2,%0";
  return "fsglmul%.s %f2,%0";
}
}

char *
output_84 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
#ifdef MOTOROLA
  return "ext.l %0\n\tdivs.w %2,%0";
#else
  return "extl %0\n\tdivs %2,%0";
#endif
}
}

char *
output_85 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
#ifdef MOTOROLA
  return "divs.w %2,%0";
#else
  return "divs %2,%0";
#endif
}
}

char *
output_87 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
#ifdef MOTOROLA
  return "and.l %#0xFFFF,%0\n\tdivu.w %2,%0";
#else
  return "andl %#0xFFFF,%0\n\tdivu %2,%0";
#endif
}
}

char *
output_88 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
#ifdef MOTOROLA
  return "divu.w %2,%0";
#else
  return "divu %2,%0";
#endif
}
}

char *
output_90 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (REG_P (operands[2]))
    return "fdiv%.x %2,%0";
  return "fdiv%.d %f2,%0";
}
}

char *
output_91 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (REG_P (operands[2]) && ! DATA_REG_P (operands[2]))
    return "fsgldiv%.x %2,%0";
  return "fsgldiv%.s %f2,%0";
}
}

char *
output_92 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  /* The swap insn produces cc's that don't correspond to the result.  */
  CC_STATUS_INIT;
#ifdef MOTOROLA
  return "ext.l %0\n\tdivs.w %2,%0\n\tswap %0";
#else
  return "extl %0\n\tdivs %2,%0\n\tswap %0";
#endif
}
}

char *
output_93 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  /* The swap insn produces cc's that don't correspond to the result.  */
  CC_STATUS_INIT;
#ifdef MOTOROLA
  return "divs.w %2,%0\n\tswap %0";
#else
  return "divs %2,%0\n\tswap %0";
#endif
}
}

char *
output_94 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  /* The swap insn produces cc's that don't correspond to the result.  */
  CC_STATUS_INIT;
#ifdef MOTOROLA
  return "and.l %#0xFFFF,%0\n\tdivu.w %2,%0\n\tswap %0";
#else
  return "andl %#0xFFFF,%0\n\tdivu %2,%0\n\tswap %0";
#endif
}
}

char *
output_95 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  /* The swap insn produces cc's that don't correspond to the result.  */
  CC_STATUS_INIT;
#ifdef MOTOROLA
  return "divu.w %2,%0\n\tswap %0";
#else
  return "divu %2,%0\n\tswap %0";
#endif
}
}

char *
output_98 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (GET_CODE (operands[2]) == CONST_INT
      && (INTVAL (operands[2]) | 0xffff) == 0xffffffff
      && (DATA_REG_P (operands[0])
	  || offsetable_memref_p (operands[0])))
    { 
      if (GET_CODE (operands[0]) != REG)
        operands[0] = adj_offsetable_operand (operands[0], 2);
      operands[2] = gen_rtx (CONST_INT, VOIDmode,
			     INTVAL (operands[2]) & 0xffff);
      /* Do not delete a following tstl %0 insn; that would be incorrect.  */
      CC_STATUS_INIT;
      return "and%.w %2,%0";
    }
  return "and%.l %2,%0";
}
}

char *
output_103 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  register int logval;
  if (GET_CODE (operands[2]) == CONST_INT
      && INTVAL (operands[2]) >> 16 == 0
      && (DATA_REG_P (operands[0])
	  || offsetable_memref_p (operands[0])))
    { 
      if (GET_CODE (operands[0]) != REG)
        operands[0] = adj_offsetable_operand (operands[0], 2);
      /* Do not delete a following tstl %0 insn; that would be incorrect.  */
      CC_STATUS_INIT;
      return "or%.w %2,%0";
    }
  if (GET_CODE (operands[2]) == CONST_INT
      && (logval = exact_log2 (INTVAL (operands[2]))) >= 0
      && (DATA_REG_P (operands[0])
	  || offsetable_memref_p (operands[0])))
    { 
      if (DATA_REG_P (operands[0]))
	{
	  operands[1] = gen_rtx (CONST_INT, VOIDmode, logval);
	}
      else
        {
	  operands[0] = adj_offsetable_operand (operands[0], 3 - (logval / 8));
	  operands[1] = gen_rtx (CONST_INT, VOIDmode, logval % 8);
	}
      return "bset %1,%0";
    }
  return "or%.l %2,%0";
}
}

char *
output_106 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (GET_CODE (operands[2]) == CONST_INT
      && INTVAL (operands[2]) >> 16 == 0
      && (offsetable_memref_p (operands[0]) || DATA_REG_P (operands[0])))
    { 
      if (! DATA_REG_P (operands[0]))
	operands[0] = adj_offsetable_operand (operands[0], 2);
      /* Do not delete a following tstl %0 insn; that would be incorrect.  */
      CC_STATUS_INIT;
      return "eor%.w %2,%0";
    }
  return "eor%.l %2,%0";
}
}

char *
output_112 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (REG_P (operands[1]) && ! DATA_REG_P (operands[1]))
    return "fneg%.x %1,%0";
  return "fneg%.s %f1,%0";
}
}

char *
output_113 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (REG_P (operands[1]) && ! DATA_REG_P (operands[1]))
    return "fneg%.x %1,%0";
  return "fneg%.d %f1,%0";
}
}

char *
output_114 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (REG_P (operands[1]) && ! DATA_REG_P (operands[1]))
    return "fabs%.x %1,%0";
  return "fabs%.s %f1,%0";
}
}

char *
output_115 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (REG_P (operands[1]) && ! DATA_REG_P (operands[1]))
    return "fabs%.x %1,%0";
  return "fabs%.d %f1,%0";
}
}

char *
output_119 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (TARGET_68020)
    return "move%.b %1,%0\n\textb%.l %0";
  return "move%.b %1,%0\n\text%.w %0\n\text%.l %0";
}
}

char *
output_120 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (reg_mentioned_p (operands[0], operands[1]))
    return "move%.b %1,%0\n\tand%.l %#0xFF,%0";
  return "clr%.l %0\n\tmove%.b %1,%0";
}
}

char *
output_121 (operands, insn)
     rtx *operands;
     rtx insn;
{
 cc_status.flags |= CC_REVERSED;
#ifdef HPUX_ASM
  return "cmp%.b %1,%0";
#else
  return "cmp%.b %0,%1";
#endif

}

char *
output_122 (operands, insn)
     rtx *operands;
     rtx insn;
{

#ifdef HPUX_ASM
  return "cmp%.b %0,%1";
#else
  return "cmp%.b %1,%0";
#endif

}

char *
output_123 (operands, insn)
     rtx *operands;
     rtx insn;
{
 cc_status.flags |= CC_REVERSED;
#ifdef HPUX_ASM
  return "cmp%.b %1,%0";
#else
  return "cmp%.b %0,%1";
#endif

}

char *
output_124 (operands, insn)
     rtx *operands;
     rtx insn;
{

#ifdef HPUX_ASM
  return "cmp%.b %0,%1";
#else
  return "cmp%.b %1,%0";
#endif

}

char *
output_143 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (REG_P (operands[0]))
    {
      if (INTVAL (operands[1]) + INTVAL (operands[2]) != 32)
        return "bfins %3,%0{%b2:%b1}";
    }
  else
    operands[0]
      = adj_offsetable_operand (operands[0], INTVAL (operands[2]) / 8);

  if (GET_CODE (operands[3]) == MEM)
    operands[3] = adj_offsetable_operand (operands[3],
					  (32 - INTVAL (operands[1])) / 8);
  if (INTVAL (operands[1]) == 8)
    return "move%.b %3,%0";
  return "move%.w %3,%0";
}
}

char *
output_144 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (REG_P (operands[1]))
    {
      if (INTVAL (operands[2]) + INTVAL (operands[3]) != 32)
	return "bfextu %1{%b3:%b2},%0";
    }
  else
    operands[1]
      = adj_offsetable_operand (operands[1], INTVAL (operands[3]) / 8);

  output_asm_insn ("clr%.l %0", operands);
  if (GET_CODE (operands[0]) == MEM)
    operands[0] = adj_offsetable_operand (operands[0],
					  (32 - INTVAL (operands[1])) / 8);
  if (INTVAL (operands[2]) == 8)
    return "move%.b %1,%0";
  return "move%.w %1,%0";
}
}

char *
output_145 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (REG_P (operands[1]))
    {
      if (INTVAL (operands[2]) + INTVAL (operands[3]) != 32)
	return "bfexts %1{%b3:%b2},%0";
    }
  else
    operands[1]
      = adj_offsetable_operand (operands[1], INTVAL (operands[3]) / 8);

  if (INTVAL (operands[2]) == 8)
    return "move%.b %1,%0\n\textb%.l %0";
  return "move%.w %1,%0\n\text%.l %0";
}
}

char *
output_156 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
#if 0
  /* These special cases are now recognized by a specific pattern.  */
  if (GET_CODE (operands[1]) == CONST_INT && GET_CODE (operands[2]) == CONST_INT
      && INTVAL (operands[1]) == 16 && INTVAL (operands[2]) == 16)
    return "move%.w %3,%0";
  if (GET_CODE (operands[1]) == CONST_INT && GET_CODE (operands[2]) == CONST_INT
      && INTVAL (operands[1]) == 24 && INTVAL (operands[2]) == 8)
    return "move%.b %3,%0";
#endif
  return "bfins %3,%0{%b2:%b1}";
}
}

char *
output_157 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (operands[1] == const1_rtx
      && GET_CODE (operands[2]) == CONST_INT)
    {    
      int width = GET_CODE (operands[0]) == REG ? 31 : 7;
      return output_btst (operands,
			  gen_rtx (CONST_INT, VOIDmode,
				   width - INTVAL (operands[2])),
			  operands[0],
			  insn, 1000);
      /* Pass 1000 as SIGNPOS argument so that btst will
         not think we are testing the sign bit for an `and'
	 and assume that nonzero implies a negative result.  */
    }
  if (INTVAL (operands[1]) != 32)
    cc_status.flags = CC_NOT_NEGATIVE;
  return "bftst %0{%b2:%b1}";
}
}

char *
output_158 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (operands[1] == const1_rtx
      && GET_CODE (operands[2]) == CONST_INT)
    {    
      int width = GET_CODE (operands[0]) == REG ? 31 : 7;
      return output_btst (operands,
			  gen_rtx (CONST_INT, VOIDmode,
				   width - INTVAL (operands[2])),
			  operands[0],
			  insn, 1000);
      /* Pass 1000 as SIGNPOS argument so that btst will
         not think we are testing the sign bit for an `and'
	 and assume that nonzero implies a negative result.  */
    }
  if (INTVAL (operands[1]) != 32)
    cc_status.flags = CC_NOT_NEGATIVE;
  return "bftst %0{%b2:%b1}";
}
}

char *
output_159 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (operands[1] == const1_rtx
      && GET_CODE (operands[2]) == CONST_INT)
    {    
      int width = GET_CODE (operands[0]) == REG ? 31 : 7;
      return output_btst (operands,
			  gen_rtx (CONST_INT, VOIDmode,
				   width - INTVAL (operands[2])),
			  operands[0],
			  insn, 1000);
      /* Pass 1000 as SIGNPOS argument so that btst will
         not think we are testing the sign bit for an `and'
	 and assume that nonzero implies a negative result.  */
    }
  if (INTVAL (operands[1]) != 32)
    cc_status.flags = CC_NOT_NEGATIVE;
  return "bftst %0{%b2:%b1}";
}
}

char *
output_160 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (operands[1] == const1_rtx
      && GET_CODE (operands[2]) == CONST_INT)
    {    
      int width = GET_CODE (operands[0]) == REG ? 31 : 7;
      return output_btst (operands,
			  gen_rtx (CONST_INT, VOIDmode,
				   width - INTVAL (operands[2])),
			  operands[0],
			  insn, 1000);
      /* Pass 1000 as SIGNPOS argument so that btst will
         not think we are testing the sign bit for an `and'
	 and assume that nonzero implies a negative result.  */
    }
  if (INTVAL (operands[1]) != 32)
    cc_status.flags = CC_NOT_NEGATIVE;
  return "bftst %0{%b2:%b1}";
}
}

char *
output_161 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (operands[1] == const1_rtx
      && GET_CODE (operands[2]) == CONST_INT)
    {    
      int width = GET_CODE (operands[0]) == REG ? 31 : 7;
      return output_btst (operands,
			  gen_rtx (CONST_INT, VOIDmode,
				   width - INTVAL (operands[2])),
			  operands[0],
			  insn, 1000);
      /* Pass 1000 as SIGNPOS argument so that btst will
         not think we are testing the sign bit for an `and'
	 and assume that nonzero implies a negative result.  */
    }
  if (INTVAL (operands[1]) != 32)
    cc_status.flags = CC_NOT_NEGATIVE;
  return "bftst %0{%b2:%b1}";
}
}

char *
output_162 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (operands[1] == const1_rtx
      && GET_CODE (operands[2]) == CONST_INT)
    {    
      int width = GET_CODE (operands[0]) == REG ? 31 : 7;
      return output_btst (operands,
			  gen_rtx (CONST_INT, VOIDmode,
				   width - INTVAL (operands[2])),
			  operands[0],
			  insn, 1000);
      /* Pass 1000 as SIGNPOS argument so that btst will
         not think we are testing the sign bit for an `and'
	 and assume that nonzero implies a negative result.  */
    }
  if (INTVAL (operands[1]) != 32)
    cc_status.flags = CC_NOT_NEGATIVE;
  return "bftst %0{%b2:%b1}";
}
}

char *
output_163 (operands, insn)
     rtx *operands;
     rtx insn;
{

  cc_status = cc_prev_status;
  if (cc_status.flags & CC_Z_IN_NOT_N)
    return "spl %0";
  OUTPUT_JUMP ("seq %0", "fseq %0", "seq %0");

}

char *
output_164 (operands, insn)
     rtx *operands;
     rtx insn;
{

  cc_status = cc_prev_status;
  if (cc_status.flags & CC_Z_IN_NOT_N)
    return "smi %0";
  OUTPUT_JUMP ("sne %0", "fsne %0", "sne %0");

}

char *
output_165 (operands, insn)
     rtx *operands;
     rtx insn;
{

  cc_status = cc_prev_status;
  OUTPUT_JUMP ("sgt %0", "fsgt %0", "and%.b %#0xc,%!\n\tsgt %0");

}

char *
output_166 (operands, insn)
     rtx *operands;
     rtx insn;
{
 cc_status = cc_prev_status;
     return "shi %0"; 
}

char *
output_167 (operands, insn)
     rtx *operands;
     rtx insn;
{
 cc_status = cc_prev_status;
     OUTPUT_JUMP ("slt %0", "fslt %0", "smi %0"); 
}

char *
output_168 (operands, insn)
     rtx *operands;
     rtx insn;
{
 cc_status = cc_prev_status;
     return "scs %0"; 
}

char *
output_169 (operands, insn)
     rtx *operands;
     rtx insn;
{
 cc_status = cc_prev_status;
     OUTPUT_JUMP ("sge %0", "fsge %0", "spl %0"); 
}

char *
output_170 (operands, insn)
     rtx *operands;
     rtx insn;
{
 cc_status = cc_prev_status;
     return "scc %0"; 
}

char *
output_171 (operands, insn)
     rtx *operands;
     rtx insn;
{

  cc_status = cc_prev_status;
  OUTPUT_JUMP ("sle %0", "fsle %0", "and%.b %#0xc,%!\n\tsle %0");

}

char *
output_172 (operands, insn)
     rtx *operands;
     rtx insn;
{
 cc_status = cc_prev_status;
     return "sls %0"; 
}

char *
output_173 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (cc_status.flags & CC_Z_IN_NOT_N)
#ifdef MOTOROLA
    return "jbpl %l0";
#else
    return "jpl %l0";
#endif
#ifdef MOTOROLA
  OUTPUT_JUMP ("jbeq %l0", "fbeq %l0", "jbeq %l0");
#else
  OUTPUT_JUMP ("jeq %l0", "fjeq %l0", "jeq %l0");
#endif
}
}

char *
output_174 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (cc_status.flags & CC_Z_IN_NOT_N)
#ifdef MOTOROLA
    return "jbmi %l0";
#else
    return "jmi %l0";
#endif
#ifdef MOTOROLA
  OUTPUT_JUMP ("jbne %l0", "fbne %l0", "jbne %l0");
#else
  OUTPUT_JUMP ("jne %l0", "fjne %l0", "jne %l0");
#endif
}
}

char *
output_175 (operands, insn)
     rtx *operands;
     rtx insn;
{

#ifdef MOTOROLA
  OUTPUT_JUMP ("jbgt %l0", "fbgt %l0", "and%.b %#0xc,%!\n\tjbgt %l0");
#else
  OUTPUT_JUMP ("jgt %l0", "fjgt %l0", "andb %#0xc,%!\n\tjgt %l0");
#endif

}

char *
output_176 (operands, insn)
     rtx *operands;
     rtx insn;
{

#ifdef MOTOROLA
  return "jbhi %l0";
#else
  return "jhi %l0";
#endif

}

char *
output_177 (operands, insn)
     rtx *operands;
     rtx insn;
{

#ifdef MOTOROLA
  OUTPUT_JUMP ("jblt %l0", "fblt %l0", "jbmi %l0");
#else
  OUTPUT_JUMP ("jlt %l0", "fjlt %l0", "jmi %l0");
#endif

}

char *
output_178 (operands, insn)
     rtx *operands;
     rtx insn;
{

#ifdef MOTOROLA
  return "jbcs %l0";
#else
  return "jcs %l0";
#endif

}

char *
output_179 (operands, insn)
     rtx *operands;
     rtx insn;
{

#ifdef MOTOROLA
  OUTPUT_JUMP ("jbge %l0", "fbge %l0", "jbpl %l0");
#else
  OUTPUT_JUMP ("jge %l0", "fjge %l0", "jpl %l0");
#endif

}

char *
output_180 (operands, insn)
     rtx *operands;
     rtx insn;
{

#ifdef MOTOROLA
  return "jbcc %l0";
#else
  return "jcc %l0";
#endif

}

char *
output_181 (operands, insn)
     rtx *operands;
     rtx insn;
{

#ifdef MOTOROLA
  OUTPUT_JUMP ("jble %l0", "fble %l0", "and%.b %#0xc,%!\n\tjble %l0");
#else
  OUTPUT_JUMP ("jle %l0", "fjle %l0", "and%.b %#0xc,%!\n\tjle %l0");
#endif

}

char *
output_182 (operands, insn)
     rtx *operands;
     rtx insn;
{

#ifdef MOTOROLA
  return "jbls %l0";
#else
  return "jls %l0";
#endif

}

char *
output_183 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (cc_status.flags & CC_Z_IN_NOT_N)
#ifdef MOTOROLA
    return "jbmi %l0";
#else
    return "jmi %l0";
#endif
#ifdef MOTOROLA
  OUTPUT_JUMP ("jbne %l0", "fbne %l0", "jbne %l0");
#else
  OUTPUT_JUMP ("jne %l0", "fjne %l0", "jne %l0");
#endif
}
}

char *
output_184 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (cc_status.flags & CC_Z_IN_NOT_N)
#ifdef MOTOROLA
    return "jbpl %l0";
#else
    return "jpl %l0";
#endif
#ifdef MOTOROLA
  OUTPUT_JUMP ("jbeq %l0", "fbeq %l0", "jbeq %l0");
#else
  OUTPUT_JUMP ("jeq %l0", "fjeq %l0", "jeq %l0");
#endif
}
}

char *
output_185 (operands, insn)
     rtx *operands;
     rtx insn;
{

#ifdef MOTOROLA
  OUTPUT_JUMP ("jble %l0", "fbngt %l0", "and%.b %#0xc,%!\n\tjble %l0");
#else
  OUTPUT_JUMP ("jle %l0", "fjngt %l0", "and%.b %#0xc,%!\n\tjle %l0");
#endif

}

char *
output_186 (operands, insn)
     rtx *operands;
     rtx insn;
{

#ifdef MOTOROLA
  return "jbls %l0";
#else
  return "jls %l0";
#endif

}

char *
output_187 (operands, insn)
     rtx *operands;
     rtx insn;
{

#ifdef MOTOROLA
  OUTPUT_JUMP ("jbge %l0", "fbnlt %l0", "jbpl %l0");
#else
  OUTPUT_JUMP ("jge %l0", "fjnlt %l0", "jpl %l0");
#endif

}

char *
output_188 (operands, insn)
     rtx *operands;
     rtx insn;
{

#ifdef MOTOROLA
  return "jbcc %l0";
#else
  return "jcc %l0";
#endif

}

char *
output_189 (operands, insn)
     rtx *operands;
     rtx insn;
{

#ifdef MOTOROLA
  OUTPUT_JUMP ("jblt %l0", "fbnge %l0", "jbmi %l0");
#else
  OUTPUT_JUMP ("jlt %l0", "fjnge %l0", "jmi %l0");
#endif

}

char *
output_190 (operands, insn)
     rtx *operands;
     rtx insn;
{

#ifdef MOTOROLA
  return "jbcs %l0";
#else
  return "jcs %l0";
#endif

}

char *
output_191 (operands, insn)
     rtx *operands;
     rtx insn;
{

#ifdef MOTOROLA
  OUTPUT_JUMP ("jbgt %l0", "fbnle %l0", "and%.b %#0xc,%!\n\tjbgt %l0");
#else
  OUTPUT_JUMP ("jgt %l0", "fjnle %l0", "and%.b %#0xc,%!\n\tjgt %l0");
#endif

}

char *
output_192 (operands, insn)
     rtx *operands;
     rtx insn;
{

#ifdef MOTOROLA
  return "jbhi %l0";
#else
  return "jhi %l0";
#endif

}

char *
output_196 (operands, insn)
     rtx *operands;
     rtx insn;
{

#ifdef SGS
#ifdef ASM_OUTPUT_CASE_LABEL
  return "jmp 6(%%pc,%0.w)";
#else
  return "jmp 2(%%pc,%0.w)";
#endif
#else
#ifdef MOTOROLA
  return "jmp (2,pc,%0.w)";
#else
  return "jmp pc@(2,%0:w)";
#endif
#endif

}

char *
output_197 (operands, insn)
     rtx *operands;
     rtx insn;
{

#ifdef MOTOROLA
  return "jbra %l0";
#else
  return "jra %l0";
#endif

}

char *
output_198 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  if (DATA_REG_P (operands[0]))
    return "dbra %0,%l1";
  if (GET_CODE (operands[0]) == MEM)
    {
#ifdef MOTOROLA
      return "subq%.w %#1,%0\n\tjbcc %l1";
#else
      return "subqw %#1,%0\n\tjcc %l1";
#endif
    }
#ifdef MOTOROLA
#ifdef HPUX_ASM
  return "subq%.w %#1,%0\n\tcmp%.w %0,%#-1\n\tjbne %l1";
#else
  return "subq%.w %#1,%0\n\tcmp%.w %#-1,%0\n\tjbne %l1";
#endif
#else
  return "subqw %#1,%0\n\tcmpw %#-1,%0\n\tjne %l1";
#endif
}
}

char *
output_199 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
#ifdef MOTOROLA
  if (DATA_REG_P (operands[0]))
    return "dbra %0,%l1\n\tclr.w %0\n\tsubq.l %#1,%0\n\tjbcc %l1";
  if (GET_CODE (operands[0]) == MEM)
    return "subq.l %#1,%0\n\tjbcc %l1";
#ifdef HPUX_ASM
  return "subq.l %#1,%0\n\tcmp.l %0,%#-1\n\tjbne %l1";
#else
  return "subq.l %#1,%0\n\tcmp.l %#-1,%0\n\tjbne %l1";
#endif
#else
  if (DATA_REG_P (operands[0]))
    return "dbra %0,%l1\n\tclrw %0\n\tsubql %#1,%0\n\tjcc %l1";
  if (GET_CODE (operands[0]) == MEM)
    return "subql %#1,%0\n\tjcc %l1";
  return "subql %#1,%0\n\tcmpl %#-1,%0\n\tjne %l1";
#endif
}
}

char *
output_200 (operands, insn)
     rtx *operands;
     rtx insn;
{

#ifdef MOTOROLA
  return "jsr %0";
#else
  return "jbsr %0";
#endif

}

char *
output_201 (operands, insn)
     rtx *operands;
     rtx insn;
{

#ifdef MOTOROLA
  return "jsr %1";
#else
  return "jbsr %1";
#endif

}

char *
output_203 (operands, insn)
     rtx *operands;
     rtx insn;
{

{
  rtx xoperands[2];
  xoperands[1] = gen_rtx (REG, SImode, REGNO (operands[1]) + 1);
  output_asm_insn ("move%.l %1,%s", xoperands);
  output_asm_insn ("move%.l %1,%-", operands);
  return "fmove%.d %+,%0";
}

}

char *insn_template[] =
  {
    0,
    0,
    0,
    0,
    "tst%.b %0",
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    "exg %1,%0",
    0,
    "pea %a1",
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    "pea %a1",
    "lea %a1,%0",
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    "ext%.w %0",
    "extb%.l %0",
    0,
    "fmove%.s %f1,%0",
    "fmove%.l %1,%0",
    "fmove%.l %1,%0",
    "fmove%.w %1,%0",
    "fmove%.w %1,%0",
    "fmove%.b %1,%0",
    "fmove%.b %1,%0",
    0,
    0,
    "fmove%.b %1,%0",
    "fmove%.w %1,%0",
    "fmove%.l %1,%0",
    "fmove%.b %1,%0",
    "fmove%.w %1,%0",
    "fmove%.l %1,%0",
    0,
    "add%.w %2,%0",
    0,
    "add%.w %1,%0",
    0,
    "add%.b %1,%0",
    0,
    0,
    0,
    "sub%.w %2,%0",
    "sub%.w %2,%0",
    "sub%.w %1,%0",
    "sub%.b %2,%0",
    "sub%.b %1,%0",
    0,
    0,
    0,
    0,
    "muls%.l %2,%0",
    0,
    0,
    "mulu%.l %2,%0",
    0,
    0,
    0,
    0,
    "divs%.l %2,%0",
    0,
    0,
    "divu%.l %2,%0",
    0,
    0,
    0,
    0,
    0,
    0,
    "divsl%.l %2,%3:%0",
    "divul%.l %2,%3:%0",
    0,
    "and%.w %2,%0",
    "and%.b %2,%0",
    "and%.w %1,%0",
    "and%.b %1,%0",
    0,
    "or%.w %2,%0",
    "or%.b %2,%0",
    0,
    "eor%.w %2,%0",
    "eor%.b %2,%0",
    "neg%.l %0",
    "neg%.w %0",
    "neg%.b %0",
    0,
    0,
    0,
    0,
    "not%.l %0",
    "not%.w %0",
    "not%.b %0",
    0,
    0,
    0,
    0,
    0,
    0,
    "asl%.l %2,%0",
    "asl%.w %2,%0",
    "asl%.b %2,%0",
    "asr%.l %2,%0",
    "asr%.w %2,%0",
    "asr%.b %2,%0",
    "lsl%.l %2,%0",
    "lsl%.w %2,%0",
    "lsl%.b %2,%0",
    "lsr%.l %2,%0",
    "lsr%.w %2,%0",
    "lsr%.b %2,%0",
    "rol%.l %2,%0",
    "rol%.w %2,%0",
    "rol%.b %2,%0",
    "ror%.l %2,%0",
    "ror%.w %2,%0",
    "ror%.b %2,%0",
    0,
    0,
    0,
    "bfexts %1{%b3:%b2},%0",
    "bfextu %1{%b3:%b2},%0",
    "bfchg %0{%b2:%b1}",
    "bfclr %0{%b2:%b1}",
    "bfset %0{%b2:%b1}",
    "bfins %3,%0{%b2:%b1}",
    "bfexts %1{%b3:%b2},%0",
    "bfextu %1{%b3:%b2},%0",
    "bfclr %0{%b2:%b1}",
    "bfset %0{%b2:%b1}",
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    "rts",
    0,
  };

char *(*insn_outfun[])() =
  {
    output_0,    output_1,    output_2,    output_3,    0,
    output_5,    output_6,    output_7,    output_8,    output_9,    output_10,    output_11,    output_12,    output_13,    output_14,    output_15,    output_16,    output_17,    output_18,    output_19,    output_20,    output_21,    0,
    output_23,    0,
    output_25,    output_26,    output_27,    output_28,    output_29,    output_30,    output_31,    output_32,    0,
    0,
    output_35,    output_36,    output_37,    0,
    0,
    0,
    output_41,    0,
    0,
    output_44,    0,
    0,
    0,
    0,
    0,
    0,
    0,
    output_52,    output_53,    0,
    0,
    0,
    0,
    0,
    0,
    output_60,    0,
    output_62,    0,
    output_64,    0,
    output_66,    output_67,    output_68,    0,
    0,
    0,
    0,
    0,
    output_74,    output_75,    output_76,    output_77,    0,
    output_79,    output_80,    0,
    output_82,    output_83,    output_84,    output_85,    0,
    output_87,    output_88,    0,
    output_90,    output_91,    output_92,    output_93,    output_94,    output_95,    0,
    0,
    output_98,    0,
    0,
    0,
    0,
    output_103,    0,
    0,
    output_106,    0,
    0,
    0,
    0,
    0,
    output_112,    output_113,    output_114,    output_115,    0,
    0,
    0,
    output_119,    output_120,    output_121,    output_122,    output_123,    output_124,    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    output_143,    output_144,    output_145,    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    output_156,    output_157,    output_158,    output_159,    output_160,    output_161,    output_162,    output_163,    output_164,    output_165,    output_166,    output_167,    output_168,    output_169,    output_170,    output_171,    output_172,    output_173,    output_174,    output_175,    output_176,    output_177,    output_178,    output_179,    output_180,    output_181,    output_182,    output_183,    output_184,    output_185,    output_186,    output_187,    output_188,    output_189,    output_190,    output_191,    output_192,    0,
    0,
    0,
    output_196,    output_197,    output_198,    output_199,    output_200,    output_201,    0,
    output_203,  };

rtx (*insn_gen_function[]) () =
  {
    0,
    0,
    gen_tstsi,
    gen_tsthi,
    gen_tstqi,
    gen_tstsf,
    gen_tstdf,
    gen_cmpsi,
    gen_cmphi,
    0,
    gen_cmpqi,
    gen_cmpdf,
    gen_cmpsf,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    gen_swapsi,
    0,
    0,
    gen_movsi,
    gen_movhi,
    gen_movstricthi,
    gen_movqi,
    gen_movstrictqi,
    gen_movsf,
    gen_movdf,
    gen_movdi,
    gen_pushasi,
    0,
    gen_truncsiqi2,
    gen_trunchiqi2,
    gen_truncsihi2,
    gen_zero_extendhisi2,
    gen_zero_extendqihi2,
    gen_zero_extendqisi2,
    gen_extendhisi2,
    gen_extendqihi2,
    gen_extendqisi2,
    gen_extendsfdf2,
    gen_truncdfsf2,
    gen_floatsisf2,
    gen_floatsidf2,
    gen_floathisf2,
    gen_floathidf2,
    gen_floatqisf2,
    gen_floatqidf2,
    gen_ftruncdf2,
    gen_ftruncsf2,
    gen_fixsfqi2,
    gen_fixsfhi2,
    gen_fixsfsi2,
    gen_fixdfqi2,
    gen_fixdfhi2,
    gen_fixdfsi2,
    gen_addsi3,
    0,
    gen_addhi3,
    0,
    gen_addqi3,
    0,
    gen_adddf3,
    gen_addsf3,
    gen_subsi3,
    0,
    gen_subhi3,
    0,
    gen_subqi3,
    0,
    gen_subdf3,
    gen_subsf3,
    gen_mulhi3,
    gen_mulhisi3,
    gen_mulsi3,
    gen_umulhi3,
    gen_umulhisi3,
    gen_umulsi3,
    gen_muldf3,
    gen_mulsf3,
    gen_divhi3,
    gen_divhisi3,
    gen_divsi3,
    gen_udivhi3,
    gen_udivhisi3,
    gen_udivsi3,
    gen_divdf3,
    gen_divsf3,
    gen_modhi3,
    gen_modhisi3,
    gen_umodhi3,
    gen_umodhisi3,
    gen_divmodsi4,
    gen_udivmodsi4,
    gen_andsi3,
    gen_andhi3,
    gen_andqi3,
    0,
    0,
    gen_iorsi3,
    gen_iorhi3,
    gen_iorqi3,
    gen_xorsi3,
    gen_xorhi3,
    gen_xorqi3,
    gen_negsi2,
    gen_neghi2,
    gen_negqi2,
    gen_negsf2,
    gen_negdf2,
    gen_abssf2,
    gen_absdf2,
    gen_one_cmplsi2,
    gen_one_cmplhi2,
    gen_one_cmplqi2,
    0,
    0,
    0,
    0,
    0,
    0,
    gen_ashlsi3,
    gen_ashlhi3,
    gen_ashlqi3,
    gen_ashrsi3,
    gen_ashrhi3,
    gen_ashrqi3,
    gen_lshlsi3,
    gen_lshlhi3,
    gen_lshlqi3,
    gen_lshrsi3,
    gen_lshrhi3,
    gen_lshrqi3,
    gen_rotlsi3,
    gen_rotlhi3,
    gen_rotlqi3,
    gen_rotrsi3,
    gen_rotrhi3,
    gen_rotrqi3,
    0,
    0,
    0,
    gen_extv,
    gen_extzv,
    0,
    0,
    0,
    gen_insv,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    gen_seq,
    gen_sne,
    gen_sgt,
    gen_sgtu,
    gen_slt,
    gen_sltu,
    gen_sge,
    gen_sgeu,
    gen_sle,
    gen_sleu,
    gen_beq,
    gen_bne,
    gen_bgt,
    gen_bgtu,
    gen_blt,
    gen_bltu,
    gen_bge,
    gen_bgeu,
    gen_ble,
    gen_bleu,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    gen_casesi_1,
    gen_casesi_2,
    gen_casesi,
    0,
    gen_jump,
    0,
    0,
    gen_call,
    gen_call_value,
    gen_return,
    0,
  };

int insn_n_operands[] =
  {
    2,
    2,
    1,
    1,
    1,
    1,
    1,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    1,
    2,
    2,
    1,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    3,
    3,
    3,
    2,
    3,
    2,
    3,
    3,
    3,
    3,
    3,
    2,
    3,
    2,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    4,
    4,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    2,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    3,
    4,
    4,
    4,
    4,
    4,
    4,
    3,
    3,
    4,
    4,
    4,
    3,
    3,
    4,
    3,
    3,
    3,
    3,
    3,
    3,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    1,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    4,
    2,
    5,
    1,
    0,
    1,
    1,
    2,
    3,
    0,
    2,
  };

int insn_n_dups[] =
  {
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    2,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    1,
    0,
    1,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    2,
    2,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    3,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    2,
    2,
    0,
    0,
    0,
    0,
  };

char *insn_operand_constraint[][MAX_RECOG_OPERANDS] =
  {
    { "=m", "ro<>fF", },
    { "=m", "ro<>", },
    { "rm", },
    { "rm", },
    { "dm", },
    { "fdm", },
    { "fm", },
    { "rKs,mr", "mr,Ksr", },
    { "rn,mr", "mr,nr", },
    { "+a", "+a", },
    { "dn,md", "dm,nd", },
    { "f,mG", "fmG,f", },
    { "f,mdG", "fmdG,f", },
    { "do", "di", },
    { "d", "di", },
    { "do", "d", },
    { "d", "d", },
    { "o,d", "i,i", },
    { "o,d", "i,i", },
    { "do", "i", },
    { "dm", },
    { "dm", "i", },
    { "r", "r", },
    { "=g", },
    { "=m", "J", },
    { "=g,da", "damKs,i", },
    { "=g", "g", },
    { "+dm", "rmn", },
    { "=d,a,m", "g,d,dmi", },
    { "+dm", "dmn", },
    { "=rmf", "rmfF", },
    { "=rm,&rf,&rof<>", "rf,m,rofF<>", },
    { "=rm,&rf,&ro<>,!&rm,!&f", "r,m,roi<>,fF,rfF", },
    { "=m", "p", },
    { "=a", "p", },
    { "=dm,d", "doJ,i", },
    { "=dm,d", "doJ,i", },
    { "=dm,d", "roJ,i", },
    { "", "", },
    { "", "", },
    { "", "", },
    { "=*d,a", "0,rmn", },
    { "=d", "0", },
    { "=d", "0", },
    { "=*fdm,f", "f,dmF", },
    { "=dm", "f", },
    { "=f", "dmi", },
    { "=f", "dmi", },
    { "=f", "dmn", },
    { "=f", "dmn", },
    { "=f", "dmn", },
    { "=f", "dmn", },
    { "=f", "fFm", },
    { "=f", "dfFm", },
    { "=dm", "f", },
    { "=dm", "f", },
    { "=dm", "f", },
    { "=dm", "f", },
    { "=dm", "f", },
    { "=dm", "f", },
    { "=m,r,!a", "%0,0,a", "dIKLs,mrIKLs,rJK", },
    { "=a", "0", "rmn", },
    { "=m,r", "%0,0", "dn,rmn", },
    { "+m,d", "dn,rmn", },
    { "=m,d", "%0,0", "dn,dmn", },
    { "+m,d", "dn,dmn", },
    { "=f", "%0", "fmG", },
    { "=f", "%0", "fdmF", },
    { "=m,r,!a,?d", "0,0,a,mrIKs", "dIKs,mrIKs,J,0", },
    { "=a", "0", "rmn", },
    { "=m,r", "0,0", "dn,rmn", },
    { "+m,d", "dn,rmn", },
    { "=m,d", "0,0", "dn,dmn", },
    { "+m,d", "dn,dmn", },
    { "=f", "0", "fmG", },
    { "=f", "0", "fdmF", },
    { "=d", "%0", "dmn", },
    { "=d", "%0", "dmn", },
    { "=d", "%0", "dmsK", },
    { "=d", "%0", "dmn", },
    { "=d", "%0", "dmn", },
    { "=d", "%0", "dmsK", },
    { "=f", "%0", "fmG", },
    { "=f", "%0", "fdmF", },
    { "=d", "0", "dmn", },
    { "=d", "0", "dmn", },
    { "=d", "0", "dmsK", },
    { "=d", "0", "dmn", },
    { "=d", "0", "dmn", },
    { "=d", "0", "dmsK", },
    { "=f", "0", "fmG", },
    { "=f", "0", "fdmF", },
    { "=d", "0", "dmn", },
    { "=d", "0", "dmn", },
    { "=d", "0", "dmn", },
    { "=d", "0", "dmn", },
    { "=d", "0", "dmsK", "=d", },
    { "=d", "0", "dmsK", "=d", },
    { "=m,d", "%0,0", "dKs,dmKs", },
    { "=m,d", "%0,0", "dn,dmn", },
    { "=m,d", "%0,0", "dn,dmn", },
    { "=d", "dm", "0", },
    { "=d", "dm", "0", },
    { "=m,d", "%0,0", "dKs,dmKs", },
    { "=m,d", "%0,0", "dn,dmn", },
    { "=m,d", "%0,0", "dn,dmn", },
    { "=do,m", "%0,0", "di,dKs", },
    { "=dm", "%0", "dn", },
    { "=dm", "%0", "dn", },
    { "=dm", "0", },
    { "=dm", "0", },
    { "=dm", "0", },
    { "=f", "fdmF", },
    { "=f", "fmF", },
    { "=f", "fdmF", },
    { "=f", "fmF", },
    { "=dm", "0", },
    { "=dm", "0", },
    { "=dm", "0", },
    { "=d", "m", },
    { "=d", "m", },
    { "i", "m", },
    { "m", "i", },
    { "i", "m", },
    { "m", "i", },
    { "=d", "0", "dI", },
    { "=d", "0", "dI", },
    { "=d", "0", "dI", },
    { "=d", "0", "dI", },
    { "=d", "0", "dI", },
    { "=d", "0", "dI", },
    { "=d", "0", "dI", },
    { "=d", "0", "dI", },
    { "=d", "0", "dI", },
    { "=d", "0", "dI", },
    { "=d", "0", "dI", },
    { "=d", "0", "dI", },
    { "=d", "0", "dI", },
    { "=d", "0", "dI", },
    { "=d", "0", "dI", },
    { "=d", "0", "dI", },
    { "=d", "0", "dI", },
    { "=d", "0", "dI", },
    { "+do", "i", "i", "d", },
    { "=&d", "do", "i", "i", },
    { "=d", "do", "i", "i", },
    { "=d,d", "o,d", "di,di", "di,di", },
    { "=d,d", "o,d", "di,di", "di,di", },
    { "+o,d", "di,di", "di,di", "i", },
    { "+o,d", "di,di", "di,di", },
    { "+o,d", "di,di", "di,di", },
    { "+o,d", "di,di", "di,di", "d", },
    { "=d", "d", "di", "di", },
    { "=d", "d", "di", "di", },
    { "+d", "di", "di", },
    { "+d", "di", "di", },
    { "+d", "di", "di", "d", },
    { "o", "di", "di", },
    { "o", "di", "di", },
    { "o", "di", "di", },
    { "d", "di", "di", },
    { "d", "di", "di", },
    { "d", "di", "di", },
    { "=d", },
    { "=d", },
    { "=d", },
    { "=d", },
    { "=d", },
    { "=d", },
    { "=d", },
    { "=d", },
    { "=d", },
    { "=d", },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { "", "", "", "", },
    { "", "", },
    { "", "", "", "", "", },
    { "r", },
    { 0 },
    { "g", },
    { "g", },
    { "m", "g", },
    { "rf", "m", "g", },
    { 0 },
    { "f", "ad", },
  };

enum machine_mode insn_operand_mode[][MAX_RECOG_OPERANDS] =
  {
    { DFmode, DFmode, },
    { DImode, DImode, },
    { SImode, },
    { HImode, },
    { QImode, },
    { SFmode, },
    { DFmode, },
    { SImode, SImode, },
    { HImode, HImode, },
    { SImode, SImode, },
    { QImode, QImode, },
    { DFmode, DFmode, },
    { SFmode, SFmode, },
    { QImode, SImode, },
    { SImode, SImode, },
    { QImode, SImode, },
    { SImode, SImode, },
    { QImode, SImode, },
    { HImode, SImode, },
    { SImode, SImode, },
    { QImode, },
    { QImode, SImode, },
    { SImode, SImode, },
    { SImode, },
    { SImode, SImode, },
    { SImode, SImode, },
    { HImode, HImode, },
    { HImode, HImode, },
    { QImode, QImode, },
    { QImode, QImode, },
    { SFmode, SFmode, },
    { DFmode, DFmode, },
    { DImode, DImode, },
    { SImode, SImode, },
    { SImode, QImode, },
    { QImode, SImode, },
    { QImode, HImode, },
    { HImode, SImode, },
    { SImode, HImode, },
    { HImode, QImode, },
    { SImode, QImode, },
    { SImode, HImode, },
    { HImode, QImode, },
    { SImode, QImode, },
    { DFmode, SFmode, },
    { SFmode, DFmode, },
    { SFmode, SImode, },
    { DFmode, SImode, },
    { SFmode, HImode, },
    { DFmode, HImode, },
    { SFmode, QImode, },
    { DFmode, QImode, },
    { DFmode, DFmode, },
    { SFmode, SFmode, },
    { QImode, SFmode, },
    { HImode, SFmode, },
    { SImode, SFmode, },
    { QImode, DFmode, },
    { HImode, DFmode, },
    { SImode, DFmode, },
    { SImode, SImode, SImode, },
    { SImode, SImode, HImode, },
    { HImode, HImode, HImode, },
    { HImode, HImode, },
    { QImode, QImode, QImode, },
    { QImode, QImode, },
    { DFmode, DFmode, DFmode, },
    { SFmode, SFmode, SFmode, },
    { SImode, SImode, SImode, },
    { SImode, SImode, HImode, },
    { HImode, HImode, HImode, },
    { HImode, HImode, },
    { QImode, QImode, QImode, },
    { QImode, QImode, },
    { DFmode, DFmode, DFmode, },
    { SFmode, SFmode, SFmode, },
    { HImode, HImode, HImode, },
    { SImode, HImode, HImode, },
    { SImode, SImode, SImode, },
    { HImode, HImode, HImode, },
    { SImode, HImode, HImode, },
    { SImode, SImode, SImode, },
    { DFmode, DFmode, DFmode, },
    { SFmode, SFmode, SFmode, },
    { HImode, HImode, HImode, },
    { HImode, SImode, HImode, },
    { SImode, SImode, SImode, },
    { HImode, HImode, HImode, },
    { HImode, SImode, HImode, },
    { SImode, SImode, SImode, },
    { DFmode, DFmode, DFmode, },
    { SFmode, SFmode, SFmode, },
    { HImode, HImode, HImode, },
    { HImode, SImode, HImode, },
    { HImode, HImode, HImode, },
    { HImode, SImode, HImode, },
    { SImode, SImode, SImode, SImode, },
    { SImode, SImode, SImode, SImode, },
    { SImode, SImode, SImode, },
    { HImode, HImode, HImode, },
    { QImode, QImode, QImode, },
    { SImode, HImode, SImode, },
    { SImode, QImode, SImode, },
    { SImode, SImode, SImode, },
    { HImode, HImode, HImode, },
    { QImode, QImode, QImode, },
    { SImode, SImode, SImode, },
    { HImode, HImode, HImode, },
    { QImode, QImode, QImode, },
    { SImode, SImode, },
    { HImode, HImode, },
    { QImode, QImode, },
    { SFmode, SFmode, },
    { DFmode, DFmode, },
    { SFmode, SFmode, },
    { DFmode, DFmode, },
    { SImode, SImode, },
    { HImode, HImode, },
    { QImode, QImode, },
    { SImode, SImode, },
    { SImode, SImode, },
    { QImode, SImode, },
    { SImode, QImode, },
    { QImode, SImode, },
    { SImode, QImode, },
    { SImode, SImode, SImode, },
    { HImode, HImode, HImode, },
    { QImode, QImode, QImode, },
    { SImode, SImode, SImode, },
    { HImode, HImode, HImode, },
    { QImode, QImode, QImode, },
    { SImode, SImode, SImode, },
    { HImode, HImode, HImode, },
    { QImode, QImode, QImode, },
    { SImode, SImode, SImode, },
    { HImode, HImode, HImode, },
    { QImode, QImode, QImode, },
    { SImode, SImode, SImode, },
    { HImode, HImode, HImode, },
    { QImode, QImode, QImode, },
    { SImode, SImode, SImode, },
    { HImode, HImode, HImode, },
    { QImode, QImode, QImode, },
    { SImode, SImode, SImode, SImode, },
    { SImode, SImode, SImode, SImode, },
    { SImode, SImode, SImode, SImode, },
    { SImode, QImode, SImode, SImode, },
    { SImode, QImode, SImode, SImode, },
    { QImode, SImode, SImode, VOIDmode, },
    { QImode, SImode, SImode, },
    { QImode, SImode, SImode, },
    { QImode, SImode, SImode, SImode, },
    { SImode, SImode, SImode, SImode, },
    { SImode, SImode, SImode, SImode, },
    { SImode, SImode, SImode, },
    { SImode, SImode, SImode, },
    { SImode, SImode, SImode, SImode, },
    { QImode, SImode, SImode, },
    { QImode, SImode, SImode, },
    { QImode, SImode, SImode, },
    { SImode, SImode, SImode, },
    { SImode, SImode, SImode, },
    { SImode, SImode, SImode, },
    { QImode, },
    { QImode, },
    { QImode, },
    { QImode, },
    { QImode, },
    { QImode, },
    { QImode, },
    { QImode, },
    { QImode, },
    { QImode, },
    { VOIDmode },
    { VOIDmode },
    { VOIDmode },
    { VOIDmode },
    { VOIDmode },
    { VOIDmode },
    { VOIDmode },
    { VOIDmode },
    { VOIDmode },
    { VOIDmode },
    { VOIDmode },
    { VOIDmode },
    { VOIDmode },
    { VOIDmode },
    { VOIDmode },
    { VOIDmode },
    { VOIDmode },
    { VOIDmode },
    { VOIDmode },
    { VOIDmode },
    { SImode, SImode, SImode, SImode, },
    { SImode, SImode, },
    { SImode, SImode, SImode, VOIDmode, VOIDmode, },
    { HImode, },
    { VOIDmode },
    { HImode, },
    { SImode, },
    { QImode, SImode, },
    { VOIDmode, QImode, SImode, },
    { VOIDmode },
    { VOIDmode, VOIDmode, },
  };

char insn_operand_strict_low[][MAX_RECOG_OPERANDS] =
  {
    { 0, 0, },
    { 0, 0, },
    { 0, },
    { 0, },
    { 0, },
    { 0, },
    { 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 1, 0, },
    { 0, 0, },
    { 1, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 1, 0, },
    { 0, 0, 0, },
    { 1, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 1, 0, },
    { 0, 0, 0, },
    { 1, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, 0, },
    { 0, 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, 0, },
    { 0, 0, 0, 0, },
    { 0, 0, 0, 0, },
    { 0, 0, 0, 0, },
    { 0, 0, 0, 0, },
    { 0, 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, 0, },
    { 0, 0, 0, 0, },
    { 0, 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, 0, 0, },
    { 0, },
    { 0, },
    { 0, },
    { 0, },
    { 0, },
    { 0, },
    { 0, },
    { 0, },
    { 0, },
    { 0, },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0, 0, 0, 0, },
    { 0, 0, },
    { 0, 0, 0, 0, 0, },
    { 0, },
    { 0 },
    { 0, },
    { 0, },
    { 0, 0, },
    { 0, 0, 0, },
    { 0 },
    { 0, 0, },
  };

int (*insn_operand_predicate[][MAX_RECOG_OPERANDS])() =
  {
    { push_operand, general_operand, },
    { push_operand, general_operand, },
    { general_operand, },
    { general_operand, },
    { general_operand, },
    { general_operand, },
    { general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { nonimmediate_operand, general_operand, },
    { nonimmediate_operand, general_operand, },
    { nonimmediate_operand, general_operand, },
    { nonimmediate_operand, general_operand, },
    { nonimmediate_operand, general_operand, },
    { nonimmediate_operand, general_operand, },
    { nonimmediate_operand, general_operand, },
    { nonimmediate_operand, },
    { nonimmediate_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, },
    { push_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { push_operand, address_operand, },
    { general_operand, address_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, general_operand, },
    { general_operand, memory_operand, },
    { general_operand, memory_operand, },
    { general_operand, memory_operand, },
    { memory_operand, general_operand, },
    { general_operand, memory_operand, },
    { memory_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { general_operand, general_operand, general_operand, },
    { nonimmediate_operand, immediate_operand, immediate_operand, general_operand, },
    { general_operand, nonimmediate_operand, immediate_operand, immediate_operand, },
    { general_operand, nonimmediate_operand, immediate_operand, immediate_operand, },
    { general_operand, nonimmediate_operand, general_operand, general_operand, },
    { general_operand, nonimmediate_operand, general_operand, general_operand, },
    { nonimmediate_operand, general_operand, general_operand, immediate_operand, },
    { nonimmediate_operand, general_operand, general_operand, },
    { nonimmediate_operand, general_operand, general_operand, },
    { nonimmediate_operand, general_operand, general_operand, general_operand, },
    { general_operand, nonimmediate_operand, general_operand, general_operand, },
    { general_operand, nonimmediate_operand, general_operand, general_operand, },
    { nonimmediate_operand, general_operand, general_operand, },
    { nonimmediate_operand, general_operand, general_operand, },
    { nonimmediate_operand, general_operand, general_operand, general_operand, },
    { memory_operand, general_operand, general_operand, },
    { memory_operand, general_operand, general_operand, },
    { memory_operand, general_operand, general_operand, },
    { nonimmediate_operand, general_operand, general_operand, },
    { nonimmediate_operand, general_operand, general_operand, },
    { nonimmediate_operand, general_operand, general_operand, },
    { general_operand, },
    { general_operand, },
    { general_operand, },
    { general_operand, },
    { general_operand, },
    { general_operand, },
    { general_operand, },
    { general_operand, },
    { general_operand, },
    { general_operand, },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { 0 },
    { general_operand, immediate_operand, general_operand, general_operand, },
    { 0, 0, },
    { general_operand, immediate_operand, general_operand, 0, 0, },
    { general_operand, },
    { 0 },
    { general_operand, },
    { general_operand, },
    { general_operand, general_operand, },
    { 0, general_operand, general_operand, },
    { 0 },
    { 0, 0, },
  };
