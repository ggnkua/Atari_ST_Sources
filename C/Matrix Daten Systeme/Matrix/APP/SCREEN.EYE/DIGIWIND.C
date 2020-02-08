/********************************************************************/
/* 				MatDigi Multi-Windows Program						*/
/*																	*/
/*------------------------------------------------------------------*/
/*	Status : 24.09.93												*/
/*																	*/
/*  HG - Matrix Daten Systeme, Talstr. 16, W-71570 Oppenweiler		*/
/*																	*/
/********************************************************************/

# define SETwindowTitle	0

# include <stdlib.h>
# include <portab.h>
# include <aes.h>
# include <tos.h>
# include <stdio.h>
# include <scancode.h>
# include <string.h>
# include <linea.h>
# include <vdi.h>
# include <ext.h>

# include <global.h>

# include "\pc\app\matdigi.f\digitise.h"
# include "\pc\app\matdigi.f\digiblit.h"
# include "\pc\app\matdigi.f\film.h"
# include "\pc\app\matdigi.f\mdf_lca.h"

# include "\pc\app\matdigi.f\screyeif.h"
# include "\pc\app\matdigi.f\scryiacc.h"

# include "\pc\cxxsetup\aesutils.h"
# include "menus.h"

# include "scrn_eye.h"
# include "scrneye.h"
# include "tool_bar.h"

# include "digiwind.h"

bool     DisplaySequenceOn = FALSE ;

unsigned LastWindowStyle = 0 ;
unsigned CurrentStyle    = WINDOW_TYPE_PURE ;

int 	 WindStyleNumber   = 2 ;
unsigned WindStyleTable[3] = { WINDOW_TYPE, WINDOW_TYPE_NO_BAR, WINDOW_TYPE_PURE } ;

char TitleBuffer[128] = "" ;
	
# define _UseBackBuffer	0

# if _UseBackBuffer

TImage BackBuffer = /* background buffer for displayed image */
{
	NULL,
	0, 0, 0, 0
} ;


/*------------------------------------------------- CheckBackBuffer ------*/
void CheckBackBuffer ( TImageWindow scrwnd )
{
	if ( scrwnd->window.w != BackBuffer.w !! scrwnd->window.h != BackBuffer.h )
	{
		if ( BackBuffer.data != NULL )
			free ( BackBuffer.data ) ;
		BackBuffer.w 		= scrwnd->window.w ;
		BackBuffer.h		= scrwnd->window.h ;
		BackBuffer.planes 	= scrwnd->image->planes ;
		BackBuffer.bpl    	= scrwnd->window.w * scrwnd->image->planes / 8 ;
		BackBuffer.data 	= malloc ( _SizeOf(&BackBuffer) ) ;
	}
}

/*------------------------------------------- SaveBackBuffer -------------*/
# endif _UseBackBuffer

/*----------------------------------------------------- SourceWidth ------*/
int SourceWidth ( void )
{
	int w ;
	
	w = MatDigiF.image.w / Zoom.x - border_left - border_x ;
	return w >= 0 ? w : 0 ;
}

/*-------------------------------------------------- SourceHeight ------*/
int SourceHeight ( void )
{
	int h ;
	
	h = MatDigiF.image.h / Zoom.y - head_y - tail_y ;
	return h >= 0 ? h : 0 ;
}


/*--------------------------------------------- calc_x_slider -----*/
void calc_x_slider ( int pos1000, TRectangle *win, TRectangle *vid )
{
	long	vid_pos ;

	wind_set ( whandle, WF_HSLIDE, pos1000 ) ;
	vid_pos = (long)pos1000 * (long)(SourceWidth() - win->w) / 1000L ;
	vid->x = (int)vid_pos + border_left ;
}

/*--------------------------------------------- calc_y_slider -----*/
void calc_y_slider ( int pos1000, TRectangle *win, TRectangle *vid )
{
	long	vid_pos ;

	wind_set ( whandle, WF_VSLIDE, pos1000 ) ;
	vid_pos = (long)pos1000 * (long)(SourceHeight() - win->h) / 1000L ;
	vid->y = (int)vid_pos + head_y ;
}

/*--------------------------------------------- update_x_slider -----*/
void update_x_slider ( TRectangle *win, TRectangle *vid )
{
	int		vidw ;
	long	wxl, wwl ;				/* scaled x, w */

	vidw = ( MatDigiF.image.w / Zoom.x ) - border_left - border_x ;

	vid->x = min ( vid->x, vidw - win->w ) ;
	vid->x = max ( vid->x, border_left ) ;

	wwl = 1000L * (long) win->w / (long) vidw ;

	if ( vidw != win->w )
		wxl = 1000L * (long) vid->x / (long) ( vidw - win->w ) ;	  
	else
		wxl = 1000L ;

	if ( CurrentStyle & HSLIDE )
	{
		wind_get ( whandle, WF_HSLIDE, &vidw ) ;
		if ( vidw != (int) wxl )
			wind_set ( whandle, WF_HSLIDE,  (int) wxl ) ;
		wind_set ( whandle, WF_HSLSIZE, (int) wwl ) ;
	}

	x_page = win->w ;
}


/*--------------------------------------------- update_y_slider -----*/
void update_y_slider ( TRectangle *win, TRectangle *vid )
{
	int		vidh ;
	long	wyl, whl ;		/* scaled y, h */

	vidh = MatDigiF.image.h / Zoom.y - head_y - tail_y ;

	vid->y = min ( vid->y, vidh - win->h) ;
	vid->y = max ( vid->y, head_y ) ;

	whl = 1000L * (long) win->h / (long) vidh ;
	if ( vidh != win->h )
		wyl = 1000L * (long) vid->y / (long) ( vidh - win->h ) ;
	else
		wyl = 1000L ;

	if ( CurrentStyle & HSLIDE )
	{
		wind_get ( whandle, WF_VSLIDE, &vidh ) ;
		if ( vidh !=  (int) wyl )
			wind_set ( whandle, WF_VSLIDE,  (int) wyl ) ;
		wind_set ( whandle, WF_VSLSIZE, (int) whl ) ;
	}

	y_page = win->h ;
}


/*--------------------------------------------- update_sliders -----*/
void update_sliders ( TRectangle *win, TRectangle *vid )
{
	update_x_slider ( win, vid ) ;
	update_y_slider ( win, vid ) ;
}



/*-------------------------------------------- GetMaxWindowFrame ----*/
void GetMaxWindowFrame ( TRectangle *maxrect )
{
	maxrect->x = DeskTop.x ;
	maxrect->y = DeskTop.y ;
	wind_calc ( WC_BORDER, CurrentStyle, 
				0, 0,
				max ( SourceWidth(), ToolsWidth() ),
				SourceHeight() + ToolsHeight(),
				&dummy, &dummy, &maxrect->w, &maxrect->h ) ;
}

# define ChkMini(v,m)	if(v>m) v = m
# define ChkMaxi(v,m)	if(v<m) v = m

/*----------------------------------------- WorkToDestWindow ---*/
void WorkToDestWindow ( TRectangle *work, TRectangle *dest )
{
	int sw ;

	*dest = *work ;
	sw = SourceWidth() ;
	ChkMini ( dest->w, sw ) ;
 	if ( ToolBarOn )
		dest->h -= ToolsHeight() ;
}

/*-------------------------------- LimitWindowToMaximum ------------*/
void LimitWindowToMaximum ( TRectangle *rect, TRectangle *maxrect )
{
	ChkMini ( rect->w, maxrect->w ) ;	/* limit size	*/
	ChkMini ( rect->h, maxrect->h ) ;
}

/*-------------------------------- LimitWindowToRectangle ------------*/
void LimitWindowToRectangle ( TRectangle *rect, TRectangle *limit )
{
	POINT maxi ;

	ChkMini ( rect->w, limit->w ) ;	/* limit size	*/
	ChkMini ( rect->h, limit->h ) ;
	
	maxi.x = limit->x + limit->w - rect->w ;
	maxi.y = limit->y + limit->h - rect->h ;

	ChkMini ( rect->x, maxi.x ) ;	/* limit start point	*/
	ChkMini ( rect->y, maxi.y ) ;
	
	ChkMaxi ( rect->x, limit->x ) ;
	ChkMaxi ( rect->y, limit->y ) ;
}


/*------------------------------------------ WindowCreateAndOpen ---*/
int WindowCreateAndOpen ( TRectangle *curr, int style )
{
	int h ;
	
	TprintfK (( "+ WindowCreateAndOpen" )) ;
	if ( ( h = WindCreate ( style, DeskTop ) ) >= 0 )
	{
		WindOpen ( h, *curr ) ;
		LastWindowStyle = style ;
		ToolsVisible = ToolBarOn ;
	}
	TprintfK (( "- WindowCreateAndOpen : %d", h )) ;
	return h ;
}


/*-------------------------------------- WindowRemove --------------*/
void WindowRemove ( int h )
{
	WindClose ( h ) ;
	WindDelete ( h ) ;
}


/*------------------------------------------- SetWindowRectangle ---*/
void SetWindowRectangle ( TRectangle *rect )
{
	TRectangle curr, work ;
	
	TprintfK (( "+ SetWindowRectangle" )) ;
	GetMaxWindowFrame ( &curr ) ;
	LimitWindowToMaximum ( rect, &curr ) ;
	LimitWindowToRectangle ( rect, &DeskTop ) ;

	if ( whandle < 0 )
	{
		if ( ( whandle = WindowCreateAndOpen ( rect, CurrentStyle ) ) < 0 )
			return ;
	}
	else
	{
		if ( LastWindowStyle != CurrentStyle )
		{
# if 0
			WindSetKind ( whandle, CurrentStyle ) ;
# else
			WindowRemove ( whandle ) ;
			if ( ( whandle = WindowCreateAndOpen ( rect, CurrentStyle ) ) < 0 )
				return ;
# endif
		}
		else
			WindSetCurr ( whandle, *rect ) ;
	}
	
	WindGetWork ( whandle, work ) ;
	WorkToDestWindow ( &work, &BlitWindow.dst.window ) ;

	BlitWindow.src.window.x = border_left ;
	BlitWindow.src.window.y = head_y ;

	if ( ToolBarOn )
		DrawToolBar ( NULL ) ;
	update_sliders ( &BlitWindow.dst.window, &BlitWindow.src.window ) ;
# if _UseBackBuffer
	CheckBackBuffer ( &BlitWindow.dst );
# endif _UseBackBuffer
	TprintfK (( "- SetWindowRectangle" )) ;
}


/*------------------------------------------- SetWindowFull ---*/
void SetWindowFull ( void )
{
	TRectangle full ;

	TprintfK (( "- SetWindowFull" )) ;
	full = DeskTop ;
	SetWindowRectangle ( &full ) ;
	TprintfK (( "- SetWindowFull" )) ;
}


/*-------------------------------------------- ResizeWindow -------*/
void ResizeWindow ( void )
{
	TRectangle	curr ;

	WindGetCurr ( whandle, curr ) ;
	curr.w = DeskTop.w ;
	curr.h = DeskTop.h ;
	SetWindowRectangle ( &curr ) ;
}


/* ------------------------------------------- reset_window ------ */
void reset_window ( int style )
{
	CurrentStyle = style ;
	ResizeWindow();
# if SETwindowTitle
	WindSetName ( whandle, TitleBuffer ) ;
# endif
}


/*..................................................................

	+-------------------------------------------+---+	-------
	| C	|			title						| F	|		  ^
	+-------------------------------------------+---+	-	  |
	|											|	|	^	  |
	|		BlitWindow.dst.window				|	|	|	  |
	|											|	|  work	 curr
	|...........................................|	|	|	  |
	|		tools								|	|	v	  |
	+-------------------------------------------+---+	-	  |
	|											| S	|		  v
	+-------------------------------------------+---+	-------

..................................................................*/

	
/*--------------------------------------------- WindowMessage -----*/
int WindowMessage ( const char *newtitle, ... )
{
	int l ;
	
	l = vsprintf ( TitleBuffer, newtitle, (va_list)... ) ;
	ToolsTree[TX_MESG].ob_spec.tedinfo->te_ptext = TitleBuffer ;
	if ( ToolsVisible )
		ObjectDraw ( ToolsTree, TX_MESG	) ;
# if SETwindowTitle
	else
		wind_set ( whandle, WF_NAME, TitleBuffer ) ;
# endif
	return l ;
}

/*--------------------------------------------- set_window_title -----*/
void set_window_title ( void )
{
# if SETwindowTitle
	TprintfK (( "+ set_window_title" )) ;
	get_window_title ( TitleBuffer ) ;	
	TprintfK (( "  set_window_title : %s", TitleBuffer )) ;
# if SETwindowTitle == 1
	wind_set ( whandle, WF_NAME, TitleBuffer ) ;
# elif SETwindowTitle == 2
	wind_set ( whandle, WF_NAME,
			GetDmsdType() == 9051 ? "ScreenEye" : "ScreenEye +" ) ;
	TprintfK (( "- set_window_title" )) ;
# endif
# else
	TprintfK (( "* set_window_title off" )) ;
# endif
}


/* ------------------------------------------- open_window ------ */
void open_window ( void )
{
	TprintfK (( "+ open_window" )) ;
	if ( whandle < 0 )
	{
		check_zoom_pop() ;
		SetWindowFull() ;
		set_window_title() ;
	}
	TprintfK (( "- open_window" )) ;
}


/* ------------------------------------------- recalc_open_window ------ */
void recalc_open_window ( TRectangle *win )
{
	TRectangle	curr ;

	wind_calc ( WC_BORDER, CurrentStyle, 
				win->x, win->y,
				max ( win->w, ToolsWidth() ),
				win->h + ToolsHeight(),
				&curr.x, &curr.y, &curr.w, &curr.h ) ;

	wind_open ( whandle,
				curr.x, curr.y,
 				curr.w, curr.h ) ;
}

/* ------------------------------------------- reopen_window ------ */
void reopen_window ( void )
{
# if TEST > 1
	printf ("+reopen_window\n");
# endif TEST > 1
	if ( whandle >= 0 )
	{
		check_zoom_pop() ;
		recalc_open_window ( &BlitWindow.dst.window ) ;
	}
	else
		open_window() ;
# if TEST > 1
	printf ("-reopen_window\n");
# endif TEST > 1
}


/* ----------------------------------- set_clip_box --------------- */
void set_clip_box ( TRectangle *box, int *clip )
{
    *clip++ = box->x;
    *clip++ = box->y;
    *clip++ = box->x + box->w - 1;
    *clip++ = box->y + box->h - 1;
}

int test_color = WHITE ;

/* ----------------------------------- test_output --------------- */
void test_output ( TRectangle *box )
{
	int clip[4] ;

	set_clip_box ( box, clip ) ;

	if ( ++test_color >= 16 )
		test_color = WHITE ;
	vswr_mode ( vdi_handle, MD_REPLACE ) ;
	vsf_interior ( vdi_handle, FIS_SOLID ) ;
    vsf_color ( vdi_handle, test_color );
	mouse_off() ;
    vr_recfl ( vdi_handle, clip );              /* fill rectangle */
	mouse_on() ;
}

/* --------------------------------- restart_sliders ------------------- */
void restart_sliders ( void )
{
	calc_x_slider  ( 0, &BlitWindow.dst.window, &BlitWindow.src.window ) ;
	calc_y_slider  ( 0, &BlitWindow.dst.window, &BlitWindow.src.window ) ;
	update_sliders ( &BlitWindow.dst.window, &BlitWindow.src.window ) ;
}

/* ---------------------------------------- resize_window -------- */
void resize_window ( void )
{
	check_zoom_pop() ;
	ResizeWindow() ;
	get_picture ( GRAB_ON ) ;
}


/* ----------------------------------------- redraw_window -------- */
void redraw_window ( void )
{
	TRectangle box, curr ;
	int       	clip[4];

	if ( whandle < 0 )
		return ;

	vsf_color ( vdi_handle, BLUE ) ;
	vswr_mode ( vdi_handle, MD_REPLACE ) ;

	wind_get ( whandle, WF_FIRSTXYWH, &box.x, &box.y, &box.w, &box.h );
	wind_get ( whandle, WF_CURRXYWH, &curr.x, &curr.y, &curr.w, &curr.h );

	SetToolsWindow() ;

	mouse_off();
	while ( box.w > 0 && box.h > 0 )
    {
		set_clip_box ( &box, clip ) ;
    	if ( rc_intersect( &BlitWindow.dst.window, &box ) )
		{
			if ( madi_ok )
				repeat_pic() ;
            else	/* test output : coloured rectangles	*/
            	test_output ( &box ) ;
		}
		if ( ToolsVisible )
		    objc_draw ( ToolsTree, 0, 99, clip[0], clip[1], clip[2], clip[3] ) ;
		wind_get ( whandle, WF_NEXTXYWH, &box.x, &box.y, &box.w, &box.h );
	}
	mouse_on() ;
    vs_clip ( vdi_handle, 0, clip ) ;
}


/*--------------------------------------------- close_d_window ---*/
void close_d_window ( void )
{
	int top_window ;
	
	if ( whandle >= 0 )
	{
		wind_close ( whandle ) ;
		wind_get ( 0, WF_TOP, &top_window ) ;
		whandle = -1 ;
	}
}

/*--------------------------------------------- kill_d_window ---*/
void kill_d_window ( void )
{
	if ( whandle >= 0 )
	{
		wind_close ( whandle ) ;
		wind_delete ( whandle ) ;
		whandle = -1 ;
	}
}

/*--------------------------------------------- kill_digit_windows ---*/
void kill_digit_windows ( void )
{
	acc_opened = FALSE ;
	kill_d_window () ;
}


/*-------------------------------------------- ToggleWindowFulled ---------*/
void ToggleWindowFulled ( void )
{
	TRectangle prev, full, curr ;

	GetMaxWindowFrame ( &full ) ;
	wind_get ( whandle, WF_CURRXYWH, REFrect(curr) ) ;
	if ( DimensionsEqual ( curr, full ) )	/* is full	*/
	{
		wind_get ( whandle, WF_PREVXYWH, REFrect(prev) ) ;
		SetWindowRectangle ( &prev ) ;
	}
	else									/* not full	*/
	{
		SetWindowRectangle ( &full ) ;
	}
	get_picture ( GRAB_OFF ) ;
}


/*--------------------------------------------- ResetDigiImages ------*/
void ResetDigiImages ( TBlitWindow *blitwind )
{
	SetToFullSize ( &blitwind->src, NULL, MatDigiF.image.w, MatDigiF.image.h, 16 ) ;
	SetToFullSize ( &blitwind->dst, Logbase(), screen_size.x, screen_size.y, bit_planes ) ;
}


/*--------------------------------------------- ResetBlitWindow ------*/
void ResetBlitWindow ( TBlitWindow *blitwind, POINT *zoom )
{
	ResetDigiImages ( blitwind ) ;
	ResetDigiWindows ( blitwind ) ;
	*zoom = ZoomTable[menu_zoom] ;
}


