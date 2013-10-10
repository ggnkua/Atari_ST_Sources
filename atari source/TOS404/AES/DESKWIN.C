/*	DESKWIN.C		3/16/89	- 6/15/89 	Derek Mui	*/
/*	Take out vdi_handle	6/28/89					*/
/*	Put in error checking for window memory allocating 9/24/89	*/
/*	Add up_1allwin		11/14/90		D.Mui		*/
/*	Add up_2allwin		4/18/91			D.Mui		*/
/*	Fix at view_adjust for vertical slide box's size 7/9/91	D.Mui	*/
/*	Alloc window at create_window			7/7/92	D.Mui	*/
/*	Change all the iconblk to ciconblk	7/11/92	D.Mui		*/
/*	Change w_iblk to w_ciblk	7/11/92		D.Mui		*/

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
#include <osbind.h>
#include <deskusa.h>
#include <extern.h>
#include <error.h>

EXTERN	BYTE	*get_fstring();
EXTERN	OBJECT	*get_tree();

GRECT	sizes[] = { 150, 150, 150, 150 };
OBJECT	blank[] = { -1, -1, -1, G_BOX, NONE, NORMAL, 0x000000F0L, 0, 0, 0, 0 };

/*	Update the window info line	*/

winfo( win )
	WINDOW	*win;
{
	REG WORD	i;
	REG DIR		*dir;
	UWORD		j;
	LONG		sizes;
	LONG		sizes1;
	BYTE		buffer[14];
	BYTE		*type;

	dir = win->w_memory;
	j = 0;
	sizes = 0;
	sizes1 = 0;

	for ( i = 0; i < win->w_items; i++ )
	{
	  sizes += dir[i].d_size; 
	  if ( dir[i].d_state & SELECTED )
	  {
	    sizes1 += dir[i].d_size;
	    j++;
	  }
	}

	if ( j )		/* some items are selected	*/
	{
	  *( (LONG *) &buffer[0] ) = sizes1;
	  *( (WORD *) &buffer[4] ) = j;
	  type = get_fstring( ( j == 1 ) ? ISEL : ISELS );
	}
	else
	{
	  *( (LONG *) &buffer[0] ) = sizes;
	  *( (WORD *) &buffer[4] ) = (WORD)win->w_items;
	  type = get_fstring( ( win->w_items == 1 ) ? ISTR : ISTRS );
	}

	merge_str( win->w_info, type, buffer );
	wind_set( win->w_id, WF_INFO, win->w_info, 0, 0 );	
}


	WINDOW
*w_gnext()
{
	WINDOW 	*win;

	while( ww_win )
	{
	  win = ww_win;
	  ww_win = ww_win->w_next;	  
	  if ( win->w_id != -1 )
	    return( win );
	}

 	return( (WINDOW*)0 );
}

	WINDOW
*w_gfirst()
{
	ww_win = winhead;
	return( w_gnext() );
}



/*	Update all the windows, change dir path if fails	*/

	VOID
up_2allwin( path )
	BYTE	path[];
{
	REG WINDOW	*win;

	win = w_gfirst();
	
	while ( win )
	{
	  if ( path[0] == win->w_path[0] )
	  {
	    if ( !open_subdir( win, 0, FALSE, FALSE, TRUE ) )
	    {
	      strcpy( wilds, &win->w_path[2] );
	      open_subdir( win, 0, FALSE, FALSE, TRUE );
	    }
	  }

	  win = w_gnext();
	}
}


/*	Update all the windows					*/
/*	If the path has nothing, then update all the windows	*/

up_1allwin( path, full, change )
	BYTE	path[];
	WORD	full;	/* compare full path	*/
	WORD	change;
{
	REG WINDOW	*win;

	win = w_gfirst();
	
	while ( win )
	{
	  if ( !path[0] )
	    goto uu_1;

	  if ( full )		/* compare the full path	*/
	  {
	    if ( strcmp( path, win->w_path ) )
	      goto uu_1;
	  }
	  else			/* just the id	*/	
	  {
	    if ( path[0] == win->w_path[0] )
	    {
uu_1:  	      if ( !up_win( win, change ) )
	      {
	        strcpy( wilds, &win->w_path[2] );
	        up_win( win, FALSE );
	      }
	    }
	  }

	  win = w_gnext();
	}
}


up_allwin( path, full )
	BYTE	path[];
	WORD	full;
{
	up_1allwin( path, full, FALSE );
}
 


/* 	Do the actual update of a particular window	*/

	WORD
up_win( win, mediac )
	WINDOW	*win;
	WORD	mediac;
{
	BYTE	*ptr;
	WORD	ret;

	ptr = win->w_path;

	if ( ptr[0] != 'c' )
	{
	  if ( mediac )
	  {
	    desk_wait( TRUE );	  
	    if ( ret = hit_disk( (WORD)ptr[0] ) )
	      mediach( (WORD)(ptr[0] - 'A') );	
	      
	    desk_wait( FALSE );

	    if ( !ret )
	      return( FALSE );
	  }
	}

	if ( !open_subdir( win, 0, FALSE, FALSE, TRUE ) )
	{
	  if ( ( mediac ) && ( ret ) )	/* it is force media change	*/
	  {
	    strcpy( wilds, &win->w_path[2] );
	    return( open_subdir( win, 0, FALSE, FALSE, TRUE ) );
	  }
	}

	return( TRUE );
}

/*	Bring bottom window to top	*/

bottop()
{
	REG WINDOW	*win;
	WINDOW	*win1;
	WORD	item;
	WORD	buffer[8];

	if ( win = w_gfirst() )
	{
	  while( win )			/* get to the bottom one	*/
	  {
	    win1 = win;
	    win = w_gnext();
	  }	

	  if ( win1 != winhead )	/* stimulate a message call	*/
	  {
	    buffer[0] = WM_TOPPED;
	    buffer[3] = win1->w_id;
	    hd_msg( buffer );
	  }
	}
}


/*	Allocate memory for window path	*/

	WORD
path_alloc( level )		/* requested level	*/
	WORD	level;
{
	WORD	oldlevel,wsize;
	LONG	size;
	REG WORD	i;
	REG BYTE	*addr;
	BYTE	*path;

	oldlevel = d_level;

	while( d_level <= level )
	{
	  d_level = d_level * 2;
	}

	wsize = ( 13 * ( d_level + 1 ) ) + 3;
	size = ( MAXWIN * 2 * (UWORD)wsize ) + 1;
	addr = path = Malloc( size );
	
	if ( path )
	{
	  path3 = addr;
	  addr += wsize;
	
	  for ( i = 0; i < MAXWIN; i++ )
	  {
	    if ( winpd[i].w_path )
	      strcpy( winpd[i].w_path, addr );
	    else
	      *addr = 0;
	
	    winpd[i].w_path = addr;
	    addr += wsize;
	    winpd[i].w_buf = addr;
	    addr += wsize;
	    winpd[i].w_level = d_level;
	  }

	  free_path();

	  d_path = path;
	  return( TRUE );
	}
	else
	  do1_alert( FCNOMEM );
	
	d_level = oldlevel;	/* restore the old level	*/
	return( FALSE );
}


free_path()
{
	if ( d_path )
	{
/*	  form_alert( 1, "[1][ Free Path Memory ][ OK ]" );	*/
	  Mfree( d_path );
	  d_path = (BYTE*)0;
	}
}


/*	Clean up all the window		*/

clr_allwin( )
{
	REG WINDOW	*win;

	win = w_gfirst();

	while( win )
	{
	  clr_xwin( win, TRUE );
	  win = w_gnext();
	}
}


/*	Clean up and dselect the window objects		*/

clr_xwin( win, infoupdate )
	REG WINDOW	*win;
	WORD		infoupdate;
{
	OBJECT		*obj;
	REG WORD	i;
	WORD		change,ret;
	REG DIR		*dir;
	GRECT		pt;

	dir = win->w_memory;
	obj = win->w_obj;
	ret = build_rect( obj, &pt, obj[1].ob_width, obj[1].ob_height );
	change = FALSE;	
	
	for( i = 0; i < win->w_items; i++ )
	{
	  if ( dir[i].d_state & SELECTED )
	  {
	    change = TRUE;
	    dir[i].d_state = NORMAL;
	  }
	}

	if ( change )
	{
	  set_newview( win->w_srtitem, win );
	  if ( ret )
	    do_redraw( win->w_id, &pt, 0 );
	}

	if ( change && infoupdate )
	  winfo( win );
}



/*	Move the vertical bar	*/

srl_verbar( win, pos )
	REG WINDOW	*win;
	UWORD	pos;
{
	LONG	l;
	UWORD	i;
	WORD	diff,dir;

	l = pos * win->w_vvicons;
	i = l / 1000;

	if ( i == win->w_rowi )		/* No change	*/
	  return;

	diff = i - win->w_rowi;		/* Up or down	*/

	if ( diff < 0 )
	{
	  diff *= -1;
	  dir = SUP;
	}
	else
	  dir = SDOWN;
	  
	if ( diff < win->w_xrow )	/* less than one window	*/
	  srl_row( win, diff, dir );
	else
	{
	  win->w_rowi = i;
	  if ( win->w_vvicons )
	  {
	    l = 1000 * win->w_rowi;
	    l = l / win->w_vvicons;
	  }
	  else
	    l = 0;
  
	  wind_set( win->w_id, WF_VSLIDE, (UWORD)l, 0, 0, 0 );	

	  win->w_obj->ob_y = win->w_work.y;	/* reset at the topmost	*/
	  win->w_srtitem = i * win->w_icol;
	  up_1( win );
	}
}


/*	Move the horizontal bar	*/

srl_hzbar( win, pos )
	REG WINDOW	*win;
	UWORD	pos;
{
	LONG		l;
	UWORD		x,w;	
	REG OBJECT	*obj;
	REG WORD	diff,i;
	WORD		dir;

	l = pos * win->w_hvicons;
	i = l / 1000;
	
	if ( i == win->w_coli )
	  return;

	diff = i - win->w_coli;

	if ( diff < 0 )
	{
	  dir = SRIGHT;
	  diff *= -1;
	}
	else
	  dir = SLEFT;

	if ( diff < win->w_xcol )	/* less than one window	*/
	  srl_col( win, diff, dir );
	else
	{
	  win->w_coli = i;
	  if ( win->w_hvicons )
	  { 
	    l = 1000 * win->w_coli;
	    l /= win->w_hvicons;  
	  }
	  else
	    l = 0;

	  wind_set( win->w_id, WF_HSLIDE, (UWORD)l, 0, 0, 0 );	

	  x = win->w_work.x;
	  w = win->w_work.w;

	  obj = win->w_obj;	
	  obj[0].ob_x = x;	/* reset at the leftmost	*/
	  obj[0].ob_width = w;
	  i = i * fobj.w;
	  obj[0].ob_x -= i;
	  obj[0].ob_width += i;
	  objc_draw( obj, 0, 8, x, win->w_work.y, w, win->w_work.h );	  
	}
}



/*	Scroll the content down		*/

srl_row( win, row, dir )
	REG WINDOW	*win;
	WORD		row,dir;
{
	WORD		i;

	if ( dir == SDOWN )		/* scroll content dowm	*/
	{
	  i = win->w_vvicons - win->w_rowi;
	  if ( i )
	  {
	    if ( row > i )
	      row = i;

	    set_newview( win->w_srtitem + ( win->w_icol * row ), win );
	    blt_window( win, SDOWN, row );
	  }
	}
	else
	if ( win->w_rowi )		/* scroll content up	*/
	{
	  if ( ( win->w_rowi - row ) < 0 )
	    row = win->w_rowi;

	  set_newview( win->w_srtitem - ( win->w_icol * row ), win );	  
	  blt_window( win, SUP, row );
	}
}


srl_col( win, col, dir )
	REG WINDOW	*win;
	REG WORD	col;
	WORD		dir;
{
	if ( dir == SRIGHT )		/* scroll content right	*/
	{
	  if ( win->w_coli > 0 )
	  {
	    if ( ( win->w_coli - col ) < 0 )
	      col = win->w_coli;

	    blt_window( win, SRIGHT, col );
	  }
	}
	else				/* scroll content left	*/
	if ( win->w_coli < win->w_hvicons )
	{
	  if ( ( win->w_coli + col ) > win->w_hvicons ) 
	    col = win->w_hvicons - win->w_coli;

	  blt_window( win, SLEFT, col );
	}
}


/*	Bitblt a window content either up, dowm, left or right	*/

	WORD
blt_window( win, mode, size )
	REG	WINDOW	*win;
	WORD	mode,size;
{
	REG 	OBJECT	*obj;
	REG 	WORD	x,y;
		WORD	e_x[12];	/* bitblt rectangle	*/
		LONG	trash,l;
		WORD	y1,block,w,h,i;
		WORD	*ptr;
		GRECT	pt;

	mice_state( M_OFF );		
	obj = win->w_obj;		/* parent box		*/
	trash = 0x0L;

	rc_copy( &win->w_work, e_x );	/* copy the window's rectangle	*/
	rc_intersect( &full, &e_x[0] );	/* clip with screen	*/
					
	x = e_x[0];			/* get the real x,y,w,h */
	y = e_x[1];
	w = e_x[2];
	h = e_x[3];

	e_x[2] = e_x[0] + e_x[2];
	e_x[3] = e_x[1] + e_x[3];
	y1 = e_x[3];

	vs_clip( 1, e_x );		/* set clipping rect	*/
					/* scroll up or down	*/
	if ( ( mode == SUP ) || ( mode == SDOWN ) )
	{
	  i = size * win->w_icol;
	  block = obj[i].ob_height + obj[i].ob_y;
	  e_x[11] = e_x[3] = y + h - 1;	/* source's bottom	*/
	  e_x[1] = y + block;		/* source's top		*/

	  if ( e_x[1] > e_x[3] )	/* top > bottom		*/
	    e_x[1] = e_x[3];

	  e_x[9] = e_x[1];
	  e_x[8] = e_x[4] = e_x[0] = x;
	  e_x[10] = e_x[6] = e_x[2] = x + w - 1;
	  e_x[5] = y;			/* top of destination	*/
	  e_x[7] = e_x[3] - e_x[1] + e_x[5];

	  if ( mode == SUP )
	  {
	    win->w_rowi -= size;
	    ptr = &e_x[4];
	    y = e_x[5];
	  }
	  else
	  {
	    win->w_rowi += size;
	    ptr = &e_x[0];
	    y = e_x[7];
	  }

	  if ( y1 >= ptr[1] )		/* source is not off the screen	*/
	    vro_cpyfm( 3, ptr, &trash, &trash );
	  else
	    y = win->w_work.y;

  	  objc_draw( obj, 0, 8, x, y, w, block + 1 );
	  
	  if ( win->w_vvicons )
	  {
	    l = 1000 * win->w_rowi;
	    l = l / win->w_vvicons;  
	  }
	  else
	    l = 0;

	  wind_set( win->w_id, WF_VSLIDE, (UWORD)(l), 0, 0, 0 );

	}
	else				/* scroll left or right		*/
	{
	  block = obj[size].ob_width + obj[size].ob_x;
	  e_x[10] = e_x[2] = x + w - 1;
	  e_x[0] = x + block;
	  if ( e_x[0] > e_x[2] )
	    e_x[0] = e_x[2];
	  
	  e_x[8] = e_x[0];
	  e_x[9] = e_x[5] = e_x[1] = y;
	  e_x[7] = e_x[11] = e_x[3] = y + h - 1;
	  e_x[4] = x;
	  e_x[6] = e_x[2] - e_x[0] + e_x[4];

	  if ( mode == SRIGHT )	
	  {
	    win->w_coli -= size;
	    obj[0].ob_x += block;
	    obj[0].ob_width -= block;
	    x = e_x[4];
	    ptr = &e_x[4];
	  }
	  else
	  {
	    win->w_coli += size;
	    obj[0].ob_x -= block;
	    obj[0].ob_width += block;
	    x = e_x[6];
	    ptr = &e_x[0];
	  }

	  if ( block > w )
	  {
	    x = win->w_work.x;
	    goto bb_1;
	  }
	  else
	    w = block + 1;

	  vro_cpyfm( 3, ptr, &trash, &trash );
bb_1:
	  objc_draw( obj, 0, 8, x, y, w, h );
	  if ( win->w_hvicons )
	  {
	    l = 1000 * win->w_coli;
	    l /= win->w_hvicons;
	  }
	  else
	    l = 0;
  
	  wind_set( win->w_id, WF_HSLIDE, (UWORD)l, 0, 0, 0 );

	}

	mice_state( M_ON );
}


/*	Adjust everything inside the window because of window's */
/*	size has been changed or object type is changed		*/
/*	Adjust means we have to do recalculation		*/
/*	otherwise, pin down the left upper corner and just 	*/
/*	adjust the scroll bars					*/
  
view_adjust( win )
	REG WINDOW	*win;
{
	REG OBJECT	*obj;
	REG UWORD	x,col;
	UWORD	row;		/* must be unsigned	*/
	LONG	l;
	UWORD	i;

	obj = win->w_obj;

	/***  Figure out the vertical slide bar	***/

	x = win->w_items / win->w_icol;	/* number of row needed	*/

	if ( win->w_items % win->w_icol )
	  x++;

	if ( !x )			 /* at least one row	*/
	  x = 1;
	
	row = win->w_work.h / fobj.h; /* current visible number of row */

	win->w_xrow = row;

	win->w_vvicons = ( x < row ) ? 0 : ( x - row );

	if ( x > row )		/* if there is more need to be shown */	
	{
	  l = 1000 * row;
	  i = l / x;
	}
	else
	  i = 1000;

	wind_set( win->w_id, WF_VSLSIZE, i, 0, 0, 0 );

	if ( win->w_rowi > win->w_vvicons )
	  win->w_rowi = win->w_vvicons;

	if ( !win->w_vvicons )
          i = 0;
	else
	{
	  l = 1000 * win->w_rowi;
	  i = l / win->w_vvicons;
	}

	wind_set( win->w_id, WF_VSLIDE, i, 0, 0, 0 );

	/***    Figure the horizontal slide bar size	***/
	
	if ( win->w_icol <= 1 )
	  col = 1;
	else
	  col = win->w_work.w / fobj.w; /* current visible column	*/

	if ( !col )
	  col = 1;
	  
	x = ( win->w_items > win->w_icol ) ? win->w_icol : win->w_items;

	win->w_xcol = col;		/* current visible column	*/

	win->w_hvicons = ( x <= col ) ? 0 : ( x - col ) ;

	if ( !x )
	  i = 1000;
	else
	{
	  l = 1000 * col;
	  i = l / x;
	}

	wind_set( win->w_id, WF_HSLSIZE, i, 0, 0, 0 );

	if ( win->w_coli > win->w_hvicons )
	  win->w_coli = win->w_hvicons;

	obj[0].ob_x = win->w_work.x;
	obj[0].ob_x -= ( win->w_coli * fobj.w );
	obj[0].ob_width = win->w_work.w;
	obj[0].ob_width += ( win->w_coli * fobj.w );

	if ( !win->w_hvicons )	/* fits all the file	*/
	  i = 0;
	else
	{
	  l = 1000 * win->w_coli;
	  i = l / win->w_hvicons;
	}

	wind_set( win->w_id, WF_HSLIDE, i, 0, 0, 0 );
	set_newview( win->w_rowi * win->w_icol, win );		
}	


/*	Change the viewing mode, form text to icon or vice verse	*/

sort_show( mode, view )
	WORD	mode,view;
{
	REG WINDOW	*win;

	desk_wait( TRUE );

	win = w_gfirst();

	while( win )
	{
	  if ( view )
	  {
	    view_fixmode( win );	/* change icon or text mode */
	    view_adjust( win );		/* view adjust will set new view ptr */
	    do_redraw( win->w_id, &full, 0 );
	  }			
	  else
	  {
	    sort_file( win, mode ); 
	    up_1( win );
	  }

	  win = w_gnext();
	}

	desk_wait( FALSE );
}


/*	The viewing mode has been changed				*/
/*	Fix up the icon position according to largest window size	*/
/*	Call this routine before calling view_adjust!!!!!!!		*/
/*	It used the s_stofit flag to set the horizontal number of icon!	*/ 

view_fixmode( win )
	WINDOW	*win;
{
	REG WORD	x,y,w,i,offx;
	WORD		h,limitw,limith;
	WORD		type,offy;
	WORD		len,col,row,doitc;
	CICONBLK	*iblk;
	BYTE		*text;
	REG OBJECT	*obj;
	OBJECT		*obj1;
	TEDINFO		*ted;

	obj = win->w_obj;

	if ( s_view == S_ICON )		/* icon mode	*/
	{
	  w = dicon.w;
	  h = dicon.h;			/* Change also at deskinf.c	*/ 
	  offx = ( gl_hchar == 8 ) ? gl_wchar / 2 : gl_wchar; 
	  offy = gl_hchar / 2;		
	  type = G_CICON;
	  iblk = win->w_ciblk;
	}
	else				/* text mode	*/
	{
	  obj1 = get_tree( TEXTLINES );
	  len = strlen( ( (TEDINFO*)(obj1[TSTYLE].ob_spec) )->te_ptext );	
	  w = ( len - 1 ) * gl_wchar;
	  h = gl_hchar;	  
	  offx = 3 * gl_wchar;
	  offy = 2;
	  type = G_TEXT;
	  text = win->w_text;
	  ted = win->w_ted;
	}

	fobj.w = w + offx; 
	fobj.h = h + offy;

	if ( s_stofit )		/* size to fit	*/
	  limitw = win->w_work.w;
	else
	  limitw = full.w - gl_wbox;

	limith = full.h - ( 3 * gl_hbox );

	x = offx;
	y = offy;

	col = 0;		/* min one col one row	*/
	row = 0;

	doitc = TRUE;

	for ( i = 1; i < ( win->w_maxicons + 1 ); i++ )
	{
	  obj[i].ob_type = type;
	  obj[i].ob_x = x;
	  obj[i].ob_y = y;
	  obj[i].ob_width = w;
	  obj[i].ob_height = h;
	  obj[i].ob_next = i+1;

	  if ( s_view == S_ICON )	/* icon mode	*/	  
            obj[i].ob_spec = iblk++;
	  else
	  {
	    obj[i].ob_spec = ted;
	    ted->te_ptext = text;
	    text += len;
	    ted++;
	  }

	  col++;			/* one icon added	*/
	  x = x + w + offx;		/* point to next x pos	*/

	  if ( ( x + w ) > limitw )	/* off the edge?	*/
	  {
	    x = offx;			/* yes			*/
	    y = y + h + offy;
	    row++;
	    if ( doitc )
	    {
	      win->w_icol = col;	/* maximum col of icons	*/
	      doitc = FALSE;
	    }
	  }

	  if ( y >= limith )		/* At the bottom	*/
	    break;

	}/* for */

	win->w_irow = row;		/* maximum row of icons	*/

	/* Free up the rest of the icons	*/

	obj[0].ob_tail = i;
	obj[i].ob_next = 0;

	win->w_vicons = i;		/* maximum visible icons*/
}


/*	Make this window to be the top one	*/

make_top( win )
	REG WINDOW	*win;
{
	REG WINDOW	*winptr;	

	if ( win )
	{
/*	  set_dir( win->w_path );	*/

	  if ( winhead == win )		/* already on top	*/
	    return;

	  winptr = winhead;

	  while( winptr )	
	  {
	    if ( winptr->w_next == win )
	    {
	      winptr->w_next = win->w_next;
	      win->w_next = winhead;
	      winhead = win;
	      break;	
	    }

	    winptr = winptr->w_next;
	  }
	}
}


/*	Allocate a window object	*/
	
	WORD
alloc_obj( mode, win )
	WORD	mode;
	REG WINDOW	*win;
{
	REG WORD	i,j;
	REG UWORD	item;
	REG OBJECT	*obj1,*obj2;
	WORD		w,h,len;
	CICONBLK	*iblk;
	TEDINFO		*ted;
	UWORD		k;
	LONG		size;

 	i = full.w / dicon.w;		
	if ( full.w % dicon.w )
	  i++;	 

	j = full.h / dicon.h;
	if ( full.h % dicon.h )
	  j++;	 
	  
	item = i * j;

	obj2 = get_tree( TEXTLINES );

 	i = full.w / obj2[TSTYLE].ob_width;		
	if ( full.w % obj2[TSTYLE].ob_width )
	  i++;	 

	j = full.h / obj2[TSTYLE].ob_height;
	if ( full.h % obj2[TSTYLE].ob_height )
	  j++;	 
	  
	k = i * j;

	if ( k > item )
	  item = k;	

	len = strlen ( ( (TEDINFO*)(obj2[TSTYLE].ob_spec) )->te_ptext );

	size = 0;
	size += (UWORD)(( item + 1 ) * sizeof( OBJECT ) );
	size += (UWORD)( item * len );
	size += (UWORD)( item * sizeof( TEDINFO ) );
	size += (UWORD)( item * sizeof( CICONBLK ) );

	if ( win->w_obj = Malloc( size ) )
	{
	  obj1 = win->w_obj;

	  LBCOPY( obj1++, blank, sizeof( OBJECT ) );		

	  for( i = 0; i < item; i++ )	/* copy object structure */
	    LBCOPY( obj1++, &iconaddr[ICON1], sizeof( OBJECT ) );

	  win->w_ciblk = iblk = obj1;

					/* start of the iconblk area	*/
	  for( i = 0; i < item; i++ )	/* copy icon structure		*/
	    LBCOPY( iblk++, iconaddr[ICON1].ob_spec, sizeof( CICONBLK ) );

	  win->w_ted = ted = iblk;

	  for ( i = 0; i < item; i++ )
	    LBCOPY( ted++, obj2[TSTYLE].ob_spec, sizeof( TEDINFO ) );

	  win->w_text = ted;		/* set the text pointer		*/

	  win->w_maxicons = item;
	  return( TRUE );
	}
	else
	{	
	  win->w_maxicons = 0;
	  do1_alert( NOWINMEM );
	  return( FALSE );
	}
}

/*	Initalize all the windows	*/

ini_windows( )
{
	REG WORD	i;
	REG WINDOW	*win;

	d_level = 4;

	win = &winpd[0];

	for( i = 0; i < MAXWIN; i++, win++ )
	{
	  win->w_obj = (BYTE*)0;
	  win->w_path = (BYTE*)0;	/* window path	*/
	  win->w_buf = (BYTE*)0;	  
	  win->w_free = FALSE;		/* window is not free yet	*/
	  win->w_level = 0;	  
	  win->w_id = -1;		/* window is not open		*/
	  win->w_rowi = 0;
	  win->w_coli = 0;	  
	  win->w_memory = 0x0L;		/* clean up file memory		*/

	  /* Put in default sizes, in case users have old inf file */
	  
	  rc_copy( sizes, &win->w_work );
	  rc_copy( sizes, &win->w_sizes );
	}		

	path_alloc( 4 );		/* allocate path memory	*/

	win = &winpd[0];

	for( i = 0; i < MAXWIN; i++, win++ )
	{
#if 0
	  if ( !alloc_obj( 0, win ) )  /* in case memory alloc failed	*/
	  {
	    do1_alert( NOWINMEM );
	    break;
	  }
#endif
	  win->w_next = &winpd[i+1];
	  win->w_free = TRUE;		/* this window is available	*/
	}

	winpd[i-1].w_next = (BYTE*)0;
	winhead = &winpd[0];
}


	VOID
ret_win( win )
	WINDOW	*win;
{
	if ( win->w_obj )
	{
	  Mfree( win->w_obj );
	  win->w_obj = (OBJECT*)0;
	}

	win->w_free = TRUE;
}


	WINDOW
*alloc_win( )
{	
	REG WINDOW	*win;	
	
	win = winhead;

	while( win )
	{
	  if ( win->w_free )
	  {
	    if ( !alloc_obj( 0, win ) )		/* allocate objects */
	    {
	      do1_alert( NOWINMEM );	
	      break;
	    }
	    win->w_free = FALSE;
	    return( win );
	  }

	  win = win->w_next;
	}

	return( (WINDOW*)0 );
}


/*	Get the window data structure address according to handle	*/

	WINDOW
*get_win( handle )
	WORD	handle;
{
	REG WINDOW	*win;

	win = winhead;
	
	while( win )
	{
	   if ( win->w_id == handle )
	     break;

	   win = win->w_next;
	}

	return( win );	
}


/*	Open window	*/

	WORD
open_window( handle )
	WORD	handle;
{
	REG WINDOW	*win;

	win = get_win( handle );		/* window's size	*/
						/* open it		*/

	win->w_obj->ob_spec = windspec;		/* set window's color	*/

	do_xyfix( &win->w_sizes );
	
	wind_open( handle, win->w_sizes.x, win->w_sizes.y, win->w_sizes.w, 
		   win->w_sizes.h );

	wind_get( handle, WF_CURRXYWH, &win->w_sizes.x, &win->w_sizes.y, 
		  &win->w_sizes.w, &win->w_sizes.h );

						/* get the working area	*/
						/* and set it to object	*/
	wind_get( handle, WF_WORKXYWH, &win->w_work.x, &win->w_work.y,
		  &win->w_work.w, &win->w_work.h );
						
	rc_copy( &win->w_work, &win->w_obj->ob_x );
	make_top( win );
}


/*	Create Window of its full size	*/

	WORD
create_window( )
{
	REG WINDOW	*win;
	WORD	handle;
					/* Do we have any window pd ?	*/
	if ( win = alloc_win( ) )
	{
	  handle = wind_create( ALLITEMS, win->w_sizes.x, win->w_sizes.y, 
			win->w_sizes.w, win->w_sizes.h );
		
	  if ( handle < 0 )		/* release windows	*/
	    ret_win( win );
	  else
	  {
	    win->w_id = handle;
	    return( handle );
	  }
	}
	return( -1 );
}


/*	Get the top window		*/

	WINDOW 
*get_top()
{
	return( w_gfirst() );

#if UNLINKED
	WORD	handle, ret;
	WINDOW	*win;

					/* find out who is on top	*/
	wind_get( 0, WF_TOP, &handle, &ret, &ret, &ret );
	if ( handle > 0 )
	{
	  if ( win = get_win( handle ) )
  	    return( win );
	}
	return( (WINDOW*)0 );
#endif
}


/*	Close and delete a window	*/

close_window( handle, closeit )
	WORD	handle,closeit;
{
	REG WINDOW	*win;

	if ( closeit )		/* close window		*/
	  wind_close( handle );

	/*	Delete window and assume it is closed	*/
	/*	Free up the file memory 		*/

	if ( win = get_win( handle ) )
	{
	  win->w_id = -1;
	  win->w_free = TRUE;
	  if ( win->w_memory )
	  {
	    Mfree( win->w_memory );
	    win->w_memory = (BYTE*)0;
	  }	
	  wind_delete( handle );

	  if ( closeit )
	  {
	    while( win )
	    {
	      if ( win->w_id != -1 )
	      {
	        make_top( win );
	        break;
	      }
	      else
		win = win->w_next;
	    }
	  }
	}
}



/*	Free and close all the windows and free the objects	*/ 

free_windows( )
{
	REG WINDOW	*win;
	WORD	i;
	
	for ( i = 0; i < MAXWIN; i++ )
	{
	   win = &winpd[i];

	   if ( win->w_obj )
	   {
	     Mfree( win->w_obj );
	     win->w_obj = (BYTE*)0;
	   }			
	
	   /* don't close window, do it at the sh_main */

	   if ( win->w_id != -1 )	
	     close_window( win->w_id, FALSE );
	}

	free_path();				
}

/*	This is my own redraw routine		*/

do_redraw( handle, pc, which )
	REG WORD	handle;
	GRECT	*pc;
	WORD	which;
{
	GRECT	pt;
	REG OBJECT	*obj;
	WINDOW	*win;
	GRECT	px;

	rc_copy( pc, &px );
	
	wind_get( handle, WF_FIRSTXYWH, &pt.x, &pt.y, &pt.w, &pt.h );

	if ( handle > 0 )
	{
	  win = get_win( handle );
	  obj = win->w_obj;
	}
	else
	  obj = background;

	if ( which )
	{
	  objc_offset( obj, which, &px.x, &px.y ); 
	  px.w = obj[which].ob_width;
	  px.h = obj[which].ob_height;	
	}

	while( pt.w && pt.h )
	{
	  if ( rc_intersect( &px, &pt ) )
	  {
	    if ( rc_intersect( &full, &pt ) )
	      objc_draw( obj, 0, 8, pt.x, pt.y, pt.w, pt.h );
	  }			      			
	  wind_get( handle, WF_NEXTXYWH, &pt.x, &pt.y, &pt.w, &pt.h );
	}
}


do_xyfix( pc )
	REG	GRECT	*pc;
{
	GRECT	rect;
	
	rc_copy( &full, &rect );

	pc->w =	min( pc->w, rect.w );
	pc->h =	min( pc->h, rect.h );
	
	if ( pc->x >= ( rect.x + rect.w ) )
	  pc->x = rect.x + rect.w;
	  
	if ( pc->x < rect.x )
	  pc->x = rect.x;

	if ( pc->y >= ( rect.y + rect.h ) )
	  pc->y = rect.y + rect.h;

	if ( pc->y < rect.y )
	  pc->y = rect.y;

	rect.x = pc->x;

	pc->x = (rect.x & 0x000f);
	
	if ( pc->x < 8 )
	  pc->x = rect.x & 0xfff0;
	else
	  pc->x = (rect.x & 0xfff0) + 16;

	pc->y = max(pc->y, rect.y);
}
