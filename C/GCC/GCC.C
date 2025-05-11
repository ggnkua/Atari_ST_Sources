/* Compiler driver program that can handle many languages.
   Copyright (C) 1987 Free Software Foundation, Inc.

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


/* This program is the user interface to the C compiler and possibly to
other compilers.  It is used because compilation is a complicated procedure
which involves running several programs and passing temporary files between
them, forwarding the users switches to those programs selectively,
and deleting the temporary files at the end.

CC recognizes how to compile each input file by suffixes in the file names.
Once it knows which kind of compilation to perform, the procedure for
compilation is specified by a string called a "spec".

Specs are strings containing lines, each of which (if not blank)
is made up of a program name, and arguments separated by spaces.
The program name must be exact and start from root, since no path
is searched and it is unreliable to depend on the current working directory.
Redirection of input or output is not supported; the subprograms must
accept filenames saying what files to read and write.

In addition, the specs can contain %-sequences to substitute variable text
or for conditional text.  Here is a table of all defined %-sequences.
Note that spaces are not generated automatically around the results of
expanding these sequences; therefore, you can concatenate them together
or with constant text in a single argument.

 %%	substitute one % into the program name or argument.
 %i     substitute the name of the input file being processed.
 %b     substitute the basename of the input file being processed.
	This is the substring up to (and not including) the last period.
 %g     substitute the temporary-file-name-base.  This is a string chosen
	once per compilation.  Different temporary file names are made by
	concatenation of constant strings on the end, as in `%g.s'.
	%g also has the same effect of %d.
 %d	marks the argument containing or following the %d as a
	temporary file name, so that that file will be deleted if CC exits
	successfully.  Unlike %g, this contributes no text to the argument.
 %w	marks the argument containing or following the %w as the
	"output file" of this compilation.  This puts the argument
	into the sequence of arguments that %o will substitute later.
 %o	substitutes the names of all the output files, with spaces
	automatically placed around them.  You should write spaces
	around the %o as well or the results are undefined.
	%o is for use in the specs for running the linker.
	Input files whose names have no recognized suffix are not compiled
	at all, but they are included among the output files, so they will
	be linked.
 %p	substitutes the standard macro predefinitions for the
	current target machine.  Use this when running cpp.
 %s     current argument is the name of a library file of some sort.
        Search for that file in a standard list of directories
	and substitute the full pathname found.
 %a     process ASM_SPEC as a spec.
        This allows config.h to specify part of the spec for running as.
 %l     process LINK_SPEC as a spec.
 %L     process LIB_SPEC as a spec.
 %S     process STARTFILE_SPEC as a spec.  A capital S is actually used here.
 %c	process SIGNED_CHAR_SPEC as a spec.
 %C     process CPP_SPEC as a spec.  A capital C is actually used here.
 %{S}   substitutes the -S switch, if that switch was given to CC.
	If that switch was not specified, this substitutes nothing.
	Here S is a metasyntactic variable.
 %{S*}  substitutes all the switches specified to CC whose names start
	with -S.  This is used for -o, -D, -I, etc; switches that take
	arguments.  CC considers `-o foo' as being one switch whose
	name starts with `o'.  %{o*} would substitute this text,
	including the space; thus, two arguments would be generated.
 %{S:X} substitutes X, but only if the -S switch was given to CC.
 %{!S:X} substitutes X, but only if the -S switch was NOT given to CC.

The conditional text X in a %{S:X} or %{!S:X} construct may contain
other nested % constructs or spaces, or even newlines.
They are processed as usual, as described above.

Note that it is built into CC which switches take arguments and which
do not.  You might think it would be useful to generalize this to
allow each compiler's spec to say which switches take arguments.  But
this cannot be done in a consistent fashion.  CC cannot even decide
which input files have been specified without knowing which switches
take arguments, and it must know which input files to compile in order
to tell which compilers to run.

CC also knows implicitly that arguments starting in `-l' are to
be treated as output files, and passed to the linker in their proper
position among the other output files.

*/

/* This defines which switches take arguments.  */

#define SWITCH_TAKES_ARG(CHAR)      \
  ((CHAR) == 'D' || (CHAR) == 'U' || (CHAR) == 'o' \
   || (CHAR) == 'e' || (CHAR) == 'T' || (CHAR) == 'u' \
   || (CHAR) == 'I' || (CHAR) == 'Y' || (CHAR) == 'm' \
   || (CHAR) == 'L')

#include <stdio.h>

#ifdef atarist
#include <types.h>
#include <signal.h>
#include <file.h>
#include <osbind.h>

long _stksize = 8192;

#else
#include <sys/types.h>
#include <signal.h>
#include <sys/file.h>
#endif

#include "obstack.h"
#include "config.h"

#ifdef USG
#define R_OK 4
#define W_OK 2
#define X_OK 1
#define vfork fork
#endif

#define obstack_chunk_alloc xmalloc
#define obstack_chunk_free free
extern int xmalloc ();
extern void free ();

/* If a stage of compilation returns an exit status >= 1,
   compilation of that file ceases.  */

#define MIN_FATAL_STATUS 1

/* This is the obstack which we use to allocate many strings.  */

struct obstack obstack;

char *handle_braces ();
char *save_string ();
char *concat ();
int do_spec ();
int do_spec_1 ();
int give_string ();
char *find_file ();

/* config.h can define ASM_SPEC to provide extra args to the assembler
   or extra switch-translations.  */
#ifndef ASM_SPEC
#define ASM_SPEC ""
#endif

/* config.h can define CPP_SPEC to provide extra args to the assembler
   or extra switch-translations.  */
#ifndef CPP_SPEC
#define CPP_SPEC ""
#endif

/* config.h can define LINK_SPEC to provide extra args to the linker
   or extra switch-translations.  */
#ifndef LINK_SPEC
#define LINK_SPEC ""
#endif

/* config.h can define LIB_SPEC to override the default libraries.  */
#ifndef LIB_SPEC
#define LIB_SPEC "%{!p:%{!pg:-lc}}%{p:-lc_p}%{pg:-lc_p}"
#endif

/* config.h can define STARTFILE_SPEC to override the default crt0 files.  */
#ifndef STARTFILE_SPEC
#define STARTFILE_SPEC  \
  "%{pg:gcrt0.o%s}%{!pg:%{p:mcrt0.o%s}%{!p:crt0.o%s}}"
#endif

/* This spec is used for telling cpp whether char is signed or not.  */
#define SIGNED_CHAR_SPEC  \
  (DEFAULT_SIGNED_CHAR ? "%{funsigned-char:-D__CHAR_UNSIGNED__}"	\
   : "%{!fsigned-char:-D__CHAR_UNSIGNED__}")

/* This structure says how to run one compiler, and when to do so.  */

struct compiler
{
  char *suffix;			/* Use this compiler for input files
				   whose names end in this suffix.  */
  char *spec;			/* To use this compiler, pass this spec
				   to do_spec.  */
};

/* Here are the specs for compiling files with various known suffixes.
   A file that does not end in any of these suffixes will be passed
   unchanged to the loader and nothing else will be done to it.  */

struct compiler compilers[] =
{
  {".c",
   "cpp %{nostdinc} %{C} %{v} %{D*} %{U*} %{I*} %{M*} %{T} \
        -undef -D__GNU__ -D__GNUC__ %{ansi:-T -$ -D__STRICT_ANSI__} %{!ansi:%p}\
        %c %{O:-D__OPTIMIZE__} %{traditional} %{pedantic}\
	%{Wcomment} %{Wtrigraphs} %{Wall} %C\
        %i %{!M*:%{!E:%g.cpp}}%{E:%{o*}}%{M*:%{o*}}\n\
    %{!M*:%{!E:cc1 %g.cpp %{!Q:-quiet} -dumpbase %i %{Y*} %{d*} %{m*} %{f*}\
		   %{g} %{O} %{W*} %{w} %{pedantic} %{ansi} %{traditional}\
		   %{v:-version} %{gg:-symout %g.sym} %{pg:-p} %{p}\
		   %{S:%{o*}%{!o*:-o %b.s}}%{!S:-o %g.s}\n\
              %{!S:as %{R} %{j} %{J} %{h} %{d2} %a %{gg:-G %g.sym}\
                      %g.s %{c:%{o*}%{!o*:-o %w%b.o}}%{!c:-o %d%w%b.o}\n }}}"},
  {".s",
   "%{!S:as %{R} %{j} %{J} %{h} %{d2} %a \
            %i %{c:%{o*}%{!o*:-o %w%b.o}}%{!c:-o %d%w%b.o}\n }"},
  /* Mark end of table */
  {0, 0}
};

/* Here is the spec for running the linker, after compiling all files.  */
#ifdef atarist

char *link_spec = "%{!c:%{!M*:%{!E:%{!S:ld %{o*} %l\
 %{A} %{d} %{e*} %{N} %{n} %{r} %{s} %{S} %{T*} %{t} %{u*} %{X} %{x} %{z}\
 %{y*} %{!nostdlib:%S} \
 %{L*} %o %{!nostdlib:%s %{g:-lg} %L}\n }}}}";

#else

char *link_spec = "%{!c:%{!M*:%{!E:%{!S:ld %{o*} %l\
 %{A} %{d} %{e*} %{N} %{n} %{r} %{s} %{S} %{T*} %{t} %{u*} %{X} %{x} %{z}\
 %{y*} %{!nostdlib:%S} \
 %{L*} %o %{!nostdlib:gnulib%s %{g:-lg} %L}\n }}}}";

#endif


/* Record the names of temporary files we tell compilers to write,
   and delete them at the end of the run.  */

/* This is the common prefix we use to make temp file names.
   It is chosen once for each run of this program.
   It is substituted into a spec by %g.
   Thus, all temp file names contain this prefix.
   In practice, all temp file names start with this prefix.
   The prefix starts with `/tmp'.  */

char *temp_filename;

/* Length of the prefix.  */

int temp_filename_length;

/* Define the list of temporary files to delete.  */

struct temp_file
{
  char *name;
  struct temp_file *next;
  int success_only;		/* Nonzero means delete this file
				   only if compilation succeeds fully.  */
};

struct temp_file *temp_file_queue;

/* Record FILENAME as a file to be deleted automatically.
   SUCCESS_ONLY nonzero means delete it only if all compilation succeeds;
   otherwise delete it in any case.  */

void
record_temp_file (filename, success_only)
     char *filename;
     int success_only;
{
  register struct temp_file *temp;
  register char *name;
  temp = (struct temp_file *) xmalloc (sizeof (struct temp_file));
  name = (char *) xmalloc (strlen (filename) + 1);
  strcpy (name, filename);
  temp->next = temp_file_queue;
  temp->name = name;
  temp->success_only = success_only;
  temp_file_queue = temp;
}

/* Delete all the temporary files whose names we previously recorded.
   SUCCESS nonzero means "delete on success only" files should be deleted.  */

void
delete_temp_files (success)
     int success;
{
  register struct temp_file *temp;
  for (temp = temp_file_queue; temp; temp = temp->next)
    if (success || ! temp->success_only)
      {
#ifdef DEBUG
	int i;
	printf ("Delete %s? (y or n) ", temp->name);
	fflush (stdout);
	i = getchar ();
	if (i != '\n')
	  while (getchar () != '\n') ;
	if (i == 'y' || i == 'Y')
#endif /* DEBUG */
	  unlink (temp->name);
      }
  temp_file_queue = 0;
}

/* Compute a string to use as the base of all temporary file names.
   It is substituted for %g.  */

void
choose_temp_base ()
{
#ifndef atarist
  register char *foo = "/tmp/ccXXXXXX";
  temp_filename = (char *) xmalloc (strlen (foo) + 1);
  strcpy (temp_filename, foo);
#else
  char * env_temp = (char *)getenv("TEMP");

  if (!env_temp)
	env_temp = "\\temp";
  temp_filename = concat(env_temp, "\\", "gcc-temp");
#endif

#ifndef atarist
  mktemp (temp_filename);
#endif
  temp_filename_length = strlen (temp_filename);
}

/* Accumulate a command (program name and args), and run it.  */

/* Vector of pointers to arguments in the current line of specifications.  */

char **argbuf;

/* Number of elements allocated in argbuf.  */

int argbuf_length;

/* Number of elements in argbuf currently in use (containing args).  */

int argbuf_index;

/* Flag indicating whether we should print the command and arguments */

unsigned char vflag;

/* User-specified prefix to attach to command names,
   or 0 if none specified.  */

char *user_exec_prefix = 0;

/* Default prefixes to attach to command names.  */

#ifndef STANDARD_EXEC_PREFIX
#define STANDARD_EXEC_PREFIX "/usr/local/lib/gcc-"
#endif /* !defined STANDARD_EXEC_PREFIX */

char *standard_exec_prefix = STANDARD_EXEC_PREFIX;
char *standard_exec_prefix_1 = "/usr/lib/gcc-";

char *standard_startfile_prefix = "/lib/";
char *standard_startfile_prefix_1 = "/usr/lib/";

/* Clear out the vector of arguments (after a command is executed).  */

void
clear_args ()
{
  argbuf_index = 0;
}

/* Add one argument to the vector at the end.
   This is done when a space is seen or at the end of the line.
   If TEMPNAMEP is nonzero, this arg is a file that should be deleted
   at the end of compilation.  (If TEMPNAMEP is 2, delete the file
   only if compilation is fully successful.)  */

void
store_arg (arg, tempnamep)
     char *arg;
     int tempnamep;
{
  if (argbuf_index + 1 == argbuf_length)
    {
      argbuf = (char **) realloc (argbuf, (argbuf_length *= 2) * sizeof (char *));
    }

  argbuf[argbuf_index++] = arg;
  argbuf[argbuf_index] = 0;

  if (tempnamep)
    record_temp_file (arg, tempnamep == 2);
}

/* Execute the command specified by the arguments on the current line of spec.
   Returns 0 if successful, -1 if failed.  */

int
execute ()
{
  int pid;
  int status;
  int size;
  char *temp;
  int win = 0;

  size = strlen (standard_exec_prefix);
  if (user_exec_prefix != 0 && strlen (user_exec_prefix) > size)
    size = strlen (user_exec_prefix);
  if (strlen (standard_exec_prefix_1) > size)
    size = strlen (standard_exec_prefix_1);
  size += strlen (argbuf[0]) + 1;
#ifdef atarist
  size += 5;		/* slush for ".ttp" */
#endif
  temp = (char *) alloca (size);

  /* Determine the filename to execute.  */

  if (user_exec_prefix)
    {
      strcpy (temp, user_exec_prefix);
      strcat (temp, argbuf[0]);
#ifdef atarist
	strcat (temp, ".ttp");
#endif
      win = (access (temp, X_OK) == 0);
    }

  if (!win)
    {
      strcpy (temp, standard_exec_prefix);
      strcat (temp, argbuf[0]);
#ifdef atarist
	strcat (temp, ".ttp");
#endif
      win = (access (temp, X_OK) == 0);
    }

  if (!win)
    {
      strcpy (temp, standard_exec_prefix_1);
      strcat (temp, argbuf[0]);
#ifdef atarist
	strcat (temp, ".ttp");
#endif
      win = (access (temp, X_OK) == 0);
    }

  if (vflag)
    {
      int i;
      for (i = 0; argbuf[i]; i++)
	{
	  if (i == 0 && win)
	    fprintf (stderr, " %s", temp);
	  else
	    fprintf (stderr, " %s", argbuf[i]);
	}
      fprintf (stderr, "\n");
      fflush (stderr);
#ifdef DEBUG
      fprintf (stderr, "\nGo ahead? (y or n) ");
      fflush (stderr);
      i = getchar ();
      if (i != '\n')
	while (getchar () != '\n') ;
      if (i != 'y' && i != 'Y')
	return 0;
#endif				/* DEBUG */
    }

#ifndef atarist
#ifdef USG
  pid = fork ();
  if (pid < 0)
    pfatal_with_name ("fork");
#else
  pid = vfork ();
  if (pid < 0)
    pfatal_with_name ("vfork");
#endif
  if (pid == 0)
    {
      if (win)
	execv (temp, argbuf);
      else
	execvp (argbuf[0], argbuf);
      perror_with_name (argbuf[0]);
      _exit (65);
    }
  wait (&status);
  if ((status & 0x7F) != 0)
    fatal ("Program %s got fatal signal %d.", argbuf[0], (status & 0x7F));
  if (((status & 0xFF00) >> 8) >= MIN_FATAL_STATUS)
    return -1;
#else

	{
	char * sizep = (char * ) alloca(256);
	char * cmdp = sizep + 1;
	register int iii;

	*cmdp = '\0';
	for (iii = 1 ; (argbuf[iii] != 0) ; iii++ )
		{
		strcat (cmdp, argbuf[iii]);
		strcat (cmdp, " ");
		}
	*sizep = strlen(cmdp);
	if (!win)
		temp = argbuf[0];
/*	printf("exec '%s' '%s'\n", temp, cmdp); */
	iii = Pexec(0, temp, sizep, 0);
/*	printf(" ... -> %d\n", iii); */
	return(iii);
	}
#endif
  return 0;
}

/* Find all the switches given to us
   and make a vector describing them.
   The elements of the vector a strings, one per switch given.
   If a switch uses the following argument, then the `part1' field
   is the switch itself and the `part2' field is the following argument.  */

struct switchstr
{
  char *part1;
  char *part2;
};

struct switchstr *switches;

int n_switches;

/* Also a vector of input files specified.  */

char **infiles;

int n_infiles;

/* And a vector of corresponding output files is made up later.  */

char **outfiles;

char *
make_switch (p1, s1, p2, s2)
     char *p1;
     int s1;
     char *p2;
     int s2;
{
  register char *new;
  if (p2 && s2 == 0)
    s2 = strlen (p2);
  new = (char *) xmalloc (s1 + s2 + 2);
  bcopy (p1, new, s1);
  if (p2)
    {
      new[s1++] = ' ';
      bcopy (p2, new + s1, s2);
    }
  new[s1 + s2] = 0;
  return new;
}

/* Create the vector `switches' and its contents.
   Store its length in `n_switches'.  */

void
process_command (argc, argv)
     int argc;
     char **argv;
{
  register int i;
  n_switches = 0;
  n_infiles = 0;

  /* Scan argv twice.  Here, the first time, just count how many switches
     there will be in their vector, and how many input files in theirs.
     Here we also parse the switches that cc itself uses (e.g. -v).  */

  for (i = 1; i < argc; i++)
    {
      if (argv[i][0] == '-' && argv[i][1] != 'l')
	{
	  register char *p = &argv[i][1];
	  register int c = *p;

	  switch (c)
	    {
	    case 'B':
	      user_exec_prefix = p + 1;
	      break;

	    case 'v':	/* Print our subcommands and print versions.  */
	      vflag++;
	      n_switches++;
	      break;

	    default:
	      n_switches++;

	      if (SWITCH_TAKES_ARG (c) && p[1] == 0)
		i++;
	    }
	}
      else
	n_infiles++;
    }

  /* Then create the space for the vectors and scan again.  */

  switches = ((struct switchstr *)
	      xmalloc ((n_switches + 1) * sizeof (struct switchstr)));
  infiles = (char **) xmalloc ((n_infiles + 1) * sizeof (char *));
  n_switches = 0;
  n_infiles = 0;

  /* This, time, copy the text of each switch and store a pointer
     to the copy in the vector of switches.
     Store all the infiles in their vector.  */

  for (i = 1; i < argc; i++)
    {
      if (argv[i][0] == '-' && argv[i][1] != 'l')
	{
	  register char *p = &argv[i][1];
	  register int c = *p;

	  if (c == 'B')
	    continue;
	  switches[n_switches].part1 = p;
	  if (SWITCH_TAKES_ARG (c) && p[1] == 0)
	    switches[n_switches].part2 = argv[++i];
	  else
	    switches[n_switches].part2 = 0;
	  n_switches++;
	}
      else
	infiles[n_infiles++] = argv[i];
    }

  switches[n_switches].part1 = 0;
  infiles[n_infiles] = 0;
}

/* Process a spec string, accumulating and running commands.  */

/* These variables describe the input file name.
   input_file_number is the index on outfiles of this file,
   so that the output file name can be stored for later use by %o.
   input_basename is the start of the part of the input file
   sans all directory names, and basename_length is the number
   of characters starting there excluding the suffix .c or whatever.  */

char *input_filename;
int input_file_number;
int input_filename_length;
int basename_length;
char *input_basename;

/* These are variables used within do_spec and do_spec_1.  */

/* Nonzero if an arg has been started and not yet terminated
   (with space, tab or newline).  */
int arg_going;

/* Nonzero means %d or %g has been seen; the next arg to be terminated
   is a temporary file name.  */
int delete_this_arg;

/* Nonzero means %w has been seen; the next arg to be terminated
   is the output file name of this compilation.  */
int this_is_output_file;

/* Nonzero means %s has been seen; the next arg to be terminated
   is the name of a library file and we should try the standard
   search dirs for it.  */
int this_is_library_file;

#ifdef atarist
/* I don't know why this is necessary.  Recursive calls to do_spec_1
   end up ignoring the error code from calls to execute().  That causes
   do_spec to get a 0 return value, and do_spec_1("\n"), which causes the
   command to get executed again.
*/
int execute_return_error = 0;
#endif

/* Process the spec SPEC and run the commands specified therein.
   Returns 0 if the spec is successfully processed; -1 if failed.  */

int
do_spec (spec)
     char *spec;
{
  int value;

  clear_args ();
  arg_going = 0;
  delete_this_arg = 0;
  this_is_output_file = 0;
  this_is_library_file = 0;

  value = do_spec_1 (spec, 0);
#ifdef atarist
  if (!value && execute_return_error)
	{
	value = execute_return_error;
	execute_return_error = 0;
	}
#endif
  if (value == 0)
    value = do_spec_1 ("\n", 0);
  return value;
}

/* Process the sub-spec SPEC as a portion of a larger spec.
   This is like processing a whole spec except that we do
   not initialize at the beginning and we do not supply a
   newline by default at the end.
   INSWITCH nonzero means don't process %-sequences in SPEC;
   in this case, % is treated as an ordinary character.
   This is used while substituting switches.
   INSWITCH nonzero also causes SPC not to terminate an argument.

   Value is zero unless a line was finished
   and the command on that line reported an error.  */

int
do_spec_1 (spec, inswitch)
     char *spec;
     int inswitch;
{
  register char *p = spec;
  register int c;
  char *string;

  while (c = *p++)
    /* If substituting a switch, treat all chars like letters.
       Otherwise, NL, SPC, TAB and % are special.  */
    switch (inswitch ? 'a' : c)
      {
#ifdef atarist
/* this stuff added by jrd.  if see '$', expect name of env var, delimited
   by '$'.  Find it's value, and subst it in. */

      case '$':
	{
	char varname[32];		/* should be enough */
	char * value;			/* deciphered value string */
	int i;

	for (i = 0 ; ((c = *p++) != '$') ; i++)
		varname[i] = c;
	varname[i] = '\0';
	if (strlen(&varname) > 0)
		{
		value = (char * )getenv(&varname);
		if (value)
			do_spec_1(value, 0);
		    else
			do_spec_1(".", 0);	/* a compleat kludge... */
		}
	break;
	}
#endif
      case '\n':
	/* End of line: finish any pending argument,
	   then run the pending command if one has been started.  */
	if (arg_going)
	  {
	    obstack_1grow (&obstack, 0);
	    string = obstack_finish (&obstack);
	    if (this_is_library_file)
	      string = find_file (string);
	    store_arg (string, delete_this_arg);
	    if (this_is_output_file)
	      outfiles[input_file_number] = string;
	  }
	arg_going = 0;
	if (argbuf_index)
	  {
	    int value = execute ();
#ifdef atarist
		if (!execute_return_error)
			execute_return_error = value;
#endif
	    if (value)
	      return value;
	  }
	/* Reinitialize for a new command, and for a new argument.  */
	clear_args ();
	arg_going = 0;
	delete_this_arg = 0;
	this_is_output_file = 0;
	this_is_library_file = 0;
	break;

      case '\t':
      case ' ':
	/* Space or tab ends an argument if one is pending.  */
	if (arg_going)
	  {
	    obstack_1grow (&obstack, 0);
	    string = obstack_finish (&obstack);
	    if (this_is_library_file)
	      string = find_file (string);
	    store_arg (string, delete_this_arg);
	    if (this_is_output_file)
	      outfiles[input_file_number] = string;
	  }
	/* Reinitialize for a new argument.  */
	arg_going = 0;
	delete_this_arg = 0;
	this_is_output_file = 0;
	this_is_library_file = 0;
	break;

      case '%':
	switch (c = *p++)
	  {
	  case 0:
	    fatal ("Invalid specification!  Bug in cc.");

	  case 'i':
	    obstack_grow (&obstack, input_filename, input_filename_length);
	    arg_going = 1;
	    break;

	  case 'b':
	    obstack_grow (&obstack, input_basename, basename_length);
	    arg_going = 1;
	    break;

	  case 'p':
	    do_spec_1 (CPP_PREDEFINES, 0);
	    break;

	  case 'g':
	    obstack_grow (&obstack, temp_filename, temp_filename_length);
	    delete_this_arg = 1;
	    arg_going = 1;
	    break;

	  case 'd':
	    delete_this_arg = 2;
	    break;

	  case 'w':
	    this_is_output_file = 1;
	    break;

	  case 's':
	    this_is_library_file = 1;
	    break;

	  case 'o':
	    {
	      register int f;
	      for (f = 0; f < n_infiles; f++)
		store_arg (outfiles[f], 0);
	    }
	    break;

	  case 'a':
	    do_spec_1 (ASM_SPEC, 0);
	    break;

	  case 'c':
	    do_spec_1 (SIGNED_CHAR_SPEC, 0);
	    break;

	  case 'C':
	    do_spec_1 (CPP_SPEC, 0);
	    break;

	  case 'l':
	    do_spec_1 (LINK_SPEC, 0);
	    break;

	  case 'L':
	    do_spec_1 (LIB_SPEC, 0);
	    break;

	  case 'S':
	    do_spec_1 (STARTFILE_SPEC, 0);
	    break;

	  case '{':
	    p = handle_braces (p);
	    if (p == 0)
	      return -1;
	    break;

	  case '%':
	    obstack_1grow (&obstack, '%');
	    break;

	  default:
#ifdef atarist
	    fprintf(stderr, "Bogus char '%c' found at pos %d of spec '%s'\n",
		c, (p - spec - 1), spec);
#endif
	    abort ();
	  }
	break;

      default:
	/* Ordinary character: put it into the current argument.  */
	obstack_1grow (&obstack, c);
	arg_going = 1;
      }

  return 0;		/* End of string */
}

/* Return 0 if we call do_spec_1 and that returns -1.  */

char *
handle_braces (p)
     register char *p;
{
  register char *q;
  int negate = *p == '!';
  char *filter;

  if (negate) ++p;

  filter = p;
  while (*p != ':' && *p != '}') p++;
  if (*p != '}')
    {
      register int count = 1;
      q = p + 1;
      while (count > 0)
	{
	  if (*q == '{')
	    count++;
	  else if (*q == '}')
	    count--;
	  else if (*q == 0)
	    abort ();
	  q++;
	}
    }
  else
    q = p + 1;

  if (p[-1] == '*' && p[0] == '}')
    {
      /* Substitute all matching switches as separate args.  */
      register int i;
      --p;
      for (i = 0; i < n_switches; i++)
	if (!strncmp (switches[i].part1, filter, p - filter))
	  {
	    give_switch (i);
	  }
    }
  else
    {
      /* Test for presence of the specified switch.  */
      register int i;
      int present = 0;

      /* If name specified ends in *, as in {x*:...},
	 check for presence of any switch name starting with x.  */
      if (p[-1] == '*')
	{
	  for (i = 0; i < n_switches; i++)
	    {
	      if (!strncmp (switches[i].part1, filter, p - filter - 1))
		{
		  present = 1;
		  break;
		}
	    }
	}
      /* Otherwise, check for presence of exact name specified.  */
      else
	{
	  for (i = 0; i < n_switches; i++)
	    {
	      if (!strncmp (switches[i].part1, filter, p - filter)
		  && switches[i].part1[p - filter] == 0)
		{
		  present = 1;
		  break;
		}
	    }
	}

      /* If it is as desired (present for %{s...}, absent for %{-s...})
	 then substitute either the switch or the specified
	 conditional text.  */
      if (present != negate)
	{
	  if (*p == '}')
	    {
	      give_switch (i);
	    }
	  else
	    {
	      if (do_spec_1 (save_string (p + 1, q - p - 2), 0) < 0)
		return 0;
	    }
	}
    }

  return q;
}

/* Pass a switch to the current accumulating command
   in the same form that we received it.
   SWITCHNUM identifies the switch; it is an index into
   the vector of switches gcc received, which is `switches'.
   This cannot fail since it never finishes a command line.  */

give_switch (switchnum)
     int switchnum;
{
  do_spec_1 ("-", 0);
  do_spec_1 (switches[switchnum].part1, 1);
  do_spec_1 (" ", 0);
  if (switches[switchnum].part2 != 0)
    {
      do_spec_1 (switches[switchnum].part2, 1);
      do_spec_1 (" ", 0);
    }
}

/* Search for a file named NAME trying various prefixes including the
   user's -B prefix and some standard ones.
   Return the absolute pathname found.  If nothing is found, return NAME.  */

char *
find_file (name)
     char *name;
{
  int size;
  char *temp;
  int win = 0;

  /* Compute maximum size of NAME plus any prefix we will try.  */

  size = strlen (standard_exec_prefix);
  if (user_exec_prefix != 0 && strlen (user_exec_prefix) > size)
    size = strlen (user_exec_prefix);
  if (strlen (standard_exec_prefix_1) > size)
    size = strlen (standard_exec_prefix_1);
  if (strlen (standard_startfile_prefix) > size)
    size = strlen (standard_startfile_prefix);
  if (strlen (standard_startfile_prefix_1) > size)
    size = strlen (standard_startfile_prefix_1);
  size += strlen (name) + 1;

  temp = (char *) alloca (size);

  if (user_exec_prefix)
    {
      strcpy (temp, user_exec_prefix);
      strcat (temp, name);
      win = (access (temp, R_OK) == 0);
    }

  if (!win)
    {
      strcpy (temp, standard_exec_prefix);
      strcat (temp, name);
      win = (access (temp, R_OK) == 0);
    }

  if (!win)
    {
      strcpy (temp, standard_exec_prefix_1);
      strcat (temp, name);
      win = (access (temp, R_OK) == 0);
    }

  if (!win)
    {
      strcpy (temp, standard_startfile_prefix);
      strcat (temp, name);
      win = (access (temp, R_OK) == 0);
    }

  if (!win)
    {
      strcpy (temp, standard_startfile_prefix_1);
      strcat (temp, name);
      win = (access (temp, R_OK) == 0);
    }

  if (!win)
    {
#ifdef atarist
      strcpy (temp, ".\\");
#else
      strcpy (temp, "./");
#endif
      strcat (temp, name);
      win = (access (temp, R_OK) == 0);
    }

  if (win)
    return save_string (temp, strlen (temp));
  return name;
}

/* Name with which this program was invoked.  */

char *programname;

/* On fatal signals, delete all the temporary files.  */

#ifndef atarist
void
fatal_error (signum)
     int signum;
{
  signal (signum, SIG_DFL);
  delete_temp_files (0);
  /* Get the same signal again, this time not handled,
     so its normal effect occurs.  */
  kill (getpid (), signum);
}
#endif

int
main (argc, argv)
     int argc;
     char **argv;
{
  register int i;
  int value;
  int nolink = 0;
  int error = 0;

#ifdef atarist
  programname = "gcc";
#else
  programname = argv[0];
#endif

#ifndef atarist
  if (signal (SIGINT, SIG_IGN) != SIG_IGN)
    signal (SIGINT, fatal_error);
  if (signal (SIGHUP, SIG_IGN) != SIG_IGN)
    signal (SIGHUP, fatal_error);
  if (signal (SIGTERM, SIG_IGN) != SIG_IGN)
    signal (SIGTERM, fatal_error);
#endif

  argbuf_length = 10;
  argbuf = (char **) xmalloc (argbuf_length * sizeof (char *));

  obstack_init (&obstack);

  choose_temp_base ();

  /* Make a table of what switches there are (switches, n_switches).
     Make a table of specified input files (infiles, n_infiles).  */

  process_command (argc, argv);

#ifdef atarist
/* if no default dir specified for executables, look for an env var
   called 'GCCEXEC' and use that */

  if (!user_exec_prefix)
  	{
	user_exec_prefix = getenv("GCCEXEC");
	}
#endif /* atarist */

  if (vflag)
    {
      extern char *version_string;
      printf ("gcc version %s\n", version_string);
      if (n_infiles == 0)
	exit (0);
    }

  if (n_infiles == 0)
    fatal ("No source or object files specified.");

  /* Make a place to record the compiler output file names
     that correspond to the input files.  */

  outfiles = (char **) xmalloc (n_infiles * sizeof (char *));
  bzero (outfiles, n_infiles * sizeof (char *));

  for (i = 0; i < n_infiles; i++)
    {
      /* First figure out which compiler from the file's suffix.  */
      
      register struct compiler *cp;

      /* Tell do_spec what to substitute for %i.  */

      input_filename = infiles[i];
      input_filename_length = strlen (input_filename);
      input_file_number = i;

      /* Use the same thing in %o, unless cp->spec says otherwise.  */

      outfiles[i] = input_filename;

      for (cp = compilers; cp->spec; cp++)
	{
	  if (strlen (cp->suffix) < input_filename_length
	      && !strcmp (cp->suffix,
			  infiles[i] + input_filename_length
			  - strlen (cp->suffix)))
	    {
	      /* Ok, we found an applicable compiler.  Run its spec.  */
	      /* First say how much of input_filename to substitute for %b  */
	      register char *p;

	      input_basename = input_filename;
	      for (p = input_filename; *p; p++)
#ifdef atarist
		if (*p == '\\')
#else
		if (*p == '/')
#endif
		  input_basename = p + 1;
	      basename_length = (input_filename_length - strlen (cp->suffix)
				 - (input_basename - input_filename));
	      value = do_spec (cp->spec);
	      if (value < 0)
		error = 1;
#ifdef atarist
/* is this necessary? */
	       else
	      if (value == FATAL_EXIT_CODE)
		error = 1;
#endif
	      break;
	    }
	}

      /* If this file's name does not contain a recognized suffix,
	 don't do anything to it, but do feed it to the link spec
	 since its name is in outfiles.  */
    }

  /* Run ld to link all the compiler output files.  */

  if (! nolink && error == 0)
    {
      value = do_spec (link_spec);
      if (value < 0)
	error = 1;
    }

  /* Delete some or all of the temporary files we made.  */

  delete_temp_files (error == 0);

  exit (error);
}

xmalloc (size)
     int size;
{
  register int value = malloc (size);
  if (value == 0)
    fatal ("Virtual memory full.");
  return value;
}

xrealloc (ptr, size)
     int ptr, size;
{
  register int value = realloc (ptr, size);
  if (value == 0)
    fatal ("Virtual memory full.");
  return value;
}

fatal (msg, arg1, arg2)
     char *msg, *arg1, *arg2;
{
  error (msg, arg1, arg2);
  delete_temp_files (0);
  exit (1);
}

error (msg, arg1, arg2)
     char *msg, *arg1, *arg2;
{
  fprintf (stderr, "%s: ", programname);
  fprintf (stderr, msg, arg1, arg2);
  fprintf (stderr, "\n");
}

/* Return a newly-allocated string whose contents concatenate those of s1, s2, s3.  */

char *
concat (s1, s2, s3)
     char *s1, *s2, *s3;
{
  int len1 = strlen (s1), len2 = strlen (s2), len3 = strlen (s3);
  char *result = (char *) xmalloc (len1 + len2 + len3 + 1);

  strcpy (result, s1);
  strcpy (result + len1, s2);
  strcpy (result + len1 + len2, s3);
  *(result + len1 + len2 + len3) = 0;

  return result;
}

char *
save_string (s, len)
     char *s;
     int len;
{
  register char *result = (char *) xmalloc (len + 1);

  bcopy (s, result, len);
  result[len] = 0;
  return result;
}

pfatal_with_name (name)
     char *name;
{
  extern int errno, sys_nerr;
  extern char *sys_errlist[];
  char *s;

#ifdef atarist
  if ((errno > sys_nerr) && (errno < 0))
#else
  if (errno < sys_nerr)
#endif
    s = concat ("", sys_errlist[errno], " for %s");
  else
    s = "cannot open %s";
  fatal (s, name);
}

perror_with_name (name)
     char *name;
{
  extern int errno, sys_nerr;
  extern char *sys_errlist[];
  char *s;

#ifdef atarist
  if ((errno > sys_nerr) && (errno < 0))
#else
  if (errno < sys_nerr)
#endif
    s = concat ("", sys_errlist[errno], " for %s");
  else
    s = "cannot open %s";
  error (s, name);
}
