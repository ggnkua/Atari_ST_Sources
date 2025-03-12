/* $Id: dict.c,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $
*/
char *dict_id = "$Id: dict.c,v 1.5 1994/02/24 15:03:05 a904209 Exp a904209 $";
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <fcntl.h>
#include <unistd.h>
#ifndef linux
#ifndef NeXT
#include <search.h>
#endif
#endif
#ifdef NeXT
#include <libc.h>
#include <mach/mach.h>
#include <mach/mach_error.h>
#endif
#include <stdlib.h>
#include <memory.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/mman.h>
#include "proto.h"
#include "dict.h"

#ifndef DICT_PATH
#define DICT_PATH "/usr/local/lib/text710.dat"
#endif

#ifdef NeXT
#define DICTRECTSIZE 129
#else
#define DICTRECTSIZE  sizeof(dictrec_t)
#endif

int
dict_init(d, path)
dict_ptr d;
char *path;
{
 int code = 0;
 int fd;
#ifdef NeXT
 kern_return_t k_err;
#endif

 if (!path || !path[0])
  path = DICT_PATH;
 fd = open(path, O_RDONLY, 0444);
 if (fd >= 0)
  {
   struct stat st;
   if (!fstat(fd, &st))
    {
     d->size = st.st_size;
#ifdef NeXT
	 d->base = 0;
	 k_err = map_fd(fd, (vm_offset_t)0,
	   (vm_offset_t *)&d->base, TRUE, (vm_size_t)d->size);
	 if (k_err != KERN_SUCCESS) {
		mach_error("dict_init", k_err);
		exit(1);
	 }
     d->entries = d->size / DICTRECTSIZE;
	 code = 1;
#else
     d->base = (dictrec_ptr) mmap(0, d->size, PROT_READ, MAP_PRIVATE, fd, 0);
     if (d->base && d->base != (dictrec_ptr) - 1)
      {
       d->entries = d->size / DICTRECTSIZE;
       code = 1;
      }
#endif
    }
   close(fd);
  }
 return code;
}

void
dict_term(d)
dict_ptr d;
{
#ifdef NeXT
	kern_return_t r;
	r = vm_deallocate(task_self(), (vm_address_t)d->base, d->size);
	if (r != KERN_SUCCESS)
    	mach_error("dict_term", r);
#else
 munmap((caddr_t) d->base, d->size);
#endif
}


static int spell_cmp PROTO((const void *a, const void *b));

static int spell_cmp(a, b)
const void *a;
const void *b;
{
 return strncmp((char *)a, (char *)b, 23);
}

dictrec_ptr
spell_find(d, s, n)
dict_ptr d;
char *s;
unsigned n;
{
 dictrec_t r;
 dictrec_ptr x;
 char *p = r.spell;
 memset(&r, ' ', sizeof(r));
 while (n-- > 0)
  *p++ = *s++;
 r.eoln = '\n';
 x = (dictrec_ptr) bsearch(&r, d->base, d->entries,
                           DICTRECTSIZE, spell_cmp);
 if (!x && isupper(r.spell[0]))
  {
   for (p = r.spell; p < r.spell + sizeof(r.spell); p++)
    {
     if (isupper(*p))
      *p = tolower(*p);
    }
   x = (dictrec_ptr) bsearch(&r, d->base, d->entries,
                             DICTRECTSIZE, spell_cmp);
  }
 if (x)
  {
   /* Find 1st matching entry */
   while (x > d->base && !spell_cmp(r.spell, x[-1].spell))
    x--;
  }
 return x;
}
