/*
 * Accents:
 */
	extern	void	init_accents( void );
	extern	char	*convert_Asc2Vdt( 		/* Out: Ptr sur tampon de caract�res �quivalents */
							char	c_ascii );		/* In:  caract�re � traduire */
	extern	char	convert_G2toAsc( 			/* Out: caract�re �quivalent */
							char	c_ascii );		/* In:  caract�re � traduire */
	extern	char	convert_Compose2Asc( 	/* Out: caract�re �quivalent */
							char	c_accent,		/* In:  accent � composer */
							char	c_car );			/* In:  caract�re � composer */
