**********************
***		   ***
*** System equates ***
***		   ***
**********************


*** Exception vectors

HBL_ISR		equ	$68
VBL_ISR		equ	$70
TimerD_ISR	equ	$110
TimerC_ISR	equ	$114
KBD_ISR		equ	$118
FDC_ISR		equ	$11c
HDC_ISR		equ	$11c
TimerB_ISR	equ	$120
TimerA_ISR	equ	$134


*** Memory

MemConfig	equ	$ffff8001


*** Display

VidBaseHi	equ	$ffff8201
VidBaseLo	equ	$ffff8203
VidAddrHi	equ	$ffff8205
VidAddrMid	equ	$ffff8207
VidAddrLo	equ	$ffff8209
SyncMode	equ	$ffff820a

Palette0	equ	$ffff8240
Palette1	equ	$ffff8242
Palette2	equ	$ffff8244
Palette3	equ	$ffff8246
Palette4	equ	$ffff8248
Palette5	equ	$ffff824a
Palette6	equ	$ffff824c
Palette7	equ	$ffff824e
Palette8	equ	$ffff8250
Palette9	equ	$ffff8252
Palette10	equ	$ffff8254
Palette11	equ	$ffff8256
Palette12	equ	$ffff8258
Palette13	equ	$ffff825a
Palette14	equ	$ffff825c
Palette15	equ	$ffff825e


*** DMA/Disk

DMAdata		equ	$ffff8604
DMAcntl		equ	$ffff8606
DMABaseHi	equ	$ffff8609
DMABaseMid	equ	$ffff860b
DMABaseLo	equ	$ffff860d


*** Sound

PSGread		equ	$ffff8800
PSGreg		equ	$ffff8800
PSGwrite	equ	$ffff8802
PSGportB	equ	$ffff8802


*** MK68901 (MFP)

GPIP		equ	$fffffa01
AER		equ	$fffffa03
DDR		equ	$fffffa05
IERA		equ	$fffffa07
IERB		equ	$fffffa09
IPRA		equ	$fffffa0b
IPRB		equ	$fffffa0d
ISRA		equ	$fffffa0f
ISRB		equ	$fffffa11
IMRA		equ	$fffffa13
IMRB		equ	$fffffa15
VR		equ	$fffffa17
TACR		equ	$fffffa19
TBCR		equ	$fffffa1b
TCDCR		equ	$fffffa1d
TADR		equ	$fffffa1f
TBDR		equ	$fffffa21
TCDR		equ	$fffffa23
TDDR		equ	$fffffa25
SCR		equ	$fffffa27
UCR		equ	$fffffa29
RSR		equ	$fffffa2b
TSR		equ	$fffffa2d
UDR		equ	$fffffa2f


*** MC6850

KBD_CNTL	equ	$fffffc00
KBD_DATA	equ	$fffffc02
MIDI_CNTL	equ	$fffffc04
MIDI_DATA	equ	$fffffc06
