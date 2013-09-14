/* TTBLIT.C
 *==========================================================================
 * DATE:	March 21, 1990
 * DESCRIPTION: TT and Blitter Routines
 *
 * 07/29/92  cjg - No Blitter and Cache Controls for Sparrow
 *		 - Yes  on the Speaker tho...
 */
 
 
 /* INCLUDE FILES
 *==========================================================================
 */ 
#include <sys\gemskel.h>
#include <tos.h>

#include "country.h"

#include "general.h"
#include "cache.h"
#include "gen2.h"

#include "text.h"



/* DEFINES
 *==========================================================================
 */
#define NO_SPEED	0
#define BLITTER		1
#define TTCACHE		2
#define BLITCACHE	3


#define SPEED_OFF	0
#define BLIT_OFF	0
#define CACHE_OFF	0
#define BLIT_ON		1
#define CACHE_ON	2
#define BLITCACHE_ON	3



/* PROTOTYPES
 *==========================================================================
 */
 
void	Init_Speed( void );
void	Set_Speed( void );
void	Get_Speed( void );
void	Do_Speed( void );
void	Speed_Update( void );

int	Check_Blitter( void );
void	Set_Blitter( void );
void	Get_Blitter( void );
BOOLEAN	IsBlitter( void );

int	Check_TT_Cache( void );
long	Set_TTCache( void );
long	Get_TTCache( void );
BOOLEAN	IsTTCache( void );

void	Get_Pop_BlitCache( int flag );
int	Set_Pop_BlitCache( void );

int	IsSparrow( void );

/* EXTERNALS
 *==========================================================================
 */


/* GLOBALS 
 *==========================================================================
 */
int speed_flag = 0;			/* 0 - no blitter/ no ttcache
					 * 1 - blitter/ no ttcache
					 * 2 - no blitter/ ttcache
					 * 3 - Blitter / 030 cache
					 */

/* FUNCTIONS
 *==========================================================================
 */


/*--------------------------------------------------------------------------
 * Blitter and TT Cache Routines
 *--------------------------------------------------------------------------
 */


/* Init_Speed() 
 *==========================================================================
 * Initialize Speed_Flag -     0 -  No Blitter / No TT Cache
 *			       1 -  Blitter    / No TT Cache
 *			       2 -  No Blitter / TT Cache
 * Called to Initialize flag for the presence of Blitter or TT Cache
 * Note: We can't have both.
 * cur_value.BlitTTCache   ==    0 - Off
 *			         1 - On
 */
 void
 Init_Speed( void )
 {
    speed_flag = NO_SPEED;

    if( !IsSparrow() )
       speed_flag = ( Check_Blitter() | Check_TT_Cache() );
 }
 
 


 
/* Set_Speed()
 *==========================================================================
 * Set the Blitter or 030 cache
 */ 
void
Set_Speed( void )
{
  Set_Blitter();
  Supexec( Set_TTCache );
}





/* Get_Speed()
 *==========================================================================
 * Get the current status of the Blitter or TT Cache
 */
void
Get_Speed( void )
{
  Get_Blitter();
  Supexec( Get_TTCache );
}




void
Do_Speed( void )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ GENERAL ];
   char **txtptr;
   int  items;
   int  length;
   int  flag;
   int  temp;
   
   if( speed_flag == BLITCACHE )
   {
      items  = 4;
      length = 17;
      txtptr = chip2_text;
   }
   else
   {
      items  = 2;
      length = 8;
      txtptr = chip1_text;
   }

   temp = Set_Pop_BlitCache();
   flag = Pop_Handle( BLK1BUTT, txtptr, items, &temp, IBM, length );
   if( flag != -1 )
   {
      Get_Pop_BlitCache( flag );
      Set_Blitter();
      Supexec( Set_TTCache );
   }
   if( speed_flag == BLITCACHE )
     TedText( BLK1BUTT ) = chip_button[ cur_value.BlitCache ];
   else
   {
     if( IsTTCache() )
          TedText( BLK1BUTT ) = chip1_text[ (( cur_value.BlitCache & TTCACHE )?(FALSE):(TRUE)) ];
          
     if( IsBlitter() )
          TedText( BLK1BUTT ) = chip1_text[ (( cur_value.BlitCache & BLITTER )?(FALSE):(TRUE)) ];
   }        
   Objc_draw( tree, BLK1BUTT, 0, NULL );
}



int
Set_Pop_BlitCache( void )
{
   int state = NO_SPEED;
   
   Get_Speed();
   if( speed_flag == BLITCACHE )
       state = cur_value.BlitCache;
   else
   {
       if( IsBlitter() )
            state = !( cur_value.BlitCache & BLITTER );

       if( IsTTCache() )
       	    state = !( cur_value.BlitCache & TTCACHE );
   }
   return( state );   
}



void
Get_Pop_BlitCache( int flag )
{
    if( speed_flag == BLITCACHE )
         cur_value.BlitCache = flag;
    else
    {
	if( IsBlitter() )
	{
	   /* Preserve Cache field */
	   cur_value.BlitCache &= TTCACHE;
	   cur_value.BlitCache |= (( flag ) ? ( NO_SPEED ) : ( BLITTER ) );
	}
	
	if( IsTTCache() )
	{
	   /* Preserve Blitter field */
	   cur_value.BlitCache &= BLITTER;
	   cur_value.BlitCache |= (( flag ) ? ( NO_SPEED ) : ( TTCACHE ) );
	}
    }
}






void
Speed_Update( void )
{
  OBJECT *tree = ( OBJECT *)rs_trindex[ GENERAL ];
  
  HideObj( BLK1 );
  if( speed_flag )
  {
      ShowObj( BLK1 );
      TedText( BLK1TXT ) = Chip_Title[ speed_flag ];
  
      if( speed_flag == BLITCACHE )
         TedText( BLK1BUTT ) = chip_button[ cur_value.BlitCache ];
      else
      {
         if( IsTTCache() )
             TedText( BLK1BUTT ) = chip1_text[ (( cur_value.BlitCache & TTCACHE )?(FALSE):(TRUE)) ];
         
         if( IsBlitter() )
             TedText( BLK1BUTT ) = chip1_text[ (( cur_value.BlitCache & BLITTER )?(FALSE):(TRUE)) ];
      }         
  }
}





/* Check_Blitter()
 *==========================================================================
 * Check for the Presence of a blitter
 * IN: NONE
 * OUT: Return BLITTER if detected, else NO_SPEED otherwise
 */ 
 int
 Check_Blitter( void )
 {
    long flag;
   
   flag = xbios( 0x40, -1 ); 
   if( flag & 0x02L )
       return( BLITTER );
   else
       return( NO_SPEED );
 }
 


/* Set_Blitter()
 *==========================================================================
 * Check to see if a blitter exists
 * Slam the current state of the blitter variable into the blitter
 */
void
Set_Blitter( void )
{
   BOOLEAN flag;
   
   if( IsBlitter() )
   {
      flag = ( cur_value.BlitCache & BLIT_ON );
      xbios( 0x40, flag );
   }
}




/* Get_Blitter()
 *==========================================================================
 * Get the current status of the blitter and store it in
 * cur_value.blitter
 */
void
Get_Blitter( void )
{
    long flag;
    int  state;
    
    if( IsBlitter() )
    {
        flag = xbios( 0x40, -1 );
        state = ( ( flag & 0x01L ) ? ( BLIT_ON ) : ( BLIT_OFF ) );
        /* Preserve TTCACHE bit */
        cur_value.BlitCache &= TTCACHE;
        cur_value.BlitCache |= state;
    }    
}



/* IsBlitter()
 *==========================================================================
 * Return the status of the blitter based on speed_flag
 * OUT: TRUE  - Blitter Exists
 *      FALSE - Blitter does not exist
 */
BOOLEAN
IsBlitter( void )
{
   return( speed_flag & BLITTER );
}




/*--------------------------------------------------------------------------
 * TT Cache Routines
 *--------------------------------------------------------------------------
 */

 
 /* Check_TT_Cache()
  *=========================================================================
  * Check for the Presence of TT Cache( Actually, just an 030 
  * IN: none
  * OUT: Return NO_SPEED of Non Detected or
  *      TTCACHE if its there
  */
 int
 Check_TT_Cache( void )
 {
   long     p_value;
   
   if( (*xcpb->getcookie)( 0x5f435055L, &p_value ) )
   {
      if( p_value == 30 )		
               return( TTCACHE );
   }
   return( NO_SPEED );
 }
 
 

/* Set_TTCache()
 *==========================================================================
 * Check if we're on a 68030 (cache exists if so) and then
 * slam the cache on or off depending upon the current value 
 * of:             cur_value.ttcache
 * NOTE: call this routine using Supexec()
 */
long
Set_TTCache( void )
{
    if( IsTTCache() )
    {
       if( cur_value.BlitCache & CACHE_ON )
             cacheon();
       else
             cacheoff();
    }
    return( 0L );
}



/* Get_TTCache()
 *==========================================================================
 * Inquire the cache, if one exists, and check whether its on or off
 * Store the on/off status in cur_value.ttcache
 * NOTE: Call this routine using Supexec()
 */
long
Get_TTCache( void )
{
   long cachevalue;
   int  state;
   
   if( IsTTCache() )
   {
        cachevalue = cacheinq();
        state = (( cachevalue == 0x3111L ) ? ( CACHE_ON ) : ( CACHE_OFF ) );
        /* Preserve Blitter Status */
        cur_value.BlitCache &= BLITTER;
        cur_value.BlitCache |= state;
   }
   return( 0L );      
}




/* IsTTCache()
 *==========================================================================
 * Check if speed_flag is set to at least TTCACHE
 * RETURN TRUE  or FALSE
 */
BOOLEAN
IsTTCache( void )
{
   return( speed_flag & TTCACHE );
}


void
Speed_Redraw( void )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ GENERAL ];
   int old_value = cur_value.BlitCache;
   
   Get_Speed();
   Speed_Update();

   if( old_value != cur_value.BlitCache )
   	do_redraw( tree, BLK1BUTT );
}



int
IsSparrow( void )
{
   long     p_value;
   
   if( (*xcpb->getcookie)( 0x5f4d4348L, &p_value ) )
   {
      p_value = p_value >> 16;
      if( p_value == 3L )		/* SPARROW 0x00030000L */
            return( TRUE );
   }
   return( FALSE );
}