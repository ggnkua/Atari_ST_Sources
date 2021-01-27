
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

