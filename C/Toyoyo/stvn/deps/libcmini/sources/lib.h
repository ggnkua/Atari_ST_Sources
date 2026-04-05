/*
 * lib.h
 *
 *  Created on: 08.06.2013
 *      Author: mfro
 */

#ifndef LIB_H_
#define LIB_H_

#include <stdio.h>
#include <stdarg.h>
#include <sys/types.h>

/* definitions needed for stack stuff */

#define MINFREE	(8L * 1024L)		/* free at least this much mem on top */
#define MINKEEP (64L * 1024L)		/* keep at least this much mem on stack */
void _setstack(char *);

/* automagically called, either on entry to main(), or by use of .init_array */
void __main (void);

/* definitions needed in FILE related functions (fopen, fseek etc.) */

#define FILE_SET_HANDLE(fp, H) (fp)->__cookie = ((void*)(long)(H))
#define FILE_GET_HANDLE(fp) ((long)((fp)->__cookie))

typedef void (*ExitFn)(void);
extern char **environ;
extern short _app;
extern unsigned long _PgmSize;
extern long __libc_argc;
extern char **__libc_argv;

struct _mem_stream { char *xstring; char *xestring; };

int doprnt(int (*)(int, void *), void *stream, const char *fmt, va_list va);
int doscan(int (*getchar_func)(void*), int (*ungetchar_func)(int, void*), void* stream, const char* fmt, va_list va);
int __addchar(int c, void *stream);
int unx2dos(const char *unx, char *dos);
int dos2unx(const char *dos, char *unx);
unsigned long __strtoul_internal(const char *nptr, char **endptr, int base, int *sign);
unsigned long long __strtoull_internal(const char *nptr, char **endptr, int base, int *sign);
void _acc_main(void);
void _crtinit(void);
void _crtinit_noargs(void);

extern FILE *__stdio_head;

/* inode.c */
extern __ino_t __inode;

#undef __set_errno
#define __set_errno(e) (errno = (int)(e))

#ifndef NO_CONST
#  ifdef __GNUC__
#    define NO_CONST(p) __extension__({ union { const void *cs; void *s; } x; x.cs = p; x.s; })
#  else
#    define NO_CONST(p) ((void *)(p))
#  endif
#endif

#endif /* LIB_H_ */
