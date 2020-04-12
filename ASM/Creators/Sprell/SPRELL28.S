Start:
	;Opt	d-
*****

ret_sndinit

	Move.l	#tvs_Blink,tvs_Music
	Move.l	#tri_Blink,tri_Music
	Bsr.w	Clear_BSS
	Bsr.w	InitST
	Clr.b	$ffff8e21.w
	Jsr	Init_Data
	Bsr.w	Precalc
	Clr.l	cnt_Time

EventLoop:

;head:
	Move.l	cnt_Event,d0
	Lea	Event_Queue,a0
	Move.l	(a0,d0.l),d1
	Move.l	d1,NextEvent

	Lea	Event_Heads,a0
	Move.l	(a0,d0.w),d1
	Beq.s	.nohead
	Move.l	d1,a0
	Jsr	(a0)
.nohead

Main:
	Bsr.w	Wait_VBL

	Lea	Event_Table,a0
	Move.l	cnt_Event,d0
	Move.l	(a0,d0.l),d0
	Beq.s	ForceQuit
	Move.l	d0,a1
	Jsr	(a1)
	
	Move.l	cnt_Time,d0
	Cmp.l	NextEvent,d0
	Blo.s	Main
;tail:
	Move.l	cnt_Event,d0
	Lea	Event_Tails,a0
	Move.l	(a0,d0.l),d0
	Beq.s	.notail
	Move.l	d0,a0
	Jsr	(a0)
.notail
	Addq.l	#4,cnt_Event
	Bra.w	EventLoop	

ForceQuit:
	Bsr.w	AllBlack
	Move.l	cnt_Event,d0
	Lea	Event_Tails,a0
	Move.l	(a0,d0.l),d0
	Beq.s	.notail
	Move.l	d0,a0
	Jsr	(a0)
.notail	

Quit:
	Bra.w	ExitST
Pause:
	Move.l	cnt_Time,d0
	Move.l	d0,d1
DonePause:
	Rts

*****
Event_Queue:
	Dc.l	5700,0
	Dc.l	90,500,858,1250,2020,2402,2920,3300,5720,0
	
Event_Table:
	;Dc.l	evt_AkkaPic,0
	Dc.l	evt_PlasmaRot1,0
	Dc.l	evt_Dummy,evt_Creds,evt_Syli1,evt_eqDots1
	Dc.l	evt_AkkaPic,evt_PlasmaRot1,evt_PlasmaRot2
	Dc.l	evt_PlasmaRot3,evt_Dummy,0

Event_Heads:
	;Dc.l	head_AkkaPic,0
	Dc.l	head_PlasmaRot1,0
	Dc.l	head_Dummy,head_Creds,head_Syli1,head_eqDots1
	Dc.l	head_AkkaPic,head_PlasmaRot1,head_PlasmaRot2
	Dc.l	head_PlasmaRot3,head_Dummy,0

Event_Tails:
	;Dc.l	tail_AkkaPic,0
	Dc.l	tail_PlasmaRot1,0
	Dc.l	tail_Dummy,tail_Creds,tail_Syli1,tail_eqDots1
	Dc.l	tail_AkkaPic,tail_PlasmaRot1,tail_PlasmaRot2
	Dc.l	tail_PlasmaRot3,tail_Dummy,0

cnt_Event	Dc.l	0
NextEvent	Dc.l	0

*****

head_eqDots1:
	Move.l	pal_Shade,a0
	Movem.l	(a0),d0-7
	Movem.l	d0-7,$ffff8240.w
	Rts

tail_eqDots1:
	Rts

evt_eqDots1:
	Bsr.w	Scroll_Background
	Bsr.w	OnePlane_Clear_Screen
	Bsr.w	eqDots1PutPixels
	Bsr.w	ScreenSwap
	;Move.w	#-1,NoWaitVBL
	Rts

head_Syli1:
	Bsr.w	AllBlack
	Bsr.w	Setup_Shading
	Bsr.w	ScreenSwap
	Bsr.w	Set_Physical
	Bsr.w	Wait_VBL
	Move.l	pal_Shade,a0
	Movem.l	(a0),d0-7
	Movem.l	d0-7,$ffff8240.w
	Move.l	Logical2,Temp_Logical
	Rts

tail_Syli1:
	Rts

evt_Syli1:
	Bsr.w	Scroll_Background
	Bsr.w	OnePlane_Clear_Screen
	Bsr.w	Syli1PutPixels
	Bsr.w	ScreenSwap
	;Move.w	#-1,NoWaitVBL
	Rts
	
*****

head_PlasmaRot1:
	Move.w	#-9,xmovement
	Move.w	#6,ymovement
	Move.w	#10,Wobble1
	Move.w	#-1,Wobble2
	Move.l	txt_Sykle,CurrentTexture
	Move.l	PlasmaScreen,Physical
	Bsr.w	Set_Physical
	Bsr.w	Wait_VBL
	Move.l	#PlasmaHBL1,NextTimerB
	Bsr.w	Init_TimerB
	Move.l	#vsub_PlasmaRot1,SubVBI
	Rts

evt_PlasmaRot1:
	Bsr.w	Mkshit
	Bsr.w	PaletteSwap
	Rts

tail_PlasmaRot1:
	Bsr.w	Restore_TimerB
	Clr.l	SubVBI
	Rts

head_PlasmaRot2:
	Move.w	#5,xmovement
	Move.w	#-9,ymovement
	Move.w	#8,Wobble1
	Move.w	#1,Wobble2
	Move.l	txt_Sykle,CurrentTexture
	Move.l	PlasmaScreen,Physical
	Bsr.w	Set_Physical
	Bsr.w	Wait_VBL
	Move.l	#PlasmaHBL1,NextTimerB
	Bsr.w	Init_TimerB
	Move.l	#vsub_PlasmaRot1,SubVBI
	Rts


evt_PlasmaRot2:
	Bsr.w	Mkshit
	Bsr.w	PaletteSwap
	Rts
tail_PlasmaRot2:
	Bsr.w	Restore_TimerB
	Clr.l	SubVBI
	Rts

vsub_PlasmaRot1:
	Move.l	PhysRGB,TimerB_data
	Clr.w	TimerB_data+4	;line count
	Rts

head_PlasmaRot3:
	Move.w	#-2,xmovement
	Move.w	#2,ymovement
	Move.w	#8,Wobble1
	Move.w	#-1,Wobble2

	Move.l	txt_Brun,CurrentTexture
	Move.l	PlasmaScreen,Physical
	Bsr.w	Set_Physical
	Bsr.w	Wait_VBL
	Move.l	#PlasmaHBL1,NextTimerB
	Bsr.w	Init_TimerB
	Move.l	#vsub_PlasmaRot1,SubVBI
	Rts

evt_PlasmaRot3:
	Bsr.w	Mkshit
	Bsr.w	PaletteSwap
	Rts


tail_PlasmaRot3:
	Bsr.w	Restore_TimerB
	Clr.l	SubVBI
	Move.w	d0,SR
	Rts

*****

head_AkkaPic:
	Bsr.w	AllBlack
	Bsr.w	ScreenSwap
	Bsr.w	Set_Physical
	Bsr.w	Wait_VBL
	Bsr.w	Mask_AkkaPic

	Move.l	pic_Akka,a0
	Lea	34(a0),a0
	Move.l	Logical1,a1
	Move.l	Logical2,a2
	Move.l	Physical,a3
	Move.w	#8000-1,d7
.show	
	Move.l	(a0)+,d0
	Move.l	d0,(a1)+
	Move.l	d0,(a2)+
	Move.l	d0,(a3)+

	Dbf	d7,.show

	Move.l	pic_Akka,a0
	Move.w	#$55d,2(a0)
	Movem.l	2(a0),d0-7
	Movem.l	d0-7,$ffff8240.w
	Rts

*****
evt_AkkaPic:
	Bsr.w	Set_Physical
	Bsr.w	Draw_Lines
	Bsr.w	ScreenSwap
	Rts

tail_AkkaPic:
	Rts
*****


head_Creds:
	Bsr.w	AllBlack
	Bsr.w	ScreenSwap
	Bsr.w	Set_Physical
	Bsr.w	Wait_VBL	
	Move.l	Physical,a0
	Bsr.w	Slow_Clear_Screen
	Move.l	pic_Creds,a0
	Movem.l	2(a0),d0-7
	Movem.l	d0-7,$ffff8240.w
	Rts

*****
evt_Creds:
	Move.b	#7,$ff8800
	Btst.b	#0,$ff8800
	Bne.s	.vent

	Move.b	#4,$ff8800
	Btst.b	#3,$ff8800
	Bne.s	.vent

	Move.w	cnt_Creds,d0
	Lea	tab_Creds,a2
	Move.w	(a2,d0.w),d1
	
	Sub.w	#2,d0
	Bmi.s	.donecreds
	Move.w	d0,cnt_Creds
	Move.w	(a2,d0.w),d2
	
	Move.l	pic_Creds,a0
	Lea	34(a0),a0
	Move.l	Physical,a1

	Lea	(a0,d1.w),a3
	Lea	(a1,d1.w),a4
	Lea	(a1,d2.w),a5
.fill
	Move.w	(a3)+,(a4)+
	Cmpa.l	a4,a5
	Bne.s	.fill
	
	Move.w	#5-1,d7
.wl	
	Bsr.w	Wait_VBL
	Dbf	d7,.wl

.vent
.donecreds

	Rts

tail_Creds:
	Rts
*****

Set_Physical:
	Move.b	Physical+1,$ffff8201.w
	Move.b	Physical+2,$ffff8203.w
	Move.b	Physical+3,$ffff820d.w
	Rts

Wait_VBL:	
	Tst.w	NoWaitVBL
	Bne.s	.no
	Clr.w	DoneVBL
.wvbl	Tst.w	DoneVBL
	Beq.s	.wvbl
.no	Clr.w	NoWaitVBL
	Rts

*****

Mask_AkkaPic:

	Move.l	pic_Akka,a0
	Lea	34(a0),a0
	Move.l	AkkaMask,a1
	Move.w	#16000-1,d7
.maskloop
	Movem.w	(a0)+,d0-3
	Or.w	d1,d0
	Or.w	d2,d0
	Or.w	d3,d0
	Not.w	d0
	Move.w	d0,(a1)+
	Dbf	d7,.maskloop
	Rts


Draw_Lines:
	Move.l	Logical2,a0
	Move.l	AkkaMask,a1
	Move.l	tab_Sinus,a2
	Lea	tab_NotPixel,a3
	Move.l	pic_Akka,a4
	Lea	34(a4),a4

	Move.w	cnt_VBar,d0
	Add.w	#4*47,d0
	And.w	#8191,d0
	Move.w	d0,cnt_VBar
	
	Move.w	(a2,d0.w),d2
	Muls.w	#9,d2
	Add.l	d2,d2
	Swap	d2
	Move.w	d2,d6
	And.w	#15,d2
	Add.w	d6,d6

	Moveq.l	#0,d4
	Move.w	#95-1,d7
.yloop
	Move.w	cnt_Lines1,d0
	Add.w	#4*20,d0
	And.w	#8191,d0
	Move.w	d0,cnt_Lines1

	Move.w	(a2,d0.w),d1
	Muls.w	d6,d1
	Add.l	d1,d1
	Swap	d1
	And.w	#15,d1
	Add.w	d1,d1

	Move.w	d2,d0
	Add.w	d1,d0
	And.w	#15,d0
	Add.w	d0,d0

	Move.w	cnt_Lines2,d3
	Add.w	#4*20,d3
	And.w	#8191,d3
	Move.w	d3,cnt_Lines2
	Add.w	#2,d3

	Move.w	(a2,d3.w),d3
	Muls.w	#15,d3
	Add.l	d3,d3
	Swap	d3
	And.w	#15,d3
	Add.w	d3,d3

	Move.w	d2,d1
	Add.w	d3,d1
	Add.w	d1,d1
	
	Swap	d7
	Lea	16(a3,d1.w),a5
	Lea	22(a3,d0.w),a6

ofs	set	0
	Rept	9
	Move.w	ofs(a6),d4
	Or.w	ofs(a5),d4
	Move.w	d4,(ofs*4)(a0)
ofs	set	ofs+2
	Endr
	Rept	2
	Move.w	ofs(a6),d4
	Or.w	ofs(a5),d4
	And.w	ofs(a1),d4
	Or.w	(ofs*4)(a4),d4
	Move.w	d4,(ofs*4)(a0)
ofs	set	ofs+2
	Endr
	
	Lea	160(a0),a0
	Lea	40(a1),a1
	Lea	160(a4),a4
	
	Swap	d7
	Dbf	d7,.yloop
	Move.w	#105-1,d7
.yloop2
	Move.w	cnt_Lines1,d0
	Add.w	#4*20,d0
	And.w	#8191,d0
	Move.w	d0,cnt_Lines1

	Move.w	(a2,d0.w),d1
	Muls.w	d6,d1
	Add.l	d1,d1
	Swap	d1
	And.w	#15,d1
	Add.w	d1,d1

	Move.w	d2,d0
	Add.w	d1,d0
	And.w	#15,d0
	Add.w	d0,d0

	Move.w	cnt_Lines2,d3
	Add.w	#4*20,d3
	And.w	#8191,d3
	Move.w	d3,cnt_Lines2
	Add.w	#2,d3

	Move.w	(a2,d3.w),d3
	Muls.w	#15,d3
	Add.l	d3,d3
	Swap	d3
	And.w	#15,d3
	Add.w	d3,d3

	Move.w	d2,d1
	Add.w	d3,d1
	Add.w	d1,d1
	
	Swap	d7
	Lea	16(a3,d1.w),a5
	Lea	22(a3,d0.w),a6

ofs	set	0
	Rept	6
	Move.w	ofs(a6),d4
	Or.w	ofs(a5),d4
	Move.w	d4,(ofs*4)(a0)
ofs	set	ofs+2
	Endr
	Rept	5
	Move.w	ofs(a6),d4
	Or.w	ofs(a5),d4
	And.w	ofs(a1),d4
	Or.w	(ofs*4)(a4),d4
	Move.w	d4,(ofs*4)(a0)
ofs	set	ofs+2
	Endr
	
	Lea	160(a0),a0
	Lea	40(a1),a1
	Lea	160(a4),a4
	
	Swap	d7
	Dbf	d7,.yloop2

	Rts
	
****

Slow_Clear_Screen:
	Move.w	#8000-1,d7
.cls	Clr.l	(a0)+
	Dbf	d7,.cls
	Rts

*****

evt_Dummy:
	Rts
	
head_Dummy:
	Bsr.w	AllBlack
	Rts
	
tail_Dummy:
	Rts

*****
AllBlack:
	Lea	$ffff8240,a0
	Move.w	#7,d7
.black
	Clr.l	(a0)+
	Dbf	d7,.black
	Rts
*****

Mkshit:
	Move.l	Log2RGB,a1
	Move.l	Rotval,a2

	Moveq.l	#0,d0
	Move.w	alpha,d0
	Move.l	d0,d1
	Add.w	Wobble1,d1
	And.w	#63,d1
	Move.w	Wobble2,d2
	Add.w	d2,alpha
	And.w	#63,alpha
	
	Lsl.l	#7,d0
	Lsl.l	#7,d1
	Lea	(a2,d1.l),a3
	Lea	(a2,d0.l),a2
	;Lea	16*64*2(a2),a3
	Add.l	#16*2,a2
	Add.l	#7*2,a3

	Lea	.smc+2,a0
	Rept	30
	Move.w	(a2)+,(a0)
	Addq.l	#4,a0
	Endr

	Move.l	CurrentTexture,a2
	Lea	(64*128+64)*2(a2),a2
	Move.l	tab_Sinus,a4

	Move.w	xmove,d0
	Move.w	ymove,d1
	Move.w	xmovement,d2
	Add.w	d2,xmove
	Move.w	ymovement,d2
	Add.w	d2,ymove
	And.w	#2047,xmove
	And.w	#2047,ymove

	Add.w	d0,d0
	Add.w	d0,d0
	Add.w	d1,d1
	Add.w	d1,d1
	Move.w	(a4,d0.w),d0
	Move.w	2(a4,d1.w),d1
	Muls.w	#64,d0
	Muls.w	#64,d1
	Add.l	d0,d0
	Add.l	d1,d1
	Swap	d0
	Swap	d1
	Asl.w	#7,d1
	Add.w	d0,d1
	Add.w	d1,d1
	Lea	(a2,d1.w),a2

	Moveq.l	#0,d0
	Move.w	#50-1,d7
.yloop
	Move.l	a2,a0
	Add.w	(a3)+,a0
.smc
	Rept	30
	Move.w	00(a0),(a1)+
	Endr
	Dbra	d7,.yloop

	Rts

*****
PaletteSwap:
	Move.l	PhysRGB,d0
	Move.l	LogRGB,PhysRGB
	Move.l	Log2RGB,LogRGB
	Move.l	d0,Log2RGB
	Move.w	#$00,$ff8240
	Rts

*****

PlasmaHBL1:
	;Move.w	#$2700,SR
	Movem.l	a0-2/d0,-(sp)
	Lea	TimerB_data,a3
	Move.l	(a3)+,a0		;PhysRGB
	Add.w	(a3)+,a0		;line count
	Move.w	(a3)+,a1		;set ff8242
	Move.l	a1,a2

	Rept	7
	Move.l	(a0)+,(a1)+
	Endr
	Move.w	(a0)+,(a1)
	Rept	7
	Move.l	(a0)+,(a2)+
	Endr
	Move.w	(a0)+,(a2)

	Movem.l	(sp)+,d0/a0-2
	Move.l	#PlasmaHBL2,$120.w
	Bclr	#0,$fffa0f		interrupt done
	Rte
	
	

*****

PlasmaHBL2:
	;Move.w	#$2700,SR
	
	Movem.l	a0-2/d0,-(sp)

	Lea	TimerB_data,a3
	Move.l	(a3)+,a0		;PhysRGB
	Add.w	(a3),a0		;line count
	Add.w	#30*2,(a3)+	;inc above
	Move.w	(a3)+,a1		;set ff8242
	Move.l	a1,a2

	Rept	7
	Move.l	(a0)+,(a1)+
	Endr
	Move.w	(a0)+,(a1)
	Rept	7
	Move.l	(a0)+,(a2)+
	Endr
	Move.w	(a0)+,(a2)

	Movem.l	(sp)+,d0/a0-2
	Move.l	#PlasmaHBL1,$120.w
	Bclr	#0,$fffa0f		interrupt done
	Rte

*****
Init_TimerB:
	Move.w	SR,d1
	Move.w	#$2700,SR
	Lea	SaveTimerB,a0
	Move.l	NextTimerB,d0
	Beq.s	.nochange			no address set?
	Cmp.l	(a0),d0
	Beq.s	.nochange			no change since last?
	Move.l	$120.w,(a0)+		save old rout
	Move.b	$fffffa07.w,(a0)+		save timerB settings
	Move.b	$fffffa13.w,(a0)+
	Move.b	$fffffa15.w,(a0)+
	Move.b	$fffffa1b.w,(a0)+
	Move.b	$fffffa21.w,(a0)+
	Move.b	$fffa15,TimerCreg
	Bclr.b	#5,$fffa15
	Clr.b	$fffffa1b.w		disable timerB
	Move.l	d0,$120.w			set timerB rout
	bset	#0,$fffffa07.w		timerB enable
	bset	#0,$fffffa13.w		timerB mask
	Move.b	#2,$fffffa21.w		scanline counter
	Move.b	#8,$fffffa1b.w		event count
.nochange
	Move.w	d1,SR
	Rts

Restore_TimerB:
	Move.w	SR,d0
	Move.w	#$2700,SR
	Clr.b	$fffffa1b.w		disable timer B
	Lea	SaveTimerB,a0
	Move.l	(a0)+,$120.w
	Move.b	(a0)+,$fffffa07.w
	Move.b	(a0)+,$fffffa13.w
	Move.b	(a0)+,$fffffa15.w
	Move.b	(a0)+,$fffffa1b.w
	Move.b	(a0)+,$fffffa21.w
	Move.b	TimerCreg,$fffa15
	Move.w	d0,SR
	Rts


*****

Precalc:
	Move.l	pic_Precalc,a0
	Movem.l	2(a0),d0-7
	Movem.l	d0-7,$ffff8240.w
	
	Move.l	pic_Precalc,a0
	Lea	34(a0),a0
	Move.l	$44e.w,a1
	Move.w	#8000-1,d7
.show	Move.l	(a0)+,(a1)+
	Dbf	d7,.show
y
	Move.l	Logical2,Clear_Logical
	Bsr.w	Precalc_Circles
	Bsr.w	Setup_Stencil
	Bsr.w	Setup_Plasmabuffers
	Bsr.w	PreCalcRotator
	Bsr.w	SetupBlocks
	
	Movem.l	pal_Shade,d0-7
	Movem.l	d0-7,$ffff8240.w

	Rts
*****

SetupBlocks:

	Move.l	tab_SetPixel,a0
	Lea	tab_NotPixel,a1
	Move.w	#(16*4)-1,d7
.blocks
	Move.w	(a0)+,d0
	Or.w	(a0),d0
	Or.w	2(a0),d0
	Or.w	4(a0),d0
	Move.w	d0,(a1)+
	Dbf	d7,.blocks

	Rts

*****

Setup_Stencil:
	
	Move.l	PlasmaScreen,a0
	Lea	160*2(a0),a0
	Move.l	tab_SetPixel,a1
	Move.l	tab_OnePlaneOfs,a2

	Move.w	#100-1,d7
.yloop
	Moveq.l	#20,d0
	Moveq.l	#1,d4
	Move.w	#15-1,d6
.xloop
	Moveq.l	#10-1,d5
.pixloop
	Move.w	d0,d1
	Move.w	d0,d2

	And.w	#15,d1
	Add.w	d1,d1
	Add.w	d2,d2

	Move.w	(a1,d1.w),d1
	Move.w	(a2,d2.w),d2
	Lea	(a0,d2.w),a3

	Bsr.s	.Plot4bpl
	Add.w	#150,d0
	Move.w	d0,d1
	Move.w	d0,d2
	Sub.w	#150,d0

	And.w	#15,d1
	Add.w	d1,d1
	Add.w	d2,d2

	Move.w	(a1,d1.w),d1
	Move.w	(a2,d2.w),d2
	Lea	(a0,d2.w),a3

	Bsr.s	.Plot4bpl

	Addq.l	#1,d0
	Dbra	d5,.pixloop
	Addq.l	#1,d4
	And.b	#15,d4

	Dbra	d6,.xloop
	Lea	160*2(a0),a0
	Dbra	d7,.yloop
	Bra.w	.skipplot
.Plot4bpl
	Move.w	d4,d2
	And.w	#%1,d2
	Tst.w	d2
	Beq.s	.not1plane
	Or.w	d1,(a3)

.not1plane
	Move.w	d4,d2
	And.w	#%10,d2
	Tst.w	d2
	Beq.s	.not2plane
	Or.w	d1,2(a3)

.not2plane
	Move.w	d4,d2
	And.w	#%100,d2
	Tst.w	d2
	Beq.s	.not3plane
	Or.w	d1,4(a3)

.not3plane
	Move.w	d4,d2
	And.w	#%1000,d2
	Tst.w	d2
	Beq.s	.not4plane
	Or.w	d1,6(a3)
.not4plane
.skipplot
	Rts

Setup_Plasmabuffers:
	Move.l	Plasma1,PhysRGB
	Move.l	Plasma2,LogRGB
	Move.l	Plasma3,Log2RGB

	Rts

****

PreCalcRotator:
	Move.l	tab_Sinus,a0
	Move.l	Rotval,a1
	Moveq.l	#0,d3
	Move.w	#64-1,d7
.NextDegree
	Move.w	d3,d5
	Move.w	#-32,d2		;initial radius
	Move.w	#64-1,d6
.line
	Move.w	d3,d4
;----
	Move.w	d5,d0
	Add.w	d0,d0
	Add.w	d0,d0
	Add.w	#32,d5
	And.w	#2047,d5

	Move.w	(a0,d0.w),d0
	Muls.w	#200,d0
	Add.l	d0,d0
	Swap	d0
	Add.w	d0,d4
	And.w	#2047,d4
;----
	Add.w	d4,d4
	Add.w	d4,d4
	Move.w	(a0,d4.w),d0
	Move.w	2(a0,d4.w),d1
	Muls.w	d2,d0
	Muls.w	d2,d1
	Add.l	d0,d0
	Add.l	d1,d1
	Swap	d0
	Swap	d1
	Muls.w	#128,d1
	Add.w	d0,d1
	Add.w	d1,d1
	Move.w	d1,(a1)+
	Addq.l	#1,d2
	Dbra	d6,.line

	Add.w	#2048/64,d3
	And.w	#2047,d3
	Dbra	d7,.NextDegree
	Rts

*****

Setup_Shading:
	Lea	str_Screens,a0
	Move.l	(a0)+,a1
	Move.l	(a0)+,a2
	Move.l	(a0)+,a3
	Lea	32000(a3),a4
	Move.l	pic_Shading,a0
	Lea	34(a0),a0
	Move.w	#8000-1,d7
.fill
	Move.l	(a0)+,d0
	Move.l	d0,-32000(a1)
	Move.l	d0,-32000(a2)
	Move.l	d0,-32000(a3)
	Move.l	d0,(a1)+
	Move.l	d0,(a2)+
	Move.l	d0,(a3)+
	Move.l	d0,(a4)+
	Dbf	d7,.fill
	Rts

*****

Scroll_Background:

	Move.l	tab_Sinus,a2
	Move.l	Physical,a0

	Moveq.l	#0,d0
	Move.w	cnt_ScrollBg,d0

	Move.b	#7,$ff8800
	Btst.b	#0,$ff8800
	Bne.s	.vent

	Move.b	#4,$ff8800
	Btst.b	#3,$ff8800
	Bne.s	.vent
	
	Add.w	#4*42,d0
	Andi.w	#8191,d0
	Move.w	d0,cnt_ScrollBg
.vent
	Move.w	(a2,d0.w),d1
	Asl.w	#6,d1
	Ext.l	d1
	Swap	d1
	Muls.w	#160,d1
	Move.l	d1,diff_Scroll
	
	Lea	(a0,d1.l),a1
	Move.l	a1,Physical
	Bsr.w	Set_Physical
	Move.l	Logical2,a2
	Lea	(a2,d1.l),a2
	Move.l	a2,Temp_Logical
	Rts

*****
Precalc_Circles:

	Move.l	tab_Radius,a0
	Move.l	tab_Circles,a1
	Move.l	tab_Sinus,a5

	Move.w	#256-1,d7		256 circles -
.circles

	Move.w	cnt_Alpha,d6
	Add.w	#2048/256,d6
	Andi.w	#2047,d6
	Move.w	d6,cnt_Alpha		sincos Alpha modulo

	Swap	d7
	Move.w	#512-1,d7			- with 256 dots each
.rotate
	Add.w	#2048/256,d6
	Andi.w	#2047,d6
	Move.w	d6,d0
	Add.w	d0,d0
	Add.w	d0,d0
	
	Move.l	(a5,d0.w),d0
	Move.w	d0,d1
	Swap	d0
	
	Move.l	(a0),d2			get current radius
	Move.w	d2,d3
	Swap	d2
	Move.w	d2,d4
	Move.w	d3,d5
;				x' = sin(a) * x + cos(a) * y
;				y' = cos(a) * x - sin(a) * y

	Muls.w	d0,d2		sin(a) * x
	Add.l	d2,d2
	Swap	d2

	Muls.w	d1,d3		cos(a) * y
	Add.l	d3,d3
	Swap	d3

	Add.w	d2,d3		x' = sin(a) * x + cos(a) * y

	Muls.w	d1,d4		cos(a) * x
	Add.l	d4,d4
	Swap	d4
	
	Muls.w	d0,d5		cos(a) * y
	Add.l	d5,d5
	Swap	d5

	Sub.w	d4,d5		x = cos(a) * x + sin(a) * y

	Add.w	origo_x,d3
	Add.w	origo_y,d5
	
	Cmp.w	#320,d3
	Blo.s	.noxclip
	Tst.w	d3
	Bpl.s	.noxclip
	Moveq.w	#-1,d3
	bra.s	.skipadd
.noxclip
	;Add.w	#2,d3
	;And.w	#-2,d3
	Add.w	d3,d3
.skipadd	Move.w	d3,(a1)+
	Cmp.w	#200,d5
	Blo.s	.noyclip
	Tst.w	d5
	Bpl.s	.noyclip
	Moveq.w	#-1,d5
.noyclip
	Add.w	#2,d5
	And.w	#-2,d5
	Move.w	d5,(a1)+
	Dbf	d7,.rotate
	Swap	d7

	Addq.l	#4,a0		next radius please

	Dbf	d7,.circles
	Rts

*****

eqDots1PutPixels:

	Move.l	tab_ScanLines,a0
	Move.l	tab_SetPixel,a1
	Move.l	tab_OnePlaneOfs,a4
	Move.l	Logical2,a5
	Adda.l	diff_Scroll,a5
	Addq.l	#6,a5

	;Moveq.l	#0,d3
	;Move.w	cnt_Dist,d3
	;Add.l	#(256),d3		tunnel rotation
	;Move.w	d3,cnt_Dist

	Move.l	tab_Circles,a3
	;Lea	(a3,d3.l),a3
	Moveq.l	#0,d2
	Move.w	#16-1,d7
.pxloop
	Move.w	cnt_Movement,d2
	Move.b	#7,$ff8800
	Btst.b	#0,$ff8800
	Bne.s	.vent

	Move.b	#4,$ff8800
	Btst.b	#3,$ff8800
	Bne.s	.vent
	Subq.l	#8,d2
.vent
	Addq.w	#4,d2
	And.l	#127,d2
	Move.w	d2,cnt_Movement
	Move.l	tab_Movement,a2
	Move.l	(a2,d2.l),d2
	Lea	(a5,d2.w),a5

	Moveq.l	#0,d0
	Moveq.l	#0,d1
	Moveq.l	#64,d3
	Move.l	#2047,d4
	Moveq.l	#0,d5
	Move.w	#8-1,d6
.pzloop
	Add.w	d3,d5
	And.w	d4,d5
	
	Lea	(a3,d5.l),a6
	Move.w	(a6)+,d0
	Bmi.s	.clip
	Move.w	(a6),d1
	Bmi.s	.clip
	Cmp.w	#199,d1
	Bhi.s	.clip

	Move.w	(a0,d1.l),d1
	Add.w	(a4,d0.l),d1
	Lea	(a5,d1.l),a6		Physbase + x & y offset
	Move.w	(a1,d0.l),d1
	Or.w	d1,(a6)
	
.clip
	Add.w	d3,d5
	And.w	d4,d5
	
	Lea	(a3,d5.l),a6
	Move.w	(a6)+,d0
	Bmi.s	.clip2
	Move.w	(a6),d1
	Bmi.s	.clip2

	Cmp.w	#199,d1
	Bhi.s	.clip2

	Move.w	(a0,d1.l),d1
	Add.w	(a4,d0.l),d1
	Lea	(a5,d1.l),a6		Physbase + x & y offset
	
	Move.w	(a1,d0.l),d1
	Or.w	d1,(a6)
	
.clip2
	Add.w	d3,d5
	And.w	d4,d5
	
	Lea	(a3,d5.l),a6
	Move.w	(a6)+,d0
	Bmi.s	.clip3
	Move.w	(a6),d1
	Bmi.s	.clip3

	Cmp.w	#199,d1
	Bhi.s	.clip3
	
	Move.w	(a0,d1.l),d1
	Add.w	(a4,d0.l),d1
	Lea	(a5,d1.l),a6		Physbase + x & y offset
	
	Move.w	(a1,d0.l),d1
	Or.w	d1,(a6)
	
.clip3
	Add.w	d3,d5
	And.w	d4,d5
	
	Lea	(a3,d5.l),a6
	Move.w	(a6)+,d0
	Bmi.s	.clip4
	Move.w	(a6),d1
	Bmi.s	.clip4
	Cmp.w	#199,d1
	Bhi.s	.clip4

	Move.w	(a0,d1.l),d1
	Add.w	(a4,d0.l),d1
	Lea	(a5,d1.l),a6		Physbase + x & y offset
	
	Move.w	(a1,d0.l),d1
	Or.w	d1,(a6)
	
.clip4
	Dbf	d6,.pzloop
	
	Move.l	cnt_Dist,d1
	Add.l	#4*(512+13),d1		tunnel phase
	And.l	#32767,d1
	Move.l	d1,cnt_Dist
	Move.l	tab_Circles,a3
	Lea	(a3,d1.l),a3

 	Dbf	d7,.pxloop
	Rts
*****

OnePlane_Clear_Screen:

	Move.l	Temp_Logical,a0
	Lea	-320*2(a0),a0
	Addq.l	#6,a0
ofs	set	0
	Move.w	#42-1,d7
.cls	
	Rept	100
	Clr.w	ofs(a0)
ofs	set	ofs+8
	Endr
	Lea	800(a0),a0
	Dbf	d7,.cls

	Rts

Syli1PutPixels:
	Move.l	tab_ScanLines,a0
	Move.l	tab_SetPixel,a1
	Move.l	tab_OnePlaneOfs,a4
	Move.l	Logical2,a5
	Adda.l	diff_Scroll,a5
	Addq.l	#6,a5

	Move.w	cnt_Dist,d3
	Add.w	#512-(256+4),d3		tunnel rotation speed
	And.w	#32767,d3
	Move.w	d3,cnt_Dist

	Move.l	tab_Circles,a3
;	Lea	(a3,d3.w),a3
	Move.w	#16-1,d7
pxloop
	Move.w	cnt_Movement,d2
	Addq.w	#4,d2
	And.w	#127,d2
	Move.w	d2,cnt_Movement
	Move.l	tab_Movement,a2
	Move.l	(a2,d2.w),d2
	Adda.l	d2,a5

	Move.l	tab_Sinus,a2

	Move.w	xsin,d2
	Add.w	#4,d2
	And.w	#2047,d2
	Add.w	d2,d2
	Add.w	d2,d2
	Move.w	(a2,d2.w),d2
	Lsr.w	#8,d2
	Lsr.w	#2,d2
	;Add.w	d2,d2
	And.w	#-2,d2
	Move.w	d2,cxsin
	
	Move.w	ysin,d2
	Addq.w	#8,d2
	And.w	#2047,d2
	Move.w	d2,cysin
	Add.w	d2,d2
	Add.w	d2,d2
	Move.w	(a2,d2.w),d2
	Lsr.w	#8,d2
	Lsr.w	#2,d2
	And.w	#-2,d2
	;Add.w	d2,d2
	Move.w	d2,cysin

	Move.w	cxsin,d4
	Move.w	cysin,d5
	Move.w	#33-1,d6
pzloop
	Move.w	(a3),d0
	Bmi.s	clip
	Move.w	2(a3),d1
	Bmi.s	clip

	Sub.w	d4,d0
	Add.w	d5,d1

	Move.w	(a0,d1.w),d1
	Add.w	(a4,d0.w),d1
	Lea	(a5,d1.w),a6		Physbase + x & y offset

	Move.w	(a1,d0.w),d1
	Or.w	d1,(a6)
clip
	;Lea	68(a3),a3
	Lea	32(a3),a3
	Dbf	d6,pzloop
	
	Move.w	cnt_Dist,d1
	Add.w	#2048-64,d1		tunnel phase
	And.w	#32767,d1
	Move.w	d1,cnt_Dist
	Move.l	tab_Circles,a3
	Lea	(a3,d1.w),a3

	Dbf	d7,pxloop
	Rts


*****

ScreenSwap:
	Move.l	Logical1,TempScr
	Move.l	Physical,Logical1
	Move.l	Logical2,Physical
	Move.l	TempScr,Logical2
	Rts
*****
	Include	NewOut.s
	Include	NewIn.s
*****

Clear_BSS:
	Lea	startBSS,a0
	Lea	endBSS,a1
.loop
	Clr.w	(a0)+
	Cmpa	a0,a1
	Blo.s	.loop
	
	Rts

****		

Init_Data:
	Lea	data_start,a0
	Move.l	a0,a4
	Lea	tab_Adr,a1
.dataloop
	Move.l	(a0)+,d0
	Beq.s	.done
	Lea	(a4,d0.l),a5
	Move.l	a5,(a1)+
	Bra.s	.dataloop
.done
	Rts	

*****
	Section	TEXT

TimerB_data:
		dc.l	0	;phys rgb
		dc.w	0	;line count
		dc.w	$8242	;ff8242  short

cnt_Creds		Dc.w	10

origo_x	Dc.w	160
origo_y	Dc.w	100

crd_Center:
	Dc.w	160,-100

tab_Creds:
	Dc.w	200*160,145*160,100*160,77*160,33*160,0
tab_CredsOut:
	Dc.w	33*160,77*160,100*160,147*160,200*160,0

tab_Circles:
	Dc.l	0

****
	Section	BSS

startBSS:
SaveSr		Ds.w	1
AbuseSp		Ds.l	1
SaveMfp		Ds.l	1
NextTimerB	Ds.l	1
SaveTimerB	Ds.l	10
cnt_Dist:		Ds.l	1
cnt_Move		Ds.w	1
cnt_Alpha		Ds.w	1
cnt_Movement	Ds.w	1
cnt_Vri		Ds.w	1
cnt_ScrollBg	Ds.w	1
cnt_ScrollWave	Ds.w	1
cnt_Lines1	Ds.w	1
cnt_Lines2	Ds.w	1
cnt_VBar		Ds.w	1
diff_Scroll	Ds.l	1
Temp_Logical	Ds.l	1
Clear_Logical	Ds.l	1
TempScr		Ds.l	1
TimerCreg		Ds.w	1
NoWaitVBL		Ds.l	1
VBLflag		Ds.w	1
flag_Draw		Ds.w	1
xmove		Ds.w	1
xmovement		Ds.w	1
ymove		Ds.w	1
ymovement		Ds.w	1
Wobble1		Ds.w	1
Wobble2		Ds.w	1
alpha		Ds.w	1
PhysRGB		Ds.l	1
LogRGB		Ds.l	1
Log2RGB		Ds.l	1
CurrentTexture	Ds.l	1
xsin		Ds.w	1
ysin		Ds.w	1
cxsin		Ds.w	1
cysin		Ds.w	1
Rotval		Ds.l	1
Plasma1		Ds.l	1
Plasma2		Ds.l	1
Plasma3		Ds.l	1
AkkaMask		Ds.l	1

tab_Adr:
tab_Sinus		Ds.l	1
pic_Akka		Ds.l	1
pic_Creds		Ds.l	1
pic_Precalc	Ds.l	1
pic_Shading	Ds.l	1
tab_Radius	Ds.l	1
tab_Movement	Ds.l	1
tab_ScanLines	Ds.l	1 
tab_OnePlaneOfs	Ds.l	1
tab_SetPixel	Ds.l	1
pal_Shade		Ds.l	1
txt_Sykle		Ds.l	1
txt_Brun		Ds.l	1
txt_Blaa		Ds.l	1
tab_NotPixel:	Ds.w	16*4
endBSS

	Section	DATA


data_start:
	Incbin	e:\sprell2.dat
tvs_Blink	
	Incbin	f:\work\sprell\blink.tvs
tri_Blink	
	Incbin	f:\work\sprell\blink.tri

	END

