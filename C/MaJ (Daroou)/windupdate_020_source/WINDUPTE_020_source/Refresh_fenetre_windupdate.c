/* **[WindUpdate]*************** */
/* *                           * */
/* * 07/01/2013 MaJ 29/01/2015 * */
/* ***************************** */



void refresh_fenetre_windupdate( void )
{

	OBJECT	*adr_formulaire;




	if( win_iconified[W_WINDUPDATE]==TRUE )
	{
		/* Si la fenetre est iconifi‚, pas besoin de refresh */
		return;
	}


	rsrc_gaddr( R_TREE, DL_WINDUPDATE, &adr_formulaire );


	Fcm_objet_draw( adr_formulaire, h_win[W_WINDUPDATE], WU_I_FOND_BAR, 0 );


	Fcm_objet_draw( adr_formulaire, h_win[W_WINDUPDATE], WU_REDRAW_START, 0 );

	Fcm_objet_draw( adr_formulaire, h_win[W_WINDUPDATE], WU_REDRAW_FINISH, 0 );
	Fcm_objet_draw( adr_formulaire, h_win[W_WINDUPDATE], WU_CONSEC_FINISH, 0 );
	Fcm_objet_draw( adr_formulaire, h_win[W_WINDUPDATE], WU_RECORD_FINISH, 0 );

	Fcm_objet_draw( adr_formulaire, h_win[W_WINDUPDATE], WU_REDRAW_SKIP, 0 );
	Fcm_objet_draw( adr_formulaire, h_win[W_WINDUPDATE], WU_CONSEC_SKIP, 0 );
	Fcm_objet_draw( adr_formulaire, h_win[W_WINDUPDATE], WU_RECORD_SKIP, 0 );


	return;


}

