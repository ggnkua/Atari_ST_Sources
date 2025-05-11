/* Sets (bit vectors) of hard registers, and operations on them.
   Copyright (C) 1987 Free Software Foundation, Inc.

This file is part of GNU CC

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


/* Define the type of a set of hard registers.  */

/* If HARD_REG_SET is a macro, its definition is a scalar type
   that has enough bits for all the target machine's hard registers.
   Otherwise, it is a typedef for a suitable array of longs,
   and HARD_REG_SET_LONGS is how many.  */

#if FIRST_PSEUDO_REGISTER <= HOST_BITS_PER_CHAR
#define HARD_REG_SET char
#else
#if FIRST_PSEUDO_REGISTER <= HOST_BITS_PER_SHORT
#define HARD_REG_SET short
#else
#if FIRST_PSEUDO_REGISTER <= HOST_BITS_PER_INT
#define HARD_REG_SET int
#else
#if FIRST_PSEUDO_REGISTER <= HOST_BITS_PER_LONG
#define HARD_REG_SET long
#else
#define HARD_REG_SET_LONGS \
 ((FIRST_PSEUDO_REGISTER + HOST_BITS_PER_LONG - 1) / HOST_BITS_PER_LONG)
typedef long HARD_REG_SET[HARD_REG_SET_LONGS];
#endif
#endif
#endif
#endif

/* Define macros SET_HARD_REG_BIT, CLEAR_HARD_REG_BIT and TEST_HARD_REG_BIT
   to set, clear or test one bit in a hard reg set of type HARD_REG_SET.
   All three take two arguments: the set and the register number.

   In the case where sets are arrays of longs, the first argument
   is actually a pointer to a long.

   Define two macros for initializing a set:
   CLEAR_HARD_REG_SET and SET_HARD_REG_SET.
   These take just one argument.

   Also define macros for copying hard reg sets:
   COPY_HARD_REG_SET and COMPL_HARD_REG_SET.
   These take two arguments TO and FROM; they read from FROM
   and store into TO.  COMPL_HARD_REG_SET complements each bit.

   Also define macros for combining hard reg sets:
   IOR_HARD_REG_SET and AND_HARD_REG_SET.
   These take two arguments TO and FROM; they read from FROM
   and combine bitwise into TO.  Define also two variants
   IOR_COMPL_HARD_REG_SET and AND_COMPL_HARD_REG_SET
   which use the complement of the set FROM.

   Also define GO_IF_HARD_REG_SUBSET (X, Y, TO):
   if X is a subset of Y, go to TO.
*/   

#ifdef HARD_REG_SET

#define SET_HARD_REG_BIT(SET, BIT)  \
 ((SET) |= 1 << (BIT))
#define CLEAR_HARD_REG_BIT(SET, BIT)  \
 ((SET) &= ~(1 << (BIT)))
#define TEST_HARD_REG_BIT(SET, BIT)  \
 ((SET) & (1 << (BIT)))

#define CLEAR_HARD_REG_SET(TO) ((TO) = 0)
#define SET_HARD_REG_SET(TO) ((TO) = -1)

#define COPY_HARD_REG_SET(TO, FROM) ((TO) = (FROM))
#define COMPL_HARD_REG_SET(TO, FROM) ((TO) = ~(FROM))

#define IOR_HARD_REG_SET(TO, FROM) ((TO) |= (FROM))
#define IOR_COMPL_HARD_REG_SET(TO, FROM) ((TO) |= ~ (FROM))
#define AND_HARD_REG_SET(TO, FROM) ((TO) &= (FROM))
#define AND_COMPL_HARD_REG_SET(TO, FROM) ((TO) &= ~ (FROM))

#define GO_IF_HARD_REG_SUBSET(X,Y,TO) if (0 == ((X) & ~(Y))) goto TO
#else

#define SET_HARD_REG_BIT(SET, BIT)  \
 ((SET)[(BIT) / HOST_BITS_PER_LONG] |= 1 << ((BIT) % HOST_BITS_PER_LONG))
#define CLEAR_HARD_REG_BIT(SET, BIT)  \
 ((SET)[(BIT) / HOST_BITS_PER_LONG] &= ~(1 << ((BIT) % HOST_BITS_PER_LONG)))
#define TEST_HARD_REG_BIT(SET, BIT)  \
 ((SET)[(BIT) / HOST_BITS_PER_LONG] & (1 << ((BIT) % HOST_BITS_PER_LONG)))

#define CLEAR_HARD_REG_SET(TO)  \
{ register long *scan_tp_ = (TO);				\
  register int i;						\
  for (i = 0; i < HARD_REG_SET_LONGS; i++)			\
    *scan_tp_++ = 0; }

#define SET_HARD_REG_SET(TO)  \
{ register long *scan_tp_ = (TO);				\
  register int i;						\
  for (i = 0; i < HARD_REG_SET_LONGS; i++)			\
    *scan_tp_++ = -1; }

#define COPY_HARD_REG_SET(TO, FROM)  \
{ register long *scan_tp_ = (TO), *scan_fp_ = (FROM);		\
  register int i;						\
  for (i = 0; i < HARD_REG_SET_LONGS; i++)			\
    *scan_tp_++ = *scan_fp_++; }

#define COMPL_HARD_REG_SET(TO, FROM)  \
{ register long *scan_tp_ = (TO), *scan_fp_ = (FROM);		\
  register int i;						\
  for (i = 0; i < HARD_REG_SET_LONGS; i++)			\
    *scan_tp_++ = ~ *scan_fp_++; }

#define AND_HARD_REG_SET(TO, FROM)  \
{ register long *scan_tp_ = (TO), *scan_fp_ = (FROM);		\
  register int i;						\
  for (i = 0; i < HARD_REG_SET_LONGS; i++)			\
    *scan_tp_++ &= *scan_fp_++; }

#define AND_COMPL_HARD_REG_SET(TO, FROM)  \
{ register long *scan_tp_ = (TO), *scan_fp_ = (FROM);		\
  register int i;						\
  for (i = 0; i < HARD_REG_SET_LONGS; i++)			\
    *scan_tp_++ &= ~ *scan_fp_++; }

#define IOR_HARD_REG_SET(TO, FROM)  \
{ register long *scan_tp_ = (TO), *scan_fp_ = (FROM);		\
  register int i;						\
  for (i = 0; i < HARD_REG_SET_LONGS; i++)			\
    *scan_tp_++ |= *scan_fp_++; }

#define IOR_COMPL_HARD_REG_SET(TO, FROM)  \
{ register long *scan_tp_ = (TO), *scan_fp_ = (FROM);		\
  register int i;						\
  for (i = 0; i < HARD_REG_SET_LONGS; i++)			\
    *scan_tp_++ |= ~ *scan_fp_++; }

#define GO_IF_HARD_REG_SUBSET(X,Y,TO)  \
{ register long *scan_xp_ = (X), *scan_yp_ = (Y);		\
  register int i;						\
  for (i = 0; i < HARD_REG_SET_LONGS; i++)			\
    if (0 != (*scan_xp_++ & ~*scan_yp_++)) break;		\
  if (i == HARD_REG_SET_LONGS) goto TO; }

#endif

/* Define some standard sets of registers.  */

/* Indexed by hard register number, contains 1 for registers
   that are fixed use (stack pointer, pc, frame pointer, etc.).
   These are the registers that cannot be used to allocate
   a pseudo reg whose life does not cross calls.  */

extern char fixed_regs[FIRST_PSEUDO_REGISTER];

/* The same info as a HARD_REG_SET.  */

extern HARD_REG_SET fixed_reg_set;

/* Indexed by hard register number, contains 1 for registers
   that are fixed use or are clobbered by function calls.
   These are the registers that cannot be used to allocate
   a pseudo reg whose life crosses calls.  */

extern char call_used_regs[FIRST_PSEUDO_REGISTER];

/* The same info as a HARD_REG_SET.  */

extern HARD_REG_SET call_used_reg_set;

/* For each reg class, a HARD_REG_SET saying which registers are in it.  */

extern HARD_REG_SET reg_class_contents[];

/* For each reg class, table listing all the containing classes.  */

extern enum reg_class reg_class_superclasses[N_REG_CLASSES][N_REG_CLASSES];

/* For each reg class, table listing all the classes contained in it.  */

extern enum reg_class reg_class_subclasses[N_REG_CLASSES][N_REG_CLASSES];

/* For each pair of reg classes,
   a largest reg class contained in their union.  */

extern enum reg_class reg_class_subunion[N_REG_CLASSES][N_REG_CLASSES];

