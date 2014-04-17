/* WINDOWS.H
 *==========================================================================
 * Prototypes, Defines and Externs 
 *
 * Parent File: WINDOWS.C
 */
 
/* PROTOTYPES
 *==========================================================================
 */
void	init_window( void );
void    Wm_Redraw( int *msg );
void    Wm_Topped( int *msg );
void    Wm_Closed( int *msg );
void	Wm_Moved( int *msg );
 
BOOLEAN open_window( void );
void    do_redraw( OBJECT *tree, int object, GRECT *rect );
 
void	Send_Redraw( GRECT *rect );
 
/* DEFINES
 *==========================================================================
 */
#define NO_WINDOW 	( -1 )
 

/* EXTERNS
 *==========================================================================
 */
extern WINFO    w;
   