/* **[Fonction Commune]******* */
/* *                         * */
/* * 02/01/2013  06/04/2013  * */
/* *************************** */



#ifndef ___Fcm_gestion_fermeture_programme___
#define ___Fcm_gestion_fermeture_programme___




/* Prototype */
VOID Fcm_gestion_fermeture_programme( VOID );


/* Fonction */
VOID Fcm_gestion_fermeture_programme( VOID )
{

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# Fcm_gestion_fermeture_programme()"CRLF);
	log_print( FALSE );
	#endif

	/* A voir s'il faut sauter … une fonction en cas d'arret     */
	/* du programme, afin de v‚rifi‚ s'il y a des document …     */
    /* sauver ou demander une confirmation.                      */
    /* Pour l'instant l'utilit‚ n'est pas pr‚sente               */
	/* On met fin au programme simplement                        */


	buffer_aes[0]=AP_TERM;
	buffer_aes[1]=ap_id;
	buffer_aes[2]=0;
	buffer_aes[3]=0;
	appl_write( ap_id, 16, &buffer_aes );


	return;


}


#endif   /* ___Fcm_gestion_fermeture_programme___ */


