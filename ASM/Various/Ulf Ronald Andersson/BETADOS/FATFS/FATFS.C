/*
 * This file belongs to FreeMiNT. It's not in the original MiNT 1.12
 * distribution. See the file CHANGES for a detailed log of changes.
 * 
 * 
 * Copyright 1998, 1999, 2000 Frank Naumann <fnaumann@freemint.de>
 * All rights reserved.
 * 
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 * 
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 * 
 * 
 * begin:	1998-02-01
 * last change:	2000-01-06
 * 
 * Author: Frank Naumann <fnaumann@freemint.de>
 * 
 * please send suggestions, patches or bug reports to me or
 * the MiNT mailing list
 * 
 * 
 * changes since last version:
 * 
 * 2000-04-28:	(v1.20)
 * 
 * - new: is_short declared static as is at least two times used
 * 
 * Gryf:
 * - fix: Calculation of rdlen now rounds up, as described in the
 *        Microsoft FAT whitepaper
 * - fix: fatfs_root() no longer forces a media change on drive A when
 *        drive B gets accessed (and vice versa), but instead only syncs
 *        the buffer cache - this fixes crashes when both drive letters
 *        are accessed like this: A-B-A or B-A-B
 * - fix: Fixed wrong order of arguments in a macro call in
 *        fatfs_rename(), causing write accesses to wrong sectors
 * 
 * 2000-01-10:	(v1.19)
 * 
 * - fix: 0x05 as first byte in _DIR is handled as 0xe5
 *        (see Microsoft White Paper)
 * - new: always initialize ctime, cdate, adate in make_cookie
 * 
 * Gryf:
 * - fix: correct '..' STCL on FAT32 in fatfs_mkdir
 * - fix: correct dirread(TOS_SEARCH) for the case the buffer is to small
 *        so nextdir failed and returned EBADARG to fsfirst/fsnext
 * 
 * 2000-01-06:	(v1.18)
 * 
 * - fix: corrected wrong return code ENAMETOOLONG to EBADARG
 * - new: restructurized FAT access a little bit in a more logical way;
 *        cleaned up
 * - fix: finally fixed fat32 access optimization
 * - fix: possible cache inconsistency in fatfs_rename
 *        missing remove of subdirentries on a directory rename
 * 
 * 1999-11-23:
 * 
 * - fix: debug output in get_bpb now as unsigend and not signed
 * 
 * 1999-10-28:	(v1.17)
 * 
 * - fix: missing time/date initialization for the ROOT cookie
 *        in get_devinfo
 * 
 * 1999-07-18:	(v1.16)
 * 
 * - fix: bug in fat_truncate: searched with wrong string ptr
 * - fix: some optimizations and corrections in cookie lock behaviour
 * - fix: bug in rmdir again: cookie release now hopefully always correct
 * 
 * 1999-06-20:	(v1.15)
 * 
 * - new: chown return always E_OK (temporary compatibility reason)
 * - fix: bug in device driver, flen is a global attribute
 * - fix: bug in rmdir, missing cookie release in error condition
 * - fix: bug in rename, wrong return value for cross device rename
 * - fix: bug in rename, '..' entry was not updated on a directory move
 * 
 * 1999-05-06:	(v1.14)
 * 
 * - fix: bug in symlink, if file already exist was not checked
 * 
 * 1999-04-24:	(v1.13)
 * 
 * - fix: ffree32 doesn't count correctly
 * - fix: bug in bio_fat_l_read
 *        blocks are absolut number -> offsett correction
 * 
 * 1999-04-09:	(v1.12)
 * 
 * - new: added read only check to all 'write' functions
 *        added read only flag, soft/hard, configurable
 * 
 * 1999-03-27:	(v1.11)
 * 
 * - new: bio access is mapped through special support routines
 *        divided into bootsector-, fat- and data access with
 *        optional verification
 *        (cost runtime but increase failure tolerance)
 * - new: 'fend' member in DEVINFO for the last fat sector
 * - new: the root cookie is now part of DEVINFO struct and no longer
 *        seperatly allocated (save one kmalloc for every drive)
 * 
 * 1999-03-13:	(v1.10)
 * 
 * - new: optional LRU cookie cache
 * - new: hash table efficiency statistic
 * - fix: typo in newcl16/32
 * - fix: typo in MS-DOS character table
 * 
 * 1999-03-06:	(v1.09)
 * 
 * Gryf:
 * - new: high speed ffree32 (need temporary much memory)
 * - fix: added 0xc and 0xe DOS partition types
 * - fix: optimised expressions in ffree16/32 (recalc max if overflow)
 * 
 * - new: declared some functions that are used only once as inline
 *        -> save some static functions
 * - new: more checks in val_bpb
 * - fix: upd_fat32info only updates if neccessary
 * - new: complete FAT32 info sector support
 *        changed some things related to this; info sector is resident
 *        loaded with new buffer cache feature and fatfs_sync() periodically
 *        update the info sector now
 * - fix: bug in __nextdir: invalid entrys are accepted as valid
 * 
 * 1999-02-25:	(v1.08)
 * 
 * - fix: bug in fatfs_lookup (..); forgot to copy last byte
 * 
 * 1999-02-14:	(v1.07)
 * 
 * - fix: bug in rename (rename '.' or '..' in root dir)
 * - fix: FAT32 info sector data start at offset 480 and not 0
 * 
 * Draco:
 * - new: better is_exec(); enabled by default
 * 
 * 1999-01-29:	(v1.06)
 * 
 * - fix: fatfs_root return now better values (EBUSY, EMEDIUMTYPE, ENOMEM, ENXIO)
 * 
 * Thomas Binder (gryf):
 * - fix: dirread -> never lowercase on TOS_SEARCH
 * - fix: old gas syntax for WPEEK/WPOKE_INTEL inline assembler
 * 
 * 1999-01-10:	(v1.05)
 * 
 * - fix: fatfs_rename: lastlookup not freed after table manipulating
 * - fix: search_cookie: better failure behaviour
 * - add: unimplemented '..' search in fatfs_lookup
 * 
 * 1998-12-22:	(v1.04)
 * 
 * - add: __FIO -> fix for READ calls with negative bytecount
 *        -> read the complete file to buf
 * - add: dynamic memory usage statistic in DEBUG mode
 * - fix: bug in rename - inode cache not correct after
 *        a position save renaming, also forgot to decrease old->links
 * 
 * 1998-12-11:	(v1.03)
 * 
 * - add: extended debug information in get_bpb (sector dump)
 * - new: writelabel/readlabel rewritten
 * - new: WPOKE_INTEL/WPEEK_INTEL replaced with inline assembler
 * - new: EXTENSIVE_GETXATTR keyword for best getxattr data
 *        (cost runtime, disabled by default)
 * - new: added a position save renaming for non VFAT names
 * - new: replaced ROBUST keyword by check for drive A/B
 *        -> write through sync on non critical operations only on A/B
 * - new: added _cdecl keyword for interface functions
 * 
 * 1998-11-15:	(v1.02)
 * 
 * - fix: bug in FAT12 handling routines
 *        (getcl12 & fixcl12)
 * 
 * 1998-11-01:	(v1.01)
 * 
 * - new: ROBUST keyword; perform also write through sync on non
 *        critical operations like chattr, FUTIME, datime
 * - add: Dpathconf (DP_VOLNAMEMAX)
 * - add: getxattr better nblock value for directories
 * - new: some internal cleanup
 * - new: uid/gid/mode for the root cookie
 *   -> getxattr/chown/chmode
 * 
 * 1998-10-12:
 * 
 * - add: Dcntl (FS_USAGE)
 * - fix: fatfs_fscntl incorrect return values
 * 
 * 1998-09-25:	(v1.00)
 * 
 * - add: lcase flag to force a strlwr operation on real 8+3 names
 *        -> make_shortname/fatfs_readdir/fatfs_config modified
 * - fix: some modifications to reduce overkill syncing for small
 *        fatfs_write calls in writethrough mode
 * - fix: bug in lseek (SEEK_END)
 *        negative offsets are allowed, the compendium is wrong
 * 
 * 1998-09-09:
 * 
 * - fix: bug in symlink (idiotic implementation from MagiC)
 * - some name changes related to block_IO restructurization
 * - add: val_bpb - check the xpbp
 * - fix: delete_cookie: missing check for 'cookie->links'
 * - fix: missing increment/decrement for 'cookie->links' in open/close
 * 
 * 1998-08-06:	(v0.99)
 * 
 * - new: free cluster counter for every drive (speedup dfree)
 *        -> changed dfree?? to ffree?? (fat free)
 *        -> modified nextcl (decrease freecl counter)
 *        -> modified del_chain (increase freecl counter)
 * 
 * Rainer Seitel:
 * - change: replace t_getdate()/t_gettime() by datestamp/timestamp
 * - fix: getcl12 and fixcl12 unaligned word access (68000)
 * 
 * - fix: FAT syncing if mirroring is enabled
 * - fix: missing breaks in Dcntl (FS_INFO)
 * - fix: some missing const in function declaration
 * - change: all drv variables are now of type ushort (before long)
 * - change: better hash function
 * - new: get_bpb - remove completly use of getbpb()
 *        all boot sectors are handled bye the xfs itself now
 * - fix: get_devinfo - better start lastalloc
 * - fix: newcl32 - little bug in overflow calculation
 * - fix: fixcl32 - bug in updating more than 2 FATs
 * 
 * 1998-07-23:	(v0.98)
 * 
 * - change: dskchng now support new method
 * - new: start alloc of clusters on FAT32 at cluster 16
 *        (avoid fragmentation of the root dir)
 * - fix: get_bpb: FAT32 calculation was not correct
 * 
 * Rainer Seitel:
 * - fix: readlabel/writelabel (detection of a label)
 * - fix: getxattr: ctime was incorrect set
 * - fix: chmode: directories can now be hidden
 * - fix: dpathconf (DP_XATTRFIELDS) now doesn't return DP_RDEV flag
 * - fix: functions return now konsequent E_OK 
 * 
 * - add: a little fix for A/B cache consistence
 * - add: Dcntl opcode 'FS_INFO' (experimental!)
 * 
 * 1998-07-13:	(v0.97)
 * 
 * - new: remove sync buffercache (now global in s_ync)
 * - new: writelabel create label if it doesn't exist
 * - fix: is_short -> double points are not detected
 * 
 * 1998-07-08:	(v0.96)
 * 
 * - new: some opcodes
 * - change: Dcntl opcodes
 * - fix: correct dostrunc on FAT
 * - fix: getcl32/fixcl32/nextcl32 - highest 4 bits are reserved
 * - new: DOS media detection (include FAT32)
 *        (own getbpb)
 * - change: adaption for new block low level I/O
 * - change: adaption for new buffer cache
 * 
 * 1998-07-01:	(v0.95)
 *
 * - fix: little bug in getxattr (CLUSTSIZE and not CLSIZE)
 * 
 * - fix: little bug in nextcl16/32 (last free clusters are not found)
 * - fix: bug in lseek
 * - new: __updatedir to mark the actual dir entry as modified
 * - change: new strategie for extend directorys
 * - new: some Dcntl's
 * - new: ISO, GEMDOS and MSDOS name modus
 *   configurable for every drive
 * 
 * - fix: update of FA_CHANGED and mdate/mtime correct
 * - add: FTRUNCATE on fatfs_ioctl (not tested)
 * - add: FUTIME on fatfs_ioctl (not tested)
 * - change: FIONREAD -> read direct the values
 * - change: pathconf (korrekt return DP_CASEINS, DP_NOTRUNC)
 * - fix: make_shortname (every long VFAT entry get a ~)
 * - fix: make_shortname (now up to 6 digits for the number after ~)
 * - fix: fatfs_close (archivbit is not set on symlinks now)
 * - fix: rename (check for existing file now)
 * 
 * - change: replace makros by inline functions
 *   (better typecheck and automatic cast)
 * - change: dir2str, str2dir (reduce a variable, more logical parameter)
 * 
 * - new: optimized search_cookie -> really speed improvement
 * - new: is_short (determine a FAT or VFAT entry)
 *   --> change: make_shortname (faster)
 *   --> change: fatfs_lookup (faster)
 * - new: faster SWAP68_W and SWAP68_L (GCC inline assembler)
 * - new: complete file name trunc (make_shortname)
 * - new: symlink is configurable for every drive
 *   --> change: fatfs_symlink, fatfs_pathconf
 * 
 * 
 * known bugs:
 * 
 * - dskchng() doesn't free the dynamically used memory for the drive
 *   (LOCKS & FILE structs) if open files are on an invalidated medium
 * 
 * todo:
 * 
 * - fall back mechanism in fat_trunc?
 * - real file locking
 * - writelabel/readlabel -> update bootsector label on DOS 4.0 mediums
 * - MSDOS boot sector info stuff (extended information)
 * 
 * optimizations to do:
 * 
 * - __FIO -> L_BS, linear algorithm?
 * - make_cookie -> intelligent search with history
 * - what about auto correction and fall back mechanism?
 */

# include "fatfs.h"
# include "global.h"

# include "libkern/libkern.h"
# include "mint/endian.h"

# include "block_IO.h"
# include "dev-null.h"
# include "filesys.h"
# include "init.h"
# include "kmemory.h"
# include "nullfs.h"
# include "proc.h"
# include "unicode.h"


/*
 * internal version
 */

# define FATFS_MAJOR	1
# define FATFS_MINOR	20
# define FATFS_STATUS	

# if FATFS_MINOR > 9
# define str_FATFS_MINOR	str (FATFS_MINOR)
# else
# define str_FATFS_MINOR	"0" str (FATFS_MINOR)
# endif

# define FATFS_VERSION	str (FATFS_MAJOR) "." str_FATFS_MINOR str (FATFS_STATUS) 
# define FATFS_DATE	__DATE__

# define FATFS_BOOT	\
	"\033pFAT/VFAT/FAT32 filesystem version " FATFS_VERSION "\r\n"

# define FATFS_GREET	\
	"\033qΩ " FATFS_DATE " by Frank Naumann.\r\n\r\n"


/*
 * compile time configurable options
 */

# define FATFS_SECURE_0						\
	  (S_IRUSR | S_IWUSR | S_IXUSR)				\
	| (S_IRGRP | S_IWGRP | S_IXGRP)				\
	| (S_IROTH | S_IWOTH | S_IXOTH)		/* -rwxrwxrwx */

# define FATFS_SECURE_1						\
	  (S_IRUSR | S_IWUSR | S_IXUSR)				\
	| (S_IRGRP | S_IWGRP | S_IXGRP)		/* -rwxrwx--- */

# define FATFS_SECURE_2						\
	  (S_IRUSR | S_IWUSR | S_IXUSR)		/* -rwx------ */

# if 1
# define FATFS_DEFAULT_MODE	FATFS_SECURE_0
# else
# define FATFS_DEFAULT_MODE	FATFS_SECURE_1
# endif

# if 0
# define EXTENSIVE_GETXATTR
# endif

# if 1
# define FAST_FFREE32
# endif

# if 0
# define LRU_COOKIE_CACHE
# endif

# if 1

# if 1
# define FATFS_ACESS_CHECK_BOOT
# endif

# if 1
# define FATFS_ACESS_CHECK_FAT
# endif

# if 1
# define FATFS_ACESS_CHECK_DATA
# endif

# endif

/*
 * debugging stuff
 */

# if 1
# ifdef DEBUG_INFO
# define FS_DEBUG		1
# define FS_DEBUG_COOKIE	0
# define FS_LOGFILE		"u:\\ram\\fat.log"
# define FS_DUMPFILE		"u:\\ram\\fshashtab.dmp"
# endif
# endif

/****************************************************************************/
/* BEGIN tools */

# define COOKIE_EQUAL(c1, c2) \
	(((c1)->index == (c2)->index) && ((c1)->dev == (c2)->dev))


# ifdef DEBUG_INFO

/* memory statistic in debug mode
 */

static ulong fatfs_dynamic_mem = 0;

INLINE void *
fatfs_kmalloc (long size)
{
	register ulong *place;
	
	size += sizeof (*place);
	place = kmalloc (size);
	
	if (place)
	{
		*place++ = size;
		fatfs_dynamic_mem += size;
	}
	
	return place;
}

INLINE void
fatfs_kfree (void *ptr)
{
	register ulong *place = ptr;
	
	place--;
	fatfs_dynamic_mem -= *place;
	
	kfree (place);
}

# undef kmalloc
# undef kfree

# define kmalloc	fatfs_kmalloc
# define kfree		fatfs_kfree

# endif


/*
 * wp???_intel(): read/write 16 bit byte swapped from/to odd addresses.
 */

INLINE ushort
WPEEK_INTEL (register uchar *ptr)
{
	register ushort c1 = *ptr++;
	register ushort c2 = *ptr;
	
	return ((c2 << 8) | (c1 & 0x00ff));
}

INLINE void
WPOKE_INTEL (register uchar *ptr, register ushort value)
{
	*ptr++ = (uchar) (value & 0x00ff);
	*ptr = value >> 8;
}

/* END tools */
/****************************************************************************/

/****************************************************************************/
/* BEGIN definition part */

/*
 * filesystem
 */

static long	_cdecl fatfs_root	(int drv, fcookie *fc);

static long	_cdecl fatfs_lookup	(fcookie *dir, const char *name, fcookie *fc);
static DEVDRV *	_cdecl fatfs_getdev	(fcookie *fc, long *devsp);
static long	_cdecl fatfs_getxattr	(fcookie *fc, XATTR *xattr);

static long	_cdecl fatfs_chattr	(fcookie *fc, int attrib);
static long	_cdecl fatfs_chown	(fcookie *fc, int uid, int gid);
static long	_cdecl fatfs_chmode	(fcookie *fc, unsigned mode);

static long	_cdecl fatfs_mkdir	(fcookie *dir, const char *name, unsigned mode);
static long	_cdecl fatfs_rmdir	(fcookie *dir, const char *name);
static long	_cdecl fatfs_creat	(fcookie *dir, const char *name, unsigned mode, int attrib, fcookie *fc);
static long	_cdecl fatfs_remove	(fcookie *dir, const char *name);
static long	_cdecl fatfs_getname	(fcookie *root, fcookie *dir, char *pathname, int size);
static long	_cdecl fatfs_rename	(fcookie *olddir, char *oldname, fcookie *newdir, const char *newname);

static long	_cdecl fatfs_opendir	(DIR *dirh, int flags);
static long	_cdecl fatfs_readdir	(DIR *dirh, char *nm, int nmlen, fcookie *);
static long	_cdecl fatfs_rewinddir	(DIR *dirh);
static long	_cdecl fatfs_closedir	(DIR *dirh);

static long	_cdecl fatfs_pathconf	(fcookie *dir, int which);
static long	_cdecl fatfs_dfree	(fcookie *dir, long *buf);
static long	_cdecl fatfs_writelabel	(fcookie *dir, const char *name);
static long	_cdecl fatfs_readlabel	(fcookie *dir, char *name, int namelen);

static long	_cdecl fatfs_symlink	(fcookie *dir, const char *name, const char *to);
static long	_cdecl fatfs_readlink	(fcookie *file, char *buf, int len);
static long	_cdecl fatfs_fscntl	(fcookie *dir, const char *name, int cmd, long arg);
static long	_cdecl fatfs_dskchng	(int drv, int mode);

static long	_cdecl fatfs_release	(fcookie *fc);
static long	_cdecl fatfs_dupcookie	(fcookie *dst, fcookie *src);
static long	_cdecl fatfs_sync	(void);
static long	_cdecl fatfs_unmount	(int drv);


FILESYS fatfs_filesys =
{
	NULL,
	
	/*
	 * FS_KNOPARSE		kernel shouldn't do parsing
	 * FS_CASESENSITIVE	file names are case sensitive
	 * FS_NOXBIT		if a file can be read, it can be executed
	 * FS_LONGPATH		file system understands "size" argument to "getname"
	 * FS_NO_C_CACHE	don't cache cookies for this filesystem
	 * FS_DO_SYNC		file system has a sync function
	 * FS_OWN_MEDIACHANGE	filesystem control self media change (dskchng)
	 * FS_REENTRANT_L1	fs is level 1 reentrant
	 * FS_REENTRANT_L2	fs is level 2 reentrant
	 * FS_EXT_1		extensions level 1 - mknod & unmount
	 * FS_EXT_2		extensions level 2 - additional place at the end
	 * FS_EXT_3		extensions level 3 - stat & native UTC timestamps
	 */
	FS_CASESENSITIVE	|
	FS_NOXBIT		|
	FS_LONGPATH		|
	FS_NO_C_CACHE		|
	FS_DO_SYNC		|
	FS_OWN_MEDIACHANGE	|
	FS_EXT_1		|
	FS_EXT_2		,
	
	fatfs_root,
	fatfs_lookup, fatfs_creat, fatfs_getdev, fatfs_getxattr,
	fatfs_chattr, fatfs_chown, fatfs_chmode,
	fatfs_mkdir, fatfs_rmdir, fatfs_remove, fatfs_getname, fatfs_rename,
	fatfs_opendir, fatfs_readdir, fatfs_rewinddir, fatfs_closedir,
	fatfs_pathconf, fatfs_dfree, fatfs_writelabel, fatfs_readlabel,
	fatfs_symlink, fatfs_readlink, null_hardlink, fatfs_fscntl, fatfs_dskchng,
	fatfs_release, fatfs_dupcookie,
	fatfs_sync,
	
	/* FS_EXT_1 */
	null_mknod, fatfs_unmount,
	
	/* FS_EXT_2
	 */
	
	/* FS_EXT_3 */
	NULL,
	
	0, 0, 0, 0, 0,
	NULL, NULL
};

/*
 * device driver
 */

static long	_cdecl fatfs_open	(FILEPTR *f);
static long	_cdecl fatfs_write	(FILEPTR *f, const char *buf, long bytes);
static long	_cdecl fatfs_read	(FILEPTR *f, char *buf, long bytes);
static long	_cdecl fatfs_lseek	(FILEPTR *f, long where, int whence);
static long	_cdecl fatfs_ioctl	(FILEPTR *f, int mode, void *buf);
static long	_cdecl fatfs_datime	(FILEPTR *f, ushort *time, int rwflag);
static long	_cdecl fatfs_close	(FILEPTR *f, int pid);

DEVDRV fatfs_device =
{
	fatfs_open,
	fatfs_write, fatfs_read, fatfs_lseek,
	fatfs_ioctl, fatfs_datime,
	fatfs_close,
	null_select, null_unselect,
	NULL, NULL
};


/*
 * internal global data definitions
 */

/* FAT boot sector */
typedef struct
{
	uchar	boot_jump[3];	/* Boot strap short or near jump */
	char	system_id[8];	/* Name - can be used to special case partition manager volumes */
	
	uchar	sector_size[2];	/* bytes per logical sector */
	uchar	cluster_size;	/* sectors/cluster */
	ushort	reserved;	/* reserved sectors */
	uchar	fats;		/* number of FATs */
	uchar	dir_entries[2];	/* root directory entries */
	uchar	sectors[2];	/* number of sectors */
	uchar	media;		/* media code (unused) */
	ushort	fat_length;	/* sectors/FAT */
	ushort	secs_track;	/* sectors per track */
	ushort	heads;		/* number of heads */
	ulong	hidden;		/* hidden sectors (unused) */
	ulong	total_sect;	/* number of sectors (if sectors == 0) */
	
} _F_BS;

/* FAT volume info */
typedef struct
{
	uchar	drive_number;	/* BIOS drive number */
	uchar	RESERVED;	/* Unused */
	uchar	ext_boot_sign;	/* 0x29 if fields below exist (DOS 3.3+) */
	
# define EXT_INFO		0x29
	
	uchar	vol_id[4];	/* Volume ID number */
	char	vol_label[11];	/* Volume label */
	char	fs_type[8];	/* Typically FAT12, FAT16, or FAT32 */
	
} _F_VI;

/* FAT32 boot sector */
typedef struct
{
	_F_BS	fbs;		/* normal FAT boot sector */
	
	ulong	fat32_length;	/* sectors/FAT */
	ushort	flags;		/* bit 8: fat mirroring, low 4: active fat */
	
# define FAT32_ActiveFAT_Mask	0x0f
# define FAT32_NoFAT_Mirror	0x80
	
	ushort	version;	/* major, minor filesystem version */
	ulong	root_cluster;	/* first cluster in root directory */
	ushort	info_sector;	/* filesystem info sector */
	ushort	backup_boot;	/* backup boot sector */
	
# define INVALID_SECTOR		0xffff
	
	ushort	RESERVED2[6];	/* Unused */
	
} _F32_BS;

/* FAT32 boot fsinfo */
typedef struct
{
	ulong	reserved1;	/* Nothing as far as I can tell */
	ulong	signature;	/* 0x61417272L */
	
# define FAT32_FSINFOSIG	0x61417272L
	
	ulong	free_clusters;	/* Free cluster count.  -1 if unknown */
	ulong	next_cluster;	/* Most recently allocated cluster. Unused under Linux. */
	ulong	reserved2[4];
	
# define _FAT32_BFSINFO_OFF	480 /* offset from the beginning */
	
} _FAT32_BFSINFO;

/* fat entry structure */
typedef struct
{
	char	name[11];	/* short name */
	char	attr;		/* file attribut */
	uchar	lcase;		/* used by Windows NT and Linux */
	uchar	ctime_ms;	/* creation time milliseconds */
	ushort	ctime;		/* creation time */
	ushort	cdate;		/* creation date */
	ushort	adate;		/* last access date */
	ushort	stcl_fat32;	/* the 12 upper bits for the stcl */
	ushort	time;		/* last modification time */
	ushort	date;		/* last modification date */
	ushort	stcl;		/* start cluster */
	ulong	flen;		/* file len */
	
} _DIR; /* 32 byte */

/* vfat entry structure */
typedef struct
{
	uchar	head;		/* bit 0..4: number of slot, bit 6: endofname */
	uchar	name0_4[10];	/* 5 unicode character */
	char	attr;		/* attribut (0x0f) */
	uchar	unused;		/* not used, reserved, (= 0) */
	uchar	chksum;		/* checksum short name */
	uchar	name5_10[12];	/* 6 unicode character */
	ushort	stcl;		/* start cluster (must be 0) */
	uchar	name11_12[4];	/* 2 unicode character */
	
} LDIR; /* 32 byte */


/*
 * file attributes
 */

# define FA_RDONLY	0x01	/* write protected */
# define FA_HIDDEN	0x02	/* hidden */
# define FA_SYSTEM	0x04	/* system */
# define FA_LABEL	0x08	/* label */
# define FA_DIR		0x10	/* subdirectory */
# define FA_CHANGED	0x20	/* archiv bit */
# define FA_VFAT	0x0f	/* VFAT entry */
# define FA_SYMLINK	0x40	/* symbolic link (MagiC style) */

# define FA_TOSVALID	(FA_RDONLY | FA_HIDDEN | FA_SYSTEM | FA_DIR | FA_CHANGED)
# define FA_VALID	(FA_RDONLY | FA_HIDDEN | FA_SYSTEM | FA_DIR | FA_CHANGED | FA_SYMLINK)


# define FAT_PATHMAX	129	/* include '\0' */
# define FAT_NAMEMAX	13	/* include '.' and '\0' */

/* this informations are from Microsoft */
# define VFAT_PATHMAX	260	/* include '\0' */
# define VFAT_NAMEMAX	256	/* include '\0' */


typedef struct cookie COOKIE;

struct cookie
{
	COOKIE	*next;		/* internal usage */
	char 	*name;		/* full pathname (own alloc) */
	ulong	links;		/* 'in use' counter */
	ulong	stat;		/* access statistic */
	ushort	dev;		/* the device on which is the file */
	ushort	rdev;		/* not used at the moment */
	long	dir;		/* the start cluster of the dir */
	long	offset;		/* the offset in the dir */
	long	stcl;		/* the start cluster */
	ulong	flen;		/* file len */
	_DIR	info;		/* the direntry */
	FILEPTR	*open;		/* linked list of opened file ptr (kernel alloc) */
	LOCK 	*locks;		/* linked list of locks on this file (own alloc) */
	char	*lastlookup;	/* last lookup fail cache, must be kmalloc'ed */
	long	nextslot;	/* next free slot in directories */
	ushort	slots;		/* number of VFAT slots */
	ushort	res;		/* alignment */	
};

/* internal eXtended bpb */
typedef struct
{
	ulong	recsiz;		/* bytes per sector */
	ulong	clsiz;		/* sectors per cluster */
	ulong	clsizb;		/* bytes per cluster */
	
	ulong	numcl;		/* total number of clusters */
	
	ulong	rdrec;		/* root directory rec or stcl if FAT32 */
	ulong	rdlen;		/* root directory size or 0 if FAT32 */
	ulong	datrec;		/* first data sector */
	
	ulong	fsiz;		/* size of a FAT */
	ulong	fatrec;		/* startsector of !*first*! FAT */
	ushort	fats;		/* number of additional FATs (0 = 1 FAT, 1 = 2 FATs, ...) */
	ushort	ftype;		/* type of FAT */
	
/* ftype: */
# define FAT_INVALID	0xffff
# define FAT_TYPE_12	2
# define FAT_TYPE_16	0
# define FAT_TYPE_32	1
	
	/* special for FAT32 */
	ushort	fflag;		/* FAT flag, contain mirror or active FAT status */
	ushort	info;		/* FAT32 info sector, 0 == doesn't exist */
	ushort	version;	/* major/minor version */
	ushort	res;		/* reserved */
	
} _x_BPB;

/* device info structure */
typedef struct
{
	DI	*di;		/* device identifikator for this drive */
	
	ushort	rdonly;		/* rdonly flag */
	ushort	res;		/* reserved */
	
	ulong	recsiz;		/* bytes per sector */
	ulong	clsiz;		/* sectors per cluster */
	ulong	clsizb;		/* bytes per cluster */
	ulong	fstart;		/* FAT start - first sector of FAT area */
	ulong	fend;		/* FAT end - last sector of FAT area */
	ulong	flen;		/* FAT len in sectors */
	ulong	rdstart;	/* root dir start */
	ulong	rdlen;		/* root dir len in sectors  */
	ulong	rdentrys;	/* root dir entry's */
	ulong	dstart;		/* 1st cluster sector number */
	ulong	doffset;	/* clusteroffset */
	ulong	numcl;		/* total number of clusters */
	ulong	maxcl;		/* highest clnumber + 1 */
	ulong	entrys;		/* number of dir entrys in a cluster */
	
	long	(*getcl)(long, const ushort, ulong);
	long	(*fixcl)(long, const ushort, long);
	long	(*newcl)(long, const ushort);
	long	(*ffree)(      const ushort);
	
	COOKIE	root;		/* the root COOKIE for this drive */
	ushort	ftype;		/* the type of the fat */
	ushort	fat2on;		/* is there an active second FAT? */
	long	lastcl;		/* the last allocated cluster */
	long	freecl;		/* free cluster counter, -1 if unknown */
	
	/* FAT32 extensions */
	ushort	fmirroring;	/* status of fat mirroring (flag) */
	ushort	actual_fat;	/* active fat if fat mirroring is disabled */
	UNIT	*info_unit;	/* unit descriptor for the info sector */
_FAT32_BFSINFO	*info;		/* info sector pointer */
	
} DEVINFO;

/* extended open directory descriptor */
typedef struct
{
	ushort	dev;		/* device */
	ushort	rdev;		/* not used at the moment */
	long	stcl;		/* start cluster */
	long	actual;		/* actual cluster (sector number) */
	long	cl;		/* cluster number */
	long	index;		/* logical index */
	long	real_index;	/* index there normal & vfat point */
	UNIT	*u;		/* the locked UNIT */
	_DIR	*info;		/* points to the actual _DIR */
	
} oDIR;

/* extended open file descriptor */
typedef struct
{
	long	mode;		/* the file I/O mode */
	long	actual;		/* actual cluster */
	long	cl;		/* number of the actual cluster */
	long	error;		/* holds the last error */
	
} FILE;


/*
 * internal global functions
 */


/* help functions */

INLINE char *	fullname	(const COOKIE *c, const char *name);
INLINE long	INDEX		(const COOKIE *c);


/* cookie cache access */

INLINE ulong	c_hash_hash	(register const char *s);
INLINE COOKIE *	c_hash_lookup	(register const char *s, register ushort dev);
INLINE void	c_hash_install	(register COOKIE *c);
INLINE void	c_hash_remove	(register COOKIE *c);

static COOKIE *	c_get_cookie	(register char *s);
static void	c_del_cookie	(register COOKIE *c);


/* FAT access functions */

static long	getcl12		(long cluster, const ushort dev, ulong n);
static long	getcl16		(long cluster, const ushort dev, ulong n);
static long	getcl32		(long cluster, const ushort dev, ulong n);

static long	fixcl12		(long cluster, const ushort dev, long next);
static long	fixcl16		(long cluster, const ushort dev, long next);
static long	fixcl32		(long cluster, const ushort dev, long next);

static long	newcl12		(long cluster, const ushort dev);
static long	newcl16		(long cluster, const ushort dev);
static long	newcl32		(long cluster, const ushort dev);

static long	ffree12		(const ushort dev);
static long	ffree16		(const ushort dev);
static long	ffree32		(const ushort dev);


/* FAT utility functions */

static long	nextcl		(register long cluster, register const ushort dev);
static long	del_chain	(long cluster, const ushort dev);


/* DIR help functions */

INLINE void	zero_cl		(register long cl, register const ushort dev);
INLINE void	dir2str		(register const char *src, register char *nm);
INLINE void	str2dir		(register const char *src, register char *nm);
INLINE long	is_exec		(register const char *src);
static int	is_short	(register const char *src, register const char *table);
INLINE long	fat_trunc	(register char *dst, const char *src, register long len, COOKIE *dir);
INLINE long	vfat_trunc	(register char *dst, const char *src, register long len, COOKIE *dir);
static long	make_shortname	(COOKIE *dir, const char *src, char *dst);

/* DIR low lewel access */

INLINE long	__opendir	(register oDIR *dir, register const long cluster, register const ushort dev);
INLINE void	__closedir	(register oDIR *dir);
INLINE void	__updatedir	(register oDIR *dir);
static long	__seekdir	(register oDIR *dir, register long index, ushort mode);
INLINE long	__SEEKDIR	(register oDIR *dir, register long index, ushort mode);
INLINE long	__readvfat	(register oDIR *dir, char *lname, long size);
static long	__nextdir	(register oDIR *dir, char *name, long size);

static long	search_cookie	(COOKIE *dir, COOKIE **found, const char *name, int mode);
static long	write_cookie	(COOKIE *c);
static long	delete_cookie	(COOKIE *c, long mode); /* mode == 0 -> don't delete cluster chain */
static long	make_cookie	(COOKIE *dir, COOKIE **new, const char *name, int attr);


/* device check and initialization */

INLINE long	val_bpb		(_x_BPB *xbpb, ushort drv);
INLINE long	get_bpb		(_x_BPB *xbpb, DI *di);
static DEVINFO *get_devinfo	(const ushort drv, long *err);


/* special FAT32 extension */

INLINE void	upd_fat32fats	(register const ushort dev, long reference);
INLINE void	upd_fat32boot	(register const ushort dev);
INLINE void	val_fat32info	(register const ushort dev);
INLINE void	inv_fat32info	(register const ushort dev);
INLINE void	upd_fat32info	(register const ushort dev);


/* internal device driver functions */

static long	__FUTIME	(COOKIE *c, ushort *ptr);
static long	__FTRUNCATE	(COOKIE *c, long newlen);
static long	__FIO		(FILEPTR *f, char *buf, long bytes, ushort mode);

/* mode values: */
# define	READ		0
# define	WRITE		1


/* debugging functions */

# ifndef FS_DEBUG

#  define FAT_ASSERT(x)		
#  define FAT_FORCE(x)		{ FORCE x; }
#  define FAT_ALERT(x)		{ ALERT x; }
#  define FAT_DEBUG(x)		
#  define FAT_DEBUG_PRINTDIR(x)	
#  define FAT_DEBUG_COOKIE(x)	
#  define FAT_DEBUG_HASH(x)	

#  define FAT_DEBUG_ON
#  define FAT_DEBUG_OFF

# else

#  define FAT_ASSERT(x)		{ assert x; }
#  define FAT_FORCE(x)		{ FORCE x; }
#  define FAT_ALERT(x)		{ ALERT x; }
#  define FAT_DEBUG(x)		{ if (fatfs_debug_mode) { fatfs_debug x; } }
#  define FAT_DEBUG_PRINTDIR(x)	{ fatfs_print_dir x; }
#  define FAT_DEBUG_HASH(x)	{ fatfs_dump_hashtable x; }

#  if FS_DEBUG_COOKIE
#   define FAT_DEBUG_COOKIE(x)	{ fatfs_print_cookie x; }
#  else
#   define FAT_DEBUG_COOKIE(x)
#  endif

#  define FAT_DEBUG_ON	fatfs_config (0, FATFS_DEBUG, ENABLE)
#  define FAT_DEBUG_OFF	fatfs_config (0, FATFS_DEBUG, DISABLE)

   static uchar	fatfs_debug_mode = 0;
   static void	fatfs_debug		(const char *s, ...);
   static void	fatfs_print_dir		(const _DIR *d, ushort dev);
   static void	fatfs_dump_hashtable	(void);
#  if FS_DEBUG_COOKIE
   static void	fatfs_print_cookie	(COOKIE *c);
#  endif

# endif

/* END definition part */
/****************************************************************************/

/****************************************************************************/
/* BEGIN global data definition & access implementation */

/*
 * shortnames are returned in lower case
 * global flag
 */

# define LCASE(dev)	(__lcase_flag)
static ushort __lcase_flag = 1;

/*
 * global device info array
 */

static struct
{
	DEVINFO	*info;		/* device information */
	ushort	valid;		/* validation flag */
	
/* valid: */
# define INVALID		0
# define VALID			1
	
	ushort	__vfat;		/* VFAT configuration */
	ushort	__slnk;		/* symbolic link configuration */
	
	ushort	__new_mode;	/* newname mode configuration */
const	char *	__table;	/* actual character table */
	
	ushort	__uid;		/* root permissions */
	ushort	__gid;
	ushort	__mode;
	
# ifdef FATFS_TESTING
	ushort	__test;		/* test partitions */
# else
	ushort	res;		/* reserved */
# endif
# ifdef FS_DEBUG
	ulong	__c_hit;	/* cookie cache hits */
	ulong	__c_miss;	/* cookie cache miss */
# endif
	
} devinfo [NUM_DRIVES];

/*
 * makros for easy access
 */

# define DEVINFO(dev)	(devinfo[(dev)])

# define BPB(dev)	(DEVINFO (dev).info)
# define BPBVALID(dev)	(DEVINFO (dev).valid)

# define VFAT(dev)	(DEVINFO (dev).__vfat)
# define SLNK(dev)	(DEVINFO (dev).__slnk)
# define NAME_MODE(dev)	(DEVINFO (dev).__new_mode)
# define DEFAULT_T(dev)	(DEVINFO (dev).__table)
# define ROOT_UID(dev)	(DEVINFO (dev).__uid)
# define ROOT_GID(dev)	(DEVINFO (dev).__gid)
# define ROOT_MODE(dev)	(DEVINFO (dev).__mode)

# ifdef FATFS_TESTING
# define TEST_PART(dev)	(DEVINFO (dev).__test)
# endif

# ifdef FS_DEBUG
# define C_HIT(dev)	(DEVINFO (dev).__c_hit)
# define C_MISS(dev)	(DEVINFO (dev).__c_miss)
# endif


# define DI(dev)	(BPB (dev)->di)
# define RCOOKIE(dev)	(&(BPB (dev)->root))

# define RDONLY(dev)	(BPB (dev)->rdonly)

# define SECSIZE(dev)	(BPB (dev)->recsiz)
# define CLUSTSIZE(dev)	(BPB (dev)->clsizb)
# define CLSIZE(dev)	(BPB (dev)->clsiz)
# define CLUSTER(dev)	(BPB (dev)->numcl)
# define MAXCL(dev)	(BPB (dev)->maxcl)
# define ROOT(dev)	(BPB (dev)->rdstart)
# define ROOTSIZE(dev)	(BPB (dev)->rdlen)
# define ROOTENTRYS(dev)(BPB (dev)->rdentrys)
# define CLFIRST(dev)	(BPB (dev)->dstart)
# define DOFFSET(dev)	(BPB (dev)->doffset)
# define FATSTART(dev)	(BPB (dev)->fstart)
# define FATEND(dev)	(BPB (dev)->fend)
# define FATSIZE(dev)	(BPB (dev)->flen)
# define FAT2ON(dev)	(BPB (dev)->fat2on)
# define ENTRYS(dev)	(BPB (dev)->entrys)

# define FAT_TYPE(dev)	(BPB (dev)->ftype)
# define LASTALLOC(dev)	(BPB (dev)->lastcl)
# define FREECL(dev)	(BPB (dev)->freecl)
# define FAT32(dev)	(FAT_TYPE (dev) == FAT_TYPE_32)

/* special for FAT32 */
# define FAT32mirr(dev)	(BPB (dev)->fmirroring)
# define FAT32prim(dev)	(BPB (dev)->actual_fat)
# define FAT32infu(dev)	(BPB (dev)->info_unit)
# define FAT32info(dev)	(BPB (dev)->info)

/* avoid root dir fragmentation */
# define FAT32_ROFF	32


/*
 * low level access
 * the routines verify the correct position
 */

INLINE UNIT *
bio_boot_read (DI *di, ulong sector, ulong blocksize)
{
# ifdef FATFS_ACESS_CHECK_BOOT
	if (sector == 0)
		return bio.read (di, sector, blocksize);
	
	FAT_ALERT (("FATFS [%c]: bio_boot_read acess failure, aborted!", 'A'+di->drv));
	return NULL;
# else
	return bio.read (di, sector, blocksize);
# endif
}


INLINE UNIT *
bio_fat_getunit (const ushort dev, DI *di, ulong sector, ulong blocksize)
{
# ifdef FATFS_ACESS_CHECK_FAT
	if ((sector >= FATSTART (dev)) && (sector <= FATEND (dev)))
		return bio.getunit (di, sector, blocksize);
	
	FAT_ALERT (("FATFS [%c]: bio_fat_getunit: out of range (%ld, %ld - %ld), aborted", 'A'+dev, sector, FATSTART (dev), FATEND (dev)));
	return NULL;
# else
	return bio.getunit (di, sector, blocksize);
# endif
}

INLINE UNIT *
bio_fat_read (const ushort dev, DI *di, ulong sector, ulong blocksize)
{
# ifdef FATFS_ACESS_CHECK_FAT
	if ((sector >= FATSTART (dev)) && (sector <= FATEND (dev)))
		return bio.read (di, sector, blocksize);
	
	FAT_ALERT (("FATFS [%c]: bio_fat_read: out of range (%ld, %ld - %ld), aborted", 'A'+dev, sector, FATSTART (dev), FATEND (dev)));
	return NULL;
# else
	return bio.read (di, sector, blocksize);
# endif
}

INLINE long
bio_fat_l_read (const ushort dev, DI *di, ulong sector, ulong blocks, ulong blocksize, void *buf)
{
# ifdef FATFS_ACESS_CHECK_FAT
	if ((sector >= FATSTART (dev)) && (sector + blocks - 1 <= FATEND (dev)))
		return bio.l_read (di, sector, blocks, blocksize, buf);
	
	FAT_ALERT (("FATFS [%c]: bio_fat_l_read: out of range (%ld+%ld, %ld - %ld), aborted", 'A'+dev, sector, blocks, FATSTART (dev), FATEND (dev)));
	return EREAD;
# else
	return bio.l_read (di, sector, blocks, blocksize, buf);
# endif
}


INLINE UNIT *
bio_data_getunit (const ushort dev, DI *di, ulong sector, ulong blocksize)
{
# ifdef FATFS_ACESS_CHECK_DATA
	if (sector > FATEND (dev))
		return bio.getunit (di, sector, blocksize);
	
	FAT_ALERT (("FATFS [%c]: bio_data_getunit: out of range (%ld, %ld), aborted", 'A'+dev, sector, FATEND (dev)));
	return NULL;
# else
	return bio.getunit (di, sector, blocksize);
# endif
}

INLINE UNIT *
bio_data_read (const ushort dev, DI *di, ulong sector, ulong blocksize)
{
# ifdef FATFS_ACESS_CHECK_DATA
	if (sector > FATEND (dev))
		return bio.read (di, sector, blocksize);
	
	FAT_ALERT (("FATFS [%c]: bio_data_read: out of range (%ld, %ld), aborted", 'A'+dev, sector, FATEND (dev)));
	return NULL;
# else
	return bio.read (di, sector, blocksize);
# endif
}

INLINE long
bio_data_l_read (const ushort dev, DI *di, ulong sector, ulong blocks, ulong blocksize, void *buf)
{
# ifdef FATFS_ACESS_CHECK_DATA
	if (sector > FATEND (dev))
		return bio.l_read (di, sector, blocks, blocksize, buf);
	
	FAT_ALERT (("FATFS [%c]: bio_data_l_read: out of range (%ld, %ld), aborted", 'A'+dev, sector, FATEND (dev)));
	return EREAD;
# else
	return bio.l_read (di, sector, blocks, blocksize, buf);
# endif
}

INLINE long
bio_data_l_write (const ushort dev, DI *di, ulong sector, ulong blocks, ulong blocksize, void *buf)
{
# ifdef FATFS_ACESS_CHECK_DATA
	if (sector > FATEND (dev))
		return bio.l_write (di, sector, blocks, blocksize, buf);
	
	FAT_ALERT (("FATFS [%c]: bio_data_l_write: out of range (%ld, %ld), aborted", 'A'+dev, sector, FATEND (dev)));
	return EWRITE;
# else
	return bio.l_write (di, sector, blocks, blocksize, buf);
# endif
}


/*
 * FAT access help functions
 */

INLINE long
GETCL (register long cluster, register const ushort dev, register long offset)
{
	return (offset > 0) ? (*(BPB (dev)->getcl))(cluster, dev, offset) : cluster;
}

INLINE long
FIXCL (register long cluster, register const ushort dev, register long next)
{
	return (*(BPB (dev)->fixcl))(cluster, dev, next);
}

INLINE long
NEWCL (register long cluster, register const ushort dev)
{
	return (*(BPB (dev)->newcl))(cluster, dev);
}

INLINE long
NEXTCL (register long cluster, register const ushort dev, register const long mode)
{
	return (mode == READ) ? GETCL (cluster, dev, 1) : nextcl (cluster, dev);
}

INLINE long
DFREE (const fcookie *dir, ulong *buf)
{
	const ushort dev = dir->dev;
	
	if (FREECL (dev) < 0)
	{
		FREECL (dev) = (*(BPB (dev)->ffree))(dev);
	}
	
	*buf++ = FREECL (dev);
	*buf++ = CLUSTER (dev);
	*buf++ = SECSIZE (dev);
	*buf   = CLSIZE (dev);
	
	return E_OK;
}


/*
 * help functions
 */

INLINE char *
fullname (const COOKIE *c, const char *name)
{
	register long len = strlen (c->name);
	register char *full = kmalloc (len + strlen (name) + 2);
	if (full)
	{
		(void) strcpy (full, c->name);
		*(full + len) = '\\';
		(void) strcpy (full + len + 1, name);
	}
	else
	{
		FAT_ALERT (("fatfs.c: kmalloc fail in: fullname (%s, %s)", c->name, name));
	}
	
	return full;
}

INLINE long
INDEX (const COOKIE *c)
{
	return
		c->stcl ?	c->stcl
			:	c->dir + (c->offset << 16);
	
	/* "x << 16" equivalent to "x * 32 * 2048" */
}

/*
 * cookie hash table
 */

# define COOKIE_HASHBITS	9
# define COOKIE_CACHE		(1UL << COOKIE_HASHBITS)
# define COOKIE_HASHMASK	(COOKIE_CACHE - 1)

static COOKIE cookies [COOKIE_CACHE];
static COOKIE *ctable [COOKIE_CACHE];

# ifdef FS_DEBUG
# define COOKIE_CACHE_HIT(dev)	{ C_HIT (dev)++; }
# define COOKIE_CACHE_MISS(dev)	{ C_MISS (dev)++; }
# else
# define COOKIE_CACHE_HIT(dev)
# define COOKIE_CACHE_MISS(dev)
# endif

# ifdef LRU_COOKIE_CACHE
INLINE void
c_stat_update (register COOKIE *u)
{
	u->stat = c20ms;
}
# endif

/* ?
 *	prevhash = (prevhash << 4) | (prevhash >> 28);
 *	return prevhash ^ TOUPPER (c);
 */

# if 1
INLINE ulong
c_hash_hash (register const char *s)
{
	register ulong hash = 0;
	
	while (*s)
	{
		hash = ((hash << 5) - hash) + TOUPPER (*s);
		s++;
	}
	
	hash ^= (hash >> COOKIE_HASHBITS) ^ (hash >> (COOKIE_HASHBITS << 1));
	
	return hash & COOKIE_HASHMASK;
}
# else
static ushort crcTable [] = /* 16 12 5 0 */
{
	0x0000, 0x1189, 0x2312, 0x329b, 0x4624, 0x57ad, 0x6536, 0x74bf,
	0x8c48, 0x9dc1, 0xaf5a, 0xbed3, 0xca6c, 0xdbe5, 0xe97e, 0xf8f7,
	0x1081, 0x0108, 0x3393, 0x221a, 0x56a5, 0x472c, 0x75b7, 0x643e,
	0x9cc9, 0x8d40, 0xbfdb, 0xae52, 0xdaed, 0xcb64, 0xf9ff, 0xe876,
	0x2102, 0x308b, 0x0210, 0x1399, 0x6726, 0x76af, 0x4434, 0x55bd,
	0xad4a, 0xbcc3, 0x8e58, 0x9fd1, 0xeb6e, 0xfae7, 0xc87c, 0xd9f5,
	0x3183, 0x200a, 0x1291, 0x0318, 0x77a7, 0x662e, 0x54b5, 0x453c,
	0xbdcb, 0xac42, 0x9ed9, 0x8f50, 0xfbef, 0xea66, 0xd8fd, 0xc974,
	0x4204, 0x538d, 0x6116, 0x709f, 0x0420, 0x15a9, 0x2732, 0x36bb,
	0xce4c, 0xdfc5, 0xed5e, 0xfcd7, 0x8868, 0x99e1, 0xab7a, 0xbaf3,
	0x5285, 0x430c, 0x7197, 0x601e, 0x14a1, 0x0528, 0x37b3, 0x263a,
	0xdecd, 0xcf44, 0xfddf, 0xec56, 0x98e9, 0x8960, 0xbbfb, 0xaa72,
	0x6306, 0x728f, 0x4014, 0x519d, 0x2522, 0x34ab, 0x0630, 0x17b9,
	0xef4e, 0xfec7, 0xcc5c, 0xddd5, 0xa96a, 0xb8e3, 0x8a78, 0x9bf1,
	0x7387, 0x620e, 0x5095, 0x411c, 0x35a3, 0x242a, 0x16b1, 0x0738,
	0xffcf, 0xee46, 0xdcdd, 0xcd54, 0xb9eb, 0xa862, 0x9af9, 0x8b70,
	0x8408, 0x9581, 0xa71a, 0xb693, 0xc22c, 0xd3a5, 0xe13e, 0xf0b7,
	0x0840, 0x19c9, 0x2b52, 0x3adb, 0x4e64, 0x5fed, 0x6d76, 0x7cff,
	0x9489, 0x8500, 0xb79b, 0xa612, 0xd2ad, 0xc324, 0xf1bf, 0xe036,
	0x18c1, 0x0948, 0x3bd3, 0x2a5a, 0x5ee5, 0x4f6c, 0x7df7, 0x6c7e,
	0xa50a, 0xb483, 0x8618, 0x9791, 0xe32e, 0xf2a7, 0xc03c, 0xd1b5,
	0x2942, 0x38cb, 0x0a50, 0x1bd9, 0x6f66, 0x7eef, 0x4c74, 0x5dfd,
	0xb58b, 0xa402, 0x9699, 0x8710, 0xf3af, 0xe226, 0xd0bd, 0xc134,
	0x39c3, 0x284a, 0x1ad1, 0x0b58, 0x7fe7, 0x6e6e, 0x5cf5, 0x4d7c,
	0xc60c, 0xd785, 0xe51e, 0xf497, 0x8028, 0x91a1, 0xa33a, 0xb2b3,
	0x4a44, 0x5bcd, 0x6956, 0x78df, 0x0c60, 0x1de9, 0x2f72, 0x3efb,
	0xd68d, 0xc704, 0xf59f, 0xe416, 0x90a9, 0x8120, 0xb3bb, 0xa232,
	0x5ac5, 0x4b4c, 0x79d7, 0x685e, 0x1ce1, 0x0d68, 0x3ff3, 0x2e7a,
	0xe70e, 0xf687, 0xc41c, 0xd595, 0xa12a, 0xb0a3, 0x8238, 0x93b1,
	0x6b46, 0x7acf, 0x4854, 0x59dd, 0x2d62, 0x3ceb, 0x0e70, 0x1ff9,
	0xf78f, 0xe606, 0xd49d, 0xc514, 0xb1ab, 0xa022, 0x92b9, 0x8330,
	0x7bc7, 0x6a4e, 0x58d5, 0x495c, 0x3de3, 0x2c6a, 0x1ef1, 0x0f78 
};

INLINE ulong
c_hash_hash (register const char *s)
{
	register ulong result = 0;
	
	while (*s)
	{
		result = (crcTable [(((ulong) TOUPPER (*s)) ^ result) & 0xff]) ^ (result >> 8);
		s++;
	}
	
	return result & COOKIE_HASHMASK;
}
# endif

INLINE COOKIE *
c_hash_lookup (register const char *s, register ushort dev)
{
	register const ulong hashval = c_hash_hash (s);
	register COOKIE *c;
	
	FAT_DEBUG (("c_hash_lookup: s = %s, c_hash (s) = %li", s, hashval));
	
	for (c = ctable [hashval]; c != NULL; c = c->next)
	{
		if ((dev == c->dev) && (stricmp (c->name, s) == 0))
		{
			FAT_DEBUG (("c_hash_lookup: match s = %s, c->name = %s", s, c->name));
			
# ifdef LRU_COOKIE_CACHE
			c_stat_update (c);
# endif
			COOKIE_CACHE_HIT (dev);
			return c;
		}
	}
	
	COOKIE_CACHE_MISS (dev);
	return NULL;
}

INLINE void
c_hash_install (register COOKIE *c)
{
	register const ulong hashval = c_hash_hash (c->name);
	
	FAT_DEBUG (("c_hash_lookup: c->name = %s, c_hash (c->name) = %li", c->name, c_hash_hash (c->name)));
	
	c->next = ctable [hashval];
	ctable [hashval] = c;
	
# ifdef LRU_COOKIE_CACHE
	c_stat_update (c);
# endif
}

INLINE void
c_hash_remove  (register COOKIE *c)
{
	register const ulong hashval = c_hash_hash (c->name);
	register COOKIE **temp = & ctable [hashval];
	register long flag = 1;
	
	while (*temp)
	{
		if (*temp == c)
		{
			*temp = c->next;
			flag = 0;
			break;
		}
		temp = &(*temp)->next;
	}
	
	if (flag)
	{
		FAT_ALERT (("fatfs.c: remove from hashtable fail in: c_hash_remove (addr = %lx, %s)", c, c->name));
	}
}

# ifdef LRU_COOKIE_CACHE
static COOKIE *
c_get_cookie (register char *s)
{
	register COOKIE *u = NULL;
	register ulong min = 4294967295UL;
	register long i;
	
	for (i = 0; i < COOKIE_CACHE; i++)
	{
		register COOKIE *c = &(cookies [i]);
		if (c->links == 0)
		{
			register ulong stat = c->stat;
			if (stat < min)
			{
				min = stat;
				u = c;
			}
		}
	}
	
	if (u)
	{
		if (u->name)
			c_del_cookie (u);
		
		u->name = s;
		u->links = 1;
		u->nextslot = 0;
		
		c_hash_install (u);
	}
	else
	{
		FAT_ALERT (("fatfs.c: c_get_cookie: no free COOKIE found for %s", s));
		FAT_DEBUG_HASH (());
	}
	
	return u;
}
# else
static COOKIE *
c_get_cookie (register char *s)
{
	static long count = 0;
	register long i;
	
	for (i = 0; i < COOKIE_CACHE; i++)
	{
		count++; if (count == COOKIE_CACHE) count = 0;
		{
			register COOKIE *c = &(cookies [count]);
			if (c->links == 0)
			{
				if (c->name)
					c_del_cookie (c);
				
				c->name = s;
				c->links = 1;
				c->nextslot = 0;
				
				c_hash_install (c);
				
				return c;
			}
		}
	}
	
	FAT_ALERT (("fatfs.c: c_get_cookie: no free COOKIE found for %s", s));
	
	FAT_DEBUG_HASH (());
	return NULL;
}
# endif

static void
c_del_cookie (register COOKIE *c)
{
	c_hash_remove (c);
	
	if (c->open)
	{
		FAT_ALERT (("fatfs.c: open FILEPTR detect in: c_del_cookie (%s)", c->name));
		c->open = NULL;
	}
	if (c->locks)
	{
		FAT_ALERT (("fatfs.c: open LOCKS detect in: c_del_cookie (%s)", c->name));
		c->locks = NULL;
	}
	if (c->lastlookup)
	{
		kfree (c->lastlookup);
		c->lastlookup = NULL;
	}
	
	kfree (c->name);
	c->name = NULL;
	c->links = 0;
}

/* END global data & access implementation */
/****************************************************************************/

/****************************************************************************/
/* BEGIN FAT access functions */

/*
 * makros for cluster to sector and sector to cluster calculation
 */

INLINE long
C2S (register long cluster, ushort dev)
{
	return ((cluster * CLSIZE (dev)) + DOFFSET (dev));
}
INLINE long
S2C (register long sector, ushort dev)
{
	return ((sector - DOFFSET (dev)) / CLSIZE (dev));
}

/*
 * makros for FAT validation
 */

# define FAT_VALID12(cl, dev)	(((cl) > 1) && ((cl) < MAXCL (dev)))
# define FAT_VALID16(cl, dev)	(((cl) > 1) && ((cl) < MAXCL (dev)))
# define FAT_VALID32(cl, dev)	(((cl) > 1) && ((cl) < MAXCL (dev)))

# define FAT_LAST12(cl)		((cl) > 0x0000ff7L)
# define FAT_LAST16(cl)		((cl) > 0x000fff7L)
# define FAT_LAST32(cl)		((cl) > 0xffffff7L)

# define FAT_BAD12(cl)		(((cl) > 0x0000fefL) && ((cl) < 0x0000ff8L))
# define FAT_BAD16(cl)		(((cl) > 0x000ffefL) && ((cl) < 0x000fff8L))
# define FAT_BAD32(cl)		(((cl) > 0xfffffefL) && ((cl) < 0xffffff8L))

# define FAT_FREE(cl)		((cl) == 0)

/*
 * makros for fat values
 */

# define CLLAST12		(0x0000fffL)
# define CLLAST16		(0x000ffffL)
# define CLLAST32		(0xfffffffL)

# define CLBAD12		(0x0000ff7L)
# define CLBAD16		(0x000fff7L)
# define CLBAD32		(0xffffff7L)

# define CLFREE			( 0L)
# define CLLAST			(-1L)
# define CLBAD			(-2L)
# define CLILLEGAL		(-3L)

/*
 * stlc (start cluster) access 
 */

# define GET32_STCL(dir)	get32_stcl (dir)
# define PUT32_STCL(dir, cl)	put32_stcl (dir, cl)

INLINE long
get32_stcl (_DIR *dir)
{
	return (((ulong) (le2cpu16 (dir->stcl_fat32))) << 16) | le2cpu16 (dir->stcl);
}

INLINE void
put32_stcl (_DIR *dir, long cl)
{
	dir->stcl = cpu2le16 ((ushort) cl);
	dir->stcl_fat32 = cpu2le16 ((ushort) (cl >> 16));
}

INLINE long
GET_STCL (_DIR *dir, ushort dev)
{
	return FAT32 (dev) ? GET32_STCL (dir) : le2cpu16 (dir->stcl);
}

INLINE void
PUT_STCL (_DIR *dir, ushort dev, long cl)
{
	if (FAT32 (dev))
	{
		PUT32_STCL (dir, cl);
	}
	else
	{
		dir->stcl = cpu2le16 ((ushort) cl);
	}
}

/*
 * getcl??:
 * --------
 * get the contents of the fat entry 'cluster' [repeat n]
 * 
 * return: cluster number to be linked or
 *         negative error number:
 *          CLFREE    ... free
 *          CLLAST    ... last in linked list
 *          CLBAD     ... bad cluster
 *          CLILLEGAL ... illegal value
 *          EREAD     ... read fail
 * 
 * fixcl??:
 * --------
 * set the contents of the fat entry 'cluster'
 * to link to 'next';
 * next can be pos. value or CLFREE, CLLAST, CLBAD
 * 
 * newcl??:
 * ------------
 * allocate a new cluster
 * 
 * ffree??:
 * --------
 * fat free - return the number of free cluster
 * 
 */


/*
 * get cluster
 */

static long
getcl12 (long cluster, const ushort dev, ulong n)
{
	FAT_DEBUG (("getcl12: enter (cluster = %li, n = %li)", cluster, n));
	
	/* input validation */
	if (cluster < 2 || cluster >= MAXCL (dev))
	{
		FAT_DEBUG (("getcl12: leave failure (cluster out of range)"));
		return CLILLEGAL;
	}
	
	{
		register const ulong entrys = SECSIZE (dev) << 1; /* we read 3 sectors */
		register ulong old_sector = 0; /* always invalid for FAT start */
		UNIT *u = NULL;
		
		do {
			register const ulong sector = FATSTART (dev) + ((cluster / entrys) * 3);
			register const ulong offset = ((cluster % entrys) * 12) / 8;
# if 1
			register long newcl;
# endif
			
			if (sector != old_sector)
			{
				register long sectors;
				
				sectors = FATSIZE (dev) - (sector - FATSTART (dev));
				sectors = MIN (3, sectors);
				
				FAT_ASSERT ((sectors == 1 || sectors == 2 || sectors == 3));
				FAT_ASSERT (((sector + sectors) <= (FATSTART (dev) + FATSIZE (dev))));
				
				FAT_DEBUG (("getcl12: start = %li, sectors = %li", sector, sectors));
				
				old_sector = sector;
				u = bio_fat_read (dev, DI (dev), sector, SECSIZE (dev) * sectors);
				if (!u)
				{
					FAT_DEBUG (("getcl12: leave failure (can't read the fat)"));
					return EREAD;
				}
			}
			
# if 1
			/* copy the entry */
			newcl = WPEEK_INTEL (u->data + offset);
			
			FAT_DEBUG (("getcl12: cluster & 1 = %li, newcl = %li", cluster & 1, newcl));
			
			/* mask out the 12 bits */
			if (cluster & 1)
				cluster = newcl >> 4;
			else
				cluster = newcl & 0x0fff;
# else
			cluster = fat12_peek (u->data, offset);
# endif
			
			FAT_DEBUG (("getcl12: cluster = %li", cluster));
			
			/* entry valid? */
			if (!FAT_VALID12 (cluster, dev))
			{
				register long ret;
				
				FAT_FREE (cluster) ? (ret =  CLFREE) :
				FAT_LAST12 (cluster) ? (ret = CLLAST) :
				FAT_BAD12  (cluster) ? (ret = CLBAD) : (ret = CLILLEGAL);
				
				FAT_DEBUG (("getcl12: leave failure (invalid entry, ret = %li)", ret));
				return ret;
			}
		}
		while (--n);
	}
	
	FAT_DEBUG (("getcl12: leave ok (sector = %li, cluster = %li)", C2S (cluster, dev), cluster));
	return cluster;
}

static long
getcl16 (long cluster, const ushort dev, ulong n)
{
	FAT_DEBUG (("getcl16: enter (cluster = %li, n = %li)", cluster, n));
	
	/* input validation */
	if (cluster < 2 || cluster >= MAXCL (dev))
	{
		FAT_DEBUG (("getcl16: leave failure (cluster out of range)"));
		return CLILLEGAL;
	}
	
	{
		register const ulong entrys = SECSIZE (dev) >> 1;
		register ulong old_sector = 0; /* always invalid for FAT start */
		UNIT *u = NULL;
		
		do {
			register const ulong sector = FATSTART (dev) + cluster / entrys;
			register const ulong offset = cluster % entrys;
			
			if (sector != old_sector)
			{
				old_sector = sector;
				u = bio_fat_read (dev, DI (dev), sector, SECSIZE (dev));
				if (!u)
				{
					FAT_DEBUG (("getcl16: leave failure (can't read the fat)"));
					return EREAD;
				}
			}
			
			/* copy the entry */
			cluster = le2cpu16 (*(((ushort *) u->data) + offset));
			
			/* entry valid? */
			if (!FAT_VALID16 (cluster, dev))
			{
				register long ret;
				
				FAT_FREE (cluster) ? (ret =  CLFREE) :
				FAT_LAST16 (cluster) ? (ret = CLLAST) :
				FAT_BAD16  (cluster) ? (ret = CLBAD) : (ret = CLILLEGAL);
				
				FAT_DEBUG (("getcl16: leave failure (invalid entry, ret = %li)", ret));
				return ret;
			}
		}
		while (--n);
	}
	
	FAT_DEBUG (("getcl16: leave ok (sector = %li, cluster = %li)", C2S (cluster, dev), cluster));
	return cluster;
}

static long
getcl32 (long cluster, const ushort dev, ulong n)
{
	FAT_DEBUG (("getcl32: enter (cluster = %li, n = %li)", cluster, n));
	
	/* input validation */
	if (cluster < 2 || cluster >= MAXCL (dev))
	{
		FAT_DEBUG (("getcl32: leave failure (cluster out of range)"));
		return CLILLEGAL;
	}
	
	{
		register const ulong entrys = SECSIZE (dev) >> 2;
		register ulong old_sector = 0; /* always invalid for FAT start */
		UNIT *u = NULL;
		
		do {
			register const ulong sector = FAT32prim (dev) + cluster / entrys;
			register const ulong offset = cluster % entrys;
			
			if (sector != old_sector)
			{
				old_sector = sector;
				u = bio_fat_read (dev, DI (dev), sector, SECSIZE (dev));
				if (!u)
				{
					FAT_DEBUG (("getcl32: leave failure (can't read the fat)"));
					return EREAD;
				}
			}
			
			/* copy the entry */
			cluster = le2cpu32 (*(((ulong *) u->data) + offset));
			
			/* the highest 4 Bits are reserved, mask out */
			cluster &= 0x0fffffffL;
			
			/* entry valid? */
			if (!FAT_VALID32 (cluster, dev))
			{
				register long ret;
				
				FAT_FREE (cluster) ? (ret =  CLFREE) :
				FAT_LAST32 (cluster) ? (ret = CLLAST) :
				FAT_BAD32  (cluster) ? (ret = CLBAD) : (ret = CLILLEGAL);
				
				FAT_DEBUG (("getcl32: leave failure (invalid entry, ret = %li)", ret));
				return ret;
			}
		}
		while (--n);
	}
	
	FAT_DEBUG (("getcl32: leave ok (sector = %li, cluster = %li)", C2S (cluster, dev), cluster));
	return cluster;
}

/*
 * fix cluster
 */

static long
fixcl12 (long cluster, const ushort dev, long next)
{
	FAT_DEBUG (("fixcl12: enter (cluster = %li, next = %li)", cluster, next));
	
	/* input validation */
	if (cluster < 2 || cluster >= MAXCL (dev))
	{
		FAT_DEBUG (("fixcl12: leave failure (cluster out of range)"));
		return CLILLEGAL;
	}
	
	switch (next)
	{
		case CLLAST:	next = CLLAST12;	break;
		case CLBAD:	next = CLBAD12;		break;
	}
	
	{
		register const ulong entrys = SECSIZE (dev) << 1; /* we read 3 sectors */
		register const ulong sector = FATSTART (dev) + ((cluster / entrys) * 3);
		register const ulong offset = ((cluster % entrys) * 12) / 8;
		
		register long sectors;
		
		UNIT *u;
		
		sectors = FATSIZE (dev) - (sector - FATSTART (dev));
		sectors = MIN (3, sectors);
		
		FAT_ASSERT ((sectors == 1 || sectors == 2 || sectors == 3));
		FAT_ASSERT (((sector + sectors) <= (FATSTART (dev) + FATSIZE (dev))));
		
		FAT_DEBUG (("fixcl12: (1) start = %li, sectors = %li", sector, sectors));
		
		u = bio_fat_read (dev, DI (dev), sector, SECSIZE (dev) * sectors);
		if (u)
		{
			register long newcl;
# if 1
			/* read the FAT entry */
			newcl = WPEEK_INTEL (u->data + offset);
			
			FAT_DEBUG (("fixcl12: newcl = %li", newcl));
			
			/* mask in the 12 used bits */
			if (cluster & 1)
				newcl = (newcl & 0x000f) | (next << 4);
			else
				newcl = (newcl & 0xf000) | next;
			
			FAT_DEBUG (("fixcl12: newcl = %li", newcl));
			
			/* write the entry to the first FAT */
			WPOKE_INTEL (u->data + offset, newcl);
# else
			newcl = fat12_poke (u->data, offset, next);
# endif
			
			bio_MARK_MODIFIED ((&bio), u);
			
			if (FAT2ON (dev))
			{
				FAT_DEBUG (("fixcl12: (2) start = %li, sectors = %li", sector + FATSIZE (dev), sectors));
				
				u = bio_fat_read (dev, DI (dev), sector + FATSIZE (dev), SECSIZE (dev) * sectors);
				if (u)
				{
					/* write the entry to the second FAT */
					WPOKE_INTEL (u->data + offset, newcl);
					
					bio_MARK_MODIFIED ((&bio), u);
				}
			}
			
			FAT_DEBUG (("fixcl12: leave ok (return E_OK)"));
			return E_OK;
		}
		
	}
	
	FAT_DEBUG (("fixcl12: leave failure (can't read the fat)"));
	return EREAD;
}

static long
fixcl16 (long cluster, const ushort dev, long next)
{
	FAT_DEBUG (("fixcl16: enter (cluster = %li, next = %li)", cluster, next));
	
	/* input validation */
	if (cluster < 2 || cluster >= MAXCL (dev))
	{
		FAT_DEBUG (("fixcl16: leave failure (cluster out of range)"));
		return CLILLEGAL;
	}
	
	switch (next)
	{
		case CLLAST:	next = CLLAST16;	break;
		case CLBAD:	next = CLBAD16;		break;
	}
	
	{
		register const ulong entrys = SECSIZE (dev) >> 1;
		register const ulong sector = FATSTART (dev) + cluster / entrys;
		register const ulong offset = cluster % entrys;
		
		UNIT *u;
		
		u = bio_fat_read (dev, DI (dev), sector, SECSIZE (dev));
		if (u)
		{
			/* write the entry to the first FAT */
			*(((ushort *) u->data) + offset) = cpu2le16 ((ushort) next);
			
			bio_MARK_MODIFIED ((&bio), u);
			
			if (FAT2ON (dev))
			{
				u = bio_fat_read (dev, DI (dev), sector + FATSIZE (dev), SECSIZE (dev));
				if (u)
				{
					/* write the entry to the second FAT */
					*(((ushort *) u->data) + offset) = cpu2le16 ((ushort) next);
					
					bio_MARK_MODIFIED ((&bio), u);
				}
			}
			
			FAT_DEBUG (("fixcl16: leave ok (return E_OK)"));
			return E_OK;
		}
	}
	
	FAT_DEBUG (("fixcl16: leave failure (can't read the fat)"));
	return EREAD;
}

static long
fixcl32 (long cluster, const ushort dev, long next)
{
	FAT_DEBUG (("fixcl32: enter (cluster = %li, next = %li)", cluster, next));
	
	/* input validation */
	if (cluster < 2 || cluster >= MAXCL (dev))
	{
		FAT_DEBUG (("fixcl32: leave failure (cluster out of range)"));
		return CLILLEGAL;
	}
	
	switch (next)
	{
		case CLLAST:	next = CLLAST32;	break;
		case CLBAD:	next = CLBAD32;		break;
	}
	
	{
		register const ulong entrys = SECSIZE (dev) >> 2;
		register ulong sector = FAT32prim (dev) + cluster / entrys;
		register const ulong offset = cluster % entrys;
		
		UNIT *u;
		
		u = bio_fat_read (dev, DI (dev), sector, SECSIZE (dev));
		if (u)
		{
			/* mask in the highest 4 bit (reserved) */
			next |= *(((ulong *) u->data) + offset) & 0xf0000000L;
			
			/* write the entry to the first FAT */
			*(((ulong *) u->data) + offset) = cpu2le32 ((ulong) next);
			
			bio_MARK_MODIFIED ((&bio), u);
			
			if (FAT32mirr (dev))
			{
				/* update all FATs,
				 * 'sector' is in the first FAT
				 * in this case
				 */
				register long i;
				for (i = FAT2ON (dev); i; i--)
				{
					sector += FATSIZE (dev);
					u = bio_fat_read (dev, DI (dev), sector, SECSIZE (dev));
					if (u)
					{
						/* write the FAT entry */
						*(((ulong *) u->data) + offset) = cpu2le32 ((ulong) next);
						
						bio_MARK_MODIFIED ((&bio), u);
					}
				}
			}
			
			FAT_DEBUG (("fixcl32: leave ok (return E_OK)"));
			return E_OK;
		}
	}
	
	FAT_DEBUG (("fixcl32: leave failure (can't read the fat)"));
	return EREAD;
}


/*
 * new cluster
 */

static long
newcl12 (register long cluster, register const ushort dev)
{
	register const long max = MAXCL (dev);
	register long i;
	
	FAT_DEBUG (("newcl12: enter cluster = %li, dev = %i", cluster, dev));
	
	if (cluster == 0)
	{
		cluster = LASTALLOC (dev);
		FAT_DEBUG (("newcl12: use LASTALLOC = %li", cluster));
	}
	
	/* search free cluster */
	for (i = 2; i < max; i++)
	{
		/* out of range? */
		if (cluster < 2 || cluster >= max)
		{
			cluster = 2;
		}
		
		if (getcl12 (cluster, dev, 1) != CLFREE)
		{
			cluster++;
		}
		else
		{
			/* yes, found a free cluster */
			LASTALLOC (dev) = cluster;
			
			FAT_DEBUG (("newcl12: leave ok, cluster = %li, dev = %i", cluster, dev));
			return cluster;
		}
	}
	
	/* disk full */
	return EACCES;
}

static long
newcl16 (register long cluster, register const ushort dev)
{
	long entrys = SECSIZE (dev) >> 1;
	long todo = FATSIZE (dev) + 1;
	long sector;
	register long i;
	
	FAT_DEBUG (("newcl16: enter cluster = %li", cluster));
	
	if (cluster == 0)
	{
		cluster = LASTALLOC (dev);
		FAT_DEBUG (("newcl16: use LASTALLOC = %li", cluster));
	}
	
	sector = FATSTART (dev) + cluster / entrys;
	i = cluster % entrys;
	cluster -= i;
	
	FAT_DEBUG (("newcl16: i = %li, sector = %li", i, sector));
	
	do {
		UNIT *u;
		
		u = bio_fat_read (dev, DI (dev), sector, SECSIZE (dev));
		if (u)
		{
			/* recalc entrys if overflow */
			if ((cluster + entrys) > MAXCL (dev))
			{
				entrys = MAXCL (dev) - cluster;
			}
			
			/* search a free cluster */
			{
				register ushort *value = (ushort *) u->data;
				while (i < entrys)
				{
					if (!*(value + i))
					{
						cluster += i;
						LASTALLOC (dev) = cluster;
						
						FAT_DEBUG (("newcl16: leave ok, cluster = %li, dev = %i", cluster, dev));
						return cluster;
					}
					i++;
				}
			}
			
			cluster += entrys;
			sector++;
			i = 0;
			if (sector >= (FATSTART (dev) + FATSIZE (dev)))
			{
				cluster = 0;
				entrys = SECSIZE (dev) >> 1;
				sector = FATSTART (dev);
				i = 2;
			}
		}
	}
	while (--todo);
	
	/* disk full */
	return EACCES;
}

static long
newcl32 (register long cluster, register const ushort dev)
{
	long entrys = SECSIZE (dev) >> 2;
	long todo = FATSIZE (dev) + 1;
	long sector;
	register long i;
	
	FAT_DEBUG (("newcl32: enter cluster = %li", cluster));
	
	if (cluster == 0)
	{
		cluster = LASTALLOC (dev);
		FAT_DEBUG (("newcl32: use LASTALLOC = %li", cluster));
	}
	
	sector = FAT32prim (dev) + cluster / entrys;
	i = cluster % entrys;
	cluster -= i;
	
	FAT_DEBUG (("newcl32: i = %li, sector = %li", i, sector));
	
	do {
		UNIT *u;
		
		u = bio_fat_read (dev, DI (dev), sector, SECSIZE (dev));
		if (u)
		{
			/* recalc entrys if overflow */
			if ((cluster + entrys) > MAXCL (dev))
			{
				entrys = MAXCL (dev) - cluster;
			}
			
			/* search a free cluster */
			{
				register ulong *value = (ulong *) u->data;
				while (i < entrys)
				{
# if 1
					/* the highest 4 bits are reserved
					 * -> the lower 4 bits (in the unswapped value)
					 *    are reserved
					 */
					if ((*(value + i) & ~0xf0) == 0)
# else
					/* the highest 4 bits are reserved
					 */
					register long cl;
					
					cl = le2cpu32 (*(value + i));
					cl &= 0x0fffffff;
					if (!cl)
# endif
					{
						cluster += i;
						LASTALLOC (dev) = cluster;
						
						FAT_DEBUG (("newcl32: leave ok, cluster = %li, dev = %i", cluster, dev));
						return cluster;
					}
					
					i++;
				}
			}
			
			cluster += entrys;
			sector++;
			i = 0;
			if (sector >= (FATSTART (dev) + FATSIZE (dev)))
			{
				cluster = 0;
				entrys = SECSIZE (dev) >> 2;
				sector = FAT32prim (dev);
				i = 2;
			}
		}
	}
	while (--todo);
	
	/* disk full */
	return EACCES;
}


/*
 * fat free
 */

static long
ffree12 (const ushort dev)
{
	register long count = 0;
	FAT_DEBUG (("ffree12: enter (%c)", 'A'+dev));
# if 1
	/*
	 * use GETCL (slow)
	 */
	{
		register long i;
		for (i = 2; i < MAXCL (dev); i++)
			if (!getcl12 (i, dev, 1))
				count++;
	}
# else
	/*
	 * read fat direct
	 */
# error not implemented
# endif
	
	FAT_DEBUG (("ffree12: leave count = %li", count));
	return count;
}

static long
ffree16 (const ushort dev)
{
	register long count = 0;
	FAT_DEBUG (("ffree16: enter (%c)", 'A'+dev));
# if 0
	/*
	 * use GETCL (slow)
	 */
	{
		register long i;
		for (i = 2; i < MAXCL (dev); i++)
			if (!getcl16 (i, dev, 1))
				count++;
	}
# else
	/*
	 * read fat direct
	 */
	{	long entrys = SECSIZE (dev) >> 1;	/* FAT entrys per sector */
		long sector = FATSTART (dev);		/* the final startsector to read */
		long todo = FATSIZE (dev);		/* number of sectors to read */
		long cluster = 0;
		
		do {
			UNIT *u;
			
			u = bio_fat_read (dev, DI (dev), sector, SECSIZE (dev));
			if (u)
			{
				/* recalc max if overflow */
				if ((cluster + entrys) > MAXCL (dev))
				{
					entrys = MAXCL (dev) - cluster;
				}
				
				/* count the free cluster */
				{
					register ushort *value = (ushort *) u->data;
					register long i = 0;
					if (cluster == 0)
					{
						value++; value++;
						i = 2;
					}
					for (; i < entrys; i++)
					{
						if (!*value++)
							count++;
					}
				}
				cluster += entrys;
				sector++;
			}
		}
		while (--todo);
	}
# endif	
	
	FAT_DEBUG (("ffree16: leave count = %li", count));
	return count;
}

static long
ffree32 (const ushort dev)
{
	register long count = 0;
	FAT_DEBUG (("ffree32: enter (%c)", 'A'+dev));
# if 0
	/*
	 * use GETCL (slow)
	 */
	{
		register long i;
		for (i = 2; i < MAXCL (dev); i++)
			if (!getcl32 (i, dev, 1))
				count++;
	}
# else
	/*
	 * read fat direct
	 */
	{	long entrys = SECSIZE (dev) >> 2;	/* FAT entrys per sector */
		long sector = FAT32prim (dev);		/* the final startsector to read */
		long todo = FATSIZE (dev);		/* number of sectors to read */
		
# ifdef FAST_FFREE32
		ulong *fat;
		
		fat = kmalloc (SECSIZE (dev) * todo);
		if (fat)
		{
			if (bio_fat_l_read (dev, DI (dev), sector, todo, SECSIZE (dev), fat))
			{
				FAT_DEBUG (("fast ffree32: bio_fat_l_read (%i, %lu, %lu, %lu) fail", dev, sector, todo, SECSIZE (dev)));
				
				kfree (fat);
				fat = NULL;
			}
		}
		else
		{
			FAT_DEBUG (("fast ffree32: kmalloc (%ld) fail", SECSIZE (dev) * todo));
		}
		
		if (fat)
		{
			register ulong *value = fat + 2;
			register long i;
			
			FAT_DEBUG (("fast ffree32: work on fat [%ld bytes]", SECSIZE (dev) * todo));
			
			for (i = MAXCL (dev); i > 2 ; i--)
			{
# if 1
				/* the highest 4 bits are reserved
				 * -> the lower 4 bits (in the unswapped value)
				 *    are reserved
				 */
				if ((*value++ & ~0xf0) == 0)
					count++;
# else
				/* the highest 4 bits are reserved
				 */
				register long cl;
				
				cl = le2cpu32 (*value++);
				cl &= 0x0fffffff;
				if (!cl)
					count++;
# endif
			}
			
			kfree (fat);
		}
		else
# endif /* FAST_FFREE32 */
		{
			long cluster = 0;
			
			do {
				UNIT *u;
				
				u = bio_fat_read (dev, DI (dev), sector, SECSIZE (dev));
				if (u)
				{
					/* recalc max if overflow */
					if ((cluster + entrys) > MAXCL (dev))
					{
						entrys = MAXCL (dev) - cluster;
					}
					
					/* count the free cluster */
					{
						register ulong *value = (ulong *) u->data;
						register long i = 0;
						if (cluster == 0)
						{
							value++; value++;
							i = 2;
						}
						for (; i < entrys; i++)
						{
# if 1
							/* the highest 4 bits are reserved
							 * -> the lower 4 bits (in the unswapped value)
							 *    are reserved
							 */
							if ((*value++ & ~0xf0) == 0)
								count++;
# else
							/* the highest 4 bits are reserved
							 */
							register long cl;
							
							cl = le2cpu32 (*value++);
							cl &= 0x0fffffff;
							if (!cl)
								count++;
# endif
						}
					}
					cluster += entrys;
					sector++;
				}
			}
			while (--todo);
		}
	}
# endif	
	
	FAT_DEBUG (("ffree32: leave count = %li", count));
	return count;
}

/* END FAT access functions */
/****************************************************************************/

/****************************************************************************/
/* BEGIN FAT utility functions */

/* 
 * nextcl:
 * -------
 * get the next cluster; at the end of the cluster chain is
 * a new cluster is allocated
 * 
 * del_chain:
 * ----------
 * delete the cluster chain started at cluster
 */

static long
nextcl (register long cluster, register const ushort dev)
{
	register long content =
		(cluster == 0) ? CLLAST : GETCL (cluster, dev, 1);
	
	if (content == 0)
	{
		FAT_ALERT (("fatfs.c: nextcl: content = 0!"));
	}
	
	if (content == CLLAST)
	{
		/* last, alloc a new cluster */
		
		content = NEWCL (cluster, dev);
		if (content > 0)
		{
			register long r;
			
			r = FIXCL (content, dev, CLLAST);
			if (r) return r;
			
			/* decrease free cluster counter */
			if (!(FREECL (dev) < 0))
			{
				FREECL (dev)--;
			}
			
			if (cluster)
			{
				r = FIXCL (cluster, dev, content);
				if (r) return r;
			}
		}
	}
	
	return content;
}

static long
del_chain (long cluster, const ushort dev)
{
	register long next;
	
	FAT_DEBUG (("del_chain: enter"));
	
	next = GETCL (cluster, dev, 1);
	while (next > 0)
	{
		register long r;
		
		FAT_DEBUG (("del_chain: FIXCL cluster = %li, next = %li", cluster, next));
		
		r = FIXCL (cluster, dev, 0);
		if (r == 0)
		{
			/* increase free cluster counter */
			if (!(FREECL (dev) < 0))
			{
				FREECL (dev)++;
			}
			
			cluster = next;
			next = GETCL (cluster, dev, 1);
		}
		else
		{
			FAT_DEBUG (("del_chain: leave failure (FIXCL, cluster = %li)", cluster));
			return r;
		}
	}
	
	if (next == CLLAST)
	{
		register long r;
		
		r = FIXCL (cluster, dev, 0);
		if (r == 0)
		{
			/* increase free cluster counter */
			if (!(FREECL (dev) < 0))
			{
				FREECL (dev)++;
			}
		}
		
		FAT_DEBUG (("del_chain: leave ok (return FIXCL = %li) cluster = %li", r, cluster));
		return r;
	}
	
	FAT_DEBUG (("del_chain: leave failure (not at end)"));
	return EERROR;
}

/* END FAT utility functions */
/****************************************************************************/

/****************************************************************************/
/* BEGIN DIR part */

INLINE void
zero_cl (register long cl, register const ushort dev)
{
	UNIT *u;
	
	u = bio_data_getunit (dev, DI (dev), C2S (cl, dev), CLUSTSIZE (dev));
	if (u)
	{
		quickzero (u->data, CLUSTSIZE (dev) >> 8);
		bio_MARK_MODIFIED ((&bio), u);
	}
}

INLINE void
dir2str (register const char *src, register char *nm)
{
# ifdef FS_DEBUG
	const char *_src = src;
	char *_nm = nm;
# endif
	register long i;
	
	i = 8;
	while (i-- && *src != ' ')
	{
		*nm++ = *src++;
	}
	
	src += i + 1;
	if (*src > ' ')
	{
		*nm++ = '.';
		i = 3;
		while (i-- && *src != ' ')
		{
			*nm++ = *src++;
		}
	}
	
	*nm = '\0';
	
	FAT_DEBUG (("dir2str: ok (src = %s, nm = %s)", _src, _nm));
}

INLINE void
str2dir (register const char *src, register char *nm)
{
# ifdef FS_DEBUG
	const char *_src = src;
	char *_nm = nm;
# endif
	register long i;
	
	i = 8;
	while (i--)
	{
		if (*src && *src != '.')
			*nm++ = *src++;
		else
			*nm++ = ' ';
	}
	
	if (*src == '.') src++;
	i = 3;
	while (i--)
	{
		if (*src)
			*nm++ = *src++;
		else
			*nm++ = ' ';
	}
	
	FAT_DEBUG (("str2dir: ok (src = %s, nm = %s)", _src, _nm));
}

INLINE long
is_exec (register const char *src)
{
	register ulong i;
# ifndef ONLY030
	/* on 68000 cause an unaligned access
	 * a bus error
	 */
	union
	{
		ulong value;
		char buf [3];
	} data;
	
	data.buf [0] = *src++;
	data.buf [1] = *src++;
	data.buf [2] = *src;
	
	i = data.value;
# else
	i = *(const ulong *) src;
# endif
	
	/* force uppercase */
	i &= 0xdfdfdf00;
	
	/* 0x544f5300L = TOS, 0x54545000L = TTP, 0x50524700L = PRG
	 * 0x41505000L = APP, 0x47545000L = GTP, 0x41434300L = ACC
	 */
	
	return (i == 0x544f5300L || i == 0x54545000L || i == 0x50524700L ||
		i == 0x41505000L || i == 0x47545000L || i == 0x41434300L);
}

/*
 * MS-DOS: A..Z0..9!#$%&'()-@^_`{}~ und grosse Umlaute
 * What about the French and Skandinavian local characters???
 */

# define MSDOS_VALID(c)		(msdos_table [(long) (c)])
# define MSDOS_TABLE		(msdos_table)
static const char msdos_table [256] =
{
/* 000   */ 0,
/* 001   */ 0,	/* 002   */ 0,	/* 003   */ 0,	/* 004   */ 0,	/* 005   */ 0,
/* 006   */ 0,	/* 007   */ 0,	/* 008   */ 0,	/* 009   */ 0,	/* 010   */ 0,
/* 011   */ 0,	/* 012   */ 0,	/* 013   */ 0,	/* 014   */ 0,	/* 015   */ 0,
/* 016   */ 0,	/* 017   */ 0,	/* 018   */ 0,	/* 019   */ 0,	/* 020   */ 0,
/* 021   */ 0,	/* 022   */ 0,	/* 023   */ 0,	/* 024   */ 0,	/* 025   */ 0,
/* 026   */ 0,	/* 027   */ 0,	/* 028   */ 0,	/* 029   */ 0,	/* 030   */ 0,
/* 031   */ 0,	/* 032   */ 0,	/* 033 ! */ 1,	/* 034 " */ 0,	/* 035 # */ 1,
/* 036 $ */ 1,	/* 037 % */ 1,	/* 038 & */ 1,	/* 039 ' */ 1,	/* 040 ( */ 1,
/* 041 ) */ 1,	/* 042 * */ 0,	/* 043 + */ 0,	/* 044 , */ 0,	/* 045 - */ 1,
/* 046 . */ 0,	/* 047 / */ 0,	/* 048 0 */ 1,	/* 049 1 */ 1,	/* 050 2 */ 1,
/* 051 3 */ 1,	/* 052 4 */ 1,	/* 053 5 */ 1,	/* 054 6 */ 1,	/* 055 7 */ 1,
/* 056 8 */ 1,	/* 057 9 */ 1,	/* 058 : */ 0,	/* 059 ; */ 0,	/* 060 < */ 0,
/* 061 = */ 0,	/* 062 > */ 0,	/* 063 ? */ 0,	/* 064 @ */ 1,	/* 065 A */ 1,
/* 066 B */ 1,	/* 067 C */ 1,	/* 068 D */ 1,	/* 069 E */ 1,	/* 070 F */ 1,
/* 071 G */ 1,	/* 072 H */ 1,	/* 073 I */ 1,	/* 074 J */ 1,	/* 075 K */ 1,
/* 076 L */ 1,	/* 077 M */ 1,	/* 078 N */ 1,	/* 079 O */ 1,	/* 080 P */ 1,
/* 081 Q */ 1,	/* 082 R */ 1,	/* 083 S */ 1,	/* 084 T */ 1,	/* 085 U */ 1,
/* 086 V */ 1,	/* 087 W */ 1,	/* 088 X */ 1,	/* 089 Y */ 1,	/* 090 Z */ 1,
/* 091 [ */ 0,	/* 092 \ */ 0,	/* 093 ] */ 0,	/* 094 ^ */ 1,	/* 095 _ */ 1,
/* 096 ` */ 1,	/* 097 a */ 1,	/* 098 b */ 1,	/* 099 c */ 1,	/* 100 d */ 1,
/* 101 e */ 1,	/* 102 f */ 1,	/* 103 g */ 1,	/* 104 h */ 1,	/* 105 i */ 1,
/* 106 j */ 1,	/* 107 k */ 1,	/* 108 l */ 1,	/* 109 m */ 1,	/* 110 n */ 1,
/* 111 o */ 1,	/* 112 p */ 1,	/* 113 q */ 1,	/* 114 r */ 1,	/* 115 s */ 1,
/* 116 t */ 1,	/* 117 u */ 1,	/* 118 v */ 1,	/* 119 w */ 1,	/* 120 x */ 1,
/* 121 y */ 1,	/* 122 z */ 1,	/* 123 { */ 1,	/* 124 | */ 0,	/* 125 } */ 1,
/* 126 ~ */ 1,	/* 127   */ 0,	/* 128   */ 0,	/* 129 Å */ 0,	/* 130   */ 0,
/* 131   */ 0,	/* 132 Ñ */ 0,	/* 133   */ 0,	/* 134   */ 0,	/* 135   */ 0,
/* 136   */ 0,	/* 137   */ 0,	/* 138   */ 0,	/* 139   */ 0,	/* 140   */ 0,
/* 141   */ 0,	/* 142 é */ 1,	/* 143   */ 0,	/* 144   */ 0,	/* 145   */ 0,
/* 146   */ 0,	/* 147   */ 0,	/* 148 î */ 0,	/* 149   */ 0,	/* 150   */ 0,
/* 151   */ 0,	/* 152   */ 0,	/* 153 ô */ 1,	/* 154 ö */ 1,	/* 155   */ 0,
/* 156   */ 0,	/* 157   */ 0,	/* 158   */ 0,	/* 159   */ 0,	/* 160   */ 0,
/* 161   */ 0,	/* 162   */ 0,	/* 163   */ 0,	/* 164   */ 0,	/* 165   */ 0,
/* 166   */ 0,	/* 167   */ 0,	/* 168   */ 0,	/* 169   */ 0,	/* 170   */ 0,
/* 171   */ 0,	/* 172   */ 0,	/* 173   */ 0,	/* 174   */ 0,	/* 175   */ 0,
/* 176   */ 0,	/* 177   */ 0,	/* 178   */ 0,	/* 179   */ 0,	/* 180   */ 0,
/* 181   */ 0,	/* 182   */ 0,	/* 183   */ 0,	/* 184   */ 0,	/* 185   */ 0,
/* 186   */ 0,	/* 187   */ 0,	/* 188   */ 0,	/* 189   */ 0,	/* 190   */ 0,
/* 191   */ 0,	/* 192   */ 0,	/* 193   */ 0,	/* 194   */ 0,	/* 195   */ 0,
/* 196   */ 0,	/* 197   */ 0,	/* 198   */ 0,	/* 199   */ 0,	/* 200   */ 0
/* 201 - 255 automatically set to 0 */
};

/*
 * GEMDOS: A..Z0..9!#$%&'()-@^_`{}~"+,;<=>[]| und grosse Umlaute
 * What about the French and Skandinavian local characters???
 */

# define GEMDOS_VALID(c)	(gemdos_table [(long) (c)])
# define GEMDOS_TABLE		(gemdos_table)
static const char gemdos_table [256] =
{
/* 000   */ 0,
/* 001   */ 0,	/* 002   */ 0,	/* 003   */ 0,	/* 004   */ 0,	/* 005   */ 0,
/* 006   */ 0,	/* 007   */ 0,	/* 008   */ 0,	/* 009   */ 0,	/* 010   */ 0,
/* 011   */ 0,	/* 012   */ 0,	/* 013   */ 0,	/* 014   */ 0,	/* 015   */ 0,
/* 016   */ 0,	/* 017   */ 0,	/* 018   */ 0,	/* 019   */ 0,	/* 020   */ 0,
/* 021   */ 0,	/* 022   */ 0,	/* 023   */ 0,	/* 024   */ 0,	/* 025   */ 0,
/* 026   */ 0,	/* 027   */ 0,	/* 028   */ 0,	/* 029   */ 0,	/* 030   */ 0,
/* 031   */ 0,	/* 032   */ 0,	/* 033 ! */ 1,	/* 034 " */ 0,	/* 035 # */ 1,
/* 036 $ */ 1,	/* 037 % */ 1,	/* 038 & */ 1,	/* 039 ' */ 1,	/* 040 ( */ 1,
/* 041 ) */ 1,	/* 042 * */ 0,	/* 043 + */ 1,	/* 044 , */ 1,	/* 045 - */ 1,
/* 046 . */ 0,	/* 047 / */ 0,	/* 048 0 */ 1,	/* 049 1 */ 1,	/* 050 2 */ 1,
/* 051 3 */ 1,	/* 052 4 */ 1,	/* 053 5 */ 1,	/* 054 6 */ 1,	/* 055 7 */ 1,
/* 056 8 */ 1,	/* 057 9 */ 1,	/* 058 : */ 0,	/* 059 ; */ 1,	/* 060 < */ 1,
/* 061 = */ 1,	/* 062 > */ 1,	/* 063 ? */ 0,	/* 064 @ */ 1,	/* 065 A */ 1,
/* 066 B */ 1,	/* 067 C */ 1,	/* 068 D */ 1,	/* 069 E */ 1,	/* 070 F */ 1,
/* 071 G */ 1,	/* 072 H */ 1,	/* 073 I */ 1,	/* 074 J */ 1,	/* 075 K */ 1,
/* 076 L */ 1,	/* 077 M */ 1,	/* 078 N */ 1,	/* 079 O */ 1,	/* 080 P */ 1,
/* 081 Q */ 1,	/* 082 R */ 1,	/* 083 S */ 1,	/* 084 T */ 1,	/* 085 U */ 1,
/* 086 V */ 1,	/* 087 W */ 1,	/* 088 X */ 1,	/* 089 Y */ 1,	/* 090 Z */ 1,
/* 091 [ */ 1,	/* 092 \ */ 0,	/* 093 ] */ 1,	/* 094 ^ */ 1,	/* 095 _ */ 1,
/* 096 ` */ 1,	/* 097 a */ 1,	/* 098 b */ 1,	/* 099 c */ 1,	/* 100 d */ 1,
/* 101 e */ 1,	/* 102 f */ 1,	/* 103 g */ 1,	/* 104 h */ 1,	/* 105 i */ 1,
/* 106 j */ 1,	/* 107 k */ 1,	/* 108 l */ 1,	/* 109 m */ 1,	/* 110 n */ 1,
/* 111 o */ 1,	/* 112 p */ 1,	/* 113 q */ 1,	/* 114 r */ 1,	/* 115 s */ 1,
/* 116 t */ 1,	/* 117 u */ 1,	/* 118 v */ 1,	/* 119 w */ 1,	/* 120 x */ 1,
/* 121 y */ 1,	/* 122 z */ 1,	/* 123 { */ 1,	/* 124 | */ 1,	/* 125 } */ 1,
/* 126 ~ */ 1,	/* 127   */ 0,	/* 128   */ 0,	/* 129 Å */ 0,	/* 130   */ 0,
/* 131   */ 0,	/* 132 Ñ */ 0,	/* 133   */ 0,	/* 134   */ 0,	/* 135   */ 0,
/* 136   */ 0,	/* 137   */ 0,	/* 138   */ 0,	/* 139   */ 0,	/* 140   */ 0,
/* 141   */ 0,	/* 142 é */ 1,	/* 143   */ 0,	/* 144   */ 0,	/* 145   */ 0,
/* 146   */ 0,	/* 147   */ 0,	/* 148 î */ 0,	/* 149   */ 0,	/* 150   */ 0,
/* 151   */ 0,	/* 152   */ 0,	/* 153 ô */ 1,	/* 154 ö */ 1,	/* 155   */ 0,
/* 156   */ 0,	/* 157   */ 0,	/* 158   */ 0,	/* 159   */ 0,	/* 160   */ 0,
/* 161   */ 0,	/* 162   */ 0,	/* 163   */ 0,	/* 164   */ 0,	/* 165   */ 0,
/* 166   */ 0,	/* 167   */ 0,	/* 168   */ 0,	/* 169   */ 0,	/* 170   */ 0,
/* 171   */ 0,	/* 172   */ 0,	/* 173   */ 0,	/* 174   */ 0,	/* 175   */ 0,
/* 176   */ 0,	/* 177   */ 0,	/* 178   */ 0,	/* 179   */ 0,	/* 180   */ 0,
/* 181   */ 0,	/* 182   */ 0,	/* 183   */ 0,	/* 184   */ 0,	/* 185   */ 0,
/* 186   */ 0,	/* 187   */ 0,	/* 188   */ 0,	/* 189   */ 0,	/* 190   */ 0,
/* 191   */ 0,	/* 192   */ 0,	/* 193   */ 0,	/* 194   */ 0,	/* 195   */ 0,
/* 196   */ 0,	/* 197   */ 0,	/* 198   */ 0,	/* 199   */ 0,	/* 200   */ 0
/* 201 - 255 automatically set to 0 */
};

/*
 * ISO: A..Z0..9_
 */

# define ISO_VALID(c)		(iso_table [(long) (c)])
# define ISO_TABLE		(iso_table)
static const char iso_table [256] =
{
/* 000   */ 0,
/* 001   */ 0,	/* 002   */ 0,	/* 003   */ 0,	/* 004   */ 0,	/* 005   */ 0,
/* 006   */ 0,	/* 007   */ 0,	/* 008   */ 0,	/* 009   */ 0,	/* 010   */ 0,
/* 011   */ 0,	/* 012   */ 0,	/* 013   */ 0,	/* 014   */ 0,	/* 015   */ 0,
/* 016   */ 0,	/* 017   */ 0,	/* 018   */ 0,	/* 019   */ 0,	/* 020   */ 0,
/* 021   */ 0,	/* 022   */ 0,	/* 023   */ 0,	/* 024   */ 0,	/* 025   */ 0,
/* 026   */ 0,	/* 027   */ 0,	/* 028   */ 0,	/* 029   */ 0,	/* 030   */ 0,
/* 031   */ 0,	/* 032   */ 0,	/* 033 ! */ 0,	/* 034 " */ 0,	/* 035 # */ 0,
/* 036 $ */ 0,	/* 037 % */ 0,	/* 038 & */ 0,	/* 039 ' */ 0,	/* 040 ( */ 0,
/* 041 ) */ 0,	/* 042 * */ 0,	/* 043 + */ 0,	/* 044 , */ 0,	/* 045 - */ 0,
/* 046 . */ 0,	/* 047 / */ 0,	/* 048 0 */ 1,	/* 049 1 */ 1,	/* 050 2 */ 1,
/* 051 3 */ 1,	/* 052 4 */ 1,	/* 053 5 */ 1,	/* 054 6 */ 1,	/* 055 7 */ 1,
/* 056 8 */ 1,	/* 057 9 */ 1,	/* 058 : */ 0,	/* 059 ; */ 0,	/* 060 < */ 0,
/* 061 = */ 0,	/* 062 > */ 0,	/* 063 ? */ 0,	/* 064 @ */ 0,	/* 065 A */ 1,
/* 066 B */ 1,	/* 067 C */ 1,	/* 068 D */ 1,	/* 069 E */ 1,	/* 070 F */ 1,
/* 071 G */ 1,	/* 072 H */ 1,	/* 073 I */ 1,	/* 074 J */ 1,	/* 075 K */ 1,
/* 076 L */ 1,	/* 077 M */ 1,	/* 078 N */ 1,	/* 079 O */ 1,	/* 080 P */ 1,
/* 081 Q */ 1,	/* 082 R */ 1,	/* 083 S */ 1,	/* 084 T */ 1,	/* 085 U */ 1,
/* 086 V */ 1,	/* 087 W */ 1,	/* 088 X */ 1,	/* 089 Y */ 1,	/* 090 Z */ 1,
/* 091 [ */ 0,	/* 092 \ */ 0,	/* 093 ] */ 0,	/* 094 ^ */ 0,	/* 095 _ */ 1,
/* 096 ` */ 0,	/* 097 a */ 1,	/* 098 b */ 1,	/* 099 c */ 1,	/* 100 d */ 1,
/* 101 e */ 1,	/* 102 f */ 1,	/* 103 g */ 1,	/* 104 h */ 1,	/* 105 i */ 1,
/* 106 j */ 1,	/* 107 k */ 1,	/* 108 l */ 1,	/* 109 m */ 1,	/* 110 n */ 1,
/* 111 o */ 1,	/* 112 p */ 1,	/* 113 q */ 1,	/* 114 r */ 1,	/* 115 s */ 1,
/* 116 t */ 1,	/* 117 u */ 1,	/* 118 v */ 1,	/* 119 w */ 1,	/* 120 x */ 1,
/* 121 y */ 1,	/* 122 z */ 1,	/* 123 { */ 0,	/* 124 | */ 0,	/* 125 } */ 0,
/* 126 ~ */ 0,	/* 127   */ 0,	/* 128   */ 0,	/* 129 Å */ 0,	/* 130   */ 0,
/* 131   */ 0,	/* 132 Ñ */ 0,	/* 133   */ 0,	/* 134   */ 0,	/* 135   */ 0,
/* 136   */ 0,	/* 137   */ 0,	/* 138   */ 0,	/* 139   */ 0,	/* 140   */ 0,
/* 141   */ 0,	/* 142 é */ 0,	/* 143   */ 0,	/* 144   */ 0,	/* 145   */ 0,
/* 146   */ 0,	/* 147   */ 0,	/* 148 î */ 0,	/* 149   */ 0,	/* 150   */ 0,
/* 151   */ 0,	/* 152   */ 0,	/* 153 ô */ 0,	/* 154 ö */ 0,	/* 155   */ 0,
/* 156   */ 0,	/* 157   */ 0,	/* 158   */ 0,	/* 159   */ 0,	/* 160   */ 0,
/* 161   */ 0,	/* 162   */ 0,	/* 163   */ 0,	/* 164   */ 0,	/* 165   */ 0,
/* 166   */ 0,	/* 167   */ 0,	/* 168   */ 0,	/* 169   */ 0,	/* 170   */ 0,
/* 171   */ 0,	/* 172   */ 0,	/* 173   */ 0,	/* 174   */ 0,	/* 175   */ 0,
/* 176   */ 0,	/* 177   */ 0,	/* 178   */ 0,	/* 179   */ 0,	/* 180   */ 0,
/* 181   */ 0,	/* 182   */ 0,	/* 183   */ 0,	/* 184   */ 0,	/* 185   */ 0,
/* 186   */ 0,	/* 187   */ 0,	/* 188   */ 0,	/* 189   */ 0,	/* 190   */ 0,
/* 191   */ 0,	/* 192   */ 0,	/* 193   */ 0,	/* 194   */ 0,	/* 195   */ 0,
/* 196   */ 0,	/* 197   */ 0,	/* 198   */ 0,	/* 199   */ 0,	/* 200   */ 0
/* 201 - 255 automatically set to 0 */
};

static int
is_short (register const char *src, register const char *table)
{
	register long i = strlen (src);
	
	FAT_DEBUG (("is_short: enter (src = %s, len = %li)", src, i));
	
	/* verify length and beginning point */
	if (i > 12 || *src == '.')
	{
		FAT_DEBUG (("is_short: leave check 0 (src = %s)", src));
		return 0;
	}
	
	/* verify base name */
	i = 8;
	while (i-- && *src && *src != '.')
	{
		if (table [(long) *src])
		{
			src++;
		}
		else
		{
			FAT_DEBUG (("is_short: leave check 1 (src = %s)", src));
			return 0;
		}
	}
	
	/* verify extension */
	if (*src == '.')
	{
		src++;
		i = 3;
		while (i-- && *src && *src != '.')
		{
			if (table [(long) *src])
			{
				src++;
			}
			else
			{
				FAT_DEBUG (("is_short: leave check 2 (src = %s)", src));
				return 0;
			}
		}
	}
	
	/* anything left? */
	if (*src)
	{
		FAT_DEBUG (("is_short: leave check 3 (src = %s)", src));
		return 0;
	}
	
	FAT_DEBUG (("is_short: leave ok (return = 1)"));
	return TOS_SEARCH; /* shortname */
}

INLINE long
fat_trunc (register char *dst, const char *src, register long len, COOKIE *dir)
{
	/* truncate name to 8+3 and verify that the name
	 * doesn't exist in this dir
	 * 
	 * 1: select the first eight characters
	 * 
	 * 2: if there is an extension, select its first three
	 *    characters
	 * 
	 * 3: convert letters to uppercase.
	 * 
	 * 4: convert to underscore any character
	 *    that are illegal
	 * 
	 * 5: check for existing filename
	 */
	
	register const char *table = DEFAULT_T (dir->dev);
	register const char *s = src;
	register char *d = dst;
	register long i;
	
	/* step 1 - 4 */
	
	if (*s == '.') s++;
	i = 8;
	while (i-- && *s && *s != '.')
	{
		*d++ = table [(long) *s] ? TOUPPER (*s) : '_';
		s++;
	}
	
	s = src + len; s--;
	while (*s && *s != '.') s--;
	
	if (*s == '.')
	{
		*d++ = '.';
		s++;
		for (i = 1; i < 4 && *s; i++)
		{
			*d++ = table [(long) *s] ? TOUPPER (*s) : '_';
			s++;
		}
	}
	
	/* step 5 */
	i = search_cookie (dir, NULL, dst, TOS_SEARCH);
	
	if (i == E_OK)
	{
		/* file exist */
		return EACCES;
	}
	
	/* file doesn't exist */
	return E_OK;
}

INLINE long
vfat_trunc (register char *dst, const char *src, register long len, COOKIE *dir)
{
	/* truncate name to 8+3 and verify that the name
	 * doesn't exist in this dir
	 *
	 * 1: select the first eight characters
	 * 
	 * 2: if there is an extension, select its first three
	 *    characters
	 * 
	 * 3: convert letters to uppercase.
	 * 
	 * 4: convert to underscore any character that are illegal
	 *    under the FAT fs; valid are:
	 *    character, digit and $ % ' - _ @ ~ ` ! ( ) # { }
	 * 
	 * 5: if the resulting name already exists in the same dir,
	 *    replace the last two characters with a tilde and a
	 *    unique integer (Even if the resulting name is unique,
	 *    replace the last two characters if the long filename
	 *    has embedded spaces or illegal characters.)
	 */
	
	char ext [4] = { '\0', '\0', '\0', '\0' };
	register const char *s = src;
	register char *d = dst;
	register char *bak;
	register long i;
	
	/* first zero the dst */
	for (i = 13; i; i--)
		*d++ = '\0';
	
	/* step 1 - 4 */
	
	if (*s == '.') s++;
	d = dst;
	i = 8;
	while (i-- && *s && *s != '.')
	{
		*d++ = MSDOS_VALID (*s) ? TOUPPER (*s) : '_';
		s++;
	}
	
	bak = d - 1;
	
	s = src + len; s--;
	while (*s && *s != '.') s--;
	
	if (*s == '.')
	{
		ext [0] = *d++ = '.';
		s++;
		for (i = 1; i < 4 && *s; i++)
		{
			ext [i] = *d++ = MSDOS_VALID (*s) ? TOUPPER (*s) : '_';
			s++;
		}
	}
	
	/* step 5 */
	i = bak - dst;
	if (i < 7)
	{
		i = 7 - i;
		bak += MIN (2, i);
		for (i = 4; i; i--)
			*(bak + i) = ext[i-1];
	}
	i = 1;
	*bak = ((char) i) + '0'; *(bak - 1) = '~';
	while (search_cookie (dir, NULL, dst, TOS_SEARCH) == E_OK)
	{
		register long j;
		if (i == 10L || i == 100L || i == 1000L || i == 10000L || i == 100000L)
		{
			j = bak - dst;
			if (j < 7)
			{
				bak++;
				for (j = 4; j; j--)
					*(bak + j) = ext[j-1];
			}
		}
		d = bak;
		j = i;
		while (j)
		{
			*d-- = ((char) (j % 10)) + '0';
			j /= 10;
		}
		*d = '~';
		i++;
	}
	
	return E_OK;
}

static long
make_shortname (COOKIE *dir, const char *src, char *dst)
{
	register const long len = strlen (src);
	const int sflag = is_short (src, DEFAULT_T (dir->dev));
	
# ifdef FS_DEBUG
	const char *start = dst;
# endif
	
	FAT_DEBUG (("make_shortname: enter (src = %s, len, = %li, sflag = %u)", src, len, sflag));
	if (!sflag)
	{
		long r;
		
		if (VFAT (dir->dev))
			r = vfat_trunc (dst, src, len, dir);
		else
			r = fat_trunc (dst, src, len, dir);
		
		if (r) return r;
	}
	else
	{
		/* copy the name (it's in correct 8+3 format) */
		
		register const char *s = src;
		while (*s)
		{
			*dst++ = TOUPPER (*s);
			s++;
		}
		*dst ='\0';
	}
	
	if (VFAT (dir->dev))
	{
		if (!sflag)
		{
			/* a really longname */
			
			FAT_DEBUG (("make_shortname: leave ok (VFAT) (s = %s, return = %li)", start, len));
			return len;
		}
		
		/* casesensitive check */
		if (LCASE (dir->dev))
		{
# if 0
			register const char *s = src;
			while (*s)
			{
				if (*s >= 'A' && *s <= 'Z')
				{
					FAT_DEBUG (("make_shortname: leave ok (casesensitive [lcase]) (s = %s, return = %li)", start, len));
					return len;
				}
				else
					s++;
			}
# else
			/* create always VFAT names
			 * to avoid problems with wrong upper/lowercase
			 * under MagiC/Windows
			 */
			FAT_DEBUG (("make_shortname: leave ok (casesensitive [lcase]) (s = %s, return = %li)", start, len));
			return len;
# endif
		}
		else
		{
			register const char *s = src;
			while (*s)
			{
				if (*s >= 'a' && *s <= 'z')
				{
					FAT_DEBUG (("make_shortname: leave ok (casesensitive) (s = %s, return = %li)", start, len));
					return len;
				}
				else
					s++;
			}
		}
		
		/* name is in 8+3 and correct upper/lower case */
	}
	
	/* else { truncated, copied and verifed before } */
	
	FAT_DEBUG (("make_shortname: leave ok (FAT) (s = %s, return = 0)", start));
	return 0;
}

INLINE long
__opendir (register oDIR *dir, register const long cluster, register const ushort dev)
{
	dir->dev = dev;
	dir->rdev = dev;
	dir->stcl = cluster;
	dir->actual = 0;
	dir->cl = -1;
	dir->index = -1;
	dir->real_index = -1;
	dir->u = NULL;
	
	FAT_DEBUG (("__opendir: ok (dev = %i, stcl = %li)", dir->dev, dir->stcl));
	return E_OK;
}

INLINE void
__closedir (register oDIR *dir)
{
	if (dir->u)
		bio.unlock (dir->u);
	
	FAT_DEBUG (("__closedir: ok (dev = %i, stcl = %li)", dir->dev, dir->stcl));
}

INLINE void
__updatedir (register oDIR *dir)
{
	bio_MARK_MODIFIED (&(bio), dir->u);
	
	FAT_DEBUG (("__updatedir: ok (dev = %i, stcl = %li)", dir->dev, dir->stcl));
}

static long
__seekdir (register oDIR *dir, register long index, ushort mode)
{
	register const ushort dev = dir->dev;
	register long offset;
	
	FAT_DEBUG (("__seekdir: enter (index = %li, dev = %i, stcl = %li)", index, dir->dev, dir->stcl));
	
	if (dir->stcl == 1)
	{
		/* ROOT DIR */
		
		if (index >= ROOTENTRYS (dev))
		{
			/* no more in root dir */
			
			FAT_DEBUG (("__seekdir: leave ok (no more in root, dev = %i)", dir->dev));
			return ENMFILES;
		}
		else
		{
			/* calculate the offset */
			
			register const long entrys = ENTRYS (dev) / CLSIZE (dev);
			register const long sector = index / entrys;
			
			offset = index % entrys;
			
			if (sector != dir->cl)
			{
				/* read the right unit */
				
				if (dir->u)
					bio.unlock (dir->u);
				
				dir->actual = sector;
				dir->cl = sector;
				dir->u = bio_data_read (dev, DI (dev), ROOT (dev) + sector, SECSIZE (dev));
				
				if (!dir->u)
				{
					dir->cl = -1;
					dir->info = NULL;
					
					FAT_DEBUG (("__seekdir: leave failure (read cluster, sector = %li);", ROOT (dir->dev) + sector));
					return EREAD;
				}
				
				bio.lock (dir->u);
			}
		}
	}
	else
	{
		/* SUB DIR */
		
		register const long entrys = ENTRYS (dev);
		register const long cluster = index / entrys;
		
		offset = index % entrys;
		
		if (cluster != dir->cl)
		{
			/* read the right cluster */
			
			register long actual = GETCL (dir->stcl, dev, cluster);
			if (actual <= 0)
			{
				FAT_DEBUG (("__seekdir: failure get right cluster (error = %li)", actual));
				if (mode == READ)
				{
					FAT_DEBUG (("__seekdir: leave ENMFILES (read only)"));
					return ENMFILES;
				}
				actual = GETCL (dir->stcl, dev, cluster - 1);
				if (actual <= 0)
				{
					FAT_DEBUG (("__seekdir: can't read prev cl (error = %li)", actual));
					return ENMFILES;
				}
				actual = nextcl (actual, dev);
				if (actual <= 0)
				{
					FAT_DEBUG (("__seekdir: can't expand dir (error = %li)", actual));
					return ENMFILES;
				}
				zero_cl (actual, dev);
			}
			
			if (dir->u)
				bio.unlock (dir->u);
			
			dir->actual = actual;
			dir->cl = cluster;
			dir->u = bio_data_read (dev, DI (dev), C2S (actual, dev), CLUSTSIZE (dev));
			
			if (!dir->u)
			{
				dir->cl = -1;
				dir->info = NULL;
				
				FAT_DEBUG (("__seekdir: leave failure (read cluster, sector = %li);", dir->actual));
				return EREAD;
			}
			
			bio.lock (dir->u);
		}
	}
	
	dir->index = dir->real_index = index;
	dir->info = ((_DIR *) dir->u->data) + offset;
	
	FAT_DEBUG (("__seekdir: leave ok"));
	return E_OK;
}

INLINE long
__SEEKDIR (register oDIR *dir, register long index, ushort mode)
{
	register const long entrys = (dir->stcl > 1) ?
		ENTRYS (dir->dev) :
		ENTRYS (dir->dev) / CLSIZE (dir->dev);
	
	FAT_DEBUG (("__SEEKDIR: set index = %li (dev = %i, stcl = %li)", index, dir->dev, dir->stcl));
	
	if ((index / entrys) == dir->cl)
	{
		dir->index = dir->real_index = index;
		dir->info = ((_DIR *) dir->u->data) + (index % entrys);
		
		return E_OK;
	}
	
	return __seekdir (dir, index, mode);
}

INLINE void
ldir2unicode (long slot, uchar *name, LDIR *ldir)
{
 	register long offset = slot * 13 * 2;
	register long i;
	
	for (i = 0; i < 10; i++)
		name [offset+i] = ldir->name0_4   [i];
	
	offset += 10;
	for (i = 0; i < 12; i++)
		name [offset+i] = ldir->name5_10  [i];
	
	offset += 12;
	for (i = 0; i < 4; i++)
		name [offset+i] = ldir->name11_12 [i];
}

INLINE long
__readvfat (register oDIR *dir, char *lname, long size)
{
	LDIR *ldir = (LDIR *) dir->info;
	
	FAT_DEBUG (("__readvfat: enter (real = %li, index = %li)", dir->real_index, dir->index));
	
	if (ldir->head & 0x40)
	{
		uchar name [VFAT_NAMEMAX * 2];
		long r = 0;
		long is_long = 1;
		
		long slots = ldir->head & ~0x40;
		long slot = slots - 1;
		uchar chksum = ldir->chksum;
		
		FAT_DEBUG (("__readvfat: slots = %li, chksum = %li", slots, (long) chksum));
		
		if (lname) ldir2unicode (slot, name, ldir);
		
		while (slot > 0)
		{
			r = __SEEKDIR (dir, dir->real_index + 1, READ);
			if (r) return r;
			ldir = (LDIR *) dir->info;
			
			if (ldir->head != slot)
			{
				FAT_DEBUG (("__readvfat: error (head != slot, head = %li)", (long) ldir->head));
				is_long = 0;
				break;
			}
			if (ldir->chksum != chksum)
			{
				FAT_DEBUG (("__readvfat: error (bad chksum, slot = %li, chksum = %li)", slot, (long) ldir->chksum));
				is_long = 0;
				break;
			}
			
			slot--;
			
			if (lname) ldir2unicode (slot, name, ldir);
		}
		
		if (is_long)
		{
			register uchar sum;
			
			r = __SEEKDIR (dir, dir->real_index + 1, READ);
			if (r) return r;
			
			ldir = (LDIR *) dir->info;
			
			FAT_DEBUG_PRINTDIR ((dir->info, dir->dev));
			
			/* calculate the checksum */
			{
				register long i;
				for (sum = i = 0; i < 11; i++)
				{
					sum = (((sum & 1) << 7) | ((sum & 0xfe) >> 1))
						+ dir->info->name [i];
				}
			}
			
			if (sum == chksum)
			{
				if (lname)
				{
					/* copy Unicode string to Atari ST character string */
					register long i = slots * 13;
					
					/* range check */
					if (i >= size)
					{
						i--; /* null relative */
						i <<= 1;
						for (; i; i -= 2)
						{
							if (name [i] == '\0' && name [i+1] == '\0')
							{
								i >>= 1;
								break;
							}
						}
						if (i == 0 || i > size - 1)
						{
							i = size - 1;
							slots = EBADARG;
						}
					}
					
					/* copy */
					lname [i] = '\0';
					while (i--)
					{
						register const long j = i << 1;
						lname [i] = UNI2ATARI ((name [j]), (name [j+1]));
					}
					
					FAT_DEBUG (("__readvfat: (lname = %s)", lname));
				}
				
				FAT_DEBUG (("__readvfat: leave ok"));
				return slots;
			}
			else
			{
				FAT_DEBUG (("__readvfat: error (bad chksum, sum = %li)", (long) sum));
			}
		}
		
		/* repositionate backward (for nextdir) */
		r = __SEEKDIR (dir, dir->real_index - 1, READ);
		
		return r;
	}
	
	FAT_DEBUG (("__readvfat: leave failure (not valid head)"));
	return 0;
}

static long
__nextdir (register oDIR *dir, char *name, long size)
{
	for (;;)
	{
		register long index = dir->real_index + 1;
		register long r;
		
		r = __SEEKDIR (dir, index, READ);
		if (r) return r;
		
		if (dir->info->name[0] == '\0')
		{
			/* never used */
			
			FAT_DEBUG (("__nextdir: leave failure (no more) index = %li", index));
			return ENMFILES;
		}
		else if ((dir->info->name[0] == (char) 0xe5)
			|| (dir->info->name[0] == (char) 0x05))
		{
			/* a deleted entry */
			
			FAT_DEBUG (("__nextdir: (skip deleted) index = %li", index));
			/* skip */
		}
		else if (dir->info->attr == FA_VFAT)
		{
			/* a vfat entry */
			
			r = __readvfat (dir, name, size);
			if (r > 0)
			{
				dir->index = index;
				return r;
			}
			
			if (r == EBADARG)
			{
				FAT_DEBUG (("__nextdir: EBADARG (buffer to small)"));
				return r;
			}
			
			FAT_DEBUG (("__nextdir: (vfat entry, return = %li, index = %li, real = %li)", r, index, dir->real_index));
			/* failure, skip */
		}
		else if ((dir->info->attr & ~FA_VALID) == 0)
		{
			/* a valid entry */
			
			if (name) dir2str (dir->info->name, name);
			return E_OK;
		}
# if 0		/* not neccessary, skipped afterwards */
		else if ((dir->info->attr & (FA_DIR | FA_LABEL)) == FA_LABEL)
		{
			/* the label or an invalid vfat entry */
			
			FAT_DEBUG (("__nextdir: (skip label) index = %li", index));
			/* skip */
		}
# endif
		else
		{
			/* an invalid entry */
			
			FAT_DEBUG (("__nextdir: (skip invalid) index = %li", index));
			/* skip */
		}
	}
	
	FAT_DEBUG (("__nextdir: leave failure (unknown)"));
	return ENMFILES;
}


static long
search_cookie (COOKIE *dir, COOKIE **found, const char *name, int mode)
{
	oDIR odir;
	long r;
	
	FAT_DEBUG (("search_cookie: enter (name = %s)", name));
	
	/* 1. search in COOKIE cache
	 */
	{
		COOKIE *search;
		char *temp = fullname (dir, name);
		if (!temp)
		{
			FAT_DEBUG (("search_cookie: leave failure, out of memory"));
			return ENOMEM;
		}
		
		FAT_DEBUG (("search_cookie: looking for: %s", temp));
		
		search = c_hash_lookup (temp, dir->dev); kfree (temp);
		if (search)
		{
			if (found)
			{
				*found = search;
				search->links++;
			}
			
			FAT_DEBUG (("search_cookie: leave ok, found in table"));
			return E_OK;
		}
	}
	
	/* 2. check negative lookup cache
	 */
	if (dir->lastlookup)
	{
		if (stricmp (name, dir->lastlookup) == 0)
		{
			FAT_DEBUG (("search_cookie: leave not found (extra) (name = %s)", name));
			return ENOENT;
		}
	}
	
	/* 3. search on disk
	 */
	if (mode == 0)
		mode = is_short (name, VFAT (dir->dev) ? MSDOS_TABLE : GEMDOS_TABLE);
	
	r = __opendir (&odir, dir->stcl, dir->dev);
	if (r)
	{
		FAT_DEBUG (("search_cookie: __opendir fail (r = %li)", r));
		return r;
	}
	
	if (mode == TOS_SEARCH)
	{
		/* FAT search on FAT or VFAT */
		
		char fat_name [FAT_NAMEMAX];
		
		str2dir (name, fat_name);
		while ((r = __nextdir (&odir, NULL, 0)) >= 0)
		{
			if (strnicmp (odir.info->name, fat_name, 11) == 0)
			{
				if (found)
				{
					char *temp;
					char buf [VFAT_NAMEMAX];
					
					if (r)
					{
						register long j;
						
						(void) __SEEKDIR (&odir, odir.index - 1, READ);
						j = __nextdir (&odir, buf, VFAT_NAMEMAX);
						if (r != j)
						{
							FAT_ALERT (("fatfs.c: filesystem inconsistent in search_cookie!"));
							
							r = ENOENT;
							goto leave;
						}
					}
					else
					{
						dir2str (odir.info->name, buf);
					}
					
					temp = fullname (dir, buf);
					if (temp == NULL)
					{
						FAT_DEBUG (("search_cookie: out of memory"));
						
						r = ENOMEM;
						goto leave;
					}
					
					if (r)
					{
						*found = c_hash_lookup (temp, dir->dev);
						if (*found)
						{
							(*found)->links++;
							kfree (temp);
							
							FAT_DEBUG (("search_cookie: found in table (FAT search, r = %li)", r));
							
							r = E_OK;
							goto leave;
						}
					}
					
					*found = c_get_cookie (temp);
					if (*found == NULL)
					{
						kfree (temp);
						
						FAT_DEBUG (("search_cookie: c_get_cookie fail!"));
						
						r = ENOMEM;
						goto leave;
					}
					
					(*found)->dev = dir->dev;
					(*found)->rdev = dir->dev;
					(*found)->dir = dir->stcl;
					(*found)->offset = odir.index;
					(*found)->stcl = GET_STCL (odir.info, dir->dev);
					(*found)->flen = le2cpu32 (odir.info->flen);
					(*found)->info = *(odir.info);
					(*found)->slots = r;
				}
				
				FAT_DEBUG (("search_cookie: found (FAT search)"));
				
				r = E_OK;
				goto leave;
			}
		}
	}
	else
	{
		/* VFAT search */
		
		char buf [VFAT_NAMEMAX];
		
		while ((r = __nextdir (&odir, buf, VFAT_NAMEMAX)) >= 0)
		{
			if (stricmp (buf, name) == 0) /* always not casesensitive, yes, right */
			{
				if (found)
				{
					char *temp;
					
					temp = fullname (dir, buf);
					if (temp == NULL)
					{
						FAT_DEBUG (("search_cookie: out of memory"));
						
						r = ENOMEM;
						goto leave;
					}
					
					*found = c_get_cookie (temp);
					if (*found == NULL)
					{
						kfree (temp);
						
						FAT_DEBUG (("search_cookie: c_get_cookie fail!"));
						
						r = ENOMEM;
						goto leave;
					}
					
					(*found)->dev = dir->dev;
					(*found)->rdev = dir->dev;
					(*found)->dir = dir->stcl;
					(*found)->offset = odir.index;
					(*found)->stcl = GET_STCL (odir.info, dir->dev);
					(*found)->flen = le2cpu32 (odir.info->flen);
					(*found)->info = *(odir.info);
					(*found)->slots = r;
				}
				
				FAT_DEBUG (("search_cookie: found (VFAT search)"));
				
				r = E_OK;
				goto leave;
			}
		}
	}
	
	r = ENOENT;
	
	/* 4. update negative lookup cache
	 */
	{
		if (dir->lastlookup)
			kfree (dir->lastlookup);
		
		dir->lastlookup = kmalloc (strlen (name) + 1);
		if (dir->lastlookup)
		{
			strcpy (dir->lastlookup, name);
		}
	}
	
leave:
	__closedir (&odir);
	
	FAT_DEBUG (("search_cookie: leave %s (%li)", r ? "failure" : "ok", r));
	return r;
}

static long
write_cookie (COOKIE *c)
{
	oDIR dir;
	register long r;
	
	FAT_DEBUG (("write_cookie: enter (dir = %li, offset = %li, dev = %i)", c->dir, c->offset, c->dev));
	
	if (c->dir == 0)
	{
		/* ROOT */
		
		FAT_DEBUG (("write_cookie: leave failure (root)"));
		return EACCES;
	}
	
	/* open the dir */
	r = __opendir (&dir, c->dir, c->dev);
	
	r = __seekdir (&dir, c->offset + c->slots, READ);
	if (r < E_OK)
	{
		__closedir (&dir);
		
		FAT_DEBUG (("write_cookie: leave failure (__seekdir)"));
		return r;
	}
	
	/* copy the dirstruct */
	*dir.info = c->info;
	
	__updatedir (&dir);
	__closedir (&dir);
	
	FAT_DEBUG (("write_cookie: leave ok (return E_OK)"));
	return E_OK;
}

static long
delete_cookie (COOKIE *c, long mode)
{
	oDIR dir;
	register long r;
	
	FAT_DEBUG (("delete_cookie: enter (dir = %li, offset = %i, dev = %i)", c->dir, c->offset, c->dev));
	
	if (c->dir == 0)
	{
		/* ROOT */
		
		FAT_DEBUG (("delete_cookie: leave failure (root)"));
		return EACCES;
	}
	
	if (c->links > 1)
	{
		FAT_DEBUG (("delete_cookie: leave failure (cookie in use)"));
		return EACCES;
	}
	
	/* open the dir */
	r = __opendir (&dir, c->dir, c->dev);
	
	/* seek to the right dir */
	r = __seekdir (&dir, c->offset + c->slots, READ);
	if (r < E_OK)
	{
		__closedir (&dir);
		
		FAT_DEBUG (("delete_cookie: leave failure (__seekdir)"));
		return r;
	}
	
	/* invalidate the FAT entry */
	dir.info->name[0] = (char) 0xe5;
	__updatedir (&dir);
	
	/* delete the cluster-chain */
	if (mode && c->stcl) (void) del_chain (c->stcl, c->dev);
	
	if (c->slots)
	{
		/* invalidate the VFAT entrys */
		r = c->slots;
		while (r--)
		{
			(void) __SEEKDIR (&dir, c->offset + r, READ);
			dir.info->name[0] = (char) 0xe5;
			__updatedir (&dir);
		}
	}
	
	__closedir (&dir);
	c_del_cookie (c);
	
	FAT_DEBUG (("delete_cookie: leave ok"));
	return E_OK;
}

INLINE void
copy_to_vfat (LDIR *ldir, register const char *name)
{
	char unicode[26];
	register long i;
	register long slot = ldir->head;
	
	slot = (slot & 0x40) ? slot & ~0x40 : slot;
	slot--;
	name += slot * 13;
	
	FAT_DEBUG (("copy_to_vfat: enter (name = %s, ldir->head = %li)", name, slot));
	
	for (i = 0; *name && i < 25; i += 2)
	{
		ATARI2UNI (*name, unicode + i);
		name++;
	}
	if (i < 25)
	{
		unicode[i++] = '\0';
		unicode[i++] = '\0';
		if (i < 25)
			for (; i < 26; i++)
				unicode[i] = 0xff;
	}
	
	for (i = 0; i < 10; i++)
		ldir->name0_4   [i] = unicode [i];
	for (i = 0; i < 12; i++)
		ldir->name5_10  [i] = unicode [i+10];
	for (i = 0; i < 4; i++)
		ldir->name11_12 [i] = unicode [i+22];
	
	FAT_DEBUG (("copy_to_vfat: leave ok"));
}

# if 0
INLINE void
update_nextslot (register long *nextslot, register long freeslot)
{
	if (*nextslot && *nextslot < freeslot)
		return;
	
	*nextslot = freeslot;
}
# endif

INLINE long
search_free (oDIR *dir, long *pos, long slots)
{
	long r;
	
	r = __seekdir (dir, *pos, WRITE);
	while (r == 0)
	{
		if ((dir->info->name[0] == (char) 0xe5)
			|| (dir->info->name[0] == (char) 0x05))
		{
			/* a deleted entry */
			
			if (slots > 1)
			{
				/* we need more as one, check for more */
				register long tpos = *pos;
				register long searched = slots;
				while (searched-- && (r == 0))
				{
					r = __SEEKDIR (dir, ++tpos, WRITE);
					if (dir->info->name[0] &&
						dir->info->name[0] != (char) 0xe5)
					{
						*pos = tpos;
						break;
					}
				}
				if (((tpos - *pos) == slots) && (r == 0 || r == ENMFILES))
				{
					/* yes, we found enough deleted entrys :-)
					 * seek to the old pos
					 */
					r = __SEEKDIR (dir, *pos, WRITE);
					break;
				}
			}
			else
			{
				/* we only need one */
				break;
			}
		}
		else if (dir->info->name[0] == '\0')
		{
			/* here are the end of the dir */
			break;
		}
		
		/* go to the next entry */
		(*pos)++;
		r = __SEEKDIR (dir, *pos, WRITE);
	}
	
	return r;
}

static long
make_cookie (COOKIE *dir, COOKIE **new, const char *name, int attr)
{
	oDIR odir;
	char shortname[FAT_NAMEMAX];
	char *full;
# if 0
	long pos = dir->nextslot;
# else
	long pos = 0;
# endif
	long vfat;
	long slot;
	long r;
	
	FAT_DEBUG (("make_cookie: enter (name = %s, stcl = %li, pos = %li)", name, dir->stcl, pos));
	
	/* validate the name and make a correkt 8+3 name
	 * if VFAT is enabled and the name is a longname
	 * 'vfat' holds the len of the longname
	 */
	
	vfat = make_shortname (dir, name, shortname);
	FAT_DEBUG (("make_cookie: (8+3 = %s, vfat = %li)", shortname, vfat));
	if (vfat < 0)
	{
		/* invalid name (no vfat) */
		return vfat;
	}
	
	/* clear the negative lookup cache */
	if (dir->lastlookup)
	{
		kfree (dir->lastlookup);
		dir->lastlookup = NULL;
	}
	
	if (vfat)
	{
		/* slots to be filled out */
		vfat = (vfat / 13) + ((vfat % 13) ? 1 : 0);
		FAT_DEBUG (("make_cookie: (slots = %li)", vfat));
	}
	
	r = __opendir (&odir, dir->stcl, dir->dev);
	if (r == E_OK)
		r = search_free (&odir, &pos, vfat ? vfat + 1 : 1);
	
	full = fullname (dir, name);
	*new = c_get_cookie (full);
	
	/* if anything goes wrong we leave here */
	if (r || !full || !*new)
	{
		FAT_DEBUG (("make_cookie: leave failure (r = %li)", r));
		
		if (*new)
		{
			c_del_cookie (*new);
		}
		
		/* close directory */
		__closedir (&odir);
		
		return r;
	}
	
	/* copy the short name to the entry */
	str2dir (shortname, (*new)->info.name);
	
	if (vfat)
	{
		/* a VFAT entry */
		
		/* calculate the checksum */
		register uchar chksum = 0;
		{
			register long i;
			
			for (chksum = i = 0; i < 11; i++)
			{
				chksum = (((chksum & 1) << 7) | ((chksum & 0xfe) >> 1))
					+ (*new)->info.name[i];
			}
		}
		
		FAT_DEBUG (("make_cookie: chksum = %li, pos = %li", (ulong) chksum, pos));
		
		/* now we write the VFAT entrys */
		slot = 0;
		while (slot < vfat)
		{
			register LDIR *ldir = (LDIR *) odir.info;
			
			FAT_DEBUG (("make_cookie: writing VFAT, slot = %li", slot));
			
			/* fill out the slot */
			ldir->head = vfat - slot; if (slot == 0) ldir->head |= 0x40;
			ldir->attr = FA_VFAT;
			ldir->unused = 0;
			ldir->stcl = 0;
			ldir->chksum = chksum;
			copy_to_vfat (ldir, name);
			
			__updatedir (&odir);
			
			r = __SEEKDIR (&odir, pos + slot + 1, WRITE);
			if (r)
			{
				FAT_DEBUG (("make_cookie: leave failure (__seekdir = %li)", r));
				
				/* remove from cache */
				c_del_cookie (*new);
				
				/* close directory */
				__closedir (&odir);
				
				return r;
			}
			
			slot++;
		}
	}
	
	/* now make the FAT entry
	 */
	(*new)->info.attr = attr;
	(*new)->info.lcase = 0;
	(*new)->info.ctime_ms = 0;
	(*new)->info.ctime = cpu2le16 (timestamp);
	(*new)->info.cdate = cpu2le16 (datestamp);
	(*new)->info.adate = (*new)->info.cdate;
	(*new)->info.stcl_fat32 = 0;
	(*new)->info.time = (*new)->info.ctime;
	(*new)->info.date = (*new)->info.cdate;
	(*new)->info.stcl = 0;
	(*new)->info.flen = 0;
	
	/* validate the cookie
	 */
	(*new)->dev = dir->dev;
	(*new)->rdev = dir->dev;
	(*new)->dir = dir->stcl;
	(*new)->offset = pos;
	(*new)->stcl = 0;
	(*new)->flen = 0;
	(*new)->slots = vfat;
	
	*(odir.info) = (*new)->info;
	
	__updatedir (&odir);
	__closedir (&odir);
	
	FAT_DEBUG (("make_cookie: leave E_OK"));
	return E_OK;
}

/* END DIR part */
/****************************************************************************/

/****************************************************************************/
/* BEGIN init & configuration part */

void
fatfs_init (void)
{
	long i;
	
	/* binary check */
	if (sizeof (_DIR) != 32 || sizeof (LDIR) != 32)
	{
		FATAL (__FILE__ ": "
			"Internal error! "
			"Compiler problem (sizeof (_DIR) != 32).");
	}
	
	/* internal init */
	for (i = 0; i < NUM_DRIVES; i++)
	{
		/* zero devinfo */
		BPB (i) = NULL;
		BPBVALID (i) = INVALID;
		
		/* VFAT extension disabled by default */
		VFAT (i) = DISABLE;
		
		/* symbolic link configuration default on */
		SLNK (i) = ENABLE;
		
		/* new name mode configuration default to GEMDOS */
		NAME_MODE (i) = GEMDOS;
		DEFAULT_T (i) = GEMDOS_TABLE;
		
		/* default root permissions */
		ROOT_UID (i) = 0;			/* user  0 */
		ROOT_GID (i) = 0;			/* group 0 */
		ROOT_MODE (i) = FATFS_DEFAULT_MODE;
		
# ifdef FATFS_TESTING
		/* no test partition for default */
		TEST_PART (i) = DISABLE;
# endif
# ifdef FS_DEBUG
		C_HIT (i) = 0;
		C_MISS (i) = 0;
# endif
	}
	
	boot_print (FATFS_BOOT);
	boot_print (FATFS_GREET);
}

long
fatfs_config (const ushort drv, const long config, const long mode)
{
	if (drv >= NUM_DRIVES)
	{
		return EBADARG;
	}
	
	switch (config)
	{
		case FATFS_VFAT:
		{
			if (mode == ASK)
			{
				return VFAT (drv);
			}
			
			VFAT (drv) = mode ? ENABLE : DISABLE;
			
			if (VFAT (drv))
			{
				NAME_MODE (drv) = MSDOS;
				DEFAULT_T (drv) = MSDOS_TABLE;
			}
			else
			{
				NAME_MODE (drv) = GEMDOS;
				DEFAULT_T (drv) = GEMDOS_TABLE;
			}
			
			return E_OK;
		}
		case FATFS_VCASE:
		{
			if (mode == ASK)
			{
				return LCASE (drv);
			}
			
			LCASE (drv) = mode ? ENABLE : DISABLE;
			
			return E_OK;
		}
		case FATFS_SECURE:
		{
			long smode;
			long i;
			
			switch (mode)
			{
				case 0:
				{
					smode = FATFS_SECURE_0;
					break;
				}
				case 1:
				{
					smode = FATFS_SECURE_1;
					break;
				}
				case 2:
				{
					smode = FATFS_SECURE_2;
					break;
				}
				default:
				{
					return EBADARG;
				}
			}
			
			for (i = 0; i < NUM_DRIVES; i++)
			{
				ROOT_UID (i) = 0;
				ROOT_GID (i) = 0;
				ROOT_MODE (i) = smode;
			}
			
			return E_OK;
		}
# ifdef FS_DEBUG
		case FATFS_DEBUG:
		{
			(void) bio.config (drv, BIO_DEBUGLOG, mode);
			fatfs_debug_mode = mode;
			
			return E_OK;
		}
		case FATFS_DEBUG_T:
		{
			FAT_DEBUG_HASH (());
			
			return E_OK;
		}
# endif
# ifdef FATFS_TESTING
		case FATFS_DRV:
		{
			if (mode == ASK)
			{
				return TEST_PART (drv);
			}
			
			TEST_PART (drv) = mode ? ENABLE : DISABLE;
			
			return E_OK;
		}
# endif
	}
	
	/* failure */
	return ENOSYS;
}

/* END init & configuration part */
/****************************************************************************/

/****************************************************************************/
/* BEGIN special FAT32 extension */

INLINE void
upd_fat32fats (register const ushort dev, long reference)
{
	long i;
	for (i = 0; i < FATSIZE (dev); i++)
	{
		UNIT *u = bio_fat_read (dev, DI (dev), reference + i, SECSIZE (dev));
		if (u)
		{
			long j;
			
			bio.lock (u);
			
			for (j = 0; j <= FAT2ON (dev); j++)
			{
				long start = FATSTART (dev) + j * FATSIZE (dev);
				if (start != reference)
				{
					UNIT *mirr = bio_fat_getunit (dev, DI (dev), start + i, SECSIZE (dev));
					if (mirr)
					{
						quickmove (mirr->data, u->data, SECSIZE (dev));
						bio_MARK_MODIFIED (&(bio), mirr);
					}
				}
			}
			
			bio.unlock (u);
		}
	}
}

INLINE void
upd_fat32boot (register const ushort dev)
{
	UNIT *u = bio_boot_read (DI (dev), 0, DI (dev)->pssize);
	if (u)
	{
		_F32_BS *f32bs = (_F32_BS *) u->data;
		ushort temp;
		ushort i = 0;
		
		if (!FAT32mirr (dev))
		{
			temp = FAT32prim (dev);
			temp -= FATSTART (dev);
			temp /= FATSIZE (dev);
			i |= (temp & FAT32_ActiveFAT_Mask);
			i |= FAT32_NoFAT_Mirror;
		}
		
		f32bs->flags = cpu2le16 (i);
		
		bio_MARK_MODIFIED ((&bio), u);
	}
}

INLINE void
val_fat32info (register const ushort dev)
{
	if (FAT32info (dev))
	{
		FREECL (dev) = le2cpu32 (FAT32info (dev)->free_clusters);
		LASTALLOC (dev) = le2cpu32 (FAT32info (dev)->next_cluster);
		
		FAT_DEBUG (("val_fat32info [%c]: free_clusters = %li, next_cluster = %li", dev+'A', FREECL (dev), LASTALLOC (dev)));
		
		/* validation of FREECL */
		if (FREECL (dev) >= CLUSTER (dev))
		{
			/* set it to -1;
			 * that means FREECL isn't known
			 */
			FREECL (dev) = -1;
		}
		
		/* validation of LASTALLOC */
		if (LASTALLOC (dev) < FAT32_ROFF || LASTALLOC (dev) >= MAXCL (dev))
		{
			/* set to first cluster after reserved
			 * root dir cluster
			 */
			LASTALLOC (dev) = FAT32_ROFF;
		}
	}
}

INLINE void
inv_fat32info (register const ushort dev)
{
	if (RDONLY (dev))
		return;
	
	if (FAT32info (dev))
	{
		FAT32info (dev)->free_clusters = cpu2le32 (-1L);
		FAT32info (dev)->next_cluster = cpu2le32 (FAT32_ROFF);
		
		bio_MARK_MODIFIED ((&bio), FAT32infu (dev));
	}
}

INLINE void
upd_fat32info (register const ushort dev)
{
	if (RDONLY (dev))
		return;
	
	if (FAT32info (dev))
	{
		register long i = cpu2le32 (FREECL (dev));
		register long j = cpu2le32 (LASTALLOC (dev));
		
		if (i != FAT32info (dev)->free_clusters
			|| j != FAT32info (dev)->next_cluster)
		{
			FAT32info (dev)->free_clusters = i;
			FAT32info (dev)->next_cluster = j;
			
			bio_MARK_MODIFIED ((&bio), FAT32infu (dev));
		}
	}
}

/* END special FAT32 extension */
/****************************************************************************/

/****************************************************************************/
/* BEGIN device info */

/* val_bpb and get_bpb are only used in one place
 * so we can inline to save two extra functions
 */

INLINE long
val_bpb (_x_BPB *xbpb, ushort drv)
{
	/* ask every time -> dynamic reconfiguration */
	long max = bio.config (0, BIO_MAX_BLOCK, 0);
	
	FAT_DEBUG (("val_bpb: enter (max = %li)", max));
	
	if (xbpb->clsizb > max)
	{
		FAT_ALERT (("FATFS [%c]: unitsize (%li) to small (clsizb = %li)!", 'A'+drv, max, xbpb->clsizb));
		FAT_ALERT (("FATFS [%c]: medium access rejected", 'A'+drv));
		return ENXIO;
	}
	
	/*
	 * other checks:
	 */
	
	/* fat type */
	if (xbpb->ftype != FAT_TYPE_12
		&& xbpb->ftype != FAT_TYPE_16
		&& xbpb->ftype != FAT_TYPE_32)
	{
		FAT_ALERT (("FATFS [%c]: unknown FAT type (ftype = %i)!", 'A'+drv, xbpb->ftype));
		FAT_ALERT (("FATFS [%c]: medium access rejected", 'A'+drv));
		return EMEDIUMTYPE;
	}
	
	/* vital values */
	if (xbpb->recsiz & (512 - 1)
		|| xbpb->recsiz == 0
		|| xbpb->numcl  == 0)
	{
		FAT_ALERT (("FATFS [%c]: illegal vital data (recsiz = %li, numcl = %li)", 'A'+drv, xbpb->recsiz, xbpb->numcl));
		FAT_ALERT (("FATFS [%c]: medium access rejected", 'A'+drv));
		return EMEDIUMTYPE;
	}
	
	/* root directory size */
	if (xbpb->ftype == FAT_TYPE_32)
	{
		if (xbpb->rdlen != 0
			|| xbpb->rdrec < 2
			|| xbpb->rdrec > xbpb->numcl + 1)
		{
			FAT_ALERT (("FATFS [%c]: illegal root directory cluster (rdlen = %ld, rdstart = %ld)", 'A'+drv, xbpb->rdlen, xbpb->rdrec));
			FAT_ALERT (("FATFS [%c]: medium access rejected", 'A'+drv));
			return EMEDIUMTYPE;
		}
	}
	else 
	{
		if (xbpb->rdlen == 0)
		{
			FAT_ALERT (("FATFS [%c]: illegal root directory len (rdlen = %li)", 'A'+drv, xbpb->rdlen));
			FAT_ALERT (("FATFS [%c]: medium access rejected", 'A'+drv));
			return EMEDIUMTYPE;
		}
	}
	
	/* number of clusters */
	if ((xbpb->ftype == FAT_TYPE_12 && xbpb->numcl >= 0x0000fefL)
		|| (xbpb->ftype == FAT_TYPE_16 && xbpb->numcl >= 0x000ffefL)
		|| (xbpb->ftype == FAT_TYPE_32 && xbpb->numcl >= 0xfffffefL))
	{
		FAT_ALERT (("FATFS [%c]: illgeal number of clusters (%li - %s-bit FAT)", 'A'+drv, xbpb->numcl,
				(xbpb->ftype == FAT_TYPE_12) ? "12" :
					(xbpb->ftype == FAT_TYPE_16) ? "16" : "32"
		));
		FAT_ALERT (("FATFS [%c]: medium access rejected", 'A'+drv));
		return EMEDIUMTYPE;
	}
	
	/* size of FAT */
	{
		ulong minfat = xbpb->numcl + 2;	/* size in cluster */
		
		switch (xbpb->ftype)
		{
			case FAT_TYPE_12:	minfat *= 12;	/* in bits */
						break;
			case FAT_TYPE_16:	minfat <<= 4;	/* in bits */
						break;
			case FAT_TYPE_32:	minfat <<= 5;	/* in bits */
						break;
		}
		minfat >>= 3; /* in bytes */
		
		minfat += xbpb->recsiz - 1L;
		minfat /= xbpb->recsiz;
		
		if (minfat > xbpb->fsiz)
		{
			FAT_ALERT (("FATFS [%c]: FAT too small (FAT size = %li, minfat = %li)", 'A'+drv, xbpb->fsiz, minfat));
			FAT_ALERT (("FATFS [%c]: medium access rejected", 'A'+drv));
			return EMEDIUMTYPE;
		}
	}
	
	/* special FAT32 checks */
	if (xbpb->ftype == FAT_TYPE_32)
	{
		/* anyone has a good idea?
		 */
	}
	
	FAT_DEBUG (("val_bpb: leave ok"));
	
	/* device ok */
	return E_OK;
}

INLINE long
get_bpb (_x_BPB *xbpb, DI *di)
{
	_F_BS *fbs;
	_F32_BS *f32bs;
	_F_VI *fvi;
	
	UNIT *u;
	long r;
	
	FAT_DEBUG (("get_bpb: enter (drv = %i)", di->drv));
	
	
	/* read boot sector */
	u = bio_boot_read (di, 0, di->pssize);
	if (!u)
	{
		FAT_DEBUG (("get_bpb: bio_boot_read fail, leave EBUSY"));
		return EBUSY;
	}
	
	
	fbs = (void *) u->data;
	f32bs = (void *) u->data;
	
	FAT_DEBUG (("get_bpb: fbs:"));
	FAT_DEBUG (("get_bpb: sector_size = %u", WPEEK_INTEL (fbs->sector_size));
	FAT_DEBUG (("get_bpb: cluster_size = %u", (ushort) fbs->cluster_size)));
	FAT_DEBUG (("get_bpb: reserved = %u", le2cpu16 (fbs->reserved)));
	FAT_DEBUG (("get_bpb: fats = %u", (ushort) fbs->fats));
	FAT_DEBUG (("get_bpb: dir_entries = %u", WPEEK_INTEL (fbs->dir_entries)));
	FAT_DEBUG (("get_bpb: sectors = %u", WPEEK_INTEL (fbs->sectors)));
	FAT_DEBUG (("get_bpb: fat_length = %u", le2cpu16 (fbs->fat_length)));
	FAT_DEBUG (("get_bpb: total_sect = %lu", le2cpu32 (fbs->total_sect)));
	FAT_DEBUG (("get_bpb: secs_track = %u", le2cpu16 (fbs->secs_track)));
	FAT_DEBUG (("get_bpb: heads = %lu", le2cpu16 (fbs->heads)));
	FAT_DEBUG (("get_bpb: hidden = %lu", le2cpu32 (fbs->hidden)));
	FAT_DEBUG (("get_bpb: media = %x", (ushort) (fbs->media)));
	
	FAT_DEBUG (("get_bpb: f32bs:"));
	FAT_DEBUG (("get_bpb: fat32_length = %lu", le2cpu32 (f32bs->fat32_length)));
	FAT_DEBUG (("get_bpb: flags = %x", le2cpu16 (f32bs->flags)));
	FAT_DEBUG (("get_bpb: root_cluster = %lu", le2cpu32 (f32bs->root_cluster)));
	FAT_DEBUG (("get_bpb: info_sector = %u", le2cpu16 (f32bs->info_sector)));
	FAT_DEBUG (("get_bpb: backup_boot = %u", le2cpu16 (f32bs->backup_boot)));
	
	
	xbpb->ftype = FAT_INVALID;
	
	/*
	 * step 1: check for GEM/BGM partition
	 */
	
	if ((di->id [0] == 'B' && di->id [1] == 'G' && di->id [2] == 'M')
		|| (di->id [0] == 'G' && di->id [1] == 'E' && di->id [2] == 'M'))
	{
		FAT_DEBUG (("get_bpb: GEM/BGM detected"));
		
		xbpb->ftype = FAT_TYPE_16;
		fvi = (void *) (u->data + sizeof (*fbs));
	}
	else
	
	/*
	 * step 2: check for F32 partition
	 */
	
	if (di->id [0] == 'F' && di->id [1] == '3' && di->id [2] == '2')
	{
		FAT_DEBUG (("get_bpb: F32 detected"));
		
		xbpb->ftype = FAT_TYPE_32;
		fvi = (void *) (u->data + sizeof (*f32bs));
	}
	else
	
	/*
	 * step 3: check for dos medium (supported signs: 0x04, 0x06, 0x0b, 0x0c, 0x0e)
	 */
	
	if (di->id [0] == '\0' && di->id [1] == 'D')
	{		
		FAT_DEBUG (("get_bpb: DOS medium detected (%x)", (int) (di->id [2])));
		
		/* check media descriptor (must be 0xf8 on harddisks) */
		if (fbs->media != 0xf8)
		{
			FAT_ALERT (("fatfs.c: get_bpb: unknown media deskriptor (%x) on %c (ID = %x)", (int) fbs->media, 'A'+di->drv, (int) (di->id [2])));
		}
		
		switch (di->id [2])
		{
			case 0x04:
			case 0x06:
			case 0x0e: /* FAT16, partially or completely above sector 16,450,559 (DOS-limit for CHS access) */
			{
				xbpb->ftype = FAT_TYPE_16;
				fvi = (void *) (u->data + sizeof (*fbs));
				break;
			}
			case 0x0b:
			case 0x0c: /* FAT32, partially or completely above sector 16,450,559 (DOS-limit for CHS access) */
			{
				xbpb->ftype = FAT_TYPE_32;
				fvi = (void *) (u->data + sizeof (*f32bs));
				break;
			}
			default:
			{
				FAT_FORCE (("fatfs.c: get_bpb: DOS partition type not supported (%x) on %c", (int) (di->id [2]), 'A'+di->drv));
				FAT_DEBUG (("get_bpb: unknown DOS partition type (%x)", (int) (di->id [2])));
				return EMEDIUMTYPE;
			}
		}
	}
	else
	
	/*
	 * step 4: check for NULL partition (A, B or other BIOS device)
	 */
	
	if (di->id [0] == '\0' && di->id [1] == '\0' && di->id [2] == '\0')
	{
		FAT_DEBUG (("get_bpb: \\0\\0\\0 detected"));
		
		if (di->drv == 0 || di->drv == 1)
		{
			/* assume FAT12 disk medium through BIOS ??? */
			xbpb->ftype = FAT_TYPE_12;
			
			FAT_DEBUG (("get_bpb: assume FAT12 (BIOS)"));
		}
		else
		{
			/* assume FAT16 TOS partition through BIOS */
			xbpb->ftype = FAT_TYPE_16;
			
			FAT_DEBUG (("get_bpb: assume FAT16 (BIOS)"));
		}
	}
	else
	
	/*
	 * this can't be a FAT partition
	 */
		return EMEDIUMTYPE;
	
	
	xbpb->recsiz = WPEEK_INTEL (fbs->sector_size);
	xbpb->clsiz = fbs->cluster_size;
	xbpb->clsizb = xbpb->recsiz * xbpb->clsiz;
	
# if 1
	xbpb->rdlen = (WPEEK_INTEL (fbs->dir_entries) * 32L + xbpb->recsiz - 1) / xbpb->recsiz;
# else
	xbpb->rdlen = (WPEEK_INTEL (fbs->dir_entries) * 32L) / xbpb->recsiz;
	if ((xbpb->rdlen == 0)
		&& (WPEEK_INTEL (fbs->dir_entries) == 256)
		&& (xbpb->recsiz >= 16384))
	{
		FAT_ALERT (("FATFS [%c]: WARNING: dir_entries have illegal value 256!", 'A'+di->drv));
		FAT_ALERT (("FATFS [%c]: Please correct your partition!", 'A'+di->drv));
		xbpb->rdlen = 1;
	}
# endif
	
	xbpb->fatrec = le2cpu16 (fbs->reserved);
	xbpb->fats = fbs->fats;
	
	switch (xbpb->ftype)
	{
		case FAT_TYPE_12:
		case FAT_TYPE_16:
		{
			xbpb->fsiz = le2cpu16 (fbs->fat_length);
			
			xbpb->rdrec = xbpb->fatrec + xbpb->fsiz * xbpb->fats;
			xbpb->datrec = xbpb->rdrec + xbpb->rdlen;
			
			break;
		}
		case FAT_TYPE_32:
		{
			xbpb->fsiz = le2cpu32 (f32bs->fat32_length);
			
			xbpb->rdrec = le2cpu32 (f32bs->root_cluster);
			xbpb->datrec = xbpb->fatrec + xbpb->fsiz * xbpb->fats;
			
			break;
		}
	}
	
	if (WPEEK_INTEL (fbs->sectors))
	{
		xbpb->numcl = WPEEK_INTEL (fbs->sectors);
	}
	else
	{
		xbpb->numcl = le2cpu32 (fbs->total_sect);
	}
	
	xbpb->numcl -= xbpb->datrec;
	xbpb->numcl /= xbpb->clsiz;
	
	if (xbpb->ftype == FAT_TYPE_32)
	{
		xbpb->fflag = le2cpu16 (f32bs->flags);
		xbpb->info = le2cpu16 (f32bs->info_sector);
		xbpb->version = le2cpu16 (f32bs->version);
		
		if (xbpb->info >= le2cpu16 (fbs->reserved))
		{
			xbpb->info = 0;
		}
	}
	
	xbpb->fats--;
	
	/* validate device informations */
	r = val_bpb (xbpb, di->drv);
	
	if (r == E_OK)
	{
		/* update logical sectorsize for block_IO wrapper */
		bio.set_lshift (di, xbpb->recsiz);
	}
	
	FAT_DEBUG (("get_bpb: val_bpb = %li", r));
	return r;
}

static DEVINFO *
get_devinfo (const ushort drv, long *err)
{
	DI *di;
	
	_x_BPB xbpb;
	_x_BPB *t = &xbpb;
	
	FAT_DEBUG (("get_devinfo: enter (drv = %i -> %c)", drv, 'A'+drv));
	
	if (BPBVALID (drv) == VALID)
	{
		*err = E_OK;
		
		FAT_DEBUG (("get_devinfo: leave ok (VALID)"));
		return BPB (drv);
	}
	
	di = bio.get_di (drv);
	if (!di)
	{
		*err = EBUSY;
		
		FAT_DEBUG (("get_devinfo: leave (bio.get_di fail -> EBUSY)"));
		return NULL;
	}
	
	BPB (drv) = kmalloc (sizeof (*BPB (drv)));
	if (!BPB (drv))
	{
		bio.free_di (di);
		*err = ENOMEM;
		
		FAT_ALERT (("fatfs.c: kmalloc fail in: get_devinfo for BPB (%i)", drv));
		return NULL;
	}
	
	/* initialize the complete area with 0 */
	bzero (BPB (drv), sizeof (*BPB (drv)));
	
	*err = get_bpb (t, di);
	if (*err == E_OK)
	{
		DEVINFO *d = BPB (drv);
		
		
		d->di		= di;
		
		d->rdonly	= BIO_WP_CHECK (di);
		d->res		= 0;
		
		d->recsiz	= t->recsiz;
		d->clsiz	= t->clsiz;
		d->clsizb	= t->clsizb;
		d->fstart	= t->fatrec;
		d->fend		= t->fatrec + t->fsiz * (t->fats + 1) - 1;
		d->flen		= t->fsiz;
		d->rdstart	= t->rdrec;
		d->rdlen	= t->rdlen;
		d->rdentrys	= t->rdlen * (t->recsiz >> 5); /* (t->recsiz / 32); */
		d->dstart	= t->datrec;
		d->doffset	= t->datrec - 2 * t->clsiz; /* the first cluster has the number 2 */
		d->numcl	= t->numcl;
		d->maxcl	= t->numcl + 2;
		d->entrys	= t->clsizb >> 5; /* t->clsizb / 32 */;
		
		/* initialize root cookie
		 * (all values are here NULL from previous zero)
		 */
		d->root.dev = drv;
		d->root.rdev = drv;
		d->root.stcl = 1;
		d->root.info.attr = FA_DIR;
		d->root.info.time = cpu2le16 (timestamp);
		d->root.info.date = cpu2le16 (datestamp);
		
		d->freecl	= -1; /* unknown */
		d->fat2on	= t->fats;
		
		switch (t->ftype)
		{
			case FAT_TYPE_12:
			{
				d->ftype	= FAT_TYPE_12;
				
				d->getcl	= getcl12;
				d->fixcl	= fixcl12;
				d->newcl	= newcl12;
				d->ffree	= ffree12;
				d->lastcl	= 2;
				
				break;
			}
			case FAT_TYPE_16:
			{
				d->ftype	= FAT_TYPE_16;
				
				d->getcl	= getcl16;
				d->fixcl	= fixcl16;
				d->newcl	= newcl16;
				d->ffree	= ffree16;
				d->lastcl	= 2;
				
				break;
			}
			case FAT_TYPE_32:
			{
				d->ftype	= FAT_TYPE_32;
				
				d->getcl	= getcl32;
				d->fixcl	= fixcl32;
				d->newcl	= newcl32;
				d->ffree	= ffree32;
				d->lastcl	= FAT32_ROFF;
				
				d->root.stcl	= t->rdrec;
				PUT32_STCL (&(d->root.info), t->rdrec);
				
				/* FAT stuff
				 */
				d->fmirroring	= t->fflag & FAT32_NoFAT_Mirror;
				d->actual_fat	= t->fflag & FAT32_ActiveFAT_Mask;
				
				if (d->fmirroring)	/* disabled, setup up primary FAT */
				{
					if (d->actual_fat <= t->fats)
					{
						d->fmirroring = DISABLE;
						d->actual_fat *= d->flen;
						d->actual_fat += d->fstart;
					}
				}
				else			/* enabled */
				{
					d->fmirroring = ENABLE;
				}
				
				if (d->fmirroring)	/* enabled, primary FAT = first FAT */
				{
					d->actual_fat = d->fstart;
				}
				
				/* info sector stuff
				 */
				if (!t->info)
				{
					d->info_unit = NULL;
					d->info = NULL;
				}
				else
				{
					d->info_unit = bio.get_resident (di, t->info, di->pssize);
					if (d->info_unit)
					{
						d->info = (_FAT32_BFSINFO *) (d->info_unit->data + _FAT32_BFSINFO_OFF);
						if (!(d->info->signature == cpu2le32 (FAT32_FSINFOSIG)))
							d->info = NULL;
					}
					else
						d->info = NULL;
				}
				
				val_fat32info (drv);
				
				break;
			}
		}
		
		FAT_DEBUG ((
			"%c -> recsize = %ld x clsiz = %ld -> clsizb = %ld\r\n"
			"rdstart = %ld, rdlen = %ld\r\n"
			"dstart = %ld, numcl = %ld",
			'A'+drv, d->recsiz, d->clsiz, d->clsizb,
			d->rdstart, d->rdlen,
			d->dstart, d->numcl
		));
		FAT_DEBUG (("fstart = %ld, fend = %ld, flen = %ld", d->fstart, d->fend, d->flen));
		FAT_DEBUG (("fat2on = %d, ftype = %d", d->fat2on, d->ftype));
		
		BPBVALID (drv) = VALID;
		
		FAT_DEBUG (("get_devinfo: leave ok"));
		return d;
	}
	
	bio.free_di (di);
	BPBVALID (drv) = INVALID;
	kfree (BPB (drv)); BPB (drv) = NULL;
	
	FAT_DEBUG (("get_devinfo: leave (get_bpb fail, *err = %li)", *err));
	return NULL;
}

/* END device info part */
/****************************************************************************/

/****************************************************************************/
/* BEGIN filesystem */

static long _cdecl
fatfs_root (int drv, fcookie *fc)
{
	long r = ENXIO;
	
	FAT_DEBUG (("fatfs_root: enter"));
	
# ifdef FATFS_TESTING
	if (TEST_PART (drv))
# endif
	{
		DEVINFO *a;
		
		if (drv == 0 || drv == 1)
		{
			/* verify that only A or B is active */
			
			register long check = drv ? 0 : 1;
			
			if (BPBVALID (check))
			{
				bio.sync_drv (DI (check));
				
				/* crash bug from ulrich? */
				/* fatfs_dskchng (check, 1); */
			}
		}
		
		a = get_devinfo (drv, &r);
		if (a)
		{
			FAT_ASSERT ((r == E_OK));
			
			/* nice, make a fcookie for the kernel */
			
			fc->fs = &fatfs_filesys;
			fc->dev = drv;
			fc->aux = 0;
			fc->index = (long) RCOOKIE (drv); RCOOKIE (drv)->links++;
			
			FAT_DEBUG (("fatfs_root: drive %d active", drv));
			return E_OK;
		}
		
		FAT_DEBUG (("fatfs_root: get_devinfo fail"));
	}
	
	fc->fs = NULL;
	
	FAT_DEBUG (("fatfs_root: return ENXIO (drive %c)", 'A'+drv));
	return r;
}

static long _cdecl
fatfs_lookup (fcookie *dir, const char *name, fcookie *fc)
{
	COOKIE *c = (COOKIE *) dir->index;
	
	FAT_DEBUG (("fatfs_lookup [%s]: enter (c->dir = %li, %s)", c->name, c->dir, name));
	
	/* 1 - itself */
	if (!*name || (name[0] == '.' && name[1] == '\0'))
	{	
		c->links++;
		*fc = *dir;
		
		FAT_DEBUG (("fatfs_lookup: leave ok, (name = \".\")"));
		return E_OK;
	}
	
	/* 2 - parent dir */
	if (name[0] == '.' && name[1] == '.' && name[2] == '\0')
	{
		char *temp = NULL;
		
		if (c->dir == 0)
		{
			/* special case: no parent, ROOT itself */
			
			*fc = *dir;
			
			FAT_DEBUG (("fatfs_lookup: leave ok, EMOUNT, (name = \"..\")"));
			return EMOUNT;
		}
		
		if (c->dir == RCOOKIE (c->dev)->stcl)
		{
			/* special case: parent is ROOT DIR */
			
			fc->fs = &fatfs_filesys;
			fc->dev = c->dev;
			fc->aux = 0;
			fc->index = (long) RCOOKIE (c->dev); RCOOKIE (c->dev)->links++;
			
			FAT_DEBUG (("fatfs_lookup: leave ok, ROOT DIR, (name = \"..\")"));
			return E_OK;
		}
		
		
		/* normal case: parent is a SUB DIR */
		
		{	/* calculate parent path */
			
			register long i = strlen (c->name);
			
			i--;
			while (i--)
			{
				if (c->name [i] == '\\')
				{
					temp = kmalloc (i + 1);
					if (!temp)
					{
						FAT_DEBUG (("fatfs_lookup: leave failure (out of memory)"));
						return ENOMEM;
					}
					
					strncpy_f (temp, c->name, i + 1);
					
					break;
				}
			}
			
			FAT_ASSERT ((i > 0));
		}
		
		{	/* 1. search in INODE cache */
			
			COOKIE *search;
			
			search = c_hash_lookup (temp, c->dev);
			if (search)
			{
				kfree (temp);
				
				fc->fs = &fatfs_filesys;
				fc->dev = c->dev;
				fc->aux = 0;
				fc->index = (long) search;
				
				search->links++;
				
				FAT_DEBUG (("fatfs_lookup: leave ok, found in table"));
				return E_OK;
			}
		}
		
		{	/* 2. search on disk */
			
			oDIR odir;
			long stcl = 0;
			long r;
			
			r = __opendir (&odir, c->dir, c->dev);
			if (r == E_OK)
			{
				r = __seekdir (&odir, 1, READ);
				if (r == E_OK)
				{
					if (strncmp (odir.info->name, "..         ", 11) == 0)
					{
						stcl = GET_STCL (odir.info, odir.dev);
						if (stcl == 0)
							stcl = 1;
					}
					else
					{
						FAT_DEBUG (("fatfs_lookup: '..' not found?"));
						r = ENOENT;
					}
				}
				
				__closedir (&odir);
			}
			
			if (r == E_OK)
			{
				r = __opendir (&odir, stcl, c->dev);
				if (r == E_OK)
				{
					char buf [VFAT_NAMEMAX];
					
					while ((r = __nextdir (&odir, buf, VFAT_NAMEMAX)) >= 0)
					{
						if (GET_STCL (odir.info, c->dev) == c->dir)
						{
							COOKIE *found;
							
							FAT_DEBUG (("fatfs_lookup: make COOKIE [%s] -> %s", temp, buf));
							
							found = c_get_cookie (temp);
							if (!found)
							{
								r = ENOMEM;
								break;
							}

							temp = NULL;

							found->dev = c->dev;
							found->rdev = c->dev;
							found->dir = stcl;
							found->offset = odir.index;
							found->stcl = GET_STCL (odir.info, c->dev);
							found->flen = le2cpu32 (odir.info->flen);
							found->info = *(odir.info);
							found->slots = r;
							
							fc->fs = &fatfs_filesys;
							fc->dev = c->dev;
							fc->aux = 0;
							fc->index = (long) found;
							
							r = E_OK;
							break;
						}
					}
					
					__closedir (&odir);
				}
			}
			
			if (temp) kfree (temp);
			
			FAT_DEBUG (("fatfs_lookup: leave %li, SUB DIR, (name = \"..\")", r));
			return r;
		}
	}
	
	/* 3 - normal name */
	{
		COOKIE *search;
		register long r;
		
		r = search_cookie (c, &search, name, 0);
		if (r == E_OK)
		{
			fc->fs = &fatfs_filesys;
			fc->dev = c->dev;
			fc->aux = 0;
			fc->index = (long) search;
		}
		
		FAT_DEBUG (("fatfs_lookup: leave (r = %li)", r));
		return r;
	}
}

static DEVDRV * _cdecl
fatfs_getdev (fcookie *fc, long *devsp)
{
	FAT_DEBUG (("fatfs_getdev [%s]: ok", ((COOKIE *) fc->index)->name));
	
	if (fc->fs == &fatfs_filesys) return &fatfs_device;
	
	FAT_DEBUG (("fatfs_getdev: leave failure"));
	*devsp = ENOSYS;
	return NULL;
}

static long _cdecl
fatfs_getxattr (fcookie *fc, XATTR *xattr)
{
	COOKIE *c = (COOKIE *) fc->index;
	
	FAT_DEBUG (("fatfs_getxattr [%s]: enter", c->name));
	FAT_DEBUG_COOKIE ((c));
	
	xattr->index	= INDEX (c);
	xattr->dev	= c->dev;
	xattr->rdev	= c->rdev;
	
	xattr->uid	= ROOT_UID (c->dev);
	xattr->gid	= ROOT_GID (c->dev);
	
	xattr->blksize	= CLUSTSIZE (c->dev);
	xattr->nlink	= 1;
	
	if (c->info.attr & FA_DIR)
	{
		xattr->mode	= S_IFDIR;
		
		if (c->stcl == 1)
		{
			/* rootdir have fixed values */
			xattr->blksize	= SECSIZE (c->dev);
			xattr->nblocks	= ROOTSIZE (c->dev);
		}
		else
		{
# ifdef EXTENSIVE_GETXATTR
			register long cluster = c->stcl;
			
			xattr->nblocks	= 0;
			do {
				xattr->nblocks++;
			}
			while ((cluster = GETCL (cluster, c->dev, 1)) > 0);
# else
			xattr->nblocks	= 1;
# endif
			xattr->nlink	= 2; /* subdirs have 2 links */
		}
		
		xattr->size = xattr->blksize * xattr->nblocks;
	}
	else
	{
		xattr->mode	= S_IFREG;
		
		xattr->size	= c->flen;
		xattr->nblocks	= (xattr->size + xattr->blksize - 1) / xattr->blksize;
	}
	
	xattr->mode |= (ROOT_MODE (c->dev) & DEFAULT_DIRMODE);
	
	if (!(c->info.attr & FA_DIR))
	{
		if (!is_exec (c->info.name + 8))
		{
			xattr->mode &= ~(S_IXUSR | S_IXGRP | S_IXOTH);
		}
	}
	
	if (c->info.attr & FA_RDONLY)
	{
		xattr->mode &= ~(S_IWUSR | S_IWGRP | S_IWOTH);
	}
	
	if (c->info.attr == FA_SYMLINK)
	{
		xattr->mode = S_IFLNK | 0777;
	}
	
	xattr->mtime	= le2cpu16 (c->info.time);
	xattr->mdate	= le2cpu16 (c->info.date);
	xattr->atime	= xattr->mtime; 
	xattr->adate	= c->info.adate ? le2cpu16 (c->info.adate) : xattr->mdate;
	xattr->ctime	= c->info.ctime ? le2cpu16 (c->info.ctime) : xattr->mtime;
	xattr->cdate	= c->info.cdate ? le2cpu16 (c->info.cdate) : xattr->mdate;
	xattr->attr	= c->info.attr & FA_TOSVALID;
	
	FAT_DEBUG (("fatfs_getxattr: return ok"));
	return E_OK;
}

static long _cdecl
fatfs_chattr (fcookie *fc, int attrib)
{
	COOKIE *c = (COOKIE *) fc->index;
	long r = EACCES;
	
	FAT_DEBUG (("fatfs_chattr [%s]: enter", c->name));
	FAT_DEBUG_COOKIE ((c));
	
	if (RDONLY (c->dev))
		return EROFS;
	
	if (c->dir)
	{
		/* only the lowest 8 bits are used */
		c->info.attr = attrib & FA_TOSVALID;
		
		r = write_cookie (c);
		if (r)
		{
			FAT_DEBUG (("fatfs_chattr: failure in write_cookie (%li)", r));
		}
		else
		{
			if (c->dev == 0 || c->dev == 1)
			{
				bio_SYNC_DRV ((&bio), DI (c->dev));
			}
			
			r = E_OK;
		}
	}
	
	FAT_DEBUG (("fatfs_chattr: leave ok (r = %li)", r));
	return r;
}

static long _cdecl
fatfs_chown (fcookie *fc, int uid, int gid)
{
	COOKIE *c = (COOKIE *) fc->index;
	
	FAT_DEBUG (("fatfs_chown [%s]: enter (%s)", c->name, (c->dir == 0) ? "ROOT" : "SUB"));
	
	if (RDONLY (c->dev))
		return EROFS;
	
	if (c->dir == 0)
	{
		ROOT_UID (c->dev) = uid;
		ROOT_GID (c->dev) = gid;
	}
	
	/* temporary: always return E_OK to make Unix programs happy
	 *            this will be removed if MiNT-Lib automatically do this
	 */
# if 0
	else
	{
		if (ROOT_UID (c->dev) != uid || ROOT_GID (c->dev) != gid)
		{
			FAT_DEBUG (("fatfs_chown: leave ENOSYS"));
			return ENOSYS;
		}
	}
# endif
	
	FAT_DEBUG (("fatfs_chown: leave ok"));
	return E_OK;
}

static long _cdecl
fatfs_chmode (fcookie *fc, unsigned mode)
{
	COOKIE *c = (COOKIE *) fc->index;
	
	FAT_DEBUG (("fatfs_chmode [%s]: enter (%s)", c->name, (c->dir == 0) ? "ROOT" : "SUB"));
	FAT_DEBUG_COOKIE ((c));
	
	if (RDONLY (c->dev))
		return EROFS;
	
	if (c->dir == 0)
	{
		ROOT_MODE (c->dev) = mode;
	}
	else
	{
		char new;
		
		if (!(mode & S_IWUSR))
		{
			new = c->info.attr | FA_RDONLY;
		}
		else
		{
			new = c->info.attr & ~FA_RDONLY;
		}
		
		if (c->info.attr & FA_DIR)
		{
			if (mode & S_ISUID)
			{
				/* hidden directory */
				new |= FA_HIDDEN;
			}
			else
			{
				new &= ~FA_HIDDEN;
			}
		}
		
		if (new != c->info.attr)
		{
			long r;
			
			c->info.attr = new;
			r = write_cookie (c);
			if (r)
			{
				FAT_DEBUG (("fatfs_chmode: leave failure (write_cookie = %li)", r));
				return r;
			}
			
			if (c->dev == 0 || c->dev == 1)
			{
				bio_SYNC_DRV ((&bio), DI (c->dev));
			}
		}
	}
	
	FAT_DEBUG (("fatfs_chmode: leave ok"));
	return E_OK;
}

static long _cdecl
fatfs_mkdir (fcookie *dir, const char *name, unsigned mode)
{
	COOKIE *c = (COOKIE *) dir->index;
	COOKIE *new = NULL;
	long r;
	
	UNUSED (mode);
	
	FAT_DEBUG (("fatfs_mkdir [%s]: enter (%s)", c->name, name));
	
	if (RDONLY (c->dev))
		return EROFS;
	
	/* check if dir exist */
	r = search_cookie (c, NULL, name, 0);
	if (r == E_OK)
	{
		FAT_DEBUG (("fatfs_mkdir: leave failure (dir exist)"));
		return EACCES;
	}
	
	r = make_cookie (c, &new, name, FA_DIR);
	if (r == E_OK)
	{
		long stcl;
		
		stcl = r = nextcl (0, c->dev);
		if (r > 0)
		{
			PUT_STCL (&(new->info), c->dev, stcl);
			new->stcl = stcl;
			
			r = write_cookie (new);
			if (r == E_OK)
			{
				UNIT *u;
				
				u = bio_data_getunit (c->dev, DI (c->dev), C2S (stcl, c->dev), CLUSTSIZE (c->dev));
				if (u)
				{
					register const ushort date = cpu2le16 (datestamp);
					register const ushort time = cpu2le16 (timestamp);
					register _DIR *info = (_DIR *) u->data;
					register long j;
					
					quickzero (u->data, CLUSTSIZE (c->dev) >> 8);
					
					info->name[0] = '.';
					for (j = 1; j < 11; j++) info->name[j] = ' ';
					info->attr = FA_DIR;
					info->date = date;
					info->time = time;
					PUT_STCL (info, c->dev, stcl);
					
					info++;
					info->name[0] = info->name[1] = '.';
					for (j = 2; j < 11; j++) info->name[j] = ' ';
					info->attr = FA_DIR;
					info->date = date;
					info->time = time;
					if ((new->dir > 1) && (new->dir != RCOOKIE (c->dev)->stcl))
					{
						PUT_STCL (info, c->dev, new->dir);
					}
					
					bio_MARK_MODIFIED ((&bio), u);
					bio_SYNC_DRV ((&bio), DI (c->dev));
					
					new->links--;
					
					FAT_DEBUG (("fatfs_mkdir: leave ok"));
					return E_OK;
					
				}
				else /* if (ptr) */
				{
					FAT_DEBUG (("fatfs_mkdir: leave failure (read)"));
					r = EREAD;
				}
				
			}
			else /* if (r == E_OK) */
			{
				FAT_DEBUG (("fatfs_mkdir: leave failure (write_cookie = %li)", r));
			}
			
		}
		else /* if (r > 0) */
		{
			FAT_DEBUG (("fatfs_mkdir: leave failure (nextcl = %li)", r));
		}
		
		(void) delete_cookie (new, 1);
	}
	else /* if (r == E_OK) */
	{
		FAT_DEBUG (("fatfs_mkdir: leave failure (make_cookie = %li)", r));
	}
	
	return r;
}

static long _cdecl
fatfs_rmdir (fcookie *dir, const char *name)
{
	DIR dirh;	
	long r;
	
	FAT_DEBUG (("fatfs_rmdir [%s]: enter (%s)", ((COOKIE *) dir->index)->name, name));
	
	if (RDONLY (dir->dev))
		return EROFS;
	
	r = fatfs_lookup (dir, name, &(dirh.fc));
	if (r == E_OK)
	{
		FAT_DEBUG (("fatfs_rmdir: found: dev = %i", dirh.fc.dev));
		
		/* Ordner muss leer sein, ansonsten EACCES
		 */
		dirh.flags = 0;
		r = fatfs_opendir (&dirh, dirh.flags);
		
		if (r)
		{
			(void) fatfs_release (&(dirh.fc));
			
			FAT_DEBUG (("fatfs_rmdir: leave failure (fatfs_opendir = %li)", r));
			return r;
		}
		
		{
			char buf [VFAT_NAMEMAX];
			fcookie file;
			long count = 0;
			
			while (fatfs_readdir (&dirh, buf, VFAT_NAMEMAX, &file) == 0)
			{
				fatfs_release (&file);
				c_del_cookie ((COOKIE *) file.index);
				
				count++;
				if (count > 2)
				{
					(void) fatfs_closedir (&dirh);
					(void) fatfs_release (&(dirh.fc));
					
					FAT_DEBUG (("fatfs_rmdir: leave failure (not free)"));
					return EACCES;
				}
			}
		}
		
		(void) fatfs_closedir (&dirh);
		
		r = delete_cookie ((COOKIE *) dirh.fc.index, 1);
		if (r == 0)
		{
			bio_SYNC_DRV ((&bio), DI (dir->dev));
			
			FAT_DEBUG (("fatfs_rmdir: leave ok"));
			return E_OK;
		}
		else
		{
			(void) fatfs_release (&(dirh.fc));
			
			FAT_DEBUG (("fatfs_rmdir: leave failure (delete_cookie = %li)", r));
		}
	}
	else
	{
		FAT_DEBUG (("fatfs_rmdir: leave failure (fatfs_lookup = %li)", r));
	}
	
	return r;
}

static long _cdecl
fatfs_creat (fcookie *dir, const char *name, unsigned mode, int attrib, fcookie *fc)
{
	COOKIE *c = (COOKIE *) dir->index;
	COOKIE *new = NULL;
	long r;
	
	UNUSED (mode);
	
	FAT_DEBUG (("fatfs_creat [%s]: enter (%s)", c->name, name));
	
	if (RDONLY (c->dev))
		return EROFS;
	
# if 0 	/* --- kernel do this --- */
	r = search_cookie (c, NULL, name, 0);
	if (r == E_OK)
	{
		FAT_DEBUG (("fatfs_creat: leave failure (file exist)"));
		return EACCES;
	}
# endif
	
	r = make_cookie (c, &new, name, attrib);
	
	fc->fs = &fatfs_filesys;
	fc->dev = c->dev;
	fc->aux = 0;
	fc->index = (long) new;
	
	bio_SYNC_DRV ((&bio), DI (c->dev));
	
	FAT_DEBUG (("fatfs_creat: leave ok (return make_cookie = %li)", r));
	return r;
}

static long _cdecl
fatfs_remove (fcookie *dir, const char *name)
{
	COOKIE *file;
	long r;
	
	FAT_DEBUG (("fatfs_remove [%s]: enter (%s)", ((COOKIE *) dir->index)->name, name));
	
	if (RDONLY (dir->dev))
		return EROFS;
	
	r = search_cookie ((COOKIE *) dir->index, &file, name, 0);
	if (r == E_OK)
	{
		r = delete_cookie (file, 1);
		if (r == E_OK)
		{
			bio_SYNC_DRV ((&bio), DI (dir->dev));
			
			FAT_DEBUG (("fatfs_remove: leave ok"));
			return E_OK;
		}
		else
		{
			file->links--;
			
			FAT_DEBUG (("fatfs_remove: leave failure (delete_cookie)"));
		}
	}
	else
	{
		FAT_DEBUG (("fatfs_remove: leave failure (search_cookie)"));
	}
	
	return r;
}

static long _cdecl
fatfs_getname (fcookie *root, fcookie *dir, char *pathname, int size)
{
	const char *r = ((COOKIE *) root->index)->name;
	const char *d = ((COOKIE *) dir->index)->name;
	long i, j;
	
	FAT_DEBUG (("fatfs_getname: enter - root = %s, dir = %s", r, d));
	
	if (size <= 0)
	{
		FAT_DEBUG (("fatfs_getname: leave failure (EBADARG)"));
		return EBADARG;
	}
	
	*pathname = '\0';
	
	if (COOKIE_EQUAL (root, dir))
	{
		FAT_DEBUG (("fatfs_getname: leave ok, equal"));
		return E_OK;
	}
	
	i = strlen (r);
	j = strlen (d);
	if (j > i)
	{
		if ((j - i) < size)
		{
			strcpy (pathname, d + i);
			
			FAT_DEBUG (("fatfs_getname: leave pathname = %s", pathname));
			return E_OK;
		}
		
		FAT_DEBUG (("fatfs_getname: leave failure (EBADARG)"));
		return EBADARG;
	}
	
	FAT_DEBUG (("fatfs_getname: leave failure (EINTERNAL)"));
	return EINTERNAL;
}

static long _cdecl
fatfs_rename (fcookie *olddir, char *oldname, fcookie *newdir, const char *newname)
{
	COOKIE *oldd = (COOKIE *) olddir->index;
	COOKIE *newd = (COOKIE *) newdir->index;
	COOKIE *old;
	long r;
	
	FAT_DEBUG (("fatfs_rename: enter (oldd = %s, newd = %s)", oldd->name, newd->name));
	FAT_DEBUG (("fatfs_rename: old = %s, new = %s", oldname, newname));
	
	if (RDONLY (oldd->dev))
		return EROFS;
	
	/* on same device? */
	if (oldd->dev != newd->dev)
	{
		FAT_DEBUG (("fatfs_rename: cross device rename: [%c] -> [%c]!", olddir->dev+'A', newdir->dev+'A'));
		return EXDEV;
	}
	
	/* check if the file exist */
	r = search_cookie (newd, NULL, newname, 0);
	if (r == E_OK)
	{
		/* check for rename same file (casepreserving) */
		if (!(COOKIE_EQUAL (olddir, newdir) && (stricmp (oldname, newname) == 0)))
		{
			FAT_DEBUG (("fatfs_rename: leave failure (file exist)"));
			return EACCES;
		}
	}
	
	/* search_cookie doesn't find '.' or '..' in the root directory
	 * so we verify here that newname does not match '.' or '..'
	 */
	if (newd->dir == 0)
	{
		/* newdir is root directory */
		if (newname [0] == '.')
		{
			if (newname [1] == '\0'
				|| (newname [1] == '.' && newname [2] == '\0'))
			{
				FAT_DEBUG (("fatfs_rename: leave failure, rename to '.' or '..'"));
				return EACCES;
			}
		}
	}
	
	r = search_cookie (oldd, &old, oldname, 0);
	if (r)
	{
		FAT_DEBUG (("fatfs_rename: leave failure (not found -> %li)", r));
		return r;
	}
	
	if (old->links > 1)
	{
		old->links--;
		
		FAT_DEBUG (("fatfs_rename: leave failure (cookie in use)"));
		return EACCES;
	}
	
	if (old->info.attr & FA_DIR)
	{
		long i;
		
		for (i = 0; i < COOKIE_CACHE; i++)
		{
			COOKIE *c = &(cookies [i]);
			
			if (c->name)
			{
				if (old->stcl == c->dir)
				{
					if (c->links)
					{
						old->links--;
						
						FAT_DEBUG (("fatfs_rename: leave failure (can't remove subcookies)"));
						return EACCES;
					}
					else
						c_del_cookie (c);
				}
			}
		}
	}
	
	if (!old->slots && !VFAT (old->dev) && COOKIE_EQUAL (olddir, newdir))
	{
		/* special case for non VFAT drives -> position save renaming
		 * 
		 * requirenments:
		 * 
		 * 1. the file is in the same directory [COOKIE_EQUAL]
		 * 2. the old filename has no VFAT entries [!old->slots]
		 * 3. the new filename is a 8+3 name [!VFAT (dev)]
		 *    the new 8+3 name is verified later but !VFAT
		 *    gurant that the validated name is 8+3 if
		 *    make_shortname return successful
		 * 
		 * side effect: the '..' in directories must not be
		 *              updated
		 */
		
		char shortname[FAT_NAMEMAX];
		
		FAT_DEBUG (("fatfs_rename: same entry method"));
		
		/* verify new name */
		r = make_shortname (oldd, newname, shortname);
		if (r)
		{
			old->links--;
			return r;
		}
		
		/* update directory entry */
		str2dir (shortname, old->info.name);
		
		/* here we must update the inode cache self
		 */
		{
			register char *name;
			
			name = fullname (oldd, shortname);
			if (!name)
			{
				old->links--;
				
				FAT_DEBUG (("fatfs_rename: leave failure (out of memory)"));
				return ENOMEM;
			}
			
			c_hash_remove (old);
			{
				kfree (old->name);
				old->name = name;
			}
			c_hash_install (old);
		}
		
		FAT_DEBUG (("fatfs_rename: old->name = %s", old->name));
		
		/* invalidate negative lookup cache
		 */
		if (oldd->lastlookup)
		{
			kfree (oldd->lastlookup);
			oldd->lastlookup = NULL;
		}
		
		/* update data on disk */
		r = write_cookie (old);
		
		old->links--;
		bio_SYNC_DRV ((&bio), DI (old->dev));
	}
	else
	{
		/* normal renaming
		 * create a new entry and delete the old
		 * 
		 * if a directory is moved the '..' entry must be
		 * updated
		 */
		
		COOKIE *new;
		
		FAT_DEBUG (("fatfs_rename: new entry method"));
		
		r = make_cookie (newd, &new, newname, old->info.attr);
		if (r)
		{
			old->links--;
			return r;
		}
		
		new->info.lcase		= old->info.lcase;
		new->info.ctime_ms	= old->info.ctime_ms;
		new->info.ctime		= old->info.ctime;
		new->info.cdate		= old->info.cdate;
		new->info.adate		= old->info.adate;
		new->info.stcl_fat32	= old->info.stcl_fat32;
		new->info.time		= old->info.time;
		new->info.date		= old->info.date;
		new->info.stcl		= old->info.stcl;
		new->info.flen		= old->info.flen;
		
		new->stcl = old->stcl;
		new->flen = old->flen;
		
		r = write_cookie (new);
		if (r)
		{
			old->links--;
			/* new->links--; */
			
			/* ALERT about to run fsck? */
			return r;
		}
		
		if ((new->info.attr & FA_DIR) && !COOKIE_EQUAL (olddir, newdir))
		{
			UNIT *u;
			
			u = bio_data_read (new->dev, DI (new->dev), C2S (new->stcl, new->dev), CLUSTSIZE (new->dev));
			if (u)
			{
				register _DIR *info = (_DIR *) u->data;
				
				info++;
				
				if (new->dir > 1)	PUT_STCL (info, new->dev, new->dir);
				else			PUT_STCL (info, new->dev, 0);
				
				bio_MARK_MODIFIED ((&bio), u);
			}
			else
			{
				FAT_ALERT (("FATFS [%c]: can't update '..' in directory rename; possible filesystem corruption!", new->dev+'A'));
			}
		}
		
		r = delete_cookie (old, 0);
		
		new->links--;
		bio_SYNC_DRV ((&bio), DI (new->dev));
	}
	
	FAT_DEBUG (("fatfs_rename: leave %s, r = %li", r ? "failure" : "ok", r));
	return r;
}

static long _cdecl
fatfs_opendir (DIR *dirh, int flags)
{
	COOKIE *c = (COOKIE *) dirh->fc.index;
	oDIR *dir = (oDIR *) dirh->fsstuff;
	long r;
	
	UNUSED (flags);
	
	dirh->index = 0;
	
	r = __opendir (dir, c->stcl, c->dev);
	if (!r)
		c->links++;
	
	FAT_DEBUG_COOKIE ((c));
	FAT_DEBUG (("fatfs_opendir [%s]: (%li, %li), %li -> r = %li", c->name, c->dir, c->offset, c->stcl, r));
	return r;
}

static long _cdecl
fatfs_readdir (DIR *dirh, char *nm, int nmlen, fcookie *fc)
{
	oDIR *dir = (oDIR *) dirh->fsstuff;
	COOKIE *c = (COOKIE *) dirh->fc.index;
	COOKIE *new;
	char *name;
	char *read_nm;
	char buf [VFAT_NAMEMAX];
	char shortbuf [FAT_NAMEMAX];
	register long r;
	
	FAT_DEBUG (("fatfs_readdir [%s]: enter", c->name));
	
	if (dirh->flags & TOS_SEARCH)
	{
		FAT_DEBUG (("fatfs_readdir: TOS_SEARCH"));
		
		r = __nextdir (dir, buf, VFAT_NAMEMAX);
		if (r < 0)
			return r;
		
		if (r)
		{
			dir2str (dir->info->name, shortbuf);
			if (strlen (shortbuf) >= nmlen)
				return EBADARG;
		}
		else
		{
			if (strlen (buf) >= nmlen)
				return EBADARG;
			
			strcpy (nm, buf);
		}
		
		read_nm = buf;
	}
	else
	{
		nm += 4;
		nmlen -= 4;
		
		r = __nextdir (dir, nm, nmlen);
		if (r < 0)
			return r;
		
		read_nm = nm;
	}
	
	name = fullname (c, read_nm);
	if (name)
	{
		new = c_hash_lookup (name, dir->dev);
		if (!new)
		{
			new = c_get_cookie (name);
			if (new)
			{
				new->dev = dir->dev;
				new->rdev = dir->dev;
				new->dir = c->stcl;
				new->offset = dir->index;
				new->stcl = GET_STCL (dir->info, dir->dev);
				new->flen = le2cpu32 (dir->info->flen);
				new->info = *(dir->info);
				new->slots = r;
			}
		}
		else
		{
			kfree (name);
			new->links++;
		}
		
		if (new)
		{
			fc->fs = &fatfs_filesys;
			fc->dev = dir->dev;
			fc->aux = 0;
			fc->index = (long) new;
			
			dirh->index = dir->index;
			
			if (r && ((dirh->flags & TOS_SEARCH) || !VFAT (dir->dev)))
			{
				/* return TOS name */
				FAT_DEBUG (("fatfs_readdir: TOS_SEARCH, make TOS_NAME"));
				dir2str (dir->info->name, nm);
				
				if (curproc->domain != DOM_TOS)
					strlwr (nm);
			}
			
			if (!(dirh->flags & TOS_SEARCH) && VFAT (dir->dev))
			{
				if (!r && LCASE (dir->dev))
					strlwr (nm);
			}
			else
			{
				if (curproc->domain != DOM_TOS)
					strlwr (nm);
			}
			
			if ((dirh->flags & TOS_SEARCH) == 0)
			{
				*(long *) (nm - 4) = INDEX (new);
			}
			
			FAT_DEBUG_COOKIE ((new));
			FAT_DEBUG (("fatfs_readdir: leave ok (nm = %s)", nm));
			
			return E_OK;
		}
		
		FAT_DEBUG (("fatfs_readdir: leave failure (c_get_cookie)"));
	}
	
	FAT_DEBUG (("fatfs_readdir: leave failure (out of memory)"));
	return ENOMEM;
}

static long _cdecl
fatfs_rewinddir (DIR *dirh)
{
	register long r;
	
	(void) fatfs_closedir (dirh);
	r = fatfs_opendir (dirh, dirh->flags);
	
	FAT_DEBUG (("fatfs_rewinddir [%s]: ok", ((COOKIE *) dirh->fc.index)->name));
	return r;
}

static long _cdecl
fatfs_closedir (DIR *dirh)
{
	COOKIE *c = (COOKIE *) dirh->fc.index;
	
	__closedir ((oDIR *) dirh->fsstuff);
	c->links--;
	
	FAT_DEBUG (("fatfs_closedir [%s]: ok (links = %li)", c->name, c->links));
	return E_OK;
}

static long _cdecl
fatfs_pathconf (fcookie *dir, int which)
{
	FAT_DEBUG (("fatfs_pathconf [%s]: enter", ((COOKIE *) dir->index)->name));
	
	switch (which)
	{
		case DP_INQUIRE:	return DP_VOLNAMEMAX;
		case DP_IOPEN:		return UNLIMITED;
		case DP_MAXLINKS:	return 1;
		case DP_PATHMAX:	return VFAT (dir->dev) ? VFAT_PATHMAX - 1 : FAT_PATHMAX - 1;
		case DP_NAMEMAX:	return VFAT (dir->dev) ? VFAT_NAMEMAX - 1 : FAT_NAMEMAX - 1;
		case DP_ATOMIC:		return CLUSTSIZE (dir->dev);
		case DP_TRUNC:		return VFAT (dir->dev) ? DP_NOTRUNC : DP_DOSTRUNC;
		case DP_CASE:		return VFAT (dir->dev) ? DP_CASEINSENS : DP_CASECONV;
		case DP_MODEATTR:	return (FA_TOSVALID
						| DP_FT_DIR
						| DP_FT_REG
						| (SLNK (dir->dev) ? DP_FT_LNK : 0)
					);
		case DP_XATTRFIELDS:	return (DP_INDEX
						| DP_DEV
						| DP_BLKSIZE
						| DP_SIZE
						| DP_NBLOCKS
						| DP_MTIME
						| (VFAT (dir->dev) ? (DP_ATIME | DP_CTIME) : 0)
					);
		case DP_VOLNAMEMAX:	return FAT_NAMEMAX - 2; /* . and \0 */
	}
	
	FAT_DEBUG (("fatfs_pathconf: leave failure"));	
	return ENOSYS;
}

static long _cdecl
fatfs_dfree (fcookie *dir, long *buf)
{
	return DFREE (dir, buf);
}

static long _cdecl
fatfs_writelabel (fcookie *dir, const char *name)
{
	oDIR odir;
	long index = 0;
	long r;
	
	FAT_DEBUG (("fatfs_writelabel [%s]: enter (name = %s)", ((COOKIE *) dir->index)->name, name));
	
	if (RDONLY (dir->dev))
		return EROFS;
	
	r = __opendir (&odir, RCOOKIE (dir->dev)->stcl, dir->dev);
	while ((r = __SEEKDIR (&odir, index++, READ)) == E_OK)
	{
		if (odir.info->name[0] && odir.info->name[0] != (char) 0xe5)
		{
			if (!(((odir.info->attr & (FA_DIR | FA_LABEL)) != FA_LABEL)
				|| (odir.info->attr == FA_VFAT)))
			{
				break;
			}
		}
	}
	
	if (r)
	{
		/* no label found, search free entry */
		FAT_DEBUG (("fatfs_writelabel: no label found, search free entry"));
		
		index = 0;
		
		while ((r = __SEEKDIR (&odir, index++, READ)) == E_OK)
		{
			if (odir.info->name[0] == (char) 0xe5)
				/* deleted entry */
				break;
			if (odir.info->name[0] == '\0')
				/* never used */
				break;
		}
	}
	
	if (r == E_OK)
	{
		register const char *table = DEFAULT_T (dir->dev);
		register const char *src = name;
		register char *dst = odir.info->name;
		register long i;
		
		for (i = 0; i < 11 && *src; i++)
		{
			if (*src == ' ')
				*dst++ = ' ';
			else
				*dst++ = table [(long) *src] ? TOUPPER (*src) : '_';
			src++;
		}
		
		/* fill out with spaces */
		for (; i < 11; i++)
			*dst++ = ' ';		
		
		/* set up entry */
		odir.info->attr = FA_LABEL;
		odir.info->lcase = 0;
		odir.info->ctime_ms = 0;
		odir.info->ctime = 0;
		odir.info->cdate = 0;
		odir.info->adate = 0;
		odir.info->stcl_fat32 = 0;
		odir.info->time = cpu2le16 (timestamp);
		odir.info->date = cpu2le16 (datestamp);
		odir.info->stcl = 0;
		odir.info->flen = 0;
		
		__updatedir (&odir);
		
		bio_SYNC_DRV ((&bio), DI (dir->dev));
	}
	
	__closedir (&odir);
	
	FAT_DEBUG (("fatfs_writelabel: leave r = %li (index = %li)", r, odir.index));
	return r;
}

static long _cdecl
fatfs_readlabel (fcookie *dir, char *name, int namelen)
{
	oDIR odir;
	long index = 0;
	long r;
	
	FAT_DEBUG (("fatfs_readlabel [%s]: enter (namelen = %i)", ((COOKIE *) dir->index)->name, namelen));
	
	/* set up empty label */
	*name = '\0';
	
	r = __opendir (&odir, RCOOKIE (dir->dev)->stcl, dir->dev);
	while ((r = __SEEKDIR (&odir, index++, READ)) == E_OK)
	{
		if (odir.info->name[0] && odir.info->name[0] != (char) 0xe5)
		{
			if (!(((odir.info->attr & (FA_DIR | FA_LABEL)) != FA_LABEL)
				|| (odir.info->attr == FA_VFAT)))
			{
				break;
			}
		}
	}
	
	if (r == E_OK)
	{
		register long space = 0;
		register long i;
		
		FAT_DEBUG (("fatfs_readlabel: label found (index = %li)", odir.index));
		
		for (i = 0; namelen && i < 11; namelen--, i++)
		{
			name[i] = odir.info->name[i];
			if (odir.info->name[i] == ' ') space++;
			else space = 0;
		}
		
		if (namelen == 0)
		{
			FAT_DEBUG (("fatfs_readlabel: namelen == 0 -> EBADARG"));
			r = EBADARG;
		}
		else
		{
			i -= space;
			name[i] = '\0';
			r = E_OK;
		}
	}
	else
	{
		FAT_DEBUG (("fatfs_readlabel: label not found -> ENOENT"));
		r = ENOENT;
	}
	
	__closedir (&odir);
	
	FAT_DEBUG (("fatfs_readlabel: leave r = %li (label = %s, namelen = %i, index = %li)", r, name, namelen, odir.index));
	return r;
}

static long _cdecl
fatfs_symlink (fcookie *dir, const char *name, const char *to)
{
	FILEPTR f;
	ushort linklen;
	long r;
	
	if (!SLNK (dir->dev))
		return ENOSYS;
	
	if (RDONLY (dir->dev))
		return EROFS;
	
	FAT_DEBUG (("fatfs_symlink [%s]: enter", ((COOKIE *) dir->index)->name));
	FAT_DEBUG (("fatfs_symlink: name = %s, to = %s", name, to));
	
	/* check if file exist */
	r = search_cookie ((COOKIE *) dir->index, NULL, name, 0);
	if (r == E_OK)
	{
		FAT_DEBUG (("fatfs_symlink: leave failure (file exist)"));
		return EACCES;
	}
	
	r = fatfs_creat (dir, name, 0, FA_SYMLINK, &(f.fc));
	if (r)
	{
		FAT_DEBUG (("fatfs_symlink: leave failure (creat = %li)", r));
		return r;
	}
	
	f.flags = O_TRUNC | O_WRONLY;
	f.links = 0;
	r = fatfs_open (&f);
	if (r)
	{
		delete_cookie ((COOKIE *) f.fc.index, 1);
		
		FAT_DEBUG (("fatfs_symlink: leave failure (open = %li)", r));
		return r;
	}
	
	linklen = strlen (to) + 1;
	if (linklen & 1) linklen += 1;
	
	(void) fatfs_write (&f, (char *) &linklen, 2);
	(void) fatfs_write (&f, to, linklen - 1);
	(void) fatfs_write (&f, "\0", 1);
	(void) fatfs_close (&f, 0);
	
	(void) fatfs_release (&(f.fc));
	
	FAT_DEBUG (("fatfs_symlink: leave ok"));
	return E_OK;
}

static long _cdecl
fatfs_readlink (fcookie *file, char *buf, int len)
{
	COOKIE *c = (COOKIE *) file->index;
	FILEPTR f;
	ushort linklen;
	long r;
	
	FAT_DEBUG (("fatfs_readlink [%s]: enter", c->name));
	
	if (c->info.attr != FA_SYMLINK)
	{
		FAT_DEBUG (("fatfs_readlink: leave failure (not a symlink)"));
		return EACCES;  /* EINVAL on HP-UX */
	}
	
	(void) fatfs_dupcookie (&(f.fc), file);
	
	f.flags = O_RDONLY;
	f.links = 0;
	r = fatfs_open (&f);
	if (r == E_OK)
	{
		r = fatfs_read (&f, (char *) &linklen, 2);
		if (r != 2)
		{
			/* read error */
			r = (r < 0) ? r : EERROR;
		}
		else if (linklen >= len)
		{
			r = EBADARG;
		}
		else
		{
			r = fatfs_read (&f, buf, MIN (len, linklen));
			if (r == linklen)
			{
				buf[--len] = '\0';
				r = E_OK;
			}
			else
			{
				/* read error */
				r = (r < 0) ? r : EERROR;
			}
		}
		
		(void) fatfs_close (&f, 0);
	}
	else
	{
		FAT_DEBUG (("fatfs_readlink: failure (open = %li)", r));
	}
	
	(void) fatfs_release (&(f.fc));
	
	FAT_DEBUG (("fatfs_readlink: leave return = %li", r));
	return r;
}

static long _cdecl
fatfs_fscntl (fcookie *dir, const char *name, int cmd, long arg)
{
	FAT_DEBUG (("fatfs_fscntl [%s]: enter (name = %s, cmd = %i, arg = %li)", ((COOKIE *) dir->index)->name, name, cmd, arg));
	
	switch (cmd)
	{
		case MX_KER_XFSNAME:
		{
			strcpy ((char *) arg, "vfat-xfs");
			return E_OK;
		}
		case FS_INFO:
		{
			struct fs_info *info;
			
			info = (struct fs_info *) arg;
			if (info)
			{
				char *dst = info->type_asc;
				
				strcpy (info->name, "vfat-xfs");
				info->version = (long) FATFS_MAJOR << 16;
				info->version |= (long) FATFS_MINOR;
				
				if (VFAT (dir->dev))
				{
					info->type = _MAJOR_VFAT;
					*dst++ = 'v';
				}
				else
				{
					info->type = _MAJOR_FAT;
				}
				
				*dst++ = 'f';
				*dst++ = 'a';
				*dst++ = 't';
				*dst++ = ' ';
				
				switch (FAT_TYPE (dir->dev))
				{
					case FAT_TYPE_12:
					{
						info->type |= FS_FAT12;
						*dst++ = '1';
						*dst++ = '2';
						
						break;
					}
					case FAT_TYPE_16:
					{
						info->type |= FS_FAT16;
						*dst++ = '1';
						*dst++ = '6';
						
						break;
					}
					case FAT_TYPE_32:
					{
						info->type |= FS_FAT32;
						*dst++ = '3';
						*dst++ = '2';
						
						break;
					}
				}
				
				*dst++ = '\0';
			}
			
			return E_OK;
		}
		case FS_USAGE:
		{
			struct fs_usage *usage;
			
			usage = (struct fs_usage *) arg;
			if (usage)
			{
				ulong buf [4];
				long r;
				
				r = fatfs_dfree (dir, buf);
				if (r) return r;
				
				usage->blocksize = buf [2] * buf [3];
# ifdef __GNUC__
				usage->blocks = buf [1];
				usage->free_blocks = buf [0];
				usage->inodes = FS_UNLIMITED;
				usage->free_inodes = FS_UNLIMITED;
# else
# error 			/* FIXME: PureC doesn't know 'long long' */
# endif
			}
			
			return E_OK;
		}
		case VFAT_CNFDFLN:
		{
			long drv = 1;
			long i;
			
			for (i = 0; i < NUM_DRIVES; i++)
			{
				if (arg & drv)
					VFAT (i) = ENABLE;
				else
					VFAT (i) = DISABLE;
				
				drv <<= 1;
			}
			
			return E_OK;
		}
		case VFAT_CNFLN:
		{
			return fatfs_config (dir->dev, FATFS_VFAT, arg);
		}
		case V_CNTR_SLNK:
		{
			if (arg == ASK)
				return SLNK (dir->dev);
			
			SLNK (dir->dev) = arg ? ENABLE : DISABLE;
			
			return E_OK;
		}
		case DL_SETCHAR:
		case V_CNTR_MODE:
		{
			if (VFAT (dir->dev)) return ENOSYS;
			
			switch (arg)
			{
				case ASK:
				{
					return NAME_MODE (dir->dev);
				}
				case GEMDOS:
				{
					NAME_MODE (dir->dev) = GEMDOS;
					DEFAULT_T (dir->dev) = GEMDOS_TABLE;
					break;
				}
				case ISO:
				{
					NAME_MODE (dir->dev) = ISO;
					DEFAULT_T (dir->dev) = ISO_TABLE;
					break;
				}
				case MSDOS:
				{
					NAME_MODE (dir->dev) = MSDOS;
					DEFAULT_T (dir->dev) = MSDOS_TABLE;
					break;
				}
				default:
				{
					return ENOSYS;
				}
			}
			
			return E_OK;
		}
		case V_CNTR_FAT32:
		{
			struct control_FAT32 *f32 = (struct control_FAT32 *) arg;
			
			if (!FAT32 (dir->dev)) return ENOSYS;
			
			if (f32->mode == 0)
			{
				if (FAT32mirr (dir->dev))
				{
					f32->mirr = 0;
				}
				else
				{
					f32->mirr = FAT32prim (dir->dev);
					f32->mirr -= FATSTART (dir->dev);
					f32->mirr /= FATSIZE (dir->dev);
					f32->mirr++;
				}
				f32->fats = FAT2ON (dir->dev) + 1;
				f32->info = 0;
				f32->info |= FAT32infu (dir->dev) ? FAT32_info_exist : 0;
				f32->info |= FAT32info (dir->dev) ? FAT32_info_active : 0;
			}
			else
			{
				/*
				 * setup FAT stuff
				 */
				
				long old_mirr = FAT32mirr (dir->dev);
				long old_fat = FAT32prim (dir->dev);
				
				if (f32->mirr)
				{
					f32->mirr--;
					if (f32->mirr >= 0 && f32->mirr <= FAT2ON (dir->dev))
					{
						f32->mirr *= FATSIZE (dir->dev);
						f32->mirr += FATSTART (dir->dev);
						
						FAT32prim (dir->dev) = f32->mirr;
						FAT32mirr (dir->dev) = DISABLE;
					}
					else
					{
						FAT32mirr (dir->dev) = ENABLE;
					}
				}
				else
				{
					FAT32mirr (dir->dev) = ENABLE;
				}
				
				if (FAT32mirr (dir->dev))
				{
					FAT32prim (dir->dev) = FATSTART (dir->dev);
				}
				
				/* anything changed? */
				if (old_mirr != FAT32mirr (dir->dev) || old_fat != FAT32prim (dir->dev))
				{
					/* update FAT's if neccessary */
					if (old_mirr == DISABLE)
					{
						upd_fat32fats (dir->dev, old_fat);
					}
					
					/* set up new boot sector */
					upd_fat32boot (dir->dev);
				}
				
				/*
				 * setup INFO sector
				 */
				
				if (FAT32infu (dir->dev))
				{
					if (f32->info & FAT32_info_reset)
						FREECL (dir->dev) = -1;
					
					if (f32->info & FAT32_info_active)
					{
						if (!FAT32info (dir->dev))
						{
							FAT32info (dir->dev) = (_FAT32_BFSINFO *) (FAT32infu (dir->dev)->data + _FAT32_BFSINFO_OFF);
							FAT32info (dir->dev)->signature = cpu2le32 (FAT32_FSINFOSIG);
						}
						upd_fat32info (dir->dev);
					}
					else
					{
						inv_fat32info (dir->dev);
						FAT32info (dir->dev) = NULL;
					}
				}
				
				/* non maskable sync
				 * we changed eventually very critical data
				 * not called very often, so no speed
				 * problem here
				 */
				bio.sync_drv (DI (dir->dev));
			}
			
			return E_OK;
		}
		case V_CNTR_WP:
		{
			long r;
			
			r = bio.config (dir->dev, BIO_WP, arg);
			if (!r)
			{
				if (BIO_WP_CHECK (DI (dir->dev)) && !RDONLY (dir->dev))
				{
					bio.sync_drv (DI (dir->dev));
					
					RDONLY (dir->dev) = 1;
					FAT_ALERT (("FAT-FS [%c]: remounted read-only!", dir->dev+'A'));
				}
				else if (RDONLY (dir->dev))
				{
					bio.sync_drv (DI (dir->dev));
					
					RDONLY (dir->dev) = 0;
					FAT_ALERT (("FAT-FS [%c]: remounted read/write!", dir->dev+'A'));
				}
			}
			
			return r;
		}
		case V_CNTR_WB:
		{
			return bio.config (dir->dev, BIO_WB, arg);
		}
		case FUTIME:
		{
			COOKIE *c;
			long r;
			
			r = search_cookie ((COOKIE *) dir->index, &c, name, 0);
			if (r == E_OK)
			{
				r = __FUTIME (c, (ushort *) arg);
				c->links--;
			}
			
			FAT_DEBUG (("fatfs_fscntl: leave (FUTIME) (r = %li)", r));
			return r;
		}
		case FTRUNCATE:
		{
			COOKIE *c;
			long r;
			
			r = search_cookie ((COOKIE *) dir->index, &c, name, 0);
			if (r == E_OK)
			{
				r = __FTRUNCATE (c, arg);
				c->links--;
			}
			
			FAT_DEBUG (("fatfs_fscntl: leave (FTRUNCATE) (r = %li)", r));
			return r;
		}
	}
	
	FAT_DEBUG (("fatfs_fscntl: invalid function"));
	return ENOSYS;
}

static long _cdecl
fatfs_dskchng (int drv, int mode)
{
	long change = 1;
	
	FAT_DEBUG (("fatfs_dskchng: enter (drv = %c, mode = %i)", 'A'+drv, mode));
	
	if (mode == 0)
	{
		change = BIO_DSKCHNG (DI (drv));
	}
	
	if (change == 0)
	{
		/* no change */
		FAT_DEBUG (("fatfs_dskchng: leave no change"));
		return change;
	}
	
	FAT_DEBUG (("fatfs_dskchng: invalidate drv (change = %li)", change));
	
	/* I hope this isn't a failure */
	bio.sync_drv (DI (drv));
	
	/* invalid all cookies */
	{
		register long i;
		for (i = 0; i < COOKIE_CACHE; i++)
		{
			register COOKIE *c = &(cookies[i]);
			if (c->dev == drv)
			{
				if (c->name)
				{
					c_del_cookie (c);
				}
			}
		}
	}
	
	/* free the DI (also invalidate cache units) */
	bio.free_di (DI (drv));
	
	/* invalidate the BPB */
	BPBVALID (drv) = INVALID;
	
	/* free the dynamically allocated memory */
	kfree (BPB (drv)); BPB (drv) = NULL;
	
	FAT_DEBUG (("fatfs_dskchng: leave (change = %li)", change));
	return change;
}

static long _cdecl
fatfs_release (fcookie *fc)
{
	register COOKIE *c = (COOKIE *) fc->index;
# ifdef FS_DEBUG
	register long links = c->links;
# endif
	
	if (c->links)
		c->links--;
	
	FAT_DEBUG (("fatfs_release [%s]: ok (c->dev = %i, c->links = %li -> %li)", c->name, c->dev, links, c->links));
	return E_OK;
}

static long _cdecl
fatfs_dupcookie (fcookie *dst, fcookie *src)
{
	register COOKIE *c = (COOKIE *) src->index;
	
	c->links++;
	*dst = *src;
	
	FAT_DEBUG (("fatfs_dupcookie [%s]: ok (c->dev = %i, c->links = %li)", c->name, c->dev, c->links));
	return E_OK;
}

static long _cdecl
fatfs_sync (void)
{
	ushort drv;
	
	/* update FAT32 info sectors */
	for (drv = 0; drv < NUM_DRIVES; drv++)
		if (BPBVALID (drv) && FAT32 (drv) && FAT32info (drv))
			upd_fat32info (drv);
	
	/* buffer cache automatically synced */
	
	FAT_DEBUG (("fatfs_sync: ok"));
	return E_OK;
}

static long _cdecl
fatfs_unmount (int drv)
{
	fatfs_dskchng (drv, 1);
	
	return E_OK;
}

/* END filesystem */
/****************************************************************************/

/****************************************************************************/
/* BEGIN device driver */

/*
 * internal
 */

static long
__FUTIME (COOKIE *c, ushort *ptr)
{
	long r;
	
	FAT_DEBUG (("__FUTIME [%s]: enter", c->name));
	
	if (RDONLY (c->dev))
		return EROFS;
	
	/* VFAT adate */
	if (VFAT (c->dev))
	{
		if (ptr)
			c->info.adate = cpu2le16 (ptr[1]);
		else
			c->info.adate = cpu2le16 (datestamp);
	}
	
	/* mtime/mdate */
	if (ptr)
	{
		c->info.time = cpu2le16 (ptr[2]);
		c->info.date = cpu2le16 (ptr[3]);
	}
	else
	{
		c->info.time = cpu2le16 (timestamp);
		c->info.date = cpu2le16 (datestamp);
	}
	
	FAT_DEBUG (("__FUTIME: leave return write_cookie"));
	
	/* write and leave */
	r = write_cookie (c);
	
	if (c->dev == 0 || c->dev == 1)
	{
		bio_SYNC_DRV ((&bio), DI (c->dev));
	}
	
	return r;
}

static long
__FTRUNCATE (COOKIE *c, long newlen)
{
	const long oldlen = c->flen;
	long cl = newlen / CLUSTSIZE (c->dev);
	long actual;
	long r;
	
	FAT_DEBUG (("__FTRUNCATE [%s]: enter (newlen = %li)", c->name, newlen));
	
	if (RDONLY (c->dev))
		return EROFS;
	
	/* range check */
	if (newlen > oldlen) return EBADARG;
	
	/* avoid simple case */
	if (newlen == oldlen) return E_OK;
	
	if (newlen && (newlen % CLUSTSIZE (c->dev) == 0))
	{
		/* correct cluster boundary */
		cl--;
	}
	
	/* search the new last cluster */
	actual = GETCL (c->stcl, c->dev, cl);
	if (actual <= 0)
	{
		/* bad clustered or read error */
		FAT_DEBUG (("__FTRUNCATE: leave failure, bad clustered (error = %li)", actual));
		return actual;
	}
	
	/* truncate cluster chain and update last cluster */
	r = GETCL (actual, c->dev, 1);
	if (r > 0)
	{
		(void) del_chain (r, c->dev);
		(void) FIXCL (actual, c->dev, CLLAST);
	}
	
	/* write new file len */
	c->flen = newlen;
	c->info.flen = cpu2le32 (newlen);
	
	FAT_DEBUG (("__FTRUNCATE: leave return write_cookie"));
	
	/* write and leave */
	r = write_cookie (c);
	
	bio_SYNC_DRV ((&bio), DI (c->dev));
	return r;
}

static long
__FIO (FILEPTR *f, char *buf, long bytes, ushort mode)
{
	COOKIE *c = (COOKIE *) f->fc.index;
	FILE *ptr = (FILE *) f->devinfo;
	const ushort dev = c->dev;
	long actual = ptr->actual;
	long temp = c->flen - f->pos;
	long todo;
	long offset;
	long data;
	
	FAT_DEBUG (("__FIO [%s]: enter (bytes = %li, mode: %s)", c->name, bytes, (mode == READ) ? "READ" : "WRITE"));
	FAT_DEBUG (("__FIO: f->pos = %li, ptr->actual = %li", f->pos, ptr->actual));
	
	if (ptr->error < 0)
	{
		register long i = ptr->error;
		ptr->error = 0;
		FAT_DEBUG (("__FIO: ERROR (value = %li)", i));
		return i;
	}
	
	if (bytes <= 0)
	{
		FAT_DEBUG (("__FIO: ERROR -> bytes = %li)", bytes));
		
		if (bytes < 0 && mode == READ)
		{
			/* hmm, Draco's idea */
			
			bytes = 2147483647L; /* LONG_MAX */
			FAT_DEBUG (("__FIO: (fix) mode == READ -> bytes = %li", bytes));
		}
		else
		{
			FAT_DEBUG (("__FIO: return 0"));
			return 0;
		}
	}
	
	if (mode == READ)
	{
		if (temp <= 0)
		{
			FAT_DEBUG (("__FIO: leave, file end (left = %li)", temp));
			return 0;
		}
		bytes = MIN (bytes, temp);
	}
	else
	{
		if (RDONLY (dev))
			return 0;
	}
	
	todo = bytes;
	
	if (c->stcl == 0)
	{
		/* no first cluster,
		 * here only writing, if reading we leave before (while flen == 0)
		 */
		actual = nextcl (0, dev);
		if (actual <= 0)
		{
			FAT_DEBUG (("__FIO: leave failure (nextcl = %li)", actual));
			return EACCES;
		}
		c->stcl = ptr->actual = actual;
		PUT_STCL (&(c->info), dev, actual);
	}
	
	while (todo > 0)
	{
		temp = f->pos / CLUSTSIZE (dev);
		if (temp > ptr->cl)
		{
			/* get next cluster */
			
			FAT_DEBUG (("__FIO: temp - ptr->cl = %li", temp - ptr->cl));
			
			actual = NEXTCL (actual, dev, mode);
			if (actual <= 0)
			{
				/* bad clustered */
				ptr->error = actual;
				FAT_DEBUG (("__FIO: leave failure, bad clustered (return = %li)", bytes - todo));
				break;
			}
			
			ptr->actual = actual;
			ptr->cl++;
		}
		
		/* offset */
		offset = f->pos % CLUSTSIZE (dev);
		
		if ((todo >= CLUSTSIZE (dev)) && (offset == 0))
		{
			register long cls = 1;
			data = CLUSTSIZE (dev);
			
			FAT_DEBUG (("__FIO: CLUSTER (todo = %li, pos = %li)", todo, f->pos));
			
			if (todo - data > CLUSTSIZE (dev))
			{
				register long oldcl = ptr->actual;
				register long newcl = NEXTCL (oldcl, dev, mode);
				
				/* linear read/write optimization */
				while ((newcl > 0) && (newcl == (oldcl + 1)))
				{
					data += CLUSTSIZE (dev);
					cls++;
					
					ptr->actual++;
					ptr->cl++;
					
					if (todo - data > CLUSTSIZE (dev))
					{
						oldcl = newcl;
						newcl = NEXTCL (oldcl, dev, mode);
					}
					else
						break;
				}
			}
			
			FAT_DEBUG (("__FIO: CLUSTER (data = %li, cluster = %li)", data, cls));
			
			/* read/write direct */
			if (mode == READ)
			{
				ptr->error = bio_data_l_read (dev, DI (dev), C2S (actual, dev), cls, CLUSTSIZE (dev), buf);
			}
			else
			{
				ptr->error = bio_data_l_write (dev, DI (dev), C2S (actual, dev), cls, CLUSTSIZE (dev), buf);
			}
			
			if (ptr->error)
			{
				FAT_DEBUG (("__FIO: leave failure, read/write direct"));
				break;
			}
			
			actual = ptr->actual;
		}
		else
		{
			UNIT *u;
			
			FAT_DEBUG (("__FIO: BYTES (todo = %li, pos = %li)", todo, f->pos));
			
			data = CLUSTSIZE (dev) - offset;
			data = MIN (todo, data);
			
			/* read the unit */
			u = bio_data_read (dev, DI (dev), C2S (ptr->actual, dev), CLUSTSIZE (dev));
			if (!u)
			{
				ptr->error = EREAD;
				FAT_DEBUG (("__FIO: leave failure, read unit (return = %li, dev = %i)", bytes - todo, dev));
				break;
			}
			
			if (mode == READ)
			{
				/* copy */
				
				quickmovb (buf, (u->data + offset), data);
			}
			else
			{
				/* copy and write */
				
				quickmovb ((u->data + offset), buf, data);
				bio_MARK_MODIFIED ((&bio), u);
			}
		}
		
		buf += data;
		todo -= data;
		f->pos += data;
	}
	
	if (mode == WRITE)
	{
		if (f->pos > c->flen)
		{
			c->flen = f->pos;
			c->info.flen = cpu2le32 (f->pos);
		}
		if (c->info.attr != FA_SYMLINK
			&& !(c->info.attr & FA_CHANGED))
		{
			c->info.attr |= FA_CHANGED;
		}
		c->info.time = cpu2le16 (timestamp);
		c->info.date = cpu2le16 (datestamp);
		ptr->error = write_cookie (c);
		
		if (!BIO_WB_CHECK (DI (dev)))
		{
			/* this reduce overkill syncs
			 * in writethrough mode
			 */
			if (bytes > CLUSTSIZE (dev)
				&& f->pos % CLUSTSIZE (dev) == 0)
			{
				bio.sync_drv (DI (dev));
			}
		}
	}
	
	FAT_DEBUG (("__FIO: leave ok (todo = %li, processed = %li, pos = %li)", todo, bytes - todo, f->pos));
	return (bytes - todo);
}

/*
 * external
 */

static long _cdecl
fatfs_open (FILEPTR *f)
{
	COOKIE *c = (COOKIE *) f->fc.index;
	FILE *ptr;
	
	FAT_DEBUG (("fatfs_open [%s]: enter", c->name));
	
	if (c->open && denyshare (c->open, f))
	{
		FAT_DEBUG (("fatfs_open: file sharing denied"));
		return EACCES;
	}
	
	if (c->info.attr & FA_LABEL || c->info.attr & FA_DIR)
	{
		FAT_DEBUG (("fatfs_open: leave failure, not a valid file"));
		return EACCES;
	}
	
	ptr = kmalloc (sizeof (*ptr));
	if (!ptr)
	{
		FAT_ALERT (("fatfs.c: kmalloc fail in: fatfs_open (%s)", c->name));
		FAT_DEBUG (("fatfs_open: leave failure, memory out for FILE struct"));
		return ENOMEM;
	}
	
	ptr->mode = f->flags;
	ptr->actual = c->stcl;
	ptr->cl = 0;
	ptr->error = 0;
	
	if (ptr->mode & O_TRUNC && (c->flen || c->stcl))
	{
		long r;
		
		FAT_DEBUG (("fatfs_open: truncate file to 0 bytes (flen = %li, stcl = %li)", c->flen, c->stcl));
		
		c->flen = 0;
		c->info.flen = 0;
		c->info.stcl = c->info.stcl_fat32 = 0;
		
		r = write_cookie (c);
		if (r)
		{
			kfree (ptr);
			FAT_DEBUG (("fatfs_open: leave failure (write_cookie = %li)", r));
			return r;
		}
		
		FAT_DEBUG (("fatfs_open: del_chain"));
		if (c->stcl)
		{
			(void) del_chain (c->stcl, c->dev);
			c->stcl = 0;
		}
		
		bio_SYNC_DRV ((&bio), DI (c->dev));
	}
	
	if ((ptr->mode & O_RWMODE) == O_EXEC)
	{
		ptr->mode = (ptr->mode ^ O_EXEC) | O_RDONLY;
	}
	
	f->pos = 0;
	f->next = c->open;
	c->open = f;
	c->links++;
	
	f->devinfo = (long) ptr;
	
	FAT_DEBUG (("fatfs_open: leave ok"));
	return E_OK;
}

static long _cdecl
fatfs_write (FILEPTR *f, const char *buf, long bytes)
{
	FAT_DEBUG (("fatfs_write [%s]: enter (bytes = %li)", ((COOKIE *) f->fc.index)->name, bytes));
	
	if ((((FILE *) f->devinfo)->mode & O_RWMODE) == O_RDONLY)
	{
		FAT_DEBUG (("fatfs_write: leave failure (bad mode)"));
		return EACCES;
	}
	
	FAT_DEBUG (("fatfs_write: leave return __FIO ()"));
	return __FIO (f, (char *) buf, bytes, WRITE);
}

static long _cdecl
fatfs_read (FILEPTR *f, char *buf, long bytes)
{
	FAT_DEBUG (("fatfs_read [%s]: enter (bytes = %li)", ((COOKIE *) f->fc.index)->name, bytes));

	if ((((FILE *) f->devinfo)->mode & O_RWMODE) == O_WRONLY)
	{
		FAT_DEBUG (("fatfs_read: leave failure (bad mode)"));
		return EACCES;
	}
	
	FAT_DEBUG (("fatfs_read: leave return __FIO (bytes = %li)", bytes));
	return __FIO (f, buf, bytes, READ);
}

static long _cdecl
fatfs_lseek (FILEPTR *f, long where, int whence)
{
	register COOKIE *c = (COOKIE *) f->fc.index;
	register FILE *ptr = (FILE *) f->devinfo;
	
	FAT_DEBUG (("fatfs_lseek [%s]: enter (where = %li, whence = %i)", c->name, where, whence));
	
	switch (whence)
	{
		case SEEK_SET:				break;
		case SEEK_CUR:	where += f->pos;	break;
		case SEEK_END:	where += c->flen;	break;
		default:	return ENOSYS;
	}
	
	if (where > c->flen || where < 0)
	{
		FAT_DEBUG (("fatfs_lseek: leave failure EBADARG (where = %li)", where));
		return EBADARG;
	}
	
	if (where == 0)
	{
		f->pos = 0;
		ptr->cl = 0;
		ptr->actual = c->stcl;
		
		FAT_DEBUG (("fatfs_lseek: leave ok (where = %li)", where));
		return 0;
	}
	
	{	/* calculate and set the new actual cluster and position */
		
		long actual = 0;
		register long cl = where / CLUSTSIZE (c->dev);
		
		if ((where % CLUSTSIZE (c->dev) == 0) && (where == c->flen))
		{
			/* correct cluster boundary */
			cl--;
		}
		
		if (cl != ptr->cl)
		{
			if (cl > ptr->cl)
			{
				actual = GETCL (ptr->actual, c->dev, cl - ptr->cl);
			}
			else
			{
				actual = GETCL (c->stcl, c->dev, cl);
			}
			
			if (actual <= 0)
			{
				/* bad clustered or read error */
				ptr->error = actual;
				
				FAT_DEBUG (("fatfs_lseek: leave failure, bad clustered (ptr->error = %li)", ptr->error));
				return EACCES;
			}
			
			ptr->cl = cl;
			ptr->actual = actual;
		}
		
		f->pos = where;
	}
	
	FAT_DEBUG (("fatfs_lseek: leave ok (f->pos = %li)", f->pos));
	return where;
}

/*
 * the following function based on 'tos_ioctl' from 'tosfs.c'
 * please notice the right copyright
 */

static long _cdecl
fatfs_ioctl (FILEPTR *f, int mode, void *buf)
{
	COOKIE *c = (COOKIE *) f->fc.index;
	
	FAT_DEBUG (("fatfs_ioctl [%s]: enter (mode = %i)", c->name, mode));
	
	switch (mode)
	{
		case FIONREAD:
		{
			long bytes;
			
			bytes = c->flen - f->pos;
			if (bytes < 0)
				bytes = 0;
			
			*(long *) buf = bytes;
			return E_OK;
		}
		case FIONWRITE:
		{
			*(long *) buf = 1;
			return E_OK;
		}
		case FIOEXCEPT:
		{
			*(long *) buf = 0;
			return E_OK;
		}
		case FUTIME:
		{
			return __FUTIME (c, buf);
		}
		case FTRUNCATE:
		{
			long r;
			
			if ((f->flags & O_RWMODE) == O_RDONLY)
			{
				return EACCES;
			}
			
			r = __FTRUNCATE (c, *(long *) buf);
			if (r == E_OK)
			{
				long pos = f->pos;
				(void) fatfs_lseek (f, 0, SEEK_SET);
				(void) fatfs_lseek (f, pos, SEEK_SET);
			}
			
			return r;
		}
		case F_SETLK:
		case F_SETLKW:
		case F_GETLK:
		{
			struct flock *fl = (struct flock *) buf;
			
			LOCK t;
			LOCK *lck;
			
			t.l = *fl;
			
			switch (t.l.l_whence)
			{
				case SEEK_SET:
				{
					break;
				}
				case SEEK_CUR:
				{
					long r = fatfs_lseek (f, 0L, SEEK_CUR);
					t.l.l_start += r;
					break;
				}
				case SEEK_END:
				{
					long r = fatfs_lseek (f, 0L, SEEK_CUR);
					t.l.l_start = fatfs_lseek (f, t.l.l_start, SEEK_END);
					(void) fatfs_lseek (f, r, SEEK_SET);
					break;
				}
				default:
				{
					FAT_DEBUG (("fatfs_ioctl: invalid value for l_whence"));
					return ENOSYS;
				}
			}
			
			if (t.l.l_start < 0) t.l.l_start = 0;
			t.l.l_whence = 0;
			
			if (mode == F_GETLK)
			{
				lck = denylock (c->locks, &t);
				if (lck)
				{
					*fl = lck->l;
				}
				else
				{
					fl->l_type = F_UNLCK;
				}
				
				return E_OK;
			}
			
			if (t.l.l_type == F_UNLCK)
			{
				/* try to find the lock */
				LOCK **lckptr = &(c->locks);
				
				lck = *lckptr;
				while (lck)
				{
					if (lck->l.l_pid == curproc->pid
						&& lck->l.l_start == t.l.l_start
						&& lck->l.l_len == t.l.l_len)
					{
						/* found it -- remove the lock */
						*lckptr = lck->next;
						FAT_DEBUG (("fatfs_ioctl: unlocked %s: %ld + %ld", c->name, t.l.l_start, t.l.l_len));
						/* (void) fatfs_lock (f, 1, t.l.l_start, t.l.l_len); */
						
						/* wake up anyone waiting on the lock */
						wake (IO_Q, (long) lck);
						kfree (lck);
						
						return E_OK;
					}
					
					lckptr = &(lck->next);
					lck = lck->next;
				}
				
				return ENSLOCK;
			}
			
			FAT_DEBUG (("fatfs_ioctl: lock %s: %ld + %ld", c->name, t.l.l_start, t.l.l_len));
			
			do {
				long r;
				
				/* see if there's a conflicting lock */
				while ((lck = denylock (c->locks, &t)) != 0)
				{
					FAT_DEBUG (("fatfs_ioctl: lock conflicts with one held by %d", lck->l.l_pid));
					if (mode == F_SETLKW)
					{
						/* sleep a while */
						sleep (IO_Q, (long) lck);
					}
					else
					{
						return ELOCKED;
					}
				}
				
				/* if not, add this lock to the list */
				lck = kmalloc (sizeof (*lck));
				if (!lck)
				{
					FAT_ALERT (("fatfs.c: kmalloc fail in: fatfs_ioctl (%s)", c->name));
					return ENOMEM;
				}
				
				r = E_OK; /* fatfs_lock (f, 0, t.l.l_start, t.l.l_len); */
				if (r)
				{
					kfree (lck);
					if (mode == F_SETLKW && r == ELOCKED)
					{
						yield ();
						lck = NULL;
					}
					else
					{
						return r;
					}
				}
			}
			while (!lck);
			
			lck->l = t.l;
			lck->l.l_pid = curproc->pid;
			lck->next = c->locks;
			c->locks = lck;
			
			/* mark the file as being locked */
			f->flags |= O_LOCK;
			return E_OK;
		}
	}
	
	FAT_DEBUG (("fatfs_ioctl: return ENOSYS"));
	return ENOSYS;
}

static long _cdecl
fatfs_datime (FILEPTR *f, ushort *time, int rwflag)
{
	COOKIE *c = (COOKIE *) f->fc.index;
	register FILE *ptr = (FILE *) f->devinfo;
	
	FAT_DEBUG (("fatfs_datime [%s]: enter", c->name));
	
	if (rwflag)
	{
		/* set the date/time */
		
		if (RDONLY (c->dev))
			return EROFS;
		
		c->info.time = cpu2le16 (time[0]);
		c->info.date = cpu2le16 (time[1]);
		
		if (VFAT (c->dev))
		{
			c->info.adate = c->info.date;
		}
		
		ptr->error = write_cookie (c);
		
		if (c->dev == 0 || c->dev == 1)
		{
			bio_SYNC_DRV ((&bio), DI (c->dev));
		}
	}
	else
	{
		/* read the date/time */
		
		time[0] = le2cpu16 (c->info.time);
		time[1] = le2cpu16 (c->info.date);
	}
	
	FAT_DEBUG (("fatfs_datime: leave ok"));
	return E_OK;
}

static long _cdecl
fatfs_close (FILEPTR *f, int pid)
{
	COOKIE *c = (COOKIE *) f->fc.index;
	
	FAT_DEBUG (("fatfs_close [%s]: enter (f->links = %i)", c->name, f->links));
	
/*
 * the following code based on 'tos_close' from 'tosfs.c'
 * please notice the right copyright
 *
 * start
 */
	/* if a lock was made, remove any locks of the process */
	if (f->flags & O_LOCK)
	{
		LOCK *lock;
		LOCK **oldlock;
		
		FAT_DEBUG (("fatfs_close: remove lock (pid = %i)", pid));
		
		oldlock = &c->locks;
		lock = *oldlock;
		
		while (lock)
		{
			if (lock->l.l_pid == pid)
			{
				*oldlock = lock->next;
				/* (void) fatfs_lock (f, 1, lock->l.l_start, lock->l.l_len); */
				wake (IO_Q, (long) lock);
				kfree (lock);
			}
			else
			{
				oldlock = &lock->next;
			}
			lock = *oldlock;
		}
	}
/* end */
	
	if (f->links <= 0)
	{
		register FILEPTR **temp;
		register long flag = 1;
		
		/* remove the FILEPTR from the linked list */
		temp = &c->open;
		while (*temp)
		{
			if (*temp == f)
			{
				*temp = f->next;
				f->next = NULL;
				flag = 0;
				break;
			}
			temp = &(*temp)->next;
		}
		
		if (flag)
		{
			FAT_ALERT (("fatfs.c: remove open FILEPTR fail in: fatfs_close (%s)", c->name));
		}
		
		/* free the extra info */
		kfree ((FILE *) f->devinfo);
		
		c->links--;
	}
	
	bio_SYNC_DRV ((&bio), DI (c->dev));
	
	FAT_DEBUG (("fatfs_close: leave ok"));
	return E_OK;
}

/* END device driver */
/****************************************************************************/

/****************************************************************************/
/* BEGIN debug infos */

# ifdef FS_DEBUG

# include <stdarg.h>
# include "dosfile.h"

static void
fatfs_debug (const char *fmt, ...)
{
	static char buf [SPRINTF_MAX];
	static const long buflen = sizeof (buf);
	
	va_list args;
	FILEPTR *f;
	
	va_start (args, fmt);
	f = do_open (FS_LOGFILE, (O_WRONLY | O_CREAT | O_APPEND), 0, NULL);
	if (f)
	{
		(void) (*f->dev->lseek)(f, 0, SEEK_END);
		
		(void) vsprintf (buf, buflen, fmt, args);
		(*f->dev->write)(f, buf, strlen (buf));
		(*f->dev->write)(f, "\r\n", 2);
		
		do_close (f);
	}
	else
	{
		(void) vsprintf (buf, buflen, fmt, args);
		DEBUG ((buf));
	}
	va_end (args);
}

static void
fatfs_print_dir (const _DIR *d, ushort dev)
{
	char attr[SPRINTF_MAX];
	char stime[20];
	char sdate[20];
	long i = 0;
	
	attr [0] = '\0';
	
	if (d->attr & FA_RDONLY)
	{
		ksprintf (attr + i, sizeof (attr) - i, "READONLY  ");
		i += 10;
	}
	if (d->attr & FA_HIDDEN)
	{
		ksprintf (attr + i, sizeof (attr) - i, "HIDDEN    ");
		i += 10;
	}
	if (d->attr & FA_SYSTEM)
	{
		ksprintf (attr + i, sizeof (attr) - i, "SYSTEM    ");
		i += 10;
	}
	if (d->attr & FA_LABEL)
	{
		ksprintf (attr + i, sizeof (attr) - i, "LABEL     ");
		i += 10;
	}
	if (d->attr & FA_DIR)
	{
		ksprintf (attr + i, sizeof (attr) - i, "DIR       ");
		i += 10;
	}
	if (d->attr & FA_CHANGED)
	{
		ksprintf (attr + i, sizeof (attr) - i, "CHANGED   ");
		i += 10;
	}
	
	{
		ushort time = le2cpu16 (d->time);
		ushort date = le2cpu16 (d->date);
		
		ksprintf (stime, sizeof (stime), "%d:%d,%d",
			((time >> 11) & 31),
			((time >> 5) & 63),
			((time & 31) << 1));
		
		ksprintf (sdate, sizeof (sdate), "%d.%d.19%d",
			 (date & 31),
			 ((date >> 5) & 15),
			 (80 + ((date >> 9) & 127)));
	}
	
	FAT_DEBUG ((
		"---\r\n"
		"name: %s, attr: %s\r\n"
		"time: %s, date: %s\r\n"
		"stcl: %u, flen: %lu",
		d->name, attr,
		stime, sdate,
		le2cpu16 (d->stcl), le2cpu32 (d->flen)
	));
}

static void
fatfs_dump_hashtable (void)
{
	static char buf [SPRINTF_MAX];
	static const long buflen = sizeof (buf);
	FILEPTR *f;
	
	FAT_FORCE (("fatfs.c: dynamic used memory = %li bytes", fatfs_dynamic_mem));
	
	f = do_open (FS_DUMPFILE, (O_WRONLY | O_CREAT | O_TRUNC), 0, NULL);
	if (f)
	{
		long i;
		
		(void) ksprintf (buf, buflen, "fatfs.c: dynamic used memory = %li bytes\r\n", fatfs_dynamic_mem);
		(*f->dev->write)(f, buf, strlen (buf));
		
		(*f->dev->write)(f, "BPBs:\r\n", 7);
		for (i = 0; i < NUM_DRIVES; i++)
		{
			(void) ksprintf (buf, buflen,
				"nr: %2li  valid = %1li  drv = %2i"
				"  c_hits = %6ld  c_miss = %6ld\r\n",
				i,
				(long) BPBVALID (i),
				BPBVALID (i) ? DI(i)->drv : -1,
				C_HIT (i),
				C_MISS (i)
			);
			(*f->dev->write)(f, buf, strlen (buf));
		}
		
		(*f->dev->write)(f, "cookies:\r\n", 10);
		for (i = 0; i < COOKIE_CACHE; i++)
		{
			(void) ksprintf (buf, buflen,
				"nr: %li\tlinks = %li\tdev = %i\tname = %s\r\n",
				i,
				cookies[i].links,
				cookies[i].dev,
				cookies[i].name
			);
			(*f->dev->write)(f, buf, strlen (buf));
		}
		
		(*f->dev->write)(f, "table:\r\n", 8);
		for (i = 0; i < COOKIE_CACHE; i++)
		{
			COOKIE *temp = ctable [i];
			(void) ksprintf (buf, buflen, "nr: %li\tptr = %lx", i, temp);
			(*f->dev->write)(f, buf, strlen (buf));
			for (; temp; temp = temp->next)
			{
				(void) ksprintf (buf, buflen, "\r\n"
					"\tnext = %lx\tlinks = %li"
					"\tdev = %i\tname = %s\r\n",
					temp->next,
					temp->links,
					temp->dev,
					temp->name
				);
				(*f->dev->write)(f, buf, strlen (buf));	
			}
			(*f->dev->write)(f, "\r\n", 2);
		}
		
		do_close (f);
	}
}

# if FS_DEBUG_COOKIE
static void
fatfs_print_cookie (COOKIE *c)
{
	FAT_DEBUG (("c->name = %s", c->name));
	FAT_DEBUG (("c->links = %li, c->dev = %i", c->links, c->dev));
	FAT_DEBUG (("c->dir = %li, c->offset = %li, c->stcl = %li", c->dir, c->offset, c->stcl));
	FAT_DEBUG (("c->slots = %u", c->slots));
	FAT_DEBUG_PRINTDIR ((&(c->info), c->dev));
}
# endif /* FS_DEBUG_COOKIE */

# endif /* FS_DEBUG */

/* END debug infos */
/****************************************************************************/
