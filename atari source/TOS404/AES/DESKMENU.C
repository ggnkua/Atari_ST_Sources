/*	DESKMENU.C		3/16/89	- 9/18/89	Derek Mui	*/
/*	Put o_select and x_select into menu_verify	7/3/90	D.Mui	*/
/*	Scan ascii '>' instead of whole scan code	7/12/90	D.Mui	*/
/*	Two new help menu		7/12/90		D.Mui		*/
/*	Display print screen if it is ST mode	7/31/90	D.Mui		*/ 
/*	Fix the alt drive table			8/27/90	D.Mui		*/
/*	Use m_cpu to determine cache or no cache	9/19/90	D.Mui	*/
/*	Fix at read_inf to read file only	7/15/91	D.Mui		*/
/*	Changes to do_opt()		       07/07/92 C.Gee		*/
/*        - Call mv_desk() instead of av_desk()				*/
/*	  - Call mins_app() instead of ins_app()			*/
/*	  - Call mdesk_pref() instead of desk_pref()			*/
/*	  - Add set_video() to do_opt()					*/
/*	Changes to tb3[] - added VIDITEM object				*/
/*      Changes to hdkeybd() - added VIDITEM object			*/


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

EXTERN  WORD    mv_desk();
EXTERN	BYTE	*get_fstring();
EXTERN	APP	*app_key();
EXTERN	BYTE	*get_string();
EXTERN	WINDOW	*get_win();
EXTERN	WINDOW	*get_top();
EXTERN	BYTE	*r_slash();
EXTERN	BYTE	toupper();
EXTERN	OBJECT	*get_tree();
EXTERN	WINDOW	*w_gfirst();
EXTERN	WINDOW	*w_gnext();
EXTERN	BYTE	*g_name();

EXTERN	LONG	gl_vdo;
EXTERN	WORD	m_cpu;
EXTERN	WORD	s_defdir;
EXTERN	WORD	s_fullpath;
EXTERN	WORD	numicon;
EXTERN	WORD	gl_restype;
EXTERN	BYTE	afile[];
EXTERN	WORD	x_status;
EXTERN	WORD	x_type;
EXTERN	BYTE	mkeys[];
EXTERN	BYTE	restable[];
EXTERN	WORD	ftab[];
EXTERN	WORD	st_keybd;

WORD	d_exit;		/* desktop exit flag	*/
BYTE	mentable[MAXMENU];
BYTE	*keytable;
BYTE	*contable;

/*	Alternate keys table	*/

/*	USA|UK|SPAIN|ITALY|SWEDEN	*/
WORD	key1table[] = { 0x1e00, 0x3000, 0x2e00, 0x2000, 0x1200, 0x2100, 0x2200,
			0x2300, 0x1700, 0x2400, 0x2500, 0x2600, 0x3200, 0x3100,
			0x1800, 0x1900, 0x1000, 0x1300, 0x1f00, 0x1400, 0x1600,
			0x2f00, 0x1100, 0x2d00, 0x1500, 0x2c00, 0 };

/*	GERMANY|SWISSFRE|SWISSGER	*/
WORD	key2table[] = { 0x1e00, 0x3000, 0x2e00, 0x2000, 0x1200, 0x2100, 0x2200,
			0x2300, 0x1700, 0x2400, 0x2500, 0x2600, 0x3200, 0x3100,
			0x1800, 0x1900, 0x1000, 0x1300, 0x1f00, 0x1400, 0x1600,
			0x2f00, 0x1100, 0x2d00, 0x2c00, 0x1500, 0 };

/*	FRENCH				*/
WORD	key3table[] = { 0x1000, 0x3000, 0x2e00, 0x2000, 0x1200, 0x2100, 0x2200,
			0x2300, 0x1700, 0x2400, 0x2500, 0x2600, 0x2700, 0x3100,
			0x1800, 0x1900, 0x1e00, 0x1300, 0x1f00, 0x1400, 0x1600,
			0x2f00, 0x2c00, 0x2d00, 0x1500, 0x1100, 0 };


/*	Control keys table	*/

/*	USA|UK|SPAIN|ITALY|SWEDEN	*/
WORD	con1table[] = {0x1e01, 0x3002, 0x2e03, 0x2004, 0x1205, 0x2106, 0x2207,
		       0x2308, 0x1709, 0x240a, 0x250b, 0x260c, 0x320d, 0x310e,
		       0x180f, 0x1910, 0x1011, 0x1312, 0x1f13, 0x1414, 0x1615,
		       0x2f16, 0x1117, 0x2d18, 0x1519, 0x2c1a, 0 };

/*	GERMANY|SWISSFRE|SWISSGER 	*/
WORD	con2table[] = { 0x1e01, 0x3002, 0x2e03, 0x2004, 0x1205, 0x2106, 0x2207,
			0x2308, 0x1709, 0x240a, 0x250b, 0x260c, 0x320d, 0x310e,
			0x180f, 0x1910, 0x1011, 0x1312, 0x1f13, 0x1414, 0x1615,
			0x2f16, 0x1117, 0x2d18, 0x2c19, 0x151a, 0 };

/*	FRENCH			*/
WORD	con3table[] = { 0x1001, 0x3002, 0x2e03, 0x2004, 0x1205, 0x2106, 0x2207,
			0x2308, 0x1709, 0x240a, 0x250b, 0x260c, 0x270d, 0x310e,
			0x180f, 0x1910, 0x1e11, 0x1312, 0x1f13, 0x1414, 0x1615,
			0x2f16, 0x2c17, 0x2d18, 0x1519, 0x111a, 0 };

/*	Arrow keys table	*/
WORD	arrowtab[] = { 0x4d36, 0x5032, 0x4838, 0x4b34, 0x4800, 0x5000, 0x4d00,
		       0x4b00, 0 };

/*	Arrow keys Message	*/
WORD	arrowimg[] = { 5, 1, 0, 4, 2, 3, 7, 6 };

WORD	tb1[] = { NEWFITEM, CLSFITEM, CLSWITEM, BOTTOP, EXTMENU, SELALL, 0 };
WORD	tb2[] = { REMVICON, SEAMENU, SHOWITEM, 0 };

WORD	xxxview[9] = { ICONITEM, TEXTITEM, 0, NAMEITEM, DATEITEM, SIZEITEM, 
		       TYPEITEM, NOSORT, 0 };

/* cjg - added VIDITEM - 07/07/92 		*/
/*	Moved VIDITEM after set preferences	*/
/*	Take out BITBLT and PRINTITE		*/
WORD	tb3[MAXMENU] = { OPENITEM, SHOWITEM, SEAMENU,  DELMENU,  NEWFITEM, 
			 CLSFITEM, CLSWITEM, BOTTOP,   SELALL,   EXTMENU,  
			 FORMITEM, ICONITEM, TEXTITEM, NAMEITEM, DATEITEM, 
			 SIZEITEM, TYPEITEM, NOSORT,   SIZEFIT,  SCOLTYPE, 
			 IDSKITEM, IAPPITEM, INSDISK,  REMVICON, PREFITEM, 
			 VIDITEM,  READINF,  MEMMENU,  SAVEITEM };

/*	Alternate Number Table	*/

WORD	altnum[] = { 0x7800, 0x7900, 0x7a00, 0x7c00, 0x7d00, 0x7b00, 0 };

WORD	o_status;	/* for o_select	*/
WINDOW	*o_win;
WORD	o_type;
WORD	o_item;


/*	Change one individual key	*/
	
ch_key( i )
	WORD	i;
{
	OBJECT		*obj;
	REG WORD	l;
	REG BYTE	*str;

	obj = menu_addr;
	str = obj[tb3[i]].ob_spec;
	l = strlen( str );	  
	if ( mentable[i] )
	{
	  strcpy( "[ ]", &str[l-3] );
	  str[l-2] = mentable[i];
	}
	else
	  strcpy( "   ", &str[l-3] );
}


/*	Put keys into the menus	*/
	
put_keys( )
{
	REG WORD	i;

	for ( i = 0; i < MAXMENU; i++ )
	  ch_key( i );
}


/*	Loop to find matching array	*/

	WORD
loop_find( input, table, index )
	WORD	input;
	WORD	table[];
	WORD	*index;
{
	REG WORD	i;

	i = 0;

	while( table[i] )
	{ 
	  if ( input == table[i] )
	  {
	    *index = i;
	    return( TRUE );
	  }
	  else
	    i++;
	}

	return( FALSE );  
}


/*	Enable or disable the menu item according to current status	*/

menu_verify()
{
	WORD	enable;
	REG 	WORD	i;
	WINDOW	*win;
	WORD	type;
	BYTE	*str;
			/* If there is a window opened/closed	*/

        o_select();	/* check to see if there is anything selected */
	x_select();

	enable = ( winhead->w_id == -1 ) ? FALSE : TRUE;	

	i = 0;	
	while( tb1[i] )
 	  menu_ienable( menu_addr, tb1[i++], enable );

	i = 0;

	if ( x_status )
	{
	  enable = TRUE;
	  if ( x_type == WINICON )
	    i = 1;
	}
	else
	  enable = FALSE;		

	while( tb2[i] )
 	  menu_ienable( menu_addr, tb2[i++], enable );

	enable = x_first( &str, &type );

 	menu_ienable( menu_addr, DELMENU, enable );
 	menu_ienable( menu_addr, IAPPITEM, enable );

	enable = FALSE;

	if ( w_gfirst() )
	{
	  if ( w_gnext() )
	    enable = TRUE;

 	  menu_ienable( menu_addr, SEAMENU, TRUE );
 	  menu_ienable( menu_addr, SHOWITEM, TRUE );
	}

 	menu_ienable( menu_addr, BOTTOP, enable );
	ch_cache( FALSE );
#if 0	/* take out for sparrow	*/
 	menu_ienable( menu_addr, PRINTITE, ( gl_restype <= 3 ) ? TRUE : FALSE );
#endif
}


/*	Select all objects inside the window	*/

sel_all( )
{
	REG WINDOW	*win;
	REG DIR		*dir;
	REG WORD	i;
	BYTE		buffer[14];

	if ( win = w_gfirst() )
	{
	  clr_dicons( );
          dir = win->w_memory;
	  strcpy( g_name( win->w_path ), buffer );
	  for ( i = 0; i < win->w_items; i++ )
	  {
	    if ( wildcmp( buffer, dir[i].d_name ) )
	      dir[i].d_state = SELECTED; 	    
	  }

	  up_2( win );	   
	}
}


/*	Handle the keyboard	*/

hd_keybd( key )
	UWORD	key;
{
	OBJECT		*obj;
	REG WINDOW	*win;
	REG WORD	item;
	WORD		msgbuff[8];
	BYTE		buffer[14];
	WORD		i;
	BYTE		*str;
	APP		*app;

	switch( st_keybd )
	{
	  case 1:
	  case 7:
	  case 8:
	    keytable = key2table;
	    contable = con2table;
	    break;
	  case 2:
	    keytable = key3table;
	    contable = con3table;
	    break;
	  case 0:	/* usa */
	  case 3:	/* uk	*/
	  case 4:	/* spain */
	  case 5:	/* italy */
   	  case 6:	/* sweden */
	  default:
	    keytable = key1table;
	    contable = con1table;
	    break;	    				
	}

	if ( app = app_key( key ) )
	{
	  exec_file( app->a_name, (WINDOW*)0, 0, Nostr );
	  return;
	}

	win = get_top();

	item = toupper( key );

	for ( i = 0; i < MAXMENU; i++ )
	{
	  if ( !mentable[i] )
	    continue;

	  if ( item == toupper( mentable[i] ) )
	  {
	    switch ( i )
	    {
	      case 0:			/* Open item	*/
	      case 1:			/* Show	item	*/
	      case 2:			/* Search	*/
	      case 3:			/* Delete	*/
	      case 4: 			/* Folder making	*/
	      case 5:			/* Close directory	*/
	      case 6:			/* Close top window	*/
	      case 7:			/* Bottom to top	*/
	      case 8:			/* Select all		*/
	      case 9:			/* Set Extension	*/
	      case 10:			/* Format Disk		*/
	    	do_file( tb3[i] );
	    	return;
	
	      case 11:			/* Icon mode		*/
	      case 12:			/* Text mode		*/
	      case 13:			/* Sort by Name		*/
	      case 14:			/* Sort by Date		*/
	      case 15:			/* Sort by Size		*/
	      case 16:			/* Sort by Type		*/
	      case 17:			/* No Sort		*/
	      case 18:			/* Size to fit		*/
	      case 19:			/* Window Style		*/
	    	do_view( tb3[i] );
	    	return;
		
	      case 20:			/* Install disk icon	*/
	      case 21:			/* Install application	*/
	      case 22:			/* Install Device	*/
	      case 23:			/* Remove icons		*/
	      case 24:			/* Desktop Preference	*/
	      case 25:			/* read inf file	*/
	      case 26: 			/* desktop config	*/
	      case 27:			/* save desktop.inf	*/	    
	      case 28:			/* print screen		*/
	      case 29:			/* set blt		*/
	      case 30:			/* cjg - 06/19/92  Set Video	*/
	    	do_opt( tb3[i] );
	    	return;

	    }/* switch */

	    break;
	  }
	}

					/* 7/16/92 */
	if ( ( ( gl_vdo >> 16 ) & 0xFFFFL ) <= 0x02 )
	{
	  if ( loop_find( key, altnum, &i ) )
	  {
	    if ( restable[i] )
	    {
	      if ( app_reschange( i + 1 ) )
	      {
	        d_exit = L_CHGRES;
	        return;
	      }
	    }	 		
	  }
	}

					/* open a disk drive	*/
	if ( loop_find( key, keytable, &i ) )
	{
	  if ( win )
	    clr_xwin( win, TRUE );
hx_1:	  strcpy( wildext, buffer );
	  buffer[0] = i + 'A';	
	  open_disk( 0, buffer, TRUE );
	  return;
	}

	if ( loop_find( key, contable, &i ) )
	{
	  if ( ch_drive( i + 'A' ) )
	  {
	    if ( win )	/* replace top window	*/
	    {		
	      strcpy( win->w_path, win->w_buf );
	      strcpy( g_name( win->w_path ), buffer );
	      strcpy( wildext, win->w_path );
	      win->w_path[0] = i + 'A';
	      rep_path( buffer, win->w_path );	
	      if ( !up_win( win, FALSE ) )
	        strcpy( win->w_buf, win->w_path );
	      return;
	    }
	    else	/* open a window	*/	
	      goto hx_1;
	  }
	}

	if ( win )			/* there is a window	*/
	{
	  if ( loop_find( key, arrowtab, &i ) )
	  {
	     msgbuff[0] = WM_ARROWED;
	     msgbuff[3] = win->w_id;
	     msgbuff[4] = arrowimg[i];
	     do_scroll( msgbuff );
	     return;	      
	  }
	}          

	if (item == 0x3e )		/* >	*/
	{
	  pri_win();
	  return;
	}

	if ( key == 0x6200 )		/* help		*/
	{
	   if ( fmdodraw( HELP1, -1 ) == MOREHELP )
	     fmdodraw( HELP2, -1 );
	   return;
	}

	if ( item == 0x0D )		/* return		*/
	{
	  clr_allwin();			/* deselect all items	*/	
	  clr_dicons();
	}

	if ( item == 0x1B )		/* escape		*/
	{
	  if ( win )			/* update top window	*/
	    up_win( win, TRUE );
	}
}


/*	Set file option		*/

foption( win )
	REG WINDOW	*win;
{
	REG OBJECT	*obj;
	BYTE		buffer[14];
	BYTE		buf2[14];
	BYTE		buf1[14];

	obj = get_tree( FILEOPTI );
	save_ext( win->w_path, buf2 );
	strcpy( buf2, buf1 );
	xinf_sset( obj, OPTNAME, buf2 );
	if ( fmdodraw( FILEOPTI, 0 ) == OPTOK )
	{
	  inf_sget( obj, OPTNAME, buffer );
	  unfmt_str( buffer, buf2 );
	  if ( !buf2[0] )
	    strcpy( getall, buf2 );

	  if ( !strcmp( buf1, buf2 ) )
	  {
	    rep_path( buf2, win->w_path );
	    up_win( win, FALSE ); 
	  }
	}
}


do_scroll( msgbuff )
	WORD	msgbuff[];
{
	REG WORD	act;
	REG WINDOW	*win;
	WORD		bdown,x,y;

	act = msgbuff[4];
	
	if ( win = get_win( msgbuff[3] ) )
	{
	  switch( act )
	  {
	    case 1:			/* page down		*/
	    case 0:			/* page up		*/
	      srl_row( win, win->w_xrow, ( act == 1 ) ? SDOWN : SUP );
	      break;

	    case 3:			/* arrow down		*/
	    case 2:			/* arrow up		*/
	      srl_row( win, 1, ( act == 2 ) ? SUP : SDOWN );
	      break;

	    case 5:			/* page left or right	*/
	    case 4:
	      srl_col( win, win->w_xcol, ( act == 4 ) ? SRIGHT : SLEFT );
	      break;

	    case 7:
	    case 6:			/* scroll left		*/
	      srl_col( win, 1, ( act == 6 ) ? SRIGHT : SLEFT );
	      break;
	  } 
	}
}



/*	Do the option menu	*/

do_opt( msgbuff )
	WORD	msgbuff;
{
	REG OBJECT	*obj;
	WORD		ret,button,handle;
	BYTE		buffer[16];
	BYTE		*str;

	switch( msgbuff )
	{
	  case IDSKITEM:			/* install disk icon	*/
	    if ( x_status )
	    {
	      if ( x_type == DESKICON )
	        goto opt1;
	      else
		goto opt2;
	    }

	    ret = do1_alert( ICONTYPE );
	    if ( ret == 2 )
opt2:	      ins_wicons();
	    if ( ret == 1 )
opt1:	      ins_icons();

	    break;

	  case IAPPITEM:
	    if ( x_first( &str, &button ) )
	      mins_app();		/* cjg - 07/07/92 */
/*	      ins_app();	*/
	    break;

	  case INSDISK:
	    ins_drive();
	    return;
	
	  case REMVICON:		/* remove icon		*/
	    rm_icons();
	    break;

	  case PREFITEM:		/* desktop preference	*/
	    mdesk_pref();		/* cjg 07/07/92 */
/*	    desk_pref();	*/
	    break;

	  case READINF:
	    strcpy( "C:\\*.INF", path1 );
	    path1[0] = ( isdrive() & 0x04 ) ? 'C' : 'A';
	    strcpy( &infpath[3], buffer );	
	    fsel_exinput( path1, buffer, &button, get_fstring( SINF) );
	    if ( button )
	    {
	      desk_wait( TRUE );
	      rep_path( buffer, path1 );
	      handle = Fopen( path1, 0x00 );
	      if ( handle > 0 )
	      {
	        bfill( INFSIZE, 0, afile );
	        Fread( handle, (LONG)INFSIZE, afile ); 	
		Fclose( handle );
		if ( ( afile[0] == '#' ) && ( afile[1] == 'a' ) )
		{
	          shel_put( afile, INFSIZE );	/* copy to the aes buffer */
	    	  d_exit = L_READINF;
		  wait_msg();
		  strcpy( path1, inf_path );	/* new inf path	*/
		}
		else
		  do1_alert( ILLMAT );
	      }
	      else
		fill_string( path1, FNOTFIND );

	      desk_wait ( FALSE );
	    }

	    break;
	
	  case MEMMENU:
	    mv_desk();			/* cjg - 07/07/92 */
/*	    av_desk();	*/
	    break;


	  case SAVEITEM:		/* save desktop		*/
	    if ( do1_alert( SAVETOP ) == 1 )
	      save_inf( TRUE );
	
	    break;

#if 0	/* take out for sparrow	*/

	  case PRINTITE:		/* print screen		*/
	    if ( !( menu_addr[PRINTITE].ob_states & DISABLED ) )
	    {
	      if ( do1_alert( PRINTTOP ) == 1 )
	      {
	        desk_wait( TRUE );
	        v_hardcopy();
	        desk_wait( FALSE );
	      }
	    }

	    break;

	  case BITBLT:
	    if ( m_cpu != 30 )
	      cbit_save = !cbit_save;
	    else
	      s_cache = !s_cache;

	    ch_cache( TRUE );
	    break;		  	
#endif
	  case VIDITEM: 
	    if ( set_video() )
	      d_exit = L_CHGRES;
	    break;
	}
}


/*	Do the sorting menu	*/

do_view( msgbuff )
	WORD	msgbuff;
{
	WORD		mode,i;

	switch( msgbuff )
	{
	  case SCOLTYPE:
	    col_pa_pref( );
	    return;

	  case SIZEFIT:			/* size to fit	*/
	    s_stofit = !s_stofit;
	    sort_show( 0, TRUE );
	    goto v_4;

	  case ICONITEM:		/* show as icon	*/
	    mode = S_ICON;
	    goto v_1;
 
	  case TEXTITEM:		/* show as text	*/
	    mode = S_TEXT;

v_1:	    i = 0;	    
	
	    if ( mode == s_view )	/* No change	*/
	      break;

	    s_view = mode;
	    sort_show( FALSE, TRUE );
	    break;

	  case NAMEITEM:
	    mode = S_NAME;
	    goto v_2;
	
	  case DATEITEM:
	    mode = S_DATE;
	    goto v_2;

	  case SIZEITEM:
	    mode = S_SIZE;
	    goto v_2;

          case TYPEITEM:
            mode = S_TYPE;
	    goto v_2;

	  case NOSORT:
	    mode = S_NO;
	
v_2:	  
	  i = 3;	
  	  if ( mode == s_sort )		/* No change	*/
	    break;
	  s_sort = mode;
	  sort_show( s_sort, FALSE );
	  break;
	}

v_3:	while( xxxview[i] )
	  menu_icheck( menu_addr, xxxview[i++], 0 );
	
	menu_icheck( menu_addr, msgbuff, 1 );
v_4:
	menu_icheck( menu_addr, SIZEFIT, s_stofit );
}


/*	Do the file menu	*/

	WORD
do_file( msgbuff )
	WORD	msgbuff;
{
	OBJECT		*obj;
	WORD		ret,type;
	REG WINDOW	*win;
	BYTE		buffer[14];
	BYTE		buf2[14];
	BYTE		*str;
	BYTE		*str1;

	win = get_top();

	switch( msgbuff )
	{
	  case OPENITEM:
	    if ( o_status )
	      open_item( o_item, o_type, o_win );
	    else
	      launch_pref();

	    break;

	  case SHOWITEM:
	    show_item( );
	    break;

	  case SEAMENU:		/* search file menu	*/
	    if ( ( x_status ) || ( w_gfirst() ) )
	    {
	      obj = get_tree( SEAFILE );
	      inf_sset( obj, SFILE, Nostr );
	      if ( fmdodraw( SEAFILE, SFILE ) == SEAOK )
	      {
	        inf_sget( obj, SFILE, buffer );
	        unfmt_str( buffer, buf2 );
	        if ( buf2[0] )
	          sea_file( buf2 );
	      }
	    }
		
	    break;

	  case DELMENU:
	    if ( !( menu_addr[DELMENU].ob_states & DISABLED ) )
	    {
	      if ( x_status )
	      {
	        if ( x_type == DESKICON )	/* desktop icons	*/
	        {
	          ret = do1_alert( DELITEM );
	          if ( ret == 1 )		/* remove		*/
	          {
		    rm_icons();
		    break;
		  }

	          if ( ret == 3 )		/* cancel		*/
		    break;
		}
	        file_op( Nostr, OP_DELETE );
	      }	
	    }

	    break;

	  case NEWFITEM:
	    if ( win )
	      newfolder( win );	  	
	    break;
		
	  case CLSFITEM:
	    if ( win )
	      close_path( win );	/* close one path	*/
	    break;
		
	  case CLSWITEM:		/* close the top window	*/
	    close_top();
	    break;

	  case BOTTOP:			/* bring bot win to top	*/
	    bottop();
	    break;

	  case SELALL:
	    sel_all();
	    break;

	  case EXTMENU:
	    if ( win )
	      foption( win );

	    break;

	  case FORMITEM:
	    str = "A";

	    if ( ( x_status ) && ( x_type == DESKICON ) )
	    {
	      ret = x_first( &str1, &type );
	      while ( ret )
	      {
		if ( type == DISK )
		{
	          if ( ( *str1 == 'A' ) || ( *str1 == 'B' ) )
		  {
		    str = str1;
		    break;
		  }
		}
	        ret = x_next( &str1, &type );	
	      }
	    }
		
	    fc_start( str, CMD_FORMAT );
	    clr_dicons( );
	    break;
	}
}	


/*	Handle Menu	*/

	WORD
hd_menu( msgbuff )
	REG WORD	msgbuff[];
{
	switch( msgbuff[3] )
	{
	  case DESKMENU:
/*	    roton();	*/
	    fmdodraw( ADDINFO, 0 );
/*	    rotoff();	*/
	    break;
	
	  case FILEMENU:
	    do_file( msgbuff[4] );
	    break;

	  case VIEWMENU:
	    do_view( msgbuff[4] );
	    break;

	  case OPTNMENU:
	    do_opt( msgbuff[4] );
	    break; 	
	}

	menu_tnormal( menu_addr, msgbuff[3], 1 );
}


/*	Handle all the different message	*/

	VOID
hd_msg( msgbuff )
	REG WORD	msgbuff[];
{
	REG WORD	handle;
	REG WINDOW	*win;	
	REG OBJECT	*obj;
	WORD	shrink,x,y,w,h;
	GRECT	pt;
	GRECT	*pc;
	
	if ( msgbuff[0] == MN_SELECTED )
	  hd_menu( msgbuff );
	else
	{
	  pc = &msgbuff[4];	/* pc == msgbuff[4,5,6,7]	*/
	  handle = msgbuff[3];

	  if ( !( win = get_win( handle ) ) )
	    return;

	  obj = win->w_obj;

	  switch( msgbuff[0] )
	  {
	    case WM_REDRAW:
	    case WM_USER:
	      do_redraw( handle, pc, 0 );
	      return;

	    case WM_TOPPED:
	    case WM_NEWTOP:
	      clr_allwin();
	      wind_set( handle, WF_TOP, 0, 0, 0, 0 );
	      make_top( win );
	      return;
	  }	  

	  if ( handle != get_top()->w_id )
	    return;

	  switch( msgbuff[0] )
	  {
	    case WM_CLOSED:		/* close one path	*/
	      close_path( win );
              break;

	    case WM_ARROWED:
	      do_scroll( msgbuff );			
	      break;
	
            case WM_HSLID:
	      srl_hzbar( win, msgbuff[4] );
	      break;
	
	    case WM_VSLID:
	      srl_verbar( win, msgbuff[4] );
	      break;

	    case WM_MOVED:		/* set the current x,y,w,h	*/
	      do_xyfix( &msgbuff[4] );
	      wind_set( handle, WF_CURRXYWH, msgbuff[4], msgbuff[5], 
			msgbuff[6], msgbuff[7] );

					/* set the position offset	*/
	      obj[0].ob_x += msgbuff[4] - win->w_sizes.x;
	      obj[0].ob_y += msgbuff[5] - win->w_sizes.y;
	      rc_copy( pc, &win->w_sizes );

	      wind_get( handle, WF_WORKXYWH, &msgbuff[4], &msgbuff[5], 
			&msgbuff[6], &msgbuff[7] );

	      rc_copy( pc, &win->w_work );
	      break;	
	
	    case WM_FULLED:
	      wind_get( handle, WF_CURRXYWH, &msgbuff[4], &msgbuff[5],
	                &msgbuff[6], &msgbuff[7] );

					/* already in full size		*/
	      if ( rc_equal( &msgbuff[4], &full ) )
	      {				/* so shrink it			*/
	        wind_get( handle, WF_PREVXYWH, &msgbuff[4], &msgbuff[5],
	                &msgbuff[6], &msgbuff[7] );
		form_dial( 2, pc->x, pc->y, pc->w, pc->h,
			      full.x, full.y, full.w, full.h );	 
	      }
	      else
	      {
	        rc_copy( &full, pc );	/* calculate the center point	*/
		rc_copy( &win->w_sizes, &pt );
	        rc_center( &pt, &pt );	
					/* form grow box		*/
		form_dial( 1, pt.x, pt.y, pt.w, pt.h, pc->x, pc->y, pc->w, pc->h );	 
	      }

            case WM_SIZED:
	      do_xyfix( &msgbuff[4] );
	      wind_set( handle, WF_CURRXYWH, msgbuff[4], msgbuff[5], 
			msgbuff[6], msgbuff[7] );

	      rc_copy( pc, &win->w_sizes );

      	      wind_get( handle, WF_WORKXYWH, &obj->ob_x, &obj->ob_y,
			&obj->ob_width, &obj->ob_height );

	      shrink = FALSE;

	      if ( ( obj->ob_width < win->w_work.w ) &&
		   ( obj->ob_height <= win->w_work.h ) )
		shrink = TRUE;

	      if ( ( obj->ob_height < win->w_work.h ) &&
		   ( obj->ob_width <= win->w_work.w ) )
		shrink = TRUE;
 
	      rc_copy( &obj->ob_x, &win->w_work );	

	      ch_path( win );

	      if ( shrink )
	        x = win->w_xcol;
	 
	      if ( s_stofit )		/* size to fit		*/
	        view_fixmode( win );

	      view_adjust( win );	/* adjust parameter	*/

	      if ( s_stofit && shrink )
	      {
		if ( x != win->w_xcol )
	          do_redraw( win->w_id, &full, 0 );
	      }
					
	      break;
			  	
	    default:
	      break;
	  }
       	}
}

	
/*	Handle all the events		*/

	VOID
actions( )
{
	WORD	event,kstate,kreturn,button,clicks;
	WORD	mx,my;
	WORD	msgbuff[8];	

	d_exit = L_NOEXIT;

	while( d_exit == L_NOEXIT )
	{
	  menu_verify();		
	  q_write();		/* update inf file	*/
	  event = evnt_multi( MU_MESAG|MU_BUTTON|MU_KEYBD,2,1,1,
			      0,0,0,0,0,
			      0,0,0,0,0,
			      msgbuff,	/* mesaage buffer	*/
			      0,0,	/* timer counter	*/
			      &mx,&my,
			      &button,
			      &kstate,
			      &kreturn,
			      &clicks );

	  wind_update( TRUE );

	  if ( event & MU_MESAG )
	    hd_msg( msgbuff );
	
	  if ( event & MU_BUTTON )
	    hd_button( clicks, kstate, mx, my );

	  if ( event & MU_KEYBD )
	    hd_keybd( kreturn );
	
	  wind_update( FALSE );

	}/* while */
}


/*	Find out available memory	*/

	LONG
av_mem()
{
	REG BYTE	*start;
	REG BYTE	*addr;
	REG BYTE	**new;
	LONG		total,size;
	
	total = 0;
	start = (BYTE*)0;

	while( TRUE )
	{
	  size = Malloc( 0xFFFFFFFFL );
	  if ( size >= 4 )
	  {
	    addr = Malloc( size );
	    total += size;
	    if ( !start )
	      start = addr;
	    else
	      *new = addr;

	    new = addr;	    
	  }
	  else
	  {
	    if ( start )
	      *new = (BYTE*)0;
	    break;
	  }
	}

	if ( start )
	{
	  new = start;

	  while( new )
	  {
	    addr = *new;
	    Mfree( new );
	    new = addr;	
	  }
	}

	return( total );
}

#if 0
/*	Find out available memory	*/

av_desk()
{
	REG OBJECT	*obj;
	REG LONG	f;
	REG WORD	fi,i,menui,which;
	REG APP		*app;
	WORD		len;
	APP		*xapp;
	BYTE		*str;
	BYTE		temp[MAXMENU];
	OBJECT		*obj1;
	BYTE		buf[2];


	obj = get_tree( SSYSTEM );
	obj1 = menu_addr;

	for ( i = 0; i < MAXMENU; i++ )	/* save a copy	*/
	  temp[i] = mentable[i];	

	(TEDINFO*)(obj[MKSTR].ob_spec)->te_ptext = obj1[tb3[0]].ob_spec;
	buf[1] = 0;
	buf[0] = mentable[0];
	inf_sset( obj, MKKEY, buf );
	menui = 0;

	obj[AP1].ob_state = NORMAL;
	obj[WI1].ob_state = NORMAL;
	obj[DEFFULL].ob_state = NORMAL;
	obj[DEFFILE].ob_state = NORMAL;

	if ( s_defdir )				/* set the full path	*/ 
	  obj[AP1].ob_state = SELECTED;		/* application		*/
	else
	  obj[WI1].ob_state = SELECTED;		/* application		*/

	if ( s_fullpath )
	  obj[DEFFULL].ob_state = SELECTED;
	else
	  obj[DEFFILE].ob_state = SELECTED;

	f_str( obj, SDMEMORY, av_mem() );
	*(BYTE*)((TEDINFO*)(obj[SDKEY].ob_spec)->te_ptext) = 0;

				/* save the original pointer	*/
	str = (TEDINFO*)(obj[SDFILE].ob_spec)->te_ptext;
	len = strlen( str );	
	*str = 0;

	app = (APP*)0;
	which = SDDOWN;

 	f = 0;
	fm_draw( SSYSTEM );		/* save the string	*/
	goto ad_2;

	while( TRUE )
	{
ad_5:	  which = xform_do( obj, MKKEY );

	  if ( ( which == MKUP ) || ( which == MKDOWN ) || ( which == SDOK ) )
	  {
	      inf_sget( obj, MKKEY, buf );
	      buf[0] = toupper( buf[0] );
	      if ( buf[0] )
	      {
	        for ( i = 0; i < MAXMENU; i++ )
	        {
	           if ( i == menui )
		     continue;

	          if ( mentable[i] == buf[0] )
	      	  {
		    if ( do1_alert( KEYUSED ) == 1 ) /* Overwrite */
		    {
		      mentable[i] = 0;	
		      continue;
		    }

		    if ( which == SDOK )
	  	      draw_fld( obj, SDOK );

		    goto p_2;
	          }
	        }		  	
	      }
	
	      mentable[menui] = buf[0];
	  }	
	
ad_2:	  switch( which )
	  {
	    case CLRKEYS:
	      for ( i = 0; i < MAXMENU; i++ )
		mentable[i] = 0;

	      put_keys();
	      goto p_11;

	    case MKUP:		/* check for keys	*/
	      if ( menui )
	      {
	 	menui--;
		goto p_11;
	      }

	      break;

	    case MKDOWN:
	      if ( ( menui + 1 ) < MAXMENU )
	      {
		menui++;
p_11:
	        ch_key( menui );
	        (TEDINFO*)(obj[MKSTR].ob_spec)->te_ptext = obj1[tb3[menui]].ob_spec;
	        draw_fld( obj, MKSTR );
p_2:	
	        buf[1] = 0;
	        buf[0] = mentable[menui];
	        inf_sset( obj, MKKEY, buf );
	        draw_fld( obj, MKKEY );		
	      }
	
	      break;

	    case SDCANCEL:		/* restore the menu key table */
	      for ( i = 0; i < MAXMENU; i++ )
	        mentable[i] = temp[i];			

	       goto ad_1;

	    case SDOK:
	      if ( obj[AP1].ob_state & SELECTED )
		s_defdir = TRUE;
	      else
		s_defdir = FALSE;

	      if ( obj[DEFFULL].ob_state & SELECTED )
	        s_fullpath = TRUE;
	      else
		s_fullpath = FALSE;

	      goto ad_1;	 

	    case SDUP:
	      f--;
	      if ( f )
	        goto ad_3;  	
	      else
		f++;
	
	      break;
	    
	    case SDDOWN:
	      f++;
	      if ( f <= 20 )
	      {
ad_3:	        if ( !( xapp = app_key( ftab[f] ) ) )
		  goto ad_2;
	        else
	        {
		  app = xapp;
		  fi = 0;
		  (TEDINFO*)(obj[SDFILE].ob_spec)->te_ptext = app->a_name;
		  draw_fld( obj, SDFILE );
		  f_str( obj, SDKEY, f );
		  draw_fld( obj, SDKEY );
	        }		
	      }
	      else
		f--;

	      break;

	    case SDLEFT:		
	    case SDRIGHT:
	      if ( !app )
		continue;
		
	      if ( which == SDLEFT )
	      {
	        if ( fi > 0 )
		  fi--;
	        else
		  continue;
	      }
	      else
	      {
	        fi++;
	        if ( strlen( &app->a_name[fi] ) < len )
	        {
		  fi--;
		  continue;
	        }
	      }
ad_4:
	      (TEDINFO*)(obj[SDFILE].ob_spec)->te_ptext = &app->a_name[fi];
	      draw_fld( obj, SDFILE );
	      goto ad_5;

	  }/* switch */

	  cl_delay();
	}

ad_1:				/* restore the pointer	*/
	put_keys();
	(TEDINFO*)(obj[SDFILE].ob_spec)->te_ptext = str;
	*str = 1;		
	do_finish( SSYSTEM );
}
#endif
