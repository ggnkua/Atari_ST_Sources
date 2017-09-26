WORD	ParseFtpUrl( BYTE *Url, SESSION *Session );
BYTE	*MakeFtpUrl( BYTE *Host, WORD Port, BYTE *Uid, BYTE *Pwd, BYTE *Dir );
WORD cdecl	HandleNoFtpUrlDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
