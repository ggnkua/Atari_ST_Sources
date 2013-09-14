/* FILE:  FSMCACHE.C
 * ====================================================================
 * DATE:  October 18, 1990	cjg
 *	  July     9, 1991	cjg	
 *	  July    12, 1991      cjg
 *
 * DESCRIPTION: Handle Sizing of the Caches.
 *		1) FSM Character Cache
 *		2) FSM Miscellaneous Cache
 *		3) Bitmap Font Cache
 *
 * The cache size in the extend.sys is the 'cache size','Percent'
 * Therefore, if the number was 204800,5 - the character cache
 * would be 100 and the miscellaneous cache would be 100.
 *
 * So, the FSM Character Cache + FSM Miscellaneous Cache equals
 * the FSM Cache Size. The Percent # is from 1-9 and is the percent
 * that the Miscellaneous Cache is of the Character Cache.
 *
 * NOTE: CSIZE variables are really MSIZE variables and vice-versa.
 *       The Character Cache is what is calculated.
 *       The Miscellaneous Cache is the main number.
 *       So, we'll just switch the display. CUP, CDOWN, CSIZE
 *					    MUP, MDOWN, MSIZE
 *
 * INCLUDE FILE: FSMCACHE.H
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


extern XCPB *xcpb;		/* XControl Parameter Block   */

struct foobar {
	WORD	dummy;
	WORD	*image;
	};

/* PROTOTYPES
 * ====================================================================
 */
void Do_Cache_Size( void );
int  FSM_Cache_Button( int button, WORD *msg );
long limits( long num, long min_num, long max_num );
void obj_outline( OBJECT *xtree, int obj );
void MUpDown( int obj, int UpButton, char *text, long *num, int NBase );


/* DEFINES
 * ====================================================================
 */
#define FSM_DIV_MIN	1	/* 10% FSM CACHE/BITMAP */
#define FSM_DIV_MAX	9	/* 90% FSM CACHE/BITMAP */


/* GLOBALS
 * ====================================================================
 */
long Old_BitCache; 
long old_fsmcache;

long old_ccache;
long old_mcache;
long ccache;
long mcache;

int  Cur_FDiv;		/* Current fsm_div */			
int  Old_FDiv;		/* Old Fsm_div     */
char FDiv_Text[7];	/* Text to hold the Miscellaneous size */

MFORM   Other;
BOOLEAN Internal_Flag = FALSE; /* INternal flag for Change_Flag */


/* FUNCTIONS
 * ====================================================================
 */


/* Do_FSM_Cache_Size()
 * ====================================================================
 * Set the FSM Character Cache, FSM Miscellaneous Cache and
 * Bitmap Font Cache.
 */
void
Do_Cache_Size( void )
{
   PrevTree = Oxtree;
   Reset_Tree( FsmTree );       		                

   Internal_Flag = FALSE;
   
   /* Set the FSM Character Cache */   
   old_fsmcache = Current.FSMCacheSize;
   ccache = Current.FSMCacheSize / 10L;
   ccache = ccache * ( 10L - (long)Current.fsm_percent );
   ccache = limits( ccache, MIN_CACHE_SIZE, MAX_CACHE_SIZE );	   
   old_ccache = ccache;
   sprintf( FSM_Cache_Text,"%5ld", ccache );
   TedText( MSIZE ) = FSM_Cache_Text;

   /* Display a size based on a percentage of the FSM CACHE Size */
   Old_FDiv  = Cur_FDiv = Current.fsm_percent;
   mcache    = Current.FSMCacheSize / 10L;
   mcache   *= Current.fsm_percent;
   mcache    = limits( mcache, MIN_CACHE_SIZE, MAX_CACHE_SIZE );	   
   old_mcache = mcache;
   
   sprintf( FDiv_Text, "%5ld", mcache );
   TedText( CSIZE ) = FDiv_Text;


   /* Set the Bitmap Font Cache */
   Current.BITCacheSize = limits( Current.BITCacheSize, 0L, MAX_CACHE_SIZE );	   
   Old_BitCache = Current.BITCacheSize;
   sprintf( Bit_Cache_Text,"%5ld", Current.BITCacheSize );
   TedText( BSIZE ) = Bit_Cache_Text;

   Objc_draw( tree, ROOT, MAX_DEPTH, NULL );   		  
}


/* FSM_Cache_Button()
 * ====================================================================
 */
int
FSM_Cache_Button( int button, WORD *msg )
{
  int   quit = FALSE;
  int   extra;
  long  half;
         
  if( ( button != -1 ) && ( button & 0x8000 ) )
     button &= 0x7FFF;      

  switch( button )
  {
     case FSMCAN:   Deselect( FSMCAN );
		    Current.FSMCacheSize = old_fsmcache;
		    Current.fsm_percent  = Old_FDiv;
		    Current.BITCacheSize = Old_BitCache;
		    Internal_Flag = FALSE;
		    					    
     case FSMOK:    if( button == FSMOK )
     		    {
     		       Deselect( FSMOK );
		       /* FSM Character Stuff */		       
		       ccache = atol( FSM_Cache_Text );
		       if( !ccache )
		       	   ccache = old_ccache;
		       ccache = limits( ccache, MIN_CACHE_SIZE, MAX_CACHE_SIZE );	   
		       
		       /* FSM Miscellaneous Stuff */
		       mcache = atol( FDiv_Text );
		       if( !mcache )
		       	   mcache = old_mcache;
		       mcache = limits( mcache, MIN_CACHE_SIZE, MAX_CACHE_SIZE );	   

		       Current.FSMCacheSize = ccache + mcache;

		       half     =  Current.FSMCacheSize / 2L;
		       extra    =  ((( mcache * 10L ) % Current.FSMCacheSize) > half );
		       Cur_FDiv =  (int)(( mcache * 10L ) / Current.FSMCacheSize);
		       Current.fsm_percent = Cur_FDiv + extra;
		       Current.fsm_percent = (int)limits( (int)Current.fsm_percent, 1L, 9L );	   

		       if(( Current.fsm_percent != Old_FDiv ) ||
		          ( Current.FSMCacheSize != old_fsmcache ) )  		       
		    	    Internal_Flag = TRUE;

		       /* Bitmap Font Cache Stuff */
		       Current.BITCacheSize = atol( Bit_Cache_Text );
		       Current.BITCacheSize = limits( Current.BITCacheSize, 0L, MAX_CACHE_SIZE );	   
		       
        	       if( Current.BITCacheSize != Old_BitCache )
		           Internal_Flag = TRUE;

 	               CacheCheck( 0 );
     		    }
		    sprintf( FSM_Cache_Text,"%5ld", Current.FSMCacheSize );
		    sprintf( Bit_Cache_Text,"%5ld", Current.BITCacheSize );
		    
		    Reset_Tree( Oxtree );     
		    Objc_draw( tree, ROOT, MAX_DEPTH, NULL );   		  
                    Change_Flag |= Internal_Flag;
     		    break;

     case MUP:
     case MDOWN:    Up_Down_Arrow( button, MUP, &FSM_Cache_Text[0], &ccache, MSIZE );
		    Internal_Flag = TRUE;
     		    break;

     case BUP:
     case BDOWN:    Up_Down_Arrow( button, BUP, &Bit_Cache_Text[0], &Current.BITCacheSize, BSIZE );
		    Internal_Flag = TRUE;
		    break;

     case CUP:
     case CDOWN:    Up_Down_Arrow( button, CUP, &FDiv_Text[0], &mcache, CSIZE );
		    Internal_Flag = TRUE;
		    break;
		         		         		       
     default:	if( button == -1 )
     		{
     		   switch( msg[0] )
     		   {
     		     case WM_REDRAW: 
     		     		     break;
     			     	
     		     /* Don't care about canceling or oking the values
     		      * here, because, the cpx is gone gone gone otherwise
     		      */		     		     
     		     case AC_CLOSE:  quit = TRUE;
     		     		     break;
     				     		     
     		     case WM_CLOSED: quit = TRUE;
     		     		     /* FSM Character Cache Stuff */
				     ccache = atol( FSM_Cache_Text );
				     if( !ccache )
		       	   		  ccache = old_ccache;
				     ccache = limits( ccache, MIN_CACHE_SIZE, MAX_CACHE_SIZE );	   

		       		     /* FSM Miscellaneous Stuff */
				     mcache = atol( FDiv_Text );
		       		     if( !mcache )
		       	   		  mcache = old_mcache;
		                     mcache = limits( mcache, MIN_CACHE_SIZE, MAX_CACHE_SIZE );	   
				     Current.FSMCacheSize = ccache + mcache;

				     half     =  Current.FSMCacheSize / 2L;
				     extra    =  ((( mcache * 10L ) % Current.FSMCacheSize) > half );
		       		     Cur_FDiv =  (int)(( mcache * 10L ) / Current.FSMCacheSize);
		       		     Current.fsm_percent = Cur_FDiv + extra;
				     Current.fsm_percent = (int)limits( (int)Current.fsm_percent, 1L, 9L );	   
				     
				     if(( Current.fsm_percent != Old_FDiv ) ||
				        ( Current.FSMCacheSize != old_fsmcache ) )  		       
					Internal_Flag = TRUE;

				     /* Bitmap Font Cache Stuff */
				     Current.BITCacheSize = atol( Bit_Cache_Text );
				     Current.BITCacheSize = limits( Current.BITCacheSize, 0L, MAX_CACHE_SIZE );	   
		       	   	     if( Current.BITCacheSize != Old_BitCache )
		       	   	     		Internal_Flag = TRUE;
					
     		     		     Change_Flag |= Internal_Flag;
				     do_write_extend( FALSE );
				     break;

		     case CT_KEY:    CacheCheck( 0 );
		     
		     		     /* FSM Character Cache Stuff */
		     		     obj_outline( tree, CSIZE );
		     		     
				     /* FSM Miscellaneous Cache Stuff */
		     		     obj_outline( tree, MSIZE );

				     /* Bitmap Font Cache Stuff */
				     obj_outline( tree, BSIZE );
		     		     break;
     		     default:
     		     		break;
     		   }
     		}
     		break;
  }
  
  return( quit );
}
 




/* limits()
 * ====================================================================
 */
long
limits( long num, long min_num, long max_num )
{
    if( num > max_num )
    	    num = max_num;
    	
    if( num < min_num )
            num = min_num;
    return( num );    
}


/* obj_outline()
 * ====================================================================
 */
void
obj_outline( OBJECT *xtree, int obj )
{
   GRECT rect;
   
   rect = ObRect( obj );
   objc_offset( xtree, obj, &rect.g_x, &rect.g_y );
   rect.g_h += 6;
   rect.g_y -= 3;
   rect.g_w += 2;
   Objc_draw( xtree, ROOT, MAX_DEPTH, &rect );
}

