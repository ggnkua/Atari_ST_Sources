*********************************************************************************
* Register definitions for the 8390 chip central to a NE2000 device		*
*										*
*	Copyright 2001 Dr. Thomas Redelberger					*
*	Use it under the terms of the GNU General Public License		*
*	(See file COPYING.TXT)							*
*										*
* Credits:									*
* Although written in 68000 assembler this source code is based on the source	*
* module 8390.h of Linux originally due to the authors ... 			*
*										*
* Tabsize 8, developed with DEVPAC assembler 2.0.				*
*********************************************************************************
* $Id: 8390.i 1.1 2002/03/24 13:53:06 Thomas Exp Thomas $
*


**** 8390 definitions taken from Linux 8390.h ***********************************

* Generic NS8390 register definitions.

* We only use one Tx slot. Should always use two Tx slots to get back-to-back transmits.

TX_PAGES	EQU	6
ETHER_ADDR_LEN	EQU	6


* Some generic ethernet register configurations.
E8390_TX_IRQ_MASK	EQU	$0a		; For register EN0_ISR
E8390_RX_IRQ_MASK	EQU	$05
E8390_RXCONFIG		EQU	$04		; EN0_RXCR: broadcasts:yes, multicast:no, errors:no
E8390_RXOFF		EQU	$20		; EN0_RXCR: Accept no packets
E8390_TXCONFIG		EQU	$00		; EN0_TXCR: Normal transmit mode
E8390_TXOFF		EQU	$02		; EN0_TXCR: Transmitter off

*  Register accessed at EN_CMD, the 8390 base addr. 
E8390_STOP	EQU	$01		; Stop and reset the chip
E8390_START	EQU	$02		; Start the chip, clear reset
E8390_TRANS	EQU	$04		; Transmit a frame
E8390_RREAD	EQU	$08		; Remote read  DMA on
E8390_RWRITE	EQU	$10		; Remote write DMA on
E8390_RSEND	EQU	$18		; Remote send  DMA on
E8390_NODMA	EQU	$20		; Remote DMA off
E8390_PAGE0	EQU	$00		; Select page chip registers
E8390_PAGE1	EQU	$40		; using the two high-order bits
E8390_PAGE2	EQU	$80		; Page 3 is invalid.

E8390_CMD	EQU	$00		; The command register (for all pages)
* Page 0 register offsets.
EN0_CLDALO	EQU	$01		; Low byte of current local dma addr  RD
EN0_STARTPG	EQU	$01		; Starting page of ring bfr WR
EN0_CLDAHI	EQU	$02		; High byte of current local dma addr  RD
EN0_STOPPG	EQU	$02		; Ending page +1 of ring bfr WR
EN0_BOUNDARY	EQU	$03		; Boundary page of ring bfr RD WR
EN0_TSR		EQU	$04		; Transmit status reg RD
EN0_TPSR	EQU	$04		; Transmit starting page WR
EN0_NCR		EQU	$05		; Number of collision reg RD
EN0_TCNTLO	EQU	$05		; Low  byte of tx byte count WR
EN0_FIFO	EQU	$06		; FIFO RD
EN0_TCNTHI	EQU	$06		; High byte of tx byte count WR
EN0_ISR		EQU	$07		; Interrupt status reg RD WR
EN0_CRDALO	EQU	$08		; low byte of current remote dma address RD
EN0_RSARLO	EQU	$08		; Remote start address reg 0
EN0_CRDAHI	EQU	$09		; high byte, current remote dma address RD
EN0_RSARHI	EQU	$09		; Remote start address reg 1
EN0_RCNTLO	EQU	$0a		; Remote byte count reg WR
EN0_RCNTHI	EQU	$0b		; Remote byte count reg WR
EN0_RSR		EQU	$0c		; rx status reg RD
EN0_RXCR	EQU	$0c		; RX configuration reg WR
EN0_TXCR	EQU	$0d		; TX configuration reg WR
EN0_COUNTER0	EQU	$0d		; Rcv alignment error counter RD
EN0_DCFG	EQU	$0e		; Data configuration reg WR
EN0_COUNTER1	EQU	$0e		; Rcv CRC error counter RD
EN0_IMR		EQU	$0f		; Interrupt mask reg WR
EN0_COUNTER2	EQU	$0f		; Rcv missed frame error counter RD

* Bits in EN0_ISR - Interrupt status register
ENISR_RX	EQU	$01		; Receiver, no error
ENISR_TX	EQU	$02		; Transmitter, no error
ENISR_RX_ERR	EQU	$04		; Receiver, with error
ENISR_TX_ERR	EQU	$08		; Transmitter, with error
ENISR_OVER	EQU	$10		; Receiver overwrote the ring
ENISR_COUNTERS	EQU	$20		; Counters need emptying
ENISR_RDC	EQU	$40		; remote dma complete
ENISR_RESET	EQU	$80		; Reset completed (this does never fire an int)
ENISR_ALL	EQU	$00		; no Interrupts ($3f would be normal)

* Bits in EN0_DCFG - Data config register
ENDCFG_WTS	EQU	$01		; word transfer mode selection

* Page 1 register offsets.
EN1_PHYS	EQU	$01		; This board's physical enet addr RD WR
EN1_CURPAG	EQU	$07		; Current memory page RD WR
EN1_MULT	EQU	$08		; Multicast filter mask array (8 bytes) RD WR

* Bits in received packet status byte and EN0_RSR
ENRSR_RXOK	EQU	$01		; Received a good packet
ENRSR_CRC	EQU	$02		; CRC error
ENRSR_FAE	EQU	$04		; frame alignment error
ENRSR_FO	EQU	$08		; FIFO overrun
ENRSR_MPA	EQU	$10		; missed pkt
ENRSR_PHY	EQU	$20		; physical/multicase address
ENRSR_DIS	EQU	$40		; receiver disable. set in monitor mode
ENRSR_DEF	EQU	$80		; deferring

* Transmitted packet status, EN0_TSR
ENTSR_PTX	EQU	$01		; Packet transmitted without error
ENTSR_ND	EQU	$02		; The transmit wasn't deferred.
ENTSR_COL	EQU	$04		; The transmit collided at least once.
ENTSR_ABT	EQU	$08		; The transmit collided 16 times, and was deferred.
ENTSR_CRS	EQU	$10		; The carrier sense was lost.
ENTSR_FU	EQU	$20		; A "FIFO underrun" occurred during transmit.
ENTSR_CDH	EQU	$40		; The collision detect "heartbeat" signal was lost.
ENTSR_OWC	EQU	$80		; There was an out-of-window collision.


******** Start of the NEx000 and clones board specific code *********************

*NE_BASE	EQU	 (dev->base_addr)	; that is fixed here
NE_CMD		EQU	$00
NE_DATAPORT	EQU	$10		; NatSemi-defined port window offset
NE_RESET	EQU	$1f		; Issue a read to reset, a write to clear
NE_IO_EXTENT	EQU	$20

NE1SM_START_PG	EQU	$20		; First page of TX buffer
	IFNE	0
NE1SM_STOP_PG	EQU	$40		; Last page +1 of RX ring (NE1000 with 8K)
	ELSEIF
NE1SM_STOP_PG	EQU	$60		; Last page +1 of RX ring (NE1000 with 16K)
	ENDC

NESM_START_PG	EQU	$40		; First page of TX buffer
	IFNE	0
NESM_STOP_PG	EQU	$80		; Last page +1 of RX ring
	ELSEIF
* NE2000 cards in 8bit mode seem to use only half of memory (use only 8 from 16 bits internally?)
NESM_STOP_PG	EQU	$60		; Last page +1 of RX ring
	ENDC



*********************************************************************************
