/* **[Fonction commune]***************** */
/* * affichage d'une alerte avec       * */
/* * message contenu dans un ressource * */
/* * 10/04/2003 = 11/01/2015           * */
/* ************************************* */



#ifndef __Fcm_form_alerte__
#define __Fcm_form_alerte__



/* Prototype */
int16 Fcm_form_alerte( const int16 arbre_idx, const int16 texte_idx );


/* Fonction */
int16 Fcm_form_alerte( const int16 arbre_idx, const int16 texte_idx )
{

	int16 reponse;


	/* --------------------------------------- */
	/* Si un index d'arbre du RSC est transmis */
	/* --------------------------------------- */
	if( arbre_idx != 0 )
	{
		OBJECT	*adr_formulaire;


		/* on cherche l'adresse du formulaire */
		reponse = rsrc_gaddr( R_TREE, arbre_idx, &adr_formulaire );

		if( reponse != 0 )
		{
			#ifdef LOG_FILE
			sprintf( buf_log, " * Fcm_form_alerte() {%s}"CRLF, (adr_formulaire+texte_idx)->ob_spec.free_string );
			log_print(FALSE);
			#endif

			reponse=form_alert( 1, (adr_formulaire+texte_idx)->ob_spec.free_string );
		}
		else
		{
			reponse=0;

			#ifdef LOG_FILE
			sprintf( buf_log, "ERREUR Fcm_form_alerte() Objet inexistant"CRLF );
			log_print(FALSE);
			#endif
		}
	}
	else
	{
		/* --------------------------------------- */
		/* Pas d'arbre RSC, il s'agit d'une chaine */
		/* --------------------------------------- */
		CHAR	*pt_chaine;



		reponse = rsrc_gaddr( R_STRING, texte_idx, &pt_chaine );

		if( reponse != 0 )
		{

			#ifdef LOG_FILE
			sprintf( buf_log, " * Fcm_form_alerte() {%s}"CRLF, pt_chaine );
			log_print(FALSE);
			#endif

			reponse=form_alert(1, pt_chaine);
		}
		else
		{
			reponse=0;

			#ifdef LOG_FILE
			sprintf( buf_log, "ERREUR Fcm_form_alerte() Objet inexistant"CRLF );
			log_print(FALSE);
			#endif
		}
	}


	return( reponse );


}


#endif

