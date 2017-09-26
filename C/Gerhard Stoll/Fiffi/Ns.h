/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
WORD	cdecl	HandleNewSessionDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
#ifdef	V110
void	InsertNsItem( BYTE *Host, WORD Port, BYTE *Uid, BYTE *Pwd, BYTE *Dir, DIALOG *Dialog );
#endif