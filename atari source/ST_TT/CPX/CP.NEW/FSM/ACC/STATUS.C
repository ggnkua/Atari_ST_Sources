/* FILE: STATUS.C
 * ======================================================================
 * DATE:  January 29, 1991
 *	  July    12, 1991
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
 *      fsmheader	64			1 per font
 *	fontp_actual	114			1 per workstation
 *	width_table	458			1 per font per pointsize.
 *						( if width_tables are on)
 *	ptsblk		28			1 per font per pointsize.
 *	arb/ptsblk	28			1 to 8 members per font
 *
 *	character
 *	generation	84 * ( width - height )
 *			This is the width and height of a character in 
 *			pixels. 91dpi for screen, 300 for printer.
 *			Checked when adding a new pointsize for a font.
 *
 *      ------------------------------------------------------
 *
 *	BITMAP----------------------
 *
 *      NAME		AMOUNT (bytes)         USAGE
 *      -----------------------------------------------------
 *	fonts		#fonts * 11bytes       #fonts
 *	drivers		#drivers*36bytes       #drivers
 *
 *	bitmap cache
 *	struct...	12		       1 per font
 *
 *	bitmap font
 *	header...	108		       1 per font
 *
 *	offset table	448		       1 per font
 *
 *  FIXED
 *
 *      NAME		AMOUNT (bytes)         USAGE
 *      -----------------------------------------------------
 *
 *	client		16382		       once
 *	Hebrew fontp	134		       once
 *	Symbol fontp	134		       once
 *
 *  The TOTAL available FSM data cache area is:
 *
 *  extern XFSM Current.FSMCacheSize;
 *  extern XFSM Current.fsm_percent;
 *
 *  Size of Data Cache =
 *  ( Current.FSMCacheSize * ( 100 - ( Current.fsm_percent * 10 )) )/100;
 *
 */


/* INCLUDE FILES
 * ======================================================================
 */
#include "fsmhead.h"
#include "country.h"

#include "fsm.h"
#include "fsmio.h"

#include "mainstuf.h"
#include "text.h"


#include "outline.h"
#include "ptbind.h"

#include "cacheopt.h"
#include "fsmacc.h"


/* PROTOTYPES
 * ======================================================================
 */
void	CacheCheck( int pointsize );
long	GetCurUsage( void );
long	CalcPointUsage( int pointsize );
void	CachePrompt( void );



/* DEFINES
 * ======================================================================
 */
/* FSM FONTS */
#define	FSMHEADER	 64L
#define FONTP_ACTUAL	 114L
#define WIDTH_TABLE_DATA 458L
#define	THE_PTSBLK	 28L
#define	ARB_PTSBLK	 28L

#define CHARSIZE	 (long)(( 84 * ( width + height ) ))

/* BITMAP FONTS */
#define BFONT		11L
#define BDRIVER		36L
#define BFONTSTRUCT	568L	/* 12 + 108 + 448 */
	

/* FIXED...*/
#define XCLIENT		16382L
#define XHEBREW		134L
#define XSYMBOL		134L


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
 * Get the current FSM Data Cache Usage.
 */
long
GetCurUsage( void )
{
    FON_PTR  curptr;
    int      i;
    long     Used;
       
    /* Get the Fixed amount - always have this...*/
    Used = XCLIENT + XHEBREW + XSYMBOL + FONTP_ACTUAL;
    
    /* Get the per font allocation */
    Used +=  (long)active_fsm_count * ( FSMHEADER + ARB_PTSBLK );
    /* Get the per pointsize per font allocation. */
    curptr = active_fsm_list;
    while( curptr )
    {
       for( i=0; i < MAX_DEV; i++ )
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
       curptr = FNEXT( curptr );
    }
    /* If FSM GDOS is installed, we'll add roughly 8K to the used amount.
     * This way, we don't need to parse the ASSIGN.SYS since this whole
     * thing is supposed to be just an estimate.
     */
    if( gdos_flag )
        Used += 8000L;

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
CacheCheck( int pointsize )
{
   long CharSize;
   
   CacheDataSize =
     ( Current.FSMCacheSize * ( Current.fsm_percent * 10 ) )/100;
   
   CharSize = CalcPointUsage( pointsize );
   CacheUsedSize = GetCurUsage() + CharSize;

   if( ( CacheUsedSize ) >= CacheDataSize )
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
   CacheDataSize =
     ( Current.FSMCacheSize * ( 100 - ( Current.fsm_percent * 10 )) )/100;
   
   CacheUsedSize = GetCurUsage();

   if( ( CacheUsedSize ) >= CacheDataSize )
      form_alert( 1, alert22 );   /* Put out a warning...*/
}





/* CalcPointUsage()
 * ======================================================================
 * Calculates a memory requirement size for a character.
 * If FSM_GDOS is installed, assume 300dpi.
 * If NO FSM_GDOS, assume 91dpi.
 *
 * ASSUME: 72 points == 1 inch.
 *
 * Memory used: -> 84 * ( width of char + height of char )
 *
 * If pointsize is zero, return zero immediately.
 */
long
CalcPointUsage( int pointsize )
{
   long width;
   long height;
   long size;
   
     if( pointsize )
     {
       if( gdos_flag )	/* FSM_GDOS installed, assume 300dpi */
       {
             height = width = ( ( pointsize * 300L ) / 72L );
       }
       else  /* NO FSM_GDOS, assume 91dpi */
       {
	     height = width = ( ( pointsize * 91L ) / 72L );       
       }
       size = ( width + height );
       size *= 84L;	/* The size we need in bytes...*/
       size /= 1024L;	/* get it in K */
       return( size );
     }
     else
       return( 0L );
}

 