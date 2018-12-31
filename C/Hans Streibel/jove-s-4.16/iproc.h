/************************************************************************
 * This program is Copyright (C) 1986-1996 by Jonathan Payne.  JOVE is  *
 * provided to you without charge, and with no warranty.  You may give  *
 * away copies of JOVE, including sources, provided that this notice is *
 * included in all the files.                                           *
 ************************************************************************/

#ifdef IPROCS	/* the body is the rest of this file */

typedef struct process	*Process;	/* process reference (opaque type) */

# ifdef PIPEPROCS

extern char	Portsrv[FILESIZE];	/* path to portsrv program (in LibDir) */

extern int  NumProcs;

#  define KBDSIG		SIGUSR1	/* used for shoulder tapping */

/* Messages from kbd and portsrv to jove.
 * We depend on writes to a pipe being atomic.
 * This seems to be the case if the write is short enough (<4k?)
 * but not documented in the UNIX manuals.
 */

struct header {
	pid_t	pid;	/* sender */
	int	nbytes;	/* data length */
};

struct lump {
	struct header	header;
	char	data[128];	/* data being sent */
};

extern File	*ProcInput;
extern pid_t	kbd_pid;

extern void	kbd_strt proto((void));
extern bool	kbd_stop proto((void));
extern void	read_pipe_proc proto((pid_t, int));
extern void	kbd_kill proto((void));

# else /* !PIPEPROCS */

extern void	read_pty_proc proto((int));

extern SIGRESTYPE	sigchld_handler proto((int));
extern volatile bool	procs_to_reap;
extern void	reap_procs proto((void));

# endif /* !PIPEPROCS */

extern void
	closeiprocs proto((void)),
	untieDeadProcess proto((Buffer *));

extern bool
	KillProcs proto((void));

extern const char
	*dbxness proto((Process)),
	*pstate proto((Process));

extern pid_t	DeadPid;	/* info about ChildPid, if reaped by kill_off */
extern wait_status_t	DeadStatus;

extern void
	kill_off proto((pid_t, wait_status_t));

/* Commands: */
extern void
	ProcInt proto((void)),
	DBXpoutput proto((void)),
	Iprocess proto((void)),
	ShellProc proto((void)),
	ProcQuit proto((void)),
	ProcKill proto((void)),
# ifdef PTYPROCS
	ProcCont proto((void)),
	ProcDStop proto((void)),
	ProcEof proto((void)),
	ProcStop proto((void)),
# endif
	ProcSendData proto((void)),
	ProcNewline proto((void)),
	ProcList proto((void));

/* Variables: */

extern char
	proc_prompt[128],	/* VAR: process prompt */
	dbx_parse_fmt[128];	/* VAR: dbx-mode parse string */

#endif /* IPROCS */
