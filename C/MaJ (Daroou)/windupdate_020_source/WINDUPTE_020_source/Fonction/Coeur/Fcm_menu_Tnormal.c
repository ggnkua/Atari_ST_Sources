/* **[Fonction commune]******* */
/* * Modifie entr‚e de Menu  * */
/* *                         * */
/* * 14/11/2003 06/04/2013   * */
/* *************************** */


/* Prototype */
VOID Fcm_menu_tnormal( WORD tree_index, WORD menu_index, WORD mode );


/* Fonction */
VOID Fcm_menu_tnormal( WORD tree_index, WORD menu_index, WORD mode )
{

 /*
  *	Mode:
  *		- (1) Afficher entr‚e du menu normal
  *		- (0) Afficher entr‚e du menu invers‚
  */

	#ifndef __WINDOM__

	{
		/* Fonction AES */
		OBJECT *adr_formulaire;

		/* on cherche l'adresse du Menu */
		rsrc_gaddr( R_TREE, tree_index, &adr_formulaire );

		menu_tnormal(adr_formulaire, menu_index, mode );
	}

	#else

	{
		/* Fonction Windom */
		tree_index=NULL;	/* pour ‚viter le warning */
		MenuTnormal( NULL, menu_index, mode );
	}

	#endif


	return;


}

