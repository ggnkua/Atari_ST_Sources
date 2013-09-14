/* FILE: STATUS.C
 * ======================================================================
 * DATE:  January 29, 1991
 *        May      6, 1992
 *	  October 27, 1992
 *
 * DESCRIPTION: Calculate the usage of FSM data cache.
 *
 * INCLUDE FILE: STATUS.H
 *
 * FSM DATA CACHE USAGE:
 *
 *	FSM----------------------
 *
 *      NAME		AMOUNT (bytes)         USAGE
 *      -----------------------------------------------------
 *      fsmheader	80			1 per font
 *	fontp_actual	180			1 per workstation
 *	width_table	458			1 per font per pointsize.
 *						( if width_tables are on)
 *	ptsblk		 6			1 per font per pointsize.
 *	arb/ptsblk	28			1 to 8 members per font
 *
 *      ------------------------------------------------------
 *
 *  The TOTAL available FSM data cache area is:
 *
 *  extern XFSM Current.SpeedoCacheSize;
 *  extern XFSM Current.speedo_percent;
 *
 *  Size of Misc Data Cache =
 *  ( Current.SpeedoCacheSize * ( 100 - ( Current.speedo_percent * 10 )) )/100;
 *
 */


/* INCLUDE FILES
 * ======================================================================
 */
#include <sys\gemskel.h>
 
#include "country.h"
#include "fonthead.h"
#include "fsmio.h"
#include "fonts.h"
#include "mainstuf.h"
#include "text.h"
#include "cache.h"
#include "front.h"



/* PROTOTYPES
 * ======================================================================
 */
void	CacheCheck( void );
long	GetCurUsage( void );
void	CachePrompt( void );



/* DEFINES
 * ======================================================================
 */
/* FSM FONTS */
#define	FSMHEADER	 80L
#define FONTP_ACTUAL	 180L
#define WIDTH_TABLE_DATA 458L
#define	THE_PTSBLK	  6L
#define	ARB_PTSBLK	 28L


/* EXTERN
 * ======================================================================
 */


/* GLOBALS
 * ======================================================================
 */
long	CacheDataSize;		/* FSM Data Cache Size */
long	CacheUsedSize;		/* FSM Data Cache Size calculated used*/


/* FUNCTIONS
 * ======================================================================
 */


/* GetCurUsage()
 * ======================================================================
 * Get the current Speedo Data Cache Usage.
 */
long
GetCurUsage( void )
{
    FON_PTR  curptr;
    int      i;
    long     Used;
    int      icount;

    /* Get the Fixed amount - always have this...*/
    Used = FONTP_ACTUAL;
    
    /* Get the per font allocation */
    icount = CountFonts( installed_list, SPD_FONT );
    
    Used +=  (long)icount * ( FSMHEADER + ARB_PTSBLK );
    
    /* Get the per pointsize per font allocation. */
    curptr = installed_list;
    while( curptr )
    {
       if( FTYPE( curptr ) == SPD_FONT )
       {
         for( i=0; i < MAX_POINTS; i++ )
         {
           if( POINTS( curptr )[i] )
           {
              if( Current.Width )
                 Used += WIDTH_TABLE_DATA;
              Used += THE_PTSBLK;
           }
           else
            break;
         }
       }         
       curptr = FNEXT( curptr );
    }
    
    Used += ( GetFontMin() + GetCharMin() );
    
    /* Make sure we ALWAYS have at least 10K */
    if( Used < 10240L )
      Used = 10240L;	

    Used /= 1024L;
    return( Used );
}



/* CacheCheck()
 * ======================================================================
 * Checks the CacheUsedSize vs the CacheDataSize.
 * Note: This is a check against the CPX setting. NOT the
 * actual setting. This checks the Miscellaneous size against
 * the used amount.
 */
void
CacheCheck( void )
{
   long extra;
   long interim;

   interim = (100L - ( (long)Current.speedo_percent * 10L )) * Current.SpeedoCacheSize;
   extra = ( interim % 100L ) > 50L;
   CacheDataSize = ( interim / 100L ) + extra;

   
   CacheUsedSize = GetCurUsage();

   if( ( CacheUsedSize ) > CacheDataSize )
      form_alert( 1, alert21 );   /* Put out a warning...*/
}


/* CachePrompt()
 * ======================================================================
 * Used only by the write_extend.sys routine. This is so that if
 * we have used more cache than we should've, we'll warn them.
 * return: TRUE - Don't write the extend.sys
 *	   FALSE- Write the extend.sys
 */
void
CachePrompt( void )
{
   long extra;
   long interim;

   interim = (100L - ( (long)Current.speedo_percent * 10L )) * Current.SpeedoCacheSize;
   extra = ( interim % 100L ) > 50L;
   CacheDataSize = ( interim / 100L ) + extra;
   
   CacheUsedSize = GetCurUsage();

   if( ( CacheUsedSize ) > CacheDataSize )
      form_alert( 1, alert22 );   /* Put out a warning...*/
}
