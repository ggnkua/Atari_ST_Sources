/********************************************************************/
/* 				MatDigi Window Program - Parameter Menus			*/
/*																	*/
/*------------------------------------------------------------------*/
/*	Status : 27.09.93												*/
/*																	*/
/*  HG - Matrix Daten Systeme, Talstr. 16, W-71570 Oppenweiler		*/
/*																	*/
/********************************************************************/

# include <stdlib.h>
# include <stdio.h>
# include <string.h>
# include <vdi.h>
# include <aes.h>
# include <tos.h>
# include <scancode.h>

# include <global.h>
# include <popup.h>
/*# define popup_update(p,b) popup_set_value(p,*((p)->pvalue),(int)b)*/

# include "\pc\cxxsetup\dialog.h"
# include "\pc\cxxsetup\aesutils.h"

# ifdef __MATDIGIF__
# include "\pc\app\matdigif\digiblit.h"
# include "\pc\app\matdigif\digitise.h"
# include "\pc\app\matdigif\mdf_lca.h"
# include "matdigif\mdf_vers.h"
# endif __MATDIGIF__
# ifdef __MATDIGIR__
# include "matdigir\mdr_vers.h"
# include "savefile.h"
# endif __MATDIGIR__
# ifdef __MATDIGI1__
# include "matdigi1\md1_vers.h"
# endif __MATDIGI1__
# include "menus.h"
# include "matdigif\matdigif.h"

# include "matdigif\tool_bar.h"
# include "matdigif\digiwind.h"

unsigned		madi_ok ;

TBlitWindow		BlitWindow ;
TImageWindow	MatDigiF ;

POINT			ZoomTable[NUMzoomCodes] =
{	/*	X	Y							320 x 240			320 x 480			*/
	{	1,	1 	},	/*	720 x 288	: full image								*/
	{	2,	1 	},	/*	360 x 288	: 1:1 aspect ratio							*/
	{	4,	1 	},	/*	180 x 288	: 						1:1 aspect ratio	*/
	{	4,	2 	},	/*	180 x 144	: 1/4 image fast mode						*/
	{	8,	2 	}	/*	 90 x 144	: 						1/4 image fast mode	*/
} ;

unsigned		menu_zoom = Z42 ;	/* 1:1 mode	*/
POINT			Zoom ;
	
int    			whandle ;

POINT 			screen_size ;
int				aes_version ;

long			video_cookie = 0 ;
long			cpu_cookie = 0 ;
long			fram_cookie = 0 ;
int	   			bit_planes ;
unsigned 		end_program ;
unsigned 		border_x ;
unsigned 		head_y ;
unsigned		tail_y = 0 ;
int				Drive ;
int 			cycle ;
int    			max_x, max_y ;

TRectangle  	DeskTop ;
int 			old_menu_zoom ;

# ifdef __MATDIGIF__
DISPLAY_MODE	menu_dmode = ZCOLOUR ;
# else
DISPLAY_MODE	menu_dmode = ZMONO ;
# endif __MATDIGIF__

unsigned 		menu_vsignal = PUP_CVBS ;
unsigned 		menu_vsource = 1 ;

# ifdef __MATDIGIF__
# else !__MATDIGIF__
unsigned		menu_vfactor = 4 ;
# endif !__MATDIGIF__


DISPLAY_MODE	dmode ;
# ifndef __MATDIGIF__
unsigned 	video_signal ;
unsigned 	video_source ;
# else
extern unsigned	video_signal ;
extern unsigned	video_source ;
# endif !__MATDIGIF__

TRunMode 		RunMode  = IDLE ;
int				whole ;

TGrabMode		grab ;
SPEED_MODE		speed ;

OBJECT			*matdigi_tree ;
POPUP_MENU		*popup_dmode ;
POPUP_MENU		*popup_channel ;
POPUP_MENU		*popup_signal ;
POPUP_MENU		*popup_format ;
POPUP_MENU		*popup_grab ;
POPUP_MENU		*popup_digitise ;
POPUP_MENU		*popup_speed ;
POPUP_MENU		*popup_save ;


/* ---------------------------------------- init_menus ------------- */
void init_menus ( void )
{
	if ( rsrc_gaddr ( R_TREE, MD_PARAM, &matdigi_tree ) != 0 )
	{
		popup_dmode = popup_create ( SELECTsingle,
					 matdigi_tree, TX_DISPLAY,
					 MD_POPUP, MD_DISPLAY,
					 &(int)menu_dmode, 0, NULL ) ;

		popup_channel = popup_create ( SELECTsingle,
					 matdigi_tree, TX_CHANNEL,
					 MD_POPUP, MD_CHANNEL,
					 &(int)menu_vsource, 0, NULL ) ;

		popup_signal = popup_create ( SELECTsingle,
					 matdigi_tree, TX_SIGNAL,
					 MD_POPUP, MD_SIGNAL,
					 &(int)menu_vsignal, 0, NULL ) ;

		popup_format = popup_create ( SELECTsingle,
					 matdigi_tree, TX_FORMAT,
					 MD_POPUP, MD_FORMAT,
					 &(int)menu_zoom, 0, NULL ) ;

		popup_grab = popup_create ( SELECTsingle,
					 matdigi_tree, TX_GRAB,
					 MD_POPUP, MD_GRAB,
					 &(int)grab, 0, NULL ) ;

		popup_speed = popup_create ( SELECTsingle,
					 matdigi_tree, TX_SPEED,
					 MD_POPUP, MD_SPEED,
					 &(int)speed, 0, NULL ) ;

		popup_digitise = popup_create ( SELECTsingle,
					 matdigi_tree, TX_DIGITISE,
					 MD_POPUP, MD_DIGITISE,
					 &(int)RunMode, 0, NULL ) ;

		popup_save = popup_create ( SELECTsingle,
					 matdigi_tree, TX_SAVE,
					 MD_POPUP, MD_SAVE,
					 &(int)whole, 0, NULL ) ;

		popup_update ( popup_dmode, 0 ) ;
		popup_update ( popup_channel, 0 ) ;
		popup_update ( popup_signal,  0 ) ;
		popup_update ( popup_format, 0 ) ;
		popup_update ( popup_grab, 0 ) ;
		popup_update ( popup_speed, 0 ) ;
		popup_update ( popup_digitise, 0 ) ;
		popup_update ( popup_save, 0 ) ;
	}
}


/* ---------------------------------------- GetZoomCode ----------- */
int GetZoomCode ( POINT *zoom )
{
	int i ;
	
	for ( i = 0 ; i < NUMzoomCodes ; i++ )
		if ( ZoomTable[i].x == zoom->x && ZoomTable[i].y == zoom->y )
			return i ;
	return 0 ;
}

/* ---------------------------------------- check_format_pop ------------- */
void check_format_pop ( void )
{
	menu_zoom = GetZoomCode ( &Zoom ) ;
	popup_update ( popup_format, 0 ) ;
}

/* ---------------------------------------- check_signal_pop ------------- */
void check_signal_pop ( void )
{
	menu_vsignal = video_signal ;
	popup_update ( popup_signal, 0 ) ;
}


/* ---------------------------------------- check_source_pop ------------- */
void check_source_pop ( void )
{
	menu_vsource = video_source ;
	popup_update ( popup_channel, 0 ) ;
}


char *empty_mesg = "" ;
/*--------------------------------------------- get_free_string ------*/
char *get_free_string ( int tree )
{
	char *m ;
	
	if ( rsrc_gaddr ( R_STRING, tree, &m ) != 0 )
		return m ;
	else
		return empty_mesg ;
}


/* ---------------------------------------- check_display_pop ------------- */
void check_display_pop ( int planes )
{
# ifdef __MATDIGIF__
	planes = planes;
# else __MATDIGIR__ / __MATDIGIR__

	if ( ( vfactor == 4) && ( menu_dmode == ZCOLOUR ) )
		form_alert ( 1, get_free_string ( AL_GREY ) ) ;

# ifdef __MATDIGI1__
	if ( vfactor == 4 )
# endif __MATDIGI1__

# ifdef __MATDIGIR__			
	if ( ( planes < 8 ) && ( menu_dmode == ZCOLOUR ) )
		form_alert ( 1, get_free_string ( AL_BPP ) ) ;
	if ( ( vfactor == 4) || ( planes < 8 ) )
# endif __MATDIGIR__

		popup_object_change ( popup_dmode, PD_COLOUR, DISABLED, 0 ) ;
	else
		popup_object_change ( popup_dmode, PD_COLOUR, 0, 0 ) ;

	if ( planes == 1 )
		popup_object_change ( popup_dmode, PD_GREY, DISABLED, 0) ;
	else
		popup_object_change ( popup_dmode, PD_GREY, 0, 0 ) ;
#endif __MATDIGI1__ / __MATDIGIR__

	menu_dmode = dmode ;
	popup_update ( popup_dmode, 0 ) ;
}


/* ---------------------------------------- check_grab_pop ------------- */
void check_grab_pop ( void )
{
	popup_update ( popup_grab, 0 ) ;
}


/* ---------------------------------------- check_speed_pop ------------- */
void check_speed_pop ( void )
{
	int style ;

	popup_update ( popup_speed, 0 ) ;
# ifndef __MATDIGIF__
	if ( speed == MAX_SPEED )
		style = NAME|MOVER ;
	else
# endif !__MATDIGIF__
		style = WINDOW_TYPE ;

	if ( whandle >= 0 )
		reset_window ( style ) ;
}


/* ---------------------------------------- check_digitise_pop ------------- */
void check_digitise_pop ( void )
{
/*
	popup_update ( popup_digitise, 0 ) ;
*/
}


/* ---------------------------------------- check_save_pop ------------- */
void check_save_pop ( void )
{
	popup_update ( popup_save, 0 ) ;
}


/* ------------------------------------------ get_obj_addr ---------*/
void *get_obj_addr (OBJECT *obj)
{
	void	*ans;
	
	switch (obj->ob_type)
	{
case G_TEXT		:
case G_BOXTEXT	:
case G_FTEXT	:
case G_FBOXTEXT	:	ans = obj->ob_spec.tedinfo->te_ptext;
					break;
case G_IMAGE	:	ans = obj->ob_spec.bitblk;
					break;
#ifndef __STDC__
case G_USERDEF	:	ans = obj->ob_spec.userblk;
					break;
# endif
case G_ICON		:	ans = obj->ob_spec.iconblk;
					break;
case G_BUTTON	:
case G_STRING	:
case G_TITLE	:	ans = obj->ob_spec.free_string;
					break;
case G_IBOX		:
case G_BOXCHAR	:
case G_BOX		:	ans = (void *) &obj->ob_spec.obspec;
					break;
	default		:	ans = NULL;
	}
	return (ans);
} /*- get_obj_addr -*/


/* ------------------------------------------ get_child_addr ------*/
OBJECT *get_child_addr (int tree, int child)
{
	OBJECT		*tree_ptr,
				*obj = NULL;

	if ((rsrc_gaddr (R_TREE, tree, &tree_ptr) != 0))
		obj = (OBJECT *) (tree_ptr + child);
	return (obj);
} /*- get_child_addr -*/


/* ------------------------------------------ FetchTreeInt --------*/
void FetchTreeInt (int tree, int child, int *old)
{
	char		*new;
	OBJECT		*obj;

	obj = get_child_addr (tree, child);		
	new = get_obj_addr (obj);
	*old = atoi (new);
} /*- FetchTreeInt -*/


/* ------------------------------------------ UpdateTreeInt --------*/
void UpdateTreeInt (int tree, int child, const int *new)
{
	char		*old;
	OBJECT		*obj;

	obj = get_child_addr (tree, child);		
	old = get_obj_addr (obj);
	itoa (*new, old, 10);
} /*- UpdateTreeInt -*/


/* ------------------------------------------ UpdateTreeString -----*/
void UpdateTreeString (int tree, int child, const char *new)
{
	char		*old;
	OBJECT		*obj;

	obj = get_child_addr (tree, child);		
	old = get_obj_addr (obj);
	strcpy (old, new);
} /*- UpdateTreeString -*/


/*--------------------------------------------- get_rsc_string -----*/
void get_rsc_string ( int txt, char *string )
{
	strcpy ( string, get_free_string ( txt ) ) ;
}


/* ------------------------------------------- FetchAttributes ---*/
unsigned int FetchAttributes (int tree, int child)
{
	OBJECT		*obj;

	obj = get_child_addr (tree, child);
	return (obj->ob_state);
} /*- FetchAttributes -*/


/* ------------------------------------------ UpdateAttributes ---*/
void UpdateAttributes (int tree, int child,
					   int new, int redraw)
{
	OBJECT		*tree_ptr;

	if ((rsrc_gaddr (R_TREE, tree, &tree_ptr) != 0))
	{
		objc_change (tree_ptr, child, 0,
					 tree_ptr->ob_x, tree_ptr->ob_y,
					 tree_ptr->ob_width, tree_ptr->ob_height,
		  			 new, redraw);
	}
} /*- UpdateAttributes -*/


unsigned old_head_y ;
unsigned old_border_x ;
/* ---------------------------------------- check_video_param ------------- */
int check_video_param ( void )
{
	unsigned maxx, maxy ;
	int result ;
	
	maxx = MatDigiF.image.w / Zoom.x ;		/* max video width  / 2*/
	maxy = MatDigiF.image.h / Zoom.y ;		/* max video height / 2*/
	FetchTreeInt ( MD_BORDER, ED_BORDER, (int *)&border_x ) ;
	if ( border_x > maxx )
	{
		border_x = maxx ;
		UpdateTreeInt ( MD_BORDER, ED_BORDER, (int *)&border_x ) ;
	}
	FetchTreeInt ( MD_BORDER, ED_HEAD, (int * )&head_y ) ;
	if ( head_y >  maxy )
	{
		head_y = maxy ;
		UpdateTreeInt ( MD_BORDER, ED_HEAD, (int * )&head_y ) ;
	}
	result = ( ( head_y != old_head_y ) || ( border_x != old_border_x) ) ;
	old_head_y = head_y ;
	old_border_x = border_x ;
	return result ;
}


/* ---------------------------------------- setup_video_param ------------- */
void setup_video_param ( void )
{
	UpdateTreeInt ( MD_BORDER, ED_HEAD, (int * )&head_y ) ;
	UpdateTreeInt ( MD_BORDER, ED_BORDER, (int *)&border_x ) ;
	old_head_y = head_y ;
	old_border_x = border_x ;
}


/*--------------------------------------------- get_window_title -----*/
void get_window_title ( char *info )
{
	char	signal[6] ;
	char	status[14] ;
	bool 	locked, code, fidt ;
	
	if ( madi_ok )
	{
		switch ( video_signal ) 
		{
	case PUP_SVHS :	get_rsc_string ( T_SVHS, signal ) ;
					break ;
	case PUP_CVBS :	get_rsc_string ( T_FBAS, signal ) ;
					break ;
	case PUP_BAS :	get_rsc_string ( T_BAS, signal ) ;
					break ;
	default :		get_rsc_string ( T_AUTO, signal ) ;
		}

		GetDmsdStatus ( &locked, &code, &fidt ) ;
		if ( locked )
		{
			if ( code )
				get_rsc_string ( T_LKC, status ) ;
			else
				get_rsc_string ( T_LKBW, status ) ;
		}
		else
			get_rsc_string ( T_UNLK, status ) ;

		sprintf ( info, "%d : %s %s",
						 video_source,
						 signal,
						 status ) ;
	}
	else
		get_rsc_string ( T_NOK, info ) ;
}


/* ---------------------------------------- setup_param ------------- */
void setup_param ( void )
{
	video_signal = menu_vsignal ; 
	video_source = menu_vsource ;
	menu_zoom 	 = GetZoomCode ( &Zoom ) ;
	dmode		 = menu_dmode ;
}


/*---------------------------------------------- mtree_dialog -----*/
int mtree_dialog ( OBJECT *fromtree, int fromobj,
				  OBJECT *dialtree, int editstart )
{
	RECTangle rect, fr ;
	int ex_object ;

	form_center ( dialtree, &rect.x, &rect.y, &rect.w, &rect.h ) ;
	FormDialStart ( rect ) ;

	if ( fromtree != NULL )
	{
		fromtree[fromobj].ob_state |= SELECTED ;
		ObjectDraw ( fromtree, fromobj ) ;
		ObjectGetRectangle ( fromtree, fromobj, fr ) ;
		FormDialGrow ( fr, rect ) ;
	}
	
	ObjectDraw ( dialtree, 0 ) ;	/* draw from TOP */

	ex_object = FormDo ( dialtree, editstart ) ;
	dialtree[ex_object & 0x7FFF].ob_state &= ~ SELECTED ;
	
	if( fromtree != NULL )
	{
		FormDialShrink ( fr, rect ) ;
		fromtree[fromobj].ob_state &= ~ SELECTED ;
		ObjectDraw ( fromtree, fromobj ) ;
	}
	
	FormDialFinish ( rect ) ;
	return ( ex_object ) ;
}


/*---------------------------------------------- handle_fdialog -----*/
int handle_fdialog ( OBJECT *fromtree, int fromobj,
					 int dialtr, int editstart )
{
	OBJECT *dialtree ;

	if( rsrc_gaddr( R_TREE, dialtr, &dialtree ) != 0)
		return ( mtree_dialog ( fromtree, fromobj,
								dialtree, editstart ) ) ;
	else
		return -1 ;
}


/*---------------------------------------------- mopen_dialog -----*/
void mopen_dialog ( OBJECT *fromtree, int fromobj,
				    OBJECT *dialtree, RECTangle *rect, RECTangle *fr )
{
	form_center ( dialtree, &rect->x, &rect->y, &rect->w, &rect->h ) ;
	FormDialStart ((*rect));

	if( fromtree != NULL )
	{
		fromtree[fromobj].ob_state |= SELECTED ;
		ObjectDraw ( fromtree, fromobj ) ;
		ObjectGetRectangle ( fromtree, fromobj, (*fr) ) ;
		FormDialGrow ( (*fr), (*rect) ) ;
	}
	
	ObjectDraw  ( dialtree, 0 );	/* draw from TOP */
}


/*---------------------------------------------- mdo_dialog -----*/
int mdo_dialog ( OBJECT *dialtree, int editstart )
{
	int ex_object ;
	
	ex_object = FormDo ( dialtree, editstart ) ;
	dialtree[ex_object & 0x7FFF].ob_state &= ~ SELECTED ;
	
	return (ex_object);
}


/*---------------------------------------------- mclose_dialog -----*/
void mclose_dialog ( OBJECT *fromtree, int fromobj, 
					 RECTangle *rect, RECTangle *fr )
{
	if ( fromtree != NULL )
	{
		FormDialShrink ( (*fr), (*rect) ) ;
		fromtree[fromobj].ob_state &= ~ SELECTED ;
		ObjectDraw ( fromtree, fromobj ) ;
	}
	
	FormDialFinish ( (*rect) ) ;
}



/*---------------------------------------------- move_button_text -----*/
void move_button_text ( int dialtr, int button,
						int text, bool button_state )
{
	OBJECT *dialtree ;
	OBJECT		*obj ;

 	if ( rsrc_gaddr ( R_TREE, dialtr, &dialtree ) != 0 )
 	{
		obj = get_child_addr ( dialtr, text ) ;		
		if ( button_state )
		{
			obj->ob_x -= 1 ;
			obj->ob_y -= 1 ;
			UpdateAttributes ( dialtr, button, NORMAL, 0 ) ;
		}
		else
		{
			obj->ob_x += 1 ;
			obj->ob_y += 1 ;
			UpdateAttributes ( dialtr, button, SELECTED, 0 ) ;
		}
	}
}


/*---------------------------------------------- m_intersect -----*/
bool m_intersect ( int mx, int my, int x, int y, int w, int h )
{
	return (bool) ( ( mx >= x ) && ( mx <= ( x + w ) ) &&
					( my >= y ) && ( my <= ( y + h ) )	   ) ;
}

	
/*---------------------------------------------- press_button -----*/
bool press_button ( int dialtr, int button, int text )
{
	OBJECT *dialtree, *obj ;
	int ob_ofxoff, ob_ofyoff ;
	bool button_state = TRUE, old_button_state = TRUE ;
	int mx, my,
	kstate,
	key,
	clicks,
	event,
	state ;
	int pipe[8] ;
	
 	if ( rsrc_gaddr ( R_TREE, dialtr, &dialtree ) != 0 )
	{
		state = FetchAttributes ( dialtr, button ) & SELECTED ;
		move_button_text ( dialtr, button, text, (bool)state ) ;
		obj = get_child_addr ( dialtr, button ) ;		
		objc_offset ( dialtree, button, &ob_ofxoff, &ob_ofyoff ) ;
	    objc_draw ( dialtree, 0, 99,
	    			ob_ofxoff, ob_ofyoff,
	   				obj->ob_width, obj->ob_height ) ;
	}

	graf_mkstate ( &mx, &my, &state, &kstate ) ;
	if ( ( obj->ob_flags & DEFAULT ) &&
		 ( ! m_intersect ( mx, my,
		 				   ob_ofxoff, ob_ofyoff,
		 				   obj->ob_width, obj->ob_height ) ) )
		/* default key must have been pressed */
		return TRUE ;
		
	do
	{
		/* wait until mouse button released or pointer leaves button */
		event = evnt_multi ( MU_M1 | MU_M2 | MU_BUTTON,
	 						 1, 0x1, 0,
	                		 1, ob_ofxoff, ob_ofyoff, obj->ob_width, obj->ob_height,
	                		 0, ob_ofxoff, ob_ofyoff, obj->ob_width, obj->ob_height,
							 pipe,
							 0, 0,
	 						 &mx, &my, &state, &kstate, &key, &clicks ) ;

		if ( event & MU_M1 )				/* mouse has left button area */
			button_state = FALSE ;
		else if ( event & MU_M2 )			/* mouse has reentered button area */
			button_state = TRUE ;

		if ( button_state != old_button_state )
		{
			old_button_state = button_state ;
			move_button_text ( dialtr, button, text, !button_state ) ;
			objc_draw ( dialtree, 0, 99,		/* redraw button */
		  				ob_ofxoff, ob_ofyoff,
						obj->ob_width, obj->ob_height ) ;

		}

		if ( event & MU_BUTTON )			/* button released */
			return button_state ;
	} while (TRUE) ;
 }


/*---------------------------------------------- update_info -----*/
void update_info ( void )
/* update information (all AES versions) */
{
	char memfree[9] = "12345678" ;
	
	/* check free memory */
	sprintf ( memfree, "%5lu", (unsigned long) Malloc ( -1 ) >> 10 ) ;
	UpdateTreeString ( MD_INFO, ITXT_STRAM, memfree ) ;
	if ( fram_cookie > 0L )
	{
		sprintf ( memfree, "%5lu", (unsigned long) Mxalloc ( -1, 1 ) >> 10 ) ;
		UpdateTreeString ( MD_INFO, ITXT_TTRAM, memfree ) ;
	}
	else
		UpdateTreeString ( MD_INFO, ITXT_TTRAM, "--------" ) ;
}


/*--------------------------------------------- handle_sdialog -----*/
int handle_sdialog ( OBJECT *fromtree, int fromobj,
				     int dialtr, int editstart,
				     int exit1, int exit2 )
/* handle help/video/info parameters (old AES) */
{
	RECTangle rect, fr ;
	OBJECT *dialtree ;
	int button ;
	bool  breakout = FALSE ;
	
	if ( rsrc_gaddr ( R_TREE, dialtr, &dialtree ) != 0)
	{
		mopen_dialog ( fromtree, fromobj, dialtree,	&rect, &fr ) ;
		do
		{	
			button = mdo_dialog ( dialtree, editstart ) ;
			if ( button > 0 ) 
			{
				if ( ( button == exit1 ) || ( button == exit2 ) )
				{
					if ( press_button ( dialtr, exit1, exit2 ) )
					{
						breakout = TRUE ;
						move_button_text ( dialtr, exit1, exit2, TRUE ) ;
					}
				}
			}
		} while ( !breakout ) ;
		mclose_dialog ( fromtree, fromobj, &rect, &fr ) ;
		return button ;
	}
	return -1 ;
}


/*---------------------------------------------- popup_entry -------*/
void popup_entry ( void )
{
	old_menu_zoom = menu_zoom ;
}

/*---------------------------------------------- popup_exit -------*/
void popup_exit ( void )
{
	if ( old_menu_zoom != menu_zoom )
	{
		Zoom = ZoomTable [menu_zoom] ;
		check_format_pop () ;
		LoadMatDigiFLcaData ( 0, DIGcolor, &Zoom, TRUE ) ;
		resize_window ();
	}
}

/*---------------------------------------------- handle_popups -----*/
int handle_popups ( int button )
/* handle popups in parameter dialogue box (for all AES versions) */
{
	
	switch ( button )
	{
case TX_DISPLAY :
			popup_menu ( popup_dmode ) ;
			break ;
case TX_FORMAT :
			popup_menu ( popup_format ) ;
			break ;
case TX_SIGNAL :
			popup_menu ( popup_signal ) ;
			break ;
case TX_CHANNEL :
			popup_menu ( popup_channel ) ;
			break ;
case TX_GRAB :
			popup_menu ( popup_grab ) ;
			break ;
case TX_SPEED :
			popup_menu ( popup_speed ) ;
			break ;
case TX_DIGITISE :
			popup_menu ( popup_digitise ) ;
			break ;
case TX_SAVE :
			popup_menu ( popup_save ) ;
			break ;
	}
	return button ;
}


/*---------------------------------------------- handle_fparams -----*/
int handle_fparams ( OBJECT *fromtree, int fromobj,
					 int dialtr, int editstart )
/* standard handle parameter dialogue box (for FALCON AES) */
{
	RECTangle rect, fr ;
	OBJECT *dialtree ;
	int button ;
	bool  breakout = FALSE ;
	
	if ( rsrc_gaddr ( R_TREE, dialtr, &dialtree ) != 0)
	{
		popup_entry();

		mopen_dialog ( fromtree, fromobj, dialtree,	&rect, &fr ) ;
		do
		{
			button = mdo_dialog ( dialtree, editstart ) ;
			if ( button > 0 ) 
			{							  
				switch ( button )
				{
case TX_DISPLAY :
case TX_FORMAT :
case TX_SIGNAL :
case TX_CHANNEL :
case TX_GRAB :
case TX_SPEED :
case TX_DIGITISE :
case TX_SAVE :
					handle_popups ( button ) ;
					break ;
# ifdef __MATDIGIR__
case BDTXT_SAVE :
case BD_SAVE :
case BDF_SAVE :
					if ( madi_ok )
						save_a_file ( &BlitWindow.dst.window, &BlitWindow.src.window,
								  	vfactor, &Drive ) ;
					break ;
# endif __MATDIGIR__
case BDTXT_QUIT :
case BD_QUIT :
case BDF_QUIT :
					breakout = TRUE ;
					end_program = 1 ;
					break ;
case BDTXT_INFO :
case BD_INFO :
case BDF_INFO :
					handle_fdialog ( NULL, 0, MD_INFO, NO_EDIT ) ;
					break ;
case BDTXT_HELP :
case BD_HELP :
case BDF_HELP :
					handle_fdialog ( NULL, 0, DHELP, NO_EDIT ) ;
					break ;
case BDTXT_VIDEO :
case BD_VIDEO :
case BDF_VIDEO :
					handle_fdialog ( NULL, 0, MD_BORDER, ED_HEAD ) ;
					break ;
case BDTXT_POK :
case BD_POK :
case BDF_POK :
					breakout = TRUE ;
					break ;
default :	 	;
				} /* switch */
			} /* if */
		} while ( !breakout ) ;
		mclose_dialog ( fromtree, fromobj, &rect, &fr ) ;

		popup_exit();

		return button ;
	} /* rsrc_gaddr */

	return -1 ;
}


/*---------------------------------------------- handle_params -----*/
int handle_params ( OBJECT *fromtree, int fromobj,
					int dialtr, int editstart )
/* special handle parameter dialogue box (for old AES) */
{
	RECTangle rect, fr ;
	OBJECT *dialtree ;
	int button ;
	bool  breakout = FALSE ;
	
	if ( rsrc_gaddr ( R_TREE, dialtr, &dialtree ) != 0)
	{
		popup_entry();

		mopen_dialog ( fromtree, fromobj, dialtree,	&rect, &fr ) ;
		do
		{	
			button = mdo_dialog ( dialtree, editstart ) ;
			if ( button > 0 ) 
			{
				switch ( button )
				{
		case TX_DISPLAY :
		case TX_FORMAT :
		case TX_SIGNAL :
		case TX_CHANNEL :
		case TX_GRAB :
		case TX_SPEED :
		case TX_DIGITISE :
		case TX_SAVE :
					handle_popups ( button ) ;
					break ;
# ifdef __MATDIGIR__
		case BDTXT_SAVE :
		case BD_SAVE :
		case BDF_SAVE :
					if ( press_button ( dialtr, BD_SAVE, BDTXT_SAVE ) )
					{
						if ( madi_ok )
							save_a_file ( &BlitWindow.dst.window, &BlitWindow.src.window,
										  vfactor, &Drive ) ;
						move_button_text ( dialtr, BD_SAVE, BDTXT_SAVE, TRUE ) ;
						ObjectDraw ( dialtree, 0 ) ;
					}
					break ;
# endif __MATDIGIR__
		case BDTXT_QUIT :
		case BD_QUIT :
		case BDF_QUIT :
					if ( press_button ( dialtr, BD_QUIT, BDTXT_QUIT ) )
					{
						end_program = 1 ;
						breakout = TRUE ;
						move_button_text ( dialtr, BD_QUIT, BDTXT_QUIT, TRUE ) ;
					}
					break ;
		case BDTXT_INFO :
		case BD_INFO :
		case BDF_INFO :
					if ( press_button ( dialtr, BD_INFO, BDTXT_INFO ) )
					{
						update_info () ;
						handle_sdialog ( NULL, 0, MD_INFO, NO_EDIT,
										 I_OK, ITXT_OK ) ;
						move_button_text ( dialtr, BD_INFO, BDTXT_INFO, TRUE ) ;
						ObjectDraw ( dialtree, 0 ) ;
					}
					break ;
		case BDTXT_HELP :
		case BD_HELP :
		case BDF_HELP :
					if ( press_button ( dialtr, BD_HELP, BDTXT_HELP ) )
					{
						handle_sdialog ( NULL, 0, DHELP, NO_EDIT,
										 DH_OK, DHTXT_OK ) ;
						move_button_text ( dialtr, BD_HELP, BDTXT_HELP, TRUE ) ;
						ObjectDraw ( dialtree, 0 ) ;
					}
					break ;
		case BDTXT_VIDEO :
		case BD_VIDEO :
		case BDF_VIDEO :
					if ( press_button ( dialtr, BD_VIDEO, BDTXT_VIDEO ) )
					{
						handle_sdialog ( NULL, 0, MD_BORDER, ED_HEAD,
										 B_OK, BTXT_OK ) ;
						move_button_text ( dialtr, BD_VIDEO, BDTXT_VIDEO, TRUE ) ;
						ObjectDraw ( dialtree, 0 ) ;
					}
					break ;
		case BDTXT_POK :
		case BD_POK :
		case BDF_POK :
					if ( press_button ( dialtr, BD_POK, BDTXT_POK ) )
					{
						breakout = TRUE ;
						move_button_text ( dialtr, BD_POK, BDTXT_POK, TRUE ) ;
					}
					break ;
		default :	 ;
				}
			}
		} while ( !breakout ) ;
		mclose_dialog ( fromtree, fromobj, &rect, &fr ) ;

		popup_exit();

		return button ;
	}
	return -1 ;
}


/*---------------------------------------------- tweak_buttons -----*/
void tweak_buttons ( int dialtr )
/* alter buttons according to AES version */
{
	OBJECT *dialtree, *obj, *but_obj ;
	unsigned child = 0 ;
	
	if ( rsrc_gaddr ( R_TREE, dialtr, &dialtree ) != 0)
	{
		for ( child = dialtree->ob_head; child <= dialtree->ob_tail; child++ )
		{
			obj = (OBJECT *) ( dialtree + child ) ;
			if ( obj->ob_flags & HDG_BUTTON )
			{
				but_obj = obj ;
				if ( aes_version >= AES_FALCON )
					obj->ob_flags |= HIDETREE ;
				else if ( ( screen_size.y <= 200 ) || 
						  ( ( screen_size.y <= 240 ) && 
						 	( (int) ( video_cookie >> 16 ) == VID_FALCON ) ) )
				{	/* use smaller icons */
					if ( obj->ob_spec.iconblk->ib_wicon > 64 )
						but_obj = get_child_addr ( F_BUTTON, IC2_LARGE ) ;
					else
						but_obj = get_child_addr ( F_BUTTON, IC2_SMALL ) ;
					but_obj->ob_height = 16 ;
				}
				else
				{	/* use larger icons */
					if ( obj->ob_spec.iconblk->ib_wicon > 64 )
						but_obj = get_child_addr ( F_BUTTON, IC_LARGE ) ;
					else
						but_obj = get_child_addr ( F_BUTTON, IC_SMALL ) ;
				}

				obj->ob_spec.iconblk = but_obj->ob_spec.iconblk ;
				obj->ob_width = but_obj->ob_width ;
				obj->ob_height = but_obj->ob_height ;

				if ( bit_planes == 8 )
					/* set bitmap to black & white */
					obj->ob_spec.iconblk->ib_char = 0x1020 ;
				
				obj->ob_spec.iconblk->ib_xtext = 1 ;
				obj->ob_spec.iconblk->ib_ytext = 1 ;
				obj->ob_spec.iconblk->ib_wtext = 0 ;
				obj->ob_spec.iconblk->ib_htext = 0 ;
			}
			else if ( obj->ob_flags & FL3DACT )
				if ( aes_version >= AES_FALCON )
					obj->ob_flags &= ~HIDETREE ;
		}
	}
}


/*---------------------------------------------- grey_to_white -----*/
void grey_to_white ( int dialtr )
{
	OBJECT *obj ;
	unsigned col ;
	
	if ( rsrc_gaddr ( R_TREE, dialtr, &obj ) != 0)
	{
		col = obj->ob_spec.obspec.interiorcol ;
		if ( ( col == LWHITE ) || ( col == LBLACK ) )
			obj->ob_spec.obspec.interiorcol = WHITE ;
	}
}

	
/*---------------------------------------------- chk_buttons -----*/
void chk_buttons ( void )
{
	char cpu[3] = "00" ;
	char video[7] = "    ST" ;
	
	cpu[0] = (char) ( cpu_cookie / 10 + 48 ) ;
	switch ( (int) ( video_cookie >> 16 ) )
	{
case VID_ST :		strcpy ( video, "    ST" ) ; break ;
case VID_STE :		strcpy ( video, "   STE" ) ; break ;
case VID_TT :		strcpy ( video, "    TT" ) ; break ;
case VID_FALCON :	strcpy ( video, "FALCON" ) ; break ;
default :;
	}
	UpdateTreeString ( MD_INFO, ITXT_DATE, __DATE__ ) ;
# ifdef __MATDIGIF__
	UpdateTreeString ( MD_INFO, ITXT_VERSION, MDF_VERSION ) ;
	popup_object_change ( popup_speed, PD_MAXIMUM, DISABLED, 0 ) ;
	popup_object_change ( popup_dmode, PD_GREY, DISABLED, 0 ) ;
	popup_object_change ( popup_dmode, PD_DITHER, DISABLED, 0 ) ;
	popup_object_change ( popup_dmode, PD_MONO, DISABLED, 0 ) ;
	UpdateAttributes ( MD_PARAM, BDTXT_SAVE, DISABLED, 0 ) ;
	UpdateAttributes ( MD_PARAM, BDF_SAVE, DISABLED, 0 ) ;
# endif __MATDIGIF__
# ifdef __MATDIGIR__
	UpdateTreeString ( MD_INFO, ITXT_VERSION, MDR_VERSION ) ;
# endif __MATDIGIR__
# ifdef __MATDIGI1__
	UpdateTreeString ( MD_INFO, ITXT_VERSION, MDR_VERSION ) ;
# endif __MATDIGI1__
	UpdateTreeString ( MD_INFO, ITXT_VIDEO, video ) ;
	UpdateTreeString ( MD_INFO, ITXT_CPU, cpu ) ;
	
	if ( bit_planes < 4 )
	{	/* convert grey backgrounds to white for monochrome */
		grey_to_white ( DHELP ) ;
		grey_to_white ( MD_PARAM ) ;
		grey_to_white ( MD_INFO ) ;
		grey_to_white ( MD_BORDER ) ;
	}
	tweak_buttons ( DHELP ) ;
	tweak_buttons ( MD_PARAM ) ;
	tweak_buttons ( MD_INFO ) ;
	tweak_buttons ( MD_BORDER ) ;
}

