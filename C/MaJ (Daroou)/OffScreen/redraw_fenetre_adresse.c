/* **[Offscreen]**************** */
/* *                           * */
/* * 30/12/2015 MaJ 31/12/2015 * */
/* ***************************** */



/* Prototype */
void redraw_fenetre_adresse( const GRECT *rd );



/* Fonction */
void redraw_fenetre_adresse( const GRECT *rd )
{

	OBJECT	*adr_formulaire;
	int16	winx,winy,winw,winh;



	/* on cherche les coordonn‚es de la fenˆtre */
	wind_get(h_win[W_ADRESSE],WF_WORKXYWH,&winx,&winy,&winw,&winh);




	if( win_iconified[W_ADRESSE]==FALSE )
	{
		rsrc_gaddr( R_TREE, DL_ADRESSE, &adr_formulaire );
	}
	else
	{
		rsrc_gaddr( R_TREE, DL_ICN_ADRESSE, &adr_formulaire );

		adr_formulaire[ICN_FD_ADRESSE].ob_width  = winw;
		adr_formulaire[ICN_FD_ADRESSE].ob_height = winh;

		adr_formulaire[ICN_TX_ADRESSE].ob_x=(winw-adr_formulaire[ICN_TX_ADRESSE].ob_width)/2;
		adr_formulaire[ICN_TX_ADRESSE].ob_y=(winh-adr_formulaire[ICN_TX_ADRESSE].ob_height)/2;
	}



	/* on cale le formulaire sur ces coordonn‚es */
	adr_formulaire[0].ob_x = winx;
	adr_formulaire[0].ob_y = winy;



	/* on demande … l'AES de tracer le formulaire */
	objc_draw( adr_formulaire,0,4,rd->g_x,rd->g_y,rd->g_w,rd->g_h );



	return;


}

