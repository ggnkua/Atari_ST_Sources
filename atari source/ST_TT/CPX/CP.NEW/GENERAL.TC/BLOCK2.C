/* BLOCK2.C
 *==========================================================================
 * DATE:	March 21, 1990
 * DESCRIPTION: STE Chip Select and TT Speaker Routines
 */
 
 
 /* INCLUDE FILES
 *==========================================================================
 */ 
#include <sys\gemskel.h>
#include <tos.h>

#include "country.h"

#include "general.h"
#include "gen2.h"
#include "ttblit.h"

#include "text.h"


/* DEFINES
 *==========================================================================
 */
#define NON_TT_STE	0
#define SPEAKER		1
#define MEGA_STE	2

#define MEGA_STE_CACHE	0xFFFF8E21L	/* BYTE ADDRESS */

/* The MEGA STE allows...
 *             8 Mhz No Cache
 *	      16 Mhz No Cache
 *	      16 Mhz Cache
 * DO NOT Set 8Mhz Cache- EVER! Dire Consequences will result...
 *    PLUS - Preserve the other bits not being used.
 *
 * Bit 0 - Cache Enable
 * Bit 1 - Turbo Enable ( High Speed )
 *
 *	   Bit 1   Bit 0
 *	     0	     0	   0	8 Mhz - no cache
 *	     0       1	   1	 Do Not Use
 *	     1	     0	   2	16 Mhz - No Cache
 *	     1	     1	   3	16 Mhz - Cache
 *
 * HOWEVER, our variable will have it as 
 *        0 - 8 Mhz - no cache
 *	  1 - 16 Mhz - no Cache
 *	  2 - 16 Mhz - Cache
 */



/* PROTOTYPES
 *==========================================================================
 */
void	Init_Block2( void );
void	Set_Block2( void );
void	Get_Block2( void );
void	Block2_Update( void );
void	Do_Block2( void );

int	Block2_Set_Pop( void );
void	Block2_Get_Pop( int flag );

int	Check_Speaker( void );
BOOLEAN	IsSpeaker( void );
void	Set_Speaker( void );
void	Get_Speaker( void );

int	Check_STE( void );
BOOLEAN IsSTE( void );
void	Set_STE( void );
void	Get_STE( void );

long	Write_STE_Cache( void );
long	Read_STE_Cache( void );


/* EXTERNALS
 *==========================================================================
 */


/* GLOBALS 
 *==========================================================================
 */
 
int  Block2_Flag = 0;		/* 0 - NON-TT or STE
				 * 1 - TT Speaker
				 * 2 - MEGA STE Chip Select
				 */



int From_Chip[] = { 0, 0, 1, 2 };	/* Index with STE_Actual */
int To_Chip[]   = { 0, 2, 3 };		/* Index with cur_value.STE_Chip */

int STE_Actual;


/* FUNCTIONS
 *==========================================================================
 */


/* Init_Block2()
 *==========================================================================
 * Check to see if we have a TT speaker or an STE that has a switchable
 * mc68000.
 *
 * Set Block2_Flag to:    0 - NON_TT_STE
 *			  1 - TT Speaker
 *			  2 - STE Chip Select ( MEGA STE )
 */
void
Init_Block2( void )
{
    Block2_Flag = NON_TT_STE;
    Block2_Flag = ( Check_Speaker() | Check_STE() );
}



/* Set_Block2()
 *==========================================================================
 * Set the TT Speaker OR the STE Chip Select Speed.
 * in the hardware.
 */
void
Set_Block2( void )
{
   Set_Speaker();
   Set_STE();
}



/* Get_Block2()
 *==========================================================================
 * Get the current status of either the TT Speaker OR the STE Chip Select
 * Speed.
 */
void
Get_Block2( void )
{
   Get_Speaker();
   Get_STE();
}



/* Block2_Update()
 *==========================================================================
 * 1) Hide or Display Block2 Area
 * 2) Choose Title Text
 * 3) Choose Button Text
 */
void
Block2_Update( void )
{
  OBJECT *tree = ( OBJECT *)rs_trindex[ GENERAL ];
  
  HideObj( BLK2 );
  if( Block2_Flag )
  {
      ShowObj( BLK2 );
      TedText( BLK2TXT ) = block2_title[ Block2_Flag ];
  
      if( IsSpeaker() )
            TedText( BLK2BUTT ) = 
                   chip1_text[ (( cur_value.TT_Speaker )?(FALSE):(TRUE)) ];
      if( IsSTE() )
      	    TedText( BLK2BUTT ) = STE_Speed[ cur_value.STE_Chip ];
  }
}




void
Do_Block2( void )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ GENERAL ];

   char **txtptr;
   int  items;
   int  length;
   int  flag;
   int  temp;
   
   if( IsSpeaker() )
   {
      items  = 2;
      length = 8;
      txtptr = chip1_text;
   }

   if( IsSTE() )
   {
      items  = 3;

#if FRENCH
      length = 22;
#endif
      
#if ITALY
      length = 23;
#endif
      
#if US | UK | SPAIN | GERMAN | SWEDEN
      length = 21;
#endif
      
      txtptr = STE_Text;
   }
   
   temp = Block2_Set_Pop();
   flag = Pop_Handle( BLK2BUTT, txtptr, items, &temp, IBM, length );
   if( flag != -1 )
   {
      Block2_Get_Pop( flag );
      Set_Block2();
   }
   if( IsSpeaker() )
       TedText( BLK2BUTT ) = 
           chip1_text[ (( cur_value.TT_Speaker )?(FALSE):(TRUE)) ];

   if( IsSTE() )
         TedText( BLK2BUTT ) = STE_Speed[ cur_value.STE_Chip ];
         
   Objc_draw( tree, BLK2BUTT, 0, NULL );
}




int
Block2_Set_Pop( void )
{
   int state = NON_TT_STE;

   Get_Block2();
   if( IsSpeaker() )
          state = !cur_value.TT_Speaker;
   if( IsSTE() )
         state = cur_value.STE_Chip;          
   return( state );   
}



void
Block2_Get_Pop( int flag )
{
   if( IsSpeaker() )
      cur_value.TT_Speaker = (( flag ) ? ( FALSE ) : ( TRUE ) );
      
   if( IsSTE() )
      cur_value.STE_Chip = flag;
}





void
Block2_Redraw( void )
{
   OBJECT *tree = ( OBJECT *)rs_trindex[ GENERAL ];
   
   int Old_STE = cur_value.STE_Chip;
   int Old_Speaker = cur_value.TT_Speaker;
   
   Get_Block2();
   Block2_Update();

   if( IsSTE() && ( Old_STE != cur_value.STE_Chip ) )
   	do_redraw( tree, BLK2BUTT );
   
   if( IsSpeaker() && ( Old_Speaker != cur_value.TT_Speaker ) )
        do_redraw( tree, BLK2BUTT );
}




/*--------------------------------------------------------------------------
 * TT Speaker Routines
 *--------------------------------------------------------------------------
 */
 
/* Check_Speaker()
 *==========================================================================
 * Check to see if we have a TT speaker.
 * Check Cookie type for _MCH == 0x2xxxL
 */
int
Check_Speaker( void )
{
   long     p_value;
   
   if( (*xcpb->getcookie)( 0x5f4d4348L, &p_value ) )
   {
      p_value = p_value >> 16;
      if( p_value == 2L )		
            return( SPEAKER );
   }
   return( NON_TT_STE );
}



/* IsSpeaker()
 *==========================================================================
 * Return TRUE or FALSE based on the presence of a TT Speaker.
 * Simply check Block2_Flag.
 */
BOOLEAN
IsSpeaker( void )
{
   return( Block2_Flag & SPEAKER );
}




void
Set_Speaker( void )
{
   if( IsSpeaker() )
   {
      if( cur_value.TT_Speaker )
            Offgibit( 0xBf );		/* Turn off Speaker */
      else
            Ongibit( 0x40 );		/* Turn on Speaker */

   }
}



void
Get_Speaker( void )
{
   char status;
   
   if( IsSpeaker() )
   {
       status = Giaccess( 0, 14 );
       cur_value.TT_Speaker = !( status & 0x040 );
   }
}



/*--------------------------------------------------------------------------
 * STE Chip Select Routines
 *--------------------------------------------------------------------------
 */
 
 /* Check Cookie to see if we are a MEGA_STE */
int
Check_STE( void )
{
   long     p_value;
   
   if( (*xcpb->getcookie)( 0x5f4d4348L, &p_value ) )
   {
      if( p_value == 0x10010L )		
            return( MEGA_STE );
   }
   return( NON_TT_STE );	
}



BOOLEAN
IsSTE( void )
{
   return( Block2_Flag & MEGA_STE );
}
 
 
 

/* Set the Cache and Speed */ 
void
Set_STE( void )
{
   if( IsSTE() )
   {
        STE_Actual = To_Chip[ cur_value.STE_Chip ];
        Supexec( Write_STE_Cache );
   }
}



/* Get the Current Cache and Speed Setting */
void
Get_STE( void )
{
   if( IsSTE() )
   {
       Supexec( Read_STE_Cache );
       cur_value.STE_Chip = From_Chip[ STE_Actual ];
   }
}




long
Write_STE_Cache( void )
{
    char *ptr;
    char hold;
    
    ptr = ( char *)MEGA_STE_CACHE;
    hold = *ptr;
    
    hold &= 0xfc;
    hold |= (char)(STE_Actual & 2);
    *ptr = hold;
    hold |= (char)(STE_Actual & 1);
    *ptr = hold;
    return 0L;
}


long
Read_STE_Cache( void )
{
   char *ptr;
   
   ptr = ( char *)MEGA_STE_CACHE;
   STE_Actual = ( int )( *ptr & 0x3 );
   return( 0L );
}



