/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 27/11/2003 MaJ 04/03/2024 * */
/* ***************************** */



void Fcm_gestion_clavier( const int16 controlkey, const int16 touche)
{

	FCM_LOG_PRINT2("* Fcm_gestion_clavier(ctrl=$%x key=$%x)", controlkey, touche);


	/* ---------------------------------------------------------- */
	/* On regarde s'il s'agit d'un raccourci clavier standard GEM */
	/* ---------------------------------------------------------- */
	if( controlkey == K_CTRL )
	{
		if( Fcm_analyse_raccourci_GEM(touche) )
		{
			/* renvoie TRUE si le raccourci a ‚t‚ g‚r‚ */
			return;
		}
	}



	/* ------------------------------------------------------------------------ */
	/* On regarde s'il s'agit d'un raccourci clavier commum … toutes les applis */
	/* ------------------------------------------------------------------------ */

	/* Avec la touche CONTROL */
	if( controlkey == K_CTRL )
	{

		switch(touche & 0xff)
		{
			case	9:	/* CTRL-I */
				Fcm_ouvre_fenetre(W_INFO_PRG, NULL);
				return;
				break;
		}
	}


	/* Avec la touche ALT */
	if( controlkey == K_ALT )
	{
		/* rien pour le moment */
	}



	/* touches de fonction - debug */
	switch( touche & 0xff00 )
	{
		case 0x3b00:  /* F1 */
			{
				char debug_txt[256];
				char tampon[16];
				int16 idx;

				debug_txt[0]=0;
				for( idx=0; idx<NB_FENETRE; idx++)
				{
					sprintf( tampon, "(%d,%d)", idx, h_win[idx] );
					strcat( debug_txt, tampon );
				}
				FCM_CONSOLE_DEBUG1("%s", debug_txt);
			}
			break;
		case 0x3c00:  /* F2 */
			break;
		case 0x3d00:  /* F3 */
			break;
	}




	/* Ca doit etre un raccourci propre … l'application */
	/* On execute sa gestion des raccourcis claviers    */
	gestion_clavier( controlkey, touche );


	Fcm_purge_clavier();

	return;


}

