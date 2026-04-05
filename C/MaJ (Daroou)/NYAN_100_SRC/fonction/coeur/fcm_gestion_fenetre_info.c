/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 31/12/2016 MaJ 05/03/2024 * */
/* ***************************** */



void Fcm_gestion_fenetre_info( const int16 controlkey, const int16 touche, const int16 bouton )
{
	UNUSED(controlkey);
	UNUSED(bouton);


	FCM_LOG_PRINT3("#Fcm_gestion_fenetre_info(%d,%d,%d)", controlkey,touche,bouton);


	if( (touche & 0xff00) == 0x0100 ) /* ESCape */
	{
		Fcm_fermer_fenetre( W_INFO_PRG );
	}


	return;


}

