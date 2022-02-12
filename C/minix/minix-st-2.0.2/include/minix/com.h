/* System calls. */
#define SEND		   1	/* function code for sending messages */
#define RECEIVE		   2	/* function code for receiving messages */
#define BOTH		   3	/* function code for SEND + RECEIVE */
#define ANY   (NR_PROCS+100)	/* receive(ANY, buf) accepts from any source */

/* Task numbers, function codes and reply codes. */

/* The values of several task numbers depend on whether they or other tasks
 * are enabled.  They are defined as (PREVIOUS_TASK - ENABLE_TASK) in general.
 * ENABLE_TASK is either 0 or 1, so a task either gets a new number, or gets
 * the same number as the previous task and is further unused.
 * The TTY task must always have the most negative number so that it is
 * initialized first.  Many of the TTY function codes are shared with other
 * tasks.
 */

#define TTY		(DL_ETH - 1)
				/* terminal I/O class */
#	define CANCEL       0	/* general req to force a task to cancel */
#	define HARD_INT     2	/* fcn code for all hardware interrupts */
#	define DEV_READ	    3	/* fcn code for reading from tty */
#	define DEV_WRITE    4	/* fcn code for writing to tty */
#	define DEV_IOCTL    5	/* fcn code for ioctl */
#	define DEV_OPEN     6	/* fcn code for opening tty */
#	define DEV_CLOSE    7	/* fcn code for closing tty */
#	define SCATTERED_IO 8	/* fcn code for multiple reads/writes */
#	define TTY_SETPGRP  9	/* fcn code for setpgroup */
#	define TTY_EXIT	   10	/* a process group leader has exited */	
#	define OPTIONAL_IO 16	/* modifier to DEV_* codes within vector */
#	define SUSPEND	 -998	/* used in interrupts when tty has no data */

#define DL_ETH		(DOSDSK - ENABLE_NETWORKING)
				/* networking task */

/* Message type for data link layer reqests. */
#	define DL_WRITE		3
#	define DL_WRITEV	4
#	define DL_READ		5
#	define DL_READV		6
#	define DL_INIT		7
#	define DL_STOP		8
#	define DL_GETSTAT	9

/* Message type for data link layer replies. */
#	define DL_INIT_REPLY	20
#	define DL_TASK_REPLY	21

#	define DL_PORT		m2_i1
#	define DL_PROC		m2_i2
#	define DL_COUNT		m2_i3
#	define DL_MODE		m2_l1
#	define DL_CLCK		m2_l2
#	define DL_ADDR		m2_p1
#	define DL_STAT		m2_l1

/* Bits in 'DL_STAT' field of DL replies. */
#	define DL_PACK_SEND	0x01
#	define DL_PACK_RECV	0x02
#	define DL_READ_IP	0x04

/* Bits in 'DL_MODE' field of DL requests. */
#	define DL_NOMODE	0x0
#	define DL_PROMISC_REQ	0x2
#	define DL_MULTI_REQ	0x4
#	define DL_BROAD_REQ	0x8

#	define NW_OPEN		DEV_OPEN
#	define NW_CLOSE		DEV_CLOSE
#	define NW_READ		DEV_READ
#	define NW_WRITE		DEV_WRITE
#	define NW_IOCTL		DEV_IOCTL
#	define NW_CANCEL	CANCEL

#define DOSDSK		(CDROM - ENABLE_DOSDSK)
				/* DOS virtual disk device task */

#define CDROM		(AUDIO - ENABLE_CDROM)
				/* cd-rom device task */

#define AUDIO		(MIXER - ENABLE_AUDIO)
#define MIXER		(SCSI - ENABLE_AUDIO)
				/* audio & mixer device tasks */

#define SCSI		(WINCHESTER - ENABLE_SCSI)
				/* scsi device task */

#define WINCHESTER	(SYN_ALRM_TASK - ENABLE_WINI)
				/* winchester (hard) disk class */

#define SYN_ALRM_TASK     -8	/* task to send CLOCK_INT messages */

#define IDLE              -7	/* task to run when there's nothing to run */

#define PRINTER           -6	/* printer I/O class */

#define FLOPPY            -5	/* floppy disk class */

#define MEM               -4	/* /dev/ram, /dev/(k)mem and /dev/null class */
#       define NULL_MAJOR  1	/* major device for /dev/null */
#	define RAM_DEV     0	/* minor device for /dev/ram */
#	define MEM_DEV     1	/* minor device for /dev/mem */
#	define KMEM_DEV    2	/* minor device for /dev/kmem */
#	define NULL_DEV    3	/* minor device for /dev/null */

#define CLOCK             -3	/* clock class */
#	define SET_ALARM   1	/* fcn code to CLOCK, set up alarm */
#	define GET_TIME	   3	/* fcn code to CLOCK, get real time */
#	define SET_TIME	   4	/* fcn code to CLOCK, set real time */
#	define GET_UPTIME  5	/* fcn code to CLOCK, get uptime */
#	define SET_SYNC_AL 6	/* fcn code to CLOCK, set up alarm which */
				/* times out with a send */
#	define REAL_TIME   1	/* reply from CLOCK: here is real time */
#	define CLOCK_INT   HARD_INT
				/* this code will only be sent by */
				/* SYN_ALRM_TASK to a task that requested a */
				/* synchronous alarm */

#define SYSTASK           -2	/* internal functions */
#	define SYS_XIT        1	/* fcn code for sys_xit(parent, proc) */
#	define SYS_GETSP      2	/* fcn code for sys_sp(proc, &new_sp) */
#	define SYS_OLDSIG     3	/* fcn code for sys_oldsig(proc, sig) */
#	define SYS_FORK       4	/* fcn code for sys_fork(parent, child) */
#	define SYS_NEWMAP     5	/* fcn code for sys_newmap(procno, map_ptr) */
#	define SYS_COPY       6	/* fcn code for sys_copy(ptr) */
#	define SYS_EXEC       7	/* fcn code for sys_exec(procno, new_sp) */
#	define SYS_TIMES      8	/* fcn code for sys_times(procno, bufptr) */
#	define SYS_ABORT      9	/* fcn code for sys_abort() */
#	define SYS_FRESH     10	/* fcn code for sys_fresh()  (Atari only) */
#	define SYS_KILL      11	/* fcn code for sys_kill(proc, sig) */
#	define SYS_GBOOT     12	/* fcn code for sys_gboot(procno, bootptr) */
#	define SYS_UMAP      13	/* fcn code for sys_umap(procno, etc) */
#	define SYS_MEM       14	/* fcn code for sys_mem() */
#	define SYS_TRACE     15	/* fcn code for sys_trace(req,pid,addr,data) */
#	define SYS_VCOPY     16	/* fnc code for sys_vcopy(src_proc, dest_proc,
				   vcopy_s, vcopy_ptr) */
#	define SYS_SENDSIG   17	/* fcn code for sys_sendsig(&sigmsg) */
#	define SYS_SIGRETURN 18	/* fcn code for sys_sigreturn(&sigmsg) */
#	define SYS_ENDSIG    19	/* fcn code for sys_endsig(procno) */
#	define SYS_GETMAP    20	/* fcn code for sys_getmap(procno, map_ptr) */

#define HARDWARE          -1	/* used as source on interrupt generated msgs*/

/* Names of message fields for messages to CLOCK task. */
#define DELTA_TICKS    m6_l1	/* alarm interval in clock ticks */
#define FUNC_TO_CALL   m6_f1	/* pointer to function to call */
#define NEW_TIME       m6_l1	/* value to set clock to (SET_TIME) */
#define CLOCK_PROC_NR  m6_i1	/* which proc (or task) wants the alarm? */
#define SECONDS_LEFT   m6_l1	/* how many seconds were remaining */

/* Names of message fields used for messages to block and character tasks. */
#define DEVICE         m2_i1	/* major-minor device */
#define PROC_NR        m2_i2	/* which (proc) wants I/O? */
#define COUNT          m2_i3	/* how many bytes to transfer */
#define REQUEST        m2_i3	/* ioctl request code */
#define POSITION       m2_l1	/* file offset */
#define ADDRESS        m2_p1	/* core buffer address */

/* Names of message fields for messages to TTY task. */
#define TTY_LINE       DEVICE	/* message parameter: terminal line */
#define TTY_REQUEST    COUNT	/* message parameter: ioctl request code */
#define TTY_SPEK       POSITION	/* message parameter: ioctl speed, erasing */
#define TTY_FLAGS      m2_l2	/* message parameter: ioctl tty mode */
#define TTY_PGRP       m2_i3	/* message parameter: process group */	

/* Names of the message fields for QIC 02 status reply from tape driver */
#define TAPE_STAT0	m2_l1
#define TAPE_STAT1	m2_l2

/* Names of messages fields used in reply messages from tasks. */
#define REP_PROC_NR    m2_i1	/* # of proc on whose behalf I/O was done */
#define REP_STATUS     m2_i2	/* bytes transferred or error number */

/* Names of fields for copy message to SYSTASK. */
#define SRC_SPACE      m5_c1	/* T or D space (stack is also D) */
#define SRC_PROC_NR    m5_i1	/* process to copy from */
#define SRC_BUFFER     m5_l1	/* virtual address where data come from */
#define DST_SPACE      m5_c2	/* T or D space (stack is also D) */
#define DST_PROC_NR    m5_i2	/* process to copy to */
#define DST_BUFFER     m5_l2	/* virtual address where data go to */
#define COPY_BYTES     m5_l3	/* number of bytes to copy */

/* Field names for accounting, SYSTASK and miscellaneous. */
#define USER_TIME      m4_l1	/* user time consumed by process */
#define SYSTEM_TIME    m4_l2	/* system time consumed by process */
#define CHILD_UTIME    m4_l3	/* user time consumed by process' children */
#define CHILD_STIME    m4_l4	/* sys time consumed by process' children */
#define BOOT_TICKS     m4_l5	/* number of clock ticks since boot time */

#define PROC1          m1_i1	/* indicates a process */
#define PROC2          m1_i2	/* indicates a process */
#define PID            m1_i3	/* process id passed from MM to kernel */
#define STACK_PTR      m1_p1	/* used for stack ptr in sys_exec, sys_getsp */
#define PR             m6_i1	/* process number for sys_sig */
#define SIGNUM         m6_i2	/* signal number for sys_sig */
#define FUNC           m6_f1	/* function pointer for sys_sig */
#define MEM_PTR        m1_p1	/* tells where memory map is for sys_newmap */
#define NAME_PTR       m1_p2	/* tells where program name is for dmp */
#define IP_PTR	       m1_p3	/* initial value for ip after exec */
#define SIG_PROC       m2_i1	/* process number for inform */
#define SIG_MAP        m2_l1	/* used by kernel for passing signal bit map */
#define SIG_MSG_PTR    m1_i1	/* pointer to info to build sig catch stack */
#define SIG_CTXT_PTR   m1_p1	/* pointer to info to restore signal context */
