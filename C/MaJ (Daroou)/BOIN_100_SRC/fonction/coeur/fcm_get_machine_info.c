/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 24/05/2003 MaJ 03/03/2024  * */
/* ****************************** */



/*
 *
 * 26/06/2020: supression des doublons pour la detection Fcm_systeme.machine_modele
 * 21/06/2020: ajout Fcm_systeme.video_ram_type: type de RAM par défaut pour les buffers vidéos
 *
 */


#include "fcm_machine_id.h"


void Fcm_get_machine_info(void)
{

	FCM_LOG_PRINT("# Fcm_get_machine_info()");


	Fcm_systeme.magic_os  = FALSE;
	Fcm_systeme.mint_os   = FALSE;
	Fcm_systeme.aes_multi = FALSE;

	Fcm_systeme.machine_type    = -1;
	Fcm_systeme.machine_subtype = -1;

	Fcm_systeme.machine_modele  = FCM_MACHINE_INCONNU;



	if( Fcm_cookies_exist(COOKIE_MagX) )
	{
		Fcm_systeme.magic_os = TRUE;

		FCM_LOG_PRINT( "- MagiC d‚tect‚" );
	}
	else
	{
		FCM_LOG_PRINT( "- Cookie MagiC absent" );
	}


	if( Fcm_cookies_exist(COOKIE_MiNT) )
	{
		Fcm_systeme.mint_os = TRUE;

		FCM_LOG_PRINT( "- MiNT d‚tect‚" );
	}
	else
	{
		FCM_LOG_PRINT( "- Cookie MiNT absent" );
	}


	if( Fcm_systeme.magic_os  ||  Fcm_systeme.mint_os )
	{
		Fcm_systeme.aes_multi = TRUE;

		FCM_LOG_PRINT( "- Execution multi-tache" );
	}
	else
	{
		FCM_LOG_PRINT( "- Execution Mono-tache (ou OS multi-tache inconnu) => redraw desktop" );

		form_dial( 3,0,0,0,0,Fcm_screen.x_desktop,Fcm_screen.y_desktop,Fcm_screen.w_desktop,Fcm_screen.h_desktop);
	}


	Fcm_systeme.aes_version = _AESversion;  /* definition dans GEM.H */

	FCM_LOG_PRINT3("- AES version=%x.%x ($%x)", (Fcm_systeme.aes_version>>8), (Fcm_systeme.aes_version&0xff), Fcm_systeme.aes_version );


	/* Nombre d'appli simultanné (1:monotache, -1:multitache) */
	Fcm_systeme.aes_numapps = _AESnumapps;	/* definition dans GEM.H */

	FCM_LOG_PRINT1("- AES number application=%d", Fcm_systeme.aes_numapps );


	/* version du GEMDOS */
	{
		int16	dummy;

		dummy=Sversion();
		Fcm_systeme.gemdos_version = dummy >> 8;
		Fcm_systeme.gemdos_version = Fcm_systeme.gemdos_version + (dummy << 8);
	}

	FCM_LOG_PRINT1("- GEMDOS version=0.%d", Fcm_systeme.gemdos_version);


	/* PCI bios */
	{
		uint32 valeur_cookie;

		if( Fcm_get_cookies(COOKIE__PCI, &valeur_cookie) == 0 )
		{
			PCI_COOKIE *pt_cookie_pci;

			pt_cookie_pci = (PCI_COOKIE *)valeur_cookie;
			Fcm_systeme.pci_version = pt_cookie_pci->version;

			FCM_LOG_PRINT1("- Cookie _PCI=$%08lx", valeur_cookie);
			FCM_LOG_PRINT3("  _PCI version=%x.%02x ($%08lx)", (uint16)((pt_cookie_pci->version>>16)&0xffff), (uint16)(pt_cookie_pci->version&0xffff), pt_cookie_pci->version );
		}
		else
		{
			Fcm_systeme.pci_version = 0;

			FCM_LOG_PRINT( "- Cookie _PCI absent" );
		}
	}



	/* NVDI */
	{
		uint32 valeur_cookie;

		if( Fcm_get_cookies(COOKIE_NVDI, &valeur_cookie) == 0 )
		{
			NVDI_STRUCT *pt_cookie_nvdi;

			pt_cookie_nvdi = (NVDI_STRUCT *)valeur_cookie;
			Fcm_systeme.nvdi_version = pt_cookie_nvdi->nvdi_version;

			FCM_LOG_PRINT1("- Cookie NVDI=$%08lx", valeur_cookie);
			FCM_LOG_PRINT3("  NVDI version=%x.%02x ($%x)", Fcm_systeme.nvdi_version>>8, Fcm_systeme.nvdi_version&0xff, Fcm_systeme.nvdi_version );
		}
		else
		{
			Fcm_systeme.nvdi_version = 0;

			FCM_LOG_PRINT( "- Cookie NVDI absent" );
		}
	}



	/* SuyperVidel */
	{
		uint32 valeur_cookie;

		if( Fcm_get_cookies(COOKIE_SupV, &valeur_cookie) == 0 )
		{
			Fcm_systeme.supervidel = TRUE;

			FCM_LOG_PRINT1("- Cookie _SupV=$%08lx", valeur_cookie);
		}
		else
		{
			Fcm_systeme.supervidel = FALSE;

			FCM_LOG_PRINT( "- Cookie SupV absent" );
		}
	}



	/* _CPU */
	{
		int32 reponse;
		uint32 valeur_cookie;
		
		reponse=Fcm_get_cookies(COOKIE__CPU, &valeur_cookie);

		if( reponse==0 )
		{
			Fcm_systeme.cpu_type = (int16)(valeur_cookie & 0xffff);

			FCM_LOG_PRINT1("- Cookie _CPU=$%08lx", valeur_cookie);
			FCM_LOG_PRINT1("  CPU type=%ld", (int32)Fcm_systeme.cpu_type + 68000 );
		}
		else
		{
			Fcm_systeme.cpu_type = -1;

			FCM_LOG_PRINT( "- Cookie _CPU absent" );
		}
	}



	/* TOS langage avec cookie _AKP */
	{
		int32 reponse;
		uint32 valeur_cookie;
		
		reponse = Fcm_get_cookies(COOKIE__AKP, &valeur_cookie);

		if( reponse == 0 )
		{
			/* The low word indicates the language currently used by TOS  */
			/* for keyboard interpretation and alerts. high word reserved */
			/* Atari compendium 3.12 */
			/* 0xCC00 the country code used for display: fonts and language */
			/* 0x00CC the country code used for input: keyboard layout      */
			/* EmuTOS source country.c */
			Fcm_systeme.tos_langage = (int16)(valeur_cookie & 0xFFFF);

			FCM_LOG_PRINT1("- cookie _AKP & 0xFFFF = 0x%x", Fcm_systeme.tos_langage );
			FCM_LOG_PRINT1("  country code display fonts and language: %d (0=USA 1=Germany 2=France 3=England  etc...)", (Fcm_systeme.tos_langage>>8) & 0xff );
			FCM_LOG_PRINT1("  country code input keyboard layout: %d (idem)", (Fcm_systeme.tos_langage & 0xff) );

		}
		else
		{
			Fcm_systeme.tos_langage = -1;

			FCM_LOG_PRINT( "  - Cookie _AKP absent" );
		}
	}


	/* AES langage - compendium 6.49 */
	if( Fcm_systeme.aes_version >= 0x399 )
	{
		int16 aes_langage, dummy, reponse;

		reponse = appl_getinfo( 3, &aes_langage, &dummy, &dummy, &dummy );

		if( reponse == 1 )
		{
			Fcm_systeme.aes_langage = aes_langage;

			FCM_LOG_PRINT1("- AES langage %d ( apple_getinfo(3) ) (0=English 1=Germany 2=France 3=reserved  etc...)", aes_langage );
		}
		else
		{
			FCM_LOG_PRINT( "- apple_getinfo( 3 ) AES_LANGUAGE  reponse error" );
		}
	}



	/* Recherche TOS version */
	Fcm_systeme.tos_version = Fcm_get_tos_version();

	FCM_LOG_PRINT3("- TOS version=%x.%02x ($%x)", Fcm_systeme.tos_version>>8, Fcm_systeme.tos_version&0xff, Fcm_systeme.tos_version );


	/* Free RAM */
	if( Fcm_systeme.gemdos_version >= 0x19 )
	{
		/* Si Mxalloc() est support‚... */
		FCM_LOG_PRINT1("- ST RAM free : %ld ( Mxalloc(-1, MX_STRAM) )", Mxalloc(-1, MX_STRAM) );
		FCM_LOG_PRINT1("- TT RAM free : %ld ( Mxalloc(-1, MX_TTRAM) )", Mxalloc(-1, MX_TTRAM) );
	}
	FCM_LOG_PRINT1("-    RAM free : %ld ( Malloc(-1) , depend du flag PRG)", Malloc(-1) );


	/* extension No_BLOCK presente ? */
	Fcm_systeme.noblock = 0;

	if( Fcm_systeme.aes_version >= 0x399 )
	{
		int16 dummy, noblock, reponse;

		reponse = appl_getinfo(11,&dummy, &dummy, &dummy, &noblock);

		if( reponse == 1 )
		{
			Fcm_systeme.noblock = noblock;

			FCM_LOG_PRINT1("- AES NO BLOCK extension=%d ( appl_getinfo(11) parm4 )", Fcm_systeme.noblock );
		}
		else
		{
			FCM_LOG_PRINT( "- AES NO BLOCK extension appl_getinfo(11) ERREUR" );
		}
	}
	else
	{
		FCM_LOG_PRINT( "- AES NO BLOCK extension non disponible" );
	}


	/* -------------- */
	/* LDG installé ? */
	/* -------------- */
	{
		int32 reponse;
		uint32 valeur_cookie;
		
		reponse = Fcm_get_cookies(COOKIE_LDGM, &valeur_cookie);

		if( reponse == 0 )
		{
			LDG_INFOS *cookie_ldg;

			cookie_ldg = (LDG_INFOS *)valeur_cookie;

			Fcm_systeme.tsr_ldg_version = cookie_ldg->version;

			FCM_LOG_PRINT1("- TSR LDG installé: version $%x", cookie_ldg->version );
			FCM_LOG_PRINT1("  chemin LDG {%s}", cookie_ldg->path );
		}
		else
		{
			Fcm_systeme.tsr_ldg_version = -1;

			FCM_LOG_PRINT( "- TSR LDG non install‚ (cookie LDGM absent)" );
		}
	}


	/* ------------------------------------------------- */
	/* Quel modele d' Atari ?                            */
	/* ------------------------------------------------- */

	FCM_LOG_PRINT( CRLF"* detection modele Atari" );


	Fcm_systeme.machine_modele = FCM_MACHINE_INCONNU;

	{
		int32 reponse;
		uint32 valeur_cookie;
		
		reponse = Fcm_get_cookies(COOKIE__MCH, &valeur_cookie);

		if( reponse == 0 )
		{
			Fcm_systeme.machine_type    =  (int16)(valeur_cookie>>16) & 0xffff;
			Fcm_systeme.machine_subtype =  (int16) valeur_cookie      & 0xffff;

			FCM_LOG_PRINT1(" Cookie _MCH = 0x%08lx", valeur_cookie );
			FCM_LOG_PRINT2(" machine type:0x%04x machine subtype:0x%04x ", Fcm_systeme.machine_type, Fcm_systeme.machine_subtype );
		}
		else
		{
			Fcm_systeme.machine_type = -1;

			FCM_LOG_PRINT( " Cookie _MCH absent" );
		}


		if( Fcm_cookies_exist(COOKIE__MIL) )
		{
			Fcm_systeme.machine_modele = FCM_MACHINE_MILAN;

			FCM_LOG_PRINT( " Cookie _MIL present" );
		}


		if( Fcm_systeme.machine_type == 0   &&   Fcm_systeme.machine_subtype == 0 )
		{
			Fcm_systeme.machine_modele = FCM_MACHINE_ST;

			FCM_LOG_PRINT( " modele ST ou MegaST" );
		}


		if( Fcm_systeme.machine_type == 0   &&   Fcm_systeme.machine_subtype == 1 )
		{
			Fcm_systeme.machine_modele = FCM_MACHINE_STEMULATOR;

			FCM_LOG_PRINT( " modele STemulator" );
		}


		if( Fcm_systeme.machine_type == 1   &&   Fcm_systeme.machine_subtype == 0 )
		{
			Fcm_systeme.machine_modele = FCM_MACHINE_STE;

			FCM_LOG_PRINT( " modele STe" );
		}

		if( Fcm_systeme.machine_type == 1   &&   Fcm_systeme.machine_subtype == 0x10 )
		{
			Fcm_systeme.machine_modele = FCM_MACHINE_MEGA_STE;

			FCM_LOG_PRINT( " modele Mega STe" );
		}

		if( Fcm_systeme.machine_type == 2 )
		{
			Fcm_systeme.machine_modele = FCM_MACHINE_TT;

			FCM_LOG_PRINT( " modele TT" );
		}

		if( Fcm_systeme.machine_type == 3 )
		{
			Fcm_systeme.machine_modele = FCM_MACHINE_FALCON;

			FCM_LOG_PRINT( " modele Falcon" );
		}

		if( Fcm_systeme.machine_type == 4 )
		{
			Fcm_systeme.machine_modele = FCM_MACHINE_MILAN;

			FCM_LOG_PRINT( " modele Milan" );
		}

		if( Fcm_systeme.machine_type == 5 )
		{
			Fcm_systeme.machine_modele = FCM_MACHINE_ARANYM;

			FCM_LOG_PRINT( " modele Aranym" );
		}

		if( Fcm_systeme.machine_type == 3   &&   Fcm_cookies_exist(COOKIE__CF_) )
		{
			Fcm_systeme.machine_modele = FCM_MACHINE_FIREBEE;

			FCM_LOG_PRINT( " modele FireBee" );
		}

		if( Fcm_cookies_exist(COOKIE_hade) )
		{
			Fcm_systeme.machine_modele = FCM_MACHINE_HADES;

			FCM_LOG_PRINT( " modele Hades" );
		}

		if( (Fcm_systeme.machine_type == 0   ||   Fcm_systeme.machine_type == 2)   &&   Fcm_systeme.machine_subtype == 0x4d34 )
		{
			/* 0x4d34 => M4 => Medusa 40 ? */
			Fcm_systeme.machine_modele = FCM_MACHINE_MEDUSA;

			FCM_LOG_PRINT( " modele Medusa" );
		}



		if( Fcm_systeme.machine_modele == FCM_MACHINE_INCONNU )
		{
			if( Fcm_systeme.tos_version == 0x100 )
			{
				Fcm_systeme.machine_modele = FCM_MACHINE_ST;

				FCM_LOG_PRINT( " modele ST (TOS 1.00)" );
			}

			if( Fcm_systeme.tos_version == 0x102 )
			{
				Fcm_systeme.machine_modele = FCM_MACHINE_ST;

				FCM_LOG_PRINT( " modele STF ou MegaST (TOS 1.02)" );
			}

			if( Fcm_systeme.tos_version == 0x104 )
			{
				Fcm_systeme.machine_modele = FCM_MACHINE_ST;

				FCM_LOG_PRINT( " modele STFM ou STacy (TOS 1.04)" );
			}
		}


		if( Fcm_systeme.machine_modele == FCM_MACHINE_INCONNU )
		{
			FCM_LOG_PRINT( " modele non reconnu !" );
		}
	}





	/* ---------------------- */
	/* Quel system sonore ?   */
	/* ---------------------- */

	FCM_LOG_PRINT( CRLF"* detection systeme sonore" );

	Fcm_systeme.xbios_sound      = FALSE;
	Fcm_systeme.xbios_sound_mode = 0;


	if( Fcm_systeme.machine_modele == FCM_MACHINE_FALCON )
	{
		Fcm_systeme.xbios_sound      = TRUE;
		Fcm_systeme.xbios_sound_mode = XBIOS_SOUND_MODE_FALCON;

		FCM_LOG_PRINT( " Falcon d‚tect‚" );
	}

	if( Fcm_systeme.machine_modele == FCM_MACHINE_ARANYM )
	{
		Fcm_systeme.xbios_sound      = TRUE;
		Fcm_systeme.xbios_sound_mode = XBIOS_SOUND_MODE_FALCON;

		FCM_LOG_PRINT( " ARAnyM d‚tect‚" );
	}

	if( Fcm_cookies_exist(COOKIE_McSn) )
	{
		Fcm_systeme.xbios_sound      = TRUE;
		Fcm_systeme.xbios_sound_mode = XBIOS_SOUND_MODE_FALCON;

		FCM_LOG_PRINT( " Cookie McSn pr‚sent" );
	}

	if( Fcm_cookies_exist(COOKIE_GSXB) )
	{
		Fcm_systeme.xbios_sound      = TRUE;
		Fcm_systeme.xbios_sound_mode = XBIOS_SOUND_MODE_FALCON;

		FCM_LOG_PRINT( " Cookie GSXB pr‚sent" );
	}

	if( Fcm_cookies_exist(COOKIE_STFA) )
	{
		Fcm_systeme.xbios_sound      = TRUE;
		Fcm_systeme.xbios_sound_mode = XBIOS_SOUND_MODE_STE_TT;

		FCM_LOG_PRINT( " Cookie STFA pr‚sent" );
	}


	{
		int32 reponse;
		uint32 valeur_cookie;
		
		reponse = Fcm_get_cookies(COOKIE__SND, &valeur_cookie);

		if( reponse == 0 )
		{
			Fcm_systeme.snd_cookie = (int32)valeur_cookie;

			FCM_LOG_PRINT1(" Cookie _SND = $%08lx", valeur_cookie );


			if( Fcm_systeme.snd_cookie  &  (1<<0) ) /* bit 0 */
			{
				FCM_LOG_PRINT( "   [b0] Sound chip" );
			}

			if( Fcm_systeme.snd_cookie  &  (1<<1)) /* bit 1 */
			{
				FCM_LOG_PRINT( "   [b1] Stereo DMA sound (as with STE and TT)" );
			}

			if( Fcm_systeme.snd_cookie  &  (1<<2) ) /* bit 2 */
			{
				FCM_LOG_PRINT( "   [b2] CODEC" );
			}

			if( Fcm_systeme.snd_cookie  &  (1<<3) ) /* bit 3 */
			{
				FCM_LOG_PRINT( "   [b3] Digital signal processor (DSP)" );
			}

			if( Fcm_systeme.snd_cookie  &  (1<<4) ) /* bit 4 */
			{
				FCM_LOG_PRINT( "   [b4] Multiplexer connection matrix" );
			}

			if( Fcm_systeme.snd_cookie  &  (1<<5) ) /* bit 5 */
			{
				FCM_LOG_PRINT( "   [b5] Extended XBIOS routines (Milan, GSXB)" );

				Fcm_systeme.xbios_sound      = TRUE;
				Fcm_systeme.xbios_sound_mode = XBIOS_SOUND_MODE_FALCON;
			}
		}
		else
		{
			Fcm_systeme.snd_cookie = -1;

			FCM_LOG_PRINT( " Cookie _SND absent" );
		}
	}


	FCM_LOG_PRINT( CRLF" Resultat:" );

	if( Fcm_systeme.xbios_sound == TRUE )
	{
		FCM_LOG_PRINT( "  => XBIOS Falcon sound compatible" );
	}
	else
	{
		FCM_LOG_PRINT( "  => pas de son XBIOS Falcon sound compatible" );
	}

	if( Fcm_systeme.xbios_sound_mode == XBIOS_SOUND_MODE_STE_TT )
	{
		FCM_LOG_PRINT( "  => XBIOS sound mode STE/TT compatible" );
	}

	if( Fcm_systeme.xbios_sound_mode == XBIOS_SOUND_MODE_FALCON )
	{
		FCM_LOG_PRINT( "  => XBIOS sound mode Falcon compatible" );
	}




	FCM_LOG_PRINT( CRLF"* detection type RAM pour transfert video" );

	/* Type de RAM préférentiel suivant le type de micro */
	Fcm_systeme.video_ram_type = MX_STRAM;

	if( Fcm_systeme.machine_modele > FCM_MACHINE_FALCON )
	{
		Fcm_systeme.video_ram_type = MX_PREFTTRAM;

		/* Sur CT060, ST ram ou Fast ram ? si radeon, fast ram, à completer */
	}


	FCM_LOG_PRINT3("  video_ram_type=%d (%d=MX_STRAM %d=MX_PREFTTRAM)", Fcm_systeme.video_ram_type, MX_STRAM, MX_PREFTTRAM );

	FCM_LOG_PRINT("# FIN Fcm_get_machine_info()"CRLF""CRLF);

	return;


}

