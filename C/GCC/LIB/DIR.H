/*
 *		Cross Development System for Atari ST 
 *     Copyright (c) 1988, Memorial University of Newfoundland
 *
 *  A public domain implementation of BSD directory routines for
 *  MS-DOS.  Written by Michael Rendell ({uunet,utai}michael@garfield),
 *  August 1897
 *
 * $Header: dir.h,v 1.1 88/01/29 17:22:25 m68k Exp $
 *
 * $Log:	dir.h,v $
 * Revision 1.1  88/01/29  17:22:25  m68k
 * Initial revision
 * 
 */

#define	rewinddir(dirp)	seekdir(dirp, 0L)

#define	MAXNAMLEN	12

struct direct {
	ino_t	d_ino;			/* a bit of a farce */
	int	d_reclen;		/* more farce */
	int	d_namlen;		/* length of d_name */
	char	d_name[MAXNAMLEN + 1];		/* garentee null termination */
};

struct _dircontents {
	char	*_d_entry;
	struct _dircontents	*_d_next;
};

typedef struct _dirdesc {
	int		dd_id;	/* uniquely identify each open directory */
	long		dd_loc;	/* where we are in directory entry is this */
	struct _dircontents	*dd_contents;	/* pointer to contents of dir */
	struct _dircontents	*dd_cp;	/* pointer to current position */
} DIR;

extern	DIR		*opendir();
extern	struct direct	*readdir();
extern	void		seekdir();
extern	long		telldir();
extern	void		closedir();
