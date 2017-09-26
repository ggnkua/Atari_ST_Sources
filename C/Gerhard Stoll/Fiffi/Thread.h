void	cdecl WaitThreadAppId( LONG Pid );
typedef	WORD cdecl threadfun( long arg );
int	DOThread (threadfun *fun, long arg, long stksize, char *name );

