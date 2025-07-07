#include <osbind.h>
#include <stdio.h>

static int	_cfg_ch = _CIOCH;	/* getch()/putch() configuration */
unsigned long	_getch = 0L;		/* raw getch() value from OS */

cfg_ch(cfg)
	int cfg;
	{
	register int oldcfg;

	oldcfg = _cfg_ch;
	if(cfg != -1)
		_cfg_ch = cfg;
	return(oldcfg);
	}

int getch()
	{
	register unsigned long cc;
	register unsigned int c;

	_getch = cc = (_cfg_ch & _CIOB) ? Bconin(2) : Crawcin();
	if(_cfg_ch & _CIOCH)
		{
		if((c = cc) == 0)		/* null character code */
			c = (cc >> 16) | 0x80;	/* get scan code instead */
		c &= 0xFF;			/* make it 8-bit only */
		}
	else
		c = (0x00FF & cc) | (0xFF00 & (cc >> 8));
	return(c);
	}

char putch(c)
	register char c;
	{
	if(_cfg_ch & _CIOB)
		if((c < ' ') || (_cfg_ch & _CIOVT))
			Bconout(2, c);
		else
			Bconout(5, c);
	else
		Cconout(c);
	return(c);
	}

int getche()
	{
	register char c;

	c = getch();			/* do normal getch() */
	putch((char) _getch);		/* echo from raw OS code */
	return(c);
	}

int kbhit()
	{
	return((_cfg_ch & _CIOB) ? Bconstat(2) : Cconis());
	}
