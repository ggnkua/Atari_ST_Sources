#ifndef __Z_STAT_H
#define __Z_STAT_H
#define __STAT_H

/* Since older versions of the Lattice C compiler for Amiga, and all current */
/* versions of the Manx Aztec C compiler for Amiga, either provide no stat() */
/* function or provide one inadequate for unzip (Aztec's has no st_mode      */
/* field), we provide our own stat() function in stat.c by Paul Wells, and   */
/* this fake stat.h file by Paul Kienitz.  Paul Wells originally used the    */
/* Lattice stat.h but that does not work for Aztec and is not distributable  */
/* with this package, so I made a separate one.  This has to be pulled into  */
/* unzip.h when compiling an Amiga version, as "amiga/z-stat.h".             */

/* We also provide here a "struct direct" for use with opendir() & readdir() */
/* functions included in amiga/stat.c.  If you use amiga/stat.c, this must   */
/* be included wherever you use either readdir() or stat().                  */

/* This include file should ONLY be loaded if AZTEC_C is defined, and
 * you are using the substitute version of stat() from amiga/stat.c.
 * Bit definitions are based on those in headers for SAS/C v6.0
 */

#include <time.h>

struct stat {
    unsigned short st_mode;
    time_t st_ctime, st_atime, st_mtime;
    long st_size;
    long st_ino;
    long st_blocks;
    short st_attr, st_dev, st_nlink, st_uid, st_gid, st_rdev;
};

#define S_IFDIR  (1<<11)
#define S_IFREG  (1<<10)

#if 0
   /* these values here are totally random: */
#  define S_IFLNK  (1<<14)
#  define S_IFSOCK (1<<13)
#  define S_IFCHR  (1<<8)
#  define S_IFIFO  (1<<7)
#  define S_IFMT   (S_IFDIR|S_IFREG|S_IFCHR|S_IFLNK)
#else
#  define S_IFMT   (S_IFDIR|S_IFREG)
#endif

#define S_IHIDDEN    (1<<7)
#define S_ISCRIPT    (1<<6)
#define S_IPURE      (1<<5)
#define S_IARCHIVE   (1<<4)
#define S_IREAD      (1<<3)
#define S_IWRITE     (1<<2)
#define S_IEXECUTE   (1<<1)
#define S_IDELETE    (1<<0)

int stat(char *name, struct stat *buf);


#include <libraries/dos.h>

typedef struct direct {
    struct direct       *d_cleanuplink,
                       **d_cleanupparent;
    BPTR                 d_parentlock;
    struct FileInfoBlock d_fib;
} DIR;
#define                  d_name  d_fib.fib_FileName

extern unsigned short disk_not_mounted;         /* flag set by opendir() */

DIR *opendir(char *);
void closedir(DIR *);
void close_leftover_open_dirs(void);    /* call this if aborted in mid-run */
DIR *readdir(DIR *);

int rmdir(char *);

#  ifdef AZTEC_C
void tzset(void);
int chmod(char *filename, int bits);
#  endif

#endif /* __Z_STAT_H */
