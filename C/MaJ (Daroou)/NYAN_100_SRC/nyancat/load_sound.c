/* **[NyanCat]****************** */
/* *                           * */
/* * 17/05/2018 MaJ 24/05/2018 * */
/* ***************************** */



#include "../fonction/include/falcon.h"
#include "../fonction/audio/avr.h"

#include "exit_sound.c"



#define TAILLE_CHEMIN_AVR   ( (FCM_TAILLE_CHEMIN)+(16) )  /* 16 octets pour le nom de fichier 'nyancat.avr' */
#define FILE_SONG    "nyancat.avr"



/* prototype */
int32 load_sound( void );



/* Fonction */
int32 load_sound( void )
{
	char          mon_chemin[ TAILLE_CHEMIN_AVR ];
	int32         taille_fichier;
	s_AVR_HEADER *musique_header;





	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# load_sound()"CRLF);
	log_print(FALSE);
	#endif



	if( (strlen(chemin_data)+strlen(FILE_SONG)) > TAILLE_CHEMIN_AVR )
	{
		return(APPLI_ERROR_DATA_PATH_OVER);
	}


	strcpy( mon_chemin, chemin_data );
	strcat( mon_chemin, FILE_SONG );

	if( Fcm_file_exist( mon_chemin ) != TRUE )
	{
		return(APPLI_ERROR_AVR_NOT_FOUND);
	}

	taille_fichier = Fcm_file_size(mon_chemin);


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"  Taille fichier : %ld"CRLF, taille_fichier );
	log_print(FALSE);
	#endif


	global_adr_buffer_AVR = Fcm_reserve_ram( ((taille_fichier + 3) & (int32)0xFFFFFFFC), MX_STRAM/*|MX_MPROT|MX_READABLE*/ );
	/*|MX_MPROT|MX_READABLE fait planter sur falcon tos 4.02 4.04 (Hatari)*/


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"  global_adr_buffer_AVR : 0x%lx"CRLF, global_adr_buffer_AVR );
	log_print(FALSE);
	#endif


	if( global_adr_buffer_AVR == FALSE )
	{
		/* echec reservation ram */
		return( APPLI_ERROR_RESERVE_RAM_SOUND );
	}





	{
		int32 number_octet_load;


		number_octet_load = Fcm_bload( mon_chemin, (char *)global_adr_buffer_AVR, 0, taille_fichier);

		if( number_octet_load != taille_fichier  )
		{
			exit_sound(); /* liberation Ram */
			return( APPLI_ERROR_LOAD_AVR );
		}
	}



	musique_header = (s_AVR_HEADER *)global_adr_buffer_AVR;


	global_musique.adresse_start = global_adr_buffer_AVR + 128;
	global_musique.adresse_end   = global_adr_buffer_AVR + 128 + (uint32)musique_header->size;

	if( (global_musique.adresse_end - global_musique.adresse_start) > (uint32)taille_fichier )
	{
		exit_sound(); /* liberation Ram */
		return( APPLI_ERROR_AVR_SIZE );
	}

	global_musique.adresse_loop_start = global_musique.adresse_start + (uint32)musique_header->lbeg;
	global_musique.adresse_loop_end   = global_musique.adresse_start + (uint32)musique_header->lend;




	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"  global_musique.adresse_start : %ld"CRLF, global_musique.adresse_start );
	log_print(FALSE);
	sprintf( buf_log, "  global_musique.adresse_end   : %ld"CRLF, global_musique.adresse_end );
	log_print(FALSE);
	sprintf( buf_log, CRLF"  global_musique.adresse_loop_start : %ld"CRLF, global_musique.adresse_loop_start );
	log_print(FALSE);
	sprintf( buf_log, "  global_musique.adresse_loop_end   : %ld"CRLF, global_musique.adresse_loop_end );
	log_print(FALSE);
	#endif



	return 0L;


}


#undef TAILLE_CHEMIN_AVR

