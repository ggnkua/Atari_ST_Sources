#define	COLUMNS	10

void	*ListCreate( int nColumns );
void	ListDelete( void *L );
void	ListDeleteItem( void *L, long n );
int	ListAttachItem( void *L, char *Item[], int Colour, int SortFlag );
long	ListGetnItem( void *L );
int	ListGetSort( void *L );
char	**ListGetItem( void *L, long n, int *Colour );
void	ListSetSort( void *L, int Sort );
void	ListSetSelected( void *L, long n, int selected );
int	ListSelected( void *L, long n );