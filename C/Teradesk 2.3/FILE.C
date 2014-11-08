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
#include <stdlib.h>
#include <string.h>
#include <ctype.h>			/* HR 271102: for wildcards */
#include <tos.h>
#include <mint.h>
#include <ctype.h>

#include "desk.h"
#include "desktop.h"			/* HR 151102: only 1 rsc */
#include "error.h"
#include "xfilesys.h"
#include "file.h"
#include "prgtype.h"

#if _MINT_
#define CFG_EXT		"*.cfg"
#else
#define CFG_EXT		"*.CFG"
#endif

/* Geef een pointer terug die wijst naar het begin van de filenaam
   in een padnaam. */

char *fn_get_name(const char *path)
{
	char *h;

	if ((h = strrchr(path, '\\')) == NULL)
		return (char *) path;

	else
		return h + 1;
}

/* Geef een pointer terug op een met malloc gereserveerd stuk
   geheugen, waarin het pad van de padnaam van een file wordt
   gezet. */

char *fn_get_path(const char *path)
{
	char *backsl;
	long l;

	if ((backsl = strrchr(path, '\\')) == NULL)
		backsl = (char *) path;

	if (((l = backsl - (char *) path) == 2) && (path[1] == ':'))
		l++;

	if ((backsl = malloc(l + 1)) == NULL)
	{
		xform_error(ENSMEM);
		return NULL;
	}

	strsncpy(backsl, path, l + 1);		/* HR 120203: secure cpy */

	return backsl;
}

char *fn_make_path(const char *path, const char *name)
{
	int error;
	char *result;

	if ((result = x_makepath(path, name, &error)) == NULL)
		xform_error(error);
	return result;
}

/* Geef een pointer terug op een met malloc gereserveerd stuk
   geheugen, waarin het path van oldname is samengevoegd met
   newnameen. */

char *fn_make_newname(const char *oldname, const char *newname)
{
	char *backsl, *path, *h;
	long l, tl, ml;
	int error = 0;

	if ((backsl = strrchr(oldname, '\\')) == NULL)
		backsl = (char *) oldname;

	l = backsl - (char *) oldname;

	tl = l + strlen(newname) + 2L;

	if ((path = malloc(tl)) != NULL)
	{
		strncpy(path, oldname, l);
		h = &path[l];
		*h++ = '\\';
		*h = 0;

		if ((ml = x_pathconf(path, DP_NAMEMAX)) < 0)
			ml = 256;

		if (strlen(newname) > ml)
			error = EFNTL;
		else
		{
			if ((ml = x_pathconf(path, DP_PATHMAX)) < 0)
				ml = 0x7FFFFFFFL;

			if ((tl - 1) > ml)
				error = EPTHTL;
			else
				strcpy(h, newname);
		}
		if (error != 0)
		{
			free(path);
			path = NULL;
		}
	}
	else
		error = ENSMEM;

	if (error != 0)
		xform_error(error);

	return path;
}

static void split_name(char *name, char *ext, const char *fname)
{
	char *s, *d, *e;

	if ((e = strrchr(fname, '\\')) == NULL)
		e = (char *) fname;

	if ((e = strchr(e, '.')) == NULL)
	{
		strcpy(name, fname);
		*ext = 0;
	}
	else
	{
		s = (char *) fname;
		d = name;

		while (s != e)
			*d++ = *s++;
		*d = 0;

		strcpy(ext, e + 1);
	}
}

boolean isroot(const char *path)
{
	long l = strlen(path);

	if (path[l - 1] == '\\')
		l--;
	if (path[l - 1] == ':')
		return TRUE;
	return FALSE;
}

char *locate(const char *name, int type)
{
	char fname[256], *newpath, *newname, *fspec, *title;
	boolean result = FALSE;
	int ex_flags;

	if (type == L_FOLDER)
	{
		if ((fspec = fn_make_path(name, "*")) == NULL)		/* HR 271102 */
			return NULL;
		fname[0] = 0;
		ex_flags = EX_DIR;
	}
	else
	{
		if (   (fspec = fn_make_newname(
		                        name, 
		                        (  (type == L_LOADCFG) || (type == L_SAVECFG) )
		                          ? CFG_EXT
		                          : "*"					/* HR 271102 */
		                               )
		       ) == NULL
		   )
			return NULL;
		strcpy(fname, fn_get_name(name));
		ex_flags = EX_FILE;
	}

	rsrc_gaddr(R_STRING, FSTLFILE + type, &title);

	do
	{
		newpath = xfileselector(fspec, fname, title);

		free(fspec);

		if (newpath == NULL)
			return NULL;

		if (type == L_FOLDER)
		{
			if (((newname = fn_get_path(newpath)) != NULL) && (isroot(newname) == TRUE))
			{
				alert_printf(1, MNOROOT);
				free(newname);
			}
			else
				result = TRUE;
		}
		else
		{
			if ((type == L_PROGRAM) && (prg_isprogram(fname) == FALSE))
				alert_printf(1, MFNPRG, fname);
			else
			{
				if (((newname = fn_make_newname(newpath, fname)) != NULL) && (type != L_SAVECFG))
				{
					result = x_exist(newname, ex_flags);
					if (result == FALSE)
					{
						alert_printf(1, MFNEXIST, fname);
						free(newname);
					}
				}
				else
					result = TRUE;
			}
		}
		fspec = newpath;
	}
	while (result == FALSE);

	free(newpath);

	return newname;
}

void getroot(char *root)
{
	root[0] = x_getdrv() + 'A';
	root[1] = ':';
	root[2] = 0;
}

char *getdir(int *error)
{
	return x_getpath(0, error);
}

int chdir(const char *path)
{
	int error;
	char *h;

	h = (char *) path;
	if (*path && (path[1] == ':'))
	{
		x_setdrv((path[0] & 0xDF) - 'A');
		h = (char *) path + 2;
		if (*h == 0)
			h = "\\";
	}
	error = x_setpath(h);

	return error;
}

long drvmap(void)
{
	return (x_setdrv(x_getdrv()));
}

boolean check_drive(int drv)
{
	if ((drv >= 0) && (drv < 26) && (btst(drvmap(), drv)))
		return TRUE;

	alert_printf(1, MDRVEXIS);

	return FALSE;
}

#if _MINT_

bool match_pattern(const char *t, const char *pat)
{
	bool valid = true;
	
	while(    valid
	      and (   ( *t and *pat)
	           or (!*t and *pat == '*')	/* HR: catch empty that should be OK */
	         )
	      )
	{
		switch(*pat)
		{
		case '?':			/* Any character */
			t++;
			pat++;
			break;
		case '*':			/* String of any character */
			pat++;
			while(*t and (toupper(*t) != toupper(*pat)))
				t++;
			break;
		case '!':			/* !X means any character but X */
			if (toupper(*t) != toupper(pat[1]))
			{
				t++;
				pat += 2;
			} else
				valid = false;
			break;
		case '[':			/* [<chars>] means any one of <chars> */
			while((*(++pat) != ']') and (toupper(*t) != toupper(*pat)));
			if (*pat == ']')
				valid = false;
			else
				while(*++pat != ']');
			pat++;
			t++;			/* HR: yeah, this one was missing */
			break;
		default:
			if (toupper(*t++) != toupper(*pat++))
				valid = false;
			break;
		}
	}
	
	return valid and toupper(*t) == toupper(*pat);
}

#else

boolean cmp_part(const char *name, const char *wildcard)
{
	int i = -1, j = -1;

	do
	{
		j++;
		i++;
		switch (wildcard[i])
		{
		case '?':
			if (name[j] == 0)
				return FALSE;
			break;
		case '*':
			if (wildcard[i + 1] == 0)
				return TRUE;
			else
			{
				i++;
				while (name[j] != 0)
				{
					if (cmp_part(name + j, wildcard + i) == TRUE)
						return TRUE;
					j++;
				}
				return FALSE;
			}
		default:
			if (tolower(name[j]) != tolower(wildcard[i]))		/* HR 271102: case insensitive */
				return FALSE;
			break;
		}
	}
	while (wildcard[i] != 0);
	return TRUE;
}
#endif

boolean cmp_wildcard(const char *fname, const char *wildcard)
{
#if _MINT_		/* HR 151102 */
        return match_pattern(fname,wildcard);		/* HR 051202: courtesy XaAES */
#else
	{
		char name[10], ext[4], wname[10], wext[4];
	
		split_name(name, ext, fname);
		split_name(wname, wext, wildcard);
		if (cmp_part(name, wname) == FALSE)
			return FALSE;
		return cmp_part(ext, wext);
	}
#endif
}

typedef long cdecl (*Func)();

static int chdrv;
static long cdecl (*Oldgetbpb) (int);
static long cdecl (*Oldmediach) (int);
static long cdecl (*Oldrwabs) (int, void *, int, int, int, long);

static long cdecl Newgetbpb(int d)
{
	if (d == chdrv)
	{
		*((Func *)0x472L) = Oldgetbpb;
		*((Func *)0x476L) = Oldrwabs;
		*((Func *)0x47eL) = Oldmediach;
	}

	return (*Oldgetbpb)(d);
}

static long cdecl Newmediach(int d)
{
	if (d == chdrv)
		return 2;
	else
		return (*Oldmediach)(d);
}

static long cdecl Newrwabs(int d, void *buf, int a, int b, int c, long l)
{
	if (d == chdrv)
		return MEDIA_CHANGE;
	else
		return (*Oldrwabs)(d, buf, a, b, c, l);
}

void force_mediach(const char *path)
{
	int drive, p = *path;

	if (   p == 0
	    || !(isalnum(p) && path[1] == ':')		/* HR 271102: alnum */
	   )
		return;

	drive =   isalpha(p)
	        ? tolower(p) - 'a'			/* HR 271102 */
	        : p - '0' + 'z' - 'a'  + 2;

#if _MINT_			/* HR 151102 */
	if (mint)
	{
		if (Dlock(1, drive) == 0)
			Dlock(0, drive);
	}
	else
#endif
	{
		void *stack;
		static char fname[] = "X:\\X";
		long r;

		stack = (void *)Super(0L);

		chdrv = drive;
		Oldrwabs = *((Func *)0x476L);
		Oldgetbpb = *((Func *)0x472L);
		Oldmediach = *((Func *)0x47eL);

		*((Func *)0x476L) = Newrwabs;
		*((Func *)0x472L) = Newgetbpb;
		*((Func *)0x47eL) = Newmediach;

		fname[0] = drive + 'A';
		r = Fopen(fname, 0);
		if (r >= 0)
			Fclose((int)r);

		if (*((Func *)0x476L) == Newrwabs)
		{
			*((Func *)0x472L) = Oldgetbpb;
			*((Func *)0x476L) = Oldrwabs;
			*((Func *)0x47eL) = Oldmediach;
		}

		Super(stack);
	}
}
