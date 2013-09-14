;                                     ;
;      /| __    _    /  __            ;
;     / |/ _ __| \  <  <              ;
;    /__|\ // _| / / \  \ |/ \  |     ;
;   <   | \ \ /|< <_  >  >|\_/|\|     ;
;    \  |    \ | \ \ / _/ |   | |     ;
;     \        |    /                 ;
;                                     ;
; fixed inits                         
; Vsynced routine-script 
; min vsync..
; freezer (undo)

	TEXT

SENDKB	MACRO
.\@Wait:btst	#1,$fffffc00.w
	beq.s	.\@Wait
	move.b	#\1,$fffffc02.w
	ENDM

	move.l	a7,a5
	move.l	4(a5),a5	;basepage address
	move.l	$c(a5),d0	;prg lenght
	add.l	$14(a5),d0	;data lenght
	add.l	$1c(a5),d0	;bss lenght
	add.l	#$100,d0	;basepage lenght
	move.l	d0,-(sp)	;memory to be reserved
	move.l	a5,-(sp)	;start of memory area to be reserved
	move.w	#0,-(sp)
	move.w	#$4a,-(sp)	;setblock function
	trap	#1
	lea	12(sp),sp
	tst.l	d0
	beq.s	okie
memerror:
	clr.w	-(sp)
	trap	#1
okie:

;	Reserve memory

	move.l	#memory,-(sp)
	move.w	#$48,-(sp)
	trap	#1
	addq.l	#6,sp
	tst.l	d0
	ble.s	memerror
	move.l	d0,address.freemem

	pea 	Supervisor(pc)
	move.w 	#$26,-(sp)
	trap 	#14
	addq.l 	#6,sp

;	Vapauta muisti

	move.l	address.freemem(pc),-(sp)
	move.w	#$49,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w 	-(sp)
	trap 	#1
	 
Supervisor:
	move	#1,vsync_max
	bsr	CheckCPU	; Check for Falcon and processor
	bmi	Out		; CPU Required: 68020/68332, 68030, 68040

*	move.b	$ffff8006.w,d0
*	lsr.b	#7,d0
*	bcs.s	.rgb
*	
*	jmp	Out
*.rgb:

	move.w 	#$2700,sr
	lea	Stack(pc),a0
	move.l	sp,(a0)

	bsr 	StoreSystem	; Completely kills OS

	bsr 	InitSystem	; Installs new system
	move.b	#$03,$fffffc00.w	; IKBD RESET
	move.b	#$96,$fffffc00.w	; IKBD RESET
	SENDKB	$12
	SENDKB	$15
	move.w 	#$2300,sr
;-------------------------------------------------------------

Main:	
;	bsr	vsync2

	lea 	Adr_Screen1(pc),a0
	move.l	(a0),d0
	ror.w	#8,d0
	move.l 	d0,$ffff8200.w
	ror.w	#8,d0
	move.b 	d0,$ffff820d.w

	bsr vsync2

	cmp.b 	#$1d,$fffffc02.w	;testiaika.. maskaa ulos lopuulisesta..
	seq 	Test_Time		;
	bne.s 	.nt1			;
	clr.l	$ffff9800.w		;
.nt1
	cmp.b	#$61,$fffffc02.w
	bne.s	.froze
	move.l	#$20000000,$ffff9800.w
	bra.s	.froze2
.froze

	bsr 	Demo

.froze2
	tst.w 	Test_Time(pc)		;
	beq.s 	.nt2			;
	move.l 	#$500c0050,$ffff9800.w	;
.nt2					;
	tst.w 	Space_Pressed(pc)
	beq.s 	Main

;-----------------------------------------------------------------------

Reset:	move.w 	#$2700,sr

	move.w	#$0000,$ffff8900.w	;nollaa soundi DMA

	move.l	Stack(pc),sp

	move.l 	Error(pc),d0
	beq.s 	NoError
	move.l 	d0,$ffff9800.w
.esc	btst	#0,$fffffc00.w
	beq.s	.esc
	cmp.b 	#$01,$fffffc02.w
	bne.s 	.esc
NoError
	bsr 	RestoreSystem

	move.w 	#$2500,sr
	move.l 	#$fcfc00fc,$ffff9800.w
	move.w 	#$2300,sr
	move.b	#$03,$fffffc00.w	; IKBD RESET
	move.b	#$96,$fffffc00.w	; IKBD RESET
	SENDKB	$8

Out	rts	

		CNOP	0,4
Stack:			dc.l	0
Test_Time		dc.w 	0
Space_Pressed		dc.w 	0
Error:			dc.l 	0
*****************************************************************************		
StoreSystem:
	bsr	Store68030
	bsr	StoreVectors
	bsr	StoreMFP
 	bsr	StoreVidel
	bsr	StorePalette
	bsr	FlushKeys
	move.b	#%00000001,$fffffa07.w
	move.b	#%11000000,$fffffa09.w
	move.b	#%00000001,$fffffa13.w
	move.b	#%11000000,$fffffa15.w
	move.l	#key_r,$118.w
	rts

RestoreSystem:
	bsr	RestoreVectors
	bsr	Restore68030
	bsr	RestoreMFP
	bsr	RestoreVidel
	bsr	RestorePalette
	bsr	FlushKeys
	rts

	CNOP	0,4
Adr_Screen1:	dc.l 	0
Adr_Screen2:	dc.l 	0

Empty:	dc.l	0

CheckCPU:
	moveq	#4,d0
	jmp	.cpu(pc,d0.w*2)
.cpu	EQU	*-4
	bra.w	.fail
	movec	cacr,d1
	or.w	#$0909,d1
	move.l	#$8000,d0
	movec	d0,cacr
	movec	cacr,d0
	lea	Processor(pc),a0
	tst.w	d0
	smi	d2
	and.b	#1,d2
	move.b	d2,(a0)
	movec	d1,cacr
	tst.b	(a0)
	beq.w	.030
	OPT	P=68040
	cpusha	bc
.030
	movec	vbr,a1
	move.l	sp,d0

	move.l	$08(a1),d2		;BERR
	move.l	$2c(a1),d3		;LINEF
	move.l	#.BusError,$8(a1)
	move.l	#.NoMMULineF,$2c(a1)

	tst.w	$ffff9200.w		;CHECK SDMA...
	tst.w	$ffff8a00.w		;...BLiTTER...
	tst.w	$ffff8930.w		;...CROSSBAR...
	tst.l	$ffffa204.w		;...DSP...
	tst.l	$ffff82c0.w		;...VIDEL...
	tst.l	$ffff9800.w		;...VIDEL PALETTE
					;Falcon for sure
	tst.b	(a0)
	bgt.s	.040
	lea	Empty(pc),a2
	OPT	P=68030
	pmove.l	tc,(a2)	
.040
	move.l	d2,$08(a1)
	move.l	d3,$2c(a1)

	move.l	d0,sp
	moveq	#0,d0
	rts

.fail2	move.l	d0,sp
	move.l	d2,$08(a1)
	move.l	d3,$2c(a1)
.fail	moveq	#-1,d0
	rts

.NoMMU:	st	(a0)
	moveq	#0,d0
	rts

.BusError:
	move.l	#.fail2,2(sp)
	rte

.NoMMULineF:
	move.l	#.NoMMU,2(sp)
	rte

;-1:	020/332 (030 w/o MMU)
;0:	030
;1:	040
Processor:	dc.w	0

InitSystem:
;############################	SET 68030/040 REGISTERS

	move.b	Processor(pc),d7
	bgt.s	.040
	move.l 	#$101!$808!$2000,d0	DATA/INST -ENABLE -FLUSH -WA
	movec 	d0,cacr
	tst.b	d7
	bmi.s	.common			020 or 332
	lea	Empty(pc),a0
	OPT	P=68030
	pmove.l	(a0),tc
	pmove.l	(a0),tt0
	pmove.l	(a0),tt1
	bra.s	.common

.040	move.l	#$80008000,d0	DATA/INST -ENABLE
	movec	d0,cacr
	OPT	P=68040
	cpusha	bc		FLUSH

.common	moveq	#0,d0
	movec	d0,vbr

;############################	16 MHz CPU/BLiTTER

	move.b 	#$05,$ffff8007.w

;############################  MFP	; All have been cleared!

;	move.b	#$xx,$fffffa03.w	; Active Edge Register
	move.b	#$40,$fffffa17.w	; Automatic End of Interrupt

;############################ VECTORS	;All point to _null

	move.l 	#BusError,$8.w
	move.l 	#IllegalInstruction,$10.w
	move.l 	#DivisionByZero,$14.w
	move.l	#ChkException,$18.w
	move.l	#TRAPcc,$1c.w
	move.l	#LineF,$2c.w

	move.l 	#HBI,$68.w
	move.l 	#VBI,$70.w

;############################	SET DISPLAY
middlesetscreen
	move.w	#$2300,sr
	bsr	vsync
	move.w	#$2700,sr

	move.l 	Adr_Screen1(pc),d0
	ror.w 	#8,d0
	move.l 	d0,$ffff8200.w
	ror.w	#8,d0
	move.b 	d0,$ffff820d.w

	move.b	$ffff8006.w,d0
	lsr.b	#7,d0
	bcs.s	.rgb
	beq	reset			; To the error routine!
.vga	move.l	pointerVGA(pc),a6
	bra	.mon_ok
.rgb	move.l	pointerTV(pc),a6
.mon_ok:
	movem.l	(a6),d0-d7/a0-a1
	clr.l 	$ffff828e.w
	movem.l	d0-d2,$ffff8282.w
	movem.l	d3-d5,$ffff82a2.w
	move.l 	d6,$ffff82c0.w

	move.b 	#$02,$ffff820a.w
	move.w 	a1,$ffff8266.w	;true colors
	move.w 	d7,$ffff8210.w	; Length of line in words
	move.w 	a0,$ffff820e.w		; Modulo

.mono	clr.w	$ffff8264.w		; HSCROLL

; muut setupit..

	rts
;-------------------------

pointervga	dc.l	displaysettingsvga
pointertv	dc.l	displaysettingstv

DisplaySettingsVGA:
.HHT	SET 	$0c6		; Horizontal Hold Timer
.HBB	SET 	$08d		; Horizontal Border Begin (Border Blank)
.HBE	SET 	$015		; Horizontal Border End (Border Blank)
.HDB	SET 	$29a		; Horizontal Display Begin
.HDE	SET 	$07b		; Horizontal Display End
.HSS	SET 	$096		; Horizontal Synchro Start

.VFT	SET 	$4e3		; (62500)/Hz)!1 ; V FREQUENCY
.VBB	SET 	$3ff		; V BORDER BLANK
.VBE	SET 	$03f		; ($3ff-$3f)/4 = 240 lines
.VDB	SET 	$03f		; V DISPLAY SIZE
.VDE	SET 	$3ff		; ($3ff-$3f)/4 = 240 lines
.VSS	SET 	$4d5		; V SYNCHRO START (<FREQUENCY!)
.VCLK	SET	$186		; Video Clock: Bits 5/6 Stretch VGA Vertically
.VCO	SET	$005		; Video Control
.WIDE	set	320		;screen wide
.modulo	set	0		;screen modulo
.VMODE	set	$100		;screen mode (true)
; Video Control VGA Bits			3 2 1 0
;	Horizontal Resolution-------------------+-+ + +
;		00: SUPER LORES (160 Pixels)	    | |
;		01: LORES (320 Pixels)		    | |
;		10: HIRES (640 Pixels)		    | |
;		    (VGA HiRes does not support	    | |
;		    True Color mode.)		    | |
;	Interlace-----------------------------------' |
;		To enable interlacing, set VFT	      |
;		bit 0 to logic 0.		      |
;	Vertical Resolution---------------------------'
;		0: 400 lines
;		1: 200 lines

	dc.w	.HHT&$1ff,.HBB&$1ff,.HBE&$1ff,.HDB&$1ff,.HDE&$1ff,.HSS&$1ff
	dc.w	.VFT&$7ff,.VBB&$7ff,.VBE&$7ff,.VDB&$7ff,.VDE&$7ff,.VSS&$7ff
	dc.w	.VCLK&$1ff,.VCO&$00f
	dc.l	.wide,.modulo,.vmode

DisplaySettingsTV:
.HHT	SET 	$fe	*fe	; Horizontal Hold Timer
.HBB	SET 	$cb	*cb	; Horizontal Border Begin
.HBE	SET 	$27	*27	; Horizontal Border End
.HDB	SET 	$2e	*1c	; Horizontal Display Begin
.HDE	SET 	$8f	*7d	; Horizontal Display End
.HSS	SET 	$d8	*d8	; Horizontal Synchro Start

.VFT	SET 	$271	*271	; (31250/Hz!1) ; V FREQUENCY
.VBB	SET 	$265	*265	; V BORDER BLANK
.VBE	SET 	$2f	*2f	; ($265-$02f)/2 = 283 LINES
.VDB	SET 	$48	*57	; V DISPLAY SIZE (256 lines..)
.VDE	SET 	$248	*237	; ($237-$057)/2 = 240 LINES
.VSS	SET 	$26b	*26b	; V SYNCHRO START (<FREQUENCY!)
.VCLK	SET	$182	*181	; Video Clock
.VCO	SET	$000		; Video Control
.WIDE	set	320		;screen wide (words)
.modulo	set	0		;screen modulo
.VMODE	set	$100		;screen mode (true)
; Video Control TV Bits				3 2 1 0
;	Horizontal Resolution-------------------+-+ + +
;		00: LORES (320 Pixels)		    | |
;		01: HIRES (640 Pixels)		    | |
;		10: SUPER HIRES (1280 Pixels)	    | |
;		    (shires seems to work with	    | |
;		     16 colors only (???))	    | |
;	Interlace-----------------------------------' |
;		To enable interlacing, set VFT	      |
;		bit 0 to logic 0.		      |
;	Vertical Resolution---------------------------'
;		0: 200 lines
;		1: 100 lines

	dc.w	.HHT&$1ff,.HBB&$1ff,.HBE&$1ff,.HDB&$1ff,.HDE&$1ff,.HSS&$1ff
	dc.w	.VFT&$3ff,.VBB&$3ff,.VBE&$3ff,.VDB&$3ff,.VDE&$3ff,.VSS&$3ff
	dc.w	.VCLK&$1ff,.VCO&$00f
	dc.l	.wide,.modulo,.vmode

Store68030:
	lea 	Old68030(pc),a0
	move.w 	$ffff8006.w,(a0)+
	movec 	cacr,d0
	movec	vbr,d1
	movec	msp,d2
	movec	usp,d3
	movem.l d0-d3,(a0)
	tst.b	Processor(pc)
	bne.s	.no_mmu
	OPT	P=68030
	lea	OldMMU(pc),a0
	pmove.l	tc,(a0)
	pmove.l	tt0,4(a0)
	pmove.l	tt1,8(a0)
.no_mmu:
	rts

Restore68030:
	lea 	Old68030(pc),a0
	move.w 	(a0)+,$ffff8006.w
	movem.l (a0)+,d0-d3
	tst.b	Processor(pc)
	bgt.s	.040
	or.w	#$808,d0
.040	movec 	d0,cacr
	movec	d1,vbr
	movec	d2,msp
	movec	d3,usp
	tst.b	Processor(pc)
	ble.s	.030
	OPT	P=68040
	cpusha	bc
.030	tst.b	Processor(pc)
	bne.s	.no_mmu
	lea	OldMMU(pc),a0
	OPT	P=68030
	pmove.l	(a0),tc
	pmove.l	4(a0),tt0
	pmove.l	8(a0),tt1
.no_mmu	rts

StoreVidel:
	lea 	OldVidel(pc),a0
	move.l 	$ffff8200.w,(a0)+
	move.l 	$ffff820a.w,(a0)+
	move.l 	$ffff820e.w,(a0)+
	move.b 	$ffff8260.w,(a0)+
	move.b	$ffff8265.w,(a0)+
	move.w 	$ffff8266.w,(a0)+
	lea	$ffff8282.w,a1
	moveq	#4-1,d0
.xa	move.l 	(a1)+,(a0)+			; Horizontal Registers
	dbra	d0,.xa
	lea	$ffff82a2.w,a1
	moveq	#3-1,d0	
.xb	move.l	(a1)+,(a0)+			; Vertical Registers
	dbra	d0,.xb
	move.l 	$ffff82c0.w,(a0)+		; VMODE
	rts

RestoreVidel:
	lea 	OldVidel(pc),a0
	move.l 	(a0)+,$ffff8200.w
	move.l 	(a0)+,$ffff820a.w
	move.l 	(a0)+,$ffff820e.w
	move.b 	(a0)+,d0
	move.b	(a0)+,$ffff8265.w
	move.w 	(a0)+,$ffff8266.w
	lea	$ffff8282.w,a1
	moveq	#4-1,d7
.xa	move.l	(a0)+,(a1)+
	dbra	d7,.xa
	lea	$ffff82a2.w,a1
	moveq	#3-1,d7
.xb	move.l	(a0)+,(a1)+
	dbra	d7,.xb

	move.l 	(a0)+,$ffff82c0.w

	move.w	$ffff82c0.w,d0
	btst 	#8,d0
	bne.s 	.f			;
	move.b 	d0,$ffff8260.w		; ST Resolution
.f	rts

StoreMFP:
	lea	$fffffa00.w,a0
	lea	OldMFP(pc),a1
	moveq	#$30/4-1,d7
.lp	move.l	(a0)+,(a1)+		;Transfer...
	dbra	d7,.lp
	clr.l	$fffffa06.w		;tapa enablet..
	rts
RestoreMFP:
	lea	$fffffa00.w,a1
	lea	OldMFP(pc),a0
	moveq	#$30/4-1,d7
.lp	move.l	(a0)+,(a1)+		;Transfer...
	dbra	d7,.lp
	move.b	#192,$fffffa23.w	;fix keyrepeat (timerC data)

	rts

StoreVectors:
	lea	$8.w,a0			; Store Vectors $008-$3fc
	lea	OldVectors(pc),a1
	bra.s	MoveVectors
RestoreVectors:
	lea	OldVectors(pc),a0
	lea	$8.w,a1			; Restore Vectors $008-$3fc
MoveVectors:
	move.w	#($400-$008)/4-1,d7
.lp	move.l	(a0)+,(a1)+
***	move.l	#_null,(a0)+
	dbra	d7,.lp
	rts

StorePalette:
	lea 	$ffff8240.w,a0
	lea	OldPalette(pc),a1
	lea	$ffff9800.w,a2
	lea	32(a1),a3
	bra.s	MovePalette
RestorePalette:
	lea	OldPalette(pc),a0
	lea 	$ffff8240.w,a1
	lea	32(a0),a2
	lea	$ffff9800.w,a3
MovePalette:
	moveq 	#8-1,d0
.lp1	move.l 	(a0),(a1)+
	clr.l	(a0)+
	dbf 	d0,.lp1
	move.w 	#16-1,d0		;256 orig
.lp2	move.l 	(a2),(a3)+
	clr.l	(a2)+
	dbf 	d0,.lp2
	rts

FlushKeys:
	moveq	#128-1,d1
	bra.s	.start
.lp	move.b	$fffffc02.w,d0
.start	move.b	$fffffc00.w,d0
	btst	#0,d0
	dbeq	d1,.lp
	bne.s	.reset
	rts
.reset	;move.b	#$xx,$fffffc00.w	; IKBD RESET
	rts

	CNOP	0,4
Old68030:	ds.l	5
OldMMU:		ds.l	3
OldVidel:	ds.l	12
OldMFP:		ds.b	$30
OldVectors:	ds.b	$400-$8
		ds.l	1
OldPalette:	ds.l	8+256
		ds.l	1
BusError:
	move.l 	#$fc000000,Error		; Red
	jmp 	Reset
IllegalInstruction:
	move.l 	#$00fc0000,Error		; Green
	jmp 	Reset
DivisionByZero:
	move.l 	#$000000fc,Error		; Blue
	jmp 	Reset

ChkException:
TRAPcc:
LineF:	rte

HBI:	or.w	#$0300,(sp)			;Kill HBI
_null:	rte


VBI:	movem.l	d0-a6,-(sp)
	lea	N_Vbl(pc),a0
	addq.w 	#1,(a0)
	addq.l	#1,$4ba.w		;fake 200hz clock for dsp traps..
	addq.l	#1,$462.w		;system vbl counter

	move.b	#0,$fffffa1b.w
	move.l	raster_adr,$120.w
	move.b	raster_data,$fffffa21.w
	move.b	raster_control,$fffffa1b.w

	cmp.b 	#$3b,$fffffc02.w	;f1 paniikkiexit
	bne.s 	.nspace			;
	st 	Space_Pressed		;
.nspace					;
	cmp.b 	#$3c,$fffffc02.w	;f2 skippaus
	bne.s 	.nspace2			;
	addq.w	#1,activepoint
.nspace2					;
	tst.w 	Test_Time(pc)
	beq.s 	.nt69
	clr.l 	$ffff9800.w
.nt69
	move.l	musa_vbl(pc),a0
	jsr	(a0)
	move.l	own_vbl(pc),a0
	jsr	(a0)
	movem.l	(sp)+,d0-a6
raster_null
	rte

nullie:	rts

musa_vbl:	dc.l	nullie
own_vbl:	DC.L	nullie
N_Vbl:		dc.w 	0
vsync_max	dc.w	0
raster_adr	dc.l	raster_null
raster_data	dc.w	0
raster_control	dc.w	0
address.freemem: DC.L	0
Vsync:
	move.w	d0,-(sp)
	move.w	N_vbl(pc),d0
.vs	cmp	n_vbl(pc),d0
	beq.s	.vs
	move.w	#0,n_vbl
	move.w	(sp)+,d0
	rts

vsync2:
	movem.l	d0/a0,-(sp)
	lea	N_Vbl(pc),a0
	move.w	(a0),d0
.vs	cmp.w 	(a0),d0
	beq.s 	.vs
	move.w	vsync_max,d0
.vs2	cmp.w	(a0),d0
	bgt.s	.vs2
	move.w	#0,(a0)
	movem.l	(sp)+,d0/a0
	rts

; realtime sin calculation by xnt

xcos:	add.w	#16384,d0
xsin:

.tulos	EQUR	d1
.angle	EQUR	d2
.data1	EQUR	d3
.data2	EQUR	d4
.flag	EQUR	d5

	move.w	d0,.angle

	bclr	#15,.angle
	sne	.flag
	bclr	#14,.angle
	beq.s	.ok
	eor.w	#$3fff,.angle
	addq.w	#1,.angle
.ok
	ext.l	.angle
	mulu.l	#$6487f,.data2:.angle
	move.w	.data2,.angle
	swap	.angle

	move.l	.angle,.tulos
	move.l	.angle,.data2

	mulu.l	.angle,.data1:.angle		;x^2
	move.w	.data1,.angle
	swap	.angle

	mulu.l	.angle,.data1:.data2		;x^3
	move.w	.data1,.data2
	swap	.data2
	move.l	.data2,.data1
	mulu.l	#$2aaaaaaa,.data1:.data1	;/3!
	sub.l	.data1,.tulos

	mulu.l	.angle,.data1:.data2
	move.w	.data1,.data2
	swap	.data2
	move.l	.data2,.data1
	mulu.l	#$02222222,.data1:.data1	;/5!
	add.l	.data1,.tulos

	mulu.l	.angle,.data1:.data2
	move.w	.data1,.data2
	swap	.data2
	mulu.l	#$000d00d0,.data2:.data2	;/7!
	sub.l	.data2,.tulos

	tst.b	.flag
	beq.s	.pos
	neg.l	.tulos
.pos	asr.l	.tulos
	rts

;	lue nappaimia

key_r:
	movem.l	d0/d1/a0,-(sp)
	lea	keytab,a0
	move.b	$fffffc02.w,d0
	cmp.b	#$fd,d0
	beq.s	.joy1
	move.b	d0,d1
	spl	d0
	and.w	#$7f,d1
	move.b	d0,(a0,d1.w)
	movem.l	(sp)+,d0/d1/a0
	rte
.joy1:
	move.l	#joy_r1,$118.w
	movem.l	(sp)+,d0/d1/a0
	rte

joy_r1:
	move.b	$fffffc02.w,joy1bits
	move.l	#joy_r2,$118.w
	rte
joy_r2:
	move.b	$fffffc02.w,joy2bits
	move.l	#key_r,$118.w
	rte

keytab:		DCB.B	256,0
joy1bits:	DC.W	0
joy2bits:	DC.W	0

;--------------------------------  

