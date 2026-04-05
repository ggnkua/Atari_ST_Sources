/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 02/01/2013 MaJ 05/03/2024 * */
/* ***************************** */



#ifndef ___FCM_GESTION_FERMETURE_PROGRAMME_C___
#define ___FCM_GESTION_FERMETURE_PROGRAMME_C___


void Fcm_gestion_fermeture_programme( void )
{

	FCM_LOG_PRINT(CRLF"# Fcm_gestion_fermeture_programme()");

	/* A voir s'il faut sauter … une fonction en cas d'arret     */
	/* du programme, afin de v‚rifi‚ s'il y a des document …     */
    /* sauver ou demander une confirmation.                      */
    /* Pour l'instant l'utilit‚ n'est pas pr‚sente               */
	/* On met fin au programme simplement                        */


	buffer_aes[0] = AP_TERM;
	buffer_aes[1] = ap_id;
	buffer_aes[2] = 0;
	buffer_aes[3] = 0;
	appl_write( ap_id, 16, &buffer_aes );


	return;


}


#endif   /* ___FCM_GESTION_FERMETURE_PROGRAMME_C___ */

