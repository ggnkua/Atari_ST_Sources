/*---------*\
>  7plus.h  <
\*---------*/

/* Uncomment next line, if compiling on AMIGA! */
/* #define _AMIGA_ */

#define YES "yes"
#define ALWAYS "always"
#define NO  "no"
#define EOS '\0'

/* Some compilers are very strict abt the type of NULL-pointers */
#define NULLFP ((FILE *) 0)
#define NULLCP ((char *) 0)

/** these includes should work anywhere **/
#include <stdio.h>
#include <string.h>
#include <time.h>
#include <ctype.h>
#include <errno.h>
#include <limits.h>

#ifndef __TOS__
 #include <sys/stat.h>
#endif

#ifdef __M_XENIX__
 #include <malloc.h>
 #define SEEK_CUR 1
 #define SEEK_END 2
 #define SEEK_SET 0
 typedef unsigned size_t;
#else
 #include <stdlib.h>
#endif
#ifdef SYSV
 #include <unistd.h> /* not sure, if this one is really necessary */
#endif

/* flags for fopen() */
#define OPEN_READ_TEXT "r"
#define OPEN_WRITE_TEXT "w"
#define OPEN_APPEND_TEXT "a"
#define OPEN_RANDOM_TEXT "r+"
#ifdef __unix__
 #define OPEN_READ_BINARY "r"
 #define OPEN_WRITE_BINARY "w"
 #define OPEN_APPEND_BINARY "a"
 #define OPEN_RANDOM_BINARY "r+"
#else
 #define OPEN_READ_BINARY "rb"
 #define OPEN_WRITE_BINARY "wb"
 #define OPEN_APPEND_BINARY "ab"
 #define OPEN_RANDOM_BINARY "r+b"
#endif

/* Microsoft's Quick C has some different makros and function names **/
#ifdef _QC
 #define __MSDOS__
 #define MAXDRIVE _MAX_DRIVE
 #define MAXDIR   _MAX_DIR
 #define MAXFILE  _MAX_FNAME
 #define MAXEXT   _MAX_EXT
 #define MAXPATH  _MAX_PATH
 #define fnsplit  _splitpath
#endif

#ifdef __MSDOS__
 #ifdef __TURBOC__
  #include <dir.h>
  #include <io.h>
 #endif
 #include <conio.h>
 #define PATHSEP "\\"
 #define PATHCHAR '\\'
 #define INDICATE 0xdb
 #define TWO_CHAR_SEP
 #define MAXFNAME MAXFILE+MAXEXT-1
 #define _CHSIZE_OK
#endif

#ifdef _AMIGA_
 #undef  YES
 #define YES ""
 #undef  NO
 #define NO ""
 #undef ALWAYS
 #define ALWAYS ""
 #define SEEK_SET 0
 #define SEEK_CUR 1
 #define SEEK_END 2
 #define MAXPATH  300
 #define MAXDRIVE 5
 #define MAXDIR   220
 #define MAXFILE  31
 #define MAXEXT   31
 #define PATHSEP  "/"
 #define PATHCHAR '/'
 #define INDICATE '*'
 #define MAXFNAME MAXFILE
 #define _FNSPLIT
 #define _ICMP
 #define getch getchar
#endif

#ifdef __TOS__
 #define MAXPATH   119
 #define MAXDRIVE  3
 #define MAXDIR    102
 #define MAXFILE   9
 #define MAXEXT    5
 #define PATHSEP "\\"
 #define PATHCHAR '\\'
 #define TWO_CHAR_SEP
 #define INDICATE 0xdb
 #define MAXFNAME MAXFILE+MAXEXT-1
 #define _FNSPLIT
 #include <ext.h>
 /* quick & dirty, swaps upper and lower word                      */
 unsigned long swapl(unsigned long l)0x4840; /* opcode for SWAP D0 */
 /* needed for timestamp-functions    (Odo,DL1XAO)                 */
#endif

  
#ifdef __unix__
/* assumed limits (hope reasonable !!! DF6NL) */
 #define ON 0
 #define OFF 1
 #define MAXPATH 256
 #define MAXDRIVE 16
 #define MAXDIR 256
 #define MAXFILE 32
 #define MAXEXT 32
 #define PATHSEP "/"
 #define PATHCHAR '/'
 #define INDICATE '*'
 #define MAXFNAME MAXFILE
 #define _ICMP
 #define _FNSPLIT
 #define getch my_getch
 #ifdef __i386__
  #ifndef SYSV
   #define SYSV
  #endif
 #endif

 #ifdef SYSV
  #include <termio.h>
  struct termio sg[2];
 #else
  #include <sgtty.h>
  struct sgttyb sg[2];
 #endif
#endif /* __unix__ */

#define MAXFPATH MAXDRIVE+MAXDIR-1

/** shorthands for unsigned types **/
typedef unsigned char byte;  /* 8bit unsigned char       */
#ifdef __unix__
 #include <sys/types.h>
 #ifdef __vax__
   typedef u_long ulong;
 #endif
 #ifdef __M_XENIX__
   typedef unsigned long ulong;
 #endif
#else
 typedef unsigned int  uint;  /* 16 or 32bit unsigned int */
 typedef unsigned long ulong; /* 32bit unsigned long      */
#endif

struct  m_index {
  char  filename[14];  /*12  chars +2*/
  char  full_name[258];/*256 chars +2*/
  ulong length;
  ulong timestamp;
  uint  splitsize;
  ulong lines_ok[4080];
  long  lines_left;
};

/***************** function prototypes ******************/

/** 7plus.c **/
int   go_at_it       (int argc, char **argv);

/** encode.c **/
int   encode_file    (char *name, long blocksize, char *searchbin,
                                                  int part, char *head_foot);
int   read_tb        (char *name, char *go_top, char *go_bottom);
int   top_bottom     (FILE *wfile, char *top_bot, char *orgname,
                                                        int part, int parts);
/** decode.c **/
int   control_decode (char *name);
int   decode_file    (char *name, int flag);
void  decode_n_write (FILE *raus, char *p, int length);
void  w_index_err    (struct m_index *index, int flag);
int   make_new_err   (char *name);
void  progress       (char *filename, int part, int of_parts, long errors,
                                                 long rebuilt, char *status);
/* correct.c */
int   correct_meta   (char *name, int itsacor);

/** util.c **/
char  *my_fgets      (char *string, register n, FILE *rein);
int   my_putc        (int  outchar, FILE *out);
void  crc_n_lnum     (uint *crc, int *linenumber, char *line);
void  crc2           (uint *crc, char *line);
void  add_crc2       (char *line);
int   mcrc           (char *line, int flag);
int   read_index     (FILE *ifile, struct m_index *index);
int   write_index    (FILE *ifile, struct m_index *index, int flag);
ulong read_ulong     (FILE *in);
uint  read_uint      (FILE *in);
void  write_ulong    (FILE *out, ulong val);
void  write_uint     (FILE *out, uint val);
int   crc_file       (char *file, char *s1, char *s2, int flag);
int   copy_file      (char *to, char *from, ulong timestamp);
void  replace        (char *old, char *new, ulong timestamp);
void  kill_em        (char *name, char *inpath, char *one, char *two,
                                        char *three, char *four, char *five);
void  kill_dest      (FILE *in, FILE *out, char *name);
int   test_exist     (char *filename);
int   test_file      (FILE *in, char *destnam, int flag, int namsize);
void  init_decodetab (void);
void  init_codetab   (void);
void  init_crctab    (void);
void  build_DOS_name (char *name);
#if defined (__MSDOS__) || (__TOS__)
 ulong get_filetime   (FILE *_file);
 void  set_filetime   (FILE *_file, ulong ftimestamp);
#else
 #ifndef _HAVE_GMTIME
  struct tm *__offtime (const time_t *t, long int offset);
  struct tm *gmtime    (const time_t *t);
 #endif
 #ifndef _HAVE_MKTIME
  time_t    mktime     (register struct tm *tp);
 #endif
 ulong get_filetime (char *filename);
 void  set_filetime (char *filename, ulong ftimestamp);
#endif
uint  get_hex        (char *hex);
#ifdef _FNSPLIT
  void  fnsplit      (char *pth, char *dr, char *pa, char *fn, char *ft);
#endif
#ifdef _ICMP
  char  *strupr      (char *string);
  char  *strlwr      (char *string);
  char  *strcnvt     (char *string, int flag);
  int   stricmp      (const char *s1, const char *s2);
  int   strnicmp     (const char *s1, const char *s2, size_t n);
#endif

/** rebuild.c **/
int   rebuild        (char *line, int flag);

/** extract.c **/
int   extract_files  (char *name, char *search);

/** join.c **/
int   join_control   (char *file1, char *file2);
int   join_err       (char *file1, char *file2);

/** unix.c **/
#ifdef __unix__
 int       my_getch   (void);

 #ifdef __i386__
  #ifndef _HAVE_STRSTR
   char     *strstr    (const char *s1, const char *s2);
  #endif
  int      rename     (const char *s1, const char *s2);
 #endif

 #ifdef __vax__
  #ifdef __STDC__
   extern char *strdup (const char *);
  #else
   extern char *strdup ();
  #endif
 #endif

#endif
