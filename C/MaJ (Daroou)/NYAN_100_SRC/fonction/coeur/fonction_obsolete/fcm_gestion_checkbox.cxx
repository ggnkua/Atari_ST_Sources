/* **[Fonction commune]******** */
/* *                          * */
/* * 04/01/2013 = 04/03/2021  * */
/* **************************** */



#ifndef __Fcm_gestion_checkbox__
#define __Fcm_gestion_checkbox__ 




#include "fcm_objet_draw.c"
#include "fcm_mouse_no_bouton.c"




/* Prototypes */
int16 Fcm_gestion_checkbox( OBJECT *adr_formulaire,  const int16 handle_win, const int16 objet);


/* Fonction */
int16 Fcm_gestion_checkbox( OBJECT *adr_formulaire,  const int16 handle_win, const int16 objet)
{
/*
 *
 */


	#ifdef LOG_FILE
	sprintf( buf_log, "#Fcm_gestion_checkbox(%p,%d,%d)"CRLF,adr_formulaire,handle_win,objet );
	log_print(FALSE);
	#endif



	/* on v‚rifie l'‚tat du bouton avant de */
	/* modifier quoi que ce soit            */
	if( ((adr_formulaire+objet)->ob_state & OS_DISABLED) == 0 )
	{
		/* Si l'objet n'est pas d‚sactiv‚ on change son ‚tat */
		if( (adr_formulaire+objet)->ob_state & OS_SELECTED )
		{
			/* on le d‚s‚lectionne ... */
			SET_BIT_W( (adr_formulaire+objet)->ob_state, OS_SELECTED, 0);
		}
		else
		{
			/* on le s‚lectionne ... */
			SET_BIT_W( (adr_formulaire+objet)->ob_state, OS_SELECTED, 1);
		}

		/* On red‚ssinne l'objet */
		Fcm_objet_draw( adr_formulaire, handle_win, objet, FCM_WU_BLOCK );

		/* Si l'utilisateur a le doigt lourd... */
		Fcm_mouse_no_bouton();

	}

	/* On retourne l'‚tat de l'objet */
	/* 0  -> non s‚lectionn‚         */
	/* !0 -> s‚lectionn‚             */
	return( ((adr_formulaire+objet)->ob_state & OS_SELECTED) );


}


#endif

