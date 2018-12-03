/* 
 *   Copyright (c) 1990 Rodney Volz
 *   ALL RIGHTS RESERVED 
 * 
 *   THIS SOFTWARE PRODUCT CONTAINS THE
 *   UNPUBLISHED SOURCE CODE OF RODNEY VOLZ
 *
 *   The copyright notices above do not evidence
 *   intended publication of such source code.
 *
 */

/*
 * MERCURY UUCP SOURCECODE [scr.c]
 */

#include "define.h"

locate(x,y)
int x,y;
{
	out(27);
	out('Y');
	out(31 + y);
	out(31 + x);
}
	

box(a,b,c,d)
int a,b,c,d;
{
	int n,i;

	char s[LLEN];
	
	locate(a,b);
	out('+');
	n = c - a;
	while (--n)
		out('-');
	
	locate(c,b);
	out('+');
	locate(a,d);
	out('+');
	locate(a,d);
	out('+');

	n = c - a;
	while (--n)
		out('-');
	
	locate(c,d);
	send("+");
	for (i = b + 1; i < d; ++i)
	{
		locate(a,i);
		out('!');
		locate(c,i);
		out('!');
	}
	locate(1,24);
}

center(s)	/* Zeichenkette zentriert ausgeben */
char *s;
{
	int i;

	i = 40 - (strlen(s) / 2);
	while (--i)
		out(' ');

	send(s);
	cr(1);
}


cls()
{
	send("\033E");
}


boxtext(x,y,s)
int x,y;
char *s;
{
	int i;
	i = strlen(s) / 2 + 3;
	box(x - i,y - 2,x + i,y + 2);
	locate(x - i + 3,y);
	send(s);
}
