/* General constants used by the kernel. */

#if (CHIP == INTEL)

#define K_STACK_BYTES    512	/* how many bytes for the kernel stack */

#define INIT_PSW      0x0200	/* initial psw */
#define INIT_TASK_PSW 0x1200	/* initial psw for tasks (with IOPL 1) */
#define TRACEBIT       0x100	/* OR this with psw in proc[] for tracing */
#define SETBITS(rp, new)	/* permits only certain bits to be set */ \
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

#define ALIGNMENT	   4	/* align large items to a multiple of this */
#define VECTOR_BYTES     512	/* bytes of interrupt vectors to save */
#define VEC_TABLE_SEG      0	/* segment of vector table */

/* Interrupt vectors defined/reserved by processor. */
#define DIVIDE_VECTOR      0	/* divide error */
#define DEBUG_VECTOR       1	/* single step (trace) */
#define NMI_VECTOR         2	/* non-maskable interrupt */
#define BREAKPOINT_VECTOR  3	/* software breakpoint */
#define OVERFLOW_VECTOR    4	/* from INTO */

/* Fixed system call vector (the only software interrupt). */
#define SYS_VECTOR        32	/* system calls are made with int SYSVEC */
#define SYS386_VECTOR     33	/* except 386 system calls use this */

/* Suitable irq bases for hardware interrupts.  Reprogram the 8259(s) from
 * the PC BIOS defaults since the BIOS doesn't respect all the processor's
 * reserved vectors (0 to 31).
 */
#define BIOS_IRQ0_VEC   0x08	/* base of IRQ0-7 vectors used by BIOS */
#define BIOS_IRQ8_VEC   0x70	/* base of IRQ8-15 vectors used by BIOS */
#define IRQ0_VECTOR     0x28	/* more or less arbitrary, but > SYS_VECTOR */
#define IRQ8_VECTOR     0x30 	/* together for simplicity */

#define WINI_0_PARM_VEC 0x41	/* parameters for hard disk 1 */
#define WINI_1_PARM_VEC 0x46	/* parameters for hard disk 2 */

/* Hardware interrupt numbers. */
#define CLOCK_IRQ          0
#define KEYBOARD_IRQ       1
#define CASCADE_IRQ        2	/* cascade enable for 2nd AT controller */
#define ETHER_IRQ          3	/* ethernet interrupt vector */
#define SECONDARY_IRQ      3	/* RS232 interrupt vector for port 2 */
#define RS232_IRQ          4	/* RS232 interrupt vector for port 1 */
#define XT_WINI_IRQ        5	/* xt winchester */
#define FLOPPY_IRQ         6	/* floppy disk */
#define PRINTER_IRQ        7
#define AT_WINI_IRQ       14	/* at winchester */
#define PS_KEYB_IRQ        9	/* keyboard interrupt vector for PS/2 */

/* Hardware vector numbers. */
#define CLOCK_VECTOR     ((CLOCK_IRQ & 0x07) + IRQ0_VECTOR)
#define KEYBOARD_VECTOR  ((KEYBOARD_IRQ & 0x07) + IRQ0_VECTOR)
#define ETHER_VECTOR     ((ETHER_IRQ & 0x07) + IRQ0_VECTOR)
#define SECONDARY_VECTOR ((SECONDARY_IRQ & 0x07) + IRQ0_VECTOR)
#define RS232_VECTOR     ((RS232_IRQ & 0x07) + IRQ0_VECTOR)
#define XT_WINI_VECTOR   ((XT_WINI_IRQ & 0x07) + IRQ0_VECTOR)
#define FLOPPY_VECTOR    ((FLOPPY_IRQ & 0x07) + IRQ0_VECTOR)
#define PRINTER_VECTOR   ((PRINTER_IRQ & 0x07) + IRQ0_VECTOR)
#define AT_WINI_VECTOR   ((AT_WINI_IRQ & 0x07) + IRQ8_VECTOR)
#define PS_KEYB_VECTOR   ((PS_KEYB_IRQ & 0x07) + IRQ8_VECTOR)

/* 8259A interrupt controller ports. */
#define INT_CTL         0x20	/* I/O port for interrupt controller */
#define INT_CTLMASK     0x21	/* setting bits in this port disables ints */
#define INT2_CTL        0xA0	/* I/O port for second interrupt controller */
#define INT2_MASK       0xA1	/* setting bits in this port disables ints */

/* Magic numbers for interrupt controller. */
#define ENABLE          0x20	/* code used to re-enable after an interrupt */

/* Sizes of memory tables. */
#define NR_MEMS            4	/* number of chunks of memory */

/* Magic memory locations and sizes. */
#define COLOR_BASE   0xB8000L	/* base of color video memory */
#define COLOR_SIZE    0x8000L	/* maximum usable color video memory */
#define MONO_BASE    0xB0000L	/* base of mono video memory */
#define MONO_SIZE     0x8000L	/* maximum usable mono video memory */

/* Cursor shape is needed by debugger as well as console driver. */
#define CURSOR_SHAPE      15	/* block cursor for MDA/HGC/CGA/EGA/VGA... */

/* Miscellaneous ports. */
#define PCR		0x65	/* Planar Control Register */
#define PORT_B          0x61	/* I/O port for 8255 port B (kbd, beeper...) */
#define TIMER0          0x40	/* I/O port for timer channel 0 */
#define TIMER2          0x42	/* I/O port for timer channel 2 */
#define TIMER_MODE      0x43	/* I/O port for timer mode control */

#endif /* (CHIP == INTEL) */

#if (CHIP == M68000)

#define K_STACK_BYTES   1024	/* how many bytes for the kernel stack */

/* p_reg contains: d0-d7, a0-a6,   in that order. */
#define NR_REGS           15	/* number of general regs in each proc slot */
 
#define TRACEBIT      0x8000	/* or this with psw in proc[] for tracing */
#define SETBITS(rp, new)	/* permits only certain bits to be set */ \
	((rp)->p_reg.psw = (rp)->p_reg.psw & ~0xFF | (new) & 0xFF)
 
#define MEM_BYTES  0x1000000	/* memory size for /dev/mem */
#define ALIGNMENT	   4	/* align large items to a multiple of this */
		/* 2 would do for an 68000, but 4 is nicer for 68020/68030 */
 
#ifdef ACK
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

#define printf        printk	/* the kernel really uses printk, not printf */
