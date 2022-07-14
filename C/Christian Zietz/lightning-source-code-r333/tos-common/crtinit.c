/*
 * Modified for the FreeMiNT USB subsystem by David Galvez. 2010 - 2011
 *
 * Modified for XaAES by Frank Naumann <fnaumann@freemint.de>
 *
 * Crtinit: C run-time initialization code.
 * Written by Eric R. Smith, and placed in the public domain.
 * Use at your own risk.
 */

/* define this symbol to get ARGV argument passing that's strictly
 * compatible with the Atari standard. If it's not defined, then
 * the startup code won't validate the ARGV= variable by checking
 * the command byte for 0x127. Note that there are still some
 * applications (gulam is a notable example) that implement only
 * part of the standard and don't set the command byte to 0x127.
 */

#if 0
#define STRICTLY_COMPATIBLE_WITH_STANDARD
#endif

#include <mint/basepage.h>
#include <mint/osbind.h>
#include <stddef.h>

#define MINFREE	(8L * 1024L) /* free at least this much mem */

/* XXX ??? */
#undef isspace
#undef isdigit
#define isspace(c) ((c) == ' '||(c) == '\t')
#define isdigit(c) ((c) >= '0' && (c) <= '9')

int init(int argc, char **argv, char **env);

/* setstack.S */
void __CDECL _setstack(void *newsp);

/* in startup.S */
extern BASEPAGE *_base;

char *program_invocation_name;
char *program_invocation_short_name;

char **environ;
char **__libc_argv;
long   __libc_argc;


/* size to be allocated for the stack
 * it's defined in XXXXDEFS build files
 * (ex: USBDEFS, STORAGEDEFS, etc )
 */
long _stksize = STACKSIZE;

/* total size of program area */
unsigned long _PgmSize;

static long parseargs(BASEPAGE *);
void _crtinit(void);

void
_crtinit(void)
{
	register BASEPAGE *bp;
	register long m;

	bp = _base;

	/* m = # bytes used by environment + args */
	m = parseargs(bp);

	/* make m the total number of bytes required by program sans stack/heap */
	m += (bp->p_tlen + bp->p_dlen + bp->p_blen + sizeof(BASEPAGE));
	m = (m + 3L) & (~3L);

	/* make m the total number of bytes including stack */
	_stksize = _stksize & (~3L);
	m += _stksize;

	/* make sure there's enough room for the stack */
	if (((long)bp + m) > ((long)bp->p_hitpa - MINFREE))
		goto notenough;

	/* set up the new stack to bp + m  */
	_setstack((char *)bp + m);

	/* shrink the TPA */
	(void)Mshrink(bp, m);

	/* keep length of program area */
	_PgmSize = m;

	m = init(__libc_argc, __libc_argv, environ);
	Pterm(m);

notenough:
	(void) Cconws("Fatal error: insufficient memory\r\n");
	Pterm(-1);
}

static char *
my_strrchr(char *str, long which)
{
	register char *s = str;
	register char *place = NULL;
	register unsigned char c;

	do {
		c = *s++;
		if (c == which)
			place = s - 1;
	}
	while (c);

	return place;
}

/*
 * parseargs(bp): parse the environment and arguments pointed to by the
 * basepage. Return the number of bytes of environment and arguments
 * that have been appended to the bss area (the environ and argv arrays
 * are put here, as is a temporary buffer for the command line, if
 * necessary).
 *
 * The MWC extended argument passing scheme is assumed.
 *
 */
static long
parseargs(BASEPAGE *bp)
{
	long count = 4; /* compensate for aligning */
	long  i;
	char *from, *cmdln, *to;
	char **envp, **arg;
	char *null_list = 0;
	/* flag to indicate desktop-style arg. passing */
	long desktoparg;

	/* handle the environment first */

	environ = envp = (char **)(((long)bp->p_bbase + bp->p_blen + 4) & (~3));
	from = bp->p_env;
	while (*from)
	{
		/* if we find MWC arguments, tie off environment here */
		if (*from == 'A' && *(from+1) == 'R' && *(from+2) == 'G'
		    && *(from+3) == 'V' && *(from + 4) == '=')
		{
			*envp++ = (char *) 0; count += 4;
			*from = 0;
#ifdef STRICTLY_COMPATIBLE_WITH_STANDARD
			if (bp->p_cmdlin[0] != 127)
				goto old_cmdlin;
#endif
			/* skip ARGV= string */
			from += 5;

			/* find list of empty params
			 */
			if (*from == 'N' && *(from+1) == 'U'
			    && *(from+2) == 'L' && *(from+3) == 'L'
			    && *(from+4) == ':')
			{
				null_list = from + 5;
			}

			while (*from++) ; /* skip ARGV= value */
			__libc_argv = arg = envp;
			*arg++ = from; count+= 4;
			while (*from++) ; /* skip __libc_argv[0] */
			goto do_argc;
		}
		*envp++ = from;
		count += 4;
		desktoparg = 1;
		while (*from)
		{
			if (*from == '=')
			{
				desktoparg = 0;
			}
			from++;
		}
		from++; /* skip 0 */

		/* the desktop (and some shells) use the environment in the wrong
		 * way, putting in "PATH=\0C:\0" instead of "PATH=C:". so if we
		 * find an "environment variable" without an '=' in it, we
		 * see if the last environment variable ended with '=\0', and
		 * if so we append this one to the last one
		 */
		if (desktoparg && envp > &environ[1])
		{
			/* launched from desktop -- fix up env */
			char *p, *q;

			q = envp[-2]; /* current one is envp[-1] */
			while (*q) q++;
			if (q[-1] == '=')
			{
				p = *--envp;
				while(*p)
					*q++ = *p++;
				*q = '\0';
			}
		}
	}
	*envp++ = NULL;
	count += 4;

#ifdef STRICTLY_COMPATIBLE_WITH_STANDARD
old_cmdlin:
#endif
	/* Allocate some room for the command line to be parsed */
	cmdln = bp->p_cmdlin;
	i = *cmdln++;
	from = to = (char *)envp;
	if (i > 0)
	{
		count += (i&(~3));
		envp = (char **)(((long)envp) + (i & (~3)));
	}
	envp += 2; count += 8;

	/* Now parse the command line and put __libc_argv after the environment */

	__libc_argv = arg = envp;
	*arg++ = ""; /* __libc_argv[0] not available */
	count += 4;
	while (i > 0 && isspace(*cmdln))
		cmdln++, --i;

	/*
	 * MagXDesk only uses ARGV if the arg is longer than the 126 character
	 * of bp->cmdlin. If the arg is short enough and contains a file name with
	 * blanks it will be come quoted via bp->cmdlin!!
	 */
	if (cmdln[0] != '\'')
	{
		while (i > 0)
		{
			if (isspace(*cmdln))
			{
				--i; cmdln++;
				while (i > 0 && isspace(*cmdln))
					--i, cmdln++;
				*to++ = 0;
			}
			else
			{
				if ((*to++ = *cmdln++) == 0)
					break;
				i--;
			}
		}
	}
	else
	{
		int in_quote = 0;

		while (i > 0)
		{
			if (*cmdln == '\'')
			{
				i--;
				cmdln++;
				if (in_quote)
				{
					if (*cmdln == '\'') /* double ': file name contains ' */
					{
						*to++ = *cmdln++;
						i--;
					}
					else
					{
						in_quote = 0;
						*to++ = 0; /* end of quoted arg */
						i--; cmdln++;
					}
				}
				else
					in_quote = 1;
			}
			else
			{
				if (*cmdln == ' ')
				{
					if (in_quote)
					{
						*to++ = *cmdln++;
						i--;
					}
					else
					{
						--i; cmdln++;
						*to++ = 0;
					}
				}
				else
				{
					*to++ = *cmdln++;
					i--;
				}
			}
		}
	}

	*to++ = '\0';
	*to = '\0'; /* bug fix example:cmdln == '\3' 'a' ' ' 'b' '\0' */
	/* the loop below expects \0\0 at end to terminate! */
	/* the byte @ cmdln[i+2] != 0 when fast bit is set */
do_argc:
	/* Find out the name we have been invoked with.  */
	if (__libc_argv[0] != 0 && __libc_argv[0][0] != '\0')
	{
		char *p;

		program_invocation_name = __libc_argv[0];
		p = my_strrchr(program_invocation_name, '\\');
		if (p == NULL)
			p = my_strrchr(program_invocation_name, '/');
		if (p != NULL)
			p++;

		program_invocation_short_name = (p == 0) ?
			program_invocation_name : p;
	}

	__libc_argc = 1; /* at this point __libc_argv[0] is done */
	while (*from)
	{
		*arg++ = from;
		__libc_argc++;
		count += 4;
		while (*from++) ;
	}
	*arg = NULL;

	/* zero epmty params
	 */
	if (null_list)
	{
		char *s;
		unsigned long idx;

		while (*null_list)
		{
			s = null_list;

			while (*++null_list) /* find ',' or '\0' */
			{
				if (*null_list == ',')
				{
					*null_list++ = 0;
					break;
				}
			}

			idx = 0;
			for (;;)
			{
				if (!isdigit(*s))
					goto bail_out;

				/* don't feed this to strtol(),
				 * do the ascii -> long conversion by
				 * hand for efficency
				 */
				idx += *s++ - '0';
				if (*s)
					idx = (idx << 3) + (idx << 1);
				else
					break;
			}

			if (idx < __libc_argc)
				*(__libc_argv[idx]) = 0;
			else
				goto bail_out;
		}
	}

bail_out:
	return count+4;
}
