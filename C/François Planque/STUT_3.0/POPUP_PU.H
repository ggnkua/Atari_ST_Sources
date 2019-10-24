/*
 * popup_Public.h
 */

#ifndef _POPUP_PU_H_
#define _POPUP_PU_H_

#include "POPUP.H"

	/* 
	 * Pop-Up:
	 */
	extern	void	PopUp_Init( void );
	extern	int	popup_inform( OBJECT *call_form, int call_obj, int title_obj, POPUP_ENTRY *entries, int current_val );
	const char * get_popup_name( 			/* Out: Nom correspondant ou "" */
			POPUP_ENTRY *	entries, 	/* In:  Menu Pop-Up */
			int 				n_val );		/* In:  Valeur … rechercher */
	int	Popup_GetCurrVal( 
			OBJECT		*	popup_title );	/* In: Objet titre de Menu */
	extern	void	fix_popup_title( OBJECT	*popup_title, POPUP_ENTRY *entries, int current_val );

#endif

