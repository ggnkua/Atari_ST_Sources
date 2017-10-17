/******************************************************************************
 *	Memory.c	Memory usage control
 *			T.Barnaby, Made 22/7/85
 ******************************************************************************
 *
 *	This section of code allocates system memory into Major segments
 *	and minor segments that are used for different tasks.
 *	The Major segment areas are defined in the Majseg structure,
 *	the entries for which are:-
 *
 *		short	inuse	-	Indicates segment is in use ie
 *					contains data, that is required.
 *					and number of things using it.
 *		short	nsegs	-	Number of minor segments beneath it.
 *		struct	Minseg segs -	Pointer to array of minor segments.
 *		caddr_t	start	-	Start address of segment
 *		caddr_t	end	-	End address of segment
 *
 *	The standard segment uses are:-
 *
 *		0	-	All of memory	Special case
 *		1	-	Kernal area
 *		2	-	Process workspace
 *		3	-	Process 2 workspace
 *		4	-	Swap space
 *		5	-	Ramdisk space
 *		6	-	User addon device driver space
 *
 *	Special system calls available to super-user only allow modifiaction
 *	to these entries, but only when the segment concerned is not in use.
 *	Note segments can be made to overlap one another, so watch it!
 *	
 */

# include	"../include/param.h"
# include	"../include/inode.h"
# include	"../include/signal.h"
# include	"../include/procs.h"
# include	"../include/memory.h"
# include	<errno.h>

/* Initial Major memory segment sizes in c.c */

extern	struct Majseg dmem_maj[NMSEGS];
struct Majseg mem_maj[NMSEGS];

/* Minor segment arrays */
struct	Minseg mseg0[NMINSEG0], mseg1[NMINSEG1], mseg2[NMINSEG2];
struct	Minseg mseg3[NMINSEG3], mseg4[NMINSEG4], mseg5[NMINSEG5];
struct	Minseg mseg6[NMINSEG6];

/*
 *	Meminit()	Initialises memory segments
 */
mem_init(){
	int	maj;

	/* Initialise memory segments to default values
	 * NOTE 0 is special case ie all of available memory containing
	 * all other segments.
	 */
	bytecp(dmem_maj, mem_maj, sizeof(struct Majseg) * NMSEGS);

	/* Initialise all minor memory segments */
	for(maj = 0; maj < NMSEGS; maj++) mtidyseg(maj);
}

/*
 *	Getseg()	Gets a Major segment entry if valid
 */
getseg(seg, mem)
int seg;
struct Majseg *mem;
{
	if((seg < 0) || (seg >= NMSEGS)) return error(-1);
	bytecp(&mem_maj[seg], mem, sizeof(struct Majseg));
	return 0;
}

/*
 *	Setseg()	Sets a Major segment entry if valid and super-user
 */
setseg(seg, mem)
int seg;
struct Majseg *mem;
{
	/* Checks if super-user */
	if(cur_proc->euid) return error(EPERM);

	/* Checks if segment is valid */
	if((seg < 0) || (seg >= NMSEGS)) return error(-1);

	swapclr();	/* Clears swap area of sticky processes */

	/* Only allowed if segment not in use */
	if(mem_maj[seg].inuse) return error(-1);

	/* Set start and end addresses */
	mem_maj[seg].end = mem->end;
	mem_maj[seg].start = mem->start;
	return 0;
}

/*
 *	Mgetseg()	Checks Minor segment area for free space if found
 *			returns	segment number else -1
 */
mgetseg(majseg, totals)
int	majseg;
int	totals;
{
	int segno;
	struct Minseg *seg;

	/* Tidy segments before try */
	mtidyseg(majseg);

	/* Search through seg table for free space */
	/* Sets up seg area pointer to first segment */
	seg = mem_maj[majseg].segs;
	for(segno = 0; segno < mem_maj[majseg].nsegs; segno++){

		/* Check if there is room in this segment */
		if((!seg->inuse) && ((seg->end - seg->start) >= totals) ){
			/* Set up segment info */
			seg->inuse++;
			if(totals) seg->end = seg->start + totals;
			mem_maj[majseg].inuse++;
			mtidyseg(majseg);
			return segno;
		}
		seg++;
	}
	return -1;
}

/*
 *	Mendseg()	Ends the use of the given segment
 */
mendseg(majseg, minseg)
int	majseg, minseg;
{
	int	err;

	/* Returns ok */
	err = 0;

	/* Decrements inuse flag */
	if(--(mem_maj[majseg].inuse) < 0) mem_maj[majseg].inuse = 0;
	if(--(mem_maj[majseg].segs[minseg].inuse) < 0){
		mem_maj[majseg].segs[minseg].inuse = 0;
		err = -1;
	}
	mtidyseg(majseg);
	return err;
}

/*
 *	Relockmem()	Relocks a memory segment ie used by some-one else
 */
relockmem(majseg,minseg)
short	majseg, minseg;
{
	/* Increments inuse flag */
	mem_maj[majseg].inuse++;
	mem_maj[majseg].segs[minseg].inuse++;
	return 0;
}

/*
 *	Nlockmem()	Returns the number of locks to segment
 */
nlockmem(majseg,minseg)
short	majseg, minseg;
{
	/* Returns inuse flag */
	return mem_maj[majseg].segs[minseg].inuse;
}

/*
 *	Mcomp_segs()	Compress the Major segments by moveing
 *			the minor segments together.
 *			Calls function update with two arguments
 *			update(from, to) which are segment numbers moved.
 */
mcomp_segs(majseg, update)
int	majseg;
int	(*update)();
{
	struct	Majseg *maj;
	struct	Minseg *tmin, *fmin;
	int to, from;

	maj = &mem_maj[majseg];		/* Gets address of major segment */
	if(maj->nsegs < 2) return 0;	/* If one or less segments return */

	tmin = maj->segs;		/* First segment entry */

	/* Search through swap table for an empty segment */
	for(to = 0; to < (maj->nsegs - 1); to++){

		/* Check if this segment is used */
		if(!tmin->inuse){

			/* Sets start of area pointer to end of last area */
			if(to > 0) tmin->start = (tmin-1)->end;

			/* If not look from here upwards to find a used
			 * segment
			 */
			fmin = tmin + 1;
			for(from = to + 1; from < maj->nsegs; from++){
				if(fmin->inuse){
					/* When found copy it into the unused
					 * one. If update function is present
					 * Then call this with segment numbers
					 * Being updated.
					 */
					if(update) update(from, to);
					mmoveseg(fmin, tmin);
					break;
				}
				fmin++;
			}
		}
		tmin++;
	}
	return 0;
}

/*
 *	Mmoveseg()	Given two swap space segment entries will copy the first
 *			to the second in its entirety ( the whole lot! )
 */
mmoveseg(from, to)
struct	Minseg *from, *to;
{
	int	size;

	/* Calculate used size of segment */
	size = from->end - from->start;

	/* Copy segment */
	bytecp(from->start, to->start, size);

	/* Set up pointers in new segment */
	to->end = to->start + size;
	to->inuse = from->inuse;

	/* Setup old segments start address */
	from->start = to->end;

	/* Release old segment */
	from->inuse = 0;
	return 0;
}

/*	Mtidyseg()	This routine sets the last avalable segment entry
 *			to occupy the rest of the avalable segory
 *			It also will clear two consecutive empty areas
 *			Into one occupying the size of the two areas
 *			and one of null size.
 */

mtidyseg(majseg)
int	majseg;
{
	short	segno, s;
	struct	Minseg *seg;
	struct	Majseg *maj;

	/* Sets next area available's start and end addreses */
	maj = &mem_maj[majseg];		/* Pointer to major segment */
	segno = maj->nsegs;		/* last entry in seg space  +1*/

	if(!segno) return 0;		/* If no minor segments return */

	/* Sets last available segments's start and end addreses */
	seg = maj->segs + (segno - 1);	/* Last minor segment entry */
	s = segno - 1;
	while(s >= 0){
		if(seg->inuse){
			/* Found used area sets one above to rest of seg space*/
			/* Checks if segment + 1 is valid */
			if(s < (segno - 1)){
				(seg+1)->end = maj->end;
				(seg+1)->start = seg->end;
			}
			break;
		}
		else seg->end = seg->start = maj->end;
		s--;
		seg--;
	}

	/* Special case no entries in seg area, sets entry 0 to whole area */
	/* s and seg points to last used area or -1 if none */
	if(s < 0){
		(seg+1)->end = maj->end;
		(seg+1)->start = maj->start;
	}

	/* Make any unused consecutive entrys into one filling the whole
	 * space setting the other blocks to null sized areas
	 * segno and seg are initialy pointing at the last used block
	 * in the seg list
	 */

	/* Work down list seeking consecutive unused areas
	 * and setting the start of the last of these to the end
	 * Of the used area imediatly above these areas
	 */
	while(--s > 0){
		seg--;
		while((s >= 0) && (!seg->inuse)){
			seg->start = seg->end = (seg+1)->start;

			if(s == 0) seg->start = maj->start;
			else if((seg-1)->inuse) seg->start = (seg-1)->end;

			s--;
			seg--;
		}
	}
	return 0;
}
