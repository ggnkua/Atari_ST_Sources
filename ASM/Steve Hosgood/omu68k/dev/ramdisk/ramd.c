/******************************************************************************
 *	Ramd.c	Ramdisk device driver
 ******************************************************************************
 *
 *	Ramdisk driver software:
 *		rdopen(), rdclose(), and rdstrat().
 *
 *	Gets memory from memory segments using getmem(), endmem()
 *		memstart(), memend().
 *	
 */

# include	"../../include/param.h"
# include	"ramd.h"
# include       <sys/filsys.h>
# include	<sys/dir.h>
# include       <sys/fblk.h>
# include	<sys/ino.h>
# include	"../../include/signal.h"
# include	"../../include/procs.h"
# include       "../../include/inode.h"
# include       "../../include/buf.h"
# include       "../../include/dev.h"
# include	"../../include/memory.h"

struct ramdisk ramd;			/* Ram area definitions */

/******************************************************************************
 *	Rdopen		Sets up filestore in RAMDISK memory area
 ******************************************************************************
 *
 *
 *	Rdopen will create a file store in the memory area defined
 *		in the memory segment structure, with a spec as
 *		defined in ramd.h ( ie number of inodes per block etc )
 */

rdopen(dminor)
short dminor;
{
	struct buf buf;
	struct filsys *super;
	struct fblk *freeb;
	struct dinode *inode;
	struct direct *dir;
	int block, bleft, nextb;
	int number, count, seg;

	/* If already open leave well alone */
	if(ramd.nopen++) return 0;

	/* Get memory for use */
	if((seg = getmem(RAMDISKSEG,0)) == -1){
		ramd.nopen = 0;
		return -1;
	}

	ramd.seg = seg;			/* Memory segment number */

	/* Sets up basic RAMdisk areas */
	ramd.start = (long)memstart(RAMDISKSEG, seg);
	ramd.nblocks = (memend(RAMDISKSEG, seg) -
		memstart(RAMDISKSEG, seg))/BSIZE;
	if(ramd.nblocks< (2 + RD_NINODBK + NICFREE)){
		ramd.nopen = 0;
		endmem(RAMDISKSEG, seg);
		return -1;
	}

	/* No blocks in free list, note 1 block for root directory */
	bleft = ramd.nblocks - (2+RD_NINODBK+1);

 	/* Clears RAM disk area */
	byteclr(ramd.start, ramd.nblocks * BSIZE);

	/* Clears super block and sets up parameters */
	byteclr(buf.b_buf,BSIZE);
	super = (struct filsys *)buf.b_buf;

	super->s_isize = RD_NINODBK + 2;
	super->s_fsize = ramd.nblocks;
	super->s_flock = 0;
	super->s_fmod  = 0;
	super->s_ronly = 0;
	super->s_time  = 0;
	super->s_tfree = bleft;
	super->s_tinode = (RD_NINODBK*8)-2;	/* Tempary */

	/* Sets up inode list all free except 1 and 2 */
/*	This has been commented out as the Codata doesn't do it
 *	so niether shall I.
 *
 *	for(block = 0; block<NICINOD; block++){
 *		super->s_inode[block] = block+3;
 *	}
 *	super->s_ninode = NICINOD;
 */

	/* Sets up freelist in super->block */

	/* First free block */
	block = 2+RD_NINODBK+1;

	/* Increment bleft to work out how many block entries to insert
	 * last block is 0 terminating block
	 */
	bleft++;

	/* Works out how many blocks will be left to fill super block */
	number = (bleft % 50);

	/* Saves left overs (50 per block) in super block */
	for(count = number-1; count > 0; count--){
		if(bleft > 0) super->s_free[count] = block++;
		else super->s_free[count] = 0;
		bleft--;
	}
	super->s_nfree = number;

	/* Checks if no more free blocks */
	if(bleft <= 1){
		super->s_free[0] = 0;
		bleft--;
	}
	else{
		super->s_free[0] = block++;
		bleft--;
	}
	nextb = super->s_free[0];		/* Sets up next block pointer */

	/* Writes super block to RAM area */
	buf.b_bno = SUPERB;
	buf.b_dev = 0;
	buf.b_flags = WRITE;
	rdstrat(&buf);

	/* Put free blocks list into blocks untill end of freelist */
	freeb = (struct fblk *)buf.b_buf;
	while(bleft > 0){
		byteclr(buf.b_buf,BSIZE);

		/* Puts first NICFREE into freelist */
		for(count = NICFREE-1; count > 0; count--){
			if(bleft > 0) freeb->df_free[count] = block++;
			else freeb->df_free[count] = 0;
			bleft--;
		}
		freeb->df_nfree = NICFREE;

		if(bleft <= 1){
			freeb->df_free[0] = 0;
			bleft--;
		}
		else {
			freeb->df_free[0] = block++;
			bleft--;
		}

		/* Writes this free block to RAM area */
		buf.b_bno = nextb;
		buf.b_flags = WRITE;
		buf.b_dev = 0;
		rdstrat(&buf);

		/* Sets next block in free list */
		nextb = freeb->df_free[0];
	}
	
	/* Write root inode */
	byteclr(buf.b_buf,BSIZE);	/* Clear area */

	inode = (struct dinode *)buf.b_buf;
	inode->di_mode = 0x8000;
	inode->di_atime = inode->di_mtime = inode->di_ctime = time(0);
	inode++;
	inode->di_mode = 0x41FF;
	inode->di_nlink = 2;
	inode->di_uid = cur_proc->euid;
	inode->di_gid = cur_proc->egid;
	inode->di_size = 2 * sizeof(struct direct);
	block = RD_NINODBK + 2;
	inode->di_addr[0] = block>>16;
	inode->di_addr[1] = (block>>8)&0xFF;
	inode->di_addr[2] = (block)&0xFF;
	inode->di_atime = inode->di_mtime = inode->di_ctime = time(0);

	/* Write inode block */
	buf.b_bno = 2;
	buf.b_flags = WRITE;
	buf.b_dev = 0;
	rdstrat(&buf);

	/* Write root directory */
	byteclr(buf.b_buf,BSIZE);

	dir = (struct direct *)buf.b_buf;
	dir->d_ino = 2;
	strcpy(dir->d_name,".");
	dir++;
	dir->d_ino = 2;
	strcpy(dir->d_name,"..");

	buf.b_bno = RD_NINODBK + 2;
	buf.b_flags = WRITE;
	buf.b_dev = 0;
	rdstrat(&buf);

	return 0;
}


/******************************************************************************
 *	Rdclose	-	Closes Ramdisk if not opened by someone else
 ******************************************************************************
 */
rdclose(dminor)
short dminor;
{
	/* Closes device if completely closed */
	if(--ramd.nopen > 0) return 0;
	if(ramd.nopen < 0){
		ramd.nopen = 0;
		return -1;
	}
	ramd.nblocks = 0;

	/* Realeses memory segment */
	endmem(RAMDISKSEG, ramd.seg);

	return 0;
}

/******************************************************************************
 *	Rdstrat	-	Strategy for Ramdisk read and write block
 ******************************************************************************
 */
rdstrat(buf)
struct buf *buf;
{
	/* Check if block within device */
	if((buf->b_bno<0) || (buf->b_bno>= ramd.nblocks)){
		buf->b_flags = ABORT;
		return -1;
	}

	/* Check if correct device 0 */
	if(buf->b_dev){
		buf->b_flags = ABORT;
		return -1;
	}

	/* Check if write if so write data to correct block */
	if(buf->b_flags == WRITE){
		bytecp(buf->b_buf,(ramd.start+(buf->b_bno<<BSHIFT)),BSIZE);
		buf->b_flags = 0;
	}
	/* Else read data */
	else{
		bytecp((ramd.start+(buf->b_bno<<BSHIFT)),buf->b_buf,BSIZE);
		buf->b_flags = 0;
	}
	return 0;
}
