/* ----------------- ST FORMAT PINBALL PROGRAM ------- ------------------------

	Title:		PINBALL

	Module:		errexit.c

	Version:	1.1

	Author:		Warwick Grigg

	Copyright (c) Warwick Grigg 1990. All rights reserved.

----------------------------------------------------------------------------- */

#include <gemfast.h>
#include <stdio.h>

void errexit(s)
char *s;
{
	if (*s = '[')
		form_alert(1, s);
	else
		fprintf(stderr, s);
	exit(1);
}
