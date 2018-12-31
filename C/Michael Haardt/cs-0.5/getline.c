/* #includes */ /*{{{C}}}*//*{{{*/
#ifndef NO_POSIX_SOURCE
#undef _POSIX_SOURCE
#define _POSIX_SOURCE 1
#undef _POSIX_C_SOURCE
#define _POSIX_C_SOURCE 2
#endif

/* FreeBSD is broken because it requires the first two in this order */
#include <sys/types.h>
#include <sys/stat.h>
#include <assert.h>
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include "alloc.h"
#include "getline.h"
#include "misc.h"
/*}}}*/

char *getline(const char *filename, int line)
{
  /* variables */ /*{{{*/
  static struct
  {
    char *name;
    int fd;
    off_t *index;
    int indexs;
    int indexsz;
  } lru[10],ex;
  static int used=0;
  int i;
  static char *srcline=(char*)0;
  static size_t srclinelen=0;
  const char *p;
  ssize_t len;
  /*}}}*/

  assert(filename!=(const char*)0);
  assert(line>=0); /* 0 to zap the cache, 1 or more to get a line */
  for (i=0; i<used && strcmp(filename,lru[i].name); ++i);
  if (i==used)
  {
    if (line>=1)
    {
    off_t position;
    ssize_t buflen;
    char buffer[4096];

    if (used==10) /* drop last element from list and push others down */ /*{{{*/
    {
      close(lru[10-1].fd);
      free(lru[10-1].index);
      free(lru[10-1].name);
      memmove(lru+1,lru,sizeof(lru[0])*(10-1));
      i=0;
      --used;
    }
    /*}}}*/
    else if (used) /* push other elements down */ /*{{{*/
    {
      memmove(lru+1,lru,sizeof(lru[0])*used);
      --used;
    }
    /*}}}*/
    /* load top element and create index of all line positions */ /*{{{*/
    lru[0].name=mystrsave(filename);
    lru[0].fd=open(filename,O_RDONLY);
    lru[0].index=xmalloc(2048*sizeof(off_t));
    lru[0].indexs=0;
    lru[0].indexsz=2048;
    position=0;
    while ((buflen=read(lru[0].fd,buffer,sizeof(buffer)))>0)
    {
      const char *p;

      for (i=0,p=buffer; i<buflen; ++i,++p) if (*p=='\n')
      {
        if ((lru[0].indexs+1)>=lru[0].indexsz) lru[0].index=xrealloc(lru[0].index,(lru[0].indexsz+=1024)*sizeof(off_t));
        lru[0].index[lru[0].indexs]=position+i+1;
        ++lru[0].indexs;
      }
      position+=buflen;
    }
    lru[0].index[lru[0].indexs]=position+i+1;
    ++lru[0].indexs;
    ++used;
    /*}}}*/
    }
    else return (char*)0;
  }
  else /* move found element to front or remove it */ /*{{{*/
  {
    if (line>=1) /* move found element to front */
    {
    if (i)
    {
    ex=lru[i];
    memmove(lru+1,lru,sizeof(lru[0])*i);
    lru[0]=ex;
    }
    }
    else
    {
      close(lru[i].fd);
      free(lru[i].index);
      free(lru[i].name);
     if (i<(used-1)) memmove(lru+i,lru+i+1,sizeof(lru[0])*(used-i-1));
     --used;
     return (char*)0;
    }
  }
  /*}}}*/
  lseek(lru[0].fd,line==1 ? 0 : lru[0].index[line-2],SEEK_SET);
  len=lru[0].index[line-1]-(line==1 ? 0 : lru[0].index[line-2])-1;
  if (len>=srclinelen) { free(srcline); srcline=xmalloc(srclinelen=len+1); }
  if (len) len=read(lru[0].fd,srcline,len);
  assert(len>=0);
  srcline[len]='\0';
  p=srcline; while (*p && (*p==' ' || *p=='\t')) ++p;
  return mystrsave(p);
}
