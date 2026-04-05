/* **[Fonction Commune]******* */
/* *                         * */
/* * 02/01/2013  06/04/2013  * */
/* *************************** */


#include "Fcm_Menu_Tnormal.c"
#include "Fcm_gestion_fermeture_programme.c"



/* Prototype */
VOID Fcm_gestion_barre_menu( VOID );


/* Fonction */
VOID Fcm_gestion_barre_menu( VOID )
{


	/* ---------------------------------------------- */
	/* Ici on gäre les clic sur la barre de Menu,     */
	/* on intercepte les clics sur les menus          */
	/* communs, sinon on lance la fonction de gestion */
	/* de l'application                               */
	/* ---------------------------------------------- */



	/* On remet le MENU dans son Çtat d'origine */
	Fcm_menu_tnormal( BARRE_MENU, buffer_aes[3], 1 );



	switch( buffer_aes[4] )
	{
		/* Interception des options du MENU qui sont communes */
		/* Ö toutes les applications                          */
		case MN_QUITTER:
			Fcm_gestion_fermeture_programme();
			break;

		case MN_INFO_PRG:
			Fcm_ouvre_fenetre_info();
			break;


		case MN_PREFERENCE:
			Fcm_ouvre_fenetre_preference();
			break;

		case MN_SAUVER_CONFIG:
			Fcm_sauver_config(TRUE);
			break;


		default:
			/* On redirige vers la fonction qui gäre les options du */
			/* MENU spÇcifique Ö l'application                      */

			gestion_barre_menu();
			break;
	}


	return;

}

