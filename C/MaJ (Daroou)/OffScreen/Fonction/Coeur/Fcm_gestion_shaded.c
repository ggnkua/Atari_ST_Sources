/* **[Fonction commune]******** */
/* * Gestion message          * */
/* * 03/01/2013 = 06/04/2013  * */
/* **************************** */



#ifndef ___Fcm_gestion_shaded___
#define ___Fcm_gestion_shaded___





/* Prototypes */
VOID Fcm_gestion_shaded(VOID);


/* Fonction */
VOID Fcm_gestion_shaded(VOID)
{
/*
 * extern	FT_REDRAW	table_ft_redraw_win[NB_FENETRE];
 * extern	WORD		buffer_aes[16];
 * extern	WORD		h_win[NB_FENETRE];
 * extern	WORD		pxy[16];
 * extern	WORD		vdihandle;
 *
 */
	WORD win_index;


	/* Cette fonction gŠre les actions qui doivent etre */
	/* ex‚cut‚ lorsque le contenu d'une de nos fenetres */
	/* est cach‚ ou r‚-affich‚                          */

	/* Ex: changement de palette, activation du contenu, */
	/* pause du jeu, etc...                              */


	/* Pour l'instant, aucune utilit‚, … impl‚menter le */
	/* jour o— la n‚cessit‚ se fera sentir              */



	/* on prend juste note de l'‚tat pour les redraws & Cie */

	win_index=Fcm_get_indexwindow( buffer_aes[3] );


	if( win_index != FCM_NO_MY_WINDOW )
	{
		switch( buffer_aes[0] )
		{
			case WM_SHADED:
				win_shaded[win_index]=TRUE;
				break;

			case WM_UNSHADED:
				win_shaded[win_index]=FALSE;
				break;
		}
	}



	return;


}


#endif /* ___Fcm_gestion_shaded___ */

