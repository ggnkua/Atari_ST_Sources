/* ***************************** */
/* *                           * */
/* * 08/08/2017 MaJ 08/08/2017 * */
/* ***************************** */




#include "../coeur/Fcm_cookie_definition.h"



/* prototype */
uint32 Fcm_reserve_vram_milan( int32 taille_vram );

/*#define MX_CT60_FREEVRAM (-1)*/


/* Fonction */
uint32 Fcm_reserve_vram_milan( int32 taille_vram )
{
/*	int32 reponse;*/
	
	UNUSED(taille_vram);


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF""TAB8"* Fcm_reserve_vram_milan(%ld)"CRLF, taille_vram );
	log_print(FALSE);
	#endif

/*
	if( !Fcm_cookies_exist(COOKIE_CT60) )
	{*/
		#ifdef LOG_FILE
		sprintf( buf_log, TAB8"routine a coder !!!"CRLF );
		log_print(FALSE);
		#endif


/*		
		return FALSE;
	}


	#ifdef LOG_FILE
	sprintf( buf_log, " appel ct60_vmalloc(0, %ld)"CRLF, taille_vram );
	log_print(FALSE);
	#endif

	reponse = ct60_vmalloc(0, taille_vram);

	#ifdef LOG_FILE
	sprintf( buf_log, " reponse= %ld"CRLF, reponse );
	log_print(FALSE);
	#endif


	if( reponse > 0 )
	{
		return (uint32)reponse;
	}

*/


	/* erreur */
	return FALSE;

}

