#include <aes.h>
#include <vdi.h>

#include <global.h>
#include <vdi_ext.h>

# include "\pc\cxxsetup\aesutils.h"
# include "\pc\cxxsetup\main.h"
# include "\pc\cxxsetup\poti.h"
# include "\pc\cxxsetup\dialog.h"

# include "\pc\tcxx\tcxx.lib\tcxxfast.h"

# define WINDOWdescr void
# include "toolbox.h"
# include "text.h"
# include "drawutil.h"

# include "colors.h"

# include "drawwind.h"

int	curr_color, last_color ;

ReGrBl color_levels ;
ReGrBl curr_line_rgb = { 0, 0, 0 } ;
ReGrBl curr_text_rgb = { 0, 0, 0 } ;
ReGrBl curr_fill_rgb = { 0, 0, 0 } ;




/*--------------------------------------- update_color_potis ----------*/
void update_color_potis(void)

{
	ReGrBl rgb ;

	update_poti( &colix_poti,  curr_color ) ;

	vq_color(vdi_handle,curr_color,VQcolMode,rgb);
	update_poti( &rgb_poti[R], rgb[R] ) ;
	update_poti( &rgb_poti[G], rgb[G] ) ;
	update_poti( &rgb_poti[B], rgb[B] ) ;
}

/*--------------------------------------- display_color_potis ----------*/
void display_color_potis(void)

{
	ReGrBl rgb ;

	dis_poti ( &colix_poti,  curr_color );

	vq_color(vdi_handle,curr_color,VQcolMode,rgb);
	
	dis_poti ( &rgb_poti[R], rgb[R] );
	dis_poti ( &rgb_poti[G], rgb[G] );
	dis_poti ( &rgb_poti[B], rgb[B] );
}


/*----------------------------------------- rgb_poti_click ---------*/
void rgb_poti_click ( int bascol, int obj, int mx )
{
	vq_color ( vdi_handle, curr_color, VQcolMode, color_levels ) ;
	rgb_poti[bascol].value = &color_levels[bascol] ;
	poti_click ( &rgb_poti[bascol], obj, mx ) ;
}

/*----------------------------------------- set_current_rgb --------*/
void set_current_rgb(void)
{
	vs_color ( vdi_handle, curr_color, color_levels ) ;
	if ( ! palette_support )
		draw_big_color_box();
}


/*------------------------------------------ set_new_color ------*/
void set_new_color ( void )
{
	if ( curr_color != last_color )
	{
		last_color = curr_color ;

		MouseOff();
		display_color_potis();
		draw_big_color_box();
		MouseOn() ;
	}
}

/*------------------------------------------ change_vdi_color -*/
void change_vdi_color ( int newcol )
{
	if ( newcol != curr_color )
	{
		curr_color = newcol ;
		if ( palette_box_active() )
		{
			set_new_color();
		}
		else
		{
			update_color_potis() ;
			last_color = curr_color ;
		}
	}
}

		/*fedcba9876543210	*/
# define _0000000000000000	0
# define _0000000010000000	128
# define _0000001101100000	864
# define _0000010000010000	1040
# define _0000110000011000	3096
# define _0000100000001000	2056
# define _0001000000000100	4100
# define _0010000000000010	8194
# define _0100000000000001	16385

# if 1
MFORM mf_circle =
{
	7, 7,		/* mf_x/yhot				*/
	1, 0, 1,	/* mf_nplanes, mf_fg, mf_bg	*/
	{			/* mf_mask[16]				*/
  0x0000, 0x0000, 0x0000, 0x07C0, 
  0x0FE0, 0x1FF0, 0x1EF0, 0x1C70, 
  0x1EF0, 0x1FF0, 0x0FE0, 0x07C0, 
  0x0000, 0x0000, 0x0000, 0x0000
	},
	{			/* mf_data[16]				*/
  0x0000, 0x0000, 0x0000, 0x0000, 
  0x0380, 0x07C0, 0x0EE0, 0x0C60, /*0000.1100.0110.0000*/
  0x0EE0, 0x07C0, 0x0380, 0x0000, 
  0x0000, 0x0000, 0x0000, 0x0000
	}
} ;
# else
MFORM mf_circle =
{
	8, 8,		/* mf_x/yhot				*/
	1, 0, 1,	/* mf_nplanes, mf_fg, mf_bg	*/
	{			/* mf_mask[16]				*/
		_0000000000000000,
		_0000000000000000,
		_0000000010000000,
		_0000001101100000,
		_0000110000011000,
		_0000100000001000,
		_0001000000000100,
		_0001000000000100,
		_0010000000000010,
		_0001000000000100,
		_0001000000000100,
		_0000100000001000,
		_0000110000011000,
		_0000001101100000,
		_0000000010000000,
		_0000000000000000
	},
	{			/* mf_data[16]				*/
		_0000000000000000,
		_0000000010000000,
		_0000001101100000,
		_0000010000010000,
		_0000100000001000,
		_0001000000000100,
		_0010000000000010,
		_0010000000000010,
		_0100000000000001,
		_0010000000000010,
		_0010000000000010,
		_0001000000000100,
		_0000100000001000,
		_0000010000010000,
		_0000001101100000,
		_0000000010000000
	}
} ;
# endif


/*------------------------------------------ pick_rgb_color -----*/
void pick_rgb_color ( int boxobj, int *rgb )
{
	ReGrBl picked ;

	if ( fetch_rgb_color ( picked, "Farbe picken von beliebigem Punkt" ) & RIGHT_BUTTON )
		return ;
	rgb[0] = picked[0] ;				
	rgb[1] = picked[1] ;				
	rgb[2] = picked[2] ;	
	ObjectDraw ( tcdraw_tree, boxobj ) ;
}

/*--------------------------------------------- pick_color -----*/
void pick_color ( void )
{
	ReGrBl picked ;

	if ( fetch_rgb_color ( picked, "Farbe picken von beliebigem Punkt" ) & RIGHT_BUTTON )
		return ;
	color_levels[0] = picked[0] ;				
	color_levels[1] = picked[1] ;				
	color_levels[2] = picked[2] ;	
	set_current_rgb () ;
	display_color_potis() ;
}

/*----------------------------------------- fetch_color --*/
int fetch_color ( unsigned char *rgb, char *info )
{
	int pts[2], button ;

	MouseUser ( &mf_circle ) ;

	button = get_position ( pts, info ) ;
	MouseOff();
	get_tcpixel ( pts[X0], pts[Y0], rgb ) ;
	MouseOn();
	return button ;
}

/*----------------------------------------- fetch_rgb_color --*/
int fetch_rgb_color ( int *rgb, char *info )
{
	int pts[2], button ;

	MouseUser ( &mf_circle ) ;

	button = get_position ( pts, info ) ;
	MouseOff();
	vq_pixrgb ( vdi_handle, pts[X0], pts[Y0], rgb ) ;
	MouseOn();
	return button ;
}



/*--------------------------------------------- init_colors -----*/
void init_colors ( void )
{
	setup_poti ( &colix_poti,  tcdraw_tree, LWHITE ) ;
	setup_poti ( &rgb_poti[R], tcdraw_tree, RED ) ;
	setup_poti ( &rgb_poti[G], tcdraw_tree, GREEN ) ;
	setup_poti ( &rgb_poti[B], tcdraw_tree, BLUE ) ;

	setup_poti ( &clut_mask_poti[R], tcdraw_tree, RED ) ;
	setup_poti ( &clut_mask_poti[G], tcdraw_tree, GREEN ) ;
	setup_poti ( &clut_mask_poti[B], tcdraw_tree, BLUE ) ;

	upd_potilist ( &clut_mask_poti[R] ) ;
	update_clut_mask();
}
