/*********************************************************************
*
* MagiC 3/4/5
* ===========
*
* Strukturen fÅr die Einbindung eines XFS.
* FÅr die Implementation eines XFS in 'C' sind die korrespondierenden
* CDECL_xxx Strukturen fÅr MX_XFS und MX_DEV definiert.
* Dies ermîglicht die Verwendung eines beliebigen Compilers.
*
* Es wird <portab.h> benîtigt.
*
* Version: 10.5.97
*
*********************************************************************/


#define ELINK  -300           /* Datei ist symbolischer Link */

typedef struct {
     WORD version;
     void (*fast_clrmem)      ( void *von, void *bis );
     char (*toupper)          ( char c );
     void (*_sprintf)         ( char *dest, char *source, LONG *p );
     PD	**act_pd;
     APPL *act_appl;
     APPL *keyb_app;
     WORD *pe_slice;
     WORD *pe_timer;
     void (*appl_yield)       ( void );
     void (*appl_suspend)     ( void );
     void (*appl_begcritic)   ( void );
     void (*appl_endcritic)   ( void );
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
/* Ab Kernelversion 1: */
     LONG DMD_rdevinit		( struct _mx_dmd *dmd );
/* Ab Kernelversion 2: */
     LONG proc_info			( WORD code, PD *pd );
/* Ab Kernelversion 4: */
	LONG mxalloc			( LONG amount, WORD mode, PD *pd );
	LONG mfree			( void *block );
	LONG mshrink			( LONG newlen, void *block );
} MX_KERNEL;


typedef struct {
	WORD	version;
	LONG	_dir_srch;
	LONG	reopen_FD;
	LONG	close_DD;
	LONG	match_8_3;
	LONG	conv_8_3;
	LONG	init_DTA;
} MX_DFSKERNEL;


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

typedef struct _cdecl_mx_dev {
     LONG cdecl     (*dev_close)( struct _mx_fd *f );
     LONG cdecl	(*dev_read)( struct _mx_fd *f, LONG count, void *buf );
     LONG cdecl     (*dev_write)( struct _mx_fd *f, LONG count, void *buf );
     LONG cdecl     (*dev_stat)( struct _mx_fd *f, LONG *unselect,
							WORD rwflag, LONG apcode );
     LONG cdecl     (*dev_seek)( struct _mx_fd *f, LONG where, WORD mode );
     LONG cdecl     (*dev_datime)( struct _mx_fd *f, WORD d[2], WORD set );
     LONG cdecl     (*dev_ioctl)( struct _mx_fd *f, WORD cmd, void *buf );
     LONG cdecl	(*dev_getc)( struct _mx_fd *f, WORD mode );
     LONG cdecl     (*dev_getline)( struct _mx_fd *f, char *buf,
     						LONG size, WORD mode );
     LONG cdecl     (*dev_putc)( struct _mx_fd *f, WORD mode, LONG val );
} CDECL_MX_DEV;


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
     char      dta_attrib;
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

typedef struct _cdecl_mx_xfs {
     char			xfs_name[8];
     struct _cdecl_mx_xfs *xfs_next;
     ULONG		xfs_flags;
     LONG cdecl	(*xfs_init)( void );
     void cdecl     (*xfs_sync)( MX_DMD *dmd );
     void	cdecl	(*xfs_pterm)( MX_DMD *dmd, PD *pd );
     LONG cdecl	(*xfs_garbcoll)( MX_DMD *dmd );
     void cdecl	(*xfs_freeDD)( MX_DD *dd );
     LONG cdecl     (*xfs_drv_open)( MX_DMD *dmd );
     LONG cdecl     (*xfs_drv_close)( MX_DMD *dmd, WORD mode );
     MX_DD * cdecl  (*xfs_path2DD)( MX_DD *dd, char *path, WORD mode,
     						char **restp, MX_DD **symlink_dd,
     						void **symlink );
     LONG cdecl     (*xfs_sfirst)( MX_DD *dd, char *name, DTA *dta,
     						WORD attrib, void **symlink );
     LONG cdecl     (*xfs_snext)( DTA *dta, MX_DMD *dmd, void **symlink );
     MX_FD * cdecl  (*xfs_fopen)( MX_DD *dd, char *name, WORD omode,
     						WORD attrib, void **symlink );
     LONG cdecl     (*xfs_fdelete)( MX_DD *dd, char *name );
     LONG cdecl     (*xfs_link)( MX_DD *altdd, MX_DD *neudd,
							char *altname, char *neuname,
							WORD flag );
     LONG cdecl     (*xfs_xattr)( MX_DD *dd, char *name, XATTR *xa,
							WORD mode );
     LONG cdecl     (*xfs_attrib)( MX_DD *dd, char *name, WORD mode,
							WORD attrib );
     LONG cdecl     (*xfs_chown)( MX_DD *dd, char *name, WORD uid,
							WORD gid );
     LONG cdecl     (*xfs_chmod)( MX_DD *dd, char *name, WORD mode );
     LONG cdecl     (*xfs_dcreate)( MX_DD *dd , char *name );
     LONG cdecl     (*xfs_ddelete)( MX_DD *dd );
     LONG cdecl     (*xfs_DD2name)( MX_DD *dd, char *buf, WORD buflen );
     MX_DHD * cdecl (*xfs_dopendir)( MX_DD *d, WORD tosflag );
     LONG cdecl     (*xfs_dreaddir)( MX_DHD *dh, WORD len, char *buf,
							XATTR *xattr, LONG *xr );
     LONG cdecl     (*xfs_drewinddir)( MX_DHD *dhd );
     LONG cdecl     (*xfs_dclosedir)( MX_DHD *dhd );
     LONG cdecl     (*xfs_dpathconf)( MX_DD *dd, WORD which );
     LONG cdecl     (*xfs_dfree)( MX_DD *dd, LONG buf[4] );
     LONG cdecl     (*xfs_wlabel)( MX_DD *dd, char *name );
     LONG cdecl     (*xfs_rlabel)( MX_DD *dd, char *name, char *buf,
     						WORD buflen );
     LONG cdecl     (*xfs_symlink)( MX_DD *dd, char *name, char *to);
     LONG cdecl     (*xfs_readlink)( MX_DD *dd, char *name, char *buf,
     						WORD buflen );
     LONG cdecl     (*xfs_dcntl)( MX_DD *dd, char *name, WORD cmd,
     						LONG arg );
} CDECL_MX_XFS;

/* Dcntl(KER_DOSLIMITS) -> Zeiger auf Zeiger auf: */

typedef struct {
     UWORD     version;                 /* Versionsnummer */
     UWORD     num_drives;              /* max. Anzahl Laufwerke */
     ULONG     max_secsizb;             /* max. Sektorgrîûe in Bytes */
     UWORD     min_nfats;               /* min. Anzahl FATs */
     UWORD     max_nfats;               /* max. Anzahl FATs */
     ULONG     min_nclsiz;              /* min. Anzahl Sektoren/Cluster */
     ULONG     max_nclsiz;              /* max. Anzahl Sektoren/Cluster */
     ULONG     max_ncl;                 /* max. Anzahl Cluster */
     ULONG     max_nsec;                /* max. Anzahl Sektoren */
} MX_DOSLIMITS;

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
#define   KER_DOSLIMITS  0x0101
#define   KER_INSTXFS    0x0200
#define   DFS_GETINFO    0x1100
#define   DFS_INSTDFS    0x1200
#define   DEV_M_INSTALL  0xcd00
#ifndef CDROMEJECT
#define	CDROMEJECT     0x4309	/* Kernel: Medium auswerfen */
#endif

/* unterstÅtzte Dcntl- Modi */
/* # define FUTIME       0x4603 */

/* unterstÅtzte Fcntl- Modi */
#define   FSTAT          0x4600
#define   FIONREAD       0x4601
#define   FIONWRITE      0x4602
#define   FUTIME         0x4603
#define   FTRUNCATE      0x4604
#define   SHMGETBLK      0x4d00
#define   SHMSETBLK      0x4d01
#define   PBASEADDR      0x5002

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
