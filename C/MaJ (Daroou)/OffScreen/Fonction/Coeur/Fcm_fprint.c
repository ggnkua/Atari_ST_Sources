/* **************************** */
/* * Fonction Fprint          * */
/* * 30/11/2001 :: 06/04/2013 * */
/* **************************** */



#ifndef __Fcm_fprint__
#define __Fcm_fprint__




#define FPRINT_TAILLE_TAMPON 256


/* Prototype */
WORD Fcm_fprint ( const WORD handle, const CHAR *buffer );


/* Fonction */
WORD Fcm_fprint ( const WORD handle, const CHAR *buffer )
{
	CHAR	tampon[FPRINT_TAILLE_TAMPON];


	/* On v‚rifie que la chaine ne soit pas trop longue */
	/* -2 pour le CR/LF                                 */
	if( strlen(buffer) < (FPRINT_TAILLE_TAMPON-2) )
	{
		sprintf( tampon, "%s"CRLF, buffer);


		return( Fwrite(handle, strlen(tampon) , &tampon) );
	}


	#ifdef LOG_FILE
	sprintf( buf_log, "# ERREUR - Fcm_fprint: chaine trop longue pour le tampon (%ld > %d)"CRLF,  strlen(buffer), FPRINT_TAILLE_TAMPON);
	log_print( FALSE );
	#endif

	/* La chaine est trop longue pour le tampon */
	/* on ne fait rien                          */
	return(0);


}


#endif

