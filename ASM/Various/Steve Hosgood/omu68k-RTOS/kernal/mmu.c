/******************************************************************************
 *	Mmu.c		Contains routines for process memory managment
 ******************************************************************************
 *
 *	When a process requires memory in which to run, or for other
 * purposes, it will call a routine in this section of code.
 *
 *	Main ones are:
 *		getmem()	Will get an area of the given size in the
 *				given memory segment if possible.
 *		extmem()	Will increase or decrease a segment size.
 *		endmem()	Will release a memory segment.
 *		memstart()	Gets the start address of the memory segment.
 *		memend()	Gets the end address of the memory segment.
 *		setmempid()	Sets the process ID useing the segment.
 */

# include	"../include/param.h"
# include	"../include/inode.h"
# include	"../include/signal.h"
# include	"../include/procs.h"
# include	"../include/memory.h"
# include	<errno.h>

/*
 *	Getmem()	Gets a memory segment of size "size", to the next
 *			MMU page boundary, and returns a minor segment number
 *			to access it with. Returns -1 if unable to do so.
 */
getmem(majseg,size)
int	majseg;
long	size;
{
	int	segno;

	/* Special case if process segment */
	if(majseg == PROCSEG) return pgetmem(majseg, size);

	/* Get a segment if possible */
	if((segno = mgetseg(majseg, size)) == -1){
		return -1;
	}
	return segno;
}

/*
 *	Setmempid()	Sets a memory segment to a particular process id
 */
setmempid(majseg, minseg, pid)
int	majseg, minseg, pid;
{
	/* Sets pid */
	mem_maj[majseg].segs[minseg].pid = pid;
	return 0;
}

/*
 *	Endmem()	Ends a memory segment releases memory to system
 *			Returns 0 if OK -1 if segment gone.
 */
endmem(majseg,minseg)
short	majseg, minseg;
{
	return mendseg(majseg, minseg);
}

/*
 *	Memstart()	Gets the start address of a memory segment
 */
memstart(majseg,minseg)
short	majseg, minseg;
{
	return (int)mem_maj[majseg].segs[minseg].start;
}

/*
 *	Memend()	Gets the end address of a memory segment
 */
memend(majseg,minseg)
short	majseg, minseg;
{
	return (int)mem_maj[majseg].segs[minseg].end;
}


/*
 *	Pgetmem()	Gets a memory segment of size "size", to the next
 *			MMU page boundary, and returns a minor segment number
 *			to access it with.
 */
pgetmem(majseg,size)
int	majseg;
long	size;
{
	short	pid;
	struct	procs *proc;

	/* Only works in process segment */

	/* Check if there is room for the process */
	if(size > (mem_maj[PROCSEG].end - mem_maj[PROCSEG].start)) return -1;

	/* Check to see if any processes are in the segment
	 * if so swap them out
	 */
	proc = &proc_table[0];
	for(pid = 0; pid < NPROC; pid++){

		/* If the process is in core and in this memory segment
		 * then swap, if possible.
		 */
		if((proc->flag & SLOAD) && (proc->majseg == majseg)){
			/* If process is locked in core break out */
			if(proc->flag & (SULOCK|SLOCK)) break;

			/* Swapout the process */
			if(swapout(proc)){
				printf("GETMEM: Cannot swap out %s\n",
				 proc->name);
				return -1;
			}

			/* Memory not in use */
			endmem(proc->majseg, proc->minseg);
		}
		proc++;
	}
	/* If any process locked in core then return error */
	if(pid != NPROC){
		 return -1;
	}

	return mgetseg(majseg, mem_maj[majseg].end - mem_maj[majseg].start);
}

/*
 *	Extmem()	Extends a memory segment to size "size", to the next
 *			MMU page boundary, and returns a minor segment number
 *			to access it with.
 */
extmem(majseg,minseg,size)
short	majseg, minseg;
long	size;
{
	/* Only works in process segment */
	if(majseg != PROCSEG) return -1;

	/* Check if there is room for the process */
	if(size > (mem_maj[PROCSEG].end - mem_maj[PROCSEG].start)) return -1;
	return 0;
}

pmajsegs(){
	int	maj;

	for(maj = 0; maj < 7; maj++){
		printf("	Major %d\n",maj);
		printf("inuse %x, nsegs %d, start %x, end %x\n",mem_maj[maj].inuse, mem_maj[maj].nsegs, mem_maj[maj].start, mem_maj[maj].end);
		pminsegs(maj);
	}
}
pminsegs(maj){
	int	min;

	struct	Majseg *m;

	m = &mem_maj[maj];

	for(min = 0; min < m->nsegs; min++){
		printf("min %d inuse %x, start %x, end %x\n",min,
m->segs[min].inuse, m->segs[min].start, m->segs[min].end);
	}
}
