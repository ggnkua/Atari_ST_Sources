/* PORTS.C
 *==========================================================================
 * DATE: March 9, 1990
 * DESCRIPTION: MODEM CPX
 *		Reading and writing to the 4 serial ports
 */



/* INCLUDE FILES 
 *==========================================================================
 */
#include <sys\gemskel.h>
#include <tos.h>

#include "struct.h"
#include "modem2.h"


/* PROTOTYPES
 *==========================================================================
 */
void	Write_Port( int cur_port, BUFFER *store );
void	Read_Port( int cur_port, BUFFER *store );
void	Set_Rsconf( int cur_port );

void	Set_BaudRate( int baudrate );
int	Get_BaudRate( BUFFER *store );

void	Set_FlowControl( int flow );
int	Get_FlowControl( BUFFER *store );

void	Set_UCR( int parity, int stop, int bits );
int	Get_UCR( void );

int	Get_Parity( int SData );
int	Get_StopBits( int SData );
int	Get_BitsChar( int SData );


/* DEFINES
 *==========================================================================
 */	



/* EXTERNALS
 *==========================================================================
 */



/* GLOBALS
 *==========================================================================
 */


/* FUNCTIONS
 *==========================================================================
 */
 



/* Write_Port()
 *==========================================================================
 * Set the current active serial port with the current data in 
 * the data structure. NOTE: The port has already been mapped in.
 * IN: MDATA *modem:   The modem data structure array
 *     int   cur_port: The current active serial port - 0 - 3
 *     BUFFER *store:  Pointer to the 64byte buffer in the node
 *		       This however, has already been incremented
 *		       to the proper location based on cur_port.
 *		       store  =   for 0
 *		       store++=   for port 1
 *			etc...
 */
void
Write_Port( int port, BUFFER *store )
{
     Set_Active_Port( port );
     store->cur_baud    = Modem.modem[ port ].cur_baud;
     store->cur_flow    = Modem.modem[ port ].cur_flow;
     Set_Rsconf( port );
}





/* Read_Port()
 *==========================================================================
 * Read the current active port data INTO the modem structure
 * Note: the port has already been mapped in.
 * IN: cur_port: The active current port index
 *     store:    Pointer to the current port node buffer
 */
void
Read_Port( int port, BUFFER *store )
{
  int UCR_Data;
  
  Set_Active_Port( port );
  Modem.modem[ port ].cur_baud  = Get_BaudRate( store );
  Modem.modem[ port ].cur_flow  = Get_FlowControl( store );

  Set_BaudRate( Modem.modem[ port ].cur_baud );
  Set_FlowControl( Modem.modem[ port ].cur_flow );
  
  UCR_Data = Get_UCR();
  Modem.modem[ port ].cur_parity = Get_Parity( UCR_Data ); 
  Modem.modem[ port ].cur_stop   = Get_StopBits( UCR_Data );
  Modem.modem[ port ].cur_bits   = Get_BitsChar( UCR_Data );
}





/* Set_Rsconf()
 *==========================================================================
 * Set the current active serial port mapped in with new data
 * The port has already been mapped.
 */
void
Set_Rsconf( int port )
{
    Set_BaudRate( Modem.modem[ port ].cur_baud );
    Set_FlowControl( Modem.modem[ port ].cur_flow );
    Set_UCR( Modem.modem[ port ].cur_parity,
    	     Modem.modem[ port ].cur_stop,
    	     Modem.modem[ port ].cur_bits );	
}



/* Set_BaudRate()
 *==========================================================================
 * Set the Current Baud Rate 
 */
void
Set_BaudRate( int baudrate )
{
    Rsconf( baudrate, -1, -1, -1, -1, -1 );
}




/* Get_BaudRate()
 *==========================================================================
 * Return the current baud rate.
 * On Tos 1.4 or greater, we can get the actual baud rate.
 * Otherwise, we return what we think it is in the 64 byte node buffe
 */
int
Get_BaudRate( BUFFER *store )
{
   if( Check_OS() )
       return( (int)Rsconf( -2, -1, -1, -1, -1, -1 ) );
   else
       return( store->cur_baud );
}




/* Set_FlowControl()
 *==========================================================================
 * Set the Flow Control for the current active serial port
 */
void
Set_FlowControl( int flow )
{
   Rsconf( -1, flow, -1, -1, -1, -1 );
}




/* Get_FlowControl()
 *==========================================================================
 * Get the current flow control from the buffer.
 * NOTE: we can't read the flow control from the hardware, therefore
 * we must get it from the buffer instead.
 */
int
Get_FlowControl( BUFFER *store )
{
   return( store->cur_flow );
}



/* Set_UCR()
 *==========================================================================
 * Set the UCR in the current active Serial port
 */
void
Set_UCR( int parity, int stop, int bits )
{
    int SData;
    
    SData = Get_UCR();    
    /* Preserve bits 0 and 7, clear out bits 1 thru 6 */
    SData &= 0x81;

	/* Add 1 to parity to correspond to actual settings 
	 *    we want        they want
	 *      0		0	No Parity
	 *      0		1	No Parity
	 *      1		2	Odd Parity
	 *      2		3	Even Parity
	 * Just remember to subtract 1 later when reading rsconf...
	 */
	SData |= ( ( ( parity + 1 ) << 1 ) & 0x06 );
	SData |= ( ( stop << 3 ) & 0x18 );
	SData |= ( ( bits << 5 ) & 0x60 );
	Rsconf( -1, -1, SData, -1, -1, -1 );
}




/* Get_UCR()
 *==========================================================================
 * Get the current UCR from the current active serial port
 */
int
Get_UCR( void )
{
   long RData;
   int  SData;
   
   RData = Rsconf( -1, -1, -1, -1, -1, -1 );
   SData = ( int )( ( RData >> 24 ) & 0xff );
   return( SData );
}




/* Get_Parity()
 *==========================================================================
 * Get the current parity from the current active serial port
 */
int
Get_Parity( int SData )
{
   int parity;
   
   parity = (int)( ( SData >> 1 ) & 0x03 );
   if( parity ) parity -= 1;
   return( parity );
}



/* Get_StopBits()
 *==========================================================================
 * Get the current stop bits from the active serial port
 */
int
Get_StopBits( int SData )
{
     return( ( SData >> 3 ) & 0x03 );
}



/* Get_BitsChar()
 *==========================================================================
 * Get the current bits per character from the active serial port
 */
int
Get_BitsChar( int SData )
{
   return( ( SData >> 5 ) & 0x03 ); 
}



