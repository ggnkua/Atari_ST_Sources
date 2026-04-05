/* **[Fonction Commune]******** */
/* * Get Machine Info         * */
/* * 24/05/2003 - 08/01/2015  * */
/* **************************** */



#include "Fcm_Cookie_definition.h"
#include "Fcm_get_tos_version.c"




/* Prototype */
void Fcm_get_machine_info(void);


/* Fonction */
void Fcm_get_machine_info(void)
{


	#ifdef LOG_FILE
	sprintf( buf_log, "  ## Fcm_get_machine_info()"CRLF);
	log_print(FALSE);
	#endif


	systeme.magic_os=0;


	if( Fcm_cookies_exist(COOKIE_MagX) )
	{
		systeme.magic_os=TRUE;

		#ifdef LOG_FILE
		sprintf( buf_log, "  - MagiC d‚tect‚"CRLF );
		log_print(FALSE);
		#endif
	}


	systeme.mint_os=0;

	if( Fcm_cookies_exist(COOKIE_MiNT) )
	{
		systeme.mint_os=TRUE;

		#ifdef LOG_FILE
		sprintf( buf_log, "  - MiNT d‚tect‚"CRLF );
		log_print(FALSE);
		#endif
	}


	systeme.aes_multi=0;

	if( systeme.magic_os || systeme.mint_os )
	{
		systeme.aes_multi=TRUE;

		#ifdef LOG_FILE
		sprintf( buf_log, "  - Execution multi-tache"CRLF );
		log_print(FALSE);
		#endif
	}
	else
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "  - Execution Mono-tache ou OS inconnu (redraw desktop)"CRLF );
		log_print(FALSE);
		#endif

		form_dial( 3,0,0,0,0,screen.x_desktop,screen.y_desktop,screen.w_desktop,screen.h_desktop);
	}



	/* version de l'AES */
	systeme.aes_version=_AESversion;	/* definition dans GEM.H */

	#ifdef LOG_FILE
	sprintf( buf_log, "  - AES version=%x.%x ($%x)"CRLF, (systeme.aes_version>>8), (systeme.aes_version&0xff), systeme.aes_version );
	log_print(FALSE);
	#endif


	/* version du GEMDOS */
	{
		uint16	dummy;

		dummy=Sversion();
		systeme.gemdos_version=dummy>>8;
		systeme.gemdos_version=systeme.gemdos_version + (dummy<<8);
	}

	#ifdef LOG_FILE
	sprintf( buf_log, "  - GEMDOS version=0.%d"CRLF, systeme.gemdos_version);
	log_print(FALSE);
	#endif


	systeme.cpu_type=0;

	if( Fcm_cookies_exist(COOKIE__CPU) )
	{
		systeme.cpu_type=Fcm_get_cookies(COOKIE__CPU);
	}

	#ifdef LOG_FILE
	sprintf( buf_log, "  - CPU type=%d"CRLF, systeme.cpu_type+68000);
	log_print(FALSE);
	#endif


	systeme.tos_langage=2;

	if( Fcm_cookies_exist(COOKIE__AKP) )
	{
		systeme.tos_langage=(Fcm_get_cookies(COOKIE__AKP) >> 8) & 0xFF;
	}
	#ifdef LOG_FILE
	else
	{
		sprintf( buf_log, "  - Cookie _AKP absent "CRLF );
		log_print(FALSE);
	}
	#endif


	#ifdef LOG_FILE
	sprintf( buf_log, "  - TOS langage=%d"CRLF, systeme.tos_langage );
	log_print(FALSE);
	#endif


	/* Recherche TOS version */
	systeme.tos_version=Fcm_get_tos_version();

	#ifdef LOG_FILE
	sprintf( buf_log, "  - TOS version=%x"CRLF, systeme.tos_version );
	log_print(FALSE);
	#endif


	/* extension No_BLOCK presente ? */
	systeme.noblock=0;

	if( systeme.aes_version >= 0x399 )
	{
		int16 dummy,noblock,reponse;

		reponse=appl_getinfo(11,&dummy, &dummy, &dummy, &noblock);

		if(reponse==1)
		{
			systeme.noblock=noblock;
		}
	}

	#ifdef LOG_FILE
	sprintf( buf_log, "  - NO BLOCK extension=%d"CRLF""CRLF, systeme.noblock );
	log_print(FALSE);
	#endif


	return;


}

