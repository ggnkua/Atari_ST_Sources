#ifdef atarist
/* POSIX compatible directory access routines for TOS */
/* written by Eric R. Smith and placed in the public domain */

#include <stddef.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>
#include <types.h>
#include <stat.h>
#include <errno.h>
#include <dirent.h>
#include <osbind.h>

extern int fullpath;

DIR *opendir(_dirname)
     const char *_dirname;
{
  char dirname[FILENAME_MAX];
  char *t;
  DIR  *dd;
  struct dirent *d, *x;
  long r;
  short i = 0;
  struct _dta mydta, *olddta;

  if (!(dd = malloc((size_t)sizeof(DIR)))) {
    errno = ENOMEM;
    return NULL;
  }
  olddta = (struct _dta *)Fgetdta();
  if ((r = Fsetdta(&mydta)) < 0) {
    errno = r;
    return NULL;
  }
  unx2dos(_dirname,dirname);
  for (t = dirname; *t; t++) ;

  /* make sure it's terminated by a slash */
  if (t > dirname && *(t-1) != '\\') {
    *t++ = '\\'; *t = 0;
  }
  strcpy(t, "*.*");
  if ((r = Fsfirst(dirname, (fullpath ? FA_DIR : 0))) < 0) {
    if (r != ENOENT) {
      errno = r;
      free(dd);
      dd = NULL;
      goto _done;
    }
    d = NULL;
    goto _done;
  }
  d = x = malloc((size_t)(DIRENTSIZ(strlen(mydta.dta_name))));
  for (;;) {
    if (!x) {
      errno = ENOMEM;
      free(dd); dd = NULL;
      break;
    }
    dos2unx(mydta.dta_name, x->d_name);
    x->d_ino = rand();      /* to make sure no two are equal */
    x->d_off = i++;

    /* I don't know what d_reclen means on Unix, but for TOS we might as well
       stuff the string length in here (so sys/dir.h can be more like BSD) */
    x->d_reclen = strlen(x->d_name);
    if (Fsnext() == 0) {
      x->d_next = malloc((size_t)(DIRENTSIZ(strlen(mydta.dta_name))));
      x = x->d_next;
    }
    else {
      x->d_next = 0;
      break;
    }
  }
_done:
  Fsetdta(olddta);
  if (dd) {
    dd->D_list = dd->D_curpos = d;
  }
  return dd;
}

struct dirent *readdir(dirp)
     DIR *dirp;
{
  struct dirent *x;

  if (!dirp) return NULL;

  x = dirp->D_curpos;
  if (x) dirp->D_curpos = x->d_next;
  return x;
}

int closedir(dirp)
     DIR *dirp;
{
  struct dirent *x, *oldx;

  if (!dirp) return -1;

  for (x = dirp->D_list; x; ) {
    oldx = x;
    x = x->d_next;
    free(oldx);
  }
  free(dirp);
  return 0;
}
#endif /* atarist */
