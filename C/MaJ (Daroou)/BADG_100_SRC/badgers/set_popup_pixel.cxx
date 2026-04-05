/* **[Badgers]****************** */
/* *                           * */
/* * 04/10/2014 MaJ 14/11/2023 * */
/* ***************************** */

void set_popup_pixel( void );






void set_popup_pixel( void )
{

	OBJECT	*dial_popup;


#ifdef LOG_FILE
sprintf( buf_log, " * set_popup_pixel()"CRLF );
log_print( FALSE );
#endif



	/* ---------------------------- */
	/* Label popup Pixel            */
	/* ---------------------------- */

	/*uint16    index_label=1;*/


	/*switch( Fcm_screen.nb_plan )
	{
		case 1:
			index_label=POP_PIX_1B;
			break;
		case 2:
			index_label=POP_PIX_2B;
			break;
		case 4:
			index_label=POP_PIX_4B;
			break;
		case 8:
			index_label=global_pixel_8bits;
			break;

	}
	global_pixel_label_actif = index_label;*/


	
	rsrc_gaddr( R_TREE, POPUP_PIXEL, &dial_popup );
	Fcm_set_rsc_string( DL_OPTIONS, OPTION_POPUP_PIX, dial_popup[global_pixel_label_actif].ob_spec.tedinfo->te_ptext );



/*{
	char texto[64];

	sprintf( texto, "* global_pixel_label_actif =%d  ",  global_pixel_label_actif );
	v_gtext( vdihandle, 1*8, 10*16, texto);
	sprintf( texto, "* global_pixel_8bits =%d  ",  global_pixel_8bits );
	v_gtext( vdihandle, 1*8, 11*16, texto);
}*/


	if( Fcm_screen.nb_plan < 8 )
	{
		rsrc_gaddr( R_TREE, DL_OPTIONS, &dial_popup );

		SET_BIT_W( dial_popup[OPTION_PIXEL_TXT].ob_state, OS_DISABLED, 1);
		/*SET_BIT_W( dial_popup[OPTION_PIXEL_MIR].ob_state, OS_DISABLED, 1);*/
		SET_BIT_W( dial_popup[OPTION_POPUP_PIX].ob_state, OS_DISABLED, 1);

		return;
	}




	rsrc_gaddr( R_TREE, POPUP_PIXEL, &dial_popup );

	/* on cache tous les labels du popup, sauf 'Auto' */
	{
		int16    idx;

		rsrc_gaddr( R_TREE, POPUP_PIXEL, &dial_popup );

		for( idx=POP_PIX_32B_MOT; idx>POP_PIXEL_AUTO; idx-- )
		{
			SET_BIT_W( dial_popup[idx].ob_flags, OF_HIDETREE, 1);
		}
	}


	if( Fcm_screen.nb_plan==8 )
	{
		SET_BIT_W( dial_popup[POP_PIX_8B_PLAN].ob_flags, OF_HIDETREE, 0);
		SET_BIT_W( dial_popup[POP_PIX_8B_PACK].ob_flags, OF_HIDETREE, 0);
	}

	if( Fcm_screen.nb_plan==16 )
	{
		SET_BIT_W( dial_popup[POP_PIX_15B_FAL].ob_flags, OF_HIDETREE, 0);
		SET_BIT_W( dial_popup[POP_PIX_15B_INT].ob_flags, OF_HIDETREE, 0);
		SET_BIT_W( dial_popup[POP_PIX_15B_MOT].ob_flags, OF_HIDETREE, 0);
		SET_BIT_W( dial_popup[POP_PIX_16B_INT].ob_flags, OF_HIDETREE, 0);
		SET_BIT_W( dial_popup[POP_PIX_16B_MOT].ob_flags, OF_HIDETREE, 0);
	}

	if( Fcm_screen.nb_plan==24 )
	{
		SET_BIT_W( dial_popup[POP_PIX_24B_INT].ob_flags, OF_HIDETREE, 0);
		SET_BIT_W( dial_popup[POP_PIX_24B_MOT].ob_flags, OF_HIDETREE, 0);
	}

	if( Fcm_screen.nb_plan==32 )
	{
		SET_BIT_W( dial_popup[POP_PIX_32B_INT].ob_flags, OF_HIDETREE, 0);
		SET_BIT_W( dial_popup[POP_PIX_32B_MOT].ob_flags, OF_HIDETREE, 0);
	}



	return;


}

