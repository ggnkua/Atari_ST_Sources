/*
 * library-specific stuff
 */
#ifndef _LIB_H
#define _LIB_H

#ifndef _COMPILER_H
#include <compiler.h>
#endif

#include <stdio.h>	/* for FILE   */
#include <time.h>	/* for time_t */

/* filename mapping function type */
#ifndef __FNMAP
#define __FNMAP
typedef int (*fnmapfunc_t) __PROTO((const char *, char *));
#endif

__EXTERN int		_unx2dos __PROTO((const char *, char *, size_t));
__EXTERN int		_dos2unx __PROTO((const char *, char *, size_t));
#ifndef __MINT__
__EXTERN int		unx2dos __PROTO((const char *, char *));
__EXTERN int		dos2unx __PROTO((const char *, char *));
__EXTERN void		fnmapfunc __PROTO((fnmapfunc_t u2dos, fnmapfunc_t dos2u));
#endif
__EXTERN int		_path_dos2unx __PROTO((const char *, char *, size_t));
__EXTERN int		_path_unx2dos __PROTO((const char *, char *, size_t));

__EXTERN long		_write 	 __PROTO((int, const void *, unsigned long));
__EXTERN long		_read 	 __PROTO((int, void *, unsigned long));
#ifndef __MINT__
__EXTERN int		console_input_status __PROTO((int));
__EXTERN unsigned int	console_read_byte __PROTO((int));
__EXTERN void		console_write_byte __PROTO((int, int));
#else
__EXTERN int	_console_read_byte __PROTO((int));
__EXTERN void	_console_write_byte __PROTO((int, int));
#endif

__EXTERN time_t		_dostime __PROTO((time_t));
__EXTERN time_t		_unixtime __PROTO((unsigned int, unsigned int));

__EXTERN char *		_itoa __PROTO((int, char *, int));
__EXTERN char *		_ltoa __PROTO((long, char *, int));
__EXTERN char *		_ultoa __PROTO((unsigned long, char *, int));

__EXTERN int		_doprnt __PROTO((int (*)(int, FILE *), FILE *, const char *, __VA_LIST__));

#ifdef __MINT__
__EXTERN int	_scanf __PROTO((FILE *, int (*)(FILE *),
			int (*)(int, FILE *), const char *, __VA_LIST__));
__EXTERN int	_enoent __PROTO((char *));
#endif

__EXTERN long		get_sysvar __PROTO((void *var));
__EXTERN void		set_sysvar_to_long __PROTO((void *var, long val));

__EXTERN void	_main		__PROTO((long, char **, char **));
__EXTERN void	_init_signal	__PROTO((void));
__EXTERN void 	_monstartup	__PROTO((void *lowpc, void *highpc));
__EXTERN void	__mcleanup	__PROTO((void));
__EXTERN void	_moncontrol	__PROTO((long));
__EXTERN void	_setstack	__PROTO((char *));
__EXTERN void	_crtinit	__PROTO((void));
__EXTERN void	_acc_main	__PROTO((void));
__EXTERN __EXITING	__exit	__PROTO((long status)) __NORETURN;

__EXTERN void	_fclose_all_files __PROTO((void));
/* from the TOS GCC library */
/* 5/5/92 sb -- definitions needed in malloc.c and realloc.c */

struct mem_chunk 
	{
	long valid;
#define VAL_FREE  0xf4ee0abcL
#define VAL_ALLOC 0xa11c0abcL
#define VAL_BORDER 0xb04d0abcL

	struct mem_chunk *next;
	unsigned long size;
	};
#define ALLOC_SIZE(ch) (*(long *) ((char *) (ch) + sizeof (*(ch))))
#define BORDER_EXTRA ((sizeof (struct mem_chunk) + sizeof (long) + 7) & ~7)

/* linked list of free blocks */

extern struct mem_chunk _mchunk_free_list;

/* status of open files (for isatty, et al.) */

#ifdef __MINT__

#define __NHANDLES 40

struct __open_file {
	short	status;		/* whether or not it's a tty */
	short	flags;		/* if a tty, its flags */
};

#else

#define __NHANDLES	80
struct __open_file {
    unsigned short append:1;	/* 1 if O_APPEND set for this file */
    unsigned short nodelay:1;	/* 1 if O_NDELAY set for this file */
    unsigned short pipe:1;      /* 1 if O_PIPE set for this file */
    unsigned short eclose:1;    /* 1 if close on exec is set for this file */
    unsigned short status:2;	/* status FH_UNKNOWN | ISATTY | ISAFILE */
    char	   *filename;	/* filename of open file */
};

#endif /* __MINT__ */

extern struct __open_file __open_stat[];
  /* NOTE: this array is indexed by (__OPEN_INDEX(fd)) */

#define __OPEN_INDEX(x)	(((short)(x)) + 3)

#define FH_UNKNOWN	0
#define FH_ISATTY	1
#define FH_ISAFILE	2

/*
 * macro for converting a long in DOS format to one in Unix format. "x"
 * _must_ be an lvalue!
 */
#define __UNIXTIME(x) (x = _unixtime( ((short *)&x)[0], ((short *)&x)[1] ))

__EXTERN int _do_lock __PROTO((int fd, int cmd, long size, int whence));

#ifdef _STDIO_H
__EXTERN FILE *_fopen_i __PROTO((const char *, const char *, FILE *));
#endif

#endif /* _LIB_H */
