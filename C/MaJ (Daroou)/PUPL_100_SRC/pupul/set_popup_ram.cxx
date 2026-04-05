/* **[pupul]******************** */
/* *                           * */
/* * 04/10/2014 MaJ 26/05/2018 * */
/* ***************************** */


void set_popup_ram( void );




/* Fonction */
void set_popup_ram( void )
{



	#ifdef LOG_FILE
	sprintf( buf_log, " * set_popup_ram()"CRLF );
	log_print( FALSE );
	#endif



	/* ---------------------------- */
	/* Label popup Type RAM         */
	/* ---------------------------- */
	{
		OBJECT	*adr_popup;

		/* Adresse du pop up */
		rsrc_gaddr( R_TREE, POPUP_RAM, &adr_popup );
		Fcm_set_rsc_string( DL_OPTIONS, RAM_POPUP_RAM, adr_popup[Fcmgfx_CreateSurface_ram_type_select].ob_spec.tedinfo->te_ptext );
	}



	/* ******************************************************* */
	/* * POP UP RAM                                          * */
	/* ******************************************************* */
	/* on desactive les menu du popup qui sont indisponible */
	{
		OBJECT	*dial_popup;

		/* Adresse du pop up */
		rsrc_gaddr( R_TREE, POPUP_RAM, &dial_popup );

		if( Fcm_reserve_ram(-1, MX_TTRAM) == 0 )
		{
			SET_BIT_W( dial_popup[POPUP_RAM_TTRAM].ob_state, OS_DISABLED, 1);
		}

		if( !Fcm_cookies_exist(COOKIE_CT60) )
		{
			SET_BIT_W( dial_popup[POPUP_RAM_CT60].ob_state, OS_DISABLED, 1);
		}

		/*if( !Fcm_cookies_exist(COOKIE__MIL) )*/ /* routine a coder */
		{
			SET_BIT_W( dial_popup[POPUP_RAM_MILAN].ob_state, OS_DISABLED, 1);
		}
	}


	return;


}

