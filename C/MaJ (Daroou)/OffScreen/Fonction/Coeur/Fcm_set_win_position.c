/* **[Fonction Comune]******** */
/* *                         * */
/* * 13/11/2003 = 04/01/2015 * */
/* *************************** */



#ifndef __Fcm_set_win_position__
#define __Fcm_set_win_position__




/* Prototype */
VOID Fcm_set_win_position( const WORD index_win, WORD *winx, WORD *winy );


/* Fonction */
VOID Fcm_set_win_position( const WORD index_win, WORD *winx, WORD *winy )
{


	/* Si x et y de win_pos[] (qui m‚morise les positions des fenetres) ne sont pas  */
	/* positionn‚ sur FCM_NO_WINPOS, alors on modifie winx et winy par les positions */
	/* sauvegard‚ dans win_pos[].                                                    */

	/* Si x et y de win_pos[] sont positionn‚ sur FCM_NO_WINPOS, alors on laisse les */
	/* coordonn‚es winx et winy transmise (qui sont centr‚ sur le bureau), cas du    */
	/* fichier de config absent                                                      */

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"* Fcm_set_win_position()"CRLF );
	log_print(FALSE);
	sprintf( buf_log, "win_posxywh[index_win][0]=%d win_posxywh[index_win][1]=%d"CRLF, win_posxywh[index_win][0], win_posxywh[index_win][1] );
	log_print(FALSE);
	sprintf( buf_log, "winx=%d winy=%d"CRLF, *winx, *winy );
	log_print(FALSE);
	#endif


	if( win_posxywh[index_win][0]!=FCM_NO_WINPOS && win_posxywh[index_win][1]!=FCM_NO_WINPOS )
	{
		/* On reprend les coordonn‚es sauvegard‚es */
		*winx=win_posxywh[index_win][0];
		*winy=win_posxywh[index_win][1];
	}


	/* v‚rification de la position sur x */
	/* d‚passement du bureau … droite    */
	*winx=MIN( *winx, (Fcm_screen.w_desktop-32) );
	/* d‚passement du bureau … gauche    */
	*winx=MAX( *winx, 0 );


	/* v‚rification de la position sur y */
	/* d‚passement du bureau en hauteur, pas plus haut que la barre de menu */
	*winy=MAX( *winy, Fcm_screen.y_desktop+2 );
	/* d‚passement du bureau en bas, on garde la barre de fenetre visible.  */
	/* Fcm_h_destop n'est pas la hauteur de l'‚cran, mais la hauteur moins la barre de menu */
	*winy=MIN( *winy, Fcm_screen.h_desktop-32 );

	#ifdef LOG_FILE
	sprintf( buf_log, "win_posxywh[index_win][0]=%d win_posxywh[index_win][1]=%d"CRLF, win_posxywh[index_win][0], win_posxywh[index_win][1] );
	log_print(FALSE);
	sprintf( buf_log, "winx=%d winy=%d"CRLF, *winx, *winy );
	log_print(FALSE);
	#endif

	return;

}


#endif

