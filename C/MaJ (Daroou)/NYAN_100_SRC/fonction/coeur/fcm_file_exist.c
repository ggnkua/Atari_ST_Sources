/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 10/04/2003 MaJ 05/03/2024 * */
/* ***************************** */



#ifndef __FCM_FILE_EXIST_C__
#define __FCM_FILE_EXIST_C__


int16 Fcm_file_exist( const char *nom_fichier )
{
	int32 handle_fichier;


	/* On tente d'ouvrir le fichier */
	handle_fichier = Fopen( nom_fichier, 0 );

	/* Erreur ? */
	if( handle_fichier < 0 )
	{
		/* On retourne le code d'erreur */
		return( handle_fichier );
	}

	/* Le fichier existe, on le ferme */
	Fclose( handle_fichier );


	return(TRUE);


}


#endif   /*   __FCM_FILE_EXIST_C__   */

