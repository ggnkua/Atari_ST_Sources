/* **[Fonction commune]******* */
/* * File Exist              * */
/* * 10/04/2003 = 09/01/2015 * */
/* *************************** */


#ifndef __Fcm_file_exist__
#define __Fcm_file_exist__



/* Prototype */
int16 Fcm_file_exist( const char *nom_fichier);


/* Fonction */
int16 Fcm_file_exist( const char *nom_fichier)
{

	int32	handle_fichier;



	/* On tente d'ouvrir le fichier */
	handle_fichier = Fopen(nom_fichier, 0);


	/* Erreur ? */
	if( handle_fichier<0 )
	{
		/* On retourne le code d'erreur */
		return(handle_fichier);
	}


	/* Le fichier existe, on le ferme */
	Fclose(handle_fichier);


	return(TRUE);


}


#endif

