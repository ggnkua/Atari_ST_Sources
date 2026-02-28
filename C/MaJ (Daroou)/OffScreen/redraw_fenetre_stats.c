/* **[Offscreen]**************** */
/* *                           * */
/* * 10/12/2015 MaJ 18/12/2015 * */
/* ***************************** */



/* Prototype */
void redraw_fenetre_stats( const GRECT *rd );



/* Fonction */
void redraw_fenetre_stats( const GRECT *rd )
{

	OBJECT	*adr_formulaire;
	int16	winx,winy,winw,winh;



	/* on cherche les coordonn‚es de la fenˆtre */
	wind_get(h_win[W_STATS],WF_WORKXYWH,&winx,&winy,&winw,&winh);




	if( win_iconified[W_STATS]==FALSE )
	{
		rsrc_gaddr( R_TREE, DL_STATS, &adr_formulaire );
	}
	else
	{
		rsrc_gaddr( R_TREE, DL_ICN_STATS, &adr_formulaire );

		adr_formulaire[ICN_STATS_FOND].ob_width  = winw;
		adr_formulaire[ICN_STATS_FOND].ob_height = winh;

		adr_formulaire[ICN_STATS_TEXT].ob_x=(winw-adr_formulaire[ICN_STATS_TEXT].ob_width)/2;
		adr_formulaire[ICN_STATS_TEXT].ob_y=(winh-adr_formulaire[ICN_STATS_TEXT].ob_height)/2;
	}



	/* on cale le formulaire sur ces coordonn‚es */
	adr_formulaire[ICN_STATS_FOND].ob_x = winx;
	adr_formulaire[ICN_STATS_FOND].ob_y = winy;



	/* on demande … l'AES de tracer le formulaire */
	objc_draw( adr_formulaire,0,4,rd->g_x,rd->g_y,rd->g_w,rd->g_h );



	return;


}

