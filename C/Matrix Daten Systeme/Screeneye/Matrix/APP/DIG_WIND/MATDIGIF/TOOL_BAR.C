# include <stdlib.h>
# include <aes.h>
# include <vdi.h>
# include <stdio.h>
# include <string.h>
# include <linea.h>

# include <global.h>
# include <scancode.h>
# include <fast.h>

# define ESC	0x1b

# include "\pc\app\matdigif\digiblit.h"
# include "\pc\app\matdigif\film.h"
# include "\pc\app\dig_wind\menus.h"

# include "\pc\cxxsetup\aesutils.h"

# include "matdigif.h"
# include "matdigi.h"
# include "tool_bar.h"


bool	ToolBarOn    = TRUE ;
bool	ToolsVisible = FALSE ;

OBJECT 	*ToolsTree ;
TImageWindow LiveBox ;

int ToolsStartWidth = 0 ; 

/*............ film icon handling ...................................*/

# define _ICON(icnobj)	((icnobj)->ob_spec.iconblk)

ICONBLK  *FilmIcon ;
unsigned FilmIconPos = 0 ;
int 	 *FilmIconData ;

/*---------------------------------------------------- SetIconMaskColor ----*/
void SetIconMaskColor ( OBJECT *icnobj, int color )
{
	int *ibc ;
	
	ibc = &(_ICON(icnobj)->ib_char) ;
	*ibc &= 0xf0ff ;
	*ibc |= color << 8 ;
}

/*---------------------------------------------------- SetIconDataColor ----*/
void SetIconDataColor ( OBJECT *icnobj, int color )
{
	int *ibc ;
	
	ibc = &(_ICON(icnobj)->ib_char) ;
	*ibc &= 0x0fff ;
	*ibc |= color << 12 ;
}

/*---------------------------------------------------- GetIconDataColor ----*/
int GetIconDataColor ( OBJECT *icnobj )
{
	return ((unsigned)(_ICON(icnobj)->ib_char)) >> 12 ;
}

/*---------------------------------------------------- SwitchFilmIconColor ----*/
void SwitchFilmIconColor ( int color )
{
	SetIconDataColor(&ToolsTree[IS_FILM],color) ;
	if ( ToolsVisible )
		ObjectDraw ( ToolsTree, IS_FILM ) ;
}
	
# define NUMsteps	8

/*----------------------------------- StepFilm ------------------------*/
void StepFilm ( bool forw )
{
	if ( forw )
	{
		if ( ++FilmIconPos < NUMsteps )
		{
			FilmIcon->ib_pdata++ ;	/* icon-width = 16	*/
		}
		else
		{
			FilmIcon->ib_pdata = FilmIconData ;
			FilmIconPos = 0 ;
		}
	}
	else
	{
		if ( FilmIconPos > 0 )
		{
			FilmIconPos-- ;
			FilmIcon->ib_pdata-- ;	/* icon-width = 16	*/
		}
		else
		{
			FilmIcon->ib_pdata = FilmIconData + NUMsteps ;
			FilmIconPos = NUMsteps-1 ;
		}
	}
	ObjectDraw ( ToolsTree, IS_FILM ) ;
}

# define UNREADYcolor	LWHITE
# define READYcolor		BLUE

/*--------------------------------------- SignalReady ----------*/
void SignalReady ( int units, int of )
{
	TRectangle ReadyRectangle ;

	ObjectGetRectangle ( ToolsTree, TX_MESG, ReadyRectangle ) ;
	if ( units == 0 )
	{
		DrawBox ( &ReadyRectangle, UNREADYcolor ) ;
	}
	else if ( of > 0 )
	{		
		ReadyRectangle.w = iscale ( units, ReadyRectangle.w, of ) ;
		DrawBox ( &ReadyRectangle, READYcolor ) ;
	}
}

	
/*----------------------------------- ToolBarInit -------------------*/
void ToolBarInit ( void )
{
	int obj ;
	OBJECT *object ;

 	if ( rsrc_gaddr ( R_TREE, TRTOOLS16, &ToolsTree ) != 0 )
 	{
		ToolsStartWidth = ToolsTree->ob_width - 3 ;
# if 0
		ToolsTree->ob_height -= NUMsteps ;
# endif
		/* prepare film icon */
			
		FilmIcon = _ICON(&ToolsTree[IS_FILM]) ;
		FilmIconData = FilmIcon->ib_pdata ;
		FilmIcon->ib_hicon = ToolsTree[IS_FILM].ob_height -= NUMsteps ;
		SwitchFilmIconColor ( RED ) ;

		if ( bit_planes <= 2 )	/* black & white	*/
		{
			object = ToolsTree ;
			for ( obj = 0; obj <= TX_MESG; obj++, object++ )
			{
				switch ( object->ob_type )
				{
 case G_BOX :
 case G_IBOX :		object->ob_spec.obspec.interiorcol = WHITE ;
					break ;
 case G_TEXT :
 case G_BOXTEXT :
 case G_FTEXT :
 case G_FBOXTEXT :	object->ob_spec.tedinfo->te_color &= 0xfff0 ;
 					break ;

 case G_ICON :		SetIconMaskColor ( object, WHITE ) ;
					SetIconDataColor ( object, BLACK ) ;
					break ;
				}
			}
			
		}

# if 0
		ToolsTree[IS_TRASH].ob_state = DISABLED ;
# elif 0
		ObjectHide ( ToolsTree, IS_TRASH ) ;
# else
		SetIconMaskColor ( &ToolsTree[IS_TRASH], LWHITE ) ;
# endif
	}
	else
	{
 		printf ( "\033H*** RSC error : rsrc_gaddr ( .. TRTOOLS .. )\n" ) ;
 		ToolsTree = NULL ;
 	}
}

/*-------------------------------------------- SetToolsWindow ------*/
void SetToolsWindow ( void )
{
	ToolsTree->ob_x = BlitWindow.dst.window.x ;
	ToolsTree->ob_y = BlitWindow.dst.window.y + BlitWindow.dst.window.h ;
	ToolsTree->ob_width = max ( ToolsStartWidth, BlitWindow.dst.window.w ) ;
	
	LiveBox.image    = BlitWindow.dst.image ;
	LiveBox.window.x = ToolsTree->ob_x + ToolsTree[IS_LIVE_BOX].ob_x ;
	LiveBox.window.y = ToolsTree->ob_y + ToolsTree[IS_LIVE_BOX].ob_y ;
	LiveBox.window.w = ToolsTree[IS_LIVE_BOX].ob_width ;
	LiveBox.window.h = ToolsTree[IS_LIVE_BOX].ob_height ;
}	


/*-------------------------------------------- DrawToolBar ---------------*/
void DrawToolBar ( TRectangle *clip )
{
	TRectangle full ;
	
	if ( clip == NULL )
	{
		full.x = 0 ;
		full.y = 0 ;
		full.w = max_x ;
		full.h = max_y ;

		clip = &full ;
	}

	SetToolsWindow() ;
	
    objc_draw ( ToolsTree, 0, 99, clip->x, clip->y, clip->w, clip->h ) ;
}

/*---------------------------------------------------- SetTrashState ----*/
void SetTrashState ( void )
{
# if 0
	ObjectChange ( ToolsTree, IS_TRASH,
						Sequence.valid > 0 ? NORMAL : DISABLED,
							ToolsVisible ) ;
# else
# if 0
	if ( Sequence.valid > 0 )
		ObjectUnhide ( ToolsTree, IS_TRASH ) ;
	else
		ObjectHide ( ToolsTree, IS_TRASH ) ;
# else
	SetIconMaskColor ( &ToolsTree[IS_TRASH], Sequence.valid > 0 ? GREEN : LWHITE ) ;
# endif
	if ( ToolsVisible )
		ObjectDraw ( ToolsTree, IS_TRASH ) ;
# endif
}

/* ------------------------------------------------- ToolSelected ------- */
bool ToolSelected ( int obj )
{
	return ObjectSelected ( ToolsTree, obj ) ;
}

/* ------------------------------------------------- ToolSelect ------- */
void ToolSelect ( int obj )
{
	ObjectSetState ( ToolsTree, obj, SELECTED ) ;
	if ( ToolsVisible )
		ObjectDraw ( ToolsTree, obj ) ;
}

/* ------------------------------------------------- ToolNormal ------- */
void ToolNormal ( int obj )
{
	ObjectClearState ( ToolsTree, obj, SELECTED ) ;
	if ( ToolsVisible ) 
		ObjectDraw ( ToolsTree, obj ) ;
}

/* ------------------------------------------------- ToolNormal ------- */
bool ToggleTool ( int obj )
{
	bool nowselected ;
	
	nowselected = ! ToolSelected ( obj ) ;
	if ( nowselected )
		ToolSelect ( obj ) ;
	else
		ToolNormal ( obj ) ;
	return nowselected ;
}


# define MAXlength	6

int CurrTextField  = -1 ;
int CurrColor 	   = 0 ;
int *CurrValue 	   = NULL ;
int CharsInput	   = 0 ;
int MaxInput	   = 0 ;
						/*      0        1     2   3    4       5	*/
int MaxiTab[MAXlength+1] = { -32767,      9, 99, 999, 9999, 32767,  32767 } ; 
int MiniTab[MAXlength+1] = { +32767, +32767, -9, -99, -999, -9999, -32767 } ; 
char *FormatTable[MAXlength+1] = 
						   { "", "%d", "%02d", "%03d", "%04d", "%05d", "%06d" } ;


# define SELtextColor	RED

/*----------------------------------- GetNumberFormat --------------------*/
char *GetNumberFormat ( int l )
{
	return FormatTable [ (unsigned)l <= MAXlength ? l : MAXlength ] ;
}


/*------------------------------------------ DeselectCurrTextField -------*/
int DeselectCurrTextField ( void )
{
	int oldfield ;

	oldfield = CurrTextField ;
	if ( CurrTextField >= 0 )
	{	
		ToolsTree[CurrTextField].ob_spec.tedinfo->te_color = CurrColor ;
		if ( ToolsVisible )
			ObjectDraw ( ToolsTree, CurrTextField ) ;
		CurrTextField = -1 ;
		CurrValue = NULL ;
	}
	return oldfield ;
}


/*------------------------------------------ SelectTextField -------*/
void SelectTextField ( int obj, int *pval )
{
	int *pcolor ;
	TEDINFO *tedinfo ;
	
	if ( CurrTextField >= 0 )
		DeselectCurrTextField() ;

	tedinfo = ToolsTree[obj].ob_spec.tedinfo ;
	pcolor = &tedinfo->te_color ;

	CurrTextField = obj ;
	CurrColor = *pcolor ;
	*pcolor = ( *pcolor & 0x0fff ) | ( SELtextColor << 12 ) ;
	CharsInput = 0 ;
	MaxInput = (int)strlen ( tedinfo->te_ptext ) ;
	CurrValue = pval ;
	if ( pval != NULL )
	{
		if ( MaxInput > MAXlength )
			MaxInput = MAXlength ;
		SetToolNumber ( obj, *pval ) ;
	}
	else if ( ToolsVisible )
		ObjectDraw ( ToolsTree, obj ) ;
}

/*------------------------------------ EnterCurrTextField -------*/
void EnterCurrTextField ( int key )
{
	if ( CurrTextField >= 0 )
	{
		if ( CurrValue != NULL )	/* signals Number field	*/
		{
			int newval ;

			newval = *CurrValue ;
			switch ( key )
			{
	case '+' :	newval += 1 ;
				CharsInput = 0 ;
				break ;
	case '-' :	newval -= 1 ;
				CharsInput = 0 ;
				break ;
	case ESC :	newval = 0 ;
				CharsInput = 0 ;
				break ;
	default :	if ( key >= '0' && key <= '9' )
				{
					int digit ;

					digit = key - '0' ;
					if ( CharsInput == 0 )
					{
						newval = digit ;
						CharsInput++ ;
					}
					else
					{
						if ( CharsInput >= MaxInput )	/* over	*/
						{
							if ( MaxInput > 1 )
								newval %= (MaxiTab[MaxInput-1]+1) ;	/* cut max digit	*/
							else
								newval = 0 ;
						}
						else
							CharsInput++ ;
						newval = newval * 10 + digit ;
					}
				}
				else
					return ;
				break ;
			}
			if ( newval >= MiniTab[MaxInput]
			  && newval <= MaxiTab[MaxInput] )
				SetToolNumberFormat ( CurrTextField, *CurrValue = newval,
									GetNumberFormat ( MaxInput ) ) ;
		}
		else
		{
			char *txt ;
	
			txt = ToolsTree[CurrTextField].ob_spec.tedinfo->te_ptext ;
			switch ( key )
			{
case BACKSPACE :
case DELETE :	if ( CharsInput > 0 )
					txt[--CharsInput] = ' ' ;
				else
					return ;
				break ;	
case ESC :		strset ( txt, ' ' ) ;
				CharsInput = 0 ;
				break ;
default :		if ( CharsInput == 0 )
					strset ( txt, ' ' ) ;
				if ( CharsInput < MaxInput )
					txt[CharsInput++] = key ;
				else			/* over	*/
					return ;
				break ;
			}
			ObjectDraw ( ToolsTree, CurrTextField ) ;
		}
	}
}


/*------------------------------------ GetCurrTextField -------*/
int GetCurrTextField ( void )
{
	return CurrTextField ;
}

/*----------------------------------- SetToolNumber --------------------*/
void SetToolNumber ( int obj, int n )
{
	char *txt ;
	
	txt = ToolsTree[obj].ob_spec.tedinfo->te_ptext ;
	
	if ( n == INVALID )
		strset ( txt, '-' ) ;
	else
		sprintf ( txt, GetNumberFormat ( (int)strlen ( txt ) ), n ) ;
	if ( ToolsVisible )
		ObjectDraw ( ToolsTree, obj ) ;
}

/*----------------------------------- SetToolNumberFormat --------------------*/
void SetToolNumberFormat ( int obj, int n, char *format )
{
	char *txt ;
	
	txt = ToolsTree[obj].ob_spec.tedinfo->te_ptext ;
	
	if ( n == INVALID )
		strset ( txt, '-' ) ;
	else
		sprintf ( txt, format, n ) ;
	if ( ToolsVisible )
		ObjectDraw ( ToolsTree, obj ) ;
}



int RunIcons[] =
{
	IS_STOP,    IS_TV,     IS_RECORD,
	IS_RIGHT,   IS_LEFT,   IS_RIGHT2, IS_LEFT2,
	IS_RD_DISK, IS_WR_DISK
} ;

/*------------------------------------------ GetToolIcon --------------*/
int GetToolIcon ( void )
{
	return RunIcons[RunMode] ;
}


