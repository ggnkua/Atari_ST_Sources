; DSP-Registernamen als Konstanten.
; Als INCLUDEFILE fÅr alle Proggys.
; 12.7.1993 by BDC/AURA.

PBC		equ	$ffe0				; Port B - Bus Control Register
PCC		equ	$ffe1				; Port C - Control Register
PBDDR	equ	$ffe2				; Port B - Data Direction Register
PCDDR	equ	$ffe3				; Port C - Data Direction Register
PBD		equ	$ffe4				; Port B - Data Register
PCD		equ	$ffe5				; Port C - Data Register
HCR		equ	$ffe8				; Host Control Register
HSR		equ	$ffe9				; Host Status Register
HRX		equ	$ffeb				; Host Receive/Transmit Register
HTX		equ	HRX
CRA		equ	$ffec				; SSI Control Register A
CRB		equ	$ffed				; SSI Control Register B
_SR		equ	$ffee				; SSI Status/Timeslot Register
TSR		equ	_SR
RX		equ	$ffef				; SCI Receive/Transmit Data Register
TX		equ	RX
SCR		equ	$fff0				; SCI Interface Control Register
SSR		equ	$fff1				; SCI Interface Status Register
SCCR	equ	$fff2				; SCI Control Register
STXA	equ	$fff3				; SCI Transmit Data Adress Register
SRXLOW	equ	$fff4				; SCI Low-Rec/Xmit Data Register
STXLOW	equ	SRXLOW
SRXMID	equ	$fff5				; SCI Mid-Rec...
STXMID	equ	SRXMID
SRXHI	equ	$fff6				; SCI Hi-Rec...
STXHI	equ	SRXHI
BCR		equ	$fffe				; Port-A: Bus Control Register
IPR		equ	$ffff				; Interrupt Priority Register