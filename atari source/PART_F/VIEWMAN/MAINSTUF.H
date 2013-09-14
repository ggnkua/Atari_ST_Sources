/* PROTOTYPES
 * ================================================================
 */
int  execform( OBJECT *tree, int start_obj );
void do_redraw( int handle, GRECT *clip );
void do_file( int type );
void Graf_Mouse( int item );
void Send_Redraw( WINFO *x );
void Set_Brush_Path( void );
void World_Check( void );
void EatKeyboard( void );

/* EXTERN
 * ================================================================
 */
extern char Brush_Path[];
