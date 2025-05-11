/* Generated automatically by the program `genpeep'
from the machine description file `md'.  */

#include "rtl.h"

#include "config.h"

#include "regs.h"

extern rtx peep_operand[];

#define operands peep_operand

int
peephole (ins1)
     rtx ins1;
{
  rtx insn, x, pat;
  int i;
  insn = ins1;
  if (GET_CODE (insn) == CODE_LABEL) goto L203;
  pat = PATTERN (insn);
  x = pat;
  if (GET_CODE (x) != SET) goto L203;
  x = XEXP (pat, 0);
  if (GET_CODE (x) != REG) goto L203;
  if (GET_MODE (x) != SImode) goto L203;
  if (XINT (x, 0) != 15) goto L203;
  x = XEXP (pat, 1);
  if (GET_CODE (x) != PLUS) goto L203;
  if (GET_MODE (x) != SImode) goto L203;
  x = XEXP (XEXP (pat, 1), 0);
  if (GET_CODE (x) != REG) goto L203;
  if (GET_MODE (x) != SImode) goto L203;
  if (XINT (x, 0) != 15) goto L203;
  x = XEXP (XEXP (pat, 1), 1);
  if (GET_CODE (x) != CONST_INT) goto L203;
  if (XINT (x, 0) != 4) goto L203;
  do { insn = NEXT_INSN (insn);
       if (insn == 0) goto L203; }
  while (GET_CODE (insn) == NOTE);
  if (GET_CODE (insn) == CODE_LABEL) goto L203;
  pat = PATTERN (insn);
  x = pat;
  if (GET_CODE (x) != SET) goto L203;
  x = XEXP (pat, 0);
  operands[0] = x;
  if (! register_operand (x, DFmode)) goto L203;
  x = XEXP (pat, 1);
  operands[1] = x;
  if (! register_operand (x, DFmode)) goto L203;
  if (! (FP_REG_P (operands[0]) && ! FP_REG_P (operands[1]))) goto L203;
  PATTERN (ins1) = gen_rtx (PARALLEL, VOIDmode, gen_rtvec_v (2, operands));
  insn = ins1;
  for (i = 0; i < 2; i++)
    if (GET_CODE (operands[i]) == CODE_LABEL)
      LABEL_NUSES (operands[i])++;
  INSN_CODE (insn) = 203;
  do insn = NEXT_INSN (insn);
  while (GET_CODE (insn) == NOTE);
  delete_insn (insn);
  return 1;
 L203:

  return 0;
}

rtx peep_operand[2];
