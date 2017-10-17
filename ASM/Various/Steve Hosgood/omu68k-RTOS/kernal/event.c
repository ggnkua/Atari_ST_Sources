/******************************************************************************
 *	Event.c		Event related stuff
 ******************************************************************************
 */

# include	"../include/param.h"
# include	"../include/inode.h"
# include	"../include/signal.h"
# include	"../include/procs.h"
# include	"../include/file.h"
# include	<errno.h>

/*
 *	Comms()		System inter-process comunication call
 */
comms(pid, arg1, arg2)
int	pid;
long	arg1, arg2;
{
	struct	procs *proc;

	/* Checks if pid is correct */
	if(pid >= NPROC || pid < 0) return -1;

	proc = &proc_table[pid];

	/* Check if process exits and has still to acknowledge a preveous
	 * coms call.
	 */
	if((proc->stat == SRUN) || (proc->stat == SSLEEP) && !proc->evcom){
		proc->evcom = 1;
		proc->evcoma[0] = cur_proc->pid;
		proc->evcoma[1] = arg1;
		proc->evcoma[2] = arg2;
		sendsig(pid, SIGEVCOMMS, 0);
		return 0;
	}
	else return -1;
}

/*
 *	Onfile()	System file event call (set file event bit map)
 */
onfile(file, dof)
int	file, dof;
{
	/* Checks if file number is correct */
	if(file >= NFPERU || file < 0) return -1;

	if(dof){
		/* Sets file event number bit map */
		cur_proc->evenfile |= (1 << file);
	}
	else{
		/* Clears file event number bit map */
		cur_proc->evenfile &= ~(1 << file);
	}

	return 0;
}

/*
 *	Fileevent()	Signal all processes that have the given file
 *			pointer opened, with the file no as the argument.
 *			And that are looking for events on this file.
 */
fileevent(file)
struct file *file;
{
	register struct procs *proc;
	short pid;
	register int	s;

	/* Look at each process slot for a matching file pointer, if
	 * found signal process seting the event argument to the file no
	 */

	proc = &proc_table[0];
	for(pid = 0; pid < NPROC; pid++){
		/* If a process entry exists and has a slot pointing to
		 * the relevent file, signal it
		 */
		if((proc->stat == SRUN) || (proc->stat == SSLEEP)){
			for(s = 0; s < NFPERU; s++){
				/* Checks if process looking at this file and
				 * if process has file opened
				 */
				if((proc->slots[s] == file) &&
					(proc->evenfile & (1<<s))){
					proc->evfile |= (1<<s);
					sendsig(pid, SIGEVFILE, 0);
					/* Only one signal per process */
					break;
				}
			}
		}
		proc++;
	}
}

/*
 *	Devevent()	Signal all processes that have a file opened
 *			to the given device, return file no as argument.
 *			Note has to be fast as TTY handler calls this.
 */
devevent(majdev, mind)
register struct	dev *majdev;
register short	mind;
{
	register int	s;
	register struct	file **slot;
	register short	pid;
	register struct	procs *proc;

	/* Look at each process slot for a file pointer using this dev, if
	 * found signal process seting the event argument to the file no
	 */

	proc = &proc_table[0];
	for(pid = 0; pid < NPROC; pid++){
		/* If a process entry exists and is looking at the file
		 * events, check if it has any files open to the device.
		 */
		if(((proc->stat == SRUN) || (proc->stat == SSLEEP)) &&
			(proc->evenfile)){
			slot = &proc->slots[0];
			for(s = 0; s < NFPERU; s++){
				/* Checks if slot used and process is looking
				 * at this slot and device is the same.
				 */
				if(*slot && (proc->evenfile & (1 << s)) &&
					((*slot)->f_handler == majdev) &&
					((*slot)->f_dev == mind)){
					proc->evfile |= (1<<s);
/* NOTE: actualy does signal !!!!! */
					sendsig(pid, SIGEVFILE, 1);
					/* Only one signal per process */
					break;
				}
				slot++;
			}
		}
		proc++;
	}
}

/*
 *	Devevp()	Signal the given process f it has a file opened
 *			to the given device, return file no as argument.
 *			Note has to be fast as TTY handler calls this.
 */
devevp(pid, majdev, mind)
register int	pid;
register struct	dev *majdev;
register short	mind;
{
	register int	s;
	register struct	file **slot;
	register struct	procs *proc;

	proc = &proc_table[pid];

	/* If a process entry exists and is looking at the file
	 * events, check if it has any files open to the device.
	 */
	if(((proc->stat == SRUN) || (proc->stat == SSLEEP)) &&
		(proc->evenfile)){
		slot = &proc->slots[0];
		for(s = 0; s < NFPERU; s++){
			/* Checks if slot used and process is looking
			 * at this slot and device is the same.
			 */
			if(*slot && (proc->evenfile & (1 << s)) &&
				((*slot)->f_handler == majdev) &&
				((*slot)->f_dev == mind)){
				proc->evfile |= (1<<s);
				sendsig(pid, SIGEVFILE, 0);
				/* Only one signal per process */
				break;
			}
			slot++;
		}
	}
}
