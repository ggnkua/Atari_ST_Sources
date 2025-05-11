/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 *  Fake stat the best we can.  The only field that isn't filled in half-way
 * sensibly in st_ino.  Also put dta struct here for lack of a better place.
 *
 * $Header: stat.h,v 1.1 88/01/29 17:22:33 m68k Exp $
 *
 * $Log:	stat.h,v $
 * Revision 1.1  88/01/29  17:22:33  m68k
 * Initial revision
 * 
 */
struct stat {
	short	st_mode;
	ino_t	st_ino;
	dev_t	st_dev;
	short	st_rdev;
	short	st_nlink;
	short	st_uid;
	short	st_gid;
	off_t	st_size;
	long	st_blksize;
	long	st_blocks;
	time_t	st_mtime;
	time_t	st_atime;
	time_t	st_ctime;
	short	st_attr;
};

#define	S_IFMT			0170000
#define		S_IFDIR		0010000
#define	S_IFREG			0000000
#define	S_IFCHR			0000000	/* not really, but what to do? */
#define	S_ISUID			0004000
#define	S_ISGID			0002000
#define	S_ISTX			0001000
#define	S_IREAD			0000400
#define	S_IWRITE		0000200
#define	S_IEXEC			0000100

struct _dta {
	char		dta_buf[21];
	char		dta_attribute;
	unsigned short	dta_time;
	unsigned short	dta_date;
	long		dta_size;
	char		dta_name[14];
};

#define	FA_RDONLY		0x01
#define	FA_HIDDEN		0x02
#define	FA_SYSTEM		0x04
#define	FA_LABEL		0x08
#define	FA_DIR			0x10
#define	FA_CHANGED		0x20
