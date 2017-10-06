/******************************************************************************/
/*																										*/
/*          Eine handoptimierte Bibliothek fÅr Pure-C und GNU-C               */
/*																										*/
/*          Die BIOS-, XBIOS- & GEMDOS-Funktionen - Headerdatei					*/
/*																										*/
/*	(c) 1999 by Martin ElsÑsser																*/
/******************************************************************************/

#ifndef __ACSTOS__
#define __ACSTOS__

#ifndef __ACSTYPE__
	#include <ACSTYPE.H>
#endif

/******************************************************************************/

#ifdef __cplusplusextern "C" {#endif
/******************************************************************************/
/*																										*/
/* Die Konstanten & Definitionen																*/
/*																										*/
/******************************************************************************/

/* Die Prototypen der TOS-Funktionen werden "verziert", */
/* damit GNU-C keine eigenstÑndigen Funktionen erzeugt, */
/* sondern echte inline-Funktionen verwendet... ;-)     */
#ifndef __GNUC__
	#define TOSFKT
#else
	#define TOSFKT static
#endif

/******************************************************************************/

/* Die TOS-Fehlernummern */
#define E_OK    0

/* BIOS errors */
#define ERROR   -1              /* generic error */
#define EDRVNR  -2              /* drive not ready */
#define EUNCMD  -3              /* unknown command */
#define E_CRC   -4              /* crc error */
#define EBADRQ  -5              /* bad request */
#define E_SEEK  -6              /* seek error */
#define EMEDIA  -7              /* unknown media */
#define ESECNF  -8              /* sector not found */
#define EPAPER  -9              /* out of paper */
#define EWRITF  -10             /* write fault */
#define EREADF  -11             /* read fault */
#define EWRPRO  -13             /* device write protected */
#define E_CHNG  -14             /* media change detected */
#define EUNDEV  -15             /* unknown device */
#define EBADSF  -16             /* bad sectors on format */
#define EOTHER  -17             /* insert other disk request */

/* GEMDOS errors */
#define EINVFN  -32             /* invalid function */
#define EFILNF  -33             /* file not found */
#define EPTHNF  -34             /* path not found */
#define ENHNDL  -35             /* no more handles */
#define EACCDN  -36             /* access denied */
#define EIHNDL  -37             /* invalid handle */
#define ENSMEM  -39             /* insufficient memory */
#define EIMBA   -40             /* invalid memory block address */
#define EDRIVE  -46             /* invalid drive specification */
#define EXDEV   -48             /* cross device rename */
#define ENMFIL  -49             /* no more files (from fsnext) */
#define ELOCKED -58             /* record is locked already */
#define ENSLOCK -59             /* invalid lock removal request */
#define ERANGE  -64             /* range error */
#define EINTRN  -65             /* internal error */
#define EPLFMT  -66             /* invalid program load format */
#define ENOEXEC EPLFMT
#define EGSBF   -67             /* memory block growth failure */
#define ENAMETOOLONG ERANGE     /* a filename component is too long */
#define ELOOP -80               /* too many symbolic links */

/* Eigentlich kein Fehler, sondern nur ein Hinweis an den Kernel: */
/*    "Mount Point may have been crossed"                         */
#define EMOUNT  -200

/******************************************************************************/

/* Modus fÅr Ssystem */
#define S_INQUIRE 		 -1
#define S_OSNAME			  0
#define S_OSXNAME			  1
#define S_OSVERSION		  2
#define S_OSHEADER		  3
#define S_OSBUILDDATE	  4
#define S_OSBUILDTIME	  5
#define S_OSCOMPILE		  6
#define S_OSFEATURES		  7
#define S_GETCOOKIE		  8
#define S_SETCOOKIE		  9
#define S_GETLVAL			 10
#define S_GETWVAL			 11
#define S_GETBVAL			 12
#define S_SETLVAL			 13
#define S_SETWVAL			 14
#define S_SETBVAL			 15
#define S_SECLEVEL		 16
#define S_RUNLEVEL		 17	/* currently disabled, reserved */
#define S_TSLICE			 18
#define S_FASTLOAD		 19
#define S_SYNCTIME		 20	/* reserved, use Dcntl */
#define S_BLOCKCACHE		 21
#define S_FLUSHCACHE		 22
#define S_CTRLCACHE		 23
#define S_CLOCKUTC		100
#define S_CLOCKMODE		100
#define S_TIOCMGET  		0x54f8 /* reserved for MiNT-Lib */

/* experimental - need feedback additional informations about the kernel */
/* reserved 900 - 999																	 */
#define S_KNAME			900	/* kernel name - arg1 pointer to a buffer of arg2 len */
#define S_CNAME			910	/* compiler name - arg1 pointer to a buffer of arg2 len */
#define S_CVERSION		911	/* compiler version - arg1 pointer to a buffer of arg2 len */
#define S_CDEFINES		912	/* compiler definitions - arg1 pointer to a buffer of arg2 len */
#define S_COPTIM			913	/* compiler flags - arg1 pointer to a buffer of arg2 len */

/* Debug Section (reserved 1000 - 1999) */
#define S_DEBUGLEVEL		1000	/* debug level */
#define S_DEBUGDEVICE	1001	/* BIOS device number */

/******************************************************************************/

#define FEAT_MP	1	/* memory protection enabled */
#define FEAT_VM	2	/* virtual memory manager enabled */

/******************************************************************************/

/* attributes for Fcreate/Fsfirst/Fsnext: */
#define FA_READONLY     0x01
#define FA_HIDDEN       0x02
#define FA_SYSTEM       0x04
#define FA_VOLUME       0x08
#define FA_SUBDIR       0x10
#define FA_ARCHIVE      0x20

/******************************************************************************/

/* Fopen modes */
#define FO_READ         0
#define FO_WRITE        1
#define FO_RW           2

/******************************************************************************/

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

/******************************************************************************/
/*																										*/
/* Die verschiedenen Datenstrukturen														*/
/*																										*/
/******************************************************************************/

/* Der BIOS-Parameterblock eines GerÑtes (siehe Getbpb) */
typedef struct
{
	INT16 recsiz;       /* Bytes pro Sektor      */
	INT16 clsiz;        /* Sektoren pro Cluster  */
	INT16 clsizb;       /* Bytes pro Cluster     */
	INT16 rdlen;        /* VerzeichnislÑnge      */
	INT16 fsiz;         /* LÑnge der FAT         */
	INT16 fatrec;       /* Start der 2. FAT      */
	INT16 datrec;       /* 1. freier Sektor      */
	INT16 numcl;        /* Gesamtzahl an Cluster */
	INT16 bflags;       /* Flags                 */
} BPB;

/******************************************************************************/

/* CD-Info-Struktur (siehe Metadiscinfo) */
typedef struct
{
	UCHAR disctype;
	UCHAR firsttrack, lasttrack, curtrack;
	UCHAR relposz, relposm, relposs, relposf;
	UCHAR absposz, absposm, absposs, absposf;
	UCHAR endposz, endposm, endposs, endposf;
	UCHAR index, res[3];
	UINT32 reserved[123];
} CD_DISC_INFO;

/******************************************************************************/

/* Struktur fÅr CD-Verzeichnis (siehe Metagettoc) */
typedef struct
{
	UCHAR trackno;
	UCHAR minute;
	UCHAR second;
	UCHAR frame;
} CD_TOC_ENTRY;

/******************************************************************************/

/* Struktur fÅr Cconrs */
typedef struct
{
	UCHAR maxlen;
	UCHAR actuallen;
	char buffer[255];
} LINE;

/******************************************************************************/

/* Disk-Transfer-Area (siehe Fsetdta, Fgetdta, Fsfirst, Fsnext) */
typedef struct
{
	CHAR		d_reserved[21];
	UCHAR		d_attrib;
	UINT16	d_time;
	UINT16	d_date;
	UINT32	d_length;
	char		d_fname[14];
} DTA;

/******************************************************************************/

/* Die Basepage des Prozesses */
typedef struct baspag
{
	void	*p_lowtpa;          /* Start der TPA              */
	void	*p_hitpa;           /* Ende der TPA               */
	void	*p_tbase;           /* Start des Textsegments     */
	INT32	p_tlen;             /* LÑnge des Textsegments     */
	void	*p_dbase;           /* Start des Datasegments     */
	INT32	p_dlen;             /* LÑnge des Datasegments     */
	void	*p_bbase;           /* Start des BSS              */
	INT32	p_blen;             /* LÑnge des BSS              */
	DTA	*p_dta;             /* Start der DTA              */
	struct baspag *p_parent;    /* Start des aufrufenden Prg. */
	INT32	p_resrvd0;          /* reserviert                 */
	char	*p_env;             /* Start des Environments     */
	char	p_stdfh[6];         /* Standardhandles            */
	char	p_resrvd1;          /* reserviert                 */
	char	p_curdrv;           /* aktuelles Laufwerk         */
	INT32	p_resrvd2[18];      /* reserviert                 */
	char	p_cmdlin[128];      /* Kommandozeile              */
} BASPAG;

/******************************************************************************/

/* Memory Descriptor */
typedef struct __md
{
	struct __md *m_link;
	void        *m_start;
	long        m_length;
	BASPAG      *m_own;
} MD;

/******************************************************************************/

/* Memory Parameter Block */
typedef struct
{
	MD *mp_mfl;
	MD *mp_mal;
	MD *mp_rover;
} MPB;

/******************************************************************************/

/* Struktur fÅr Buffptr (siehe Buffptr) */
typedef struct
{
	void *playptr;
	void *recordptr;
	void *reserved1;
	void *reserved2;
} SBUFPTR;

/******************************************************************************/

/* (siehe Dsp_MultBlocks) */
typedef struct
{
	INT16	blocktype;		/* Typ der Daten im Puffer: */
								/*   0 : LongInt            */
								/*   1 : Integer            */
								/*   2 : Byte               */
	INT32	blocksize;		/* Puffergrîûe              */
	void	*blockaddr;		/* Zeiger auf den Puffer    */
} DSPBLOCK;

/******************************************************************************/

/* Sruktur zur Initialisierung der Maus (siehe Initmouse) */
typedef struct
{
	CHAR topmode;
	CHAR buttons;
	CHAR xparam;
	CHAR yparam;
	INT16 xmax;
	INT16 ymax;
	INT16 xinitial;
	INT16 yinitial;
} InitMousParam;

/******************************************************************************/

/* Struktur fÅr die seriellen Schnittstellen (siehe Iorec) */
typedef struct
{
	void	*ibuf;		/* Zeiger auf den Buffer   */
	INT16	ibufsiz;		/* Grîûe des Buffers       */
	INT16	ibufhd;		/* nÑchste Schreibposition */
	INT16	ibuftl;		/* nÑchste Leseposition    */
	INT16	ibuflow;		/* Marke fÅr Xon           */
	INT16	ibufhi;		/* Marke fÅr Xoff          */
} _IOREC;
#define IOREC _IOREC

/******************************************************************************/

/* Struktur fÅr die seriellen Schnittstellen (siehe BCONMAP, Bconmap) */
typedef struct
{
	INT16 (*Bconstat)(void);
	INT32 (*Bconin)(void);
	INT16 (*Bcostat)(void);
	void  (*Bconout)(void);
	INT32 (*Rsconf)(void);
	IOREC *iorec;
} MAPTAB;

/******************************************************************************/

/* Beschreibung der seriellen SChnittstellen (siehe Bconmap) */
typedef struct
{
	MAPTAB *maptab;
	INT16 mabtabsize;
} BCONMAP;

/******************************************************************************/

/* Funktionstabelle fÅr den Tastaturprozessor (siehe Kbdvbase) */
typedef struct
{
	void (*kb_midivec)( UCHAR data );
	void (*kb_vkbderr)( UCHAR data );
	void (*kb_vmiderr)( UCHAR data );
	void (*kb_statvec)(CHAR *buf);
	void (*kb_mousevec)(CHAR *buf);
	void (*kb_clockvec)(CHAR *buf);
	void (*kb_joyvec)(CHAR *buf);
	void (*kb_midisys)( void );
	void (*kb_ikbdsys)( void );
	CHAR ikbdstate;
} KBDVECS;

/******************************************************************************/

/* Tastatur-Belegung (siehe Keytbl) */
typedef struct
{
	CHAR *unshift;
	CHAR *shift;
	CHAR *capslock;
} KEYTAB;

/******************************************************************************/

typedef struct
{
	UINT32 drivemap;		/* Bitmap of drives (Bit 0 = A, 1 = B, etc... */
	CHAR *version;			/* String containing name and version */
	INT32 reserved[2];	/* Currently unused */
} METAINFO;

/******************************************************************************/

typedef struct
{
	CHAR *mdr_name;
	INT32 reserved[3];
} META_DRVINFO;

/******************************************************************************/

/* Beschreibung des zu druckenden Bildschirmausschnittes (siehe Prtblk) */
typedef struct
{
	void	*pb_scrptr;
	INT16	pb_offset;
	INT16	pb_width;
	INT16	pb_height;
	INT16	pb_left;
	INT16	pb_right;
	INT16	pb_screz;
	INT16	pb_prrez;
	void	*pb_colptr;
	INT16	pb_prtype;
	INT16	pb_prport;
	void	*pb_mask;
} PBDEF;

/******************************************************************************/

/* Info-Struktur Åber Partitionen (siehe Dfree) */
typedef struct
{
	UINT32 b_free;
	UINT32 b_total;
	UINT32 b_secsiz;
	UINT32 b_clsiz;
} DISKINFO;

/******************************************************************************/

/* Informationen Åber Dateien und Verzeichnisse (siehe Fxattr, Dxreaddir) */
typedef struct
{
	UINT16 mode;
	INT32 index;
	UINT16 dev;
	UINT16 reserved1;
	UINT16 nlink;
	UINT16 uid;
	UINT16 gid;
	INT32 size;
	INT32 blksize;
	INT32 nblocks;
	INT16 mtime;
	INT16 mdate;
	INT16 atime;
	INT16 adate;
	INT16 ctime;
	INT16 cdate;
	INT16 attr;
	INT16 reserved2;
	INT32 reserved3;
	INT32 reserved4;
} XATTR;

/******************************************************************************/

#ifndef __PCTOSLIB__
	typedef struct
	{
		UINT16 hour:5;
		UINT16 minute:6;
		UINT16 second:5;
		UINT16 year:7;
		UINT16 month:4;
		UINT16 day:5;
	} DATETIME;
#else
	typedef struct
	{
		UINT16 time;
		UINT16 date;
	} DOSTIME;
#endif

/******************************************************************************/

/* Kommandozeile zum Start von Programmen (siehe Pexec) */
typedef struct
{
	UCHAR length;
	CHAR command[126];
} COMMAND;

/******************************************************************************/

typedef struct
{
	INT32 userlong1;
	INT32 userlong2;
	INT16 pid;
} MSG;

/******************************************************************************/

/* (siehe ) */
typedef struct
{
	INT32 sa_handler;
	INT16 sa_mask;
	INT16 sa_flags;
} SIGACTION;

/******************************************************************************/

struct timezone
{
	INT16 tz_minuteswest;
	INT16 tz_dsttime;
};

/******************************************************************************/

struct timeval
{
	INT32 tv_sec;
	INT32 tv_usec;
};

/******************************************************************************/

/* system variable _sysbase (0x4F2L) points to next structure         */
typedef struct _syshdr
{
	UINT16 os_entry;				/* $00 BRA zum Reset-Handler            */
	UINT16 os_version;			/* $02 TOS-Versionsnummer               */
	void *os_start;				/* $04 -> Reset-Handler                 */
	struct _syshdr *os_base;	/* $08 -> baseof OS                     */
	void *os_memboot;				/* $0C -> Ende des BIOS/GEMDOS/VDI RAM  */
	void *os_rsv1;					/* $10 << unbenutzt, reserviert >>      */
	INT32 *os_magic;				/* $14 -> GEM memoryusage parm. block   */
	INT32 os_gendat;				/* $18 Datum des Systems ($MMDDYYYY)    */
	INT16 os_palmode;				/* $1C OS-Konfiguration-Bits            */
	INT16 os_gendatg;				/* $1e Dateum des Systems (DOS-Format)  */
	
	/* Diese Komponenten sind erst am TOS 1.02 verfÅgbar */
	void *_root;					/* $20 -> base of OS pool               */
	INT32 *kbshift;				/* $24 -> keyboard shift state variable */
	BASPAG **_run;					/* $28 -> GEMDOS PID of current process */
	void *p_rsv2;					/* $2C << unbenutzt, reserviert >>      */
} SYSHDR;

/******************************************************************************/
/*																										*/
/* Globale Variablen																				*/
/*																										*/
/******************************************************************************/

/* Basepage des Programmes */
extern BASPAG *_BasPag;			/* Im Startup-Code definiert */

/* Programmgrîûe (fÅr Ptermres interessant ;-) */
extern long _PgmSize;			/* Im Startup-Code definiert */

/******************************************************************************/
/*																										*/
/* Die BIOS-Funktionen																			*/
/*																										*/
/******************************************************************************/

#ifndef __GNUC__
	#define TOSFKT
	
	/* Achtung: Diese Funktion ist NICHT multithreading-fest! */
	INT32 bios( INT16 fkt_nr, ... );
#else
	#define TOSFKT static
#endif

/******************************************************************************/

TOSFKT INT32 Bconin( const INT16 dev );
TOSFKT void Bconout( const INT16 dev, const INT16 c );
TOSFKT INT16 Bconstat( const INT16 dev );
TOSFKT INT32 Bcostat( const INT16 dev );
TOSFKT INT32 Drvmap( void );
TOSFKT BPB *Getbpb( const INT16 dev );
TOSFKT INT32 Getmpb( const MPB *p_mpb );
TOSFKT INT32 Kbshift( const INT16 mode );
TOSFKT INT32 Mediach( const INT16 dev );
TOSFKT INT32 Rwabs( const INT16 rwflag, const void *buf, const INT16 count,
			const INT16 recno, const INT16 dev, const INT32 lrecno );
TOSFKT void (*Setexc( const INT16 vecnum, const void (*vec)(void) ))(void);
TOSFKT INT32 Tickcal( void );

/******************************************************************************/
/*																										*/
/* Die XBIOS-Funktionen																			*/
/*																										*/
/******************************************************************************/

#ifndef __GNUC__
	/* Achtung: Diese Funktion ist NICHT multithreading-fest! */
	INT32 xbios( INT16 fkt_nr, ... );
#endif

/******************************************************************************/

TOSFKT INT32 Bconmap( const INT16 devno );
TOSFKT INT16 HasBconmap( void );
TOSFKT void Bioskeys( void );
TOSFKT INT16 Blitmode( const INT16 mode );
TOSFKT INT32 Buffoper( const INT16 mode );
TOSFKT INT32 Buffptr( const SBUFPTR *sptr );
TOSFKT INT16 Cursconf( const INT16 function, const INT16 operand );
TOSFKT void Dbmsg( const INT16 rsrvd, const INT16 msg_num, const INT32 msg_arg );
TOSFKT INT32 Devconnect( INT16 source, INT16 dest, INT16 clk, INT16 prescale, INT16 protocol );
TOSFKT INT32 DMAread( const INT32 sector, const INT16 count, void *buffer, const INT16 devno );
TOSFKT INT32 DMAwrite( const INT32 sector, const INT16 count, void *buffer, const INT16 devno );
TOSFKT void Dosound( const char *ptr );
TOSFKT void Dsp_Available( INT32 *xavail, INT32 *yavail );
TOSFKT void Dsp_BlkBytes( UCHAR *data_in, INT32 size_in, UCHAR *data_out, INT32 size_out );
TOSFKT void Dsp_BlkHandShake( UCHAR *data_in, INT32 size_in, UCHAR *data_out, INT32 size_out );
TOSFKT void Dsp_BlkUnpacked( INT32 *data_in, INT32 size_in, INT32 *data_out, INT32 size_out );
TOSFKT void Dsp_BlkWords( INT16 *data_in, INT32 size_in, INT16 *data_out, INT32 size_out );
TOSFKT void Dsp_DoBlock( char *data_in, INT32 size_in, char *data_out, INT32 size_out );
TOSFKT void Dsp_ExecBoot( char *codeptr, INT32 codesize, INT16 ability );
TOSFKT void Dsp_ExecProg( char *codeptr, INT32 codesize, INT16 ability );
TOSFKT void Dsp_FlushSubroutines( void );
TOSFKT INT16 Dsp_GetProgAbility( void );
TOSFKT INT16 Dsp_GetWordSize( void );
TOSFKT INT16 Dsp_Hf0( INT16 flag );
TOSFKT INT16 Dsp_Hf1( INT16 flag );
TOSFKT INT16 Dsp_Hf2( void );
TOSFKT INT16 Dsp_Hf3( void );
TOSFKT CHAR Dsp_HStat( void );
TOSFKT CHAR Dsp_InqSubrAbility( INT16 ability );
TOSFKT void Dsp_InStream( char *data_in, INT32 block_size, INT32 num_blocks, INT32 *blocks_done );
TOSFKT void Dsp_IOStream( char *data_in, char *data_out, INT32 block_insize, INT32 block_outsize,
			INT32 num_blocks, INT32 *blocks_done );
TOSFKT INT16 Dsp_LoadProg( char *file, INT16 ability, char *buf );
TOSFKT INT16 Dsp_LoadSubroutine( char *ptr, INT32 size, INT16 ability );
TOSFKT CHAR Dsp_Lock( void );
TOSFKT INT32 Dsp_LodToBinary( char *file, char *codeptr );
TOSFKT CHAR Dsp_MultBlocks( INT32 numsend, INT32 numreceive, DSPBLOCK *sendblk,
			DSPBLOCK *receiveblock );
TOSFKT void Dsp_OutStream( char *data_out, INT32 block_size, INT32 num_blocks, INT32 *blocks_done );
TOSFKT void Dsp_RemoveInterrupts( INT16 mask );
TOSFKT INT16 Dsp_RequestUniqueAbility( void );
TOSFKT INT16 Dsp_Reserve( INT32 xreserve, INT32 yreserve );
TOSFKT INT16 Dsp_RunSubroutine( INT16 handle );
TOSFKT void Dsp_SetVectors( void (*receiver)(void), INT32 (*transmitter)(void) );
TOSFKT void Dsp_TriggerHC( INT16 vector );
TOSFKT void Dsp_Unlock( void );
TOSFKT INT32 Dsptristate( INT16 dspxmit, INT16 dsprec );
void EgetPalette( INT16 colorNum, INT16 count, INT16 *palettePtr );
INT16 EgetShift( void );
INT16 EsetBank( INT16 bankNum );
INT16 EsetColor( INT16 colorNum, INT16 color );
INT16 EsetGray( INT16 swtch );
void EsetPalette( INT16 colorNum, INT16 count, INT16 *palettePtr );
INT16 EsetShift( INT16 shftMode );
INT16 EsetSmear( INT16 swtch );
INT16 Flopfmt( void *buf, void *sect, INT16 devno, INT16 spt, INT16 trackno, INT16 sideno,
			INT16 interlv, INT32 magic, INT16 virgin );
INT16 Floprate( INT16 drive, INT16 seekrate );
INT16 Floprd( void *buf, INT32 filler, INT16 devno, INT16 sectno, INT16 trackno,
			INT16 sideno, INT16 count );
INT16 Flopver( void *buf, INT32 filler, INT16 devno, INT16 sectno, INT16 trackno,
			INT16 sideno, INT16 count );
INT16 Flopwr( void *buf, INT32 filler, INT16 devno, INT16 sectno, INT16 trackno,
			INT16 sideno, INT16 count );
INT16 Getrez( void );
INT32 Gettime( void );
char Giaccess( INT16 c, INT16 recno );
INT32 Gpio( INT16 mode, INT16 data );
void Ikbdws( INT16 cnt, const char *ptr );
void Initmouse( INT16 type, InitMousParam *param, void *(*vec)(void) );
IOREC *Iorec( INT16 devno );
void Jdisint( INT16 intno );
void Jenabint( INT16 intno );
KBDVECS *Kbdvbase( void );
INT16 Kbrate( INT16 initial, INT16 repeat );

#if !defined(__PCTOSLIB__) && !defined(__CATTOS__)
	KEYTAB *Keytbl( char *unshift, char *shift, char *capslock );
#else
	KEYTAB *Keytbl( void *unshift, void *shift, void *capslock );
#endif

INT32 Locksnd( void );
void *Logbase( void );
INT32 Metaclose( INT16 drive );
INT32 Metadiscinfo( INT16 drive, CD_DISC_INFO *p );
INT32 Metagettoc( INT16 drive, INT16 flag,  CD_TOC_ENTRY *buffer );
void Metainit( METAINFO *buffer );
INT32 Metaioctl( INT16 drive, INT32 magic, INT16 opcode, void *buffer );
INT32 Metaopen ( INT16 drive, META_DRVINFO *buffer );
INT32 Metaread( INT16 drive, void *buffer, INT32 blockno, INT16 count );
INT32 Metasetsongtime( INT16 drive, INT16 repeat, INT32 starttime, INT32 endtime );
INT32 Metastartaudio( INT16 drive, INT16 flag, UCHAR *bytearray );
INT32 Metastopaudio( INT16 drive );
INT32 Metastatus( INT16 drive, void *buffer );
INT32 Metawrite( INT16 drive, void *buffer, INT32 blockno, INT16 count );
void Mfpint( INT16 intno, void (*vector)(void) );
void Midiws( INT16 cnt, const char *buffer );
INT16 NVMaccess( INT16 op, INT16 start, INT16 count, char *buffer );
void Offgibit( INT16 bitno );
void Ongibit( INT16 bitno );
void *Physbase( void );
void Protobt( void *buf, INT32 serialno, INT16 disktype, INT16 execflag );
void Prtblk( PBDEF *defptr );
void Puntaes( void );
INT32 Random( void );
UINT32 Rsconf( INT16 speed, INT16 flowctl, INT16 ucr, INT16 rsr, INT16 tsr, INT16 scr );
void Scrdmp( void );
INT32 Setbuffer( INT16 reg, void *begaddr, void *endaddr );
INT16 Setcolor( INT16 colornum, INT16 color );
INT32 Setinterrupt( INT16 mode, INT16 cause );
INT32 Setmode( INT16 mode );
INT32 Setmontracks( INT16 track );
void Setpalette( INT16 *palettePtr );
void Setscreen( void *logLoc, void *physLoc, INT16 res );
void Settime( INT32 datetime );
INT32 Settracks( INT16 playtrack, INT16 rectrack );
INT32 Sndstatus( INT16 reset );
INT32 Soundcmd( INT16 mode, INT16 data );
INT32 Ssbrk( INT16 amount );
INT32 Supexec( INT32 (*codeptr)(void) );
INT32 Unlocksnd( void );
/* INT32(?) ValidMode( INT16 xyz(?) ); */ /* Noch unklar, was das ist... ;-/ */
INT16 VgetMonitor( void );
void VgetRGB( INT16 index, INT16 count, RGB *rgb );
INT32 VgetSize( INT16 mode );
void VsetMask( INT16 ormask, INT16 andmask, INT16 overlay );
INT16 VsetMode( INT16 mode );
void VsetRGB( INT16 index, INT16 count, RGB *rgb );
void VsetScreen( void *log, void *phys, INT16 mode, INT16 modecode );
void VsetSync( INT16 external );
void Vsync( void );
void Waketime( UINT16 date, UINT16 time );
INT16 WavePlay( INT16 flags, INT32 rate, void *sptr, INT32 slen );
void Xbtimer( INT16 timer, INT16 control, INT16 data, void (*vec)(void) );

/******************************************************************************/
/*																										*/
/* Die GEMDOS-Funktionen																		*/
/*																										*/
/******************************************************************************/

/* Achtung: Diese Funktion ist NICHT multithreading-fest! */
INT32 gemdos( INT16 fkt_nr, ... );

/******************************************************************************/

INT16 Cauxin( void );
INT16 Cauxis( void );
INT16 Cauxos( void );
void Cauxout( INT16 c );
INT32 Cconin( void );
INT16 Cconis( void );
INT16 Cconos( void );
void Cconout( INT16 c );
void Cconrs( LINE *buf );
INT16 Cconws( const char *str );
INT32 Cnecin( void );
INT16 Cprnos( void );
INT16 Cprnout( INT16 c );
INT32 Crawcin( void );
INT32 Crawio( INT16 c );
INT32 Dclosedir( INT32 dirhandle );
INT32 Dcntl( INT16 cmd, char *name, INT32 arg );
INT32 Dcreate( const char *path );
INT32 Ddelete( const char *path );
INT32 Dfree( DISKINFO *buf, INT16 drive );
INT32 Dgetcwd( char *path, INT16 drv, INT16 size );
INT16 Dgetdrv( void );
INT32 Dgetpath( char *buf, INT16 drive );
INT32 Dlock( INT16 mode, INT16 drv );
INT32 Dopendir( const char *name, INT16 flag );
INT32 Dpathconf( char *name, INT16 mode );
INT32 Dreaddir( INT16 len, INT32 dirhandle, char *buf );
INT32 Dreadlabel( const char *path, char *label, INT16 maxlen );
INT32 Dwritelabel( const char *path, char *label );
INT32 Dxreaddir( INT16 buflen, INT32 dir, char *buf, XATTR *xbuf, INT32 *xr );
INT32 Drewinddir( INT32 handle );
INT32 Dsetdrv( INT16 drive );
INT32 Dsetpath( const char *path );
INT32 F_lock( INT16 handle, INT32 count );
INT32 Fattrib( const char *fname, INT16 flag, INT16 attr );
INT32 Fchmod( char *name, INT16 mode );
INT32 Fchown( char *name, INT16 uid, INT16 gid );
INT16 Fclose( INT16 handle );
INT32 Fcntl( INT16 handle, INT32 arg, INT16 cmd );
INT32 Fcreate( const char *fname, INT16 attr );

#ifndef __PCTOSLIB__
	INT32 Fdatime( DATETIME *timeptr, INT16 handle, INT16 flag );
#else
	INT32 Fdatime( DOSTIME *timeptr, INT16 handle, INT16 flag );
#endif

INT32 Fdelete( const char *fname );
INT32 Fdup( INT16 shandle );
INT32 Fflush( INT16 handle );
INT32 Fforce( INT16 shandle, INT16 nhandle );
INT32 Fgetchar( INT16 handle, INT16 mode );
DTA *Fgetdta( void );
INT32 Finstat( INT16 handle );
INT32 Flink( char *oldname, char *newname );
INT32 Flock( INT16 handle, INT16 mode, INT32 start, INT32 length );
INT32 Fmidipipe( INT16 pid, INT16 in, INT16 out );
INT32 Fopen( const char *fname, INT16 mode );
INT32 Foutstat( INT16 handle );
INT32 Fpipe( INT16 fhandle[2] );
INT32 Fputchar( INT16 handle, INT32 lchar, INT16 mode );
INT32 Fread( INT16 handle, INT32 length, void *buf );
INT32 Freadlink( INT16 bufsiz, char *buf, char *name );

#if !defined(__PCTOSLIB__) && !defined(__CATTOS__)
	INT32 Frename( const char *oldname, const char *newname );
#else
	INT32 Frename( const INT16 zero, const char *oldname, const char *newname );
#endif

INT32 Frlock( INT16 handle, INT32 start, INT32 count );
INT32 Frunlock( INT16 handle, INT32 start );
INT32 Fseek( INT32 offset, INT16 handle, INT16 mode );
INT16 Fselect( UINT16 timeout, INT32 *rfds, INT32 *wfds, INT32 *xfds );
void Fsetdta( DTA *ndta );
INT16 Fsfirst( const char *fspec, INT16 attribs );
INT16 Fsnext( void );
INT32 Fsymlink( char *oldname, char *newname );
INT32 Funlock( INT16 handle );
INT32 Fwrite( INT16 handle, INT32 count, void *buf );
INT32 Fxattr( INT16 flag, char *name, XATTR *xattr );
INT32 Lock( const char *path );
INT32 Maddalt( void *start, INT32 size );
void *Malloc( INT32 amount );
INT16 Mfree( void *startadr );
INT32 Mgrow( void *block, INT32 newsize );
INT16 Mshrink( void *startadr, INT32 newsize );
void *Mxalloc( INT32 amount, INT16 mode );
INT16 Nactive( void );
void Ndisable( void );
void Nenable( void );
INT32 Nlock( const char *file );
INT32 Nlocked( void );
INT16 Nlogged( INT16 nn );
INT16 Nmsg( INT16 rw, char *buf, char *id, INT16 node, INT16 leng );
INT16 Nnodeid( void );
INT16 Nrecord( INT16 handle, INT16 mm, INT32 offset, INT32 leng );
INT16 Nremote( INT16 nn );
void Nreset( void );
INT32 Nunlock( const char *file );
INT32 Nversion( void );
void Pause( void );
INT16 Pdomain( INT16 domain );
INT32 Pexec( INT16 mode, const char *fname, const COMMAND *cmdline, const char *envstr );
INT16 Pfork( void );
INT32 Pgetauid( void );
INT16 Pgetegid( void );
INT16 Pgeteuid( void );
INT16 Pgetgid( void );
INT32 Pgetgroups( INT16 gidsetlen, UINT16 gidset[] );
INT16 Pgetpgrp( void );
INT16 Pgetpid( void );
INT16 Pgetppid( void );
INT32 Pgetpriority( INT16 which, INT16 who );
INT16 Pgetuid( void );
INT16 Pkill( INT16 pid, INT16 sig );
INT16 Pmsg( INT16 mode, INT32 mboxid, MSG *msgptr );
INT16 Pnice( INT16 delta );
INT32 Prenice( INT16 pid, INT16 delta );
void Prusage( INT32 *rusg );
INT32 Psemaphore( INT16 mode, INT32 id, INT32 timeout );
INT32 Psetauid( INT16 id );
INT32 Psetegid( INT16 id );
INT32 Pseteuid( INT16 id );
INT16 Psetgid( INT16 gid );
INT32 Psetgroups( INT16 ngroups, UINT16 gidset[] );
void Psetlimit( INT16 limit, INT32 value );
INT32 Psetpgrp( INT16 pid, INT16 newgrp );
INT32 Psetpriority( INT16 which, INT16 who, INT16 pri );
INT32 Psetregid( INT16 rid, INT16 eid );
INT32 Psetreuid( INT16 rid, INT16 eid );
INT16 Psetuid( INT16 uid );

#ifndef __PCTOSLIB__
	INT32 Psigaction( INT16 sig, SIGACTION *act, SIGACTION *oact );
#else
	INT32 Psigaction( INT16 sig, INT32 act, INT32 oact );
#endif

INT32 Psigblock( INT32 mask );
INT32 Psigintr( INT16 vec, INT16 sig );

#if !defined(__PCTOSLIB__) && !defined(__CATTOS__)
	INT32 Psignal( INT16 sig, void CDECL (*handler)(INT32 sig) );
#elif defined(__CATTOS__)
	INT32 Psignal( INT16 sig, long handler );
#else
	INT32 Psignal( INT16 sig, void *handler );
#endif

INT32 Psigpause( INT32 mask );
INT32 Psigpending( void );
void Psigreturn( void );
INT32 Psigsetmask( INT32 mask );
void Pterm( INT16 retcode );
void Pterm0( void );
void Ptermres( INT32 keep, INT16 retcode );
INT16 Pumask( INT16 mode );
INT32 Pusrval( INT32 val );
INT16 Pvfork( void );
INT32 Pwait( void );
INT32 Pwait3( INT16 flag, INT32 *rusage );
INT32 Pwaitpid( INT16 pid, INT16 flag, INT32 *rusage );
void Salert( char *str );
INT32 Sconfig( INT16 mode, INT32 value );
INT32 Scookie( INT16 action, void *yummy );
INT32 Shutdown( INT32 restart );
/*INT32 Slbopen( char *name, char *path, INT32 min_ver, SHARED_LIB *sl, SLB_EXEC *fn );
INT32 Slbclose( SHARED_LIB *sl );*/
INT32 Srealloc( INT32 size );
INT32 Ssystem( INT16 mode, INT32 arg1, INT32 arg2 );

/* Achtung: Diese Funktion ist NICHT multithreading-fest! */
INT32 Super( void *stack );

INT32 Suptime( UINT32 *cur_uptime, UINT32 loadave[3] );
UINT16 Sversion( void );
void Syield( void );
INT32 Sync( void );
INT32 Sysconf( INT16 inq );
INT32 Tadjtime( INT32 adj );
INT32 Talarm( INT32 time );
UINT16 Tgetdate( void );
UINT16 Tgettime( void );
INT32 Tgettimeofday( struct timeval *tv, struct timezone *tz );
UINT32 Tmalarm( UINT32 millisecs );
INT16 Tsetdate( UINT16 date );
INT32 Tsetitimer( INT32 which, INT32 *interval, INT32 *value,
			INT32 *ointeral, INT32 *ovalue );
INT16 Tsettime( UINT16 time );
INT32 Tsettimeofday( struct timeval *tv, struct timezone *tz );
INT32 Unlock( const char *path );
		
/******************************************************************************/

#ifdef __GNUC__
	#include <acstosi.h>
#endif

#ifdef __cplusplus}#endif
#endif
