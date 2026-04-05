/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 11/08/2003 MaJ 03/03/2024 * */
/* ***************************** */



/* resoudre probleme work_in[0] = 2 + Getrez(); !!! */


int16 Fcm_init_AES_VDI( void )
{
	int16  work_in[20]={1,1,1,1,1,1,1,1,1,1,2,0,0,0,0,0,0,0,0,0};
	int16  work_out[280];


	FCM_LOG_PRINT(CRLF"# Fcm_init_AES_VDI()");


	/* on demande a l'AES quel est notre numero d'identification */
	ap_id = appl_init();	/* Standard AES appl_init() */

	FCM_LOG_PRINT1("- Application ID=%d (AES)", ap_id);


	if( ap_id < 0 )
	{
		form_alert(1,"[3]["PRG_NOM"| |Ouverture session AES impossible|Veuillez fermer une application|dont vous n'avez plus besoin.][  Quitter  ]");
		return( FALSE );
	}


	/* on veut dessiner sur l'ecran, on recupere */
	/* le num‚ro du p‚riph‚rique ‚cran           */
	vdihandle = graf_handle( &Fcm_screen.gr_hwchar, &Fcm_screen.gr_hhchar, &Fcm_screen.gr_hwbox, &Fcm_screen.gr_hhbox );

	FCM_LOG_PRINT5("- AES Graf_handle=%d (gr_hwcar=%d, gr_hhcar=%d, gr_hwbox=%d, gr_hhbox=%d)", vdihandle,Fcm_screen.gr_hwchar, Fcm_screen.gr_hhchar, Fcm_screen.gr_hwbox, Fcm_screen.gr_hhbox);


	/* http://toshyp.atari.org/en/00700a.html#v_opnvwk dit d'utilser   work_in[0] = 2 + Getrez();    */
	/* http://toshyp.atari.org/en/Screen_functions.html#Getrez  dit de ne pas utilser   work_in[0] = 2 + Getrez();   */
	/* https://www.atari-forum.com/viewtopic.php?p=413455#p413455 dit d'utiliser '1' */

	/* The device identification code for the display device must be specified as Getrez() + 2 for */
	/* all VDI features to work correctly. The Atari Compendium 7.4 VDI */
	/* For screen devices you should normally use the value Getrez() + 2, however, a value of 1 is */
	/* acceptable if not using any loaded fonts. The Atari Compendium 7.61 v_opnvwk() */


/*	work_in[0] = Getrez() + 2;*/
/*	work_in[0] = 2 */               /* beaucoup utilise 2 */
	work_in[0] = 1;                 /*  1 => current resolution d'apres doc NVDI 4 */

	FCM_LOG_PRINT2("- v_opnvwk() : work_in[0]=%d (Getrez()=%d) ", work_in[0], Getrez());
	

	/* initialisation de la station virtuelle VDI */
	/* Vdihandle recoit cette fois le Handle VDI  */
	v_opnvwk( work_in, &vdihandle, work_out );

	FCM_LOG_PRINT1("- Handle VDI=%d"CRLF""CRLF, vdihandle);


	if( vdihandle <= 0 )
	{
		form_alert(1,"[3]["PRG_NOM"| |Ouverture station VDI impossible|Veuillez fermer une application|dont vous n'avez plus besoin.][  Quitter  ]");
		appl_exit();	/* on previent l'AES de ne plus s'occuper*/
						/* de nous, he oui d‚j… :(               */
		return(FALSE);
	}


	Fcm_mfdb_ecran.fd_addr = 0L;


	return(TRUE);


}

