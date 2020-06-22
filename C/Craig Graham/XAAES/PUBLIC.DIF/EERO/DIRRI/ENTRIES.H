/*
 * directory access --- The POSIX way
 *
 * W/ 1996 by Eero Tamminen, t150315@cc.tut.fi
 */

/* directory name space allocator configuration defines */
#ifndef POINTER_ALIGN
#define POINTER_ALIGN	(sizeof(void*))
#endif
#define BLOCK_SIZE	128

/* entry in the read directory */
typedef struct ENTRY
{
  struct ENTRY *next;
  long flags;
  long size;
} Entry;
/* followed with the name string */

/* sort entries returns two char*[] arrays, names of directories and
 * files, from the given entry list for the fileselector listbox widgets.
 */
typedef struct
{
  char **dirs;
  char **files;
} Lists;

/* Memory handling / usage:
 *
 * pointer aligning is needed for the structures after strings in the
 * blocks.  One block can contain at least (BLOCK_SIZE / (NAME_MAX +
 * POINTER_ALIGN + sizeof(void*) * 3)) directory entries.  Using
 * sort_entries() will take further sizeof(char*) / entry.
 */

/* directory entry flags */
#define FLAG_DIR	1


Entry *read_entries(char *dir);
Lists *sort_entries(void);
void free_entries(void);
