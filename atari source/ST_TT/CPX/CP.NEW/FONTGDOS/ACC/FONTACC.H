/* PROTOTYPES 
 * ===============================================================
 */
void	 initialize( void );
int	 handle_button( int button, WORD *msg );
int	 handle_front( int button, WORD *msg );
int	 Handle_Menu( int button, WORD *msg );
void	 DoActiveFonts( void );

void	 Reset_Tree( OBJECT *tree );

int	 open_vwork( void );
void	 close_vwork( void );

void	 MF_Save( void );
void	 MF_Restore( void );
void	 Scan_Message( OBJECT *Tree, BOOLEAN flag );

void	 DeviceUpDown( int button );
void	 SetupDriverFonts( DEV_PTR device );
void	 strip_period( char *text );
void	 ClearDriverFontList( void );
void	 SortDriverFonts( int num );
void	 Remove_Fonts( void );

void	 RestoreMainTree( void );

void	 ClearChangeFlag( void );
void	 SetChangeFlag( void );
BOOLEAN	 IsChangeFlag( void );
 
void	 CloseWindow( void );


/* CHOOSER tree routines */
void	 InitDriverNames( void );
void	 DoDrivers( void );
long	 get_cookie( void );



/* EXTERNS
 * ===============================================================
 */
extern char device_text[];		/* Text to display device number */
extern char driver_text[];		/* Text to display driver name   */
extern int  Item;
