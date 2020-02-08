/* main.h / 8.9.90 / MATRIX / WA */

# define MAXlevel  1000
# define MAXlevelL 1000L

# define TICKcycle	  100 /* ms	*/


# define MM_ENTER 0
# define MM_LEAVE 1

typedef struct
{
	int 	  state ;
	int 	  form[2] ;
	TRectangle rect ;
} MOUSEevent ;

typedef struct
{
/* in  */	int  		in_events, tick_cycle,
		        		iclicks, imask, istate ;
			MOUSEevent	mousevt[2] ;
/* out */	int			out_events,
				 		buttons, keystate, keycode, clicks ;
			POINT 		mouse ;
			int			buffer[8] ;
} EVENTparameter ;

# define DEFmousEvt(inside) { 0, { inside, ARROW }, { 0, 0, 0, 0 } }
# define DEFevtPars(evts)		\
{								\
	evts, TICKcycle,			\
	1, 1, 1,					\
	{							\
		DEFmousEvt(THIN_CROSS),	\
		DEFmousEvt(POINT_HAND)	\
	},							\
	0,							\
	0, 0, 0, 0,					\
	{ 0, 0 },					\
	{ 0, 0, 0, 0, 0, 0, 0, 0 }	\
}

extern long timer_ticks ;
extern void multiple_events ( EVENTparameter *evtpar ) ;

/* exports from main */

extern int
    appl_id,
	colors,
	bit_planes,
	palette_support,
	scr_max_x,
	scr_max_y,
    vdi_handle,
	hwchar, hhchar,
	hwbox, hhbox,
	dummy;

extern POINT screen_size ;	/* dimension	*/
/* local */ extern OBJECT *menu_tree ;

# if 0
extern void not_impl(void);
# endif

extern void show_menu ( void ) ;
extern void hide_menu ( void ) ;
extern void menu_enable ( int menuobj ) ;
extern void menu_disable ( int menuobj ) ;
extern bool menu_enabled ( int menuobj ) ;

extern char *rsrc_gstring ( int tree ) ;

extern int base_mouse_form ;
# define MouseBase()	graf_mouse ( base_mouse_form, 0 )

extern bool message_event ( int buffer[] ) ;
extern void mouse_event ( MOUSEevent *mous_evt ) ;

typedef void (*TIMERproc)( EVENTparameter *evtpar ) ;

extern void evtimer_enable  ( TIMERproc timproc, int cycle ) ;
extern void evtimer_disable ( void ) ;
extern bool event_state_changed ( EVENTparameter *last, EVENTparameter *curr ) ;
extern void timer_ticked ( EVENTparameter *evtpar ) ;

/* imports to main */

extern int
	_app ;

# define application _app
# define accessory	 (!_app)

extern char acc_menu_title[] ;
extern char rsc_filename[] ;
extern char program_title[] ;

extern int  menu_num_tree ;

extern bool open_application_window(int argc,char *argv[]) ;
extern bool	init_application(void) ;
extern void	term_application(void) ;

extern int test ;
