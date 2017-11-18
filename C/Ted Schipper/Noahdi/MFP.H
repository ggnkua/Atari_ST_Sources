/*
    File: MFP.H               Atari ST 68901 MFP device.

    Oct 1988. V1.00 T.H. Schipper

*/
/* References:
 
 * Atari Toolkit page 984 
 * MOSTEK data book page VI-103 
*/
/*
Copyright (c) 1988 - 1991 by Ted Schipper.

Permission to use, copy, modify, and distribute this software and its
documentation for any purpose and without fee is hereby granted,
provided that the above copyright notice appear in all copies and that
both that copyright notice and this permission notice appear in
supporting documentation.

This software is provided AS IS with no warranties of any kind.  The author
shall have no liability with respect to the infringement of copyrights,
trade secrets or any patents by this file or any part thereof.  In no
event will the author be liable for any lost revenue or profits or
other special, indirect and consequential damages.
*/

#define MFP_ADDR 0xFFFA00L      /* MFP device addres */

#define MFP      ((struct mfp_chip *) MFP_ADDR)


 struct mfp_chip {
                  char reg[48]; /* MFP registers are on odd bytes */
                 } ;

/* MFP register names */

#define GPIP    reg[1]          /* general purpose I/O (interrupt port) */
#define AER     reg[3]          /* active edge register */
#define DDR     reg[5]          /* data direction register */
#define IERA    reg[7]          /* interrupt enable register A */
#define IERB    reg[9]          /* interrupt enable register B */
#define IPRA    reg[11]         /* interrupt pending register A */
#define IPRB    reg[13]         /* interrupt pending register B */
#define ISRA    reg[15]         /* interrupt in service register A */
#define ISRB    reg[17]         /* interrupt in service register B */
#define IMRA    reg[19]         /* interrupt mask register A */
#define IMRB    reg[21]         /* interrupt mask register B */
#define VR      reg[23]         /* vector base address register */
#define TACR    reg[25]         /* timer A control register */
#define TBCR    reg[27]         /* timer B control register */
#define TCDCR   reg[29]         /* timer C + B control register */
#define TADR    reg[31]         /* timer A data register */
#define TBDR    reg[33]         /* timer B data register */
#define TCDR    reg[35]         /* timer C data register */
#define TDDR    reg[37]         /* timer D data register */
#define SCR     reg[39]         /* synchronous character register */
#define UCR     reg[41]         /* USART control register */
#define RSR     reg[43]         /* receiver status register */
#define TSR     reg[45]         /* transmitter status register */
#define UDR     reg[47]         /* USART data register */


/* names of General Purpose IO Port bits: */

#define IO_CBSY     0x01        /* Centronics Busy */
#define IO_DCD      0x02        /* RS232 Data Carrier Detect */
#define IO_CTS      0x04        /* RS232 Clear To Send */
#define IO_GPU      0x08        /* GPU Operation done ???? What's this */
#define IO_AINT     0x10        /* ACIA interrupt (KB or MIDI) */
#define IO_DINT     0x20        /* DMA interrupt (FDC or HDC) */
#define IO_RI       0x40        /* RS232 Ring Indicator */
#define IO_MONO     0x80        /* Monochrome Monitor Detect */


/* names of interrupts in register A: */

#define IRA_TIMB    0x01        /* Timer B */
#define IRA_TERR    0x02        /* RS232 Transmitter Error */
#define IRA_TRDY    0x04        /* RS232 Transmitter Ready */
#define IRA_RERR    0x08        /* RS232 Receiver Error */
#define IRA_RRDY    0x10        /* RS232 Receiver Ready */
#define IRA_TIMA    0x20        /* Timer A */
#define IRA_RI      0x40        /* GPIO6 RS232 RI */
#define IRA_MONO    0x80        /* GPIO7 MONO Detect */


/* names of interrupts in register B: */

#define IRB_CBSY    0x01        /* GPIO0 Centronics Busy */
#define IRB_DCD     0x02        /* GPIO1 RS232 DCD */
#define IRB_CTS     0x04        /* GPIO2 RS232 CTS */
#define IRB_GPU     0x08        /* GPIO3 GPU Operation done ???? what's this */
#define IRB_TIMD    0x10        /* Timer D */
#define IRB_TIMC    0x20        /* Timer C */
#define IRB_AINT    0x40        /* GPIO4 AINT: ACIA's */
#define IRB_DINT    0x80        /* GPIO5 DINT: DMA devices (HDC/FDC) */

/* bits in VR: */

#define V_S         0x08        /* Software end-of-interrupt mode */
#define V_V         0xF0        /* 4 most significant bits of int vector */

/* bits in TCR A and B */

#define TAB_STOP    0x00        /* Timer Stopped */
#define TAB_D004    0x01        /* Delay mode, /004 prescale */
#define TAB_D010    0x02        /* Delay mode, /010 prescale */
#define TAB_D016    0x03        /* Delay mode, /016 prescale */
#define TAB_D050    0x04        /* Delay mode, /050 prescale */
#define TAB_D064    0x05        /* Delay mode, /064 prescale */
#define TAB_D100    0x06        /* Delay mode, /100 prescale */
#define TAB_D200    0x07        /* Delay mode, /200 prescale */
#define TAB_ECM     0x08        /* Event Count Mode */
#define TAB_P004    0x09        /* Pulse Width mode, /004 prescale */
#define TAB_P010    0x0A        /* Pulse Width mode, /010 prescale */
#define TAB_P016    0x0B        /* Pulse Width mode, /016 prescale */
#define TAB_P050    0x0C        /* Pulse Width mode, /050 prescale */
#define TAB_P064    0x0D        /* Pulse Width mode, /064 prescale */
#define TAB_P100    0x0E        /* Pulse Width mode, /100 prescale */
#define TAB_P200    0x0F        /* Pulse Width mode, /200 prescale */
#define TAB_RST     0x10        /* Reset Timer, force timer output low */


/* bits in TCR C+D */

#define TD_STOP     0x00        /* Timer D Stopped */
#define TD_D004     0x01        /* Delay mode, D /004 prescale */
#define TD_D010     0x02        /* Delay mode, D /010 prescale */
#define TD_D016     0x03        /* Delay mode, D /016 prescale */
#define TD_D050     0x04        /* Delay mode, D /050 prescale */
#define TD_D064     0x05        /* Delay mode, D /064 prescale */
#define TD_D100     0x06        /* Delay mode, D /100 prescale */
#define TD_D200     0x07        /* Delay mode, D /200 prescale */
#define TC_STOP     0x00        /* Timer C Stopped */
#define TC_D004     0x10        /* Delay mode, C /004 prescale */
#define TC_D010     0x20        /* Delay mode, C /010 prescale */
#define TC_D016     0x30        /* Delay mode, C /016 prescale */
#define TC_D050     0x40        /* Delay mode, C /050 prescale */
#define TC_D064     0x50        /* Delay mode, C /064 prescale */
#define TC_D100     0x60        /* Delay mode, C /100 prescale */
#define TC_D200     0x70        /* Delay mode, C /200 prescale */

/* bits in UCR: */

#define U_NU        0x01        /* Not Used */
#define U_EVEN      0x02        /* Even / Odd parity */
#define U_PAR       0x04        /* Parity Enable / Disable */
/* Start / Stop bit Control */
#define U_SYNC      0x00        /* Synchrone */
#define U_ASYNC1    0x08        /* Asynchrone, 1 stop bit */
#define U_ASYNC1_5  0x10        /* Asynchrone, 1.5 stop bit */
#define U_ASYNC2    0x18        /* Asynchrone, 2 stop bits */
/* Word Length Contol */
#define U_D8        0x00        /* Word length 8 data bits */
#define U_D7        0x20        /* Word length 7 data bits */
#define U_D6        0x40        /* Word length 6 data bits */
#define U_D5        0x60        /* Word length 5 data bits */

#define U_DIV16     0x80        /* Divide Clock by 16 */

/* bits in RSR: */

#define R_RE        0x01        /* Receiver Enable */
#define R_SSE       0x02        /* Sync Strip Enable */
#define R_MCIP      0x04        /* Match / Character in Progress */
#define R_BREAK     0x08        /* Break Detected */
#define R_FS        0x08        /* Found / Search Detected */
#define R_FE        0x10        /* Frame Error */
#define R_PE        0x20        /* Parity Error */
#define R_OE        0x40        /* Overrun Error */
#define R_BF        0x80        /* Buffer Full */

/* bits in TSR: */

#define T_TE        0x01        /* Transmitter Enable */
/* Disabled transmitter configure bits HIGH and LOW */
#define T_HIZ       0x00        /* Output in Tristate */
#define T_LOW       0x02        /* Output LOW */
#define T_HIGH      0x04        /* Output HIGH */
#define T_LOOP      0x06        /* Loop Back Mode */

#define T_BREAK     0x08        /* Break Detected */
#define T_END       0x10        /* End of Transmission */
#define T_AT        0x20        /* Auto Turnaround */
#define T_UE        0x40        /* Underrun Error */
#define T_BE        0x80        /* Buffer Empty */

