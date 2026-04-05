/* ***************************** */
/* *                           * */
/* * 13/11/2023 MaJ 13/11/2023 * */
/* ***************************** */

/*

 definition pour les fonctions:
 - Fcm_make_liste_redraw_transparent()
 - Fcm_make_liste_redraw_opaque()

*/


#ifndef ___FCM_MAKE_LISTE_REDRAW_H___
#define ___FCM_MAKE_LISTE_REDRAW_H___


#ifndef FCM_LISTE_RESTAURE_FOND_MAX
#error "FCM_LISTE_RESTAURE_FOND_MAX doit etre defini par l'application"
#endif

#ifndef FCM_LISTE_REFRESH_ECRAN_MAX
#error "FCM_LISTE_REFRESH_ECRAN_MAX doit etre defini par l'application"
#endif

/* doivent etre defini dans l'application */
/*#define FCM_LISTE_RESTAURE_FOND_MAX (128)*/
/*#define FCM_LISTE_REFRESH_ECRAN_MAX (128)*/


#ifdef LOG_FILE
int16 Fcm_nb_liste_restaure_fond_max;
int16 Fcm_nb_liste_refresh_ecran_max;
#endif


GRECT Fcm_make_liste_redraw_xywh_ecran;


int16 Fcm_nb_liste_restaure_fond;
GRECT Fcm_liste_restaure_fond[FCM_LISTE_RESTAURE_FOND_MAX];

int16 Fcm_nb_liste_refresh_ecran;
GRECT Fcm_liste_refresh_ecran[FCM_LISTE_REFRESH_ECRAN_MAX];



#endif   /*  ___FCM_MAKE_LISTE_REDRAW_H___  */


