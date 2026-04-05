/* **[Badgers]****************** */
/* *                           * */
/* * 24/10/2015 MaJ 05/01/2024 * */
/* ***************************** */

#include "../fonction/graphique/fcm_make_liste_redraw.h"

void init_animation( void );






void init_animation( void )
{

#ifdef LOG_FILE
sprintf( buf_log, CRLF"# init_animation_global()"CRLF );
log_print( FALSE );
#endif




	/* On copie l'image de fond dans l'‚cran offscreen */
	vro_cpyfm(vdihandle,3,pxy_screen, &mfdb_prairie, &mfdb_framebuffer );




	/* dimension de l'ecran pour les fonctions : */
	/* - Fonction\graphique\fcm_make_liste_redraw_opaque.c */
	/* - Fonction\graphique\fcm_make_liste_redraw_transparent.c */
	Fcm_make_liste_redraw_xywh_ecran.g_x=0;
	Fcm_make_liste_redraw_xywh_ecran.g_y=0;
	Fcm_make_liste_redraw_xywh_ecran.g_w=SCREEN_WIDTH;
	Fcm_make_liste_redraw_xywh_ecran.g_h=SCREEN_HEIGHT;



	/* ****************************** */
	/* position de depart des sprites */
	/* ****************************** */


	/* -------------------------------- */
	/* Badgers Animation                */
	/* -------------------------------- */

	pxy_badgers[0][0]=0;
	pxy_badgers[0][1]=0;
	pxy_badgers[0][2]=256-1;
	pxy_badgers[0][3]=210-1;
	pxy_badgers[0][4]=0;
	pxy_badgers[0][5]=SCREEN_HEIGHT-210;
	pxy_badgers[0][6]=0+256-1;
	pxy_badgers[0][7]=SCREEN_HEIGHT-210+210-1;


	pxy_badgers[1][0]=0;
	pxy_badgers[1][1]=0;
	pxy_badgers[1][2]=208-1;
	pxy_badgers[1][3]=207-1;
	pxy_badgers[1][4]=SCREEN_WIDTH-208;
	pxy_badgers[1][5]=330-207;
	pxy_badgers[1][6]=SCREEN_WIDTH-208+208-1;
	pxy_badgers[1][7]=330-207+207-1;


	pxy_badgers[2][0]=0;
	pxy_badgers[2][1]=0;
	pxy_badgers[2][2]=144-1;
	pxy_badgers[2][3]=134-1;
	pxy_badgers[2][4]=195;
	pxy_badgers[2][5]=119;
	pxy_badgers[2][6]=195+144-1;
	pxy_badgers[2][7]=119+134-1;


	pxy_badgers[3][0]=0;
	pxy_badgers[3][1]=0;
	pxy_badgers[3][2]=112-1;
	pxy_badgers[3][3]=100-1;
	pxy_badgers[3][4]=130;
	pxy_badgers[3][5]=110;
	pxy_badgers[3][6]=130+112-1;
	pxy_badgers[3][7]=119+100-1;


	pxy_badgers[4][0]=0;
	pxy_badgers[4][1]=0;
	pxy_badgers[4][2]=86-1;
	pxy_badgers[4][3]=80-1;
	pxy_badgers[4][4]=300;
	pxy_badgers[4][5]=100;
	pxy_badgers[4][6]=300+86-1;
	pxy_badgers[4][7]=100+80-1;


	pxy_badgers[5][0]=0;
	pxy_badgers[5][1]=0;
	pxy_badgers[5][2]=64-1;
	pxy_badgers[5][3]=60-1;
	pxy_badgers[5][4]=228;
	pxy_badgers[5][5]=94;
	pxy_badgers[5][6]=228+64-1;
	pxy_badgers[5][7]=94+60-1;


	pxy_badgers[6][0]=0;
	pxy_badgers[6][1]=0;
	pxy_badgers[6][2]=48-1;
	pxy_badgers[6][3]=24-1;
	pxy_badgers[6][4]=40;
	pxy_badgers[6][5]=88;
	pxy_badgers[6][6]=40+48-1;
	pxy_badgers[6][7]=88+24-1;


	pxy_badgers[7][0]=0;
	pxy_badgers[7][1]=0;
	pxy_badgers[7][2]=47-1;
	pxy_badgers[7][3]=44-1;
	pxy_badgers[7][4]=388;
	pxy_badgers[7][5]=81;
	pxy_badgers[7][6]=388+47-1;
	pxy_badgers[7][7]=81+44-1;


	pxy_badgers[8][0]=0;
	pxy_badgers[8][1]=0;
	pxy_badgers[8][2]=47-1;
	pxy_badgers[8][3]=44-1;
	pxy_badgers[8][4]=210;
	pxy_badgers[8][5]=81;
	pxy_badgers[8][6]=210+47-1;
	pxy_badgers[8][7]=81+44-1;


	pxy_badgers[9][0]=0;
	pxy_badgers[9][1]=0;
	pxy_badgers[9][2]=30-1;
	pxy_badgers[9][3]=28-1;
	pxy_badgers[9][4]=158;
	pxy_badgers[9][5]=80;
	pxy_badgers[9][6]=158+30-1;
	pxy_badgers[9][7]=80+28-1;


	pxy_badgers[10][0]=0;
	pxy_badgers[10][1]=0;
	pxy_badgers[10][2]=30-1;
	pxy_badgers[10][3]=28-1;
	pxy_badgers[10][4]=317;
	pxy_badgers[10][5]=80;
	pxy_badgers[10][6]=317+30-1;
	pxy_badgers[10][7]=80+28-1;



	pxy_badgers[11][0]=0;
	pxy_badgers[11][1]=0;
	pxy_badgers[11][2]=21-1;
	pxy_badgers[11][3]=20-1;
	pxy_badgers[11][4]=458;
	pxy_badgers[11][5]=80;
	pxy_badgers[11][6]=458+21-1;
	pxy_badgers[11][7]=80+20-1;




	/* -------------------------------- */
	/* Snake Animation                  */
	/* -------------------------------- */

	soleil_xywh.g_x = SOLEIL_X;
	soleil_xywh.g_y = SOLEIL_Y;
	soleil_xywh.g_w = SOLEIL_W;
	soleil_xywh.g_h = SOLEIL_H;
	*( &soleil_xywh_old )  = *( &soleil_xywh );


	nuage_xywh.g_x = NUAGE_X;
	nuage_xywh.g_y = NUAGE_Y;
	nuage_xywh.g_w = NUAGE_W;
	nuage_xywh.g_h = NUAGE_H;
	*( &nuage_xywh_old )  = *( &nuage_xywh );


	horizon1_xywh.g_x = HORIZON1_X;
	horizon1_xywh.g_y = HORIZON1_Y;
	horizon1_xywh.g_w = HORIZON1_W;
	horizon1_xywh.g_h = HORIZON1_H;
	*( &horizon1_xywh_old )  = *( &horizon1_xywh );


	horizon2_xywh.g_x = HORIZON2_X;
	horizon2_xywh.g_y = HORIZON2_Y;
	horizon2_xywh.g_w = HORIZON2_W;
	horizon2_xywh.g_h = HORIZON2_H;
	*( &horizon2_xywh_old )  = *( &horizon2_xywh );


	cactus_xywh.g_x = CACTUS_X;
	cactus_xywh.g_y = CACTUS_Y;
	cactus_xywh.g_w = CACTUS_W;
	cactus_xywh.g_h = CACTUS_H;
	*( &cactus_xywh_old )  = *( &cactus_xywh );


	herbe1_xywh.g_x = HERBE1_X;
	herbe1_xywh.g_y = HERBE1_Y;
	herbe1_xywh.g_w = HERBE1_W;
	herbe1_xywh.g_h = HERBE1_H;
	*( &herbe1_xywh_old )  = *( &herbe1_xywh );


	herbe2_xywh.g_x = HERBE2_X;
	herbe2_xywh.g_y = HERBE2_Y;
	herbe2_xywh.g_w = HERBE2_W;
	herbe2_xywh.g_h = HERBE2_H;
	*( &herbe2_xywh_old )  = *( &herbe2_xywh );


	snake_xywh.g_x = SNAKE_X;
	snake_xywh.g_y = SNAKE_Y;
	snake_xywh.g_w = SNAKE_W;
	snake_xywh.g_h = SNAKE_H;
	*( &snake_xywh_old )  = *( &snake_xywh );



	return;


}

