/*	DESKPREF.C		3/17/89	- 6/15/89	Derek Mui	*/
/*	Change at set color and pattern	6/29/90		D.Mui		*/ 
/*	Use m_st to determine the resolution	9/19/90	D.Mui		*/
/*	Fixed at col_par_pref for window background 7/7/92	D.Mui	*/

/************************************************************************/
/*	New Desktop for Atari ST/TT Computer				*/
/*	Atari Corp							*/
/*	Copyright 1989,1990 	All Rights Reserved			*/
/************************************************************************/

#include <portab.h>
#include <mobdefs.h>
#include <defines.h>
#include <window.h>
#include <gemdefs.h>
#include <deskusa.h>
#include <extern.h>

EXTERN	OBJECT	*fm_draw();
EXTERN	OBJECT	*get_tree();
EXTERN	WINDOW	*w_gfirst();
EXTERN	WINDOW	*w_gnext();
EXTERN	BYTE	*get_string();

EXTERN	WORD	gl_restype;
EXTERN	WORD	d_exit;
EXTERN	WORD	font_save;
EXTERN	WORD	m_st;
EXTERN	BYTE	restable[];
EXTERN	WORD	d_maxcolor;

#if 0
/*	Set preferences dialog		*/

desk_pref()
{
	REG OBJECT		*obj;
	REG WORD	cyes, i, flag;
	    WORD	overwrite,font;

	obj = get_tree( ADSETPRE );
	cyes = cdele_save;
	obj[SPCDYES].ob_state = cyes;
	obj[SPCDNO].ob_state = !cyes;

	cyes = write_save;
	obj[YWRITE].ob_state = !cyes;
	obj[NWRITE].ob_state = cyes;

	cyes = ccopy_save;
	obj[SPCCYES].ob_state = cyes;
	obj[SPCCNO].ob_state = !cyes;

	for ( i = SPLOW; i <= SPEXT3; i++ )	/* hopefully they are in order	*/
	  obj[i].ob_state = NORMAL;

						/* set the resolution button */
	for ( i = 0,flag = SPLOW; i < 6; i++, flag++ )		
	{
	  if ( !restable[i] )
	    obj[flag].ob_state = DISABLED;
	}

	if ( m_st )
	{
	  for( i = SPEXT1; i <= SPEXT3; i++ )
	    obj[i].ob_flags |= HIDETREE;
	}

	if ( restable[4] )		/* TT high res	*/		
	  cyes = font_save;

	/* gl_restype is set according to followings:
					vdi handle
	1 = LOW RES	320 x 200	0, 2, 5, 7
	2 = MEDIUM RES	640 x 200	3		
	3 = HIGH RES	640 x 400	4
	4 = EXT1	640 x 480	6
	5 = EXT2	1280 x 960	8
	6 = EXT3 	320 x 480	9

	*/

	switch( gl_restype )
	{
	   case 1:
	     flag = SPLOW;
	     break;
		   
	   case 2:
	     flag = SPMEDIUM;
	     break;

	   case 3:
	     flag = SPHIGH;
	     break;
	
	   case 4:
	     flag = SPEXT1;
	     break;
		
	   case 5:
	     flag = SPEXT2;
	     break;

	   case 6:
	     flag = SPEXT3;
	     break;		

	}

	obj[flag].ob_state = SELECTED;

	if ( fmdodraw( ADSETPRE, 0 ) == SPOK )
	{
	  cdele_save = inf_what( obj, SPCDYES, SPCDNO );
	  ccopy_save = inf_what( obj, SPCCYES, SPCCNO );
	  write_save = !inf_what( obj, YWRITE, NWRITE );

	  flag = inf_gindex( obj, SPLOW, 6 ) + 1;

	  if ( app_reschange( flag ) )
	    d_exit = L_CHGRES;
	}

} /* inf_pref */
#endif
 
/*	Set Color and pattern	*/ 

	WORD
col_pa_pref( )
{
	REG OBJECT	*obj;
	REG WORD	ret;
	REG WINDOW	*win;
	LONG		newwin;
	LONG		newdesk;
	LONG		*outpat;
	WORD		last,i,j;
	
	obj = get_tree( SSCREEN );

	newdesk = background[0].ob_spec;
	newwin = (UWORD)windspec;
					/* set the background pattern */
	last = ret = obj[DESKPREF].ob_state & SELECTED ? DESKPREF : WINPREF;

	for ( j = COLOR0,i = d_maxcolor; i < 16; i++ )
	  obj[j+i].ob_flags |= HIDETREE;	

	fm_draw( SSCREEN );

	goto c_1;
	
	while( TRUE )
	{
	  ret = xform_do( obj, 0 );
c_1:
	  if ( ret == SOK )
	    break;

	  if ( ret == SCANCEL )
	  {
	    do_finish( SSCREEN );
	    return;
	  }

	  if ( ret == DESKPREF )
	  {
	    outpat = &newdesk;
	    obj[DESKPREF].ob_state = SELECTED;
	    obj[WINPREF].ob_state = NORMAL;
	    goto c_2;
	  }
		    
	  if ( ret == WINPREF )
	  {
	    outpat = &newwin;
	    obj[WINPREF].ob_state = SELECTED;
	    obj[DESKPREF].ob_state = NORMAL;
c_2:
	    draw_fld( obj, DESKPREF );
	    draw_fld( obj, WINPREF );
	    obj[PATTERN].ob_spec = *outpat;
	  }

	  if ( ( ret >= PAT0 ) && ( ret <= PAT7 ) )
	  {
	    obj[PATTERN].ob_spec &= 0xFFFFFF0FL;
	    obj[PATTERN].ob_spec |= obj[ret].ob_spec & 0x000000F0L;	
	  }
	  else				/* color changed	*/
	  if ( ( ret >= COLOR0 ) && ( ret <= COLOR15 ) )
	  {
	    obj[PATTERN].ob_spec &= 0xFFFFFFF0L;
	    obj[PATTERN].ob_spec |= obj[ret].ob_spec & 0x0000000FL;
	  }

	  objc_draw( obj, OUTBOX, 2, 0, 0, full.w, full.h );
	  *outpat = obj[PATTERN].ob_spec;

	}/* while */

	do_finish( SSCREEN );

	if ( background[0].ob_spec != newdesk )
	{
	  background[0].ob_spec = newdesk;
	  do_redraw( 0, &full, 0 );
	}

	win = winhead;

	if ( windspec != (UWORD)newwin )
	{
	  windspec = (UWORD)newwin;
	  while( win )
	  {
	    if ( win->w_obj )	/* fixed 7/7/92	*/
	      win->w_obj[0].ob_spec = windspec;
	    win = win->w_next;
	  }

	  win = w_gfirst();
	  while( win )
	  {
	    do_redraw( win->w_id, &full, 0 );
	    win = w_gnext();
	  }
	}
}
