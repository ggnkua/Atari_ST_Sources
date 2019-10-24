/*
 * Special MALLOC library
 * Copyright (c)1995 by Fran‡ois PLANQUE
 *
 * Header contenant les prototypes et les macros n‚cessaires
 * … l'utilisation de la bibliothŠque.
 *
 * Include  #include "S_MALLOC.H" dans les modules … d‚buguer
 * puis utiliser MALLOC() … la place de malloc() etc...
 */
 
/*
 * Enlever cette ligne pour le mode RELEASE:
 */
#define	DEBUG_MALLOC

#ifdef	DEBUG_MALLOC	
	#define	MCHECK( x )			S_Check( x )
	#define	MALLOC( x )			S_malloc( x )
	#define	STRDUP( x )			S_strdup( x )
	#define	REALLOC( x, y )	S_realloc( x, y )
	#define	FREE( x )			S_free( x )

	extern	void * S_Check(				/* Out: adresse de la zone avec head & foot */
							void * p_manip );	/* In:  adresse de manipulation */

	extern	void * S_malloc( 				/* Out: Ptr sur la zone allou‚e (comme avec malloc()) */
							size_t size );		/* In:  taille dela zone … allouer */

	extern	char * S_strdup( 							/* Out: Ptr sur copie de la chaŒne */
							const char * cpsz_src );	/* In:  Ptr sur la chaŒne … dupliquer */

	extern	void * S_realloc( 			/* Out: Ptr sur la nouvelle zone allou‚e */
							void * p_manip, 	/* In:  Ptr sur une zone allou‚e */
							size_t size );		/* In:  Nouvelle taille d‚sir‚e pour cette zone */

	extern	void S_free( void * p_manip );	/* In: Ptr sur une zone m‚moire allou‚e */

	extern	void S_MemStat( void );

#else
	#define	MCHECK( x )			
	#define	MALLOC( x )			malloc( x )
	#define	STRDUP( x )			strdup( x )
	#define	REALLOC( x, y )	realloc( x, y )
	#define	FREE( x )			free( x )
#endif