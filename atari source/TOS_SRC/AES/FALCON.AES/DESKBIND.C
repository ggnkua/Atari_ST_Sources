/*	DESKBIND.C		6/16/89	- 9/14/89	Derek Mui	*/

/************************************************************************/
/*	New Desktop for Atari ST/TT Computer				*/
/*	Atari Corp							*/
/*	Copyright 1989,1990 	All Rights Reserved			*/
/************************************************************************/


#include <portab.h>
#include <struct88.h>

EXTERN	WORD	gl_wchar;
EXTERN	WORD	gl_hchar;
EXTERN	WORD	gl_wbox;
EXTERN	WORD	gl_hbox;
EXTERN	WORD	gl_handle;
EXTERN	WORD	pglobal[];

EXTERN	WORD	contrl[];
EXTERN	WORD	intin[];
EXTERN	WORD	ptsin[];
EXTERN	PD	*rlr;


wind_new()
{
	wm_new();
	dsptch();
}


	WORD
fsel_exinput( path, selec, button, label )
	BYTE	*path,*selec,*label;
	WORD	*button;
{
	WORD	ret;

	ret = fs_input( path, selec, button, label );
	dsptch();
	return( ret );
}


	WORD
rsrc_load( name )
	BYTE	*name;
{
	WORD	ret;

	ret = rs_load( pglobal, name );
	dsptch();
	return( ret );
}

	WORD
rsrc_obfix( tree, obj )
	LONG	tree;
	WORD	obj;
{
	WORD	ret;
	
	ret = rs_obfix( tree, obj );
	dsptch();
	return( ret );
}


	WORD
menu_popup( menu, x, y, mdata )
	LONG	menu,mdata;
	WORD	x,y;
{
	WORD	ret;

	ret = mn_popup( rlr->p_pid, menu, x, y, mdata );
	dsptch();
	return( ret );
}


	WORD
menu_istart( code, mtree, mmenu, start )
	WORD	code,mmenu,start;
	LONG	mtree;
{
	WORD	ret;

	ret = mn_istart( rlr->p_pid, code, mtree, mmenu, start );
	dsptch();
	return( ret );
}


objc_gclip( tree, which, x, y, rx, ry, w, h )
	LONG	tree;
	WORD	which;
	WORD	*x,*y,*rx,*ry,*w,*h;
{
	ob_gclip( tree, which, x, y, rx, ry, w, h );
	dsptch();
}


graf_mouse( style, pointer )
	WORD	style;
	BYTE	*pointer;
{
	gr_mouse( style, pointer );
	dsptch();
}

/*	show cursor	*/

v_show_c( reset )
	WORD	reset;
{
	intin[0] = reset;
	gsx_ncode( 122, 0, 1 );
}

/*	hide cursor	*/

v_hide_c( )
{
	gsx_ncode( 123, 0, 0 );
}


/*	enter graphic mode	*/

v_exit_cur( )
{
	contrl[5] = 2;
	gsx_ncode( 5, 0, 0 );
}

/*	enter alpha mode	*/

v_enter_cur( )
{
	contrl[5] = 3;
	gsx_ncode( 5, 0, 0 );
}

/*	clipping function	*/

vs_clip( clip_flag, pxyarray )
	WORD	clip_flag;
	WORD	pxyarray[];
{
	intin[0] = clip_flag;
	ptsin[0] = pxyarray[0];
	ptsin[1] = pxyarray[1];
	ptsin[2] = pxyarray[2];
	ptsin[3] = pxyarray[3];
	gsx_ncode( 129, 2, 1 );
}
