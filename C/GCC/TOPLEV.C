/* Top level of GNU C compiler
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


/* This is the top level of cc1.
   It parses command args, opens files, invokes the various passes
   in the proper order, and counts the time used by each.
   Error messages and low-level interface to malloc also handled here.  */

#include "config.h"
#include <stdio.h>

#ifdef atarist
#include <signal.h>
#include <types.h>
#include <stat.h>

extern long _stksize = 500000;		/* enough to compile -O gas */

#else

#include <signal.h>

#include <sys/types.h>
#include <sys/stat.h>

#ifdef USG
#include <sys/param.h>
#include <sys/times.h>
#include <time.h>   /* Correct for hpux at least.  Is it good on other USG?  */
#else
#ifndef VMS
#include <sys/time.h>
#include <sys/resource.h>
#endif
#endif

#endif		/* atarist */

#include "tree.h"
#include "c-tree.h"
#include "rtl.h"
#include "flags.h"

extern int yydebug;

extern FILE *finput;

extern void init_lex ();
extern void init_decl_processing ();
extern void init_tree ();
extern void init_rtl ();
extern void init_optabs ();
extern void init_reg_sets ();
extern void dump_flow_info ();
extern void dump_local_alloc ();

void rest_of_decl_compilation ();
void error ();
void error_with_file_and_line ();
void set_target_switch ();

/* Bit flags that specify the machine subtype we are compiling for.
   Bits are tested using macros TARGET_... defined in the tm-...h file
   and set by `-m...' switches.  */

int target_flags;

/* Name of current original source file (what was input to cpp).
   This comes from each #-command in the actual input.  */

char *input_filename;

/* Name of top-level original source file (what was input to cpp).
   This comes from the first #-command in the actual input.  */

char *main_input_filename;

/* Current line number in real source file.  */

extern int lineno;

/* FUNCTION_DECL for function now being parsed or compiled.  */

extern tree current_function_decl;

/* Name to use as base of names for dump output files.  */

char *dump_base_name;

/* Flags saying which kinds of debugging dump have been requested.  */

int rtl_dump = 0;
int rtl_dump_and_exit = 0;
int jump_opt_dump = 0;
int cse_dump = 0;
int loop_dump = 0;
int flow_dump = 0;
int combine_dump = 0;
int local_reg_dump = 0;
int global_reg_dump = 0;
int jump2_opt_dump = 0;

/* 1 => write gdb debugging output (using symout.c).  -g
   2 => write dbx debugging output (using dbxout.c).  -G  */

enum debugger write_symbols = NO_DEBUG;

/* Nonzero means do optimizations.  -opt.  */

int optimize = 0;

/* Nonzero for -fforce-mem: load memory value into a register
   before arithmetic on it.  This makes better cse but slower compilation.  */

int flag_force_mem = 0;

/* Nonzero for -fforce-addr: load memory address into a register before
   reference to memory.  This makes better cse but slower compilation.  */

int flag_force_addr = 0;

/* Nonzero for -fdefer-pop: don't pop args after each function call;
   instead save them up to pop many calls' args with one insns.  */

int flag_defer_pop = 1;

/* Nonzero for -ffloat-store: don't allocate floats and doubles
   in extended-precision registers.  */

int flag_float_store = 0;

/* Nonzero for -fcombine-regs:
   allow instruction combiner to combine an insn
   that just copies one reg to another.  */

int flag_combine_regs = 0;

/* Nonzero for -fwritable-strings:
   store string constants in data segment and don't uniquize them.  */

int flag_writable_strings = 0;

/* Nonzero means don't put addresses of constant functions in registers.
   Used for compiling the Unix kernel, where strange substitutions are
   done on the assembly output.  */

int flag_no_function_cse = 0;

/* Nonzero for -fomit-frame-pointer:
   don't make a frame pointer in simple functions that don't require one.  */

int flag_omit_frame_pointer = 0;

/* Nonzero to inhibit use of define_optimization peephole opts.  */

int flag_no_peephole = 0;

/* Nonzero means `char' should be signed.  */

int flag_signed_char;

/* Nonzero means allow type mismatches in conditional expressions;
   just make their values `void'.   */

int flag_cond_mismatch;

/* Nonzero means don't recognize the keyword `asm'.  */

int flag_no_asm;

/* Nonzero means warn about implicit declarations.  */

int warn_implicit;

/* Nonzero means warn about function definitions that default the return type
   or that use a null return and have a return-type other than void.  */

int warn_return_type;

/* Nonzero means do some things the same way PCC does.  */

int flag_traditional;

/* Nonzero means all references through pointers are volatile.  */

int flag_volatile;

/* Nonzero means do stupid register allocation.  -noreg.
   This and `optimize' are controlled by different switches in cc1,
   but normally cc controls them both with the -O switch.  */

int obey_regdecls = 0;

/* Don't print functions as they are compiled and don't print
   times taken by the various passes.  -quiet.  */

int quiet_flag = 0;

/* Don't print warning messages.  -w.  */

int inhibit_warnings = 0;

/* Do print extra warnings (such as for uninitialized variables).  -W.  */

int extra_warnings = 0;

/* Number of error messages and warning messages so far.  */

int errorcount = 0;
int warningcount = 0;

/* Nonzero if generating code to do profiling.  */

int profile_flag = 0;

/* Nonzero for -pedantic switch: warn about anything
   that standard C forbids.  */

int pedantic = 0;

/* Nonzero means `$' can be in an identifier.
   See cccp.c for reasons why this breaks some obscure ANSI C programs.  */

#ifndef DOLLARS_IN_IDENTIFIERS
#define DOLLARS_IN_IDENTIFIERS 0
#endif
int dollars_in_ident = DOLLARS_IN_IDENTIFIERS;

/* Nonzero for -finline-functions: ok to inline functions that look like
   good inline candidates.  */

int flag_inline_functions;

/* Nonzero for -fkeep-inline-functions: even if we make a function
   go inline everywhere, keep its defintion around for debugging
   purposes.  */

int flag_keep_inline_functions;

/* Name for output file of assembly code, specified with -o.  */

char *asm_file_name;

/* Name for output file of GDB symbol segment, specified with -symout.  */

char *sym_file_name;

/* Output files for assembler code (real compiler output)
   and debugging dumps.  */

FILE *asm_out_file;
FILE *rtl_dump_file;
FILE *jump_opt_dump_file;
FILE *cse_dump_file;
FILE *loop_dump_file;
FILE *flow_dump_file;
FILE *combine_dump_file;
FILE *local_reg_dump_file;
FILE *global_reg_dump_file;
FILE *jump2_opt_dump_file;

/* Time accumulators, to count the total time spent in various passes.  */

int parse_time;
int varconst_time;
int integration_time;
int jump_time;
int cse_time;
int loop_time;
int flow_time;
int combine_time;
int local_alloc_time;
int global_alloc_time;
int final_time;
int symout_time;
int dump_time;

/* Return time used so far, in microseconds.  */

int
gettime ()
{
#ifdef atarist
  long now;
#else
#ifdef USG
  struct tms tms;
#else
#ifndef VMS
  struct rusage rusage;
#else /* VMS */
  struct
    {
      int proc_user_time;
      int proc_system_time;
      int child_user_time;
      int child_system_time;
    } vms_times;
#endif
#endif
#endif		/* atarist */

  if (quiet_flag)
    return 0;

#ifdef atarist
  return(time(NULL) * 1000000);
#else
#ifdef USG
  times (&tms);
  return (tms.tms_utime + tms.tms_stime) * (1000000 / HZ);
#else
#ifndef VMS
  getrusage (0, &rusage);
  return (rusage.ru_utime.tv_sec * 1000000 + rusage.ru_utime.tv_usec
	  + rusage.ru_stime.tv_sec * 1000000 + rusage.ru_stime.tv_usec);
#else /* VMS */
  times (&vms_times);
  return (vms_times.proc_user_time + vms_times.proc_system_time) * 10000;
#endif
#endif
#endif		/* atarist */
}

#define TIMEVAR(VAR, BODY)    \
do { int otime = gettime (); BODY; VAR += gettime () - otime; } while (0)

void
print_time (str, total)
     char *str;
     int total;
{
  fprintf (stderr,
	   "time in %s: %d.%06d\n",
	   str, total / 1000000, total % 1000000);
}

/* Count an error or warning.  Return 1 if the message should be printed.  */

int
count_error (warningp)
     int warningp;
{
  if (warningp && inhibit_warnings)
    return 0;

  if (warningp)
    warningcount++;
  else
    errorcount++;

  return 1;
}

/* Print a fatal error message.  NAME is the text.
   Also include a system error message based on `errno'.  */

void
pfatal_with_name (name)
     char *name;
{
  fprintf (stderr, "cc1: ");
  perror (name);
  exit (35);
}

void
fatal_io_error (name)
     char *name;
{
  fprintf (stderr, "cc1:%s: I/O error\n", name);
  exit (35);
}

void
fatal (s)
     char *s;
{
  error (s, 0);
  exit (34);
}

/* Called when the start of a function definition is parsed,
   this function prints on stderr the name of the function.  */

void
announce_function (decl)
     tree decl;
{
  if (! quiet_flag)
    {
      fprintf (stderr, " %s", IDENTIFIER_POINTER (DECL_NAME (decl)));
      fflush (stderr);
    }
}

/* Prints out, if necessary, the name of the current function
   which caused an error.  Called from all error and warning functions.  */

void
report_error_function()
{
  static tree last_error_function = NULL;

  if (last_error_function != current_function_decl)
    {
      if (current_function_decl == NULL)
	{
	  if (!quiet_flag)
	    fprintf (stderr, "\n");
	  fprintf (stderr, "At top level:\n");
	}
      else
	{
	  if (!quiet_flag)
	    /* We already know this info.  Don't print it twice.
	       But make sure we are at the beginning of a line.  */
	    fprintf (stderr, "\n");
	  else
	    fprintf (stderr, "In function %s:\n",
		     IDENTIFIER_POINTER (DECL_NAME (current_function_decl)));
	}
      last_error_function = current_function_decl;
    }
}

/* Report an error at the current line number.
   S and V are a string and an arg for `printf'.  */

void
error (s, v)
     char *s;
     int v;			/* @@also used as pointer */
{
  error_with_file_and_line (input_filename, lineno, s, v);
}

/* Report an error at line LINE of file FILE.
   S and V are a string and an arg for `printf'.  */

void
error_with_file_and_line (file, line, s, v)
     char *file;
     int line;
     char *s;
     int v;
{
  count_error (0);

  report_error_function ();

  if (file)
    fprintf (stderr, "%s:%d: ", file, line);
  else
    fprintf (stderr, "cc1: ");
  fprintf (stderr, s, v);
  fprintf (stderr, "\n");
}

/* Report an error at the declaration DECL.
   S is string which uses %s to substitute the declaration name.  */

void
error_with_decl (decl, s)
     tree decl;
     char *s;
{
  count_error (0);

  report_error_function ();

  fprintf (stderr, "%s:%d: ",
	   DECL_SOURCE_FILE (decl), DECL_SOURCE_LINE (decl));

  if (DECL_NAME (decl))
    fprintf (stderr, s, IDENTIFIER_POINTER (DECL_NAME (decl)));
  else
    fprintf (stderr, s, "((anonymous))");
  fprintf (stderr, "\n");
}

/* Report a warning at line LINE.
   S and V are a string and an arg for `printf'.  */

void
warning_with_line (line, s, v)
     int line;
     char *s;
     int v;
{
  if (count_error (1) == 0)
    return;

  report_error_function ();

  if (input_filename)
    fprintf (stderr, "%s:%d: ", input_filename, line);
  else
    fprintf (stderr, "cc1: ");

  fprintf (stderr, "warning: ");
  fprintf (stderr, s, v);
  fprintf (stderr, "\n");
}

/* Report a warning at the current line number.
   S and V are a string and an arg for `printf'.  */

void
warning (s, v)
     char *s;
     int v;			/* @@also used as pointer */
{
  warning_with_line (lineno, s, v);
}

/* Report a warning at the declaration DECL.
   S is string which uses %s to substitute the declaration name.  */

void
warning_with_decl (decl, s)
     tree decl;
     char *s;
{
  if (count_error (1) == 0)
    return;

  report_error_function ();

  fprintf (stderr, "%s:%d: ",
	   DECL_SOURCE_FILE (decl), DECL_SOURCE_LINE (decl));

  fprintf (stderr, "warning: ");
  if (DECL_NAME (decl))
    fprintf (stderr, s, IDENTIFIER_POINTER (DECL_NAME (decl)));
  else
    fprintf (stderr, s, "((anonymous))");
  fprintf (stderr, "\n");
}

/* When `malloc.c' is compiled with `rcheck' defined,
   it calls this function to report clobberage.  */

void
botch (s)
{
  abort ();
}

/* Same as `malloc' but report error if no memory available.  */

int
xmalloc (size)
     unsigned size;
{
  register int value = (int) malloc (size);
  if (value == 0)
    fatal ("Virtual memory exhausted.");
  return value;
}

/* Same as `realloc' but report error if no memory available.  */

int
xrealloc (ptr, size)
     char *ptr;
     int size;
{
  int result = realloc (ptr, size);
  if (!result)
    fatal ("Virtual memory exhausted.");
  return result;
}

/* Return the logarithm of X, base 2, considering X unsigned,
   if X is a power of 2.  Otherwise, returns -1.  */

int
exact_log2 (x)
     register unsigned int x;
{
  register int log = 0;
  for (log = 0; log < HOST_BITS_PER_INT; log++)
    if (x == (1 << log))
      return log;
  return -1;
}

/* Given X, an unsigned number, return the largest int Y such that 2**Y <= X.
   If X is 0, return -1.  */

int
floor_log2 (x)
     register unsigned int x;
{
  register int log = 0;
  for (log = 0; log < HOST_BITS_PER_INT; log++)
    if ((x & ((-1) << log)) == 0)
      return log - 1;
  return HOST_BITS_PER_INT - 1;
}

/* Compile an entire file of output from cpp, named NAME.
   Write a file of assembly output and various debugging dumps.  */

static void
compile_file (name)
     char *name;
{
  tree globals;
  int start_time;
  int dump_base_name_length = strlen (dump_base_name);

  parse_time = 0;
  varconst_time = 0;
  integration_time = 0;
  jump_time = 0;
  cse_time = 0;
  loop_time = 0;
  flow_time = 0;
  combine_time = 0;
  local_alloc_time = 0;
  global_alloc_time = 0;
  final_time = 0;
  symout_time = 0;
  dump_time = 0;

  /* Open input file.  */

  finput = fopen (name, "r");
  if (finput == 0)
    pfatal_with_name (name);

  /* Initialize data in various passes.  */

  init_tree ();
  init_lex ();
  init_rtl ();
  init_emit_once ();
  init_decl_processing ();
  init_optabs ();

  /* If rtl dump desired, open the output file.  */
  if (rtl_dump)
    {
      register char *dumpname = (char *) xmalloc (dump_base_name_length + 6);
      strcpy (dumpname, dump_base_name);
      strcat (dumpname, ".rtl");
      rtl_dump_file = fopen (dumpname, "w");
      if (rtl_dump_file == 0)
	pfatal_with_name (dumpname);
    }

  /* If jump_opt dump desired, open the output file.  */
  if (jump_opt_dump)
    {
      register char *dumpname = (char *) xmalloc (dump_base_name_length + 6);
      strcpy (dumpname, dump_base_name);
      strcat (dumpname, ".jump");
      jump_opt_dump_file = fopen (dumpname, "w");
      if (jump_opt_dump_file == 0)
	pfatal_with_name (dumpname);
    }

  /* If cse dump desired, open the output file.  */
  if (cse_dump)
    {
      register char *dumpname = (char *) xmalloc (dump_base_name_length + 6);
      strcpy (dumpname, dump_base_name);
      strcat (dumpname, ".cse");
      cse_dump_file = fopen (dumpname, "w");
      if (cse_dump_file == 0)
	pfatal_with_name (dumpname);
    }

  /* If loop dump desired, open the output file.  */
  if (loop_dump)
    {
      register char *dumpname = (char *) xmalloc (dump_base_name_length + 6);
      strcpy (dumpname, dump_base_name);
      strcat (dumpname, ".loop");
      loop_dump_file = fopen (dumpname, "w");
      if (loop_dump_file == 0)
	pfatal_with_name (dumpname);
    }

  /* If flow dump desired, open the output file.  */
  if (flow_dump)
    {
      register char *dumpname = (char *) xmalloc (dump_base_name_length + 6);
      strcpy (dumpname, dump_base_name);
      strcat (dumpname, ".flow");
      flow_dump_file = fopen (dumpname, "w");
      if (flow_dump_file == 0)
	pfatal_with_name (dumpname);
    }

  /* If combine dump desired, open the output file.  */
  if (combine_dump)
    {
      register char *dumpname = (char *) xmalloc (dump_base_name_length + 10);
      strcpy (dumpname, dump_base_name);
      strcat (dumpname, ".combine");
      combine_dump_file = fopen (dumpname, "w");
      if (combine_dump_file == 0)
	pfatal_with_name (dumpname);
    }

  /* If local_reg dump desired, open the output file.  */
  if (local_reg_dump)
    {
      register char *dumpname = (char *) xmalloc (dump_base_name_length + 6);
      strcpy (dumpname, dump_base_name);
      strcat (dumpname, ".lreg");
      local_reg_dump_file = fopen (dumpname, "w");
      if (local_reg_dump_file == 0)
	pfatal_with_name (dumpname);
    }

  /* If global_reg dump desired, open the output file.  */
  if (global_reg_dump)
    {
      register char *dumpname = (char *) xmalloc (dump_base_name_length + 6);
      strcpy (dumpname, dump_base_name);
      strcat (dumpname, ".greg");
      global_reg_dump_file = fopen (dumpname, "w");
      if (global_reg_dump_file == 0)
	pfatal_with_name (dumpname);
    }

  /* If jump2_opt dump desired, open the output file.  */
  if (jump2_opt_dump)
    {
      register char *dumpname = (char *) xmalloc (dump_base_name_length + 7);
      strcpy (dumpname, dump_base_name);
      strcat (dumpname, ".jump2");
      jump2_opt_dump_file = fopen (dumpname, "w");
      if (jump2_opt_dump_file == 0)
	pfatal_with_name (dumpname);
    }

  /* Open assembler code output file.  */
 
  {
    register char *dumpname = (char *) xmalloc (dump_base_name_length + 6);
    int len = strlen (dump_base_name);
    strcpy (dumpname, dump_base_name);
    if (len > 2 && ! strcmp (".c", dumpname + len - 2))
      dumpname[len - 2] = 0;
    else if (len > 3 && ! strcmp (".co", dumpname + len - 3))
      dumpname[len - 3] = 0;
    strcat (dumpname, ".s");
    if (asm_file_name == 0)
      {
	asm_file_name = (char *) malloc (strlen (dumpname) + 1);
	strcpy (asm_file_name, dumpname);
      }
    asm_out_file = fopen (asm_file_name, "w");
    if (asm_out_file == 0)
      pfatal_with_name (asm_file_name ? asm_file_name : dumpname);
  }

  input_filename = name;

  /* the beginning of the file is a new line; check for # */
  /* With luck, we discover the real source file's name from that
     and put it in input_filename.  */
  ungetc (check_newline (), finput);

  ASM_FILE_START (asm_out_file);

  /* If GDB symbol table desired, open the GDB symbol output file.  */
  if (write_symbols == GDB_DEBUG)
    {
      register char *dumpname = (char *) xmalloc (dump_base_name_length + 6);
      int len = strlen (dump_base_name);
      strcpy (dumpname, dump_base_name);
      if (len > 2 && ! strcmp (".c", dumpname + len - 2))
	dumpname[len - 2] = 0;
      else if (len > 3 && ! strcmp (".co", dumpname + len - 3))
	dumpname[len - 3] = 0;
      strcat (dumpname, ".sym");
      if (sym_file_name == 0)
	sym_file_name = dumpname;
      symout_init (sym_file_name, asm_out_file, main_input_filename);
    }

  /* If dbx symbol table desired, initialize writing it
     and output the predefined types.  */
#ifdef DBX_DEBUGGING_INFO
  if (write_symbols == DBX_DEBUG)
    dbxout_init (asm_out_file, main_input_filename);
#endif
#ifdef SDB_DEBUGGING_INFO
  if (write_symbols == SDB_DEBUG)
    sdbout_init (asm_out_file, main_input_filename);
#endif

  /* Initialize yet another pass.  */

  init_final (main_input_filename);

  start_time = gettime ();

  /* Call the parser, which parses the entire file
     (calling rest_of_compilation for each function).  */

  yyparse ();

  /* Compilation is now finished except for writing
     what's left of the symbol table output.  */

  parse_time += gettime () - start_time;

  parse_time -= varconst_time;

  globals = getdecls ();

  /* Really define vars that have had only a tentative definition.
     Really output inline functions that must actually be callable
     and have not been output so far.  */

  {
    tree decl;
    for (decl = globals; decl; decl = TREE_CHAIN (decl))
      {
	if (TREE_CODE (decl) == VAR_DECL && TREE_STATIC (decl)
	    && ! TREE_ASM_WRITTEN (decl))
	  rest_of_decl_compilation (decl, 0, 1, 1);
	if (TREE_CODE (decl) == FUNCTION_DECL
	    && ! TREE_ASM_WRITTEN (decl)
	    && DECL_INITIAL (decl) != 0
	    && TREE_ADDRESSABLE (decl))
	  output_inline_function (decl);
      }
  }

  /* Do dbx symbols */
#ifdef DBX_DEBUGGING_INFO
  if (write_symbols == DBX_DEBUG)
    TIMEVAR (symout_time,
	     {
	       dbxout_tags (gettags ());
	       dbxout_types (get_permanent_types ());
	     });
#endif

#ifdef SDB_DEBUGGING_INFO
  if (write_symbols == SDB_DEBUG)
    TIMEVAR (symout_time,
	     {
	       sdbout_tags (gettags ());
	       sdbout_types (get_permanent_types ());
	     });
#endif

  /* Do gdb symbols */
  if (write_symbols == GDB_DEBUG)
    TIMEVAR (symout_time,
	     {
	       struct stat statbuf;
#ifdef atarist
		stat (name, &statbuf);
#else
	       fstat (fileno (finput), &statbuf);
#endif
	       symout_types (get_permanent_types ());
	       symout_top_blocks (globals, gettags ());
	       symout_finish (name, statbuf.st_ctime);
	     });

  /* Close the dump files.  */

  if (rtl_dump)
    fclose (rtl_dump_file);

  if (jump_opt_dump)
    fclose (jump_opt_dump_file);

  if (cse_dump)
    fclose (cse_dump_file);

  if (loop_dump)
    fclose (loop_dump_file);

  if (flow_dump)
    fclose (flow_dump_file);

  if (combine_dump)
    {
      dump_combine_total_stats (combine_dump_file);
      fclose (combine_dump_file);
    }

  if (local_reg_dump)
    fclose (local_reg_dump_file);

  if (global_reg_dump)
    fclose (global_reg_dump_file);

  if (jump2_opt_dump)
    fclose (jump2_opt_dump_file);

  /* Close non-debugging input and output files.  */

  fclose (finput);
  if (ferror (asm_out_file) != 0)
    fatal_io_error (asm_file_name);
  fclose (asm_out_file);

  /* Print the times.  */

  if (! quiet_flag)
    {
      fprintf (stderr,"\n");
      print_time ("parse", parse_time);
      print_time ("integration", integration_time);
      print_time ("jump", jump_time);
      print_time ("cse", cse_time);
      print_time ("loop", loop_time);
      print_time ("flow", flow_time);
      print_time ("combine", combine_time);
      print_time ("local-alloc", local_alloc_time);
      print_time ("global-alloc", global_alloc_time);
      print_time ("final", final_time);
      print_time ("varconst", varconst_time);
      print_time ("symout", symout_time);
      print_time ("dump", dump_time);
    }
}

/* This is called from finish_decl (within yyparse)
   for each declaration of a function or variable.
   This does nothing for automatic variables.
   Otherwise, it sets up the RTL and outputs any assembler code
   (label definition, storage allocation and initialization).

   DECL is the declaration.  If ASMSPEC is nonzero, it specifies
   the assembler symbol name to be used.  TOP_LEVEL is nonzero
   if this declaration is not within a function.  */

void
rest_of_decl_compilation (decl, asmspec, top_level, at_end)
     tree decl;
     tree asmspec;
     int top_level;
     int at_end;
{
  /* Declarations of variables, and of functions defined elsewhere.  */

  if (TREE_STATIC (decl) || TREE_EXTERNAL (decl))
    TIMEVAR (varconst_time,
	     {
	       assemble_variable (decl, asmspec, top_level, write_symbols, at_end);
	     });
#ifdef DBX_DEBUGGING_INFO
  else if (write_symbols == DBX_DEBUG && TREE_CODE (decl) == TYPE_DECL)
    TIMEVAR (varconst_time, dbxout_symbol (decl, 0));
#endif
#ifdef SDB_DEBUGGING_INFO
  else if (write_symbols == SDB_DEBUG && TREE_CODE (decl) == TYPE_DECL)
    TIMEVAR (varconst_time, sdbout_symbol (decl, 0));
#endif

  if (top_level)
    {
      if (write_symbols == GDB_DEBUG)
	{
	  TIMEVAR (symout_time,
		   {
		     /* The initizations make types when they contain
			string constants.  The types are on the temporary
			obstack, so output them now before they go away.  */
		     symout_types (get_temporary_types ());
		   });
	}
      else
	/* Clean out the temporary type list, since the types will go away.  */
	get_temporary_types ();
    }
}

/* This is called from finish_function (within yyparse)
   after each top-level definition is parsed.
   It is supposed to compile that function or variable
   and output the assembler code for it.
   After we return, the tree storage is freed.  */

void
rest_of_compilation (decl)
     tree decl;
{
  register rtx insns;
  int start_time = gettime ();
  int tem;

  /* If we are reconsidering an inline function
     at the end of compilation, skip the stuff for making it inline.  */

  if (DECL_SAVED_INSNS (decl) == 0)
    {

      /* If requested, consider whether to make this function inline.  */
      if (flag_inline_functions || TREE_INLINE (decl))
	{
	  TIMEVAR (integration_time,
		   {
		     int specd = TREE_INLINE (decl);
		     char *lose = function_cannot_inline_p (decl);
		     if (lose != 0 && specd)
		       warning_with_decl (decl, lose);
		     if (lose == 0)
		       save_for_inline (decl);
		     else
		       TREE_INLINE (decl) = 0;
		   });
	}

      insns = get_insns ();

      /* Dump the rtl code if we are dumping rtl.  */

      if (rtl_dump)
	TIMEVAR (dump_time,
		 {
		   fprintf (rtl_dump_file, "\n;; Function %s\n\n",
			    IDENTIFIER_POINTER (DECL_NAME (decl)));
		   if (DECL_SAVED_INSNS (decl))
		     fprintf (rtl_dump_file, ";; (integrable)\n\n");
		   print_rtl (rtl_dump_file, insns);
		   fflush (rtl_dump_file);
		 });

      /* If function is inline, and we don't yet know whether to
	 compile it by itself, defer decision till end of compilation.
	 finish_compilation will call rest_of_compilation again
	 for those functions that need to be output.  */

      if (TREE_PUBLIC (decl) == 0
	  && TREE_INLINE (decl)
	  && ! flag_keep_inline_functions)
	goto exit_rest_of_compilation;
    }

  if (rtl_dump_and_exit)
    goto exit_rest_of_compilation;

  TREE_ASM_WRITTEN (decl) = 1;

  insns = get_insns ();

  /* Copy any shared structure that should not be shared.  */

  unshare_all_rtl (insns);

  /* See if we have allocated stack slots that are not directly addressable.
     If so, scan all the insns and create explicit address computation
     for all references to such slots.  */
/*   fixup_stack_slots (); */

  /* Do jump optimization the first time, if -opt.
     Also do it if -W, but in that case it doesn't change the rtl code,
     it only computes whether control can drop off the end of the function.  */

  if (optimize || extra_warnings || warn_return_type)
    TIMEVAR (jump_time, jump_optimize (insns, 0, 0));

  /* Dump rtl code after jump, if we are doing that.  */

  if (jump_opt_dump)
    TIMEVAR (dump_time,
	     {
	       fprintf (jump_opt_dump_file, "\n;; Function %s\n\n",
			IDENTIFIER_POINTER (DECL_NAME (decl)));
	       print_rtl (jump_opt_dump_file, insns);
	       fflush (jump_opt_dump_file);
	     });

  /* Perform common subexpression elimination.
     Nonzero value from `cse_main' means that jumps were simplified
     and some code may now be unreachable, so do
     jump optimization again.  */

  if (optimize)
    {
      TIMEVAR (cse_time, reg_scan (insns, max_reg_num (), 0));

      TIMEVAR (cse_time, tem = cse_main (insns, max_reg_num ()));

      if (tem)
	TIMEVAR (jump_time, jump_optimize (insns, 0, 0));
    }

  /* Dump rtl code after cse, if we are doing that.  */

  if (cse_dump)
    TIMEVAR (dump_time,
	     {
	       fprintf (cse_dump_file, "\n;; Function %s\n\n",
			IDENTIFIER_POINTER (DECL_NAME (decl)));
	       print_rtl (cse_dump_file, insns);
	       fflush (cse_dump_file);
	     });

  if (loop_dump)
    TIMEVAR (dump_time,
	     {
	       fprintf (loop_dump_file, "\n;; Function %s\n\n",
			IDENTIFIER_POINTER (DECL_NAME (decl)));
	     });

  /* Move constant computations out of loops.  */

  if (optimize)
    {
      TIMEVAR (loop_time,
	       {
		 reg_scan (insns, max_reg_num (), 1);
		 loop_optimize (insns, max_reg_num (),
				loop_dump ? loop_dump_file : 0);
	       });
    }

  /* Dump rtl code after loop opt, if we are doing that.  */

  if (loop_dump)
    TIMEVAR (dump_time,
	     {
	       print_rtl (loop_dump_file, insns);
	       fflush (loop_dump_file);
	     });

  /* Now we choose between stupid (pcc-like) register allocation
     (if we got the -noreg switch and not -opt)
     and smart register allocation.  */

  if (optimize)		/* Stupid allocation probably won't work */
    obey_regdecls = 0;	/* if optimizations being done.  */

  regclass_init ();

  /* Print function header into flow dump now
     because doing the flow analysis makes some of the dump.  */

  if (flow_dump)
    TIMEVAR (dump_time,
	     {
	       fprintf (flow_dump_file, "\n;; Function %s\n\n",
			IDENTIFIER_POINTER (DECL_NAME (decl)));
	     });

  if (obey_regdecls)
    {
      TIMEVAR (flow_time,
	       {
		 regclass (insns, max_reg_num ());
		 stupid_life_analysis (insns, max_reg_num (),
				       flow_dump_file);
	       });
    }
  else
    {
      /* Do control and data flow analysis,
	 and write some of the results to dump file.  */

      TIMEVAR (flow_time, flow_analysis (insns, max_reg_num (),
					 flow_dump_file));
      if (extra_warnings)
	uninitialized_vars_warning (DECL_INITIAL (decl));
    }

  /* Dump rtl after flow analysis.  */

  if (flow_dump)
    TIMEVAR (dump_time,
	     {
	       print_rtl (flow_dump_file, insns);
	       fflush (flow_dump_file);
	     });

  /* If -opt, try combining insns through substitution.  */

  if (optimize)
    TIMEVAR (combine_time, combine_instructions (insns, max_reg_num ()));

  /* Dump rtl code after insn combination.  */

  if (combine_dump)
    TIMEVAR (dump_time,
	     {
	       fprintf (combine_dump_file, "\n;; Function %s\n\n",
			IDENTIFIER_POINTER (DECL_NAME (decl)));
	       dump_combine_stats (combine_dump_file);
	       print_rtl (combine_dump_file, insns);
	       fflush (combine_dump_file);
	     });

  /* Unless we did stupid register allocation,
     allocate pseudo-regs that are used only within 1 basic block.  */

  if (!obey_regdecls)
    TIMEVAR (local_alloc_time,
	     {
	       regclass (insns, max_reg_num ());
	       local_alloc ();
	     });

  /* Dump rtl code after allocating regs within basic blocks.  */

  if (local_reg_dump)
    TIMEVAR (dump_time,
	     {
	       fprintf (local_reg_dump_file, "\n;; Function %s\n\n",
			IDENTIFIER_POINTER (DECL_NAME (decl)));
	       dump_flow_info (local_reg_dump_file);
	       dump_local_alloc (local_reg_dump_file);
	       print_rtl (local_reg_dump_file, insns);
	       fflush (local_reg_dump_file);
	     });

  if (global_reg_dump)
    TIMEVAR (dump_time,
	     fprintf (global_reg_dump_file, "\n;; Function %s\n\n",
		      IDENTIFIER_POINTER (DECL_NAME (decl))));

  /* Unless we did stupid register allocation,
     allocate remaining pseudo-regs, then do the reload pass
     fixing up any insns that are invalid.  */

  TIMEVAR (global_alloc_time,
	   {
	     if (!obey_regdecls)
	       global_alloc (global_reg_dump ? global_reg_dump_file : 0);
	     else
	       reload (insns, 0,
		       global_reg_dump ? global_reg_dump_file : 0);
	   });

  if (global_reg_dump)
    TIMEVAR (dump_time,
	     {
	       dump_global_regs (global_reg_dump_file);
	       print_rtl (global_reg_dump_file, insns);
	       fflush (global_reg_dump_file);
	     });

  /* One more attempt to remove jumps to .+1
     left by dead-store-elimination.
     Also do cross-jumping this time
     and delete no-op move insns.  */

  if (optimize)
    {
      TIMEVAR (jump_time, jump_optimize (insns, 1, 1));
    }

  /* Dump rtl code after jump, if we are doing that.  */

  if (jump2_opt_dump)
    TIMEVAR (dump_time,
	     {
	       fprintf (jump2_opt_dump_file, "\n;; Function %s\n\n",
			IDENTIFIER_POINTER (DECL_NAME (decl)));
	       print_rtl (jump2_opt_dump_file, insns);
	       fflush (jump2_opt_dump_file);
	     });

  /* Now turn the rtl into assembler code.  */

  TIMEVAR (final_time,
	   {
	     assemble_function (decl);
	     final_start_function (insns, asm_out_file,
				   write_symbols, optimize);
	     final (insns, asm_out_file,
		    write_symbols, optimize);
	     final_end_function (insns, asm_out_file,
				 write_symbols, optimize);
	     fflush (asm_out_file);
	   });

  /* Write GDB symbols if requested */

  if (write_symbols == GDB_DEBUG)
    {
      TIMEVAR (symout_time,
	       {
		 symout_types (get_permanent_types ());
		 symout_types (get_temporary_types ());

		 DECL_BLOCK_SYMTAB_ADDRESS (decl)
		   = symout_function (DECL_INITIAL (decl),
				      DECL_ARGUMENTS (decl), 0);
	       });
    }
  else
    get_temporary_types ();

  /* Write DBX symbols if requested */

#ifdef DBX_DEBUGGING_INFO
  if (write_symbols == DBX_DEBUG)
    TIMEVAR (symout_time, dbxout_function (decl));
#endif

 exit_rest_of_compilation:

  /* The parsing time is all the time spent in yyparse
     *except* what is spent in this function.  */

  parse_time -= gettime () - start_time;
}

/* Entry point of cc1.  Decode command args, then call compile_file.
   Exit code is 35 if can't open files, 34 if fatal error,
   33 if had nonfatal errors, else success.  */

int
main (argc, argv, envp)
     int argc;
     char **argv;
     char **envp;
{
  register int i;
  char *filename = 0;
  int print_mem_flag = 0;

#ifdef RLIMIT_STACK
  /* Get rid of any avoidable limit on stack size.  */
  {
    struct rlimit rlim;

    /* Set the stack limit huge so that alloca does not fail. */
    getrlimit (RLIMIT_STACK, &rlim);
    rlim.rlim_cur = rlim.rlim_max;
    setrlimit (RLIMIT_STACK, &rlim);
  }
#endif /* RLIMIT_STACK */

  /* Initialize whether `char' is signed.  */
  flag_signed_char = DEFAULT_SIGNED_CHAR;

  /* This is zeroed by -O.  */
  obey_regdecls = 1;

  /* Initialize register usage now so switches may override.  */
  init_reg_sets ();

  target_flags = 0;
  set_target_switch ("");

  for (i = 1; i < argc; i++)
    if (argv[i][0] == '-')
      {
	register char *str = argv[i] + 1;
	if (str[0] == 'Y')
	  str++;

	if (str[0] == 'm')
	  set_target_switch (&str[1]);
	else if (!strcmp (str, "dumpbase"))
	  {
	    dump_base_name = argv[++i];
#ifdef atarist
/* dump_base_name will typically be 'foo.c' here.  Need to truncate at the '.',
   cause dots mean something here */
	    {
	      char * n = dump_base_name;
	      for ( ; ((*n) && (*n != '.')) ; )
		n++;
	      *n = '\0';
	    }
#endif
	  }
	else if (str[0] == 'd')
	  {
	    register char *p = &str[1];
	    while (*p)
	      switch (*p++)
		{
		case 'c':
		  combine_dump = 1;
		  break;
		case 'f':
		  flow_dump = 1;
		  break;
		case 'g':
		  global_reg_dump = 1;
		  break;
		case 'j':
		  jump_opt_dump = 1;
		  break;
		case 'J':
		  jump2_opt_dump = 1;
		  break;
		case 'l':
		  local_reg_dump = 1;
		  break;
		case 'L':
		  loop_dump = 1;
		  break;
		case 'm':
		  print_mem_flag = 1;
		  break;
		case 'r':
		  rtl_dump = 1;
		  break;
		case 's':
		  cse_dump = 1;
		  break;
		case 'y':
		  yydebug = 1;
		  break;
		}
	  }
	else if (str[0] == 'f')
	  {
	    register char *p = &str[1];
	    if (!strcmp (p, "float-store"))
	      flag_float_store = 1;
	    else if (!strcmp (p, "traditional"))
	      flag_traditional = 1, dollars_in_ident = 1;
	    else if (!strcmp (p, "volatile"))
	      flag_volatile = 1;
	    else if (!strcmp (p, "defer-pop"))
	      flag_defer_pop = 1;
	    else if (!strcmp (p, "no-defer-pop"))
	      flag_defer_pop = 0;
	    else if (!strcmp (p, "omit-frame-pointer"))
	      flag_omit_frame_pointer = 1;
	    else if (!strcmp (p, "no-omit-frame-pointer"))
	      flag_omit_frame_pointer = 0;
	    else if (!strcmp (p, "no-peephole"))
	      flag_no_peephole = 1;
	    else if (!strcmp (p, "signed-char"))
	      flag_signed_char = 1;
	    else if (!strcmp (p, "unsigned-char"))
	      flag_signed_char = 0;
	    else if (!strcmp (p, "force-mem"))
	      flag_force_mem = 1;
	    else if (!strcmp (p, "force-addr"))
	      flag_force_addr = 1;
	    else if (!strcmp (p, "combine-regs"))
	      flag_combine_regs = 1;
	    else if (!strcmp (p, "writable-strings"))
	      flag_writable_strings = 1;
	    else if (!strcmp (p, "no-function-cse"))
	      flag_no_function_cse = 1;
	    else if (!strcmp (p, "cond-mismatch"))
	      flag_cond_mismatch = 1;
	    else if (!strcmp (p, "no-asm"))
	      flag_no_asm = 1;
	    else if (!strncmp (p, "fixed-", 6))
	      fix_register (&p[6], 1, 1);
	    else if (!strncmp (p, "call-used-", 10))
	      fix_register (&p[10], 0, 1);
	    else if (!strncmp (p, "call-saved-", 11))
	      fix_register (&p[11], 0, 0);
	    else if (!strcmp (p, "inline-functions"))
	      flag_inline_functions = 1;
	    else if (!strcmp (p, "keep-inline-functions"))
	      flag_keep_inline_functions = 1;
	    else
	      error ("Invalid option, `%s'", argv[i]);	      
	  }
	else if (!strcmp (str, "noreg"))
	  ;
	else if (!strcmp (str, "opt"))
	  optimize = 1, obey_regdecls = 0;
	else if (!strcmp (str, "O"))
	  optimize = 1, obey_regdecls = 0;
	else if (!strcmp (str, "pedantic"))
	  pedantic = 1;
	else if (!strcmp (str, "traditional"))
	  flag_traditional = 1, dollars_in_ident = 1;
	else if (!strcmp (str, "ansi"))
	  flag_no_asm = 1, dollars_in_ident = 0;
	else if (!strcmp (str, "quiet"))
	  quiet_flag = 1;
	else if (!strcmp (str, "version"))
	  {
	    extern char *version_string;
	    printf ("GNU C version %s", version_string);
#ifdef TARGET_VERSION
	    TARGET_VERSION;
#endif
#ifdef __GNUC__
#ifndef __VERSION__
#define __VERSION__ "[unknown]"
#endif
	    printf (" compiled by GNU C version %s.\n", __VERSION__);
#else
	    printf (" compiled by CC.\n");
#endif
	  }
	else if (!strcmp (str, "w"))
	  inhibit_warnings = 1;
	else if (!strcmp (str, "W"))
	  extra_warnings = 1;
	else if (!strcmp (str, "Wimplicit"))
	  warn_implicit = 1;
	else if (!strcmp (str, "Wreturn-type"))
	  warn_return_type = 1;
	else if (!strcmp (str, "Wcomment"))
	  ; /* cpp handles this one.  */
	else if (!strcmp (str, "Wtrigraphs"))
	  ; /* cpp handles this one.  */
	else if (!strcmp (str, "Wall"))
	  {
	    extra_warnings = 1;
	    warn_implicit = 1;
	    warn_return_type = 1;
	  }
	else if (!strcmp (str, "p"))
	  profile_flag = 1;
	else if (!strcmp (str, "gg"))
	  write_symbols = GDB_DEBUG;
#ifdef DBX_DEBUGGING_INFO
	else if (!strcmp (str, "g"))
	  write_symbols = DBX_DEBUG;
	else if (!strcmp (str, "G"))
	  write_symbols = DBX_DEBUG;
#endif
#ifdef SDB_DEBUGGING_INFO
	else if (!strcmp (str, "g"))
	  write_symbols = SDB_DEBUG;
	else if (!strcmp (str, "G"))
	  write_symbols = SDB_DEBUG;
#endif
	else if (!strcmp (str, "symout"))
	  {
	    if (write_symbols == NO_DEBUG)
	      write_symbols = GDB_DEBUG;
	    sym_file_name = argv[++i];
	  }
	else if (!strcmp (str, "o"))
	  {
	    asm_file_name = argv[++i];
	  }
	else
	  error ("Invalid switch, %s.", argv[i]);
      }
    else
      filename = argv[i];

  if (filename == 0)
    fatal ("no input file specified");

  if (dump_base_name == 0)
    dump_base_name = filename;

#ifdef OVERRIDE_OPTIONS
  /* Some machines may reject certain combinations of options.  */
  OVERRIDE_OPTIONS;
#endif

  /* Now that register usage is specified, convert it to HARD_REG_SETs.  */
  init_reg_sets_1 ();

  compile_file (filename);

#ifndef atarist
#ifndef USG
#ifndef VMS
  if (print_mem_flag)
    {
      extern char **environ;
      caddr_t lim = (caddr_t) sbrk (0);
      
      fprintf (stderr, "Data size %d.\n",
	       (int) lim - (int) &environ);
      fflush (stderr);

      system ("ps v");
    }
#endif /* not VMS */
#endif /* not USG */
#endif /* not atarist */

  if (errorcount)
    exit (FATAL_EXIT_CODE);
  exit (SUCCESS_EXIT_CODE);
  return 34;
}

/* Decode -m switches.  */

/* Here is a table, controlled by the tm-...h file, listing each -m switch
   and which bits in `target_switches' it should set or clear.
   If VALUE is positive, it is bits to set.
   If VALUE is negative, -VALUE is bits to clear.
   (The sign bit is not used so there is no confusion.)  */

struct {char *name; int value;} target_switches []
  = TARGET_SWITCHES;

/* Decode the switch -mNAME.  */

void
set_target_switch (name)
     char *name;
{
  register int j;
  for (j = 0; j < sizeof target_switches / sizeof target_switches[0]; j++)
    if (!strcmp (target_switches[j].name, name))
      {
	if (target_switches[j].value < 0)
	  target_flags &= ~-target_switches[j].value;
	else
	  target_flags |= target_switches[j].value;
	break;
      }
}
