/*
 * nnisok.c -- do sanity check on a nodename
 *
 * 90Aug27 AA	Split off from libnet.c
 */

#include <ctype.h>

char *strchr();

int
NNisok(node)
register char *node;
{
    while (*node)
	if (isalnum(*node) || strchr("* _-.", *node))
	    ++node;
	else
	    return 0;
    return 1;
}
