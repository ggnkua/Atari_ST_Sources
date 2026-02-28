/* **[Offscreen]**************** */
/* *                           * */
/* * 03/01/2016 MaJ 06/02/2016 * */
/* ***************************** */





#include "fonction/coeur/Fcm_Fprint.c"
#include "fonction/Fcm_file_select.c"

#include "affiche_error.c"



/* Prototype */
void sauver_statistiques( void );




/* Fonction */
void sauver_statistiques( void )
{

	char    chemin[TAILLE_CHEMIN_DATA];
	char    fichier[TAILLE_FICHIER];
	int16	handle_fichier;



	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# sauver_statistiques()"CRLF );
	log_print( FALSE );
	#endif


	strcpy( chemin, Fcm_chemin_courant );
	strcpy( fichier, "STATS.TXT" );


	{
		int16 reponse_file_select;


		reponse_file_select=Fcm_file_select( TITRE_SAVE_STATS, TAILLE_CHEMIN_DATA, chemin, fichier, "*.TXT" );
		evnt_timer(500);


/*{
	char texte[256];

	sprintf(texte,"Fcm_file_select, reponse=%d      ", reponse_file_select );
	v_gtext(vdihandle,61*8,5*16,texte);
	sprintf(texte,"chemin=%s      ", chemin );
	v_gtext(vdihandle,61*8,6*16,texte);
}*/

		/* Une erreur s'est produiite ? */
		if( reponse_file_select < 0 )
		{
			affiche_error(reponse_file_select);
			return;
		}

		/* Annuler par l'utilisateur ? */
		if( reponse_file_select==FALSE )
		{
			return;
		}

	}



	/* Le fichier existe d‚j… ? */
	if( Fcm_file_exist(chemin) == TRUE )
	{
		int16 bouton;

		/* On l'‚crase ? */
		Fcm_affiche_alerte( DATA_MODE_APPLI, ALT_ERR_F_EXIST, &bouton );

/*{
	char texte[256];

	sprintf(texte,"Fcm_affiche_alerte, bouton=%d    ", bouton );
	v_gtext(vdihandle,61*8,8*16,texte);
}*/

		/* L'utilisateur a annul‚ ? */
		if( bouton != 2 )
		{
			return;
		}

	}





	/* ----------------------- */
	/* Sauvegarde Statistiques */
	/* ----------------------- */

	handle_fichier=Fcreate( chemin, 0 );

	if(handle_fichier>0)
	{
		char buffer[64];


		Fcm_fprint( handle_fichier, "* --- "PRG_FULL_NOM"  version "PRG_VERSION" --- *" );
		Fcm_fprint( handle_fichier, "");


		sprintf( buffer, "%dx%d  %d bits (%ld couleurs)", Fcm_screen.width, Fcm_screen.height, Fcm_screen.nb_plan, Fcm_screen.color );
		Fcm_fprint( handle_fichier, buffer );
		Fcm_fprint( handle_fichier, "");

		sprintf( buffer, "Adresse ‚cran:"CRLF"VDI      = $%08lx"CRLF"Physbase = $%08lx", Fcm_screen.adresse, Fcm_screen.physbase );
		Fcm_fprint( handle_fichier, buffer );
		Fcm_fprint( handle_fichier, "");


		if( offscreenhandle!=vdihandle )
		{
			sprintf( buffer, "Mode offscreen VDI support‚ (EdDi %x.%02x)", (Fcm_screen.eddi_version>>8), (Fcm_screen.eddi_version & 0xff) );
			Fcm_fprint( handle_fichier, buffer );
		}
		else
		{
			sprintf( buffer, "Mode offscreen VDI non support‚.");
			Fcm_fprint( handle_fichier, buffer );
		}



		Fcm_fprint( handle_fichier, "");
		Fcm_fprint( handle_fichier, "");

		sprintf( buffer, "Cookie:" );
		Fcm_fprint( handle_fichier, buffer );
		sprintf( buffer, "EdDI : %s", info_eddi );
		Fcm_fprint( handle_fichier, buffer );
		sprintf( buffer, "NVDI : %s", info_nvdi );
		Fcm_fprint( handle_fichier, buffer );
		sprintf( buffer, "CT60 : %s", info_ct60 );
		Fcm_fprint( handle_fichier, buffer );
		sprintf( buffer, "_PCI : %s", info_pci );
		Fcm_fprint( handle_fichier, buffer );
		sprintf( buffer, "SupV : %s", info_supv );
		Fcm_fprint( handle_fichier, buffer );
		Fcm_fprint( handle_fichier, "");

/*		sprintf( buffer, "Rez: %s", info_rez );
		Fcm_fprint( handle_fichier, buffer );
		Fcm_fprint( handle_fichier, "");*/

		sprintf( buffer, "Ct60_vmalloc(0,-1) %s", info_vram_free );
		Fcm_fprint( handle_fichier, buffer );
		Fcm_fprint( handle_fichier, "");

		sprintf( buffer, "ATI Device : %s", info_ati_device );
		Fcm_fprint( handle_fichier, buffer );
		Fcm_fprint( handle_fichier, "");


		Fcm_fprint( handle_fichier, "");



/*		Fcm_fprint( handle_fichier, "Statistiques:");
		Fcm_fprint( handle_fichier, "-----------------------------------------");

		Fcm_fprint( handle_fichier, "");
		sprintf( buffer, "Mode VDI    : %ld Mo/s %ld Fps", gb_stats_mode_vdi_bp, gb_stats_mode_vdi_fps );
		Fcm_fprint( handle_fichier, buffer );
		sprintf( buffer, "Mode VRAM   : %ld Mo/s %ld Fps", gb_stats_mode_vram_bp, gb_stats_mode_vram_fps );
		Fcm_fprint( handle_fichier, buffer );
		sprintf( buffer, "Mode ST RAM : %ld Mo/s %ld Fps", gb_stats_mode_stram_bp, gb_stats_mode_stram_fps );
		Fcm_fprint( handle_fichier, buffer );
		sprintf( buffer, "Mode TT RAM : %ld Mo/s %ld Fps", gb_stats_mode_ttram_bp, gb_stats_mode_ttram_fps );
		Fcm_fprint( handle_fichier, buffer );
		Fcm_fprint( handle_fichier, "");
		Fcm_fprint( handle_fichier, "");
*/

		Fcm_fprint( handle_fichier, "Bench vro_cpyfm(mode 3):");
		Fcm_fprint( handle_fichier, "-----------------------------------------");

		Fcm_fprint( handle_fichier, "");
		sprintf( buffer, "ST Ram -> Ecran  : %ld Mo/s", gb_stats_stram_ecran );
		Fcm_fprint( handle_fichier, buffer );
		sprintf( buffer, "TT Ram -> Ecran  : %ld Mo/s", gb_stats_ttram_ecran );
		Fcm_fprint( handle_fichier, buffer );
		sprintf( buffer, "VDI    -> Ecran  : %ld Mo/s", gb_stats_vdi_ecran );
		Fcm_fprint( handle_fichier, buffer );

		sprintf( buffer, "ST Ram -> ST Ram : %ld Mo/s", gb_stats_stram_stram );
		Fcm_fprint( handle_fichier, buffer );
		sprintf( buffer, "TT Ram -> TT Ram : %ld Mo/s", gb_stats_ttram_ttram );
		Fcm_fprint( handle_fichier, buffer );
		sprintf( buffer, "VDI    -> VDI    : %ld Mo/s (handle application)", gb_stats_vdi_vdi );
		Fcm_fprint( handle_fichier, buffer );
		sprintf( buffer, "VDI    -> VDI    : %ld Mo/s (handle offscreen)", gb_stats_vdi_vdi2 );
		Fcm_fprint( handle_fichier, buffer );
		sprintf( buffer, "Ecran  -> Ecran  : %ld Mo/s", gb_stats_ecran_ecran );
		Fcm_fprint( handle_fichier, buffer );
		Fcm_fprint( handle_fichier, "");
		Fcm_fprint( handle_fichier, "");




		Fcm_fprint( handle_fichier, "Adresse buffer:");
		Fcm_fprint( handle_fichier, "-----------------------------------------");
		Fcm_fprint( handle_fichier, "* Mode VDI *");

		sprintf( buffer, "Offscreen = $%08lx - Handle VDI = %3d", surface_offscreen_vdi.adresse_buffer, surface_offscreen_vdi.handle_offscreen );
		Fcm_fprint( handle_fichier, buffer );

		sprintf( buffer,"Fond      = $%08lx - Handle VDI = %3d", surface_fond.adresse_buffer, surface_fond.handle_offscreen );
		Fcm_fprint( handle_fichier, buffer );

		{
			int16 idx;

			for( idx=0; idx<7; idx++)
			{
				sprintf( buffer,"BAR%d      = $%08lx - Handle VDI = %3d", idx, surface_bar[idx].adresse_buffer, surface_bar[idx].handle_offscreen );
				Fcm_fprint( handle_fichier, buffer );
			}
		}

		sprintf( buffer,"Bee       = $%08lx - Handle VDI = %3d", surface_bee.adresse_buffer, surface_bee.handle_offscreen );
		Fcm_fprint( handle_fichier, buffer );

		sprintf( buffer,"Bee mask  = $%08lx - Handle VDI = %3d", surface_bee_mask.adresse_buffer, surface_bee_mask.handle_offscreen );
		Fcm_fprint( handle_fichier, buffer );






		Fcm_fprint( handle_fichier, "");
		Fcm_fprint( handle_fichier, "* Mode ST RAM *");


		sprintf( buffer,"Offscreen = $%08lx", surface_offscreen_stram.adresse_buffer );
		Fcm_fprint( handle_fichier, buffer );

		sprintf( buffer,"Fond      = $%08lx", surface_fond_stram.adresse_buffer );
		Fcm_fprint( handle_fichier, buffer );

		{
			int16 idx;

			for( idx=0; idx<7; idx++)
			{
				sprintf( buffer,"Bar%d      = $%08lx", idx, surface_bar_stram[idx].adresse_buffer );
				Fcm_fprint( handle_fichier, buffer );
			}
		}

		sprintf( buffer,"Bee       = $%08lx", surface_bee_stram.adresse_buffer );
		Fcm_fprint( handle_fichier, buffer );

		sprintf( buffer,"Bee mask  = $%08lx", surface_bee_mask_stram.adresse_buffer );
		Fcm_fprint( handle_fichier, buffer );






		Fcm_fprint( handle_fichier, "");
		Fcm_fprint( handle_fichier, "* Mode TT RAM *");


		sprintf( buffer,"Offscreen = $%08lx", surface_offscreen_ttram.adresse_buffer );
		Fcm_fprint( handle_fichier, buffer );

		sprintf( buffer,"Fond      = $%08lx", surface_fond_ttram.adresse_buffer );
		Fcm_fprint( handle_fichier, buffer );

		{
			int16 idx;

			for( idx=0; idx<7; idx++)
			{
				sprintf( buffer,"Bar%d      = $%08lx", idx, surface_bar_ttram[idx].adresse_buffer );
				Fcm_fprint( handle_fichier, buffer );
			}
		}

		sprintf( buffer,"Bee       = $%08lx", surface_bee_ttram.adresse_buffer );
		Fcm_fprint( handle_fichier, buffer );

		sprintf( buffer,"Bee mask  = $%08lx", surface_bee_mask_ttram.adresse_buffer );
		Fcm_fprint( handle_fichier, buffer );





		Fcm_fprint( handle_fichier, "");





		/* ---------------------------------------------- */
		/* Bas de page du fichier de Configuration        */
		/* ---------------------------------------------- */
		Fcm_fprint( handle_fichier, "");
		Fcm_fprint( handle_fichier, "-= Renaissance "PRG_ANNEE" =-");
		Fcm_fprint( handle_fichier, "");




		{
			int16 reponse;

			reponse=Fclose( handle_fichier );

			if(reponse<0)
			{
				#ifdef LOG_FILE
				sprintf( buf_log, CRLF"Erreur durant la sauvegarde du fichier (err=%d)."CRLF, reponse);
				log_print(FALSE);
				#endif
				affiche_error( reponse );
			}
		}
	}
	else
	{
		#ifdef LOG_FILE
		sprintf( buf_log, "Erreur (%d) durant le cr‚ation du fichier"CRLF, handle_fichier);
		log_print(FALSE);
		#endif
		affiche_error( handle_fichier );
	}


	return;


}

