/*********************************************************************
*
* Mag!X 3.00
* ==========
*
* Strukturen fÅr die Einbindung eines XFS.
* Die korrekten Prototypen fÅr die Implementation eines XFS
* in 'C' folgen, so wie die 'C'- Schnittstelle fertig ist.
*
* Da z.T. mehrere Register fÅr RÅckgabewerte verwendet werden und
* auûerdem Zeiger in Datenregistern Åbergeben werden, ist eine
* Schnittstelle als _cdecl geplant, d.h. sÑmtliche Parameter werden
* auf dem Stapel Åbergeben, dies ermîglicht die Verwendung eines
* beliebigen Compilers.
*
* Version: 3.10.94
*
*********************************************************************/

typedef struct {
     WORD version;
     void (*fast_clrmem)      ( void *von, void *bis );
     char (*toupper)          ( char c );
     void (*_sprintf)         ( char *dest, char *source, LONG *p );
     void *act_pd;
     APPL *act_appl;
     APPL *keyb_app;
     WORD *pe_slice;
     WORD *pe_timer;
     void (*appl_yield)       ( void );
     void (*appl_suspend)     ( void );
     long (*evnt_IO)          ( LONG ticks_50hz, void *unsel );
     void (*evnt_mIO)         ( LONG ticks_50hz, void *unsel, WORD cnt );
     void (*evnt_emIO)        ( APPL *ap );
     void (*appl_IOcomplete)  ( APPL *ap );
     long (*evnt_sem)         ( WORD mode, void *sem, LONG timeout );
     void (*Pfree)            ( void *pd );
     WORD int_msize;
     void *int_malloc         ( void );
     void int_mfree           ( void *memblk );
     void resv_intmem         ( void *mem, LONG bytes );
     LONG diskchange          ( WORD drv );
} MX_KERNEL;


typedef struct _mx_dev {
     long      (*dev_close)();
     long      (*dev_read)();
     long      (*dev_write)();
     long      (*dev_stat)();
     long      (*dev_seek)();
     long      (*dev_datime)();
     long      (*dev_ioctl)();
     long      (*dev_getc)();
     long      (*dev_getline)();
     long      (*dev_putc)();
} MX_DEV;


typedef struct _mx_dd {
     struct _mx_dmd *dd_dmd;
     WORD      dd_refcnt;
} MX_DD;


typedef struct _mx_fd {
     struct _mx_dmd *fd_dmd;
     WORD      fd_refcnt;
     WORD      fd_mode;
     MX_DEV    *fd_dev;
} MX_FD;


typedef struct _mx_dhd {
     struct _mx_dmd *dhd_dmd;
} MX_DHD;


typedef struct _mx_dta {
     char      dta_res1[20];
     char      dta_drive;
     char      dta_attribute;
     WORD      dta_time;
     WORD      dta_date;
     ULONG     dta_len;
     char      dta_name[14];
} MX_DTA;


typedef struct _mx_dmd {
     struct _mx_xfs *d_xfs;
     WORD      d_drive;
     MX_DD     *d_root;
     WORD      biosdev;
     LONG      driver;
     LONG      devcode;
} MX_DMD;


/* structure for getxattr (-> MiNT) */

#ifndef S_IFMT

typedef struct xattr {
     unsigned short mode;
/* file types */
#define S_IFMT 0170000        /* mask to select file type */
#define S_IFCHR     0020000        /* BIOS special file */
#define S_IFDIR     0040000        /* directory file */
#define S_IFREG 0100000       /* regular file */
#define S_IFIFO 0120000       /* FIFO */
#define S_IMEM 0140000        /* memory region or process */
#define S_IFLNK     0160000        /* symbolic link */

/* special bits: setuid, setgid, sticky bit */
#define S_ISUID     04000
#define S_ISGID 02000
#define S_ISVTX     01000

/* file access modes for user, group, and other*/
#define S_IRUSR     0400
#define S_IWUSR 0200
#define S_IXUSR 0100
#define S_IRGRP 0040
#define S_IWGRP     0020
#define S_IXGRP     0010
#define S_IROTH     0004
#define S_IWOTH     0002
#define S_IXOTH     0001
#define DEFAULT_DIRMODE (0777)
#define DEFAULT_MODE     (0666)
     long index;
     unsigned short dev;
     unsigned short reserved1;
     unsigned short nlink;
     unsigned short uid;
     unsigned short gid;
     long size;
     long blksize, nblocks;
     short     mtime, mdate;
     short     atime, adate;
     short     ctime, cdate;
     short     attr;
     short     reserved2;
     long reserved3[2];
} XATTR;

#endif

typedef struct _mx_xfs {
     char      xfs_name[8];
     struct    _mx_xfs *xfs_next;
     ULONG     xfs_flags;
     long      (*xfs_init)();
     long      (*xfs_sync)();
     long      (*xfs_pterm)();
     long      (*xfs_garbcoll)();
     long      (*xfs_freeDD)();
     long      (*xfs_drv_open)();
     long      (*xfs_drv_close)();
     long      (*xfs_path2DD)();
     long      (*xfs_sfirst)();
     long      (*xfs_snext)();
     long      (*xfs_fopen)();
     long      (*xfs_fdelete)();
     long      (*xfs_link)();
     long      (*xfs_xattr)();
     long      (*xfs_attrib)();
     long      (*xfs_chown)();
     long      (*xfs_chmod)();
     long      (*xfs_dcreate)();
     long      (*xfs_ddelete)();
     long      (*xfs_DD2name)();
     long      (*xfs_dopendir)();
     long      (*xfs_dreaddir)();
     long      (*xfs_drewinddir)();
     long      (*xfs_dclosedir)();
     long      (*xfs_dpathconf)();
     long      (*xfs_dfree)();
     long      (*xfs_wlabel)();
     long      (*xfs_rlabel)();
     long      (*xfs_symlink)();
     long      (*xfs_readlink)();
     long      (*xfs_dcntl)();
} MX_XFS;

/* Standardhandles */

#define   STDIN     0
#define   STDOUT    1
#define   STDAUX    2
#define   STDPRN    3
#define   STDHDL4   4
#define   STDHDL5   5

/* Schreib-/Lesemodi fÅr Fgetchar und Fputchar */

#define   CMODE_RAW      0
#define   CMODE_COOKED   1
#define   CMODE_ECHO     2

/* Open- Modus von Dateien (Mag!X- intern)                                 */
/* NOINHERIT wird nicht unterstÅtzt, weil nach TOS- Konvention nur die     */
/* Handles 0..5 vererbt werden                                             */
/* HiByte wie unter MiNT verwendet                                         */

#define   OM_RPERM       1
#define   OM_WPERM       2
#define   OM_EXEC        4
#define   OM_APPEND      8
#define   OM_RDENY       16
#define   OM_WDENY       32
#define   OM_NOCHECK     64


/* Open- Modus von Dateien ( -> MiNT) */

#define   O_RWMODE       3
#define   O_RDONLY       0
#define   O_WRONLY       1
#define   O_RDWR         2
#define   O_EXEC         3

#define   O_APPEND       8

#define   O_SHMODE       0x70
#define   O_COMPAT       0
#define   O_DENYRW       0x10
#define   O_DENYW        0x20
#define   O_DENYR        0x30
#define   O_DENYNONE     0x40

#define   O_CREAT        0x200
#define   O_TRUNC        0x400
#define   O_EXCL         0x800

/* unterstÅtzte Dcntl- Modi (Mag!X- spezifisch!) */
#define   KER_GETINFO    0x0100
#define   KER_INSTXFS    0x0200
#define   KER_SETWBACK   0x0300
#define   DFS_GETINFO    0x1100
#define   DFS_INSTDFS    0x1200
#define   DEV_M_INSTALL  0xcd00

/* unterstÅtzte Fcntl- Modi */
#define   FTRUNCATE      0x4604

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

/* FÅr Psemaphore, die Modi 0/1 werden z.Zt. nicht unterstÅtzt */

#define   PSEM_CRGET     0
#define   PSEM_DESTROY   1
#define   PSEM_GET       2
#define   PSEM_RELEASE   3
