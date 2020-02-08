typedef void (*GRAPHICfunction)( int  *pts ) ;

# if 0
# define radius(pts)	hypothenuse(pts)
# else
# define radius(pts)	(abs(pts[X1]-pts[X0]))
# endif

extern void sort_pts ( int *pts ) ;

extern void filled_rectangle ( int *pts ) ;
extern bool buffer_ok ( void ) ;
extern void save_p0p1 ( int *pts ) ;

extern void erase_picture ( void ) ;

extern void set_curr_fill_attr ( void ) ;
extern void set_invert_attr ( void ) ;
extern unsigned hypothenuse ( int *pts ) ;

extern void copy_rectangle ( int *srcpts, int *dstpts ) ;
extern void invert_rect ( int *pts ) ;

extern void DrawText ( int *pt, char *s ) ;
extern void circle_function ( int *pts ) ;
extern void DrawCircle ( int *pts ) ;
extern void Line ( int *pts ) ;
extern void Fill ( int *pts, int fillcol ) ;
extern void Mirror ( int *pts ) ;
extern void SimulateClut ( int *pts ) ;
extern void DrawFractal ( int *pts ) ;
extern void color_cube ( int *pts ) ;

extern void check_stop_message ( void ) ;
extern bool check_stop ( void ) ;
extern void check_stop_off ( void ) ;
