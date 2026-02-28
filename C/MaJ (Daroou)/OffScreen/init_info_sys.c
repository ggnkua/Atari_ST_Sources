/* **[Offscreen]**************** */
/* *                           * */
/* * 02/02/2016 MaJ 07/02/2016 * */
/* ***************************** */




#ifndef ___init_info_sys___
#define ___init_info_sys___




/* prototype */
void init_info_sys( void );




/* Fonction */
void init_info_sys( void )
{


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# init_info_sys()"CRLF );
	log_print( FALSE );
	#endif




	if( Fcm_cookies_exist(COOKIE_EdDI) )
	{
		sprintf(info_eddi, "%x.%02x",  (Fcm_screen.eddi_version>>8)&0xff,  (Fcm_screen.eddi_version&0xff) );
	}
	else
	{
		strcpy(info_eddi, "----");
	}

	#ifdef LOG_FILE
	sprintf( buf_log, "  EdDI : %s"CRLF, info_eddi );
	log_print( FALSE );
	#endif




	if( Fcm_cookies_exist(COOKIE_NVDI) )
	{
		NVDI_STRUCT *pt_cookie_nvdi;

		pt_cookie_nvdi = (NVDI_STRUCT *)Fcm_get_cookies(COOKIE_NVDI);

		sprintf(info_nvdi, "%x.%02x", (pt_cookie_nvdi->nvdi_version>>8)&0xff, (pt_cookie_nvdi->nvdi_version&0xff) );
	}
	else
	{
		strcpy(info_nvdi, "----");
	}

	#ifdef LOG_FILE
	sprintf( buf_log, "  NVDI : %s"CRLF, info_nvdi );
	log_print( FALSE );
	#endif




	if( Fcm_cookies_exist(COOKIE__PCI) )
	{
		PCI_COOKIE *pt_cookie_pci;

		pt_cookie_pci = (PCI_COOKIE *)Fcm_get_cookies(COOKIE__PCI);

		sprintf(info_pci, "%x.%02x", (uint16)((pt_cookie_pci->version>>16)&0xffff), (uint16)(pt_cookie_pci->version&0xffff) );
	}
	else
	{
		strcpy(info_pci, "----");
	}

	#ifdef LOG_FILE
	sprintf( buf_log, "  _PCI : %s"CRLF, info_pci );
	log_print( FALSE );
	#endif




	if( Fcm_cookies_exist(COOKIE_SupV) )
	{
		sprintf(info_supv, "$%08lx", Fcm_get_cookies(COOKIE_SupV) );
	}
	else
	{
		strcpy(info_supv, "----");
	}

	#ifdef LOG_FILE
	sprintf( buf_log, "  SupV : %s"CRLF, info_supv );
	log_print( FALSE );
	#endif




	if( Fcm_cookies_exist(COOKIE_CT60) )
	{
		sprintf(info_ct60, "$%08lx", Fcm_get_cookies(COOKIE_CT60) );
	}
	else
	{
		strcpy(info_ct60, "----");
	}

	#ifdef LOG_FILE
	sprintf( buf_log, "  info_ct60 : %s"CRLF, info_ct60 );
	log_print( FALSE );
	#endif




	sprintf(info_rez, "%dx%d %db", Fcm_screen.width, Fcm_screen.height, Fcm_screen.nb_plan );

	#ifdef LOG_FILE
	sprintf( buf_log, "  info_rez : %s"CRLF, info_rez );
	log_print( FALSE );
	#endif




	if( gb_mode_ct60_vram_actif==TRUE )
	{
		if( gb_vram_free > 99999999 )
		{
			sprintf(info_vram_free, "Free: %ld Mo", gb_vram_free/1024/1024 );
		}
		else if( gb_vram_free > 99999 )
		{
			sprintf(info_vram_free, "Free: %ld Ko", gb_vram_free/1024 );
		}
		else
		{
			sprintf(info_vram_free, "Free: %ld", gb_vram_free );
		}
	}
	else
	{
		sprintf(info_vram_free, "Free: ----" );
	}

	#ifdef LOG_FILE
	sprintf( buf_log, "  info_vram_free : %s"CRLF, info_vram_free );
	log_print( FALSE );
	#endif





















		sprintf(info_ati_device, " ----  ----" );

		if( (Fcm_cookies_exist(COOKIE_CT60) && Fcm_cookies_exist(COOKIE__PCI)) || Fcm_cookies_exist(COOKIE_XPCI) )
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
						sprintf(info_ati_device, "$%4x $%4x", (uint16)(data & 0xFFFF), (uint16)(data>>16) );

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




	return;


}


#endif   /* ___init_info_sys___ */

