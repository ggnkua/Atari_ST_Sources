WORD	NewWindow( WORD WinId, WORD AppId, WORD Global[15] );
void	DelWindow( WORD WinId, WORD Global[15] );
WORD	GetAppIdWindow( WORD WinId );
WORD	GetFirstWindow( void );
WORD	GetNextWindow( WORD WinId );
void	IconifyWindow( WORD WinId );
void	AllIconifyWindow( WORD WinId );
void	UnIconifyWindow( WORD WinId );
void	UnAllIconifyWindow( WORD WinId );
WORD	isWindow( WORD WinId );
WORD	isIconifiedWindow( WORD WinId );
WORD	isAllIconifiedWindow( WORD WinId );
#ifdef	GEMScript
void	SetTopWindow( WORD WinId );
WORD	GetTopWindow( void );
#endif