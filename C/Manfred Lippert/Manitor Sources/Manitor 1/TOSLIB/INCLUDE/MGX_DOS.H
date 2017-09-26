/*      MGX_DOS.H

     MagiC GEMDOS/(X)BIOS Definition Includes

	Andreas Kromke
	31.1.98
*/


#ifndef LONG
#include <portab.h>
#endif
#ifndef NULL
#define NULL        ((void *)0L)
#endif
#ifndef EOS
#define EOS         '\0'
#endif

#if !defined( __TOS )
#define __TOS


/* File Access Types */

#define RMODE_RD 0
#define RMODE_WR 1
#define RMODE_RW 2

/* Device Identifiers  (BIOS) */

#define PRT	0
#define AUX	1
#define CON	2
#define MIDI	3
#define IKBD	4
#define RAWCON	5		   /* no control- characters */

/* GEMDOS- Device- Handles */

#define HDL_CON -1
#define HDL_AUX -2
#define HDL_PRN -3
#define HDL_NUL -4		   /* KAOS extension */

/* GEMDOS- Standard- Handles */

#define STDIN	 0
#define STDOUT	 1
#define STDAUX	 2
#define STDPRN	 3
#define STDERR	 4
#define STDXTRA 5

/* File Attributes */

#define F_RDONLY 0x01
#define F_HIDDEN 0x02
#define F_SYSTEM 0x04
#define F_VOLUME 0x08
#define F_SUBDIR 0x10
#define F_ARCHIVE 0x20

/* BIOS level errors */

#define E_OK	  0L	/* OK, no error 		*/
#define ERROR	 -1L	/* basic, fundamental error	*/
#define EDRVNR	 -2L	/* drive not ready		*/
#define EUNCMD	 -3L	/* unknown command		*/
#define E_CRC	 -4L	/* CRC error			*/
#define EBADRQ	 -5L	/* bad request			*/
#define E_SEEK	 -6L	/* seek error			*/
#define EMEDIA	 -7L	/* unknown media		*/
#define ESECNF	 -8L	/* sector not found		*/
#define EPAPER	 -9L	/* no paper			*/
#define EWRITF	-10L	/* write fault			*/
#define EREADF	-11L	/* read fault			*/
#define EGENRL	-12L	/* general error		*/
#define EWRPRO	-13L	/* write protect		*/
#define E_CHNG	-14L	/* media change 		*/
#define EUNDEV	-15L	/* unknown device		*/
#define EBADSF	-16L	/* bad sectors on format	*/
#define EOTHER	-17L	/* insert other disk	*/

/* BDOS level errors */

#define EINVFN	-32L	/* invalid function number		 1 */
#define EFILNF	-33L	/* file not found				 2 */
#define EPTHNF	-34L	/* path not found				 3 */
#define ENHNDL	-35L	/* no handles left				 4 */
#define EACCDN	-36L	/* access denied				 5 */
#define EIHNDL	-37L	/* invalid handle				 6 */
#define ENSMEM	-39L	/* insufficient memory			 8 */
#define EIMBA	-40L	/* invalid memory block address 	 9 */
#define EDRIVE	-46L	/* invalid drive was specified	15 */
#define ENSAME -48L /* MV between two different drives 17 */
#define ENMFIL	-49L	/* no more files				18 */

/* our own inventions */

#define ERANGE	-64L	/* range error					33 */
#define EINTRN	-65L	/* internal error				34 */
#define EPLFMT	-66L	/* invalid program load format	35 */
#define EGSBF	-67L	/* setblock failure 			36 */

/* KAOS extensions */

#define EBREAK	-68L	/* user break (^C)				37 */
#define EXCPT	-69L	/* 68000- exception ("bombs")		38 */

/* MiNT extensions */

#define ELOCKED -58L
#define ENSLOCK -59L

/*  MagiC extensions */

#define EPTHOV -70L /* path overflow                           MAG!X    */
#define ELOOP  -80L /* too many symlinks in path               MiNT */

/* GEMDOS Pexec Modes */

#define EXE_LDEX    0                                       /* TOS */
#define EXE_LD      3                                       /* TOS */
#define EXE_EX      4                                       /* TOS */
#define EXE_BASE    5                                       /* TOS */
#define EXE_EXFR    6                                       /* TOS 1.4  */
#define EXE_XBASE   7                                       /* TOS 3.01 */


/* GEMDOS (MiNT) Fopen modes */

#define   OF_RDONLY       0
#define   OF_WRONLY       1
#define   OF_RDWR         2
#define   OF_APPEND       8
#define   OF_COMPAT       0
#define   OF_DENYRW       0x10
#define   OF_DENYW        0x20
#define   OF_DENYR        0x30
#define   OF_DENYNONE     0x40
#define   OF_CREAT        0x200
#define   OF_TRUNC        0x400
#define   OF_EXCL         0x800

/* GEMDOS Fseek Modes */

#define SEEK_SET    0                                       /* TOS */
#define SEEK_CUR    1                                       /* TOS */
#define SEEK_END    2                                       /* TOS */

/* Psemaphore */

#define PSEM_CRGET       0                                  /* MagiC 3.0 */
#define PSEM_DESTROY     1
#define PSEM_GET         2
#define PSEM_RELEASE     3

/* Dlock modes */

#define DLOCKMODE_LOCK   1
#define DLOCKMODE_UNLOCK 0
#define DLOCKMODE_GETPID 2

/* Dopendir modes */

#define DOPEN_COMPAT     1
#define DOPEN_NORMAL     0

/* Fxattr modes */

#define FXATTR_RESOLVE	0
#define FXATTR_NRESOLVE	1

/* Pdomain modes */

#define PDOM_TOS         0
#define PDOM_MINT        1

/* Modi und Codes fÅr Dpathconf() (-> MiNT) */

#define   DP_MAXREQ      -1
#define   DP_IOPEN       0
#define   DP_MAXLINKS    1
#define   DP_PATHMAX     2
#define   DP_NAMEMAX     3
#define   DP_ATOMIC      4
#define   DP_TRUNC       5
#define    DP_NOTRUNC    0
#define    DP_AUTOTRUNC  1
#define    DP_DOSTRUNC   2
#define   DP_CASE        6
#define    DP_CASESENS   0
#define    DP_CASECONV   1
#define    DP_CASEINSENS 2
#define DP_MODEATTR		7
#define	DP_ATTRBITS	0x000000ffL
#define	DP_MODEBITS	0x000fff00L
#define	DP_FILETYPS	0xfff00000L
#define	DP_FT_DIR		0x00100000L
#define	DP_FT_CHR		0x00200000L
#define	DP_FT_BLK		0x00400000L
#define	DP_FT_REG		0x00800000L
#define	DP_FT_LNK		0x01000000L
#define	DP_FT_SOCK	0x02000000L
#define	DP_FT_FIFO	0x04000000L
#define	DP_FT_MEM		0x08000000L
#define DP_XATTRFIELDS	8
#define	DP_INDEX		0x0001
#define	DP_DEV		0x0002
#define	DP_RDEV		0x0004
#define	DP_NLINK		0x0008
#define	DP_UID		0x0010
#define	DP_GID		0x0020
#define	DP_BLKSIZE	0x0040
#define	DP_SIZE		0x0080
#define	DP_NBLOCKS	0x0100
#define	DP_ATIME		0x0200
#define	DP_CTIME		0x0400
#define	DP_MTIME		0x0800

/* additional Dcntl/Fcntl Modes */

#define CDROMEJECT			(('C'<<8)|0x09)
#define CDROMPREVENTREMOVAL	(('C'<<8)|0x0e)
#define CDROMALLOWREMOVAL	(('C'<<8)|0x0f)
#define KER_DRVSTAT			0x0104	/* Kernel: Drive-Status (ab 9.9.95) */
#define KER_XFSNAME			0x0105	/* Kernel: XFS-Name (ab 15.6.96) */
#define VFAT_CNFDFLN		0x5600	/* VFAT-XFS: ab 2.1.96 */
#define VFAT_CNFLN			0x5601	/* VFAT-XFS: ab 2.1.96 */

/* D/Fcntl(FUTIME,...) */

struct mutimbuf
     {
     unsigned int actime;          /* Zugriffszeit */
     unsigned int acdate;
     unsigned int modtime;         /* letzte énderung */
     unsigned int moddate;
     };

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


typedef struct          /* used by Getbpb */
{
        int     recsiz;
        int     clsiz;
        int     clsizb;
        int     rdlen;
        int     fsiz;
        int     fatrec;
        int     datrec;
        int     numcl;
        int     bflags;
} BPB;


typedef struct
{
        unsigned int  time;
        unsigned int  date;
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
        int     pb_prtype;
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


/* Cookie structure */

typedef struct {
	long		key;
	long		value;
} COOKIE;

/* Sconfig(2) -> */

typedef struct
   {
   char      *in_dos;                 /* Adresse der DOS- Semaphore */
   int       *dos_time;               /* Adresse der DOS- Zeit      */
   int       *dos_date;               /* Adresse des DOS- Datums    */
   long      res1;                    /*                            */
   long      res2;                    /*                            */
   long      res3;                    /* ist 0L                     */
   void      *act_pd;                 /* Laufendes Programm         */
   long      res4;                    /*                            */
   int       res5;                    /*                            */
   void      *res6;                   /*                            */
   void      *res7;                   /* interne DOS- Speicherliste */
   void      (*resv_intmem)();        /* DOS- Speicher erweitern    */
   long      (*etv_critic)();         /* etv_critic des GEMDOS      */
   char *    ((*err_to_str)(char e)); /* Umrechnung Code->Klartext  */
   long      res8;                    /*                            */
   long      res9;                    /*                            */
   long      res10;                   /*                            */
   } DOSVARS;

/* os_magic -> */

typedef struct
     {
     long magic;                   /* muû $87654321 sein              */
     void *membot;                 /* Ende der AES- Variablen         */
     void *aes_start;              /* Startadresse                    */
     long magic2;                  /* ist 'MAGX'                      */
     long date;                    /* Erstelldatum ttmmjjjj           */
     void (*chgres)(int res, int txt);  /* Auflîsung Ñndern           */
     long (**shel_vector)(void);   /* residentes Desktop              */
     char *aes_bootdrv;            /* von hieraus wurde gebootet      */
     int  *vdi_device;             /* vom AES benutzter VDI-Treiber   */
     void *reservd1;
     void *reservd2;
     void *reservd3;
     int  version;                 /* z.B. $0201 ist V2.1             */
     int  release;                 /* 0=alpha..3=release              */
     } AESVARS;

/* Cookie MagX --> */

typedef struct
     {
     long    config_status;
     DOSVARS *dosvars;
     AESVARS *aesvars;
     void *res1;
     void *hddrv_functions;
     long status_bits;             /* MagiC 3 ab 24.5.95         */
     } MAGX_COOKIE;

/* Bits for <status_bits> in MAGX_COOKIE (read only!) */

#define MGXSTB_TSKMAN_ACTIVE  1    /* MagiC task manager is currently active */

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
long    Cconrs( LINE *buf );
int     Cconis( void );
long    Dsetdrv( int drv );
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
long    Fcreate( const char *filename, int attr );
long    Fopen( const char *filename, int mode );
int     Fclose( int handle );
long    Fread( int handle, long count, void *buf );
long    Fwrite( int handle, long count, void *buf );
long    Fdelete( const char *filename );
long    Fseek( long offset, int handle, int seekmode );
int     Fattrib( const char *filename, int wflag, int attrib );
long    Fdup( int handle );
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

/****** MagiC 030 Gemdos Extension ****************************************/

/* new GEMDOS- Calls */

#define SCONFIG		0x33							/* KAOS 1.2 */
#define Sconfig(a,b)    gemdos(0x33, (int) (a), (long) (b)) /* KAOS 1.2 */
/* extern long Sconfig(WORD fn, ...); */
#define Fshrink(a)      Fwrite(a, 0L, (void *) -1L)         /* KAOS 1.2 */
#define Mgrow(a,b)      Mshrink(a,b)                        /* KAOS 1.2 */
#define Mblavail(a)     Mshrink(a,-1L)                      /* KAOS 1.2 */
#define Ssync()         gemdos(0x150)					/* MagiC 4.01 */

/* Sconfig - Functions */

#define SC_GETCONF   0                                      /* KAOS 1.2 */
#define SC_SETCONF   1                                      /* KAOS 1.2 */
#define SC_DOSVARS   2                                      /* KAOS 1.4 */
#define SC_MOWNER	 3		/* reserviert */			/* MagiC 3.00 */
#define SC_WBACK	 4								/* MagiC 4.01 */
#define  SCWB_GET	 0		/* (fÅr WBDAEMON) */		/* MagiC 4.01 */
#define  SCWB_SET    1								/* MagiC 4.01 */
#define  SCWB_RESET  2								/* MagiC 4.01 */
#define SC_INTMAVAIL 5        /* reserviert */			/* MagiC 4.01 */
#define SC_INTGARBC  6		/* reserviert */			/* MagiC 4.01 */

/* Sconfig Bits */

#define SCB_PTHCK   0x001                                   /* KAOS 1.2 */
#define SCB_DSKCH   0x002                                   /* KAOS 1.2 */
#define SCB_BREAK   0x004                                   /* KAOS 1.2 */
#define SCB_NCTLC   0x008                                   /* KAOS 1.2 */
#define SCB_NFAST   0x010                                   /* KAOS 1.2 */
#define SCB_CMPTB   0x020                                   /* KAOS 1.4 */
#define SCB_NSMRT   0x040                                   /* KAOS 1.4 */
#define SCB_NGRSH   0x080                                   /* KAOS 1.4 */
#define SCB_NHALT   0x100                                   /* KAOS 1.4 */
#define SCB_RESVD   0x200                                   /* KAOS 1.4 */
#define SCB_PULLM   0x400                                   /* KAOS 1.4 */
#define SCB_FLPAR   0x800                                   /* MagiC 3.0 */

/* Memory Control Block */

typedef struct
     {
     long mcb_magic;                    /* 'ANDR' oder 'KROM' (letzter)    */
     long mcb_len;                      /* NettolÑnge                      */
     long mcb_owner;                    /* PD *                            */
     long mcb_prev;                     /* vorh. Block oder NULL           */
     char mcb_data[0];
     } MCB;

/****** TOS 030 Gemdos Extension ****************************************/

void    *Mxalloc( long number, int mode );
long    Maddalt( void *start, long size );

/****** Network Gemdos Extension ****************************************/

long    Flock( int handle, int mode, long start, long length );

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
int     Floprd( void *buf, void *filler, int devno, int sectno,
               int trackno, int sideno, int count );
int     Flopwr( void *buf, void *filler, int devno, int sectno,
               int trackno, int sideno, int count );
int     Flopfmt( void *buf, void *filler, int devno, int spt, int trackno,
                int sideno, int interlv, long magic, int virgin );
void    Midiws( int cnt, void *ptr );
void    Mfpint( int erno, void (*vector)() );
IOREC   *Iorec( int dev );
long    Rsconf( int baud, int ctr, int ucr, int rsr, int tsr, int scr );
KEYTAB  *Keytbl( void *unshift, void *shift, void *capslock );
long    Random( void );
void    Protobt( void *buf, long serialno, int disktype, int execflag );
int     Flopver( void *buf, void *filler, int devno, int sectno,
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
int     NVMaccess( int opcode, int start, int count, void *buffer );
long    Bconmap( int devno );
int     Esetshift( int shftMode );
int     Egetshift( void );
int     EsetBank( int bankNum );
int     EsetColor( int colorNum, int color );
void    EsetPalette( int colorNum, int count, int *palettePtr );
void    EgetPalette( int colorNum, int count, int *palettePtr );
int     EsetGray( int swtch );
int     EsetSmear( int swtch );

/* MinT Gemdos */

/* Fcntl opcodes */

#define   FSTAT          0x4600
#define   FIONREAD       0x4601
#define   FIONWRITE      0x4602
#define   FUTIME         0x4603
#define   FTRUNCATE      0x4604
#define   SHMGETBLK      0x4d00
#define   SHMSETBLK      0x4d01
#define   PBASEADDR      0x5002

/* signal handling */

#define NSIG       31       /* number of signals recognized   */

#define SIGNULL     0       /* not really a signal             */
#define SIGHUP      1       /* hangup signal                   */
#define SIGINT      2       /* sent by ^C                      */
#define SIGQUIT     3       /* quit signal                     */
#define SIGILL      4       /* illegal instruction             */
#define SIGTRAP     5       /* trace trap                      */
#define SIGABRT     6       /* abort signal                    */
#define SIGPRIV     7       /* privilege violation             */
#define SIGFPE      8       /* divide by zero                  */
#define SIGKILL     9       /* cannot be ignored               */
#define SIGBUS     10       /* bus error                       */
#define SIGSEGV    11       /* illegal memory reference        */
#define SIGSYS     12       /* bad argument to a system call   */
#define SIGPIPE    13       /* broken pipe                     */
#define SIGALRM    14       /* alarm clock                     */
#define SIGTERM    15       /* software termination signal     */
#define SIGURG     16       /* urgent condition on I/O channel */
#define SIGSTOP    17       /* stop signal not from terminal   */
#define SIGTSTP    18       /* stop signal from terminal       */
#define SIGCONT    19       /* continue stopped process        */
#define SIGCHLD    20       /* child stopped or exited         */
#define SIGTTIN    21       /* read by background process      */
#define SIGTTOU    22       /* write by background process     */
#define SIGIO      23       /* I/O possible on a descriptor    */
#define SIGXCPU    24       /* CPU time exhausted              */
#define SIGXFSZ    25       /* file size limited exceeded      */
#define SIGVTALRM  26       /* virtual timer alarm             */
#define SIGPROF    27       /* profiling timer expired         */
#define SIGWINCH   28       /* window size changed             */
#define SIGUSR1    29       /* user signal 1                   */
#define SIGUSR2    30       /* user signal 2                   */

#define SIG_DFL    0        /* default signal handler          */
#define SIG_IGN    1        /* ignore the signal               */


/* file types */
#define S_IFMT  0170000     /* mask to select file type */
#define S_IFCHR 0020000     /* BIOS special file */
#define S_IFDIR 0040000     /* directory file */
#define S_IFREG 0100000     /* regular file */
#define S_IFIFO 0120000     /* FIFO */
#define S_IMEM  0140000     /* memory region or process */
#define S_IFLNK 0160000     /* symbolic link */

/* special bits: setuid, setgid, sticky bit */
#define S_ISUID 04000
#define S_ISGID 02000
#define S_ISVTX 01000

/* file access modes for user, group, and other*/
#define S_IRUSR         0400
#define S_IWUSR         0200
#define S_IXUSR         0100
#define S_IRGRP         0040
#define S_IWGRP         0020
#define S_IXGRP         0010
#define S_IROTH         0004
#define S_IWOTH         0002
#define S_IXOTH         0001
#define DEFAULT_DIRMODE (0777)
#define DEFAULT_MODE    (0666)


typedef struct
{
        long     msg1;
        long     msg2;
        int      pid;
} MSG;

typedef struct
{
        unsigned int   mode;
        long           index;
        unsigned int   dev;
        unsigned int   reserved1;
        unsigned int   nlink;
        unsigned int   uid;
        unsigned int   gid;
        long           size;
        long           blksize;
        long           nblocks;
        int            mtime;
        int            mdate;
        int            atime;
        int            adate;
        int            ctime;
        int            cdate;
        int            attr;
        int            reserved2;
        long           reserved3[2];
} XATTR;


#define SA_NOCLDSTOP    1

typedef struct
{
        void    cdecl (*sa_handler)( long sig );
        long    sa_mask;
        int     sa_flags;
} SIGACTION;


int     Syield( void );
int     Fpipe( int *usrh );
int     Fcntl( int f, long arg, int cmd );
long    Finstat( int f );
long    Foutstat( int f );
long    Fgetchar( int f, int mode );
long    Fputchar( int f, long c, int mode );
long    Pwait( void );
int     Pnice( int delta );
int     Pgetpid( void );
int     Pgetppid( void );
int     Pgetpgrp( void );
int     Psetpgrp( int pid, int newgrp );
int     Pgetuid( void );
int     Psetuid( int id );
int     Pkill( int pid, int sig );
void    *Psignal( int sig, void *handler );
int     Pvfork( void );
int     Pgetgid( void );
int     Psetgid( int id );
long    Psigblock( long mask );
long    Psigsetmask( long mask );
long    Pusrval( long arg );
int     Pdomain( int newdom );
long    Psigreturn( void );
int     Pfork( void );
long    Pwait3( int flag, long *rusage );
int     Fselect( unsigned int timeout, long *rfds, long *wfds, long *xfds );
void    Prusage( long *r );
long    Psetlimit( int lim, long value );
long    Talarm( long secs );
void    Pause( void );
long    Sysconf( int n );
long    Psigpending( void );
long    Dpathconf( char *name, int n );
long    Pmsg( int mode, long mbox, MSG *msg );
long    Fmidipipe( int pid, int in, int out );
int     Prenice( int pid, int delta );
long    Dopendir( char *name, int flag );
long    Dreaddir( int buflen, long dir, char *buf );
long    Drewinddir( long dir );
long    Dclosedir( long dir );
long    Fxattr( int flag, char *name, XATTR *buf );
long    Flink( char *oldname, char *newname );
long    Fsymlink( char *oldname, char *newname );
long    Freadlink( int size, char *buf, char *name );
long    Dcntl( int cmd, char *name, long arg );
long    Fchown( char *name, int uid, int gid );
long    Fchmod( char *name, int mode );
long    Pumask( unsigned int mode );
long    Psemaphore( int mode, long id, long timeout );
long    Dlock( int mode, int drive );
void    Psigpause( unsigned long mask );
long    Psigaction( int sig, SIGACTION *act, SIGACTION *oact );
int     Pgeteuid( void );
int     Pgetegid( void );
long    Pwaitpid( int pid, int flag, long *rusage );

/* Falcon */

#define VERTFLAG          0x0100
#define STMODES           0x0080
#define OVERSCAN          0x0040
#define PAL               0x0020
#define VGA_FALCON        0x0010
#define TV                0x0000

#define COL80             0x08
#define COL40             0x00

#define BPS16             4
#define BPS8              3
#define BPS4              2
#define BPS2              1
#define BPS1              0

#define NUMCOLS           7


typedef struct
{
    int     blocktype;
    long    blocksize;
    void    *blockaddr;
} DSPBLOCK;


long    locksnd( void );
long    unlocksnd( void );
long    soundcmd( int mode, int data );
long    setbuffer( int reg, void *begaddr, void *endaddr );
long    setmode( int mode );
long    settracks( int playtracks, int rectracks );
long    setmontracks( int montrack );
long    setinterrupt( int src_inter, int cause );
long    buffoper( int mode );
long    dsptristate( int dspxmit, int dsprec );
long    gpio( int mode, int data );
long    devconnect( int src, int dst, int srcclk, int prescale,
                    int protocol );
long    sndstatus( int reset );
long    buffptr( long *ptr );

int     Dsp_LoadProg( char *file, int ability, char *buffer );
long    Dsp_LodToBinary( char *file, char *codeptr );
void    Dsp_DoBlock( char *data_in, long size_in, char *data_out,
                     long size_out );
void    Dsp_BlkHandShake( char *data_in, long size_in, char *data_out,
                          long size_out );
void    Dsp_BlkUnpacked( long *data_in, long size_in, long *data_out,
                         long size_out );
void    Dsp_InStream( char *data_in, long block_size, long num_blocks,
                      long *blocks_done );
void    Dsp_OutStream( char *data_out, long block_size, long num_blocks,
                       long *blocks_done );
void    Dsp_IOStream( char *data_in, char *data_out, long block_insize,
                      long block_outsize, long num_blocks,
                      long *blocks_done );
void    Dsp_RemoveInterrupts( int mask );
int     Dsp_GetWordSize( void );
int     Dsp_Lock( void );
void    Dsp_Unlock( void );
void    Dsp_Available( long *xavailable, long *yavailable );
int     Dsp_Reserve( long xreserve, long yreserve );
void    Dsp_ExecProg( char *codeptr, long codesize, int ability );
void    Dsp_ExecBoot( char *codeptr, long codesize, int ability );
void    Dsp_TriggerHC( int vector );
int     Dsp_RequestUniqueAbility( void );
int     Dsp_GetProgAbility( void );
void    Dsp_FlushSubroutines( void );
int     Dsp_LoadSubroutine( char *codeptr, long codesize, int ability );
int     Dsp_InqSubrAbility( int ability );
int     Dsp_RunSubroutine( int handle );
int     Dsp_Hf0( int flag );
int     Dsp_Hf1( int flag );
int     Dsp_Hf2( void );
int     Dsp_Hf3( void );
void    Dsp_BlkWords( void *data_in, long size_in, void *data_out,
                      long size_out );
void    Dsp_BlkBytes( void *data_in, long size_in, void *data_out,
                      long size_out );
char    Dsp_HStat( void );
void    Dsp_SetVectors( void (*receiver)( ), long (*transmitter)( ));
void    Dsp_MultBlocks( long numsend, long numreceive,
                        DSPBLOCK *sendblocks, DSPBLOCK *receiveblocks );
int     Vsetmode( int modecode );
int     mon_type( void );
long    VgetSize( int mode );
void    VsetSync( int flag );
void    VsetRGB( int index, int count, long *array );
void    VgetRGB( int index, int count, long *array );
void    VsetMask( int ormask, int andmask, int overlay );

typedef void *SHARED_LIB;
typedef long (*SLB_EXEC)( void , ... );
/*
	das geht leider in PureC nicht, weil PureC hier einen
	Fehler (!!!) hat: cdecl wird ignoriert, wenn die Funktion
	eine variable Anzahl von Parametern hat.

typedef LONG (cdecl *SLB_EXEC)( SHARED_LIB *sl, LONG fn, WORD nargs, ... );
*/

extern long Slbopen( char *name, char *path, long min_ver,
				SHARED_LIB *sl, SLB_EXEC *fn, long param );
extern long Slbclose( SHARED_LIB *sl );

#endif

/************************************************************************/
