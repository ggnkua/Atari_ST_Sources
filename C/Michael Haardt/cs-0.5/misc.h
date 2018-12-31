#ifndef MISC_H
#define MISC_H

#ifdef NEEDS_SSIZE_T
typedef int ssize_t;
#endif

#ifdef NEEDS_MEMMOVE
void memmove(void *dst, void *src, size_t len);
#endif

#ifdef NEEDS_STRERROR
char *strerror(int errno);
#endif

#endif
