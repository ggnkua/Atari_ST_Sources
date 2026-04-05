/* **[Fonction commune]******* */
/* * Gestion Barre de Menu   * */
/* *                         * */
/* * 09/08/2003 = 06/04/2013 * */
/* *************************** */


/* Prototype */
VOID Fcm_my_menu_bar( const WORD tree_index, const WORD mode );


/* Fonction */
VOID Fcm_my_menu_bar( const WORD tree_index, const WORD mode )
{
 /*
  *	Mode:
  *		- (1) MENU_INSTALL : install menu bar
  *		- (0) MENU_REMOVE  : remove  menu bar
  */


	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"## Fcm_my_menu_bar(%d,%d)"CRLF, tree_index, mode );
	log_print(FALSE);
	#endif




	#ifdef LOG_FILE
	if( mode==MENU_INSTALL )
	{
		sprintf( buf_log, " - Installation de la Barre de Menu"CRLF);
	}
	else
	{
		if( mode==MENU_REMOVE )
		{
			sprintf( buf_log, " - DÇsinstallation de la Barre de Menu"CRLF);
		}
		else
		{
			sprintf( buf_log, " - Menu Barre: ERREUR de paramätre"CRLF);
		}
	}
	log_print(FALSE);
	#endif


	{
		OBJECT *menu;


		rsrc_gaddr( R_TREE, tree_index, &menu);

		#ifndef __WINDOM__

			#ifdef LOG_FILE
			sprintf( buf_log, " - AES menu_bar (mode=%d)"CRLF, mode );
			log_print(FALSE);
			#endif

			menu_bar( menu, mode);


		#else

			#ifdef LOG_FILE
			sprintf( buf_log, " - WINDOM menu_bar (mode=%d)"CRLF, mode );
			log_print(FALSE);
			#endif

			MenuBar( menu, mode );

		#endif

	}


	return;

}

