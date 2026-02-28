/*
 *
 * DO NOT INCLUDE THIS FILE IF YOU USE ARGC/ARGV OR STANDARD I/O AT ALL!!
 *
 * This header file defines _initarg() and _main() functions, that replace
 * the ones in the standard library.  With these functions, none of the
 * standard i/o functions normally linked into a program will be referenced,
 * and the command line arguments will not be parsed.
 *
 * However... if you REALLY need arguments, but still want a teeny tiny
 * (non-portable) program, you can use a main() like this...
 *
 *	#include <sys\minimum.h>
 *
 *	main()
 *		{
 *		register char *p, *q, *t;
 *	
 *		t = (p + _cmdlen);
 *		*t = '\0';
 *		p = _cmdline;
 *		while(p < t)
 *			{
 *			while(*p == ' ')
 *				++p;
 *			if(*p == '\0')
 *				break;
 *			for(q = p; (*q && (*q != ' ')); ++q)
 *				;
 *			*q = '\0';
 *			process(p);	<-- insert real operation here
 *			p = q + 1;
 *			}
 *		}
 */

#ifndef MINI_H
#define	MINI_H

extern int	_argc;
extern char	**_argv;
extern char	*_envp;

char	*_cmdline;	/* make command line image globally available */
int	_cmdlen;	/* make it's length global also */

_initargs(cmdline, cmdlen)
	register char *cmdline;
	register int cmdlen;
	{
	register int i = cmdlen;
	char *sbrk(), *strncpy();

	_cmdline = strncpy(sbrk((i + 2) & ~1), cmdline, cmdlen);
	_cmdline[_cmdlen = cmdlen] = '\0';
	}

_main()
	{
	main(_argc, _argv, _envp);
	_exit(0);
	}

#define	exit(code)	_exit(code)	/* no stdio, no cleanup needed */

#endif
