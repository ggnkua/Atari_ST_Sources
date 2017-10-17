/******************************************************************************
 *	Exec.c		Exec fork and sbrk etc
 *			T.Barnaby, Made 20/5/85
 ******************************************************************************
 */

# include	"../include/param.h"
# include	<a.out.h>
# include	"../include/inode.h"
# include	"../include/signal.h"
# include	"../include/procs.h"
# include	"../include/memory.h"
# include	"../include/swap.h"
# include	<errno.h>
# include	"../include/stat.h"
# include	<sys/dir.h>
# include	"../include/state.h"
# include	"../include/inbin.h"
# include	"../include/dev.h"
# include	"../include/file.h"

extern	int proc_index;		/* Proccess index (number of proccesse */
extern	struct Comm kercom[];	/* Internal kernal commands */

long *saveargs();		/* Internal function declarations */
char *putstack(), *putarea();
struct procs *newproc();

# define	OPEN	SEARCH

# define	ARGAREA 2048		/* Max area for argument strings */
# define	NARGS   60		/* Max number of arguments */
# define	NENVS	30		/* Number of enviroment varibles */

char	argarea[ARGAREA];	/* Area on system stack to save arguments */
char	*areaptr;		/* Pointer to the area */
char	*aargv[NARGS];		/* Pointers to args in area */
char	*aenv[NENVS];		/* Pointers to environs in area */

/******************************************************************************
 *	Xeq	- Attempt to load and execute a command
 ******************************************************************************
 *
 * This is used to execute a program from within the kernal (eg internal shell)
 *	A new proccess number is found, but the old proccess is not swaped
 *	out of core.
 *	It effectivly forks a new process and then execls over the top
 *	the program required.
 *	Returns pid to parent on success (0 to child), or -1 on fail
 *	with error no in errno.
 *	Do not call this routine without using the syscall interface.
 */
xeq(name, argv, env)
char *name, *argv[], *env[];
{
	struct procs *child, *parent;
	short smask;
	struct	inode	*iptr;

#ifdef TXEQ
printf("XEQ: %s, %x, %x\n",name,argv,environ);
ps();
#endif
	/* Checks if internal kernal program, if not checks if program is
	 * on disk and accessable
	 */
	if(!inbin(name)){
		/* Try and get the file inode and get the object name */
		if(!(iptr = namlock(name, EOPEN, NULLIPTR))) return error(ENOENT);

		/* Check file access permissions */
		if(!i_access(iptr, IAEXEC)){
			freeiptr(iptr);
			return error(EACCES);
		}
		/* Checks if regular file else retuens error */
		if((iptr->i_mode & S_IFMT) != S_IFREG){
			freeiptr(iptr);
			return error(EACCES);
		}
		freeiptr(iptr);
	}

	smask = smaskon(cur_proc, EVALL);	/* Disables process switching */

#ifdef TXEQ
printf("Forking new process\n");
#endif
	/* attempt to make process slot for new process */
	if((child = newproc()) != (struct procs *)-1){

		/* Gets area of memory for the process */
		getmem(PROCSEG, 0);

		/* Sets parent to return childs pid */
		parent = cur_proc;

		/* Process is now child */
		cur_proc = child;

#ifdef TXEQ
printf("Execling new process\n");
#endif
		/* Try and execl a process */
		if(kexece(name, argv, env) == -1){
#ifdef TXEQ
printf("Exiting new process\n");
#endif
			endmem(PROCSEG, 0);
			clrproc();
			cur_proc->pid = 0;
			cur_proc->ppid = 0;
			cur_proc->sig = 0;
			cur_proc->flag = 0;
			cur_proc->majseg = 0;
			cur_proc->minseg = 0;
			cur_proc->wchan = 0;
			cur_proc->stat = 0;
			cur_proc->exitstatus = 0;
			proc_index--;
			cur_proc = parent;
			smaskoff(cur_proc, smask);
			return error(-1);
		}
		else {
			cur_proc = parent;
			smaskoff(child, EVOFF);
			smaskoff(cur_proc, smask);
			return child->pid;
		}
	}

	/* failed - no slot */
	smaskoff(cur_proc, smask);
	return error(EAGAIN);
}

/******************************************************************************
 * kexece - attempt to load and execute a command.
 ******************************************************************************
 *
 * This is the standard system execl. It will check to see if the
 *	program name is an internal kernal program, if so it will execute
 *	this else will search the disk for the given program.
 *	returns 0 on success, -1 on fail.
 *	Do not call this routine without using the syscall interface.
 */
kexece(name, argv, env)
char *name, *argv[], *env[];
{
	unsigned long datastart;	/* Start of data in process space */

	short sticky;		/* Sticky file indicator */
	char swap;		/* Program from swap space flag */
	short mseg, smask, smask1;
	int c;
	long *sp;
	struct	inode	*iptr;	/* Inode or the program */
	struct	Object	object;
	struct	Psize	psize;
	struct	file	file;

#ifdef TEXEC
printf("EXEC: %s, %x, %x\n",name, argv, env);
ps();
#endif

	sticky = swap = 0;

	/* Checks if internal program if so executes it */
	if(inbin(name)) return exinbin(name, argv, env);

	/* Try and get the file inode and get the object name */
	if(!(iptr = namlock(name, EOPEN, NULLIPTR))) return error(ENOENT);
	object.majdev = iptr->i_mdev;
	object.mindev = iptr->i_minor;
	object.inode = iptr->i_ino;

	/* Check file access permissions */
	if(!i_access(iptr, IAEXEC)){
		freeiptr(iptr);
		return error(EACCES);
	}

	/* Checks if regular file else returns error */
	if((iptr->i_mode & S_IFMT) != S_IFREG){
		freeiptr(iptr);
		return error(EACCES);
	}

	smask = smaskon(cur_proc, EVALL);	/* Mask process switch */

	/* Store all arguments in argarea */ 
	if(storeargs(argv, env) == -1){
		freeiptr(iptr);
		smaskoff(cur_proc, smask);
		return -1;
	}

#ifdef TEXEC
printf("EXEC: checking swap\n");
#endif

	/* Check if in swap space */
	if(inswap(&object, &psize) != -1){
		swap = 1;
	}

	/* If not check if in file */
	else{
#ifdef TEXEC
printf("EXEC: Opening file\n");
#endif
		if(f_open(&file, relock(iptr), READABLE) == -1){
			freeiptr(iptr);
			smaskoff(cur_proc,smask);
			return error(ENOENT);
		}
#ifdef TEXEC
printf("EXEC: checking file\n");
#endif
		infile(&file, &psize);
	}

#ifdef TEXEC
printf("EXEC: in %d filetype %x\n",swap, psize.fmagic);
#endif

	/* Check file type */
	if ((psize.fmagic != FMAGIC) && (psize.fmagic != NMAGIC)){
		/* format wrong */
		if(!swap) f_close(&file);
		freeiptr(iptr);
		return error(ENOEXEC);
	}

	/* Check if there is room for this program */
	if((mseg = extmem(PROCSEG, cur_proc->minseg,
		psize.tsize + psize.dsize + psize.bsize)) == -1){
		if(!swap) f_close(&file);
		freeiptr(iptr);
		smaskoff(cur_proc, smask);
		return error(ENOMEM);
	}

	/* Check if within process workspace */
	if((psize.entry < (long)memstart(PROCSEG, mseg)) ||
		(psize.entry >= (long)memend(PROCSEG, mseg))){
		if(!swap) f_close(&file);
		freeiptr(iptr);
		smaskoff(cur_proc,smask);
		return error(ENOMEM);
	}

	/* Clears signals to default if they are not ignored ones */
	for(c=0; c<NSIG; c++){
		if(cur_proc->signals[c].func != SIG_IGN){
			cur_proc->signals[c].func = SIG_DFL;
		}
	}
	cur_proc->sigmode = SIGMODEUNIX;	/* Normal signal mode */
	cur_proc->sigmask = ENALLSIG;		/* Unmask all signals */

	cur_proc->evcom = 0;			/* All events off */
	cur_proc->evenfile = 0;
	cur_proc->evfile = 0;
	cur_proc->alarm = 0;		/* Event alarm clock ! */
					/* Ps I only found this one 1 day */
					/* before my Phd viva ! */

	cur_proc->wchan = 0;			/* Wakeup off */
	cur_proc->pwakechan = 0;		/* Pre-wake off */
	cur_proc->pwakeevent = 0;

	/* Set program sizes */
	if(psize.fmagic == FMAGIC){
		datastart = psize.entry+psize.tsize;
	}
	else{
		datastart = ((psize.entry+psize.tsize)&MMUMASK)+MMUBOUND;
	}

	/* Sets up stack pointer to end of stack */
	sp = (long *)memend(PROCSEG, mseg);
	cur_proc->psize.ustack = (long)sp;	/* Top of user stack */

#ifdef TEXEC
printf("EXEC: saveing args \n");
#endif

 	/* Saves arguments here either for codata exec */
	sp = saveargs(sp, aargv, aenv);
	setusp(sp);				/* Sets the user sp to here */

	/* Modify process table entry for this new process */

	cur_proc->pid = cur_proc->pid;		/* Same proccess id */
	cur_proc->reg->sr = 0x0000;		/* Sets user state */
	cur_proc->reg->usp = (long)sp;
	cur_proc->reg->pc = psize.entry;
	cur_proc->psize.fmagic = psize.fmagic;
	cur_proc->psize.entry = psize.entry;
	cur_proc->psize.tsize = psize.tsize;
	cur_proc->psize.dsize = psize.dsize;
	cur_proc->psize.bsize = psize.bsize;
	cur_proc->psize.ebss = (unsigned)(datastart+psize.dsize+psize.bsize);
	cur_proc->object.majdev = object.majdev;
	cur_proc->object.mindev = object.mindev;
	cur_proc->object.inode = object.inode;

	strncpy(cur_proc->name, name, PATHLEN);
	cur_proc->majseg = PROCSEG;
	cur_proc->minseg = mseg;

#ifdef TEXEC
printf("EXEC: GETING program\n");
#endif

	/* If inswap space recover program from here */
	if(swap){
		if(stickin(&object)){
			freeiptr(iptr);
			endmem(PROCSEG, mseg);
			smaskoff(cur_proc,smask);
			kexit(1 << 8);
		}
	}

	/* Else get program from opened file */
	else {
		if(fromfile(&file, &psize)){
			f_close(&file);
			freeiptr(iptr);
			endmem(PROCSEG, mseg);
			smaskoff(cur_proc,smask);
			kexit(1 << 8);
		}
		if(iptr->i_mode & ISVTX) sticky = 1;
	} 
	if(!swap) f_close(&file);

	/* set BSS to zeroes */
	byteclr((datastart+psize.dsize),psize.bsize);

	/* Sets euid, egid on execution */
	if(iptr->i_mode & ISUID) cur_proc->euid = iptr->i_uid;
	if(iptr->i_mode & ISGID) cur_proc->egid = iptr->i_gid;

	/* If sticky process save in swap area */
	if(sticky) stickout(cur_proc);

#ifdef TEXEC
ps();
#endif
	cur_proc->flag = SLOAD;
	cur_proc->stat = SRUN;

	setmempid(PROCSEG, mseg, cur_proc->pid);
	freeiptr(iptr);
	smaskoff(cur_proc,smask);	/* Reallow those nasty interupts */
	return 0;
}

/*
 *	Inbin()		Determins whether the program is internal or not
 */
inbin(name)
char	*name;
{
	if(strncmp(name, INBIN, strlen(INBIN))) return 0;
	return 1;
}

/*
 *	Exinbin()	Executes internal program
 *			Checks if program exists, if so resets the process
 *			table entry for 0 text, data and bss size, places
 *			All arguments on user stack, and executes the
 *			Internal process in super state with arguments pointing
 *			to argc, argv, and env on the user stack.
 */
exinbin(name, argv, env)
char	*name;
char	*argv[], *env[];
{
	int	c;
	short	smask;
	long	*sp;
	struct	Comm *coms;

	/* Finds comand name entry in internal kernal command jump table */
	coms = kercom;
	while(coms->c_name && strcmp(coms->c_name, (name + strlen(INBIN)))) coms++;
	if(!coms->c_name) return error(ENOENT);

	smask = smaskon(cur_proc, EVALL);	/* Mask process switch */

	/* Store all arguments in argarea */ 
	if(storeargs(argv, env) == -1){
		smaskoff(cur_proc, smask);
		return -1;
	}

	/* Sets up stack pointer to end of stack (user stack) */
	sp = (long *)memend(PROCSEG, 0);
	cur_proc->psize.ustack = (long)sp;	/* Top of user stack */

 	/* Saves arguments here either for codata exec */
	sp = saveargs(sp, aargv, aenv);

	/* Modify process table entry for this new process */

	/* Clears signals to default if they are not ignored ones */
	for(c=0; c<NSIG; c++){
		if(cur_proc->signals[c].func != SIG_IGN){
			cur_proc->signals[c].func = SIG_DFL;
		}
	}

	cur_proc->sig = 0;
	cur_proc->evenfile = 0;
	cur_proc->pid = cur_proc->pid;		/* Same proccess id */
	cur_proc->psize.fmagic = 0;
	cur_proc->psize.entry = (long)coms->c_routine;
	cur_proc->psize.tsize = 0;
	cur_proc->psize.dsize = 0;
	cur_proc->psize.bsize = 0;
	cur_proc->psize.ebss = (unsigned)memstart(PROCSEG, 0);
	cur_proc->object.majdev = 0;
	cur_proc->object.mindev = 0;
	cur_proc->object.inode = 0;

	strncpy(cur_proc->name, name, PATHLEN);
	cur_proc->majseg = PROCSEG;
	cur_proc->minseg = 0;
	cur_proc->flag = SLOAD;
	cur_proc->stat = SRUN;

	/* Not realy nesecary as they will be ignored */
	cur_proc->reg->sr = 0x0200;		/* Sets super state */
	cur_proc->reg->usp = (long)sp;
	cur_proc->reg->pc = cur_proc->psize.entry;

	/* Sets euid, egid on execution */
	if(coms->mode & ISUID) cur_proc->euid = 0;
	if(coms->mode & ISGID) cur_proc->egid = 0;

	setmempid(PROCSEG, 0, cur_proc->pid);
	smaskoff(cur_proc, EVOFF);	/* Reallow those nasty interupts */

	/* Execute internal program with argc, argv and env on user stack */
	kexit(((*coms->c_routine)(*sp, sp + 1, sp + 2)) << 8);
	return;
}

/*
 *	Infile	-	Get program size info from the file whoose inode
 *			is given
 */
infile(file, psize)
struct	file *file;
struct	Psize *psize;
{
	struct	bhdr filhdr;

	/* Read header */
	if (f_read(file, &filhdr, sizeof(struct bhdr)) != sizeof(struct bhdr)){
		/* read error */
		return error(ENOEXEC);
	}
	psize->fmagic = filhdr.fmagic;
	psize->tsize = filhdr.tsize;
	psize->dsize = filhdr.dsize;
	psize->bsize = filhdr.bsize;

	psize->entry = filhdr.entry;
	psize->ustack = 0;
	psize->stacks = 0;
	psize->ebss = 0;
	return 0;

}

/*
 *	Fromfile -	Collect the executable program from the filestore
 *			Into core.
 */
fromfile(file,psize)
struct	file *file;
struct	Psize *psize;
{
	unsigned long datastart;

	/* Read in text segment */
	if (f_read(file, psize->entry, psize->tsize) != psize->tsize){
		/* read error */
		return -1;
	}

	/* Work out start of data segment */
	if(psize->fmagic == FMAGIC){
		datastart = psize->entry+psize->tsize;
	}
	else{
		datastart = ((psize->entry+psize->tsize)&MMUMASK)+MMUBOUND;
	}

	/* Read in data segment */
		if(f_read(file, datastart, psize->dsize) != psize->dsize){
		/* read error */
		return -1;
	}

	return 0;
}

/******************************************************************************
 *	Storeargs	Saves both arguments and environ's in store area
 ******************************************************************************
 */
storeargs(argv, env)
char	*argv[], *env[];
{
	int	c;

	areaptr = argarea;	/* Sets area pointer to start of save area */

	/* saves argvs */
	for(c=0; argv[c]; c++){
		if((c>=(NARGS-1))||((areaptr-argarea+strlen(argv[c]))>ARGAREA)){
			return error(E2BIG);
		}
		aargv[c] = areaptr;	/* Puts argument pointer into array */
		areaptr =  putarea(areaptr, argv[c]);	/* Saves string */
	}
	aargv[c]=0;			/* Last one is a null pointer

	/* Saves enviroment varibles */
	for(c=0; env[c]; c++){
		if((c>=(NENVS-1))||((areaptr-argarea+strlen(env[c]))>ARGAREA)){
			return error(E2BIG);
		}
		aenv[c] = areaptr;	/* Puts environ pointer into array */
		areaptr =  putarea(areaptr,env[c]);	/* Saves string */
	}
	aenv[c]=0;			/* Last one is a null pointer */
	return 0;
}

/******************************************************************************
 *	Saveargs	Saves both arguments and environ's on user stack
 ******************************************************************************
 *
 *	Arguments
 *		sp	Stack pointer
 *		argv	Pointer to array of argument pointers
 *		env	Pointer to array of enviroment pointers
 *
 *	Returns
 *		sp	New updated value for stack pointer
 *
 *	Uses
 *		putstack()	To push varibles
 */

long *saveargs(sp, argv, env)
long *sp;
char *argv[], *env[];
{
	char	*spc;
	long	count;
	char	*args[NARGS];		/* argument pos on stack */
	short	argc;			/* Number of arguments */
	char	*envs[NENVS];		/* enviroment pos on stack */
	short	envc;			/* Number of enviroment varibles */
	int	sum;

#ifdef TEXECE
printf("SAVEARGS\n\r");
#endif
	*(--sp) = 0;		/* Puts 00 on stack end of strings */
	spc = (char *)sp;

	/* Finds the number of bytes in the strings if odd make even */
	sum = 0;
	for(count = 0; env[count]; count++){
		sum += strlen(env[count]) + 1;
	}
	envc = count;
	for(count = 0; argv[count]; count++){
		sum += strlen(argv[count]) + 1;
	}
	argc=count;
	if(sum&1) *(--spc) = 0;	/* Make even subtracts one from sp */
	
#ifdef TEXECE
printf("SAVEARGS saveing strings\n\r");
#endif
	/* Saveing argument strings */
	for(count = envc-1; count >= 0; count--){
		spc=putstack(spc,env[count]);
		envs[count] = spc;	/* Sets enviroment pointer to string */
	}
	for(count = argc-1; count >= 0; count--){
		spc = putstack(spc,argv[count]);
		args[count] = spc;	/* Sets argument pointer to string */
	}
	sp = (long *)spc;

	/* Save enviroment pointers */
	*(--sp) = 0;			/* Null pointer */
	for(count = envc-1; count >= 0; count--){
		*(--sp) = (long)envs[count];
	}

	/* Save argument pointers */
	*(--sp) = 0;			/* Null pointer */

#ifdef TEXECE
printf("SAVEARGS saveing pointers\n\r");
#endif
	for(count=argc-1; count>=0; count--){
		*(--sp) = (long)args[count];
	}

	/* Codata exec type just saves argc */
	*(--sp) = argc;			/* Save argc */

#ifdef TEXECE
	spl=sp;
printf("Bottom stack %x\n\r",sp);
if('p'==getchar()){
for(c=0; c<20; c++){
	printf("%x %x\n\r",spl,*spl);
	spl++;
}
}
#endif

	return sp;
}



/******************************************************************************
 *	Putstack	Puts a string onto the stack (ie decrement before push
 *			action) returning the new value of the stack pointer.
 ******************************************************************************
 */
char *putstack(sp,str)
char *sp;
char *str;
{
	int len;

	len=strlen(str);		/* Finds length of string */
	str += len;			/* Sets str to point to end of string */
	while(len-- >=0){		/* Puts string includeing null to sp */
		*(--sp)= *str--;
	}
	return sp;			/* Returns updated sp */
}

/******************************************************************************
 *	Putarea		Puts a string into the area (increment after push
 *			action) returning the new value of the srea pointer
 ******************************************************************************
 */
char *putarea(area,str)
char *area;
char *str;
{
	int	len;

	len=strlen(str);		/* Finds length of string */
	while((len--)>=0){		/* Puts string includeing null to area*/
		*(area++)= *str++;
	}
	return area;			/* Returns updated */
}

/******************************************************************************
 *	Kfork	Fork a new proccess, Swaps parent out and leaves child running
 ******************************************************************************
 *
 *	Returns		0 to child proccess (sets d0 of parent to pid of child)
 *		
 *	uses
 *		swapout()	Swaps proccess out of core
 *
 *	Note
 *		Sets Return address to +=2 if parent (Very nasty!)
 */
kfork(){
	struct	procs *child;
	short	smask;

#ifdef TFORK
printf("Fork\n\r");
ps();
#endif

	/* Creates a new proccess entry */
	if((child = newproc()) != (struct procs *)-1){

		smask = smaskon(cur_proc, EVALL); /* Disable process switch */

#ifdef TFORK
printf("Stack p %x, c %x, stp %x, stc %x\n",cur_proc,child,cur_proc->reg,
	child->reg);
#endif
		child->reg->d0 = cur_proc->pid;	/* Sets up return pid */
		cur_proc->reg->d0 = child->pid;	/* Inform parent of children */
		/* Sets up last state pointer */
		cur_proc->reg->laststate = (long)&cur_proc->sysstack[SYSSTACK];

		/* Increments pc for return to Fork if parent
		 * YEUCK! what a horible thing to Have to do
		 */
		cur_proc->reg->pc += 2;	/* Adds 2 for return to parent fork */

#ifdef TFORK
printf("About to return ie execute bye bye!\n\r");
#endif

#ifdef TFORK
ps();
#endif
		smaskoff(child, EVOFF);
		smaskoff(cur_proc, smask);
		return cur_proc->reg->d0;
	}
#ifdef TFORK
printf("FORK:	Didnt make proccess\n\r");
#endif

	/* failed - no slot */
	cur_proc->reg->pc += 2;	/* Adds 2 for return to parent fork */
	printf("FORK: No more proccess room\n\r");
	return error(EAGAIN);
}

/******************************************************************************
 *	Kill()		System kill process call
 ******************************************************************************
 *
 *	Sends the kill signal to the pid given, if process has the same
 *	userid or is root.
 *	If the pid is 0 sends the signal to all processes in the group.
 *	If the pid is -1 and process is root sends the signal to all
 *	processes bar 0, and the curent process (normaly would send to
 *	process 1 as well).
 */
kill(pid, sig)
short pid;
long sig;
{
	struct procs *proc;

	/* If pid is 0 send the signal to all processes in group */
	if(!pid){
		sendgrp(cur_proc->tty, sig, 0);
	}
	/* If pid is -1 and user is super user then send signal to all
	 * processes except this one, and 0 (note signal is sent to pid 1).
	 */
	if((pid == -1) && (!cur_proc->euid)){
		proc = &proc_table[NPROC-1];
		for(pid = NPROC - 1; pid > 0; pid--){
			if((proc->stat) && (proc->pid != cur_proc->pid))
				sendsig(proc->pid, sig, 0);
			proc--;
		}
	}
	/* Else send only to given pid */
	else{
		/* Check if pid is valid and same user id */
		proc = &proc_table[pid];
		if((pid < 0) || (pid >= NPROC)) return error(ESRCH);
		/* If not root and not the same user id then error */
		if((cur_proc->euid) && (cur_proc->euid != proc->euid))
			return error(ESRCH);
		sendsig(proc->pid, sig, 0);
	}
	return 0;
}

/******************************************************************************
 *	Sbrk	- Reset proccess's break location
 ******************************************************************************
 */

caddr_t
sbrk(newbrk)
caddr_t newbrk;
{
	caddr_t oldbrk;

	oldbrk = (caddr_t)cur_proc->psize.ebss;

	/* Slight checking is performed ie close to User stack pointer
	 * Or Below workspace
	 */
	if((newbrk < (caddr_t)memstart(PROCSEG, cur_proc->minseg)) ||
		((long)newbrk >= (cur_proc->reg->usp - STACKROOM))){
		if(state.warning)
			printf("SBRK: Warning bss area aproached stack\n");
		return (caddr_t)error(ENOMEM);
	}

	cur_proc->psize.ebss = (long)newbrk;
	cur_proc->psize.bsize += (newbrk - oldbrk);

	return oldbrk;
}


/* Proccess status enquiry */
p_status(no,pointer)
int no;
struct procs *pointer;
{
	struct procs *proc;

	/* Checks if proccess table entry exists */
	if(no >= NPROC) return -1;

	/* Get proccess entry and write to given location */
	proc = &proc_table[no];
	bytecp(proc,pointer,sizeof(struct procs));
	return (int)pointer;
}
