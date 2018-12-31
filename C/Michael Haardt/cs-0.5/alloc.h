#ifndef ALLOC_H
#define ALLOC_H

#include <sys/types.h>
#include <string.h>

#define mystrsave(X) strcpy(xmalloc(strlen((X))+1), (X))

void *xmalloc(size_t n);
void *xrealloc(void *s, size_t n);

#endif
