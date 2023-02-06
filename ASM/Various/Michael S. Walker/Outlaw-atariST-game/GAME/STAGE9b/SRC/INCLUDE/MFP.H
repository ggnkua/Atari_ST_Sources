/*
 * Michael S. Walker <mwalk762@mtroyal.ca>
 *	    _    _
 *       | |  | |	OUTLAW. 
 *      -| |  | |- 
 *  _    | |- | |
 *-| |   | |  | |- 	
 * |.|  -| ||/  |
 * | |-  |  ___/ 
 *-|.|   | | |
 * |  \_|| |
 *  \____  |
 *   |   | |- 
 *       | |
 *      -| |
 *       |_| Copyleft !(c) 2020 All Rights Unreserved in all Federations, including Alpha Centauris.
 */

#ifndef MFP_H
#define MFP_H

#include <TYPES.H>

/*
 *  MFP Interrupt Control Registers
 */

extern volatile uint8_t *const MFP_IERA = 0xFFFFA07;
extern volatile uint8_t *const MFP_IERB = 0xFFFFA09;
extern volatile uint8_t *const MFP_IPRA = 0xFFFFA0B;
extern volatile uint8_t *const MFP_IPRB = 0xFFFFA0D;
extern volatile uint8_t *const MFP_ISRA = 0xFFFFA0F;
extern volatile uint8_t *const MFP_ISRB = 0xFFFFA11;
extern volatile uint8_t *const MFP_IMRA = 0xFFFFA13;
extern volatile uint8_t *const MFP_IMRB = 0xFFFFA15;
extern volatile uint8_t *const MFP_VR = 0xFFFFA17;

/*
 *  MFP Interrupt Control Registers
 *  Interrupt Control Registers - (IERA) (IPRA) (IMRA) (ISRA)
 *  X Register register bit values.
 */

#define MFP_IxRA_GPIP7 0x80
#define MFP_IxRA_GPIP6 0x40
#define MFP_IxRA_TIMER_A 0x20
#define MFP_IxRA_RCV_BUFFER_FULL 0x10
#define MFP_IxRA_RCV_ERROR 0x08
#define MFP_IxRA_XMIT_BUFFER_EMPTY 0x04
#define MFP_IxRA_XMIT_ERROR 0x02
#define MFP_IxRA_TIMER_B 0x01

/*  MFP Interrupt Control Registers
 *  Interrupt Control Registers - (IERB) (IPRB) (IMRB) (ISRB)
 *  X Register register bit values.
 */

#define MFP_IxRB_GPIP5 0x80
#define MFP_IxRB_GPIP4 0x40
#define MFP_IxRB_TIMER_C 0x20
#define MFP_IxRB_TIMER_D 0x10
#define MFP_IxRB_GPIP3 0x08
#define MFP_IxRB_GPIP2 0x04
#define MFP_IxRB_GPIP1 0x02
#define MFP_IxRB_GPIP0 0x01

/*  MFP Interrupt Control Registers
 *  Interrupt Control Registers - (IERB) (IPRB) (IMRB) (ISRB)
 *  Vector Register register bit values.
 */

#define MFP_VR_VECTOR_7 0x80
#define MFP_VR_VECTOR_6 0x40
#define MFP_VR_VECTOR_5 0x20
#define MFP_VR_VECTOR_4 0x10
#define MFP_VR_SERVICE_REGISTER_ENABLE 0x08

#endif /* MFP_H */
