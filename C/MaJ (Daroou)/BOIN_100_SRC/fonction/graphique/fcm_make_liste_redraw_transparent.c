/* ***************************** */
/* *                           * */
/* * 20/09/2015 MaJ 13/11/2023 * */
/* ***************************** */


#ifndef ___FCM_MAKE_LISTE_REDRAW_TRANSPARENT___
#define ___FCM_MAKE_LISTE_REDRAW_TRANSPARENT___


#include "Fcm_make_liste_redraw.h"

#ifdef LOG_FILE
#include "fcm_affiche_texte_ecran.c"
#endif

/*

 - Fcm_make_liste_redraw_transparent()
 - Fcm_make_liste_redraw_opaque()

 * Variables Globales
 * 
 * GRECT Fcm_make_liste_redraw_xywh_ecran               : dimension de l'ecran
 * int16 Fcm_nb_liste_restaure_fond   : nombre de zone a restaurer dans le framebuffer
 * GRECT Fcm_liste_restaure_fond[]    : liste des zones a restaurer dans le framebuffer
 * int16 Fcm_nb_liste_refresh_ecran   : nombre de zone a redraw a l'ecran
 * GRECT Fcm_liste_refresh_ecran      : liste des zones a redraw a l'ecran
 *
 * utilisé par:
 * Boing (build_screen_xxx)
 * Badgers
 */



/*  pxy_block[] : zone du sprite à afficher, Attention, si pxy_block[0]==-1 ne pas afficher => hors écran */




/* prototype */
void Fcm_make_liste_redraw_transparent( const GRECT *xywh_new, const GRECT *xywh_old, int16 *pxy_block );



/* Fonction */
void Fcm_make_liste_redraw_transparent( const GRECT *xywh_new, const GRECT *xywh_old, int16 *pxy_block )
{

	GRECT xywh_zone;






	/* Fcm_nb_liste_restaure_fond - Fcm_nb_liste_refresh_ecran doivent  */
	/* etre remis à zero au d‚but de la construction de chaque ‚cran    */



	/* --------------------------------------------------------- */
	/* sprite transparent, il faut restaurer la totalit‚ du fond */
	/* --------------------------------------------------------- */

	*(&xywh_zone) = *xywh_old;

	if( rc_intersect( &Fcm_make_liste_redraw_xywh_ecran, &xywh_zone) )
	{
		*(&Fcm_liste_restaure_fond[Fcm_nb_liste_restaure_fond]) = *(&xywh_zone);
		Fcm_nb_liste_restaure_fond++;
		Fcm_nb_liste_restaure_fond = MIN( Fcm_nb_liste_restaure_fond, FCM_LISTE_RESTAURE_FOND_MAX);
	}




	/* --------------------------------------------------------------- */
	/* On calcul la zone d'affichage de la nouvelle position du sprite */
	/* --------------------------------------------------------------- */

	*(&xywh_zone) = *xywh_new;

	if( rc_intersect( &Fcm_make_liste_redraw_xywh_ecran, &xywh_zone) )
	{
		pxy_block[0] = xywh_zone.g_x - xywh_new->g_x;
		pxy_block[1] = xywh_zone.g_y - xywh_new->g_y;
		pxy_block[2] = pxy_block[0] + xywh_zone.g_w - 1;
		pxy_block[3] = pxy_block[1] + xywh_zone.g_h - 1;

		pxy_block[4] = xywh_zone.g_x;
		pxy_block[5] = xywh_zone.g_y;
		pxy_block[6] = pxy_block[4] + xywh_zone.g_w - 1;
		pxy_block[7] = pxy_block[5] + xywh_zone.g_h - 1;
	}
	else
	{
		/* indicateur, le sprite est hors ‚cran, il ne doit pas etre affich‚ */
		pxy_block[0] = -1;
	}





	/* ------------------------------------------------------------------- */
	/* Calcul de la zone ‚cran … r‚afficher                                */
	/* ------------------------------------------------------------------- */
	{
		xywh_zone.g_x = MIN(xywh_old->g_x, xywh_new->g_x );
		xywh_zone.g_y = MIN(xywh_old->g_y, xywh_new->g_y );
	
		xywh_zone.g_w = MAX( (xywh_old->g_x+xywh_old->g_w), (xywh_new->g_x+xywh_new->g_w) ) - xywh_zone.g_x;
		xywh_zone.g_h = MAX( (xywh_old->g_y+xywh_old->g_h), (xywh_new->g_y+xywh_new->g_h) ) - xywh_zone.g_y;

		if( rc_intersect( &Fcm_make_liste_redraw_xywh_ecran, &xywh_zone) )
		{
			/* si le sprite (ou une partie) est visible … l'‚cran */
			* (&Fcm_liste_refresh_ecran[Fcm_nb_liste_refresh_ecran]) = * (&xywh_zone);
			Fcm_nb_liste_refresh_ecran++;
			Fcm_nb_liste_refresh_ecran = MIN( Fcm_nb_liste_refresh_ecran, FCM_LISTE_REFRESH_ECRAN_MAX);
		}

	}



#ifdef LOG_FILE
	{
		char mytexte[80];


		Fcm_nb_liste_restaure_fond_max=MAX(Fcm_nb_liste_restaure_fond_max, Fcm_nb_liste_restaure_fond);
		Fcm_nb_liste_refresh_ecran_max=MAX(Fcm_nb_liste_refresh_ecran_max, Fcm_nb_liste_refresh_ecran);

		snprintf( mytexte, 80, "Fcm_nb_liste_restaure_fond=%d  MAX(%d)    ", Fcm_nb_liste_restaure_fond, Fcm_nb_liste_restaure_fond_max  );
		Fcm_affiche_texte_ecran(1,1,mytexte);
		snprintf( mytexte, 80, "Fcm_nb_liste_refresh_ecran=%d  MAX(%d)    ", Fcm_nb_liste_refresh_ecran, Fcm_nb_liste_refresh_ecran_max );
		Fcm_affiche_texte_ecran(1,2,mytexte);

	}
#endif


	return;


}

#endif   /*   ___FCM_MAKE_LISTE_REDRAW_TRANSPARENT___   */

