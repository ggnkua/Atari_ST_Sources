#include <stdlib.h>
#include <string.h>
#include <windom.h>
#include <gslib.h>

/* exemple : reception de commande */

void myGScommands( void *gsc, int argc, char **argv) {
	if( !stricmp( argv[0], "getappversion"))
		GSSetCommandResult( gsc, "1.00");
	else if( !stricmp( argv[0], "getapplongname"))
		GSSetCommandResult( gsc, "testgs");
	else if( !stricmp( argv[0], "quit"))
		ApplWrite( app.id, AP_TERM);
	else
		GSSetCommandResult( gsc, "test: command not supported");
}

void ApTerm( void) {
	GSExit();
	ApplExit();
	exit(0);
}

void main( void) {	
	ApplInit();
	GSInit( myGScommands,0L);
	EvntAttach( NULL, AP_TERM, ApTerm);
	for(;;) EvntWindom( MU_MESAG);
}

