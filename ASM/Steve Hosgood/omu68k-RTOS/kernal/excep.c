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
 *
 *	If the trap() routine is entered a list of redirecatble exceptions
 *	is checked to see if the trap has been redirected, if so the apropriate
 *	vector is jumped to.
 */

# include	"../include/signal.h"
# include	"../include/param.h"
# include	"../include/inode.h"
# include	"../include/procs.h"
# include	"../include/excep.h"

extern	long dispatc[];			/* Dispatch table */

/*	Redirection structures */
struct	E_redir	e_redir[NREDIR];

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
	/* If no redirected exceptions do fault processing */
	if(!chk_excep(number)){

		switch(number){
		case TBUSERR:
			/* Bus error */
			sendsig(cur_proc->pid, SIGBUS, 1);
			break;

		case TADDERR:
			/* Address error */
			sendsig(cur_proc->pid, SIGSEGV, 1);
			break;

		case TILLEGAL:
			/* Illegal instruction error */
			sendsig(cur_proc->pid, SIGILL, 1);
			break;

		case TDIVZERO:
			/* Zero divide */
			sendsig(cur_proc->pid, SIGFPE, 1);
			break;

		case TTRACE:
			/* Trace */
			sendsig(cur_proc->pid, SIGTRAP, 1);
			break;

		case TINBUS:
			/* Instrument bus interupt */
			i_inbus();
			printf("Instrument bus spurious interupt! %d error\n\r",number);
			break;

		default:
			/* Undefined */
			printf("Trap %d error\n\r",number);
			sendsig(cur_proc->pid, SIGTERM, 0);
			break;

		}
	}

	/* Process signals, events etc generated */
	checkmev();
}

/*
 *	Chk_excep()	Checks if exception has been redirected
 *			If so check each of the possible redirections utill
 *			a valid one is found.
 *			Returns 1 if valid exception has been processed
 *			0 if not.
 */
chk_excep(num)
int	num;
{
	register int	nr, vect;
	register struct	E_redir *redir;

	/* Checks each redirection entry */
	redir = e_redir;
	for(nr = 0; nr < NREDIR; nr++){
		if(num == redir->vectno){
			/* If entry found for vector try each valid one for
			 * a responce of 1, if found return 1 to indicate vector
			 * has been processed
			 */
			for(vect = 0; vect < NPERREDIR; vect++){
				if(redir->vectors[vect]){
					if(redir->vectors[vect]()) return 1;
				}
			}
		}
		redir++;
	}
	return 0;
}

/*
 *	Settrap()	Initialise a redirection trap vector to point to
 *			somewhere.
 *			Returns 0 if ok, -1 if error.
 */
settrap(trapno, address)
int	trapno;
int	(*address)();
{
	int	nr, vect;
	struct	E_redir *redir;

	if((trapno < 0) || (trapno > 255)) return -1;

	/* Gets redirection entry either unused, or for same vector */
	for(nr = 0; nr < NREDIR; nr++){
		redir = &e_redir[nr];
		if(!redir->vectno || (redir->vectno == trapno)){
			redir->vectno = trapno;
			for(vect = 0; vect < NPERREDIR; vect++){
				/* If entry in redirection table set entry */
				if(!redir->vectors[vect]){
					redir->vectors[vect] = address;
					return 0;
				}
			}
		}
	}
	return -1;
}

/*
 *	Clrtrap()	Clears a redirected trap vector
 */
clrtrap(trapno, address)
int	trapno;
int	(*address)();
{
	int	nr, vect, inuse, done;
	struct	E_redir *redir;

	if((trapno < 0) || (trapno > 255)) return -1;

	/* Gets redirection entry for vector */
	for(nr = 0; nr < NREDIR; nr++){
		redir = &e_redir[nr];
		if(redir->vectno == trapno){
			inuse = done = 0;
			for(vect = 0; vect < NPERREDIR; vect++){
				/* If entry in redirection table */
				if(redir->vectors[vect]){
					/* If required vector remove */
					if(redir->vectors[vect] == address){
						redir->vectors[vect] = 0;
						done++;
					}
					else inuse++;
				}
			}
			/* If redirection entry unused remove it */
			if(!inuse) redir->vectno = 0;

			/* If done ok return 0 */
			if(done) return 0;
		}
	}
	return -1;
}
