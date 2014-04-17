/* DEFINES
 *==========================================================================
 */
#define NO_WINDOW 	( -1 )


/* GLOBALS
 *==========================================================================
 */
extern WINFO	w;


/* PROTOTYPES
 *==========================================================================
 */
void	init_window( void );
void	Wm_Redraw( int *msg );
void	Wm_Topped( int *msg );
void	Wm_Closed( int *msg );
void	Wm_Moved( int *msg );
BOOLEAN Create_Window( void );
void	open_window( void );
void	do_redraw( OBJECT *tree, GRECT *prect );
void	GrowShrinkBox( BOOLEAN flag );
void	Send_Redraw( GRECT *rect );
