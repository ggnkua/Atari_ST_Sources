/* **[WindUpdate]*************** */
/* *                           * */
/* * 09/01/2013 MaJ 29/01/2015 * */
/* ***************************** */



void set_config( void )
{


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"* set_config()"CRLF );
	log_print( FALSE );
	#endif


	/* --------------------------------------------------------- */
	/* config sp‚cifique … l'application                         */
	/* --------------------------------------------------------- */
	{
		OBJECT	*adr_formulaire;


		rsrc_gaddr( R_TREE, win_rsc[W_WINDUPDATE], &adr_formulaire );


		/* On selectionne BEG_UPDATE par defaut (valeur=0) */
		SET_BIT_W( (adr_formulaire+WU_BLOCK  )->ob_state, OS_SELECTED, 1);
		SET_BIT_W( (adr_formulaire+WU_NOBLOCK)->ob_state, OS_SELECTED, 0);

		if( mask_windupdate == FCM_WU_NO_BLOCK )
		{
			/* On selectionne BEG_UPDATE|NO_BLOCK  */
			SET_BIT_W( (adr_formulaire+WU_BLOCK  )->ob_state, OS_SELECTED, 0);
			SET_BIT_W( (adr_formulaire+WU_NOBLOCK)->ob_state, OS_SELECTED, 1);
		}



		/* On d‚s‚lectionne Temps r‚el par d‚faut  (valeur=0) */
		SET_BIT_W( (adr_formulaire+WU_BT_FULLTIME)->ob_state, OS_SELECTED, 0);

		if( redraw_skip_compteur== 0 )
		{
			/* On selectionne */
			SET_BIT_W( (adr_formulaire+WU_BT_FULLTIME)->ob_state, OS_SELECTED, 1);
		}




		/* On d‚s‚lectionne no block pour le cadre stat */
		SET_BIT_W( (adr_formulaire+WU_NOMBRE_MODE)->ob_state, OS_SELECTED, 0);

		if( mask_noblock_nombre == FCM_WU_NO_BLOCK )
		{
			/* On selectionne */
			SET_BIT_W( (adr_formulaire+WU_NOMBRE_MODE)->ob_state, OS_SELECTED, 1);
		}


	}


	return;


}

