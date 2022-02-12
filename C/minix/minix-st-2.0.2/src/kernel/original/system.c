/* This task handles the interface between file system and kernel as well as
 * between memory manager and kernel.  System services are obtained by sending
 * sys_task() a message specifying what is needed.  To make life easier for
 * MM and FS, a library is provided with routines whose names are of the
 * form sys_xxx, e.g. sys_xit sends the SYS_XIT message to sys_task.  The
 * message types and parameters are:
 *
 *   SYS_FORK	 informs kernel that a process has forked
 *   SYS_NEWMAP	 allows MM to set up a process memory map
 *   SYS_GETMAP	 allows MM to get a process' memory map
 *   SYS_EXEC	 sets program counter and stack pointer after EXEC
 *   SYS_XIT	 informs kernel that a process has exited
 *   SYS_GETSP	 caller wants to read out some process' stack pointer
 *   SYS_TIMES	 caller wants to get accounting times for a process
 *   SYS_ABORT	 MM or FS cannot go on; abort MINIX
 *   SYS_FRESH	 start with a fresh process image during EXEC (68000 only)
 *   SYS_SENDSIG send a signal to a process (POSIX style)
 *   SYS_SIGRETURN complete POSIX-style signalling
 *   SYS_KILL	 cause a signal to be sent via MM
 *   SYS_ENDSIG	 finish up after SYS_KILL-type signal
 *   SYS_COPY	 request a block of data to be copied between processes
 *   SYS_VCOPY   request a series of data blocks to be copied between procs
 *   SYS_GBOOT	 copies the boot parameters to a process
 *   SYS_MEM	 returns the next free chunk of physical memory
 *   SYS_UMAP	 compute the physical address for a given virtual address
 *   SYS_TRACE	 request a trace operation
 *
 * Message types and parameters:
 *
 *    m_type       PROC1     PROC2      PID     MEM_PTR
 * ------------------------------------------------------
 * | SYS_FORK   | parent  |  child  |   pid   |         |
 * |------------+---------+---------+---------+---------|
 * | SYS_NEWMAP | proc nr |         |         | map ptr |
 * |------------+---------+---------+---------+---------|
 * | SYS_EXEC   | proc nr | traced  | new sp  |         |
 * |------------+---------+---------+---------+---------|
 * | SYS_XIT    | parent  | exitee  |         |         |
 * |------------+---------+---------+---------+---------|
 * | SYS_GETSP  | proc nr |         |         |         |
 * |------------+---------+---------+---------+---------|
 * | SYS_TIMES  | proc nr |         | buf ptr |         |
 * |------------+---------+---------+---------+---------|
 * | SYS_ABORT  |         |         |         |         |
 * |------------+---------+---------+---------+---------|
 * | SYS_FRESH  | proc nr | data_cl |         |         |
 * |------------+---------+---------+---------+---------|
 * | SYS_GBOOT  | proc nr |         |         | bootptr |
 * |------------+---------+---------+---------+---------|
 * | SYS_GETMAP | proc nr |         |         | map ptr |
 * ------------------------------------------------------
 *
 *    m_type          m1_i1     m1_i2     m1_i3       m1_p1
 * ----------------+---------+---------+---------+--------------
 * | SYS_VCOPY     |  src p  |  dst p  | vec siz | vc addr     |
 * |---------------+---------+---------+---------+-------------|
 * | SYS_SENDSIG   | proc nr |         |         | smp         |
 * |---------------+---------+---------+---------+-------------|
 * | SYS_SIGRETURN | proc nr |         |         | scp         |
 * |---------------+---------+---------+---------+-------------|
 * | SYS_ENDSIG    | proc nr |         |         |             |
 * -------------------------------------------------------------
 *
 *    m_type       m2_i1     m2_i2     m2_l1     m2_l2
 * ------------------------------------------------------
 * | SYS_TRACE  | proc_nr | request |  addr   |  data   |
 * ------------------------------------------------------
 *
 *
 *    m_type       m6_i1     m6_i2     m6_i3     m6_f1
 * ------------------------------------------------------
 * | SYS_KILL   | proc_nr  |  sig    |         |         |
 * ------------------------------------------------------
 *
 *
 *    m_type      m5_c1   m5_i1    m5_l1   m5_c2   m5_i2    m5_l2   m5_l3
 * --------------------------------------------------------------------------
 * | SYS_COPY   |src seg|src proc|src vir|dst seg|dst proc|dst vir| byte ct |
 * --------------------------------------------------------------------------
 * | SYS_UMAP   |  seg  |proc nr |vir adr|       |        |       | byte ct |
 * --------------------------------------------------------------------------
 *
 *
 *    m_type      m1_i1      m1_i2      m1_i3
 * |------------+----------+----------+----------
 * | SYS_MEM    | mem base | mem size | tot mem |
 * ----------------------------------------------
 *
 * In addition to the main sys_task() entry point, there are 5 other minor
 * entry points:
 *   cause_sig:	take action to cause a signal to occur, sooner or later
 *   inform:	tell MM about pending signals
 *   numap:	umap D segment starting from process number instead of pointer
 *   umap:	compute the physical address for a given virtual address
 *   alloc_segments: allocate segments for 8088 or higher processor
 */

#include "kernel.h"
#include <signal.h>
#include <unistd.h>
#include <sys/sigcontext.h>
#include <sys/ptrace.h>
#include <minix/boot.h>
#include <minix/callnr.h>
#include <minix/com.h>
#include "proc.h"
#if (CHIP == INTEL)
#include "protect.h"
#endif

/* PSW masks. */
#define IF_MASK 0x00000200
#define IOPL_MASK 0x003000

PRIVATE message m;

FORWARD _PROTOTYPE( int do_abort, (message *m_ptr) );
FORWARD _PROTOTYPE( int do_copy, (message *m_ptr) );
FORWARD _PROTOTYPE( int do_exec, (message *m_ptr) );
FORWARD _PROTOTYPE( int do_fork, (message *m_ptr) );
FORWARD _PROTOTYPE( int do_gboot, (message *m_ptr) );
FORWARD _PROTOTYPE( int do_getsp, (message *m_ptr) );
FORWARD _PROTOTYPE( int do_kill, (message *m_ptr) );
FORWARD _PROTOTYPE( int do_mem, (message *m_ptr) );
FORWARD _PROTOTYPE( int do_newmap, (message *m_ptr) );
FORWARD _PROTOTYPE( int do_sendsig, (message *m_ptr) );
FORWARD _PROTOTYPE( int do_sigreturn, (message *m_ptr) );
FORWARD _PROTOTYPE( int do_endsig, (message *m_ptr) );
FORWARD _PROTOTYPE( int do_times, (message *m_ptr) );
FORWARD _PROTOTYPE( int do_trace, (message *m_ptr) );
FORWARD _PROTOTYPE( int do_umap, (message *m_ptr) );
FORWARD _PROTOTYPE( int do_xit, (message *m_ptr) );
FORWARD _PROTOTYPE( int do_vcopy, (message *m_ptr) );
FORWARD _PROTOTYPE( int do_getmap, (message *m_ptr) );

#if (SHADOWING == 1)
FORWARD _PROTOTYPE( int do_fresh, (message *m_ptr) );
#endif

/*===========================================================================*
 *				sys_task				     *
 *===========================================================================*/
PUBLIC void sys_task()
{
/* Main entry point of sys_task.  Get the message and dispatch on type. */

  register int r;

  while (TRUE) {
	receive(ANY, &m);

	switch (m.m_type) {	/* which system call */
	    case SYS_FORK:	r = do_fork(&m);	break;
	    case SYS_NEWMAP:	r = do_newmap(&m);	break;
	    case SYS_GETMAP:	r = do_getmap(&m);	break;
	    case SYS_EXEC:	r = do_exec(&m);	break;
	    case SYS_XIT:	r = do_xit(&m);		break;
	    case SYS_GETSP:	r = do_getsp(&m);	break;
	    case SYS_TIMES:	r = do_times(&m);	break;
	    case SYS_ABORT:	r = do_abort(&m);	break;
#if (SHADOWING == 1)
	    case SYS_FRESH:	r = do_fresh(&m);	break;
#endif
	    case SYS_SENDSIG:	r = do_sendsig(&m);	break;
	    case SYS_SIGRETURN: r = do_sigreturn(&m);	break;
	    case SYS_KILL:	r = do_kill(&m);	break;
	    case SYS_ENDSIG:	r = do_endsig(&m);	break;
	    case SYS_COPY:	r = do_copy(&m);	break;
            case SYS_VCOPY:	r = do_vcopy(&m);	break;
	    case SYS_GBOOT:	r = do_gboot(&m);	break;
	    case SYS_MEM:	r = do_mem(&m);		break;
	    case SYS_UMAP:	r = do_umap(&m);	break;
	    case SYS_TRACE:	r = do_trace(&m);	break;
	    default:		r = E_BAD_FCN;
	}

	m.m_type = r;		/* 'r' reports status of call */
	send(m.m_source, &m);	/* send reply to caller */
  }
}


/*===========================================================================*
 *				do_fork					     *
 *===========================================================================*/
PRIVATE int do_fork(m_ptr)
register message *m_ptr;	/* pointer to request message */
{
/* Handle sys_fork().  m_ptr->PROC1 has forked.  The child is m_ptr->PROC2. */

#if (CHIP == INTEL)
  reg_t old_ldt_sel;
#endif
  register struct proc *rpc;
  struct proc *rpp;

  if (!isoksusern(m_ptr->PROC1) || !isoksusern(m_ptr->PROC2))
	return(E_BAD_PROC);
  rpp = proc_addr(m_ptr->PROC1);
  rpc = proc_addr(m_ptr->PROC2);

  /* Copy parent 'proc' struct to child. */
#if (CHIP == INTEL)
  old_ldt_sel = rpc->p_ldt_sel;	/* stop this being obliterated by copy */
#endif

  *rpc = *rpp;			/* copy 'proc' struct */

#if (CHIP == INTEL)
  rpc->p_ldt_sel = old_ldt_sel;
#endif
  rpc->p_nr = m_ptr->PROC2;	/* this was obliterated by copy */

#if (SHADOWING == 0)
  rpc->p_flags |= NO_MAP;	/* inhibit the process from running */
#endif

  rpc->p_flags &= ~(PENDING | SIG_PENDING | P_STOP);

  /* Only 1 in group should have PENDING, child does not inherit trace status*/
  sigemptyset(&rpc->p_pending);
  rpc->p_pendcount = 0;
  rpc->p_pid = m_ptr->PID;	/* install child's pid */
  rpc->p_reg.retreg = 0;	/* child sees pid = 0 to know it is child */

  rpc->user_time = 0;		/* set all the accounting times to 0 */
  rpc->sys_time = 0;
  rpc->child_utime = 0;
  rpc->child_stime = 0;

#if (SHADOWING == 1)
  rpc->p_nflips = 0;
  mkshadow(rpp, (phys_clicks)m_ptr->m1_p1);	/* run child first */
#endif

  return(OK);
}


/*===========================================================================*
 *				do_newmap				     *
 *===========================================================================*/
PRIVATE int do_newmap(m_ptr)
message *m_ptr;			/* pointer to request message */
{
/* Handle sys_newmap().  Fetch the memory map from MM. */

  register struct proc *rp;
  phys_bytes src_phys;
  int caller;			/* whose space has the new map (usually MM) */
  int k;			/* process whose map is to be loaded */
  int old_flags;		/* value of flags before modification */
  struct mem_map *map_ptr;	/* virtual address of map inside caller (MM) */

  /* Extract message parameters and copy new memory map from MM. */
  caller = m_ptr->m_source;
  k = m_ptr->PROC1;
  map_ptr = (struct mem_map *) m_ptr->MEM_PTR;
  if (!isokprocn(k)) return(E_BAD_PROC);
  rp = proc_addr(k);		/* ptr to entry of user getting new map */

  /* Copy the map from MM. */
  src_phys = umap(proc_addr(caller), D, (vir_bytes) map_ptr, sizeof(rp->p_map));
  if (src_phys == 0) panic("bad call to sys_newmap", NO_NUM);
  phys_copy(src_phys, vir2phys(rp->p_map), (phys_bytes) sizeof(rp->p_map));

#if (SHADOWING == 0)
#if (CHIP != M68000)
  alloc_segments(rp);
#else
  pmmu_init_proc(rp);
#endif
  old_flags = rp->p_flags;	/* save the previous value of the flags */
  rp->p_flags &= ~NO_MAP;
  if (old_flags != 0 && rp->p_flags == 0) lock_ready(rp);
#endif

  return(OK);
}


/*===========================================================================*
 *				do_getmap				     *
 *===========================================================================*/
PRIVATE int do_getmap(m_ptr)
message *m_ptr;			/* pointer to request message */
{
/* Handle sys_getmap().  Report the memory map to MM. */

  register struct proc *rp;
  phys_bytes dst_phys;
  int caller;			/* where the map has to be stored */
  int k;			/* process whose map is to be loaded */
  struct mem_map *map_ptr;	/* virtual address of map inside caller (MM) */

  /* Extract message parameters and copy new memory map to MM. */
  caller = m_ptr->m_source;
  k = m_ptr->PROC1;
  map_ptr = (struct mem_map *) m_ptr->MEM_PTR;

  if (!isokprocn(k))
	panic("do_getmap got bad proc: ", m_ptr->PROC1);

  rp = proc_addr(k);		/* ptr to entry of the map */

  /* Copy the map to MM. */
  dst_phys = umap(proc_addr(caller), D, (vir_bytes) map_ptr, sizeof(rp->p_map));
  if (dst_phys == 0) panic("bad call to sys_getmap", NO_NUM);
  phys_copy(vir2phys(rp->p_map), dst_phys, sizeof(rp->p_map));

  return(OK);
}


/*===========================================================================*
 *				do_exec					     *
 *===========================================================================*/
PRIVATE int do_exec(m_ptr)
register message *m_ptr;	/* pointer to request message */
{
/* Handle sys_exec().  A process has done a successful EXEC. Patch it up. */

  register struct proc *rp;
  reg_t sp;			/* new sp */
  phys_bytes phys_name;
  char *np;
#define NLEN (sizeof(rp->p_name)-1)

  if (!isoksusern(m_ptr->PROC1)) return E_BAD_PROC;
  /* PROC2 field is used as flag to indicate process is being traced */
  if (m_ptr->PROC2) cause_sig(m_ptr->PROC1, SIGTRAP);
  sp = (reg_t) m_ptr->STACK_PTR;
  rp = proc_addr(m_ptr->PROC1);
  rp->p_reg.sp = sp;		/* set the stack pointer */
#if (CHIP == M68000)
  rp->p_splow = sp;		/* set the stack pointer low water */
#ifdef FPP
  /* Initialize fpp for this process */
  fpp_new_state(rp);
#endif
#endif
  rp->p_reg.pc = (reg_t) m_ptr->IP_PTR;	/* set pc */
  rp->p_alarm = 0;		/* reset alarm timer */
  rp->p_flags &= ~RECEIVING;	/* MM does not reply to EXEC call */
  if (rp->p_flags == 0) lock_ready(rp);

  /* Save command name for debugging, ps(1) output, etc. */
  phys_name = numap(m_ptr->m_source, (vir_bytes) m_ptr->NAME_PTR,
							(vir_bytes) NLEN);
  if (phys_name != 0) {
	phys_copy(phys_name, vir2phys(rp->p_name), (phys_bytes) NLEN);
	for (np = rp->p_name; (*np & BYTE) >= ' '; np++) {}
	*np = 0;
  }
  return(OK);
}


/*===========================================================================*
 *				do_xit					     *
 *===========================================================================*/
PRIVATE int do_xit(m_ptr)
message *m_ptr;			/* pointer to request message */
{
/* Handle sys_xit().  A process has exited. */

  register struct proc *rp, *rc;
  struct proc *np, *xp;
  int parent;			/* number of exiting proc's parent */
  int proc_nr;			/* number of process doing the exit */
  phys_clicks base, size;

  parent = m_ptr->PROC1;	/* slot number of parent process */
  proc_nr = m_ptr->PROC2;	/* slot number of exiting process */
  if (!isoksusern(parent) || !isoksusern(proc_nr)) return(E_BAD_PROC);
  rp = proc_addr(parent);
  rc = proc_addr(proc_nr);
  lock();
  rp->child_utime += rc->user_time + rc->child_utime;	/* accum child times */
  rp->child_stime += rc->sys_time + rc->child_stime;
  unlock();
  rc->p_alarm = 0;		/* turn off alarm timer */
  if (rc->p_flags == 0) lock_unready(rc);

#if (SHADOWING == 1)
  rmshadow(rc, &base, &size);
  m_ptr->m1_i1 = (int)base;
  m_ptr->m1_i2 = (int)size;
#endif

  strcpy(rc->p_name, "<noname>");	/* process no longer has a name */

  /* If the process being terminated happens to be queued trying to send a
   * message (i.e., the process was killed by a signal, rather than it doing an
   * EXIT), then it must be removed from the message queues.
   */
  if (rc->p_flags & SENDING) {
	/* Check all proc slots to see if the exiting process is queued. */
	for (rp = BEG_PROC_ADDR; rp < END_PROC_ADDR; rp++) {
		if (rp->p_callerq == NIL_PROC) continue;
		if (rp->p_callerq == rc) {
			/* Exiting process is on front of this queue. */
			rp->p_callerq = rc->p_sendlink;
			break;
		} else {
			/* See if exiting process is in middle of queue. */
			np = rp->p_callerq;
			while ( ( xp = np->p_sendlink) != NIL_PROC)
				if (xp == rc) {
					np->p_sendlink = xp->p_sendlink;
					break;
				} else {
					np = xp;
				}
		}
	}
  }
#if (CHIP == M68000) && (SHADOWING == 0)
  pmmu_delete(rc);	/* we're done remove tables */
#endif

  if (rc->p_flags & PENDING) --sig_procs;
  sigemptyset(&rc->p_pending);
  rc->p_pendcount = 0;
  rc->p_flags = P_SLOT_FREE;
  return(OK);
}


/*===========================================================================*
 *				do_getsp				     *
 *===========================================================================*/
PRIVATE int do_getsp(m_ptr)
register message *m_ptr;	/* pointer to request message */
{
/* Handle sys_getsp().  MM wants to know what sp is. */

  register struct proc *rp;

  if (!isoksusern(m_ptr->PROC1)) return(E_BAD_PROC);
  rp = proc_addr(m_ptr->PROC1);
  m_ptr->STACK_PTR = (char *) rp->p_reg.sp;	/* return sp here (bad type) */
  return(OK);
}


/*===========================================================================*
 *				do_times				     *
 *===========================================================================*/
PRIVATE int do_times(m_ptr)
register message *m_ptr;	/* pointer to request message */
{
/* Handle sys_times().  Retrieve the accounting information. */

  register struct proc *rp;

  if (!isoksusern(m_ptr->PROC1)) return E_BAD_PROC;
  rp = proc_addr(m_ptr->PROC1);

  /* Insert the times needed by the TIMES system call in the message. */
  lock();			/* halt the volatile time counters in rp */
  m_ptr->USER_TIME   = rp->user_time;
  m_ptr->SYSTEM_TIME = rp->sys_time;
  unlock();
  m_ptr->CHILD_UTIME = rp->child_utime;
  m_ptr->CHILD_STIME = rp->child_stime;
  m_ptr->BOOT_TICKS  = get_uptime();
  return(OK);
}


/*===========================================================================*
 *				do_abort				     *
 *===========================================================================*/
PRIVATE int do_abort(m_ptr)
message *m_ptr;			/* pointer to request message */
{
/* Handle sys_abort.  MINIX is unable to continue.  Terminate operation. */
  char monitor_code[64];
  phys_bytes src_phys;

  if (m_ptr->m1_i1 == RBT_MONITOR) {
	/* The monitor is to run user specified instructions. */
	src_phys = numap(m_ptr->m_source, (vir_bytes) m_ptr->m1_p1,
					(vir_bytes) sizeof(monitor_code));
	if (src_phys == 0) panic("bad monitor code from", m_ptr->m_source);
	phys_copy(src_phys, vir2phys(monitor_code),
					(phys_bytes) sizeof(monitor_code));
	reboot_code = vir2phys(monitor_code);
  }
  wreboot(m_ptr->m1_i1);
  return(OK);			/* pro-forma (really EDISASTER) */
}


#if (SHADOWING == 1)
/*===========================================================================*
 *				do_fresh				     *
 *===========================================================================*/
PRIVATE int do_fresh(m_ptr)     /* for 68000 only */
message *m_ptr;			/* pointer to request message */
{
/* Handle sys_fresh.  Start with fresh process image during EXEC. */

  register struct proc *p;
  int proc_nr;			/* number of process doing the exec */
  phys_clicks base, size;
  phys_clicks c1, nc;

  proc_nr = m_ptr->PROC1;	/* slot number of exec-ing process */
  if (!isokprocn(proc_nr)) return(E_BAD_PROC);
  p = proc_addr(proc_nr);
  rmshadow(p, &base, &size);
  do_newmap(m_ptr);
  c1 = p->p_map[D].mem_phys;
  nc = p->p_map[S].mem_phys - p->p_map[D].mem_phys + p->p_map[S].mem_len;
  c1 += m_ptr->m1_i2;
  nc -= m_ptr->m1_i2;
  zeroclicks(c1, nc);
  m_ptr->m1_i1 = (int)base;
  m_ptr->m1_i2 = (int)size;
  return(OK);
}
#endif /* (SHADOWING == 1) */


/*===========================================================================*
 *			      do_sendsig				     *
 *===========================================================================*/
PRIVATE int do_sendsig(m_ptr)
message *m_ptr;			/* pointer to request message */
{
/* Handle sys_sendsig, POSIX-style signal */

  struct sigmsg smsg;
  register struct proc *rp;
  phys_bytes src_phys, dst_phys;
  struct sigcontext sc, *scp;
  struct sigframe fr, *frp;

  if (!isokusern(m_ptr->PROC1)) return(E_BAD_PROC);
  rp = proc_addr(m_ptr->PROC1);

  /* Get the sigmsg structure into our address space.  */
  src_phys = umap(proc_addr(MM_PROC_NR), D, (vir_bytes) m_ptr->SIG_CTXT_PTR,
		  (vir_bytes) sizeof(struct sigmsg));
  if (src_phys == 0)
	panic("do_sendsig can't signal: bad sigmsg address from MM", NO_NUM);
  phys_copy(src_phys, vir2phys(&smsg), (phys_bytes) sizeof(struct sigmsg));

  /* Compute the usr stack pointer value where sigcontext will be stored. */
  scp = (struct sigcontext *) smsg.sm_stkptr - 1;

  /* Copy the registers to the sigcontext structure. */
  memcpy(&sc.sc_regs, &rp->p_reg, sizeof(struct sigregs));

  /* Finish the sigcontext initialization. */
  sc.sc_flags = SC_SIGCONTEXT;

  sc.sc_mask = smsg.sm_mask;

  /* Copy the sigcontext structure to the user's stack. */
  dst_phys = umap(rp, D, (vir_bytes) scp,
		  (vir_bytes) sizeof(struct sigcontext));
  if (dst_phys == 0) return(EFAULT);
  phys_copy(vir2phys(&sc), dst_phys, (phys_bytes) sizeof(struct sigcontext));

  /* Initialize the sigframe structure. */
  frp = (struct sigframe *) scp - 1;
  fr.sf_scpcopy = scp;
  fr.sf_retadr2= (void (*)()) rp->p_reg.pc;
  fr.sf_fp = rp->p_reg.fp;
  rp->p_reg.fp = (reg_t) &frp->sf_fp;
  fr.sf_scp = scp;
  fr.sf_code = 0;	/* XXX - should be used for type of FP exception */
  fr.sf_signo = smsg.sm_signo;
  fr.sf_retadr = (void (*)()) smsg.sm_sigreturn;

  /* Copy the sigframe structure to the user's stack. */
  dst_phys = umap(rp, D, (vir_bytes) frp, (vir_bytes) sizeof(struct sigframe));
  if (dst_phys == 0) return(EFAULT);
  phys_copy(vir2phys(&fr), dst_phys, (phys_bytes) sizeof(struct sigframe));

  /* Reset user registers to execute the signal handler. */
  rp->p_reg.sp = (reg_t) frp;
  rp->p_reg.pc = (reg_t) smsg.sm_sighandler;

  return(OK);
}

/*===========================================================================*
 *			      do_sigreturn				     *
 *===========================================================================*/
PRIVATE int do_sigreturn(m_ptr)
register message *m_ptr;
{
/* POSIX style signals require sys_sigreturn to put things in order before the
 * signalled process can resume execution
 */

  struct sigcontext sc;
  register struct proc *rp;
  phys_bytes src_phys;

  if (!isokusern(m_ptr->PROC1)) return(E_BAD_PROC);
  rp = proc_addr(m_ptr->PROC1);

  /* Copy in the sigcontext structure. */
  src_phys = umap(rp, D, (vir_bytes) m_ptr->SIG_CTXT_PTR,
		  (vir_bytes) sizeof(struct sigcontext));
  if (src_phys == 0) return(EFAULT);
  phys_copy(src_phys, vir2phys(&sc), (phys_bytes) sizeof(struct sigcontext));

  /* Make sure that this is not just a jmp_buf. */
  if ((sc.sc_flags & SC_SIGCONTEXT) == 0) return(EINVAL);

  /* Fix up only certain key registers if the compiler doesn't use
   * register variables within functions containing setjmp.
   */
  if (sc.sc_flags & SC_NOREGLOCALS) {
	rp->p_reg.retreg = sc.sc_retreg;
	rp->p_reg.fp = sc.sc_fp;
	rp->p_reg.pc = sc.sc_pc;
	rp->p_reg.sp = sc.sc_sp;
	return (OK);
  }
  sc.sc_psw  = rp->p_reg.psw;

#if (CHIP == INTEL)
  /* Don't panic kernel if user gave bad selectors. */
  sc.sc_cs = rp->p_reg.cs;
  sc.sc_ds = rp->p_reg.ds;
  sc.sc_es = rp->p_reg.es;
#if _WORD_SIZE == 4
  sc.sc_fs = rp->p_reg.fs;
  sc.sc_gs = rp->p_reg.gs;
#endif
#endif

  /* Restore the registers. */
  memcpy(&rp->p_reg, (char *)&sc.sc_regs, sizeof(struct sigregs));

  return(OK);
}

/*===========================================================================*
 *				do_kill					     *
 *===========================================================================*/
PRIVATE int do_kill(m_ptr)
register message *m_ptr;	/* pointer to request message */
{
/* Handle sys_kill(). Cause a signal to be sent to a process via MM.
 * Note that this has nothing to do with the kill (2) system call, this
 * is how the FS (and possibly other servers) get access to cause_sig to
 * send a KSIG message to MM
 */

  if (!isokusern(m_ptr->PR)) return(E_BAD_PROC);
  cause_sig(m_ptr->PR, m_ptr->SIGNUM);
  return(OK);
}


/*===========================================================================*
 *			      do_endsig					     *
 *===========================================================================*/
PRIVATE int do_endsig(m_ptr)
register message *m_ptr;	/* pointer to request message */
{
/* Finish up after a KSIG-type signal, caused by a SYS_KILL message or a call
 * to cause_sig by a task
 */

  register struct proc *rp;

  if (!isokusern(m_ptr->PROC1)) return(E_BAD_PROC);
  rp = proc_addr(m_ptr->PROC1);

  /* MM has finished one KSIG. */
  if (rp->p_pendcount != 0 && --rp->p_pendcount == 0
      && (rp->p_flags &= ~SIG_PENDING) == 0)
	lock_ready(rp);
  return(OK);
}

/*===========================================================================*
 *				do_copy					     *
 *===========================================================================*/
PRIVATE int do_copy(m_ptr)
register message *m_ptr;	/* pointer to request message */
{
/* Handle sys_copy().  Copy data for MM or FS. */

  int src_proc, dst_proc, src_space, dst_space;
  vir_bytes src_vir, dst_vir;
  phys_bytes src_phys, dst_phys, bytes;

  /* Dismember the command message. */
  src_proc = m_ptr->SRC_PROC_NR;
  dst_proc = m_ptr->DST_PROC_NR;
  src_space = m_ptr->SRC_SPACE;
  dst_space = m_ptr->DST_SPACE;
  src_vir = (vir_bytes) m_ptr->SRC_BUFFER;
  dst_vir = (vir_bytes) m_ptr->DST_BUFFER;
  bytes = (phys_bytes) m_ptr->COPY_BYTES;

  /* Compute the source and destination addresses and do the copy. */
#if (SHADOWING == 0)
  if (src_proc == ABS)
	src_phys = (phys_bytes) m_ptr->SRC_BUFFER;
  else {
	if (bytes != (vir_bytes) bytes)
		/* This would happen for 64K segments and 16-bit vir_bytes.
		 * It would happen a lot for do_fork except MM uses ABS
		 * copies for that case.
		 */
		panic("overflow in count in do_copy", NO_NUM);
#endif

	src_phys = umap(proc_addr(src_proc), src_space, src_vir,
			(vir_bytes) bytes);
#if (SHADOWING == 0)
	}
#endif

#if (SHADOWING == 0)
  if (dst_proc == ABS)
	dst_phys = (phys_bytes) m_ptr->DST_BUFFER;
  else
#endif
	dst_phys = umap(proc_addr(dst_proc), dst_space, dst_vir,
			(vir_bytes) bytes);

  if (src_phys == 0 || dst_phys == 0) return(EFAULT);
  phys_copy(src_phys, dst_phys, bytes);
  return(OK);
}


/*===========================================================================*
 *				do_vcopy				     *
 *===========================================================================*/
PRIVATE int do_vcopy(m_ptr)
register message *m_ptr;	/* pointer to request message */
{
/* Handle sys_vcopy(). Copy multiple blocks of memory */

  int src_proc, dst_proc, vect_s, i;
  vir_bytes src_vir, dst_vir, vect_addr;
  phys_bytes src_phys, dst_phys, bytes;
  cpvec_t cpvec_table[CPVEC_NR];

  /* Dismember the command message. */
  src_proc = m_ptr->m1_i1;
  dst_proc = m_ptr->m1_i2;
  vect_s = m_ptr->m1_i3;
  vect_addr = (vir_bytes)m_ptr->m1_p1;

  if (vect_s > CPVEC_NR) return EDOM;

  src_phys= numap (m_ptr->m_source, vect_addr, vect_s * sizeof(cpvec_t));
  if (!src_phys) return EFAULT;
  phys_copy(src_phys, vir2phys(cpvec_table),
				(phys_bytes) (vect_s * sizeof(cpvec_t)));

  for (i = 0; i < vect_s; i++) {
	src_vir= cpvec_table[i].cpv_src;
	dst_vir= cpvec_table[i].cpv_dst;
	bytes= cpvec_table[i].cpv_size;
	src_phys = numap(src_proc,src_vir,(vir_bytes)bytes);
	dst_phys = numap(dst_proc,dst_vir,(vir_bytes)bytes);
	if (src_phys == 0 || dst_phys == 0) return(EFAULT);
	phys_copy(src_phys, dst_phys, bytes);
  }
  return(OK);
}


/*==========================================================================*
 *				do_gboot				    *
 *==========================================================================*/
PUBLIC struct bparam_s boot_parameters;

PRIVATE int do_gboot(m_ptr)
message *m_ptr;			/* pointer to request message */
{
/* Copy the boot parameters.  Normally only called during fs init. */

  phys_bytes dst_phys;

  dst_phys = umap(proc_addr(m_ptr->PROC1), D, (vir_bytes) m_ptr->MEM_PTR,
				(vir_bytes) sizeof(boot_parameters));
  if (dst_phys == 0) panic("bad call to SYS_GBOOT", NO_NUM);
  phys_copy(vir2phys(&boot_parameters), dst_phys,
				(phys_bytes) sizeof(boot_parameters));
  return(OK);
}


/*===========================================================================*
 *				do_mem					     *
 *===========================================================================*/
PRIVATE int do_mem(m_ptr)
register message *m_ptr;	/* pointer to request message */
{
/* Return the base and size of the next chunk of memory. */

  struct memory *memp;

  for (memp = mem; memp < &mem[NR_MEMS]; ++memp) {
	m_ptr->m1_i1 = memp->base;
	m_ptr->m1_i2 = memp->size;
	m_ptr->m1_i3 = tot_mem_size;
	memp->size = 0;
	if (m_ptr->m1_i2 != 0) break;		/* found a chunk */
  }
  return(OK);
}


/*==========================================================================*
 *				do_umap					    *
 *==========================================================================*/
PRIVATE int do_umap(m_ptr)
register message *m_ptr;	/* pointer to request message */
{
/* Same as umap(), for non-kernel processes. */

  m_ptr->SRC_BUFFER = umap(proc_addr((int) m_ptr->SRC_PROC_NR),
                           (int) m_ptr->SRC_SPACE,
                           (vir_bytes) m_ptr->SRC_BUFFER,
                           (vir_bytes) m_ptr->COPY_BYTES);
  return(OK);
}


/*==========================================================================*
 *				do_trace				    *
 *==========================================================================*/
#define TR_PROCNR	(m_ptr->m2_i1)
#define TR_REQUEST	(m_ptr->m2_i2)
#define TR_ADDR		((vir_bytes) m_ptr->m2_l1)
#define TR_DATA		(m_ptr->m2_l2)
#define TR_VLSIZE	((vir_bytes) sizeof(long))

PRIVATE int do_trace(m_ptr)
register message *m_ptr;
{
/* Handle the debugging commands supported by the ptrace system call
 * The commands are:
 * T_STOP	stop the process
 * T_OK		enable tracing by parent for this process
 * T_GETINS	return value from instruction space
 * T_GETDATA	return value from data space
 * T_GETUSER	return value from user process table
 * T_SETINS	set value from instruction space
 * T_SETDATA	set value from data space
 * T_SETUSER	set value in user process table
 * T_RESUME	resume execution
 * T_EXIT	exit
 * T_STEP	set trace bit
 *
 * The T_OK and T_EXIT commands are handled completely by the memory manager,
 * all others come here.
 */

  register struct proc *rp;
  phys_bytes src, dst;
  int i;

  rp = proc_addr(TR_PROCNR);
  if (rp->p_flags & P_SLOT_FREE) return(EIO);
  switch (TR_REQUEST) {
  case T_STOP:			/* stop process */
	if (rp->p_flags == 0) lock_unready(rp);
	rp->p_flags |= P_STOP;
	rp->p_reg.psw &= ~TRACEBIT;	/* clear trace bit */
	return(OK);

  case T_GETINS:		/* return value from instruction space */
	if (rp->p_map[T].mem_len != 0) {
		if ((src = umap(rp, T, TR_ADDR, TR_VLSIZE)) == 0) return(EIO);
		phys_copy(src, vir2phys(&TR_DATA), (phys_bytes) sizeof(long));
		break;
	}
	/* Text space is actually data space - fall through. */

  case T_GETDATA:		/* return value from data space */
	if ((src = umap(rp, D, TR_ADDR, TR_VLSIZE)) == 0) return(EIO);
	phys_copy(src, vir2phys(&TR_DATA), (phys_bytes) sizeof(long));
	break;

  case T_GETUSER:		/* return value from process table */
	if ((TR_ADDR & (sizeof(long) - 1)) != 0 ||
	    TR_ADDR > sizeof(struct proc) - sizeof(long))
		return(EIO);
	TR_DATA = *(long *) ((char *) rp + (int) TR_ADDR);
	break;

  case T_SETINS:		/* set value in instruction space */
	if (rp->p_map[T].mem_len != 0) {
		if ((dst = umap(rp, T, TR_ADDR, TR_VLSIZE)) == 0) return(EIO);
		phys_copy(vir2phys(&TR_DATA), dst, (phys_bytes) sizeof(long));
		TR_DATA = 0;
		break;
	}
	/* Text space is actually data space - fall through. */

  case T_SETDATA:			/* set value in data space */
	if ((dst = umap(rp, D, TR_ADDR, TR_VLSIZE)) == 0) return(EIO);
	phys_copy(vir2phys(&TR_DATA), dst, (phys_bytes) sizeof(long));
	TR_DATA = 0;
	break;

  case T_SETUSER:			/* set value in process table */
	if ((TR_ADDR & (sizeof(reg_t) - 1)) != 0 ||
	     TR_ADDR > sizeof(struct stackframe_s) - sizeof(reg_t))
		return(EIO);
	i = (int) TR_ADDR;
#if (CHIP == INTEL)
	/* Altering segment registers might crash the kernel when it
	 * tries to load them prior to restarting a process, so do
	 * not allow it.
	 */
	if (i == (int) &((struct proc *) 0)->p_reg.cs ||
	    i == (int) &((struct proc *) 0)->p_reg.ds ||
	    i == (int) &((struct proc *) 0)->p_reg.es ||
#if _WORD_SIZE == 4
	    i == (int) &((struct proc *) 0)->p_reg.gs ||
	    i == (int) &((struct proc *) 0)->p_reg.fs ||
#endif
	    i == (int) &((struct proc *) 0)->p_reg.ss)
		return(EIO);
#endif
	if (i == (int) &((struct proc *) 0)->p_reg.psw)
		/* only selected bits are changeable */
		SETPSW(rp, TR_DATA);
	else
		*(reg_t *) ((char *) &rp->p_reg + i) = (reg_t) TR_DATA;
	TR_DATA = 0;
	break;

  case T_RESUME:		/* resume execution */
	rp->p_flags &= ~P_STOP;
	if (rp->p_flags == 0) lock_ready(rp);
	TR_DATA = 0;
	break;

  case T_STEP:			/* set trace bit */
	rp->p_reg.psw |= TRACEBIT;
	rp->p_flags &= ~P_STOP;
	if (rp->p_flags == 0) lock_ready(rp);
	TR_DATA = 0;
	break;

  default:
	return(EIO);
  }
  return(OK);
}

/*===========================================================================*
 *				cause_sig				     *
 *===========================================================================*/
PUBLIC void cause_sig(proc_nr, sig_nr)
int proc_nr;			/* process to be signalled */
int sig_nr;			/* signal to be sent, 1 to _NSIG */
{
/* A task wants to send a signal to a process.   Examples of such tasks are:
 *   TTY wanting to cause SIGINT upon getting a DEL
 *   CLOCK wanting to cause SIGALRM when timer expires
 * FS also uses this to send a signal, via the SYS_KILL message.
 * Signals are handled by sending a message to MM.  The tasks don't dare do
 * that directly, for fear of what would happen if MM were busy.  Instead they
 * call cause_sig, which sets bits in p_pending, and then carefully checks to
 * see if MM is free.  If so, a message is sent to it.  If not, when it becomes
 * free, a message is sent.  The process being signaled is blocked while MM
 * has not seen or finished with all signals for it.  These signals are
 * counted in p_pendcount, and the SIG_PENDING flag is kept nonzero while
 * there are some.  It is not sufficient to ready the process when MM is
 * informed, because MM can block waiting for FS to do a core dump.
 */

  register struct proc *rp, *mmp;

  rp = proc_addr(proc_nr);
  if (sigismember(&rp->p_pending, sig_nr))
	return;			/* this signal already pending */
  sigaddset(&rp->p_pending, sig_nr);
  ++rp->p_pendcount;		/* count new signal pending */
  if (rp->p_flags & PENDING)
	return;			/* another signal already pending */
  if (rp->p_flags == 0) lock_unready(rp);
  rp->p_flags |= PENDING | SIG_PENDING;
  ++sig_procs;			/* count new process pending */

  mmp = proc_addr(MM_PROC_NR);
  if ( ((mmp->p_flags & RECEIVING) == 0) || mmp->p_getfrom != ANY) return;
  inform();
}


/*===========================================================================*
 *				inform					     *
 *===========================================================================*/
PUBLIC void inform()
{
/* When a signal is detected by the kernel (e.g., DEL), or generated by a task
 * (e.g. clock task for SIGALRM), cause_sig() is called to set a bit in the
 * p_pending field of the process to signal.  Then inform() is called to see
 * if MM is idle and can be told about it.  Whenever MM blocks, a check is
 * made to see if 'sig_procs' is nonzero; if so, inform() is called.
 */

  register struct proc *rp;

  /* MM is waiting for new input.  Find a process with pending signals. */
  for (rp = BEG_SERV_ADDR; rp < END_PROC_ADDR; rp++)
	if (rp->p_flags & PENDING) {
		m.m_type = KSIG;
		m.SIG_PROC = proc_number(rp);
		m.SIG_MAP = rp->p_pending;
		sig_procs--;
		if (lock_mini_send(proc_addr(HARDWARE), MM_PROC_NR, &m) != OK)
			panic("can't inform MM", NO_NUM);
		sigemptyset(&rp->p_pending); /* the ball is now in MM's court */
		rp->p_flags &= ~PENDING;/* remains inhibited by SIG_PENDING */
		lock_pick_proc();	/* avoid delay in scheduling MM */
		return;
	}
}


/*===========================================================================*
 *				umap					     *
 *===========================================================================*/
PUBLIC phys_bytes umap(rp, seg, vir_addr, bytes)
register struct proc *rp;	/* pointer to proc table entry for process */
int seg;			/* T, D, or S segment */
vir_bytes vir_addr;		/* virtual address in bytes within the seg */
vir_bytes bytes;		/* # of bytes to be copied */
{
/* Calculate the physical memory address for a given virtual address. */

  vir_clicks vc;		/* the virtual address in clicks */
  phys_bytes pa;		/* intermediate variables as phys_bytes */
#if (CHIP == INTEL)
  phys_bytes seg_base;
#endif

  /* If 'seg' is D it could really be S and vice versa.  T really means T.
   * If the virtual address falls in the gap,  it causes a problem. On the
   * 8088 it is probably a legal stack reference, since "stackfaults" are
   * not detected by the hardware.  On 8088s, the gap is called S and
   * accepted, but on other machines it is called D and rejected.
   * The Atari ST behaves like the 8088 in this respect.
   */

  if (bytes <= 0) return( (phys_bytes) 0);
  vc = (vir_addr + bytes - 1) >> CLICK_SHIFT;	/* last click of data */

#if (CHIP == INTEL) || (CHIP == M68000)
  if (seg != T)
	seg = (vc < rp->p_map[D].mem_vir + rp->p_map[D].mem_len ? D : S);
#else
  if (seg != T)
	seg = (vc < rp->p_map[S].mem_vir ? D : S);
#endif

  if((vir_addr>>CLICK_SHIFT) >= rp->p_map[seg].mem_vir+ rp->p_map[seg].mem_len)
	return( (phys_bytes) 0 );
#if (CHIP == INTEL)
  seg_base = (phys_bytes) rp->p_map[seg].mem_phys;
  seg_base = seg_base << CLICK_SHIFT;	/* segment origin in bytes */
#endif
  pa = (phys_bytes) vir_addr;
#if (CHIP != M68000)
  pa -= rp->p_map[seg].mem_vir << CLICK_SHIFT;
  return(seg_base + pa);
#endif
#if (CHIP == M68000)
#if (SHADOWING == 0)
  pa -= (phys_bytes)rp->p_map[seg].mem_vir << CLICK_SHIFT;
  pa += (phys_bytes)rp->p_map[seg].mem_phys << CLICK_SHIFT;
#else
  if (rp->p_shadow && seg != T) {
	pa -= (phys_bytes)rp->p_map[D].mem_phys << CLICK_SHIFT;
	pa += (phys_bytes)rp->p_shadow << CLICK_SHIFT;
  }
#endif
  return(pa);
#endif
}


/*==========================================================================*
 *				numap					    *
 *==========================================================================*/
PUBLIC phys_bytes numap(proc_nr, vir_addr, bytes)
int proc_nr;			/* process number to be mapped */
vir_bytes vir_addr;		/* virtual address in bytes within D seg */
vir_bytes bytes;		/* # of bytes required in segment  */
{
/* Do umap() starting from a process number instead of a pointer.  This
 * function is used by device drivers, so they need not know about the
 * process table.  To save time, there is no 'seg' parameter. The segment
 * is always D.
 */

  return(umap(proc_addr(proc_nr), D, vir_addr, bytes));
}


#if (CHIP == INTEL)
/*==========================================================================*
 *				alloc_segments				    *
 *==========================================================================*/
PUBLIC void alloc_segments(rp)
register struct proc *rp;
{
/* This is called only by do_newmap, but is broken out as a separate function
 * because so much is hardware-dependent.
 */

  phys_bytes code_bytes;
  phys_bytes data_bytes;
  int privilege;

  if (protected_mode) {
	data_bytes = (phys_bytes) (rp->p_map[S].mem_vir + rp->p_map[S].mem_len)
	             << CLICK_SHIFT;
	if (rp->p_map[T].mem_len == 0)
		code_bytes = data_bytes;	/* common I&D, poor protect */
	else
		code_bytes = (phys_bytes) rp->p_map[T].mem_len << CLICK_SHIFT;
	privilege = istaskp(rp) ? TASK_PRIVILEGE : USER_PRIVILEGE;
	init_codeseg(&rp->p_ldt[CS_LDT_INDEX],
		     (phys_bytes) rp->p_map[T].mem_phys << CLICK_SHIFT,
		     code_bytes, privilege);
	init_dataseg(&rp->p_ldt[DS_LDT_INDEX],
		     (phys_bytes) rp->p_map[D].mem_phys << CLICK_SHIFT,
		     data_bytes, privilege);
	rp->p_reg.cs = (CS_LDT_INDEX * DESC_SIZE) | TI | privilege;
#if _WORD_SIZE == 4
	rp->p_reg.gs =
	rp->p_reg.fs =
#endif
	rp->p_reg.ss =
	rp->p_reg.es =
	rp->p_reg.ds = (DS_LDT_INDEX*DESC_SIZE) | TI | privilege;
  } else {
	rp->p_reg.cs = click_to_hclick(rp->p_map[T].mem_phys);
	rp->p_reg.ss =
	rp->p_reg.es =
	rp->p_reg.ds = click_to_hclick(rp->p_map[D].mem_phys);
  }
}
#endif /* (CHIP == INTEL) */
