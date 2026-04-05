/**[Console]********************/
/*                             */
/* 01/01/2024 MaJ 12/02/2024   */
/* *****************************/

void Fcm_console_set_slider( void )
{
	int16 dummy;
	int16 winw,winh;


	wind_get(h_win[W_CONSOLE],WF_WORKXYWH,&dummy,&dummy,&winw,&winh);


	/* Taille Slider Horizontal */
	{
		int32 h_slide_size;

		h_slide_size =  (1000 * winw) / Fcm_struct_console_global.zone_w_max;
		h_slide_size =  MIN(1000, h_slide_size);
		h_slide_size =  MAX(32, h_slide_size);

		wind_set( h_win[W_CONSOLE], WF_HSLSIZE, (int16)h_slide_size, 0, 0, 0 );
	}


	/* Taille Slider Vertical */
	{
		int32 v_slide_size;

		v_slide_size =  (1000 * winh) / Fcm_struct_console_global.zone_h_max;
		v_slide_size =  MIN(1000, v_slide_size);
		v_slide_size =  MAX(32, v_slide_size);

		wind_set( h_win[W_CONSOLE], WF_VSLSIZE, (int16)v_slide_size, 0, 0, 0 );
	}


	/* Position Slider Horizontal */
	{
		int32 h_slide_pos;  /* 1 - 1000 */

		if( Fcm_struct_console_global.lettre_start == 0 )
		{
			h_slide_pos = 1;
		}
		else
		{
			h_slide_pos = FCM_CONSOLE_TEXTE_MAXLEN - Fcm_struct_console_global.nblettre_visible;
			h_slide_pos = (Fcm_struct_console_global.lettre_start * 1000 ) / h_slide_pos;
			h_slide_pos = MIN( 1000, h_slide_pos );
		}
		wind_set( h_win[W_CONSOLE], WF_HSLIDE, (int16)h_slide_pos, 0, 0, 0 );
	}


	/* Position Slider Vertical */
	{
		int32 v_slide_pos;  /* 1 - 1000 */

		if( Fcm_struct_console_global.ligne_start == 0 )
		{
			v_slide_pos = 1;
		}
		else
		{
			v_slide_pos = FCM_CONSOLE_MAXLIGNE - Fcm_struct_console_global.nbligne_visible;
			v_slide_pos = (Fcm_struct_console_global.ligne_start * 1000 ) / v_slide_pos;
			v_slide_pos = MIN( 1000, v_slide_pos );
		}
		wind_set( h_win[W_CONSOLE], WF_VSLIDE, (int16)v_slide_pos, 0, 0, 0 );
	}


	return;


}
