/*
 * Sercom_Public.h
 */

BOOL	extract_number(					/* Out: TRUE si OK */
			const char * cpsz,			/* In:  chaine de caractŠres */
			long		  * pl_number );	/* Out: nombre trouv‚ */

BOOL	serv_handleKeyword(							/* Out: FALSE0 si pas de mot clef … traiter */
			VOIE	*	pVoie_curr,					/* In: Voie concern‚e */
			char		c_KeywordIdentifier );	/* In: car obligatoire en d‚but de champ pour indiquer que c'est un mot clef ou bien '\0' */

void	keyaction_std( KEYCODE curr_keypress, VOIE *pVoie_curr );

void	follow_KeyArboLink(
			VOIE *	pVoie_curr,			/* In: Voie en cours de traitement */
			KEYCODE	curr_keypress );	/* In: Code touche … suivre */
BOOL	follow_ArboLink(					/* In: TRUE_1 si OK */
				VOIE *	pVoie_curr,		/* In: Voie en cours de traitement */
				int		n_FnctLink );	/* In: Fonction lien demand‚e */
