;;  Mips.md        Naive version of Machine Description for MIPS
;;  Contributed by   A. Lichnewsky, lich@inria.inria.fr
;;  Copyright (C) 1989 Free Software Foundation, Inc.

;; This file is part of GNU CC.

;; GNU CC is free software; you can redistribute it and/or modify
;; it under the terms of the GNU General Public License as published by
;; the Free Software Foundation; either version 1, or (at your option)
;; any later version.

;; GNU CC is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.

;; You should have received a copy of the GNU General Public License
;; along with GNU CC; see the file COPYING.  If not, write to
;; the Free Software Foundation, 675 Mass Ave, Cambridge, MA 02139, USA.

;;
;;------------------------------------------------------------------------
;;

;;
;;  ....................
;;
;;  Peephole Optimizations for
;;
;;          ARITHMETIC
;;
;;  ....................
;;
					;;- The following peepholes are
					;;- motivated by the fact that
					;;- stack movement result in some
					;;- cases in embarrassing sequences
					;;- of addiu SP,SP,int
					;;-    addiu SP,SP,other_int

					;;- --------------------
					;;- REMARK: this would be done better
					;;- by analysis of dependencies in
					;;- basic blocks, prior to REG ALLOC,
					;;- and simplification of trees:
					;;-      (+  (+ REG const) const)
					;;- ->   (+ REG newconst)
					;;- --------------------
(define_peephole
  [(set (match_operand:SI 0 "general_operand" "=r")
	(plus:SI (match_operand:SI 1 "general_operand" "r")
		 (match_operand:SI 2 "general_operand" "IJ")))
   (set (match_operand:SI 3 "general_operand" "=r")
	(plus:SI (match_dup 0)
		 (match_operand:SI 4 "general_operand" "IJ")))]
  "					/* DATA FLOW SEMANTICS*/
   (((REGNO (operands[0])) == (REGNO (operands[3])))
    ||
      dead_or_set_p (insn, operands[0]))
  &&
   (                                   /* CONSTRAINTS         */
       (GET_CODE (operands[2]) == CONST_INT)
    && ((CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'I'))
        ||(CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'J')))
    &&  (GET_CODE (operands[4]) == CONST_INT)
    && ((CONST_OK_FOR_LETTER_P (INTVAL (operands[4]), 'I'))
        ||(CONST_OK_FOR_LETTER_P (INTVAL (operands[4]), 'J'))))
  "
  "*
{
  rtx ops[3];
  int i;
  i = INTVAL (operands[2]) + INTVAL (operands[4]);
  if  (i == 0)
    {
      if  ((REGNO (operands[3])) == (REGNO (operands[1])))
	{
	  if  ((REGNO (operands[0])) == (REGNO (operands[3])))
	    return \"\\t\\t# NULL %0 <- %1 + %2; %3 <- %0 + %4\";
	  else
	    return \"\\t\\t# NULL %0 <- %1 + %2; %3 <- %0 + %4 and dead %0\";
	}
      else
	return \"add%:\\t%3,%1,$0\\t# %0 <- %1 + %2; %3 <- %0 + %4 and dead %0\";
    }
  else
    {
      ops[0] = operands[3];
      ops[1] = operands[1];
      ops[2] = gen_rtx (CONST_INT, VOIDmode, i);
      output_asm_insn (\"addi%:\\t%0,%1,%2\\t# simplification of:\", ops);
      return \"\\t\\t\\t#  %0 <- %1 + %2; %3 <- %0 + %4 and dead %0\";
    }
}")




(define_peephole
  [(set (match_operand:SI 0 "general_operand" "=r")
	(plus:SI (match_operand:SI 1 "general_operand" "r")
		 (match_operand:SI 2 "general_operand" "IJ")))
   (set (match_operand:SI 3 "general_operand" "=r")
	(minus:SI (match_dup 0)
		  (match_operand:SI 4 "general_operand" "IJ")))]
  "(((REGNO (operands[0])) == (REGNO (operands[3])))
    ||
      dead_or_set_p (insn, operands[0]))
  &&
   (                                   /* CONSTRAINTS         */
       (GET_CODE (operands[2]) == CONST_INT)
    && ((CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'I'))
        ||(CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'J')))
    &&  (GET_CODE (operands[4]) == CONST_INT)
    && ((CONST_OK_FOR_LETTER_P (INTVAL (operands[4]), 'I'))
        ||(CONST_OK_FOR_LETTER_P (INTVAL (operands[4]), 'J'))))
  "
  "*
{
  rtx ops[3];
  int i;
  i = INTVAL (operands[2]) - INTVAL (operands[4]);
  if  (i == 0)
    {
      if  ((REGNO (operands[3])) == (REGNO (operands[1])))
	{
	  if  ((REGNO (operands[0])) == (REGNO (operands[3])))
	    return \"\\t\\t# NULL %0 <- %1 + %2; %3 <- %0 - %4\";
	  else
	    return \"\\t\\t# NULL %0 <- %1 + %2; %3 <- %0 - %4 and dead %0\";
	}
      else
	return \"add%:\\t%3,%1,$0\\t# %0 <- %1 + %2; %3 <- %0 - %4 and dead %0\";
    }
  else
    {
      ops[0] = operands[3];
      ops[1] = operands[1];
      ops[2] = gen_rtx (CONST_INT, VOIDmode, i);
      output_asm_insn (\"addi%:\\t%0,%1,%2\\t# simplification of:\", ops);
      return \"\\t\\t\\t#  %0 <- %1 + %2; %3 <- %0 - %4 and dead %0\";
    }
}")


(define_peephole
  [(set (match_operand:SI 0 "general_operand" "=r")
	(minus:SI (match_operand:SI 1 "general_operand" "r")
		  (match_operand:SI 2 "general_operand" "IJ")))
   (set (match_operand:SI 3 "general_operand" "=r")
	(plus:SI (match_dup 0)
		 (match_operand:SI 4 "general_operand" "IJ")))]
  "(((REGNO (operands[0])) == (REGNO (operands[3])))
    ||
      dead_or_set_p (insn, operands[0]))
  &&
   (                                   /* CONSTRAINTS         */
       (GET_CODE (operands[2]) == CONST_INT)
    && ((CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'I'))
        ||(CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'J')))
    &&  (GET_CODE (operands[4]) == CONST_INT)
    && ((CONST_OK_FOR_LETTER_P (INTVAL (operands[4]), 'I'))
        ||(CONST_OK_FOR_LETTER_P (INTVAL (operands[4]), 'J'))))
  "
  "*
{
  rtx ops[3];
  int i;
  i = (- INTVAL (operands[2])) + INTVAL (operands[4]);
  if  (i == 0)
    {
      if  ((REGNO (operands[3])) == (REGNO (operands[1])))
	{
	  if  ((REGNO (operands[0])) == (REGNO (operands[3])))
	    return \"\\t\\t# NULL %0 <- %1 - %2; %3 <- %0 + %4\";
	  else
	    return \"\\t\\t# NULL %0 <- %1 - %2; %3 <- %0 + %4 and dead %0\";
	}
      else
	return \"add%:\\t%3,%1,$0\\t# %0 <- %1 - %2; %3 <- %0 + %4 and dead %0\";
    }
  else
    {
      ops[0] = operands[3];
      ops[1] = operands[1];
      ops[2] = gen_rtx (CONST_INT, VOIDmode, i);
      output_asm_insn (\"addi%:\\t%0,%1,%2\\t# simplification of:\", ops);
      return \"\\t\\t\\t#  %0 <- %1 - %2; %3 <- %0 + %4 and dead %0\";
    }
}")




(define_peephole
  [(set (match_operand:SI 0 "general_operand" "=r")
	(minus:SI (match_operand:SI 1 "general_operand" "r")
		  (match_operand:SI 2 "general_operand" "IJ")))
   (set (match_operand:SI 3 "general_operand" "=r")
	(minus:SI (match_dup 0)
		  (match_operand:SI 4 "general_operand" "IJ")))]
  "((REGNO (operands[0]) == REGNO (operands[3])
     || dead_or_set_p (insn, operands[0]))
    &&
    (GET_CODE (operands[2]) == CONST_INT
     && (CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'I')
	 || CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'J'))
     && GET_CODE (operands[4]) == CONST_INT
     && (CONST_OK_FOR_LETTER_P (INTVAL (operands[4]), 'I')
	 || CONST_OK_FOR_LETTER_P (INTVAL (operands[4]), 'J'))))"
  "*
{
  rtx ops[3];
  int i = - (INTVAL (operands[2]) + INTVAL (operands[4]));

  if  (i == 0)
    {
      if  (REGNO (operands[3]) == REGNO (operands[1]))
	{
	  if  (REGNO (operands[0]) == REGNO (operands[3]))
	    return \"\\t\\t# NULL %0 <- %1 - %2; %3 <- %0 - %4\";
	  else
	    return \"\\t\\t# NULL %0 <- %1 - %2; %3 <- %0 - %4 and dead %0\";
	}
      else
	return \"add%:\\t%3,%1,$0\\t# %0 <- %1 - %2; %3 <- %0 - %4 and dead %0\";
    }
  else
    {
      ops[0] = operands[3];
      ops[1] = operands[1];
      ops[2] = gen_rtx (CONST_INT, VOIDmode, i);
      output_asm_insn (\"addi%:\\t%0,%1,%2\\t# simplification of:\", ops);
      return \"\\t\\t\\t#  %0 <- %1 - %2; %3 <- %0 - %4 and dead %0\";
    }
}")


;;
;;  ....................
;;
;;          ARITHMETIC
;;
;;  ....................
;;

(define_insn "adddf3"
  [(set (match_operand:DF 0 "general_operand" "=f")
	(plus:DF (match_operand:DF 1 "general_operand" "%f")
		 (match_operand:DF 2 "general_operand" "f")))]
  ""
  "add.d\\t%0,%1,%2")

(define_insn "addsf3"
  [(set (match_operand:SF 0 "general_operand" "=f")
	(plus:SF (match_operand:SF 1 "general_operand" "%f")
		 (match_operand:SF 2 "general_operand" "f")))]
  ""
  "add.s\\t%0,%1,%2")

(define_insn "addsi3"
  [(set (match_operand:SI 0 "register_operand" "=r")
	(plus:SI (match_operand:SI 1 "register_operand" "%r")
		 (match_operand:SI 2 "general_operand" "rIJ")))]
  ""
  "*
{
  if (GET_CODE (operands[2]) == CONST_INT)
    {
      if (CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'I'))
	return \"addi%:\\t%0,%1,%x2\\t#addsi3\\t%1,%d2 -> %0\";
      else  if (CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'J'))
	return \"add%:\\t%0,%1,$0\\t#addsi3\\t%1,%2 -> %0\";
      else abort_with_insn (insn, \"Constant does not fit descriptor\");
    }
  else
    return \"add%:\\t%0,%1,%2\\t#addsi3\\t%1,%2 -> %0\";
}")

(define_insn "addhi3"
  [(set (match_operand:HI 0 "general_operand" "=r")
	(plus:HI (match_operand:HI 1 "general_operand" "%r")
		 (match_operand:HI 2 "general_operand" "rIJ")))]
  ""
  "*
{
  if (GET_CODE (operands[2]) == CONST_INT)
    {
      if (CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'I'))
	return \"addi%:\\t%0,%1,%x2\\t#addhi3\\t%1,%d2 -> %0\";
      else  if (CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'J'))
	return \"add%:\\t%0,%1,$0\\t#addhi3\\t%1,%2 -> %0\";
      else abort_with_insn (insn, \"Constant does not fit descriptor\");
    }
  else
    return \"add%:\\t%0,%1,%2\\t#addhi3 %1,%2 -> %0\";

}")

(define_insn "addqi3"
  [(set (match_operand:QI 0 "general_operand" "=r")
	(plus:QI (match_operand:QI 1 "general_operand" "%r")
		 (match_operand:QI 2 "general_operand" "rIJ")))]
  ""
  "*
{
  if (GET_CODE (operands[2]) == CONST_INT)
    {
      if (CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'I'))
	return \"addi%:\\t%0,%1,%x2\\t#addqi3\\t%1,%d2 -> %0\";
      else  if (CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'J'))
	return \"add%:\\t%0,%1,$0\\t#addqi3\\t%1,%2 -> %0\";
      else abort_with_insn (insn, \"Constant does not fit descriptor\");
    }
  else
    return \"add%:\\t%0,%1,%2\\t#addqi3 %1,%2 -> %0\";
}")

;;- All kinds of subtract instructions.

(define_insn "subdf3"
  [(set (match_operand:DF 0 "general_operand" "=f")
	(minus:DF (match_operand:DF 1 "general_operand" "f")
		  (match_operand:DF 2 "general_operand" "f")))]
  ""
  "sub.d\\t%0,%1,%2")

(define_insn "subsf3"
  [(set (match_operand:SF 0 "general_operand" "=f")
	(minus:SF (match_operand:SF 1 "general_operand" "f")
		  (match_operand:SF 2 "general_operand" "f")))]
  ""
  "sub.s\\t%0,%1,%2")

(define_insn "subsi3"
  [(set (match_operand:SI 0 "general_operand" "=r")
	(minus:SI (match_operand:SI 1 "general_operand" "r")
		  (match_operand:SI 2 "general_operand" "rIJ")))]
  ""
  "*
{
  if (GET_CODE (operands[2]) == CONST_INT)
    {
      if (CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'I'))
	{
	  rtx ops[4];
	  ops[0] = operands[0];
	  ops[1] = operands[1];
	  ops[3] = operands[2];
	  ops[2] = gen_rtx (CONST_INT, VOIDmode, -INTVAL (operands[2]));
	  output_asm_insn (\"addi%:\\t%0,%1,%x2\\t#subsi3\\t%1,%d3 -> %0\",
			   ops);
	  return \"\";
	}
      else  if (CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'J'))
	return \"sub%:\\t%0,%1,$0\\t#subsi3\\t%1,%2 -> %0\";
      else abort_with_insn (insn, \"Constant does not fit descriptor\");
    }
  else
    return \"sub%:\\t%0,%1,%2\\t#subsi3 %1,%2 -> %0\";
}")

(define_insn "subhi3"
  [(set (match_operand:HI 0 "general_operand" "=r")
	(minus:HI (match_operand:HI 1 "general_operand" "r")
		  (match_operand:HI 2 "general_operand" "r")))]
  ""
  "*
{
  if (GET_CODE (operands[2]) == CONST_INT)
    {
      if (CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'I'))
	{
	  rtx ops[4];
	  ops[0] = operands[0];
	  ops[1] = operands[1];
	  ops[3] = operands[2];
	  ops[2] = gen_rtx (CONST_INT, VOIDmode, -INTVAL (operands[2]));
	  output_asm_insn (\"addi%:\\t%0,%1,%x2\\t#subhi3\\t%1,%d3 -> %0\"
			   , ops);
	  return \"\";
	}
      else  if (CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'J'))
	return \"sub%:\\t%0,%1,$0\\t#subhi3\\t%1,%2 -> %0\";
      else abort_with_insn (insn, \"Constant does not fit descriptor\");
    }
  else
    return \"sub%:\\t%0,%1,%2\\t#subhi3 %1,%2 -> %0\";
}")

(define_insn "subqi3"
  [(set (match_operand:QI 0 "general_operand" "=r")
	(minus:QI (match_operand:QI 1 "general_operand" "r")
		  (match_operand:QI 2 "general_operand" "r")))]
  ""
  "*
{
  if (GET_CODE (operands[2]) == CONST_INT)
    {
      if (CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'I'))
	{
	  rtx ops[4];
	  ops[0] = operands[0];
	  ops[1] = operands[1];
	  ops[3] = operands[2];
	  ops[2] = gen_rtx (CONST_INT, VOIDmode, -INTVAL (operands[2]));
	  output_asm_insn (\"addi%:\\t%0,%1,%x2\\t#subqi3\\t%1,%d3 -> %0\"
			   , ops);
	  return \"\";
	}
      else  if (CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'J'))
	return \"sub%:\\t%0,%1,$0\\t#subqi3\\t%1,%2 -> %0\";
      else abort_with_insn (insn, \"Constant does not fit descriptor\");
    }
  else
    return \"sub%:\\t%0,%1,%2\\t#subqi3 %1,%2 -> %0\";
}")

;;- Multiply instructions.

(define_insn "muldf3"
  [(set (match_operand:DF 0 "general_operand" "=f")
	(mult:DF (match_operand:DF 1 "general_operand" "%f")
		 (match_operand:DF 2 "general_operand" "f")))]
  ""
  "mul.d\\t%0,%1,%2")

(define_insn "mulsf3"
  [(set (match_operand:SF 0 "general_operand" "=f")
	(mult:SF (match_operand:SF 1 "general_operand" "%f")
		 (match_operand:SF 2 "general_operand" "f")))]
  ""
  "mul.s\\t%0,%1,%2")

(define_insn "mulsi3"
  [(set (match_operand:SI 0 "general_operand" "=r")
	(mult:SI (match_operand:SI 1 "general_operand" "%r")
		 (match_operand:SI 2 "general_operand" "r")))]
  ""
  "mul\\t%0,%1,%2\\t#mulsi3 %1,%2 -> %0")

(define_insn "mulhi3"
  [(set (match_operand:HI 0 "general_operand" "=r")
	(mult:HI (match_operand:HI 1 "general_operand" "%r")
		 (match_operand:HI 2 "general_operand" "r")))]
  ""
  "mul\\t%0,%1,%2\\t#mulhi3 %1,%2 -> %0")

(define_insn "mulqi3"
  [(set (match_operand:QI 0 "general_operand" "=r")
	(mult:QI (match_operand:QI 1 "general_operand" "%r")
		 (match_operand:QI 2 "general_operand" "r")))]
  ""
  "mul\\t%0,%1,%2\\t#mulhi3 %1,%2 -> %0")

;;- Divide instructions.

(define_insn "divdf3"
  [(set (match_operand:DF 0 "general_operand" "=f")
	(div:DF (match_operand:DF 1 "general_operand" "f")
		(match_operand:DF 2 "general_operand" "f")))]
  ""
  "div.d\\t%0,\\t%1,%2")

(define_insn "divsf3"
  [(set (match_operand:SF 0 "general_operand" "=f")
	(div:SF (match_operand:SF 1 "general_operand" "f")
		(match_operand:SF 2 "general_operand" "f")))]
  ""
  "div.s\\t%0,%1,%2")

(define_insn "divsi3"
  [(set (match_operand:SI 0 "general_operand" "=r")
	(div:SI (match_operand:SI 1 "general_operand" "r")
		(match_operand:SI 2 "general_operand" "r")))]
  ""
  "div\\t%0,%1,%2\\t#divsi3 %1,%2 -> %0")

(define_insn "divhi3"
  [(set (match_operand:HI 0 "general_operand" "=r")
	(div:HI (match_operand:HI 1 "general_operand" "r")
		(match_operand:HI 2 "general_operand" "r")))]
  ""
  "div\\t%0,%1,%2\\t#divhi3 %1,%2 -> %0")

(define_insn "divqi3"
  [(set (match_operand:QI 0 "general_operand" "=r")
	(div:QI (match_operand:QI 1 "general_operand" "r")
		(match_operand:QI 2 "general_operand" "r")))]
  ""
  "div\\t%0,%1,%2\\t#divqi3 %1,%2 -> %0")

;;
;;  ....................
;;
;;          LOGICAL
;;
;;  ....................
;;

(define_insn "anddi3"
  [(set (match_operand:DI 0 "general_operand" "=r")
	(and:DI (match_operand:DI 1 "general_operand" "%r")
                (match_operand:DI 2 "general_operand" "r")))]
  ""
  "*
{
  rtx xops[3];
  if ((REGNO (operands[0]) != (REGNO (operands[1]) +1))
      &&
      (REGNO (operands[0]) != (REGNO (operands[2]) +1)))
    {
      /* TAKE CARE OF OVERLAPS */
      xops[0] =  gen_rtx (REG, SImode, REGNO (operands[0]));
      xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1]));
      xops[2] =  gen_rtx (REG, SImode, REGNO (operands[2]));
      output_asm_insn (\"and\\t%0,%1,%2\\t#anddi %1,%2 -> %0\", xops);
      xops[0] =  gen_rtx (REG, SImode, REGNO (xops[0])+1);
      xops[1] =  gen_rtx (REG, SImode, REGNO (xops[1])+1);
      xops[2] =  gen_rtx (REG, SImode, REGNO (xops[2])+1);
      output_asm_insn (\"and\\t%0,%1,%2\\t#anddi %1,%2 -> %0\", xops);
    }
  else
    abort ();
  return \"\";
}")

(define_insn "andsi3"
  [(set (match_operand:SI 0 "general_operand" "=r,&r")
	(and:SI (match_operand:SI 1 "general_operand" "%r,r")
		(match_operand:SI 2 "general_operand" "rJ,K")))]
  ""
  "*
{
  rtx xops[3];
  if (GET_CODE (operands[2]) == CONST_INT)
    {
      if (CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'K'))
	if (INTVAL (operands[2]) >= 0)
	  {
	    return \"andi\\t%0,%1,%x2\\t#andsi3\\t%1,%d2 -> %0\";
	  }
	else
	  {
	    xops[0] = operands[0];
	    xops[1] = operands[1];;
	    xops[2] = gen_rtx (CONST_INT, VOIDmode,
			       (INTVAL (operands[2]))>>16);
	    output_asm_insn (\"lui\\t%0,%x2\\t#load higher part (andsi3)\",
			     xops);
	    xops[2] = gen_rtx (CONST_INT, VOIDmode,
			       0xffff & (INTVAL (operands[2])));
	    output_asm_insn (\"addi%:\\t%0,$0,%x2\\t#load lower part (andsi3)\",
			     xops);
	    output_asm_insn (\"and\\t%0,%0,%1\\t#andsi3\", xops);
	    return \"\";
	  }
      else  if (CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'J'))
	return \"and\\t%0,%1,$0\\t#andsi3\\t%1,%2 -> %0\";
      else return \"ERROR op2 not zero \\t#andsi3\\t%1,%2 -> %0\";
    }
  else
    return \"and\\t%0,%1,%2\\t#andsi3\\t%1,%2 -> %0\";
}")

(define_insn "andhi3"
  [(set (match_operand:HI 0 "general_operand" "=r")
	(and:HI (match_operand:HI 1 "general_operand" "%r")
		(match_operand:HI 2 "general_operand" "r")))]
  ""
  "and\\t%0,%1,%2\\t#andhi3 %1,%2 -> %0")

(define_insn "andqi3"
  [(set (match_operand:QI 0 "general_operand" "=r")
	(and:QI (match_operand:QI 1 "general_operand" "%r")
		(match_operand:QI 2 "general_operand" "r")))]
  ""
  "and\\t%0,%1,%2\\t#andqi3 %1,%2 -> %0")

(define_insn "iordi3"
  [(set (match_operand:DI 0 "general_operand" "=r")
	(ior:DI (match_operand:DI 1 "general_operand" "%r")
                (match_operand:DI 2 "general_operand" "r")))]
  ""
  "*
{
  rtx xops[3];
  if ((REGNO (operands[0]) != (REGNO (operands[1]) +1))
      &&
      (REGNO (operands[0]) != (REGNO (operands[2]) +1)))
    {
      /* TAKE CARE OF OVERLAPS */
      xops[0] =  gen_rtx (REG, SImode, REGNO (operands[0]));
      xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1]));
      xops[2] =  gen_rtx (REG, SImode, REGNO (operands[2]));
      output_asm_insn (\"or\\t%0,%1,%2\\t#iordi3 %1,%2 -> %0\", xops);
      xops[0] =  gen_rtx (REG, SImode, REGNO (xops[0])+1);
      xops[1] =  gen_rtx (REG, SImode, REGNO (xops[1])+1);
      xops[2] =  gen_rtx (REG, SImode, REGNO (xops[2])+1);
      output_asm_insn (\"or\\t%0,%1,%2\\t#iordi3 %1,%2 -> %0\", xops);
    }
  else
    abort ();
  return \"\";
}")

(define_insn "iorsi3"
  [(set (match_operand:SI 0 "general_operand" "=r")
	(ior:SI (match_operand:SI 1 "general_operand" "%r")
		(match_operand:SI 2 "general_operand" "rKJ")))]
  ""
  "*
{
  if (GET_CODE (operands[2]) == CONST_INT)
    {
      if (CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'K'))
	{
	  return \"ori\\t%0,%1,%x2\\t#iorsi3\\t%1,%d2 -> %0\";
	}
      else  if (CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'J'))
	return \"or\\t%0,%1,$0\\t#iorsi3\\t%1,%2 -> %0\";
      else return \"ERROR op2 not zero \\t#iorsi3\\t%1,%2 -> %0\";
    }
  else
    return \"or\\t%0,%1,%2\\t#iorsi3\\t%1,%2 -> %0\";
}")

(define_insn "iorhi3"
  [(set (match_operand:HI 0 "general_operand" "=r")
	(ior:HI (match_operand:HI 1 "general_operand" "%r")
		(match_operand:HI 2 "general_operand" "r")))]
  ""
  "or\\t%0,%1,%2\\t#iorhi3 %1,%2 -> %0")

(define_insn "iorqi3"
  [(set (match_operand:QI 0 "general_operand" "=r")
	(ior:QI (match_operand:QI 1 "general_operand" "%r")
		(match_operand:QI 2 "general_operand" "r")))]
  ""
  "or\\t%0,%1,%2\\t#iorqi3 %1,%2 -> %0")

(define_insn "xordi3"
  [(set (match_operand:DI 0 "general_operand" "=r")
	(xor:DI (match_operand:DI 1 "general_operand" "r")
                (match_operand:DI 2 "general_operand" "r")))]
  ""
  "*
{
  rtx xops[3];
  if ((REGNO (operands[0]) != (REGNO (operands[1]) +1))
      &&
      (REGNO (operands[0]) != (REGNO (operands[2]) +1)))
    {
      /* TAKE CARE OF OVERLAPS */
      xops[0] =  gen_rtx (REG, SImode, REGNO (operands[0]));
      xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1]));
      xops[2] =  gen_rtx (REG, SImode, REGNO (operands[2]));
      output_asm_insn (\"xor\\t%0,%1,%2\\t#xordi3 %1,%2 -> %0\", xops);
      xops[0] =  gen_rtx (REG, SImode, REGNO (xops[0])+1);
      xops[1] =  gen_rtx (REG, SImode, REGNO (xops[1])+1);
      xops[2] =  gen_rtx (REG, SImode, REGNO (xops[2])+1);
      output_asm_insn (\"xor\\t%0,%1,%2\\t#xordi3 %1,%2 -> %0\", xops);
    }
  else
    abort ();
  return \"\";
}")

(define_insn "xorsi3"
  [(set (match_operand:SI 0 "general_operand" "=r")
	(xor:SI (match_operand:SI 1 "general_operand" "%r")
		(match_operand:SI 2 "general_operand" "rKJ")))]
  ""
  "*
{
  if (GET_CODE (operands[2]) == CONST_INT)
    {
      if (CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'K'))
	{
	  return \"xori\\t%0,%1,%x2\\t#xorsi3\\t%1,%d2 -> %0\";
	}
      else  if (CONST_OK_FOR_LETTER_P (INTVAL (operands[2]), 'J'))
	return \"xor\\t%0,%1,$0\\t#xorsi3\\t%1,%2 -> %0\";
      else return \"ERROR op2 not zero \\t#xorsi3\\t%1,%2 -> %0\";
    }
  else
    return \"xor\\t%0,%1,%2\\t#xorsi3\\t%1,%2 -> %0\";
}")

(define_insn "xorhi3"
  [(set (match_operand:HI 0 "general_operand" "=r")
	(xor:HI (match_operand:HI 1 "general_operand" "%r")
		(match_operand:HI 2 "general_operand" "r")))]
  ""
  "xor\\t%0,%1,%2\\t#xorhi3 %1,%2 -> %0")

(define_insn "xorqi3"
  [(set (match_operand:QI 0 "general_operand" "=r")
	(xor:QI (match_operand:QI 1 "general_operand" "%r")
		(match_operand:QI 2 "general_operand" "r")))]
  ""
  "xor\\t%0,%1,%2\\t#xorqi3 %1,%2 -> %0")

;;
;;  ....................
;;
;;          TRUNCATION
;;
;;  ....................

;; Extension and truncation insns.
;; Those for integer source operand
;; are ordered widest source type first.


(define_insn "truncsiqi2"
  [(set (match_operand:QI 0 "general_operand" "=r")
	(truncate:QI (match_operand:SI 1 "general_operand" "r")))]
  ""
  "andi\\t%0,%1,0xff\\t#truncsiqi2\\t %1 -> %0")

(define_insn "truncsihi2"
  [(set (match_operand:HI 0 "general_operand" "=r")
	(truncate:HI (match_operand:SI 1 "general_operand" "r")))]
  ""
  "*
    output_asm_insn (\"sll\\t%0,%1,0x10\\t#truncsihi2\\t %1 -> %0\",
                    operands);
    return \"sra\\t%0,%0,0x10\\t#truncsihi2\\t %1 -> %0\";
")

(define_insn "trunchiqi2"
  [(set (match_operand:QI 0 "general_operand" "=r")
	(truncate:QI (match_operand:HI 1 "general_operand" "r")))]
  ""
  "andi\\t%0,%1,0xff\\t#trunchiqi2\\t %1 -> %0")

(define_insn "truncdfsf2"
  [(set (match_operand:SF 0 "general_operand" "=f")
	(float_truncate:SF (match_operand:DF 1 "general_operand" "f")))]
  ""
  "cvt.s.d\\t%0,%1\\t#truncdfsf2\\t %1 -> %0")

;;
;;  ....................
;;
;;          ZERO EXTENSION
;;
;;  ....................

;; Extension insns.
;; Those for integer source operand
;; are ordered widest source type first.



(define_insn "zero_extendhisi2"
  [(set (match_operand:SI 0 "general_operand" "=r,r")
	(zero_extend:SI (match_operand:HI 1 "general_operand" "r,m")))]
  ""
  "*
{
  if (which_alternative == 0)
    {
      output_asm_insn (\"sll\\t%0,%1,0x10\\t#zero_extendhisi2\\t %1 -> %0\",
		       operands);
      return \"srl\\t%0,%0,0x10\\t#zero_extendhisi2\\t %1 -> %0\";
    }
  else
    return \"lhu\\t%0,%1\\t#zero extendhisi2 %1 -> %0\";
}")

(define_insn "zero_extendqihi2"
  [(set (match_operand:HI 0 "general_operand" "=r")
	(zero_extend:HI (match_operand:QI 1 "general_operand" "r")))]
  ""
  "*
    output_asm_insn (\"sll\\t%0,%1,0x18\\t#zero_extendqihi2\\t %1 -> %0\",
                    operands);
    return \"srl\\t%0,%0,0x18\\t#zero_extendqihi2\\t %1 -> %0\";
  ")


(define_insn "zero_extendqisi2"
  [(set (match_operand:SI 0 "general_operand" "=r,r")
	(zero_extend:SI (match_operand:QI 1 "general_operand" "r,m")))]
  ""
  "*
{
  if (which_alternative == 0)
    {
      return \"andi\\t%0,%1,0xff\\t#zero_extendqisi2\\t %1 -> %0\";
    }
  else
    return \"lbu\\t%0,%1\\t#zero extendqisi2 %1 -> %0\";
}")


;;
;;  ....................
;;
;;          SIGN EXTENSION
;;
;;  ....................

;; Extension insns.
;; Those for integer source operand
;; are ordered widest source type first.



(define_insn "extendhisi2"
  [(set (match_operand:SI 0 "general_operand" "=r,r")
	(sign_extend:SI (match_operand:HI 1 "general_operand" "r,m")))]
  ""
  "*
{
  if (which_alternative == 0)
    {
      output_asm_insn (\"sll\\t%0,%1,0x10\\t#sign extendhisi2\\t %1 -> %0\",
		       operands);
      return \"sra\\t%0,%0,0x10\\t#sign extendhisi2\\t %1 -> %0\";
    }
  else
    return \"lh\\t%0,%1\\t#sign extendhisi2 %1 -> %0\";
}")

(define_insn "extendqihi2"
  [(set (match_operand:HI 0 "general_operand" "=r")
	(sign_extend:HI (match_operand:QI 1 "general_operand" "r")))]
  ""
  "*
    output_asm_insn (\"sll\\t%0,%1,0x18\\t#sign extendqihi2\\t %1 -> %0\",
                    operands);
    return \"sra\\t%0,%0,0x18\\t#sign extendqihi2\\t %1 -> %0\";
  ")


(define_insn "extendqisi2"
  [(set (match_operand:SI 0 "general_operand" "=r,r")
	(sign_extend:SI (match_operand:QI 1 "general_operand" "r,m")))]
  ""
  "*
{
  if (which_alternative == 0)
    {
      output_asm_insn (\"sll\\t%0,%1,0x18\\t#sign extendqisi2\\t %1 -> %0\",
		       operands);
      return \"sra\\t%0,%0,0x18\\t#sign extendqisi2\\t %1 -> %0\";
    }
  else
    return \"lb\\t%0,%1\\t#sign extendqisi2 %1 -> %0\";
}")


(define_insn "extendsfdf2"
  [(set (match_operand:DF 0 "general_operand" "=f")
	(float_extend:DF (match_operand:SF 1 "general_operand" "f")))]
  ""
  "cvt.d.s\\t%0,%1\\t#extendsfdf2\\t %1 -> %0")


;;
;;  ....................
;;
;;          CONVERSIONS
;;
;;  ....................


(define_insn "fix_truncdfsi2"
  [(set (match_operand:SI 0 "general_operand" "=r")
	(fix:SI (fix:DF (match_operand:DF 1 "general_operand" "f"))))
   (clobber (reg:DF 44))]
  ""
  "trunc.w.d\\t$f12,%1,%0\\t#fix_truncdfsi2\\t%1 -> %0\;mfc1\\t%0,$f12\\t#fix_truncdfsi2\\t%1 -> %0")


(define_insn "fix_truncsfsi2"
  [(set (match_operand:SI 0 "general_operand" "=r")
	(fix:SI (fix:SF (match_operand:SF 1 "general_operand" "f"))))
   (clobber (reg:DF 44))]
  ""
  "trunc.w.s\\t$f12,%1,%0\\t#fix_truncsfsi2\\t%1 -> %0\;mfc1\\t%0,$f12\\t#fix_truncsfsi2\\t%1 -> %0")

(define_insn "floatsidf2"
  [(set (match_operand:DF 0 "general_operand" "=f")
	(float:DF (match_operand:SI 1 "general_operand" "r")))]
  ""
  "mtc1\\t%1,%0\\t#floatsidf2\\t%1 -> %0\;cvt.d.w\\t%0,%0\\t#floatsidf2\\t%1 -> %0")


(define_insn "floatsisf2"
  [(set (match_operand:SF 0 "general_operand" "=f")
	(float:SF (match_operand:SI 1 "general_operand" "r")))]
  ""
  "mtc1\\t%1,%0\\t#floatsisf2\\t%1 -> %0\;cvt.s.w\\t%0,%0\\t#floatsisf2\\t%1 -> %0")

					;;- Wild things used when
					;;- unions make double and int
					;;- overlap.
					;;-
					;;- This must be supported
					;;- since corresponding code
					;;- gets generated

(define_insn ""
  [(set (subreg:DF (match_operand:DI 0 "register_operand" "=ry") 0)
	(match_operand:DF 1  "register_operand" "rf"))
   (clobber (match_operand  2  "register_operand" "rf"))]
  ""
  "*
{
  rtx xops[2];
  xops[0] =  gen_rtx (REG, SImode, REGNO (operands[0]));
#ifndef DECSTATION
  xops[1] =  gen_rtx (REG, DFmode, REGNO (operands[1])+1);
#else
  xops[1] =  gen_rtx (REG, DFmode, REGNO (operands[1]));
#endif
  output_asm_insn (\"mfc1\\t%0,%1\\t# %1 -> (subreg:DF %0 0) \\t likely Union\"
		   , xops);
  xops[0] =  gen_rtx (REG, SImode, REGNO (operands[0])+1);
#ifndef DECSTATION
  xops[1] =  gen_rtx (REG, DFmode, REGNO (operands[1]));
#else
  xops[1] =  gen_rtx (REG, DFmode, REGNO (operands[1])+1);
#endif
  output_asm_insn (\"mfc1\\t%0,%1\\t# %1 -> (subreg:DF %0 0)  \"
		   , xops);
  return (\"\");
}")



(define_insn ""
  [(set (subreg:DF (match_operand:DI 0 "register_operand" "=ry") 0)
	(match_operand:DF 1  "register_operand" "rf"))]
  ""
  "*
{
  rtx xops[2];
  xops[0] =  gen_rtx (REG, SImode, REGNO (operands[0]));
#ifndef DECSTATION
  xops[1] =  gen_rtx (REG, DFmode, REGNO (operands[1])+1);
#else
  xops[1] =  gen_rtx (REG, DFmode, REGNO (operands[1]));
#endif
  output_asm_insn (\"mfc1\\t%0,%1\\t# %1 -> (subreg:DF %0 0) \\t likely Union\"
		   , xops);
  xops[0] =  gen_rtx (REG, SImode, REGNO (operands[0])+1);
#ifndef DECSTATION
  xops[1] =  gen_rtx (REG, DFmode, REGNO (operands[1]));
#else
  xops[1] =  gen_rtx (REG, DFmode, REGNO (operands[1])+1);
#endif
  output_asm_insn (\"mfc1\\t%0,%1\\t# %1 -> (subreg:DF %0 0)  \"
		   ,xops);
  return (\"\");
}")



(define_insn ""
  [(set (match_operand:DF 0  "register_operand" "=rf")
        (subreg:DF (match_operand:DI 1 "register_operand" "ry") 0))
   (clobber (match_operand  2  "register_operand" "rf"))]
  ""
  "*
{
  rtx xops[2];
  xops[0] =  gen_rtx (REG, DFmode, REGNO (operands[0]));
#ifndef DECSTATION
  xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1])+1);
#else
  xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1]));
#endif
  output_asm_insn (\"mtc1\\t%1,%0\\t# (subreg:DF %1) -> %0  \\t\"
		   , xops);
  xops[0] =  gen_rtx (REG, DFmode, REGNO (operands[0])+1);
#ifndef DECSTATION
  xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1]));
#else
  xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1])+1);
#endif
  output_asm_insn (\"mtc1\\t%1,%0\\t# (subreg:DF %1) -> %0  \\t\"
		   , xops);
  return (\"\");
}")



(define_insn ""
  [(set (match_operand:DF 0  "register_operand" "=rf")
        (subreg:DF (match_operand:DI 1 "register_operand" "ry") 0))]
  ""
  "*
{
  rtx xops[2];
  xops[0] =  gen_rtx (REG, DFmode, REGNO (operands[0]));
#ifndef DECSTATION
  xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1])+1);
#else
  xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1]));
#endif
  output_asm_insn (\"mtc1\\t%1,%0\\t# (subreg:DF %1) -> %0  \\t\"
		   , xops);
  xops[0] =  gen_rtx (REG, DFmode, REGNO (operands[0])+1);
#ifndef DECSTATION
  xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1]));
#else
  xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1])+1);
#endif
  output_asm_insn (\"mtc1\\t%1,%0\\t# (subreg:DF %1) -> %0  \\t\"
		   , xops);

  return (\"\");
}")

;;
;;  ....................
;;
;;          MOVES
;;
;;          and
;;
;;          LOADS AND STORES
;;
;;  ....................

(define_insn "movdi"
  [(set (match_operand:DI 0 "general_operand" "=r,*r,*m")
	(match_operand:DI 1 "general_operand" "r,*miF,*r"))]
  ""
  "*
{
  extern rtx change_address ();
  extern rtx plus_constant ();

  if (which_alternative == 0)
    {
      rtx xops[2];
      if (REGNO (operands[0]) != (REGNO (operands[1]) +1))
	{
	  /* TAKE CARE OF OVERLAPS */
	  xops[0] =  gen_rtx (REG, SImode, REGNO (operands[0]));
	  xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1]));
	  output_asm_insn (\"add%:\\t%0,$0,%1\\t#movdi %1 -> %0\", xops);
	  xops[0] =  gen_rtx (REG, SImode, REGNO (xops[0])+1);
	  xops[1] =  gen_rtx (REG, SImode, REGNO (xops[1])+1);
	  output_asm_insn (\"add%:\\t%0,$0,%1\\t#movdi %1 -> %0\", xops);
	}
      else
	{
	  /* TAKE CARE OF OVERLAPS */
	  xops[0] =  gen_rtx (REG, SImode, REGNO (operands[0])+1);
	  xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1])+1);
	  output_asm_insn (\"add%:\\t%0,$0,%1\\t#movdi %1 -> %0\", xops);
	  xops[0] =  gen_rtx (REG, SImode, REGNO (xops[0])-1);
	  xops[1] =  gen_rtx (REG, SImode, REGNO (xops[1])-1);
	  output_asm_insn (\"add%:\\t%0,$0,%1\\t#movdi %1 -> %0\", xops);
	}
      return \"\";
    }
  else if (which_alternative == 1)
    {
      /* No overlap here */
      rtx xops[2];
      xops[0] =  gen_rtx (REG, SImode, REGNO (operands[0]));
      if (GET_CODE (operands[1]) == MEM)
	{
	  xops[1] =  gen_rtx (MEM, SImode, XEXP (operands[1], 0));
	  output_asm_insn (\"lw\\t%0,%1\\t#movdi %1 (mem) -> %0\", xops);
	}
      else if (CONSTANT_P (operands[1]))
	{
#ifdef WORDS_BIG_ENDIAN
	  xops[1] = const0_rtx;
#else
	  xops[1] = operands[1];
#endif
	  output_load_immediate (xops);
	}
      else if (GET_CODE (operands[1]) == CONST_DOUBLE)
	{
	  xops[1] = gen_rtx (CONST_INT, VOIDmode,
			     CONST_DOUBLE_LOW (operands[1]));
	  output_load_immediate (xops);
	}
      else
	abort ();
      xops[0] =  gen_rtx (REG, SImode, REGNO (operands[0])+1);
      if (offsettable_memref_p (operands[1]))
	{
	  xops[1] = adj_offsettable_operand (gen_rtx (MEM, SImode,
						      XEXP (operands[1], 0)),
					     4);
	  output_asm_insn (\"lw\\t%0,%1\\t#movdi %1(mem) -> %0\", xops);
	}
      else if (GET_CODE (operands[1]) == MEM)
	{
	  abort ();
	  output_asm_insn (\"lw\\t%0,%1\\t#movdi %1(mem) -> %0\", xops);
	}
      else if (CONSTANT_P (operands[1]))
	{
#ifdef WORDS_BIG_ENDIAN
	  xops[1] = operands[1];
#else
	  xops[1] = const0_rtx;
#endif
	  output_load_immediate (xops);
	}
      else if (GET_CODE (operands[1]) == CONST_DOUBLE)
	{
	  xops[1] = gen_rtx (CONST_INT, VOIDmode,
			     CONST_DOUBLE_HIGH (operands[1]));
	  output_load_immediate (xops);
	}
      else abort ();
      return \"\";
    }
  else
    {
      /* No overlap here */
      rtx xops[2];
      xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1]));
      if (GET_CODE (operands[0]) == MEM)
	xops[0] =  gen_rtx (MEM, SImode, XEXP (operands[0], 0));
      else abort ();
      output_asm_insn (\"sw\\t%1,%0\\t#movdi %1 -> %0(mem)\", xops);
      xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1])+1);
      if (offsettable_memref_p (operands[0]))
	{
	  xops[0] = adj_offsettable_operand (gen_rtx (MEM, SImode,
						      XEXP (operands[0], 0)),
					     4);
	  output_asm_insn (\"sw\\t%1,%0\\t#movdi %1 -> %0 (mem)\", xops);
	}
      else if (GET_CODE (operands[0]) == MEM)
	{
	  abort ();
	  output_asm_insn (\"sw\\t%1,%0\\t#movdi %1(mem) -> %0\", xops);
	}
      else abort ();
      return \"\";
    }
}")

(define_insn "movsi"
  [(set (match_operand:SI 0 "general_operand" "=r,r,m,r,r,m,*r")
	(match_operand:SI 1 "general_operand" "r,m,r,i,J,J,*p"))]
  ""
  "*
{
  if (which_alternative >= 4)
    {
      if (which_alternative == 4)
	return \"add%:\\t%0,$0,$0\\t#movsi\\t%1 == 0  -> %0\";
      else if (which_alternative == 5)
	return \"sw\\t$0,%0\\t#movsi\\t%1 == 0  -> %0\";
      else if (which_alternative == 6)
	{
	  rtx xops[4];
	  register rtx addr;
	  xops[0] = operands[0];
	  addr = operands[1];
	  if ((GET_CODE (addr) == PLUS)
	      && (GET_CODE (XEXP (addr, 0)) == REG))
	    {
	      xops[1] = XEXP (addr, 0);
	      xops[2] = XEXP (addr, 1);
	      xops[3] = addr;
	      output_asm_insn (\"addiu\\t%0,%1,%2\\t#movsi (*p)\\t%a3 -> %0\", xops);
	      return \"\";
	    }
	  else abort ();
	}
    }
  else if ((GET_CODE (operands[0]) == REG) && (GET_CODE (operands[1]) == REG))
    return \"add%:\\t%0,$0,%1\\t#movsi\\t%1 -> %0 \";
  else if (GET_CODE (operands[0]) == REG
	   &&
	   GET_CODE (operands[1]) == CONST_INT)
    {
      output_load_immediate (operands);
      return \"\";
    }
  else if (GET_CODE (operands[0]) == REG)
    {
      if (GET_CODE (operands[1]) == SYMBOL_REF
	  || GET_CODE (operands[1]) == LABEL_REF)
	return \"la\\t%0,%a1\\t#movsi %a1 -> %0\";
      else if (GET_CODE (operands[1]) == CONST)
	return \"la\\t%0,%a1\\t#movsi %a1(AExp) -> %0\";
      else
	return \"lw\\t%0,%1\\t#movsi %1 -> %0\";
    }
  else
    return \"sw\\t%1,%0\\t#movsi %1 -> %0\";
}")

(define_insn ""
  [(set (match_operand:SI 0 "register_operand" "=*r")
	(match_operand:SI 1 "address_operand" "*p"))]
  "FIXED_FRAME_PTR_REL_P (operands[1])"
  "*
{
  rtx xops[4];
  register rtx addr;
  xops[0] = operands[0];
  addr = operands[1];
  if (GET_CODE (addr) == PLUS
      && GET_CODE (XEXP (addr, 0)) == REG)
    {
      xops[1] = XEXP (addr, 0);
      xops[2] = XEXP (addr, 1);
      xops[3] = addr;
      output_asm_insn (\"addiu\\t%0,%1,%2\\t#movsi (*p)\\t%a3 -> %0\", xops);
      return \"\";
    }
  else
    abort ();
}")

(define_insn "movhi"
  [(set (match_operand:HI 0 "general_operand" "=r,r,m,r,r,m")
	(match_operand:HI 1 "general_operand" "r,m,r,i,J,J"))]
  ""
  "*
{
  if (which_alternative == 4)
    return \"add%:\\t%0,$0,$0\\t#movhi\\t%1 == 0  -> %0\";
  else if (which_alternative == 5)
    return \"sh\\t$0,%0\\t#movhi\\t%1 == 0  -> %0\";
  else if (GET_CODE (operands[0]) == REG && GET_CODE (operands[1]) == REG)
    return \"add%:\\t%0,$0,%1\\t#move.h %1 -> %0 \";
  else if (GET_CODE (operands[0]) == REG
	   && GET_CODE (operands[1]) == CONST_INT)
    return \"addi%:\\t%0,$0,%x1\\t# movhi %1 -> %0\";
  else if (GET_CODE (operands[0]) == REG)
    return \"lh\\t%0,%1\\t#movhi %1 -> %0\";
  else
    return \"sh\\t%1,%0\\t#movhi %1 -> %0\";
}")

(define_insn "movqi"
  [(set (match_operand:QI 0 "general_operand" "=r,r,m,r,r,m")
	(match_operand:QI 1 "general_operand" "r,m,r,i,J,J"))]
  ""
  "*
{
  if (which_alternative == 4)
    return \"add%:\\t%0,$0,$0\\t#movqi\\t%1 == 0  -> %0\";
  else if (which_alternative == 5)
    return \"sb\\t$0,%0\\t#movqi\\t%1 == 0  -> %0\";
  else if (GET_CODE (operands[0]) == REG && GET_CODE (operands[1]) == REG)
    return \"add%:\\t%0,$0,%1\\t#move.b %1 -> %0 \";

  if ((GET_CODE (operands[0]) == REG )
      &&
      (GET_CODE (operands[1]) == CONST_INT))
    return \"addi%:\\t%0,$0,%x1\\t# movqi %1 -> %0\";

  /* Should say that I am not padding high order
   ** bits correctly
   */
  else if (GET_CODE (operands[0]) == REG)
    return \"lb\\t%0,%1\\t#movqi %1 -> %0\";
  else
    return \"sb\\t%1,%0\\t#movqi %1 -> %0\";
}")

(define_insn "movsf"
  [(set (match_operand:SF 0 "general_operand" "=f,rf,m,f,!rf")
	(match_operand:SF 1 "general_operand" "f,m,rf,F,rf"))
   (clobber (reg:SI 24))]
  ""
  "*
{
  if (GET_CODE (operands[0]) == REG && GET_CODE (operands[1]) == REG)
    {
      if (REGNO (operands[0]) >= 32)
	{
	  if (REGNO (operands[1]) >= 32)
	    return \"mov.s %0,%1\\t#movsf %1 -> %0 \";
	  return \"mtc1 %1,%0\";
	}
      if (REGNO (operands[1]) >= 32)
	return \"mfc1 %0,%1\";
      return \"add%: %0,$0,%1\";
    }

  if (GET_CODE (operands[0]) == REG
      && GET_CODE (operands[1]) == CONST_DOUBLE)
    {
      rtx xops[3];
      xops[0] = operands[0];
      xops[1] = gen_rtx (CONST_INT, VOIDmode,
			 (XINT (operands[1], 0))>>16);
      xops[2] = gen_rtx (CONST_INT, VOIDmode,
			 XINT (operands[1], 0));
      output_asm_insn (\"lui\\t$24,%x1\\t#move  high part of %2\", xops);
      xops[1] = gen_rtx (CONST_INT, VOIDmode,
			 (XINT (operands[1], 0)) & 0xff);
      output_asm_insn (\"ori\\t$24,%x1\\t#move low part of %2\", xops);
      output_asm_insn (\"mtc1\\t$24,%0\", xops);

      xops[0] = gen_rtx (REG, SFmode, REGNO (xops[0])+1);
      xops[1] = gen_rtx (CONST_INT, VOIDmode,
			 (XINT (operands[1], 1))>>16);
      xops[2] = gen_rtx (CONST_INT, VOIDmode,
			 XINT (operands[1], 1));
      output_asm_insn (\"lui\\t$24,%x1\\t#move  high part of %2\", xops);
      xops[1] = gen_rtx (CONST_INT, VOIDmode,
			 (XINT (operands[1], 1)) & 0xff);
      output_asm_insn (\"ori\\t$24,%x1\\t#move low part of %2\", xops);

      output_asm_insn (\"mtc1\\t$24,%0\", xops);
      return \"cvt.s.d\\t %0,%0 \";
    }
  /* Should say that I am not padding high order
   ** bits correctly
   */
  else if (GET_CODE (operands[0]) == REG)
    {
      if (REGNO (operands[0]) < 32)
	return \"lw\\t %0,%1\\t#movsf %1 -> %0\";
      return \"l.s\\t %0,%1\\t#movsf %1 -> %0\";
    }
  else
    {
      if (REGNO (operands[1]) < 32)
	return \"sw\\t %1,%0\\t#movsf %1 -> %0\";
      return \"s.s\\t %1,%0\\t#movsf %1 -> %0\";
    }
}")

;; ---

(define_insn "movdf"
  [(set (match_operand:DF 0 "general_operand" "=f,f,m,f,*f,*y")
	(match_operand:DF 1 "general_operand" "f,m,f,F,*y,*f"))
   (clobber (reg:SI 24))]
  ""
  "*
{
  if (which_alternative > 3)
    {
      rtx xops[2];

      if (REGNO (operands[1]) == 6)
	{
	  xops[0] =  gen_rtx (REG, DFmode, REGNO (operands[0]));
#ifndef DECSTATION
	  xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1])+1);
#else
	  xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1]));
#endif
	  output_asm_insn (\"mtc1\\t%1,%0\\t# %1 -> %0  \\tcalling sequence trick\"
			   , xops);
	  xops[0] =  gen_rtx (REG, DFmode, REGNO (operands[0])+1);
#ifndef DECSTATION
	  xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1]));
#else
	  xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1])+1);
#endif
	  output_asm_insn (\"mtc1\\t%1,%0\\t# %1 -> %0  \\tcalling sequence trick\"
			   , xops);
	  return (\"\");
	}
      else if (REGNO (operands[0]) == 6)
	{
	  xops[0] =  gen_rtx (REG, SImode, REGNO (operands[0]));
#ifndef DECSTATION
	  xops[1] =  gen_rtx (REG, DFmode, REGNO (operands[1])+1);
#else
	  xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1]));
#endif
	  output_asm_insn (\"mfc1\\t%0,%1\\t# %1 -> %0  \\tcalling sequence trick\"
			   , xops);
	  xops[0] =  gen_rtx (REG, SImode, REGNO (operands[0])+1);
#ifndef DECSTATION
	  xops[1] =  gen_rtx (REG, DFmode, REGNO (operands[1]));
#else
	  xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1])+1);
#endif
	  output_asm_insn (\"mfc1\\t%0,%1\\t# %1 -> %0  \\tcalling sequence trick\"
			   , xops);
	  return (\"\");
	}
      else
	abort_with_insn (insn,
			 \"Matched *y constraint and register number wrong\");
    }
  else
    {
      if (GET_CODE (operands[0]) == REG && GET_CODE (operands[1]) == REG)
	return \"mov.d\\t%0,%1\\t#movdf %1 -> %0 \";

      if (GET_CODE (operands[0]) == REG
	  && GET_CODE (operands[1]) == CONST_DOUBLE)
	{
	  rtx xops[3];
	  xops[0] = operands[0];
	  xops[1] = gen_rtx (CONST_INT, VOIDmode,
			     (XINT (operands[1], 0))>>16);
	  xops[2] = gen_rtx (CONST_INT, VOIDmode,
			     XINT (operands[1], 0));
	  output_asm_insn (\"lui\\t$24,%x1\\t#move  high part of %2\", xops);
	  xops[1] = gen_rtx (CONST_INT, VOIDmode,
			     (XINT (operands[1], 0)) & 0xff);
	  output_asm_insn (\"ori\\t$24,%x1\\t#move low part of %2\", xops);
	  output_asm_insn (\"mtc1\\t%0,$24\", xops);

	  xops[0] = gen_rtx (REG, SFmode, REGNO (xops[0])+1);
	  xops[1] = gen_rtx (CONST_INT, VOIDmode,
			     (XINT (operands[1], 1))>>16);
	  xops[2] = gen_rtx (CONST_INT, VOIDmode,
			     XINT (operands[1], 1));
	  output_asm_insn (\"lui\\t$24,%x1\\t#move  high part of %2\", xops);
	  xops[1] = gen_rtx (CONST_INT, VOIDmode,
			     (XINT (operands[1], 1)) & 0xff);
	  output_asm_insn (\"ori\\t$24,%x1\\t#move low part of %2\", xops);

	  output_asm_insn (\"mtc1\\t%0,$24\", xops);
	  return \"# \";

	}
      else if (GET_CODE (operands[0]) == REG)
	return \"l.d\\t %0,%1\\t#movdf %1 -> %0\";
      else
	return \"s.d\\t %1,%0\\t#movdf %1 -> %0\";
    }
}")

(define_insn ""
  [(set (match_operand:SF 0 "general_operand" "=f,f,m")
	(match_operand:SF 1 "general_operand" "f,m,f"))]
  ""
  "*
{
  if (GET_CODE (operands[0]) == REG && GET_CODE (operands[1]) == REG)
    return \"mov.s %0,%1\\t#movsf %1 -> %0 \";

  if (GET_CODE (operands[0]) == REG)
    return \"l.s\\t %0,%1\\t#movsf %1 -> %0\";
  else
    return \"s.s\\t %1,%0\\t#movsf %1 -> %0\";
}")

;; ---

(define_insn ""
  [(set (match_operand:DF 0 "general_operand" "=f,f,m,*f,*y")
	(match_operand:DF 1 "general_operand" "f,m,f,*y,*f"))]
  ""
  "*
{
  if (which_alternative > 2)
    {
      rtx xops[2];
      if (REGNO (operands[1]) == 6)
	{
	  xops[0] =  gen_rtx (REG, DFmode, REGNO (operands[0]));
#ifndef DECSTATION
	  xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1])+1);
#else
	  xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1]));
#endif
	  output_asm_insn (\"mtc1\\t%1,%0\\t# %1 -> %0  \\tcalling sequence trick\"
			   , xops);
	  xops[0] =  gen_rtx (REG, DFmode, REGNO (operands[0])+1);
#ifndef DECSTATION
	  xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1]));
#else
	  xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1])+1);
#endif
	  output_asm_insn (\"mtc1\\t%1,%0\\t# %1 -> %0  \\tcalling sequence trick\"
			   , xops);
	  return (\"\");
	}
      else if (REGNO (operands[0]) == 6)
	{
	  xops[0] =  gen_rtx (REG, SImode, REGNO (operands[0]));
#ifndef DECSTATION
	  xops[1] =  gen_rtx (REG, DFmode, REGNO (operands[1])+1);
#else
	  xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1]));
#endif
	  output_asm_insn (\"mfc1\\t%0,%1\\t# %1 -> %0  \\tcalling sequence trick\"
			   , xops);
	  xops[0] =  gen_rtx (REG, SImode, REGNO (operands[0])+1);
#ifndef DECSTATION
	  xops[1] =  gen_rtx (REG, DFmode, REGNO (operands[1]));
#else
	  xops[1] =  gen_rtx (REG, SImode, REGNO (operands[1])+1);
#endif
	  output_asm_insn (\"mfc1\\t%0,%1\\t# %1 -> %0  \\tcalling sequence trick\"
			   , xops);
	  return (\"\");
	}
      else
	abort_with_insn (insn,
			 \"Matched *y constraint and register number wrong\");
    }
  else
    {
      if ((GET_CODE (operands[0]) == REG) && (GET_CODE (operands[1]) == REG))
	return \"mov.d\\t%0,%1\\t#movdf %1 -> %0 \";

      if (GET_CODE (operands[0]) == REG)
	return \"l.d\\t %0,%1\\t#movdf %1 -> %0\";
      else
	return \"s.d\\t %1,%0\\t#movdf %1 -> %0\";
    }
}")

(define_insn ""
  [(set (match_operand:SI 0 "general_operand" "=r")
	(match_operand:QI 1 "general_operand" "r"))]
  ""
  "andi\\t%0,%1,0xff\\t#Wild zero_extendqisi2\\t %1 -> %0")




;;
;;  ....................
;;
;;          OTHER ARITHMETIC AND SHIFT
;;
;;  ....................

(define_insn "ashlqi3"
  [(set (match_operand:QI 0 "general_operand" "=r")
	(ashift:QI (match_operand:QI 1 "general_operand" "r")
		   (match_operand:SI 2 "arith32_operand" "ri")))]
  ""
  "*
{
  if (GET_CODE (operands[2]) == CONST_INT)
    {
      operands[2] = gen_rtx (CONST_INT, VOIDmode, (XINT (operands[2], 0))& 0x1f);
      output_asm_insn (\"sll\\t%0,%1,%2\\t#ashlqi3\\t (%1<<%2) -> %0\", operands);
    }
  else
    output_asm_insn (\"sll\\t%0,%1,%2\\t#ashlqi3\\t (%1<<%2) -> %0 (asm syntax)\",
		     operands);
  return \"andi\\t%0,%0,0xff\\t#ashlqi3\";
}")



(define_insn "ashlhi3"
  [(set (match_operand:HI 0 "general_operand" "=r")
	(ashift:HI (match_operand:HI 1 "general_operand" "r")
		   (match_operand:SI 2 "arith32_operand" "ri")))]
  ""
  "*
{
  if (GET_CODE (operands[2]) == CONST_INT)
    {
      operands[2] = gen_rtx (CONST_INT, VOIDmode, (XINT (operands[2], 0))& 0x1f);
      output_asm_insn (\"sll\\t%0,%1,%2\\t#ashlhi3\\t (%1<<%2) -> %0\",
		       operands);
    }
  else
    output_asm_insn (\"sll\\t%0,%1,%2\\t#ashlhi3\\t (%1<<%2) -> %0 (asm syntax)\",
		     operands);
  return \"sll\\t%0,%0,0x10\;sra\\t%0,%0,0x10\\t#ashlhi3\";
}")



(define_insn "ashlsi3"
  [(set (match_operand:SI 0 "general_operand" "=r")
	(ashift:SI (match_operand:SI 1 "general_operand" "r")
		   (match_operand:SI 2 "arith32_operand" "ri")))]
  ""
  "*
{
  if (GET_CODE (operands[2]) == CONST_INT)
    {
      operands[2] = gen_rtx (CONST_INT, VOIDmode, (XINT (operands[2], 0))& 0x1f);
      return \"sll\\t%0,%1,%2\\t#ashlsi3\\t (%1<<%2) -> %0\";
    }
  return \"sll\\t%0,%1,%2\\t#ashlsi3\\t (%1<<%2) -> %0 (asm syntax)\";
}")



(define_insn "ashrsi3"
  [(set (match_operand:SI 0 "general_operand" "=r")
	(ashiftrt:SI (match_operand:SI 1 "general_operand" "r")
		     (match_operand:SI 2 "arith32_operand" "ri")))]
  ""
  "*
{
  if (GET_CODE (operands[2]) == CONST_INT)
    {
      operands[2] = gen_rtx (CONST_INT, VOIDmode, (XINT (operands[2], 0))& 0x1f);
      return \"sra\\t%0,%1,%2\\t#ashrsi3\\t (%1>>%2) -> %0\";
    }
  return \"sra\\t%0,%1,%2\\t#ashrsi3\\t (%1>>%2) -> %0 (asm syntax for srav)\";
}")



(define_insn "lshrsi3"
  [(set (match_operand:SI 0 "general_operand" "=r")
	(lshiftrt:SI (match_operand:SI 1 "general_operand" "r")
		     (match_operand:SI 2 "arith32_operand" "rn")))]
  ""
  "*
{
  if (GET_CODE (operands[2]) == CONST_INT)
    {
      operands[2] = gen_rtx (CONST_INT, VOIDmode, (XINT (operands[2], 0))& 0x1f);
      return \"srl\\t%0,%1,%2\\t#lshrsi3\\t (%1>>%2) -> %0\";
    }
  return \"srl\\t%0,%1,%2\\t#lshrsi3\\t (%1>>%2) -> %0 (asm syntax)\";
}")




(define_insn "negsi2"
  [(set (match_operand:SI 0 "general_operand" "=r")
	(neg:SI (match_operand:SI 1 "general_operand" "r")))]
  ""
  "sub%:\\t%0,$0,%1\\t#negsi2")


(define_insn "negdf2"
  [(set (match_operand:DF 0 "general_operand" "=f")
	(neg:DF (match_operand:DF 1 "general_operand" "f")))]
  ""
  "neg.d\\t%0,%1\\t#negdf2")



(define_insn "negsf2"

  [(set (match_operand:SF 0 "general_operand" "=f")
	(neg:SF (match_operand:SF 1 "general_operand" "f")))]
  ""
  "neg.s\\t%0,%1\\t#negsf2")


(define_insn "one_cmplsi2"
  [(set (match_operand:SI 0 "general_operand" "=r")
	(not:SI (match_operand:SI 1 "general_operand" "r")))]
  ""
  "nor\\t%0,$0,%1\\t#one_cmplsi2")



(define_insn "one_cmplhi2"
  [(set (match_operand:HI 0 "general_operand" "=r")
	(not:HI (match_operand:HI 1 "general_operand" "r")))]
  ""
  "nor\\t%0,$0,%1\\t#one_cmplhi2")



(define_insn "one_cmplqi2"
  [(set (match_operand:QI 0 "general_operand" "=r")
	(not:QI (match_operand:QI 1 "general_operand" "r")))]
  ""
  "nor\\t%0,$0,%1\\t#one_cmplqi2")

;;
;;  ....................
;;
;;          BRANCHES
;;
;;  ....................


					;;- MERGED CMPSI + BEQ
(define_peephole
  [(set (cc0)
	(compare (match_operand:SI 0 "general_operand" "r")
		 (match_operand:SI 1 "general_operand" "r")))
   (set (pc)
	(if_then_else (eq (cc0)
			  (const_int 0))
		      (label_ref (match_operand 2 "" ""))
		      (pc)))]
  ""
  "beq \\t%0,%1,%l2\\t#beq MIPS primitive insn")

					;;- MERGED CMPSI + INV BEQ
(define_peephole
  [(set (cc0)
	(compare (match_operand:SI 0 "general_operand" "r")
		 (match_operand:SI 1 "general_operand" "r")))
   (set (pc)
	(if_then_else (ne (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 2 "" ""))))]
  ""
  "beq \\t%0,%1,%l2\\t#beq inverted primitive insn")
					;;- MERGED CMPSI + BNE
(define_peephole
  [(set (cc0)
	(compare (match_operand:SI 0 "general_operand" "r")
		 (match_operand:SI 1 "general_operand" "r")))
   (set (pc)
	(if_then_else (ne (cc0)
			  (const_int 0))
		      (label_ref (match_operand 2 "" ""))
		      (pc)))]
  ""
  "bne \\t%0,%1,%l2\\t#bne MIPS primitive insn")

					;;- MERGED CMPSI + INV BNE
(define_peephole
  [(set (cc0)
	(compare (match_operand:SI 0 "general_operand" "r")
		 (match_operand:SI 1 "general_operand" "r")))
   (set (pc)
	(if_then_else (eq (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 2 "" ""))))]
  ""
  "bne \\t%0,%1,%l2\\t#bne inverted primitive insn")

					;;- MERGED CMPSI + BGT
(define_peephole
  [(set (cc0)
	(compare (match_operand:SI 0 "general_operand" "r")
		 (match_operand:SI 1 "general_operand" "r")))
   (set (pc)
	(if_then_else (gt (cc0)
			  (const_int 0))
		      (label_ref (match_operand 2 "" ""))
		      (pc)))]
  ""
  "bgt \\t%0,%1,%l2\\t#bgt MIPS composite insn")

					;;- MERGED CMPSI + INV BGT
(define_peephole
  [(set (cc0)
	(compare (match_operand:SI 0 "general_operand" "r")
		 (match_operand:SI 1 "general_operand" "r")))
   (set (pc)
	(if_then_else (le (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 2 "" ""))))]
  ""
  "bgt \\t%0,%1,%l2\\t#bgt inverted composite insn")
					;;- MERGED CMPSI + BLT
(define_peephole
  [(set (cc0)
	(compare (match_operand:SI 0 "general_operand" "r")
		 (match_operand:SI 1 "general_operand" "r")))
   (set (pc)
	(if_then_else (lt (cc0)
			  (const_int 0))
		      (label_ref (match_operand 2 "" ""))
		      (pc)))]
  ""
  "blt \\t%0,%1,%l2\\t#blt MIPS composite insn")

					;;- MERGED CMPSI + INV BLT
(define_peephole
  [(set (cc0)
	(compare (match_operand:SI 0 "general_operand" "r")
		 (match_operand:SI 1 "general_operand" "r")))
   (set (pc)
	(if_then_else (ge (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 2 "" ""))))]
  ""
  "blt \\t%0,%1,%l2\\t#blt inverted composite insn")
					;;- MERGED CMPSI + BGE
(define_peephole
  [(set (cc0)
	(compare (match_operand:SI 0 "general_operand" "r")
		 (match_operand:SI 1 "general_operand" "r")))
   (set (pc)
	(if_then_else (ge (cc0)
			  (const_int 0))
		      (label_ref (match_operand 2 "" ""))
		      (pc)))]
  ""
  "bge \\t%0,%1,%l2\\t#bge composite insn")

					;;- MERGED CMPSI + INV BGE
(define_peephole
  [(set (cc0)
	(compare (match_operand:SI 0 "general_operand" "r")
		 (match_operand:SI 1 "general_operand" "r")))
   (set (pc)
	(if_then_else (lt (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 2 "" ""))))]
  ""
  "bge \\t%0,%1,%l2\\t#bge inverted composite insn")
					;;- MERGED CMPSI + BLE
(define_peephole
  [(set (cc0)
	(compare (match_operand:SI 0 "general_operand" "r")
		 (match_operand:SI 1 "general_operand" "r")))
   (set (pc)
	(if_then_else (le (cc0)
			  (const_int 0))
		      (label_ref (match_operand 2 "" ""))
		      (pc)))]
  ""
  "ble \\t%0,%1,%l2\\t#ble composite insn")

					;;- MERGED CMPSI + INV BLE
(define_peephole
  [(set (cc0)
	(compare (match_operand:SI 0 "general_operand" "r")
		 (match_operand:SI 1 "general_operand" "r")))
   (set (pc)
	(if_then_else (gt (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 2 "" ""))))]
  ""
  "ble \\t%0,%1,%l2\\t#ble inverted composite insn")


					;;- MERGED CMPSI + BGT
(define_peephole
  [(set (cc0)
	(compare (match_operand:SI 0 "general_operand" "r")
		 (match_operand:SI 1 "general_operand" "r")))
   (set (pc)
	(if_then_else (gtu (cc0)
			   (const_int 0))
		      (label_ref (match_operand 2 "" ""))
		      (pc)))]
  ""
  "bgtu \\t%0,%1,%l2\\t#bgtu MIPS composite insn")

					;;- MERGED CMPSI + INV BGT
(define_peephole
  [(set (cc0)
	(compare (match_operand:SI 0 "general_operand" "r")
		 (match_operand:SI 1 "general_operand" "r")))
   (set (pc)
	(if_then_else (leu (cc0)
			   (const_int 0))
		      (pc)
		      (label_ref (match_operand 2 "" ""))))]
  ""
  "bgtu \\t%0,%1,%l2\\t#bgtu inverted composite insn")
					;;- MERGED CMPSI + INV BLTU
(define_peephole
  [(set (cc0)
	(compare (match_operand:SI 0 "general_operand" "r")
		 (match_operand:SI 1 "general_operand" "r")))
   (set (pc)
	(if_then_else (geu (cc0)
			   (const_int 0))
		      (pc)
		      (label_ref (match_operand 2 "" ""))))]
  ""
  "bltu \\t%0,%1,%l2\\t#blt inverted composite insn")
					;;- MERGED CMPSI + BGEU
(define_peephole
  [(set (cc0)
	(compare (match_operand:SI 0 "general_operand" "r")
		 (match_operand:SI 1 "general_operand" "r")))
   (set (pc)
	(if_then_else (geu (cc0)
			   (const_int 0))
		      (label_ref (match_operand 2 "" ""))
		      (pc)))]
  ""
  "bgeu \\t%0,%1,%l2\\t#bgeu composite insn")

					;;- MERGED CMPSI + INV BGEU
(define_peephole
  [(set (cc0)
	(compare (match_operand:SI 0 "general_operand" "r")
		 (match_operand:SI 1 "general_operand" "r")))
   (set (pc)
	(if_then_else (ltu (cc0)
			   (const_int 0))
		      (pc)
		      (label_ref (match_operand 2 "" ""))))]
  ""
  "bgeu \\t%0,%1,%l2\\t#bgeu inverted composite insn")
					;;- MERGED CMPSI + BLE
(define_peephole
  [(set (cc0)
	(compare (match_operand:SI 0 "general_operand" "r")
		 (match_operand:SI 1 "general_operand" "r")))
   (set (pc)
	(if_then_else (leu (cc0)
			   (const_int 0))
		      (label_ref (match_operand 2 "" ""))
		      (pc)))]
  ""
  "bleu \\t%0,%1,%l2\\t#bleu composite insn")

					;;- MERGED CMPSI + INV BLE
(define_peephole
  [(set (cc0)
	(compare (match_operand:SI 0 "general_operand" "r")
		 (match_operand:SI 1 "general_operand" "r")))
   (set (pc)
	(if_then_else (gtu (cc0)
			   (const_int 0))
		      (pc)
		      (label_ref (match_operand 2 "" ""))))]
  ""
  "bleu \\t%0,%1,%l2\\t#bleu inverted composite insn")
					;;- MERGED CMPSI + BLTU
(define_peephole
  [(set (cc0)
	(compare (match_operand:SI 0 "general_operand" "r")
		 (match_operand:SI 1 "general_operand" "r")))
   (set (pc)
	(if_then_else (ltu (cc0)
			   (const_int 0))
		      (label_ref (match_operand 2 "" ""))
		      (pc)))]
  ""
  "bltu \\t%0,%1,%l2\\t#bltu MIPS composite insn")

					;;- MERGED CMPSI + INV BLTU
(define_peephole
  [(set (cc0)
	(compare (match_operand:SI 0 "general_operand" "r")
		 (match_operand:SI 1 "general_operand" "r")))
   (set (pc)
	(if_then_else (geu (cc0)
			   (const_int 0))
		      (pc)
		      (label_ref (match_operand 2 "" ""))))]
  ""
  "bltu \\t%0,%1,%l2\\t#bltu inverted composite insn")

					;;- FLOATING POINT CASES
					;;- --------------------

					;;- MERGED CMPSF + BEQ
(define_peephole
  [(set (cc0)
	(compare (match_operand:SF 0 "general_operand" "f")
		 (match_operand:SF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (eq (cc0)
			  (const_int 0))
		      (label_ref (match_operand 2 "" ""))
		      (pc)))]
  ""
  "c.eq.s\\t%0,%1\\t# Merged CMPSF + BEQ \;bc1t\\t%l2\\t# Merged CMPSF + BEQ ")

					;;- MERGED CMPSF + INV BEQ

(define_peephole
  [(set (cc0)
	(compare (match_operand:SF 0 "general_operand" "f")
		 (match_operand:SF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (ne (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 2 "" ""))))]
  ""
  "c.eq.s\\t%0,%1\\t# Merged CMPSF + BEQ \;bc1t\\t%l2\\t# Merged CMPSF + BEQ ")

					;;- MERGED CMPSF + BNE

(define_peephole
  [(set (cc0)
	(compare (match_operand:SF 0 "general_operand" "f")
		 (match_operand:SF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (ne (cc0)
			  (const_int 0))
		      (label_ref (match_operand 2 "" ""))
		      (pc)))]
  ""
  "c.eq.s\\t%0,%1\\t# Merged CMPSF + BNE \;bc1f\\t%l2\\t# Merged CMPSF + BNE ")

					;;- MERGED CMPSF + INV BNE
(define_peephole
  [(set (cc0)
	(compare (match_operand:SF 0 "general_operand" "f")
		 (match_operand:SF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (eq (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 2 "" ""))))]
  ""
  "c.eq.s\\t%0,%1\\t# Merged CMPSF + I.BNE \;bc1f\\t%l2\\t# Merged CMPSF +I.BNE ")

					;;- MERGED CMPSF + BGT
(define_peephole
  [(set (cc0)
	(compare (match_operand:SF 0 "general_operand" "f")
		 (match_operand:SF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (gt (cc0)
			  (const_int 0))
		      (label_ref (match_operand 2 "" ""))
		      (pc)))]
  ""
  "c.le.s\\t%0,%1\\t# Merged CMPSF + BGT \;bc1f\\t%l2\\t# Merged CMPSF + BGT ")

					;;- MERGED CMPSF + INV BGT
(define_peephole
  [(set (cc0)
	(compare (match_operand:SF 0 "general_operand" "f")
		 (match_operand:SF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (le (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 2 "" ""))))]
  ""
  "c.le.s\\t%0,%1\\t# Merged CMPSF + I.BGT \;bc1f\\t%l2\\t# Merged CMPSF +I. BGT ")

					;;- MERGED CMPSF + BLT
(define_peephole
  [(set (cc0)
	(compare (match_operand:SF 0 "general_operand" "f")
		 (match_operand:SF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (lt (cc0)
			  (const_int 0))
		      (label_ref (match_operand 2 "" ""))
		      (pc)))]
  ""
  "c.lt.s\\t%0,%1\\t# Merged CMPSF + BLT \;bc1t\\t%l2\\t# Merged CMPSF + BLT ")

					;;- MERGED CMPSF + INV BLT
(define_peephole
  [(set (cc0)
	(compare (match_operand:SF 0 "general_operand" "f")
		 (match_operand:SF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (ge (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 2 "" ""))))]
  ""
  "c.lt.s\\t%0,%1\\t# Merged CMPSF + I.BLT \;bc1t\\t%l2\\t# Merged CMPSF + I.BLT ")

					;;- MERGED CMPSF + BGE
(define_peephole
  [(set (cc0)
	(compare (match_operand:SF 0 "general_operand" "f")
		 (match_operand:SF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (ge (cc0)
			  (const_int 0))
		      (label_ref (match_operand 2 "" ""))
		      (pc)))]
  ""
  "c.lt.s\\t%0,%1\\t# Merged CMPSF + BGE \;bc1f\\t%l2\\t# Merged CMPSF + BGE")

					;;- MERGED CMPSF + INV BGE
(define_peephole
  [(set (cc0)
	(compare (match_operand:SF 0 "general_operand" "f")
		 (match_operand:SF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (lt (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 2 "" ""))))]
  ""
  "c.lt.s\\t%0,%1\\t# Merged CMPSF +INV  BGE \;bc1f\\t%l2\\t# Merged CMPSF +INV BGE ")
					;;- MERGED CMPSF + BLE
(define_peephole
  [(set (cc0)
	(compare (match_operand:SF 0 "general_operand" "f")
		 (match_operand:SF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (le (cc0)
			  (const_int 0))
		      (label_ref (match_operand 2 "" ""))
		      (pc)))]
  ""
  "c.le.s\\t%0,%1\\t# Merged CMPSF + BLE \;bc1t\\t%l2\\t# Merged CMPSF + BLE ")

					;;- MERGED CMPSF + INV BLE
(define_peephole
  [(set (cc0)
	(compare (match_operand:SF 0 "general_operand" "f")
		 (match_operand:SF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (gt (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 2 "" ""))))]
  ""
  "c.le.s\\t%0,%1\\t# Merged CMPSF + INV BLE \;bc1t\\t%l2\\t# Merged CMPSF +I. BLE")

					;;- DOUBLE FLOATING POINT CASES
					;;- --------------------

					;;- MERGED CMPDF + BEQ

(define_peephole
  [(set (cc0)
	(compare (match_operand:DF 0 "general_operand" "f")
		 (match_operand:DF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (eq (cc0)
			  (const_int 0))
		      (label_ref (match_operand 2 "" ""))
		      (pc)))]
  ""
  "c.eq.d\\t%0,%1\\t# Merged CMPDF + BEQ \;bc1t\\t%l2\\t# Merged CMPDF + BEQ ")

					;;- MERGED CMPDF + INV BEQ

(define_peephole
  [(set (cc0)
	(compare (match_operand:DF 0 "general_operand" "f")
		 (match_operand:DF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (ne (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 2 "" ""))))]
  ""
  "c.eq.d\\t%0,%1\\t# Merged CMPDF + I.BEQ \;bc1t\\t%l2\\t# Merged CMPDF +I. BEQ ")

					;;- MERGED CMPDF + BNE

(define_peephole
  [(set (cc0)
	(compare (match_operand:DF 0 "general_operand" "f")
		 (match_operand:DF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (ne (cc0)
			  (const_int 0))
		      (label_ref (match_operand 2 "" ""))
		      (pc)))]
  ""
  "c.eq.d\\t%0,%1\\t# Merged CMPDF + BNE \;bc1f\\t%l2\\t# Merged CMPDF + BNE ")

					;;- MERGED CMPDF + INV BNE
(define_peephole
  [(set (cc0)
	(compare (match_operand:DF 0 "general_operand" "f")
		 (match_operand:DF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (eq (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 2 "" ""))))]
  ""
  "c.eq.d\\t%0,%1\\t# Merged CMPDF +I. BNE \;bc1f\\t%l2\\t# Merged CMPDF +I BNE")

					;;- MERGED CMPDF + BGT
(define_peephole
  [(set (cc0)
	(compare (match_operand:DF 0 "general_operand" "f")
		 (match_operand:DF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (gt (cc0)
			  (const_int 0))
		      (label_ref (match_operand 2 "" ""))
		      (pc)))]
  ""
  "c.le.d\\t%0,%1\\t# Merged CMPDF + BGT \;bc1f\\t%l2\\t# Merged CMPDF + BGT ")

					;;- MERGED CMPDF + INV BGT
(define_peephole
  [(set (cc0)
	(compare (match_operand:DF 0 "general_operand" "f")
		 (match_operand:DF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (le (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 2 "" ""))))]
  ""
  "c.le.d\\t%0,%1\\t# Merged CMPDF + I. BGT \;bc1f\\t%l2\\t# Merged CMPDF + I. BGT ")

					;;- MERGED CMPDF + BLT
(define_peephole
  [(set (cc0)
	(compare (match_operand:DF 0 "general_operand" "f")
		 (match_operand:DF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (lt (cc0)
			  (const_int 0))
		      (label_ref (match_operand 2 "" ""))
		      (pc)))]
  ""
  "c.lt.d\\t%0,%1\\t# Merged CMPDF + BLT \;bc1t\\t%l2\\t# Merged CMPDF + BLT ")

					;;- MERGED CMPDF + INV BLT
(define_peephole
  [(set (cc0)
	(compare (match_operand:DF 0 "general_operand" "f")
		 (match_operand:DF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (ge (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 2 "" ""))))]
  ""
  "c.lt.d\\t%0,%1\\t# Merged CMPDF + I.BLT \;bc1t\\t%l2\\t# Merged CMPDF + I.BLT")

					;;- MERGED CMPDF + BGE
(define_peephole
  [(set (cc0)
	(compare (match_operand:DF 0 "general_operand" "f")
		 (match_operand:DF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (ge (cc0)
			  (const_int 0))
		      (label_ref (match_operand 2 "" ""))
		      (pc)))]
  ""
  "c.lt.d\\t%0,%1\\t# Merged CMPDF + BGE \;bc1f\\t%l2\\t# Merged CMPDF + BGE")

					;;- MERGED CMPDF + INV BGE
(define_peephole
  [(set (cc0)
	(compare (match_operand:DF 0 "general_operand" "f")
		 (match_operand:DF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (lt (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 2 "" ""))))]
  ""
  "c.lt.d\\t%0,%1\\t# Merged CMPDF +I. BGE \;bc1f\\t%l2\\t# Merged CMPDF +I. BGE")
					;;- MERGED CMPDF + BLE
(define_peephole
  [(set (cc0)
	(compare (match_operand:DF 0 "general_operand" "f")
		 (match_operand:DF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (le (cc0)
			  (const_int 0))
		      (label_ref (match_operand 2 "" ""))
		      (pc)))]
  ""
  "c.le.d\\t%0,%1\\t# Merged CMPDF + BLE \;bc1t\\t%l2\\t# Merged CMPDF + BLE ")

					;;- MERGED CMPDF + INV BLE
(define_peephole
  [(set (cc0)
	(compare (match_operand:DF 0 "general_operand" "f")
		 (match_operand:DF 1 "general_operand" "f")))
   (set (pc)
	(if_then_else (gt (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 2 "" ""))))]
  ""
  "c.le.d\\t%0,%1\\t# Merged CMPDF +I. BLE \;bc1t\\t%l2\\t# Merged CMPDF + I.BLE ")




;;
;;  ....................
;;
;;          COMPARISONS
;;
;;  ....................

					;;- Order is significant here
					;;- because there are untyped
					;;- comparisons generated by
					;;- the optimizer
                                        ;;- (set (cc0)
                                        ;;-      (compare (const_int 2)
                                        ;;-           (const_int 1)))

(define_insn "cmpsi"
  [(set (cc0)
	(compare (match_operand:SI 0 "register_operand" "r")
		 (match_operand:SI 1 "register_operand" "r")))]
  ""
  "*
    compare_collect (SImode, operands[0], operands[1]);
    return \" #\\tcmpsi\\t%0,%1\";
")

;; These patterns are hopelessly invalid, because
;; comparing subword values properly requires extending them.

;; (define_insn "cmphi"
;;   [(set (cc0)
;; 	(compare (match_operand:HI 0 "general_operand" "r")
;; 		 (match_operand:HI 1 "general_operand" "r")))]
;;   ""
;;   "*
;;     compare_collect (HImode, operands[0], operands[1]);
;;     return      \" #\\tcmphi\\t%0,%1\";
;;   ")
;; 
;; (define_insn "cmpqi"
;;   [(set (cc0)
;; 	(compare (match_operand:QI 0 "general_operand" "r")
;; 		 (match_operand:QI 1 "general_operand" "r")))]
;;   ""
;;   "*
;;     compare_collect (QImode, operands[0], operands[1]);
;;     return      \" #\\tcmpqi\\t%0,%1\";
;;   ")

(define_insn "cmpdf"
  [(set (cc0)
	(compare (match_operand:DF 0 "register_operand" "f")
		 (match_operand:DF 1 "register_operand" "f")))]
  ""
  "*
    compare_collect (DFmode, operands[0], operands[1]);
    return \" #\\tcmpdf\\t%0,%1\" ;
")

(define_insn "cmpsf"
  [(set (cc0)
	(compare (match_operand:SF 0 "register_operand" "f")
		 (match_operand:SF 1 "register_operand" "f")))]
  ""
  "*
    compare_collect (SFmode, operands[0], operands[1]);
    return \" #\\tcmpsf\\t%0,%1\" ;
")

(define_insn ""
  [(set (cc0)
	(match_operand:QI 0 "general_operand" "r"))]
  ""
  "*
    compare_collect (QImode, operands[0], gen_rtx (REG, QImode, 0));
    return \" #\\t (set (cc0)\\t%0)\";
")

(define_insn ""
  [(set (cc0)
	(match_operand:HI 0 "general_operand" "r"))]
  ""
  "*
    compare_collect (HImode, operands[0], gen_rtx (REG, HImode, 0));
    return \" #\\t (set (cc0)\\t%0)\";
")

(define_insn ""
  [(set (cc0)
	(match_operand:SI 0 "general_operand" "r"))]
  ""
  "*
    compare_collect (SImode, operands[0], gen_rtx (REG, SImode, 0));
    return \" #\\t (set (cc0)\\t%0)\";
")

;;
;;  ....................
;;
;;          BRANCHES
;;
;;  ....................

(define_insn "jump"
  [(set (pc)
	(label_ref (match_operand 0 "" "")))]
  ""
  "*
{
  if (GET_CODE (operands[0]) == REG)
    return \"j\\t%%0\\t#jump %l0 (jr not asm syntax)\";
  else
    return \"j\\t%l0\\t#jump %l0\";
}")


(define_insn "beq"
  [(set (pc)
	(if_then_else (eq (cc0)
			  (const_int 0))
		      (label_ref (match_operand 0 "" ""))
		      (pc)))]
  ""
  "*
{
  rtx br_ops[3];
  enum machine_mode mode;
  compare_restore (br_ops,  &mode, insn);
  br_ops[2] = operands[0];
  if (mode == DFmode)
    {
      output_asm_insn (\"c.eq.d\\t%0,%1\\t#beq\", br_ops);
      output_asm_insn (\"bc1t\\t%2\\t#beq\", br_ops);
    }
  else if  (mode == SFmode)
    {
      output_asm_insn (\"c.eq.s\\t%0,%1\\t#beq\", br_ops);
      output_asm_insn (\"bc1t\\t%2\\t#beq\", br_ops);
    }
  else
    {
      output_asm_insn (\"beq\\t%0,%1,%2\\t#beq\", br_ops);
    }
  return \"\";
}
   ")

(define_insn "bne"
  [(set (pc)
	(if_then_else (ne (cc0)
			  (const_int 0))
		      (label_ref (match_operand 0 "" ""))
		      (pc)))]
  ""
  "*
{
  rtx br_ops[3];
  enum machine_mode mode;
  compare_restore (br_ops,  &mode, insn);
  br_ops[2] = operands[0];
  if (mode == DFmode)
    {
      output_asm_insn (\"c.eq.d\\t%0,%1\\t#bne\", br_ops);
      output_asm_insn (\"bc1f\\t%2\\t#bne\", br_ops);
    }
  else if  (mode == SFmode)
    {
      output_asm_insn (\"c.eq.s\\t%0,%1\\t#bne\", br_ops);
      output_asm_insn (\"bc1f\\t%2\\t#bne\", br_ops);
    }
  else
    {
      output_asm_insn (\"bne\\t%0,%1,%2\\t#bne\", br_ops);
    }
  return \"\";
}

")

(define_insn "bgt"
  [(set (pc)
	(if_then_else (gt (cc0)
			  (const_int 0))
		      (label_ref (match_operand 0 "" ""))
		      (pc)))]
  ""
  "*
{
  rtx br_ops[3];
  enum machine_mode mode;
  compare_restore (br_ops,  &mode, insn);
  br_ops[2] = operands[0];
  if (mode == DFmode)
    {
      output_asm_insn (\"c.le.d\\t%0,%1\\t#bgt branch %0 > %1\", br_ops);
      output_asm_insn (\"bc1f\\t%2\\t#bgt\", br_ops);
    }
  else if  (mode == SFmode)
    {
      output_asm_insn (\"c.le.s\\t%0,%1\\t#bgt branch %0 > %1\", br_ops);
      output_asm_insn (\"bc1f\\t%2\\t#bgt\", br_ops);
    }
  else
    {
      output_asm_insn (\"bgt\\t%0,%1,%2\\t#bgt\", br_ops);
    }
  return \"\";
}

")

(define_insn "blt"
  [(set (pc)
	(if_then_else (lt (cc0)
			  (const_int 0))
		      (label_ref (match_operand 0 "" ""))
		      (pc)))]
  ""
  "*
{
  rtx br_ops[3];
  enum machine_mode mode;
  compare_restore (br_ops,  &mode, insn);
  br_ops[2] = operands[0];
  if (mode == DFmode)
    {
      output_asm_insn (\"c.lt.d\\t%0,%1\\t#blt\", br_ops);
      output_asm_insn (\"bc1t\\t%2\\t#blt\", br_ops);
    }
  else if  (mode == SFmode)
    {
      output_asm_insn (\"c.lt.s\\t%0,%1\\t#blt\", br_ops);
      output_asm_insn (\"bc1t\\t%2\\t#blt\", br_ops);
    }
  else
    {
      output_asm_insn (\"blt\\t%0,%1,%2\\t#blt\", br_ops);
    }
  return \" #\\tblt \\t%l0\\t#blt\";
}
")

(define_insn "bgtu"
  [(set (pc)
	(if_then_else (gtu (cc0)
			   (const_int 0))
		      (label_ref (match_operand 0 "" ""))
		      (pc)))]
  ""
  "*
{
  rtx br_ops[3];
  enum machine_mode mode;
  compare_restore (br_ops,  &mode, insn);
  br_ops[2] = operands[0];
  if (mode == DFmode)
    {
      output_asm_insn (\"c.le.d\\t%0,%1\\t#bgtu\", br_ops);
      output_asm_insn (\"bc1f\\t%2\\t#bgtu\", br_ops);
    }
  else if  (mode == SFmode)
    {
      output_asm_insn (\"c.le.s\\t%0,%1\\t#bgtu\", br_ops);
      output_asm_insn (\"bc1f\\t%2\\t#bgtu\", br_ops);
    }
  else
    {
      output_asm_insn (\"bgtu\\t%0,%1,%2\\t#bgtu\", br_ops);
    }
  return \" #\\tbgtu \\t%l0\\t#bgtu\";
}

")

(define_insn "bltu"
  [(set (pc)
	(if_then_else (ltu (cc0)
			   (const_int 0))
		      (label_ref (match_operand 0 "" ""))
		      (pc)))]
  ""
  "*
{
  rtx br_ops[3];
  enum machine_mode mode;
  compare_restore (br_ops,  &mode, insn);
  br_ops[2] = operands[0];
  if (mode == DFmode)
    {
      output_asm_insn (\"c.lt.d\\t%0,%1\\t#bltu\", br_ops);
      output_asm_insn (\"bc1t\\t%2\\t#bltu\", br_ops);
    }
  else if  (mode == SFmode)
    {
      output_asm_insn (\"c.lt.s\\t%0,%1\\t#bltu\", br_ops);
      output_asm_insn (\"bc1t\\t%2\\t#bltu\", br_ops);
    }
  else
    {
      output_asm_insn (\"bltu\\t%0,%1,%2\\t#bltu\", br_ops);
    }
  return \"\";
}
")

(define_insn "bge"
  [(set (pc)
	(if_then_else (ge (cc0)
			  (const_int 0))
		      (label_ref (match_operand 0 "" ""))
		      (pc)))]
  ""
  "*
{
  rtx br_ops[3];
  enum machine_mode mode;
  compare_restore (br_ops,  &mode, insn);
  br_ops[2] = operands[0];
  if (mode == DFmode)
    {
      output_asm_insn (\"c.lt.d\\t%0,%1\\t#bge\", br_ops);
      output_asm_insn (\"bc1f\\t%2\\t#bge\", br_ops);
    }
  else if  (mode == SFmode)
    {
      output_asm_insn (\"c.lt.s\\t%0,%1\\t#bge\", br_ops);
      output_asm_insn (\"bc1f\\t%2\\t#bge\", br_ops);
    }
  else
    {
      output_asm_insn (\"bge\\t%0,%1,%2\\t#bge\", br_ops);
    }
  return \"\";
}
")

(define_insn "bgeu"
  [(set (pc)
	(if_then_else (geu (cc0)
			   (const_int 0))
		      (label_ref (match_operand 0 "" ""))
		      (pc)))]
  ""
  "*
{
  rtx br_ops[3];
  enum machine_mode mode;
  compare_restore (br_ops,  &mode, insn);
  br_ops[2] = operands[0];
  if (mode == DFmode)
    {
      output_asm_insn (\"c.lt.d\\t%0,%1\\t#bgeu\", br_ops);
      output_asm_insn (\"bc1f\\t%2\\t#bgeu\", br_ops);
    }
  else if  (mode == SFmode)
    {
      output_asm_insn (\"c.lt.s\\t%0,%1\\t#bgeu\", br_ops);
      output_asm_insn (\"bc1f\\t%2\\t#bgeu\", br_ops);
    }
  else
    {
      output_asm_insn (\"bgeu\\t%0,%1,%2\\t#bgeu\", br_ops);
    }
  return \"\";
}
")

(define_insn "ble"
  [(set (pc)
	(if_then_else (le (cc0)
			  (const_int 0))
		      (label_ref (match_operand 0 "" ""))
		      (pc)))]
  ""
  "*
{
  rtx br_ops[3];
  enum machine_mode mode;
  compare_restore (br_ops,  &mode, insn);
  br_ops[2] = operands[0];
  if (mode == DFmode)
    {
      output_asm_insn (\"c.le.d\\t%0,%1\\t#ble\", br_ops);
      output_asm_insn (\"bc1t\\t%2\\t#ble\", br_ops);
    }
  else if  (mode == SFmode)
    {
      output_asm_insn (\"c.le.s\\t%0,%1\\t#ble\", br_ops);
      output_asm_insn (\"bc1t\\t%2\\t#ble\", br_ops);
    }
  else
    {
      output_asm_insn (\"ble\\t%0,%1,%2\\t#ble\", br_ops);
    }
  return \"\";
}
")

(define_insn "bleu"
  [(set (pc)
	(if_then_else (leu (cc0)
			  (const_int 0))
		      (label_ref (match_operand 0 "" ""))
		      (pc)))]
  ""
  "*
{
  rtx br_ops[3];
  enum machine_mode mode;
  compare_restore (br_ops,  &mode, insn);
  br_ops[2] = operands[0];
  if (mode == DFmode)
    {
      output_asm_insn (\"c.le.d\\t%0,%1\\t#ble\", br_ops);
      output_asm_insn (\"bc1t\\t%2\\t#ble\", br_ops);
    }
  else if  (mode == SFmode)
    {
      output_asm_insn (\"c.le.s\\t%0,%1\\t#ble\", br_ops);
      output_asm_insn (\"bc1t\\t%2\\t#ble\", br_ops);
    }
  else
    {
      output_asm_insn (\"bleu\\t%0,%1,%2\\t#bleu\", br_ops);
    }
  return \" #\\tbleu \\t%l0\\t#bleu\";
}
")

(define_insn ""
  [(set (pc)
	(if_then_else (ne (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 0 "" ""))))]
  ""
  "*
{
  rtx br_ops[3];
  enum machine_mode mode;
  compare_restore (br_ops,  &mode, insn);
  br_ops[2] = operands[0];
  if (mode == DFmode)
    {
      output_asm_insn (\"c.eq.d\\t%0,%1\\t#beq\", br_ops);
      output_asm_insn (\"bc1t\\t%2\\t#beq\", br_ops);
    }
  else if  (mode == SFmode)
    {
      output_asm_insn (\"c.eq.s\\t%0,%1\\t#beq\", br_ops);
      output_asm_insn (\"bc1t\\t%2\\t#beq\", br_ops);
    }
  else
    {
      output_asm_insn (\"beq\\t%0,%1,%2\\t#beq Inv.\", br_ops);
    }
  return \"\";
}
")

(define_insn ""
  [(set (pc)
	(if_then_else (eq (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 0 "" ""))))]
  ""
  "*
{
  rtx br_ops[3];
  enum machine_mode mode;
  compare_restore (br_ops,  &mode, insn);
  br_ops[2] = operands[0];
  if (mode == DFmode)
    {
      output_asm_insn (\"c.eq.d\\t%0,%1\\t#bne\", br_ops);
      output_asm_insn (\"bc1f\\t%2\\t#bne\", br_ops);
    }
  else if  (mode == SFmode)
    {
      output_asm_insn (\"c.eq.s\\t%0,%1\\t#bne\", br_ops);
      output_asm_insn (\"bc1f\\t%2\\t#beq\", br_ops);
    }
  else
    {
      output_asm_insn (\"bne\\t%0,%1,%2\\t#bne Inv.\", br_ops);
    }
  return \"\";
}

")

(define_insn ""
  [(set (pc)
	(if_then_else (le (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 0 "" ""))))]
  ""
  "*
{
  rtx br_ops[3];
  enum machine_mode mode;
  compare_restore (br_ops,  &mode, insn);
  br_ops[2] = operands[0];
  if (mode == DFmode)
    {
      output_asm_insn (\"c.le.d\\t%0,%1\\t#bgt\", br_ops);
      output_asm_insn (\"bc1f\\t%2\\t#beq\", br_ops);
    }
  else if  (mode == SFmode)
    {
      output_asm_insn (\"c.le.s\\t%0,%1\\t#bgt\", br_ops);
      output_asm_insn (\"bc1f\\t%2\\t#beq\", br_ops);
    }
  else
    {
      output_asm_insn (\"bgt\\t%0,%1,%2\\t#bgt Inv.\", br_ops);
    }
  return \"\";
}
")

(define_insn ""
  [(set (pc)
	(if_then_else (leu (cc0)
			   (const_int 0))
		      (pc)
		      (label_ref (match_operand 0 "" ""))))]
  ""
  "*
{
  rtx br_ops[3];
  enum machine_mode mode;
  compare_restore (br_ops,  &mode, insn);
  br_ops[2] = operands[0];
  if (mode == DFmode)
    {
      output_asm_insn (\"c.le.d\\t%0,%1\\t#bgt\", br_ops);
      output_asm_insn (\"bc1f\\t%2\\t#beq\", br_ops);
    }
  else if  (mode == SFmode)
    {
      output_asm_insn (\"c.le.s\\t%0,%1\\t#bgt\", br_ops);
      output_asm_insn (\"bc1f\\t%2\\t#beq\", br_ops);
    }
  else
    {
      output_asm_insn (\"bgtu\\t%0,%1,%2\\t#bgtu Inv.\", br_ops);
    }
  return \" #\\tbgtu \\t%l0\\t#bgtu\";
}
")

(define_insn ""
  [(set (pc)
	(if_then_else (ge (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 0 "" ""))))]
  ""
  "*
{
  rtx br_ops[3];
  enum machine_mode mode;
  compare_restore (br_ops,  &mode, insn);
  br_ops[2] = operands[0];
  if (mode == DFmode)
    {
      output_asm_insn (\"c.lt.d\\t%0,%1\\t#blt\", br_ops);
      output_asm_insn (\"bc1t\\t%2\\t#beq\", br_ops);
    }
  else if  (mode == SFmode)
    {
      output_asm_insn (\"c.lt.s\\t%0,%1\\t#blt\", br_ops);
      output_asm_insn (\"bc1t\\t%2\\t#beq\", br_ops);
    }
  else
    {
      output_asm_insn (\"blt\\t%0,%1,%2\\t#blt Inv.\", br_ops);
    }
  return \"\";
}
")

(define_insn ""
  [(set (pc)
	(if_then_else (geu (cc0)
			   (const_int 0))
		      (pc)
		      (label_ref (match_operand 0 "" ""))))]
  ""
  "*
{
  rtx br_ops[3];
  enum machine_mode mode;
  compare_restore (br_ops,  &mode, insn);
  br_ops[2] = operands[0];
  if (mode == DFmode)
    {
      output_asm_insn (\"c.lt.d\\t%0,%1\\t#bltu\", br_ops);
      output_asm_insn (\"bc1t\\t%2\\t#bltu\", br_ops);
    }
  else if  (mode == SFmode)
    {
      output_asm_insn (\"c.lt.s\\t%0,%1\\t#bltu\", br_ops);
      output_asm_insn (\"bc1t\\t%2\\t#bltu\", br_ops);
    }
  else
    {
      output_asm_insn (\"bltu\\t%0,%1,%2\\t#bltu Inv.\", br_ops);
    }
  return \" #\\tbltu \\t%l0\\t#bltu\";
}
")

(define_insn ""
  [(set (pc)
	(if_then_else (lt (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 0 "" ""))))]
  ""
  "*
{
  rtx br_ops[3];
  enum machine_mode mode;
  compare_restore (br_ops,  &mode, insn);
  br_ops[2] = operands[0];
  if (mode == DFmode)
    {
      output_asm_insn (\"c.lt.d\\t%0,%1\\t#bge\", br_ops);
      output_asm_insn (\"bc1f\\t%2\\t#bge (DF) Inv.\", br_ops);
    }
  else if  (mode == SFmode)
    {
      output_asm_insn (\"c.lt.s\\t%0,%1\\t#bge\", br_ops);
      output_asm_insn (\"bc1f\\t%2\\t#bge (SF) Inv.\", br_ops);
    }
  else
    {
      output_asm_insn (\"bge\\t%0,%1,%2\\t#bge Inv.\", br_ops);
    }
  return \"\";
}
")

(define_insn ""
  [(set (pc)
	(if_then_else (ltu (cc0)
			   (const_int 0))
		      (pc)
		      (label_ref (match_operand 0 "" ""))))]
  ""
  "*
{
  rtx br_ops[3];
  enum machine_mode mode;
  compare_restore (br_ops,  &mode, insn);
  br_ops[2] = operands[0];
  if (mode == DFmode)
    {
      output_asm_insn (\"c.lt.d\\t%0,%1\\t#bge\", br_ops);
      output_asm_insn (\"bc1f\\t%2\\t#bgeu (DF)  Inv.\", br_ops);
    }
  else if  (mode == SFmode)
    {
      output_asm_insn (\"c.lt.s\\t%0,%1\\t#bge\", br_ops);
      output_asm_insn (\"bc1f\\t%2\\t#bgeu (SF )Inv.\", br_ops);
    }
  else
    {
      output_asm_insn (\"bgeu\\t%0,%1,%2\\t#bgeu Inv.\", br_ops);
    }
  return \" #\\tbgeu \\t%l0\\t#bgeu\";
}
")

(define_insn ""
  [(set (pc)
	(if_then_else (gt (cc0)
			  (const_int 0))
		      (pc)
		      (label_ref (match_operand 0 "" ""))))]
  ""
  "*
{
  rtx br_ops[3];
  enum machine_mode mode;
  compare_restore (br_ops,  &mode, insn);
  br_ops[2] = operands[0];
  if (mode == DFmode)
    {
      output_asm_insn (\"c.le.d\\t%0,%1\\t#ble\", br_ops);
      output_asm_insn (\"bc1t\\t%2\\t#ble\", br_ops);
    }
  else if  (mode == SFmode)
    {
      output_asm_insn (\"c.le.s\\t%0,%1\\t#ble\", br_ops);
      output_asm_insn (\"bc1t\\t%2\\t#ble\", br_ops);
    }
  else
    {
      output_asm_insn (\"ble\\t%0,%1,%2\\t#ble Inv.\", br_ops);
    }
  return \"\";
}
")

(define_insn ""
  [(set (pc)
	(if_then_else (gtu (cc0)
			   (const_int 0))
		      (pc)
		      (label_ref (match_operand 0 "" ""))))]
  ""
  "*
{
  rtx br_ops[3];
  enum machine_mode mode;
  compare_restore (br_ops,  &mode, insn);
  br_ops[2] = operands[0];
  if (mode == DFmode)
    {
      output_asm_insn (\"c.le.d\\t%0,%1\\t#bleu\", br_ops);
      output_asm_insn (\"bc1t\\t%2\\t#bleu\", br_ops);
    }
  else if  (mode == SFmode)
    {
      output_asm_insn (\"c.le.s\\t%0,%1\\t#bleu\", br_ops);
      output_asm_insn (\"bc1t\\t%2\\t#bleu\", br_ops);
    }
  else
    {
      output_asm_insn (\"bleu\\t%0,%1,%2\\t#bleu Inv.\", br_ops);
    }
  return \"\";
}
")

(define_insn "tablejump"
  [(set (pc)
	(match_operand:SI 0 "general_operand" "r"))
   (use (label_ref (match_operand 1 "" "")))]
  ""
  "j\\t%0\\t# tablejump, label %l1\\t (jr not asm syntax)")

;;
;;  ....................
;;
;;          LINKAGE
;;
;;  ....................

(define_insn "call"
  [(call (match_operand 0 "general_operand" "g")
	 (match_operand 1 "general_operand" "g"))
   (clobber (reg:SI 31))]
  ""
  "*
{
  if (GET_CODE (XEXP (operands[0], 0)) == SYMBOL_REF)
    return \"jal\\t%0\\t# call with %1 arguments\";
  else
    {
      operands[0] = XEXP (operands[0], 0);
      return \"jal\\t$31,%0\\t# call with  %1 arguments (reg)\";
    }
}" )


(define_expand "call_value"
  [(set (match_operand 0 "" "=rf")
	(call (match_operand:SI 1 "memory_operand" "m")
	      (match_operand 2 "" "i")))
   (clobber (reg:SI 31))]
  ;; operand 3 is next_arg_register
  ""
  "
{
  rtx fn_rtx, nregs_rtx;
  rtvec vec;

  fn_rtx = operands[1];

  nregs_rtx = const0_rtx;


  vec = gen_rtvec (2,
		   gen_rtx (SET, VOIDmode, operands[0],
			    gen_rtx (CALL, VOIDmode, fn_rtx, nregs_rtx)),
		   gen_rtx (CLOBBER, VOIDmode, gen_rtx (REG, SImode, 31)));

  emit_call_insn (gen_rtx (PARALLEL, VOIDmode, vec));
  DONE;
}")


(define_insn ""
  [(set (match_operand 0 "general_operand" "=g,f")
        (call (match_operand 1 "general_operand" "g,g")
              (match_operand 2 "general_operand" "g,g")))
   (clobber (match_operand 3 "general_operand" "g,g"))]
  ""
  "*
{
  if (GET_CODE (XEXP (operands[1], 0)) == SYMBOL_REF)
    return \"jal\\t%1\\t# call  %1  regle 2-call (VOIDmode)\";
  else
    {
      operands[1] = XEXP (operands[1], 0);
      return \"jal\\t$31,%1\\t# call %1 regle 2-call (VOIDmode, reg)\";
    }
}")

(define_insn "nop"
  [(const_int 0)]
  ""
  "nop")

(define_expand "probe"
  [(set (reg:SI 29) (minus:SI (reg:SI 29) (const_int 4)))
   (set (mem:SI (reg:SI 29)) (const_int 0))
   (set (reg:SI 29) (plus:SI (reg:SI 29) (const_int 4)))]
  ""
  "")

;;
;;- Local variables:
;;- mode:emacs-lisp
;;- comment-start: ";;- "
;;- eval: (set-syntax-table (copy-sequence (syntax-table)))
;;- eval: (modify-syntax-entry ?[ "(]")
;;- eval: (modify-syntax-entry ?] ")[")
;;- eval: (modify-syntax-entry ?{ "(}")
;;- eval: (modify-syntax-entry ?} "){")
;;- End:
