/*
 * This file belongs to FreeMiNT. It's not in the original MiNT 1.12
 * distribution. See the file CHANGES for a detailed log of changes.
 * 
 * 
 * Copyright 1998, 1999, 2000 Frank Naumann <fnaumann@freemint.de>
 * All rights reserved.
 * 
 * This file is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2, or (at your option)
 * any later version.
 * 
 * This file is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with this program; if not, write to the Free Software
 * Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
 * 
 * 
 * begin:	1998-02
 * last change: 2000-01-12
 * 
 * Author: Frank Naumann <fnaumann@freemint.de>
 * 
 * please send suggestions or bug reports to me or
 * the MiNT mailing list
 * 
 * 
 * changes since last version:
 * 
 * 2000-01-12:
 * 
 * - new: changes all over the place  for blocking
 *        RWABS transfers
 * 
 * 1999-10-19:
 * 
 * - fix: possible corruption error in get_resident
 * - fix: additional assert in invalidate
 * 
 * 1999-10-10:
 * 
 * - new: changes to reflect new crypto layer from gryf
 * - fix: possible assert error in get_di/bio_set_lshift from gryf
 * 
 * 1999-07-18:	(version 3, revision 2)
 * 
 * - fix: bio_get_di: fixed possible memory leak
 * - fix: bio_remove: update now writeback queue
 * 
 * 1999-05-25:
 * 
 * - new: added DEV_RANDOM stuff to rwabs wrapper
 * 
 * 1999-04-09:
 * 
 * - new: bio_config: better behaviour for WP and WB setting
 *        WP setting now check for a hardware writeprotection
 * - new: bio_remove: experimental, not ready yet
 * 
 * 1999-03-31:
 * 
 * - fix: bug in bio_set_cache_size: percentage value was not updated
 * 
 * 1999-02-16:
 * 
 * Frank:
 * - new: some optimizations (redundant code)
 * 
 * Thomas:
 * - new: additional l_read caching strategie (configurable)
 *        (bio_lread, bio_set_percentage)
 * 
 * 1999-01-25:	(version 3, revision 1)
 * 
 * - fix: set_lshift sync and invalidate now!
 *        this is neccessary because the mapping is changed
 * - new: added two new functions (get_resident, del_resident)
 *        with this funtions a sector can be resident loaded
 *        and all operations (mark_modified, lookup, lock/unlock, ...)
 *        are allowed; automatically deleted on an invalidate call
 *        [I need this for the ext2.xfs]
 *        -> changed also some internal functions to reflect these
 * 
 * 1999-01-21:
 * 
 * - new: revisions level for compatible feature enhancement
 *        (changed also 'include/block_IO.h')
 * - fix: xhdi_lock/xhdi_unlock can't use XHReserve because
 *        there can be more than one partition on the same device
 * - new: working rwabs_xhdi for more than 65535 sectors
 * 
 * 1998-12-28:
 * 
 * - new: some changes releated to XHDI lock/unlocking
 * - fix: rwabs_log/rwabs_lrec wrong logical to physical mapping
 * 
 * 1998-11-14:
 * 
 * - fix: pun FATAL error in init_block_IO
 * - fix: bio_get_di: correct mapping in BIOS mode
 * 
 * 1998-11-03:
 * 
 * - fix: calculation of maximum clustersize (short <-> long)
 * - add: writeback optimization in bio_wb_queue
 * 
 * 1998-10-18:
 * 
 * - fix: bio_large_write/bio_invalidate: dereferencing a freed block
 * - fix: bio_res_di: missing initializations
 * - add: BIO_ASSERT makro, activated on debug kernel
 * - add: some more BIO_ASSERT for critical data/operations
 * - fix: replaced assert by BIO_ASSERT
 * 
 * 1998-09-22:
 * 
 * - fix: bio_wbq_remove clear now wb_next/wb_free
 * 
 * 1998-09-08:
 * 
 * - new: removed all 'const' DI
 * - new: add XHReserve/XHLock support for removable medias
 * 
 * 1998-09-02:	(version 3)
 * 
 * - Warning: Interface really changed!
 * 
 * - change: optimised l_write for small transfers
 * - merged hdio.c and bcache.c into block_IO.c
 *   this simplify a lot and allows the integration of additional features
 *   - add writeback queues, dirty UNITs will be written back
 *     in sorted order now, UNITs will also be blocked
 *   - add seperate UNIT hash tables for each device
 * 
 * - change: getunit/read -> remove lock parameter
 * - change: l_read/l_write -> works blockorientated
 *                          -> self optimising data transfers
 * 
 * 1998-07-13:	(version 2)
 * 
 * - Warning: Interface really changed!
 * 
 * - new: bio_lookup -> check if a UNIT is in cache
 * - new: bio_getunit -> same as bio_read but without reading
 *        (useful for only written units)
 * - new: bio_lock -> lock a unit after read
 * - new: prototype for bio_pre_read (not implemented yet)
 * - fix: l_read/l_write check for existing cache entries
 *        and sync if necessary
 * 
 * known bugs:
 * 
 * - nothing :-)
 * 
 * todo:
 * 
 * - bio_pre_read
 * 
 */

# include "block_IO.h"
# include "global.h"

# include "libkern/libkern.h"

# include "bios.h"
# include "kmemory.h"
# include "pun.h"
# include "proc.h"
# include "random.h"
# include "scsidrv.h"
# include "timeout.h"
# include "xhdi.h"


# define DEFAULT	128UL		/* default cache in kB */
# define DEFAULT_PERC	5UL		/* 5% */

# define WB_BUFFER	(1024UL * 64)	/* 64 kb writeback buffer (static) */

# define HASHBITS	8		/* size of UNIT hashtable */
# define HASHSIZE	(1UL << HASHBITS)
# define HASHMASK	(HASHSIZE - 1)

# define MIN_BLOCK	8192UL		/* minimal block size */
# define CHUNK_SIZE	512UL		/* minimal chunk size */
# define CHUNK_SHIFT	9		/* shift value */

# define UNLOCK		0
# define LOCK		1

/*
 * debugging stuff
 */

# ifdef DEBUG_INFO
# define BLOCK_IO_DEBUG 1
# define BIO_LOGFILE "u:\\ram\\fat.log"
# define BIO_DUMPFILE "u:\\ram\\block_IO.dmp"
# endif

/****************************************************************************/
/* BEGIN definition part */

static long	_cdecl bio_config	(const ushort dev, const long config, const long mode);

/* DI management */
static DI *	_cdecl bio_get_di	(ushort drv);
static DI *	_cdecl bio_res_di	(ushort drv);
static void	_cdecl bio_free_di	(DI *di);

/* physical/logical calculation init */
static void	_cdecl bio_set_pshift	(DI *di, ulong physical);
static void	_cdecl bio_set_lshift	(DI *di, ulong logical);

/* cached block I/O */
static UNIT *	_cdecl bio_lookup	(DI *di, ulong sector, ulong blocksize);
static UNIT *	_cdecl bio_getunit	(DI *di, ulong sector, ulong blocksize);
static UNIT *	_cdecl bio_read		(DI *di, ulong sector, ulong blocksize);
static long	_cdecl bio_write	(UNIT *u);
static long	_cdecl bio_l_read	(DI *di, ulong sector, ulong blocks, ulong blocksize, void *buf);
static long	_cdecl bio_l_write	(DI *di, ulong sector, ulong blocks, ulong blocksize, const void *buf);

/* optional feature */
static void	_cdecl bio_pre_read	(DI *di, ulong *sector, ulong blocks, ulong blocksize);

/* synchronization */
static void	_cdecl bio_lock		(UNIT *u);
static void	_cdecl bio_unlock	(UNIT *u);

/* update functions */
static void	_cdecl bio_mark_modified(UNIT *u);
static void	_cdecl bio_sync_drv	(DI *di);

/* cache management */
static long	_cdecl bio_validate	(DI *di, ulong maxblocksize);
static void	_cdecl bio_invalidate	(DI *di);

/* resident block I/O */
static UNIT *	_cdecl bio_get_resident	(DI *di, ulong sector, ulong blocksize);
static void	_cdecl bio_rel_resident	(UNIT *u);

/* remove explicitly a cache unit without writing */
static void	_cdecl bio_remove	(UNIT *u);

BIO bio =
{
	BLOCK_IO_VERS, BLOCK_IO_REV, bio_config,
	bio_get_di, bio_res_di, bio_free_di,
	bio_set_pshift, bio_set_lshift,
	bio_lookup, bio_getunit, bio_read, bio_write, bio_l_read, bio_l_write,
	bio_pre_read,
	bio_lock, bio_unlock,
	bio_mark_modified, bio_sync_drv,
	bio_validate, bio_invalidate,
	bio_get_resident, bio_rel_resident,
	bio_remove
};

/* cache block */
struct cbl
{
	char	*data;			/* ptr to the data */
	UNIT	**active;		/* array of the used UNITS */
	ushort	*used;			/* array of the UNIT positions */
	ulong	stat;			/* access statistic */
	ushort	lock;			/* locked unit counter */
	ushort	free;			/* free chunks */
};


/*
 * internal prototypes
 */


/* rwabs wrapper */

static long	_cdecl rwabs_log	(DI *di, ushort rw, void *buf, ulong size, ulong rec);
static long	_cdecl rwabs_log_lrec	(DI *di, ushort rw, void *buf, ulong size, ulong rec);
/*static long	_cdecl rwabs_phy	(DI *di, ushort rw, void *buf, ulong size, ulong rec);*/
/*static long	_cdecl rwabs_phy_lrec	(DI *di, ushort rw, void *buf, ulong size, ulong rec);*/
static long	_cdecl rwabs_xhdi	(DI *di, ushort rw, void *buf, ulong size, ulong rec);


/* dskchng wrapper */

static long	_cdecl dskchng_bios	(DI *di);
static long	_cdecl dskchng_xhdi	(DI *di);


/* */

INLINE void	bio_xhdi_lock		(register DI *di);
INLINE void	bio_xhdi_unlock		(register DI *di);


/* cache help functions */

INLINE long	bio_get_chunks		(register ulong size);
INLINE void	bio_update_stat		(register UNIT *u);


/* cache hash table functions */

INLINE ulong	bio_hash		(register const ulong sector);
INLINE UNIT *	bio_hash_lookup		(register const ulong sector, register const ulong size, register UNIT **table);
INLINE void	bio_hash_install	(register UNIT *u);
INLINE void	bio_hash_remove		(register UNIT *u);


/* basic unit I/O routines */

INLINE long	bio_readin		(DI *di, void *buffer, ulong size, ulong sector);
INLINE long	bio_writeout		(DI *di, const void *buffer, ulong size, ulong sector);
INLINE long	bio_unit_read		(register UNIT *u);
INLINE long	bio_unit_write		(register UNIT *u);
INLINE int	bio_unit_wait		(register UNIT *u);


/* writeback queue functions */

INLINE void	bio_wbq_insert		(register UNIT *u);
static void	bio_wbq_remove		(register UNIT *u);
INLINE UNIT *	bio_wbq_getfirst	(register UNIT **queue);

INLINE long	bio_wb_unit		(register UNIT *u);
static void	bio_wb_queue		(DI *di);


/* cache unit management functions */

static void	bio_unit_remove_cache	(register UNIT *u);
static void	bio_unit_remove		(register UNIT *u);
static UNIT *	bio_unit_get		(DI *di, ulong sector, ulong size);


/* debugging functions */

# ifndef BLOCK_IO_DEBUG

#  define BIO_ASSERT(x)
#  define BIO_FORCE(x)			{ FORCE x; }
#  define BIO_ALERT(x)			{ ALERT x; }
#  define BIO_DEBUG(x)
#  define BIO_DEBUG_CACHE(x)

# else

#  define BIO_ASSERT(x)			{ assert x; }
#  define BIO_FORCE(x)			{ FORCE x; }
#  define BIO_ALERT(x)			{ ALERT x; }
#  define BIO_DEBUG(x)			{ bio_debug x; }	/* DEBUG (x) */
#  define BIO_DEBUG_CACHE(x)		{ bio_dump_cache x; }
   static long debug_mode;
   static void bio_debug (const char *s, ...);
   static void bio_dump_cache (void);

# endif

/* END definition part */
/****************************************************************************/

/****************************************************************************/
/* BEGIN rwabs wrapper */

static long _cdecl
rwabs_log (DI *di, ushort rw, void *buf, ulong size, ulong rec)
{
	register ulong n;
	register ulong recno;
	
# ifdef DEV_RANDOM
	add_blkdev_randomness (di->drv);
# endif
	
	n = size >> di->pshift;
	recno = rec << di->lshift;
	
	if (!n || n > 65535UL)
	{
		BIO_ALERT (("block_IO.c: rwabs_log (%c): n outside range (%li)", di->drv+'A', n));
		return ESECTOR;
	}
	
	return rwabs (rw, buf, n, recno, di->drv, 0L);
}

static long _cdecl
rwabs_log_lrec (DI *di, ushort rw, void *buf, ulong size, ulong rec)
{
	register ulong n;
	register ulong recno;
	
# ifdef DEV_RANDOM
	add_blkdev_randomness (di->drv);
# endif
	
	n = size >> di->pshift;
	recno = rec << di->lshift;
	
	if (!n || n > 65535UL)
	{
		BIO_ALERT (("block_IO.c: rwabs_log_lrec (%c): n outside range (%li)", di->drv+'A', n));
		return ESECTOR;
	}
	
	return rwabs (rw, buf, n, -1, di->drv, recno);
}

# if 0
static long _cdecl
rwabs_phy (DI *di, ushort rw, void *buf, ulong size, ulong rec)
{
	register ulong n;
	register ulong recno;
	
# ifdef DEV_RANDOM
	add_blkdev_randomness (di->drv);
# endif
	
	n = size >> di->pshift;
	recno = rec << di->lshift;
	
	if (!n || n > 65535UL)
	{
		BIO_ALERT (("block_IO.c: rwabs_phy (%c): n outside range (%li)", di->drv+'A', n));
		return ESECTOR;
	}
	
# if 0
	if ((recno + n) > di->size)
	{
		BIO_ALERT (("block_IO.c: rwabs_phy: access outside partition (drv = %i)", di->drv));
		return ESECTOR;
	}
# endif
	
	BIO_FORCE (("block_IO.c: (%i) rw = %i, start = %li, recno = %li, size = %li, n = %li", di->major, rw, di->start, recno, size, n));
	return rwabs (rw | 8, buf, n, (recno + di->start), di->major, 0L);
}
# endif

# if 0
static long _cdecl
rwabs_phy_lrec (DI *di, ushort rw, void *buf, ulong size, ulong rec)
{
	register ulong n;
	register ulong recno;
	
# ifdef DEV_RANDOM
	add_blkdev_randomness (di->drv);
# endif
	
	n = size >> di->pshift;
	recno = rec << di->lshift;
	
	if (!n || n > 65535UL)
	{
		BIO_ALERT (("block_IO.c: rwabs_phy_lrec (%c): n outside range (%li)", di->drv+'A', n));
		return ESECTOR;
	}
	
# if 0
	if ((recno + n) > di->size)
	{
		BIO_ALERT (("block_IO.c: rwabs_phy_lrec: access outside partition (drv = %i)", di->drv));
		return ESECTOR;
	}
# endif
	
	BIO_FORCE (("block_IO.c: (%i) rw = %i, start = %li, recno = %li, size = %li, n = %li", di->major, rw, di->start, recno, size, n));
	return rwabs (rw | 8, buf, n, -1, di->major, (recno + di->start));
}
# endif

static long _cdecl
rwabs_xhdi (DI *di, ushort rw, void *buf, ulong size, ulong rec)
{
	register ulong n;
	register ulong recno;
	
# ifdef DEV_RANDOM
	add_blkdev_randomness (di->drv);
# endif
	
	n = size >> di->pshift;
	recno = rec << di->lshift;
	
	if (!n)
	{
		BIO_ALERT (("block_IO.c: rwabs_xhdi (%c): n = 0 (failure)!", di->drv+'A'));
		return ESECTOR;
	}
	
	if ((recno + n) > di->size)
	{
		BIO_ALERT (("block_IO.c: rwabs_xhdi (%c): access outside partition", di->drv+'A'));
		return ESECTOR;
	}
	
	recno += di->start;
	
	while (n > 65535UL)
	{
		register long r;
		
		r = XHReadWrite (di->major, di->minor, rw, recno, 65535, buf);
		if (r) return r;
		
		recno += 65535UL;
		n -= 65535UL;
		buf = (char *) buf + (65535UL << di->pshift);
	}
	
	return XHReadWrite (di->major, di->minor, rw, recno, n, buf);
}

/* END rwabs wrapper */
/****************************************************************************/

/****************************************************************************/
/* BEGIN dskchng wrapper */

static long _cdecl
dskchng_bios (DI *di)
{
	register long r;
	
	r = mediach (di->drv);
	if (r)
	{
		(void) getbpb (di->drv);
	}
	
	return r;
}

static long _cdecl
dskchng_xhdi (DI *di)
{
	register long r;
	
	r = mediach (di->drv);
	if (r)
	{
		(void) getbpb (di->drv);
	}
	
	return r;
}

/* END dskchng wrapper */
/****************************************************************************/

/****************************************************************************/
/* BEGIN  */

# if 0
INLINE void
bio_xhdi_lock (register DI *di)
{
	if (!di->key)
	{
		di->key = XHReserve (di->major, di->minor, LOCK, 0);
		
		if (di->key && di->mode & BIO_LOCKABLE)
		{
			XHLock (di->major, di->minor, LOCK, di->key);
		}
	}
}

INLINE void
bio_xhdi_unlock (register DI *di)
{
	if (di->lock == ENABLE && di->key)
	{
		if (di->mode & BIO_LOCKABLE)
		{
			XHLock (di->major, di->minor, UNLOCK, di->key);
		}
		
		XHReserve (di->major, di->minor, UNLOCK, di->key);
		di->key = 0;
	}
}
# else
INLINE void
bio_xhdi_lock (register DI *di)
{
	if (di->key == 0)
	{
		if (di->mode & BIO_LOCKABLE)
		{
			XHLock (di->major, di->minor, LOCK, 0);
		}
		
		di->key = 1;
	}
}

INLINE void
bio_xhdi_unlock (register DI *di)
{
	if (di->lock == ENABLE && di->key == 1)
	{
		if (di->mode & BIO_LOCKABLE)
		{
			XHLock (di->major, di->minor, UNLOCK, 0);
		}
		
		di->key = 0;
	}
}
# endif

/* END  */
/****************************************************************************/

/****************************************************************************/
/* BEGIN cache help functions */

INLINE long
bio_get_chunks (register ulong size)
{
	return (size + (CHUNK_SIZE - 1)) >> CHUNK_SHIFT;
}

INLINE void
bio_update_stat (register UNIT *u)
{
	u->stat = c20ms;
	if (u->cbl)
		u->cbl->stat = c20ms;
}

/* END cache help functions */
/****************************************************************************/

/****************************************************************************/
/* BEGIN cache hash table */

/*
 * unit hash manipulation
 * 
 * ATTENTION: all functions must be executed atomic!
 */

INLINE ulong
bio_hash (register const ulong sector)
{
	register ulong hash;
	
	hash = sector;
	hash = hash + (hash >> HASHBITS) + (hash >> (HASHBITS << 1));
	
	return hash  & HASHMASK;
}

INLINE UNIT *
bio_hash_lookup (register const ulong sector, register const ulong size, register UNIT **table)
{
	register UNIT *u;
	
	BIO_ASSERT ((table));
	
	for (u = table [bio_hash (sector)]; u; u = u->next)
	{
		if (u->sector == sector)
		{
			/* failure of the xfs */
			BIO_ASSERT ((size <= u->size));
			
			bio_update_stat (u);
			return u;
		}
	}
	
	return NULL;
}

INLINE void
bio_hash_install (register UNIT *u)
{
	register UNIT **n = &(u->di->table [bio_hash (u->sector)]);
	
	u->next = *n;
	*n = u;
	
	bio_update_stat (u);
}

static void
bio_hash_remove (register UNIT *u)
{
	register UNIT **n = &(u->di->table [bio_hash (u->sector)]);
	
	while (*n)
	{
		if (u == *n)
		{
			/* remove from table */
			*n = (*n)->next;
			
			return;
		}
		n = &((*n)->next);
	}
}

/* END cache hash table */
/****************************************************************************/

/****************************************************************************/
/* BEGIN basic unit I/O routines */

/*
 * read in size bytes in buffer to sector
 * on device DI
 * 
 * ATTENTION: this function can/will block!
 */

INLINE long
bio_readin (DI *di, void *buffer, ulong size, ulong sector)
{
	register long r;
	
	r = BIO_RWABS (di, 0, buffer, size, sector);
	if (r)
	{
		BIO_ALERT (("block_IO.c: bio_readin: RWABS fail (return = %li))", r));
	}
	else
	{
		BIO_DEBUG (("bio_readin [sector %lu]: %lu bytes read!", sector, size));
	}
	
	return r;
}

/*
 * write out size bytes in buffer to sector
 * on device DI
 * 
 * ATTENTION: this function can/will block!
 */

INLINE long
bio_writeout (DI *di, const void *buffer, ulong size, ulong sector)
{
	register long r;
	
	r = BIO_RWABS (di, 1, (void *) buffer, size, sector);
	if (r)
	{
		BIO_ALERT (("block_IO.c: bio_writeout: RWABS fail (ignored, return = %li))", r));
	}
	else
	{
		BIO_DEBUG (("bio_writeout [sector %lu]: %lu bytes written back!", sector, size));
	}
	
	return r;
}

INLINE long
bio_unit_read (register UNIT *u)
{
	register long r;
	
	u->io_pending = BIO_UNIT_READ;
	r = bio_readin (u->di, u->data, u->size, u->sector);
	u->io_pending = BIO_UNIT_READY;
	
	if (u->io_sleep)
	{
		wake (IO_Q, (long) u);
		u->io_sleep = 0;
	}
	
	return r;
}

INLINE long
bio_unit_write (register UNIT *u)
{
	register long r;
	
	u->io_pending = BIO_UNIT_WRITE;
	r = bio_writeout (u->di, u->data, u->size, u->sector);
	u->io_pending = BIO_UNIT_READY;
	
	if (u->io_sleep)
	{
		wake (IO_Q, (long) u);
		u->io_sleep = 0;
	}
	
	return r;
}

INLINE int
bio_unit_wait (register UNIT *u)
{
	if (u->io_pending != BIO_UNIT_READY)
	{
		FORCE ("block_IO: sleeping in bio_unit_wait [%c:, %lu, %lu]", 'A'+u->di->drv, u->sector, u->size);
		
		u->io_sleep = 1;
		sleep (IO_Q, (long) u);
		
		return 1;
	}
	
	return 0;
}

/* END basic unit I/O routines  */
/****************************************************************************/

/****************************************************************************/
/* BEGIN writeback queue functions */

/*
 * ATTENTION: must be executed atomic!
 * 
 * - wb_next/wb_prev must be NULL
 */

INLINE void
bio_wbq_insert (register UNIT *u)
{
	if (!u->dirty)
	{
		register UNIT *queue = u->di->wb_queue;
		
		u->dirty = 1;
		u->di->lock++;
		
		if (queue)
		{
			register UNIT *old = NULL;
			
			while (queue && queue->sector < u->sector)
			{
				old = queue;
				queue = queue->wb_next;
			}
			
			if (queue)
			{
				if (queue->wb_prev)
				{
					queue->wb_prev->wb_next = u;
					u->wb_prev = queue->wb_prev;
				}
				
				u->wb_next = queue;
				queue->wb_prev = u;
				
				/* head check */
				if (u->di->wb_queue == queue)
				{
					 u->di->wb_queue = u;
				}
			}
			else
			{
				/* last element */
				old->wb_next = u;
				u->wb_prev = old;
			}
		}
		else
		{
			/* empty list */
			u->di->wb_queue = u;
		}
	}
}

/*
 * ATTENTION: must be executed atomic!
 * 
 * - set wb_next/wb_prev to NULL
 */

static void
bio_wbq_remove (register UNIT *u)
{
	if (u->dirty)
	{
		if (u->wb_next)
			u->wb_next->wb_prev = u->wb_prev;
		
		if (u->wb_prev)
			u->wb_prev->wb_next = u->wb_next;
		else
		{
			/* u is first element -> correct start */
			u->di->wb_queue = u->wb_next;
		}
		
		u->wb_next = NULL;
		u->wb_prev = NULL;
		u->dirty = 0;
		
		u->di->lock--;
	}
}

/*
 * ATTENTION: must be executed atomic!
 * 
 * - set wb_next/wb_prev to NULL
 */

static UNIT *
bio_wbq_getfirst (register UNIT **queue)
{
	register UNIT *u = *queue;
	
	if (u)
	{
		*queue = u->wb_next;
		if (*queue)
			(*queue)->wb_prev = NULL;
		
		u->wb_next = NULL;
		u->wb_prev = NULL;
		u->dirty = 0;
		
		u->di->lock--;
	}
	
	return u;
}

/*
 * writeback the cache UNIT u
 * 
 * - first remove element from writeback queue
 * - then writeback
 * 
 * ATTENTION: this function can/will block!
 */

INLINE long
bio_wb_unit (register UNIT *u)
{
	if (u->dirty)
	{
		bio_wbq_remove (u);
		return bio_unit_write (u);
	}
	
	return E_OK;
}

/*
 * buffer and synchronization stuff
 * 
 * - buffer can be freely used after it's locked (size: WB_SIZE)
 * - buffer is 16 byte aligned (set up in init)
 * 
 * ATTENTION: this functions can/will block!
 */

static char _buffer [WB_BUFFER + 16];
static char *buffer;

static long buffer_locked = 0;
static long buffer_sleepers = 0;

static void
buffer_lock (void)
{
	while (buffer_locked)
	{
		buffer_sleepers++;
		sleep (IO_Q, (long) &buffer_locked);
		buffer_sleepers--;
	}
	
	buffer_locked = 1;
}

static void
buffer_unlock (void)
{
	buffer_locked = 0;
	if (buffer_sleepers)
		wake (IO_Q, (long) &buffer_locked);
}

/*
 * writeback a complete queue
 * 
 * - use buffer for writeback optimization
 * 
 * ATTENTION: this function can/will block!
 */

INLINE void
bio_wb_queue (DI *di)
{
	register UNIT *u = bio_wbq_getfirst (&(di->wb_queue));
	
	while (u)
	{
		register UNIT *next = bio_wbq_getfirst (&(di->wb_queue));
		
		/* calculate offset to next sector */
		register long incr = u->size >> di->p_l_shift;
		
		BIO_ASSERT ((bio_unit_wait (u) == 0));
		BIO_ASSERT ((next ? (bio_unit_wait (next) == 0) : 1));
		
		if (next
			&& ((u->sector + incr) == next->sector)
			&& ((u->size + next->size) <= WB_BUFFER))
		{
			buffer_lock ();
			{
				register long sector = u->sector;
				register long size = u->size;
				
				quickmove (buffer, u->data, size);
				/* fcopy (buffer, u->data, size); */
				
				do {
					u = next;
					next = bio_wbq_getfirst (&(di->wb_queue));
					
					quickmove (buffer + size, u->data, u->size);
					/* fcopy (buffer + size, u->data, u->size); */
					
					size += u->size;
					incr = u->size >> di->p_l_shift;
				}
				while (next
					&& ((u->sector + incr) == next->sector)
					&& ((size + next->size) <= WB_BUFFER));
				
				bio_writeout (di, buffer, size, sector);
			}
			buffer_unlock ();
		}
		else
		{
			bio_unit_write (u);
		}
		
		u = next;
	}
}

/* END writeback queue functions */
/****************************************************************************/

/****************************************************************************/
/* BEGIN cache unit management */

/*
 * block cache
 */

static struct
{
	ulong	percentage;	/* max. percentage to cache for l_read */
	ulong	max_size;	/* max. blocksize */
	ulong	chunks;		/* number of chunks in each block */
	ulong	count;		/* number of blocks in cache */
	CBL	*blocks;	/* ptr array to the cache blocks */
	
} cache;

static void
bio_unit_remove_cache (register UNIT *u)
{
	BIO_ASSERT ((u->dirty == 0))
	BIO_ASSERT ((bio_hash_lookup (u->sector, u->size, u->di->table)));
	
	/* remove from hash table */
	bio_hash_remove (u);
	
	if (u->cbl)
	{
		const ulong chunks = bio_get_chunks (u->size);
		register ushort *used = u->cbl->used + u->pos;
		register ulong n;
		
		BIO_ASSERT ((*(u->cbl->active + u->pos) == u));
		
		*(u->cbl->active + u->pos) = NULL;
		
		/* clear block datas */
		for (n = chunks; n; n--, used++)
		{
			*used = 0;
		}
		
		/* remove any lock */
		if (u->lock)
			u->cbl->lock -= u->lock;
		
		/* correct n */
		u->cbl->free += chunks;
	}
	else
	{
		kfree (u->data);
	}
	
	/* free the memory */
	kfree (u);
}

/*
 * ATTENTION: this functions can/will block!
 */

static void
bio_unit_remove (register UNIT *u)
{
	/* writeback if dirty */
	bio_wb_unit (u);
	
	/*  */
	bio_unit_remove_cache (u);
}

/*
 * ATTENTION: this functions can/will block!
 */

static UNIT *
bio_unit_get (DI *di, ulong sector, ulong size)
{
	const ulong n = bio_get_chunks (size);
	UNIT *new;
	
	register long found = -1;
	int retries = 5;
	
	BIO_DEBUG (("bio_unit_get: enter (size = %lu)", size));
	
	/* failure of the xfs */
	BIO_ASSERT ((size <= cache.max_size));
	
retry:
	{	register CBL *b = cache.blocks;
		register const ulong ni = n;
		register ulong min = 4294967295UL;
		register long i;
		
		for (i = cache.count; i; i--, b++)
		{
			if (b->lock == 0)
			{
				register ulong temp;
				
				if (ni < b->free)
				{
					found = cache.count - i;
					break;
				}
				
				temp = b->stat;
				if (temp < min)
				{
					min = temp;
					found = cache.count - i;
				}
			}
		}
	}
	
	if (found < 0)
	{
		if (retries--)
		{
			nap (200);
			goto retry;
		}
		
		BIO_ALERT (("block_IO.c: abort, no free unit in cache! (cache to small?)"));
		return NULL;
	}
	
	BIO_DEBUG (("bio_unit_get: use CBL %li", found));
	
	new = kmalloc (sizeof (*new));
	if (new)
	{
		CBL * const b = cache.blocks + found;
		ushort *actual_used = b->used;
		register const ulong end = (cache.chunks == n) ? 0 : cache.chunks - n + 1;
		register long long min_cost = 4294967295UL;
		long i;
		
		found = 0;
		
		for (i = end; i; i--, actual_used++)
		{
			register ushort *used = actual_used;
			register ushort old_used = 0;
			register long cost = 0;
			register long j;
			
			for (j = n; j; j--, used++)
			{
				if (*used)
				{
					if (*used != old_used)
					{
						register UNIT *u = b->active [*used - 1];
						old_used = *used;
						cost += u->size;
						cost -= (c20ms - u->stat);
						if (u->dirty) cost <<= 1;
					}
				}
				else
				{
					cost -= CHUNK_SIZE;
				}
			}
			
			if (cost < min_cost)
			{
				min_cost = cost;
				found = end - i;
			}
		}
		
		/* prevent bio_unit_get to access this CBL again
		 * as bio_unit_remove can block
		 */
		b->lock++;
		
		new->data = b->data + (found << CHUNK_SHIFT);
		new->next = NULL;
		new->wb_prev = NULL;
		new->wb_next = NULL;
		new->cbl = b;
		new->di = di;
		new->sector = sector;
		new->size = size;
		new->stat = 0;
		new->pos = found;
		new->dirty = 0;
		new->lock = 0;
		new->io_pending = BIO_UNIT_NEW;
		new->io_sleep = 0;
		
		/* install in hash table to prevent anyone to read this unit
		 * again until we finished (bio_unit_remove can block)
		 * 
		 * we mark io_pending so anybody must wait who try
		 * to access this unit
		 */
		bio_hash_install (new);
		
		{	register ushort *used = b->used + found;
			found++;
			for (i = n; i; i--, used++)
			{
				if (*used) bio_unit_remove (b->active [*used - 1]);
				*used = found;
			}
			found--;
		}
		
		new->io_pending = BIO_UNIT_READY;
		if (new->io_sleep)
			wake (IO_Q, (long) new);
		
		b->free -= n;
		*(b->active + found) = new;
		
		b->lock--;
	}
	else
	{
		BIO_DEBUG (("bio_unit_get: leave can't get free UNIT (kmalloc (%lu) fail)", sizeof (*new)));
		BIO_ALERT (("block_IO.c: bio_unit_get: kmalloc (%lu) fail, out of memory?", sizeof (*new)));
	}
	
	return new;
}

/* END cache unit management */
/****************************************************************************/

/****************************************************************************/
/* BEGIN global data */

static DI bio_di [NUM_DRIVES];

/* END global data */
/****************************************************************************/

/****************************************************************************/
/* BEGIN init & configuration */

void
init_block_IO (void)
{
	PUN_INFO *pun;
	long i;
	
	
	/* set up aligned buffer */
	buffer = (char *) (((long) _buffer + 15) & ~15);
	
	
	/* validate AHDI minimum version */
	pun = get_pun ();
	if (!pun)
	{
		BIO_FORCE (("AHDI 3.0 not supported on this system, please update."));
	}
	
	
	/* initalize SCSIDRV interface */
	scsidrv_init ();
	
	/* initalize XHDI interface */
	XHDI_init ();
	
	
	/* initalize DI array */
	for (i = 0; i < NUM_DRIVES; i++)
	{
		DI *di = & bio_di [i];
		
		di->drv  = i;
		di->mode = 0;
		di->lock = DISABLE;
		
		di->rrwabs = &di->rwabs;
		di->rdskchng = &di->dskchng;
	}
	
	
	/*
	 * initalize cache structures
	 * initalize default cache
	 */
	
	cache.percentage = 0;
	
	if (pun)
		cache.max_size = pun->max_sect_siz * 2L;
	else
		cache.max_size = 0;
	
	cache.max_size = MAX (cache.max_size, MIN_BLOCK);
	cache.chunks = cache.max_size >> CHUNK_SHIFT;
	cache.count = 0;
	cache.blocks = NULL;
	
	if (bio_set_cache_size (DEFAULT))
		FATAL ("init_block_IO: can't initialize default cache!");
	
	bio_set_percentage (DEFAULT_PERC);
}

long
bio_set_cache_size (long size)
{
	ulong count;
	ulong m_stat;
	ulong m_block;
	CBL *blocks;
	char *data;
	long r;
	
	if (size < 0)
	{
		return cache.count * cache.max_size;
	}
	
	count = (size * 1024L) / cache.max_size;
	if (!count)
	{
		BIO_ALERT (("%s, %ld: Specified cache size to small (%li).", __FILE__, __LINE__, size));
		return EBADARG;
	}
	
	m_stat = cache.chunks;
	m_stat *= (sizeof (UNIT *) + sizeof (ushort *));
	
	m_block = m_stat;
	m_block += sizeof (CBL);
	
	blocks = kmalloc (m_block * (cache.count + count));
	data = kmalloc (count * cache.max_size);
	if ((long) data & 15)
	{
		BIO_FORCE (("%s, %ld: not aligned (%lx)!", __FILE__, (long) __LINE__, data));
	}
	
	if (!blocks || !data)
	{
		if (blocks) kfree (blocks);
		if (data) kfree (data);
		
		BIO_ALERT (("block_IO.c: Not enough RAM for buffer cache (kmalloc fail)."));
		r = ENOMEM;
	}
	else
	{
		char *c = (char *) (blocks + cache.count + count);
		long i;
		for (i = 0; i < cache.count + count; i++)
		{
			if (i < cache.count)
			{
				(blocks [i]).data = (cache.blocks [i]).data;
				(blocks [i]).active = (UNIT **) c;
				(blocks [i]).used = (ushort *) (c + cache.chunks * sizeof (UNIT *));
				(blocks [i]).stat = (cache.blocks [i]).stat;
				(blocks [i]).lock = (cache.blocks [i]).lock;
				(blocks [i]).free = (cache.blocks [i]).free;
				c += m_stat;
				
				/* initialize block */
				{
					long j;
					for (j = 0; j < cache.chunks; j++)
					{
						(blocks [i]).active [j] = (cache.blocks [i]).active [j];
						(blocks [i]).used [j] = (cache.blocks [i]).used [j];
						
						if ((blocks [i]).active [j])
						{
							((blocks [i]).active [j])->cbl = &(blocks [i]);
						}
					}
				}
			}
			else
			{
				(blocks [i]).data = data; data += cache.max_size;
				(blocks [i]).active = (UNIT **) c;
				(blocks [i]).used = (ushort *) (c + cache.chunks * sizeof (UNIT *));
				(blocks [i]).lock = 0;
				(blocks [i]).free = cache.chunks;
				(blocks [i]).stat = 0;
				c += m_stat;
				
				/* initialize block */
				{
					long j;
					for (j = 0; j < cache.chunks; j++)
					{
						(blocks [i]).active [j] = NULL;
						(blocks [i]).used [j] = 0;
					}
				}
			}
		}
		
		if (cache.blocks)
		{
			/* free old information block array */
			kfree (cache.blocks);
		}
		
		/* backup percentage value */
		if (cache.count)
			r = bio_set_percentage (ASK);
		else
			r = DEFAULT_PERC;
		
		/* set up new information block array */
		cache.blocks = blocks;
		cache.count += count;
		
		/* revalidate percentage value */
		(void) bio_set_percentage (r);
		
		r = E_OK;
	}
	
	return r;
}

long
bio_set_percentage (long percentage)
{
	if (percentage < 0)
		return (cache.percentage / (cache.count * cache.max_size));
	
	if (percentage > 100UL)
		return EBADARG;
	
	cache.percentage = cache.count * cache.max_size * percentage;
	return E_OK;
}

static long _cdecl
bio_config (const ushort drv, const long config, const long mode)
{
	if (drv >= NUM_DRIVES)
		return ENXIO;
	
	switch (config)
	{
		case BIO_WP:
		{
			register DI *di = & bio_di [drv];
			
			if (mode == ASK)
				return BIO_WP_CHECK (di);
			
			if (!(curproc->euid == 0))
				return EPERM;
			
			if (di->mode & BIO_WP_HARD)
				return EACCES;
			
			if (mode)
				di->mode |= BIO_WP;
			else
				di->mode &= ~BIO_WP;
			
			return E_OK;
		}
		case BIO_WB:
		{
			register DI *di = & bio_di [drv];
			
			if (mode == ASK)
				return BIO_WB_CHECK (di);
			
			if (!(curproc->euid == 0))
				return EPERM;
			
			if (mode)
				di->mode |= BIO_WB;
			else
				di->mode &= ~BIO_WB;
			
			return E_OK;
		}
# if 0
		case BIO_CRYPT:
		{
			if (mode == ASK)
				return (di->mode & BIO_ENCRYPTED);
			
			if (!(curproc->euid == 0))
				return EPERM;
			
			return E_OK;
			
		}
# endif
		case BIO_MAX_BLOCK:
		{
			return cache.max_size;
		}
# ifdef BLOCK_IO_DEBUG
		case BIO_DEBUGLOG:
		{
			debug_mode = mode;
			return E_OK;
		}
		case BIO_DEBUG_T:
		{
			BIO_DEBUG_CACHE (());
			return E_OK;
		}
# endif
	}
	
	return ENOSYS;
}

/* END init & configuration */
/****************************************************************************/

/****************************************************************************/
/* BEGIN DI management */

static void
bio_init_di (DI *di)
{
	/*
	 * default values
	 */
	
	di->next	= NULL;
	di->table	= NULL;
	di->wb_queue	= NULL;
	
	di->major = 0;
	di->minor = 0;
	di->mode &= ~(BIO_REMOVABLE | BIO_LOCKABLE | BIO_LRECNO);
	
	di->start = 0;
	di->size = 0;
	di->pssize = 0;
	di->pshift = 0;
	di->lshift = 0;
	di->p_l_shift = 0;
	
	/* default I/O routines */
	*di->rrwabs = rwabs_log;
	*di->rdskchng = dskchng_bios;
	
	di->valid = 0;
	di->id[0] = '\0';
	di->id[1] = '\0';
	di->id[2] = '\0';
	di->id[3] = '\0';
	di->key	= 0;
	
	di->uniterror = NULL;
}

static DI * _cdecl
bio_get_di (ushort drv)
{
	DI *di;
	
	BIO_DEBUG (("bio_get_di: entry (drv = %u)", drv));
	
	if (drv >= NUM_DRIVES)
		return NULL;
	
	di = & bio_di [drv];
	if (di->lock)
		return NULL;
	
	bio_init_di (di);
	
	di->table = kmalloc (HASHSIZE * sizeof (*(di->table)));
	if (!di->table)
	{
		BIO_ALERT (("block_IO.c: kmalloc fail in bio_get_di (%c:), out of memory?", 'A'+drv));
		return NULL;
	}
	
	/* zero out allocated memory */
	bzero (di->table, HASHSIZE * sizeof (*(di->table)));
	
	/* ok, check for a valid XHDI drive, use it by default */
	if (XHDI_installed >= 0x110)
	{
		__BPB dummy;
		ulong pssize;
		ulong flags;
		long r;
		
		r = XHInqDev2 (drv, &(di->major), &(di->minor), &(di->start), &dummy, &(di->size), di->id);
		
		if (r == E_OK)
		{
			r = XHInqTarget2 (di->major, di->minor, &pssize, &flags, NULL, 0);
		}
		
		if ((r == E_OK) && (di->start != 0xffffffffUL))
		{
			BIO_DEBUG (("bio_get_di: check XHDI drv:"));
			BIO_DEBUG (("bio_get_di: major = %u, minor = %u, pssize = %lu", di->major, di->minor, pssize));
			BIO_DEBUG (("bio_get_di: start = %lu, size = %lu, flags = %lu", di->start, di->size, flags));
			BIO_DEBUG (("bio_get_di: id = 0x%02x%02x%02x%02x", (int) di->id[0] & 0xff, (int) di->id[1] & 0xff, (int) di->id[2] & 0xff, (int) di->id[3] & 0xff));
			
			*di->rrwabs = rwabs_xhdi;
			*di->rdskchng = dskchng_xhdi;
			
			bio_set_pshift (di, pssize);
			bio_set_lshift (di, pssize);
			
			if (flags & XH_TARGET_RESERVED)
			{
				BIO_DEBUG (("bio_get_di: (XHDI) drv reserved!"));
				goto error;
			}
			
			di->mode |= BIO_LRECNO;
			
			if (flags & XH_TARGET_REMOVABLE)
			{
				BIO_DEBUG (("bio_get_di: (XHDI) drv removable!"));
				di->mode |= BIO_REMOVABLE;
			}
			
			if (flags & XH_TARGET_LOCKABLE)
			{
				BIO_DEBUG (("bio_get_di: (XHDI) drv lockable!"));
				di->mode |= BIO_LOCKABLE;
			}
			
			di->valid = 1;
			di->lock = ENABLE;
			
			BIO_DEBUG (("bio_get_di: XHDI mode ok!"));
			return di;
		}
		else if (r == E_OK)
		{
			BIO_DEBUG (("bio_get_di: XHDI reports no accessible medium (start == -1)"));
			goto error;
		}
		
		BIO_DEBUG (("bio_get_di: XHDI failure (%li), fall back to BIOS", r));
	}
	else
	{
		BIO_DEBUG (("bio_get_di: XHDI not installed, fall back to BIOS"));
	}
	
	/* fall back to BIOS */
	{
		__BPB *bpb;
		
		bpb = (__BPB *) getbpb (drv);
		if (bpb)
		{
			ulong pssize = bpb->recsiz;
			PUN_INFO *pun;
			
			if ((pssize == 0) || (pssize & 511))
			{
				/* not a valid sector size */
				goto error;
			}
			
			/* access through BIOS is always logical;
			 * so the logical size from BIOS is our physical
			 * size and we map 1:1
			 */
			bio_set_pshift (di, pssize);
			bio_set_lshift (di, pssize);
			
			pun = get_pun ();
# if 1
			if (pun && (drv >= 16 || !(pun->pun[drv] & PUN_VALID)))
			{
				BIO_DEBUG (("bio_get_di: (BIOS) lrecno ok!"));
				
				*di->rrwabs = rwabs_log_lrec;
				di->mode |= BIO_LRECNO;
			}
# else
/* not reliable enough
 */
			if (pun)
			{
				if (drv < 16 && !(pun->pun [drv] & PUN_VALID))
				{
					BIO_DEBUG (("bio_get_di: (BIOS) lrecno ok [1]!"));
					BIO_DEBUG (("bio_get_di: (BIOS) Rwabs physical mode."));
					
					/* but if physical Rwabs is allowed
					 * we assume 512 byte sector size
					 */
					pssize = 512;
					
					di->minor = pun->pun [drv];
					di->major = (di->minor & PUN_DEV) + 2;
					di->start = pun->partition_start [drv];
					di->size = 0;
					
					/* and setup this as our
					 * mapping
					 */
					bio_set_pshift (di, pssize);
					bio_set_lshift (di, pssize);
					
					*di->rrwabs = rwabs_phy_lrec;
					di->mode |= BIO_LRECNO;
					
					BIO_DEBUG (("bio_get_di: major = %i, minor = %i, start = %li", di->major, di->minor, di->start));
					BIO_FORCE (("bio_get_di: major = %i, minor = %i, start = %li", di->major, di->minor, di->start));
				}
				else if (drv > 1)
				{
					/* we assume always rwabs logical lrecno
					 * for drives after B: if an AHDI 3.0
					 * compliant harddiskdriver is present
					 */
					
					BIO_DEBUG (("bio_get_di: (BIOS) lrecno ok [2]!"));
					BIO_DEBUG (("bio_get_di: (BIOS) Rwabs logical mode."));
					
					*di->rrwabs = rwabs_log_lrec;
					di->mode |= BIO_LRECNO;
				}
			}
# endif
			
			di->valid = 1;
			di->lock = ENABLE;
			
			BIO_DEBUG (("bio_get_di: BIOS mode ok (%li)!", pssize));
			return di;
		}
	}
	
error:
	kfree (di->table);
	di->table = NULL;
	
	BIO_DEBUG (("bio_get_di: leave failure!"));
	return NULL;
}

static DI * _cdecl
bio_res_di (ushort drv)
{
	DI *di;
	
	BIO_DEBUG (("bio_res_di: entry (drv = %i)", drv));
	
	if (drv >= NUM_DRIVES) return NULL;
	
	di = & bio_di [drv];
	if (di->lock) return NULL;
	
	bio_init_di (di);
	
	di->table = kmalloc (HASHSIZE * sizeof (*(di->table)));
	if (!di->table)
	{
		BIO_ALERT (("block_IO.c: kmalloc fail in bio_get_di (%c:), out of memory?", 'A'+drv));
		return NULL;
	}
	
	/* zero out allocated memory */
	bzero (di->table, HASHSIZE * sizeof (*(di->table)));
	
	di->valid = 1;
	di->lock = ENABLE;
	
	return di;
}

static void _cdecl
bio_free_di (DI *di)
{
	BIO_DEBUG (("bio_free_di: entry (di->drv = %u)", di->drv));
	BIO_DEBUG (("bio_free_di: di->lock = %u", di->lock));
	BIO_ASSERT ((di->valid == 1));
	
	bio_invalidate (di);
	
	if (di->mode & BIO_REMOVABLE)
	{
		/* remove possible XHDI lock */
		di->lock = ENABLE;
		bio_xhdi_unlock (di);
	}
	
	kfree (di->table);
	di->table = NULL;
	
	di->valid = 0;
	di->lock = DISABLE;
}

/* END DI management */
/****************************************************************************/

/****************************************************************************/
/* BEGIN physical/logical calculation init */

static void _cdecl
bio_set_pshift (DI *di, ulong physical)
{
	BIO_DEBUG (("bio_set_pshift: %c -> %lu bytes", di->drv+'A', physical));
	
	assert (((physical & 511) == 0));
	
	di->pssize = physical;
	di->pshift = 0;
	
	while (physical > 1)
	{
		di->pshift++;
		physical >>= 1;
	}
	
	di->p_l_shift = di->pshift + di->lshift;
}

static void _cdecl
bio_set_lshift (DI *di, ulong logical)
{
	BIO_DEBUG (("bio_set_lshift: %c -> %lu bytes", di->drv+'A', logical));
	
	assert (((logical & 511) == 0));
	assert (((logical >= di->pssize)));
	
	bio_sync_drv (di);
	bio_invalidate (di);
	
	logical /= di->pssize;
	di->lshift = 0;
	
	while (logical > 1)
	{
		di->lshift++;
		logical >>= 1;
	}
	
	di->p_l_shift = di->pshift + di->lshift;
}

/* END physical/logical calculation init */
/****************************************************************************/

/****************************************************************************/
/* BEGIN cached block I/O */

static UNIT * _cdecl
bio_lookup (DI *di, ulong sector, ulong blocksize)
{
	register UNIT *u;
	
restart:
	u = bio_hash_lookup (sector, blocksize, di->table);
	
	/* verify that UNIT is sync, otherwise we must restart */
	if (u && bio_unit_wait (u))
		goto restart;
	
	return u;
}

static UNIT * _cdecl
bio_getunit (DI *di, ulong sector, ulong blocksize)
{
	register UNIT *u;
	
	BIO_DEBUG (("bio_getunit: entry (sector = %lu, drv = %u, size = %lu)", sector, di->drv, blocksize));
	
	u = bio_lookup (di, sector, blocksize);
	if (!u)
	{
		/* can block but always success */
		u = bio_unit_get (di, sector, blocksize);
	}
	
	BIO_DEBUG (("bio_getunit: leave %s", u ? "ok" : "failure"));
	return u;
}

static UNIT * _cdecl
bio_read (DI *di, ulong sector, ulong blocksize)
{
	UNIT *u;
	
	BIO_DEBUG (("bio_read: entry (sector = %lu, drv = %u, size = %lu)", sector, di->drv, blocksize));
	
	u = bio_lookup (di, sector, blocksize);
	if (!u)
	{
		u = bio_unit_get (di, sector, blocksize);
		if (u)
		{
			long r;
			
			r = bio_unit_read (u);
			if (r)
			{
				BIO_DEBUG (("bio_read: bio_unit_read fail (ret = %li)", r));
				
				bio_unit_remove_cache (u);
				u = NULL;
			}
		}
	}
	
	BIO_DEBUG (("bio_read: leave %s", u ? "ok" : "failure"));
	return u;
}

static long _cdecl
bio_write (UNIT *u)
{
	long r;
	BIO_DEBUG (("bio_write: entry"));
	
	bio_mark_modified (u);
	r = bio_wb_unit (u);
	
	BIO_DEBUG (("bio_write: leave ok (writethrough = %li)", r));
	return r;
}

static void
bio_units_add (DI *di, ulong sector, ulong blocks, ulong blocksize, void *buf, const ulong incr, const ulong size)
{
	/* Only add new blocks if the total size is less than or equal to the
	 * given max. percentage of the cache
	 */
	if ((size * 100UL) <= cache.percentage)
	{
		while (blocks)
		{
			register UNIT *u;
			
			u = bio_unit_get (di, sector, blocksize);
			if (u)
			{
				quickmovb (u->data, buf, blocksize);
				(char *) buf += blocksize;
				sector += incr;
				blocks--;
			}
			else
			{
				/* for any unknown reason there is no cache
				 * unit available
				 * harmless here, there are no side effects
				 */
				break;
			}
		}
	}
}

static long _cdecl
bio_l_read (DI *di, ulong sector, ulong blocks, ulong blocksize, void *buf)
{
	register const ulong incr = blocksize >> di->p_l_shift;
	
	register ulong tstart = sector;
	register ulong tblocks = 0;
	register long r = E_OK;
	
	BIO_DEBUG (("bio_l_read: entry (sector = %lu, drv = %u, size = %lu, incr = %lu)", sector, di->drv, blocks * blocksize, incr));
	
	/* failure of the xfs */
	BIO_ASSERT ((incr > 0));
	
	while (blocks)
	{
		UNIT *u;
		
		u = bio_lookup (di, sector, blocksize);
		if (u)
		{
			if (tblocks)
			{
				register const ulong size = tblocks * blocksize;
				
				quickmovb ((char *) buf + size, u->data, blocksize);
				
				r = bio_readin (di, buf, size, tstart);
# if 1
				if (!r)
					bio_units_add (di, tstart, tblocks, blocksize, buf, incr, size);
# endif
				
				tblocks = 0;
				(char *) buf += size;
				
				if (r) break;
			}
			else
			{
				quickmovb (buf, u->data, blocksize);
			}
			
			(char *) buf += blocksize;
		}
		else
		{
			if (tblocks == 0) tstart = sector;
			tblocks++;
		}
		
		sector += incr;
		blocks--;
	}
	
	if (tblocks)
	{
		register const ulong size = tblocks * blocksize;
		
		r = bio_readin (di, buf, size, tstart);
# if 1
		if (!r)
			bio_units_add (di, tstart, tblocks, blocksize, buf, incr, size);
# endif
	}
	
	if (r)
	{
		BIO_ALERT (("bio_l_read: leave failure, RWABS fail (ret = %li)", r));
	}
	else
	{
		BIO_DEBUG (("bio_l_read: leave ok"));
	}
	
	return r;
}

static long
bio_large_write (DI *di, ulong sector, ulong size, const void *buf)
{
	register UNIT **table = di->table;
	register ulong end = sector + (size >> di->p_l_shift);
	register long i;
	
	BIO_DEBUG (("bio_large_write: entry (sector = %lu, drv = %u, size = %lu", sector, di->drv, size));
	
	/* synchronisize cache with direct transfer
	 * -> remove entries in range: sector <= xxx < end
	 */
restart:
	for (i = 0; i < HASHSIZE; i++)
	{
		register UNIT *u = table [i];
		
		while (u)
		{
			register UNIT *next = u->next;
			
			if ((u->sector >= sector) && (u->sector < end))
			{
				/* overwritten by linear transfer
				 */
				
				if (bio_unit_wait (u))
					goto restart;
				
				/* wbq_remove - nonblocking
				 * unit_remove_cache - nonblocking
				 */
				bio_wbq_remove (u);
				bio_unit_remove_cache (u);
			}
			
			u = next;
		}
	}
	
	/* cache ready, do linear transfer
	 */
	
	i = bio_writeout (di, buf, size, sector);
	if (i)
	{
		BIO_ALERT (("bio_large_write: leave failure, RWABS fail (ret = %li)", i));
	}
	else
	{
		BIO_DEBUG (("bio_large_write: leave ok"));
	}
	
	return i;
}

INLINE long
bio_small_write (DI *di, ulong sector, ulong blocks, ulong blocksize, const void *buf)
{
	register const ulong incr = blocksize >> di->p_l_shift;
	long r = E_OK;
	
	BIO_DEBUG (("bio_small_write: entry (sector = %lu, drv = %u, blocks = %lu", sector, di->drv, blocks));
	
	while (blocks)
	{
		register UNIT *u;
		
		u = bio_lookup (di, sector, blocksize);
		if (!u)
			u = bio_getunit (di, sector, blocksize);
		
		if (!u)
		{
			/* for any unknown reason there are no
			 * free cache units available
			 * -> fall back to direct transfer
			 */
			r = bio_large_write (di, sector, blocks * blocksize, buf);
			
			/* and go out */
			break;
		}
		
		quickmovb (u->data, buf, blocksize);
		(const char *) buf += blocksize;
		
		bio_mark_modified (u);
		
		sector += incr;
		blocks--;
	}
	
	return r;
}

static long _cdecl
bio_l_write (DI *di, ulong sector, ulong blocks, ulong blocksize, const void *buf)
{
	register ulong size = blocks * blocksize;
	register long r;
	
	BIO_DEBUG (("bio_l_write: entry (sector = %lu, drv = %u, size = %lu", sector, di->drv, size));
	
	if (size > cache.max_size)
	{
		r = bio_large_write (di, sector, size, buf);
	}
	else
	{
		r = bio_small_write (di, sector, blocks, blocksize, buf);
	}
	
	return r;
}

/* END cached block I/O */
/****************************************************************************/

/****************************************************************************/
/* BEGIN optional feature */

static void _cdecl
bio_pre_read (DI *di, ulong *sector, ulong blocks, ulong blocksize)
{
	UNUSED (di); UNUSED (sector); UNUSED (blocks); UNUSED (blocksize);
	
	BIO_DEBUG (("bio_pre_read: leave not implemented"));
}

/* END optional feature */
/****************************************************************************/

/****************************************************************************/
/* BEGIN synchronization */

static void _cdecl
bio_lock (UNIT *u)
{
	register DI *di = u->di;
	
	BIO_DEBUG (("bio_lock: sector = %lu, drv = %u", u->sector, u->di->drv));
	
	u->lock++;
	if (u->cbl)
		u->cbl->lock++;
	
	di->lock++;
	
	if (di->mode & BIO_REMOVABLE)
	{
		bio_xhdi_lock (di);
	}
}

static void _cdecl
bio_unlock (UNIT *u)
{
	BIO_DEBUG (("bio_unlock: sector = %lu, drv = %u", u->sector, u->di->drv));
	
	if (u->lock)
	{
		register DI *di = u->di;
		
		u->lock--;
		if (u->cbl)
			u->cbl->lock--;
		
		di->lock--;
		
		if ((di->mode & BIO_REMOVABLE) && (di->lock == 1))
		{
			bio_xhdi_unlock (di);
		}
	}
}

/* END synchronization */
/****************************************************************************/

/****************************************************************************/
/* BEGIN update functions */

static void _cdecl
bio_mark_modified (UNIT *u)
{
	if (u->di->mode & BIO_REMOVABLE)
	{
		bio_xhdi_lock (u->di);
	}
	
	bio_wbq_insert (u);
	
	BIO_DEBUG (("bio_mark_modified: sector = %lu, drv = %u", u->sector, u->di->drv));
}

static void _cdecl
bio_sync_drv (DI *di)
{
	BIO_DEBUG (("bio_sync_drv: sync %c:", 'A' + di->drv));
	
	/* writeback queue */
	bio_wb_queue (di);
	
	BIO_DEBUG (("bio_sync_drv: wb_queue on %c: flushed.", 'A' + di->drv));
	
	if ((di->mode & BIO_REMOVABLE) && (di->lock == 1))
	{
		bio_xhdi_unlock (di);
	}
}

void
bio_sync_all (void)
{
	register long i;
	
	for (i = 0; i < NUM_DRIVES; i++)
	{
		register DI *di = &(bio_di [i]);
		
		if (di->valid)
		{
			BIO_DEBUG (("bio_sync_all: sync %c:", 'A' + di->drv));
			
			/* writeback queue */
			bio_wb_queue (di);
			
			if ((di->mode & BIO_REMOVABLE) && (di->lock == 1))
			{
				bio_xhdi_unlock (di);
			}
		}
	}
	
	BIO_DEBUG (("bio_sync_all: all wb_queues flushed."));
}

/* END update functions */
/****************************************************************************/

/****************************************************************************/
/* BEGIN cache management */

static long _cdecl
bio_validate (DI *di, ulong maxblocksize)
{
	long r = E_OK;
	UNUSED (di);
	
	/* at the moment only check the maximum blocksize */
	
	BIO_DEBUG (("bio_validate: entry (di->drv = %u, max = %lu)", di->drv, maxblocksize));
	
	if (maxblocksize > cache.max_size)
	{
		r = ENOMEM;
	}
	
	return r;
}

static void _cdecl
bio_invalidate (DI *di)
{
	/* invalid all cache units for drv */
	
	register UNIT **table = di->table;
	register long i;
	
	BIO_DEBUG (("bio_invalidate: entry (di->drv = %i)", di->drv));
	BIO_ASSERT ((table));
	
	if (di->lock > 1)
	{
		BIO_FORCE (("bio_invalidate [%c]: invalidate on LOCKED di", 'A'+di->drv));
	}
	
restart:
	/* invalidate writeback queue */
	di->wb_queue = NULL;
	
	/* remove all hashtable entries */
	for (i = 0; i < HASHSIZE; i++)
	{
		register UNIT *u = table [i];
		
		while (u)
		{
			register UNIT *next = u->next;
			
			if (bio_unit_wait (u))
				goto restart;
			
			if (u->dirty)
			{
				/* never writeback */
				u->dirty = 0;
				
				/* inform user */
				BIO_ALERT (("block_IO.c: bio_invalidate: cache unit not written back (%li, %li)!", u->sector, u->size));
			}
			
			/* remove from table */
			bio_unit_remove_cache (u);
			
			u = next;
		}
		
		BIO_ASSERT ((table [i] == NULL));
	}
	
	BIO_DEBUG (("bio_invalidate: leave ok, all units are invalidated"));
}

/* END cache management */
/****************************************************************************/

/****************************************************************************/
/* BEGIN resident block I/O */

static UNIT * _cdecl
bio_get_resident (DI *di, ulong sector, ulong blocksize)
{
	UNIT *u;
	
	BIO_DEBUG (("bio_get_resident: entry (sector = %lu, drv = %u, size = %lu)", sector, di->drv, blocksize));
	
	u = kmalloc (sizeof (*u));
	if (u)
	{
		u->data = kmalloc (blocksize);
		if (u->data)
		{
			UNIT *check;
			
			u->next = NULL;
			u->wb_prev = NULL;
			u->wb_next = NULL;
			u->cbl = NULL;
			u->di = di;
			u->sector = sector;
			u->size = blocksize;
			u->stat = 0;
			u->pos = 0;
			u->dirty = 0;
			u->lock = 0;
			
			check = bio_lookup (di, sector, blocksize);
			if (check)
			{
				quickmove (u->data, check->data, blocksize);
				
				u->lock = check->lock;
				
				if (check->dirty)
				{
					bio_wbq_remove (check);
					bio_wbq_insert (u);
				}
				
				bio_unit_remove_cache (check);
				bio_hash_install (u);
			}
			else
			{
				long r;
				
				bio_hash_install (u);
				
				r = bio_unit_read (u);
				if (r)
				{
					BIO_DEBUG (("bio_read: rwabs fail (ret = %li)", r));
					
					kfree (u->data);
					kfree (u);
					
					u = NULL;
				}
			}
		}
		else
		{
			kfree (u);
			
			u = NULL;
		}
	}
	
	BIO_DEBUG (("bio_get_resident: leave %s", u ? "ok" : "failure"));
	return u;
}

static void _cdecl
bio_rel_resident (UNIT *u)
{
	BIO_DEBUG (("bio_rel_resident: entry (sector = %lu, size = %lu)", u->sector, u->size));
	BIO_ASSERT ((u->cbl == NULL));
	
	bio_unit_remove (u);
	
	BIO_DEBUG (("bio_rel_resident: leave ok"));
}

/* END resident block I/O */
/****************************************************************************/

/****************************************************************************/
/* BEGIN remove explicitly a cache unit without writing */

static void _cdecl
bio_remove (UNIT *u)
{
	BIO_DEBUG (("bio_remove: entry (sector = %lu, size = %lu)", u->sector, u->size));
	
	bio_wbq_remove (u);
	bio_unit_remove_cache (u);
	
	BIO_DEBUG (("bio_remove: leave ok"));
}

/* END remove explicitly a cache unit without writing */
/****************************************************************************/

/****************************************************************************/
/* BEGIN debug infos */

# ifdef BLOCK_IO_DEBUG

# include "dosfile.h"
# define out_device 2 /* console */

static void
bio_debug (const char *fmt, ...)
{
	static char buf [SPRINTF_MAX];
	static const long buflen = sizeof (buf);
	
	if (debug_mode)
	{
		va_list args;
		int foo;
		FILEPTR *f;
		
		va_start (args, fmt);
		f = do_open (BIO_LOGFILE, (O_WRONLY|O_CREAT|O_APPEND), 0, NULL);
		if (f)
		{
			(void) (*f->dev->lseek)(f, 0, 2);
			
			foo = vsprintf (buf, buflen, fmt, args);
			(*f->dev->write)(f, buf, strlen (buf));
			(*f->dev->write)(f, "\r\n", 2);
			
			do_close (f);
		}
		else
		{
			foo = vsprintf (buf, buflen, fmt, args);
			BIO_FORCE ((buf));
		}
		va_end (args);
	}
}

static void
bio_dump_cache (void)
{
	static char buf [SPRINTF_MAX];
	static const long buflen = sizeof (buf);
	FILEPTR *f;
	
	f = do_open (BIO_DUMPFILE, (O_WRONLY|O_CREAT|O_TRUNC), 0, NULL);
	if (f)
	{
		CBL *b = cache.blocks;
		long i;
		
		for (i = 0; i < NUM_DRIVES; i++)
		{
			register UNIT **table = bio_di [i].table;
			register long j;
			
			if (table)
			{
		
				(*f->dev->write)(f, "table:\r\n", 8);
				for (j = 0; j < HASHSIZE; j++)
				{
					UNIT *t = table [j];
					(void) ksprintf (buf, buflen, "nr: %li\tptr = %lx", j, t);
					(*f->dev->write)(f, buf, strlen (buf));
					for (; t; t = t->next)
					{
						(void) ksprintf (buf, buflen, "\r\n\thnext = %lx\tlock = %i\tdirty = %i"
								"\tsector = %li\tdev = %i\r\n",
								t->next, t->lock, t->dirty, t->sector, t->di->drv
						);
						(*f->dev->write)(f, buf, strlen (buf));
					}
					(*f->dev->write)(f, "\r\n", 2);
				}
			}
		}
		(void) ksprintf (buf, buflen, "blocks:\t(max_size = %li)\r\n", cache.max_size);
		(*f->dev->write)(f, buf, strlen (buf));
		for (i = 0; i < cache.count; i++)
		{
			long j;
			(void) ksprintf (buf, buflen, "buffer = %lx, buffer->stat = %lu, lock = %u, free = %u\r\n", b[i].data, b[i].stat, b[i].lock, b[i].free);
			(*f->dev->write)(f, buf, strlen (buf));
			for (j = 0; j < cache.chunks; j++)
			{
				(void) ksprintf (buf, buflen, "\tused = %u\tstat = %li\tactive = %lx\r\n", b[i].used[j], b[i].active[j] ? b[i].active[j]->stat : -1, b[i].active[j]);
				(*f->dev->write)(f, buf, strlen (buf));
			}
			(*f->dev->write)(f, "\r\n", 2);
		}
		do_close (f);
	}
}
# endif

/* END debug infos */
/****************************************************************************/
