/*	DESKSEAR.C		1/3/90 - 1/16/90	D.Mui		*/

/************************************************************************/
/*	New Desktop for Atari ST/TT Computer				*/
/*	Atari Corp							*/
/*	Copyright 1989,1990 	All Rights Reserved			*/
/************************************************************************/

#include "portab.h"	
#include "obdefs.h"
#include "deskdefi.h"
#include "osbind.h"
#include "deskwin.h"
#include "deskusa.h"
#include "error.h"
#include "extern.h"
#include "pdesk.h"
#include "pmisc.h"

EXTERN 	WORD	f_level;	/* local level counter same as deskdir	*/
EXTERN	WORD	f_rename;	/* window opened?			*/
EXTERN	WINDOW	*x_win;
EXTERN	WORD	x_type;
EXTERN	WORD	x_status;

/*	Position an item within a window	*/

	VOID
pos_item( win, newi )
	REG WINDOW	*win;
	WORD		newi;
{
	REG WORD	i,j,k;
	LONG		l;

	/******   adjust the vertical bar   ******/	

	j = newi / win->w_icol;

	i = win->w_items / win->w_icol;	/* maximum number of row	*/
	if ( win->w_items % win->w_icol )
	  i++;	

	if ( j >= win->w_xrow )
	  j = j - win->w_xrow + 1;
	else
	  j = 0;

	win->w_rowi = j;

	win->w_srtitem = j * win->w_icol; /* was w_srtitems, changed for LC */
	      	
	if ( i > win->w_xrow )
	{
	  l = 1000L * (LONG)j;
	  l = l / (LONG)( i - win->w_xrow );
	}
	else
	  l = 1000L;

	win->w_obj->ob_y = win->w_work.g_y;
	wind_set( win->w_id, WF_VSLIDE, (UWORD)l, 0, 0, 0 );

	/*******  adjust the horizontal bar  ********/

	win->w_obj->ob_x = win->w_work.g_x;
	win->w_obj->ob_width = win->w_work.g_w;

	i = ( newi % win->w_icol ) + 1;		/* column index		*/
	if ( i > win->w_xcol )			/* bigger than one frame*/ 
	  j = i - win->w_xcol;		/* move left		*/
	else
	  j = 0;
	    
	win->w_coli = j;		/* column index		*/	
		
	k = j * fobj.g_w;			/* move the object if necessary */
	win->w_obj->ob_x -= k;
	win->w_obj->ob_width += k;

	if ( win->w_hvicons )
	{
	  l = 1000L * (LONG)j;
	  l = l / (LONG)win->w_hvicons;
	}
	else
	  l = 1000L;

	wind_set( win->w_id, WF_HSLIDE, (UWORD)l, 0, 0, 0 );	  	
	up_2( win );
}



/*	Search a file	*/

	VOID
sea_file( filename )
	BYTE		*filename;
{
	REG WINDOW	*win;
	REG DIR		*dir;	
	REG WORD	i;	
	BYTE		*str;
	WORD		status,type,change,newi;
	BYTE		buffer[16];

	strcpy( filename, buffer );
	mass_string( filename );

	change = FALSE;
	
	if ( status = x_first( &str, &type ) )
	{
	  f_level = 0;
	  f_rename = FALSE;

	  while( status )
	  {
	    if ( ( type == DISK ) || ( type == SUBDIR ) || ( type == XDIR ) )
	    {
	      if ( *str == 'c' )
		do1_alert( NOSEA );
	      else
	      {			
	        set_dir( str );		/* set the current directory	*/
	        if ( rec_sea( filename ) )
	          goto s_ex1;
	      }
	    }
	    status = x_next( &str, &type );	
	  }

	  if ( f_rename )	/* if there is a window opened, then the */
	  {			/* search must be succeed		 */
	    do1_alert( NOMORE );
	    goto s_ex1;
	  }
	}			
	else
	{
	  if ( win = w_gfirst() )
	  {
	    if ( win->w_path[0] == 'c' )
	    {
	      do1_alert( NOSEA );
	      goto s_ex2;
	    }
	
	    dir = (DIR *) win->w_memory;
	    for ( i = 0; i < win->w_items; i++ )
	    {
	      if ( wildcmp( filename, dir[i].d_name ) )
	      {
		dir[i].d_state = SELECTED;
		if ( !change )
		  newi = i;

		change = TRUE;
	      }
	    }

	    if ( change )
	    {
	      if (win->w_iconified) {
		GRECT pc;		/* open iconified window */
		
		wind_get(win->w_id, WF_UNICONIFY, /* get old size */
			&pc.g_x, &pc.g_y, &pc.g_w, &pc.g_h);
		uniconify_window(win->w_id, &pc);
	      }

	      pos_item( win, newi );
	      goto s_ex2;
	    }		
	  }/* if window */
	}/* else	*/

	fill_string( buffer, FNOTFIND );
	goto s_ex3;
	
s_ex1:				/* if not select from top window */
	if ( ( x_type == WINICON ) && ( x_status ) )
	  clr_xwin( x_win, TRUE );
s_ex2:	  
	clr_dicons();

s_ex3:
	;
}


/*	Recursive search of a file	*/

	WORD
rec_sea( filename )
	REG BYTE	*filename;
{
	DTA		*dtabuf;	
	DTA		*savedta;
	REG WORD	status,ret;
	
	if ( !( dtabuf = (DTA *) malloc( (LONG)sizeof(DTA) ) ) )
	{
	  do1_alert( FCNOMEM );
	  return( TRUE );
	}

	savedta = (DTA *) Fgetdta();	/* save the dta buffer	*/
	Fsetdta( dtabuf );		/* set the new dta	*/

	status = FALSE;			/* not found		*/

/*	desk_mice( HOURGLASS );	*/
					/* look for matching	*/
	ret = Fsfirst( filename, 0x31 );

	while( !ret )
	{				/* matched		*/
	  if ( wildcmp( filename, dtabuf->dirfile.d_name ) )
	  {
	    if ( display( filename ) )
	    {
	      if ( do1_alert( SNEXT ) == 1 )
		 goto s_more; 
	    }

	    status = TRUE;
	    goto s_exit;
	  }
		
          ret = Fsnext();
	}

					/* Look for folder	*/
s_more:	
/*	desk_mice( HOURGLASS );	*/

	Fsetdta( dtabuf );		/* set the new dta	*/
	ret = Fsfirst( getall, 0x31 );
			
	while( !ret )
	{
	  if ( ( dtabuf->dirfile.d_att & SUBDIR ) && 
	       ( dtabuf->dirfile.d_name[0] != '.' ) )
	  {
	      path2[0] = '.';
	      path2[1] = '\\';
	      strcpy( dtabuf->dirfile.d_name, &path2[2] );
	      Dsetpath( path2 );
	      f_level++;
	      if ( f_level > COPYMAXDEPTH )
	      {
		do1_alert( STFO8DEE );
		status = TRUE;
	        break;
	      }

	      status = rec_sea( filename );
	      f_level--;
		
	      if ( !status )		/* if not found then back up one path */
	        Dsetpath( ".." );
	      else		
	        break;			/* quit	*/

	    }/* if SUBDIR	*/

	    ret = Fsnext();
	}/* while		*/

s_exit:	
	free( dtabuf );
	Fsetdta( savedta );
	return( status );		
}


/*	Display a window and highlight the items	*/

	WORD
display( filename )
	BYTE	*filename;
{
#if 0	/* NOT USED: */
	LONG		size;
#endif
	REG BYTE	*addr;
	REG WINDOW	*win;
	REG DIR		*dir;
	REG WORD	i;
	WORD		newi,ret,first;

	addr = malloc( 4096L );
	if ( addr )
	{
	  Dgetpath( addr, 0 );
	  i = strlen( addr ) + 20;
	  free( addr );		/* free the memory		*/
	  addr = malloc( (LONG)i );
	  addr[0] = Dgetdrv() + 'A';	/* get the default drive	*/
	  addr[1] = ':';
	  Dgetpath( &addr[2], 0 );	    
	  strcat( bckslsh, addr );
	  strcat( getall, addr );

	  if ( f_rename )
	  {
	     if ( c_path_alloc( addr ) )
	     {
	       win = w_gfirst();
	       strcpy( addr, win->w_path );
	       free( addr );
	       first = TRUE;
	
	       if ( open_subdir( win, 0, FALSE, FALSE, FALSE ) )
	       {
	    	 dir = (DIR *) win->w_memory;
	    	 for ( i = 0; i < win->w_items; i++ )
	    	 {	
		   if ( wildcmp( filename, dir[i].d_name ) )
		   {
		     if ( first )
		     {
		       newi = i;
		       first = FALSE;	
		     }
		     dir[i].d_state = SELECTED;
		   }
	         }
	       }/* open subdir */
	       else
		 return( FALSE );
	     }
	     else
	     {
	       free( addr );
	       return( FALSE );
	     }
	  }
	  else
	  {
	    f_rename = TRUE;
	    if ( win = alloc_win() )	/* check for window */
	    {
/*	      win->w_sizes.x = full.x;
	      win->w_sizes.y = full.y;
	      win->w_sizes.w = full.w;
	      win->w_sizes.h = full.h / 3;
	      rc_copy( &win->w_sizes, &win->w_work );
*/
	      ret_win( win );		/* return window 	*/
	      ret = open_disk( 0, addr, FALSE );
	    }
	    else
	      ret = FALSE;	

	    free( addr );

	    if ( !ret )
	      return( FALSE );

	    win = w_gfirst();
	    dir = (DIR *) win->w_memory;
	    first = TRUE;

	    for ( i = 0; i < win->w_items; i++ )
	    {	
	      if ( wildcmp( filename, dir[i].d_name ) )
	      {
		if ( first )
		{
		  newi = i;
		  first = FALSE;
		}
		dir[i].d_state = SELECTED;
	      }
	    }
	    wait_msg( -1, (OBJECT *) 0L );
	  }
	  pos_item( win, newi );
	  return( TRUE );
	    
	}/* No memory	*/
	
	return( FALSE );
}


/*	Put in wild card in the name string	*/

	VOID
mass_string( str1 )
	BYTE	*str1;
{
	REG WORD	i;
	BYTE		buffer[6];

	i = 0;	
	
	while( *str1 )
	{
	  if ( *str1 == '.' )
	  {
	    if ( i < 8 )
	    {
	      *str1++ = '*';
	      strcpy( str1, buffer );
	    }
	    else
	      strcpy( str1 + 1, buffer );

	    i = strlen( buffer );
	    if ( i < 3 )
	      buffer[i++] = '*';
	  
	    buffer[i] = 0;
	    *str1++ = '.'; 
	    strcpy( buffer, str1 );
	    return;
	  }	
	  else
	    i++;
		
	  str1++;
	}
	
	strcpy( getall, str1 );	/*  *.*	*/
}	
