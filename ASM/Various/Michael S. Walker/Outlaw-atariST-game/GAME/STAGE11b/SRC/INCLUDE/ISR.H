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

#include <TYPES.H>

#ifndef ISR_H
#define ISR_H

#define HBL_ISR 26
#define VBL_ISR 28
#define IKBD_ISR 70

/*
 *  MFP Interrupt Control Registers
 */

extern volatile uint8_t *const MFP_PDR = 0xFFFFA01;
extern volatile uint8_t *const MFP_AER = 0xFFFFA03;
extern volatile uint8_t *const MFP_DIR = 0xFFFFA05;
extern volatile uint8_t *const MFP_IERA = 0xFFFFA07;
extern volatile uint8_t *const MFP_IERB = 0xFFFFA09;
extern volatile uint8_t *const MFP_IPRA = 0xFFFFA0B;
extern volatile uint8_t *const MFP_IPRB = 0xFFFFA0D;
extern volatile uint8_t *const MFP_ISRA = 0xFFFFA0F;
extern volatile uint8_t *const MFP_ISRB = 0xFFFFA11;
extern volatile uint8_t *const MFP_IMRA = 0xFFFFA13;
extern volatile uint8_t *const MFP_IMRB = 0xFFFFA15;
extern volatile uint8_t *const MFP_VCR = 0xFFFFA17;
extern volatile uint8_t *const MFP_TAC = 0xFFFFA19;
extern volatile uint8_t *const MFP_TBC = 0xFFFFA1B;
extern volatile uint8_t *const MFP_TAD = 0xFFFFA1F;
extern volatile uint8_t *const MFP_TBD = 0xFFFFA21;
extern volatile uint8_t *const MFP_TCD = 0xFFFFA23;
extern volatile uint8_t *const MFP_TDD = 0xFFFFA25;
extern volatile uint8_t *const MFP_SYC = 0xFFFFA27;
extern volatile uint8_t *const MFP_UCR = 0xFFFFA29;
extern volatile uint8_t *const MFP_RES = 0xFFFFA2B;
extern volatile uint8_t *const MFP_TRS = 0xFFFFA2D;
extern volatile uint8_t *const MFP_UAD = 0xFFFFA2F;

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

typedef void (*Vector)(void); /* a Vector is a function start addr. */
void InstallMfp(void);
Vector InstallVector(int num, Vector vector);
extern void Vbl(void);
extern void Hbl(void);
extern void Ikbd(void);

#endif /* ISR_H */
