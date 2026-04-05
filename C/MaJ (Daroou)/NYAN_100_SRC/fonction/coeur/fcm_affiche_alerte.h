/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 12/02/2024 MaJ 12/02/2024 * */
/* ***************************** */



#ifndef __FCM_AFFICHE_ALERTE_H__
#define __FCM_AFFICHE_ALERTE_H__



#define  DATA_MODE_COEUR  (1)	/* RSC dialogue coeur */
#define  DATA_MODE_APPLI  (2)	/* RSC dialogue appli */
#define  DATA_MODE_USER   (3)	/* Chaine … afficher  */

int16 Fcm_affiche_alerte( const int16 data_mode, const uint16 idx_alert, int16 *bouton );


#endif /* __FCM_AFFICHE_ALERTE_H__ */

