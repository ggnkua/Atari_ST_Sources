/******************************************************************************
 *	Excep.c		Exception handler, in conjunction with mcexcep.68k
 ******************************************************************************
 *
 *
 *		All of the 68000 exception vectors are set to point
 *	into the dispatch table. If the dispatch table is less than
 *	the NOVECTORS (256) entries required to accomplish this then
 *	all vectors above will be set to point to the last entry in
 *	the dispatch table.
 *		The dispatch table consisits of a sequence of BSR.W
 *	instructions which will place on the stack their address in
 *	the dispatch table +4, and the jump to the appropriate wrapper
 *	for this exception.
 *	Note these wrappers must be within +- 32K bytes of the BSR.W.
 *
 *	Note if TTRAPS	is defined, some of the traps will be left alone
 *	such that a moniter program can be used for debuging.
 *	The only trap not masked normaly for the Eltec board is the 
 *	software abort, level 7 auto vectered interupt.
 */

# include	"../include/signal.h"
# include	"../include/param.h"
# include	"../include/inode.h"
# include	"../include/procs.h"
# include	"../include/excep.h"

extern	long dispatc[];			/* Dispatch table */

#ifdef	TTRAPS

/*
 *	Table of proccessor vectors not to be touched for moniters use
 */

# define	NO_USED		7	/* Number of vectors not to be used */

char vectused[NO_USED] = {
	TBUSERR, TADDERR, TPRIV, TTRACE,
	TL7AUTO, TTRAP15, TILLEGAL	/* Eltec Abort and return to monitor */
};

#else

/*
 *	Table of proccessor vectors not to be touched normal use
 */

# define	NO_USED		2	/* Number of vectors not to be used */

char vectused[NO_USED] = {
	TL7AUTO, TTRAP15		/* Eltec Abort and return to monitor */
};

#endif	TTRAPS

/*
 *	Excep_init()	Initialise all exceptions
 *			This routine sets the first NOVECTORS, 
 *			proccessors vectors to point to the dispatch
 *			table, unless they are conained within vectused[],
 *			and then allows	interupts to occur.
 */
excep_init(){
	int vectorno, used;
	long *vector;
	long *dispatch;

	/* Sets pointers to start of dispatch table , and vector table */
	dispatch = dispatc;
	vector = VECTORSTART;

	/* Sets all vectors to point into dispatch table */
	for(vectorno = 0; vectorno<NOVECTORS; vectorno++){

		/* Check if vector is being used */
		for(used = 0; used < NO_USED; used++){
			if(vectorno == vectused[used]) break;
		}

		/* If vector is not being used then set it to point
		 * into the dipatch table, else ignore
		 */
		if(used == NO_USED){
			*vector++ = (long)dispatch;
		}
		else{
			vector++;
		}
		/* If end of dispatch table leave pointer here */
		if(vectorno < (NO_DISPATC-1)) dispatch++;
	}
}

/*
 *	Fault exception handler, for exceptions with no where to go.
 */
trap(number)
int number;
{
	switch(number){
	case 2:
		/* Bus error */
		sendsig(cur_proc->pid, SIGBUS, 0);
		break;

	case 3:
		/* Address error */
		sendsig(cur_proc->pid, SIGSEGV, 0);
		break;

	case 4:
		/* Bus error */
		sendsig(cur_proc->pid, SIGILL, 0);
		break;

	case 5:
		/* Zero divide */
		sendsig(cur_proc->pid, SIGFPE, 0);
		break;

	case 9:
		/* Trace */
		sendsig(cur_proc->pid, SIGTRAP, 0);
		break;

	default:
		/* Undefined */
		printf("Trap %d error\n\r",number);
		sendsig(cur_proc->pid, SIGTERM, 0);
		break;

	}

	/* Process signals, events etc generated */
	checkmev();
}

/*
 *	Settrap()	Initialise a trap vector to point to somewhere 
 *			Returns the previous value.
 */
caddr_t
settrap(trapno, address)
int	trapno;
caddr_t	address;
{
	long	*vector;
	caddr_t	oldaddress;

	if((trapno < 0) || (trapno > 255)) return 0;
	/* Sets pointers to start of dispatch table , and vector table */
	vector = (long *)(VECTORSTART + (trapno * sizeof(long)));

	oldaddress = (caddr_t)*vector;
	*vector = (long)address;
	return	oldaddress;
}
