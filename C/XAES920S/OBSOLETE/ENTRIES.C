/*
 * Directory access --- The POSIX way (I hope <g>)
 *
 * Note: If you're doing something recursive, ignore
 * files "." and "..".
 *
 * W/ 1996 by Eero Tamminen, t150315@cc.tut.fi
 * Extended by Craig
 */

#include <stdlib.h>			/* Memory stuff */
#include <sys/stat.h>			/* File statistics */
#include <dirent.h>			/* Directory stuff */
#include <string.h>			/* String stuff */
#include <unistd.h>
#include "entries.h"			/* Directory entry stuff */
#include "xa_defs.h"
#include "xa_types.h"
#include "xa_globl.h"

short match_pattern(char *t, char *pat);

static Lists NameList = {NULL, NULL};	/* Sorted name lists for listboxes */
static Entry *EntryStart;		/* First directory entry */
static char *MemEnd;			/* Last allocated block */
static int Dirs, Files;			/* Number of entries */


/*
 * Get directory entry information and copy it into memory
 */
static void get_stats(char *name, Entry *current)
{
	struct stat st;

	/* Get file information */
	if (stat(name, &st) < 0)
	{
		current->size = 0;
		current->flags = 0;
	} else
	{
		current->size = st.st_size;
		current->flags = 0;

		if (st.st_mode & S_IFLNK)	/* ++cg[6/9/96]: Show sym links in entries */
			current->flags |= FLAG_LINK;

		if (S_ISDIR(st.st_mode))
		{
			current->flags |= FLAG_DIR;
			Dirs++;
		} else
		{
			if (st.st_mode & (S_IXUSR|S_IXGRP|S_IXOTH))	/* ++cg[6/9/96]: Show files that are executable */
				current->flags |= FLAG_EXECUTABLE;
       
			Files++;
		}

		/* set other flags */
	}
	/* copy dir entry name */
	strcpy((char *)(current + 1), name);
}

/*
 * Read all the directory entries + handle memory allocation
 */
#define _NO_CASE  8
extern short toscase;

Entry *read_entries(char *dir)
{
	char *new_block;
	struct dirent *entry;
	Entry *current, *prev;
	int length, mem_left;
	char *olddir;
	DIR *dfd;

	DIAGS(("read_entries\n"));
	DIAGS(("dir=%s\n", dir));

	olddir = getcwd(0, PATH_MAX);
	chdir(dir);
	
	if ((dfd = opendir(".")) == 0)
		return 0;

	if ((MemEnd = malloc(BLOCK_SIZE)) == 0L)
	{
		chdir(olddir);
		free(olddir);
		closedir(dfd);
		return 0;
	}
  
	*(char **)MemEnd = NULL;			/* This is the first block */
	EntryStart = (Entry *)(MemEnd + sizeof(char *));
	mem_left = BLOCK_SIZE - sizeof(char *);
	current = prev = EntryStart;
	Files = Dirs = 0;

	while((entry = readdir(dfd)) != 0)
	{
		length = sizeof(Entry) + strlen(entry->d_name);
		length = (length + POINTER_ALIGN) & ~(POINTER_ALIGN - 1);

		/* Allocate more memory if needed */
		if (mem_left < length)
		{
			if ((new_block = malloc(BLOCK_SIZE)) == 0L)
				break;			/* Out of memory */

			*(char **)new_block = MemEnd;
			current = (Entry *)(new_block + sizeof(char *));
			mem_left = BLOCK_SIZE - sizeof(char *);
			MemEnd = new_block;
		}
		prev->next = current;
		prev = current;
		if (dfd->status == _NO_CASE && toscase)		/* HR */
			strupr(entry->d_name),
			strupr(dir);
		get_stats(entry->d_name, current);
		current = (Entry *)((char *)current + length);
		mem_left -= length;
	}
	prev->next = NULL;
	closedir(dfd);
	chdir(olddir);
	free(olddir);

	return EntryStart;
}

static int compare(const void *a, const void *b)
{
	return stricmp(*(char **)a, *(char **)b);		/* HR case insensitive */
}

/* HR: moved match_pattern() to it's own file MATCHPAT.C */

/* 
 * Divide directory entries into subdirectories & files and sort both 
 * ++cg[16/9/96]:retrofitted the pattern matching (glob) code
 */
Lists *sort_entries(char *mask)
{
	Entry *current = EntryStart;
	char **dirlist, **filelist;

	if (Dirs + Files <= 0)
		return 0;

	dirlist = NameList.dirs = malloc((Dirs + 1) * sizeof(char *));
	if (!dirlist)
		return 0;
	filelist = NameList.files = malloc((Files + 1) * sizeof(char *));
	if (!filelist)
	{
		free(dirlist);
		NameList.dirs = 0;
		return 0;
	}

	DIAGS(("sorting\n"));
	NameList.num_dirs = 0;
	NameList.num_files = 0;

	do
	{
		if (current->flags & FLAG_DIR)
		{
			*(dirlist++) = (char *)(current + 1);
			NameList.num_dirs++;
		} else
		{
			if (match_pattern((char *)(current + 1), mask))	/* ++cg: match the pattern */
			{
				*(filelist++) = (char *)(current + 1);
				NameList.num_files++;
			} else
			{
				Files--;
			}
		}
		current = current->next;
	} while(current);
	*filelist = NULL;
	*dirlist = NULL;

#if FILESELECTOR_QSORT
	if (Dirs > 0)
		qsort(NameList.dirs, Dirs, sizeof(char *), compare);
	if (Files > 0)
		qsort(NameList.files, Files, sizeof(char *), compare);
#endif

	return &NameList;
}

/*
 * Free all the allocated areas
 */
void free_entries(void)
{
	char *previous;

	/* Free lists */
	if (NameList.dirs)
	{
		free(NameList.dirs);
		NameList.dirs = 0;
	}
	if (NameList.files)
	{
		free(NameList.files);
		NameList.files = 0;
	}

	/* Free blocks */
	do
	{
		previous = *(char **)MemEnd;
		free(MemEnd);
		MemEnd = previous;
	} while(MemEnd);
}
