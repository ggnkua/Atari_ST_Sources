/* target def file for atarist (both TOS and MINIX), for use with GNU CC */

/* The following Macros control the compilation
 *
 *	CROSSATARI	defined when making cross compiler for TOS or Minix
 *	MINIX		defined when making cross compiler for MINIX only
 *	atariminix	defined when making compiler for MINIX
 *	atarist		defined when making compiler for TOS
 */

#include "tm-m68k.h"

#ifndef CROSSATARI
#  ifndef atarist
#    undef alloca
#  endif
#else
#  ifdef sparc
#    undef alloca
#    include <alloca.h>
#  endif
#endif

/* See tm-m68k.h.  0 means 68000 with no 68881.  */

#define TARGET_DEFAULT 0

/* These compiler options take an argument. We have none for now.  */

#define WORD_SWITCH_TAKES_ARG(STR)	(0)

/* -m68020 requires special flags to the assembler.  */

/* -m68000 (on atari) need this flag to assembler, otherwise pc relative
   code is produced where it should not be (in places where the
   68000 only allows data ALTERABLE addressing modes) (++jrb 03/19/89) */
#define ASM_SPEC "%{m68020:-mc68020}%{!m68020:-m68000}"

/* Names to predefine in the preprocessor for this target machine.  */

#if (defined(MINIX) || defined(atariminix))
#define CPP_PREDEFINES "-DATARI_ST -Dminix -Dm68k"
#else
#define CPP_PREDEFINES "-Datarist -Dgem -Dm68k"
#endif

/* default exec dir */
#ifndef STANDARD_EXEC_PREFIX
#ifdef MINIX
#define STANDARD_EXEC_PREFIX "/net/acae127/home/bammi/atari/cross-minix/lib/gcc-"
#else
#ifdef atariminix
#define STANDARD_EXEC_PREFIX "/usr/local/lib/gcc-"
#else
#define STANDARD_EXEC_PREFIX "/net/acae127/home/bammi/atari/cross-gcc/lib/gcc-"
#endif
#endif
#endif

/* Alignment of field after `int : 0' in a structure.  */
/* recent gcc's have this as 16, this is left in for the benfit of */
 /* older gcc */
#undef EMPTY_FIELD_BOUNDARY
#define EMPTY_FIELD_BOUNDARY 16

/* Every structure or union's size must be a multiple of 2 bytes.  */

#undef STRUCTURE_SIZE_BOUNDARY
#define STRUCTURE_SIZE_BOUNDARY 16

/* code seems to assume this... */
#define DBX_DEBUGGING_INFO

#ifndef HAVE_VPRINTF
#define HAVE_VPRINTF 1
#endif

#ifdef abort
#undef abort
#define abort fancy_abort
#endif


/* the following stolen from tm-sun3.h, they seem to work better */
/* This is how to output an assembler line defining a `double' constant.  */

#undef ASM_OUTPUT_DOUBLE
#define ASM_OUTPUT_DOUBLE(FILE,VALUE)					\
  (isinf ((VALUE))							\
   ? fprintf (FILE, "\t.double 0r%s99e999\n", ((VALUE) > 0 ? "" : "-")) \
   : double_is_minus_zero ((VALUE))					\
   ? fprintf (FILE, "\t.long 0x80000000,0\n")				\
   : fprintf (FILE, "\t.double 0r%.20e\n", (VALUE)))

/* This is how to output an assembler line defining a `float' constant.  */

#undef ASM_OUTPUT_FLOAT
#define ASM_OUTPUT_FLOAT(FILE,VALUE)					\
  (isinf ((VALUE))							\
   ? fprintf (FILE, "\t.single 0r%s99e999\n", ((VALUE) > 0 ? "" : "-")) \
   : double_is_minus_zero ((VALUE))					\
   ? fprintf (FILE, "\t.long 0x80000000\n")				\
   : fprintf (FILE, "\t.single 0r%.20e\n", (VALUE)))

#undef ASM_OUTPUT_FLOAT_OPERAND
#define ASM_OUTPUT_FLOAT_OPERAND(FILE,VALUE)				\
  (isinf ((VALUE))							\
   ? fprintf (FILE, "#0r%s99e999", ((VALUE) > 0 ? "" : "-")) 		\
   : double_is_minus_zero ((VALUE))					\
   ? fprintf (FILE, "#0r-0.0")						\
   : fprintf (FILE, "#0r%.9g", (VALUE)))

#undef ASM_OUTPUT_DOUBLE_OPERAND
#define ASM_OUTPUT_DOUBLE_OPERAND(FILE,VALUE)				\
  (isinf ((VALUE))							\
   ? fprintf (FILE, "#0r%s99e999", ((VALUE) > 0 ? "" : "-"))		\
   : double_is_minus_zero ((VALUE))					\
   ? fprintf (FILE, "#0r-0.0")						\
   : fprintf (FILE, "#0r%.20g", (VALUE)))


/* specs for start file and link specs */

#ifndef CROSSATARI

#ifdef atariminix
#define STARTFILE_SPEC  \
  "%{pg:/usr/local/lib/gcrtso.o%s}\
   %{!pg:\
         %{p:/usr/local/lib/mcrtso.o%s}\
         %{!p:/usr/local/lib/crtso.o%s}}"
#else /* atarist */
#define STARTFILE_SPEC  \
 "%{mint:\
     %{pg:$GNULIB$\\mgcrt0.o%s}\
     %{!pg:\
         %{p:$GNULIB$\\mmcrt0.o%s}\
         %{!p:$GNULIB$\\mcrt0.o%s}}}\
\
  %{!mint:\
     %{pg:$GNULIB$\\gcrt0.o%s}\
     %{!pg:\
         %{p:$GNULIB$\\mcrt0.o%s}\
         %{!p:$GNULIB$\\crt0.o%s}}}"
#endif

#else	/* CROSSATARI */

#ifdef MINIX
#define STARTFILE_SPEC  \
  "%{pg:/net/acae127/home/bammi/atari/cross-minix/lib/gcrtso.o%s}\
   %{!pg:\
         %{p:/net/acae127/home/bammi/atari/cross-minix/lib/mcrtso.o%s}\
         %{!p:/net/acae127/home/bammi/atari/cross-minix/lib/crtso.o%s}}"
#else
#define STARTFILE_SPEC  \
  "%{mint:\
      %{pg:/net/acae127/home/bammi/atari/cross-gcc/lib/mgcrt0.o%s}\
      %{!pg:\
             %{p:/net/acae127/home/bammi/atari/cross-gcc/lib/mmcrt0.o%s}\
             %{!p:/net/acae127/home/bammi/atari/cross-gcc/lib/mcrt0.o%s}}}\
\
  %{!mint:\
      %{pg:/net/acae127/home/bammi/atari/cross-gcc/lib/gcrt0.o%s}\
      %{!pg:\
             %{p:/net/acae127/home/bammi/atari/cross-gcc/lib/mcrt0.o%s}\
             %{!p:/net/acae127/home/bammi/atari/cross-gcc/lib/crt0.o%s}}}"
#endif
#endif /* CROSSATARI */

#ifdef MINIX
#define LIB_SPEC \
  "%{mshort:/net/acae127/home/bammi/atari/cross-minix/lib/libc.a}\
   %{!mshort:/net/acae127/home/bammi/atari/cross-minix/lib/libc32.a}"
#else
#ifdef atariminix
#define LIB_SPEC \
  "%{mshort:/usr/local/lib/libc.a}\
   %{!mshort:/usr/local/lib/libc32.a}"
#else /* atarist cross or native */
#define LIB_SPEC \
 "%{mint:\
   %{!gg:\
         %{mshort:-lmint16 -lgnu16}\
         %{!mshort:-lmint -lgnu}}\
    %{gg:\
         %{mshort:-lmintg16 -lgnugdb16}\
         %{!mshort:-lmintg -lgnugdb}}}\
\
  %{!mint:\
   %{!gg:\
         %{mshort:-lgnu16}\
         %{!mshort:-lgnu}}\
    %{gg:\
         %{mshort:-lgnugdb16}\
         %{!mshort:-lgnugdb}}}"
#endif
#endif

/* add -mint : meanining
   pre-procees with -D__MINT__
   compile with -mint	(target_flags & 0200) (this flag is
	 currently not used by cc1, but maybe later)
   link with mcrt0.o and -lmint -lgnu
   
 */
#undef TARGET_SWITCHES
#define TARGET_SWITCHES  \
  { { "68020", 5},				\
    { "c68020", 5},				\
    { "68881", 2},				\
    { "bitfield", 4},				\
    { "68000", -5},				\
    { "c68000", -5},				\
    { "soft-float", -0102},			\
    { "nobitfield", -4},			\
    { "rtd", 8},				\
    { "nortd", -8},				\
    { "short", 040},				\
    { "noshort", -040},				\
    { "fpa", 0100},				\
    { "nofpa", -0100},				\
    { "int", 0200},				\
    { "noint", -0200},				\
    { "", TARGET_DEFAULT}}
