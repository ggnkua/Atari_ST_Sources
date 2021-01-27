
#include <prelude.h>
#include <tos.h>
#include "aaaankcc.h"

short nkc_tconv(long toskey);

global
KEYTAB keytab;

global
uchar xscantab[] =
{
	NK_UP,		0x48,	/* cursor up			*/
	NK_DOWN,	0x50,	/* cursor down			*/
	NK_LEFT,	0x4b,	/* cursor left			*/
	NK_LEFT,	0x73,	/* Control cursor left	*/
	NK_RIGHT,	0x4d,	/* cursor right			*/
	NK_RIGHT,	0x74,	/* Control cursor right	*/
	NK_INS,		0x52,	/* Insert				*/
	NK_CLRHOME,	0x47,	/* ClrHome				*/
	NK_CLRHOME,	0x77,	/* Control ClrHome		*/
	NK_HELP,	0x62,	/* Help					*/
	NK_UNDO,	0x61,	/* Undo					*/
	-1, -1
};

global
void *nkc_init(void)
{
	void * pmin = (void *)-1;
	keytab = *Keytbl(pmin,pmin,pmin);
	return &keytab;
}

global
short nkc_exit(void) { return 0; }


global
short normkey(short aesstate, short aescode)
{
	struct
	{
		uchar s, f, d, code;
	} t;

	t.s = aesstate;
	t.f = aescode >> 8;
	t.d = 0;
	t.code = aescode;

	aescode = nkc_tconv(*(long *)&t);
	aescode &= 0xbfff;
	if ((aescode & 0x0300) ne 0)
		aescode |= 0x0300;

	return aescode & 0xefff;
}

#if 0		/* HR: later :-) */
/* The real nkc_tconv is in nkcc.s */
global
short nkc_tconv(long toskey)
{
	char *tab;
	ushort state, flags, scan, code;
	struct
	{
		uchar s, f;
		ushort code;
	} key;

	*(long *)&key = toskey;
	code  = key.code;
	state = key.s;
	scan  = key.f;
	flags = scan << 8;		/* for masks */
	if (scan)				/* --> .tos306 */
	{
		if (flags & NKF_SHIFT)
			tab = keytab.shift;	/* use shift table */
		elif (flags & NKF_CAPS)
			tab = keytab.capslock;	/* use CapsLock table */
		else
			tab = keytab.unshift;	/* use unshifted table */
ktab3:
		if (scan >= 0x78)			/* alpha block ? */
		{
			code = tab[scan - 0x76];
			flags |= NKF_ALT;		/* set Alternate flag */
			/* --> cat_codes */
		othw
/* scan1: */
			uchar *x = xscantab;
search_scan:
			while(*x >= 0)
			{
				uchar y = *x++;
				if (y eq scan)
					break;
				y <<= 8;
			}
tabend:
		}
cat_codes:
		;
	}
tos306:
	return flags | code;
}
#endif
