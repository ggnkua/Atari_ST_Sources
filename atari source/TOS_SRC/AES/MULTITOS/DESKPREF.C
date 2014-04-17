/*	DESKPREF.C		3/17/89	- 6/15/89	Derek Mui	*/
/*	Change at set color and pattern	6/29/90		D.Mui		*/ 
/*	Use m_st to determine the resolution	9/19/90	D.Mui		*/
/*	Add "SET FONT" stuff			5/24/93 H.M.Krober	*/

/************************************************************************/
/*	New Desktop for Atari ST/TT Computer				*/
/*	Atari Corp							*/
/*	Copyright 1989,1990 	All Rights Reserved			*/
/************************************************************************/

#include "portab.h"
#include "machine.h"
#include "obdefs.h"
#include "deskdefi.h"
#include "deskwin.h"
#include "osbind.h"
#include "deskusa.h"
#include "extern.h"
#include "pdesk.h"
#include "pmisc.h"
#include "pboth.h"

EXTERN	WORD	d_maxcolor;
EXTERN	OBJECT	*fontmn;
EXTERN	FNTLST	*d_fontlst;
EXTERN	WORD	win_font;
EXTERN	WORD	win_fsize;
EXTERN  WORD	win_wchar;
EXTERN  WORD	win_hchar;


	WORD
desk_chres( res, mode )
	WORD	res,mode;
{
	WORD	ret;

	if ( !mode )
	  res = res_handle( res );

	if ( !( ret = shel_write( 5, res, mode, 0x0L, 0x0L ) ) )
#if 0
	  form_alert( 1, "[1][ Can't do resolution change ][ OK ]" );
#else
	  do1_alert( NORESCHG ); /* ++ERS 12/16/92 */
#endif
	return( ret );
}


 
/*	Set Color and pattern	*/ 

	VOID
col_pa_pref( )
{
	REG OBJECT	*obj;
	REG WORD	ret;
	REG WINDOW	*win;
	LONG		newwin;
	LONG		newdesk;
	LONG		*outpat;
	WORD		last,i,j;
	WORD		editobj;
	WORD		s_font;
	LONG		s_fsize;
	WORD		redraw = FALSE;
		
	obj = get_tree( SSCREEN );

	newdesk = background[0].ob_spec;
	newwin = (LONG)windspec;
					/* set the background pattern */
	last = ret = obj[DESKPREF].ob_state & SELECTED ? DESKPREF : WINPREF;

	s_font  = win_font;		
	s_fsize = (LONG) win_fsize;

	if (last == WINPREF) {
	    obj[WFTITLE].ob_state  &= (~DISABLED);
	    obj[WINFONT].ob_state  &= (~DISABLED);
	    obj[WINFMBTN].ob_state &= (~DISABLED);
	    obj[WINFSIZE].ob_state &= (~DISABLED);
	    obj[WFSZDN].ob_state  &= (~DISABLED);
	    obj[WFSZUP].ob_state   &= (~DISABLED);
	    obj[WINFSIZE].ob_flags |= EDITABLE;
	    editobj = WINFSIZE;	
	} else {
	    obj[WFTITLE].ob_state  |= DISABLED;
	    obj[WINFONT].ob_state  |= DISABLED;
	    obj[WINFMBTN].ob_state |= DISABLED;
	    obj[WINFSIZE].ob_state |= DISABLED;
	    obj[WFSZDN].ob_state  |= DISABLED;
	    obj[WFSZUP].ob_state   |= DISABLED;
	    obj[WINFSIZE].ob_flags &= (~EDITABLE);
	    editobj = 0;	
	}
	((TEDINFO *)(obj[WINFONT].ob_spec))->te_ptext = 
		(LONG) d_fontlst[win_font].fnt_name;

	lbintoasc((LONG) s_fsize, 
		(BYTE*)((TEDINFO *)(obj[WINFSIZE].ob_spec))->te_ptext );
	
	for ( j = COLOR0,i = d_maxcolor; i < 16; i++ )
	  obj[j+i].ob_flags |= HIDETREE;	

	dr_dial_w( SSCREEN, FALSE, 0 /* dummy */ );

	goto c_1;
	
	while( TRUE )
	{
	  ret = xform_do( obj, editobj );
c_1:
	  if ( ret == SOK )
	    break;

	  if ( ret == SCANCEL )
	  {
	    if (s_font != win_font)
		    menu_icheck(fontmn, s_font + 1, FALSE);
	    do_finish( SSCREEN );
	    return;
	  }

	  if ( ret == DESKPREF )
	  {
	    outpat = &newdesk;
	    obj[DESKPREF].ob_state = SELECTED;
	    obj[WINPREF].ob_state = NORMAL;

	    obj[WFTITLE].ob_state  |= DISABLED;
	    obj[WINFONT].ob_state  |= DISABLED;
	    obj[WINFMBTN].ob_state |= DISABLED;
	    obj[WINFSIZE].ob_state |= DISABLED;
	    obj[WFSZDN].ob_state   |= DISABLED;
	    obj[WFSZUP].ob_state   |= DISABLED;
	    obj[WINFSIZE].ob_flags &= (~EDITABLE);
	    editobj = 0;
	    goto c_2;
	  }
		    
	  if (ret == WINPREF)
	  {
	    outpat = &newwin;
	    obj[DESKPREF].ob_state = NORMAL;
	    obj[WINPREF].ob_state = SELECTED;

	    obj[WFTITLE].ob_state  &= (~DISABLED);
	    obj[WINFONT].ob_state  &= (~DISABLED);
	    obj[WINFMBTN].ob_state &= (~DISABLED);
	    obj[WINFSIZE].ob_state &= (~DISABLED);
	    obj[WFSZDN].ob_state   &= (~DISABLED);
	    obj[WFSZUP].ob_state   &= (~DISABLED);
	    obj[WINFSIZE].ob_flags |= EDITABLE;
	    editobj = WINFSIZE;	
c_2:
	    draw_fld( obj, DESKPREF );
	    draw_fld( obj, WINPREF );
	    draw_fld( obj, WFTITLE );
	    draw_fld( obj, WINFONT );
	    draw_fld( obj, WINFMBTN );
	    draw_fld( obj, WINFSIZE );
	    draw_fld( obj, WFSZDN );
	    draw_fld( obj, WFSZUP );
	    obj[PATTERN].ob_spec = *outpat;
	  }

	  if ( (ret == WINFONT) || (ret == WINFMBTN) ) {
		WORD	start = 1;
		GRECT	brect;
		MENU	Menu, MData;
		WORD	flag;

		if (obj[WINFONT].ob_state & DISABLED) {
			continue;
		}
		obj[WINFONT].ob_state  |= SELECTED;
		draw_fld( obj, WINFONT );
		draw_fld( obj, WINFMBTN );
		objc_offset(obj, WINFONT, &brect.g_x, &brect.g_y );
		brect.g_y += (obj[WINFONT].ob_height + 1);

		Menu.mn_tree   = fontmn;
		Menu.mn_menu   = 0;
		Menu.mn_item   = s_font + 1;
		Menu.mn_scroll = -1;	/* scroll list popup */
		fontmn->ob_x = brect.g_x;
		fontmn->ob_y = brect.g_y;

		menu_icheck(fontmn, s_font + 1, TRUE );

		flag = menu_popup( &Menu, brect.g_x, brect.g_y, &MData );

		if (flag) {
			if( fontmn == MData.mn_tree ) {
				menu_icheck(fontmn, s_font + 1, FALSE);
				menu_icheck(fontmn, MData.mn_item, TRUE);
				s_font = MData.mn_item - 1;
				((TEDINFO *)(obj[WINFONT].ob_spec))->te_ptext = 
					(LONG) d_fontlst[s_font].fnt_name;				
        		}
		} else 
			menu_icheck(fontmn, s_font + 1, FALSE);

		obj[WINFONT].ob_state  &= (~SELECTED);
		draw_fld( obj, WINFONT );
		draw_fld( obj, WINFMBTN );
	  }

	  if (ret == WFSZDN) {
		if (obj[WFSZDN].ob_state & DISABLED) {
			continue;
		}
		asctobin((BYTE*)((TEDINFO *)(obj[WINFSIZE].ob_spec))->te_ptext, 
		&s_fsize);
		if (s_fsize > 1L) {
			s_fsize -= 1L;
			lbintoasc((LONG) s_fsize, 
			  (BYTE*)((TEDINFO *)(obj[WINFSIZE].ob_spec))->te_ptext );
			draw_fld( obj, WINFSIZE );
		}
	  }
	  if (ret == WFSZUP) {
		if (obj[WFSZUP].ob_state & DISABLED) {
			continue;
		}
		asctobin((BYTE*)((TEDINFO *)(obj[WINFSIZE].ob_spec))->te_ptext, 
		&s_fsize);
		if (s_fsize < 999L) {
			s_fsize += 1L;
			lbintoasc((LONG) s_fsize, 
			  (BYTE*)((TEDINFO *)(obj[WINFSIZE].ob_spec))->te_ptext );
			draw_fld( obj, WINFSIZE );
		}
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

	  m_objdraw( obj, OUTBOX, 2, 0, 0, full.g_w, full.g_h );
	  *outpat = obj[PATTERN].ob_spec;

	}/* while */

	do_finish( SSCREEN );

	if ( background[0].ob_type != G_USERDEF && background[0].ob_spec != newdesk )
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
	    if ( win->w_obj )	/* fixed 6/24/92 */	
	      win->w_obj[0].ob_spec = windspec;
	    if ( win->w_icnobj )	/* +++ HMK 5/6/93 */	
	      win->w_icnobj[0].ob_spec = windspec;

	    win = (WINDOW *) win->w_next;
	  }
		/* "All Iconified" window */
	  winpd[MAXWIN].w_icnobj[0].ob_spec = windspec; /* +++ HMK 5/27/93 */
	  redraw = TRUE;
	}

	/* window font stuff */

	asctobin((BYTE*)((TEDINFO *)(obj[WINFSIZE].ob_spec))->te_ptext, 
		&s_fsize);
	if ((win_font != s_font) || (win_fsize != (WORD) s_fsize)) {
		win_font  = s_font;
		win_fsize = (WORD) s_fsize;
		win = w_gfirst();
		while ( win ) {
			set_winfont(win->w_ted, win->w_maxicons);			
			view_fixmode(win);
			view_adjust(win);
			win = w_gnext();
		}
		redraw = TRUE;

		f_xywh[2] = win_wchar * 14;
		f_xywh[4] = win_wchar * 14;
		f_xywh[5] = win_hchar;
		f_xywh[7] = win_hchar;
 	}
	
	if (redraw) {		
		win = w_gfirst();
		while( win )
	  	{
	    		do_redraw( win->w_id, &full, 0 );
	    		win = w_gnext();
	  	}
	}
}
