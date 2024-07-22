/*
****************************************************************************
** MACROS
****************************************************************************
*/
#define minimum(a, b)	((a) < (b) ? (a) : (b))
#define maximum(a, b)	((a) > (b) ? (a) : (b))
/*
****************************************************************************
** Function prototypes
****************************************************************************
*/

int		open_window( OBJECT *tree );
void	kill_window( int handle );
void	redraw_window( int handle ,int object,GRECT *work);
int		rc_intersect( GRECT *r1, GRECT *r2 );
void	mouse_on( void );
void	mouse_off( void );
/*
****************************************************************************
** Variables
****************************************************************************
*/

extern	char	title[];

extern	int		max_x,max_y;
