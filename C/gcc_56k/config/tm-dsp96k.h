/* Definitions of target machine for GNU compiler, for the Motorola dsp96000
   digital signal processing chip.
   Copyright (C) 1988 Free Software Foundation, Inc.

    $Header: /usr1/dsp/cvsroot/source/gcc/config/tm-dsp96k.h,v 1.30 92/04/02 10:41:19 pete Exp $
    $Id: tm-dsp96k.h,v 1.30 92/04/02 10:41:19 pete Exp $

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


/* Note that some other tm- files include this one and then override
   many of the definitions that relate to assembler syntax.  */

#define DSP96000 1

/* Turn on debugging output */

#define SDB_DEBUGGING_INFO

/* Names to predefine in the preprocessor for this target machine.  */

#define CPP_PREDEFINES "-DDSP96K"

/* Print subsidiary information on the compiler version in use.  */
#define TARGET_VERSION fprintf (stderr, " Motorola DSP96002 %s", \
				motorola_version_string);

/* Run-time compilation parameters selecting different hardware subsets. */

extern int target_flags;

/* Macro to define tables used to set the flags.
   This is a list in braces of pairs in braces,
   each pair being { "NAME", VALUE }
   where VALUE is the bits to set or minus the bits to clear.
   An empty string NAME is used to identify the default VALUE.  */

#define TARGET_DSP				( target_flags & ( 3 + 96 ))
#define TARGET_LINV_PLUS_BIV_PROMOTION		( target_flags & 1 )
#define TARGET_DO_LOOP_GENERATION		( target_flags & 2 )
#define TARGET_X_MEMORY	 			( target_flags & 4 )
#define TARGET_Y_MEMORY				( target_flags & 8 )
#define TARGET_L_MEMORY				( target_flags & 16 )
#define TARGET_CALL_OVERHEAD_REDUCTION		( target_flags & 32 )
#define TARGET_RELOAD_CLEANUP			( target_flags & 64 )
#define TARGET_STACK_CHECK			( target_flags & 4096 )
#define TARGET_SWITCHES  			\
  {{ "dsp", ( 3 + 96 ) },			\
   { "no-dsp", -( 3 + 96 ) },	 		\
   { "linv-plus-biv-promotion", 1 },		\
   { "no-linv-plus-biv-promotion", -1 },	\
   { "do-loop-generation", 2 },			\
   { "no-do-loop-generation", -2 },		\
   { "x-memory", 4 },				\
   { "y-memory", 8 },				\
   { "l-memory", 16 },				\
   { "call-overhead-reduction", 32 },           \
   { "no-call-overhead-reduction", -32 },       \
   { "reload-cleanup", 64 },			\
   { "no-reload-cleanup", -64 },		\
   { "stack-check", 4096 },                     \
   { "no-stack-check", 4096 },                  \
   { "", TARGET_DEFAULT}}

#define TARGET_DEFAULT ( 3 + 16 + 96 )

/* target machine storage layout */

/* Define this if most significant bit is lowest numbered
   in instructions that operate on numbered bit-fields.  */
/* m96k is numbered 31..0 */
#undef BITS_BIG_ENDIAN

/* Define this if most significant byte of a word is the lowest numbered.  */
/* has no byte address but if it did they would look like 3..2..1..0 */
#undef BYTES_BIG_ENDIAN

/* Define this if most significant word of a multiword object has the lowest
   is number. */
/* m96k has no multiword objects */
#undef WORDS_BIG_ENDIAN 

/* number of bits in an addressible storage unit. m96k has word addressing */
#define BITS_PER_UNIT 32
#define BITS_PER_WORD 32
#define CHAR_TYPE_SIZE 32
#define SHORT_TYPE_SIZE 32
#define FLOAT_TYPE_SIZE 31
#define DOUBLE_TYPE_SIZE (( 'l' == memory_model ) ? 32 : 64 )
#define LONG_DOUBLE_TYPE_SIZE DOUBLE_TYPE_SIZE
/* long long is turned off in the front end. */
#define LONG_LONG_TYPE_SIZE 64

/* the maximum nesting depth of do-loops allowed. */
#define MAX_DO_LOOP_NESTING 3

/* Width in bits of a "word", which is the contents of a machine register.
   Note that this is not necessarily the width of data type `int';
   if using 16-bit ints on a 68000, this would still be 32.
   But on a machine with 16-bit registers, this would be 16.  */
#define BITS_PER_WORD 32
#define MAX_FIXED_MODE_SIZE 32

/* Width of a word, in units (bytes).  */
/* m96k has word addressing */
#define UNITS_PER_WORD 1

/* Width in bits of a pointer.
   See also the macro `Pmode' defined below.  */
#define POINTER_SIZE 32

/* Allocation boundary (in *bits*) for storing pointers in memory.  */
#define POINTER_BOUNDARY 32

/* Allocation boundary (in *bits*) for storing arguments in argument list.  */
#define PARM_BOUNDARY 32

/* Allocation boundary (in *bits*) for the code of a function.  */
#define FUNCTION_BOUNDARY 32

/* Alignment of field after `int : 0' in a structure.  */
#define EMPTY_FIELD_BOUNDARY 32

/* No data type wants to be aligned rounder than this.  */
#define BIGGEST_ALIGNMENT 32

/* Define this if move instructions will actually fail to work
   when given unaligned data.  */
/* m96k cannot have unaligned data */
#define STRICT_ALIGNMENT

/* Standard register usage.  */

/*
  Number of actual hardware registers.
  The hardware registers are assigned numbers for the compiler
  from 0 to just below FIRST_PSEUDO_REGISTER.
  All registers that the compiler knows about must be given numbers,
  even those that are not normally considered general registers.

  40 registers for the m96k ( 24 data + 8 address + 8 index )
*/
#define FIRST_PSEUDO_REGISTER 40

/* 1 for registers that have pervasive standard uses
   and are not available for the register allocator.

   for the m96k:

   0..23   = (d0.l,d0.m,d0.h)..(d7.l,d7.m,d7.h) general data registers
   24..29  = r0..r5 address registers
   30	   = r6 frame pointer
   31      = r7 stack pointer
   32..37  = n0..n5 index registers
   38	   = n6 index register associted in hardware to frame pointer
   39	   = n7 index register associted in hardware to stack pointer
*/
#define FIXED_REGISTERS   \
 {0, 0, 0, 0, 0, 0, 0, 0, \
  0, 0, 0, 0, 0, 0, 0, 0, \
  0, 0, 0, 0, 0, 0, 0, 0, \
  1, 0, 0, 0, 0, 0, 1, 0, \
  1, 0, 0, 0, 0, 0, 1, 0}

/* Like FIXED_REGISTERS but has a 1 for each register that is clobbered
   ( in general ) by function calls. This macro therefore identifies the
   registers that are not available for general allocation of values that
   live across function calls.
   If a register has 0 in CALL_USED_REGISTERS the compiler automatically
   saves it on function entry if the register is used within that function.

   These must include the FIXED_REGISTERS and also any
   registers that can be used without being saved.
   The latter must include the registers where values are returned
   and the register where structure-value addresses are passed.
   Aside from that, you can include as many other registers as you like.  */
#define CALL_USED_REGISTERS  \
 {1, 1, 1, 1, 1, 1, 0, 0, \
  0, 0, 0, 0, 0, 0, 0, 0, \
  0, 0, 0, 0, 0, 0, 0, 0, \
  1, 0, 0, 0, 0, 0, 1, 0, \
  1, 0, 0, 0, 0, 0, 1, 0}

/* Return number of consecutive hard regs needed starting at reg REGNO
   to hold something of mode MODE.
   This is ordinarily the length in words of a value of mode MODE
   but can be less for certain modes in special long registers.

   m96k puts floats and doubles into 96 bit registers, double integers
   into 64 bit registers and everything else into 32 bit registers */

#define HARD_REGNO_NREGS(REGNO, MODE) \
    ( ( MODE == DFmode || MODE == SFmode ) ? 3 : ( MODE == DImode ) ? 2 : 1 )

/* Value is 1 if hard register REGNO can hold a value of machine-mode MODE.
   For m96k, data registers are allocated on a mode 3 basis. DFmode
   is also restricted to data registers */ 

#define HARD_REGNO_MODE_OK(REGNO, MODE)\
    (((MODE) == DFmode || (MODE) == SFmode || (MODE) == DImode )\
     ? (( REGNO < 24 ) && ( 0 == ( REGNO % 3 ))) 	\
     : 1 )

/* Value is 1 if it is a good idea to tie two pseudo registers
   when one has mode MODE1 and one has mode MODE2.
   If HARD_REGNO_MODE_OK could produce different values for MODE1 and MODE2,
   for any hard reg, then this must be 0 for correct output.  
   For m96k DFmode cannot be tieable because HARD_REGNO_MODE_OK
   is not the same for DFmode and other modes */

#define MODES_TIEABLE_P(MODE1, MODE2) 		\
    (((MODE1) == DFmode || (MODE1) == SFmode ) &&\
     ((MODE2) == DFmode || (MODE2) == SFmode ))

/* Specify the registers used for certain standard purposes.
   The values of these macros are register numbers.  */

/* m96k has a dedicated pc */
#undef PC_REGNUM

/* Register to use for pushing function arguments.  */
#define STACK_POINTER_REGNUM 30

/* Base register for access to local variables of the function.  */
#define FRAME_POINTER_REGNUM 24

/* Value should be nonzero if functions must have frame pointers.
   Zero means the frame pointer need not be set up (and parms
   may be accessed via the stack pointer) in functions that seem suitable.
   This is computed in `reload', in reload1.c.  */
#define FRAME_POINTER_REQUIRED 1

/* Base register for access to arguments of the function.  */
/* m96k uses the frame pointer (r6) to as the argument pointer */
#define ARG_POINTER_REGNUM FRAME_POINTER_REGNUM

/* Register in which static-chain is passed to a function.  */
/* This is currently not used but this may change for pascal or ada or ... */
#define STATIC_CHAIN_REGNUM 15

/* Register in which address to store a structure value
   is passed to a function.  */
/* pcc for the m96k returns pointer types in r0 and all others in d0,
   however there does not seem to be a way to get gcc to do the same thing.
   */
#define STRUCT_VALUE_REGNUM 31


/* Define the classes of registers for register constraints in the
   machine description.  Also define ranges of constants.

   One of the classes must always be named ALL_REGS and include all hard regs.
   If there is more than one class, another class must be named NO_REGS
   and contain no registers.

   The name GENERAL_REGS must be the name of a class (or an alias for
   another name such as ALL_REGS).  This is the class of registers
   that is allowed by "g" or "r" in a register constraint.
   Also, registers outside this class are allocated only when
   instructions express preferences for them.

   The classes must be numbered in nondecreasing order; that is,
   a larger-numbered class must never be contained completely
   in a smaller-numbered class.

   For any two classes, it is very desirable that there be another
   class that represents their union.  */
   
/* dsp96k register set looks like this:

   d0..d7 are general purpose date registers each of which can be
   used as either a set of three 32 bit registers or as a single 96
   bit register. In general, only the low 32 bits of each register
   can be used for integer type instructions. The only execeptions
   are shift instructions which use the high order 32 bits as a shift
   count.
   
   d8..d9 are 96 bit registers identical in type to d0..d7. However d8..d9
   cannot be used by most opcodes.

   r0..r7 are 32 bit address registers.

   n0..n7 are 32 bit index registers.

   For the compiler the register set will be used as follows:

	   data type			register class

	   integer 			d0..d7

	   floating point		d0..d7

	   pointer			r0..r7

   n0..n7 will be used as index registers and also for pointer,
   integer operations such a multiplication. They will have to be
   allocated based on the name of the address register being used
   i.e for r0, n0 will have to be allocated. */

enum reg_class
{
    NO_REGS,
    LO_DATA_REGS,
    HI_DATA_REGS,
    DI_REGS,
    FP_REGS,
    ADDR_REGS,
    DATA_OR_ADDR_REGS,
    INDX_REGS,
    ALL_REGS,
    LIM_REG_CLASSES
};

#define N_REG_CLASSES (int) LIM_REG_CLASSES

/* Since GENERAL_REGS is the same class as ALL_REGS,
   don't give it a different class number; just make it an alias.  */

#define GENERAL_REGS ALL_REGS

/* Give names of register classes as strings for dump file.   */

#define REG_CLASS_NAMES {					\
	"NO_REGS", "LO_DATA_REGS", "HI_DATA_REGS",		\
	"DI_REGS", "FP_REGS", "ADDR_REGS", "DATA_OR_ADDR_REGS",	\
	"INDX_REGS", "ALL_REGS"					\
								}

/* Define which registers fit in which classes.
   This is an initializer for a vector of HARD_REG_SET
   of length N_REG_CLASSES.  */

#define REG_CLASS_CONTENTS {					\
	000000000000, 000000000000,	/* NO_REGS */		\
	000011111111, 000000000000,	/* LO_DATA_REGS .l */	\
	000044444444, 000000000000,	/* HI_DATA_REGS .h */	\
	000033333333, 000000000000,     /* DI_REGS .ml */       \
	000077777777, 000000000000,	/* FP_REGS */		\
	037700000000, 000000000000,	/* ADDR_REGS */		\
	037711111111, 000000000000,	/* DATA_OR_ADDR_REGS */	\
	000000000000, 000000000377,	/* INDX_REGS */		\
	037777777777, 000000000377 	/* ALL_REGS */		};	

/* The same information, inverted:
   Return the class number of the smallest class containing
   reg number REGNO.  This could be a conditional expression
   or could index an array.  */

#define REGNO_REG_CLASS(REGNO)					\
    (( 24 <= REGNO ) ? 						\
     (( 32 > REGNO ) ? ADDR_REGS : INDX_REGS ) :		\
     (( 0 == REGNO % 3 ) ? LO_DATA_REGS :			\
      (( 1 == REGNO % 3 ) ? DATA_OR_ADDR_REGS : HI_DATA_REGS )))

/* The class value for index registers, and the one for base regs.  */
#define INDEX_REG_CLASS INDX_REGS
#define BASE_REG_CLASS ADDR_REGS

/* Get reg_class from a letter such as appears in the machine description.  */

#define REG_CLASS_FROM_LETTER(C) ( 'd' == ( C )			\
				  ? LO_DATA_REGS		\
				  : ( 'h' == ( C )		\
				     ? HI_DATA_REGS		\
				     : ( 'a' == ( C )		\
					? ADDR_REGS		\
					: ( 'f' == ( C )	\
					   ? FP_REGS		\
					   : ( 'n' == ( C )	\
					      ? INDX_REGS	\
					      : ( 'D' == ( C )  \
						 ? DI_REGS      \
						 : NO_REGS ))))))


/* The letters I, J, K, L and M in a register constraint string
   can be used to stand for particular ranges of immediate operands.
   This macro defines what the ranges are.
   C is the letter, and VALUE is a constant value.
   Return 1 if VALUE is in the range specified by C.
*/
#define CONST_OK_FOR_LETTER_P(VALUE, C)  			\
    ( ( 'I' == ( C ) && 0 == ( VALUE ))				\
     || ( 'J' == ( C ) && ( 1 ==  ( VALUE )))			\
     || ( 'K' == ( C ) && ( -2 <= ( VALUE ) && 2 >= ( VALUE )))	\
     || ( 'L' == ( C ) && ( 0 == ( 0xfff80000 & ( VALUE )))))

/* Similar, but for floating constants, and defining letters G and H.
   Here VALUE is the CONST_DOUBLE rtx itself.  */

#define CONST_DOUBLE_OK_FOR_LETTER_P(VALUE, C) 0

/* Given an rtx X being reloaded into a reg required to be
   in class CLASS, return the class of reg to actually use.
   In general this is just CLASS; but on some machines
   in some cases it is preferable to use a more restrictive class.  */
#define PREFERRED_RELOAD_CLASS(X,CLASS) (CLASS)

/* Return the maximum number of consecutive registers
   needed to represent mode MODE in a register of class CLASS.  */
/* For m96k a data register can hold any value except a double integer
   an address register can only hold a 32 bit quantity, meaning that a 
   double float stored in an address register would require two registers.
   However, it is not really possible in the hardware to store a double
   into a pair of address registers, so this had better never come up. */
#define CLASS_MAX_NREGS(CLASS, MODE)					\
    (((CLASS) == FP_REGS && ((MODE) == DFmode || (MODE) == SFmode )) ? 3 :\
     (((CLASS) == DI_REGS && (MODE) == DImode ) ? 2 : 1 ))

/* Stack layout; function entry, exit and calling.  */

#define PUSH_ARGS_REVERSED

/* Define this if pushing a word on the stack
   makes the stack pointer a smaller address.  */
#undef STACK_GROWS_DOWNWARD

/* Define this if the nominal address of the stack frame
   is at the high-address end of the local variables;
   that is, each additional local variable allocated
   goes at a more negative offset in the frame. */

#undef FRAME_GROWS_DOWNWARD 

/* Offset within stack frame to start allocating local variables at.
   If FRAME_GROWS_DOWNWARD, this is the offset to the END of the
   first local allocated.  Otherwise, it is the offset to the BEGINNING
   of the first local allocated.  */
#define STARTING_FRAME_OFFSET 0

/* If we generate an insn to push BYTES bytes,
   this says how many the stack pointer really advances by. */
/* #define PUSH_ROUNDING(BYTES) ( BYTES ) - 1 size on 96k. */
#define PUSH_ROUNDING(BYTES) ( BYTES ) 

/* If BYTES is the size of arguments for a function call,
   return the size of the argument block (which is BYTES suitably rounded).
   Define this only on machines where the entire call block is allocated
   before the args are stored into it.  */
   
#undef ROUND_CALL_BLOCK_SIZE

/* Offset of first parameter from the argument pointer register value.  */
#define FIRST_PARM_OFFSET(FNDECL) \
    local_first_parm_offset ( FNDECL )

/* Value is 1 if returning from a function call automatically
   pops the arguments described by the number-of-args field in the call.
   FUNTYPE is the data type of the function (as a tree),
   or for a library call it is an identifier node for the subroutine name.  */

#define RETURN_POPS_ARGS(FUNTYPE) 1

/* Define how to find the value returned by a function.
   VALTYPE is the data type of the value (as a tree).
   If the precise function being called is known, FUNC is its FUNCTION_DECL;
   otherwise, FUNC is 0.  */

#define LIBCALL_VALUE(MODE)  gen_rtx (REG, MODE, 0)

#define FUNCTION_VALUE(VALTYPE, FUNC)  LIBCALL_VALUE ( TYPE_MODE (VALTYPE) )

/* Define how to find the value returned by a library function
   assuming the value has mode MODE.  */

/* 1 if N is a possible register number for a function value
   as seen by the caller.*/

#define FUNCTION_VALUE_REGNO_P(N) ( 0 == ( N ) )

/* 1 if N is a possible register number for function argument passing. */

#define FUNCTION_ARG_REGNO_P(N) ( 0 == ( N ) || 3 == ( N ) )

/* Define a data type for recording info about an argument list
   during the scan of that argument list.  This data type should
   hold all necessary information about the function itself
   and about the args processed so far, enough to enable macros
   such as FUNCTION_ARG to determine where the next arg should go.
*/
#define CUMULATIVE_ARGS int

/* Initialize a variable CUM of type CUMULATIVE_ARGS
   for a call to a function whose data type is FNTYPE.
   For a library call, FNTYPE is 0.
*/
#define INIT_CUMULATIVE_ARGS(CUM,FNTYPE) \
 ((CUM) = 0 )

/* Update the data in CUM to advance over an argument
   of mode MODE and data type TYPE.
   (TYPE is null for libcalls where that information may not be available.)  */

#define FUNCTION_ARG_ADVANCE(CUM, MODE, TYPE, NAMED) ((CUM) ++)

/* Determine where to put an argument to a function.
   Value is zero to push the argument on the stack,
   or a hard register in which to store the argument.

   MODE is the argument's machine mode.
   TYPE is the data type of the argument (as a tree).
    This is null for libcalls where that information may
    not be available.
   CUM is a variable of type CUMULATIVE_ARGS which gives info about
    the preceding args and about the function being called.
   NAMED is nonzero if this argument is a named parameter
    (otherwise it is an extra parameter matching an ellipsis).  */

#define FUNCTION_ARG(CUM, MODE, TYPE, NAMED)			\
(( 2 <= CUM || BLKmode == MODE || 0 == NAMED )			\
 ? 0 : gen_rtx ( REG, ( MODE ), 3 * CUM ))

/* Define where a function finds its arguments.
   This would be different from FUNCTION_ARG if we had register windows.  */

#define FUNCTION_INCOMING_ARG(CUM, MODE, TYPE, NAMED)\
    local_function_incoming_arg ( CUM, MODE, TYPE, NAMED )

/* For an arg passed partly in registers and partly in memory,
   this is the number of registers used.
   For args passed entirely in registers or entirely in memory, zero.  */

#define FUNCTION_ARG_PARTIAL_NREGS(CUM, MODE, TYPE, NAMED) 0

/* This macro generates the assembly code for function entry.
   FILE is a stdio stream to output the code to.
   SIZE is an int: how many units of temporary storage to allocate.
   Refer to the array `regs_ever_live' to determine which registers
   to save; `regs_ever_live[I]' is nonzero if register number I
   is ever used in the function.  This macro is responsible for
   knowing which registers should not be saved even if used.  */

#define FUNCTION_PROLOGUE(FILE, SIZE) function_logue ( FILE, SIZE, 0 )

/* Output assembler code to FILE to increment profiler label # LABELNO
   for profiling a function entry.
   m96k cannot profile. */

#define FUNCTION_PROFILER(FILE, LABELNO) 

/* EXIT_IGNORE_STACK should be nonzero if, when returning from a function,
   the stack pointer does not matter.  The value is tested only in
   functions that have frame pointers.
   No definition is equivalent to always zero.  */

#define EXIT_IGNORE_STACK 0

/* This macro generates the assembly code for function exit,
   on machines that need it.  If FUNCTION_EPILOGUE is not defined
   then individual return instructions are generated for each
   return statement.  Args are same as for FUNCTION_PROLOGUE.

   The function epilogue should not depend on the current stack pointer!
   It should use the frame pointer only.  This is mandatory because
   of alloca; we also take advantage of it to omit stack adjustments
   before returning.  */

#define FUNCTION_EPILOGUE(FILE, SIZE) function_logue ( FILE, SIZE, 1 )

/* If the memory address ADDR is relative to the frame pointer,
   correct it to be relative to the stack pointer instead.
   This is for when we don't use a frame pointer.
   ADDR should be a variable name.  */

#define FIX_FRAME_POINTER_ADDRESS(ADDR,DEPTH) 

/* Addressing modes, and classification of registers for them.  */

#define HAVE_POST_INCREMENT
#define HAVE_POST_DECREMENT

#undef HAVE_PRE_DECREMENT
#undef HAVE_PRE_INCREMENT 

/* Macros to check register numbers against specific register classes.  */

/* These assume that REGNO is a hard or pseudo reg number.
   They give nonzero only if REGNO is a hard reg of the suitable class
   or a pseudo reg currently allocated to a suitable hard reg.
   Since they use reg_renumber, they are safe only once reg_renumber
   has been allocated, which happens in local-alloc.c.  */

#define REGNO_OK_FOR_BASE_P(REGNO)  				\
    ( ( REGNO < 32 && REGNO > 23 ) || 				\
    ( ( ( unsigned ) reg_renumber[REGNO] < 32 ) &&		\
    ( ( unsigned ) reg_renumber[REGNO] > 23 ) ) )

#define REGNO_OK_FOR_INDEX_P(REGNO) 				\
    ( ( REGNO < 40 && REGNO > 31 ) || 				\
    ( ( ( unsigned ) reg_renumber[REGNO] < 40 ) &&		\
    ( ( unsigned ) reg_renumber[REGNO] > 31 ) ) )

/* Now macros that check whether X is a register and also,
   strictly, whether it is in a specified class.

   These macros are specific to the the m96000, and may be used only
   in code for printing assembler insns and in conditions for
   define_optimization.  */

/* Maximum number of registers that can appear in a valid memory address.  */

#define MAX_REGS_PER_ADDRESS 1

/* Recognize any constant value that is a valid address.  */

#define CONSTANT_ADDRESS_P(X)  CONSTANT_P (X)

/* Nonzero if the constant value X is a legitimate general operand.
   It is given that X satisfies CONSTANT_P or is a CONST_DOUBLE.  */

#define LEGITIMATE_CONSTANT_P(X) (CONSTANT_P(X))

/* The macros REG_OK_FOR..._P assume that the arg is a REG rtx
   and check its validity for a certain class.
   We have two alternate definitions for each of them.
   The usual definition accepts all pseudo regs; the other rejects
   them unless they have been allocated suitable hard regs.
   The symbol REG_OK_STRICT causes the latter definition to be used.

   Most source files want to accept pseudo regs in the hope that
   they will get allocated to the class that the insn wants them to be in.
   Source files for reload pass need to be strict.
   After reload, it makes no difference, since pseudo regs have
   been eliminated by then.  */

# ifndef REG_OK_STRICT

/*
 * Nonzero if X is a hard reg that can be used as an index
 * or if it is a pseudo reg.
 */
# define REG_OK_FOR_INDEX_P(X) ( ( REG_P ( X )				\
				 && ( REGNO ( X ) < FIRST_PSUEDO_REG ) )\
			       ?					\
			       REGNO_OK_FOR_INDEX ( REGNO ( P ) )	\
			       :					\
			       REG_P ( X ) )

/*
 * Nonzero if X is a hard reg that can be used as a base reg
 * or if it is a pseudo reg.
 */
# define REG_OK_FOR_BASE_P(X)  ( ( REG_P ( X )				\
				 && ( REGNO ( X ) < FIRST_PSUEDO_REG ) )\
			       ?					\
			       REGNO_OK_FOR_BASE ( REGNO ( X ) )	\
			       :					\
			       REG_P ( X ) )
# else

/* Nonzero if X is a hard reg that can be used as an index.  */
# define REG_OK_FOR_INDEX_P(X) REGNO_OK_FOR_INDEX_P (REGNO (X))

/* Nonzero if X is a hard reg that can be used as a base reg.  */
# define REG_OK_FOR_BASE_P(X) REGNO_OK_FOR_BASE_P (REGNO (X))

# endif

/* GO_IF_LEGITIMATE_ADDRESS recognizes an RTL expression
   that is a valid memory address for an instruction.
   The MODE argument is the machine mode for the MEM expression
   that wants to use this address.

   On the m96000, the actual legitimate addresses must be REG+REG or
   REG+SMALLINT. But we can treat a SYMBOL_REF as legitimate if it is
   part of this function's constant-pool, because such addresses can
   actually be output as REG+SMALLINT.  */

# ifdef REG_OK_STRICT
# define GO_IF_LEGITIMATE_ADDRESS(MODE, X, ADDR) 		\
    if ( go_if_legitimate_address ( MODE, X, 1 ) ) goto ADDR;
# else
# define GO_IF_LEGITIMATE_ADDRESS(MODE, X, ADDR) 		\
    if ( go_if_legitimate_address ( MODE, X, 0 ) ) goto ADDR;
# endif

/* Try machine-dependent ways of modifying an illegitimate address
   to be legitimate.  If we find one, return the new, valid address.
   This macro is used in only one place: `memory_address' in explow.c.

   OLDX is the address as it was before break_out_memory_refs was called.
   In some cases it is useful to look at this to decide what needs to be done.

   MODE and WIN are passed so that this macro can use
   GO_IF_LEGITIMATE_ADDRESS.

   It is always safe for this macro to do nothing.  It exists to recognize
   opportunities to optimize the output.  */

#define LEGITIMIZE_ADDRESS(X,OLDX,MODE,WIN)

/* Go to LABEL if ADDR (a legitimate address expression)
   has an effect that depends on the machine mode it is used for.
   The m96000 is word addressed with 64 bits at each address so
   this is never true.  */

# define GO_IF_MODE_DEPENDENT_ADDRESS(ADDR,LABEL)


/* Specify the machine mode that this machine uses
   for the index in the tablejump instruction.  */
#define CASE_VECTOR_MODE SImode

/* Define this if a raw index is all that is needed for a
   `tablejump' insn.  */
#undef CASE_TAKES_INDEX_RAW

/* Define this if the tablejump instruction expects the table
   to contain offsets from the address of the table.
   Do not define this if the table should contain absolute addresses.  */
#undef CASE_VECTOR_PC_RELATIVE

/* Specify the tree operation to be used to convert reals to integers.  */
#define IMPLICIT_FIX_EXPR FIX_ROUND_EXPR

/* This is the kind of divide that is easiest to do in the general case.  */
#define EASY_DIV_EXPR TRUNC_DIV_EXPR

/* Define this as 1 if `char' should by default be signed; else as 0.  */
#define DEFAULT_SIGNED_CHAR 1

/* Max number of bytes we can move from memory to memory
   in one reasonably fast instruction.  */
#define MOVE_MAX 1

/* We can't use move by pieces due to l space problems. */
#define MOVE_RATIO 0
#define MOVE_RATIO_96 5

/* Nonzero if access to memory by bytes is slow and undesirable.  */
#define SLOW_BYTE_ACCESS 1

/* Do not break .stabs pseudos into continuations.  */
#define DBX_CONTIN_LENGTH 0

/* Value is 1 if truncating an integer of INPREC bits to OUTPREC bits
   is done just by pretending it is already truncated.  */
#define TRULY_NOOP_TRUNCATION(OUTPREC, INPREC) \
    ( 32 == OUTPREC && 64 == INPREC )

/* We assume that the store-condition-codes instructions store 0 for false
   and some other value for true.  This is the value stored for true.  */

#define STORE_FLAG_VALUE 1

/* Specify the machine mode that pointers have.
   After generation of rtl, the compiler makes no further distinction
   between pointers and any other objects of this machine mode.  */
#define Pmode SImode

/* A function address in a call instruction
   is a byte address (for indexing purposes)
   so give the MEM rtx a byte's mode.  */
#define FUNCTION_MODE SImode

/* Define this if addresses of constant functions
   shouldn't be put through pseudo regs where they can be cse'd.
   Desirable on machines where ordinary constants are expensive
   but a CALL with constant address is cheap.  */
#undef NO_FUNCTION_CSE

/* Compute the cost of computing a constant rtl expression RTX
   whose rtx-code is CODE.  The body of this macro is a portion
   of a switch statement.  If the code is computed here,
   return it with a return statement.  Otherwise, break from the switch.  */

#define CONST_COSTS(RTX,CODE) \
  case CONST_INT:						\
  case CONST:							\
  case LABEL_REF:						\
  case SYMBOL_REF:						\
  case CONST_DOUBLE:						\
    return 2;

/* Store in cc_status the expressions
   that the condition codes will describe
   after execution of an instruction whose pattern is EXP.
   Do not alter them if the instruction would not alter the cc's.  */

#define NOTICE_UPDATE_CC(EXP, INSN) notice_update_cc ( EXP, INSN )

/* Control the assembler format that we output.  */

/* Output at beginning of assembler file.  */

#define ASM_FILE_START(FILE) asm_file_start ( FILE ) 

# define ASM_FILE_END(FILE) asm_file_end ( FILE )

/* Output to assembler file text saying following lines
   may contain character constants, extra white space, comments, etc.  */
extern char* asm_app_toggle ();
#define ASM_APP_ON asm_app_toggle ()

/* Output to assembler file text saying following lines
   no longer contain unusual constructs.  */

#define MAX_TEXT_ALIGN 1

#define ASM_APP_OFF asm_app_toggle ()

#define SELECT_RTX_SECTION( MODE, X )					\
{									\
    if ( GET_MODE_BITSIZE ( MODE ) > MAX_TEXT_ALIGN )			\
    {									\
	data_section ();						\
    }									\
    else								\
    {									\
	text_section ();						\
    }									\
}

#define SELECT_SECTION(DECL)						    \
{									    \
    if ( FUNCTION_DECL == TREE_CODE ( DECL ) )				    \
	{ text_section (); } else { data_section (); }			    \
}


/* Output before read-only data.  */

char *text_section_asm_op ( );
#define TEXT_SECTION_ASM_OP text_section_asm_op ( )

/* Output before writable data.  */

char *data_section_asm_op ( );
#define DATA_SECTION_ASM_OP data_section_asm_op ( )

/* How to refer to registers in assembler output.
   This sequence is indexed by compiler's hard-register-number (see above).  */

#define REGISTER_NAMES 				\
{ "d0", "d0", "d0", "d1", "d1", "d1",		\
  "d2", "d2", "d2", "d3", "d3", "d3",		\
  "d4", "d4", "d4", "d5", "d5", "d5",		\
  "d6", "d6", "d6", "d7", "d7", "d7",		\
  "r0", "r1", "r2", "r3", "r4", "r5",		\
  "r6", "r7",					\
  "n0", "n1", "n2", "n3", "n4", "n5",		\
  "n6", "n7" }

/* How to renumber registers for dbx and gdb.  */

#define DBX_REGISTER_NUMBER(REGNO) (REGNO)

/* This is how to output the definition of a user-level label named NAME,
   such as the label on a static function or variable NAME.  */

#define ASM_IDENTIFY_GCC(FILE) fprintf ( FILE, ";*** DSP96002 %s GNU %s\n", motorola_version_string, version_string );

#define ASM_OUTPUT_LABEL(FILE,NAME)	\
  do { assemble_name (FILE, NAME); fputs ("\n", FILE); } while (0)

/* This is how to output a command to make the user-level label named NAME
   defined for reference from other files.  */

#define ASM_GLOBALIZE_LABEL(FILE,NAME)	\
( fputs ("\tglobal\t", FILE), assemble_name (FILE, NAME), fputs ("\n", FILE) )

/* This is how to output a reference to a user-level label named NAME.
   `assemble_name' uses this.  */

#define ASM_OUTPUT_LABELREF(FILE,NAME)	\
  fprintf (FILE, "F%s", NAME)

/* This is how to output an internal numbered label where
   PREFIX is the class of label and NUM is the number within the class.  */

#define ASM_OUTPUT_INTERNAL_LABEL(FILE,PREFIX,NUM)	\
  fprintf (FILE, "%s%d\n", PREFIX, NUM)

/* This is how to store into the string LABEL
   the symbol_ref name of an internal numbered label where
   PREFIX is the class of label and NUM is the number within the class.
   This is suitable for output with `assemble_name'.  */

#define ASM_GENERATE_INTERNAL_LABEL(LABEL,PREFIX,NUM)	\
  sprintf (LABEL, "*%s%d", PREFIX, NUM)

/* This is how to output an assembler line defining a `double' constant.  */

#define ASM_OUTPUT_DOUBLE(FILE,VALUE)  \
    (( 'l' == memory_model ) ?\
      (void) fprintf (FILE, "\tdc\t%.20e\n", (VALUE)) :\
      ((void) fprintf (FILE, "\tdc\t(@lfr(%.20e))>>32\n", (VALUE)),\
       (void) fprintf (FILE, "\tdc\t(@lfr(%.20e))&$ffffffff\n", (VALUE))))

/* This is how to output an assembler line defining a `float' constant.  */

#define ASM_OUTPUT_FLOAT(FILE,VALUE)  \
  fprintf (FILE, "\tdc\t@frc(%.12e)\n", (VALUE))

/* This is how to output an assembler line defining an `int' constant.  */

#define ASM_OUTPUT_INT(FILE,VALUE)  \
( fprintf (FILE, "\tdc "),			\
  output_addr_const (FILE, (VALUE)),		\
  fprintf (FILE, "\n"))

/* Likewise for `short' and `char' constants.  */

#define ASM_OUTPUT_SHORT(FILE,VALUE)  \
( fprintf (FILE, "\tdc "),			\
  output_addr_const (FILE, (VALUE)),		\
  fprintf (FILE, "\n"))

#define ASM_OUTPUT_CHAR(FILE,VALUE)  \
( fprintf (FILE, "\tdc "),			\
  output_addr_const (FILE, (VALUE)),		\
  fprintf (FILE, "\n"))

/* This is how to output an assembler line for a numeric constant byte.  */

#define ASM_OUTPUT_BYTE(FILE,VALUE)  \
  fprintf (FILE, "\tdc $%x\n", (VALUE))

#define ASM_OUTPUT_ASCII(FILE, P, SIZE)  \
  output_ascii (FILE, P, SIZE)

# define ASM_OUTPUT_CASE_LABEL(STREAM, PREFIX, NUM, TABLE ) 	\
  ( fprintf (STREAM, "%s\n", DATA_SECTION_ASM_OP ),		\
  ASM_OUTPUT_INTERNAL_LABEL(STREAM, PREFIX, NUM))

# define ASM_OUTPUT_CASE_END(STREAM, NUM, TABLE ) 		\
  fprintf (STREAM, "%s\n", TEXT_SECTION_ASM_OP )		\

/* This is how to output an element of a case-vector that is relative.  */

#define ASM_OUTPUT_ADDR_DIFF_ELT(FILE, VALUE, REL)  \
  fprintf (FILE, "\tdc L%d-L%d\n", VALUE, REL)

/* This is how to output an element of a case-vector that is absolute.  */

#define ASM_OUTPUT_ADDR_VEC_ELT(FILE, VALUE)  \
  fprintf (FILE, "\tdc L%d\n", VALUE)

/* This is how to output an assembler line
   that says to advance the location counter
   to a multiple of 2**LOG bytes.  */

#define ASM_OUTPUT_ALIGN(FILE,LOG)	\
  if ((LOG) != 0)			\
    fprintf (FILE, "\t;align %d\n", 1<<(LOG))

#define ASM_OUTPUT_SKIP(FILE,SIZE)  \
  fprintf (FILE, "\tbsc\t%d,0\n", (SIZE))

/* This says how to output an assembler line
   to define a global common symbol.  */

#define ASM_OUTPUT_COMMON(FILE, NAME, SIZE, ROUNDED)  		\
( assemble_name ((FILE), (NAME)),				\
  fprintf ((FILE), "\tbsc\t%d\n", (ROUNDED)),			\
  ASM_GLOBALIZE_LABEL((FILE),(NAME)))

/* This says how to output an assembler line
   to define a local common symbol.  */

#define ASM_OUTPUT_LOCAL(FILE, NAME, SIZE, ROUNDED)  \
( assemble_name ((FILE), (NAME)),				\
  fprintf ((FILE), "\tbsc\t%d,0\n", (ROUNDED)))

/* Store in OUTPUT a string (made with alloca) containing
   an assembler-name for a local static variable named NAME.
   LABELNO is an integer which is different for each call.  */

#define ASM_FORMAT_PRIVATE_NAME(OUTPUT, NAME, LABELNO)	\
( (OUTPUT) = (char *) alloca (strlen ((NAME)) + 10),	\
  sprintf ((OUTPUT), "___%s%d", (NAME), (LABELNO)))

/* Define the parentheses used to group arithmetic operations
   in assembler code.  */

#define ASM_OPEN_PAREN "("
#define ASM_CLOSE_PAREN ")"

/* Define results of standard character escape sequences.  */
#define TARGET_BELL 007
#define TARGET_BS 010
#define TARGET_TAB 011
#define TARGET_NEWLINE 012
#define TARGET_VT 013
#define TARGET_FF 014
#define TARGET_CR 015

/* Print operand X (an rtx) in assembler syntax to file FILE.
   CODE is a letter or dot (`z' in `%z0') or 0 if no letter was specified.
   For `%' followed by punctuation, CODE is the punctuation and X is null.
*/

#define PRINT_OPERAND(FILE, X, CODE) print_operand ( FILE, X, CODE )

/* Print a memory address as an operand to reference that memory location.  */

#define PRINT_OPERAND_ADDRESS(FILE, ADDR) print_operand_address ( FILE, ADDR )

# define ASM_OUTPUT_REG_PUSH( FILE, REGNO )
# define ASM_OUTPUT_REG_POP( FILE, REGNO )

# define ASM_OUTPUT_OPCODE( FILE, OPCODE ) asm_output_opcode ( FILE, OPCODE )

extern double ldexp ( );

/* the following definitions and declarations are used to efficiently
   implement the use of either memory space. */

/* this structure is used within the code generator. it is initialized upon
   first use. */

struct dsp_string
{
    int init;
    char string[256];
};

/* RETURN_DSP provides a mechanism for the code generator to use this facility
   transparently. */

#define RETURN_DSP( str ) \
{ static struct dsp_string template = { 0, str }; \
      return fix_mem_space ( & template ); }

/* global memory space indicator - either 'x' or 'y'. */
extern char mem_space;
extern char memory_model;
/* tells sdbout which prolog/epilog pair is being used. */
extern int logue_index;

extern char *fix_mem_space ( );

/* this data type is used to pass information about the function to the
   optimizer and code generator, and pro/epilog generators. */

typedef enum 
{
    FUNC_NO_INFO = 0x0000,
    FUNC_ISNT_LEAF = 0x0001, /* this func makes at least one call */
    FUNC_RETURNS_FLOAT = 0x0002, /* a float/double value is returned */
    FUNC_HAS_STACK_PARMS = 0x0004, /* this func has at least one stack parm */
    FUNC_RETURNS_VOID =0x0008 /* this function is of type void. */
} func_attributes;

/* a global var used for the aformentioned purpose. */
extern func_attributes current_func_info;

/* this enum is used as the mdep portion of cc_... structs. branches, conds and
   jumps on the 96k need to know whether the ccs were set by a floating point
   instruction or not. */

typedef enum
{
    INTEGER_CCS, /* regular cmp or integer op. */
    FLOAT_CCS    /* fcmp or floating op. */
} compare_type;

#define CC_STATUS_MDEP_INIT INTEGER_CCS
#define CC_STATUS_MDEP compare_type

/* these force a min number of operands allowed. */
#define MIN_RECOG_OPERANDS 16
#define MIN_DUP_OPERANDS 16

/* we undef abort so that we can print a proper warning message and not dump
   core. (code in rtl.c) */
#undef abort

typedef struct
{
    int no_latency_addr_reg_op_p;
}
dsp96k_insn_info;

#define INSN_MACHINE_INFO dsp96k_insn_info

/* allow certain pragmas. */
int dsp_process_pragma_line ( );

#define TARGET_PROCESS_PRAGMA_LINE( f ) \
dsp_process_pragma_line ( f )
