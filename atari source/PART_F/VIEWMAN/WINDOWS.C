/* WINDOWS.C
 * ================================================================
 * DATE: October 17, 1990
 * DESCRIPTION: 
 */
#include <sys\gemskel.h>
#include <string.h>
#include <tos.h>
#include <vdikeys.h>

#include <stdio.h>

#include "viewer.h"
#include "DaveStuf.h"
#include "mainstuf.h"

/*
 * TURN OFF Turbo C "parameter X is never used" warnings
 */
#pragma warn -par



/* DEFINES
 * ================================================================
 */
#define DUMMY	    4	/* just a random number for window offsets(pixels) */
#define NO_WINDOW   ( -1 )
#define WKIND	    ( INFO | NAME | FULLER | MOVER | SIZER | UPARROW | DNARROW | VSLIDE | LFARROW | RTARROW | HSLIDE )
#define BSIZE	    16

#define WORLD	   0
#define LIBRARY	   1

typedef struct _wdata
{
    int xoffset;		/* Xoffset in window (pixels ) */
    int yoffset;		/* Yoffset in window (pixels ) */
    unsigned int w_wid;		/* Width of form	       */
    unsigned int w_hite;	/* Height of form	       */
    GRECT  w;			/* GRECT of work window	       */
}WDATA;




/* PROTOTYPES
 * ================================================================
 */
void DaveName( int id, char *name );

void slider_chk( void );
int  scale( int visible, int factor, int total );
void sliderv( void );
void sliderh( void );

void nada( void );
void wupline( void );
void wdnline( void );
void wrtline( void );
void wlfline( void );

void Full_Window( void );
void Do_Arrows( int action );
void HSlide_Window( int position );
void VSlide_Window( int position );
void Size_Window( GRECT *rect );
void Move_Window( GRECT *rect );

int  Check_ID( int id );
void SetDave_Stuff( int handle );
void Set_Window_To_Size( int width, int height );
void DaveInfo( int id, char *name );
void Update_World( int handle );

void Gem_Exit( int code );
int  GetTopWindow( void );
void do_arrow_buttons( int key );

/* EXTERN
 * ================================================================
 */


/* GLOBALS 
 * ================================================================
 */

/*-----------------------------------------------------------------
 * Window Structure variables 
 *----------------------------------------------------------------- 
 */
WINFO  *W; 				/* Global Window ptr */
WINFO  w;				/* WORLD FORM Window structure  */
WINFO  l;				/* Library WiNdOw Structure     */
WINFO *window[2];			/* Window array			*/

WDATA wstruct[2];			/* Array data Cary<->Dave which 
					 * replaces the globals defined
					 * for the same info. ( DAVE )
					 */


/*-----------------------------------------------------------------
 * Global Window Offsets and Form Width and Heights.
 * These are used to point to the actual values.
 *-----------------------------------------------------------------
 */
int  *XOFFSET;
int  *YOFFSET;
unsigned int  *FORM_WIDTH;
unsigned int  *FORM_HEIGHT;

int  Cur_Handle;			/* Current Handle - WORLD | LIBRARY */
GRECT Grid;				/* Grid Dialog Box Global ( DAVE )*/
GRECT Old_Lib;				/* Old Library Curr window grect  */

/*----------------------------------------------------------------------
 * Arrow function pointers used by the slider routines.
 *----------------------------------------------------------------------
 */
void (*arrow_funcs)( void );		/* These are used by the arrow      */
void (*slide_arrow)( void );		/* and slider routines for scrolling*/




/* FUNCTIONS
 * ================================================================
 */
 
/* wind_init()
 * ================================================================
 */
void
wind_init( void )
{
   int     i;
   WINFO   *x;
   int     flag;
   
   window[ WORLD ]   = &w; 
   window[ LIBRARY ] = &l;
   
   for( i = LIBRARY; i >= WORLD; i-- )
   {
      x = window[i];
      
      x->kind   = WKIND;
      x->id     = NO_WINDOW;
      x->wchar  = gl_wbox;
      x->hchar  = gl_hbox;    
      x->fulled = FALSE;

      if( ( x->id = Wind_create( x->kind, &desk )) < 0 )
      {
         x->id = NO_WINDOW;
         wind_exit();
         form_alert( 1, "[1][ No More Windows| Available. Problems...][ Sorry ]");
         return;    
      }        



      /* The world window will be 3/4 of the width of the screen
       * -------------------------------------------------------
       */
      if( i == WORLD )
      {
         strcpy( x->name, " ViewMaster " );
         strcpy( x->info, " " );
      }
      
      
      /* The Library window will be 1/4 of the width of the screen
       * -------------------------------------------------------
       */
      if( i == LIBRARY )
      {
         strcpy( x->name, " World Info " );
         strcpy( x->info, " " );
      }
      Wind_calc( 1, x->kind, &x->r, &x->work );
      
      if( i == LIBRARY )		/* Used for Full Box of Library window */
         Old_Lib = x->r;
         
      wind_set( x->id, WF_NAME, x->name );
      wind_set( x->id, WF_INFO, x->info );      
      Wind_open( x->id, &x->r );
   }
   
   /* We want the WORLD window to be on top */
   wind_set( window[ WORLD ]->id, WF_TOP );
 
   Update_World( WORLD );
   Update_World( LIBRARY );
      
   
   flag = DaveInit( Brush_Path );
   while( !flag || ( flag == -1 ) )
   {
       /* Brushes exist, but several errors occurred */
       if( flag == -1 )
       {
          if( form_alert( 1, "[1][ | | Brush File(s) Error!  | Write the Error File?  ][ OK | Cancel ]") == 1 )
          {  
            SaveErr();
          }
          flag = TRUE; /* forces it to exit */
       }
       
       
       if( !flag )
       {
          if( form_alert( 1,"[1][ |  No Brushes Found!   ][Try Again|Exit]") == 1 )
          {
            Set_Brush_Path();
            flag = DaveInit( Brush_Path );
          }
          else
          {
            Gem_Exit( -1 );
          }  
       }
   }
   vex_butv( vhandle, NEW_BUT, ( int (**)() )&BUT_ADDR );

   World_Check();
   
   SetDave_Stuff( LIBRARY );
   slider_chk();

   SetDave_Stuff( WORLD );
   slider_chk();
}
 



/* do_windows()
 * ================================================================
 */
void
do_windows( int *msg, int *event )
{
    int handle;
    
    if( ( handle = Check_ID( msg[3] )) == NO_WINDOW )
          return;

    SetDave_Stuff( handle );     
        
    switch( msg[0] )
    {
       case WM_REDRAW: do_redraw( handle, ( GRECT *)&msg[4] );
       		       break;

       case WM_NEWTOP:
       case WM_TOPPED: wind_set( W->id, WF_TOP );
       		       break;
       		       
       case WM_FULLED: Full_Window();
       		       break;
       		       
       case WM_ARROWED:Do_Arrows( msg[4] );
       		       break;

       case WM_HSLID:  HSlide_Window( msg[4] );
       		       break;

       case WM_VSLID:  VSlide_Window( msg[4] );
       		       break;

       case WM_SIZED:  Size_Window( ( GRECT *)&msg[4] );
       		       break;

       case WM_MOVED:  Move_Window( ( GRECT *)&msg[4] );
       		       break;
       default:  
       		break;
    }   

}





/* Full_Window()
 * ================================================================
 */
void
Full_Window( void )
{
   GRECT prev;
   GRECT full;
   GRECT curr;
 
   Wind_get( W->id, WF_CURRXYWH, ( WARGS *)&curr );
   Wind_get( W->id, WF_FULLXYWH, ( WARGS *)&full );


   /* The Library window will just toggle between the library world size
    * and the previous size. The WORLD window will size to FULL and
    * previous size.
    */  
   if( Cur_Handle == LIBRARY )
   {
      Wind_get( 0, WF_WORKXYWH, ( WARGS *)&full );
      
      wstruct[ LIBRARY ].xoffset = 0;
      wstruct[ LIBRARY ].yoffset = 0; 
      
      if(( wstruct[ LIBRARY ].w_wid  == W->work.g_w ) &&
         ( wstruct[ LIBRARY ].w_hite == W->work.g_h ) )
      { 
          W->r = Old_Lib; /* Go back to the old size window...*/
      }
      else
      {
          W->work.g_w = wstruct[ LIBRARY ].w_wid; 
          W->work.g_h = wstruct[ LIBRARY ].w_hite;
          Wind_calc( 0, W->kind, &W->work, &W->r );
      }
      W->r.g_x = max( W->r.g_x, full.g_x );
      W->r.g_y = max( W->r.g_y, full.g_y );
      W->r.g_w = min( W->r.g_w, full.g_w );
      W->r.g_h = min( W->r.g_h, full.g_h );
      Wind_set( W->id, WF_CURRXYWH, ( WARGS *)&W->r );    
      Wind_calc( 1, W->kind, &W->r, &W->work );
      Wind_set( W->id, WF_WORKXYWH, ( WARGS *)&W->work );
   }
   else
   {   /* WORLD WINDOW Full size box handling */
     if( rc_equal( &curr, &full ) )
     {
       Wind_get( W->id, WF_PREVXYWH, ( WARGS *)&prev );
       Graf_shrinkbox( &prev, &full );
       Wind_set( W->id, WF_CURRXYWH, ( WARGS *)&prev );
       W->fulled = FALSE;
     }
     else
     {
       Graf_growbox( &curr, &full );
       Wind_set( W->id, WF_CURRXYWH, ( WARGS *)&full );
       W->fulled = TRUE;
     }
     DisplayXY();
   }    		          


   Wind_get( W->id, WF_CURRXYWH, ( WARGS *)&W->r );
   Wind_get( W->id, WF_WORKXYWH, ( WARGS *)&W->work );
   Update_World( Cur_Handle );      			  
   slider_chk();
}




/* Do_Arrows()
 * ================================================================
 */
void
Do_Arrows( int action )
{
   MRETS m;

      arrow_funcs = nada;
      slide_arrow = sliderv;
      
      switch( action )
      {
	case WA_UPPAGE:  *YOFFSET = max( *YOFFSET - W->work.g_h, 0 );
			 sliderv();
			 if( Cur_Handle == WORLD );
			     DisplayXY();

			 do_redraw( Cur_Handle, &W->work );
			 break;
			     		    
	case WA_DNPAGE:  if( *FORM_HEIGHT > W->work.g_h )
			 {
			   *YOFFSET += W->work.g_h;
			   *YOFFSET  = min( *YOFFSET, *FORM_HEIGHT - W->work.g_h );
			   sliderv();
			   if( Cur_Handle == WORLD );
			      DisplayXY();
			   do_redraw( Cur_Handle, &W->work );
			 }
			 break;
			     		
	case WA_UPLINE:  if( ( *FORM_HEIGHT > W->work.g_h ) && *YOFFSET )
			 {
			    *YOFFSET = max( *YOFFSET - BSIZE, 0 );
			    arrow_funcs = wupline;
			 }  
			 break;
 			     		     
	case WA_DNLINE:  if( *FORM_HEIGHT > W->work.g_h )
			 {
			    if( *YOFFSET < ( *FORM_HEIGHT - W->work.g_h ) )
			    {
			      *YOFFSET += BSIZE;
			      *YOFFSET = min( *YOFFSET, *FORM_HEIGHT - W->work.g_h );    
			      arrow_funcs = wdnline;
			    }  
			 }
			 break;
			     		
	case WA_LFPAGE:  *XOFFSET = max( *XOFFSET - W->work.g_w, 0 );
			 sliderh();
			 if( Cur_Handle == WORLD );
			    DisplayXY();
			 do_redraw( Cur_Handle, &W->work );
			 break;
			                      
	case WA_RTPAGE:  if( *FORM_WIDTH > W->work.g_w )
			 {
			    *XOFFSET += W->work.g_w;
			    *XOFFSET = min( *XOFFSET, *FORM_WIDTH - W->work.g_w );
			    sliderh();
			    if( Cur_Handle == WORLD );
			      DisplayXY();
			    do_redraw( Cur_Handle, &W->work );
			 }
			 break;
			     		
	case WA_LFLINE:  if( *FORM_WIDTH > W->work.g_w )
			 {
			    *XOFFSET = max( *XOFFSET - BSIZE, 0 );
			    arrow_funcs = wlfline;
			    slide_arrow = sliderh;
			 }
			 break;
			     		
	case WA_RTLINE:  if( *FORM_WIDTH > W->work.g_w )
			 {
			   *XOFFSET += BSIZE;
			   *XOFFSET = min( *XOFFSET, *FORM_WIDTH - W->work.g_w );
			   arrow_funcs = wrtline;
			   slide_arrow = sliderh;
			 }    
			 break;
			     		
       	default:
       		break;
      }

      Graf_mkstate( &m );
      do
      {
         if( arrow_funcs != nada )
         {
           (*arrow_funcs)();
           (*slide_arrow)();
  	   if( Cur_Handle == WORLD );
               DisplayXY();
           do_redraw( Cur_Handle, &W->work );
	 }  
	 Graf_mkstate( &m );
      }while( m.buttons ); 
      Graf_mkstate( &m );
}






/* HSlide_Window()
 * ================================================================
 */
void
HSlide_Window( int position )
{ 
  if( *FORM_WIDTH > W->work.g_w )
  {
     *XOFFSET = scale( position, *FORM_WIDTH - W->work.g_w, 1000 );
     sliderh();
     if( Cur_Handle == WORLD );
        DisplayXY();
     do_redraw( Cur_Handle, &W->work );
  }  
}




/* VSlide_Window()
 * ================================================================
 */
void
VSlide_Window( int position )
{ 
  if( *FORM_HEIGHT > W->work.g_h )
  {
     *YOFFSET = scale( position, *FORM_HEIGHT - W->work.g_h, 1000 );
     sliderv();
     if( Cur_Handle == WORLD );
        DisplayXY();
     do_redraw( Cur_Handle, &W->work );
  }  
}



/* Size_Window()
 * ================================================================
 */
void
Size_Window( GRECT *rect )
{
   GRECT prev;
      
   W->r = *rect;
   Wind_get( W->id, WF_PREVXYWH, ( WARGS *)&prev );
   Wind_set( W->id, WF_CURRXYWH, ( WARGS *)&W->r );
   Wind_calc( 1, W->kind, &W->r, &W->work );
   Wind_set( W->id, WF_WORKXYWH, ( WARGS *)&W->work );
   Update_World( Cur_Handle );
   slider_chk();     

   if( ( prev.g_w > rect->g_w ) && ( prev.g_h >= rect->g_h ) ||
       ( prev.g_w >= rect->g_w ) && ( prev.g_h > rect->g_h ) )
       do_redraw( Cur_Handle, rect );
       
   if( Cur_Handle == LIBRARY ) /* Used for Full Box of Library Window */
       Old_Lib = W->r;
       
   if( Cur_Handle == WORLD );
      DisplayXY();
       
}       		       


/* Move_Window()
 * ================================================================
 */
void
Move_Window( GRECT *rect )
{
     W->r = *rect;
     Wind_set( W->id, WF_CURRXYWH, ( WARGS *)&W->r );
     Wind_calc( 1, W->kind, &W->r, &W->work );
     Wind_set( W->id, WF_WORKXYWH, ( WARGS *)&W->work );
     Update_World( Cur_Handle );

     if( Cur_Handle == LIBRARY )	/* Used for Full Box of Library Window */
     {
        Old_Lib.g_x = W->r.g_x;
        Old_Lib.g_y = W->r.g_y;
     }   
}




/* wind_exit();
 * ================================================================
 */
void
wind_exit( void )
{
   int i;
   
   for( i = WORLD; i<= LIBRARY; i++ )
   {
      if( window[i]->id != NO_WINDOW )
               wind_delete( window[i]->id );
      window[i]->id = NO_WINDOW;         
   }
}



/* DaveName()
 * ================================================================
 * Let's Dave pass in a string and change the window title string.
 */
void
DaveName( int id, char *name )
{
   WINFO *x;

   x = (( id == WORLD ) ? ( &w ) : ( &l ) );   
   strcpy( x->name, name ); 
   wind_set( x->id, WF_NAME, x->name );
}



/* DaveInfo()
 * ================================================================
 * Let's Dave pass in a string and change the window info string
 * IN: int id	WORLD or LIBRARY
 */
void
DaveInfo( int id, char *name )
{
   WINFO *x;

   x = (( id == WORLD ) ? ( &w ) : ( &l ) );   
   strcpy( x->info, name );
   wind_set( x->id, WF_INFO, x->info );
}



/******************************************************************
 * SLIDER CODE for sizing and positioning the vertical and
 * horizontal sliders of a window.
 ******************************************************************/


/* slider_chk()
 * ================================================================
 * Adjusts the width and height of the sliders.
 * Also, repositions the sliders based on XOFFSET and YOFFSET.
 */
void
slider_chk( void )
{
   wind_set( W->id, WF_VSLSIZE, scale( 1000, W->work.g_h, *FORM_HEIGHT ), 0, 0, 0 );   
   wind_set( W->id, WF_HSLSIZE, scale( 1000, W->work.g_w, *FORM_WIDTH ), 0, 0, 0 );
     
   sliderv();
   sliderh();
}


/* scale()
 * ================================================================
 * Scaling routine to preserve the fraction.
 */
int
scale( int visible, int factor, int total )
{
   long tmp;
   int  munits;
   long half;

   if( total == 0 )	/* just in case of divide by zero...       */
       return( 0 );	/* If this occurs, we have a bug somewhere */
          		/* Cause, the total shouldn't ever be zero */
          		
   half = ((long)total / 2L );
   
   tmp = (long)visible * (long)factor;
   munits = ((tmp % (long)total) > half );
   tmp /= (long)total;
   return( (int)tmp + munits );
}



/* sliderv()
 * ================================================================
 * 
 */
void
sliderv( void )
{
  if( *FORM_HEIGHT < W->work.g_h )	/* the form is smaller than the window*/
      *YOFFSET = 0;
  
  if( *FORM_HEIGHT > W->work.g_h )
      *YOFFSET = min( *YOFFSET, *FORM_HEIGHT - W->work.g_h );
      
  wind_set( W->id, WF_VSLIDE, scale( 1000, *YOFFSET, *FORM_HEIGHT - W->work.g_h ), 0, 0, 0 );
}


/* sliderh()
 * ================================================================
 */
void
sliderh( void )
{
  if( *FORM_WIDTH < W->work.g_w )
      *XOFFSET = 0;
      
  if( *FORM_WIDTH > W->work.g_w )
     *XOFFSET = min( *XOFFSET, *FORM_WIDTH - W->work.g_w );    
     
  wind_set( W->id, WF_HSLIDE, scale( 1000, *XOFFSET, *FORM_WIDTH - W->work.g_w ), 0, 0, 0 );
}


/* nada()
 * ================================================================
 */
void
nada( void )
{
}


/* wupline()
 * ================================================================
 */
void
wupline( void )
{
   *YOFFSET = max( *YOFFSET - BSIZE, 0 );
}


/* wdnline()
 * ================================================================
 */
void
wdnline( void )
{
   if( *FORM_HEIGHT > W->work.g_h )
   {
      *YOFFSET += BSIZE;
      *YOFFSET = min( *YOFFSET, *FORM_HEIGHT - W->work.g_h );    
   }
}



/* wrtline()
 * ================================================================
 */
void
wrtline( void )
{
 if( *FORM_WIDTH > W->work.g_w )
 {
    *XOFFSET += BSIZE;
    *XOFFSET = min( *XOFFSET, *FORM_WIDTH - W->work.g_w );
 }
}



/* wlfline()
 * ================================================================
 */
void
wlfline( void )
{
   *XOFFSET = max( *XOFFSET - BSIZE, 0 );
}



/* Check_ID()
 * ================================================================
 * Checks the window handle from the system.
 * Returns a oneof our window handles, or -1 ( NO WINDOW ) if
 * its not either one.
 */
int
Check_ID( int id )
{
   int handle = NO_WINDOW;
   
   if( id == window[ WORLD ]->id )
       handle = WORLD;
   
   if( id == window[ LIBRARY ]->id )
       handle = LIBRARY;
   return( handle );    
}



/* SetDave_Stuff()
 * ================================================================
 */
void
SetDave_Stuff( int handle )
{
   Cur_Handle  = handle;
   if( handle != NO_WINDOW )
   {
      W = window[ handle ];
      XOFFSET = &wstruct[ handle ].xoffset;
      YOFFSET = &wstruct[ handle ].yoffset;
      FORM_WIDTH  = &wstruct[ handle ].w_wid;
      FORM_HEIGHT = &wstruct[ handle ].w_hite;
   }
}



/* Set_Window_To_Lynx()
 * ================================================================
 */
void
Set_Window_To_Size( int width, int height  )
{
    GRECT full;
    
    Wind_get( 0, WF_WORKXYWH, ( WARGS *)&full );

    wstruct[ WORLD ].xoffset = 0;
    wstruct[ WORLD ].yoffset = 0; 
    w.work.g_w = width;		/* Let's get the work area setup. */
    w.work.g_h = height;

    Wind_calc( 0, w.kind, &w.work, &w.r );    /* then calc the actual window*/
    w.r.g_x = full.g_x;
    w.r.g_y = full.g_y;
    w.r.g_w = min( w.r.g_w, full.g_w );
    w.r.g_h = min( w.r.g_h, full.g_h );
    
    Wind_set( w.id, WF_CURRXYWH, ( WARGS *)&w.r );
    Wind_calc( 1, w.kind, &w.r, &w.work );
    Wind_set( w.id, WF_WORKXYWH, ( WARGS *)&w.work );
    SetDave_Stuff( WORLD );
    slider_chk();
    Update_World( WORLD );
    do_redraw( WORLD, &w.work );
}



/* update_world()
 * ================================================================
 */
void 
Update_World( int handle )
{
   wstruct[ handle ].w = window[ handle ]->work;
}




int
GetTopWindow( void )
{
   int handle;
   
   wind_get( 0, WF_TOP, &handle );
   
   if( handle == window[ WORLD ]->id )
       return( WORLD );
       
   if( handle == window[ LIBRARY ]->id )
       return( LIBRARY );
       
   return( NO_WINDOW );    
}



/* Allows the user to use the arrow keys to scroll the arrows
 * on a window.
 */
void
do_arrow_buttons( int key )
{
    SetDave_Stuff( GetTopWindow() );

    arrow_funcs = nada;
    slide_arrow = sliderv;

    switch( key )
    {
       case K_UP:     if( ( *FORM_HEIGHT > W->work.g_h ) && *YOFFSET )
		      { 
		         *YOFFSET = max( *YOFFSET - BSIZE, 0 );
		         arrow_funcs = wupline;
		      }      
		      break;

		      
       case K_DOWN:   if( *FORM_HEIGHT > W->work.g_h )
	              {
			if( *YOFFSET < ( *FORM_HEIGHT - W->work.g_h ) )
			{
			  *YOFFSET += BSIZE;
			  *YOFFSET = min( *YOFFSET, *FORM_HEIGHT - W->work.g_h );    
			  arrow_funcs = wdnline;
			}  
		      }
       		      break;
       		      
       case K_LEFT:   if( *FORM_WIDTH > W->work.g_w )
		      {
		         *XOFFSET = max( *XOFFSET - BSIZE, 0 );
		         arrow_funcs = wlfline;
		         slide_arrow = sliderh;
		      }
       		      break;
       		      
       case K_RIGHT:  if( *FORM_WIDTH > W->work.g_w )
		      {
		        *XOFFSET += BSIZE;
		        *XOFFSET = min( *XOFFSET, *FORM_WIDTH - W->work.g_w );
		        arrow_funcs = wrtline;
		        slide_arrow = sliderh;
		      }
       		      break;
    }
    
    if( arrow_funcs != nada )
    {
       (*arrow_funcs)();
       (*slide_arrow)();
       if( Cur_Handle == WORLD );
             DisplayXY();
       do_redraw( Cur_Handle, &W->work );
    }
    EatKeyboard();  
}
