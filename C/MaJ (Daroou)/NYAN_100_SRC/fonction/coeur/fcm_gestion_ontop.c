/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 03/01/2013 MaJ 03/04/2024 * */
/* ***************************** */



/*
 *
 * 29/10/2023: redéfinition de la forme du pointeur souris -> graf_mouse()
 *
 */


void Fcm_gestion_ontop( void )
{
	/* Cette fonction gŠre les actions qui doivent etre */
	/* ex‚cut‚ lors d'un passage au premier plan d'une  */
	/* fenetre ordonn‚e par l'AES                       */


	/* Ex: changement de palette, activation du contenu, */
	/* sortie de pause du jeu, etc...                    */


	/* Pour l'instant, aucune utilit‚, … impl‚menter le */
	/* jour o— la n‚cessit‚ se fera sentir              */



	/* on doit redéfinir la forme du pointeur souris (ref Atari Compendium 1992 p.688)*/
	graf_mouse(ARROW, NULL);


	return;


}

