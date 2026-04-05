/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 03/01/2013 MaJ 05/03/2024 * */
/* ***************************** */



#ifndef ___FCM_GESTION_BOTTOM_C___
#define ___FCM_GESTION_BOTTOM_C___


void Fcm_gestion_bottom( void )
{
	/* Cette fonction gŠre les actions qui doivent etre */
	/* ex‚cut‚ lors d'un passage … l'arriere plan d'une */
	/* fenetre ordonn‚e par l'AES                       */


	/* Ex: changement de palette, activation du contenu, */
	/* mise en pause du jeu, etc...                      */


	/* Pour l'instant, aucune utilit‚, … impl‚menter le */
	/* jour o— la n‚cessit‚ se fera sentir              */


	/* On met la fenetre … l'arriŠre plan et puis c'est tout :p */
	wind_set(buffer_aes[3],WF_BOTTOM,buffer_aes[4],buffer_aes[5],buffer_aes[6],buffer_aes[7]);


	return;


}


#endif /* ___FCM_GESTION_BOTTOM_C___ */

