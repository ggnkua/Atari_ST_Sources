/* **[Offscreen]**************** */
/* *                           * */
/* * 10/12/2015 MaJ 07/02/2016 * */
/* ***************************** */


#include <STDIO.H>
#include <STDLIB.H>
#include <STRING.H>
#include <OSBIND.H>

#define  USE_GEMLIB
#include <GEMX.H>
#include <GEM.H>

#include <CT60.H>
#include <NVDI.H>
#include <PCIXBIOS.H>




/*#define  LOG_FILE*/



/* Pour debugage mode ct60 vram */
/*#define  CT60_VRAM_IN_TTRAM*/




/* # RSC # */
#include	"RSC/FR/OFFSCREN.H"


#include	"Define_application.c"

#include	"offscreen_error_code.h"
#include	"offscreen_global.H"





/* # Variables # */
#include	"Variables_application.c"


/* # Prototypes des fonctions # */
#include	"Prototypes_application.c"


/* Fonctions Communes aux applications */
#include	"fonction/coeur/Coeur_fonctions.c"


/* Fonctions propres … l'application */
#include	"Fonctions_application.c"


/*=============================*/
/*===  Procedure principal  ===*/
/*=============================*/
int main( void )
{
	int16	init;



	init=Fcm_init_coeur_application();

	if( init==EXIT_SUCCESS)
	{
		return( EXIT_SUCCESS );
	}


/*Fcm_screen.height=599;
Fcm_screen.width=639;*/


	if( init==TRUE )
	{
		init_barre_menu();


		init=init_offscreen();

		if( init== 0 )
		{

			Fcm_my_menu_bar( BARRE_MENU, MENU_INSTALL );

			Fcm_ouvre_fenetre_start();

			ouvre_fenetre_offscreen();
			replace_fenetre_test();


			appl_write( ap_id, 16, tube_gem);

			Fcm_gestion_aes();

			Fcm_fermer_fenetre( W_SPRITE_OFFSCREEN );

		}
		else
		{
			affiche_error(init);
		}


		libere_surface();


		Fcm_sauver_config(FALSE);
		Fcm_fermer_fenetre(FCM_CLOSE_ALL_WIN);
		Fcm_my_menu_bar( BARRE_MENU, MENU_REMOVE );
		Fcm_libere_RSC();
	}




	/* Lib‚ration RAM  / ... */
	fermeture_programme();

	/* fermeture station VDI et session AES */
	Fcm_libere_aes_vdi();


	#ifdef LOG_FILE
	sprintf( buf_log, "#return(EXIT_SUCCESS)"CRLF );
	log_print(FALSE);
	#endif
	return(EXIT_SUCCESS);


}


