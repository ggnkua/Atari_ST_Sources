/* *[Console]******************* */
/* *                           * */
/* * 01/01/2024 MaJ 13/03/2026 * */
/* ***************************** */


#include "../fcm_affiche_alerte.h"


void Fcm_console_ouvre_fenetre( void )
{
	int16	x, y, largeur, hauteur;
	int16	winx, winy, winw, winh;
	GRECT   win_xywh;


	FCM_LOG_PRINT(CRLF"* Fcm_console_ouvre_fenetre()");


	if( h_win[W_CONSOLE] > 0 )
	{
		/* La console reste dans le plan actuel, pas de premier plan */
		return;
	}


	/* Calcul des dimensions de la fenetre par defaut */
	x       = 16;
	//y       = Fcm_screen.h_desktop - hauteur - 32;
	y       = Fcm_screen.y_desktop + 16;
//	largeur = Fcm_struct_console_global.nblettre_visible * Fcm_struct_console_global.char_cellw;
	largeur = Fcm_screen.w_desktop - 16;
	//largeur = 160;
//	hauteur = Fcm_struct_console_global.nbligne_visible  * Fcm_struct_console_global.char_cellh;
	hauteur = Fcm_screen.h_desktop - 16;
	//hauteur = 80;

FCM_LOG_PRINT4(CRLF"*1** x=%d y=%d largeur=%d hauteur=%d", x, y, largeur, hauteur );

	/* on demande … l'AES de nous calculer les dimensions exterieurs de la fenˆtre */
	wind_calc( WC_BORDER, win_widgets[W_CONSOLE], x, y, largeur, hauteur, &winx, &winy, &winw, &winh );

FCM_LOG_PRINT4(CRLF"*2** WC_BORDER:: winx=%d winy=%d winw=%d winh=%d", winx, winy, winw, winh );

	/* On applique les coordonn‚es sauvegard‚es dans le fichier de config si pr‚sente */
	Fcm_set_win_position( W_CONSOLE, &winx, &winy, &winw, &winh );

FCM_LOG_PRINT4(CRLF"*3** winx=%d winy=%d winw=%d winh=%d", winx, winy, winw, winh );


	/* on controle par rapport au dimension de l'ecran */
	winw = MIN( winw, (Fcm_screen.w_desktop-16) );  /* 16 -> VSLIDE */
	winh = MIN( winh, (Fcm_screen.h_desktop-32) );  /* 32 -> NAME + HSLIDE */

	winx = MIN( winx, (Fcm_screen.w_desktop - winw) );
	winx = MAX( 0, winx);

	winy = MIN( winy, (Fcm_screen.h_desktop-winh) );
	winy = MAX( Fcm_screen.y_desktop, winy );

FCM_LOG_PRINT4(CRLF"*4** winx=%d winy=%d winw=%d winh=%d", winx, winy, winw, winh );

	/* on doit de nouveau verifier les dimensions interne de la fenˆtre    */
	/* Les dimensions sont alignées sur la taille d'un caractère en W et H */
	wind_calc( WC_WORK, win_widgets[W_CONSOLE],	winx, winy, winw, winh, &x, &y, &largeur, &hauteur  );

FCM_LOG_PRINT4(CRLF"*5** WC_WORK:: x=%d y=%d largeur=%d hauteur=%d", x, y, largeur, hauteur );

	largeur = MIN( largeur, FCM_CONSOLE_TEXTE_MAXLEN * Fcm_struct_console_global.char_cellw );
	largeur = MIN( largeur, ((largeur/Fcm_struct_console_global.char_cellw) * Fcm_struct_console_global.char_cellw) );

	hauteur = MIN( hauteur, FCM_CONSOLE_MAXLIGNE  * Fcm_struct_console_global.char_cellh );
	hauteur = MIN( hauteur, ((hauteur/Fcm_struct_console_global.char_cellh) * Fcm_struct_console_global.char_cellh) );

FCM_LOG_PRINT4(CRLF"*6** x=%d y=%d largeur=%d hauteur=%d", x, y, largeur, hauteur );

	/* dimension interieur final de la fenetre */
	x = (x / 16) * 16;  /* x multiple de 16 */
	//win_xywh.g_y = y;
	//win_xywh.g_w = largeur;
	//win_xywh.g_h = hauteur;

FCM_LOG_PRINT4(CRLF"*7** x=%d y=%d largeur=%d hauteur=%d", x, y, largeur, hauteur );

	Fcm_struct_console_global.nbligne_visible  = hauteur / Fcm_struct_console_global.char_cellh;
	Fcm_struct_console_global.nblettre_visible = largeur / Fcm_struct_console_global.char_cellw;

FCM_LOG_PRINT3(CRLF"**** nbligne_visible=%d char_cellh=%d hauteur=%d", Fcm_struct_console_global.nbligne_visible, Fcm_struct_console_global.char_cellh, hauteur );
FCM_LOG_PRINT3("**** nblettre_visible=%d char_cellw=%d largeur=%d", Fcm_struct_console_global.nblettre_visible, Fcm_struct_console_global.char_cellw, largeur );

	Fcm_struct_console_global.ligne_start  = FCM_CONSOLE_MAXLIGNE - Fcm_struct_console_global.nbligne_visible;

FCM_LOG_PRINT2("**** Fcm_struct_console_global.ligne_start=%d FCM_CONSOLE_MAXLIGNE=%d", Fcm_struct_console_global.ligne_start, FCM_CONSOLE_MAXLIGNE );


	/* Dimension de la zone de travail */
	win_xywh.g_x = x;
	win_xywh.g_y = y;
	win_xywh.g_w = largeur;
	win_xywh.g_h = hauteur;

	/* c'est fini, enfin, on demande les dimensions final de la fenetre */
	wind_calc( WC_BORDER, win_widgets[W_CONSOLE], x, y, largeur, hauteur, &winx, &winy, &winw, &winh );

FCM_LOG_PRINT4(CRLF"*8** WC_BORDER:: winx=%d winy=%d winw=%d winh=%d", winx, winy, winw, winh );

	/* on memorise les dimension exterieur de la fenetre */
	win_posxywh[W_CONSOLE][0] = winx;
	win_posxywh[W_CONSOLE][1] = winy;
	win_posxywh[W_CONSOLE][2] = winw;
	win_posxywh[W_CONSOLE][3] = winh;


	Fcm_ouvre_fenetre( W_CONSOLE, &win_xywh );

	if( h_win[W_CONSOLE] > 0 )
	{
		Fcm_console_set_slider();
	}
	else
	{
		FCM_LOG_PRINT1("‚chec (%d)", h_win[W_CONSOLE]);


		h_win[W_CONSOLE] = FCM_NO_OPEN_WINDOW;
		Fcm_affiche_alerte( DATA_MODE_COEUR, ALC_NO_WINDOWS, 0 );
	}


	return;


}

