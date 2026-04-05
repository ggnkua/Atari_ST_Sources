/* **[Fonction Commune]******** */
/* *                          * */
/* * 17/11/2003 # 08/04/2013  * */
/* **************************** */


/* Prototype */
VOID Fcm_redraw_fenetre_preference( const GRECT *rd );


/* Fonction */
VOID Fcm_redraw_fenetre_preference( const GRECT *rd )
{
	/* Variables Globales Externes:
	 *
	 * extern	WORD	h_win[NB_FENETRE];
	 * extern	UWORD	frame_win[NB_FENETRE];
	 * extern	MFDB	mfdb_winframe;
	 * extern	MFDB	mfdb_ecran;
	 * extern	WORD	pxy[16];
	 * extern	WORD	vdihandle;
	 *
	 */


	OBJECT	*adr_formulaire;
	UWORD	ob_start;
	WORD	winx,winy,winw,winh;


	/* on cherche les coordonn‚es de la fenˆtre */
	wind_get(h_win[W_OPTION_PREFERENCE],WF_WORKXYWH,&winx,&winy,&winw,&winh);

	ob_start=0;

	/* Si le winframe est activ‚ et que la fenetre n'est pas iconifi‚e */
/*	if( Fcm_winframe_flag && win_iconified[W_OPTION_PREFERENCE]==FALSE )
	{
		ob_start=1;
		pxy[0]=rd->g_x-winx;
		pxy[1]=rd->g_y-winy;
		pxy[2]=pxy[0]+rd->g_w-1;
		pxy[3]=pxy[1]+rd->g_h-1;

		pxy[4]=rd->g_x;
		pxy[5]=rd->g_y;
		pxy[6]=pxy[4]+rd->g_w-1;
		pxy[7]=pxy[5]+rd->g_h-1;

		vro_cpyfm(vdihandle,3,pxy,&Fcm_mfdb_winframe,&Fcm_mfdb_ecran);
	}*/

	if( win_iconified[W_OPTION_PREFERENCE]==FALSE )
	{
		rsrc_gaddr( R_TREE, DL_OPT_PREF, &adr_formulaire );
	}
	else
	{
		rsrc_gaddr( R_TREE, DL_ICON_PREF, &adr_formulaire );
	}

	/* on cale le formulaire sur ces coordonn‚es */
	adr_formulaire->ob_x = winx;
	adr_formulaire->ob_y = winy;

	/* on demande … l'AES de tracer le formulaire */
	objc_draw( adr_formulaire,ob_start,7,rd->g_x,rd->g_y,rd->g_w,rd->g_h );


	return;


}

