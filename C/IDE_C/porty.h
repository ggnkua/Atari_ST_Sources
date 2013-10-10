#include <iom64v.h>

#define	OnRealHW  1

// signals on PORTE
#define	   ClrBit(Where,Which)	(Where &= ~Which)
#define	   SetBit(Where,Which)	(Where |= Which)

//----------------------------------------------------------
#define	   IDE	   PORTE		// IDE control signals

#define	   IDE_WR	(1 << 0)
#define	   IDE_RD	(1 << 1)
#define	   IDE_RDY	(1 << 2)
#define	   IDE_A2	(1 << 3)
#define	   IDE_A1	(1 << 4)
#define	   IDE_A0	(1 << 5)
#define	   IDE_CS1	(1 << 6)
#define	   IDE_CS0	(1 << 7)

#define IDE_DATA_low_o  PORTF
#define IDE_DATA_low_i  PINF

#define IDE_DATA_hi_o  PORTA
#define IDE_DATA_hi_i  PINA
//----------------------------------------------------------
#define IDE_RESET	(1 << 7)		// on PORTB

//----------------------------------------------------------
// Signals on PORTD
#define	   ACSI_o	   PORTD   	// ACSI control signals
#define	   ACSI_i	   PIND   	// ACSI control signals

//#define    ACSI_A1 	  (1 << 0)   // INT 0
#define    ACSI_ACK	  (1 << 0)   // INT 0
#define    ACSI_CS	  (1 << 1)   // INT 1
//#define  Rx1		  (1 << 2)   // UART debug
//#define  Tx1		  (1 << 3)   // UART debug
#define	   ACSI_RST	  (1 << 4)
//#define	   ACSI_ACK	  (1 << 5)	 
#define	   ACSI_A1	  (1 << 5)	 
#define	   ACSI_INT	  (1 << 6)
#define	   ACSI_DRQ	  (1 << 7)
 
#define ACSI_DATA_o	  PORTC
#define ACSI_DATA_i	  PINC
//----------------------------------------------------------

/*
;         7   6   5  4  3  2   1  0 
;        CS0 CS1 A0 A1 A2 RDY RD WR
; DDRE    1   1   1  1  1  0   1  1    = 0xfb
;      0 = vstup, 1 = vystup
;---------------------------------------------
;         7    6    5    4   3    2    1   0 
;        DRQ  INT  ACK  RST TxD  RxD  CS  A1
; DDRD    1    1    0    0   1    0    0   0    = 0xc8
;      0 = vstup, 1 = vystup
;---------------------------------------------

.EQU aDATA = PORTC				; D0-7  
*/
