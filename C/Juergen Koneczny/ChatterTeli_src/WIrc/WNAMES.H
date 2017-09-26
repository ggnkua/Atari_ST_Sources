WORD	OpenNamesWindow( IRC_CHANNEL *IrcChannel, WORD Global[15] );
WORD	NamesWindowAppend( IRC_CHANNEL *IrcChannel, WORD Flag, BYTE *Nickname, BYTE *Username, BYTE *Realname, BYTE *Channels, BYTE *Server, BYTE *Host, BYTE *Idle, WORD Colour, WORD Global[15] );
void	NamesWindowWhois( IRC_CHANNEL *IrcChannel, WORD Global[15] );
WORD	IsInNamesWindow( IRC_CHANNEL *IrcChannel, BYTE *Nickname, WORD *Colour, WORD Global[15] );
void	NamesWindowDelete( IRC_CHANNEL *IrcChannel, BYTE *Nickname, WORD Global[15] );
void	NamesWindowReset( IRC_CHANNEL *IrcChannel, WORD Global[15] );
void	NamesWindowRedraw( IRC_CHANNEL *IrcChannel, WORD Global[15] );
