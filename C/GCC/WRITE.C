/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 * $Header: write.c,v 1.2 88/02/03 22:56:45 m68k Exp $
 *
 * $Log:	write.c,v $
 *
 * 1.3	jrd
 *
 * Revision 1.2  88/02/03  22:56:45  m68k
 * Added unix like tty driver stuff
 * 
 * Revision 1.1  88/01/29  17:32:06  m68k
 * Initial revision
 * 
 */
/* #include	<gembios.h>	?? */
#include	<osbind.h>
#include	<ioctl.h>
#include	"tchars.h"

#ifdef DEBUG
extern int stderr;
#endif

extern	int	__col_pos;

int
write(fd, buf, nbytes)
int		fd;
char		*buf;
unsigned int	nbytes;
{
  char	*s;

  if (!(__ttymode & CRMOD) || !isatty(fd))

#ifdef DEBUG
		{
		int result = Fwrite(fd, nbytes, buf);

		fprintf(stderr, "write(%d, %X, %d)->%d\n", 
			fd, buf, nbytes, result);
		return(result);
		}
#else
	return Fwrite(fd, nbytes, buf);
#endif

  for (s = buf ; nbytes > 0 ; s++, nbytes-- )
	if (*s == '\n') 
		{
/*		Bconout(2, '\r');
		Bconout(2, '\n');	*/
		console_write_byte(2, '\r');
		console_write_byte(2, '\n');
		__col_pos = 0;
		} 
	    else
		{
		if (*s == '\r')
			__col_pos = 0;
		    else
		if (*s >= ' ' && *s < 0177)
			__col_pos++;
		    else
		if (*s == '\t')
			__col_pos = (__col_pos | 7) + 1;
/*		Bconout(2, *s);		*/
		console_write_byte(2, *s);
		}
  return nbytes;
}
