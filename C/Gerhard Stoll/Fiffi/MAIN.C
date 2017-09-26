#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<MT_AES.H>
#include <VDI.H>
#include <STDDEF.H>
#include <STDLIB.H>
#include <STDIO.H>
#include	<STRING.H>
#include	<EXT.H>
#include <CTYPE.H>

#include	<av.h>
#ifdef	GEMScript
#include	<gscript.h>
#endif
#include	<atarierr.h>
#ifdef	V110
#include	<ICON_MSG.H>
#include <sockinit.h>
#endif

#include "ADAPTRSC.h"
#include "dragdrop.h"
#include	"edscroll.h"
#include "mapkey.h"
#ifdef	V110
#include	"DD.h"
#endif

#include "main.h"
#include "Register.h"
#include	"Window.h"
#include	"Config.h"
#include	"Ns.h"
#include "Hotlist.h"
#include "Suffix.h"
#include "GemFtp.h"
#include	"Url.h"
#include "Fiffi.h"

#define	GS_CNT	18

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	magic_version;
extern LONG	magic_date;

/*-----------------------------------------------------------------------------*/
/* Globale Variablen                                                           */
/*-----------------------------------------------------------------------------*/
int		GemdosVersion;
WORD		Global[15];
WORD		AppId, AesHandle, VdiHandle;
WORD		AvAppId = -1;
OBJECT	**TreeAddr;
BYTE		**FstringAddr;
WORD		AesFlags, AesFont, AesHeight;
WORD		PwChar, PhChar, PwBox, PhBox;
WORD		WorkOut[57];
OBJECT	*HotlistSubmenuTree = NULL;
OBJECT	*HotlistPopupTree = NULL;
MENU		HotlistSubmenu;

#ifdef	GEMScript
volatile WORD	GsConnection;
#endif

#ifdef	V110
volatile	WORD	IConnectStarted = 0;
WORD		Sockets = 0;
#endif

#ifdef DEBUG
volatile WORD DebugSemaphore = 0;
#endif

/* Konfiguration --------------------------------------------------------------*/
WORD	 	nHotlist = 0;
#ifdef	V120
BYTE		**HotlistName = NULL;
#endif
BYTE		**HotlistHost = NULL;
UWORD		*HotlistPort = NULL;	
BYTE		**HotlistUid = NULL;
BYTE		**HotlistPwd = NULL;
BYTE		**HotlistDir = NULL;
BYTE		**HotlistComment = NULL;
UWORD		ComPort;
UWORD		DataPort;
UWORD		DataPortL;
UWORD		DataPortH;
UWORD		PasvFlag;
UWORD		TransferType;
UWORD		TransferTypeAuto;
UWORD		ConfFlag;
UWORD		ShowFlag;
volatile	ULONG		BufLen;
SUF_ITEM	*SuffixList = NULL;
BYTE		*RxDir = NULL;
BYTE		*TxDir = NULL;
WORD		FileSelectorFlag;
#ifdef	V110
extern	WORD	IConnect;
#endif

/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
int	GetGemdosVersion( void );
WORD	cdecl	HandleAboutDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
WORD	cdecl	HandleIconifyDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
WORD	cdecl	HandleWindowAlertDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
WORD	cdecl	HandleWindowInputTextDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD );
void	SetIcon( OBJECT *Tree, WORD Index );
static void	StIc_Init( WORD AppId, OBJECT *Big, OBJECT *Small );
static void	StIc_Del( WORD AppId );

void	*Xmalloc( long Len, int Mode)
{
	if( GemdosVersion < 0x0019 || Mode == RAM_MALLOC )
		return Malloc( Len );
	return Mxalloc( Len, Mode );
}

int GetGemdosVersion( void )
{
	unsigned int version = Sversion();
	return (int)(((version << 8) & 0xFF00) | ((version >> 8) & 0x00FF));
}

void	*SearchCookie( LONG Id )
{
	COOKIE	*Cookie = ( COOKIE * ) Setexc( 0x5a0/4, ( void ( * )()) -1 );
	if( Cookie )
	{
		while ( Cookie->id )
		{
			if ( Cookie->id == Id )
				return(( void * )Cookie->value );
			Cookie++;
		}		
	}
	return( NULL );
}

/*-----------------------------------------------------------------------------*/
/* Virtuelle Bildschirm-Workstation îffnen                                     */
/* Funktionsresultat: VDI-Handle oder 0 als Fehlernummer                       */
/* WorkOut: GerÑteinformationen                                                */
/*-----------------------------------------------------------------------------*/
WORD	OpenScreenWk( WORD AesHandle, WORD *WorkOut )
{
	WORD	WorkIn[11], Handle, i;
	for( i = 1; i < 10; i++ )
		WorkIn[i] = 1;
	WorkIn[0] = Getrez() + 2;
	WorkIn[10] = 2;
	Handle = AesHandle;
	v_opnvwk( WorkIn, &Handle, WorkOut );
	return( Handle );
}

/*-----------------------------------------------------------------------------*/
/* Resource und dazugehîrige Strukturen initalisieren                          */
/* Funktionsergebnis: -                                                        */
/*-----------------------------------------------------------------------------*/
void	SetIcon( OBJECT *Tree, WORD Index )
{
	Tree[Index].ob_spec.ciconblk->monoblk.ib_xtext = 8;
	Tree[Index].ob_spec.ciconblk->monoblk.ib_ytext = 8;
	Tree[Index].ob_spec.ciconblk->monoblk.ib_wtext = 0;
	Tree[Index].ob_spec.ciconblk->monoblk.ib_htext = 0;
}

void	InitRsrc( OBJECT ***TreeAddr, BYTE ***FstringAddr, WORD Global[15] )
{
	OBJECT	*Objs, *Tree;
	UWORD		NoObjs;
	WORD		Hor3d, Ver3d;
	WORD		TreeCount;
	RSHDR 	*Rsh;

	Rsh = *((RSHDR **)( &Global[7] ));	
	*TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
	TreeCount = Rsh->rsh_ntree;
	*FstringAddr = (BYTE **)((UBYTE *)Rsh + Rsh->rsh_frstr);
	Objs = (OBJECT *)(((BYTE *)Rsh)+Rsh->rsh_object);
	NoObjs = Rsh->rsh_nobs;

	{
		Tree = (*TreeAddr)[ICONS];
		SetIcon( Tree, ICON_LINK );
		SetIcon( Tree, ICON_FILE );
		SetIcon( Tree, ICON_DIR );
		Tree = (*TreeAddr)[HT];
		SetIcon( Tree, HT_ADD_I );
		SetIcon( Tree, HT_CHANGE_I );
		SetIcon( Tree, HT_DEL_I );
		Tree = (*TreeAddr)[NS];
		SetIcon( Tree, NS_HOTLIST_I );
		SetIcon( Tree, NS_OK_I );
		Tree = (*TreeAddr)[SUFFIX];
		SetIcon( Tree, SUFFIX_ADD_I );
		SetIcon( Tree, SUFFIX_CHANGE_I );
		SetIcon( Tree, SUFFIX_DEL_I );
		Tree = (*TreeAddr)[FTP];
		SetIcon( Tree, FTP_CLOSER );		
		SetIcon( Tree, FTP_SLCT_ALL );		
		SetIcon( Tree, FTP_SLCT_NON );		
		SetIcon( Tree, FTP_GET_I );		
		SetIcon( Tree, FTP_PUT_I );		
		SetIcon( Tree, FTP_MV_I );		
		SetIcon( Tree, FTP_RM_I );		
		SetIcon( Tree, FTP_MKDIR_I );		
		SetIcon( Tree, FTP_RMDIR_I );		
		SetIcon( Tree, FTP_CD_I );		
		Tree = (*TreeAddr)[FILE_D];
		SetIcon( Tree, FILE_REPLACE_I );		
		SetIcon( Tree, FILE_REPLACE_A_I );		
		SetIcon( Tree, FILE_JUMPOVER_I );		
		SetIcon( Tree, FILE_JUMPOVER_AI );		
		SetIcon( Tree, FILE_RENAME_I );		
	}

	AesFlags = get_aes_info( &AesFont, &AesHeight, &Hor3d, &Ver3d );
	if( AesFlags & GAI_3D )
		adapt3d_rsrc( Objs, NoObjs, Hor3d, Ver3d );
	else
	{
		Tree = (*TreeAddr)[FTP];
		Tree[FTP_DIR_BACK_V].ob_spec.obspec.interiorcol = 1;
		Tree[FTP_DIR_BACK_V].ob_spec.obspec.fillpattern = 1;
		Tree[FTP_DIR_BACK_H].ob_spec.obspec.interiorcol = 1;
		Tree[FTP_DIR_BACK_H].ob_spec.obspec.fillpattern = 1;

		Tree = (*TreeAddr)[HT];
		Tree[HT_ENTRY_BACK_V].ob_spec.obspec.interiorcol = 1;
		Tree[HT_ENTRY_BACK_V].ob_spec.obspec.fillpattern = 1;
		Tree[HT_ENTRY_BACK_H].ob_spec.obspec.interiorcol = 1;
		Tree[HT_ENTRY_BACK_H].ob_spec.obspec.fillpattern = 1;

		Tree = (*TreeAddr)[SUFFIX];
		Tree[SUFFIX_BACK].ob_spec.obspec.interiorcol = 1;
		Tree[SUFFIX_BACK].ob_spec.obspec.fillpattern = 1;
		Tree[SUF_ENTRY_BACK_H].ob_spec.obspec.interiorcol = 1;
		Tree[SUF_ENTRY_BACK_H].ob_spec.obspec.fillpattern = 1;
		
		no3d_rsrc( Objs, NoObjs, 1 );
		SetSliderBorders( *TreeAddr );
	}

	if(( AesFlags & GAI_MAGIC ) == 0 )
	{
		SetSliderBorders( *TreeAddr );
	}
	else
		substitute_objects( Objs, NoObjs, AesFlags, 0L, 0L );
}

/*----------------------------------------------------------------------------------------*/ 
/* RÑnder der Slider-Objekte auf 1 Pixel setzen															*/
/* Funktionsergebnis:	-																						*/
/*----------------------------------------------------------------------------------------*/ 
void	SetSliderBorders( OBJECT **TreeAddr )
{
	OBJECT	*Tree;

	Tree = TreeAddr[FTP];
	Tree[FTP_DIR_BACK_V].ob_spec.obspec.framesize = 1;
	Tree[FTP_DIR_SL_V].ob_spec.obspec.framesize = 1;
	Tree[FTP_DIR_UP].ob_spec.obspec.framesize = 1;
	Tree[FTP_DIR_DOWN].ob_spec.obspec.framesize = 1;
	Tree[FTP_DIR_BACK_H].ob_spec.obspec.framesize = 1;
	Tree[FTP_DIR_SL_H].ob_spec.obspec.framesize = 1;
	Tree[FTP_DIR_LEFT].ob_spec.obspec.framesize = 1;
	Tree[FTP_DIR_RIGHT].ob_spec.obspec.framesize = 1;
	Tree[FTP_DIR_PATH].ob_spec.tedinfo->te_thickness = 1;
	Tree[FTP_CLOSER_BOX].ob_spec.obspec.framesize = 1;
	Tree[FTP_SLCT_ALL_BOX].ob_spec.obspec.framesize = 1;
	Tree[FTP_SLCT_NON_BOX].ob_spec.obspec.framesize = 1;

	Tree[FTP_W_SIZER].ob_spec.obspec.framesize = -1;


	Tree = TreeAddr[TR];
	Tree[TR_BACK].ob_spec.tedinfo->te_thickness = 1;
	Tree[TR_SL].ob_spec.obspec.framesize = 1;
	Tree[TR_BACK_ALL].ob_spec.tedinfo->te_thickness = 1;
	Tree[TR_SL_ALL].ob_spec.obspec.framesize = 1;

	Tree = TreeAddr[HT];
	Tree[HT_ENTRY_BACK_V].ob_spec.obspec.framesize = 1;
	Tree[HT_ENTRY_SL_V].ob_spec.obspec.framesize = 1;
	Tree[HT_ENTRY_UP].ob_spec.obspec.framesize = 1;
	Tree[HT_ENTRY_DOWN].ob_spec.obspec.framesize = 1;
	Tree[HT_ENTRY_BACK_H].ob_spec.obspec.framesize = 1;
	Tree[HT_ENTRY_SL_H].ob_spec.obspec.framesize = 1;
	Tree[HT_ENTRY_LEFT].ob_spec.obspec.framesize = 1;
	Tree[HT_ENTRY_RIGHT].ob_spec.obspec.framesize = 1;
	Tree[HT_PORT_DOWN].ob_spec.tedinfo->te_thickness = +1;
	Tree[HT_PORT_UP].ob_spec.tedinfo->te_thickness = +1;
	Tree[HT_PORT_BOX].ob_spec.tedinfo->te_thickness = 0;
	
	Tree = TreeAddr[NS];
	Tree[NS_PORT_DOWN].ob_spec.tedinfo->te_thickness = +1;
	Tree[NS_PORT_UP].ob_spec.tedinfo->te_thickness = +1;
	Tree[NS_PORT_BOX].ob_spec.tedinfo->te_thickness = 0;

	Tree = TreeAddr[SUFFIX];
	Tree[SUFFIX_BACK].ob_spec.obspec.framesize = 1;
	Tree[SUFFIX_SL].ob_spec.obspec.framesize = 1;
	Tree[SUFFIX_UP].ob_spec.obspec.framesize = 1;
	Tree[SUFFIX_DOWN].ob_spec.obspec.framesize = 1;
	Tree[SUF_ENTRY_BACK_H].ob_spec.obspec.framesize = 1;
	Tree[SUF_ENTRY_SL_H].ob_spec.obspec.framesize = 1;
	Tree[SUF_ENTRY_LEFT].ob_spec.obspec.framesize = 1;
	Tree[SUF_ENTRY_RIGHT].ob_spec.obspec.framesize = 1;

	Tree = TreeAddr[CONF1];
	Tree[CONF1_BUF_DOWN].ob_spec.tedinfo->te_thickness = +1;
	Tree[CONF1_BUF_UP].ob_spec.tedinfo->te_thickness = +1;
	Tree[CONF1_BUF_BOX].ob_spec.tedinfo->te_thickness = 0;

	Tree = TreeAddr[CONF2];
	Tree[CONF2_COM_DOWN].ob_spec.tedinfo->te_thickness = +1;
	Tree[CONF2_COM_UP].ob_spec.tedinfo->te_thickness = +1;
	Tree[CONF2_COM_BOX].ob_spec.tedinfo->te_thickness = 0;
	Tree[CONF2_DATA_LDOWN].ob_spec.tedinfo->te_thickness = +1;
	Tree[CONF2_DATA_LUP].ob_spec.tedinfo->te_thickness = +1;
	Tree[CONF2_DATA_L_BOX].ob_spec.tedinfo->te_thickness = 0;
	Tree[CONF2_DATA_HDOWN].ob_spec.tedinfo->te_thickness = +1;
	Tree[CONF2_DATA_HUP].ob_spec.tedinfo->te_thickness = +1;
	Tree[CONF2_DATA_H_BOX].ob_spec.tedinfo->te_thickness = 0;
	Tree[CONF2_NOOP_DOWN].ob_spec.tedinfo->te_thickness = +1;
	Tree[CONF2_NOOP_UP].ob_spec.tedinfo->te_thickness = +1;
	Tree[CONF2_NOOP_BOX].ob_spec.tedinfo->te_thickness = 0;

	Tree = TreeAddr[POPUP];
	Tree[POPUP_BOX].ob_spec.obspec.framesize = -1;
}

WORD	HandleIcon( WORD *Obj, DIALOG *Dialog, WORD Global[15] )
{
	OBJECT		*DialogTree;
	GRECT			Rect;
	WORD			a;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );

	if( DialogTree[*Obj].ob_type == G_CICON )
	{
		WORD	Parent;
		EVNTDATA	Ev;
		Parent = DialogTree[*Obj].ob_next;
		if( !(DialogTree[Parent].ob_flags & SELECTABLE ))
			return( 0 );
		if( !(DialogTree[Parent].ob_state & SELECTED ))
		{
			DialogTree[Parent].ob_state |= SELECTED;
			DoRedraw( Dialog, &Rect, Parent, Global );
		}
		do
		{
			MT_graf_mkstate( &Ev, Global );
			a = MT_objc_find( DialogTree, ROOT, MAX_DEPTH, Ev.x, Ev.y, Global );
			if( a != *Obj && a != Parent )
			{
				DialogTree[Parent].ob_state &= ~SELECTED;
				DoRedraw( Dialog, &Rect, Parent, Global );
				return( 1 );
			}
		}
		while( Ev.bstate & 1 );
		if( a == *Obj || a == Parent )
		{
			*Obj = Parent;
			return( 0 );
		}
	}
	return( 0 );
}

/*----------------------------------------------------------------------------------------*/ 
/* Installiert die MenÅleiste und die entsprechenden SubmenÅs                             */
/* Funktionsergebnis:	-																						*/
/*----------------------------------------------------------------------------------------*/ 
void	InstalMenuBar( void )
{
	if( MT_menu_bar( TreeAddr[MENUE], -1, Global ) != Global[2] );
		MT_menu_bar( TreeAddr[MENUE], MENU_SHOW, Global );
	if( nHotlist && HotlistSubmenuTree )
	{
		WORD	a1, a2, a3, a4;
		MT_menu_ienable( TreeAddr[MENUE], MENUE_OPEN_SES, 1, Global );
		if(( AesFlags & GAI_INFO ) && MT_appl_getinfo( 9, &a1, &a2, &a3, &a4, Global ) && a1 );
		{
			HotlistSubmenu.mn_menu = 0;
			HotlistSubmenu.mn_item = 0;
			HotlistSubmenu.mn_scroll = 1;
			HotlistSubmenu.mn_keystate = 0;
			HotlistSubmenu.mn_tree = HotlistSubmenuTree;
			MT_menu_attach( 1, TreeAddr[MENUE], MENUE_OPEN_SES, &HotlistSubmenu, Global );
		}
	}
	else
		MT_menu_ienable( TreeAddr[MENUE], MENUE_OPEN_SES, 0, Global );
}

void	ScrapDirCutTxt( BYTE *Txt, WORD Global[15] )
{
	BYTE	Path[128];
	MT_scrp_read( Path, Global );
	if( strlen( Path ))
	{
		LONG	DirHandle, FileHandle;
		BYTE	File[128], Puf[256];
		WORD	Msg[8];
		DirHandle = Dopendir( Path, 1 );
		while( Dreaddir( 128, DirHandle, File ) != ENMFIL )
		{
			if( !strnicmp( File, "SCRAP.", 6 ))
			{
				strcpy( Puf, Path );
				strcat( Puf, File );
				Fdelete( Puf );
			}
		}
		Dclosedir( DirHandle );
		strcpy( Puf, Path );
		strcat( Puf, "\\scrap.txt" );
		FileHandle = Fcreate( Puf, 0 );
		Fwrite(( WORD ) FileHandle, strlen( Txt ), Txt );
		Fclose(( WORD ) FileHandle );
		Msg[0] = SC_CHANGED;
		Msg[1] = Global[2];
		Msg[2] = 0;
		Msg[3] = 0x0002;
		MT_shel_write( SHW_BROADCAST, 0, 0, ( BYTE * ) Msg, 0L, Global );
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* Fileselector im Fenster                                                                */
/*----------------------------------------------------------------------------------------*/ 
void	*WindowFileselector( WORD Flag, BYTE *Title, BYTE *Path, BYTE *File, WORD *Handle, WORD Global[15] )
{
	if( !strlen( Path ) || Path[1] != ':' || Path[2] != '\\' )
	{
		Dgetpath( &(Path[2]), 0 );
		Path[1] = ':';
		Path[0] = Dgetdrv() + 'A';
	}
	if( *( Path + strlen( Path ) - 1 ) != '\\' )
		strcat( Path, "\\" );
		
	if( !FileSelectorFlag )
		return( MT_fslx_open( Title, -1, -1, Handle, Path, PathLen, File, FileLen, "*\0", 0L, "\0", SORTBYNAME, Flag, Global ));
	else
		return( NULL );
}

/*----------------------------------------------------------------------------------------*/ 
/* Bastelt ein SubmenÅ                                                                    */
/* Funktionsergebnis:	 																						*/
/*----------------------------------------------------------------------------------------*/ 
void	CreateSubmenuTree( OBJECT **Tree, WORD n, BYTE *T[] )
{
	WORD	i, j, MaxLen = 0, CharH, CharW;
	OBJECT	*X;
	X = *Tree;
	if( X )
	{
		i = X[SUBMENUE_BOX].ob_head;
		j = X[SUBMENUE_BOX].ob_tail;
		while( i != j )
		{
			free( X[i].ob_spec.free_string );
			i = X[i].ob_next;
		}
		free( X );
	}
	if( !n )
		return;
	*Tree = (OBJECT *) malloc(( n + 1 ) * sizeof( OBJECT ));
	if( !*Tree )
	{
		MemErr( "main" );
		return;
	}

	X = *Tree;

	for( i = 0; i < n; i++ )
		if( strlen( T[i] ) > MaxLen )
			MaxLen = (WORD) strlen( T[i] );
	MaxLen += 3 * (WORD) sizeof( BYTE );

	CharH = TreeAddr[SUBMENUE][SUBMENUE_STRING].ob_height;
	CharW	= TreeAddr[SUBMENUE][SUBMENUE_STRING].ob_width;

	X[SUBMENUE_BOX].ob_next = -1;
	X[SUBMENUE_BOX].ob_head = -1;
	X[SUBMENUE_BOX].ob_tail = -1;
	X[SUBMENUE_BOX].ob_type = TreeAddr[SUBMENUE][SUBMENUE_BOX].ob_type;
	X[SUBMENUE_BOX].ob_flags = TreeAddr[SUBMENUE][SUBMENUE_BOX].ob_flags;
	X[SUBMENUE_BOX].ob_state = TreeAddr[SUBMENUE][SUBMENUE_BOX].ob_state;
	X[SUBMENUE_BOX].ob_spec = TreeAddr[SUBMENUE][SUBMENUE_BOX].ob_spec;
	X[SUBMENUE_BOX].ob_width = MaxLen * CharW;
	X[SUBMENUE_BOX].ob_height = n * CharH;

	for( i = 1; i <= n; i++)
	{
		X[i].ob_next = i + 1;
		X[i].ob_head = -1;
		X[i].ob_tail = -1;
		X[i].ob_type = TreeAddr[SUBMENUE][SUBMENUE_STRING].ob_type;
		X[i].ob_flags = TreeAddr[SUBMENUE][SUBMENUE_STRING].ob_flags;
		X[i].ob_state = TreeAddr[SUBMENUE][SUBMENUE_STRING].ob_state;
		X[i].ob_spec.free_string = malloc( strlen( T[i-1] ) + 2 * sizeof( BYTE ) + 2 );
		if( !X[i].ob_spec.free_string )
		{
			MemErr( "main" );
			return;
		}
		strcpy( X[i].ob_spec.free_string, "  " );
		strcat( X[i].ob_spec.free_string, T[i-1] );
		X[i].ob_x = 0;
		X[i].ob_y = (i-1) * CharH;
		X[i].ob_width = MaxLen * CharW;
		X[i].ob_height = CharH;
	}
	X[SUBMENUE_STRING + n - 1].ob_next = SUBMENUE_BOX;
	X[SUBMENUE_STRING + n - 1].ob_flags |= LASTOB;
	X[SUBMENUE_BOX].ob_head = SUBMENUE_STRING;
	X[SUBMENUE_BOX].ob_tail = SUBMENUE_STRING + n - 1;
}

/*----------------------------------------------------------------------------------------*/ 
/* Bastelt PopupmenÅ                            														*/
/* Funktionsergebnis:	 																						*/
/*----------------------------------------------------------------------------------------*/ 
void	CreatePopupTree( OBJECT **Tree, WORD n, BYTE *T[] )
{
	int CharW, i, MaxLen = 0, Width;

	CharW	= TreeAddr[SUBMENUE][SUBMENUE_STRING].ob_width;

	for( i = 0; i < n; i++ )
		if( strlen( T[i] ) > MaxLen )
			MaxLen = (WORD) strlen( T[i] );
	MaxLen += 3 * (WORD) sizeof( BYTE );

	Width = MaxLen * CharW;
	nCreatePopupTree( Tree, n, T, Width );
}

void	nCreatePopupTree( OBJECT **Tree, WORD n, BYTE *T[], WORD Width )
{
	WORD	i, j, MaxLen = 0, CharH, CharW;
	OBJECT	*X;

	X = *Tree;

	if( X )
	{
		i = X[POPUP_BOX].ob_head;
		j = X[POPUP_BOX].ob_tail;
		while( i != j )
		{
			free( X[i].ob_spec.free_string );
			i = X[i].ob_next;
		}
		free( X );
	}
	if( !n )
		return;

	*Tree = (OBJECT *) malloc(( n + 1 ) * sizeof( OBJECT ));
	if( !*Tree )
	{
		MemErr( "main" );
		return;
	}

	X = *Tree;

	CharH = TreeAddr[POPUP][POPUP_STRING].ob_height;
	CharW	= TreeAddr[POPUP][POPUP_STRING].ob_width;

	MaxLen = Width / CharW;

	X[POPUP_BOX].ob_next = -1;
	X[POPUP_BOX].ob_head = -1;
	X[POPUP_BOX].ob_tail = -1;
	X[POPUP_BOX].ob_type = TreeAddr[POPUP][POPUP_BOX].ob_type;
	X[POPUP_BOX].ob_flags = TreeAddr[POPUP][POPUP_BOX].ob_flags;
	X[POPUP_BOX].ob_state = TreeAddr[POPUP][POPUP_BOX].ob_state;
	X[POPUP_BOX].ob_spec = TreeAddr[POPUP][POPUP_BOX].ob_spec;
	X[POPUP_BOX].ob_width = Width;
	X[POPUP_BOX].ob_height = n * CharH;

	for( i = 1; i <= n; i++)
	{
		X[i].ob_next = i + 1;
		X[i].ob_head = -1;
		X[i].ob_tail = -1;
		X[i].ob_type = TreeAddr[POPUP][POPUP_STRING].ob_type;
		X[i].ob_flags = TreeAddr[POPUP][POPUP_STRING].ob_flags;
		X[i].ob_state = TreeAddr[POPUP][POPUP_STRING].ob_state;
		X[i].ob_spec.free_string = malloc( strlen( T[i-1] ) + 2 * sizeof( BYTE ) + 2 );
		if( !X[i].ob_spec.free_string )
		{
			MemErr( "main" );
			return;
		}
		strcpy( X[i].ob_spec.free_string, "  " );
		strncat( X[i].ob_spec.free_string, T[i-1], MaxLen - 3 );
		X[i].ob_x = 0;
		X[i].ob_y = (i-1) * CharH;
		X[i].ob_width = Width;
		X[i].ob_height = CharH;
	}
	X[POPUP_STRING + n - 1].ob_next = POPUP_BOX;
	X[POPUP_STRING + n - 1].ob_flags |= LASTOB;
	X[POPUP_BOX].ob_head = POPUP_STRING;
	X[POPUP_BOX].ob_tail = POPUP_STRING + n - 1;
}

/*-----------------------------------------------------------------------------*/
/* Objekt zeichnen                                                             */
/* Funktionsergebnis: -                                                        */
/*  Tree: Zeiger auf den Objektbaum                                            */
/*  Rect: Begrenzendes Rechteck                                                */
/*  Obj: Objektnummer                                                          */
/*-----------------------------------------------------------------------------*/
void	DoRedraw( DIALOG *Dialog, GRECT *Rect, WORD Obj, WORD Global[15] )
{
	if( !isIconifiedWindow( MT_wdlg_get_handle( Dialog, Global )))
	{
		WORD	w1, w2, w3 ,w4;
		MT_wind_get( MT_wdlg_get_handle( Dialog, Global ), WF_OWNER, &w1, &w2, &w3, &w4, Global );
		if( w2 != 1 )
			return;
		MT_wind_update( BEG_UPDATE, Global );
		MT_wdlg_redraw( Dialog, Rect, Obj, MAX_DEPTH, Global );
		MT_wind_update( END_UPDATE, Global );
	}
}
void	DoRedrawX( DIALOG *Dialog, GRECT *Rect, WORD Global[15], ... )
{
	va_list	Arg;
	WORD		Obj;
	if( !isIconifiedWindow( MT_wdlg_get_handle( Dialog, Global )))
	{
		WORD	w1, w2, w3 ,w4;
		MT_wind_get( MT_wdlg_get_handle( Dialog, Global ), WF_OWNER, &w1, &w2, &w3, &w4, Global );
		if( w2 != 1 )
			return;
		MT_wind_update( BEG_UPDATE, Global );
		va_start( Arg, x );
		while(( Obj = va_arg( Arg, WORD )) != EDRX )
			MT_wdlg_redraw( Dialog, Rect, Obj, MAX_DEPTH, Global );
		va_end( Arg );
		MT_wind_update( END_UPDATE, Global );
	}
}

/*-----------------------------------------------------------------------------*/
/* Fensterdialog îffnen                                                        */
/* Funktionsergebnis: Zeiger auf Dialog 0: Fehler                              */
/*  DialogTree:       Zeiger auf den Objektbaum                                */
/*  TitelStr:         Zeiger auf Titel des Dialogs                             */
/*  HandleDialog:     Service-Funktion fÅr Dialog                              */
/*  UserData:         Thread- und Dialog-abhÑngige Daten                       */
/*  Global:           Global-Feld des jeweiligen Threads                       */
/*-----------------------------------------------------------------------------*/
DIALOG	*OpenDialog( OBJECT *DialogTree, BYTE *TitelStr, HNDL_OBJ HandleDialog, void *UserData, WORD Global[15] )
{
	DIALOG	*Dialog;

	Dialog = MT_wdlg_create( HandleDialog, DialogTree, UserData, 0, UserData, WDLG_BKGD, Global );

	if( Dialog )
		if( MT_wdlg_open( Dialog, TitelStr, NAME + MOVER + CLOSER + ICONIFIER, -1, -1, 0, UserData, Global ))
		{
			NewWindow( MT_wdlg_get_handle( Dialog, Global ), Global[2], Global );
			return( Dialog );
		}
		else
			MT_wdlg_delete( Dialog, Global );

	return( 0L );
}

/*-----------------------------------------------------------------------------*/
/* Fensterdialog schlieûen *und* lîschen                                       */
/* Funktionsergebnis: -                                                        */
/*  Dialog:           Zeiger auf Dialog                                        */
/*  Global:           Global-Feld des jeweiligen Threads                       */
/*-----------------------------------------------------------------------------*/
void	CloseDialog( DIALOG *D, WORD G[15] )
{
	WORD	*Global;
	DIALOG	*Dialog;
	Global = G;
	Dialog = D;
	if( Dialog )
	{
		WORD		i, j;
		if( isIconifiedWindow( MT_wdlg_get_handle( Dialog, Global )))
		{
			OBJECT	*DialogTree;
			GRECT		Rect;
			MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
			free( DialogTree );
		}
		DelWindow( MT_wdlg_get_handle( Dialog, Global ), Global );
		MT_wdlg_close( Dialog, &i, &j, Global );
		MT_wdlg_delete( Dialog, Global );
	}
}

WORD	cdecl	HandleAboutDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD )
{
	OBJECT	*DialogTree;
	GRECT		Rect;

	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );

	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_INIT:
				DecodeName( DialogTree[ABOUT_SER].ob_spec.tedinfo->te_ptext, DialogTree[ABOUT_NAME].ob_spec.tedinfo->te_ptext, DialogTree[ABOUT_FIRMA].ob_spec.tedinfo->te_ptext ); 
				sprintf( DialogTree[ABOUT_DATE].ob_spec.free_string, "%s", __DATE__ );
				sprintf( DialogTree[ABOUT_VERSION].ob_spec.free_string, "%s", FiffiVersion );
				DialogTree[ABOUT_OK].ob_state &= ~SELECTED;
				break;
			case	HNDL_CLSD:
				return( 0 );
			case	HNDL_MESG:
			{
				if( Events->msg[0] == WM_ICONIFY )
				{
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &Global[7] ));
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					if( !isIconifiedWindow( MT_wdlg_get_handle( Dialog, Global )))
					{
						DialogTree = malloc( 2 * sizeof( OBJECT ));
						if( !DialogTree )
						{
							MemErr( "main" );
							return( 0 );
						}
						memcpy( DialogTree, TreeAddr[ICONIFY], 2 * sizeof( OBJECT ));
						MT_wdlg_set_iconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, DialogTree, ICONIFY_ICON, Global );
						IconifyWindow( MT_wdlg_get_handle( Dialog, Global ));
					}
					else
						MT_wind_set_grect( MT_wdlg_get_handle( Dialog, Global ), WF_CURRXYWH, ( GRECT *) &( Events->msg[4] ), Global );
				}
				if( Events->msg[0] == WM_UNICONIFY )
				{
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &Global[7] ));
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					MT_wdlg_set_uniconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, TreeAddr[ABOUT], Global );
					UnIconifyWindow( MT_wdlg_get_handle( Dialog, Global ));
					free( DialogTree );
				}
				if( Events->msg[0] == WM_ALLICONIFY )
				{
					WORD	Msg[8];
					Msg[0] = WM_ALLICONIFY;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = 0;
					Msg[4] = Events->msg[4]; Msg[5] = Events->msg[5]; Msg[6] = Events->msg[6];	Msg[7] = Events->msg[7];
					MT_appl_write( Global[2], 16, Msg, Global );
				}
				break;
			}
		}
	}
	else
	{
		Obj &= 0x7fff;
		switch( Obj )
		{
			case	ABOUT_OK:
				return( 0 );
		}
	}
	return( 1 );
}

WORD cdecl	HandleDragDropFailedDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD )
{
	OBJECT	*DialogTree;
	GRECT		Rect;

	WORD 		*Global;
	Global = (WORD *) UD;

	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );

	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_INIT:
			{
				DialogTree[NFU_CANCEL].ob_state &= ~SELECTED;
				break;
			}
			case	HNDL_MESG:
			{
				if( Events->msg[0] == WM_ICONIFY )
				{
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &(Global[7] )));	
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					if( !isIconifiedWindow( MT_wdlg_get_handle( Dialog, Global )))
					{
						DialogTree = malloc( 2 * sizeof( OBJECT ));
						if( !DialogTree )
						{
							MemErr( "NoFtpUrl" );
							return( 0 );
						}
						memcpy( DialogTree, TreeAddr[ICONIFY], 2 * sizeof( OBJECT ));
						MT_wdlg_set_iconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, DialogTree, ICONIFY_ICON, Global );
						IconifyWindow( MT_wdlg_get_handle( Dialog, Global ));
					}
					else
						MT_wind_set_grect( MT_wdlg_get_handle( Dialog, Global ), WF_CURRXYWH, ( GRECT *) &( Events->msg[4] ), Global );
				}
				if( Events->msg[0] == WM_UNICONIFY )
				{
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &(Global[7] )));
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					MT_wdlg_set_uniconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, TreeAddr[DDF], Global );
					UnIconifyWindow( MT_wdlg_get_handle( Dialog, Global ));
					free( DialogTree );
				}
				if( Events->msg[0] == WM_ALLICONIFY )
				{
					WORD	Msg[8];
					Msg[0] = WM_ALLICONIFY;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = 0;
					Msg[4] = Events->msg[4]; Msg[5] = Events->msg[5]; Msg[6] = Events->msg[6];	Msg[7] = Events->msg[7];
					MT_appl_write( Global[2], 16, Msg, Global );
				}
				break;
			}
			case	HNDL_CLSD:
				return( 0 );
		}
	}
	else
	{
		Obj &= 0x7fff;
		if( Obj == DDF_CANCEL )
			return( 0 );
	}
	return( 1 );
}

WORD	cdecl	HandleIconifyDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD )
{
	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_CLSD:
			{
				WORD	Msg[8];
				Msg[0] = WM_UNICONIFY;
				Msg[2] = 0;
				Msg[3] = MT_wdlg_get_handle( Dialog, Global );
				MT_appl_write( Global[2], 16, Msg, Global );
				break;
			}
			case	HNDL_MESG:
				if( Events->msg[0] == WM_UNICONIFY )
				{
					WORD	Msg[8];
					Msg[3] = GetFirstWindow();
					if( Msg[3] != -1 )
					{
						Msg[0] = WM_UNICONIFY;
						Msg[1] = Global[2];
						Msg[2] = 0;
						do
						{
							MT_wind_get_grect( Msg[3], WF_UNICONIFY, (GRECT *) &( Msg[4] ), Global );
							MT_appl_write( GetAppIdWindow( Msg[3] ), 16, Msg, Global );
							UnAllIconifyWindow( Msg[3] );
							Msg[3] = GetNextWindow( Msg[3] );
						}
						while( Msg[3] != -1 );
					}
					return( 0 );
				}
				break;
		}
	}
	return( 1 );
}
/*-----------------------------------------------------------------------------*/
/* Alert als FensterDialog                                                     */
/* Funktionsergebnis:                                                          */
/*-----------------------------------------------------------------------------*/
DIALOG	*WindowAlert( BYTE *Title, BYTE *Text, WORD DefaultButton, WORD Global[15] )
{
	WORD	Icon, i = 0, j = 0;
	BYTE	*Pos, *End;
	BYTE	Line[5][32];
	BYTE	Button[2][21];
	RSHDR 	*Rsh;
	OBJECT	**TreeAddr;

	Rsh = *((RSHDR **)( &Global[7] ));	
	TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
	memset( Line[0], 0, 32 );
	memset( Line[1], 0, 32 );
	memset( Line[2], 0, 32 );
	memset( Line[3], 0, 32 );
	memset( Line[4], 0, 32 );
	memset( Button[0], 0, 21 );
	memset( Button[1], 0, 21 );

	Pos = Text + 1;
	Icon = atoi( Pos );
	Pos += 3;
	End = strchr( Pos, ']' );
	while( Pos < End )
	{
		if( *Pos == '|' )
		{
			i++;
			j = 0;
		}
		else
			Line[i][j++] = *Pos;
		Pos++;		
	}
	i = 0; j = 0;
	Pos += 2;
	End = strchr( Pos, ']' );
	while( Pos < End )
	{
		if( *Pos == '|' )
		{
			i++;
			j = 0;
		}
		else
			Button[i][j++] = *Pos;
		Pos++;		
	}
	TreeAddr[ALERT][ALERT_ICON_1].ob_flags |= HIDETREE;
	TreeAddr[ALERT][ALERT_ICON_2].ob_flags |= HIDETREE;
	TreeAddr[ALERT][ALERT_ICON_3].ob_flags |= HIDETREE;
	switch( Icon )
	{
		case	1:	TreeAddr[ALERT][ALERT_ICON_1].ob_flags &= ~HIDETREE; break;
		case	2:	TreeAddr[ALERT][ALERT_ICON_2].ob_flags &= ~HIDETREE; break;
		case	3:	TreeAddr[ALERT][ALERT_ICON_3].ob_flags &= ~HIDETREE; break;
	}
	strcpy( TreeAddr[ALERT][ALERT_LINE_0].ob_spec.free_string, Line[0] );
	strcpy( TreeAddr[ALERT][ALERT_LINE_1].ob_spec.free_string, Line[1] );
	strcpy( TreeAddr[ALERT][ALERT_LINE_2].ob_spec.free_string, Line[2] );
	strcpy( TreeAddr[ALERT][ALERT_LINE_3].ob_spec.free_string, Line[3] );
	strcpy( TreeAddr[ALERT][ALERT_LINE_4].ob_spec.free_string, Line[4] );
	TreeAddr[ALERT][ALERT_BUTTON_0].ob_state &= ~SELECTED;
	TreeAddr[ALERT][ALERT_BUTTON_1].ob_state &= ~SELECTED;

	if( strlen( Button[1] ))
	{
		strcpy( TreeAddr[ALERT][ALERT_BUTTON_0].ob_spec.free_string, Button[0] );
		strcpy( TreeAddr[ALERT][ALERT_BUTTON_1].ob_spec.free_string, Button[1] );
		if( strlen( Button[1] ) + 1 >= 8 )
			TreeAddr[ALERT][ALERT_BUTTON_1].ob_width = (WORD) ( strlen( Button[1] ) + 1 ) * PwChar;
		else
			TreeAddr[ALERT][ALERT_BUTTON_1].ob_width = 8 * PwChar;
		TreeAddr[ALERT][ALERT_BUTTON_1].ob_x = TreeAddr[ALERT][ALERT_BOX].ob_width - 2 * PwChar - TreeAddr[ALERT][ALERT_BUTTON_1].ob_width;

		TreeAddr[ALERT][ALERT_BUTTON_0].ob_flags &= ~HIDETREE;
		if( strlen( Button[0] ) + 1 >= 8 )
			TreeAddr[ALERT][ALERT_BUTTON_0].ob_width = (WORD) ( strlen( Button[0] ) + 1 ) * PwChar;
		else
			TreeAddr[ALERT][ALERT_BUTTON_0].ob_width = 8 * PwChar;
		TreeAddr[ALERT][ALERT_BUTTON_0].ob_x = TreeAddr[ALERT][ALERT_BUTTON_1].ob_x - TreeAddr[ALERT][ALERT_BUTTON_0].ob_width - 2 * PwChar;
	}
	else
	{
		strcpy( TreeAddr[ALERT][ALERT_BUTTON_1].ob_spec.free_string, Button[0] );
		TreeAddr[ALERT][ALERT_BUTTON_0].ob_flags |= HIDETREE;
		if( strlen( Button[0] ) + 1 >= 8 )
			TreeAddr[ALERT][ALERT_BUTTON_1].ob_width = (WORD) ( strlen( Button[0] ) + 1 ) * PwChar;
		else
			TreeAddr[ALERT][ALERT_BUTTON_1].ob_width = 8 * PwChar;
		TreeAddr[ALERT][ALERT_BUTTON_1].ob_x = TreeAddr[ALERT][ALERT_BOX].ob_width - 2 * PwChar - TreeAddr[ALERT][ALERT_BUTTON_1].ob_width;
	}

	TreeAddr[ALERT][ALERT_BUTTON_0].ob_flags &= ~DEFAULT;
	TreeAddr[ALERT][ALERT_BUTTON_1].ob_flags &= ~DEFAULT;
	if( DefaultButton == 1 && strlen( Button[1] ))
		TreeAddr[ALERT][ALERT_BUTTON_0].ob_flags |= DEFAULT;
	if( DefaultButton == 1 && !strlen( Button[1] ))
		TreeAddr[ALERT][ALERT_BUTTON_1].ob_flags |= DEFAULT;
	if( DefaultButton == 2 && strlen( Button[1] ))
		TreeAddr[ALERT][ALERT_BUTTON_1].ob_flags |= DEFAULT;

	return( OpenDialog( TreeAddr[ALERT], Title, HandleWindowAlertDialog, Global, Global ));
}
WORD	cdecl	HandleWindowAlertDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD )
{
	OBJECT	*DialogTree;
	GRECT		Rect;
	WORD		*Global;
	Global = (WORD *) UD;	

	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );

	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_CLSD:
			{
				return( 0 );
			}
			
			case	HNDL_MESG:
			{
				if( Events->msg[0] == WM_ICONIFY )
				{
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &Global[7] ));
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					if( !isIconifiedWindow( MT_wdlg_get_handle( Dialog, Global )))
					{
						DialogTree = malloc( 2 * sizeof( OBJECT ));
						if( !DialogTree )
						{
							MemErr( "main" );
							return( 0 );
						}
						memcpy( DialogTree, TreeAddr[ICONIFY], 2 * sizeof( OBJECT ));
						MT_wdlg_set_iconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, DialogTree, ICONIFY_ICON, Global );
						IconifyWindow( MT_wdlg_get_handle( Dialog, Global ));
					}
					else
						MT_wind_set_grect( MT_wdlg_get_handle( Dialog, Global ), WF_CURRXYWH, ( GRECT *) &( Events->msg[4] ), Global );
				}
				if( Events->msg[0] == WM_UNICONIFY )
				{
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &Global[7] ));
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					MT_wdlg_set_uniconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, TreeAddr[ALERT], Global );
					UnIconifyWindow( MT_wdlg_get_handle( Dialog, Global ));
					free( DialogTree );
				}
				if( Events->msg[0] == WM_ALLICONIFY )
				{
					WORD	Msg[8];
					Msg[0] = WM_ALLICONIFY;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = 0;
					Msg[4] = Events->msg[4]; Msg[5] = Events->msg[5]; Msg[6] = Events->msg[6];	Msg[7] = Events->msg[7];
					MT_appl_write( Global[2], 16, Msg, Global );
				}
				break;
			}
		}
	}
	else
	{
		Obj &= 0x7fff;
		switch( Obj )
		{
			case	ALERT_BUTTON_0:	
			case	ALERT_BUTTON_1:	return( 0 );
		}
	}
	return( 1 );
}

/*-----------------------------------------------------------------------------*/
/* Texteingabe im Fenster                                                      */
/* Funktionsergebnis:                                                          */
/* Xted, Tmplt und Txt mÅssen immer gleich sein! */
/*-----------------------------------------------------------------------------*/
DIALOG	*WindowInputText( BYTE *WindowTitle, BYTE *TextTitle, XTED *Xted, char *Tmplt, char *Txt, WORD Global[15] )
{
	RSHDR 	*Rsh;
	OBJECT	**TreeAddr;
	WORD		isScroll;

	Rsh = *((RSHDR **)( &Global[7] ));	
	TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);

	if( magic_version && magic_date >= 0x19950829L )
		isScroll = 1;
	else
		isScroll = 0;

	if( TreeAddr[IT][IT_EDIT].ob_spec.tedinfo->te_tmplen != EditLen + 1 )
		InitScrlted(&TreeAddr[IT][IT_EDIT], isScroll, Xted, Txt, Tmplt, EditLen);

	TreeAddr[IT][IT_OK].ob_state &= ~SELECTED;
	TreeAddr[IT][IT_OK].ob_state |= DISABLED;
	TreeAddr[IT][IT_OK].ob_flags &= ~SELECTABLE;
	TreeAddr[IT][IT_CANCEL].ob_state &= ~SELECTED;
	strcpy( TreeAddr[IT][IT_TITLE].ob_spec.free_string, TextTitle );

	return( OpenDialog( TreeAddr[IT], WindowTitle, HandleWindowInputTextDialog, Global, Global ));
}
WORD	cdecl	HandleWindowInputTextDialog( DIALOG *Dialog, EVNT *Events, WORD Obj, WORD Clicks, void *UD )
{
	OBJECT	*DialogTree;
	GRECT		Rect;
	WORD		*Global;
	Global = (WORD *) UD;	

	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );

	if ( Obj < 0 )
	{
		switch( Obj )
		{
			case	HNDL_INIT:
			{
				break;
			}
			case	HNDL_CLSD:
			{
				return( 0 );
			}
			case	HNDL_EDDN:
			{
				if( strlen( DialogTree[IT_EDIT].ob_spec.tedinfo->te_ptext ) && 
					( DialogTree[IT_OK].ob_state & DISABLED ))
				{
					DialogTree[IT_OK].ob_state &= ~DISABLED;
					DialogTree[IT_OK].ob_flags |= SELECTABLE;
					DoRedraw( Dialog, &Rect, IT_OK, Global );
				}
				if( !strlen( DialogTree[IT_EDIT].ob_spec.tedinfo->te_ptext ) &&
					!( DialogTree[IT_OK].ob_state & DISABLED ))
				{
					DialogTree[IT_OK].ob_state |= DISABLED;
					DialogTree[IT_OK].ob_flags &= ~SELECTABLE;
					DoRedraw( Dialog, &Rect, IT_OK, Global );
				}
				break;
			}

			case	HNDL_EDIT:
			{
				WORD	a, b;
				if( IsMenuKey( Events->key, &a, &b ))
					return( 0 );
				break;
			}

			case	HNDL_MESG:
			{
				if( Events->msg[0] == WM_ICONIFY )
				{
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &Global[7] ));
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					if( !isIconifiedWindow( MT_wdlg_get_handle( Dialog, Global )))
					{
						DialogTree = malloc( 2 * sizeof( OBJECT ));
						if( !DialogTree )
						{
							MemErr( "main" );
							return( 0 );
						}
						memcpy( DialogTree, TreeAddr[ICONIFY], 2 * sizeof( OBJECT ));
						MT_wdlg_set_iconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, DialogTree, ICONIFY_ICON, Global );
						IconifyWindow( MT_wdlg_get_handle( Dialog, Global ));
					}
					else
						MT_wind_set_grect( MT_wdlg_get_handle( Dialog, Global ), WF_CURRXYWH, ( GRECT *) &( Events->msg[4] ), Global );
				}
				if( Events->msg[0] == WM_UNICONIFY )
				{
					RSHDR 	*Rsh;
					OBJECT	**TreeAddr;
					Rsh = *((RSHDR **)( &Global[7] ));
					TreeAddr = (OBJECT **)(((UBYTE *)Rsh) + Rsh->rsh_trindex);
					MT_wdlg_set_uniconify( Dialog, ( GRECT *) &( Events->msg[4] ), NULL, TreeAddr[IT], Global );
					UnIconifyWindow( MT_wdlg_get_handle( Dialog, Global ));
					free( DialogTree );
				}
				if( Events->msg[0] == WM_ALLICONIFY )
				{
					WORD	Msg[8];
					Msg[0] = WM_ALLICONIFY;
					Msg[1] = Global[2];
					Msg[2] = 0;
					Msg[3] = 0;
					Msg[4] = Events->msg[4]; Msg[5] = Events->msg[5]; Msg[6] = Events->msg[6];	Msg[7] = Events->msg[7];
					MT_appl_write( Global[2], 16, Msg, Global );
				}
				break;
			}
		}
	}
	else
	{
		Obj &= 0x7fff;
		if( DialogTree[Obj].ob_state & DISABLED )
		{
			DialogTree[Obj].ob_state &= ~SELECTED;
			return( 1 );
		}
		switch( Obj )
		{
			case	IT_OK:	return( 0 );
			case	IT_CANCEL:	return( 0 );
		}
	}
	return( 1 );
}

WORD	AvInit( BYTE *AppName, WORD Global[15] )
{
	BYTE	*Tmp;
	WORD	AvAppId = -1;
	WORD	Msg[8];
	Tmp = getenv( "AVSERVER" );
	if( Tmp )
	{
		BYTE	Str[9];
		int	i = 7;
		strncpy( Str, Tmp, 9 );
		while( !Str[i] )
			Str[i--] = ' ';
		Str[i--] = ' ';
		AvAppId = MT_appl_find( Str, Global );
	}
	if( AvAppId < 0 )
		AvAppId = MT_appl_find( "AVSERVER", Global );
	if( AvAppId < 0 )
	{
		WORD	a1, a2, a3, a4;
		if( MT_appl_getinfo( 4, &a1, &a2, &a3, &a4, Global ) && a3 )
		{
			WORD	ShellId, D;
			BYTE	Dummy[9];
			if( !MT_appl_search( 2, Dummy, &D, &ShellId, Global ))
				AvAppId = ShellId;
		}
	}
	if( AvAppId < 0 )
		AvAppId = 0;	
	Tmp = Xmalloc( 9, RAM_READABLE );
	strcpy( Tmp, AppName );
	Msg[0] = AV_PROTOKOLL;
	Msg[1] = Global[2];
	Msg[2] = 0;
	Msg[3] = 0x1f;
	Msg[4] = 0;
	Msg[5] = 0;
	*(BYTE **) &( Msg[6] ) = Tmp;
	MT_appl_write( AvAppId, 16, Msg, Global );
	return( AvAppId );
}

void	AvExit( WORD AvAppId, WORD Global[15] )
{
	WORD	Msg[8];
	Msg[0] = AV_EXIT;
	Msg[1] = Global[2];
	Msg[2] = 0;
	Msg[3] = Global[2];
	MT_appl_write( AvAppId, 16, Msg, Global );
}
/*-----------------------------------------------------------------------------*/
/* String und Objekstatus eines GTEXT-Objekts in der Listbox setzen            */
/* Funktionsergebnis: Nummer des zu zeichnenden Startobjekts                   */
/*  Box: Zeiger auf die Listbox-Struktur                                       */
/*  Tree: Zeiger auf den Objektbaum                                            */
/*  Item: Zeiger auf den Eintrag                                               */
/*  Index: Objektnummer                                                        */
/*  user_data: ...                                                             */
/*  Rect: GRECT fÅr Selektion/Deselektion oder 0L (nicht verÑnderbar)          */
/*-----------------------------------------------------------------------------*/
WORD cdecl	SetStrItem( LIST_BOX *Box, OBJECT *Tree, LBOX_ITEM *Item, WORD Index, void *user_data, GRECT *Rect, WORD Offset )
{
	BYTE	*ptext;
	BYTE	*str;

	ptext = Tree[Index].ob_spec.tedinfo->te_ptext;
	
	if( Item )
	{
		if( strcmp( "", ((STR_ITEM *) Item)->str ))
			if( Item->selected )
				Tree[Index].ob_state |= SELECTED;
			else
				Tree[Index].ob_state &= ~SELECTED;
		else
			Tree[Index].ob_state &= ~SELECTED;
			
		str = ((STR_ITEM *)Item)->str;
		
		if( Offset == 0 )
		{
			if( *ptext )
				*ptext++ = ' ';
		}
		else
			Offset -= 1;
		
		if( Offset <= strlen( str ))
		{
			str += Offset;
			
			while( *ptext && *str )
				*ptext++ = *str++;
		}
	}
	else
		Tree[Index].ob_state &= ~SELECTED;
	
	while( *ptext )
		*ptext++ = ' ';
	
	return( Index );
}

/*-----------------------------------------------------------------------------*/
/* PrÅft, ob eine Taste einem MenÅ-Eintrag zugeordnet ist                      */
/* Funktionsergebnis: 0: Kein MenÅ-Eintrag zugeordnet                          */
/*  Key:              Tastatur-Code gem. evnt_keybd                            */
/*  *Title:           Zeiger auf den Index des MenÅ-Eintrags                   */
/*  *Entry:           Zeiger auf den Index des MenÅ-Titels                     */
/*-----------------------------------------------------------------------------*/
WORD	IsMenuKey( WORD Key, WORD *Title, WORD *Entry )
{
	WORD	a, b, c, x, y, xEntry, yEntry;
	BYTE	Str[3];

	*Entry = 0;
	*Title = 0;

/* if-Abfragen paût nicht immer */
	Key = MapKey( Key );
	if( Key & KbCONTROL )
		Str[0] = '^';
	else if( Key & KbALT )
			Str[0] = '';
	else if( Key & KbSCAN )
	     {
        	Str[0] = 'F';
        	Key = Key - KbF1 + '1';
        }
	else	return( 0 );


	Str[1] = toupper( Key & 0xff );
	Str[2] = 0x0;

	a = TreeAddr[MENUE][0].ob_head;
	do
	{
		b = TreeAddr[MENUE][a].ob_head;
		do
		{
			c = TreeAddr[MENUE][b].ob_head;
			do
			{
				if( TreeAddr[MENUE][c].ob_type == G_STRING )
				{
					if( strstr( TreeAddr[MENUE][c].ob_spec.free_string, Str ))
					{
						*Entry = c;
						MT_objc_offset( TreeAddr[MENUE], *Entry, &xEntry, &yEntry, Global );
					}
				}
				c= TreeAddr[MENUE][c].ob_next;
			}
			while( c != b && !*Entry );
			b = TreeAddr[MENUE][b].ob_next;
		}
		while( b != a && !*Entry );
		a = TreeAddr[MENUE][a].ob_next;
	}
	while( a != 0 && !*Entry );


	if( *Entry )
	{
		a = TreeAddr[MENUE][0].ob_head;
		do
		{
			b = TreeAddr[MENUE][a].ob_head;
			do
			{
				c = TreeAddr[MENUE][b].ob_head;
				do
				{
					if( TreeAddr[MENUE][c].ob_type == G_TITLE )
					{
						MT_objc_offset( TreeAddr[MENUE], c, &x, &y, Global );
						if( x == xEntry )
							*Title = c;
					}
					c= TreeAddr[MENUE][c].ob_next;
				}
				while( c != b && !*Title );
				b = TreeAddr[MENUE][b].ob_next;
			}
			while( b != a && !*Title );
			a = TreeAddr[MENUE][a].ob_next;
		}
		while( a != 0 && !*Title );
	}

	return( *Entry );
}

/*-----------------------------------------------------------------------------*/
/* Verarbeitet Tasten, die MenÅbefehle sind                                    */
/* Funktionsergebnis: -                                                        */
/*  Key:              Tastatur-Code gem. evnt_keybd                            */
/*  Global:           Global-Feld des jeweiligen Threads                       */
/*-----------------------------------------------------------------------------*/
void	KeyEvent( WORD	Key, WORD Global[15] )
{
	WORD	Title, Entry;

	if( Key == 0 )
		return;
	if( IsMenuKey( Key, &Title, &Entry ))
	{
		if( !( TreeAddr[MENUE][Entry].ob_state & DISABLED || 
		       TreeAddr[MENUE][Title].ob_state & DISABLED ))
		{
			WORD	Msg[16];
			MT_menu_tnormal( TreeAddr[MENUE], Title, 0, Global );
			Msg[0] = MN_SELECTED;
			Msg[2] = 0;
			Msg[3] = Title;
			Msg[4] = Entry;
			(OBJECT *) *(LONG *) &(Msg[5]) = TreeAddr[MENUE];
			MT_appl_write( AppId, 16, Msg, Global );
		}
	}
}

static void StIc_Init( WORD AppId, OBJECT *BigOrig, OBJECT *SmallOrig )
{
	struct
	{
		int     version;
		long    magic;
		OBJECT* cdecl (*str_icon)       (char *string, int tree);
		void    cdecl (*ext_icon)       (int id, OBJECT *big, OBJECT *small, int flag);
		OBJECT* cdecl (*id_icon)        (int id, int tree);
		OBJECT* cdecl (*top_icon)       (int tree);
		OBJECT* cdecl (*menu_icon)      (int tree);
		int     cdecl (*menu_popup)     (MENU *me_menu, int me_xpos, int me_ypos, MENU *me_mdata);
		int     cdecl (*menu_attach)    (int me_flag, OBJECT *me_tree, int me_item, MENU *me_mdata);
		int     cdecl (*menu_settings)  (int me_flag, MN_SET *me_values);
	} *STIC;
	if(( STIC = SearchCookie( 'StIc' )) != NULL )
		STIC->ext_icon( AppId, BigOrig, SmallOrig, 1 );
}
static void	StIc_Del( WORD AppId )
{
	struct
	{
		int     version;
		long    magic;
		OBJECT* cdecl (*str_icon)       (char *string, int tree);
		void    cdecl (*ext_icon)       (int id, OBJECT *big, OBJECT *small, int flag);
		OBJECT* cdecl (*id_icon)        (int id, int tree);
		OBJECT* cdecl (*top_icon)       (int tree);
		OBJECT* cdecl (*menu_icon)      (int tree);
		int     cdecl (*menu_popup)     (MENU *me_menu, int me_xpos, int me_ypos, MENU *me_mdata);
		int     cdecl (*menu_attach)    (int me_flag, OBJECT *me_tree, int me_item, MENU *me_mdata);
		int     cdecl (*menu_settings)  (int me_flag, MN_SET *me_values);
	} *STIC;
	if(( STIC = SearchCookie( 'StIc' )) != NULL )
		STIC->ext_icon( AppId, NULL, NULL, 0 );
}

/*-----------------------------------------------------------------------------*/
/* Hauptprogramm                                                               */
/*-----------------------------------------------------------------------------*/
WORD	main( int ArgC, const char *ArgV[] )
{
	WORD	RetCode = -1;
#ifdef	MEMDEBUG
	set_MemdebugOptions( c_Yes, c_Yes, c_Yes, c_Yes, c_Yes, c_Yes, c_Yes, 0L, 0L, "C:\\var\\log\\Fiffi-Debug\\statistics", "C:\\var\\log\\Fiffi-Debug\\error" );
#endif
	Pdomain( 1 );
	GemdosVersion = GetGemdosVersion();
#ifdef MINTNET
#else
	#ifdef	V110
		if( sock_init() >= 0 )
			Sockets = 1;
	#endif
#endif
	if(( AppId = MT_appl_init( Global )) != -1 )
	{
#ifdef	NAES
		MT_menu_register( AppId, "  Fiffi", Global );
#endif
		AesHandle = MT_graf_handle( &PwChar, &PhChar, &PwBox, &PhBox, Global );
		if(( VdiHandle = OpenScreenWk( AesHandle, WorkOut )) > 0 )
		{
			MT_graf_mouse( M_SAVE, NULL, Global );
			MT_graf_mouse( BUSYBEE, NULL, Global );
			if( MT_rsrc_load( "Fiffi.rsc", Global ))
			{
				InitRsrc( &TreeAddr, &FstringAddr, Global );
				StIc_Init( AppId, &TreeAddr[ICONS][ICON_BIG], &TreeAddr[ICONS][ICON_SMALL] );
				InstalMenuBar();
				if(( AesFlags & ( GAI_WDLG + GAI_LBOX )) == ( GAI_WDLG + GAI_LBOX ))
				{
					EVNT		Events;
					DIALOG	*NewSessionDialog = 0L, *HotlistDialog = 0L, 
					         *SuffixDialog = 0L, *WindowAlertDialog = 0L,
					         *AboutDialog = NULL, *IconifyDialog = NULL, *Conf1Dialog = NULL, *Conf2Dialog = NULL,
					         *DoubleHtDialog = NULL, *NoFtpUrlDialog = NULL, *DragDropFailedDialog = NULL;
					WORD		Quit = 1, Msg[8];
					WORD		AlertStatus = 0;
					
					void		*FselDialog = 0L;
					WORD		FselButton, FselN, FselSortmode, FselHandle = 0, FselStatus = -1;
					BYTE		FselPath[PathLen], FselFile[10 * FileLen], *FselPattern;
					WORD		ThreadExitFlag = 1;
#ifdef	V110
					SESSION	DragDropSession;
#endif
#ifdef	GEMScript
					GS_INFO	*FiffiGsInfo;
#ifdef	V120
					BYTE	*GsCmd[GS_CNT] = {"AppGetLongName","cd","CheckCommand","close","get","GetAllCommands","getfront","lcd","ls","mkdir","open","put","pwd","quit","rm","rmdir","tofront","type"};
#endif
#endif
#ifdef	GEMScript
					FiffiGsInfo = Xmalloc( sizeof( GS_INFO ), RAM_READABLE );
					FiffiGsInfo->len = sizeof( GS_INFO );
					FiffiGsInfo->version = 0x0100;
					FiffiGsInfo->msgs = GSM_COMMAND;
					FiffiGsInfo->ext = 0L;
#endif
					MT_shel_write( SHW_INFRECGN, 1, 0, 0L, 0L, Global );
					AvInit( "FIFFI   ", Global );
					ReadConfig();
#ifdef	V120
					CreatePopupTree( &HotlistPopupTree, nHotlist, HotlistName );
					CreateSubmenuTree( &HotlistSubmenuTree, nHotlist, HotlistName );
#else
					CreatePopupTree( &HotlistPopupTree, nHotlist, HotlistHost );
					CreateSubmenuTree( &HotlistSubmenuTree, nHotlist, HotlistHost );
#endif

					InstalMenuBar();
					MT_graf_mouse( M_RESTORE, NULL, Global );

					if( ArgC > 1 )
					{
						Msg[0] = VA_START;
						Msg[1] = AppId;
						Msg[2] = 0;
						(BYTE * ) *(long *)&( Msg[3] ) = (BYTE * ) ArgV[1];
						MT_appl_write( AppId, 16, Msg, Global );
					}	
					RetCode = 0;
					while( Quit )
					{
						if( GetFirstWindow() != -1 )
						{
							WORD	w1, w2, w3, w4;
							WORD	a1, a2, a3, a4;
							WORD	w = GetFirstWindow();
							MT_menu_ienable( TreeAddr[MENUE], MENUE_CLS_W, 1, Global );
							MT_menu_ienable( TreeAddr[MENUE], MENUE_CLS_ALL, 1, Global );
							MT_menu_ienable( TreeAddr[MENUE], MENUE_CYC_W, 0, Global );
							while(( w = GetNextWindow( w )) != -1 )
								if( !isAllIconifiedWindow( w ))
								{
									MT_menu_ienable( TreeAddr[MENUE], MENUE_CYC_W, 1, Global );
									break;
								}
							MT_wind_get( 0, WF_TOP, &w1, &w2, &w3, &w4, Global );
#ifdef	GEMScript
							if( isWindow( w1 ))
								SetTopWindow( w1 );
#endif
							if( w2 != AppId )
								MT_menu_ienable( TreeAddr[MENUE], MENUE_CLOSE_SES, 1, Global );
							else
								MT_menu_ienable( TreeAddr[MENUE], MENUE_CLOSE_SES, 0, Global );
							if(( AesFlags & GAI_INFO ) && MT_appl_getinfo( 6, &a1, &a2, &a3, &a4, Global ) && a3 );
							{
								MT_wind_update( BEG_UPDATE, Global );
								if( MT_menu_bar( TreeAddr[MENUE], -1, Global ) != AppId && GetAppIdWindow( w1 ) != -1 )
								{
									MT_menu_bar( TreeAddr[MENUE], MENU_SHOW, Global );
									MT_wind_set( w1, WF_TOP, 0, 0, 0, 0, Global );
								}
								MT_wind_update( END_UPDATE, Global );
							}
						}
						else
						{
							MT_menu_ienable( TreeAddr[MENUE], MENUE_CLOSE_SES, 0, Global );
							MT_menu_ienable( TreeAddr[MENUE], MENUE_CLS_W, 0, Global );
							MT_menu_ienable( TreeAddr[MENUE], MENUE_CYC_W, 0, Global );
							MT_menu_ienable( TreeAddr[MENUE], MENUE_CLS_ALL, 0, Global );
						}

						if( !( FileSelectorFlag && FselDialog ))
							MT_EVNT_multi( MU_KEYBD + MU_BUTTON + MU_MESAG, 0x102, 3, 0, 0L, 0L, 250, &Events, Global );
						else
							Events.mwhich = 0;
							
						if( IconifyDialog )
							if( MT_wdlg_evnt( IconifyDialog, &Events, Global ) == 0 )
							{
								CloseDialog( IconifyDialog, Global );
								IconifyDialog = NULL;
								continue;
							}
						if( AboutDialog )
							if( MT_wdlg_evnt( AboutDialog, &Events, Global ) == 0 )
							{
								CloseDialog( AboutDialog, Global );
								AboutDialog = NULL;
								continue;
							}
						if( NewSessionDialog )
							if( MT_wdlg_evnt( NewSessionDialog, &Events, Global ) == 0 )
							{
								CloseDialog( NewSessionDialog, Global );
								NewSessionDialog = 0L;
								continue;
							}

						if( HotlistDialog )
							if( MT_wdlg_evnt( HotlistDialog, &Events, Global ) == 0 )
							{
								CloseDialog( HotlistDialog, Global );
								HotlistDialog = 0L;
								continue;
							}
						if( SuffixDialog )
							if( MT_wdlg_evnt( SuffixDialog, &Events, Global ) == 0 )
							{
								CloseDialog( SuffixDialog, Global );
								SuffixDialog = 0L;
								continue;
							}
						if( Conf1Dialog )
							if( MT_wdlg_evnt( Conf1Dialog, &Events, Global ) == 0 )
							{
								if( FselDialog )
								{
									MT_fslx_close( FselDialog, Global );
									FselDialog = NULL;
								}
								CloseDialog( Conf1Dialog, Global );
								Conf1Dialog = 0L;
								continue;
							}
						if( Conf2Dialog )
							if( MT_wdlg_evnt( Conf2Dialog, &Events, Global ) == 0 )
							{
								CloseDialog( Conf2Dialog, Global );
								Conf2Dialog = 0L;
								continue;
							}
#ifdef	V110
						if( DoubleHtDialog )
							if( MT_wdlg_evnt( DoubleHtDialog, &Events, Global ) == 0 )
							{
								CloseDialog( DoubleHtDialog, Global );
								DoubleHtDialog = NULL;
								if( TreeAddr[DHT][DHT_OK].ob_state & SELECTED )
								{
#ifdef	V120
									InsertHtItem( DragDropSession.Host, DragDropSession.Host, DragDropSession.Port, DragDropSession.Uid, DragDropSession.Pwd, DragDropSession.Dir, DragDropSession.Comment );
#else
									InsertHtItem( DragDropSession.Host, DragDropSession.Port, DragDropSession.Uid, DragDropSession.Pwd, DragDropSession.Dir, DragDropSession.Comment );
#endif
									FreeSession( &DragDropSession );
									Msg[0] = Main_UpdateMenu;
									Msg[1] = -1;
									Msg[2] = 0;
									MT_appl_write( AppId, 16, Msg, Global );
								}
								continue;
							}
#endif
						if( DragDropFailedDialog )
							if( MT_wdlg_evnt( DragDropFailedDialog, &Events, Global ) == 0 )
							{
								CloseDialog( DragDropFailedDialog, Global );
								DragDropFailedDialog = NULL;
								continue;
							}
						if( NoFtpUrlDialog )
							if( MT_wdlg_evnt( NoFtpUrlDialog, &Events, Global ) == 0 )
							{
								CloseDialog( NoFtpUrlDialog, Global );
								NoFtpUrlDialog = NULL;
								continue;
							}
						if( WindowAlertDialog )
							if( MT_wdlg_evnt( WindowAlertDialog, &Events, Global ) == 0 )
							{
								CloseDialog( WindowAlertDialog, Global );
								WindowAlertDialog = 0L;
								if( AlertStatus == Main_Shutdown )
								{
									if( TreeAddr[ALERT][ALERT_BUTTON_0].ob_state & SELECTED )
									{
										Msg[0] = Main_Shutdown;
										Msg[2] = 0;
										Msg[1] = AppId;
										MT_appl_write( AppId, 16, Msg, Global );
									}
									if( TreeAddr[ALERT][ALERT_BUTTON_1].ob_state & SELECTED )
									{
										Msg[0] = AP_TFAIL;
										Msg[2] = 0;
										Msg[1] = -1;
										MT_shel_write(SHW_AESSEND, 0, 0, (char *) Msg, NULL, Global );
									}
								}
								continue;
							}
						if( FselDialog )
							if( FileSelectorFlag || !MT_fslx_evnt( FselDialog, &Events, FselPath, FselFile, &FselButton, &FselN, &FselSortmode, &FselPattern, Global ))
							{
								GRECT		Rect;
								OBJECT	*DialogTree;
								if( FileSelectorFlag )
									*( strrchr( FselPath, '\\' ) + 1 ) = 0;
								MT_wdlg_get_tree( Conf1Dialog, &DialogTree, &Rect, Global );
								if( FselStatus == Fsel_Conf_Rx || FselStatus == Fsel_Conf_Tx || FselStatus == Fsel_Conf_Log )
								{
									DialogTree[CONF1_OK].ob_state &= ~DISABLED;
									DialogTree[CONF1_OK].ob_flags |= SELECTABLE;
									DialogTree[CONF1_CANCEL].ob_state &= ~DISABLED;
									DialogTree[CONF1_CANCEL].ob_flags |= SELECTABLE;
									DialogTree[CONF1_TX].ob_state &= ~DISABLED;
									DialogTree[CONF1_TX].ob_flags |= TOUCHEXIT;
									DialogTree[CONF1_TX].ob_flags |= EDITABLE;
									DialogTree[CONF1_RX].ob_state &= ~DISABLED;
									DialogTree[CONF1_RX].ob_flags |= TOUCHEXIT;
									DialogTree[CONF1_RX].ob_flags |= EDITABLE;
									DialogTree[CONF1_LOG].ob_state &= ~DISABLED;
									DialogTree[CONF1_LOG].ob_flags |= TOUCHEXIT;
									DialogTree[CONF1_LOG].ob_flags |= EDITABLE;
									if( FselStatus == Fsel_Conf_Rx && FselButton )
									{
										strcpy( DialogTree[CONF1_RX].ob_spec.tedinfo->te_ptext, FselPath );
										MT_wdlg_set_edit( Conf1Dialog, 0, Global );
										MT_wdlg_set_edit( Conf1Dialog, CONF1_RX, Global );
										FselStatus = -1;
									}
									if( FselStatus == Fsel_Conf_Tx && FselButton )
									{
										strcpy( DialogTree[CONF1_TX].ob_spec.tedinfo->te_ptext, FselPath );
										MT_wdlg_set_edit( Conf1Dialog, 0, Global );
										MT_wdlg_set_edit( Conf1Dialog, CONF1_TX, Global );
										FselStatus = -1;
									}
									if( FselStatus == Fsel_Conf_Log && FselButton )
									{
										strcpy( DialogTree[CONF1_LOG].ob_spec.tedinfo->te_ptext, FselPath );
										MT_wdlg_set_edit( Conf1Dialog, 0, Global );
										MT_wdlg_set_edit( Conf1Dialog, CONF1_LOG, Global );
										FselStatus = -1;
									}
									DoRedrawX( Conf1Dialog, &Rect, Global, CONF1_RX,
									           CONF1_TX, CONF1_LOG, CONF1_OK, CONF1_CANCEL, EDRX );
								}
								if( !FileSelectorFlag )
									MT_fslx_close( FselDialog, Global );
								FselDialog = 0L;
							}

						if( Events.mwhich & MU_KEYBD )
							KeyEvent( Events.key, Global );

						if( Events.mwhich & MU_MESAG )
						{
							switch( Events.msg[0] )
							{
/******************************************************************************/
/* AV-Protokoll                                                               */
/******************************************************************************/
								case	VA_PROTOSTATUS:
									AvAppId = Events.msg[1];
									break;
								case	VA_START:
								{
									if( ( BYTE *) *( LONG *)&( Events.msg[3] ) && strlen(( BYTE *) *( LONG *)&( Events.msg[3] )))
									{
										BYTE	*Url = strdup(( BYTE *) *( LONG *)&( Events.msg[3] ));
										if( !Url )
											return( ENSMEM );
										if( newGemFtp( Url, Global ) <= 0 )
											MT_form_alert( 1, FstringAddr[THREAD_FAILED], Global );
										Msg[0] = AV_STARTED;
										Msg[1] = AppId;
										Msg[2] = 0;
										Msg[3] = Events.msg[3];
										Msg[4] = Events.msg[4];
										MT_appl_write( Events.msg[1], 16, Msg, Global );
									}
									else
										InstalMenuBar();
									break;
								}

								case	AP_TERM:
									Msg[0] = MN_SELECTED;
									Msg[1] = AppId;
									Msg[2] = 0;
									Msg[3] = MENUE_SESSION;
									Msg[4] = MENUE_QUIT;
									( OBJECT * ) *(LONG *) &(Msg[5]) = TreeAddr[MENUE];
									MT_appl_write( AppId, 16, Msg, Global );
									break;
/******************************************************************************/
/* GEMScript                                                                  */
/******************************************************************************/
#ifdef	GEMScript
								case	GS_REQUEST:
								{
									GS_INFO	*Tmp = *( GS_INFO ** )&( Events.msg[3] );
									Msg[0] = GS_REPLY;
									Msg[1] = AppId;
									Msg[2] = 0;
									*( GS_INFO ** )&(Msg[3] ) = FiffiGsInfo;
									Msg[5] = 0;
									Msg[6] = 0;
									Msg[7] = Events.msg[7];
									MT_appl_write( Events.msg[1], 16, Msg, Global );
									break;
								}
								case	GS_ACK:
									if( *( BYTE ** )&( Events.msg[5] ))
										Mfree( *( BYTE ** )&( Events.msg[5] ));
									if( *( BYTE ** )&( Events.msg[3] ))
									{
										Msg[0] = GS_ACK;
										Msg[1] = AppId;
										Msg[2] = 0;
										Msg[3] = Events.msg[3];
										Msg[4] = Events.msg[4];
										Msg[5] = 0;
										Msg[6] = 0;
										Msg[7] = 0;
										MT_appl_write( Events.msg[1], 16, Msg, Global );
									}
									break;
								case	GS_QUIT:
									break;
								case	GS_COMMAND:
								{
									BYTE	*Cmd = *( BYTE **) &Events.msg[3];
/* GEMScript: AppGetLongName -------------------------------------------------*/
									if( !stricmp( Cmd, "AppGetLongName" ))
									{
										Msg[0] = GS_ACK;
										Msg[1] = AppId;
										Msg[2] = 0;
										*( BYTE ** ) &Msg[3] = Cmd;
										if( Events.msg[6] == -1 )
										{
											*( BYTE ** ) &Msg[5] = Xmalloc( 2, RAM_READABLE );
											*( *( BYTE ** ) &Msg[5] + 0 ) = 0;
											*( *( BYTE ** ) &Msg[5] + 1 ) = 0;
										}
										else
										{
											*( BYTE ** ) &Msg[5] = Xmalloc( 7, RAM_READABLE );
											strcpy( *( BYTE ** ) &Msg[5], "Fiffi" );
											*(( *( BYTE ** ) &Msg[5] ) + 6 ) = 0;
										}
										Msg[7] = GSACK_OK;
										MT_appl_write( Events.msg[1], 16, Msg, Global );
										break;
									}
/* GEMScript: close ----------------------------------------------------------*/
									if( !stricmp( Cmd, "close" ))
									{
										BYTE	*Para = Cmd + strlen( Cmd ) + 1;
										if( strlen( Para ) == 0 )
										{
											if( GetTopWindow() != -1 )
											{
												WORD	w1, w2, w3, w4;
												MT_wind_get( GetTopWindow(), WF_OWNER, &w1, &w2, &w3, &w4, Global );
												if( w1 != AppId )
												{
													Msg[0] = GS_CONNECTION;
													Msg[1] = Events.msg[1];
													Msg[2] = 0;
													Msg[3] = Events.msg[3];
													Msg[4] = Events.msg[4];
													Msg[5] = Events.msg[5];
													Msg[6] = Events.msg[6];
													Msg[7] = AppId;
													MT_appl_write( w1, 16, Msg, Global );
												}
												else
												{
													Msg[0] = GS_ACK;
													Msg[1] = AppId;
													Msg[2] = 0;
													*( BYTE ** ) &Msg[3] = Cmd;
													*( BYTE ** ) &Msg[5] = NULL;
													Msg[7] = GSACK_ERROR;
													MT_appl_write( Events.msg[1], 16, Msg, Global );
												}
											}
											break;
										}
									}
/* GEMScript: GetFront -------------------------------------------------------*/
									if( !stricmp( Cmd, "GetFront" ))
									{
										if( GetTopWindow() != -1 )
										{
											WORD	w1, w2, w3, w4;
											MT_wind_get( GetTopWindow(), WF_OWNER, &w1, &w2, &w3, &w4, Global );
											if( w1 != AppId )
											{
												Msg[0] = GS_CONNECTION;
												Msg[1] = Events.msg[1];
												Msg[2] = 0;
												Msg[3] = Events.msg[3];
												Msg[4] = Events.msg[4];
												Msg[5] = Events.msg[5];
												Msg[6] = Events.msg[6];
												Msg[7] = AppId;
												MT_appl_write( w1, 16, Msg, Global );
												break;
											}
										}
										Msg[0] = GS_ACK;
										Msg[1] = AppId;
										Msg[2] = 0;
										*( BYTE **) &Msg[3] = Cmd;
										*( BYTE **) &Msg[5] = NULL;
										Msg[7] = GSACK_ERROR;
										MT_appl_write( Events.msg[1], 16, Msg, Global );
										break;
									}
/* GEMScript: lcd ------------------------------------------------------------*/
									if( !stricmp( Cmd, "lcd" ))
									{
										BYTE	*Para = Cmd + strlen( Cmd ) + 1;
										LONG	Err;
										XATTR	Xattr;
										Msg[0] = GS_ACK;
										Msg[1] = AppId;
										Msg[2] = 0;
										*( BYTE **) &Msg[3] = Cmd;
										if(( Err = Fxattr( 0, Para, &Xattr )) != E_OK )
										{
											BYTE	*Ret = Xmalloc( 7, RAM_READABLE );
											itoa(( WORD ) Err, Ret, 10 );
											Ret[strlen( Ret ) + 1] = 0;
											*( BYTE **) &Msg[5] = Ret;
											Msg[7] = GSACK_OK;
										}
										else
										{
											BYTE	*Ret = Xmalloc( 3, RAM_READABLE );
											if( RxDir )
												free( RxDir );
											RxDir = malloc( strlen( Para ) + 2 );
											strcpy( RxDir, Para );
											if( Para[strlen(Para)] != '\\' )
												RxDir[strlen(RxDir)+1] = '\\';
											Ret[0] = '0';
											Ret[1] = 0;
											Ret[2] = 0;
											*( BYTE **) &Msg[5] = Ret;
											Msg[7] = GSACK_OK;
										}
										MT_appl_write( Events.msg[1], 16, Msg, Global );
										break;
									}
/* GEMScript: New ------------------------------------------------------------*/
									if( !stricmp( Cmd, "New" ))
									{
										Msg[0] = MN_SELECTED;
										Msg[1] = AppId;
										Msg[2] = 0;
										Msg[3] = MENUE_SESSION;
										Msg[4] = MENUE_NEW_SES;
										*( OBJECT ** )&( Msg[5] ) = TreeAddr[MENUE];
										MT_appl_write( AppId, 16, Msg, Global );
										Msg[0] = GS_ACK;
										Msg[1] = AppId;
										Msg[2] = 0;
										*( BYTE ** ) &Msg[3] = Cmd;
										*( BYTE ** ) &Msg[5] = NULL;
										Msg[7] = GSACK_OK;
										MT_appl_write( Events.msg[1], 16, Msg, Global );
										break;
									}
/* GEMScript: Open -----------------------------------------------------------*/
									if( !stricmp( Cmd, "open" ))
									{
										BYTE	*Para = Cmd + strlen( Cmd ) + 1;
										Msg[0] = GS_ACK;
										Msg[1] = AppId;
										Msg[2] = 0;
										*( BYTE ** ) &Msg[3] = Cmd;
										{
											WORD	GemFtpAppId;
											BYTE	*Url;
											{
												WORD	Port = ComPort;
												BYTE	*Host = Para, *Uid = NULL, *Pwd = NULL;
												if( strlen( Host ) != 0 )
												{
													if( Host[strlen( Host ) + 1] != 0 )
														Uid = Host + strlen( Host ) + 1;
													if( Uid && Uid[strlen( Uid ) + 1] != 0 )
														Pwd = Uid + strlen( Uid ) + 1;
													if( Pwd && Pwd[strlen( Pwd ) + 1] != 0 )
														Port = atoi( Pwd + strlen(Pwd) + 1 );
												}
												Url = MakeFtpUrl( Host, Port, Uid, Pwd, NULL );
											}

											while( GsConnection )
												MT_appl_yield( Global );
											GsConnection = 1;
											if(( GemFtpAppId = newGemFtp( Url, Global )) <= 0 )
											{
												BYTE	*Ret = Xmalloc( 4, RAM_READABLE );
												strcpy( Ret, "-1" );
												Ret[3] = 0;
												*( BYTE **) &Msg[5] = Ret;
												Msg[7] = GSACK_OK;
											}
											else
											{
												Msg[0] = GS_CONNECTION;
												Msg[1] = Events.msg[1];
												Msg[2] = 0;
												Msg[3] = Events.msg[3];
												Msg[4] = Events.msg[4];
												Msg[5] = Events.msg[5];
												Msg[6] = Events.msg[6];
												Msg[7] = AppId;
												MT_appl_write( GemFtpAppId, 16, Msg, Global );
												break;
											}
										}
										MT_appl_write( Events.msg[1], 16, Msg, Global );
										break;
									}
/* GEMScript: Quit -----------------------------------------------------------*/
									if( !stricmp( Cmd, "Quit" ))
									{
										BYTE	*Para = Cmd + strlen( Cmd ) + 1;
										if( !stricmp( Para, "-q" ) || !stricmp( Para, "-quiet" ))
											Msg[0] = Main_Shutdown;
										else
											Msg[0] = AP_TERM;
										Msg[1] = AppId;
										Msg[2] = 0;
										MT_appl_write( AppId, 16, Msg, Global );
										Msg[0] = GS_ACK;
										Msg[1] = AppId;
										Msg[2] = 0;
										*( BYTE ** ) &Msg[3] = Cmd;
										*( BYTE ** ) &Msg[5] = NULL;
										Msg[7] = GSACK_OK;
										MT_appl_write( Events.msg[1], 16, Msg, Global );
										break;
									}
/* GEMScript: ToFront ---------------------------------------------------------*/
									if( !stricmp( Cmd, "ToFront" ))
									{
										BYTE	*Para = Cmd + strlen( Cmd ) + 1;
										if( *Para == 0 )
										{
											BYTE	*Ret = Xmalloc( 4, RAM_READABLE );
											Ret[0] = '-';
											Ret[1] = '1';
											Ret[2] = 0;
											Ret[3] = 0;
											Msg[0] = GS_ACK;
											Msg[1] = AppId;
											Msg[2] = 0;
											*( BYTE **) &Msg[3] = Cmd;
											*( BYTE **) &Msg[5] = Ret;
											Msg[7] = GSACK_ERROR;
											MT_appl_write( Events.msg[1], 16, Msg, Global );
											break;
										}
										if( strspn( Para, "0123456789" ) != strlen( Para ))
										{
											WORD	i = 0;
											BYTE	*Url;
											while(( Url = GetThreadUrl( i, Global )) != NULL )
											{
												if( strstr( Url, Para ) != NULL )
													break;
												else
													i++;
											}
											if( Url != NULL )
											{
												Msg[0] = GS_CONNECTION;
												Msg[1] = Events.msg[1];
												Msg[2] = 0;
												Msg[3] = Events.msg[3];
												Msg[4] = Events.msg[4];
												Msg[5] = Events.msg[5];
												Msg[6] = Events.msg[6];
												Msg[7] = AppId;
												MT_appl_write( GetThreadAppId( i, Global ), 16, Msg, Global );
											}
											else
											{
												BYTE	*Ret = Xmalloc( 4, RAM_READABLE );
												Ret[0] = '-';
												Ret[1] = '1';
												Ret[2] = 0;
												Ret[3] = 0;
												Msg[0] = GS_ACK;
												Msg[1] = AppId;
												Msg[2] = 0;
												*( BYTE **) &Msg[3] = Cmd;
												*( BYTE **) &Msg[5] = Ret;
												Msg[7] = GSACK_ERROR;
												MT_appl_write( Events.msg[1], 16, Msg, Global );
											}
											break;
										}
										/* Nur der vollstÑndigkeithalber: tofront 
										   funktioniert auch mit der session (nicht dokumentiert) */
									}
/* GEMScript: GetAllCommands -------------------------------------------------*/
									if( !stricmp( Cmd, "GetAllCommands" ))
									{
										BYTE	*Ret, *p;
										WORD	i = 0, l = 0;
										for( i = 0; i < GS_CNT; i++ )
											l += strlen( GsCmd[i] ) + 1;
										l++;
										Ret = Xmalloc( l, RAM_READABLE );
										p = Ret;
										if( Ret )
										{
											for( i = 0; i < GS_CNT; i++ )
											{
												strcpy( p, GsCmd[i] );
												p += strlen( GsCmd[i] ) + 1;
											}
											*p = 0;
										}
										Msg[0] = GS_ACK;
										Msg[1] = AppId;
										Msg[2] = 0;
										*( BYTE ** ) &Msg[3] = Cmd;
										*( BYTE ** ) &Msg[5] = Ret;
										Msg[7] = GSACK_OK;
										MT_appl_write( Events.msg[1], 16, Msg, Global );
										break;
									}
/* GEMScript: CheckCommand -------------------------------------------------*/
									if( !stricmp( Cmd, "CheckCommand" ))
									{
										WORD	i;
										BYTE	*Ret = Xmalloc( 3, RAM_READABLE );
										BYTE	*Para = Cmd + strlen( Cmd ) + 1;
										if( Ret )
										{
											Ret[0] = '0';
											Ret[1] = 0;
											Ret[2] = 0;
											for( i = 0; i < GS_CNT; i++ )
												if( !stricmp( Para, GsCmd[i] ))
												{
													Ret[0] = '1';
													break;
												}
										}
										Msg[0] = GS_ACK;
										Msg[1] = AppId;
										Msg[2] = 0;
										*( BYTE ** ) &Msg[3] = Cmd;
										*( BYTE ** ) &Msg[5] = Ret;
										Msg[7] = GSACK_OK;
										MT_appl_write( Events.msg[1], 16, Msg, Global );
										break;
									}
/* ---------------------------------------------------------------------------*/
									if( !stricmp( Cmd, "cd" ) || !stricmp( Cmd, "close" ) || 
									    !stricmp( Cmd, "get" ) || !stricmp( Cmd, "put" ) ||
									    !stricmp( Cmd, "mkdir" ) || !stricmp( Cmd, "rmdir" ) ||
									    !stricmp( Cmd, "rm" ) || !stricmp( Cmd, "pwd" ) ||
									    !stricmp( Cmd, "ls" ) || !stricmp( Cmd, "type" ) ||
									    !stricmp( Cmd, "tofront" ) || !stricmp( Cmd, "chmod" ))
									{
										BYTE	*Para = Cmd + strlen( Cmd ) + 1;
										WORD	GemFtpAppId = atoi( Para ), i = 0, j;
										while(( j = GetThreadAppId( i++, Global )) != -1 )
											if( j == GemFtpAppId )
												break;
										if( j != GemFtpAppId )
										{
											BYTE	*Ret = Xmalloc( 4, RAM_READABLE );
											Msg[0] = GS_ACK;
											Msg[1] = AppId;
											Msg[2] = 0;
											Ret[0] = '-';
											Ret[1] = '1';
											Ret[2] = 0;
											Ret[3] = 0;
											*( BYTE **) &Msg[5] = Ret;
											*( BYTE **) &Msg[3] = Cmd;
											Msg[7] = GSACK_ERROR;
											MT_appl_write( Events.msg[1], 16, Msg, Global );
										}
										else
										{
											Msg[0] = GS_CONNECTION;
											Msg[1] = Events.msg[1];
											Msg[2] = 0;
											Msg[3] = Events.msg[3];
											Msg[4] = Events.msg[4];
											Msg[5] = Events.msg[5];
											Msg[6] = Events.msg[6];
											Msg[7] = AppId;
											MT_appl_write( GemFtpAppId, 16, Msg, Global );
										}
										break;
									}
/* GEMScript: Unknown Command ------------------------------------------------*/
									Msg[0] = GS_ACK;
									Msg[1] = AppId;
									Msg[2] = 0;
									*( BYTE **) &Msg[3] = Cmd;
									*( BYTE **) &Msg[5] = NULL;
									Msg[7] = GSACK_UNKNOWN;
									MT_appl_write( Events.msg[1], 16, Msg, Global );
									break;
								}
#endif
/* AP_DRAGDROP ----------------------------------------------------------------*/
								case	AP_DRAGDROP:
								{
									void	*OldSig;
									LONG	Size;
									WORD	Fd;
									BYTE	Pipename[] = "U:\\PIPE\\DRAGDROP.AA";
									ULONG	FormatRcvr[8], Format;
									BYTE	Name[255];

									Pipename[18] = Events.msg[7] & 0x00ff;
									Pipename[17] = ( Events.msg[7] & 0xff00 ) >> 8;
									FormatRcvr[0] = 'URLS';
									FormatRcvr[1] = '.ASC';	FormatRcvr[2] = '.TXT';	FormatRcvr[3] = 0;	FormatRcvr[4] = 0;
									FormatRcvr[5] = 0;	FormatRcvr[6] = 0;	FormatRcvr[7] = 0;

									if( Events.msg[3] != - 1 &&
									    !( HotlistDialog && Events.msg[3] == MT_wdlg_get_handle( HotlistDialog, Global )) &&
									    !( NewSessionDialog && Events.msg[3] == MT_wdlg_get_handle( NewSessionDialog, Global )))
									{
										Fd = ( WORD ) Fopen (Pipename, 2);
										if (Fd >= 0)
										{
											BYTE c = DD_NAK;
											Fwrite ((WORD) Fd, 1, &c);
											Fclose ((WORD) Fd);
										}
										break;
									}
									if(( Fd = ddopen( Pipename, FormatRcvr, &OldSig )) != -1 )
									{
										while( ddrtry( Fd, Name, &Format, &Size) == 1 )
										{
											if( Format == 'URLS' || Format == '.ASC' || Format == '.TXT' )
											{
												WORD	n;
												BYTE	*c, *Data = malloc( Size * sizeof( BYTE ) + 1 );
												if( !Data )
													return( ENSMEM );
												ddreply( Fd, DD_OK );
												Fread( Fd, Size, Data );
												Data[Size] = 0;
												n = parse_ARGS( Data );
												c = Data;
												while( n )
												{
													BYTE	*Url = strdup( c );
													if( !Url )
														return( ENSMEM );
													if( strnicmp( Url, "ftp://", 6 ) == 0 )
													{
														if( NewSessionDialog && Events.msg[3] == MT_wdlg_get_handle( NewSessionDialog, Global ))
														{
															ParseFtpUrl( Url, &DragDropSession );
															InsertNsItem( DragDropSession.Host, DragDropSession.Port, DragDropSession.Uid, DragDropSession.Pwd, DragDropSession.Dir, NewSessionDialog );
															FreeSession( &DragDropSession );
														}
														if( HotlistDialog && Events.msg[3] == MT_wdlg_get_handle( HotlistDialog, Global ))
														{
															ParseFtpUrl( Url, &DragDropSession );
															if( Format == 'URLS' && ( WORD ) strlen( Url ) < Size )
															{
#ifdef	V120
																c += strlen( c ) + 1;
																DragDropSession.Name = strdup( c );
																DragDropSession.Comment = NULL;
#else
																BYTE *d = c + strlen( c ) + 1;
																DragDropSession.Comment = strdup( d );
#endif
															}
															else
															{
																DragDropSession.Comment = NULL;
#ifdef	V120
																DragDropSession.Name = NULL;
#endif
															}
#ifdef	V120
															if( !DragDropSession.Name )
																DragDropSession.Name = strdup( DragDropSession.Host );
															if( ExistHtItem( DragDropSession.Name ))
#else
															if( ExistHtItem( DragDropSession.Host ))
#endif
															{
																if( !DoubleHtDialog	)
																	DoubleHtDialog = OpenDialog( TreeAddr[DHT], "[Fiffi] Drag&Drop", HandleDoubleHtDialog, Global, Global );
																else
																{
																	FreeSession( &DragDropSession );
																	Msg[0] = WM_TOPPED;
																	Msg[1] = AppId;
																	Msg[2] = 0;
																	Msg[3] = MT_wdlg_get_handle( DoubleHtDialog, Global );
																	MT_appl_write( AppId, 16, Msg, Global );
																}
															}
															else
															{
#ifdef	V120
																InsertHtItem( DragDropSession.Name, DragDropSession.Host, DragDropSession.Port, DragDropSession.Uid, DragDropSession.Pwd, DragDropSession.Dir, DragDropSession.Comment );
#else
																InsertHtItem( DragDropSession.Host, DragDropSession.Port, DragDropSession.Uid, DragDropSession.Pwd, DragDropSession.Dir, DragDropSession.Comment );
#endif
																FreeSession( &DragDropSession );
																Msg[0] = Main_UpdateMenu;
																Msg[1] = Events.msg[1];
																Msg[2] = 0;
																MT_appl_write( AppId, 16, Msg, Global );
															}
														}
														if( Events.msg[3] == -1 )
														{
															if( newGemFtp( Url, Global ) <= 0 )
																MT_form_alert( 1, FstringAddr[THREAD_FAILED], Global );
														}
													}
													else
													{
														if( !NoFtpUrlDialog	)
															NoFtpUrlDialog = OpenDialog( TreeAddr[NFU], "[Fiffi] Drag&Drop", HandleNoFtpUrlDialog, Global, Global );
														else
														{
															Msg[0] = WM_TOPPED;
															Msg[1] = AppId;
															Msg[2] = 0;
															Msg[3] = MT_wdlg_get_handle( NoFtpUrlDialog, Global );
															MT_appl_write( AppId, 16, Msg, Global );
														}
													}
													c += strlen( c ) + 1;
													n--;
												}
												free( Data );
												break;
											}
											else
												if( !ddreply( Fd, DD_EXT ))
													break;
										}
										ddclose( Fd, OldSig );
									}
									break;
								}
								case	DRAGDROP:
								{
									BYTE	*Url = *(BYTE **) &( Events.msg[4] );
									if( Url )
									{
										if( ( HotlistDialog && Events.msg[3] == MT_wdlg_get_handle( HotlistDialog, Global )) || 
									       ( NewSessionDialog && Events.msg[3] == MT_wdlg_get_handle( NewSessionDialog, Global )))
										{
											if( strnicmp( Url, "ftp://", 6 ) == 0 )
											{
												if( NewSessionDialog && Events.msg[3] == MT_wdlg_get_handle( NewSessionDialog, Global ))
												{
													ParseFtpUrl( Url, &DragDropSession );
													InsertNsItem( DragDropSession.Host, DragDropSession.Port, DragDropSession.Uid, DragDropSession.Pwd, DragDropSession.Dir, NewSessionDialog );
													FreeSession( &DragDropSession );
												}
												if( HotlistDialog && Events.msg[3] == MT_wdlg_get_handle( HotlistDialog, Global ))
												{
													ParseFtpUrl( Url, &DragDropSession );
													DragDropSession.Comment = NULL;
													DragDropSession.Name = strdup( DragDropSession.Host );
													if( ExistHtItem( DragDropSession.Name ))
													{
														if( !DoubleHtDialog	)
															DoubleHtDialog = OpenDialog( TreeAddr[DHT], "[Fiffi] Drag&Drop", HandleDoubleHtDialog, Global, Global );
														else
														{
															FreeSession( &DragDropSession );
															Msg[0] = WM_TOPPED;
															Msg[1] = AppId;
															Msg[2] = 0;
															Msg[3] = MT_wdlg_get_handle( DoubleHtDialog, Global );
															MT_appl_write( AppId, 16, Msg, Global );
														}
													}
													else
													{
														InsertHtItem( DragDropSession.Name, DragDropSession.Host, DragDropSession.Port, DragDropSession.Uid, DragDropSession.Pwd, DragDropSession.Dir, DragDropSession.Comment );
														FreeSession( &DragDropSession );
														Msg[0] = Main_UpdateMenu;
														Msg[1] = Events.msg[1];
														Msg[2] = 0;
														MT_appl_write( AppId, 16, Msg, Global );
													}
												}
											}
											else
											{
												if( !NoFtpUrlDialog	)
													NoFtpUrlDialog = OpenDialog( TreeAddr[NFU], "[Fiffi] Drag&Drop", HandleNoFtpUrlDialog, Global, Global );
												else
												{
													Msg[0] = WM_TOPPED;
													Msg[1] = AppId;
													Msg[2] = 0;
													Msg[3] = MT_wdlg_get_handle( NoFtpUrlDialog, Global );
													MT_appl_write( AppId, 16, Msg, Global );
												}
											}
										}
										else
											Cconout( '\a' );
										free( Url );
									}
									break;
								}
/* WM_ALLICONIFY --------------------------------------------------------------*/
								case	WM_ALLICONIFY:
								{
									OBJECT	*DialogTree;
									Msg[3] = GetFirstWindow();
									if( Msg[3] != -1 )
									{
										Msg[0] = WM_ICONIFY;
										Msg[1] = AppId;
										Msg[2] = 0;
										Msg[4] = 20000; Msg[5] = 20000; Msg[6] = 0; Msg[7] = 0;
										do
										{
											MT_appl_write( GetAppIdWindow( Msg[3] ), 16, Msg, Global );
											AllIconifyWindow( Msg[3] );
											Msg[3] = GetNextWindow( Msg[3] );
										}
										while( Msg[3] != -1 );
									}
									if( IconifyDialog )
									{
										CloseDialog( IconifyDialog, Global );
										IconifyDialog = NULL;
									}
									IconifyDialog = OpenDialog( TreeAddr[ICONIFY], FstringAddr[ICONIFY_TITLE], HandleIconifyDialog, Global, Global );
									DialogTree = malloc( 2 * sizeof( OBJECT ));
									if( !DialogTree )
									{
										MemErr( "main" );
										return( ENSMEM );
									}
									memcpy( DialogTree, TreeAddr[ICONIFY], 2 * sizeof( OBJECT ));
									MT_wdlg_set_iconify( IconifyDialog, ( GRECT *) &( Events.msg[4] ), NULL, DialogTree, ICONIFY_ICON, Global );
									IconifyWindow( MT_wdlg_get_handle( IconifyDialog, Global ));
									break;
								}
/* THR_EXIT -------------------------------------------------------------------*/
								case	THR_EXIT:
								{
									delThreadInfoGemFtp( Events.msg[3], Global );
									MT_menu_bar( TreeAddr[MENUE], MENU_SHOW, Global );
									ThreadExitFlag = 1;
#ifdef	V110
									if( !existThreadInfoGemFtp() && IConnectStarted && ( IConnect & ICONNECT_DISCONNECT_LAST_SESSION ))
									{
										WORD IConnectAppId;
										if(( IConnectAppId = MT_appl_find( "ICONNECT", Global )) != -1 )
										{
											Msg[0] = ICON_MSG;
											Msg[1] = AppId;
											Msg[2] = 0;
											Msg[3] = ICM_SHUTDOWN_REQUEST;
											Msg[4] = 0;
											Msg[5] = 0;
											Msg[6] = 0;
											Msg[7] = -1234;
											MT_appl_write( IConnectAppId, 16, Msg, Global );
										}
										IConnectStarted = 0;
									}
#endif
									break;
								}
								
								case	Fsel_Msg:
								{
									GRECT		Rect;
									OBJECT	*DialogTree;
									if( Events.msg[3] == Fsel_Open && Events.msg[4] == Fsel_Conf_Rx )
									{
										MT_wdlg_get_tree( Conf1Dialog, &DialogTree, &Rect, Global );
										strcpy( FselPath, DialogTree[CONF1_RX].ob_spec.tedinfo->te_ptext );
										strcpy( FselFile, "" );
										FselStatus = Fsel_Conf_Rx;
										if( FileSelectorFlag )
											FselDialog = ( void * ) MT_fsel_exinput( FselPath, FselFile, &FselButton, FstringAddr[FS_TITLE_RX], Global );
										else
											FselDialog = WindowFileselector( 0, FstringAddr[FS_TITLE_RX], FselPath, FselFile, &FselHandle, Global );
										break;
									}
									if( Events.msg[3] == Fsel_Open && Events.msg[4] == Fsel_Conf_Tx )
									{
										MT_wdlg_get_tree( Conf1Dialog, &DialogTree, &Rect, Global );
										strcpy( FselPath, DialogTree[CONF1_TX].ob_spec.tedinfo->te_ptext );
										strcpy( FselFile, "" );
										FselStatus = Fsel_Conf_Tx;
										if( FileSelectorFlag )
											FselDialog = ( void * ) MT_fsel_exinput( FselPath, FselFile, &FselButton, FstringAddr[FS_TITLE_TX], Global );
										else
											FselDialog = WindowFileselector( 0, FstringAddr[FS_TITLE_TX], FselPath, FselFile, &FselHandle, Global );
										break;
									}
									if( Events.msg[3] == Fsel_Open && Events.msg[4] == Fsel_Conf_Log )
									{
										MT_wdlg_get_tree( Conf1Dialog, &DialogTree, &Rect, Global );
										strcpy( FselPath, DialogTree[CONF1_LOG].ob_spec.tedinfo->te_ptext );
										strcpy( FselFile, "" );
										FselStatus = Fsel_Conf_Log;
										if( FileSelectorFlag )
											FselDialog = ( void * ) MT_fsel_exinput( FselPath, FselFile, &FselButton, FstringAddr[FS_TITLE_LOG], Global );
										else
											FselDialog = WindowFileselector( 0, FstringAddr[FS_TITLE_LOG], FselPath, FselFile, &FselHandle, Global );
										break;
									}
								}
								case	Main_Shutdown:
									if( !( TreeAddr[MENUE][MENUE_SESSION].ob_state & DISABLED ))
									{
										MT_menu_ienable( TreeAddr[MENUE], MENUE_SESSION, 0, Global );
										MT_menu_ienable( TreeAddr[MENUE], MENUE_WORK, 0, Global );
										MT_menu_ienable( TreeAddr[MENUE], MENUE_WINDOW, 0, Global );
										MT_menu_ienable( TreeAddr[MENUE], MENUE_PARA, 0, Global );
										MT_menu_ienable( TreeAddr[MENUE], MENUE_INFO, 0, Global );
										MT_menu_bar( TreeAddr[MENUE], 1, Global );
									}
									if( existThreadInfoGemFtp())
									{
										if( ThreadExitFlag )
										{
											Msg[0] = GemFtp_Shutdown;
											Msg[1] = GetThreadAppId( 0, Global );
											Msg[2] = 0;
											MT_appl_write( GetThreadAppId( 0, Global ), 16, Msg, Global );
											ThreadExitFlag = 0;
										}
										Msg[0] = Main_Shutdown;
										Msg[1] = AppId;
										Msg[2] = 0;
										MT_appl_write( AppId, 16, Msg, Global );
										break;
									}
									if( AboutDialog )
									{
										Msg[0] = WM_CLOSED;
										Msg[1] = AppId;
										Msg[2] = 0;
										Msg[3] = MT_wdlg_get_handle( AboutDialog, Global );
										MT_appl_write( AppId, 16, Msg, Global );
										Msg[0] = Main_Shutdown;
										Msg[2] = 0;
										Msg[1] = AppId;
										MT_appl_write( AppId, 16, Msg, Global );
										break;
									}
									if( DoubleHtDialog )
									{
										Msg[0] = WM_CLOSED;
										Msg[1] = AppId;
										Msg[2] = 0;
										Msg[3] = MT_wdlg_get_handle( DoubleHtDialog, Global );
										MT_appl_write( AppId, 16, Msg, Global );
										Msg[0] = Main_Shutdown;
										Msg[2] = 0;
										Msg[1] = AppId;
										MT_appl_write( AppId, 16, Msg, Global );
										break;
									}
									if( NoFtpUrlDialog )
									{
										Msg[0] = WM_CLOSED;
										Msg[1] = AppId;
										Msg[2] = 0;
										Msg[3] = MT_wdlg_get_handle( NoFtpUrlDialog, Global );
										MT_appl_write( AppId, 16, Msg, Global );
										Msg[0] = Main_Shutdown;
										Msg[2] = 0;
										Msg[1] = AppId;
										MT_appl_write( AppId, 16, Msg, Global );
										break;
									}
									if( DragDropFailedDialog )
									{
										Msg[0] = WM_CLOSED;
										Msg[1] = AppId;
										Msg[2] = 0;
										Msg[3] = MT_wdlg_get_handle( DragDropFailedDialog, Global );
										MT_appl_write( AppId, 16, Msg, Global );
										Msg[0] = Main_Shutdown;
										Msg[2] = 0;
										Msg[1] = AppId;
										MT_appl_write( AppId, 16, Msg, Global );
										break;
									}
									if( NewSessionDialog )
									{
										Msg[0] = WM_CLOSED;
										Msg[1] = AppId;
										Msg[2] = 0;
										Msg[3] = MT_wdlg_get_handle( NewSessionDialog, Global );
										MT_appl_write( AppId, 16, Msg, Global );
										Msg[0] = Main_Shutdown;
										Msg[1] = AppId;
										Msg[2] = 0;
										MT_appl_write( AppId, 16, Msg, Global );
										break;
									}
									if( HotlistDialog )
									{
										Msg[0] = WM_CLOSED;
										Msg[1] = AppId;
										Msg[2] = 0;
										Msg[3] = MT_wdlg_get_handle( HotlistDialog, Global );
										MT_appl_write( AppId, 16, Msg, Global );
										Msg[0] = Main_Shutdown;
										Msg[1] = AppId;
										Msg[2] = 0;
										MT_appl_write( AppId, 16, Msg, Global );
										break;
									}
									if( SuffixDialog )
									{
										Msg[0] = WM_CLOSED;
										Msg[1] = AppId;
										Msg[2] = 0;
										Msg[3] = MT_wdlg_get_handle( SuffixDialog, Global );
										MT_appl_write( AppId, 16, Msg, Global );
										Msg[0] = Main_Shutdown;
										Msg[1] = AppId;
										Msg[2] = 0;
										MT_appl_write( AppId, 16, Msg, Global );
										break;
									}
									if( Conf1Dialog )
									{
										Msg[0] = WM_CLOSED;
										Msg[1] = AppId;
										Msg[2] = 0;
										Msg[3] = MT_wdlg_get_handle( Conf1Dialog, Global );
										MT_appl_write( AppId, 16, Msg, Global );
										Msg[0] = Main_Shutdown;
										Msg[1] = AppId;
										Msg[2] = 0;
										MT_appl_write( AppId, 16, Msg, Global );
										break;
									}
									if( Conf2Dialog )
									{
										Msg[0] = WM_CLOSED;
										Msg[1] = AppId;
										Msg[2] = 0;
										Msg[3] = MT_wdlg_get_handle( Conf2Dialog, Global );
										MT_appl_write( AppId, 16, Msg, Global );
										Msg[0] = Main_Shutdown;
										Msg[1] = AppId;
										Msg[2] = 0;
										MT_appl_write( AppId, 16, Msg, Global );
										break;
									}
									if( WindowAlertDialog )
									{
										Msg[0] = WM_CLOSED;
										Msg[1] = AppId;
										Msg[2] = 0;
										Msg[3] = MT_wdlg_get_handle( WindowAlertDialog, Global );
										MT_appl_write( AppId, 16, Msg, Global );
										Msg[0] = Main_Shutdown;
										Msg[1] = AppId;
										Msg[2] = 0;
										MT_appl_write( AppId, 16, Msg, Global );
										break;
									}
									if( IconifyDialog )
									{
										Msg[0] = WM_CLOSED;
										Msg[1] = AppId;
										Msg[2] = 0;
										Msg[3] = MT_wdlg_get_handle( IconifyDialog, Global );
										MT_appl_write( AppId, 16, Msg, Global );
										Msg[0] = Main_Shutdown;
										Msg[1] = AppId;
										Msg[2] = 0;
										MT_appl_write( AppId, 16, Msg, Global );
										break;
									}
#ifdef	V110
									if( IConnectStarted && ( IConnect & ICONNECT_DISCONNECT ))
									{
										WORD IConnectAppId;
										if(( IConnectAppId = MT_appl_find( "ICONNECT", Global )) != -1 )
										{
											Msg[0] = ICON_MSG;
											Msg[1] = AppId;
											Msg[2] = 0;
										   Msg[3] = ICM_SHUTDOWN_REQUEST;
											Msg[4] = 0;
											Msg[5] = 0;
											Msg[6] = 0;
											Msg[7] = -1234;
											MT_appl_write( IConnectAppId, 16, Msg, Global );
										}
									}
#endif
									if( ConfFlag & SaveConf )
										if( !WriteConfig())
											MT_form_alert( 1, FstringAddr[ERR_SAVE_CONF], Global );
									Quit = 0;
									break;
								case	Main_Top:
									break;
								case	Main_UpdateMenu:
#if	defined( KEY ) || defined( V110 )
									if( HotlistDialog && Events.msg[1] != AppId )
										UpdateHotlistDialog( HotlistDialog );
#endif
#ifdef	V120
									CreatePopupTree( &HotlistPopupTree, nHotlist, HotlistName );
									CreateSubmenuTree( &HotlistSubmenuTree, nHotlist, HotlistName );
#else
									CreatePopupTree( &HotlistPopupTree, nHotlist, HotlistHost );
									CreateSubmenuTree( &HotlistSubmenuTree, nHotlist, HotlistHost );
#endif
									InstalMenuBar();
									break;
								case	DragDropUrl:
									if( DDUrl( Events.msg[3], Events.msg[4], Events.msg[5], *(BYTE **) &( Events.msg[6] ), Global ) != E_OK )
									{
										if( !DragDropFailedDialog	)
											DragDropFailedDialog = OpenDialog( TreeAddr[DDF], "[Fiffi] Drag&Drop", HandleDragDropFailedDialog, Global, Global );
										else
										{
											Msg[0] = WM_TOPPED;
											Msg[1] = AppId;
											Msg[2] = 0;
											Msg[3] = MT_wdlg_get_handle( DragDropFailedDialog, Global );
											MT_appl_write( AppId, 16, Msg, Global );
										}
									}
									free( *(BYTE **) &( Msg[6] ));
									break;

								case	MN_SELECTED:
								{
									if(( OBJECT * ) *(LONG *) &(Events.msg[5]) != NULL && ( OBJECT * ) *(LONG *) &(Events.msg[5]) != TreeAddr[MENUE] )
									{
										if( (OBJECT *) *(LONG *) &(Events.msg[5]) == HotlistSubmenuTree )
										{
											if( newGemFtp( MakeFtpUrl( HotlistHost[Events.msg[4]-1], 
											                            HotlistPort[Events.msg[4]-1],
											                            HotlistUid[Events.msg[4]-1], 
											                            HotlistPwd[Events.msg[4]-1],
											                            HotlistDir[Events.msg[4]-1] ), Global ) <= 0 )
												MT_form_alert( 1, FstringAddr[THREAD_FAILED], Global );
											(OBJECT *) *(LONG *) &(Events.msg[5]) = TreeAddr[MENUE];
										}
									}
									else
									{									
										switch( Events.msg[4] )
										{
											case	MENUE_INFO:
												if( !AboutDialog )
													AboutDialog = OpenDialog( TreeAddr[ABOUT], FstringAddr[ABOUT_TITLE], HandleAboutDialog, Global, Global );
												else
												{
													Msg[0] = WM_TOPPED;
													Msg[1] = AppId;
													Msg[2] = 0;
													Msg[3] = MT_wdlg_get_handle( AboutDialog, Global );
													MT_appl_write( AppId, 16, Msg, Global );
												}
												break;
											
											case	MENUE_QUIT:
												if( existThreadInfoGemFtp())
												{
													if( !WindowAlertDialog )
													{
				 										WindowAlertDialog = WindowAlert( FstringAddr[WIN_NAME], FstringAddr[SHUTDOWN_MAIN], 1, Global );
				 										AlertStatus = Main_Shutdown;
				 									}
													else
														MT_wind_set( MT_wdlg_get_handle( WindowAlertDialog, Global ), WF_TOP, 0, 0, 0, 0, Global );
												}
												else
												{
													Msg[0] = Main_Shutdown;
													Msg[1] = AppId;
													Msg[2] = 0;
													MT_appl_write( AppId, 16, Msg, Global );
												}
												break;
	
											case	MENUE_OPEN_SES:
											{
												MENU	Popup;
												EVNTDATA Ev;
												WORD	a1, a2, a3, a4;
												if(( AesFlags & GAI_INFO ) && MT_appl_getinfo( 9, &a1, &a2, &a3, &a4, Global ) && a2 )
												{
													Popup.mn_tree = HotlistPopupTree;
													Popup.mn_menu = 0;
													Popup.mn_item = 0;
													Popup.mn_scroll = 1;
													Popup.mn_keystate = 0;
													MT_graf_mkstate( &Ev, Global );
	
													if( HotlistPopupTree )
													{
														MT_menu_popup( &Popup, Ev.x, Ev.y, &Popup, Global );
														if( Popup.mn_item > 0 )
														{
															if( newGemFtp( MakeFtpUrl( HotlistHost[Popup.mn_item-1], 
															                            HotlistPort[Popup.mn_item-1],
															                            HotlistUid[Popup.mn_item-1], 
											   				                         HotlistPwd[Popup.mn_item-1],
											               				             HotlistDir[Popup.mn_item-1] ), Global ) <= 0 )
																MT_form_alert( 1, FstringAddr[THREAD_FAILED], Global );										
														}
													}
													break;
												}
											}
											case	MENUE_NEW_SES:
											{
												if( !NewSessionDialog )
													NewSessionDialog = OpenDialog( TreeAddr[NS], FstringAddr[NS_TITLE], HandleNewSessionDialog, Global, Global );
												else
												{
													Msg[0] = WM_TOPPED;
													Msg[1] = AppId;
													Msg[2] = 0;
													Msg[3] = MT_wdlg_get_handle( NewSessionDialog, Global );
													MT_appl_write( AppId, 16, Msg, Global );
												}
												break;
											}
											case	MENUE_CLOSE_SES:
											{
												WORD	w1, w2, w3, w4;
												MT_wind_get( 0, WF_TOP, &w1, &w2, &w3, &w4, Global );
												Msg[0] = AP_TERM;
												Msg[1] = AppId;
												Msg[2] = 0;
												MT_appl_write( w2, 16, Msg, Global );
												break;
											}
										
											case	MENUE_SUFFIX:
											{
												if( !SuffixDialog )
													SuffixDialog = OpenDialog( TreeAddr[SUFFIX], FstringAddr[SUFFIX_TITLE], HandleSuffixDialog, Global, Global );
												else
												{
													Msg[0] = WM_TOPPED;
													Msg[1] = AppId;
													Msg[2] = 0;
													Msg[3] = MT_wdlg_get_handle( SuffixDialog, Global );
													MT_appl_write( AppId, 16, Msg, Global );
												}
												break;
											}

											case	MENUE_HOTLIST:
											{
												if( !HotlistDialog )
													HotlistDialog = OpenDialog( TreeAddr[HT], FstringAddr[HT_TITLE], HandleHotlistDialog, Global, Global );
												else
												{
													Msg[0] = WM_TOPPED;
													Msg[1] = AppId;
													Msg[2] = 0;
													Msg[3] = MT_wdlg_get_handle( HotlistDialog, Global );
													MT_appl_write( AppId, 16, Msg, Global );
												}
												break;
											}
											
											case	MENUE_CONF1:
											{
												if( !Conf1Dialog )
													Conf1Dialog = OpenDialog( TreeAddr[CONF1], FstringAddr[CONF1_TITLE], HandleConf1Dialog, Global, Global );
												else
												{
													Msg[0] = WM_TOPPED;
													Msg[1] = AppId;
													Msg[2] = 0;
													Msg[3] = MT_wdlg_get_handle( Conf1Dialog, Global );
													MT_appl_write( AppId, 16, Msg, Global );
												}
												break;
											}
											case	MENUE_CONF2:
											{
												if( !Conf2Dialog )
													Conf2Dialog = OpenDialog( TreeAddr[CONF2], FstringAddr[CONF2_TITLE], HandleConf2Dialog, Global, Global );
												else
												{
													Msg[0] = WM_TOPPED;
													Msg[1] = AppId;
													Msg[2] = 0;
													Msg[3] = MT_wdlg_get_handle( Conf2Dialog, Global );
													MT_appl_write( AppId, 16, Msg, Global );
												}
												break;
											}

											case	MENUE_SAVE_CONF:
											{
												if( !WriteConfig())
													MT_form_alert( 1, FstringAddr[ERR_SAVE_CONF], Global );
												break;
											}
											case	MENUE_CLS_W:
											{
												WORD	Msg[16], W, A, dummy;
												MT_wind_get( 0, WF_TOP, &W, &A, &dummy, &dummy, Global );
												Msg[0] = WM_CLOSED;
												Msg[1] = AppId;
												Msg[2] = 0;
												Msg[3] = W;												
												MT_appl_write( A, 16, Msg, Global );
												break;
											}
											case	MENUE_CYC_W:
											{
												WORD	w1, w2, w3, w4;
												MT_wind_get( 0, WF_TOP, &w1, &w2, &w3, &w4, Global );
												if( isWindow( w1 ))
												{
													if(( w1 = GetNextWindow( w1 )) == -1 )
														w1 = GetFirstWindow();
													while( isAllIconifiedWindow( w1 ))
													{
														if(( w1 = GetNextWindow( w1 )) == -1 )
															w1 = GetFirstWindow();
													}
												}
												else
													w1 = GetFirstWindow();
												MT_wind_set( w1, WF_TOP, 0, 0, 0, 0, Global );
											break;
											}
											case	MENUE_CLS_ALL:
												Msg[3] = GetFirstWindow();
												if( Msg[3] != -1 )
												{
													Msg[0] = WM_CLOSED;
													Msg[1] = AppId;
													Msg[2] = 0;
													do
													{
														MT_appl_write( GetAppIdWindow( Msg[3] ), 16, Msg, Global );
														Msg[3] = GetNextWindow( Msg[3] );
													}
													while( Msg[3] != -1 );
												}
												break;					
											default:
											{
												MT_form_alert( 1, "[3][MenÅ!][Cancel]", Global );
											}
										}
									}
									MT_menu_tnormal(( OBJECT * ) *(LONG *) &(Events.msg[5]), Events.msg[3], 1, Global );
									break;
								}
/*								default:
									printf("Evnt[0] = %x  Evnt[1] = %i\n", Events.msg[0], Events.msg[1] );	*/
							}
						}
					}
					if( AvAppId >= 0) 
						AvExit( AvAppId, Global );
				}
				else
				{
					MT_graf_mouse( M_RESTORE, NULL, Global );
					MT_form_alert( 1, FstringAddr[WDLG_MISSING], Global );
				}
				StIc_Del( AppId );
				MT_rsrc_free( Global );
 			}
			else
			{
				MT_graf_mouse( M_RESTORE, NULL, Global );
				MT_form_alert( 1, "[3][Error: Can't load rsc!][Cancel]", Global );
			}
			v_clsvwk ( VdiHandle );
		}
		else
			MT_form_alert( 1, "[3][Error: OpenScreenWk()][Cancel]", Global );
		
/*		MT_appl_exit( Global );	*/
	}
	else
	{
		Con( "Error: No AES" ); crlf;
	}
	return (RetCode);
}

#ifdef DEBUG
void	WriteDebugMsg( FILE *DebugHandle, BYTE *Arg, va_list ap )
{
	BYTE	Puf[512];
	vsprintf( Puf, Arg, ap);
	if( DebugHandle )
		fwrite( Puf, sizeof( char ), strlen( Puf ), DebugHandle );
}
void	DebugMsg( WORD Global[15], BYTE *Arg, ... )
{
	while( DebugSemaphore )
		MT_appl_yield( Global );
	DebugSemaphore = 1;
	{
		va_list	ap;
		FILE	*DebugHandle = NULL;
		va_start( ap, Arg );
		DebugHandle = fopen( "Fiffi.log", "a+" );

		if( DebugHandle )
			WriteDebugMsg( DebugHandle, Arg, ap );
		if( DebugHandle )
			fclose( DebugHandle );
	}
	DebugSemaphore = 0;
}
#endif