/* tos.h for Turbo C / Pure C

   os structure definitions according to a) mintlib,
                                         b) Atari Profibuch ST/STE/TT
                                   and   c) Pure C                     */

#ifndef __TOS
#define __TOS

#ifndef __PROTO
#define __PROTO(x) x
#endif

/*
 * basepage structure
 *
 */

typedef struct basep {
    char	*p_lowtpa;	/* pointer to self (bottom of TPA) */
    char	*p_hitpa;	/* pointer to top of TPA + 1 */
    char	*p_tbase;	/* base of text segment */
    long	p_tlen;		/* length of text segment */
    char	*p_dbase;	/* base of data segment */
    long	p_dlen;		/* length of data segment */
    char	*p_bbase;	/* base of BSS segment */
    long	p_blen;		/* length of BSS segment */
    char	*p_dta;		/* (UNOFFICIAL, DON'T USE) */
    struct basep *p_parent;	/* pointer to parent's basepage */
    char	*p_reserved;	/* reserved for future use */
    char	*p_env;		/* pointer to environment string */
#if 0
/* none of these are documented by Atari. If you try to use them under MiNT,
 * MiNT will laugh at you. So will I.
 */
    char	devx[6];	/* real handles of the standard devices */
    char	res2;		/* reserved */
    char	defdrv;		/* default drv */
#else
    char	p_junk[8];
#endif
    long	p_undef[18];	/* scratch area... don't touch */
    char	p_cmdlin[128];	/* command line image */
} BASEPAGE;

extern	BASEPAGE	*_base;

#ifndef __NPROFIBUCH
# define basepage basep
#endif

#ifndef __NPURECDEF
# define baspag basep
# define BASPAG BASEPAGE
#endif

/*
 * General OS specific codes here
 *
 */

/*
 * GEMDOS defines and structures
 */

/* Structure used by Dfree() */
typedef struct {
    long b_free;	/* number of free clusters */
    long b_total;	/* total number of clusters */
    long b_secsiz;	/* number of bytes per sector */
    long b_clsiz;	/* number of sectors per cluster */
} _DISKINFO;

/* Structure returned by Fdatime() */
typedef struct {
  short time;
  short date;
} _DOSTIME;

/* Structure used by Fgetdta(), Fsetdta(), Fsfirst(), Fsnext() */
typedef struct _dta {
    char 	    dta_buf[21];	/* reserved */
    char            dta_attribute;	/* file attribute */
    unsigned short  dta_time;		/* file time stamp */
    unsigned short  dta_date;		/* file date stamp */
    long            dta_size;		/* file size */
    char            dta_name[14];	/* file name */
} _DTA;

/* Codes used with Fsfirst() */

#define        FA_RDONLY           0x01
#define        FA_HIDDEN           0x02
#define        FA_SYSTEM           0x04
#define        FA_LABEL            0x08
#define        FA_DIR              0x10
#define        FA_CHANGED          0x20

/* Codes used with Pexec */

#define        PE_LOADGO           0           /* load & go */
#define        PE_LOAD             3           /* just load */
#define        PE_GO               4           /* just go */
#define        PE_CBASEPAGE        5           /* just create basepage */
/* Tos 1.4: like 4, but memory ownership changed to child, and freed
   on exit
 */
#define        PE_GO_FREE          6           /* just go, then free */

#ifdef __MINT__
/* ers: what exactly does mode 7 do ??? */
#  define	PE_ASYNC_LOADGO	   100	       /* load and asynchronously go */
#  define       PE_ASYNC_GO	   104	       /* asynchronously go	     */
#  define       PE_ASYNC_GO_FREE   106	       /* asynchronously go and free */
#  define       PE_OVERLAY	   200	       /* load and overlay	     */
#endif

/*
 * BIOS defines and structures
 */

/* Device codes for Bconin(), Bconout(), Bcostat(), Bconstat() */
#define _PRT    0
#define _AUX    1
#define _CON    2
#define _MIDI   3
#define _IKBD   4
#define _RAWCON 5

/* Structure returned by Getbpb() */
typedef struct {
  short recsiz;         /* bytes per sector */
  short clsiz;          /* sectors per cluster */
  short clsizb;         /* bytes per cluster */
  short rdlen;          /* root directory size */
  short fsiz;           /* size of file allocation table */
  short fatrec;         /* startsector of second FAT */
  short datrec;         /* first data sector */
  short numcl;          /* total number of clusters */
  short bflags;         /* some flags */
} _BPB;

/* Structures used by Getmpb() */

/* Memory descriptor */
typedef struct _md {
    struct _md	*md_next;	/* next descriptor in the chain */
    long	 md_start;	/* starting address of block */
    long	 md_length;	/* length of the block */
    long	 md_owner;	/* owner's process descriptor */
} _MD;

/* Memory parameter block */
typedef struct {
    _MD *mp_free;		/* free memory chunks */
    _MD *mp_used;		/* used memory descriptors */
    _MD *mp_rover;		/* rover memory descriptor */
} _MPB;


/*
 * XBIOS defines and structures
 */

/* Codes used with Cursconf() */
#define CURS_HIDE   	0
#define CURS_SHOW   	1
#define CURS_BLINK  	2
#define CURS_NOBLINK    3
#define CURS_SETRATE    4
#define CURS_GETRATE    5

/* Structure returned by Iorec() */
typedef struct {
    char    *ibuf;
    short   ibufsiz;
    short   ibufhd;
    short   ibuftl;
    short   ibuflow;
    short   ibufhi;
} _IOREC;

/* Structure used by Initmouse() */
typedef struct {
	char	topmode;
	char	buttons;
	char	xparam;
	char	yparam;
} _PARAM;

/* Structure returned by Kbdvbase() */
typedef struct {
    void    (*midivec)	__PROTO((void));
    void    (*vkbderr)	__PROTO((void));
    void    (*vmiderr)	__PROTO((void));
    void    (*statvec)	__PROTO((void *));
    void    (*mousevec)	__PROTO((void *));
    void    (*clockvec)	__PROTO((void *));
    void    (*joyvec)	__PROTO((void *));
    long    (*midisys)	__PROTO((void));
    long    (*ikbdsys)	__PROTO((void));
    char    kbstate;
} _KBDVECS;

/* Structure returned by Keytbl() */
typedef struct {
    void *unshift;	/* pointer to unshifted keys */
    void *shift;	/* pointer to shifted keys */
    void *caps;		/* pointer to capslock keys */
} _KEYTAB;

/* Structure used by Prtblk() */
typedef struct
{
    void    *pb_scrptr;
    short   pb_offset;
    short   pb_width;
    short   pb_height;
    short   pb_left;
    short   pb_right;
    short   pb_screz;
    short   pb_prrez;
    void    *pb_colptr;
    short   pb_prtype;
    short   pb_prport;
    void    *pb_mask;
} _PBDEF;

/* Structure returned by Metainit() */
typedef struct
{
	unsigned long drivemap;
	char *version;
	long reserved[2];
} METAINFO;

/* Profibuch structure definitions */

#ifndef __NPROFIBUCH

#define DISKINFO _DISKINFO
#define DOSTIME _DOSTIME

typedef struct {
    char 	    dta_buf[21];	/* reserved */
    char            d_attrib;		/* file attribute */
    unsigned short  d_time;		/* file time stamp */
    unsigned short  d_date;		/* file date stamp */
    long            d_length;		/* file size */
    char            d_fname[14];	/* file name */
} DTA;

#define FA_DIREC FA_DIR
#define FA_ARCH 0x20
#define FA_ATTRIB (FA_DIREC|FA_RDONLY|FA_HIDDEN|FA_SYSTEM)

#define PRT _PRT
#define AUX _AUX
#define CON _CON
#define MIDI _MIDI
#define IKBD _IKBD
#define RAWCON _RAWCON

#define BPB _BPB

typedef struct md {
    struct md	*m_link;	/* next descriptor in the chain */
    long	 m_start;	/* starting address of block */
    long	 m_length;	/* length of the block */
    BASEPAGE	*m_own;		/* owner's process descriptor */
} MD;

typedef struct {
    MD *mp_mfl;		/* free memory chunks */
    MD *mp_mal;		/* used memory descriptors */
    MD *mp_rover;	/* rover memory descriptor */
} MPB;

#define IOREC _IOREC

#define PARAM _PARAM
typedef struct {
    short xmax;
    short ymax;
    short xinitial;
    short yinitial;
} EXTRA;

typedef struct {
    void    (*midivec)	__PROTO((void));
    void    (*vkbderr)	__PROTO((void));
    void    (*vmiderr)	__PROTO((void));
    void    (*statvec)	__PROTO((void *));
    void    (*mousevec)	__PROTO((void *));
    void    (*clockvec)	__PROTO((void *));
    void    (*joyvec)	__PROTO((void *));
    long    (*midisys)	__PROTO((void));
    long    (*ikbdsys)	__PROTO((void));
    char    drvstat;
} KBDVECS;

typedef struct {
    void *unshift;	/* pointer to unshifted keys */
    void *shift;	/* pointer to shifted keys */
    void *capslock;	/* pointer to capslock keys */
} KEYTAB;

#define PBDEF _PBDEF

/* Structure used by Cconrs */
typedef struct
{
    unsigned char maxlen;
    unsigned char actuallen;
    char    buffer[255];
} LINE;

/* Structures used by Bconmap */
#ifndef Bconin /* this does not work if system functions are macros */
typedef struct {
    short	(*Bconstat) ();
    long	(*Bconin) ();
    long	(*Bcostat) ();
    void	(*Bconout) ();
    long	(*Rsconf) ();
    IOREC	*iorec;
} MAPTAB;
#else
#define MAPTAB void
#endif

typedef struct {
    MAPTAB	*maptab;
    short	maptabsize;
} BCONMAP;

typedef struct _osheader
{
    unsigned short os_entry;   /* BRA to reset handler */
    unsigned short os_version; /* TOS version number */
    void           *reseth;    /* reset handler */
    struct _osheader *os_beg;  /* OS base */
    void           *os_end;    /* end of OS ram usage */
    void           *os_rsv1;   /* reserved */
    long           *os_magic;  /* GEM memory usage parm. block */
    long           os_date;    /* Date of system build, BCD */
    unsigned short os_conf;    /* OS configuration bits */
    unsigned short os_dosdate; /* DOS-format date of systembuild */
/* The following are available up from TOS 1.02 */
    char           **p_root;   /* base of OS pool */
    char           **kbshift;  /* keyboard shift state variable */
    BASEPAGE       **p_run;    /* GEMDOS PID of current process */
    void           *p_rsv2;    /* reserved */
} OSHEADER;

/* These are given for compatibility with Pure C tos.h */

#ifndef __NPURECDEF

#define FA_READONLY     0x01
#define FA_VOLUME       0x08
#define FA_SUBDIR       0x10
#define FA_ARCHIVE      0x20
#define FO_READ         0
#define FO_WRITE        1
#define FO_RW           2
#define KBDVBASE KBDVECS

typedef struct
{
    char    topmode;
    char    buttons;
    char    x_scale;
    char    y_scale;
    short   x_max;
    short   y_max;
    short   x_start;
    short   y_start;
} MOUSE;

typedef struct
{
    unsigned char ength;
    char command_tail[128];
} COMMAND;

#define __md md

typedef struct _syshdr
{
    unsigned os_entry;
    unsigned os_version;
    void *os_start;
    struct _syshdr *os_base;
    void *os_membot;
    void *os_rsv1;
    long *os_magic;
    long os_gendat;
    short os_palmode;
    short os_gendatg;
    void *_root;
    long *kbshift;
    BASPAG **_run;
    void *p_rsv2;
} SYSHDR;

#endif /* __PURECDEF */

#endif /* __NPROFIBUCH */


/*
 * os bindings
 *
 */

long    gemdos( void, ... );
long    bios( void, ... );
long    xbios( void, ... );

/* Gemdos prototypes */

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
long    Dsetdrv( int drv );
int     Cconos( void );
int     Cprnos( void );
int     Cauxis( void );
int     Cauxos( void );
int     Dgetdrv( void );
void    Fsetdta( _DTA *buf );
long    Super( void *stack );
unsigned int  Tgetdate( void );
unsigned int  Tsetdate( unsigned int date );
unsigned int  Tgettime( void );
unsigned int  Tsettime( unsigned int time );
_DTA    *Fgetdta( void );
int     Sversion( void );
void    Ptermres( long keepcnt, int retcode );
int     Dfree( _DISKINFO *buf, int driveno );
int     Dcreate( const char *path );
int     Ddelete( const char *path );
int     Dsetpath( const char *path );
long    Fcreate( const char *filename, int attr );
long    Fopen( const char *filename, int mode );
int     Fclose( int handle );
long    Fread( int handle, long count, void *buf );
long    Fwrite( int handle, long count, void *buf );
int     Fdelete( const char *filename );
long    Fseek( long offset, int handle, int seekmode );
int     Fattrib( const char *filename, int wflag, int attrib );
long    Fdup( int handle );
long    Fforce( int stch, int nonstdh );
int     Dgetpath( char *path, int driveno );
void    *Malloc( long number );
int     Mfree( void *block );
int     Mshrink( int zero, void *ptr, long size );
#define Mshrink(ptr, size) Mshrink(0, ptr, size)
long    Pexec( int mode, char *ptr1, void *ptr2, void *ptr3 );
void    Pterm( int retcode );
int     Fsfirst( const char *filename, int attr );
int     Fsnext( void );
int     Frename( int zero, const char *oldname, const char *newname );
int     Fdatime( _DOSTIME *timeptr, int handle, int wflag );

/* GEMDOS extensions */

void    *Mxalloc( long number, int mode );
long    Maddalt( void *start, long size );

/* Network Gemdos Extension */

long    Nversion( void );
long    Frlock( int handle, long start, long count );
long    Frunlock( int handle, long start );
long    Flock( int handle, long count );
long    Funlock( int handle );
long    Fflush( int handle );
long    Unlock( const char *path );
long    Lock( const char *path );

/* BIOS */

void    Getmpb( _MPB *ptr );
int     Bconstat( int dev );
long    Bconin( int dev );
void    Bconout( int dev, int c );
long    Rwabs( int rwflag, void *buf, int cnt, int recnr, int dev );
void    (*Setexc( int number, void (*exchdlr)() )) ();
long    Tickcal( void );
_BPB    *Getbpb( int dev );
long    Bcostat( int dev );
long    Mediach( int dev );
long    Drvmap( void );
long    Kbshift( int mode );
#define Getshift() Kbshift(-1)

/* XBios */

void    Initmouse( int type, _PARAM *par, void (*mousevec)() );
#define Initmous Initmouse
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
_IOREC   *Iorec( int dev );
long    Rsconf( int baud, int ctr, int ucr, int rsr, int tsr, int scr );
_KEYTAB  *Keytbl( void *unshift, void *shift, void *capslock );
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
_KBDVECS *Kbdvbase( void );
int     Kbrate( int initial, int repeat );
void    Prtblk( _PBDEF *par );
void    Vsync( void );
long    Supexec( long (*func)() );
#define Supexec(func) Supexec((long (*) ()) func)
void    Puntaes( void );
int     Floprate( int devno, int newrate );
void	Metainit( METAINFO *buffer) ;
int     Blitmode( int mode );

/* TOS030 XBios */
int     DMAread( long sector, int count, void *buffer, int devno );
int     DMAwrite( long sector, int count, void *buffer, int devno );
int     NVMaccess( int opcode, int start, int count, void *buffer );
long    Bconmap( int devno );
int     Esetshift( int shftMode );
#define EsetShift Esetshift
int     Egetshift( void );
#define EgetShift Egetshift
int     EsetBank( int bankNum );
int     EsetColor( int colorNum, int color );
void    EsetPalette( int colorNum, int count, int *palettePtr );
void    EgetPalette( int colorNum, int count, int *palettePtr );
int     EsetGray( int swtch );
int     EsetSmear( int swtch );

#endif

