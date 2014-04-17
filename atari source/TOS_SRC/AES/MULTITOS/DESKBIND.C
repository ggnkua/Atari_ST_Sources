/*	DESKBIND.C		6/16/89	- 9/14/89	Derek Mui	*/

/************************************************************************/
/*	New Desktop for Atari ST/TT Computer				*/
/*	Atari Corp							*/
/*	Copyright 1989,1990 	All Rights Reserved			*/
/************************************************************************/

#include <portab.h>
#include <osbind.h>

EXTERN	WORD	gl_wchar;
EXTERN	WORD	gl_hchar;
EXTERN	WORD	gl_wbox;
EXTERN	WORD	gl_hbox;
EXTERN	WORD	gl_handle;
EXTERN	WORD	pglobal[];

EXTERN	WORD	contrl[];
EXTERN	WORD	intin[];
EXTERN	WORD	ptsin[];


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
