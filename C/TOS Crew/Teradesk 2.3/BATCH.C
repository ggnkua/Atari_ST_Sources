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
#include <string.h>
#include <stdlib.h>
#include <mint.h>

#include "desk.h"
#include "desktop.h"			/* HR 151102: only 1 rsc */
#include "error.h"
#include "xfilesys.h"
#include "batch.h"
#include "file.h"

extern char *optname;

static boolean eos(char c)
{
	if ((c != ' ') && (c != '\t') && (c != 0))
		return FALSE;
	else
		return TRUE;
}

static char *skipspace(char *p)
{
	char *i = p;

	while ((*i == ' ') || (*i == '\t'))
		i++;

	return i;
}

static char *skipchar(char *p)
{
	char *i = p;

	while (eos(*i) == FALSE)
		i++;

	return i;
}

static char *getint(char *p, int *result)
{
	char *i = p;
	int r = 0;

	while ((*i >= '0') && (*i <= '9'))
		r = r * 10 + (int) (*i++ - '0');

	*result = r;

	return (i == p) ? NULL : i;
}

void exec_bat(char *name)
{
	char line[256], *p, *s, *com, *tail;
	char *olddir;
	XFILE *bf;
	int x, y, cnt = 0, error;
	COMMAND comline;

	if ((olddir = getdir(&error)) != NULL)
	{
		if ((bf = x_fopen(name, O_DENYW | O_RDONLY, &error)) != NULL)
		{
			while ((error = x_fgets(bf, line, 256)) == 0)
			{
				cnt++;

				p = skipspace(line);

				switch (*p)
				{
				case 0:
				case '*':
					break;
				case '#':
					p = skipspace(p + 1);
					if ((p = getint(p, &x)) == NULL)
					{
						alert_printf(1, MBSYNTAX, cnt);
						break;
					}
					p = skipspace(p);
					if (*p != ',')
					{
						alert_printf(1, MBSYNTAX, cnt);
						break;
					}
					p = skipspace(p + 1);
					if ((p = getint(p, &y)) == NULL)
					{
						alert_printf(1, MBSYNTAX, cnt);
						break;
					}
					p = skipspace(p);

					if ((x == max_w) && (y == max_h))
					{
						long l = 0;

						while (eos(p[l]) == FALSE)
							l++;

						if (l > 0)
						{
							if ((s = malloc(l + 1)) != NULL)
							{
								free(optname);
								optname = s;
								strsncpy(s, p, l + 1);		/* HR 120203: secure cpy */
								p += l;
							}
							else
								xform_error(ENSMEM);
						}
					}
					break;
				default:
					com = p;
					p = skipchar(p);
					if (*p != 0)
					{
						*p++ = 0;
						p = skipspace(p);
						tail = p;
					}
					else
						tail = "";

					if (strcmp(com, "cd") != 0)
					{
#if _MINT_
						boolean bg;
						if (mint)				/* HR 151102 */
						{
							int i;
	
							i = (int) strlen(tail) - 1;
							while (((tail[i] == ' ') || (tail[i] == '\t')) && (i > 0))
								i--;
							if (tail[i] == '&')
							{
								bg = TRUE;
								tail[i] = 0;
							}
							else
								bg = FALSE;
						}
#endif
						strcpy(comline.command_tail, tail);
						comline.length = (unsigned char) strlen(tail);
#if _MINT_
						if (mint)				/* HR 151102 */
							error = (int) x_exec((bg == FALSE) ? 0 : 100, com, &comline, NULL);
						else
#endif
							error = (int) x_exec(0, com, &comline, NULL);
					}
					else
						error = chdir(tail);

					if (error != 0)
						hndl_error(MEBATCH, error);
					break;
				}
			}
			x_fclose(bf);
		}

		chdir(olddir);
		free(olddir);
	}

	if ((error != 0) && (error != EEOF) && (error != EFILNF))
		hndl_error(MEBATCH, error);
}
