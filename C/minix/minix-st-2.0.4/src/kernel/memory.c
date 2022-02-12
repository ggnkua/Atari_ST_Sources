/* This file contains the device dependent part of the drivers for the
 * following special files:
 *     /dev/null	- null device (data sink)
 *     /dev/mem		- absolute memory
 *     /dev/kmem	- kernel virtual memory
 *     /dev/ram		- RAM disk
 *     /dev/zero	- zeroes
 *
 * The file contains one entry point:
 *
 *   mem_task:	main entry when system is brought up
 *
 *  Changes:
 *	20 Apr  1992 by Kees J. Bot: device dependent/independent split
 */

#include "kernel.h"
#include "driver.h"
#include <sys/ioc_memory.h>
#if (CHIP == INTEL) && ENABLE_USERBIOS
#include "protect.h"
#include <ibm/int86.h>
#endif

#define NR_RAMS            5	/* number of RAM-type devices */

PRIVATE struct device m_geom[NR_RAMS];	/* Base and size of each RAM disk */
PRIVATE int m_device;		/* current device */

FORWARD _PROTOTYPE( struct device *m_prepare, (int device) );
FORWARD _PROTOTYPE( int m_transfer, (int proc_nr, int opcode, off_t position,
					iovec_t *iov, unsigned nr_req) );
FORWARD _PROTOTYPE( int m_do_open, (struct driver *dp, message *m_ptr) );
FORWARD _PROTOTYPE( void m_init, (void) );
FORWARD _PROTOTYPE( int m_ioctl, (struct driver *dp, message *m_ptr) );
FORWARD _PROTOTYPE( void m_geometry, (struct partition *entry) );


/* Entry points to this driver. */
PRIVATE struct driver m_dtab = {
  no_name,	/* current device's name */
  m_do_open,	/* open or mount */
  do_nop,	/* nothing on a close */
  m_ioctl,	/* specify ram disk geometry */
  m_prepare,	/* prepare for I/O on a given minor device */
  m_transfer,	/* do the I/O */
  nop_cleanup,	/* no need to clean up */
  m_geometry,	/* memory device "geometry" */
};


/*===========================================================================*
 *				mem_task				     *
 *===========================================================================*/
PUBLIC void mem_task()
{
  m_init();
  driver_task(&m_dtab);
}


/*===========================================================================*
 *				m_prepare				     *
 *===========================================================================*/
PRIVATE struct device *m_prepare(device)
int device;
{
/* Prepare for I/O on a device. */

  if (device < 0 || device >= NR_RAMS) return(NIL_DEV);
  m_device = device;

  return(&m_geom[device]);
}


/*===========================================================================*
 *				m_transfer				     *
 *===========================================================================*/
PRIVATE int m_transfer(proc_nr, opcode, position, iov, nr_req)
int proc_nr;			/* process doing the request */
int opcode;			/* DEV_GATHER or DEV_SCATTER */
off_t position;			/* offset on device to read or write */
iovec_t *iov;			/* pointer to read or write request vector */
unsigned nr_req;		/* length of request vector */
{
/* Read or write /dev/null, /dev/mem, /dev/kmem, or /dev/ram. */

  int device;
  phys_bytes mem_phys, user_phys;
  unsigned count;
  struct device *dv;
  unsigned long dv_size;
  phys_bytes user_base = proc_vir2phys(proc_addr(proc_nr), 0);
  register unsigned i;
  register char *p;

  /* Get minor device number and check for /dev/null. */
  device = m_device;
  dv = &m_geom[device];
  dv_size = cv64ul(dv->dv_size);

  while (nr_req > 0) {
	user_phys = user_base + iov->iov_addr;
	count = iov->iov_size;

	switch (device) {
	case NULL_DEV:
		if (opcode == DEV_GATHER) return(OK);	/* Always at EOF. */
		break;
	case ZERO_DEV:
		if (opcode == DEV_SCATTER) return(iov->iov_size = EIO);
		p = (char *) user_phys;
		i = count;
		if ((long)p & 1) {
			*p++ = '\0';
			i--;
		}
		if (i >= 4) {
			register long *lp = (long *) p;
			while (i > 3) {
				*lp++ = 0;
				i -= 4;
			}
			p = (char *) lp;
		}
		while (i > 0) {
			*p++ = '\0';
			i--;
		}
		break;
	default:
		/* /dev/mem, /dev/kmem, /dev/ram: Check for EOF */
		if (position >= dv_size) return(OK);
		if (position + count > dv_size) count = dv_size - position;
		mem_phys = cv64ul(dv->dv_base) + position;

		/* Copy the data. */
		if (opcode == DEV_GATHER) {
			phys_copy(mem_phys, user_phys, (phys_bytes) count);
		} else {
			phys_copy(user_phys, mem_phys, (phys_bytes) count);
		}
	}

	/* Book the number of bytes transferred. */
	position += count;
	iov->iov_addr += count;
  	if ((iov->iov_size -= count) == 0) { iov++; nr_req--; }
  }
  return(OK);
}


/*============================================================================*
 *				m_do_open				      *
 *============================================================================*/
PRIVATE int m_do_open(dp, m_ptr)
struct driver *dp;
message *m_ptr;
{
/* Check device number on open.  Give I/O privileges to a process opening
 * /dev/mem or /dev/kmem.
 */

  if (m_prepare(m_ptr->DEVICE) == NIL_DEV) return(ENXIO);

#if (CHIP == INTEL)
  if (m_device == MEM_DEV || m_device == KMEM_DEV)
	enable_iop(proc_addr(m_ptr->PROC_NR));
#endif

  return(OK);
}


/*===========================================================================*
 *				m_init					     *
 *===========================================================================*/
PRIVATE void m_init()
{
  /* Initialize this task. */
  extern int end;

  m_geom[KMEM_DEV].dv_base = cvul64(vir2phys(0));
  m_geom[KMEM_DEV].dv_size = cvul64(vir2phys(&end));

#if (CHIP == INTEL)
  if (!protected_mode) {
	m_geom[MEM_DEV].dv_size =   cvul64(0x100000); /* 1M for 8086 systems */
  } else {
#if _WORD_SIZE == 2
	m_geom[MEM_DEV].dv_size =  cvul64(0x1000000); /* 16M for 286 systems */
#else
	m_geom[MEM_DEV].dv_size = cvul64(0xFFFFFFFF); /* 4G-1 for 386 systems */
#endif
  }
#else /* !(CHIP == INTEL) */
#if (CHIP == M68000)
  m_geom[MEM_DEV].dv_size = cvul64(MEM_BYTES);
#else /* !(CHIP == M68000) */
#error /* memory limit not set up */
#endif /* !(CHIP == M68000) */
#endif /* !(CHIP == INTEL) */
}


/*===========================================================================*
 *				m_ioctl					     *
 *===========================================================================*/
PRIVATE int m_ioctl(dp, m_ptr)
struct driver *dp;
message *m_ptr;			/* pointer to read or write message */
{
/* Set parameters for one of the RAM disks. */

  static struct psinfo psinfo = { NR_TASKS, NR_PROCS, (vir_bytes) proc, 0, 0 };
  struct device *dv;
  struct proc *pp;

  if ((dv = m_prepare(m_ptr->DEVICE)) == NIL_DEV) return(ENXIO);
  pp = proc_addr(m_ptr->PROC_NR);

  switch (m_ptr->REQUEST) {
    case MIOCRAMSIZE: {
	/* FS sets the RAM disk size. */
	unsigned long bytesize;
	unsigned base, size;
	struct memory *memp;

	if (m_ptr->PROC_NR != FS_PROC_NR) return(EPERM);

	bytesize = m_ptr->POSITION * BLOCK_SIZE;
	size = (bytesize + CLICK_SIZE-1) >> CLICK_SHIFT;

	/* Find a memory chunk big enough for the RAM disk. */
	memp= &mem[NR_MEMS];
	while ((--memp)->size < size) {
		if (memp == mem) panic("Not enough memory for RAM disk",NO_NUM);
	}
	memp->size -= size;
	base = memp->base + memp->size;

	dv->dv_base = cvul64((u32_t) base << CLICK_SHIFT);
	dv->dv_size = cvul64(bytesize);
	break;
    }
    case MIOCSPSINFO: {
	/* MM or FS set the address of their process table. */
	phys_bytes psinfo_phys;

	if (m_ptr->PROC_NR == MM_PROC_NR) {
		psinfo.mproc = (vir_bytes) m_ptr->ADDRESS;
	} else
	if (m_ptr->PROC_NR == FS_PROC_NR) {
		psinfo.fproc = (vir_bytes) m_ptr->ADDRESS;
	} else {
		return(EPERM);
	}
	break;
    }
    case MIOCGPSINFO: {
	/* The ps program wants the process table addresses. */
	if (vir_copy(MEM, (vir_bytes) &psinfo,
		m_ptr->PROC_NR, (vir_bytes) m_ptr->ADDRESS,
		sizeof(psinfo)) != OK) return(EFAULT);
	break;
    }
#if (CHIP == INTEL) && ENABLE_USERBIOS
    case MIOCINT86: {
	/* Execute a BIOS call for a user process. */
	phys_bytes user_phys, buf_phys;
	struct mio_int86 mint86;

	if (m_device != MEM_DEV && m_device != KMEM_DEV) return(ENOTTY);

	user_phys = umap(pp, D, (vir_bytes) m_ptr->ADDRESS, sizeof(mint86));
	if (user_phys == 0) return(EFAULT);
	phys_copy(user_phys, vir2phys(&mint86), sizeof(mint86));
	buf_phys = 0;

	if (mint86.seg == 0) {
		/* Client doesn't yet know where my buffer is... */
		mint86.off = tmp_phys % HCLICK_SIZE;
		mint86.seg = tmp_phys / HCLICK_SIZE;
		mint86.buf = NULL;
		mint86.len = DMA_BUF_SIZE;
	} else {
		if (mint86.buf != NULL) {
			/* Copy user data buffer to my buffer. */
			if (mint86.len > DMA_BUF_SIZE) return(EINVAL);
			buf_phys = umap(pp, D, (vir_bytes) mint86.buf,
								mint86.len);
			if (buf_phys == 0) return(EFAULT);
			phys_copy(buf_phys, tmp_phys, mint86.len);
		}

		/* Execute the interrupt. */
		reg86 = mint86.reg86;
		level0(int86);
		mint86.reg86 = reg86;
	}

	/* Copy the results back. */
	phys_copy(vir2phys(&mint86), user_phys, sizeof(mint86));
	if (buf_phys != 0) phys_copy(tmp_phys, buf_phys, mint86.len);
	break;
    }
    case MIOCGLDT86:
    case MIOCSLDT86: {
	/* Get or set an LDT entry of this process. */
	phys_bytes user_phys;
	struct mio_ldt86 mldt;

	if (m_device != MEM_DEV && m_device != KMEM_DEV) return(ENOTTY);

	user_phys = umap(pp, D, (vir_bytes) m_ptr->ADDRESS, sizeof(mldt));
	if (user_phys == 0) return(EFAULT);
	phys_copy(user_phys, vir2phys(&mldt), sizeof(mldt));

	if (!protected_mode || mldt.idx >= LDT_SIZE) return(ESRCH);

	if (m_ptr->REQUEST == MIOCGLDT86) {
		* (struct segdesc_s *) mldt.entry = pp->p_ldt[mldt.idx];
		phys_copy(vir2phys(&mldt), user_phys, sizeof(mldt));
	} else {
		pp->p_ldt[mldt.idx] = * (struct segdesc_s *) mldt.entry;
	}
	break;
    }
#endif /* CHIP == INTEL && ENABLE_USERBIOS */

    default:
  	return(do_diocntl(&m_dtab, m_ptr));
  }
  return(OK);
}


/*============================================================================*
 *				m_geometry				      *
 *============================================================================*/
PRIVATE void m_geometry(entry)
struct partition *entry;
{
  /* Memory devices don't have a geometry, but the outside world insists. */
  entry->cylinders = div64u(m_geom[m_device].dv_size, SECTOR_SIZE) / (64 * 32);
  entry->heads = 64;
  entry->sectors = 32;
}
