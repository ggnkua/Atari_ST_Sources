/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 13/11/2003 MaJ 26/02/2024 * */
/* ***************************** */



#ifndef __FCM_SET_WIN_POSITION_C__
#define __FCM_SET_WIN_POSITION_C__


/*
 *  win_posxywh[] : m‚morise les positions des fenetres.
 *
 * Si x et y de win_posxywh[] ne sont pas positionn‚ sur FCM_NO_WINPOS, alors
 * on applique les positions sauvegard‚ dans win_posxywh[].
 *
 * Si x et y de win_posxywh[] sont positionn‚ sur FCM_NO_WINPOS, alors on
 * laisse les coordonn‚es winx et winy transmise (qui sont normalement centr‚
 * sur le bureau), cas du fichier de config absent.
 *
 * Les coordonnées sont vérifiées avant de quitter.
 *
 */



void Fcm_set_win_position( const uint16 index_win, int16 *winx, int16 *winy, int16 *winw, int16 *winh )
{

FCM_LOG_PRINT1( "* Fcm_set_win_position(%d)", index_win );


	if( win_posxywh[index_win][0] != FCM_NO_WINPOS   &&   win_posxywh[index_win][1] != FCM_NO_WINPOS )
	{
		/* On applique les coordonn‚es sauvegard‚es */
		*winx = win_posxywh[index_win][0];
		*winy = win_posxywh[index_win][1];
		*winw = win_posxywh[index_win][2];
		*winh = win_posxywh[index_win][3];
	}


	/* v‚rification de la position sur x */
	/* d‚passement du bureau … droite    */
	*winx = MIN( *winx, (Fcm_screen.w_desktop-100) ); /* etait -32 mais Myaes avec les widget a gauche... */
	/* d‚passement du bureau … gauche    */
	*winx = MAX( *winx, 0 );


	/* v‚rification de la position sur y */
	/* d‚passement du bureau en hauteur, pas plus haut que la barre de menu */
	*winy = MAX( *winy, Fcm_screen.y_desktop/*+2*/ );
	/* d‚passement du bureau en bas, on garde la barre de fenetre visible.  */
	/* Fcm_h_destop n'est pas la hauteur de l'‚cran, mais la hauteur moins la barre de menu */
//	*winy = MIN( *winy, Fcm_screen.h_desktop - (16 * 2) ); /* BAR menu + BAR fenetre */
	*winy = MIN( *winy, (Fcm_screen.y_desktop + Fcm_screen.h_desktop - 16) ); /* 16 => barre WF_NAME fenetre */


	*winw = MIN( *winw, Fcm_screen.w_desktop );
	*winh = MIN( *winh, Fcm_screen.h_desktop );

FCM_LOG_PRINT2("  win_posxywh[idx][0]=%d  win_posxywh[idx][1]=%d", win_posxywh[index_win][0], win_posxywh[index_win][1]);
FCM_LOG_PRINT4("  x=%d y=%d w=%d h=%d", *winx, *winy, *winw, *winh);


	return;

}


#endif   /*  __FCM_SET_WIN_POSITION_C__  */

