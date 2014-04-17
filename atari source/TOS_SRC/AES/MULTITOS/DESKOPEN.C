/*	DESKOPEN.C		3/16/89 - 5/23/89	Derek Mui	*/
/*	Fix show item		9/6/89			D.Mui		*/
/*	Fixed open dir when there is no window	7/20/90	D.Mui		*/
/*	Fixed at do_box when it is from desktop	5/2/91	D.Mui		*/
/*	Chnaged at close_path			9/30/91	D.Mui		*/
/*	Change all the iconblk to ciconblk	7/11/92	D.Mui		*/
/*	Add support for icnoified windows	6/02/93 H.M.Krober	*/
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
#include "deskusa.h"
#include "osbind.h"
#include "extern.h"
#include "pdesk.h"
#include "pmisc.h"


EXTERN	WORD	numicon;
EXTERN	WINDOW	*x_win;
EXTERN	WORD	x_status;
EXTERN	WORD	x_type;
EXTERN	WORD	back_update;

EXTERN	WORD	contrl[];
EXTERN	WORD	intout[];

/*	open the default windows	*/

	VOID
open_def( )
{
	REG WORD	i;
	REG WINDOW	*win;

	wind_update(1);

	win = winpd;

	for ( i = 0; i < MAXWIN; i++ )
	{
	  if ( win[i].w_path[0] )
	  {
	    if ( !open_disk( 0, win[i].w_path, FALSE ) )
	      win[i].w_path[0] = 0;
	  }
	}

	wind_update(0);
}

	VOID
ch_path( win )
	REG	WINDOW	*win;
{
	WORD	i,num,len;
	WORD	temp1, temp2;

	i = 0;
	len = strlen( win->w_path );

	if ( ( win->w_sizes.g_w >= full.g_w ) || ( len >= 127 ) )
	{
	  num = ( win->w_sizes.g_w - ( 2 * gl_wbox ) ) / gl_wchar;
	  if ( len > num ) 
	    i = len - num;	
	}

	temp1 = (WORD) ((LONG)&win->w_path[i] >> 16L );
	temp2 = (WORD) ((LONG)&win->w_path[i] & 0x0000FFFFL );
	wind_set( win->w_id, WF_NAME, temp1, temp2, 0, 0 );	
}


/*	Pass in window stuff and tells if you want to open it or not	*/
/*	init -- initalize window	*/
/*	open -- open a disk		*/

	WORD
open_subdir( win, icon, opendisk, init, redraw )
	REG WINDOW	*win;
	WORD	icon,opendisk,init,redraw;
{
	WORD	handle; 
	WORD	status;

	desk_mice( HOURGLASS );
	status = FALSE;
	
	if ( !c_path_alloc( win->w_path ) )	/* check the path length*/
	  goto sub_1;

	handle = win->w_id;

	if ( read_files( win, 0x16 ) )
	{
	  if ( init )		/* initalize to zero	*/
	  {
	    wind_set( handle, WF_HSLIDE, 0, 0, 0, 0 );
	    wind_set( handle, WF_VSLIDE, 0, 0, 0, 0 );
	    win->w_coli = 0;
	    win->w_rowi = 0;
	    win->w_obj->ob_width = win->w_work.g_w;
	  }

	  ch_path( win );		/* check and set the path	*/
	  winfo( win );

	  if ( opendisk )		/* open a disk	*/
	  {
	    do_box( win, icon, TRUE, TRUE, FALSE );
	    win->w_icon = icon;		/* set the new icon number that	*/
	    open_window( handle );
	    view_fixmode( win );	  
	  }

	  view_adjust( win );	/* adjust icons according to 	*/
	  status = TRUE;
	}

sub_1:
	if ( status && redraw )
	  do_redraw( win->w_id, &win->w_work, 0 );

	desk_mice( ARROW );
	return( status );
}


	VOID
show_item()
{
	REG WINDOW	*win;

	wind_update(1);
	if ( x_status ) {		/* something is selected	*/
	  if ( x_win && x_win->w_iconified && (x_win->w_icndir.d_name[0] == '\\') 
	  && (x_win->w_icndir.d_name[1] == '\0') ) {
	    	strcpy( wildext, x_win->w_buf );	/* we are at root */
	   	x_win->w_buf[0] = x_win->w_path[0];	/* so		  */
		sh_disk( x_win->w_buf );		/* show disk info */
	  } else		
		  sh_sitems();
	} else
	{
	  if ( win = w_gfirst() )
	  {
	    strcpy( wildext, win->w_buf );
	    win->w_buf[0] = win->w_path[0];
	    sh_disk( win->w_buf );
	  }
	}
	wind_update(0);
}


/*	Show the info of a selected item	*/

	VOID
sh_sitems( )
{
	DIR		dir1;
	REG DIR		*dir;
	DIR		*dir2;
	REG OBJECT	*obj;
	REG WORD	curri,ret,which;
	WORD		cont,changed,limit;
	WORD		opened,subtype;
	LONG		ndir,nfile,nsize;	
	BYTE		buffer[20];
	BYTE		newname[14];
	BYTE		*newstr;
	BYTE		*oldstr;
	UWORD		len,pos;
	BYTE		*file;
	BYTE		*savestr;

	changed = FALSE;	/* any changes made?	*/
	cont = TRUE;
	opened = FALSE;
	back_update = FALSE;	

	obj = get_tree( ADFILEIN );
	bfill( 32, 0, dr );	/* set up drive table	*/

	if ( x_type == DESKICON )
	{
	  limit = background[0].ob_tail; 
	  curri = 1;
	}
	else
	{
	  if (x_win->w_iconified) {	/* get the right dir */
	  	dir2 = &x_win->w_icndir;
		limit = 1;
	  } else {
		dir2 = (DIR *) x_win->w_memory;
		limit = x_win->w_items;
	  }
	  curri = 0;
	}

	while( cont )
	{			/* desktop icon		*/	
   	  if ( x_type == DESKICON )	
	  {
ss_1:	    for ( ; curri <= limit; curri++ )
	    {
	      if ( background[curri].ob_state & SELECTED )
		break;
	    }
	    if (curri > limit)
	      goto get_out;


	    subtype = backid[curri].i_type;
	    file = backid[curri].i_path;

	    ret = PRINTINF;
	    
	    switch( subtype )
	    {
	      case TRASHCAN:	/* trash can info	*/
		ret = TRSINFO;
	      case PRINTER:	/* printer info		*/
	        fill_string( backid[curri++].i_name, ret );
	        goto ss_1;
	      case DISK:
		strcpy( wildext, buffer );
		buffer[0] = (BYTE) 
		 ((CICONBLK*)(background[curri++].ob_spec))->monoblk.ib_char;

	        if ( sh_disk( buffer ) )
	          goto ss_1;
		else
		  goto get_out;
	    }			
	
	    curri++;

	    if ( *file == 'c' )
	    {
	      do1_alert( CARTNOSH );
	      goto ss_1;
	    }
	
	    if ( subtype == XFILE )
	    {		
	      if ( m_sfirst( file, 0x31 ) )	/* get the dir block	*/
	      {
	        fill_string( file, FNOTFIND );	
	        goto ss_1;
	      }
	    }

	    dir1 = dtabuf.dirfile;
	  }
	  else					/* window icon	*/
	  {

	    for( ; curri < limit; curri++ )
	    {
	      if ( dir2[curri].d_state & SELECTED ) {
		break;
	      }
	    }
	    if (curri >= limit)
	      goto get_out;

	    dir1 = dir2[curri];

	    if (!x_win->w_iconified)
		    file = put_name( x_win, dir2[curri].d_name );
	    else
		    file = put_name( x_win, NULL); /* just get rid of '*.*' */

	    curri++;

	    if ( *file == 'c' )
	    {
	      do1_alert( CARTNOSH );
#ifdef OUR_OPTIMIZER_WORKS
	      goto ss_1;
#else
	      goto get_out;
#endif
	    }
	  }

	  dir = &dir1;
	  len = strlen( file ) + 20;	/* file's name length	*/
	  newstr = malloc( (LONG)len );
	  oldstr = malloc( (LONG)len );

	  if ( ( !newstr ) || ( !oldstr ) )
	  {
	    if (newstr)
	    {
	      free( newstr );
	      newstr = 0;
	    }
	    do1_alert( FCNOMEM );
	    goto get_out;
	  }

	  strcpy( file, oldstr );

	  if ( ( x_type == DESKICON ) && ( subtype == XDIR ) )
	  {
	    *r_slash( oldstr ) = 0;
	    if ( m_sfirst( oldstr, 0x31 ) )
	    {
	      fill_string( oldstr, FNOTFIND );
	      which = FIOK;
	      goto ss_6;
	    }

	    *dir = dtabuf.dirfile;		
	  }

	  strcpy( oldstr, newstr );	  

	  if ( dir->d_att & SUBDIR )	/* directory file	*/
	  {		
	    strcat( wilds, newstr );	/* attach wild card	*/
/*	    i_status = FALSE;	*/	/* force it to do only one file */	

	    if ( dofiles( newstr, newstr, OP_COUNT, &ndir, &nfile, &nsize, TEXT, FALSE, -1 ) )
	    {
	      f_str( obj, FINFOLDS, ndir );
	      f_str( obj, FINFILES, nfile );
	      f_str( obj, FISIZE, nsize );
	    }
	    else {
	      goto get_out;
	    }
	
	    *r_slash( newstr ) = 0; 	
	    ((TEDINFO*)(obj[INFTITLE].ob_spec))->te_ptext = (LONG)
			get_fstring( FOLDINFO );
	  }
	  else
	  {
	    *(BYTE*)(((TEDINFO*)(obj[FINFOLDS].ob_spec))->te_ptext) = 0;
	    *(BYTE*)(((TEDINFO*)(obj[FINFILES].ob_spec))->te_ptext) = 0;
	    f_str( obj, FISIZE, dir->d_size );
	    ((TEDINFO*)(obj[INFTITLE].ob_spec))->te_ptext = (LONG)
			get_fstring( FILEINFO );
	  }

	  fmt_time( dir->d_time, buffer );	/* put in time	*/
	  inf_sset( (LONG)obj, FITIME, buffer );
	  fmt_date( dir->d_date, buffer );
	  inf_sset( (LONG)obj, FIDATE, buffer );

	  savestr = (BYTE *) ((TEDINFO*)(obj[FIFILE].ob_spec))->te_ptext;
	  len = strlen( savestr );
sf_1:
	  if ( !( dir->d_att & SUBDIR ) )
	  {
	    obj[FIRONLY].ob_state = ( dir->d_att & READ ) ? SELECTED : NORMAL;
	    obj[FIRWRITE].ob_state = ( dir->d_att & READ ) ? NORMAL : SELECTED;
	  }
	  else
	  {
	    obj[FIRONLY].ob_state = DISABLED;
	    obj[FIRWRITE].ob_state = DISABLED;
	  }
					/* put in name	*/
	  xinf_sset( obj, FINAME, dir->d_name );
	  ((TEDINFO*)(obj[FIFILE].ob_spec))->te_ptext = (LONG) oldstr;
	  pos = 0;			/* text position	*/

	  dr_dial_w( ADFILEIN, FALSE, 0 /* dummy */ );
	  opened = TRUE;
ss_7:	  which = xform_do( obj, 0 );

	  if ( which == FIRIGHT )
	  {
            pos++;
	    if ( strlen( &oldstr[pos] ) < len )
	    {
	      pos--;
	      goto ss_7;
	    }
	    else
	      goto ss_8;
	  }
	  
	  if ( which == FILEFT )
	  {
	    if ( pos > 0 )
	    {
	      pos--;
ss_8:	      ((TEDINFO*)(obj[FIFILE].ob_spec))->te_ptext = (LONG) &oldstr[pos];
	      draw_fld( obj, FIFILE );
	    }

	    goto ss_7;	
	  }

	  ((TEDINFO*)(obj[FIFILE].ob_spec))->te_ptext = (LONG) savestr;
	  
	  if ( which == FIOK )		/* OK		*/
	  {
	    inf_sget( (LONG)obj, FINAME, buffer );
	    unfmt_str( buffer, newname );
	    rep_path( newname, newstr );
						/* name changed ?	*/
	    if ( !strcmp( dir->d_name, newname ) )
	    {					/* Yes			*/
	      if ( Frename( 0, oldstr, newstr ) )
	      {
	        if ( do1_alert( RENAME ) == 1 )	/* Retry	*/
	          goto sf_1;
	      }
	      else
	      {
	        upfdesk( oldstr, newstr );	/* check background file */
	        changed = TRUE;
	        dr[*oldstr - 'A'] = 1;
	      }
	    }

	    if ( !( dir->d_att & SUBDIR ) )
	    {
	      if ( obj[FIRONLY].ob_state & SELECTED )
	      {
	        if ( dir->d_att & READ )
	          goto sf_2;

	        ret = dir->d_att |= READ;
	      }
	      else
	      {
	        if ( dir->d_att & READ )
	          ret = dir->d_att &= ~READ;
	        else
		  goto sf_2;		
              }

	      Fattrib( newstr, 1, ret );
	      dir->d_att = ret;
	      changed = TRUE;	
	      dr[*oldstr - 'A'] = 1;
	    }
sf_2: ;
	  }				/* OK is selected	*/

ss_6:
	  free( newstr );
	  free( oldstr );

	  if ( which == FICNCL )	/* stop */
	    break;
	}

get_out:
	if ( opened )
	  do_finish( ADFILEIN );

	if ( changed )			/* something has changed	*/
	{
	  if ( x_type == WINICON )
	    up_allwin( x_win->w_path, TRUE );
	  else
	  {
	    for ( ret = 0; ret < 32; ret++ )
	    {	  
	       if ( dr[ret] )
	       {
	         buffer[0] = ret + 'A';
	         up_allwin( buffer, FALSE );
               }
	    }
	  }

	  if ( back_update ) 
	    lp_collect();		/* garbage collection	*/
	}
}
	


/*	Show the info of a drive	*/

	WORD
sh_disk( buffer )
	BYTE		*buffer;
{
	REG OBJECT	*obj;
	LONG		ndir,nfile,nsize;	
	BYTE		newname[14];
	LONG		sizes[4];

	buffer[1] = 0;

	if ( buffer[0] == 'c' )
	{
	  do1_alert( CARTNOSH );
	  return( TRUE );
	}
	
	if ( !ch_drive( buffer[0] ) )
	  return( TRUE );

	obj = get_tree( ADDISKIN );
	inf_sset( (LONG)obj, DIDRIVE, buffer );
	buffer[1] = ':';
	ndir = nfile = nsize = 0;
	
/*	i_status = FALSE;	*/	/* force to do only one item	*/
	
	if ( dofiles( buffer, buffer, OP_COUNT, &ndir, &nfile, &nsize, TEXT, FALSE, -1 ) )
	{
	  f_str( obj, DINFOLDS, ndir );	
	  f_str( obj, DINFILES, nfile );	
	  f_str( obj, DIUSED, nsize ); 	
	  desk_mice( HOURGLASS );
	  Dfree( sizes, buffer[0] - 'A' + 1 );
	  sizes[1] = sizes[0] * sizes[2] * sizes[3];
	  f_str( obj, DIAVAIL, sizes[1] );
	  Fsetdta( &dtabuf );
	  if ( Fsfirst( buffer, VOLUME ) )
	    newname[0] = 0;		/* No volume label	*/
	  else
	    fmt_str( dtabuf.dirfile.d_name, newname );

	  inf_sset( (LONG)obj, DIVOLUME, newname );
	  desk_mice( ARROW );
	  if ( fmdodraw( ADDISKIN, 0 ) == DIQUIT )
	    return( FALSE );
	}

	return( TRUE );
}
	

/*	Close a path		*/

	VOID
close_path( win )
	REG WINDOW	*win;
{
	WORD	item;
	BYTE	buffer[14];

	item = 0; /* item was not initalized, changed for LC */

	save_mid( win->w_path, buffer );
	if ( cut_path( win->w_path ) )		/* close a folder	*/
	{
	  do_box( win, 0, FALSE, FALSE, FALSE );
	  if ( !( open_subdir( win, item, FALSE, TRUE, TRUE ) ) )
	    cat_path( buffer, win->w_path );	
	}
	else
	  close_window( win->w_id, TRUE );
}


/*	Close top window	*/

	VOID
close_top( )
{
	REG WINDOW	*win;

	if ( win = get_top() )
	{
	  do_box( win, win->w_icon, TRUE, FALSE, FALSE );
	  close_window( win->w_id, TRUE );	/* close it	*/
	}
}


/*	open an item	*/

	VOID
open_item( item, type, win )
	REG WORD	item;
	WORD		type;
	WINDOW		*win;
{
	BYTE		buffer[16];
 	REG IDTYPE	*itype;
	WORD		ret;

	switch( type )
	{
	  case DESKICON:
	    itype = &backid[item];

	    switch( itype->i_type )
	    {
	      case XFILE:	/* show or executable	*/
		if ( m_sfirst( itype->i_path, 0x31 ) )
		{
		  ret = fill_string( itype->i_path, XNFILE );
		  goto o_1;	/* file not found	*/
		}
		else
	          exec_file( backid[item].i_path, (WINDOW*)0, item, Nostr );

		break;
		
	      case XDIR:	/* open a folder	*/	
		if ( m_sfirst( itype->i_path, 0x31 ) )
		{
		  save_mid( itype->i_path, buffer );	
		  ret = fill_string( buffer, XNFILE );
o_1:
		  if ( ret == 1 )
		  {
		    background[item].ob_flags |= HIDETREE;
		    lp_collect();
		    do_redraw( 0, &full, 0 );
		  }
	
		  if ( ret == 2 )
		    locate_item( item, (BYTE *)&itype->i_path, 
				 ( itype->i_type == XFILE ) ? TRUE : FALSE );
		}
		else
		  open_disk( item, itype->i_path, TRUE );

		break;

	      case DISK:	/* open a disk		*/
		strcpy( wildext, buffer );
		buffer[0] = (BYTE)itype->i_cicon.monoblk.ib_char;
      		open_disk( item, buffer, TRUE );
	        break;

	      case TRASHCAN:	
	      case PRINTER:
		fill_string( itype->i_name, ( itype->i_type == PRINTER ) ? 
		PRINTINF : TRSINFO );
	        break;

	      default:
	        return;
	    }

	    background[item].ob_state = NORMAL;
	    do_redraw( 0, &full, item ); 
	    break;
	
	  case WINICON:
	    open_wfile( win, item, Nostr, (WINDOW*)0, 0 );
	    break;
	} 
}


#if 0
 /*	Open a file, it may be an executable file		*/

	VOID
open_file( win, item, tail )
	REG WINDOW	*win;	/* destination window */
	WORD		item;
	BYTE	*tail;
{
	WORD		i,dump,key;
	REG DIR		*dir;
	BYTE		buffer[14];

	if ( !win )		/* open from the desktop	*/
	  exec_file( backid[item].i_path, win, item, tail );
	else
	{  
	  dir = get_dir( win, item );

	  if ( dir->d_att & SUBDIR )	/* open folder	*/
	  {
	    graf_mkstate( &dump, &dump, &dump, &key );

	    if ( key == ALTER )
	    {
	      strcpy( win->w_path, path3 );
	      cat_path( dir->d_name, path3 );
	      open_disk( 0, path3, FALSE );
	    }
	    else
	    {
	      cat_path( dir->d_name, win->w_path );
	      do_box( win, item, FALSE, TRUE, FALSE );
	      if ( !( open_subdir( win, item, FALSE, TRUE, TRUE ) ) )
	        cut_path( win->w_path );
	    }
	  }
	  else				/* open exec file	*/
	  {				/* deselect the item	*/
/*	    get_dir( win, item )->d_state = NORMAL;
	    win->w_obj[item].ob_state = NORMAL;
*/
	    exec_file( put_name( win, dir->d_name ), win, item, tail );
/*	    winfo( win );	*/
	  }
	}
}
#endif



/*	Open a window file, it may be an executable file		*/

	VOID
open_wfile( win, item, tail, swin, sitem )
	REG WINDOW	*win;	/* destination window */
	WORD		item,sitem;
	WINDOW		*swin;
	BYTE		*tail;
{
	UWORD		i;
	WORD		dump,key;
	REG DIR		*dir;
	BYTE		*bptr,*addr;
	
	if (win->w_iconified) {		/* +++ HMK 6/2/93   */
		/* if icon in iconified window is selected, */
		/* then uniconify window...		    */
		uniconify_window(win->w_id, &win->w_normsizes);
		return;
	}

	dir = get_dir( win, item );

	if ( dir->d_att & SUBDIR )	/* open folder	*/
	{
	  graf_mkstate( &dump, &dump, &dump, &key );

	  if ( key == ALTER )
	  {
	    strcpy( win->w_path, path3 );
	    cat_path( dir->d_name, path3 );
	    open_disk( 0, path3, FALSE );
	  }
	  else
	  {
	    cat_path( dir->d_name, win->w_path );
	    do_box( win, item, FALSE, TRUE, FALSE );
	    if ( !( open_subdir( win, item, FALSE, TRUE, TRUE ) ) )
	      cut_path( win->w_path );
	  }
	}
	else				/* open exec file	*/
	{				/* deselect the item	*/
	  if (win->w_iconified)
		  bptr = put_name( win, NULL );	/* just get rid of '*.*' */
	  else	
		  bptr = put_name( win, dir->d_name );	
	  if ( win == swin )
	  {
 	    i = strlen( bptr ) + 1;	/* +1 for trailing 0 */
	    if ( addr = malloc( (LONG)i ) )
	      strcpy( bptr, addr );
	    else
	      return;

	    bptr = (BYTE*)0;
	  }
	  else
	    addr = bptr;
  
	  exec_file( addr, win, item, tail );

	  if ( ( addr ) && ( !bptr ) )
	    free( addr );
	}
}


/*	open a disk icon	*/

	WORD
open_disk( icon, path, init )
	WORD	icon;		/* icon number	*/
	BYTE	path[];
	WORD	init;
{
	WORD	handle;
	WINDOW	*win;

	if ( path[0] == 'c' )		/* cartridge	*/
	{
	  if ( !cart_init() )		/* error	*/
	  {
	    do1_alert( NOCART );
	    return( FALSE );
	  }
	}
	else
	{
	  if ( !ch_drive( path[0] ) )	/* drive exists?*/
	    return( FALSE );
	}

	if ( c_path_alloc( path ) )	/* check the path length	*/
	{	
	  if ( ( handle = create_window( ) ) == -1 )
	    do1_alert( STNOWIND );
	  else
 	  {
	    win = get_win( handle );
	    strcpy( path, win->w_path );
	  
	    if ( open_subdir( win, icon, TRUE, init, FALSE ) )
	      return( TRUE );
	    else
	      close_window( handle, FALSE );	/* delete the window	*/	
	  }
	}
	return( FALSE );
}



/*	Do a grow or shrink box on a disk icon	*/	

	VOID
do_box( win, item, desk, open, openfull )
	WINDOW	*win;
	WORD	item,desk,open; /* item number, desk icon, open/close */
	WORD	openfull;
{	
	GRECT	pc;
	GRECT	dc;
	OBJECT	*obj;
	
	obj = ( desk ) ? background : win->w_obj;

	rc_copy( (WORD *)(( openfull ) ? &full : &win->w_work),(WORD *) &dc );

	if ( ( obj[item].ob_flags & HIDETREE ) || ( !item ) )	
	{
	  if ( desk )
	    rc_center( &full, &pc );  	
	  else
	    rc_copy( (WORD *)&win->w_work, (WORD *)&pc );

	  pc.g_w = 0;
	  pc.g_h = 0;
	}
	else
	{
	  objc_offset( obj, item, &pc.g_x, &pc.g_y );
	  pc.g_w = gl_wbox;
	  pc.g_h = gl_hbox;
	}
	form_dial( ( open ) ? FMD_GROW : FMD_SHRINK, pc.g_x, pc.g_y, pc.g_w,
		pc.g_h, dc.g_x, dc.g_y, dc.g_w, dc.g_h );
}

/*	Does the drive exist?	*/

	WORD
drv_exist( id )
	WORD	id;
{
	REG LONG	map;
	WORD		handle,ret;
	
	ret = (WORD)Dgetdrv();	/* Get default drive */
	map = (LONG)Dsetdrv(ret);/* Set default drive in order to get the drive map */

/*	map = (LONG)Drvmap();	*/
	handle = id - 'A';
	map = map >> handle;
	return( ( map & 0x01 ) ? TRUE : FALSE );
}


/*	Check drive and put up alert	*/

	WORD
ch_drive( id )
	WORD	id;
{
	BYTE	buffer[4];

	if ( !drv_exist( id ) )
	{
	  buffer[0] = id;
	  buffer[1] = 0;
	  fill_string( buffer, NODRIVE );
	  return( FALSE );
	}

	return( TRUE );
}



/*	Update the desk file or desk dir on the background	*/
/*	If new is a NULL pointer then erase the icon if matches	*/

	VOID
upfdesk( s, new )
	BYTE		*s;
	REG BYTE	*new;
{
	REG OBJECT	*obj;
	REG APP		*app;
	REG WORD	i,type;
	WORD		install;
	BYTE		*ptr;
	BYTE		*addr;

	obj = background;

	for ( i = 1; i <= obj->ob_tail; i++ )
	{
	  if ( !( obj[i].ob_flags & HIDETREE ) )
	  {
	    type = backid[i].i_type;

	    if ( type == XDIR )
	    {
	      ptr = r_slash( backid[i].i_path );
	      *ptr = 0;			/* erase the wild card */
	      goto u_1;
	    }
	 
	    if ( type == XFILE )
	    {
u_1:	      if ( strcmp( s, backid[i].i_path ) )
	      {
		if ( new )		/* rename application	*/
		{
	          if ( type == XDIR )	/* append wild card	*/
		  {
		    if ( addr = malloc( (LONG)(strlen( new ) + 10 ) ) )
		    {
		      strcpy( new, addr );
	              strcat( wilds, addr );
	              lp_fill( addr, &backid[i].i_path );
		      free( addr );
		    }	
		  }
		  else			
	            lp_fill( new, &backid[i].i_path );
		}			/* erase icon		*/
	        else			
		{
		  obj[i].ob_flags |= HIDETREE;
		}

		back_update = TRUE;	/* set the flag		*/
	      }				/* find the match	*/
	    }				/* XFIlE		*/

	    if ( type == XDIR )		/* restore the wild card	*/
	      *ptr = '\\';
	  }
	}
					/* check the install application */
	app = app_xtype( s, &install ); 
	if ( !install )
	{
	  if ( strcmp( app->a_name, s ) )
	  {
	    if ( new )
	      lp_fill( new, &app->a_name );
	    else
	      app_free( app );
 
	    back_update = TRUE;
	  }
	}

	q_sea( s, new ); 
}


/*	Locate an item 	*/

	VOID
locate_item( item, path, file )
	WORD	item,file;
	BYTE	*path;
{
	WORD	button;
	BYTE	buffer[16];

l_1:
	strcpy( "C:\\*.*", path1 );
    	path1[0] = ( isdrive() & 0x04 ) ? 'C' : 'A';
    	strcpy( Nostr, buffer );
    	fsel_exinput( (LONG)path1,(LONG)buffer, &button, get_fstring( LITEM ) );

    	if ( button )
	{
	  if ( file )
	  {
	    if ( ( buffer[0] ) && ( path1[0] ) )
	      rep_path( buffer, path1 );
	    else
	      goto l_1;		      
	  }
  	  lp_fill( (BYTE *)path1, (BYTE **)path );
	  lp_collect();
	}
}

	WORD
winsmall( WINDOW *win, WORD x, WORD y )
{
	char *path;
	BYTE buffer[14];
	WORD temp, i;
	WORD isfolder;

	path = win->w_path;

/* if it's a top level window, we make a drive icon */
	if (ch_level(path) <= 1) {
	  i = make_icon( path[0], 0, DISK, get_fstring( DEVICE ) );
	  isfolder = 0;
	} else {
/* else we make a folder icon */
	  save_mid( path, buffer);
	  app_icon( buffer, FOLDER, &temp );
	  i = make_icon( 0, temp, XDIR, buffer );
	  isfolder = 1;
	}
	if (i == -1)
	{
		do1_alert( NOICON );
		return 0;
	}
	app_mtoi( x, y, &background[i].ob_x, &background[i].ob_y );
	if (isfolder) {
	  lp_fill( path, &backid[i].i_path );
	  if (!backid[i].i_path) {
		do1_alert( NOICON );
		return 0;
	  }
	}
	do_redraw( 0, &full, i );
	return 1;
}

