/* **[Fonction commune]******** */
/* * Gestion message          * */
/* * 03/01/2013 = 06/04/2013  * */
/* **************************** */


/* Prototypes */
VOID Fcm_gestion_topped(VOID);


/* Fonction */
VOID Fcm_gestion_topped(VOID)
{
/*
 * extern	FT_REDRAW	table_ft_redraw_win[NB_FENETRE];
 * extern	WORD		buffer_aes[16];
 * extern	WORD		h_win[NB_FENETRE];
 * extern	WORD		pxy[16];
 * extern	WORD		vdihandle;
 *
 */



	/* Cette fonction gŠre les actions qui doivent etre */
	/* ex‚cut‚ lors d'un passage au premier plan d'une  */
	/* fenetre ordonn‚e par l'AES                       */


	/* Ex: changement de palette, activation du contenu, */
	/* sortie de pause du jeu, etc...                    */


	/* Pour l'instant, aucune utilit‚, … impl‚menter le */
	/* jour o— la n‚cessit‚ se fera sentir              */


	/* On met la fenetre au premier plan et puis c'est tout :p */
	wind_set(buffer_aes[3],WF_TOP,buffer_aes[4],buffer_aes[5],buffer_aes[6],buffer_aes[7]);



	return;


}

