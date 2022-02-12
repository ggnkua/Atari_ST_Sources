/* EXTERN should be extern except in table.c */
#ifdef _TABLE
#undef EXTERN
#define EXTERN
#endif

/* Global variables. */
EXTERN struct mproc *mp;	/* ptr to 'mproc' slot of current process */
EXTERN int procs_in_use;	/* how many processes are marked as IN_USE */

/* The parameters of the call are kept here. */
EXTERN message mm_in;		/* the incoming message itself is kept here. */
EXTERN int who;			/* caller's proc number */
EXTERN int mm_call;		/* system call number */

extern _PROTOTYPE (int (*call_vec[]), (void) );	/* system call handlers */
extern char core_name[];	/* file name where core images are produced */
EXTERN sigset_t core_sset;	/* which signals cause core images */
EXTERN sigset_t ign_sset;	/* which signals are by default ignored */

#if OPTIMIZE_FOR_SPEED
EXTERN struct mproc *mproc_ptr[NR_PROCS];	/* to avoid mul/div */
#define	mproc_addr(p)	mproc_ptr[(p)]
#else
#define	mproc_addr(p)	&mproc[(p)]
#endif /* OPTIMIZE_FOR_SPEED */
