/* **[Fonction commune]***** */
/* *                       * */
/* * 20/01/2013 08/04/2013 * */
/* ************************* */




#ifndef __Fcm_sauver_config__
#define __Fcm_sauver_config__




#include "Fcm_Fprint.c"
#include "Fcm_save_config_generale.c"



/* Prototype */
VOID Fcm_sauver_config( const WORD force_save );


/* Fonction */
VOID Fcm_sauver_config( const WORD force_save )
{
/*	extern	WORD	win_pos[NB_FENETRE][5];
 *	extern	WORD	h_win[NB_FENETRE];
 *  extern	CHAR	Fcm_chemin_courant[TAILLE_CHEMIN];
 *	extern	CHAR	Fcm_chemin_source[TAILLE_CHEMIN];
 *	extern	CHAR	Fcm_chemin_destination[TAILLE_CHEMIN];
 *	extern	CHAR	Fcm_chemin_config[TAILLE_CHEMIN];
 */

	WORD	handle_fichier;



	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# Fcm_sauver_config(%d)"CRLF" - V‚rification sauvegarde config"CRLF, force_save);
	log_print( FALSE );
	#endif

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF" - Fcm_save_option_auto=%d"CRLF, Fcm_save_option_auto);
	log_print( FALSE );
	#endif

	if( force_save==FALSE && Fcm_save_option_auto==FALSE )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, " - Sauvegarde d‚sactiv‚..."CRLF);
		log_print( FALSE );
		#endif

		return;
	}





	#ifdef LOG_FILE
	sprintf( buf_log, " - Sauvegarde sur: %s"CRLF,Fcm_chemin_config);
	log_print(FALSE);
	#endif

	#ifdef LOG_FILE
	sprintf( buf_log, " => Fcm_save_config_generale()"CRLF);
	log_print(FALSE);
	sprintf( buf_log, " => save_config()"CRLF);
	log_print(FALSE);
	#endif



	handle_fichier=Fcreate( Fcm_chemin_config, 0 );

	if(handle_fichier>0)
	{
		Fcm_fprint( handle_fichier, "* "PRG_FULL_NOM" "PRG_VERSION" *"CRLF"Fichier de Configuration" );
		Fcm_fprint( handle_fichier, "");



		/* ----------------------------------- */
		/* Tout ce qui est commum a toute les  */
		/* applications est Sauver ici         */
		/* ----------------------------------- */
		Fcm_save_config_generale(handle_fichier);






		/* ---------------------------------------------- */
		/* paramŠtre de config propre … cette application */
		/* ---------------------------------------------- */
		save_config(handle_fichier);












		/* ---------------------------------------------- */
		/* Bas de page du fichier de Configuration        */
		/* ---------------------------------------------- */
		Fcm_fprint( handle_fichier, "");
		Fcm_fprint( handle_fichier, "(C) "PRG_ANNEE" Renaissance");
		Fcm_fprint( handle_fichier, "");

		{
			WORD reponse;


			reponse=Fclose( handle_fichier );

			if(reponse<0)
			{
				int16 dummy;

				#ifdef LOG_FILE
				sprintf( buf_log, "Erreur durant la sauvegarde du fichier (err=%d)."CRLF, reponse);
				log_print(FALSE);
				#endif
/*				Fcm_form_alerte( 0, ALT_ERR_SAVE_INF );*/
				Fcm_affiche_alerte( DATA_MODE_COEUR, ALC_ERR_SAVE_INF, &dummy );
			}
		}



		/* On d‚sactive les boutons de sauvegarde config */
/*		{
			OBJECT	*adr_formulaire;
			rsrc_gaddr( R_TREE, DL_OPT_PREF, &adr_formulaire );
			SET_BIT_W( (adr_formulaire+PREF_SAVE_CONFIG)->ob_state, OS_DISABLED, 1);
			if( h_win[W_OPTION_PREFERENCE]>0 )
			{
				Fcm_objet_draw( adr_formulaire, h_win[W_OPTION_PREFERENCE], PREF_SAVE_CONFIG, FCM_WU_BLOCK );
			}
		}*/

	}
	else
	{
		int16 dummy;

		#ifdef LOG_FILE
		sprintf( buf_log, "Erreur (%d) durant le cr‚ation du fichier"CRLF, handle_fichier);
		log_print(FALSE);
		#endif
/*		Fcm_form_alerte( 0, ALT_ERR_SAVE_INF );*/
		Fcm_affiche_alerte( DATA_MODE_COEUR, ALC_ERR_SAVE_INF, &dummy );

	}


	return;


}


#endif

