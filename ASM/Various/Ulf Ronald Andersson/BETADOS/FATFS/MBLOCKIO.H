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
 * begin:	1998-06
 * last change: 1998-09-10
 * 
 * Author: Frank Naumann <fnaumann@freemint.de>
 * 
 * please send suggestions, patches or bug reports to me or
 * the MiNT mailing list
 * 
 */

# ifndef _mint_block_IO_h
# define _mint_block_IO_h

# include "kcompiler.h"
# include "ktypes.h"


/*
 * forward declarations
 */

typedef struct crypt	CRYPT;
typedef struct di	DI;
typedef struct unit	UNIT;
typedef struct cbl	CBL;
typedef struct bio	BIO;


struct crypt
{
	BF_KEY	*key;
	long	_cdecl (*rwabs)(DI *di, ushort rw, void *buf, ulong size, ulong lrecno);
};

/* device identifikator */
struct di
{
	DI	*next;			/* internal: next in linked list */
	UNIT	**table;		/* internal: unit hash table */
	UNIT	*wb_queue;		/* internal: writeback queue */
	
	ushort	drv;			/* internal: BIOS device number (unique) */
	ushort	major;			/* XHDI */
	ushort	minor;			/* XHDI */
	ushort	mode;			/* internal: some flags */
	
# define BIO_WP_MODE		0x01	/* write-protect bit (soft) */
# define BIO_WB_MODE		0x02	/* write-back bit (soft) */
# define BIO_REMOVABLE		0x04	/* removable media */
# define BIO_LOCKABLE		0x08	/* lockable media */
# define BIO_LRECNO		0x10	/* lrecno supported */
# define BIO_WP_HARD		0x20	/* write-protected partition */
# define BIO_ENCRYPTED		0x40	/* partition is encrypted */
	
	ulong	start;			/* physical start sector */
	ulong	size;			/* physical sectors */
	ulong	pssize;			/* internal: physical sector size */
	
	ushort	pshift;			/* internal: size to count calculation */
	ushort	lshift;			/* internal: logical to physical recno calculation */
	
	long	_cdecl (*rwabs)(DI *di, ushort rw, void *buf, ulong size, ulong lrecno);
	long	_cdecl (*dskchng)(DI *di);
	
	ushort	valid;			/* internal: DI valid */
	ushort	lock;			/* internal: DI in use */
	
	char	id[4];			/* XHDI partition id (GEM, BGM, RAW, \0D6, ...) */
	ushort	key;			/* XHDI key */
	ushort	p_l_shift;		/* internal: summary of pshift and lshift */
	
	/* revision 3 extension - xfs error callback */
	long	_cdecl (*uniterror)(DI *di, long err);
	
	long	res [3];
	
	/* these are pointer to the real I/O vectors
	 * so the vectors can be overloaded
	 */
	long	_cdecl (**rrwabs)(DI *di, ushort rw, void *buf, ulong size, ulong lrecno);
	long	_cdecl (**rdskchng)(DI *di);
	
	CRYPT	crypt;			/* internal: crypto layer data */
};

/* cache unit */
struct unit
{
	char	*data;			/* pointer to the data */
	UNIT	*next;			/* next in hash table */
	UNIT	*wb_prev;		/* prev in writeback queue */
	UNIT	*wb_next;		/* next in writeback queue */
	CBL	*cbl;			/* the parent cache block or NULL for resident UNITs */
	DI	*di;			/* device identifikator */
	ulong	sector;			/* logical start sector on device */
	ulong	size;			/* size in bytes */
	ulong	stat;			/* access statistic */
	ushort	pos;			/* location in block */
	ushort	dirty;			/* modified flags: bit0 = dirty, bit1 = on wb queue */
	ushort	lock;			/* lock counter */
	uchar	io_pending;		/* pending I/O on this unit */
# define BIO_UNIT_READY		0
# define BIO_UNIT_NEW		1
# define BIO_UNIT_READ		2
# define BIO_UNIT_WRITE		4
	uchar	io_sleep;		/* process(es) sleep on this unit flag */
};


/*
 * interface
 */

struct bio
{
	ushort	version;		/* buffer cache version */
	ushort	revision;		/* buffer cache revision */
	
# define BLOCK_IO_VERS	3		/* our existing version - incompatible interface change */
# define BLOCK_IO_REV	2		/* actual revision - compatible interface change */
	
	long	_cdecl (*config)	(const ushort drv, const long config, const long mode);
	
/* config: */
# define BIO_WP		1		/* configuring writeprotect feature */
# define BIO_WB		2		/* configuring writeback mode */
# define BIO_MAX_BLOCK	10		/* return maximum cacheable blocksize */
# define BIO_DEBUGLOG	100		/* only for debugging, kernel internal */
# define BIO_DEBUG_T	101		/* only for debugging, kernel internal */
	
	/* DI management */
	DI *	_cdecl (*get_di)	(ushort drv);
	DI *	_cdecl (*res_di)	(ushort drv);
	void	_cdecl (*free_di)	(DI *di);
	
	/* physical/logical mapping setting */
	void	_cdecl (*set_pshift)	(DI *di, ulong physical);
	void	_cdecl (*set_lshift)	(DI *di, ulong logical);
	
	/* cached block I/O */
	UNIT *	_cdecl (*lookup)	(DI *di, ulong sector, ulong blocksize);
	UNIT *	_cdecl (*getunit)	(DI *di, ulong sector, ulong blocksize);
	UNIT *	_cdecl (*read)		(DI *di, ulong sector, ulong blocksize);
	long	_cdecl (*write)		(UNIT *u);
	long	_cdecl (*l_read)	(DI *di, ulong sector, ulong blocks, ulong blocksize, void *buf);
	long	_cdecl (*l_write)	(DI *di, ulong sector, ulong blocks, ulong blocksize, const void *buf);
	
	/* optional feature */
	void	_cdecl (*pre_read)	(DI *di, ulong *sector, ulong blocks, ulong blocksize);
	
	/* synchronization */
	void	_cdecl (*lock)		(UNIT *u);
	void	_cdecl (*unlock)	(UNIT *u);
	
	/* update functions */
	void	_cdecl (*mark_modified)	(UNIT *u);
	void	_cdecl (*sync_drv)	(DI *di);
	
	/* cache management */
	long	_cdecl (*validate)	(DI *di, ulong maxblocksize);
	void	_cdecl (*invalidate)	(DI *di);
	
	/* revision 1 extension: resident block I/O
	 */
	UNIT *	_cdecl (*get_resident)	(DI *di, ulong sector, ulong blocksize);
	void	_cdecl (*rel_resident)	(UNIT *u);
	
	/* revision 2 extension: remove explicitly a cache unit without writing
	 * optional, never fail
	 */
	void	_cdecl (*remove)	(UNIT *u);
	
	
	long	res[3];			/* reserved for future */
};


/*
 * useful makros
 */

# define BIO_RWABS(di, rw, buf, size, recno) \
				((*(di->rwabs))(di, rw, buf, size, recno))
# define BIO_DSKCHNG(di)	((*(di->dskchng))(di))

# define BIO_WP_CHECK(di)	((di->mode & BIO_WP_MODE) ? ENABLE : DISABLE)
# define BIO_WB_CHECK(di)	((di->mode & BIO_WB_MODE) ? ENABLE : DISABLE)
# define BIO_LR_CHECK(di)	((di->mode & BIO_LRECNO) ? ENABLE : DISABLE)

INLINE void
bio_MARK_MODIFIED (BIO *bio, UNIT *u)
{
	if (!u->dirty)
		(bio)->mark_modified (u);
}

INLINE void
bio_SYNC_DRV (BIO *bio, DI *di)
{
	if (!BIO_WB_CHECK (di))
		(bio)->sync_drv (di);
}


# endif /* _mint_block_IO_h */
