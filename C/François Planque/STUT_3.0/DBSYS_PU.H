/*
 * DataBase_System_Public.h
 */

	#include	"DXF.H"

	extern	RECORD_NUMBER	G_RecNb_Null;


	void	init_dbsystem( void );

	COMPACT_RECORD * CompRec_Create(					/* Out: ptr sur record cr‚‚ */
							size_t	size_data );	/* In: taille des donn‚es … stocker */

	RECORD_FIELD	*	Create_HeaderFld(									/* Out: Champ cr‚‚ */
							const RECORD_NUMBER	*	pRecNb_Ref,		/* In:  Id du message auquel on fait r‚f‚rence */
							BOOL							b_Private );	/* In: !=0 si le message est priv‚ */

	RECORD_FIELD	*	Create_SimpleRecFld(					/* Out: champ cr‚‚ */
							unsigned	long	dw_FieldId,		/* In: Identificateur du champ */
							const char 	*	cpsz_Content );	/* In: texte … recopier DANS le champ */


	RECORD_FIELD	*	Create_FooterFld( void );	/* Out: Champ cr‚‚ */

	size_t	record_length( 
				RECORD_FIELD *field_ptr ); /* In: ptr sur champ header */

	COMPACT_RECORD *	Create_CompactRecord( 
							RECORD_FIELD 	*	field_ptr );

	void	Append_CompactRecToDB(
			COMPACT_RECORD *	pCompactRec,	/* In: Ptr sur le Record … ajouter */
			DATA_RECORDS	*	records );		/* In: Base de donn‚es concern‚e */

	COMPACT_FIELD * Find_FieldinCompactRecord(
		const	COMPACT_RECORD *	cpCompactRec,
		const ULONG 				cUL_FieldId );

	COMPACT_RECORD * Find_CompactRecByField( 
		const	COMPACT_RECORD *	cpCompactRec_Curr,	/* In: Ptr sur record o— doit commencer la recherche */
		const ULONG			 		cUL_FieldId,			/* In: Identifiant du champ qui sert de clef */
		const char 				*	cpsz_FieldContent );	/* In: Clef de recheche */

	void	clear_AllLocks( 						
							COMPACT_RECORD *pCompRec ); 	/* In:  Ptr sur record … initialiser */
	int	request_ReadLock( 				/* Out: !=0 si erreur */
							COMPACT_RECORD *pCompRec ); 	/* In:  Ptr sur record … locker */
	void	release_ReadLock(
							COMPACT_RECORD *pCompRec ); 	/* In:  Ptr sur record … d‚locker */
	int	change_ReadToXLock( 					/* Out: !=0 si impossible */
							COMPACT_RECORD *pCompRec ); 	/* In:  Ptr sur record … locker */
	void	release_XLock(
							COMPACT_RECORD *pCompRec ); 	/* In:  Ptr sur record … d‚locker */
