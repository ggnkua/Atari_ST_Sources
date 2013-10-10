/******************************************************************************/
/*																										*/
/*          Eine handoptimierte Bibliothek fÅr Pure-C und GNU-C               */
/*																										*/
/*          Die BIOS-, XBIOS- & GEMDOS-Funktionen - Headerdatei					*/
/*																										*/
/*	(c) 1999-2003 by Martin ElsÑsser									1 Tab = 3 Spaces	*/
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
#define E_OK		0					/* success, no error							*/

/* BIOS errors */
#define ERROR		-1					/* generic error								*/
#define EDRVNR		-2					/* drive not ready							*/
#define EUNCMD		-3					/* unknown command							*/
#define E_CRC		-4					/* crc error									*/
#define EBADRQ		-5					/* bad request									*/
#define E_SEEK		-6					/* seek error									*/
#define EMEDIA		-7					/* unknown media								*/
#define ESECNF		-8					/* sector not found							*/
#define EPAPER		-9					/* out of paper								*/
#define EWRITF		-10				/* write fault									*/
#define EREADF		-11				/* read fault									*/
#define EGENRL		-12				/* general error								*/
#define EWRPRO		-13				/* device write protected					*/
#define E_CHNG		-14				/* media change detected					*/
#define EUNDEV		-15				/* unknown device								*/
#define EBADSF		-16				/* bad sectors on format					*/
#define EOTHER		-17				/* insert other disk request				*/

/* GEMDOS errors */
#define EINVFN		-32				/* invalid function							*/
#define EFILNF		-33				/* file not found								*/
#define EPTHNF		-34				/* path not found								*/
#define ENHNDL		-35				/* no more handles							*/
#define EACCDN		-36				/* access denied								*/
#define EIHNDL		-37				/* invalid handle								*/
#define ENSMEM		-39				/* insufficient memory						*/
#define EIMBA		-40				/* invalid memory block address			*/
#define EDRIVE		-46				/* invalid drive specification			*/
#define EXDEV		-48				/* cross device rename						*/
#define ENSAME		-48				/* MV between two different drives		*/
#define ENMFIL		-49				/* no more files (from fsnext)			*/
#define ELOCKED	-58				/* record is locked already				*/
#define ENSLOCK	-59				/* invalid lock removal request			*/
#define ERANGE		-64				/* range error									*/
#define EINTRN		-65				/* internal error								*/
#define EPLFMT		-66				/* invalid program load format			*/
#define EGSBF		-67				/* memory block growth failure			*/
#define EBREAK		-68				/* user break (^C)							*/
#define EXCPT		-69				/* 68000- exception ("bombs")				*/
#define EPTHOV		-70				/* path overflow        MAG!X				*/
#define ELOOP		-80				/* too many symbolic links					*/

/* Eigentlich kein Fehler, sondern nur ein Hinweis an den Kernel: */
#define EMOUNT		-200				/* "Mount Point may have been crossed"	*/

#define ENOEXEC		EPLFMT
#define ENAMETOOLONG	ERANGE		/* a filename component is too long */

/******************************************************************************/

/* Mode fÅr Mxalloc */
#define MONLYST				0x00
#define MONLYTT				0x01
#define MEGALST				0x02
#define MEGALTT				0x03
#define MPRIVATE				0x10
#define MGLOBAL				0x20

/******************************************************************************/

/* Konstanten fÅr 'mode' der Struktur XATTR */
#define S_IFMT				0170000       /* mask to select file type */
#define S_IFCHR			0020000       /* BIOS special file        */
#define S_IFDIR			0040000       /* directory file           */
#define S_IFREG			0100000       /* regular file             */
#define S_IFIFO			0120000       /* FIFO                     */
#define S_IMEM 			0140000       /* memory region or process */
#define S_IFLNK			0160000       /* symbolic link            */

/* special bits: setuid, setgid, sticky bit */
#define S_ISUID			04000
#define S_ISGID			02000
#define S_ISVTX			01000

/* file access modes for user, group, and other*/
#define S_IRUSR			0400
#define S_IWUSR			0200
#define S_IXUSR			0100
#define S_IRGRP			0040
#define S_IWGRP			0020
#define S_IXGRP			0010
#define S_IROTH			0004
#define S_IWOTH			0002
#define S_IXOTH			0001
#define DEFAULT_DIRMODE	(0777)
#define DEFAULT_MODE		(0666)

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
#define S_FORCEFASTLOAD	 S_FASTLOAD
#define S_SYNCTIME		 20	/* reserved, use Dcntl */
#define S_BLOCKCACHE		 21
#define S_FLUSHCACHE		 22
#define S_CTRLCACHE		 23
#define S_CLOCKUTC		100
#define S_CLOCKMODE		S_CLOCK_UTC
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

/* Attribute fÅr Fcreate/Fsfirst/Fsnext: */
#define FA_UPDATE       0x00
#define FA_READONLY     0x01
#define FA_HIDDEN       0x02
#define FA_SYSTEM       0x04
#define FA_VOLUME       0x08
#define FA_SUBDIR       0x10
#define FA_ARCHIVE      0x20

/* Bezeichnungen aus dem Profibuch */
#ifndef FA_RDONLY
	#define FA_RDONLY			FA_READONLY
#endif
#ifndef FA_LABEL
	#define FA_LABEL			FA_VOLUME
#endif
#ifndef FA_DIREC
	#define FA_DIREC			FA_SUBDIR
#endif
#ifndef FA_ARCH
	#define FA_ARCH			FA_ARCHIVE
#endif
#define FA_ATTRIB				(FA_SUMDIR|FA_READONLY|FA_HIDDEN|FA_SYSTEM)

/******************************************************************************/

/* Fopen modes */
#define FO_READ         0
#define FO_WRITE        1
#define FO_RW           2

/******************************************************************************/

/* Fcntl Opcodes */
#define   FSTAT          0x4600
#define   FIONREAD       0x4601
#define   FIONWRITE      0x4602
#define   FUTIME         0x4603
#define   FTRUNCATE      0x4604
#define   FIOEXCEPT      0x4605
#define   SHMGETBLK      0x4d00
#define   SHMSETBLK      0x4d01
#define   PBASEADDR      0x5002

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

/* Konstanten fÅr VsetMode */
#define VERTFLAG          0x0100
#define STMODES           0x0080
#define OVERSCAN          0x0040
#define PAL               0x0020
#define VGA_FALCON        0x0010
#define TV                0x0000

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

#define COL80             0x08
#define COL40             0x00

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

#define BPS16             4
#define BPS8              3
#define BPS4              2
#define BPS2              1
#define BPS1              0

/*++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++*/

/* Maske fÅr die Anzahl der Planes */
#define NUMCOLS           7

/******************************************************************************/

/* Konstanten fÅr PAMsNet */
#define NLOCK    1
#define NUNLOCK  0

/* rwabs extended rw-codes */
#define NGETMSG 4                  /* get message                          */
#define NSNDMSG 8                  /* send message                         */          
#define NSNDSCN 5                  /* send screen                          */
#define NGETSCN 9                  /* get screen                           */
#define NRCVSCN 6                  /* ? */
#define NDENIES 7                  /* ? */

/* Nmsg Macros */
#define NMSG_READ     0            /* read message                         */
#define NMSG_WRITE    1            /* send message                         */

/* NET ERROR */
#define NET_ERROR   -36

/******************************************************************************/

/* Codes used with Cursconf() */
#define CURS_HIDE			0
#define CURS_SHOW			1
#define CURS_BLINK		2
#define CURS_NOBLINK		3
#define CURS_SETRATE		4
#define CURS_GETRATE		5

/******************************************************************************/
/*																										*/
/* Die verschiedenen Datenstrukturen														*/
/*																										*/
/******************************************************************************/

/* Der BIOS-Parameterblock eines GerÑtes (siehe Getbpb) */
typedef struct
{
	int16 recsiz;       /* Bytes pro Sektor      */
	int16 clsiz;        /* Sektoren pro Cluster  */
	int16 clsizb;       /* Bytes pro Cluster     */
	int16 rdlen;        /* VerzeichnislÑnge      */
	int16 fsiz;         /* LÑnge der FAT         */
	int16 fatrec;       /* Start der 2. FAT      */
	int16 datrec;       /* 1. freier Sektor      */
	int16 numcl;        /* Gesamtzahl an Cluster */
	int16 bflags;       /* Flags                 */
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
	uint32 reserved[123];
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
	uint16	d_time;
	uint16	d_date;
	uint32	d_length;
	char		d_fname[14];
} DTA;

/******************************************************************************/

/* ProgramHeader, Programmkopf fÅr ausfÅhrbare Dateien */
typedef struct
{
	int16 ph_branch;			/* 0x00: muû 0x601A sein!!               */
	int32 ph_tlen;				/* 0x02: LÑnge  des TEXT - Segments      */
	int32 ph_dlen;				/* 0x06: LÑnge  des DATA - Segments      */
	int32 ph_blen;				/* 0x0A: LÑnge  des BSS  - Segments      */
	int32 ph_slen;				/* 0x0E: LÑnge  der Symboltabelle        */
	int32 ph_res1;				/* 0x12: reserviert, sollte 0 sein       */
	int32 ph_prgflags;		/* 0x16: Programmflags                   */
	int16 ph_absflag;			/* 0x1A: 0 = RelozierungsInfos vorhanden */
} PH;

/******************************************************************************/

/* Die Basepage des Prozesses */
typedef struct baspag
{
	void	*p_lowtpa;          /* Start der TPA              */
	void	*p_hitpa;           /* Ende der TPA               */
	void	*p_tbase;           /* Start des Textsegments     */
	int32	p_tlen;             /* LÑnge des Textsegments     */
	void	*p_dbase;           /* Start des Datasegments     */
	int32	p_dlen;             /* LÑnge des Datasegments     */
	void	*p_bbase;           /* Start des BSS              */
	int32	p_blen;             /* LÑnge des BSS              */
	DTA	*p_dta;             /* Start der DTA              */
	struct baspag *p_parent;    /* Start des aufrufenden Prg. */
	int32	p_resrvd0;          /* reserviert                 */
	char	*p_env;             /* Start des Environments     */
	char	p_stdfh[6];         /* Standardhandles            */
	char	p_resrvd1;          /* reserviert                 */
	char	p_curdrv;           /* aktuelles Laufwerk         */
	int32	p_resrvd2[18];      /* reserviert                 */
	char	p_cmdlin[128];      /* Kommandozeile              */
} BASPAG;

/* Anderer Name der Basepage bei MagiC */
typedef BASPAG PD;

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
	int16	blocktype;		/* Typ der Daten im Puffer: */
								/*   0 : LongInt            */
								/*   1 : Integer            */
								/*   2 : Byte               */
	int32	blocksize;		/* Puffergrîûe              */
	void	*blockaddr;		/* Zeiger auf den Puffer    */
} DSPBLOCK;

/******************************************************************************/

/* Struktur zur Initialisierung der Maus (siehe Initmouse) */
typedef struct
{
	CHAR topmode;
	CHAR buttons;
	CHAR xparam;
	CHAR yparam;
	int16 xmax;
	int16 ymax;
	int16 xinitial;
	int16 yinitial;
} InitMouseParam;

/* AbwÑrtskompatibilitÑt mit PureC */
#define MOUSE InitMouseParam

/******************************************************************************/

/* Struktur fÅr die seriellen Schnittstellen (siehe Iorec) */
typedef struct
{
	void	*ibuf;		/* Zeiger auf den Buffer   */
	int16	ibufsiz;		/* Grîûe des Buffers       */
	int16	ibufhd;		/* nÑchste Schreibposition */
	int16	ibuftl;		/* nÑchste Leseposition    */
	int16	ibuflow;		/* Marke fÅr Xon           */
	int16	ibufhi;		/* Marke fÅr Xoff          */
} _IOREC;
#define IOREC _IOREC

/******************************************************************************/

/* Struktur fÅr die seriellen Schnittstellen (siehe BCONMAP, Bconmap) */
typedef struct
{
	int16 (*Bconstat)(void);
	int32 (*Bconin)(void);
	int16 (*Bcostat)(void);
	void  (*Bconout)(void);
	int32 (*Rsconf)(void);
	IOREC *iorec;
} MAPTAB;

/******************************************************************************/

/* Beschreibung der seriellen SChnittstellen (siehe Bconmap) */
typedef struct
{
	MAPTAB *maptab;
	int16 mabtabsize;
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
	uint32 drivemap;		/* Bitmap of drives (Bit 0 = A, 1 = B, etc... */
	CHAR *version;			/* String containing name and version */
	int32 reserved[2];	/* Currently unused */
} METAINFO;

/******************************************************************************/

typedef struct
{
	CHAR *mdr_name;
	int32 reserved[3];
} META_DRVINFO;

/******************************************************************************/

/* Beschreibung des zu druckenden Bildschirmausschnittes (siehe Prtblk) */
typedef struct
{
	void	*pb_scrptr;
	int16	pb_offset;
	int16	pb_width;
	int16	pb_height;
	int16	pb_left;
	int16	pb_right;
	int16	pb_screz;
	int16	pb_prrez;
	void	*pb_colptr;
	int16	pb_prtype;
	int16	pb_prport;
	void	*pb_mask;
} PBDEF;

/******************************************************************************/

/* Info-Struktur Åber Partitionen (siehe Dfree) */
typedef struct
{
	uint32 b_free;
	uint32 b_total;
	uint32 b_secsiz;
	uint32 b_clsiz;
} DISKINFO;

/******************************************************************************/

/* Informationen Åber Dateien und Verzeichnisse (siehe Fxattr, Dxreaddir) */
typedef struct
{
	uint16 mode;
	int32 index;
	uint16 dev;
	uint16 reserved1;
	uint16 nlink;
	uint16 uid;
	uint16 gid;
	int32 size;
	int32 blksize;
	int32 nblocks;
	int16 mtime;
	int16 mdate;
	int16 atime;
	int16 adate;
	int16 ctime;
	int16 cdate;
	int16 attr;
	int16 reserved2;
	int32 reserved3;
	int32 reserved4;
} XATTR;

/******************************************************************************/

/* Struktur fÅÅr Fdatime gem. PureC und TOS.HYP */
typedef struct
{
	uint16 time;
	uint16 date;
} DOSTIME;

/******************************************************************************/

/* Struktur fÅr Fdatime gem. Kompendium */
typedef struct
{
	uint16 hour:5;
	uint16 minute:6;
	uint16 second:5;
	uint16 year:7;
	uint16 month:4;
	uint16 day:5;
} DATETIME;

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
	int32 userlong1;
	int32 userlong2;
	int16 pid;
} MSG;

/******************************************************************************/

/* (siehe ) */
typedef struct
{
	int32 sa_handler;
	int16 sa_mask;
	int16 sa_flags;
} SIGACTION;

/******************************************************************************/

struct timezone
{
	int16 tz_minuteswest;
	int16 tz_dsttime;
};

/******************************************************************************/

struct timeval
{
	int32 tv_sec;
	int32 tv_usec;
};

/******************************************************************************/

/* system variable _sysbase (0x4F2L) points to next structure         */
typedef struct _syshdr
{
	uint16 os_entry;				/* $00 BRA zum Reset-Handler            */
	uint16 os_version;			/* $02 TOS-Versionsnummer               */
	void *os_start;				/* $04 -> Reset-Handler                 */
	struct _syshdr *os_base;	/* $08 -> baseof OS                     */
	void *os_memboot;				/* $0C -> Ende des BIOS/GEMDOS/VDI RAM  */
	void *os_rsv1;					/* $10 << unbenutzt, reserviert >>      */
	int32 *os_magic;				/* $14 -> GEM memoryusage parm. block   */
	int32 os_gendat;				/* $18 Datum des Systems ($MMDDYYYY)    */
	int16 os_palmode;				/* $1C OS-Konfiguration-Bits            */
	int16 os_gendatg;				/* $1e Dateum des Systems (DOS-Format)  */
	
	/* Diese Komponenten sind erst am TOS 1.02 verfÅgbar */
	void *_root;					/* $20 -> base of OS pool               */
	int32 *kbshift;				/* $24 -> keyboard shift state variable */
	BASPAG **_run;					/* $28 -> GEMDOS PID of current process */
	void *p_rsv2;					/* $2C << unbenutzt, reserviert >>      */
} SYSHDR;

/* Dieser Header ist auch unter dem Namen OSHEADER bekannt */
typedef SYSHDR OSHEADER;

/******************************************************************************/

typedef struct
{
	int16	mwhl_version;
	char*	mwhl_info;
	int16	(*mwhl_wheeled)(int16 Value[16]);
	int16	(*mwhl_service)(int32 Opcode, ...);
	int16	mwhl_wheels;
	int32	mwhl_control;
	int16	mwhl_step[16];
	int16	mwhl_direction;
	int16	mwhl_delay;
} MWHL_Cookie;

/******************************************************************************/

/* FÅr die Shared-Libraries ab MagiC 6 */
typedef void *SHARED_LIB;
typedef LONG cdecl (*SLB_EXEC)( SHARED_LIB *sl, LONG fn, WORD nargs, ... );

/******************************************************************************/

/* Socket -- MiNTNet/MagiCNet only */
#ifndef __SOCKET_H__
	typedef unsigned long socklen_t;
	typedef long ssize_t;
	typedef void *sockaddrPtr;
	typedef void *iovecPtr;
	typedef void *msghdrPtr;
#endif

/******************************************************************************/
/*																										*/
/* Cookie-Strukturen von MagiC																*/
/*																										*/
/******************************************************************************/

typedef struct
{
	char	*in_dos;							/* Adresse der DOS- Semaphore */
	int16	*dos_time;						/* Adresse der DOS- Zeit      */
	int16	*dos_date;						/* Adresse des DOS- Datums    */
	int32	res1;								/*                            */
	int32	res2;								/*                            */
	int32	res3;								/* ist 0L                     */
	void	*act_pd;							/* Laufendes Programm         */
	int32	res4;								/*                            */
	int16	res5;								/*                            */
	void	*res6;							/*                            */
	void	*res7;							/* interne DOS- Speicherliste */
	void	(*resv_intmem)();				/* DOS- Speicher erweitern    */
	int32	(*etv_critic)();				/* etv_critic des GEMDOS      */
	char	*((*err_to_str)(char e));	/* Umrechnung Code->Klartext  */
	int32	res8;								/*                            */
	int32	res9;								/*                            */
	int32	res10;							/*                            */
} DOSVARS;

/******************************************************************************/

typedef struct
{
	int32	magic;									/* muû $87654321 sein              */
	void	*membot;									/* Ende der AES- Variablen         */
	void	*aes_start;								/* Startadresse                    */
	int32	magic2;									/* ist 'MAGX'                      */
	int32	date;										/* Erstelldatum ttmmjjjj           */
	void	(*chgres)(int res, int txt);		/* Auflîsung Ñndern           */
	int32	(**shel_vector)(void);				/* residentes Desktop              */
	char	*aes_bootdrv;							/* von hieraus wurde gebootet      */
	int16	*vdi_device;							/* vom AES benutzter VDI-Treiber   */
	void	*reservd1;
	void	*reservd2;
	void	*reservd3;
	int16	version;									/* z.B. $0201 ist V2.1             */
	int16	release;									/* 0=alpha..3=release              */
} AESVARS;

/******************************************************************************/

/* Cookie-Struktur des Cookies MagX */
typedef struct
{
	int32		config_status;
	DOSVARS	*dosvars;
	AESVARS	*aesvars;
	void		*res1;
	void		*hddrv_functions;
	int32		status_bits;             /* MagiC 3 ab 24.5.95         */
} MAGX_COOKIE;

/******************************************************************************/
/*																										*/
/* Cookie-Strukturen von MagiCMacX															*/
/*																										*/
/******************************************************************************/

/* Ein paar Datentypen fÅr den MagiCMac-Cookie */
typedef char	**Handle;
typedef void	PixMap;
typedef Handle	THPrint;

/******************************************************************************/

typedef struct
{
	int16	vRefNum;
	int32	parID;
	uint8	name[64];	/* pascal string! */
} FSSpec;

/******************************************************************************/

/* Forward-Deklartation der Struktur, */
typedef struct MgMcCookie MgMcCookie;

/******************************************************************************/

/* Die Typen der Funktions-Zeiger */
typedef int32 cdecl (*GenProc)(int16 function, void *data );
typedef boolean cdecl (*PrSetupProc)( char alwaysInteractively);
typedef void cdecl (*VoidProcPtr)( void );
typedef int32 cdecl (*LongProcPtr)( void );
typedef void cdecl (*MacCtProc)( VoidProcPtr ptr);

/******************************************************************************/

typedef struct
{
	THPrint		printHdl;
	PrSetupProc	doPrintSetup;
	VoidProcPtr	saveSetup;
	int32			reserved[7];
} PrintDesc;

/******************************************************************************/

/* status flags (bit numbers) for 'flags1' field */
enum
{
	emul640x400Bit = 0,			/* 640*400 monochrome screen simulation */
	distinctShiftKeysBit,		/* right & left shift keys give diff. scan codes */
	realTwoButtonMouseBit,		/* 2-button mouse is connected */
	runningOn68KEmulatorBit,	/* running on PowerPC with emulation */
	noLowerIOSegmentAvailable, /* lower IO-Segment ($00FF8000-$00FFFFFF) not available */
	noHigherIOSegmentAvailable /* higher IO-Segment ($FFFF8000-$FFFFFFFF) not available */
};

/******************************************************************************/

typedef struct		/* 'vers' resource definition, see Inside Mac docs */
{
	uint8	vm;		/* first part of version number in BCD */
	uint8	vn;		/* second and third part of version number in BCD */
	uint8	vt;		/* development: 0x20, alpha: 0x40, beta: 0x60, release: 0x80 */
	uint8	vd;		/* stage of prerelease version in BCD */
	int16	region;	/* region code */
	char	str[];	/* version strings */
} MacVersion;

/******************************************************************************/

typedef struct
{
	uint8		inserted;		/* true: disk is inserted and available to GEMDOS/BIOS functions */
	uint8		highDensity;	/* true: HD disk inserted, false: none or DD disk inserted */
	int16		res1;				/* reserved */
	int32		res2;				/* reserved */
} FlpDrvInfo;

/******************************************************************************/

typedef struct
{
	char		*start;
	int32		length;
} MemArea;

/******************************************************************************/

/* Das XCMD-Interface */

enum
{
	XCMDMajorVersion	= 1,	/* BCD format */
	XCMDRevision		= 0x01	/* BCD format */
};

/******************************************************************************/

/* some XCMD specific error codes */
enum
{
	unknownFunctionXErr	= -65539L,	/* on callXCMD: unknown function code */
	notInstalledXErr	= -65540L,	/* on openXCMD: no XCMD with this name found */
	notOpenedXErr		= -65541L,	/* on openXCMD: XCMD refused to open */
	alreadyClosedXErr	= -65542L,	/* on closeXCMD: calls to close > calls to open */
	generalXErr			= -1,
	noXErr				= 0
};

/******************************************************************************/

/* predefined XCMD function codes */
/* negative cmds are functions called by MagiCMac in Mac environment */
enum
{
	xcmdOpen	= -2,	/* called each time some MagiC program opens this XCMD */
	xcmdClose	= -1	/* called each time some MagiC program closes this XCMD */
};

/******************************************************************************/

/* function codes for cookie functions 'ext' and 'extMac' */
enum
{
	extMax = 0,
	extAlert,
	extAUXOpenErr,
	extFSSpecToPath,
	extDoMacTasks,
	extMgMcACCMsg,	/* internal use */
	extIntrInfo		/* internal use */
};

/******************************************************************************/

/* to be used with extFSSpecToPath function as parameter */
typedef struct
{
	FSSpec	specIn;
	char		pathOut[256];	/* 0-terminated string */
} FSSpecToPathRec;

typedef long XCMDHdl;

typedef XCMDHdl cdecl (*XCMDOpenProc)(char *xcmdName);			/* returns handle or error code */
typedef long cdecl (*XCMDCloseProc)(XCMDHdl xcmdHdl);				/* returns error code or 0 if no error */
typedef long cdecl (*XCMDGenProc)(XCMDHdl xcmdHdl, short function, void *data);
typedef GenProc cdecl (*XCMDGetAdrProc)(XCMDHdl xcmdHdl);		/* returns zero, if not valid */

/******************************************************************************/

/* the information in this record is static and the record does not move */
typedef struct
{
	int16			recSize;			/* size of this whole structure */
	uint8			majorVers;		/* major version of the XCMD Mgr (== XCMDMajorVersion) */
	uint8			revision;		/* revision version of the XCMD Mgr (== XCMDRevision) */
	
	/* The following routines may be called from Atari User mode or Atari Supervisor mode, */
	/* but not from Interrupts!                                                            */
	XCMDOpenProc	open;			/* negative values mean errors, all positive are valid handles */
	XCMDCloseProc	close;		/* negative values mean errors, zero means OK */
	XCMDGenProc		call;			/* call a user function */
	XCMDGetAdrProc	getAdr;		/* returns the address of the XCMD function dispatcher */
	MgMcCookie		*cookie;		/* back-link to cookie. Is not yet initialized on init! */
	int32				res[15];		/* reserved, zero */
}
XCMDMgrRec;

/******************************************************************************/

/* Die Cookie-Struktur des Cookies 'MgMc'*/
struct MgMcCookie
{
	int16				vers;					/* Versionskennung im BCD-Format       */
	int16				size;					/* Grîûe der Struktur in Bytes         */
	int32				flags1;				/* verschiedene Flags:                 */
												/*                                     */
												/* Bit-0: 640*400-Emulation aktiv      */
												/* Bit-1: Rechts-Shift mîglich         */
												/* Bit-2: 2-Tasten-Maus                */
												/* Bit-3: 68K-Emulation auf Power-PC   */
												/* Bit-4: u. I/O-Bereich nicht vorh.   */
												/* Bit-5: o. I/O-Bereich nicht vorh.   */
												/*                                     */
												/* Hinweis: Bit-2 steht erst ab        */
												/* der Version 1.01, Bit-3 ab Version  */
												/* 1.05 und die folgenden erst ab Ver- */
												/* sion 1.10 zur VerfÅgung.            */
	
	PixMap			*scrnPMPtr;			/* Zeiger auf Screen-Beschreibung      */
	uint8				*updatePalette;	/* Ist zu setzen, um Farbtabellen      */
												/* zu restaurieren                     */
	
	VoidProcPtr		modeMac;				/* MMU-Umschaltung auf Mac-Modus       */
	VoidProcPtr		modeAtari;			/* MMU-Umschaltung auf Atari-Modus     */
	VoidProcPtr		getBaseMode;		/* Liefert in D0.W den MMU-Modus.      */
												/* Es gilt:                            */
												/*                                     */
												/*    0 = Macintosh                    */
												/* <> 0 = Atari                        */
 
	VoidProcPtr		getIntrCount;		/* Liefert in D0.L Intr-Semaphore-     */
												/* ZÑhler (0 = frei)                   */
	
	VoidProcPtr		intrLock;			/* Erhîht Interrupt-Semaphore-ZÑhler   */
	VoidProcPtr		intrUnlock;			/* Erniedrigt Inter.-Semaphore-ZÑhler  */
	VoidProcPtr		callMacContext;	/* FÅhrt Routine im Mac-Kontext aus;   */
												/* Proc-Adr auf Stack.                 */
												/*                                     */
												/* Achtung: Die RegisterD0-D2/A0/A1    */
												/* A5 und A7 werden zerstîrt.          */
	
	char				*atariZeroPage;	/* Zeiger auf Atari-Speicherbereich    */
												/* $0-$800 im Macintosh-Adreûraum      */
	
	char				*macA5;				/* Wert des A5-Regist. im Mac-Kontext  */
	VoidProcPtr		macAppSwitch;		/* Aufruf durch MagiC-Kernel (D0/4(A7).*/
												/* Es gilt:                            */
												/*                                     */ 
												/*   0 = Suspend                       */
												/*   1 = Resume                        */
												/*   2 = Quit                          */
												/* 3/4 = atariModePossbile wechselt    */
	
	VoidProcPtr		controlSwitch;		/* Aufruf durch MagiC-Kernel (D0/4(A7) */
												/* Es gilt:                            */
												/*                                     */ 
												/* 0 = Atari-Screen verstecken         */
												/* 1 = Atari-Screen zeigen             */
	
	int32				hardwareAttr1;		/* z.Zt. undefiniert.                  */
	int32				hardwareAttr2;		/* z.Zt. undefiniert.                  */
	char				*magiC_BP;			/* BASEPAGE des MagiC OS.              */
	char				*auxOutName;			/* Pascal-String fÅr AUX-Ausg.-Device  */
	char				*auxInName;			/* Pascal-String fÅr AUX-Eing.-Device  */
	VoidProcPtr		auxControl;			/* Aufruf durch MagiC-Kernel (D0/4(A7) */
												/* Es gilt:                            */
												/*                                     */ 
												/* 0 = Suspend                         */
												/* 1 = Resume                          */
												/* 2 = Quit                            */
	
	PrintDesc		*printDescPtr;
	GenProc			configKernel;			/* Aufruf (C-Konvention) Atari-Modus   */
	uint8				*atariModePossible;	/* Zeiger auf ein Flag das anzeigt, ob */
													/* der Aufruf von modeAtari z.Zt. er-  */
													/* laubt ist.                          */
	
	MacVersion		*versionOfMacAppl;	/* Version der MagiCMac-Applikation    */
													/* (ab Version 1.06)                   */ 
	
	void				*hwEmulSupport;		/* interner Gebrauch (ab Version 1.07) */
	FlpDrvInfo		*floppyDrvInfoPtr;	/* zeigt auf Infos fÅr Laufwerke A und */
													/* B (ab Version 1.07)                 */
	
	XCMDMgrRec		*xcmdMgrPtr;			/* XCMD-Interface (ab Version 1.08)    */
	VoidProcPtr		giveTimeToMac;			/* Aufrufen im Mac-Kontext falls idle  */
	int32				minStackSize;			/* Mindest-Supervisor-Stackgrîûe       */
	GenProc			ext;						/* Hilfsroutinen, Aufr. aus Atari-Mode */
	GenProc			extMac;					/* analog 'ext'; Aufruf aus Mac-Modus  */
	VoidProcPtr		stackLoad;				/* (ab Version 1.11)                   */
	VoidProcPtr		stackUnload;			/* (ab Version 1.11)                   */
	int32				reserved[3];
};

/******************************************************************************/
/*																										*/
/* Cookie-Strukturen von MagiCMacX															*/
/*																										*/
/******************************************************************************/

typedef INT32(XCMD_CMD)(struct strXCMD *pCmd);
typedef INT32(XCMD_EXEC)(UINT32 SymPtr, void *pParams);

/******************************************************************************/

struct MgMxCookieData
{
	uint32		mgmx_magic;			/* ist "MgMx" */
	uint32		mgmx_version;		/* Versionsnummer */
	uint32		mgmx_len;			/* StrukturlÑnge */
	XCMD_CMD		*mgmx_xcmd;			/* PPC-Bibliotheken laden und verwalten */
	XCMD_EXEC	*mgmx_xcmd_exec;	/* PPC-Aufruf aus PPC-Bibliothek */
};

/******************************************************************************/

/* Befehlsformat fÅr XCmd-Kommandos: */
struct strXCMD
{
	uint32	m_cmd;						/* -> Kommando */
	uint32	m_LibHandle;				/* <->   Connection-ID (je nach Kommando IN oder OUT) */
	uint32	m_MacError;					/* -> Mac-Fehlercode */
	union
	{
		struct
		{
			char	m_PathOrName[256];	/* -> Pfad (Kommando 10) oder Name */
			int32	m_nSymbols;				/* <- Anzahl Symbole beim ôffnen */
		} m_10_11;
		struct
		{
			uint32 m_Index;				/* -> Index (Kommando 13) */
			char m_Name[256];				/* -> Symbolname (Kommando 12) */
												/* <- Symbolname (Kommando 13) */
			int32 m_SymPtr;				/* <- Zeiger auf Symbol */
			uint8 m_SymClass;				/* <- Symboltyp */
      } m_12_13;
   } u;
};

/******************************************************************************/
/*																										*/
/* Cookie-Strukturen von N.AES																*/
/*																										*/
/******************************************************************************/

/* Konstanten fÅr typ in CNF_VAR */
#define CNF_TEND  0   /* Kennzeichnet das Ende der Liste */
#define CNF_TBOOL 1   /* true/false                      */
#define CNF_TWORD 2   /* 16-Bit signed Wert              */
#define CNF_TLONG 3   /* 32-Bit signed Wert              */

/******************************************************************************/

/* Struktur fÅr eine Variable */
typedef struct
{
	union cnf_typ
	{
		int16 w;
		int32 l;
	} val;						/* Der Inhalt             */
	int16	typ;					/* Typ, CNF_T...          */
	char	text[22];			/* Name, wie in N_AES.CNF */
} CNF_INF;

/******************************************************************************/

/* Struktur fÅr Variablen-Gruppen */
typedef struct
{
	char	typ[16];			/* Kategorie, Text aus den Strings des Dialog-Baums CNF_TREE der */
								/* N_AESSYS.RSC, z.B. "Fenster" oder "System".                   */
	CNF_INF *cnf_inf;		/* Die Variablen eben                                            */
} CNF_VAR;

/******************************************************************************/

/* Die Cookie-Struktur des N.AES-Cookies */
typedef struct
{
	uint16	version;
	uint16	date;
	uint16	time;
	uint16	flags;
	CNF_VAR	**config;
	uint32	unused_2;
} N_AESINFO;

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
	int32 cdecl bios( int16 fkt_nr, ... );
#else
	#define TOSFKT static
#endif

/******************************************************************************/

TOSFKT int32 Bconin( const int16 dev );
TOSFKT void Bconout( const int16 dev, const int16 c );
TOSFKT int16 Bconstat( const int16 dev );
TOSFKT int32 Bcostat( const int16 dev );
TOSFKT int32 Drvmap( void );
TOSFKT BPB *Getbpb( const int16 dev );
TOSFKT int32 Getmpb( const MPB *p_mpb );
TOSFKT int32 Kbshift( const int16 mode );
TOSFKT int32 Mediach( const int16 dev );
TOSFKT int32 Rwabs( const int16 rwflag, const void *buf, const int16 count,
			const int16 recno, const int16 dev, const int32 lrecno );
TOSFKT void (*Setexc( const int16 vecnum, const void (*vec)(void) ))(void);
TOSFKT int32 Tickcal( void );

/******************************************************************************/
/*																										*/
/* Die XBIOS-Funktionen																			*/
/*																										*/
/******************************************************************************/

#ifndef __GNUC__
	/* Achtung: Diese Funktion ist NICHT multithreading-fest! */
	int32 cdecl xbios( int16 fkt_nr, ... );
#endif

/******************************************************************************/

TOSFKT int32 Bconmap( const int16 devno );
TOSFKT int16 HasBconmap( void );
TOSFKT void Bioskeys( void );
TOSFKT int16 Blitmode( const int16 mode );
TOSFKT int32 Buffoper( const int16 mode );
TOSFKT int32 Buffptr( const SBUFPTR *sptr );
TOSFKT int16 Cursconf( const int16 function, const int16 operand );
TOSFKT void Dbmsg( const int16 rsrvd, const int16 msg_num, const int32 msg_arg );
TOSFKT int32 Devconnect( int16 source, int16 dest, int16 clk, int16 prescale, int16 protocol );
TOSFKT int32 DMAread( const int32 sector, const int16 count, void *buffer, const int16 devno );
TOSFKT int32 DMAwrite( const int32 sector, const int16 count, void *buffer, const int16 devno );
TOSFKT void Dosound( const char *ptr );
TOSFKT void Dsp_Available( int32 *xavail, int32 *yavail );
TOSFKT void Dsp_BlkBytes( UCHAR *data_in, int32 size_in, UCHAR *data_out, int32 size_out );
TOSFKT void Dsp_BlkHandShake( UCHAR *data_in, int32 size_in, UCHAR *data_out, int32 size_out );
TOSFKT void Dsp_BlkUnpacked( int32 *data_in, int32 size_in, int32 *data_out, int32 size_out );
TOSFKT void Dsp_BlkWords( int16 *data_in, int32 size_in, int16 *data_out, int32 size_out );
TOSFKT void Dsp_DoBlock( char *data_in, int32 size_in, char *data_out, int32 size_out );
TOSFKT void Dsp_ExecBoot( char *codeptr, int32 codesize, int16 ability );
TOSFKT void Dsp_ExecProg( char *codeptr, int32 codesize, int16 ability );
TOSFKT void Dsp_FlushSubroutines( void );
TOSFKT int16 Dsp_GetProgAbility( void );
TOSFKT int16 Dsp_GetWordSize( void );
TOSFKT int16 Dsp_Hf0( int16 flag );
TOSFKT int16 Dsp_Hf1( int16 flag );
TOSFKT int16 Dsp_Hf2( void );
TOSFKT int16 Dsp_Hf3( void );
TOSFKT CHAR Dsp_HStat( void );
TOSFKT CHAR Dsp_InqSubrAbility( int16 ability );
TOSFKT void Dsp_InStream( char *data_in, int32 block_size, int32 num_blocks, int32 *blocks_done );
TOSFKT void Dsp_IOStream( char *data_in, char *data_out, int32 block_insize, int32 block_outsize,
			int32 num_blocks, int32 *blocks_done );
TOSFKT int16 Dsp_LoadProg( char *file, int16 ability, char *buf );
TOSFKT int16 Dsp_LoadSubroutine( char *ptr, int32 size, int16 ability );
TOSFKT CHAR Dsp_Lock( void );
TOSFKT int32 Dsp_LodToBinary( char *file, char *codeptr );
TOSFKT CHAR Dsp_MultBlocks( int32 numsend, int32 numreceive, DSPBLOCK *sendblk,
			DSPBLOCK *receiveblock );
TOSFKT void Dsp_OutStream( char *data_out, int32 block_size, int32 num_blocks, int32 *blocks_done );
TOSFKT void Dsp_RemoveInterrupts( int16 mask );
TOSFKT int16 Dsp_RequestUniqueAbility( void );
TOSFKT int16 Dsp_Reserve( int32 xreserve, int32 yreserve );
TOSFKT int16 Dsp_RunSubroutine( int16 handle );
TOSFKT void Dsp_SetVectors( void (*receiver)(void), int32 (*transmitter)(void) );
TOSFKT void Dsp_TriggerHC( int16 vector );
TOSFKT void Dsp_Unlock( void );
TOSFKT int32 Dsptristate( int16 dspxmit, int16 dsprec );
void EgetPalette( int16 colorNum, int16 count, int16 *palettePtr );
int16 EgetShift( void );
int16 EsetBank( int16 bankNum );
int16 EsetColor( int16 colorNum, int16 color );
int16 EsetGray( int16 swtch );
void EsetPalette( int16 colorNum, int16 count, int16 *palettePtr );
int16 EsetShift( int16 shftMode );
int16 EsetSmear( int16 swtch );
int16 Flopfmt( void *buf, void *sect, int16 devno, int16 spt, int16 trackno, int16 sideno,
			int16 interlv, int32 magic, int16 virgin );
int16 Floprate( int16 drive, int16 seekrate );
int16 Floprd( void *buf, int32 filler, int16 devno, int16 sectno, int16 trackno,
			int16 sideno, int16 count );
int16 Flopver( void *buf, int32 filler, int16 devno, int16 sectno, int16 trackno,
			int16 sideno, int16 count );
int16 Flopwr( void *buf, int32 filler, int16 devno, int16 sectno, int16 trackno,
			int16 sideno, int16 count );
int16 Getrez( void );
int32 Gettime( void );
char Giaccess( int16 c, int16 recno );
int32 Gpio( int16 mode, int16 data );
void Ikbdws( int16 cnt, const char *ptr );
void Initmouse( int16 type, InitMouseParam *param, void *(*vec)(void) );
IOREC *Iorec( int16 devno );
void Jdisint( int16 intno );
void Jenabint( int16 intno );
KBDVECS *Kbdvbase( void );
int16 Kbrate( int16 initial, int16 repeat );
KEYTAB *Keytbl( void *unshift, void *shift, void *capslock );
int32 Locksnd( void );
void *Logbase( void );
int32 Metaclose( int16 drive );
int32 Metadiscinfo( int16 drive, CD_DISC_INFO *p );
int32 Metagettoc( int16 drive, int16 flag,  CD_TOC_ENTRY *buffer );
void Metainit( METAINFO *buffer );
int32 Metaioctl( int16 drive, int32 magic, int16 opcode, void *buffer );
int32 Metaopen ( int16 drive, META_DRVINFO *buffer );
int32 Metaread( int16 drive, void *buffer, int32 blockno, int16 count );
int32 Metasetsongtime( int16 drive, int16 repeat, int32 starttime, int32 endtime );
int32 Metastartaudio( int16 drive, int16 flag, UCHAR *bytearray );
int32 Metastopaudio( int16 drive );
int32 Metastatus( int16 drive, void *buffer );
int32 Metawrite( int16 drive, void *buffer, int32 blockno, int16 count );
void Mfpint( int16 intno, void (*vector)(void) );
void Midiws( int16 cnt, const char *buffer );
int16 NVMaccess( int16 op, int16 start, int16 count, char *buffer );
void Offgibit( int16 bitno );
void Ongibit( int16 bitno );
void *Physbase( void );
void Protobt( void *buf, int32 serialno, int16 disktype, int16 execflag );
void Prtblk( PBDEF *defptr );
void Puntaes( void );
int32 Random( void );
uint32 Rsconf( int16 speed, int16 flowctl, int16 ucr, int16 rsr, int16 tsr, int16 scr );
void Scrdmp( void );
int32 Setbuffer( int16 reg, void *begaddr, void *endaddr );
int16 Setcolor( int16 colornum, int16 color );
int32 Setinterrupt( int16 mode, int16 cause );
int32 Setmode( int16 mode );
int32 Setmontracks( int16 track );
void Setpalette( int16 *palettePtr );
void Setscreen( void *logLoc, void *physLoc, int16 res );
void Settime( int32 datetime );
int32 Settracks( int16 playtrack, int16 rectrack );
int32 Sndstatus( int16 reset );
int32 Soundcmd( int16 mode, int16 data );
int32 Ssbrk( int16 amount );
int32 Supexec( int32 (*codeptr)(void) );
int32 Unlocksnd( void );
/* int32(?) ValidMode( int16 xyz(?) ); */ /* Noch unklar, was das ist... ;-/ */
int16 VgetMonitor( void );
void VgetRGB( int16 index, int16 count, RGB1000 *rgb );
int32 VgetSize( int16 mode );
void VsetMask( int16 ormask, int16 andmask, int16 overlay );
int16 VsetMode( int16 mode );
void VsetRGB( int16 index, int16 count, RGB1000 *rgb );
void VsetScreen( void *log, void *phys, int16 mode, int16 modecode );
void VsetSync( int16 external );
void Vsync( void );
void Waketime( uint16 date, uint16 time );
int16 WavePlay( int16 flags, int32 rate, void *sptr, int32 slen );
void Xbtimer( int16 timer, int16 control, int16 data, void (*vec)(void) );
void CacheCtrl( int16 opcode, int16 param );
void WdgCtrl( int16 opcode );
void ExtRsConf( int16 command, int16 dev, int32 param );

/******************************************************************************/
/*																										*/
/* Die GEMDOS-Funktionen																		*/
/*																										*/
/******************************************************************************/

/* Achtung: Diese Funktion ist NICHT multithreading-fest! */
int32 cdecl gemdos( int16 fkt_nr, ... );

/******************************************************************************/

int16 Cauxin( void );
int16 Cauxis( void );
int16 Cauxos( void );
void Cauxout( int16 c );
int32 Cconin( void );
int16 Cconis( void );
int16 Cconos( void );
void Cconout( int16 c );
void Cconrs( LINE *buf );
int16 Cconws( const char *str );
int32 Cnecin( void );
int16 Cprnos( void );
int16 Cprnout( int16 c );
int32 Crawcin( void );
int32 Crawio( int16 c );
int32 Dclosedir( int32 dirhandle );
int32 Dcntl( int16 cmd, char *name, int32 arg );
int32 Dcreate( const char *path );
int32 Ddelete( const char *path );
int32 Dfree( DISKINFO *buf, int16 drive );
int32 Dgetcwd( char *path, int16 drv, int16 size );
int16 Dgetdrv( void );
int32 Dgetpath( char *buf, int16 drive );
int32 Dlock( int16 mode, int16 drv );
int32 Dopendir( const char *name, int16 flag );
int32 Dpathconf( char *name, int16 mode );
int32 Dreaddir( int16 len, int32 dirhandle, char *buf );
int32 Dreadlabel( const char *path, char *label, int16 maxlen );
int32 Dsetkey( int32 hidev, int32 lowdev, char *key, int16 cipher);
int32 Dxreaddir( int16 buflen, int32 dir, char *buf, XATTR *xbuf, int32 *xr );
int32 Drewinddir( int32 handle );
int32 Dsetdrv( int16 drive );
int32 Dsetpath( const char *path );
int32 F_lock( int16 handle, int32 count );
int32 Fattrib( const char *fname, int16 flag, int16 attr );
int32 Fchmod( char *name, int16 mode );
int32 Fchown( char *name, int16 uid, int16 gid );
int16 Fclose( int16 handle );
int32 Fcntl( int16 handle, int32 arg, int16 cmd );
int32 Fcreate( const char *fname, int16 attr );
int32 Fdatime( DOSTIME *timeptr, int16 handle, int16 flag );
int32 Fdelete( const char *fname );
int32 Fdup( int16 shandle );
int32 Fflush( int16 handle );
int32 Fforce( int16 shandle, int16 nhandle );
int32 Fgetchar( int16 handle, int16 mode );
DTA *Fgetdta( void );
int32 Finstat( int16 handle );
int32 Flink( char *oldname, char *newname );
int32 Flock( int16 handle, int16 mode, int32 start, int32 length );
int32 Fmidipipe( int16 pid, int16 in, int16 out );
int32 Fopen( const char *fname, int16 mode );
int32 Foutstat( int16 handle );
int32 Fpipe( int16 fhandle[2] );
int32 Fputchar( int16 handle, int32 lchar, int16 mode );
int32 Fread( int16 handle, int32 length, void *buf );
int32 Freadlink( int16 bufsiz, char *buf, char *name );
int32 Frename( const int16 zero, const char *oldname, const char *newname );
int32 Frlock( int16 handle, int32 start, int32 count );
int32 Frunlock( int16 handle, int32 start );
int32 Fseek( int32 offset, int16 handle, int16 mode );
int16 Fselect( uint16 timeout, int32 *rfds, int32 *wfds, int32 *xfds );
void Fsetdta( DTA *ndta );
int16 Fsfirst( const char *fspec, int16 attribs );
int16 Fsnext( void );
int32 Fsymlink( char *oldname, char *newname );
int32 Funlock( int16 handle );
int32 Fwrite( int16 handle, int32 count, void *buf );
int32 Fxattr( int16 flag, char *name, XATTR *xattr );
int32 Lock( const char *path );
int32 Maddalt( void *start, int32 size );
void *Malloc( int32 amount );
int16 Mfree( void *startadr );
int32 Mgrow( void *block, int32 newsize );
int16 Mshrink( int16 zero, void *startadr, int32 newsize );
void *Mxalloc( int32 amount, int16 mode );
void Pause( void );
int16 Pdomain( int16 domain );
int32 Pexec( int16 mode, const char *fname, const COMMAND *cmdline, const char *envstr );
int16 Pfork( void );
int32 Pgetauid( void );
int16 Pgetegid( void );
int16 Pgeteuid( void );
int16 Pgetgid( void );
int32 Pgetgroups( int16 gidsetlen, uint16 gidset[] );
int16 Pgetpgrp( void );
int16 Pgetpid( void );
int16 Pgetppid( void );
int32 Pgetpriority( int16 which, int16 who );
int16 Pgetuid( void );
int16 Pkill( int16 pid, int16 sig );
int16 Pmsg( int16 mode, int32 mboxid, MSG *msgptr );
int16 Pnice( int16 delta );
int32 Prenice( int16 pid, int16 delta );
void Prusage( int32 *rusg );
int32 Psemaphore( int16 mode, int32 id, int32 timeout );
int32 Psetauid( int16 id );
int32 Psetegid( int16 id );
int32 Pseteuid( int16 id );
int16 Psetgid( int16 gid );
int32 Psetgroups( int16 ngroups, uint16 gidset[] );
void Psetlimit( int16 limit, int32 value );
int32 Psetpgrp( int16 pid, int16 newgrp );
int32 Psetpriority( int16 which, int16 who, int16 pri );
int32 Psetregid( int16 rid, int16 eid );
int32 Psetreuid( int16 rid, int16 eid );
int16 Psetuid( int16 uid );
int32 Psigaction( int16 sig, int32 act, int32 oact );
int32 Psigblock( int32 mask );
int32 Psigintr( int16 vec, int16 sig );
int32 Psignal( int16 sig, void *handler );
int32 Psigpause( int32 mask );
int32 Psigpending( void );
void Psigreturn( void );
int32 Psigsetmask( int32 mask );
void Pterm( int16 retcode );
void Pterm0( void );
void Ptermres( int32 keep, int16 retcode );
int16 Pumask( int16 mode );
int32 Pusrval( int32 val );
int16 Pvfork( void );
int32 Pwait( void );
int32 Pwait3( int16 flag, int32 *rusage );
int32 Pwaitpid( int16 pid, int16 flag, int32 *rusage );
void Salert( char *str );
int32 Sconfig( int16 mode, int32 value );
int32 Scookie( int16 action, void *yummy );
int32 Shutdown( int32 restart );
int32 Slbopen( char *name, char *path, int32 min_ver, SHARED_LIB *sl, SLB_EXEC *fn );
int32 Slbclose( SHARED_LIB *sl );
int32 Srealloc( int32 size );
int32 Ssystem( int16 mode, int32 arg1, int32 arg2 );

/* Achtung: Diese Funktion ist NICHT multithreading-fest! */
int32 Super( void *stack );

int32 Suptime( uint32 *cur_uptime, uint32 loadave[3] );
uint16 Sversion( void );
void Syield( void );
int32 Sync( void );
int32 Sysconf( int16 inq );
int32 Tadjtime( int32 delta, int32 olddelta );
int32 Talarm( int32 time );
uint16 Tgetdate( void );
uint16 Tgettime( void );
int32 Tgettimeofday( struct timeval *tv, struct timezone *tz );
uint32 Tmalarm( uint32 millisecs );
int16 Tsetdate( uint16 date );
int32 Tsetitimer( int16 which, int32 *interval, int32 *value,
			int32 *ointeral, int32 *ovalue );
int16 Tsettime( uint16 time );
int32 Tsettimeofday( struct timeval *tv, struct timezone *tz );
int32 Unlock( const char *path );

/******************************************************************************/
/*																										*/
/* Utility-Funktionen																			*/
/*																										*/
/******************************************************************************/

/* Liefert Maske fÅr Mxalloc() - siehe Maus.Computer.Atari.Programmieren */
int16 Mxmask( void );

/* Die Struktur SYSHDR - auch OSHEADER genannt - aus _sysbase ermitteln */
SYSHDR *Ash_getOSHeader( void );

/* Den Cookie suchen und den Wert in 'value' schreiben */
/* liefert TRUE bei gefundenem Cookie                  */
int16 Ash_getcookie( int32 cookie, void *value );

/* Den MagiC-Cookie 'MagX' auslesen und liefern */
MAGX_COOKIE *Ash_getMagiC( void );

/* Den N.AES-Cookie 'MagX' auslesen und liefern */
N_AESINFO *Ash_getNAES( void );

/* Die MagiC-Versionsnummer ermitteln:                   */
/*    -1: kein Magic vorhanden                           */
/*    -2: MagiC installiert aber MagiC-AES z.Z. inaktiv, */
/*        d.h. MagiC wird nur als schnelles Dateisystem  */
/*        benutzt - z.B. innerhalb des Auto-Ordners      */
/*    >0: MagiC vorhanden und MagiC-AES aktiv, der RÅck- */
/*        gabewert ist die BCD-codierte MagiC-Version    */
int16 Ash_getMagiCVersion( void );

/* Die MagiC-AES-Variablen bestimmen - auch im Auto-Ordner! */
AESVARS *Ash_getMagiCAESVars( void );

/******************************************************************************/
/*																										*/
/* Funktionen nur in MiNT																		*/
/*																										*/
/******************************************************************************/

int32 Dchroot( const char *path );
int32 Dwritelabel( const char *path, const char *label );

/******************************************************************************/
/*																										*/
/* MiNTNet-Funktionen im MiNT-Kernel														*/
/*																										*/
/******************************************************************************/

int32 Faccept( int16 fd, sockaddrPtr name, socklen_t *namelen );int32 Fbind( int16 fd, const sockaddrPtr name, socklen_t namelen );int32 Fconnect( int16 fd, const sockaddrPtr name, socklen_t namelen );int32 Fgetpeername( int16 fd, sockaddrPtr addr, socklen_t *addrlen );int32 Fgetsockname( int16 fd, sockaddrPtr addr, socklen_t *addrlen );int32 Fgetsockopt( int16 fd, int32 level, int32 optname,
						void *optval, socklen_t *optlen );int32 Flisten( int16 fd, int32 backlog );int32 Freadv( int16 fd, const iovecPtr iovp, ssize_t iovcnt );int32 Frecvfrom( int16 fd, void *buf, ssize_t buflen, int32 flags,						sockaddrPtr from, socklen_t *fromlen );int32 Frecvmsg( int16 fd, msghdrPtr msg, int32 flags );
int32 Fsendto( int16 fd, const void *buf, ssize_t buflen, int32 flags,						const sockaddrPtr addr, socklen_t addrlen );int32 Fsetsockopt( int16 fd, int32 level, int32 optname,
						void *optval, socklen_t optlen );int32 Fshutdown( int16 fh, int32 how );int32 Fsocket( int32 domain, int32 type, int32 protocol );int32 Fsocketpair( int32 domain, int32 type, int32 protocol, int16 rsv[2] );int32 Fwritev( int16 fd, const iovecPtr iov, ssize_t niov );
/******************************************************************************/
/*																										*/
/* PAMsNet-Funktionen																			*/
/*																										*/
/******************************************************************************/

int16 Nactive( void );
void Ndisable( void );
void Nenable( void );
int32 Nlock( const char *file );
int32 Nlocked( void );
int16 Nlogged( int16 nn );
int16 Nmsg( int16 rw, char *buf, char *id, int16 node, int16 leng );
int16 Nnodeid( void );
int16 Nrecord( int16 handle, int16 mm, int32 offset, int32 leng );
int16 Nremote( int16 nn );
void Nreset( void );
int32 Nunlock( const char *file );
int32 Nversion( void );

/******************************************************************************/

#ifdef __GNUC__
	#include <acstosi.h>
#endif

#ifdef __cplusplus}#endif
#endif
