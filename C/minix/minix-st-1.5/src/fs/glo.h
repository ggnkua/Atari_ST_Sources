/* EXTERN should be extern except for the table file */
#ifdef _TABLE
#undef EXTERN
#define EXTERN
#endif

/* File System global variables */
EXTERN struct fproc *fp;	/* pointer to caller's fproc struct */
EXTERN int super_user;		/* 1 if caller is super_user, else 0 */
EXTERN int dont_reply;		/* normally 0; set to 1 to inhibit reply */
EXTERN int susp_count;		/* number of procs suspended on pipe */
EXTERN int reviving;		/* number of pipe processes to be revived */
EXTERN off_t rdahedpos;		/* position to read ahead */
EXTERN struct inode *rdahed_inode;	/* pointer to inode to read ahead */
EXTERN char fstack[FS_STACK_BYTES];	/* the File System's stack. */

/* The parameters of the call are kept here. */
EXTERN message m;		/* the input message itself */
EXTERN message m1;		/* the output message used for reply */
EXTERN int who;			/* caller's proc number */
EXTERN int fs_call;		/* system call number */
EXTERN char user_path[PATH_MAX];/* storage for user path name */

/* The following variables are used for returning results to the caller. */
EXTERN int err_code;		/* temporary storage for error number */
EXTERN int rdwt_err;		/* status of last disk i/o request */

/* Data which needs initialization. */
typedef unsigned short u16_t;	/* belongs in h/type.h */
extern u16_t data_org[INFO + 2];/* origin and sizes of init */
				/* belongs in h/build.h */
extern int (*call_vector[])();	/* table of system calls handled by FS */
extern max_major;		/* maximum major device (+ 1) */
