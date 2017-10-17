/******************************************************************************
 *	Swap.c		Process swaper bits
 ******************************************************************************
 */

# include	"../include/param.h"
# include	<a.out.h>
# include	"../include/inode.h"
# include	"../include/signal.h"
# include	"../include/procs.h"
# include	"../include/memory.h"
# include	"../include/swap.h"
# include	<errno.h>
# include	"../include/stat.h"
# include	<sys/dir.h>
# include	"../include/file.h"
# include	"../include/state.h"

/*
 *	Swapspace definitions
 */

int	swapupseg();
struct	Swapspace swapspace[NSWAPS];

/******************************************************************************
 *	Swapout		Swaps given proccess out of core
 ******************************************************************************
 */
swapout(proc)
struct procs *proc;
{
#ifdef TSWAP
printf("SWAPOUT swaping %s\n\r",proc->name);
#endif
	return swappout(proc, SPROC);
}

/******************************************************************************
 *	Stickout	Swaps given proccess out of core
 ******************************************************************************
 */
stickout(proc)
struct procs *proc;
{
#ifdef TSWAP
printf("SWAPOUT swaping sticky %s\n\r",proc->name);
#endif

	return swappout(proc, SSTICK);
}

/******************************************************************************
 *	Swappout		Swaps given proccess out of core
 ******************************************************************************
 */
swappout(proc, type)
struct procs *proc;
int	type;
{
	unsigned long	datastart;
	unsigned long	tsize, dsize, ssize;
	int	swapno, tswapno, segno;
	struct	Swapspace *swap, *tswap;

		
#ifdef TSWAP
printf("Swap out %s %d\n",proc->name,proc->pid);
psize(proc);
pswap();
#endif
	/*
	 *	Gets a swap-space table entry
	 */
	swap = swapspace;
	for(swapno = 0; swapno < NSWAPS; swapno++){
		if(!swap->pid) break;
		swap++;
	}
	if(swapno == NSWAPS){
		printf("SWAPOUT: no swapspace table entries left\n\r");
		pswap();
		return -1;
	}

	/* Indicate swap table entry being created */
	swap->pid = SWAPCREATE;
	swap->textseg = SWAPDISK;
	swap->dataseg = SWAPDISK;

	/* Initialy no sizes for text or data */
	swap->psize.tsize = 0;
	swap->psize.dsize = 0;
	swap->psize.bsize = 0;
	swap->psize.stacks = 0;

	/* Work out program segment sizes */
	tsize = proc->psize.tsize;
	if(proc->psize.fmagic == NMAGIC){
		datastart = ((proc->psize.entry + proc->psize.tsize) & MMUMASK) + MMUBOUND;
	}
	else{
		datastart = proc->psize.entry + proc->psize.tsize;
	}

	/* Get data area and stack size only if normal process */
	dsize = proc->psize.ebss - datastart;
	if(type != SSTICK) ssize = proc->psize.ustack - getusp();
	else ssize = 0;


#ifdef TSWAP
printf("usr sp %x\n",getusp());
printf("Swap out tsize %x, dsize %x ssize %x\n",tsize,dsize,ssize);
#endif

	/* Checks if text area exists in swap space */
	if((segno = swapcheck(&proc->object, STEXT)) == -1){

		/* Get a free area if none return -1 */
		if((segno = getsarea(tsize, (type | STEXT))) == -1){
			swap->pid = 0;
			return -1;
		}
#ifdef TSWAP
printf("SWAPOUT: copying text segment %x\n",tsize);
printf("From %x to %x\n",proc->psize.entry,segarea[segno].start);
#endif
		/* Checks if getsarea returned a flag indicating that
		 * The area is on disk, if not area is in swap space
		 * So copy text segment there.
		 */
		if(segno != SWAPDISK){
			bytecp(proc->psize.entry,memstart(SWAPSEG,segno),tsize);

			/* Checks if any processes exist with the same text area
		 	* with the text area on disk, if so set its text pointer
		 	* to this new swap space segment
		 	*/
			tswap = &swapspace[0];
			for(tswapno = 0; tswapno < NSWAPS; tswapno++){
				/* If process with the same ID exists and using
			 	* disk for text segment set text segment to new
			 	* one created.
			 	*/
				if((tswap != swap) && (tswap->pid) &&
					(tswap->textseg == SWAPDISK) &&
					(tswap->object.majdev == proc->object.majdev) &&
					(tswap->object.mindev == proc->object.mindev) &&
					(tswap->object.inode == proc->object.inode)){
					tswap->textseg = segno;
					relockmem(SWAPSEG, segno);
				}
				tswap++;
			}
		}
	}
	else {
		relockmem(SWAPSEG, segno);
	}

	/* Set up text segment number and size */
	swap->textseg = segno;
	swap->psize.tsize = tsize;

	/* At this stage the context of the process will be saved so no
	 * User action can now take place and so the process can be assumed
	 * to be out of core. (All gone ...)
	 */
	if(type != SSTICK) proc->flag &= ~SLOAD;

	/* Does data segment */
	/* Get a free area if none return -1 */
	if((segno = getsarea((dsize + ssize), (type | SDATA))) == -1){
		if(swap->textseg != SWAPDISK) endmem(SWAPSEG,swap->textseg);
		swap->pid = 0;
		return -1;
	}

#ifdef TSWAP
printf("SWAPOUT: copying data segment %x, %x, %x\n",dsize,ssize,dsize+ssize);
printf("From %x to %x\n",datastart,segarea[segno].start);
printf("From %x to %x\n",getusp(),segarea[segno].start+dsize);
#endif

	bytecp(datastart, memstart(SWAPSEG,segno), dsize);
	bytecp(getusp(), (memstart(SWAPSEG,segno) + dsize), ssize);

	/* Set up data segment number */
	swap->dataseg = segno;

	/* Copies object description and process size info to swap table */
	bytecp(&proc->object, &swap->object, sizeof(struct Object));
	bytecp(&proc->psize, &swap->psize, sizeof(struct Psize));
	swap->psize.stacks = ssize;
	strcpy(swap->name, proc->name);

	/* Set up swap table entry */
	if(type == SPROC) swap->pid = proc->pid;
	else swap->pid = SWAPSTICK;

#ifdef TSWAP
tidyseg();
pswap();
printf("SWAPOUT: returning\n");
#endif
	return 0;
}

/******************************************************************************
 *	Inswap		Checks if named proccess is in swap space
 ******************************************************************************
 */
inswap(object, psize)
struct Object *object;
struct Psize *psize;
{
	short	swapno;
	struct	Swapspace *swap;

#ifdef	TSWAP
printf("INSWAP: Checking if in swap\n");
#endif

	swap = &swapspace[0];
	for(swapno=0; swapno <NSWAPS; swapno++){
		/* If sticky process with the same ID exists break out */
		if((swap->pid == SWAPSTICK) &&
			(swap->object.majdev == object->majdev) &&
			(swap->object.mindev == object->mindev) &&
			(swap->object.inode == object->inode)) break;
			
		swap++;
	}
	if(swapno >= NSWAPS) return -1;
	bytecp(&swap->psize, psize, sizeof(struct Psize));
	return swapno;
}

/******************************************************************************
 *	Swapin		Swaps given proccess back into core
 ******************************************************************************
 */
swapin(proc)
struct procs *proc;
{
	short	swapno;
	struct	Swapspace *swap;

#ifdef TSWAP
printf("Swapin process %d, %s\n",proc->pid,proc->name);
psize(proc);
pswap();
#endif
	swap = &swapspace[0];
	for(swapno=0; swapno <NSWAPS; swapno++){
		if(swap->pid == proc->pid) break;
		swap++;
	}
	if(swapno >= NSWAPS){
		printf("Cannot swapin proccess not in swap table %d\n",proc->pid);
		pswap();
		return -1;
	}
	swapino(swapno);

	/* Process is now in core */
	proc->flag |= SLOAD;
	return 0;
}

/******************************************************************************
 *	Stickin		Swaps given sticky entry back into core
 ******************************************************************************
 */
stickin(object)
struct	Object *object;
{
	short	swapno;
	struct	Swapspace *swap;

#ifdef TSWAP
printf("Stickin Object\n");
pswap();
#endif
	swap = &swapspace[0];
	for(swapno=0; swapno <NSWAPS; swapno++){
		/* If sticky process with the same ID exists break out */
		if((swap->pid == SWAPSTICK) &&
			(swap->object.majdev == object->majdev) &&
			(swap->object.mindev == object->mindev) &&
			(swap->object.inode == object->inode)) break;
			
		swap++;
	}
	if(swapno >= NSWAPS) return -1;
	return swapino(swapno);
}

/******************************************************************************
 *	Swapino		Swaps given swap entry back into core
 ******************************************************************************
 */
swapino(swapno)
short swapno;
{
	unsigned long	tsize, datastart, dsize;
	struct	Swapspace *swap;


	swap = &swapspace[swapno];

#ifdef TSWAP
printf("Swap in %s\n",swap->name);
pswap();
#endif

	if(swap->psize.fmagic == NMAGIC){
		datastart = ((swap->psize.entry + swap->psize.tsize) & MMUMASK) + MMUBOUND;
	}
	else{
		datastart = swap->psize.entry + swap->psize.tsize;
	}
	dsize = swap->psize.dsize + swap->psize.bsize;
	tsize = swap->psize.tsize;


#ifdef TSWAP
printf("Sizes %x %x %x\n",tsize, dsize, swap->psize.stacks);
pswap();
#endif

	/* Get text area back into core */
	if(swap->textseg == SWAPDISK) gettext(swap);
	else bytecp(memstart(SWAPSEG, swap->textseg), swap->psize.entry, tsize);

	/* Get data area from swap space into core */
	bytecp(memstart(SWAPSEG, swap->dataseg), datastart, dsize);
	bytecp((memstart(SWAPSEG, swap->dataseg) + dsize),
		swap->psize.ustack - swap->psize.stacks, swap->psize.stacks);

#ifdef TSWAP
printf("SWAPIN: swaped in \n");
#endif

	if(swap->pid != SWAPSTICK){
		swap->pid = 0;
		if(swap->textseg != SWAPDISK) endmem(SWAPSEG, swap->textseg);
		if(swap->dataseg != SWAPDISK) endmem(SWAPSEG, swap->dataseg);
	}

#ifdef TSWAP
pswap();
#endif
	return 0;
}

/*
 *	Gettext	-	Gets Object named text segment from disk into core.
 */
gettext(swap)
struct	Swapspace *swap;
{
	struct	file file;
	struct	inode *iptr;

	if(iptr = getiptr(swap->object.majdev, swap->object.mindev,
		swap->object.inode)){

		/* Open file */
		if(f_open(&file, relock(iptr), READABLE) == -1){
			freeiptr(iptr);
			return -1;
		}

		f_seek(&file, sizeof(struct bhdr), 0);
	
		/* Read in text segment */
		if(f_read(&file, swap->psize.entry, swap->psize.tsize) != 
			swap->psize.tsize){
			/* read error */
			f_close(&file);
			freeiptr(iptr);
			return -1;
		}
		f_close(&file);
		freeiptr(iptr);
		return 0;
	}
	else return -1;
}

/* Swap table status enquiry */
s_status(no,pointer)
int no;
struct Swapspace *pointer;
{
	struct Swapspace *swap;

	/* Checks if swap table entry exists */
	if(no >= NSWAPS) return -1;

	/* Get swapspace entry and write to given location */
	swap = &swapspace[no];
	bytecp(swap,pointer,sizeof(struct Swapspace));
	return (int)pointer;
}

/*
 *	Swapcheck()	Checks if a given object is in the swapspace
 */
swapcheck(object,type)
struct	Object *object;
int	type;
{
	int	swapno;
	struct	Swapspace *swap;

	swap = swapspace;
	for(swapno = 0; swapno < NSWAPS; swapno++){
		if(swap->pid && (swap->pid != SWAPCREATE) &&
			(swap->object.majdev == object->majdev) &&
			(swap->object.mindev == object->mindev) &&
			(swap->object.inode == object->inode)){

			/* Return the segment number if found */
			if(type & STEXT){
				if(swap->textseg != SWAPDISK)
					return swap->textseg;
			}
			else return swap->dataseg;
		}
		swap++;
	}
	return -1;
}

/*
 *	Getsarea()	Gets a segment area in the swap space of a mininum size
 *			of totals, returns number of swap area or
 *			-1 if not posible.
 *			If type is SSTICK then only tries a bit.
 *			If trying to swap out a text area then if unable to
 *			find a place returns SWAPDISK (-2) to indicate that
 *			the area on disk could be used.
 *			If trying to swap out a data area and and no space is
 *			available, then a text area will be released and its
 *			apropriate area on disk will be used for later
 *			retreivial.
 */
getsarea(totals,type)
unsigned long totals;
int type;
{
	short swapno, segno, ts;
	struct Swapspace *swap;

#ifdef TSWAP
printf("GETSAREA: tidyied swap size %x\n",totals);
pswap();
#endif

	/* Check if there is a big enough segment available */
	if((segno = getmem(SWAPSEG, totals)) != -1) return segno;

#ifdef TSWAP
printf("STAGE 1 fail\n");
#endif

	/* Compress the segspace up and try again */
	mcomp_seg(SWAPSEG, swapupseg);		/* Compress seg area */
	if((segno = getmem(SWAPSEG, totals)) != -1) return segno;

#ifdef TSWAP
printf("STAGE 2 fail\n");
#endif

	/* If still no free space see if a sticky proccess can be removed */
	swap = swapspace;	/* Sets up swap area pointer to first element */
	for(swapno=0; swapno <NSWAPS; swapno++){

		/* Check if there is a sticky proccess in this segment 
		 * and has a text area of sufficient size to hold the data
		 * And no real proccess is using this text segment
		 */
		if((swap->pid == SWAPSTICK) && (swap->psize.tsize >= totals) &&
			(swap->textseg != SWAPDISK) &&
			(nlockmem(SWAPSEG, swap->textseg) == 1)){

			/* Realease swap segments for use */
			endmem(SWAPSEG, swap->textseg);
			endmem(SWAPSEG, swap->dataseg);

			/* Clears and returns segno */
			swap->pid = 0;

			if((segno = getmem(SWAPSEG,totals)) != -1) return segno;
		}
		swap++;
	}

#ifdef TSWAP
printf("STAGE 3 fail\n");
#endif

	/* If trying to swap out a sticky proccess give up at this point */
	if(type & SSTICK) return -1;

	/* Else compress the seg space completely */

	swapclr();		/* Remove all sticky proccesses */
	mcomp_seg(SWAPSEG, swapupseg);		/* Compress seg area */
	if((segno = getmem(SWAPSEG, totals)) != -1) return segno;

	/* If still no free space and swaping the data segment of a running
	 * process, see if a text segment can be removed
	 */
	if(state.warning) printf("SWAP: getting difficult text area on disk\n");
	swap = swapspace;	/* Sets up swap area pointer to first element */
	for(swapno=0; swapno <NSWAPS; swapno++){

		/* Check if there is a proccess in this segment 
		 * and has a text area of sufficient size to hold the data
		 * If so realese segment and set all segment pointers
		 * to SWAPDISK.
		 */
		if(swap->pid && (swap->psize.tsize >= totals) &&
			(swap->textseg != SWAPDISK)){

			/* Realease swap text segment for use */
			while(endmem(SWAPSEG, swap->textseg) != -1);
			ts = swap->textseg;

			/* Alter swapspace segment number pointers */
			/* Segment is now on the disk */
			swap = swapspace;
			for(swapno = 0; swapno < NSWAPS; swapno++){
				if(swap->textseg == ts) swap->textseg= SWAPDISK;
				swap++;
			}
			break;

		}
		swap++;
	}

	/* The last ditch atempt to copy the data segment if this fails
	 * Goodbye!!!!!!!!
	 */
	mcomp_seg(SWAPSEG, swapupseg);		/* Compress seg area */
	if((segno = getmem(SWAPSEG, totals)) != -1) return segno;

	/* If still no room and tring to swap a text segment then return
	 * SWAPDISK to indicate that the area will be on the disk
	 */
	if(type & STEXT) return SWAPDISK;


	printf("SWAP: Swap space out of room\n");
	pswap();
	return -1;
}

/*
 *	Swapupseg()	Update swap segments
 */
swapupseg(from, to)
int	from, to;
{
	int	swapno;
	struct	Swapspace *swap;

	/* Alter swapspace segment number pointers */
	swap = swapspace;
	for(swapno = 0; swapno < NSWAPS; swapno++){
		if(swap->textseg == from) swap->textseg = to;
		if(swap->dataseg == from) swap->dataseg = to;
		swap++;
	}
	return 0;
}

/*
 *	Swapclr()		Clears all sticky processes from swap area
 */
swapclr(){
	short swapno;
	struct Swapspace *swap;

	/* Remove all sticky proccesses */
	swap = &swapspace[0];	/* Sets up swap area pointer to first segment */
	for(swapno = 0; swapno < NSWAPS; swapno++){

		/* If a sticky proccess remove */
		if(swap->pid == SWAPSTICK){
			/* Realease swap segments for use */
			endmem(SWAPSEG, swap->textseg);
			endmem(SWAPSEG, swap->dataseg);
			swap->pid = 0;
		}
		swap++;
	}
}

pswap(){
	long c,total;
	struct	Minseg *seg;
	struct	Swapspace *swap;

	swap = &swapspace[0];
	printf("Swap space\n");
	printf("Pid	Text	Data	totalsize\n");
	for(c=0; c<NSWAPS; c++){
		total = swap->psize.dsize+swap->psize.bsize+swap->psize.stacks;
		total += swap->psize.tsize;
		printf("%d	",swap->pid);
		printf("%x	%x	%x\n",swap->textseg,swap->dataseg,total);
		if((c > 6) && !swap->pid) break;
		swap++;
	}
	seg = mem_maj[SWAPSEG].segs;
	printf("inuse	Start	End\n");
	for(c=0; c<mem_maj[SWAPSEG].nsegs; c++){
		printf("%d	%x	%x\n",seg->inuse, seg->start, seg->end);
		if((c > 16) && !seg->inuse) break;
		seg++;
	}
	getchar();
}
psize(p)
struct	procs *p;
{
	printf("Entry	Tsize	dsize	bsize	ebss	ssize\n");
	printf("%x	%x	%x	%x	%x	%x\n",p->psize.entry,
p->psize.tsize,p->psize.dsize,p->psize.bsize,p->psize.ebss,p->psize.stacks);
}
