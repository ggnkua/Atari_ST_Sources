#include <stdlib.h>
#include <aes.h>
#include "gem_init.h"
#include "direct.h"
#include "constant.h"
char *sound_buffer;

void main(void)
{ 
 short int i;

 gem_init();				/* initialisaton de l'AES et VDI */
 if ( ( sound_buffer = malloc(SOUND_BUF_LEN)) == 0 ) 
	form_alert(1,"[3][Pas assez de m‚moire!][FIN]");
 else	
 {
 	if (  rsrc_load("d2d2.rsc")==0  )
 		form_alert(1,"[3][Pas de fichier RSC!][FIN]");
 	else
 		direct2disk();
 };

 free(sound_buffer);		/* lib‚re la m‚moire */	
 rsrc_free();				/* efface le fichier ressource de la memoire */
 gem_exit();
}
 						