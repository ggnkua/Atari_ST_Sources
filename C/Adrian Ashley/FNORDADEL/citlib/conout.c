/*
 * conout.c -- spit a character to modem and console
 *
 * 90Aug27 AA	Split off from libout.c
 */

#include "ctdl.h"
#include "citlib.h"

/* Must find a better place to put these things. */
char seemodem = YES;		/* See what the modemed user is typing?	*/
char onConsole = NO;		/* input coming from the console?	*/

extern char echo;

void
conout(int c)
{
    if (active && (onConsole || (seemodem && echo && c != BELL))) {
	putch(c);
	if (c == '\n')
	    putch('\r');
    }
}
