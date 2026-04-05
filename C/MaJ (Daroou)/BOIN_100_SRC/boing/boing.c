/* **[Boing]******************** */
/* *                           * */
/* * 20/09/2015 MaJ 06/11/2023 * */
/* ***************************** */


#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <osbind.h>


#include <gemx.h>


#include    "../fonction/coeur/type_gcc.h"

#include	"rsc/fr/boing.h"

#include	"define_application.h"
#include	"appli_error_code.h"

#include	"prototypes_application.h"

/* fonctions communes aux applications */
#include	"../fonction/coeur/coeur_fonctions.h"
#include	"../fonction/fcm_fenetre_launch.c"
#include	"../fonction/graphique/fcm_select_pixel_xformat.c"
#include	"../fonction/graphique/fcmgfx_sprite_fonctions.h"
#include	"../fonction/audio/fcm_sound_play.c"

#include	"boing_global.h"

#include	"variables_application.c"
#include	"fonctions_application.c"



/*=============================*/
/*===  Procedure principal  ===*/
/*=============================*/
int main( void )
{
	int32	init;



	init = Fcm_init_coeur_application();

	if( init == EXIT_SUCCESS)
	{
		return( EXIT_SUCCESS );
	}



	if( init == TRUE )
	{
		init_barre_menu();

		rescale_rsc_options();
		rescale_rsc_ram();

		/* pour ne pas redemarrer au premier lancement du programme */
		/* voir init_boing() -> gestion appel init_surface()      */
		global_nb_redemarrage_succesif = 1;

		init_animation();

		/* on sauve le format des pixels au cas ou l'utilisateur force */
		/* un autre format, permet le retour en mode auto              */
		global_save_pixel_xformat = Fcm_screen.pixel_xformat;


		/* Permet de redemmarer si une erreur arrive dans init_boing() */
		/* Detection Auto ou mode forcé incorrect ou autres... */
		global_app_restart=TRUE;


		/*--------- Boucle restart - debut ----------------------*/
		do
		{
				Fcm_init_appli_terminer=FALSE;

				init=init_boing();

				if( init == 0 )
				{
					global_app_restart = FALSE;  /* TRUE pour redemarrer l'appli */

					Fcm_set_config_generale();
					set_config();

					calcul_screen();
					build_screen();


					Fcm_my_menu_bar( BARRE_MENU, MENU_INSTALL );
					Fcm_ouvre_fenetre_start();

//FCM_CONSOLE_ADD2("dial[INFO_IMG_RENAIS].ob_height=%d", Fcm_adr_RTREE[DL_INFO_PRG][INFO_IMG_RENAIS].ob_height, G_GREEN );
//FCM_CONSOLE_ADD2("Fcm_struct_console_global.nbligne_visible = %d",Fcm_struct_console_global.nbligne_visible, G_GREEN);

					/* on force l'ouverture de la fenetre Boing */
					ouvre_fenetre_boing();

					/* gestion_timer() peut etre executer a partir de maintenant */
					Fcm_init_appli_terminer = TRUE;

					gestion_timer(); /* Start Animation */


					/* La boucle principale de gestion GEM de l'appli */
					/* en on sort que pour quitter ou redémarrer       */
					Fcm_gestion_aes();


				}
				else
				{
					affiche_error(init);
				}


				Fcm_sauver_config(FALSE);

				/* on stoppe l'animation, sinon elle continu d'être */
				/* calculé/affiché via fcm_purge_aes_message()      */
				global_animation_pause = TRUE;

				Fcm_fermer_fenetre(FCM_CLOSE_ALL_WIN);
				Fcm_my_menu_bar( BARRE_MENU, MENU_REMOVE );

				exit_boing();


		} while( global_app_restart==TRUE );
		/*--------- Boucle restart - fin ------------------------*/


		Fcm_libere_RSC();
	}


	#ifdef LOG_FILE
	Fcm_libere_ram(FCM_LIBERE_RAM_CHECK);
	#endif

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

