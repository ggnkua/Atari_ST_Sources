/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 03/01/2013 MaJ 05/03/2024 * */
/* ***************************** */



/* 
 * 29/10/2023: redéfinition de la forme du pointeur souris -> graf_mouse()
 *
 */


void Fcm_gestion_topped( void )
{

	/* Cette fonction gŠre les actions qui doivent etre */
	/* ex‚cut‚ lors d'un passage au premier plan d'une  */
	/* fenetre ordonn‚e par l'AES                       */


	/* Ex: changement de palette, activation du contenu, */
	/* sortie de pause du jeu, etc...                    */


	/* Pour l'instant, aucune utilit‚, … impl‚menter le */
	/* jour o— la n‚cessit‚ se fera sentir              */


	/* On met la fenetre au premier plan et puis c'est tout :p */
	wind_set(buffer_aes[3],WF_TOP,buffer_aes[4],buffer_aes[5],buffer_aes[6],buffer_aes[7]);

	/* on doit redéfinir la forme du pointeur souris (ref Atari Compendium 1992 p.687)*/
	graf_mouse(ARROW, NULL);

	return;


}

