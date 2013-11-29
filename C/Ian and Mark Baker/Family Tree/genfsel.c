/*************************************************************************/
/*                                                                       */
/*  GENFSEL.C    Font selector routines for family tree    21 May 2000	 */
/*                                                                       */
/*************************************************************************/

#if !defined GEN_PH
	#include "geninc.h"
#endif

#include "genhd.h"
#include "gendata.h"
#include "genfsel.h"
#include "genutil.h"
#include "xufsl_lc.h"


#define DOUBLE_CLICK 0x8000			/* Double click bit					*/
#define MAX_FONTSIZES 200			/* Number of font sizes in array	*/

extern Preferences prefs ;

short font_selector = UFSL_FSEL ;


typedef struct
{
	int index ;
	int number ;
} Fontlist_type ;
Fontlist_type *fontlist ;

int fsel_maxsize = 72 ;				/* Maximum size						*/


static int font_oset = 0 ;			/* shortlist scrolling offset		*/
static int size_oset = 0 ;			/* ditto for fonts					*/
static int old_fonts ;				/* Number of fonts already loaded	*/
static int font_entries ;
static int size_entries ;
static short font = 0, size = 0;

struct
{
	char *title ;
	char *names[9] ;
	char *sizes[9] ;
	char *arbsize ;
} font_sel_addrs ;

int sizelist[ MAX_FONTSIZES ] ;

OBJECT *form ;
short vdih ;

									/* Routines start here				*/

FONTINFO ft_font_select( short handle, FONTINFO font_info, char *title )

{
	short done = FALSE ;
	short button ;
	short m_x, m_y ;
	short dummy ;
	short obj_x, obj_y ;
	FONTINFO selected ;
	short attr[10] ;
	APPLBLK ap ;

	vqt_attributes( handle, attr ) ;

	rsrc_gaddr( R_TREE, FSEL, &form ) ;
	app_modal_init( form, "Font Selector", TITLED ) ;

	set_fontsel_addrs() ;

	font_entries = init_fontsel_form( handle, app_modal_box(), title, font_info ) ;

	if( font_entries == 0 )	/* insufficient memory so return old font	*/
	{
		app_modal_end() ;
		return font_info ;
	}
	
	size_entries = init_sizes( handle, font_info, app_modal_box() ) ;
	sprintf( font_sel_addrs.arbsize, "%3d", font_info.font_size ) ;

	vdih = handle ;
	ap.ab_code = render_sample ;
	ap.ab_parm = (long) &font_info ;
	form[SAMPLE].ob_spec = &ap ;
	form[SAMPLE].ob_type = G_PROGDEF ;

	display_font_list( handle, *app_modal_box() ) ;
	display_size_list( *app_modal_box() ) ;

	selected = font_info ;
	while( !done )
	{	button = app_modal_do() ;

		font_info.font_size = atoi( font_sel_addrs.arbsize ) ;

		button &= ~DOUBLE_CLICK ;
		switch( button )
		{
			case FSEL_CANCEL :
			case APP_MODAL_TERM :
				done = TRUE ;
				form[FSEL_CANCEL].ob_state &= ~SELECTED ;
				break ;
			case FSEL_OK :
				form[FSEL_OK].ob_state &= ~SELECTED ;
				selected = font_info ;
				vst_unload_fonts( handle, 0 ) ;
				done = TRUE ;
				break ;
			case FSEL_FONTDRAG :
				if( font_entries > 8 )
				{
					form[font].ob_state &= ~SELECTED ;
					font_oset = fsel_move_slide( form,
								FSEL_FONTDRAG, FSEL_FONTSLIDER, app_modal_box() ) ;
					font_oset = ( font_entries - 8 ) * font_oset / 1000 ;

					display_font_list( handle, *app_modal_box() ) ;
				}
				break ;
			case FSEL_FONTUP :
				if( font_entries > 8 && font_oset > 0 )
				{
					font_oset-- ;
					form[font].ob_state &= ~SELECTED ;
					fsel_set_slide( font_oset, font_entries-8, form,
								FSEL_FONTDRAG, FSEL_FONTSLIDER, app_modal_box() ) ;
					display_font_list( handle, *app_modal_box() ) ;
				}
				break ;
			case FSEL_FONTDOWN :
				if( font_entries > 8 && font_oset < font_entries - 8 )
				{
					font_oset++ ;
					form[font].ob_state &= ~SELECTED ;
					fsel_set_slide( font_oset, font_entries-8, form,
								FSEL_FONTDRAG, FSEL_FONTSLIDER, app_modal_box() ) ;
					display_font_list( handle, *app_modal_box() ) ;
				}
				break ;
			case FSEL_FONTSLIDER :
				if( font_entries > 8 )
				{
					graf_mkstate( &m_x, &m_y, &dummy, &dummy ) ;
					objc_offset( form, FSEL_FONTDRAG, &obj_x, &obj_y ) ;
					if( m_y > obj_y )
					{
						font_oset += 7 ;
						if( font_oset > font_entries - 8 )
							font_oset = font_entries - 8 ;
					}
					else
					{
						font_oset -= 7 ;
						if( font_oset < 0 )  font_oset = 0 ;
					}
					form[font].ob_state &= ~SELECTED ;
					fsel_set_slide( font_oset, font_entries-8, form,
								FSEL_FONTDRAG, FSEL_FONTSLIDER, app_modal_box() ) ;
					display_font_list( handle, *app_modal_box() ) ;
				}
				break ;
					/* assert used in set_fontsel_addrs to ensure field are consecutive	*/
			case FSEL_FONT1 :
			case FSEL_FONT2 :
			case FSEL_FONT3 :
			case FSEL_FONT4 :
			case FSEL_FONT5 :
			case FSEL_FONT6 :
			case FSEL_FONT7 :
			case FSEL_FONT8 :
				selectfont( handle, button, button - FSEL_FONT1 + 1,
												&font_info, *app_modal_box() ) ;
				objc_draw( form, SAMPLE, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
				break ;
			case FSEL_SIZEDRAG :
				if( size_entries > 8 )
				{
					form[size].ob_state &= ~SELECTED ;
					size_oset = fsel_move_slide( form,
								FSEL_SIZEDRAG, FSEL_SIZESLIDER, app_modal_box() ) ;
					size_oset = ( size_entries - 8 ) * size_oset / 1000 ;

					display_size_list( *app_modal_box() ) ;
				}
				break ;
			case FSEL_SIZEUP :
				if( size_entries > 8 && size_oset > 0 )
				{
					size_oset-- ;
					form[size].ob_state &= ~SELECTED ;
					fsel_set_slide( size_oset, size_entries-8, form,
								FSEL_SIZEDRAG, FSEL_SIZESLIDER, app_modal_box() ) ;
					display_size_list( *app_modal_box() ) ;
				}
				break ;
			case FSEL_SIZEDOWN :
				if( size_entries > 8 && size_oset < size_entries - 8 )
				{
					size_oset++ ;
					form[size].ob_state &= ~SELECTED ;
					fsel_set_slide( size_oset, size_entries-8, form,
								FSEL_SIZEDRAG, FSEL_SIZESLIDER, app_modal_box() ) ;
					display_size_list( *app_modal_box() ) ;
				}
				break ;
			case FSEL_SIZESLIDER :
				if( size_entries > 8 )
				{
					graf_mkstate( &m_x, &m_y, &dummy, &dummy ) ;
					objc_offset( form, FSEL_SIZEDRAG, &obj_x, &obj_y ) ;
					if( m_y > obj_y )
					{
						size_oset += 7 ;
						if( size_oset > size_entries - 8 )
							size_oset = size_entries - 8 ;
					}
					else
					{
						size_oset -= 7 ;
						if( size_oset < 0 )  size_oset = 0 ;
					}
					form[size].ob_state &= ~SELECTED ;
					fsel_set_slide( size_oset, size_entries-8, form,
								FSEL_SIZEDRAG, FSEL_SIZESLIDER, app_modal_box() ) ;
					display_size_list( *app_modal_box() ) ;
				}
				break ;
					/* assert used in set_fontsel_addrs to ensure field are consecutive	*/
			case FSEL_SIZE1 :
			case FSEL_SIZE2 :
			case FSEL_SIZE3 :
			case FSEL_SIZE4 :
			case FSEL_SIZE5 :
			case FSEL_SIZE6 :
			case FSEL_SIZE7 :
			case FSEL_SIZE8 :
				selectsize( button, button - FSEL_SIZE1 + 1,
												&font_info, *app_modal_box() ) ;
				objc_draw( form, SAMPLE, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
				break ;
			case FSEL_THICKEN :
			case FSEL_LIGHTEN :
			case FSEL_SKEW :
			case FSEL_UNDERLINE :
			case FSEL_OUTLINE :
			case FSEL_SHADOW :
				font_info.font_effects = 0 ;
				if( form[FSEL_THICKEN].ob_state & SELECTED )
								font_info.font_effects |= THICKENED ;
				if( form[FSEL_LIGHTEN].ob_state & SELECTED )
								font_info.font_effects |= SHADED ;
				if( form[FSEL_SKEW].ob_state & SELECTED )
								font_info.font_effects |= SKEWED ;
				if( form[FSEL_UNDERLINE].ob_state & SELECTED )
								font_info.font_effects |= UNDERLINED ;
				if( form[FSEL_OUTLINE].ob_state & SELECTED )
								font_info.font_effects |= OUTLINE ;
				if( form[FSEL_SHADOW].ob_state & SELECTED )
								font_info.font_effects |= SHADOW ;
				objc_draw( form, SAMPLE, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
			case SAMPLE :
				objc_draw( form, SAMPLE, MAX_DEPTH, PTRS( app_modal_box() ) ) ;
				break ;
			default :
				break ;
		}
	}

	form[font].ob_state &= ~SELECTED ;
	form[size].ob_state &= ~SELECTED ;

	app_modal_end() ;
	if( fontlist != NULL )  free( fontlist ) ;

	if( !old_fonts )	vst_unload_fonts( handle, 0 ) ;
	vst_font( handle, attr[0] ) ;
	vst_height( handle, attr[7], &dummy, &dummy, &dummy, &dummy ) ;

	return selected ;
}


int __stdargs __saveds render_sample( PARMBLK *pb )
{
	short a, b ;
	short pxyarray[4] ;

	pxyarray[0] = ( pb->pb_x > pb->pb_xc ) ? pb->pb_x : pb->pb_xc ;
	pxyarray[1] = ( pb->pb_y > pb->pb_yc ) ? pb->pb_y : pb->pb_yc ;
	a = pb->pb_x + pb->pb_w - 1 ;  b = pb->pb_xc + pb->pb_wc - 1;
	pxyarray[2] = ( a < b ) ? a : b ;
	a = pb->pb_y + pb->pb_h - 1 ;  b = pb->pb_yc + pb->pb_hc - 1;
	pxyarray[3] = ( a < b ) ? a : b ;

	vs_clip( vdih, 1 /* CLIP_ON */, pxyarray ) ;
	vsf_color( vdih, 0 ) ;
	vsf_interior( vdih, FIS_SOLID ) ;
	vr_recfl( vdih, pxyarray ) ;

	use_fontinfo( vdih, *(FONTINFO *)(pb->pb_parm) ) ;
	v_gtext( vdih, pb->pb_x + 4, pb->pb_y + pb->pb_h - 4, "The quick brown fox jumps over a lazy dog" ) ;

	vs_clip( vdih, 0 /* CLIP_OFF */, pxyarray ) ;

	return 0 ;
}


void  use_fontinfo( int handle, FONTINFO select )
{
	short dummy ;

	vst_font( handle, select.font_index ) ;
	if( vq_vgdos() == '_FSM' )
		vst_arbpt( handle, select.font_size, &dummy, &dummy, &dummy, &dummy ) ;
	else
		vst_point( handle, select.font_size, &dummy, &dummy, &dummy, &dummy ) ;
	vst_effects( handle, select.font_effects ) ;
}


void  set_fontsel_addrs( void )
{
	short i ;

			/* looping assumes consecutive field numbers	*/
	assert( FSEL_FONT2 - FSEL_FONT1 == 1 ) ;
	assert( FSEL_FONT3 - FSEL_FONT2 == 1 ) ;
	assert( FSEL_FONT4 - FSEL_FONT3 == 1 ) ;
	assert( FSEL_FONT5 - FSEL_FONT4 == 1 ) ;
	assert( FSEL_FONT6 - FSEL_FONT5 == 1 ) ;
	assert( FSEL_FONT7 - FSEL_FONT6 == 1 ) ;
	assert( FSEL_FONT8 - FSEL_FONT7 == 1 ) ;
	assert( FSEL_SIZE2 - FSEL_SIZE1 == 1 ) ;
	assert( FSEL_SIZE3 - FSEL_SIZE2 == 1 ) ;
	assert( FSEL_SIZE4 - FSEL_SIZE3 == 1 ) ;
	assert( FSEL_SIZE5 - FSEL_SIZE4 == 1 ) ;
	assert( FSEL_SIZE6 - FSEL_SIZE5 == 1 ) ;
	assert( FSEL_SIZE7 - FSEL_SIZE6 == 1 ) ;
	assert( FSEL_SIZE8 - FSEL_SIZE7 == 1 ) ;
	
	font_sel_addrs.title = FORM_TEXT( form, FSEL_TITLE ) ;

	for( i=0; i<8; i++ )
	{
		font_sel_addrs.names[i+1] = FORM_TEXT( form, FSEL_FONT1 + i ) ;
	}
	for( i=0; i<8; i++ )
	{
		font_sel_addrs.sizes[i+1] = FORM_TEXT( form, FSEL_SIZE1 + i ) ;
	}

	font_sel_addrs.arbsize
					= FORM_TEXT( form, FSEL_ARBSIZE ) ;
}


int init_fontsel_form( short handle, GRECT *box, char *title,
													FONTINFO preselected )
{
	short _work_out[57] ;
	int i ;
	short font_found = FALSE ;
	int fonts ;
	char dummy[33] ;

	strcpy( font_sel_addrs.title, title ) ;

	vq_extnd( handle, 0, _work_out ) ;
	old_fonts = _work_out[10] ;
	fonts = old_fonts +	vst_load_fonts( handle, 0 ) - 1 ;
	
	fontlist = (Fontlist_type *) pmalloc( (size_t) ( fonts * sizeof( Fontlist_type ) ) ) ;
	if( fontlist == NULL )
	{
		release_memory() ;
		fontlist = (Fontlist_type *) pmalloc( (size_t) ( fonts * sizeof( Fontlist_type ) ) ) ;
	}
	if( fontlist == NULL )
	{
		rsrc_form_alert( 1, NO_MEMORY ) ;
		return 0 ;
	}

	for( i=0; i<fonts; i++ )
	{
		fontlist[i].number = i+2 ;
		fontlist[i].index = vqt_name( handle, i+2, dummy ) ;
	}
	vdih = handle ;	/* used in index_cmp	*/
	qsort( fontlist, (size_t) fonts, sizeof (Fontlist_type), index_cmp ) ;

	for( i=0; i<fonts; i++ )
	{
		if( fontlist[i].index == preselected.font_index )
		{
			font_found = TRUE ;

			if( i<8 )
			{	font_oset = 0 ;
				switch( i )
				{
					case 0 :	font = FSEL_FONT1 ; break ;
					case 1 :	font = FSEL_FONT2 ; break ;
					case 2 :	font = FSEL_FONT3 ; break ;
					case 3 :	font = FSEL_FONT4 ; break ;
					case 4 :	font = FSEL_FONT5 ; break ;
					case 5 :	font = FSEL_FONT6 ; break ;
					case 6 :	font = FSEL_FONT7 ; break ;
					case 7 :	font = FSEL_FONT8 ; break ;
				}
			}
			else
			{	font_oset = i - 7 ;
				font = FSEL_FONT8 ;
			}
		}
	}

	if( !font_found )	font = 0 ;
	else	form[font].ob_state |= SELECTED ;

	if( preselected.font_effects & THICKENED )
								form[FSEL_THICKEN].ob_state |= SELECTED ;
	else						form[FSEL_THICKEN].ob_state &= ~SELECTED ;
	if( preselected.font_effects & SHADED )
								form[FSEL_LIGHTEN].ob_state |= SELECTED ;
	else						form[FSEL_LIGHTEN].ob_state &= ~SELECTED ;
	if( preselected.font_effects & SKEWED )
								form[FSEL_SKEW].ob_state |= SELECTED ;
	else						form[FSEL_SKEW].ob_state &= ~SELECTED ;
	if( preselected.font_effects & UNDERLINED )
								form[FSEL_UNDERLINE].ob_state |= SELECTED ;
	else						form[FSEL_UNDERLINE].ob_state &= ~SELECTED ;
	if( preselected.font_effects & OUTLINE )
								form[FSEL_OUTLINE].ob_state |= SELECTED ;
	else						form[FSEL_OUTLINE].ob_state &= ~SELECTED ;
	if( preselected.font_effects & SHADOW )
								form[FSEL_SHADOW].ob_state |= SELECTED ;
	else						form[FSEL_SHADOW].ob_state &= ~SELECTED ;

	if( fonts > 8 )
	{
		form[FSEL_FONTDRAG].ob_height
					= form[FSEL_FONTSLIDER].ob_height * 8 / fonts ;
		fsel_set_slide( font_oset, fonts-8, form, FSEL_FONTDRAG,
												FSEL_FONTSLIDER, box ) ;
	}
	else
	{
		form[FSEL_FONTDRAG].ob_height = form[FSEL_FONTSLIDER].ob_height ;
		fsel_set_slide( 0, 1, form, FSEL_FONTDRAG, FSEL_FONTSLIDER, box ) ;
	}

	return fonts ;
}


int init_sizes( short handle, FONTINFO preselected, GRECT *box_ptr )
{
	int s ;
	int n = 0 ;
	int size_found = FALSE ;
	short dummy ;

	vst_font( handle, preselected.font_index ) ;

	for( s=0; s<=fsel_maxsize; s++ )
	{
		if( s == vst_point( handle, s, &dummy, &dummy, &dummy, &dummy ) )
		{	sizelist[n] = s ;
			n++ ;
		}
		if( n == MAX_FONTSIZES )	break ;
	}

	for( s=0; s<n; s++ )
	{
		if( sizelist[s] == preselected.font_size )
		{
			size_found = TRUE ;

			if( s<8 )
			{
				size_oset = 0 ;
				switch( s )
				{
					case 0 :	size = FSEL_SIZE1 ; break ;
					case 1 :	size = FSEL_SIZE2 ; break ;
					case 2 :	size = FSEL_SIZE3 ; break ;
					case 3 :	size = FSEL_SIZE4 ; break ;
					case 4 :	size = FSEL_SIZE5 ; break ;
					case 5 :	size = FSEL_SIZE6 ; break ;
					case 6 :	size = FSEL_SIZE7 ; break ;
					case 7 :	size = FSEL_SIZE8 ; break ;
				}
			}
			else
			{	size_oset = s - 7 ;
				size = FSEL_SIZE8 ;
			}
		}
	}

	if( !size_found )	size = 0 ;
	else	form[size].ob_state |= SELECTED ;

	if( n > 8 )
	{
		form[FSEL_SIZEDRAG].ob_height
					= form[FSEL_SIZESLIDER].ob_height * 8 / n ;
		fsel_set_slide( size_oset, size_entries-8, form, FSEL_SIZEDRAG,
												FSEL_SIZESLIDER, box_ptr ) ;
	}
	else
	{
		form[FSEL_SIZEDRAG].ob_height = form[FSEL_SIZESLIDER].ob_height ;
		fsel_set_slide( 0, 1, form, FSEL_SIZEDRAG, FSEL_SIZESLIDER, box_ptr ) ;
	}

	return n ;
}


int index_cmp( void *one, void *two )
{	
	char fontname1[33] ;
	char fontname2[33] ;

	vqt_name( vdih, ((Fontlist_type *)one)->number, fontname1 ) ;
	vqt_name( vdih, ((Fontlist_type *)two)->number, fontname2 ) ;
	
	return strcmp( fontname1, fontname2 ) ;
/*	return ((Fontlist_type *)one)->index - ((Fontlist_type *)two)->index ;
*/
}


void  display_font_list( short vdi_handle, GRECT box )
{
	int entry ;
	int n ;
	char fontname[33] ;

	for( entry=1; entry<=font_entries-font_oset && entry < 9; entry++ )
	{
		n = fontlist[ entry-1 + font_oset ].number ;
		vqt_name( vdi_handle, n, fontname ) ;
		strcpy( font_sel_addrs.names[entry], fontname ) ;
	}
	while( entry < 9 )
	{
		*(font_sel_addrs.names[entry++]) = '\0' ;
	}

	objc_draw( form, FSEL_FONTLIST, MAX_DEPTH,
									ELTS( box ) ) ;
}

void  display_size_list( GRECT box )
{
	int entry ;
	int n ;
	char length ;
	char size[8] ;
	int i ;

	for( entry=1; entry<=size_entries-size_oset && entry < 9; entry++ )
	{
		*(font_sel_addrs.sizes[entry]) = '\0' ;
		n = sizelist[ entry-1 + size_oset ] ;
		length = stci_d( size, n ) ;
		for( i = 5; i>length; i-- )
			strcat( font_sel_addrs.sizes[entry], " " ) ;
		strcat( font_sel_addrs.sizes[entry], size ) ;
	}
	while( entry < 9 )
	{
		*(font_sel_addrs.sizes[entry++]) = '\0' ;
	}

	objc_draw( form, FSEL_SIZELIST, MAX_DEPTH,
									box.g_x, box.g_y, box.g_w, box.g_h ) ;
}

void  selectfont( short handle, short obj, int new_font, FONTINFO *info,
																GRECT box )
{
	if( new_font <= font_entries )
	{
		if( font )
			form[font].ob_state &= ~SELECTED ;
		form[obj].ob_state |= SELECTED ;
		font = obj ;

		if( size )	form[size].ob_state &= ~SELECTED ;

		info->font_index = fontlist[new_font+font_oset-1].index ;
		strcpy( info->font_name, font_sel_addrs.names[new_font] ) ;

		size_entries = init_sizes( handle, *info, &box ) ;
		display_size_list( box ) ;

		objc_draw( form, FSEL_FONTLIST, MAX_DEPTH,
									box.g_x, box.g_y, box.g_w, box.g_h ) ;
	}
}

void  selectsize( short obj, int new_size, FONTINFO *info, GRECT box )
{
	if( new_size <= size_entries )
	{
		if( size )
			form[size].ob_state &= ~SELECTED ;
		form[obj].ob_state |= SELECTED ;
		size = obj ;

		info->font_size = sizelist[new_size+size_oset-1] ;
		sprintf( font_sel_addrs.arbsize, "%3d", sizelist[new_size+size_oset-1] ) ;

		objc_draw( form, FSEL_SIZELIST, MAX_DEPTH,
										box.g_x, box.g_y, box.g_w, box.g_h ) ;
		objc_draw( form, FSEL_ARBSIZE, MAX_DEPTH, box.g_x, box.g_y, box.g_w, box.g_h ) ;
	}
}

int  fsel_move_slide( OBJECT *tree, int slider, int slide_range,
															GRECT *box )
							/* This routine moves the slider and does	*/
							/* the redraw. It returns a number in the	*/
							/* standard GEM range of 0 to 1000.			*/
{
	int res ;
	int range ;

	res = graf_slidebox( tree, slide_range, slider, 1 ) ;

	range = tree[slide_range].ob_height - tree[slider].ob_height ;
	tree[slider].ob_y = res * range / 1000 ;

	objc_draw( tree, slide_range, MAX_DEPTH,
								box->g_x, box->g_y, box->g_w, box->g_h ) ;

	return res ;
}

void  fsel_set_slide( int value, int range, OBJECT *tree,
								int slider, int slide_range, GRECT *box )
							/* This routine moves the slider a distance	*/
							/* equal to jump/range times the maximum	*/
							/* slider movement.							*/
{
	short max_slide ;

	max_slide = tree[slide_range].ob_height - tree[slider].ob_height ;

	tree[slider].ob_y = value * max_slide / range ;
	objc_draw( tree, slide_range, MAX_DEPTH,
								box->g_x, box->g_y, box->g_w, box->g_h ) ;
}




FONTINFO uf_font_select( short handle, xUFSL_struct* ufsl, FONTINFO font_info, char *title )
{
	short _work_out[57] ;
	long maxfonts ;
	FW_INFO width = {0,0,0} ;
	short colour = 0 ;
	short skew = 0 ;
	
	vq_extnd( handle, 0, _work_out ) ;
	maxfonts = _work_out[10] + vst_load_fonts( handle, 0 ) - 1 ;
	
	ufsl_font_select( (long) handle, ufsl,
								(long) UFS_SIZE_CHANGE | UFS_ATTR_CHANGE
								| UFS_GDOS_FONTS | UFS_PROP_FONTS
								| UFS_WIND_DIALOG | UFS_ERROR_MSG,
				title, NULL,
				(XUFSL_LIST *) NULL, 0l, 0l,
				1l, 1l,													/* sys_small, long sysibm	*/
				&(font_info.font_index), &(font_info.font_size),
				&width, &(font_info.font_effects), &colour, &skew,
				maxfonts ) ;

	return font_info ;
}



FONTINFO font_select( short handle, FONTINFO font_info, char *title )
{
	FONTINFO selected_font ;

	if( prefs.external_font_selector )  font_selector = UFSL_FSEL ;
	else  font_selector = FT_FSEL ;
	
	switch( font_selector )
	{
		case FT_FSEL :
			selected_font = ft_font_select( handle, font_info, title ) ;
			break ;
		case UFSL_FSEL :
			{
				xUFSL_struct *ufsl ;
			
				ufsl = ufsl_cookie() ;
				if( ufsl )
					selected_font = uf_font_select( handle, ufsl, font_info, title ) ;
				else  selected_font = ft_font_select( handle, font_info, title ) ;
			}
			break ;
		default :
			selected_font = font_info ;
			break ;
	}
	
	return selected_font ;
}

