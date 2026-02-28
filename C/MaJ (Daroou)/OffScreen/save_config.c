/*===============================*/
/* Fonction sauvant tous les     */
/* TAG de configuration propre … */
/* l'appli                       */
/* 20/09/2015 MaJ 17/10/2015     */
/*_______________________________*/



/* Fonction */
void save_config(const int16 handle_fichier)
{

	/* anti warning */
	{
		int16 a=handle_fichier;
		a++;
	}



	#ifdef LOG_FILE
	sprintf( buf_log, "# save_config()"CRLF );
	log_print(FALSE);
	#endif


	/* rien pour cette appli */


	return;


}

