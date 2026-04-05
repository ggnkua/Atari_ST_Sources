/* **[]************************* */
/* *                           * */
/* * 20/04/2015 MaJ 20/04/2015 * */
/* ***************************** */



void Fcm_redraw_fenetre_launch( const GRECT *rd );



/* Fonction */
void Fcm_redraw_fenetre_launch( const GRECT *rd )
{

	OBJECT	*adr_formulaire;
	int16	winx,winy,winw,winh;


	/* on cherche les coordonn‚es de travail de la fenˆtre */
	wind_get(h_win[W_LAUNCH],WF_WORKXYWH,&winx,&winy,&winw,&winh);


	rsrc_gaddr( R_TREE, win_rsc[W_LAUNCH], &adr_formulaire );


	/* on cale le formulaire sur ces coordonn‚es */
	adr_formulaire->ob_x = winx;
	adr_formulaire->ob_y = winy;

	/* on demande … l'AES de tracer le formulaire */
	objc_draw( adr_formulaire,0,4,rd->g_x,rd->g_y,rd->g_w,rd->g_h );


	return;


}

