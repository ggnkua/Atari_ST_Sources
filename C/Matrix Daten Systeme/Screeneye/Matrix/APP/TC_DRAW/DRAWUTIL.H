# define MINpattern	 0
# define DEFpattern  1
# define MAXpattern 38

extern int pattern ;
extern int interior ;
extern int style ;

extern struct POTIstruct pattern_poti ;

# define inside_work(mx,my)	( 0 < (mx) && (mx) < scr_max_x && canvas.y <= (my) && (my) < scr_max_y )

extern void snap_xy2_canv ( int *pts ) ;
extern bool mouse_move ( int *pts, int *buttons, bool clip ) ;
extern void clip_grid ( int *pts, int *npts ) ;

extern void fill_object ( OBJECT *tree, int objn, int color ) ;
extern void fill_object_rgb ( OBJECT *tree, int objn, int *rgb ) ;
extern void draw_patbox ( OBJECT *tree, int objn ) ;
extern void set_fill_pattern ( void ) ;
extern void update_pattern ( void ) ;
extern int get_position ( int *pts, char *info ) ;
