/* **[Boing]******************** */
/* *                           * */
/* * 09/08/2017 MaJ 14/08/2017 * */
/* ***************************** */


#include "../fonction/coeur/Fcm_rescale_def.h"


/* Prototype */
void rescale_rsc_ram( void );


/* Fonction */
void rescale_rsc_ram( void )
{

	OBJECT	*dial;
	int16    form_w;
	/*int16    gr_hwbox, gr_hhbox;*/
	int16	 gr_hwcar,gr_hhcar;

	/* Marre que le formulaire s'affiche mal d'une resolution a l'autre */
	/* tous les objets et le fond sont repositionner                    */

	#ifdef LOG_FILE
	sprintf( buf_log, "#FCM_RESCALE_rsc_ram()"CRLF );
	log_print(FALSE);
	#endif


	/* espace occuper par les caracteres de la fonte systeme */
	{
		int16 dummy;
		graf_handle( &gr_hwcar, &gr_hhcar, &dummy, &dummy );
		/*graf_handle( &gr_hwcar, &gr_hhcar, &gr_hwbox, &gr_hhbox );*/
	}


	/* on cherche l'adresse du formulaire et l'objet sous la souris */
	rsrc_gaddr( R_TREE, DL_RAM, &dial );

	/* position du pop up et de son label */
/*	{
		dial[RAM_TYPE_RAM].ob_x = FCM_RESCALE_MARGE_GAUCHE;
		dial[RAM_TYPE_RAM].ob_y = FCM_RESCALE_MARGE_HAUT;

		dial[RAM_POPUP_RAM].ob_x = dial[RAM_TYPE_RAM].ob_x + dial[RAM_TYPE_RAM].ob_width + FCM_RESCALE_ESPACE;
		dial[RAM_POPUP_RAM].ob_y = dial[RAM_TYPE_RAM].ob_y;

		form_w = dial[RAM_POPUP_RAM].ob_x + dial[RAM_POPUP_RAM].ob_width;
	}*/

	/* position des elements de la liste des buffer de sprite */
	{
		int16 idx;

		/* on positionne la premiere ligne */
		dial[RAM_LIGNE1].ob_x = FCM_RESCALE_MARGE_GAUCHE;
		/*dial[RAM_LIGNE1].ob_y = dial[RAM_TYPE_RAM].ob_y + dial[RAM_TYPE_RAM].ob_height + FCM_RESCALE_INTERLIGNE + 2;*/
		dial[RAM_LIGNE1].ob_y = FCM_RESCALE_MARGE_HAUT;

		dial[RAM_LIGNE1+1].ob_x = dial[RAM_LIGNE1].ob_x + dial[RAM_LIGNE1].ob_width + FCM_RESCALE_ESPACE;
		dial[RAM_LIGNE1+1].ob_y = dial[RAM_LIGNE1].ob_y;

		dial[RAM_LIGNE1+2].ob_x = dial[RAM_LIGNE1+1].ob_x + dial[RAM_LIGNE1+1].ob_width + FCM_RESCALE_ESPACE;
		dial[RAM_LIGNE1+2].ob_y = dial[RAM_LIGNE1].ob_y;

/*		dial[RAM_LIGNE1+3].ob_x = dial[RAM_LIGNE1+2].ob_x + dial[RAM_LIGNE1+2].ob_width + FCM_RESCALE_ESPACE;
		dial[RAM_LIGNE1+3].ob_y = dial[RAM_LIGNE1].ob_y;*/

		/*form_w = MAX( form_w, (dial[RAM_LIGNE1+2].ob_x + dial[RAM_LIGNE1+2].ob_width) );*/
		form_w = dial[RAM_LIGNE1+2].ob_x + dial[RAM_LIGNE1+2].ob_width;


		for( idx=RAM_LIGNE1+3; idx<RAM_LIGNE_END; idx=idx+3 )
		{
			/* et les autres en fonction de la premiere / precedente */
			dial[idx].ob_x = dial[RAM_LIGNE1].ob_x;
			dial[idx].ob_y = dial[idx-1].ob_y + dial[idx-1].ob_height;

			dial[idx+1].ob_x = dial[RAM_LIGNE1+1].ob_x;
			dial[idx+1].ob_y = dial[idx].ob_y;

			dial[idx+2].ob_x = dial[RAM_LIGNE1+2].ob_x;
			dial[idx+2].ob_y = dial[idx].ob_y;

/*			dial[idx+3].ob_x = dial[RAM_LIGNE1+3].ob_x;
			dial[idx+3].ob_y = dial[idx].ob_y;*/
		}
	}

	dial[RAM_FOND].ob_width  = form_w + FCM_RESCALE_MARGE_DROITE;
	dial[RAM_FOND].ob_height = dial[RAM_LIGNE_END].ob_y + dial[RAM_LIGNE_END].ob_height + FCM_RESCALE_MARGE_BAS;

	return;

}

