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
 */


/* INCLUDES
 * ==================================================================
 */
#include <portab.h>
#include <mobdefs.h>
#include <defines.h>
#include <window.h>
#include <gemdefs.h>
#include <wsdefine.h>
#include <osbind.h>
#include <mode.h>

#if SPAIN
#include <deskspa.h>
#endif

#if USA|UK
#include <deskusa.h>
#endif

#if FRENCH|SWISSFRE
#include <deskfre.h>
#endif

#if GERMANY|SWISSGER
#include <deskgrm.h>
#endif

#if SWEDEN
#include <deskswe.h>
#endif

#if ITALY
#include <deskita.h>
#endif

#if 0
#include <osbind.h>
#endif

#include <extern.h>

/*
#include <vdidefs.h>
*/
/* EXTERNS
 * ==================================================================
 */
EXTERN	BYTE	*get_fstring();
EXTERN	BYTE	*malloc();
EXTERN	APP	*app_key();
EXTERN	BYTE	*get_string();
EXTERN	WINDOW	*get_win();
EXTERN	WINDOW	*get_top();
EXTERN	BYTE	*r_slash();
EXTERN	BYTE	toupper();
EXTERN	OBJECT	*get_tree();
EXTERN	ICONBLK	*get_icon();
EXTERN	WINDOW	*w_gfirst();
EXTERN	WINDOW	*w_gnext();
EXTERN	BYTE	*g_name();

EXTERN	WS	gl_ws;
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
/* EXTERN  WS	gl_ws;	*/

EXTERN  UWORD    d_rezword;	/* set_mode() value ( system ) */


/* DEFINES
 * ==================================================================
 */

/* Structure for passing menu data */
typedef struct _menu
{
   OBJECT *mn_tree;		/* Object tree of the menu */
   WORD   mn_menu;		/* Parent of the menu items*/
   WORD   mn_item;		/* Starting menu item      */
   WORD   mn_scroll;		/* scroll flag for the menu*/
   WORD   mn_keystate;		/* Key State 		   */
}MENU;


/* Mouse Rectangle Structure...*/
typedef struct _mrets
{
  WORD x;
  WORD y;
  WORD buttons;
  WORD kstate;
}MRETS;



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
    GRECT rect;

    wind_update( BEG_MCTRL );

    Select( tree, button );			

    graf_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );
    while( mk.buttons )
    {
      obj = objc_find( tree, button, 0, mk.x, mk.y );
      if( obj != button )
      {
         if( tree[ button ].ob_state & SELECTED )
	     Deselect( tree, button, TRUE );
      }
      else
      {
         if( !( tree[ button ].ob_state & SELECTED ) )
	     Select( tree, button );
      }
      graf_mkstate( &mk.x, &mk.y, &mk.buttons, &mk.kstate );
    }
    evnt_button( 1, 1, 0, &dummy, &dummy, &dummy, &dummy );
    obj = objc_find( tree, button, 0, mk.x, mk.y );
    if( obj != button )
       Deselect( tree, button, TRUE );

    wind_update( END_MCTRL );
    return( obj == button );
}




/* mv_desk()
 * ===============================================================
 * Desktop Configuration modified to include Pop-ups.
 */
mv_desk()
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
	GRECT		brect;
	WORD		flag;
        GRECT		trect;
	BYTE		dcolor;

	obj = get_tree( MNSYSTEM );	      /* Get config tree  */
	obj1 = menu_addr;		      /* Get Menu Bar Tree*/

	dtree = get_tree( MNMENU );	      /* Get Popup menu Tree */


	for ( i = 0; i < MAXMENU; i++ )	      /* save a copy of keystrokes*/
	  temp[i] = mentable[i];	

	/* Initialize the First Menu Item Keystroke */
	(TEDINFO*)(obj[MKITEM].ob_spec)->te_ptext = obj1[tb3[0]].ob_spec;
	buf[1] = 0;
	buf[0] = mentable[0];
	inf_sset( obj, MKKEYS, buf );
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
          ( BYTE *)obj[SDBUTTON].ob_spec = get_fstring( FSAPP );
        }
	else
        {
	  dstart = SDTOP;			/* Top Window  */
          ( BYTE *)obj[SDBUTTON].ob_spec = get_fstring( FSTOP );
        }
	menu_icheck( dtree, dstart, 1 );


	/* Initialize the starting object and button text of the path menu*/
	if ( s_fullpath )			/* Set input parameter  */
        {
	  istart = SIFULL;			/* Full Path   */
          ( BYTE *)obj[SIBUTTON].ob_spec = get_fstring( FSFULL );
	}
	else
        {
	  istart = SIFILE;			/* File Name   */
          ( BYTE *)obj[SIBUTTON].ob_spec = get_fstring( FSFILE );
        }
	menu_icheck( dtree, istart, 1 );


	/* Initialize the Free Memory String */
	f_str( obj, MKMEMORY, av_mem() );
	*(BYTE*)((TEDINFO*)(obj[MFKEY].ob_spec)->te_ptext) = 0;

	/* save the original pointer	*/
	str = (TEDINFO*)(obj[MFFILE].ob_spec)->te_ptext;
	len = strlen( str );	
	*str = 0;

	app = (APP*)0;
	which = MFDOWN;

 	f = 0;
	fm_draw( MNSYSTEM, FALSE );		/* save the string	*/
	goto ad_2;

	while( TRUE )
	{
ad_5:	  which = form_do( obj, MKKEYS ) & 0x7fff;
	  obj[ which ].ob_state &= ~SELECTED;

	  if ( ( which == MKUPS ) || ( which == MKDOWNS ) || ( which == MOK ) )
	  {
	      inf_sget( obj, MKKEYS, buf );
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
		Deselect( obj, MKCLEAR, TRUE );
	        goto p_11;	
	      }
	      break;

	    case MKUPS:		/* check for keys	*/
	      if ( menui )
	      {
	 	menui--;
		goto p_11;
	      }

	      break;

	    case MKDOWNS:
	      if ( ( menui + 1 ) < MAXMENU )
	      {
		menui++;
p_11:
	        ch_key( menui );
	        (TEDINFO*)(obj[MKITEM].ob_spec)->te_ptext = obj1[tb3[menui]].ob_spec;
	        draw_fld( obj, MKITEM );
p_2:	
	        buf[1] = 0;
	        buf[0] = mentable[menui];
	        inf_sset( obj, MKKEYS, buf );
	        draw_fld( obj, MKKEYS );		
	      }
	
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
	      s_defdir = ( dtree[FSAPP].ob_state & CHECKED ) ? TRUE : FALSE;
	      s_fullpath = ( dtree[ FSFULL ].ob_state & CHECKED ) ? TRUE : FALSE;

	      goto ad_1;	 

	    case MFUP:
	        f--;
	        if ( f )
	          goto ad_3;  	
	        else
		  f++;
	      break;
	    
	    case MFDOWN:
	        f++;
	        if ( f <= 20 )
	        {
ad_3:	          if ( !( xapp = app_key( ftab[f] ) ) )
		    goto ad_2;
	          else
	          {
		    app = xapp;
		    fi = 0;
		    (TEDINFO*)(obj[MFFILE].ob_spec)->te_ptext = app->a_name;
		    draw_fld( obj, MFFILE );
		    f_str( obj, MFKEY, f );
		    draw_fld( obj, MFKEY );
	          }		
	        }
	        else
		  f--;
	      break;

	    case MFLEFT:		
	    case MFRIGHT:
	      if( !app )
		continue;
		
	      if ( which == MFLEFT )
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
	      (TEDINFO*)(obj[MFFILE].ob_spec)->te_ptext = &app->a_name[fi];
	      draw_fld( obj, MFFILE );
	      goto ad_5;

	  }/* switch */

	  cl_delay();
	}

ad_1:				/* restore the pointer	*/
	put_keys();
	(TEDINFO*)(obj[MFFILE].ob_spec)->te_ptext = str;
	*str = 1;		
	do_finish( MNSYSTEM );
}




/* mins_app()
 * ===============================================================
 * Install Application using Popups
 */
mins_app()
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
	GRECT		brect;
        GRECT		trect;
	WORD		flag;

	WORD		istart;		/* Current obj - Install As */
	WORD		bstart;		/* Current Obj - Boot Status*/
	WORD		fstart;		/* Current Obj - File Type  */
	WORD		dstart;		/* Current Obj - Default Dir*/
	WORD		pstart;		/* Current Obj - Parameter  */
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
               ( BYTE *)obj[MPBBUTTN].ob_spec = get_fstring( FSAUTO );	      
	  }
	  else
	  {
	       bstart = MPBNORML;
               ( BYTE *)obj[MPBBUTTN].ob_spec = get_fstring( FSNORMAL );
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
              ( BYTE *)obj[MPDBUTTN].ob_spec = get_fstring( FSAPP );
	  }
	  else
	  {
	      dstart = SDTOP;
              ( BYTE *)obj[MPDBUTTN].ob_spec = get_fstring( FSTOP );
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
            ( BYTE *)obj[MPPBUTTN].ob_spec = get_fstring( FSFULL );
          }
	  else
          {
	    pstart = SIFILE;
            ( BYTE *)obj[MPPBUTTN].ob_spec = get_fstring( FSFILE );
	  }
	  menu_icheck( dtree, pstart, TRUE );	


	  /* Set the Document type */
	  inf_sset( obj, MPDTYPE, ( newapp ) ? Nostr : &app->a_doc[2] );

	  /* Set the Application Name */
 	  xinf_sset( obj, MPFNAME, g_name( str ) );

	  /* Set the Arguments */
	  inf_sset( obj, MPARGS, ( newapp ) ? Nostr : app->a_argu );
	


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
                ( BYTE *)obj[MPFBUTTN].ob_spec = get_fstring( FSGEM );
	        break;
	
            case TTP:		 	
	        ret = fstart = MPFTTP;
                ( BYTE *)obj[MPFBUTTN].ob_spec = get_fstring( FSTOSTTP );
	        break;
	
	    case TOS:
	        ret = fstart = MPFTOS;
                ( BYTE *)obj[MPFBUTTN].ob_spec = get_fstring( FSTOS );
	        break;

	    case PTP:	/* Gem takes parameters */
	        ret = fstart = MPFGMTTP;
                ( BYTE *)obj[MPFBUTTN].ob_spec = get_fstring( FSGEMTTP );
	        break;

	    default:
ins_1:	      	fill_string( str, NOTPRG );
	       	goto is_1;
	  }
          menu_icheck( dtree, ret, TRUE );

	  /* Set the Function Key */
	  if( app->a_key )
	  {
	    lbintoasc( (LONG)app->a_key, buffer );
	    istart = MPIF1 + app->a_key - 1;
            ( BYTE *)obj[MPIBUTTN].ob_spec = get_fstring( FSF1 + app->a_key-1);
	  }
	  else
	  {
	    istart = MPINONE;
	    buffer[0] = 0;
            ( BYTE *)obj[MPIBUTTN].ob_spec = get_fstring( FSNONE );
	  }
	  menu_icheck( dtree, istart, TRUE );
		
	  fm_draw( MNINSAPP, FALSE );
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

		case MPOK:  done = TRUE;  /*Install */
			    if( ( istart >= MPIF1 ) && ( istart <= MPIF20 ) )
		  	    {
	      			l = (UWORD)(istart - MPINONE);	/* Get 1 - 20 */
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
				           ( BYTE *)obj[MPIBUTTN].ob_spec = get_fstring( FSF1 + app->a_key-1);
					}
					else
					{
					   istart = MPINONE;
	    				   buffer[0] = 0;
				           ( BYTE *)obj[MPIBUTTN].ob_spec = get_fstring( FSNONE );
					}
	             			menu_icheck( dtree, istart, TRUE );

		     			draw_fld( obj, MPIBUTTN );
		     			draw_fld( obj, MPOK );
	             			where = 0;
	             			goto ins_2;
		  		      }
		  		      else
		    			sapp->a_key = 0;	/* Overwrite	*/
				   }

ins_4:				   sapp = sapp->a_next;
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
	    		    inf_sget( obj, MPDTYPE, &buffer[2] );
	    		    app_icon( buffer, -1, &app->a_dicon );	      

	    		    strcpy( buffer, app->a_doc );
	    		    inf_sget( obj, MPARGS, app->a_argu );
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

			    if ( dtree[SDTOP].ob_state & CHECKED )
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
mdesk_pref()
{
	REG OBJECT		*obj;
	REG WORD	cyes, i, flag;
	    WORD	overwrite,font;

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
           ( BYTE *)obj[SPDBUTTN].ob_spec = get_fstring( FSYES );
	}
	else
	{
	   dstart = SPNO;
           ( BYTE *)obj[SPDBUTTN].ob_spec = get_fstring( FSNO );
	}

	if( !write_save )	/* Overwrite is backwards...*/
	{
	   ostart = SPYES;
           ( BYTE *)obj[SPOBUTTN].ob_spec = get_fstring( FSYES );
	}
	else
	{
	   ostart = SPNO;
           ( BYTE *)obj[SPOBUTTN].ob_spec = get_fstring( FSNO );
	}

	if( ccopy_save )
	{
	   cstart = SPYES;
           ( BYTE *)obj[SPCBUTTN].ob_spec = get_fstring( FSYES );
	}
	else
	{
	   cstart = SPNO;
           ( BYTE *)obj[SPCBUTTN].ob_spec = get_fstring( FSNO );
	}

        fm_draw( MNSETPREF, FALSE );
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

	do_finish( MNSETPREF );
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
set_video()
{
	REG OBJECT		*obj;
	REG WORD	cyes, i, flag;
	    WORD	overwrite,font;

	OBJECT		*dtree;
	WORD		button;
	WORD		cstart, old_cstart;
	WORD		lstart, old_lstart;
	WORD		dstart, old_dstart;
	OBJECT		*vtree;
	WORD		output;
	WORD		done;

	WORD		monitor_type;
	UWORD		mode_code;

	WORD		color_flag;
	WORD		column_flag;
	WORD		vga_flag;
	WORD		pal_flag;
	WORD		overscan_flag;
	WORD		st_flag;
	WORD		vertical_flag;
	WORD		double_flag;	/* 1 = double, 0 = interlaced mode*/
	LONG		p_value;

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

	/* 07/21/92 - cjg - display Sparrow Video Dialog Box first */
	/* But, if monochrome, just disable everything...*/
	if( !monitor_type )
        {
	    obj[ SVCBUTTN ].ob_state |= DISABLED;
	    obj[ SVLBUTTN ].ob_state |= DISABLED;
	    obj[ SVDBUTTN ].ob_state |= DISABLED;
        }        
	mode_code   =  d_rezword;	/* Get wot the system thinks its in */

	color_flag  = mode_code & NUMCOLS;	/* # of bits per pixel */
	column_flag = mode_code & COL80;	/* 40 or 80 column     */

	vga_flag    = mode_code & VGA;		/* 200 Lines/400 lines */
	pal_flag    = mode_code & PAL;		/* PAL or NTSC	       */
	overscan_flag = mode_code & OVERSCAN;   /* Overscan or not     */
	st_flag  = mode_code & STMODES;		/* ST mode or NOT      */
	vertical_flag = mode_code & VERTFLAG;   /* ON or OFF	       */

	
	/* Determine whether to display Double Line or Interlace
	 * 2 == VGA Monitor
	 */
	double_flag = (( monitor_type == 2 ) ? ( TRUE ) : ( FALSE ));


	/* Initialize Colors, Columns and Double Line/Interlace */
	for( i = VID2; i <= VIDTRUE; i++ )
	   menu_icheck( dtree, i, FALSE );
	
	/* Initialize the number of colors available */
	cstart = color_flag + VID2;
	
        ( BYTE *)obj[SVCBUTTN].ob_spec = get_fstring( color_flag + FS2C );	
	menu_icheck( dtree, cstart, TRUE );


	/* Initialize the number of columns */
	menu_icheck( dtree, SVL40, FALSE );
	menu_icheck( dtree, SVL80, FALSE );
	
	if( column_flag == COL80 )
        {
	   lstart = SVL80;
           ( BYTE *)obj[SVLBUTTN].ob_spec = get_fstring( FS80 );
	}
	else
	{
	   lstart = SVL40;
           ( BYTE *)obj[SVLBUTTN].ob_spec = get_fstring( FS40 );
	}
	menu_icheck( dtree, lstart, TRUE );


	/* Get Free String for Title - Double Line or Interlace
         * If we are on a VGA monitor, use double...
         * If we are on a Television, use Interlace
	 */
	if( double_flag )
	    (TEDINFO*)(obj[SVDTITLE].ob_spec)->te_ptext = get_fstring( DLTEXT );
	else
	    (TEDINFO*)(obj[SVDTITLE].ob_spec)->te_ptext = get_fstring( ITEXT );

	/* Initialize the double/interlace to ON or OFF */
	menu_icheck( dtree, SVION, FALSE );
	menu_icheck( dtree, SVIOFF, FALSE );
	
	if( vertical_flag )
	{
	   dstart = SVION;
           ( BYTE *)obj[SVDBUTTN].ob_spec = get_fstring( FSON );
	}
	else
	{
	   dstart = SVIOFF;
           ( BYTE *)obj[SVDBUTTN].ob_spec = get_fstring( FSOFF );
	}
	menu_icheck( dtree, dstart, TRUE );

	button = 0;
	output = 0;
	done   = FALSE;

	old_cstart = cstart;
	old_lstart = lstart;
	old_dstart = dstart;

		
        fm_draw( MNSETVID, FALSE );
	do
	{
	   button = form_do( obj, 0 ) & 0x7fff;
	   obj[ button ].ob_state &= ~SELECTED;

	   switch( button )
	   {
			     /* SParrow Video OK - NO ST COMPATIBILITY */
	      case SVOK:     if( ( cstart != old_cstart ) ||
				 ( lstart != old_lstart ) ||
				 ( dstart != old_dstart ))
			     {
				 st_flag = FALSE;
				 mode_code = (( cstart - VID2 ) |
					     ( ( lstart == SVL80) ? (COL80):(COL40))|
					     vga_flag | pal_flag |
					     overscan_flag | st_flag |
					     (( dstart == SVION )?(VERTFLAG ):(0)));
			     }
			     else
				button = SVCANCEL;

	      case SVCANCEL: done = TRUE;
			     do_finish( MNSETVID );	
			     break;
             
	      case SVMODES:  /* Compatibility Modes */
			     do_finish( MNSETVID );	
dialog1:
			     init_vtree();
			     output = fmdodraw( MNVIDEO, 0 );
	
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
				  flag = inf_gindex( vtree, SVSTLOW, 5 );
				  if( flag != -1 )
				  {
			  	       switch( flag )
				       {
					  case 0: /* STLOW */
						  st_flag = STMODES;
						  vertical_flag = (( monitor_type == 2 ) ? ( VERTFLAG ) : ( 0 ));
				                  mode_code |= ( STMODES | BPS4 | COL40 | vertical_flag );
						  break;

					  case 1: /* STMED */
						  st_flag = STMODES;
						  vertical_flag = (( monitor_type == 2 ) ? ( VERTFLAG ) : ( 0 ));
						  mode_code |= ( STMODES | BPS2 | COL80 | vertical_flag );
						  break;

					  case 2: /* STHIGH */
						  st_flag = STMODES;
						  vertical_flag = (( monitor_type == 2 ) ? ( 0 ) : ( VERTFLAG ));
						  mode_code |= ( STMODES | BPS1 | COL80 | vertical_flag );
						  break;

					  case 3: /* TTLOW - NOTE: NON-ST Mode Flag*/
						  vertical_flag = (( monitor_type == 2 ) ? ( 0 ) : ( VERTFLAG ));
						  mode_code |= ( BPS8 | COL40 | vertical_flag );
						  break;

					  case 4: /* TTMED - NOTE: NON-ST Mode Flag */
						  vertical_flag = (( monitor_type == 2 ) ? ( 0 ) : ( VERTFLAG ));
						  mode_code |= ( BPS4 | COL80 | vertical_flag );
						  break;
				      }/* end of switch*/

				      /* If built mode_code does not AND
				       * with current setting, change rez!
				       */
				
		  				
				      if( ( mode_code ^ d_rezword ))
					button = SVTTOK;
				
				/*
				    flag++;
				    if ( flag != pref_save )
				    {
				      if ( app_reschange( flag ) ) 	
					d_exit = L_CHGRES;
				    }	
				*/
				   }/* If flag != -1 */

				} /* if( monitor_type ) */
				done = TRUE;
			     }
			     else
			     {
				st_flag = FALSE;
			        fm_draw( MNSETVID, FALSE );
			     }
			     break;

	      case SVCBUTTN: /* Number of Colors Popup */

			     /* Don't allow 80col, VGA, True Color */
			     if( ( monitor_type == 2 ) && ( lstart == SVL80 ) )
				dtree[ VIDTRUE ].ob_state |= DISABLED;
			     else
				dtree[ VIDTRUE ].ob_state &= ~DISABLED;

			     /* Don't allow 40col, 2 Color */
			     if( lstart == SVL40 )
				dtree[ VID2 ].ob_state |= DISABLED;
			     else
				dtree[ VID2 ].ob_state &= ~DISABLED;

			     DoPopup( obj, SVCBUTTN, SVCTITLE, dtree,
				      VIDBASE, cstart, &cstart, FALSE,
				      VID2, FS2C, FALSE );
			     break;

	      case SVLBUTTN: /* Number of Columns Popup */

			     /* Don't allow 80col, VGA, TRUE Color */
			     if( ( monitor_type == 2 ) && ( cstart == VIDTRUE ) )
				dtree[ SVL80 ].ob_state |= DISABLED;
			     else
				dtree[ SVL80 ].ob_state &= ~DISABLED;

			     /* Don't Allow 40col Monochrome */
			     if( cstart == VID2 )
			        dtree[ SVL40 ].ob_state |= DISABLED;
			     else
				dtree[ SVL40 ].ob_state &= ~DISABLED;
			     DoPopup( obj, SVLBUTTN, SVLTITLE, dtree,
				      SVLBASE, lstart, &lstart, FALSE,
				      SVL40, FS40, FALSE );
    			     break;
		
	      case SVDBUTTN: /* Double/Interlace - ON/OFF */
			     DoPopup( obj, SVDBUTTN, SVDTITLE, dtree,
				      SVIBASE, dstart, &dstart, FALSE,
				      SVION, FSON, FALSE );
			     break;
	   }

	}while( !done );


	/* Change the Resolution! - Pass mode_code to DEREK! */
	if( button != SVCANCEL )
	{
	   d_rezword = mode_code;
	   return( TRUE );

	}
	return( FALSE );

} /* set_video */



/* Select()
 * ==================================================================
 * Select an object and redraw
 */
WORD
Select( tree, obj )
OBJECT *tree;
WORD   obj;
{
       tree[ obj ].ob_state |= SELECTED;
       draw_fld( tree, obj );
}


/* Deselect()
 * ====================================================================
 * Deselect an object and redraw - use the flag to redraw in case
 * the area to redraw needs to be bigger.( ie: SHADOWED )
 */
WORD
Deselect( tree, obj, flag )
OBJECT *tree;
WORD   obj;
WORD   flag;
{
       GRECT trect;

       tree[ obj ].ob_state &= ~SELECTED;
       trect = *(GRECT *)&tree[(obj)].ob_x;
       objc_offset( tree, obj, &trect.x, &trect.y );
       if( flag )
       {
	   trect.x -= 1;
	   trect.y -= 1;
           trect.w += 2;
           trect.h += 2;
       }
       objc_draw( tree, obj, MAX_DEPTH, trect.x, trect.y, trect.w, trect.h );
}



/* DoPopup()
 * ====================================================================
 * Popup Routine to the dialog boxes.
 * This routine will select the title and dispay the PopUp Menu
 * at the button location.
 */
WORD
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
     Select( tree, title );

     objc_offset( tree, button, &brect.x, &brect.y );

     Menu.mn_tree   = Mtree;
     Menu.mn_menu   = Mmenu;
     Menu.mn_item   = Mfirst;
     Menu.mn_scroll = Mscroll;
     flag = menu_popup( &Menu, brect.x, brect.y, &MData );
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

           ( BYTE *)tree[ button ].ob_spec = get_fstring( *Mstart - FirstMenu + FirstText );
        }
     }
     /* Deselect the title */
     Deselect( tree, title, FALSE );
     Deselect( tree, button, TRUE );
}



/* init_vtree()
 * ====================================================================
 * Initialize the Video Dialog Box ( ST and TT Modes )
 */
WORD
init_vtree()
{
	REG OBJECT	*vtree;
	REG WORD	cyes, i, flag;
	WORD		monitor_type;

	vtree = get_tree( MNVIDEO );

	/* Clear the Compatability buttons */
	for ( i = SVSTLOW; i <= SVTTMED; i++ )
	  vtree[i].ob_state = NORMAL;

	/* If we're on a monochrome monitor, disable all of the buttons*/
	monitor_type = mon_type();
	if( !monitor_type )
	{
	  for ( i = SVSTLOW; i <= SVTTMED; i++ )
	     vtree[i].ob_state = DISABLED;
	}


	vtree[ SVTTLOW ].ob_flags &= ~HIDETREE;
	vtree[ SVTTMED ].ob_flags &= ~HIDETREE;
	/* If we're on a TV or Color monitor, hide the TTLOW and TTMED buttons*/
	if( ( monitor_type == 1 ) || ( monitor_type == 3 ))
	{
	   vtree[ SVTTLOW ].ob_flags |= HIDETREE;
	   vtree[ SVTTMED ].ob_flags |= HIDETREE;
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

    obj1 = menu_addr;
    start = *item + 1;

    /* Initialize the ROOT */
    mtree[ ROOT ].ob_next   = -1;
    mtree[ ROOT ].ob_head   = mtree[ ROOT ].ob_tail = -1;
    mtree[ ROOT ].ob_type   = G_BOX;
    mtree[ ROOT ].ob_flags  = LASTOB;
    mtree[ ROOT ].ob_state  = SHADOWED;
    mtree[ ROOT ].ob_spec   = 0xFF1100L;
    mtree[ ROOT ].ob_x      = mtree[ ROOT ].ob_y = 0;
    mtree[ ROOT ].ob_width  = 30;
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
	   mtree[ index ].ob_width  = 30;
	   mtree[ index ].ob_height = 1;
	   objc_add( mtree, ROOT, index );
    }

    for( index = ROOT; index <= MAXMENU; index++ )
       rsrc_obfix( mtree, index );

    mtree[ MAXMENU ].ob_flags = LASTOB;
    tree = &mtree[ ROOT ];
    menu_icheck( tree, start, TRUE );



     if( !ChkTouchButton( dtree, button ) )
	 return( FALSE );

     old_item = DoKeyCheck( *item );
     if( old_item != -1 )
       mtree[ old_item + 1 ].ob_spec   = obj1[tb3[old_item]].ob_spec;     
     mtree[ start ].ob_spec   = obj1[tb3[*item]].ob_spec;     

     objc_offset( dtree, button, &brect.x, &brect.y );

     Menu.mn_tree   = tree;
     Menu.mn_menu   = ROOT;
     Menu.mn_item   = start;
     Menu.mn_scroll = TRUE;
     flag = menu_popup( &Menu, brect.x, brect.y, &MData );
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
     Deselect( dtree, button, TRUE );
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

     inf_sget( obj, MKKEYS, buf );
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
     inf_sset( obj, MKKEYS, buf );
     draw_fld( obj, MKKEYS );		
     ch_key( item );
     return( flag );
}


