/* **[WindUpdate]*************** */
/* *                           * */
/* * 20/12/2012 MaJ 29/01/2015 * */
/* ***************************** */



void redraw_fenetre_windupdate( const GRECT *rd )
{

	OBJECT	*adr_formulaire;
	int16	winx,winy,winw,winh;



	/* on cherche les coordonn‚es de la fenˆtre */
	wind_get(h_win[W_WINDUPDATE],WF_WORKXYWH,&winx,&winy,&winw,&winh);


	if( win_iconified[W_WINDUPDATE] != TRUE )
	{
		rsrc_gaddr( R_TREE, DL_WINDUPDATE, &adr_formulaire );
	}
	else
	{
		rsrc_gaddr( R_TREE, DL_ICON_WINDUPTE, &adr_formulaire );
	}


	/* on cale le formulaire sur ces coordonn‚es */
	adr_formulaire->ob_x = winx;
	adr_formulaire->ob_y = winy;

	/* on demande … l'AES de tracer le formulaire */
	objc_draw( adr_formulaire,0,4,rd->g_x,rd->g_y,rd->g_w,rd->g_h );


	return;


}

