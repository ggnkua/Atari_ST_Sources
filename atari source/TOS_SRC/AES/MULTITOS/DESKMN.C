/* DESKMN.C
 * =================================================================
 * DESCRIPTION: New Desk Menu Functions using Popups.
 *
 * DATE
 * 06/15/92  - cjg Created - preserved original routines.
 * 06/24/92  - cjg - Install Application works
 *		   - Desktop Configuration works
 *		   - Set Preferences works
 *		   - Set Video works - requires more data for new modes
 * 06/25/92  - cjg - install popup for defining keystrokes.
 * 07/09/92  - cjg - Set Video - 
 *		     If we're in TRUE COLOR, disable 80 column menu item
 *		     If we're in 80 column mode, disable TRUE COLOR menu item
 * 07/10/92  - cjg - Removed changes for 07/09/92
 * 07/13/92  - cjg - put in modecode routines - needs quite a few things
 *		     from kbad and townsend
 * 07/14/92  - cjg - Checked if the pen number for an object that is 3D
 *		     is greater than or equal to the number of pens.
 *		     if it is, then set pen number to pen zero.
 * 		   - Don't allow 40 COLUMN MONOCHROME
 *		   - Don't allow 80 COLUMN, VGA, TRUE COLOR
 * 07/15/92  - cjg - The No Budget, IOU State, DAY 15
 *		   - _VDO Cookie for SPARROW Video is 3 for the upper word
 * 07/17/92  - cjg - Set_Video() returns TRUE and shoves set_mode() into
 *		     'd_rezword' if we want to change resolutions.
 *		   - Returns FALSE if no change or if we are not
 *		     running SPARROW video.
 *		   - Uses cookie to keep and maintain original
 *		     method of changing resolutions on an ST/TT
 * 07/21/92  - cjg - Sparrow Set_Video()
 *		   - If in Sparrow mode, ALWAYS come up first in
 *		     the Sparrow Video Dialog Box.
 *		   - Even if we're a Monochrome monitor
 * 07/31/92  - cjg - Many Changes...read ....
 *		   - use mon_type() to determine type of monitor
 *		   - Removed Sparrow Video Check, must always be on
 *		     a Sparrow
 *		   - Remove TT High
 *		   - ST/TT Dialog Box
 *		     -Do not initialize to any mode
 *		     -Monochrome monitor, disable everything
 *		     -Redid the layout for this dialog box.
 * 08/03/92  - cjg - Hide TTLOW and TTMED on a TV
 *		   - fixed ST Compatibility set_mode variables
 * 		   - Added a mem-check() to test if enough memory
 *		     is available for switching resolutions.
 * 08/05/92  - cjg - Change all Deselect() to XDeselect()
 *		   - Change all Select() to XSelect()
 *		   - Remove TTMED and TTLOW
 * 08/06/92  - cjg - Changed XDeselect() and XSelect() to
 *		     redraw from the root and to increase the
 *		     redraw area by 2 pixels.
 *		   - Changed Selecting Titles to draw_fld()
 *		   - Enabled Arrow Buttons to INVERT when Selected.
 *		   - Buttons remain selected until mouse button is released.
 * 08/11/92  - cjg - When a function key is already used, and cancel is pressed
 *		     deselect the OK button properly.
 * 08/11/92  - cjg - Fixed bug with objc_find() inside ChkTouchButton()
 * 08/17/92  - cjg - Fixed bug - System Configuration
 *		   - Used wrong object number..
 * 09/21/92  - cjg - Configuration Popup - Look for longest string first
 * 09/24/92  - cjg - Fixed bug with MKUP and MKDOWN pausing for a scroll.
 * 02/17/93  - cjg - Converted to Lattice C 5.51
 * 05/06/93  - ers - Added Memory popup in Install Application dialog
 */


/* INCLUDES
 * ==================================================================
 */

#include "portab.h"
#include "machine.h"
#include "obdefs.h"
#include "deskdefi.h"
#include "deskwin.h"
#include "osbind.h"
#include "vdomode.h"
#include "deskusa.h"
#include "extern.h"
#include "mn_tools.h"
#include "pdesk.h"
#include "pmisc.h"

/* EXTERNS
 * ==================================================================
 */
EXTERN	VOID	menu_icheck();

EXTERN  WORD	gl_restype;
EXTERN  WORD	gl_rschange;
EXTERN	WORD	d_exit;
EXTERN	LONG	gl_vdo;
EXTERN	WORD	pref_save;
EXTERN	WORD	m_cpu;
EXTERN	WORD	s_defdir;
EXTERN	WORD	s_fullpath;
EXTERN	WORD	numicon;
EXTERN	WORD	x_status;
EXTERN	WORD	x_type;
EXTERN	BYTE	mkeys[];
EXTERN	BYTE	restable[];
EXTERN	WORD	ftab[];

EXTERN	APP	*app_xtype();
EXTERN	BYTE	*scasb();
EXTERN	APP	*app_alloc();
EXTERN  LONG	av_mem();

EXTERN	WORD	font_save;
EXTERN	WORD	m_st;
EXTERN  WORD	tb3[];

EXTERN  BYTE	mentable[];

EXTERN  UWORD    d_rezword;	/* set_mode() value ( system ) */
EXTERN	WORD	 d_multi;
EXTERN  VOID XDeselect();

EXTERN  WORD	strlen();	/* cjg 09/21/92 */

/* DEFINES
 * ==================================================================
 */
#define Srealloc( a )   gemdos( 0x15, a )
#define VgetSize( a )   xbios( 91, a )





/* GLOBALS
 * ==================================================================
 */
MENU Menu, MData;
OBJECT mtree[ MAXMENU + 2 ];	/* cjg - 07/10/92 moved to global */


/* ChkTouchButton
 * ================================================================
 * Given the tree and the button, the mouse is tracked until an up button.
 * This is used for buttons that are Touch Exits
 * RETURNS: TRUE - the mouse was released and is within the button.
 *          FALSE - the mouse was released and is NOT within the button.
 */
WORD
ChkTouchButton( tree, button )
OBJECT *tree;
WORD   button;
{
    MRETS mk;
    WORD  dummy; 
    WORD  obj;

    wind_update( BEG_MCTRL );
    XSelect( tree, button );			

    graf_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );
    while( mk.buttons )
    {
      obj = objc_find( tree, ROOT, MAX_DEPTH, mk.x, mk.y );
      if( obj != button )
      {
         if( tree[ button ].ob_state & SELECTED )
	     XDeselect( tree, button );
      }
      else
      {
         if( !( tree[ button ].ob_state & SELECTED ) )
	     XSelect( tree, button );
      }
      graf_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );
    }
    evnt_button( 1, 1, 0, &dummy, &dummy, &dummy, &dummy );
    obj = objc_find( tree, ROOT, MAX_DEPTH, mk.x, mk.y );
    if( obj != button )
       XDeselect( tree, button );

    wind_update( END_MCTRL );
    return( obj == button );
}




/* mv_desk()
 * ===============================================================
 * Desktop Configuration modified to include Pop-ups.
 */
	VOID
mv_desk( VOID )
{
	REG OBJECT	*obj;
	REG LONG	f;
	REG WORD	fi,i,which;
	WORD		menui;
	REG APP		*app;
	WORD		len;
	APP		*xapp;
	BYTE		*str;
	BYTE		temp[MAXMENU];
	OBJECT		*obj1;
	BYTE		buf[2];

	OBJECT          *dtree;
	WORD		dstart;
	WORD		istart;
	MRETS		mk;
	WORD		skip_flag;
	LONG		old_f;		      /* cjg 09/24/92 */

	skip_flag = TRUE;
	obj = get_tree( MNSYSTEM );	      /* Get config tree  */
	obj1 = menu_addr;		      /* Get Menu Bar Tree*/

	dtree = get_tree( MNMENU );	      /* Get Popup menu Tree */


	for ( i = 0; i < MAXMENU; i++ )	      /* save a copy of keystrokes*/
	  temp[i] = mentable[i];	

	/* Initialize the First Menu Item Keystroke */
	((TEDINFO*)(obj[MKITEM].ob_spec))->te_ptext = obj1[tb3[0]].ob_spec;
	buf[1] = 0;
	buf[0] = mentable[0];
	inf_sset( (LONG)obj, MKKEYS, buf );
	menui = 0;

	/* Initialize the Popup Menus - CheckMarks and Object States */
        menu_icheck( dtree, SDAPP, FALSE );
        menu_icheck( dtree, SDTOP, FALSE );
        menu_icheck( dtree, SIFULL, FALSE );
	menu_icheck( dtree, SIFILE, FALSE );

	dtree[ SDAPP ].ob_state  = NORMAL;	/* Clear the menu states*/
        dtree[ SDTOP ].ob_state  = NORMAL;
	dtree[ SIFULL ].ob_state = NORMAL;
	dtree[ SIFILE ].ob_state = NORMAL;

	/* Initialize the starting object and button text of the default menu*/
	if ( s_defdir )				/* set the full path	*/ 
        {
	  dstart = SDAPP;			/* Application */
          obj[SDBUTTON].ob_spec = ( LONG )get_fstring( FSAPP );
        }
	else
        {
	  dstart = SDTOP;			/* Top Window  */
          obj[SDBUTTON].ob_spec = ( LONG )get_fstring( FSTOP );
        }
	menu_icheck( dtree, dstart, 1 );


	/* Initialize the starting object and button text of the path menu*/
	if ( s_fullpath )			/* Set input parameter  */
        {
	  istart = SIFULL;			/* Full Path   */
          obj[SIBUTTON].ob_spec = ( LONG )get_fstring( FSFULL );
	}
	else
        {
	  istart = SIFILE;			/* File Name   */
          obj[SIBUTTON].ob_spec = ( LONG )get_fstring( FSFILE );
        }
	menu_icheck( dtree, istart, 1 );


	/* Initialize the Free Memory String */
	f_str( obj, MKMEMORY, av_mem() );
	*(BYTE*)(((TEDINFO*)(obj[MFKEY].ob_spec))->te_ptext) = 0;

	/* save the original pointer	*/
	str = ( BYTE *)((TEDINFO*)(obj[MFFILE].ob_spec))->te_ptext;
	len = strlen( str );	
	*str = 0;

	app = (APP*)0;
	which = MFDOWN;

 	old_f = f = 0L;
	dr_dial_w( MNSYSTEM, FALSE, 0 );		/* save the string	*/


	for( f = 1L; f <= 20L; f++ )		/* cjg 09/24/92 */
	{
          if( app_key( ftab[f] )  )		/* ALL THIS.... */
	  {
	    old_f = f;
	    break;
	  }
	}
	f = 0L;					/* cjg 09/24/92 */

	goto ad_2;

	while( TRUE )
	{
ad_5:	  which = form_do( obj, MKKEYS ) & 0x7fff;
	  obj[ which ].ob_state &= ~SELECTED;

	  if ( ( which == MKUPS ) || ( which == MKDOWNS ) || ( which == MOK ) )
	  {
	      inf_sget( (LONG)obj, MKKEYS, buf );
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

		    if ( which == MOK )
	  	      draw_fld( obj, MOK );

		    goto p_2;
	          }
	        }		  	
	      }
	
	      mentable[menui] = buf[0];
	  }	
	
ad_2:	  switch( which )
	  {
	    case MKITEM:  if( DoMKItems( obj, MKITEM, &menui ))
			    goto p_11;
			  break;

	    case MKCLEAR:
	      if( ChkTouchButton( obj, MKCLEAR ))
	      {
		
	        for ( i = 0; i < MAXMENU; i++ )
		  mentable[i] = 0;

	        put_keys();
		XDeselect( obj, MKCLEAR );
	        goto p_11;	
	      }
	      break;

	    case MKUPS:		/* check for keys	*/

cg_2:
	      if ( menui )
	      {
	        XSelect( obj, which );	/* cjg 08/06/92 */
	 	menui--;
		goto p_11;
	      }
	      wait_up();
	      XDeselect( obj, which );	/* cjg 08/06/92 */
	      break;

	    case MKDOWNS:

cg_3:	      
	      if ( ( menui + 1 ) < MAXMENU )
	      {
	        XSelect( obj, which );	/* cjg 08/06/92 */
		menui++;
p_11:
	        ch_key( menui );
	        ((TEDINFO*)(obj[MKITEM].ob_spec))->te_ptext = obj1[tb3[menui]].ob_spec;
	        draw_fld( obj, MKITEM );
p_2:	
	        buf[1] = 0;
	        buf[0] = mentable[menui];
	        inf_sset( (LONG)obj, MKKEYS, buf );
	        draw_fld( obj, MKKEYS );		
		cl_delay();

	        /* cjg 08/06/92 - Check if the buttons are still down */
	        graf_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );
		if( mk.buttons )
		{

		   if( which == MKUPS )
		      goto cg_2;
		   
		   if( which == MKDOWNS )
		      goto cg_3;
		}
	      }
	      wait_up();
	      XDeselect( obj, which );	/* cjg 08/06/92 */	
	      break;

	    case SDBUTTON:  /* Default Dir: */
		  	    DoPopup( obj, SDBUTTON, SDTITLE, dtree,
				     SDBASE, dstart, &dstart, FALSE,
				     SDAPP, FSAPP, FALSE );
			    break;

	    case SIBUTTON:  /* Parameter: */
			    DoPopup( obj, SIBUTTON, SITITLE, dtree,
			  	     SIBASE, istart, &istart, FALSE,
				     SIFULL, FSFULL, FALSE );
			    break;

	    case MCANCEL:		/* restore the menu key table */
	      for ( i = 0; i < MAXMENU; i++ )
	        mentable[i] = temp[i];			

	       goto ad_1;

	    case MOK:
	      s_defdir = (( dstart == SDAPP ) ? ( TRUE ) : ( FALSE ) );
	      s_fullpath = (( istart == SIFULL ) ? ( TRUE ) : ( FALSE ));
	      goto ad_1;	 

	    case MFUP:

cg_4:
	        f--;
	        if ( f )
	          goto ad_3;  	
	        else
		{
		  if( old_f )	/* cjg 09/24/92 */
		    f = old_f;
		  else
		    f++;
		}
	        wait_up();
		XDeselect( obj, which );	/* cjg 08/06/92 */
	        break;
	    
	    case MFDOWN:

cg_5:

	        f++;
	        if ( f <= 20L )
	        {
ad_3:	          if ( !( xapp = app_key( ftab[f] ) ) )
		  {
		    goto ad_2;
		  }
	          else
	          {
		    if( !skip_flag )			/* Silly thing  */
		    {
		       old_f = f;			/* cjg 09/24/92 */
		       XSelect( obj, which );		/* cjg 08/06/92 */
		    }
		    app = xapp;
		    fi = 0;
		    ((TEDINFO*)(obj[MFFILE].ob_spec))->te_ptext = ( LONG )app->a_name;
		    draw_fld( obj, MFFILE );
		    f_str( obj, MFKEY, f );
		    draw_fld( obj, MFKEY );

		    if( !skip_flag )	/* Silly thing - cjg 08/06/92 */
		    {
		      cl_delay();
	              /* cjg 08/06/92 - Check if the buttons are still down */
	              graf_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );
		      if( mk.buttons )
		      {
			if( which == MFUP )
			   goto cg_4;
			if( which == MFDOWN )
			   goto cg_5;
		      }
		    }
	          }		
	        }
	        else
		{
		  if( old_f  )			/* cjg - 09/24/92 */
		    f = old_f;
		  else
		    f--;
		}


		if( !skip_flag )		/* Silly thing cjg -08/06/92*/
		{
		  wait_up();
		  XDeselect( obj, which );	/* cjg 08/06/92 */
		}
		skip_flag = FALSE;
	      break;

	    case MFLEFT:		
	    case MFRIGHT:

cg_1:	  

	      if( !app )
	      {
	        wait_up();
		XDeselect( obj, which ); /* cjg 08/06/92 */
		continue;
	      }
	
	      if( which == MFLEFT )
	      {
	        if ( fi > 0 )
		{
		  fi--;
		}
	        else
		{
	          wait_up();
		  XDeselect( obj, which ); /* cjg 08/06/92 */
		  continue;
		}
	      }
	      else
	      {
	        fi++;
	        if( strlen( &app->a_name[fi] ) < len )
	        {
		  fi--;
	          wait_up();
		  XDeselect( obj, which ); /* cjg 08/06/92 */
		  continue;
	        }
	      }
ad_4:
	      XSelect( obj, which );	/* cjg 08/06/92 */
	      ((TEDINFO*)(obj[MFFILE].ob_spec))->te_ptext = ( LONG )&app->a_name[fi];
	      draw_fld( obj, MFFILE );

	      /* cjg 08/06/92 - Check if the buttons are still down */
	      graf_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );
	      if( mk.buttons )
	        goto cg_1;

	      wait_up();
	      XDeselect( obj, which );	 /* cjg 08/06/92 */
	      goto ad_5;

	  }/* switch */

	  cl_delay();
	}

ad_1:				/* restore the pointer	*/
	put_keys();
	((TEDINFO*)(obj[MFFILE].ob_spec))->te_ptext = ( LONG )str;
	*str = 1;		
	do_finish( MNSYSTEM );
}




/* mins_app()
 * ===============================================================
 * Install Application using Popups
 */
	VOID
mins_app( VOID )
{
	REG OBJECT	*obj;
	REG APP		*app;
	APP		*sapp;	
	WORD		install,ret,newapp;
	WORD		cont,setdir,dofull,where;
	WORD		type,sret,icon,graphic;
	BYTE		*str;
	BYTE		buffer[8];
	LONG		l;


	OBJECT		*dtree;

	WORD		istart;		/* Current obj - Install As */
	WORD		bstart;		/* Current Obj - Boot Status*/
	WORD		fstart;		/* Current Obj - File Type  */
	WORD		dstart;		/* Current Obj - Default Dir*/
	WORD		pstart;		/* Current Obj - Parameter  */
	WORD		mstart;		/* Current Obj - Memory Limit */
        WORD		i;
	WORD		done;

	cont = TRUE;
	obj = (OBJECT*)0;
	dtree = get_tree( MNMENU );	/* Get menu Tree */	

	cont = x_first( &str, &type );
		
	while( cont )
	{
	  if ( ( type != WINICON ) && ( type != XFILE ) )
	     goto is_1;

	  app = app_xtype( str, &install );

	  if ( install )		/* Not an application	*/
	    goto is_1;

	  obj   = get_tree( MNINSAPP );


	  icon = app->a_icon;
 					/* if it is a wild card match	*/
	  if ( *scasb( app->a_name, '*' ) == '*' )	
	    newapp = TRUE;		/* then we need app 		*/
	  else
	    newapp = FALSE;

	  if ( !autofile[0] )
	    ret = FALSE;
	  else  			/* skip the graphic flag */
	    ret = strcmp( str, &autofile[3] );

	  /* Handle Boot Status */
	  sret = ret ? TRUE : FALSE;
	  dtree[ MPBAUTO ].ob_state = NORMAL;
	  dtree[ MPBNORML].ob_state = NORMAL;
	  menu_icheck( dtree, MPBAUTO, FALSE );
	  menu_icheck( dtree, MPBNORML, FALSE );
	  if( ret )
	  {
	       bstart = MPBAUTO;
               obj[MPBBUTTN].ob_spec = ( LONG )get_fstring( FSAUTO );	      
	  }
	  else
	  {
	       bstart = MPBNORML;
               obj[MPBBUTTN].ob_spec = ( LONG )get_fstring( FSNORMAL );
          }
	  menu_icheck( dtree, bstart, TRUE );


	  /* Clear the Function Key Menu */
	  for( i = MPINONE; i <= MPIF20; i++ )
	  {
	     dtree[ i ].ob_state = NORMAL;
	     menu_icheck( dtree, i, FALSE );
	  }
	

	  if ( strcmp( str, app->a_name ) )
	  { 
	    dofull = ( app->a_pref & 0x2 ) ? TRUE : FALSE; 
	    setdir = ( app->a_pref & 0x1 ) ? TRUE : FALSE;
	  }
	  else
	  {
	    dofull = s_fullpath;
	    setdir = s_defdir;
	  }


	  /* Setup the Default Dir Menu */
	  dtree[ SDAPP ].ob_state = NORMAL;
          dtree[ SDTOP ].ob_state = NORMAL;
	  menu_icheck( dtree, SDAPP, FALSE );
	  menu_icheck( dtree, SDTOP, FALSE );
	  if( setdir )
	  {  
	      dstart = SDAPP;
              obj[MPDBUTTN].ob_spec = ( LONG )get_fstring( FSAPP );
	  }
	  else
	  {
	      dstart = SDTOP;
              obj[MPDBUTTN].ob_spec = ( LONG )get_fstring( FSTOP );
	  }
	  menu_icheck( dtree, dstart, TRUE );	  



	  /* Set the Parameter Menu */
	  dtree[ SIFULL ].ob_state = NORMAL;
	  dtree[ SIFILE ].ob_state = NORMAL;
	  menu_icheck( dtree, SIFULL, FALSE );
	  menu_icheck( dtree, SIFILE, FALSE );
	  if ( dofull )
          {
	    pstart = SIFULL;
            obj[MPPBUTTN].ob_spec = ( LONG )get_fstring( FSFULL );
          }
	  else
          {
	    pstart = SIFILE;
            obj[MPPBUTTN].ob_spec = ( LONG )get_fstring( FSFILE );
	  }
	  menu_icheck( dtree, pstart, TRUE );	


	  /* Set the Document type */
	  inf_sset( (LONG)obj, MPDTYPE, ( newapp ) ? Nostr : &app->a_doc[2] );

	  /* Set the Application Name */
 	  xinf_sset( obj, MPFNAME, g_name( str ) );

	  /* Set the Arguments */
	  inf_sset( (LONG)obj, MPARGS, ( newapp ) ? Nostr : app->a_argu );
	


	  /* Clear Application Type Menu */
	  for( i = MPFTOS; i <= MPFGMTTP; i++ )
	  {
	     dtree[ i ].ob_state = NORMAL;
	     menu_icheck( dtree, i, FALSE );
	  }
	  switch ( app->a_type )
	  {
	    case PRG:	
	    case APPS:
	        ret = fstart = MPFGEM;
                obj[MPFBUTTN].ob_spec = ( LONG )get_fstring( FSGEM );
	        break;
	
            case TTP:		 	
	        ret = fstart = MPFTTP;
                obj[MPFBUTTN].ob_spec = ( LONG )get_fstring( FSTOSTTP );
	        break;
	
	    case TOS:
	        ret = fstart = MPFTOS;
                obj[MPFBUTTN].ob_spec = ( LONG )get_fstring( FSTOS );
	        break;

	    case PTP:	/* Gem takes parameters */
	        ret = fstart = MPFGMTTP;
                obj[MPFBUTTN].ob_spec = ( LONG )get_fstring( FSGEMTTP );
	        break;

	    default:
ins_1:	      	fill_string( str, NOTPRG );
	       	goto is_1;
	  }
          menu_icheck( dtree, ret, TRUE );

	  /* Set the Function Key */
	  if( app->a_key )
	  {
	    if( app->a_key < 1 )	/* cjg 08/06/92 */
	        app->a_key = 1;

 	    if( app->a_key > 20 )	/* cjg 08/06/92 */
		app->a_key = 20;

	    lbintoasc( (LONG)app->a_key, buffer );
	    istart = MPIF1 + app->a_key - 1;
	    
            obj[MPIBUTTN].ob_spec = ( LONG )get_fstring( FSF1 + app->a_key-1);
	  }
	  else
	  {
	    istart = MPINONE;
	    buffer[0] = 0;
            obj[MPIBUTTN].ob_spec = ( LONG )get_fstring( FSNONE );
	  }
	  menu_icheck( dtree, istart, TRUE );
		
/* set up the memory limits tree */
/* don't show any memory limit if we're not multitasking */
	  for (i = MEM128K; i < MEMNOLIM; i++)
	  {
	    dtree[i].ob_state = NORMAL;
	    menu_icheck( dtree, i, FALSE );
	  }

	  if (!d_multi)
	  {
	    obj[MPMBOX].ob_flags |= HIDETREE;
	  }
	  else
	  {
	    obj[MPMBOX].ob_flags &= ~HIDETREE;
	    if (!app->a_limit || app->a_limit > 8192*1024L)
		mstart = MEMNOLIM;
	    else if (app->a_limit > 4096*1024L)
		mstart = MEM8MEG;
	    else if (app->a_limit > 3072*1024L)
	  	mstart = MEM4MEG;
	    else if (app->a_limit > 2048*1024L)
		mstart = MEM3MEG;
	    else if (app->a_limit > 1024*1024L)
		mstart = MEM2MEG;
	    else if (app->a_limit > 512*1024L)
		mstart = MEM1MEG;
	    else if (app->a_limit > 256*1024L)
		mstart = MEM512K;
	    else if (app->a_limit > 128*1024L)
		mstart = MEM256K;
	    else
		mstart = MEM128K;

	    menu_icheck( dtree, mstart, TRUE );

	/* fix up the button text to match the menu selection */
	    obj[MPMBUTTN].ob_spec = (LONG)get_fstring(FS128K+(mstart-MEM128K));
	  }

	  dr_dial_w( MNINSAPP, FALSE, 0 );
	  where = 0;
ins_2:
	  done = 0;
	  while( !done )
	  {
	      ret = form_do( obj, where ) & 0x7fff;
	      obj[ret].ob_state &= ~SELECTED;

	      switch( ret )
	      {
		case MPCANCEL:	done = TRUE;
				break;

		case MPQUIT:	cont = FALSE;
				done = TRUE;
				break;

		case MPIBUTTN:  /* Install As: */
				DoPopup( obj, MPIBUTTN, MPITITLE, dtree,
					 MPIBASE, MPINONE, &istart, FALSE,
					 MPINONE, FSNONE, TRUE );
				break;

		case MPBBUTTN:  /* Boot Status: */
				DoPopup( obj, MPBBUTTN, MPBTITLE, dtree,
					 MPBBASE, bstart, &bstart, FALSE,
					 MPBAUTO, FSAUTO, FALSE );
				break;


		case MPFBUTTN:  /* File Type: */
				DoPopup( obj, MPFBUTTN, MPFTITLE, dtree,
					 MPFBASE, fstart, &fstart, FALSE,
					 MPFTOS, FSTOS, FALSE );
				break;


		case MPDBUTTN:  /* Default Dir: */
				DoPopup( obj, MPDBUTTN, MPDTITLE, dtree,
					 SDBASE, dstart, &dstart, FALSE,
					 SDAPP, FSAPP, FALSE );
				break;

		case MPPBUTTN:  /* Parameter: */
				DoPopup( obj, MPPBUTTN, MPPTITLE, dtree,
					 SIBASE, pstart, &pstart, FALSE,
					 SIFULL, FSFULL, FALSE );
				break;

		case MPMBUTTN: /* Memory: */
				DoPopup( obj, MPMBUTTN, MPMTITLE, dtree,
					 MPMBASE, mstart, &mstart, FALSE,
					 MEM128K, FS128K, FALSE );
				break;
		case MPOK:  done = TRUE;  /*Install */
	    		    l = (LONG)(istart - MPINONE);	/* Get 1 - 20 */
			    if( ( istart >= MPIF1 ) && ( istart <= MPIF20 ) )
		  	    {
			        sapp = applist;
	      
			        while( sapp )
		                {
				   if ( !newapp )		/* already installed	*/
				   {
		  		      if ( sapp == app )	/* found itself		*/
		    			goto ins_4;		/* skip it		*/
				   }

				   if( sapp->a_key == (UWORD)l )
				   {
				      if( do1_alert( KEYUSED ) == 2 )
		  		      {
	  	     			/* Clear the Function Key Menu */
	  	     			for( i = MPINONE; i <= MPIF20; i++ )
	  	     			{
	     				   dtree[ i ].ob_state = NORMAL;
		        		   menu_icheck( dtree, i, FALSE );
		     			}
	
					/* Set the Function Key */
	  				if( app->a_key )
	  				{
					   lbintoasc( (LONG)app->a_key, buffer );
					   istart = MPIF1 + app->a_key - 1;
				           obj[MPIBUTTN].ob_spec = ( LONG )get_fstring( FSF1 + app->a_key-1);
					}
					else
					{
					   istart = MPINONE;
	    				   buffer[0] = 0;
				           obj[MPIBUTTN].ob_spec = ( LONG )get_fstring( FSNONE );
					}
	             			menu_icheck( dtree, istart, TRUE );

		     			draw_fld( obj, MPIBUTTN );

					/* cjg 08/11/92 */
					obj[ MPOK ].ob_state |= SELECTED;
					XDeselect( obj, MPOK );
	             			where = 0;
	             			goto ins_2;
		  		      }
		  		      else
		    			sapp->a_key = 0;	/* Overwrite	*/
				   }

ins_4:				   sapp = ( APP *)sapp->a_next;
	      			}
			    }/* check function key */

	    		    if( newapp )
	    		    {		/* get the Function key definiton*/
		              app = app_alloc();/* app_alloc will clean up doc	*/	
	      		      if( !app )
	                      {
	        		do1_alert( NOAPP );
				goto ins_6;
	      		      }
	    		    }
	    		    else	/* clean up the old define	*/	
	      		       app->a_doc[0] = 0;

				        /* get the doc icon type	*/
	    		    strcpy( "*.", buffer );
	    		    inf_sget( (LONG)obj, MPDTYPE, &buffer[2] );
	    		    app_icon( buffer, -1, &app->a_dicon );	      

	    		    strcpy( buffer, app->a_doc );
	    		    inf_sget( (LONG)obj, MPARGS, app->a_argu );
	    		    graphic = 1;

			    switch( fstart )
			    {
			       case MPFGEM:   type = PRG;
					      break;

			       case MPFGMTTP: type = PTP;
					      break;

			       case MPFTOS:   graphic = 0;
					      type = TOS;
					      break;

			       case MPFTTP:   graphic = 0;
					      type = TTP;
					      break;
			    }

			    app->a_type = type;		
			    app->a_icon = icon;
			    app->a_pref = 0;

			    if ( dtree[SDAPP].ob_state & CHECKED )
			      app->a_pref = 1;

			    if ( dtree[SIFULL].ob_state & CHECKED )
			      app->a_pref += 2;

			    if ( dtree[MPBAUTO].ob_state & CHECKED )
			    {
			      if ( *str )
			      {
				if ( strlen( str ) < ( PATHLEN - 4 ) )
			        {
			          save_2( autofile, graphic );
				  autofile[2] = ' ';	
			          strcpy( str, &autofile[3] );	    
			        }
			        else
				  do1_alert( NOAUTO );
			      }
			    }
			    else
			    {
			      if ( sret )		/* change from auto to normal	*/
			        strcpy( Nostr, autofile );
			    }
					/* get the Function key definiton*/
			    app->a_key = (UWORD)l;

			    if (d_multi)
			    {
			      switch(mstart) {
				case MEM128K:	app->a_limit = 128*1024L;
						break;
			        case MEM256K:  	app->a_limit = 256*1024L;
						break;
				case MEM512K:	app->a_limit = 512*1024L;
						break;
			        case MEM1MEG:	app->a_limit = 1024*1024L;
						break;
				case MEM2MEG:	app->a_limit = 2048*1024L;
						break;
			        case MEM3MEG:	app->a_limit = 3072*1024L;
						break;
				case MEM4MEG:	app->a_limit = 4096*1024L;
						break;
				case MEM8MEG:	app->a_limit = 8192*1024L;
						break;
			        default:	app->a_limit = 0;
						break;
			      }
			    }
			    lp_fill( str, &app->a_name );
			    lp_collect();
		  	    break;

			case MPREMOVE:	done = TRUE;
				        if( *str )		/* changed 3/3/92	*/
			  	           strcpy( Nostr, autofile );

				        if( !newapp )
					    app_free( app );
					break;

			default:
				 break;

		} /* end of switch */
	  }	/* while !done */
is_1:
	  if ( cont == FALSE )
	    break;

	  cont = x_next( &str, &type );

	}/* while */	

ins_6:	if ( obj )	
	  do_finish( MNINSAPP );
	else
	  do1_alert( NOINSTAL );
}





/* mdesk_pref()
 * ===============================================================
 * Desk Preferences using Pop-Ups
 */
	VOID
mdesk_pref( VOID )
{
	REG OBJECT		*obj;
	OBJECT          *dtree;
	WORD		dstart;
	WORD		cstart;
	WORD		ostart;
	WORD		button;
 
	obj = get_tree( MNSETPRE );
        dtree = get_tree( MNMENU );

	if( cdele_save )
	{
	   dstart = SPYES;
           obj[SPDBUTTN].ob_spec = ( LONG )get_fstring( FSYES );
	}
	else
	{
	   dstart = SPNO;
           obj[SPDBUTTN].ob_spec = ( LONG )get_fstring( FSNO );
	}

	if( !write_save )	/* Overwrite is backwards...*/
	{
	   ostart = SPYES;
           obj[SPOBUTTN].ob_spec = ( LONG )get_fstring( FSYES );
	}
	else
	{
	   ostart = SPNO;
           obj[SPOBUTTN].ob_spec = ( LONG )get_fstring( FSNO );
	}

	if( ccopy_save )
	{
	   cstart = SPYES;
           obj[SPCBUTTN].ob_spec = ( LONG )get_fstring( FSYES );
	}
	else
	{
	   cstart = SPNO;
           obj[SPCBUTTN].ob_spec = ( LONG )get_fstring( FSNO );
	}

        dr_dial_w( MNSETPRE, FALSE, 0 );
	button = 0;
	do
	{
	   button = form_do( obj, 0 ) & 0x7fff;
	   obj[ button ].ob_state &= ~SELECTED;

           dtree[ SPYES ].ob_state = NORMAL;
           dtree[ SPNO ].ob_state  = NORMAL;

	   switch( button )
	   {
	      case MNSPOK:  cdele_save  = ( dstart == SPYES );
			    ccopy_save  = ( cstart == SPYES );
			    write_save  = ( ostart != SPYES );

	      case MNSPCAN: 
			    break;

	      case SPDBUTTN: menu_icheck( dtree, dstart, TRUE );
			     DoPopup( obj, SPDBUTTN, SPDTITLE, dtree,
				      SPBASE, dstart, &dstart, FALSE,
				      SPYES, FSYES, FALSE );
			     break;

	      case SPCBUTTN: menu_icheck( dtree, cstart, TRUE );
			     DoPopup( obj, SPCBUTTN, SPCTITLE, dtree,
				      SPBASE, cstart, &cstart, FALSE,
				      SPYES, FSYES, FALSE );
			     break;

	      case SPOBUTTN: menu_icheck( dtree, ostart, TRUE );
			     DoPopup( obj, SPOBUTTN, SPOTITLE, dtree,
				      SPBASE, ostart, &ostart, FALSE,
				      SPYES, FSYES, FALSE );
			     break;
	   }
	}while( ( button != MNSPOK ) && ( button != MNSPCAN ));

	do_finish( MNSETPRE );
} /* inf_pref */




/* set_video()
 * ===============================================================
 * Set Video Preferences using Pop-Ups( 2Color - True Color )
 * and sets the initial parameters based upon the setmode() call.
 * 
 * RETURNS: TRUE - We are in SPARROW Video and want to change the rez
 *          FALSE - all others
 * RULES:
 * 1) if the Video Cookie value is == 3, we are in SPARROW Video
 *
 * 2) if we are on an ST/TT Shifter, display ONLY the ST/TT Dialog Box.
 *
 * 3) If we are SPARROW Video, ALWAYS come up first in the Sparrow
 *    Video Dialog Box.
 *
 * 5) TT High is not possible with the Sparrow Shifter
 * 6) TT LOW and TT MED are faked using the set_mode() command
 *    BUT the ST COMPATIBLE flag is NOT SET!
 *
 * 7) If we have a SPARROW Shifter, and the current rez is an ST compatible
 *    resolution, Display the Sparrow Video Dialog Box FIRST still.
 */
	WORD
set_video( VOID )
{
	REG OBJECT		*obj;
	REG WORD	i, flag;

	OBJECT		*dtree;
	WORD		button;
	WORD		cstart, old_cstart;
	WORD		lstart, old_lstart;
	WORD		dstart, old_dstart;
	OBJECT		*vtree;
	WORD		output;
	WORD		done,ret;

	WORD		monitor_type;
	UWORD		mode_code;
	UWORD		old_mode_code;

	WORD		color_flag;
	WORD		column_flag;
	WORD		vga_flag;
	WORD		pal_flag;
	WORD		overscan_flag;
	WORD		st_flag;
	WORD		vertical_flag;
	WORD		double_flag;	/* 1 = double, 0 = interlaced mode*/
	WORD		do_falcon_dialog;

	obj   = get_tree( MNSETVID );
	dtree = get_tree( MNMENU );

        /* Check if we're on a MONOCHROME MONITOR.
         * If so, we can ONLY display ST HIGH 
         *
         * 0 = ST monochrome monitor;
         * 1 = ST color monitor;
	 * 2 = VGA monitor;
         * 3 = Television;
	 * The ST color monitor and Television are considered equivalent
         * for our purposes....
         */
	monitor_type = mon_type();

	obj[ SVCBUTTN ].ob_state &= ~DISABLED;
	obj[ SVLBUTTN ].ob_state &= ~DISABLED;
	obj[ SVDBUTTN ].ob_state &= ~DISABLED;

	obj[ SVCBUTTN ].ob_flags |= TOUCHEXIT;
	obj[ SVLBUTTN ].ob_flags |= TOUCHEXIT;
	obj[ SVDBUTTN ].ob_flags |= TOUCHEXIT;

	/* 07/21/92 - cjg - display Sparrow Video Dialog Box first 	*/
	/* But, if monochrome or NO FALCON, just disable everything...	*/
	/* 1/14/93 ++ERS: don't display this box at all if not on a	*/
	/* FALCON							*/

	if ( ( !monitor_type ) || ( gl_vdo & HIGHWORD ) != FALCON )
        {
	    obj[ SVCBUTTN ].ob_state |= DISABLED;
	    obj[ SVLBUTTN ].ob_state |= DISABLED;
	    obj[ SVDBUTTN ].ob_state |= DISABLED;

	    obj[ SVCBUTTN ].ob_flags &= ~TOUCHEXIT;
	    obj[ SVLBUTTN ].ob_flags &= ~TOUCHEXIT;
	    obj[ SVDBUTTN ].ob_flags &= ~TOUCHEXIT;
	    do_falcon_dialog = FALSE;
        }        
	else
	  do_falcon_dialog = TRUE;

	old_mode_code = mode_code   = setmode( -1 );
	color_flag  = mode_code & NUMCOLS;	/* # of bits per pixel */
	column_flag = mode_code & COL80;	/* 40 or 80 column     */

	vga_flag    = mode_code & VGA;		/* VGA or TV/COLOR     */
	pal_flag    = mode_code & PAL;		/* PAL or NTSC	       */
	overscan_flag = mode_code & OVERSCAN;   /* Overscan or not     */
	st_flag  = mode_code & STMODES;		/* ST mode or NOT      */
	vertical_flag = mode_code & VERTFLAG;   /* ON or OFF	       */

	
	/* Determine whether to display Double Line or Interlace
	 * Check if vga_flag == VGA
	 */
	double_flag = (( vga_flag == VGA ) ? ( TRUE ) : ( FALSE ));


	/* Initialize Colors, Columns and Double Line/Interlace */
	for( i = VID2; i <= VIDTRUE; i++ )
	   menu_icheck( dtree, i, FALSE );
	
	/* Initialize the number of colors available */
	cstart = color_flag + VID2;
	
        obj[SVCBUTTN].ob_spec = ( LONG )get_fstring( color_flag + FS2C );	
	menu_icheck( dtree, cstart, TRUE );


	/* Initialize the number of columns */
	menu_icheck( dtree, SVL40, FALSE );
	menu_icheck( dtree, SVL80, FALSE );
	
	if( column_flag == COL80 )
        {
	   lstart = SVL80;
           obj[SVLBUTTN].ob_spec = ( LONG )get_fstring( FS80 );
	}
	else
	{
	   lstart = SVL40;
           obj[SVLBUTTN].ob_spec = ( LONG )get_fstring( FS40 );
	}
	menu_icheck( dtree, lstart, TRUE );


	/* Get Free String for Title - Double Line or Interlace
         * If we are on a VGA monitor, use double...
         * If we are on a Television, use Interlace
	 */
	if( double_flag )
	    ((TEDINFO*)(obj[SVDTITLE].ob_spec))->te_ptext = ( LONG )get_fstring( DLTEXT );
	else
	    ((TEDINFO*)(obj[SVDTITLE].ob_spec))->te_ptext = ( LONG )get_fstring( ITEXT );

	/* Initialize the double/interlace to ON or OFF */
	menu_icheck( dtree, SVION, FALSE );
	menu_icheck( dtree, SVIOFF, FALSE );
	
	if( vertical_flag )
	{
	   dstart = SVION;
           obj[SVDBUTTN].ob_spec = ( LONG )get_fstring( FSON );
	}
	else
	{
	   dstart = SVIOFF;
           obj[SVDBUTTN].ob_spec = ( LONG )get_fstring( FSOFF );
	}
	menu_icheck( dtree, dstart, TRUE );

	button = 0;
	output = 0;
	done   = FALSE;

	old_cstart = cstart;
	old_lstart = lstart;
	old_dstart = dstart;

		
	if (!do_falcon_dialog)
	  goto dialog1;

        dr_dial_w( MNSETVID, FALSE, 0 );
	do
	{
	   button = form_do( obj, 0 ) & 0x7fff;
	   obj[ button ].ob_state &= ~SELECTED;

	   switch( button )
	   {
			     /* SParrow Video OK - NO ST COMPATIBILITY
			      * Change ONLY if one of the 3 variables has
			      * changed AND we are NOT on a monochrome monitor.
			      * Or, if we are in STMODE and want to get
			      * out of it...
			      */	
	      case SVOK:
		if( ( ( cstart != old_cstart ) ||
		   ( lstart != old_lstart ) ||
		   ( dstart != old_dstart ) ||
		   ( old_mode_code & STMODES ) )
		   && monitor_type )
		 {
		   st_flag = FALSE;
		   mode_code = (( cstart - VID2 ) |
				  ( ( lstart == SVL80) ? (COL80):(COL40))|
				    vga_flag | pal_flag |
				    overscan_flag | st_flag |
				    (( dstart == SVION )?(VERTFLAG ):(0)));
		   /* Check if there is enough memory
		    * to switch to the new mode
		    * If not, go back to form_do...
		    */
		   if( !get_that_size( mode_code ))
		   {
		     XDeselect( obj, SVOK );
		     continue;
		   }
		 }
		 else
		   button = SVCANCEL;
					     
	      case SVCANCEL: 
		done = TRUE;
		do_finish( MNSETVID );	
		break;
             
	      case SVMODES:  /* Compatibility Modes */
		do_finish( MNSETVID );	
dialog1:
		vtree = get_tree( MNVIDEO );
		init_vtree();
		output = fmdodraw( MNVIDEO, 0 );
		vtree[ output ].ob_state &= ~SELECTED;

		/* Must be in non-monochrome mode */
		if( output == SVTTOK )
		{
		  button = SVCANCEL;
		  if( monitor_type )
		  {
		    /* Change rez via modecode */
		    st_flag = FALSE;
		    mode_code = vga_flag | pal_flag | overscan_flag;

		    vtree = get_tree( MNVIDEO );
		    flag = inf_gindex( (LONG)vtree, SVSTLOW, 6 );

		    if ( flag != -1 )
		    {
		      switch( flag )
		      {
			case 0: /* STLOW */
			  st_flag = STMODES;
			  vertical_flag = (( vga_flag  == VGA ) ? ( VERTFLAG ) : ( 0 ));
			  mode_code |= ( STMODES | BPS4 | COL40 | vertical_flag );
			  break;

			case 1: /* STMED */
			  st_flag = STMODES;
			  vertical_flag = (( vga_flag == VGA ) ? ( VERTFLAG ) : ( 0 ));
			  mode_code |= ( STMODES | BPS2 | COL80 | vertical_flag );
			  break;

			case 2: /* STHIGH */
			  st_flag = STMODES;
			  vertical_flag = (( vga_flag == VGA ) ? ( 0 ) : ( VERTFLAG ));
			  mode_code |= ( STMODES | BPS1 | COL80 | vertical_flag );
			  break;

			case 3: /* TTMED - NOTE: NON-ST Mode Flag */
			  vertical_flag = (( vga_flag == VGA ) ? ( 0 ) : ( VERTFLAG ));
			  mode_code |= ( BPS4 | COL80 | vertical_flag );
			  break;

			case 4:	/* TT HIGH	*/
			  break;

			case 5: /* TTLOW - NOTE: NON-ST Mode Flag*/
			  vertical_flag = (( vga_flag == VGA ) ? ( 0 ) : ( VERTFLAG ));
			  mode_code |= ( BPS8 | COL40 | vertical_flag );
			  break;

		     }/* end of switch*/

		      /* If built mode_code does not AND
		       * with current setting, change rez!
		       */

		    flag++;	/* this flag is used for NON FALCON mode */
		
		    if (( mode_code ^ old_mode_code ))
		    {
		      if ( get_that_size( mode_code ))
			button = SVTTOK;
		      else
		      {
		        XDeselect( vtree, SVTTOK );
			goto dialog1;
		      }
		    }

		   }/* If flag != -1 */

		  } /* if( monitor_type ) */
		  done = TRUE;
	        }
	        else
	        {
		  st_flag = FALSE;
		  if (!do_falcon_dialog)
		  {
		    button = SVCANCEL;
		    goto enddialog1;
		  }
	          dr_dial_w( MNSETVID, FALSE, 0 );
	        }
	        break;

	      case SVCBUTTN: /* Number of Colors Popup */

		     /* Don't allow 80col, VGA, True Color */
		if( ( vga_flag == VGA ) && ( lstart == SVL80 ) )
		  dtree[ VIDTRUE ].ob_state |= DISABLED;
	     	else
		  dtree[ VIDTRUE ].ob_state &= ~DISABLED;

		    /* Don't allow 40col, 2 Color */
		if( lstart == SVL40 )
		  dtree[ VID2 ].ob_state |= DISABLED;
		else
		  dtree[ VID2 ].ob_state &= ~DISABLED;

		DoPopup( obj, SVCBUTTN, SVCTITLE, dtree, VIDBASE, cstart, &cstart, 
			   FALSE, VID2, FS2C, FALSE );
		break;

	      case SVLBUTTN: /* Number of Columns Popup */

			     /* Don't allow 80col, VGA, TRUE Color */
		if( ( vga_flag == VGA ) && ( cstart == VIDTRUE ) )
		  dtree[ SVL80 ].ob_state |= DISABLED;
		else
		  dtree[ SVL80 ].ob_state &= ~DISABLED;

		/* Don't Allow 40col Monochrome */
		if( cstart == VID2 )
		  dtree[ SVL40 ].ob_state |= DISABLED;
		else
		  dtree[ SVL40 ].ob_state &= ~DISABLED;

		DoPopup( obj, SVLBUTTN, SVLTITLE, dtree, SVLBASE, lstart, &lstart, 
			 FALSE, SVL40, FS40, FALSE );

    		break;
		
	      case SVDBUTTN: /* Double/Interlace - ON/OFF */
		DoPopup( obj, SVDBUTTN, SVDTITLE, dtree, SVIBASE, dstart, &dstart, 
			 FALSE, SVION, FSON, FALSE );

	      break;
	   }

	}while( !done );

enddialog1:

	/* Change the Resolution! - Pass mode_code to DEREK! */

	ret = FALSE;

	if ( button != SVCANCEL )
	{		/* valid the mode code */	
	  if ( ( gl_vdo & HIGHWORD ) == FALCON )
	  {
	    mode_code = (WORD)trap14( 95, mode_code );
	    ret = desk_chres( mode_code, 1 );
	    if (ret)
	      pref_save = mode2res(d_rezword);	
	  }
	  else
	  {		/* ST compatability mode */
	    if ( ( mode_code & 0x80 ) || ( flag != pref_save ) )	
	    {
	       ret = desk_chres( flag, 0 );
 	       if (ret)		
 	         pref_save = flag;
	    }
	  }	

/*	  d_rezword = mode_code;	*/
	}

	return( ret );

} /* set_video */



/* XSelect()
 * ==================================================================
 * Select an object and redraw
 */
	VOID
XSelect( tree, obj )
OBJECT *tree;
WORD   obj;
{
       GRECT trect;

       /* If already selected, return...*/
       if( tree[ obj ].ob_state & SELECTED )
	 return;

       tree[ obj ].ob_state |= SELECTED;
       trect = *(GRECT *)&tree[(obj)].ob_x;
       objc_offset( tree, obj, &trect.g_x, &trect.g_y );
       trect.g_x -= 2;	/* cjg 08/06/92 */
       trect.g_y -= 2;
       trect.g_w += 4;
       trect.g_h += 4;
       objc_draw((LONG)tree,obj,MAX_DEPTH,trect.g_x,trect.g_y,trect.g_w,trect.g_h );
}


/* XDeselect()
 * ====================================================================
 * Deselect an object and redraw - use the flag to redraw in case
 * the area to redraw needs to be bigger.( ie: SHADOWED )
 */
	VOID
XDeselect( tree, obj )
OBJECT *tree;
WORD   obj;
{
       GRECT trect;

       if( tree[ obj ].ob_state & SELECTED )
       {
         tree[ obj ].ob_state &= ~SELECTED;
         trect = *(GRECT *)&tree[(obj)].ob_x;
         objc_offset( (OBJECT *)tree, obj, &trect.g_x, &trect.g_y );
         trect.g_x -= 2;	/* cjg 08/06/92 */
         trect.g_y -= 2;
         trect.g_w += 4;
         trect.g_h += 4;
         objc_draw( (LONG)tree, obj, MAX_DEPTH, trect.g_x, trect.g_y, 
		trect.g_w, trect.g_h );
       }
}



/* DoPopup()
 * ====================================================================
 * Popup Routine to the dialog boxes.
 * This routine will select the title and dispay the PopUp Menu
 * at the button location.
 */
	VOID
DoPopup( tree, button, title, Mtree, Mmenu, Mfirst, Mstart, Mscroll,
         FirstMenu, FirstText, Skip )
OBJECT *tree;
WORD   button;
WORD   title;
OBJECT *Mtree;
WORD   Mmenu;
WORD   Mfirst;
WORD   *Mstart;
WORD   Mscroll;
WORD   FirstMenu;
WORD   FirstText;
WORD   Skip;
{
     GRECT brect;
     WORD  flag;

     if( !ChkTouchButton( tree, button ) )
	 return;

     /* Select the Title */
     tree[ title ].ob_state |= SELECTED;
     draw_fld( tree, title );


     objc_offset( tree, button, &brect.g_x, &brect.g_y );

     Menu.mn_tree   = Mtree;
     Menu.mn_menu   = Mmenu;
     Menu.mn_item   = Mfirst;
     Menu.mn_scroll = Mscroll;
     flag = menu_popup( &Menu, brect.g_x, brect.g_y, &MData );
     if( flag )
     {
        if( ( Mtree == MData.mn_tree ) &&
            ( MData.mn_menu == Mmenu ) )
        {
  	    menu_icheck( Mtree, *Mstart, 0 );
  	    menu_icheck( Mtree, MData.mn_item, 1 );
	    *Mstart = MData.mn_item;

	    if( !Skip )
 	        menu_istart( 1, Mtree, Mmenu, *Mstart );

           tree[ button ].ob_spec = ( LONG )get_fstring( *Mstart - FirstMenu + FirstText );
        }
     }
     /* Deselect the title */
     XDeselect( tree, title );
     XDeselect( tree, button );
}



/* init_vtree()
 * ====================================================================
 * Initialize the Video Dialog Box ( ST and TT Modes )
 */
	VOID
init_vtree( VOID )
{
	REG OBJECT	*vtree;
	REG WORD	i;
	WORD		monitor_type;
	
	vtree = get_tree( MNVIDEO );

	/* Clear the Compatability buttons */

	for ( i = SVSTLOW; i <= TTLOW; i++ )
	  vtree[i].ob_state = DISABLED;

	if ( ( gl_vdo & HIGHWORD ) == TT )
	{
	  if ( pref_save != 5 )		/* Not the high res */
	  { 	
	    for ( i = SVSTLOW; i <= TTLOW; i++ )
	      vtree[i].ob_state = NORMAL;

	    vtree[TTHIGH].ob_state = DISABLED;
	  }
	  else
	    vtree[TTHIGH].ob_state = NORMAL;	    	   	
		
	  vtree[pref_save+SVSTLOW-1].ob_state |= SELECTED;
	}	
	else
	{
	  	/* If we are in FALCON machine, then check if we're	*/
		/* on a monochrome monitor, disable all of the buttons	*/
	  if ( ( gl_vdo & HIGHWORD ) == FALCON )
	  {
	    if ( monitor_type = mon_type() )
	    {
	      for ( i = SVSTLOW; i <= TTLOW; i++ )
	        vtree[i].ob_state = NORMAL;

	      vtree[TTHIGH].ob_state = DISABLED;
	    }

	    /* If we're on a TV or Color monitor, hide the TTLOW and TTMED buttons*/

	    if ( monitor_type != 2 )
	    {
	      vtree[ TTLOW ].ob_state = DISABLED;
	      vtree[ TTMEDIUM ].ob_state = DISABLED;
	    }
	  }
 	  else	/* assume it is STE or ST	*/
	  {
	    for ( i = SVSTLOW; i <= SVSTHIGH; i++ )
	      vtree[i].ob_state = NORMAL;

	    vtree[pref_save+SVSTLOW-1].ob_state |= SELECTED;
	  }
	}
}







/* DoMKItems()
 * ====================================================================
 * Handle the Menu Item Popup for the configuration dialog box
 */
	WORD
DoMKItems( dtree, button, item )
OBJECT *dtree;
WORD   button;
WORD   *item;
{
    OBJECT *obj1;
    WORD   index;
    OBJECT *tree;
    WORD   flag;
    GRECT  brect;
    WORD   start;
    WORD   old_item;
    WORD   length;
    WORD   temp;

    obj1 = menu_addr;
    start = *item + 1;

    /* cjg 09/21/92 */
    length = 0;
    temp   = 0;
    /* Get the length of the largest string */
    for( index = 1; index <= MAXMENU; index++ )
    {
	temp = strlen( (BYTE *)obj1[ tb3[ index - 1 ] ].ob_spec );
	if( temp > length )
	   length = temp;
    }

    /* Ensure a minimum width */
    if( length < 30 )
        length = 30;

    /* Initialize the ROOT */
    mtree[ ROOT ].ob_next   = -1;
    mtree[ ROOT ].ob_head   = mtree[ ROOT ].ob_tail = -1;
    mtree[ ROOT ].ob_type   = G_BOX;
    mtree[ ROOT ].ob_flags  = LASTOB;
    mtree[ ROOT ].ob_state  = SHADOWED;
    mtree[ ROOT ].ob_spec   = 0xFF1100L;
    mtree[ ROOT ].ob_x      = mtree[ ROOT ].ob_y = 0;
    mtree[ ROOT ].ob_width  = length;  /* cjg 09/21/92  - was 30 */
    mtree[ ROOT ].ob_height = MAXMENU;

    for( index = 1; index <= MAXMENU; index++ )
    {
	   mtree[ index ].ob_next = -1;
           mtree[ index ].ob_head   = mtree[ index ].ob_tail = -1;
	   mtree[ index ].ob_type   = G_STRING;
	   mtree[ index ].ob_flags  = NONE;
	   mtree[ index ].ob_state  = NORMAL;
	   mtree[ index ].ob_spec   = obj1[tb3[index-1]].ob_spec;
	   mtree[ index ].ob_x      = 0;
           mtree[ index ].ob_y      = ( index - 1 );
	   mtree[ index ].ob_width  = length;   /* cjg 09/21/92 30; */
	   mtree[ index ].ob_height = 1;
	   objc_add( mtree, ROOT, index );
    }

    for( index = ROOT; index <= MAXMENU; index++ )
       rsrc_obfix( mtree, index );

    mtree[ MAXMENU ].ob_flags |= LASTOB;
    tree = &mtree[ ROOT ];
    menu_icheck( tree, start, TRUE );



     if( !ChkTouchButton( dtree, button ) )
	 return( FALSE );

     old_item = DoKeyCheck( *item );
     if( old_item != -1 )
       mtree[ old_item + 1 ].ob_spec   = obj1[tb3[old_item]].ob_spec;     
     mtree[ start ].ob_spec   = obj1[tb3[*item]].ob_spec;     

     objc_offset( dtree, button, &brect.g_x, &brect.g_y );

     Menu.mn_tree   = tree;
     Menu.mn_menu   = ROOT;
     Menu.mn_item   = start;
     Menu.mn_scroll = TRUE;
     flag = menu_popup( &Menu, brect.g_x, brect.g_y, &MData );
     if( flag )
     {
        if( tree == MData.mn_tree )
        {
  	    menu_icheck( tree, start, 0 );
  	    menu_icheck( tree, MData.mn_item, 1 );
	    *item = MData.mn_item - 1;
	    dtree[ button ].ob_state &= ~SELECTED;
	    return( TRUE );
        }
     }
     XDeselect( dtree, button );
     return( FALSE );
}


/* DoKeyCheck()
 * ====================================================================
 * Check if the keystroke is already used by another menu item
 * in the configuration dialog box.
 */
	WORD
DoKeyCheck( item )
WORD item;
{
     OBJECT *obj;
     WORD   i;
     BYTE   buf[2];
     WORD   flag;

     flag = -1;

     obj = get_tree( MNSYSTEM );	/* Get config tree */

     inf_sget( (LONG)obj, MKKEYS, buf );
     buf[0] = toupper( buf[0] );
     if ( buf[0] )
     {
        for ( i = 0; i < MAXMENU; i++ )
        {
           if( i == item )	/* Skip checking our own */
	     continue;

           if ( mentable[i] == buf[0] )	/* if found elsewhere? */
      	   {
	     if ( do1_alert( KEYUSED ) == 1 ) /* Overwrite */
	     {
	        mentable[i] = 0;
	        ch_key( i );
		flag = i;
	        continue;
	     }
	     buf[1] = 0;
	     buf[0] = mentable[item];
	   }
        }		  	
     }
     mentable[item] = buf[0]; 
     inf_sset( (LONG)obj, MKKEYS, buf );
     draw_fld( obj, MKKEYS );		
     ch_key( item );
     return( flag );
}




	WORD
get_that_size( newmode )
	WORD newmode;
{
	LONG avail, size, needed;
	LONG char_bytes;
	WORD IsVGA;
	WORD IsVertFlag;
	WORD Result;

	if ( ( gl_vdo & HIGHWORD ) == FALCON )
	{
	  avail = Srealloc( -1L );
	  size  = VgetSize( newmode );
	  IsVGA = (( newmode & VGA ) == VGA );
	  IsVertFlag = (( newmode & VERTFLAG ) == VERTFLAG );
	  Result = 2 - !( IsVGA ^ IsVertFlag );

	  char_bytes = 8 * ( 1 << newmode & NUMCOLS ) * Result;
	  needed = 25L * 40L * char_bytes;

	  if( ( avail - size ) < needed )
	  {
	     do1_alert( FCNOMEM );
	     return( FALSE );
	  }
	}

	return( TRUE );	
}



	VOID
wait_up( VOID )
{
  MRETS mk;

  do
  {
      graf_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );
  }while( mk.buttons );
}

