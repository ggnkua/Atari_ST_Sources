/* **[Fonction Coeur]*********** */
/* *                           * */
/* * 30/12/2016 MaJ 29/11/2025 * */
/* ***************************** */



#ifndef __FCM_GESTION_BIT_OBJET_C__
#define __FCM_GESTION_BIT_OBJET_C__ 


uint16   Fcm_gestion_bit_objet( OBJECT *adr_formulaire,  const int16 handle_win, const uint16 objet, const uint16 id_bit )
{

	FCM_LOG_PRINT4("* Fcm_gestion_bit_objet(%p,%d,%d,$%x)", adr_formulaire,handle_win,objet, id_bit);

	/* on v‚rifie l'‚tat du bouton avant de */
	/* modifier quoi que ce soit            */
	if( (adr_formulaire[objet].ob_state & OS_DISABLED) == 0 )
	{
		/* Si l'objet n'est pas d‚sactiv‚ on change son ‚tat */
		if( adr_formulaire[objet].ob_state & id_bit )
		{
			/* on le d‚s‚lectionne ... */
			SET_BIT_W( adr_formulaire[objet].ob_state, id_bit, 0);
		}
		else
		{
			/* on le s‚lectionne ... */
			SET_BIT_W( adr_formulaire[objet].ob_state, id_bit, 1);
		}

		/* On red‚ssinne l'objet */
		Fcm_objet_draw( adr_formulaire, handle_win, objet, FCM_WU_BLOCK );

		/* Si l'utilisateur a le doigt lourd... */
		Fcm_mouse_no_bouton();
	}
	else
	{
		FCM_CONSOLE_DEBUG("Fcm_gestion_bit_objet() : objet OS_DISABLED");
	}


	/* On retourne l'‚tat de l'objet */
	/* 0  -> non s‚lectionn‚         */
	/* !0 -> s‚lectionn‚             */
	return( (adr_formulaire[objet].ob_state & id_bit) );


}


#endif  /*   __FCM_GESTION_BIT_OBJET_C__   */

