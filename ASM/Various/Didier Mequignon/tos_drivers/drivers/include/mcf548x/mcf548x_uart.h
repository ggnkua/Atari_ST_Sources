/*
 * File:    mcf548x_uart.h
 * Purpose: Register and bit definitions
 */

#ifndef __MCF548X_UART_H__
#define __MCF548X_UART_H__

/*********************************************************************
*
* Universal Asynchronous Receiver Transmitter (UART)
*
*********************************************************************/

/* Register read/write macros */
#define MCF_UART0_UMR                 (*(vuint8 *)(&__MBAR[0x008600]))
#define MCF_UART0_USR                 (*(vuint8 *)(&__MBAR[0x008604]))
#define MCF_UART0_UCSR                (*(vuint8 *)(&__MBAR[0x008604]))
#define MCF_UART0_UCR                 (*(vuint8 *)(&__MBAR[0x008608]))
#define MCF_UART0_URB                 (*(vuint8 *)(&__MBAR[0x00860C]))
#define MCF_UART0_UTB                 (*(vuint8 *)(&__MBAR[0x00860C]))
#define MCF_UART0_UIPCR               (*(vuint8 *)(&__MBAR[0x008610]))
#define MCF_UART0_UACR                (*(vuint8 *)(&__MBAR[0x008610]))
#define MCF_UART0_UISR                (*(vuint8 *)(&__MBAR[0x008614]))
#define MCF_UART0_UIMR                (*(vuint8 *)(&__MBAR[0x008614]))
#define MCF_UART0_UBG1                (*(vuint8 *)(&__MBAR[0x008618]))
#define MCF_UART0_UBG2                (*(vuint8 *)(&__MBAR[0x00861C]))
#define MCF_UART0_UIP                 (*(vuint8 *)(&__MBAR[0x008634]))
#define MCF_UART0_UOP1                (*(vuint8 *)(&__MBAR[0x008638]))
#define MCF_UART0_UOP0                (*(vuint8 *)(&__MBAR[0x00863C]))
#define MCF_UART1_UMR                 (*(vuint8 *)(&__MBAR[0x008700]))
#define MCF_UART1_USR                 (*(vuint8 *)(&__MBAR[0x008704]))
#define MCF_UART1_UCSR                (*(vuint8 *)(&__MBAR[0x008704]))
#define MCF_UART1_UCR                 (*(vuint8 *)(&__MBAR[0x008708]))
#define MCF_UART1_URB                 (*(vuint8 *)(&__MBAR[0x00870C]))
#define MCF_UART1_UTB                 (*(vuint8 *)(&__MBAR[0x00870C]))
#define MCF_UART1_UIPCR               (*(vuint8 *)(&__MBAR[0x008710]))
#define MCF_UART1_UACR                (*(vuint8 *)(&__MBAR[0x008710]))
#define MCF_UART1_UISR                (*(vuint8 *)(&__MBAR[0x008714]))
#define MCF_UART1_UIMR                (*(vuint8 *)(&__MBAR[0x008714]))
#define MCF_UART1_UBG1                (*(vuint8 *)(&__MBAR[0x008718]))
#define MCF_UART1_UBG2                (*(vuint8 *)(&__MBAR[0x00871C]))
#define MCF_UART1_UIP                 (*(vuint8 *)(&__MBAR[0x008734]))
#define MCF_UART1_UOP1                (*(vuint8 *)(&__MBAR[0x008738]))
#define MCF_UART1_UOP0                (*(vuint8 *)(&__MBAR[0x00873C]))
#define MCF_UART2_UMR                 (*(vuint8 *)(&__MBAR[0x008800]))
#define MCF_UART2_USR                 (*(vuint8 *)(&__MBAR[0x008804]))
#define MCF_UART2_UCSR                (*(vuint8 *)(&__MBAR[0x008804]))
#define MCF_UART2_UCR                 (*(vuint8 *)(&__MBAR[0x008808]))
#define MCF_UART2_URB                 (*(vuint8 *)(&__MBAR[0x00880C]))
#define MCF_UART2_UTB                 (*(vuint8 *)(&__MBAR[0x00880C]))
#define MCF_UART2_UIPCR               (*(vuint8 *)(&__MBAR[0x008810]))
#define MCF_UART2_UACR                (*(vuint8 *)(&__MBAR[0x008810]))
#define MCF_UART2_UISR                (*(vuint8 *)(&__MBAR[0x008814]))
#define MCF_UART2_UIMR                (*(vuint8 *)(&__MBAR[0x008814]))
#define MCF_UART2_UBG1                (*(vuint8 *)(&__MBAR[0x008818]))
#define MCF_UART2_UBG2                (*(vuint8 *)(&__MBAR[0x00881C]))
#define MCF_UART2_UIP                 (*(vuint8 *)(&__MBAR[0x008834]))
#define MCF_UART2_UOP1                (*(vuint8 *)(&__MBAR[0x008838]))
#define MCF_UART2_UOP0                (*(vuint8 *)(&__MBAR[0x00883C]))
#define MCF_UART3_UMR                 (*(vuint8 *)(&__MBAR[0x008900]))
#define MCF_UART3_USR                 (*(vuint8 *)(&__MBAR[0x008904]))
#define MCF_UART3_UCSR                (*(vuint8 *)(&__MBAR[0x008904]))
#define MCF_UART3_UCR                 (*(vuint8 *)(&__MBAR[0x008908]))
#define MCF_UART3_URB                 (*(vuint8 *)(&__MBAR[0x00890C]))
#define MCF_UART3_UTB                 (*(vuint8 *)(&__MBAR[0x00890C]))
#define MCF_UART3_UIPCR               (*(vuint8 *)(&__MBAR[0x008910]))
#define MCF_UART3_UACR                (*(vuint8 *)(&__MBAR[0x008910]))
#define MCF_UART3_UISR                (*(vuint8 *)(&__MBAR[0x008914]))
#define MCF_UART3_UIMR                (*(vuint8 *)(&__MBAR[0x008914]))
#define MCF_UART3_UBG1                (*(vuint8 *)(&__MBAR[0x008918]))
#define MCF_UART3_UBG2                (*(vuint8 *)(&__MBAR[0x00891C]))
#define MCF_UART3_UIP                 (*(vuint8 *)(&__MBAR[0x008934]))
#define MCF_UART3_UOP1                (*(vuint8 *)(&__MBAR[0x008938]))
#define MCF_UART3_UOP0                (*(vuint8 *)(&__MBAR[0x00893C]))
#define MCF_UART_UMR(x)               (*(vuint8 *)(&__MBAR[0x008600+((x)*0x100)]))
#define MCF_UART_USR(x)               (*(vuint8 *)(&__MBAR[0x008604+((x)*0x100)]))
#define MCF_UART_UCSR(x)              (*(vuint8 *)(&__MBAR[0x008604+((x)*0x100)]))
#define MCF_UART_UCR(x)               (*(vuint8 *)(&__MBAR[0x008608+((x)*0x100)]))
#define MCF_UART_URB(x)               (*(vuint8 *)(&__MBAR[0x00860C+((x)*0x100)]))
#define MCF_UART_UTB(x)               (*(vuint8 *)(&__MBAR[0x00860C+((x)*0x100)]))
#define MCF_UART_UIPCR(x)             (*(vuint8 *)(&__MBAR[0x008610+((x)*0x100)]))
#define MCF_UART_UACR(x)              (*(vuint8 *)(&__MBAR[0x008610+((x)*0x100)]))
#define MCF_UART_UISR(x)              (*(vuint8 *)(&__MBAR[0x008614+((x)*0x100)]))
#define MCF_UART_UIMR(x)              (*(vuint8 *)(&__MBAR[0x008614+((x)*0x100)]))
#define MCF_UART_UBG1(x)              (*(vuint8 *)(&__MBAR[0x008618+((x)*0x100)]))
#define MCF_UART_UBG2(x)              (*(vuint8 *)(&__MBAR[0x00861C+((x)*0x100)]))
#define MCF_UART_UIP(x)               (*(vuint8 *)(&__MBAR[0x008634+((x)*0x100)]))
#define MCF_UART_UOP1(x)              (*(vuint8 *)(&__MBAR[0x008638+((x)*0x100)]))
#define MCF_UART_UOP0(x)              (*(vuint8 *)(&__MBAR[0x00863C+((x)*0x100)]))

/* Bit definitions and macros for MCF_UART_UMR */
#define MCF_UART_UMR_BC(x)            (((x)&0x03)<<0)
#define MCF_UART_UMR_PT               (0x04)
#define MCF_UART_UMR_PM(x)            (((x)&0x03)<<3)
#define MCF_UART_UMR_ERR              (0x20)
#define MCF_UART_UMR_RXIRQ            (0x40)
#define MCF_UART_UMR_RXRTS            (0x80)
#define MCF_UART_UMR_SB(x)            (((x)&0x0F)<<0)
#define MCF_UART_UMR_TXCTS            (0x10)
#define MCF_UART_UMR_TXRTS            (0x20)
#define MCF_UART_UMR_CM(x)            (((x)&0x03)<<6)
#define MCF_UART_UMR_PM_MULTI_ADDR    (0x1C)
#define MCF_UART_UMR_PM_MULTI_DATA    (0x18)
#define MCF_UART_UMR_PM_NONE          (0x10)
#define MCF_UART_UMR_PM_FORCE_HI      (0x0C)
#define MCF_UART_UMR_PM_FORCE_LO      (0x08)
#define MCF_UART_UMR_PM_ODD           (0x04)
#define MCF_UART_UMR_PM_EVEN          (0x00)
#define MCF_UART_UMR_BC_5             (0x00)
#define MCF_UART_UMR_BC_6             (0x01)
#define MCF_UART_UMR_BC_7             (0x02)
#define MCF_UART_UMR_BC_8             (0x03)
#define MCF_UART_UMR_CM_NORMAL        (0x00)
#define MCF_UART_UMR_CM_ECHO          (0x40)
#define MCF_UART_UMR_CM_LOCAL_LOOP    (0x80)
#define MCF_UART_UMR_CM_REMOTE_LOOP   (0xC0)
#define MCF_UART_UMR_SB_STOP_BITS_1   (0x07)
#define MCF_UART_UMR_SB_STOP_BITS_15  (0x08)
#define MCF_UART_UMR_SB_STOP_BITS_2   (0x0F)

/* Bit definitions and macros for MCF_UART_USR */
#define MCF_UART_USR_RXRDY            (0x01)
#define MCF_UART_USR_FFULL            (0x02)
#define MCF_UART_USR_TXRDY            (0x04)
#define MCF_UART_USR_TXEMP            (0x08)
#define MCF_UART_USR_OE               (0x10)
#define MCF_UART_USR_PE               (0x20)
#define MCF_UART_USR_FE               (0x40)
#define MCF_UART_USR_RB               (0x80)

/* Bit definitions and macros for MCF_UART_UCSR */
#define MCF_UART_UCSR_TCS(x)          (((x)&0x0F)<<0)
#define MCF_UART_UCSR_RCS(x)          (((x)&0x0F)<<4)
#define MCF_UART_UCSR_RCS_SYS_CLK     (0xD0)
#define MCF_UART_UCSR_RCS_CTM16       (0xE0)
#define MCF_UART_UCSR_RCS_CTM         (0xF0)
#define MCF_UART_UCSR_TCS_SYS_CLK     (0x0D)
#define MCF_UART_UCSR_TCS_CTM16       (0x0E)
#define MCF_UART_UCSR_TCS_CTM         (0x0F)

/* Bit definitions and macros for MCF_UART_UCR */
#define MCF_UART_UCR_RXC(x)           (((x)&0x03)<<0)
#define MCF_UART_UCR_TXC(x)           (((x)&0x03)<<2)
#define MCF_UART_UCR_MISC(x)          (((x)&0x07)<<4)
#define MCF_UART_UCR_NONE             (0x00)
#define MCF_UART_UCR_STOP_BREAK       (0x70)
#define MCF_UART_UCR_START_BREAK      (0x60)
#define MCF_UART_UCR_BKCHGINT         (0x50)
#define MCF_UART_UCR_RESET_ERROR      (0x40)
#define MCF_UART_UCR_RESET_TX         (0x30)
#define MCF_UART_UCR_RESET_RX         (0x20)
#define MCF_UART_UCR_RESET_MR         (0x10)
#define MCF_UART_UCR_TX_DISABLED      (0x08)
#define MCF_UART_UCR_TX_ENABLED       (0x04)
#define MCF_UART_UCR_RX_DISABLED      (0x02)
#define MCF_UART_UCR_RX_ENABLED       (0x01)

/* Bit definitions and macros for MCF_UART_UIPCR */
#define MCF_UART_UIPCR_CTS            (0x01)
#define MCF_UART_UIPCR_COS            (0x10)

/* Bit definitions and macros for MCF_UART_UACR */
#define MCF_UART_UACR_IEC             (0x01)

/* Bit definitions and macros for MCF_UART_UISR */
#define MCF_UART_UISR_TXRDY           (0x01)
#define MCF_UART_UISR_RXRDY_FU        (0x02)
#define MCF_UART_UISR_DB              (0x04)
#define MCF_UART_UISR_RXFTO           (0x08)
#define MCF_UART_UISR_TXFIFO          (0x10)
#define MCF_UART_UISR_RXFIFO          (0x20)
#define MCF_UART_UISR_COS             (0x80)

/* Bit definitions and macros for MCF_UART_UIMR */
#define MCF_UART_UIMR_TXRDY           (0x01)
#define MCF_UART_UIMR_RXRDY_FU        (0x02)
#define MCF_UART_UIMR_DB              (0x04)
#define MCF_UART_UIMR_COS             (0x80)

/* Bit definitions and macros for MCF_UART_UIP */
#define MCF_UART_UIP_CTS              (0x01)

/* Bit definitions and macros for MCF_UART_UOP1 */
#define MCF_UART_UOP1_RTS             (0x01)

/* Bit definitions and macros for MCF_UART_UOP0 */
#define MCF_UART_UOP0_RTS             (0x01)

/********************************************************************/

#endif /* __MCF548X_UART_H__ */
