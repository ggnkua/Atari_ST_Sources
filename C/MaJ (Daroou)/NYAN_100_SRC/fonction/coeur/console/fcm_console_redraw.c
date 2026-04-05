/* *[Console]******************* */
/* *                           * */
/* * 01/01/2024 MaJ 27/02/2024 * */
/* ***************************** */



/* ATTENTION : pas de message Console :) */


void Fcm_console_redraw( const GRECT *rd , const int16 index_tab_win)
{
	int16	winx,winy,dummy;


//FCM_LOG_PRINT(CRLF"* Fcm_console_redraw");

	wind_get(h_win[index_tab_win],WF_WORKXYWH,&winx,&winy,&dummy,&dummy);

	{
		int16 pxybar[8];

		pxybar[0]=rd->g_x;
		pxybar[1]=rd->g_y;
		pxybar[2]=rd->g_x+rd->g_w;
		pxybar[3]=rd->g_y+rd->g_h;

/*		evnt_timer(20);
		vsf_color(vdihandle, G_YELLOW);
		vr_recfl(vdihandle, pxybar);
		evnt_timer(50);*/

		vsf_color(vdihandle, G_BLACK);
		vr_recfl(vdihandle, pxybar);
	}

	{
		int16 index_ligne;
		int16 num_ligne;
		char *pt_texte;

		for( index_ligne=0 ; index_ligne<Fcm_struct_console_global.nbligne_visible ; index_ligne++ )
		{
			num_ligne = Fcm_struct_console_global.ligne_start + index_ligne;
			pt_texte  = Fcm_struct_console_texte[num_ligne].texte;

			if( Fcm_struct_console_global.lettre_start < Fcm_struct_console_texte[num_ligne].texte_lenght )
			{
				pt_texte = pt_texte + Fcm_struct_console_global.lettre_start;

				vst_color(vdihandle, Fcm_struct_console_texte[num_ligne].texte_color);
				v_gtext( vdihandle, winx, winy, pt_texte);
			}
			winy = winy + Fcm_struct_console_global.char_cellh;
		}
	}


	return;


}

