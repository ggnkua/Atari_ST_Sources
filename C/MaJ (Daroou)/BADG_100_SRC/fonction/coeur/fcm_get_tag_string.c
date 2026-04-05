/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 20/02/2024 MaJ 03/03/2024 * */
/* ***************************** */



/*
 *
 * cette fonction sert a chercher les tag de config qui ont pour
 * valeur une chaine de caractere .
 * Par defaut, en cas d'erreur, une chaine vide est transmise
 *
 */


#ifndef __FCM_GET_TAG_STRING_C__
#define __FCM_GET_TAG_STRING_C__


void Fcm_get_tag_string(const char *tag, const char *pt_fichier_config, char *string_dest, uint16 string_dest_size )
{
	char  *pt_position;


/*FCM_LOG_PRINT4( CRLF"* Fcm_get_tag_string(%s,%p,{%s}, %d)"CRLF, tag, pt_fichier_config, string_dest, string_dest_size);*/

	/* on vide la chaine par defaut */
	string_dest[0] = 0;

	if( strlen(tag) == 0 )
	{
		FCM_CONSOLE_DEBUG("Fcm_get_tag_string(): TAG vide");
		return;
	}

	/* on recherche le TAG dans le buffer de config */
	pt_position = strstr( pt_fichier_config, tag );

	if( pt_position == NULL )
	{
		/* Le TAG n'a pas ‚t‚ trouv‚ */
		FCM_CONSOLE_ADD2("Config: TAG %s absent", tag, G_WHITE);
		return;
	}

	/* on se positionne aprŠs le TAG */
	pt_position = pt_position + strlen( tag );

	/* on copie la chaine */
	{
		uint16 nb_car = 0;


		while( pt_position[nb_car] != 13   &&   pt_position[nb_car] != 0   &&   nb_car < (string_dest_size - 1) )
		{
			string_dest[nb_car] = pt_position[nb_car];
			nb_car++;
		}

		string_dest[nb_car] = 0;

		if( nb_car == (string_dest_size - 1) )
		{
			FCM_CONSOLE_DEBUG1("Fcm_get_tag_string: TAG %s chemin trop long", tag);
		}
	}


	return;

}


#endif  /* __FCM_GET_TAG_STRING_C__ */

