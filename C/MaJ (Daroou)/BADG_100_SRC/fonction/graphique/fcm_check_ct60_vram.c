/* ***************************** */
/* *                           * */
/* * 31/01/2016 MaJ 07/02/2016 * */
/* ***************************** */




#include "../coeur/Fcm_cookie_definition.h"
#include "../PCI/PCIXBIOS.H"


/* ce n'est pas une fonction specifique a offscreen ? */

/* prototype */
int32 Fcm_check_ct60_vram( int32 *vram_free );




/* Fonction */
int32 Fcm_check_ct60_vram( int32 *vram_free )
{


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# Fcm_check_ct60_vram()"CRLF );
	log_print(FALSE);
	sprintf( buf_log, CRLF"  Recherche cookie:"CRLF );
	log_print(FALSE);
	#endif


	{
		int16 cookie_ct60=FALSE;
		int16 cookie_pci =FALSE;
		int16 cookie_supv=FALSE;
		int16 ati_present=FALSE;


		#ifdef LOG_FILE
		sprintf( buf_log, CRLF" Cookie CT60 ($%lx) ", COOKIE_CT60 );
		log_print(FALSE);
		#endif

		if( Fcm_cookies_exist(COOKIE_CT60) )
		{
			cookie_ct60=TRUE;

			#ifdef LOG_FILE
			sprintf( buf_log, "pr‚sent." );
			log_print(FALSE);
			#endif
		}
		else
		{
			#ifdef LOG_FILE
			sprintf( buf_log, "absent." );
			log_print(FALSE);
			#endif
		}





		#ifdef LOG_FILE
		sprintf( buf_log, CRLF" Cookie _PCI ($%lx) ", COOKIE__PCI );
		log_print(FALSE);
		#endif

		if( Fcm_cookies_exist(COOKIE__PCI) )
		{
			cookie_pci=TRUE;

			#ifdef LOG_FILE
			sprintf( buf_log, "pr‚sent." );
			log_print(FALSE);
			#endif
		}
		else
		{
			#ifdef LOG_FILE
			sprintf( buf_log, "absent." );
			log_print(FALSE);
			#endif
		}






		#ifdef LOG_FILE
		sprintf( buf_log, CRLF" Cookie SupV ($%lx) ", COOKIE_SupV );
		log_print(FALSE);
		#endif

		if( Fcm_cookies_exist(COOKIE_SupV) )
		{
			cookie_supv=TRUE;

			#ifdef LOG_FILE
			sprintf( buf_log, "pr‚sent." );
			log_print(FALSE);
			#endif
		}
		else
		{
			#ifdef LOG_FILE
			sprintf( buf_log, "absent." );
			log_print(FALSE);
			#endif
		}




		if( (cookie_ct60==TRUE && cookie_pci==TRUE) || Fcm_cookies_exist(COOKIE_XPCI) )
		{
			/* recherche carte graphique ATI  */

			#define MAX_PCI_SLOT_SCAN  (20)
			int32  handle;
			int32  reponse;
			uint32 data;
			int16  index_id=0;

			#ifdef LOG_FILE
			sprintf( buf_log, CRLF"Recherche carte ATI:"CRLF );
			log_print(FALSE);
			#endif

			do
			{
				handle=find_pci_device( 0x0000ffff, index_id );

				#ifdef LOG_FILE
				sprintf( buf_log, "index %d : handle=%lx", index_id, handle );
				log_print(FALSE);
				#endif

				if( handle==PCI_DEVICE_NOT_FOUND )
				{
					#ifdef LOG_FILE
					sprintf( buf_log, " plus de carte"CRLF );
					log_print(FALSE);
					#endif

					break;
				}

				reponse=read_config_longword( handle, PCIIDR, &data );

				if( reponse!=PCI_FUNC_NOT_SUPPORTED )
				{

					#ifdef LOG_FILE
					sprintf( buf_log, " Vendor ID=%04X  Device ID=%04X"CRLF, (uint16)(data & 0xFFFF), (uint16)(data>>16) );
					log_print(FALSE);
					#endif

					if( (uint16)(data & 0xFFFF)==0x1002 )
					{
						ati_present=TRUE;

						#ifdef LOG_FILE
						sprintf( buf_log, " ----> Carte ATI"CRLF );
						log_print(FALSE);
						#endif
					}
				}

				index_id++;

			} while( handle!=PCI_DEVICE_NOT_FOUND && index_id<MAX_PCI_SLOT_SCAN );

			#undef MAX_PCI_SLOT_SCAN
		}








		if(	cookie_ct60==TRUE && (cookie_supv==TRUE || ati_present==TRUE) )
		{
			#ifdef LOG_FILE
			sprintf( buf_log, CRLF" ct60_vmalloc normalement pr‚sent"CRLF );
			log_print(FALSE);
			sprintf( buf_log, " Test Free CT060 Vram"CRLF );
			log_print(FALSE);
			#endif

			*vram_free = ct60_vmalloc(0,-1);

			#ifdef LOG_FILE
			sprintf( buf_log, " reponse= %ld octets free VRAM "CRLF, *vram_free );
			log_print(FALSE);
			#endif

			return(0);

		}

	}


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF" ct60_vmalloc non support‚"CRLF );
	log_print(FALSE);
	#endif


	return(-1);


}

