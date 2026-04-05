/* **[Pupul]******************** */
/* *                           * */
/* * 01/09/2014 MaJ 07/11/2023 * */
/* ***************************** */



void redraw_fenetre_pupul( const GRECT *rd, const int16 index_tab_win );




/* Fonction */
void redraw_fenetre_pupul( const GRECT *rd, const int16 index_tab_win )
{

	int16	winx,winy,winw,winh;
	UNUSED(index_tab_win);


	/* on cherche les coordonn‚es de travail de la fenˆtre */
	wind_get(h_win[W_PUPUL],WF_WORKXYWH,&winx,&winy,&winw,&winh);



	/* mode normal */
	pxy[0]=rd->g_x-winx;
	pxy[1]=rd->g_y-winy;


	if( win_iconified[W_PUPUL] == TRUE )
	{
		static int16 iconified_flag = FALSE;


		if( iconified_flag == FALSE )
		{
			/* init, on centre la vue */
			iconified_flag    = TRUE;
			view_iconified_x  = MAX( 0, ((SCREEN_WIDTH  - winw)/2) );
			view_iconified_cx = view_iconified_x;

			view_iconified_y  = MAX( 0, ((SCREEN_HEIGHT - winh)/2) );
			view_iconified_cy = view_iconified_y;
		}

		/* mode iconifi‚ */
		pxy[0] = pxy[0] + view_iconified_x;
		pxy[1] = pxy[1] + view_iconified_y;
	}


	pxy[2] = pxy[0] + rd->g_w - 1;
	pxy[3] = pxy[1] + rd->g_h - 1;

	pxy[4] = rd->g_x;
	pxy[5] = rd->g_y;
	pxy[6] = rd->g_x + rd->g_w - 1;
	pxy[7] = rd->g_y + rd->g_h - 1;


	vro_cpyfm(global_vdihandle_ecran,3,pxy,  &mfdb_framebuffer, &Fcm_mfdb_ecran);


	return;


}

