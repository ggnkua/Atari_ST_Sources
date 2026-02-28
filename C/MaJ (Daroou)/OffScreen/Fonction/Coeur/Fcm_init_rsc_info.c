/* **[Fonction Commune]******* */
/* *                         * */
/* * 28/11/2003 # 09/01/2015 * */
/* *************************** */



#ifndef ___Fcm_init_rsc_info___
#define ___Fcm_init_rsc_info___



#ifndef __GNUC_PATCHLEVEL__
#define __GNUC_PATCHLEVEL__ (1)
#endif



#define MY_BUFFER_SIZE     28



/* Prototype */
void Fcm_init_rsc_info( void );




/* Fonction */
void Fcm_init_rsc_info( void )
{
/*
 *
 */
	char mon_buffer[MY_BUFFER_SIZE];



	#ifdef LOG_FILE
	sprintf( buf_log, "  ## Fcm_init_rsc_info()"CRLF);
	log_print(FALSE);
	#endif



	/* num‚ro de version du programme */
	Fcm_set_rsc_string( DL_INFO_PRG, INFO_PRG_VERSION, PRG_VERSION );



	/* date du d‚but de d‚veloppement de cette version du programme */
	Fcm_set_rsc_string( DL_INFO_PRG, INFO_PRG_DATE, PRG_DATE );



	/* GEMLIB version */
	sprintf( mon_buffer, "%1d.%2d.%1d", __GEMLIB_MAJOR__, __GEMLIB_MINOR__, __GEMLIB_REVISION__ );
	Fcm_set_rsc_string( DL_INFO_PRG, INFO_GEMLIB_VER, mon_buffer );



	/* GCC version */
	sprintf( mon_buffer, "%1d.%1d.%1d", __GNUC__, __GNUC_MINOR__, __GNUC_PATCHLEVEL__ );
	Fcm_set_rsc_string( DL_INFO_PRG, INFO_GCC_VER, mon_buffer );



	/* Date et heure de la compilation */
	if( (strlen(__DATE__)+strlen(__TIME__)+4) < MY_BUFFER_SIZE )
	{
		sprintf( mon_buffer, "%s … %s", __DATE__, __TIME__ );
		Fcm_set_rsc_string( DL_INFO_PRG, INFO_COMPIL_DATE, mon_buffer );
	}
#ifdef LOG_FILE
	else
	{
		sprintf( buf_log, "ERREUR - Champ __DATE__  et __TIME__ trop long "CRLF );
		log_print(FALSE);
	}
#endif


	/* Version du Coeur du programme */
	Fcm_set_rsc_string( DL_INFO_PRG, INFO_COEUR_VER, COEUR_VERSION );



	#ifndef  LOG_FILE
	{
		OBJECT	*adr_formulaire;


		/* on cherche l'adresse du formulaire */
		rsrc_gaddr( R_TREE, DL_INFO_PRG, &adr_formulaire );

		/* Debug version */
		adr_formulaire[INFO_DBUG].ob_flags=OF_HIDETREE;

	}
	#endif





	strcpy( mon_buffer, "?????" );

	#ifdef CPU_68K
		strcpy( mon_buffer, "68000" );
	#endif 

	#ifdef CPU_030
		strcpy( mon_buffer, "68030" );
	#endif 

	#ifdef CPU_040
		strcpy( mon_buffer, "68040" );
	#endif 

	#ifdef CPU_060
		strcpy( mon_buffer, "68060" );
	#endif

	#ifdef CPU_CFV4E
		strcpy( mon_buffer, "CFv4e" );
	#endif

	/* CPU cible pour le programme */
	Fcm_set_rsc_string( DL_INFO_PRG, INFO_CPU_TARGET, mon_buffer );


	#ifdef LOG_FILE
	sprintf( buf_log, ""CRLF );
	log_print(FALSE);
	#endif


}



#endif   /* ___Fcm_init_rsc_info___ */


