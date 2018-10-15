/*************************************************************************

	MWC - MidiShare Library 
	
	Function: MidiShare
	tests MidiShare code presence in memory
	
	Prototype: int MidiShare(void);
	
**************************************************************************/

#include <osbind.h>

/*************************************************************************/
int is()
{
register unsigned long *test;			
register char *val;
register char *code = "MIDISHARE";
register int i;

	test = (unsigned long *)0x94L;
	val  = (char *)*test - 18;
	for ( i = 0; i < 9; i++) {
		if ( *code++ != *val++)
			return 0;
	}
	return 1;
}

/*************************************************************************/
int	MidiShare()
{
	return Supexec(&is);
}

/******************************** end ************************************/
