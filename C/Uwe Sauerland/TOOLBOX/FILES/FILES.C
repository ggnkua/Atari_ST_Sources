/* PROGRAMM	find
** VERSION	1.2
** DATUM	27. Juni 1988
** AUTOR	Uwe Sauerland
** ZWECK	finds files to the specified match
**
*/

#include <stdio.h>
#include <ctype.h>
#include <ext.h>
#include <tos.h>
#include <string.h>
#include <stdlib.h>

#define TOS

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

#define cins(s,c)	(strchr(s, c) != NULL)
#define noparcur(de)	(de.ff_name[0] != '.')
	/* (neither parent nor current directory index */

int	verify = FALSE, display = 1, oldref = FALSE,
	nodir = TRUE, passwildcard = FALSE, bottomup = FALSE;

struct ffblk oldffb;

typedef struct pathnode
{
	char pathname[81];
	struct pathnode *next;
} PATHNODE;

typedef PATHNODE *PATHPTR;

#define fyear(x)	(((x) >> 9) & 0x7F)
#define fmonth(x)	((((x) & 0x01E0) >> 5) & 0xF)
#define fday(x)		((x) & 0x001F)
#define fhour(x)	(((x) >> 11) & 0x1F)
#define fminute(x)	((((x) & 0x07E0) >> 5) & 0x3F)
#define fsecond(x)	((((x) & 0x001F) << 1) & 0x1E)

int datcmp(struct ffblk ffb1, struct ffblk ffb2)
{
	if (fyear(ffb1.ff_fdate) - fyear(ffb2.ff_fdate))
		return fyear(ffb1.ff_fdate) - fyear(ffb2.ff_fdate);
	if (fmonth(ffb1.ff_fdate) - fmonth(ffb2.ff_fdate))
		return fmonth(ffb1.ff_fdate) - fmonth(ffb2.ff_fdate);
	if (fday(ffb1.ff_fdate) - fday(ffb2.ff_fdate))
		return fday(ffb1.ff_fdate) - fday(ffb2.ff_fdate);
	if (fhour(ffb1.ff_ftime) - fhour(ffb2.ff_ftime))
		return fhour(ffb1.ff_ftime) - fhour(ffb2.ff_ftime);
	if (fminute(ffb1.ff_ftime) - fminute(ffb2.ff_ftime))
		return fminute(ffb1.ff_ftime) - fminute(ffb2.ff_ftime);
	if (fsecond(ffb1.ff_ftime) - fsecond(ffb2.ff_ftime))
		return fsecond(ffb1.ff_ftime) - fsecond(ffb2.ff_ftime);

	return 0;
}

void found
(
	char *path,
	struct ffblk *direntry,
	char *command,
	DTA *olddta
)
{
	char fullcmd[241], mypath[81], *parm, *s;
	int i, ch, confirm = TRUE;

	strcpy(mypath, path);
	if (! passwildcard)
	{
		if (mypath[strlen(mypath) - 1] != '\\')
			strcat(mypath, "\\");
		strcat(mypath, direntry->ff_name);
	}

	if ((parm = strstr(command, "{}")) == NULL)
	{
		strcpy(fullcmd, command);
		strcat(fullcmd, " ");
		strcat(fullcmd, mypath);
	}
	else
	{
		for (i = 0, s = command; s != parm; fullcmd[i++] = *s++);
		fullcmd[i] = 0;
		strcat(fullcmd, mypath);
		parm += 2;
		strcat(fullcmd, parm);
	}

	if (! oldref || datcmp(oldffb, *direntry) < 0)
	{
		if (display)
			printf("%s\n", strlen(command) ? fullcmd : mypath);
		if (strlen(command))
		{
			if (verify)
			{
				if (! display)
					printf("%s\n", fullcmd);
				printf("execute (y/n)? ");
				do
				{
					ch = getch();
					ch = toupper(ch);
				} while (ch != 'Y' && ch != 'N' && ch != 3);
				if (ch == 3)
				{
					Fsetdta(olddta);
					exit(0);
				}
				confirm = ch == 'Y';
				putchar(ch); putchar('\n');
			}
			if (confirm)
				system(fullcmd);
		}
	}
}

void get_entries(char *pathname, char *path, char *command)
{
	struct ffblk direntry;
	int attributes = FA_RDONLY | FA_DIREC | FA_ARCH | FA_LABEL | FA_HIDDEN | FA_SYSTEM;
	DTA *olddta;

	olddta = Fgetdta();
	if (! findfirst(pathname, &direntry, attributes))
	{
		if (passwildcard)
			found(pathname, &direntry, command, olddta);
		else
		{
			if (! (direntry.ff_attrib & FA_DIREC) || (! nodir && noparcur(direntry)))
				found(path, &direntry, command, olddta);
			while (! findnext(&direntry))
				if (! (direntry.ff_attrib & FA_DIREC) || (! nodir && noparcur(direntry)))
					found(path, &direntry, command, olddta);
		}
	}
	Fsetdta(olddta);
}

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
	if (! (present & (FILENAME | EXTENSION)))
	{
		strcat(exppath, "*.*");
		present |= WILDCARDS;
	}
	if (! (present & WILDCARDS))
	{
		olddta = Fgetdta();
		findfirst(exppath, &matchinfo, FA_SYSTEM | FA_HIDDEN | FA_DIREC);
		if (matchinfo.ff_attrib & FA_DIREC)
			strcat(exppath, "\\*.*");
		Fsetdta(olddta);
	}
}

void find_recursive(char *mypath, char *file, char *command)
{
	void find(char *path, char *file, char *command);

	struct ffblk direntry;
	int attributes = FA_RDONLY | FA_DIREC | FA_ARCH | FA_HIDDEN | FA_SYSTEM;
	DTA *olddta;
	PATHPTR root = NULL, newpath = NULL;
	char pathroot[81], exppath[81];

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
			find(newpath->pathname, file, command);
			root = newpath;
			newpath = newpath->next;
			free(root);
		}
	}
	Fsetdta(olddta);
}

void find(char *path, char *file, char *command)
{
	char mypath[81], fullpath[161], exppath[161];

	strcpy(mypath, path);
	strcpy(fullpath, mypath);
	if (fullpath[strlen(fullpath) - 1] != '\\')
		strcat(fullpath, "\\");
	strcat(fullpath, file);
	expand(fullpath, exppath);

	if (strlen(exppath))
		if (bottomup)
		{
			find_recursive(mypath, file, command);
			get_entries(exppath, mypath, command);
		}
		else
		{
			get_entries(exppath, mypath, command);
			find_recursive(mypath, file, command);
		}
}

void main(int argc, char *argv[])
{
	int i, splitres;
	unsigned long dskfree;
	char path[81], command[81], oldfile[81], file[13];
	char drv[MAXDRIVE], dir[MAXDIR], fname[MAXFILE], ext[MAXEXT];

	strcpy(path, "");
	strcpy(command, "");
	strcpy(oldfile, "");
	strcpy(file, "");
	for (i = 1; i < argc; i++)
	{
		if (*argv[i] == '-')
		{
			if (strchr(argv[i], '?') != NULL)
			{
				fprintf(stderr, "usage: files [<path>] -name <file> -print -dir -wildc -newer <file> ...\n");
				fprintf(stderr, "\t\t-bu -ok -exec \"<cmd>\"\n");
				fprintf(stderr, "\tname <file>\tscan for <file>\n");
				fprintf(stderr, "\tprint\t\tdisplay matches\n");
				fprintf(stderr, "\tdir\t\treturn dirnames also\n");
				fprintf(stderr, "\twildc\t\tpass wildcards rather than files\n");
				fprintf(stderr, "\t\t\t(excludes and overrides dir and newer)\n");
				fprintf(stderr, "\tnewer <file>\tmatch files that are newer than <file> only\n");
				fprintf(stderr, "\tbu\t\tprocess files search bottom-up wise.\n");
				fprintf(stderr, "\tok\t\tconfirm before EXECuting\n");
				fprintf(stderr, "\texec \"<cmd>\"\texecute command for every match\n");
				exit(0);
			}
			else if (strcmp(argv[i], "-name") == 0)
			{
				if (++i < argc)
					strcpy(file, argv[i]);
			}
			else if (strcmp(argv[i], "-exec") == 0)
			{
				if (++i < argc)
					strcpy(command, argv[i]);
				--display;
			}
			else if (strcmp(argv[i], "-newer") == 0)
			{
				if (++i < argc)
					strcpy(oldfile, argv[i]);
				oldref = TRUE;
			}
			else if (strcmp(argv[i], "-bu") == 0)
				bottomup = TRUE;
			else if (strcmp(argv[i], "-ok") == 0)
				verify = TRUE;
			else if (strcmp(argv[i], "-print") == 0)
				++display;
			else if (strcmp(argv[i], "-dir") == 0)
				nodir = FALSE;
			else if (strcmp(argv[i], "-wildc") == 0)
				passwildcard = TRUE;
		}
		else
			strcpy(path, argv[i]);
	}

	if (passwildcard)
	{	/* nur zur Sicherheit... */
		nodir = TRUE;
		oldref = FALSE;
	}

	if (! strlen(path))
		Dgetpath(path, 0);
	else
	{
		splitres = fnsplit(path, drv, dir, fname, ext);
		if (! (splitres & DIRECTORY) && (splitres & DRIVE))
		{
			Dgetpath(dir, toupper(drv[0]) - 'A' + 1);
			strcpy(path, drv);
			strcat(path, "\\");
			strcat(path, dir);
		}
	}			
		
	if (strlen(oldfile) && findfirst(oldfile, &oldffb, -1))
	{
		fprintf(stderr, "No reference for -newer %s...\n", oldfile);
		exit(1);
	}
	strupr(path); strupr(file);
	find(path, file, command);
}
