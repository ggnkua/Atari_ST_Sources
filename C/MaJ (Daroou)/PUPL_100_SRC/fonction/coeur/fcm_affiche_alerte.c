/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 01/03/2015 MaJ 29/02/2024 * */
/* ***************************** */



/*
 * affichage d'une alerte avec message contenu
 * dans un ressource (RSC)
 *
 */



#ifndef __FCM_AFFICHE_ALERTE_C__
#define __FCM_AFFICHE_ALERTE_C__


#include "fcm_affiche_alerte.h"



int16 Fcm_affiche_alerte( const int16 data_mode, const uint16 idx_alert, int16 *bouton )
{
	int16 reponse=0;


	FCM_LOG_PRINT3("# Fcm_affiche_alerte( dm=%d, idx=%d, bt=%p)", data_mode, idx_alert, bouton);
//FCM_CONSOLE_DEBUG3("Fcm_affiche_alerte( DM=%d, idx_alert=%d, BT=%p)", data_mode, idx_alert, bouton);


	/* Adresse de bouton vaut 0 si pas de réponse attendu, */
	/* cas d'une alerte avec un seul bouton, cela évite    */
	/* de déclarer une variable pour la reponse            */

	/* valeur par d‚faut, en cas d'erreur */
	if( bouton != 0L ) *bouton = 0;


	if( data_mode != DATA_MODE_COEUR  &&  data_mode != DATA_MODE_APPLI  &&  data_mode != DATA_MODE_USER)
	{
		FCM_LOG_PRINT("ERREUR Fcm_affiche_alerte() data_mode incorrect");
		FCM_CONSOLE_DEBUG("Fcm_affiche_alerte() : data_mode incorrect");

		return(-1);
	}



	if( data_mode == DATA_MODE_COEUR   ||   data_mode == DATA_MODE_APPLI )
	{
		OBJECT	*adr_formulaire;

		if( data_mode==DATA_MODE_COEUR )
		{
			/* C'est une alerte du Coeur des Applications */
			adr_formulaire = Fcm_adr_RTREE[ DL_ALERTE_COEUR ];
		}
		else
		{
			/* C'est une alerte local à l'application */
			adr_formulaire = Fcm_adr_RTREE[ DL_ALERTE_APPLI ];
		}


		if( adr_formulaire != (OBJECT *)0L )
		{
			FCM_LOG_PRINT1("  -> Fcm_win_form_alert() {%s}", adr_formulaire[idx_alert].ob_spec.free_string );

			reponse = Fcm_win_form_alert( 1, adr_formulaire[idx_alert].ob_spec.free_string );
		}
		else
		{
			FCM_LOG_PRINT("Fcm_affiche_alerte() DL_ALERTE_xxx inexistant");
			FCM_CONSOLE_DEBUG("Fcm_affiche_alerte() DL_ALERTE_xxx inexistant");

			return(-1);
		}
	}



	/* pas d'arbre RSC, il s'agit d'une chaine. */
	/* Etait utilisé par la gestion des erreurs de config, qui n'existe plus. */
	/* N'est plus utilisé par le Coeur, mais peut-être en local par une appli */
	/* Mode obsolète, on garde le test pour afficher une erreur console       */
	/* Utilise en cas d'erreur inconnu, affiche_error() */
	if( data_mode == DATA_MODE_USER )
	{
		FCM_CONSOLE_DEBUG("Fcm_affiche_alerte() : DATA_MODE_USER desactivé");
		evnt_timer(2000);
		return(-1);

/*		char *pt_chaine = (char *)data;

		FCM_LOG_PRINT1(" * Fcm_affiche_alerte() {%s}", pt_chaine );
		reponse = Fcm_win_form_alert( 1, pt_chaine );*/
	}


	/* réponse si souhaitée */
	if( bouton != 0L ) *bouton = reponse;


	return(0);

}


#endif /* __FCM_AFFICHE_ALERTE_C__ */

