/* **[Fonction commune]***************** */
/* * affichage d'une alerte avec       * */
/* * message contenu dans un ressource * */
/* * 01/03/2015 MaJ 02/03/2015         * */
/* ************************************* */



#ifndef __Fcm_affiche_alerte__
#define __Fcm_affiche_alerte__


#define  DATA_MODE_COEUR  (1)	/* RSC dialogue coeur */
#define  DATA_MODE_APPLI  (2)	/* RSC dialogue appli */
#define  DATA_MODE_USER   (3)	/* Chaine … afficher  */



/* Prototype */
int16 Fcm_affiche_alerte( const int16 data_mode, const uint32 data, int16 *bouton );


/* Fonction */
int16 Fcm_affiche_alerte( const int16 data_mode, const uint32 data, int16 *bouton )
{

	int16 reponse=0;


	/* valeur par d‚faut, en cas d'erreur */
	*bouton=0;


	if( data_mode!=DATA_MODE_COEUR && data_mode!=DATA_MODE_APPLI && data_mode!=DATA_MODE_USER)
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "ERREUR Fcm_form_alerte() data mode incorrect"CRLF );
		log_print(FALSE);
		#endif

		return(-1);
	}





	if( data_mode==DATA_MODE_COEUR || data_mode==DATA_MODE_APPLI )
	{
		OBJECT	*adr_formulaire;


		if( data_mode==DATA_MODE_COEUR )
		{
			reponse = rsrc_gaddr( R_TREE, DL_ALERTE_COEUR, &adr_formulaire );
		}
		else
		{
			reponse = rsrc_gaddr( R_TREE, DL_ALERTE_APPLI, &adr_formulaire );
		}


		if( reponse != 0 )
		{
			#ifdef LOG_FILE
			sprintf( buf_log, " * Fcm_form_alerte() {%s}"CRLF, (adr_formulaire+data)->ob_spec.free_string );
			log_print(FALSE);
			#endif

			reponse=form_alert( 1, (adr_formulaire+data)->ob_spec.free_string );
		}
		else
		{
			#ifdef LOG_FILE
			sprintf( buf_log, "ERREUR Fcm_form_alerte() Objet inexistant"CRLF );
			log_print(FALSE);
			#endif

			return(-1);
		}
	}






	if( data_mode==DATA_MODE_USER )
	{
		/* --------------------------------------- */
		/* Pas d'arbre RSC, il s'agit d'une chaine */
		/* --------------------------------------- */
		char *pt_chaine = (char *)data;

		#ifdef LOG_FILE
		sprintf( buf_log, " * Fcm_form_alerte() {%s}"CRLF, pt_chaine );
		log_print(FALSE);
		#endif

		reponse=form_alert(1, pt_chaine);

	}



	*bouton = reponse;


	return(0);


}


#endif /* __Fcm_affiche_alerte__ */

