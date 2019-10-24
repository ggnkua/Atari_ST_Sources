/*
 * Lecture_Messages_Public.h
 */


#ifndef LECTM_PU_H
#define LECTM_PU_H

#include "SERVEUR.H"

	void	LectMsg_ENPG(
			VOIE	*	pVoie_curr );		/* In: Voie concern‚e */
	void	LectMsg_OPDB(
			VOIE	*	pVoie_curr,		/* In: Voie concern‚e */
			int		n_fnct_base );	/* In: Fonction de la base de don‚es qu'on vient d'ouvrir */
	void	LectMsg_DispData(
			VOIE *	pVoie_curr );	/* In: Voie concern‚e */
	void	LectMsg_DispMsg( 
			VOIE *	pVoie_curr );
	void	LectMsg_KeyAction( KEYCODE curr_keypress, VOIE *pVoie_curr );
	BOOL	LectMsg_EraseCurrRec( 		/* Out: TRUE if success */
			VOIE *	pVoie_curr );	/* In: Voie qui demande l'effacement */

#endif