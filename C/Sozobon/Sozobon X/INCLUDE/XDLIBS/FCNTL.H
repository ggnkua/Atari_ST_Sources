/*
 *	FCNTL.H
 */

#ifndef	_FCNTL_H
#define	_FCNTL_H

/*
 * defines for the access() function
 */
#define	F_OK			0
#define	X_OK			1
#define	W_OK			2
#define	R_OK			4

/* 
 * defines for iomode in open(), or TOS/MiNT Fopen()
 * MagiC doesn't support all these flags this time
 */
#define _MIN_FILE_HANDLE -3

#define O_ACCMODE	0x03		/* used to mask off file access mode */
#ifndef _file_h
#define	O_RDONLY	0x00		/* read only */
#define	O_WRONLY	0x01		/* write only */
#define	O_RDWR		0x02		/* read/write */

#define	O_APPEND	0x08		/* position at EOF */

#define O_SHMODE	0x70	/* isolates file sharing mode */
#	define O_COMPAT	0x00	/* compatibility mode */
#	define O_DENYRW	0x10	/* deny both read and write access */
#	define O_DENYW	0x20	/* deny write access to others */
#	define O_DENYR	0x30	/* deny read access to others */
#	define O_DENYNONE 0x40	/* don't deny any access to others */

#define O_NOINHERIT	0x80	/* private file (not passed to child) */

#define O_NDELAY	0x100	/* don't block for i/o on this file */
#define O_CREAT		0x200	/* create file if it doesn't exist */
#define O_TRUNC		0x400	/* truncate file to 0 bytes if it does exist */
#define O_EXCL		0x800	/* fail open if file exists */

#define O_GLOBAL	0x1000	/* for opening a global file */
#endif

extern int	creat(const char *filename, int pmode);
extern int	open(const char *filename, int iomode, int pmode);

#endif /* _FCNTL_H */
