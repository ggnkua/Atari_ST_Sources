/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 12/12/2003 MaJ 06/03/2024 * */
/* ***************************** */



/*
 * Vieille fonction utilisé par PaulaNG si les *.MOD
 * y sont associés.
 *
 * A revoir un jour... Si j'utilise à nouveau.
 *
 */


void Fcm_gestion_app_arg( const int argc, char **argv )
{
	/* Conversions des paramŠtres App_ARG en VA_START 
	 *
	 * variables globales:
	 *
	 * int16  ARGV_nombre_argument;
	 * char* ARGV_pt_argument[ARGV_MAX_ARGUMENT];
	 * uint32 ARGV_adr_buffer;
	 *
	 */

	FCM_LOG_PRINT("# Lecture message ArgV[]");
	FCM_LOG_PRINT1("  %d paramŠtres", argc);


#ifdef LOG_FILE
	if( argc > 1 )
	{
		int16 idx;

		for( idx=0; idx < argc; idx++ )
		{
			sprintf( buf_log, "- Argv[%d]=%s"CRLF, idx, argv[idx] );
			log_print( FALSE );
		}
	}
#endif


	if( argc > 1 )
	{
		int idx;
		uint16 taille_memoire;

		/* Au moins 1 argument transmis au programme   */
		/* on les stocke dans un buffer et on s'envoie */
		/* un message VA_START indiquant qu'il s'agit  */
		/* de fichier recu au lancement du programme   */


		/* On calcul la taille occup‚ par tous les arguments */
		taille_memoire = 0;
		for( idx=1; idx < argc ; idx++ )
		{
			FCM_LOG_PRINT2(" -> taille argv[%d]=%ld", idx, strlen(argv[idx]) );

			taille_memoire = taille_memoire + strlen( argv[idx] );
		}

		/* N'oublions pas les NUL bytes de fin de chaque chaine */
		taille_memoire = taille_memoire + (argc * 1);

		FCM_LOG_PRINT1(" - m‚moire n‚cessaire pour stocker les messages: %d", taille_memoire);

		/* On ajoute notre identificateur '_APP_ARGV_' */
		taille_memoire = taille_memoire + 10 + 1;


		ARGV_adr_buffer = Fcm_reserve_ram( (int32)taille_memoire, MX_PREFTTRAM );

		if( ARGV_adr_buffer == FALSE )
		{
			Fcm_affiche_alerte( DATA_MODE_COEUR, ALC_NO_MORE_RAM, 0 );

			return;
		}


		/* On enregistre les ARGV dans notre buffer */
		{
			char *pt_buffer_argv = (char *)ARGV_adr_buffer;


			strcpy( pt_buffer_argv, "_APP_ARGV_" );
			pt_buffer_argv = pt_buffer_argv + (strlen( pt_buffer_argv ) + 1);

			ARGV_nombre_argument = 0;

			for( idx=1; idx < argc; idx++ )
			{
				strcpy( pt_buffer_argv, argv[idx] );

				ARGV_pt_argument[(idx - 1)] = pt_buffer_argv;
				ARGV_nombre_argument++;

				pt_buffer_argv = pt_buffer_argv + ( strlen( argv[idx] ) + 1 );

				if( idx == ARGV_MAX_ARGUMENT )
				{
					FCM_LOG_PRINT1(" - Seulement %d arguments m‚morisables, contactez l'auteur pour augmenter cette capacit‚e", ARGV_MAX_ARGUMENT);

					break;
				}
			}

			if( (uint32)pt_buffer_argv > (ARGV_adr_buffer + taille_memoire) )
			{
				FCM_LOG_PRINT(" - ERREUR !!! d‚bordement du buffer RAM !!! Plantage certain … venir...");

				return;
			}
		}


		FCM_LOG_PRINT(" -> Envoie du message VA_START");


		buffer_aes[0] = VA_START;
		buffer_aes[1] = ap_id;
		buffer_aes[2] = 0;
		buffer_aes[3] = (int16)(ARGV_adr_buffer >> 16    );
		buffer_aes[4] = (int16)(ARGV_adr_buffer &  0xFFFF);
		buffer_aes[5] = 0;
		buffer_aes[6] = 0;
		buffer_aes[7] = 0;
		appl_write( ap_id, 16, &buffer_aes );
	}


	return;

}

