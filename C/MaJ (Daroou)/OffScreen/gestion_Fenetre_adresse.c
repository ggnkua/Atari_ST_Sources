/* **[Offscreen]**************** */
/* *                           * */
/* * 30/12/2015 MaJ 30/12/2015 * */
/* ***************************** */



#include "gestion_mode_adresse.c"
#include "refresh_rsc_adresse.c"



void gestion_fenetre_adresse( int16 controlkey, int16 touche, int16 bouton );




void gestion_fenetre_adresse( int16 controlkey, int16 touche, int16 bouton )
{

	OBJECT	*adr_formulaire;
	int16	objet;
/*	int16	valeur=0;*/
	int16	commande=0;


	/* suppression warning */
	objet=controlkey+touche;




	/* on cherche l'adresse du formulaire */
	rsrc_gaddr( R_TREE, DL_ADRESSE, &adr_formulaire );

	objet = objc_find(adr_formulaire,0,4,souris.g_x,souris.g_y);




/*	{
		char texte[256];


		sprintf(texte,"gestion_fenetre_stats() Timer = %ld     ", Fcm_get_timer() );
		v_gtext(vdihandle,78*8,1*16, texte);
	}*/


	if( bouton )
	{
		switch( objet )
		{
			case AD_POPUP:
				commande=5;
/*				valeur=0;*/
				break;
		}
	}





	/* ------------------------- */
	/* Pop Up Adresse mode       */
	/* ------------------------- */
	if( commande==5 )
	{
		if( gestion_mode_adresse() )
		{
			refresh_rsc_adresse();
			Fcm_objet_draw( adr_formulaire, h_win[W_ADRESSE], AD_FOND_ADRESSE, 0 );
		}
	}





	return;


}

