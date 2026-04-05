/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 28/11/2003 MaJ 03/03/2024 * */
/* ***************************** */


/*
 *
 * 06/11/2023 : ajout du type de la libC: MintLIB ou LibCmini
 * 03/03/2024 : Titre info prg n'est plus statique dans le RSC, c'est PRG_TITRE_INFO
 *              qui est utilisé. Dans le but de rendre la partie Coeur du RSC indépendant
 *              de l'application en vue d'un projet futur (RSC Builder).
 *
 *
 */


#ifndef ___FCM_INIT_RSC_INFO_C___
#define ___FCM_INIT_RSC_INFO_C___



/* __GNUC_PATCHLEVEL__ n'est pas defini sous Gcc 2.8.1,           */
/* donc on le define sur la valeur "1" par defaut                 */
/* version : GCC __GNUC__ , __GNUC_MINOR__ , __GNUC_PATCHLEVEL__  */
#ifndef __GNUC_PATCHLEVEL__
#define __GNUC_PATCHLEVEL__ (1)
#endif



#define MY_BUFFER_SIZE (32)

void Fcm_init_rsc_info( void )
{
	char mon_buffer[MY_BUFFER_SIZE];


	FCM_LOG_PRINT( "# Fcm_init_rsc_info()");


	/* Titre de l'appli */
	{
		size_t titre_len = strlen( Fcm_adr_RTREE[DL_INFO_PRG][INFO_CDR_TEXTE].ob_spec.tedinfo->te_ptext );

		/* N'utilise pas Fcm_set_rsc_string(), car le texte doit être centré (et donc pas rempli d'espace) */
		snprintf( Fcm_adr_RTREE[DL_INFO_PRG][INFO_CDR_TEXTE].ob_spec.tedinfo->te_ptext, titre_len, PRG_TITRE_INFO );
	}

	/* num‚ro de version du programme */
	Fcm_set_rsc_string( DL_INFO_PRG, INFO_PRG_VERSION, PRG_VERSION );


	/* date de sortie de cette version du programme */
	/* construction auto de la date et année du programme */
	/* un peu plus de code, mais plus besoin de mettre à jour à la main */
	#define BUFFER_MOIS_SIZE (16)
	{
		char gcc_mois[]="JanFebMarAprMayJunJulAugSepOctNovDec";
		char buffer_mois[BUFFER_MOIS_SIZE];
		char *pt_position_mois;
		int16 idx_mois;

		/* __DATE__ : "mmm jj aaaa" */

		snprintf( buffer_mois, BUFFER_MOIS_SIZE, __DATE__ );
		buffer_mois[3]=0;  /* on garde que le mois mmm */

		pt_position_mois = strstr( gcc_mois, buffer_mois );

		if( pt_position_mois == NULL )
		{
			/* mois inconnu ??? */
			FCM_CONSOLE_DEBUG1("Fcm_init_rsc_info() : gcc __DATE__ mois inconnu '%s'", buffer_mois );
		}
		else
		{
			/* index du mois  0 - 11 */
			idx_mois = (pt_position_mois - gcc_mois) / 3;

			if( idx_mois > 11 )
			{
				FCM_CONSOLE_DEBUG1("Fcm_init_rsc_info() : gcc __DATE__ erreur mois (%d)", idx_mois);
			}
			else
			{
				snprintf( buffer_mois, BUFFER_MOIS_SIZE, "%s %s", Fcm_adr_RTREE[DL_MOIS][MOIS_JANVIER+idx_mois].ob_spec.free_string, (char *)(__DATE__ + 7) );

//FCM_CONSOLE_ADD3("(%d) date compilation: %s", idx_mois, buffer, G_YELLOW);

				Fcm_set_rsc_string( DL_INFO_PRG, INFO_PRG_DATE, buffer_mois );
			}
		}
	}
	#undef BUFFER_MOIS_SIZE


	/* GEMLIB version */
	snprintf( mon_buffer, MY_BUFFER_SIZE, "%1d.%2d.%1d", __GEMLIB_MAJOR__, __GEMLIB_MINOR__, __GEMLIB_REVISION__ );
	Fcm_set_rsc_string( DL_INFO_PRG, INFO_GEMLIB_VER, mon_buffer );

	/* GCC version */
	snprintf( mon_buffer, MY_BUFFER_SIZE, "%1d.%1d.%1d", __GNUC__, __GNUC_MINOR__, __GNUC_PATCHLEVEL__ );
	Fcm_set_rsc_string( DL_INFO_PRG, INFO_GCC_VER, mon_buffer );

	/* Date et heure de la compilation */
	snprintf( mon_buffer, MY_BUFFER_SIZE, "%s … %s", __DATE__, __TIME__ );
	Fcm_set_rsc_string( DL_INFO_PRG, INFO_COMPIL_DATE, mon_buffer );

	/* Version du Coeur du programme */
	Fcm_set_rsc_string( DL_INFO_PRG, INFO_COEUR_VER, FCM_COEUR_VERSION );

/* *** Temporaire *** le temps que toutes les applis passent à RSC Builder */
#ifdef INFO_RSCBUILD_V
	/* Version de RSC Builder qui a construit le RSC du programme */
	snprintf( mon_buffer, MY_BUFFER_SIZE, "%1d.%2d", RSCBUILDER_MAJOR, RSCBUILDER_MINOR );
	Fcm_set_rsc_string( DL_INFO_PRG, INFO_RSCBUILD_V, mon_buffer );
#endif


	/* TEXT Debug version */
	#ifndef  LOG_FILE
		/* on cache le TEXT 'Debug version' */
		Fcm_adr_RTREE[DL_INFO_PRG][INFO_DBUG].ob_flags = OF_HIDETREE;
	#endif


	/* CPU cible pour la compilation, le define CPU_xxx     */
	/* est defini en option de compilation GCC (-DCPU_XXX)  */
	/* voir le BATch de compilation (boing.bat par exemple) */

	/* 68000 par defaut -> gcc 2.81 */
	strcpy( mon_buffer, "68000" );

	/* les #define sont definis dans la ligne de commande  */
	/* de Gcc :  -DCPU_020_060 avec -m68020-60 par exemple */
	#ifdef CPU_020_060
	  strcpy( mon_buffer, "20-60" );
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


	/* LibC utilise pour la compilation, le define BUILDxxx */
	/* est defini en option de compilation GCC (-DBUILDxxx) */
	/* voir le BATch de compilation (boing.bat par exemple) */

	#ifdef BUILDMINTLIB
	  Fcm_set_rsc_string( DL_INFO_PRG, INFO_LIBC_TYPE, "MintLib" );
	#endif

	#ifdef BUILDLIBCMINI
	  Fcm_set_rsc_string( DL_INFO_PRG, INFO_LIBC_TYPE, "LibCmini" );
	#endif


}

#undef MY_BUFFER_SIZE


#endif   /* ___FCM_INIT_RSC_INFO_C___ */

