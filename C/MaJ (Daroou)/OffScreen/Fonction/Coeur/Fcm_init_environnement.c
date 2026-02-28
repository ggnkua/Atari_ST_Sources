/* **[Fonction Commune]********* */
/* * Init environnement        * */
/* * 16/06/2003 == 07/01/2015  * */
/* ***************************** */





/* Prototype */
void Fcm_init_environnement( void );



/* Fonction */
void Fcm_init_environnement( void )
{
/*
 *
 */
	char	mon_chemin[ (TAILLE_CHEMIN*2) ];
	int16	reponse;
	int16	erreur=FALSE;



	/***********************************************/
	/* Recherche et m‚morisation du chemin courant */
	/***********************************************/

	/* Lecteur courant */
	sprintf( Fcm_chemin_courant, "%c:", (char)(Dgetdrv()+65) );
	/* Chemin courant */
	reponse=Dgetpath( mon_chemin, (Dgetdrv()+1) );


	if( reponse==0 )
	{
		/* On v‚rifie que la taille du chemin est inf‚rieur */
		/* … la capacit‚ du buffer                          */
		if( strlen(mon_chemin) < (TAILLE_CHEMIN-4) )
		{
			strcat( Fcm_chemin_courant, mon_chemin );
		}
		else
		{
			erreur=TRUE;
		}
	}
	strcat( Fcm_chemin_courant, "\\" );



	/* Aucun log_print ne doit etre appel‚ avant que le */
	/* chemin courant soit initialis‚                   */



	/* on cr‚e notre fichier LOG si mode d‚bug activ‚ */
	#ifdef LOG_FILE
	sprintf( buf_log, "# Fcm_init_environnement()"CRLF);
	log_print(TRUE);
	sprintf( buf_log, "# Fichier Log de "PRG_NOM" v"PRG_VERSION","CRLF );
	log_print(FALSE);

	reponse=Tgetdate();

	sprintf( buf_log, "  session du %02d/%02d/%04d",(reponse & 31),((reponse>>5) & 15), ((reponse>>9) & 127)+1980 );
	log_print(FALSE);
	reponse=Tgettime();
	sprintf( buf_log, " … %02d:%02d:%02d"CRLF,((reponse>>11) & 31), ((reponse>>5) & 63), ((reponse & 31)<<1) );
	log_print(FALSE);
	sprintf( buf_log, " - Chemin courant: %s"CRLF""CRLF,Fcm_chemin_courant);
	log_print(FALSE);
	#endif



	if(erreur==TRUE)
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "ERREUR !!! Chemin trop long: (%ld/%ld octets) {%s} "CRLF""CRLF,strlen(mon_chemin), (LONG)(TAILLE_CHEMIN*4), mon_chemin );
		log_print(FALSE);
		#endif

		/* Chemin trop long */
		form_alert(1, "[1]["PRG_NOM"|Chemin courant trop long|pour le buffer.|Chemin ignor‚...][Ok]");
	}


	if( strlen(Fcm_chemin_courant) >= TAILLE_CHEMIN )
	{
		/* d‚passement du buffer !!! */
		#ifdef LOG_FILE
		sprintf( buf_log, "ERREUR !!! d‚passement du buffer Fcm_chemin_courant: (%ld/%ld octets)"CRLF""CRLF, strlen(Fcm_chemin_courant), (int32)(TAILLE_CHEMIN) );
		log_print(FALSE);
		#endif

		form_alert(1, "[1]["PRG_NOM"|Erreur grave|buffer ‚cras‚.|Quitter le programme][Ok]");

	}


	return;


}

