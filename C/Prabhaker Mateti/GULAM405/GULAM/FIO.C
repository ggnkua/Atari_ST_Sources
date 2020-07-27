/*			
	fio.c of Gulam/uE					April 1986

	copyright (c) 1987 pm@cwru.edu

The routines in this file read and write ASCII files from the disk.
All of the knowledge about files are here.  A better message writing
scheme should be used.  This is a complete rewrite, by pm@cwru.edu, of
what was in microEmacs.

*/

#include        "ue.h"

int		lnn;			/* line number			*/
int		evalu;
long		ntotal;

local int	fd;                     /* File descriptor, all functions. */
local int	rwflag;			/* 0=read or 1=write flag */
local long	x;
local long	n;
local long	lsz;
local uchar	*txtp;
local uchar	TWD[]	="that was a directory!";

/* Open a file for writing.  Return FIOSUC if all is well, and FIOERR
on errors.  */

ffwopen(fn)
register char    *fn;
{
	if (isdir(fn)) {userfeedback(TWD, -1); return FIOERR;}
        if ((fd=gfcreate(fn, 0)) < 0)
	{	userfeedback("Cannot open file for writing", -1);
                return FIOERR;
        }

	/* we try to allocate a large buffer for read/write	*/
	lsz = 0x0FFFFFFFL;
	txtp = maxalloc(&lsz);
	x = n = 0L;  rwflag = 1;
        userfeedback(sprintp("(Writing %s ...)", fn), 1);
        return FIOSUC;
}

	local int
twrite()
{
	if (gfwrite(fd, txtp, x) == x)
	{	x = 0;
		return FIOSUC;
	}
	userfeedback("Write I/O error", -1);
	return FIOERR;
}

/* Close a file. Should look at the status in all systems. */

ffclose()
{
	register int	r;

	r = FIOSUC;
	if ((rwflag == 1) && (x < lsz)) r = twrite();
	gfclose(fd);	/* check for errors ??	*/
	maxfree(txtp);
        return r;
}

/* Write a line to the already opened file.  The "buf" points to the
buffer, and the "nbuf" is its length, less the free newline.  Return
the status.  Check only at the newline.  */

ffputline(buf, nb)
char	buf[];
{
        register	int	i;
	register	char	*p;
	extern		char	DFLNSEP[];

	p = buf;
	xxxx:
	while (nb > 0)
	{	if (x + nb > lsz && twrite() == FIOERR) return FIOERR;
		i = (x + nb <= lsz? nb : lsz - x);
		cpymem(txtp + x, p, i);  p += i; nb -= i; x += i;
	}
	if (p != &DFLNSEP [LDFLNSEP] )
	{	p = DFLNSEP;
		nb = LDFLNSEP;
		goto xxxx;
	}
        return FIOSUC;
}

/* Open a file for reading, and apply func to each of its lines.  If
file not found return.  */

frdapply(fnm, func)
register char   *fnm;
register void	(*func)();
{
	if (isdir(fnm)) {userfeedback(TWD, -1); return FIOERR;}
        if ((fd=gfopen(fnm, 0)) < 0) return FIOFNF;
        userfeedback(sprintp("(Reading %s ...)", fnm), 1);
	lnn = evalu = 0; ntotal = 0L;
	eachline(fd, func);	/* Fcloses(fd) also */

	if (evalu < 0) emsg = "File read error";
	if (emsg) {mlmesg(emsg); return FIOERR;}
	userfeedback(sprintp(
		"(Read %s, %D bytes in %d lines)",fnm, ntotal, lnn), 1);
        return FIOSUC;
}

/* -eof- */
