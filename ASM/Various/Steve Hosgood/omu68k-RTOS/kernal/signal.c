/******************************************************************************
 *	Signal.c	All signal related stuff
 ******************************************************************************
 *
 *	The signal table is held in the process table and is an array
 *	of function addresses.
 *	If 0 then the default signal is caried out (termination sometimes
 *	with core).
 *	If bit 0 is 1 then the signal is ignored
 *	Else the apropriate function is called
 *	Note signals available are 1 - 31 ( 0 is not used )
 *
 *	Note the tty handler will set the process controlling tty number
 *	on the open of a tty into file channel 0.
 *	This is used to direct process group signals such as SIGQUIT to
 *	all processes using this tty as control.
 *	Note all processes without a controling tty have the console
 *	(tty 0) given to them.
 *
 *	Note generaly a signal is only flaged not immediatly executed
 *	Execution will be done by checkmev() at certain places in the
 *	kernal (after wrapper() tick() and after any interupt routine that
 *	could cause a signal).
 *	Note because of the "C" signal call library operation, which
 *	maintains an internal jump table for the caught signals,
 *	a signal should not be acted upon during a kernel "signal"
 *	system call, else the internal jump table and the kernels
 *	table will not be the same, with dire consequences.
 *	It should only return an error if comeing out of a sleep
 *	to process the signal realy.
 *
 *	Calluser()	Calls a user function caught via a signal
 *
 *	This bit is extremely and uterly horible, because it is legit
 *	to long jump from a caught signal to another user function.
 *	What this bit does is to copy the state of the processor as
 *	saved in u_regs on the system stack, onto the user stack so
 *	that the long jump bit can get rid of it if so required.
 *	The system stack is set back to the previous state and a call
 *	is made to the user function. If this call returns (no long jump)
 *	then the state on the user stack will be retrieved and the system
 *	will return to the system call in progress when
 *	the signal was caught. Puke!
 *	Note an error should be flaged useing error() if the process was
 *	woken up to process the signal
 *
 *	Special bits OMU: Note 4 arguments can be passed to the returning
 *	signal call, by default the first argument is the signal number,
 *	the following arguments are speciphic to the signal.
 *	These are used specificaly for the SIGEVFILE, and SIGEVCOMMS signals.
 *	Note with the SIGEVFILE signal there is a race hazard, such that if a
 *	signal is pending and another one arives then the later one is ignored.
 *	If SIGEVCOMMS is used via the coms() syscall then a -1 will be returned
 *	If the process has still to acknowledge the last coms.
 *
 */
 

# include	"../include/param.h"
# include	"../include/inode.h"
# include	"../include/signal.h"
# include	"../include/procs.h"
# include	"../include/state.h"
# include	<errno.h>

extern	char	swtchflag;

/*
 *	Sigmode()	Sets mode of signal operation
 */
sigmode(smode)
int	smode;
{
	int	osmode;

	osmode = cur_proc->sigmode;
	cur_proc->sigmode = smode;
	return osmode;
}

/*
 *	Sigmask()	Masks selected signals
 */
sigmask(smask)
unsigned long	smask;
{
	unsigned long	osmask;

	osmask = cur_proc->sigmask;
	smask &= ~(1 << SIGKILL);	/* Does not mask kill signal */
	cur_proc->sigmask = smask;
	return osmask;
}

/*
 *	Checkev()	Checks if any event has occured if so do event
 *			Note processor registers d0 and d1 are used
 *			thus if calling before or after wrapper these
 *			need to be saved before calling.
 *			Mode indicates which events are to be checked
 *			EVSWTCH		Process switching allowed
 *			EVSIGQUIT	Quit signals
 *			EVSIGUSER	User caught signals
 *			Note this rotine will check all the events
 *			even if the software mask smask is masking
 *			action on these events. Call checkmev() for
 *			normal event checkeing.
 *			Returns 0 normaly, or the signal number if a
 *			signal was processed.
 */
checkev(mode)
int	mode;
{
	int	err;

	/* Check and act upon any signals for this process */
	err = psig(mode);

	/* If process switch required do this bit */
	if(mode & EVSWTCH){
		/* Checks if process switch is required and allowed */
		if(swtchflag) pswitch(-1);
	}
	return err;
}

/*
 *	Checkmev()	Check events which are not masked off by the software
 *			process mask smask.
 */
checkmev(){
	int	mode;

	/* Gets in mode bit mask of all posible events to be checked */
	mode = ~cur_proc->smask & EVALL;

	return checkev(mode);
}

/*
 *	Signal()	Sets up signal function call addresses (system call)
 */
int (*signal(sig,func))()
int sig;
int (*func)();
{
	int (*oldsig)();

	/* Checks if signal is valid if so sets it */
	if((sig < 1) || (sig >= NSIG)) return (int (*)())error(BADSIG);
	if(sig == SIGKILL) return (int (*)())error(BADSIG);
	oldsig = cur_proc->signals[sig].func;

	/* Checks if function address is legit ie within user text area
	 * unless default or ignore signal address.
	 */
	if((func != SIG_DFL) && (func != SIG_IGN)){
		if((cur_proc->psize.entry > (long)func) ||
			((cur_proc->psize.entry + cur_proc->psize.tsize) < (long)func))
			return (int (*)())error(BADSIG);
	}
	cur_proc->signals[sig].func = func;
	return oldsig;
}

/*
 *	Alarm()		Alarm system call, Sets up alarm time.
 */

alarm(seconds)
long seconds;
{
	long sec;

	/* Save old value for return and set new value */
	sec = cur_proc->alarm;
	cur_proc->alarm = seconds;
	return sec;
}

/*
 *	Sendgrp()	Sends a signal to all processes with tty as
 *			controlling terminal. Except process 0 (ie Kernel)
 *			If flag "dosig" is not 0  then actualy do the signal.
 */
sendgrp(tty, sig, dosig)
int tty;
int sig;
char dosig;
{
	struct procs *proc;
	short pid;

	/* Work through process table sending signals to apropriate
	 * processes note signals are acted upon later.
	 */
	proc = &proc_table[1];
	for(pid = 1; pid < NPROC; pid++){
		/* If a process entry exists and is corect tty then set signal*/
		if(((proc->stat == SRUN) || (proc->stat == SSLEEP)) &&
			(proc->tty == tty)){
			proc->sig |= 1<<(sig);
			proc->pri = PSIGNAL;
			proc->stat = SRUN;

			/* Indicate Process switch is required
			 */
			swtchflag = 1;
			if(dosig) pswitch(proc->pid); /* Do signal if required */
		}
		proc++;
	}
}
/*
 *	Sendsig()	Send a signal to a particular process
 *			If dosig is not 0 then actualy do the signal; 
 */
sendsig(pid,sig,dosig)
short pid;
long sig;
char dosig;
{
	struct procs *proc;

	if(pid == 0) return;
	proc = &proc_table[pid];
	/* If process id given send signal to that one only */
	if((proc->stat == SRUN) || (proc->stat == SSLEEP)){
		proc->sig |= 1<<(sig);
		proc->pri = PSIGNAL;
		proc->stat = SRUN;

		/* Indicate Process switch is required
		 */
		swtchflag = 1;
		if(dosig){
			/* If proccess is in core and locked, do signal */
			if((proc->flag & SLOAD) && (proc->flag & (SLOCK|SULOCK)))
			pswitch(pid);
		}
	}
}

/*
 *	Anysig()	Checks to see if any process has a signal pending
 *			returns process number if found -1 if not
 */
anysig(){
	struct procs *proc;
	short pid;

	/* Workthrough process table checking on signals
	 */
	proc = &proc_table[1];
	for(pid = 1; pid < NPROC; pid++){
		/* If a process entry exists and has signal return */
		if(((proc->stat == SRUN) || (proc->stat == SSLEEP))){
			if(issig(proc)) return pid;
		}
		proc++;
	}
	return -1;
}

/*
 *	Issig()		Checks if signal pending if so returns number
 *			Ignores ignored signals
 */
issig(proc)
struct procs *proc;
{
	int n;

	/* Check all signals recieved ignore defered ones */
	while(proc->sig){
		if(!(n = fsig(proc))) return 0;
		if(!SIGISDEFER(proc->signals[n].func)) return n;
		else proc->sig &= ~(1<<(n));
	}
	return 0;
}

/*
 *	Istermsig()	Checks if signal pending and is a default signal
 *			and not masked, if so returns number,
 *			ignores ignored signals.
 */
istermsig(proc)
struct procs *proc;
{
	unsigned long i,n;

	/* Check for default signals recieved ignore defered ones and masked
	 * ones
	 */
	n = 1;
	for(i = 0; i < NSIG; i++){
		if((proc->sig & n) && (!(proc->sigmask & n))){
			if(SIG_DFL == proc->signals[i].func) return i;
			if(SIGISDEFER(proc->signals[i].func)) proc->sig &= ~n;
		}
		n <<= 1;
	}
	return 0;
}

/*
 *	Fsig()		Find signal number pending 1 - 31 (0 is no signal)
 *			Ignores Masked signals.
 */
fsig(proc)
struct procs *proc;
{
	unsigned long i,n;

	n = 1;
	for(i = 0; i < NSIG; i++){
		if((proc->sig & n) && (!(proc->sigmask & n))) return i;
		n <<= 1;
	}
	return 0;
}

/*
 *	Psig()		Process signal perform action as required
 *			Called when curent process is in core only
 *			Normally at the beginning and end of system calls
 *			If mode is EVSIGUSER will check all signals
 *			If mode is EVSIGQUIT will only check quit signals
 *			If process is not in core and pisg() is called,
 *			psig() will return and process the signal
 *			at a later time when the process is in core.
 *			Returns 0 normaly, or the signal number if a user
 *			caught signal was processed.
 *			Psig() only processes signals that are not masked
 *			by the process table entry sigmask.
 *			If the signal mode for the current process is
 *			set to SIGMODEOMU, then when a user caught signal
 *			is processed all signals are masked.
 *			If the caught signal returns then the signal mask
 *			is set back to the original value, else the
 *			user should reset it by means of the sigmask()
 *			system call.
 *			Signals are NOT set back to default condition
 *			when in SIGMODEOMU.
 */
psig(mode)
int	mode;
{
# define	SIGTNONE	0	/* No action */
# define	SIGTQUIT	1	/* Signal causes a process exit */
# define	SIGTCORE	2	/* Signal causes core and exit */
# define	SIGTUSER	3	/* Signal calls a user function */
	int	sig, e, a1, a2, a3;
	int	(*func)();
	char	type;
	short	smask, imask;
	unsigned long	ssigmask;

	sig = 0;
	/* Check if signal exists given the mode */
	if(mode & EVSIGUSER){
		sig = issig(cur_proc);
	}
	else if(mode & EVSIGQUIT){
		sig = istermsig(cur_proc);
	}

	/* If no valid signal return */
	if(!sig) return 0;

	/* If signal is masked ignore for now NORE: checked in issig aswell */
	if(cur_proc->sigmask & (1<<sig)) return 0;

	/* If process is not in core don't do signals, wait until
	 * The process is pulled back into core
	 */
	if(!(cur_proc->flag & SLOAD)) return 0;

	/* Disables process switch and No interupts */
	smask = smaskon(cur_proc, EVALL);
	imask = spl6();

	type = SIGTNONE;
	a1 = a2 = a3 = 0;

	/* Awake process */
	cur_proc->stat = SRUN;

	cur_proc->sig &= ~(1<<(sig));		/* Acknowledge signal */
	func = cur_proc->signals[sig].func;

	switch(sig){
		/* Signals producing core and that are reset when caught */
		case SIGQUIT:
		case SIGIOT:
		case SIGEMT:
		case SIGFPE:
		case SIGBUS:
		case SIGSEGV:
		case SIGSYS:
			/* Sets back to default if not SIGMODEOMU */
			if(cur_proc->sigmode != SIGMODEOMU){
				cur_proc->signals[sig].func = SIG_DFL;
			}

			/* If signal caught then jump to function */
			if(func) type = SIGTUSER;
			else type = SIGTCORE;
			break;

		/* Signals producing core but that are NOT reset when caught */
		case SIGILL:
		case SIGTRAP:
			/* If signal caught then jump to function */
			if(func) type = SIGTUSER;
			else type = SIGTCORE;
			break;

		/* Special kill process */
		case SIGKILL:
			type = SIGTCORE;
			break;

		case SIGEVFILE:
			/* Call process with appropriate args no process quit */
			/* Calculates next file pending */
			for(e = 0; e < 32; e++)
				if(cur_proc->evfile & (1<<e)) break;
			a1 = e;

			/* Clears event bits to acknowledge event call */
			cur_proc->evfile &= ~(1<<e);

			/* Sets back to default if not SIGMODEOMU */
			if(cur_proc->sigmode != SIGMODEOMU){
				cur_proc->signals[sig].func = SIG_DFL;
			}

			/* If file events are still pending renable signal */
			if(cur_proc->evfile) cur_proc->sig |= (1<<SIGEVFILE);
			if(func) type = SIGTUSER;
			break;

		case SIGEVCOMMS:
			/* Call process with appropriate args no quit */
			a1 = cur_proc->evcoma[0];
			a2 = cur_proc->evcoma[1];
			a3 = cur_proc->evcoma[2];

			/* Clears event bits to acknowledge event call */
			cur_proc->evcom = 0;
#ifdef TEVENT
printf("COMMS CALLING USER FUNC\n");
#endif
			/* Sets back to default if not SIGMODEOMU */
			if(cur_proc->sigmode != SIGMODEOMU){
				cur_proc->signals[sig].func = SIG_DFL;
			}

			if(func) type = SIGTUSER;
#ifdef TEVENT
printf("COMMS RETURNED USER FUNC\n");
#endif
			break;

		default:
			/* Sets back to default if not SIGMODEOMU */
			if(cur_proc->sigmode != SIGMODEOMU){
				cur_proc->signals[sig].func = SIG_DFL;
			}

			/* If signal caught then jump to function */
			if(func) type = SIGTUSER;
			else type = SIGTQUIT;
	}

	/* Renable interupts and process switch as decision has been made */
	splx(imask);
	smaskoff(cur_proc, smask);

	/* Do appropriate action */
	switch(type){
	case SIGTCORE:
		core();
		kexit(sig);
		break;

	case SIGTQUIT:
		kexit(sig);
		break;

	case SIGTUSER:
		/* If process is awaiting an event ignore it. */
		cur_proc->wchan = 0;

		/* If special signal mode mask this signals during user
		 * signal processing and return to normal at end.
		 */
		if(cur_proc->sigmode == SIGMODEOMU){
			ssigmask = cur_proc->sigmask;
#ifdef	MASKALL
			/* Mask all signals except kill signal */
			cur_proc->sigmask = MASKALLSIG & ~(1 << SIGKILL);
#else
			/* This signal */
			cur_proc->sigmask |= (1 << sig);
#endif
		}

		calluser(func, sig, a1, a2, a3);

		if(cur_proc->sigmode == SIGMODEOMU) cur_proc->sigmask = ssigmask;
		break;
	}
	return sig;
}

/*
 *	Core()		Does absolutely nothing!
 */
core(){
}
