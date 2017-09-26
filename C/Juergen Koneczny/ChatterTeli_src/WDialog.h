#ifndef	__WDIALOG__
#define	__WDIALOG__

#define	EDRX	-1


typedef	WORD	( *HNDL_DD_DIALOG )( void *DialogData, EVNT *Events, WORD Global[15] );
typedef	WORD	( *HNDL_CLS_DIALOG )( void *DialogData, WORD Global[15] );
typedef	WORD	( *HNDL_MESAG_DIALOG )( void *DialogData, EVNT *Events, WORD Global[15] );
typedef	WORD	( *HNDL_EDIT_DIALOG )( void *DialogData, EVNT *Events, WORD Global[15] );
typedef	WORD	( *HNDL_HELP_DIALOG )( void *DialogData, EVNT *Events, WORD Global[15] );
typedef	WORD	( *HNDL_TIMER_DIALOG )( void *DialogData, WORD Global[15] );
typedef	WORD	( *HNDL_CHECK_DIALOG )( void *DialogData, EVNT *Events, WORD Global[15] );

typedef	struct
{
	DIALOG	*Dialog;
	OBJECT	*Tree;
	WORD		TreeIndex;
	HNDL_DD_DIALOG	HndlDdDialog;
	HNDL_CLS_DIALOG HndlClsDialog;
	HNDL_MESAG_DIALOG	HndlMesagDialog;
	HNDL_EDIT_DIALOG	HndlEditDialog;
	HNDL_HELP_DIALOG HndlHelpDialog;
	HNDL_TIMER_DIALOG HndlTimerDialog;
	HNDL_CHECK_DIALOG HndlCheckDialog;
	void		*UserData;
}	DIALOG_DATA;

typedef	void	( *CLS_ALERT_DIALOG )( void *UserData, WORD Button, WORD WinId, WORD Global[15] );

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
void	DoRedraw( DIALOG *Dialog, GRECT *Rect, WORD Obj, WORD Global[15] );
void	DoRedrawX( DIALOG *Dialog, GRECT *Rect, WORD Global[15], ... );
WORD	OpenDialog( BYTE *TitelStr, WORD Type, HNDL_OBJ HandleDialog, DIALOG_DATA *DialogData, WORD Global[15] );
WORD	OpenDialogX( BYTE *TitelStr, WORD Type, WORD Elements, WORD x, WORD y, HNDL_OBJ HandleDialog, DIALOG_DATA *DialogData, WORD Global[15] );
void	CloseDialog( DIALOG_DATA *DialogData, WORD Global[15] );
WORD	HandleWDialogIcon( WORD *Obj, DIALOG *Dialog, WORD Global[15] );
WORD	HandleWdialog( WORD WinId, EVNT *Events, void *UserData, WORD Global[15] );
WORD	URL_Action( OBJECT *Tree, WORD Obj, WORD Global[15] );
ULONG	MenuKontextDialog( WORD WinId, WORD Global[15] );
WORD	AlertDialogX( WORD DefaultButton, BYTE *Str, BYTE *Titel, CLS_ALERT_DIALOG CloseAlertDialog, void *UserData, WORD Global[15], WORD nPar, ... );
#define	AlertDialog( a, b, c, d, e, f ) \
	AlertDialogX( a, b, c, d, e, f, 0 )
#define	ALERT_DIALOG_MAX_LEN	50
#endif