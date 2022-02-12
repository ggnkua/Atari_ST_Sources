#include "kernel.h"
#include "proc.h"

#ifdef FPP
/*
	support for the Motorola 68881/2 FPA chip.
	we basically assume that the kernel itself (syscall) never
	uses the fpp. Other than that, we'll just see if it there,
	and then save and restore it's state on every task switch 
	if necessary.

	fpp.h - contains state frame definitions etc.
	fpp.c - C -level code, really not much 
	fpps.s - assembler code (all symbols have an extra _ in front )
*/

/*
	initialize the state of a new process
*/
void fpp_new_state(rp)
struct proc *rp;
{
	*(long *)rp->p_fsave = 0;	/* null state */
}
/*
	save state for a process
*/
void fpp_save(rp)
struct proc *rp;
{
	/* only save state if present or not super */
	if (rp->p_reg.psw & 0x2000)
		return;
	_fppsave(rp->p_fsave);
	if (*(long *)rp->p_fsave)	/* only dump registers if not null */
		_fppsavereg(&rp->p_fsave[216]);
}
/*
	restore process state
*/
void fpp_restore(rp)
struct proc *rp;
{
	if (rp->p_reg.psw & 0x2000)
		return;
	if (*(long *)rp->p_fsave)	/* only restore when !null state */
		_fpprestreg(&rp->p_fsave[216]);
	_fpprestore(rp->p_fsave);
}
#endif
