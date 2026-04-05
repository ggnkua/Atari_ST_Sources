/* **[Fonction Commune]********* */
/* *                           * */
/* * 23/05/2015 MaJ 04/03/2021 * */
/* ***************************** */




void Fcm_gestion_erreur_config( void )
{


	#ifdef LOG_FILE
	sprintf( buf_log, "## Fcm_gestion_erreur_config()"CRLF);
	log_print( FALSE );
	#endif



	if( Fcm_config_erreur==ALC_NORAMCONFIG )
	{
		int16 dummy;

		Fcm_affiche_alerte( DATA_MODE_COEUR, ALC_NORAMCONFIG, &dummy );
	}




	if( Fcm_config_erreur_config>0 || Fcm_config_tag_absent>0 )
	{
		/*****************************************************/
		/* si des erreurs ont ‚t‚ d‚tect‚es                  */
		/*****************************************************/

		char    my_buffer[TAILLE_BUFFER];
		OBJECT *adr_formulaire;
		int16   dummy;


		rsrc_gaddr( R_TREE, DL_ALERTE_COEUR,  &adr_formulaire );

		if( strlen( (adr_formulaire+ALC_BAD_CONFIG)->ob_spec.free_string ) < (TAILLE_BUFFER-5) )
		{
			sprintf( my_buffer, (adr_formulaire+ALC_BAD_CONFIG)->ob_spec.free_string, Fcm_config_erreur_config, Fcm_config_tag_absent );
			Fcm_affiche_alerte( DATA_MODE_USER, (uint32)my_buffer, &dummy );
		}
		else
		{
			#ifdef LOG_FILE
			sprintf( buf_log, "ERREUR - Taille buffer trop faible"CRLF );
			log_print( FALSE );
			#endif
			/* on affiche le message tel quel, sans modifier les valeurs */
			Fcm_affiche_alerte( DATA_MODE_USER, (uint32)(adr_formulaire+ALC_BAD_CONFIG)->ob_spec.free_string, &dummy );
		}
	}


	return;


}


