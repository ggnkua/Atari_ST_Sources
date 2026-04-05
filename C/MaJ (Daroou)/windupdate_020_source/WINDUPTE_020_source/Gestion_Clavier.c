/* **[WindUpdate]*************** */
/* * Gestion Clavier           * */
/* * 20/12/2012 MaJ 29/01/2015 * */
/* ***************************** */



void gestion_clavier( int16 controlkey, int16 touche)
{


	/* ---------------------- */
	/* Touche CONTROL appuy‚e */
	/* ---------------------- */
	if( controlkey==K_CTRL )
	{
		/* rien pour le moment */
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
	{
		int16 handle, win_index, dummy;



		wind_get(0,WF_TOP,&handle,&dummy,&dummy,&dummy);

		win_index = Fcm_get_indexwindow(handle);


		if( win_index != FCM_NO_MY_WINDOW )
		{

			if( table_ft_gestion_win[win_index] != FCM_FONCTION_NON_DEFINI )
			{
				table_ft_gestion_win[win_index]( controlkey, touche, 0);
			}
			else
			{
				#ifdef LOG_FILE
				sprintf( buf_log, CRLF"ERREUR - gestion_clavier() (local), FONCTION NON DEFINI (%d)"CRLF, win_index);
				log_print( FALSE );
				#endif
			}
		}
	}



	return;


}

