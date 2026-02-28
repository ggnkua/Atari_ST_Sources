/* **[Fonction Commune]********* */
/* *                           * */
/* * 22/02/2002  =  06/04/2013 * */
/* ***************************** */



#ifndef __Fcm_objet_change__
#define __Fcm_objet_change__




/* Prototypes */
VOID Fcm_objet_change( OBJECT *adr_formulaire, const WORD handle, const UWORD objet, const UWORD etat );


/* Fonction */
VOID Fcm_objet_change( OBJECT *adr_formulaire, const WORD handle_win, const UWORD objet, const UWORD etat )
{


	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_objet_change(%8p,%d,%d,%d)"CRLF,adr_formulaire,handle_win,objet,etat );
	log_print( FALSE );
	#endif



	switch( etat )
	{
		case OS_SELECTED:
			SET_BIT_W( (adr_formulaire+objet)->ob_state, OS_SELECTED, 1);
			break;

		case 0:
			SET_BIT_W( (adr_formulaire+objet)->ob_state, OS_SELECTED, 0);
			break;

		default:
			#ifdef LOG_FILE
			sprintf( buf_log, "# *** ERREUR *** Fcm_objet_change(): etat=%d"CRLF, etat);
			log_print(FALSE);
			sprintf( buf_log, "# *** ERREUR *** Etat inconnu ! redraw objet sans modification "CRLF);
			log_print(FALSE);
			#endif
			break;
	}


	/* On redessine l'objet */
	Fcm_objet_draw( adr_formulaire, handle_win, objet, FCM_WU_BLOCK );


	return;


}


#endif

