/* Scheme implementation intended for JACAL.
   Copyright (C) 1990, 1991, 1992 Aubrey Jaffer.
   See the file "COPYING" for terms applying to this program */

/* SCMVERSION is a string for the version specifier.  The number is
the major version number and the trailing letter is the revision:
"a" for alpha release, "b" for beta release, "c", "d", and so on.
There is a separate PATCHLEVEL defined in "patchlvl.h" */

#ifndef SCMVERSION
#define SCMVERSION "4a"
#endif

/* If your scheme code runs under this program without any errors you
can disable almost all error checking by compiling all files with this
line or better yet by changing the makefile. */

/* #define RECKLESS */

/* IMPLINIT is the full pathname (surrounded by double quotes) of
Init.scm, the Scheme initialization code.  This is best defined in the
makefile, if possible.  If available, scm uses the value of
environment variable SCM_INIT_PATH instead of IMPLINIT. */

/* #define IMPLINIT "/usr/jaffer/scm/Init.scm" */

/* INITS is calls to initialization routines for any compiled
libraries being linked into scm.  This is best done in the makefile. */

/* #define INITS init_db() */

/* Define SYNTAX_EXTENSIONS if you want DEFINED? */

#define SYNTAX_EXTENSIONS

/* Define REV2_PROCEDURES if you need substring-move-left!,
substring-move-right!, substring-fill!, append!, and last-pair.  You
can remove the object file for sc2.c from linking if REV2_PROCEDURES
is not defined. */

#define REV2_PROCEDURES

/* Define IO_EXTENSIONS if you want R/W files and file-position */

#define IO_EXTENSIONS

/* Only some machines have pipes */
#ifdef IO_EXTENSIONS
# if defined (unix) || defined (__MINT__)
   /* DJGPP (gcc for i386) defines unix! */
#  ifndef GNUDOS
#   define HAVE_PIPE
#  endif
# endif
#endif

/* Define BIGDIG to an integer type whose size is smaller than long if
you want bignums.  BIGNUMS ARE NOT IMPLEMENTED YET. */

/* #define BIGDIG short */

/* Define FLOATS if you want floating point numbers.  This is best
done in the Makefile */

/* #define FLOATS */

/* Define SINGLES if you want single precision floats and
   (sizeof (float) == sizeof (long)) */

#ifdef FLOATS
#define SINGLES
#endif
  
/* Define SINGLESONLY if you want all inexact real numbers to be
   single precision.  This only has an effect if SINGLES is also
   defined.  This does not affect complex numbers */

/* #define SINGLESONLY */

/* Define ENGNOT if you want floats to display in engineering notation
(exponents always multiples of 3) instead of scientific notation. */

#define ENGNOT

/* FLOBUFLEN is the maximum number of characters you expect to be
neccessary for the printed or string representation of an inexact
number.  This assumes that sizeof is in units of 8 bits. */

# ifdef FLOATS
#  define FLOBUFLEN (10+5*sizeof(double))
# endif /* FLOATS */

/* INTBUFLEN is the maximum number of characters you expect to be
neccessary for the printed or string representation of an exact
number.  This assumes that sizeof is in units of 8 bits. */

#define INTBUFLEN (5+8*sizeof(long))

/* MEMOIZE_LOCALS will speed up most local variable references.  You
will need to remove this and recompile eval.c if you use very large or
deep environments (more than 32767 bound variables in one procedure)*/

#define MEMOIZE_LOCALS

/* PROT386 should be defined on the compilation command line if the program
is to be run on an intel 386 in protected mode.  `Huge' pointers common on
MSDOS compilers do not work in protected mode.  PROT386 is required if scm is
to run as part of a Microsoft Windows application.
Added by Stephen Adams 8 May 92 */

/* #define PROT386 */
#ifndef THINK_C
# ifdef __WINDOWS__		/* there should be a better flag for this. */
#  define PROT386
# endif
#endif

/* PTR_LT defines how to compare two CELLPTRs (which may not be in the
same array).  CELLPTR is a pointer to a cons cell which may be
compared or differenced.  SCMPTR is used for stack bounds. */

#ifdef __TURBOC__
# define MSDOS
# ifdef PROT386
typedef cell *CELLPTR;
typedef SCM *SCMPTR;
#  define PTR_LT(x,y) (((long)(x)) < ((long)(y)))
# else
typedef cell huge *CELLPTR;
typedef SCM  huge *SCMPTR;
#  define PTR_LT(x,y) ((x) < (y))
# endif
#else /* not __TURBOC__ */
typedef cell *CELLPTR;
typedef SCM  *SCMPTR;
# ifdef nosve
#  define PTR_MASK 0xffffffffffff
#  define PTR_LT(x,y) (((int)(x)&PTR_MASK) < ((int)(y)&PTR_MASK))
# else
#  define PTR_LT(x,y) ((x) < (y))
# endif
#endif

/* STDC_HEADERS indicates that the include file names are the same as
ANSI C.  For most modern systems this is the case. */

/* added by Yasuaki Honda */
#ifdef THINK_C
#define __STDC__
#endif

#ifdef __STDC__
#define STDC_HEADERS
#endif
#ifdef MSDOS
#define STDC_HEADERS
#endif
#ifdef vms
#define STDC_HEADERS
#endif
#ifdef nosve
#define STDC_HEADERS
#endif

#ifdef STDC_HEADERS
# include <stdlib.h>
# ifdef AMIGA
#  include <stddef.h>
# endif
# define sizet size_t
#else
# ifdef _SIZE_T
#  define sizet size_t
# else
#  define sizet unsigned int
# endif
#endif

#ifdef sequent
#include <strings.h>
#define strchr index
#define strrchr rindex
#else
#include <string.h>
#endif

/* On VMS, GNU C's errno.h contains a special hack to get link attributes
   for errno correct for linking to the C RTL. */

#include <errno.h>

/* SYSCALL retries system calls that have been interrupted (EINTR) */

#ifdef EINTR
# if (EINTR > 0)
#  define SYSCALL(line) do{errno=0;line}while(errno==EINTR)
# endif
#endif
#ifndef SYSCALL
# define SYSCALL(line) {line}
#endif

#ifndef MSDOS
extern int errno;
#endif
#if (__TURBOC__==1)
/* Needed for TURBOC V1.0 */
extern int errno;
#endif

/* #define CAREFUL_INTS for extra consistency checking.  This is for
   debugging C code in sys.c and repl.c. */
/* #define CAREFUL_INTS */

#ifdef CAREFUL_INTS
#define DEFER_INTS {if (ints_disabled) puts("ints already disabled"); \
		    ints_disabled = 1;}
#define ALLOW_INTS {if (!ints_disabled) puts("ints already enabled"); \
		    ints_disabled = 0;CHECK_INTS}
#else
#define DEFER_INTS {ints_disabled = 1;}
#define ALLOW_INTS {ints_disabled = 0;CHECK_INTS}
#endif
#define CHECK_INTS {if (sig_deferred) han_sig();if (alrm_deferred) han_alrm();}

/* LINE_INCREMENTORS are the characters which cause the line count to
be incremented for the purposes of error reporting.  This feature is
only used for scheme code loaded from files.

WHITE_SPACES are other characters which should be treated like spaces
in programs.  in both cases sparate characters with ":case " */

#define LINE_INCREMENTORS  '\n'
#define WHITE_SPACES  ' ':case '\t':case '\r':case '\f'

/* The following 6 definitions are defined automatically by the C
pre-processor.  You will need to override these if you are
cross-compiling or if the C pre-processor has different properties
than the compiler. */

#if (((-1)%2 == -1) && ((-1)%(-2) == -1) && (1%2 == 1) && (1%(-2) == 1))
#else
#define BADIVSGNS
#endif

/* SRS is signed right shift */
/*--- Turbo C++ v1.0 has a bug with right shifts of signed longs!
      It is believed to be fixed in Turbo C++ v1.01                ---*/
#if ((((-1L)<<2)+2)>>2 == -1L) && (__TURBOC__ != 0x295)
#define SRS(x,y) ((x)>>y)
#else
#define SRS(x,y) (((x)<0) ? ~((~(x))>>y) : (x)>>y)
#endif

#if (('\n'=='\025') && (' '=='\100') && ('a'=='\201') && ('A'=='\301'))
#define EBCDIC
#endif
#if (('\n'=='\012') && (' '=='\040') && ('a'=='\141') && ('A'=='\101'))
#define ASCII
#endif

/* CHAR_CODE_LIMIT is the number of distinct characters represented by
the unsigned char datatype. */
/* most-positive-fixnum is the INUM closest to positive infinity. */
/* MOST_NEGATIVE_FIXNUM is the INUM closest to negative infinity. */

#ifdef __STDC__
#include <limits.h>
# ifdef UCHAR_MAX
#  define CHAR_CODE_LIMIT (UCHAR_MAX+1)
# else
#  define CHAR_CODE_LIMIT 256
# endif
# define MOST_POSITIVE_FIXNUM (LONG_MAX>>2)
# define MOST_NEGATIVE_FIXNUM SRS(LONG_MIN,2)
#else
# define CHAR_CODE_LIMIT 256
# define MOST_POSITIVE_FIXNUM ((unsigned long)~0L>>3)
# if (0 != ~0)
#  define MOST_NEGATIVE_FIXNUM (-MOST_POSITIVE_FIXNUM-1)
# else
#  define MOST_NEGATIVE_FIXNUM (-MOST_POSITIVE_FIXNUM)
# endif
#endif

/* the rest of "scm.h" applies only to sys.c */
#ifdef IN_SYS

/* FLTRADIX is the base of the mantissa of floating point numbers (usually 2) */
/* FLTMAX is less than or equal the largest single precision float */

#ifdef FLOATS
# ifdef STDC_HEADERS
#  ifndef GNUDOS
#   include <float.h>
#  endif
# endif
# ifdef FLT_RADIX
#  define FLTRADIX FLT_RADIX
# else
#  define FLTRADIX 2
# endif
# ifdef FLT_MAX
#  define FLTMAX FLT_MAX
# else
#  define FLTMAX 1e+23 /* 1e37 */
# endif
#endif

/* end of automatic C pre-processor definitions */

/* TEMPTEMPLATE is used only if mktemp() is being used instead of
   tmpnam(). */

#ifdef AMIGA
# define TEMPTEMPLATE "T:SchemeaaaXXXXXX";
#else
char *mktemp();
# ifdef VMS
#  define TEMPTEMPLATE "sys$scratch:aaaXXXXXX";
# else /* VMS */
#  ifdef __MSDOS__
#   ifdef GNUDOS
#    define TEMPTEMPLATE "\\tmp\\TMPaaaXXXXXX";
#   else
#    define TEMPTEMPLATE "TMPaaaXXXXXX";
#   endif
#  else /* __MSDOS__ */
#   define TEMPTEMPLATE "/tmp/aaaXXXX";
#  endif /* __MSDOS__ */
# endif /* VMS */
#endif /* AMIGA */

/* If you only need straight stack continuations CHEAP_CONTINUATIONS
will run faster and use less storage than not having it.  Machines
with unusual stacks need this.  Also, if you incorporate new C code
into scm which uses VMS system services or library routines (which
need to unwind the stack in an ordrly manner) you may need to define
CHEAP_CONTINUATIONS. */

/* #define CHEAP_CONTINUATIONS */

/* James Clark came up with this neat one instruction fix for
continuations on the SPARC.  It flushes the register windows so that
all the state of the process is contained in the stack. */

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

/* CELL_UP and CELL_DN are used by init_heap_seg to find cell aligned inner
bounds for allocated storage */

#ifdef PROT386
/*in 386 protected mode we must only adjust the offset */
#define CELL_UP(p) MK_FP(FP_SEG(p),~7&(FP_OFF(p)+7))
#define CELL_DN(p) MK_FP(FP_SEG(p),~7&FP_OFF(p))
#else
#define CELL_UP(p) (CELLPTR)(~(sizeof(cell)-1L) & ((long)(p)+sizeof(cell)-1L))
#define CELL_DN(p) (CELLPTR)(~(sizeof(cell)-1L) & (long)(p))
#endif

/* how to get the local definition for malloc */

#ifndef STDC_HEADERS
	char *malloc();
	char *realloc();
#endif

/* NUM_HASH_BUCKETS is the number of symbol hash table buckets.  */

#define NUM_HASH_BUCKETS 137

/* If fewer than MIN_GC_YIELD cells are recovered during a garbage
collection (GC) more space is allocated for the heap. */

#define MIN_GC_YIELD (heap_size/5)

/* These are parameters for controlling memory allocation.  The heap
is the area out of which cons and object headers is allocated.  Each
heap object is 8 bytes on a 32 bit machine and 16 bytes on a 64 bit
machine.  The units of the _SIZE parameters are bytes.

INIT_HEAP_SIZE is the initial size of heap.  If this much heap is
allocated initially the heap will grow by half its current size each
subsequent time more heap is needed.
If INIT_HEAP_SIZE heap cannot be allocated initially, HEAP_SEG_SIZE
will be used, and the heap will grow by HEAP_SEG_SIZE when more heap
is needed.  HEAP_SEG_SIZE must fit into type sizet.
This code is in init_storage() and alloc_some_heap() in sys.c

MIN_HEAP_SEG_SIZE is minimum size of heap to accept when more
heap is needed.  */

#define INIT_HEAP_SIZE (25000L*sizeof(cell))
#define MIN_HEAP_SEG_SIZE (2000L*sizeof(cell))
#ifdef _QC
#define HEAP_SEG_SIZE 32400L
#else
#define HEAP_SEG_SIZE (8100L*sizeof(cell))
#endif

#endif /* IN_SYS */
