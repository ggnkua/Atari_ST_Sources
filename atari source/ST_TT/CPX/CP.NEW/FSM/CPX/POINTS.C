/* FILE:  POINTS.C
 * ====================================================================
 * DATE:  August 23, 1990  cjg
 *	  July   11, 1991  cjg
 *
 * DESCRIPTION: Point Size Manipulation
 *
 * INCLUDE FILE: POINTS.H
 */


/* INCLUDE FILES
 * ====================================================================
 */
#include <stdlib.h>

#include "fsmhead.h"
#include "country.h"

#include "fsmio.h"

#include "fsm.h"
#include "fsm2.h"
#include "mover.h"

#include "..\cpxdata.h"
#include "text.h"
#include "outline.h"

#include "status.h"
#include "buildwd.h"
 
extern XCPB *xcpb;		/* XControl Parameter Block   */

struct foobar {
	WORD	dummy;
	WORD	*image;
	};

/* PROTOTYPES
 * ====================================================================
 */
int	Fsize_button( int button, WORD *msg );
int	New_Point_Size_Button( int button, WORD *msg );

void	Do_Point_Sizes( int obj, int flag );
void	Pointer_Setup( FON_PTR cur_ptr, int defaults );
void	Sort_Points( void );
BOOLEAN	Point_Sizes_Exist( FON_PTR cur_ptr );
int	Count_Point_Sizes( void );
void	Delete_Point_Sizes( void );
void	Add_New_Point_Size( void );
void	New_Point_Size_Up_Down_Arrow( int obj );
void    Insert_New_Point_Size( int num );
void	Push_Point_Size( void );
void	Default_Point_Button( void );
void	Move_Defaults_To_Font( FON_PTR ptr );
void	Point_Left_Right( int button );
void    RedrawNNUM( void );

void	SetPointButtons( void );
BOOLEAN FindPointSize( int num );
void	default_buttons( int obj );


/* DEFINES
 * ====================================================================
 */
#define NO_DEFAULT_POINTS 0
#define DEFAULT_POINTS  1						 

#define MAX_TITLE	22
#define UNDO	0x6100


/* GLOBALS
 * ====================================================================
 */
int Old_Cur_Slit;

int  Point_Count;		/* # of POint Sizes for font */
char Point_Size_Text[ 4 ];	/* Text for New Point Size */
int  Cur_Point_Size;		/* Current Point Size for New Point Size*/
char name_buf[ MAX_TITLE + 2 ];
int  fncount;
int  fnsize;
char cur_font_name[ 35 ];	
 
BOOLEAN Internal_Flag = FALSE;	/* Used to set Change_Flag upon exit */
BOOLEAN internal_flag = FALSE;  /* for use with adding a new point size*/

/* FUNCTIONS
 * ====================================================================
 */


/* Fsize_button()
 * ====================================================================
 * Handle point size button events. ( Adding/ deleting etc.. )
 */
int
Fsize_button( int button, WORD *msg )
{
   int quit = FALSE;
   BOOLEAN click_flag = FALSE;
   
   if( ( button != -1 ) && ( button & 0x8000 ) )
   {
      click_flag = TRUE;
      button &= 0x7FFF;      
   }   

      
   switch( button )
   {
     case FOEXIT:   if( Count_Point_Sizes() <= 0 )
		    {
		       /* Used to make sure that we have at least 1 
		        * point size available. If we decide to add a
		        * point size, we'll just not exit back to
		        * wherever we came from.
		        */
		       if( form_alert( 1, alert20 ) == 1 )
		       {
		          deselect( tree, FOEXIT );
		          return( quit );
		       }
		       else
		         button = FOCANCEL;   
		    }
		    Deselect( FOEXIT );

		    /* We did something that will require the user
		     * to make width tables. So set the 'flag'.
		     * The prompt will appear after we write the
		     * extend.sys. The only other way to clear the flag
		     * is to re-init() or to create width tables.
		     */
		     
		    if( Internal_Flag )
		       Make_Width_Flag = TRUE;
		       
     case FOCANCEL: Deselect( FOCANCEL );
		    if( button == FOCANCEL )
		    	Internal_Flag = FALSE;
		    else	/* Save out the NEW point sizes ONLY if not a CANCEL */
		      Push_Point_Size();
		      
                    Change_Flag |= Internal_Flag;
     		    Return_To_Maintree( PrevTree );
		
		    if( IsActiveTree( Maintree ) )
		    {
                      HideObj( BOTTOM );
              	      ShowObj( BOTTOM2 );
              	      Objc_draw( tree, BOTTOM2, MAX_DEPTH, NULL );
              	    }
              	    
       	           /* We want to restore the Change_Flag AND
       	            * Make_Width_Flag if this was called directly
       	            * from the INACTIVE fonts list. Since this doesn't
       	            * effect anything.
       	            */
       	            if( Restore_Flags )
       	            {
       	              Change_Flag     = Old_Change_Flag;   
       	              Make_Width_Flag = Old_Make_Width_Flag;
       	            }   
              	    Restore_Flags = FALSE;   
      		    break;

     case ADDSIZE: Add_New_Point_Size();
     		   break;
     		   
     case DELSIZE: Delete_Point_Sizes();
		   Internal_Flag = TRUE;
     		   break;

     case USEDFLT: Default_Point_Button();
     		   break;

     case OLEFT:
     case ORIGHT:  Point_Left_Right( button );
     		   break;     		        		   
     		   
     case ADD10:
     case ADD12:
     case ADD18:
     case ADD24:
     case ADD48:   default_buttons( button );
     		   break;    		   
     		   
     case OPLINE0:
     case OPLINE1:
     case OPLINE2:
     case OPLINE3:
     case OPLINE4:
     case OPLINE5:
     case OPUP:
     case OPDOWN:
     case OPBASE:
     case OPSLIDER: mover_button( button, click_flag );
		    break;
		    		    
     default:	if( button == -1 )
     		{
     		   switch( msg[0] )
     		   {
     		     case WM_REDRAW: 
     		     		     break;
     			     		     
     		     case AC_CLOSE:  quit = TRUE;
     		     		     break;
     				     		     
		     case WM_CLOSED: if( Count_Point_Sizes() <= 0 )
		                     {
		       			/* Used to make sure that we have at least 1 
		        		 * point size available. If we decide to add a
		        		 * a point size, return BACK to POINT dialog box.
		        		 * IF Cancel..we DON'T do check for write_extend()
		 		         */
		                        if( form_alert( 1, alert20 ) == 1 )
				            return( quit );	/* NOTE: quit == FALSE right now */
				        else
				        {
				            /* If they are going to cancel adding a point size AND
				             * we can't allow no point sizes to exist, hey...
				             * we're not gonna prompt to save the 'EXTEND.SYS' file 
				             * either then.
				             */
				            Internal_Flag = Change_Flag = FALSE;
				        }
		                     }
		                     quit = TRUE;   
      		     		     Change_Flag |= Internal_Flag;
      		     		     
				    /* We did something that will require the user
				     * to make width tables. So set the 'flag'.
		     		     * The prompt will appear after we write the
		     		     * extend.sys. The only other way to clear the flag
		     		     * is to re-init() or to create width tables.
		     		     */
		     
		    		     if( Internal_Flag )
		       			 Make_Width_Flag = TRUE;

      		     		     if( Internal_Flag )
		 		        Push_Point_Size();

		       	             /* We want to restore the Change_Flag AND
       	            		      * Make_Width_Flag if this was called directly
       	            		      * from the INACTIVE fonts list. Since this doesn't
       	            		      * effect anything.
       	            		      */
       	            		      if( Restore_Flags )
       	            		      {
       	                                Change_Flag     = Old_Change_Flag;   
       	                                Make_Width_Flag = Old_Make_Width_Flag;
       	                              }   
     		     		      Restore_Flags = FALSE;
     		     		      
				      do_write_extend( FALSE );
				      break;
				     
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



/* New_Point_Size_Button()
 * ====================================================================
 * Handle button events for adding a new point size.
 */
int
New_Point_Size_Button( int button, WORD *msg )
{
  int quit = FALSE;
     
  if( ( button != -1 ) && ( button & 0x8000 ) )
     button &= 0x7FFF;      

  switch( button )
  {
     case NOK:    Deselect( NOK );
      		  /* The 'internal_flag' variable is set by 
      		   * Insert_New_Point_Size()
      		   */
    		  Insert_New_Point_Size( 0 );
		  		  		  
     case NCANCEL:Deselect( NCANCEL );

		  Reset_Tree( Oxsizes );     
		  SetPointButtons();     		     
			
		  Point_Count = Count_Point_Sizes();	
	     	  mover_setup( hdptr, Point_Count,
		               OPBASE, OPSLIDER, OPUP, OPDOWN,
		               OPLINE0, OPLINE5, OPTEXT, 0 );
		  
		  Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
		  Internal_Flag |= internal_flag;   		  
     		  break;

     case NUP:
     case NDOWN:  New_Point_Size_Up_Down_Arrow( button );
     		  break;
     		       
     default:	if( button == -1 )
     		{
     		   switch( msg[0] )
     		   {
     		     case WM_REDRAW: 
     		     		     break;
     			     		     
     		     case AC_CLOSE:  quit = TRUE;
     		     		     break;
     				     		     
		     case WM_CLOSED: Insert_New_Point_Size( 0 );
		     	             /* The variable 'internal_flag' is
		     	              * set by the function
		     	              * Insert_New_Point_Size()
		     	              */
				     if( Count_Point_Sizes() <= 0 )		    		     
				     {
		                        if( form_alert( 1, alert20 ) == 1 )
		                        {
		                            RedrawNNUM();
				            return( quit );	/* NOTE: quit == FALSE right now */
				        }    
				        else
				        {
				            /* If they are going to cancel adding a point size AND
				             * we can't allow no point sizes to exist, hey...
				             * we're not gonna prompt to save the 'EXTEND.SYS' file 
				             * either then.
				             */
				            Internal_Flag = internal_flag = Change_Flag = FALSE;
				        }
				     }
				     quit = TRUE;
 		    		     if( Internal_Flag )
		       			 Make_Width_Flag = TRUE;

     		     		     Change_Flag |= ( Internal_Flag | internal_flag );
		       	             /* We want to restore the Change_Flag AND
       	            		      * Make_Width_Flag if this was called directly
       	            		      * from the INACTIVE fonts list. Since this doesn't
       	            		      * effect anything.
       	            		      */
       	            		      if( Restore_Flags )
       	            		      {
       	                                Change_Flag     = Old_Change_Flag;   
       	                                Make_Width_Flag = Old_Make_Width_Flag;
       	                              }   
     		     		      Restore_Flags = FALSE;

				     do_write_extend( FALSE );
				     break;
				     
		     case CT_KEY:    RedrawNNUM();
		     		     break;
     		     default:
     		     		break;
     		   }
     		}
     		break;
  }
  
  return( quit );
}



/* Do_Point_Sizes()
 * ====================================================================
 * Setup and display the point size dialog box.
 * Depending upon the flag, we set up based upon either
 * someone double-clicking on the font or selecting the default
 * point sizes from the outline dialog box.
 * IN: flag = 0   We double-clicked a font
 *            1   We selected the point size dialog from the outline dialog.
 *	      2   We selected the Set Point button from the main menu with
 *		  0, 1 or more fonts selected.
 */
void
Do_Point_Sizes( int obj, int flag )
{
   FON_PTR temp_ptr;
   FON_PTR new_ptr;

   Internal_Flag = FALSE;
   temp_ptr = ( FON_PTR )NULL;

   /* Double Clicked on a Font */      
   if( !flag )   	   		     
   {
     PrevTree = Maintree;
     temp_ptr = Active_Slit[ obj - LINE0 ];
     Undo_Fnodes( hdptr, ( FON_PTR )NULL );
   }
   
   /* Default Point Setup caller */
   if( flag == 1 )
      PrevTree = Oxtree;


   /* Clicked on the point setup button when 1 or more fonts selected*/
   if( ( flag == 2 ) || ( flag == 3 ) )
     PrevTree = Maintree;

   /* Clicked on the point setup button when only 1 font is selected */
   if( flag == 3 )
   {
     temp_ptr = FindFirstFont( hdptr );
     Undo_Fnodes( hdptr, ( FON_PTR )NULL );
   }
     
     
   if( ( temp_ptr && !flag ) || flag )
   {
       if( !flag )		/* Double Clicked on a font */
       {
         Temp_Fon = temp_ptr;
       
         Old_Cur_Slit = Cur_Slit;
       
         AFLAG( temp_ptr ) = TRUE;
         Select( obj );
       }

       if( flag == 3 )		/* 1 font selected pushing the button */
       {
         Temp_Fon = temp_ptr;
         Old_Cur_Slit = Cur_Slit;
         AFLAG( temp_ptr ) = TRUE;
       /*  Select( obj ); * might not be displayed tho...*/
         flag = 0;
       }
       
       if( flag == 2 )		/* more than 1 font selected */
          Old_Cur_Slit = Cur_Slit;
       
       Reset_Tree( Oxsizes );       		                
       
       if( flag )		/* Display the Group or Default Name */
       {  
          HideObj( FONTNAME );
          HideObj( OLEFT );
          HideObj( ORIGHT );

          TedText( DFTNAME ) = name_text[ flag ];
          ShowObj( DFTNAME );
       }   
       else   
       {			/* Show the Font Name for 1 font */
          HideObj( DFTNAME );
          ShowObj( FONTNAME );
          ShowObj( OLEFT );
          ShowObj( ORIGHT );

          fncount = 0;
          strcpy( cur_font_name, FLNAME( temp_ptr ) );
          fnsize = ( int ) strlen( cur_font_name );     
          
          strncpy( name_buf, fblank, MAX_TITLE );
          strncpy( name_buf, cur_font_name, min( MAX_TITLE, fnsize ) );
          if( fnsize > MAX_TITLE )
     	       name_buf[ MAX_TITLE - 1 ] = 0xAF;
          TedText( FONTNAME ) = name_buf;
       }   

       ObString( USEDFLT ) = use_default_text[ flag ];

       NoExit( DELSIZE );
       Disable( DELSIZE );

       Pointer_Setup( temp_ptr, flag );  /* change for flag == 2 */
       
       new_ptr = &Point_Arena[0];
       mover_setup( new_ptr, Point_Count,
		    OPBASE, OPSLIDER, OPUP, OPDOWN,
		    OPLINE0, OPLINE5, OPTEXT, 0 );

       SetPointButtons();
       Objc_draw( tree, ROOT, MAX_DEPTH, NULL );   		  
   }
   else
      Undo_Fnodes( hdptr, ( FON_PTR )NULL );
}				



/* Pointer_Setup()
 * ====================================================================
 * Setup the point sizes to display in the point size dialog.
 * If there are point sizes assigned, use them. Otherwise, we
 * shall use the default point sizes.
 * The default point sizes are the summation of the point sizes
 * used by the fonts found in the 'EXTEND.SYS' file.
 */
void
Pointer_Setup( FON_PTR cur_ptr, int defaults )
{
   int i;
   int count = 0;
   FON_PTR new_ptr;
   BOOLEAN flag;
   
   if( defaults )
      flag = FALSE;
   else
      flag = Point_Sizes_Exist( cur_ptr );
    
   for( i = 0; i < MAX_DEV; i++ )
   {
       new_ptr = &Point_Arena[i];
       if( flag )
           POINT_SIZE( new_ptr ) = POINTS( cur_ptr)[i];
       else
           POINT_SIZE( new_ptr ) = Current.point_size[i];
           
       strcpy( FNAME( new_ptr ), fblank2 );
       AFLAG( new_ptr ) = FALSE;
       SFLAG( new_ptr ) = FALSE;
       FPREV( new_ptr ) = FNEXT( new_ptr ) = ( FON_PTR )NULL;
       
       /* Copy the ASCII value to the font name field */
       if( POINT_SIZE( new_ptr ) )
       {
            sprintf( FNAME( new_ptr ),"%3d", POINT_SIZE( new_ptr ));
            count++;
       }
       /* Adjust the Pointers */
       if( i )
       	  FPREV( new_ptr ) = ( FON_PTR )&Point_Arena[i - 1]; 
       else
          FPREV( new_ptr ) = ( FON_PTR )NULL;
       
       if( i >= ( MAX_DEV - 1 ) )
          FNEXT( new_ptr ) = ( FON_PTR )NULL;
       else
          FNEXT( new_ptr ) = &Point_Arena[ i + 1 ]; 

    }
   Point_Count = count;    
   Sort_Points();
}




/* Sort_Points()
 * ====================================================================
 * Sort the points found. ( smallest to Largest )
 */
void
Sort_Points( void )
{
   int i,j;
   FON_PTR cur_ptr;
   FON_PTR a_ptr, b_ptr;
   BOOLEAN found;
   
   
   for( i = 0;i < MAX_DEV; i++ )
   {
      cur_ptr = &Point_Arena[i];
      if( !POINT_SIZE( cur_ptr ) )
          POINT_SIZE( cur_ptr ) = 1000;
   }

   cur_ptr = &Point_Arena[ MAX_DEV ];

   for( i = 1; i < MAX_DEV; i++ )
   {
      a_ptr = &Point_Arena[ i ];
      b_ptr = &Point_Arena[ i - 1 ];
      if( POINT_SIZE( a_ptr ) < POINT_SIZE( b_ptr ) )
      {
         j = i;
         
         /* Save to our temp buffer */
         POINT_SIZE( cur_ptr ) = POINT_SIZE( a_ptr );
         strcpy( FNAME( cur_ptr ), FNAME( a_ptr ) );
         
         found = FALSE;
         while( !found )
         {
             j = j - 1;
             a_ptr = &Point_Arena[ j ];
             b_ptr = &Point_Arena[ j + 1 ];
             POINT_SIZE( b_ptr ) = POINT_SIZE( a_ptr );
             strcpy( FNAME( b_ptr ), FNAME( a_ptr ) );
             
             if( !j )
                found = TRUE;
             else
             {
                 a_ptr = &Point_Arena[ j - 1 ];
                 found = ( POINT_SIZE( a_ptr ) <= POINT_SIZE( cur_ptr ) );
             }   
         }
         
         a_ptr = &Point_Arena[ j ];
         POINT_SIZE( a_ptr ) = POINT_SIZE( cur_ptr );
         strcpy( FNAME( a_ptr ), FNAME( cur_ptr ) );
      }
   }

   for( i = 0;i < MAX_DEV; i++ )
   {
      cur_ptr = &Point_Arena[i];
      if( POINT_SIZE( cur_ptr ) == 1000 )
          POINT_SIZE( cur_ptr ) = 0;
   }

}




/* Point_Sizes_Exist()
 * ====================================================================
 * Check to see if any point sizes exist for a specific font.
 */
BOOLEAN
Point_Sizes_Exist( FON_PTR curptr )
{
   BOOLEAN flag = FALSE;
   int i;
   
   for( i = 0; i < MAX_DEV; i++ )
   {
      if( POINTS( curptr )[i] )
          flag = TRUE;
   }
   return( flag );
}




/* Delete_Point_Sizes()
 * ====================================================================
 * Delete the selected point sizes and resort them. We then redisplay
 * the newly adjusted point sizes available for the particular font.
 */
void
Delete_Point_Sizes( void )
{
   FON_PTR curptr;
   GRECT   rect;
      
   deselect( tree, DELSIZE );
   
   curptr = &Point_Arena[0];
   
   /* if no point sizes - we are already sorted
    * just return...otherwise, we have at least
    * one font size.
    */
   if( !POINT_SIZE( curptr ) )
      return;
   
   /* go thru the Arena checking the AFLAG.
    * If the AFLAG is TRUE, we set the font size to zero
    * and blank out the font name.
    * After that, we resort the Arena, update the count
    * and redraw.
    */
   while( curptr )
   {
      if( AFLAG( curptr ) )
      {
         AFLAG( curptr ) = SFLAG( curptr ) = FALSE;
         POINT_SIZE( curptr ) = 0;
         strcpy( FNAME( curptr ), fblank2 );
      }
      curptr = FNEXT( curptr );
   }
   
   Sort_Points();
   Point_Count = Count_Point_Sizes();   

   curptr = &Point_Arena[0];
   mover_setup( curptr, Point_Count,
	        OPBASE, OPSLIDER, OPUP, OPDOWN,
	        OPLINE0, OPLINE5, OPTEXT, 0 );

   Objc_draw( tree, OPBASE, MAX_DEPTH, NULL );   		  
   Objc_draw( tree, OPTEXT, MAX_DEPTH, NULL );

   SetPointButtons();
   Objc_draw( tree, ADD10, MAX_DEPTH, NULL );
   Objc_draw( tree, ADD12, MAX_DEPTH, NULL );
   Objc_draw( tree, ADD18, MAX_DEPTH, NULL );
   Objc_draw( tree, ADD24, MAX_DEPTH, NULL );
   Objc_draw( tree, ADD48, MAX_DEPTH, NULL );
   
   NoExit( DELSIZE );
   Disable( DELSIZE );
          
   rect = ObRect( DELSIZE );
   objc_offset( tree, DELSIZE, &rect.g_x, &rect.g_y );

   rect.g_x -= 3;
   rect.g_y -= 3;
   rect.g_w += 6;
   rect.g_h += 6;

   Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
}





/* Count_Point_Sizes()
 * ====================================================================
 * Count the number of point sizes available for a specific font.
 */
int
Count_Point_Sizes( void )
{
   int i;
   int count = 0;
   FON_PTR curptr;
   
   for( i=0; i < MAX_DEV; i++ )
   {
     curptr = &Point_Arena[i];
     if( POINT_SIZE( curptr ) )
        count++;   
   } 
   return( count );
}




/* Add_New_Point_Size()
 * ====================================================================
 * Display and setup the 'Add a NEW Point Size' dialog box.
 */
void
Add_New_Point_Size( void )
{
   internal_flag = FALSE;
   Undo_Fnodes( hdptr, ( FON_PTR )NULL );
   
   NoExit( DELSIZE );
   Disable( DELSIZE );

   deselect( tree, ADDSIZE );

   Reset_Tree( PtSizeTree );

   Cur_Point_Size = MIN_FONT_SIZE;
   sprintf( Point_Size_Text, "%3d", Cur_Point_Size );
   TedText( NNUM ) = Point_Size_Text;
   Objc_draw( tree, ROOT, MAX_DEPTH, NULL );
}



/* New_Point_Size_Up_Down_Arrow()
 * ====================================================================
 * Handles the 'New Point Size' Dialog box's up and down arrows.
 */
void
New_Point_Size_Up_Down_Arrow( int obj )
{
   MRETS mk;
   
   select( tree, obj );
   do
   {
      Evnt_timer( 50L );
   
      Cur_Point_Size = atoi( Point_Size_Text );

      if( obj == NUP )
         Cur_Point_Size = min( Cur_Point_Size + 1, MAX_FONT_SIZE ); 
      else
         Cur_Point_Size = max( Cur_Point_Size - 1, MIN_FONT_SIZE );

      sprintf( Point_Size_Text, "%3d", Cur_Point_Size );
      Objc_draw( tree, NNUM, MAX_DEPTH, NULL );
      Graf_mkstate( &mk );
   }while( mk.buttons );
   
   deselect( tree, obj );
}



/* Insert_New_Point_Size()
 * ====================================================================
 * Take the new point size chosen and add it to the point size linked
 * list for the chosen font. ( Don't forget to sort them first )
 */
void  		 
Insert_New_Point_Size( int num )
{
   int i;
   FON_PTR new_ptr;
   BOOLEAN flag = FALSE;
   int 	   new_size;
   
   if( !num )
      new_size = atoi( Point_Size_Text );
   else
      new_size = num;
         
   if( !new_size )
       return;
       
   for( i = 0; i < MAX_DEV; i++ )
   {
      new_ptr = &Point_Arena[i];
      if( POINT_SIZE( new_ptr ) )
      {
         if( POINT_SIZE( new_ptr ) == new_size )
            flag = TRUE;
      }
   }
   
   if( !flag )
   {
     internal_flag = TRUE;
     for( i = 0; i < MAX_DEV; i++ )
     {
       new_ptr = &Point_Arena[i];
       if( !POINT_SIZE( new_ptr ) )
       {
          POINT_SIZE( new_ptr ) = new_size;
          sprintf( FNAME( new_ptr ),"%3d", POINT_SIZE( new_ptr ));
          break;
       }
     }
     CacheCheck( new_size ); 
   } 
   Sort_Points();
   Point_Count = Count_Point_Sizes();
}



/* Push_Point_Size()
 * ====================================================================
 * Save the NEW point sizes out to the respective source of the points.
 * If the CANCEL was pressed, we should ignore saving out the point sizes.
 */
void
Push_Point_Size( void )
{
   int 	   i;
   FON_PTR curptr;
   int     num;
   FON_PTR ptr;
   
   /* We need to make sure to count the number of fonts selected
    * IF this isn't the default font caller.
    */
   num = 0;
   if( PrevTree == Maintree )
   {
     if( Status_Value == ACTIVE )
        curptr = fsm_list;
     else
        curptr = active_fsm_list;
     num = FindNumSelected( curptr );
   }     


   /* DEFAULT points setup or only 1 font selected. */
   if( !num || ( num == 1 ) )
   {
     for( i = 0; i < MAX_DEV; i++ )
     {
       ptr = &Point_Arena[i];
       if( PrevTree == Maintree )
          POINTS( Temp_Fon )[i] = POINT_SIZE( ptr );
       else
          Current.point_size[i] = POINT_SIZE( ptr );
     }
   }
   else
   {
      /* Multiple fonts selected. */
      while( curptr )
      {
        if( AFLAG( curptr ) )
        {
          for( i = 0; i < MAX_DEV; i++ )
          {
             ptr = &Point_Arena[i];
             POINTS( curptr )[i] = POINT_SIZE( ptr );
          }
        }   
        curptr = FNEXT( curptr );   
      }
   }
}



/* Default_Point_Button()
 * ====================================================================
 * Set the point sizes for the current font ( the one that we are looking
 * at in the point size dialog box ) to the default point sizes.
 */
void
Default_Point_Button( void )
{
   BOOLEAN flag;
   FON_PTR new_ptr;
   GRECT rect;
      
   flag = ( PrevTree == Oxtree );
   
   deselect( tree, USEDFLT );
   
   if( !flag )	/* Point Sizes Handling */
   {
       if( form_alert( 1, alert14 ) == 2 )
       	   return;
       	   
       Internal_Flag = TRUE;	   
       
       Pointer_Setup( Temp_Fon, DEFAULT_POINTS );

       new_ptr = &Point_Arena[0];
       mover_setup( new_ptr, Point_Count,
  	            OPBASE, OPSLIDER, OPUP, OPDOWN,
	            OPLINE0, OPLINE5, OPTEXT, 0 );

       SetPointButtons();
       Objc_draw( tree, ADD10, MAX_DEPTH, NULL );
       Objc_draw( tree, ADD12, MAX_DEPTH, NULL );
       Objc_draw( tree, ADD18, MAX_DEPTH, NULL );
       Objc_draw( tree, ADD24, MAX_DEPTH, NULL );
       Objc_draw( tree, ADD48, MAX_DEPTH, NULL );

       Objc_draw( tree, OPBASE, MAX_DEPTH, NULL );   		  
       Objc_draw( tree, OPTEXT, MAX_DEPTH, NULL );

       if( !IsDisabled( DELSIZE ) )
       {
         NoExit( DELSIZE );
         Disable( DELSIZE );
          
         rect = ObRect( DELSIZE );
         objc_offset( tree, DELSIZE, &rect.g_x, &rect.g_y );

         rect.g_x -= 3;
         rect.g_y -= 3;
         rect.g_w += 6;
         rect.g_h += 6;

         Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
       }   
   }
   else		/* Default Point Sizes handling */
   {
      if( form_alert( 1, alert15 ) == 2 )
           return;

      /* Replace ALL ACTIVE and InActive Fonts with the Default fonts.*/
      /* Write them INTO the POINTS value */

      Move_Defaults_To_Font( active_fsm_list );
      Move_Defaults_To_Font( fsm_list );
   }
}





/* Move_Defaults_To_Font()
 * ====================================================================
 * Set the point sizes for a particular font to be the default point sizes.
 */
void
Move_Defaults_To_Font( FON_PTR ptr )
{
   int i;
   FON_PTR curptr;
   FON_PTR newptr;
   
   curptr = ptr;
   while( curptr )
   {
     for( i = 0; i< MAX_DEV; i++ )
     {
        newptr = &Point_Arena[i];  
        POINTS( curptr )[i] = POINT_SIZE( newptr );
     }   
     curptr = FNEXT( curptr );
   }
}




/* Point_Left_Right()
 * ====================================================================
 * Handles the left and right buttons on the point size dialog box.
 * These are used to scroll thru the font name which might be longer
 * than the display space allocated.
 */
void
Point_Left_Right( int button )
{
    MRETS mk;
    
    Undo_Fnodes( hdptr, ( FON_PTR )NULL );
    select( tree, button );
    if( button == OLEFT )	/* Left Button */
    {
       do
       {
           Graf_mkstate( &mk );
           if( fncount )
           {
              fncount--;
     	      strncpy( name_buf, &cur_font_name[ fncount ], min( MAX_TITLE, fnsize - fncount ) );
     	      if( fncount )
     	     	   name_buf[0] = 0xAE;
     	      if((fnsize - fncount ) > MAX_TITLE )
     	      	   name_buf[ MAX_TITLE - 1 ] = 0xAF;
     	      TedText( FONTNAME ) = name_buf;
     	      Objc_draw( tree, FONTNAME, MAX_DEPTH, NULL );
           }  
       }while( mk.buttons );
     }
     else     		    
     {     /* Right Button */
       do
       {
          Graf_mkstate( &mk );
          if( ( fnsize > MAX_TITLE ) && ((fncount + MAX_TITLE ) < fnsize ))
          {
            fncount++;
            strncpy( name_buf, &cur_font_name[ fncount], min( MAX_TITLE, fnsize - fncount) );
            name_buf[0] = 0xAE;
            if( (fnsize - fncount) > MAX_TITLE )
            	name_buf[ MAX_TITLE - 1 ] = 0xAF;
            TedText( FONTNAME ) = name_buf;
            Objc_draw( tree, FONTNAME, MAX_DEPTH, NULL );
          }	   		    
       }while( mk.buttons );
    }
    deselect( tree, button );
}




/* RedrawNNUM()
 * ====================================================================
 * Redraws the NNUM object in the Add a point dialog box.
 * Needed so that the editable text field is redrawn properly.
 */
void
RedrawNNUM( void )
{
    GRECT rect;
    
    rect = ObRect( NNUM );
    objc_offset( tree, NNUM, &rect.g_x, &rect.g_y );
    rect.g_h += 6;
    rect.g_y -= 3;
    rect.g_w += 2;
    Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
}



/* SetPointButtons()
 * ====================================================================
 */
void
SetPointButtons( void )
{
   ( FindPointSize( 10 ) ? ( Select( ADD10 ) ) : ( Deselect( ADD10 ) ) );
   ( FindPointSize( 12 ) ? ( Select( ADD12 ) ) : ( Deselect( ADD12 ) ) );
   ( FindPointSize( 18 ) ? ( Select( ADD18 ) ) : ( Deselect( ADD18 ) ) );
   ( FindPointSize( 24 ) ? ( Select( ADD24 ) ) : ( Deselect( ADD24 ) ) );
   ( FindPointSize( 48 ) ? ( Select( ADD48 ) ) : ( Deselect( ADD48 ) ) );
}


/* FindPointSize()
 * ====================================================================
 * Returns TRUE or FALSE if the point size exists
 */
BOOLEAN
FindPointSize( int num )
{
  FON_PTR newptr;
  FON_PTR curptr;
  BOOLEAN flag;
  
  flag = FALSE;
  newptr = &Point_Arena[0];  
  curptr = newptr;
  while( curptr )
  {
     if( POINT_SIZE( curptr ) == num )
     {
        flag = TRUE;
        break;
     }   
     curptr = FNEXT( curptr );
  }
  return( flag );
}
 

/* default_buttons() 
 * ====================================================================
 */
void
default_buttons( int obj )
{
    MRETS   mk;
    FON_PTR newptr;
    FON_PTR curptr;
    int     num;
    GRECT   rect;
    
    switch( obj )
    {
       case ADD10: num = 10;
       		   break;
       		   
       case ADD12: num = 12;
       		   break;
       		   
       case ADD18: num = 18;
       		   break;
       		   
       case ADD24: num = 24;
       		   break;
       		   
       case ADD48: num = 48;
       		   break;
    }

    /* Turn off any that are marked for deletion */
    newptr = &Point_Arena[0];
    curptr = newptr;
    while( curptr )
    {
       if( AFLAG( curptr ) )
           AFLAG( curptr ) = FALSE;
       curptr = FNEXT( curptr );
    }

    if( IsSelected( obj ) )	/* add point size */
    {
	Insert_New_Point_Size( num );   
        Point_Count = Count_Point_Sizes();	
   	mover_setup( hdptr, Point_Count,
	             OPBASE, OPSLIDER, OPUP, OPDOWN,
	             OPLINE0, OPLINE5, OPTEXT, 0 );
		  
	SetPointButtons();     		     

        Objc_draw( tree, OPBASE, MAX_DEPTH, NULL );   		  
        Objc_draw( tree, OPTEXT, MAX_DEPTH, NULL );

        if( !IsDisabled( DELSIZE ) )
        {
          NoExit( DELSIZE );
          Disable( DELSIZE );
          
          rect = ObRect( DELSIZE );
          objc_offset( tree, DELSIZE, &rect.g_x, &rect.g_y );

          rect.g_x -= 3;
          rect.g_y -= 3;
          rect.g_w += 6;
          rect.g_h += 6;

          Objc_draw( tree, ROOT, MAX_DEPTH, &rect );
        }   
	Internal_Flag |= internal_flag;   		  
    }       
    else
    {  /* Delete Point Size */   
      newptr = &Point_Arena[0];  
      curptr = newptr;
      while( curptr )
      {
        if( POINT_SIZE( curptr ) == num )
        {
          AFLAG( curptr ) = TRUE;
          Delete_Point_Sizes();         
	  Internal_Flag |= TRUE;   		  
          break;
        }   
        curptr = FNEXT( curptr );
      }
    }  
    Evnt_button( 1, 1, 0, &mk );	/* wait for up button */
}

 