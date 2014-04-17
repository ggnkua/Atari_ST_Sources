/* deskact.c
 * ======================================================================
 * New Desktop for Atari ST/TT computers.
 * ½ 1989-93 Atari Corporation
 * ======================================================================
 * 930610	hmkrober	srollable r_box implemented
 * 930601	hmkrober	support for iconified windows added
 * 930209	towns		started conversion to LC5
 * 921214	esmith		Add new drag and drop code.
 * 920711	dmui		change all the iconblk to ciconblk
 * 920303	dmui		gh_init allocates 10K of buffer
 * 910418	dmui		fix at file_op to do update for all affected
 *						windows. Also did fix at file_op to check for
 *						destination drive.
 * 910417	dmui		fix hd_down for mouse is moving too fast.
 * 910219	dmui		Add bit_par to handle multiple parameters
 * 900708	dmui		Modified hd_down
 * 900703	dmui		fix hd_down, it needs to update menu.
 * 890628	dmui		take out vdi_handle from VDI calls.
 * 890531	dmui		file created.
 */	

/* Include files */
#include "portab.h"
#include "machine.h"
#include "obdefs.h"
#include "deskdefi.h"
#include "deskwin.h"
#include "deskusa.h"
#include "osbind.h"
#include "extern.h"
#include "message.h"
#include "mintbind.h"

#include "pdesk.h"			/* Prototypes */
#include "pmisc.h"

/* -- External global variables -- */
EXTERN	WORD	desk_id;
EXTERN	WORD	d_display;
EXTERN	WORD	f_rename;
EXTERN	WINDOW	*o_win;

EXTERN	WORD	d_dir;
EXTERN	WINDOW	*x_win;
EXTERN	WORD	x_type;
EXTERN	WORD	win_wchar;
EXTERN	WORD	win_xoff;
EXTERN	WORD	win_yoff;

WORD	back_update;					/* update background	*/
BYTE	scapath[] = "?:\\CLIPBRD\\";	/* default clip board path */
BYTE	DESKCOPY[] = "DESKCOPY=";

/*	Special version of "strlen" which also counts any extra length	*/
/*	that will be needed for quoting special characters		*/
WORD
qstrlen( BYTE *s )
{
	WORD len = 0;
	WORD numquotes = 0;
	WORD numspaces = 0;
	BYTE c;

	if (*s == '\'')
		numspaces = 1;	/* force quoting */

	while ((c = *s++) != 0) {
		if (c == ' ')
			numspaces++;
		else if (c == '\'')
			numquotes++;
		len++;
	}
	if (numspaces) {
		len += 2 + numquotes;
	}
	return len;
}

BYTE *
qstrcpy( BYTE *src, BYTE *dest )
{
	BYTE *t, c;
	WORD needquotes = 0;

	if (*src == '\'')
		needquotes = 1;
	else {
		for (t = src; *t; t++)
			if (*t == ' ') needquotes = 1;
	}
	if (needquotes) {
		*dest++ = '\'';
	}
	while ((c = *src++) != 0) {
		if (needquotes && c == '\'')
			*dest++ = c;
		*dest++ = c;
	}
	if (needquotes)
		*dest++ = '\'';
	*dest++ = 0;
	return dest;
}

/*	Build an command tail. File name will be build as C:\XXXX		*/
/*	Directory will be built as C:\BIN\ If the style is 1, then there is	*/
/*	empty byte at the head of the buffer, otherwise the parameters at the	*/
/*	head. Otherwise, the parameters start from the very first byte.		*/

BYTE	
*bld_par( WORD full, WORD style )
{
	REG BYTE	*addr;
	BYTE		*str, *ret;
	WORD		status, type;
	UWORD		len;

	ret = (BYTE*)0;
	
	if ( status = x_first( &str, &type ) )
	{
		len = style ? 1 : 0;		/* Number of byte to increase	*/
		while( status )
		{
			len += qstrlen( str ) + 1;	/* string and space */
			status = x_next( &str, &type );
		}
		
		if ( addr = ret = malloc( (LONG)(len + 2) ) )
		{
			if ( style )
			{
				addr[0] = (BYTE) 0xFF;
				addr++;
			}
			
			status = x_first( &str, &type );

			while( status )
			{
				if ( (type == DISK) || (type == XDIR) || (type == FOLDER) ||
					( type == SUBDIR ) )
					*(r_slash( str ) + 1) = 0;
				else 
					if ( !full )		/* file name only	*/
						str = g_name( str );	

				addr = qstrcpy( str, addr ) - 1;
				*addr++ = ' ';
				status = x_next( &str, &type );
			}
			addr--;
			*addr = 0;
		}	 
	}
	
	if (ret) {
		Debug1( "The bld_par is " );
		Debug1( ret );
		Debug1( "\r\n" );
	}
	return( ret );
}


#if 0
/*	Build an input parameter block		*/

BYTE	
*blt_argvs( BYTE *file, WORD full )
{
	REG BYTE	*addr;
	BYTE		*str, *ret;
	WORD		status, type;
	UWORD		len;

	ret = (BYTE*)0;

	len = strlen( file ) + 1;	

	if ( status = x_first( &str, &type ) )
	{
		while( status )
		{
			len += strlen( str ) + 1;	/* add the 0 */
			status = x_next( &str, &type );
		}
					/* ARGV=\0	*/
		addr = ret = malloc( (LONG)(len + 7) );

		if ( addr )
		{
			addr = strcpy( "ARGV=", addr );
			addr = strcpy( file, addr );	
			status = x_first( &str, &type );

			while( status )
			{
				if ( !full )		/* file name only	*/
					str = g_name( str );	
				addr = strcpy( str, addr );
				status = x_next( &str, &type );
			}
			*addr = 0;
		}	 
	}
	return( ret );
}
#endif



/*	Check what kind of object is executable	*/
/*	Return TRUE if it is 			*/

WORD
ch_obj( WORD mx, WORD my, WINDOW **win, WORD *item, WORD *type )
{
	REG WORD	i;
	DIR			*dir;
	WORD		install;
	APP			*app;
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
			} else {

				if ((*win)->w_iconified)	/* +++ HMK 5/28/83 */
					i = 1;			/* just one object */


				dir = get_dir( *win, i );
				if ( dir->d_att & SUBDIR )	/* dir is OK	*/
					return( TRUE );		     

				if ((*win)->w_iconified)	/* get path */
					str = put_name( *win, NULL );
				else
					str = put_name( *win, dir->d_name );
						/* check file type	*/
ch_1:			app = app_xtype( str, &install );

				if ( !install )
				{ 
					switch ( app->a_type )		/* executable is OK	*/
					{
						case TOS:
						case TTP:
						case PRG:
						case PTP:
						case APPS: return( TRUE );
					}
				}  
			}/* window object	*/
		}/* if object		*/
	}/* if found something	*/
	return( FALSE );
}

/*	Change for UNDO key	*/

WORD
ch_undo( void )
{
	/* If there is an UNDO key and the user wants to abort, return FALSE */
	if ((Bconstat(2)) && (Bconin(2)==0x00610000L) && (do1_alert(ABORTCON)==1))
		return( FALSE );

	/* Otherwise, return TRUE */
	return( TRUE ); 
}


/*	Perform a file operation	*/

VOID
file_op( BYTE *dest, WORD mode )
{
	REG OBJECT	*obj;
	REG WORD	ret;
	UWORD		len;
	WORD		type,item,i,handle;
	WORD		keydown;
	LONG		ndir,nfile,nsize;
	BYTE		*source;
	BYTE		buffer[2];
	GRECT		pt;
	BYTE		*which,*tail,*bptr,*addr;
	BYTE		tailbuf[30];

	/* get the key state */
	graf_mkstate( &item, &item, &item, &keydown );
	
	f_rename = ( keydown & ALTER ) ? TRUE : FALSE;

	if ( !x_first( &source, &type ) )
		return;

	if (source[3] == '\0') {		/* +++ HMK 6/2/93 */
		rep_path( getall, source ); 	/* if root dir, then append '*.*' */		
	}					/* needed for iconified window	  */

	if ( mode != OP_DELETE )
		if ( !ch_drive( *dest ) )	return;	

	d_display = TRUE;
	back_update = FALSE;
	buffer[1] = 0;

	obj = get_tree( CPBOX );
	obj[CDDRIVE].ob_flags &= ~HIDETREE;
	obj[DATEBOX].ob_flags &= ~HIDETREE;

	bfill( 30, ' ', tailbuf );
	bptr = &tailbuf[1];
	*bptr++ = '-';
	
	switch( mode )
	{
		case OP_DELETE:	*bptr++ = 'd';
						which = get_fstring( DELSTR );
						obj[CDDRIVE].ob_flags |= HIDETREE;
						obj[DATEBOX].ob_flags |= HIDETREE;
						if( !cdele_save )
							d_display = FALSE;	
						break;
		case OP_COPY:	*bptr++ = 'c';	
						if ( ! ( keydown & K_CTRL ) )	/* control key down? */
						{
							if ( f_rename )
							{ 
								bptr++;	
								*bptr++ = '-';
								*bptr++ = 'R';
							}
							which = get_fstring( ( f_rename ) ? CRENSTR : CPYSTR );
							if ( !ccopy_save )
								d_display = FALSE;
							break;
 						}
		case OP_MOVE:	*bptr++ = 'm';
						mode = OP_MOVE;
						if ( f_rename )
						{ 
							bptr++;		
							*bptr++ = '-';
							*bptr++ = 'R';
						}
						which = get_fstring( ( f_rename ) ? MRENSTR : MOVESTR );
						if ( ( !ccopy_save ) && ( !cdele_save ) )
							d_display = FALSE;
						break;
	} /* End of switch statement */

	/* Set the option parameters  */
	bptr++;
	*bptr++ = '-';
	*bptr++ = ( ccopy_save ) ? 'A' : 'B';
	
	bptr++;
	*bptr++ = '-';
	*bptr++ = ( cdele_save ) ? 'C' : 'D';
	
	bptr++;
	*bptr++ = '-';
	*bptr++ = ( write_save ) ? 'E' : 'F';
	
	bptr++;
	*bptr = 0;
	
	/* Search for program that want to do file operation	*/
	(VOID) shel_envrn( (LONG) &bptr, (LONG) DESKCOPY );
	
	/* build file names */
	if ( bptr )
	{			
		if ( tail = bld_par(1,1) )
		{
			len = strlen( &tailbuf[1] ) + strlen( &tail[1] ) + strlen( dest );	
			if ( addr = malloc((LONG)len + 2L) )
			{
				addr[0] = (BYTE) 0xFF;	
				strcpy( &tailbuf[1], &addr[1] );
				strcat( &tail[1], &addr[1] );
				strcat( " ", &addr[1] );
				strcat( dest, &addr[1] );			
				if ( !( ret = shel_write( 0, 0, 1, (LONG)bptr, (LONG)addr ) ) )
					fill_string( bptr, FTOLAUNC ); /* @LC5@ */
				free( addr );	
			} else	ret = FALSE;	

			free( tail );	
			if ( ret )	return;		/* OK */
		}/* No expanded tail */
	
	}/* Otherwise, do it the old way */
	build_rect( background, &pt, d_xywh[6], d_xywh[9] );
	
	if (!dofiles( source,dest,OP_COUNT, &ndir,&nfile,&nsize,type,TRUE,-1))
	{
	  do1_alert( STBADCOP );
	  return;
	}

	ndir += d_dir;		/* count also the number of dir in window */
	((TEDINFO*)(obj[TITLE].ob_spec))->te_ptext = (long)which;
	f_str( obj, NUMDIR, ndir );
	f_str( obj, NUMFILE, nfile );
	obj[HIDECBOX].ob_flags |= HIDETREE;
	inf_sset( (LONG)obj, CSDRIVE, Nostr );
	buffer[0] = *dest;
	inf_sset( (LONG)obj, CDDRIVE, buffer );

	if (d_display)
	  obj[CHBOX1].ob_flags &= ~HIDETREE;
	else
	  obj[CHBOX1].ob_flags |= HIDETREE;

	/* draw the box		*/

#ifdef WINDOWED_DIALOGS
  	handle = dr_dial_w( CPBOX, TRUE, MOVE|NAME|CLOSE );	
#else
 	handle = dr_dial_w( CPBOX, FALSE, 0);
#endif
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
		if (source[3] == '\0') {		/* +++ HMK 6/2/93 */
			rep_path( getall, source ); 	/* if root dir, then append '*.*' */		
		}					/* needed for iconified windows	  */
		ret = dofiles(source,dest,mode,&ndir,&nfile,&nsize,type,TRUE,handle );
	}

	obj[item].ob_state = NORMAL;
 	if (handle < 0)
 		do_finish( CPBOX );
 	else {
 		wind_close( handle );
 		wind_delete( handle );	/* ++ERS 1/08/93 */
 	}

	if ( ( item == OKCP ) && ( ret ) )
	{
		/* 32 below is the number of drives. */
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
				rc_copy( (WORD *)&full, (WORD *)&pt );
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
build_rect( REG OBJECT *obj, REG GRECT *rect, WORD w, WORD h )
{
	REG WORD	i;
	REG WORD	minx,miny;
	REG WORD	maxx,maxy;
	WORD		found;

	minx = full.g_x + full.g_w;
	miny = full.g_y + full.g_h;
	maxx = 0;
	maxy = 0;
	found = FALSE;

	for ( i = 1; i <= obj[0].ob_tail; i++ )
	{
		if ((obj[i].ob_state & SELECTED) && (in_parent(obj,i)))
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
		rect->g_x = minx + obj[0].ob_x;
		rect->g_y = miny + obj[0].ob_y;
		rect->g_w = maxx - minx + w;
		rect->g_h = maxy - miny + h;
	} else {
	  rect->g_x = 0;
	  rect->g_y = 0;
	  rect->g_w = 0;
	  rect->g_h = 0;
	}
	return( found );
}


/*	Check whose is inside the rect and select the object	*/
VOID
chk_rect( REG WINDOW *win, GRECT *rect, WORD id)
{
	REG OBJECT	*op, *obj;
 	REG WORD	i;
	REG WORD	minx,miny,maxx,maxy;
	WORD		/*limit,*/orgx,orgy,select;
	GRECT		pt;
	WORD		doit;
	WORD		tail;
	DIR		*dir;

	if ( win )
	{
		rc_intersect( &win->w_work, rect );
		doit = TRUE;
		if (win->w_iconified) {
			obj = win->w_icnobj;
		} else {
			obj = win->w_obj;
		}
	} else {
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

	tail = obj->ob_tail;

	for ( i = 1, op = &obj[i]; i <= tail; i++, op++ )
	{
		if ( !(op->ob_flags & HIDETREE) )
		{
			rc_copy( &op->ob_x, (WORD *)&pt );
			pt.g_x += orgx;
			pt.g_y += orgy;
			if ( rc_intersect( rect, &pt ) )
			{
				if ( minx > op->ob_x )
					minx = op->ob_x;
	 
				if ( miny > op->ob_y )
					miny = op->ob_y;

				if ( op->ob_x > maxx )
					maxx = op->ob_x;

				if ( op->ob_y > maxy )
					maxy = op->ob_y;

				op->ob_state ^= SELECTED;		 
				if ( doit )
				{
					dir = get_dir( win, i );
					dir->d_state ^= SELECTED;
				}
				select = TRUE;
			}
		}
	}


	if ( select )
	{
		pt.g_w = maxx - minx + obj[1].ob_width;
		pt.g_h = maxy - miny + obj[1].ob_height;
		pt.g_x = minx + obj[0].ob_x;
		pt.g_y = miny + obj[0].ob_y;
		do_redraw( id, &pt, 0 );
	}

}

/*
 *	Check rectangle for scrollable windows and select
 *	objects inside the rectangle.
 */

	VOID
chk_r2(win, id, mode, x, y)
	WINDOW	*win;
	WORD	id;
	WORD	x, y;
{
	MLOCAL	WORD	osrow, oscol;
	MLOCAL	WORD	ox, oy, ow, oh;
	MLOCAL	WORD	clip_x, clip_y;
	MLOCAL	WORD	top;
	LOCAL	WORD	srtitem, enditem;
	LOCAL	WORD	crow, ccol;
	LOCAL	WORD	srow, scol;
	MLOCAL	OBJECT	*obj;
	REG	WORD	i, j;
	LOCAL	WORD	index, oi, ncol, nrow;
	MLOCAL	WORD	limit;
	LOCAL	WORD	doit;
	REG	DIR	*dir;
	MLOCAL	DIR	*wdir;
	REG 	WORD	irow, jcol, acol;
	LOCAL	WORD	ii, jj;
	LOCAL	WORD	wx, wy, ww, wh;
	

	if (mode == 0) { 
		/* 
		 * INIT MODE 
		 */
		if (win->w_iconified) {
			obj = win->w_icnobj;
			limit = 1;
			wdir = &win->w_icndir;
		} else { 
			obj = win->w_obj;
			limit = win->w_items;
			wdir = (DIR *) win->w_memory;
		}
		wind_get(win->w_id, WF_TOP, &top, &ii, &ii, &ii);
		if (top == win->w_id)
			top = TRUE;
		else
			top = FALSE;

		ox = win->w_work.g_x; /* work area */
		oy = win->w_work.g_y;
		ow = obj[1].ob_width;
		oh = obj[1].ob_height;
		clip_x = ox + win->w_work.g_w;
		clip_y = oy + win->w_work.g_h;

		/* original start column and start row */		 
		oscol = win->w_coli + (x - ox) / (win_xoff + ow);
		osrow = win->w_rowi + (y - oy) / (win_yoff + oh);
	} else {	
		/*
		 * ACTION MODE
		 */

		/* total number of rows and columns in window */
		nrow = win->w_vvicons + win->w_xrow;
		ncol = win->w_hvicons + win->w_xcol;

		/* current column and current row */
		ccol = win->w_coli + (x - ox) / (win_xoff + ow);
		ccol = (ccol >= ncol) ? (ncol - 1) : ccol;
		crow = win->w_rowi + (y - oy) / (win_yoff + oh);

		srtitem = win->w_srtitem;
		enditem = srtitem + obj->ob_tail;

		/*
		 *	check direction
		 */
		if (osrow > crow) {
			srow = crow;
			crow = osrow;
			irow = nrow - 1;
			ii = -1;
		} else {
			srow = osrow;
			irow = 0;
			ii = 1;
		}
		if (oscol > ccol) {
			scol = ccol;
			ccol = oscol;
			acol = ncol - 1;
			jj = -1;
		} else {
			scol = oscol;
			acol = 0;
			jj = 1;
		}

		doit = FALSE;

		/*
		 *	now check all files (objects)
		 *	by row and column
		 */
		for (i = 0; i < nrow; i++, irow += ii) {
			for (j = 0, jcol = acol; j < ncol; j++, jcol += jj) {
				index = irow * ncol + jcol;
				if (index >= limit) {
					continue;
				}
				dir = &wdir[index]; /* get file */

				/*
				 *	is it inside the rectangle?
				 *
				 *	srow, scol
				 *        |
				 *	  +------------------+
				 *	  |                  |
				 *	  |                  |
				 *	  +------------------+
				 *                           |
				 *	               crow, ccol
		                 */
				if ((irow >= srow) && (irow <= crow) && 
				    (jcol >= scol) && (jcol <= ccol)) {
					/*
					 * Has it already been touched?
				         */
					if (!(dir->d_att & 0x1000) ) { 
						/* NO TOUCHED YET */
						dir->d_state ^= SELECTED;
						dir->d_att |= (0x1000);
						doit = TRUE;
					}
				} else { /* not inside rect */
					if ((dir->d_att & 0x1000)) {
						/* HAS BEEN TOUCHED */
					   	dir->d_state ^= SELECTED;
						dir->d_att &= (~0x1000);
						doit = TRUE;
					}
				}
				/*
				 *	Do we have to redraw the object?
				 */	 
				if (doit && ((index >= srtitem) && 
				   (index < enditem))) {
					oi = index - srtitem + 1; 
					obj[oi].ob_state = dir->d_state;
					doit = FALSE;
					objc_offset(obj, oi, &wx, &wy);
					if (!top)
					   draw_loop(id, obj, 0, MAX_DEPTH, wx, wy, 
					     obj[oi].ob_width, obj[oi].ob_height);
					else { /* little bit more speed... */
						desk_mice( M_OFF );
						ww = obj[oi].ob_width; 
						wh = obj[oi].ob_height;
						ww = ((wx + ww) > clip_x) ?
							clip_x - wx : ww;
						wh = ((wy + wh) > clip_y) ?
							clip_y - wy : wh;
						if ((ww > 0) && (wh > 0))
							objc_draw( (LONG)obj, 0, 
								MAX_DEPTH, 
								wx, wy, ww, wh);
						desk_mice( M_ON );
					}
				}	
			}
		}
	}
}


/*	Draw a box	*/

VOID
frame( WORD x1, WORD y1, WORD x2, WORD y2 )
{
	WORD	points[10];

	desk_mice( M_OFF );
	points[0] = points[6] = points[8] = x1;
	points[1] = points[3] = points[9] = y1;
	points[2] = points[4] = x2;
	points[5] = points[7] = y2;
	d_setattr( MD_XOR, BLACK );
	d_xlines( 5, points );
	desk_mice( M_ON );
}


/*	Draw a box and wait for button to go up				*/
/*	+++ 6/10/93 HMK If inside window, it's able to do scrolling now */
VOID
r_box( WORD id, WINDOW *win )
{
	REG WORD 	tmpx, tmpy;
	REG WORD	tmpx1, tmpy1;
	WORD 		gr_mkmx,gr_mkmy;
	WORD 		gr_mkmstate,gr_mkkstate;
	GRECT		rect;
	GRECT		srect;
	WORD		ww, wh, wx, wy, in_w;
	OBJECT		*obj;
	REG DIR		*dirp;	
	WORD		i, limit, noframe;

	graf_mkstate( &gr_mkmx, &gr_mkmy, &gr_mkmstate, &gr_mkkstate );
	if ( !( 0x0001 & gr_mkmstate ) )
	  return;	

	wind_update( 1 );	
	desk_mice( POINT_HAND|0x8000 );

	if (win) {	
		wx = win->w_work.g_x;	/* window work area */
		wy = win->w_work.g_y;
		ww = win->w_work.g_x + win->w_work.g_w;
		wh = win->w_work.g_y + win->w_work.g_h;
		if (win->w_iconified)
			obj = win->w_icnobj;
		else
			obj = win->w_obj;

		/* Mark all directories as NOT touched yet. */
		
		limit = (win->w_iconified) ? 1  : win->w_items;
		for (i = 0, dirp = (DIR *) win->w_memory; i < limit; i++)
			dirp++->d_att &= (~0x1000);  /* use free bit */  
	} else {
		obj = background;  /* desktop */
	}

	rect.g_x = full.g_x;
	rect.g_y = full.g_y;
	rect.g_w = full.g_x + full.g_w; 
	rect.g_h = full.g_y + full.g_h;

	vs_clip( 1, (WORD *) &rect );

	srect.g_x = gr_mkmx;
	srect.g_y = gr_mkmy;
	srect.g_w = 0;
	srect.g_h = 0;
	in_w = FALSE;		/* not touching the window borders */
	noframe = FALSE;	/* draw frame */

	while( TRUE )	
	{
		if ( 0x0001 & gr_mkmstate )	
		{
			tmpy = tmpy1 = gr_mkmy;
			tmpx = tmpx1 = gr_mkmx;
			if (id) 
				chk_r2(win, id, 0, tmpx1, tmpy1);

			frame( tmpx, tmpy, tmpx1, tmpy1 );

			while ( 0x0001 & gr_mkmstate )	
			{
					
				if ((tmpx1 != gr_mkmx) || (tmpy1 != gr_mkmy))
					noframe = FALSE;
				else
					noframe = TRUE; /* mouse stays still, no frame */
				
				if (!noframe || in_w)	
				{
					in_w = FALSE;
					frame( tmpx, tmpy, tmpx1, tmpy1 );

					if (id) {  /* only if window and NOT desk */
						srect.g_x = min( tmpx, gr_mkmx );
						srect.g_y = min( tmpy, gr_mkmy );

						srect.g_w = abs( tmpx, gr_mkmx );
						srect.g_h = abs( tmpy, gr_mkmy );	


						if (gr_mkmx < wx) { /* scroll */
						        srl_col( win, 1, SRIGHT);
							in_w = TRUE;
						} else if (gr_mkmx > ww) {
						        srl_col( win, 1, SLEFT);
							in_w = TRUE;
						}

						if (gr_mkmy < wy) { /* scroll */
						        srl_row( win, 1, SUP );
							in_w = TRUE;
						} else if (gr_mkmy > wh) {
						        srl_row( win, 1, SDOWN );
							in_w = TRUE;
						}

						if (in_w) { /* turn on proper clipping */
							vs_clip( 1, (WORD *) &rect );
						}
						if ((srect.g_w ) && (srect.g_h ) ) {
							/* check rectangle (window only) */
							chk_r2(win, id, 1, gr_mkmx, gr_mkmy);
						}
					} 
					
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

	if (!id) { /* do desktop rubber band stuff */
		rect.g_x = min( tmpx, tmpx1 );
		rect.g_y = min( tmpy, tmpy1 );

		rect.g_w = abs( tmpx, tmpx1 );
		rect.g_h = abs( tmpy, tmpy1 );	

		if ( ( rect.g_w ) && ( rect.g_h ) )
			chk_rect( win, &rect, id );
	} else {
r_1:
		limit = win->w_items;
		for (i = 0, dirp = (DIR *) win->w_memory; 
		     i < limit; i++)
			dirp++->d_att &= (~0x1000);  
	}

	desk_mice( ARROW );
	wind_update( 0 );
}


/*	Return an absolute value	*/

WORD
abs( WORD x, WORD y )
{
	if ( x > y )
		return( x - y );
	else
		return( y - x );
}


/*	Move icons from window to desktop	*/

VOID
win_desk( REG WINDOW *swin, WORD sitems, WORD ditem, WORD mx, WORD my )
{
/*	DIR			*dir; */
	REG OBJECT	*obj; 
	REG WORD	i;
	WORD		temp,first,type,status,ntype;
	WORD		x,y;
	BYTE		buffer[14];
	BYTE		*str;
	BYTE		*tail;
	BYTE		drive;

	drive = 0;
	if ( !ditem )
	{
		first = TRUE;
		status = x_first( &str, &type );

		while( status )
		{
			if ( type == SUBDIR )
			{
				ntype = XDIR;
				if (ch_level(str) <= 1) {	/* +++ HMK 6/2/93 */	
					buffer[0] = str[0];
					buffer[1] = ':';
					buffer[2] = '\\';	/* root directory */
					buffer[3] = '\0';
					drive = str[0];		/* type is DISK on the desktop!!! */
					ntype = DISK;	
				} else
					save_mid( str, buffer );			
			} else {
				ntype = XFILE;
				save_ext( str, buffer );		    	
			} 
			if (ntype != DISK)
				app_icon( buffer, ( type == SUBDIR ) ? FOLDER : -1, &temp );
			else
				temp = 0; /* Cabin Icon */
			
			if ( ( i = make_icon( drive, temp, ntype, buffer ) ) == -1 )
			{
				do1_alert( NOICON );
				break;
			}

			if ( first )
			{
				if (swin->w_iconified)		/* get the right object */
					obj = swin->w_icnobj;
				else
					obj = swin->w_obj;
				objc_offset( obj, sitems, &x, &y );
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
	} else {		/* drop on desktop object	*/
		if ( backid[ditem].i_type == XFILE )
		{
/*			dir = get_dir( swin, sitems );
			strcpy( swin->w_path, &swin->w_buf[1] );
			rep_path( dir->d_name, &swin->w_buf[1] );
			swin->w_buf[0] = strlen( &swin->w_buf[1] );
			tail = swin->w_buf;
*/
			tail = (BYTE*)0;	
		} else tail = Nostr;
		
		to_desk( ditem, tail );
	}
}


/*	Move icons from desktop to desktop	*/

VOID
desk_desk( WORD sitem, WORD ditem, WORD mx, WORD my )
{
	REG OBJECT	*obj;
	BYTE		buffer[14];
	REG BYTE	temp1;
	BYTE		temp2;
	GRECT		rect;
	WORD		/*x,y,*/sitems;
/*	BYTE		*ptr;	*/
	BYTE		*tail;

	obj = background;

	if ( !ditem )			/* on the background	*/
	{
		if ( ( mx ) || ( my ) ) 	/* moved		*/
		{
			sitems = 1;
			while ( i_next( sitems, obj, &sitems ) )
			{				/* copy x,y,w,h		*/
				rc_copy((WORD *)&dicon,(WORD *)&rect );	/* set x,y		*/
				rect.g_x = obj[0].ob_x + obj[sitems].ob_x;
				rect.g_y = obj[0].ob_y + obj[sitems].ob_y;
				app_mtoi( rect.g_x + mx, rect.g_y + my, &obj[sitems].ob_x, &obj[sitems].ob_y );
				do_redraw( 0, &rect, 0 ); 	/* erase old one	*/
				do_redraw( 0, &full, sitems );	/* draw the new one	*/
				sitems++;

			}/* while */
		}/* if moved */
	} else {/* if open area */
	
		/* check for floppy disk copy	*/
		temp1 = (BYTE)(((CICONBLK*)(obj[sitem].ob_spec))->monoblk
.ib_char & 0x00ff);
		temp2 = (BYTE)(((CICONBLK*)(obj[ditem].ob_spec))->monoblk.ib_char & 0x00ff);
	
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
/*					wind_update(1);	*/
					fc_start( buffer, CMD_COPY );
/*					wind_update(0);	*/
					return;
				}
		}

		if ( backid[ditem].i_type == XFILE )
		{
/*			if ( ch_tail( backid[sitem].i_path, path2 ) )	*/
				tail = (BYTE*)0;
/*			else
				return;
*/	      
		} else tail = Nostr;

		to_desk( ditem, tail );
	}
}


/*	Ghost icon initalization	*/

WORD
gh_init( REG OBJECT *obj, WORD disk )
{
	REG WORD	*ptr1;
	WORD		x,y,i,offx,offy;
	LONG		limit,j;
	WORD		count,lines;
	WORD		*ptr;
	OBJECT		*tree;

	if ( ! ( gh_buffer = (long)malloc( 0x7800L ) ) )
	  return( FALSE );
	
	j = 0x7800L / 40L;		/* 9 vertices x 2 x 2 	*/ 	
					/* + 1 ascushion	*/
	limit = (LONG)obj->ob_tail;

	if ( limit > j )
	  limit = j;

	offx = obj->ob_x;
	offy = obj->ob_y;

	ptr1 = (WORD *)gh_buffer;
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

	ptr1 = (WORD *)gh_buffer;
	*ptr1 = count;
	return( TRUE );
}


/*	Draw icons outline	*/ 

VOID
ghost_icon( REG WORD offx, REG WORD offy, WORD disk )
{
	REG WORD	*ptr;
	REG WORD	i,j,limit;
	WORD		lines;
	WORD		buffer[4];
	WORD		*start;

	desk_mice( M_OFF );

	rc_copy( (WORD *)&full, (WORD *)buffer );	/* set clipping rectangle	*/
	buffer[2] = buffer[0] + buffer[2];
	buffer[3] = buffer[1] + buffer[3];
	vs_clip( 1, buffer );	

	d_setattr( MD_XOR, BLACK );

	ptr = (WORD *)gh_buffer;
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

	   d_xlines( lines, start );
	}

	desk_mice( M_ON );
}


/*	Handle the holding down button event	*/


VOID
hd_down( REG WORD sitem, REG WORD stype, REG WINDOW *swin )
{
	REG WORD	pitem,state;
	WORD		itype,w,h,ret,exec;
	WORD		mx,my,kstate,mstate;
	WORD		omx,omy;
	WORD		ditem,dtype;
	WORD		ptype,pid,docopy;
	WORD		cx,cy,offx,offy,o1,o2;
	WORD		handle,temp,id;
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
	  if (!swin->w_iconified && (s_view != S_ICON) )
	  {
	    itype = FALSE;
	    w = f_xywh[2];
	    h = f_xywh[5];
	  } 
	
	  if (!swin->w_iconified)	/* get the right object */
		  sobj = swin->w_obj;
	  else
		sobj = swin->w_icnobj;	
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
	  goto h_2;
	}

	if ( !gh_init( sobj, itype ) )
	{
	  do1_alert( FCNOMEM );
	  goto h_2;
	}

	wind_update( 1 );

	desk_mice( FLAT_HAND|0x8000 );

	ghost_icon( 0, 0, itype );	/* draw icon			*/
					/* draw the biggest rectangle	*/
	build_rect( sobj, &pt, w, h ); 
	rc_copy( (WORD *)&pt, (WORD *)&pt2 );

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
	    o1 = pt.g_x;			/* save the old rectangle x,y	*/
	    o2 = pt.g_y;

	    pt.g_x = o1 + mx - omx;	/* update the new x.y	*/
	    pt.g_y = o2 + my - omy;

	    rc_constrain( &full, &pt );	/* check how far it can move	*/

	    offx = pt.g_x - o1;		/* movement distance	*/
	    offy = pt.g_y - o2;	

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
h_3:		  pt.g_x -= offx;
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
h_4:		  pt.g_y -= offy;   
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
		if (dwin->w_iconified)	/* +++ HMK 5/28/93 */
			pobj = dwin->w_icnobj;
		else
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

	free( (VOIDP) gh_buffer );

	desk_mice( ARROW );

	wind_update( 0 );

	if ( !ret )
 	  goto h_2;

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

	if ( handle = wind_find( mx, my ) )		/* find the window */
	{
	  if ( wind_get( handle, WF_OWNER, &id, &temp, &temp, &temp ) )	
	  {
	    if ( id != desk_id )
	    {	
	      d_dragdrop( id, handle, mx, my );
	      goto h_2;
	    }
	  }
	}


	if ( stype == WINICON )		/* source is window	*/
	{
	  if ( dtype == DESKICON )	/* Hit the desktop	*/
	  {
	    if ( ( !ditem ) || ( exec ) )
	      win_desk( swin, sitem, ditem, pt.g_x - pt2.g_x, pt.g_y - pt2.g_y );
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
	      desk_desk( sitem, ditem, pt.g_x - pt2.g_x, pt.g_y - pt2.g_y );
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

VOID
to_desk( WORD ditem, BYTE *tail )
{
	BYTE		buffer[14];
/*	WORD		ret; */
	REG IDTYPE	*itype;

	itype = &backid[ditem];

	switch( itype->i_type )
	{
	    case XDIR:
	      file_op( itype->i_path, OP_COPY );
	      break;
		
	    case DISK:			/* copy to disk		*/
	      strcpy( wildext, buffer );	
 	      buffer[0] = (BYTE)(itype->i_cicon.monoblk.ib_char & 0x00ff);
	      file_op( buffer, OP_COPY );
	      break;
	   
	    case TRASHCAN:
	      do_file( DELMENU );
	      break;
	      
	    case XFILE:
	      exec_file( backid[ditem].i_path, (WINDOW*)0, ditem, tail );
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

VOID
to_win( WORD sitem, WINDOW *swin, WORD ditem, WINDOW *dwin )
{
	REG DIR		*dir;
	REG BYTE	*temp;

	temp = ( swin == dwin ) ? path3 : dwin->w_buf;
	strcpy( dwin->w_path, temp );

	if ( ditem )			/* copy to something	*/
	{
	  dir = get_dir( dwin, ditem );
	  if ( dir->d_att & SUBDIR ) { 	/* win file to folder	*/
	    if (!dwin->w_iconified)
		    cat_path( dir->d_name, temp );
	  } else				/* launch application	*/
	  {
	    if ( swin )			/* window to window	*/
	    {
#if 0
	      if ( swin != dwin )
		temp = swin->w_buf;
	       	
	      dir = get_dir( swin, sitem );
	      strcpy( swin->w_path, &temp[1] );
	      rep_path( dir->d_name, &temp[1] );
	      temp[0] = strlen( &temp[1] );
	      temp = (BYTE*)0;
#endif
	      open_wfile( dwin, ditem, (BYTE *)0, swin, sitem );
	    }
	    else			/* desktop to window	*/
	    {
/*	      if ( ch_tail( backid[sitem].i_path, path2 ) )	*/
	        open_wfile( dwin, ditem, (BYTE *)0, swin, sitem );
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
make_icon( WORD drive, WORD icon, WORD type, BYTE *text )
{
	REG WORD	id;
	REG IDTYPE	*itype;
	OBJECT		*obj;
	WORD		temp;

	if ( ( id = av_icon() ) != -1 )
	{
	  itype = &backid[id];
	  obj = background; 
	  cp_iblk( icon, (CICONBLK*)(obj[id].ob_spec) );	       
          itype->i_type = type;
	  temp = (itype->i_cicon.monoblk.ib_char & 0xFF00);
	  itype->i_cicon.monoblk.ib_char = temp | drive;
	  itype->i_icon = icon;
	  strcpy( text, (BYTE *)((CICONBLK*)(obj[id].ob_spec))->monoblk.ib_ptext );
	}

	return( id );
}

#if 0
BYTE	sbuff[200];
#endif

/*
 * drag and drop code by ERS; implements a generic drag & drop
 * protocol using MiNT pipes
 */

#ifndef EACCDN
#define EACCDN -36
#endif

#ifndef SIGPIPE
#define SIGPIPE 13
#endif

#ifndef SIG_IGN
#define SIG_IGN 1L
#endif

#ifndef WF_OWNER
#define WF_OWNER 20
#endif

#define	DD_OK		0
#define DD_NAK		1
#define DD_EXT		2
#define DD_LEN		3
#define DD_TRASH	4
#define DD_PRINTER	5

/* timeout in milliseconds */
#define DD_TIMEOUT	2000

/* number of bytes of "preferred
 * extensions" sent by recipient during
 * open
 */
#define DD_NUMEXTS	8
#define DD_EXTSIZE	32

/* max size of a drag&drop item name */
#define DD_NAMEMAX	128

/* max length of a drag&drop header */
#define DD_HDRMAX	(8+DD_NAMEMAX)


static LONG oldpipesig;
static BYTE pipename[] = "U:\\PIPE\\DRAGDROP.AA";

/*	Drag and drop to another window	*/

WORD
d_dragdrop( WORD apid, WORD winid, WORD msx, WORD msy )
{
	WORD	handle,err;
	LONG	len;
	BYTE	*addr;
	BYTE	recexts[32];
	WORD	kstate, dummy;

/* get shift key state */
	graf_mkstate( &dummy,&dummy,&dummy,&kstate );
	kstate &= 0xff;
 
	addr = bld_par(1,0);
	if (!addr)
		return 0;		/* JTT - Added zero */

	len = strlen( addr );
	handle = ddcreate(apid, winid, msx, msy, kstate, recexts);
	if ( handle >= 0 )
	{
	  err = ddstry( handle, "ARGS", "DESKTOP args", len );
	  if ( err == DD_OK )
	  {
	    Fwrite( handle, len, addr );
	  }
	  ddclose( handle );
	} else {
	  do1_alert( NODROP );
	}
	free( addr );
}

/*
 * create a pipe for doing the drag & drop,
 * and send an AES message to the receipient
 * application telling it about the drag & drop
 * operation.
 *
 * Input Parameters:
 * apid:	AES id of the window owner
 * winid:	target window (0 for background)
 * msx, msy:	mouse X and Y position
 *		(or -1, -1 if a fake drag & drop)
 * kstate:	shift key state at time of event
 *
 * Output Parameters:
 * exts:	A 32 byte buffer into which the
 *		recipient's 8 favorite
 *		extensions will be copied.
 *
 * Returns:
 * A positive file descriptor (of the opened
 * drag & drop pipe) on success.
 * -1 if the recipient doesn't respond or
 *    returns DD_NAK
 * -2 if appl_write fails
 */

WORD
ddcreate( WORD apid, WORD winid, WORD msx, WORD msy, WORD kstate, char *exts )
{
	WORD fd, i;
	WORD msg[8];
	LONG fd_mask;
	BYTE c;

	pipename[17] = pipename[18] = 'A';
	fd = -1;
	do {
		pipename[18]++;
		if (pipename[18] > 'Z') {
			pipename[17]++;
			if (pipename[17] > 'Z')
				break;
		}
/* FA_HIDDEN means "get EOF if nobody has pipe open for reading" */
		fd = (WORD)Fcreate(pipename, 0x02);   /* JTT - added (WORD) */
	} while (fd == EACCDN);

	if (fd < 0) {
		return fd;
	}

/* construct and send the AES message */
	msg[0] = AP_DRAGNDROP;
	msg[1] = desk_id;
	msg[2] = 0;
	msg[3] = winid;
	msg[4] = msx;
	msg[5] = msy;
	msg[6] = kstate;
	msg[7] = (pipename[17] << 8) | pipename[18];
	i = appl_write(apid, 16, (BYTE *)msg);
	if (i == 0) {
		Fclose(fd);
		return -2;
	}

/* now wait for a response */
	fd_mask = 1L << fd;
	i = (WORD)Fselect(DD_TIMEOUT, &fd_mask, 0L, 0L);
	if (!i || !fd_mask) {	/* timeout happened */
abort_dd:
		Fclose(fd);
		return -1;
	}

/* read the 1 byte response */
	i = (WORD)Fread(fd, 1L, &c);
	if (i != 1 || c != DD_OK) {
		goto abort_dd;
	}

/* now read the "preferred extensions" */
	i = (WORD)Fread(fd, (long)DD_EXTSIZE, exts);
	if (i != DD_EXTSIZE) {
		goto abort_dd;
	}

	oldpipesig = Psignal(SIGPIPE, SIG_IGN);
	return fd;
}

/*
 * see if the recipient is willing to accept a certain
 * type of data (as indicated by "ext")
 *
 * Input parameters:
 * fd		file descriptor returned from ddcreate()
 * ext		pointer to the 4 byte file type
 * name		pointer to the name of the data
 * size		number of bytes of data that will be sent
 *
 * Output parameters: none
 *
 * Returns:
 * DD_OK	if the receiver will accept the data
 * DD_EXT	if the receiver doesn't like the data type
 * DD_LEN	if the receiver doesn't like the data size
 * DD_NAK	if the receiver aborts
 */

WORD
ddstry( WORD fd, BYTE *ext, BYTE *name, LONG size)
{
	WORD hdrlen, i;
	char c;

/* 4 bytes for extension, 4 bytes for size, 1 byte for
 * trailing 0
 */
	hdrlen = 9 + strlen(name);
	i = (WORD)Fwrite(fd, 2L, &hdrlen);

/* now send the header */
	if (i != 2) return DD_NAK;
	i = (WORD)Fwrite(fd, 4L, ext);
	i += (WORD)Fwrite(fd, 4L, &size);
	i += (WORD)Fwrite(fd, (long)strlen(name)+1, name);
	if (i != hdrlen) return DD_NAK;

/* wait for a reply */
	i = (WORD)Fread(fd, 1L, &c);
	if (i != 1) return DD_NAK;
	return c;
}


/* Code for either recipient or originator */

/*
 * close a drag & drop operation
 */

VOID
ddclose( WORD fd )
{
	Psignal(SIGPIPE, oldpipesig);
	Fclose(fd);
}


/* Code for recipient */

/*
 * open a drag & drop pipe
 *
 * Input Parameters:
 * ddnam:	the pipe's name (from the last word of
 *		the AES message)
 * preferext:	a list of DD_NUMEXTS 4 byte extensions we understand
 *		these should be listed in order of preference
 *		if we like fewer than DD_NUMEXTS extensions, the
 *		list should be padded with 0s
 *
 * Output Parameters: none
 *
 * Returns:
 * A (positive) file handle for the drag & drop pipe, on success
 * -1 if the drag & drop is aborted
 * A negative error number if an error occurs while opening the
 * pipe.
 */

WORD
ddopen( WORD ddnam, BYTE *preferext)
{
	WORD fd;
	BYTE outbuf[DD_EXTSIZE+1];
	WORD i;
	BYTE *to, *from, c;

	pipename[18] = ddnam & 0x00ff;
	pipename[17] = (ddnam & 0xff00) >> 8;

	fd = (WORD)Fopen(pipename, 2);
	if (fd < 0) return fd;

	outbuf[0] = DD_OK;
	to = &outbuf[1];
	from = preferext;

	for (i = 0; i < DD_EXTSIZE; i++) {
		c = *from;
		*to++ = c;
		if (c) from++;
	}

	oldpipesig = Psignal(SIGPIPE, SIG_IGN);

	if (Fwrite(fd, (long)DD_EXTSIZE+1, outbuf) != DD_EXTSIZE+1) {
		ddclose(fd);
		return -1;
	}

	return fd;
}

/*
 * ddrtry: get the next header from the drag & drop originator
 *
 * Input Parameters:
 * fd:		the pipe handle returned from ddopen()
 *
 * Output Parameters:
 * name:	a pointer to the name of the drag & drop item
 *		(note: this area must be at least DD_NAMEMAX*2 bytes long,
 *		 and will also be used to store the file name)
 * fname:	a pointer to a pointer to a file name for this item
 * whichext:	a pointer to the 4 byte extension
 * size:	a pointer to the size of the data
 *
 * Returns:
 * 0 on success
 * -1 if the originator aborts the transfer
 *
 * Note: it is the caller's responsibility to actually
 * send the DD_OK byte to start the transfer, or to
 * send a DD_NAK, DD_EXT, or DD_LEN reply with ddreply().
 */

WORD
ddrtry( WORD fd, BYTE *name, BYTE **fname, BYTE *whichext, LONG *size)
{
	WORD hdrlen;
	WORD i;
	BYTE buf[80];

	i = (WORD)Fread(fd, 2L, &hdrlen);
	if (i != 2) {
		return -1;
	}
	if (hdrlen < 9) {	/* this should never happen */
		return -1;
	}
	i = (WORD)Fread(fd, 4L, whichext);
	if (i != 4) {
		return -1;
	}
	whichext[4] = 0;
	i = (WORD)Fread(fd, 4L, size);
	if (i != 4) {
		return -1;
	}
	hdrlen -= 8;
	if (hdrlen > DD_NAMEMAX+DD_NAMEMAX)
		i = DD_NAMEMAX+DD_NAMEMAX;
	else
		i = hdrlen;
	if (Fread(fd, (long)i, name) != i) {
		return -1;
	}
	hdrlen -= i;

/* skip any extra header */
	while (hdrlen > 80) {
		Fread(fd, 80L, buf);
		hdrlen -= 80;
	}
	if (hdrlen > 0)
		Fread(fd, (long)hdrlen, buf);

/* find the file name, if it is there */
	hdrlen = i;	/* original amount of data we read */
	for (i = 0; i < hdrlen-1; i++) {
		if (name[i] == 0) {
			i++;
			break;
		}
	}
	*fname = name+i;
	return 0;
}

/*
 * send a 1 byte reply to the drag & drop originator
 *
 * Input Parameters:
 * fd:		file handle returned from ddopen()
 * ack:		byte to send (e.g. DD_OK)
 *
 * Output Parameters:
 * none
 *
 * Returns: 0 on success, -1 on failure
 * in the latter case the file descriptor is closed
 */

WORD
ddreply( WORD fd, WORD ack)
{
	BYTE c = ack;

	if (Fwrite(fd, 1L, &c) != 1L) {
		Fclose(fd);
	}
	return 0;
}


/*
 * rec_ddmsg(int *msg): given a drag & drop message, act as
 * a recipient and get the data
 */

static char ourexts[DD_EXTSIZE] = "PATH";

VOID
rec_ddmsg( WORD msg[] )
{
	WORD winid;
	WORD mx, my, kstate;
	WORD fd, pnam;
	WORD ditem, dtype;
	WORD exec, d_id;
	WINDOW *dwin;
	OBJECT *dobj;
	WORD handle, id, ddresult;
	IDTYPE *itype;
	WORD reply;
	BYTE *path;
	BYTE buffer[14];
	DIR  *dir;
	BYTE *txtname, ext[5];
	BYTE *filename;
	LONG size;
	BYTE *pathbuf;

	winid = msg[3];
	mx = msg[4];
	my = msg[5];
	kstate = msg[6];
	pnam = msg[7];

	fd = ddopen(pnam, ourexts);
	if (fd < 0) return;

	reply = DD_NAK;

	pathbuf = malloc( 1024L );
	if (!pathbuf) {
		ddreply(fd, DD_NAK);
		ddclose(fd);
		return;
	}
	txtname = pathbuf + 512;

	exec = ch_obj( mx, my, &dwin, &ditem, &dtype );

	if ( dtype == DESKICON ) {
		dobj = background;
		d_id = 0;
	} else {
		dobj = dwin->w_obj;
		d_id = dwin->w_id;
	}
	if ( ditem && exec ) {
		if ( !(dobj[ditem].ob_state & SELECTED) ) {
			dobj[ditem].ob_state |= SELECTED;
			do_redraw( d_id, &full, ditem );
		}
	}

	handle = wind_find( mx, my );
	if (handle != winid)
		goto finish;
	wind_get( handle, WF_OWNER, &id, &pnam, &pnam, &pnam );
	if ( id != desk_id )
		goto finish;

	if (dtype == DESKICON) {
		itype = &backid[ditem];
		if (itype->i_type == TRASHCAN) {
			reply = DD_TRASH;
			goto finish;
		} else if (itype->i_type == PRINTER) {
			reply = DD_PRINTER;
			goto finish;
		} else if (itype->i_type == XDIR) {
			path = itype->i_path;
		} else if (itype->i_type == DISK) {
			strcpy( wildext, buffer );
			buffer[0] = (BYTE)(itype->i_cicon.monoblk.ib_char & 0x00ff);
			path = buffer;
		} else {
	/* get the clipboard directory */
			path = pathbuf+1;
			*path = 0;
			if (scrp_read(path) == 0 || path[0] == 0) {
				strcpy(scapath, path);
				path[0] = ( isdrive() & 0x04 ) ? 'C' : 'A';
				Dcreate( path );
				scrp_write( path );
			}
		}
	} else {
		path = dwin->w_buf;
		strcpy( dwin->w_path, path );
		if (ditem) {
			dir = get_dir( dwin, ditem );
			if ( dir->d_att & SUBDIR )
				cat_path( dir->d_name, path );
		}
	}
	if (path != pathbuf+1) {
	  strcpy(path, pathbuf+1); /* +1 so we can put a command line length byte in */
	  path = pathbuf+1;
	}
	*(r_slash(path) + 1) = 0;

	for (;;) {
		ddresult = ddrtry(fd, txtname, &filename, ext, &size);
		if (ddresult < 0) {
			reply = -1;
			break;
		}
	/* note: strcmp semantics are *not* ANSI!!! */
		if (strcmp(ext, "PATH") == TRUE) {
			if (size < strlen(path)+1) {
				ddreply(fd, DD_LEN);
				continue;
			}
			ddreply(fd, DD_OK);
			Fwrite(fd, (LONG)strlen(path)+1, path);
			reply = -1;	/* no reply needed */
			break;
		}

		if (ext[0] == '.') {
		  ddreply(fd, DD_OK);
		  pnam = copypipe(fd, size, path, filename, ext);
		  reply = -1;	/* no reply needed */
		  if (pnam && dtype == DESKICON) {
		    if (exec && itype->i_type == XFILE)
		    {
		      --path;
		      *path = strlen( path + 1 );
		      exec_file( backid[ditem].i_path, (WINDOW *)0, ditem,
					path );
#if 0
		      Fdelete( path + 1 ); /* delete temp. file */
#endif
		    } else if (!exec) {
		      save_ext( path, buffer );
		      app_icon(buffer, -1, &pnam);
		      pnam = make_icon( 0, pnam, XFILE, txtname );
		      if (pnam == -1)
		        do1_alert( NOICON );
		      else {
			app_mtoi( mx, my, &background[pnam].ob_x,
				&background[pnam].ob_y );
			lp_fill( path, &backid[pnam].i_path );
			if ( !backid[pnam].i_path ) {
			  do1_alert( NOICON );
			  background[pnam].ob_flags |= HIDETREE;
			} else {
			  do_redraw( 0, &full, pnam );
			}
		      } 
		    }
		  }
		  up_2allwin( path );
		  break;
		} else {
			ddreply(fd, DD_EXT);
		}
	}

finish:
	if (reply >= 0)		/* -1 indicates no reply necessary */
		ddreply( fd, reply );
	ddclose( fd );
	free(pathbuf);
	Fselect(500, 0L, 0L, 0L);	/* pause a bit */
	if (ditem && exec) {
		dobj[ditem].ob_state &= ~SELECTED;
		do_redraw( d_id, &full, ditem );
	}
}


WORD
copypipe(ifd, size, path, filename, ext)
	WORD ifd;
	LONG size;
	BYTE *path;
	BYTE *filename;
	BYTE *ext;
{
	BYTE temp[80];
	BYTE *addr;
	LONG chunksize, i;
	WORD ofd;
	WORD ret;

	ret = FALSE;
	addr = (BYTE *)Mxalloc( size, 3 );
	chunksize = size;

	if (!addr) {
		chunksize = 8192L;
		addr = (BYTE *)Mxalloc( chunksize, 80 );
		if (!addr) {
			addr = temp;
			chunksize = 80;
		}
	}
	if (*filename) {
		strcat( filename, path );
	} else {
		strcat( "DRAGDROP", path );
		strcat( ext, path );
	}

#if 0
	strcpy("[4][ DRAGDROP: type ", temp);
	strcat(ext, temp);
	strcat("|to: ", temp);
	strcat(path, temp);
	strcat("][ OK |Cancel]", temp);
	i = form_alert(1, temp);

	if (i == 1) {
#endif
retry1:
	ofd = Fcreate( path, 0 );
	if (ofd < 0) {
		if ( fill_string( filename, CNTCRTFL ) == 2 )
			goto retry1;
	} else {
		while (size > 0) {
			i = Fread(ifd, chunksize, addr);
			if (i > 0) {
				size -= i;
				Fwrite(ofd, i, addr);
			} else
				size = 0;
		}
		Fclose(ofd);
		ret = TRUE;
	}
#if 0
	}
#endif
	if (addr != temp) {
		Mfree( addr );
	}
	return ret;
}
