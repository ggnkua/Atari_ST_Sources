/*
 * congetyn.c -- get a yes/no response from the console.
 *
 * 90Sep29 AA	Fixed to see `active' flag.
 * 90Aug27 AA	Split off from libmisc.c
 */

#include "ctdl.h"
#include "citlib.h"

int
conGetYesNo(message)
char *message;
{
    char c;

    printf("\r%s? (Y/N): ",message);
    while (1) {
	if (active) {
	    c = (char)tolower(getch());
	    if (c == 'y' || c == 'n') {
		printf("%c\n ", c);
		return (c == 'y');
	    }
	    putchar(7);
	}
    }
}
