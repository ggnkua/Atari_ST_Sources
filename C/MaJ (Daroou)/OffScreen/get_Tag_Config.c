/*===============================*/
/* Fonction recherchant tous les */
/* TAG de configuration locale … */
/* l'appli                       */
/* 20/09/2015 MaJ 17/10/2015     */
/*_______________________________*/



/* Fonction */
void get_tag_config( const char *buffer_config, int16 *erreur_config, int16 *tag_absent)
{
	/* anti warning */
	{
		uint32 a=(uint32)buffer_config;
		int16 *c=erreur_config;
		int16 *d=tag_absent;

		a=a+(uint32)*c+(uint32)*d;
	}


	#ifdef LOG_FILE
	sprintf( buf_log, " - get_tag_config()"CRLF);
	log_print(FALSE);
	#endif



	return;


}

