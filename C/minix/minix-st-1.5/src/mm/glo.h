/* EXTERN should be extern except in table.c */
#ifdef _TABLE
#undef EXTERN
#define EXTERN
#endif

/* Global variables. */
EXTERN struct mproc *mp;	/* ptr to 'mproc' slot of current process */
EXTERN int dont_reply;		/* normally 0; set to 1 to inhibit reply */
EXTERN int procs_in_use;	/* how many processes are marked as IN_USE */

/* The parameters of the call are kept here. */
EXTERN message mm_in;		/* the incoming message itself is kept here. */
EXTERN message mm_out;		/* the reply message is built up here. */
EXTERN int who;			/* caller's proc number */
EXTERN int mm_call;		/* system call number */

/* The following variables are used for returning results to the caller. */
EXTERN int err_code;		/* temporary storage for error number */
EXTERN int result2;		/* secondary result */
EXTERN char *res_ptr;		/* result, if pointer */

extern int (*call_vec[])();	/* functions to handle system calls */
extern char core_name[];	/* file name where core images are produced */
extern unshort core_bits;	/* which signals cause core images */
EXTERN char mm_stack[MM_STACK_BYTES];	/* MM's stack */

/* Library variables. */
extern int errno;

