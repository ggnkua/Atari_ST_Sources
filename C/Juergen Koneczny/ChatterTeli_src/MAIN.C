#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include <STDDEF.H>
#include <STDLIB.H>
#include <STDIO.H>
#include	<STRING.H>
#include	<TIME.H>

#include	<av.h>
#include	<atarierr.h>
#ifdef	IRC_CLIENT
#include	<slb.h>
#endif

#include	"main.h"
#include	RSCHEADER
#include	"Config.h"
#include	"Help.h"
#include	"IConnect.h"
#include	"Menu.h"
#ifdef	IRC_CLIENT
#include	"SmIcons.h"
#endif
#ifdef	TELNET_CLIENT
#include	"Telnet.h"
#endif
#include	"WDialog.h"
#include	"Window.h"

#include "AdaptRsc.h"
#include	"KEYTAB.h"

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	SaveFlag;

/*-----------------------------------------------------------------------------*/
/* Globale Variablen                                                           */
/*-----------------------------------------------------------------------------*/
WORD		Global[15];
WORD		AppId, AesHandle, VdiHandle, AvAppId;
WORD		ModWinId = 0;
OBJECT	**TreeAddr;
BYTE		**FstringAddr;
WORD		AesFlags, AesFont, AesHeight;
WORD		PwChar, PhChar, PwBox, PhBox;
WORD		WorkOut[57];
ULONG		ScreenColors;
GRECT		ScreenRect;
WORD		nFont = 0;
WORD		SessionCounter = 0;

WORD		VqExtnd[48];
int		EdDI = 0;

KEYT		*Keytab;
OBJECT	*KeyExportPopup, *KeyImportPopup;

#ifdef	IRC_CLIENT
WORD		KeytabAnsiExport, KeytabAnsiImport;
WORD		SmIcons_Support = -1;
#endif

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
static int	GemdosVersion;
static WORD	Quit = 0;

#ifdef	IRC_CLIENT
#endif

#ifdef	DEBUG
static int 	DebugSemaphore = 0;
#endif


/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static void	InitRsrc( OBJECT ***TreeAddr, BYTE ***FstringAddr, WORD Global[15] );
static void	SetShortcut( OBJECT *Tree );
static void	SetIcon( OBJECT *Tree, WORD Index );
static void	SetSliderBorders( OBJECT **TreeAddr );
static int	GetGemdosVersion( void );
static WORD	AV_Init( BYTE *AppName, WORD Global[15] );
static WORD	MakeKeyPopup( KEYT *Keytab, OBJECT *KeyPopup, OBJECT **KeyExportPopup, OBJECT **KeyImportPopup );
static WORD	CheckEdDI( void );
static void StIc_Init( WORD AppId, OBJECT *Big, OBJECT *Small );
static void	StIc_Del( WORD AppId );
void CloseQuitAlert( void *UserData, WORD Button, WORD WinId, WORD Global[15] );	

void	*Xmalloc( long Len, int Mode)
{
	if( GemdosVersion < 0x0019 || Mode == RAM_MALLOC )
		return Malloc( Len );
	return Mxalloc( Len, Mode );
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

static int	GetGemdosVersion( void )
{
	unsigned int version = Sversion();
	return (int)(((version << 8) & 0xFF00) | ((version >> 8) & 0x00FF));
}

static WORD	CheckEdDI( void )
{
	typedef	int( *eddi )( int );
	eddi	func = SearchCookie( 'EdDI' );
	if( func )
		return( func( 0 ));
	else
		return( 0 );
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
/* Virtuelle Bildschirm-Workstation ”ffnen                                     */
/* Funktionsresultat: VDI-Handle oder 0 als Fehlernummer                       */
/* WorkOut: Ger„teinformationen                                                */
/*-----------------------------------------------------------------------------*/
WORD	OpenScreenWk( WORD AesHandle, WORD *WorkOut )
{
	WORD	WorkIn[11], Handle, i;
	for( i = 1; i < 10; i++ )
		WorkIn[i] = 1;
	WorkIn[0] = 1;
/*	WorkIn[0] = Getrez() + 2;*/
	WorkIn[10] = 2;
	Handle = AesHandle;
	v_opnvwk( WorkIn, &Handle, WorkOut );
	return( Handle );
}

int16	OpenBitmap( WORD Width, WORD Height, WORD AesHandle, MFDB *Bitmap )
{
	int16	WorkIn[20], Handle, i;
	for( i = 1; i < 10; i++ )
		WorkIn[i] = 1;
	WorkIn[0] = 1;
	WorkIn[10] = 2;
	if(( Width / 16 ) * 16 != Width )
		Width = (( Width + 16 ) / 16 ) * 16;
	WorkIn[11] = Width - 1;
	WorkIn[12] = Height - 1;
	WorkIn[13] = WorkOut[3];
	WorkIn[14] = WorkOut[4];
	for( i = 15; i < 20; i++ )
		WorkIn[i] = 0;
	Handle = AesHandle;
	Bitmap->fd_addr = NULL;
	Bitmap->fd_nplanes = 0;
	{
		int16	WorkOut[57];
		v_opnbm( WorkIn, Bitmap, &Handle, WorkOut );
	}
	return( Handle );
}

/*-----------------------------------------------------------------------------*/
/* Resource und dazugeh”rige Strukturen initalisieren                          */
/* Funktionsergebnis: -                                                        */
/*-----------------------------------------------------------------------------*/
static void	InitRsrc( OBJECT ***TreeAddr, BYTE ***FstringAddr, WORD Global[15] )
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
	AesFlags = get_aes_info( &AesFont, &AesHeight, &Hor3d, &Ver3d );

#ifdef	TELNET_CLIENT
	Tree = (*TreeAddr)[POPUP_TEXT];
	SetShortcut( Tree );
#endif

	if( AesFlags & GAI_3D )
		adapt3d_rsrc( Objs, NoObjs, Hor3d, Ver3d );
	else
	{
		no3d_rsrc( Objs, NoObjs, 1 );
/*		SetSliderBorders( *TreeAddr );	*/
	}

	if(( AesFlags & GAI_MAGIC ) == 0 )
	{
/*		SetSliderBorders( *TreeAddr );	*/
	}
	else
		substitute_objects( Objs, NoObjs, AesFlags, 0L, 0L );
}
static void	SetIcon( OBJECT *Tree, WORD Index )
{
	Tree[Index].ob_spec.ciconblk->monoblk.ib_xtext = 8;
	Tree[Index].ob_spec.ciconblk->monoblk.ib_ytext = 8;
	Tree[Index].ob_spec.ciconblk->monoblk.ib_wtext = 0;
	Tree[Index].ob_spec.ciconblk->monoblk.ib_htext = 0;
}
static void	SetShortcut( OBJECT *Tree )
{
	WORD	i = Tree[0].ob_head, j;
	while( 1 )
	{
		if(( Tree[i].ob_type & 0xff ) == G_STRING )
		{
			j = Tree[i].ob_type & 0xff00;
			Tree[i].ob_type = j + G_SHORTCUT;
		}
		if( Tree[i].ob_flags & LASTOB )
			break;
		i = Tree[i].ob_next;
	}
}

/*----------------------------------------------------------------------------------------*/ 
/* R„nder der Slider-Objekte auf 1 Pixel setzen															*/
/* Funktionsergebnis:	-																						*/
/*----------------------------------------------------------------------------------------*/ 
static void	SetSliderBorders( OBJECT **TreeAddr )
{
	OBJECT	*Tree;
	Tree = TreeAddr[HOTLIST];
	Tree[HOTLIST_ENTRY_BACK_V].ob_spec.obspec.framesize = 1;
	Tree[HOTLIST_ENTRY_SL_V].ob_spec.obspec.framesize = 1;
	Tree[HOTLIST_ENTRY_UP].ob_spec.obspec.framesize = 1;
	Tree[HOTLIST_ENTRY_DOWN].ob_spec.obspec.framesize = 1;
	Tree[HOTLIST_ENTRY_BACK_H].ob_spec.obspec.framesize = 1;
	Tree[HOTLIST_ENTRY_SL_H].ob_spec.obspec.framesize = 1;
	Tree[HOTLIST_ENTRY_LEFT].ob_spec.obspec.framesize = 1;
	Tree[HOTLIST_ENTRY_RIGHT].ob_spec.obspec.framesize = 1;
}

static WORD	AV_Init( BYTE *AppName, WORD Global[15] )
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

static WORD	MakeKeyPopup( KEYT *Keytab, OBJECT *KeyPopup, OBJECT **KeyExportPopup, OBJECT **KeyImportPopup )
{
	OBJECT	*Popup;
	int	nExport = Keytab->GetExportCount(), nImport = Keytab->GetExportCount(), i;

	Popup = malloc( sizeof( OBJECT )  * ( nExport + 1  + 1 ));
	if( !Popup )
		return( ERROR );
	memcpy( Popup, KeyPopup, sizeof( OBJECT ));
	Popup[0].ob_next = -1;
	Popup[0].ob_head = 1;
	Popup[0].ob_tail = nExport + 1;
	Popup[0].ob_height = ( nExport + 1 ) * PhChar;
	for( i = 0; i <= nExport; i++ )
	{
		memcpy( &( Popup[i+1] ), &( KeyPopup[1] ), sizeof( OBJECT ));
		Popup[i+1].ob_next = i+2;
		Popup[i+1].ob_head = -1;
		Popup[i+1].ob_tail = -1;
		Popup[i+1].ob_y = i * PhChar;
		Popup[i+1].ob_spec.free_string = strdup( KeyPopup[1].ob_spec.free_string );
		if( !Popup[i+1].ob_spec.free_string )
			return( ERROR );
		memcpy( &(( Popup[i+1].ob_spec.free_string )[2] ), Keytab->GetExportShortName( i ), strlen( Keytab->GetExportShortName( i )));
	}
	Popup[i].ob_next = 0;
	*KeyExportPopup = Popup;


	Popup = malloc( sizeof( OBJECT )  * ( nExport + 1  + 1 ));
	if( !Popup )
		return( ERROR );

	memcpy( Popup, KeyPopup, sizeof( OBJECT ));
	Popup[0].ob_next = -1;
	Popup[0].ob_head = 1;
	Popup[0].ob_tail = nImport + 1;
	Popup[0].ob_height = ( nImport + 1 ) * PhChar;
	for( i = 0; i <= nImport; i++ )
	{
		memcpy( &( Popup[i+1] ), &( KeyPopup[1] ), sizeof( OBJECT ));
		Popup[i+1].ob_next = i+2;
		Popup[i+1].ob_head = -1;
		Popup[i+1].ob_tail = -1;
		Popup[i+1].ob_y = i * PhChar;
		Popup[i+1].ob_spec.free_string = strdup( KeyPopup[1].ob_spec.free_string );
		if( !Popup[i+1].ob_spec.free_string )
			return( ERROR );
		memcpy( &(( Popup[i+1].ob_spec.free_string )[2] ), Keytab->GetImportShortName( i ), strlen( Keytab->GetImportShortName( i )));
	}
	Popup[i].ob_next = 0;
	*KeyImportPopup = Popup;
	return( E_OK );
}

WORD	isMonospaceFont( WORD FontId )
{
	WORD	i, Width, ld, rd, w;
	vst_font( VdiHandle, FontId );

	vqt_width( VdiHandle, 32, &Width, &ld, &rd );
	for( i = 33; i < 127; i++ )
	{
		vqt_width( VdiHandle, i, &w, &ld, &rd );
		if( w != Width )
			return( 0 );
	}
	return( 1 );
}

void	SortXy( XY *A, XY *B )
{
	if( A->y > B->y || ( A->y == B->y && A->x > B->x ))
	{
		XY	Tmp;
		Tmp.x = A->x;
		Tmp.y = A->y;
		A->x = B->x;
		A->y = B->y;
		B->x = Tmp.x;
		B->y = Tmp.y;
	}
}
/*-----------------------------------------------------------------------------*/
/* Hauptprogramm                                                               */
/*-----------------------------------------------------------------------------*/
WORD	main( int ArgC, const char *ArgV[] )
{
	WORD	RetCode = 0;
#ifdef	MEMDEBUG
#ifdef	IRC_CLIENT
	set_MemdebugOptions( c_Yes, c_Yes, c_Yes, c_Yes, c_Yes, c_Yes, c_Yes, 0L, 0L, "C:\\var\\log\\Chatter-Debug\\statistics", "C:\\var\\log\\Chatter-Debug\\error" );
#endif
#ifdef	TELNET_CLIENT
	set_MemdebugOptions( c_Yes, c_Yes, c_Yes, c_Yes, c_Yes, c_Yes, c_Yes, 0L, 0L, "C:\\var\\log\\Teli-Debug\\statistics", "C:\\var\\log\\Teli-Debug\\error" );
#endif
#endif
	Pdomain( 1 );
	GemdosVersion = GetGemdosVersion();
#ifdef	DEBUG
	DebugMsg( Global, "Id = %s %s\n", APPNAME, VERSION );
#endif
	if(( AppId = MT_appl_init( Global )) != -1 )
	{
#ifdef	DEBUG
	DebugMsg( Global, "AppId = %i\n", AppId );
#endif
		AesHandle = MT_graf_handle( &PwChar, &PhChar, &PwBox, &PhBox, Global );
#ifdef	DEBUG
	DebugMsg( Global, "AesHandle = %i\n", AesHandle );
#endif
		if(( VdiHandle = OpenScreenWk( AesHandle, WorkOut )) > 0 )
		{
#ifdef	DEBUG
	DebugMsg( Global, "VdiHandle = %i\n", VdiHandle );
#endif
			MT_graf_mouse( M_SAVE, NULL, Global );
			MT_graf_mouse( BUSYBEE, NULL, Global );
			if( MT_rsrc_load( RSCNAME, Global ))
			{
#ifdef	IRC_CLIENT
				SHARED_LIB	EditObjSlb;
				SLB_EXEC	EditObjExec;
#endif			
				InitRsrc( &TreeAddr, &FstringAddr, Global );
#ifdef	IRC_CLIENT
				StIc_Init( AppId, &TreeAddr[ICONS][ICON_BIG], &TreeAddr[ICONS][ICON_SMALL] );
#endif
#ifdef	TELNET_CLIENT
				StIc_Init( AppId, &TreeAddr[TITLES][ICON_BIG], &TreeAddr[TITLES][ICON_SMALL] );
#endif
				MT_menu_bar( TreeAddr[MENUE], MENU_SHOW, Global );
#ifdef	DRACONIS
				MT_menu_ienable( TreeAddr[MENUE], MENUE_CONFIG_ICONNECT, 0, Global );
#endif

#ifdef	IRC_CLIENT
				if( Slbopen( "EDITOBJC.SLB", NULL, 0L, &EditObjSlb, &EditObjExec ) >= 0 )
#endif
#ifdef	TELNET_CLIENT
				if( 1 == 1 )
#endif
				{
					if(( EdDI = CheckEdDI()) != 0 )
					{
						WORD	ScreenOut[271];
						vq_extnd( VdiHandle, 1, VqExtnd );
						vq_scrninfo( VdiHandle, ScreenOut );
						ScreenColors = ScreenOut[3]; ScreenColors = ScreenColors << 16; ScreenColors += ScreenOut[4];
						if(( Keytab = ( KEYT * ) SearchCookie( 'KEYT' )) != NULL && Keytab->magic == 'KEYT' && Keytab->size >= 64 )
						{
#ifdef	IRC_CLIENT
							KeytabAnsiExport = Keytab->GetExportFilter( KEYTAB_ID_ANSI );
							KeytabAnsiImport = Keytab->GetImportFilter( KEYTAB_ID_ANSI );
#endif
#ifdef	TELNET_CLIENT
							MakeKeyPopup( Keytab, TreeAddr[POPUP_KEY], &KeyExportPopup, &KeyImportPopup );
#endif
							if(( AesFlags & ( GAI_WDLG + GAI_LBOX )) == ( GAI_WDLG + GAI_LBOX ))
							{
								EVNT		Events;
								WORD		LastClosedWinId = -1;
	
								nFont = WorkOut[10];
								MT_wind_get_grect( 0, WF_WORKXYWH, &ScreenRect, Global );
								if( vq_gdos())
									nFont += vst_load_fonts( VdiHandle, 0 );

								ReadConfig();
#ifdef	IRC_CLIENT
								SmIcons_Init( TreeAddr[SMICONS] );
#endif
#ifdef	DEBUG
	DebugMsg( Global, "Help_Init()\n" );
#endif
							Help_Init();
#ifdef	DEBUG
	DebugMsg( Global, "AV_Init()\n" );
#endif
								AvAppId = AV_Init( PRGNAME, Global );

								MT_shel_write( SHW_INFRECGN, 1, 0, 0L, 0L, Global );
								MT_graf_mouse( ARROW, NULL, Global );

								if( ArgC > 1 )
								{
#ifdef	TELNET_CLIENT
									TELNET *Telnet;
									if( strnicmp(( BYTE * ) ArgV[1], "telnet:", 7 ) == 0 && ( Telnet = Url2Telnet(( BYTE * ) ArgV[1] )) != NULL )
										OpenTelnet( Telnet, Global );
									else
									{
										MT_form_alert( 1, TreeAddr[ALERTS][NO_TELNET_URL].ob_spec.free_string, Global );
										Quit = 1;
									}
#endif
								}

								RetCode = 0;
								while( Quit != 1 )
								{
									KontextMenu();
	
									MT_EVNT_multi( MU_KEYBD + MU_BUTTON + MU_MESAG + MU_TIMER, 0x102, 3, 0, 0L, 0L, 500, &Events, Global );

#ifdef	MEMDEBUG
									if( Events.mwhich & MU_KEYBD )
										if( Events.key == 8196 )
											print_MemdebugStatistics();
#endif
									HandleIConnect( &Events, Global );
									HandleWindow( &Events, Global );

									if( Events.mwhich & MU_KEYBD )
									{
										if( !Quit )
											Quit = KeyEvent( Events.key );
									}
									if( Events.mwhich & MU_MESAG )
									{
										switch( Events.msg[0] )
										{
											case	BUBBLEGEM_ACK:
												if( *( BYTE ** )&( Events.msg[5] ))
													Mfree( *( BYTE ** )&( Events.msg[5] ));
												break;
											case	VA_START:
											{
												WORD		Msg[8];
#ifdef	TELNET_CLIENT
												if( *( BYTE **)&( Events.msg[3] ) && strlen( *( BYTE **)&( Events.msg[3] )))
												{
													TELNET	*Telnet;
													if( strnicmp( *( BYTE **)&( Events.msg[3] ), "telnet:", 7 ) == 0 && ( Telnet = Url2Telnet( *( BYTE **)&( Events.msg[3] ))) != NULL )
														OpenTelnet( Telnet, Global );
													else
														MT_form_alert( 1, TreeAddr[ALERTS][NO_TELNET_URL].ob_spec.free_string, Global );
												}
												else
													MT_menu_bar( TreeAddr[MENUE], MENU_SHOW, Global );
												Msg[0] = AV_STARTED;
												Msg[1] = AppId;
												Msg[2] = 0;
												Msg[3] = Events.msg[3];
												Msg[4] = Events.msg[4];
												MT_appl_write( Events.msg[1], 16, Msg, Global );
#endif
												break;
											}
											case	AV_STARTED:
												if( *( BYTE ** )&( Events.msg[3] ))
													Mfree( *( BYTE ** )&( Events.msg[3] ));
												break;
											case	THR_EXIT:
											{
												EVNT	lEvent;
												lEvent.mwhich = MU_MESAG;
												lEvent.msg[0] = THR_EXIT;
												lEvent.msg[3] = ( WORD ) *( LONG ** ) &( Events.msg[4] );
												lEvent.msg[4] = Events.msg[3];
												HandleWindow( &lEvent, Global );
												break;
											}
/* AP_TERM --------------------------------------------------------------------*/
											case	AP_TERM:
												Quit = 1;
												break;
/* GEMScript ------------------------------------------------------------------*/
/* AP_DRAGDROP ----------------------------------------------------------------*/
/* MN_SELECTED ----------------------------------------------------------------*/
											case	MN_SELECTED:
												if( !Quit )
													Quit = HandleMenu( &Events );
												break;
										}
									}
									if( Quit )
									{
										if( !( TreeAddr[MENUE][MENUE_FILE_M].ob_state & DISABLED ))
										{
											MT_menu_ienable( TreeAddr[MENUE], MENUE_FILE_M, 0, Global );
											MT_menu_ienable( TreeAddr[MENUE], MENUE_WORK_M, 0, Global );
											MT_menu_ienable( TreeAddr[MENUE], MENUE_WINDOW_M, 0, Global );
											MT_menu_ienable( TreeAddr[MENUE], MENUE_CONFIG_M, 0, Global );
											MT_menu_ienable( TreeAddr[MENUE], MENUE_HELP_M, 0, Global );
											MT_menu_ienable( TreeAddr[MENUE], MENUE_ABOUT, 0, Global );
											MT_menu_bar( TreeAddr[MENUE], 1, Global );
#ifdef	IRC_CLIENT
#endif
										}
										if( Quit == 1 )
										{
											if( SessionCounter )
											{
												Quit = 2;
												ModWinId = AlertDialog( 1, TreeAddr[ALERTS][QUIT_APP].ob_spec.free_string, APPNAME, CloseQuitAlert, 0L, Global );
											}
											else
												Quit = 3;
										}
										if( Quit == 3 )
										{
											WORD	w = GetFirstWindow();
											while( w != -1 )
											{
												WORD	Type = GetTypeWindow( w );
												if( Type == WIN_UPDATE || Type == WIN_WDIALOG || Type == WIN_ALERT_WINDOW || Type == WIN_CHAT_IRC_CONSOLE || Type == WIN_CHAT_DCC || Type == WIN_DATA_DCC || Type == WIN_TEXT_WINDOW )
												{
													if( w != LastClosedWinId )
													{
														EVNT	lEvent;
														lEvent.mwhich = MU_MESAG;
														lEvent.msg[0] = WM_CLOSED;
														lEvent.msg[1] = Global[2];
														lEvent.msg[2] = 0;
														lEvent.msg[3] = w;
														lEvent.msg[4] = WIN_CLOSE_WITHOUT_DEMAND;
														HandleWindow( &lEvent, Global );
														LastClosedWinId = w;
													}
													break;
												}
												else
													w = GetNextWindow( w );
											}
										}
										if( Quit == 3 && GetFirstWindow() == -1 )
											Quit = 1;
									}
								}
	
								SessionCounter = -1;
								Events.mwhich = MU_MESAG;
								Events.msg[0] = ICONNECT_ACK;
								Events.msg[1] = AppId;
								Events.msg[2] = 0;
								Events.msg[3] = 0;
								HandleIConnect( &Events, Global );
								if( SaveFlag )
									WriteConfig( Global );
								if( vq_gdos())
									vst_unload_fonts( VdiHandle, 0 );
							}
							else
							{
								MT_graf_mouse( M_RESTORE, NULL, Global );
								MT_form_alert( 1, TreeAddr[ALERTS][WDLG_MISSING].ob_spec.free_string, Global );
							}
						}
						else
						{
							MT_graf_mouse( M_RESTORE, NULL, Global );
							MT_form_alert( 1, TreeAddr[ALERTS][KEYT_MISSING].ob_spec.free_string, Global );
						}
					}
					else
					{
						MT_graf_mouse( M_RESTORE, NULL, Global );
						MT_form_alert( 1, TreeAddr[ALERTS][EDDI_MISSING].ob_spec.free_string, Global );
					}
#ifdef	IRC_CLIENT
					Slbclose( EditObjSlb );
#endif
				}
				else
				{
#ifdef	IRC_CLIENT
					MT_graf_mouse( M_RESTORE, NULL, Global );
					MT_form_alert( 1, TreeAddr[ALERTS][SL_ERROR].ob_spec.free_string, Global );
#endif
				}
				StIc_Del( AppId );
				MT_rsrc_free( Global );
 			}
			else
				MT_form_alert( 1, "[3][Error: Can't load rsc!][Cancel]", Global );
			v_clsvwk( VdiHandle );
		}
		else
			MT_form_alert( 1, "[3][Error: OpenScreenWk()][Cancel]", Global );
		
		MT_appl_exit( Global );
	}
	else
	{
		Con( "Error: No AES" ); crlf;
	}
#ifdef	DEBUG
	DebugMsg( Global, "Exit()\n" );
#endif
	return (RetCode);
}

void CloseQuitAlert( void *UserData, WORD Button, WORD WinId, WORD Global[15] )
{
	ModWinId = 0;
	if( Button == 1 )
		Quit = 3;
	else
	{
		Quit = 0;
		MT_menu_ienable( TreeAddr[MENUE], MENUE_FILE_M, 1, Global );
		MT_menu_ienable( TreeAddr[MENUE], MENUE_WORK_M, 1, Global );
		MT_menu_ienable( TreeAddr[MENUE], MENUE_WINDOW_M, 1, Global );
		MT_menu_ienable( TreeAddr[MENUE], MENUE_CONFIG_M, 1, Global );
		MT_menu_ienable( TreeAddr[MENUE], MENUE_HELP_M, 1, Global );
		MT_menu_ienable( TreeAddr[MENUE], MENUE_ABOUT, 1, Global );
		MT_menu_bar( TreeAddr[MENUE], 1, Global );
	}
}

BYTE	*Decimal( ULONG Z, BYTE *Puf )
{
	BYTE	Str[10];
	WORD	Stellen, Punkte, i, j, k = 0;
	sprintf(Str, "%li", Z );
	Stellen = ( WORD )strlen( Str );
	Punkte = ( Stellen - 1 ) / 3;
	j = Stellen + Punkte;
	Puf[j + 1] = 0;
	for( i = Stellen; i >= 0; i-- )
	{
		if( k == 4 || k == 7 )
			Puf[j--] = '.';
		Puf[j--] = Str[i];
		k++;
	}
	return( Puf );
}


#ifdef	DEBUG
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
		DebugHandle = fopen( DEBUGNAME, "a+" );

		if( DebugHandle )
			WriteDebugMsg( DebugHandle, Arg, ap );
		if( DebugHandle )
			fclose( DebugHandle );
	}
	DebugSemaphore = 0;
}

#endif