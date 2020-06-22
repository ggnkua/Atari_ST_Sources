/*
 * Directory access --- The POSIX way (I hope <g>)
 *
 * Note: if you're doing something recursive, ignore
 * files "." and "..".
 *
 * W/ 1996 by Eero Tamminen, t150315@cc.tut.fi
 */

#include <stdlib.h>			/* memory stuff */
#include <sys/stat.h>			/* file statistics */
#include <dirent.h>			/* directory stuff */
#include <string.h>			/* string stuff */
#include "entries.h"			/* directory entry stuff */

static Lists NameList;			/* sorted name lists for listboxes */
static Entry *EntryStart;		/* first directory entry */
static char *MemEnd;			/* last allocated block */
static int Dirs, Files;			/* number of entries */


/* get directory entry information and copy it into memory */
static void get_stats(char *name, Entry *current)
{
  struct stat st;

  /* get file information */
  if(stat(name, &st) < 0)
  {
    current->size = 0;
    current->flags = 0;
  }
  else
  {
    current->size = st.st_size;
    current->flags = 0;
    if(S_ISDIR(st.st_mode))
    {
      current->flags |= FLAG_DIR;
      Dirs++;
    }
    else
      Files++;

    /* set other flags */
  }
  /* copy dir entry name */
  strcpy((char*)(current+1), name);
}

/* read all the directory entries + handle memory allocation */
Entry *read_entries(char *dir)
{
  char *new_block;
  struct dirent *entry;
  Entry *current, *prev;
  int length, mem_left;
  DIR *dfd;

  if(!(dfd = opendir(dir)))
    return 0;

  if(!(MemEnd = malloc(BLOCK_SIZE)))
  {
    closedir(dfd);
    return 0;
  }
  *(char **)MemEnd = NULL;			/* this is the first block */
  EntryStart = (Entry *)(MemEnd + sizeof(char *));
  mem_left = BLOCK_SIZE - sizeof(char *);
  current = prev = EntryStart;
  Files = Dirs = 0;

  while((entry = readdir(dfd)))
  {
    length = sizeof(Entry) + strlen(entry->d_name);
    length = (length + POINTER_ALIGN) & ~(POINTER_ALIGN-1);

    /* allocate more memory if needed */
    if(mem_left < length)
    {
      if(!(new_block = malloc(BLOCK_SIZE)))
	break;					/* out of memory */

      *(char **)new_block = MemEnd;
      current = (Entry *)(new_block + sizeof(char *));
      mem_left = BLOCK_SIZE - sizeof(char *);
      MemEnd = new_block;
    }
    prev->next = current;
    prev = current;
    get_stats(entry->d_name, current);
    current = (Entry *)((char *)current + length);
    mem_left -= length;
  }
  prev->next = NULL;
  closedir(dfd);
  return EntryStart;
}

static int compare(const void *a, const void *b)
{
  return strcmp(*(char**)a, *(char**)b);
}

/* divide directory entries into subdirectories & files and sort both */
Lists *sort_entries(void)
{
  Entry *current = EntryStart;
  char **dirlist, **filelist;

  if(Dirs + Files <= 0)
    return 0;

  dirlist = NameList.dirs = malloc((Dirs+1) * sizeof(char*));
  if(!dirlist)
    return 0;
  filelist = NameList.files = malloc((Files+1) * sizeof(char*));
  if(!filelist)
  {
    free(dirlist);
    NameList.dirs = 0;
    return 0;
  }

  do
  {
    if(current->flags & FLAG_DIR)
      *(dirlist++) = (char *)(current+1);
    else
      *(filelist++) = (char *)(current+1);
    current = current->next;
  } while(current);
  *filelist = NULL;
  *dirlist = NULL;

  qsort(NameList.dirs, Dirs, sizeof(char*), compare);
  qsort(NameList.files, Files, sizeof(char*), compare);

  return &NameList;
}

/* free all the allocated spaces */
void free_entries(void)
{
  char *previous;

  /* free lists */
  if(NameList.dirs)
  {
    free(NameList.dirs);
    NameList.dirs = 0;
  }
  if(NameList.files)
  {
    free(NameList.files);
    NameList.files = 0;
  }

  /* free blocks */
  do
  {
    previous = *(char **)MemEnd;
    free(MemEnd);
    MemEnd = previous;
  } while(MemEnd);
}
