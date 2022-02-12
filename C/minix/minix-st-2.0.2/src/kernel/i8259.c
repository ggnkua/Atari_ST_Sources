/* This file contains routines for initializing the 8259 interrupt controller:
 *	get_irq_handler: address of handler for a given interrupt
 *	put_irq_handler: register an interrupt handler
 *	intr_init:	initialize the interrupt controller(s)
 */

#include "kernel.h"

#define ICW1_AT         0x11	/* edge triggered, cascade, need ICW4 */
#define ICW1_PC         0x13	/* edge triggered, no cascade, need ICW4 */
#define ICW1_PS         0x19	/* level triggered, cascade, need ICW4 */
#define ICW4_AT         0x01	/* not SFNM, not buffered, normal EOI, 8086 */
#define ICW4_PC         0x09	/* not SFNM, buffered, normal EOI, 8086 */

FORWARD _PROTOTYPE( int spurious_irq, (int irq) );

#if _WORD_SIZE == 2
typedef _PROTOTYPE( void (*vecaddr_t), (void) );

FORWARD _PROTOTYPE( void set_vec, (int vec_nr, vecaddr_t addr) );

PRIVATE vecaddr_t int_vec[] = {
  int00, int01, int02, int03, int04, int05, int06, int07,
};

PRIVATE vecaddr_t irq_vec[] = {
  hwint00, hwint01, hwint02, hwint03, hwint04, hwint05, hwint06, hwint07,
  hwint08, hwint09, hwint10, hwint11, hwint12, hwint13, hwint14, hwint15,
};
#else
#define set_vec(nr, addr)	((void)0)
#endif


/*==========================================================================*
 *				intr_init				    *
 *==========================================================================*/
PUBLIC void intr_init(mine)
int mine;
{
/* Initialize the 8259s, finishing with all interrupts disabled.  This is
 * only done in protected mode, in real mode we don't touch the 8259s, but
 * use the BIOS locations instead.  The flag "mine" is set if the 8259s are
 * to be programmed for Minix, or to be reset to what the BIOS expects.
 */

  int i;

  lock();
  if (protected_mode) {
	/* The AT and newer PS/2 have two interrupt controllers, one master,
	 * one slaved at IRQ 2.  (We don't have to deal with the PC that
	 * has just one controller, because it must run in real mode.)
	 */
	out_byte(INT_CTL, ps_mca ? ICW1_PS : ICW1_AT);
	out_byte(INT_CTLMASK, mine ? IRQ0_VECTOR : BIOS_IRQ0_VEC);
							/* ICW2 for master */
	out_byte(INT_CTLMASK, (1 << CASCADE_IRQ));	/* ICW3 tells slaves */
	out_byte(INT_CTLMASK, ICW4_AT);
	out_byte(INT_CTLMASK, ~(1 << CASCADE_IRQ));	/* IRQ 0-7 mask */
	out_byte(INT2_CTL, ps_mca ? ICW1_PS : ICW1_AT);
	out_byte(INT2_CTLMASK, mine ? IRQ8_VECTOR : BIOS_IRQ8_VEC);
							/* ICW2 for slave */
	out_byte(INT2_CTLMASK, CASCADE_IRQ);		/* ICW3 is slave nr */
	out_byte(INT2_CTLMASK, ICW4_AT);
	out_byte(INT2_CTLMASK, ~0);			/* IRQ 8-15 mask */

	/* Copy the BIOS vectors from the BIOS to the Minix location, so we
	 * can still make BIOS calls without reprogramming the i8259s.
	 */
#if IRQ0_VECTOR != BIOS_IRQ0_VEC
	phys_copy(BIOS_VECTOR(0) * 4L, VECTOR(0) * 4L, 8 * 4L);
#endif
#if IRQ8_VECTOR != BIOS_IRQ8_VEC
	phys_copy(BIOS_VECTOR(8) * 4L, VECTOR(8) * 4L, 8 * 4L);
#endif
  } else {
	/* Use the BIOS interrupt vectors in real mode.  We only reprogram the
	 * exceptions here, the interrupt vectors are reprogrammed on demand.
	 * SYS_VECTOR is the Minix system call for message passing.
	 */
	for (i = 0; i < 8; i++) set_vec(i, int_vec[i]);
	set_vec(SYS_VECTOR, s_call);
  }

  /* Initialize the table of interrupt handlers. */
  for (i = 0; i < NR_IRQ_VECTORS; i++) irq_table[i] = spurious_irq;
}

/*=========================================================================*
 *				spurious_irq				   *
 *=========================================================================*/
PRIVATE int spurious_irq(irq)
int irq;
{
/* Default interrupt handler.  It complains a lot. */

  if (irq < 0 || irq >= NR_IRQ_VECTORS)
	panic("invalid call to spurious_irq", irq);

  printf("spurious irq %d\n", irq);

  return 1;	/* Reenable interrupt */
}

/*=========================================================================*
 *				put_irq_handler				   *
 *=========================================================================*/
PUBLIC void put_irq_handler(irq, handler)
int irq;
irq_handler_t handler;
{
/* Register an interrupt handler. */

  if (irq < 0 || irq >= NR_IRQ_VECTORS)
	panic("invalid call to put_irq_handler", irq);

  if (irq_table[irq] == handler)
	return;		/* extra initialization */

  if (irq_table[irq] != spurious_irq)
	panic("attempt to register second irq handler for irq", irq);

  disable_irq(irq);
  if (!protected_mode) set_vec(BIOS_VECTOR(irq), irq_vec[irq]);
  irq_table[irq]= handler;
  irq_use |= 1 << irq;
}


#if _WORD_SIZE == 2
/*===========================================================================*
 *                                   set_vec                                 *
 *===========================================================================*/
PRIVATE void set_vec(vec_nr, addr)
int vec_nr;			/* which vector */
vecaddr_t addr;			/* where to start */
{
/* Set up a real mode interrupt vector. */

  u16_t vec[2];

  /* Build the vector in the array 'vec'. */
  vec[0] = (u16_t) addr;
  vec[1] = (u16_t) physb_to_hclick(code_base);

  /* Copy the vector into place. */
  phys_copy(vir2phys(vec), vec_nr * 4L, 4L);
}
#endif /* _WORD_SIZE == 2 */
