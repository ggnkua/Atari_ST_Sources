*
*
* Strukturen und Konstanten fÅr den Assembler-Teil
* eines MagiX-XFS
*
* Version: Andreas Kromke, 23.5.97
*
*

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
mxk_DMD_rdevinit:	DS.L		1
mxk_ker_proc_info:	DS.L		1
mxk_ker_mxalloc:	DS.L		1
mxk_ker_mfree:		DS.L		1
mxk_ker_mshrink:	DS.L		1

	OFFSET

dfsk_version:		DS.W	1
dfsk_dir_srch:		DS.L	1
dfsk_reopen_FD:	DS.L	1
dfsk_close_DD:		DS.L	1
dfsk_match_8_3:	DS.L	1
dfsk_conv_8_3:		DS.L	1
dfsk_init_DTA:		DS.L	1

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

     OFFSET

p_lowtpa:      DS.L      1    /* 0x00: Beginn TPA, des BP selbst           */
p_hitpa:       DS.L      1    /* 0x04: zeigt 1 Byte hinter TPA             */
p_tbase:       DS.L      1    /* 0x08: Beginn des TEXT - Segments          */
p_tlen:        DS.L      1    /* 0x0c: LÑnge  des TEXT - Segments          */
p_dbase:       DS.L      1    /* 0x10: Beginn des DATA - Segments          */
p_dlen:        DS.L      1    /* 0x14: LÑnge  des DATA - Segments          */
p_bbase:       DS.L      1    /* 0x18: Beginn des BSS  - Segments          */
p_blen:        DS.L      1    /* 0x1c: LÑnge  des BSS  - Segments          */
p_dta:         DS.L      1    /* 0x20: Aktueller DTA- Puffer               */
p_parent:      DS.L      1    /* 0x24: Zeiger auf BP des Parent            */
p_procid:      DS.W      1	/* 0x28: Prozeû- ID        				*/
p_res1:        DS.W      1
p_env:         DS.L      1    /* 0x2c: Zeiger auf Environment              */
p_devx:        DS.B      6
p_res2:        DS.B      1
p_defdrv:      DS.B      1    /* 0x37: Default- Laufwerk                   */
p_res3:        DS.B      8
p_drvx:        DS.B     32	/* 0x40	*/
p_res4:		DS.L		1	/* 0x60	*/
p_umask:		DS.W		1	/* 0x64: Maske fÅr Dateirechte			*/
p_res5:        DS.W		1	/* 0x66	*/
p_mem:         DS.L      1
p_context:     DS.L      1
p_mflags:      DS.L      1
p_mres3:       DS.L      1
p_mres4:       DS.L      1
p_reg:         DS.L      1
p_cmdlin:      DS.B    128    /* 0x80: Kommandozeile                       */

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
DP_IOPEN       EQU  0    /* internal limit on # of open files */
DP_MAXLINKS    EQU  1    /* max number of hard links to a file */
DP_PATHMAX     EQU  2    /* max path name length */
DP_NAMEMAX     EQU  3    /* max length of an individual file name */
DP_ATOMIC      EQU  4    /* # of bytes that can be written atomically */
DP_TRUNC       EQU  5    /* file name truncation behavior */
 DP_NOTRUNC    EQU  0    /* long filenames give an error */
 DP_AUTOTRUNC  EQU  1    /* long filenames truncated */
 DP_DOSTRUNC   EQU  2    /* DOS truncation rules in effect */
DP_CASE        EQU  6
 DP_CASESENS   EQU  0    /* case sensitive */
 DP_CASECONV   EQU  1    /* case always converted */
 DP_CASEINSENS EQU  2    /* case insensitive, preserved */
DP_MODEATTR    EQU  7
 DP_ATTRBITS   EQU  $000000ff
 DP_MODEBITS   EQU  $000fff00
 DP_FILETYPS   EQU  $fff00000
  DP_FT_DIR    EQU  $00100000
  DP_FT_CHR    EQU  $00200000
  DP_FT_BLK    EQU  $00400000
  DP_FT_REG    EQU  $00800000
  DP_FT_LNK    EQU  $01000000
  DP_FT_SOCK   EQU  $02000000
  DP_FT_FIFO   EQU  $04000000
  DP_FT_MEM    EQU  $08000000
DP_XATTRFIELDS EQU  8
 DP_INDEX      EQU  $0001
 DP_DEV        EQU  $0002
 DP_RDEV       EQU  $0004
 DP_NLINK      EQU  $0008
 DP_UID        EQU  $0010
 DP_GID        EQU  $0020
 DP_BLKSIZE    EQU  $0040
 DP_SIZE       EQU  $0080
 DP_NBLOCKS    EQU  $0100
 DP_ATIME      EQU  $0200
 DP_CTIME      EQU  $0400
 DP_MTIME      EQU  $0800

/* FÅr Psemaphore, die Modi 0/1 werden z.Zt. nicht unterstÅtzt */

PSEM_CRGET     EQU  0    /* create and get */
PSEM_DESTROY   EQU  1
PSEM_GET       EQU  2
PSEM_RELEASE   EQU  3
