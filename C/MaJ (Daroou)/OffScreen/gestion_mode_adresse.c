/* **[Offscreen]**************** */
/* *                           * */
/* * 30/12/2015 MaJ 30/12/2015 * */
/* ***************************** */




/*#include "Fcm_file_exist.c"*/
#include "fonction/coeur/Fcm_gestion_pop_up.c"
/*#include "Fcm_libere_RSC.c"

#include "Fcm_set_config_generale.c"
#include "Fcm_charge_RSC.c"
#include "Fcm_my_menu_bar.c"
#include "Fcm_init_rsc_info.c"

#include "Fcm_ouvre_fenetre_start.c"*/
/*#include "fonction/coeur/Fcm_purge_redraw.c"*/

/*#include "Fcm_gestion_fermeture_programme.c"*/








/* Prototype */
int32 gestion_mode_adresse( void );




/* Fonction */
int32 gestion_mode_adresse( void )
{

/*	char    my_buffer[ (TAILLE_CHEMIN+TAILLE_FICHIER) ];*/
	OBJECT *adr_popup;
	OBJECT *adr_dl_adresse;
/*	int16   y;*/




	#ifdef LOG_FILE
	sprintf( buf_log, CRLF"## gestion_mode_adresse()"CRLF );
	log_print( FALSE );
	#endif



	/* Adresse du pop up */
	rsrc_gaddr( R_TREE, POPUP_ADRESSE, &adr_popup );


	SET_BIT_W( adr_popup[POP_MODE_AD_1].ob_state, OS_SELECTED, 0);
	SET_BIT_W( adr_popup[POP_MODE_AD_2].ob_state, OS_SELECTED, 0);
	SET_BIT_W( adr_popup[POP_MODE_AD_3].ob_state, OS_SELECTED, 0);
	SET_BIT_W( adr_popup[POP_MODE_AD_4].ob_state, OS_SELECTED, 0);



	/* Adresse du dialogue */
	rsrc_gaddr( R_TREE, DL_ADRESSE, &adr_dl_adresse );

	adr_popup[POPUP_ADR_FOND].ob_y = adr_dl_adresse[AD_POPUP].ob_y+adr_dl_adresse[AD_POPUP].ob_height;
	adr_popup[POPUP_ADR_FOND].ob_x = adr_dl_adresse[AD_POPUP].ob_x;


	{
		int16  winx,winy,winw,winh;
		int16  objet;


		/* on cherche les coordonn‚es de la fenˆtre */
		wind_get(h_win[W_ADRESSE],WF_WORKXYWH,&winx,&winy,&winw,&winh);

		adr_popup[POPUP_ADR_FOND].ob_x += winx;
		adr_popup[POPUP_ADR_FOND].ob_y += winy;

		adr_popup[POPUP_ADR_FOND].ob_y += (adr_dl_adresse[AD_POPUP].ob_spec.tedinfo->te_thickness * -1);
		adr_popup[POPUP_ADR_FOND].ob_y += (adr_popup[POPUP_ADR_FOND].ob_spec.obspec.framesize * -1);

		objet = Fcm_gestion_pop_up( adr_popup/*, h_win[W_OPTION_PREFERENCE]*/ );


		Fcm_purge_redraw();

/*		{
			char texte[256];

			sprintf( texte, "reponse pop up = %d   ", objet );
			v_gtext(vdihandle,4*8,2*16,texte);
		}
*/


		/* ---------------------------------------------- */
		/* Mise … jour Langue dans le dialogue preference */
		/* ---------------------------------------------- */
		if( objet!=-1 && objet!=rsc_adresse_view_mode )
		{
			rsc_adresse_view_mode=objet;

			return(TRUE);
		}


	}


	return(FALSE);


}


