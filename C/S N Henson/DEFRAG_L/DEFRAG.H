/*
 * defrag.h - include file for the Linux file system degragmenter.
 * defrag.h,v 1.7 1993/01/07 14:48:49 linux Exp
 *
 * Copyright (C) 1992, 1993 Stephen Tweedie (sct@dcs.ed.ac.uk)
 *
 * Copyright (C) 1992 Remy Card (card@masi.ibp.fr)
 *
 * Copyright (C) 1991 Linus Torvalds (torvalds@kruuna.helsinki.fi)
 * 
 * This file may be redistributed under the terms of the GNU General
 * Public License.
 *
 */

#ifdef NODEBUG
 #define debug 0
 #define assert(a)
#else
 extern int debug;
 #include <assert.h>
#endif

#ifdef EXTFS
#include "ext.h"
#endif
#ifdef MINIXFS
#include "minix.h"
#endif

/* Use inline assembler to generate efficient bit operators */
#ifndef __GNUC__
#error "needs gcc for the bitop-__asm__'s"
#endif

#define SYNC_PERIOD 500

extern char * program_name, * version, * CVSID;
extern char * device_name;
extern int IN;
extern int verbose, show, show_version, badblocks, readonly;
extern int blocks_until_sync;

extern int changed; /* flags if the filesystem has been changed */

/* We omit a lot of the declarations when compiling misc.c, since
   misc.o is shared between extfs and minixfs versions, so we can't
   give correct types for a lot of fs-dependent stuff. */

#ifndef MISC_C

extern Block next_block_to_fill, first_zone;
extern unsigned int zones, block_size;

extern char * inode_buffer;
#define Inode		(((struct d_inode *) inode_buffer) - 1)
extern char super_block_buffer[];

/* n2d_map and d2n_map contain the zone movement maps.  Whenever a zone is
   moved, these maps are updated to allow the current occupant of a zone
   to be mapped to its original location, and the original location of any
   zone data to be mapped to its current location.

   When a zone was originally empty, the d2n_map will contain zero at
   that location to reflect the fact that there was no original occupant
   of that zone is not to be found.  The n2d_map will also be zero for
   blocks which do not currently hold any useful data and which may be
   overwritten freely.

   o2n_map contains the final translation from  old to new disc
   blocks, and is used to update inode block tables and indirection
   blocks.

   inode_map and bad_map maintain flags recording which inodes are in
   use, and which blocks are bad respectively.
*/

extern char * inode_map;
extern Block *inode_average_map;
extern int *inode_order_map;

extern Block *n2d_map, *d2n_map, *o2n_map;

/* Manipulate the inode map */
#define inode_in_use(x)	(bit (inode_map, (x)))
#define mark_inode(x)	(setbit (inode_map, (x)), changed = 1)
#define unmark_inode(x)	(clrbit (inode_map, (x)), changed = 1)

/* Manipulate the block translation maps */
#define n2d(x)		(n2d_map[(x)-first_zone])
#define d2n(x)		(d2n_map[(x)-first_zone])
#define o2n(x)		(o2n_map[(x)-first_zone])

#define unmark_zone(x)	(d2n(x) = 0, n2d(x) = 0, changed = 1)
#define zone_in_use(x)	(n2d(x) != 0)

#ifdef EXTFS
/* Manipulate the bad block map */
extern char * bad_map;
#define zone_is_bad(x)	(bit (bad_map, (x) - first_zone + 1))
#define mark_bad(x)	(setbit (bad_map, (x) - first_zone + 1), badblocks++)
#endif


/* Define modes for the walk_zone functions */
enum walk_zone_mode {WZ_SCAN, WZ_REMAP_IND, WZ_REMAP_DATA
#ifdef EXTFS
			     , WZ_BAD_BLOCKS
#endif
			     };

/* Miscellaneous function declarations */

/* The inline bitop functions... */
#ifdef atarist
#include <portst.h>
#else

#define bitop(name,op) \
static inline int name(char * addr,unsigned int nr) \
{ \
	int __res; \
	__asm__ __volatile__("bt" op "l %1,%2; adcl $0,%0" \
		:"=g" (__res) \
		:"r" (nr),"m" (*(addr)),"0" (0)); \
	return __res; \
}

bitop(bit,"")
bitop(setbit,"s")
bitop(clrbit,"r")
#endif

extern int isatty(int);

/* Block/buffer management prototypes */
enum BufferType { OUTPUT, RESCUE };
typedef enum BufferType BufferType;
	
typedef struct Buffer Buffer;
struct Buffer
{
	BufferType btype : 1;
	unsigned int in_use : 1;
	unsigned int full : 1;
	Buffer *next;
	Block dest_zone;
	unsigned char data[0];
};


extern int pool_size;
extern Buffer *pool;

extern int count_buffer_writes, count_buffer_reads;
extern int count_write_groups, count_read_groups;
extern int count_buffer_migrates, count_buffer_forces;
extern int count_buffer_read_aheads;

void read_buffer_data (Buffer *b);
void write_buffer_data_at (Buffer *b, Block dest);
void write_buffer_data (Buffer *b);

void init_buffer_tables (void);
void remap_disk_blocks (void);

void check_zone_nr (Block nr);
/* Read/write block currently at given address */
void read_current_block (Block nnr, char * addr);
void write_current_block (Block nnr, char * addr);
/* Read/write block originally at given address */
void read_old_block (Block onr, char *addr);
void write_old_block (Block onr, char *addr);

/* Prototypes for fs-specific portions */
void read_tables (void);
void write_tables (void);
void salvage_free_zones (void);
void init_zone_maps (void);
void init_inode_bitmap (void);

#endif /* MISC_C */

/* Now for the prototypes for misc.c */

/* Volatile to let gcc know that this doesn't return. */
volatile void fatal_error ();
volatile void usage ();

#define die(str)	fatal_error("%s: " str "\n")
#define nomore()	fatal_error("%s: cannot continue.\n")

