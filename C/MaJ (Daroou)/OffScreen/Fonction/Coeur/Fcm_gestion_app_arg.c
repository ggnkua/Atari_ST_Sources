/* **[Fonction commune]******** */
/* *                          * */
/* * 12/12/2003 = 06/04/2013  * */
/* **************************** */


#include <AV.H>
#include "Fcm_Reserve_Ram.c"



/* Prototypes */
VOID Fcm_gestion_app_arg( const int argc, char **argv );


/* Fonction */
VOID Fcm_gestion_app_arg( const int argc, char **argv )
{

	/* Conversions des paramŠtres App_ARG en VA_START 
	 *
	 * variables globales:
	 *
	 * WORD  ARGV_nombre_argument;
	 * CHAR* ARGV_pt_argument[ARGV_MAX_ARGUMENT];
	 * ULONG ARGV_adr_buffer;
	 *
	 */




	#ifdef LOG_FILE
	strcpy( buf_log, "# Lecture message ArgV[]"CRLF);
	log_print( FALSE );

	sprintf( buf_log, "  %d paramŠtres"CRLF, argc);
	log_print( FALSE );

	if( argc>1 )
	{
		WORD index;

		for( index=0; index<argc; index++)
		{
			sprintf( buf_log, "- Argv[%d]=%s"CRLF, index, argv[index] );
			log_print( FALSE );
		}
	}
	#endif







	if( argc>1 )
	{
		int index;
		WORD taille_memoire;

		/* Au moins 1 argument transmis au programme   */
		/* on les stocke dans un buffer et on s'envoie */
		/* un message VA_START indiquant qu'il s'agit  */
		/* de fichier recu au lancement du programme   */


		/* On calcul la taille occup‚ par tous les arguments */
		taille_memoire=0;
		for( index=1; index<argc ; index++)
		{
			#ifdef LOG_FILE
			sprintf( buf_log, " -> taille argv[%d]=%ld"CRLF, index, strlen(argv[index]) );
			log_print( FALSE );
			#endif

			taille_memoire=taille_memoire+strlen(argv[index]);
		}

		/* N'oublions pas les NUL bytes de fin de chaque chaine */
		taille_memoire=taille_memoire + (argc*1);


		#ifdef LOG_FILE
		sprintf( buf_log, " - m‚moire n‚cessaire pour stocker les messages: %d"CRLF, taille_memoire);
		log_print( FALSE );
		#endif


		/* On ajoute notre identificateur '_APP_ARGV_' */
		taille_memoire=taille_memoire+10+1;


		ARGV_adr_buffer=Fcm_reserve_ram( taille_memoire, MX_PREFTTRAM );

		if( ARGV_adr_buffer==FALSE )
		{
			int16 dummy;

/*			Fcm_form_alerte( 0, ALT_NO_MORE_RAM );*/
			Fcm_affiche_alerte( DATA_MODE_COEUR, ALC_NO_MORE_RAM, &dummy );

			return;
		}


		/* On enregistre les ARGV dans notre buffer */

		{
			CHAR *pt_buffer_argv=(CHAR *)ARGV_adr_buffer;


			strcpy( pt_buffer_argv, "_APP_ARGV_" );
			pt_buffer_argv=pt_buffer_argv+(strlen(pt_buffer_argv)+1);

			ARGV_nombre_argument=0;

			for( index=1; index<argc; index++ )
			{
				strcpy( pt_buffer_argv, argv[index] );

				ARGV_pt_argument[(index-1)]=pt_buffer_argv;
				ARGV_nombre_argument++;

				pt_buffer_argv=pt_buffer_argv+( strlen(argv[index]) + 1 );

				if( index==ARGV_MAX_ARGUMENT )
				{
					#ifdef LOG_FILE
					sprintf( buf_log, " - Seulement %d arguments m‚morisables, contactez l'auteur pour augmenter cette capacit‚e"CRLF, ARGV_MAX_ARGUMENT);
					log_print( FALSE );
					#endif
					break;
				}
			}

			if( (ULONG)pt_buffer_argv > (ARGV_adr_buffer+taille_memoire) )
			{
/*sprintf(texte,"ArgV[] - ERREUR !!! d‚bordement du buffer RAM !!! Plantage certain … venir..."  );
v_gtext(vdihandle,4*8,2*16,texte);*/
					#ifdef LOG_FILE
					sprintf( buf_log, " - ERREUR !!! d‚bordement du buffer RAM !!! Plantage certain … venir..."CRLF);
					log_print( FALSE );
					#endif
					return;
			}

		}


		#ifdef LOG_FILE
		strcpy( buf_log, " -> Envoie du message VA_START"CRLF);
		log_print( FALSE );
		#endif

		buffer_aes[0]=VA_START;
		buffer_aes[1]=ap_id;
		buffer_aes[2]=0;
		buffer_aes[3]=(UWORD)(ARGV_adr_buffer >> 16    );
		buffer_aes[4]=(UWORD)(ARGV_adr_buffer &  0xFFFF);
		buffer_aes[5]=0;
		buffer_aes[6]=0;
		buffer_aes[7]=0;
		appl_write( ap_id, 16, &buffer_aes );

	}


	return;


}

