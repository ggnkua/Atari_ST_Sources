/*
 * stdio.h
 *
 *  Created on: 29.05.2013
 *      Author: mfro
 */

#ifndef _STDIO_H_
#define _STDIO_H_

#include <stdlib.h>
#include <stdarg.h>
#include <mint/osbind.h>

/* The mode of I/O, as given in the MODE argument to fopen, etc.  */
typedef struct
{
  unsigned int __read:1;    /* Open for reading.  */
  unsigned int __write:1;   /* Open for writing.  */
  unsigned int __append:1;  /* Open for appending.  */
  unsigned int __binary:1;  /* Opened binary.  */
  unsigned int __create:1;  /* Create the file.  */
  unsigned int __exclusive:1;   /* Error if it already exists.  */
  unsigned int __truncate:1;    /* Truncate the file on opening.  */
} __io_mode;

typedef struct __stdio_file FILE;
struct __stdio_file
{
    long __magic;
#define	_IOMAGIC (0xfedabeecL)	/* Magic number to fill `__magic'.  */

    void *__cookie;			/* Magic cookie. Holds GEMDOS handle */
	int __pushback;
#ifdef STDIO_MAP_NEWLINE
    int __last_char;
#endif /* defined STDIO_MAP_NEWLINE */
    FILE *__next;     		/* Next FILE in the linked list.  */
	__io_mode __mode;     /* File access mode.  */
	unsigned int __eof:1;
	unsigned int __error:1;
};

extern FILE *stdout;
extern FILE *stdin;
extern FILE *stderr;

#define _IONBF	2

#ifndef NULL
#define NULL        ((void *)0)
#endif

#define OPEN_MAX        32
#define FOPEN_MAX       32
#define FILENAME_MAX    128
#define PATH_MAX        128
#define BUFSIZ          1024
#define EOF             (-1)

/* File access modes for `open' and `fcntl'.  */
#define O_RDONLY    0   /* Open read-only.  */
#define O_WRONLY    1   /* Open write-only.  */
#define O_RDWR      2   /* Open read/write.  */


/* Bits OR'd into the second argument to open.  */
#define O_CREAT     0x200       /* create new file if needed */
#define O_TRUNC     0x400       /* make file 0 length */
#define O_EXCL      0x800       /* error if file exists */
#define O_NOCTTY    0x4000      /* do not open new controlling tty */

#ifdef __USE_GNU
# define O_NOATIME  0x04        /* Do not set atime.  */
# define O_DIRECTORY    0x10000     /* Must be a directory.  */
# define O_NOFOLLOW 0x20000     /* Do not follow links.  */
#endif

/* File status flags for `open' and `fcntl'.  */
#define O_APPEND    0x1000      /* position at EOF */
#define O_NONBLOCK  0x100       /* Non-blocking I/O */

#ifdef __USE_BSD
# define O_NDELAY   O_NONBLOCK
#endif

/* Mask for file access modes.  This is system-dependent in case
   some system ever wants to define some other flavor of access.  */
#define O_ACCMODE   (O_RDONLY|O_WRONLY|O_RDWR)

/* file sharing modes (not POSIX) */
#define O_COMPAT    0x00    /* old TOS compatibility mode */
#define O_DENYRW    0x10    /* deny both reads and writes */
#define O_DENYW     0x20
#define O_DENYR     0x30
#define O_DENYNONE  0x40    /* don't deny anything */
#define O_SHMODE    0x70    /* mask for file sharing mode */
#define O_SYNC      0x00    /* sync after writes (not implemented) */

/* Values for the second argument to `fcntl'.  */
#define F_DUPFD     0   /* Duplicate file descriptor.  */
#define F_GETFD     1   /* Get file descriptor flags.  */
#define F_SETFD     2   /* Set file descriptor flags.  */
#define F_GETFL     3   /* Get file status flags.  */
#define F_SETFL     4   /* Set file status flags.  */
#define F_GETLK     5   /* Get record locking info.  */
#define F_SETLK     6   /* Set record locking info.  */
#define F_SETLKW    7   /* Set record locking info, wait.  */
#if defined __USE_BSD || defined __USE_XOPEN2K
# define F_GETOWN   8   /* Get owner (receiver of SIGIO).  */
# define F_SETOWN   9   /* Set owner (receiver of SIGIO).  */
#endif

/* File descriptor flags used with F_GETFD and F_SETFD.  */
#define FD_CLOEXEC  1   /* Close on exec.  */

#ifdef __USE_GNU
# define F_DUPFD_CLOEXEC 1030   /* Duplicate file descriptor with
                   close-on-exit set.  */
#endif

#define SEEK_SET    0   /* Seek from beginning of file.  */
#define SEEK_CUR    1   /* Seek from current position.  */
#define SEEK_END    2   /* Seek from end of file.  */

extern int errno;

FILE *fopen(const char *path, const char *mode);
FILE *freopen(const char *path, const char *mode, FILE *stream);
FILE *fdopen(int fd, const char *mode);
int fclose(FILE *fp);
int fcloseall(void);
size_t fread(void *ptr, size_t size, size_t nmemb, FILE *stream);
size_t fwrite(const void *ptr, size_t size, size_t nmemb, FILE *stream);
int fseek(FILE *fp, long offset, int origin);
long ftell(FILE *stream);
void rewind(FILE *stream);

int setvbuf(FILE *stream, char *buf, int mode, size_t size);

int fputs(const char *s, FILE *stream);
int puts(const char *s);
int fputc(int c, FILE *stream);
int putc(int c, FILE *stream);
int putchar(int c);

int fgetc(FILE *stream);
char* fgets(char *s, int n, FILE *stream);
int getc(FILE *stream);
/* No gets() anymore! */
#define getchar()  fgetc(stdin)
int ungetc(int c, FILE *stream);

int scanf(const char *format, ...);
int fscanf(FILE *stream, const char *format, ...);
int sscanf(const char *str, const char *format, ...);
int vscanf(const char *format, va_list list);
int vfscanf(FILE* fp, const char *format, va_list list);
int vsscanf(const char* str, const char *format, va_list list);

int fprintf(FILE *stream, const char *format, ...);
int vfprintf(FILE *stream, const char *format, va_list ap);
int printf(const char *fmt, ...);
int vprintf(const char *fmt, va_list ap);
int snprintf(char *s, size_t size, const char *fmt, ...);
int vsnprintf(char *str, size_t size, const char *fmt, va_list va);
int sprintf(char *s, const char *format, ...);
int vsprintf(char *s, const char *format, va_list va);
int asprintf(char** strp, const char* format, ...);
int vasprintf(char** strp, const char* format, va_list ap);

int fflush(FILE *stream);
int feof(FILE *stream);
int ferror(FILE *stream);
void clearerr(FILE *stream);
int fileno(FILE *stream);

int open(const char *filename, int access, ...);
int close(int fd);
int unlink(const char *filename);

int remove(const char *filename);
int rename(const char *oldname, const char *newname);

#endif /* STDIO_H_ */
