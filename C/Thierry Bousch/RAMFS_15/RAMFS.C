/*
 * 'RAMFS': A (resizable) ramdisk file system for MiNT
 * Author : Thierry Bousch
 * Version: 1.4 (August 1993)
 *
 * Revision history:
 * 1.0	Added version number, and macro-ized TRACE so that it is possible
 *	to compile with or without debug information.
 * 1.1  Added setuid, setgid and sticky bit for directories. Macro-ized
 *      also DEBUG, ALERT and FATAL.
 * 1.2  Deleted open files are now hidden. Added the valid_name() function.
 *      Added a test in ram_rename about sticky directories.
 * 1.3  Deleted open files are now put in a special place (the trash-list)
 *      instead of leaving them half-deleted in their directories.
 *      Added support for the FTRUNCATE ioctl call.
 * 1.4  Take advantage of the FS_MOUNT call in MiNT 1.08, so that we can
 *      get rid of drive R. Added FS_LONGPATH support.
 *      The size of the RAMFILE structure is now considered in the getxattr
 *      and dfree functions.
 * 1.5  Fixed the return-code in ram_readlabel. Also, update the mtime of
 *      a directory when one of its files is deleted.
 */

#include <string.h>
#include "atarierr.h"
#include "filesys.h"

#define VERSION  "1.5"

/*
 * You may edit the following constants:
 *
 *	RAM_NAME	name of the ramdisk-fs directory
 *	RAMFILE_MAX	maximum length of a filename
 *	BLKSIZE		chunk size (must be a power of two)
 *
 * Define the symbols NO_{TRACE,DEBUG,ALERT,FATAL} to disable trace,
 * debug, alert and fatal calls, respectively.
 */

#define RAM_NAME	"U:\\ram"
#define RAMFILE_MAX	35
#define BLKSIZE		512L
#define NO_TRACE

/*
 * this points to the structure that has all the useful functions that
 * the kernel told us about
 */

struct kerinfo *kernel;

#define CCONWS		(*kernel->dos_tab[0x09])
#define DCNTL		(*kernel->dos_tab[0x130])

#define Timestamp	(*kernel->dos_tab[0x2c])
#define Datestamp	(*kernel->dos_tab[0x2a])
#define FreeMemory()	(*kernel->dos_tab[0x48])(-1L)
#define Getpid		(*kernel->dos_tab[0x10b])
#define Getuid		(*kernel->dos_tab[0x10f])
#define Getgid		(*kernel->dos_tab[0x114])
#define Geteuid		(*kernel->dos_tab[0x138])
#define Getegid		(*kernel->dos_tab[0x139])

#define Kmalloc		(*kernel->kmalloc)
#define Kfree		(*kernel->kfree)
#define Stricmp		(*kernel->stricmp)
#define Denyshare	(*kernel->denyshare)

#ifndef NULL
# define NULL		((void *)0L)
#endif

#define FTRUNCATE	(('F'<< 8) | 4)		/* from the Minix FS */

/* Useful macros */

#define IS_DIRECTORY(s)	(((s)->mode & S_IFMT) == S_IFDIR)
#define IS_SYMLINK(s)	(((s)->mode & S_IFMT) == S_IFLNK)
#define IS_SETUID(s)	((s)->mode & S_ISUID)
#define IS_SETGID(s)	((s)->mode & S_ISGID)
#define IS_STICKY(s)	((s)->mode & S_ISVTX)

/* Conditional debugging */

#ifdef NO_DEBUG
# define DEBUG(x)
#else
# define DEBUG(x)	(*kernel->debug)x
#endif

#ifdef NO_ALERT
# define ALERT(x)
#else
# define ALERT(x)	(*kernel->alert)x
#endif

#ifdef NO_TRACE
# define TRACE(x)
#else
# define TRACE(x)	(*kernel->trace)x
#endif

#ifdef NO_FATAL
# define FATAL(x)
#else
# define FATAL(x)	(*kernel->fatal)x
#endif

/* Forward declarations of the file system functions */

long	ram_root	(int drv, fcookie *fc);
long	ram_lookup	(fcookie *dir, char *name, fcookie *fc);
long	ram_creat	(fcookie *dir, char *name, unsigned mode,
				int attrib, fcookie *fc);
DEVDRV*	ram_getdev	(fcookie *fc, long *devsp);
long	ram_getxattr	(fcookie *fc, XATTR *xattr);
long	ram_chattr	(fcookie *fc, int attrib);
long	ram_chown	(fcookie *fc, int uid, int gid);
long	ram_chmode	(fcookie *fc, unsigned mode);
long	ram_mkdir	(fcookie *fc, char *name, unsigned mode);
long	ram_rmdir	(fcookie *dir, char *name);
long	ram_remove	(fcookie *dir, char *name);
long	ram_getname	(fcookie *root, fcookie *dir, char *path, int size);
long	ram_rename	(fcookie *olddir, char *oldname,
				fcookie *newdir, char *newname);
long	ram_opendir	(DIR *dirh, int flags);
long	ram_readdir	(DIR *dirh, char *nm, int nmlen, fcookie *fc);
long	ram_rewinddir	(DIR *dirh);
long	ram_closedir 	(DIR *dirh);
long	ram_pathconf 	(fcookie *dir, int which);
long	ram_dfree	(fcookie *dir, long *buf);
long	ram_writelabel	(fcookie *dir, char *name);
long	ram_readlabel	(fcookie *dir, char *name, int namelen);
long	ram_symlink	(fcookie *dir, char *name, char *to);
long	ram_readlink	(fcookie *dir, char *buf, int len);
long	ram_hardlink	(fcookie *fromdir, char *fromname,
				fcookie *todir, char *toname);
long	ram_fscntl	(fcookie *dir, char *name, int cmd, long arg);
long	ram_dskchng	(int drv);

/* Forward declarations of the device driver functions */

long	ram_open	(FILEPTR *f);
long	ram_write	(FILEPTR *f, char *buf, long bytes);
long	ram_read	(FILEPTR *f, char *buf, long bytes);
long	ram_lseek	(FILEPTR *f, long where, int whence);
long	ram_ioctl	(FILEPTR *f, int mode, void *buf);
long	ram_datime	(FILEPTR *f, int *time, int rwflag);
long	ram_close	(FILEPTR *f, int pid);
long	ram_select	(FILEPTR *f, long p, int mode);
void	ram_unselect	(FILEPTR *f, long p, int mode);

/* 
 * Here is the structure used for ram files. The "next" field points to
 * the following file/dir in that directory. The "up" field points to the 
 * directory the file/dir is in, or NULL for the root directory. The
 * "down" field is only used by subdirectories and points to the first
 * entry in that subdirectory. "lst" is the list of open FILEPTRs for
 * this file. "length" is the actual length, "data" the actual data, and
 * "avail" is the length of the ram block allocated for "data".
 *
 * Note that all the memory is allocated in one block: it may cause trouble
 * with big files if the memory is fragmented.
 */

typedef struct ramfile {
	struct ramfile *next, *up, *down;
	char filename[RAMFILE_MAX+1];
	int uid, gid;
	short time, date;
	unsigned mode;
	FILEPTR *lst;
	long length, avail;
	char *data;
} RAMFILE;

RAMFILE ramroot, *trash;
int ram_drive;

DEVDRV ram_device = {
	ram_open, ram_write, ram_read, ram_lseek, ram_ioctl, ram_datime,
	ram_close, ram_select, ram_unselect
};

FILESYS ram_filesys = {
	(FILESYS *)0,
	FS_LONGPATH,
	ram_root,
	ram_lookup, ram_creat, ram_getdev, ram_getxattr,
	ram_chattr, ram_chown, ram_chmode,
	ram_mkdir, ram_rmdir, ram_remove, ram_getname, ram_rename,
	ram_opendir, ram_readdir, ram_rewinddir, ram_closedir,
	ram_pathconf, ram_dfree,
	ram_writelabel, ram_readlabel, ram_symlink, ram_readlink,
	ram_hardlink, ram_fscntl, ram_dskchng
};

struct fs_descr ram_fs_descr = { &ram_filesys };

/*
 * This function is called by the kernel when the
 * file system is being loaded, and should return the file system
 * structure
 */

FILESYS *ram_init (struct kerinfo *k)
{
	kernel = k;

	CCONWS("Ramdisk filesystem for MiNT (Version " VERSION ", compiled " 
	__DATE__ ") by T.Bousch\r\n");

	TRACE(("ram_init: initialize filesystem"));
	ramroot.next = ramroot.up = ramroot.down = NULL;
	ramroot.filename[0] = 0;
	ramroot.uid  = ramroot.gid = 0;
	ramroot.time = Timestamp();
	ramroot.date = Datestamp();
	ramroot.mode = S_IFDIR | DEFAULT_DIRMODE;
	ramroot.lst  = NULL;
	ramroot.length = ramroot.avail = 0;
	ramroot.data = NULL;
	trash = NULL;

	/* 
	 * We try first to install the filesystem as a gemdos-only drive
	 * because we don't want to pollute the bios drive map with a fake
	 * drive. Unfortunately, this will only work with recent MiNT
	 * versions (at least 1.08); with older versions we fallback
	 * to the previous method (install drive 'R').
	 */
	if (DCNTL(FS_INSTALL, RAM_NAME, &ram_fs_descr) >= 0 &&
	    DCNTL(FS_MOUNT,   RAM_NAME, &ram_fs_descr) >= 0) {
		ram_drive = ram_fs_descr.dev_no;
		/* Tell the kernel that the filesystem is already loaded */
		return (FILESYS*)(1L);
	}
	/* Add drive 'R' to the list of Bios drives */
	ram_drive = 'R'-'A';
	*(unsigned long *)(0x4c2L) |= (1UL << ram_drive);
	return &ram_filesys;
}

long ram_root (int drv, fcookie *fc)
{
	if (drv == ram_drive) {
		TRACE(("ram_root: drive #%d is a ramdisk", drv));
		fc->fs = &ram_filesys;
		fc->dev = drv;
		fc->index = (long) &ramroot;
		return 0;
	} else {
		fc->fs = NULL;	/* Not our drive */
		return EDRIVE;
	}
}

long ram_lookup (fcookie *dir, char *name, fcookie *fc)
{
	RAMFILE *s, *d;
	
	TRACE(("ram_lookup: search name [%s]", name));

	d = (RAMFILE *)dir->index;
	
	if (!d || !IS_DIRECTORY(d)) {
		DEBUG(("ram_lookup: bad directory"));
		return EPTHNF;
	}
	/* Empty name and "." are the directory itself */
	if (!*name || !Stricmp(name, ".")) {
		*fc = *dir;
		return 0;
	}
	/* ".." could be a mount point */
	if (!Stricmp(name, "..")) {
		s = d->up;
		if (s) {
			fc->index = (long)s;
			fc->fs = &ram_filesys;
			fc->dev = ram_drive;
			return 0;
		} else {
			*fc = *dir;
			return EMOUNT;
		}
	}
	
	for (s = d->down; s; s = s->next) {
		if (!Stricmp(s->filename,name))
			break;
	}	

	if (!s) {
		DEBUG(("ram_lookup: name [%s] not found", name));
		return EFILNF;
	} else {
		fc->index = (long)s;
		fc->fs = &ram_filesys;
		fc->dev = ram_drive;
	}
	return 0;
}

/* How many files are there in a directory? */

static unsigned int count (RAMFILE *d)
{
	unsigned int n = 0;
	RAMFILE *s;
	
	for (s = d->down; s; s = s->next)
		++n;
	return n;
}

long ram_getxattr (fcookie *fc, XATTR *xattr)
{
	RAMFILE *s;
	
	TRACE(("ram_getxattr: get file attributes"));
	
	xattr->blksize = BLKSIZE;
	xattr->dev = ram_drive;
	xattr->nlink = 1;
	s = (RAMFILE *)fc->index;
	xattr->index = (long)s;
	xattr->uid = s->uid; xattr->gid = s->gid;
	xattr->size =
		(IS_DIRECTORY(s) ? count(s) * sizeof(RAMFILE) : s->length);
        xattr->nblocks = (s->avail + BLKSIZE - 1) / BLKSIZE;
	xattr->mtime = xattr->ctime = xattr->atime = s->time;
	xattr->mdate = xattr->cdate = xattr->adate = s->date;
	xattr->mode = s->mode;
	xattr->attr = ((s->mode & (S_IWUSR|S_IWGRP|S_IWOTH)) ? 0 : FA_RDONLY)
			| (IS_DIRECTORY(s) ? FA_DIR : 0);
	return 0;
}

long ram_chattr (fcookie *fc, int attrib)
{
	RAMFILE *s;
	
	TRACE(("ram_chattr: new attrib 0%o", attrib));

	s = (RAMFILE *)fc->index;
	if (attrib & FA_RDONLY) {
		s->mode &= ~(S_IWUSR|S_IWGRP|S_IWOTH);
	} else if ( !(s->mode & (S_IWUSR|S_IWGRP|S_IWOTH)) ) {
		s->mode |= (S_IWUSR|S_IWGRP|S_IWOTH);
	}
	return 0;
}

long ram_chown (fcookie *fc, int uid, int gid)
{
	RAMFILE *s;
	
	TRACE(("ram_chown: new owner is %d.%d", uid, gid));

	s = (RAMFILE *)fc->index;
	s->uid = uid;
	s->gid = gid;
	return 0;
}

long ram_chmode (fcookie *fc, unsigned mode)
{
	RAMFILE *s;
	
	TRACE(("ram_chmode: new mode 0%o", mode));

	s = (RAMFILE *)fc->index;
	s->mode = (s->mode & S_IFMT) | (mode & ~S_IFMT);
	return 0;
}

/*
 * Deletes file "s" if it's on the trash-list and no longer used,
 * i.e. (s->lst == NULL).
 */

static void _unlink (RAMFILE *s)
{
	RAMFILE *t, **old;

	if (s->lst == NULL) {	
		old = &trash;
		for (t = trash; t && t != s; t = t->next)
			old = &t->next;
		if (t) {
			*old = s->next;
			Kfree(s->data);
			Kfree(s);
		}
	}
}

/*
 * Deletes a file from the current directory, moving it into
 * the trash-list.
 */

static void unlink (RAMFILE *s)
{
	RAMFILE *d, *t, **old;

	d = s->up;
	old = &d->down;
	for (t = d->down; t && t != s; t = t->next)
		old = &t->next;
	if (!t) {
		ALERT(("ram_unlink: file not found"));
		return;
	}
	*old = s->next;

	/* Now move the file into the trash */
	s->next = trash;
	trash = s;
	_unlink(s);

        d->time = Timestamp();
        d->date = Datestamp();
}

/* Is a filename valid ? */

static int valid_name (char *name)
{
	char c;

	if (!name || !*name || !Stricmp(name,".") || !Stricmp(name,".."))
		return 0;		/* Reserved */

	while ((c = *name++) != 0) {
		if (c < 32 || c > 126)
			return 0;	/* Non-ASCII character met */
		if (c == '/' || c == '\\' || c == ':')
			return 0;	/* Directory separator */
	}
	return 1;
}

long ram_remove (fcookie *dir, char *name)
{
	RAMFILE *d, *s;
	
	TRACE(("ram_remove: delete file [%s]", name));

	d = (RAMFILE *)dir->index;
	for (s = d->down; s; s = s->next) {
		if (!Stricmp(s->filename, name))
			break;
	}
	if (!s) {
		DEBUG(("ram_remove: file [%s] not found", name));
		return EFILNF;
	}
	if (IS_DIRECTORY(s)) {
		DEBUG(("ram_remove: [%s] is a directory", name));
		return EACCDN;
	}
	/* If d is sticky, check that we own the file */
	if (IS_STICKY(d) && Geteuid() && s->uid != Getuid()) {
		DEBUG(("ram_remove: not owner"));
		return EACCDN;
	}
	unlink(s);	
	return 0;
}

long ram_getname (fcookie *root, fcookie *dir, char *path, int size)
{
	RAMFILE *s, *d;
	char p[RAMFILE_MAX+2];

	if (size <= 0) return ERANGE;
	path[0] = 0;	/* empty string */
	d = (RAMFILE *)root->index;
	s = (RAMFILE *)dir->index;
	while (s) {
		if (s == d) {
			strrev(path);
			TRACE(("ram_getname: returned [%s]", path));
			return 0;
		}
		p[0] = '\\';
		strcpy(p+1, s->filename);
		strrev(p);
		size -= strlen(p);
		if (size <= 0) {
			DEBUG(("ram_getname: name too long"));
			path[0] = 0;
			return ENAMETOOLONG;
		}
		strcat(path, p);
		s = s->up;
	}
	DEBUG(("ram_getname: path not found"));
	path[0] = 0;
	return EPTHNF;	/* not found */
}

long ram_rename (fcookie *olddir, char *oldname,
			fcookie *newdir, char *newname)
{
	RAMFILE *s, *d, *dold, *dnew, **old;
	
	TRACE(("ram_rename: mv %s %s", oldname, newname));

	/* Verify that "newname" doesn't exist */
	if (!valid_name(newname)) {
		DEBUG(("ram_rename: invalid filename"));
		return EACCDN;
	}
	dnew = (RAMFILE *)newdir->index;
	for (s = dnew->down; s; s = s->next)
		if (!Stricmp(s->filename, newname)) {
			DEBUG(("ram_rename: file already exists"));
			return EACCDN;
		}
	/* Verify that "oldname" exists */
	dold = (RAMFILE *)olddir->index;
	old = &dold->down;
	for (s = dold->down; s; s = s->next)
		if (!Stricmp(s->filename, oldname))
			break;
		else	old = &s->next;
	if (!s) {
		DEBUG(("ram_rename: file not found"));
		return EFILNF;
	}
	/* Verify that "newdir" is not a subdirectory of "name" */
	for (d = dnew; d; d = d->up)
		if (d == s) {
			DEBUG(("ram_rename: invalid move"));
			return EACCDN;
		}
	/* If dold is sticky, check that we own the file */
	if (IS_STICKY(dold) && Geteuid() && s->uid != Getuid()) {
		DEBUG(("ram_rename: not owner"));
		return EACCDN;
	}
	/* Ok... The file can be renamed now. */
	strncpy(s->filename, newname, RAMFILE_MAX);
	s->filename[RAMFILE_MAX] = 0;
	if (dold != dnew) {
		/* Rename across directories */
		TRACE(("ram_rename: move across directories"));
		*old = s->next;
		s->next = dnew->down;
		dnew->down = s;
		s->up = dnew;
	}
	dold->time = dnew->time = Timestamp();
	dold->date = dnew->date = Datestamp();

	return 0;
}

long ram_opendir (DIR *dirh, int flags)
{
	RAMFILE *d;
	
	TRACE(("ram_opendir: open directory"));

	dirh->index = 0;
	d = (RAMFILE *)dirh->fc.index;
	*(RAMFILE **)(&dirh->fsstuff) = d->down;	/* next file */

	return 0;
}

long ram_rewinddir (DIR *dirh)
{
	RAMFILE *d;
	
	TRACE(("ram_rewinddir: rewind directory"));

	dirh->index = 0;
	d = (RAMFILE *)dirh->fc.index;
	*(RAMFILE **)(&dirh->fsstuff) = d->down;	/* next file */

	return 0;

}

long ram_closedir (DIR *dirh)
{
	TRACE(("ram_closedir: close directory"));
	return 0;
}

long ram_readdir (DIR *dirh, char *name, int namelen, fcookie *fc)
{
	int i;
	int giveindex = (dirh->flags == 0);
	RAMFILE *s;
	char *Filename;
	
	i = dirh->index++;
	s = (RAMFILE *)dirh->fc.index;	/* Current directory */
	if (i == 0) {
		/* The "." entry is the first one */
		Filename = ".";
	} else if (i == 1 && s->up != NULL) {
		/* The ".." entry is the second one */
		s = s->up;
		Filename = "..";
	} else {
		/* Any regular entry */
		s = *(RAMFILE **)(&dirh->fsstuff);
		if (!s) {
			TRACE(("ram_readdir: no more files"));
			return ENMFIL;
		}
		*(RAMFILE **)(&dirh->fsstuff) = s->next;
		Filename = s->filename;
	}
	TRACE(("ram_readdir: entry %d: %s", i, Filename));
	
	fc->index = (long)s;
	fc->fs = &ram_filesys;
	fc->dev = ram_drive;
	
	if (giveindex) {
		namelen -= (int)sizeof(long);
		if (namelen <= 0) return ERANGE;
		*((long *)name) = (long)s;
		name += sizeof(long);
	}
	if (namelen <= strlen(Filename)) {
		DEBUG(("ram_readdir: name too long"));
		return ENAMETOOLONG;
	}
	strcpy(name, Filename);
	return 0;
}
	
long ram_pathconf (fcookie *dir, int which)
{
	TRACE(("ram_pathconf: limit %d", which));

	switch(which) {
	case -1:
		return DP_MAXREQ;
	case DP_IOPEN:
		return UNLIMITED;	/* no internal limit on open files */
	case DP_MAXLINKS:
		return 1;		/* we don't have hard links */
	case DP_PATHMAX:
		return UNLIMITED;	/* max. path length */
	case DP_NAMEMAX:
		return RAMFILE_MAX;	/* max. length of individual name */
	case DP_ATOMIC:
		return UNLIMITED;	/* all writes are atomic */
	case DP_TRUNC:
		return DP_AUTOTRUNC;	/* file names are truncated */
	case DP_CASE:
		return DP_CASEINSENS;	/* case preserved but ignored */
	default:
		DEBUG(("ram_pathconf: invalid parameter"));
		return EINVFN;
	}
}

/*
 * The following (recursive) function calculates the total size of a
 * file or directory, including the RAMFILE structure
 */
 
static long mem_used (RAMFILE *d)
{
	long used;
	RAMFILE *s;
	
	if (!IS_DIRECTORY(d))
		return sizeof(RAMFILE) + (d->avail);
	/* If it is a directory, then */
	used = sizeof(RAMFILE);
	for (s = d->down; s; s = s->next)
		used += mem_used(s);
	return used;
}

long ram_dfree (fcookie *dir, long *buf)
{
	long memfree, memused;
	
	TRACE(("ram_dfree: getting free disk space"));

	memfree = FreeMemory();
	memused = mem_used(&ramroot);

	*buf++ = memfree / BLKSIZE;		/* free blocks        */
	*buf++ = (memfree + memused) / BLKSIZE;	/* total nb of blocks */
	*buf++ = BLKSIZE;			/* sector size        */
	*buf   = 1;				/* 1 sector per block */
	
	return 0;
}

long ram_writelabel (fcookie *dir, char *name)
{
	DEBUG(("ram_writelabel: not implemented"));
	return EINVFN;
}

long ram_readlabel (fcookie *dir, char *name, int namelen)
{
	DEBUG(("ram_readlabel: not implemented"));
        return EFILNF;
}

long ram_hardlink (fcookie *fromdir, char *fromname,
			fcookie *todir, char *toname)
{
	DEBUG(("ram_hardlink: invalid function"));
	return EINVFN;
}

long ram_fscntl (fcookie *dir, char *name, int cmd, long arg)
{
	DEBUG(("ram_fscntl: nothing available"));
	return EINVFN;	/* Nothing for now */
}

long ram_dskchng (int drv)
{
	TRACE(("ram_dskchng: ram disk changed ?"));
	return 0; /* No media change on a ram disk! */
}

DEVDRV *ram_getdev (fcookie *fc, long *devsp)
{
	RAMFILE *s;
	
	TRACE(("ram_getdev: find device driver"));

	s = (RAMFILE *)fc->index;
	*devsp = (long)s;
	return &ram_device;
}

/*
 * Create a ram file. This function is used for regular files _and_
 * directories
 */
 
static long 
create_ram_file (fcookie *dir, char *name, unsigned mode, fcookie *fc)
{
	RAMFILE *s, *d;

	TRACE(("create_ram_file: file [%s] mode 0%o", name, mode));
	
	/* Does this name already exist ? */
	if (!valid_name(name)) {
		DEBUG(("create_ram_file: invalid filename"));
		return EACCDN;
	}
	d = (RAMFILE *)dir->index;
	for (s = d->down; s; s = s->next) {
		if (!Stricmp(s->filename, name)) {
			DEBUG(("create_ram_file: file exists"));
			return EACCDN;
		}
	}
	s = (RAMFILE *)Kmalloc(sizeof(RAMFILE));
	if (!s) {
		ALERT(("create_ram_file: out of memory"));
		return ENSMEM;
	}
	strncpy(s->filename, name, RAMFILE_MAX);
	s->filename[RAMFILE_MAX] = 0;
	/*
	 * If the directory has the bits Setuid or Setgid set, then the
	 * file inherits the uid or gid of its parent:
	 */
	s->uid = IS_SETUID(d) ? d->uid : Getuid();
	s->gid = IS_SETGID(d) ? d->gid : Getgid();
	s->mode = mode;
	s->lst  = NULL;
	s->length = s->avail = 0;
	s->data = NULL;
	s->time = d->time = Timestamp();
	s->date = d->date = Datestamp();
	s->next = d->down;
	d->down = s;
	s->down = NULL;
	s->up   = d;
	
	fc->fs = &ram_filesys;
	fc->index = (long)s;
	fc->dev = dir->dev;
	
	return 0;
}

long ram_creat (fcookie *dir, char *name, unsigned mode,
			int attrib, fcookie *fc)
{
	TRACE(("ram_creat: create regular file"));
	return create_ram_file (dir, name, mode|S_IFREG, fc);
}

long ram_mkdir (fcookie *fc, char *name, unsigned mode)
{
	fcookie Fc;
	
	TRACE(("ram_mkdir: make directory"));
	return create_ram_file (fc, name, mode|S_IFDIR, &Fc);
}

long ram_rmdir (fcookie *dir, char *name)
{
	RAMFILE *d, *s;
	
	TRACE(("ram_rmdir: remove directory [%s]", name));

	d = (RAMFILE *)dir->index;
	for (s = d->down; s; s = s->next) {
		if (!Stricmp(s->filename, name))
			break;
	}
	if (!s) {
		DEBUG(("ram_rmdir: directory [%s] not found", name));
		return EFILNF;
	}
	if (!IS_DIRECTORY(s) && !IS_SYMLINK(s)) {
		DEBUG(("ram_rmdir: [%s] isn't a directory", name));
		return EACCDN;
	}
	if (IS_DIRECTORY(s) && s->down) {
		DEBUG(("ram_rmdir: directory [%s] isn't empty", name));
		return EACCDN;
	}
	/* If d is sticky, check that we own the subdirectory */
	if (IS_STICKY(d) && Geteuid() && s->uid != Getuid()) {
		DEBUG(("ram_rmdir: not owner"));
		return EACCDN;
	}
	unlink(s);
	return 0;
}

long ram_symlink (fcookie *dir, char *name, char *to)
{
	RAMFILE *s;
	fcookie Fc; 
	long ret, len;

	TRACE(("ram_symlink: create symbolic link"));

	ret = create_ram_file (dir, name, 0777|S_IFLNK, &Fc);
	if (ret == 0) {
		s = (RAMFILE *)Fc.index;
		len = strlen(to) + 1;
		s->data = Kmalloc(len);
		if (!s->data) {
			ALERT(("ram_symlink: out of memory"));
			unlink(s);
			return ENSMEM;
		}
		s->length = s->avail = len;
		strcpy(s->data, to);
	}
	return ret;
}

long ram_readlink (fcookie *dir, char *buf, int len)
{
	RAMFILE *s;

	s = (RAMFILE *)dir->index;
	if (!IS_SYMLINK(s)) {
		DEBUG(("ram_readlink: not a symbolic link"));
		return EACCDN;
	}
	if (s->length > len) {
		DEBUG(("ram_readlink: name too long"));
		return ENAMETOOLONG;
	}
	strcpy(buf, s->data);
	TRACE(("ram_readlink: returned [%s]", buf));
	return 0;
}

/*
 * The ram disk driver
 */
 
static void realloc_ramfile (RAMFILE *s, long new_size)
{
	char *data2;
	long quantum, bytes;
	
	/* We choose bigger blocks for big files */
	quantum = (new_size > 16*BLKSIZE) ? 4*BLKSIZE : BLKSIZE;
	/* 
	 * Round to the next multiple of quantum; we assume that 
	 * quantum is a power of two !!
	 */
	new_size = (new_size + quantum - 1) & ~(quantum - 1);
	data2 = new_size ? (char *)Kmalloc(new_size) : NULL;
	if (!new_size || data2) {
		bytes = s->length;
		if (bytes > new_size)
			bytes = new_size;
		bcopy(s->data, data2, bytes);
		Kfree(s->data);
		s->data = data2;
		s->avail = new_size;
		if (s->length > s->avail)
			s->length = s->avail;
	} else	ALERT(("realloc_ramfile: out of memory"));
}

long ram_open (FILEPTR *f)
{
	RAMFILE *s;

	TRACE(("ram_open: open file"));

	s = (RAMFILE *)f->devinfo;
	/* Check the sharing mode */
	if (Denyshare(s->lst, f)) {
		DEBUG(("ram_open: sharing modes conflict"));
		return EACCDN;
	}
	if (f->flags & O_TRUNC) {
		/* truncate the file */
		realloc_ramfile(s, 0);
	}
	f->next = s->lst;
	s->lst = f;
	
	return 0;
}

long ram_close (FILEPTR *f, int pid)
{
	RAMFILE *s;
	FILEPTR **old, *g;
	
	TRACE(("ram_close: close file"));

	if (f->links == 0) {
		s = (RAMFILE *)f->devinfo;
		old = &(s->lst);
		for (g = s->lst; g && g != f; g = g->next)
			old = &(g->next);
		if (!g)
			ALERT(("ram_close: FILEPTR not found"));
		else	*old = f->next;

		_unlink(s);
	}
	return 0;
}

long ram_write (FILEPTR *f, char *buf, long nbytes)
{
	RAMFILE *s;
	long new_size;
	
	s = (RAMFILE *)f->devinfo;
	new_size = nbytes + f->pos;
	if (new_size > s->avail)
		realloc_ramfile(s, new_size);
	/* Hope that the file is big enough now */
	if (new_size > s->avail)
		nbytes = s->avail - f->pos;
	if (nbytes < 0)
		nbytes = 0;
	/* Copy the data */
	TRACE(("ram_write: %ld bytes from pos %ld", nbytes, f->pos));
	bcopy(buf, s->data + f->pos, nbytes);

	/* Update the file status */
	f->pos += nbytes;
	if (f->pos > s->length)
		s->length = f->pos;
	if (s->length > s->avail)
		s->length = s->avail;
	s->time = Timestamp();
	s->date = Datestamp();

	return nbytes;
}
		
long ram_read (FILEPTR *f, char *buf, long nbytes)
{
	RAMFILE *s;

	s = (RAMFILE *)f->devinfo;
	if (nbytes + f->pos > s->length)
		nbytes = s->length - f->pos;
	if (nbytes < 0)
		nbytes = 0;
	/* Copy the data */
	TRACE(("ram_read: %ld bytes from pos %ld", nbytes, f->pos));
	bcopy(s->data + f->pos, buf, nbytes);
	f->pos += nbytes;
	
	return nbytes;
}

/* File locking code not yet implemented */

long ram_ioctl (FILEPTR *f, int mode, void *buf)
{
	RAMFILE *s;
	long new_size;

	TRACE(("ram_ioctl: mode %d", mode));
	s = (RAMFILE *)f->devinfo;
	if (mode == FIONREAD || mode == FIONWRITE) {
		*((long *)buf) = 1;
		return 0;
	} else if (mode == F_SETLK || mode == F_GETLK) {
		DEBUG(("ram_ioctl: locking not implemented"));
		return EINVFN;
	} else if (mode == FTRUNCATE) {
		new_size = *((long *)buf);
		if (new_size < 0) {
			DEBUG(("ram_ioctl: can't truncate file"));
			return ERANGE;
		}
		/* Reallocate the memory block */
		realloc_ramfile(s, new_size);
		if (new_size > s->avail) {
			DEBUG(("ram_ioctl: can't truncate file"));
			return ENSMEM;
		}
		s->length = new_size;
		return 0;
	}
	DEBUG(("ram_ioctl: invalid function"));
	return EINVFN;
}

long ram_lseek(FILEPTR *f, long where, int whence)
{
	RAMFILE *s;
	long newpos;

	TRACE(("ram_lseek: goto %ld, mode %d", where, whence));
	
	s = (RAMFILE *)f->devinfo;
	
	switch(whence) {
	case 0:
		newpos = where;
		break;
	case 1:
		newpos = f->pos + where;
		break;
	case 2:
		newpos = s->length - where;
		break;
	default:
		DEBUG(("ram_lseek: invalid mode"));
		return EINVFN;
	}
	
	if (newpos < 0) {
		TRACE(("ram_lseek: out of range"));
		return ERANGE;
	}
	f->pos = newpos;
	return newpos;
}

long ram_datime (FILEPTR *f, int *timeptr, int rwflag)
{
	RAMFILE *s;
	
	s = (RAMFILE *)f->devinfo;
	if (rwflag) {
		TRACE(("ram_datime: set time and date"));
		s->time = *timeptr++;
		s->date = *timeptr;
	} else {
		TRACE(("ram_datime: get time and date"));
		*timeptr++ = s->time;
		*timeptr   = s->date;
	}
	return 0;
}

long ram_select (FILEPTR *f, long p, int mode)
{
	TRACE(("ram_select: always ready"));
	return 1;
}

void ram_unselect (FILEPTR *f, long p, int mode)
{
	TRACE(("ram_unselect: nothing to do"));
	/* Nothing for us to do */
}
