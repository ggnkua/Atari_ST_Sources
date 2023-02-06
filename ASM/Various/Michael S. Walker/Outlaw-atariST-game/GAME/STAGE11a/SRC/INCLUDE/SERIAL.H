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

#ifndef SERIAL_H
#define SERIAL_H

void RxFullIsr(void);
void TxEmptyIsr(void);
int SerialTxPending(void);
int SerialCanRead(void);
int SerialCanWrite(void);
int SerialRead(char *buff, unsigned int size);
int SerialWrite(const char *buff, unsigned int size);
void SerialTearDown(void);
void SerialSetup(void);

#endif /* SERIAL_H */
