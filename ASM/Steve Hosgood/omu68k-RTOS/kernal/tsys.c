
# include	"../include/param.h"
# include	"../include/inode.h"
# include	"../include/signal.h"
# include	"../include/procs.h"

extern struct inode ibuf[];

tpinodes(){
	int i;
	struct inode *iptr;

	iptr=ibuf;
	for(i=0; i<NINODES; i++){
		if(iptr->i_nlocks) tpn(iptr);
		iptr++;
	}
}
tpn(iptr)
struct inode *iptr;
{
	printf("inode at address %d\n\r",iptr);
	printf("dev ptr %d\n\r",iptr->i_mdev);
	printf("minor %d\n\r",iptr->i_minor);
	printf("ino %d\n\r",iptr->i_ino);
	printf("nlocks %d\n\r",iptr->i_nlocks);
	printf("addresses %d\n\r",iptr->i_addr);
}

/******************************************************************************
 *	Ps.c		Proccess status for OMU uses system call 253
 ******************************************************************************
 */


# define	PS	253		/* Proccess status system call */

/* Proccess state flags */
char pstate[] = {
	'0', 'S', 'W', 'R', 'I', 'Z', 'T'
};

ps(){
	int pid;

	printf("F S UID  PID  PPID CPU PRI NICE   ADDR SZ  WCHAN WAKE TTY TIME CMD\n");
	for(pid = 0; pid < NPROC; pid++){
		printps(&proc_table[pid]);
	}
	printf("SMASK %x\n",cur_proc->smask);
	printf("s gives stack values\n");
	if( 's' != (0x7f & getchar())) return;
	printf("F S UID  PID  PPID STACKB  STACKT  STACK  SSIZE  ADDR SZ  WCHAN  CMD\n");
	for(pid = 0; pid < NPROC; pid++){
		printst(&proc_table[pid]);
	}
	getchar();
}
/*
 *	Printps()	Print a proccess entry
 */
printps(proc)
struct procs *proc;
{
	char strtmp[50];

	printf("%d ",proc->flag);
	printf("%d ",proc->stat);
	printf("%d  ",proc->uid);
	printf("%d    ",proc->pid);
	printf("%d   ",proc->ppid);
	printf("0     ");
	printf("%d    ",proc->pri);
	printf("%d   ",proc->nice);
	printf("%x ",proc->psize.entry);
	printf("0   ");
	printf("%x ",proc->wchan);
	strncpy(strtmp,proc->name,20);
	printf("%s\n",strtmp);
}
/*
 *	Printst()	Print a proccess entry with stack
 */
printst(proc)
struct procs *proc;
{
	char strtmp[50];

	printf("%d ",proc->flag);
	printf("%d ",proc->stat);
	printf("%d  ",proc->uid);
	printf("%d    ",proc->pid);
	printf("%d   ",proc->ppid);
	printf("%x ",proc);
	printf("%x ",((long)(&proc->sysstack[SYSSTACK])));
	printf("%x ",proc->reg);
	printf("%x ",((long)(&proc->sysstack[SYSSTACK])-(long)proc->reg));
	printf("%x ",proc->psize.entry);
	printf("0   ");
	printf("%x ",proc->wchan);
	printf("0    ");
	printf("0     ");
	strncpy(strtmp,proc->name,20);
	printf("%s\n",strtmp);
}
