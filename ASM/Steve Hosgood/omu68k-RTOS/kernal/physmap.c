/******************************************************************************
 *	Physblock.c	Performs logical to physical block conversions
 ******************************************************************************
 *
 *	Modded T.Barnaby 17/5/85
 *		Added double and triple indirection of block list
 */

/*
 * Perform mapping from logical file concepts to physical blocks.
 */

# include	"../include/param.h"
# include       "../include/buf.h"
# include       "../include/inode.h"

# define        B_READ          1
# define        B_WRITE         2

/* # define	TMULTI		1*/	/* Test printing */

/*
 * Physblk - returns physical block given logical blk no. and inode ptr.
 *              if writing, and new block reqd, get one from free list.
 *		returns 0 if unavailable
 */
physblk(n, i_ptr, mode)
int n;
struct inode *i_ptr;
{
	int rblk, d, i, ii, iii, numi;

	i = ii = iii = -1;

	/* find how much indirection will be reqd */
	if (n < 10)
		/* direct access */
		d = n;
	else if (n < 10+128){
		/* single indirect access */
		d = 10;
		i = n-10;
	}
	else if (n < 10+128+16384){
		/* multiple indirect not allowed (yet), oh yes it is! TB */

#ifdef TMULTI
printf("Block %d Now its getting bigger\n", n);
#endif
		d = 11;
		numi = n-10-128;
		i = numi>>7;  /* Number of 128 indirections most significant */
		ii= numi-(i<<7);	/* least significant pointer */
	}
	else if (n < 10+128+16384+2097152){
		/* WOW what a big number, ps I'm getting pissed */

#ifdef TMULTI
printf("Block %d Now its getting enormous\n", n);
#endif
		d = 12;
		numi = n-10-128-16384;
		i = numi>>21; /* Number of 16384 most significant indirections*/
		ii= (numi-(i<<21))>>14;		/* Middle 128 indirections */
		iii = (numi-(ii<<14)-(i<<21))>>7; /* Least significant indir. */
	}

	if ((rblk = i_ptr->i_addr[d]) == 0 && mode == B_WRITE){
		i_ptr->i_addr[d] = rblk = getfree(i_ptr->i_mdev, i_ptr->i_minor);
		i_ptr->i_flag |= ICHG;
	}

	/* check if indirection reqd */
	if (rblk && i >= 0){
		rblk = scan_indir(rblk, i, i_ptr, mode);

	/* Drinking definitly helps programming TB This bit actualy worked */

		if (rblk && ii >= 0){
			rblk = scan_indir(rblk, ii, i_ptr, mode);

			if (rblk && iii >= 0){
				rblk = scan_indir(rblk, iii, i_ptr, mode);
			}
		}
	}
	return rblk;
}

/*
 * Scan_indir - returns block number at position 'n' in indirect block 'blk'.
 */
scan_indir(blk, n, i_ptr, mode)
int blk, n;
struct inode *i_ptr;
{
	int rblk;
	struct buf *b_ptr;
	struct indir *ind_ptr;

	/* get indirect block */
	b_ptr = getbuf(i_ptr->i_mdev, i_ptr->i_minor, blk, ALLBUF);
	ind_ptr = (struct indir *)b_ptr->b_buf;

	/* obtain element 'n' - create block if reqd */
	if ((rblk = ind_ptr[n].ind_addr) == 0 && mode == B_WRITE){
		rblk = ind_ptr[n].ind_addr = getfree(i_ptr->i_mdev, i_ptr->i_minor);
		b_ptr->b_flags |= WRITE;
	}

	return rblk;
}

/*
 * Itrunc - clears an inode, releasing all blocks.
 */
itrunc(iptr)
struct inode *iptr;
{
	int count, fb;

	/* Third indirect block */
	if (fb = iptr->i_addr[12]){
		clr_3_indir(iptr->i_mdev, iptr->i_minor, fb);
		iptr->i_addr[12] = 0;
	}

	/* Second indirect block */
	if (fb = iptr->i_addr[11]){
		clr_2_indir(iptr->i_mdev, iptr->i_minor, fb);
		iptr->i_addr[11] = 0;
	}

	/* first indirect block.. */
	if (fb = iptr->i_addr[10]){
		clr_1_indir(iptr->i_mdev, iptr->i_minor, fb);
		iptr->i_addr[10] = 0;
	}

	for (count = 9; count >= 0; count--){
		if (fb = iptr->i_addr[count]){
			makefree(iptr->i_mdev, iptr->i_minor, fb);
			iptr->i_addr[count] = 0;
		}
	}

	iptr->i_size = 0;
	iptr->i_flag |= ICHG;

	return;
}

/*
 * Clr_1_indir - clears a first level indirect block.
 */
clr_1_indir(mdev, mindev, blk)
struct dev *mdev;
{
	int count, fb;
	struct indir *ind_ptr;
	struct buf *b_ptr;

	/* get the indirect block */
	b_ptr = getbuf(mdev, mindev, blk, ALLBUF);
	b_ptr->b_flags |= B_BUSY;		/* Mark buffer as busy */
	ind_ptr = ((struct indir *)b_ptr->b_buf) + 127;

	/* now release all blocks pointed-to */
	for (count = 127; count >= 0; count--){
		if (fb = ind_ptr->ind_addr)
			makefree(mdev, mindev, fb);

		ind_ptr--;
	}

	b_ptr->b_flags &= ~B_BUSY;	/* No longer busy */

	/* and free indirect block itself */
	makefree(mdev, mindev, blk);

	return;
}

/*
 * Clr_2_indir - clears a first level indirect block.
 */
clr_2_indir(mdev, mindev, blk)
struct dev *mdev;
{
	int count, fb;
	struct indir *ind_ptr;
	struct buf *b_ptr;

	/* get the indirect block */
	b_ptr = getbuf(mdev, mindev, blk, ALLBUF);
	b_ptr->b_flags |= B_BUSY;		/* Mark buffer as busy */
	ind_ptr = ((struct indir *)b_ptr->b_buf) + 127;

	/* now release all blocks pointed-to */
	for (count = 127; count >= 0; count--){
		if (fb = ind_ptr->ind_addr){
			clr_1_indir(mdev, mindev, fb);
		}

		ind_ptr--;
	}

	b_ptr->b_flags &= ~B_BUSY;	/* No longer busy */

	/* and free indirect block itself */
	makefree(mdev, mindev, blk);

	return;
}

clr_3_indir(mdev, mindev, blk)
struct dev *mdev;
{
	int count, fb;
	struct indir *ind_ptr;
	struct buf *b_ptr;

	/* get the indirect block */
	b_ptr = getbuf(mdev, mindev, blk, ALLBUF);
	b_ptr->b_flags |= B_BUSY;		/* Mark buffer as busy */
	ind_ptr = ((struct indir *)b_ptr->b_buf) + 127;

	/* now release all blocks pointed-to */
	for (count = 127; count >= 0; count--){
		if (fb = ind_ptr->ind_addr){
			clr_2_indir(mdev, mindev, fb);
		}

		ind_ptr--;
	}

	b_ptr->b_flags &= ~B_BUSY;	/* No longer busy */

	/* and free indirect block itself */
	makefree(mdev, mindev, blk);

	return;
}
