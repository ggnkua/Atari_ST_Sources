/* This file contains a collection of miscellaneous procedures:
 *	mem_init:	initialize memory tables.  Some memory is reported
 *			by the BIOS, some is guesstimated and checked later
 *	do_vrdwt:	unpack an i/o vector for those block device drivers
 *			which do not do it for themself
 */

#include "kernel.h"
#include <minix/com.h>

#if (CHIP == INTEL)

#define EM_BASE     0x100000L	/* base of extended memory on AT's */
#define SHADOW_BASE 0xFA0000L	/* base of RAM shadowing ROM on some AT's */
#define SHADOW_MAX  0x060000L	/* maximum usable shadow memory (16M limit) */

/*=========================================================================*
 *				mem_init				   *
 *=========================================================================*/
PUBLIC void mem_init()
{
/* Initialize the memory size tables.  This is complicated by fragmentation
 * and different access strategies for protected mode.  There must be a
 * chunk at 0 big enough to hold Minix proper.  For 286 and 386 processors,
 * there can be extended memory (memory above 1MB).  This usually starts at
 * 1MB, but there may be another chunk just below 16MB, reserved under DOS
 * for shadowing ROM, but available to Minix if the hardware can be re-mapped.
 * In protected mode, extended memory is accessible assuming CLICK_SIZE is
 * large enough, and is treated as ordinary memory.
 * The magic bits for memory types are:
 *	1: extended
 *	0x80: must be checked since BIOS doesn't and it may not be there.
 */

  /* Get the size of ordinary memory from the BIOS. */
  mem_size[0] = k_to_click(low_memsize);	/* 0 base and type */

#if SPARE_VIDEO_MEMORY
  /* Spare video memory.  Experimental, it's too slow for program memory
   * except maybe on PC's, and belongs low in a memory hierarchy.
   */
  if (color) {
	mem_size[1] = MONO_SIZE >> CLICK_SHIFT;
	mem_base[1] = MONO_BASE >> CLICK_SHIFT;
  } else {
	mem_size[1] = COLOR_SIZE >> CLICK_SHIFT;
	mem_base[1] = COLOR_BASE >> CLICK_SHIFT;
  }
  mem_type[1] = 0x80;
#endif

  if (pc_at) {
	/* Get the size of extended memory from the BIOS.  This is special
	 * except in protected mode, but protected mode is now normal.
	 */
	mem_size[2] = k_to_click(ext_memsize);
	mem_base[2] = EM_BASE >> CLICK_SHIFT;

	/* Shadow ROM memory. */
	mem_size[3] = SHADOW_MAX >> CLICK_SHIFT;
	mem_base[3] = SHADOW_BASE >> CLICK_SHIFT;
	mem_type[3] = 0x80;

	if (!protected_mode) {
		mem_type[2] = 1;
		mem_type[3] |= 1;
	}
  }
}
#endif /* (CHIP == INTEL) */


/*==========================================================================*
 *				do_vrdwt				    *
 *==========================================================================*/
PUBLIC int do_vrdwt(m_ptr, do_rdwt)
register message *m_ptr;	/* pointer to read or write message */
int (*do_rdwt)();		/* pointer to function which does the work */
{
/* Fetch a vector of i/o requests.  Handle requests one at a time.  Return
 * status in the vector.
 */

  register struct iorequest_s *iop;
  static struct iorequest_s iovec[NR_BUFS];
  phys_bytes iovec_phys;
  unsigned nr_requests;
  int request;
  int result;
  phys_bytes user_iovec_phys;
  message vmessage;
  int proc_nr;
  int device;

  nr_requests = m_ptr->COUNT;
  proc_nr = m_ptr->PROC_NR;
  device = m_ptr->DEVICE;
  if (nr_requests > sizeof iovec / sizeof iovec[0])
	panic("FS gave some driver too big an i/o vector", nr_requests);
  iovec_phys = umap(proc_ptr, D, (vir_bytes) iovec, (vir_bytes) sizeof iovec);
  user_iovec_phys = numap(m_ptr->PROC_NR, (vir_bytes) m_ptr->ADDRESS,
			 (vir_bytes) (nr_requests * sizeof iovec[0]));
  if (user_iovec_phys == 0)
	panic("FS gave some driver bad i/o vector", (int) m_ptr->ADDRESS);
  phys_copy(user_iovec_phys, iovec_phys,
	    (phys_bytes) nr_requests * sizeof iovec[0]);

  for (request = 0; request < nr_requests; ++request) {
	iop = &iovec[request];
	vmessage.m_type = iop->io_request & ~OPTIONAL_IO;
	vmessage.DEVICE = device;
	vmessage.PROC_NR = proc_nr;
	vmessage.COUNT = iop->io_nbytes;
	vmessage.POSITION = iop->io_position;
	vmessage.ADDRESS = iop->io_buf;
	result = (*do_rdwt)(&vmessage);
	if (result == 0) break;	/* EOF */
	if (result < 0) {
		iop->io_nbytes = result;
		if (iop->io_request & OPTIONAL_IO) break;  /* abort if opt */
	} else
		iop->io_nbytes -= result;
  }

  phys_copy(iovec_phys, user_iovec_phys,
	    (phys_bytes) nr_requests * sizeof iovec[0]);
  return(OK);
}
