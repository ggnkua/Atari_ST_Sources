#include	<mt_mem.h>
#include	<PORTAB.H>
#include	<TOS.H>
#include	<VDICOL.H>
#include	<MT_AES.H>
#include	<STDDEF.H>
#include	<STDARG.H>
#include	<STDLIB.H>

#include	<atarierr.h>

#include	"main.h"
#include	RSCHEADER
#include	"DragDrop.h"
#include	"DD.h"

extern OBJECT	**TreeAddr;

WORD	GetDragDrop( EVNT *Events, ULONG	FormatRcvr[8], ULONG *Format, BYTE **RetPuf, LONG *Size )
{
	void	*OldSig;
	WORD	Fd, Ret = ERROR;
	BYTE	Pipename[] = "U:\\PIPE\\DRAGDROP.AA", Name[255];

	Pipename[18] = Events->msg[7] & 0x00ff;
	Pipename[17] = ( Events->msg[7] & 0xff00 ) >> 8;

	if(( Fd = ddopen( Pipename, FormatRcvr, &OldSig )) != -1 )
	{
		while( ddrtry( Fd, Name, Format, Size) == 1 )
		{
			if( *Format == FormatRcvr[0] || *Format == FormatRcvr[1] || *Format == FormatRcvr[2] || *Format == FormatRcvr[3] ||
			    *Format == FormatRcvr[4] || *Format == FormatRcvr[5] || *Format == FormatRcvr[6] || *Format == FormatRcvr[7] )
			{
				*RetPuf = malloc(( *Size ) * sizeof( BYTE ) + 1 );
				if( *RetPuf )
				{
					ddreply( Fd, DD_OK );
					Fread( Fd, *Size, *RetPuf );
					( *RetPuf )[*Size] = 0;
					if( *Format == 'ARGS' )
						parse_ARGS( *RetPuf );
					Ret = E_OK;
					break;
				}
				else
					Ret = ENSMEM;
				break;
			}
			else
				if( !ddreply( Fd, DD_EXT ))
					break;
				
		}
		ddclose( Fd, OldSig );
	}
	return( Ret );
}

WORD	PutDragDrop( WORD WinId, WORD X, WORD Y, WORD Key, WORD AppId, ULONG Format, BYTE *Puf, LONG Size, WORD Global[15] )
{
	ULONG	FormatRcvr[8];
	void	*OldSig;
	WORD	Fd;
	if(( Fd = ddcreate( Global[2], AppId, WinId, X, Y, Key, FormatRcvr, &OldSig, Global )) >= 0 )
	{
		if( ddstry( Fd, Format, "", Size ) == DD_OK )
		{
			if( Fwrite( Fd, Size, Puf ) > 0 )
			{
				ddclose( Fd, OldSig );
				return( E_OK );
			}
		}
		else
			MT_form_alert( 1, TreeAddr[ALERTS][DD_FAILED].ob_spec.free_string, Global );
		ddclose( Fd, OldSig );
	}
	else
		MT_form_alert( 1, TreeAddr[ALERTS][DD_NO].ob_spec.free_string, Global );
	return( E_OK );
}

void	NoDragDrop( EVNT *Events )
{
	BYTE	Pipename[] = "U:\\PIPE\\DRAGDROP.AA";
	WORD	Fd;
	Pipename[18] = Events->msg[7] & 0x00ff;
	Pipename[17] = ( Events->msg[7] & 0xff00 ) >> 8;
	Fd = ( WORD ) Fopen (Pipename, 2);
	if (Fd >= 0)
	{
		BYTE c = DD_NAK;
		Fwrite ((WORD) Fd, 1, &c);
		Fclose ((WORD) Fd);
	}
}