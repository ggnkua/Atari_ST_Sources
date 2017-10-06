#ifndef _MEMORY_H
#define _MEMORY_H

#ifndef _COMPILER_H
#include <compiler.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

#ifndef _SIZE_T
#define _SIZE_T __SIZE_TYPEDEF__
/* typedef _SIZE_T size_t; */
#endif

#ifndef alloca
#  ifndef __GNUC__
#    ifndef __cplusplus
        void *alloca(size_t);
#    else
        void *alloca(long unsigned int);
#    endif
#  else
#    define alloca(X) __builtin_alloca(X)
#  endif
#endif

void *malloc(size_t n);
void free(void *param);
void *realloc(void *_r, size_t n);
void *calloc(size_t n, size_t sz);
void _malloczero(int yes);
void _mallocChunkSize(size_t siz);

void *_malloc(unsigned long n);
void *_realloc(void *_r, unsigned long n);
void *_calloc(unsigned long n, unsigned long sz);

void *sbrk(size_t);
void *lsbrk(long);
void *_sbrk(long);

#ifndef alloca
#  ifndef __cplusplus
    void *alloca(size_t);
#  else
     void *alloca(long unsigned int);
#  endif
#endif

#ifdef __cplusplus
}
#endif
  
#endif /* _MEMORY_H */
