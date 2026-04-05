/* **[Fonction Commune]********* */
/* *                           * */
/* * 17/11/2003 MaJ 03/05/2015 * */
/* ***************************** */


/* Prototype */
/*void Fcm_redraw_fenetre_preference( const GRECT *rd );*/


/* Fonction */
void Fcm_redraw_fenetre_preference( const GRECT *rd )
{

	OBJECT	*adr_formulaire;
	int16	winx,winy,winw,winh;



	/* on cherche les coordonn‚es de la fenˆtre */
	wind_get(h_win[W_OPTION_PREFERENCE],WF_WORKXYWH,&winx,&winy,&winw,&winh);




	if( win_iconified[W_OPTION_PREFERENCE]==FALSE )
	{
		rsrc_gaddr( R_TREE, DL_OPT_PREF, &adr_formulaire );
	}
	else
	{
		rsrc_gaddr( R_TREE, DL_ICON_PREF, &adr_formulaire );

		adr_formulaire[ICN_PREF_FOND].ob_width  = winw;
		adr_formulaire[ICN_PREF_FOND].ob_height = winh;

		adr_formulaire[ICN_PREF_TEXT].ob_x=(winw-adr_formulaire[ICN_PREF_TEXT].ob_width)/2;
		adr_formulaire[ICN_PREF_TEXT].ob_y=(winh-adr_formulaire[ICN_PREF_TEXT].ob_height)/2;
	}



	/* on cale le formulaire sur ces coordonn‚es */
	adr_formulaire[ICN_PREF_FOND].ob_x = winx;
	adr_formulaire[ICN_PREF_FOND].ob_y = winy;



	/* on demande … l'AES de tracer le formulaire */
	objc_draw( adr_formulaire,0,4,rd->g_x,rd->g_y,rd->g_w,rd->g_h );



	return;


}

