void	InitPopUpMenus( void );
int     InsertPopUpMenu( char *text, int num_entries, int height );
void	DeletePopUpMenu( int MenuID );

long    PopUpMenuSelect( int MenuID, int xpos, int ypos, int Item );


/* APPEARANCE OF ITEMS */
void	SetHeight( int MenuID, int Height );
void	SetNumItems( int MenuID, int NumItems );

void	CheckItem( int MenuID, int item, BOOLEAN check );
void	DisableItem( int MenuID, int item );
void	EnableItem( int MenuID, int item );

void	SetItemCmd( int MenuID, int item, char cmd );
char	GetItemCmd( int MenuID, int item );

void	SetSubMenuID( int MenuID, int item, int ID );
int	GetSubMenuID( int MenuID, int item );

void	SetItemMark( int MenuID, int item, char key );
char    GetItemMark( int MenuID, int item );
 
void	SetFuncMark( int MenuID, int item, int num );
int 	GetFuncMark( int MenuID, int item );

void	SetItem( int MenuID, int item, char *text );
char	*GetItem( int MenuID, int item );

int	GetStartItem( int MenuID );
void	SetStartItem( int MenuID, int item );


void	SetSubMenuDelay( long ms );
void	SetSubDragDelay( long ms );
void	SetArrowClickDelay( long ms );
long    MenuChoice( void );
