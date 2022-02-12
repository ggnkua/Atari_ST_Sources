/* This file is concerned with allocating and freeing arbitrary-size blocks of
 * physical memory on behalf of the FORK and EXEC system calls.  The key data
 * structure used is the hole table, which maintains a list of holes in memory.
 * It is kept sorted in order of increasing memory address. The addresses
 * it contains refer to physical memory, starting at absolute address 0
 * (i.e., they are not relative to the start of MM).  During system
 * initialization, that part of memory containing the interrupt vectors,
 * kernel, and MM are "allocated" to mark them as not available and to
 * remove them from the hole list.
 *
 * The entry points into this file are:
 *   alloc_mem:	allocate a given sized chunk of memory
 *   free_mem:	release a previously allocated chunk of memory
 *   mem_init:	initialize the tables when MM start up
 *   max_hole:	returns the largest hole currently available
 */

#include "mm.h"
#include <minix/com.h>
#include <minix/callnr.h>
#include <signal.h>
#include "mproc.h"

#define NR_HOLES  (2*NR_PROCS)	/* max # entries in hole table */
#define NIL_HOLE (struct hole *) 0

PRIVATE struct hole {
  struct hole *h_next;		/* pointer to next entry on the list */
  phys_clicks h_base;		/* where does the hole begin? */
  phys_clicks h_len;		/* how big is the hole? */
} hole[NR_HOLES];

PRIVATE struct hole *hole_head;	/* pointer to first hole */
PRIVATE struct hole *free_slots;/* ptr to list of unused table slots */
#if ENABLE_SWAP
PRIVATE int swap_fd = -1;	/* file descriptor of open swap file/device */
PRIVATE u32_t swap_offset;	/* offset to start of swap area on swap file */
PRIVATE phys_clicks swap_base;	/* memory offset chosen as swap base */
PRIVATE phys_clicks swap_maxsize;/* maximum amount of swap "memory" possible */
PRIVATE struct mproc *in_queue;	/* queue of processes wanting to swap in */
PRIVATE struct mproc *outswap = &mproc[LOW_USER];  /* outswap candidate? */
#else /* !SWAP */
#define swap_base ((phys_clicks) -1)
#endif /* !SWAP */

FORWARD _PROTOTYPE( void del_slot, (struct hole *prev_ptr, struct hole *hp) );
FORWARD _PROTOTYPE( void merge, (struct hole *hp)			    );
#if ENABLE_SWAP
FORWARD _PROTOTYPE( int swap_out, (void)				    );
FORWARD _PROTOTYPE( phys_clicks alloc_mem2, \
				(phys_clicks base, phys_clicks clicks)	    );
#else
#define swap_out()	(0)
#endif

#define	TRACE(x)	x

/*===========================================================================*
 *				alloc_mem				     *
 *===========================================================================*/
PUBLIC phys_clicks alloc_mem(clicks)
phys_clicks clicks;		/* amount of memory requested */
{
/* Allocate a block of memory from the free list using first fit. The block
 * consists of a sequence of contiguous bytes, whose length in clicks is
 * given by 'clicks'.  A pointer to the block is returned.  The block is
 * always on a click boundary.  This procedure is called when memory is
 * needed for FORK or EXEC.  Swap other processes out if needed.
 */

  register struct hole *hp, *prev_ptr;
  phys_clicks old_base;

#if (SHADOWING && ENABLE_SWAP)
  register struct hole *best_hp = NIL_HOLE, *best_prev;

  /* find the smallest hole that fits */
  do {
	hp = hole_head;
	while (hp != NIL_HOLE && hp->h_base < swap_base) {
		if (hp->h_len >= clicks) {
			if (best_hp == NIL_HOLE || hp->h_len < best_hp->h_len) {
				best_hp = hp;
				best_prev = prev_ptr;
			}
		}
		prev_ptr = hp;
		hp = hp->h_next;
	}

	/* found a hole ? */
	if (best_hp != NIL_HOLE) {
		old_base = best_hp->h_base;	/* remember where it started */
		best_hp->h_base += clicks;	/* bite a piece off */
		best_hp->h_len -= clicks;	/* ditto */

		/* Delete the hole if used up completely. */
		if (best_hp->h_len == 0) del_slot(best_prev, best_hp);

		/* Return the start address of the acquired block. */
		return(old_base);
	}
  } while (swap_out());		/* try to swap some other process out */

#else

  do {
	hp = hole_head;
	while (hp != NIL_HOLE && hp->h_base < swap_base) {
		if (hp->h_len >= clicks) {
			/* We found a hole that is big enough.  Use it. */
			old_base = hp->h_base;	/* remember where it started */
			hp->h_base += clicks;	/* bite a piece off */
			hp->h_len -= clicks;	/* ditto */

			/* Delete the hole if used up completely. */
			if (hp->h_len == 0) del_slot(prev_ptr, hp);

			/* Return the start address of the acquired block. */
			return(old_base);
		}

		prev_ptr = hp;
		hp = hp->h_next;
	}
  } while (swap_out());		/* try to swap some other process out */

#endif /* SHADOWING && ENABLE_SWAP */

  return(NO_MEM);
}

/*===========================================================================*
 *				free_mem				     *
 *===========================================================================*/
PUBLIC void free_mem(base, clicks)
phys_clicks base;		/* base address of block to free */
phys_clicks clicks;		/* number of clicks to free */
{
/* Return a block of free memory to the hole list.  The parameters tell where
 * the block starts in physical memory and how big it is.  The block is added
 * to the hole list.  If it is contiguous with an existing hole on either end,
 * it is merged with the hole or holes.
 */

  register struct hole *hp, *new_ptr, *prev_ptr;

  if (clicks == 0) return;
  if ( (new_ptr = free_slots) == NIL_HOLE) panic("Hole table full", NO_NUM);
  new_ptr->h_base = base;
  new_ptr->h_len = clicks;
  free_slots = new_ptr->h_next;
  hp = hole_head;

  /* If this block's address is numerically less than the lowest hole currently
   * available, or if no holes are currently available, put this hole on the
   * front of the hole list.
   */
  if (hp == NIL_HOLE || base <= hp->h_base) {
	/* Block to be freed goes on front of the hole list. */
	new_ptr->h_next = hp;
	hole_head = new_ptr;
	merge(new_ptr);
	return;
  }

  /* Block to be returned does not go on front of hole list. */
  while (hp != NIL_HOLE && base > hp->h_base) {
	prev_ptr = hp;
	hp = hp->h_next;
  }

  /* We found where it goes.  Insert block after 'prev_ptr'. */
  new_ptr->h_next = prev_ptr->h_next;
  prev_ptr->h_next = new_ptr;
  merge(prev_ptr);		/* sequence is 'prev_ptr', 'new_ptr', 'hp' */
}

/*===========================================================================*
 *				del_slot				     *
 *===========================================================================*/
PRIVATE void del_slot(prev_ptr, hp)
register struct hole *prev_ptr;	/* pointer to hole entry just ahead of 'hp' */
register struct hole *hp;	/* pointer to hole entry to be removed */
{
/* Remove an entry from the hole list.  This procedure is called when a
 * request to allocate memory removes a hole in its entirety, thus reducing
 * the numbers of holes in memory, and requiring the elimination of one
 * entry in the hole list.
 */

  if (hp == hole_head)
	hole_head = hp->h_next;
  else
	prev_ptr->h_next = hp->h_next;

  hp->h_next = free_slots;
  free_slots = hp;
}

/*===========================================================================*
 *				merge					     *
 *===========================================================================*/
PRIVATE void merge(hp)
register struct hole *hp;	/* ptr to hole to merge with its successors */
{
/* Check for contiguous holes and merge any found.  Contiguous holes can occur
 * when a block of memory is freed, and it happens to abut another hole on
 * either or both ends.  The pointer 'hp' points to the first of a series of
 * three holes that can potentially all be merged together.
 */

  register struct hole *next_ptr;

  /* If 'hp' points to the last hole, no merging is possible.  If it does not,
   * try to absorb its successor into it and free the successor's table entry.
   */
  if ( (next_ptr = hp->h_next) == NIL_HOLE) return;
  if (hp->h_base + hp->h_len == next_ptr->h_base) {
	hp->h_len += next_ptr->h_len;	/* first one gets second one's mem */
	del_slot(hp, next_ptr);
  } else {
	hp = next_ptr;
  }

  /* If 'hp' now points to the last hole, return; otherwise, try to absorb its
   * successor into it.
   */
  if ( (next_ptr = hp->h_next) == NIL_HOLE) return;
  if (hp->h_base + hp->h_len == next_ptr->h_base) {
	hp->h_len += next_ptr->h_len;
	del_slot(hp, next_ptr);
  }
}

/*===========================================================================*
 *				mem_init				     *
 *===========================================================================*/
PUBLIC void mem_init(total, free)
phys_clicks *total, *free;		/* memory size summaries */
{
/* Initialize hole lists.  There are two lists: 'hole_head' points to a linked
 * list of all the holes (unused memory) in the system; 'free_slots' points to
 * a linked list of table entries that are not in use.  Initially, the former
 * list has one entry for each chunk of physical memory, and the second
 * list links together the remaining table slots.  As memory becomes more
 * fragmented in the course of time (i.e., the initial big holes break up into
 * smaller holes), new table slots are needed to represent them.  These slots
 * are taken from the list headed by 'free_slots'.
 */

  register struct hole *hp;
  phys_clicks base;		/* base address of chunk */
  phys_clicks size;		/* size of chunk */
  message mess;

  /* Put all holes on the free list. */
  for (hp = &hole[0]; hp < &hole[NR_HOLES]; hp++) hp->h_next = hp + 1;
  hole[NR_HOLES-1].h_next = NIL_HOLE;
  hole_head = NIL_HOLE;
  free_slots = &hole[0];

  /* Ask the kernel for chunks of physical memory and allocate a hole for
   * each of them.  The SYS_MEM call responds with the base and size of the
   * next chunk and the total amount of memory.
   */
  *free = 0;
  for (;;) {
	mess.m_type = SYS_MEM;
	if (sendrec(SYSTASK, &mess) != OK) panic("bad SYS_MEM?", NO_NUM);
	base = mess.m1_i1;
	size = mess.m1_i2;
	if (size == 0) break;		/* no more? */

	free_mem(base, size);
	*total = mess.m1_i3;
	*free += size;
#if ENABLE_SWAP
	if (swap_base < base + size) swap_base = base+size;
#endif
  }

#if ENABLE_SWAP
  /* The swap area is represented as a hole above and separate of regular
   * memory.  A hole at the size of the swap file is allocated on "swapon".
   */
  swap_base++;				/* make separate */
  swap_maxsize = 0 - swap_base;		/* maximum we can possibly use */
#endif
}

#if ENABLE_SWAP
/*===========================================================================*
 *				swap_on					     *
 *===========================================================================*/
PUBLIC int swap_on(file, offset, size)
char *file;				/* file to swap on */
u32_t offset, size;			/* area on swap file to use */
{
/* Turn swapping on. */

  if (swap_fd != -1) return(EBUSY);	/* already have swap? */

  tell_fs(CHDIR, who, FALSE, 0);	/* be like the caller for open() */
  if ((swap_fd = open(file, O_RDWR)) < 0) return(-errno);
  swap_offset = offset;
  size >>= CLICK_SHIFT;
  if (size > swap_maxsize) size = swap_maxsize;
  if (size > 0) free_mem(swap_base, (phys_clicks) size);
}

/*===========================================================================*
 *				swap_off				     *
 *===========================================================================*/
PUBLIC int swap_off()
{
/* Turn swapping off. */
  struct mproc *rmp;
  struct hole *hp, *prev_ptr;

  if (swap_fd == -1) return(OK);	/* can't turn off what isn't on */

  /* Put all swapped out processes on the inswap queue and swap in. */
  for (rmp = mproc_addr(LOW_USER); rmp < &mproc[NR_PROCS]; rmp++) {
	if (rmp->mp_flags & ONSWAP) swap_inqueue(rmp);
  }
  swap_in();

  /* All in memory? */
  for (rmp = mproc_addr(LOW_USER); rmp < &mproc[NR_PROCS]; rmp++) {
	if (rmp->mp_flags & ONSWAP) return(ENOMEM);
  }

  /* Yes.  Remove the swap hole and close the swap file descriptor. */
  for (hp = hole_head; hp != NIL_HOLE; prev_ptr = hp, hp = hp->h_next) {
	if (hp->h_base >= swap_base) {
		del_slot(prev_ptr, hp);
		hp = hole_head;
	}
  }
  close(swap_fd);
  swap_fd = -1;
  return(OK);
}

/*===========================================================================*
 *				swap_inqueue				     *
 *===========================================================================*/
PUBLIC void swap_inqueue(rmp)
register struct mproc *rmp;		/* process to add to the queue */
{
/* Put a swapped out process on the queue of processes to be swapped in.  This
 * happens when such a process gets a signal, or if a reply message must be
 * sent, like when a process doing a wait() has a child that exits.
 */
  struct mproc **pmp;

  if (rmp->mp_flags & SWAPIN) return;	/* already queued */

  
  for (pmp = &in_queue; *pmp != NULL; pmp = &(*pmp)->mp_swapq) {}
  *pmp = rmp;
  rmp->mp_swapq = NULL;
  rmp->mp_flags |= SWAPIN;
}

/*===========================================================================*
 *				swap_in					     *
 *===========================================================================*/
PUBLIC void swap_in()
{
/* Try to swap in a process on the inswap queue.  We want to send it a message,
 * interrupt it, or something.
 */
  struct mproc **pmp, *rmp;
  phys_clicks old_base, new_base, size;
  off_t off;
  int proc_nr;

  pmp = &in_queue;
  while ((rmp = *pmp) != NULL) {
	proc_nr = (rmp - mproc);
	size = rmp->mp_seg[S].mem_vir + rmp->mp_seg[S].mem_len
		- rmp->mp_seg[D].mem_vir;

	if (!(rmp->mp_flags & SWAPIN)) {
		/* Guess it got killed.  (Queue is cleaned here.) */
		*pmp = rmp->mp_swapq;
		continue;
	} else
#if SHADOWING
	if ((new_base = alloc_mem2(rmp->mp_memadr, size)) == NO_MEM) {
#else
	if ((new_base = alloc_mem(size)) == NO_MEM) {
#endif /* SHADOWING */
		/* No memory for this one, try the next. */
		pmp = &rmp->mp_swapq;
	} else {
		/* We've found memory.  Update map and swap in. */
		old_base = rmp->mp_seg[D].mem_phys;
		rmp->mp_seg[D].mem_phys = new_base;
#if SHADOWING
		rmp->mp_seg[S].mem_phys += new_base - old_base;
#else
		rmp->mp_seg[S].mem_phys = rmp->mp_seg[D].mem_phys + 
			(rmp->mp_seg[S].mem_vir - rmp->mp_seg[D].mem_vir);
#endif /* SHADOWING */
		sys_newmap(proc_nr, rmp->mp_seg);
		off = swap_offset + ((off_t) (old_base-swap_base)<<CLICK_SHIFT);
		lseek(swap_fd, off, SEEK_SET);
		rw_seg(0, swap_fd, proc_nr, D, (phys_bytes)size << CLICK_SHIFT);
		free_mem(old_base, size);
		rmp->mp_flags &= ~(ONSWAP|SWAPIN);
		*pmp = rmp->mp_swapq;
		TRACE(printf("swapped in base %x with %d clicks\n", new_base, size));
		check_pending(rmp);	/* a signal may have waked this one */
	}
  }
}

/*===========================================================================*
 *				swap_out				     *
 *===========================================================================*/
PRIVATE int swap_out()
{
/* Try to find a process that can be swapped out.  Candidates are those blocked
 * on a system call that MM handles, like wait(), pause() or sigsuspend().
 */
  struct mproc *rmp;
  struct hole *hp, *prev_ptr;
  phys_clicks old_base, new_base, size;
  off_t off;
  int proc_nr;

  rmp = outswap;
  do {
	if (++rmp == &mproc[NR_PROCS]) rmp = mproc_addr(LOW_USER);

	/* A candidate? */
	if (!(rmp->mp_flags & (PAUSED | WAITING | SIGSUSPENDED))) continue;

	/* Already on swap or otherwise to be avoided? */
	if (rmp->mp_flags & (TRACED | REPLY | ONSWAP)) continue;

#if SHADOWING
	if (rmp->mp_flags & MM_DONT_SWAP) continue;
#endif /* SHADOWING */

	/* Got one, find a swap hole and swap it out. */
	proc_nr = (rmp - mproc);
	size = rmp->mp_seg[S].mem_vir + rmp->mp_seg[S].mem_len
		- rmp->mp_seg[D].mem_vir;

	prev_ptr = NIL_HOLE;
	for (hp = hole_head; hp != NIL_HOLE; prev_ptr = hp, hp = hp->h_next) {
		if (hp->h_base >= swap_base && hp->h_len >= size) break;
	}
	if (hp == NIL_HOLE) continue;	/* oops, not enough swapspace */
	new_base = hp->h_base;
	hp->h_base += size;
	hp->h_len -= size;
	if (hp->h_len == 0) del_slot(prev_ptr, hp);

	off = swap_offset + ((off_t) (new_base - swap_base) << CLICK_SHIFT);
	lseek(swap_fd, off, SEEK_SET);
	rw_seg(1, swap_fd, proc_nr, D, (phys_bytes)size << CLICK_SHIFT);
	old_base = rmp->mp_seg[D].mem_phys;
#if SHADOWING
	rmp->mp_memadr = old_base;
#endif /* SHADOWING */
	rmp->mp_seg[D].mem_phys = new_base;
#if SHADOWING
	rmp->mp_seg[S].mem_phys += new_base - old_base;
#else
	rmp->mp_seg[S].mem_phys = rmp->mp_seg[D].mem_phys + 
		(rmp->mp_seg[S].mem_vir - rmp->mp_seg[D].mem_vir);
#endif /* SHADOWING */
	sys_newmap(proc_nr, rmp->mp_seg);
	free_mem(old_base, size);
	rmp->mp_flags |= ONSWAP;

	outswap = rmp;		/* next time start here */
	TRACE(printf("swapped out base %x with %d clicks\n", old_base, size));
	return(TRUE);
  } while (rmp != outswap);

  return(FALSE);	/* no candidate found */
}

#if SHADOWING
/*===========================================================================*
 *				alloc_mem2				     *
 *===========================================================================*/
PRIVATE phys_clicks alloc_mem2(base, clicks)
phys_clicks base;
phys_clicks clicks;		/* amount of memory requested */
{
/* Try to alloc memory from base with clicks size */

  register struct hole *hp, *new_ptr, *prev_ptr;

  do {
	hp = hole_head;
	while (hp != NIL_HOLE && hp->h_base <= base && hp->h_base < swap_base) {
		if (hp->h_base + hp->h_len >= base + clicks) {
			/* We found the hole.  Use it. */
			if (hp->h_base < base) {
				/* take care of new hole under base */
  				if ((new_ptr = free_slots) == NIL_HOLE) {
					printf("Hole table full");
					return (NO_MEM);
				}
				/* fill in new hole slot */
				new_ptr->h_base = hp->h_base;
				new_ptr->h_len = base - new_ptr->h_base;

				/* and link it in */
				if (hp == hole_head)
					hole_head = new_ptr;
				else
					prev_ptr->h_next = new_ptr;
				new_ptr->h_next = hp;
				prev_ptr = new_ptr;

				/* adjust our hole */
				hp->h_base = base;
			}
			hp->h_base += clicks;	/* bite a piece off */
			hp->h_len -= clicks;	/* ditto */

			/* Delete the hole if used up completely. */
			if (hp->h_len == 0) del_slot(prev_ptr, hp);

			/* Return the start address of the acquired block. */
			return(base);
		}

		prev_ptr = hp;
		hp = hp->h_next;
	}
  } while (swap_out());		/* try to swap some other process out */
  return(NO_MEM);
}
#endif /* SHADOWING */
#endif /* SWAP */
