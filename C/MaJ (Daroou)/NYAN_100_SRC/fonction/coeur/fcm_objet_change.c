/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 22/02/2002 MaJ 29/11/2025 * */
/* ***************************** */



#ifndef __FCM_OBJET_CHANGE_C__
#define __FCM_OBJET_CHANGE_C__


void Fcm_objet_change( OBJECT *adr_formulaire, const int16 handle_win, const uint16 objet, const uint16 etat )
{

	FCM_LOG_PRINT4("# Fcm_objet_change(%8p,%d,%d,%d)", adr_formulaire, handle_win, objet, etat );


	switch( etat )
	{
		case OS_SELECTED:
			SET_BIT_W( adr_formulaire[objet].ob_state, OS_SELECTED, 1);
			break;

		case 0:
			SET_BIT_W( adr_formulaire[objet].ob_state, OS_SELECTED, 0);
			break;

		default:
			FCM_LOG_PRINT1("# ERREUR etat inconnu=%d redraw objet sans modification ", etat);
			FCM_CONSOLE_DEBUG1("Fcm_objet_change() : etat inconnu=%d", etat);
			break;
	}

	/* On redessine l'objet */
	Fcm_objet_draw( adr_formulaire, handle_win, objet, FCM_WU_BLOCK );

	return;

}


#endif   /*   __FCM_OBJET_CHANGE_C__    */

