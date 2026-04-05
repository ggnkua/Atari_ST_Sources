/* **[Boing]******************** */
/* *                           * */
/* * 20/09/2015 MaJ 24/09/2023 * */
/* ***************************** */



void redraw_fenetre_boing( const GRECT *rd, const int16 index_tab_win );



/* Fonction */
void redraw_fenetre_boing( const GRECT *rd, const int16 index_tab_win )
{
	/*int16   pxy[8];  global, set in ../fonction/coeur/coeur_variables.c */
	int16	winx,winy,winw,winh;

	UNUSED(index_tab_win); /* => W_BOING */


	/* on cherche les coordonn‚es de travail de la fenˆtre */
	wind_get(h_win[W_BOING],WF_WORKXYWH,&winx,&winy,&winw,&winh);



	/* mode normal */
	pxy[0]=rd->g_x-winx;
	pxy[1]=rd->g_y-winy;


	if( win_iconified[W_BOING]==TRUE )
	{
		static int16 iconified_flag=FALSE;


		if( iconified_flag==FALSE )
		{
			iconified_flag = TRUE;
			view_iconified_x  = MAX( 0, ((SCREEN_WIDTH  - winw)/2) );
			view_iconified_cx = view_iconified_x;

			view_iconified_y  = MAX( 0, ((SCREEN_HEIGHT - winh)/2) );
			view_iconified_cy = view_iconified_y;

		}

		/* mode iconifi‚ */
		pxy[0]=pxy[0]+view_iconified_x;
		pxy[1]=pxy[1]+view_iconified_y;
	}


	pxy[2]=pxy[0]+rd->g_w-1;
	pxy[3]=pxy[1]+rd->g_h-1;

	pxy[4]=rd->g_x;
	pxy[5]=rd->g_y;
	pxy[6]=rd->g_x+rd->g_w-1;
	pxy[7]=rd->g_y+rd->g_h-1;



	if( Fcm_screen.nb_plan==1)
	{
		int16 couleur_boing[2];

		couleur_boing[0]=1;
		couleur_boing[1]=0;

		vrt_cpyfm(vdihandle,MD_REPLACE,pxy, &mfdb_framebuffer, &Fcm_mfdb_ecran, couleur_boing);
	}
	else
	{
		vro_cpyfm(global_vdihandle_ecran,3,pxy,  &mfdb_framebuffer, &Fcm_mfdb_ecran);
	}


	return;


}

