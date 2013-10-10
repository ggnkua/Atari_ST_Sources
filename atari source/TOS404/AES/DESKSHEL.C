/*	DESKSHELL.C		4/24/89	- 6/15/89	Derek Mui	*/
/*	Take out vdi_handle	6/28/89					*/
/*	Modify exec_file, run_it	9/13/89		D.Mui		*/
/*	Check undo key during printing	9/26/89		D.Mui		*/

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
#include <error.h>
#include <extern.h>

EXTERN	BYTE	*r_slash();
EXTERN	BYTE	*g_name();
EXTERN	APP	*app_xtype();
EXTERN	BYTE	toupper();
EXTERN	BYTE	*scasb();
EXTERN	OBJECT	*get_tree();

EXTERN	WORD	d_exit;

EXTERN	WORD	s_defdir;
EXTERN	WORD	s_fullpath;
EXTERN	WINDOW	*x_win;
EXTERN	WORD	x_type;

EXTERN	WORD	sh_iscart;
EXTERN	BYTE	*strcpy();

	WORD
xch_tail( ptr, argu, tail )
	BYTE	*ptr,*argu,*tail;
{
	if ( ( strlen( ptr ) + strlen( argu ) + 1 ) >= PATHLEN )
	{
	  do1_alert( FCNOMEM );
	  return( FALSE );	
	}
	else
	{
	  strcpy( argu, &tail[1] );	/* put in first argus	*/
	  strcat( ptr, &tail[1] );	/* patch in file name	*/
	  tail[0] = strlen( &tail[1] );
	  return( TRUE );	  
	}
}

	WORD
ch_tail( ptr, tail )
	BYTE	*ptr,*tail;
{
	return( xch_tail( ptr, Nostr, tail ) );
}


show_file( file )
	BYTE	*file;
{
	menu_bar( menu_addr, FALSE );
	v_hide_c( );
	v_enter_cur( );	
	xvq_chcell( &d_nrows );
	d_nrows--;
	showfile( file, FALSE );		
	v_exit_cur( );
	v_show_c( 0 );
	menu_bar( menu_addr, TRUE );	
	form_dial( FMD_FINISH, 0, 0, 0, 0, full.x, full.y, full.w, full.h );
	wait_msg();
}

	
pr_setup( )
{
	inf_sset( get_tree( PRINTFIL ), PFILE, Nostr );
	fm_draw( PRINTFIL ); 		
}


/*	Print one single file		*/

	WORD
printit( str )
	BYTE	*str;
{
	BYTE		*ptr;
	REG OBJECT	*obj;

	obj = get_tree( PRINTFIL );
	xinf_sset( obj, PFILE, g_name( str ) );
	draw_fld( obj, PFILE ); 
	return( showfile( str, TRUE ) );
}


/*	Loop for print files	*/

print_file( )
{
	WORD	ret,type,print,ret1;
	BYTE	*str;
	GRECT	pt;	
	
	ret1 = build_rect( background, &pt, d_xywh[6], d_xywh[9] );

	ret = x_first( &str, &type );	/* get the first file	*/
	print = FALSE;

	desk_wait( TRUE );
 
	while( ret )
	{
	  if ( ( type == XFILE ) || ( type == WINICON ) )
	  {
	     if ( !print )
	     {
	       print = TRUE;
	       pr_setup();
	     }

	     if ( !printit( str ) )
	       break;
	  }

	  x_del();		/* deselecte the file	*/

	  if ( !ch_undo() )
	    break;
 	
	  ret = x_next( &str, &type );
	}

	if ( print )
	  do_finish( PRINTFIL );
		
	if ( x_type == DESKICON )	/* update the desktop	*/
	{
	   if ( ret1 )
	     do_redraw( 0, &pt, 0 );
	}
	else
	  up_2( x_win );

	desk_wait( FALSE );
} 	


/*	Launch a file	*/

launch_pref()
{
	WORD	graphic;
	REG OBJECT	*obj;
	BYTE	*ptr;
	
	obj = get_tree( DLAUNCH );
	inf_sset( obj, RUNNAME, Nostr );
	if ( fmdodraw( DLAUNCH, 0 ) == LAUNCHOK )
	{
	  inf_sget( obj, RUNNAME, path1 );
	  if ( path1[0] )
	  {
	    graphic = ( obj[LGRAPHIC].ob_state & SELECTED ) ? TRUE : FALSE;
	    ptr = scasb( path1, ' ' );
	    if ( *ptr )		/* point to the blank	*/
	    {
	      *ptr++ = 0;
	      if ( !ch_tail( ptr, comtail ) )
	        return;
	    }
	    else
	      comtail[0] = 0;

	    if ( path1[1] == ':' )
	      path1[0] = toupper( path1[0] );
		
	    run_it( path1, comtail, graphic, s_defdir );
	  }
	}
}


/*	Set the current directory					*/
/*	The path should look like A:\FILENAME or A:\FOLDER\FILENAME	*/

	WORD
set_dir( path )
	REG BYTE	path[];
{
	REG BYTE	*ptr;
	REG WORD	ret;

	if ( path[0] == 'c' )
	  return( TRUE );

	ret = TRUE;

	if ( path[0] == '\\' )		/* at the current root	*/
	  ret = Dsetpath( bckslsh );
	else
	{				/* there is drive id	*/
	  if ( path[1] == ':' )
	  {
	    if ( hit_disk( (WORD)path[0] ) )
	    {
	      Dsetdrv( (WORD)( toupper( path[0] ) - 'A') );
	      ptr = r_slash( path );
	      if ( &path[2] == ptr )
	        ret = Dsetpath( bckslsh );
	      else
	      {
	        *ptr = 0;
	        ret = Dsetpath( &path[2] );
	        *ptr = '\\';	
	      }
	    }
	  }
	  else			/* only file name !!!	*/
	    ret = FALSE;	/* OK			*/
	}

	return( ret ? FALSE : TRUE );
}


/*	Run an application include doing dialogue box	*/

exec_file( infile, win, item, intail )
	BYTE	*infile;
	WINDOW	*win;
	WORD	item;
	BYTE	*intail;
{
	WORD	type,install,graphic;
	WORD	dofull,setdir,which;		
	REG APP	*app;
	OBJECT	*obj;
	BYTE	buffer[14];
	BYTE	*tail;
	BYTE	*file;

	app = app_xtype( infile, &install );
	type = app->a_type;
						/* installed document	*/
	if ( ( install ) && ( app->a_name[0] ) )
	{
	  tail = infile;			/* infile becomes tail	*/
	  file = app->a_name;
	}
	else
	{
	  tail = ( intail[0] ) ? &intail[1] : Nostr;
	  file = infile;
	}

	if ( strcmp( file, app->a_name ) )
	{
	  dofull = ( app->a_pref & 0x2 ) ? TRUE : FALSE; 
	  setdir = ( app->a_pref & 0x1 ) ? TRUE : FALSE;
	}
	else
	{
	  dofull = s_fullpath;
	  setdir = s_defdir;
	}

	if ( !dofull )		/* file name only	*/
	  tail = g_name( tail );

	if ( !xch_tail( tail, app->a_argu, comtail ) )	  
	  return;

	graphic = TRUE;

	switch( type )
	{
	  case TEXT:				/* print	*/
	    if ( ( which = do1_alert( STNOAPPL ) ) == 2 )
  	    {
	      desk_wait( TRUE );
	      pr_setup();
	      printit( file );
	      desk_wait( FALSE );
	      do_finish( PRINTFIL );
	    }
	    else
	    if ( which == 1 )		/* show 	*/
	      show_file( file );

	    return;
	
	  case TTP:		/* TOS takes parameter	*/
	    graphic = FALSE;

	  case PTP:		/* program takes parameter	*/
	    if ( ( install ) || ( *tail ) )
	      break;

	    obj = get_tree( ADOPENAP );
	    tail = g_name( file );
	    xinf_sset( obj, APPLNAME, tail );
	    inf_sset( obj, APPLPARM, app->a_argu );
	     
	    if ( fmdodraw( ADOPENAP, 0 ) == APPLCNCL )
	      return;

	    tail = (TEDINFO*)(obj[APPLPARM].ob_spec)->te_ptext;

	    if ( !ch_tail( tail, comtail ) )
	      return;

	    break;
		
	  case TOS:
	    graphic = FALSE;
	    break;
	
	  case PRG:
	  case APPS:
	    break;
	
	  default:
	    do1_alert( NOTYPE );
	    return;
	 }

	do_box( win, item, ( win ) ? FALSE : TRUE, TRUE, TRUE );
	run_it( file, comtail, graphic, setdir );  
}


/*	Run the application	*/

run_it( file, tail, graphic, setdir )
	BYTE	*file;
	BYTE	*tail;
	WORD	graphic, setdir;
{
	if ( m_sfirst( file, 0x31 ) )	/* search the file */
	{
	  fill_string( file, FNOTFIND );
	  return;
	}

	desk_wait( TRUE );

	if ( ( strlen( tail ) >= PATHLEN ) || 
	     ( strlen( file ) >= PATHLEN ) )
	{
	  do1_alert( NOBUF );
	  goto ex_1;
	}

	if ( setdir )	/* set according to application	*/
	{
ex_3:	  if ( !set_dir( file ) )
	    goto ex_2;
	}
	else		/* set as top window	*/
	{
	  if ( winhead->w_id == -1 )
	    goto ex_3;
	
	  if ( !set_dir( winhead->w_path ) )
	  {
ex_2:	    do1_alert( NOSETDIR );
ex_1:	    desk_wait( FALSE );
	    return;
	  }
	}
		
	if ( !save_inf( FALSE ) )		/* prepare to launch application */
	  goto ex_1;

	wind_set( 0, WF_NEWDESK, 0, 0, 0, 0 );
	
	if ( *file == 'c' )
	{
	  if ( cart_init() )
	    sh_iscart = TRUE;
	  else
	  {
	    do1_alert( NOCART );			
	    return;
	  }
	}
	else
	  sh_iscart = FALSE;

	tail[strlen( tail )+1] = 0xD;
	shel_write( TRUE, graphic, 0, file, tail );	
	d_exit = L_LAUNCH;
}
