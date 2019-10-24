/*
 * Generic_Public.h
 */

	void	OutFields_DisplayGroup(
				VOIE	*	pVoie_curr,			/* In: Voie concern‚e */
				UINT		u_GroupId,			/* In: Groupe … afficher */
				int		X_Offset,			/* In: Offsets … appliquer aux coordonn‚es des champs */			
				int		Y_Offset );
	void	Generic_DispData(
			VOIE *	pVoie_curr );	/* In: Voie concern‚e */
	void	Generic_DisplayPageChange(
			VOIE *	pVoie_curr );	/* In: Voie concern‚e */
	void	Generic_DispPage(
			VOIE *	pVoie_curr );	/* In: Voie concern‚e */
