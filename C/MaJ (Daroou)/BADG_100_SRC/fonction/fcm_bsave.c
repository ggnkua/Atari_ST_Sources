/* **[Fonction Commune]********** */
/* *                            * */
/* * 02/06/2013 MaJ 17/03/2024  * */
/* ****************************** */



/*
 * Fonction GFA adapt‚ et am‚lior‚
 *
 */

int32 Fcm_bsave( char *nom_fichier, char *adresse, int32 nombre );



int32 Fcm_bsave( char *nom_fichier, char *adresse, int32 nombre )
{
	int32	handle_fichier;
	int32	nombre_sauver;
	int32	reponse = 0;


	FCM_LOG_PRINT3("* Fcm_bsave( {%s}, %p, %ld )", nom_fichier, adresse, nombre );


	/* Ouverture du fichier */
	handle_fichier = Fcreate( nom_fichier, 0);


	/* Si erreur on retourne l'erreur */
	if( handle_fichier < 0)
	{
		FCM_LOG_PRINT1("  ERREUR Fcm_bsave, handle=%ld", handle_fichier );
		FCM_CONSOLE_DEBUG1("  ERREUR Fcm_bsave, handle=%ld", handle_fichier );

		return(handle_fichier);
	}




	do
	{
		nombre_sauver = Fwrite( handle_fichier, nombre, adresse);

		FCM_LOG_PRINT1("Nombre_sauver=%ld", nombre_sauver );
//FCM_CONSOLE_DEBUG1("Nombre_sauver=%ld", nombre_sauver );


		adresse = adresse + nombre_sauver;
		nombre  = nombre  - nombre_sauver;
		reponse = reponse + nombre_sauver;

//FCM_CONSOLE_DEBUG1("nombre=%ld", nombre );

	} while(nombre);


	Fclose( handle_fichier );


	if( reponse > 0 )
	{
		FCM_LOG_PRINT1("* Fcm_bsave: %ld octets sauv‚s", reponse );
//FCM_CONSOLE_DEBUG1("* Fcm_bsave: %ld octets sauv‚s", reponse );
	}


	return(reponse);


}

