WORD	cdecl OpenChannelWindow( IRC_CHANNEL *IrcChannel, WORD Flag, WORD Global[15] );
void	ChannelWindowUpdate( IRC_CHANNEL *IrcChannel, WORD Global[15] );
void	ChannelWindowRedraw( IRC_CHANNEL *IrcChannel, WORD Global[15] );
WORD	cdecl ChannelWindowCheckDisable( IRC_CHANNEL *IrcChannel, WORD Global[15] );

