/* **[Offscreen]**************** */
/* *                           * */
/* * 10/12/2015 MaJ 02/01/2016 * */
/* ***************************** */




/* Fonction */
void gestion_barre_menu( void )
{

	/* ----------------------------------------- */
	/* Ici on gŠre les clic sur la barre de Menu */
	/* sp‚cifique … l'application                */
	/* ----------------------------------------- */


	switch( buffer_aes[4] )
	{
		case MN_SAVE_STATS:
			sauver_statistiques();
			break;


		case MN_OFFSCREEN:
			ouvre_fenetre_offscreen();
			break;

		case MN_SPRITE_OFFSCR:
			ouvre_fenetre_sprite_offscreen();
			break;


		case MN_STATISTIQUE:
			ouvre_fenetre_stats();
			break;

		case MN_ADRESSE:
			ouvre_fenetre_adresse();
			break;


		case MN_BENCH:
			ouvre_fenetre_bench();
			break;

		case MN_INFO:
			ouvre_fenetre_info();
			break;
	}


	return;


}

