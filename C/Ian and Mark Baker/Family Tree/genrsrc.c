/************************************************************************/
/*																		*/
/*		Genrsrc.c		18 Jul 97										*/
/*																		*/
/************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"			/* Use precompiled header GENINC.SYM ?	*/
#endif

#include "gen.h"
#include "genhd.h"
#include "genrsrc.h"
#include "genutil.h"

#define AES_WINDOW 11

#define PATTERN_MASK 0x70
#define COLOR_MASK 0xF

extern short wchar, hchar ;
extern short colours ;					/* 2 for ST high, 4 for medium, etc.	*/

short scroll_bar_colour ;
short scroll_slider_colour ;


/*
	In resource files the x, y, w and h values are stored as multiples of character
	size plus a pixel offset. To use a resource file at a different character size,
	the pixel offset must be scaled.
	If the resource file is produced on the Falcon, or ST high resolution, the character
	size is 8*16. The pixel offset should therefore be multiplied by charwidth/8 and
	charheight/16.
	
	The menu should not be scaled. The original sizes are restored, I hope.
*/

void  rescale_resources( void )
{
	set_scroll_colours() ;

	rescale_tree( PERSON ) ;
	rescale_tree( SEL_PERSON ) ;
	rescale_tree( COUPLE ) ;
	rescale_tree( DEATH_FORM ) ;
	rescale_tree( BAP_FORM ) ;
	rescale_tree( BIRTH_FORM ) ;
	rescale_tree( W_FORM ) ;
	rescale_tree( DI_FORM ) ;
	rescale_tree( PREFS ) ;
	rescale_menu( MENU1 ) ;
	rescale_tree( CONFIG_PRN ) ;
	rescale_tree( FSEL ) ;
	rescale_tree( FLAGS ) ;
	rescale_tree( EXPORT_SELECT ) ;
	rescale_tree( EXPORT_FILTER ) ;
	rescale_tree( USE_FLAG ) ;
	rescale_tree( PSEL_EXTRA_INFO ) ;
	rescale_tree( INDEX_RANGE ) ;
	rescale_tree( SUBMITTER ) ;
	rescale_tree( ATTRIBUTES ) ;
	rescale_tree( CSV_SELECT ) ;
	rescale_tree( CSV_FORMAT ) ;
	rescale_tree( MEDIA_PROGS) ;
	rescale_tree( FOOTER ) ;
	rescale_tree( CANCEL_PRINT ) ;
}


void rescale_tree( int tree )
{
	OBJECT* tree_ptr ;
	
	rsrc_gaddr( R_TREE, tree, &tree_ptr ) ;
	objc_walk( tree_ptr, ROOT, NIL, 0, rescale_object ) ;
}


int  rescale_object( OBJECT *object, int object_number )
{
	short colour ;
	
	object[object_number].ob_x = rescale( object[object_number].ob_x, wchar, RESOURCE_CHAR_WIDTH ) ; 
	object[object_number].ob_y = rescale( object[object_number].ob_y, hchar, RESOURCE_CHAR_HEIGHT ) ; 
	object[object_number].ob_width = rescale( object[object_number].ob_width, wchar, RESOURCE_CHAR_WIDTH ) ; 
	object[object_number].ob_height = rescale( object[object_number].ob_height, hchar, RESOURCE_CHAR_HEIGHT ) ; 

	if( object[object_number].ob_type == G_BOX )		/* change colours for scroll bars */
	{
		colour = (short) object[object_number].ob_spec & 0xF ;
		if( colour == LBLACK )	/* dk grey used for scroll bars	*/
		{
			object[object_number].ob_spec = (void*) ( ( (int) object[object_number].ob_spec ) & ~( PATTERN_MASK | COLOR_MASK ) ) ;
			object[object_number].ob_spec = (void*) ( ( (int) object[object_number].ob_spec ) | scroll_bar_colour ) ;
		}
		else if( colour == LWHITE )	/* lt grey used for scroll sliders	*/
		{
			object[object_number].ob_spec = (void*) ( ( (int) object[object_number].ob_spec ) & ~( PATTERN_MASK | COLOR_MASK ) ) ;
			object[object_number].ob_spec = (void*) ( ( (int) object[object_number].ob_spec ) | scroll_slider_colour ) ;
		}
	}
	
						/* remove shadowing on medium res as it looks too heavy	*/
	if( hchar < 16 )  object[object_number].ob_state &= ~SHADOWED ; 

	return 1 ;		/* continue with any sub trees	*/
}


short  rescale( int pixels, int charsize, int resource_char_size )
{
	return (short) ( pixels + ( pixels % charsize ) * ( charsize - resource_char_size ) / resource_char_size ) ;
}


void rescale_menu( int tree )
{
	OBJECT* menu_ptr ;
	
	rsrc_gaddr( R_TREE, tree, &menu_ptr ) ;
	objc_walk( menu_ptr, ROOT, NIL, 0, restore_menu ) ;
}


int  restore_menu( OBJECT *object, int object_number )
{
	if( object[object_number].ob_type == G_TITLE )
		object[object_number].ob_height = hchar + 3 ;
	
	if( object[object_number].ob_type == G_IBOX && object[object_number].ob_height < 2 * hchar )
		object[object_number].ob_height = hchar + 2 ;

	if( object[object_number].ob_type == G_IBOX
			 && object[object_number].ob_y >= hchar&& object[object_number].ob_y < 2 * hchar )
		object[object_number].ob_y = hchar + 3 ;

	return 1 ;
}


void  set_scroll_colours( void )
{
	BOOLEAN WF_DColor_available = TRUE ;
	short param1, param2, param3, param4 ; 
		
	if( _AESglobal[0] < 0x0330 )					/* ie AES version < 3.30			*/
		WF_DColor_available = FALSE ;
	if( _AESglobal[0] >= 0x0400 )					/* ie AES version > 4.00			*/	
	{
		appl_getinfo( AES_WINDOW, &param1, &param2, &param3, &param4 ) ;
		if( param1 & 0x4 == 0 )  WF_DColor_available = FALSE ;
	}
	
	if( WF_DColor_available )
	{
		param1 = W_VSLIDE ;
		wind_get( 0, WF_DCOLOR, &param1, &param2, &param3, &param4 ) ;
		scroll_bar_colour = param2 & ( PATTERN_MASK | COLOR_MASK ) ;
		param1 = W_VELEV ;
		wind_get( 0, WF_DCOLOR, &param1, &param2, &param3, &param4 ) ;
		scroll_slider_colour = param2 & ( PATTERN_MASK | COLOR_MASK ) ;
	}
	else
	{
		scroll_bar_colour = ( IP_1PATT << 4 ) + BLACK ;
		scroll_slider_colour = ( IP_SOLID << 4 ) + WHITE ;
	}
}

