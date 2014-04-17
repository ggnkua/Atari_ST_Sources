/* ML_SLIDE.C
 * ================================================================
 * DESCRIPTION: These are the Drop Down List Slider Routines
 *
 * 01/08/93  cjg   - Created
 * 05/14/93  cjg   - Linked in with AES
 * 05/18/93  cjg   - Copy ListData[] to ListObjects[] since
 *		     ListData would appear in the DATA section
 *		     of the ROM and can't be modified.
 * 		   - If Ob_Find fails, check the up,down and base
 *		     rectangles ( with 3D ) to see if we have
 *		     fallen in between the 'cracks' of a 3D object.
 * 05/19/93  cjg   - Clear 'cu_button' upon exit from ml_arrow()
 *		     and ml_dragy() in order to compensate for
 *		     cu_button and gl_button not being the same
 *		     button state. NOTE: It's a KLUDGE!
 * 05/20/93  cjg   - Set the colors of the UP, DOWN, SLIDER stuff
 *		     to be the same as the vertical window parts.
 *		     For a description of the wtcolor[] index values,
 *		     see windlib.h for W_UPARROW, W_DNARROW, W_VSLIDE
 *		     and W_VELEV.
 * 05/28/93  cjg   - Don't use ob_actxywh() for the extents in
 *		     ml_arrow() and ml_dragy() because we want the
 *		     GRECT of the obj which doesn't include effects.
 * 06/10/93  cjg   - Added to SliderButtons() the ability to
 *		     handle UP, DOWN, SHIFT-Up and SHIFT-Down.
 */

/* INCLUDE FILES
 * ================================================================
 */
#include "pgem.h"
#include "pmisc.h"

#include "machine.h"


/* EXTERNS
 * ================================================================
 */
EXTERN WORD	gl_wchar;
EXTERN WORD	gl_hchar;
EXTERN WORD	gl_hbox;
EXTERN GRECT    gl_rscreen;
EXTERN WORD	gl_width;
EXTERN WORD	gl_height;
EXTERN GRECT	gl_rfull;
EXTERN WORD	gl_wbox;
EXTERN WORD	gl_button;
EXTERN WORD	gl_yrat;

EXTERN WORD	MAX_LIST_HEIGHT;
EXTERN MENU_PTR DListPtr;
EXTERN WORD	cu_button;	/* kludge */
EXTERN WORD	wtcolor[];

EXTERN WORD	gl_nplanes;


/* DEFINES
 * ================================================================
 */
#define LISTTREE     0  	/* TREE */
#define LISTUP       1  	/* OBJECT in TREE #0 */
#define LISTBASE     2  	/* OBJECT in TREE #0 */
#define LSLIDER      3  	/* OBJECT in TREE #0 */
#define LISTDOWN     4  	/* OBJECT in TREE #0 */
#define ADJSHADPIX   SHADOW

#define xabs( value )	(( value < 0 ) ? ( value * -1 ) : ( value ))

#ifndef NULLFUNC
   #define NULLFUNC	( void(*)())0L
#endif


#define K_UP	0x4800
#define KS_UP	0x4838
#define K_DOWN	0x5000
#define KS_DOWN 0x5032


/* PROTOTYPES
 * ================================================================
 */
VOID	Get3DClip( OBJECT *tree, WORD obj, GRECT *rect );


/* GLOBALS
 * ================================================================
 */
/* UP, DOWN, BASE and SLIDER OBJECTS */
OBJECT ListData[] =    {
			 -1, 1, 4, G_IBOX, NONE, NORMAL , (void*)0x1100L, 0,0, 17,9,
			 2, -1, -1, G_BOXCHAR, TOUCHEXIT | IS3DOBJ | IS3DACT, SHADOWED , (void*)0x1FF1100L, 6,1, 2,1,
			 4, 3, 3, G_BOX, TOUCHEXIT | IS3DOBJ | IS3DACT, SHADOWED | SELECTED, (void*)0xFF1111L, 6,2, 2,4,
			 2, -1, -1, G_BOX, TOUCHEXIT | IS3DOBJ | IS3DACT, NORMAL, (void*)0xFF1100L, 0,2, 2,1,
			 0, -1, -1, G_BOXCHAR, 0x60 | IS3DOBJ | IS3DACT, SHADOWED, (void*)0x2FF1100L, 6,6, 2,1
		       };
OBJECT	  ListObjects[5];
OBJECT    *ad_list;		  /* Tree for Slider Objects		   */
WORD	  Old_Offset;		  /* Old LIST OFFSET ( Used for Scrolling )*/
GRECT	  DUpRect;		  /* GRECT of UP Arrow with 3D 		   */
GRECT	  DDownRect;		  /* GRECT of Down Arrow with 3D	   */
GRECT     DBaseRect;		  /* GRECT of BASE with 3D		   */
GRECT	  DSlideRect;		  /* GRECT of SLIDER Area with 3D	   */



/* FUNCTIONS
 * ================================================================
 */


/* InitListSliders()
 * ================================================================
 * Initialize the Sliders for the Drop Down Menu List
 */
void
InitListSliders( MenuPtr )
MENU_PTR MenuPtr;
{
    OBJECT *tree;
    WORD    xpos;
    WORD    maximum;
    WORD    i;
    WORD    Obj3DHeight;
    WORD    Obj3DWidth;

    /* Copy the Slider Objects over, because, if we used
     * this in a ROM, the ListData[] would be in the DATA 
     * section and we can't modify stuff in the  DATA section.
     */
    for( i = ROOT; i <= LISTDOWN; i++ )
       ListObjects[i] = ListData[i];

    ad_list = ( OBJECT *)&ListObjects[ ROOT ];
    ActiveTree( ad_list );

    ObX( ROOT ) = ObY( ROOT ) = 0;
    ObW( ROOT ) = gl_width;
    ObH( ROOT ) = gl_height;

    xpos = MXPOS( MenuPtr ) + MWIDTH( MenuPtr ) + 1 + ADJ3DPIX;
    Obj3DHeight = gl_hbox + ( ADJ3DPIX << 1 );
    Obj3DWidth  = gl_wbox + ( ADJ3DPIX << 1 );
    

    /* UP ARROW */
    ObX( LISTUP ) = xpos;
    ObY( LISTUP ) = MYPOS( MenuPtr ) + ADJ3DPIX;
    ObW( LISTUP ) = gl_wbox - ADJSHADPIX;
    ObH( LISTUP ) = gl_hbox;
    Get3DClip( ad_list, LISTUP, &DUpRect );
    ObSpec( LISTUP ) &= 0xFFFF0000L;
    ObSpec( LISTUP ) |= ( (LONG)wtcolor[10] & 0x0000FFFFL );

    /* DOWN ARROW */
    ObX( LISTDOWN ) = xpos;
    ObY( LISTDOWN ) = MYPOS( MenuPtr ) + MHEIGHT( MenuPtr ) - Obj3DHeight + ADJ3DPIX;
    ObW( LISTDOWN ) = gl_wbox - ADJSHADPIX;
    ObH( LISTDOWN ) = gl_hbox;
    Get3DClip( ad_list, LISTDOWN, &DDownRect );
    ObSpec( LISTDOWN ) &= 0xFFFF0000L;
    ObSpec( LISTDOWN ) |= ( (LONG)wtcolor[11] & 0x0000FFFFL );

    /* BASE */
    ObX( LISTBASE ) = xpos;
    ObY( LISTBASE ) = MYPOS( MenuPtr ) + Obj3DHeight + ADJ3DPIX + ADJSHADPIX;
    ObW( LISTBASE ) = gl_wbox - ADJSHADPIX;
    ObH( LISTBASE ) = (ObY( LISTDOWN ) - ( ADJ3DPIX << 1 ) ) - ObY( LISTBASE ) - ADJSHADPIX;
    Get3DClip( ad_list, LISTBASE, &DBaseRect );
    ObSpec( LISTBASE ) &= 0xFFFF0000L;
    ObSpec( LISTBASE ) |= ( (LONG)wtcolor[12] & 0x0000FFFFL );

    /* SLIDER */
    ObX( LSLIDER ) = 0;
    ObY( LSLIDER ) = 0;
    ObW( LSLIDER ) = gl_wbox - ADJSHADPIX;
    ObH( LSLIDER ) = gl_hbox;
    ObSpec( LSLIDER ) &= 0xFFFF0000L;
    ObSpec( LSLIDER ) |= ((LONG)wtcolor[13] & 0x0000FFFFL );

    /* Initialize the size of the slider */
    ml_size( ad_list, LISTBASE, LSLIDER, MNUM_ITEMS( MenuPtr ),
	     MAX_LIST_HEIGHT, gl_hchar );

    /* Position the slider */
    maximum = max( MFIRST_CHILD( MenuPtr ) + MNUM_ITEMS( MenuPtr ) -
		   MAX_LIST_HEIGHT, MFIRST_CHILD( MenuPtr ) );

    ml_y( ad_list, LISTBASE, LSLIDER,
	  min( MSTART_OBJ( MenuPtr ), maximum  ),
	  maximum, MFIRST_CHILD( MenuPtr ), NULLFUNC );

    
}


/* ml_size()
 *==========================================================================
 * Size the slider
 *
 * IN:	   OBJECT *tree:	Object tree
 *	   WORD    base:	base of slider
 *	   WORD    slider:	slider object - it must be child of base
 *	   WORD    num_items:   Total number of items accounted for
 *	   WORD    visible:	Number of said items visible at one time
 *	   WORD	   min_size:	Minimum Pixel Size
 *
 * OUT:    void
 */ 
void
ml_size( tree, base, slider, num_items, visible, min_size )
OBJECT *tree;
WORD    base;
WORD    slider;
WORD    num_items;
WORD    visible;
WORD    min_size;
{
     WORD size = 1000;

     if( visible && num_items )
       size = min( 1000, (WORD)((1000L * (LONG)visible) / (LONG)num_items) );
                 
     ObH( slider ) = (WORD)(( (LONG )size * (LONG)ObH( base )) / 1000L );
     ObH( slider ) = max( min_size, ObH( slider ) );
}



/* ml_y()
 *==========================================================================
 * Modify slider in y position
 *
 * IN:   OBJECT *tree:		object tree
 *	 WORD    base:		base of slider
 *	 WORD    slider:	slider object - must be child of base
 *	 WORD    txtobj:	txtobj for numbers. This does NOT have to
 *				be a child of the base. -1 if there is none.
 *	 WORD    value:		current value
 *	 WORD    num_min:	minimum item number
 *	 WORD    num_max:	maximum item number
 *	 void    (*foo)():	Drawing routine passed in by calling routine
 *
 * OUT:  void
 */
void
ml_y( OBJECT *tree, WORD base, WORD slider, WORD value,
      WORD num_min, WORD num_max, void (*foo)( void ) )
{
    if( value == num_min )
    {
	ObY(slider) = ObH(base) - ObH(slider);
    }
    else
    {
	ObY(slider) = 
	    (WORD)( ( (LONG)(value-num_max) *
	           ( (LONG)(ObH(base) - ObH(slider)) * 1000L )
	    	   ) /
	    	   ( (LONG)(num_min - num_max) * 1000L )
	    	   );
    }   

    if( foo != NULLFUNC )
		(*foo)();          
}


/* ml_arrow()
 *==========================================================================
 * Handle vertical arrow buttons
 *
 * IN:   OBJECT *tree:		object tree
 *	 WORD base:		base of slider object
 *	 WORD slider:		slider object - this must be child of base
 *	 WORD obj:		Arrow object clicked on
 *	 WORD txtobj:		txt object for numbers. -1 if there is none.
 *				Does not have to be a child of base.
 *	 WORD inc:		increment by this amount
 *	 WORD min:		min item number
 *	 WORD max:		max item number
 *	 WORD *numvar:		current value
 *	 void (*foo)():		Drawing routine passed in.
 *
 * OUT:  void
 */
void
ml_arrow( OBJECT *tree, WORD base, WORD slider, WORD obj,
	  WORD inc, WORD num_min, WORD num_max,
	  WORD *numvar, void (*foo)() )
{
    WORD  newvalue, oldvalue;
    GRECT slidrect;
    WORD  parent;

    slidrect = ObRect( slider );
    ob_offset( ( LONG )tree, slider, &slidrect.g_x, &slidrect.g_y );

    /* account for outlines */
    slidrect.g_x -= 3;
    slidrect.g_y -= 3;
    slidrect.g_w += 6;
    slidrect.g_h += 6;

    if( obj > 0 )
        FXSelect( tree, obj );

    oldvalue = *numvar;
    do
    {
	newvalue = *numvar + inc;

	if( num_max > num_min )
	{
	    if( newvalue < num_min ) newvalue = num_min;
	    else if( newvalue > num_max ) newvalue = num_max;
	}
	else
	{
	    if( newvalue > num_min ) newvalue = num_min;
	    else if( newvalue < num_max ) newvalue = num_max;
	}

	/* if in bounds, change the slider thumb */
	if( newvalue != oldvalue )
        {
	    oldvalue = newvalue;
	    *numvar = newvalue;
	    ml_y( tree, base, slider, newvalue, num_min, num_max, foo );

	    /* undraw old */
	    if( ( slidrect.g_y + slidrect.g_h ) >= ( ad_list[ LISTDOWN ].ob_y - ADJ3DPIX ))
	       parent = ROOT;
	    else
	       parent = base;
	    ObjcDraw( tree, parent, &slidrect );

  	    /* draw new */
	    ob_offset( ( LONG )tree, slider, &slidrect.g_x, &slidrect.g_y );
	    slidrect.g_x -= 3;
	    slidrect.g_y -= 3;

	    /* SPECIAL CASE - Check if the DOWN ARROW button IS exceeded.
	     * Need to redraw from the root to get a clean redraw
	     */
	    if( ( slidrect.g_y + slidrect.g_h ) >= ( ad_list[ LISTDOWN ].ob_y - ADJ3DPIX ))
	      parent = ROOT;
	    else
	      parent = base;
   	    ObjcDraw( tree, parent, &slidrect );
        }
    }while( gl_button & 0x01 );
    cu_button = 0;	/* KLUDGE */

    if( obj > 0 )
        FXDeselect( tree, obj );
}





/* ml_dragy()
 *==========================================================================
 * Handle dragging the slider vertically
 */
void
ml_dragy( OBJECT *tree, WORD base, WORD slider, WORD num_min,
          WORD num_max, WORD *numvar, void (*foo)() )
{
    WORD  newvalue, yoffset, slidy, lastvalue;
    GRECT baserect, slidrect;
    WORD  parent;

   /* get slider extent */
    baserect = ObRect( base );
    ob_offset( ( LONG )tree, base, &baserect.g_x, &baserect.g_y );

    /* get slide box extent */
    slidrect = ObRect( slider );
    ob_offset( ( LONG )tree, slider, &slidrect.g_x, &slidrect.g_y );

    /* find mouse offset into slide box */
    yoffset = gl_yrat - (slidrect.g_y + ( slidrect.g_h >> 1 ));

    /* adjust box w/h for clip */
    slidrect.g_x -= 3;
    slidrect.g_y -= 3;
    slidrect.g_w += 6;
    slidrect.g_h += 6;

    lastvalue = num_min-1;
    do
    {
       /* get current slide box Y coordinate */
       slidy = gl_yrat - yoffset;

       /* translate it to a value */
       if( slidy < ( baserect.g_y + ( ObH( slider ) >> 1 ) ) )
       { 
          newvalue = num_max;
       }
       else
       {
	 if( slidy > ( baserect.g_y + baserect.g_h - ( ObH( slider ) >> 1 ) ) )
            newvalue = num_min;
         else
	 {
	    newvalue = ML_CalcValue( slidy, baserect.g_y, baserect.g_h,
				     ObH( slider ), num_max, num_min );	     
	 }
       }


       if( newvalue != lastvalue )
       {
          lastvalue = newvalue;

          /* update the value, and draw the slidebox */
          *numvar = newvalue;

          ml_y( tree, base, slider, newvalue, num_min, num_max, foo );

          /* undraw old */
	  if( ( slidrect.g_y + slidrect.g_h ) >= ( ad_list[ LISTDOWN ].ob_y - ADJ3DPIX ) )
	    parent = ROOT;
	  else
	    parent = base;
	  ObjcDraw( tree, parent, &slidrect );

          ob_offset( ( LONG )tree, slider, &slidrect.g_x, &slidrect.g_y );
          slidrect.g_x -= 3;
          slidrect.g_y -= 3;

          /* draw new */
	  if( ( slidrect.g_y + slidrect.g_h ) >= ( ad_list[ LISTDOWN ].ob_y - ADJ3DPIX ) )
	    parent = ROOT;
	  else
	    parent = base;

	  ObjcDraw( tree, parent, &slidrect );
	}

    }while( gl_button & 0x01  );
    cu_button = 0;	/* KLUDGE */
   
}





/* Calc_Value()
 *==========================================================================
 *Calculate a new value for sl_dragx() and sl_dragy()
 *  IN: WORD    slidxy:      sldx or sldy
 *      WORD    basexy:	    baserect.g_x or baserect.g_y
 *	WORD    basewh:	    baserect.g_w or baserect.g_h
 *	WORD    obwh:	    ObH() or (ObW)
 */
WORD
ML_CalcValue( WORD slidxy, WORD basexy, WORD basewh,
              WORD obwh, WORD num_min, WORD num_max )
{
   LONG top;
   WORD digit;
   LONG bottom;

   digit = 0;
   top = bottom = 0L;
   
   top      = (LONG)((LONG)( num_max - num_min) * 1000L *
                     (LONG)(slidxy - basexy - ( obwh / 2 ) ) );
	                
   bottom   = (LONG)(basewh - obwh ) * 1000L;
   if( top && bottom )
   {
     digit    = (WORD)((LONG)(top % bottom) > (LONG)( bottom / 2L ));
     top     /= bottom;
   }  
   return( num_min + (WORD)top + digit );
}





/* SliderCheck()
 * ================================================================
 * Check if the user is clicking on the Sliders
 *
 * IN: WORD mk.x	X position of the mouse when the click occurred
 *     WORD mk.y	Y position of the mouse.
 *
 * OUT: obj num -  - This is an active UP or DOWN , SLIDER, or BASE
 *      -1 - Nope - this isn't an UP or DOWN arrow
 *
 * To qualify, the top menu item must be an Up arrow or
 *             the bottom menu item must be a Down arrow.
 */
WORD
SliderCheck( mx, my )
WORD  mx;
WORD  my;
{
   WORD	    obj;

   obj = ob_xfind( ( LONG )ad_list, LISTTREE, MAX_DEPTH, mx, my );

   if( obj <= NIL )
   {
     do{
     }while( gl_button & 0x01 );
     cu_button = 0;			/* Kludge */
     return( NIL );
   }

   /* Kludge to check if the mouse has clicked between or within
    * a 3D fringe area.
    */
   if( obj == LISTTREE )
   { 
      if( inside( mx, my, &DUpRect ) )
        return( LISTUP);

      if( inside( mx, my, &DDownRect ) )
        return( LISTDOWN );


      /* Get REctangle for the Slider to check against. */
      Get3DClip( ad_list, LSLIDER, &DSlideRect );

      if( inside( mx, my, &DSlideRect ) )
        return( LSLIDER );

      if( inside( mx, my, &DBaseRect ) )
        return( LISTBASE );

      do{
      }while( gl_button & 0x01 );
      cu_button = 0;			/* Kludge */
      return( NIL );
   }

   if( ( obj == LISTUP ) || ( obj == LISTDOWN ) ||
       ( obj == LISTBASE ) || ( obj == LSLIDER )
     )
     return( obj );
   else
     return( NIL );
}



/* SliderScroll()
 * ================================================================
 * Scroll the menu when the user is clicking on either the
 * up or down arrows.
 *
 * GLOBAL: DListPtr -> POINTER TO THE MENU STRUCTURE
 *	   It is SET in Menu_Popup() for Drop Down Lists ONLY
 */
VOID
SliderScroll( VOID )
{
    /* Adjust the menu to compensate for the scrolling */
    DListAdjust( DListPtr, MOFFSET( DListPtr ) ); 
   
    ScrollBlit( DListPtr, Old_Offset, MOFFSET( DListPtr ) );

    Old_Offset = MOFFSET( DListPtr );   
}




/* SliderButtons()
 * ================================================================
 * SLIDER button handling ( Drop Down Lists )
 */
VOID
SliderButtons( button )
WORD button;
{
    WORD  ox,oy;

    switch( button )
    {
       case KS_UP:     ml_arrow( ad_list, LISTBASE, LSLIDER, -1, -MAX_LIST_HEIGHT,
           	  	        max( MFIRST_CHILD( DListPtr ) +
				MNUM_ITEMS( DListPtr ) - MAX_LIST_HEIGHT,
			        MFIRST_CHILD( DListPtr )),
			        MFIRST_CHILD( DListPtr ),
	            	        &MOFFSET( DListPtr ), SliderScroll );
		      break;

       case KS_DOWN:   ml_arrow( ad_list, LISTBASE, LSLIDER, -1, MAX_LIST_HEIGHT,
           	                max( MFIRST_CHILD( DListPtr) +
			 	MNUM_ITEMS( DListPtr ) - MAX_LIST_HEIGHT,
			        MFIRST_CHILD( DListPtr ) ),
			        MFIRST_CHILD( DListPtr ),
           	                &MOFFSET( DListPtr ), SliderScroll );
		      break;


       case K_UP:     button = -1;
       case LISTUP:   ml_arrow( ad_list, LISTBASE, LSLIDER, button, -1,
           	  	        max( MFIRST_CHILD( DListPtr ) +
				MNUM_ITEMS( DListPtr ) - MAX_LIST_HEIGHT,
			        MFIRST_CHILD( DListPtr )),
			        MFIRST_CHILD( DListPtr ),
	            	        &MOFFSET( DListPtr ), SliderScroll );
		      break;
	
       case K_DOWN:   button = -1;	  
       case LISTDOWN: ml_arrow( ad_list, LISTBASE, LSLIDER, button, 1,
           	                max( MFIRST_CHILD( DListPtr) +
			 	MNUM_ITEMS( DListPtr ) - MAX_LIST_HEIGHT,
			        MFIRST_CHILD( DListPtr ) ),
			        MFIRST_CHILD( DListPtr ),
           	                &MOFFSET( DListPtr ), SliderScroll );
		      break;

       case LISTBASE: ob_offset( ( LONG )ad_list, LSLIDER, &ox, &oy );
                      ox = (( gl_yrat < oy ) ? ( -MAX_LIST_HEIGHT ) : ( MAX_LIST_HEIGHT ) );

		      ml_arrow( ad_list, LISTBASE, LSLIDER, -1, ox,
           	                max( MFIRST_CHILD( DListPtr ) +  
				MNUM_ITEMS( DListPtr ) - MAX_LIST_HEIGHT,
				MFIRST_CHILD( DListPtr ) ),
			        MFIRST_CHILD( DListPtr ),
           	                &MOFFSET( DListPtr ), SliderScroll );
		      break;

        case LSLIDER: FXSelect( ad_list, LSLIDER );

		      oy = gl_yrat;
		      do{
		      }while(( gl_button & 0x01 ) && ( gl_yrat == oy ));
		
		      if(( gl_button & 0x01 ) && ( gl_yrat != oy ) )	
	   	      {
              		ml_dragy( ad_list, LISTBASE, LSLIDER,
           	        	  max( MFIRST_CHILD( DListPtr ) + 
				  MNUM_ITEMS( DListPtr ) - MAX_LIST_HEIGHT,
				  MFIRST_CHILD( DListPtr ) ),
				  MFIRST_CHILD( DListPtr ),
           	    		  &MOFFSET( DListPtr ), SliderScroll );
           	      }

	              FXDeselect( ad_list, LSLIDER );
		      break;

	default:
		      break;
    }

}


/* ScrollBlit()
 *==========================================================================
 * Perform the blitting when the List is scrolling.
 *     WORD old_offset:	The previous offset
 *     WORD new_offset:	The current offset to work on.
 */
void
ScrollBlit( MenuPtr, old_offset, new_offset )
MENU_PTR MenuPtr;
WORD old_offset;
WORD new_offset;
{
    GRECT srcbase;
    GRECT dstbase;
    GRECT clip;
    GRECT rect;
    WORD  pxy[16];
    GRECT clip2;
                
    WORD   offset;
    LONG   location = 0L;
    WORD   dummy;
    WORD   obj;
    WORD   base;
    OBJECT *tree;

    ActiveTree( MTREE( MenuPtr ) );

    obj  = MTOP_OBJ( MenuPtr );
    base = MPARENT( MenuPtr );


    clip = ObRect( base );		/* We WANT Width and Height of Base */
    ob_offset( ( LONG )tree, obj, &clip.g_x, &clip.g_y ); /* and xy of obj  */

    clip2 = srcbase = dstbase = rect = clip;  
    offset = new_offset - old_offset;

    if( !offset )			/* went nowhere fast...*/
    	   return;

    rc_intersect( &gl_rfull, &clip2 );
    if(  ( xabs( offset )  <  MAX_LIST_HEIGHT ) &&
    	 rc_equal( ( WORD *)&clip2, ( WORD *)&clip ) 
      )
    {
       rect.g_h    = ( xabs( offset ) * ObH( obj ) );
       dstbase.g_h = srcbase.g_h = ( MAX_LIST_HEIGHT - xabs( offset ) ) * ObH( obj );
       if( offset > 0 )
       {
          ob_offset( ( LONG )tree, obj + xabs( MAX_LIST_HEIGHT - offset ),
                       &dummy, &rect.g_y );
	  ob_offset( ( LONG )tree, obj + xabs( offset ), &dummy, &srcbase.g_y );
       }
       else
	  ob_offset( ( LONG )tree, obj + xabs( offset ), &dummy, &dstbase.g_y );

       rc_intersect( &gl_rfull, &srcbase );
       rc_intersect( &gl_rfull, &dstbase );
       
       rc_2xy( &srcbase, ( WORD *) &pxy[0] );
       rc_2xy( &dstbase, ( WORD *)&pxy[4] );
       
       gsx_sclip( &clip );

       gsx_moff();
       vro_cpyfm( 3, pxy, ( WORD *)&location,( WORD *)&location );
       gsx_mon();
    }
    else
    {
       gsx_sclip( &clip );
    }
    ObjcDraw( tree, base, &rect );
    gsx_sclip( &gl_rscreen );
}





/* Get3DClip
 *==========================================================================
 * Gets the objects clip area - taking into account a 3D area offset.
 * and their SHADOW.
 */
VOID
Get3DClip( OBJECT *tree, WORD obj, GRECT *rect )
{
    rect->g_w = ObW( obj );
    rect->g_h = ObH( obj );

    ob_offset( ( LONG )tree, obj, &rect->g_x, &rect->g_y );

    rect->g_x -= ( ADJ3DPIX + 1 );	/* Offset of 1 for X position also...*/
    rect->g_y -= ADJ3DPIX;
    rect->g_w += ( ( ADJ3DPIX << 1 ) + ADJSHADPIX + 2 );
    rect->g_h += ( ( ADJ3DPIX << 1 ) + ADJSHADPIX );
}



