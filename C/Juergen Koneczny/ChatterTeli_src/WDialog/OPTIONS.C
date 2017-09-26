#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<STDLIB.H>
#include  <STDDEF.H>
#include	<STRING.H>
#include	<stdio.h>

#include	<atarierr.h>

#include	"..\main.h"
#include	RSCHEADER
#include	"..\Dd.h"
#include	"..\Emulator.h"
#include	"..\Help.h"
#include	"..\Popup.h"
#include	"..\Rsc.h"
#ifdef	IRC_CLIENT
#include	"..\Irc.h"
#include	"..\ExtObj\ListObj.h"
#endif
#ifdef	TELNET_CLIENT
#include	"..\Telnet.h"
#endif
#include	"..\WDialog.h"
#include	"..\Window.h"

#include	"Options.h"

#include	"..\Edscroll.h"
#include	"..\KEYTAB.h"

/*-----------------------------------------------------------------------------*/
/* Externe Variablen                                                           */
/*-----------------------------------------------------------------------------*/
extern WORD	Global[15], VdiHandle;
extern OBJECT	**TreeAddr;
extern WORD	isScroll, nFont;
extern KEYT		*Keytab;
extern OBJECT	*KeyExportPopup, *KeyImportPopup;


/*-----------------------------------------------------------------------------*/
/* Funktionsprototypen                                                         */
/*-----------------------------------------------------------------------------*/
static void	SetEdit( DIALOG *Dialog, OPT_DATA *OptData, WORD Global[15] );
static WORD	cdecl ColorUbCode( PARMBLK *ParmBlock );
static void	GetFaceName( WORD FontId, LONG FontPt, WORD VdiHandle, BYTE *Puf );

#ifdef	IRC_CLIENT
static void	InsertOptions( OPT_DATA *OptData, IRC *Irc );
static void	InsertTelnetOptions( DIALOG *Dialog, OPT_DATA *OptData, IRC *Irc, WORD Global[15] );
static void	SetCSlider( OPT_DATA *OptData, DIALOG *Dialog, WORD Global[15] );
#endif
#ifdef	TELNET_CLIENT
static void	InsertOptions( OPT_DATA *OptData, TELNET *Telnet );
static void	InsertTelnetOptions( DIALOG *Dialog, OPT_DATA *OptData, TELNET *Telnet, WORD Global[15] );
#endif

/*-----------------------------------------------------------------------------*/
/* Lokale Variablen                                                            */
/*-----------------------------------------------------------------------------*/
#ifdef	IRC_CLIENT
static WORD	KatObject[4] = { OPTIONS_COLORS, OPTIONS_SESSION, OPTIONS_OTHER, OPTIONS_FONTS };
#endif
#ifdef	TELNET_CLIENT
static WORD	KatObject[4] = { OPTIONS_VIEW, OPTIONS_TELNET, OPTIONS_TERMINAL, OPTIONS_OTHER };
#endif

#ifdef	IRC_CLIENT
static WORD	KatPopup[4] = { POPUP_OPTIONS_COLORS, POPUP_OPTIONS_SESSION, POPUP_OPTIONS_OTHER, POPUP_OPTIONS_FONTS };
extern WORD ColourTableObj[], ColourTableIdx[];
#endif
#ifdef	TELNET_CLIENT
static WORD	KatPopup[4] = { POPUP_OPTIONS_VIEW, POPUP_OPTIONS_TELNET, POPUP_OPTIONS_TERMINAL, POPUP_OPTIONS_OTHER };
static WORD	EmuTypePopup[4] = { POPUP_EMULATION_NVT, POPUP_EMULATION_VT52, POPUP_EMULATION_VT100/*, POPUP_EMULATION_VT102 */};
#endif

static XTED	HostXted;
static BYTE	HostTmplt[EDITLEN+1], HostTxt[EDITLEN+1];
#ifdef	IRC_CLIENT
static XTED	NickXted;
static BYTE	NickTmplt[EDITLEN+1], NickTxt[EDITLEN+1];
static XTED	UserXted;
static BYTE	UserTmplt[EDITLEN+1], UserTxt[EDITLEN+1];
static XTED	PassXted;
static BYTE	PassTmplt[EDITLEN+1], PassTxt[EDITLEN+1];
static XTED	RealXted;
static BYTE	RealTmplt[EDITLEN+1], RealTxt[EDITLEN+1];
static XTED	AutojoinXted;
static BYTE	AutojoinTmplt[EDITLEN+1], AutojoinTxt[EDITLEN+1];
#endif

#ifdef	IRC_CLIENT
OBJECT	*CreateOptions( OPT_DATA *OptData, WORD No, IRC *Irc )
#endif
#ifdef	TELNET_CLIENT
OBJECT	*CreateOptions( OPT_DATA *OptData, WORD No, TELNET *Telnet )
#endif
{
	WORD		Off;

	if( TreeAddr[OPTIONS][OPTIONS_HOST].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
		InitScrlted( &TreeAddr[OPTIONS][OPTIONS_HOST], isScroll, &HostXted, HostTxt, HostTmplt, EDITLEN );
#ifdef	IRC_CLIENT
	if( TreeAddr[OPTIONS][OPTIONS_NICKNAME].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
		InitScrlted( &TreeAddr[OPTIONS][OPTIONS_NICKNAME], isScroll, &NickXted, NickTxt, NickTmplt, EDITLEN );
	if( TreeAddr[OPTIONS][OPTIONS_USERNAME].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
		InitScrlted( &TreeAddr[OPTIONS][OPTIONS_USERNAME], isScroll, &UserXted, UserTxt, UserTmplt, EDITLEN );
/*	if( TreeAddr[OPTIONS][OPTIONS_PASSWORD].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
		InitScrlted( &TreeAddr[OPTIONS][OPTIONS_PASSWORD], isScroll, &PassXted, PassTxt, PassTmplt, EDITLEN );
*/	if( TreeAddr[OPTIONS][OPTIONS_REALNAME].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
		InitScrlted( &TreeAddr[OPTIONS][OPTIONS_REALNAME], isScroll, &RealXted, RealTxt, RealTmplt, EDITLEN );
	if( TreeAddr[OPTIONS][OPTIONS_AUTOJOIN].ob_spec.tedinfo->te_txtlen < EDITLEN + 1 )
		InitScrlted( &TreeAddr[OPTIONS][OPTIONS_AUTOJOIN], isScroll, &AutojoinXted, AutojoinTxt, AutojoinTmplt, EDITLEN );
#endif
	OptData->DialogTree = InsertTree( OptData->Tree, OptData->Obj, TreeAddr[OPTIONS], KatObject[OptData->Kat] );
	strcpy( OptData->DialogTree[OptData->Button].ob_spec.free_string, TreeAddr[POPUP_OPTIONS][KatPopup[OptData->Kat]].ob_spec.free_string );

	Off = GetInsertOffset( OptData->Tree );

	OptData->No = No;
	if( No & OPT_NO_HOST )
	{
		OptData->DialogTree[Off+OPTIONS_HOST].ob_flags &= ~EDITABLE;
		OptData->DialogTree[Off+OPTIONS_HOST].ob_state |= DISABLED;
		OptData->DialogTree[Off+OPTIONS_HOST_TEXT].ob_flags &= ~SELECTABLE;
	}
	if( No & OPT_NO_PORT )
	{
		OptData->DialogTree[Off+OPTIONS_PORT].ob_flags &= ~EDITABLE;
		OptData->DialogTree[Off+OPTIONS_PORT].ob_state |= DISABLED;
		OptData->DialogTree[Off+OPTIONS_PORT_TEXT].ob_flags &= ~SELECTABLE;
	}
#ifdef	IRC_CLIENT
	if( No & OPT_NO_PASSWORD )
	{
/*		OptData->DialogTree[Off+OPTIONS_PASSWORD].ob_flags &= ~EDITABLE;
		OptData->DialogTree[Off+OPTIONS_PASSWORD].ob_state |= DISABLED;
		OptData->DialogTree[Off+OPTIONS_PASSWORD_TEXT].ob_flags &= ~SELECTABLE;
*/	}

	if( mt_list_create( OptData->DialogTree, Off + OPTIONS_CTEXT, 1, Global ))
	{
		FreeInsertTree( OptData->Tree, TreeAddr[OPTIONS], OptData->DialogTree );
		return( NULL );
	}
	if( mt_list_create( OptData->DialogTree, Off + OPTIONS_CBOX, 1, Global ))
	{
		FreeInsertTree( OptData->Tree, TreeAddr[OPTIONS], OptData->DialogTree );
		return( NULL );
	}
	mt_list_set_mode( OptData->DialogTree, Off + OPTIONS_CTEXT, 0, Global );
	mt_list_set_mode( OptData->DialogTree, Off + OPTIONS_CBOX, LISTOBJ_SHOW_COLOUR, Global );
	{
		WORD	i;
		BYTE	*Item1[1], *Item2[1];
		for( i = 0; i < COLOUR_MAX; i++ )
		{
			Item1[0] = TreeAddr[POPUP_COLOURTABLE][ColourTableObj[i]].ob_spec.free_string + 2;
			Item2[0] = "";
			mt_list_attach_item( OptData->DialogTree, Off+OPTIONS_CTEXT, Item1, -1, 0, Global );
			mt_list_attach_item( OptData->DialogTree, Off+OPTIONS_CBOX, Item2, i, 0, Global );
		}
	}
	SetCSlider( OptData, NULL, Global );
	
#endif
#ifdef	IRC_CLIENT
	InsertOptions( OptData, Irc );
#endif
#ifdef	TELNET_CLIENT
	InsertOptions( OptData, Telnet );
#endif
	return( OptData->DialogTree );
}

#ifdef	IRC_CLIENT
void	InsertOptions( OPT_DATA *OptData, IRC *Irc )
#endif
#ifdef	TELNET_CLIENT
void	InsertOptions( OPT_DATA *OptData, TELNET *Telnet )
#endif
{
	WORD	Off = GetInsertOffset( OptData->Tree );

#ifdef	IRC_CLIENT
/* -- Kategorie: Farben ---------------------------------------------------- */
	WORD	i;
	for( i = 0; i < COLOUR_MAX; i++ )
		mt_list_set_colourtable( OptData->DialogTree, Off+OPTIONS_CBOX, Irc->ColourTable[ColourTableIdx[i]], i, Global );

/* -- Kategorie: IRC ------------------------------------------------------- */
	Irc->Host ? strcpy( OptData->DialogTree[Off+OPTIONS_HOST].ob_spec.tedinfo->te_ptext, Irc->Host ) : strcpy( OptData->DialogTree[Off+OPTIONS_HOST].ob_spec.tedinfo->te_ptext, "" );
	sprintf( OptData->DialogTree[Off+OPTIONS_PORT].ob_spec.tedinfo->te_ptext, "%u", Irc->Port );
	Irc->Nickname ? strcpy( OptData->DialogTree[Off+OPTIONS_NICKNAME].ob_spec.tedinfo->te_ptext, Irc->Nickname ) : strcpy( OptData->DialogTree[Off+OPTIONS_NICKNAME].ob_spec.tedinfo->te_ptext, "" );
	Irc->Username ? strcpy( OptData->DialogTree[Off+OPTIONS_USERNAME].ob_spec.tedinfo->te_ptext, Irc->Username ) : strcpy( OptData->DialogTree[Off+OPTIONS_USERNAME].ob_spec.tedinfo->te_ptext, "" );
/*	Irc->Password ? strcpy( OptData->DialogTree[Off+OPTIONS_PASSWORD].ob_spec.tedinfo->te_ptext, Irc->Password ) : strcpy( OptData->DialogTree[Off+OPTIONS_PASSWORD].ob_spec.tedinfo->te_ptext, "" );
*/	Irc->Realname ? strcpy( OptData->DialogTree[Off+OPTIONS_REALNAME].ob_spec.tedinfo->te_ptext, Irc->Realname ) : strcpy( OptData->DialogTree[Off+OPTIONS_REALNAME].ob_spec.tedinfo->te_ptext, "" );

	OptData->InputFontId = Irc->InputFontId;
	OptData->InputFontHt = Irc->InputFontHt;
	OptData->OutputFontId = Irc->OutputFontId;
	OptData->OutputFontHt = Irc->OutputFontHt;
	OptData->ChannelFontId = Irc->ChannelFontId;
	OptData->ChannelFontHt = Irc->ChannelFontHt;
	OptData->UserFontId = Irc->UserFontId;
	OptData->UserFontHt = Irc->UserFontHt;

	sprintf( OptData->DialogTree[Off+OPTIONS_NLINES].ob_spec.tedinfo->te_ptext, "%li", Irc->nLines );
	Irc->Autojoin ? strcpy( OptData->DialogTree[Off+OPTIONS_AUTOJOIN].ob_spec.tedinfo->te_ptext, Irc->Autojoin ) : strcpy( OptData->DialogTree[Off+OPTIONS_AUTOJOIN].ob_spec.tedinfo->te_ptext, "" );

	if( Irc->PingPong )
		OptData->DialogTree[Off+OPTIONS_OTHER_PINGPONG].ob_state |= SELECTED;
	else
		OptData->DialogTree[Off+OPTIONS_OTHER_PINGPONG].ob_state &= ~SELECTED;
	if( Irc->CtcpReply )
		OptData->DialogTree[Off+OPTIONS_OTHER_CTCP].ob_state |= SELECTED;
	else
		OptData->DialogTree[Off+OPTIONS_OTHER_CTCP].ob_state &= ~SELECTED;
	if( Irc->LogFlag )
		OptData->DialogTree[Off+OPTIONS_LOG].ob_state |= SELECTED;
	else
		OptData->DialogTree[Off+OPTIONS_LOG].ob_state &= ~SELECTED;

	GetFaceName( OptData->OutputFontId, OptData->OutputFontHt, VdiHandle, OptData->DialogTree[Off+OPTIONS_FONTNAME_OUTPUT].ob_spec.free_string );
	GetFaceName( OptData->InputFontId, OptData->InputFontHt, VdiHandle, OptData->DialogTree[Off+OPTIONS_FONTNAME_INPUT].ob_spec.free_string );
	GetFaceName( OptData->ChannelFontId, OptData->ChannelFontHt, VdiHandle, OptData->DialogTree[Off+OPTIONS_FONTNAME_CHANNEL].ob_spec.free_string );
	GetFaceName( OptData->UserFontId, OptData->UserFontHt, VdiHandle, OptData->DialogTree[Off+OPTIONS_FONTNAME_USER].ob_spec.free_string );

#endif

#ifdef	TELNET_CLIENT
	OptData->FontId = Telnet->FontId;
	OptData->FontPt = Telnet->FontPt;
	OptData->FontEffects = Telnet->FontEffects;
	OptData->EmuType = Telnet->EmuType;
	OptData->KeyFlag = Telnet->KeyFlag;
	OptData->KeyExport = Telnet->KeyExport;
	OptData->KeyImport = Telnet->KeyImport;

/* -- Kategorie: Darstellung ----------------------------------------------- */
	OptData->FontColorUserBlk.ub_code = ColorUbCode;
	OptData->FontColorUserBlk.ub_parm = Telnet->FontColor;
	OptData->WindowColorUserBlk.ub_code = ColorUbCode;
	OptData->WindowColorUserBlk.ub_parm = Telnet->WindowColor;
	GetFaceName( OptData->FontId, OptData->FontPt, VdiHandle, OptData->DialogTree[Off+OPTIONS_FONTNAME].ob_spec.free_string );
	OptData->DialogTree[Off+OPTIONS_FONTCOLOR].ob_type = G_USERDEF;
	OptData->DialogTree[Off+OPTIONS_FONTCOLOR].ob_spec.userblk = &( OptData->FontColorUserBlk );
	OptData->DialogTree[Off+OPTIONS_WINDOWCOLOR].ob_type = G_USERDEF;
	OptData->DialogTree[Off+OPTIONS_WINDOWCOLOR].ob_spec.userblk = &( OptData->WindowColorUserBlk );
	sprintf( OptData->DialogTree[Off+OPTIONS_PUFLINES].ob_spec.tedinfo->te_ptext, "%li", Telnet->PufLines );

/* -- Kategorie: Telnet ---------------------------------------------------- */
	Telnet->Host ? strcpy( OptData->DialogTree[Off+OPTIONS_HOST].ob_spec.tedinfo->te_ptext, Telnet->Host ) : strcpy( OptData->DialogTree[Off+OPTIONS_HOST].ob_spec.tedinfo->te_ptext, "" );
	sprintf( OptData->DialogTree[Off+OPTIONS_PORT].ob_spec.tedinfo->te_ptext, "%u", Telnet->Port );

/* -- Kategorie: Terminal -------------------------------------------------- */
	strcpy( OptData->DialogTree[Off+OPTIONS_EMULATION].ob_spec.free_string, TreeAddr[POPUP_EMULATION][EmuTypePopup[OptData->EmuType]].ob_spec.free_string );
	sprintf( OptData->DialogTree[Off+OPTIONS_COLUMNS].ob_spec.tedinfo->te_ptext, "%li", Telnet->Terminal.x );
	sprintf( OptData->DialogTree[Off+OPTIONS_ROWS].ob_spec.tedinfo->te_ptext, "%li", Telnet->Terminal.y );
	if( OptData->KeyFlag & CURSOR_APPLICATION )
		strcpy( OptData->DialogTree[Off+OPTIONS_CURSOR].ob_spec.free_string, TreeAddr[POPUP_CURSOR][POPUP_CURSOR_APPLICATION].ob_spec.free_string );
	else
		strcpy( OptData->DialogTree[Off+OPTIONS_CURSOR].ob_spec.free_string, TreeAddr[POPUP_CURSOR][POPUP_CURSOR_NORMAL].ob_spec.free_string );
	if( OptData->KeyFlag & KEYPAD_APPLICATION )
		strcpy( OptData->DialogTree[Off+OPTIONS_KEYPAD].ob_spec.free_string, TreeAddr[POPUP_KEYPAD][POPUP_KEYPAD_APPLICATION].ob_spec.free_string );
	else
		strcpy( OptData->DialogTree[Off+OPTIONS_KEYPAD].ob_spec.free_string, TreeAddr[POPUP_KEYPAD][POPUP_KEYPAD_NORMAL].ob_spec.free_string );

/* -- Kategorie: Sonstiges ------------------------------------------------- */
	strcpy( OptData->DialogTree[Off+OPTIONS_KEY_IMPORT].ob_spec.free_string, KeyImportPopup[Telnet->KeyImport+1].ob_spec.free_string );
	strcpy( OptData->DialogTree[Off+OPTIONS_KEY_EXPORT].ob_spec.free_string, KeyExportPopup[Telnet->KeyExport+1].ob_spec.free_string );
	sprintf( OptData->DialogTree[Off+OPTIONS_TAB_H].ob_spec.tedinfo->te_ptext, "%li", Telnet->Tab.x );
	sprintf( OptData->DialogTree[Off+OPTIONS_TAB_V].ob_spec.tedinfo->te_ptext, "%li", Telnet->Tab.y );
	if( Telnet->ProtocolFlag )
		OptData->DialogTree[Off+OPTIONS_PROTOCOL].ob_state |= SELECTED;
	else
		OptData->DialogTree[Off+OPTIONS_PROTOCOL].ob_state &= ~SELECTED;
#endif
}

void	DelOptions( OPT_DATA *OptData )
{
#ifdef	IRC_CLIENT
	WORD	Off = GetInsertOffset( OptData->Tree );
	mt_list_delete( OptData->DialogTree, Off + OPTIONS_CTEXT, Global );
	mt_list_delete( OptData->DialogTree, Off + OPTIONS_CBOX, Global );
#endif
	FreeInsertTree( OptData->Tree, TreeAddr[OPTIONS], OptData->DialogTree );
}

#ifdef	IRC_CLIENT
void	GetOptions( OPT_DATA *OptData, IRC *Irc )
#endif
#ifdef	TELNET_CLIENT
void	GetOptions( OPT_DATA *OptData, TELNET *Telnet )
#endif
{
	WORD	Off = GetInsertOffset( OptData->Tree );
#ifdef	IRC_CLIENT
	Irc->Host = strlen( OptData->DialogTree[Off+OPTIONS_HOST].ob_spec.tedinfo->te_ptext ) ? strdup( OptData->DialogTree[Off+OPTIONS_HOST].ob_spec.tedinfo->te_ptext ) : NULL;
	Irc->Port = atoi( OptData->DialogTree[Off+OPTIONS_PORT].ob_spec.tedinfo->te_ptext );
	Irc->Nickname = strlen( OptData->DialogTree[Off+OPTIONS_NICKNAME].ob_spec.tedinfo->te_ptext ) ? strdup( OptData->DialogTree[Off+OPTIONS_NICKNAME].ob_spec.tedinfo->te_ptext ) : NULL;
	Irc->Username = strlen( OptData->DialogTree[Off+OPTIONS_USERNAME].ob_spec.tedinfo->te_ptext ) ? strdup( OptData->DialogTree[Off+OPTIONS_USERNAME].ob_spec.tedinfo->te_ptext ) : NULL;
	Irc->Password = NULL;
/*	Irc->Password = strlen( OptData->DialogTree[Off+OPTIONS_PASSWORD].ob_spec.tedinfo->te_ptext ) ? strdup( OptData->DialogTree[Off+OPTIONS_PASSWORD].ob_spec.tedinfo->te_ptext ) : NULL;
*/	Irc->Realname = strlen( OptData->DialogTree[Off+OPTIONS_REALNAME].ob_spec.tedinfo->te_ptext ) ? strdup( OptData->DialogTree[Off+OPTIONS_REALNAME].ob_spec.tedinfo->te_ptext ) : NULL;
	Irc->Autojoin = strlen( OptData->DialogTree[Off+OPTIONS_AUTOJOIN].ob_spec.tedinfo->te_ptext ) ? strdup( OptData->DialogTree[Off+OPTIONS_AUTOJOIN].ob_spec.tedinfo->te_ptext ) : NULL;

	Irc->OutputFontId = OptData->OutputFontId;
	Irc->OutputFontHt = OptData->OutputFontHt;
	Irc->InputFontId = OptData->InputFontId;
	Irc->InputFontHt = OptData->InputFontHt;
	Irc->ChannelFontId = OptData->ChannelFontId;
	Irc->ChannelFontHt = OptData->ChannelFontHt;
	Irc->UserFontId = OptData->UserFontId;
	Irc->UserFontHt = OptData->UserFontHt;
	Irc->PingPong = ( OptData->DialogTree[Off+OPTIONS_OTHER_PINGPONG].ob_state & SELECTED ) ? 1 : 0;
	Irc->CtcpReply = ( OptData->DialogTree[Off+OPTIONS_OTHER_CTCP].ob_state & SELECTED ) ? 1 : 0;
	Irc->LogFlag = ( OptData->DialogTree[Off+OPTIONS_LOG].ob_state & SELECTED ) ? 1 : 0;
	{
		WORD	i;
		for( i = 0; i < COLOUR_MAX; i++ )
			Irc->ColourTable[ColourTableIdx[i]] = mt_list_get_colourtable( OptData->DialogTree, Off+OPTIONS_CBOX, i, Global );
	}

	Irc->nLines = atol( OptData->DialogTree[Off+OPTIONS_NLINES].ob_spec.tedinfo->te_ptext );
#endif
#ifdef	TELNET_CLIENT
	Telnet->Host = strdup( OptData->DialogTree[Off+OPTIONS_HOST].ob_spec.tedinfo->te_ptext );
	Telnet->Port = atoi( OptData->DialogTree[Off+OPTIONS_PORT].ob_spec.tedinfo->te_ptext );
	Telnet->EmuType = OptData->EmuType;
	Telnet->Terminal.x = atol( OptData->DialogTree[Off+OPTIONS_COLUMNS].ob_spec.tedinfo->te_ptext );
	Telnet->Terminal.y = atol( OptData->DialogTree[Off+OPTIONS_ROWS].ob_spec.tedinfo->te_ptext );
	Telnet->Tab.x = atol( OptData->DialogTree[Off+OPTIONS_TAB_H].ob_spec.tedinfo->te_ptext );
	Telnet->Tab.y = atol( OptData->DialogTree[Off+OPTIONS_TAB_V].ob_spec.tedinfo->te_ptext );
	Telnet->KeyFlag = OptData->KeyFlag;
	Telnet->FontId = OptData->FontId;
	Telnet->FontPt = OptData->FontPt;
	Telnet->FontColor = ( WORD ) OptData->FontColorUserBlk.ub_parm;
	Telnet->FontEffects = OptData->FontEffects;
	Telnet->WindowColor = ( WORD ) OptData->WindowColorUserBlk.ub_parm;
	Telnet->PufLines = atol( OptData->DialogTree[Off+OPTIONS_PUFLINES].ob_spec.tedinfo->te_ptext );
	Telnet->KeyExport = OptData->KeyExport;
	Telnet->KeyImport = OptData->KeyImport;
	Telnet->ProtocolFlag = ( OptData->DialogTree[Off+OPTIONS_PROTOCOL].ob_state & SELECTED ) ? 1 : 0;
#endif
}

#ifdef	IRC_CLIENT
void	NewOptions( DIALOG *Dialog, OPT_DATA *OptData, IRC *Irc, WORD Global[15] )
#endif
#ifdef	TELNET_CLIENT
void	NewOptions( DIALOG *Dialog, OPT_DATA *OptData, TELNET *Telnet, WORD Global[15] )
#endif
{
	OBJECT	*DialogTree;
	GRECT		Rect;
	WORD		Edit, Cursor;
	Edit = MT_wdlg_get_edit( Dialog, &Cursor, Global );
	MT_wdlg_set_edit( Dialog, 0, Global );
#ifdef	IRC_CLIENT
	InsertOptions( OptData, Irc );
#endif
#ifdef	TELNET_CLIENT
	InsertOptions( OptData, Telnet );
#endif	
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	DoRedraw( Dialog, &Rect, OptData->Obj, Global );
	MT_wdlg_set_edit( Dialog, Edit, Global );
}

WORD	HandleOptions( DIALOG *Dialog, OPT_DATA *OptData, WORD Obj, EVNT *Events, WORD Data, WORD Global[15] )
{
	OBJECT	*DialogTree;
	GRECT		Rect;
	WORD		Off = GetInsertOffset( OptData->Tree );
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if( Obj == HNDL_OPEN )
		SetEdit( Dialog, OptData, Global );
#ifdef	IRC_CLIENT
	else	if( Obj == HNDL_EDIT )
	{
		WORD	Cur, i = MT_wdlg_get_edit( Dialog, &Cur, Global );
		if( i == Off+OPTIONS_NICKNAME || i == Off+OPTIONS_USERNAME )
		{
			if(( Data & 0x00ff ) == 0x20 )
			{
				Cconout( '\a' );
				return( 0 );
			}
		}
		return( 1 );
	}
#endif
	else	if( Obj == HNDL_EDDN || Obj == HNDL_EDCH || Obj == HNDL_EDIT )
	{
		if( Obj == HNDL_EDCH )
		{
			if( Data != 0 )
			{
				if( Data > Off )
				{
					WORD	i = Data;
					do
					{
						if( i == Off + KatObject[OptData->Kat] )
						{
							OptData->Edit = Data;
							break;
						}
					}
					while(( i = GetParentObject( DialogTree, i )) != -1 );
					if( i == -1 )
						MT_wdlg_set_edit( Dialog, OptData->Edit, Global );
				}
				else
					OptData->Edit = Data;
			}
			else
				OptData->Edit = 0;
		}
#ifdef	IRC_CLIENT
		if(( strlen( DialogTree[Off+OPTIONS_HOST].ob_spec.tedinfo->te_ptext ) || ( DialogTree[Off+OPTIONS_HOST].ob_state & DISABLED )) &&
		     strlen( DialogTree[Off+OPTIONS_PORT].ob_spec.tedinfo->te_ptext ) && (( ULONG ) atol( DialogTree[Off+OPTIONS_PORT].ob_spec.tedinfo->te_ptext ) < 65536L ) &&
		   ( strlen( DialogTree[Off+OPTIONS_NICKNAME].ob_spec.tedinfo->te_ptext ) || ( DialogTree[Off+OPTIONS_NICKNAME].ob_state & DISABLED ) || ( OptData->No & OPT_NN_NICKNAME )) &&
		   ( strlen( DialogTree[Off+OPTIONS_USERNAME].ob_spec.tedinfo->te_ptext ) || ( DialogTree[Off+OPTIONS_USERNAME].ob_state & DISABLED ) || ( OptData->No & OPT_NN_USERNAME )) &&
		   ( strlen( DialogTree[Off+OPTIONS_REALNAME].ob_spec.tedinfo->te_ptext ) || ( DialogTree[Off+OPTIONS_REALNAME].ob_state & DISABLED ) || ( OptData->No & OPT_NN_REALNAME )))
			return( 1 );
		else
			return( -1 );
#endif
#ifdef	TELNET_CLIENT		
		if(( strlen( DialogTree[Off+OPTIONS_HOST].ob_spec.tedinfo->te_ptext ) || ( DialogTree[Off+OPTIONS_HOST].ob_state & DISABLED )) &&
		    strlen( DialogTree[Off+OPTIONS_PORT].ob_spec.tedinfo->te_ptext ) &&
		    (( ULONG ) atol( DialogTree[Off+OPTIONS_PORT].ob_spec.tedinfo->te_ptext )) < 65536L  &&
		    atoi( DialogTree[Off+OPTIONS_COLUMNS].ob_spec.tedinfo->te_ptext ) &&
		    atoi( DialogTree[Off+OPTIONS_ROWS].ob_spec.tedinfo->te_ptext ))
	   	return( 1 );
		else
			return( -1 );
#endif
	}
	else 	if( Obj == OptData->Button )
	{
		WORD	x, y, Selected, Edit, Cursor;
		MT_objc_offset( DialogTree, OptData->Button, &x, &y, Global );			
		Selected = Popup( TreeAddr[POPUP_OPTIONS], KatPopup[OptData->Kat], x, y, Global );
		if( Selected >= 0 && Selected != KatPopup[OptData->Kat] )
		{
			WORD	i = 0;
			
			if(( Edit = MT_wdlg_get_edit( Dialog, &Cursor, Global )) > Off )
				MT_wdlg_set_edit( Dialog, 0, Global );
			else	if( Edit )
				Edit = -1;
			
			while( KatPopup[i] != Selected )
				i++;
			OptData->Kat = i;
			SetInsertObj( OptData->Tree, OptData->Obj, DialogTree, KatObject[OptData->Kat] );
			strcpy( DialogTree[OptData->Button].ob_spec.free_string, TreeAddr[POPUP_OPTIONS][KatPopup[OptData->Kat]].ob_spec.free_string );
			if( Edit != -1 )
				SetEdit( Dialog, OptData, Global );
			DoRedrawX( Dialog, &Rect, Global, OptData->Button, OptData->Obj, EDRX );
		}
	}
	else
	{
		WORD	i = Obj;
		do
		{
			if( i == Off + KatObject[OptData->Kat] )
			{
				break;
			}
		}
		while(( i = GetParentObject( DialogTree, i )) != -1 );

		if( i == -1 )
			return( 0 );
#ifdef	IRC_CLIENT
		mt_list_evnt( DialogTree, Off + OPTIONS_CTEXT, MT_wdlg_get_handle( Dialog, Global ), Events, Global );
		mt_list_evnt( DialogTree, Off + OPTIONS_CBOX, MT_wdlg_get_handle( Dialog, Global ), Events, Global );
		if(( i = mt_list_get_selected( DialogTree, Off + OPTIONS_CTEXT, Global )) != -1 || 
		   ( i = mt_list_get_selected( DialogTree, Off + OPTIONS_CBOX, Global )) != -1 )
		{
			WORD	Color;
			if(( Color = ColorPopup( mt_list_get_colourtable( DialogTree, Off + OPTIONS_CBOX, i, Global ), 0, Events->mx, Events->my, Global )) != -1 )
				mt_list_set_colourtable( DialogTree, Off + OPTIONS_CBOX, Color, i, Global );
			mt_list_set_selected( DialogTree, Off + OPTIONS_CTEXT, MT_wdlg_get_handle( Dialog, Global ), -1, Global );
			mt_list_set_selected( DialogTree, Off + OPTIONS_CBOX, MT_wdlg_get_handle( Dialog, Global ), -1, Global );
		}
#endif
		switch( Obj - Off )
		{
#ifdef	IRC_CLIENT
			case	OPTIONS_CBOX_SLDR_UP:
			{
				LONG	nLines, yScroll;
				WORD	yVis, nCols, xScroll, xVis;
				mt_list_get_scrollinfo( DialogTree, Off+OPTIONS_CTEXT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
				if( yScroll > 0 )
				{
					mt_list_scroll( DialogTree, Off+OPTIONS_CTEXT, MT_wdlg_get_handle( Dialog, Global ), -1, 0, Global );
					mt_list_scroll( DialogTree, Off+OPTIONS_CBOX, MT_wdlg_get_handle( Dialog, Global ), -1, 0, Global );
					SetCSlider( OptData, Dialog, Global );
				}
				break;
			}
			case	OPTIONS_CBOX_SLDR_DOWN:
			{
				LONG	nLines, yScroll;
				WORD	yVis, nCols, xScroll, xVis;
				mt_list_get_scrollinfo( DialogTree, Off+OPTIONS_CTEXT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
				if( yScroll + yVis < nLines )
				{
					mt_list_scroll( DialogTree, Off+OPTIONS_CTEXT, MT_wdlg_get_handle( Dialog, Global ), +1, 0, Global );
					mt_list_scroll( DialogTree, Off+OPTIONS_CBOX, MT_wdlg_get_handle( Dialog, Global ), +1, 0, Global );
					SetCSlider( OptData, Dialog, Global );
				}
				break;
			}
			case	OPTIONS_CBOX_SLDR:
			{
				EVNTDATA	EvNew;
				WORD	xPos, yPos, DyScroll, y;
				WORD	Height = DialogTree[Off+OPTIONS_CBOX_SLDR_BACK].ob_height;
				LONG	nLines, yScroll;
				WORD	yVis, nCols, xScroll, xVis;

 				MT_wind_update( BEG_UPDATE, Global );
				MT_wind_update( BEG_MCTRL, Global );
				MT_graf_mouse( 258, NULL, Global );
				MT_graf_mouse( FLAT_HAND, NULL, Global );

				MT_graf_mkstate( &EvNew, Global );
				yPos = EvNew.y;
				do
				{
					if( yPos != EvNew.y )
					{
						mt_list_get_scrollinfo( OptData->DialogTree, Off+OPTIONS_CTEXT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
						y = DialogTree[Off+OPTIONS_CBOX_SLDR].ob_y;
						DyScroll = ( DialogTree[Off+OPTIONS_CBOX_SLDR].ob_y + EvNew.y - yPos ) * nLines / Height - yScroll;
						if( DyScroll )
						{
							mt_list_scroll( DialogTree, Off+OPTIONS_CTEXT, MT_wdlg_get_handle( Dialog, Global ), DyScroll, 0, Global );
							mt_list_scroll( DialogTree, Off+OPTIONS_CBOX, MT_wdlg_get_handle( Dialog, Global ), DyScroll, 0, Global );
							SetCSlider( OptData, Dialog, Global );
							if( y != DialogTree[Off+OPTIONS_CBOX_SLDR].ob_y )
								yPos = EvNew.y;
						}
					}
					MT_graf_mkstate( &EvNew, Global );
				}
				while( EvNew.bstate );

				MT_graf_mouse( 259, NULL, Global );
				MT_wind_update( END_MCTRL, Global );
				MT_wind_update( END_UPDATE, Global );
				break;
			}
			case	OPTIONS_CBOX_SLDR_BACK:
			{
				EVNTDATA	Ev;
				LONG	nLines, yScroll;
				WORD	yVis, nCols, xScroll, xVis, x, y;
				MT_graf_mkstate( &Ev, Global );
				mt_list_get_scrollinfo( DialogTree, Off+OPTIONS_CTEXT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );
				MT_objc_offset( DialogTree, Off+OPTIONS_CBOX_SLDR, &x, &y, Global );
				if( y < Ev.y )
				{
					mt_list_scroll( DialogTree, Off+OPTIONS_CTEXT, MT_wdlg_get_handle( Dialog, Global ), yVis, 0, Global );
					mt_list_scroll( DialogTree, Off+OPTIONS_CBOX, MT_wdlg_get_handle( Dialog, Global ), yVis, 0, Global );
				}
				else
				{
					mt_list_scroll( DialogTree, Off+OPTIONS_CTEXT, MT_wdlg_get_handle( Dialog, Global ), -yVis, 0, Global );
					mt_list_scroll( DialogTree, Off+OPTIONS_CBOX, MT_wdlg_get_handle( Dialog, Global ), -yVis, 0, Global );
				}
				SetCSlider( OptData, Dialog, Global );
				break;
			}
			case	OPTIONS_FONTNAME_OUTPUT:
			case	OPTIONS_FONTNAME_INPUT:
			case	OPTIONS_FONTNAME_CHANNEL:
			case	OPTIONS_FONTNAME_USER:
			{
				WORD	ChkBox;
				LONG	Id, Pt, Ratio = 1L << 16;
				void	*FontDialog;
				MT_graf_mouse( M_SAVE, NULL, Global );
				MT_graf_mouse( BUSYBEE, NULL, Global );
				FontDialog = MT_fnts_create( VdiHandle, 0, FNTS_BTMP + FNTS_OUTL + 
				                             FNTS_MONO + FNTS_PROP, FNTS_3D, 
				                             TreeAddr[ABOUT][MOT].ob_spec.free_string, 
				                              NULL, Global );
				MT_graf_mouse( M_RESTORE, NULL, Global );
				if( FontDialog )
				{
					WORD	Ret = -1;
					if( Obj == Off + OPTIONS_FONTNAME_OUTPUT )
						Ret = MT_fnts_do( FontDialog, 0, ( LONG ) OptData->OutputFontId, (( LONG ) OptData->OutputFontHt ) << 16, Ratio, &ChkBox, &Id, &Pt, &Ratio, Global );
					else	if( Obj == Off + OPTIONS_FONTNAME_INPUT )
						Ret = MT_fnts_do( FontDialog, 0, ( LONG ) OptData->InputFontId, (( LONG ) OptData->InputFontHt ) << 16, Ratio, &ChkBox, &Id, &Pt, &Ratio, Global );
					else	if( Obj == Off + OPTIONS_FONTNAME_CHANNEL )
						Ret = MT_fnts_do( FontDialog, 0, ( LONG ) OptData->ChannelFontId, (( LONG ) OptData->ChannelFontHt ) << 16, Ratio, &ChkBox, &Id, &Pt, &Ratio, Global );
					else	if( Obj == Off + OPTIONS_FONTNAME_USER )
						Ret = MT_fnts_do( FontDialog, 0, ( LONG ) OptData->UserFontId, (( LONG ) OptData->ChannelFontHt ) << 16, Ratio, &ChkBox, &Id, &Pt, &Ratio, Global );

					if( Ret == FNTS_OK )
					{
						if( Obj == Off + OPTIONS_FONTNAME_OUTPUT )
						{
							OptData->OutputFontId = ( WORD ) Id;
							OptData->OutputFontHt = Pt >> 16;
							GetFaceName( OptData->OutputFontId, OptData->OutputFontHt, VdiHandle, DialogTree[Off+OPTIONS_FONTNAME_OUTPUT].ob_spec.free_string );
						}
						else	if( Obj == Off + OPTIONS_FONTNAME_INPUT )
						{
							OptData->InputFontId = ( WORD ) Id;
							OptData->InputFontHt = Pt >> 16;
							GetFaceName( OptData->InputFontId, OptData->InputFontHt, VdiHandle, DialogTree[Off+OPTIONS_FONTNAME_INPUT].ob_spec.free_string );
						}
						else	if( Obj == Off + OPTIONS_FONTNAME_CHANNEL )
						{
							OptData->ChannelFontId = ( WORD ) Id;
							OptData->ChannelFontHt = Pt >> 16;
							GetFaceName( OptData->ChannelFontId, OptData->ChannelFontHt, VdiHandle, DialogTree[Off+OPTIONS_FONTNAME_CHANNEL].ob_spec.free_string );
						}
						else	if( Obj == Off + OPTIONS_FONTNAME_USER )
						{
							OptData->UserFontId = ( WORD ) Id;
							OptData->UserFontHt = Pt >> 16;
							GetFaceName( OptData->UserFontId, OptData->UserFontHt, VdiHandle, DialogTree[Off+OPTIONS_FONTNAME_USER].ob_spec.free_string );
						}
					}
					MT_fnts_delete( FontDialog, VdiHandle, Global );
				}
				else
				{
					Cconout( '\a' );
					break;
				}
				DialogTree[Obj].ob_state &= ~SELECTED;
				DoRedraw( Dialog, &Rect, Obj, Global );
				break;
			}
			case	OPTIONS_NLINES_TEXT:
				MT_wdlg_set_edit( Dialog, Off + OPTIONS_NLINES, Global );
			case	OPTIONS_AUTOJOIN_TEXT:
				MT_wdlg_set_edit( Dialog, Off + OPTIONS_AUTOJOIN, Global );
				break;
#endif
#ifdef	TELNET_CLIENT
/* -- Kategorie: Darstellung ----------------------------------------------- */
			case	OPTIONS_FONTNAME:
			{
				WORD	ChkBox;
				LONG	Id, Pt, Ratio = 1L << 16;
				void	*FontDialog;
				MT_graf_mouse( M_SAVE, NULL, Global );
				MT_graf_mouse( BUSYBEE, NULL, Global );
				FontDialog = MT_fnts_create( VdiHandle, 0, FNTS_BTMP + FNTS_OUTL + 
				                             FNTS_MONO, FNTS_3D, 
				                             TreeAddr[ABOUT][MOT].ob_spec.free_string, 
				                              NULL, Global );
				MT_graf_mouse( M_RESTORE, NULL, Global );
				if( FontDialog )
				{
					if( MT_fnts_do( FontDialog, 0, ( LONG ) OptData->FontId, OptData->FontPt, Ratio, &ChkBox, &Id, &Pt, &Ratio, Global ) == FNTS_OK )
					{
						if( Id != OptData->FontId || OptData->FontPt != Pt )
						{
							OptData->FontId = ( WORD ) Id;
							OptData->FontPt = Pt;
							GetFaceName( OptData->FontId, OptData->FontPt, VdiHandle, DialogTree[Off+OPTIONS_FONTNAME].ob_spec.free_string );
						}
					}
					MT_fnts_delete( FontDialog, VdiHandle, Global );
				}
				else
				{
					Cconout( '\a' );
					break;
				}
				DialogTree[Off+OPTIONS_FONTNAME].ob_state &= ~SELECTED;
				DoRedraw( Dialog, &Rect, Off+OPTIONS_FONTNAME, Global );
				break;
			}

			case	OPTIONS_FONTCOLOR_TEXT:
			case	OPTIONS_FONTCOLOR:
			{
				WORD	x, y, Color, Flag = 0;
				if( Obj == Off + OPTIONS_FONTCOLOR  )
				{
					x = Events->mx;
					y = Events->my;
					Flag = 1;
				}
				else
					MT_objc_offset( DialogTree, Off + OPTIONS_FONTCOLOR, &x, &y, Global );
				if(( Color = ColorPopup(( WORD ) OptData->FontColorUserBlk.ub_parm, Flag, x, y, Global )) != -1 )
				{
					OptData->FontColorUserBlk.ub_parm = Color;
					DoRedraw( Dialog, &Rect, Off + OPTIONS_FONTCOLOR_BOX, Global );
				}
				break;
			}

			case	OPTIONS_WINDOWCOLOR_TEXT:
			case	OPTIONS_WINDOWCOLOR:
			{
				WORD	x, y, Color, Flag = 0;
				if( Obj == Off + OPTIONS_WINDOWCOLOR  )
				{
					x = Events->mx;
					y = Events->my;
					Flag = 1;
				}
				else
					MT_objc_offset( DialogTree, Off + OPTIONS_WINDOWCOLOR, &x, &y, Global );
				if(( Color = ColorPopup(( WORD ) OptData->WindowColorUserBlk.ub_parm, Flag, x, y, Global )) != -1 )
				{
					OptData->WindowColorUserBlk.ub_parm = Color;
					DoRedraw( Dialog, &Rect, Off + OPTIONS_WINDOWCOLOR_BOX, Global );
				}
				break;
			}
			case	OPTIONS_PUFLINES_TEXT:
				MT_wdlg_set_edit( Dialog, Off + OPTIONS_PUFLINES, Global );
				break;

/* -- Kategorie: Telnet ---------------------------------------------------- */
			case	OPTIONS_HOST_TEXT:
				if( DialogTree[Off+OPTIONS_HOST].ob_flags & EDITABLE )
					MT_wdlg_set_edit( Dialog, Off + OPTIONS_HOST, Global );
				break;
			case	OPTIONS_PORT_TEXT:
				if( DialogTree[Off+OPTIONS_PORT].ob_flags & EDITABLE )
				MT_wdlg_set_edit( Dialog, Off + OPTIONS_PORT, Global );
				break;

/* -- Kategorie: Terminal -------------------------------------------------- */
			case	OPTIONS_EMULATION_TEXT:
			case	OPTIONS_EMULATION:
			{
				WORD	x, y, Selected;
				MT_objc_offset( DialogTree, Off + OPTIONS_EMULATION, &x, &y, Global );			
				Selected = Popup( TreeAddr[POPUP_EMULATION], EmuTypePopup[OptData->EmuType], x, y, Global );
				if( Selected != -1 )
				{
					OptData->EmuType = NVT;
					while( EmuTypePopup[OptData->EmuType] != Selected )
						OptData->EmuType++;
					strcpy( DialogTree[Off+OPTIONS_EMULATION].ob_spec.free_string, TreeAddr[POPUP_EMULATION][Selected].ob_spec.free_string );
					DoRedraw( Dialog, &Rect, Off + OPTIONS_EMULATION, Global );
				}
				break;
			}
			case	OPTIONS_COLUMNS_TEXT:
				MT_wdlg_set_edit( Dialog, Off + OPTIONS_COLUMNS, Global );
				break;
			case	OPTIONS_ROWS_TEXT:
				MT_wdlg_set_edit( Dialog, Off + OPTIONS_ROWS, Global );
				break;
			case	OPTIONS_CURSOR_TEXT:
			case	OPTIONS_CURSOR:
			{
				WORD	x, y, Selected;
				MT_objc_offset( DialogTree, Off + OPTIONS_CURSOR, &x, &y, Global );
				Selected = Popup( TreeAddr[POPUP_CURSOR], OptData->KeyFlag & CURSOR_APPLICATION ? POPUP_CURSOR_APPLICATION : POPUP_CURSOR_NORMAL, x, y, Global );
				if( Selected != -1 )
				{
					OptData->KeyFlag = ( Selected == POPUP_CURSOR_APPLICATION ? OptData->KeyFlag | CURSOR_APPLICATION : OptData->KeyFlag & ~CURSOR_APPLICATION );
					if( OptData->KeyFlag & CURSOR_APPLICATION )
						strcpy( DialogTree[Off+OPTIONS_CURSOR].ob_spec.free_string, TreeAddr[POPUP_CURSOR][POPUP_CURSOR_APPLICATION].ob_spec.free_string );
					else
						strcpy( DialogTree[Off+OPTIONS_CURSOR].ob_spec.free_string, TreeAddr[POPUP_CURSOR][POPUP_CURSOR_NORMAL].ob_spec.free_string );
					DoRedraw( Dialog, &Rect, Off + OPTIONS_CURSOR, Global );
				}
				break;
			}
			case	OPTIONS_KEYPAD_TEXT:
			case	OPTIONS_KEYPAD:
			{
				WORD	x, y, Selected;
				MT_objc_offset( DialogTree, Off + OPTIONS_KEYPAD, &x, &y, Global );
				Selected = Popup( TreeAddr[POPUP_KEYPAD], OptData->KeyFlag & KEYPAD_APPLICATION ? POPUP_KEYPAD_APPLICATION : POPUP_KEYPAD_NORMAL, x, y, Global );
				if( Selected != -1 )
				{
					OptData->KeyFlag = ( Selected == POPUP_KEYPAD_APPLICATION ? OptData->KeyFlag | KEYPAD_APPLICATION : OptData->KeyFlag & ~KEYPAD_APPLICATION );
					if( OptData->KeyFlag & KEYPAD_APPLICATION )
						strcpy( DialogTree[Off+OPTIONS_KEYPAD].ob_spec.free_string, TreeAddr[POPUP_KEYPAD][POPUP_KEYPAD_APPLICATION].ob_spec.free_string );
					else
						strcpy( DialogTree[Off+OPTIONS_KEYPAD].ob_spec.free_string, TreeAddr[POPUP_KEYPAD][POPUP_KEYPAD_NORMAL].ob_spec.free_string );
					DoRedraw( Dialog, &Rect, Off + OPTIONS_KEYPAD, Global );
				}
				break;
			}
/* -- Kategorie: Sonstiges ------------------------------------------------- */
			case	OPTIONS_KEY_EXPORT_TEXT:
			case	OPTIONS_KEY_EXPORT:
			{
				WORD	x, y, Selected;
				MT_objc_offset( DialogTree, Off + OPTIONS_KEY_EXPORT, &x, &y, Global );
				Selected = Popup( KeyExportPopup, OptData->KeyExport + 1, x, y, Global );
				if( Selected != -1 )
				{
					OptData->KeyExport = Selected - 1;
					strcpy( DialogTree[Off+OPTIONS_KEY_EXPORT].ob_spec.free_string, KeyExportPopup[Selected].ob_spec.free_string );
					DoRedraw( Dialog, &Rect, Off + OPTIONS_KEY_EXPORT, Global );
				}
				break;
			}
			case	OPTIONS_KEY_IMPORT_TEXT:
			case	OPTIONS_KEY_IMPORT:
			{
				WORD	x, y, Selected;
				MT_objc_offset( DialogTree, Off + OPTIONS_KEY_IMPORT, &x, &y, Global );
				Selected = Popup( KeyImportPopup, OptData->KeyImport + 1, x, y, Global );
				if( Selected != -1 )
				{
					OptData->KeyImport = Selected - 1;
					strcpy( DialogTree[Off+OPTIONS_KEY_IMPORT].ob_spec.free_string, KeyImportPopup[Selected].ob_spec.free_string );
					DoRedraw( Dialog, &Rect, Off + OPTIONS_KEY_IMPORT, Global );
				}
				break;
			}
			case	OPTIONS_TAB_TEXT:
				MT_wdlg_set_edit( Dialog, Off + OPTIONS_TAB_H, Global );
				break;
#endif
		}
	}
	return( 0 );
}

/* Handle..Options auf DialogData umstellen */

WORD	HandleDdOptions( DIALOG *Dialog, OPT_DATA *OptData, EVNT *Events, WORD Global[15] )
{
	if(( Events->mwhich & MU_MESAG ) && ( Events->msg[0] == AP_DRAGDROP || ( Events->msg[0] == WIN_CMD && Events->msg[4] == WIN_DRAGDROP )))
	{
		BYTE		*Url;
		if( Events->msg[0] == AP_DRAGDROP )
		{
			LONG	Size;
			ULONG	FormatRcvr[8], Format;
			FormatRcvr[0] = 'URLS';	FormatRcvr[1] = '.TXT';	FormatRcvr[2] = 'ARGS';	FormatRcvr[3] = 0;
			FormatRcvr[4] = 0;	FormatRcvr[5] = 0;	FormatRcvr[6] = 0;	FormatRcvr[7] = 0;
			if( GetDragDrop( Events, FormatRcvr, &Format, &Url, &Size ) != E_OK )
				return( E_OK );
		}
		if( Events->msg[4] == WIN_DRAGDROP )
		{
			DD_INFO	*DdInfo = *( DD_INFO ** )&( Events->msg[5] );
			if( DdInfo->format == 'URLS' || DdInfo->format == '.TXT' || DdInfo->format == 'ARGS' )
				Url = DdInfo->puf;
			else
				return( E_OK );
		}
#ifdef	TELNET_CLIENT
		if( strnicmp( Url, "telnet:", 7 ) == 0 )
		{
			TELNET	*Telnet = Url2Telnet( Url );
			if( !Telnet )
				return( ERROR );
			InsertTelnetOptions( Dialog, OptData, Telnet, Global );
			FreeTelnet( Telnet );
		}
		else		
			MT_form_alert( 1, TreeAddr[ALERTS][DD_NO_TELNET_URL].ob_spec.free_string, Global );
#endif
		free( Url );
		return( E_OK );
	}
	return( ERROR );
}
WORD	HandleMesagOptions( DIALOG *Dialog, OPT_DATA *OptData, EVNT *Events, WORD Global[15] )
{
	if( Events->msg[0] == FONT_CHANGED )
	{
#ifdef	IRC_CLIENT
		WORD	Off = GetInsertOffset( OptData->Tree ), a;
		OBJECT	*DialogTree;
		GRECT		Rect;
		EVNTDATA	Ev;
		MT_graf_mkstate( &Ev, Global );
 		MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
 		a = MT_objc_find( DialogTree, ROOT, MAX_DEPTH, Ev.x, Ev.y, Global );
		if( a == Off + OPTIONS_FONTNAME_OUTPUT )
 		{
			if( Events->msg[4] > 0 )
				OptData->OutputFontId = Events->msg[4];
			if( Events->msg[5] > 0 )
				OptData->OutputFontHt = (( LONG ) Events->msg[5] );
			GetFaceName( OptData->OutputFontId, OptData->OutputFontHt, VdiHandle, DialogTree[Off+OPTIONS_FONTNAME_OUTPUT].ob_spec.free_string );
			DoRedraw( Dialog, &Rect, Off + OPTIONS_FONTNAME_OUTPUT, Global );
 		}
		else	if( a == Off + OPTIONS_FONTNAME_INPUT )
		{
			if( Events->msg[4] > 0 )
				OptData->InputFontId = Events->msg[4];
			if( Events->msg[5] > 0 )
				OptData->InputFontHt = (( LONG ) Events->msg[5] );
			GetFaceName( OptData->InputFontId, OptData->InputFontHt, VdiHandle, DialogTree[Off+OPTIONS_FONTNAME_INPUT].ob_spec.free_string );
			DoRedraw( Dialog, &Rect, Off + OPTIONS_FONTNAME_INPUT, Global );
		}
		else	if( a == Off + OPTIONS_FONTNAME_CHANNEL )
		{
			if( Events->msg[4] > 0 )
				OptData->ChannelFontId = Events->msg[4];
			if( Events->msg[5] > 0 )
				OptData->ChannelFontHt = (( LONG ) Events->msg[5] );
			GetFaceName( OptData->ChannelFontId, OptData->ChannelFontHt, VdiHandle, DialogTree[Off+OPTIONS_FONTNAME_CHANNEL].ob_spec.free_string );
			DoRedraw( Dialog, &Rect, Off + OPTIONS_FONTNAME_CHANNEL, Global );
		}
		else	if( a == Off + OPTIONS_FONTNAME_USER )
		{
			if( Events->msg[4] > 0 )
				OptData->UserFontId = Events->msg[4];
			if( Events->msg[5] > 0 )
				OptData->UserFontHt = (( LONG ) Events->msg[5] );
			GetFaceName( OptData->UserFontId, OptData->UserFontHt, VdiHandle, DialogTree[Off+OPTIONS_FONTNAME_USER].ob_spec.free_string );
			DoRedraw( Dialog, &Rect, Off + OPTIONS_FONTNAME_USER, Global );
		}
		else
			return( ERROR );
		return( E_OK );
#endif
#ifdef	TELNET_CLIENT
		if( !isMonospaceFont( Events->msg[4] ))
			MT_form_alert( 1, TreeAddr[ALERTS][FONT_NOT_MONO].ob_spec.free_string, Global );
		else
		{
			OBJECT	*DialogTree;
			GRECT		Rect;
			WORD	Off = GetInsertOffset( OptData->Tree );
			MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
			if( Events->msg[4] > 0 )
				OptData->FontId = Events->msg[4];
			if( Events->msg[5] > 0 )
				OptData->FontPt = (( LONG ) Events->msg[5] ) << 16;
			if( Events->msg[6] != -1 )
				OptData->FontColorUserBlk.ub_parm = Events->msg[6];
			GetFaceName( OptData->FontId, OptData->FontPt, VdiHandle, OptData->DialogTree[Off+OPTIONS_FONTNAME].ob_spec.free_string );
			if( OptData->Kat == OPT_VIEW )
				DoRedrawX( Dialog, &Rect, Global, Off+OPTIONS_FONTNAME, Off+OPTIONS_FONTCOLOR, EDRX );
		}
		return( E_OK );
#endif
	}
	else	if( Events->msg[0] == COLOR_ID )
	{
		WORD	Off = GetInsertOffset( OptData->Tree ), a;
		OBJECT	*DialogTree;
		GRECT		Rect;
 		MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
 		a = MT_objc_find( DialogTree, ROOT, MAX_DEPTH, Events->msg[3], Events->msg[4], Global );
#ifdef	IRC_CLIENT
/* Klick auf Userdef simulieren und entsprechende Farbe setzen */
		if( a == Off + OPTIONS_CTEXT || a == Off + OPTIONS_CBOX )
		{
			WORD	i;
			EVNT	lEvents;
			lEvents.mclicks = 1;
			lEvents.mx = Events->msg[3];
			lEvents.my = Events->msg[4];
			mt_list_evnt( DialogTree, Off + OPTIONS_CTEXT, MT_wdlg_get_handle( Dialog, Global ), &lEvents, Global );
			mt_list_evnt( DialogTree, Off + OPTIONS_CBOX, MT_wdlg_get_handle( Dialog, Global ), &lEvents, Global );
			if(( i = mt_list_get_selected( DialogTree, Off + OPTIONS_CTEXT, Global )) != -1 || 
    			( i = mt_list_get_selected( DialogTree, Off + OPTIONS_CBOX, Global )) != -1 )
			{
				mt_list_set_colourtable( DialogTree, Off + OPTIONS_CBOX, Events->msg[5], i, Global );
				mt_list_set_selected( DialogTree, Off + OPTIONS_CTEXT, MT_wdlg_get_handle( Dialog, Global ), -1, Global );
				mt_list_set_selected( DialogTree, Off + OPTIONS_CBOX, MT_wdlg_get_handle( Dialog, Global ), -1, Global );
			}
			return( E_OK );
		}
		return( E_OK );
#endif
#ifdef	TELNET_CLIENT
 		if( a == Off + OPTIONS_FONTCOLOR_TEXT || a == Off + OPTIONS_FONTCOLOR || a == OPTIONS_FONTNAME )
 		{
			OptData->FontColorUserBlk.ub_parm = Events->msg[5];
			DoRedraw( Dialog, &Rect, Off+OPTIONS_FONTCOLOR, Global );
 		}
 		else	if( a == Off + OPTIONS_WINDOWCOLOR_TEXT || a == Off + OPTIONS_WINDOWCOLOR )
		{
			OptData->WindowColorUserBlk.ub_parm = Events->msg[5];
			DoRedraw( Dialog, &Rect, Off+OPTIONS_WINDOWCOLOR, Global );
		}
		else
			return( ERROR );
#endif
		return( E_OK ); 		
	}
	return( ERROR );
}

WORD	HandleHelpOptions( DIALOG *Dialog, OPT_DATA *OptData, EVNT *Events, WORD Global[15] )
{
	OBJECT	*DialogTree;
	GRECT		Rect;
	WORD	Off = GetInsertOffset( OptData->Tree ), Obj;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	Obj = MT_objc_find( DialogTree, ROOT, MAX_DEPTH, Events->mx, Events->my, Global );
	if( Obj != -1 )
	{
		if( Obj >= Off )
		{
			if( BG_Action( TreeAddr[OPTIONS], OPTIONS, Obj - Off, Events->mx, Events->my, Global ) == E_OK )
				return( E_OK );
		}
		else
		{
			if( BG_Action( OptData->Tree, OptData->TreeIdx, Obj, Events->mx, Events->my, Global ) == E_OK )
				return( E_OK );
		}
	}
	return( ERROR );	
}

void	ChangeFontOptions( DIALOG *Dialog, OPT_DATA *OptData, WORD FontId, LONG FontPt, WORD FontColor, WORD Global[15] )
{
	OBJECT	*DialogTree;
	GRECT		Rect;
	WORD	Off = GetInsertOffset( OptData->Tree );
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );

#ifdef	TELNET_CLIENT
	OptData->FontId = FontId;
	OptData->FontPt = FontPt;
	OptData->FontColorUserBlk.ub_parm = FontColor;
	GetFaceName( OptData->FontId, OptData->FontPt, VdiHandle, OptData->DialogTree[Off+OPTIONS_FONTNAME].ob_spec.free_string );
	if( OptData->Kat == OPT_VIEW )
		DoRedrawX( Dialog, &Rect, Global, Off+OPTIONS_FONTNAME, Off+OPTIONS_FONTCOLOR, EDRX );
#endif
}

static void	SetEdit( DIALOG *Dialog, OPT_DATA *OptData, WORD Global[15] )
{
	OBJECT	*DialogTree;
	GRECT		Rect;
	WORD		IdxOff, Cursor;
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	IdxOff = GetInsertOffset( OptData->Tree );
#ifdef	IRC_CLIENT
	switch( OptData->Kat )
	{
		case	OPT_SESSION:
			if( !( DialogTree[IdxOff+OPTIONS_HOST].ob_state & DISABLED ))
				MT_wdlg_set_edit( Dialog, IdxOff + OPTIONS_HOST, Global );
			else	if( !( DialogTree[IdxOff+OPTIONS_PORT].ob_state & DISABLED ))
				MT_wdlg_set_edit( Dialog, IdxOff + OPTIONS_PORT, Global );
			else	if( !( DialogTree[IdxOff+OPTIONS_NICKNAME].ob_state & DISABLED ))
				MT_wdlg_set_edit( Dialog, IdxOff + OPTIONS_NICKNAME, Global );
/*			else	if( !( DialogTree[IdxOff+OPTIONS_PASSWORD].ob_state & DISABLED ))
				MT_wdlg_set_edit( Dialog, IdxOff + OPTIONS_PASSWORD, Global );
*/			else	if( !( DialogTree[IdxOff+OPTIONS_REALNAME].ob_state & DISABLED ))
				MT_wdlg_set_edit( Dialog, IdxOff + OPTIONS_REALNAME, Global );
			else
				MT_wdlg_set_edit( Dialog, 0, Global );
			break;
		case	OPT_OTHER:
			MT_wdlg_set_edit( Dialog, IdxOff + OPTIONS_NLINES, Global );
			break;
		default:
			MT_wdlg_set_edit( Dialog, 0, Global );
			break;
	}
#endif
#ifdef	TELNET_CLIENT
	switch( OptData->Kat )
	{
		case	OPT_VIEW:
			MT_wdlg_set_edit( Dialog, IdxOff + OPTIONS_PUFLINES, Global );
			break;
		case	OPT_TELNET:
			if( !( DialogTree[IdxOff+OPTIONS_HOST].ob_state & DISABLED ))
				MT_wdlg_set_edit( Dialog, IdxOff + OPTIONS_HOST, Global );
			else	if( !( DialogTree[IdxOff+OPTIONS_PORT].ob_state & DISABLED ))
				MT_wdlg_set_edit( Dialog, IdxOff + OPTIONS_PORT, Global );
			else
				MT_wdlg_set_edit( Dialog, 0, Global );
			break;
		case	OPT_TERMINAL:
			OptData->Edit = IdxOff + OPTIONS_COLUMNS;
			MT_wdlg_set_edit( Dialog, IdxOff + OPTIONS_COLUMNS, Global );
			break;
		case	OPT_OTHER:
			OptData->Edit = IdxOff + OPTIONS_TAB_H;
			MT_wdlg_set_edit( Dialog, IdxOff + OPTIONS_TAB_H, Global );
			break;
		default:
			OptData->Edit = 0;
			MT_wdlg_set_edit( Dialog, 0, Global );
	}
#endif
}

#ifdef	IRC_CLIENT
static void	InsertTelnetOptions( DIALOG *Dialog, OPT_DATA *OptData, IRC *Irc, WORD Global[15] )
#endif
#ifdef	TELNET_CLIENT
static void	InsertTelnetOptions( DIALOG *Dialog, OPT_DATA *OptData, TELNET *Telnet, WORD Global[15] )
#endif
{
	OBJECT	*DialogTree;
	GRECT		Rect;
	WORD		Off = GetInsertOffset( OptData->Tree );
	WORD		Cursor, Edit;
	Edit = MT_wdlg_get_edit( Dialog, &Cursor, Global );
	MT_wdlg_set_edit( Dialog, 0, Global );
	MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
	if( DialogTree[Off+OPTIONS_HOST].ob_flags & EDITABLE )
	{
#ifdef	IRC_CLIENT
		if( Irc->Host )
			strcpy( DialogTree[Off+OPTIONS_HOST].ob_spec.tedinfo->te_ptext, Irc->Host );
		else
			strcpy( DialogTree[Off+OPTIONS_HOST].ob_spec.tedinfo->te_ptext, "" );
#endif
#ifdef	TELNET_CLIENT
		if( Telnet->Host )
			strcpy( DialogTree[Off+OPTIONS_HOST].ob_spec.tedinfo->te_ptext, Telnet->Host );
		else
			strcpy( DialogTree[Off+OPTIONS_HOST].ob_spec.tedinfo->te_ptext, "" );
#endif
	}
	if( DialogTree[Off+OPTIONS_PORT].ob_flags & EDITABLE )
#ifdef	IRC_CLIENT
		sprintf( DialogTree[Off+OPTIONS_PORT].ob_spec.tedinfo->te_ptext, "%u", Irc->Port );
#endif
#ifdef	TELNET_CLIENT
		sprintf( DialogTree[Off+OPTIONS_PORT].ob_spec.tedinfo->te_ptext, "%u", Telnet->Port );
#endif
	DoRedrawX( Dialog, &Rect, Global, Off+OPTIONS_HOST, Off+OPTIONS_PORT, EDRX );
	MT_wdlg_set_edit( Dialog, Edit, Global );
}

static WORD	cdecl ColorUbCode( PARMBLK *ParmBlock )
{
	WORD	Cxy[4], Pxy[4];

	Cxy[0] = ParmBlock->pb_xc;
	Cxy[1] = ParmBlock->pb_yc;
	Cxy[2] = Cxy[0] + ParmBlock->pb_wc - 1;
	Cxy[3] = Cxy[1] + ParmBlock->pb_hc - 1;
	vs_clip( VdiHandle, 1, Cxy );

	vswr_mode( VdiHandle, MD_REPLACE );
	vsf_perimeter( VdiHandle, 0 );
	vsf_interior( VdiHandle, FIS_SOLID );

	Pxy[0] = ParmBlock->pb_x + 1;
	Pxy[1] = ParmBlock->pb_y + 1;
	Pxy[2] = Pxy[0] + ParmBlock->pb_w - 3;
	Pxy[3] = Pxy[1] + ParmBlock->pb_h - 3;

	vsf_color( VdiHandle, ( WORD ) ParmBlock->pb_parm );
	v_bar( VdiHandle, Pxy );

	vs_clip( VdiHandle, 0, Cxy );
	return( 0 );
}

static void	GetFaceName( WORD FontId, LONG FontPt, WORD VdiHandle, BYTE *Puf )
{
	WORD	i;
	BYTE	Name[33], Pt[10];
	vst_load_fonts( VdiHandle, 0 );
	for( i = 1; i < nFont; i++ )
	{
		if( vqt_name( VdiHandle, i, Name ) == FontId )
		{
			strcpy( Puf, Name );
#ifdef	IRC_CLIENT
			itoa( ( WORD )( FontPt ), Pt, 10 );
#endif
#ifdef	TELNET_CLIENT
			itoa( ( WORD )( FontPt >> 16 ), Pt, 10 );
#endif
			if(( i = ( WORD ) strlen( Puf )) == 31 )
			{
				*strrchr( Puf, ' ' ) = 0;
				i = ( WORD ) strlen( Puf );
			}
			while( i < 38 - strlen( Pt ) - 2 )
				Puf[i++] = ' ';
			Puf[i] = 0;
			strcat( Puf, Pt );
			strcat( Puf, "pt" );
			return;
		}
	}
	strcpy( Puf, "" );
}

#ifdef	IRC_CLIENT
static void	SetCSlider( OPT_DATA *OptData, DIALOG *Dialog, WORD Global[15] )
{
	WORD	Off = GetInsertOffset( OptData->Tree );
	LONG	nLines, yScroll;
	WORD	yVis, nCols, xScroll, xVis;
	WORD	Oldy = OptData->DialogTree[Off+OPTIONS_CBOX_SLDR].ob_y;
	WORD	OldHeight = OptData->DialogTree[Off+OPTIONS_CBOX_SLDR].ob_height;

	mt_list_get_scrollinfo( OptData->DialogTree, Off+OPTIONS_CTEXT, &nLines, &yScroll, &yVis, &nCols, &xScroll, &xVis, Global );

	OptData->DialogTree[Off+OPTIONS_CBOX_SLDR].ob_height = OptData->DialogTree[Off+OPTIONS_CBOX_SLDR_BACK].ob_height * yVis / nLines + 1;
	OptData->DialogTree[Off+OPTIONS_CBOX_SLDR].ob_y = OptData->DialogTree[Off+OPTIONS_CBOX_SLDR_BACK].ob_height * yScroll / nLines;

	if( OptData->DialogTree[Off+OPTIONS_CBOX_SLDR].ob_height > OptData->DialogTree[Off+OPTIONS_CBOX_SLDR_BACK].ob_height + 1)
		OptData->DialogTree[Off+OPTIONS_CBOX_SLDR].ob_height = OptData->DialogTree[Off+OPTIONS_CBOX_SLDR_BACK].ob_height + 1;
	if( Dialog &&( OptData->DialogTree[Off+OPTIONS_CBOX_SLDR].ob_height != OldHeight || OptData->DialogTree[Off+OPTIONS_CBOX_SLDR].ob_y != Oldy ))
	{
		OBJECT	*DialogTree;
		GRECT		Rect;
		MT_wdlg_get_tree( Dialog, &DialogTree, &Rect, Global );
		DoRedraw( Dialog, &Rect, Off+OPTIONS_CBOX_SLDR_BACK, Global );
	}
}
#endif