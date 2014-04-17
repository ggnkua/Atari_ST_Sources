/*	DESKSELE.C		10/9/89			Derek Mui	*/
/*	Change all the iconblk to ciconblk	7/11/92	D.Mui		*/
/*	Support for iconified windows added	6/01/93 h.M.Krober	*.
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

WORD	x_status;		/* for x_select			*/
WORD	x_index;		/* For x_next and x_first	*/
WORD	x_type;			/* ditto			*/
WINDOW	*x_win;			/* diito			*/	
WORD	x_cur;			/* x_del			*/

WORD	d_dir;			/* count how many folders are selected	*/
				/* inside the window			*/

EXTERN	WORD	o_type;
EXTERN	WORD	o_item;
EXTERN	WORD	o_status;
EXTERN	WINDOW	*o_win;

EXTERN	DIR	*get_dir();


/*	Turn off the current selected object	*/

	VOID
x_deselect( )
{
	DIR	*dir;

	if ( x_type == WINICON )
	{
	  if (x_win->w_iconified) /* get the right dir */
		x_win->w_icndir.d_state = NORMAL;
	  else {
		  dir = (DIR *) x_win->w_memory;
		  dir[x_cur].d_state = NORMAL;
	  }
	}
	else
	  background[x_cur].ob_state = NORMAL;
}


/*	My own object find	*/

	WORD
m_objfind( obj, mx, my, mode )
	REG OBJECT	*obj;
	REG WORD	mx,my;
	WORD		mode;	/* TRUE == window mode	*/
{
	REG		i,limit;
	WORD		status,offx,offy;
	WORD		x1,y1;
	CICONBLK	*iblk;
	GRECT		pt;

	status = -1;

	offx = obj[0].ob_x;
	offy = obj[0].ob_y;
	limit = obj[0].ob_tail;	

	for ( i = 1; i <= limit; i++ )
	{
	   if ( obj[i].ob_flags & HIDETREE )
	     continue;

	   if ( obj[i].ob_type == G_CICON )	/* icon ?	*/
	   {
	     x1 = obj[i].ob_x + offx;
	     y1 = obj[i].ob_y + offy;	     

	     iblk = (CICONBLK*)(obj[i].ob_spec);
	     rc_copy( &iblk->monoblk.ib_xicon, (WORD *)&pt );
	     pt.g_x += x1;
	     pt.g_y += y1;
 
	     if ( !inside( mx, my, &pt ) )
	     {
	        rc_copy( &iblk->monoblk.ib_xtext, (WORD *)&pt );
	        pt.g_x += x1;
	        pt.g_y += y1;
	        if ( inside( mx, my, &pt ) )
		  status = i;
	     }
	     else
	       status = i;	
	   }
	   else					/* text mode	*/
	   {
	     rc_copy( &obj[i].ob_x, (WORD *)&pt );
	     pt.g_x += offx;
	     pt.g_y += offy;
	     if ( inside( mx, my, &pt ) )
	       status = i;	
	   }
	
	   if ( ( status != -1 ) && ( mode ) )
	     break;

	}/* for */

	if ( status == -1 )	/* if fails then try the root	*/
	{
	  if ( inside( mx, my, (GRECT *)&obj[0].ob_x ) )
	    status = 0;	
	}

	return( status );
}


/*	Find out which object is selected based on the object structures */
/*	Type can only be DESKICON or WINICON				*/

	WORD
o_select( )
{
	REG WINDOW	*win;
	REG OBJECT	*obj;
	REG WORD	i,j;

	o_type = WINICON;		/* Try the window	*/
	
	win = w_gfirst();	
	
	while( win )
	{
	  if (win->w_iconified)	/* get the right object */
		obj = win->w_icnobj;
	  else
		obj = win->w_obj;
	  j = obj->ob_tail;

	  for ( i = 1; i <= j; i++ )
	  {
	    if ( ( obj[i].ob_state & SELECTED ) && ( obj[i].ob_flags != HIDETREE ) )
	    {
	      if ( in_parent( obj, i ) )	/* in side parent's box?*/
	      {
	        o_item = i;
	        o_win = win;
	        o_status = TRUE;
	        return( o_status = TRUE );
	      }
	    }
	  }

	  win = w_gnext();
	}

	o_type = DESKICON;		/* Now try desktop */
	o_win = (WINDOW*)0;	
	return( o_status = i_next( 1, background, &o_item ) );
}


/*	Find out if anything is selected		*/

	WORD
x_select( )
{
	REG WINDOW	*win;
	REG DIR		*dir;
	REG WORD	i;
	WORD		j;
	WORD		items;

	x_win = (WINDOW*)0;
	x_type = DESKICON;

	win = w_gfirst();

	while( win )
	{
	  if (win->w_iconified) { /* get the right dir */
		dir = &win->w_icndir;
		items = 1;	 /* just one */
	  } else {
		  dir = (DIR *)win->w_memory;
		  items = win->w_items;
	  }
	  for ( i = 0; i < items; i++ )
	  {
	    if ( dir[i].d_state & SELECTED )
	    {
	      x_win = win;
	      x_type = WINICON;
	      return( x_status = TRUE );	
	    }
	  }
	  win = w_gnext();
	}

	return( x_status = i_next( 1, background, &j ) );
}


/*	Extended dir structure search next	*/

	WORD
x_next( name, type )
	BYTE	**name;
	WORD	*type;
{
	REG DIR		*dir;
	REG WORD	i;
	WORD	limit;
	BYTE	*str;

	if ( x_type == WINICON )
	{
	  if (x_win->w_iconified) { /* get the right dir */
		dir = &x_win->w_icndir;
		limit = 1;	    /* just one */
	  } else {
		  dir = (DIR *) x_win->w_memory;
		  limit = x_win->w_items;
	  }
	  for ( i = x_index; i < limit; i++ )
	  {
	    if ( dir[i].d_state & SELECTED )
	    {
	      if (x_win->w_iconified) {
		      str = put_name( x_win, NULL ); /* get rid of '*.*' */
	      } else {
		      str = put_name( x_win, &dir[i].d_name[0] );
	      }
	      if ( dir[i].d_att & SUBDIR )
	      {
	        strcat( wilds, str );	
	        d_dir++;
	        *type = SUBDIR;
	      }
	      else
	        *type = x_type;

	      *name = str;
	      x_cur = i;
	      x_index = i + 1; 
	      return( TRUE );
	    }
	  }
	  return( FALSE );
	}
	else
	  return( d_sdesk( name, type ) );
}

/*	Object oriented search first				*/
/*	Returns icon type, WINICON, XFILE, DISK, SUBDIR		*/
/*	Extended dir search first				*/
	
	WORD	
x_first( name, type )
	BYTE	**name;
	WORD	*type;
{
	REG WINDOW	*win;
	REG WORD	i,j;
	DIR	*dir;

	d_dir = 0;

	x_type = DESKICON;		/* try desktop first	*/
	x_win = (WINDOW*)0;

	if ( i_next( 1, background, &x_index ) )
	  return( x_next( name, type ) );
		
	win = w_gfirst();

	while( win )			/* inside a window?	*/
	{
	  if (win->w_iconified) {	/* get right dir */
		dir = &win->w_icndir;
		j = 1;			/* just one */
	  } else {
		  dir = (DIR *) win->w_memory;
		  j = win->w_items;
	  }
	  for ( i = 0; i < j; i++ )
	  {
	    if ( dir[i].d_state & SELECTED )
	    {
	      x_index = i;
	      x_type = WINICON;
	      x_win = win;
	      return( x_next( name, type ) );
	    }
	  }

	  win = w_gnext();
	}

	return( FALSE );
}	


/*	Find out what the user has clicked on based on the mx and my	*/

	WORD
i_find( mx, my, winout, item, type )
	REG WORD	mx,my;
	WINDOW		**winout;
	WORD		*item;
	WORD		*type;
{
	REG WINDOW	*win;
	REG WORD	which;
	REG WORD	handle;		/* ++ERS 1/11/93 */
	WORD		icon, dummy;
 
	win = w_gfirst();

	while( win )		
	{				/* inside a window boundary	*/
#if 0
	  if ( !(win->w_iconified) && inside( mx, my, &win->w_sizes ) )
#else	  /* now working inside iconified windows, too: */
	  if (inside( mx, my, &win->w_sizes))
#endif
	  {				
	    *winout = win;
	    *type = WINICON;
	    *item = 0;
	    				/* inside the work area		*/
	    if ( inside( mx, my, &win->w_work ) )
	    {
		OBJECT	*obj;

		if (win->w_iconified)	/* get right object */ 
			obj = win->w_icnobj;
		else
			obj = win->w_obj; 
	      if ( ( which = m_objfind(obj, mx, my, TRUE ) ) != -1 )
	     		*item = which;
	    }

#if 1
/* Now check to make sure some other application's window isn't covering ours */
/* check added 1/11/93 ++ERS */
	    handle = wind_find(mx, my);
	    if (handle && handle != win->w_id)
	    {
	      *item = 0;
	      return( FALSE );		/* not the same window, must be another
					   application's */
	    }
#endif
	    return( TRUE );
	  }

	  win = w_gnext();
	}

					/* try desktop		*/
	if ( ( which = m_objfind( background, mx, my, FALSE ) ) != -1 )
	{
	  handle = wind_find(mx, my);
	  if (handle)		/* some other window is there */
	    return( FALSE );

	  *item = which;
	  *type = DESKICON;
	  *winout = (WINDOW*)0;
	  return( TRUE );	
	}

	return( FALSE );
}


/*	Search for next selected OBJECT		*/

	WORD
i_next( start, obj, itemout )
	WORD	start;
	REG OBJECT	*obj;
	WORD	*itemout;
{
	REG WORD	limit,i;

	limit = obj->ob_tail;
	
	for ( i = start; i <= limit; i++ )
	{
	  if ( (!( obj[i].ob_flags & HIDETREE )) && ( obj[i].ob_state & SELECTED ) )
	  {
	    *itemout = i;
	    return( TRUE );
	  }	
	}

	return( FALSE );
}

/*	Search the selected desktop object	*/ 
/*	Used by x_next only			*/

	WORD
d_sdesk( name, type )
	BYTE	**name;
	WORD	*type;
{
	WORD		temp;
	REG IDTYPE	*itype;	
	
	while( i_next( x_index, background, &x_index ) )
	{
	  itype = &backid[x_index];
	  temp = itype->i_type;

	  if ( temp == DISK )
	  {
	    strcpy( wildext, path1 );
      	    path1[0] = (BYTE)itype->i_cicon.monoblk.ib_char;
	    *name = path1;
	    *type = temp;
	    goto xd_1;
	  }
	  else
	  if ( itype->i_path )
	  {
	    *name = itype->i_path;
	    *type = temp;
	    if ( temp == XDIR )
	      d_dir++;
	
xd_1:	    x_cur = x_index++;
	    return( TRUE );
	  }
	  else
	    x_index++;
	}

	return( FALSE );	
}
