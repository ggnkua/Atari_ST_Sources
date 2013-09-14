extern FON_PTR hdptr;
extern FON_PTR Active_Slit[];
extern FON  Point_Arena[];	/* Arena for the Scrolling of point sizes */
extern FON_PTR  Temp_Fon;
extern int   Cur_Slit, Old_Slit;
extern char fblank[];
extern char fblank2[];
extern int First_Obj;			/* First Object in Scroll Area : ie: LINE0 */

void	mover_setup( FON_PTR list_ptr, int font_count,
		     int base, int slider, int up, int down,
		     int first_obj, int last_obj, int base_obj,
		     int start_index, int num_rows );

BOOLEAN IsChanged( FON_PTR ptr );

void 	mover_button( int obj, int clicks );
void	Undo_Fnodes( FON_PTR ptr, FON_PTR flag );
int	Get_Findex( FON_PTR tptr, FON_PTR ptr );
int	FindNumSelected( FON_PTR ptr );
FON_PTR	FindFirstFont( FON_PTR ptr );
void	ClearFnodes( FON_PTR ptr );

void	CheckHotFront( FON_PTR Head_Node );
void	CheckHotAvailable( FON_PTR Head_Node );
void	CheckHotCustom( void );
