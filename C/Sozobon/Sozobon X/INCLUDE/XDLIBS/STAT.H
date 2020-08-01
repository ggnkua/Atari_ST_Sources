/*
 * @(#)stat.h, XdLibs, SozobonX
 * 
 */

#ifndef	_STAT_H
#define	_STAT_H

#ifndef _TYPES_H
#include <types.h>
#endif
/* 
 * changed by jerry
 * now compatible to standard,
 * stat() now uses fxattr if _mint is set.
 * if _mint is not set, the fields:
 * 		st_index, st_uid, st_gid, st_atime, st_ctime
 * 		are set to 0;
 * 		st_size, st_nblocks is set to -1 for directories
 * though Mint is running these fields mustn't have proper values set!
 * this depends on the filesystem, the file is from.
 */


struct stat
	{
	unsigned short	st_mode;	/* file mode flags */
	long	st_index;
	dev_t	st_dev;				/* device id (0 == A:) */
	unsigned short	st_nlink;	/* number of links */
	unsigned short	st_uid;		/* owner's user id */
	unsigned short	st_gid;		/* 		group id */
	long	st_size;		/* file size in bytes */
	long	st_blksize;		/* size of a block in bytes  	*/
	long	st_nblocks;		/* no of blocks used	*/
	time_t	st_mtime;	/* last modification date/time 				*/
	time_t	st_atime;	/*   of course in our XDlibs rawtime format	*/
	time_t	st_ctime;
	short	st_attr;		/* GEMDOS file attribs	*/
};

#define	st_rdev		st_dev		/* drive id */

#define	S_IFMT			0170000
#define	S_IFCHR			0020000
#define	S_IFDIR			0040000
#define S_IFBLK			0060000
#define	S_IFREG			0100000
#define S_IFIFO			0120000
#define S_IMEM			0140000
#define	S_IFLNK			0160000

#define S_ISCHR(m)		((m & S_IFMT) == S_IFCHR)
#define S_ISDIR(m)		((m & S_IFMT) == S_IFDIR)
#define S_ISBLK(m)		((m & S_IFMT) == S_IFBLK)
#define S_ISREG(m)		((m & S_IFMT) == S_IFREG)
#define S_ISFIFO(m)		((m & S_IFMT) == S_IFIFO)
#define S_ISMEM(m)		((m & S_IFMT) == S_IMEM)
#define S_ISFLNK(m)		((m & S_IFMT) == S_IFLNK)

	/* the values for st_attr	*/
#define S_IRWXU			0700
#define S_IRWXG			0070
#define S_IRWXO			0007

#define	S_ISUID			04000
#define	S_ISGID			02000
#define	S_ISVTX			01000
/* file access modes for user, group, and other*/
#define S_IRUSR			0400
#define S_IWUSR			0200
#define S_IXUSR			0100
#define S_IRGRP			0040
#define S_IWGRP			0020
#define S_IXGRP			0010
#define S_IROTH			0004
#define S_IWOTH			0002
#define S_IXOTH			0001

#define	S_IREAD			S_IRUSR
#define	S_IWRITE		S_IWUSR
#define	S_IEXEC			S_IXUSR

	/* supported old constants - soon phased out 	*/
#define	S_IFHID		0222
#define	S_ISRO		0444
#define	S_ISARC		0666
	/* Gemdos file attributes (st_attr)	*/
#ifndef FA_NORMAL
#define	FA_NORMAL	0x00
		/* Fcreate()/Fattrib()/Fsfirst()/Fsnext()	*/
#define FA_RDONLY	0x01
#define FA_HIDDEN	0x02
#define FA_SYSTEM	0x04
#define FA_LABEL	0x08
		/* only Fattrib()/Fsfirst/Fsnext:	*/
#define FA_DIREC	0x10
#define FA_DIR		0x10
#define FA_ARCH		0x20
#define FA_CHANGED	0x20
#endif

int chmod(char *filename, int pmode);
int mkdir(char *pathname);
int stat(char *name, struct stat *statbuf);

/* not a standard function */
extern long size(char *name);	/* former called fsize	*/


#endif 	/* _STAT_H	*/
