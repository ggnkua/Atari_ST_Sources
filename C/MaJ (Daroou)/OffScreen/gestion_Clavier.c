/* **[Offscreen]**************** */
/* *                           * */
/* * 10/12/2015 MaJ 17/12/2015 * */
/* ***************************** */




/* Fonction */
void gestion_clavier(int16 controlkey, int16 touche)
{
	int16 global_key=FALSE;


/*
 * Scancode : bit 8..15 de touche
 * key      : bit 0..7  de touche
 *
 */





/*{
	char texte[256];

	sprintf(texte,"controlkey%d  touche=%d   Scancode=%d  key=%d   ", controlkey, touche, (touche>>8), (touche&0xff) );
	v_gtext(vdihandle,61*8,2*16,texte);
}*/


	/* ---------------------- */
	/* Touche CONTROL appuy‚e */
	/* ---------------------- */
	if( controlkey==K_CTRL )
	{
		if( (touche>>8)==31 )    /* CTRL-S */
		{
			sauver_statistiques();
			global_key=TRUE;
		}
	}


	/* ------------------------ */
	/* Touche ALTERNATE appuy‚e */
	/* ------------------------ */
	if( controlkey==K_ALT )
	{
		/* rien pour le moment */
	}




	/* Ce n'est pas un raccourci global … l'appli, */
	/* On envoi sur la fentre de gestion de la     */
	/* fenetre au premier plan                     */



	/* *********************************** */
	/* Aiguillage vers la fenˆtre concern‚ */
	/* *********************************** */
	if( global_key != TRUE )
	{
		int16 handle,win_index,dummy;


		wind_get(0,WF_TOP,&handle,&dummy,&dummy,&dummy);

		win_index=Fcm_get_indexwindow(handle);

		if( win_index != FCM_NO_MY_WINDOW )
		{

			if( table_ft_gestion_win[win_index] != FCM_FONCTION_NON_DEFINI )
			{
				table_ft_gestion_win[win_index]( controlkey, touche, 0);
			}
			else
			{
				#ifdef LOG_FILE
				sprintf( buf_log, "ERREUR !!! gestion_clavier(), FONCTION NON DEFINI (%d)"CRLF, win_index);
				log_print( FALSE );
				#endif
			}
		}
	}


	return;


}

