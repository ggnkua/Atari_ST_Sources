/* PROGRAMM	move a file
 * VERSION	2.0
 * DATUM	9. Dezember 1987
 * AUTOR	Uwe Sauerland
 * ZWECK	moves a file from one directory to another.
 *		The program uses Turbo C's rename function to move files.
 *
 */

#include <ext.h>
#include <errno.h>
#include <stdio.h>
#include <string.h>
#include <ctype.h>
#include <tos.h>
#include <stdlib.h>

#define FALSE	0
#define TRUE	1

const char *credit = "Copyright (C) by Uwe Sauerland, Berlin 1987";

#define unlink(p)	remove(p)

#define MAXPATH		80	/* path */
#define	MAXDRIVE	3	/* drive; includes colon (:) */
#define	MAXDIR		66	/* dir; includes leading and trailing
				   backslashes (\) */
#define	MAXFILE		9	/* name */
#define	MAXEXT		5	/* extension; includes leading dot (.) */

#define	WILDCARDS	0x01
#define	EXTENSION	0x02
#define	FILENAME	0x04
#define	DIRECTORY	0x08
#define	DRIVE		0x10

int fnsplit(char *path, char *drive, char *dir, char *name, char *ext)
{
	int	i, result = 0, readext = FALSE;

	drive[0] = dir[0] = 0;
	for (i = 0; i < MAXFILE; name[i++] = 0);
	for (i = 0; i < MAXEXT; ext[i++] = 0);

	if (strchr(path, '*') != NULL || strchr(path, '?') != NULL)
		result = WILDCARDS;

	if (path[1] == ':')
	{
		strncpy(drive, path, 2);
		drive[2] = 0;
		++path; ++path;
	}

	while (*path)
	{
		if (*path == '\\')
		{
			readext = FALSE;
			strcat(dir, name);
			strcat(dir, ext);
			strcat(dir, "\\");
			for (i = 0; i < MAXFILE; name[i++] = 0);
			for (i = 0; i < MAXEXT; ext[i++] = 0);
			++path;
		}
		else if (readext)
			strncat(ext, path++, 1);
		else if (*path == '.')
			readext = TRUE;
		else
			strncat(name, path++, 1);
	}
	if (strlen(drive))
		result |= DRIVE;
	if (strlen(dir))
		result |= DIRECTORY;
	if (strlen(name))
		result |= FILENAME;
	if (strlen(ext))
		result |= EXTENSION;
	if (strlen(drive))
		result |= DRIVE;
	return result;
}

int xfat, repl = TRUE;

static int isdir(char *pattern)
{
	int notfound;
	DTA *dta;
	struct ffblk finfo;
	char drv[MAXDRIVE], dir[MAXDIR], name[MAXFILE], ext[MAXEXT];

	fnsplit(pattern, drv, dir, name, ext);
	if (strcmp(dir, "\\") == 0)
		return TRUE;
	else
	{
		dta = Fgetdta();
		notfound = findfirst(pattern, &finfo, FA_DIREC);
		Fsetdta(dta);
		return notfound ? FALSE : finfo.ff_attrib & FA_DIREC;
	}
}

static char *getfname(char *pattern)
{
	static struct ffblk finfo;
	static int notfound = 1;
	DTA *dta;

	dta = Fgetdta();
	Fsetdta((DTA *) &finfo);
	if (notfound)
		notfound = findfirst(pattern, &finfo, 0);
	else
		notfound = findnext(&finfo);
	Fsetdta(dta);
	return notfound ? NULL : finfo.ff_name;
}

static void move(char *source, char *dest)
{
	int i, sinfo, dinfo;
	DTA *dta;
	struct ffblk ffb;
	char destpath[MAXPATH];
	char drv[MAXDRIVE], dir[MAXDIR];	/* dummies */
	char sname[MAXFILE], sext[MAXEXT];	/* source components */
	char dname[MAXFILE], dext[MAXEXT];	/* dest components */
	char syscmd[MAXPATH+MAXPATH+5];		/* command buffer for trans-fat move */

	strupr(source);
	strupr(dest);

	sinfo = fnsplit(source, drv, dir, sname, sext);
	dinfo = fnsplit(dest, drv, dir, dname, dext);
	if ((sinfo & DRIVE) && (dinfo & DRIVE))
		xfat = toupper(source[0]) != toupper(dest[0]);
	else if ((sinfo & DRIVE) || (dinfo & DRIVE))
		xfat = Dgetdrv() != (toupper((sinfo & DRIVE) ? source[0] : dest[0]) - 'A' + 1);
	else
		xfat = FALSE;

	strcpy(destpath, dest);
	if (dinfo & WILDCARDS)
	{
		strcpy(destpath, drv);
		strcat(destpath, dir);
		if (! strcmp(dname, "*"))
			strcpy(dname, "????????");
		if (! strcmp(dext, ".*"))
			strcpy(dext, ".???");
		for (i = 0; i < strlen(dname); ++i)
			if (dname[i] == '?')
				if (i < strlen(sname))
					dname[i] = sname[i];
				else
					dname[i] = '\0';
		for (i = 0; i < strlen(dext); ++i)
			if (dext[i] == '?')
				if (i < strlen(sname))
					dext[i] = sext[i];
				else
					dext[i] = '\0';
		strcat(destpath, dname);
		strcat(destpath, dext);
	}
	else if ((strlen(destpath) == 0) || isdir(destpath))
	{
		if (strlen(destpath) && destpath[strlen(destpath) - 1] != '\\')
			strcat(destpath, "\\");
		strcat(destpath, sname);
		strcat(destpath, sext);
	}

	dta = Fgetdta();
	if (! findfirst(destpath, &ffb, FA_HIDDEN | FA_SYSTEM | FA_RDONLY))
	{	/* destination file already exists! */
		sinfo = Fattrib(source, 0, 0);
		Fattrib(source, 1, sinfo | FA_RDONLY);
		dinfo = Fattrib(destpath, 0, 0);
		if (dinfo & FA_RDONLY)
		{
			fprintf(stderr, "%s not moved onto itself or %s readonly\n", source, destpath);
			Fattrib(source, 1, sinfo);
			Fsetdta(dta);
			return;
		}
		Fattrib(source, 1, sinfo);
		if (repl)
			unlink(destpath);
		else
		{
			fprintf(stderr, "%s not moved to %s!\n", source, destpath, destpath);
			fprintf(stderr, "use without option -r to replace existing files!\n");
			Fsetdta(dta);
			return;
		}
	}
	Fsetdta(dta);

	if (xfat)
	{
		printf("XFAT %s --> %s", source, destpath);
		strcpy(syscmd, "COPY ");
		strcat(syscmd, source);
		strcat(syscmd, " ");
		strcat(syscmd, destpath);
		system(syscmd);
		unlink(source);
	}
	else
		rename(source, destpath);
}

static void help(void)
{
	fprintf(stderr, "usage: mv -r <source-path> [ <dest-path> ]\n");
	fprintf(stderr, "\tr\tdon't replace existing files\n");
	exit(0);
}

void main(int argc, char *argv[])
{
	int i = 1;
	char sourcearg[MAXPATH], source[MAXPATH], *fname;
	char drv[MAXDRIVE], dir[MAXDIR], name[MAXFILE], ext[MAXEXT];

	if (argc < 2)
		help();
	else if (*argv[1] == '-')
	{
		++i;
		if (strchr(argv[1], '?') != NULL || argc < 3)
			help();
		else
		{
			if (strchr(argv[1], 'r') != NULL)
				repl = FALSE;
		}
	}
	strcpy(sourcearg, argv[i]);
	/* if a directory path is given only, *.* must be appended */
	if /* it is a directory... */
	(
		/* no directory, if wildcards are given */
		! (fnsplit(sourcearg, drv, dir, name, ext) & WILDCARDS) &&
		/* directory, if the directory bit is set */
		isdir(sourcearg)
	)
		/* ... append the global wildcard */
		strcat(sourcearg, (sourcearg[strlen(sourcearg) - 1]) == '\\' ? "*.*" : "\\*.*");
	if (! (fnsplit(sourcearg, drv, dir, name, ext) & WILDCARDS))
		/* no wildcards yet? just move it... */
		move(sourcearg, (argc > i + 1) ? argv[i + 1] : "");
	else /* select for any fitting source file */
	{
		while ((fname = getfname(sourcearg)) != NULL)
		{
			fnsplit(sourcearg, drv, dir, name, ext);
			strcpy(source, drv); strcat(source, dir);
			strcat(source, fname);
			move(source, (argc > i + 1) ? argv[i + 1] : "");
		}
	}
}
