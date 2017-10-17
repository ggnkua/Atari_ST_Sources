/******************************************************************************
 *	Sort.c		Sorts the freelist into ascending order
 ******************************************************************************
 */

# define        NICFREE         50
# define        NICINOD         100
# define	TBLOCKS		1440

# include       <sys/types.h>
# include       "../include/inode.h"
# include       "../include/filsys.h"
# include       "../include/buf.h"
# include       "../include/fblk.h"
# include       "../include/dev.h"
# include       "../include/ino.h"

# define        SUPERB          1

/*
 * Sortfree - Sorts the freelist on the given device into ascending order
 *           Note Max number of blocks is defined by TBLOCKS (1440)
 * Uses
 *	setblk()	Sets a bit in the bit map
 *	getnext()	Gets the next block in bit map (ascending order)
 *	getbuf()	Gets a buffer from disk
 *	sync()		Writes out modifed freelist
 */

sortfree(mdev, min_dev)
struct dev *mdev;
{
	long fb, count;
	struct buf *s_buf, *fb_buf;	/* Disk buffer pointers */
	struct filsys *s_blk;		/* Super block pointer */
	struct fblk *fb_ptr;		/* Free block list pointer */

	char freelist[(TBLOCKS/8)+1];	/* Free list bit map */
	int total, number, last;

	total = fb = 0;			/* Total is number of free blocks */

	/* Clears freelist bit map */
	for(number=0; number<((TBLOCKS/8)+1); number++) freelist[number]=0;

	/* obtain superblock for this volume */
	s_buf = getbuf(mdev, min_dev, SUPERB, ONEBUF);
	s_blk = ( struct filsys * ) s_buf->b_buf;

	/* Puts all of free list including secondary block into bit map */
	if (s_blk->s_nfree){
		for(count=s_blk->s_nfree-1; count>=0; count--){
			setblk(freelist,s_blk->s_free[count]);
			total++;
		}
	}
	else{
		printf("SORTFREE: No free blocks\n\r");
		return;
	}

	/* Goes through each indirect freelist block in turn */
	if(fb = s_blk->s_free[0]){
		fb_buf = getbuf(mdev, min_dev, fb, ONEBUF);
		fb_ptr = ( struct fblk * ) fb_buf->b_buf;
		while(1){
			if(!fb_ptr->df_nfree) break; /* If none free break */
			for(count=fb_ptr->df_nfree-1; count>=0; count--){
				setblk(freelist,fb_ptr->df_free[count]);
				total++;
			}
			/* Checks if last block in list if not gets next */
			if(fb = fb_ptr->df_free[0]){
				fb_buf = getbuf(mdev, min_dev, fb, ONEBUF);
				fb_ptr = ( struct fblk * ) fb_buf->b_buf;
			}
			else break;

		}
	}
	total--;	/* Ignore 00 pointer last block */

#ifdef TSORT
prfree(freelist,total);
getchar();
#endif

	last =0;		/* Sets for first block in bit map */

	/* obtain superblock for this volume */
	s_buf = getbuf(mdev, min_dev, SUPERB, ONEBUF);
	s_blk = ( struct filsys * ) s_buf->b_buf;

	/* Works out how many blocks will be left to fill super block */
	number = total-((total/50)*50)+1;	/* Plus one for last 0 block */

	/* Saves left overs (50 per block) in super block */
	for(count=number-1; count>0; count--){
		s_blk->s_free[count]=last= getnext(freelist,last);
	}
	s_blk->s_nfree=number;

	/* Checks if no more free blocks */
	if(getnext(freelist,last)== -1){
		s_blk->s_free[0]=0;
	}
	else{
		s_blk->s_free[0]=last=getnext(freelist,last);
	}
	s_buf->b_flags |= WRITE;	/* Sets buffer to write super block */

	/* Put free blocks list into blocks untill end of freelist */
	if(fb = s_blk->s_free[0]){
		fb_buf = getbuf(mdev, min_dev, fb, ONEBUF);
		fb_ptr = ( struct fblk * ) fb_buf->b_buf;
		while(1){
			number=NICFREE;
			/* Puts first NICFREE into freelist */
			for(count=number-1; count>0; count--){
			     fb_ptr->df_free[count]=last=getnext(freelist,last);
			}
			fb_ptr->df_nfree=number;

			/* Checks if end of free list if so ends */
			if(getnext(freelist,last)== -1){
				fb_ptr->df_free[0]=0;
				fb_buf->b_flags |= WRITE;
				break;
			}
			/* Else sets pointer to next block and gets next block*/
			else{
			      fb=fb_ptr->df_free[0]=last=getnext(freelist,last);
			
			}
			fb_buf->b_flags |= WRITE;
			fb_buf = getbuf(mdev, min_dev, fb, ONEBUF);
			fb_ptr = ( struct fblk * ) fb_buf->b_buf;
		}
	}
	sync();		/* Writes all blocks not yet written */
	return 0;
}
/*
 *	Setblk -	Sets a bit representing the block number given
 *			into the freelist bit map given.
 */
setblk(freelist,block)
char freelist[];
short block;
{
	char *pos;
	char bit;

	pos = freelist + (block>>3);	/* Block number divided by 8 (char ) */
	bit = 0x01<<(block&0x7);	/* Bits number from remainder */
	*pos |= bit;
}
/*
 *	Getblk -	Tests if block number given is in bit map
 *			Zero returen if not, bit mask if it is.
 */
getblk(freelist,block)
char freelist[];
short block;
{
	char *pos;
	char bit;

	pos = freelist + (block>>3);	/* Block number divided by 8 (char ) */
	bit = 0x01<<(block&0x7);	/* Bits number from remainder */
	return (*pos & bit);
}
/*
 *	Getnext -	Gets the next block available in the bit map
 *			(Ascending order) returning the block number.
 *			Note should be given the last block number found.
 *			Returns -1 if end of list.
 */
getnext(freelist,last)
char freelist[];
short last;
{
	while(++last<TBLOCKS){
		if(getblk(freelist,last)) return last;
	}
	return -1;
}

#ifdef TSORT
prfree(freelist,total);
char freelist[];
int total;
{
	int last,c;

	last=0;
	printf("Free list number %d\n\r",total);
	while(1){
		for(c=0; c<20; c++){
			if((last=getnext(freelist,last))== -1) return;
			printf("%d	%x\n\r",last,last);
			if(getnext(freelist,last)== -1) return;
		}
		getchar();
	}
}
#endif

/*
 *	Sort	Sorts the freelist on the given device
 */
sortf(argc,argv)
char *argv[];
int argc;
{
	if(argc != 3){
		printk("Usage:	Device major, Device minor\n");
		return -1;
	}
	sortfree(&bdevsw[atoi(argv[1])],atoi(argv[2]));
	return 0;
}

