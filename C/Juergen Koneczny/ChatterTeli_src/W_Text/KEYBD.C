#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<STDDEF.H>
#include	<stdio.h>

#include	<atarierr.h>

#include	"..\Emulator.h"
#include	"..\Window.h"
#include	"..\W_Text.h"
#include	"Keybd.h"

#include	"..\MapKey.h"
#include	"..\KEYTAB.h"

extern KEYT *Keytab;

WORD	HandleMuKeybdTextWindow( WORD WinId, EVNT *Events, TEXT_WINDOW *TextWindow, WORD Global[15] )
{
	WORD	Key = MapKey( Events->key );
	WORD	Char = Key & 0x00ff;
	if((( Key & KbALT ) || ( Key & KbCONTROL )) && ( Key & KbSHIFT ))
		return( ERROR );
	else	if(( Key & KbSCAN ) || ( Key & KbNUM ) || Char == '\t' )
	{
		CTRL_SEQ	*Ctrl = EMU_GetCtrl( Key, TextWindow->EmuData );
		Events->mwhich &= ~MU_KEYBD;
		if( Ctrl )
		{
			EVNT	lEvents;
			DD_INFO	DdInfo;
			DdInfo.format = '.TXT';
			DdInfo.mx = -1;
			DdInfo.my = -1;
			DdInfo.kstate = -1;
			DdInfo.puf = Ctrl->Seq;
			DdInfo.size = Ctrl->Len;
			lEvents.mwhich = MU_MESAG;
			lEvents.msg[0] = WIN_CMD;
			lEvents.msg[1] = Global[2];
			lEvents.msg[2] = 0;
			lEvents.msg[3] = WinId;
			lEvents.msg[4] = WIN_DRAGDROP;
			*( DD_INFO ** )&( lEvents.msg[5] ) = &DdInfo;
			TextWindow->HandleUserTextWindow( WinId, &lEvents, TextWindow->UserData, Global );
			return( E_OK );
		}
		else
			return( ERROR );
	}
	else
	{
		EVNT	lEvents;
		WORD	Char = Events->key & 0x00ff;
		Events->mwhich &= ~MU_KEYBD;
		lEvents.mwhich = MU_MESAG;
		lEvents.msg[0] = WIN_CMD;
		lEvents.msg[1] = Global[2];
		lEvents.msg[2] = 0;
		lEvents.msg[3] = WinId;
		lEvents.msg[4] = WIN_KEY;
		lEvents.msg[5] = ( WORD ) Keytab->ExportChar( TextWindow->KeyExport, Char );
		return( TextWindow->HandleUserTextWindow( WinId, &lEvents, TextWindow->UserData, Global ));
	}
}