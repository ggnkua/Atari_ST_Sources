/******************************************************************************
 *	Concur.c	Concurent routines	T.Barnaby 
 ******************************************************************************
 *
 *	All concurancy related routines are contained within these bounds.
 *	Major routines are pswitch() which performs all process switching,
 *	sleep() which will send a process to sleep, wakeup() which will
 *	wakeup a sleeping process() etc.
 *	Also included is newproc() which will create a new process as an
 *	image of its parent.
 */
# include	"../include/param.h"
# include	"../include/inode.h"
# include	"../include/signal.h"
# include	"../include/procs.h"
# include	"../include/excep.h"
# include	"../include/memory.h"
# include	<errno.h>
# include	"../include/state.h"

short	tickcount;		/* Ticker counter */
short	second;			/* Second counter */
short	tickmach;		/* Machine tick (approx 30 secs ) */
long	systime;		/* System time */
char	swtchflag;		/* Indicates process switch should occur */


/******************************************************************************
 *	Tick()		20ms system tick
 ******************************************************************************
 *
 *	Called via tick interupt wapper every 20ms (Eltec board)
 *	Does some system checking and calls the process switch every so
 *	often (as defined by TPERSWITCH).
 *	Every 1 second checks all alarm times and sends signals as nescecary.
 *	Note the process switch is switched off by smaskon().
 */
tick(){
	register struct procs *proc;
	register short pid;

	/* Checks system stack for over flow if not internal shell */
/*
	if(cur_proc->pid && ((long)&cur_proc->sysstack[0] > getstack())){
		printf("TICK: System stack overflowing!!!!!!\n");
		printf("This is proberbly good bye, sniff, its been nice");
		printf("running for you. PID %d\n",cur_proc->pid);
	}
 */
	/* Increments CPU usage info */
	if((cur_proc->stat == SRUN) && (++cur_proc->cpu < 0)) cur_proc->cpu--;

	/* Perform alarm function every second */
	if(!second--){
		second = TPERSEC;
		systime++;
		proc = &proc_table[0];
		/* Decrement each processes alarm counter if necesary */
		for(pid = 0; pid < NPROC; pid++){
			if(proc->alarm){
				if(!(--(proc->alarm))) sendsig(pid, SIGALRM, 0);
			}
			proc++;
		}
		/* Checks if machine tick function required */
		if(!tickmach--){
			mach_tick();
			tickmach = MTICK;
			clrcpu();
		}
	}

	/* Check if timer execeeded if so set process switch flag */
	if(!swtchflag && !tickcount--){
		swtchflag = 1;
		tickcount = TPERSWITCH;
		setpri(cur_proc);	/* sets priority of curent process */
	}

	/* Check if any signals have occured for this or any other
	 * process, also if process switch is required
	 */
	checkmev();
	return;
} 

/*
 *	Setpri()	Sets the priority of this processes
 */
setpri(cproc)
struct	procs *cproc;
{
	if(cproc->pri >= PUSERMIN) cproc->pri = PUSER + cproc->nice;
}

/*
 *	Clrcpu()	Clears cpu usage
 */
clrcpu(){
	register struct	procs *proc;
	register int	pid;

	proc = &proc_table[0];
	for(pid = 0; pid < NPROC; pid++) (proc++)->cpu = 0;
}

/******************************************************************************
 *	Newproc()	Finds and creates a new proccess table entry
 ******************************************************************************
 *
 *	Duplicates process table for new process (fork)
 *	returns pointer to new child process table entry.
 *	Swaps out child process. Leaving parent in core.
 *	NOTE in MMU systems should copy process to a new section of core
 *	if posible, before having to swaping out child process.
 */

struct procs
*newproc(){

	struct	procs *child;
	int	cpid;
	short	smask;

#ifdef TFORK
printf("NEWPROC: Makeing new proc\n");
ps();
#endif
	/* Creates a new proccess entry if possible */
	if (++proc_index < NPROC){
		smask = smaskon(cur_proc, EVALL);	/* No process switch */
		cpid=0;
		child = &proc_table[0];	/* First real entry 0 is sys */

		/* Find free proccess slot set child pointing to it */
		while(child->stat){
			child++;
			cpid++;
		}
		if(cpid>=NPROC){
			printf("NEWPROC: Proccess table messed up!\n\r");
			proc_index--;
			smaskoff(cur_proc,smask);
			return (struct procs *)error(EAGAIN);
		}

		/* Duplicate proccess table entry for child, includes system
		 * stack (ie process state).
		 */
		bytecp(cur_proc,child,sizeof(struct procs));
		child->stat = SIDL;	/* Process in creation */

		/* Sets the child processes system stack pointer to point
		 * to the present state on the system stack for the child,
		 * (user state "u_regs" saved there). Sets the laststate's
		 * pointer to point to the top of the system stack.
		 */
		child->reg = (struct u_regs *)
			((long)&child->sysstack[SYSSTACK] -
			sizeof(struct u_regs));
		child->reg->laststate = (long)&child->sysstack[SYSSTACK];

		child->pid = cpid;		/* Capture proccess entry */
		child->ppid = cur_proc->pid;	/* Parent process */

		/* Try and swapout child proccess if process can be swapped
		 * and process is not the internal shell
		 */
		if(cur_proc->pid){
#ifdef TFORK
printf("Swaping out process %d\n",child->pid);
#endif
			if(swapout(child)){
				printf("NEWPROC: Cannot swap out %s\n",
					child->name);
				child->stat = 0;  /* Process deaded */
				smaskoff(cur_proc,smask);
				return (struct procs *)error(EAGAIN);
			}
		}
		else{
			/* If internal kernal process process state will
			 * not be in process table so copy state
			 */
			bytecp(cur_proc->reg, child->reg, sizeof(struct u_regs));
		}
		/* Save working directory locking to this new proccess */
		child->wd = relock(cur_proc->wd);

		/* make 'dups' of parent's open files */
		dup_all(cur_proc, child);

		child->stat = cur_proc->stat;
		smaskoff(cur_proc,smask);	/* Process entry now aquired */

#ifdef TFORK
printf("NEWPROC: Made new proc\n");
ps();
#endif
		return child;
	}

	/* failed - no slot */
	proc_index--;
	printf("NEWPROC: No more proccess room\n\r");
	return (struct procs *)error(EAGAIN);
}

/******************************************************************************
 *	KWAIT()	Real wait system call 
 ******************************************************************************
 *
 *	Checks to see if any of the processes children have died, if so
 *	kwait() will return imediatly with the PID of the child.
 *	If there are no children kwait() will return an error imediatly.
 *	Otherwise the process will be put to sleep awaiting a child to
 *	die and wake up this parent process.
 *	If a child has died (ie it is a zombie) then it is completely
 *	Anialated before returning to the parent with the process ID.
 *	Has to be called via the syscall wrapper
 */
kwait(){
	char child;
	short pid;
	struct procs *proc;

#ifdef TWAIT
printf("TWAIT entered stack %x %x %x\n",cur_proc->reg,
cur_proc->reg->sr,cur_proc->reg->pc);
getchar();
#endif
	/* Process will wait in this loop until a dead child is
	 * found when it will return with the exit status
	 * of that child
	 */
	child = 0;
	do{
		proc = &proc_table[1];	/* First process table entry sys 0 */
		for(pid = 1; pid < NPROC; pid++){

			/* If child is found and is a zombie deal with it */
			if((proc->stat) && (proc->ppid == cur_proc->pid)){
				child = 1;
				if(proc->stat == SZOMB){
					/* Set do to return child pid */
					cur_proc->reg->d0 = proc->pid;

					/* Gets exit status of child */
					cur_proc->reg->d1 = proc->exitstatus;
					/* Anialate the process ZAP, POW,
					 * WALOP its deaded.
					 */
					proc->pid = 0;
					proc->ppid = 0;
					proc->sig = 0;
					proc->flag = 0;
					proc->majseg = 0;
					proc->minseg = 0;
					proc->wchan = 0;
					proc->stat = 0;
					proc->exitstatus = 0;
					proc_index--;
					break;
				}
			}
			proc++;
		}
		/* If no dead children sleep until there are */
		if(pid == NPROC){
			/* If no children atall return error */
			if(!child) return error(ECHILD);

#ifdef TWAIT
printf("wait about to sleep process %x stack %x\n",cur_proc,cur_proc->reg);
getchar();
#endif
			sleep((caddr_t)cur_proc,PWAIT);
#ifdef TWAIT
printf("Twait awoke! stack %x\n",cur_proc->reg);
getchar();
#endif
		}
	}while(pid == NPROC);

#ifdef TWAIT
printf("TWAIT returning %d, %x\n",cur_proc->reg->d0,cur_proc->reg->d1);
printf("process %x stack %x %x %x\n",cur_proc,cur_proc->reg,
cur_proc->reg->sr,cur_proc->reg->pc);
getchar();
#endif
	/* Returns childs PID */
	return cur_proc->reg->d0;
}

/******************************************************************************
 *	Kexit()		Exits from proccess
 ******************************************************************************
 *
 *	Closes all the processes files, realeses the working dir iptr
 *	Gives any childen to their Grandperson (whos sexist not me)
 *	Becomes a Zombie (very nasty) and wakes up its parent if it has one.
 */
kexit(state)
short state;
{
	char pfound;
	short pid, smask;
	struct	procs *parent;

#ifdef TEXIT
printf("Exit entered state %d pid %d\n",state,cur_proc->pid);
ps();
#endif

	/* Disable process switching */
	smask = smaskon(cur_proc, EVALL);

	pfound = 0;

	/* Find parent process */
	parent = &proc_table[0];
	for(pid = 0; pid < NPROC; pid++){
		if(parent->pid == cur_proc->ppid) break;
		parent++;
	}
	if(pid != NPROC) pfound++;		/* Parent found */

	/* clears the process table entry */
	clrproc();

	/* Exit state and Termination state */
	cur_proc->exitstate = state;

	smaskoff(cur_proc,smask);		/* Renables process switch */

	/* Wakes up parent proccess if there is one */
	if(pfound) wakeup((caddr_t)parent);

#ifdef TEXIT
ps();
printf("Exit about to switch\n");
#endif

	/* Switches processes anyway if parent has gone */
	pswitch(-1);

	panic("EXIT: failed. ps It should never have got here\n");
	return;
}

/*
 *	Clrproc()	Clears the process table entry pointed to, oposite
 *			of newproc.
 */
clrproc(){
	struct	procs *child;
	short smask, pid;
	int t;

	/* Disable process switching */
	smask = smaskon(cur_proc, EVALL);

	/* remove old process's current directory */
	freeiptr(cur_proc->wd);

	/* close all his files */
	for (t = 0; t < NFPERU; t++) close(t);

	/* Zobifie the process */
	cur_proc->stat = SZOMB;

	/* Remove any locks */
	cur_proc->flag = 0;

	/* Ignore any pending signals */
	cur_proc->sig = 0;

	/* Find any children and give them the to the grand person of
	 * the process. 
	 */
	child = &proc_table[0];
	for(pid = 0; pid < NPROC; pid++){
		if(child->ppid == cur_proc->pid){
			child->ppid = cur_proc->ppid;
		}
		child++;
	}

	/* Realeses process memory segment for use */
	endmem(cur_proc->majseg, cur_proc->minseg);
	cur_proc->majseg = cur_proc->minseg = 0;

	smaskoff(cur_proc,smask);		/* Renables process switch */
	return 0;
}

/******************************************************************************
 *	Sleep()		Send process to sleep
 ******************************************************************************
 *
 *	Will send a process to sleep awaiting the event as given (chan).
 *	If the process is awoken by a signal which returns, then the
 *	process will be sent to sleep again.
 */
sleep(chan, pri)
caddr_t chan;
int pri;
{
	short smask;

#ifdef TCONCUR
printf("Sleep on chan %x, pri %d\n",chan,pri);
#endif

	/* Check if there are any signals if so do them */
	checkev(EVALLSIG);

	smask = smaskon(cur_proc, EVALL);	/* Disables process switch */

	cur_proc->wchan = chan;
	cur_proc->pri = pri;


#ifdef TCONCUR
printf("Sleep about to switch\n");
#endif

	/* Switch to new process no preference, if process hasn't been awoken */
	while(cur_proc->wchan){
		cur_proc->stat = SSLEEP;	/* Sends process to sleep */
		pswitch(-1);
		/* If waiting for wchan = 1 (pause() call) break out */
		if(cur_proc->wchan == (caddr_t)1) break;
	}

	smaskoff(cur_proc,smask);		/* Renables process switch */

#ifdef TCONCUR
printf("Sleep returned from switch\n");
#endif
	return;
}

/******************************************************************************
 *	Wakeup()	Flag wakeup process
 ******************************************************************************
 *
 *	Flags processes to wake up but does not actualy wake them up.
 *	They will wake on the next or later process switch.
 */
wakeup(chan)
caddr_t chan;
{
	register short pid;
	register struct procs *proc;

	proc = &proc_table[0];

	for(pid = 0; pid < NPROC; pid++){
		if((proc->wchan == chan) && (proc->stat != SZOMB)){
			proc->wchan = 0;
			proc->stat = SRUN;

			/* If waking up high-priority process indicate
			 * Process switch is required
			 */
			if(proc->pri <= PUSERMIN) swtchflag = 1;
		}
		proc++;
	}
	return;
}

/******************************************************************************
 *	Pswitch()	Process switch change processes
 ******************************************************************************
 *
 *	Argument passed to pswitch contains the process number
 *	to switch to, if -1 then there is no preference and pswitch()
 *	will search for the highest priority process to run.
 *	When this is found it will scan though for the next process in
 *	the process table that has this priority, thus processes with
 *	equal prioritys will be executed in round robin fashion.
 *	Note pre-emting high priority processes will mess up this system
 *	So process prioritys should be adjusted depending on the
 *	time they occupied the CPU.
 *	Note is a signal is found the whole process will be swaped in
 *	even if it is going to be killed this is a bit time consuming and
 *	wastfull. The signal will be processed on the returning system
 *	call, or on returning back to sleep.
 *	This routine calla via the swtch wrapper pswtch to change to a
 *	new process, the events are :-
 *		swtch	- saves proc pointer in d0 calls trap #1
 *		trap #1 - calls wrapper which saves process state, calls pswtch
 *		pswtch	- changes to new process and returns
 */
# define	LOWPRI	0x7FFF		/* Lowest priority */

pswitch(reqpid)
int reqpid;
{
	register char found;
	register short pid, hpri;
	register struct procs *proc;
	short	smask, intmask;
	struct	procs *oproc;

#ifdef TPSWITCH
printf("Pswitch got here given %d %x %x\n",reqpid
cur_proc->reg->sr,cur_proc->reg->pc);
#endif

	/* Disable process switching */
	smask = smaskon(cur_proc, EVALL);
	oproc = cur_proc;

	/* Indicate process switch has occured */
	swtchflag = 0;

	/* Allow interupts to ocurr */
	intmask = spl0();

	/* Continue round this loop until a process is found
	 * exits with proc pointing to process
	 */
	found = 0;
	while(!found){
		/* Check if a valid process id is has been given if so
		 * choose this one as the next process
		 */
		if((reqpid < NPROC) && (reqpid >= 0)){
			proc = &proc_table[reqpid];
			if((proc->stat == SRUN) || (proc->stat == SSLEEP)){
				found++;
				break;
			}
		}

		/* Search for higest priority process */
		hpri = LOWPRI;
		proc = &proc_table[0];
		for(pid = 0; pid < NPROC; pid++){
			if(proc->stat == SRUN){
				if(proc->pri < hpri) hpri = proc->pri;
				found++;
			}
			proc++;
		}

		/* If no process wants to run continue in wait loop */
		if(!found) continue;

		/* Go through table from curent process upwards, looking for
		 * a proccess with this priority that wants to run.
		 * Continue back through 0 to curent process.
		 */
		proc = cur_proc;
		do{
			/* Increments to next entry in process table */
			proc++;

			/* Checks if last process in table is so go
			 * to begining
			 */
			if(proc->pid >= NPROC){
				/* Next process is 0 wrap-around */
				proc = &proc_table[0];
			}

			/* If running process has this priority set found flag*/
			if((proc->stat == SRUN) && (proc->pri == hpri)) break;
		} while(proc != cur_proc);
	}
			
	/* Found one so go get it going first stop interupts */
	splx(intmask);

	/* Check if the process is in core if so continue with new process */
	/* Note if MMU is added then will have to check here if process is
	 * mapped into core if not map it in (call mmuset(pid) in mmu.c)
	 */
	if(!(proc->flag & SLOAD)){

#ifdef TPSWITCH
printf("PSWITCH: Swaping out process %d\n",cur_proc->pid);
#endif

		/* Get an area of core for the process */
		if((proc->minseg = getmem(proc->majseg, 0)) == -1){
			proc = cur_proc;
		}

		/* Swaps in new process if possible */
		else{

#ifdef TPSWITCH
printf("PSWITCH: Swaping in process %d\n",proc->pid);
#endif
			if(swapin(proc)){
				printf("PSWTCH: Cannot swap in new process %s\n"
					, proc->name);
				smaskoff(cur_proc,smask);
				return -1;
			}
		}
	}

	/* Sets to new process and executes it */
	/* Sets process priority */
	proc->pri = PUSER;
	proc->stat = SRUN;

	/* Make sure new process will run for a while */
	swtchflag = 0;
	tickcount = TPERSWITCH;

	/* Set to new process and reset switch mask */
	swtch(proc);
	smaskoff(oproc,smask);

	/* Checking if any events have occured to stop this process
	 */
	checkev(EVALLSIG);

#ifdef TPSWITCH
printf("Pswitch about to execute %d %x %x\n",cur_proc->pid,
cur_proc->reg->sr,cur_proc->reg->pc);
#endif
	return 0;
}
/*
 *	Smaskon()	Appends the new masking level to the software mask
 */
smaskon(proc, smask)
struct	procs *proc;
short smask;
{
	short smasko;

	smasko = proc->smask;
	proc->smask |= smask;
	return smasko;
}
/*
 *	Smaskoff()	Sets the software mask to the given value
 */
smaskoff(proc, smask)
struct	procs *proc;
short smask;
{
	short	smasko;

	smasko = proc->smask;
	proc->smask = smask;
	return smasko;
}
