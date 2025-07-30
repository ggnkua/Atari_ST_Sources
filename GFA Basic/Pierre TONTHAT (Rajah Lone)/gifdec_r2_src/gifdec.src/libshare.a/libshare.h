/*
 *  libshare: a dirty patch to make LDG compiled against mintlib shareable
 *
 *  by Arnaud BERCEGEAY (Feb 2004)
 */

#ifndef __LIBSHARE_H_
#define __LIBSHARE_H_

#include <compiler.h>

__BEGIN_DECLS

/* This is libshare 0.1.0 */

#define __LIBSHARE_MAJOR__    0
#define __LIBSHARE_MINOR__    1
#define __LIBSHARE_REVISION__ 1

void __CDECL libshare_init( void);
void __CDECL libshare_exit( void);

void * libshare_getshm( const char * memory_name);
void * libshare_createshm( const char * memory_name, size_t size);
void   libshare_deleteshm( const char * memory_name);

/* debug stuff */
extern int __sbrk_has_been_called; /* libshare::sbrk.c */
extern int __ind_lst_malloc ;
extern long __lst_malloc_size[];
extern void *__lst_malloc_addr[];
extern int __ind_lst_free;
extern void *__lst_free[];

__END_DECLS

#endif /* __LIBSHARE_H_ */
