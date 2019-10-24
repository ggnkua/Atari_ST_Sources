/*
 * Server_FileSelect_Public.h
 */
 
void	FileSel_ENPG(
			VOIE	*	pVoie_curr );		/* In: Voie concern‚e */
void	FileSel_DispData(
			VOIE *	pVoie_curr );		/* In: Voie concern‚e */
void	FileSel_DispRec(
			VOIE *	pVoie_curr );	/* In: Voie concern‚e */
void	FileSel_DispPage(
			VOIE *	pVoie_curr );		/* In: Voie concern‚e */
void	FileSel_KeyAction( 
			KEYCODE	curr_keypress, /* In: Touche press‚e */
			VOIE	*	pVoie_curr );	/* In: Voie concern‚e */
