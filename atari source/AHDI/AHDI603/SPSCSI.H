;+
; Edit History
;
; Jul-11-90	ml.	Created this for files that need to know SCSI
;			 addresses.
;-

; Conditional assembly
SPSCDMA		equ	1		; 1: do Sparrow SCSI

bSPSCSI		equ	$88	; base of SCSI bus

; SCSI Interface (NCR 5380) for READ operations
SPSCSIDB	equ	bSPSCSI+0	; SCSI data bus
SPSCSIICR	equ	bSPSCSI+1	; initiator command register
SPSCSIMR	equ	bSPSCSI+2	; mode register
SPSCSITCR	equ	bSPSCSI+3	; target command register
SPSCSICR	equ	bSPSCSI+4	; current SCSI control register
SPSCSIDSR	equ	bSPSCSI+5	; DMA status register
SPSCSIIDR	equ	bSPSCSI+6	; input data register
SPSCSIREI	equ	bSPSCSI+7	; reset error / interrupt


; SCSI Interface (NCR 5380) for WRITE operations
SPSCSIODR	equ	bSPSCSI+0	; output data register
;SPSCSIICR	equ	bSPSCSI+1	; initiator command register
;SPSCSIMR	equ	bSPSCSI+2	; mode register
;SPSCSITCR	equ	bSPSCSI+3	; target command register
SPSCSIISR	equ	bSPSCSI+4	; ID select register
SPSCSIDS	equ	bSPSCSI+5	; start DMA send
SPSCSIDTR	equ	bSPSCSI+6	; start DMA target receive
SPSCSIDIR	equ	bSPSCSI+7	; start DMA initiator receive


; Macros to talk to the NCR5380 through the ACSI DMA chip

.macro	RSCSI	srcreg,dst	; read from specified register
	move.w	\srcreg,WDL
	move.w	WDC,\dst
.endm

.macro	WSCSI	val,dstreg	; write to specified register
	move.w	\dstreg,WDL
	move.w	\val,WDC
.endm


;+
; Rstdelay()
;	After talking to the DMA chip in a way that may reset it, 
; we need a 8 8Mhz clocks (ie. 1 microsec) delay, before we can
; talk to the chip again.
;-
.macro	RSTDELAY
	tst.b	GPIP			; delay for 1 microsec
	tst.b	GPIP			; this amounts to 16 16Mhz clocks
	tst.b	GPIP
	tst.b	GPIP
.endm


