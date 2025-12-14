/*
 *	This file implements some sort of filename -> un_index conversion
 *	cache. Speeds up for real FS's (where the inode numbers are NOT
 *	junk) and slows down for the silly FS's where the inode numbers
 *	are junk.
 *
 *	12/12/93, kay roemer.
 */

#include "config.h"
#include "kerbind.h"
#include "file.h"
#include "atarierr.h"
#include "sockerr.h"

#define CACHE_ENTRIES	10

struct lookup_cache {
	short	valid;
#define CACHE_VALID	0
#define CACHE_DIRTY	1
	short	dev;
	long	inode;
	long	stamp;
#define MK_STAMP(time, date)	((((long)(date)) << 16) | (time))
	long	un_index;
};

static struct lookup_cache f_cache[CACHE_ENTRIES];

long
un_cache_lookup (name, index)
	char *name;
	long *index;
{
	XATTR attr;
	short dirty_idx, i;
	long r, stamp, fd;
	static short last_deleted = 0;

	r = f_xattr (1, name, &attr);
	if (r != 0) {
		DEBUG (("unix: un_cache_lookup: Fxattr(%s) -> %ld", name, r));
		return r;
	}
	dirty_idx = -1;
	stamp = MK_STAMP (attr.mtime, attr.mdate);
	for (i = 0; i < CACHE_ENTRIES; ++i) {
		if (f_cache[i].valid == CACHE_DIRTY) {
			dirty_idx = i;
			continue;
		}
		if (f_cache[i].inode == attr.index &&
		    f_cache[i].dev == attr.dev) {
			if (f_cache[i].stamp == stamp) {
				*index = f_cache[i].un_index;
				return 0;
			} else {
				f_cache[i].valid = CACHE_DIRTY;
				dirty_idx = i;
				break;
			}
		}
	}

/* No matching entry found. We drop dirty_entry or some other entry
   in a round robin manner if no dirty entry is left. */

	fd = f_open (name, O_RDWR);
	if (fd < 0) {
		DEBUG (("unix: un_cache_lookup: Fopen(%s) -> %ld", name, fd));
		return fd;
	}
	r = f_read (fd, sizeof (*index), index);
	f_close (fd);
	if (r >= 0 && r != sizeof (*index)) r = EACCDN;
	if (r < 0) {
		DEBUG (("unix: un_namei: Could not read idx from %s", name));
		return r;
	}
	if (dirty_idx == -1) {
		dirty_idx = last_deleted++;
		if (last_deleted >= CACHE_ENTRIES)
			last_deleted = 0;
	}
	f_cache[dirty_idx].dev = attr.dev;
	f_cache[dirty_idx].inode = attr.index;
	f_cache[dirty_idx].stamp = stamp;
	f_cache[dirty_idx].un_index = *index;
	f_cache[dirty_idx].valid = CACHE_VALID;
	return 0;
}

void
un_cache_remove (name)
	char *name;
{
	XATTR attr;
	long r;
	short i;

	r = f_xattr (1, name, &attr);
	if (r) return;
	
	for (i = 0; i < CACHE_ENTRIES; ++i) {
		if (f_cache[i].valid == CACHE_VALID &&
		    f_cache[i].inode == attr.index &&
		    f_cache[i].dev == attr.dev) {
			f_cache[i].valid = CACHE_DIRTY;
			return;
		}
	}
}

void
un_cache_init (void)
{
	int i;

	for (i = 0; i < CACHE_ENTRIES; ++i) {
		f_cache[i].valid = CACHE_DIRTY;
	}
}
