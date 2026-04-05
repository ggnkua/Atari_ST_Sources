/* **[NyanCat]****************** */
/* *                           * */
/* * 22/07/2017 MaJ 24/05/2018 * */
/* ***************************** */




void set_offscreen_framebuffer( void );



/* Fonction */
void set_offscreen_framebuffer( void )
{


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# set_offscreen_framebuffer()"CRLF );
	log_print(FALSE);
	#endif


	global_handleoffscreen_framebuffer = (int16)surface_framebuffer.handle_VDIoffscreen;

	
	if( global_handleoffscreen_framebuffer == 0 )
	{
		OBJECT	*adr_dialogue_option;

		rsrc_gaddr( R_TREE, DL_OPTIONS, &adr_dialogue_option );
		SET_BIT_W( (adr_dialogue_option+CHECK_FRAME_BUF )->ob_state, OS_DISABLED, 1 );
		SET_BIT_W( (adr_dialogue_option+CHECK_FRAME_BUF )->ob_state, OS_SELECTED, 0 );
		SET_BIT_W( (adr_dialogue_option+OPTION_FRAME_BUF)->ob_state, OS_DISABLED, 1 );

		global_use_VDI_offscreen_for_framebuffer = FALSE;
	}


	return;


}

