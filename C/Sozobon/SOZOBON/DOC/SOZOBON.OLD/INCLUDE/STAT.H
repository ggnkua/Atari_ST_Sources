/*
 *	STAT.H
 */

#ifndef	STAT_H
#define	STAT_H

#include <types.h>

struct stat			/* maps to the DTA up to the st_name field */
	{
	char	st_rsvd[21];		/* reserved field. DON'T TOUCH! */
	uchar	st_mode;		/* file mode flags */
	time_t	st_mtime;		/* last modification time/date */
	long	st_size;		/* file size in bytes */
	char	st_name[14];		/* file name */
	dev_t	st_dev;			/* drive id (0 == A:) */
	uchar	st_nlink;		/* number of links (always == 1) */
	};

#define	st_atime	st_mtime	/* last access time */
#define	st_ctime	st_mtime	/* creation time */
#define	st_rdev		st_dev		/* drive id */

#define	S_IFMT		0xD6		/* mask for type of file */
#define	S_IFHID		0x02		/* hidden */
#define	S_IFSYS		0x04		/* system */
#define	S_IFDIR		0x10		/* directory */
#define	S_IREAD		0x40		/* read permission */
#define	S_IWRITE	0x80		/* write permission */
#define	S_ISRO		0x01		/* file is read-only */
#define	S_ISVOL		0x08		/* file is volume label */
#define	S_ISARC		0x20		/* file is written to and closed? */

#endif STAT_H
