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
 *		Returns pointer to least used buffer.
 *		If mode is ALLBUF then the buffer is placed at the top
 *			of the buffer list.
 *		If mode is ONEBUF then the order of the buffers remains
 *			unchanged (ONEBUF used mainly for EXEC).
 *		Does not realocate busy blocks.
 */
struct buf *
getbuf(mdev, mindev, block, mode)
struct dev *mdev;
{
	int	(*stratfnc)();
	struct buf	*bptr, *b_last;

	stratfnc = mdev->stratfnc;
	bptr = b_last = b_first;

	/* Scan buffer cache for required buffer, either returns or escapes
	 * with b_last pointing to last buffer or 0 if first allocation.
	 */
	while (bptr){
		if ((bptr->b_flags & B_INUSE) && (bptr->b_bno == block)){
			/* accept block if joke blk, or correct device */
			if (block == -1 || (bptr->b_dev == mindev && bptr->b_strat == stratfnc)){
				/* found block! - link to start of list */
				if (bptr->b_prev && (mode != ONEBUF)){
					/* Unlink from list */
					if(bptr->b_prev)
						bptr->b_prev->b_next = bptr->b_next;
					if(bptr->b_next)
						bptr->b_next->b_prev = bptr->b_prev;
					/* Link to start */
					bptr->b_next = b_first;
					bptr->b_prev = 0;
					b_first->b_prev = bptr;
					b_first = bptr;
				}
				return bptr;
			}
		}

		/* try next one */
		b_last = bptr;			/* Sets last block ptr */
		bptr = bptr->b_next;
	}


	/* not there - if free blocks exist, use one, else evict last block
	 * Link to start of list if in ALLBUF mode.
	 */
	if ( !(bptr = gfreebuf()) ){

		/* evict - write dirty block */
		bptr = b_last;

		/* Checks if this block is busy, if so work back till free one*/
		if(bptr->b_flags & B_BUSY){
			while((bptr = bptr->b_prev) && (bptr->b_flags & B_BUSY));
			if(bptr == b_first) panic("No non busy buffers\n");
		}
		relbuf(bptr);
	}

	 /* Sets first block if nesecary */
	if(!b_first) b_first = bptr;

	/* Sets up block for use */
	bptr->b_dev = mindev;
	bptr->b_strat = stratfnc;
	bptr->b_flags = B_INUSE;

	/* link to start of list if not in ONEBUF mode */
	if(mode == ONEBUF){
 		/* Links to end of list if required, first unlink from list */
		if(bptr != b_last){
			/* Sets first block pointer if nesecary */
			if((bptr == b_first) && bptr->b_next)
				b_first = bptr->b_next;

			/* Unlinks block from list */
			if(bptr->b_prev) bptr->b_prev->b_next = bptr->b_next;
			if(bptr->b_next) bptr->b_next->b_prev = bptr->b_prev;

			/* Link to end of list */
			b_last->b_next = bptr;
			bptr->b_prev = b_last;
			bptr->b_next = 0;
		}
	}
	else {
		/* Links block to start of list if required */
		if(bptr != b_first){
			/* Unlinks block from list */
			if(bptr->b_prev) bptr->b_prev->b_next = bptr->b_next;
			if(bptr->b_next) bptr->b_next->b_prev = bptr->b_prev;

			/* Link in block at head of list */
			bptr->b_next = b_first;
			b_first->b_prev = bptr;
			b_first = bptr;
			bptr->b_prev = 0;
		}
	}

	/* read in new data from disk */
	if ((bptr->b_bno = block) != -1)
		/* not a joke block, do a real read */
		(*bptr->b_strat)(bptr);
	else
		byteclr(bptr->b_buf,BSIZE);

	return bptr;
}

/*
 *	Gfreebuf()	Returns a free system buffer
 */
struct buf
*gfreebuf(){
	struct buf	*bptr;

	if (b_index < NBUF){
		return &bbuf[b_index++];
	}
	else{
		bptr =  b_first;
		while (bptr){
			if(bptr->b_flags == 0)
				return bptr;
			bptr = bptr->b_next;
		}
	}
	return 0;
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
	buf->b_flags &= ~WRITE;

	if(buf->b_flags & B_BUSY){
		/* joke block is caused by read on file with hole */
		panic("write of busy block?");
	}

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

/*
 * Bflush_all - called by 'sync' to write all buffers on umounted
 *	File stores to disk to disk.
 */
bflush_all()
{
	struct buf *b_ptr;

	b_ptr = b_first;
	while (b_ptr){
		if(!(b_ptr->b_flags & B_BUSY))
			rmbuf(b_ptr);
		b_ptr = b_ptr->b_next;
	}

	return;
}

/*
 * Rmbuf - Removes Completely a buffer in the cache. Writes buffer if dirty.
 */
rmbuf(buf)
struct buf	*buf;
{
	/* First release buffer and write if nesecary */
	relbuf(buf);
	buf->b_flags = 0;

	return;
}
