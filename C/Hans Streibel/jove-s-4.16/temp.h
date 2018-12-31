/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

/*
   The tmp file stores lines of text for JOVE buffers as contiguous
   sequences of chars, terminated by NUL.  New lines are added to
   the end of the tmp file.  The file is not garbage collected
   because that would be too painful.  As a result, commands like
   Yank and Kill are really easy; basically all we do is make copies
   of the disk addresses of the lines (as opposed to the contents).
   So, putline(char *buf) writes buf to the disk and returns a new
   disk address.  getline(daddr addr, char *buf) is the opposite of
   putline().  f_getputl(LinePtr line, File fp) reads from open fp
   directly into the tmp file (into the buffer cache (see below))
   and stores the address in line.  This is used during read_file to
   minimize copying.

   To reduce the size of a tmp file disk address, each disk address
   is limited to point to positions that are the start of a chunk.
   A chunk has exactly CHNK_CHARS characters, so that an disk
   address can be reduced by log2(CHNK_CHARS) bits.  These extra
   bits allow for a larger tmp file.  This is exploited on machines
   where the disk address is stored in a 16-bit type (for other
   machines, a chunk is simply one character).  Using chunks wastes
   some tmp file space since lines must be aligned on CHNK_CHARS
   boundaries.

   The tmp file is accessed by blocks of size JBLKSIZE (typically
   512 bytes or larger).  Lines do NOT cross block bounderies in the
   tmp file so that accessing the contents of lines can be much
   faster.  Pointers into the interior of disk buffers are returned
   instead of copying the contents into local arrays and then using
   them.  This cuts down on the amount of copying a great deal, at
   the expense of space efficiency.

   The high bit of each disk address is used for marking the line as
   needing redisplay (DIRTY).  In theory, this has nothing to do
   with a disk address, but it is the cheapest place to hide a bit
   in struct line (this is important since instances of this struct
   are the major consumer of memory).

   The type daddr is used to represent the disk address of a line.
   It is an integer containing three packed fields: the dirty bit,
   the block number (within the tmp file), and the chunk number
   (within the block).  Many of the following definitions are for
   packing and unpacking daddr values.

   There is a buffer cache of NBUF buffers (64 on !SMALL machines and the
   3 on small ones).  The blocks are stored in LRU order and each block
   is also stored in a hash table by block #.  When a block is requested
   it can quickly be looked up in the hash table.  If it's not there the
   LRU block is assigned the new block #.  If it finds that the LRU block
   is dirty (i.e., has pending IO) it syncs the WHOLE tmp file, i.e.,
   does all the pending writes.  This works much better on floppy disk
   systems, like the IBM PC, if the blocks are sorted before sync'ing. */

/* select chunk size by specifiying its log2 */

#ifdef SMALL
# define LG_CHNK_CHARS		4	/* save bits in daddr at cost of space in tempfile */
#else
# define LG_CHNK_CHARS		0
#endif

/* MAX_BLOCKS is the number of distinct block numbers that
 * can be represented in a daddr (a power of two!).
 * In fact, we don't allow block number MAX_BLOCKS-1 to be
 * used because NOWHERE_DADDR and NOTYET_DADDR must not
 * be valid disk references, and we want to prevent space overflow
 * from being undetected through arithmetic overflow.
 *
 * MAX_BLOCKS is based on the number of bits remaining in daddr to
 * represent it, after space for the offset (in chunks) and the
 * DDIRTY bit is accounted for.
 */
#define MAX_BLOCKS		((daddr) 1 << (sizeof(daddr)*CHAR_BITS - JLGBUFSIZ + LG_CHNK_CHARS - 1))

/* CHNK_CHARS is how big each chunk is.  For each 1 the DFree pointer
   is incremented we extend the tmp file by CHNK_CHARS characters.
   BLK_CHNKS is the # of chunks per block.

   NOTE:  It's pretty important that these numbers be powers of 2.
	  Be careful if you change things. */

#define CHNK_CHARS		((daddr)1 << LG_CHNK_CHARS)
#define REQ_CHNKS(chars)	(((daddr)(chars) + (CHNK_CHARS - 1)) >> LG_CHNK_CHARS)
#define BLK_CHNKS		((daddr)JBUFSIZ / CHNK_CHARS)
#define blk_chop(addr)		((daddr)(addr) & ~(BLK_CHNKS - 1))
#define da_to_bno(addr)		(((daddr)(addr) >> (JLGBUFSIZ - LG_CHNK_CHARS)) & (MAX_BLOCKS - 1))
#define da_to_off(addr)		(((daddr)(addr) << LG_CHNK_CHARS) & ((daddr)JBUFSIZ - 1))
