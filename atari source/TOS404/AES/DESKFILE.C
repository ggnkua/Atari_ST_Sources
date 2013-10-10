/*	DESKFILE.C		3/17/89 - 6/15/89	Derek Mui	*/
/*	Change read_file	9/14/89			D.Mui		*/
/*	Change the way it gets icon	9/15/89		D.Mui		*/
/*	Fix at sort by date		6/28/90		D.Mui		*/
/*	Fix at read_file to allow lower case 7/18/90	D.Mui		*/
/*	Fix at read_file for calculating volume value	4/29/91	D.Mui	*/
/*	Fix at read_file for calculating volume again	8/13/91	D.Mui	*/
/*	Change all the iconblk to ciconblk	7/11/92	D.Mui		*/

/************************************************************************/
/*	New Desktop for Atari ST/TT Computer				*/
/*	Atari Corp							*/
/*	Copyright 1989,1990 	All Rights Reserved			*/
/************************************************************************/

#include <portab.h>
#include <mobdefs.h>
#include <defines.h>
#include <osbind.h>
#include <window.h>
#include <gemdefs.h>
#include <deskusa.h>
#include <error.h>
#include <extern.h>

EXTERN	BYTE	*get_fstring();
EXTERN	APP	*app_icon();
EXTERN	BYTE	*r_slash();
EXTERN	BYTE	*scasb();
EXTERN	OBJECT	*get_tree();
EXTERN	WINDOW	*w_gfirst();
EXTERN	BYTE	*bldstring();
EXTERN	BYTE	*strcpy();

#define CTLC 	3

	WORD
pri_str( where, ptr )
	WORD	where;
	BYTE	*ptr;
{
	LONG	c;
	WORD	ch;

	while( *ptr )
	{
pr_1:	  if ( !Bconout( where, *ptr++ ) )/* device not present ?	*/
	  {
	    if ( do_alert( 2, NOOUTPUT ) == 1 )
	      goto pr_1;
	    else
	      return( FALSE );	
	  }

	  if ( Bconstat( 2 ) ) 
	  {
	    ch = (WORD)(c = Bconin(2));
    	    if ( ch == CTLC || ch == 'q' || ch == 'Q' || 
	       ( c & 0x00ff0000L ) == 0x00610000 ) 
	      return( FALSE );
	  }
	}
	return( TRUE ); 
} 


/*	Print a window directory	*/

pri_win( )
{
	REG WINDOW	*win;
	REG WORD	serial;
	WORD		max,i,type;
	DIR		*dir;
	BYTE		buffer[80];
	BYTE		buf1[10];
	LONG		sizes;

	if ( win = w_gfirst() )
	{
	  desk_wait( TRUE );

	  serial = ( trp14( 0x21, 0xFFFF ) & 0x10 ) ? TRUE : FALSE; 	
	  dir = win->w_memory;
	  max = win->w_items;
	  sizes = 0;

	  if ( !pri_str( serial, Nextline ) )
	    goto pri_end;

	  if ( !pri_str( serial, win->w_path ) )
	    goto pri_end;

	  if ( !pri_str( serial, "\012\012\015" ) )
	    goto pri_end;
	  
	  for( i = 0; i < max; i++ )
	  {
	    sizes += dir[i].d_size;
	    strcpy( Nextline, bldstring( &dir[i], buffer ) );
	    if ( !pri_str( serial, buffer ) )
	      goto pri_end;
	  }

	  *( (LONG *) &buf1[0] ) = sizes;
	  *( (WORD *) &buf1[4] ) = (WORD)win->w_items;

	 merge_str( strcpy( Nextline, buffer ) - 1, get_fstring( ( win->w_items == 1 ) ? ISTR : ISTRS ),
		     buf1 );

	  strcat( "\014", buffer );	  
	  pri_str( serial, buffer );
pri_end:
	  desk_wait( FALSE );
	}
}


/*	Create a new folder on the top window	*/

newfolder( win )
	REG	WINDOW	*win;
{
	BYTE		namenew[14];
	BYTE		nameold[14];
	BYTE		name[14];
	WORD		i,ret,update;
	REG OBJECT	*obj;
	BYTE		buf[2];

	if ( win->w_path[0] == 'c' )
	{
	  do_alert( 1, STBADCOP );
	  return;
	}

	if ( !c_path_alloc( win->w_path ) )
	  return;

	strcpy( win->w_path, win->w_buf );
	obj = get_tree( ADMKDBOX );

	while( TRUE )
	{
	  update = FALSE;
	  name[0] = 0;
	  inf_sset( obj, MKNAME, name );
	  fm_draw( ADMKDBOX );		/* draw the box		*/
	  if ( xform_do( obj, 0 ) == MKCNCL )
	    break;

	  inf_sget( obj, MKNAME, name );
	  unfmt_str( name, namenew );
 	  if ( !namenew[0] )		/* no name	*/
	    break;

	  rep_path( namenew, win->w_buf );	/* append the name	*/

	  ret = m_sfirst( win->w_buf, 0x10 );
	
	  if ( ret )			/* Error 	*/
	  {
	    if ( ret == EFILNF )	/* File Not found*/
	      goto n_1;

	    if ( ret == EACCDN )	/* access denied*/
	    {
	      buf[0] = win->w_buf[0];
	      buf[1] = 0;
	      fill_string( buf, STDISKFULL );
	    }
	
	    break;
	  }
	  else			/* file exists	*/
	  {	
	    if ( do1_alert( STFOEXIST ) == 2 )
	      break;
	    else	
	      continue;		/* retry	*/
	  } 
n_1:
	  desk_wait( TRUE );

n_2:	  if ( Dcreate( win->w_buf ) )
	  {
	    if ( fill_string( win->w_buf, CNTCRTDR ) == 2 )
	      goto n_2;
	  }
	  else
	    update = TRUE;

	  desk_wait( FALSE );

	  break;
	}			/* while	*/

	do_finish( ADMKDBOX );

	if ( update )
	  up_allwin( win->w_path, TRUE );
}



/*	Sort the files		*/

sort_file( win, mode )
	WINDOW		*win;
	WORD		mode;
{
	REG DIR		*dir;
	REG WORD	n;
	REG WORD	gap,i,j,ret;
	    DIR		buff;
	REG DIR		*dir2;
	REG DIR		*dir1;
	BYTE		*ps1,*ps2;
	
	dir = win->w_memory;
	n = win->w_items;

	for( gap = n/2; gap > 0; gap /=2 )
	{
	  for( i = gap; i < n; i++ )
	  {
	    for( j = i - gap; j >= 0; j -= gap )
	    {
	      if ( mode == S_NO )
		goto ss_1;
		
	      if ( ( dir[j+gap].d_att & SUBDIR ) && ( dir[j].d_att & SUBDIR ) )
		goto ss_1;
	
	      if ( dir[j+gap].d_att & SUBDIR )
		goto ss_2;
	
	      if ( dir[j].d_att & SUBDIR )
		break;
ss_1:
	      dir1 = &dir[j];	      
	      dir2 = &dir[j+gap];
	      ps1 = &dir[j].d_name[0];
	      ps2 = &dir[j+gap].d_name[0];

	      switch ( mode )
	      {
		case S_NO:
		  if ( dir1->d_order > dir2->d_order )
		    ret = 1;
		  else
		    ret = -1;
		
		  break;

	  	case S_SIZE:
	    	  if ( dir2->d_size > dir1->d_size )
		    ret = 1;
		  else
	    	  if ( dir2->d_size < dir1->d_size )
		    ret = -1;
		  else
		    ret = strchk( ps1, ps2 );
		 
		  break;

          	case S_TYPE:
	    	  if ( ret = strchk( scasb( ps1, '.' ), scasb( ps2, '.' ) ) )
		    break;

		case S_NAME:
	    	  ret = strchk( ps1, ps2 );
		  break;

	  	case S_DATE:
		  ret = 0;
	    	  if ( dir2->d_date > dir1->d_date )
		    ret = 1;

	    	  if ( dir2->d_date < dir1->d_date )
		    ret = -1;

	          if ( !ret )
		  {
	            if ( ( dir2->d_time >> 5 ) > ( dir1->d_time >> 5 ) )
		      ret = 1;
		  }
	      }/* switch	*/ 	

	      if ( ret <= 0 )
	        break;
		
ss_2:	      buff = dir[j];
	      dir[j] = dir[j+gap];
	      dir[j+gap] = buff;		      	      	 
	    }
	  }
	}
}


/*	Set up all the files pointer 	*/
/*	Scroll up or down		*/

	WORD
set_newview( index, win )
	WORD	index;
	REG WINDOW	*win;
{
	REG 	WORD	i,k,items,vicons;
	 	DIR	*dir;
	REG 	OBJECT	*obj;
		OBJECT	*obj1;
		WORD	len,type;
		BYTE	*text;

	obj = win->w_obj;	/* get all the icons source	*/
	obj->ob_next = 0xFFFF;
				/* No objects			*/
	if ( !( items = win->w_items ) )
	{
	  obj->ob_head = 0xFFFF;
	  obj->ob_tail = 0xFFFF;
	  return;		 
	}
	else
	{
	  obj->ob_head = 1;	
	  obj->ob_tail = 1;
	}

	obj++;		/* points to the rigth object	*/

	dir = win->w_memory;

	vicons = win->w_vicons + 1;

	obj1 = get_tree( TEXTLINES );
	len = strlen( ( (TEDINFO*)(obj1[TSTYLE].ob_spec) )->te_ptext );
	text = win->w_text;

	for( k = 1, i = index; ( ( i < items ) && ( k < vicons ) ); 
	     i++, k++, obj++ )
	{
	  if ( s_view == S_ICON )
	  {
	    app_icon( &dir[i].d_name[0], ( dir[i].d_att & 0x10 ) ? FOLDER : -1, &type );
	    cp_iblk( type, (CICONBLK*)(obj->ob_spec) );
    	    ((CICONBLK*)(obj->ob_spec))->monoblk.ib_char[1] = 0;		
	    ((CICONBLK*)(obj->ob_spec))->monoblk.ib_ptext = &dir[i].d_name[0];
	  }
	  else
	  {
	    bldstring( &dir[i], text );
	    text += len;
	    *(text - 1) = 0;
	  }
	  
	  obj->ob_flags &= ~HIDETREE;
	  obj->ob_states = dir[i].d_state;
	  obj->ob_next = k+1;

	}/* for loop	*/

	obj--;			/* go back to last one		*/
	obj->ob_next = 0;	/* points back to parent	*/

	win->w_obj->ob_tail = k-1;	/* set up the parents	*/

	win->w_srtitem = index;

	obj++;			/* finish up the rest 	*/

	for( ; k < vicons; k++, obj++ )
	  obj->ob_flags |= HIDETREE;
}


/*	Read the files into a window	*/

	WORD
read_files( win, attr )
	REG WINDOW	*win;
	WORD	attr;
{
	REG LONG	items,volume,sizes;
	REG DIR		*addr;
	BYTE		buffer[14];
	BYTE		*path;
	WORD		ret,i;
	
	items = 0;
	sizes = 0;

	Fsetdta( &dtabuf );		/* set dta buffer	*/
	
	/*	Check to see if the drive is OK		*/
	/*	Look for all subdir file		*/

	path = win->w_path;

	save_ext( path, buffer );

	i = 0;
	while( buffer[i] )
	{
	  buffer[i] = toupper( buffer[i] );
	  i++;
	}

	rep_path( getall, path );	/* search everything	*/
	
	if ( path[0] == 'c' )
	  ret = !cart_sfirst( &dtabuf );
	else
	  ret = Fsfirst( path, 0x31 );	/* Error 	*/

	if ( ret )
	{
	  if ( ret != EFILNF )		/* Fatal error	*/
	  {
	    rep_path( buffer, path );
	    return( FALSE );
	  }
	}

	if ( win->w_memory )		/* Memory allocated?	*/
	{
	  Mfree( win->w_memory );	/* Free it		*/
	  win->w_memory = (BYTE*)0;
	}

	if ( ret == EFILNF )		/* file not found	*/
	  goto r_2;

	addr = Malloc( 0xFFFFFFFFL );	/* we should have memory*/

	if ( !addr )			/* No memory		*/
	{
	  do1_alert( FCNOMEM );
	  goto r_1;
	}
					/* How many files we can store*/

	volume = ((LONG) addr) / (LONG)(sizeof( DIR ));

	addr = Malloc( addr );

	win->w_memory = (BYTE*)addr;

	if ( !volume )
	  goto r_2;
	  
	do
	{				/* volume label		*/
	  if ( dtabuf.dirfile.d_att & VOLUME )
	    goto r_3;
					/* directory file	*/
	  if ( dtabuf.dirfile.d_att & 0x10 )
	  {
	    if ( dtabuf.dirfile.d_name[0] == '.' )
	    {
	      if ( ( dtabuf.dirfile.d_name[1] == '.' ) || 
		   ( !dtabuf.dirfile.d_name[1] ) ) 		
		goto r_3;
	    } 	
	  }
	  else
	  {				/* file match ?		*/
	     if ( !wildcmp( buffer, dtabuf.dirfile.d_name ) )
	       goto r_3;
	  }

	  if ( items <= volume )
	  {
	    dtabuf.dirfile.d_order = items;
	    dtabuf.dirfile.d_state = NORMAL;
	    *addr++ = dtabuf.dirfile;	  
	    sizes += dtabuf.dirfile.d_size;
	    items++;
	  }
	  else
	    break;

r_3:
	  if ( path[0] == 'c' )
	    ret = !cart_snext();  
	  else
	    ret = Fsnext();
	 
	}while( !ret );

r_2:
	rep_path( buffer, path );

	/* Free up some memory		*/

	if ( items )
	  Mshrink( win->w_memory, (LONG)( (BYTE*)addr - (BYTE*)win->w_memory ) );
	else
	{
	  Mfree( win->w_memory );
	  win->w_memory = (BYTE*)0;
	}

r_1:
	win->w_items = (UWORD)items;	/* total number of files	*/
	sort_file( win, s_sort );
	return( TRUE );
}
