#include <stdio.h>
#include <osbind.h>
#include <string.h>
#include <basepage.h>
#include <errno.h>

typedef struct
	{
	char		xarg_magic[4];	/* verification value "xArg" */
	int		xargc;		/* argc */
	char		**xargv;	/* argv */
	char		*xiovector;	/* i/o handle status */
	BASEPAGE	*xparent;	/* pointer to parent's basepage */
	}
	XARG;

extern int      _argc;
extern char     **_argv;

static char     xmagic[] = "xArg";
static char     hex[] = "0123456789ABCDEF";

static char *_sbrk(size)
	register int size;
/*
 * Internal error checking interface for the sbrk() function
 */
	{
	register char *p;
	char *sbrk();

	size = (size + 1) & ~1;
	if(p = sbrk(size))
		return(p);
	Cconws("Too many arguments\n");
	_exit(ENSMEM);
	}
	
/*
 * Retrieve extended arguments, if possible, and set up argc and argv[].
 */
void _initargs(cmdline, cmdlen)
	char *cmdline;
	int cmdlen;
	{
	register XARG *xp;
	register char *p, **q;
	register int i, n;
	register long a;
	char *getenv();

	if(p = getenv(xmagic))
		{
		/*
		 * if the "xArg" variable exists, decode the address
		 * and assume that it points somewhere reasonable,
		 * though possibly not to a valid XARG struct
		 */
		for(a = 0L; *p; ++p)	/* convert ascii-hex to long */
			a = ((a << 4) | (0xF & strpos(hex, *p)));
		xp = ((XARG *) a);
		}
	if((p == NULL)					/* no extended args */
	|| (strncmp(xp->xarg_magic, xmagic, 4))		/* not XARG struct */
	|| (xp->xparent != _base->p_parent))		/* not right parent */
		{
		/* copy the command line */
		i = cmdlen;
		p = strncpy(_sbrk(i + 1), cmdline, i);
		p[i] = '\0';
		_argv = q = (char **) _sbrk(sizeof(char *));
		*q = "";				/* argv[0] == "" */
		n = 1;
		/*
		 * parse command line image based on whitespace
		 */
		if(p = strtok(p, " \t"))
			{
			do
				{
				q = (char **) _sbrk(sizeof(char *));
				++n;
				*q = p;
				}
				while(p = strtok(NULL, " \t"));
			}
		q = (char **) _sbrk(sizeof(char *));
		*q = NULL;				/* tie off argv */
		_argc = n;
		}
	else						/* EXTENDED ARGS! */
		{
		/*
		 * extended args are easy... just remember to copy the
		 * data, since it resides in your parent's data space
		 */
		_argc = n = xp->xargc;			/* copy argc */
		i = ((n + 1) * sizeof(char *));
		_argv = q = ((char **) _sbrk(i));
		memcpy(q, xp->xargv, i);		/* copy argv */
		q[n] = NULL;
		do					/* copy arguments */
			{
			p = _sbrk(strlen(*q) + 1);
			*q = strcpy(p, *q);
			}
			while(*++q);
		}
	if((_argv[0] == NULL) || (_argv[0][0] == '\0'))
		{
		/*
		 * argv[0] not set, extract value from parent's dta
		 */
		p = (char *) _base->p_parent;	/* get parent's basepage */
		if(p == NULL)
			_argv[0] = "";		/* for sid... */
		else
			{
			p = *(char **)(p+0x7C);	/* get parent's saved usp */
			p = *(char **)(p+0x36);	/* get Pexec'd filename */
			_argv[0] = _sbrk(strlen(p) + 1);
			strcpy(_argv[0], p);	/* copy filename */
			}
		}
	}
