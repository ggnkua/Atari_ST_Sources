/* *[Console]******************* */
/* *                           * */
/* * 01/01/2024 MaJ 26/02/2024 * */
/* ***************************** */



void Fcm_console_init( void )
{

	FCM_LOG_PRINT(CRLF"# Fcm_console_init()");


	win_titre               [ W_CONSOLE ] = 0;
	win_widgets             [ W_CONSOLE ] = NAME|CLOSER|MOVER|BACKDROP|SMALLER|UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE|SIZER;
	win_mouse_through       [ W_CONSOLE ] = FCM_NO_MOUSE_THROUGH;
	win_moved_scalex        [ W_CONSOLE ] = 16; /* x multiple de 16 */

	table_ft_ouvre_fenetre  [ W_CONSOLE ] = Fcm_console_ouvre_fenetre;
	table_ft_redraw_win     [ W_CONSOLE ] = Fcm_console_redraw;
	table_ft_gestion_widgets[ W_CONSOLE ] = Fcm_console_gestion_widget;
	table_ft_gestion_sized  [ W_CONSOLE ] = Fcm_console_gestion_sized;




//@vst_alignment(0,5)   halign left / valign top
//@vst_mode => vswr_mode(2) => MD_TRANS  
//@vst_font(1)    => font index 1 
//@vst_point(8)   => taille fonte hauteur 8 pixels
//@vst_effect(0)  => aucun (italique/bold/underlined/etc...)


	{
		int16 halign_out, valign_out;

		vst_alignment(vdihandle , TA_LEFT, TA_TOP, &halign_out, &valign_out );

		FCM_LOG_PRINT2("  halign_out=%d valign_out=%d", halign_out, valign_out);
	}


	{
//		int16 mode_out;

		/*mode_out =*/ vswr_mode(vdihandle , MD_TRANS);

		//FCM_LOG_PRINT1(" mode_out=%d", mode_out);
	}



/*	{
		int16 name_out;
		char font_name[36];
		int16 font_type;
		int16 index;

		for(index=0; index<8; index++)
		{
			name_out = vqt_name( vdihandle, index, font_name );
			font_type = font_name[33];
			font_name[33]=0;

			FCM_LOG_PRINT3(" name_out=%d font_name={%s} font_type=%d", name_out, font_name, font_type);
		}
	}*/




	{
//		int16 font_out;

		/* AES_LARGEFONT 0 */
		/* AES_SMALLFONT 1 */
		/*font_out =*/ vst_font(vdihandle , 1/*AES_LARGEFONT*/ );

		//FCM_LOG_PRINT1(" font_out=%d ", font_out);
	}


	{
//		int16 point_out;
		int16 charw, charh, cellw, cellh;
		int16 height;

		height = Fcm_screen.gr_hhchar;
		if( Fcm_screen.gr_hhchar < 10 ) height=9;

		/*point_out =*/ vst_point(vdihandle , height/*16*/, &charw, &charh, &cellw, &cellh);

		Fcm_struct_console_global.char_cellw=cellw;
		Fcm_struct_console_global.char_cellh=cellh;

		//FCM_LOG_PRINT4(" charw=%d charh=%d cellw=%d cellh=%d", charw, charh, cellw, cellh);
	}



	{
//		int16 effects_out;

		/*effects_out =*/ vst_effects(vdihandle , TXT_NORMAL);

		//FCM_LOG_PRINT1(" effects_out=%d "CRLF, effects_out);
	}



	/* on vide et init les lignes */
	Fcm_console_clear();


	/* Valeur par defaut */
	Fcm_struct_console_global.nbligne_visible  = 1 + (FCM_CONSOLE_HAUTEUR_MINI / Fcm_struct_console_global.char_cellh);
	Fcm_struct_console_global.nbligne_visible  = MIN( 5, Fcm_struct_console_global.nbligne_visible );
	//Fcm_struct_console_global.nbligne_visible  = 40;



	Fcm_struct_console_global.nblettre_visible = (Fcm_screen.w_desktop / Fcm_struct_console_global.char_cellw) - 4;
	Fcm_struct_console_global.nblettre_visible = MIN( FCM_CONSOLE_TEXTE_MAXLEN, Fcm_struct_console_global.nblettre_visible );
	//Fcm_struct_console_global.nblettre_visible = 80;  /* temp */


	/* largeur max de la zone de travail de la console en pixel */
	Fcm_struct_console_global.zone_w_max = Fcm_struct_console_global.char_cellw * FCM_CONSOLE_TEXTE_MAXLEN;

	/* hauteur max de la zone de travail de la console en pixel */
	Fcm_struct_console_global.zone_h_max = Fcm_struct_console_global.char_cellh * FCM_CONSOLE_MAXLIGNE;


	Fcm_struct_console_global.ligne_active = FCM_CONSOLE_MAXLIGNE - 1;

	Fcm_struct_console_global.ligne_start  = FCM_CONSOLE_MAXLIGNE - Fcm_struct_console_global.nbligne_visible;
	Fcm_struct_console_global.lettre_start = 0;


	return;

}

