/* **[Fonction Commune]******** */
/* *                          * */
/* * Init AES et VDI          * */
/* * 11/08/2003 :: 07/01/2015 * */
/* **************************** */



/* Prototype */
int16 Fcm_init_AES_VDI( void );



/* Fonction */
int16 Fcm_init_AES_VDI( void )
{
	int16  work_in[20]={1,1,1,1,1,1,1,1,1,1,2,0,0,0,0,0,0,0,0,0};
	int16  work_out[280];
	int16  dummy;



	#ifdef LOG_FILE
	sprintf( buf_log, "  ## Fcm_init_AES_VDI()"CRLF );
	log_print( FALSE );
	#endif


	/* on demande a l'AES quel est notre numero d'identification */
	#ifdef LOG_FILE
	sprintf( buf_log, "  - Appl_Init()"CRLF );
	log_print( FALSE );
	#endif


	ap_id=appl_init();	/* Standard AES appl_init() */


	#ifdef LOG_FILE
	sprintf( buf_log, "  - Application ID=%d (AES)"CRLF, ap_id );
	log_print( FALSE );
	#endif


	if(ap_id<0)
	{
		form_alert(1,"[3]["PRG_NOM"| |Ouverture session AES impossible|Veuillez fermer une application|dont vous n'avez plus besoin.][  Quitter  ]");
		return(FALSE);
	}



	/* on veut dessiner sur l'ecran, on recupere */
	/* le num‚ro du p‚riph‚rique ‚cran           */
	vdihandle = graf_handle( &dummy, &dummy, &dummy, &dummy );


	#ifdef LOG_FILE
	sprintf(buf_log, "  - AES Graf_handle=%d"CRLF, vdihandle);
	log_print(FALSE);
	#endif


	/* initialisation de la station virtuelle VDI */
	/* Vdihandle recoit cette fois le Handle VDI  */
	v_opnvwk( work_in, &vdihandle, work_out );


	#ifdef LOG_FILE
	sprintf(buf_log, "  - Handle VDI=%d"CRLF""CRLF, vdihandle);
	log_print(FALSE);
	#endif


	if( vdihandle <= 0 )
	{
		form_alert(1,"[3]["PRG_NOM"| |Ouverture station VDI impossible|Veuillez fermer une application|dont vous n'avez plus besoin.][  Quitter  ]");
		appl_exit();	/* on previent l'AES de ne plus s'occuper*/
						/* de nous, he oui d‚j… :(               */
		return(FALSE);
	}


	return(TRUE);


}

