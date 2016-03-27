/* dialog.c / 16.9.90 / MATRIX / WA */

# define TEST 0

#include <vdi.h>
#include <aes.h>
#include <stdio.h>
#include <stdlib.h>

#include <global.h>
#include <scancode.h>

#include "aesutils.h"
#include "main.h"
#include "dialog.h"
#include "cxxfast.h"
#include "backbuff.h"

# undef  FormDialFinish 
# undef  FormDialStart
# define FormDialFinish(r)	restore_background(&r)
# define FormDialStart(r)	save_background(&r)

#include "cxxsetup.h"


/*-------------------------------------------------------- edit_name -----*/
void edit_text ( OBJECT *tree, int ediobj )
{
	int edix, c, event ;
	
	edix = 0 ;

# if TEST == 2
	printf ( "\033Hedit_text : start\n" ) ;
# endif
	release_button();
	objc_edit ( tree, ediobj, 0, &edix, ED_INIT  ) ;
	for(;;)
	{
		event = evnt_multi(	MU_BUTTON | MU_KEYBD,
    	    		 		1,1,1,       	      	/* left button, single click */
 							0, R0,
 					   		0, R0,
 							NULL,
 					   		0,0,                	/* timer */    
 			    			&dummy,&dummy,&dummy,&dummy,&c,&dummy);
# if TEST == 2
		if ( event & MU_KEYBD )
			printf ( "#=%2d, c = '%c' = $%04x\n", edix, c&0xff, c ) ;
# endif
		if ( ( event & MU_BUTTON ) ||
			 ( ( event & MU_KEYBD ) && ( c == RETURN || c == ENTER 
					|| objc_edit ( tree, ediobj, c, &edix, ED_CHAR ) == 0 ) ) )
		{
			release_button();
			objc_edit ( tree, ediobj, 0, &edix, ED_END  ) ;
			return;
		}
	}
# if TEST == 2
	printf ( "edit_text : end\n" ) ;
# endif
}


/*--------------------------------------------- o_printf -----*/
int o_printf( OBJECT *tree, int obj, const char *format, ... )

{
	return ( vsprintf ( object_text(tree,obj), format, ... ) ) ;
}


/*--------------------------------------------- alert_printf -----*/
int alert_printf( int defbut, int icon, const char *buttxt, const char *format, ... )

{
	int length ;
	char inftxt[256],buffer[256] ;
	
	length = vsprintf ( inftxt, format, ... ) ;

	length += sprintf ( buffer, "[%d][ %s ][ %s ]",
						 icon, inftxt, buttxt ) ;
	
	form_alert ( defbut, buffer ) ;
	return ( length ) ;
}



/*------------------------------------------ fill_decimal -----*/
void fill_decimal(OBJECT *tree,int obj,long val,int pos,int digs)
{
	sprintf( &object_text(tree,obj)[pos], "%*ld", digs, val ) ;
}

/*------------------------------------------ fill_fix -----*/
void fill_fix(OBJECT *tree,int obj,long val,int pos,int digs)
{
	char *txt;
	long val10 ;
	
	txt = &object_text(tree,obj)[pos];
	
	val10 = val/10L ;
	if ( val10 <= 99 )
	{
		sprintf( txt, "%*ld", digs-2, val10 ) ;
		txt += digs-2 ;
		*txt++ = '.' ;
		*txt   = (int)(val % 10L) + '0' ;
	}
	else
		sprintf( txt, "%*ld", digs, val10 ) ;
}

/* === message boxes === */

OBJECT	*mesg_tree ;
TRectangle mesg_rect = { 0, 0, 0, 0 } ;
TRectangle from_rect ;
OBJECT *from_tree ;
int from_obj = NOobject ;
int old_ob_state = 0 ;

char text_buffer[256] ;


/*---------------------------------------------- clear_message ---*/
void clear_message(void)
{
	if(from_obj >= 0)
	{
		FormDialShrink ( from_rect, mesg_rect ) ;
		ObjectChange ( from_tree, from_obj, old_ob_state, 1 ) ;
	}
	if ( mesg_rect.w > 0 )
	{
		FormDialFinish ( mesg_rect );
	}
	mesg_rect.w = 0 ;
	from_obj = NOobject ;
}

/*---------------------------------------------- vsshow_message ---*/
int vsshow_message ( OBJECT *fromtree, int fromobj, const char *format, void *args )
# define MESG_BORDER 40
{
	int		txt_lng ;
	
		txt_lng = vsprintf ( text_buffer, format, args ) ;
		if ( text_buffer[txt_lng-1] == '\n' )
			text_buffer[--txt_lng] = 0 ;
		*(object_text_ptr( mesg_tree, MSGTEXT )) = text_buffer ;
		mesg_tree[MSGFRAME].ob_width =
				 txt_lng * hwchar + 2*mesg_tree[MSGTEXT].ob_x ;
		mesg_tree[MESGOK].ob_x =
			 mesg_tree[MSGFRAME].ob_width
				 	- mesg_tree[MESGOK].ob_width - 6 ;
		
		FormCenter ( mesg_tree, mesg_rect ) ;
		FormDialStart(mesg_rect);

		if(fromobj >= 0)
		{
			old_ob_state = fromtree[fromobj].ob_state ;
			ObjectChange ( fromtree, fromobj, old_ob_state | SELECTED, 1 ) ;
			ObjectGetRectangle( fromtree, fromobj, from_rect ) ;
			FormDialGrow(from_rect,mesg_rect);
		}
	
		ObjectDraw(mesg_tree,0);	/* draw from TOP */
		
		from_obj  = fromobj ;
		from_tree = fromtree ;
		return ( txt_lng ) ;
}


/*---------------------------------------------- show_message ---*/
int show_message ( OBJECT *fromtree, int fromobj, const char *format, ... )
{
	return ( vsshow_message ( fromtree, fromobj, format, ... ) ) ;
}


/*---------------------------------------------- message_box -----*/
void message_box ( OBJECT *fromtree, int fromobj, const char *format, ... )
{
	vsshow_message ( fromtree, fromobj, format, ... ) ;
	release_button() ;
	wait_at_least ( 3000, 1 ) ;
	clear_message();
}

/*---------------------------------------------- simple_message -----*/
int simple_message ( const char *format, ... )
{
	int lng ;
	
	lng = vsshow_message ( NULL, NOobject, format, ... ) ;
	release_button() ;
	wait_at_least ( 3000, 1 ) ;
	clear_message();
	return ( lng ) ;
}

/*---------------------------------------------- tree_dialog -----*/
int tree_dialog ( OBJECT *fromtree, int fromobj,
				  OBJECT *dialtree, int editstart )
{
	TRectangle rect, fr ;
	int ex_object ;

	FormCenter(dialtree,rect);
	if ( dialtree->ob_state & SHADOWED )
	{
		rect.w += 2 ;
		rect.h += 2 ;
	}
	FormDialStart(rect);
# if TEST == 1
	printf ( "\033Y7 +tree_dialog %3d:%3d %3d:%3d",
				 VALrect(rect) ) ;
# endif		

	if( fromtree != NULL )
	{
		fromtree[fromobj].ob_state |= SELECTED ;
		ObjectDraw ( fromtree, fromobj ) ;
		ObjectGetRectangle( fromtree, fromobj, fr ) ;
		FormDialGrow(fr,rect);
	}
	
	dialtree->ob_x += 1 ;
	dialtree->ob_y += 1 ;
	ObjectDraw(dialtree,0);	/* draw from TOP */
# if TEST == 1
	printf ( "\033Y8  tree_dialog object : %3d:%3d %3d:%3d",
				 dialtree->ob_x, dialtree->ob_y,
				 dialtree->ob_width, dialtree->ob_height ) ;
# endif
	ex_object = FormDo( dialtree, editstart ) ;
	dialtree[ex_object & 0x7FFF].ob_state &= ~ SELECTED ;
	
	if( fromtree != NULL )
	{
		FormDialShrink(fr,rect);
		fromtree[fromobj].ob_state &= ~ SELECTED ;
		ObjectDraw ( fromtree, fromobj ) ;
	}
	
	FormDialFinish(rect);
# if TEST == 1
	printf ( "\033Y9 -tree_dialog %3d:%3d %3d:%3d",
				 VALrect(rect) ) ;
# endif		

	return(ex_object);
}

/*---------------------------------------------- handle_dialog -----*/
int handle_dialog ( OBJECT *fromtree, int fromobj, int dialtr, int editstart )
{
	OBJECT *dialtree ;

	if( rsrc_gaddr( R_TREE, dialtr, &dialtree ) != 0)
		return ( tree_dialog ( fromtree, fromobj, dialtree, editstart ) ) ;
	else
		return ( -1 ) ;
}

# define round_mul(val,multiple) \
	( (val+multiple/2) / multiple * multiple )


/*------------------------------------------- object_change -------*/
void object_change ( OBJECT *tree, int obj, int state, int draw )
{
	if ( state != ObjectState ( tree, obj ) )
		ObjectChange ( tree, obj, state, draw ) ;
}

# if 0
/*-------------------------------- object_select_unchanged -------*/
void object_select_unchanged ( OBJECT *tree, int obj )
{
	int state ;

	state = ObjectState ( tree, obj ) ;
	ObjectSelect ( tree, obj ) ;
	ObjectState ( tree, obj ) = state ;
}
# endif

/*------------------------------------------- move_object -------*/
void move_object ( OBJECT *tree, int frameobj, int start_icon,
				   DRAGfct drag_fct )
{
	POINT	stop ;
	int		mx, my, lmx, lmy, buttons ;
	int		start_state, stop_icon, stop_state, result ;
	
	start_state = ObjectState ( tree, start_icon ) ;
	ObjectChange ( tree, start_icon, start_state | SELECTED, 1 ) ;

	MousePointHand();
	
	graf_mkstate( &lmx, &lmy, &dummy, &dummy ) ;
	do	/* wait until mouse moved or button released */
		graf_mkstate( &mx, &my, &buttons, &dummy ) ;
	while ( lmx == mx && lmy == my && buttons & 1 ) ;
	
	if ( buttons & 1 )
	{
		DragObject ( tree, frameobj, start_icon, &stop ) ;
		evnt_button ( 1, 1, 0, &mx, &my, &dummy, &dummy ) ;
		stop_icon = objc_find ( tree, frameobj, MAX_DEPTH, mx, my );
	}
	else
	{
		stop_icon = start_icon ;
	}

	if( stop_icon <= 0 || stop_icon <= frameobj )
	{
		ObjectChange ( tree, start_icon, start_state, 1 ) ;
	}
	else
	{
		if ( stop_icon == start_icon )
		{
			stop_state = start_state ;
		}
		else
		{
			stop_state = ObjectState ( tree, stop_icon ) ;
			ObjectChange ( tree, stop_icon, stop_state | SELECTED, 1 ) ;
		}
		MouseBusyBee();

		result = (*drag_fct)( start_icon, start_state, stop_icon, stop_state ) ;

		if ( ( result & SELstart ) == 0 )
			ObjectChange ( tree, start_icon, start_state, 1 ) ;
		if ( result & UNSELstart )
			ObjectChange ( tree, start_icon, start_state & ~SELECTED, 1 ) ;

		if ( stop_icon != start_icon )
		{
			if ( ( result & SELstop ) == 0 )
				ObjectChange ( tree, stop_icon,  stop_state,  1 ) ;
			if ( result & UNSELstop )
				ObjectChange ( tree, stop_icon, stop_state & ~SELECTED, 1 ) ;
		}

		MouseArrow();
	}
}

/*------------------------------------------- DragObject --------*/
void DragObject( OBJECT *tree, int frameobj, int dragobj, POINT *stop )
{
	TRectangle framerect, dragrect ;
	
	ObjectGetRectangle ( tree, frameobj, framerect ) ;
	ObjectGetRectangle ( tree, dragobj,  dragrect  ) ;
	MouseFlatHand();
	GrafDragbox ( dragrect, framerect, *stop ) ;
	MouseArrow();

}

/*------------------------------------------- object_switch --------*/
void object_switch ( OBJECT *tree, int obj, bool select, bool draw)
{
	objc_change ( tree, obj, 0, 0,0,9999,9999,
		 select ? SELECTED : NORMAL, draw );
}

/*--------------------------------- object_toggle_selection --------*/
bool object_toggle_selection ( OBJECT *tree, int obj, bool draw )
{
	int was_selected ;

	was_selected = tree[obj].ob_state & SELECTED ;
	objc_change ( tree, obj, 0, 0,0,9999,9999,
				 was_selected ? NORMAL : SELECTED, draw );
	return was_selected == 0 ;
}

/*------------------------------------------- object_hide --------*/
void object_hide ( OBJECT *tree, int obj, bool hide)
{
	if(hide)
		tree[obj].ob_flags |= HIDETREE ;
	else
		tree[obj].ob_flags &= ~ HIDETREE ;
}

/*------------------------------------------- objfam_change ---*/
void objfam_change ( OBJECT *tree, int frame, int newsta, bool draw )
{
	int obj ;
	OBJECT *frob ;
	
	frob = &tree[frame] ;
	for ( obj=frob->ob_head ; obj<=frob->ob_tail ; obj++ )
		tree[obj].ob_state = newsta ;
	if(draw)
		ObjectDraw ( tree, frame ) ;	
}


/*------------------------------------------- object_change_set ---*/
void object_change_set ( OBJECT *tree, int frame, int from, int to,
						 int newsta, bool draw )
{
	int obj ;
	for(obj=from;obj<=to;obj++)	tree[obj].ob_state = newsta ;
	if(draw) ObjectDraw ( tree, frame ) ;	
}

/*-------------------------------------------------------- toggle_selection --*/
bool toggle_selection( OBJECT *tree, int obj )
{
	int sel ;
	
	sel = ObjectSelected ( tree, obj ) ;
	if ( sel ) ObjectNormal ( tree, obj ) ;
		  else ObjectSelect ( tree, obj ) ;
	release_button();
	return ( ! sel ) ;
}


/*-------------------------------------------------------- release_button --*/
void release_button(void)
{
# if 1
	int n, buttons ;
	
	evnt_button ( 2, 1, 0, &dummy, &dummy, &dummy, &dummy ) ;
	for ( n = 0 ; ; )
	{
		graf_mkstate ( &dummy, &dummy, &buttons, &dummy ) ;
		if ( ( buttons & BOTH_BUTTONS ) == 0 )
			if ( n++ > 2 )
				break ;
		evnt_timer ( 10, 0 ) ;
	}
# else
	evnt_button ( 1, 1, 0, &dummy, &dummy, &dummy, &dummy ) ;
# endif
}

# if 0
MFORM matrix_m = { 8, 8, 2, WHITE, BLUE, { 0 }, { 0 } } ;

# else
MFORM matrix_m =
{ 8, 8, 2, WHITE, BLUE,
	{	/*	mask	*/
		0x03EF, 0x07FF, 0x07FF, 0x0FFF, 0x0FFF, 0x1FFF, 0x1FFF, 0x3FFF,
		0x3FFF, 0x7FFF, 0x7FFF, 0xFBFF, 0xF800, 0xF000, 0xF000, 0x0000
	},
	{	/*	data	*/
		0x0000, 0x01C6, 0x03CE, 0x03DE, 0x07DE, 0x07FE, 0x0DFE, 0x0DEE,
		0x19EE, 0x19CE, 0x31CE, 0x3000, 0x6000, 0x6000, 0x0000, 0x0000
	}
} ;
# endif

# include <string.h>

/*------------------------------------------------ wait_flat_hand --*/
void wait_flat_hand(void)
{
# if 0
	OBJECT *image_tree ;
	ICONBLK *icon ;

	if( rsrc_gaddr ( R_TREE, TRIMAGE, &image_tree ) != 0 )
	{
		icon = image_tree[ICM].ob_spec.iconblk ;

		memcpy ( matrix_m.mf_data, icon->ib_pdata, 16*16/8 ) ;
		memcpy ( matrix_m.mf_mask, icon->ib_pmask, 16*16/8 ) ;
	 
		graf_mouse ( USER_DEF, &matrix_m ) ;
	}
	else
	{
		MouseFlatHand();
	}
# else
	graf_mouse ( USER_DEF, &matrix_m ) ;
# endif
	release_button();
	MouseArrow();
}

				
/*---------------------------------------------- wait_at_least ---*/
int wait_at_least ( int msec, int press )
{
	int event ;
	
	event = evnt_multi (
				MU_TIMER | MU_BUTTON,
   	    		1,1,press,		/* press/release button */
				0, R0,
				0, R0,
				(int *)0L,
				msec,0,       /* timer */    
		    	&dummy,&dummy,&dummy,&dummy,&dummy,&dummy ) ;
	if ( ( event & MU_BUTTON ) && press ) release_button() ;
	return ( event ) ;
}

/*------------------------------------------------ init_dialog -----*/
bool init_dialog(int mesg_trix)
{
	return ( rsrc_gaddr( R_TREE, mesg_trix, &mesg_tree ) != 0) ;
}






