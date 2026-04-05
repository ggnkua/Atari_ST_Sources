/* **[WindUpdate]*********************** */
/* *                                   * */
/* * Fonction recherchant tous les TAG * */
/* * de configuration locale … l'appli * */
/* * 30/12/2012 MaJ 29/01/2015         * */
/* ************************************* */



#define TAILLE_MY_BUFFER  (16)



void get_tag_config(const char *adr_fichier_config, int16 *erreur_config, int16 *tag_absent)
{

	char  my_buffer[TAILLE_MY_BUFFER]="vide";
	int32 valeur;
	int16 reponse;



	#ifdef LOG_FILE
	sprintf( buf_log, "# get_tag_config (application)"CRLF);
	log_print(FALSE);
	#endif



	/* --------------------------------------------------------- */
	/* Ici, tous les TAG propre … l'application                  */
	/* --------------------------------------------------------- */
	{
		valeur=0;


		reponse=Fcm_get_tag( "WU_WINDUPDATE_MODE=", my_buffer, TAILLE_MY_BUFFER, adr_fichier_config );

		if( reponse==TRUE )
		{
			valeur=Fcm_conversion_ascii_to_long( my_buffer );
		}
		else
		{
			*tag_absent = *tag_absent + 1;
		}

		mask_windupdate=FCM_WU_BLOCK;

		if( valeur== 1 )
		{
			/* On selectionne BEG_UPDATE|NO_BLOCK  */
			mask_windupdate=FCM_WU_NO_BLOCK;
		}
		else if( valeur!=0)
		{
			/* valeur par d‚faut */
			*erreur_config = *erreur_config + 1;
		}
	}




	{
		valeur=0;


		reponse=Fcm_get_tag( "WU_WINDUPDATE_REALTIME=", my_buffer, TAILLE_MY_BUFFER, adr_fichier_config );

		if( reponse==TRUE )
		{
			valeur=Fcm_conversion_ascii_to_long( my_buffer );
		}
		else
		{
			*tag_absent = *tag_absent + 1;
		}

		redraw_skip_compteur=WU_SKIP_COMPTEUR;

		if( valeur== 1 )
		{
			/* On selectionne */
			redraw_skip_compteur=0;
		}
		else if( valeur!=0)
		{
			/* valeur par d‚faut */
			*erreur_config = *erreur_config + 1;
		}
	}




	{
		valeur=0;


		reponse=Fcm_get_tag( "WU_NOMBRE_NOBLOCK=", my_buffer, TAILLE_MY_BUFFER, adr_fichier_config );
		if( reponse==TRUE )
		{
			valeur=Fcm_conversion_ascii_to_long( my_buffer );
		}
		else
		{
			*tag_absent = *tag_absent + 1;
		}

		/* On d‚s‚lectionne Temps r‚el par d‚efaut  (valeur=0) */
		mask_noblock_nombre=FCM_WU_BLOCK;

		if( valeur== 1 )
		{
			/* On selectionne */
			mask_noblock_nombre=FCM_WU_NO_BLOCK;
		}
		else if( valeur!=0)
		{
			/* valeur par d‚faut */
			*erreur_config = *erreur_config + 1;
		}
	}



	return;


}


#undef TAILLE_MY_BUFFER

