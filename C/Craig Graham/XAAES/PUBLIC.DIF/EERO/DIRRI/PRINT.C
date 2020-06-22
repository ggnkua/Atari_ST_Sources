/*
 * divide and sort entry list into two dir & file name pointer lists
 *
 * W/ 1996 by Eero Tamminen, t150315@cc.tut.fi
 */

#include <stdio.h>
#include <unistd.h>			/* getcwd() */
#include <stdlib.h>			/* free() */
#include <limits.h>			/* PATH/NAME_MAX */
#include "entries.h"			/* directory entry stuff */

/* show the directory path and all the files in it (sorted) */
static void show_lists(char *path, Lists *lists)
{
  char **dirs, **files;

  printf("%s:\n", path);

  dirs = lists->dirs;
  while(*dirs)
    printf("%s/\n", *(dirs++));

  files = lists->files;
  while(*files)
  {
    printf("%-30s%9ld\n",
      *files, ((Entry *)*files - 1)->size);
    files++;
  }
}

/* show the directory path and all the files in it (unsorted) */
static void show_entries(char *path, Entry *current)
{
  printf("%s:\n", path);

  while(current)
  {
    if(current->flags & FLAG_DIR)
      printf("%s/\n", (char *)(current+1));
    else
      printf("%-30s%9ld\n", (char *)(current+1), current->size);
    current = current->next;
  }
}

int main(int argc, char *argv[])
{
  char *dir, *olddir, *newdir;
  Entry *first;
  Lists *lists;

  /* store current directory path and cd to a user supplied one */
  if(argc != 2)
  {
    fprintf(stderr, "usage: %s <path>\n", *argv);
    return -1;
  }

  dir = argv[1];
  olddir = getcwd(0, PATH_MAX);
  if(chdir(dir))
  {
    free(olddir);
    fprintf(stderr, "%s: unable to change to directory %s\n", *argv, dir);
    return -1;
  }
  newdir = getcwd(0, PATH_MAX);

  first = read_entries(".");
  chdir(olddir);
  free(olddir);

  if(!first)
  {
    fprintf(stderr, "%s: unable to open dir %s\n", *argv, dir);
    return -1;
  }

  if(!(lists = sort_entries()))
  {
    fprintf(stderr, "%s: sorting failure (memory)\n", *argv);
    return -1;
  }
  show_lists(newdir, lists);
  free(newdir);
  free_entries();

  return 0;
}
