/*
 * Michael S. Walker <mwalk762@mtroyal.ca>
 *         _    _
 *        | |  | |	OUTLAW. 
 *       -| |  | |- 
 *   _    | |- | |
 * -| |   | |  | |- 	
 *  |.|  -| ||/  |
 *  | |-  |  ___/ 
 * -|.|   | | |
 *  |  \_|| |
 *   \____  |
 *    |   | |- 
 *        | |
 *       -| |
 *        |_| Copyleft !(c) 2020 All Rights Unreserved in all Federations, including Alpha Centauris.
 */

#include <SERIAL.H>

/*-------------------------------------------- SerialSetup -----
|  Function SerialSetup
|
|  Purpose: Initializes the serial interface and its associated buffers, and installs the needed ISRs.
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void SerialSetup(void)
{
}

/*-------------------------------------------- SerialTearDown -----
|  Function SerialTearDown
|
|  Purpose: Cleans up. Restores all original settings.
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void SerialTearDown(void)
{
}

/*-------------------------------------------- SerialWrite -----
|  Function SerialWrite
|
|  Purpose: Enqueues size bytes from buff in the serial output buffer. This function is non-blocking,
| meaning that it returns without waiting for the data to be transmitted. Transmission continues “in
| the background”. The number of bytes actually enqueued is returned (this may be less than size,
| if there was insufficient space in the buffer).
|
|  Parameters: Size (bytes from buff), buff output buffer
|
|  Returns: number of bytes actually enqueued
*-------------------------------------------------------------------*/

int SerialWrite(const char *buff, unsigned int size)
{
}

/*-------------------------------------------- SerialRead -----
|  Function SerialRead
|
|  Purpose: Like SerialWrite, except that if dequeues up to size bytes from the serial input buffer and
| stores them in buff. The number of bytes actually dequeued is returned
|
|  Parameters: Size (bytes in buff), buff input buffer
|
|  Returns: The number of bytes actually dequeued
*-------------------------------------------------------------------*/

int SerialRead(char *buff, unsigned int size)
{
}

/*-------------------------------------------- SerialCanWrite -----
|  Function SerialCanWrite
|
|  Purpose: Returns the number of bytes which can be successfully written, at the time of call.
|
|  Parameters:
|
|  Returns: number of bytes which can be successfully written
*-------------------------------------------------------------------*/

int SerialCanWrite(void)
{
}

/*-------------------------------------------- SerialCanRead -----
|  Function SerialCanRead
|
|  Purpose: Returns the number of bytes which can be successfully read, at the time of call.
|
|  Parameters:
|
|  Returns: number of bytes which can be successfully read
*-------------------------------------------------------------------*/

int SerialCanRead(void)
{
}

/*-------------------------------------------- SerialTxPending -----
|  Function SerialTxPending
|
|  Purpose: this is used to test if all previously written bytes have been transmitted or not.
|
|  Parameters:
|
|  Returns: Returns 0 if the serial output buffer is empty. Returns non-0 otherwise
*-------------------------------------------------------------------*/

int SerialTxPending(void)
{
}

/*-------------------------------------------- TxEmptyIsr -----
|  Function TxEmptyIsr
|
|  Purpose: The ISR which is invoked whenever the USART’s Tx register becomes empty
|
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void TxEmptyIsr(void)
{
}

/*-------------------------------------------- RxFullIsr -----
|  Function RxFullIsr
|
|  Purpose: The ISR which is invoked whenever the USART’s Rx register becomes full.
| 
|  Parameters:
|
|  Returns:
*-------------------------------------------------------------------*/

void RxFullIsr(void)
{
}
