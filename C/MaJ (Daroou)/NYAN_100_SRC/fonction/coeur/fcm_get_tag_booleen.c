/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 20/02/2024 MaJ 03/03/2024 * */
/* ***************************** */



/*
 *
 * cette fonction sert a chercher les tag de config qui ont pour
 * valeur un seul chiffre, 0 (FALSE) ou 1 (TRUE)
 *
 */


#ifndef __FCM_GET_TAG_BOOLEEN_C__
#define __FCM_GET_TAG_BOOLEEN_C__


int16 Fcm_get_tag_booleen( const char *tag, const char *pt_fichier_config, int16 valeur_par_defaut )
{
	char  *pt_position;
	int16  valeur_tag;


/*FCM_LOG_PRINT3( CRLF"  Fcm_get_tag_booleen(%s,%p,%d)", tag, pt_fichier_config, valeur_par_defaut );*/

	if( strlen( tag ) == 0 )
	{
		FCM_CONSOLE_DEBUG("Fcm_get_tag_booleen(): TAG vide");
		return(valeur_par_defaut);
	}


	/* on recherche le TAG dans le buffer de config */
	pt_position = strstr( pt_fichier_config, tag );

	if( pt_position == NULL )
	{
		/* Le TAG n'a pas ‚t‚ trouv‚ */
		FCM_CONSOLE_ADD2("Config: TAG %s absent", tag, G_WHITE);
		return(valeur_par_defaut);
	}

	/* on lit la valeur du TAG */
	valeur_tag = pt_position[ strlen( tag ) ];

/*FCM_CONSOLE_DEBUG1( "valeur tag = %c", valeur_tag );*/

	if( valeur_tag == '1' )
	{
		return( TRUE );
	}

	/* on teste pas la valeur '0' */
	return( FALSE );

}


#endif  /* __FCM_GET_TAG_BOOLEEN_C__ */

