/* PROGRAMM	ls
** VERSION	2.0
** DATUM	3. Dezember 1987
** AUTOR	Uwe Sauerland
** ZWECK	unix-like directory listing
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

int	lang = FALSE, sort_time = FALSE, list_all = FALSE, list_size = FALSE,
	list_mode = FALSE, list_type = FALSE, reverse = FALSE, sorted = TRUE,
	recursive = FALSE, streamed = FALSE, dirsonly = FALSE, lines = FALSE,
	dskinfo = FALSE;

int	drive;

unsigned long total_size = 0L, total_files = 0L, total_dirs = 0L;

typedef struct info
{
	struct ffblk entry;
	struct info *below, *above;
} INFO;

typedef INFO *INFOPTR;

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

INFOPTR mk_info(struct ffblk newinfo)
{
	INFOPTR result;

	result = (INFOPTR) malloc(sizeof(INFO));
	result->entry = newinfo;
	result->below = NULL; result->above = NULL;
	return result;
}

void add_info(struct ffblk newinfo, INFOPTR *link)
{
	INFOPTR ip = *link;

	if (ip == NULL)
		*link = mk_info(newinfo);
	else if (! sorted)
	{
		while (ip->above != NULL)
			ip = ip->above;
		add_info(newinfo, &(ip->above));
	}
	else
	{
		if (sort_time)
			if (datcmp(ip->entry, newinfo) <= 0)
				add_info(newinfo, reverse ? &(ip->below) : &(ip->above));
			else
				add_info(newinfo, reverse ? &(ip->above) : &(ip->below));
		else
			if (strcmp(ip->entry.ff_name, newinfo.ff_name) <= 0)
				add_info(newinfo, reverse ? &(ip->below) : &(ip->above));
			else
				add_info(newinfo, reverse ? &(ip->above) : &(ip->below));
	}
}

void get_entries
(
	char *pathname,
	INFOPTR *root,
	unsigned long *files,
	unsigned long *dirs,
	unsigned long *all_size
)
{
	struct ffblk direntry;
	int attributes = FA_RDONLY | FA_DIREC | FA_ARCH | FA_LABEL;
	DTA *olddta;

	if (list_all)
		attributes |= FA_HIDDEN | FA_SYSTEM;
	olddta = Fgetdta();
	if (! findfirst(pathname, &direntry, attributes))
	{
		if (! dirsonly || (direntry.ff_attrib & FA_DIREC))
		{
			if (direntry.ff_attrib & FA_DIREC)
			{
				if (noparcur(direntry) || list_all)
					++(*dirs);
			}
			else if (!(direntry.ff_attrib & FA_LABEL))
				++(*files);
			if (noparcur(direntry) || list_all)
			{
				*all_size += direntry.ff_fsize;
				add_info(direntry, root);
			}
		}
		while (! findnext(&direntry))
		{
			if (! dirsonly || (direntry.ff_attrib & FA_DIREC))
			{
				if (direntry.ff_attrib & FA_DIREC)
				{
					if (noparcur(direntry) || list_all)
						++(*dirs);
				}
				else if (!(direntry.ff_attrib & FA_LABEL))
					++(*files);
				if (noparcur(direntry) || list_all)
				{
					*all_size += direntry.ff_fsize;
					add_info(direntry, root);
				}
			}
		}
	}
	else
		*files = *dirs = 0L;
	Fsetdta(olddta);
}

void show_entry(struct ffblk ffb)
{
	char entry[MAXFILE + MAXEXT];
		/* Die zus„tzlich ben”tigte Stelle fr den Backslash (\) bzw.
		** den Stern (*) durch das doppelt enthaltene Null-Ende Byte
		** sichergestellt.
		*/
	char *ext;	/* position of extension-mark	*/
	int i;

	if (list_mode)
	{
		printf("%c" , ffb.ff_attrib & FA_RDONLY ? 'r' : 'w');
		printf("%c" , ffb.ff_attrib & FA_HIDDEN ? 'h' : '.');
		printf("%c" , ffb.ff_attrib & FA_SYSTEM ? 's' : '.');
		printf("%c " , ffb.ff_attrib & FA_ARCH  ? 'a' : '.');
	}
	strcpy(entry, ffb.ff_name);
	if (ffb.ff_attrib & FA_LABEL)
	{
		if (strlen(entry) > 8)
			for (i = 8; entry[i]; ++i)
				entry[i] = entry[i + 1];
		if (list_type)
			strcat(entry, "%");
	}
	else if (ffb.ff_attrib & FA_DIREC)
	{
		if (list_type)
			strcat(entry, "\\");
	}
	else if (list_type)
	{
		if ((ext = strchr(ffb.ff_name, '.')) != NULL)
		{	/* extension given */
			++ext;
			if
			(!(
#ifdef TOS
				strcmp(ext, "PRG") &&
				strcmp(ext, "TOS") &&
				strcmp(ext, "TTP") &&
				strcmp(ext, "APP")
#else
				strcmp(ext, "EXE") &&
				strcmp(ext, "COM") &&
				strcmp(ext, "BIN") &&
				strcmp(ext, "BAT")
#endif
			))
				strcat(entry, "*");
		}
	}
	if (streamed)
		printf("%s ", entry);
	else
		printf("%-15s", entry);
	if (list_size || lang)
		if (ffb.ff_attrib & (FA_DIREC | FA_LABEL))
			printf("%12c", ' ');
		else
			printf("%10lu  ", ffb.ff_fsize);
	if (lang)
		printf("%02u.%02u.%4u  %02u:%02u:%02u",
			fday(ffb.ff_fdate), fmonth(ffb.ff_fdate), fyear(ffb.ff_fdate) + 1980,
			fhour(ffb.ff_ftime), fminute(ffb.ff_ftime), fsecond(ffb.ff_ftime));
	if (lines) putchar('\n');
}

void do_list(INFOPTR ip, int *column)
{
	if (ip->below != NULL) do_list(ip->below, column);
	show_entry(ip->entry);
	if (++(*column) % 5 == 0 && ! (lines || streamed))
	{
		putchar('\n');
		*column = 0;
	}
	if (ip->above != NULL) do_list(ip->above, column);
	free(ip);
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

void ls_recursive(char *mypath)
{
	struct ffblk direntry;
	int attributes = FA_RDONLY | FA_DIREC | FA_ARCH;
	DTA *olddta;
	PATHPTR root = NULL, newpath = NULL;
	char pathroot[81], exppath[81];
	void ls(char *pathname);

	if (list_all)
		attributes |= FA_HIDDEN | FA_SYSTEM;

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
			ls(newpath->pathname);
			root = newpath;
			newpath = newpath->next;
			free(root);
		}
	}
	Fsetdta(olddta);
}

void ls(char *pathname)
{
	char exppath[81], mypath[81];
	INFOPTR root = NULL;
	unsigned long files = 0L, dirs = 0L, all_size = 0L;
	int column;

	strcpy(mypath, pathname);
	strupr(mypath);
	expand(mypath, exppath);
	if (strlen(exppath))
	{	get_entries(exppath, &root, &files, &dirs, &all_size);
		total_files += files;
		total_dirs += dirs;
		total_size += all_size;
		printf("listing of %s\n\n", exppath);
		if (files + dirs == 0)
			printf("no entries found.\n");
		else
		{
			column = 0;
			do_list(root, &column);
			if (((files + dirs) % 5) && (! lines))
				putchar('\n');
			if (recursive)
			{
				printf("\n%lu file%s, %lu director%s listed, covering %lu bytes.\n\n\n",
					files, files == 1 ? "" : "s", dirs, dirs == 1 ? "y" : "ies", all_size);
				ls_recursive(mypath);
			}
		}
	}
}

void get_options(char *options)
{
	list_all	= cins(options, 'a');
	list_mode	= cins(options, 'A');
	dirsonly	= cins(options, 'd');
	list_type	= cins(options, 'F');
	dskinfo		= cins(options, 'i');
	lang		= cins(options, 'l');
	recursive	= cins(options, 'R');
	reverse		= cins(options, 'r');
	list_size	= cins(options, 's');
	sort_time	= cins(options, 't');
	sorted		= ! cins(options, 'u');
	lines		= cins(options, '1') || lang || list_size || list_mode;
	if (cins(options, 'm'))
	{
		streamed = list_type = TRUE;
		list_mode = lang = list_size = lines = recursive = FALSE;
	}
}

void main(int argc, char *argv[])
{
	int i;
	DSPACE df;
	unsigned long dskfree;
	char pathname[81];

	strcpy(pathname, "");
	for (i = 1; i < argc; i++)
		if (*argv[i] == '-')
			if (strchr(argv[i], '?') != NULL)
			{
				fprintf(stderr, "usage: ls -1AadFlmRrstu [ <path> ]\n");
				fprintf(stderr, "\t1\tforce one entry per line\n");
				fprintf(stderr, "\tA\tlist directory status (attributes)\n");
				fprintf(stderr, "\ta\tlist all (including hidden and system files)\n");
				fprintf(stderr, "\td\tlist directories only\n");
				fprintf(stderr, "\tF\tshow entry status (\\=directory, *=executable, %%=volume label)\n");
				fprintf(stderr, "\ti\tdisplay disk info\n");
				fprintf(stderr, "\tl\tuse long format (plus size and date)\n");
				fprintf(stderr, "\tm\tforce stream output format\n");
				fprintf(stderr, "\tR\trecursive tree listing\n");
				fprintf(stderr, "\tr\tsort in reverse order\n");
				fprintf(stderr, "\ts\tlist size\n");
				fprintf(stderr, "\tt\tsort by time and date\n");
				fprintf(stderr, "\tu\tlist unsorted\n");
				exit(0);
			}
			else
				get_options(argv[i]);
		else
			strcpy(pathname, argv[i]);

	ls(pathname);

	if (dskinfo & !streamed)
	{
		Dfree(&df, drive);
		dskfree = df.freal * df.bps * df.pspal;
		if (! recursive)
			printf("\n");
		printf
		(
			"Total: %lu file%s, %lu director%s listed, covering %lu bytes.\n"
			"%lu bytes in %lu cluster%s are available on this disk.\n",
			total_files, total_files == 1 ? "" : "s",
			total_dirs, total_dirs == 1 ? "y" : "ies",
			total_size, dskfree, df.freal, df.freal == 1 ? "" : "s"
		);
	}
}
