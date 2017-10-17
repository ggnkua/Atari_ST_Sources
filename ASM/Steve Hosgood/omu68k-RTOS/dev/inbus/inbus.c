/*******************************************************************************
 *	Inbus.c		Instrument  bus handler
 *******************************************************************************
 */

# include	<setjmp.h>
# include	"inbus.h"
# include	"../../include/excep.h"

int	bus_err();

static jmp_buf	env;		/* Saves enviroment for long jump */

/*
 *	I_inbus()	Instrument bus spurious interupt service
 */
i_inbus(){
	struct	Inbus *inbus;
	int	i;
	long	obusvect, *pbusvect;


	/* Gets address of buserror vector */
	pbusvect = (long *)((TBUSERR * 4) + VECTORSTART);
	obusvect = *pbusvect;		/* Gets old value of bus error vector */
	*pbusvect = (long)bus_err;	/* Sets bus error vector to bus_err */

	/* Strolls along instrument bus to find board which is interupting
	 * when found clears its interupt enable bit and returns
	 * If a bus error occurs jumps to next instrument.
	 */
	for(i = 0; i < NINSBOARDS; i++){
/*printf("I_inbus: Testing board %d\n\r",i);*/
		inbus = ADDINBOARD(i);

		/* Sets jump point for bus error return if bus error return
		 * Continue around for loop.
		 */
		if(!setjmp(env)){
			if(inbus->status & SINTP){
/*printf("I_inbus: address %x\n\r",inbus);
printf("I_inbus: Status %x\n\r",inbus->status);
printf("I_inbus: Seen interrupt on board %d\n\r",i);*/
				inbus->status &= ~SINTE;
				*pbusvect = obusvect;	/* Recovers bus err */
				return;
			}
		}
	}

	*pbusvect = obusvect;	/* Recovers bus err */
	panic("Inbus: Unable to clear Inbus interrupt!\n");
}

/*
 *	Bus_err()	On bus error jumps here
 */
bus_err(){
	longjmp(env, 1);
	panic("Inbus: Bus error can't long jump!\n");
}
