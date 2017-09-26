WORD	GetDragDrop( EVNT *Events, ULONG	FormatRcvr[8], ULONG *Format, BYTE **RetPuf, LONG *Size );
WORD	PutDragDrop( WORD WinId, WORD X, WORD Y, WORD Key, WORD AppId, ULONG Format, BYTE *Puf, LONG Size, WORD Global[15] );
void	NoDragDrop( EVNT *Events );
