/*
 * Mount.c - Manipulations of the mount table.
 *
 */

# include	"../include/param.h"
# include	"../include/dev.h"
# include 	"../include/inode.h"
# include	"../include/mount.h"
# include	"../include/stat.h"
# include	<errno.h>

struct m_table mtab[NMOUNT];

/*
 * Mount - the mount system call.
 */
mount(special, name, rwflag)
char *special, *name;
{
	int ret, (*fnc)(), s_dev;
	struct inode *s_iptr, *n_iptr;
	struct m_table *mptr;

	ret = -1;
	if (s_iptr = namlock(special, SEARCH, NULLIPTR)) {
		if ((s_iptr->i_mode & S_IFMT) == S_IFBLK) {
			if (n_iptr = namlock(name, SEARCH, NULLIPTR)) {
				if (n_iptr->i_nlocks == 1) {
					/* no-one in this inode */
					if (mptr = m_free(n_iptr->i_mdev, n_iptr->i_minor, n_iptr->i_ino)) {
						/* found a free mount entry */
						/* note child device info */
						s_dev = s_iptr->i_addr[0];

						mptr->m_cdev = &bdevsw[major(s_dev)];
						mptr->m_cminor = minor(s_dev);

						/* open the block device */
						if(fnc = mptr->m_cdev->openfnc){
							ret = (*fnc)(mptr->m_cminor);
							/* If error release mount table entry */
							if(ret == -1) mptr->m_pino = 0;
						}
						else {
							/* if no open function, assume OK */
							ret = 0;
						}
					}
					/* else, no space in mount table */
				}
				/* else, "name" was being used */
				else error(EBUSY);
				freeiptr(n_iptr);
			}
			/* else, "name" didn't exist */
		}
		/* else, "special" wasn't a block device */
		else error(ENOTBLK);
		freeiptr(s_iptr);
	}
	/* else, "special" didn't exist */

	return ret;
}

/*
 * Umount - the dismount system call.
 */
umount(special)
char *special;
{
	int (*fnc)(), s_dev, ret;
	struct inode *s_iptr, *tmp_i;
	struct dev *d_ptr;
	struct m_table *mptr;

	ret = -1;

	if (s_iptr = namlock(special, SEARCH, NULLIPTR)) {
		if ((s_iptr->i_mode & S_IFMT) == S_IFBLK) {
			s_dev = s_iptr->i_addr[0];
			d_ptr = &bdevsw[major(s_dev)];

			if (mptr = c_mfind(d_ptr, minor(s_dev))) {
				/* found mount entry, is device quiet? */
				if ( !((tmp_i = i_find(mptr->m_cdev, mptr->m_cminor, 0)) && tmp_i->i_nlocks)) {
					/* quiet - so unmount at last */
					sync();
					mptr->m_pino = 0;

					if (fnc = d_ptr->closefnc)
						ret = (*fnc)(mptr->m_cminor);
					else
						/* assume device needs no close */
						ret = 0;
				}
				/* else, device was busy */
			}
			/* else, device wasn't mounted */
		}
		/* else, device is not block special */

		freeiptr(s_iptr);
	}
	/* else, device didn't exist */

	return ret;
}

/*
 * M_volparent - called if a root-directory 'iptr' is to be searched for "..".
 *	Returns a locked pointer to the directory on which the volume is mounted
 *	so that this can then be searched for ".." instead.
 *	If this indirection does occur, the locked inode of the root-directory
 *	is unlocked.
 *	If it doesn't occur, the root-directory inode is untouched, and NULL is
 *	returned.
 */
struct inode *
m_volparent(iptr)
struct inode *iptr;
{
	struct m_table *mptr;

	if (mptr = c_mfind(iptr->i_mdev, iptr->i_minor)) {
		freeiptr(iptr);
		return getiptr(mptr->m_pdev, mptr->m_pminor, mptr->m_pino);
	}

	return NULLIPTR;
}

/*
 * M_getiptr - called to obtain a locked pointer to inode 'nami' in directory
 *	'iptr'. If this inode is mounted-upon, then a pointer to the root inode
 *	of the child volume is returned. The directory inode pointer is not
 *	affected.
 */
struct inode *
m_getiptr(iptr, nami, mounted)
struct inode *iptr;
int *mounted;
{
	struct inode *c_iptr;
	struct m_table *mptr;

	*mounted = 0;

	/* find if there's a volume mounted on here */
	if (mptr = m_find(iptr->i_mdev, iptr->i_minor, nami)) {
		c_iptr = getiptr(mptr->m_cdev, mptr->m_cminor, ROOTINO);
		*mounted = 1;
	}
	else
		c_iptr = getiptr(iptr->i_mdev, iptr->i_minor, nami);

	return c_iptr;
}

/*
 * M_find - scans mount table for the parent device and i-number given.
 *		Returns a null if required one not there.
 */
struct m_table *
m_find(mdev, dminor, ino)
struct dev *mdev;
{
	struct m_table *mptr;

	for (mptr = mtab; mptr < &mtab[NMOUNT]; mptr++) {
		if (mptr->m_pdev == mdev && mptr->m_pminor == dminor) {
			/* match i-numbers (if given) */
			if (ino == 0 || ino == mptr->m_pino)
				return mptr;
		}
	}

	return NULLMPTR;
}

/*
 * M_free - find a free mount table entry if there is one.
 *		Notes parent inode info in structure.
 */
struct m_table *
m_free(mdev, dminor, ino)
struct dev *mdev;
{
	struct m_table *mptr;

	for (mptr = mtab; mptr < &mtab[NMOUNT]; mptr++) {
		if (mptr->m_pino == 0) {
			mptr->m_pino = ino;
			mptr->m_pdev = mdev;
			mptr->m_pminor = dminor;
			return mptr;
		}
	}

	return NULLMPTR;
}

/*
 * C_mfind - scans mount table for entry where device given is mounted.
 */
struct m_table *
c_mfind(mdev, dminor)
struct dev *mdev;
{
	struct m_table *mptr;

	for (mptr = mtab; mptr < &mtab[NMOUNT]; mptr++) {
		if (mptr->m_cdev == mdev && mptr->m_cminor == dminor && mptr->m_pino)
			return mptr;
	}

	return NULLMPTR;
}
