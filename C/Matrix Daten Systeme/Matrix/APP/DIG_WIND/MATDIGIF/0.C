/* ------------------------------------------- reset_window ------ */
void reset_window ( int style )
{
# if 1
	CurrentStyle = style ;
	ResizeWindow();
/*
	SetWindowFull() ;
*/

	WindSetName ( whandle, TitleBuffer ) ;
# else
	RECTangle	curr ;

	CurrentStyle = style ;

	wind_calc ( WC_BORDER, style, 
				BlitWindow.dst.window.x, BlitWindow.dst.window.y,
				BlitWindow.dst.window.w, BlitWindow.dst.window.h + ToolsHeight(),
				&curr.x, &curr.y, &curr.w, &curr.h ) ;

	wind_close ( whandle ) ;
	wind_delete ( whandle ) ;
	whandle = wind_create ( style, DeskTop.x, DeskTop.y, DeskTop.w, DeskTop.h ) ;

	wind_open ( whandle,
				curr.x, curr.y,
 				curr.w, curr.h ) ;

	if ( whandle > 0 )
	{
		wind_get ( whandle, WF_WORKXYWH,
				   &BlitWindow.dst.window.x, &BlitWindow.dst.window.y,
				   &BlitWindow.dst.window.w, &BlitWindow.dst.window.h ) ;
		wind_set ( whandle, WF_NAME, TitleBuffer ) ;
		if ( ToolBarOn )
		{
			BlitWindow.dst.window.h -= ToolsTree->ob_height ;
			DrawToolBar ( NULL ) ;
		}
	}
# endif
}

# if 0
/*-------------------------------------------- LoadFilm --------*/
void LoadFilm ( void )
{
	int nread ;
	
	if ( CheckSequenceEmpty() )
	{
		mouse_busy();

		strcat ( strcpy ( BaseName, CurrentFileDir ), CurrentFilmStem ) ;
		NewRunMode ( IDLE ) ;
		WindowMessage ( "* Lesen '%s'", CurrentFilmName ) ;
		if ( ( nread = SequenceRead ( &Sequence, BaseName, Mini, Maxi ) ) > 0 )
		{
			SetCounter ( Sequence.current ) ;
			SetToolNumber ( IS_MAX, nread ) ;
		}
		else
		{
			WindowMessage ( "* Lesefehler" ) ;
			SetToolNumber ( IS_MAX, INVALID ) ;
			SetCounter ( INVALID ) ;
		}
		mouse_arrow();
	}
}

/*--------------------------------------------- SaveFilm -----------------*/
void SaveFilm ( void )
{
	char basename[128] ;
	
	if ( CheckSequenceAvailable() )
	{
		mouse_busy();

		strcat ( strcpy ( BaseName, CurrentFileDir ), CurrentFilmStem ) ;
		WindowMessage ( "* Schreiben '%s'", BaseName ) ;
# if 1
		if ( SequenceWrite ( &Sequence, BaseName, Mini, Maxi ) == 0 )
			WindowMessage ( "* Schreibfehler" ) ;
# else
		WindowMessage ( "* write disabled" ) ;
# endif
		mouse_arrow();
	}
}
# endif



# if 0
extern void StepCurrNumberField ( int step ) ;
/*------------------------------------ StepCurrNumberField -------*/
void StepCurrNumberField ( int step )
{
	if ( CurrTextField >= 0 )
		SetToolNumber ( CurrTextField, *CurrValue += step ) ;
}

extern void SetCurrTextField ( int value ) ;
/*------------------------------------ SetCurrNumberField -------*/
void SetCurrNumberField ( int value )
{
	if ( CurrTextField >= 0 )
		SetToolNumber ( CurrTextField, *CurrValue = value ) ;
}
# endif




# if 0
# define MINpar	-9
# define MAXpar	99

/*----------------------------------- DisplayParameter --------------------*/
bool DisplayParameter ( int n )
{
	char *txt ;
	bool ok ;
	
	txt = ToolsTree[IS_PARAM].ob_spec.tedinfo->te_ptext ;
	
	if ( n < MINpar )
	{
		strcpy ( txt, " <" ) ;
		ok = FALSE ;
	}
	else if ( n > MAXpar )
	{
		strcpy ( txt, " >" ) ;
		ok = FALSE ;
	}
	else
	{
		sprintf ( txt, "%2d", n ) ;
		ok = TRUE ;
	}
	if ( ToolsOn )
		ObjectDraw ( ToolsTree, IS_PARAM ) ;
	return ok ;
}
# endif


# if 0
	{
		int i ;
		printf ( "\033H\033K" ) ;
		for ( i = 0; i < 10; i+=2 )
			printf ( "%d:%d ", RubberPts[i], RubberPts[i+1] ) ;
	}
# endif
/* ------------------------------------------- chk_window ------ */
void chk_window ( TRectangle *win, TRectangle *curr, TRectangle *vid )
{
	if ( curr->x < DeskTop.x )
		curr->x = DeskTop.x ;
	if ( curr->y < DeskTop.y )
		curr->y = DeskTop.y ;
	wind_set ( whandle, WF_CURRXYWH, curr->x, curr->y, curr->w, curr->h ) ;
	wind_get ( whandle, WF_WORKXYWH, &win->x, &win->y, &win->w, &win->h ) ;
	win->w = min ( win->w, screen_size.x - win->x ) ;
	win->h = min ( win->h, screen_size.y - win->y ) ;
	update_sliders ( win, vid ) ;
}

/* ------------------------------------------- calc_window ------ */
void calc_window ( TRectangle *win, TRectangle *vid )
{
	TRectangle	curr, work ;
	int windh ;
	
	BlitWindow.dst.window.w = ( MatDigiFImage.w / Zoom.x ) - border_left - border_x ;
	BlitWindow.dst.window.h = ( MatDigiFImage.h / Zoom.y ) - head_y - tail_y ;

	wind_calc ( WC_WORK, CurrentStyle, 	/* calc max work	*/
				DeskTop.x, DeskTop.y, DeskTop.w, DeskTop.h,
				&work.x, &work.y, &work.w, &work.h ) ;

	if ( BlitWindow.dst.window.w <= work.w )	/* center window	*/
	{
		work.x += ( work.w - BlitWindow.dst.window.w ) / 2 ;
		work.w = BlitWindow.dst.window.w ;
	}

	windh = BlitWindow.dst.window.h + ToolsHeight() ;
	if ( windh <= work.h )
	{
		work.y += ( work.h - windh ) / 2 ;
		work.h = windh ;
	}

	BlitWindow.dst.window = work ;

	vid->x = border_left ;
	vid->y = head_y ;

	wind_calc ( WC_BORDER, CurrentStyle, 
				work.x, work.y, work.w, work.h,
				&curr.x, &curr.y, &curr.w, &curr.h ) ;

	chk_window ( win, &curr, vid ) ;
}

/*----------------------------------- WindowMovedOrSized ---------*/
void WindowMovedOrSized ( TRectangle *newrect )
{
	TRectangle work, curr ;
	int maxw, maxh ;
			
	wind_calc ( WC_WORK, CurrentStyle, 
				newrect->x, newrect->y, newrect->w, newrect->h,
				&work.x, &work.y, &work.w, &work.h ) ;
	maxw = ( MatDigiFImage.w / Zoom.x ) - border_left - border_x ;
	maxh = ( MatDigiFImage.h / Zoom.y ) - head_y - tail_y ;
	if ( work.w > maxw )
		work.w = maxw ;
	if ( work.h > maxh )
		work.h = maxh ;
	wind_calc ( WC_BORDER, CurrentStyle, 
				work.x, work.y, work.w, work.h,
				&curr.x, &curr.y, &curr.w, &curr.h ) ;
	chk_window ( &BlitWindow.dst.window, &curr, &BlitWindow.src.window ) ;
}

