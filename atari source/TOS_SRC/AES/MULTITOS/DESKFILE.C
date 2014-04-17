/*	DESKFILE.C		3/17/89 - 6/15/89	Derek Mui	*/
/*	Change read_file	9/14/89			D.Mui		*/
/*	Change the way it gets icon	9/15/89		D.Mui		*/
/*	Fix at sort by date		6/28/90		D.Mui		*/
/*	Fix at read_file to allow lower case 7/18/90	D.Mui		*/
/*	Fix at read_file for calculating volume value	4/29/91	D.Mui	*/
/*	Fix at read_file for calculating volume again	8/13/91	D.Mui	*/
/*	read_file: current directory for iconify added	6/01/93 H.Krober*/
/************************************************************************/
/*	New Desktop for Atari ST/TT Computer				*/
/*	Atari Corp							*/
/*	Copyright 1989,1990 	All Rights Reserved			*/
/************************************************************************/

#include "portab.h"
#include "machine.h"
#include "obdefs.h"
#include "deskdefi.h"
#include "osbind.h"
#include "deskwin.h"
#include "deskusa.h"
#include "error.h"
#include "extern.h"
#include "pdesk.h"
#include "pmisc.h"

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

	VOID
pri_win( )
{
	REG WINDOW	*win;
	REG WORD	serial;
	WORD		max,i;
	DIR		*dir;
	BYTE		buffer[80];
	BYTE		buf1[10];
	LONG		sizes;

	if ( win = w_gfirst() )
	{
	  desk_mice( HOURGLASS );

	  serial = ( trap14( 0x21, 0xFFFF ) & 0x10 ) ? TRUE : FALSE; 	
	  dir = (DIR *)win->w_memory;
	  max = win->w_items;
	  sizes = 0L;

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

	 merge_str( strcpy( Nextline, buffer ) - 1, 
		    get_fstring( ( win->w_items == 1 ) ? ISTR : ISTRS ),
		    (UWORD *)buf1 );

	  strcat( "\014", buffer );	  
	  pri_str( serial, buffer );
pri_end:
	  desk_mice( ARROW );
	}
}


/*	Create a new folder on the top window	*/

	VOID
newfolder( win )
	REG	WINDOW	*win;
{
	BYTE		namenew[14];
	BYTE		name[14];
	WORD		ret,update;
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
	  inf_sset( (LONG)obj, MKNAME, name );
	  dr_dial_w( ADMKDBOX, FALSE, 0 );		/* draw the box		*/
	  if ( xform_do( obj, 0 ) == MKCNCL )
	    break;

	  inf_sget( (LONG)obj, MKNAME, name );
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
	      fill_string( buf, STDISKFU );
	    }
	
	    break;
	  }
	  else			/* file exists	*/
	  {	
	    if ( do1_alert( STFOEXIS ) == 2 )
	      break;
	    else	
	      continue;		/* retry	*/
	  } 
n_1:
	  desk_mice( HOURGLASS );

n_2:	  if ( Dcreate( win->w_buf ) )
	  {
	    if ( fill_string( win->w_buf, CNTCRTDR ) == 2 )
	      goto n_2;
	  }
	  else
	    update = TRUE;

	  desk_mice( ARROW );

	  break;
	}			/* while	*/

	do_finish( ADMKDBOX );

	if ( update )
	  up_allwin( win->w_path, TRUE );
}



/*	Sort the files		*/

	VOID
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
	
	dir = (DIR *)win->w_memory;
	n = win->w_items;

	for( gap = n/2; gap > 0; gap /=2 )
	{
	  for( i = gap; i < n; i++ )
	  {
	    for( j = i - gap; j >= 0; j -= gap )
	    {
#ifdef OUR_OPTIMIZER_WORKS
	      dir1 = &dir[j];	      
	      dir2 = &dir[j+gap];
	      ps1 = &dir[j].d_name[0];
	      ps2 = &dir[j+gap].d_name[0];
#else

/* thanks lattice -- your optimizer is broken, and you're also entirely
 * too clever about the "sizeof" operator
 * make sure SIZE_DIR_X is the same number as sizeof(DIR), but without
 * using "sizeof"
 */
#define SIZE_DIR_X 28
#if SIZE_DIR_X != sizeof(DIR)
# error optimizer kludge broken, please check definitions
#endif
	      dir1 = (void *)(((BYTE *)dir)+j*SIZE_DIR_X);	      
	      dir2 = (void *)(((BYTE *)dir1)+gap*SIZE_DIR_X);

	      ps1 = dir1->d_name;
	      ps2 = dir2->d_name;
#endif
	      if ( mode == S_NO )
		goto ss_1;
		
	      if ( ( dir2->d_att & SUBDIR ) && ( dir1->d_att & SUBDIR ) )
		goto ss_1;
	
	      if ( dir2->d_att & SUBDIR )
		goto ss_2;
	
	      if ( dir1->d_att & SUBDIR )
		break;
ss_1:
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
		
ss_2:
#ifdef OUR_OPTIMIZER_WORKS
	      buff = dir[j];
	      dir[j] = dir[j+gap];
	      dir[j+gap] = buff;
#else
	      buff = *dir1;
	      *dir1 = *dir2;
	      *dir2 = buff;
#endif
	    }
	  }
	}
}


/*	Set up all the files pointer 	*/
/*	Scroll up or down		*/

	VOID
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
		WORD	temp;

	if (win->w_iconified) {		/* get the right object 		*/
		obj = win->w_icnobj;	/* simple for iconified windows, just	*/
		obj[1].ob_state = win->w_icndir.d_state; /* one object		*/
		return;
	}
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

	dir = (DIR *) win->w_memory;
	vicons = win->w_vicons + 1;

	obj1 = get_tree( TEXTLINE );
	len = strlen( (BYTE *)( (TEDINFO*)(obj1[TSTYLE].ob_spec) )->te_ptext );
	text = win->w_text;

	for( k = 1, i = index; ( ( i < items ) && ( k < vicons ) ); 
	     i++, k++, obj++ )
	{
	  if ( (s_view == S_ICON) )
	  {
	    app_icon( &dir[i].d_name[0], ( dir[i].d_att & 0x10 ) ? FOLDER : -1, &type );
	    cp_iblk( type, (CICONBLK*)(obj->ob_spec) );
	    temp = ((CICONBLK*)(obj->ob_spec))->monoblk.ib_char & 0xFF00;
    	    ((CICONBLK*)(obj->ob_spec))->monoblk.ib_char = temp | 0;		
	    ((CICONBLK*)(obj->ob_spec))->monoblk.ib_ptext = (LONG)&dir[i].d_name[0];
	  }
	  else
	  {
	    bldstring( &dir[i], text );
	    text += len;
	    *(text - 1) = 0;
	  }
	  
	  obj->ob_flags &= ~HIDETREE;
	  obj->ob_state = dir[i].d_state;
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
	
	items = 0L;
	sizes = 0L;

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
	  ret = !cart_sfirst( (BYTE *)&dtabuf, 0 /* dummy */ );
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

	addr = (DIR *)(Malloc( 0xFFFFFFFFL )); /* we should have memory*/

	if ( !addr )			/* No memory		*/
	{
	  do1_alert( FCNOMEM );
	  goto r_1;
	}

					/* How many files we can store*/
	volume = ((LONG) addr) / (LONG)(sizeof( DIR ));

	if ( !( addr = (DIR *)(Malloc( (LONG)addr ) ) ) )
	  goto r_1;

	win->w_memory = (BYTE*)addr;

	if ( !volume )
	  goto r_2;

	do
	{				/* volume label		*/
	  if ( dtabuf.dirfile.d_att & VOLUME ) {
	    goto r_3;
	  }
					/* directory file	*/
	  if ( dtabuf.dirfile.d_att & 0x10 )
	  {
	    if ( dtabuf.dirfile.d_name[0] == '.' )
	    {
	      if ( dtabuf.dirfile.d_name[1] == '.' )
			goto r_3;
	      else if ( !dtabuf.dirfile.d_name[1] ) {	/* current direcotry 		*/
	      	dtabuf.dirfile.d_order = 1;		/* +++ HMK 2/6/93		*/
	    	dtabuf.dirfile.d_state = NORMAL;	/* for iconified window stuff	*/
 		getlastpath(dtabuf.dirfile.d_name, win->w_path);
		if (dtabuf.dirfile.d_name[0] == '\0')	/* root direcotry		*/
			strcpy("\\", dtabuf.dirfile.d_name); 
	       	win->w_icndir = dtabuf.dirfile;		/* store for iconifying purpose */
		goto r_3; 
	      }
	    }
	  }
	  else
	  {				/* file match ?		*/
	     if ( !wildcmp( buffer, dtabuf.dirfile.d_name ) )
	       goto r_3;
	  }

	  if ( items <= volume )
	  {
	    dtabuf.dirfile.d_order = (WORD)items;
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

	if ((win->w_path[2] == '\\') && (win->w_path[3] == '*')) {	/* +++ HMK 6/2/93 */
								/* for window iconifying  */
		strcpy("\\", win->w_icndir.d_name); 			/* root directory */ 
		win->w_icndir.d_att = 0x10;				/* directoty      */
	}
	return( TRUE );
}
