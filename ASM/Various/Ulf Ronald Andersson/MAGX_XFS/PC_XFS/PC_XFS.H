/*
 * pc_xfs.h vom 23.06.1996
 *
 * Autor:
 * Thomas Binder
 * (binder@rbg.informatik.th-darmstadt.de)
 *
 * Zweck:
 * Headerdatei fÅr die Pure-C-MagiC-3-XFS-Schnittstelle. Die genau
 * Beschreibung der Funktionen entnehme man der MagiC-3-Doku, die fÅr
 * registrierte Benutzer bei ASH erhÑltlich ist. Hier finden sich nur
 * ErklÑrungen fÅr die Unterschiede zwischen der Beschreibung in der
 * Doku und den benutzten Funktionspointern, die sich aus technischen
 * GrÅnden leider nicht vermeiden lieûen.
 *
 * History:
 * 04.11.-
 * 05.11.1995: Erstellung
 * 06.11.1995: MX_KERNEL in THE_MX_KERNEL umbenannt, da sich gezeigt
 *             hat, daû die darin erreichbaren Funktionen Register A2
 *             verÑndern, was Pure C gewaltig in's Schleudern bringt.
 *             Daher muûte auch diese Struktur auf eine eigene
 *             interne abgebildet werden, in der die Funktionen die
 *             Register vorher retten und dann die eigentlich
 *             gewÅnschte Routine anspringen (siehe pc_xfs.s).
 * 07.11.1995: XATTR-Struktur kommentiert und mit Konstanten versehen
 * 10.11.1995: mode bei xfs_dcreate entfernt, da es in der neuen
 *             MagiC-3-Doku nicht mehr auftaucht.
 * 11.11.1995: _sprintf in der Kernel-Struktur ist nicht mehr cdecl,
 *             da ja sowieso eine vorgeschaltete Routine angesprungen
 *             wird, die dann die Parameter auf den Stack legt.
 * 12.11.1995: xfs_fopen, xfs_xattr und xfs_attrib mÅssen bei Bedarf
 *             auch einen Zeiger auf einen symbolischen Link liefern,
 *             daher wurde bei den Prototypen ein solcher eingebaut.
 * 23.11.1995: dta_drive war versehentlich WORD statt char.
 * 11.12.1995: Erweiterung der THE_MX_KERNEL-Struktur um die neuen
 *             Elemente von Kernelversion 1 und 2.
 * 26.12.1995: KER_INSTXFS und KER_GETINFO aufgenommen.
 * 28.12.1995: Auch xfs_chmod, xfs_chown und xfs_dcntl mÅssen u.U.
 *             einen Zeiger auf einen symbolischen Link liefern,
 *             daher wurden die Prototypen entsprechend erweitert.
 * 31.12.1995: path2DD hat jetzt kein unhandliches returns-Array
 *             mehr, sondern die neuen Einzelparameter lastpath,
 *             linkdir und symlink.
 * 02.01.1996: Bei dev_getline waren mode und size vertauscht.
 * 13.02.1996: Der zweite Parameter fÅr install_xfs war unnîtig und
 *             ist deswegen jetzt 'rausgeflogen, ebenso wie der
 *             Zeiger real_dev.
 * 16.06.1996: d_devcode in der Struktur DMD war vom falschen Typ.
 * 23.06.1996: Neue Elemente mxalloc, mfree und mshrink in die
 *             Kernelstruktur aufgenommen.
 */

#ifndef __PC_XFS__
#define __PC_XFS__

#include <tos.h>
#include <portab.h>
#include "atarierr.h"

#ifndef ELINK
#define ELINK		-300
#define KER_GETINFO	0x100
#define KER_INSTXFS	0x200
#endif

/*
 * Zeiger auf die tatsÑchlich von MagiC angesprochenen Strukturen.
 * Sie werden u.a. bei xfs_drv_open und bei xfs_fopen benîtigt, denn
 * es darf natÅrlich nie der Zeiger auf die C-Struktur eingetragen
 * werden, wenn es sich um MagiC-Strukturen wie DMD, DD, FD, oder DHD
 * handelt.
 */
extern void	*real_xfs;

/* Die MagiC-3-DTA */
typedef struct
{
	char	dta_res1[20];
	char	dta_drive;
	char	dta_attribute;
	WORD	dta_time;
	WORD	dta_date;
	LONG	dta_len;
	char	dta_name[14];
} MGX_DTA;

/*
 * Der Drive-Media-Descriptor (DMD); prinzipiell erweiterbar, aber
 * leider kann Pure C ja keine Vererbung :(
 */
typedef struct
{
	void	*d_xfs;
	WORD	d_drive;
	void	*d_root;
	WORD	d_biosdev;
	void	*d_driver;
	LONG	d_devcode;
	void	*d_dfs;
} DMD;

/* Die Struktur(en) fÅr dev_stat */
typedef union unsel_union
{
	void	(*unsel)(void *un);
	LONG	status;
} UNSELECT;

typedef struct magx_unsel_struct
{
	UNSELECT	unsel;
	LONG		param;
} MAGX_UNSEL;

/* Die XATTR-Struktur */
typedef struct {
    UWORD   mode;           /* Filetyp und -modus */
/* Mîgliche Filetypen */
#define S_IFMT  0170000     /* Maske zur Isolierung des Filetyps */
#define S_IFCHR 0020000     /* Spezielles BIOS-File (z.B. Device) */
#define S_IFDIR 0040000     /* Verzeichnis */
#define S_IFREG 0100000     /* Normale Datei */
#define S_IFIFO 0120000     /* FIFO (Pipe mit Namen) */
#define S_IMEM  0140000     /* Speicherblock- oder Prozeûfile */
#define S_IFLNK 0160000     /* Symbolischer Link */

/*
 * Spezielle Bits (zumindest die ersten beiden kînnen unter MagiC
 * ohne énderung des XFS-Konzepts nicht korrekt benutzt werden)
 */
#define S_ISUID 04000       /* User-ID des EigentÅmers bei Aufruf setzen */
#define S_ISGID 02000       /* Gruppen-ID bei Aufruf setzen */
#define S_ISVTX 01000       /* "Sticky bit", Bedeutung abhÑngig vom Filetyp */

/* Zugriffsrechte */
#define S_IRUSR 0400        /* EigentÅmer darf Datei lesen */
#define S_IWUSR 0200        /*      "       "    "   beschreiben */
#define S_IXUSR 0100        /*      "       "    "   ausfÅhren */
#define S_IRGRP 0040        /* Gruppenmitglieder dÅrfen Datei lesen */
#define S_IWGRP 0020        /*          "           "     "   beschreiben */
#define S_IXGRP 0010        /*          "           "     "   ausfÅhren */
#define S_IROTH 0004        /* Andere dÅrfen Datei lesen */
#define S_IWOTH 0002        /*    "      "     "   beschreiben */
#define S_IXOTH 0001        /*    "      "     "   ausfÅhren */

    LONG    index;          /* Fileindex, wie bei Dreaddir */
    UWORD   dev;            /* GerÑt, auf dem die Datei liegt */
    UWORD   rdev;           /* TatsÑchliches GerÑt (z.B. bei BIOS-Files) */
    UWORD   nlink;          /* Zahl der "echten" Links auf dieses File */
    UWORD   uid;            /* User-ID des EigentÅmers */
    UWORD   gid;            /* Gruppen-ID fÅr dieses File */
    LONG    size;           /* LÑnge in Bytes */
    LONG    blksize;        /* Grîûe eines Blocks in Bytes */
    LONG    nblocks;        /* Anzahl von Blocks, die die Datei belegt */
    WORD    mtime;          /* Uhrzeit der letzten Modifikation */
    WORD    mdate;          /* Datum der letzten Modifikation */
    WORD    atime;          /* Uhrzeit des letzten Zugriffs auf die Datei */
    WORD    adate;          /* Datum des letzten Zugriffs */
    WORD    ctime;          /* Erzeugungszeit */
    WORD    cdate;          /* Erzeugungsdatum */
    WORD    attr;           /* Standard-TOS-Attribute (wie bei Fattrib) */
    WORD    reserved2;      /* bislang reserviert */
    LONG    reserved3[2];   /* dito */
} XATTR;

/*
 * Die XFS-Schnittstelle, wie sie das C-Programm sieht. In dieser
 * Struktur fehlen die Anteile der XFS-Schnittstelle, die fÅr
 * (externe) Treiber ohne Belang sind.
 */
typedef struct
{
	char	xfs_name[8];
	LONG	(*xfs_sync)(DMD *d);
	void	(*xfs_pterm)(BASPAG *pd);
/*
 * FÅr xfs_garbcoll muû ein Funktionspointer angegeben werden, auch
 * wenn das Filesystem die interne Speicherverwaltung von MagiC 3
 * nicht benutzt. In diesem Fall einfach eine Funktion einbinden, die
 * 0L zurÅckliefert.
 */
	LONG	(*xfs_garbcoll)(DMD *d);
	void	(*xfs_freeDD)(void *dd);
	LONG	(*xfs_drv_open)(DMD *d);
	LONG	(*xfs_drv_close)(DMD *d, WORD mode);
/*
 * Da xfs_path2DD normalerweise bis zu vier RÅckgabewerte hat, werden
 * drei davon in Zeigerparametern zurÅckgegeben. Die Zuordnung der
 * Register (siehe MagiC-3-Doku):
 * d0: RÅckgabewert der C-Funktion
 * d1: *lastpath
 * a0: *linkdir
 * a1: *symlink
 */
	LONG	(*xfs_path2DD)(void *reldir, char *pathname, WORD mode,
		char **lastpath, LONG *linkdir, char **symlink);
/*
 * Auch xfs_sfirst liefert zwei RÅckgabeparameter. Da a0 aber nur
 * einen Zeiger auf einen Symbolischen Link enthalten kann, ist der
 * Parameter entsprechend als char ** deklariert, d.h. die C-Funktion
 * muû ggf. hier den Zeiger auf den symbolischen Link ablegen (dabei
 * nicht vergessen, daû die ersten beiden "Buchstaben" die LÑnge des
 * Links (als Wort) angeben).
 */
	LONG	(*xfs_sfirst)(void *srchdir, char *name, MGX_DTA *dta,
		WORD attrib, char **symlink);
/* Entsprechendes gilt natÅrlich auch fÅr xfs_snext */
	LONG	(*xfs_snext)(MGX_DTA *dta, DMD *dmd, char **symlink);
#define OM_RPERM	1
#define OM_WPERM	2
#define OM_EXEC		4
#define OM_APPEND	8
#define OM_RDENY	16
#define OM_WDENY	32
#define OM_NOCHECK	64
#define O_CREAT		0x200
#define O_TRUNC		0x400
#define O_EXCL		0x800
/*
 * Auch xfs_fopen liefert unter UmstÑnden einen Zeiger auf einen
 * symbolischen Link...
 */
	LONG	(*xfs_fopen)(void *dir, char *name, WORD omode,
		WORD attrib, char **symlink);
	LONG	(*xfs_fdelete)(void *dir, char *name);
	LONG	(*xfs_link)(void *olddir, void *newdir, char *oldname,
		char *newname, WORD flag_link);
/* Ebenfalls zusÑtzlich mit Platzhalter fÅr symbolischen Link */
	LONG	(*xfs_xattr)(void *dir, char *name, XATTR *xattr,
		WORD mode, char **symlink);
/* Und noch dreimal... */
	LONG	(*xfs_attrib)(void *dir, char *name, WORD rwflag,
		WORD attrib, char **symlink);
	LONG	(*xfs_chown)(void *dir, char *name, UWORD uid,
		UWORD gid, char **symlink);
	LONG	(*xfs_chmod)(void *dir, char *name, UWORD mode,
		char **symlink);
	LONG	(*xfs_dcreate)(void *dir, char *name);
	LONG	(*xfs_ddelete)(void *dir);
	LONG	(*xfs_DD2name)(void *dir, char *name, WORD bufsize);
	LONG	(*xfs_dopendir)(void *dir, WORD tosflag);
	LONG	(*xfs_dreaddir)(void *dhd, WORD size, char *buf,
		XATTR *xattr, LONG *xr);
	LONG	(*xfs_drewinddir)(void *dhd);
	LONG	(*xfs_dclosedir)(void *dhd);
	LONG	(*xfs_dpathconf)(void *dir, WORD which);
	LONG	(*xfs_dfree)(void *dd, DISKINFO *free);
	LONG	(*xfs_wlabel)(void *dir, char *name);
	LONG	(*xfs_rlabel)(void *dir, char *name, char *buf,
		WORD len);
	LONG	(*xfs_symlink)(void *dir, char *name, char *to);
	LONG	(*xfs_readlink)(void *dir, char *name, char *buf,
		WORD size);
/* Nochmal mit Platzhalter fÅr symbolischen Link */
	LONG	(*xfs_dcntl)(void *dir, char *name, WORD cmd, LONG arg,
		char **symlink);
} THE_MGX_XFS;

/*
 * Devicetreiber, wieder aus C-Sicht, trotzdem identisch mit der
 * "echten" Struktur, d.h. hier sind keine vorgeschalteten
 * Assemblerroutinen nîtig
 */
typedef struct
{
	LONG	(*dev_close)(void *file);
	LONG	(*dev_read)(void *file, LONG count, char *buffer);
	LONG	(*dev_write)(void *file, LONG count, char *buffer);
	LONG	(*dev_stat)(void *file, MAGX_UNSEL *unselect,
		WORD rwflag, LONG apcode);
	LONG	(*dev_seek)(void *file, LONG where, WORD mode);
	LONG	(*dev_datime)(void *file, WORD *d, WORD setflag);
	LONG	(*dev_ioctl)(void *file, WORD cmd, void *buf);
#define CMODE_RAW		0
#define CMODE_COOKED	1
#define CMODE_ECHO		2
	LONG	(*dev_getc)(void *file, WORD mode);
	LONG	(*dev_getline)(void *file, char *buf, WORD mode,
		LONG size);
	LONG	(*dev_putc)(void *file, WORD mode, LONG value);
} THE_MGX_DEV;

/*
 * Die Kernel-Struktur, deren Funktionen leider auch nicht direkt von
 * Pure C aus aufgerufen werden kînnen, da sie unter UmstÑnden das
 * Register A2 verÑndern, was Pure C Åberhaupt nicht mag. Also wird
 * diese Struktur ebenfalls nachgebildet... Um die Variablen aus der
 * Struktur anzusprechen empfiehlt es sich, den Zeiger real_kernel
 * zu benutzen, da die Kopie nicht aktualisiert wird und es durchaus
 * denkbar ist, daû einer der Variablenzeiger nachtrÑglich geÑndert
 * wird. Die vorgeschalteten Funktionen benutzen selbstverstÑndlich
 * auch real_kernel, um die tatsÑchlich gewÅnschten Routinen
 * aufzurufen.
 */
typedef struct
{
	WORD		version;
	void		(*fast_clrmem)(void *von, void *bis);
	char		(*to_upper)(WORD c);
	void 		(*_sprintf)(char *dest, char *source, LONG *p);
	BASPAG		**act_pd;
	void		*act_appl;
	void		*keyb_appl;
	WORD		*pe_slice;
	WORD		*pe_timer;
	void		(*appl_yield)(void);
	void		(*appl_suspend)(void);
	void		(*appl_begcritic)(void);
	void		(*appl_endcritic)(void);
	LONG		(*event_IO)(LONG ticks_50hz, MAGX_UNSEL *unsel);
	void		(*event_mIO)(LONG ticks_50hz, MAGX_UNSEL *unsel,
		WORD cnt);
	void		(*event_emIO)(void *ap);
	void		(*appl_IOcomplete)(void *ap);
#define SEM_FREE	0
#define SEM_SET		1
#define SEM_TEST	2
#define SEM_CSET	3
#define SEM_GET		4
#define SEM_CREATE	5
#define SEM_DEL		6
	LONG		(*evnt_sem)(WORD mode, void *sem, LONG timeout);
	void		(*Pfree)(BASPAG *pd);
	WORD		int_msize;
	void		*(*int_malloc)(void);
	void		(*int_mfree)(void *memblk);
	void		(*resv_intmem)(void *mem, LONG bytes);
	LONG		(*diskchange)(WORD drv);
/* Dieses Element existiert nur, wenn version >= 1 ist! */
	LONG		(*DMD_rdevinit)(DMD *dmd);
/* Dieses Element existiert nur, wenn version >= 2 ist! */
	LONG		(*proc_info)(WORD code, BASPAG *pd);
/* Die folgenden drei Elemente existieren nur bei version >= 4! */
	void		*(*mxalloc)(LONG amount, WORD mode, BASPAG *pd);
	LONG		(*mfree)(void *block);
	void		*(*mshrink)(void *block, LONG newlen);
} THE_MX_KERNEL;

/*
 * Zeiger auf die tatsÑchlich von Dcntl(KER_INSTXFS, ...) gelieferte
 * Kernelstruktur. Die Funktionen sollten nicht angesprochen werden,
 * fÅr das Auslesen der Variablen ist es jedoch ratsam, immer Åber
 * diese Struktur zu gehen, da die Kopie nicht aktualisiert wird.
 */
extern THE_MX_KERNEL *real_kernel;

/*
 * Routine zur Installation des XFS. Ihr Åbergibt man den Zeiger auf
 * das zu installierende XFS. ZurÅck erhÑlt man einen Zeiger auf die
 * Kernelstruktur von MagiC 3 oder NULL, wenn ein Fehler aufgetreten
 * ist.
 */
THE_MX_KERNEL *install_xfs(THE_MGX_XFS *xfs);

/* Einfachste Form eines DD */
typedef struct
{
	DMD		*dd_dmd;
	WORD	dd_refcnt;
} MGX_DD;

/* Einfachste Form eines FD */
typedef struct
{
	DMD		*fd_dmd;
	WORD	fd_refcnt;
	WORD	fd_mode;
	void	*fd_dev;
} MGX_FD;

/* Einfachste Form eines DHD */
typedef struct
{
	DMD		*dhd_dmd;
} MGX_DHD;

#endif

/* EOF */
