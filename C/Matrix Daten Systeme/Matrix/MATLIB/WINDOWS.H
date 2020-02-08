# ifndef WINDOWdescr
typedef void WINDOWdescr ;
# endif

typedef void (*VOIDfct)(void);
typedef void (*REDRAWfct)( RECTangle *work, RECTangle *rect, int loop );
typedef void (*RECTfct)(RECTangle *rect);
typedef bool (*MENUfct)(int menuentry);
typedef void (*CLOSEfct)(void);

# define WINDOWmoved	0x0001	/* values for changes	*/
# define WINDOWsized	0x0010

typedef void (*SIZEfct)(RECTangle *old, RECTangle *new, unsigned changes );

extern WINDOWdescr *curr_redraw_window ;

extern char MSGwindCantOpen[] ;

extern WINDOWdescr *malloc_window ( void ) ;
extern WINDOWdescr *find_window ( WINDOWhandle handle ) ;
extern WINDOWhandle window_handle ( WINDOWdescr *window ) ;

extern void close_window ( WINDOWdescr *window ) ;
extern void close_all_but ( WINDOWdescr *window ) ;
extern void empty_wind_fct ( void );
extern void term_windows(void);
extern void init_windows(void);
extern void close_all_windows(void);
extern bool windows_open(void);
extern WINDOWdescr  *first_open_window(void) ;
extern WINDOWhandle first_open_handle(void) ;
extern bool legal_window ( WINDOWdescr *window ) ;
extern bool is_top_window ( WINDOWdescr *window ) ;
extern WINDOWdescr *top_window ( void ) ;
extern void set_window_descriptor( int *phandle,
		 					REDRAWfct redraw_fct,
		 					VOIDfct  event_fct );
		 					
# define FULLwindow		0x0001		/* flags	*/
# define NOwhLimit		0x0002
# define FULLscreen	 	0x0004
# define CENTERwindow	0x0008

extern bool open_object_tree_window ( WINDOWdescr **window,
							   unsigned flags, int elements,
							   OBJECT *tree, char *title,
				 			   REDRAWfct redraw_fct,
					 		   VOIDfct  event_fct ) ;

typedef bool (*BOOLproc)(void) ;
extern bool activate_window ( WINDOWdescr *window, BOOLproc opnwndprc ) ;

extern void set_slider_sizes ( WINDOWdescr *window, int div ) ;
extern void set_size_fct  ( WINDOWdescr *window, SIZEfct size_fct ) ;
extern void set_slide_fct ( WINDOWdescr *window, VOIDfct slide_fct ) ;
extern void set_menu_fct ( WINDOWdescr *window, MENUfct menu_fct ) ;
extern void set_close_fct ( WINDOWdescr *window, CLOSEfct close_fct ) ;

extern void event_window(WINDOWdescr *window);
extern void redraw_window(WINDOWdescr *window, RECTangle *area);
extern void full_size_window ( WINDOWdescr *window ) ;
extern bool menu_window ( WINDOWdescr *window, int menu_entry ) ;
extern void move_window ( WINDOWdescr *window, RECTangle *rect);
extern void size_window ( WINDOWdescr *window, RECTangle *rect);
extern void arrow_window ( WINDOWdescr *window, int arrow ) ;
extern void hslide_window ( WINDOWdescr *window, int new_pos ) ;
extern void vslide_window ( WINDOWdescr *window, int new_pos ) ;

extern void winfo_vprintf ( WINDOWdescr *window, const char *format, void *args ) ;
extern void winfo_printf ( WINDOWdescr *window, const char *format, ... ) ;
extern char *empty_mesg ;
extern void window_object_info ( WINDOWdescr *window, char *objtxt(int,int,int),
										int mx, int my ) ;
