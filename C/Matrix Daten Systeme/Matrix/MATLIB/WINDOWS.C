/* --- window table --- */

# define TEST	0
# if TEST
#include <ext.h>
# if 0
# define tprintf(p) 	 printf( "\033Y0 " p ) ;		delay(1000)
# define tprintf2(p,q)	 printf( "\033Y0 " p, q ) ;		delay(1000)
# define tprintf3(p,q,r) printf( "\033Y0 " p, q, r ) ;	delay(1000)
# else
# define delay(d)
# define tprintf(p) 	 printf( p ) ;			delay(1000)
# define tprintf2(p,q)	 printf( p, q ) ;		delay(1000)
# define tprintf3(p,q,r) printf( p, q, r ) ;	delay(1000)
# endif
# endif

# include <stdio.h>
# include <stdlib.h>
# include <vdi.h>
# include <aes.h>

# include <global.h>

# define WINDOWdescr	struct WINDdeSCR

# include "\pc\cxxsetup\aesutils.h"
# include "\pc\cxxsetup\main.h"

# include "windows.h"

# define DEFinfoSize 256
# define MINwindWH	  40

typedef WINDOWdescr {
	WINDOWdescr		*next ;
	WINDOWdescr		**back ;
	WINDOWhandle	handle ;
	int				elements ;
	unsigned		flags ;
	OBJECT			*tree ;
	REDRAWfct		redraw_fct ;
	VOIDfct			event_fct ;
	SIZEfct			size_fct ;
	VOIDfct			slide_fct ;
	MENUfct			menu_fct ;
	VOIDfct			close_fct ;
	int				arrow_step ;
	int				page_step ;
	char			*info ;
	} ;


char MSGwindCantOpen[] =	"Kein Fenster mehr verfgbar" ;

WINDOWdescr *WindowTable = NULL ;

# if 0
/*--------------------------------------------- empty_wind_fct ----*/
void empty_wind_fct ( void )
{
# if TEST == 99
	form_alert ( 1, "[3][| SYS : empty wind fct !!! ][ Oh ]" ) ;
# endif
}
# endif			


/*---------------------------------------------- print_window ----*/
void print_window ( char *mesg, WINDOWdescr *wd )
{
	printf ( "%swindow -> $%p", mesg, WindowTable ) ;
	if ( wd == NULL )
	{
		printf ( ", window -> NULL\n" ) ;
	}
	else
	{
		printf ( "wd $%8p nxt $%8p h %2d info '%s'\n",
					wd,
					wd->next,
					wd->handle,
					wd->info ? wd->info : "<NULL>" ) ;
	}
}

/*---------------------------------------------- default_window ----*/
local void default_window ( WINDOWdescr *wd )
{
# if 0
	wd->next		= NULL ;
	wd->info		= NULL ;	
	wd->back		= NULL ;
# endif
	wd->handle		= -1 ;
	wd->elements	= 0 ;
	wd->flags		= 0 ;
	wd->tree 		= NULL ;
	wd->redraw_fct	= NULL ;
	wd->event_fct	= NULL ;
	wd->slide_fct	= NULL ;
	wd->menu_fct	= NULL ;
	wd->close_fct	= NULL ;
	wd->size_fct	= NULL ;
	wd->arrow_step	=  1 ;
	wd->page_step	= 10 ;
# if 0
	if ( wd->info != NULL )
		*(wd->info) = 0 ;	
# endif
}


/*--------------------------------------------------- malloc_window ----*/
WINDOWdescr *malloc_window ( void )
{
	WINDOWdescr *window ;

	if ( STRUCTmalloc ( window ) )
	{
		window->info = malloc ( DEFinfoSize ) ;
		if ( window->info != NULL )
		{
			window->info[0] = 0 ;
			default_window ( window ) ;
			window->next = WindowTable ;   /* first window in list */
			WindowTable  = window ;

			window->back = NULL ;
		}
		else
		{
			free ( window ) ;
			window = NULL ;
		}
	}
	return window ;
}

/*------------------------------------------------ close_window ----*/
void close_window ( WINDOWdescr *window )
{
	RECTangle   curr;

# if TEST
	print_window ( "\033H\033Kclose ", window ) ;
	getch();
# endif
	if ( window->handle >= 0 )
	{
		if ( window->close_fct != NULL )
			(*window->close_fct)();

		WindGetCurr ( window->handle, curr ) ;
		GrafShrinkbox ( NullRectangle, curr );
		WindClose  ( window->handle ) ;
		WindDelete ( window->handle ) ;

		default_window ( window ) ;
	}
}

/*------------------------------------------ close_all_but ------*/
void close_all_but ( WINDOWdescr *window )
{
	WINDOWdescr *wd ;

# if TEST
	print_window ( "\033H\033Kclose all but ", window ) ;
	getch();
# endif

	for ( wd = WindowTable ; wd != NULL ; wd = wd->next )
		if ( wd != window )
			close_window ( wd ) ;
}

/*------------------------------------------ close_all_windows -----*/
void close_all_windows ( void )
{
	close_all_but ( NULL ) ;
}

/*------------------------------------------ free_all_windows ------*/
void free_all_windows ( void )
{
	WINDOWdescr *wd,*wn ;
	
	for ( wd = WindowTable ; wd != NULL ; )
	{
		close_window ( wd ) ;

		if( wd->back != NULL )
			*(wd->back) = NULL ;

		wn = wd->next ;
		if ( wd->info != NULL )
			free ( wd->info ) ;
		free ( wd ) ;
		wd = wn ;
	}
	WindowTable = NULL ;
}

/*------------------------------------------ term_windows ------*/
void term_windows(void)
{
# if TEST == 1
	tprintf ( "+ term_windows\n" ) ;
# endif
	free_all_windows ( ) ;
# if TEST == 1
	tprintf ( "- term_windows\n" ) ;
# endif
}


/*------------------------------------------ init_windows ------*/
void init_windows(void)
{
	WindowTable = NULL ;
}

/*------------------------------------------ first_open_window ------*/
WINDOWdescr *first_open_window(void)
{
	WINDOWdescr *wd ;

	for ( wd = WindowTable ; wd != NULL ; wd = wd->next )
		if ( wd->handle >= 0 )
			return ( wd ) ;
	return( NULL ) ;
}

/*------------------------------------------ first_open_handle ------*/
WINDOWhandle first_open_handle ( void )
{
	WINDOWdescr *wd ;

	wd = first_open_window() ;
	if ( wd != NULL )
		return wd->handle ;
	else
		return -1 ;
}

/*------------------------------------------ window_handle ------*/
WINDOWhandle window_handle ( WINDOWdescr *window )
{
	if ( window != NULL )
		return window->handle ;
	else
		return -1 ;
}

/*------------------------------------------ is_top_window ------*/
bool is_top_window ( WINDOWdescr *window )
{
	WINDOWhandle topwind ;

	if ( window != NULL )
	{
		WindGetTop ( topwind ) ;
		return window->handle == topwind ;
	}
	else
		return FALSE ;
}



/*------------------------------------------ windows_open ------*/
bool windows_open(void)
{
	return ( first_open_window() != NULL ) ;
}

/*------------------------------------------ find_window ------*/
WINDOWdescr *find_window ( WINDOWhandle handle )
{
	WINDOWdescr *wd ;

	for ( wd = WindowTable ; wd != NULL ; wd = wd->next )
		if ( wd->handle == handle )
			return ( wd ) ;
	return( NULL ) ;
}


/*------------------------------------------ legal_window ------*/
bool legal_window ( WINDOWdescr *window )
{
	return( window != NULL && window->handle >= 0 ) ;
}


/*------------------------------------------ top_window ------*/
WINDOWdescr *top_window ( void )
{
	WINDOWhandle topwind ;

	WindGetTop ( topwind ) ;
	return find_window ( topwind ) ;
}




/*-------------------------------------- open_object_tree_window ---*/
bool open_object_tree_window ( WINDOWdescr **window,
							   unsigned flags, int elements,
							   OBJECT *tree, char *title,
				 			   REDRAWfct redraw_fct,
					 		   VOIDfct  event_fct )
{
	bool		 ok ;
	RECTangle	 work ;
	RECTangle	 windbord ;
	WINDOWhandle handle ;
	WINDOWdescr	 *wd ;

	ok = FALSE ;
# if TEST == 1
	tprintf  ( "+ open_otree_window\n" ) ;
	tprintf2 ( "  malloc, req = %ld", sizeof ( WINDOWdescr ) ) ;
# endif
# if TEST
		print_window ( "\033H\033Kopen window ", *window ) ;
		getch();
# endif
	if ( *window == NULL )
		wd = malloc_window() ;
	else
		wd = *window ;

	/* ??? look for unused handles	???? */

	if ( wd != NULL )
	{
# if TEST == 1
		tprintf ( ", ok\n" ) ;
# endif
# if 0
		if ( flags & FULLscreen )
		{
			windbord.x = work.x = 0 ;
			windbord.y = work.y = 0 ;
			windbord.w = work.w = screen_size.x ;
			windbord.h = work.h = screen_size.y ;
			if ( tree != NULL )
				ObjectSetRectangle ( tree, 0, work ) ;
		}
		else if ( flags & FULLwindow )
# else
		if ( flags & (FULLwindow|FULLscreen) )
# endif
		{
			WindGetWork ( DESK_TOP, windbord ) ;
			WindCalc( WC_WORK, elements, windbord, work ) ;
			if ( tree != NULL )
				ObjectSetRectangle ( tree, 0, work ) ;
		}
		else if ( tree != NULL )	/* object window	*/
		{
			if ( flags & CENTERwindow )
			{
				FormCenter ( tree, work ) ;
				ObjectSetRectangle ( tree, 0, work ) ;
			}
			else
			{
				work.x = tree->ob_x ;
				work.y = tree->ob_y ;
				work.w = tree->ob_width ;
				work.h = tree->ob_height ;
			}

			WindCalc( WC_BORDER, elements, work, windbord ) ;

			{
				int dy ;
				
				dy = windbord.y - 32 ;
				if ( dy < 0 )
				{
					windbord.y  = 32 ;
					tree->ob_y -= dy ;
				}
			}
		}
		else				/* normal window	*/
		{
			WindGetWork ( DESK_TOP, windbord ) ;
		}
			
# if TEST == 1
		tprintf ( "> WindCreate\n" ) ;
# endif
		handle = WindCreate( elements, windbord ) ;
# if TEST == 1
		tprintf2 ( "  window handle = %d\n", handle ) ;
# endif
		if ( handle >= 0 )
		{
			*window			= wd ;
			
			wd->handle		= handle ;
			wd->back		= window ;
			wd->elements 	= elements ;
			wd->flags	 	= flags ;
			wd->tree	 	= tree ;
			wd->redraw_fct	= redraw_fct ;
			wd->event_fct	= event_fct ;
	
			if ( title != NULL )
				WindSetName ( handle, title ) ;
			if ( elements & INFO )
				WindSetInfo ( handle, "" );
			GrafGrowbox ( NullRectangle, windbord );
			WindOpen(handle,windbord);
			ok = TRUE ;
		}
# if TEST == 1
		else
		{
			tprintf ( "*** WindCreate fail\n" ) ;
		}
# endif
	}
# if TEST == 1
	else
		tprintf ( " *** fail\n" ) ;
	tprintf2 ( "- open_otree_window, ok = %u\n", ok ) ;
# endif
	return ok ;
}

/*-------------------------------------------------- activate_window --*/
bool activate_window ( WINDOWdescr *window, BOOLproc opnwndprc )
{
	WINDOWhandle wh ;

	if ( keyboard_state ( K_ALT ) )
		close_all_but ( window ) ;
	if ( ( wh = window_handle ( window ) ) >= 0 )
	{
		WindSetTop ( wh );
		return ( TRUE ) ;
	}
	else
	{
		if ( opnwndprc != NULL )
			return ( (*opnwndprc)() ) ;
		else
			return FALSE ;
	}
}


/*--------------------------------------------------- event_window ----*/
void event_window ( WINDOWdescr *window )
{
	if ( window->event_fct != NULL )
		(*window->event_fct)();
}

WINDOWdescr *curr_redraw_window = NULL ;

/*---------------------------------------------- redraw_window ------*/
void redraw_window ( WINDOWdescr *window, RECTangle *area )
{
	RECTangle work, next ;
	int loop ;

	if ( window == NULL || window->redraw_fct == NULL )
		return ;	
	curr_redraw_window = window ;
# if 0
	WindUpdateBegin();
# endif
	WindGetWork(window->handle,work);
	WindGetFirst(window->handle,next);

	MouseOff();
	for( loop = 0 ; RectangleNotEmpty(next); loop++ )
	{
		if( rc_intersect(area, &next) )
		{
			ClippingOn(vdi_handle,next);
			(*window->redraw_fct)(&work,&next,loop);
		}
		WindGetNext ( window->handle, next );
	}
# if 0
	WindUpdateEnd();
# endif
	ClippingOff(vdi_handle);
	MouseOn();
}

/*------------------------------------------------ set_menu_fct ----*/
void set_menu_fct ( WINDOWdescr *window, MENUfct menu_fct )
{
	window->menu_fct = menu_fct ;
}

/*------------------------------------------------ set_close_fct ----*/
void set_close_fct ( WINDOWdescr *window, CLOSEfct close_fct )
{
	window->close_fct = close_fct ;
}

/*------------------------------------------------ set_size_fct ----*/
void set_size_fct ( WINDOWdescr *window, SIZEfct size_fct )
{
# if TEST == 3
	tprintf3 ( "window $%p set size fct $%p\n", window, size_fct ) ;
# endif
	window->size_fct = size_fct ;
}

/*----------------------------------------------- set_slide_fct ----*/
void set_slide_fct ( WINDOWdescr *window, VOIDfct slide_fct )
{
	window->slide_fct = slide_fct ;
}

/*----------------------------------------------- recalc_window ----*/
void recalc_window ( WINDOWdescr *window, RECTangle *rect,
					 unsigned changes )
{
	RECTangle curr, work ;
	OBJECT	  *obp ;

# if TEST == 3
	tprintf3 ( "+ recalc_window $%p { %d,.. }",
				window, window != NULL ? window->handle : -1 ) ;
# endif
	WindGetCurr ( window->handle, curr ) ;
	obp = window->tree ;
	if ( obp != NULL )
	{
		WindCalc( WC_WORK, window->elements, *rect, work ) ;
		obp->ob_x = work.x ;
		obp->ob_y = work.y ;
		if ( window->flags & NOwhLimit )
		{
			obp->ob_width  = work.w ;
			obp->ob_height = work.h ;
		}
		else /* limited size	*/
		{
			if ( work.w > obp->ob_width   ) work.w = obp->ob_width ;
			if ( work.h > obp->ob_height  ) work.h = obp->ob_height ;
			WindCalc( WC_BORDER, window->elements, work, *rect ) ;
		}
	}
	WindSetCurr( window->handle, *rect ) ;
# if TEST == 3
	tprintf2 ( ", size fct : $%p\n", window->size_fct ) ;
# endif
	if ( window->size_fct != NULL )
		(*window->size_fct)( &curr, &work, changes );
# if TEST == 3
	tprintf ( "- recalc_window\n" ) ;
# endif
}

/*--------------------------------------------------- move_window ----*/
void move_window ( WINDOWdescr *window, RECTangle *rect )
{
	recalc_window ( window, rect, WINDOWmoved ) ;
}

/*--------------------------------------------------- size_window ----*/
void size_window ( WINDOWdescr *window, RECTangle *rect )
{
	if ( rect->w < MINwindWH )
		rect->w = MINwindWH ;
	if ( rect->h < MINwindWH )
		rect->h = MINwindWH ;
	recalc_window ( window, rect, WINDOWsized ) ;
}




/*---------------------------------------------- full_size_window ------*/
void full_size_window ( WINDOWdescr *window )
{
	RECTangle curr, new ;
		
	WindGetCurr ( window->handle, curr ) ;
	WindGetFull ( window->handle, new ) ;
	if ( RectanglesEqual( curr, new ) )
		WindGetPrev ( window->handle, new ) ;		/* was full size ! */
	recalc_window ( window, &new, WINDOWmoved | WINDOWsized ) ;
	WindSetCurr ( window->handle, new ) ;
}



/*---------------------------------------------- menu_window ------*/
bool menu_window ( WINDOWdescr *window, int menu_entry )
{
	if ( window->menu_fct != NULL )
		return (*window->menu_fct)( menu_entry );
	else
		return FALSE ;
}

/*---------------------------------------------- hslide_window ------*/
void hslide_window ( WINDOWdescr *window, int new_pos )
{
	WindSetHSpos(window->handle,new_pos) ; 
	if ( window->slide_fct != NULL )
		(*window->slide_fct)();
}

/*---------------------------------------------- vslide_window ------*/
void vslide_window ( WINDOWdescr *window, int new_pos )
{
	WindSetVSpos(window->handle,new_pos) ; 
	if ( window->slide_fct != NULL )
		(*window->slide_fct)();
}

# define AR_STEP	0
# define PG_STEP	1

# define AR_UP		-1
# define AR_DOWN	 1
# define AR_LEFT	-1
# define AR_RIGHT	 1


/*-------------------------------------- set_slider_sizes ---------*/
void set_slider_sizes ( WINDOWdescr *window, int div )
{
	int		  siz ;

	siz = 1000 / div ;
	
	WindSetHSsize ( window->handle, siz ) ;
	WindSetVSsize ( window->handle, siz ) ;
		
	window->page_step	= div > 3 ? 1000 / ( div-1 ) : 1000 ;
	window->arrow_step	= window->page_step / 8 ;
}

/*--------------------------------------------------- inc_wstep ----*/
int inc_wstep ( WINDOWdescr *window, int pos, int step, int dir )
{
	pos += ( step == AR_STEP ? window->arrow_step : window->page_step ) * dir ;
	if(pos<0) pos = 0 ;
	else if ( pos > MAXlevel ) pos = MAXlevel ;
	return ( pos ) ;
}

/*---------------------------------------------- hscroll_window ----*/
void hscroll_window ( WINDOWdescr *window, int step, int dir )
{
	int	pos ;
	
	WindGetHSpos(window->handle,pos) ;
	WindSetHSpos(window->handle,inc_wstep ( window, pos, step, dir )) ;	
}

/*---------------------------------------------- vscroll_window ----*/
void vscroll_window ( WINDOWdescr *window, int step, int dir )
{
	int	pos ;
	
	WindGetVSpos(window->handle,pos) ;
	WindSetVSpos(window->handle,inc_wstep ( window, pos, step, dir )) ; 
}

/*---------------------------------------------- arrow_window ------*/
void arrow_window ( WINDOWdescr *window, int arrow )
{
	switch ( arrow )
	{
 case 0 :	vscroll_window ( window, PG_STEP, AR_UP		) ;		break ;
 case 1 :	vscroll_window ( window, PG_STEP, AR_DOWN	) ;		break ;
 case 2 :	vscroll_window ( window, AR_STEP, AR_UP		) ;		break ;
 case 3 :	vscroll_window ( window, AR_STEP, AR_DOWN	) ;		break ;
 case 4 :	hscroll_window ( window, PG_STEP, AR_LEFT 	) ;		break ;
 case 5 :	hscroll_window ( window, PG_STEP, AR_RIGHT 	) ;		break ;
 case 6 :	hscroll_window ( window, AR_STEP, AR_LEFT 	) ;		break ;
 case 7 :	hscroll_window ( window, AR_STEP, AR_RIGHT 	) ;		break ;
	}
	if ( window->slide_fct != NULL )
		(*window->slide_fct)();
}

/*---------------------------------------------- winfo_vprintf -----*/
void winfo_vprintf ( WINDOWdescr *window, const char *format, void *args )
{
	if ( window->info == NULL )
	{
		window->info = malloc ( DEFinfoSize ) ;
		if ( window->info == NULL )
			return ;
	}
			
	vsprintf ( window->info, format, args ) ;
	WindSetInfo ( window->handle, window->info ) ;
}

/*---------------------------------------------- winfo_printf ------*/
void winfo_printf ( WINDOWdescr *window, const char *format, ... )
{
	winfo_vprintf ( window, format, ... ) ;
}

local int last_obj = 0 ;
local int last_mx = 0 ;
local int last_my = 0 ;
local char *last_mesg = NULL ;
char *empty_mesg = "" ;

/*--------------------------------------------- window_object_info -----*/
void window_object_info ( WINDOWdescr *window, char *objtxt(int,int,int), int mx, int my )
{
	int obj ;
	char *m ;

	if ( mx != last_mx || my != last_my )
	{
		last_mx = mx ;
		last_my = my ;

		obj = objc_find ( window->tree, 0, MAX_DEPTH, mx, my ) ;
		if ( obj > 0 )
		{
# if 0
			if ( last_obj == obj )
				return ;
			else
# endif
				m = objtxt ( obj, mx, my ) ;

			if ( m != NULL && ( m != last_mesg || *m == '*' ) )
			{
				winfo_printf ( window, " %s", m ) ;
				last_mesg = m ;
			}
			last_obj = obj ;
		}
		else
		{
			if ( last_obj > 0 )
			{
				winfo_printf ( window, empty_mesg ) ;
				last_obj = obj ;
				last_mesg = empty_mesg ;
			}
		}
	}
}

