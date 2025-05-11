/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: read.c,v 1.2 88/02/03 22:56:30 m68k Exp $
 *
 * $Log:	read.c,v $
 *
 * 1.3		jrd
 *
 * Revision 1.2  88/02/03  22:56:30  m68k
 * Added unix like tty driver stuff
 * 
 * Revision 1.1  88/01/29  17:31:39  m68k
 * Initial revision
 * 
 */
/* #include	<gembios.h>	?? */
#include	<osbind.h>
#include	<ioctl.h>
#include	<signal.h>
#include	"tchars.h"

#define	iswhite(c)	((c) == ' ' || (c) == '\t')
#define	isvisable(c)	((c) >= ' ' && (c) < 0x7f)
#define	echochar(c)	if (__ttymode & ECHO) (void) _echochar(c); else
#define	delchar(n)	if (__ttymode & ECHO) _delchar(n); else

# ifndef	NULL
#  define	NULL	0
# endif	/* NULL */

extern	void	_do_signal();

int		__col_pos = 0;
static int	start_col;
static char	*thebuf;

static	int	_echochar();
static	void	_delchar();

int
read(fd, buf, nbytes)
	int	fd;
	char	*buf;
	int	nbytes;
{
	extern	int	errno;
#ifdef DEBUG
	char dbgbuf[64];
#endif


	int		rval;
	int		cnt = 0;
	char		*p = buf;

	if (!isatty(fd))
		{
		if ((rval = Fread(fd, nbytes, buf)) < 0) 
			{
			errno = rval;
			rval = -1;
			}
#ifdef DEBUG
	sprintf(dbgbuf, "read(%d, %X, %d)->%d\r\n", fd, buf, nbytes, rval);
	dbgstr(dbgbuf);
#endif
		return rval;
		}
	thebuf = buf;
	start_col = __col_pos;
	while (1) {
		*p = Bconin(2) & 0xff;
		if (__ttymode & RAW) 
			{
			if (__ttymode & ECHO) 
				{
				Bconout(2, *p);
				if (*p == '\r')
					__col_pos = 0;
				else if (isvisable(*p))
					__col_pos++;
				}
			if (++cnt >= nbytes || !(short)Bconstat(2))
				return cnt;
			p++;
			continue;
			}
		if ((__ttymode & CRMOD) && *p == '\r')
			*p = '\n';
		if (*p == __tchars[TC_INTRC]) 
			{
			/* Do the bsd thing here, i.e. flush buffers
			 * and continue to read after the interupt
			 */
			echochar(*p);
			p = buf;
			cnt = 0;
			_do_signal(SIGINT);
			} 
		    else 
		if (*p == __tchars[TC_QUITC]) 
			{
			echochar(*p);
			p = buf;
			cnt = 0;
			_do_signal(SIGQUIT);
			}
		if (__ttymode & CBREAK) 
			{
			if (*p == __tchars[TC_LNEXTC])
				*p = Bconin(2);
			if (__ttymode & ECHO) 
				{
				if (*p == '\n' && (__ttymode & CRMOD)) 
					{
					Bconout(2, '\n');
					Bconout(2, '\r');
					__col_pos = 0;
					} 
				    else
					(void) _echochar(*p);
				}
			++cnt;
			if (!(short) Bconstat(2))
				return cnt;
			p++;
			} 
		    else
		if (*p == __tchars[TC_LNEXTC]) 
			{
			if (__ttymode & ECHO) 
				{
				Bconout(2, '^');
				Bconout(2, '\b');
				}
			*p = Bconin(2);
			echochar(*p++);
			cnt++;
			}
		    else
		if (*p == __tchars[TC_EOFC]) 
			{
			if (__ttymode & ECHO)
				{
				int i = _echochar(*p);
				__col_pos -= i;
				while (i-- > 0)
					Bconout(2, '\b');
				}
			return cnt;
			}
		    else
		if (*p == '\n' || *p == __tchars[TC_BRKC]) 
			{
			if (__ttymode & ECHO)
				if (*p == '\n')
					{
					Bconout(2, '\n');
					if (__ttymode & CRMOD) 
						{
						Bconout(2, '\r');
						__col_pos = 0;
						}
					}
				    else
					(void) _echochar(*p);
			return ++cnt;
			}
		    else
		if ((*p == __tchars[TC_ERASE]) || (*p == __tchars[TC_ERASE]))
			{
			if (cnt) 
				{
				p--;
				delchar(--cnt);
				}
			}
		    else
		if (*p == __tchars[TC_KILL]) 
			{
			while (--cnt >= 0) 
				{
				delchar(cnt);
				p--;
				}
			cnt = 0;
			} 
		    else
		if (*p == __tchars[TC_WERASC]) 
			{
			p--;
			while (cnt && iswhite(*p)) 
				{
				delchar(--cnt);
				p--;
				}
			while (cnt && !iswhite(*p)) 
				{
				delchar(--cnt);
				p--;
				}
			p++;
			}
		    else
		if (*p == __tchars[TC_RPRNTC]) 
			{
			char	*s;

			echochar(__tchars[TC_RPRNTC]);
			Bconout(2, '\r');
			Bconout(2, '\n');
			__col_pos = 0;
			start_col = 0;
			if (__ttymode & ECHO)
				for (s = buf ; s < p ; s++)
					echochar(*s);
			}
		    else
			{
			echochar(*p++);
			cnt++;
			}
		if (cnt >= nbytes)
			return cnt;
	}
	/*NOTREACHED*/
}

static	int
_echochar(c)
	char	c;
{
	int	len = 0;

	if (c & 0x80) {
		Bconout(2, 'M');
		Bconout(2, '-');
		c &= 0x7f;
		len += 2;
	}
	if (c < ' ') {
		if (c == '\t') {
			int	i;

			len = ((__col_pos | 7) + 1) - __col_pos;
			if (__ttymode & XTABS)
				for (i = len ; i-- ;)
					Bconout(2, ' ');
			else
				Bconout(2, '\t');
		} else {
			Bconout(2, '^');
			Bconout(2, c + 0x40);
			len += 2;
		}
	} else if (c == 0x7f) {
		Bconout(2, '^');
		Bconout(2, '?');
		len += 2;
	} else {
		Bconout(2, c);
		len++;
	}
	__col_pos += len;
	return len;
}

static	void
_delchar(n)
	int	n;
{
	int	len;
	char	c = thebuf[n];

	if (c & 0x80) {
		len = 2;
		c &= 0x7f;
	} else
		len = 0;
	if (c < ' ' || c == 0x7f) {
		if (c == '\t')
			len = __col_pos - str_length(thebuf, n);
		else
			len += 2;
	} else
		len++;
	__col_pos -= len;
	while (len--) {
		Bconout(2, '\b');
		Bconout(2, ' ');
		Bconout(2, '\b');
	}
}

static	int
str_length(p, n)
	char	*p;
	int	n;
{
	int	pos = start_col;
	char	c;

	while (n--) {
		c = *p++;
		if (c & 0x80) {
			pos += 2;
			c &= 0x7f;
		}
		if (c < ' ' || c == 0x7f)
			if (c == '\t')
				pos = (pos | 7) + 1;
			else
				pos += 2;
		else
			pos++;
	}
	return pos;
}
