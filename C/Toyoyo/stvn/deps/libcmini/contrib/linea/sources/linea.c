/*
 * function form of linea bindings
 *	++jrb
 */

#define __NO_INLINE__ 1
#include <mint/linea.h>

/*
 * lineA globals for both inline and non-inline lineA bindings
 */

	/* global vars */
/* Pointer to line a parameter block returned by init 	*/
 __LINEA *__aline;

/* Array of pointers to the three system font  headers
   returned by init (in register A1)	           	*/
 __FONT  **__fonts;

/* Array of pointers to the 16 line a functions returned
   by init (in register A2) only valid in ROM'ed TOS     */
#ifdef __STDC__
 short  (**__funcs)(void);
#else
 short  (**__funcs)();
#endif


#ifdef __GNUC__
#ifdef __mcoldfire__

#define PUSH_SP(regs,size)						\
	"lea	%%sp@(-" #size "),%%sp\n\t"					\
	"movml	" regs ",%%sp@\n\t"

#define POP_SP(regs,size)						\
	"movml	%%sp@," regs "\n\t"					\
	"lea	%%sp@(" #size "),%%sp\n\t"

#else

#define PUSH_SP(regs,size)						\
	"movml	" regs ",%%sp@-\n\t"

#define POP_SP(regs,size)						\
	"movml	%%sp@+," regs "\n\t"

#endif
#endif

#ifdef __mcoldfire__
	// On ColdFire V4e, the standard Line A opcodes
	// conflict with some valid MAC instructions.
	// Fortunately, the following range is always invalid
	// and triggers the standard Line A exception.
	// The ColdFire OS will keep only the last 4 bits
	#define LINEA_OPCODE_BASE 0xa920
#else
	#define LINEA_OPCODE_BASE 0xa000
#endif
	#define ASM_LINEA3(opcode) ".word	" #opcode
	#define ASM_LINEA2(opcode) ASM_LINEA3(opcode)
	#define ASM_LINEA(n) ASM_LINEA2(LINEA_OPCODE_BASE+n)


void linea0(void)
{
        register __LINEA *__xaline __asm__ ("a0");
        register __FONT **__xfonts __asm__ ("a1");
        register short (**__xfuncs) (void) __asm__ ("a2");

        __asm__ volatile
        (
		ASM_LINEA(0x0)
        : "=g"(__xaline), "=g"(__xfonts), "=g"(__xfuncs)  /* outputs */
        :                                                 /* inputs  */
        : __CLOBBER_RETURN("a0") __CLOBBER_RETURN("a1") __CLOBBER_RETURN("a2") "d0", "d1", "d2", "cc"       /* clobbered regs */
	  AND_MEMORY
        );

        __aline = __xaline;
        __fonts = __xfonts;
        __funcs = __xfuncs;
}

void linea1(void)
{
	__asm__ volatile
	(
		ASM_LINEA(0x1)
	: 						  /* outputs */
	: 						  /* inputs  */
	: "d0", "d1", "d2", "a0", "a1", "a2", "cc"       /* clobbered regs */
	  AND_MEMORY
	);
}

int linea2(void)
{
	register long retvalue __asm__("d0");

	__asm__ volatile
	(
		ASM_LINEA(0x2)
	: "=r"(retvalue)				  /* outputs */
	: 						  /* inputs  */
	: __CLOBBER_RETURN("d0") "d1", "d2", "a0", "a1", "a2", "cc"       /* clobbered regs */
	  AND_MEMORY
	);

	return (int) retvalue;
}

void linea3(void)
{
	__asm__ volatile
	(
		ASM_LINEA(0x3)
	: 						  /* outputs */
	: 						  /* inputs  */
	: "d0", "d1", "d2", "a0", "a1", "a2", "cc"       /* clobbered regs */
	  AND_MEMORY
	);
}

void linea4(void)
{
	__asm__ volatile
	(
		ASM_LINEA(0x4)
	: 						  /* outputs */
	: 						  /* inputs  */
	: "d0", "d1", "d2", "a0", "a1", "a2", "cc"       /* clobbered regs */
	  AND_MEMORY
	);
}

void linea5(void)
{
	__asm__ volatile
	(
		ASM_LINEA(0x5)
	: 						  /* outputs */
	: 						  /* inputs  */
	: "d0", "d1", "d2", "a0", "a1", "a2", "cc"       /* clobbered regs */
	  AND_MEMORY
	);
}

void linea6(void)
{
	__asm__ volatile
	(
		ASM_LINEA(0x6)
	: 						  /* outputs */
	: 						  /* inputs  */
	: "d0", "d1", "d2", "a0", "a1", "a2", "cc"       /* clobbered regs */
	  AND_MEMORY
	);
}

void linea7(BBPB *P)
{
	__asm__ volatile
	(
		"movl	%%a6,-(%%sp)\n\t"
 		"movl	%0,%%a6\n\t"
		ASM_LINEA(0x7) "\n\t"
		"movl	(%%sp)+,%%a6\n\t"
	: 						  /* outputs */
	: "r"(P)					  /* inputs  */
	: "d0", "d1", "d2", "a0", "a1", "a2", "cc"		   /* clobbered regs */
	  AND_MEMORY
	);
}

void linea8(void)
{
	__asm__ volatile
	(
		ASM_LINEA(0x8)
	: 						  /* outputs */
	: 						  /* inputs  */
	: "d0", "d1", "d2", "a0", "a1", "a2", "cc"       /* clobbered regs */
	  AND_MEMORY
	);
}

void linea9(void)
{
	__asm__ volatile
	(
		ASM_LINEA(0x9)
	: 						  /* outputs */
	: 						  /* inputs  */
	: "d0", "d1", "d2", "a0", "a1", "a2", "cc"       /* clobbered regs */
	  AND_MEMORY
	);
}

void lineaa(void)
{
	__asm__ volatile
	(
		ASM_LINEA(0xa)
	: 						  /* outputs */
	: 						  /* inputs  */
	: "d0", "d1", "d2", "a0", "a1", "a2", "cc"       /* clobbered regs */
	  AND_MEMORY
	);
}

void lineab(void)
{
	__asm__ volatile
	(
		ASM_LINEA(0xb)
	: 						  /* outputs */
	: 						  /* inputs  */
	: "d0", "d1", "d2", "a0", "a1", "a2", "cc"       /* clobbered regs */
	  AND_MEMORY
	);
}

void lineac(void *P)
{
	__asm__ volatile
	(
 		"movl	%0,%%a2\n\t"
		ASM_LINEA(0xc)
	: 						  /* outputs */
	: "r"(P)					  /* inputs  */
	: "d0", "d1", "d2", "a0", "a1", "a2", "cc"              /* clobbered regs */
	  AND_MEMORY
	);
}

void linead(int x, int y,  SFORM * sd, void *ss)
{
	__asm__ volatile
	(
 		"movw	%0,%%d0\n\t"
 		"movw	%1,%%d1\n\t"
 		"movl	%2,%%a0\n\t"
 		"movl	%3,%%a2\n\t"
		ASM_LINEA(0xd)
	: 						  /* outputs */
	: "r"((short)x), "r"((short)y), "r"(sd), "r"(ss)  /* inputs  */
	: "d0", "d1", "d2", "a0", "a1", "a2", "cc"              /* clobbered regs */
	  AND_MEMORY
	);
}

void lineae(void)
{
	__asm__ volatile
	(
		ASM_LINEA(0xe)
	: 						  /* outputs */
	: 						  /* inputs  */
	: "d0", "d1", "d2", "a0", "a1", "a2", "cc"       /* clobbered regs */
	  AND_MEMORY
	);
}

void lineaf(void)
{
	__asm__ volatile
	(
		ASM_LINEA(0xf)
	: 						  /* outputs */
	: 						  /* inputs  */
	: "d0", "d1", "d2", "a0", "a1", "a2", "cc"       /* clobbered regs */
	  AND_MEMORY
	);
}
