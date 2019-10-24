/*
 * DataBase_Interface_Public.h
 */
 
	BOOL	CompRec_Erase(										/* Out: TRUE if success */
			VOIE 				*	pVoie_curr,					/* In:  Voie concern‚e */
			COMPACT_RECORD *	pCompactRec_toKill,		/* In:  Ptr sur le Record … supprimer */
			DATAPAGE			*	pDataPage_DB );			/* In:  Base de donn‚es concern‚e */

	RECORD_FLAGS CompRec_GetRecFlags(					/* Out: Flags du record, tout est … z‚ro si yen a pas */
					COMPACT_RECORD	*	PCompactRecord );	/* In: Record dont on veut connaitre les flags */

	RECORD_FIELD	*	Create_TextRecFld( 				/* Out: Champ de DB cr‚‚ */
		const	ULONG			cUL_FieldId,					/* In:  Identificateur du champ */
		const IOFIELD	*	cpInField );					/* In:  Champ de saisie dont on doit ins‚rer le contenu */

	void	DBInt_AppendCompRecToDB(
			VOIE 				*	pVoie_curr,					/* In:  Voie concern‚e */
			COMPACT_RECORD *	pCompactRec,				/* In: Ptr sur le Record … ajouter */
			DATAPAGE			*	pDataPage_DB );			/* In: Base de donn‚es concern‚e */


	void	DBInt_AddLockToList(
			VOIE *				pVoie_curr,					/* In:  Voie concern‚e */
			COMPACT_RECORD *	pCompRec ); 				/* In:  Ptr sur record … d‚locker */
	void	DBInt_RemoveLockFromList(
			VOIE *				pVoie_curr,					/* In:  Voie concern‚e */
			COMPACT_RECORD *	pCompRec ); 				/* In:  Ptr sur record … d‚locker */
	COMPACT_RECORD *	DBInt_requestReadLock( 			/* Out: NULL si imposs, sinon ptr sur locked rec */
				VOIE *				pVoie_curr,				/* In: Voie concern‚e */
				COMPACT_RECORD *	pCompRec ); 			/* In:  Ptr sur record … locker */
	void	DBInt_releaseReadLock(
			VOIE *				pVoie_curr,					/* In: Voie concern‚e */
			COMPACT_RECORD *	pCompRec ); 				/* In:  Ptr sur record … d‚locker */
	int	DBInt_changeReadToXLock( 						/* Out: !=0 si impossible */
			VOIE *				pVoie_curr,					/* In: Voie concern‚e */
			COMPACT_RECORD *	pCompRec ); 				/* In:  Ptr sur record … locker */
	void	DBInt_releaseXLock(
			VOIE *				pVoie_curr,					/* In: Voie concern‚e */
			COMPACT_RECORD *	pCompRec ); 				/* In: Ptr sur record … d‚locker */
	void	DBInt_ReleaseAllLocks(
			VOIE *				pVoie_curr );				/* In: Voie concern‚e */
