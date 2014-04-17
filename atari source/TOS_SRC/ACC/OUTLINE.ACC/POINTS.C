/* ===================================================================
 * FILE: POINTS.C
 * ===================================================================
 * DATE: December 9, 1992
 *	 January 18, 1993 Added Character Set ID handling
 *	 June     7, 1993 Added Atari Wingbats
 * 
 * DESCRIPTION: Fonts ACC
 *
 * This file handles the point size dialog box.
 *
 * COMPILER: TURBO C Version 2.0
 */
 

/* INCLUDE FILES
 * ===================================================================
 */
#include <sys\gemskel.h>
#include <tos.h>
#include <linea.h>
#include <string.h>
#include <stdio.h>

#include "country.h"
#include "fonthead.h"
#include "fonts.h"
#include "mainstuf.h"
#include "text.h"
#include "fsmio.h"
#include "mover.h"
#include "front.h"
#include "options.h"
#include "status.h"


/* STRUCTURES
 * ===================================================================
 */


/* EXTERN
 * ===================================================================
 */
extern int AES_Version;



/* PROTOTYPES
 * ===================================================================
 */
int	DoPoints( OBJECT *xtree, int obj );
int	HandlePoints( int button, WORD *msg );

void	Pointer_Setup( FON_PTR cur_ptr, int defaults );
void	Sort_Points( void );
BOOLEAN	Point_Sizes_Exist( FON_PTR curptr );

void	SetPointButtons( void );
BOOLEAN	FindPointSize( int num );
void	default_buttons( int obj );
int     Insert_New_Point_Size( int num );
int	Count_Point_Sizes( void );
void	Delete_Point_Sizes( void );
int	FakeButton( int obj );

void	Default_Point_Button( void );
void	Move_Defaults_To_Font( FON_PTR ptr );
void	Push_Point_Size( void );


void	DoAdd( void );
int	HandleAdd( int button, WORD *msg );
void	New_Point_Size_Up_Down_Arrow( int obj );


/* DEFINES
 * ===================================================================
 */
#define POINTS_HEIGHT  6
#define FRONT_HEIGHT   14
#define INACTIVE_HEIGHT   14
#define UNDO	0x6100



/* GLOBALS
 * ===================================================================
 */
OBJECT *ReturnTree;
int    Point_Count;		/* # of POint Sizes for font */
int    Old_Cur_Slit;
char   Point_Size_Text[ 4 ];	/* Text for New Point Size */
int    Cur_Point_Size;		/* Current Point Size for New Point Size*/

BOOLEAN PointsInternalFlag;	/* If we ADD,Delete or Set Defaults,
				 * we must make sure a change is 
				 * registered.
				 */


/* FUNCTIONS
 * ===================================================================
 */


/* DoPoints()
 * ===================================================================
 */
int
DoPoints( OBJECT *xtree, int obj )
{
    int count;
    FON_PTR curptr;
    FON_PTR TempList;

    ReturnTree = xtree;

    Reset_Tree( ad_points );

    HideObj( PFBASE1 ); /* Base with the filenames */
    HideObj( PFBASE2 ); /* Blank base for Group and Defaults */
    HideObj( PTITLE1 ); /* Title of Point Sizes */
    
    /* If the calling tree is the front tree,
     * find out if any outline fonts are selected.
     * if so, is it 1, or more...
     */
    if( ( ReturnTree == ad_front ) || ( ReturnTree == ad_inactive ) )
    {
	if( ReturnTree == ad_front )
	   TempList = installed_list;
	else
	   TempList = available_list;

	/* Check if we had double-clicked on an object.
 	 * OBJ would be non-zero then.
	 * Check also if the object is a SPD_FONT.
	 */
	if( obj )
	{
	    /* double clicked on an object */
            curptr = Active_Slit[ obj - First_Obj ];
	    if( curptr && ( FTYPE( curptr ) == SPD_FONT ))
	    {
		  /* it is a SPEEDO Font.!!!! */
		  /* Undo everything else and select this font! */
		  Undo_Fnodes( hdptr, ( FON_PTR )NULL );
	          Temp_Fon = curptr;
         	  Old_Cur_Slit = Cur_Slit;
	          AFLAG( curptr ) = TRUE;


		  ActiveTree( ReturnTree );
         	  Select( obj );	/* Select the font */
		  if( IsActiveTree( ad_front ) )
		    CheckHotFront( hdptr );

		  if( IsActiveTree( ad_inactive ) )
		    CheckHotAvailable( hdptr );
		  ActiveTree( ad_points );
	    }
	    else
	    {
	        Reset_Tree( ReturnTree );
                form_alert( 1, pnt1 );
	        return(1);
	    }	 
	}


	if( IsChanged( TempList ) )
       	{
	   count = CountSelectedFonts( TempList, SPD_FONT );
	   if( !count )
	   {
	       /* No Outline Fonts to make point sizes with */
	       form_alert( 1, pnt1 );
	       Reset_Tree( ReturnTree );
	       return( TRUE );
	   }

	   /* Only 1 font was selected */
	   if( count == 1 )
	   {
	      ShowObj( PFBASE1 );	/* show Filenames */
	      
	      /* No Object selected by double_clicking...
	       * If an object WAS selected by double_clicking...
	       * we already initialized wot we had to do...
	       */
	      if( !obj )
	      {
		/* Selected CONFIGURE */
		/* Find the first SPD_FONT */
		Temp_Fon = curptr = FindFirstFont( hdptr );
         	Old_Cur_Slit = Cur_Slit;
	      }

	      ObString( PFIELD1 ) = FNAME( curptr );
	      ObString( PFIELD2 ) = FFNAME( curptr );
	      ObString( PFIELD6 ) = FCHARSET( curptr );

	      /* Default to Unknown */
	      ObString( PFIELD5 ) = SetTitlexx;

	      /* BitStream Text */
	      if( !strncmp( FCHARSET( curptr ), "00", 2 ))
	        ObString( PFIELD5 ) = SetTitle00;
	        
	      /* Bitstream Symbol */
	      if( !strncmp( FCHARSET( curptr ), "01", 2 ))
	        ObString( PFIELD5 ) = SetTitle01;
	        
	      /* Bitstream Dingbats */  
	      if( !strncmp( FCHARSET( curptr ), "02", 2 ))
	        ObString( PFIELD5 ) = SetTitle02;

	      /* PostScript Text */
	      if( !strncmp( FCHARSET( curptr ), "11", 2 ))
	        ObString( PFIELD5 ) = SetTitle11;

	      /* PostScript Symbol */
	      if( !strncmp( FCHARSET( curptr ), "12", 2 ))
	        ObString( PFIELD5 ) = SetTitle12;

	      /* PostScript Dingbats */
	      if( !strncmp( FCHARSET( curptr ), "13", 2 ))
	        ObString( PFIELD5 ) = SetTitle13;

	      /* Atari Wingbats */
	      if( !strncmp( FCHARSET( curptr ), "14", 2 ))
	        ObString( PFIELD5 ) = SetTitle14;

	   }

	   /* More than one font was selected */
	   if( count > 1 )
	   {
	      TedText( PTITLE1 ) = pnt_title2;

	      /* Show Title and a Blank Box */
	      ShowObj( PTITLE1 );
	      ShowObj( PFBASE2 );
	      
	      Temp_Fon = curptr = FindFirstFont( hdptr );
              Old_Cur_Slit = Cur_Slit;
	   }
	   ObString( PNTDEF ) = pnt_title4;

        }
	else
	{
	   Reset_Tree( ReturnTree );
           form_alert( 1, pnt1 );
	   return(1);
	}
    }


    /* The Default Point Sizes Settings */
    if( ( ReturnTree ) == ad_options )
    {
	curptr = ( FON_PTR )NULL;
	TedText( PTITLE1 ) = pnt_title3;
	ObString( PNTDEF ) = pnt_title5;

        /* Show Title and a Blank Box */
        ShowObj( PTITLE1 );
        ShowObj( PFBASE2 );
    }

    NoExit( PNTDEL );
    Disable( PNTDEL );

    /* flag = 1 - Use Defaults */
    /* flag = 0, use points    */
    Pointer_Setup( curptr, ReturnTree == ad_options );
       
    curptr = &Point_Arena[0];
    mover_setup( curptr, Point_Count,
		 PNTBASE, PNTSLIDE, PNTUP, PNTDOWN,
		 PNTLINE0, PNTLINE5, PNTLINE, 0, POINTS_HEIGHT );

    SetPointButtons();

    Enable( PNTADD );
    MakeExit( PNTADD );

    if( Point_Count >= MAX_POINTS )
    {
       Disable( PNTADD );
       NoExit( PNTADD );
    }

    PointsInternalFlag = FALSE;
    Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
    return( FALSE );
}



/* HandlePoints()
 * ===================================================================
 */
int
HandlePoints( int button, WORD *msg )
{
   int     quit;
   int     dclick;

   quit   = FALSE;
   dclick = FALSE;
   
   /* Handle Double-clicking of the objects */   
   if( ( button != -1 ) && ( button & 0x8000 ) )
   {
      button &= 0x7FFF;
      dclick = TRUE;
   }
   
   switch( button )
   {
     case POINTOK:  if( Count_Point_Sizes() <= 0 )
		    {
		       /* Used to make sure that we have at least 1 
		        * point size available. If we decide to add a
		        * point size, we'll just not exit back to
		        * wherever we came from.
		        */
		       if( form_alert( 1, alertpnt20 ) == 1 )
		       {
		          XDeselect( tree, POINTOK );
		          return( quit );
		       }
		       else
		         button = POINTCAN;   
		    }
		    Deselect( POINTOK );


     case POINTCAN: Deselect( button );

		    if( button == POINTCAN )
		       PointsInternalFlag = FALSE;
		    else	/* Save out the NEW point sizes ONLY if not a CANCEL */
		    {
		       if( PointsInternalFlag )
		       {
		         /* Put the fonts into the data area*/
		         Push_Point_Size();

		         /* If we've done something with the points...
		          * then have them make width tables again.
		          */
		         MakeWidthFlag = TRUE;
		         SetChangeFlag();
		       }  
		    }   

		    Reset_Tree( ReturnTree );

		    if( IsActiveTree( ad_front ) )
		    {
                       mover_setup( installed_list, installed_count,
		                    FBASE, FSLIDER, FUP, FDOWN,
		  		    LINE0, LINE13, LINEBASE, Old_Cur_Slit, FRONT_HEIGHT );
		       HideObj( LINEBASE );
		    }

		    if( IsActiveTree( ad_inactive ) )
		    {
		        mover_setup( available_list, available_count,
		 		     IBASE, ISLIDER, IUP, IDOWN,
		 		     ILINE0, ILINE13, ILINE, Old_Cur_Slit, INACTIVE_HEIGHT );
			HideObj( ILINE );	 		     
		    }

		    Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
		   
		    if( IsActiveTree( ad_front ) )
		    {
		       ShowObj( LINEBASE );
		       RedrawBase( tree, LINEBASE );
		    }

		    if( IsActiveTree( ad_inactive ) )
		    {
		       ShowObj( ILINE );
		       RedrawBase( tree, ILINE );
		    }
		    
     		    break;

     case PNTLINE0:
     case PNTLINE1:
     case PNTLINE2:
     case PNTLINE3:
     case PNTLINE4:
     case PNTLINE5:
     case PNTUP:
     case PNTDOWN:
     case PNTBASE:
     case PNTSLIDE:  mover_button( button, dclick );
		     break;

     case P10:
     case P12:
     case P18:
     case P24:
     case P48:   default_buttons( button );
		 break;

     case PNTDEL:  if( form_alert( 1, alertdel ) == 1 )
		   {
		     Delete_Point_Sizes();

		     if( Point_Count < MAX_POINTS )
		     {
		       if( IsDisabled( PNTADD ) )
	   		 ChangeButton( ad_points, PNTADD, TRUE );
		     }
		   }
		   else
		     XDeselect( ad_points, PNTDEL );
		   break;

     case PNTDEF: Default_Point_Button();
		  XDeselect( tree, PNTDEF );
		  break;

     case PNTADD: Deselect( PNTADD );
		  Undo_Fnodes( hdptr, ( FON_PTR )NULL );
   
   		  NoExit( PNTDEL );
   		  Disable( PNTDEL );

		  DoAdd();
		  break;

     default:	 if( button == -1 )
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
		                        if( form_alert( 1, alertpnt20 ) == 1 )
				            return( quit );	/* NOTE: quit == FALSE right now */
				        else
				        {
				            /* If they are going to cancel adding a point size AND
				             * we can't allow no point sizes to exist, hey...
				             * we're not gonna prompt to save the 'EXTEND.SYS' file 
				             * either then.
				             */
				            PointsInternalFlag =  FALSE;
				        }
		                     }
		                     quit = TRUE;
		                     if( PointsInternalFlag )
		                     {
		       			MakeWidthFlag = TRUE; /* Make width tables */
		 		        Push_Point_Size();	/* Store away the changed point sizes */
		                        SetChangeFlag();	/* Mark to save SYS files */
				     }
     		     		     CloseWindow();
				     break;

		     case CT_KEY:    if( msg[3] == UNDO )
				        Undo_Fnodes( &Point_Arena[0], ( FON_PTR )NULL );
		     		     break;
     		     default:
     		     		break;
     		   }
     		 }
		 else
		   Undo_Fnodes( &Point_Arena[0], ( FON_PTR )NULL );
     		 break;
   }
   return( quit );


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
    
   for( i = 0; i < MAX_POINTS; i++ )
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
       FTYPE( new_ptr ) = SPD_FONT;
              
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
       
       if( i >= ( MAX_POINTS - 1 ) )
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
   
   
   for( i = 0;i < MAX_POINTS; i++ )
   {
      cur_ptr = &Point_Arena[i];
      if( !POINT_SIZE( cur_ptr ) )
          POINT_SIZE( cur_ptr ) = 1000;
   }

   cur_ptr = &Point_Arena[ MAX_POINTS ];

   for( i = 1; i < MAX_POINTS; i++ )
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

   for( i = 0;i < MAX_POINTS; i++ )
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
   
   for( i = 0; i < MAX_POINTS; i++ )
   {
      if( POINTS( curptr )[i] )
          flag = TRUE;
   }
   return( flag );
}



/* SetPointButtons()
 * ====================================================================
 */
void
SetPointButtons( void )
{
   ( FindPointSize( 10 ) ? ( Select( P10 ) ) : ( Deselect( P10 ) ) );
   ( FindPointSize( 12 ) ? ( Select( P12 ) ) : ( Deselect( P12 ) ) );
   ( FindPointSize( 18 ) ? ( Select( P18 ) ) : ( Deselect( P18 ) ) );
   ( FindPointSize( 24 ) ? ( Select( P24 ) ) : ( Deselect( P24 ) ) );
   ( FindPointSize( 48 ) ? ( Select( P48 ) ) : ( Deselect( P48 ) ) );
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
 * Selecting/Deselecting presized fonts 10,12,18,24,48 points
 */
void
default_buttons( int obj )
{
    MRETS   mk;
    FON_PTR newptr;
    FON_PTR curptr;
    int     num;

    /* See if we're still on the object when we lift the mouse button */
    if( !FakeButton( obj ) )
	return;

    switch( obj )
    {
       case P10: num = 10;
       		 break;
       		   
       case P12: num = 12;
       		 break;
       		   
       case P18: num = 18;
       		 break;
       		   
       case P24: num = 24;
       		 break;
       		   
       case P48: num = 48;
       		 break;
    }



    if( IsSelected( obj ) )	/* add point size */
    {
	if( Insert_New_Point_Size( num ) )
	{
	    /* If there is no more room for any more point sizes, don't add it*/
	    if( Point_Count >= MAX_POINTS )
	    {
	      if( IsSelected( obj ) )
		XDeselect( tree, obj );
      	      return;
    	    }
	}
   	mover_setup( hdptr, Point_Count,
	             PNTBASE, PNTSLIDE, PNTUP, PNTDOWN,
	             PNTLINE0, PNTLINE5, PNTLINE, 0, POINTS_HEIGHT );
        Undo_Fnodes( &Point_Arena[0], ( FON_PTR )NULL );

	SetPointButtons();     		     

	RedrawObject( tree, PNTBASE );
        Objc_draw( tree, PNTLINE, MAX_DEPTH, NULL );

        if( !IsDisabled( PNTDEL ) )
	   ChangeButton( ad_points, PNTDEL, FALSE );
    }       
    else
    {
      Undo_Fnodes( &Point_Arena[0], ( FON_PTR )NULL );

      /* Delete Point Size */   
      newptr = &Point_Arena[0];  
      curptr = newptr;
      while( curptr )
      {
        if( POINT_SIZE( curptr ) == num )
        {
          AFLAG( curptr ) = TRUE;
          Delete_Point_Sizes();         
          break;
        }
        curptr = FNEXT( curptr );
      }
    }



    /* Turn OFF ADD Points Button if necessary */
    Point_Count = Count_Point_Sizes();
    if( Point_Count  >= MAX_POINTS )
    {
       if( !IsDisabled( PNTADD ) )
	  ChangeButton( ad_points, PNTADD, FALSE );
    }

    /* Turn ON Add Points button if necessary */
    if( Point_Count < MAX_POINTS )
    {
       if( IsDisabled( PNTADD ) )
	   ChangeButton( ad_points, PNTADD, TRUE );
    }

    Evnt_button( 1, 1, 0, &mk );	/* wait for up button */
}



/* Insert_New_Point_Size()
 * ====================================================================
 * Take the new point size chosen and add it to the point size linked
 * list for the chosen font. ( Don't forget to sort them first )
 * -1 invalid point size
 * -2 point size already exists
 * -3 no more room for any more point sizes.
 * 0 - AOK
 */
int  		 
Insert_New_Point_Size( int num )
{
   int i;
   FON_PTR new_ptr;
   BOOLEAN flag = FALSE;
   int 	   new_size;
   
   flag = FALSE;
   if( !num || ( num == -1 ) )
      new_size = atoi( Point_Size_Text );
   else
      new_size = num;
         
   if( !new_size )
   {
       Point_Count = Count_Point_Sizes();

       /* SKip for if passed in -1 - called when closing a window*/       
       if( num != -1 )
         form_alert( 1, point_invalid );
       return( -1 );	/* Invalid Point Size */
   }
       
   for( i = 0; i < MAX_POINTS; i++ )
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
     for( i = 0; i < MAX_POINTS; i++ )
     {
       new_ptr = &Point_Arena[i];
       if( !POINT_SIZE( new_ptr ) )
       {
          POINT_SIZE( new_ptr ) = new_size;
          sprintf( FNAME( new_ptr ),"%3d", POINT_SIZE( new_ptr ));
          break;
       }
     }

     /* No More Room for anymore point sizes. */
     if( i >= MAX_POINTS )
     {
         if( num != -1 )
            form_alert( 1, point_noroom );
	 return( -3 );
     }
     CacheCheck();
   } 
   else
   {
        if( num != -1 )
	   form_alert( 1, point_exists );
	return( -2 );	/* point size already exists */
   }
   
   /* Set this flag ONLY if this is not the defaults */
   if( ReturnTree != ad_options )
       PointsInternalFlag = TRUE;
   Sort_Points();
   Point_Count = Count_Point_Sizes();
   return( 0 ); 
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
   
   for( i=0; i < MAX_POINTS; i++ )
   {
     curptr = &Point_Arena[i];
     if( POINT_SIZE( curptr ) )
        count++;   
   } 
   return( count );
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
      
   Deselect( PNTDEL );
   
   curptr = &Point_Arena[0];
   
   /* if no point sizes - we are already sorted
    * just return...otherwise, we have at least
    * one font size.
    */
   if( !POINT_SIZE( curptr ) )
   {
      Point_Count = Count_Point_Sizes();   
      return;
   }


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
         
         /* Set CHANGe FLAG only if this is NOT the defaults */
         if( ReturnTree != ad_options )
	    PointsInternalFlag = TRUE;
      }
      curptr = FNEXT( curptr );
   }
   
   Sort_Points();
   Point_Count = Count_Point_Sizes();   

   curptr = &Point_Arena[0];
   mover_setup( curptr, Point_Count,
	        PNTBASE, PNTSLIDE, PNTUP, PNTDOWN,
	        PNTLINE0, PNTLINE5, PNTLINE, 0, POINTS_HEIGHT );

   RedrawObject( tree, PNTBASE );
   Objc_draw( tree, PNTLINE, MAX_DEPTH, NULL );

   SetPointButtons();
   RedrawObject( tree, P10 );
   RedrawObject( tree, P12 );
   RedrawObject( tree, P18 );
   RedrawObject( tree, P24 );
   RedrawObject( tree, P48 );
   
   if( !IsDisabled( PNTDEL ) )
      ChangeButton( ad_points, PNTDEL, FALSE );
}



/* FakeButton()
 * ====================================================================
 * Use this to make a touchexit act like a button exit.
 */
int
FakeButton( int obj )
{
    MRETS mk;
    int   cur_obj;
    int   state;

    Graf_mkstate( &mk );
    cur_obj = objc_find( tree, obj, MAX_DEPTH, mk.x, mk.y );
    state = IsSelected( obj );

    do
    {
	/* Check if the object that the mouse is over is our
	 * starting object
	 */
        if( cur_obj == obj )
        {
	   /* We are on the object */

	   if( state )
	   {
	      /* When we are on the obj, DESELECT it ALWAYS */
	      if( IsSelected( obj ) )
		XDeselect( tree, obj );
	   }
	   else
	   {
	      /* When we are on the obj, SELECT it always */
	      if( !IsSelected( obj ) )
	         XSelect( tree, obj );
	   }	   
        }
        else
        {
	   /* We are OFF the object */
	   if( state )
	   {
	      /* When we are off the obj, SELECT it ALWAYS */
	      if( !IsSelected( obj ) )
		  XSelect( tree, obj );
	   }
	   else
	   {
	      /* When we are off the obj, DESELECT it always */
	      if( IsSelected( obj ))
		 XDeselect( tree, obj );
	   }	   
        }
	
        Graf_mkstate( &mk );
        cur_obj = objc_find( tree, obj, MAX_DEPTH, mk.x, mk.y );
    }while( mk.buttons );
    return( cur_obj == obj );
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
      
   flag = ( ReturnTree == ad_options );

   if( !flag )	/* Point Sizes Handling */
   {
       if( form_alert( 1, alertpnt14 ) == 2 )
       	   return;


       Pointer_Setup( Temp_Fon, TRUE );

       new_ptr = &Point_Arena[0];
       mover_setup( new_ptr, Point_Count,
  	            PNTBASE, PNTSLIDE, PNTUP, PNTDOWN,
	            PNTLINE0, PNTLINE5, PNTLINE, 0, POINTS_HEIGHT );

       SetPointButtons();
       RedrawObject( tree, P10 );
       RedrawObject( tree, P12 );
       RedrawObject( tree, P18 );
       RedrawObject( tree, P24 );
       RedrawObject( tree, P48 );

       RedrawObject( tree, PNTBASE );
       Objc_draw( tree, PNTLINE, MAX_DEPTH, NULL );

       if( !IsDisabled( PNTDEL ) )
          ChangeButton( ad_points, PNTDEL, FALSE );
   }
   else		/* Default Point Sizes handling */
   {
      if( form_alert( 1, alertpnt15 ) == 2 )
           return;

      /* Replace ALL ACTIVE and InActive Fonts with the Default fonts.*/
      /* Write them INTO the POINTS value */

      
      Move_Defaults_To_Font( installed_list );
      Move_Defaults_To_Font( available_list );
   }
   PointsInternalFlag = TRUE;	   
}





/* Move_Defaults_To_Font()
 * ====================================================================
 * Set the point sizes for a font list to be the default point sizes.
 * NOTE: SPEEDO FONTS ONLY
 * 
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
     if( FTYPE( curptr ) == SPD_FONT )
     {
       for( i = 0; i< MAX_POINTS; i++ )
       {
          newptr = &Point_Arena[i];  
          POINTS( curptr )[i] = POINT_SIZE( newptr );
       }   
     }
     curptr = FNEXT( curptr );
   }
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
   if( ReturnTree == ad_front )
   {
      curptr = installed_list;
     num = CountSelectedFonts( curptr, SPD_FONT );

   }     

   if( ReturnTree == ad_inactive )
   {
     curptr = available_list;
     num = CountSelectedFonts( curptr, SPD_FONT );
   }

   /* DEFAULT points setup or only 1 font selected. */
   if( !num || ( num == 1 ) )
   {
     for( i = 0; i < MAX_POINTS; i++ )
     {
       ptr = &Point_Arena[i];
       /* If we're not the returning to the options tree,
	* we need to set some point sizes in a font.
        */
       if( ReturnTree != ad_options )
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
          for( i = 0; i < MAX_POINTS; i++ )
          {
             ptr = &Point_Arena[i];
             POINTS( curptr )[i] = POINT_SIZE( ptr );
          }
        }   
        curptr = FNEXT( curptr );   
      }
   }
}



/* =============================================================
 * ADD POINT SIZE HANDLING...
 * =============================================================
 */


/* DoAdd()
 * =============================================================
 * display the add point size dialog
 */
void
DoAdd( void )
{
   Reset_Tree( ad_add );
   Cur_Point_Size = MIN_FONT_SIZE;
   sprintf( Point_Size_Text, "%3d", Cur_Point_Size );
   TedText( ADDNUM ) = Point_Size_Text;
   Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
}



/* HandleAdd()
 * =============================================================
 * Button handleing for add poinst size dialog.
 */
int
HandleAdd( int button, WORD *msg )
{
   int     quit;

   quit   = FALSE;
   
   /* Handle Double-clicking of the objects */   
   if( ( button != -1 ) && ( button & 0x8000 ) )
      button &= 0x7FFF;
   
   switch( button )
   {
     case ADDOK:  /* Add the new point size in PointSizeText[] */
		  /* The number is added within Insert_New_Point_Size() */
		  /* If the point size is invalid or if it already 
		   * exists, stay within the dialog.
		   */
    		  if( Insert_New_Point_Size( 0 ) )
		  {
		     XDeselect( tree, ADDOK );
		     return( quit );
		  }
		  /* PointsInternalFlag is set by Insert_NewPoint_Size()
		   * There is no need to SetChangeFlag() because the
		   * PointSize() tree will set it instead.
		   */
		   
     case ADDCAN: Deselect( button );

		  Reset_Tree( ad_points );

		  SetPointButtons();     		     
			
		  Point_Count = Count_Point_Sizes();	
	     	  mover_setup( hdptr, Point_Count,
		               PNTBASE, PNTSLIDE, PNTUP, PNTDOWN,
		               PNTLINE0, PNTLINE5, PNTLINE, 0, POINTS_HEIGHT );

		  if( Point_Count >= MAX_POINTS )
		  {
		     Disable( PNTADD );
		     NoExit( PNTADD );
		  }
		  Objc_draw( tree, ROOT, MAX_DEPTH, NULL ); 
		  break;

  
     case ADDUP:
     case ADDDOWN:  New_Point_Size_Up_Down_Arrow( button );
     		    break;


     default:	 if( button == -1 )
     		 {
     		   switch( msg[0] )
     		   {
     		     case WM_REDRAW: 
     		     		     break;
     			     		     
     		     case AC_CLOSE:  quit = TRUE;
     		     		     break;
     				     		     
     		     case WM_CLOSED:
				     /* Add the new point size in PointSizeText[] */
		  		     /* The number is added within Insert_New_Point_Size() */
		  		     /* If the point size is invalid or if it already 
		  		      * exists, don't at it, but don't stay.
				      */
		    		     Insert_New_Point_Size( 0 );

				     if( Count_Point_Sizes() <= 0 )
		    		     {
		       			/* Used to make sure that we have at least 1 
		        		 * point size available. If we decide to add a
		        		 * point size, we'll just not exit back to
		        		 * wherever we came from.
		        		 */
		       		         if( form_alert( 1, alertpnt20 ) == 1 )
				            return( quit );
		  		         else
		  		         {
				            /* If they are going to cancel adding a point size AND
				             * we can't allow no point sizes to exist, hey...
				             * we're not gonna prompt to save the 'EXTEND.SYS' file 
				             * either then.
				             */
					     PointsInternalFlag = FALSE;		  		         
		  		         }
		    		     }
		  		     /* PointsInternalFlag is set by Insert_NewPoint_Size()
		   		      * There is no need to SetChangeFlag() because the
		   		      * PointSize() tree will set it instead.
		   		      */     		     
	     		             quit = TRUE;
	     		             
		    		     if( PointsInternalFlag )
		    		     {
		       			MakeWidthFlag = TRUE;
		 		        Push_Point_Size();
		 		        SetChangeFlag();
	     		             }
	     		             
     		     		     CloseWindow();
				     break;

		     case CT_KEY:    RedrawObject( ad_add, ADDNUM );
		     		     break;

     		     default:
     		     		break;
     		   }
     		 }
     		 break;
   }
   return( quit );
}



/* New_Point_Size_Up_Down_Arrow()
 * ====================================================================
 * Handles the 'New Point Size' Dialog box's up and down arrows.
 */
void
New_Point_Size_Up_Down_Arrow( int obj )
{
   MRETS mk;
   
   XSelect( tree, obj );
   do
   {
      Evnt_timer( 50L );
   
      Cur_Point_Size = atoi( Point_Size_Text );

      if( obj == ADDUP )
         Cur_Point_Size = min( Cur_Point_Size + 1, MAX_FONT_SIZE ); 
      else
         Cur_Point_Size = max( Cur_Point_Size - 1, MIN_FONT_SIZE );

      sprintf( Point_Size_Text, "%3d", Cur_Point_Size );
      Objc_draw( tree, ADDNUM, MAX_DEPTH, NULL );
      Graf_mkstate( &mk );
   }while( mk.buttons );
   
   XDeselect( tree, obj );
}
