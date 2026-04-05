/* **[Boing]******************** */
/* *                           * */
/* * 20/09/2015 MaJ 26/04/2024 * */
/* ***************************** */


#include	"../fonction/coeur/fcm_affiche_alerte.c"


void ouvre_fenetre_boing( void );




void ouvre_fenetre_boing( void )
{
	GRECT   win_xywh;


#ifdef LOG_FILE
sprintf( buf_log, " ~ ouvre_fenetre_boing(%d)"CRLF, W_BOING );
log_print(FALSE);
#endif

	/* controler si la fenetre est plus grande que l'écran */
	//win_widgets[W_BOING] = win_widgets[W_BOING] | (UPARROW|DNARROW|VSLIDE|LFARROW|RTARROW|HSLIDE|SIZER);


	win_xywh.g_x = win_posxywh[W_BOING][0];
	win_xywh.g_y = win_posxywh[W_BOING][1];
	win_xywh.g_w = SCREEN_WIDTH;
	win_xywh.g_h = SCREEN_HEIGHT;

	Fcm_ouvre_fenetre( W_BOING, &win_xywh );


	return;


}

