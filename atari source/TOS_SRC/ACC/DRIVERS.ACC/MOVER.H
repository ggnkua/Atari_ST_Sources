extern HDEVICE_PTR hdptr;
extern HDEVICE_PTR Active_Slit[];
extern int   Cur_Slit, Old_Slit;
extern char fblank[];
extern char fblank2[];
extern char fblank3[];
extern int First_Obj;			/* First Object in Scroll Area : ie: LINE0 */
extern DEV_PTR device_ptr;
extern DEV_PTR Device_Slit[];

void	mover_setup( HDEVICE_PTR list_ptr, int font_count,
		     int base, int slider, int up, int down,
		     int first_obj, int last_obj, int base_obj,
		     int start_index, int num_slits );

BOOLEAN IsChanged( HDEVICE_PTR ptr );

void 	mover_button( int obj );
void	Undo_Fnodes( HDEVICE_PTR ptr );
int	Get_Findex( HDEVICE_PTR tptr, HDEVICE_PTR ptr );

void	device_mover_setup( DEV_PTR list_ptr, int font_count,
		     int base, int slider, int up, int down,
		     int first_obj, int last_obj, int base_obj,
		     int start_index, int num_slits );
int	Get_Device_Index( DEV_PTR tptr, DEV_PTR ptr );
void	device_mover_button( int obj );
void	RedrawObject( OBJECT *tree, int obj );
void	Undo_Dnodes( DEV_PTR ptr, int flag );
void	ClearHFLAG( HDEVICE_PTR ptr );

