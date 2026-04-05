/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 14/11/2003 MaJ 25/02/2024 * */
/* ***************************** */



void Fcm_menu_tnormal( int16 tree_index, int16 menu_index, int16 mode )
{
 /*
  *	Mode:
  *		- (1) Afficher entr‚e du menu normal
  *		- (0) Afficher entr‚e du menu invers‚
  */

	menu_tnormal( Fcm_adr_RTREE[tree_index], menu_index, mode );


	return;


}

