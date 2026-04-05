/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 20/02/2024 MaJ 03/03/2024 * */
/* ***************************** */



/*
 * cette fonction sert a chercher les tag de config qui ont une
 * valeur numerique, positive ou negative.
 *
 */


#ifndef __FCM_GET_TAG_INT32_C__
#define __FCM_GET_TAG_INT32_C__


int32 Fcm_get_tag_int32( const char *tag, const char *pt_fichier_config )
{

#define SIZE_BUFFER_INT32  (16)

	char   buffer_int32[SIZE_BUFFER_INT32]; /* 11 char pour int32 negatif */
	char  *pt_position;
	int32  valeur_tag = 0;


/*FCM_LOG_PRINT2( CRLF"  Fcm_get_tag_int32(%s,%p)", tag, pt_fichier_config );*/

	/* on recherche le TAG dans le buffer de config */
	pt_position = strstr( pt_fichier_config, tag );

	if( pt_position == NULL )
	{
		/* Le TAG n'a pas ‚t‚ trouv‚ */
		FCM_CONSOLE_ADD2("Config: TAG %s absent", tag, G_WHITE);
		return(0);
	}

	/* on se positionne aprŠs le TAG */
	pt_position = pt_position + strlen( tag );

	{
		uint16 nb_car = 0;


		while( pt_position[nb_car] != 13   &&   pt_position[nb_car] != 0   &&   nb_car < (SIZE_BUFFER_INT32 - 1) )
		{
			buffer_int32[nb_car] = pt_position[nb_car];
			nb_car++;
		}

		buffer_int32[nb_car] = 0;


		if( strlen(buffer_int32) < 12 )
		{
			valeur_tag = atol( buffer_int32 );
		}
	}


	return(valeur_tag);


}


#endif  /* __FCM_GET_TAG_INT32_C__ */

