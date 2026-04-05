/*  libc-symbols.h -- MiNTLib.
    Copyright (C) 2000 Guido Flohr <guido@freemint.de>

    This file is part of the MiNTLib project, and may only be used
    modified and distributed under the terms of the MiNTLib project
    license, COPYMINT.  By continuing to use, modify, or distribute
    this file you indicate that you have read the license and
    understand and accept it fully.
*/

/* Support macros for making weak and strong aliases for symbols,
   and for using symbol sets and linker warnings with GNU ld.  */

#ifndef _LIBC_SYMBOLS_H
# define _LIBC_SYMBOLS_H 1

#ifndef	_FEATURES_H
# include <features.h>
#endif

/* See <linker.h>.  That is also one of the files that you have to edit
   if you want to add support for other linkers.  Currently supported
   are recent versions of GNU ld and older versions of GNU ld only
   when compiled with gcc (so that we have at least strong aliases).  */
   
#ifdef __HAVE_GNU_LD
# define HAVE_WEAK_SYMBOLS
#endif

#ifndef __SYMBOL_PREFIX
# define __SYMBOL_PREFIX __STRINGIFY(__USER_LABEL_PREFIX__)
# define __ASM_SYMBOL_PREFIX __USER_LABEL_PREFIX__
#endif

#ifndef C_SYMBOL_NAME
# ifdef __ASSEMBLER__
#   define C_SYMBOL_NAME2(pref, name) pref##name
#   define C_SYMBOL_NAME1(pref, name) C_SYMBOL_NAME2(pref, name)
#   define C_SYMBOL_NAME(name) C_SYMBOL_NAME1(__ASM_SYMBOL_PREFIX, name)
# else
#   define C_SYMBOL_NAME(name) __SYMBOL_PREFIX #name
# endif
#endif

#ifndef __ASSEMBLER__

# ifdef __GNUC__

/* Define ALIAS as a strong alias for ORIGINAL.  */
#  define strong_alias(name, aliasname) _strong_alias(name, aliasname)
#  define _strong_alias(original, alias) \
  __asm__ (".globl " C_SYMBOL_NAME(alias) "\n\t" \
       ".set " C_SYMBOL_NAME(alias) "," C_SYMBOL_NAME(original));

/* Define ALIAS as a weak alias for ORIGINAL.  */
#  ifdef HAVE_WEAK_SYMBOLS
#   define weak_alias(name, aliasname) _weak_alias (name, aliasname)
#   define _weak_alias(original, alias) \
  __asm__ (".weak " C_SYMBOL_NAME(alias) "\n\t" \
       C_SYMBOL_NAME(alias) " = " C_SYMBOL_NAME(original));

/* Declare SYMBOL as weak undefined symbol (resolved to 0 if not defined).  */
# define weak_extern(symbol) _weak_extern (weak symbol)
# define _weak_extern(expr) _Pragma (#expr)

/* This comes between the return type and function name in
   a function definition to make that definition weak.  */
# define weak_function __attribute__ ((weak))
# define weak_const_function __attribute__ ((weak, __const__))

#  endif  /* !__HAVE_WEAK_SYMBOLS */

/* When a reference to SYMBOL is encountered, the linker will emit a
   warning message MSG.  */
# ifdef __HAVE_GNU_LD
#  define link_warning(symbol, msg) \
  __asm__(".stabs \"" msg "\",30,0,0,0\n\t" \
      ".stabs \"_" #symbol "\",1,0,0,0");
# endif  /* __HAVE_GNU_LD */

# endif  /* !__GNUC__ */

# ifndef strong_alias
#  error You have to find a way how to define strong aliases.
# endif

# ifndef weak_alias
#  define weak_alias(original, alias) strong_alias(original, alias)
# endif

# ifndef weak_extern
#  define weak_extern(symbol)  /* Do nothing, the reference will be strong.  */
# endif

# ifndef link_warning
#  define link_warning(symbol, msg)  /* Our warning will be unheard.  */
# endif

#else   /* !__ASSEMBLER__ */

#ifndef C_LABEL
/* Define a macro we can use to construct the asm name for a C symbol.  */
#define C_LABEL(name)		C_SYMBOL_NAME(name):
#endif

#define	ENTRY(name)							      \
  .globl C_SYMBOL_NAME(name);						      \
  C_LABEL(name)

/* Mark the end of function named SYM.  This is used on some platforms
   to generate correct debugging information.  */
#ifndef END
#define END(sym)
#endif

#undef PSEUDO_END
#define PSEUDO_END(name)						      \
  END (name)

# ifdef HAVE_WEAK_SYMBOLS
#  define weak_alias(original, alias)  \
	.weak C_SYMBOL_NAME (alias);	\
	C_SYMBOL_NAME (alias) = C_SYMBOL_NAME (original)

#   define weak_extern(symbol)		\
	.weak C_SYMBOL_NAME (symbol)
	
# else  /* !HAVE_WEAK_SYMBOLS */
#  define weak_alias(original, alias)  \
	.globl C_SYMBOL_NAME (alias)	\
	C_SYMBOL_NAME (alias) = C_SYMBOL_NAME (original)

#  define weak_extern(symbol)		\
	.globl C_SYMBOL_NAME (symbol)

# endif /* !HAVE_WEAK_SYMBOLS */

/* Makros to generate eh_frame unwind information.  */
#ifdef __ELF__
# define cfi_startproc			.cfi_startproc
# define cfi_endproc			.cfi_endproc
# define cfi_def_cfa(reg, off)		.cfi_def_cfa reg, off
# define cfi_def_cfa_register(reg)	.cfi_def_cfa_register reg
# define cfi_def_cfa_offset(off)	.cfi_def_cfa_offset off
# define cfi_adjust_cfa_offset(off)	.cfi_adjust_cfa_offset off
# define cfi_offset(reg, off)		.cfi_offset reg, off
# define cfi_rel_offset(reg, off)	.cfi_rel_offset reg, off
# define cfi_register(r1, r2)		.cfi_register r1, r2
# define cfi_return_column(reg)	.cfi_return_column reg
# define cfi_restore(reg)		.cfi_restore reg
# define cfi_same_value(reg)		.cfi_same_value reg
# define cfi_undefined(reg)		.cfi_undefined reg
# define cfi_remember_state		.cfi_remember_state
# define cfi_restore_state		.cfi_restore_state
# define cfi_window_save		.cfi_window_save
# define cfi_personality(enc, exp)	.cfi_personality enc, exp
# define cfi_lsda(enc, exp)		.cfi_lsda enc, exp
#else
# define cfi_startproc
# define cfi_endproc
# define cfi_def_cfa(reg, off)
# define cfi_def_cfa_register(reg)
# define cfi_def_cfa_offset(off)
# define cfi_adjust_cfa_offset(off)
# define cfi_offset(reg, off)
# define cfi_rel_offset(reg, off)
# define cfi_register(r1, r2)
# define cfi_return_column(reg)
# define cfi_restore(reg)
# define cfi_same_value(reg)
# define cfi_undefined(reg)
# define cfi_remember_state
# define cfi_restore_state
# define cfi_window_save
# define cfi_personality(enc, exp)
# define cfi_lsda(enc, exp)
#endif

#endif  /* !__ASSEMBLER__ */

/* Currently disabled since not supported by gcc for MiNT.  FIXME!!! */
#if (0 && !defined __ASSEMBLER__ && \
     (__GNUC_PREREQ(2,7)))
/* GCC 2.7 and later has special syntax for weak symbols and aliases.
   Using that is better when possible, because the compiler and assembler
   are better clued in to what we are doing.  */
# undef	strong_alias
# define strong_alias(name, aliasname) \
  extern __typeof (name) aliasname __attribute__ ((alias (#name)));

# ifdef HAVE_WEAK_SYMBOLS
#  undef weak_alias
#  define weak_alias(name, aliasname) \
  extern __typeof (name) aliasname __attribute__ ((weak, alias (#name)));

/* This comes between the return type and function name in
   a function definition to make that definition weak.  */
#  define weak_function __attribute__ ((weak))
#  define weak_const_function __attribute__ ((weak, __const__))

# endif	/* HAVE_WEAK_SYMBOLS.  */
#endif	/* Not __ASSEMBLER__, and GCC 2.7 or later.  */

#ifndef weak_function
/* If we do not have the __attribute__ ((weak)) syntax, there is no way we
   can define functions as weak symbols.  The compiler will emit a `.globl'
   directive for the function symbol, and a `.weak' directive in addition
   will produce an error from the assembler.  */
# define weak_function		/* empty */
# define weak_const_function	/* empty */
#endif

/* On some platforms we can make internal function calls (i.e., calls of
   functions not exported) a bit faster by using a different calling
   convention.  */
#ifndef internal_function
# define internal_function	/* empty */
#endif

/* Prepare for the case that `__builtin_expect' is not available.  */
#ifndef HAVE_BUILTIN_EXPECT
# define __builtin_expect(expr, val) (expr)
#endif

#endif /* libc-symbols.h */
