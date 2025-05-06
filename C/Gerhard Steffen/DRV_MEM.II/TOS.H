/*      TOS.H

        Tos Definition Includes

        Copyright (c) Borland International 1990
        All Rights Reserved.
*/


#if !defined( __TOS )
#define __TOS

typedef struct          /* used by Cconrs */
{
        unsigned char maxlen;
        unsigned char actuallen;
        char    buffer[255];
} LINE;


typedef struct          /* used by Fsetdta, Fgetdta */
{
    char            d_reserved[21];
    unsigned char   d_attrib;
    unsigned int    d_time;
    unsigned int    d_date;
    unsigned long   d_length;
    char            d_fname[14];
} DTA;


typedef struct          /* used by Dfree */
{
    unsigned long   b_free;
    unsigned long   b_total;
    unsigned long   b_secsiz;
    unsigned long   b_clsiz;
} DISKINFO;


typedef struct baspag   /* used by Pexec */
{
        void    *p_lowtpa;
        void    *p_hitpa;
        void    *p_tbase;
        long    p_tlen;
        void    *p_dbase;
        long    p_dlen;
        void    *p_bbase;
        long    p_blen;
        DTA     *p_dta;
        struct baspag *p_parent;
        long    p_resrvd0;
        char    *p_env;
        char    p_stdfh[6];
        char    p_resrvd1;
        char    p_curdrv;
        long    p_resrvd2[18];
        char    p_cmdlin[128];
} BASPAG;

typedef struct
{
  int   recsiz ;        /* Bytes pro Sektor */
  int   clsiz ;         /* Sektoren pro Cluster */
  int   clsizb ;        /* Bytes pro Cluster */
  int   rdlen ;         /* Verzeichnisl„nge */
  int   fsiz ;          /* L„nge der FAT */
  int   fatrec ;        /* Start der 2. FAT */
  int   datrec ;        /* 1. freier Sektor */
  int   numcl ;         /* Gesamtzahl an Cluster */
  int   bflags ;        /* Flags */
  
  int   dntracks;       /* Anzahl der Spuren auf Disk */
  int   dnsides;        /*    "    "  Seiten  "    "  */
  int   dnspdt;         /* Sektoren pro Track (beide Seiten)  */
  int   dnspt;          /* Sektoren pro Track pro Seite */ 
  int   dhidden;        /* Anzahl der versteckten Sektoren */
  char  dserial1;       /* Seriennummer der Diskette */
  char  dserial2;       /* (3 Bytes)    */
  char  dserial3;
} BPB ;

typedef struct
{
        int     time;
        int     date;
} DOSTIME;


typedef struct          /* used by Iorec */
{
        void    *ibuf;
        int     ibufsiz;
        int     ibufhd;
        int     ibuftl;
        int     ibuflow;
        int     ibufhi;
} IOREC;


typedef struct          /* used by Kbdvbase */
{
        void    (*kb_midivec)();
        void    (*kb_vkbderr)();
        void    (*kb_vmiderr)();
        void    (*kb_statvec)();
        void    (*kb_mousevec)();
        void    (*kb_clockvec)();
        void    (*kb_joyvec)();
        void    (*kb_midisys)();
        void    (*kb_kbdsys)();
} KBDVBASE;


typedef struct          /* used by Pexec */
{
        unsigned char   length;
        char            command_tail[128];
} COMMAND;


typedef struct          /* used by Initmouse */
{
        char    topmode;
        char    buttons;
        char    x_scale;
        char    y_scale;
        int     x_max;
        int     y_max;
        int     x_start;
        int     y_start;
} MOUSE;


typedef struct          /* used by Prtblk */
{
        void    *pb_scrptr;
        int     pb_offset;
        int     pb_width;
        int     pb_height;
        int     pb_left;
        int     pb_right;
        int     pb_screz;
        int     pb_prrez;
        void    *pb_colptr;
        long    pb_prtype;
        int     pb_prport;
        void    *pb_mask;
} PBDEF;


typedef struct          /* used by Keytbl */
{
        char *unshift;
        char *shift;
        char *capslock;
} KEYTAB;


typedef struct __md
{
        struct __md *m_link;
        void        *m_start;
        long        m_length;
        BASPAG      *m_own;
} MD;


typedef struct          /* used by Getmpb */
{
        MD *mp_mfl;
        MD *mp_mal;
        MD *mp_rover;
} MPB;

typedef struct
{
        int   (*Bconstat) ();
        long  (*Bconin) ();
        int   (*Bcostat) ();
        void  (*Bconout) ();
        long  (*Rsconf) ();
        IOREC *iorec;
} MAPTAB;

typedef struct
{
        MAPTAB *maptab;
        int    maptabsize;
} BCONMAP;

/* system variable _sysbase (0x4F2L) points to next structure         */
typedef struct _syshdr
{
    unsigned       os_entry;   /* $00 BRA to reset handler             */
    unsigned       os_version; /* $02 TOS version number               */
    void           *os_start;  /* $04 -> reset handler                 */
    struct _syshdr *os_base;   /* $08 -> baseof OS                     */
    void           *os_membot; /* $0c -> end BIOS/GEMDOS/VDI ram usage */
    void           *os_rsv1;   /* $10 << unused,reserved >>            */
    long           *os_magic;  /* $14 -> GEM memoryusage parm. block   */
    long           os_gendat;  /* $18 Date of system build($MMDDYYYY)  */
    int            os_palmode; /* $1c OS configuration bits            */
    int            os_gendatg; /* $1e DOS-format date of systembuild   */
/*
    The next three fields are only available in TOS versions 1.2 and
    greater
*/
    void           *_root;     /* $20 -> base of OS pool               */
    long           *kbshift;   /* $24 -> keyboard shift state variable */
    BASPAG         **_run;     /* $28 -> GEMDOS PID of current process */
    void           *p_rsv2;    /* $2c << unused, reserved >>           */
} SYSHDR;



/* attributes for Fcreate/Fsfirst/Fsnext: */

#define FA_READONLY     0x01
#define FA_HIDDEN       0x02
#define FA_SYSTEM       0x04
#define FA_VOLUME       0x08
#define FA_SUBDIR       0x10
#define FA_ARCHIVE      0x20

/* Fopen modes: */

#define FO_READ         0
#define FO_WRITE        1
#define FO_RW           2

extern BASPAG *_BasPag;
extern long _PgmSize;

long    gemdos( void, ... );
long    bios( void, ... );
long    xbios( void, ... );

/****** Tos *************************************************************/

void    Pterm0( void );
long    Cconin( void );
void    Cconout( int c );
int     Cauxin( void );
void    Cauxout( int c );
int     Cprnout( int c );
long    Crawio( int w );
long    Crawcin( void );
long    Cnecin( void );
int     Cconws( const char *buf );
void    Cconrs( LINE *buf );
int     Cconis( void );
int     Dsetdrv( int drv );
int     Cconos( void );
int     Cprnos( void );
int     Cauxis( void );
int     Cauxos( void );
int     Dgetdrv( void );
void    Fsetdta( DTA *buf );
long    Super( void *stack );
unsigned int  Tgetdate( void );
unsigned int Tsetdate( unsigned int date );
unsigned int  Tgettime( void );
unsigned int  Tsettime( unsigned int time );
DTA     *Fgetdta( void );
int     Sversion( void );
void    Ptermres( long keepcnt, int retcode );
int     Dfree( DISKINFO *buf, int driveno );
int     Dcreate( const char *path );
int     Ddelete( const char *path );
int     Dsetpath( const char *path );
int     Fcreate( const char *filename, int attr );
int     Fopen( const char *filename, int mode );
int     Fclose( int handle );
long    Fread( int handle, long count, void *buf );
long    Fwrite( int handle, long count, void *buf );
int     Fdelete( const char *filename );
long    Fseek( long offset, int handle, int seekmode );
int     Fattrib( const char *filename, int wflag, int attrib );
int     Fdup( int handle );
int     Fforce( int stch, int nonstdh );
int     Dgetpath( char *path, int driveno );
void    *Malloc( long number );
int     Mfree( void *block );
int     Mshrink( int zero, void *block, long newsiz );
long    Pexec( int mode, char *ptr1, void *ptr2, void *ptr3 );
void    Pterm( int retcode );
int     Fsfirst( const char *filename, int attr );
int     Fsnext( void );
int     Frename( int zero, const char *oldname, const char *newname );
int     Fdatime( DOSTIME *timeptr, int handle, int wflag );


/****** Network Gemdos Extension ****************************************/

long    Nversion( void );
long    Frlock( int handle, long start, long count );
long    Frunlock( int handle, long start );
long    Flock( int handle, long count );
long    Funlock( int handle );
long    Fflush( int handle );
long    Unlock( const char *path );
long    Lock( const char *path );

/****** Bios ************************************************************/

void    Getmpb( MPB *ptr );
int     Bconstat( int dev );
long    Bconin( int dev );
void    Bconout( int dev, int c );
long    Rwabs( int rwflag, void *buf, int cnt, int recnr, int dev );
void    (*Setexc( int number, void (*exchdlr)() )) ();
long    Tickcal( void );
BPB     *Getbpb( int dev );
long    Bcostat( int dev );
long    Mediach( int dev );
long    Drvmap( void );
long    Kbshift( int mode );


/****** XBios ***********************************************************/

void    Initmouse( int type, MOUSE *par, void (*mousevec)() );
void    *Ssbrk( int count );
void    *Physbase( void );
void    *Logbase( void );
int     Getrez( void );
void    Setscreen( void *laddr, void *paddr, int rez );
void    Setpalette( void *pallptr );
int     Setcolor( int colornum, int color );
int     Floprd( void *buf, long filler, int devno, int sectno,
               int trackno, int sideno, int count );
int     Flopwr( void *buf, long filler, int devno, int sectno,
               int trackno, int sideno, int count );
int     Flopfmt( void *buf, long filler, int devno, int spt, int trackno,
                int sideno, int interlv, long magic, int virgin );
void    Midiws( int cnt, void *ptr );
void    Mfpint( int erno, void (*vector)() );
IOREC   *Iorec( int dev );
long    Rsconf( int baud, int ctr, int ucr, int rsr, int tsr, int scr );
KEYTAB  *Keytbl( void *unshift, void *shift, void *capslock );
long    Random( void );
void    Protobt( void *buf, long serialno, int disktype, int execflag );
int     Flopver( void *buf, long filler, int devno, int sectno,
                int trackno, int sideno, int count );
void    Scrdmp( void );
int     Cursconf( int func, int rate );
void    Settime( unsigned long time );
unsigned long  Gettime( void );
void    Bioskeys( void );
void    Ikbdws( int count, void *ptr );
void    Jdisint( int number );
void    Jenabint( int number );
char    Giaccess( char data, int regno );
void    Offgibit( int bitno );
void    Ongibit( int bitno );
void    Xbtimer( int timer, int control, int data, void (*vector)() );
void    *Dosound( void *buf );
int     Setprt( int config );
KBDVBASE *Kbdvbase( void );
int     Kbrate( int initial, int repeat );
void    Prtblk( PBDEF *par );
void    Vsync( void );
long    Supexec( long (*func)() );
void    Puntaes( void );
int     Floprate( int devno, int newrate );
int     Blitmode( int mode );

/* TOS030 XBios */
int     DMAread( long sector, int count, void *buffer, int devno );
int     DMAwrite( long sector, int count, void *buffer, int devno );
long    Bconmap( int devno );
int     Esetshift( int shftMode );
int     Egetshift( void );
int     EsetBank( int bankNum );
int     EsetColor( int colorNum, int color );
void    EsetPalette( int colorNum, int count, int *palettePtr );
void    EgetPalette( int colorNum, int count, int *palettePtr );
int     EsetGray( int swtch );
int     EsetSmear( int swtch );

#endif

/************************************************************************/
