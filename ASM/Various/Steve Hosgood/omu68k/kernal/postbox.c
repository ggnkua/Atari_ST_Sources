/******************************************************************************
 *	Postbox.c	Postbox message bits
 ******************************************************************************
 */

# include	"../include/postbox.h"
# include	"../include/procs.h"

# define	NPOSTBOX	4	/* Number of postboxes */

/*
 *	Postbox data area
 */

struct	postbox	post[NPOSTBOX];

/*
 *	Msgadd()	Creates a new process address from old address
 *			New address is one level beniegth present address
 *			Checks if address is free (ie not used by any process).
 */
msgadd(new, old)
char *new, *old;
{
	int i;

	i = ADDLEVELS;
	while(i--) *(new++) = 0;
	new += ADDLEVELS;

	i = ADDLEVELS;
	while(*(new++) = *(old++)) if(i-- <=0) return -1;
	for(i = 1; i < 256; i++){
		*new = i;
		if(!addused(new)) break;
	}
	return 0;
}
/*
 *	Addused()	Checks if address is already in use
 */
addused(add)
char *add;
{
	short	pid;
	struct	procs *proc;

	/* Checks if address is in use by any other process */
	proc = &proc_table[0];
	for(pid = 0; pid < NPROCS; pid++){
		if(proc->state){
			if(addeq(add, proc->postadd)) return pid;
		}
		proc++;
	}
	return 0;
}
/*
 *	Addeq()		Check if addresses are the same
addeq(add1, add2)
char *add1, *add2;
{
	int i;

	while(i--){
		if(*(add1++) != *(add2++)) return 0;
	}
	return 1;
}

/*
 *	Msgexit()	Removes all entries in the postbox for the process
 */
msgexit(){
	int i, c;

	/* Clears all entries for current process */
	for(i = 0; i < NPOSTBOX; i++){
		if(addeq(post[i].p_destin, cur_proc->postadd)){
			byteclr(&post[i], sizeof(struct postbox));
		}
	}
}


/*
 *	Msgsend()	Sends a message to the given address
 */
msgsend(post)
struct postbox *post;
{
	int i, found;

	/* Waits until an empty postbox can be found then writes new message.
	 * All processes waiting for mail are woken up to check for it.
	 * Process is sent to sleep until a postbox is free.
	 */
	while(!found){
		for(i = 0; i < NPOSTBOX; i++){
			if(post[i].p_type){
				found++;
				break;
			}
		}
		sleep(&post[0], PSLEP);
	}

	/* copies message into postbox */
	bytecp(post, &post[i], sizeof(struct postbox));
	wakeup(&post[0]);
	return 0;
}

/*
 *	Msgwait()	Waits for a message to be recieved
 */
msgwait(post)
struct postbox *post;
{
	int i, found;

	while(!found){
		for(i = 0; i < NPOSTBOX; i++){
			if((post[i].p_type) &&
				addeq(post[i].p_destin, cur_proc->postadd)){
				found++;
				break;
			}
		}
		sleep(&post[0], PSLEP);
	}
	bytecp(&post[i], post, sizeof(struct postbox));
	return 0;
}

/*
 *	Msgcheck()	Checks if there is a message for the process
 */
msgcheck(post)
struct postbox *post;
{
	int i;

	for(i = 0; i < NPOSTBOX; i++){
		if((post[i].p_type) &&
			addeq(post[i].p_destin, cur_proc->postadd)){
			bytecp(&post[i], post, sizeof(struct postbox));
			return 1;
		}
	}
	return 0;
}
/*
 *	Postadd()	Gets postage address
 */
postadd(add)
char *add;
{
	bytecp(cur_proc->postadd, add, 8);
	return 1;
}
