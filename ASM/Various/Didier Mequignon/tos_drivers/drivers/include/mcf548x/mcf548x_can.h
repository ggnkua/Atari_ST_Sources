/*
 * File:    mcf548x_can.h
 * Purpose: Register and bit definitions
 */

#ifndef __MCF548X_CAN_H__
#define __MCF548X_CAN_H__

/*********************************************************************
*
* FlexCAN Module (CAN)
*
*********************************************************************/

/* Register read/write macros */
#define MCF_CAN0_CANMCR                  (*(vuint32*)(&__MBAR[0x00A000]))
#define MCF_CAN0_CANCTRL                 (*(vuint32*)(&__MBAR[0x00A004]))
#define MCF_CAN0_TIMER                   (*(vuint32*)(&__MBAR[0x00A008]))
#define MCF_CAN0_RXGMASK                 (*(vuint32*)(&__MBAR[0x00A010]))
#define MCF_CAN0_RX14MASK                (*(vuint32*)(&__MBAR[0x00A014]))
#define MCF_CAN0_RX15MASK                (*(vuint32*)(&__MBAR[0x00A018]))
#define MCF_CAN0_ERRCNT                  (*(vuint32*)(&__MBAR[0x00A01C]))
#define MCF_CAN0_ERRSTAT                 (*(vuint32*)(&__MBAR[0x00A020]))
#define MCF_CAN0_IMASK                   (*(vuint32*)(&__MBAR[0x00A028]))
#define MCF_CAN0_IFLAG                   (*(vuint32*)(&__MBAR[0x00A030]))
#define MCF_CAN1_CANMCR                  (*(vuint32*)(&__MBAR[0x00A800]))
#define MCF_CAN1_CANCTRL                 (*(vuint32*)(&__MBAR[0x00A804]))
#define MCF_CAN1_TIMER                   (*(vuint32*)(&__MBAR[0x00A808]))
#define MCF_CAN1_RXGMASK                 (*(vuint32*)(&__MBAR[0x00A810]))
#define MCF_CAN1_RX14MASK                (*(vuint32*)(&__MBAR[0x00A814]))
#define MCF_CAN1_RX15MASK                (*(vuint32*)(&__MBAR[0x00A818]))
#define MCF_CAN1_ERRCNT                  (*(vuint32*)(&__MBAR[0x00A81C]))
#define MCF_CAN1_ERRSTAT                 (*(vuint32*)(&__MBAR[0x00A820]))
#define MCF_CAN1_IMASK                   (*(vuint32*)(&__MBAR[0x00A828]))
#define MCF_CAN1_IFLAG                   (*(vuint32*)(&__MBAR[0x00A830]))
#define MCF_CAN_CANMCR(x)                (*(vuint32*)(&__MBAR[0x00A000+((x)*0x800)]))
#define MCF_CAN_CANCTRL(x)               (*(vuint32*)(&__MBAR[0x00A004+((x)*0x800)]))
#define MCF_CAN_TIMER(x)                 (*(vuint32*)(&__MBAR[0x00A008+((x)*0x800)]))
#define MCF_CAN_RXGMASK(x)               (*(vuint32*)(&__MBAR[0x00A010+((x)*0x800)]))
#define MCF_CAN_RX14MASK(x)              (*(vuint32*)(&__MBAR[0x00A014+((x)*0x800)]))
#define MCF_CAN_RX15MASK(x)              (*(vuint32*)(&__MBAR[0x00A018+((x)*0x800)]))
#define MCF_CAN_ERRCNT(x)                (*(vuint32*)(&__MBAR[0x00A01C+((x)*0x800)]))
#define MCF_CAN_ERRSTAT(x)               (*(vuint32*)(&__MBAR[0x00A020+((x)*0x800)]))
#define MCF_CAN_IMASK(x)                 (*(vuint32*)(&__MBAR[0x00A028+((x)*0x800)]))
#define MCF_CAN_IFLAG(x)                 (*(vuint32*)(&__MBAR[0x00A030+((x)*0x800)]))

/* Bit definitions and macros for MCF_CAN_CANMCR */
#define MCF_CAN_CANMCR_MAXMB(x)          (((x)&0x0000000F)<<0)
#define MCF_CAN_CANMCR_SUPV              (0x00800000)
#define MCF_CAN_CANMCR_FRZACK            (0x01000000)
#define MCF_CAN_CANMCR_SOFTRST           (0x02000000)
#define MCF_CAN_CANMCR_HALT              (0x10000000)
#define MCF_CAN_CANMCR_FRZ               (0x40000000)
#define MCF_CAN_CANMCR_MDIS              (0x80000000)

/* Bit definitions and macros for MCF_CAN_CANCTRL */
#define MCF_CAN_CANCTRL_PROPSEG(x)       (((x)&0x00000007)<<0)
#define MCF_CAN_CANCTRL_LOM              (0x00000008)
#define MCF_CAN_CANCTRL_LBUF             (0x00000010)
#define MCF_CAN_CANCTRL_TSYNC            (0x00000020)
#define MCF_CAN_CANCTRL_BOFFREC          (0x00000040)
#define MCF_CAN_CANCTRL_SAMP             (0x00000080)
#define MCF_CAN_CANCTRL_LPB              (0x00001000)
#define MCF_CAN_CANCTRL_CLKSRC           (0x00002000)
#define MCF_CAN_CANCTRL_ERRMSK           (0x00004000)
#define MCF_CAN_CANCTRL_BOFFMSK          (0x00008000)
#define MCF_CAN_CANCTRL_PSEG2(x)         (((x)&0x00000007)<<16)
#define MCF_CAN_CANCTRL_PSEG1(x)         (((x)&0x00000007)<<19)
#define MCF_CAN_CANCTRL_RJW(x)           (((x)&0x00000003)<<22)
#define MCF_CAN_CANCTRL_PRESDIV(x)       (((x)&0x000000FF)<<24)

/* Bit definitions and macros for MCF_CAN_TIMER */
#define MCF_CAN_TIMER_TIMER(x)           (((x)&0x0000FFFF)<<0)

/* Bit definitions and macros for MCF_CAN_RXGMASK */
#define MCF_CAN_RXGMASK_MI(x)            (((x)&0x1FFFFFFF)<<0)

/* Bit definitions and macros for MCF_CAN_RX14MASK */
#define MCF_CAN_RX14MASK_MI(x)           (((x)&0x1FFFFFFF)<<0)

/* Bit definitions and macros for MCF_CAN_RX15MASK */
#define MCF_CAN_RX15MASK_MI(x)           (((x)&0x1FFFFFFF)<<0)

/* Bit definitions and macros for MCF_CAN_ERRCNT */
#define MCF_CAN_ERRCNT_TXECTR(x)         (((x)&0x000000FF)<<0)
#define MCF_CAN_ERRCNT_RXECTR(x)         (((x)&0x000000FF)<<8)

/* Bit definitions and macros for MCF_CAN_ERRSTAT */
#define MCF_CAN_ERRSTAT_WAKINT           (0x00000001)
#define MCF_CAN_ERRSTAT_ERRINT           (0x00000002)
#define MCF_CAN_ERRSTAT_BOFFINT          (0x00000004)
#define MCF_CAN_ERRSTAT_FLTCONF(x)       (((x)&0x00000003)<<4)
#define MCF_CAN_ERRSTAT_TXRX             (0x00000040)
#define MCF_CAN_ERRSTAT_IDLE             (0x00000080)
#define MCF_CAN_ERRSTAT_RXWRN            (0x00000100)
#define MCF_CAN_ERRSTAT_TXWRN            (0x00000200)
#define MCF_CAN_ERRSTAT_STFERR           (0x00000400)
#define MCF_CAN_ERRSTAT_FRMERR           (0x00000800)
#define MCF_CAN_ERRSTAT_CRCERR           (0x00001000)
#define MCF_CAN_ERRSTAT_ACKERR           (0x00002000)
#define MCF_CAN_ERRSTAT_BITERR(x)        (((x)&0x00000003)<<14)
#define MCF_CAN_ERRSTAT_FLTCONF_ACTIVE   (0x00000000)
#define MCF_CAN_ERRSTAT_FLTCONF_PASSIVE  (0x00000010)
#define MCF_CAN_ERRSTAT_FLTCONF_BUSOFF   (0x00000020)

/* Bit definitions and macros for MCF_CAN_IMASK */
#define MCF_CAN_IMASK_BUF(x)             (1<<x)

/* Bit definitions and macros for MCF_CAN_IFLAG */
#define MCF_CAN_IFLAG_BUF(x)             (1<<x)

/********************************************************************/

#endif /* __MCF548X_CAN_H__ */
