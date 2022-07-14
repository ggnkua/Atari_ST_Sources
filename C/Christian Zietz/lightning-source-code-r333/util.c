/*
 * Modified for the FreeMiNT USB subsystem by David Galvez. 2010 - 2011
 *
 * XaAES - XaAES Ain't the AES (c) 1992 - 1998 C.Graham
 *                                 1999 - 2003 H.Robbers
 *                                        2004 F.Naumann & O.Skancke
 *
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with XaAES; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 */

#ifndef TOSONLY
#include "util.h"

int
get_drv(const char *p)
{
	if (*(p + 1) == ':')
	{
		int c = *p;
		if (c >= 'a' && c <= 'z')
			return c - 'a';
		if (c >= 'A' && c <= 'Z')
			return c - 'A';
		if (c >= '0' && c <= '9')
			return (c - '0') + ('z' - ('a' - 1));
	}
	return -1;
}

void
fix_path(char *path)
{
	char c;

	if (!path)
		return;

	while ((c = *path))
	{
		if (c == '\\')
			*path = '/';
		path++;
	}
}

void
strip_fname(const char *path, char *newpath, char *fname)
{
	const char *s, *d = NULL;
	char c;

	s = path;
	c = *s;

	while (c)
	{
		if (c == '/' || c == '\\')
		{
			d = s + 1;
//			if (c == '\\')
//				*s = '/';
		}
		c = *++s;
	}
	if (d && d != s)
	{
		int slen = d - path;

		if (fname)
			strcpy(fname, d);
		if (newpath)
		{
			if (newpath != path)
				strncpy(newpath, path, slen);
			newpath[slen] = '\0';
		}
	}
}

int
drive_and_path(char *fname, char *path, char *name, bool n, bool set)
{
	int t; char *tn = fname;
	int drive = get_drv(fname);

	if (drive >= 0)
		tn += 2;

	strcpy(path, tn);

	if (n)
	{
		/* Seperate path & name */
		t = strlen(path)-1;
		while (t >= 0 && path[t] != '\\')
			t--;

		if (path[t] == '\\')
		{
			path[t] = '\0';
			if (name)
				strcpy(name, path + t + 1);
		}
		else
			if (name)
				strcpy(name, path);
	}

	if (set)
	{
		if (drive >= 0)
			d_setdrv(drive);

		d_setpath(path);
	}

	return drive;
}

void
set_drive_and_path(char *fname)
{
	char buf[256];
	int t; char *tn;
	int drive;

	strcpy(buf, fname);
	tn = buf;
	drive = get_drv(tn);

	if (drive >= 0)
		tn += 2;

	/* Seperate path & name */
	t = strlen(tn) - 1;
	while (t >= 0 && tn[t] != '\\')
		t--;

	if (tn[t] == '\\')
	{
		tn[t] = '\0';
	}
	if (!*tn)
	{
		tn[0] = '\\';
		tn[1] = '\0';
	}
	DEBUG(("set_drive_and_path %d '%s'", drive, tn));
	if (drive >= 0)
		d_setdrv(drive);

	d_setpath(tn);
}

void
get_drive_and_path(char *path, short plen)
{
	int drv;

	drv = d_getdrv();
	path[0] = (char)drv + 'a';
	path[1] = ':';
	d_getpath(path + 2, 0);
	drv = strlen(path);
	if (path[drv - 1] != '\\' && path[drv - 1] != '/')
	{
		path[drv++] = '\\';
		path[drv] = '\0';
	}
}

void
strnupr(char *s, int n)
{
	int f;

	for (f = 0; f < n; f++)
		s[f] = toupper(s[f]);
}
#endif
