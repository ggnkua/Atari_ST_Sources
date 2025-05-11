/* Medium-level subroutines: convert bit-field store and extract
   and shifts, multiplies and divides to rtl instructions.
   Copyright (C) 1987, 1988 Free Software Foundation, Inc.

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


#include "config.h"
#include "rtl.h"
#include "tree.h"
#include "flags.h"
#include "insn-flags.h"
#include "insn-codes.h"
#include "insn-config.h"
#include "expr.h"
#include "recog.h"

static rtx extract_split_bit_field ();
static rtx extract_fixed_bit_field ();
static void store_split_bit_field ();
static void store_fixed_bit_field ();

/* Return an rtx representing minus the value of X.  */

rtx
negate_rtx (x)
     rtx x;
{
  if (GET_CODE (x) == CONST_INT)
    return gen_rtx (CONST_INT, VOIDmode, - INTVAL (x));
  else
    return expand_unop (GET_MODE (x), neg_optab, x, 0, 0);
}

/* Generate code to store value from rtx VALUE
   into a bit-field within structure STR_RTX
   containing BITSIZE bits starting at bit BITNUM.
   FIELDMODE is the machine-mode of the FIELD_DECL node for this field.  */

/* ??? This should really have the ability to copy a word into a register
   in order to store the bit-field into it, on machines whose insv insns
   work that way.  */

rtx
store_bit_field (str_rtx, bitsize, bitnum, fieldmode, value)
     rtx str_rtx;
     register int bitsize;
     int bitnum;
     enum machine_mode fieldmode;
     rtx value;
{
  int unit = (GET_CODE (str_rtx) == MEM) ? BITS_PER_UNIT : BITS_PER_WORD;
  register int offset = bitnum / unit;
  register int bitpos = bitnum % unit;
  register rtx op0 = str_rtx;
  rtx value1;

  if (GET_CODE (op0) == SUBREG)
    {
      offset += SUBREG_WORD (op0);
      op0 = SUBREG_REG (op0);
    }

  value = protect_from_queue (value, 0);

  if (flag_force_mem)
    value = force_not_mem (value);

  if (GET_MODE_SIZE (fieldmode) >= UNITS_PER_WORD)
    {
      /* Storing in a full-word or multi-word field in a register
	 can be done with just SUBREG.  */
      if (GET_MODE (op0) != fieldmode)
	op0 = gen_rtx (SUBREG, fieldmode, op0, offset);
      emit_move_insn (op0, value);
      return value;
    }

#ifdef BYTES_BIG_ENDIAN
  /* If OP0 is a register, BITPOS must count within a word.
     But as we have it, it counts within whatever size OP0 now has.
     On a bigendian machine, these are not the same, so convert.  */
  if (GET_CODE (op0) != MEM && unit > GET_MODE_BITSIZE (GET_MODE (op0)))
    bitpos += unit - GET_MODE_BITSIZE (GET_MODE (op0));
#endif

  /* Storing an lsb-aligned field in a register
     can be done with a movestrict instruction.  */

  if (GET_CODE (op0) != MEM
#ifdef BYTES_BIG_ENDIAN
      && bitpos + bitsize == unit
#else
      && bitpos == 0
#endif
      && (GET_MODE (op0) == fieldmode
	  || (movstrict_optab->handlers[(int) fieldmode].insn_code
	      != CODE_FOR_nothing)))
    {
      /* Get appropriate low part of the value being stored.  */
      if (GET_CODE (value) == CONST_INT || GET_CODE (value) == REG)
	value = gen_lowpart (fieldmode, value);
      else if (!(GET_CODE (value) == SYMBOL_REF
		 || GET_CODE (value) == LABEL_REF
		 || GET_CODE (value) == CONST))
	value = convert_to_mode (fieldmode, value, 0);

      if (GET_MODE (op0) == fieldmode)
	emit_move_insn (op0, value);
      else
	emit_insn (GEN_FCN (movstrict_optab->handlers[(int) fieldmode].insn_code)
		   (gen_rtx (SUBREG, fieldmode, op0, offset), value));

      return value;
    }

  /* From here on we can assume that the field to be stored in is an integer,
     since it is shorter than a word.  */

  /* OFFSET is the number of words or bytes (UNIT says which)
     from STR_RTX to the first word or byte containing part of the field.  */

  if (GET_CODE (op0) == REG)
    {
      if (offset != 0
	  || GET_MODE_SIZE (GET_MODE (op0)) > GET_MODE_SIZE (SImode))
	op0 = gen_rtx (SUBREG, SImode, op0, offset);
      offset = 0;
    }
  else
    {
      op0 = protect_from_queue (op0, 1);
    }

  /* Now OFFSET is nonzero only if OP0 is memory
     and is therefore always measured in bytes.  */

#ifdef HAVE_insv
  if (HAVE_insv
      && !(bitsize == 1 && GET_CODE (value) == CONST_INT))
    {
      enum machine_mode mode0 = GET_MODE (op0);

      /* Add OFFSET into OP0's address.  */
      if (GET_CODE (op0) == MEM)
	op0 = change_address (op0, QImode,
			      plus_constant (XEXP (op0, 0), offset));

      /* If op0 is a register, we need it in SImode
	 to make it acceptable to the format of insv.  */
      if (GET_CODE (op0) == SUBREG)
	PUT_MODE (op0, SImode);
      if (GET_CODE (op0) == REG && GET_MODE (op0) != SImode)
	op0 = gen_rtx (SUBREG, SImode, op0, 0);

      /* Convert VALUE to SImode (which insv insn wants) in VALUE1.  */
      value1 = value;
      if (GET_MODE (value) != SImode)
	{
	  if (GET_MODE_BITSIZE (GET_MODE (value)) >= bitsize)
	    {
	      if (GET_CODE (value) != REG)
		value1 = copy_to_reg (value);
	      /* Optimization: Don't bother really extending VALUE
		 if it has all the bits we will actually use.  */
	      value1 = gen_rtx (SUBREG, SImode, value1, 0);
	    }
	  else if (!CONSTANT_P (value))
	    /* Parse phase is supposed to make VALUE's data type
	       match that of the component reference, which is a type
	       at least as wide as the field; so VALUE should have
	       a mode that corresponds to that type.  */
	    abort ();
	}

      /* If this machine's insv insists on a register,
	 get VALUE1 into a register.  */
      if (! (*insn_operand_predicate[(int) CODE_FOR_insv][3]) (value1, SImode))
	value1 = force_reg (SImode, value1);

      /* On big-endian machines, we count bits from the most significant.
	 If the bit field insn does not, we must invert.  */

#if defined (BITS_BIG_ENDIAN) != defined (BYTES_BIG_ENDIAN)
      bitpos = unit - 1 - bitpos;
#endif

      emit_insn (gen_insv (op0,
			   gen_rtx (CONST_INT, VOIDmode, bitsize),
			   gen_rtx (CONST_INT, VOIDmode, bitpos),
			   value1));
    }
  else
#endif
    /* Insv is not available; store using shifts and boolean ops.  */
    store_fixed_bit_field (op0, offset, bitsize, bitpos, value);
  return value;
}

/* Use shifts and boolean operations to store VALUE
   into a bit field of width BITSIZE
   in a memory location specified by OP0 except offset by OFFSET bytes.
   The field starts at position BITPOS within the byte.
    (If OP0 is a register, it may be SImode or a narrower mode,
     but BITPOS still counts within a full word,
     which is significant on bigendian machines.)

   Note that protect_from_queue has already been done on OP0 and VALUE.  */

static void
store_fixed_bit_field (op0, offset, bitsize, bitpos, value)
     register rtx op0;
     register int offset, bitsize, bitpos;
     register rtx value;
{
  register enum machine_mode mode;
  int total_bits = BITS_PER_WORD;
  rtx subtarget;
  int all_zero = 0;
  int all_one = 0;

  /* Add OFFSET to OP0's address (if it is in memory)
     and if a single byte contains the whole bit field
     change OP0 to a byte.  */

  if (GET_CODE (op0) == REG || GET_CODE (op0) == SUBREG)
    {
      /* Special treatment for a bit field split across two registers.  */
      if (bitsize + bitpos > BITS_PER_WORD)
	{
	  store_split_bit_field (op0, bitsize, bitpos, value);
	  return;
	}
    }
  else if (bitsize + bitpos <= BITS_PER_UNIT
	   && ! SLOW_BYTE_ACCESS)
    {
      total_bits = BITS_PER_UNIT;
      op0 = change_address (op0, QImode, 
			    plus_constant (XEXP (op0, 0), offset));
    }
  else
    {
      /* Get ref to word containing the field.  */
      /* Adjust BITPOS to be position within a word,
	 and OFFSET to be the offset of that word.
	 Then alter OP0 to refer to that word.  */
      bitpos += (offset % (BITS_PER_WORD / BITS_PER_UNIT)) * BITS_PER_UNIT;
      offset -= (offset % (BITS_PER_WORD / BITS_PER_UNIT));
      op0 = change_address (op0, SImode,
			    plus_constant (XEXP (op0, 0), offset));
      /* Special treatment for a bit field split across two words.  */
      if (bitsize + bitpos > BITS_PER_WORD)
	{
	  store_split_bit_field (op0, bitsize, bitpos, value);
	  return;
	}
    }

  mode = GET_MODE (op0);

  /* Now OP0 is either a byte or a word, and the bit field is contained
     entirely within it.  TOTAL_BITS and MODE say which one (byte or word).
     BITPOS is the starting bit number within the byte or word.
     (If OP0 is a word, it may actually have a mode narrower than SImode.)  */

#ifdef BYTES_BIG_ENDIAN
  /* BITPOS is the distance between our msb
     and that of the containing byte or word.
     Convert it to the distance from the lsb.  */

  bitpos = total_bits - bitsize - bitpos;
#endif
  /* Now BITPOS is always the distance between our lsb
     and that of the containing byte or word.  */

  /* Shift VALUE left by BITPOS bits.  If VALUE is not constant,
     we must first convert its mode to MODE.  */

  if (GET_CODE (value) == CONST_INT)
    {
      register int v = INTVAL (value);

      if (bitsize < HOST_BITS_PER_INT)
	v &= (1 << bitsize) - 1;

      if (v == 0)
	all_zero = 1;
      else if (bitsize < HOST_BITS_PER_INT && v == (1 << bitsize) - 1)
	all_one = 1;

      value = gen_rtx (CONST_INT, VOIDmode, v << bitpos);
    }
  else
    {
      int must_and = (GET_MODE_BITSIZE (GET_MODE (value)) != bitsize);

      if (GET_MODE (value) != mode)
	{
	  if (GET_CODE (value) == REG && mode == QImode)
	    value = gen_rtx (SUBREG, mode, value, 0);
	  else
	    value = convert_to_mode (mode, value, 1);
	}

      if (must_and && bitsize < HOST_BITS_PER_INT)
	value = expand_bit_and (mode, value,
				gen_rtx (CONST_INT, VOIDmode,
					 (1 << bitsize) - 1),
				0);
      if (bitpos > 0)
	value = expand_shift (LSHIFT_EXPR, mode, value,
			      build_int_2 (bitpos, 0), 0, 1);
    }

  /* Now clear the chosen bits in OP0,
     except that if VALUE is -1 we need not bother.  */

  subtarget = op0;

  if (! all_one)
    subtarget = expand_bit_and (mode, op0,
				gen_rtx (CONST_INT, VOIDmode, 
					 (~ (((1 << bitsize) - 1) << bitpos))
					 & ((GET_MODE_BITSIZE (mode)
					     == HOST_BITS_PER_INT)
					    ? -1
					    : ((1 << GET_MODE_BITSIZE (mode)) - 1))),
				subtarget);

  /* Now logical-or VALUE into OP0, unless it is zero.  */

  if (! all_zero)
    subtarget = expand_binop (mode, ior_optab, subtarget, value,
			      op0, 1, OPTAB_LIB_WIDEN);
  if (op0 != subtarget)
    emit_move_insn (op0, subtarget);
}

/* Store a bit field that is split across two words.

   OP0 is the REG, SUBREG or MEM rtx for the first of the two words.
   BITSIZE is the field width; BITPOS the position of its first bit
   (within the word).
   VALUE is the value to store.  */

static void
store_split_bit_field (op0, bitsize, bitpos, value)
     rtx op0;
     int bitsize, bitpos;
     rtx value;
{
  /* BITSIZE_1 is size of the part in the first word.  */
  int bitsize_1 = BITS_PER_WORD - bitpos;
  /* BITSIZE_2 is size of the rest (in the following word).  */
  int bitsize_2 = bitsize - bitsize_1;
  rtx part1, part2;

  if (GET_MODE (value) != VOIDmode)
    value = convert_to_mode (SImode, value, 1);
  if (CONSTANT_P (value) && GET_CODE (value) != CONST_INT)
    value = copy_to_reg (value);

  /* Split the value into two parts:
     PART1 gets that which goes in the first word; PART2 the other.  */
#ifdef BYTES_BIG_ENDIAN
  /* PART1 gets the more significant part.  */
  if (GET_CODE (value) == CONST_INT)
    {
      part1 = gen_rtx (CONST_INT, VOIDmode,
		       (unsigned) (INTVAL (value)) >> bitsize_2);
      part2 = gen_rtx (CONST_INT, VOIDmode,
		       (unsigned) (INTVAL (value)) & ((1 << bitsize_2) - 1));
    }
  else
    {
      part1 = extract_fixed_bit_field (SImode, value, 0, bitsize_1,
				       BITS_PER_WORD - bitsize, 0, 1);
      part2 = extract_fixed_bit_field (SImode, value, 0, bitsize_2,
				       BITS_PER_WORD - bitsize_2, 0, 1);
    }
#else
  /* PART1 gets the less significant part.  */
  if (GET_CODE (value) == CONST_INT)
    {
      part1 = gen_rtx (CONST_INT, VOIDmode,
		       (unsigned) (INTVAL (value)) & ((1 << bitsize_1) - 1));
      part2 = gen_rtx (CONST_INT, VOIDmode,
		       (unsigned) (INTVAL (value)) >> bitsize_1);
    }
  else
    {
      part1 = extract_fixed_bit_field (SImode, value, 0, bitsize_1, 0, 0, 1);
      part2 = extract_fixed_bit_field (SImode, value, 0, bitsize_2,
				       bitsize_1, 0, 1);
    }
#endif

  /* Store PART1 into the first word.  */
  store_fixed_bit_field (op0, 0, bitsize_1, bitpos, part1);

  /* Offset op0 to get to the following word.  */
  if (GET_CODE (op0) == MEM)
    op0 = change_address (op0, SImode,
			  plus_constant (XEXP (op0, 0), UNITS_PER_WORD));
  else if (GET_CODE (op0) == REG)
    op0 = gen_rtx (SUBREG, SImode, op0, 1);
  else
    op0 = gen_rtx (SUBREG, SImode, SUBREG_REG (op0), SUBREG_WORD (op0) + 1);

  /* Store PART2 into the second word.  */
  store_fixed_bit_field (op0, 0, bitsize_2, 0, part2);
}

/* Generate code to extract a byte-field from STR_RTX
   containing BITSIZE bits, starting at BITNUM,
   and put it in TARGET if possible (if TARGET is nonzero).
   Regardless of TARGET, we return the rtx for where the value is placed.
   It may be a QUEUED.

   STR_RTX is the structure containing the byte (a REG or MEM).
   UNSIGNEDP is nonzero if this is an unsigned bit field.
   MODE is the natural mode of the field value once extracted.
   TMODE is the mode the caller would like the value to have;
   but the value may be returned with type MODE instead.

   If a TARGET is specified and we can store in it at no extra cost,
   we do so, and return TARGET.
   Otherwise, we return a REG of mode TMODE or MODE, with TMODE preferred
   if they are equally easy.  */

rtx
extract_bit_field (str_rtx, bitsize, bitnum, unsignedp, target, mode, tmode)
     rtx str_rtx;
     register int bitsize;
     int bitnum;
     int unsignedp;
     rtx target;
     enum machine_mode mode, tmode;
{
  int unit = (GET_CODE (str_rtx) == MEM) ? BITS_PER_UNIT : BITS_PER_WORD;
  register int offset = bitnum / unit;
  register int bitpos = bitnum % unit;
  register rtx op0 = str_rtx;
  rtx spec_target = target;
  rtx bitsize_rtx, bitpos_rtx;
  rtx spec_target_subreg = 0;

  if (tmode == VOIDmode)
    tmode = mode;

  while (GET_CODE (op0) == SUBREG)
    {
      offset += SUBREG_WORD (op0);
      op0 = SUBREG_REG (op0);
    }
  
#ifdef BYTES_BIG_ENDIAN
  /* If OP0 is a register, BITPOS must count within a word.
     But as we have it, it counts within whatever size OP0 now has.
     On a bigendian machine, these are not the same, so convert.  */
  if (GET_CODE (op0) != MEM && unit > GET_MODE_BITSIZE (GET_MODE (op0)))
    bitpos += unit - GET_MODE_BITSIZE (GET_MODE (op0));
#endif

  /* Extracting a full-word or multi-word value
     from a structure in a register.
     This can be done with just SUBREG.
     So too extracting a subword value in
     the least significant part of the register.  */

  if (GET_CODE (op0) == REG
      && (bitsize >= BITS_PER_WORD
	  || ((bitsize == GET_MODE_BITSIZE (mode)
	       || bitsize == GET_MODE_BITSIZE (QImode)
	       || bitsize == GET_MODE_BITSIZE (HImode))
#ifdef BYTES_BIG_ENDIAN
	      && bitpos + bitsize == BITS_PER_WORD
#else
	      && bitpos == 0
#endif
	      )))
    {
      enum machine_mode mode1 = mode;

      if (bitsize == GET_MODE_BITSIZE (QImode))
	mode1 = QImode;
      if (bitsize == GET_MODE_BITSIZE (HImode))
	mode1 = HImode;

      if (mode1 != GET_MODE (op0))
	op0 = gen_rtx (SUBREG, mode1, op0, offset);

      if (mode1 != mode)
	return convert_to_mode (tmode, op0, unsignedp);
      return op0;
    }
  
  /* From here on we know the desired field is smaller than a word
     so we can assume it is an integer.  So we can safely extract it as one
     size of integer, if necessary, and then truncate or extend
     to the size that is wanted.  */

  /* OFFSET is the number of words or bytes (UNIT says which)
     from STR_RTX to the first word or byte containing part of the field.  */

  if (GET_CODE (op0) == REG)
    {
      if (offset != 0
	  || GET_MODE_SIZE (GET_MODE (op0)) > GET_MODE_SIZE (SImode))
	op0 = gen_rtx (SUBREG, SImode, op0, offset);
      offset = 0;
    }
  else
    {
      op0 = protect_from_queue (str_rtx, 1);
    }

  /* Now OFFSET is nonzero only for memory operands.  */

  if (unsignedp)
    {
#ifdef HAVE_extzv
      if (HAVE_extzv)
	{
	  /* Get ref to first byte containing part of the field.  */
	  if (GET_CODE (op0) == MEM)
	    {
	      if (! ((*insn_operand_predicate[(int) CODE_FOR_extzv][1])
		     (op0, GET_MODE (op0))))
		{
		  /* If memory isn't acceptable for this operand,
		     copy it to a register.  */
		  unit = BITS_PER_WORD;
		  offset = bitnum / unit;
		  bitpos = bitnum % unit;
		  op0 = change_address (op0, SImode,
					plus_constant (XEXP (op0, 0), offset));
		  op0 = force_reg (GET_MODE (op0), op0);
#ifdef BITS_BIG_ENDIAN
		  if (unit > GET_MODE_BITSIZE (GET_MODE (op0)))
		    bitpos += unit - GET_MODE_BITSIZE (GET_MODE (op0));
#endif
		}
	      else
		op0 = change_address (op0, QImode,
				      plus_constant (XEXP (op0, 0), offset));
	    }

	  /* If op0 is a register, we need it in SImode
	     to make it acceptable to the format of extv.  */
	  if (GET_CODE (op0) == SUBREG)
	    PUT_MODE (op0, SImode);
	  if (GET_CODE (op0) == REG && GET_MODE (op0) != SImode)
	    op0 = gen_rtx (SUBREG, SImode, op0, 0);

	  if (target == 0
	      || (flag_force_mem && GET_CODE (target) == MEM))
	    target = spec_target = gen_reg_rtx (tmode);

	  if (GET_MODE (target) != SImode)
	    {
	      if (GET_CODE (target) == REG)
		spec_target_subreg = target = gen_rtx (SUBREG, SImode, target, 0);
	      else
		target = gen_reg_rtx (SImode);
	    }

	  /* If this machine's extzv insists on a register target,
	     make sure we have one.  */
	  if (! (*insn_operand_predicate[(int) CODE_FOR_extzv][0]) (target, SImode))
	    target = gen_reg_rtx (SImode);

	  /* On big-endian machines, we count bits from the most significant.
	     If the bit field insn does not, we must invert.  */
#if defined (BITS_BIG_ENDIAN) != defined (BYTES_BIG_ENDIAN)
	  bitpos = unit - 1 - bitpos;
#endif

	  bitsize_rtx = gen_rtx (CONST_INT, VOIDmode, bitsize);
	  bitpos_rtx = gen_rtx (CONST_INT, VOIDmode, bitpos);

	  emit_insn (gen_extzv (protect_from_queue (target, 1),
				op0, bitsize_rtx, bitpos_rtx));
	}
      else
#endif
	target = extract_fixed_bit_field (tmode, op0, offset, bitsize, bitpos,
					  target, 1);
    }
  else
    {
#ifdef HAVE_extv
      if (HAVE_extv)
	{
	  /* Get ref to first byte containing part of the field.  */
	  if (GET_CODE (op0) == MEM)
	    {
	      if (! ((*insn_operand_predicate[(int) CODE_FOR_extzv][1])
		     (op0, GET_MODE (op0))))
		{
		  /* If memory isn't acceptable for this operand,
		     copy it to a register.  */
		  unit = BITS_PER_WORD;
		  offset = bitnum / unit;
		  bitpos = bitnum % unit;
		  op0 = change_address (op0, SImode,
					plus_constant (XEXP (op0, 0), offset));
		  op0 = force_reg (GET_MODE (op0), op0);
#ifdef BITS_BIG_ENDIAN
		  if (unit > GET_MODE_BITSIZE (GET_MODE (op0)))
		    bitpos += unit - GET_MODE_BITSIZE (GET_MODE (op0));
#endif
		}
	      else
		op0 = change_address (op0, QImode,
				      plus_constant (XEXP (op0, 0), offset));
	    }


	  /* If op0 is a register, we need it in QImode
	     to make it acceptable to the format of extv.  */
	  if (GET_CODE (op0) == SUBREG)
	    PUT_MODE (op0, SImode);
	  if (GET_CODE (op0) == REG && GET_MODE (op0) != SImode)
	    op0 = gen_rtx (SUBREG, SImode, op0, 0);

	  if (target == 0
	      || (flag_force_mem && GET_CODE (target) == MEM))
	    target = spec_target = gen_reg_rtx (tmode);

	  if (GET_MODE (target) != SImode)
	    {
	      if (GET_CODE (target) == REG)
		spec_target_subreg = target = gen_rtx (SUBREG, SImode, target, 0);
	      else
		target = gen_reg_rtx (SImode);
	    }

	  /* If this machine's extv insists on a register target,
	     make sure we have one.  */
	  if (! (*insn_operand_predicate[(int) CODE_FOR_extzv][0]) (target, SImode))
	    target = gen_reg_rtx (SImode);

	  /* On big-endian machines, we count bits from the most significant.
	     If the bit field insn does not, we must invert.  */
#if defined (BITS_BIG_ENDIAN) != defined (BYTES_BIG_ENDIAN)
	  bitpos = unit - 1 - bitpos;
#endif

	  bitsize_rtx = gen_rtx (CONST_INT, VOIDmode, bitsize);
	  bitpos_rtx = gen_rtx (CONST_INT, VOIDmode, bitpos);

	  emit_insn (gen_extv (protect_from_queue (target, 1), op0,
			       bitsize_rtx, bitpos_rtx));
	}
      else
#endif
	target = extract_fixed_bit_field (tmode, op0, offset, bitsize, bitpos,
					  target, 0);
    }
  if (target == spec_target)
    return target;
  if (target == spec_target_subreg)
    return spec_target;
  if (GET_MODE (target) != tmode && GET_MODE (target) != mode)
    return convert_to_mode (tmode, target, unsignedp);
  return target;
}

/* Extract a bit field using shifts and boolean operations
   Returns an rtx to represent the value.
   OP0 addresses a register (word) or memory (byte).
   BITPOS says which bit within the word or byte the bit field starts in.
   OFFSET says how many bytes farther the bit field starts;
    it is 0 if OP0 is a register.
   BITSIZE says how many bits long the bit field is.
    (If OP0 is a register, it may be narrower than SImode,
     but BITPOS still counts within a full word,
     which is significant on bigendian machines.)

   UNSIGNEDP is nonzero for an unsigned bit field (don't sign-extend value).
   If TARGET is nonzero, attempts to store the value there
   and return TARGET, but this is not guaranteed.
   If TARGET is not used, create a pseudo-reg of mode TMODE for the value.  */

static rtx
extract_fixed_bit_field (tmode, op0, offset, bitsize, bitpos, target, unsignedp)
     enum machine_mode tmode;
     register rtx op0, target;
     register int offset, bitsize, bitpos;
     int unsignedp;
{
  int total_bits = BITS_PER_WORD;
  enum machine_mode mode;
  rtx orig = op0;

  if (GET_CODE (op0) == SUBREG || GET_CODE (op0) == REG)
    {
      /* Special treatment for a bit field split across two registers.  */
      if (bitsize + bitpos > BITS_PER_WORD)
	return extract_split_bit_field (op0, bitsize, bitpos, unsignedp);
    }
  else if (bitsize + bitpos <= BITS_PER_UNIT && ! SLOW_BYTE_ACCESS)
    {
      /* If the bit field fits entirely in one byte of memory,
	 let OP0 be that byte.  We must add OFFSET to its address.  */
      total_bits = BITS_PER_UNIT;
      op0 = change_address (op0, QImode,
			    plus_constant (XEXP (op0, 0), offset));
    }
  else
    {
#ifdef STRICT_ALIGNMENT
#ifndef STRUCTURE_SIZE_BOUNDARY
      /* The following code assumes that OP0 is aligned
	 such that a word can be fetched there.
	 This could be because words don't need to be aligned,
	 or because all structures are suitably aligned.  */
      abort ();
#endif
#endif

      /* Get ref to word containing the field.  */
      /* Adjust BITPOS to be position within a word,
	 and OFFSET to be the offset of that word.  */
      bitpos += (offset % (BITS_PER_WORD / BITS_PER_UNIT)) * BITS_PER_UNIT;
      offset -= (offset % (BITS_PER_WORD / BITS_PER_UNIT));
      op0 = change_address (op0, SImode,
			    plus_constant (XEXP (op0, 0), offset));

      /* Special treatment for a bit field split across two words.  */
      if (bitsize + bitpos > BITS_PER_WORD)
	return extract_split_bit_field (op0, bitsize, bitpos, unsignedp);
    }

  mode = GET_MODE (op0);

#ifdef BYTES_BIG_ENDIAN
  /* BITPOS is the distance between our msb
     and that of the containing byte or word.
     Convert it to the distance from the lsb.  */

  bitpos = total_bits - bitsize - bitpos;
#endif
  /* Now BITPOS is always the distance between our lsb
     and that of the containing byte or word.
     We have reduced the big-endian case to the little-endian case.  */

  if (unsignedp)
    {
      if (bitpos)
	{
	  /* If the field does not already start at the lsb,
	     shift it so it does.  */
	  tree amount = build_int_2 (bitpos, 0);
	  /* Maybe propagate the target for the shift.  */
	  /* Certainly do so if we will return the value of the shift.  */
	  rtx subtarget = (target != 0 && GET_CODE (target) == REG
			   && FUNCTION_VALUE_REGNO_P (REGNO (target))
			   ? target : 0);
	  if (tmode != mode) subtarget = 0;
	  op0 = expand_shift (RSHIFT_EXPR, mode, op0, amount, subtarget, 1);
	}
      /* Convert the value to the desired mode.  */
      if (mode != tmode)
	op0 = convert_to_mode (tmode, op0, 1);

      /* Unless the msb of the field used to be the msb when we shifted,
	 mask out the upper bits.  */

      if ((GET_MODE_BITSIZE (mode) != bitpos + bitsize
#if 0
#ifdef SLOW_ZERO_EXTEND
	   /* Always generate an `and' if
	      we just zero-extended op0 and SLOW_ZERO_EXTEND, since it
	      will combine fruitfully with the zero-extend. */
	   || tmode != mode
#endif
#endif
	   )
	  && bitsize < HOST_BITS_PER_INT)
	return expand_bit_and (GET_MODE (op0), op0,
			       gen_rtx (CONST_INT, VOIDmode, (1 << bitsize) - 1),
			       target);
      return op0;
    }

  /* To extract a signed bit-field, first shift its msb to the msb of the word,
     then arithmetic-shift its lsb to the lsb of the word.  */
  op0 = force_reg (mode, op0);
  if (mode != tmode)
    target = 0;
  if (GET_MODE_BITSIZE (QImode) < GET_MODE_BITSIZE (mode)
      && GET_MODE_BITSIZE (QImode) >= bitsize + bitpos)
    mode = QImode, op0 = convert_to_mode (QImode, op0, 0);
  if (GET_MODE_BITSIZE (HImode) < GET_MODE_BITSIZE (mode)
      && GET_MODE_BITSIZE (HImode) >= bitsize + bitpos)
    mode = HImode, op0 = convert_to_mode (HImode, op0, 0);
  if (GET_MODE_BITSIZE (mode) != (bitsize + bitpos))
    {
      tree amount = build_int_2 (GET_MODE_BITSIZE (mode) - (bitsize + bitpos), 0);
      /* Maybe propagate the target for the shift.  */
      /* Certainly do so if we will return the value of the shift.  */
      rtx subtarget = (target != 0 && GET_CODE (target) == REG
		       && FUNCTION_VALUE_REGNO_P (REGNO (target))
		       ? target : 0);
      op0 = expand_shift (LSHIFT_EXPR, mode, op0, amount, subtarget, 1);
    }

  return expand_shift (RSHIFT_EXPR, mode, op0,
		       build_int_2 (GET_MODE_BITSIZE (mode) - bitsize, 0), 
		       target, 0);
}

/* Extract a bit field that is split across two words
   and return an RTX for the result.

   OP0 is the REG, SUBREG or MEM rtx for the first of the two words.
   BITSIZE is the field width; BITPOS, position of its first bit, in the word.
   UNSIGNEDP is 1 if should zero-extend the contents; else sign-extend.  */

static rtx
extract_split_bit_field (op0, bitsize, bitpos, unsignedp)
     rtx op0;
     int bitsize, bitpos, unsignedp;
{
  /* BITSIZE_1 is size of the part in the first word.  */
  int bitsize_1 = BITS_PER_WORD - bitpos;
  /* BITSIZE_2 is size of the rest (in the following word).  */
  int bitsize_2 = bitsize - bitsize_1;
  rtx part1, part2, result;

  /* Get the part of the bit field from the first word.  */
  part1 = extract_fixed_bit_field (SImode, op0, 0, bitsize_1, bitpos, 0, 1);

  /* Offset op0 by 1 word to get to the following one.  */
  if (GET_CODE (op0) == MEM)
    op0 = change_address (op0, SImode,
			  plus_constant (XEXP (op0, 0), UNITS_PER_WORD));
  else if (GET_CODE (op0) == REG)
    op0 = gen_rtx (SUBREG, SImode, op0, 1);
  else
    op0 = gen_rtx (SUBREG, SImode, SUBREG_REG (op0), SUBREG_WORD (op0) + 1);

  /* Get the part of the bit field from the second word.  */
  part2 = extract_fixed_bit_field (SImode, op0, 0, bitsize_2, 0, 0, 1);

  /* Shift the more significant part up to fit above the other part.  */
#ifdef BYTES_BIG_ENDIAN
  part1 = expand_shift (LSHIFT_EXPR, SImode, part1,
			build_int_2 (bitsize_2, 0), 0, 1);
#else
  part2 = expand_shift (LSHIFT_EXPR, SImode, part2,
			build_int_2 (bitsize_1, 0), 0, 1);
#endif

  /* Combine the two parts with bitwise or.  This works
     because we extracted both parts as unsigned bit fields.  */
  result = expand_binop (SImode, ior_optab, part1, part2, 0, 1,
			 OPTAB_LIB_WIDEN);

  /* Unsigned bit field: we are done.  */
  if (unsignedp)
    return result;
  /* Signed bit field: sign-extend with two arithmetic shifts.  */
  result = expand_shift (LSHIFT_EXPR, SImode, result,
			 build_int_2 (BITS_PER_WORD - bitsize, 0), 0, 0);
  return expand_shift (RSHIFT_EXPR, SImode, result,
		       build_int_2 (BITS_PER_WORD - bitsize, 0), 0, 0);
}

/* Add INC into TARGET.  */

void
expand_inc (target, inc)
     rtx target, inc;
{
  rtx value = expand_binop (GET_MODE (target), add_optab,
			    target, inc,
			    target, 0, OPTAB_LIB_WIDEN);
  if (value != target)
    emit_move_insn (target, value);
}

/* Subtract INC from TARGET.  */

void
expand_dec (target, dec)
     rtx target, dec;
{
  rtx value = expand_binop (GET_MODE (target), sub_optab,
			    target, dec,
			    target, 0, OPTAB_LIB_WIDEN);
  if (value != target)
    emit_move_insn (target, value);
}

/* Output a shift instruction for expression code CODE,
   with SHIFTED being the rtx for the value to shift,
   and AMOUNT the tree for the amount to shift by.
   Store the result in the rtx TARGET, if that is convenient.
   If UNSIGNEDP is nonzero, do a logical shift; otherwise, arithmetic.
   Return the rtx for where the value is.  */

/* Pastel, for shifts, converts shift count to SImode here
   independent of the mode being shifted.
   Should that be done in an earlier pass?
   It turns out not to matter for C.  */

rtx
expand_shift (code, mode, shifted, amount, target, unsignedp)
     enum tree_code code;
     register enum machine_mode mode;
     rtx shifted;
     tree amount;
     register rtx target;
     int unsignedp;
{
  register rtx op1, temp = 0;
  register int left = (code == LSHIFT_EXPR || code == LROTATE_EXPR);
  int try;
  rtx negated = 0;
  int rotate = code == LROTATE_EXPR || code == RROTATE_EXPR;

  /* Previously detected shift-counts computed by NEGATE_EXPR
     and shifted in the other direction; but that does not work
     on all machines.  */

  op1 = expand_expr (amount, 0, VOIDmode, 0);

  for (try = 0; temp == 0 && try < 3; try++)
    {
      enum optab_methods methods;
      if (try == 0)
	methods = OPTAB_DIRECT;
      else if (try == 1)
	methods = OPTAB_WIDEN;
      else
	methods = OPTAB_LIB_WIDEN;

      if (rotate)
	{
	  /* Widening does not work for rotation.  */
	  if (methods != OPTAB_DIRECT)
	    methods = OPTAB_LIB;

	  temp = expand_binop (mode,
			       left ? rotl_optab : rotr_optab,
			       shifted, op1, target, -1, methods);
	  /* If there is no shift instruction for the desired direction,
	     try negating the shift count and shifting in the other direction.
	     If a machine has only a left shift instruction then we are
	     entitled to assume it shifts right with negative args.  */
	  if (temp == 0)
	    {
	      if (negated != 0)
		;
	      else if (GET_CODE (op1) == CONST_INT)
		negated = gen_rtx (CONST_INT, VOIDmode, -INTVAL (op1));
	      else
		negated = expand_unop (mode, neg_optab, op1, 0, 0);
	      temp = expand_binop (mode,
				   left ? rotr_optab : rotl_optab,
				   shifted, negated, target, -1, methods);
	    }
	}
      else if (unsignedp)
	{
	  temp = expand_binop (mode,
			       left ? lshl_optab : lshr_optab,
			       shifted, op1, target, unsignedp, methods);
	  if (temp == 0 && left)
	    temp = expand_binop (mode, ashl_optab,
				 shifted, op1, target, unsignedp, methods);
	  if (temp == 0)
	    {
	      if (negated != 0)
		;
	      else if (GET_CODE (op1) == CONST_INT)
		negated = gen_rtx (CONST_INT, VOIDmode, -INTVAL (op1));
	      else
		negated = expand_unop (mode, neg_optab, op1, 0, 0);
	      temp = expand_binop (mode,
				   left ? lshr_optab : lshl_optab,
				   shifted, negated,
				   target, unsignedp, methods);
	    }

	  if (temp != 0)
	    return temp;
	}
      /* Do arithmetic shifts.
	 Also, if we are going to widen the operand, we can just as well
	 use an arithmetic right-shift instead of a logical one.  */
      if (! rotate && (! unsignedp || (! left && methods == OPTAB_WIDEN)))
	{
	  /* Arithmetic shift */

	  temp = expand_binop (mode,
			       left ? ashl_optab : ashr_optab,
			       shifted, op1, target, unsignedp, methods);
	  if (temp == 0)
	    {
	      if (negated != 0)
		;
	      else if (GET_CODE (op1) == CONST_INT)
		negated = gen_rtx (CONST_INT, VOIDmode, -INTVAL (op1));
	      else
		negated = expand_unop (mode, neg_optab, op1, 0, 0);
	      temp = expand_binop (mode,
				   left ? ashr_optab : ashl_optab,
				   shifted, negated, target, unsignedp, methods);
	    }
	  if (temp != 0)
	    return temp;
	}

      if (unsignedp)
	{
	  /* No logical shift insn in either direction =>
	     try a bit-field extract instruction if we have one.  */
#ifdef HAVE_extzv
#ifndef BITS_BIG_ENDIAN
	  if (HAVE_extzv && !left
	      && ((methods == OPTAB_DIRECT && mode == SImode)
		  || (methods == OPTAB_WIDEN
		      && GET_MODE_SIZE (mode) < GET_MODE_SIZE (SImode))))
	    {
	      rtx shifted1 = convert_to_mode (SImode, shifted, 1);
	      rtx target1 = target;

	      /* If -fforce-mem, don't let the operand be in memory.  */
	      if (flag_force_mem && GET_CODE (shifted1) == MEM)
		shifted1 = force_not_mem (shifted1);

	      /* If this machine's extzv insists on a register for
		 operand 1, arrange for that.  */
	      if (! ((*insn_operand_predicate[(int) CODE_FOR_extzv][1])
		     (shifted1, SImode)))
		shifted1 = force_reg (SImode, shifted1);

	      /* If we don't have or cannot use a suggested target,
		 make a place for the result, in the proper mode.  */
	      if (methods == OPTAB_WIDEN || target1 == 0
		  || ! ((*insn_operand_predicate[(int) CODE_FOR_extzv][0])
			(target1, SImode)))
		target1 = gen_reg_rtx (SImode);

	      /* If this machine's extzv insists on a register for
		 operand 3, arrange for that.  */
	      if (! ((*insn_operand_predicate[(int) CODE_FOR_extzv][3])
		     (op1, SImode)))
		op1 = force_reg (SImode, op1);

	      op1 = protect_from_queue (op1, 1);

	      /* TEMP gets the width of the bit field to extract:
		 wordsize minus # bits to shift by.  */
	      if (GET_CODE (op1) == CONST_INT)
		temp = gen_rtx (CONST_INT, VOIDmode,
				(GET_MODE_BITSIZE (mode) - INTVAL (op1)));
	      else
		temp = expand_binop (SImode, sub_optab,
				     gen_rtx (CONST_INT, VOIDmode,
					      GET_MODE_BITSIZE (mode)),
				     op1, gen_reg_rtx (SImode),
				     0, OPTAB_LIB_WIDEN);
	      /* Now extract with width TEMP, omitting OP1 least sig bits.  */
	      emit_insn (gen_extzv (protect_from_queue (target1, 1),
				    protect_from_queue (shifted1, 0),
				    temp, op1));
	      return convert_to_mode (mode, target1, 1);
	    }
	  /* Can also do logical shift with signed bit-field extract
	     followed by inserting the bit-field at a different position.
	     That strategy is not yet implemented.  */
#endif /* not BITS_BIG_ENDIAN */
#endif /* HAVE_extzv */
	  /* We have failed to generate the logical shift and will abort.  */
	}
    }
  if (temp == 0)
    abort ();
  return temp;
}

/* Output an instruction or two to bitwise-and OP0 with OP1
   in mode MODE, with output to TARGET if convenient and TARGET is not zero.
   Returns where the result is.  */

rtx
expand_bit_and (mode, op0, op1, target)
     enum machine_mode mode;
     rtx op0, op1, target;
{
  register rtx temp;

  /* First try to open-code it directly.  */
  temp = expand_binop (mode, and_optab, op0, op1, target, 1, OPTAB_DIRECT);
  if (temp == 0)
    {
      rtx compl;
      /* If that fails, try to open code using a clear-bits insn.  */
      if (GET_CODE (op1) == CONST_INT
	  && GET_MODE_BITSIZE (mode) < HOST_BITS_PER_INT)
	compl = gen_rtx (CONST_INT, VOIDmode,
			 ((1 << GET_MODE_BITSIZE (mode)) - 1) & ~INTVAL (op1));
      else
	compl = expand_unop (mode, one_cmpl_optab, op1, 0, 1);
      temp = expand_binop (mode, andcb_optab, op0, compl, target,
			   1, OPTAB_DIRECT);
    }
  if (temp == 0)
    /* If still no luck, try library call or wider modes.  */
    temp = expand_binop (mode, and_optab, op0, op1, target,
			 1, OPTAB_LIB_WIDEN);

  if (temp == 0)
    abort ();
  return temp;
}

/* Perform a multiplication and return an rtx for the result.
   MODE is mode of value; OP0 and OP1 are what to multiply (rtx's);
   TARGET is a suggestion for where to store the result (an rtx).

   We check specially for a constant integer as OP1.
   If you want this check for OP0 as well, then before calling
   you should swap the two operands if OP0 would be constant.  */

rtx
expand_mult (mode, op0, op1, target, unsignedp)
     enum machine_mode mode;
     register rtx op0, op1, target;
     int unsignedp;
{
  /* Don't use the function value register as a target
     since we have to read it as well as write it,
     and function-inlining gets confused by this.  */
  if (target && REG_P (target) && FUNCTION_VALUE_REGNO_P (REGNO (target)))
    target = 0;

  if (GET_CODE (op1) == CONST_INT)
    {
      register int foo;
      int bar;
      int negate = INTVAL (op1) < 0;
      int absval = INTVAL (op1) * (negate ? -1 : 1);

      /* Is multiplier a power of 2, or minus that?  */
      foo = exact_log2 (absval);
      if (foo >= 0)
	{
	  rtx tem =  expand_shift (LSHIFT_EXPR, mode, op0,
				   build_int_2 (foo, 0),
				   target, 0);
	  return negate ? negate_rtx (tem) : tem;
	}
      /* Is multiplier a sum of two powers of 2, or minus that?  */
      bar = floor_log2 (absval);
      foo = exact_log2 (absval - (1 << bar));
      if (bar >= 0 && foo >= 0)
	{
	  rtx pow1 = ((foo == 0) ? op0
		      : expand_shift (LSHIFT_EXPR, mode, op0,
				      build_int_2 (foo, 0),
				      0, 0));
	  rtx pow2 = expand_shift (LSHIFT_EXPR, mode, op0,
				   build_int_2 (bar, 0),
				   0, 0);
	  rtx tem = force_operand (gen_rtx (PLUS, mode, pow1, pow2), target);
	  return negate ? negate_rtx (tem) : tem;
	}
    }
  /* This used to use umul_optab if unsigned,
     but I think that for non-widening multiply there is no difference
     between signed and unsigned.  */
  op0 = expand_binop (mode, smul_optab,
		      op0, op1, target, unsignedp, OPTAB_LIB_WIDEN);
  if (op0 == 0)
    abort ();
  return op0;
}

/* Emit the code to divide OP0 by OP1, putting the result in TARGET
   if that is convenient, and returning where the result is.
   You may request either the quotient or the remainder as the result;
   specify REM_FLAG nonzero to get the remainder.

   CODE is the expression code for which kind of division this is;
   it controls how rounding is done.  MODE is the machine mode to use.
   UNSIGNEDP nonzero means do unsigned division.  */

/* ??? For CEIL_MOD_EXPR, can compute incorrect remainder with ANDI
   and then correct it by or'ing in missing high bits
   if result of ANDI is nonzero.
   For ROUND_MOD_EXPR, can use ANDI and then sign-extend the result.
   This could optimize to a bfexts instruction.
   But C doesn't use these operations, so their optimizations are
   left for later.  */

rtx
expand_divmod (rem_flag, code, mode, op0, op1, target, unsignedp)
     int rem_flag;
     enum tree_code code;
     enum machine_mode mode;
     register rtx op0, op1, target;
     int unsignedp;
{
  register rtx label;
  register rtx temp;
  int log = -1;
  int can_clobber_op0;
  int mod_insn_no_good = 0;
  rtx adjusted_op0 = op0;

  /* Don't use the function value register as a target
     since we have to read it as well as write it,
     and function-inlining gets confused by this.  */
  if (target && REG_P (target) && FUNCTION_VALUE_REGNO_P (REGNO (target)))
    target = 0;

  if (target == 0)
    {
      target = gen_reg_rtx (mode);
    }

  /* Don't clobber an operand while doing a multi-step calculation.  */
  if ((rem_flag && rtx_equal_p (target, op0))
      || rtx_equal_p (target, op1))
    target = gen_reg_rtx (mode);

  can_clobber_op0 = (GET_CODE (op0) == REG && op0 == target);

  if (GET_CODE (op1) == CONST_INT)
    log = exact_log2 (INTVAL (op1));

  /* If log is >= 0, we are dividing by 2**log, and will do it by shifting,
     which is really floor-division.  Otherwise we will really do a divide,
     and we assume that is trunc-division.

     We must correct the dividend by adding or subtracting something
     based on the divisor, in order to do the kind of rounding specified
     by CODE.  The correction depends on what kind of rounding is actually
     available, and that depends on whether we will shift or divide.  */

  switch (code)
    {
    case TRUNC_MOD_EXPR:
    case TRUNC_DIV_EXPR:
      if (log >= 0 && ! unsignedp)
	{
	  label = gen_label_rtx ();
	  if (! can_clobber_op0)
	    adjusted_op0 = copy_to_suggested_reg (adjusted_op0, target);
	  emit_cmp_insn (adjusted_op0, const0_rtx, 0, 0);
	  emit_jump_insn (gen_bge (label));
	  expand_inc (adjusted_op0, plus_constant (op1, -1));
	  emit_label (label);
	  mod_insn_no_good = 1;
	}
      break;

    case FLOOR_DIV_EXPR:
    case FLOOR_MOD_EXPR:
      if (log < 0 && ! unsignedp)
	{
	  label = gen_label_rtx ();
	  if (! can_clobber_op0)
	    adjusted_op0 = copy_to_suggested_reg (adjusted_op0, target);
	  emit_cmp_insn (adjusted_op0, const0_rtx, 0, 0);
	  emit_jump_insn (gen_bge (label));
	  expand_dec (adjusted_op0, op1);
	  expand_inc (adjusted_op0, const1_rtx);
	  emit_label (label);
	  mod_insn_no_good = 1;
	}
      break;

    case CEIL_DIV_EXPR:
    case CEIL_MOD_EXPR:
      if (! can_clobber_op0)
	adjusted_op0 = copy_to_suggested_reg (adjusted_op0, target);
      if (log < 0)
	{
	  if (! unsignedp)
	    {
	      label = gen_label_rtx ();
	      emit_cmp_insn (adjusted_op0, const0_rtx, 0, 0);
	      emit_jump_insn (gen_ble (label));
	    }
	  expand_inc (adjusted_op0, op1);
	  expand_dec (adjusted_op0, const1_rtx);
	  if (! unsignedp)
	    emit_label (label);
	}
      else
	{
	  adjusted_op0 = expand_binop (GET_MODE (target), add_optab,
				       adjusted_op0, plus_constant (op1, -1),
				       0, 0, OPTAB_LIB_WIDEN);
	}
      mod_insn_no_good = 1;
      break;

    case ROUND_DIV_EXPR:
    case ROUND_MOD_EXPR:
      if (! can_clobber_op0)
	adjusted_op0 = copy_to_suggested_reg (adjusted_op0, target);
      if (log < 0)
	{
	  op1 = expand_shift (RSHIFT_EXPR, mode, op1, integer_one_node, 0, 0);
	  if (! unsignedp)
	    {
	      label = gen_label_rtx ();
	      emit_cmp_insn (adjusted_op0, const0_rtx, 0, 0);
	      emit_jump_insn (gen_bge (label));
	      expand_unop (mode, neg_optab, op1, op1, 0);
	      emit_label (label);
	    }
	  expand_inc (adjusted_op0, op1);
	}
      else
	{
	  op1 = gen_rtx (CONST_INT, VOIDmode, INTVAL (op1) / 2);
	  expand_inc (adjusted_op0, op1);
	}
      mod_insn_no_good = 1;
      break;
    }

  if (rem_flag && !mod_insn_no_good)
    {
      /* Try to produce the remainder directly */
      if (log >= 0)
	{
	  return expand_bit_and (mode, adjusted_op0,
				 gen_rtx (CONST_INT, VOIDmode,
					  INTVAL (op1) - 1),
				 target);
	}
      else
	{
	  /* See if we can do remainder without a library call.  */
	  temp = expand_binop (mode,
			       unsignedp ? umod_optab : smod_optab,
			       adjusted_op0, op1, target,
			       unsignedp, OPTAB_WIDEN);
	  if (temp != 0)
	    return temp;
	  /* No luck there.
	     Can we do remainder and divide at once without a library call?  */
	  temp = gen_reg_rtx (mode);
	  if (expand_twoval_binop (unsignedp ? udivmod_optab : sdivmod_optab,
				   adjusted_op0, op1,
				   0, temp, unsignedp))
	    return temp;
	  temp = 0;
	}
    }

  /* Produce the quotient.  */
  if (log >= 0)
    temp = expand_shift (RSHIFT_EXPR, mode, adjusted_op0,
			 build_int_2 (exact_log2 (INTVAL (op1)), 0),
			 target, unsignedp);
  else if (rem_flag && !mod_insn_no_good)
    /* If producing quotient in order to subtract for remainder,
       and a remainder subroutine would be ok,
       don't use a divide subroutine.  */
    temp = expand_binop (mode, unsignedp ? udiv_optab : sdiv_optab,
			 adjusted_op0, op1, target,
			 unsignedp, OPTAB_WIDEN);
  else
    temp = expand_binop (mode, unsignedp ? udiv_optab : sdiv_optab,
			 adjusted_op0, op1, target,
			 unsignedp, OPTAB_LIB_WIDEN);

  /* If we really want the remainder, get it by subtraction.  */
  if (rem_flag)
    {
      if (temp == 0)
	{
	  /* No divide instruction either.  Use library for remainder.  */
	  temp = expand_binop (mode,
			       unsignedp ? umod_optab : smod_optab,
			       op0, op1, target,
			       unsignedp, OPTAB_LIB_WIDEN);
	}
      else
	{
	  /* We divided.  Now finish doing X - Y * (X / Y).  */
	  temp = expand_mult (mode, temp, op1, temp, unsignedp);
	  if (! temp) abort ();
	  temp = expand_binop (mode, sub_optab, op0,
			       temp, target, unsignedp, OPTAB_LIB_WIDEN);
	}
    }

  if (temp == 0)
    abort ();
  return temp;
}
