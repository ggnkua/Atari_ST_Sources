/****************************************************************************
code to handle special keys (i.e. function keys, arrow keys, help, undo, ...).
returns either ascii value of normal key or scan code value of special key.
flag speckey is true if key is special, false otherwise.
******************************************************************************/
#ifdef MiNT
#include <osbind.h>
#include <stdio.h>

#ifndef FALSE
#define FALSE 0
#define TRUE !FALSE
#endif

bgetkey(int *speckey)
{
	union scancode {
		long	scan;
		short	scarray[2];
	} sc;

	sc.scan = Bconin(2);
	if (sc.scarray[1]) {
		*speckey = FALSE;
		return (sc.scarray[1]);
	}
	else {
		*speckey = TRUE;
		return (sc.scarray[0]);
	}
}

#define keynotready !Bconstat(2)

jgetkey()
{
	int keycode, spec_key;
#define SPEC_START	(0x80 - 0x3b)

	while (keynotready)
		waitfun();

	keycode = bgetkey(&spec_key);
	if (spec_key) {
		if ((keycode > 0x77) || (keycode < 0x3b))   /* no alt keys */
			return (0x45);	  /* undefined, so unbound */
		return (keycode + SPEC_START);
	}
	return (keycode);
}

int last_min = 0;

waitfun()
{
	if (UpdModLine) {
		redisplay();
		return;
	}
	{
		const struct tm *t_buf;
		time_t num_secs;

		time(&num_secs);
		t_buf = localtime(&num_secs);
		if (t_buf->tm_min != last_min) {
			UpdModLine = YES;
			last_min = t_buf->tm_min;
		}
	}
}
#endif /* MiNT */
