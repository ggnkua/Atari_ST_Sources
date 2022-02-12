/*
 * This file contains special code dealing with the DMA interface
 * on the Atari ST.
 *
 * Although the DMA circuitry requires some special treatment
 * for the peripheral devices which make use of the ST's DMA feature
 * the DMA code constitutes not a usual Minix hardware process.
 * Nevertheless all devices using DMA need mutually exclusive
 * access and can follow some standard pattern which will be
 * provided in this file.
 *
 * The file contains the following entry points:
 *
 *	dmagrab:	ensure exclusive access to the DMA circuitry
 *	dmafree:	free exclusive access to the DMA circuitry
 *	dmaint:		DMA interrupt routine, switches to the current driver
 *	dmaaddr:	specify 24 bit RAM address
 *	dmardat:	set dma_mode and read word from dma_data
 *	dmawdat:	set dma_mode and write word to dma_data
 *	dmawcmd:	set dma_mode and write word to dma_data in one access
 *	dmacomm:	like dmawdat, but first toggle WRBIT
 */

#include "kernel.h"
#if (MACHINE == ATARI)
#include <minix/com.h>
#include "proc.h"

#include "staddr.h"
#include "stdma.h"

#define	ASSERT(x)	if (!(x)) panic("dma: ASSERT(x) failed",NO_NUM);

PRIVATE	int	qhead;
PRIVATE	int	qlink[NR_TASKS];

#define	QNEXT(p)	qlink[(p) + NR_TASKS]

PRIVATE	dmaint_t xxxint;

/*===========================================================================*
 *				dmagrab					     *
 *===========================================================================*/
PUBLIC void dmagrab(p, func)
int p;
dmaint_t func;
{
  message	m;
  register int	q;

  ASSERT(p >= -NR_TASKS && p < HARDWARE);
  ASSERT(QNEXT(p) == 0);
  if (q = qhead) {
	while (QNEXT(q))
		q = QNEXT(q);
	QNEXT(q) = p;
	receive(q, &m);
	ASSERT(qhead == p);
  } else
	qhead = p;
  xxxint = func;		/* grab DMA interrupts */
}

/*===========================================================================*
 *				dmafree					     *
 *===========================================================================*/
PUBLIC void dmafree(p)
int	p;
{
  message	m;

  xxxint = (dmaint_t)0;	/* no more DMA interrupts */
  ASSERT(qhead == p);
  qhead = QNEXT(p);
  QNEXT(p) = 0;
  if (qhead)
	send(qhead, &m);
}

/*===========================================================================*
 *				dmaint					     *
 *===========================================================================*/
PUBLIC void dmaint()
{
  if (xxxint)
	(*xxxint)();
  else
	printf("DMA interrupt discarded\n");
}

/*===========================================================================*
 *				dmaaddr					     *
 *===========================================================================*/
PUBLIC void dmaaddr(ad)
phys_bytes ad;
{
  DMA->dma_addr[AD_LOW ] = (char)(ad     );
  DMA->dma_addr[AD_MID ] = (char)(ad >> 8);
  DMA->dma_addr[AD_HIGH] = (char)(ad >>16);
}

/*===========================================================================*
 *				dmaxxxx					     *
 *===========================================================================*/
PUBLIC int dmardat(mode, delay)
int mode;
int delay;
{
  DMA->dma_mode = mode;
  while (--delay >= 0);
  return(DMA->dma_data);
}

PUBLIC void dmawdat(mode, data, delay)
int mode;
int data;
int delay;
{
  DMA->dma_mode = mode;
  while (--delay >= 0);
  DMA->dma_data = data;
}

PUBLIC void dmawcmd(data, mode)
int data;
unsigned mode;
{
/* The dma register can only be written with one(!) long word access.
 * Convert the two short parameters into a longword before writing.
 */
  union { long lval; struct { short h; short l; } sval; } sl;

  sl.sval.h = data;
  sl.sval.l = mode;
  *((_VOLATILE long*)&DMA->dma_data) = sl.lval;
}

PUBLIC void dmacomm(mode, data, delay)
int mode;
int data;
int delay;
{
  int delay2 = delay;
  DMA->dma_mode = mode ^ WRBIT;
  while (--delay >= 0);
  DMA->dma_mode = mode;
  while (--delay2 >= 0);
  DMA->dma_data = data;
}

PUBLIC int dmastat(mode, delay)
int mode;
int delay;
{
  DMA->dma_mode = mode;
  while (--delay >= 0);
  return(DMA->dma_stat);
}
#endif
