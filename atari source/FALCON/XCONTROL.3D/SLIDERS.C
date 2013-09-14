/* FILE: 	SLIDERS.C
 *==========================================================================
 * DATE:        February 5, 1990
 *		January 13, 1993
 *
 * DESCRIPTION:                                   
 *
 * INCLUDE FILE: SLIDERS.H
 */
 
/* INCLUDE FILES
 *==========================================================================
 */ 
#include <sys\gemskel.h>
#include <stdlib.h>

#include "country.h"
#include "xcontrol.h"



/* PROTOTYPES
 *==========================================================================
 */
void cdecl sl_size( OBJECT *tree, int base, int slider, int num_items,
                    int visible, int direction, int min_size );

void cdecl sl_x( OBJECT *tree, int base, int slider, int value,
                 int num_min, int num_max, void (*foo)() );
           
void cdecl sl_y( OBJECT *tree, int base, int slider, int value,
                 int num_min, int num_max, void (*foo)() );

void cdecl sl_arrow( OBJECT *tree, int base, int slider, int obj,
                     int inc, int min, int max, int *numvar, int direction,
                     void (*foo)() );
               
void cdecl sl_dragx( OBJECT *tree, int base, int slider, int min,
               	     int max, int *numvar, void (*foo)() );
               
void cdecl sl_dragy( OBJECT *tree, int base, int slider, int min,
                     int max, int *numvar, void (*foo)() );
               
int  Calc_Value( int slidxy, int basexy, int basewh,
                 int obwh, int min, int max );

void	xselect( OBJECT *tree, int base, int obj );
void	xdeselect( OBJECT *tree, int base, int obj );

/* DEFINES
 *==========================================================================
 */
/* Slider Time Delay Definitions */
#define SL_MAX_DELAY 	0
#define SL_MIN_DELAY 	0
#define SL_INC 		0

/* Orientation of sliders */
#define VERTICAL	0
#define HORIZONTAL	1

#define NULLFUNC	( void(*)())0L



/* GLOBALS
 *==========================================================================
 */




/* sl_size()
 *==========================================================================
 * Size the slider
 *
 * IN:	   OBJECT *tree:	Object tree
 *	   int    base:		base of slider
 *	   int    slider:	slider object - it must be child of base
 *	   int    num_items:    Total number of items accounted for
 *	   int    visible:	Number of said items visible at one time
 *	   int    direction:    Horizontal or Vertical - See defines above
 *	   int	  min_size:	Minimum Pixel Size
 *
 * OUT:    void
 */ 
void
cdecl sl_size( OBJECT *tree, int base, int slider, int num_items,
               int visible, int direction, int min_size )
{
     int size = 1000;

     if( visible && num_items )
       size = min( 1000, (int)((1000L * (long)visible) / (long)num_items) );
                 
     if( direction == HORIZONTAL )
     {
         ObW( slider ) = (int)(( (long)size * (long)ObW( base )) / 1000L );
         ObW( slider ) = max( min_size, ObW( slider ) );
     }    
     else
     {
         ObH( slider ) = (int)(( (long)size * (long)ObH( base )) / 1000L );
         ObH( slider ) = max( min_size, ObH( slider ) );
     }    
}




/* sl_x()
 *==========================================================================
 * Modify slider in x position
 *
 * IN:   OBJECT *tree:		object tree
 *	 int    base:		base of slider
 *	 int    slider:	        slider object - must be child of base
 *	 int    txtobj:		txtobj for numbers. This does NOT have to
 *				be a child of the base. -1 if there is none.
 *	 int    value:		current value
 *	 int    num_min:	minimum item number
 *	 int    num_max:	maximum item number
 *	 void  (*foo)():	Drawing routine passed in by calling routine
 *
 * OUT:  void
 */
void
cdecl sl_x( OBJECT *tree, int base, int slider, int value,
	    int num_min, int num_max, void (*foo)( void ) )      
{
    if( value == num_max ) {
	ObX(slider) = ObW(base) - ObW(slider);
    } else {
	ObX(slider) =
	    (int)( ( (long)(value-num_min) *
	           ( (long)(ObW(base) - ObW(slider)) * 1000L )
	    	   ) /
	    	   ( (long)(num_max-num_min) * 1000L )
	    	   );
    }   
    if( foo != NULLFUNC )
	           (*foo)();         
}





/* sl_y()
 *==========================================================================
 * Modify slider in y position
 *
 * IN:   OBJECT *tree:		object tree
 *	 int    base:		base of slider
 *	 int    slider:	        slider object - must be child of base
 *	 int    txtobj:		txtobj for numbers. This does NOT have to
 *				be a child of the base. -1 if there is none.
 *	 int    value:		current value
 *	 int    num_min:	minimum item number
 *	 int    num_max:	maximum item number
 *	 void  (*foo)():	Drawing routine passed in by calling routine
 *
 * OUT:  void
 */
void
cdecl sl_y( OBJECT *tree, int base, int slider, int value,
	    int num_min, int num_max, void (*foo)( void ) )      
{
    if( value == num_min ) {
	ObY(slider) = ObH(base) - ObH(slider);
    } else {
	ObY(slider) = 
	    (int)( ( (long)(value-num_max) *
	           ( (long)(ObH(base) - ObH(slider)) * 1000L )
	    	   ) /
	    	   ( (long)(num_min - num_max) * 1000L )
	    	   );
    }   
    
    if( foo != NULLFUNC )
		(*foo)();          
}



/* sl_arrow()
 *==========================================================================
 * Handle both horizontal and vertical arrow buttons
 *
 * IN:   OBJECT *tree:		object tree
 *	 int base:		base of slider object
 *	 int slider:		slider object - this must be child of base
 *	 int obj:		Arrow object clicked on
 *	 int txtobj:		txt object for numbers. -1 if there is none.
 *				Does not have to be a child of base.
 *	 int inc:		increment by this amount
 *	 int min:		min item number
 *	 int max:		max item number
 *	 int *numvar:		current value
 *	 int direction:		Horizontal or vertical
 *	 void (*foo)():		Drawing routine passed in.
 *
 * OUT:  void
 */
void
cdecl sl_arrow( OBJECT *tree, int base, int slider, int obj,
                int inc, int min, int max, int *numvar,
                int direction, void (*foo)() )
{
    MRETS mk;
    int   newvalue, oldvalue;
    GRECT slidrect;
    MRETS m;
    GRECT newrect;
    
    slidrect = ObRect( slider );
    objc_offset( tree, slider, &slidrect.g_x, &slidrect.g_y );

    /* account for outlines */
    slidrect.g_x -= 3;
    slidrect.g_y -= 3;
    slidrect.g_w += 6;
    slidrect.g_h += 6;

    if( obj > 0 )
    {
/* select( tree, obj );*/
/*	xselect( tree, ROOT, obj );*/
	xselect( tree, obj, obj );
    }	

    oldvalue = *numvar;
    do {
	newvalue = *numvar + inc;

	if( max > min )
	{
	    if( newvalue < min ) newvalue = min;
	    else if( newvalue > max ) newvalue = max;
	}
	else
	{
	    if( newvalue > min ) newvalue = min;
	    else if( newvalue < max ) newvalue = max;
	}

	/* if in bounds, change the slider thumb */
	if( newvalue != oldvalue ) {
	    oldvalue = newvalue;
	    *numvar = newvalue;
	    if( direction == HORIZONTAL )
	      sl_x( tree, base, slider, newvalue, min, max, foo );
	    else
	      sl_y( tree, base, slider, newvalue, min, max, foo );

	    /* undraw old */
	    Objc_draw( tree, base, 3 , &slidrect );

	    /* draw new */
	    objc_offset( tree, slider, &slidrect.g_x, &slidrect.g_y );
	    slidrect.g_x -= 3;
	    slidrect.g_y -= 3;
	    Objc_draw( tree, base, 3 , &slidrect );
        }
	Graf_mkstate( &mk );
    } while( mk.buttons != 0 );

    if( obj > 0 )
/*	xdeselect( tree, ROOT, obj );*/
	xdeselect( tree, obj, obj );
    Objc_draw( tree, base, MAX_DEPTH, &slidrect );
    Evnt_button( 1, 1, 0, &m );
}





/* sl_dragx()
 *==========================================================================
 * Handle dragging the slider horizontally
 *
 * IN:  OBJECT *tree:		object tree
 *	int    base:		base of slider
 *	int    slider:		slider object - this must be child of base
 *      int    txtobj:		Text object - -1 if not in use.
 *	int    min:		minimum item number
 *      int    max:		maximum item number
 *      int    *numvar:		Current value
 *	void   (*foo)()		Drawing function passed in.
 *
 * OUT: void
 */
void
cdecl sl_dragx( OBJECT *tree, int base, int slider, int min,
	        int max, int *numvar, void (*foo)() )
{
    int newvalue, xoffset, slidx, lastvalue;
    MRETS mk;
    GRECT baserect, slidrect;
    GRECT newrect;
    	
    /* get slider extent */
    baserect = ObRect( base );
    objc_offset( tree, base, &baserect.g_x, &baserect.g_y );

    /* get slide box extent */
    slidrect = ObRect( slider );
    objc_offset( tree, slider, &slidrect.g_x, &slidrect.g_y );

    /* find mouse offset into slide box */
    Graf_mkstate( &mk );
    xoffset = mk.x - (slidrect.g_x + (slidrect.g_w / 2));

    /* adjust box w/h for clip */
    slidrect.g_x -= 3;
    slidrect.g_y -= 3;
    slidrect.g_w += 6;
    slidrect.g_h += 6;

    lastvalue = min-1;
    while( mk.buttons )
    {
       /* get current slide box X coordinate */
       slidx = mk.x - xoffset;
       /* translate it to a value */
       if( slidx < baserect.g_x + ObW(slider)/2 )
          newvalue = min;
       else if( slidx > baserect.g_x + baserect.g_w - ObW(slider)/2 )
          newvalue = max;
       else{
	     newvalue = Calc_Value( slidx, baserect.g_x,
	     			    baserect.g_w, ObW( slider ),
	     			    min, max );
	   }
       if( newvalue != lastvalue )
       {
          lastvalue = newvalue;
          /* update the value, and draw the slidebox */
	  *numvar = newvalue;
          sl_x( tree, base, slider, newvalue, min, max, foo );
          
          /* undraw old */
          Objc_draw( tree, base, 2, &slidrect );

          /* draw new */
          objc_offset( tree, slider, &slidrect.g_x, &slidrect.g_y );
          slidrect.g_x -= 3;
          slidrect.g_y -= 3;
	  Objc_draw( tree, base , MAX_DEPTH, &slidrect );
	}
	Graf_mkstate( &mk );
    }
}






/* sl_dragy()
 *==========================================================================
 * Handle dragging the slider vertically
 */
void
cdecl sl_dragy( OBJECT *tree, int base, int slider, int min,
                int max, int *numvar, void (*foo)() )
{
    int newvalue, yoffset, slidy, lastvalue;
    MRETS mk;
    GRECT baserect, slidrect;
    GRECT newrect;
    
   /* get slider extent */
    baserect = ObRect( base );
    objc_offset( tree, base, &baserect.g_x, &baserect.g_y );

    /* get slide box extent */
    slidrect = ObRect( slider );
    objc_offset( tree, slider, &slidrect.g_x, &slidrect.g_y );

    /* find mouse offset into slide box */
    Graf_mkstate( &mk );
    yoffset = mk.y - (slidrect.g_y + (slidrect.g_h / 2));

    /* adjust box w/h for clip */
    slidrect.g_x -= 3;
    slidrect.g_y -= 3;
    slidrect.g_w += 6;
    slidrect.g_h += 6;

    lastvalue = min-1;
    while( mk.buttons )
    {
       /* get current slide box Y coordinate */
       slidy = mk.y - yoffset;
       /* translate it to a value */
       if( slidy < baserect.g_y + ObH(slider)/2 )
          newvalue = max;
       else if( slidy > baserect.g_y + baserect.g_h - ObH(slider)/2 )
          newvalue = min;
       else{
		newvalue = Calc_Value( slidy, baserect.g_y,
				       baserect.g_h, ObH( slider ),
				       max, min );	     
	   }
       if( newvalue != lastvalue )
       {
          lastvalue = newvalue;
          /* update the value, and draw the slidebox */
          *numvar = newvalue;
          sl_y( tree, base, slider, newvalue, min, max, foo );

          /* undraw old */
          Objc_draw( tree, base, 2, &slidrect );

          /* draw new */
          objc_offset( tree, slider, &slidrect.g_x, &slidrect.g_y );
          slidrect.g_x -= 3;
          slidrect.g_y -= 3;
	  Objc_draw( tree, base , MAX_DEPTH, &slidrect );
	}
	Graf_mkstate( &mk );
    }
}




/* Calc_Value()
 *==========================================================================
 *Calculate a new value for sl_dragx() and sl_dragy()
 *  IN: int    slidxy:      sldx or sldy
 *      int    basexy:	    baserect.g_x or baserect.g_y
 *	int    basewh:	    baserect.g_w or baserect.g_h
 *	int    obwh:	    ObH() or (ObW)
 */
int
Calc_Value( int slidxy, int basexy, int basewh,
            int obwh, int min, int max )
{
   long top = 0L;
   int  digit = 0;
   long bottom = 0L;
   
   top      = (long)((long)(max - min) * 1000L *
                     (long)(slidxy - basexy - ( obwh / 2 ) ) );
	                
   bottom   = (long)(basewh - obwh ) * 1000L;
   if( top && bottom )
   {
     digit    = (int)((long)(top % bottom) > (long)(bottom / 2L));
     top     /= bottom;
   }  
   return( min + (int)top + digit );
}




/* Hot_Slide()
 *==========================================================================
 * Used EXCLUSIVELY by the HOT SCrolling routines in MOVER.C
 * This routine was needed because the existing routines couldn't
 * handle it.
 *
 * IN:	OBJECT *tree:		The object tree
 *	int base:		The base of the slider
 *	int slider:		The slider object.
 *	int obj:		The object clicked on ( -1 if none )
 *	int inc:		increment (+/- # )
 *	int min:		minimum value
 *	int max:		maximum value
 *	int *numvar:		current value
 *	int direction:		VERTICAL | HORIZONTAL
 *	GRECT *rect:		Rectangle for our hot spot. If we exit the
 *				rectangle, we exit this routine also.
 *	void (*foo)():		The custom slider draw routine.
 */
void
Hot_Slide( OBJECT *tree, int base, int slider, int obj,
           int inc, int min, int max, int *numvar,
           int direction, GRECT *rect, void (*foo)() )
{
    MRETS mk;
    int   newvalue, oldvalue;
    GRECT slidrect;
    GRECT newrect;
    
    slidrect = ObRect( slider );
    objc_offset( tree, slider, &slidrect.g_x, &slidrect.g_y );
	/* account for outlines */
    slidrect.g_x -= 3;
    slidrect.g_y -= 3;
    slidrect.g_w += 6;
    slidrect.g_h += 6;

    if( obj > 0 )
	select( tree, obj );

    oldvalue = *numvar;
    do {
	newvalue = *numvar + inc;

	if( max > min )
	{
	    if( newvalue < min ) newvalue = min;
	    else if( newvalue > max ) newvalue = max;
	}
	else
	{
	    if( newvalue > min ) newvalue = min;
	    else if( newvalue < max ) newvalue = max;
	}

	/* if in bounds, change the slider thumb */
	if( newvalue != oldvalue ) {
	    oldvalue = newvalue;
	    *numvar = newvalue;
	    if( direction == HORIZONTAL )
	      sl_x( tree, base, slider, newvalue, min, max, foo );
	    else
	      sl_y( tree, base, slider, newvalue, min, max, foo );
	
	    /* undraw old */
	    Objc_draw( tree, base, 3 , &slidrect );

	    /* draw new */
	    objc_offset( tree, slider, &slidrect.g_x, &slidrect.g_y );
	    slidrect.g_x -= 3;
	    slidrect.g_y -= 3;
	    Objc_draw( tree, base, 3 , &slidrect );
        }
	Graf_mkstate( &mk );
    } while( ( mk.buttons != 0 ) && ( xy_inrect( mk.x, mk.y, rect )));

    if( obj > 0 )
	deselect( tree, obj );
    Objc_draw( tree, base, MAX_DEPTH, &slidrect );
}


