/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 10/03/2013 MaJ 29/02/2024 * */
/* ***************************** */


/*

  Cette fonction modifie un objet texte du RSC.

  L'objet texte du RSC garde toujours le meme nombre de char,
  le texte est completee par des espaces si necessaire.

  Cela permet que l'objet texte du RSC ne peut pas etre
  corrompu par un ecrasement d'une chaine trop longue.
  L'appli n'a pas a verifier la taille de la chaine,
  c'est la fonction qui la controle.

  Si la chaine est trop longue, le champ du RSC n'est pas
  modifié, un message d'erreur console est sortie si activé.

*/



#ifndef __FCM_SET_RSC_STRING_C__
#define __FCM_SET_RSC_STRING_C__



/* fonction interne qui copie la chaine dans le champ du RSC */
int16 Fcm_set_rsc_string_build( char *chaine_rsc, const char *chaine_source);




void Fcm_set_rsc_string( const int16 idx_dialogue, const int16 objet, const char *chaine )
{
	OBJECT	*adr_formulaire;
	int16	erreur;


	FCM_LOG_PRINT3("* Fcm_set_rsc_string(dial:%d, obj:%d, str:{%s})", idx_dialogue, objet, chaine );



	adr_formulaire = Fcm_adr_RTREE[idx_dialogue];

	if( adr_formulaire == (OBJECT *)0L )
	{
		FCM_LOG_PRINT("# ERREUR adr_formulaire=0");
		FCM_CONSOLE_DEBUG("Fcm_set_rsc_string() : erreur adr_formulaire=0");

		return;
	}


	erreur = FALSE;

	switch( adr_formulaire[objet].ob_type )
	{
		case G_STRING:
		case G_BUTTON:
		case G_TITLE:
			{
				erreur = Fcm_set_rsc_string_build( adr_formulaire[objet].ob_spec.free_string, chaine );
			}
			break;

		case G_TEXT:
		case G_FTEXT:
		case G_BOXTEXT:
		case G_FBOXTEXT:
			{
				erreur = Fcm_set_rsc_string_build( adr_formulaire[objet].ob_spec.tedinfo->te_ptext, chaine );
			}
			break;

		default:
			FCM_CONSOLE_DEBUG1("Fcm_set_rsc_string() : type objet non gere (%d)", adr_formulaire[objet].ob_type );
			break;
	}


	if( erreur == TRUE )
	{
		FCM_CONSOLE_DEBUG("Fcm_set_rsc_string() : chaine plus longue que la destination");
		FCM_CONSOLE_DEBUG3("dialogue:%d, objet:%d, chaine:{%s}", idx_dialogue, objet, chaine );

		FCM_LOG_PRINT( "# ERREUR chaine plus longue que la destination"CRLF);
	}

	return;

}




int16 Fcm_set_rsc_string_build( char *chaine_rsc, const char *chaine_source)
{
	uint16 size_str_rsc;
	uint16 size_str;
	uint16 idx;


	size_str_rsc = strlen( chaine_rsc );
	size_str = strlen( chaine_source );

//FCM_CONSOLE_DEBUG1("len chaine_rsc=%ld", strlen(chaine_rsc) );
//FCM_CONSOLE_DEBUG1("len chaine_source=%ld", strlen(chaine_source) );

	if( size_str_rsc >= size_str )
	{
		strcpy( chaine_rsc, chaine_source );

		if( size_str < size_str_rsc )
		{
			for( idx=size_str; idx < size_str_rsc; idx++ )
			{
				chaine_rsc[idx]=' ';
				//chaine_rsc[idx]='*';
			}
			chaine_rsc[size_str_rsc]='\0';
		}
	}
	else
	{
		return(TRUE); /* erreur */
	}


	/* cette erreur ne devrait jamais arriver */
	if( size_str_rsc != strlen(chaine_rsc) )
	{
		FCM_CONSOLE_DEBUG("Fcm_set_rsc_string_build() : Erreur len() chaine rsc differente" );
		FCM_CONSOLE_DEBUG1("chaine_rsc=%s ", chaine_rsc );
	}

	return(FALSE); /* OK */

}


#endif  /*  __FCM_SET_RSC_STRING_C__  */

