/* PROGRAMM	df
** VERSION	1.0
** DATUM	29. November 1987
** AUTOR	Uwe Sauerland
** ZWECK	shows free and covered space in the selected path
**
*/

#include <stdio.h>
#include <tos.h>
#include <ext.h>
#include <string.h>
#include <stdlib.h>
#include <ctype.h>

#define FALSE 0
#define TRUE  1

#define MAXPATH		81	/* path */
#define	MAXDRIVE	3	/* drive; includes colon (:) */
#define	MAXDIR		66	/* dir; includes leading and trailing backslashes (\) */
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

#define noparcur(de)	(de.ff_name[0] != '.')
	/* (neither parent nor current directory index */

int	quiet = FALSE, recursive = FALSE;

int	drive;

DSPACE dfr;
#define clusize(dfr)	(dfr.bps * dfr.pspal)

unsigned long total_size = 0L, total_clusters = 0L;

typedef struct pathnode
{
	char pathname[81];
	struct pathnode *next;
} PATHNODE;

typedef PATHNODE *PATHPTR;

void expand(char *pathname, char *exppath)
{
	char drv[MAXDRIVE], dir[MAXDIR], file[MAXFILE], ext[MAXEXT];
	int present;
	struct ffblk matchinfo;
	DTA *olddta;

	strcpy(exppath, pathname);
	if (! strlen(exppath))
		strcpy(exppath, "*.*");
	present = fnsplit(exppath, drv, dir, file, ext);
	if (present & DRIVE)
		drive = (int) (toupper(drv[0]) - 'A' + 1);
	else
		drive = 0;
	if (! (present & (FILENAME | EXTENSION)))
	{
		strcat(exppath, "*.*");
		present |= WILDCARDS;
	}
	if (! (present & WILDCARDS))
	{
		olddta = Fgetdta();
		if (findfirst(exppath, &matchinfo, FA_SYSTEM | FA_HIDDEN | FA_DIREC))
			strcpy(exppath, "");
		else if (matchinfo.ff_attrib & FA_DIREC)
			strcat(exppath, "\\*.*");
		Fsetdta(olddta);
	}
}		

void get_entries
(
	char *pathname,
	unsigned long *all_size,
	unsigned long *clusters)
{
	struct ffblk direntry;
	int attributes = FA_RDONLY | FA_DIREC | FA_ARCH | FA_LABEL | FA_HIDDEN | FA_SYSTEM;
	DTA *olddta;

	olddta = Fgetdta();
	if (! findfirst(pathname, &direntry, attributes))
	{
		*all_size += direntry.ff_fsize;
		*clusters += (long unsigned) direntry.ff_fsize / clusize(dfr);
		if ((long unsigned) direntry.ff_fsize % clusize(dfr))
			++(*clusters);
		while (! findnext(&direntry))
		{
			*all_size += direntry.ff_fsize;
			*clusters += (long unsigned) direntry.ff_fsize / clusize(dfr);
			if ((long unsigned) direntry.ff_fsize % clusize(dfr))
				++(*clusters);
		}
	}
	Fsetdta(olddta);
}

void df_recursive(char *mypath)
{
	struct ffblk direntry;
	int attributes = FA_RDONLY | FA_DIREC | FA_ARCH | FA_HIDDEN | FA_SYSTEM;
	DTA *olddta;
	PATHPTR root = NULL, newpath = NULL;
	char pathroot[81], exppath[81];
	void df(char *pathname);

	expand(mypath, exppath);	
	strcpy(pathroot, mypath);
	if (pathroot[strlen(pathroot) - 1] != '\\')
		/* der Normalfall */
		strcat(pathroot, "\\");

	olddta = Fgetdta();
	if (! findfirst(exppath, &direntry, attributes))
	{
		if ((direntry.ff_attrib & FA_DIREC) && noparcur(direntry))
		{
			newpath = root = (PATHPTR) malloc(sizeof(PATHNODE));
			strcpy(newpath->pathname, pathroot);
			strcat(newpath->pathname, direntry.ff_name);
			newpath->next = NULL;
		}
		while (! findnext(&direntry))
		{
			if ((direntry.ff_attrib & FA_DIREC) && noparcur(direntry))
			{
				if (root == NULL)
					newpath = root = (PATHPTR) malloc(sizeof(PATHNODE));
				else
				{
					newpath->next = (PATHPTR) malloc(sizeof(PATHNODE));
					newpath = newpath->next;
				}
				strcpy(newpath->pathname, pathroot);
				strcat(newpath->pathname, direntry.ff_name);
				newpath->next = NULL;
			}
		}
		newpath = root;
		while (newpath != NULL)
		{
			df(newpath->pathname);
			root = newpath;
			newpath = newpath->next;
			free(root);
		}
	}
	Fsetdta(olddta);
}

void df(char *pathname)
{
	char exppath[81], mypath[81];
	unsigned long all_size = 0L, clusters = 0L;
	int column;

	strcpy(mypath, pathname);
	strupr(mypath);
	expand(mypath, exppath);
	if (strlen(exppath))
	{
		get_entries(exppath, &all_size, &clusters);
		total_size += all_size;
		total_clusters += clusters;
		if (! quiet)
			printf("disk usage of %s:\n%lu Byte%s in %lu cluster%s (%lu Bytes)\n\n",
				exppath, all_size, all_size == 1 ? "" : "s",
				clusters, clusters == 1 ? "" : "s",
				clusters * clusize(dfr));
		if (recursive)
			df_recursive(mypath);
	}
}

void main(int argc, char *argv[])
{
	int i;
	unsigned long dskfree;
	char pathname[81], dummy[81];

	Dgetpath(pathname, 0);
	for (i = 1; i < argc; i++)
	{
		if (*argv[i] == '-')
		{
			if (strchr(argv[i], '?') != NULL)
			{
				fprintf(stderr, "usage: df -qr [ <path> ]\n");
				fprintf(stderr, "\tq\tquiet recursive scan\n");
				fprintf(stderr, "\tr\tinformative recursive scan\n");
				exit(0);
			}
			if (strchr(argv[i], 'q') != NULL)
				quiet = recursive = TRUE;
			if (strchr(argv[i], 'r') != NULL)
				recursive = TRUE;
		}
		else
			strcpy(pathname, argv[i]);
	}
	expand(pathname, dummy);	/* to get drivenumber */
	Dfree(&dfr, drive);
	df(pathname);
	dskfree = (long) dfr.freal * clusize(dfr);
	if (recursive)
	{
		printf("in total %lu byte%s in %lu cluster%s (%lu bytes) are used.\n",
			total_size, total_size == 1 ? "" : "s",
			total_clusters, total_clusters == 1 ? "" : "s",
			total_clusters * clusize(dfr));
	}
	printf("%lu bytes in %lu cluster%s are available on this disk.\n\n",
		dskfree, dfr.freal, dfr.freal == 1L ? "" : "s");
}
