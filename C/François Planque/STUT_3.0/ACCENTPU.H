/*
 * Accents:
 */
	extern	void	init_accents( void );
	extern	char	*convert_Asc2Vdt( 		/* Out: Ptr sur tampon de caractäres Çquivalents */
							char	c_ascii );		/* In:  caractäre Ö traduire */
	extern	char	convert_G2toAsc( 			/* Out: caractäre Çquivalent */
							char	c_ascii );		/* In:  caractäre Ö traduire */
	extern	char	convert_Compose2Asc( 	/* Out: caractäre Çquivalent */
							char	c_accent,		/* In:  accent Ö composer */
							char	c_car );			/* In:  caractäre Ö composer */
