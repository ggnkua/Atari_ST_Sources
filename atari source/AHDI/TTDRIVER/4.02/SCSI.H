;+
; Edit History
;
; Jul-11-90	ml.	Created this for files that need to know SCSI
;			 addresses.
;-

; Definitions
REGBASE	equ	1	; most are on odd part of data bus
REGSTEP	equ	2	; most registers are on word boundaries

; 68901 MFP definitions

MFP	equ	$FFFFFA01

;GPIP	equ	MFP+$00
AER	equ	MFP+$02
DDR	equ	MFP+$04
IERA	equ	MFP+$06
ERB	equ	MFP+$08
IPRA	equ	MFP+$0A
IPRB	equ	MFP+$0C
ISRA	equ	MFP+$0E
ISRB	equ	MFP+$10
IMRA	equ	MFP+$12
IMRB	equ	MFP+$14
VR	equ	MFP+$16
TACR	equ	MFP+$18
TBCR	equ	MFP+$1A
TCDCR	equ	MFP+$1C
TADR	equ	MFP+$1E
TBDR	equ	MFP+$20
TCDR	equ	MFP+$22
TDDR	equ	MFP+$24
SCR	equ	MFP+$26
UCR	equ	MFP+$28
RSR	equ	MFP+$2A
TSR	equ	MFP+$2C
UDR	equ	MFP+$2E

MFP2	equ	$FFFFFA81
GPIP2	equ	MFP2+$00
AER2	equ	MFP2+$02
DDR2	equ	MFP2+$04
IERA2	equ	MFP2+$06
IERB2	equ	MFP2+$08
IPRA2	equ	MFP2+$0A
IPRB2	equ	MFP2+$0C
ISRA2	equ	MFP2+$0E
ISRB2	equ	MFP2+$10
IMRA2	equ	MFP2+$12
IMRB2	equ	MFP2+$14
VR2	equ	MFP2+$16
TACR2	equ	MFP2+$18
TBCR2	equ	MFP2+$1A
TCDCR2	equ	MFP2+$1C
TADR2	equ	MFP2+$1E
TBDR2	equ	MFP2+$20
TCDR2	equ	MFP2+$22
TDDR2	equ	MFP2+$24
SCR2	equ	MFP2+$26
UCR2	equ	MFP2+$28
RSR2	equ	MFP2+$2A
TSR2	equ	MFP2+$2C
UDR2	equ	MFP2+$2E
	
; GPIP2 BIT ASSIGNMENTS
GPIP2SCSI	equ	7	; SCSI xIRQ
GPIP2RTC	equ	6	; RTC IRQ
GPIP25		equ	5	; 
GPIP2CHGL	equ	4	; ChangeLine
GPIP2RI		equ	3	; Ring Indicator (SCC Port B)
GPIP2DBE	equ	2	; DMA Bus Error
LED1		equ	1	; debug LED
LED0		equ	0	; debug LED

; SCSI Interface (NCR 5380) for READ operations
bSCSI	equ	$FFFF8780+REGBASE
SCSIDB	equ	bSCSI+($00*REGSTEP)	; current SCSI data bus
SCSIICR	equ	bSCSI+($01*REGSTEP)	; initiator command register
SCSIMR	equ	bSCSI+($02*REGSTEP)	; mode register
SCSITCR	equ	bSCSI+($03*REGSTEP)	; target command register
SCSICR	equ	bSCSI+($04*REGSTEP)	; current SCSI control register
SCSIDSR	equ	bSCSI+($05*REGSTEP)	; DMA status register
SCSIIDR	equ	bSCSI+($06*REGSTEP)	; input data register
SCSIREI	equ	bSCSI+($07*REGSTEP)	; reset error / interrupt

; SCSI Interface (NCR 5380) for WRITE operations
SCSIODR	equ	bSCSI+($00*REGSTEP)	; output data register
;SCSIICR	bSCSI+($01*REGSTEP)	; initiator command register
;SCSIMR		bSCSI+($02*REGSTEP)	; mode register
;SCSITCR	bSCSI+($03*REGSTEP)	; target command register
SCSIISR	equ	bSCSI+($04*REGSTEP)	; ID select register
SCSIDS	equ	bSCSI+($05*REGSTEP)	; start DMA send
SCSIDTR	equ	bSCSI+($06*REGSTEP)	; start DMA target receive
SCSIDIR	equ	bSCSI+($07*REGSTEP)	; start DMA initiator receive

; SCSI DMA Controller
bSDMAPTR	equ	$FFFF8701
bSDMACNT	equ	$FFFF8709
SDMARES		equ	$FFFF8710
SDMACTL		equ	$FFFF8714	; WORD

DMAOUT	equ	01
DMAIN	equ	00
DMAENA	equ	02
DMADIS	equ	00

SCSIID	equ	6		; our (host) SCSI ID


