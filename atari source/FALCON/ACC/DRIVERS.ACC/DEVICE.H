/* PROTOTYPES 
 * ===============================================================
 */
void	 initialize( void );
int	 handle_front( int button, WORD *msg );
int	 open_vwork( void );
void	 close_vwork( void );
void	 MF_Save( void );
void	 MF_Restore( void );
void	 Scan_Message( OBJECT *Tree, BOOLEAN flag );
void	 CloseWindow( void );

/* CHOOSER tree routines */
void	 InitDriverNames( void );
long	 get_cookie( void );
void	 ChangeButton( OBJECT *tree, int obj, int flag );


void	 ClearChangeFlag( void );
void	 SetChangeFlag( void );
BOOLEAN	 IsChangeFlag( void );
void	 SetDevices( void );


void	 RestoreMainTree( void );
void	 Reset_Tree( OBJECT *tree );
extern char driver_text[];		/* Text to display driver name   */

