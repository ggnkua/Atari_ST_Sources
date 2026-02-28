/* **[Offscreen]**************** */
/* *                           * */
/* * 31/12/2015 MaJ 31/12/2015 * */
/* ***************************** */



/* Prototype */
void redraw_fenetre_bench( const GRECT *rd );



/* Fonction */
void redraw_fenetre_bench( const GRECT *rd )
{

	OBJECT	*adr_formulaire;
	int16	winx,winy,winw,winh;



	/* on cherche les coordonn‚es de la fenˆtre */
	wind_get(h_win[W_BENCH],WF_WORKXYWH,&winx,&winy,&winw,&winh);




	if( win_iconified[W_BENCH]==FALSE )
	{
		rsrc_gaddr( R_TREE, DL_BENCH, &adr_formulaire );
	}
	else
	{
		rsrc_gaddr( R_TREE, DL_ICN_BENCH, &adr_formulaire );

		adr_formulaire[ICN_FD_BENCH].ob_width  = winw;
		adr_formulaire[ICN_FD_BENCH].ob_height = winh;

		adr_formulaire[ICN_TX_BENCH].ob_x=(winw-adr_formulaire[ICN_TX_BENCH].ob_width)/2;
		adr_formulaire[ICN_TX_BENCH].ob_y=(winh-adr_formulaire[ICN_TX_BENCH].ob_height)/2;
	}



	/* on cale le formulaire sur ces coordonn‚es */
	adr_formulaire[0].ob_x = winx;
	adr_formulaire[0].ob_y = winy;



	/* on demande … l'AES de tracer le formulaire */
	objc_draw( adr_formulaire,0,4,rd->g_x,rd->g_y,rd->g_w,rd->g_h );



	return;


}

