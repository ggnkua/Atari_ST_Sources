/* **[Boing]******************** */
/* *                           * */
/* * 09/08/2017 MaJ 27/05/2018 * */
/* ***************************** */




/* Prototype */
void gestion_fenetre_ram( const int16 controlkey, const int16 touche, const int16 bouton );


/* Fonction */
void gestion_fenetre_ram( const int16 controlkey, const int16 touche, const int16 bouton )
{
	int16	 commande=0;

	UNUSED(controlkey);
	UNUSED(bouton);



	#ifdef LOG_FILE
	sprintf( buf_log, "#gestion_fenetre_ram(%d,%d ($%04x),%d)"CRLF, controlkey,touche, touche, bouton );
	log_print(FALSE);
	#endif


	
	if( touche )
	{
		switch( touche & 0xff00)
		{
			case 0x0100:	/* ESCape */
				commande=1;
				break;
		}
	}


	/* ------------------------- */
	/* Touche ESCape             */
	/* ------------------------- */
	if( commande==1 )
	{
		Fcm_fermer_fenetre( W_RAM );
	}


	return;

}

