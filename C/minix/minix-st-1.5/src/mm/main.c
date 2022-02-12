/* This file contains the main program of the memory manager and some related
 * procedures.  When MINIX starts up, the kernel runs for a little while,
 * initializing itself and its tasks, and then it runs MM.  MM at this point
 * does not know where FS is in memory and how big it is.  By convention, FS
 * must start at the click following MM, so MM can deduce where it starts at
 * least.  Later, when FS runs for the first time, FS makes a pseudo-call,
 * BRK2, to tell MM how big it is.  This allows MM to figure out where INIT
 * is.
 *
 * The entry points into this file are:
 *   main:	starts MM running
 *   reply:	reply to a process making an MM system call
 *   do_brk2:	pseudo-call for FS to report its size
 */

#include "mm.h"
#include <minix/callnr.h>
#include <minix/com.h>
#include "mproc.h"
#include "param.h"

FORWARD void get_work();
FORWARD void mm_init();

/*===========================================================================*
 *				main					     *
 *===========================================================================*/
PUBLIC void main()
{
/* Main routine of the memory manager. */

  int error;

  mm_init();			/* initialize memory manager tables */

  /* This is MM's main loop-  get work and do it, forever and forever. */
  while (TRUE) {
	/* Wait for message. */
	get_work();		/* wait for an MM system call */
	mp = &mproc[who];

  	/* Set some flags. */
	error = OK;
	dont_reply = FALSE;
	err_code = -999;

	/* If the call number is valid, perform the call. */
	if (mm_call < 0 || mm_call >= NCALLS)
		error = EBADCALL;
	else
		error = (*call_vec[mm_call])();

	/* Send the results back to the user to indicate completion. */
	if (dont_reply) continue;	/* no reply for EXIT and WAIT */
	if (mm_call == EXEC && error == OK) continue;
	reply(who, error, result2, res_ptr);
  }
}


/*===========================================================================*
 *				get_work				     *
 *===========================================================================*/
PRIVATE void get_work()
{  
/* Wait for the next message and extract useful information from it. */

  if (receive(ANY, &mm_in) != OK) panic("MM receive error", NO_NUM);
  who = mm_in.m_source;		/* who sent the message */
  mm_call = mm_in.m_type;	/* system call number */
}


/*===========================================================================*
 *				reply					     *
 *===========================================================================*/
PUBLIC void reply(proc_nr, result, res2, respt)
int proc_nr;			/* process to reply to */
int result;			/* result of the call (usually OK or error #)*/
int res2;			/* secondary result */
char *respt;			/* result if pointer */
{
/* Send a reply to a user process. */

  register struct mproc *proc_ptr;

  /* To make MM robust, check to see if destination is still alive. */
  proc_ptr = &mproc[proc_nr];
  if ( (proc_ptr->mp_flags&IN_USE) == 0 || (proc_ptr->mp_flags&HANGING)) return;
  reply_type = result;
  reply_i1 = res2;
  reply_p1 = respt;
  if (send(proc_nr, &mm_out) != OK) panic("MM can't reply", NO_NUM);
}


/*===========================================================================*
 *				mm_init					     *
 *===========================================================================*/
PRIVATE void mm_init()
{
/* Initialize the memory manager. */

  mem_init();			/* initialize tables to all physical mem */

  /* Initialize MM's tables. */
  mproc[MM_PROC_NR].mp_flags |= IN_USE;
  mproc[FS_PROC_NR].mp_flags |= IN_USE;
  mproc[INIT_PROC_NR].mp_flags |= IN_USE;
  mproc[INIT_PROC_NR].mp_pid = INIT_PID;
  procs_in_use = 3;
}


/*===========================================================================*
 *				do_brk2	   				     *
 *===========================================================================*/
PUBLIC int do_brk2()
{
/* This "call" is made once by FS during system initialization and then never
 * again by anyone.  It contains the origin and size of INIT, and the combined
 * size of the 1536 bytes of unused mem, MINIX and RAM disk.
 *   m1_i1 = size of INIT text in clicks
 *   m1_i2 = size of INIT data in clicks
 *   m1_i3 = number of bytes for MINIX + RAM DISK
 *   m1_p1 = origin of INIT in clicks
 */

  int mem1, mem2, mem3;
  register struct mproc *rmp;
  phys_clicks init_org, init_clicks, ram_base, ram_clicks, tot_clicks;
  phys_clicks init_text_clicks, init_data_clicks;
  phys_clicks minix_clicks;

  if (who != FS_PROC_NR) return(EPERM);	/* only FS make do BRK2 */

  /* Remove the memory used by MINIX from the memory map. */
  init_text_clicks = mm_in.m1_i1;	/* size of INIT in clicks */
  init_data_clicks = mm_in.m1_i2;	/* size of INIT in clicks */
  init_org = (phys_clicks) mm_in.m1_p1;	/* addr where INIT begins in memory */
  init_clicks = init_text_clicks + init_data_clicks;
  minix_clicks = init_org + init_clicks;	/* size of system in clicks */
  ram_base = alloc_mem(minix_clicks);	/* remove MINIX from map */
  if (ram_base != 0)
	panic("inconsistent system memory base", ram_base);

  /* Remove the memory used by the RAM disk from the memory map. */
  tot_clicks = mm_in.m1_i3;		/* total size of MINIX + RAM disk */
  ram_clicks = tot_clicks - minix_clicks;	/* size of RAM disk */
#if (CHIP == INTEL)
  /* Put RAM disk in extended memory, if any. */
  if (get_mem(&ram_base, TRUE) >= ram_clicks)
	goto got_base;
#endif
  ram_base = alloc_mem(ram_clicks);	/* remove the RAM disk from the map */
  if (ram_base == NO_MEM)
	panic("not enough memory for RAM disk", NO_NUM);
got_base:
  mm_out.POSITION = (phys_bytes) ram_base * CLICK_SIZE;	/* tell FS where */

  /* Print memory information. */
#if (MACHINE == MACINTOSH)
  /* Mac memory does not start at zero, so adjust the numbers */
  mem1 = click_to_round_k(minix_clicks-start_click()+ram_clicks+mem_left());  
  mem2 = click_to_round_k(minix_clicks-start_click());
#else
  mem1 = click_to_round_k(minix_clicks + ram_clicks + mem_left());  
  mem2 = click_to_round_k(minix_clicks);
#endif
  mem3 = click_to_round_k(ram_clicks);
#if (CHIP == INTEL)
  printf("%c[H%c[J",033, 033);	/* go to top of screen and clear screen */
#endif
  printf("Memory size = %4dK     ", mem1);
  printf("MINIX = %3dK     ", mem2);
  printf("RAM disk = %4dK     ", mem3);
  printf("Available = %dK\n\n", mem1 - mem2 - mem3);
  if (mem1 - mem2 - mem3 < 32) {
	printf("\nNot enough memory to run MINIX\n\n", NO_NUM);
	sys_abort();
  }

  /* Initialize INIT's table entry. */
  rmp = &mproc[INIT_PROC_NR];
  rmp->mp_seg[T].mem_phys = init_org;
  rmp->mp_seg[T].mem_len  = init_text_clicks;
  rmp->mp_seg[D].mem_phys = init_org + init_text_clicks;
  rmp->mp_seg[D].mem_len  = init_data_clicks;
  rmp->mp_seg[S].mem_phys = init_org + init_clicks;
#if (CHIP == M68000)
  rmp->mp_seg[T].mem_vir  = rmp->mp_seg[T].mem_phys;
  rmp->mp_seg[D].mem_vir  = rmp->mp_seg[D].mem_phys;
  rmp->mp_seg[S].mem_vir  = rmp->mp_seg[S].mem_phys;
#else
  rmp->mp_seg[S].mem_vir  = init_clicks;
#endif
  if (init_text_clicks != 0) rmp->mp_flags |= SEPARATE;

  return(OK);
}


/*===========================================================================*
 *				get_mem					     *
 *===========================================================================*/
PUBLIC phys_clicks get_mem(pbase, extflag)
phys_clicks *pbase;		/* where to return the base */
int extflag;			/* nonzero for extended memory */
{
/* Ask kernel for the next chunk of memory.  'extflag' specifies the type of
 * memory.  "Extended" memory here means memory above 1MB which is no good
 * for putting programs in but usable for the RAM disk.  MM doesn't care
 * about the locations of the 2 types of memory, except memory above 1MB is
 * unreachable unless CLICK_SIZE > 16, but still usable for the RAM disk.
 */
  mm_out.m_type = SYS_MEM;
  mm_out.DEVICE = extflag;
  if (sendrec(SYSTASK, &mm_out) != OK || mm_out.m_type != OK)
	panic("Kernel didn't respond to get_mem", NO_NUM);
  *pbase = (phys_clicks) mm_out.POSITION;
  return((phys_clicks) mm_out.COUNT);
}
