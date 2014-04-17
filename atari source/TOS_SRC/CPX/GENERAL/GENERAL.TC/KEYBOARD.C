/* KEYBOARD.C
 *==========================================================================
 * DATE:	March 21, 1990
 * DESCRIPTION: Keyboard Response and Repeat Routines
 */
 
 
 /* INCLUDE FILES
 *==========================================================================
 */ 
#include <sys\gemskel.h>
#include <tos.h>

#include "country.h"

#include "general.h"
#include "gen2.h"



/* DEFINES
 *==========================================================================
 */
#define VERTICAL	0
#define HORIZONTAL	1

/* Keyboard response and repeat rate max and min */
#define KEYMAX 50
#define KEYMIN 1


/* PROTOTYPES
 *==========================================================================
 */
void	Set_Kbrate( void );
void	Get_Kbrate( void );
void	Kbrate_Update( void );
void	Kb_itoa( int n, char *s );

void	KResponse( void );
void	KRepeat( void );


/* EXTERNALS
 *==========================================================================
 */


/* GLOBALS 
 *==========================================================================
 */
char Rep_Text[5];
char Resp_Text[5];

/* FUNCTIONS
 *==========================================================================
 */


 
/* Set_Kbrate()
 *==========================================================================
 * Set Keyboard Repeat and Response Rate
 */ 
void
Set_Kbrate( void )
{
   Kbrate( cur_value.response, cur_value.repeat );
}



/* Get_Kbrate()
 *==========================================================================
 * Get keyboard Repeat and Response Rate
 */
void
Get_Kbrate( void )
{
    int cur_rate;
    
    cur_rate = Kbrate( -1, -1);
    cur_value.repeat   = cur_rate & 0xFF;
    cur_value.response = (cur_rate >> 8) & 0xFF;

    if( cur_value.repeat < KEYMIN )
    	   cur_value.repeat = KEYMIN;
    	   
    if( cur_value.response < KEYMIN )
    	   cur_value.response = KEYMIN;
    
    if( cur_value.repeat > KEYMAX )
    	 cur_value.repeat = KEYMAX;
    	 
    if( cur_value.response > KEYMAX )
    	 cur_value.response = KEYMAX;

    Set_Kbrate();    	 
}



void
Kbrate_Update( void )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ GENERAL ];
   
   (*xcpb->Sl_size)( tree, RESPBASE, KRESPONS, KEYMAX, 20, HORIZONTAL, 0 );
   (*xcpb->Sl_size)( tree, REPTBASE, KREPEAT, KEYMAX, 20, HORIZONTAL, 0 );
   
   (*xcpb->Sl_x)( tree, RESPBASE, KRESPONS, cur_value.response,
                 KEYMIN, KEYMAX, KResponse ); 
   (*xcpb->Sl_x)( tree, REPTBASE, KREPEAT, cur_value.repeat,
                 KEYMIN, KEYMAX, KRepeat );
}



/* KRepeat()
 *==========================================================================
 * Repeat Rate Slider Update Code
 */
void
KRepeat( void )
{
    OBJECT *tree = ( OBJECT *)rs_trindex[ GENERAL ];
    
    Kb_itoa( cur_value.repeat, TedText( KREPEAT ));
    Objc_draw( tree, KREPEAT, 0,NULL);
}



/* KResponse()
 *==========================================================================
 * Response Rate Slider Update Code
 */
void
KResponse( void )
{
    OBJECT *tree = ( OBJECT *)rs_trindex[ GENERAL ];
    
    Kb_itoa( cur_value.response, TedText( KRESPONS ));
    Objc_draw( tree, KRESPONS, 0,NULL);
}




/* Kb_itoa()
 *==========================================================================
 * integer to ascii conversion based upon 20ms ticks
 */
void
Kb_itoa( int n, char *s )
{
	n *= 20;					/* 20ms ticks */
	*s++ = n / 1000 + '0';
	*s++ = '.';
	n %= 1000;
	*s++ = n / 100 + '0';
	n %= 100;
	*s++ = n / 10 + '0';
	*s = '\0';
}

void
Kbrate_Redraw( void )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ GENERAL ];
   int old_repeat   = cur_value.repeat;
   int old_response = cur_value.response;
   
   Get_Kbrate();

   if( old_repeat != cur_value.repeat )
   {
        (*xcpb->Sl_x)( tree, REPTBASE, KREPEAT, cur_value.repeat,
                      KEYMIN, KEYMAX, NULLFUNC );
        Kb_itoa( cur_value.repeat, Rep_Text );
        TedText( KREPEAT ) = Rep_Text;
   	do_redraw( tree, REPTBASE );
   }	
   	
   if( old_response != cur_value.response )
   {
        (*xcpb->Sl_x)( tree, RESPBASE, KRESPONS, cur_value.response,
                      KEYMIN, KEYMAX, NULLFUNC ); 
	Kb_itoa( cur_value.response, Resp_Text );
	TedText( KRESPONS ) = Resp_Text;
  	do_redraw( tree, RESPBASE );
   }	
}


