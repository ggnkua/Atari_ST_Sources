/* FILE:  MOVER.C
 *==========================================================================
 * DATE:  May 16, 1990
 * DESCRIPTION: MOVER/RENAME Function handling. Called from XOPTIONS.
 *		This code handles the hot scrolling/ selecting/ deselecting
 *		of CPXs to CPZs.
 *
 * INCLUDE FILE: MOVER.H
 *
 * 07/07/92 cjg - Save and restore mouse form only if AES version 3.2 or >
 *		  Skip changing mouse form otherwise...
 * 09/30/92 cjg - Fixed Mover Slider Redraws when mover_text is pressed.
 *
 * 12/16/92 cjg - Make sure open_vwork() exits if fails.
 */


/* INCLUDE FILES
 *==========================================================================
 */
#include <sys\gemskel.h>
#include <sys\gemerror.h>

#include <string.h>
#include <tos.h>
#include <stdlib.h>

#include "country.h"
#include "xcontrol.h"				/* Xcontrol.c defines   */

#include "cpxdata.h"				/* Keep these in order..*/
#include "xstructs.h"
#include "cpxhandl.h"				
#include "xcontrl2.h"				/* Xcontrol.c prototypes*/
#include "windows.h"
#include "xerror.h"
#include "sliders.h"
#include "stuffptr.h"
#include "xconfig.h"
#include "xoptions.h"
#include "text.h"


EXTERN int AES_Version;
EXTERN int gl_ncolors;

/* PROTOTYPES
 *==========================================================================
 */
 
/* Interface Routines */
BOOLEAN do_mover( void );
BOOLEAN	move_setup( void );

BOOLEAN mover_button( int obj );
BOOLEAN mover_keys( void );
int	Rename( int flag );
int	Mover_Alert( char filename[], char text1[], char text2[], char text3[] );


/* Linked List Handling */
void	Init_Fnode( FNODE *ptr, BOOLEAN flag );
FNODE	*Get_Fnodes( int *total, char *pattern, BOOLEAN flag );
void	Delete_Fnodes( void );
void	Free_Fnodes( FNODE *hdptr );
void	Undo_Fnodes( FNODE *ptr, BOOLEAN flag );
BOOLEAN IsChanged( FNODE *ptr );
FNODE	*Find_Fnode( FNODE *ptr, int index );



/* Slit handling */
void  	Draw_ASlit( void );
void  	Draw_ISlit( void );
void	Draw_IHot( void );
void	Draw_AHot( void );
void  	slit_offset_adjust( FNODE *ptr, int value, FNODE *array[], BOOLEAN flag );
void	Assign_Slit( FNODE *ptr, FNODE *array[], BOOLEAN flag );
void	blit_slits( BOOLEAN flag, int old_slit, int new_slit );



/* Hot and Cold Scroll Handlers */
void	Set_Move_Text( int flag );
void	Make_Hot_Spots( int top_object );

int	Get_Findex( FNODE *tptr, FNODE *ptr );
int	Get_Hot_Index( int *hot_index );


FNODE	*Hot_Old_New_Update( int index, FNODE *Top_Node,
		     	     int old_index, int findex,
		     	     int Top_Obj, FNODE *Slit_Array[] );

void	Old_Index_Handler( int old_index, int new_index, int findex,
		   	   FNODE *Top_Node, FNODE *Base_Node,
		   	   int Above_Obj, int Below_Obj );
void	New_Index_Handler( int old_index, int new_index, int findex,
			   FNODE *Top_Node, FNODE *Base_Node,
			   int Above_Obj, int Below_Obj );
void	Hot_Scroll( FNODE *Xptr, int cur_slit, int First_Obj, int End_Obj );
void	Do_Hot_Scroll( int obj, FNODE *Top_Node, FNODE *base_node,
		       FNODE *Other, int Top_Obj, int Total,
	       	       int Xbase, int Xslider, int *cur_slit,
		       FNODE *Slit_Array[], void (*foo)() );
		     	     




/* EXTERNAL PROTOTYPES */

/* Note: This EXTERN prototype came from CPXHANDLE.C */
DTA	*Set_DTA( DTA *thedta );

/* Note: This EXTERN prototype came from POPUP.C */
int rub_wait( GRECT *obj, int dir, int state );

WORD	ChkTouchButton( OBJECT *tree, WORD button );
void	xselect( OBJECT *tree, int base, int obj );
void	xdeselect( OBJECT *tree, int base, int obj );



/* DEFINES
 *==========================================================================
 */
#define TO_NONE		0
#define TO_ACTIVE	1
#define TO_INACTIVE	2


#define ACTIVE_FNODE	1
#define INACTIVE_FNODE  0

#define MAX_SLITS	5			/* Number of Slits for the
						 * FNODE linked list menu
						 */


/* MOVER/RENAME VARIABLES */

char fblank[] = "________";	/* The blank string for the filenames    */
FNODE *Ahdptr = NULL;		/* Active FNODE Pointer Head		 */
FNODE *Ihdptr = NULL;		/* Inactive FNODE Pointer Head		 */
int   Atotal;			/* Total 'Active' filenames		 */
int   Itotal;			/* Total 'Inactive' filenames		 */
FNODE  *Active_Slit[5];		/* These are arrays of FNODE pointers    */
FNODE  *InActive_Slit[5];       /* which are used to point to the fnode
    				 * that is in its slot. That way we can
    				 * quickly get the information from the
    				 * node. If the fnode is NULL, we set the
    				 * text to point to fblank[]
    				 */
    				 
int   Text_Index = TO_NONE;	/* Index into the slit_text[] array for
				 * printing the direction text for
				 * the Filename xconfig routines.
				 */    				 
int   Cur_ISlit, Old_ISlit;    				 
int   Cur_ASlit, Old_ASlit;	/* The index INTO the filename linked list
				 * so that we can count INTO it and find
				 * an offset for the top node. I = Inactive
				 * and A = Active
				 */
GRECT hot_spot[7];		/* Grect(s) for the 5 filename buttons plus
				 * one above and one below. They are 
				 * created ONLY when a filename button 
				 * object is selected: A0-A4 or I0-I4.
				 */
int   hot_index;   		/* Index for Hot_Spot[] 
				 * Hot_Spot[] is an array of grects which is
				 * defined when the user clicks on a filename.
				 * The GRECTS are the boxes where we look to
				 * see where the mouse IS, and WAS so that
				 * we can select, deselect or scroll the
				 * filenames.
				 */
FNODE *Base_Node; 		/* The node the scroll started with */
int   new_index;		/* NEW index into linked list ( zero based ) */
int   findex;			/* node index INTO the linked list ( zero based )
				 * This is the one that was first clicked on
				 * and started all of the scrolling.
				 * NOTE: findex's node is Base_Node.
				 */
				
char src_fname[128];		/* Active and Inactive source paths */
char dst_fname[128];
				
/* FUNCTIONS
 *==========================================================================
 */
 


/*
 *==========================================================================
 * Interface Routines
 *==========================================================================
 */
 
/* do_mover
 *==========================================================================
 * Displays the CPX Active and Inactive files in the CPX directory.
 * Allows one to toggle CPXs to active and inactive states and to
 * reload the CPXs.
 * NOTE: This is the entry point into the MOVER/RENAME utility. 
 */
BOOLEAN
do_mover( void )
{
    OBJECT *tree = ( OBJECT *)rs_trindex[ MOVECPX ];

    xtree = tree;
    
    ObX( ROOT ) = w.phy.g_x;
    ObY( ROOT ) = w.phy.g_y;
    
    if( move_setup() )
    {
       Text_Index = TO_NONE;      
       TedText( MOVETEXT ) = slit_text[ Text_Index ];
       
       SetNormal( ROK );
       SetNormal( MOVETEXT );
       HideObj( MOVETEXT );
       Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
       return( TRUE );
    }
    else
    {
       tree = xtree = ( OBJECT *)rs_trindex[ XINFO ];
       return( FALSE );
    }   
}





/* move_setup()
 *==========================================================================
 * Allocates memory and sets up the active and inactive scroll linked lists.
 * RETURNS TRUE - SUCCESS
 *	   FALSE- ERROR! ( probably memory allocation )
 */
BOOLEAN
move_setup( void )
{
    OBJECT *tree = ( OBJECT *)rs_trindex[ MOVECPX ];
    int i;
    
    for( i = 0; i < 5;i++ )
    {
        Active_Slit[i] = InActive_Slit[i] = NULL;
        TedText( A0 + i ) = fblank;
        TedText( I0 + i ) = fblank;
    }
    Ahdptr = Get_Fnodes( &Atotal, "*.CPX", ACTIVE_FNODE ); 
    Ihdptr = Get_Fnodes( &Itotal, "*.CPZ", INACTIVE_FNODE );

    if(( Atotal != -1 ) && ( Itotal != -1 ) )
    {
       Old_ASlit = Cur_ASlit = 0;
       Old_ISlit = Cur_ISlit = 0;
       ObY( ASLIDER ) = ObY( ISLIDER ) = 0;
       sl_size( tree, ABASE, ASLIDER, Atotal, 5, VERTICAL, 0 );
       sl_size( tree, IBASE, ISLIDER, Itotal, 5, VERTICAL, 0 );
       
       Assign_Slit( Ahdptr, Active_Slit, ACTIVE_FNODE );
       Assign_Slit( Ihdptr, InActive_Slit, INACTIVE_FNODE );
       return( TRUE );
    }
    else
    {
      /* Memory Allocation Error! */
      XGen_Alert( MEM_ERR ); 
      Delete_Fnodes();
      return( FALSE );
    }  
  
}





/* mover_button()
 *==========================================================================
 * Handles the button events for the CPX Mover/Rename Function
 * IN: int obj:		The RCS Object clicked on.
 * OUT: BOOLEAN:   TRUE - Exit the CPX Mover Config
 *		   FALSE - Remain in the CPX Mover Config
 */
BOOLEAN
mover_button( int obj )
{
   OBJECT *tree = xtree;
   BOOLEAN flag = FALSE;
   MRETS   mk;
   int     ox,oy;
   GRECT   rect;
      
   if( xtree == ( OBJECT * )rs_trindex[ MOVECPX ] )
   {
        Old_ASlit = Cur_ASlit;
        Old_ISlit = Cur_ISlit;
       /* Change INFO TREE from RENAME BACK to XINFO tree
        * We are in the MOVER/RENAME box, so wait for the button to be 
        * raised before exiting back to XINFO
        */
        switch( obj )
        {
	   /* These are the 'Active' or 'CPX' Slider Routines */
           case AUP:	  Undo_Fnodes( Ihdptr, INACTIVE_FNODE );      
	   		  Set_Move_Text( TO_INACTIVE );
           		  sl_arrow( tree, ABASE, ASLIDER, AUP, -1,
           			    max( Atotal - MAX_SLITS, 0 ), 0,
           			    &Cur_ASlit, VERTICAL, Draw_ASlit );
			  break;
			  
           case ADOWN:	  Undo_Fnodes( Ihdptr, INACTIVE_FNODE );    
	   		  Set_Move_Text( TO_INACTIVE );
           		  sl_arrow( tree, ABASE, ASLIDER, ADOWN, 1,
           			    max( Atotal - MAX_SLITS, 0 ), 0,
           			    &Cur_ASlit, VERTICAL, Draw_ASlit );
           		  break;
           		  
           case ASLIDER:  Undo_Fnodes( Ihdptr, INACTIVE_FNODE );
	   		  Set_Move_Text( TO_INACTIVE );
	   		  MFsave( MFSAVE, &mfOther );
		 	  if( AES_Version >= 0x0320 )	/* cjg 07/07/92 */
	   		     graf_mouse( FLAT_HAND, 0L );
	   		     
	   		  if(( AES_Version >= 0x0330 )
		              && ( gl_ncolors > LWHITE ))
	   		    xselect( tree, ASLIDER, ASLIDER );   
           		  sl_dragy( tree, ABASE, ASLIDER,
           			    max( Atotal - MAX_SLITS, 0 ), 0,
           			    &Cur_ASlit, Draw_ASlit );
 
 			  if(( AES_Version >= 0x0330 )
		               && ( gl_ncolors > LWHITE ))
 		  	     xdeselect( tree, ASLIDER, ASLIDER );          			    
           		  MFsave( MFRESTORE, &mfOther );
           		  break;
           		  
           case ABASE:	  Undo_Fnodes( Ihdptr, INACTIVE_FNODE );
           		  Graf_mkstate( &mk );
           		  objc_offset( tree, ASLIDER, &ox, &oy );
           		  ox = (( mk.y < oy ) ? ( -MAX_SLITS ) : ( MAX_SLITS ) );
           		  sl_arrow( tree, ABASE, ASLIDER, -1, ox,
           		  	    max( Atotal - MAX_SLITS, 0 ), 0,
           		  	    &Cur_ASlit, VERTICAL, Draw_ASlit );
           		  break;


	   /* These are the 'InActive' or 'CPZ' Slider Routines */
           case IUP:	  Undo_Fnodes( Ahdptr, ACTIVE_FNODE );
	   		  Set_Move_Text( TO_ACTIVE );
           		  sl_arrow( tree, IBASE, ISLIDER, IUP, -1,
           			    max( Itotal - MAX_SLITS, 0 ), 0,
           			    &Cur_ISlit, VERTICAL, Draw_ISlit );
			  break;
			  
           case IDOWN:	  Undo_Fnodes( Ahdptr, ACTIVE_FNODE );
	   		  Set_Move_Text( TO_ACTIVE );
           		  sl_arrow( tree, IBASE, ISLIDER, IDOWN, 1,
           			    max( Itotal - MAX_SLITS, 0 ), 0,
           			    &Cur_ISlit, VERTICAL, Draw_ISlit );
           		  break;
           		  
           case ISLIDER:  Undo_Fnodes( Ahdptr, ACTIVE_FNODE );
	   		  Set_Move_Text( TO_ACTIVE );
		          MFsave( MFSAVE, &mfOther );
		 	  if( AES_Version >= 0x0320 )	/* cjg 07/07/92 */
	                     graf_mouse( FLAT_HAND, 0L );
	   		  
	   		  if(( AES_Version >= 0x0330 )
		               && ( gl_ncolors > LWHITE ))
	   		     xselect( tree, ROOT, ISLIDER );
	   		     
           		  sl_dragy( tree, IBASE, ISLIDER,
           			    max( Itotal - MAX_SLITS, 0 ), 0,
           			    &Cur_ISlit, Draw_ISlit );
           			    
           		  if(( AES_Version >= 0x0330 )
		               && ( gl_ncolors > LWHITE ))
           		     xdeselect( tree, ROOT, ISLIDER );	    
           		  MFsave( MFRESTORE, &mfOther );	    
           		  break;
           		  
           case IBASE:	  Undo_Fnodes( Ahdptr, ACTIVE_FNODE );
	   		  Set_Move_Text( TO_ACTIVE );
           		  Graf_mkstate( &mk );
           		  objc_offset( tree, ISLIDER, &ox, &oy );
           		  ox = (( mk.y < oy ) ? ( -MAX_SLITS ) : ( MAX_SLITS ) );
           		  sl_arrow( tree, IBASE, ISLIDER, -1, ox,
           		  	    max( Itotal - MAX_SLITS, 0 ), 0,
           		  	    &Cur_ISlit, VERTICAL, Draw_ISlit );
           		  break;

	   /* CPX filename buttons */           		  
	   case A0:
	   case A1:
	   case A2:
	   case A3:
	   case A4:	  Do_Hot_Scroll( obj, Ahdptr, Active_Slit[ obj - A0 ],
	   				 Ihdptr, A0, Atotal,
	   				 ABASE, ASLIDER, &Cur_ASlit,
	   				 Active_Slit, Draw_AHot );
	   		  break;
	   		  		 
	   /* CPZ filename buttons */
           case I0:
           case I1:
           case I2:
           case I3:
	   case I4:	 Do_Hot_Scroll( obj, Ihdptr, InActive_Slit[ obj - I0 ],
				        Ahdptr, I0, Itotal,
				        IBASE, ISLIDER, &Cur_ISlit,
				        InActive_Slit, Draw_IHot );

           		 break;

           case MOVETEXT: if( Text_Index != TO_NONE )
           		  {
			   if( ChkTouchButton( tree, MOVETEXT ) )
			   {
/*			   
           		    xselect( tree, ROOT, MOVETEXT );
           		    wait_up();
 */           		    
           		    Graf_mkstate( &mk );
           		    flag = objc_find( tree, MOVETEXT, MAX_DEPTH, mk.x, mk.y );
			    if( flag != -1 )
			    {
			      MFsave( MFSAVE, &mfOther );
		 	      if( AES_Version >= 0x0320 )	/* cjg 07/07/92 */
			         graf_mouse( BUSYBEE, 0L );
			    
           		      Rename( Text_Index );
           		      Set_Move_Text( TO_NONE );
           		      Delete_Fnodes();
           		      /* Redo the nodes and redraw */
           		      if( move_setup() )
           		      {
			          Objc_draw( tree, ATEXT, MAX_DEPTH, NULL );
			          Objc_draw( tree, ITEXT, MAX_DEPTH, NULL );

	   		          if(( AES_Version >= 0x0330 )
		                      && ( gl_ncolors > LWHITE ))
			          {
				    rect = ObRect( ABASE );
				    objc_offset( tree, ABASE, &rect.g_x, &rect.g_y );
				    rect.g_x -= 2;
				    rect.g_y -= 2;
				    rect.g_w += 4;
				    rect.g_h += 4;		          
			            Objc_draw( tree, ABASE, MAX_DEPTH, &rect );

				    rect = ObRect( IBASE );
				    objc_offset( tree, IBASE, &rect.g_x, &rect.g_y );
				    rect.g_x -= 2;
				    rect.g_y -= 2;
				    rect.g_w += 4;
				    rect.g_h += 4;		          
			            Objc_draw( tree, IBASE, MAX_DEPTH, &rect );

			          }
			          else
			          {
			            Objc_draw( tree, ABASE, MAX_DEPTH, NULL );
			            Objc_draw( tree, IBASE, MAX_DEPTH, NULL );
			          }
			          flag = FALSE;
           		      }
           		      else
           		      {
           		         /* Memory error occurred...so exit.
           		          * The nodes were already de-allocated
           		          */
           		         flag = TRUE;
           		      }
       		              MFsave( MFRESTORE, &mfOther );

			    }
			    else
			      flag = FALSE;
			   }   
/*			    xdeselect( tree, ROOT, MOVETEXT );*/
			    if( IsSelected( MOVETEXT ) )
			        xdeselect( tree, ROOT, MOVETEXT );
			  }
			  wait_up();  
           		  break;
           		  		 
           case ROK: if( ChkTouchButton( tree,  ROK ) )
		     {
           	         flag = TRUE;
           		 Delete_Fnodes();
 		     }          		 
           	     break;
           		
           default:	 flag = FALSE;
           		 Set_Move_Text( TO_NONE );
			 Undo_Fnodes( Ahdptr, ACTIVE_FNODE );
			 Undo_Fnodes( Ihdptr, INACTIVE_FNODE );
          		 break;
        }
        
        
        /* We are returning to the XINFO Tree, so
         * restore the tree and redraw.
         */
        if( flag )
        {
           select( xtree, obj );
           wait_up();

           tree = xtree = ( OBJECT *)rs_trindex[ XINFO ];
           ObX( ROOT ) = w.phy.g_x;
           ObY( ROOT ) = w.phy.g_y;
           do_redraw( xtree, ROOT, &w.phy );
        }
        flag = TRUE;   
   }
   return( flag );
}







/* mover_keys()
 *==========================================================================
 * Handle the RENAME/MOVER XCONFIG KEYBOARD handling.
 * IN: void
 * OUT: BOOLEAN - 	TRUE - Exit the Mover Functions
 *			FALSE - Don't exit
 */
BOOLEAN
mover_keys( void )
{
   OBJECT *tree;
   BOOLEAN flag = FALSE;
      
   if( xtree == ( OBJECT *)rs_trindex[ MOVECPX ] )
   {
      Delete_Fnodes();
      tree = xtree = ( OBJECT *)rs_trindex[ XINFO ];
      ObX( ROOT ) = w.phy.g_x;
      ObY( ROOT ) = w.phy.g_y;
      do_redraw( xtree, ROOT, &w.phy );
      flag = TRUE;
   }
   return( flag );
}






/* Rename()
 *==========================================================================
 * This routine will perform the actual renaming of a file from
 * CPX to CPZ and vice versa.
 * IN:	int flag:	TO_NONE | TO_ACTIVE | TO_INACTIVE
 *
 * RETURN: -1 = error
 *          0 = OK
 *          1 = Cancel
 */
int
Rename( int flag )
{
   FNODE *Head_Node = NULL;
   char *fname;
   int   error, error2;
   FNODE *curptr = NULL;
   long i;
   int   status = 0;
   
   if( flag != TO_NONE )		
   {
      Head_Node = (( flag == TO_ACTIVE ) ? ( Ihdptr ) : ( Ahdptr ) );
      if( Head_Node )
      {
#if 0
 		              		    error2 = Mover_Alert( Head_Node->fname, Alert1A, Alert1B,
		              		    			 (( flag == TO_ACTIVE ) ? ( ".CPX" ) : ( ".CPZ" ) ) );
		              		    error2 = Mover_Alert( Head_Node->fname, Alert2A, Alert2B,
		              		    			  (( flag == TO_ACTIVE ) ? ( ".CPZ" ) : ( ".CPX" ) ) );
      		             	   	    error2 = form_alert( 1, Alert3 );
#endif
          /* Make sure there are any files that need to be renamed */
	  if( IsChanged( Head_Node ) )
	  {
              curptr = Head_Node;
	      while( curptr )
	      {
		 if( curptr->aflag )	
		 {
retry:		     fname = make_path( curptr->fname , dirpath );
		     for( i = strlen( fname ) - 1L; i && fname[i] == ' ';fname[i--] = '\0' );
		     strcpy( dst_fname, fname );
		     strcpy( src_fname, fname );
		     strcat( dst_fname,   (( flag == TO_ACTIVE ) ? ( ".CPX" ) : ( ".CPZ" ) ) );
		     strcat( src_fname,   (( flag == TO_ACTIVE ) ? ( ".CPZ" ) : ( ".CPX" ) ) );
		     
		     error = Frename( 0, src_fname, dst_fname );		       
		     if( error )
		     {	    /* An Error of some sort has occurred .
		     	     * We will handle only 'Destination File Exists' and
		     	     * 'Source file not found'.  All other errors will be
		     	     * treated as a 'Critical File Error'.
		     	     */
		     	    switch( error )
		     	    {
		              case EACCDN:  /* Destination File Exists */
		              		    error2 = Mover_Alert( curptr->fname, Alert1A, Alert1B,
		              		    			 (( flag == TO_ACTIVE ) ? ( ".CPX" ) : ( ".CPZ" ) ) );
		             	   	    break;
		             	   	    
		              case EFILNF:  /* Source file not found */
		              		    error2 = Mover_Alert( curptr->fname, Alert2A, Alert2B,
		              		    			  (( flag == TO_ACTIVE ) ? ( ".CPZ" ) : ( ".CPX" ) ) );
					    break;
					    
			      default:	    /* File I/O Error */
     		             	   	    error2 = form_alert( 1, Alert3 );
     		             	   	    break;
		            }
		             	   

			    /* Handle the Buttons pressed from the alert. button 1, 2 or 3 */
		            switch( error2 )
		            {
		               case 1:  if( error == EACCDN )
		               		{
		               		   /* Copy button. Delete destination file, then rename again.
		               		    * Regardless of the outcome of the delete(), we will
		               		    * try again to rename.  They can either cancel or whatever.
		               		    */
		               		   Fdelete( dst_fname );
		               		   goto retry;
		     			}
		     			 /* For others, we skip to next iteration */  
		                        break;
		                        
		               case 2:  /* Skip Button, just go on to next iteration for destination file exists*/
		               		/* But for others, its try again */
		               		if( error != EACCDN )
		               			goto retry;
		               		break;
		               		
		               case 3:  /* Cancel Button pressed...Just return
		                         * with -1 to signify that we returned because
		                         * an error occurred. ( We pressed Cancel to get out )
		               		 */
		               	        return( -1 );
					/* Don't have a 'break' here, cause Turbo C thinks its unreachable */		               	           
					
		               default:
		               		break;		
		            }   
		     }			/* End of 'if( error )' 	  */
		 }
		 curptr = curptr->next;	      
	      }				/* End of 'while( curptr )'       */      	      
          }				/* End of 'if( IsChanged() )' 	  */
      }   				/* End of 'if( Head_Node )' 	  */
   }      				/* End of 'if( flag != TO_NONE )' */
   return( status );
}




/* Mover_Alert()
 *==========================================================================
 * Form_Alert Setup for 2 Error Messages: EACCDN and EPTHNF
 * found in the 'Rename()' function only.
 * IN:	char *filename:	The 8 character filename
 *	char *text1:	The first part of the alert message
 *	char *text2:	The second part of the alert message
 *	char *text3:	The extender to use ( CPX or CPZ )
 *
 * OUT: int:	1,2,3 The button number from left to right
 */
int
Mover_Alert( char *filename, char *text1, char *text2, char *text3 )
{
   long i;
   
   strcpy( newpath, text1 );
   strcat( newpath, filename );
   for( i = strlen( newpath ) - 1L; i && newpath[ i ] == ' '; newpath[ i-- ] = '\0' );
   strcat( newpath, text3 );
   strcat( newpath, text2 );
   return( form_alert( 1, newpath ) );
}








/*
 *==========================================================================
 * Linked List Handling
 *==========================================================================
 */



/* Init_Fnode()
 *==========================================================================
 * Initialize a Filename Node ( FNODE ).
 * IN: 	FNODE *ptr:	The node to initialize
 *	BOOLEAN flag:	TRUE - This is an Active filename ( CPX )
 *			FALSE - This is InActive ( CPZ )
 */
void
Init_Fnode( FNODE *ptr, BOOLEAN flag )
{
    if( ptr )
    {
        strcpy( ptr->fname, fblank );
        ptr->aflag = ptr->sflag = FALSE;
        ptr->mflag = flag;
	ptr->next = NULL;
    }
}



/* Get_Fnodes()
 *==========================================================================
 * Malloc a linked list of Filename Nodes by using Fsfirst and Fsnext
 * Return the number of nodes malloced with hdptr pointing to the
 * first node, OR, return -1 meaning ERROR.
 * Also, initialize the nodes.
 * IN:	int *total:	The total number of nodes for this tree.
 *	char *pattern:	The type of file to look for ( CPX or CPZ )
 *	BOOLEAN flag:	TRUE - Active CPX Linked List
 *			FALSE - CPZ Linked List
 *
 * OUT: FNODE *ptr	Return a pointer to the parent node
 */
FNODE
*Get_Fnodes( int *total, char *pattern, BOOLEAN flag )
{
   int count = 0;
   FNODE *curptr = NULL;
   FNODE *newptr = NULL;
   FNODE *ptr    = NULL;
   DTA thedta, *saved;
   char *filename;
   char fname[15];
   long i;
     
   saved = Set_DTA( &thedta );
   filename = make_path( pattern, dirpath );

   /* Get the Total Number of Nodes Needed */
   if( Fsfirst( filename, 0x01 ) == 0 )
   {
      do
      {
          count++;
      }while( Fsnext() == 0 );
   }
      
   if( count )
   {
      newptr = ( FNODE *)Malloc( (long )(( long )count * sizeof( FNODE )) );
      if( !newptr )
      {
          *total = -1;
	  Fsetdta( saved );
          return( newptr );
      }

      /* We now have one large buffer, and must now assign ptrs */  
      if( Fsfirst( filename, 0x01 ) == 0 )
      {
         do
         {
            if( ptr == NULL )
               ptr = curptr = newptr;
            else
            {
                ptr++;
                curptr->next = ptr;
                curptr = curptr->next;
            }
            Init_Fnode( curptr, flag );
   	    strcpy( fname, "               " );
   	    strcpy( fname, thedta.d_fname );
   	   
   	    /* Put ' ' at the end up to and including the '.' of the fname*/
   	    for( i = strlen( fname ); i && ( fname[i] != '.' );
   	   	fname[i--] = ' ');
   	    fname[i] = ' ';	           /* zero out the '.' */	
            strncpy( curptr->fname, fname, 8);
         }while( Fsnext() == 0 );
      }
   }
   
   Fsetdta( saved );
   *total = count;
   return( newptr );
}




/* Delete_Fnodes()
 *==========================================================================
 * Free up the malloced linked list of filename nodes for both
 * Active and Inactive nodes. ( CPX and CPZs )
 */
void
Delete_Fnodes( void )
{
    if( Ahdptr )
    	Mfree( Ahdptr );
    if( Ihdptr )
        Mfree( Ihdptr );
    Ahdptr = Ihdptr = NULL;    
}





/* Undo_Fnodes()
 *==========================================================================
 * Deselects any Slits visible. Also, it goes down the slit ptr passed in,
 * and undo's any changes made to the filename.
 *
 * IN: 	FNODE *ptr:	Head Node pointer to the linked list.
 * 	BOOLEAN flag:	Defines which linked list to clear out.
 */
void
Undo_Fnodes( FNODE *ptr, BOOLEAN flag )
{
    OBJECT *tree = ( OBJECT *)rs_trindex[ MOVECPX ];
    FNODE *curptr;
    int obj;
    int i;
    
    obj = (( flag == ACTIVE_FNODE ) ? ( A0 ) : ( I0 ) );
    
    /* Here we restore whatever the previous state was */
    curptr = ptr;
    while( curptr )
    {
        curptr->aflag = curptr->sflag = FALSE;   
        curptr = curptr->next;
    }
    
    for( i = 0; i < MAX_SLITS; i++ )
        deselect( tree, obj + i );

}







/* IsChanged()
 *==========================================================================
 * Used to see if any FNODES in the filename linked list has been 
 * changed opposite from its aflag <=> sflag
 * FNODE *ptr:	The head filename node for that linked list
 *
 * RETURN: TRUE  - YES
 *	   FALSE - NO
 */
BOOLEAN
IsChanged( FNODE *ptr )
{
   FNODE *curptr;
   BOOLEAN flag = FALSE;
   
   curptr = ptr;
   while( curptr )
   {
       if( curptr->aflag )
       {
           flag = TRUE;
           break;
       }
       curptr = curptr->next;   
   }
   return( flag );
}








/*
 *==========================================================================
 * Linked List Handling
 *==========================================================================
 */



/* Assign_Slit()
 *==========================================================================
 *  Assigns the 5 slits visible an FNODE, where possible.
 * IN: FNODE *ptr:	Start assigning with this node
 *     FNODE *array[]:	A 5 slit pointer array.
 *     BOOLEAN flag:	Assign to Active or Inactive Slit base.
 */
void
Assign_Slit( FNODE *ptr, FNODE *array[], BOOLEAN flag )
{
    OBJECT *tree = xtree;
    int i;
    int obj;
    FNODE *curptr;
    
    obj = (( flag == ACTIVE_FNODE ) ? ( A0 ) : ( I0 ) );
    
    curptr = ptr;
    for( i = 0; i < 5; i++ )
    {
        array[ i ] = NULL;
        Deselect( obj + i );
        TedText( obj + i ) = fblank;
        if( curptr )
        {
            array[i] = curptr;
            TedText( obj + i ) = curptr->fname;
	    if( curptr->aflag )
            	Select( obj + i );
            curptr = curptr->next;
        }   
    }
}




/* Draw_ASlit()
 *==========================================================================
 * The Draw Slider Routine passed into the Active ( CPX ) slider routines.
 */
void
Draw_ASlit( void )
{
    slit_offset_adjust( Ahdptr, Cur_ASlit, Active_Slit, ACTIVE_FNODE );
    blit_slits( ACTIVE_FNODE, Old_ASlit, Cur_ASlit );
    Old_ASlit = Cur_ASlit;
}



/* Draw_ISlit()
 *==========================================================================
 * The Draw Slider Routine passed into the InActive( CPZ ) slider routines.
 */
void
Draw_ISlit( void )
{
    slit_offset_adjust( Ihdptr, Cur_ISlit, InActive_Slit, INACTIVE_FNODE );
    blit_slits( INACTIVE_FNODE, Old_ISlit, Cur_ISlit );
    Old_ISlit = Cur_ISlit;
}




/* Draw_IHot()
 *==========================================================================
 * The Draw Slider Routine passed into the InActive ( CPZ ) HOT slider
 * Routines. This routine is used when we are doing 'hot' scrolling'.
 */
void
Draw_IHot( void )
{
    Hot_Scroll( Ihdptr, Cur_ISlit, I0, I4 );
    Draw_ISlit();
    Evnt_timer( 50L );
}



/* Draw_AHot()
 *==========================================================================
 * The Draw Slider Routine passed into the Active (CPX ) HOT slider
 * Routines. This routine is used when we are doing ' hot' scrolling.
 * Routines.
 */
void
Draw_AHot( void )
{
    Hot_Scroll( Ahdptr, Cur_ASlit, A0, A4 );
    Draw_ASlit();
    Evnt_timer( 50L );
}



/* slit_offset_adjust()
 *==========================================================================
 * Assign the linked list to the slits. Used in conjuction with Assign_Slit.
 * IN: FNODE *ptr:	The Head Pointer Node
 *     int   value:	The Index (base 0 ) into the linked list
 *     FNODE *array[]:	Text for the slider.
 *     Boolean flag:	Pass on to Assign_slit()
 */
 
void
slit_offset_adjust( FNODE *ptr, int value, FNODE *array[], BOOLEAN flag )
{
    FNODE *curptr;
    int   i;
    
    curptr = ptr;
    for( i = 0; i < value; i ++ )
    	curptr = curptr->next;
    Assign_Slit( curptr, array, flag );
}





/* blit_slits()
 *==========================================================================
 * Perform the blitting when the slits are scrolling.
 * IN: BOOLEAN flag:	either Active or Inactive
 *     int old_slit:	The previous slit
 *     int new_slit:	The current slit to work on.
 */
void
blit_slits( BOOLEAN flag, int old_slit, int new_slit )
{
    OBJECT *tree = ( OBJECT *)rs_trindex[ MOVECPX ];
    
    GRECT srcbase;
    GRECT dstbase;
    GRECT clip;
    GRECT rect;
    int   pxy[16];
    GRECT clip2;
            
    int   offset;
    long  location = 0L;
    int   dummy;
    int   obj;
    int   base;
    
    obj  = ( ( flag == ACTIVE_FNODE ) ? ( A0 ) : ( I0 ) );
    base = ( ( flag == ACTIVE_FNODE ) ? ( ATEXT ) : ( ITEXT ));
    clip = ObRect( base );
    objc_offset( tree, obj, &clip.g_x, &clip.g_y );
    clip2 = srcbase = dstbase = rect = clip;  
    offset = new_slit - old_slit;
               
    if( !offset )			/* went nowhere fast...*/
    	   return;
    	   
    if( !open_vwork() )
       return;

    rc_intersect( &desk, &clip2 );
    if(  ( abs( offset )  <  MAX_SLITS ) &&
    	 rc_equal( &clip2, &clip ) 
      )
    {
       rect.g_h    = ( abs( offset ) * ObH( obj ) );
       dstbase.g_h = srcbase.g_h = ( MAX_SLITS - abs( offset ) ) * ObH( obj );
       if( offset > 0 )
       {
          objc_offset( tree, obj + abs( MAX_SLITS - offset ),
                       &dummy, &rect.g_y );
	  objc_offset( tree, obj + abs( offset ), &dummy, &srcbase.g_y );
       }
       else
	  objc_offset( tree, obj + abs( offset ), &dummy, &dstbase.g_y );

       rc_intersect( &desk, &srcbase );
       rc_intersect( &desk, &dstbase );
       
       rc_2xy( &srcbase, ( WORD *) &pxy[0] );
       rc_2xy( &dstbase, ( WORD *)&pxy[4] );
       rc_2xy( &clip, ( WORD *)&pxy[8] );
       vs_clip( vhandle, 1, &pxy[8] );
       graf_mouse( M_OFF, 0L );
       Vsync();
       vro_cpyfm( vhandle, 3, pxy, ( MFDB *)&location,
                                   ( MFDB *)&location );
       graf_mouse( M_ON, 0L );
    }
    else
    {
       rc_2xy( &clip, ( WORD *)&pxy[0] );
       vs_clip( vhandle, 1, &pxy[0] );
    }
    
    Vsync();
    Objc_draw( tree, base, MAX_DEPTH, &rect );

    close_vwork();
}







/*
 *==========================================================================
 * Hot and Cold Scroll Handling
 *==========================================================================
 */



/* Hot_Scroll() 
 *=================================================================
 * Object Scrolling Handler for Hot Scrolling Routines.
 * Called ONLY by Draw_IHot() and Draw_AHot()
 * The hot scrolling kicks in when the mouse is in ZONE 0 or ZONE 6.
 * The zone boundaries are created by 'Make_Hot_Spots()'.
 * IN:  FNODE *Xptr:	The Parent FNODE pointer to the linked list.
 *  	int cur_slit:	The current index into the linked list
 *	int First_Obj:	Either A0 or I0 - the first clickable object
 *	int End_Obj:	Either A5 or I5 - The last clickable object
 *
 * OUT: void
 */
void
Hot_Scroll( FNODE *Xptr, int cur_slit, int First_Obj, int End_Obj )
{
    OBJECT *tree = ( OBJECT *)rs_trindex[ MOVECPX ];
    FNODE *curptr;
    int   index;
           
    if( Xptr )
    {
     
      if( hot_index == 0 )		/* ZONE 0 Hot Spot */
      {
        /* Scrolling around the TOP...*/
        curptr = Find_Fnode( Xptr, cur_slit );
        new_index = cur_slit;

       /* We must now compare the initial index ('findex') to
        * our NEW index. If they are the same, we just draw it
        * based on the flag.
        */
        if( new_index == findex )
        {
            if( Base_Node->aflag )
                Select( First_Obj );
		
            else
                Deselect( First_Obj );
        }
        
        if( new_index < findex )
        {
   	  /* The New index is ABOVE the starting point.
	   * Therefore, we want to set the state to
	   * be the same as the 'Base_Node->aflag'
	   * The OBJECT is ALWAYS the first filename block
	   * while we are scrolling.
	   */
           if( Base_Node->aflag )
           {
             /* Want them SELECTED
              * So, if the node is deselected, SELECT IT
	      * else, leave it alone.
              * NOTE: Don't update the 'sflag'
              */
	     if( !curptr->aflag )
                  curptr->aflag ^= TRUE;
             Select( First_Obj );    
           }
           else
           {
             /* Want it DESELECTED
              * So, if the node is selected, DESELECT IT
              * else, leave it alone.
              * NOTE: Don't update the 'sflag'
              */
             if( curptr->aflag )
                 curptr->aflag ^= TRUE;
             Deselect( First_Obj );     
           }
        }
        
	if( new_index > findex )	       
	{
	  /* The New index is BELOW the starting point.
	   * Therefore, we want to set the state of the object
	   * to its ORIGINAL state. This is the 'sflag'.
	   * The OBJECT is ALWAYS the first filename block
	   * while we are scrolling.
	   */
	   curptr->aflag = curptr->sflag;
	   if( curptr->aflag )
	       Select( First_Obj );
	   else
	       Deselect( First_Obj );
	}
      }
      
      
      if( hot_index == 6 )      	/* ZONE 6 Hot Spot */
      {
         /* Scrolling around the Bottom */
         curptr = Find_Fnode( Xptr, cur_slit + MAX_SLITS - 1);
	 index = Get_Findex( Xptr, curptr );
	 
             new_index = index;


             /* We must now compare the initial index ('findex') to
              * our NEW index.
              * If they are the same, we select/deselect it
              * based on the status of Base_Node.
              */
              if( new_index == findex )
              {
                 if( Base_Node->aflag )
                    Select( End_Obj );
                 else
                    Deselect( End_Obj );
              }
        
              if( new_index < findex )
              {
   	         /* The New index is ABOVE the starting point.
   	          * We want to RESTORE the original 'sflag' state.
	   	  * The OBJECT is ALWAYS the LAST filename block
	   	  * while we are scrolling.
	  	  */
	          curptr->aflag = curptr->sflag;
	          if( curptr->aflag )
	               Select( End_Obj );
           	  else
	               Deselect( End_Obj );
              }
              
	      if( new_index > findex )
              {
	  	 /* The New index is BELOW the starting point.
	  	  * We want to set the state of the object to the
	  	  * same as the Base_Node.
	          */
                 if( Base_Node->aflag )
                  {
                      /* Want them SELECTED
		       * So, if the node is deselected, SELECT IT
		       * else, leave it alone.
       	       	       * NOTE: Don't update the 'sflag'
        	       */
		       if( !curptr->aflag )
		            curptr->aflag ^= TRUE;
		       Select( End_Obj );    /* had I0 here */
                  }
                  else
                  {
                     /* Want it DESELECTED
	              * So, if the node is selected, DESELECT IT
                      * else, leave it alone.
             	      * NOTE: Don't update the 'sflag'
                      */
                      if( curptr->aflag )
                         curptr->aflag ^= TRUE;
                      Deselect( End_Obj );     /* had I0 here */
                  }
	      }

      } 			  /* hot_index == 6 */
    }


}












/* Set_Move_Text()
 *==========================================================================
 * Set the Text_Index flag to either TO_NONE, TO_ACTIVE or TO_INACTIVE
 * which is the text for the direction line in the Filename XCONFIG tree.
 * Several checks are done.
 * 1) If there isn't a linked list header, then set the text to TO_NONE.
 * 2) Check if there are any changed fnodes ( opposites from aflag<=>mflag.
 *    Depending on the situation we do several things.
 * IN: int flag:	Either TO_NONE | TO_ACTIVE | TO_INACTIVE
 * OUT: void 
 */
void
Set_Move_Text( int flag )
{
     OBJECT *tree = ( OBJECT *)rs_trindex[ MOVECPX ];
     BOOLEAN  changed;
     int  old_index;
     GRECT    rect;
     
     old_index = Text_Index;
     
     if( (( flag == TO_ACTIVE ) && Ihdptr ) ||
         (( flag == TO_INACTIVE ) && Ahdptr )
       )
     {
        if( flag == TO_ACTIVE )
             changed = IsChanged( Ihdptr );
     	      
        if( flag == TO_INACTIVE )
       	    changed = IsChanged( Ahdptr );
     	      
        Text_Index = (( changed ) ? ( flag ) : ( TO_NONE ) );
     }             
     else
       Text_Index = TO_NONE;

     if( old_index != Text_Index )
     { 
       TedText( MOVETEXT ) = slit_text[ Text_Index ];
       rect = ObRect( MOVETEXT );
       objc_offset( tree, MOVETEXT, &rect.g_x, &rect.g_y );
       rect.g_x -= 3;
       rect.g_y -= 3;
       rect.g_w += 6;
       rect.g_h += 6;

       if( Text_Index == TO_NONE )
          HideObj( MOVETEXT );
       else
          ShowObj( MOVETEXT );
       Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
       
     }  
}





/* Make_Hot_Spots()
 *==========================================================================
 * Create the 7 Hot spot rectangles required for scrolling through the
 * CPX filenames.  They are in this order:
 *
 *		______________________
 *		|                    |		ZONE 0 ( Above )
 *		|                    |
 *		+--------------------+
 *		|                    |		ZONE 1 ( A0 or I0 )
 *		|                    |
 *		+--------------------+
 *		|                    |		ZONE 2 ( A1 or I1 )
 *		|                    |
 *		+--------------------+
 *		|                    |		ZONE 3 ( A2 or I2 )
 *		|                    |
 *		+--------------------+
 *		|                    |		ZONE 4 ( A3 or I3 )
 *		|                    |
 *		+--------------------+
 *		|                    |		ZONE 5 ( A4 or I4 )
 *		|                    |
 *		+--------------------+
 *		|                    |		ZONE 6 ( Below )
 *		|                    |
 *		----------------------
 * NOTE: The widths of the zones are the width of the screen.
 * IN: int top_object:	Either A0 or I0
 */
void
Make_Hot_Spots( int top_object )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ MOVECPX ];
   int i;
   int obj;
   GRECT rect;
      
   for( i = 1; i < 6; i++ )
   {
      obj = top_object + i - 1;
      hot_spot[ i ] = ObRect( obj );
      objc_offset( tree, obj, &hot_spot[i].g_x, &hot_spot[i].g_y );
      hot_spot[ i ].g_w = desk.g_w;
      hot_spot[ i ].g_x = desk.g_x;
   }
   rect = desk;
   rect.g_y = 0;
   rect.g_h = desk.g_y + desk.g_h;
   
   hot_spot[0] = hot_spot[6] = rect;
   hot_spot[ 0 ].g_h = hot_spot[ 1 ].g_y;
   hot_spot[ 6 ].g_y = hot_spot[ 5 ].g_y + hot_spot[ 5 ].g_h; 
   hot_spot[ 6 ].g_h = rect.g_h - hot_spot[ 6 ].g_y + 1;

   /* Now, adjust the rectangles clipped to the desktop */   
   for( i = 0; i < 7; i++ )
      rc_intersect( &rect, &hot_spot[ i ] );
}





/* Get_Findex()
 *==========================================================================
 * Given the Parent FNODE pointer AND the FNODE pointer in question,
 * find its index into the linked list ( zero based ).
 * IN: FNODE *tptr:	The Parent FNODE pointer
 *     FNODE *ptr:	The FNODE pointer we want the index for.
 *
 * OUT: int:	The index into the linked list ( 0 based ) to the FNODE *ptr
 */
int
Get_Findex( FNODE *tptr, FNODE *ptr )
{
    FNODE *curptr;
    int   count = 0;
    
    curptr = tptr;
    while( curptr )
    {
         if( curptr == ptr )
         	 break;
         count++;
         curptr = curptr->next;
    }
    return( count );
}




/* Get_Hot_Index()
 *==========================================================================
 * Get the 'hot_index' INDEX INTO the hot_spot array to tell us
 * which rectangle we ended up in for our filename scrolling.
 * Returns the OLD hot_index in d0 and the NEW hot_index in A0.
 * IN:	int *hot_index:	   Our previus ZONE that we were in. 
 *			   Upon exit, contains the NEW ZONE that we are in.
 * OUT: int:		   Returns the OLD ZONE that we were in.
 */
int
Get_Hot_Index( int *hot_index )
{
    int   index = 0;
    int   cold_index;
    MRETS mk;
   
    cold_index = *hot_index;
     
    Graf_mkstate( &mk );
    while( !xy_inrect( mk.x, mk.y, &hot_spot[ index++ ] ));				     
    index -= 1;

    *hot_index = index;	
    return( cold_index );
}





/* Find_Fnode()
 *==========================================================================
 * Given the Parent FNODE pointer ( filename node ) and the index (base 0 )
 * into the linked list, return the FNODE pointer to that index.
 * Note that we will return the end pointer if index exceeds the number
 * of nodes.
 * IN:	FNODE *ptr:	The parent FNODE pointer to the list.
 *	int index;	The INDEX into the linked list ( 0 based )
 *
 * OUT: FNODE *ptr:	Return the pointer to the node indexed in.
 */
FNODE
*Find_Fnode( FNODE *ptr, int index )
{
    FNODE *curptr;
    int count = 0;
    
    curptr = ptr;
    while( curptr && ( count != index ) )
    {
       count++;
       curptr = curptr->next;
    }    	   
    return( curptr );
}





/* Old_Index_Handler()
 *==========================================================================
 * 1) Selects/Deselects a filename object for the MOVER/RENAMER.
 * 2) Sets the FNODE flag of the old_index either to SELECT or DESELECT
 * NOTE: This routine basically cleans up AFTER 'new_index' and
 * 	 follows it around.
 * 
 * IN: 	int old_index:		 OLD index object INTO linked list 
 *	int new_index:		 NEW index object INTO linked list 
 *	int findex:		 index object INTO linked list that 
 *				 started all this scrolling thing... 
 *	FNODE *Top_Node:	 STARTING node of linked list		 
 *      FNODE *Base_Node:	 The findex NODE pointer
 *	int Above_Obj:		 rcs object when old_index < findex    
 *	int Below_Obj:		 rcs object when old_index > findex 
 */
void
Old_Index_Handler( int old_index, int new_index, int findex,
		   FNODE *Top_Node, FNODE *Base_Node,
		   int Above_Obj, int Below_Obj )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ MOVECPX ];
   FNODE *Old_Node;			/* FNODE pointer of 'old_index'  */
   
   
   /* if the old_index is the same as 'findex', or
    * 'old_index' is the same as 'new_index',
    * then skip this routine.
    */
   if(( old_index != findex ) && ( old_index != new_index ) )			       
   {

      /* Get the NODE for the 'old_index'.  Find_Fnode() will always
       * return a node regardless. 'Top_Node' contains at least 
       * ONE node, otherwise, 'Old_Index_Handler would never have been
       * called.
       */
       Old_Node = Find_Fnode( Top_Node, old_index );


      /* CODE to Handle 'old_index' ABOVE 'findex' */
      if( old_index < findex )
      {
         /* Check if we are ABOVE or BELOW the 'new_index'
          *==================================================
          * CODE ONLY for 'old_index' being ABOVE 'new_index'
          * AND ABOVE 'findex'.
          * MEANING: the 'new_index' moved DOWNWARDS.
          *==================================================
          * For 'old_index' being ABOVE 'findex' BUT
          * BELOW 'new_index'.
          * MEANING: 'new_index' moved UPWARDS!
          * HOWEVER: INSPECTION reveals that 'old_index'
          *          handling is not required for that case.
          */
	  if( old_index < new_index )
          {
             /* We must RESTORE the 'Old_Node' to its
              * previous state, IF the conditions 
              * are met. Otherwise, do not touch anything.
              */
             if( Base_Node->aflag )
             {
                 if( !Old_Node->sflag )
                 {
                     Old_Node->aflag = Old_Node->sflag;
                     deselect( tree, Above_Obj );
                 }
             }
             else
             {
                 if( Old_Node->sflag )
                 {
                     Old_Node->aflag = Old_Node->sflag;
                     select( tree, Above_Obj );
                 }
             }
    	  }
    						      
      }				/* End of ( old_index < findex */
    						   


      /* CODE to Handle 'old_index' BELOW 'findex' */	
      if( old_index > findex )
      {
	 /* Check if we are ABOVE or BELOW the 'new_index'
          *==================================================
          * CODE ONLY for 'old_index' being BELOW 'new_index'
          * AND BELOW 'findex'.
          * MEANING: the 'new_index' moved UPWARDS.
          *==================================================
          * For 'old_index' being BELOW 'findex' AND
          * ABOVE 'new_index'...'new_index' moved 'DOWNWARDS'.
          * HOWEVER: INSPECTION reveals that 'old_index'
          *	     handling is not required for that case.
          */
          if( old_index > new_index )
    	  {
    	     /* Restore the 'old_node' to its previous state
    	      * if the below conditions are met. Otherwise
    	      * do not touch anything...
    	      */
    	     if( Base_Node->aflag )
    	     {
    	         if( !Old_Node->sflag )
    	         {
    	            Old_Node->aflag = Old_Node->sflag;
    	            deselect( tree, Below_Obj );
    	         }
    	     }
    	     else
    	     {
    	         if( Old_Node->sflag )
    	         {
    	           Old_Node->aflag = Old_Node->sflag;
    	           select( tree, Below_Obj );
    	         }
    	     }
	  }
       }	      	   
    }			/* If( ( old_index != new_index ) && ( old_index != findex ) ) */
}






/* New_Index_Handler()
 *==========================================================================
 * 1) Selects/Deselects a filename object for the MOVER/RENAMER.
 * 2) Sets the FNODE flag of the new_index either to SELECT or DESELECT
 * NOTE: This deals with 'new_index' which is followed by 'old_index'
 * 
 * IN: 	int old_index:		 OLD index object INTO linked list 
 *	int new_index:		 NEW index object INTO linked list 
 *	int findex:		 index object INTO linked list that 
 *				 started all this scrolling thing... 
 *	FNODE *Top_Node:	 STARTING node of linked list		 
 *	FNODE *Base_Node:	 FINDEX node in LINKED list		 
 *	int Above_Obj:		 rcs object when old_index < findex    
 *	int Below_Obj:		 rcs object when old_index > findex 
 */
void
New_Index_Handler( int old_index, int new_index, int findex,
		   FNODE *Top_Node, FNODE *Base_Node,
		   int Above_Obj, int Below_Obj )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ MOVECPX ];
   FNODE *New_Node;			/* FNODE pointer of 'old_index'  */

   /* If the 'new_index' is the same as 'old_index' or
    * it is the same as 'findex', we skip this routine entirely.
    */					       
  if( ( new_index != old_index ) && ( new_index != findex ) )
  {
      /* Get the FNODE pointer based on the 'new_index' index.
       * NOTE: We will always have a node, otherwise this
       *       routine will never have been called.
       */
      New_Node = Find_Fnode( Top_Node, new_index );

      /* We must now decide whether to select, deselect or
       * leave the node flag alone depending upon the 
       * position of findex, old_index and new_index.
       * Depending upon the state of 'Base_Node', we will
       * either Select, Deselect or skip the node.
       */						   

     /* CODE where 'new_index' < 'findex'
      * MEANING: We are ABOVE findex.
      */    						   
     if( new_index < findex )
     {
         /* Check if we are ABOVE or BELOW the 'old_index'
          *===============================================
          * CODE ONLY for 'new_index' ABOVE 'old_index'
          * NOTE: We are MOVING UPWARDS.
          * HERE, we save the 'aflag' state to 'sflag'
          * and then toggle 'aflag'.
          * We THEN, REDRAW the OBJECT that the node
          * was in.
          *===============================================
          * NOTE: For the case where new_index > old_index.
          * This is where 'new_index' is BELOW 'old_index'
          * We are MOVING DOWNWARDS.
          * HOWEVER, initial estimates show that we can
          * ignore this case.
          */
         if( new_index < old_index )
         {
		if( Base_Node->aflag )
    		{
    		    /* The Base_Node wants SELECTED.
    		     * So, if our 'New_Node' is Deselected, SELECT IT!
    		     * by backing up to 'sflag' and toggling 'aflag'.
    		     * If we have already SELECTED it, don't do anything.
    		     */
    		    if( !New_Node->aflag )
    		    {
    		       New_Node->sflag = New_Node->aflag;
    		       New_Node->aflag ^= TRUE;
    		       select( tree, Above_Obj );
    		    }
    		}
    		else
    		{
    		    /* The Base_Node wants DESELECTED!
    		     * So, if our 'New_Node' is Selected, DESELECT IT!
    		     * by backing up to 'sflag' and toggling 'aflag'.
    		     * If we have already DESELECTED it, don't do anything.
    		     */
    		    if( New_Node->aflag )
    		    {
    		        New_Node->sflag = New_Node->aflag;
    		        New_Node->aflag ^= TRUE;
    		        deselect( tree, Above_Obj );
    		    }
    		}            
         }		/* end of if( new_index < old_index ) */
    						      
     }
    						   

    /* CODE where 'new_index' > 'findex'.
     * MEANIN: We are BELOW 'findex'.
     */    						   
    if( new_index > findex )
    {
        /* NOTE: Initial analysis shows that the case
         * new_index < old_index can be ignored.
         */
        if( new_index > old_index )
        {
    	   /* We are BELOW findex AND BELOW old_index...
    	    * meaning, we have moved DOWNWARDS to the new_index.
    	    */
    	   if( Base_Node->aflag )
    	   {
    	      /* The BASE wants SELECTED!
    	       * If we are DESELECTED, SELECT IT!
    	       * Update 'sflag' and toggle 'aflag'
    	       * If ALREADY SELECTED, SKIP! 
    	       */
    	      if( !New_Node->aflag )
    	      {
    	         New_Node->sflag = New_Node->aflag;
    	         New_Node->aflag ^= TRUE;
    	         select( tree, Below_Obj );
    	      }
    	   }
    	   else
    	   {
    	      /* The BASE wants DESELECTED!
    	       * If we are SELECTED, DESELECT IT!
    	       * Update 'sflag' and toggle 'aflag'
    	       * If ALREADY DESELECTED, SKIP!
    	       */
    	      if( New_Node->aflag )
    	      {
    	          New_Node->sflag = New_Node->aflag;
    	          New_Node->aflag ^= TRUE;
    	          deselect( tree, Below_Obj );
    	      }
    	   }  
      }
   }					
  }  /* End of if( old_index != new_index etc..*/
}








/* Do_Hot_Scroll()
 *==========================================================================
 * Perform THE HOT Scrolling by dragging the mouse around.
 * Called when either A0-A5 | I0-I5 is clicked on.
 * 
 * int obj:		The Initial Object selected
 * int Top_Obj:		The Top Object selectable: A0 or I0
 * FNODE *Top_Node:	The Head Pointer Node of Linked List
 * FNODE *Base_Node:    The Node Pointer of the object selected.
 * int  Total:		Total Number of objects to scroll...
 *
 */
void
Do_Hot_Scroll( int obj, FNODE *Top_Node, FNODE *base_node,
	       FNODE *Other, int Top_Obj, int Total,
	       int Xbase, int Xslider, int *cur_slit,
	       FNODE *Slit_Array[],  void (*foo)() )
{
     OBJECT *tree = ( OBJECT *)rs_trindex[ MOVECPX ];
     MRETS mk;
     
     int  sindex;			/* index into Slit Arrays */
     int  data1, data2, data3;		/* storage for list specific items */
     int  bstate;			/* Button state */

     int   cold_index;			/* shadow for hot_index */
     int   old_index;			/* Old index into linked list ( zero based ) */
     int   temp_index;
     FNODE *New_Node;			/* The Node pointer to the new_index slot */
     int   ox;
     int  dir, index;
     BOOLEAN Skip_Flag = FALSE;
     BOOLEAN Scroll_Exit = FALSE;
     
          
     Base_Node = base_node;		/* Base_Node is Global and needs updating */
     if( Top_Obj == A0 )
     {
         data1 = INACTIVE_FNODE;
         data2 = ACTIVE_FNODE;
         data3 = TO_INACTIVE;
     }
     else
     {
        data1 =  ACTIVE_FNODE; 
        data2 =  INACTIVE_FNODE;
        data3 =  TO_ACTIVE;
     }

     sindex = obj - Top_Obj;
     Undo_Fnodes( Other, data1 );
     Graf_mkstate( &mk );    
     if( !( mk.kstate && K_LSHIFT ) )
         Undo_Fnodes( Top_Node, data2 );
         
     if( Top_Node && Base_Node )
     {
         Base_Node->aflag ^= TRUE;		/* <=====   NOTE: there might be a problem here */
         Base_Node->sflag = Base_Node->aflag;   /* Especially when shift key is supposed to be down*/
         if( Base_Node->aflag )
            select( tree, obj );
         else
            deselect( tree, obj );
      
         cold_index = hot_index = sindex + 1;
         findex = Get_Findex( Top_Node, Base_Node );
         old_index = new_index = findex;
         
         New_Node = Top_Node;
         while( New_Node )
         {
             New_Node->sflag = New_Node->aflag;
             New_Node = New_Node->next;
         }
         New_Node = NULL;
     }
     Set_Move_Text( data3 );
     Make_Hot_Spots( Top_Obj );
     do
     {
       /* Skip this whole mess if there isn't a Header Pointer or
        * a pointer where we clicked on.
        */
 	if( Top_Node && Base_Node )
 	{
 	    /* We now will look for the exit condition ( Going OUT )
 	     * or an up button, whichever occurs first.
 	     * Returns ZERO if button event occurred.
 	     */
 	    if( !Scroll_Exit ) 
 	         bstate = rub_wait( &hot_spot[ hot_index ], 1, 0 );
 	    else
 	         bstate = FALSE;
 	              
 	    if( !bstate )
 	    {
 	        /* Find out which hot_spot rectangle that we are in. */
 	        cold_index = Get_Hot_Index( &hot_index );
 	        
 	        /* If we have ended up in the SAME 'hot_index' slit, 
 	         * then we have gone nowhere. Therefore, skip
 	         * any scrolling.
 	         */
 	        
 	        Scroll_Exit = Skip_Flag = FALSE;
 	        if( hot_index != cold_index )
 	        {
 		   /*************************************************
		    * Hot_Index SCROLLING of filenames
		    * We have ended up within the filename slits.
		    *************************************************/

		    /* There are several cases possible only
		     * 		   START		 END
		     *		  Cold_Index	      Hot_Index
		     * CASE 0:      0 | 6		0 | 6
		     * CASE 1:      0 | 6		1 - 5	      
		     * CASE 2:      1-5			0 | 6
		     * case 3:	    1-5			1 - 5
		     * 
		     * We are going to have to clean up form cold to hot_index
		     * in turn since they might not necessarily be adjacent.
		     */

		    dir = 0;
		    dir = (( hot_index < cold_index ) ? ( -1 ) : ( dir ) );
		    dir = (( hot_index > cold_index ) ? ( 1 ) : ( dir ) );
		    index = cold_index + dir;
		    
		    switch( cold_index )
		    {
		        case 0:
		        case 6:  old_index = (( cold_index == 0 ) ? ( max( new_index - 1 , 0 ) ) : ( min( new_index + 1, Total - 1 )) );
		        	 if( old_index != new_index )
		        	 {
				      New_Node = Slit_Array[ index - 1 ];
			   	      if( New_Node )
				      {
					 new_index = Get_Findex( Top_Node, New_Node );

		        	 
				         New_Index_Handler( old_index, new_index, findex,
				   		            Top_Node, Base_Node,
							    ( index - 1 ) + Top_Obj,
							    ( index - 1 ) + Top_Obj );
				      }		 
		        	 }
		        	 old_index = new_index;
		        	    	     
		        	 if( index != hot_index )
		        	     	   index += dir;
		        	 else
		        	    Skip_Flag = TRUE;	   
		        	    	     	
		        	 while( index != hot_index )
		        	 {
				     Hot_Old_New_Update( index, Top_Node,
		     		   			 old_index, findex, 
		     		            		 Top_Obj, Slit_Array );
		        	    		
		        	     index += dir;
		        	     old_index = new_index;	/* warning: new_index is global */
		        	     Skip_Flag = FALSE;	
		        	 }   
		        	 break;	     
		        	 
		        case 1:  
		        case 2:
		        case 3:
		        case 4:
		        case 5:	 while( index != hot_index )
		        	 {
				    Hot_Old_New_Update( index, Top_Node,
		     		   			old_index, findex, 
		     		            		Top_Obj, Slit_Array );
		        	    
		        	    index += dir;
		        	    old_index = new_index;	/* warning: new_index is global */
		        	 }
		        	 break;
		       
		        default:
		         	 break;
		       
		    }
		    		   				            				
      		    if(( ( hot_index > 0 ) && ( hot_index < 6 ) ) && !Skip_Flag )
		    {
			Hot_Old_New_Update( hot_index, Top_Node,
		     		            old_index, findex, 
		     		            Top_Obj, Slit_Array );
       		    }					    		               
	        

		    if( ( hot_index == 0 ) || ( hot_index == 6 ) )
		    {
		          /* We have ENTERED the box ABOVE or BELOW
		           * the Object area, therefore, SCROLL, if possible 
		           *
		           * hot_index == 0 or hot_index == 6 ( outside obj boundaries )
		           */
				           
		           /* need to update the old_index HERE before we enter the scroll */
		           temp_index = (( hot_index == 0 ) ? ( new_index - 1 ) : ( new_index + 1 ) );
			   Old_Index_Handler( old_index, temp_index, findex,
			                      Top_Node, Base_Node,
			                      ( hot_index - 2 ) + Top_Obj,
		 			      hot_index + Top_Obj );
			   ox = ( ( hot_index == 0 ) ? ( -1 ) : ( 1 ) );
		           Hot_Slide( tree, Xbase, Xslider, -1,
           			      ox, max( Total - MAX_SLITS, 0 ), 0,
           			      cur_slit, VERTICAL, &hot_spot[ hot_index ],
           			      foo );
           					      
			/* Update the Hot_Index flag to see where we really are...
			 * It SHOULD be either hot_index 1 or 5
			 *
			 * Need to figure out why slot 0 and 4 do not select or
			 * deselect after a slide like this.
			 *
			 */
			 Scroll_Exit = TRUE;
		    }
 	        
	 	    /* Update the old_index and the NEW index...*/
		    old_index = new_index;

 	        }  			/* End of 'if( hot_index != cold_index )' */
 	    }				/* End of 'if( !bstate )'		  */
 	}    
	Graf_mkstate( &mk );
     }while( mk.buttons != 0 );
}





/* Hot_Old_New_Update()
 *==========================================================================
 * Combines the Updating of the 'old_index' and the 'new_index' into
 * one routine.
 *
 * IN: 	int index:		The 'hot ZONE index'
 *	FNODE *Top_Node:	The Parent Node pointer to the list
 *	int old_index:		The 'old_index' into the linked list
 *	int findex:		The index to the fnode which we
 *				clicked on to start the scrolling.
 *	int Top_Obj:		Either A0 | I0
 *	FNODE *Slit_Array[]	The array (either for CPX or CPZ )
 *				that contains a pointer to the
 *				FNODE in that slit.
 */
FNODE
*Hot_Old_New_Update( int index, FNODE *Top_Node,
		     int old_index, int findex,
		     int Top_Obj, FNODE *Slit_Array[] )
{
   FNODE *New_Node = NULL;

	/**********************************************
	 * We have ENTERED a NEW object area.
	 * Get the FNODE and find out what the NEW 
	 * 'new_index' for that node is. If there is
	 * NO NODE, we SKIP any scrolling.
	 **********************************************/
	New_Node = Slit_Array[ index - 1 ];
	if( New_Node )
	{
	     new_index = Get_Findex( Top_Node, New_Node );

	     Old_Index_Handler( old_index, new_index, findex,
	                        Top_Node, Base_Node,
	                        ( index - 2 ) + Top_Obj,
			        index + Top_Obj );

	     New_Index_Handler( old_index, new_index, findex,
	  			Top_Node, Base_Node,
				( index - 1 ) + Top_Obj,
				( index - 1 ) + Top_Obj );
	}
	return( New_Node );
}





				


