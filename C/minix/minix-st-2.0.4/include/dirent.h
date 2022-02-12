/*	dirent.h - Declarations for directory reading routines.
 *							Author: Kees J. Bot
 *								24 Apr 1989
 * 
 * Note: The V7 format directory entries used under Minix must be transformed
 * into a struct dirent with a d_name of at least 15 characters.  Given that
 * we have to transform V7 entries anyhow it is little trouble to let the
 * routines understand the so-called "flex" directory format too.
 */

#ifndef _DIRENT_H
#define _DIRENT_H

#ifndef _TYPES_H
#include <sys/types.h>
#endif

/* _fl_direct is a flexible directory entry.  Actually it's a union of 8
 * characters and the 3 fields defined below. 
 */

/* Flexible directory entry: */
struct _fl_direct {		/* First slot in an entry */
	ino_t		d_ino;
	unsigned char	d_extent;
	char		d_name[5];  /* Four characters for the shortest name */
};

	/* Name of length len needs _EXTENT(len) extra slots. */
#define _EXTENT(len)	(((len) + 3) >> 3)

/* Version 7 directory entry: */
struct _v7_direct {		
	ino_t		d_ino;
	char		d_name[14];
};

/* Definitions for the directory(3) routines: */
typedef struct {
	char		_fd;	/* Filedescriptor of open directory */
	char		_v7;	/* Directory is Version 7 */
	short		_count;	/* This many objects in buf */
	off_t		_pos;	/* Position in directory file */
	struct _fl_direct  *_ptr;	/* Next slot in buf */
	struct _fl_direct  _buf[128];	/* One block of a directory file */
	struct _fl_direct  _v7f[3];	/* V7 entry transformed to flex */
} DIR;

struct dirent {		/* Largest entry (8 slots) */
	ino_t		d_ino;		/* I-node number */
	unsigned char	d_extent;	/* Extended with this many slots */
	char		d_name[61];	/* Null terminated name */
};

/* Function Prototypes. */
_PROTOTYPE( int closedir, (DIR *_dirp)					);
_PROTOTYPE( DIR *opendir, (const char *_dirname)			);
_PROTOTYPE( struct dirent *readdir, (DIR *_dirp)			);
_PROTOTYPE( void rewinddir, (DIR *_dirp)				);

#ifdef _MINIX
_PROTOTYPE( int seekdir, (DIR *_dirp, off_t _loc)			);
_PROTOTYPE( off_t telldir, (DIR *_dirp)					);
#endif

#endif /* _DIRENT_H */
