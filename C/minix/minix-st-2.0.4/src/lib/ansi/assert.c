/*
 * assert.c - diagnostics
 */
/* $Header: assert.c,v 1.3 90/04/03 15:01:58 eck Exp $ */

#include	<assert.h>
#include	<stdio.h>
#include	<stdlib.h>

void __bad_assertion(const char *mess) {

	fputs(mess, stderr);
	abort();
}
