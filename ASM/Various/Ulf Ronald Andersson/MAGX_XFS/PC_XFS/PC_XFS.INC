; pc_xfs.inc vom 25.11.1995
;
; Autor:
; Thomas Binder
; (binder@rbg.informatik.th-darmstadt.de)
;
; Zweck:
; Assembler-Includefile mit allen Offsets der eigenen C-Strukturen.
;
; History:
; 05.11.1995: Erstellung
; 25.11.1995: Erg„nzung um Offsets der Devicetreiber-Struktur

	offset

_xfs_name:
	ds.b	8
_xfs_sync:
	ds.l	1
_xfs_pterm:
	ds.l	1
_xfs_garbcoll:
	ds.l	1
_xfs_freeDD:
	ds.l	1
_xfs_drv_open:
	ds.l	1
_xfs_drv_close:
	ds.l	1
_xfs_path2DD:
	ds.l	1
_xfs_sfirst:
	ds.l	1
_xfs_snext:
	ds.l	1
_xfs_fopen:
	ds.l	1
_xfs_fdelete:
	ds.l	1
_xfs_link:
	ds.l	1
_xfs_xattr:
	ds.l	1
_xfs_attrib:
	ds.l	1
_xfs_chown:
	ds.l	1
_xfs_chmod:
	ds.l	1
_xfs_dcreate:
	ds.l	1
_xfs_ddelete:
	ds.l	1
_xfs_DD2name:
	ds.l	1
_xfs_dopendir:
	ds.l	1
_xfs_dreaddir:
	ds.l	1
_xfs_drewinddir:
	ds.l	1
_xfs_dclosedir:
	ds.l	1
_xfs_dpathconf:
	ds.l	1
_xfs_dfree:
	ds.l	1
_xfs_wlabel:
	ds.l	1
_xfs_rlabel:
	ds.l	1
_xfs_symlink:
	ds.l	1
_xfs_readlink:
	ds.l	1
_xfs_dcntl:
	ds.l	1
_xfs_end:

	offset

_dev_close:
	ds.l	1
_dev_read:
	ds.l	1
_dev_write:
	ds.l	1
_dev_stat:
	ds.l	1
_dev_seek:
	ds.l	1
_dev_datime:
	ds.l	1
_dev_ioctl:
	ds.l	1
_dev_getc:
	ds.l	1
_dev_getline:
	ds.l	1
_dev_putc:
	ds.l	1
_dev_end:

; EOF
