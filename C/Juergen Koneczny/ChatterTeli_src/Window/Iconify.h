#ifndef	__WIN_ICONIFY__
#define	__WIN_ICONIY__

WORD	cdecl	HandleIconifyDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
ULONG	MenuKontextIconify( WORD WinId, WORD Global[15] );

#endif