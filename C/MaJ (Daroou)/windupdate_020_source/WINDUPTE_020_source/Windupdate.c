/* **[WindUpdate test]************* */
/* *                              * */
/* * version 0.40                 * */
/* * 20/12/2012 :: 29/01/2015     * */
/* ******************************** */


#include <STDIO.H>
#include <STDLIB.H>
#include <STRING.H>
#include <OSBIND.H>


#define  USE_GEMLIB
#include <GEMX.H>
#include <GEM.H>



/*#define		LOG_FILE*/

/*char texte[256];*/


/* # RSC # */
#include	"FR/WINDUPDT.H"


#include	"Define_application.c"

/* # Variables globales # */
#include	"Variables_application.c"

/* # Prototypes des fonctions # */
#include	"Prototypes_application.c"

/* Fonctions Communes aux applications */
#include	"fonction/coeur/Coeur_fonctions.c"

/* Fonctions propres … l'application */
#include	"Fonctions_windupdate.c"




/*=============================*/
/*===  Procedure principal  ===*/
/*=============================*/
int main( void )
{
	WORD	init;

	init=Fcm_init_coeur_application();


	if( init==EXIT_SUCCESS)
	{
		return( EXIT_SUCCESS );
	}






	if( init==TRUE )
	{

		/* init RSC ici */


		Fcm_charger_config();


		init_barre_menu();
		init_rsc_windupdate();


		Fcm_my_menu_bar( BARRE_MENU, MENU_INSTALL );


		Fcm_ouvre_fenetre_start();


		Fcm_gestion_aes();


		Fcm_sauver_config(FALSE);


		Fcm_fermer_fenetre(FCM_CLOSE_ALL_WIN);


		Fcm_my_menu_bar( BARRE_MENU, MENU_REMOVE );

		Fcm_libere_RSC();

	}


	/* Lib‚ration RAM  / ... */
	fermeture_programme();


	/* fermeture station VDI et session AES */
	Fcm_libere_aes_vdi();


	return(EXIT_SUCCESS);

}

