/* **[Fonction Commune]********** */
/* *                            * */
/* * 13.08.2017 MaJ 19/02/2024  * */
/* ****************************** */



/* ----------------------------------------------------------- */
/* define utilise par les fonctions rescale des formulaire AES */
/* ----------------------------------------------------------- */


#ifndef  __FCM_RESCALE_DEF_H___
 #define __FCM_RESCALE_DEF_H___


#define FCM_RESCALE_WCHAR        (Fcm_screen.gr_hwchar)
#define FCM_RESCALE_HCHAR        (Fcm_screen.gr_hhchar)

#define FCM_RESCALE_MARGE_HAUT   (Fcm_screen.gr_hhchar/2)
#define FCM_RESCALE_MARGE_GAUCHE (Fcm_screen.gr_hwchar)
#define FCM_RESCALE_MARGE_DROITE (Fcm_screen.gr_hwchar)
#define FCM_RESCALE_MARGE_BAS    (Fcm_screen.gr_hhchar/2)

#define FCM_RESCALE_INTERLIGNE   (Fcm_screen.gr_hhchar/2)
#define FCM_RESCALE_LIGNEVIDE    (Fcm_screen.gr_hhchar)

#define FCM_RESCALE_ESPACE       (Fcm_screen.gr_hwchar/2)


#endif	/* #ifndef __FCM_RESCALE_DEF_H___ */

