extern bool	 	DisplaySequenceOn ;
extern unsigned CurrentStyle ;
extern int 	 	WindStyleNumber ;
extern unsigned WindStyleTable[3] ;

extern void calc_x_slider ( int pos1000, TRectangle *win, TRectangle *vid ) ;
extern void calc_y_slider ( int pos1000, TRectangle *win, TRectangle *vid ) ;
extern void update_x_slider ( TRectangle *win, TRectangle *vid ) ;
extern void update_y_slider ( TRectangle *win, TRectangle *vid ) ;
extern void update_sliders ( TRectangle *win, TRectangle *vid ) ;

extern void set_window_title ( void ) ;
extern int  WindowMessage ( const char *newtitle, ... ) ;
extern void open_window ( void ) ;
extern void reopen_window ( void ) ;
extern void recalc_open_window ( TRectangle *win ) ;
extern void test_output ( TRectangle *box ) ;
extern void restart_sliders ( void ) ;
extern void resize_window ( void ) ;
extern void redraw_window ( void ) ;
extern void close_d_window ( void ) ;
extern void kill_d_window ( void ) ;
extern void kill_digit_windows ( void ) ;
extern void ToggleWindowFulled ( void ) ;

extern void SetWindowRectangle ( TRectangle *rect ) ;
extern void reset_window ( int style ) ;
extern void ResetDigiImages ( TBlitWindow *blitwind ) ;
extern void ResetBlitWindow ( TBlitWindow *blitwind, POINT *zoom ) ;
