WORD	OpenIrcChatWindow( IRC_CHANNEL *IrcChannel, WORD Global[15] );


void	IrcWindowSetInfo( IRC_CHANNEL *IrcChannel, BYTE *Str, WORD Global[15] );
WORD	IrcWindowAppend( IRC_CHANNEL *IrcChannel, BYTE *Msg, WORD Colour, WORD Global[15] );
void	IrcWindowRedraw( IRC_CHANNEL *IrcChannel, WORD Global[15] );
