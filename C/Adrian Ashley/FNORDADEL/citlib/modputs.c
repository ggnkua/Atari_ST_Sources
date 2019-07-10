/*
 * modputs.c -- blort a string to the modem
 *
 * 90Aug27 AA	Split off from libmodem.c
 */

#include <ctype.h>

void pause();
void modout();

/* modputs(): %NN% will make modputs stop for NN tenths of a second */
/* 	      before continuing.				    */
void
modputs(s)
char *s;
{
    extern char Debug;
    register int delay;
    register char c;

    while (c = *s++) {
	if (c == '%' && *s) {
	    if (isdigit(*s)) {
		for (delay=0; isdigit(*s); s++)
		    delay = (delay*10) + (*s - '0');
		if (*s == '%')
		    ++s;
		if (Debug)
		    xprintf("[%d]", delay);
		pause(10*delay);
		continue;
	    }
	    c = *s++;
	}
	if (Debug)
	    xputc(isprint(c) ? c : '.');
	pause(5);
	modout(c);
    }
}
