/* Global variables used in the kernel. */

/* EXTERN is defined as extern except in table.c. */
#ifdef _TABLE
#undef EXTERN
#define EXTERN
#endif

/* Kernel memory. */
EXTERN phys_bytes code_base;	/* base of kernel code */
EXTERN phys_bytes data_base;	/* base of kernel data */
EXTERN phys_bytes aout;		/* address of a.out headers */

/* Low level interrupt communications. */
EXTERN struct proc *held_head;	/* head of queue of held-up interrupts */
EXTERN struct proc *held_tail;	/* tail of queue of held-up interrupts */
EXTERN unsigned char k_reenter;	/* kernel reentry count (entry count less 1)*/

/* Process table.  Here to stop too many things having to include proc.h. */
EXTERN struct proc *proc_ptr;	/* pointer to currently running process */

/* Signals. */
EXTERN int sig_procs;		/* number of procs with p_pending != 0 */

/* Memory sizes. */
EXTERN struct memory mem[NR_MEMS];	/* base and size of chunks of memory */
EXTERN phys_clicks tot_mem_size;	/* total system memory size */

/* Miscellaneous. */
extern struct tasktab tasktab[];/* initialized in table.c, so extern here */
extern char *t_stack[];		/* initialized in table.c, so extern here */
EXTERN unsigned lost_ticks;	/* clock ticks counted outside the clock task */
EXTERN clock_t tty_timeout;	/* time to wake up the TTY task */
EXTERN int current;		/* currently visible console */

#if (CHIP == INTEL)

/* Machine type. */
EXTERN int pc_at;		/* PC-AT compatible hardware interface */
EXTERN int ps_mca;		/* PS/2 with Micro Channel */
EXTERN unsigned int processor;	/* 86, 186, 286, 386, ... */
#if _WORD_SIZE == 2
EXTERN int protected_mode;	/* nonzero if running in Intel protected mode*/
#else
#define protected_mode	1	/* 386 mode implies protected mode */
#endif

/* Video card types. */
EXTERN int ega;			/* nonzero if console is EGA */
EXTERN int vga;			/* nonzero if console is VGA */

/* Miscellaneous. */
EXTERN irq_handler_t irq_table[NR_IRQ_VECTORS];
EXTERN int irq_use;		/* bit map of all in-use irq's */
EXTERN reg_t mon_ss, mon_sp;	/* monitor stack */
EXTERN int mon_return;		/* true if return to the monitor possible */
EXTERN phys_bytes reboot_code;	/* program for the boot monitor */
EXTERN union reg86 reg86;	/* registers used in an 8086 interrupt */

/* Variables that are initialized elsewhere are just extern here. */
extern struct segdesc_s gdt[];	/* global descriptor table for protected mode*/

EXTERN _PROTOTYPE( void (*level0_func), (void) );
#endif /* (CHIP == INTEL) */

#if (CHIP == M68000)
/* Variables that are initialized elsewhere are just extern here. */
extern int keypad;		/* Flag for keypad mode */
extern int app_mode;		/* Flag for arrow key application mode */
extern int STdebKey;		/* nonzero if ctl-alt-Fx detected */
extern struct tty *cur_cons;	/* virtual cons currently displayed */
extern unsigned char font8[];	/* 8 pixel wide font table (initialized) */
extern unsigned char font12[];	/* 12 pixel wide font table (initialized) */
extern unsigned char font16[];	/* 16 pixel wide font table (initialized) */
extern unsigned short resolution; /* screen res; ST_RES_LOW..TT_RES_HIGH */
#endif
