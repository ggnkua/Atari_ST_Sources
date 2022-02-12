/* General constants used by the kernel. */

#if (CHIP == INTEL)

#define K_STACK_BYTES   1024	/* how many bytes for the kernel stack */

#define INIT_PSW      0x0200	/* initial psw */
#define INIT_TASK_PSW 0x1200	/* initial psw for tasks (with IOPL 1) */
#define TRACEBIT       0x100	/* OR this with psw in proc[] for tracing */
#define SETPSW(rp, new)	/* permits only certain bits to be set */ \
	((rp)->p_reg.psw = (rp)->p_reg.psw & ~0xCD5 | (new) & 0xCD5)

/* Initial sp for mm, fs and init.
 *	2 bytes for short jump
 *	2 bytes unused
 *	3 words for init_org[] used by fs only
 *	3 words for real mode debugger trap (actually needs 1 more)
 *	3 words for save and restart temporaries
 *	3 words for interrupt
 * Leave no margin, to flush bugs early.
 */
#define INIT_SP (2 + 2 + 3 * 2 + 3 * 2 + 3 * 2 + 3 * 2)

#define HCLICK_SHIFT       4	/* log2 of HCLICK_SIZE */
#define HCLICK_SIZE       16	/* hardware segment conversion magic */
#if CLICK_SIZE >= HCLICK_SIZE
#define click_to_hclick(n) ((n) << (CLICK_SHIFT - HCLICK_SHIFT))
#else
#define click_to_hclick(n) ((n) >> (HCLICK_SHIFT - CLICK_SHIFT))
#endif
#define hclick_to_physb(n) ((phys_bytes) (n) << HCLICK_SHIFT)
#define physb_to_hclick(n) ((n) >> HCLICK_SHIFT)

/* Interrupt vectors defined/reserved by processor. */
#define DIVIDE_VECTOR      0	/* divide error */
#define DEBUG_VECTOR       1	/* single step (trace) */
#define NMI_VECTOR         2	/* non-maskable interrupt */
#define BREAKPOINT_VECTOR  3	/* software breakpoint */
#define OVERFLOW_VECTOR    4	/* from INTO */

/* Fixed system call vector. */
#define SYS_VECTOR        32	/* system calls are made with int SYSVEC */
#define SYS386_VECTOR     33	/* except 386 system calls use this */
#define LEVEL0_VECTOR     34	/* for execution of a function at level 0 */

/* Suitable irq bases for hardware interrupts.  Reprogram the 8259(s) from
 * the PC BIOS defaults since the BIOS doesn't respect all the processor's
 * reserved vectors (0 to 31).
 */
#define BIOS_IRQ0_VEC   0x08	/* base of IRQ0-7 vectors used by BIOS */
#define BIOS_IRQ8_VEC   0x70	/* base of IRQ8-15 vectors used by BIOS */
#define IRQ0_VECTOR     0x50	/* nice vectors to relocate IRQ0-7 to */
#define IRQ8_VECTOR     0x70	/* no need to move IRQ8-15 */

/* Hardware interrupt numbers. */
#define NR_IRQ_VECTORS    16
#define CLOCK_IRQ          0
#define KEYBOARD_IRQ       1
#define CASCADE_IRQ        2	/* cascade enable for 2nd AT controller */
#define ETHER_IRQ          3	/* default ethernet interrupt vector */
#define SECONDARY_IRQ      3	/* RS232 interrupt vector for port 2 */
#define RS232_IRQ          4	/* RS232 interrupt vector for port 1 */
#define XT_WINI_IRQ        5	/* xt winchester */
#define FLOPPY_IRQ         6	/* floppy disk */
#define PRINTER_IRQ        7
#define AT_WINI_IRQ       14	/* at winchester */

/* Interrupt number to hardware vector. */
#define BIOS_VECTOR(irq)	\
	(((irq) < 8 ? BIOS_IRQ0_VEC : BIOS_IRQ8_VEC) + ((irq) & 0x07))
#define VECTOR(irq)	\
	(((irq) < 8 ? IRQ0_VECTOR : IRQ8_VECTOR) + ((irq) & 0x07))

/* BIOS hard disk parameter vectors. */
#define WINI_0_PARM_VEC 0x41
#define WINI_1_PARM_VEC 0x46

/* 8259A interrupt controller ports. */
#define INT_CTL         0x20	/* I/O port for interrupt controller */
#define INT_CTLMASK     0x21	/* setting bits in this port disables ints */
#define INT2_CTL        0xA0	/* I/O port for second interrupt controller */
#define INT2_CTLMASK    0xA1	/* setting bits in this port disables ints */

/* Magic numbers for interrupt controller. */
#define ENABLE          0x20	/* code used to re-enable after an interrupt */

/* Sizes of memory tables. */
#define NR_MEMS            8	/* number of chunks of memory */

/* Miscellaneous ports. */
#define PCR		0x65	/* Planar Control Register */
#define PORT_B          0x61	/* I/O port for 8255 port B (kbd, beeper...) */
#define TIMER0          0x40	/* I/O port for timer channel 0 */
#define TIMER2          0x42	/* I/O port for timer channel 2 */
#define TIMER_MODE      0x43	/* I/O port for timer mode control */

#endif /* (CHIP == INTEL) */

#if (CHIP == M68000)

#define K_STACK_BYTES   1024	/* how many bytes for the kernel stack */

/* Sizes of memory tables. */
#define NR_MEMS            2	/* number of chunks of memory */

/* p_reg contains: d0-d7, a0-a6,   in that order. */
#define NR_REGS           15	/* number of general regs in each proc slot */
 
#define TRACEBIT      0x8000	/* or this with psw in proc[] for tracing */
#define SETPSW(rp, new)		/* permits only certain bits to be set */ \
	((rp)->p_reg.psw = (rp)->p_reg.psw & ~0xFF | (new) & 0xFF)
 
#define MEM_BYTES  0xffffffff	/* memory size for /dev/mem */
 
#ifdef __ACK__
#define FSTRUCOPY
#endif

#endif /* (CHIP == M68000) */

/* The following items pertain to the scheduling queues. */
#define TASK_Q             0	/* ready tasks are scheduled via queue 0 */
#define SERVER_Q           1	/* ready servers are scheduled via queue 1 */
#define USER_Q             2	/* ready users are scheduled via queue 2 */

#if (MACHINE == ATARI)
#define SHADOW_Q           3	/* runnable, but shadowed processes */
#define NQ                 4	/* # of scheduling queues */
#else
#define NQ                 3	/* # of scheduling queues */
#endif

/* Env_parse() return values. */
#define EP_UNSET	0	/* variable not set */
#define EP_OFF		1	/* var = off */
#define EP_ON		2	/* var = on (or field left blank) */
#define EP_SET		3	/* var = 1:2:3 (nonblank field) */

/* To translate an address in kernel space to a physical address.  This is
 * the same as umap(proc_ptr, D, vir, sizeof(*vir)), but a lot less costly.
 */
#define vir2phys(vir)	(data_base + (vir_bytes) (vir))

#define printf        printk	/* the kernel really uses printk, not printf */
