     OFFSET

mxk_version:        DS.W      1
mxk_fast_clrmem:    DS.L      1
mxk_toupper:        DS.L      1
mxk__sprintf:       DS.L      1
mxk_act_pd:         DS.L      1
mxk_act_appl:       DS.L      1
mxk_keyb_app:       DS.L      1
mxk_pe_slice:       DS.L      1
mxk_pe_timer:       DS.L      1
mxk_appl_yield:     DS.L      1
mxk_appl_suspend:   DS.L      1
mxk_appl_begcritic: DS.L      1
mxk_appl_endcritic: DS.L      1
mxk_evnt_IO:        DS.L      1
mxk_evnt_mIO:       DS.L      1
mxk_evnt_emIO:      DS.L      1
mxk_appl_IOcomplete:DS.L      1
mxk_evnt_sem:       DS.L      1
mxk_Pfree:          DS.L      1
mxk_int_msize:      DS.W      1
mxk_int_malloc:     DS.L      1
mxk_int_mfree:      DS.L      1
mxk_resv_intmem:    DS.L      1
mxk_diskchange:     DS.L      1

     OFFSET

dev_close:     DS.L      1
dev_read:      DS.L      1
dev_write:     DS.L      1
dev_stat:      DS.L      1
dev_seek:      DS.L      1
dev_datime:    DS.L      1
dev_ioctl:     DS.L      1
dev_getc:      DS.L      1
dev_getline:   DS.L      1
dev_putc:      DS.L      1

     OFFSET

dd_dmd:        DS.L      1    /* 0x00: Zeiger auf DMD                      */
dd_refcnt:     DS.W      1    /* 0x04: Ref.zÑhler fÅr Standardpfade        */

     OFFSET

fd_dmd:        DS.L      1    /* 0x00: Zeiger auf DMD                      */
fd_refcnt:     DS.W      1    /* 0x04: Ref.zÑhler fÅrs Schlieûen oder -1   */
fd_mode:       DS.W      1    /* 0x06: Open- Modus (0,1,2) und flags       */
fd_dev:        DS.L      1    /* 0x08: Zeiger auf MX_DEV                   */

     OFFSET

dhd_dmd:       DS.L      1    /* 0x00: Zeiger auf DMD                      */

     OFFSET

dta_res1:      DS.B      20
dta_drive:     DS.B      1    /* 0x14: */
dta_res2:      DS.B      1    /* 0x15: */
dta_time:      DS.W      1    /* 0x16: gefundene Zeit                      */
dta_date:      DS.W      1    /* 0x18: gefundenes Datum                    */
dta_len:       DS.L      1    /* 0x1a: gefundene LÑnge                     */
dta_name:      DS.B      14   /* 0x1e: gefundener Dateiname                */

     OFFSET

d_xfs:         DS.L      1    /* 0x00: Der Dateisystemtreiber              */
d_drive:       DS.W      1    /* 0x04: Laufwerknummer 0..31                */
d_root:        DS.L      1    /* 0x06: Zeiger auf FD der Root              */
d_biosdev:     DS.W      1    /* 0x0a: BIOS-Laufwerk oder -1               */
d_driver:      DS.L      1    /* 0x0c: def. zus. mit devcode das Medium    */
d_devcode:     DS.L      1    /* 0x10: z.B. SCSI Target & Laufwerk         */

     OFFSET

xattr_mode:    DS.W      1    /* %ttttsssrwxrwxrwx                         */
                              /* Bit 12,13,14,15: Dateityp                 */
                              /*         2: BIOS special file              */
                              /*         4: Directory file                 */
                              /*         8: regular file                   */
                              /*        10: fifo                           */
                              /*        12: memory region or process       */
                              /*        14: symbolic link                  */
                              /* Bit 9,10,11: special bits                 */
                              /*         1: sticky bit (?)                 */
                              /*         2: setgid (?)                     */
                              /*         4: setuid (?)                     */
                              /* Bit 0..8: access modes                    */
                              /*         rwx fÅr user/group/world          */
xattr_index:   DS.L      1
xattr_dev:     DS.W      1
xattr_res1:    DS.W      1
xattr_nlink:   DS.W      1
xattr_uid:     DS.W      1
xattr_gid:     DS.W      1
xattr_size:    DS.L      1
xattr_blksize: DS.L      1
xattr_nblocks: DS.L      1
xattr_mtime:   DS.W      1
xattr_mdate:   DS.W      1
xattr_atime:   DS.W      1
xattr_adate:   DS.W      1
xattr_ctime:   DS.W      1
xattr_cdate:   DS.W      1
xattr_attr:    DS.W      1
xattr_res2:    DS.W      1
xattr_res3:    DS.L      2
xattr_sizeof:

     OFFSET

xfs_name:      DS.B      8
xfs_next:      DS.L      1
xfs_flags:     DS.L      1
xfs_init:      DS.L      1
xfs_sync:      DS.L      1
xfs_pterm:     DS.L      1
xfs_garbcoll:  DS.L      1
xfs_freeDD:    DS.L      1
xfs_drv_open:  DS.L      1
xfs_drv_close: DS.L      1
xfs_path2DD:   DS.L      1
xfs_sfirst:    DS.L      1
xfs_snext:     DS.L      1
xfs_fopen:     DS.L      1
xfs_fdelete:   DS.L      1
xfs_link:      DS.L      1
xfs_xattr:     DS.L      1
xfs_attrib:    DS.L      1
xfs_chown:     DS.L      1
xfs_chmod:     DS.L      1
xfs_dcreate:   DS.L      1
xfs_ddelete:   DS.L      1
xfs_DD2name:   DS.L      1
xfs_dopendir:  DS.L      1
xfs_dreaddir:  DS.L      1
xfs_drewinddir: DS.L     1
xfs_dclosedir: DS.L      1
xfs_dpathconf: DS.L      1
xfs_dfree:     DS.L      1
xfs_wlabel:    DS.L      1
xfs_rlabel:    DS.L      1
xfs_symlink:   DS.L      1
xfs_readlink:  DS.L      1
xfs_dcntl:     DS.L      1

     TEXT

/* Standardhandles */

STDIN               EQU  0
STDOUT              EQU  1
STDAUX              EQU  2
STDPRN              EQU  3
STDHDL4             EQU  4
STDHDL5             EQU  5

/* Schreib-/Lesemodi fÅr Fgetchar und Fputchar */

CMODE_RAW           EQU  0
CMODE_COOKED        EQU  1
BCMODE_COOKED       EQU  0
CMODE_ECHO          EQU  2
BCMODE_ECHO         EQU  1

/* Open- Modus von Dateien (Mag!X- intern)                                 */
/* NOINHERIT wird nicht unterstÅtzt, weil nach TOS- Konvention nur die     */
/* Handles 0..5 vererbt werden                                             */
/* HiByte wie unter MiNT verwendet                                         */

OM_RPERM       EQU  1         /* Datei ist zum Lesen geîffnet              */
BOM_RPERM      EQU  0
OM_WPERM       EQU  2         /* Datei ist zum Schreiben geîffnet          */
BOM_WPERM      EQU  1
OM_EXEC        EQU  4         /* Datei ist zum AusfÅhren geîffnet          */
BOM_EXEC       EQU  2
OM_APPEND      EQU  8         /* Schreibzugriffe ans Ende (Kernel!)        */
BOM_APPEND     EQU  3
OM_RDENY       EQU  16        /* andere dÅrfen nicht gleichz. lesen        */
BOM_RDENY      EQU  4
OM_WDENY       EQU  32        /* andere dÅrfen nicht gleichz. schreiben    */
BOM_WDENY      EQU  5
OM_NOCHECK     EQU  64        /* KEINE öberprÅfung durch den Kernel        */
BOM_NOCHECK    EQU  6


/* Open- Modus von Dateien (MiNT) */
O_RWMODE       EQU  3         /* Maske fÅr r/w- Modi */
O_RDONLY       EQU  0
O_WRONLY       EQU  1
O_RDWR         EQU  2
O_EXEC         EQU  3

O_APPEND       EQU  8         /* Schreiben geht immer ans Dateiende   */
BO_APPEND      EQU  3

O_SHMODE       EQU  $70
O_COMPAT       EQU  0
O_DENYRW       EQU  $10
O_DENYW        EQU  $20
O_DENYR        EQU  $30
O_DENYNONE     EQU  $40

O_NOINHERIT    EQU  $80       ; von Mag!X nicht unterstÅtzt
O_NDELAY       EQU  $100      ; von Mag!X nicht unterstÅtzt
O_CREAT        EQU  $200
BO_CREAT       EQU  9
O_TRUNC        EQU  $400
BO_TRUNC       EQU  10
O_EXCL         EQU  $800
BO_EXCL        EQU  11
O_TTY          EQU  $2000     ; von Mag!X nicht unterstÅtzt
O_HEAD         EQU  $4000     ; von Mag!X nicht unterstÅtzt
O_LOCK         EQU  $8000     ; von Mag!X nicht unterstÅtzt

; unterstÅtzte Dcntl- Modi (Mag!X- spezifisch!)
KER_GETINFO    EQU  $0100     /* Kernel: gib Zeiger auf Kernel zurÅck    */
KER_DOSLIMITS  EQU  $0101     /* Kernel: Limits fÅr FAT-Dateisysteme */
KER_INSTXFS    EQU  $0200     /* Kernel: installiere ein XFS */
KER_SETWBACK   EQU  $0300     /* Kernel: konfiguriere writeback */
DFS_GETINFO    EQU  $1100     /* XFS_DOS: gib Zeiger auf DFS-Kernel */
DFS_INSTDFS    EQU  $1200     /* XFS_DOS: installiere ein DFS */
DEV_M_INSTALL  EQU  $cd00     /* DFS_U */

; unterstÅtzte Fcntl- Modi
FSTAT          EQU  $4600
FIONREAD       EQU  $4601
FIONWRITE      EQU  $4602
FUTIME         EQU  $4603
FTRUNCATE      EQU  $4604
SHMGETBLK      EQU  $4d00
SHMSETBLK      EQU  $4d01
PBASEADDR      EQU  $5002

LASTDRIVE      EQU  'Z'-'A'   ; hîchste Laufwerknummer

/* Modi und Codes fÅr Dpathconf() */

DP_MAXREQ      EQU  -1
DP_IOPEN       EQU  0
DP_MAXLINKS    EQU  1
DP_PATHMAX     EQU  2
DP_NAMEMAX     EQU  3
DP_ATOMIC      EQU  4
DP_TRUNC       EQU  5
 DP_NOTRUNC    EQU  0
 DP_AUTOTRUNC  EQU  1
 DP_DOSTRUNC   EQU  2
DP_CASE        EQU  6
 DP_CASESENS   EQU  0
 DP_CASECONV   EQU  1
 DP_CASEINSENS EQU  2

/* FÅr Psemaphore, die Modi 0/1 werden z.Zt. nicht unterstÅtzt */

PSEM_CRGET     EQU  0    /* create and get */
PSEM_DESTROY   EQU  1
PSEM_GET       EQU  2
PSEM_RELEASE   EQU  3
