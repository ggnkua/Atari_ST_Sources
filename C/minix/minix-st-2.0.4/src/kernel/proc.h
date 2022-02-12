#ifndef PROC_H
#define PROC_H

/* Here is the declaration of the process table.  It contains the process'
 * registers, memory map, accounting, and message send/receive information.
 * Many assembly code routines reference fields in it.  The offsets to these
 * fields are defined in the assembler include file sconst.h.  When changing
 * 'proc', be sure to change sconst.h to match.
 */

struct proc {
  struct stackframe_s p_reg;	/* process' registers saved in stack frame */

#if (CHIP == INTEL)
  reg_t p_ldt_sel;		/* selector in gdt giving ldt base and limit*/
  struct segdesc_s p_ldt[4];	/* local descriptors for code and data */
				/* 4 is LDT_SIZE - avoid include protect.h */
#endif /* (CHIP == INTEL) */

#if (CHIP == M68000)
  reg_t p_splow;		/* lowest observed stack value */
  int p_trap;			/* trap type (only low byte) */
#if (SHADOWING == 0)
  char *p_crp;                  /* mmu table pointer (really struct _rpr *) */
#else
  phys_clicks p_shadow;         /* set if shadowed process image */
  int align;                    /* make the struct size a multiple of 4 */
#endif /* SHADOWING */
  int p_nflips;			/* statistics */
#if (SHADOWING == 1)
  char p_physio;                /* cannot be (un)shadowed now if set */
#endif /* SHADOWING */
#if defined(FPP)
  struct fsave p_fsave;		/* FPP state frame and registers */
  int align2;			/* make the struct size a multiple of 4 */
#endif
#endif /* (CHIP == M68000) */

  reg_t *p_stguard;		/* stack guard word */

  int p_nr;			/* number of this process (for fast access) */

  char p_int_blocked;		/* nonzero if int msg blocked by busy task */
  char p_int_held;		/* nonzero if int msg held by busy syscall */
  struct proc *p_nextheld;	/* next in chain of held-up int processes */

  int p_flags;			/* SENDING, RECEIVING, etc. */
  struct mem_map p_map[NR_SEGS];/* memory map */
  pid_t p_pid;			/* process id passed in from MM */
  int p_priority;		/* task, server, or user process */

  clock_t user_time;		/* user time in ticks */
  clock_t sys_time;		/* sys time in ticks */
  clock_t child_utime;		/* cumulative user time of children */
  clock_t child_stime;		/* cumulative sys time of children */

  timer_t *p_exptimers;		/* list of expired timers */

  struct proc *p_callerq;	/* head of list of procs wishing to send */
  struct proc *p_sendlink;	/* link to next proc wishing to send */
  message *p_messbuf;		/* pointer to message buffer */
  int p_getfrom;		/* from whom does process want to receive? */
  int p_sendto;

  struct proc *p_nextready;	/* pointer to next ready process */
  sigset_t p_pending;		/* bit map for pending signals */
  unsigned p_pendcount;		/* count of pending and unfinished signals */

  char p_name[16];		/* name of the process */
};

/* Guard word for task stacks. */
#define STACK_GUARD	((reg_t) (sizeof(reg_t) == 2 ? 0xBEEF : 0xDEADBEEF))

/* Bits for p_flags in proc[].  A process is runnable iff p_flags == 0. */
#define NO_MAP		0x01	/* keeps unmapped forked child from running */
#define SENDING		0x02	/* set when process blocked trying to send */
#define RECEIVING	0x04	/* set when process blocked trying to recv */
#define PENDING		0x08	/* set when inform() of signal pending */
#define SIG_PENDING	0x10	/* keeps to-be-signalled proc from running */
#define P_STOP		0x20	/* set when process is being traced */

/* Values for p_priority */
#define PPRI_NONE	0	/* Slot is not in use */
#define PPRI_TASK	1	/* Part of the kernel */
#define PPRI_SERVER	2	/* System process outside the kernel */
#define PPRI_USER	3	/* User process */
#define PPRI_IDLE	4	/* Idle process */

/* Magic process table addresses. */
#define BEG_PROC_ADDR (&proc[0])
#define END_PROC_ADDR (&proc[NR_TASKS + NR_PROCS])
#define END_TASK_ADDR (&proc[NR_TASKS])
#define BEG_SERV_ADDR (&proc[NR_TASKS])
#define BEG_USER_ADDR (&proc[NR_TASKS + LOW_USER])

#define NIL_PROC          ((struct proc *) 0)
#define isidlehardware(n) ((n) == IDLE || (n) == HARDWARE)
#define isokprocn(n)      ((unsigned) ((n) + NR_TASKS) < NR_PROCS + NR_TASKS)
#define isoksrc_dest(n)   (isokprocn(n) || (n) == ANY)
#define isrxhardware(n)   ((n) == ANY || (n) == HARDWARE)
#define issysentn(n)      ((n) == FS_PROC_NR || (n) == MM_PROC_NR)
#define isemptyp(p)       ((p)->p_priority == PPRI_NONE)
#define istaskp(p)        ((p)->p_priority == PPRI_TASK)
#define isservp(p)        ((p)->p_priority == PPRI_SERVER)
#define isuserp(p)        ((p)->p_priority == PPRI_USER)
#define proc_addr(n)      (pproc_addr + NR_TASKS)[(n)]
#define cproc_addr(n)     (&(proc + NR_TASKS)[(n)])
#define proc_number(p)    ((p)->p_nr)
#if (CHIP != M68000)
#define proc_vir2phys(p, vir) \
			  (((phys_bytes)(p)->p_map[D].mem_phys << CLICK_SHIFT) \
							+ (vir_bytes) (vir))
#else
#if (SHADOWING == 0)
#define proc_vir2phys(p, vir)   \
                  (((phys_bytes)(vir)) +        \
		   ((phys_bytes)p->p_map[D].mem_phys << CLICK_SHIFT) - \
		   ((phys_bytes)p->p_map[D].mem_vir  << CLICK_SHIFT))
#else
#define	isshadowp(p)	((p)->p_shadow != 0)

#define proc_vir2phys(p, vir)   \
		  ((phys_bytes)(vir) + \
		   (((p)->p_shadow) ? \
		    (((phys_bytes)(p)->p_shadow << CLICK_SHIFT) - \
		     ((phys_bytes)(p)->p_map[D].mem_phys << CLICK_SHIFT)) : 0))
#endif /* SHADOWING == 0 */
#endif /* CHIP != M68000 */

EXTERN struct proc proc[NR_TASKS + NR_PROCS];	/* process table */
EXTERN struct proc *pproc_addr[NR_TASKS + NR_PROCS];
/* ptrs to process table slots; fast because now a process entry can be found
   by indexing the pproc_addr array, while accessing an element i requires
   a multiplication with sizeof(struct proc) to determine the address */
EXTERN struct proc *bill_ptr;	/* ptr to process to bill for clock ticks */
EXTERN struct proc *rdy_head[NQ];	/* pointers to ready list headers */
EXTERN struct proc *rdy_tail[NQ];	/* pointers to ready list tails */

#endif /* PROC_H */
