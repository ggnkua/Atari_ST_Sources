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

#ifndef IKBD_H
#define IKBD_H

#include <TYPES.H>

/* CONTROL REGISTER 6850: RIE | TC2 | TC1 | WS3 | WS2 | WS1 | CDS2 | CDS1 */
extern volatile uint8_t *const IKBD_control = 0xfffffc00;

/* STATUS REGISTER 6850: IRQ | PE | OVRN | PE | CTS | DCD | TxDRE | RxDRF 						     */
/* bit 7: interupt request: 			set to 1 when pin is activated 							  	 */
/* bit 6: Parity error: 				when parity of received word != parity bit 				 	 */
/* bit 5: overrun error: 				processor did not read previous input reset when rectified   */
/* bit 4: framing error: 				set when no stop bit is observed reset when rectified		 */
/* bit 3: state of clear: 				to send input pin											 */
/* bit 2: state of data carrier: 		detect input pin											 */
/* bit 1: transmitter data register:	is empty when flag = 1										 */
/* bit 0: receive data register: 		is full when flag = 1										 */

extern volatile const uint8_t *const IKBD_status = 0xfffffc00;
extern volatile const SCANCODE *const IKBD_RDR = 0xfffffc02;

#define BREAK_CODE(make_code) ((make_code) | 0x80)
#define RDR_FULL(ikbdstatus) ((ikbdstatus)&ACIA_STATUS_RDRF)

#define CR_MASK (ACIA_CONTROL_CDSB_CLOCKDIVIDE_64 | ACIA_CONTROL_WSB_8n1)
#define CR_SETTINGS (CR_MASK | ACIA_CONTROL_TCB_RTS_LO_TX_INTERRUPT_DISABLED_BREAK)
#define CR_SETTINGS_RXINT (CR_SETTINGS | ACIA_CONTROL_RX_INTERRUPT_ENABLED)
#define ACIA_STATUS_RDRF (0x01)
#define ACIA_STATUS_TDRE (0x02)
#define ACIA_STATUS_DCD (0x04)
#define ACIA_STATUS_CTS (0x08)
#define ACIA_STATUS_FE (0x10)
#define ACIA_STATUS_OVRN (0x20)
#define ACIA_STATUS_PE (0x40)
#define ACIA_STATUS_IRQ (0x80)
#define ACIA_CONTROL_CDSB_CLOCKDIVIDE_1 (0x00)
#define ACIA_CONTROL_CDSB_CLOCKDIVIDE_16 (0x01)
#define ACIA_CONTROL_CDSB_MASTER_RESET (0x03)
#define ACIA_CONTROL_WSB_7e2 (0x00 << 2)
#define ACIA_CONTROL_WSB_7o2 (0x01 << 2)
#define ACIA_CONTROL_WSB_7e1 (0x02 << 2)
#define ACIA_CONTROL_WSB_7o1 (0x03 << 2)
#define ACIA_CONTROL_WSB_8n2 (0x04 << 2)
#define ACIA_CONTROL_WSB_8e1 (0x06 << 2)
#define ACIA_CONTROL_WSB_8o1 (0x07 << 2)
#define ACIA_CONTROL_TCB_RTS_HI_TX_INTERRUPT_DISABLED (0x00 << 5)
#define ACIA_CONTROL_TCB_RTS_LO_TX_INTERRUPT_ENABLED (0x01 << 5)
#define ACIA_CONTROL_TCB_RTS_HI_TX_INTERRUPT_DISABLED (0x02 << 5)
#define ACIA_CONTROL_TCB_RTS_LO_TX_INTERRUPT_DISABLED_BREAK (0x03 << 5)
#define ACIA_CONTROL_RX_INTERRUPT_ENABLED (0x01 << 7)
#define ACIA_CONTROL_TCB_RTS_LO_TX_INTERRUPT_DISABLED_BREAK (0x03 << 5)
#define ACIA_CONTROL_CDSB_CLOCKDIVIDE_64 (0x02)
#define ACIA_CONTROL_WSB_8n1 (0x05 << 2)

#endif /* IKBD_H */