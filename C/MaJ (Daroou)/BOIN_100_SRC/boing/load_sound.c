/* **[Boing]******************** */
/* *                           * */
/* * 20/09/2015 MaJ 30/07/2020 * */
/* ***************************** */



#include "../fonction/include/falcon.h"
#include "../fonction/audio/avr.h"

#define TAILLE_CHEMIN_AVR   ( (TAILLE_CHEMIN_DATA)+(16) )
#define FILE_BOING_GAUCHE    "boing_m.avr"
#define FILE_BOING_DROITE    "boing_m.avr"
#define FILE_BOING_SOL       "boing_s.avr"

#define AVR_VOIX_GAUCHE (0)
#define AVR_VOIX_DROITE (1)


/*
 * Variables globale utilisée (boing_global.h)
 * -------------------------------------------
 * uint32 global_adr_buffer_boing_gauche
 * uint32 global_adr_buffer_boing_droite
 * uint32 global_adr_buffer_boing_sol
 *
 * s_MUSIQUE_PLAY  global_son_gauche;
 * s_MUSIQUE_PLAY  global_son_droite;
 * s_MUSIQUE_PLAY  global_son_sol;
 *
 */



/* prototype */
int32 load_sound( void );



/* Fonction */
int32 load_sound( void )
{
	char          mon_chemin[ TAILLE_CHEMIN_AVR ];
	int32         taille_fichier;
	s_AVR_HEADER *musique_header;
	uint16        ram_type;


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"# load_sound()"CRLF);
	log_print(FALSE);
	#endif



	ram_type = MX_STRAM;
	/*|MX_MPROT|MX_READABLE fait planter sur falcon tos 4.02 4.04 (Hatari)*/
	if( Fcm_systeme.machine_modele == FCM_MACHINE_MILAN )
	{
		/* Sur Mon Milan, si les sons sont chargés en ST RAM, une utilisation    */
		/* intensivement répétitive fait planter le Milan, après une vingtaine   */
		/* d'itération. En les chargeant en TT RAM, plus aucun problème, un test */
		/* a été fait sur 32.000 itérations avec reset du DMA à chaque fois.     */
		/*ram_type = MX_TTRAM;*/
	}



	/* Petite vérification pour ne pas déborder du buffer */
	if( (strlen(chemin_data)+strlen(FILE_BOING_GAUCHE)) > TAILLE_CHEMIN_AVR )
	{
		return(APPLI_ERROR_DATA_PATH_OVER);
	}

	strcpy( mon_chemin, chemin_data );
	strcat( mon_chemin, FILE_BOING_GAUCHE );

	taille_fichier = Fcm_file_size(mon_chemin);

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"  Taille fichier : %ld"CRLF, taille_fichier );
	log_print(FALSE);
	#endif

	global_adr_buffer_boing_gauche = Fcm_reserve_ram( ((taille_fichier + 3) & (int32)0xFFFFFFFC), ram_type );
	
	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"  global_adr_buffer_boing_gauche : 0x%lx"CRLF, global_adr_buffer_boing_gauche );
	log_print(FALSE);
	#endif

	if( global_adr_buffer_boing_gauche==FALSE )
	{
		/* echec reservation ram */
		return( APPLI_ERROR_RESERVE_RAM );
	}


	{
		int32 number_octet_load;

		number_octet_load = Fcm_bload( mon_chemin, (char *)global_adr_buffer_boing_gauche, 0, taille_fichier);

		if( number_octet_load != taille_fichier  )
		{
			return( APPLI_ERROR_AVR_SIZE );
		}
	}


	musique_header = (s_AVR_HEADER *)global_adr_buffer_boing_gauche;

	global_son_gauche.adresse_start = global_adr_buffer_boing_gauche + 128;
	global_son_gauche.adresse_end   = global_adr_buffer_boing_gauche + 128 + (uint32)musique_header->size;

	if( (global_son_gauche.adresse_end - global_son_gauche.adresse_start) > (uint32)taille_fichier )
	{
		return( APPLI_ERROR_AVR_SIZE );
	}

	global_son_gauche.adresse_loop_start = global_son_gauche.adresse_start + (uint32)musique_header->lbeg;
	global_son_gauche.adresse_loop_end   = global_son_gauche.adresse_start + (uint32)musique_header->lend;

	global_son_gauche.adresse_pause = global_son_gauche.adresse_start;
	global_son_gauche.status        = 0; /*???*/
	global_son_gauche.play_mode     = SB_PLA_ENA;
	global_son_gauche.frequence     = musique_header->rate.valeur;
	global_son_gauche.stereo        = musique_header->mono;
	global_son_gauche.signe         = musique_header->sign;
	global_son_gauche.rez_bit       = musique_header->rez;


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"  global_son_gauche.adresse_start : %ld (%lx)"CRLF, global_son_gauche.adresse_start, global_son_gauche.adresse_start );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_gauche.adresse_end   : %ld"CRLF, global_son_gauche.adresse_end );
	log_print(FALSE);
	sprintf( buf_log, CRLF"  global_son_gauche.adresse_loop_start : %ld"CRLF, global_son_gauche.adresse_loop_start );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_gauche.adresse_loop_end   : %ld"CRLF, global_son_gauche.adresse_loop_end );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_gauche.adresse_pause   : %ld"CRLF, global_son_gauche.adresse_pause );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_gauche.status   : %d"CRLF, global_son_gauche.status );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_gauche.play_mode   : %d"CRLF, global_son_gauche.play_mode );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_gauche.frequence   : %d"CRLF, global_son_gauche.frequence );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_gauche.stereo   : %d"CRLF, global_son_gauche.stereo );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_gauche.signe   : %d"CRLF, global_son_gauche.signe );
	log_print(FALSE);
	sprintf( buf_log, " ## global_son_gauche.rez_bit   : %d"CRLF""CRLF"*************"CRLF, global_son_gauche.rez_bit );
	log_print(FALSE);
	#endif


	{
		uint32 nb_boucle,i;
		int8 *pt_son;
		
		nb_boucle = (global_son_gauche.adresse_end - global_son_gauche.adresse_start)/2;
		pt_son = (int8 *)(global_son_gauche.adresse_start+AVR_VOIX_DROITE);  /* on diminue le son a droite */

	#ifdef LOG_FILE
	sprintf( buf_log, "  pt_son=%p    nb_boucle=%ld"CRLF, pt_son, nb_boucle );
	log_print(FALSE);
	#endif

		for( i=0; i<nb_boucle; i++ )
		{
			*pt_son = *pt_son/2;
			pt_son = pt_son + 2;
/*	#ifdef LOG_FILE
	sprintf( buf_log, "  pt_son=%p"CRLF, pt_son );
	log_print(FALSE);
	#endif*/

		}
		
		
	}

	#ifdef LOG_FILE
	sprintf( buf_log, "  *********************"CRLF );
	log_print(FALSE);
	#endif




	strcpy( mon_chemin, chemin_data );
	strcat( mon_chemin, FILE_BOING_DROITE );

	taille_fichier = Fcm_file_size(mon_chemin);

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF""CRLF"  Taille fichier : %ld"CRLF, taille_fichier );
	log_print(FALSE);
	#endif

	global_adr_buffer_boing_droite = Fcm_reserve_ram( ((taille_fichier+3)&(int32)0xFFFFFFFC), ram_type );


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"  global_adr_buffer_boing_droite : 0x%lx"CRLF, global_adr_buffer_boing_droite );
	log_print(FALSE);
	#endif


	if( global_adr_buffer_boing_droite==FALSE )
	{
		/* echec reservation ram */
		return( APPLI_ERROR_RESERVE_RAM );
	}


	{
		int32 number_octet_load;


		number_octet_load = Fcm_bload( mon_chemin,(char *)global_adr_buffer_boing_droite, 0, taille_fichier);

		if( number_octet_load != taille_fichier  )
		{
			return( APPLI_ERROR_AVR_SIZE );
		}
	}



	musique_header = (s_AVR_HEADER *)global_adr_buffer_boing_droite;

	global_son_droite.adresse_start = global_adr_buffer_boing_droite + 128;
	global_son_droite.adresse_end   = global_adr_buffer_boing_droite + 128 + (uint32)musique_header->size;

	if( (global_son_droite.adresse_end - global_son_droite.adresse_start) > (uint32)taille_fichier )
	{
		return( APPLI_ERROR_AVR_SIZE );
	}

	global_son_droite.adresse_loop_start = global_son_droite.adresse_start + (uint32)musique_header->lbeg;
	global_son_droite.adresse_loop_end   = global_son_droite.adresse_start + (uint32)musique_header->lend;

	global_son_droite.adresse_pause = global_son_droite.adresse_start;
	global_son_droite.status        = 0; /*???*/
	global_son_droite.play_mode     = SB_PLA_ENA;
	global_son_droite.frequence     = musique_header->rate.valeur;
	global_son_droite.stereo        = musique_header->mono;
	global_son_droite.signe         = musique_header->sign;
	global_son_droite.rez_bit       = musique_header->rez;


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"  global_son_droite.adresse_start : %ld (%lx)"CRLF, global_son_droite.adresse_start, global_son_droite.adresse_start );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_droite.adresse_end   : %ld"CRLF, global_son_droite.adresse_end );
	log_print(FALSE);
	sprintf( buf_log, CRLF"  global_son_droite.adresse_loop_start : %ld"CRLF, global_son_droite.adresse_loop_start );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_droite.adresse_loop_end   : %ld"CRLF, global_son_droite.adresse_loop_end );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_droite.adresse_pause   : %ld"CRLF, global_son_droite.adresse_pause );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_droite.status   : %d"CRLF, global_son_droite.status );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_droite.play_mode   : %d"CRLF, global_son_droite.play_mode );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_droite.frequence   : %d"CRLF, global_son_droite.frequence );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_droite.stereo   : %d"CRLF, global_son_droite.stereo );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_droite.signe   : %d"CRLF, global_son_droite.signe );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_droite.rez_bit   : %d"CRLF""CRLF""CRLF, global_son_droite.rez_bit );
	log_print(FALSE);
	#endif





	{
		uint32 nb_boucle,i;
		int8 *pt_son;
		
		nb_boucle = (global_son_droite.adresse_end - global_son_droite.adresse_start)/2;
		pt_son = (int8 *)(global_son_droite.adresse_start+AVR_VOIX_GAUCHE);  /* on diminue le son a gauche */

	#ifdef LOG_FILE
	sprintf( buf_log, "  pt_son=%p    nb_boucle=%ld"CRLF, pt_son, nb_boucle );
	log_print(FALSE);
	#endif

		for( i=0; i<nb_boucle; i++ )
		{
			*pt_son = *pt_son/2;
			pt_son = pt_son + 2;
/*	#ifdef LOG_FILE
	sprintf( buf_log, "  pt_son=%p"CRLF, pt_son );
	log_print(FALSE);
	#endif*/

		}
		
		
	}

	#ifdef LOG_FILE
	sprintf( buf_log, "  *********************"CRLF );
	log_print(FALSE);
	#endif







	strcpy( mon_chemin, chemin_data );
	strcat( mon_chemin, FILE_BOING_SOL );

	taille_fichier = Fcm_file_size(mon_chemin);

	#ifdef LOG_FILE
	sprintf( buf_log, CRLF""CRLF"  Taille fichier : %ld"CRLF, taille_fichier );
	log_print(FALSE);
	#endif

	global_adr_buffer_boing_sol = Fcm_reserve_ram( ((taille_fichier+3)&(int32)0xFFFFFFFC), ram_type );





	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"  global_adr_buffer_boing_sol : 0x%lx"CRLF, global_adr_buffer_boing_sol );
	log_print(FALSE);
	#endif


	if( global_adr_buffer_boing_sol==FALSE )
	{
		/* echec reservation ram */
		return( APPLI_ERROR_RESERVE_RAM );
	}


	{
		int32 number_octet_load;


		number_octet_load = Fcm_bload( mon_chemin,(char *)global_adr_buffer_boing_sol, 0, taille_fichier);

		if( number_octet_load != taille_fichier  )
		{
			return( APPLI_ERROR_AVR_SIZE );
		}
	}



	musique_header = (s_AVR_HEADER *)global_adr_buffer_boing_sol;

	global_son_sol.adresse_start = global_adr_buffer_boing_sol + 128;
	global_son_sol.adresse_end   = global_adr_buffer_boing_sol + 128 + (uint32)musique_header->size;

	if( (global_son_sol.adresse_end - global_son_sol.adresse_start) > (uint32)taille_fichier )
	{
		return( APPLI_ERROR_AVR_SIZE );
	}

	global_son_sol.adresse_loop_start = global_son_sol.adresse_start + (uint32)musique_header->lbeg;
	global_son_sol.adresse_loop_end   = global_son_sol.adresse_start + (uint32)musique_header->lend;

	global_son_sol.adresse_pause = global_son_sol.adresse_start;
	global_son_sol.status        = 0; /*???*/
	global_son_sol.play_mode     = SB_PLA_ENA;
	global_son_sol.frequence     = musique_header->rate.valeur;
	global_son_sol.stereo        = musique_header->mono;
	global_son_sol.signe         = musique_header->sign;
	global_son_sol.rez_bit       = musique_header->rez;


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"  global_son_sol.adresse_start : %ld (%lx)"CRLF, global_son_sol.adresse_start, global_son_sol.adresse_start );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_sol.adresse_end   : %ld"CRLF, global_son_sol.adresse_end );
	log_print(FALSE);
	sprintf( buf_log, CRLF"  global_son_sol.adresse_loop_start : %ld"CRLF, global_son_sol.adresse_loop_start );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_sol.adresse_loop_end   : %ld"CRLF, global_son_sol.adresse_loop_end );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_sol.adresse_pause   : %ld"CRLF, global_son_sol.adresse_pause );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_sol.status   : %d"CRLF, global_son_sol.status );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_sol.play_mode   : %d"CRLF, global_son_sol.play_mode );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_sol.frequence   : %d"CRLF, global_son_sol.frequence );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_sol.stereo   : %d"CRLF, global_son_sol.stereo );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_sol.signe   : %d"CRLF, global_son_sol.signe );
	log_print(FALSE);
	sprintf( buf_log, "  global_son_sol.rez_bit   : %d"CRLF""CRLF""CRLF, global_son_sol.rez_bit );
	log_print(FALSE);
	#endif





	return 0L;


}


#undef TAILLE_CHEMIN_AVR

