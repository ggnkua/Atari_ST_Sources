/*
 * Teradesk. Copyright (c) 1993, 1994, 2002 W. Klaren.
 *
 * This file is part of Teradesk.
 *
 * Teradesk is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * Teradesk is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with Teradesk; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#include <np_aes.h>			/* HR 151102: modern */
#include <ctype.h>
#include <stdlib.h>
#include <string.h>
#include <tos.h>
#include <boolean.h>

#include "environm.h"

/*
 * Description: determine the length of the environment, including
 * terminating zero's.
 *
 * Result: length of environment.
 */

long envlen(void)
{
	char *p = _BasPag->p_env;
	long l = 0;

	do
	{
		while (*p++)
			l++;
		l++;
	}
	while (*p);

	l++;

	return l;
}

static char *findvar(const char *var)
{
	char *p;
	long l;
	boolean found = FALSE;

	l = strlen(var);
	p = _BasPag->p_env;
	while ((*p) && (found == FALSE))
	{
		if ((p[l] == '=') && (strncmp(p, var, l) == 0))
			found = TRUE;
		else
			while (*p++);
	}
	return (found == FALSE) ? NULL : p;
}

char *getenv(const char *var)
{
	char *p;

	if ((p = findvar(var)) == NULL)
		return NULL;

	p = strchr(p, '=') + 1;
	if (*p == 0)
	{
		if (p[1] == 0)
			return p;
		if (strchr(p + 1, '=') == NULL)
			return p + 1;
	}
	return p;
}

void clr_argv(void)
{
	char *p;

	if ((p = findvar("ARGV")) != NULL)
		*p = 0;
}
