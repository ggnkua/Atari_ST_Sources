;+
; Edit History
;
; Jul-11-90	ml.	Created this for files that need to know SCSI
;			 addresses.
;-

; Conditional assembly for SCSI
SCDMA	equ	1			; 0: not doing SCSI DMA
ODMA	equ	0			; 0: not using Old DMA controller
SCFRDMA	equ	1			; 0: not doing SCSI DMA to fast RAM
VI	equ	0			; 1: SCSI vectored-interrupts enabled

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



