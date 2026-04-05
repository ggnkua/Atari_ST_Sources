/* **[Pupul]****************** */
/* *                           * */
/* * 09/08/2017 MaJ 09/11/2023 * */
/* ***************************** */



#include "../fonction/coeur/Fcm_rescale_def.h"



/* Prototype */
void rescale_rsc_mod( void );



/* Fonction */
void rescale_rsc_mod( void )
{

	OBJECT	*dial;
	int16    form_w;
	int16	 gr_hwcar, gr_hhcar;
//	int16    checkbox_size;



	/* Marre que le formulaire s'affiche mal d'une resolution a l'autre */
	/* tous les objets et le fond sont repositionner                    */

	#ifdef LOG_FILE
	sprintf( buf_log, "#rescale_rsc_mod()"CRLF );
	log_print(FALSE);
	#endif


	/* espace occupé par les caracteres de la fonte systeme */
	{
		int16 dummy;

		graf_handle( &gr_hwcar, &gr_hhcar, &dummy, &dummy );
	}


	/* on cherche l'adresse du formulaire et l'objet sous la souris */
	rsrc_gaddr( R_TREE, DL_MODLDG, &dial );






	/* position du pop up Mise à jour MOD et de son label */
	{
		dial[MOD_UPDATE_LABEL].ob_x = FCM_RESCALE_MARGE_GAUCHE;
		dial[MOD_UPDATE_LABEL].ob_y = FCM_RESCALE_MARGE_GAUCHE;

		dial[MOD_UPDATE_POPUP].ob_x = dial[MOD_UPDATE_LABEL].ob_x + dial[MOD_UPDATE_LABEL].ob_width + FCM_RESCALE_ESPACE;
		dial[MOD_UPDATE_POPUP].ob_y = dial[MOD_UPDATE_LABEL].ob_y;

		form_w = dial[MOD_UPDATE_POPUP].ob_x + dial[MOD_UPDATE_POPUP].ob_width;
	}


	/* position du pop up frequence MOD et de son label */
	{
		dial[MOD_FREQ_LABEL].ob_x = FCM_RESCALE_MARGE_GAUCHE;
		dial[MOD_FREQ_LABEL].ob_y = dial[MOD_UPDATE_POPUP].ob_y + dial[MOD_UPDATE_POPUP].ob_height + FCM_RESCALE_INTERLIGNE + FCM_RESCALE_INTERLIGNE;

		dial[MOD_FREQ_POPUP].ob_x = dial[MOD_FREQ_LABEL].ob_x + dial[MOD_FREQ_LABEL].ob_width + FCM_RESCALE_ESPACE;
		dial[MOD_FREQ_POPUP].ob_y = dial[MOD_FREQ_LABEL].ob_y;

		form_w = MAX( form_w, (dial[MOD_FREQ_POPUP].ob_x + dial[MOD_FREQ_POPUP].ob_width) );
	}


	/* bouton sauver */
	{
		dial[MOD_BT_SAUVER].ob_x = (form_w - dial[MOD_BT_SAUVER].ob_width) / 2;
		dial[MOD_BT_SAUVER].ob_y = dial[MOD_FREQ_POPUP].ob_y + dial[MOD_FREQ_POPUP].ob_height + FCM_RESCALE_INTERLIGNE + FCM_RESCALE_INTERLIGNE;

		form_w = MAX( form_w, (dial[MOD_BT_SAUVER].ob_x + dial[MOD_BT_SAUVER].ob_width) );
	}

	dial[MODLDG_FOND].ob_width  = form_w + FCM_RESCALE_MARGE_DROITE;
	dial[MODLDG_FOND].ob_height = dial[MOD_BT_SAUVER].ob_y + dial[MOD_BT_SAUVER].ob_height + FCM_RESCALE_INTERLIGNE + FCM_RESCALE_MARGE_BAS;


	return;

}

