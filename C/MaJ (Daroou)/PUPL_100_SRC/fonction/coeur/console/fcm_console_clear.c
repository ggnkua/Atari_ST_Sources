/**[Console]********************/
/*                             */
/* 01/01/2024 MaJ 03/01/2024   */
/* *****************************/

void Fcm_console_clear( void )
{
	int16 idx;


	/* on vide et init les lignes */
	for( idx=0; idx<FCM_CONSOLE_MAXLIGNE; idx++)
	{
		Fcm_struct_console_texte[idx].texte[0]=0;
		Fcm_struct_console_texte[idx].texte_lenght=0;
		Fcm_struct_console_texte[idx].texte_color=0;
	}


	return;


}

