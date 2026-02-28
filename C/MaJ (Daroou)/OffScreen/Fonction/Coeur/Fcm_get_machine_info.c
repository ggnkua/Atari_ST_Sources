/* **[Fonction Commune]******** */
/* * Get Machine Info         * */
/* * 24/05/2003 - 08/01/2015  * */
/* **************************** */


#include <LDG.H>
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
	systeme.machine_type=-1;


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
		sprintf( buf_log, "  - Execution Mono-tache (ou OS multi-tache inconnu) => redraw desktop"CRLF );
		log_print(FALSE);
		#endif

		form_dial( 3,0,0,0,0,Fcm_screen.x_desktop,Fcm_screen.y_desktop,Fcm_screen.w_desktop,Fcm_screen.h_desktop);
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
	sprintf( buf_log, "  - CPU type=%ld"CRLF, (int32)systeme.cpu_type+68000);
	log_print(FALSE);
	#endif


	systeme.tos_langage=2;

	if( Fcm_cookies_exist(COOKIE__AKP) )
	{
		systeme.tos_langage=(Fcm_get_cookies(COOKIE__AKP) >> 8) & 0xFF;

		#ifdef LOG_FILE
		sprintf( buf_log, "  - cookie _AKP >> 8  = %d"CRLF, systeme.tos_langage );
		log_print(FALSE);
		#endif
	}
	#ifdef LOG_FILE
	else
	{
		sprintf( buf_log, "  - Cookie _AKP absent "CRLF );
		log_print(FALSE);
	}
	#endif

	if( systeme.aes_version >= 399 )
	{
		int16 tos_langage, dummy,reponse;

		reponse=appl_getinfo( 3, &tos_langage, &dummy, &dummy, &dummy );

		if( reponse == 1 )
		{
			systeme.tos_langage = tos_langage;

			#ifdef LOG_FILE
			sprintf( buf_log, "  - apple_getinfo( AES_LANGUAGE) => %d"CRLF, tos_langage );
			log_print(FALSE);
			#endif

		}
		#ifdef LOG_FILE
		else
		{
			sprintf( buf_log, "  - apple_getinfo( AES_LANGUAGE) error"CRLF );
			log_print(FALSE);
		}
		#endif
	}





	#ifdef LOG_FILE
	sprintf( buf_log, "    -> TOS langage=%d (0=USA 1=Germany 2=France 3=England  etc...)"CRLF, systeme.tos_langage );
	log_print(FALSE);
	#endif


	/* Recherche TOS version */
	systeme.tos_version=Fcm_get_tos_version();

	#ifdef LOG_FILE
	sprintf( buf_log, "  - TOS version=%x.%02x ($%x)"CRLF, systeme.tos_version>>8, systeme.tos_version&0xff, systeme.tos_version );
	log_print(FALSE);
	#endif





	#ifdef LOG_FILE
	{
		uint16 gemdos_version;
		int16  dummy;

		dummy=Sversion();
		gemdos_version=dummy>>8;
		gemdos_version=gemdos_version + (dummy<<8);


		if( gemdos_version >= 0x19 )
		{
			/* Si Mxalloc() est support‚... */
			sprintf( buf_log, "  - ST RAM free : %ld (Mxalloc)"CRLF, Mxalloc(-1, MX_STRAM) );
			log_print(FALSE);
			sprintf( buf_log, "  - TT RAM free : %ld (Mxalloc)"CRLF, Mxalloc(-1, MX_TTRAM) );
			log_print(FALSE);
		}
		sprintf( buf_log, "  -    RAM free : %ld (Malloc)"CRLF, Malloc(-1) );
		log_print(FALSE);
	}
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
	sprintf( buf_log, "  - AES NO BLOCK extension=%d"CRLF, systeme.noblock );
	log_print(FALSE);
	#endif





	systeme.xbios_sound=FALSE;
	systeme.xbios_sound_mode=0;


	if( Fcm_cookies_exist(COOKIE__MCH) )
	{
/*		int32 data;*/

		systeme.machine_type = (int16)(Fcm_get_cookies(COOKIE__MCH) >> 16);

#ifdef LOG_FILE
sprintf( buf_log, "  - machine type (contenu cookie _MCH >> 16) = $%04x"CRLF, systeme.machine_type );
log_print(FALSE);
#endif

		if( systeme.machine_type==0x3 )
		{
			systeme.xbios_sound=TRUE;
			systeme.xbios_sound_mode=XBIOS_SOUND_MODE_FALCON;

#ifdef LOG_FILE
sprintf( buf_log, "  - Falcon d‚tect‚"CRLF );
log_print(FALSE);
#endif
		}

		if( systeme.machine_type==0x5 )
		{
			systeme.xbios_sound=TRUE;
			systeme.xbios_sound_mode=XBIOS_SOUND_MODE_FALCON;


#ifdef LOG_FILE
sprintf( buf_log, "  - ARAnyM d‚tect‚"CRLF );
log_print(FALSE);
#endif
		}
	}























	if( Fcm_cookies_exist(COOKIE_McSn) )
	{
		systeme.xbios_sound=TRUE;
		systeme.xbios_sound_mode=XBIOS_SOUND_MODE_FALCON;

#ifdef LOG_FILE
sprintf( buf_log, "  - Cookie McSn pr‚sent"CRLF );
log_print(FALSE);
#endif

	}



	if( Fcm_cookies_exist(COOKIE__SND) )
	{
		uint32 data;

		data = Fcm_get_cookies(COOKIE__SND);

#ifdef LOG_FILE
sprintf( buf_log, "  - Contenu cookie _SND = $%08lx"CRLF, data );
log_print(FALSE);
#endif

		if( data & 0x20 )
		{
			systeme.xbios_sound=TRUE;
			systeme.xbios_sound_mode=XBIOS_SOUND_MODE_FALCON;


#ifdef LOG_FILE
sprintf( buf_log, "    -> Extended XBIOS routines pr‚sent"CRLF );
log_print(FALSE);
#endif
		}



		if( (data & 0x2) && Fcm_cookies_exist(COOKIE_STFA) )
		{
			systeme.xbios_sound=TRUE;
			systeme.xbios_sound_mode=XBIOS_SOUND_MODE_STE_TT;

#ifdef LOG_FILE
sprintf( buf_log, "  - Cookie STFA pr‚sent with DMA sound (STE/TT)"CRLF );
log_print(FALSE);
#endif

		}



	}
	else
	{

#ifdef LOG_FILE
sprintf( buf_log, "  - Cookie _SND Absent"CRLF );
log_print(FALSE);
#endif

	}


	if( systeme.xbios_sound==TRUE )
	{
#ifdef LOG_FILE
sprintf( buf_log, "    -> XBIOS Falcon sound compatible"CRLF );
log_print(FALSE);
#endif
	}

	if( systeme.xbios_sound_mode==XBIOS_SOUND_MODE_STE_TT )
	{
#ifdef LOG_FILE
sprintf( buf_log, "    -> XBIOS sound mode STE/TT compatible"CRLF );
log_print(FALSE);
#endif
	}
	else
	{
#ifdef LOG_FILE
sprintf( buf_log, "    -> XBIOS sound mode Falcon compatible"CRLF );
log_print(FALSE);
#endif
	}










	if( Fcm_cookies_exist(COOKIE_LDGM) )
	{
		LDG_INFOS *cookie_ldg;

		cookie_ldg = (LDG_INFOS *)Fcm_get_cookies(COOKIE_LDGM);

		systeme.tsr_ldg_version=cookie_ldg->version;

#ifdef LOG_FILE
sprintf( buf_log, "  - TSR LDG pr‚sent:"CRLF );
log_print(FALSE);
sprintf( buf_log, "    -> version $%x"CRLF, cookie_ldg->version );
log_print(FALSE);
sprintf( buf_log, "    -> chemin LDG {%s}"CRLF, cookie_ldg->path );
log_print(FALSE);
#endif

	}
	else
	{
#ifdef LOG_FILE
sprintf( buf_log, "  - TSR LDG non install‚"CRLF );
log_print(FALSE);
#endif
	}











#ifdef LOG_FILE
sprintf( buf_log, ""CRLF );
log_print(FALSE);
#endif


	return;


}

