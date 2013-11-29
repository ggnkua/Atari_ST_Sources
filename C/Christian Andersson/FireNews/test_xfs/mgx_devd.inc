*
* Includes fÅr MagiC-GerÑtetreiber (fÅr u:\dev)
*

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

dosfd_dmd:      DS.L      1    /* 0x00: Zeiger auf DMD                      */
dosfd_refcnt:   DS.W      1    /* 0x04: Ref.zÑhler fÅrs Schlieûen oder -1   */
dosfd_mode:     DS.W      1    /* 0x06: Open- Modus (0,1,2) und flags       */
dosfd_dev:      DS.L      1    /* 0x08: Zeiger auf MX_DEV                   */
dosfd_ddev:     DS.L      1    /* 0x0c: Zeiger auf MX_DDEV                  */
dosfd_name:     DS.B      11   /* 0x10: DD_FD: Name im internen Format      */
dosfd_attr:     DS.B      1    /* 0x1b: Attribut                            */
dosfd_owner:    DS.L      1    /* 0x1c: DD_FD: Eigner eines FD oder NULL    */
dosfd_parent:   DS.L      1    /* 0x20: Zeiger auf den Parent-DD_FD         */
dosfd_children: DS.L      1    /* 0x24: DD_FD: Liste aller Kinder           */
dosfd_next:     DS.L      1    /* 0x28: Zeiger auf FDs im selben Verzeichn. */
dosfd_multi:    DS.L      1    /* 0x2c: Zeiger auf FD derselben Datei       */
dosfd_multi1:   DS.L      1    /* 0x30: Zeiger auf erstes Listenelement     */
dosfd_fpos:     DS.L      1    /* 0x34: Position des Dateizeigers           */
dosfd_dirch:    DS.B      1    /* 0x38: Bit0: "dirty"                       */
dosfd_unused:   DS.B      1    /* 0x39: */
dosfd_time:     DS.W      1    /* 0x3a: Zeit  (8086)                        */
dosfd_date:     DS.W      1    /* 0x3c: Datum (8086)                        */
dosfd_stcl:     DS.W      1    /* 0x3e: Start- Cluster                      */
dosfd_len:      DS.L      1    /* 0x40: DateilÑnge in Bytes                 */
dosfd_dirpos:   DS.L      1    /* 0x44: Pos. des zug. Eintrags im Directory */
dosfd_user1:    DS.L      1    /* 0x48: */
dosfd_user2:    DS.L      1    /* 0x4c: */

	TEXT