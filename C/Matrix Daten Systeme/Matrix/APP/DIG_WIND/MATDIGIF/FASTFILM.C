/*-------------------------------------------------------- Record ------*/
int Record ( void )
{
	mouse_busy();

	ToolSelect ( IS_RECORD ) ;
	ReleaseLeftButton();
	new_window_title ( "* Record # %d, Stop=Shift !", Sequence.frames ) ;
	if ( RecordSequence ( &Sequence, WaitUntilGrabbed ) == Sequence.frames )
		new_window_title ( "* Stop bei # %d !", Sequence.valid ) ;
	else
		new_window_title ( "* Abbruch bei # %d !", Sequence.valid ) ;
	ToolNormal ( IS_RECORD ) ;
	SetTrashState();

	mouse_arrow();

	return Sequence.valid ;
}

/*-------------------------------------------- RecordFilm --------*/
void RecordFilm ( void )
{
	if ( CheckSequenceEmpty() )
	{
		if ( MallocFilm() > 0 )
		{
			NewRunMode ( IDLE ) ;
			Record();
		}
	}
}

/*-------------------------------------------------------- Play ------*/
int Play ( void )
{
	int frames ;
	
	if ( CheckSequenceAvailable() )
	{
		mouse_off();
		ToolSelect ( IS_RIGHT ) ;
		ReleaseLeftButton();
		new_window_title ( "* Play # %d, Stop=Shift !", Sequence.valid ) ;
		if ( ( frames = PlaySequence ( &Sequence, &BlitWindow.dst ) ) == Sequence.valid )
			new_window_title ( "* Stop bei # %d !", frames ) ;
		else
			new_window_title ( "* Abbruch bei # %d !", frames ) ;
		ToolNormal ( IS_RIGHT ) ;
		mouse_on();
		return frames ;
	}
	else
		return 0 ;
}

/*-------------------------------------------- PlayFilm --------*/
void PlayFilm ( void )
{
	NewRunMode ( IDLE ) ;
	Play() ;
}


/*-------------------------------------------------------- Still ------*/
void Still ( int frame, int count )
{
	int displayed ;
	
	if ( CheckSequenceAvailable() )
	{
		NewRunMode ( IDLE ) ;

		if ( DisplaySequenceOn )
		{
			if ( ( StepFrame ( &Sequence, frame ) ) >= 0 )
				CheckCurrentDisplayed ( &Sequence, &BlitWindow.dst ) ;
		}
		else
		{
			mouse_off();
			do
			{
				displayed = DisplayFrame ( &Sequence, frame, &BlitWindow.dst ) ;
				if ( displayed < 0 )
				{
					new_window_title ( "* Stop !" ) ;
					break ;
				}
				DisplayNumber ( displayed ) ;
				if ( SkipInput() )
				{
					new_window_title ( "* Stop bei # %d !", displayed ) ;
					break ;
				}
				if ( ! ToolsOn )
					new_window_title ( "* Frame # %d", displayed ) ;
			}
			while ( --count != 0 ) ;
			mouse_on();
		}
		
	}
}




*** play / record loop

case F7 :		if ( CheckSequenceEmpty() )
				{
					if ( MallocFilm() == 0 )
						return 0 ;

					NewRunMode ( IDLE ) ;
					while ( Record() == Sequence.frames && ! SkipInput()
						 && Play()   == Sequence.frames && ! SkipInput() )
						/* loop */ ;
				}


case F8 :		RecordFilm();					return 0 ;
case F9:		PlayFilm();						return 0 ;

# if 0
case SHFT_CL:	Still ( BACKframe, 0 ) ;		return 0 ;
case SHFT_CR:	Still ( FORWframe, 0 ) ;		return 0 ;
# else
case '(' :		Still ( BACKframe, 0 ) ;		return 0 ;
case ')' :		Still ( FORWframe, 0 ) ;		return 0 ;
# endif



# else ! RECORDinAesLoop
	case IS_RECORD:	ToolSelect ( obj ) ;
					ReleaseLeftButton();
					DeleteFilm();
					RecordFilm();
					ToolNormal ( obj ) ;
					break ;

	case IS_RIGHT :	PlayFilm();
					break ;
	case IS_LEFT2 : ToolSelect ( obj ) ;
					Still ( BACKframe, 0 ) ;
					ToolNormal ( obj ) ;
					break ;

	case IS_RIGHT2: ToolSelect ( obj ) ;
					Still ( FORWframe, 0 ) ;
					ToolNormal ( obj ) ;
					break ;

	case IS_LEFT : 	NewRunMode ( PLAY_BACK );
					break ;

# endif

			