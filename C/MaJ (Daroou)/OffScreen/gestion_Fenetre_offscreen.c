/* **[Offscreen]**************** */
/* *                           * */
/* * 10/12/2015 MaJ 18/12/2015 * */
/* ***************************** */






/* Fonction */
void gestion_fenetre_offscreen( int16 controlkey, int16 touche, int16 bouton )
{





	/* suppression des warning */
	{
		int16 a=controlkey;
		int16 b=touche;
		a=a+b;
	}






	if( win_iconified[W_OFFSCREEN]==TRUE )
	{
		if( bouton==1 )
		{
			static uint32 old_entry_timer=0;
			static uint16 old_pos_x=0;
			static uint16 old_pos_y=0;
			        int16 mx, my, dummy;
			        int16 winw,winh;


			graf_mkstate(&mx, &my, &dummy, &dummy);

			if( (Fcm_get_timer()-old_entry_timer) < 20 )
			{

/*
{
	char  texte[256];

	sprintf(texte,"gestion_fenetre_offscreen(%d, %d, %d) %ld # %ld  ", controlkey, touche, bouton, Fcm_get_timer(), Fcm_get_timer()-old_entry_timer );
	v_gtext(vdihandle,6*8,1*16,texte);

	sprintf(texte,"view_iconified_x=%d, view_iconified_y=%d  ", view_iconified_x,view_iconified_y );
	v_gtext(vdihandle,6*8,2*16,texte);
}
*/

				wind_get(h_win[W_OFFSCREEN],WF_WORKXYWH,&dummy,&dummy,&winw,&winh);


				view_iconified_x=view_iconified_x - (mx - old_pos_x);
				view_iconified_y=view_iconified_y - (my - old_pos_y);

				view_iconified_x=MAX(0, view_iconified_x);
				view_iconified_y=MAX(0, view_iconified_y);

				view_iconified_x=MIN( (SCREEN_WIDTH -winw), view_iconified_x);
				view_iconified_y=MIN( (SCREEN_HEIGHT-winh), view_iconified_y);


			}

			old_entry_timer=Fcm_get_timer();
			old_pos_x=mx;
			old_pos_y=my;
		}


		if( bouton==2 )
		{
			view_iconified_x=view_iconified_cx;
			view_iconified_y=view_iconified_cy;
		}
	}



	return;

}

