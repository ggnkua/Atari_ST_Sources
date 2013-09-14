/*
 * stat.h -- support stat() and fstat() system calls.
 *
 * Copyright (c) 1986-1987, Mark Williams Company, Chicago
 * This file and its contents may not be copied or distributed
 * without permission.
 */

#ifndef STAT_H
#define	STAT_H
#include <time.h>
/*
 * Structure returned by stat and fstat system calls.
 * NB: fstat cannot work, but it does return the times.
 */
struct stat {
	short	st_dev;			/* Device */
	short	st_ino;			/* Inode number */
	short	st_mode;		/* Mode */
	short	st_nlink;		/* Link count */
	short	st_uid;			/* User id */
	short	st_gid;			/* Group id */
	short	st_rdev;		/* Real device */
	long	st_size;		/* Size */
	time_t	st_atime;		/* Access time */
	time_t	st_mtime;		/* Modify time */
	time_t	st_ctime;		/* Change time */
};

/*
 * Modes, a la GEM-DOS:
 */
#define S_IJRON	0x01			/* Read-only */
#define S_IJHID	0x02			/* Hidden from search */
#define S_IJSYS	0x04			/* System, hidden from search */
#define S_IJVOL	0x08			/* Volume label in first 11 bytes */
#define S_IJDIR	0x10			/* Directory */
#define S_IJWAC	0x20			/* Written to and closed */

/*
 * "DMA" buffer structure for Fsfirst() and Fsnext().
 */
typedef struct {
	char	d_glob[12];	/* GEMDOS wildcard string from Fsfirst */
	char	d_mask;		/* Attribute mask from Fsfirst */
	char	d_dirent[4];	/* Offset into directory, MSB first */
	char	d_dirid[4];	/* Pointer to directory structure in GEM mem */
	char	d_fattr;	/* File attributes */
	long	d_tandd;	/* Time and date words */
	long	d_fsize;	/* File size */
	char 	d_fname[14];	/* File name */
} DMABUFFER;

/*
 * COHERENT compatibility.
 */
#define S_IFMT	(S_IJDIR|S_IJVOL)	/* Type */
#define S_IFDIR	S_IJDIR			/* Directory */
#define S_IFCHR	0xFFFF			/* Character special */
#define S_IFBLK	0xFFFF			/* Block special */
#define S_IFREG	0			/* Regular */
#define S_IFMPC	0xFFFF			/* Multiplexed character special */
#define S_IFMPB	0xFFFF			/* Multiplexed block special */
#define	S_IFPIP	0xFFFF			/* Pipe */
#define	S_ISUID	0			/* Set user id on execution */
#define S_ISGID	0			/* Set group id on execution */
#define	S_ISVTX	0			/* Save swapped text even after use */
#define S_IREAD	0			/* Read permission, owner */
#define S_IWRITE 0			/* Write permission, owner */
#define S_IEXEC	0			/* Execute/search permission, owner */

/*
 * Non-existent device.
 */
#define NODEV	(-1)

/*
 * Functions:
 */
#define	major(dev)	((dev>>8)&0377)
#define minor(dev)	(dev&0377)
#define makedev(m1, m2)	((m1<<8)|m2)

#endif

/* End of stat.h */
