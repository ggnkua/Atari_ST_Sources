#include <stdio.h>
#include <osbind.h>
#include <string.h>
#include <basepage.h>
#include <malloc.h>
#include <errno.h>

typedef struct
	{
	char		xarg_magic[4];    /* verification value "xArg" */
	int		xargc;            /* argc */
	char		**xargv;          /* argv */
	char		*xiovector;       /* i/o handle status */
	BASEPAGE	*xparent;         /* pointer to parent's basepage */
	}
	XARG;

static char     xmagic[] = "xArg";
static char     hex[] = "0123456789ABCDEF";

#define	MAXFORK	8		/* maximum number of concurrent fork's */

typedef struct
	{
	int		fk_pid;
	char		fk_rv;
	char		fk_xstatus;
	}
	FORK;

static	FORK	forktbl[MAXFORK];

#define	XS_NORMAL	0x00		/* process terminated normally */
#define	XS_RUNNING	0x7F		/* process still running */

static	FORK	*forkp = forktbl;	/* fork() context pointer */
static	int	forkcnt = 0;		/* # of fork's currently active */
static	char	fork_ext[] = ".ttp\0.tos\0.prg\0.app\0";

/*
 * Build TOS-style command line image from argv[] list.
 */
int makcmdln(cmdln, argv)
	char *cmdln;
	char **argv;
	{
	register char *p, *q, *e;
	register int argc = 1;

	p = cmdln + 1;
	e = cmdln + 127;
	while(q = *++argv)		/* start at argv[1] */
		{
		++argc;
		while(*q && p < e)
			*p++ = *q++;
		if (p < e)
			*p++ = ' ';
		}
	*p = '\0';
	cmdln[0] = p - (cmdln + 1);     /* store the string length */
	return(argc);                   /* return number of arguments */
	}

forkl(pathname, arg0)
	char *pathname, *arg0;
	{
	forkve(pathname, &arg0, NULL);
	}

forkle(pathname, arg0)
	char *pathname, *arg0;
	{
	register char **argv = &arg0, *envp;
	register int argc;
	char cmdln[130];

	argc = makcmdln(cmdln, argv);
	envp = argv[argc+1];
	return(_exec(pathname, cmdln, argc, argv, envp));
	}

int forklp(pathname, arg0)
	char *pathname, *arg0;
	{
	char *pfindfile();

	if(pathname = pfindfile(NULL, pathname, fork_ext))
		return(forkve(pathname, &arg0, NULL));
	return(errno = EFILNF);
	}

int forklpe(pathname, arg0)
	char *pathname, *arg0;
	{
	register char **argv = &arg0, *envp;
	register int argc;
	char cmdln[130];
	char *pfindfile();

	if(pathname = pfindfile(NULL, pathname, fork_ext))
		{
		argc = makcmdln(cmdln, argv);
		envp = argv[argc+1];
		return(_exec(pathname, cmdln, argc, argv, envp));
		}
	return(errno = EFILNF);
	}

forkve(pathname, argv, envp)
	char *pathname, **argv, *envp;
	{
	register int argc;
	char cmdln[130];

	argc = makcmdln(cmdln, argv);
	return(_exec(pathname, cmdln, argc, argv, envp));
	}

forkvpe(pathname, argv, envp)
	char *pathname, **argv, *envp;
	{
	char *pfindfile();

	if(pathname = pfindfile(NULL, pathname, fork_ext))
		return(forkve(pathname, argv, envp));
	return(errno = EFILNF);
	}

FORK *_fork()
/*
 * create FORK struct for new process and return calculated pid
 */
	{
	register long n;
	register int pid;
	register FORK *fp;

	if((forkcnt >= MAXFORK)		/* too many forks already active? */
	|| ((n = Malloc(-1L)) <= 0))	/* malloc error? */
		return(NULL);
	n = Malloc(n);			/* get address of next free block */
	Mfree(n);
	fp = forkp++;
	++forkcnt;
	n += 0x3EL;			/* adjust it */
	pid = (0x7FFF & (n>>8));	/* calculate pid from it */
	fp->fk_pid = pid;		/* initialize process entry */
	fp->fk_xstatus = XS_RUNNING;
	fp->fk_rv = 0;
	return(fp);
	}

int _exec(pathname, cmdln, argc, argv, envp)
	char *pathname, *cmdln;
	int argc;
	char **argv, *envp;
	{
	register FORK *fp;
	XARG xarg;
	register XARG *xp = &xarg;
	register char *p;
	register int n;
	register long rv;
	char xenv[16];

	if((fp = _fork()) == NULL)
		return(ERROR);
	/*
	 * initialize XARG struct
	 */
	strncpy(xp->xarg_magic, xmagic, 4);
	xp->xargc = argc;
	xp->xargv = argv;
	xp->xiovector = NULL;
	xp->xparent = _base;
	/*
	 * create environment variable "xArg=XXXXXXXX"
	 */
	strcpy(xenv, xmagic);
	p = strrchr(xenv, '\0');        /* move to terminating '\0' */
	*p++ = '=';
	rv = ((long) xp);
	for(n=8; n--; rv >>= 4)         /* convert long to ascii-hex */
		p[n] = hex[rv & 0xF];
	p[8] = '\0';
	/*
	 * install environment variable and execute program
	 */
	putenv(xenv);
	rv = Pexec(0, pathname, cmdln, envp);
	putenv(xmagic);                 /* remove "xArg" from environment */
	if(rv < 0L)			/* GEMDOS error */
		{
		errno = ((int) rv);
		fp->fk_rv = fp->fk_xstatus = ((char) rv);
		}
	else				/* normal exit */
		{
		fp->fk_xstatus = XS_NORMAL;
		fp->fk_rv = ((char) rv);
		}
	return(fp->fk_pid);
	}

int wait(rvp)
	char *rvp;
	{
	register FORK *fp;
	register int pid;

	fp = forktbl;
	if(fp == forkp)			/* no child processes */
		return(errno = ERROR);
	for(;;)
		{
		for(fp = forktbl; fp < forkp; ++fp)
			{
			if(fp->fk_xstatus != XS_RUNNING)
				{
				pid = fp->fk_pid;
				if(rvp)
					{
					rvp[0] = fp->fk_rv;
					rvp[1] = fp->fk_xstatus;
					}
				--forkp;
				--forkcnt;
				while(fp++ < forkp)
					fp[-1] = fp[0];
				return(pid);
				}
			}
		sleep(1);
		}
	}
