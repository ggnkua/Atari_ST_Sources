/* **[Nyancat]****************** */
/* *                           * */
/* * 09/08/2017 MaJ 06/11/2023 * */
/* ***************************** */



#include "../fonction/coeur/Fcm_rescale_def.h"



/* Prototype */
void rescale_rsc_options( void );



/* Fonction */
void rescale_rsc_options( void )
{

	OBJECT	*dial;
	int16    form_w;
	int16	 gr_hwcar, gr_hhcar;
	int16    checkbox_size;



	/* Marre que le formulaire s'affiche mal d'une resolution a l'autre */
	/* tous les objets et le fond sont repositionner                    */

	#ifdef LOG_FILE
	sprintf( buf_log, "#FCM_RESCALE_rsc_options()"CRLF );
	log_print(FALSE);
	#endif


	/* espace occupé par les caracteres de la fonte systeme */
	{
		int16 dummy;

		graf_handle( &gr_hwcar, &gr_hhcar, &dummy, &dummy );
	}


	/* on cherche l'adresse du formulaire et l'objet sous la souris */
	rsrc_gaddr( R_TREE, DL_OPTIONS, &dial );


	checkbox_size = MAX( 8, FCM_RESCALE_WCHAR);


	/* activation cache */
	{
		dial[CHECK_CACHEIMG].ob_width = checkbox_size;
		dial[CHECK_CACHEIMG].ob_height = FCM_RESCALE_HCHAR;

		dial[CHECK_CACHEIMG].ob_x = FCM_RESCALE_MARGE_GAUCHE;
		dial[CHECK_CACHEIMG].ob_y = FCM_RESCALE_MARGE_HAUT;

		dial[OPTION_CACHEIMG].ob_x = dial[CHECK_CACHEIMG].ob_x + dial[CHECK_CACHEIMG].ob_width + FCM_RESCALE_ESPACE;
		dial[OPTION_CACHEIMG].ob_y = dial[CHECK_CACHEIMG].ob_y;

		form_w = dial[OPTION_CACHEIMG].ob_x + dial[OPTION_CACHEIMG].ob_width;
	}

	/* Chemin cache */
	{
		dial[OPTION_PATHCACHE].ob_x = dial[OPTION_CACHEIMG].ob_x;
		dial[OPTION_PATHCACHE].ob_y = dial[CHECK_CACHEIMG].ob_y + dial[CHECK_CACHEIMG].ob_height + FCM_RESCALE_INTERLIGNE;

		form_w = MAX( form_w, (dial[OPTION_PATHCACHE].ob_x + dial[OPTION_PATHCACHE].ob_width) );
	}
	
	/* Force monochrome */
	{
		dial[CHECK_FORCEMONO].ob_width = checkbox_size;
		dial[CHECK_FORCEMONO].ob_height = FCM_RESCALE_HCHAR;

		dial[CHECK_FORCEMONO].ob_x = FCM_RESCALE_MARGE_GAUCHE;
		dial[CHECK_FORCEMONO].ob_y = dial[OPTION_PATHCACHE].ob_y + dial[OPTION_PATHCACHE].ob_height + FCM_RESCALE_INTERLIGNE;

		dial[OPTION_FORCEMONO].ob_x = dial[CHECK_FORCEMONO].ob_x + dial[CHECK_FORCEMONO].ob_width + FCM_RESCALE_ESPACE;
		dial[OPTION_FORCEMONO].ob_y = dial[CHECK_FORCEMONO].ob_y;

		form_w = MAX( form_w, (dial[OPTION_FORCEMONO].ob_x + dial[OPTION_FORCEMONO].ob_width) );
	}

	/* animation max speed */
	{
		dial[CHECK_MAXFPS].ob_width = checkbox_size;
		dial[CHECK_MAXFPS].ob_height = FCM_RESCALE_HCHAR;

		dial[CHECK_MAXFPS].ob_x = FCM_RESCALE_MARGE_GAUCHE;
		dial[CHECK_MAXFPS].ob_y = dial[OPTION_FORCEMONO].ob_y + dial[OPTION_FORCEMONO].ob_height + FCM_RESCALE_INTERLIGNE;

		dial[OPTION_MAXFPS].ob_x = dial[CHECK_MAXFPS].ob_x + dial[CHECK_MAXFPS].ob_width + FCM_RESCALE_ESPACE;
		dial[OPTION_MAXFPS].ob_y = dial[CHECK_MAXFPS].ob_y;

		form_w = MAX( form_w, (dial[OPTION_MAXFPS].ob_x + dial[OPTION_MAXFPS].ob_width) );
	}

	/* couper le son */
	{
		dial[CHECK_MUTESOUND].ob_width = checkbox_size;
		dial[CHECK_MUTESOUND].ob_height = FCM_RESCALE_HCHAR;

		dial[CHECK_MUTESOUND].ob_x = FCM_RESCALE_MARGE_GAUCHE;
		dial[CHECK_MUTESOUND].ob_y = dial[OPTION_MAXFPS].ob_y + dial[OPTION_MAXFPS].ob_height + FCM_RESCALE_INTERLIGNE;

		dial[OPTION_MUTESOUND].ob_x = dial[CHECK_MUTESOUND].ob_x + dial[CHECK_MUTESOUND].ob_width + FCM_RESCALE_ESPACE;
		dial[OPTION_MUTESOUND].ob_y = dial[CHECK_MUTESOUND].ob_y;

		form_w = MAX( form_w, (dial[OPTION_MUTESOUND].ob_x + dial[OPTION_MUTESOUND].ob_width) );
	}


	/* modifier palette */
	{
		dial[CHECK_PALETTE].ob_width = checkbox_size;
		dial[CHECK_PALETTE].ob_height = FCM_RESCALE_HCHAR;

		dial[CHECK_PALETTE].ob_x = FCM_RESCALE_MARGE_GAUCHE;
		dial[CHECK_PALETTE].ob_y = dial[OPTION_MUTESOUND].ob_y + dial[OPTION_MUTESOUND].ob_height + FCM_RESCALE_INTERLIGNE;

		dial[OPTION_PALETTE].ob_x = dial[CHECK_PALETTE].ob_x + dial[CHECK_PALETTE].ob_width + FCM_RESCALE_ESPACE;
		dial[OPTION_PALETTE].ob_y = dial[CHECK_PALETTE].ob_y;

		form_w = MAX( form_w, (dial[OPTION_PALETTE].ob_x + dial[OPTION_PALETTE].ob_width) );
	}



	/* offscreen framebuffer */
	{
		dial[CHECK_FRAME_BUF].ob_width = checkbox_size;
		dial[CHECK_FRAME_BUF].ob_height = FCM_RESCALE_HCHAR;

		dial[CHECK_FRAME_BUF].ob_x = FCM_RESCALE_MARGE_GAUCHE;
		dial[CHECK_FRAME_BUF].ob_y = dial[OPTION_PALETTE].ob_y + dial[OPTION_PALETTE].ob_height + FCM_RESCALE_INTERLIGNE;

		dial[OPTION_FRAME_BUF].ob_x = dial[CHECK_FRAME_BUF].ob_x + dial[CHECK_FRAME_BUF].ob_width + FCM_RESCALE_ESPACE;
		dial[OPTION_FRAME_BUF].ob_y = dial[CHECK_FRAME_BUF].ob_y;

		form_w = MAX( form_w, (dial[OPTION_FRAME_BUF].ob_x + dial[OPTION_FRAME_BUF].ob_width) );
	}


	/* position du pop up RAM et de son label */
	{
		dial[RAM_TYPE_RAM].ob_x = FCM_RESCALE_MARGE_GAUCHE;
		dial[RAM_TYPE_RAM].ob_y = dial[OPTION_FRAME_BUF].ob_y + dial[OPTION_FRAME_BUF].ob_height + FCM_RESCALE_INTERLIGNE;;

		dial[RAM_POPUP_RAM].ob_x = dial[RAM_TYPE_RAM].ob_x + dial[RAM_TYPE_RAM].ob_width + FCM_RESCALE_ESPACE;
		dial[RAM_POPUP_RAM].ob_y = dial[RAM_TYPE_RAM].ob_y;

		form_w = MAX( form_w, (dial[RAM_POPUP_RAM].ob_x + dial[RAM_POPUP_RAM].ob_width) );
	}


	/* position du pop up PIXEL et de son label */
	{
		dial[OPTION_PIXEL_TXT].ob_x = FCM_RESCALE_MARGE_GAUCHE;
		dial[OPTION_PIXEL_TXT].ob_y = dial[RAM_POPUP_RAM].ob_y + dial[RAM_POPUP_RAM].ob_height + FCM_RESCALE_INTERLIGNE + FCM_RESCALE_INTERLIGNE;

		dial[OPTION_POPUP_PIX].ob_x = dial[OPTION_PIXEL_TXT].ob_x + dial[OPTION_PIXEL_TXT].ob_width + FCM_RESCALE_ESPACE;
		dial[OPTION_POPUP_PIX].ob_y = dial[OPTION_PIXEL_TXT].ob_y;

		form_w = MAX( form_w, (dial[OPTION_POPUP_PIX].ob_x + dial[OPTION_POPUP_PIX].ob_width) );
	}


	/* bouton sauver */
	{
		dial[OPTION_SAUVER].ob_x = (form_w - dial[OPTION_SAUVER].ob_width) / 2;
		dial[OPTION_SAUVER].ob_y = dial[OPTION_POPUP_PIX].ob_y + dial[OPTION_POPUP_PIX].ob_height + FCM_RESCALE_INTERLIGNE + FCM_RESCALE_INTERLIGNE;

		form_w = MAX( form_w, (dial[OPTION_SAUVER].ob_x + dial[OPTION_SAUVER].ob_width) );
	}

	dial[OPTION_FOND].ob_width  = form_w + FCM_RESCALE_MARGE_DROITE;
	dial[OPTION_FOND].ob_height = dial[OPTION_SAUVER].ob_y + dial[OPTION_SAUVER].ob_height + FCM_RESCALE_INTERLIGNE + FCM_RESCALE_MARGE_BAS;


	return;

}

