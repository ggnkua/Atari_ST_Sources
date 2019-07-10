/*
 * io.c -- low level I/O bindings for Fnordadel.
 *
 * 90Nov06 AA	Translated back from the assembler version.  With a decent
 *		compiler (gcc) they should be the same anyway.
 */

/*
 * KBReady()	Detect a console keypress
 * getch()	get a 7-bit char from stdin
 * putch()	put a char to the console
 * MIReady()	detect a char waiting at the modem port
 * getraw()	get a character from the modem port
 * getMod()	get a 7-bit character from the modem port
 * modout()	put a character out the modem
 */

#include <osbind.h>

int active = 1;

int
KBReady(void)
{
    if (active)
	return Cconis();
    else
	return 0;
}

int
getch(void)
{
    return (int)(Crawcin() & 0x7f);
}

void
putch(register int c)
{
    Bconout(2,(short)c);
}

int
MIReady(void)
{
    return (int)Bconstat(1);
}

int
getraw(void)
{
    return (int)(Bconin(1));
}

int
getMod(void)
{
    return (int)(Bconin(1) & 0x7f);	/* only return seven bits here... */
}

void
modout(register int c)
{
    Bconout(1,(short)c);
}
