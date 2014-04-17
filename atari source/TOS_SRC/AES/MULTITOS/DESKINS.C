/*	DESKINS.C		3/18/89 - 9/18/89	Derek Mui	*/
/*	Fix at ins_app, at app_free. Do the str check before freeing	*/
/*	the app 		3/3/92			D.Mui		*/
/*	Change all the iconblk to ciconblk	7/11/92	D.Mui		*/
/*	Change at ins_wicon and ins_icons	7/11/92	D.Mui		*/
/*	Convert to Lattice C 5.51		2/18/93 C.Gee		*/

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
#include "extern.h"
#include "error.h"
#include "pdesk.h"
#include "pmisc.h"

EXTERN	BYTE	*get_fstring();
EXTERN	BYTE	*r_slash();
EXTERN	APP	*app_xtype();
EXTERN	APP	*app_icon();
EXTERN	BYTE	toupper();
EXTERN  WORD	av_icon();
EXTERN	BYTE	*scasb();
EXTERN	APP	*app_alloc();
EXTERN	BYTE	*g_name();
EXTERN	OBJECT	*get_tree();
EXTERN	OBJECT	*get_icon();
EXTERN	DIR	*get_dir();
EXTERN	BYTE	*put_name();

EXTERN	WORD	numicon;

EXTERN	WINDOW	*o_win;
EXTERN	WORD	o_type;
EXTERN	WORD	o_item;
EXTERN	WORD	o_status;
EXTERN	WORD	x_status;
EXTERN	WORD	s_defdir;
EXTERN	WORD	s_fullpath;
EXTERN	WORD	tb3[];
EXTERN	BYTE	mentable[];


/*	copy iconblk image	*/
/*	return the sources type	*/

	WORD
cp_iblk( number, dest_ciblk )
	REG CICONBLK	*dest_ciblk;
	WORD		number;
{
	OBJECT		*obj;
	CICONBLK	*ciblk;
	ICONBLK		*iblk;

	if ( number >= numicon )
	  number = numicon - 1;

	obj = get_icon( number );

	if ( obj->ob_type == G_ICON )
	{
	  iblk = (ICONBLK*)(obj->ob_spec);
	  dest_ciblk->monoblk.ib_pmask = iblk->ib_pmask;
	  dest_ciblk->monoblk.ib_pdata = iblk->ib_pdata;
	  dest_ciblk->monoblk.ib_char = iblk->ib_char;
	  dest_ciblk->monoblk.ib_xchar = iblk->ib_xchar;
	  dest_ciblk->monoblk.ib_ychar = iblk->ib_ychar;
	  dest_ciblk->mainlist = (CICON*)0;
	}
	else	/* must be G_CICON */
	{
	  ciblk =(CICONBLK*)(obj->ob_spec);
	  dest_ciblk->monoblk.ib_pmask = ciblk->monoblk.ib_pmask;
	  dest_ciblk->monoblk.ib_pdata = ciblk->monoblk.ib_pdata;
	  dest_ciblk->monoblk.ib_char = ciblk->monoblk.ib_char;
	  dest_ciblk->monoblk.ib_xchar = ciblk->monoblk.ib_xchar;
	  dest_ciblk->monoblk.ib_ychar = ciblk->monoblk.ib_ychar;
	  dest_ciblk->mainlist = ciblk->mainlist;	
	}

	return( obj->ob_type );
}



/*	Remove desktop icons	*/

	VOID
rm_icons( VOID )
{
	REG OBJECT	*obj;
	REG WORD	i;
	WORD		found,collect;

	obj = background;
	
	found = FALSE;
	collect = FALSE;

	for ( i = 1; i <= obj->ob_tail; i++ )
	{
	  if ( ( obj[i].ob_state & SELECTED ) && ( !( obj[i].ob_flags & HIDETREE ) ) )
	  {
	    found = TRUE;
	    obj[i].ob_flags |= HIDETREE;
	    if ( ( backid[i].i_type == XFILE ) || ( backid[i].i_type == XDIR ) )
	      collect = TRUE;
	  }	
	}

	if ( collect )		/* clean up memory	*/
	  lp_collect();

	if ( found )		/* redraw screen	*/
	  clr_dicons();
}



/*	Install desktop icons		*/

	VOID
ins_icons( VOID )
{
	REG OBJECT	*obj;
	REG CICONBLK	*iblk;
	CICONBLK	ciblk;
	REG OBJECT	*obj1;
	REG WORD	type,item,icon,style;
	WORD		ret,limit,redraw,select,xitem;
	WORD		driver,quit,which;
	BYTE		buf1[2];
	BYTE		idbuffer[2];
	BYTE		buffer[14];	
	GRECT		pt;
	WORD		mk_x, mk_y, mk_buttons, mk_kstate;
	LONG		saveptr;
	WORD		temp;

	quit = FALSE;
	xitem = item = o_item;
	obj = get_tree( ADINSDIS );
	idbuffer[1] = 0;
	obj1 = background;
	limit = numicon;			/* max number of icon	*/

	saveptr = obj[IICON].ob_spec;
	
	while( TRUE )
	{
	  obj[IICON].ob_type = G_CICON;	/* 7/11/92 */
	  ciblk.monoblk = *(ICONBLK*)(obj[IICON].ob_spec);
	  obj[IICON].ob_spec = ( LONG )&ciblk;
	  iblk = (CICONBLK*)(obj[IICON].ob_spec);
	  redraw = FALSE;
	  
	  if ( o_status )			/* an icon is selected	*/
	  {
	    type = backid[item].i_type;	  
	    strcpy( (BYTE *)((CICONBLK*)(obj1[item].ob_spec))->monoblk.ib_ptext, buffer );
	    buf1[0] = idbuffer[0] = (BYTE)backid[item].i_cicon.monoblk.ib_char;
	    icon = backid[item].i_icon;
	    if ( icon >= numicon )
	      icon = numicon - 1;
	  }
	  else			/* no icon is selected	*/	
	  {
	    buffer[0] = 0;
	    idbuffer[0] = 0;
	    icon = 0;
	    type = DISK;
	    buf1[0] = 0;
	  }

	  if ( ( type == XFILE ) || ( type == XDIR ) )	/* file		*/
	  {
	    style = DISABLED;
	    select = NONE;
	    driver = FALSE;
	  }
	  else			/* printer, disk, trashcan	*/
	  {
	    driver = TRUE;
	    style = NORMAL;
	    select = EDITABLE;

	    if ( type == DISK )
	      ret = IDRIVE;

	    if ( type == TRASHCAN )
	      ret = ITRASH;

	    if ( type == PRINTER )
	      ret = IPRINTER;
	  }

	  obj[DRID].ob_flags = (obj[DRID].ob_flags & (IS3DOBJ|IS3DACT)) | select;
	  obj[IDRIVE].ob_state = style;
	  obj[ITRASH].ob_state = style;
	  obj[IPRINTER].ob_state = style;
	  obj[DRID].ob_state = style;

	  if ( driver )
	    obj[ret].ob_state = SELECTED;

	  cp_iblk( icon, iblk );

	  iblk->monoblk.ib_char = iblk->monoblk.ib_char & 0xFF00;

	  inf_sset( (LONG)obj, DRLABEL, buffer );
	  inf_sset( (LONG)obj, DRID, idbuffer );

in_5:	  dr_dial_w( ADINSDIS, FALSE, 0 /*dummy */ );
	
in_2:	  ret = xform_do( obj, 0 );
	
	  if ( ret == IUP )
	  {
cg_1:
	    if ( icon )
	    {
	      icon--;
	      goto in_3;
	    }
	    else
	    {
	      wait_up();
	      XDeselect( obj, ret );
	      goto in_2;
	    }
	  }

	  if ( ret == IDOWN )
	  {
cg_2:
	    if ( ( icon + 1 ) < limit )
	    {
	      icon++;
in_3:
	      XSelect( obj, ret );	/* cjg 08/06/92 */
	      cp_iblk( icon, iblk );
	      iblk->monoblk.ib_char = iblk->monoblk.ib_char & 0xFF00;
	      objc_draw( (LONG)obj, IBOX, 1, full.g_x, full.g_y, full.g_w,
			 full.g_h  );
	      cl_delay();

	      /* cjg 08/06/92 */
	      graf_mkstate( &mk_x, &mk_y, &mk_buttons, &mk_kstate );
	      if( mk_buttons )
	      {
		if( ret == IUP )
		  goto cg_1;

		if( ret == IDOWN )
		  goto cg_2;
	      }
	    }
	    wait_up();
	    XDeselect( obj, ret );
	    goto in_2;
	  }

	  if ( ret == DRQUIT )
	  {
	    quit = TRUE;
	    goto in_1;
	  }
	
	  if ( ret == DRCNCL )		/* cancel		*/
	    goto in_1;
					/* this is install	*/
	  inf_sget( (LONG)obj, DRID, idbuffer );

	  if ( idbuffer[0] != 'c' )
	    idbuffer[0] = toupper( idbuffer[0] );

	  if ( driver )			/* driver type	*/
	  {				/* drive icon	*/
	    if ( !( which = inf_gindex( (LONG)obj, IDRIVE, 3 ) ) ) /* driver type */
	    {
	      if ( ( !idbuffer[0] ) || ( idbuffer[0] == ' ' ) )
	      {
	        do1_alert( NOID );
	        goto in_5;
	      }
	      else
	      {
		if ( type == DISK )
		{
	          if ( idbuffer[0] != buf1[0] )
	            goto in_41;
		}			    
	      }
	    }
	  }
	
	  if ( o_status )		/* icon selected	*/
	    goto in_4;			/* don't allocate	*/

in_41:	  if ( ( item = av_icon( ) ) == -1 )	/* get new one	*/
	  {					/* failed	*/
	     do1_alert( NOICON );
	     goto in_1;
	  }

in_4:	  redraw = TRUE;		/* user selected OK	*/
	  iblk = (CICONBLK*)(obj1[item].ob_spec);
	  cp_iblk( icon, iblk );
	  backid[item].i_icon = icon;

/*	  strcpy( (( ICONBLK )((CICONBLK*)(obj[DRLABEL].ob_spec))->monoblk).te_ptext, - by I don't know who */

/*	  cjg 03/03/93
	  strcpy((BYTE *)((CICONBLK*)(obj[DRLABEL].ob_spec))->monoblk.ib_ptext, 
		  (BYTE *)iblk->monoblk.ib_ptext );
*/
	  strcpy( ( BYTE *)(( TEDINFO *)(obj[ DRLABEL ].ob_spec ))->te_ptext,
		  ( BYTE *)iblk->monoblk.ib_ptext );

	  if ( driver )
	  {
	    if ( !which )		/* Disk Drive	*/
	    {
	      type = DISK;
	      temp = iblk->monoblk.ib_char & 0xFF00;
	      iblk->monoblk.ib_char = temp | idbuffer[0];
	    }
	    else
	    {
	      type = ( which == 1 ) ? TRASHCAN : PRINTER;
	      iblk->monoblk.ib_char = iblk->monoblk.ib_char & 0xFF00;	
	    }
	  }
	  else
	    iblk->monoblk.ib_char = iblk->monoblk.ib_char & 0xFF00;

	  backid[item].i_type = type;
in_1:
	  if ( redraw )
	  {
	    pt.g_x = obj1[0].ob_x + obj1[item].ob_x;
	    pt.g_y = obj1[0].ob_y + obj1[item].ob_y;
            pt.g_w = obj1[item].ob_width;
            pt.g_h = obj1[item].ob_height;
	    do_redraw( 0, &pt, 0 );
	  }

	  if ( quit )
	    break;

	  xitem++;

	  if ( !i_next( xitem, obj1, &xitem ) )
	    break;

	  item = xitem;

	}/* while */

	do_finish( ADINSDIS );
	obj[IICON].ob_spec = saveptr;
}






/*	Install window icons	*/

	VOID
ins_wicon( VOID )
{
	REG 	APP	*app;
	REG 	OBJECT	*obj;
	WORD		ret,limit,index,quit,itype;
	WORD		type,pref,status;
	CICONBLK	*iblk;
	CICONBLK	ciblk;
	BYTE		buffer[14];
	BYTE		buf2[14];
	BYTE		*str;
	WORD		mk_x, mk_y, mk_buttons, mk_kstate;
	LONG		saveptr;

	obj = get_tree( INWICON );
	limit = numicon; 
	quit = FALSE;

	x_first( &str, &itype );
	status = TRUE;
	saveptr = obj[WICON].ob_spec;

	while( status )
	{			/* 7/11/92 */
	  obj[WICON].ob_type = G_CICON;
	  ciblk.monoblk = *(ICONBLK*)(obj[WICON].ob_spec);
	  obj[WICON].ob_spec = ( LONG )&ciblk;
	  iblk = (CICONBLK*)(obj[WICON].ob_spec);
	  inf_sset( (LONG)obj, WNAME, Nostr );
	  obj[WFOLDER].ob_state = NORMAL;
	  obj[WNONE].ob_state = SELECTED;
	  obj[WFOLDER].ob_flags = SELECTABLE|RBUTTON|IS3DOBJ;
	  obj[WNONE].ob_flags = SELECTABLE|RBUTTON|IS3DOBJ;

	  pref = 0;

	  if ( x_status )		/* something is selected	*/
	  {
	    obj[WNAME].ob_flags &= ~EDITABLE;

	    if ( itype == SUBDIR )
	    {
	      obj[WFOLDER].ob_state = SELECTED;
	      obj[WNONE].ob_state = DISABLED;
	      save_mid( str, buf2 );
	    }
	    else
	    {
	      obj[WFOLDER].ob_state = DISABLED;
	      strcpy( g_name( str ), buf2 );
	    }
		
	    obj[WFOLDER].ob_flags &= (IS3DACT|IS3DOBJ);
	    obj[WNONE].ob_flags &= (IS3DACT|IS3DOBJ);

	    app = app_icon( buf2, ( itype == SUBDIR ) ? FOLDER : -1, &index );
	    pref = app->a_pref;
	    xinf_sset( obj, WNAME, buf2 );
	  }
	  else
	  {
	    index = 0;		/* icon index	*/
	    obj[WNAME].ob_flags |= EDITABLE;
	    buf2[0] = 0;
	  }

	  cp_iblk( index, iblk );
	  iblk->monoblk.ib_char = iblk->monoblk.ib_char & 0xFF00;

	  dr_dial_w( INWICON, FALSE, 0 /*dummy */ );

	  while( TRUE )
	  {
	    ret = xform_do( obj, 0 );
	    inf_sget( (LONG)obj, WNAME, buf2 );
	    unfmt_str( buf2, buffer );

	    if ( obj[WNONE].ob_state & SELECTED )
	      type = ICONS;
	    else
	      type = FOLDER;

	    if ( ret == WUP )
	    {
cg_3:
	      if ( index )
	      {
	        index--;
	        goto k_1;				      
	      }
	      wait_up();
	      XDeselect( obj, ret );
	      continue;
	    }

	    if ( ret == WDOWN )
	    {
cg_4:
	      if ( ( index + 1 ) < limit )
	      {
	        index++;
k_1:
	        XSelect( obj, ret );
	        cp_iblk( index, iblk );
	        iblk->monoblk.ib_char = iblk->monoblk.ib_char & 0xFF00;
	        objc_draw( (LONG)obj, WBOX, 1, full.g_x, full.g_y, full.g_w,
		 full.g_h );
		cl_delay();

		/* cjg 08/06/92 */
	        graf_mkstate( &mk_x, &mk_y, &mk_buttons, &mk_kstate );
		if( mk_buttons )
		{
		  if( ret == WUP )
		    goto cg_3;
		  
		  if( ret == WDOWN )
		    goto cg_4;
		}
	      }
	      wait_up();
	      XDeselect( obj, ret );
	      continue;
	    }

	    switch( ret )
	    {
	      case WQUIT:
		quit = TRUE;
		break;

	      case WREMOVE:
	        if ( !buffer[0] )
		  break;

	        app = applist;

	        while ( app )
	        {
		  if ( app->a_type == type )
	          {
		    if ( strcmp( buffer, app->a_doc ) )
		    {
		      app_free( app );
/*		      sort_show( 0, TRUE );	*/
		      break;
		    }
		  }
		  app = ( APP *)app->a_next;
	        }

	        if ( !app )		/* Not found	*/
		  do1_alert( NOMATCH );

		break;
 			
	      case WOK:			/* install a new one anyway */
	        if ( buffer[0] )
	        {			/* try to match the old one	*/
		  app = applist;
		  while ( app )
		  {
		    if ( app->a_type == type )
		    {
		      if ( strcmp( buffer, app->a_doc ) )
		        break;		/* found it	*/
		    }
		    app = ( APP *)app->a_next;
		  }
 		
		  if ( !app )		/* Not find		*/
		  {			/* try allocate one	*/
		    if ( !( app = app_alloc() )	)
		    {
		      do1_alert( NOICON );
		      break;
		    }
		  }

		  app->a_icon = 0;
		  app->a_dicon = 0;
		  app->a_pref = pref;
		  app->a_type = type;
		  strcpy( buffer, app->a_doc );
		  lp_fill( Nostr, &app->a_name );
		  app->a_dicon = index;
		  app->a_icon = index;
		  app->a_limit = 0L;
/*		  sort_show( 0, TRUE );	*/

	        }/* if there is something	*/

	    }/* switch */

	    break;

	  }/* while control */		 	

	  if ( quit )
	    break;

	  if ( x_status )
	    status = x_next( &str, &itype );
	  else
	    break;

	}/* while more		*/

	do_finish( INWICON );
	obj[WICON].ob_spec = saveptr;
	sort_show( 0, TRUE );
}	



/*	Install all the available drives	*/

	VOID
ins_drive( VOID )
{
	REG WORD	i,id;
	WORD		install,free;
	REG OBJECT	*obj;
	LONG		map;
	BYTE		*device;	

	bfill( 32, 0, dr );

	obj = background;
	free = FALSE;

	i = Dgetdrv();
	map = (LONG)Dsetdrv(i);
/*	map = (LONG)Drvmap();	*/
				/* let check which one is installed	*/
	for ( i = 1; i <= maxicon; i++ )
	{
	  if ( ( !( obj[i].ob_flags & HIDETREE ) ) && ( backid[i].i_type == DISK ) )
	  {
	    id = (BYTE)backid[i].i_cicon.monoblk.ib_char;
	    if ( ( id <= '`' ) && ( id >= 'A' ) )
	    {
	      dr[id - 'A'] = 1;
	      if ( !( ( map >> ( id - 'A' ) ) & 0x01 ) )
	      {
		free = TRUE;
		obj[i].ob_flags |= HIDETREE;
	      }
	    }
	  }
	}
				/* now install the icons	*/
	install = FALSE;

	device = get_fstring( DEVICE );

	if ( cart_init() )
	{
	  if ( make_icon( (WORD)('c'), 0, DISK, device ) != -1 )
	    install = TRUE;
	}

	for ( i = 0; i < 32; i++ )
	{
	   if ( ( !dr[i] ) && ( map & 0x1 ) )
	   {
	     if ( make_icon( (WORD)(i + 'A'), 0, DISK, device ) != -1 )
	       install = TRUE;
	     else
	     {
	       do1_alert( NOICON );
	       break;
	     }
	   }
	
	   map >>= 1;
	}

	if ( ( install ) || ( free ) )
	  do_redraw( 0, &full, 0 );
}


/*	Delay the icon scrolling	*/

	VOID
cl_delay( VOID )
{
	WORD	i;

	i = evnt_dclick( 0, 0 );
	evnt_timer( i * 8, 0 );
}
