/*************************************************************************

	Turbo C - MidiShare Library 
	
	___________________________________________________________
	Function: MidiShare
	tests MidiShare code presence in memory
	
	Prototype: int MidiShare(void);

	___________________________________________________________
	Function: TCMidiRestaure
	restore the MidiShare entry point. Usefull to test 
	the applications without leaving Turbo-C.
	
	Prototype: void TCMidiRestaure(void);
	

**************************************************************************/

#include <tos.h>
#include <stdio.h>


int _trapCode_[]= { 0x4E46, 0x4E75 };
unsigned long cdecl (* micro_rtx)()= (void *)_trapCode_;


int returnCode=1;
char *key = "MIDISHARE";
void *trap[2];


/*************************************************************************/
static void _TC_is()
{
	register char **trapPtr, *val, *code;
	register int i;

	returnCode= 1;
	code= key;
	trapPtr = (char **)0x94L;
	val  = (char *)*trapPtr - 18;
	for ( i = 0; i < 9; i++, code++, val++) {
		if ( *code != *val)
			returnCode= 0;
	}
}

/*************************************************************************/
int	MidiShare()
{
	Supexec( _TC_is);
	return returnCode;
}

/*************************************************************************/
static void _TCMidiRestore()
{
	register void **saveAdr, **trapPtr;
	register char *val, *code;
	register int i;

	code= key;
	val  = (char *)trap[0] - 18;
	for ( i = 0; i < 9; i++, code++, val++)
	{
		if ( *code != *val)
		{
			returnCode= 0;
			return;
		}
	}
	trapPtr = (void **)0x94L;
	*trapPtr++= trap[0];
	*trapPtr= trap[1];
}

#define DRIVE_C		4

/*************************************************************************/
int	TCMidiRestore()
{
	FILE *fd;
	char name[25], *error="MidiRestore: error";
	long drives;
		
	returnCode= 1;
	drives= Drvmap();
	if( drives & DRIVE_C)
		strcpy( name, "C:\\midisave");
	else
		strcpy( name, "A:\\midisave");
	if( !(fd= fopen( name, "r")))
	{
		printf( "%s opening %s.\n", error, name);
		returnCode= 0;
	}
	else
	{
		if( fread( trap, sizeof( void *), 2, fd)!= 2)
		{
			printf( "%s reading %s.\n", error, name);
			returnCode= 0;
		}
		else
		{
			Supexec( _TCMidiRestore);
			if( !returnCode)
				printf( "%s bad pointer for MidiShare.\n", error);
		}
		fclose( fd);
	}
	return returnCode;
}

/******************************** end ************************************/
