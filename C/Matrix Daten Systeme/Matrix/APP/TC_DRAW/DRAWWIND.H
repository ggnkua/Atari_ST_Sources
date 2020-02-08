/*	drawwind.h	/	24.7.91	/	MATRIX	/	WA	*/

# define X0	0	
# define Y0	1	
# define X1	2	
# define Y1	3

extern bool with_outlines ;
extern int outline_width, curr_color, writing_mode ;
extern int blit_mode ;

extern OBJECT	*tcdraw_tree ;
extern RECTangle canvas ;
extern unsigned char *screen_address ;
extern int bytes_per_line ;

extern bool snap_grid ;
extern POINT grid_width ;
extern bool quadrat ;
extern bool puzzle_mode ;
extern bool is_mattc ;

extern RECTangle tcdraw_work, canvas ;
extern int color_space ;

#define MIR_POINT 0 /* BOXTEXT in Baum TR_POPUP */
#define MIR_0     1
#define MIR_45    2
#define MIR_90    3
#define MIR_135   4
extern int mirr_mode ;

extern byte   *keyshift ;

extern long start_time, end_time ;
# define TIMEfac ((1000/200))
# define _hz_200 ((long *)0x4ba)
# define get_ticks() get_lcont ( _hz_200 )

extern void set_new_writing_mode ( int wrm ) ;
extern void set_new_blit_mode ( int blm ) ;
extern void set_new_pattern ( int pat ) ;


# ifndef VQcolMode
# define ReGrBl void
# endif

extern ReGrBl clut_masks ;
extern int text_effects ;

extern void draw_big_color_box ( void ) ;	/* colors	*/
extern bool palette_box_active ( void ) ;

extern int transp_color ;					/* pictures */
extern char *find_file_ext ( void ) ;

extern bool check_stop ( void ) ;
extern void clip_on ( void ) ;
extern void chk_canvas_pts ( int *pts ) ;
extern void set_canvas_pts ( int *pts ) ;

extern void switch_video_on ( int mode ) ;
extern void switch_video_off ( void ) ;
extern void SetVideoFrames ( int frms ) ;
extern void SetVideoWindow ( int *pts ) ;

extern void ToBox ( int *pts ) ;
extern void FromBox ( int *pts ) ;

extern int info_printf ( const char *format, ... ) ;
extern int info_vprintf ( const char *format, void *args ) ;
