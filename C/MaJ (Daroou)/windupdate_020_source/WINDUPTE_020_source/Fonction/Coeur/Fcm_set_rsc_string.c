/* **[Fonction Commune]******* */
/* *                         * */
/* * 10/03/2013 = 09/01/2015 * */
/* *************************** */


#ifndef __Fcm_set_rsc_string__
#define __Fcm_set_rsc_string__




/* Prototype */
void Fcm_set_rsc_string( const int16 idx_dialogue, const int16 objet, const char *chaine );


/* Fonction */
void Fcm_set_rsc_string( const int16 idx_dialogue, const int16 objet, const char *chaine )
{
	OBJECT	*adr_formulaire;
	int16	erreur;


	#ifdef LOG_FILE
	sprintf( buf_log, "    * Fcm_set_rsc_string( dialogue:%d, objet:%d, chaine:{%s} )", idx_dialogue, objet, chaine );
	log_print(FALSE);
	#endif


	/* on cherche l'adresse du formulaire */
	erreur=rsrc_gaddr( R_TREE, idx_dialogue, &adr_formulaire );

	#ifdef LOG_FILE
	sprintf( buf_log, " -> reponse rsrc_gaddr() : %d"CRLF, erreur );
	log_print(FALSE);
	#endif


	if( erreur == 0 )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "ERREUR l'objet n'existe pas "CRLF );
		log_print(FALSE);
		#endif

		return;
	}







	erreur=FALSE;

	switch( adr_formulaire[objet].ob_type )
	{
		case G_STRING:
		case G_BUTTON:
			if( strlen( adr_formulaire[objet].ob_spec.free_string) >= strlen(chaine) )
			{
				strcpy( adr_formulaire[objet].ob_spec.free_string, chaine );
			}
			else
			{
				erreur=TRUE;
			}
			break;


		case G_TEXT:
		case G_FTEXT:
		case G_BOXTEXT:
		case G_FBOXTEXT:

			if( strlen( adr_formulaire[objet].ob_spec.tedinfo->te_ptext) >= strlen(chaine) )
			{
				strcpy( adr_formulaire[objet].ob_spec.tedinfo->te_ptext, chaine );
			}
			else
			{
				erreur=TRUE;
			}
			break;

		default:
			#ifdef LOG_FILE
			sprintf( buf_log, "ERREUR type d'objet non gere pour le moment (%d)"CRLF, adr_formulaire[objet].ob_type );
			log_print(FALSE);
			#endif
			break;
	}



	if( erreur==TRUE )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "ERREUR !!! chaine plus longue que la destination"CRLF);
		log_print(FALSE);
		#endif
	}


	return;


}


#endif

