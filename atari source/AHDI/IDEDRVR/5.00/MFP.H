;+
; Oct-04-90	ml.	Created this to share by files that need to
;			 know addresses in MFP.
;-


; Definitions
REGBASE		equ	1	; most are on odd part of data bus
REGSTEP		equ	2	; for those that are on word boundaries
REGLSTEP	equ	4	; for those that are on long word boundaries


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
	


