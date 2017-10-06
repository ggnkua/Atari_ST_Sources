/*
 *	teeny-tiny tty driver
 */

#include <stdio.h>
#include <osbind.h>
#include <errno.h>

#define	EXIT_BREAK	EINVFN		/* ^C exit value */

#define	cecho(c)	Bconout(2,(c))	/* echo character to console */

_tttty(fp)
	register FILE *fp;
	{
	register int f;
	register unsigned char *bp = fp->_base;
	char c;
	register int n = 0, m = 0;

	f = fp->_flag;
#ifdef DEBUG
fprintf(stderr, "[_tttty: entry, mode=%s]\n",
	((f & _IOBIN)
		? "binary"
		: ((f & _IONBF)
			? "unbuffered"
			: "buffered")));
#endif
	for(;;)
		{
		m = read(fp->_file, &c, 1);
		if(m <= 0)		/* file read error or EOF */
			return(n ? n : m);
		if(f & _IOBIN)
			{
			++n;
			*bp++ = c;
			}
		else if(f & _IONBF)
			{
			++n;
			if((*bp++ = c) == '\003')	/* ^C (BREAK) */
				exit(EXIT_BREAK);
			}
		else
			{
			switch(c)
				{
				case '\b':	/* BS */
				case '\177':	/* DEL */
					if(n > 0)
						{
						--n;
						--bp;
						if(c == '\177')
							{
							cecho('\b');
							cecho(' ');
							cecho('\b');
							cecho('\b');
							}
						cecho(' ');
						cecho('\b');
						}
					break;

				case '\004':	/* ^D (acts like ^Z) */
					c = '\032';
					/* fall-thru */

				case '\032':	/* EOF */
					cecho('\r');
					/* fall-thru */

				case '\r':	/* CR */
				case '\n':	/* LF */
					*bp = c;
					++n;
					cecho((c == '\n') ? '\r' : '\n');
#ifdef DEBUG
fprintf(stderr, "[_tttty: eof/cr/nl exit, n=%d]\n", n);
#endif
					return(n);

				case '\025':	/* ^U */
				case '\0':	/* ^@ */
					/* erase all characters in buffer */
					while(n > 0)
						{
						--n;
						--bp;
						cecho('\b');
						cecho(' ');
						cecho('\b');
						}
					break;

				case '\003':	/* ^C (BREAK) */
					exit(EXIT_BREAK);

				default:
					++n;
					*bp++ = c;
					break;
				}
			}
		if(n >= fp->_bsiz)
			break;
		}
#ifdef DEBUG
fprintf(stderr, "[_tttty: buffer full exit, n=%d]\n", n);
#endif
	return(n);
	}
