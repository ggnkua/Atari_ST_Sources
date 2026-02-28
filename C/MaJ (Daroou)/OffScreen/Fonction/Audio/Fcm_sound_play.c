/**[Fonction commune]***************/
/* 07/10/2015 # 14/10/2015         */
/***********************************/



#ifndef ___Fcm_sound_play___
#define ___Fcm_sound_play___



/*#include "Coeur_define.c"*/
#include <FALCON.H>


#define FCM_SOUND_PLAY_XBIOS_FALCON_FAIL (-7001)
#define FCM_SOUND_PLAY_DMA_LOCKED        (-7002)




int32 fcm_sound_dma_buffer_start=0;
int32 fcm_sound_dma_buffer_end=0;

int16 *fcm_sound_son_buffer_start=NULL;
int16 *fcm_sound_son_buffer_end=NULL;
int16 *fcm_sound_position_son=NULL;

int16 fcm_sound_enable=FALSE;    /* Le son est disponible          */
int16 fcm_sound_active=FALSE;    /* le DMA est actif buffoper != 0 */
int16 fcm_sound_run   =FALSE;    /* un son est en cours de play    */



int16 Fcm_sound_init(uint16 frequence, uint16 rez_bit, uint16 stereo);
void  Fcm_sound_play(int32 start_buffer, int32 end_buffer);
void  Fcm_sound_update(void);
void  Fcm_sound_stop(void);
void  Fcm_sound_exit(void);



void  Fcm_sound_update(void)
{

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# Fcm_sound_update()"CRLF );
	log_print(FALSE);
	#endif


/*	{
		char   texte[256];
		int32  ptr[4];
		int32 reponse;

		reponse = Buffptr( &ptr );

		sprintf( texte, "reponse %ld : Buffptr: 0=%ld 1=%ld 2=%ld 3=%ld   ", reponse, ptr[0], ptr[1], ptr[2], ptr[3] );
		v_gtext( vdihandle, 58*8, 16*3, texte);
	}
*/


	if(fcm_sound_enable==FALSE)
	{
		#ifdef LOG_FILE
		sprintf( buf_log, CRLF"  Le son n'est pas actif"CRLF );
		log_print(FALSE);
		#endif

		return;
	}



	if( fcm_sound_active==TRUE )
	{
		uint16 idx;

			for( idx=0; idx<FCM_SOUND_PLAY_WRITEBUFFER_NB; idx++ )
			{
				if( fcm_sound_son_buffer_start < fcm_sound_son_buffer_end )
				{
					*fcm_sound_position_son++ = *fcm_sound_son_buffer_start++;
				}
				else
				{
					*fcm_sound_position_son++ = 0;
				}

				if( fcm_sound_position_son >= (int16 *)fcm_sound_dma_buffer_end )
				{
					fcm_sound_position_son = (int16 *)fcm_sound_dma_buffer_start;
				}


			}
	}


	return;


}






void  Fcm_sound_play(int32 start_buffer, int32 end_buffer)
{

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# Fcm_sound_play(%ld,%ld)"CRLF, start_buffer, end_buffer );
	log_print(FALSE);
	#endif



	if(fcm_sound_enable==FALSE)
	{
		#ifdef LOG_FILE
		sprintf( buf_log, CRLF"  Le son n'est pas actif"CRLF );
		log_print(FALSE);
		#endif

		return;
	}


	if( systeme.machine_type != 4 )
	{
		int32 reponse;


		#ifdef LOG_FILE
		sprintf( buf_log, CRLF"  Play son (machine != milan)"CRLF );
		log_print(FALSE);
		#endif

		Buffoper (0);

		reponse = Setbuffer ( SR_PLAY, start_buffer, end_buffer );

		if( reponse==0 )
		{
			Buffoper ( 1 );
		}


		return;
	}




	if( systeme.machine_type == 4 )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, CRLF"  Play son (machine == milan)"CRLF );
		log_print(FALSE);
		#endif


		/* On active le buffer DMA s'il est OFF */
		if( fcm_sound_active == FALSE )
		{
			int32 reponse;

			#ifdef LOG_FILE
			sprintf( buf_log, CRLF"  Activation du buffer DMA"CRLF );
			log_print(FALSE);
			#endif

			reponse = Setbuffer ( SR_PLAY, fcm_sound_dma_buffer_start, fcm_sound_dma_buffer_end );

			if( reponse==0 )
			{
				Buffoper(3);
				fcm_sound_active=TRUE;

				#ifdef LOG_FILE
				sprintf( buf_log, CRLF"  buffer DMA activ‚"CRLF );
				log_print(FALSE);
				#endif
			}
			else
			{
				#ifdef LOG_FILE
				sprintf( buf_log, CRLF"  Erreur activation DMA : reponse=%ld"CRLF, reponse );
				log_print(FALSE);
				#endif
			}
		}


		/* on ‚crit une partie du sample dans le buffer,   */
		/* le compl‚ment sera ‚crit par Fcm_sound_update() */
		{
			int32  ptr[4];
			int32  reponse;
/*			char   texte[256];*/
/*			uint16 idx;*/


			reponse = Buffptr( &ptr );

			if( reponse==0 )
			{

/*			sprintf( texte, "reponse %ld : Buffptr: 0=%ld 1=%ld 2=%ld 3=%ld   ", reponse, ptr[0], ptr[1], ptr[2], ptr[3] );
			v_gtext( vdihandle, 58*8, 16*3, texte);
*/
				fcm_sound_position_son     = (int16 *)(ptr[0]+1000);
				fcm_sound_son_buffer_start = (int16 *)start_buffer;
				fcm_sound_son_buffer_end   = (int16 *)end_buffer;

/*
			for( idx=0; idx<FCM_SOUND_PLAY_WRITEBUFFER_NB; idx++ )
			{
				if( fcm_sound_son_buffer_start < fcm_sound_son_buffer_end )
				{
					*fcm_sound_position_son++ = *fcm_sound_son_buffer_start++;
				}
				else
				{
					*fcm_sound_position_son++ = 0;
				}

				if( fcm_sound_position_son >= (int16 *)fcm_sound_dma_buffer_end )
				{
					fcm_sound_position_son = (int16 *)fcm_sound_dma_buffer_start;
				}

			}
*/
				Fcm_sound_update();

/*			{
				int32 old_ptr;

				old_ptr = ptr[0];
				reponse = Buffptr( &ptr );

				sprintf( texte, "reponse %ld : Buffptr: 0=%ld offset=%ld     ", reponse, ptr[0], ptr[0]-old_ptr );
				v_gtext( vdihandle, 58*8, 16*4, texte);
			}
*/
			}
			else
			{
				#ifdef LOG_FILE
				sprintf( buf_log, CRLF"  Buffprt Erreur, reponse = %ld"CRLF, reponse );
				log_print(FALSE);
				#endif
			}

		}




		return;

	}



	return;


}
























int16 Fcm_sound_init(uint16 frequence, uint16 rez_bit, uint16 stereo)
{

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# Fcm_sound_init(%d,%d,%d)"CRLF, frequence, rez_bit, stereo );
	log_print(FALSE);
	#endif


	if( systeme.xbios_sound != TRUE )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "  systeme Sonore non compatible Falcon !"CRLF );
		log_print(FALSE);
		#endif

		return(FCM_SOUND_PLAY_XBIOS_FALCON_FAIL);
	}



	fcm_sound_enable=FALSE;    /* Son DMA non disponible */
	fcm_sound_active=FALSE;    /* le DMA est OFF (buffoper(0) ) */



	/* Si c'est un Milan, on ouvre un buffer DMA */
	if( systeme.machine_type == 4 )
	{
		int32 buffer_dma_size;


		#ifdef LOG_FILE
		sprintf( buf_log, "  Milan d‚tect‚, cr‚ation d'un buffer DMA"CRLF );
		log_print(FALSE);
		#endif


/*		buffer_dma_size = frequence * (rez_bit/8) * time_buffer;
		buffer_dma_size = (buffer_dma_size / 256000);
		buffer_dma_size = (buffer_dma_size+1) * 256000;*/
		buffer_dma_size = FCM_SOUND_PLAY_DMA_BUFFER_SIZE;

/*		if( stereo == TRUE )
		{
			buffer_dma_size = buffer_dma_size * 2;
		}*/

		#ifdef LOG_FILE
		sprintf( buf_log, "  buffer_dma_size=%ld"CRLF, buffer_dma_size );
		log_print(FALSE);
		#endif


		fcm_sound_dma_buffer_start = Fcm_reserve_ram( (buffer_dma_size+256), MX_STRAM|MX_MPROT|MX_READABLE);

		fcm_sound_dma_buffer_end   = fcm_sound_dma_buffer_start + buffer_dma_size;



		memset( (void *)fcm_sound_dma_buffer_start, 0, buffer_dma_size );



/*		{
			int32 size;
			int32 idx;
			int32 *pt_dma_buf;

			size       = buffer_dma_size/4;
			pt_dma_buf = (int32 *)fcm_sound_dma_buffer_start;

			for( idx=0; idx<size; idx++)
			{
				*pt_dma_buf++=0;
			}


		}*/


	}




	#ifdef LOG_FILE
	sprintf( buf_log, "  Verouillage DMA"CRLF );
	log_print(FALSE);
	#endif

	/* on verouille le son pour notre appli, s'il n'et pas d‚j… utilis‚ */
	/* ---------------------------------------------------------------- */
	if( Locksnd() != 1 )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "  SystŠme sonore v‚rouill‚ par une autre application"CRLF );
		log_print(FALSE);
		#endif

		Fcm_sound_exit();

		return(FCM_SOUND_PLAY_DMA_LOCKED);
	}



	fcm_sound_enable=TRUE;     /* Son DMA disponible */



	#ifdef LOG_FILE
	sprintf( buf_log, "  Configuration du DMA"CRLF );
	log_print(FALSE);
	#endif

	/* Configuration du DMA */
	Sndstatus( SND_RESET );


	if( systeme.xbios_sound_mode==XBIOS_SOUND_MODE_STE_TT )
	{
		Devconnect( DMAPLAY, DAC, CLK25M, CLKOLD, 1);

		switch( frequence)
		{
			case 6250:
				Soundcmd( SETPRESCALE, 0);
				break;
			case 12500:
				Soundcmd( SETPRESCALE, 1);
				break;
			case 22500:
			case 25000:
				Soundcmd( SETPRESCALE, 2);
				break;
			case 50000:
				Soundcmd( SETPRESCALE, 3);
				break;

			default:
				Soundcmd( SETPRESCALE, 2);
		}
	}
	else
	{
		switch( frequence)
		{
			case 6250:
				Devconnect( DMAPLAY, DAC, CLK25M, CLK8K, 1);
				break;
			case 12500:
				Devconnect( DMAPLAY, DAC, CLK25M, CLK12K, 1);
				break;

			case 22500:
			case 25000:
				Devconnect( DMAPLAY, DAC, CLK25M, CLK25K, 1);
				break;

			case 50000:
				Devconnect( DMAPLAY, DAC, CLK25M, CLK50K, 1);
				break;

			default:
				Devconnect( DMAPLAY, DAC, CLK25M, CLK25K, 1);
		}
	}

	Soundcmd( LTATTEN, 0);
	Soundcmd( RTATTEN, 0);


	if( stereo != 0 )
	{
		switch( rez_bit )
		{
			case 8:
				Setmode( STEREO8  );
				break;
			case 16:
				Setmode( STEREO16 );
				break;

			default:
				Setmode( STEREO8 );
		}
	}
	else
	{
		Setmode( MONO8 );
	}



	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"  ---------------------------- End Fcm_sound_init()"CRLF );
	log_print(FALSE);
	#endif


	return(0);


}




















void  Fcm_sound_exit(void)
{

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# Fcm_sound_exit()"CRLF );
	log_print(FALSE);
	#endif


	if( fcm_sound_enable==TRUE )
	{
		#ifdef LOG_FILE
		sprintf( buf_log, CRLF"  D‚v‚rouillage son DMA"CRLF );
		log_print(FALSE);
		#endif

		Buffoper(0);
		Unlocksnd();
	}

	fcm_sound_enable=FALSE;

	if( fcm_sound_dma_buffer_start > 0 )
	{
		Fcm_libere_ram(fcm_sound_dma_buffer_start);

		fcm_sound_dma_buffer_start=0;
	}


	#ifdef LOG_FILE
	sprintf( buf_log, "# --------------------- > end Fcm_sound_exit()"CRLF );
	log_print(FALSE);
	#endif


	return;
}



#endif   /* ___Fcm_sound_play___ */
