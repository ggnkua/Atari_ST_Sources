/*
 * File:    mcf548x_i2c.h
 * Purpose: Register and bit definitions for the MCF548X
 *
 * Notes:   
 *  
 */

#ifndef __MCF548X_I2C_H__
#define __MCF548X_I2C_H__

/*********************************************************************
*
* I2C Module (I2C)
*
*********************************************************************/

/* Register read/write macros */
#define MCF_I2C_I2AR     (__MBAR + 0x008F00)
#define MCF_I2C_I2FDR    (__MBAR + 0x008F04)
#define MCF_I2C_I2CR     (__MBAR + 0x008F08)
#define MCF_I2C_I2SR     (__MBAR + 0x008F0C)
#define MCF_I2C_I2DR     (__MBAR + 0x008F10)
#define MCF_I2C_I2ICR    (__MBAR + 0x008F20)

/* Bit definitions and macros for MCF_I2C_I2AR */
#define MCF_I2C_I2AR_ADR(x)    (((x)&0x7F)<<1)

/* Bit definitions and macros for MCF_I2C_I2FDR */
#define MCF_I2C_I2FDR_IC(x)    (((x)&0x3F)<<0)

/* Bit definitions and macros for MCF_I2C_I2CR */
#define MCF_I2C_I2CR_RSTA      (0x04)
#define MCF_I2C_I2CR_TXAK      (0x08)
#define MCF_I2C_I2CR_MTX       (0x10)
#define MCF_I2C_I2CR_MSTA      (0x20)
#define MCF_I2C_I2CR_IIEN      (0x40)
#define MCF_I2C_I2CR_IEN       (0x80)

/* Bit definitions and macros for MCF_I2C_I2SR */
#define MCF_I2C_I2SR_RXAK      (0x01)
#define MCF_I2C_I2SR_IIF       (0x02)
#define MCF_I2C_I2SR_SRW       (0x04)
#define MCF_I2C_I2SR_IAL       (0x10)
#define MCF_I2C_I2SR_IBB       (0x20)
#define MCF_I2C_I2SR_IAAS      (0x40)
#define MCF_I2C_I2SR_ICF       (0x80)

/* Bit definitions and macros for MCF_I2C_I2ICR */
#define MCF_I2C_I2ICR_IE       (0x01)
#define MCF_I2C_I2ICR_RE       (0x02)
#define MCF_I2C_I2ICR_TE       (0x04)
#define MCF_I2C_I2ICR_BNBE     (0x08)

/********************************************************************/

#endif /* __MCF548X_I2C_H__ */
