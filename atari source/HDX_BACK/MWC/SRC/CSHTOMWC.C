/*
 * Usage: cshtomwc file_name [argument ...]
 *
 * Returns: 1 if anything went wrong, otherwise return status of program.
 *
 * Compile with: cc cshtomwc.c			# for the newest cshell's
 * or with:	 cc -DOLDCSHELL cshtomwc.c	# for older cshell's
 *
 * Written by: rec@mwc 1986-10-08
 *
 * This program should allow cshell users to call MWC programs
 * with the following caveats:
 *	1) You must give a complete file name for the program to be run.
 *	Since you'll probably be using this in an alias or a command
 *	file, this should be no great misery.
 *	2) You must setenv the environments which MWC requires
 *	These are listed several times in the MWC documentation.
 *	Start from the lexicon article on 'environment' if you need
 *	review.  (If your cshell doesn't have a 'setenv' command,
 *	keep reading; we have a solution for you, too.)
 *	3) The enviroments must be in MWC format with the exception
 *	of PATH which we may use the cshell list separator.
 *	4) If you redirect standard input to a file or a pipe, the
 *	program you call will not find EOF on standard input.
 *	5) If you redirect standard output to a file, all writes to
 *	stderr will end up there, too.
 *
 * The first version of this program was produced from a Beckemeyer
 * environment/argument passing specification dated 9/30/86.  The
 * version of the cshell which we have does not follow the specification,
 * it passes random binary garbage in the basepage.p_env.  The multi-
 * tasking cshell does follow the specification.  We don't know when he
 * added the environment/argument passing conventions to his product.
 * If your cshell has no 'setenv' command, or if this program doesn't
 * work when compiled with 'cc cshtomwc.c', then you should:
 *	1) Edit the strings in the defenv array below to reflect
 *	your system's configuration.
 *	2) Compile with 'cc -DOLDCSHELL cshtomwc.c' to eliminate
 *	the Beckemeyer anachronisms.
 */
#include <basepage.h>		/* To find the environment string */
#include <assert.h>		/* To find impossibilities */
#include <osbind.h>		/* To have a good time */

#ifdef OLDCSHELL
/*
 * This only applies to older cshell's which have no environment.
 * Edit these strings to match your system's layout.
 * Note that they almost certainly won't work as they are.
 * Be sure to preserve the doubled backslashes, or the c compiler
 * will make some unprintable characters for you.
 */
char *defenv[] = {
	"PATH=.bin,,a:\\bin,b:\\bin",
	"SUFF=,.prg,.tos,.ttp",
	"TMPDIR=a:\\tmp",
	"INCDIR=a:\\include",
	"LIBPATH=a:\\lib,b:\\lib",
	0
};
#endif

main(argc, argv, envp) int argc; char *argv[], *envp[];
{
#ifndef OLDCSHELL
    {
	/*
	 * The first order of business is to fixup the environment.
	 * Beckemeyer uses a "name=", "value" format which is
	 *	a) incompatible with U**X or Coherent,
	 *	b) incapable of passing empty values.
	 * We have to reparse p_env from scratch
	 * because our run time startup truncated envp[]
	 * when it found "ARGV=".
	 * But envp[], and argv[] which follows it in memory,
	 * will have plenty of room for the resulting vector
	 * since we're halving the number of strings.
	 * And p_env will have plenty of room since we're
	 * simply deleting NUL's and packing the result.
	 */
	register char *p1, *p2, **vp;
	vp = envp;			/* passed by crts0.o */
	p1 = p2 = (char *)BP->p_env;	/* Get the start */
	do {
		*vp++ = p1;	/* set envp[x] */
		while (*p1++ = *p2++)	/* copy "name=" to NUL */
			;
		--p1;			/* scrap NUL */
		while (*p1++ = *p2++)	/* concatenate "value" to NUL */
			;
	} while (*p2 != 0);	/* until you see two NUL's in a row */
	*vp++ = 0;			/* Mark end of envp[] */
	assert(vp < argv+argc);	/* There is room, I swear there is */
	assert(p1 < (char *)_start);	/* There's room here, too */
    }
    {
	/*
	 * Next we'll load argv[].
	 * Beckemeyer uses ARGV=address_in_the_parent's_data_space
	 * to pass arguments which is
	 *	a) economical, since a Pexec() makes a copy in our format
	 *	b) sort of suicidal if the program you're running is buggy
	 * We just fetch the environment and put the value into argv[]
	 * above.  We fetch the ARGC=number_of_arguments parameter, too.
	 */
	extern char *getenv();		/* To find the string */
	extern long atol();		/* To convert the string */
	register char *p;		/* To hold the value for a moment */

	if ((p = getenv("ARGV")) == 0)
		return Cconws("cshtomwc: no ARGV found\n\r"), 1;
	argv = (char **)atol(p);
	if ((p = getenv("ARGC")) == 0)
		return Cconws("cshtomwc: no ARGC found\n\r"), 1;
	argc = (int)atol(p);
	assert(((long)argv & 1) == 0);	/* Sorry Dave, just paranoid */
	assert(argv+argc < (char **)BP->p_env);
	assert(argv[argc] == 0);	/* I assume it's NULL terminated */
    }
    {
	/*
	 * A temporary fix.  The PATH parsing routines will
	 * accept ';' as a separator in the next release.
	 * But for now, we need to translate ';' into ','.
	 */
	extern char *getenv();
	register char *p;
	register int c;
	if ((p = getenv("PATH")) != 0)
		while (c = *p++)
			if (c == ';')
				p[-1] = ',';
    }
#else
    {
	/*
	 * There is no environment in older cshell's
	 * so we simply plug the canned environment
	 * defined above.
	 */
	envp = defenv;
    }
#endif
    {
	/*
	 * We need to fixup the _iovector which our libraries
	 * depend on for the information about file handles
	 * which gemdos is too dumb to provide.  Because the
	 * program we exec will see ARGV= in its environment
	 * it will assume that standard file handles 0, 1, and 2
	 * refer to standard input, standard output, and standard
	 * error streams respectively.  Beckemeyer doesn't provide
	 * any information about what he's done to these handles,
	 * but everyone complains that they can't redirect stderr
	 * so we'll assume that it points at aux:.
	 * We'll also assume that where ever stdout points
	 * it's all right to point stderr there as well.
	 * The only thing which will break our programs is a redirection
	 * of standard input to a file.  Without _iovector[0] == 'F',
	 * our programs cannot determine that stdin is not the console.
	 * Using Cconrs() to read a file is a loss, since it never
	 * returns EOF.  Using our io package to read a file when it thinks
	 * it's reading con: is a double loss, since we echo the missing
	 * linefeeds back to con:.
	 */
	extern char *_iovector;
	_iovector = "CCAP??????????????????????";	/* default setup */
	dup2(dup(2), 4);	/* make copy of aux: */
	dup2(dup(1), 2);	/* point stderr at stdout */
    }
   /*
    * One last check.
    */
    if (argc < 2)
	return Cconws("Usage: cshtomwc file_name [arg ...]\n\r"), 1;
   /*
    * And we're ready to go.
    */
    return execve(argv[1], argv+1, envp);
}
