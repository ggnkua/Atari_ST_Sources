/* **[Fonction Commune]********* */
/* *                           * */
/* * 17/04/2002 MaJ 05/05/2018 * */
/* ***************************** */

/* Prototype */
/*void Fcm_redraw_fenetre_info( const GRECT *rd );*/

/* Fonction */
void Fcm_redraw_fenetre_info( const GRECT *rd )
{

	OBJECT	*adr_formulaire;
	int16	winx,winy,winw,winh;


	/* on cherche les coordonn‚es de la fenˆtre */
	wind_get(h_win[W_INFO_PRG],WF_WORKXYWH,&winx,&winy,&winw,&winh);


	if( win_iconified[W_INFO_PRG]==FALSE )
	{
		rsrc_gaddr( R_TREE, DL_INFO_PRG, &adr_formulaire );
	}
	else
	{
		rsrc_gaddr( R_TREE, DL_ICON_INFO, &adr_formulaire );

		/* la taille de la fenetre en mode iconfie peut varier */
		/* donc on s'adapte a la taille de la fenetre          */
		adr_formulaire[ICN_INFO_FOND].ob_width  = winw;
		adr_formulaire[ICN_INFO_FOND].ob_height = winh;

		adr_formulaire[ICN_INFO_TEXT].ob_x=(winw-adr_formulaire[ICN_INFO_TEXT].ob_width)/2;
		adr_formulaire[ICN_INFO_TEXT].ob_y=(winh-adr_formulaire[ICN_INFO_TEXT].ob_height)/2;
	}


	/* on cale le formulaire sur ces coordonn‚es */
/*	adr_formulaire[ICN_INFO_FOND].ob_x = winx;
	adr_formulaire[ICN_INFO_FOND].ob_y = winy;*/
	adr_formulaire->ob_x = winx;
	adr_formulaire->ob_y = winy;


	/* on demande … l'AES de tracer le formulaire */
	objc_draw( adr_formulaire,0,4,rd->g_x,rd->g_y,rd->g_w,rd->g_h );


	return;


}

