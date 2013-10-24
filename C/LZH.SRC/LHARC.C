/*{{{  defines*/

/*************************************************
                LHarc version 1.13b (c)Yoshi, 1988-89.
                main module : 1989/ 5/14

                adaption to ATARI ST with TURBO-C 1.1
                and some corrections
                by J. Moeller 1990/01/31

                Assembly and more corrections with
                Turbo-C 1.0, 2.0, by Thomas Quester

HTAB = 4
*************************************************/

#define ThisSystem 'A'  /* Atari */

#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include <process.h>
#include <stdlib.h>
#include <setjmp.h>
#include <errno.h>
#include <tos.h>

#ifdef Japanese
#include        "usage_j.h"
#else
#ifdef German
#include        "usage_d.h"
#else
#include        "usage_e.h"
#endif
#endif
#define from extern
#ifndef __TOS__
#include <alloc.h>
#include <fcntl.h>
#include <io.h>
#include <dir.h>
#include <dos.h>
#else
#include <ext.h>
#include <tos.h>
#define MAXPATH 119
#define MAXDIR  102
#define MAXNUMFILES 128
#define far
#define huge
#define setmode(stream,mode)    /* sorry: no such function known */
#include "goodputc.h"
#endif

#define UNKNOWNERR      0
#define INVCMDERR       1
#define MANYPATERR      2
#define NOARCNMERR      3
#define NOFNERR         4
#define NOARCERR        5
#define RENAMEERR       6
#define MKTMPERR        7
#define DUPFNERR        8
#define TOOMANYERR      9
#define TOOLONGERR      10
#define NOFILEERR       11
#define MKFILEERR       12
#define RDERR           13
#define WTERR           14
#define MEMOVRERR       15
#define INVSWERR        16
#define CTRLBRK         17
#define NOMATCHERR      18
#define COPYERR         19
#define NOTLZH          20
#define OVERWT          21
#define MKDIR           22
#define MKDIRERR        23
#define CRCERR          24
#define RDONLY          25


#ifndef __TOS__
#define PAGER           "less"
#define BUFFERSIZ       4096L
#else
#define PAGER           "less.ttp"
#define BUFFERSIZ       16384L
#endif
#define MAXBLK          64
#define MAX_PAT         512
#define FAULT           0
#define SUCCS           ~FAULT

#ifndef __TOS__
#define getch() (bdos(0x08, 0, 0) & 0xff)
#endif
#define min(a,b)        ((a>b) ? b : a)
typedef unsigned char uchar;
typedef unsigned int uint;
typedef unsigned long ulong;

FILE  *file1, *file2, *file3;
from FILE *infile;
from FILE *outfile;
from int FileFits;                      /* 1, wenn File passt */
int   cmd;                              /* command */
int   cmdupdate;                        /* Not zero, when updating archive */
int   errorlevel = 0;                   /* return value */
jmp_buf exit_jmp;                       /* Jump to exit of program */
extern long  textsize;                  /* file size before compression */
extern long  codesize;                  /* file size after      compression */
from long  blocksize;                   /* Bytes bis "*" (norm. 4096) */
long  arcpos0;                          /* position pointer for archive */
uchar *basedir;                         /* base directory (home-directory) */
uchar *wdir = "";                       /* work directory */
uchar workdir[MAXPATH];                 /* work directory */
uchar *infname;                         /* input  file name (for error message) */
uchar *outfname;                        /* output file name (for error message)*/
int   attr;                             /* file attributes for search files */
int   Nfile;                            /* number of files which was found */
/* >> fbmax is used to compute the total amout used by filenames << */
ulong fblft, fbsize;
ulong fbmax,fbfiles;                    /* for buffers handling file names */
#ifndef __TOS__
uint  seg;                              /* beginning segment of file name buffers */
#endif
uchar far *fbuf, huge *fbnxt;           /* pointer to file name buffers */
uchar arcname[MAXPATH];                 /* archive name */
uchar pathname[MAXPATH];                /* work for file name (extracting) */
uchar dospathname[MAXPATH];             /* work for filename (8+3 chars)   */
uchar filename[MAXPATH];                /* work for file name (for file in archive) */
uchar comment[MAXPATH];                 /* Komments in archives */
uchar SystemId;                         /* Archiv createt on system */
uchar freezing=0;                       /* Enables extended headers */
uchar UseExthdr=0;                      /* 1, if gethdr has to use exthdrs */
int   patno;                            /* No. of path names in command line */
int   UnixFile;							/* !=0 if filename is not 8+3        */
uchar patfile[MAX_PAT][12];     /* file name in command line */
uchar *patpath[MAX_PAT];                /* directory name in command line */
int   patcnt[MAX_PAT];                  /* counts which this name matched */
uchar patnul[] = "*.*";                 /* default path name */
uchar backup1[MAXPATH], backup2[MAXPATH];            /* temporary file names */
char *TheInputBuf;                               /* Input-Buffer */
char *TheOutputBuf;
from int unpackable;
           /* temporary file names */
uchar flg_r = 0, flg_p = 0, flg_x = 0, flg_m = 0;
uchar flg_a = 0, flg_c = 0, flg_v = 0, flg_w = 0;
uchar flg_d = 0, flg_u = 0, flg_s = 0, flg_k = 0;
uchar flg_e = 0;
uchar flg_unpacked; /* Set to 1, if 100% used in pack_afx */
uchar elen=3;

from uchar flg_n = 0;
uchar flg_t = 0;
uchar flg_5 = 0;
uchar flg_arc = 0,flg_backup=0;
uchar method=5, FlgMethod=5;
#ifdef __TOS__
uchar   flg_h = 0;
#endif
                                           /* switches */
uchar copying = 0;                         /* turn on when copying temporary file */
uchar crcflg = 0;                         /* force copyfile() to calculate CRC*/
uchar tstflg = 0;                         /* turn on in 't' command */
uchar swchar;                          /* switch character */
uchar *pager = PAGER;                  /* utility used in 'p /v' mode */
from uint  crc;                          /* calculated CRC code */
uchar *keyword = "";                         /* key word for auto-execution */

struct filebuf {                         /* work for file name buffer */
        void far *next;
        uchar fpos;                          /* position of file name */
        uchar cpos;                          /* position of effective path name */
        uchar dir[MAXDIR];                 /* full path name */
} fb0, fb1;

extern char  *errmes[];                 /* array of pointers to error messages */
/* extern uchar  use[]; */                       /* usage */
extern uchar buf2[], buf3[];            /* I/O buffers */

#ifdef Japanese
/* routines for handling Japanese strings (import from util.c) */
extern uchar *j_strupr(uchar *p);
extern int        j_strcmp(char *p, char *q);
extern uchar *j_strchr(char *p, uint c);
extern uchar *j_strrchr(char *p, uint c);
extern void   slash2yen(uchar *p);                      /* convert '/' to '\' */
extern void   yen2shlas(uchar *p);

#define strupr j_strupr
#define strcmp j_strcmp
#define strchr j_strchr
#define strrchr j_strrchr
#else
extern void   slash2yen(uchar *p);                      /* convert '/' to '\' */
extern void   yen2slash(uchar *p);

/* #define slash2yen(p) */ /*
extern void slash2yen(uchar *p);                        /* convert '/' to '\' */

#endif

extern int        getfattr(uchar *fn);                  /* get file attributes */
extern void   setfattr(uchar *fn, int attr);/* set file attributes */
#ifndef __TOS__
extern uchar  getswchar(void);                          /* get switch character */
extern int test_afx(char *s);           /* šberprft, ob Datei gepackt ist */
#else
extern char *stpcpy (char *dest, char *source);
extern int mkdir (char *path);
#define getswchar() ('/')
#endif

#ifdef __TOS__
  struct outbuf
  {
    char *ptr;          /* aktuelles Zeichen */
    char *last;         /* letztes Zeichen   */
    char *base;         /* erstes Zeichen    */
    FILE *file;         /* dateiname             */
  } OutBufMem;
struct outbuf *OutBuf;

#endif __TOS__

extern void mkcrc (void);                                       /* import from 'LZS.*' */
extern void copyfile (FILE *Source, FILE *Dest, long size);
extern void Encode (void);                                      /* import from 'LZHUF.*' */
extern ulong encode5(ulong orgsize);
extern void init_encode5(void);
extern void EncodeOld(void);
extern void Decode (void);
extern void decode_lh5(ulong orgsize,ulong pacsize);
extern  void DecodeOld(void);

extern char M_NOMATCHERR[];
extern char M_COPYERR[];
extern char M_NOTLZH[];
extern char M_OVERWT[];
extern char M_MKDIR[];
extern char M_MKDIRERR[];
extern char M_CRCERR[];
extern char M_RDONLY[];

struct ftime arcstamp /* = {0L} */;     /* time stamp for archive */

struct LzHead {                                 /* file header */
        uchar HeadSiz, HeadChk, HeadID[5];
        ulong PacSiz, OrgSiz;           /* 16- and 32-bit Intel format !!!*/
        struct ftime Ftime;
        uint  Attr;
        uchar Fname[MAXPATH];           /* packed filename + crc */
} Hdr1, Hdr2;

#ifndef __TOS__
struct exeHead {                                /* EXE header for SFX */
        uint exeID, byte, page, reloc;
        uint hdrsize, minalloc, maxalloc, initSS;
        uint initSP, chksum, initIP, initCS;
        uint reloctab, overlay, dummy1, dummy2;
} ExeHdr = {
        'MZ', 0, 0, 0, 2, 0, 0xffff, 0xfff0,
        0x100, 0, 0x100, 0xfff0, 0x1e, 0, 0, 0
};
#endif

#define FTimeToUIntTime(t) ((((t.ft_hour << 6) | t.ft_min) << 5) | t.ft_tsec)
#define FTimeToUIntDate(t) ((((t.ft_year << 4) | t.ft_month) << 5) | t.ft_day)
#define FTimeToULong(t) (((ulong)FTimeToUIntDate(t) << 16) |    \
                                                 (ulong)FTimeToUIntTime(t))

uchar mksum(struct LzHead *h);

#ifdef  __TOS__
 extern int argvmain (int, uchar **, uchar **);

static DTA _mydta;
#endif __TOS__
/*}}}  */
/*{{{  setcrc:*/


#ifndef __TOS__
#define setcrc(h, crc) (*(uint *)(&(h)->Fname[1]+(h)->Fname[0])=(crc))
#define getcrc(h)          (*(uint *)(&(h)->Fname[1]+(h)->Fname[0]))
#else
static void setcrc (struct LzHead *h, uint crc)
{
                uchar *CrcPtr = &h->Fname[1] + h->Fname[0];

                *CrcPtr++ = (uchar)(crc & 0xff);
                *CrcPtr++ = (uchar)(crc >> 8);
                                *CrcPtr++ = (uchar)(ThisSystem);    /* SystemId */
                                if (freezing==0) {
/*                                *CrcPtr++ = (uchar) 0;
                                  *CrcPtr++ = (uchar) 0; */
                                }
}
/*}}}  */
/*{{{  getcrc:*/

static uint getcrc (struct LzHead *h)
{
                uchar *CrcPtr = &h->Fname[1] + h->Fname[0];

                return ((uint)*CrcPtr) | ((uint)*(CrcPtr + 1) << 8);
}
#endif
/*}}}  */
/*{{{  usage:             display helps*/
/*******************************
                display helps
*******************************/
void usage(void)
{
  int i;
  char *s,c;
  s=use;
  i=1;
  while ( (c=*s++) != 0) {
    if (c=='\n')
       if (i++ == 24) {
         fflush (stdin);                         /* wait for keystroke when used */
         printf ("\n%s",M_PRESSKEY); /* with GEM-Desktop                        */
         getch ();
         putchar ('\n');
         i=1;
    }
    putchar(c);
  }
  putchar ('\n');
  longjmp (exit_jmp, 1);
}
/*}}}  */
/*{{{  message:           Display a message*/

/*******************************
                display a message
*******************************/

void message(uchar *p, uchar *q)
{
        if (flg_d == 0) {
          printf("%s", p);
          if (q) {
                  printf(" : '%s'", q);
          }
          printf("\n");
        }
}
/*}}}  */
/*{{{  error:             process for an error*/

/*******************************
        process for an error
*******************************/
void error(int errcode, uchar *p)
{
        if (copying) {                                          /* error during copying temporary? */
                fprintf(stderr, "\n%s\n", M_COPYERR);
                fclose(file1);
                unlink(arcname);                                /* erase incomplete archive */
                file1 = NULL;
        }
        fprintf(stderr, "\n%s", errmes[errcode]);
        if (p) {
                fprintf(stderr, " : '%s'", p);
        }
        fprintf(stderr, "\n");
        if (file3) {
                fclose(file3);
                if (!cmdupdate)                                 /* during extracting */
                        unlink(pathname);                       /* delete the file */
                        file3=NULL;
        }
        if (file1) {
                fclose(file1);
                if (cmdupdate)                                  /* during updating */
                        rename(backup1, arcname);       /* recover old archive */
        }
        if (file2) {
                fclose(file2);
                if (!copying) {                                 /* if not copying */
                        unlink(backup2);                        /* delete temporary */
                        file2=NULL;
                }
        }
        if (copying)
                errorlevel = 3;
        else
                errorlevel = 2;
        longjmp (exit_jmp, 1);
}

/*}}}  */
/*{{{  userbreak:         handle user break*/
/*******************************
                handle user break
*******************************/
#ifndef __TOS__
void userbreak(void)
{
        error(CTRLBRK, NULL);
}
#endif
/*}}}  */
/*{{{  e_fopen:           fopen with detecting error*/

/*******************************
        fopen with detecting error
*******************************/
FILE *e_fopen(uchar *fname, uchar *mode, int errID)
{
        FILE *f;

        if ((f = fopen(fname, mode)) == NULL) {
                if (errno == EACCES)
                        error(RDONLY, fname);
                error(errID, fname);
        }
        return f;
}
/*}}}  */
/*{{{  e_rename:          rename with detecting erorr*/

/*******************************
        rename with detecting error
*******************************/
void e_rename(uchar *old, uchar *new)
{
        if (rename(old, new))
                error(RENAMEERR, old);
}
/*}}}  */
/*{{{  getyn:             ask 'Y' or 'N'*/
/*******************************
                ask 'Y' or 'N'
*******************************/
uint getyn(void)
{
        uint yn;

        do {
                yn = toupper(getch());
#ifdef German
        } while (yn != 'J' && yn != 'N');
#else
        } while (yn != 'Y' && yn != 'N');
#endif
        fprintf(stderr, "%c\n", yn);
#ifdef German
        if (yn == 'J') yn = 'Y';
#endif
        return yn;
}
/*}}}  */
/*{{{  getynr:            ask 'Y', 'N' or 'R'*/
/*******************************
                ask 'Y' or 'N'
*******************************/
uint getynr(void)
{
        uint yn;

        do {
                yn = toupper(getch());
#ifdef German
        } while (yn != 'J' && yn != 'N' && yn != 'R');
#else
        } while (yn != 'Y' && yn != 'N' && yn != 'R');
#endif
        fprintf(stderr, "%c\n", yn);
#ifdef German
        if (yn == 'J') yn = 'Y';
#endif
        return yn;
}
/*}}}  */
/*{{{  extfn:             File name -> internal format*/

/*******************************
  file name -> internal format
*******************************/
void extfn(uchar *p, uchar *pb)
{
        int i;
        uchar * q;

        if ((q = strrchr(p, '\\')) != NULL ||
                (q = strchr(p, ':')) != NULL)
                p = q + 1;
        q = p;
        for (i = 8; i > 0; i--, pb++) {
                switch (*p) {
                case '*':
                        *pb = '?';
                        break;
                case '.':
                case '\0':
                        *pb = ' ';
                        break;
                default:
                        *pb = *p++;
                }
        }
        while (+(*p != '\0' && *p++ != '.'));
        for (i = 3; i > 0; i--, pb++) {
                switch (*p) {
                case '*':
                        *pb = '?';
                        break;
                case '\0':
                        *pb = ' ';
                        break;
                default:
                        *pb = *p++;
                }
        }
        *q = *pb = '\0';
}
/*}}}  */
/*{{{  packfn:            internal format -> file name*/

/*******************************
  internal format -> file name
*******************************/
void packfn(uchar *p, uchar *q)
{
        int i;

        for (i = 8; i > 0; i--) {
                if (*q != ' ')
                        *p++ = *q;
                q++;
        }
        *p++ = '.';
        for (i = 3; i > 0; i--) {
                if (*q != ' ')
                        *p++ = *q;
                q++;
        }
        if (p[-1] == '.')
                p--;
        *p = '\0';
}
/*}}}  */
/*{{{  backpath           get back to parent directory*/
/*******************************
  get back to parent directory
*******************************/
uchar *backpath(uchar *p)
{
        uchar *q;

        if ((q = strrchr(p, '\\')) == NULL &&
                (q = strchr(p, ':')) == NULL) {
                *p = '\0';
                q = p;
        } else {
                *++q = '\0';
        }
        return q;
}
/*}}}  */
/*{{{  tstpat :           whether path name was used or not*/

/***********************************
  whether path name was used or not
***********************************/
void tstpat(void)
{
        int i, cnt;
        uchar path[MAXPATH];

        cnt = 0;
        for (i = 0; i < patno; i++)
                cnt += patcnt[i];
        if (cnt == 0)                                           /* no file matched */
                error(NOFILEERR, NULL);
        for (i = 0; i < patno; i++) {
                if (patcnt[i] == 0) {                   /* if any path name was not used */
                        packfn(stpcpy(path, patpath[i]), patfile[i]);
                        fprintf(stderr, "%s : '%s'\n", M_NOMATCHERR, path);
                        errorlevel = 1;                         /* display warning */
                }
        }
}
/*}}}  */
/*{{{  sethdr:            make a file header*/

/*******************************
                make a file header
*******************************/
void sethdr(uchar *fn, uint attr, struct LzHead *h)
{
        uint l;

        memset(h, 0, sizeof(struct LzHead));
        l = (uint)strlen(fn);                                           /* length of file name */
        h -> Fname[0] = l;
        memcpy(h -> Fname + 1, fn, l);
        l += 20 +  elen +2;                                        /* size of header */
        h -> HeadSiz = l;
        fseek(file3, 0L, SEEK_END);
        h -> OrgSiz = textsize = ftell(file3);  /* original size of a file */
        h -> PacSiz = codesize = 0;
        method=FlgMethod;
/*        if (h->OrgSiz < 5000 && FlgMethod==5) method=1; */
        rewind(file3);
        getftime(fileno(file3), &(h -> Ftime)); /* get time stamp */
        h -> Attr = attr;                                       /* file attributes */
        if (method==0) memcpy(h->HeadID,"-lz5-",5);
        if (method==1) memcpy(h->HeadID,"-lh1-",5);
            if (method==5) memcpy(h->HeadID,"-lh5-",5);
            if (cmd== 'C') memcpy(h->HeadID,"-afx-",5);
}
/*}}}  */
/*{{{  wthdr680x0:        write a file header on atari (or any system)*/

#ifdef __TOS__
/*******************************
        write a file header on
        Atari ST (680x0)
*******************************/
int wthdr680x0 (register struct LzHead *h,
                                FILE *file)
{
        uchar buffer [256];
        uchar chksum,*ptr2;
        int comlen;
        register uchar *ptr,*co,*ptr1;
        union { uint x;
                        uchar bytes [2]; } swap16;
        union { ulong x;
                        uchar bytes [4]; } swap32;

        register int i;
        int len;
        char c;

        if (comment[0] == 0) comlen = 0; else
                           { comlen = 4 + strlen(comment);
                             h->PacSiz += comlen; }
        if (flg_s) yen2slash(&(h->Fname));
        h -> HeadChk = mksum(h);                        /* header sum */

        ptr = buffer;
        *ptr++ = h->HeadSiz;
        *ptr++ = h->HeadChk;
        for (i = 0; i < 5; i++)
                *ptr++ = h->HeadID [i];
        swap32.x = h->PacSiz;
        for (i = 3; i >= 0; i--)                 /* convert motorola --> intel */
                *ptr++ = swap32.bytes [i];
        swap32.x = h->OrgSiz;
        for (i = 3; i >= 0; i--)                 /* convert motorola --> intel */
                *ptr++ = swap32.bytes [i];
        swap32.x = FTimeToULong (h->Ftime);
        for (i = 3; i >= 0; i--)                 /* convert motorola --> intel */
                *ptr++ = swap32.bytes [i];
        swap16.x  = h->Attr;
        for (i = 1; i >= 0; i--)                 /* convert motorola --> intel */
                *ptr++ = swap16.bytes [i];
        len = *ptr++ = h->Fname [0];
        for (i = 1; i <= len + elen+2; i++) *ptr++ = h->Fname[i];
        if (freezing && flg_k==0) {
          ptr2=ptr-1;
          if (comlen) {
          ptr-=2;
          *ptr++=comlen;
          *ptr++=0;
            *ptr++=0x3f;
            co=comment;
            while (*co) *ptr++=*co++;
            *ptr++=0xff;
            *ptr++=0x0;
            *ptr++=0x0;
          }
          ptr1=&buffer[2];
          chksum=0;
          while (ptr1 != ptr2)
             chksum = chksum + *ptr1++;
          buffer[1]=chksum;
          len = (int) fwrite (buffer, ptr-buffer  , 1, file);
        } else
          len = (int) fwrite (buffer, h->HeadSiz +2  , 1, file);


        /* slash2yen(&(h->Fname)); */
        h -> HeadChk = mksum(h);                        /* header sum */
        return len;
}
#endif
/*}}}  */
/*{{{  wthdr:             write a file header*/

/*******************************
        write a file header
*******************************/
void wthdr(struct LzHead *h)
{
        arcpos0 = ftell(file2);         /* memorize this position */
#ifndef __TOS__
        if (fwrite(h, h -> HeadSiz + 2, 1, file2) == 0)
                error(WTERR, backup2);
#else
        if (wthdr680x0 (h, file2) == 0)
                error(WTERR, backup2);
#endif
}
/*}}}  */
/*{{{  mksum:             calculate check-sum*/
/*******************************
  calculate check-sum of header
*******************************/
uchar umksum(struct LzHead *h)
{
        uchar *p, *q;
        uchar i;

        p = (uchar *)h ;
        q = p + h -> HeadSiz;
        p+=2; q+=2;
        for (i = 0; p < q; p++)
                i += *p;
        return i;
}

#ifndef __TOS__
uchar mksum(struct LzHead *h)
{
        uchar *p, *q;
        uchar i;

        p = (uchar *)h + 2;
        q = p + h -> HeadSiz;
        for (i = 0; p < q; p++)
                i += *p;
        return i;
}
#else
uchar mksum(struct LzHead *h)
{
        union { uint x;
                        uchar bytes [2]; } swap16;
        union { ulong x;
                        uchar bytes [4]; } swap32;
        char *s;
        register uchar sum;
        register int i;
        int len;

        sum = 0;
        for (i = 0; i < 5; i++)
                sum += h->HeadID [i];
        swap32.x = h->PacSiz;
        for (i = 3; i >= 0; i--)
                sum += swap32.bytes [i];
        swap32.x = h->OrgSiz;
        for (i = 3; i >= 0; i--)
                sum += swap32.bytes [i];
        swap32.x = FTimeToULong (h->Ftime);
        for (i = 3; i >= 0; i--)
                sum += swap32.bytes [i];
        swap16.x = h->Attr;
        for (i = 1; i >= 0; i--)
                sum += swap16.bytes [i];
        sum += h->Fname [0];
        len = (int) h->Fname [0];
        s=h->Fname; s++;
        for (i = 1; i <= h->HeadSiz - 20; i++)
                sum += *s++;

        return sum;
}
#endif
/*}}}  */
/*{{{  remkhdr:           remake file header and write*/

/*******************************
        remake file header & write
*******************************/
void remkhdr(struct LzHead *h)
{
        int flg;
        long arcpos1;

        flg = 0;
        h -> PacSiz = codesize;                         /* packed size of a file */
                setcrc (h, crc);
        flg_unpacked=0;
        if (h -> OrgSiz <= codesize && flg_5==0) {          /* if packed size >= original size */
                flg = 1;                                                /* select method "simple copy" */
                flg_unpacked=1;
                memcpy(h->HeadID,"-lh0-",5);
                h -> PacSiz = h -> OrgSiz;
        }
        h -> HeadChk = mksum(h);                        /* header sum */

        if (flg_u && flg_5 == 0) {                                   /* without compression */
                crcflg=1; crc=0;
                copyfile(file3, file2, h -> OrgSiz);    /* do simple copy */
                flg = 0;
                setcrc(h,crc);
        }
        arcpos1 = ftell(file2);                         /* memorize this position */
        fseek(file2, arcpos0, SEEK_SET);        /* seek to header */
#ifndef __TOS__
        fwrite(h, h -> HeadSiz + 2, 1, file2); /* rewrite header */
#else
        wthdr680x0 (h, file2);
#endif
        if (flg && flg_5 == 0) {
                rewind(file3);
                copyfile(file3, file2, h -> OrgSiz);    /* do simple copy */
        } else {
                fseek(file2, arcpos1, SEEK_SET);                /* return to the end */
        }
}
/*}}}  */
/*{{{  rdhdr680x0:        read a file header on Atari*/
#ifdef __TOS__
/*******************************
        read a file header on
        Atari ST (680x0)
*******************************/
int rdhdr680x0 (register struct LzHead *h,
                                FILE *file)
{
        uchar buffer [sizeof (struct LzHead)];
        register uchar *ptr;
        union { uint x;
                        uchar bytes [2]; } swap16;
        union { ulong x;
                        uchar bytes [4]; } swap32;
        register int i;
        int len;

        if ((h -> HeadSiz = getc (file)) <= 0 ||
                ferror (file) ||
                h->HeadSiz > sizeof buffer - 1 ||
                fread (buffer, (int) h->HeadSiz + 1, 1, file) == 0)
         {
                return FAULT;
         }

        ptr = buffer;
        h->HeadChk = *ptr++;
        for (i = 0; i < 5; i++)
                h->HeadID [i] = *ptr++;
        for (i = 3; i >= 0; i--)                 /* convert intel --> motorola */
                swap32.bytes [i] = *ptr++;
        h->PacSiz = swap32.x;
        for (i = 3; i >= 0; i--)                 /* convert intel --> motorola */
                swap32.bytes [i] = *ptr++;
        h->OrgSiz = swap32.x;
        for (i = 3; i >= 0; i--)                 /* convert intel --> motorola */
                swap32.bytes [i] = *ptr++;
        h->Ftime.ft_tsec  = (uint)(swap32.x & 0x1f);
        h->Ftime.ft_min   = (uint)((swap32.x >>  5) & 0x3f);
        h->Ftime.ft_hour  = (uint)((swap32.x >> 11) & 0x1f);
        h->Ftime.ft_day   = (uint)((swap32.x >> 16) & 0x1f);
        h->Ftime.ft_month = (uint)((swap32.x >> 21) & 0x0f);
        h->Ftime.ft_year  = (uint)((swap32.x >> 25) & 0x7f);
        for (i = 1; i >= 0; i--)                 /* convert intel --> motorola */
                swap16.bytes [i] = *ptr++;
        h->Attr = swap16.x;
        for (i=0;i<=MAXPATH;i++) h->Fname[i]=0;
        len = h->Fname [0] = *ptr++;
        for (i = 1; i <= h->HeadSiz - 20; i++)
                h->Fname [i] = *ptr++;

        return SUCCS;
}
#endif
/*}}}  */
/*{{{  gethdr :           get a file header*/
/*******************************
                get a file header
*******************************/
uchar *gethdr(FILE *arc, struct LzHead *h)
{
        uchar *q,*p,*p1, i;
        uint extsize;
        char exthdr[256];
        char fname[256];

#ifndef __TOS__
        if ((h -> HeadSiz = getc(arc)) <= 0 ||
                h -> HeadSiz > sizeof(struct LzHead) - 3 ||
                fread(&(h -> HeadChk), h -> HeadSiz + 1, 1, arc) == 0)
        {                                                               /* read file header */
                return NULL;
        }
#else
        if (!rdhdr680x0 (h, arc))
                return NULL;
#endif
        if (mksum(h) != h -> HeadChk)
           if (umksum(h) != h -> HeadChk) /* if sum is wrong */
                 return NULL;
        i = *(h -> Fname);
        strncpy(filename, h -> Fname + 1, i);
        *(filename + i) = '\0';

                if ( (flg_k == 0) && UseExthdr) {
          extsize=h->Fname[h->Fname[0]+4];
          SystemId = h->Fname[h->Fname[0]+3];
          comment[0] = 0; /* Prevent showing an illegal comment */
          if (extsize != 0) {
                fread(exthdr,1,extsize-2,arc);
/*                      h->PacSiz-=extsize;
                        extsize=fgetc(arc);
                        extsize+=(uint)fgetc(arc)<<8; */
            while (extsize != 0) {
                     if (exthdr[0] == 2) { /* pathname-header */
                        p=fname; p1=&exthdr[1];
                        while ( (*p++=*p1++) != 0xff);
                        p--;
                        *p++='\\';
                        strcpy(p,filename);
                        strcpy(filename,fname);
                     }
                     if (exthdr[0] == 0x3f) { /* Komment - Header */
                       p=comment;p1=&exthdr[1];
                       while ((*p++=*p1++) != 0xff); p--; *p=0;
                     }

                           h->PacSiz-=extsize;
                           extsize=fgetc(arc);
                           extsize+=(uint)fgetc(arc)<<8;

                   if (extsize) {
                 if (extsize > 250) {
                   fseek(arc,extsize-2,SEEK_CUR); /* Header to long, skip */
                   exthdr[0]=255; }
                 else {
                             fread(exthdr,1,extsize-2,arc);
                              }
                          }

           }
         }
                }
        if ((q = strrchr(filename, '\\')) == NULL &&
            (q = strrchr(filename, '/')) == NULL  &&
            (q = strchr(filename, ':')) == NULL)
                q = filename;
        else
                q++;
        return q;                                       /* return the portion of file name */
}
/*}}}  */
/*{{{  matchpat:          test match of file name*/
/*******************************
        test match of file name
*******************************/
int matchpat(uchar *p)
{
        uchar buf[12], name[MAXPATH];
        int i, j, retcode;

        retcode = FAULT;
        strcpy(name, p);
        extfn(name, buf);
        for (i = 0; i < patno; i++) {
                if (flg_p || *patpath[i]) {     /* should compare full path ? */
                        if (strcmp(name, patpath[i]))
                                continue;
                }
                for (j = 0; j < 11; j++) {              /* compare file name */
                        if (patfile[i][j] != buf[j] && patfile[i][j] != '?')
                        break;
                }
                if (j == 11) {                                  /* if matched */
                        patcnt[i]++;
                        retcode = SUCCS;
                }
        }
        return retcode;
}
/*}}}  */
/*{{{  ratio:             ratio * 1000*/
/*******************************
                ratio * 1000
*******************************/
uint ratio(ulong a, ulong b)
{
        int i;

        if (!b) return 0;                       /* if diviser == 0 */
        for (i = 0; i < 3 && a < 0x19999999L; i++) {
                a *= 10;                                /* while not overflow */
        }                                                       /* upto 1000 times */
        for (; i < 3; i++) {            /* the case of overflow */
                b /= 10;
        }
        a += b / 2;                             /* for round up */
        return (uint)(a / b);           /* return (a * 1000 / b) */
}
/*}}}  */
/*{{{  cmpname:           compare names*/
/*******************************
                compare names
*******************************/
int cmpname(uchar *f0, uchar *f1, uchar *p0, uchar *p1)
{
        int c;

        c = strcmp(f0, f1);                     /* compare only file names */
        if (c == 0) {
                c = (int)(strlen(p0) - strlen(p1)); /* compare lengths of path names */
                if (c == 0) {
                        c = strcmp(p0, p1);     /* compare path names */
                }
        }
        return c;
}
/*}}}  */
/*{{{  regfile:           regist file names*/
/*******************************
        regist file names
*******************************/
int regfile(uchar *p, uchar *q, uchar *f, int attrib)
/*
        p: full path name including base directory
        q: directory name to be registed
        f: file name
*/
{
        uchar path[MAXPATH];
        struct filebuf far *f0;
        struct filebuf far *f1;
        uchar *s;
        int c,size;

        if (flg_arc)
             if ((attrib & 0x20) == 0) return 0;

        if (strstr(f, "LHARC.)1(") || strstr(f, "LHARC.)2("))
                return 0;                                 /* temporary file ? */
        stpcpy(stpcpy(path, q), f);
        stpcpy(s = stpcpy(fb1.dir, p), f);
        fb1.fpos = s - (uchar *)&fb1;
        fb1.cpos = flg_x ? (q - p) + (fb1.dir - (uchar *)&fb1) : fb1.fpos;
        if (fbuf == NULL) {                     /* for first entry */
        fbfiles=0;                              /* >> Number of files matched << */
#ifndef __TOS__
                if (allocmem(fbsize = 0x100, &seg) != -1)
                        error(MEMOVRERR, NULL);
                fbuf = (uchar far *)fbnxt = MK_FP(seg, 0);
                fbleft = 0x100;

#else
/* >> get all the memory. fbmax holds the number of bytes available << */
                fbsize=sizeof(struct filebuf) * MAXNUMFILES;
                fbmax= (long) Malloc(-1);
                fbuf = fbnxt = Malloc(fbmax);
                if (fbuf == NULL)
                        error(MEMOVRERR, NULL);
                fblft = fbmax;
#endif
                *(long far *)fbuf = 0;
                fbnxt += 4;
        }
        f0 = (struct filebuf far *)fbuf;
        do {                                    /* search position in which should be inserted*/
                f1 = f0;
                if ((f0 = f0 -> next) == NULL)
                        break;
                fb0 = *f0;
                c = cmpname((uchar *)&fb0 + fb0.fpos, (uchar *)&fb1 + fb1.fpos,
                                        (uchar *)&fb0 + fb0.cpos, (uchar *)&fb1 + fb1.cpos);
        } while (c < 0);

        if (f0 && c == 0 && strcmp(fb0.dir, fb1.dir)) {
                error(DUPFNERR, (uchar *)&fb1 + fb1.cpos);
        }                                               /* same registing names of different files */

        if (f0 == NULL || c) {                          /* do regist */
                size = (int)(strlen(fb1.dir) +
                                         (fb1.dir - (uchar *)&fb1)) + 1;
#ifndef __TOS__
                if (fblft < sizeof(struct filebuf)) {   /* if buffer is short */
                        if (setblock(seg, fbsize += 0x100) != -1)
                                error(TOOMANYERR, NULL);
                        fblft += 0x100;
                }
#else
                size += size & 1;               /* size must be even to avoid address error! */
                if (fblft < sizeof (struct filebuf))
                        error(TOOMANYERR, NULL);
#endif
                fb1.next = f0;
                f0 = (struct filebuf far *)fbnxt;
                f1 -> next = f0;
                *f0 = fb1;
                fblft -= size;
                fbnxt += size;
                fbfiles++;              /* >> Count files << */
        }
 return 1;
}
/*}}}  */
/*{{{  travel:            recursive collection of files*/
/*******************************
  recursive collection of files
*******************************/
int travel(uchar *p, uchar *q, uchar *f)
{
        struct ffblk ffb;
        static uchar buf[12];
        uchar *r, *s;
        int done, cnt, j;

        cnt = 0;
        if (flg_r == 1 || strrchr(q, '\\') == q + strlen(q) - 1) {
                stpcpy(s = q + strlen(q), "*.*");
        }
        done = findfirst(p, &ffb, attr);        /* search the first file */
        s = backpath(q);
        while (! done) {
                if (ffb.ff_attrib & 0x10) {     /* if this is a sub-directory */
                        if (ffb.ff_name[0] != '.') {
                                r = stpcpy(stpcpy(s, ffb.ff_name), "\\");
                                if (r - p > MAXPATH)
                                        error(TOOLONGERR, p);
                                cnt += travel(p, q, f); /* search recursively */
                                *s = '\0';
                        }
                } else                                                  /* if this is a file */
                if (flg_r == 2) {                               /* in /r2 mode */
                        cnt += regfile(p, q, ffb.ff_name,ffb.ff_attrib);                 /* regist name */
                } else {                                                /* in /r+ mode */
                        stpcpy(s, ffb.ff_name);
                        extfn(s, buf);
                        for (j = 0; j < 11; j++) {                      /* test file names */
                                if (f[j] != buf[j] && f[j] != '?')
                                break;
                        }
                        if (j == 11) {
                                cnt += regfile(p, q, ffb.ff_name,ffb.ff_attrib);         /* if match, regist */
                        }
                }
                done = findnext(&ffb);
        }
        return cnt;                                             /* number of registed files */
}
/*}}}  */
/*{{{  findfile:          non-recursive collection of files*/
/**********************************
 non-recursive collection of files
**********************************/
int findfile(uchar *p, uchar *q)
{
        struct ffblk ffb;
        int done, cnt;

        cnt = 0;
        done = findfirst(p, &ffb, attr);
        backpath(p);
        while (! done) {
                cnt += regfile(p, q, ffb.ff_name,ffb.ff_attrib);
                done = findnext(&ffb);
        }
        return cnt;
}
/*}}}  */
/*{{{  mklilst:           make file list to append*/
/*******************************
        make file lists to append
*******************************/
void mklist(void)
{
        uchar path[MAXPATH], *p, *q, *r;
        int i, cnt;

        Nfile = 0;
        if (flg_a) {                                            /* set attributes for search */
                attr = 0x07;
        } else {
                attr = 0;
        }
        if (flg_r) {
                attr |= 0x10;
        }
        for (i = 0; i < patno; i++) {
                p = patpath[i];
                q = path;
                if (*p && p[1] == ':') {                /* if path name includes drive */
                        q = stpcpy(path, p);                    /* ignore base directory */
                        r = path + 2;                                   /* don't regist drive name */
                } else {
                        q = stpcpy(r = stpcpy(path, basedir), p);
                }
                if (flg_r == 1) {                               /* /r+ mode */
                        cnt = travel(path, r, patfile[i]);
                } else if (flg_r > 1) {                 /* /r2 mode */
                        packfn(q, patfile[i]);
                        cnt = travel(path, r, NULL);
                } else {                                                /* /r- mode */
                        packfn(q, patfile[i]);
                        cnt = findfile(path, r);
                }
                Nfile += patcnt[i] = cnt;
        }

#ifdef __TOS__
/* >> After registering all files, free the unused memory << */
        Mshrink(0,fbuf,fbmax-fblft+5);
        if (flg_d == 0) printf("Files matched: %ld\n",fbfiles);
#endif
}
/*}}}  */
/*{{{  mkhdr:             make file header*/
/*******************************
                make file header
*******************************/
uchar *mkhdr(struct filebuf far *f, struct LzHead *h)
{
        int attr;

        fb0 = *f;
        attr = getfattr(fb0.dir);
        file3 = e_fopen(fb0.dir, "rb", RDERR);

        sethdr((uchar *)&fb0 + fb0.cpos, attr, h);
        return (uchar *)&fb0 + fb0.fpos;        /* position of file name */
}

extern uint blkcnt;
uint curcnt;
uint nxtcnt;
/*}}}  */
/*{{{  blkdisp:           calculate and display*/
/*******************************
        calculate and display
                for indicator
*******************************/

void blkdisp(long l, char *s) {
        uint i;

        if (flg_n == 0) {
                blocksize=4096;
                printf("\n  %s :  ", s);
                blkcnt = (uint)((l + 4095) / 4096);
                if (blkcnt > MAXBLK) {
                        blkcnt = MAXBLK;
                        blocksize= l / MAXBLK;
                }
                i = blkcnt;
                while (i-- > 0) {
                        putchar('.');
                }
                printf("\r   %s :  ", s);
                curcnt = nxtcnt = 0;
        } else {
                curcnt = 0;
                nxtcnt = -1;
        }
}
/*}}}  */
/*{{{  curback:           let cursor back after displaying indicator*/

/*******************************
        let cursor back after
        displaying indicator
*******************************/
void curback(void)
{
        if (flg_n == 0) {
                printf("\r  ");
        }
}
/*}}}  */
/*{{{  MKinputbuf:        make buffers for reading*/

/* Try to read the complete file. If the position is odd, begin reading at */
/* an even position and dicard one byte                                    */

void MKinputbuf(long filesize)
{
   long bufsize;
   long Pos;

       bufsize=(long)Malloc(-1)-50000;
   if (bufsize < 0) bufsize=8192;
   bufsize=min(filesize,bufsize)+1024;
   TheInputBuf=(char *) Malloc(bufsize+2);
   if (TheInputBuf < 0) error(MEMOVRERR,NULL);
   if (TheInputBuf>0) {
      if ((bufsize & 1) == 1) bufsize--;        /* Make bufsize even */
      if ((ftell(infile) & 1) == 1) {           /* Odd position     */
          fseek(infile,ftell(infile)-1,0);         /* go to even pos.   */
          setvbuf(infile,TheInputBuf,   _IOFBF, bufsize); /* set buffer */
          getc(infile);                         /* fill buffer, dicard char */
       } else
       {   fseek(infile,ftell(infile),0);           /* even position is ok */
           setvbuf(infile,TheInputBuf,  _IOFBF, bufsize);
       }
       FileFits=1;                               /* signal file fits into mem */
   } else FileFits=0;


}
/*}}}  */
/*{{{  mkoutboutb         Make buffers for writing*/

void MKoutputbuf( void )
{
   long bufsize;
   char *start,ende;
   bufsize=(long)Malloc(-1)-20000;
   TheOutputBuf=Malloc(bufsize);
   fseek(outfile,ftell(outfile),0);
   if (TheOutputBuf>0) {
        setvbuf(outfile,TheOutputBuf,_IOFBF,bufsize);
    } else {
        setvbuf(outfile,buf3,_IOFBF,BUFFERSIZ);
    }
}
/*}}}  */
/*{{{  freeze:            freeze a file*/


/*******************************
                freeze a file
*******************************/
void freeze(uchar *p)
{
        char *hp;
        char iname[128];
        if (FTimeToULong (arcstamp) < FTimeToULong (Hdr2.Ftime))
                arcstamp = Hdr2.Ftime;
        strcpy(iname,p);

    freezing=1;
    if (flg_d == 0) printf("%s ", p);
    if (flg_e) { /* Enter comment THQ */
            printf("\n");
        printf(M_COMMENT);
        gets(comment);
    }

    if (method!=5)
                blkdisp(Hdr2.OrgSiz,   "Freezing ");
        else
        blkdisp(Hdr2.OrgSiz/2, "Freezing ");


    wthdr(&Hdr2);
        if (method == 5) init_encode5();
        setvbuf(file3, buf3, _IOFBF, BUFFERSIZ);
        infile = file3;
        outfile = file2;
        MKinputbuf(Hdr2.OrgSiz);
        infname = p;
        textsize = Hdr2.OrgSiz;
        crc = 0;
            codesize=0;
        if (flg_u) codesize = Hdr2.OrgSiz + 1; else {
                if (method==0) EncodeOld();
                if (method==1) Encode();
                if (method==5) codesize=encode5(Hdr2.OrgSiz);
        }
        fflush(outfile);

        fseek(infile,ftell(infile),0);
        setvbuf(file3,buf3,_IOFBF,BUFFERSIZ);
        fseek(file2,0,SEEK_END);

        Mfree(TheInputBuf);

        if (flg_backup)
             Fattrib(iname,1,Fattrib(iname,0,0) & 0xff-0x20);
        remkhdr(&Hdr2);
        curback();
        if (flg_d == 0) printf("Frozen(%3d%%) \n", ratio(Hdr2.PacSiz, Hdr2.OrgSiz) / 10);
        comment[0] = 0;
        freezing=0;
}
/*}}}  */
/*{{{  copyold:           copy file from old archiv*/


/*******************************
                Copy a file from
                        old archive
*******************************/
void copyold(void)
{
        if (FTimeToULong (arcstamp) < FTimeToULong (Hdr1.Ftime))
                arcstamp = Hdr1.Ftime;
        wthdr(&Hdr1);                           /* copy from old archive */
        copyfile(file1, file2, Hdr1.PacSiz);
}
/*}}}  */
/*{{{  execappend:        execute one of a, u, m commands*/

/*******************************
        execute one of a, u, m
                commands
*******************************/
int execappend(void)
{
        struct filebuf far *f0;
        uchar *p, *q;
        int c, d;
        int cnt = 0;

        q = file1 ? gethdr(file1, &Hdr1) : NULL;        /* read header from old arc */
        if ((f0 = ((struct filebuf far *)fbuf) -> next) != NULL) {
                p = mkhdr(f0, &Hdr2);                   /* make header from the file list */
        }
        while (1) {
                if (f0 == NULL) {
                        d = 1;
                        if (q == NULL)
                                break;
                } else if (q == NULL) {
                        d = -1;
                } else {
                        d = cmpname(p, q, (uchar *)&fb0 + fb0.cpos, filename);
                }
                c = d;
                if (c == 0) {
                        if (flg_c || FTimeToULong (Hdr1.Ftime) <
                                                 FTimeToULong (Hdr2.Ftime)) {
                                c = -1;
                        } else {
                                c = 1;
                        }
                }
                if (c < 0) {                                    /* freeze a new file */
                        if (d == 0) {
                                fseek(file1, Hdr1.PacSiz, SEEK_CUR);
                                q = gethdr(file1, &Hdr1);               /* skip a file in old */
                        }                                                                       /* archive */
                        freeze(fb0.dir);
                        fclose(file3);
                        cnt++;
                        if ((f0 = fb0.next) != NULL) {          /* make header of the next */
                                p = mkhdr(f0, &Hdr2);                   /* file in file list */
                        }
                } else {                                                /* copy a file from old archive */
                        if (d == 0) {
                                fclose(file3);
                                if ((f0 = fb0.next) != NULL) {  /* make header of the next */
                                        p = mkhdr(f0, &Hdr2);           /* file in file list */
                                }
                        }
                        copyold();
                        q = gethdr(file1, &Hdr1);                       /* get the next header */
                }                                                                               /* in old archive */
        }
        return cnt;
}
/*}}}  */
/*{{{  delfile:           delete files after execution of updating in 'm' command*/

/*******************************
        delete files after
        execution of updating
        in 'm' command
*******************************/
void delfile(void)
{
        struct filebuf far *f0;
        struct filebuf fb0;

        f0 = (struct filebuf far *)fbuf;
        while ((f0 = f0 -> next) != NULL) {
                fb0 = *f0;
                unlink(fb0.dir);
        };
}
/*}}}  */
/*{{{  openarc1:          open an old archiv*/

/*******************************
        open an old archive
*******************************/
void openarc1(void)
{
        uchar *p, *q;

        file1 = e_fopen(infname = arcname, "rb", NOARCERR);
/* >> Because some SFX-Versions for the ST have a header bigger 2048 Bytes
      4096 bytes are read here << */
        q = buf2 - 5 + fread(buf2, 1, 4096, file1);
        for (p = buf2; p < q; p++) {
                if (p[0] == '-' && p[4] == '-')
                 if (p[1] == 'l' || p[1] == 'a') break;
        }
        if (p >= q) {
                error(NOFILEERR, arcname);
        }
        fseek(file1, (long)(p - buf2 - 2), SEEK_SET);
}
/*}}}  */
/*{{{  openrwarc1:        open an archiv in rd/wt for testing read-only*/

/*******************************
        open an archive in rd/wt
        for testing read-only
*******************************/
void openrwarc1(void)
{
        file1 = e_fopen(arcname, "r+b", NOARCERR);
}
/*}}}  */
/*{{{  openbackup1        close an old archiv & rename to temporary*/
/*******************************
        close an old archive
        & rename to temporary
*******************************/
static void openbackup1(void)
{
        fclose(file1);
        stpcpy(backpath(strcpy(backup1, arcname)), "lharc.)1(");
        e_rename(arcname, backup1);
        file1 = fopen(infname = backup1, "rb");
}
/*}}}  */
/*{{{  openbackup2        open a temporary file for a new archiv*/
/*******************************
        open a temporary file
        for a new archive
*******************************/
static void openbackup2(void)
{
        if (flg_w) {
                stpcpy(stpcpy(backup2, workdir), "lharc.)2(");
        } else {
                strcat(backpath(strcpy(backup2, arcname)), "lharc.)2(");
        }
        file2 = e_fopen(outfname = backup2, "w+b", MKTMPERR);
        setvbuf(file2, buf2, _IOFBF, BUFFERSIZ);
}
/*}}}  */
/*{{{  stclosearc:        set time & close an archive*/
/*******************************
   set time & close an archive
*******************************/
void stclosearc(FILE *f)
{
        if (flg_t) {
                fflush(f);
                setftime(fileno(f), &arcstamp);
        }
        fclose(f);
}
/*}}}  */
/*{{{  endofupdate        end-of-job process in making new archive*/

/*******************************
        end-of-job process
        in making new archive
*******************************/
void endofupdate(int cnt)
{
        if (file1)
                stclosearc(file1);
        tstpat();
        if (cnt) {                                      /* if any files are manipulated */
                if (file1)
                        if (unlink(backup1))            /* delete an old archive */
                                printf("debug : Failed in deleting '%s'.", backup1);
                if ((arcpos0 = ftell(file2)) != 0) {
                        if (putc(0, file2) == EOF)
                                error(WTERR, backup2);
                        if (flg_w) {                    /* if work directory is assigned */
                                rewind(file2);
                                infname = backup2;
                                copying = 1;                    /* copy temporary to new archive */
                                file1 = e_fopen(outfname = arcname, "wb", MKFILEERR);
                                if (flg_d == 0) printf("Copying Temp to Archive ...");
                                copyfile(file2, file1, arcpos0 + 1);
                                if (flg_d == 0) printf("\n");
                                copying = 0;
                                stclosearc(file1);
                                fclose(file2);
                                unlink(backup2);
                        } else {
                                stclosearc(file2);      /* else rename temporary to archive */
                                rename(backup2, arcname);
                        }
                } else {
                        fclose(file2);
                        unlink(backup2);
                }
        } else {                                        /* if no change was made in archive */
                fclose(file2);
                unlink(backup2);
                rename(backup1, arcname);       /* restore the old archive */
        }
}
/*}}}  */
/*{{{  append:            a,u,m command*/
/*******************************
                a, u, m command
*******************************/
void append(void)
{
        int cnt;

        file1 = fopen(arcname, "r+b");
        if (file1) {
                openbackup1();                          /* if archive presents, rename to temp */
        } else {
                if (errno == EACCES)
                        error(RDONLY, arcname); /* read-only error */
        }
        mklist();                                               /* make a file list */
        if (Nfile == 0) {
                error(NOFILEERR, NULL);
        }
        if (file1) {
                message("Updating archive", arcname);
        } else {
                message("Creating archive", arcname);
        }
        openbackup2();                                  /* open temporary for new archive */
        cnt = execappend();                     /* execute updating archive */
        endofupdate(cnt);                               /* end-of-job process */
        if (cmd == 'M')
                delfile();                                      /* if 'm' command, delete files */
#ifndef __TOS__
        freemem(seg);
#else
        free (fbuf);
#endif
}
/*}}}  */
/*{{{  open_afxb:         open backup-file for afx*/
void open_afxbackup(char *s)
{
  char *p,*d,c;
  p=backup2; d=p; *backup2='\0';
  while ( (c=*s++) != 0) {
    if ((c=='\\') || (c==':'))
        d=p+1;
    *p++=c;
  }
  strcpy(d,"__temp__.lzs");
  file2=e_fopen(outfname=backup2,"w+b",MKTMPERR);
  setvbuf(file2,buf2,_IOFBF,BUFFERSIZ);
}
/*}}}  */
/*{{{  pack_aafx:         subprocess in packing afx*/
void pack_aafx(void)
{
        struct filebuf far *f0;
        uchar *p, *q;
        int c, d;
        int cnt = 0;
        if ((f0 = ((struct filebuf far *)fbuf) -> next) != NULL) {
                p = mkhdr(f0, &Hdr2);                   /* make header from the file list */
        }
        while (f0 != NULL) {
                        switch(test_afx(fb0.dir)) {
                           case 0: open_afxbackup(fb0.dir);
                                           freeze(fb0.dir);
                               fclose(file3);
                       fclose(file2);
                       if (flg_unpacked==0) {
                          unlink(fb0.dir);
                          if (rename(backup2,fb0.dir) != 0)
                              error(RENAMEERR, fb0.dir);
                       } else
                         unlink(backup2);
                       break;
                           case 1: printf("%s\n  already in AFX-format\n",fb0.dir);      break;
                           case 2: printf("%s\n  already in LHarc-format\n",fb0.dir);    break;
                           case 3: printf("%s\n  Program-file\n",fb0.dir);                           break;
                        }
                    if (file2 != NULL) fclose(file2);
                        if (file3 != NULL) fclose(file3);
            cnt++;
            if ((f0 = fb0.next) != NULL) {          /* make header of the next */
                    p = mkhdr(f0, &Hdr2);           /* file in file list */
            }
        }
        return cnt;
}
/*}}}  */
/*{{{  pack_afx:          pack-afx*/
void pack_afx(void)
{
        int cnt;
        char *p;

        mklist();                                               /* make a file list */
        if (Nfile == 0) {
                error(NOFILEERR, NULL);
        }
        FlgMethod=0;
        pack_aafx();
#ifndef __TOS__
        freemem(seg);
#else
        free (fbuf);
#endif
}
/*}}}  */
/*{{{  freshen:           f command*/
/*******************************
                f command
*******************************/
void freshen(void)
{
        uchar path[MAXPATH];
        int c;
        int cnt = 0;

        openrwarc1();                                           /* open an archive */
        message("Freshening archive", arcname);
        openbackup1();                                          /* rename the archive to temp. */
        openbackup2();                                          /* open temp. for a new archive */
        while (gethdr(file1, &Hdr1)) {
                c = 0;
                if (matchpat(filename)) {
                        stpcpy(stpcpy(path, basedir), filename);
                        if ((file3 = fopen(path, "rb")) != NULL) {
                                sethdr(filename, getfattr(path), &Hdr2);
                                if (flg_c || FTimeToULong (Hdr1.Ftime) <
                                                         FTimeToULong (Hdr2.Ftime)) {
                                        c = 1;                          /* found the file to be updated */
                                }
                        }
                }
                if (c) {
                        freeze(path);                           /* do updating */
                        cnt++;
                        fseek(file1, Hdr1.PacSiz, SEEK_CUR);
                } else {
                        copyold();
                }
                if (file3)
                        fclose(file3);
        }
        endofupdate(cnt);                                       /* end-of-job process */
}
/*}}}  */
/*{{{  tstdir:            test the file which should be melted*/
/*******************************
        test the file which
        should be melted
*******************************/
int tstdir(uchar *name)
{
        uchar path[MAXPATH], *p, yn;
        struct ffblk ffb;
Again:
        p = name;

        if (*p && p[1] == ':')                          /* skip a drive name */
                p += 2;
        if (*p == '\\')                                         /* skip a root mark('\') */
                p++;
        yn = flg_m ? 'Y' : 'N';
        while ((p = strchr(p, '\\')) != NULL) { /* skip to next '\' */
                memcpy(path, name, p - name);
                path[p - name] = '\0';
                if (findfirst(path, &ffb, 0x1f)) {      /* Is there this directory? */
                        if (yn == 'N') {
                                printf("'%s' : %s", name, M_MKDIR);
                                yn = getyn();
                        }
                        if (yn == 'N') {
                                return FAULT;
                        } else {
  								if (strcmp(path,".") != 0)
                                  if (mkdir(path)) {                      /* make directory */
                                         error(MKDIRERR, path);
                                }
                        }
                } else {
                        if ((ffb.ff_attrib & 0x10) == 0) {
                                error(MKDIRERR, path);  /* if the name isn't directory */
                        }
                }
                p++;
        }
        if (! findfirst(name, &ffb, 0x1f)) {    /* if a file has the same name */
                if (ffb.ff_attrib & 0x01 && ffb.ff_attrib != Hdr1.Attr) {
                                                                /* if the file is read-only, */
                                                                /* attributes must match */
                        fprintf(stderr, "'%s' %s\n", M_RDONLY);
                        return FAULT;
                }
                yn = 'Y';
#ifdef __TOS__
				if (flg_c == 0 && UnixFile == 0) {
#else
                if (flg_c == 0) {
#endif
                        if (((ulong)ffb.ff_fdate << 16) + (ulong)ffb.ff_ftime
                                        < FTimeToULong (Hdr1.Ftime)) {  /* compare time stamps */
                                yn = 'Y';
                        } else {
                                printf("Skipped : '%s' : New or same file exists.\n", name);
                                yn = 'N';
                        }
                }
                if (yn == 'Y' && flg_m == 0) {
                        fprintf(stderr, "'%s' : %s", name, M_OVERWT);
                        yn = getynr();                           /* may overwrite? */
                        if (yn == 'R') {
                           printf(M_ENTERNEW);
                           scanf("%s",name);
                           goto Again;
                        }
                }
                if (yn == 'N') {
                        return FAULT;
                }
                setfattr(name, 0x20);                   /* reset attributes */
        }
        return SUCCS;
}
/*}}}  */
/*{{{  tstID:             read header-ID (method)*/
/*******************************
        read header-ID (method)
*******************************/
int tstID(uchar *h)
{
        int m;
        static uchar IDpat[6][6] =
                {"-lz4-", "-lz5-", "-lh0-", "-lh1-","-lh5-","-afx-"};
                                /*  0        1        2        3       4       5   */
        m = (int)((sizeof IDpat) / (sizeof IDpat [0]));
        while (m >= 0 && memcmp(h, IDpat[m], 5)) {
                m--;
        }
        if (m==5) m=1;
        return m;
}
/*}}}  */
/*{{{  Dos1File:          Dateiname nach 8+3 Zeichen wandeln*/
#ifdef __TOS__

char LegalChar(char c)
{
  if (c <= 32) return 0;
  if (c == '*' || c == '?') return 0;
  return 1;
}

char *Dos1File(char *s, char *d) /* Ein Dateiname ohne Ordner wird berprft */
{
  char c,*t;
  int p;
  int l;
  int i;
  int j;
  int k;
  int m;

  /* Suche von hinten den letzten Punkt. i ist die Position des
     letzten Zeichens vor der Extension                         */

     l = strlen(s);
     for (i=l; i>=0;i--) if (s[i] == '.') break;
     m = i-1;
     if (i<=0) m = l;

  /* Kopiere maximal 8 Zeichen des Dateinamens. šberspringe Punkte
     und illegale Zeichen */

     j = 0; k = 0;
     t=s;
     for (j = 0; j<=7; j++) {
        c = *t++;
        if (i>0) if (k++>i)  break;
        if (c=='\0') break;
        if (j > m)   break;
        if (c != '.' && c > 32 && c != ':') {
			    if (LegalChar(c)) *d++ = c;}
         else j--;
     }
     if (i>0) {
        *d++ = '.';
        i++;
        for (j=0; j<=2; j++) {
           c=s[i++];
           if (c==0) break;
           if (c > 32 && c != ':') if (LegalChar(c)) *d++ = c;
        }
     }
     *d='\0';
     return d;
}
/*}}}  */
/*{{{  DosFile:           File mit Ordnername nach 8+3 wandeln*/
/* Auftrennen des Files in einzelne Ordner (falls n”tig) und anpassung
   jedes Ordners an 8+3 Zeichen */
void DosFile(char *s)
{
  char file[128], *f=file;
  char dest[128], *d=dest;
  char c,*s1=s;
  *d=0;
  while (( c= *s++) != 0) {
    if (c=='/') c = '\\';
    if (c==':' || c == '\\') {
      *d=0;
      f=Dos1File(dest,f);
      *f++=c; *f='\0';
      d=dest;
    } else *d++=c;
  }
  *d=0;
  f=Dos1File(dest,f);
  strcpy(s1,file);
}
#endif
/*}}}  */
/*{{{  extract:           a,x,p,t command*/

/*******************************
                e, x, p, t command
*******************************/
int extract(void)
{
        uchar *p, *q;
        int m;
        int cnt = 0;

        openarc1();                                             /* open an archive */
        setvbuf(file1, buf2, _IOFBF, 1024);
        message("Extract from", arcname);
        if (flg_v == 1)
                fprintf(file3, "Extract from '%s'\n", arcname);
        UseExthdr=1;
        while ((p = gethdr(file1, &Hdr1)) != NULL) {

                if (matchpat(filename)) {
                        arcpos0 = ftell(file1) + Hdr1.PacSiz;
                         infile=file1;
                        MKinputbuf(Hdr1.PacSiz);
                        if (cmd == 'E') {                       /* if extract command, */
                                if (flg_x) {                    /* get the destination path name */
                                        p = stpcpy(pathname, basedir);
                                        if (filename[0] == '\\') {
                                                p = pathname;
                                                if (*p && p[1] == ':') {
                                                        p += 2;
                                                }
                                        }
                                        stpcpy(p, filename);
                                } else {
                                        stpcpy(stpcpy(pathname, basedir), p);
                                }
                        }
                        slash2yen(pathname);
                        strcpy(dospathname,pathname);
						if (pathname[0] == 0)
#ifdef __TOS__
                        DosFile(dospathname);
                        UnixFile = strcmp(dospathname,pathname);
						if (dospathname[strlen(dospathname)-1]=='\\')
						   goto weiter;
#endif
						m=tstID(Hdr1.HeadID);
                        if (cmd != 'E' || tstdir(dospathname)) {
                                if ((m = tstID(Hdr1.HeadID)) < 0) {
                                        printf("Skipped : '%s' : Unknown method\n", pathname);
                                } else
                                {
                                      cnt++;
                                      p = "Melting ";
                                      q = "Melted  ";
                                      switch (cmd) {
                                                  case 'X':
                                              case 'E':

                                                      if (flg_d == 0) printf("%s ", pathname);
                                                      file3 = fopen(outfname = dospathname, "wb");
                                                      break;
                                              case 'T':
                                                      if (flg_d == 0) printf("%s ", filename);
#ifndef __TOS__
                                                      file3 = fopen ("nul", "wb");
#else
                                                      file3 = NULL;   /* no NUL-Device supported! */
#endif
                                                      p = "Testing ";
                                                      q = "Tested  ";
                                                      break;
                                              case 'P':
                                                      if (flg_v != 2)
                                                              fprintf(file3, "<<< %s >>>\n", filename);
                                                      if (flg_v)
                                                              printf("%s ", filename);
                                                      fflush(file3);


                                                      setmode(fileno(file3), O_BINARY);
                                                      break;
                                        }
#ifndef __TOS__
                                        if ((ioctl(fileno(file3), 0) & 0x82) == 0x82) {
                                                flg_n = 1;              /* Console output ? */
                                        } else {
                                                    setvbuf(file3, buf3, _IOFBF, BUFFERSIZ);
                                        }
#else
                                        if (file3 != NULL) {
                                                if (file3 == stdout) {
                                                        flg_n = 1;              /* Console output ? */
                                                } else {
                                                          outfile=file3;
                                                            /* MKoutputbuf(); */
                                                            /* setvbuf(file3, buf3, _IOFBF, BUFFERSIZ);   */

                                                }
                                        } else OutBuf=NULL;
#endif
                                        if (m != 4)
                                           blkdisp(Hdr1.OrgSiz, p);
                                        else
                                           blkdisp(Hdr1.OrgSiz/2,p);

                                        outfile = file3;
                                        infile = file1;


                                        textsize = Hdr1.OrgSiz;
                                        codesize = Hdr1.PacSiz;
                                        crc = 0;
                                         if (m == 3) {
                                                 Decode();       /* extract LHarc's file */
                                         } else if (m == 1) {
                                                 DecodeOld();    /* extract LArc's file */
                                         } else if (m == 4)  {
                                                 decode_lh5(Hdr1.OrgSiz,Hdr1.PacSiz);
                                         } else {
                                                 crcflg = 1;
                                                 copyfile(infile, outfile, Hdr1.OrgSiz);
                                                 crcflg = 0;     /* only stored file */
                                         }
                                        fflush(file1);
                                        fseek(file1,ftell(file1),0);
                                        setvbuf(file1, buf2, _IOFBF, 1024);
                                        Mfree(TheInputBuf);
                                        if (file3 != NULL) {
                                                Mfree(TheOutputBuf);
                                        }
                                        if (file3 != NULL && fflush(file3)) {
                                                error(WTERR, outfname);
                                        }
										if (pathname[0] != 0)
                                        if (cmd == 'E') {
                                                setftime(fileno(file3), &Hdr1.Ftime);
                                                fclose(file3);
                                                setfattr(pathname, Hdr1.Attr);
                                                file3 = NULL;
                                        } else if (cmd == 'T') {
#ifndef __TOS__
                                                fclose(file3);
#endif
                                        } else {
                                                setmode(fileno(file3), O_TEXT);
                                                if (flg_v != 2)
                                                        fprintf(file3, "\n");
                                        }
                                        curback();
                                        if (getcrc (&Hdr1) != crc) {
                                                errorlevel = 1;                         /* test CRC */
                                                printf("CRC err\n");
                                                if (flg_m == 0) getchar();
                                        } else if (cmd != 'P' || flg_v != 0) {
                                                if (flg_d == 0) printf("%s\n", q);
                                        }
                                }
                        }
		weiter:
                        fseek(file1, arcpos0, SEEK_SET);        /* move pointer to next file */
                } else {
                        fseek(file1, Hdr1.PacSiz, SEEK_CUR);
                }
        }
        fclose(file1);
        file1 = NULL;
        return cnt;
}
/*}}}  */
/*{{{  delete:            d command*/

/*******************************
                d command
*******************************/
void delete(void)
{
        int cnt = 0;

        openrwarc1();                                           /* open archive */
        if (patno == 0) {
                error(NOFNERR, NULL);
        }
        message("Updating archive", arcname);
        openbackup1();                                          /* rename to temporary name */
        openbackup2();                                          /* open another temporary file */
        while (gethdr(file1, &Hdr1)) {
                if (matchpat(filename)) {
                        message("Deleting", filename);
                        cnt++;
                        fseek(file1, Hdr1.PacSiz, SEEK_CUR);    /* skip file */
                } else {
                        copyold();
                }
        }
        endofupdate(cnt);                                       /* end-of-job process */
}
/*}}}  */
/*{{{  self:              s command*/

/*******************************
                s command
*******************************/
void self(void)
{
#ifndef __TOS__
        uchar *p, /* *q,*/ buf[12], yn;
        int flg, i;
        long l, m, n;
        void sfx(void), sfx2(void);

        openarc1();                                                     /* open archive */
        message("Making Sfx from archive", arcname);
        stpcpy(stpcpy(backup2, workdir), "lharc.)2(");
        file2 = e_fopen(outfname = backup2, "w+b", MKTMPERR);
                                                                                        /* open temporary */
        while (gethdr(file1, &Hdr1)) {
                flg = 0;
                if (matchpat(filename)) {
                        if (flg_d == 0) printf("Extracting '%s' ", filename);
                        if (tstID(Hdr1.HeadID) < 2) {
                                printf("(not supported) skipped.");
                        } else {
                                if (flg_x == 0 && (p = strrchr(filename, '\\')) != NULL) {
                                         p++;                                    /* delete directory part */
                                        Hdr1.Fname[0] = strlen(p);
                                        i = p - filename;
                                        Hdr1.HeadSiz -= i;
                                        memcpy(Hdr1.Fname + 1, Hdr1.Fname + 1 + i,
                                                                                                Hdr1.Fname[0] + 2);
                                        Hdr1.HeadChk = mksum(&Hdr1);    /* recalculate sum */
                                }
                                wthdr(&Hdr1);
                                copyfile(file1, file2, Hdr1.PacSiz);
                                flg = 1;
                        }
                        printf("\n");
                }
                if (flg == 0) {
                        fseek(file1, Hdr1.PacSiz, SEEK_CUR);
                }
        }
        fclose(file1);
        if (putc(0, file2) == EOF)                      /* end-mark of archive */
                error(WTERR, backup2);
        if ((l = ftell(file2)) <= 1) {
                goto self9;
        }
        if (flg_x == 0) {
                m = (uchar*)sfx2 - (uchar*)sfx;         /* size of sfx routine */
        } else {
                m = (uchar*)usage - (uchar*)sfx2;
        }
        n = l + m;                                                              /* total size of sfx file */
        rewind(file2);
        infname = backup2;
        extfn(arcname, buf);                                    /* make the name of sfx */
        p = stpcpy(pathname, basedir);
        strcpy(&buf[8], "COM");
        if (flg_x || n > 0xfe80ul) {
                strcpy(&buf[8], "EXE");
        }
        packfn(p, buf);
        if ((getfattr(pathname) & 0x8000) == 0) {       /* if the same name exists */
                fprintf(stderr, "'%s' : %s", pathname, M_OVERWT);
                yn = getyn();                                                   /* may overwrite */
                if (yn == 'N') {
                        goto self9;
                }
        }
        file3 = e_fopen(outfname = pathname, "wb", MKFILEERR);
        if (buf[8] == 'E') {                                            /* if .EXE */
                if (flg_x) {
                        n = m;
                }
                n += 0x20;
                ExeHdr.page = (n + 511) / 512;
                ExeHdr.byte = n % 512;
                ExeHdr.minalloc = (flg_x ? 0x66c0 : 0x2560) / 0x10;
                if (fwrite(&ExeHdr, 0x20, 1, file3) == 0)
                        error(WTERR, pathname);
        }
        movedata(_CS, (flg_x ? (unsigned)sfx2 : (unsigned)sfx),
                         _DS, (unsigned)buf2, m);
        if (flg_x) {
                memcpy(buf2 + 0x34, p, strlen(p));                              /* large ver. */
        } else {
                *((uint *)buf2 + 1) = (l + m + 0x10f) / 0x10;   /* small ver. */
        }
        if (fwrite(buf2, m, 1, file3) == 0)     /* write sfx routine */
                error(WTERR, pathname);
        if (flg_x) {
                if (fwrite(keyword, strlen(keyword) + 1, 1, file3) == 0)
                        error(WTERR, pathname);
        }
        copyfile(file2, file3, l);                              /* write an archive */
        printf("\nCreated : '%s'\n", pathname);
        fclose(file3);
self9:
        fclose(file2);
        unlink(backup2);
#else
        fprintf (stderr, "Self-Extracting-Files: NOT YET IMPLEMENTED!!!\7\n");
        errorlevel = 1;
        longjmp (exit_jmp, 1);          /* NOT YET IMPLEMENTED !!! */
#endif
}
/*}}}  */
/*{{{  sysid*/

char *sysid( void )
{
  char *s;
  if (flg_k == 0) {
    switch(SystemId) {
      case 'M' : s="MSDOS "; break;
      case '2' : s="OS/2  "; break;
      case '9' : s="OS9   "; break;
      case 'K' : s="OS/68K"; break;
      case '3' : s="OS/386"; break;
      case 'H' : s="HUMAN "; break;
      case 'U' : s="UNIX  "; break;
      case 'C' : s="CP/M  "; break;
      case 'm' : s="Mac   "; break;
      case 'R' : s="Runser"; break;
      case 'A' : s="Atari "; break;
      default  : s="      "; break;
    }
  } else         s="      ";
  return s;
}

/*}}}  */
/*{{{  list:              l,v command*/


/*******************************
                l, v command
*******************************/
void list(void)
{
        uint rt;
        uchar buf[79], *p,*b;
        static uchar attr[7] = "ohs--a";
        int i, j, k, Fno;
        ulong Osize, Psize;

        Osize = Psize = 0L;
        Fno = 0;
        openarc1();                                                                     /* open archive */
        UseExthdr=1;
#ifdef German
        printf("Inhalt von : '%s'\n\n", arcname);
        printf("  Name          Original   Gepackt   Rate"
                   "    Datum     Zeit Attr   Typ  CRC\n");
#else
        printf("Listing of archive : '%s'\n\n", arcname);
        printf("  Name          Original    Packed  Ratio"
                   "     Date   Time   Attr Type  CRC\n");
#endif
        printf("--------------  --------  -------- ------"
                   " -------- -------- ---- ----- ----\n");
        while ((p = gethdr(file1, &Hdr1)) != NULL) {
                if (matchpat(filename)) {
                        rt = ratio(Hdr1.PacSiz, Hdr1.OrgSiz);
                        sprintf(buf, "              %10lu%10lu %3d.%1d%% "
                                        "%2d-%02d-%02d %2d:%02d:%02d ---w       %04X\n",
                                        Hdr1.OrgSiz, Hdr1.PacSiz, rt / 10, rt % 10,
                                        (Hdr1.Ftime.ft_year + 80) % 100, Hdr1.Ftime.ft_month,
                                        Hdr1.Ftime.ft_day, Hdr1.Ftime.ft_hour,
                                        Hdr1.Ftime.ft_min, Hdr1.Ftime.ft_tsec * 2,
                                        getcrc (&Hdr1));
                        memcpy(&buf[65], Hdr1.HeadID, 5);
                        for (i = 0, j = 1; i < 6; i++, j <<= 1) {       /* attributes */
                                if (Hdr1.Attr & j) {
                                        k = attr[i];
                                        if (i <= 2) {
                                                buf[63 - i] = k;
                                        } else {
                                                buf[60] = k;
                                        }
                                }
                        }
                        if (flg_x) {
                                printf("%s\n", filename);       /* display in 2 lines */
                                p=sysid(); b = buf;
                                while (*p != 0) *b++=*p++;

                                if (comment[0] != 0) printf("%s\n",comment);
                        } else {
                                if (p != filename) {            /* display in one line */
                                        *buf = '+';
                                }
                                memcpy(&buf[2], p, strlen(p));
                        }
                        printf("%s", buf);
                        Fno ++;
                        Osize += Hdr1.OrgSiz;
                        Psize += Hdr1.PacSiz;
                }
                if (fseek(file1, Hdr1.PacSiz, 1))
                        break;
        }
        if (Fno) {
                printf("--------------  --------  -------- ------"
                           " -------- --------\n");
                rt = ratio(Psize, Osize);
                getftime(fileno(file1), &arcstamp);
                printf("   %3d files  %10lu%10lu %3d.%1d%% "
                           "%2d-%02d-%02d %2d:%02d:%02d\n",
                           Fno, Osize, Psize, rt / 10, rt % 10,
                           (arcstamp.ft_year + 80) % 100, arcstamp.ft_month,
                           arcstamp.ft_day, arcstamp.ft_hour,
                           arcstamp.ft_min, arcstamp.ft_tsec * 2);
        } else {
                printf("    no file\n");
        }
        fclose(file1);
}
/*}}}  */
/*{{{  getsw:             get switches*/

/*******************************
                get switches
*******************************/
void getsw(uchar *p)
{
#ifndef __TOS__
        static uchar flg[] = "rpxmacntvwyb";
        static uchar *flgpos[] = {&flg_r, &flg_p, &flg_x, &flg_m,
                                                          &flg_a, &flg_c, &flg_n, &flg_t,
                                                          &flg_v, &flg_w};
#else
        static uchar flg[] = "rpxmacntvwhybludoske5";
        static uchar *flgpos[] = {&flg_r, &flg_p, &flg_x, &flg_m,
                                                          &flg_a, &flg_c, &flg_n, &flg_t,
                                                          &flg_v, &flg_w, &flg_h};
#endif
        int i;
        uchar s;
        uchar *q;

        while ((s = *p++) != 0) {
                q = strchr(flg, s);     /* search switch */
                if (q) {
                        i = (int)(q - flg);
                        if (*p == '+') {
                                *flgpos[i] = 1;
                                p++;
                        } else if (*p == '-') {
                                *flgpos[i] = 0;
                                p++;
                        } else if (*p == '2') {
                                *flgpos[i] = 2;
                                p++;
                        } else if (s == 'v' && *p) {
                                if (flg_v == 0)                 /* process of '/vSTRING' */
                                        flg_v = 1;
                                pager = p;
                                p = "";
                        } else if (s == 'y') flg_arc = 1;
                                               else if (s == 'k') { flg_k=1; elen=0; }
                        else if (s == 'b') {
                                flg_arc=1;
                                flg_backup=1;
						} else if (s == '5') flg_5=1;
                          else if (s == 'l') FlgMethod=0;
                          else if (s == 'o') FlgMethod=1;
                          else if (s == 's') flg_s=1;
                          else if (s == 'u') flg_u = 1;
                          else if (s == 'e') flg_e = 1;
                          else if (s == 'w' && *p) {
                                flg_w = 1;                              /* process of '/wSTRING' */
                                wdir = p;
                                p = "";
                        } else if (s == 'd') flg_n = flg_d = 1;
                        else {
                                if (*flgpos[i]) {               /* flip-flop */
                                        *flgpos[i] = 0;
                                } else {
                                        *flgpos[i] = 1;
                                }
                        }
                        if (s == 'r' && flg_r > 0) {
                                flg_x = 1;
                        }
#ifndef __TOS__
                } else if (s == 'k') {
                        keyword = p;
                        p = "";
#endif
                }
                else {
                        if (s == '?') usage();
                        error(INVSWERR, NULL);
                }
        }
}
/*}}}  */
/*{{{  executecmd:        execute command*/

/*******************************
                execute command
*******************************/
void executecmd(void)
{
        int cnt;

        switch (cmd) {
        case 'A':
                flg_c++;
        case 'U':
        case 'M':
                append();
                break;
        case 'C':
                pack_afx();
                break;
        case 'F':
                freshen();
                break;
        case 'P':
                if (flg_v == 0) {
                   file3 = stdout;
                   goto common;
                }
                stpcpy(stpcpy(pathname, workdir), "LHARC.TMP"); /* view files */
                file3 = e_fopen(outfname = pathname, "w", MKTMPERR);
                cnt = extract();
                fclose(file3);
                if (cnt)                                                /* if any files extracted */
#ifndef __TOS__
                        stpcpy(stpcpy(stpcpy(buf2, pager), " "), pathname);
                        execute(buf2);                          /* execute by INT 0x2e */
#else
                        {
                                int retcode;

                                exec (pager, pathname, "", &retcode);
                        }
#endif
#if 0
                        spawnlp(P_WAIT, pager, pager, pathname, NULL);
#endif
                unlink(pathname);
                break;
        case 'T':
                tstflg = 1;
                goto common;
        case 'X':
        case 'E':
                cmd = 'E';
common:
                flg_v = 0;
                extract();
                break;
        case 'V':
                flg_x++;
        case 'L':
                list();
                break;
        case 'D':
                delete();
                break;
        case 'S':
                self();
                break;
        }
        if (!flg_d) putchar('\n');
}
/*}}}  */
/*{{{  recoverbrk:        handle userbreak*/

/*******************************
                handle userbreak
*******************************/
#ifndef __TOS__
int cbrk;

void recovercbrk(void) {
        setcbrk(cbrk);
}
#endif
/*}}}  */
/*{{{  OneNewFile:*/
void OneNewFile(char *p)
{
  char *s;
  s = strchr(p,'\n');
  if (s != NULL) *s='\0';
       if (patno == 0 && basedir == NULL &&
                (strrchr(p, '\\') == p + strlen(p) - 1 ||
                 p[strlen(p) - 1] == ':')) {
                basedir = p;    /* get base (or home) directory */
        } else if (patno >= MAX_PAT) {
                message("File table overflow. ignore", p);
        } else {
                patpath[patno] = p;
                extfn(p, patfile[patno]);
                patno++;                /* regist path names */
        }
}
/*}}}  */
/*{{{  newfile*/
void newfile(char *p)
{
  char file[128];       /* Dateiname bei &datei */
  FILE *f;
  if (*p == '&')
   {
     if (strcmp("-",&p[1]) == 0)
        f=stdin; else f=fopen(&p[1],"r");
     if (f != NULL)
     {
       while ( fgets(file,127,f) != NULL)
          OneNewFile(strdup(file));                     /* regist copy of filecontents */
       fclose(f);
     }
   } else OneNewFile(p);
}
/*}}}  */
/*{{{  argv_main:         main routine*/
/*******************************
                main routine
*******************************/
#ifndef __GEM__
#ifdef __TOS__
int argvmain(int argc, uchar **argv,uchar **envp)
#else
int main(int argc, uchar *argv[])
#endif
{
        uchar *p, *q, *env, *env9;
        uchar ptitel=0;
        int yn;
        extern char title[];
        struct ffblk ffb;
		FILE *fp;
		char buffer[256];



        if (!setjmp (exit_jmp)) {
#ifndef __TOS__
                ctrlbrk(userbreak);                     /* set vector for '^C' */
                cbrk = getcbrk();
                setcbrk(1);
                atexit(recovercbrk);
#endif

                remove("LHARC.)1(");
                remove("LHARC.)2(");

                mkcrc();                                                /* make CRC table */
                swchar = getswchar();                   /* get the setting of switch char */
                argc--;
                argv++;
                if (argc-- == 0)
                {
                        flg_h = 1;
                        usage();                                        /* if no parameter given */
                }
                p = (argv++)[0];
                cmd = toupper(*p);
                if (strlen(p) - 1 || strchr("EXTDLVAUMFPSC", cmd) == 0) {
                        cmd = 'X';                                      /* if no command, assume 'X' command */
                        argc++;
                        argv--;
                        flg_x = 1;      /* @@25.5.91 Ohne Kommando x -rm */
                        flg_m = 1;
                }
                cmdupdate = (int)strchr("AUMFD", cmd);
                                                                                         /* command updating archive? */
                if ((env = getenv("TMP")) != NULL) { /* get 'TMP' from environment */
                        wdir = env;
                        flg_w = 1;
                }
                if ((env = getenv("LHARC")) != NULL) {
                                                                        /* get 'LHARC' from environment */
                        for (p = env; *p != '\0'; p++) {
                                if (*p == ' ' || *p == '\x08')
                                        *p = '\0';
                        }
                        env9 = p;
                        p = env;
                        while (p < env9) {
                                while (*p == '\0') p++;
                                if (*p == swchar || *p == '-') p++;
                                getsw(p);
                                while (*p) p++;
                        }
                }
                patno = -1;
                                if (cmd == 'C') patno=0;
                basedir = NULL;
while (argc--) {
        p = (argv++)[0];
        if (*p == swchar || *p == '-') {
                getsw(++p);
        } else {
          if (ptitel == 0 && flg_d == 0) {
                puts(title);                     /* output title */
				if ((fp = fopen("lharc.ttp","rb")) != NULL ||
					(fp = fopen("lzh.ttp","rb")) != NULL ||
					(fp = fopen("lharcd.ttp","rb")) != NULL) {
          		  fread(buffer,1,256,fp);
		  		   if (strncmp(buffer+30,"LArc's PFX",10) == 0)
				         printf(morefiles);
				  fclose(fp);
			    }
				putchar('\n');
                ptitel=1;
          }
                strupr(p);
                slash2yen(p);                           /* convert '/' to '\' */
                                                        /* in japanese version */
                if (patno < 0) {                        /* get archive name */
                        strcpy(arcname, p);
                        if ((p = strrchr(arcname, '\\')) == NULL) {
                                p = arcname;    /* pointer of the part of file name */
                        }
                        if ((q = strchr(p, '.')) == NULL) {
                                strcat(arcname, ".LZH");        /* if no extension */
                        } else if (strcmp(".LZH", q) && flg_m == 0 && cmdupdate) {
                                fprintf(stderr, M_NOTLZH, arcname);
                                yn = getyn();   /* if the extension is not '.LZH' */
                                if (yn == 'N') {
                                        errorlevel = 1;
                                        longjmp (exit_jmp, 1);
                                }
                        }
                        patno++;
                } else {
                                         newfile(p); /* Register file or files */
                }
        }
}
                if (patno < 0) {
                        error(NOARCNMERR, NULL);
                }
                if (patno == 0 && cmd != 'D') {                         /* if no name given */
                        extfn(patpath[0] = patnul, patfile[0]); /* '*.*' is assumed */
                        patno++;
                }
                p = stpcpy(workdir, wdir) - 1;
                if (*workdir != '\0' && strrchr(workdir, '\\') != p && *p != ':') {
                        strcat(workdir, "\\");  /* concatenate '\' after the work dir. */
                }
                if (cmdupdate) {
                        if (strchr(arcname, '*') || strchr(arcname, '?')) {
                                error(NOARCERR, arcname);
                        }                               /* when updating archive, wild cards can't used */
                        executecmd();
                }
                else {
                    if (cmd == 'C') executecmd();
                   else {
                      if (findfirst(arcname, &ffb, 0x07)) {
                              error(NOARCERR, arcname);
                      }
                      do {
                              strcpy(backpath(arcname), ffb.ff_name);
                              executecmd();
                      } while (!findnext(&ffb));
                      if (cmd != 'L' && cmd != 'V')
                              tstpat();                       /* whether all given names were used? */
                    }
                }
        }

#ifdef __TOS__
        if (flg_h)
        {
                fflush (stdin);                         /* wait for keystroke when used */
                printf (M_PRESSKEY); /* with GEM-Desktop                         */
                getch ();
                putchar ('\n');
        }
#endif
        return errorlevel;
}
/*}}}  */
/*{{{  main:              argv calculations*/
int main (int argc, char *argv[], char *envp[])
{
  char **myargv;
  extern BASPAG *_BasPag;
  char *env;
  char *startpar;
  char *oldline;


  int count = 0;
  int i;

  Fsetdta (&_mydta);

  /* Anfang der alten Kommandozeile */
  oldline = &_BasPag->p_cmdlin[1];

  /* Flag fuer Verwendung von ARGV */
  if (_BasPag->p_cmdlin[0] != 127)
    return argvmain (argc, argv, envp);

  /* Zeiger auf Env-Var merken */
  env = getenv("ARGV");
  if (!env)
    return argvmain (argc, argv, envp);

  /* alle weiteren envp's loeschen */
  i = 0;
  while (strncmp (envp[i], "ARGV", 4)) i++;
  envp[i] = NULL;

  /* alles, was dahinter kommt, abschneiden */
  if (env[0] && env[-1])
  {
    *env++ = 0;     /* kill it */
    while (*env++);
  }

  /* Parameterstart */
  startpar = env;

  while (*env)
  {
    count++;
    while (*env++);
  }

  /* Speicher fuer neuen Argument-Vektor */
  myargv = Malloc ((count+1)*sizeof (char *));
  env = startpar;

  count = 0;
  while (*env)
  {
    myargv[count++] = env;
    while (*env++);
  }
  myargv[count] = NULL;

  /* moeglichst viele Parameter in alte Kommandozeile */
  {
    int i;

    *oldline = 0;
    i = 1;

    while ((i < count) && (strlen (oldline) + strlen (myargv[i]) < 120))
    {
      if (i > 1) strcat (oldline, " ");
      strcat (oldline, myargv[i]);
      i++;
    }

    if (i < count) strcat (oldline, " ...");
  }


  /* und ...argvmain() starten */
  count = argvmain (count, myargv, envp);
  Mfree (myargv);
  return count;
}
#endif
/*}}}  */
