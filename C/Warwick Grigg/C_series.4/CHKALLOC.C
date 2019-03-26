/* ----------------- ST FORMAT PINBALL PROGRAM ------- ------------------------

	Title:		PINBALL

	Module:		chkalloc.c

	Version:	1.1

	Author:		Warwick Grigg

	Copyright (c) Warwick Grigg 1990. All rights reserved.

----------------------------------------------------------------------------- */

#include "errexit.h"

extern char *calloc();

char *chkcalloc(nelem, elemsize)
int nelem;
int elemsize;
{
	char *temp;

	if (temp = calloc(nelem, elemsize))
		return temp;
	errexit("Sorry, there isn't enough memory\n");
}
