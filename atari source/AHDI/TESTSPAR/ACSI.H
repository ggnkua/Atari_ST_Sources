;  Hardware definitions for ACSI DMA channel
WDC		equ	$ffff8604
WDL		equ	$ffff8606
WDSR		equ	$ffff860f	; Select Register
WDCWDL		equ	WDC		; used for long writes
XWDL		equ	WDL-WDC		; offset from wdc to wdl

DMAHI		equ	$ffff8609
DMAMID		equ	DMAHI+2
DMALOW		equ	DMAMID+2

STA		equ	3		; Internal DMA status bit
					;  in the select register

