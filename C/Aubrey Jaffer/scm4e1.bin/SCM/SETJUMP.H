/* Scheme implementation intended for JACAL.
   Copyright (C) 1990, 1991, 1992, 1993, 1994 Aubrey Jaffer.
   See the file "COPYING" for terms applying to this program */

#ifdef vms
# ifndef CHEAP_CONTINUATIONS

   typedef int jmp_buf[17];
   extern int setjump(jmp_buf env);
   extern int longjump(jmp_buf env, int ret);

#  define setjmp setjump
#  define longjmp longjump
# else
#  include <setjmp.h>
# endif
#else				/* ndef vms */
# ifdef _CRAY1
    typedef int jmp_buf[112];
    extern int setjump(jmp_buf env);
    extern int longjump(jmp_buf env, int ret);

#   define setjmp setjump
#   define longjmp longjump
# else				/* ndef _CRAY1 */
#   include <setjmp.h>
# endif				/* ndef _CRAY1 */
#endif				/* ndef vms */


/* James Clark came up with this neat one instruction fix for
   continuations on the SPARC.  It flushes the register windows so
   that all the state of the process is contained in the stack. */

#ifdef sparc
#define FLUSH_REGISTER_WINDOWS asm("ta 3")
#else
#define FLUSH_REGISTER_WINDOWS /* empty */
#endif

/* If stack is not longword aligned then */

/* #define SHORT_ALIGN */
#ifdef THINK_C
#define SHORT_ALIGN
#endif
#ifdef MSDOS
#define SHORT_ALIGN
#endif
#ifdef atarist
#define SHORT_ALIGN
#endif

/* If stacks grow up then */

/* #define STACK_GROWS_UP */
#ifdef hp9000s800
#define STACK_GROWS_UP
#endif
#ifdef pyr
#define STACK_GROWS_UP
#endif
#ifdef nosve
#define STACK_GROWS_UP
#endif
#ifdef _UNICOS
#define STACK_GROWS_UP
#endif

/* CELL_UP and CELL_DN are used by init_heap_seg to find cell aligned inner
   bounds for allocated storage */

#ifdef PROT386
/*in 386 protected mode we must only adjust the offset */
#define CELL_UP(p) MK_FP(FP_SEG(p),~7&(FP_OFF(p)+7))
#define CELL_DN(p) MK_FP(FP_SEG(p),~7&FP_OFF(p))
#else
#ifdef _UNICOS
#define CELL_UP(p) (CELLPTR)(~1L & ((long)(p)+1L))
#define CELL_DN(p) (CELLPTR)(~1L & (long)(p))
#else
#define CELL_UP(p) (CELLPTR)(~(sizeof(cell)-1L) & ((long)(p)+sizeof(cell)-1L))
#define CELL_DN(p) (CELLPTR)(~(sizeof(cell)-1L) & (long)(p))
#endif				/* UNICOS */
#endif				/* PROT386 */

/* how to get the local definition for malloc */

#ifndef STDC_HEADERS
	char *malloc();
	char *realloc();
	int free();
	char *tmpnam();
	int chdir();
	int unlink();
	int link();
	char *ttyname();
/* from paulh@harlequin.com */
	int fputc ();
	int fputs ();
	sizet fwrite ();
	int fgetc ();
	int ungetc ();
	int fclose ();
	int fflush ();
	int pclose ();
#endif

/* These are parameters for controlling memory allocation.  The heap
   is the area out of which cons and object headers is allocated.
   Each heap object is 8 bytes on a 32 bit machine and 16 bytes on a
   64 bit machine.  The units of the _SIZE parameters are bytes.

   INIT_HEAP_SIZE is the initial size of heap.  If this much heap is
   allocated initially the heap will grow by half its current size
   each subsequent time more heap is needed.

   If INIT_HEAP_SIZE heap cannot be allocated initially, HEAP_SEG_SIZE
   will be used, and the heap will grow by HEAP_SEG_SIZE when more
   heap is needed.  HEAP_SEG_SIZE must fit into type sizet.  This code
   is in init_storage() and alloc_some_heap() in sys.c

   If INIT_HEAP_SIZE can be allocated initially, the heap will grow by
   EXPHEAP(heap_size) when more heap is needed.

   MIN_HEAP_SEG_SIZE is minimum size of heap to accept when more heap
   is needed.

   INIT_MALLOC_LIMIT is the initial amount of malloc usage which will
   trigger a GC. */

#define INIT_HEAP_SIZE (25000L*sizeof(cell))
#define MIN_HEAP_SEG_SIZE (2000L*sizeof(cell))
#ifdef _QC
#define HEAP_SEG_SIZE 32400L
#else
#ifdef sequent
#define HEAP_SEG_SIZE (7000L*sizeof(cell))
#else
#define HEAP_SEG_SIZE (8100L*sizeof(cell))
#endif
#endif
#define EXPHEAP(heap_size) (heap_size*2)
#define INIT_MALLOC_LIMIT 100000

#ifdef SHORT_ALIGN
typedef short STACKITEM;
#else
typedef long STACKITEM;
#endif

typedef struct {jmp_buf jmpbuf; SCM dynenv; STACKITEM *base;} regs;
#define JMPBUF(x) (((regs *)CHARS(x))->jmpbuf)
#define SETJMPBUF SETCDR
#define DYNENV(x) (((regs *)CHARS(x))->dynenv)
#define BASE(x) (((regs *)CHARS(x))->base)
void dowinds();
