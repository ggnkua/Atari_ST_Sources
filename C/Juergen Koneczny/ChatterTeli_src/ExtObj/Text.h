void	*TextCreate( void );
void	TextDelete( void *T );
void	TextDeleteLine( void *T, long n );
int	TextAttachLine( void *T, char *String, int Colour );
char	*TextGetLine( void *T, long n, int *Colour );
long	TextGetnLines( void *T );
