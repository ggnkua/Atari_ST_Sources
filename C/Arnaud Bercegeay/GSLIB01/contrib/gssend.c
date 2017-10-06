#include <stdio.h>
#include <string.h>
#include <windom.h>
#include <gslib.h>

/* exemple : Envoi de commande */

int main( int argc, char *argv[]) {
	void *gsc;
	int apid;
	char name[65];
	
	ApplInit();
	GSInit( NULL,0L);
	
	/* recherche cible et ouverture session GS 
	 * entre les deux applications  */
	if( argc > 1) {
		strcpy( name, argv[1]);
		strupr( name);
		strcat( name, "        ");
		name[8] = '\0';
		
		apid = appl_find( name);
		if( apid > 0) {
			gsc = GSOpen( apid);	
			if( gsc) {
				
				/* envoi de la requete */
				if( argc == 2)
					GSSendCommand( gsc, argv[2], 0);
				else if( argc > 2)
					GSSendCommand( gsc, argv[2], argc-2, argv+2);
				
				/* reponse de la requete */
				puts( GSGetCommandResult( gsc));

				/* fermeture session */
				GSClose(gsc);
			} else
				fprintf( stderr, "GSsend: application does not support GSscript.\n");
		} else
			fprintf( stderr, "GSsend: target '%s' not found.\n", argv[1]);	
	} else
		fprintf( stderr, "GSsend version 1.00 by D.B‚r‚ziat. Sends a GSscript command to an application.\n"
						 "Usage is: gssend target command [args...]\n");

	GSExit();
	ApplExit();
	return 0;
}

