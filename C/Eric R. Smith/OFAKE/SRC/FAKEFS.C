#include "atarierr.h"
#include "filesys.h"
#include <string.h>

#define DOM_TOS 0
#define DOM_MINT 1
#define NUM_DRIVES 32

#ifndef NULL
#define NULL 0L
#endif

/*
 * this points to the structure that has all the useful functions that
 * the kernel told us about
 */

struct kerinfo *kernel;

#define CCONWS (void)(*kernel->dos_tab[0x09])
#define FGETDTA (*kernel->dos_tab[0x2f])
#define RWABS (*kernel->bios_tab[4])
#define GETBPB (void *)(*kernel->bios_tab[7])
#define DEBUG (*kernel->debug)
#define ALERT (*kernel->alert)
#define TRACE (*kernel->trace)
#define FATAL (*kernel->fatal)
#define P_(x) ()

int fakedrv = 0;

long	fake_root	P_((int drv, fcookie *fc));
long	fake_lookup	P_((fcookie *dir, char *name, fcookie *fc));
long	fake_getxattr	P_((fcookie *fc, XATTR *xattr));
long	fake_chattr	P_((fcookie *fc, int attrib));
long	fake_chown	P_((fcookie *fc, int uid, int gid));
long	fake_chmode	P_((fcookie *fc, unsigned mode));
long	fake_rmdir	P_((fcookie *dir, char *name));
long	fake_remove	P_((fcookie *dir, char *name));
long	fake_getname	P_((fcookie *root, fcookie *dir, char *pathname));
long	fake_rename	P_((fcookie *olddir, char *oldname,
				    fcookie *newdir, char *newname));
long	fake_opendir	P_((DIR *dirh, int flags));
long	fake_readdir	P_((DIR *dirh, char *nm, int nmlen, fcookie *));
long	fake_rewinddir	P_((DIR *dirh));
long	fake_closedir	P_((DIR *dirh));
long	fake_pathconf	P_((fcookie *dir, int which));
long	fake_dfree	P_((fcookie *dir, long *buf));
DEVDRV *	fake_getdev	P_((fcookie *fc, long *devsp));
long	fake_symlink	P_((fcookie *dir, char *name, char *to));
long	fake_readlink	P_((fcookie *fc, char *buf, int buflen));
long	fake_dskchng	P_((int drv));
long errinvfn();

FILESYS fake_filesys = {
	(FILESYS *)0,
	0,
	fake_root,
	fake_lookup, errinvfn, fake_getdev, fake_getxattr,
	fake_chattr, fake_chown, fake_chmode,
	errinvfn, fake_rmdir, fake_remove, fake_getname, fake_rename,
	fake_opendir, fake_readdir, fake_rewinddir, fake_closedir,
	fake_pathconf, fake_dfree, errinvfn, errinvfn,
	fake_symlink, fake_readlink, errinvfn, errinvfn, fake_dskchng
};

typedef long (*Longfunc)();
Longfunc oldgetbpb, oldmediach, oldrwabs;
extern long newrwabs(), newmediach(), newgetbpb();	/* see below */

/* struct used by Fsfirst/Fsnext */
typedef struct _dta {
	char		dta_buf[21];
	char		dta_attribute;
	unsigned short	dta_time;
	unsigned short	dta_date;
	long		dta_size;
	char		dta_name[14];
} _DTA;

/*
 * this must be the first function; it is called by the kernel when the
 * file system is being loaded, and should return the file system
 * structure
 */

FILESYS *
fake_init(k)
	struct kerinfo *k;
{
	_DTA *d;
	static char foo[] = "x:";
	char drvlet;

	kernel = k;

/* we decide which device is going to be fake based upon the
 * name we were loaded with (available in the current DTA
 * buffer)
 */
	d = (_DTA *)FGETDTA();
	drvlet = d->dta_name[0];
	if (drvlet >= 'a' && drvlet <= 'z') {
		fakedrv = drvlet - 'a';
	} else {
		fakedrv = drvlet - 'A';
	}

	foo[0] = fakedrv + 'A';

	if (fakedrv < 0 || fakedrv > 15) {
		CCONWS("Cannot install fake drive ");
		CCONWS(foo);
		CCONWS(" -- try renaming your .XFS file\r\n");
		return 0;
	}

	if ( (*((long *)0x4c2)) & (1L << fakedrv) ) {
		CCONWS("Drive "); CCONWS(foo);
		CCONWS(" already exists -- it can't be made fake\r\n");
		return 0;
	}

/* install a fake BIOS device */
/* we also have to put in some fake drivers for Getbpb, etc */
	oldrwabs = *((Longfunc *)0x476);
	oldgetbpb = *((Longfunc *)0x472);
	oldmediach = *((Longfunc *)0x47e);

	*((Longfunc *)0x476) = newrwabs;
	*((Longfunc *)0x472) = newgetbpb;
	*((Longfunc *)0x47e) = newmediach;
	
	*((long *)0x4c2) |= (1L << fakedrv);

	CCONWS("Loaded fake universal device for drive ");
	CCONWS(foo);
	CCONWS("\r\n");

	return &fake_filesys;
}

long
errinvfn()
{
	DEBUG("Invalid function called on fake file system.");
	return EINVFN;
}

/*
 * this is rather ugly; what it does is step through the file system
 * chain looking for the universal drive (drive U:), and if found
 * it does a root directory lookup for that file system and returns the
 * result. THIS MAY BREAK ON FUTURE VERSIONS OF MINT; I don't recommend
 * that you rely on internals of the file system routines!!!!!
 */

#ifndef UNIDRV
#define UNIDRV 'U'-'A'
#endif

FILESYS *unifs;

long
fake_root(drv, fc)
	int drv;
	fcookie *fc;
{
	fcookie dir;

	if (drv == fakedrv) {
		unifs = fake_filesys.next;
		while (unifs) {
			if ( (*unifs->root)(UNIDRV, fc) == 0 ) {
				fc->fs = &fake_filesys;
				fc->dev = fakedrv;
				return 0;
			}
			unifs = unifs->next;
		}
		ALERT("Couldn't find file system for U:!");
	}
	fc->fs = 0;
	return EDRIVE;
}

/*
 * all the other fake function drivers just call out to the unified
 * file system to do their stuff
 */

long
fake_lookup(dir, name, fc)
	fcookie *dir, *fc; char *name;
{
	if (!*name || (*name == '.' && (name[1] == 0 || name[1] == '.'))) {
		*fc = *dir;
		return 0;
	}

	return (*unifs->lookup)(dir, name, fc);
}

long
fake_getxattr(fc, xattr)
	fcookie *fc; XATTR *xattr;
{
	if (fc->index != 0L) {
		ALERT("Bad getxattr call on fake file system");
		return EFILNF;
	}

	xattr->index = fc->index;
	xattr->dev = fc->dev;
	xattr->nlink = 1;
	xattr->blksize = 1;
	xattr->uid = xattr->gid = 0;
	xattr->size = xattr->nblocks = 0;
	xattr->mode = S_IFDIR | 0777;
	xattr->attr = FA_DIR;
	xattr->mtime = xattr->atime = xattr->ctime = 0;
	xattr->mdate = xattr->adate = xattr->cdate = 0;
	return 0;
}

long
fake_chattr(fc, attrib)
	fcookie *fc; int attrib;
{
	return EACCDN;
}

long
fake_chown(fc, uid, gid)
	fcookie *fc; int uid, gid;
{
	return EACCDN;
}

long
fake_chmode(fc, mode)
	fcookie *fc;
	unsigned mode;
{
	return EACCDN;
}

long
fake_rmdir(dir, name)
	fcookie *dir;
	char *name;
{
	return (*unifs->rmdir)(dir, name);
}

long
fake_remove(dir, name)
	fcookie *dir;
	char *name;
{
	return (*unifs->remove)(dir, name);
}

long
fake_getname(root, dir, name)
	fcookie *root, *dir;
	char *name;
{
	fcookie realroot;
	fcookie realdir;

	(*unifs->root)(UNIDRV, &realroot);
	realdir = *dir;
	if (realdir.dev == fakedrv) {
		realdir.dev = UNIDRV;
		realdir.fs = unifs;
	}

	return (*unifs->getname)(&realroot, &realdir, name);
}

long
fake_rename(olddir, oldname, newdir, newname)
	fcookie *olddir, *newdir;
	char *oldname, *newname;
{
	return (*unifs->rename)(olddir, oldname, newdir, newname);
}

long
fake_opendir(dirh, flags)
	DIR *dirh; int flags;
{
	return (*unifs->opendir)(dirh, flags);
}

long
fake_readdir(dirh, nm, nmlen, fc)
	DIR *dirh; char *nm; int nmlen; fcookie *fc;
{
	return (*unifs->readdir)(dirh, nm, nmlen, fc);
}

long
fake_rewinddir(dirh)
	DIR *dirh;
{
	return (*unifs->rewinddir)(dirh);
}

long
fake_closedir(dirh)
	DIR *dirh;
{
	return (*unifs->closedir)(dirh);
}

long
fake_pathconf(dir, which)
	fcookie *dir; int which;
{
	return (*unifs->pathconf)(dir, which);
}

long
fake_dfree(dir, buf)
	fcookie *dir; long *buf;
{
	return (*unifs->dfree)(dir, buf);
}

DEVDRV *
fake_getdev(fc, devsp)
	fcookie *fc; long *devsp;
{
	return (*unifs->getdev)(fc, devsp);
}

long
fake_symlink(dir, name, to)
	fcookie *dir; char *name, *to;
{
	return (*unifs->symlink)(dir, name, to);
}

long
fake_readlink(fc, buf, len)
	fcookie *fc; char *buf; int len;
{
	return (*unifs->readlink)(fc, buf, len);
}

long
fake_dskchng(drv)
	int drv;
{
	(void)GETBPB(drv);
	return 0;
}

/*
 * and here are the fake drivers for the BIOS
 */


asm
("\
	.globl	_newrwabs; 	\
	.globl	_newmediach; 	\
	.globl	_newgetbpb; 	\
_newgetbpb:			\
	movew	sp@(4), d0;	\
	cmpw	_fakedrv, d0;	\
	beq	ret0;		\
	movel	_oldgetbpb, a0;	\
	jmp	a0@;		\
ret0:				\
	clrl	d0;		\
	rts;			\
_newmediach:			\
	movew	sp@(4), d0;	\
	cmpw	_fakedrv, d0;	\
	beq	ret0;		\
	movel	_oldmediach, a0; \
	jmp	a0@;		\
_newrwabs:			\
	movew	sp@(0xe), d0;	\
	cmpw	_fakedrv, d0;	\
	beq	ret0;		\
	movel	_oldrwabs, a0;	\
	jmp	a0@"
);
