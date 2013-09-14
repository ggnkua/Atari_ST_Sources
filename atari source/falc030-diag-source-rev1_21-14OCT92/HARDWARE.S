.if !(^^defined HARDWARE_I)
HARDWARE_I = 1
*	HARDWARE EQUATES

userint	equ	$100		;start of user interrupt vectors

mconfig	equ	$ffff8000	;memory configuration register

*       system control unit     odd byte * ADDED 31JAN92 : RWS :NEEDED ???
sim     equ     $ff8e01         ;system interrupt mask
sis     equ     $ff8e03         ;interrupt state
sint1   equ     $ff8e05         ;generate int 1
svmei   equ     $ff8e07         ;vme interrupter b0 = vme int 3
scugp1  equ     $ff8e09         ;general purpose
svmeim  equ     $ff8e0d         ;vme int mask b1-b7
svmes   equ     $ff8e0f         ;vme state

SPConfig	equ	$ffff8006	; sparrow config switches : 02JAN92 : RWS
STConfig	equ	$ffff9200	; configuration switches. : 19DEC91 : RWS
SPControl	equ	$ffff8007	; control register
JoyReg1		equ	$ffff9202	; joysticks
JoyReg2		equ	$ffff9203	; joysticks
  
blt	equ	$ffff8a00		;blitter

*       SCC
sccbase equ     $ff8c81
sccac   equ     0               ;a control
sccad   equ     2               ;a data
sccbc   equ     4               ;b control
sccbd   equ     6               ;b data
sccdmap equ     $ff8c01         ;dma ptr (4 bytes @odd)
sccdmab equ     $ff8c09         ;dma byte count (4 bytes @odd)
sccdmar equ     $ff8c10         ;dma data residue (2 words)
sccdmac equ     $ff8c15         ;dma control (byte)
*               bit 7=bus error, 6=byte count 0, 1=dma enable, 0=direction

*       SCSI
sdmap   equ     $ff8701         ;dma ptr (4 bytes @odd)
sdmab   equ     $ff8709         ;dma byte count (4 bytes @odd)
*       SCSI controller (word)
scsidat equ     $ff8780         ; data reg
scsiicr equ     $ff8782         ; initiator cmd reg
scsimod equ     $ff8784         ; mode reg
scsitcr equ     $ff8786         ; target cmd reg
scsiids equ     $ff8788         ; id select
scsidma equ     $ff878a         ; dma start/status
scsitrx equ     $ff878c         ; dma target receive
scsiirx equ     $ff878e         ; dma initiator receive

*       RTC 	* ADDED : 24JAN92 : RWS
rtcadd  equ     $ff8961         ; address reg
rtcdat  equ     $ff8963         ; data reg

*	video registers
v_bas_h	equ	$ffff8201		;video base high
v_bas_m	equ	$ffff8203		;video base mid 
v_bas_l	equ	$ffff820d
vadcnth	equ	$ffff8205		;video address counter
vadcntm	equ	$ffff8207
vadcntl	equ	$ffff8209
synmod	equ	$ffff820a		;sync mode
palette	equ	$ffff8240		;start of color palette
v_shf_mod equ	$ffff8260		;00=4 plane, 01=2 plane, 10=1 plane
		
* for SP part of video.s

sppalette	equ	$ff9800

v_hoffset equ	$ffff820e		; added : 11FEB92 : RWS
v_pixscroll equ	$ffff8264
v_spshiftmd equ	$ffff8266
v_HC	equ	$ffff8280
v_HHT	equ	$ffff8282
v_HBB	equ	$ffff8284
v_HBE	equ	$ffff8286
v_HDB	equ	$ffff8288
v_HDE	equ	$ffff828a
v_HSS	equ	$ffff828c
v_HFS	equ	$ffff828e
v_HEE	equ	$ffff8290

v_VC	equ	$ffff82a0
v_VFT	equ	$ffff82a2
v_VBB	equ	$ffff82a4
v_VBE	equ	$ffff82a6
v_VDB	equ	$ffff82a8
v_VDE	equ	$ffff82aa
v_VSS	equ	$ffff82ac

v_DLW	equ	$ffff8210
v_VMC	equ	$ffff82c0
v_VTC	equ	$ffff82c2

* NEW SDMA REGISTERS...
GP0 = 0
GP1 = 1
GP2 = 2

*	DMA control
dskctl	equ	$ffff8604		;disk controller access
fifo	equ	$ffff8606		;DMA mode control, status
dmactl	equ	$ffff8606
dmahigh	equ	$ffff8609		;DMA base high
dmamid	equ	$ffff860b
dmalow	equ	$ffff860d

*	Programmable Sound Generator
psgsel	equ	$ffff8800		;register select (W)
psgrd	equ	$ffff8800		;read data
psgwr	equ	$ffff8802		;write data
porta	equ	14

*************************************************************************
*									*
*	68901 multifunction peripheral chip equates			*
*	(interrupt controller,timers,serial i/o)			*
*									*
*************************************************************************

*	register and base addresses

mfp	equ	$fffffa01	;base address, +1 offset !!!!!!!!

*	system interrupt register offsets

gpip	equ	0			;general purpose i/o
aer	equ	2			;active edge register
ddr	equ	4			;data direction register
iera	equ	6			;interrupt enable register a
ierb	equ	8			;interrupt enable register b
ipra	equ	10			;interrupt pending register a
iprb	equ	12			;interrupt pending register b
isra	equ	14			;interrupt in-service register a
isrb	equ	16			;interrupt in-service register b
imra	equ	18			;interrupt mask register a
imrb	equ	20			;interrupt mask register b
vr	equ	22			;vector register

*	system timer registers offsets

tacr	equ	24			;timer a control register
tbcr	equ	26			;timer b control register
tcdcr	equ	28			;timer c and d control register
tadr	equ	30			;timer a data register
tbdr	equ	32			;timer b data register
tcdr	equ	34			;timer c data register
tddr	equ	36			;timer d data register

*	timer relative locations
atimer	equ	0
btiber	equ	1
ctimer	equ	2
dtimer	equ	3

*	rs232/rs422/async/sync serial i/o registers offsets

scr	equ	38			;sync character register
ucr	equ	40			;usart control register
rsr	equ	42			;receiver status register
tsr	equ	44			;transmitter status register
udr	equ	46			;usart data register

*	6850 ACIA
keyboard equ	$fffffc00
midi	equ	$fffffc04
comstat	equ	$0		;command/status register
iodata	equ	2		;data register

rsetacia equ	%00000011	;reset
div64	equ	%00000010	;clock /64
div16	equ	%00000001	;clock /16

protocol equ	%00010100	;8 bits/1 stop/no parity

rtsld	equ	%00000000	;rts low/int disabled
rtsle	equ	%00100000	;rts low/int enabled
rtshd	equ	%01000000	;rts high/int disabled
rtsbrk	equ	%01100000	;rts low/int disabled/break

intron	equ	%10000000	;interrupts enabled
introff	equ	%00000000	;interrupts disabled

*	ACIA status
rdrf	equ	%00000001
tdre	equ	%00000010
dcd	equ	%00000100
cts	equ	%00001000
fe	equ	%00010000
ovrn	equ	%00100000
pe	equ	%01000000
irq	equ	%10000000

* printer and joystick stuff (from joy.s) : 2JAN92 : RWS
 
gamefr  equ     $ff9201
gamec31 equ     $ff9202
gamec20 equ     $ff9203
paddle  equ     $ff9211
gun_x   equ     $ff9220
gun_y   equ     $ff9222

* NEW CODEC SDMA VARS

AUXACTRL	equ	$ffff8938
AUXAIN		equ	$ffff893c
AUXBCTRL	equ	$ffff893a
CLOCKSCALE	equ	$ffff8934
DACRECCTRL	equ	$ffff8936
DATAMXREC	equ	$ffff8932
DATAMXSRC	equ	$ffff8930
GPIOC		equ	$ffff8940
GPIOD		equ	$ffff8942
PLAYMODECR	equ	$ffff8920
SNDCTRL		equ	$ffff8900

.endif

