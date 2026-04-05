/* **[Boing]******************** */
/* *                           * */
/* * 20/09/2015 MaJ 11/11/2023 * */
/* ***************************** */



#include "../fonction/graphique/Fcm_make_liste_redraw_transparent.c"




/* prototype */
void build_screen_mono( void );



/* Fonction */
void build_screen_mono( void )
{


#ifdef LOG_FILE
sprintf( buf_log, " * START build_screen_mono()"CRLF );
log_print( FALSE );
#endif


	/* ------------------------------------------ */
	/* Restauration des fonds qui ont ‚t‚ alt‚r‚s */
	/* ------------------------------------------ */
	{

/*		for(index_liste_fond=0; index_liste_fond<Fcm_nb_liste_restaure_fond; index_liste_fond++)
		{

			pxy[0] = Fcm_liste_restaure_fond[index_liste_fond].g_x;
			pxy[1] = Fcm_liste_restaure_fond[index_liste_fond].g_y;
			pxy[2] = pxy[0] + Fcm_liste_restaure_fond[index_liste_fond].g_w - 1;
			pxy[3] = pxy[1] + Fcm_liste_restaure_fond[index_liste_fond].g_h - 1;

			pxy[4] = pxy[0];
			pxy[5] = pxy[1];
			pxy[6] = pxy[2];
			pxy[7] = pxy[3];

			vrt_cpyfm(global_vdihandle_framebuffer,MD_REPLACE,pxy, &mfdb_fond_ecran, &mfdb_framebuffer, couleur_fond );
		}*/

		/* optimisation du redraw de la Ball et de l'ombre      */
		/* les deux sont cote … cote et ont une partie communes */
		/* On affiche la zone occup‚ par les deux               */
		pxy[0] = MIN( Fcm_liste_restaure_fond[0].g_x, Fcm_liste_restaure_fond[1].g_x );
		pxy[1] = MIN( Fcm_liste_restaure_fond[0].g_y, Fcm_liste_restaure_fond[1].g_y );
		pxy[2] = MAX( Fcm_liste_restaure_fond[0].g_x+Fcm_liste_restaure_fond[0].g_w, Fcm_liste_restaure_fond[1].g_x+Fcm_liste_restaure_fond[1].g_w ) - 1;
		pxy[3] = MAX( Fcm_liste_restaure_fond[0].g_y+Fcm_liste_restaure_fond[0].g_h, Fcm_liste_restaure_fond[1].g_y+Fcm_liste_restaure_fond[1].g_h ) - 1;

		pxy[4] = pxy[0];
		pxy[5] = pxy[1];
		pxy[6] = pxy[2];
		pxy[7] = pxy[3];

		vrt_cpyfm(global_vdihandle_framebuffer,VRT_COPY_MODE,pxy, &mfdb_fond_ecran, &mfdb_framebuffer, couleur_vrt_copy );

	}






	/* ------------------------------------------ */
	/* Affichage Boing Ombre                      */
	/* ------------------------------------------ */
	vrt_cpyfm(global_vdihandle_framebuffer,VRT_MASQUE_MODE,pxy_boing_ombre, &mfdb_boing_ombre_mask, &mfdb_framebuffer, couleur_ombre );






	/* ------------------------------------------ */
	/* Affichage Boing                            */
	/* ------------------------------------------ */
	vrt_cpyfm(global_vdihandle_framebuffer,VRT_MASQUE_MODE,pxy_boing_ball, &mfdb_boing_ball_mask[idx_boing_ball], &mfdb_framebuffer, couleur_mask_vrt );
	vrt_cpyfm(global_vdihandle_framebuffer,VRT_SPRITE_MODE,pxy_boing_ball, &mfdb_boing_ball[idx_boing_ball],      &mfdb_framebuffer, couleur_mask_vrt );



#ifdef LOG_FILE
sprintf( buf_log, " * END build_screen_mono()"CRLF );
log_print( FALSE );
#endif


	return;


}

