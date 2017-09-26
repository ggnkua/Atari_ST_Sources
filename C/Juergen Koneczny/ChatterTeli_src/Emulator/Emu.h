#ifndef	__EMU__
#define	__EMU__
#include	"Emulator.h"

/*-----------------------------------------------------------------------------*/
/* Funktions-Typedefs                                                          */
/*-----------------------------------------------------------------------------*/
typedef long ( *EMU_DO )( char *Text, long Len, EMU_DATA *EmuData );
typedef CTRL_SEQ *( *EMU_Ctrl )( int Key, int Flag );

/*-----------------------------------------------------------------------------*/
/* Strukturdefinitionen                                                        */
/*-----------------------------------------------------------------------------*/
typedef	struct
{
	EMU_DO	Do;
	EMU_Ctrl	Ctrl;
}	EMU_FUNC;

void		EMU_NewScreen( EMU_DATA *EmuData );

TEXTLINE	*EMU_InsertLine( long n, EMU_DATA *EmuData );
void		EMU_DeleteLine( long n, EMU_DATA *EmuData );
void		EMU_ScrollLines( XY *S, long D, EMU_DATA *EmuData );

void	EMU_DeleteChar( XY *Start, XY *End, EMU_DATA *EmuData );

int	EMU_IsScroll( EMU_DATA *EmuData, XY *S );

void	AppendAttribut( ATTR *Attr, ATTR_ITEM **List );
void	DeleteAttribut( int A, ATTR_ITEM **List );
void	FreeAttribut( ATTR_ITEM	**List );

void	AppendXyItem( XY *Start, XY *End, EMU_DATA *EmuData );

CTRL_SEQ	*MakeCtrlSeq( char *Seq );

/*
typedef	SECTION ( *_EMU_GetLine )( long n, EMU_DATA *EmuData );
typedef	long ( *_EMU_GetNLine )( EMU_DATA *EmuData );
typedef	long ( *_EMU_GetNCharMax )( EMU_DATA *EmuData );
typedef	long ( *_EMU_GetNCharLine )( long Line, EMU_DATA *EmuData );
typedef	int ( *_EMU_AddChar )( char Char, EMU_DATA *EmuData );
typedef	int ( *_EMU_AddStr )( char *Text, EMU_DATA *EmuData );
*/

#endif