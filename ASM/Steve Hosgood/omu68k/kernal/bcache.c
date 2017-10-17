/******************************************************************************
 *	Bcache.c	Buffer operations
 ******************************************************************************
 *
 *	Modded T.Barnaby 21/5/85
 *		Bytecp() and Byteclr(), functions used for copying and
 *		clearing buffers for speed.
 *		(These routines in assembler in bytecp.68k).
 */

# include       "../include/param.h"
# include       "../include/buf.h"
# include       "../include/dev.h"

struct buf bbuf[NBUF];		/* System buffers */
struct buf *b_first;		/* Pointer to first buffer */
int b_index;			/* Number of buffers in use */

/*
 * Getbuf - searches cache for a given buffer, if none, reads one.
 *		If mode is ALLBUF then the least used buffer is obtained.
 *		If mode is ONEBUF then the last used buffer is obtained
 *			(ONEBUF used mainly for EXEC).
 */
struct buf *
getbuf(mdev, mindev, block, mode)
struct dev *mdev;
{
	int (*stratfnc)();
	struct buf *b_ptr, *b_prev, *b_prev2;

	stratfnc = mdev->stratfnc;
	b_ptr = b_first;
	b_prev = 0;
	b_prev2 = 0;

	while (b_ptr){
		if (b_ptr->b_bno == block){
			/* accept block if joke blk, or correct device */
			if (block == -1 || (b_ptr->b_dev == mindev && b_ptr->b_strat == stratfnc)){
				/* found block! - link to start of list */
				if (b_prev){
					b_prev->b_next = b_ptr->b_next;
					b_ptr->b_next = b_first;
					b_first = b_ptr;
				}
				return b_ptr;
			}
		}

		/* try next one */
		b_prev2 = b_prev;
		b_prev = b_ptr;
		b_ptr = b_ptr->b_next;
	}

	/* not there - if free blocks exist, use one, else evict last block
	 * Unless in use last block mode, when use last used block
	 */
	if (b_index < NBUF)
		b_ptr = &bbuf[b_index++];
	else {
		/* Depending on mode evict last used block or least used block*/
		if(mode == ONEBUF){
			/* Evict last used block */
			b_ptr = b_first;
			b_prev = 0;
		}
		else{
			/* evict - write dirty block */
			b_ptr = b_prev;
			b_prev = b_prev2;
		}
		relbuf(b_ptr);
	}

	/* read in new data from disk */
	b_ptr->b_dev = mindev;
	b_ptr->b_strat = stratfnc;
	b_ptr->b_flags = 0;
	if ((b_ptr->b_bno = block) != -1)
		/* not a joke block, do a real read */
		(*b_ptr->b_strat)(b_ptr);
	else
		byteclr(b_ptr->b_buf,BSIZE);

	/* link to start of list */
	if (b_prev)
		b_prev->b_next = 0;

	/* Link in block if nesecary */
	if(b_ptr != b_first){
		b_ptr->b_next = b_first;
		b_first = b_ptr;
	}
	return b_ptr;
}

/*
 * Relbuf - frees a buffer in the cache. Writes buffer if dirty.
 */
relbuf(buf)
struct buf *buf;
{

	if (buf->b_flags & WRITE){
		if (buf->b_bno != -1)
			(*buf->b_strat)(buf);
		else
			/* joke block is caused by read on file with hole */
			panic("write of joke block?");
	}

	buf->b_flags = 0;
	return;
}

/*
 * Bflush - called by 'sync' to write changed buffers to disk.
 */
bflush()
{
	struct buf *b_ptr;

	b_ptr = b_first;
	while (b_ptr){
		relbuf(b_ptr);
		b_ptr = b_ptr->b_next;
	}

	return;
}
