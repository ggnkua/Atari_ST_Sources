/*-----------------------------------------------------------------------------*/
/* Strukturdefinitionen                                                        */
/*-----------------------------------------------------------------------------*/

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
WORD	cdecl	HandleHotlistDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
#if	defined( KEY ) || defined( V110 )
WORD cdecl	HandleDoubleHtDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
WORD	cdecl	HandleInsertHtDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
void	UpdateHotlistDialog( DIALOG *Dialog );
#endif
WORD	InsertHtItem( BYTE *Name, BYTE *Host, WORD Port, BYTE *Uid, BYTE *Pwd, BYTE *Dir, BYTE *Comment );
WORD	ExistHtItem( BYTE *Name );
#ifdef	V110
void	FreeSession( SESSION	*Session );
#endif
