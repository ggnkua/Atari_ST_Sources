/******************************************************************************
 *	Pipe.c		Pipe system call 	T.Barnaby, Made 9/6/85
 ******************************************************************************
 *
 *	Will create a pipe with two file descriptors
 */

# include	"../include/param.h"
# include	"../include/inode.h"
# include	"../include/signal.h"
# include	<errno.h>
# include	"../include/procs.h"
# include	"../include/file.h"
# include	"../include/dev.h"
# include	"../include/state.h"

extern struct file uft[];

/*
 *	Pipe()		System call for opening a pipe
 */
pipe(){
	int	fw, fr, err;
	
# ifdef TPIPES
printf("Pipe open %d\n\r",cur_proc->pid);
# endif
	/* Opens the pipe */
	if(err = pipeopen(&fw, &fr)) return err;

# ifdef TPIPES
printf("Opened %d %d\n\r",fw, fr);
# endif
	/* Returns correct file descriptors */
	cur_proc->reg->d1 = fw;
	return fr;
}

/*
 *	Pipeopen()	Creates a pipe
 *			Gets two empty slots in the system file table
 *			linked the the curent processes file slot table.
 *			Gets a free inode to allocate to the pipe and
 *			locks it, creates the correct entries in the
 *			system file table and returns file descritors
 *			for both read and write files.
 */
pipeopen(fw, fr)
int *fw, *fr;
{
	struct file *wfile, *rfile;
	struct inode *inode;
	int	(*fnc)();

# ifdef TPIPES
printf("Get slots\n");
# endif

	/* Check if pipe device exists */
	if(!(fnc = bdevsw[PDEV_MAJ].openfnc)){
		if(state.warning) printf("PIPE: No pipe device\n");
		return error(-1);
	}

	/* File open - open device it's using */
	if((*fnc)(PDEV_MIN)){
		if(state.warning) printf("PIPE: Unable to open pipe device\n");
 		return error(-1);
	}

	/* Gets device close function */
	fnc = bdevsw[PDEV_MAJ].closefnc;

	/* Get slots for files */
	if((*fw = getslot()) == -1) return -1;
	if((*fr = getslot()) == -1){
		freslot(*fw);
		/* Close pipe device */
		(*fnc)(PDEV_MIN);
		return error(-1);
	}

# ifdef TPIPES
printf("Get inode\n\r");
# endif
	/* Gets a free inode from the devices inode free list */
	if(!(inode = lockfree(&bdevsw[PDEV_MAJ], PDEV_MIN))){
		freslot(*fw);
		freslot(*fr);
		/* Close pipe device */
		(*fnc)(PDEV_MIN);
		return error(-1);
	}

	/* Inode is in use */
	inode->i_nlink++;

	/* Relocks the inode (both read and write file descriptors) */
	relock(inode);

	wfile = cur_proc->slots[*fw];
	rfile = cur_proc->slots[*fr];

# ifdef TPIPES
printf("create file entries\n\r");
# endif
	/* Sets up the uft entries */
	f_creat(wfile, inode, WRITEABLE | PIPE, 0777);
	f_creat(rfile, inode, READABLE | PIPE, 0777);

	/* Sets up the cross pipe links */
	wfile->f_pipelink = rfile;
	rfile->f_pipelink = wfile;

	/* Close pipe device note f_creat opened device as well */
	(*fnc)(PDEV_MIN);

	return 0;
}
