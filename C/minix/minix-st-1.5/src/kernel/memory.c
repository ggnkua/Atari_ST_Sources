/* This file contains the drivers for the following special files:
 *     /dev/null	- null device (data sink)
 *     /dev/mem		- absolute memory
 *     /dev/kmem	- kernel virtual memory
 *     /dev/ram		- RAM disk
 *     /dev/port	- i/o ports ((CHIP == INTEL) only)
 *
 * The driver supports the following operations (using message format m2):
 *
 *    m_type      DEVICE    PROC_NR     COUNT    POSITION  ADRRESS
 * ----------------------------------------------------------------
 * |  DISK_READ | device  | proc nr |  bytes  |  offset | buf ptr |
 * |------------+---------+---------+---------+---------+---------|
 * | DISK_WRITE | device  | proc nr |  bytes  |  offset | buf ptr |
 * |------------+---------+---------+---------+---------+---------|
 * | DISK_IOCTL | device  |         |  blocks | ram org |         |
 * ----------------------------------------------------------------
 * |SCATTERED_IO| device  | proc nr | requests|         | iov ptr |
 * ----------------------------------------------------------------
 *  
 *
 * The file contains one entry point:
 *
 *   mem_task:	main entry when system is brought up
 *
 */

#include "kernel.h"
#include <minix/callnr.h>
#include <minix/com.h>

#ifdef PORT_DEV
#define NR_RAMS            5	/* number of RAM-type devices */
#else
#define NR_RAMS            4
#endif
PRIVATE message mess;		/* message buffer */
PRIVATE phys_bytes ram_origin[NR_RAMS];	/* origin of each RAM disk  */
PRIVATE phys_bytes ram_limit[NR_RAMS];	/* limit of RAM disk per minor dev. */

FORWARD int do_mem();
FORWARD int do_setup();

/*===========================================================================*
 *				mem_task				     * 
 *===========================================================================*/
PUBLIC void mem_task()
{
/* Main program of the memory task. */

  int r, caller, proc_nr;

  /* Initialize this task. */
  ram_origin[KMEM_DEV] = numap(SYSTASK, (vir_bytes) 0, (vir_bytes) 1);
  ram_limit[KMEM_DEV] = ((phys_bytes) sizes[1] << CLICK_SHIFT) +
                        ram_origin[KMEM_DEV];
#if (CHIP == INTEL)
  if (!protected_mode)
	ram_limit[MEM_DEV] = 0x100000;	/* above 1M em_xfer word count fails */
  else
	ram_limit[MEM_DEV] = 0x1000000;	/* above 16M not mapped on 386 */
  ram_limit[PORT_DEV] = 0x10000;
#else
#if (CHIP == M68000)
  ram_limit[MEM_DEV] = MEM_BYTES;
#else
#error /* memory limit not set up */
#endif
#endif

  /* Here is the main loop of the memory task.  It waits for a message, carries
   * it out, and sends a reply.
   */
  while (TRUE) {
	/* First wait for a request to read or write. */
	receive(ANY, &mess);
	if (mess.m_source < 0)
		panic("mem task got message from ", mess.m_source);
	caller = mess.m_source;
	proc_nr = mess.PROC_NR;

	/* Now carry out the work.  It depends on the opcode. */
	switch(mess.m_type) {
	    case DISK_READ:	r = do_mem(&mess);	break;
	    case DISK_WRITE:	r = do_mem(&mess);	break;
	    case SCATTERED_IO:	r = do_vrdwt(&mess, do_mem); break;
	    case DISK_IOCTL:	r = do_setup(&mess);	break;
	    default:		r = EINVAL;		break;
	}

	/* Finally, prepare and send the reply message. */
	mess.m_type = TASK_REPLY;
	mess.REP_PROC_NR = proc_nr;
	mess.REP_STATUS = r;
	send(caller, &mess);
  }
}


/*===========================================================================*
 *				do_mem					     * 
 *===========================================================================*/
PRIVATE int do_mem(m_ptr)
register message *m_ptr;	/* pointer to read or write message */
{
/* Read or write /dev/null, /dev/mem, /dev/kmem, /dev/ram or /dev/port. */

  int device, count, endport, port, portval;
  phys_bytes mem_phys, user_phys;

  /* Get minor device number and check for /dev/null. */
  device = m_ptr->DEVICE;
  if (device < 0 || device >= NR_RAMS) return(ENXIO);	/* bad minor device */
  if (device==NULL_DEV) return(m_ptr->m_type == DISK_READ ? 0 : m_ptr->COUNT);

  /* Set up 'mem_phys' for /dev/mem, /dev/kmem, or /dev/ram. */
  if (m_ptr->POSITION < 0) return(ENXIO);
  mem_phys = ram_origin[device] + m_ptr->POSITION;
  if (mem_phys >= ram_limit[device]) return(0);
  count = m_ptr->COUNT;
  if(mem_phys + count > ram_limit[device]) count = ram_limit[device] - mem_phys;

  /* Determine address where data is to go or to come from. */
  user_phys = numap(m_ptr->PROC_NR, (vir_bytes) m_ptr->ADDRESS,
		    (vir_bytes) count);
  if (user_phys == 0) return(E_BAD_ADDR);

#ifdef PORT_DEV
  /* Do special case of /dev/port. */
  if (device == PORT_DEV) {
	port = mem_phys;
	mem_phys = umap(proc_ptr, D, (vir_bytes) &portval, (vir_bytes) 1);
	for (endport = port + count; port != endport; ++port) {
		if (m_ptr->m_type == DISK_READ) {
			portval = in_byte(port);
			phys_copy(mem_phys, user_phys++, (phys_bytes) 1);
		} else {
			phys_copy(user_phys++, mem_phys, (phys_bytes) 1);
			out_byte(port, portval);
		}
	}
	return(count);
  }
#endif

  /* Copy the data. */
  if (m_ptr->m_type == DISK_READ)
	phys_copy(mem_phys, user_phys, (long) count);
  else
	phys_copy(user_phys, mem_phys, (long) count);
  return(count);
}


/*===========================================================================*
 *				do_setup				     * 
 *===========================================================================*/
PRIVATE int do_setup(m_ptr)
message *m_ptr;			/* pointer to read or write message */
{
/* Set parameters for one of the disk RAMs. */

  int device;

  device = m_ptr->DEVICE;
  if (device != RAM_DEV) return(ENXIO);	/* bad minor device */
  ram_origin[device] = m_ptr->POSITION;
  ram_limit[device] = m_ptr->POSITION + (long) m_ptr->COUNT * BLOCK_SIZE;
  return(OK);
}
