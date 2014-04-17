/*	DESKACT.C		5/31/89 - 6/19/89	Derek Mui	*/
/*	Take out vdi_handle from vdi calls	6/28/89			*/
/*	Fix hd_down, it needs to update menu	7/3/90	D.Mui		*/
/*	Modifying hd_down	7/8/90			D.Mui		*/
/*	Fix at hd_down to solve bug when mouse is moving too fast	*/
/*				4/16/91			D.Mui		*/
/*	Fix at file_op to check for destination drive	4/18/91	D.Mui	*/
/*	Fix at file_op to do update for all affected windows 4/18/91	*/
/*	Change all the iconblk to ciconblk	7/11/92	D.Mui		*/

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
#include <osbind.h>
#include <extern.h>

EXTERN	BYTE	*get_fstring();
EXTERN	BYTE	*lp_fill();
EXTERN	WINDOW	*get_win();
EXTERN	APP	*app_icon();
EXTERN	OBJECT	*get_tree();
EXTERN	WORD	in_parent();
EXTERN	APP	*app_xtype();
EXTERN	DIR	*get_dir();
EXTERN	BYTE	*put_name();

EXTERN	WORD	d_display;
EXTERN	WORD	f_rename;
EXTERN	WINDOW	*o_win;

EXTERN	WORD	d_dir;
EXTERN	WINDOW	*x_win;
EXTERN	WORD	x_type;

WORD	back_update;	/* update background	*/

/*	Check what kind of object is executable	*/
/*	Return TRUE if it is 			*/

	WORD
ch_obj( mx, my, win, item, type )
	WORD		mx,my;
	WINDOW		**win;
	WORD		*item;	
	WORD		*type;
{
	REG WORD	i;
	DIR		*dir;
	WORD		install;
	APP		*app;
	BYTE		*str;

	if ( i_find( mx, my, win, item, type ) )
	{
	  i = *item;
	  if ( i )		/* if there is object	*/
	  {
	    if ( *type == DESKICON )
	    {
	      if ( backid[i].i_type == XFILE )
	      {
		str = backid[i].i_path;
	        goto ch_1;
	      }
  
	      return( TRUE );
	    }
	    else
	    {
	       dir = get_dir( *win, i );
	       if ( dir->d_att & SUBDIR )	/* dir is OK	*/
	         return( TRUE );		     

	       str = put_name( *win, dir->d_name );
						/* check file type	*/
ch_1:	       app = app_xtype( str, &install );

	       if ( !install )
	       { 
	         switch ( app->a_type )		/* executable is OK	*/
	         {
	           case TOS:
	           case TTP:
	           case PRG:
	           case PTP:
	           case APPS:
		     return( TRUE );
		 }
	       }  
	    }/* window object	*/
	  }/* if object		*/
	}/* if found something	*/
	
	return( FALSE );
}

/*	Change for UNDO key	*/

	WORD
ch_undo()
{
	if ( ( Bconstat( 2 ) ) && 
	     ( Bconin( 2 ) == 0x00610000L ) &&
	     ( do1_alert( ABORTCON ) == 1 ) )
	  return( FALSE );

	return( TRUE ); 
}


/*	Perform a file operation	*/

	VOID
file_op( dest, mode )
	BYTE	*dest;
	WORD	mode;
{
	REG OBJECT	*obj;
	REG WORD	ret;
	WORD		type,item,i;
	WORD		keydown;
	LONG		ndir,nfile,nsize;
	BYTE		*source;
	BYTE		buffer[2];
	GRECT		pt;
	BYTE		*which;
					/* get the key state */

	graf_mkstate( &item, &item, &item, &keydown );
	f_rename = ( keydown & ALTER ) ? TRUE : FALSE;

	if ( !x_first( &source, &type ) )
	  return;

	if ( mode != OP_DELETE )
	{
	  if ( !ch_drive( *dest ) )	
	    return;	
	}

	d_display = TRUE;
	back_update = FALSE;
	buffer[1] = 0;

	obj = get_tree( CPBOX );
	obj[CDDRIVE].ob_flags &= ~HIDETREE;
	obj[DATEBOX].ob_flags &= ~HIDETREE;

	switch( mode )
	{
	  case OP_DELETE:
	    which = get_fstring( DELSTR );
	    obj[CDDRIVE].ob_flags |= HIDETREE;
	    obj[DATEBOX].ob_flags |= HIDETREE;
	    if ( !cdele_save )
	      d_display = FALSE;	

	    break;

	  case OP_COPY:
	    if ( ! ( keydown & K_CTRL ) )	/* control key down?	*/
	    {
	      which = get_fstring( ( f_rename ) ? CRENSTR : CPYSTR );
	      if ( !ccopy_save )
	        d_display = FALSE;

	      break;
 	    }
	   		
	  case OP_MOVE:
	    mode = OP_MOVE;
	    which = get_fstring( ( f_rename ) ? MRENSTR : MOVESTR );
	    if ( ( !ccopy_save ) && ( !cdele_save ) )
	      d_display = FALSE;

	    break;
	}

	build_rect( background, &pt, d_xywh[6], d_xywh[9] );

	if ( !dofiles( source, dest, OP_COUNT, &ndir, &nfile, &nsize, type, TRUE ) )
	{
	  do1_alert( STBADCOP );
	  return;
	}

	ndir += d_dir;		/* count also the number of dir in window */
	(TEDINFO*)(obj[TITLE].ob_spec)->te_ptext = which;
	f_str( obj, NUMDIR, ndir );
	f_str( obj, NUMFILE, nfile );
	obj[HIDECBOX].ob_flags |= HIDETREE;
	inf_sset( obj, CSDRIVE, Nostr );
	buffer[0] = *dest;
	inf_sset( obj, CDDRIVE, buffer );
	if (d_display)
	  obj[CHBOX1].ob_flags &= ~HIDETREE;
	else
	  obj[CHBOX1].ob_flags |= HIDETREE;
	fm_draw( CPBOX );	/* draw the box		*/

	if ( d_display )
	  item = form_do( obj, 0 ) & 0x7FFF;
	else
	  item = OKCP;

	p_timedate = ( obj[PYES].ob_state & SELECTED ) ? TRUE : FALSE;
	d_display = TRUE;

        if ( item == OKCP )
	{
	  obj[HIDECBOX].ob_flags &= ~HIDETREE;
	  bfill( 32, 0, dr );
	  x_first( &source, &type );
	  ret = dofiles( source, dest, mode, &ndir, &nfile, &nsize, type, TRUE );
	}

	obj[item].ob_state = NORMAL;
	do_finish( CPBOX );

	if ( ( item == OKCP ) && ( ret ) )
	{
	  for ( i = 0; i < 32; i++ )	/* update all the affected window */
	  {	  
	     if ( dr[i] )
	     {
	       buffer[0] = i + 'A';
	       up_2allwin( buffer );
             }
	  } 

	  if ( back_update )		/* clean up the memory	*/
	  {		
	    lp_collect();
	    if ( mode == OP_DELETE )	/* full screen		*/
	      rc_copy( &full, &pt );
	  }

	  if ( x_type == WINICON )	/* update source window	*/
	  {
	    i = x_win->w_path[0] - 'A';
	    if ( !dr[i] )		/* if it is not updated yet	*/	
	      up_2( x_win );
	  }

	  do_redraw( 0, &pt, 0 );
 	}
}


/*	Build a rectangle that can hold all the selected icons	*/

	WORD	
build_rect( obj, rect, w, h )
	REG OBJECT	*obj;
	REG GRECT	*rect;
	WORD	w,h;
{
	REG WORD	i;
	REG WORD	minx,miny;
	REG WORD	maxx,maxy;
	WORD		found;

	minx = full.x + full.w;
	miny = full.y + full.h;
	maxx = 0;
	maxy = 0;
	found = FALSE;

	for ( i = 1; i <= obj[0].ob_tail; i++ )
	{
	  if ( ( obj[i].ob_state & SELECTED ) && ( in_parent( obj, i ) ) )
	  {
	    found = TRUE;
		
	    if ( minx > obj[i].ob_x )
	      minx = obj[i].ob_x;
	 
	    if ( miny > obj[i].ob_y )
	      miny = obj[i].ob_y;

	    if ( obj[i].ob_x > maxx )
	      maxx = obj[i].ob_x;

	    if ( obj[i].ob_y > maxy )
	      maxy = obj[i].ob_y;
	  }
	}

	if ( found )
	{
	  rect->x = minx + obj[0].ob_x;
	  rect->y = miny + obj[0].ob_y;
	  rect->w = maxx - minx + w;
	  rect->h = maxy - miny + h;
	}
	else
	{
	  rect->x = 0;
	  rect->y = 0;
	  rect->w = 0;
	  rect->h = 0;
	}

	return( found );
}


/*	Check whose is inside the rect and select the object	*/

	WORD
chk_rect( win, rect, id )
	REG WINDOW	*win;
	GRECT		*rect;
	WORD		id;
{
	REG OBJECT	*obj;
 	REG WORD	i;
	REG WORD	minx,miny,maxx,maxy;
	WORD		orgx,orgy,select;
	GRECT		pt;
	WORD		doit;
	
	if ( win )
	{
	  rc_intersect( &win->w_work, rect );
	  doit = TRUE;
	  obj = win->w_obj;
	}
	else
	{
	  obj = background;
	  doit = FALSE;
	}

	orgx = obj[0].ob_x;
	orgy = obj[0].ob_y;
	select = FALSE;

	minx = orgx + obj[0].ob_width;
	miny = orgy + obj[0].ob_height;
	maxx = 0;
	maxy = 0;
	
	for ( i = 1; i <= obj[0].ob_tail; i++ )
	{
	   if ( !(obj[i].ob_flags & HIDETREE) )
	   {
	     rc_copy( &obj[i].ob_x, &pt );
	     pt.x += orgx;
	     pt.y += orgy;
	     if ( rc_intersect( rect, &pt ) )
	     {
	       if ( minx > obj[i].ob_x )
	         minx = obj[i].ob_x;
	 
	       if ( miny > obj[i].ob_y )
	         miny = obj[i].ob_y;

	       if ( obj[i].ob_x > maxx )
	         maxx = obj[i].ob_x;

	       if ( obj[i].ob_y > maxy )
	         maxy = obj[i].ob_y;

	       obj[i].ob_state = SELECTED;		 
	       select = TRUE;
	       if ( doit )
		 get_dir( win, i )->d_state = SELECTED;
	     }
	   }
	}

	if ( select )
	{
	  pt.w = maxx - minx + obj[1].ob_width;
	  pt.h = maxy - miny + obj[1].ob_height;
	  pt.x = minx + obj[0].ob_x;
	  pt.y = miny + obj[0].ob_y;
	  do_redraw( id, &pt, 0 );
	}
}


/*	Draw a box	*/

frame( x1, y1, x2, y2 )
	WORD	x1,y1,x2,y2;
{
	WORD	points[10];

	mice_state( M_OFF );
	points[0] = points[6] = points[8] = x1;
	points[1] = points[3] = points[9] = y1;
	points[2] = points[4] = x2;
	points[5] = points[7] = y2;
	gsx_attr( FALSE, MD_XOR, BLACK );
	gsx_xlines( 5, points );
	mice_state( M_ON );
}


/*	Draw a box and wait for button to go up		*/

r_box( id, win )
	WORD	id;
	WINDOW	*win;
{
	REG WORD 	tmpx, tmpy;
	REG WORD	tmpx1, tmpy1;
	WORD 		gr_mkmx,gr_mkmy;
	WORD 		gr_mkmstate,gr_mkkstate;
	GRECT		rect;

	graf_mkstate( &gr_mkmx, &gr_mkmy, &gr_mkmstate, &gr_mkkstate );

	if ( !( 0x0001 & gr_mkmstate ) )
	  return;	

	mice_state( POINT_HAND );

	rect.x = full.x;
	rect.y = full.y;
	rect.w = full.x + full.w; 
	rect.h = full.y + full.h;

	vs_clip( 1, &rect );

	wind_update( TRUE );

	while( TRUE )	
	{
	  if ( 0x0001 & gr_mkmstate )	
	  {
	    tmpy = tmpy1 = gr_mkmy;
	    tmpx = tmpx1 = gr_mkmx;
	    frame( tmpx, tmpy, tmpx1, tmpy1 );

	    while ( 0x0001 & gr_mkmstate )	
	    {
	      if (((tmpx1 != gr_mkmx) || (tmpy1 != gr_mkmy)) && (0x0001&gr_mkmstate))	
	      {
		frame( tmpx, tmpy, tmpx1, tmpy1 );
		frame( tmpx, tmpy, gr_mkmx, gr_mkmy );
		tmpy1 = gr_mkmy;
		tmpx1 = gr_mkmx;
	      }

	      graf_mkstate(&gr_mkmx, &gr_mkmy, &gr_mkmstate, &gr_mkkstate);
	    }

	    frame( tmpx, tmpy, tmpx1, tmpy1 );
	  }
	  break;
	}

	rect.x = min( tmpx, tmpx1 );
	rect.y = min( tmpy, tmpy1 );

	rect.w = abs( tmpx, tmpx1 );
	rect.h = abs( tmpy, tmpy1 );	

	if ( ( rect.w ) && ( rect.h ) )
	  chk_rect( win, &rect, id );

	wind_update( FALSE );
	mice_state( ARROW );
	return;
}

/*	Return an absolute value	*/

	WORD
abs( x, y )
	WORD x,y;
{
	if ( x > y )
	  return( x - y );
	else
	  return( y - x );
}


/*	Move icons from window to desktop	*/

win_desk( swin, sitems, ditem, mx, my )
	REG WINDOW	*swin;
	WORD		sitems,ditem,mx,my;
{
	DIR		*dir;
	REG WORD	i;
	WORD		temp,first,type,status,ntype;
	WORD		x,y;
	BYTE		buffer[14];
	BYTE		*str;
	BYTE		*tail;

	if ( !ditem )
	{
	  first = TRUE;
	  status = x_first( &str, &type );

	  while( status )
	  {
	    if ( type == SUBDIR )
	    {
	      ntype = XDIR;
	      save_mid( str, buffer );
	    }
	    else
	    {
	      ntype = XFILE;
	      save_ext( str, buffer );		    	
	    }

	    app_icon( buffer, ( type == SUBDIR ) ? FOLDER : -1, &temp );
	
	    if ( ( i = make_icon( 0, temp, ntype, buffer ) ) == -1 )
	    {
	      do1_alert( NOICON );
	      break;
	    }

	    if ( first )
	    {
	      objc_offset( swin->w_obj, sitems, &x, &y );
	      app_mtoi( mx + x, my + y, &background[i].ob_x, &background[i].ob_y );
	      first = FALSE;
	    }

	    lp_fill( str, &backid[i].i_path );

	    if ( !backid[i].i_path )
	    {
	      do1_alert( NOICON );
	      background[i].ob_flags |= HIDETREE;
	      break;
	    }
	
	    do_redraw( 0, &full, i );
	    status = x_next( &str, &type );

	  }/* while */

	  clr_xwin( swin, TRUE );
	}
	else		/* drop on desktop object	*/
	{
	  if ( backid[ditem].i_type == XFILE )
	  {
	     dir = get_dir( swin, sitems );
	     strcpy( swin->w_path, &swin->w_buf[1] );
	     rep_path( dir->d_name, &swin->w_buf[1] );
	     swin->w_buf[0] = strlen( &swin->w_buf[1] );
	     tail = swin->w_buf;
	  }
	  else
	    tail = Nostr;

	  to_desk( ditem, tail );
	}
}


/*	Move icons from desktop to desktop	*/

desk_desk( sitem, ditem, mx, my )
	WORD	sitem;
	WORD	ditem;
	WORD	mx,my;
{
	REG OBJECT	*obj;
	BYTE		buffer[14];
	REG BYTE	temp1;
	BYTE		temp2;
	GRECT		rect;
	WORD		sitems;
	BYTE		*tail;

	obj = background;

	if ( !ditem )			/* on the background	*/
	{
	  if ( ( mx ) || ( my ) ) 	/* moved		*/
	  {
	    sitems = 1;
	    while ( i_next( sitems, obj, &sitems ) )
	    {				/* copy x,y,w,h		*/
	      rc_copy( &dicon, &rect );	/* set x,y		*/
	      rect.x = obj[0].ob_x + obj[sitems].ob_x;
	      rect.y = obj[0].ob_y + obj[sitems].ob_y;
	      app_mtoi( rect.x + mx, rect.y + my, &obj[sitems].ob_x, &obj[sitems].ob_y );
	      do_redraw( 0, &rect, 0 ); 	/* erase old one	*/
	      do_redraw( 0, &full, sitems );	/* draw the new one	*/
	      sitems++;

	    }/* while */
	  }/* if moved */
	}/* if open area */
	else				
	{				/* check for floppy disk copy	*/
					/* 7/11/92			*/
	  temp1 = ((CICONBLK*)(obj[sitem].ob_spec))->monoblk.ib_char[1];
	  temp2 = ((CICONBLK*)(obj[ditem].ob_spec))->monoblk.ib_char[1];
	
	  if ( ( backid[sitem].i_type == DISK ) && ( backid[ditem].i_type == DISK ) )
	  {
	    if ( temp1 == temp2 )
	    {
	       do1_alert( STBADCOP );
	       return;
	    }
	    else
	    if ( ( ( temp1 == 'A' ) || ( temp1 == 'B' ) ) &&  
	           ( ( temp2 == 'A' ) || ( temp2 == 'B' ) ) )
 	    {
	       buffer[0] = temp1;
	       fc_start( buffer, CMD_COPY );
	       return;
	    }
	  }

	  if ( backid[ditem].i_type == XFILE )
	  {
	    if ( ch_tail( backid[sitem].i_path, path2 ) )
	      tail = path2;
	    else
	      return;
	  }
	  else
	    tail = Nostr;

	  to_desk( ditem, tail );
	}
}


/*	Ghost icon initalization	*/

	WORD
gh_init( obj, disk )
	REG OBJECT	*obj;
	WORD	disk;
{
	REG WORD	*ptr1;
	WORD		x,y,i,offx,offy;
	LONG		limit,j;
	WORD		count,lines;
	WORD		*ptr;
	OBJECT		*tree;

	if ( ! ( gh_buffer = Malloc( 0xFFFFFFFFL ) ) )
	  return( FALSE );

	gh_buffer = Malloc( gh_buffer );
	
	j = gh_buffer / 40;		/* 9 vertices x 2 x 2 	*/ 	
					/* + 1 ascushion	*/
	limit = (UWORD)obj->ob_tail;

	if ( limit > j )
	  limit = j;

	offx = obj->ob_x;
	offy = obj->ob_y;

	ptr1 = gh_buffer;
	ptr1++;			/* leave space to save the count	*/

	tree = obj++;
	lines = ( disk ) ? 9 : 5;

	for ( count = 0, j = 0; j < limit; j++, obj++ )
	{
	  if ( obj->ob_state & SELECTED )
	  {					/* if inside parent	*/
	    if ( in_parent( tree, (WORD)j+1 ) )
	    {
	      ptr = ( disk ) ? d_xywh : f_xywh;
	      x = obj->ob_x;
	      y = obj->ob_y;

	      for ( i = 0; i < lines; i++ )
	      {
	        *ptr1++ = *ptr++ + x + offx;
	        *ptr1++ = *ptr++ + y + offy;
	      }

	      count++;	
	    }
	  }
	}

	ptr1 = gh_buffer;
	*ptr1 = count;
	return( TRUE );
}


/*	Draw icons outline	*/ 

ghost_icon( offx, offy, disk )
	REG 	WORD	offx,offy;
	WORD	disk;
{
	REG WORD	*ptr;
	REG WORD	i,j,limit;
	WORD		lines;
	WORD		buffer[4];
	WORD		*start;

	mice_state( M_OFF );

	rc_copy( &full, buffer );	/* set clipping rectangle	*/
	buffer[2] = buffer[0] + buffer[2];
	buffer[3] = buffer[1] + buffer[3];
	vs_clip( 1, buffer );	

	gsx_attr( FALSE, MD_XOR, BLACK );

	ptr = gh_buffer;
	limit = *ptr++;
	
	lines = disk ? 9 : 5;	

	for ( j = 0; j < limit; j++ )
	{
	   start = ptr;

	   for ( i = 0; i < lines; i++ )
	   {
	     *ptr++ += offx;
	     *ptr++ += offy;
	   }

	   gsx_xlines( lines, start );
	}

	mice_state( M_ON );
}


/*	Handle the holding down button event	*/

	WORD
hd_down( sitem, stype, swin )
	REG WORD	sitem,stype;
	REG WINDOW	*swin;
{
	REG WORD	pitem,state;
	WORD		itype,w,h,ret,exec;
	WORD		mx,my,kstate,mstate;
	WORD		omx,omy;
	WORD		ditem,dtype;
	WORD		ptype,pid,docopy;
	WORD		cx,cy,offx,offy,o1,o2;
	WINDOW		*dwin;
	WINDOW		*pwin;
	REG OBJECT	*pobj;
	REG OBJECT	*sobj;
	GRECT		pt;
	GRECT		pt2;

    	graf_mkstate( &omx, &omy, &mstate, &kstate );

	if ( !i_find( omx, omy, &pwin, &ret, &ptype ) )
	  return;
					/* if no button or no object	*/
	if ( ( !( mstate & 0x1 ) ) || ( !sitem ) )
	  return;

	itype = TRUE;
	w = d_xywh[6];
	h = d_xywh[9];

	if ( stype == DESKICON )	/* source is desktop	*/
	  sobj = background;
	else				/* source is window	*/
	{
	  if ( s_view != S_ICON )
	  {
	    itype = FALSE;
	    w = f_xywh[2];
	    h = f_xywh[5];
	  } 
	
	  sobj = swin->w_obj;
	}
					/* if no object selected  */
	if ( !(sobj[sitem].ob_state & SELECTED) )
	{
	  while( TRUE )			/* wait until button comes up	*/
	  {
	    graf_mkstate( &omx, &omy, &mstate, &kstate );
	    if ( !( mstate & 0x1 ) )
	      break;
	  }
	  return;
	}

	if ( !gh_init( sobj, itype ) )
	{
	  do1_alert( FCNOMEM );
	  return;
	}

	mice_state( FLAT_HAND );

	ghost_icon( 0, 0, itype );	/* draw icon			*/
					/* draw the biggest rectangle	*/
	build_rect( sobj, &pt, w, h ); 
	rc_copy( &pt, &pt2 );

	state = SELECTED;
	i_find( omx, omy, &pwin, &ret, &ptype );
	pitem = ret;
	pobj = ( ptype == DESKICON ) ? background : pwin->w_obj;	
	pid = ( ptype == DESKICON ) ? 0 : pwin->w_id;

	ret = FALSE;		/* not into the loop yet	*/
	cx = omx;
	cy = omy;

	do
	{
	  graf_mkstate( &mx, &my, &mstate, &kstate );

	  if ( !( mstate & 0x1 ) )	/* no button down	*/	
	    break;

	  if ( ( abs( mx, omx ) > 2 ) || ( abs( my, omy ) > 2 ) ) 
	  {
	    o1 = pt.x;			/* save the old rectangle x,y	*/
	    o2 = pt.y;

	    pt.x = o1 + mx - omx;	/* update the new x.y	*/
	    pt.y = o2 + my - omy;

	    rc_constrain( &full, &pt );	/* check how far it can move	*/

	    offx = pt.x - o1;		/* movement distance	*/
	    offy = pt.y - o2;	

	    if ( offx )			/* movement	*/
	    {
	      if ( offx < 0 )		/* move left	*/	
	      {
		if ( cx < mx )
		  goto h_3;
	      }
	      else			/* move right	*/
	      {
		if ( mx < cx )
		{
h_3:		  pt.x -= offx;
		  offx = 0;
		}
	      }
	    }

	    cx += offx;			/* outline box x,y	*/

	    if ( offy )			/* movement	*/
	    {
	      if ( offy < 0 )		/* move left	*/	
	      {
		if ( cy < my )
		  goto h_4;
	      }
	      else			/* move right	*/
	      {
		if ( my < cy )
		{
h_4:		  pt.y -= offy;   
		  offy = 0;
		}
	      }
	    }

	    cy += offy;

	    ghost_icon( 0, 0, itype );		
						/* Look for object	*/
	    exec = ch_obj( mx, my, &dwin, &ditem, &dtype );

	    ret = TRUE;				/* pass the loop	*/

	    if ( ( pwin != dwin ) || ( pitem != ditem ) ||
		     ( ptype != dtype ) )
	    {
	      if ( pitem )		/* restore the previous item	*/
	      {
		if ( pobj[pitem].ob_state != state )
		{
		  pobj[pitem].ob_state = state;
		  do_redraw( pid, &full, pitem );
		}
	      }

	      if ( dtype == DESKICON )
	      {
		pid = 0;
		pobj = background;
	      }
	      else
	      {
		pid = dwin->w_id;
		pobj = dwin->w_obj;
	      } 		

	      state = pobj[ditem].ob_state;
	      docopy = ( state & SELECTED ) ? FALSE : TRUE;

	      if ( ditem && exec )		/* set the new item	*/
	      {
		if ( !( pobj[ditem].ob_state & SELECTED ) )
		{
		  pobj[ditem].ob_state |= SELECTED;
		  do_redraw( pid, &full, ditem );
		}
	      }
		
	      pwin = dwin;
	      pitem = ditem;
	      ptype = dtype;

	    }/* if moved 	*/

	    ghost_icon( offx, offy, itype );	/* draw icon	*/
	    omx = mx;
	    omy = my;

	  }/* if moved		*/

	}while ( TRUE );

	ghost_icon( 0, 0, itype );		/* erase ghost icon	*/

	Mfree( gh_buffer );

	mice_state( ARROW );

	if ( !ret )
 	  return;

	if ( pitem )		/* restore destination object's state */	
	{
	  pobj[pitem].ob_state = state;
	  do_redraw( pid, &full, pitem );
	}

	menu_verify();
					/* fall back on its own icon	*/
	if ( ( stype == dtype )	&& ( sitem == ditem ) )
	{
	  if ( dtype == WINICON )
	  {	
	    if ( swin == dwin )
	      goto h_2;
	  }
	  else
	    goto h_2;
	}

	if ( stype == WINICON )		/* source is window	*/
	{
	  if ( dtype == DESKICON )	/* Hit the desktop	*/
	  {
	    if ( ( !ditem ) || ( exec ) )
	      win_desk( swin, sitem, ditem, pt.x - pt2.x, pt.y - pt2.y );
	  }
	  else
	  {
	    if ( !exec )		/* if no executable the assume 	*/
	       ditem = 0;		/* it want to copy		*/
	    to_win( sitem, swin, ditem, dwin );
	  }
	}
	else				/* source is desktop	*/
	{
	  if ( dtype == DESKICON )	/* hit the desktop	*/
	  {
	    if ( !docopy )	/* treat everything as a move function */
	      ditem = 0;

	    if ( ( !ditem ) || ( exec ) )  	
	      desk_desk( sitem, ditem, pt.x - pt2.x, pt.y - pt2.y );
	  }
	  else				/* hit the window	*/
	  {
	    if ( !exec )
	      ditem = 0; 	
	    to_win( sitem, ( WINDOW *) 0, ditem, dwin );
	  }
	}

h_2:
	return;
}

/*	Take action when something is dragged to desktop area	*/

to_desk( ditem, tail )
	WORD	ditem;
	BYTE	*tail;
{
	BYTE		buffer[14];
	WORD		ret;
	REG IDTYPE	*itype;

	itype = &backid[ditem];

	switch( itype->i_type )
	{
	    case XDIR:
	      file_op( itype->i_path, OP_COPY );
	      break;
		
	    case DISK:			/* copy to disk		*/
	      strcpy( wildext, buffer );	
 	      buffer[0] = itype->i_cicon.monoblk.ib_char[1];
	      file_op( buffer, OP_COPY );
	      break;
	   
	    case TRASHCAN:
	      do_file( DELMENU );
	      break;
	      
	    case XFILE:
	      open_file( (WINDOW*)0, ditem, tail );
	      break;

	    case PRINTER:
	      print_file();
	      break;
	      			
	    default:
	      do1_alert( STBADCOP );	    
	      break;
	}
}


/*	Take action when something is dragged to window	*/

to_win( sitem, swin, ditem, dwin )
	WORD	sitem,ditem;
	WINDOW	*swin,*dwin;
{
	REG DIR		*dir;
	REG BYTE	*temp;

	temp = ( swin == dwin ) ? path3 : dwin->w_buf;
	strcpy( dwin->w_path, temp );

	if ( ditem )			/* copy to something	*/
	{
	  dir = get_dir( dwin, ditem );
	  if ( dir->d_att & SUBDIR ) 	/* win file to folder	*/
	    cat_path( dir->d_name, temp );
	  else				/* launch application	*/
	  {
	    if ( swin )			/* window to window	*/
	    {
	      if ( swin != dwin )
		temp = swin->w_buf;
	       	
	      dir = get_dir( swin, sitem );
	      strcpy( swin->w_path, &temp[1] );
	      rep_path( dir->d_name, &temp[1] );
	      temp[0] = strlen( &temp[1] );
	      open_file( dwin, ditem, temp );
	    }
	    else			/* desktop to window	*/
	    {
	      if ( ch_tail( backid[sitem].i_path, path2 ) )	
	        open_file( dwin, ditem, path2 );
	    }
	    return;
	  }
	}
				/* copy to the window	*/
	rep_path( getall, temp );
 	file_op( temp, OP_COPY );
}


/*	make a desktop icon	*/

	WORD
make_icon( drive, icon, type, text )
	WORD	drive,icon,type;
	BYTE	*text;
{
	REG WORD	id;
	REG IDTYPE	*itype;
	OBJECT		*obj;

	if ( ( id = av_icon() ) != -1 )
	{
	  itype = &backid[id];
	  obj = background; 
	  cp_iblk( icon, (CICONBLK*)(obj[id].ob_spec) );	       
          itype->i_type = type;
	  itype->i_cicon.monoblk.ib_char[1] = (BYTE)drive;
	  itype->i_icon = icon;
	  strcpy( text, (CICONBLK*)(obj[id].ob_spec)->monoblk.ib_ptext );
	}

	return( id );
}
