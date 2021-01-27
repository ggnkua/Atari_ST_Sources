/* Copyright (c) 2017 - present by Gerhard Stoll Worms, Germany
 *
 * This file is part of AHCC.
 *
 * AHCC is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * AHCC is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with AHCC; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

/* 	SCRAP.C
 *	========
 */


#include <string.h>
#include <np_aes.h>
#include <tos.h>
#include "scrap.h"

char scrap_dir[2*SCRS] = "";		/* ample room ?? */
bool have_scrap = false;

/* > Fcreate doesnt always work with closing slash. HR: stupid boy. */
void create_scrap(void)
{
	char n[SCRS];
	char *e;

	strcpy(n, scrap_dir);
	e = n+strlen(n)-1;

	if (*e eq '\\')
		*e = 0;

	Dcreate(n);
}


void mk_scrap_name(char *to)
{
	strcpy(to, scrap_dir );
	strcat(to, scrap_name);
}

bool get_scrapdir(void)
{
	char *d = scrap_dir;
	if (!*d)
	{
		scrp_read(scrap_dir);
		if (*d)
		{
			char *de;
			size_t l = strlen(d);
			if (l > SCRS-1)
				return 0;		/* probably too late, blame the AES. */
			de = d + l - 1;
			if (*de ne '\\')
			{
				*de++ = '\\';
				*de   = 0;
			}
		}
	}
	return scrap_dir[0] ne '\0';
}

void scrap_clear(void)
{
	char	path[SCRS];
	DTA		dta, *old_dta;
	short	ok;

	if (get_scrapdir())
	{
		mk_scrap_name(path);
		old_dta = (DTA *)Fgetdta ();
		Fsetdta(&dta);

		ok = (Fsfirst (path, 0) == 0);
		while (ok)
		{
			strcpy(path, scrap_dir);
			strcat(path, dta.d_fname);
			Fdelete(path);
			ok = (Fsnext () == 0);
		}
		Fsetdta(old_dta);
	}
}

char scrap_name[] = "scrap.txt";

char *scrap_rtxt(char *buf, long *len, long maxlen)
{
	char	path[SCRS];
	short	datei;

	if (get_scrapdir())
	{
		mk_scrap_name(path);
		if ((datei = (int)Fopen(path, 0)) >= 0)
		{
			*len = Fread(datei, maxlen, buf);
			Fclose(datei);
			buf[*len] = '\0';
			return buf;
		}
	}
	return NULL;
}

void scrap_wtxt(char *buf)
{
	char	path[SCRS];
	short	datei;

  	if (get_scrapdir())
  	{
		scrap_clear();
		mk_scrap_name(path);

/* HR: Fails if a directory is present in path that has to be created. */
	 	if ((datei = (int)Fcreate(path, 0)) >= 0)
	 	{
			Fwrite(datei, strlen(buf), buf);
			Fclose(datei);
	 	}
  	}
}
