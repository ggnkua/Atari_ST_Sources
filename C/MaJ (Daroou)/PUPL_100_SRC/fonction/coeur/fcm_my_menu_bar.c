/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 09/08/2003 MaJ 25/02/2024 * */
/* ***************************** */



#ifndef ___FCM_MY_MENU_BAR_C___
#define ___FCM_MY_MENU_BAR_C___


/*
 * Cette fonction date de l'utilisation de WinDom.
 * Si WinDom defini, utilisation de sa fonction
 * sinon celle de l'AES. Aujourd'hui, je ne l'utilise
 * plus, mais cette fonction reste pour le moment
 * pour sa sortie LOG... ça peut servir.
 * 
 */

void Fcm_my_menu_bar( const int16 tree_index, const int16 mode )
{
 /*
  *	Mode:
  *		- (1) MENU_INSTALL : install menu bar
  *		- (0) MENU_REMOVE  : remove  menu bar
  */

	FCM_LOG_PRINT2( CRLF"# Fcm_my_menu_bar(%d,%d)", tree_index, mode );
//FCM_LOG_PRINT ( "  mode (0) remove bar  - (1) install bar" );

	wind_update(BEG_UPDATE);
	menu_bar( Fcm_adr_RTREE[tree_index], mode);
	wind_update(END_UPDATE);

	return;

}


#endif   /* ___FCM_MY_MENU_BAR_C___ */

