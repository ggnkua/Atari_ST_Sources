/* This file performs shadowing, a solution for the fork() problem
 * on machines that have no relocation hardware.
 */

#include "kernel.h"
#if (SHADOWING == 1)
#include <minix/callnr.h>
#include <minix/com.h>
#include "proc.h"

#define	TRACE(x)	/* x */

PRIVATE int	flipwait;

#define	FLIPWAIT	5	/* units of 100ms between flips */

/*===========================================================================*
 *				mkshadow				     * 
 *===========================================================================*/

PUBLIC void mkshadow(p, c2)
register struct proc *p;
phys_clicks c2;
{
  phys_clicks c1, nc;

  TRACE(printf("mkshadow(%d): ",p->p_pid));
  c1 = p->p_map[D].mem_phys;
  if (p->p_shadow)
	c1 = p->p_shadow;	/* father can be shadowed! */
  p->p_shadow = c2;
  nc = p->p_map[S].mem_phys - p->p_map[D].mem_phys + p->p_map[S].mem_len;
  copyclicks(c1, c2, nc);
  flipwait = FLIPWAIT;
}

/*===========================================================================*
 *				rmshadow				     * 
 *===========================================================================*/

PUBLIC void rmshadow(p, basep, sizep)
register struct proc *p;
phys_clicks *basep, *sizep;
{
/* Three possibilities:
 *   1. p is a shadow
 *   2. p is real, but has one or more shadows
 *   3. p is real without shadows
 */
  register struct proc *q;
  register phys_clicks nc;

  TRACE(printf("rmshadow(%d)->",p->p_pid));
  nc = p->p_map[S].mem_phys - p->p_map[D].mem_phys + p->p_map[S].mem_len;
  if (p->p_shadow) {
	*basep = p->p_shadow;
	*sizep = nc;
	p->p_shadow = 0;
	TRACE(printf("(%x,%x)\n",*basep,*sizep));
	return;
  }
  /*
   * search for shadows
   */
  for (q = &proc[NR_TASKS+LOW_USER]; q < &proc[NR_TASKS+NR_PROCS]; q++) {
	if (q->p_priority == PPRI_NONE)
		continue;
	if (q == p)
		continue;
	if (q->p_map[D].mem_phys != p->p_map[D].mem_phys)
		continue;
	if (q->p_shadow == 0)
		panic("no shadow?", NO_NUM);
	if (q->p_physio)
		panic("rmshadow: cannot handle physio shadows", NO_NUM);
	*basep = q->p_shadow;
	*sizep = nc;
	TRACE(printf("(%x,%x): ",*basep,*sizep));
	copyclicks(q->p_shadow, p->p_map[D].mem_phys, nc);
	if (q->p_flags == 0)
		lock_unready(q);
	q->p_shadow = 0;
	if (q->p_flags == 0)
		lock_ready(q);
	return;
  }
  /*
   * normal unshadowed process image
   */
  *basep = p->p_map[T].mem_phys;
  *sizep = nc + p->p_map[T].mem_len;
  TRACE(printf("(%x,%x)\n",*basep,*sizep));
}

/*===========================================================================*
 *				unshadow				     * 
 *===========================================================================*/

PUBLIC void unshadow(p)
register struct proc *p;
{
  register struct proc *q;

  TRACE(printf("unshadow(%d): ",p->p_pid));
  if (flipwait) {
	flipwait--;
	return;
  }
  if (p->p_physio) {
	TRACE(printf("physio(%d)\n",p->p_pid));
	return;
  }
  /*
   * find owner of real memory slot: same mem_phys, no shadow
   */
  for (q = &proc[NR_TASKS+LOW_USER]; ; q++) {
	if (q == &proc[NR_TASKS+NR_PROCS]) {
#if (SHADOWING && ENABLE_SWAP)
		printf("only shadow(s)\n");
		return;
#else
		panic("only shadow(s)", NO_NUM);
#endif /* SHADOWING && ENABLE_SWAP */
	}
	if (q->p_priority == PPRI_NONE)
		continue;
	if (q == p)
		continue;
	if (q->p_map[D].mem_phys != p->p_map[D].mem_phys)
		continue;
	if (q->p_shadow == 0)
		break;
  }
  if (q->p_physio) {
	TRACE(printf("physio(%d)\n",q->p_pid));
	return;
  }
  /*
   * exchange process images
   */
  flipclicks(
	p->p_shadow,
	q->p_map[D].mem_phys,
	q->p_map[S].mem_phys - q->p_map[D].mem_phys + q->p_map[S].mem_len
  );
  flipwait = FLIPWAIT;
  /*
   * give ownership of shadow to q, changing queues if appropriate
   */
  lock_unready(p);
  if (q->p_flags == 0)
	lock_unready(q);
  q->p_shadow = p->p_shadow;
  p->p_shadow = 0;
  lock_ready(p);
  if (q->p_flags == 0)
	lock_ready(q);
  p->p_nflips++;
  q->p_nflips++;
}
#endif
