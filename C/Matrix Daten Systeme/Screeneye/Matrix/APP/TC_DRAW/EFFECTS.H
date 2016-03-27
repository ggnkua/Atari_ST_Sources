# define RGBspace	0
# define CMYspace	1

extern void line_nalias ( int *pts, int *line_rgb ) ;
extern void rgb_cube ( int *pts, int space ) ;

extern uword max_histo ( uword *data, int n ) ;
extern void get_histo ( int *pts, uword *data ) ;
extern void get_rgb_histo ( int *pts, uword *data ) ;
extern int get_line_histo ( int *pts, uword *data ) ;
extern void init_bright ( void ) ;
extern void calib_rect ( int *pts, int ref_y0, int ref_y1 ) ;
extern void gray_rect ( int *pts ) ;
extern void yuv_rect ( int *pts ) ;
extern void bright_rect ( int *pts ) ;
extern void zoom_box  ( int *pts ) ;
extern void zoom_copy ( int *spts, int *dpts ) ;
extern void copy_box (  int *spts, int *dpts, int blit_mode ) ;
extern void copy_block ( int *spts, int *dpts,
				  int blit_mode, MFDB *source, MFDB *dest ) ;
extern void mirror_rect ( int *pts, int degree ) ;
extern void simulate_tclut ( int *pts,
						int rbits, int gbits, int bbits ) ;
extern void draw_frame ( int *pts ) ;
# if 0
extern void multi_slope ( int *pts  ) ;
# endif
extern void init_rainbow ( void ) ;
extern void rain_bow ( int *pts ) ;
extern void lines_box ( int *pts ) ;
extern void rgb_slope ( int *pts ) ;
extern void rect_slope ( int *pts,
				 unsigned char *topleft,
				 unsigned char *topright,
				 unsigned char *bottomleft,
				 unsigned char *bottomright ) ;
extern void rect_rgb_slope ( int *pts, int *rgbs ) ;
extern void even_to_odd ( int *pts ) ;
extern void draw_line4 ( int x, int y, int x1, int y1 ) ;
extern void draw_linep ( int *pts ) ;
extern void draw_cross ( int *pts ) ;
extern void draw_rect ( int *pts ) ;
