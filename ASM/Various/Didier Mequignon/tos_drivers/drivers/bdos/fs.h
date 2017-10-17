/*
 * fs.h - file system defines
 *
 * Copyright (c) 2001 Lineo, Inc.
 *
 * Authors:
 *  JSL   Jason S. Loveman
 *  SCC   Steve C. Cavender
 *  EWF   Eric W. Fleischman
 *  KTB   Karl T. Braun (kral)
 *  MAD   Martin Doering
 *  LVL   Laurent Vogel
 *
 * This file is distributed under the GPL, version 2 or at your
 * option any later version.  See doc/license.txt for details.
 */



#ifndef FS_H
#define FS_H

/*
 *  fix conditionals
 */

#define M0101052901     1

/*
 *  constants
 */

#define SLASH '\\'

#define SUPSIZ  4096    /* common supervisor stack size (in words) */
#define OPNFILES 500    /* max open files in system */
#define NCURDIR  500    /* max current directories in use in system */
#define NUMSTD 6        /* number of standard files */
#define KBBUFSZ 128     /* size of typeahead buffer -- must be power of 2!! */
#define KBBUFMASK       (KBBUFSZ-1)

/*
 *  code macros
 */

#define min(a,b) (((a) < (b)) ? (a) : (b))

/*
 *  Error handling
 */

#include "setjmp.h"

extern  long    rwerr;
extern  jmp_buf errbuf;
extern  short     errdrv;
extern  long    errcode;

extern long rwabs(long mode, long buf, long count, long recno, long dev, long lrecno);

#define longjmp_rwabs(a,b,c,d,e,f) if((rwerr=(long)rwabs((long)(a),(long)(b),(long)(c),(long)(d),(long)(e),(long)(f)))!=0) \
{errdrv=e;errcode=rwerr;longjmp(errbuf,1);}

/*
 *  Type declarations
 */

#define BCB     struct  _bcb
#define FTAB    struct  _ftab
#define PD      struct  _pd
#define OFD     struct  _ofd
#define FCB     struct  _fcb
#define DND     struct  _dnd
#define DMD     struct  _dmd
#define CLNO    unsigned short  /*  cluster number M01.01.03    */
#define RECNO   unsigned long   /*  record number M01.01.03     */
                                /*** this should be changed to a long!! ***/
#define FH      unsigned short            /*  file handle M01.01.04       */

/*
 *  PD - Process Descriptor
 */

#define PDCLSIZE        0x80            /*  size of command line in bytes  */
#define NUMCURDIR       16              /*  number of entries in curdir array */

PD      /* this is the basepage format */
{
    /* 0x00 */
    long p_lowtpa;
    long p_hitpa;
    long p_tbase;
    long p_tlen;
    /* 0x10 */
    long p_dbase;
    long p_dlen;
    long p_bbase;
    long p_blen;
    /* 0x20 */
    char *p_xdta;
    PD   *p_parent;             /* parent PD */
    short  p_flags;
    short  p_0fill[1];
    char *p_env;                /* at offset 2ch (eat your heart out, Lee) */
    /* 0x30 */
    char p_uft[NUMSTD];         /* index into sys file table for std files */
    char p_lddrv;
    char p_curdrv;
    long p_1fill[2];
    /* 0x40 */
    char p_curdir[NUMCURDIR];   /* index into sys dir table */
    /* 0x50 */
    long p_2fill[4];
    /* 0x60 */
    long p_3fill[2];
    long p_dreg[1];             /* dreg[0] */
    long p_areg[5];             /* areg[3..7] */
    /* 0x80 */
    char p_cmdlin[PDCLSIZE];
} ;

/* p_flags values: */
#define PF_FASTLOAD  0x0001
#define PF_TTRAMLOAD 0x0002
#define PF_TTRAMMEM  0x0004


/*
 *  OFD - open file descriptor
 */

OFD 
{
    OFD   *o_link;      /*  link to next OFD                    */
    short   o_flag;
    short   o_time;       /*  the next 4 items must be as in FCB  */
    short   o_date;       /*  time, date of creation              */
    CLNO  o_strtcl;     /*  starting cluster number             */
    long  o_fileln;     /*  length of file in bytes             */

    DMD   *o_dmd;       /*  link to media descr                 */
    DND   *o_dnode;     /*  link to dir for this file           */
    OFD   *o_dirfil;    /*  OFD for dir for this file           */
    long  o_dirbyt;     /*  pos in dir of this files fcb (dcnt) */

    long  o_bytnum;     /* byte pointer within file             */
    CLNO  o_curcl;      /* not used                             */
    RECNO o_currec;     /* not used                             */
    unsigned short   o_curbyt;     /* not used                             */
    short   o_usecnt;     /* use count for inherited files        */
    OFD   *o_thread;    /* mulitple open thread list            */
    short   o_mod;        /* mode file opened in (r, w, r/w)      */
} ;


/*
 * O_DIRTY - Dirty Flag
 *
 * T: OFD is dirty, because of chg to startcl, length, time, etc.
 */

#define O_DIRTY         1

#if     ! M0101052901
/*
 * O_COMPLETE -
 *
 * 1: traversal of directory file (to bld dir tree) has completed
 */

#define O_COMPLETE      2
#endif



/*
 *  FCB - File Control Block
 */

FCB
{
    char  f_name[11];
    char  f_attrib;
    char  f_fill[10];
    short f_time;
    short f_date;
    CLNO  f_clust;
    long  f_fileln;
} ;

#define FA_VOL          0x08  /* label */
#define FA_SUBDIR       0x10  /* subdirectory */
#define FA_NORM         0x27  /* archiv bit + system + hidden + write protected */
#define FA_RO           0x01  /* write protected */
#define FA_VFAT         0x0f  /* VFAT entry */

#define FA_HIDDEN     0x02
#define FA_SYSTEM     0x04
#define FA_ARCHIVE    0x20

/*
 *  DND - Directory Node Descriptor
 */

DND /* directory node descriptor */
{
    char d_name[11];    /*  directory name                      */
    char d_fill;        /*  attributes?                         */
    short  d_flag;
    CLNO d_strtcl;      /*  starting cluster number of dir      */

    short  d_time;        /*  last mod ?                          */
    short  d_date;        /*  ""   ""                             */
    OFD  *d_ofd;        /*  open file descr for this dir        */
    DND  *d_parent;     /*  parent dir (..)                     */
    DND  *d_left;       /*  1st child                           */

    DND  *d_right;      /*  sibling in same dir                 */
    DMD  *d_drv;        /*  for drive                           */
    OFD  *d_dirfil;
    long d_dirpos;      /*  */

    long d_scan;        /*  current posn in dir for DND tree    */
    OFD  *d_files;      /* open files on this node              */
} ;

/* flags:       */
#define B_16    1                               /* device has 16-bit FATs       */
#define B_FIX   2                               /* device has fixed media       */



/*
 *  DMD - Drive Media Block
 */

/*  records == sectors  */

DMD /* drive media block */
{
    long    m_recoff[3]; /*  record offsets for fat,dir,data     */
    short    m_drvnum;    /*  drive number for this media         */
    RECNO  m_fsiz;      /*  fat size in records M01.01.03       */
    RECNO  m_clsiz;     /*  cluster size in records M01.01.03   */
    unsigned short    m_clsizb;    /*  cluster size in bytes               */
    unsigned short    m_recsiz;    /*  record size in bytes                */

    CLNO   m_numcl;     /*  total number of clusters in data    */
    short    m_clrlog;    /* clsiz in rec, log2 is shift          */
    short    m_clrm;      /* clsiz in rec, mask                   */
    short    m_rblog;     /* recsiz in bytes, shift               */
    short    m_rbm;               /* recsiz in bytes, mask                */
    short    m_clblog;    /* log of clus size in bytes            */
    OFD    *m_fatofd;   /* OFD for 'fat file'                   */

    OFD    *m_ofl;      /*  list of open files                  */
    DND    *m_dtl;      /* root of directory tree list          */
    short    m_16;        /* 16 bit fat ?                         */
} ;



/*
 *  buffer type values
 */

#define BT_FAT          0               /*  fat buffer                  */
#define BT_ROOT         1               /*  root dir buffer             */
#define BT_DIR          2               /*  other dir buffer            */
#define BT_DATA         3               /*  data buffer                 */

/*
 *  buffer list indexes
 */

#define BI_FAT          0               /*  fat buffer list             */
#define BI_ROOT         1               /*  root dir buffer list        */
#define BI_DIR          1               /*  other dir buffer list       */
#define BI_DATA         1               /*  data buffer list            */

/*
 *  BCB - Buffer Control Block
 */

BCB
{
    BCB     *b_link;    /*  next bcb                    */
    short   b_bufdrv;   /*  unit for buffer             */
    short   b_buftyp;   /*  buffer type                 */
    long    b_bufrec;   /*  record number               */
    BOOL    b_dirty;    /*  true if buffer dirty        */
    long    b_dm;       /*  reserved for file system    */
    char    *b_bufr;    /*  pointer to buffer           */
} ;

/*
 * FTAB - Open File Table Entry
 */

/* point these at OFDs when needed */
FTAB
{
    OFD *f_ofd;
    PD  *f_own;         /* file owners */
    short f_use;          /* use count */
} ;



/*
 * DTAINFO - Information stored in the dta by srch-frst for use by srch-nxt.
 */

#define DTAINFO struct DtaInfo

DTAINFO
{
    char  dt_name[12];          /*  file name: filename.typ     00-11   */
    long  dt_pos;               /*  dir position                12-15   */
    DND   *dt_dnd;              /*  pointer to DND              16-19   */
    char  dt_attr;              /*  attributes of file          20      */
                                /*  --  below must not change -- [1]    */
    char  dt_fattr;             /*  attrib from fcb             21      */
    short   dt_time;              /*  time field from fcb         22-23   */
    short   dt_date;              /*  date field from fcb         24-25   */
    long  dt_fileln;            /*  file length field from fcb  26-29   */
    char  dt_fname[14];         /*  file name from fcb          30-43   */
} ;                             /*    includes null terminator          */

#include "bios.h"




/* External Declarations */

extern  DND     *dirtbl[];
extern  DMD     *drvtbl[];
extern  char    diruse[];
extern  short     drvsel;
extern  PD      *run;
extern  short     logmsk[];
extern  FTAB    sft[];
extern  BCB     *bufl[2];              /*  in bios main.c              */



/*
 * Forward Declarations
 */


/* 
 * in fsdrive.c 
 */

/* check the drive, see if it needs to be logged in. */
long ckdrv(short d);

/* allocate storage for and initialize a DMD */
DMD  *getdmd(short drv);

/* log in media 'b' on drive 'drv'. */
long log_(BPB *b, short drv);

/*
 * in fshand.c
 */

long xforce(short std, short h);
long ixforce(short std, short h, PD *p);

/* ??? */
short syshnd(short h);

/* ??? */
void ixdirdup(short h, short dn, PD *p);

/* duplicate a file handle. */
long dup(long h);

/*
 * in fsopnclo.c
 */

/* create file with specified name, attributes */
long xcreat(char *name, char attr);
long ixcreat(char *name, char attr);

/* open a file (path name) */
long xopen(char *name, short mod);

/* Close a file */
long xclose(short h);
long ixclose(OFD *fd, short part);

/* remove a file */
long xunlink(char *name);
/* internal delete file. */
long ixdel(DND *dn, FCB *f, long pos);

/*
 * in fsbuf.c
 */

void bufl_init(void);
/* ??? */
void flush(BCB *b);
/* return the ptr to the buffer containing the desired record */
char *getrec(long recn, DMD *dm, short wrtflg);
/* pack into user buffer */
char *packit(register char *s, register char *d);

/*
 * in fsfat.c
 */

RECNO cl2rec(CLNO cl, DMD *dm);
void clfix(CLNO cl, CLNO link, DMD *dm);
CLNO getcl(CLNO cl, DMD *dm);
short nextcl(OFD *p, short wrtflg);
long xgetfree(long *buf, short drv);

/* 
 * in fsio.c
 */

/* seek to byte position n on file with handle h */
long xlseek(long n, short h, short flg);
long ixlseek(OFD *p, long n);

long xread(short h, long len, void *ubufr);
long ixread(OFD *p, long len, void *ubufr);

long xwrite(short h, long len, void *ubufr);
long ixwrite(OFD *p, long len, void *ubufr);

/*
 * in fsdir.c
 */

long xmkdir(char *s);
long xrmdir(char *p);
long xchmod(char *p, short wrt, char mod);
long ixsfirst(char *name, register WORD att, register DTAINFO *addr);
long xsfirst(char *name, short att);
long xsnext(void); 
void xgsdtof(short *buf, short h, short wrt);
void builds( char *s1 , char *s2 );
long xrename(short n, char *p1, char *p2);
long xchdir(char *p);
long xgetdir(char *buf, short drv);
FCB *dirinit(DND *dn);
DND *findit(char *name, char **sp, short dflag);
FCB *scan(register DND *dnd, char *n, WORD att, LONG *posp);

/*
 * in fsmain.c
 */

char uc(register char c);
char *xgetdta(void);
void xsetdta(char *addr);
long xsetdrv(short drv);
long xgetdrv(void); 
OFD  *makofd(register DND *p);
OFD  *getofd(short h);



/* Misc. defines */

#define CL_DIR  0x0002
#define CL_FULL 0x0004

#endif /* FS_H */
