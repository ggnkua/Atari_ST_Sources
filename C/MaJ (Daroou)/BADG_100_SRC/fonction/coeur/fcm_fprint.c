/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 30/11/2001 MaJ 06/03/2024 * */
/* ***************************** */



#ifndef __FCM_FPRINT_C__
#define __FCM_FPRINT_C__


#define FPRINT_TAILLE_TAMPON  (256)


int16 Fcm_fprint ( const int16 handle, const char *buffer )
{
	int32 reponse;
	char  tampon[ FPRINT_TAILLE_TAMPON ];


	/*
	 * obliger de passer par un tampon pour ajouter le CRLF
	 *
	 * On v‚rifie que la chaine ne soit pas trop longue
	 * -3 pour CR + LF + '\0'
	 *
	 */
	if( strlen(buffer) < (FPRINT_TAILLE_TAMPON - 3) )
	{
		snprintf( tampon, sizeof(tampon), "%s"CRLF, buffer);

		reponse = Fwrite( handle, strlen(tampon) , &tampon );

		if( reponse < 0 )
		{
			FCM_CONSOLE_DEBUG1("Fcm_fprint() : erreur ecriture reponse=%ld", reponse);
		}

		return( reponse );
	}

	FCM_CONSOLE_DEBUG("Fcm_fprint() : buffer trop court");
	FCM_LOG_PRINT2("ERREUR - Fcm_fprint: chaine trop longue pour le tampon (%ld > %d)", strlen(buffer), FPRINT_TAILLE_TAMPON);

	return(0);


}


#endif   /*   __FCM_FPRINT_C__   */

