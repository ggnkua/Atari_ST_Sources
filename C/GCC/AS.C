/* as.c - GAS main program. */

/* Copyright (C) 1987 Free Software Foundation, Inc.

This file is part of Gas, the GNU Assembler.

The GNU assembler is distributed in the hope that it will be
useful, but WITHOUT ANY WARRANTY.  No author or distributor
accepts responsibility to anyone for the consequences of using it
or for whether it serves any particular purpose or works at all,
unless he says so in writing.  Refer to the GNU Assembler General
Public License for full details.

Everyone is granted permission to copy, modify and redistribute
the GNU Assembler, but only under the conditions described in the
GNU Assembler General Public License.  A copy of this license is
supposed to have been given to you along with the GNU Assembler
so you can know your rights and responsibilities.  It should be
in a file named COPYING.  Among other things, the copyright
notice and this notice must be preserved on all copies.  */

/*
 * Main program for AS; a 32-bit assembler of GNU.
 * Understands command arguments.
 * Has a few routines that don't fit in other modules because they
 * are shared.
 *
 *
 *			bugs
 *
 * : initialisers
 *	Since no-one else says they will support them in future: I
 * don't support them now.
 *
 */

#define COMMON
#include "as.h"
#include "struc-symbol.h"
#include "write.h"
		/* Warning!  This may have some slightly strange side effects
		   if you try to compile two or more assemblers in the same
		   directory!
		 */

static char * gdb_symbol_file_name;

char *myname;		/* argv[0] */
extern char version_string[];

main(argc,argv)
int	argc;
char	**argv;
{
	int	work_argc;	/* variable copy of argc */
	char	**work_argv;	/* variable copy of argv */
	char	*arg;		/* an arg to program */
	char	a;		/* an arg flag (after -) */
	char	*temp_file_name;	/* file name for -t option */

	char	*stralloc();	/* Make a (safe) copy of a string. */
	long int gdb_begin();
	void	symbol_begin();
	void	read_begin();
	void	write_object_file();

	myname=argv[0];
	bzero (flagseen, sizeof(flagseen)); /* aint seen nothing yet */
	out_file_name	= "a.out";	/* default .o file */
	symbol_begin();		/* symbols.c */
	subsegs_begin();		/* subsegs.c */
	read_begin();			/* read.c */
	md_begin();			/* MACHINE.c */
	input_scrub_begin();		/* input_scrub.c */
	gdb_symbol_file_name = 0;
	/*
	 * Parse arguments, but we are only interested in flags.
	 * When we find a flag, we process it then make it's argv[] NULL.
	 * This helps any future argv[] scanners avoid what we processed.
	 * Since it is easy to do here we interpret the special arg "-"
	 * to mean "use stdin" and we set that argv[] pointing to "".
	 * After we have munged argv[], the only things left are source file
	 * name(s) and ""(s) denoting stdin. These file names are used
	 * (perhaps more than once) later.
	 */
	work_argc = argc-1;		/* don't count argv[0] */
	work_argv = argv+1;		/* skip argv[0] */
	for (;work_argc--;work_argv++) {
		arg = * work_argv;	/* work_argv points to this argument */

		if (*arg!='-')		/* Filename. We need it later. */
			continue;	/* Keep scanning args looking for flags. */
		if (arg[1] == '-' && arg[2] == 0) {
			/* "--" as an argument means read STDIN */
			/* on this scan, we don't want to think about filenames */
			* work_argv = "";	/* Code that means 'use stdin'. */
			continue;
		}
				/* This better be a switch. */
		arg ++;		/* -> letter. */

		while (a = * arg)  {/* scan all the 1-char flags */

			/* Note that for reasons too complicated to go into
			   here, both the VAX and the 68020 acceopt
			   (and ignore) thise flags.  Of course, anyone who
			   does -m68020 on the vax is VERY confused
			 */
			if(!strcmp(&arg[0],"mc68020") || !strcmp(&arg[0],"m68020")) {
				*work_argv=NULL;
				break;
			}

			if(!strcmp(&arg[0],"v") || !strcmp(&arg[0],"version")) {
				fprintf(stderr,version_string);
				*work_argv=NULL;
				break;
			}

			arg ++;	/* arg -> after letter. */
			a &= 0x7F;	/* ascii only please */
			if (flagseen[a])
				as_warn("%s: Flag option -%c has already been seen!",myname,a);
			flagseen[a] = TRUE;
			switch (a) {
			case 'd':
				as_warn("%s: Displacement length %s. ignored! GNU is NOT Un*x!",myname,arg);
				break;

			case 'f':
				break;	/* -f means fast - no need for "app" preprocessor. */

			case 'D':
				/* DEBUG is implemented: it debugs different */
				/* things to other people's assemblers. */
				break;

			case 'G':	/* GNU AS switch: include gdbsyms. */
				if (*arg)	/* Rest of argument is file-name. */
					gdb_symbol_file_name = stralloc (arg);
				else if (work_argc) {	/* Next argument is file-name. */
					work_argc --;
					* work_argv = NULL; /* Not a source file-name. */
					gdb_symbol_file_name = * ++ work_argv;
				} else
					as_warn( "%s: I expected a filename after -G",myname);
				arg = "";	/* Finished with this arg. */
				break;

			case 'J':
				as_warn("%s: I can do better than -J!",myname);
				break;

			case 'L': /* -L means keep L* symbols */
				break;

			case 'l':	/* -l means keep external to 2 bit offset
					   rather than 16 bit one */
				break;
			case 'o':
				if (*arg)	/* Rest of argument is object file-name. */
					out_file_name = stralloc (arg);
				else if (work_argc) {	/* Want next arg for a file-name. */
					* work_argv = NULL; /* This is not a file-name. */
					work_argc--;
					out_file_name = * ++ work_argv;
				} else
					as_warn("%s: I expected a filename after -o. \"%s\" assumed.",myname,out_file_name);
				arg = "";	/* Finished with this arg. */
				break;

			case 'R':
				/* -R means put data into text segment */
				break;

			case 'S':
				break;	/* SYMBOL TABLE not implemented */

			case 't':
				if (*arg)	/* Rest of argument is filename. */
					temp_file_name = stralloc (arg);
				else if (work_argc) {
					* work_argv = NULL; /* Remember this is not a file-name. */
					work_argc--;
					temp_file_name = *++work_argv;
				} else {
					as_warn("%s: I expected a filename after -t.",myname);
					temp_file_name = "{absent}";
				}
				as_warn("%s: I don't need or use temp. file \"%s\".",myname,temp_file_name);
				arg = "";	/* Finished with this arg. */
				break;

			case 'T':
				break;	/* TOKEN TRACE not implemented */

			case 'V':
				as_warn("%s: I don't use an interpass file! -V ignored",myname);
				break;

			case 'W':
				/* -W means don't warn about things */
				break;

			default:
				as_warn("%s: I don't understand '%c' flag!",myname,a);
				break;
			}
		}
		/*
		 * We have just processed a "-..." arg, which was not a
		 * file-name. Smash it so the
		 * things that look for filenames won't ever see it.
		 *
		 * Whatever work_argv points to, it has already been used
		 * as part of a flag, so DON'T re-use it as a filename.
		 */
		*work_argv = NULL; /* NULL means 'not a file-name' */
	}
	if (gdb_begin(gdb_symbol_file_name) == 0)
		flagseen ['G'] = 0;	/* Don't do any gdbsym stuff. */
	/* Here with flags set up in flagseen[]. */
	perform_an_assembly_pass(argc,argv); /* Assemble it. */
	if (seen_at_least_1_file())
		write_object_file();/* relax() addresses then emit object file */
	input_scrub_end();
	md_end();			/* MACHINE.c */
	exit(0);			/* WIN */
}
 

/*			perform_an_assembly_pass()
 *
 * Here to attempt 1 pass over each input file.
 * We scan argv[*] looking for filenames or exactly "" which is
 * shorthand for stdin. Any argv that is NULL is not a file-name.
 * We set need_pass_2 TRUE if, after this, we still have unresolved
 * expressions of the form (unknown value)+-(unknown value).
 *
 * Note the un*x semantics: there is only 1 logical input file, but it
 * may be a catenation of many 'physical' input files.
 */
perform_an_assembly_pass (argc, argv)
int	argc;
char **	argv;
{
	char *	buffer;		/* Where each bufferful of lines will start. */
	void	read_a_source_file();

	text_fix_root		= NULL;
	data_fix_root		= NULL;
	need_pass_2		= FALSE;

	argv++;			/* skip argv[0] */
	argc--;			/* skip argv[0] */
	while (argc--) {
		if (*argv) {		/* Is it a file-name argument? */
			/* argv -> "" if stdin desired, else -> filename */
			if (buffer = input_scrub_new_file (*argv) )
				read_a_source_file(buffer);
		}
		argv++;			/* completed that argv */
	}
}

/*
 *			stralloc()
 *
 * Allocate memory for a new copy of a string. Copy the string.
 * Return the address of the new string. Die if there is any error.
 */

char *
stralloc (str)
char *	str;
{
	register char *	retval;
	register long int	len;

	len = strlen (str) + 1;
	retval = xmalloc (len);
	(void)strcpy (retval, str);
	return (retval);
}

lose()
{
	as_fatal( "%s: 2nd pass not implemented - get your code from random(3)",myname );
}

/* end: as.c */
