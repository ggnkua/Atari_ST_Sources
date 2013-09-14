/* ====================================================================
 * FILE: FSM.C
 * ====================================================================
 * DATE: June 29, 1990
 * DESCRIPTION: FSM - Scalable Font CPX Manager
 * COMPILER: TURBO C Version 2.0
 *
 * CREATED:  June 29, 1990 cjg
 * MODIFIED: June 26, 1991 cjg   - 1991 no kidding...
 *	     July 11, 1991 cjg
 */
 

/* INCLUDE FILES
 * ====================================================================
 */
#include "fsmhead.h"
#include "country.h"

#include "fsm.h"

#pragma warn -apt		   /* 1 Non-portable pointer assignment */
#pragma warn -rpt		   /* 1 Non-portable pointer conversion */
#include "fsm.rsh"
#pragma warn .apt
#pragma warn .rpt

#include "..\cpxdata.h"		   /* Our CPX Data Structures */	
#include "popup.h"
#include "mover.h"
#include "fsmio.h"
#include "outline.h"
#include "points.h"
#include "buildwd.h"
#include "text.h"
#include "fsmcache.h"
#include "cacheopt.h"

#include "status.h"

/* PROTOTYPES
 * ====================================================================
 */
CPXINFO	 *cdecl cpx_init( XCPB *Xcpb );
BOOLEAN  cdecl  cpx_call( GRECT *rect );

void	 initialize( void );
void	 setup_title( void );	
void	 Build_Menu( void );

void	 Do_Status_Toggle( void );
void	 Do_Type_Toggle( void );
	
int	 handle_button( int button, WORD *msg );

void	 Reset_Tree( OBJECT *tree );

int	 open_vwork( void );
void	 close_vwork( void );
void	 Move_Fonts( void ); 
void	 Return_To_Maintree( OBJECT *Want_This_Tree );

BOOLEAN	 do_write_extend( BOOLEAN flag );
void	 fast_write_extend( void );
void	 MF_Save( void );
void	 MF_Restore( void );
void	 Scan_Message( OBJECT *Tree, BOOLEAN flag );

/* from cpxstart.s */
long	 gdos_tst( void );


/* DEFINES
 * ====================================================================
 */
#define MENU_WIDTH  26	 

#define ACTIVE	    0
#define INACTIVE    1

#define BITMAP	    0
#define OUTLINE	    1

#define NO_GDOS_NO_FONT	   2	/* # of menu items with gdos installed */
#define NO_GDOS_YES_FONT   3	/* or not. PLUS, whether a font is     */
				/* selected or not. 		       */
#define GDOS_NO_FONT   4
#define GDOS_YES_FONT  5

#define UNDO	0x6100


/* EXTERNALS
 * ====================================================================
 */
extern int save_vars;		/* Save_vars is where our default data
				 * is stored.
				 */

int errno;			/* When using the itoa() etc libraries
				 * TC uses 'errno' which is a variable
				 * found in TCSTART.S. But, since
				 * we're not including TCSTART.S..well...
				 */

/* GLOBALS
 * ====================================================================
 */
int	contrl[12], intin[128], intout[128], ptsin[128],ptsout[128],
	work_in[12], work_out[57];

int	vhandle;
GRECT	desk;
	 
OBJECT *tree; 
OBJECT *Oxtree;			/* Outline Tree          */
OBJECT *Maintree;		/* FSM tree	         */
OBJECT *Oxsizes;		/* Outline Sizes         */
OBJECT *PtSizeTree;		/* New Point Size Tree   */
OBJECT *PrevTree;		/* Backup tree for sizes */
OBJECT *FsmTree;		/* FSM Cache Size Tree	 */
OBJECT *CacheTree;		/* Cache Options Tree	 */
OBJECT *ad_scan;		/* Scanning message tree */
OBJECT *ad_width;		/* WIDTH Tables dialog box*/
OBJECT *ad_load;		/* loading fonts message  */

XCPB *xcpb;			/* XControl Parameter Block   */
CPXINFO cpxinfo;		/* CPX Information Structure  */

int  Item;			/* Index of which item was selected from
			 	 * the POPUP menu. ( Base Zero ).
			 	 */
			 
int  num_menu_items;		/* Number of menu items to display */
int  Num_Items_Deselected;
int  Num_Items_Selected;

MFORM Mbuffer;			/* Store the current mouse shape   */

int  Command_Value = ACTIVE;	/* Value for indexing into the
				 * Command_txt[] array. ( base zero ).
				 * Used for the main menu title that
				 * shows the type of text being displayed.
				 * 'Active Fonts' or 'Inactive Fonts'.
				 */
				 
int  Status_Value  = INACTIVE;  /* Value for indexing into the
				 * Status_text[] array. ( base zero ).
				 * Used to display a menu item.
				 * 'Show Active Fonts' or 
				 * 'Show Inactive Fonts'.
				 */
				 
int  gdos_flag;			/* Flag for presence of FSMGDOS
				 * TRUE  - GDOS present
				 * FALSE - No GDOS present.
				 */

BOOLEAN Change_Flag = FALSE;	/* TRUE - IF something has changed */
				/* So that we can show the
				 * 'Save Extend.Sys' Message
				 */
BOOLEAN Old_Change_Flag;
BOOLEAN Restore_Flags;		/* Used for point size dialog. This
				 * prevents the inactive fonts from
				 * setting the flag to make width tables
				 * or to prompt for a save.
				 */
/* FUNCTIONS
 * ====================================================================
 */
	


/* cpx_init()
 * ====================================================================
 */			
CPXINFO
*cdecl cpx_init( XCPB *Xcpb )
{
    xcpb = Xcpb;
    
    if( xcpb->booting )
    {
        Get_Default_Cache();	/* load a default cache */
        return( ( CPXINFO *)TRUE );  
    }    
    else
    {    
      if( !xcpb->SkipRshFix )
           (*xcpb->rsh_fix)( NUM_OBS, NUM_FRSTR, NUM_FRIMG, NUM_TREE,
                            rs_object, rs_tedinfo, rs_strings, rs_iconblk,
                            rs_bitblk, rs_frstr, rs_frimg, rs_trindex,
                            rs_imdope );
      
           
      Oxtree     = ( OBJECT *)rs_trindex[ FOUTLINE ];
      Maintree   = ( OBJECT *)rs_trindex[ FSM ];
      Oxsizes    = ( OBJECT *)rs_trindex[ FOSIZES ];
      PtSizeTree = ( OBJECT *)rs_trindex[ NEWPTSIZ ];

      FsmTree	 = ( OBJECT *)rs_trindex[ FCACHE ];
      CacheTree  = ( OBJECT *)rs_trindex[ CACHEOPT ];
      ad_scan    = ( OBJECT *)rs_trindex[ SCANMSG  ];
      ad_width   = ( OBJECT *)rs_trindex[ MAKEWID  ];
      ad_load    = ( OBJECT *)rs_trindex[ LOADING  ];
                        
      PrevTree   = ( OBJECT *)NULL;
                        
      /* Initialize the CPXINFO structure */           
      cpxinfo.cpx_call   = cpx_call;
      cpxinfo.cpx_draw   = NULL;
      cpxinfo.cpx_wmove  = NULL;
      cpxinfo.cpx_timer  = NULL;
      cpxinfo.cpx_key    = NULL;
      cpxinfo.cpx_button = NULL;
      cpxinfo.cpx_m1 	 = NULL;
      cpxinfo.cpx_m2	 = NULL;
      cpxinfo.cpx_hook   = NULL;
      cpxinfo.cpx_close  = NULL;
      
      return( &cpxinfo );
    }
}




/* cpx_call()
 * ====================================================================
 * IN: GRECT *rect:	Ptr to a GRECT that describes the current work
 *			area of the XControl window.
 *
 * OUT:
 *   FALSE:     The CPX has exited and no more messages are
 *		needed.  XControl will either return to its
 *		main menu or close its windows.
 *		This is used by XForm_do() type CPXs.
 *
 *   TRUE:	The CPX requests that XCONTROL continue to
 *		send AES messages.  This is used by Call-type CPXs.
 */
BOOLEAN
cdecl cpx_call( GRECT *rect )
{
     int  button;
     int  quit = 0;
     WORD msg[8];
     
     ActiveTree( Maintree );
     
     HideObj( BOTTOM2 );	/* Hide the 2 buttons */
     ShowObj( BOTTOM );
               
     ObX( ROOT ) = rect->g_x;
     ObY( ROOT ) = rect->g_y;

     initialize();
     Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
     CacheCheck( 0 );
     do
     {
	button = (*xcpb->Xform_do)( tree, 0, msg );

	/* MainTree Button Handling */
	if( IsActiveTree( Maintree ) )
	{
	    quit = handle_button( button, msg );
	    continue;
	}    


	/* Outline Button Handling */
	if( IsActiveTree( Oxtree ))
	{
	    quit = Outline_Buttons( button, msg );
	    continue;
	}    


	/* Point Size Button Handling */
	if( IsActiveTree( Oxsizes ))
	{
	    quit = Fsize_button( button, msg );
	    continue;
	}    


	/* New Point Size Button Handling */
	if( IsActiveTree( PtSizeTree ) )
	{
	    quit = New_Point_Size_Button( button, msg );
	    continue;
	}	    


	/* Set the FSM Cache Size */
	if( IsActiveTree( FsmTree ) )
	{
	    quit = FSM_Cache_Button( button, msg );
	    continue;
	}

	/* Cache Options Button Handling */
	if( IsActiveTree( CacheTree ) )
	{
	    quit = CacheButton( button, msg );
	    continue;
	}
		    
     }while( !quit);
     return( FALSE );
}



/* initialize()
 * ====================================================================
 * Initialize the variables and sliders before displaying the resource.
 */
void
initialize( void )
{
     long tst = '_FSM';
     
     Wind_get( 0, WF_WORKXYWH, ( WARGS *)&desk );

     fsel_init();
     
     gdos_flag = (( gdos_tst() != tst ) ? ( FALSE ) : ( TRUE ) );
     if( gdos_flag )
     {
        Num_Items_Deselected = GDOS_NO_FONT;
        Num_Items_Selected   = GDOS_YES_FONT;
     }
     else
     {
        Num_Items_Deselected = NO_GDOS_NO_FONT;
        Num_Items_Selected   = NO_GDOS_YES_FONT;
     }
     setup_title();

     MF_Save();     
     Scan_Message( ad_scan, TRUE );	
     read_fonts( 0 );	 
     Scan_Message( ad_scan, FALSE );
     MF_Restore();
     
     mover_setup( active_fsm_list, active_fsm_count,
		  BASE, SLIDER, UP, DOWN,
		  LINE0, LINE5, LINEBASE, 0 );

     Symbol_Change = FALSE;	/* Used to display the alert for
     				 * when a Symbol or Hebrew font changes.
     				 * Will be set to TRUE once displayed
     				 * so that it will not be showing more
     				 * than once EVER.
     				 */
     				 
     Make_Width_Flag = FALSE;   /* Init the make width tables flag
     				 * Used when we add a new point size
     				 * or add or delete a symbol/hebrew font.
     				 */   				 
}

 


/* setup_txt()
 * ====================================================================
 * Setup the Main Menu Command Lne Text, the Number of menu items
 * available and clear out the Symbol and Hebrew Font filenames.
 */
void
setup_title( void )
{
     Command_Value = ACTIVE;
     Status_Value  = INACTIVE;
     TedText( COMMAND ) = command_txt[ Command_Value ];
     num_menu_items = Num_Items_Deselected;
     Current.SymbolFont[0] = Current.HebrewFont[0] = '\0';
     ObString( OACTIVE ) = move2_txt[ Status_Value ];
}




/* Build_Menu()
 * ====================================================================
 * Builds the poup main menu items. This is needed because when FSM-GDOS
 * is installed, we shall display a 'Make Width Tables' option.
 */
void
Build_Menu( void )
{
     strcpy( menu_items[1], status_txt[ Status_Value ] );
     num_menu_items = (( IsChanged( hdptr ))? ( Num_Items_Selected ) : ( Num_Items_Deselected ) );
     if( !gdos_flag )	/* NO GDOS- #items is 2-3, GDOS #items = 4-5 */
         strcpy( menu_items[2], move_txt[ Status_Value ] );
     else
       strcpy( menu_items[4], move_txt[ Status_Value ] );
     
}



/* handle_button()
 * ====================================================================
 * Main Menu Button handling.
 */
int
handle_button( int button, WORD *msg )
{
   int     default_item = -1;
   int     quit = FALSE;
   BOOLEAN click_flag = FALSE;
   FON_PTR curptr;
   int     num;
      
   /* Handle Double-clicking of the objects */   
   if( ( button != -1 ) && ( button & 0x8000 ) )
   {
      click_flag = TRUE;
      button &= 0x7FFF;      
   }   
   
   switch( button )
   {
     case QUIT:    quit = TRUE;
     		   do_write_extend( FALSE );
     		   Deselect( QUIT );
     		   break;

     case OSAVE:   do_write_extend( TRUE );
     		   deselect( tree, OSAVE );
     		   break;

     case BOTTOM:     		   	   		
     case COMMAND:
		   Undo_Fnodes( hdptr, ( FON_PTR )NULL );
     		   break;

     case OACTIVE: Move_Fonts();
     		   deselect( tree, OACTIVE );
	           HideObj( BOTTOM2 );
                   ShowObj( BOTTOM );
                   Objc_draw( tree, BOTTOM, MAX_DEPTH, NULL );
     		   break;
     		   
     case OSET:    Deselect( OSET );
                   /* If we are in the inactive fonts, we don't
                    * want to listen to the Change_Flag or Make_Width_Flag.
                    * They'll be restored in do_points_size();
                    */
     		   Old_Change_Flag     = Change_Flag;
     		   Old_Make_Width_Flag = Make_Width_Flag;
		   Restore_Flags       = FALSE;
		     		   
    		   if( Status_Value == ACTIVE )
    		   {
       		      curptr        = fsm_list;
       		      Restore_Flags = TRUE;
       		   }   
   		   else
       		      curptr = active_fsm_list;
                   num = FindNumSelected( curptr );

      		   if( num )
      		   {
      		        if( num == 1 )
       	                  Do_Point_Sizes( OSET, 3 );
       	                else
       	                  Do_Point_Sizes( OSET, 2 );
       	           }
     		   break;
     		   	   		
     case MENU:
   		Build_Menu();
		Item = Pop_Handle( tree, MENU, menu_items,
			           num_menu_items, &default_item,
       			           IBM, MENU_WIDTH );
   		switch( Item )
   		{
		   case 0: /* font setup routines */
		   	   Do_Font_Setup();
		   	   break;
	   		   	   
		   case 1: /* Toggle Show Active/Inactive*/
		   	   Do_Status_Toggle();
		   	   break;

   		   case 2: /* Cache Functions*/
   		   	   if( gdos_flag )
   		   	   {
   		   	     Do_Cache_Options();
   		   	     break;
   		   	   }  
   		   	   
		   case 3: if( gdos_flag )
		           {
		             Make_Width_Table();
	   		     break;
	   		   }    
	   		   
 	   	   case 4: Move_Fonts();
		           HideObj( BOTTOM2 );
                   	   ShowObj( BOTTOM );
                   	   Objc_draw( tree, BOTTOM, MAX_DEPTH, NULL );
 	   	   	   break;
 	   	   	   
   		   default:
   		   	    break;
   		}
		break;

     case UP:
     case DOWN:
     case BASE:
     case SLIDER:
     case LINE0:
     case LINE1:
     case LINE2:
     case LINE3:
     case LINE4:
     case LINE5:
     		 mover_button( button, click_flag );
     		 break;
     			
     default:	 if( button == -1 )
     		 {
     		   switch( msg[0] )
     		   {
     		     case WM_REDRAW: 
     		     		     break;
     			     		     
     		     case AC_CLOSE:  quit = TRUE;
     		     		     break;
     				     		     
     		     case WM_CLOSED: quit = TRUE;
				     do_write_extend( FALSE );
				     break;
				     
				     /* Want only UNDO */
		     case CT_KEY:    if( msg[3] == UNDO )
		     			Undo_Fnodes( hdptr, ( FON_PTR )NULL );
		     		     break;
     		     default:
     		     		break;
     		   }
     		 }
     		 else
		     Undo_Fnodes( hdptr, ( FON_PTR )NULL );
     		 break;
   }
   return( quit );
}



/* Do_Status_Toggle()
 * ====================================================================
 * Status Change - 'Show Active Fonts' or 'Show Inactive Fonts'.
 */
void
Do_Status_Toggle( void )
{
    FON_PTR curptr;
    int     count;
    
    Undo_Fnodes( hdptr, ( FON_PTR )NULL );

    Command_Value = Status_Value;
    Status_Value ^= TRUE;

    if( Status_Value == ACTIVE )
    {
       Read_FSM_List();		/* if we don't have the inactive fonts yet */
       curptr = fsm_list;	/* Get them...only need to do this once    */
       count  = fsm_count;
    }
    else
    {
       curptr = active_fsm_list;
       count  = active_fsm_count;
    }
    mover_setup( curptr, count,
       	         BASE, SLIDER, UP, DOWN,
		 LINE0, LINE5, LINEBASE, 0 );

    Objc_draw( tree, BASE, MAX_DEPTH, NULL );
    Objc_draw( tree, LINEBASE, MAX_DEPTH, NULL );
			   	   			   
    TedText( COMMAND ) = command_txt[ Command_Value ];
    ObString( OACTIVE ) = move2_txt[ Status_Value ];
    Objc_draw( tree, COMMAND, 0, NULL );
}



/* Reset_Tree()
 * ====================================================================
 * Make the incoming tree the active tree setting the x,y coordinates
 * at the same time.
 */
void
Reset_Tree( OBJECT *xtree )
{
  int x,y;
  
  x = ObX( ROOT );
  y = ObY( ROOT );
  ActiveTree( xtree );
  ObX( ROOT ) = x;
  ObY( ROOT ) = y;
}





/* Move_Fonts()
 * ====================================================================
 * The menu item was selected to move the font names from
 * the 'Active' List to the 'Inactive List' or vice versa.
 * We redraw after readjusting the linked lists.
 */
void
Move_Fonts( void )
{
    FON_PTR curptr;
    int	    New_SEL;
    FON_PTR tptr;
    int     count;
    FON_PTR xcurptr;
    int     index;
            
    if( Status_Value )	/* Moving Fonts to INACTIVE STATUS */
    {
        New_SEL = FALSE;
        curptr = active_fsm_list;
    }
    else
    {			/* Moving Fonts to ACTIVE STATUS */
       New_SEL = TRUE;
       curptr = fsm_list;
       
       /* Prompt to make width tables for fonts moving TO
        * ACTIVE status.
        */
       Make_Width_Flag = TRUE;
    }

    xcurptr = Active_Slit[ 0 ];
    if( curptr && xcurptr )
    	index = Get_Findex( curptr, xcurptr );
    	
    while( curptr )
    {
       if( AFLAG( curptr ) )
           SEL( curptr ) = New_SEL;
       curptr = FNEXT( curptr );
    }
    
    free_fsm_links();
    fsm_count = build_fsm_list( &fsm_list, &fsm_last, INACTIVE );
    active_fsm_count = build_fsm_list( &active_fsm_list, &active_fsm_last, ACTIVE );
    Check_Symbols();


    if( !Status_Value )
    {
       tptr  = fsm_list;
       count = fsm_count;
    }
    else
    {
       tptr  = active_fsm_list;
       count = active_fsm_count;
    }
    
    mover_setup( tptr, count,
                 BASE, SLIDER, UP, DOWN,
  		 LINE0, LINE5, LINEBASE, index );
    
    Objc_draw( tree, LINEBASE, MAX_DEPTH, NULL );
    Objc_draw( tree, BASE, MAX_DEPTH, NULL );        
    
    /* Always prompt to save the EXTEND.SYS */
    Change_Flag = TRUE;
    CacheCheck( 0 );
}




/* Return_To_Maintree()
 * ====================================================================
 *  Return from one tree to another tree redrawing the new tree
 *  in the process.
 */
void
Return_To_Maintree( OBJECT *Want_This_Tree )
{
   FON_PTR curptr;
   int	   count;

   Reset_Tree( Want_This_Tree );     		    

   if( IsActiveTree( Maintree ) )
   {
     if( Status_Value == ACTIVE )
     {
         curptr = fsm_list;
         count  = fsm_count;
     }
     else
     {
         curptr = active_fsm_list;
         count  = active_fsm_count;
     }
     mover_setup( curptr, count,
                  BASE, SLIDER, UP, DOWN,
                  LINE0, LINE5, LINEBASE, Old_Cur_Slit );
   }
		       		     
   Objc_draw( tree, ROOT, MAX_DEPTH, NULL );   		  
}



/* do_write_extend()
 * ====================================================================
 * Write out the 'EXTEND.SYS' file.
 */
BOOLEAN
do_write_extend( BOOLEAN flag )
{
   BOOLEAN xflag  = FALSE;
   BOOLEAN result = FALSE;
   
   if( flag || Change_Flag )
   {
     if( flag )
        result = form_alert( 1, alert0 );
     else
        result = form_alert( 1, alert1 );
        
     if( result == 1 )
     {
         MF_Save();
         write_extend();
         MF_Restore();
         xflag = TRUE;  
	 CachePrompt();

         /* Prompt to user to make width tables if necessary */
         if( Make_Width_Flag )
         {
           if( gdos_flag && Current.Width )
           {
             if( form_alert( 1, alert23 ) == 1 )
                 Make_Width_Table();
           }    
         }
         Change_Flag = FALSE;
     }
   }
   return( xflag );  
}


/* write_extend()
 * ====================================================================
 * Write the EXTEND.SYS without any prompt.
 * Called only by Make Width Tables()
 */
void
fast_write_extend( void )
{
    MF_Save();
    write_extend();
    MF_Restore();
}



/* MF_Save()
 * ====================================================================
 * Save the current mouse image.
 */
void
MF_Save( void )
{
/*   (*xcpb->MFsave)( MFSAVE, &Mbuffer );*/
   graf_mouse( BUSYBEE, 0L );
}



/* MF_Restore()
 * ====================================================================
 * Restore the previously saved mouse image.
 */
void
MF_Restore( void )
{
/*  (*xcpb->MFsave)( MFRESTORE, &Mbuffer );*/
   graf_mouse( ARROW, 0L );
}




/* open_vwork()
 * ====================================================================
 * Open the virtual workstation. ( Note that the workstation should
 * be closed after doing whatever you have to do. )
 * OUT: 0 - failed
 *      non-zero = handle
 *      vhandle == new handle tho...
 */
int
open_vwork( void )
{
	int i;
	
	work_in[0] = Getrez() + 2;
	for( i = 1; i < 10; work_in[i++] = 1 );
	work_in[10] = 2;
	vhandle = xcpb->handle;
	v_opnvwk( work_in, &vhandle, work_out );
	return( vhandle );
}




/* close_vwork()
 * ====================================================================
 * Close the virtual workstation.
 */
void
close_vwork( void )
{
   if( vhandle )
   {
      v_clsvwk( vhandle );
      vhandle = 0;
   }
}




/* Open_Scanning()
 * ====================================================================
 * Displays the dialog box using 'Tree';
 * IN: flag = TRUE  - Display the dialog box.
 *          = FALSE - Generate the Redraw Message
 */
void
Scan_Message( OBJECT *Tree, BOOLEAN flag )
{  
     static GRECT rect;
     static GRECT xrect;
     
     if( flag )
     {
       xrect.g_x = xrect.g_y = 10;
       xrect.g_w = xrect.g_h = 36;
   
       Form_center( Tree, &rect );
       Form_dial( FMD_START, &xrect, &rect );
       Objc_draw( Tree, ROOT, MAX_DEPTH, &rect );
     }
     else
       Form_dial( FMD_FINISH, &xrect, &rect );
}


