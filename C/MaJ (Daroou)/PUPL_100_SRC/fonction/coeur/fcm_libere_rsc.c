/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 09/08/2003 MaJ 03/03/2024 * */
/* ***************************** */



#ifndef ___FCM_LIBERE_RSC_C___
#define ___FCM_LIBERE_RSC_C___


void Fcm_libere_RSC( void )
{

	FCM_LOG_PRINT("# Fcm_libere_RSC()");


	rsrc_free();  /* Standard AES fonction */


	FCM_LOG_PRINT("  - Lib‚ration Ressource termin‚");


	return;


}


#endif  /* ___FCM_LIBERE_RSC_C___ */

