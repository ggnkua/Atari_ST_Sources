# define TEST	0

#include <vdi.h>
#include <aes.h>

# if TEST
#include <stdio.h>
# endif

#include <global.h>

# include "\pc\cxxsetup\aesutils.h"
# include "\pc\cxxsetup\main.h"
# include "\pc\cxxsetup\screen.h"

#include <windows.h>

# include "toolbox.h"

# define MAXtools	32

int curr_toolboxes[MAXtools] ;
int start_box_y	;

OBJECT *tool_tree ;
OBJECT *select_box ;
int	   frame_object ;
WINDOWdescr	**ptool_window ;

/* ??????????? */
extern void info_printf ( const char *format, ... ) ;
/* ??????????? */

/*--------------------------------------------- show_box ------*/
void show_box ( OBJECT *tree, int boxobj, int menu_entry )
{
	RECTangle boxrect, work ;
	
	ObjectGetRectangle ( tree, boxobj, boxrect ) ;

	tree[boxobj].ob_flags &= ~ HIDETREE ;
	if ( menu_tree != NULL && menu_entry >= 0 )
		menu_tree[menu_entry].ob_state |= CHECKED ;

	MouseOff() ;
	if ( buffer_allocated )
	{
		WindGetWork ( window_handle ( *ptool_window ), work ) ;
		save_window ( &work, &boxrect ) ;
	}
	ObjectDraw ( tree, boxobj ) ;
	MouseOn() ;
}

/*--------------------------------------------- hide_box ------*/
void hide_box ( OBJECT *tree, int boxobj, int menu_entry )
{
	RECTangle boxrect, work ;
	
	ObjectGetRectangle ( tree, boxobj, boxrect ) ;

	tree[boxobj].ob_flags |= HIDETREE ;
	if ( menu_tree != NULL && menu_entry >= 0 )
		menu_tree[menu_entry].ob_state &= ~CHECKED ;

	MouseOff() ;
	if ( buffer_allocated )
	{
		WindGetWork ( window_handle ( *ptool_window ), work ) ;
		restore_window ( &work, &boxrect ) ;
	}
	MouseOn() ;
}

/*------------------------------------------ get_toolbox -----*/
TOOLbox *get_toolbox ( int icnobj )
{
	TOOLbox *ptbx ;

	for ( ptbx = tool_boxes ; ptbx->icon >= 0 ; ptbx++ )
	{
		if ( ptbx->icon == icnobj )
			return ptbx ;
	}
	return NULL ;
}


/*------------------------------------------ get_toolbox_obj -----*/
int get_toolbox_obj ( int icnobj )
{
	TOOLbox *ptbx ;

	ptbx = get_toolbox ( icnobj ) ;
	if ( ptbx != NULL )
		return ptbx->box ;
	else
		return -1 ;
}

/*------------------------------------------ get_toolicn_from_closer -----*/
int get_toolicn_from_closer ( int closobj )
{
	TOOLbox *ptbx ;

	for ( ptbx = tool_boxes ; ptbx->icon >= 0 ; ptbx++ )
	{
		if ( ptbx->closer == closobj )
			return ptbx->icon ;
	}
	return -1 ;
}

/*------------------------------------------ get_toolicn_from_menu -----*/
int get_toolicn_from_menu ( int menu_entry )
{
	TOOLbox *ptbx ;

	for ( ptbx = tool_boxes ; ptbx->icon >= 0 ; ptbx++ )
	{
		if ( ptbx->menu == menu_entry )
			return ptbx->icon ;
	}
	return -1 ;
}


/*------------------------------------------ get_menu_from_toolicn -----*/
int get_menu_from_toolicn ( int icnobj )
{
	TOOLbox *ptbx ;

	ptbx = get_toolbox ( icnobj ) ;
	if ( ptbx != NULL )
		return ptbx->menu ;
	else
		return -1 ;
}




/*-------------------------------------------------- get_toolbox_entry --*/
bool get_toolbox_entry ( int *entry, int *end_y )
{
	int icnobj ;
	OBJECT *predboxobj ;

	predboxobj = select_box ;

	*entry = 0 ;
	if ( curr_toolboxes[0] < 0 )		/* empty list, first box	*/
	{
		*end_y = start_box_y ;
# if TEST == 3
		printf ( "end_y : %d - start\n", *end_y ) ;
# endif
		return TRUE ;
	}

	for ( ; *entry < MAXtools ; (*entry)++ )	/* at least one loop !	*/
	{
		icnobj = curr_toolboxes[*entry] ;
		if ( icnobj < 0 )						/* empty slot found	*/
		{
			*end_y = predboxobj->ob_y + predboxobj->ob_height ;
# if TEST == 3
			printf ( "end_y : %d, ob_y : %d, _h : %d\n", *end_y, predboxobj->ob_y, predboxobj->ob_height ) ;
# endif
			return TRUE ;
		}
		predboxobj = &tool_tree[get_toolbox_obj(icnobj)] ;
	}
	return FALSE ;
}


/*-------------------------------------------------- find_toolbox_entry --*/
int find_toolbox_entry ( int obj )
{
	int entry, icnobj ;

	for ( entry = 0 ; entry < MAXtools ; entry++ )
	{
		icnobj = curr_toolboxes[entry] ;
# if 0
printf ( "find_toolbox_entry, %3d = %3d ?    \n", obj, icnobj ) ;
# endif
		if ( icnobj < 0 )
			return -1 ;						/* end reached, object not in toolbox liste	*/
		if ( obj == icnobj )
			return entry ;
	}
	return -1 ;								/* object not in toolbox liste	*/
}


/*-------------------------------------------------- get_last_toolbox ---*/
int get_last_toolbox ( void )
{
	int entry, icnobj ;

	for ( entry = MAXtools-1 ; entry >= 0 ; entry-- )
	{
			icnobj = curr_toolboxes[entry] ;
			if ( icnobj >= 0 )
				return icnobj ;
	}
	return ( -1 ) ;
}


/*-------------------------------------------------- get_toolbox_icon ---*/
int get_toolbox_icon ( int toolicn )
{
	OBJECT *boxobj ;
	TOOLbox *ptbx ;

	for ( ptbx = tool_boxes ; ptbx->icon >= 0 ; ptbx++ )
	{
		boxobj = &tool_tree[ ptbx->box ] ;
# if 0
printf ( "get_toolbox_icon, toolicn:%3d, box:%3d,  %3d <= %3d <= %3d ?       \n",
	ptbx->icon, ptbx->box, boxobj->ob_head, toolicn, boxobj->ob_tail	) ;
# endif
		if ( boxobj->ob_head <= toolicn && toolicn <= boxobj->ob_tail )
			return ptbx->icon ;
	}
	return -1 ;
}





/*-------------------------------------------- tool_enabled -------*/
bool tool_enabled ( int toolicn )
{
	int box ;

	box = get_toolbox_obj ( get_toolbox_icon ( toolicn ) ) ;

# if TEST == 4
	printf ( "icon: %d, box : %d, disa : %04x, tool_enabled : %d\n",
				toolicn, box, tool_tree[box].ob_state & DISABLED,
				( box >= 0 )
			&& ( ( tool_tree[box].ob_state & DISABLED ) == 0 ) ) ;
# endif
	return ( box >= 0 )
			&& ( ( tool_tree[box].ob_state & DISABLED ) == 0 ) ;
}

/*-------------------------------------------- icon_visible -------*/
bool icon_visible ( int toolicn )
{
	return find_toolbox_entry ( get_toolbox_icon ( toolicn ) ) >= 0 ;
}

/*-------------------------------------------- icon_change -------*/
void icon_change ( int toolicn, int state )
{
	ObjectChange ( tool_tree, toolicn, state, icon_visible(toolicn) ) ;
}




/*-------------------------------------------- redraw_toolboxes -----*/
void redraw_toolboxes ( RECTangle *rect )
{
	int entry, icnobj, boxobj ;

# if TEST == 2
	printf ( "+ redraw_toolboxes : " ) ;
	for ( entry = 0 ; entry < MAXtools ; entry++ )
		printf ( "%3d", curr_toolboxes[entry] ) ;
	printf ( "\n" ) ;
# endif
	
	for ( entry = 0 ; entry < MAXtools ; entry++ )
	{
		icnobj = curr_toolboxes[entry] ;
		if ( icnobj < 0 )
			return ;

# if TEST == 2
		boxobj = get_toolbox_obj ( icnobj ) ;
		if ( rect != NULL )
		{
			printf ( "entry:%d, icn:%3d, box:%3d r=%3d:%3d:%3d:%3d\n",
							entry, icnobj, boxobj, VALrect(*rect) ) ;
			if ( boxobj >= 0 )
				ObjectDraw ( tool_tree, boxobj ) ;
		}
		else
			printf ( "icn:%3d\n", icnobj ) ;
# else
		boxobj = get_toolbox_obj ( icnobj ) ;
		if ( rect != NULL && boxobj >= 0 )
			objc_draw ( tool_tree, boxobj, MAX_DEPTH, VALrect(*rect) ) ;
# endif	
		redraw_toolbox ( icnobj ) ;
	}
}

/*------------------------------------------ toolbox_disable -----*/
void toolbox_disable ( TOOLbox *ptbx )
{
	tool_tree[ptbx->box].ob_state |= DISABLED ;
	menu_tree[ptbx->menu].ob_state |= DISABLED ;
	tool_tree[ptbx->icon].ob_state |= DISABLED ;
}

/*------------------------------------------ toolbox_enable -----*/
void toolbox_enable ( TOOLbox *ptbx )
{
	tool_tree[ptbx->box].ob_state  &= ~ DISABLED ;
	menu_tree[ptbx->menu].ob_state &= ~ DISABLED ;
	tool_tree[ptbx->icon].ob_state &= ~ DISABLED ;
}

/*------------------------------------------ init_toolbox -----*/
void init_toolbox ( OBJECT *tooltree, unsigned level,
					int	frame, WINDOWdescr **pwindow )
{
	int entry ;
	TOOLbox *ptbx ;
	OBJECT *boxobj ;
# if TEST == 1
	printf ( "\033H+ init_toolbox\n" ) ;
# endif	
	tool_tree  = tooltree ;
	frame_object = frame ;
	ptool_window  = pwindow ;

	select_box = &tool_tree [ tool_boxes[0].box ] ;
	start_box_y	= 0 ;
										/* hide toolboxes	*/
	for ( ptbx = tool_boxes ; ptbx->icon >= 0 ; ptbx++ )
	{
		boxobj = &tool_tree[ptbx->box] ;
		boxobj->ob_flags |= HIDETREE ;

		if ( ( ptbx->level & level ) == 0 )
			toolbox_disable ( ptbx ) ;
		boxobj->ob_x	 = 0 ;
		boxobj->ob_width = select_box->ob_width ;
	}

	for ( entry = 0 ; entry < MAXtools ; entry++ )	/* clear toolbox list	*/
		curr_toolboxes[entry] = -1 ;
# if TEST == 1
	printf ( "- init_toolbox\n" ) ;
# endif	
}



/*-------------------------------------------------- switch_toolbox_on --*/
void switch_toolbox_on ( int icnobj )
{
	int boxobj, entry, end_y ;
	OBJECT *toolboxobj ;
	RECTangle framerect ;

	if ( icnobj < 0 || find_toolbox_entry ( icnobj ) >= 0 )
		return ;

	ObjectGetRectangle ( tool_tree, frame_object, framerect ) ;

# if TEST == 2
	printf ( "= switch_toolbox_on\n" ) ;
# endif
	if ( icnobj < 0 )
		return ;
	boxobj = get_toolbox_obj ( icnobj ) ;
	toolboxobj = &tool_tree[boxobj] ;
	if ( boxobj >= 0 && ( toolboxobj->ob_state & DISABLED ) == 0 )
	{
		if ( get_toolbox_entry ( &entry, &end_y ) )
		{
			toolboxobj->ob_y = end_y ;
# if TEST == 7
	printf ( "h = %d, maxh = %d, RETURN !\n",
		toolboxobj->ob_y + toolboxobj->ob_height, framerect.y + framerect.h ) ;
	getchar();
# endif
			if ( toolboxobj->ob_y + toolboxobj->ob_height < framerect.h )
			{
				curr_toolboxes[entry] = icnobj ;				/* switch icon on	*/
				if ( icnobj > 0 )
					ObjectChange ( tool_tree, icnobj, SELECTED,
								( select_box->ob_flags & HIDETREE ) == 0 ) ;
				show_box ( tool_tree, boxobj, get_menu_from_toolicn ( icnobj ) ) ;
				redraw_toolbox ( icnobj ) ;
			}
			else
				info_printf ( "Kein Platz mehr frei" ) ;
		}
		else
			info_printf ( "Toolboxliste voll" ) ;
	}
}


/*-------------------------------------------------- switch_toolbox_off --*/
void switch_toolbox_off ( int icnobj )
{
	int boxobj, entry, succ_box, succ_icon, end_y ;
	OBJECT *succ_boxobj ;

# if TEST == 2
	printf ( "= switch_toolbox_off\n" ) ;
# endif
	if ( icnobj < 0 )
		return ;

	entry = find_toolbox_entry ( icnobj ) ;

	if ( entry >= 0 )
	{
		boxobj = get_toolbox_obj ( icnobj ) ;
		if ( boxobj >= 0 )
		{
			if ( entry == 0 )
				end_y = start_box_y ;
			else
				end_y = tool_tree[boxobj].ob_y ;

			hide_box ( tool_tree, boxobj, get_menu_from_toolicn ( icnobj ) ) ;
			if ( icnobj > 0 )
				ObjectChange ( tool_tree, icnobj, NORMAL,
					( select_box->ob_flags & HIDETREE ) == 0 ) ;
			for ( entry += 1 ;
					entry < MAXtools && (succ_icon = curr_toolboxes[entry]) >= 0 ;
						entry++ )
			{
				curr_toolboxes[entry-1] = succ_icon ;	/* shift entry one slot down	*/
				succ_box = get_toolbox_obj(succ_icon) ;
				succ_boxobj = &tool_tree[succ_box] ;

				hide_box ( tool_tree, succ_box,	-1 ) ;
				succ_boxobj->ob_y = end_y ;
				show_box ( tool_tree, succ_box, -1 ) ;
				end_y += succ_boxobj->ob_height ;
			}
			curr_toolboxes[entry-1] = -1 ;

			redraw_toolboxes ( NULL ) ;
		}
	}
}


/*--------------------------------------------- switch_toolbox ------*/
bool switch_toolbox ( int icnobj )
{
	if ( find_toolbox_entry ( icnobj ) >= 0 )
	{
		switch_toolbox_off ( icnobj ) ;
		return FALSE ;
	}
	else
	{
		switch_toolbox_on ( icnobj ) ;
		return TRUE ;
	}
}

/*--------------------------------------------- close_toolboxes ----*/
void close_toolboxes ( void )
{
	int box ;
	
	while ( ( box = get_last_toolbox() ) >= 0 )
		switch_toolbox_off ( box ) ;
}