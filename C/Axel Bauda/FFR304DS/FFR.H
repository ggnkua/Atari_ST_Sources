#include <stdio.h>

#ifndef __MSDOS__
  #ifdef MSDOS
    #define __MSDOS__
  #endif
#endif

#include <string.h>
#include <ctype.h>

#ifdef __unix__
/* flags for fopen(); temp file names */

  #define OPEN_READ_BINARY "r"
  #define OPEN_WRITE_BINARY "w"
  #define OPEN_APPEND_BINARY "a"
  #define OPEN_READ_TEXT "r"
  #define OPEN_WRITE_TEXT "w"
  #define OPEN_APPEND_TEXT "a"

/* assumed limits (hope reasonable !!!) */
  #define MAXPATH 256
  #define MAXDRIVE 16
  #define MAXDIR 256
  #define MAXFILE 32
  #define MAXEXT 32
  #define PATHSEP "/"
  #define PATHCHAR '/'
  #define EXTSEP "."
  #define EXTCHAR '.'
  #define LINESEP "\n"
  #define CONFIGFILE ".ffrrc"
  #define KILLFILE ".kill_ffr"
  #define OUTFILE ".out_ffr"
  #define MAXFNAME MAXFILE
  #define _ICMP
  #define _FNSPLIT
  #define getch my_getch

  #if __STDC__
    #include <stddef.h>
  #else
    #define const	/* nothing */
    typedef unsigned  size_t;
  #endif /* __STDC__ */

  #ifdef M_XENIX
    #define SEEK_CUR        1
    #define SEEK_END        2
    #define SEEK_SET        0
  #endif /* M_XENIX */

  #include <malloc.h>

  #ifdef __i386__
    #define SYSV
  #endif

  #ifdef SYSV
    #include <termio.h>
    struct termio sg[2];
  #else
    #include <sgtty.h>
    struct sgttyb sg[2];
  #endif

  #define ON 0
  #define OFF 1

  #ifndef fileno
    #define fileno(p)       (p)->_file
  #endif

  extern char *getenv ();
#else /* __unix__ */

/* flags for fopen(); */
  #define OPEN_READ_BINARY "rb"
  #define OPEN_WRITE_BINARY "wb"
  #define OPEN_APPEND_BINARY "ab"
  #define OPEN_READ_TEXT "r"
  #define OPEN_WRITE_TEXT "w"
  #define OPEN_APPEND_TEXT "a"

  #include <stdlib.h>
  #ifdef SCOCROSS
    #include <malloc.h>
  #else
    #ifndef __TOS__
      #include <alloc.h>
    #endif
  #endif
#endif /* __unix__ */

#ifdef __MSDOS__

  #ifdef SCOCROSS
    #define MAXPATH 256
    #define MAXDRIVE 3
    #define MAXDIR 256
    #define MAXFILE 8
    #define MAXEXT 3
  #endif

  #define PATHSEP "\\"
  #define PATHCHAR '\\'
  #define EXTSEP "."
  #define EXTCHAR '.'
  #define LINESEP "\r\n"
  #define _TWOCHARSEP
  #define MAXFNAME MAXFILE+MAXEXT-1
  #define CONFIGFILE "FFR.CFG"
  #define KILLFILE "KILL.FFR"
  #define OUTFILE "OUT.FFR"

  #include <conio.h>
  #ifdef SCOCROSS
    #define _FNSPLIT
    #include <direct.h>
  #else
    #include <dir.h>
  #endif

  #ifdef __STDC__
    #define _ICMP
  #endif

#endif

#ifdef _AMIGA_
  #define MAXPATH  300
  #define MAXDRIVE 5
  #define MAXDIR   220
  #define MAXFILE  31
  #define MAXEXT   31
  #define PATHSEP  "/"
  #define PATHCHAR '/'
  #define EXTSEP "."
  #define EXTCHAR '.'
  #define LINESEP "\n"
  #define CONFIGFILE "FFR.CFG"
  #define KILLFILE "KILL.FFR"
  #define OUTFILE "OUT.FFR"
  #define MAXFNAME MAXFILE
  #define _FNSPLIT
  #define _ICMP
  #define getch getchar
#endif

#ifdef __TOS__
  #define MAXPATH  80
  #define MAXDRIVE 3
  #define MAXDIR   66
  #define MAXFILE  9
  #define MAXEXT   5
  #define PATHSEP "\\"
  #define PATHCHAR '\\'
  #define EXTSEP "."
  #define EXTCHAR '.'
  #define LINESEP "\r\n"
  #define _TWOCHARSEP
  #define MAXFNAME MAXFILE+MAXEXT-1
  #define CONFIGFILE "FFR.CFG"
  #define KILLFILE "KILL.FFR"
  #define OUTFILE "OUT.FFR"
  #define _FNSPLIT
  #include <ext.h>
#endif

/* !! Important !! On 680X0-systems, MAXGET must be uneven !! */
#define MAXGET     83
#define MAXSEARCH  5
#define MAXMBTYPES 25
#define MAXCOTYPES 25
#define MAXMYCALLS 5
#define INFO       1
#define PROMPT     (INFO+256)
#define CODESTART  2
#define CODEEND    (CODESTART+256)
#define TEXTSTART  4
#define TEXTEND    (TEXTSTART+256)
#define WINSIZE    10
#define FALSE      0
#define TRUE       !FALSE
#define EOS        '\0'
#define LIST       1
#define KILL       2
#define EXTRACT    4

/* needed for qsort() */
typedef int (*fcmp) (const void *, const void *);

/* these types are needed to handle the different mailbox types */
struct head
{
    char *format;
    int y;
    struct head *next;
};

struct shead
{
    char *format;
    int y;
};

struct mbhead
{
  char   *type;
  char   *qtest;
  int    qtline;
  struct head *first;
  struct head *board;
  struct head *sender;
  struct head *date;
  struct prompt *begin;
  int    length;
  int    dtype;
};

struct prompt
{
  char *format;
  int  elements;
  int  len;
  int  repos;
  struct prompt *next;
};

struct code
{
  char *type;
  struct shead *qtest;
  struct head  *full;
  struct shead *name;
  struct shead *part;
  struct shead *of_parts;
  char *pform_1;
  char *pform_2;
  char *end;
  int  length;
  int  increment;
  int  codetype;
};

/* globals */
#ifdef __unix__
  extern int errno;
  extern char *sys_errlist [];
#endif
extern char *win     [];
extern char *mycall  [];
extern char *month   [];
extern char dum      [10][MAXGET+1];
extern char destnam  [];
extern char destfile [];
extern char extract  [];
extern char srcfile  [];
extern char codepath [];
extern char perspath [];
extern char genpath  [];
extern char *search  [];
extern char text     [];
extern char mbox     [];
extern int  boxtype;
extern int  codetype;
extern int  debug;
extern int  ignore;
extern int  numbers  [];
extern size_t  buflen;
extern struct mbhead mbhead[];
extern struct prompt *prompt;
extern struct code   code[];

/* function prototypes */
#ifdef _FNSPLIT
  void fnsplit (char *,char *, char *, char *, char *);
#endif

#ifdef _ICMP
  char *strupr  (char *);
  char *strlwr  (char *);
  int  stricmp  (char *, char *);
  int  strnicmp (char *, char *, int);
#endif

void get_index      (char *);
FILE *make_file     (int, int);
void make_name      (char *, int);
int  check_line     (int, int);
void kill_entries   (void);
void fraction       (int);
void count_n_write  (long *, char *, FILE *);
int  search_strings (int);
void get_parms      (char *);
void get_range      (void);
void set_win        (void);
char *read_wline    (FILE *);
void *my_malloc     (size_t);
int  comp_int       (int *, int *);
void suchbegriffe   (void);
FILE *my_fclose     (FILE *);
void get_bsd        (char *, char *, struct head *, int );
char get_month      (char *);
int qtest           (char *, int );
#ifdef _TWOCHARSEP
  void strip_cr     (char *);
#endif
void debug_out      (char *, int, int, int);
void cfg_alloc      (char **, char *, int, int);
void get_mbdefs     (int, FILE *);
void get_mbdefline  (char *, struct head **, unsigned long *, int);
void get_codefs     (int, FILE *);
void get_codefline  (char *, char **, unsigned long *, int);
void get_scodefline (char *, struct shead **, unsigned long *, int);
void get_month_ids  (FILE *);
struct prompt **get_prompts (struct prompt **, FILE *, char *);
int  elements       (char *);
void mb_errs        (unsigned long);
void co_errs        (unsigned long);
