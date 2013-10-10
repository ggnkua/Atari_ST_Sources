     OFFSET

ddev_open:     DS.L      1
ddev_close:    DS.L      1
ddev_read:     DS.L      1
ddev_write:    DS.L      1
ddev_stat:     DS.L      1
ddev_seek:     DS.L      1
ddev_datime:   DS.L      1
ddev_ioctl:    DS.L      1
ddev_delete:   DS.L      1
ddev_getc:     DS.L      1
ddev_getline:  DS.L      1
ddev_putc:     DS.L      1

     OFFSET

fd_dmd:        DS.L      1    /* 0x00: Zeiger auf DMD                      */
fd_refcnt:     DS.W      1    /* 0x04: Ref.zÑhler fÅrs Schlieûen oder -1   */
fd_mode:       DS.W      1    /* 0x06: Open- Modus (0,1,2) und flags       */
fd_dev:        DS.L      1    /* 0x08: Zeiger auf MX_DEV                   */
fd_ddev:       DS.L      1    /* 0x0c: Zeiger auf MX_DDEV                  */
fd_name:       DS.B      11   /* 0x10: DD_FD: Name im internen Format      */
fd_attr:       DS.B      1    /* 0x1b: Attribut                            */
fd_owner:      DS.L      1    /* 0x1c: DD_FD: Eigner eines FD oder NULL    */
fd_parent:     DS.L      1    /* 0x20: Zeiger auf den Parent-DD_FD         */
fd_children:   DS.L      1    /* 0x24: DD_FD: Liste aller Kinder           */
fd_next:       DS.L      1    /* 0x28: Zeiger auf FDs im selben Verzeichn. */
fd_multi:      DS.L      1    /* 0x2c: Zeiger auf FD derselben Datei       */
fd_multi1:     DS.L      1    /* 0x30: Zeiger auf erstes Listenelement     */
fd_fpos:       DS.L      1    /* 0x34: Position des Dateizeigers           */
fd_dirch:      DS.B      1    /* 0x38: Bit0: "dirty"                       */
fd_unused:     DS.B      1    /* 0x39: */
fd_time:       DS.W      1    /* 0x3a: Zeit  (8086)                        */
fd_date:       DS.W      1    /* 0x3c: Datum (8086)                        */
fd_stcl:       DS.W      1    /* 0x3e: Start- Cluster                      */
fd_len:        DS.L      1    /* 0x40: DateilÑnge in Bytes                 */
fd_dirpos:     DS.L      1    /* 0x44: Pos. des zug. Eintrags im Directory */
fd_user1:      DS.L      1    /* 0x48: */
fd_user2:      DS.L      1    /* 0x4c: */

     OFFSET

dta_sname:     DS.B      12   /* 0x00: Suchname     (von Fsfirst)          */
dta_usr1:      DS.L      1    /* 0x0c: zur freien Verwendung               */
dta_usr2:      DS.L      1    /* 0x10: zur freien VerfÅgung                */
dta_drive:     DS.B      1    /* 0x14: logisches Laufwerk (0..25)          */
dta_attr:      DS.B      1    /* 0x15: gefundenes Attribut                 */
dta_time:      DS.W      1    /* 0x16: gefundene Zeit                      */
dta_date:      DS.W      1    /* 0x18: gefundenes Datum                    */
dta_len:       DS.L      1    /* 0x1a: gefundene LÑnge                     */
dta_name:      DS.B      14   /* 0x1e: gefundener Dateiname                */

     OFFSET

; die ersten drei EintrÑge existieren fÅr jedes Dateisystem
d_xfs:         DS.L      1    /* 0x00: Der Dateisystemtreiber              */
d_drive:       DS.W      1    /* 0x04: Laufwerknummer 0..31                */
d_root:        DS.L      1    /* 0x06: Zeiger auf FD der Root              */
d_biosdev:     DS.W      1    /* 0x0a: BIOS-Laufwerk oder -1               */
d_driver:      DS.L      1    /* 0x0c: def. zus. mit devcode das Medium    */
d_devcode:     DS.L      1    /* 0x10: z.B. SCSI Target & Laufwerk         */
; dieser Eintrag existiert nur fÅr DOS- Dateisysteme
d_dfs:         DS.L      1    /* 0x14: DOS-spezifischer Dateisystemtreiber */

     OFFSET

dir_name:      DS.B     11    /* 0x00: Dateiname                           */
dir_attr:      DS.B      1    /* 0x0b: Attribut                            */
dir_usr1:      DS.W      1    /* 0x0c: zur freien Verwendung               */
dir_usr2:      DS.L      1    /* 0x0e: zur freien Verwendung               */
dir_usr3:      DS.L      1    /* 0x12: zur freien Verwendung               */
dir_time:      DS.W      1    /* 0x16: Zeit  der letzten énderung          */
dir_date:      DS.W      1    /* 0x18: Datum der letzten énderung          */
dir_stcl:      DS.W      1    /* 0x1a: erster Cluster                      */
dir_flen:      DS.L      1    /* 0x1c: DateilÑnge                          */

     OFFSET

dfs_name:      DS.B      8
dfs_next:      DS.L      1
dfs_init:      DS.L      1
dfs_sync:      DS.L      1
dfs_drv_open:  DS.L      1
dfs_drv_close: DS.L      1
dfs_dfree:     DS.L      1
dfs_sfirst:    DS.L      1
dfs_snext:     DS.L      1
dfs_ext_fd:    DS.L      1
dfs_fcreate:   DS.L      1
dfs_fxattr:    DS.L      1
dfs_dir2index: DS.L      1
dfs_readlink:  DS.L      1
dfs_dir2FD:    DS.L      1
dfs_fdelete:   DS.L      1
dfs_pathconf:  DS.L      1

; unterstÅtzte Dcntl- Modi
DFS_GETINFO    EQU  $1100     /* XFS_DOS: gib Zeiger auf DFS-Kernel */
DFS_INSTDFS    EQU  $1200     /* XFS_DOS: installiere ein DFS */
DEV_M_INSTALL  EQU  $cd00     /* DFS_U */

