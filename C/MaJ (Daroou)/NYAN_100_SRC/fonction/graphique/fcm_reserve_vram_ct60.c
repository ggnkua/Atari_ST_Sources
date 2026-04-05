/* ***************************** */
/* *                           * */
/* * 08/08/2017 MaJ 08/08/2017 * */
/* ***************************** */




#include "../coeur/Fcm_cookie_definition.h"
#include "../include/ct60.h"



/* prototype */
uint32 Fcm_reserve_vram_ct60( int32 taille_vram );

#define MX_CT60_FREEVRAM (-1)


/* Fonction */
uint32 Fcm_reserve_vram_ct60( int32 taille_vram )
{
	int32 reponse;
	
 /* tos drivers install le cookie 'VIDX' (init.c) */
 
	#ifdef LOG_FILE
	sprintf( buf_log, CRLF""TAB8"* Fcm_reserve_vram_ct60(%ld) MX_CT60_FREEVRAM(%d)"CRLF, taille_vram, MX_CT60_FREEVRAM );
	log_print(FALSE);
	#endif


	if( !Fcm_cookies_exist(COOKIE_CT60) )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, TAB8"pas de cookie CT60 pr‚sent."CRLF );
		log_print(FALSE);
		#endif
		
		return FALSE;
	}


	#ifdef LOG_FILE
	sprintf( buf_log, TAB8" appel ct60_vmalloc(0, %ld)"CRLF, taille_vram );
	log_print(FALSE);
	#endif

	reponse = ct60_vmalloc(0, taille_vram);

	#ifdef LOG_FILE
	sprintf( buf_log, TAB8" reponse= %ld"CRLF, reponse );
	log_print(FALSE);
	#endif


	if( reponse > 0 )
	{
		return (uint32)reponse;
	}


	/* erreur */
	return FALSE;

}

