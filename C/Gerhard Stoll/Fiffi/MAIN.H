/* [GS] 1.50a Start */
#define	FiffiVersion	"1.50b"
/* End; old:
#define	FiffiVersion	"1.30"
*/

/* [GS] 1.50a Start */
#define UNUSED(x)   (void)(x)
/* Ende */

/* Xmalloc-Modes: */

#define RAM_MALLOC -1	/* "Pseudo"-Mode: Statt Mxalloc Malloc nehmen */
#define RAM_ST 0
#define RAM_TT 1
#define RAM_BETTER_ST 2
#define RAM_BETTER_TT 3

#define RAM_PRIVATE  0x00
#define RAM_GLOBAL   0x10
#define RAM_SUPER    0x20
#define RAM_READABLE 0x30

#define	SHW_THR_EXIT	21
#define	SHW_THR_KILL	22

#define	EDRX				-1
#define	Main_Shutdown	0x7000
#define	Main_Top			0x7001

#define	InputText_Msg	0x7002
#define	InputText_Open	0x0001

#define	Fsel_Msg			0x7003
#define	Fsel_Open		0x0001
#define	Fsel_Conf_Rx	0x000a
#define	Fsel_Conf_Tx	0x000b
#define	Fsel_Conf_Log	0x000c

#define	Main_UpdateMenu	0x7004
#define	DragDropUrl			0x7005

#ifdef	GEMScript
#define	GS_CONNECTION	0x7006
#endif

#define	DRAGDROP			0x7007

#define	Con(a) Cconws(a)
#define	crlf Con("\r\n")
#define	MemErr(a)	Con( "insufficient memory: " ); Con( a ); crlf

#define	EditLen	127
#define	FileLen	128
#define	PathLen	256

#define	SORT_DIR_LIST_ON			0x01
#define	SORT_DIR_LIST_DESKTOP	0x02
#define	SORT_DIR_LIST_BYNAME		0x04

#ifdef	V110
#define	ICONNECT_START				0x01
#define	ICONNECT_CONNECT			0x02
#define	ICONNECT_DISCONNECT_LAST_SESSION		0x04
#define	ICONNECT_DISCONNECT		0x08
#endif

/*-----------------------------------------------------------------------------*/
/* Strukturdefinitionen                                                        */
/*-----------------------------------------------------------------------------*/
typedef struct
{
	LONG	id;
	LONG	value;
}	COOKIE;

typedef struct _str_item
{
	struct	_str_item	*next;
	WORD		selected;
	BYTE		*str;
} STR_ITEM;

typedef struct
{
#ifdef	V120
	BYTE	*Name;
#endif
	BYTE	*Host;
	UWORD	Port;
	BYTE	*Uid;
	BYTE	*Pwd;
	BYTE	*Dir;
	BYTE	*Comment;
} SESSION;

typedef struct _Thread_Info_Item
{
	struct	_Thread_Info_Item	*next;
	WORD		AppId;
#ifdef	GEMScript
	WORD		MainWinId;
	BYTE		*Url;
#endif
} ThreadInfoItem;

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
void 			*Xmalloc(long len, int mode);
WORD			OpenScreenWk( WORD AesHandle, WORD *WorkOut);
void			InitRsrc( OBJECT ***TreeAddr, BYTE ***FstringAddr, WORD Global[15] );
void			SetSliderBorders( OBJECT **TreeAddr );
void			DoRedraw( DIALOG *Dialog, GRECT *Rect, WORD Obj, WORD Global[15] );
void			DoRedrawX( DIALOG *Dialog, GRECT *Rect, WORD Global[15], ... );
DIALOG		*OpenDialog( OBJECT *DialogTree, BYTE *TitelStr, HNDL_OBJ HandleDialog, void *UserData, WORD Global[15] );
void			CloseDialog( DIALOG *Dialog, WORD Global[15] );
WORD cdecl	SetStrItem( LIST_BOX *Box, OBJECT *Tree, LBOX_ITEM *Item, WORD Index, void *user_data, GRECT *Rect, WORD Offset );
void			ScrapDirCutTxt( BYTE *Txt, WORD Global[15] );
void			InstalMenuBar( void );
void			CreatePopupTree( OBJECT **Tree, WORD n, BYTE *T[] );
void			CreateSubmenuTree( OBJECT **Tree, WORD n, BYTE *T[] );
void			nCreatePopupTree( OBJECT **Tree, WORD n, BYTE *T[], WORD Width );
WORD			AvInit( BYTE *AppName, WORD Global[15] );
void			AvExit( WORD AvAppId, WORD Global[15] );
WORD			IsMenuKey( WORD Key, WORD *Title, WORD *Entry );
void			KeyEvent( WORD	Key, WORD Global[15] );
void			*WindowFileselector( WORD Flag, BYTE *Title, BYTE *Path, BYTE *File, WORD *FselHandle, WORD Global[15] );
DIALOG		*WindowInputText( BYTE *WindowTitle, BYTE *TextTitle, XTED *Xted, char *Tmplt, char *Txt, WORD Global[15] );
DIALOG		*WindowAlert( BYTE *Title, BYTE *Text, WORD DefaultButton, WORD Global[15] );
WORD	HandleIcon( WORD *Obj, DIALOG *Dialog, WORD Global[15] );
#ifdef DEBUG
void			DebugMsg( WORD Global[15], BYTE *Arg, ... );
#endif
WORD	cdecl	HandleDragDropFailedDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
void	*SearchCookie( LONG Id );
