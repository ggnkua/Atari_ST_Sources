/* ***************************** */
/* *                           * */
/* * 08/08/2017 MaJ 08/08/2017 * */
/* ***************************** */




#include "../coeur/Fcm_cookie_definition.h"
#include "../include/ct60.h"


/* prototype */
void Fcm_libere_vram_ct60( uint32 adresse_vram );

#define MX_CT60_FREEVRAM (-1)


/* Fonction */
void Fcm_libere_vram_ct60( uint32 adresse_vram )
{
	#ifdef LOG_FILE
	int32 reponse;
	#endif
	

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# Fcm_libere_vram_ct60(%ld)"CRLF, adresse_vram );
	log_print(FALSE);
	#endif


	if( !Fcm_cookies_exist(COOKIE_CT60) )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "pas de cookie CT60 pr‚sent."CRLF );
		log_print(FALSE);
		#endif
		
		return;
	}


	#ifdef LOG_FILE
	sprintf( buf_log, " appel ct60_vmalloc(1, %ld)"CRLF, adresse_vram );
	log_print(FALSE);
	#endif

	#ifdef LOG_FILE
	reponse =
	#endif
	ct60_vmalloc(1, (int32)adresse_vram);


	#ifdef LOG_FILE
	sprintf( buf_log, " reponse= %ld"CRLF, reponse );
	log_print(FALSE);
	#endif


/*	if( reponse > 0 )
	{
		return (uint32)reponse;
	}*/


	return;

}

