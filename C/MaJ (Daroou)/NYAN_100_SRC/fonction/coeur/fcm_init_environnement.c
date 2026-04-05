/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 16/06/2003 MaJ 03/03/2024 * */
/* ***************************** */



void Fcm_init_environnement( void )
{
	char	mon_chemin[512];
	int16	erreur = FALSE;


	/* Recherche et m‚morisation du chemin courant */
	{
		int16	reponse;
		int16   drive;


		drive = Dgetdrv();
		sprintf( Fcm_chemin_courant, "%c:", (char)(drive + 'A') );  /* A = 65 */

		reponse = Dgetpath( mon_chemin, drive + 1 );

		if( reponse == 0 )
		{
			/* On v‚rifie que la taille du chemin est inf‚rieur */
			/* … la capacit‚ du buffer                          */
			if( strlen(mon_chemin) > 512 )
			{
				form_alert(1, "[3]["PRG_NOM"||buffer mon_chemin ‚cras‚.||Quitter le programme][   OK   ]");
			}
			else
			{
				if( strlen(mon_chemin) < (FCM_TAILLE_CHEMIN_COURANT - 2) )  /* 'x:' */
				{
					strcat( Fcm_chemin_courant, mon_chemin );
				}
				else
				{
					erreur = TRUE;
				}
			}
		}
	}

	strcat( Fcm_chemin_courant, "\\" );


	/* Aucun log_print ne doit etre appel‚ avant que le */
	/* chemin courant soit initialis‚                   */
	/* Aucun log_print avant cette position             */


	/* on cr‚e notre fichier LOG si mode d‚bug activ‚ */
	#ifdef LOG_FILE
	{
		int16	reponse;

		sprintf( buf_log, "# Fcm_init_environnement()"CRLF);
		log_print(TRUE);
		sprintf( buf_log, "# Fichier Log de "PRG_NOM" v"PRG_VERSION","CRLF );
		log_print(FALSE);

		reponse = Tgetdate();

		sprintf( buf_log, "  session du %02d/%02d/%04d",(reponse & 31),((reponse>>5) & 15), ((reponse>>9) & 127)+1980 );
		log_print(FALSE);

		reponse = Tgettime();

		sprintf( buf_log, " … %02d:%02d:%02d"CRLF,((reponse>>11) & 31), ((reponse>>5) & 63), ((reponse & 31)<<1) );
		log_print(FALSE);
		sprintf( buf_log, "  Chemin courant: %s"CRLF""CRLF,Fcm_chemin_courant);
		log_print(FALSE);
	}
	#endif


	if( erreur == TRUE )
	{
		/* Chemin trop long */
		FCM_LOG_PRINT3("ERREUR Chemin trop long (%ld / %d octets) {%s} "CRLF""CRLF,strlen(mon_chemin), FCM_TAILLE_CHEMIN_COURANT, mon_chemin);
	}


	return;


}

