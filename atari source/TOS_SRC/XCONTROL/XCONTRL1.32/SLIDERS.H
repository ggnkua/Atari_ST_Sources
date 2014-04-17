/* SLIDERS.C - Prototypes and defines
 *==========================================================================
 *
 */



/*  PROTOTYPES
 *==========================================================================
 */
void cdecl sl_size( OBJECT *tree, int base, int slider, int num_items,
                    int visible, int direction, int min_size );

void cdecl sl_x( OBJECT *tree, int base, int slider, int value,
                 int num_min, int num_max, void (*foo)() );
           
void cdecl sl_y( OBJECT *tree, int base, int slider, int value,
                 int num_min, int num_max, void (*foo)() );

void cdecl sl_arrow( OBJECT *tree, int base, int slider, int obj,
                     int inc, int min, int max, int *numvar, int direction,
                     void (*foo)() );
               
void cdecl sl_dragx( OBJECT *tree, int base, int slider, int min,
                     int max, int *numvar, void (*foo)() );
               
void cdecl sl_dragy( OBJECT *tree, int base, int slider, int min,
                     int max, int *numvar, void (*foo)() );

void Hot_Slide( OBJECT *tree, int base, int slider, int obj,
           	int inc, int min, int max, int *numvar,
           	int direction, GRECT *rect, void (*foo)() );


/*  DEFINES
 *==========================================================================
 */
#define NULLFUNC	( void(*)())0L
#define HORIZONTAL	1
#define VERTICAL	0
