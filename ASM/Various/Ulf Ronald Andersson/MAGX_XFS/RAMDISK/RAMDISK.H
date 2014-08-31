/*
 * ramdisk.h vom 23.06.1996
 *
 * Autor:
 * Thomas Binder
 * (binder@rbg.informatik.th-darmstadt.de)
 *
 * Zweck:
 * Enth„lt die Strukturdefinitionen zum Ramdisk-Filesystem fr
 * MagiC 3.
 *
 * History:
 * 05.11.-
 * 25.11.1995: Erstellung (mit Unterbrechungen)
 * 04.12.1995: DEFAULTFILE verdoppelt und DEFAULTDIR abh„ngig von
 *             DEFAULTFILE gemacht.
 * 05.12.1995: Neue Struktur FILEBLOCK.
 * 27.12.1995: Dcntl aufgenommen und erste Vorbereitungen fr
 *             Konfigurierbarkeit von Ramverbrauch und -typ
 *             getroffen.
 * 28.12.1995: FSTAT, FIONREAD, FIONWRITE und FUTIME aufgenommen.
 * 29.12.1995: In RAMDISK_DHD dhd_dir durch dhd_dd ersetzt, ebenso
 *             dta_dir durch dta_dd in RAMDISK_DTA (zwecks Verwaltung
 *             von atime/adate).
 * 30.12.1995: Die Žnderungen von gestern gerade wieder retour... War
 *             wohl irgendwie zu sp„t, als ich das gemacht habe ;)
 *             #include "proto.h" eingesetzt.
 * 31.12.1995: #include "version.h" eingesetzt.
 *             Neues Element fd_is_parent in RAMDISK_FD-Struktur.
 * 23.04.1996: Anpassung an neue Dateistruktur.
 * 23.06.1996: Pdomain ist kein Makro mehr, wegen Anpassung an neuere
 *             Kernelstrukturen durch Funktionspointer ersetzt.
 *             Kfree zeigt jetzt auf _Mfree, nicht mehr auf Mfree.
 */

#ifndef _RAMDISK_H
#define _RAMDISK_H

#include "..\pc_xfs\pc_xfs.h"

#define MAX_FD			200
#define MAX_DHD			100
#define ROOTSIZE		100
#define DEFAULTFILE		4096
#define DEFAULTDIR		(DEFAULTFILE / sizeof(DIRENTRY))
#define ROOT			0
#define ROOT_DE			(DIRENTRY *)1L
#define LEAVE_FREE		(512L * 1024L)
#define RAM_TYPE		3

#define is_file(x)		((x & S_IFMT) == S_IFREG)
#define is_dir(x)		((x & S_IFMT) == S_IFDIR)
#define is_link(x)		((x & S_IFMT) == S_IFLNK)

#define waccess(x)		((x)->de_xattr.mode & S_IWUSR)
#define raccess(x)		((x)->de_xattr.mode & S_IRUSR)
#define xaccess(x)		((x)->de_xattr.mode & S_IXUSR)

#define parentfd(x)		((x)->fd_parent->fd_file)

#define Kfree(x)		_Mfree(x)
#define Dcntl(x, y, z)	gemdos(0x130, (WORD)(x), (char *)(y),\
	(LONG)(z))

#undef FA_RDONLY
#undef FA_HIDDEN
#undef FA_SYSTEM
#undef FA_LABEL
#undef FA_DIR
#undef FA_CHANGED
#undef FA_SYMLINK
#define FA_RDONLY		0x01#define FA_HIDDEN		0x02#define FA_SYSTEM		0x04#define FA_LABEL		0x08#define FA_DIR			0x10#define FA_CHANGED		0x20
#define FA_SYMLINK		0x40
#undef FSTAT
#undef FIONREAD
#undef FIONWRITE
#undef FUTIME
#define FSTAT		0x4600
#define FIONREAD	0x4601
#define FIONWRITE	0x4602
#define FUTIME		0x4603

typedef struct
{
	char	de_fname[34];
	char	*de_faddr;
	WORD	de_nr;
	WORD	de_maxnr;
	XATTR	de_xattr;
	char	de_dummy[128 - sizeof(XATTR) - 42];
} DIRENTRY;

typedef struct ram_fd
{
	DMD				*fd_dmd;
	WORD			fd_refcnt;
	WORD			fd_mode;
	THE_MGX_DEV		*fd_dev;
	LONG			fd_fpos;
	DIRENTRY		*fd_file;
	WORD			fd_is_parent;
	struct ram_fd	*fd_parent;
	BASPAG			*fd_owner;
} RAMDISK_FD;

typedef struct
{
	DMD			*dhd_dmd;
	DIRENTRY	*dhd_dir;
	WORD		dhd_pos;
	WORD		dhd_tosmode;
	BASPAG		*dhd_owner;
} RAMDISK_DHD;

typedef struct
{
	DIRENTRY	*dta_dir;
	WORD		dta_pos;
	char		dta_mask[13];
	char		dta_attr;
	char		dta_drive;
	char		dta_attribute;
	WORD		dta_time;
	WORD		dta_date;
	LONG		dta_len;
	char		dta_name[14];
} RAMDISK_DTA;

typedef struct fblk
{
	char		data[DEFAULTFILE];
	struct fblk	*next;
} FILEBLOCK;

#include "proto.h"
#include "version.h"

#endif /* _RAMDISK_H */

/* EOF */
