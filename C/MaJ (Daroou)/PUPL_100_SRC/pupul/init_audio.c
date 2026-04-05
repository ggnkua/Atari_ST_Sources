/* **[Pupul]******************** */
/* *                           * */
/* * 09/09/2014 MaJ 24/02/2015 * */
/* ***************************** */



//#include "../fonction/coeur/coeur_define.c"

#include "set_mod_config.c"


#define TAILLE_CHEMIN_MOD   ((TAILLE_CHEMIN_DATA)+(FCM_TAILLE_FICHIER))



/* prototype */
int32 init_audio( void );




/* Fonction */
int32 init_audio( void )
{


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# init_audio()"CRLF);
	log_print(FALSE);
	#endif


	/* ------------------------ */
	/* On initialise la LDG MOD */ 
	/* ------------------------ */
	{
		uint32 mod_interrupt;

		if( mod_init( &mod_interrupt ) != 0 )
		{
			return(APPLI_ERROR_LDG_MOD_INIT);
		}
	}




	/* ----------------------------- */
	/* La LDG MOD est op‚rationnelle */
	/* On charge le MOD              */
	/* ----------------------------- */

	{
		char	mon_chemin[TAILLE_CHEMIN_MOD];
		int32   mod_file_size;


		if( (strlen(chemin_data) + strlen("CYBERNO2.MOD")) > TAILLE_CHEMIN_MOD )
		{
			return(APPLI_ERROR_MOD_PATH_OVER);
		}

		strcpy( mon_chemin, chemin_data );
		strcat( mon_chemin, "CYBERNO2.MOD" );


		mod_file_size = Fcm_file_size(mon_chemin);


		if( mod_file_size<0 )
		{
			/* erreur GEMDOS */
			return(APPLI_ERROR_MOD_SIZE);
		}


		adr_buffer_MOD = Fcm_reserve_ram( mod_file_size, MX_PREFSTRAM );


		if( adr_buffer_MOD==FALSE )
		{
			/* echec reservation ram */
			return( APPLI_ERROR_RESERVE_RAM );
		}


		{
			int32 number_octet_load;


			number_octet_load = Fcm_bload( mon_chemin,(char *)adr_buffer_MOD, 0, mod_file_size);

			if( number_octet_load != mod_file_size  )
			{
				/* echec chargement des donn‚es */
				return( APPLI_ERROR_LOAD_MOD );
			}
		}
	}



	/* Configuration de la fr‚quence et du mode d'alimentation de MOD.LDG */
	set_mod_config();


	return 0L;


}


#undef TAILLE_CHEMIN_MOD

