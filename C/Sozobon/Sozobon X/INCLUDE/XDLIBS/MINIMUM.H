/*
 *
 * DO NOT INCLUDE THIS FILE IF YOU USE ARGC/ARGV OR STANDARD I/O AT ALL!!
 *
 * This header file defines a _main() function, that replace
 * the one in the standard library.  With this functions, none of the
 * standard i/o functions normally linked into a program will be referenced,
 * and the variables like _mint or _starttime are not set.
 *
 * However... if you REALLY need arguments, but still want a teeny tiny
 * (non-portable) program, you can use a getcmdln() like the one in here.
 */

#ifndef _MINI_H
#define	_MINI_H
#pragma echo warning from minimum.h 
#pragma echo never use this file unless you have very good reasons

extern int	_argc;
extern char	**_argv;
extern char	*_envp;

extern void _exit(int status);

_main()
{
	_exit(main(_argc, _argv, _envp));
}

#define	exit(code)	_exit(code)	/* no stdio, no cleanup needed */


#if 0
	/* this is just an example, so it is commented out by
	 * the precompiler
	 */

void getcmdln()
{
	register char *p, *q, *t;
	char	*cmdline;
	int		cmdlen;

#ifndef _BASEP_H
	extern char *_base;
	cmdline = _base+0x80;
#else
	cmdline = _base->p_cmdlin;
#endif
	cmdlen = *cmdline++;

	/* this was how to get a pointer to cmdline
	 * the following is just an example, you may use strtok() as well.
	 */

	p = cmdline;
	t = (p + cmdlen);
	*t = '\0';

	while(p < t) {
		while(*p == ' ')
			++p;
		if(*p == '\0')
			break;
		for(q = p; (*q && (*q != ' ')); ++q);
		*q = '\0';
		process(p);	/* <-- insert real operation here */
		p = q + 1;
	}
}

#endif

#endif
