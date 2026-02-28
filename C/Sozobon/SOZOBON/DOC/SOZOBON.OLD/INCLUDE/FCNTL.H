/*
 *	FCNTL.H
 */

#ifndef	FCNTL_H
#define	FCNTL_H

#define	O_RDONLY	0x00		/* read only */
#define	O_WRONLY	0x01		/* write only */
#define	O_RDWR		0x02		/* read/write */
#define	O_APPEND	0x10		/* position at EOF */
#define	O_CREAT		0x20		/* create new file if needed */
#define	O_TRUNC		0x40		/* make file 0 length */
#define	O_EXCL		0x80		/* error if file exists */

#endif FCNTL_H
