/*
 * XaAES - XaAES Ain't the AES
 *
 * A multitasking AES replacement for MiNT
 *
 */

/*
 * Directory access --- The POSIX way
 *
 * W/ 1996 by Eero Tamminen, t150315@cc.tut.fi
 * Extended by Craig
 */
 
#ifndef _ENTRIES_H
#define _ENTRIES_H

/* Directory name space allocator configuration defines */
#ifndef POINTER_ALIGN
#define POINTER_ALIGN	(sizeof(void *))
#endif
#define BLOCK_SIZE	128

/* Entry in the read directory */
typedef struct ENTRY
{
	struct ENTRY *next;
	long flags;
	long size;
} Entry;
/* Followed by the name string */

/* Sort entries returns two char*[] arrays, names of directories and
 * files, from the given entry list for the fileselector listbox widgets.
 */
typedef struct
{
	char **dirs;
	short num_dirs;
	char **files;
	short num_files;
} Lists;

/* Memory handling / usage:
 *
 * Pointer aligning is needed for the structures after strings in the
 * blocks. One block can contain at least (BLOCK_SIZE / (NAME_MAX +
 * POINTER_ALIGN + sizeof(void*) * 3)) directory entries.  Using
 * sort_entries() will take further sizeof(char *) / entry.
 */

/* Directory entry flags */
#define FLAG_DIR	1
#define FLAG_EXECUTABLE 2
#define FLAG_LINK	4

Entry *read_entries(char *dir);
Lists *sort_entries(char *mask);
void free_entries(void);

#endif
