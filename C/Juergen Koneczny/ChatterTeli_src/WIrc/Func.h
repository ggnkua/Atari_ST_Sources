#ifndef	__WIRC_FUNC__
#define	__WIRC_FUNC__

WORD	ColourTablePopup( WORD ColourTable[COLOUR_MAX], WORD Global[15] );
void	GetFilename( BYTE *Dirname, BYTE *Filename, BYTE **Path, BYTE **HomePath, BYTE **DefaultPath );
void	ShortFilename( BYTE *Filename );
void	ShortFileStrCpy( BYTE *Dest, BYTE *Source, WORD Len );
void	PlaceIntelligent( GRECT *Pos );

typedef	struct	__mod_win__
{
	struct __mod_win__	*next;
	struct __mod_win__	*prev;
	WORD	WinId;
	WORD	Type;
}	MOD_WIN;

#endif