; Animal Mine SidSoundDesigner Replayer
;
; 1.00 reassembled,fixed and new stuff added by .defjam./.checkpoint.
; 1.01 Falcon-IDE-fix by FroST
; 1.02 Pattern Fix, Optimisation, Commented by Ben / OVR
 
; Dirtily hacked by gwEm for fast single SID voice on Timer A
; Middle channel in the editor

; Uses Timer A

; For a standalone version set 'test' to 0. The assemble as an excutable.
; Then remove the first $1c bytes from the start of the file.

test	equ	0	; 1 Test Version, 0 Full version

;	Tabs to 8

		section text

music		bra	init_music	;+0
		bra	my_replay_music	;+4
		bra	exit_player	;+8
		bra	set_music_off	;+12
		bra	set_music_on	;+16
		bra	set_sid_off	;+20
		bra	set_sid_on	;+24
		bra	set_screen_freq	;+28

lall		dc.b	"SSD-Player by Animal Mine! "
		dc.b	"ver. 1.02 ABD "
		dc.b	"fixed by .defjam./.checkpoint. "
		dc.b	"Falcon-fix by FroST "
		dc.b	"Pattern Break fix by Ben/OVR "
		dc.b	"Special gwEm single voice version"
		even

;..........................................................
gwem_off:
	move.b	#0,$FFFF8802.w
	addq.w	#1,$134.w
	rte
;..........................................................


my_replay_music:
	tst.b	do_replay_flag
	beq.s	no_replay

	movem.l	D0-A6,-(a7)
	bsr	replay_music

	tst.b	music_off_flag
	beq.s	no_music_off

	move	#$2700,SR
	bsr	clear_YM
	move.b	#9,$ffff8800.w		;YM B volume
	bsr	restore_MFP

	sf	do_replay_flag
	move	#$2300,SR

no_music_off:	movem.l	(a7)+,D0-A6
no_replay:	rts


set_music_off:	
	bsr	clear_YM
	st	music_off_flag
	rts

set_music_on:	
	bsr	set_sid_on
	sf	music_off_flag
	st	do_replay_flag
	rts

music_off_flag:	DC.B	0
do_replay_flag:	DC.B	0


exit_player:	
	bsr	restore_MFP
	bsr	restore_h200
	move	#$2700,SR
	bsr	clear_YM
	move	#$2300,SR
	rts

save_MFP:	
	
	move	#$2700,SR
	lea	mfp_regs(PC),A0
	move.b	$FFFFFA07.w,(A0)+	;IERA
	move.b	$FFFFFA09.w,(A0)+	;IERB
	move.b	$FFFFFA13.w,(A0)+	;IMRA
	move.b	$FFFFFA15.w,(A0)+	;IMRB

	move.b	$FFFFFA17.w,(A0)+	;Interrupt Vektor Register

	move.b	$FFFFFA19.w,(A0)+	;Timer A Control
	;move.b	$FFFFFA1B.w,(A0)+	;Timer B Control
	;move.b	$FFFFFA1D.w,(A0)+	;Timer C/D Control

	bclr	#5,$FFFFFA07.w	;Timer A
	;bclr	#0,$FFFFFA07.w	;Timer B
	;bclr	#4,$FFFFFA09.w	;Timer D
	
	bclr	#5,$FFFFFA13.w	;Timer A
	;bclr	#0,$FFFFFA13.w	;Timer B
	;bclr	#4,$FFFFFA15.w	;Timer D

	lea	irq_vectors(PC),A0
	;move.l	$00000120.w,(A0)+	;Timer B
	;move.l	$00000110.w,(A0)+	;Timer D
	move.l	$00000134.w,(A0)+	;Timer A
	move.l	$00000060.w,(A0)+	;Spurious irq

	bclr	#3,$FFFFFA17.w	; software end of int.
	lea	rte_(PC),A0
	move.l	A0,$00000060.w
	;move.l	A0,$00000110.w
	;move.l	A0,$00000120.w		;Timer B
	move.l	A0,$00000134.w
	move	#$2300,SR
	rts

rte_:	rte

mfp_regs:	ds.b	16
irq_vectors:	dc.l	0,0,0,0,0,0,0,0

restore_MFP:
	move	#$2700,SR

;Stop All Timers
	bclr	#5,$FFFFFA07.w	;Timer A
	;bclr	#0,$FFFFFA07.w	;Timer B
	;bclr	#4,$FFFFFA09.w	;Timer D
	
	bclr	#5,$FFFFFA13.w	;Timer A
	;bclr	#0,$FFFFFA13.w	;Timer B
	;bclr	#4,$FFFFFA15.w	;Timer D

	lea	mfp_regs(PC),A0
	move.b	(A0)+,$FFFFFA07.w	;IERA
	move.b	(A0)+,$FFFFFA09.w	;IERB
	move.b	(A0)+,$FFFFFA13.w	;IMRA
	move.b	(A0)+,$FFFFFA15.w	;IMRB

	move.b	(A0)+,$FFFFFA17.w	;Interrupt Vektor Register

	move.b	(A0)+,$FFFFFA19.w	;Timer A Control
	;move.b	(A0)+,$FFFFFA1B.w	;Timer B Control

	;move.l	d0,-(sp)
	;move.b  (A0)+,d0
	;and.b	#%11110000,$FFFFFA1D.w	;Timer C/D Control (only TD bits)
	;and.b	#7,d0
	;or.b	d0,$fffffa1d.w
	;move.l	(sp)+,d0

	;move.b  #$C0,$FFFFFA21.w	;Timer B Data

	lea	irq_vectors(PC),A0
	;move.l	(A0)+,$00000120.w	;Timer B
	;move.l	(A0)+,$00000110.w	;Timer D
	move.l	(A0)+,$00000134.w	;Timer A
	move.l	(A0)+,$00000060.w	;Spurious irq

	move	#$2300,SR
	rts

set_sid_on:

	move	#$2700,SR
	move.l	#rte_,$00000060.w	;spurious interrupt
	;bsr	copy_sid_psg_rout

	;move.l	#td0,$00000110.w	;Timer D
	;andi.b	#$F0,$FFFFFA1D.w
	;ori.b	#1,$FFFFFA1D.w
	;move.b	#255,$FFFFFA25.w	;data
	;bset	#4,$FFFFFA15.w
	;bclr	#4,$FFFFFA09.w

	;move.l	#tb0,$120.w		;Timer B
	;move.b	#%11,$fffffa1b.w
	;move.b	#255,$fffffa21.w	;data
	;bset	#0,$fffffa13.w
	;bclr	#0,$fffffa07.w

	move.l	#gwem_on,$00000134.w	;Timer A
	clr.b	$FFFFFA19.w
	move.b	#255,$FFFFFA1F.w	;data
	bset	#5,$FFFFFA13.w
	bclr	#5,$FFFFFA07.w

	bclr	#3,$FFFFFA17.w		; software end of int.
	move	#$2300,SR
	rts

set_sid_off:
	move	#$2700,SR

	lea	rte_(PC),A0
	move.l	A0,$00000060.w

	;move.l	A0,$00000110.w		;Timer D
        ;and.b	#%11110000,$fffffa1d.w	;Preserve Timer C bits!
	;move.b	#255,$FFFFFA25.w
	;bclr	#4,$FFFFFA15.w
	;bclr	#4,$FFFFFA09.w

	;move.l	A0,$120.w		;Timer B
	;clr.b	$fffffa1b.w
	;move.b	#255,$fffffa21.w
	;bclr	#0,$fffffa07.w
	;bclr	#0,$fffffa13.w

	move.l	A0,$00000134.w		;Timer A
	clr.b	$FFFFFA19.w
	move.b	#255,$FFFFFA1F.w
	bclr	#5,$FFFFFA13.w
	bclr	#5,$FFFFFA07.w
	move	#$2300,SR
	rts


save_h200:
	move	#$2700,SR
	lea	$00000200.w,A0
	lea	save200(PC),A1
do_s2:
	move.w	#$0100/4-1,D0
sc0:
	move.l	(A0)+,(A1)+
	dbra	D0,sc0
	move	#$2300,SR
	rts

restore_h200:
	move	#$2700,SR
	lea	$00000200.w,A1
	lea	save200(PC),A0
	bra.s	do_s2
save200:	DS.B	$0100


;copy_sid_psg_rout:
;	lea	sid_irqs_s(PC),A0
;	lea	$00000200.w,A1
;	move.w	#sid_irqs_e-sid_irqs_s-1,D0
;c0:	move.b	(A0)+,(A1)+
;	dbra	D0,c0
;	rts


clear_YM:				; Frost Fix - used in deinit
	move.b	#$a,$ffff8800.w
	clr.b	$ffff8802.w
	move.b	#$9,$ffff8800.w
	clr.b	$ffff8802.w
	move.b	#$8,$ffff8800.w
	clr.b	$ffff8802.w

; Never modify bit 6 on a Falcon, coz bit 7 in YM's port A means
; "Falcon internal IDE drive on/off", changing bit 6 in reg 7 will
; provide a direction change of the flow from port A (do you follow
; me, coz I don't know how to explain in english).

	move.b	#7,$ffff8800.w
	move.b	$ffff8802.w,d0
	move.b	#%11000000,$ffff8802.w

	moveq	#6,d0
clr_ym_r	
	move.b	d0,$ffff8800.w
	clr.b	$ffff8802.w
	dbra	d0,clr_ym_r
	clr.b	$FFFF8800.w
	clr.b	$FFFF8802.w
	move.b	#$07,$FFFF8800.w
	move.b	#$FF,$FFFF8802.w
	rts

;D0 = Freq.	( D0>=50 )
set_screen_freq:
	move.l	D0,screen_freq
	rts

screen_freq:	dc.l	50

vbl_timer_inc:	dc.l	0
vbl_timer:	dc.l	0

my_screen_freq:	dc.l	0
lv:	DC.W	0

replay_music:
	move.l	screen_freq(PC),D1
	cmp.b	#50,D1
	beq.s	dorep

	cmp.l	my_screen_freq(PC),D1
	beq.s	freq_da

;Initialise New Screenfrequency

	move.l	D1,my_screen_freq
	move.l	#50*1000,D0
	divu	D1,D0
	and.l	#$0000FFFF,D0
	move.l	D0,vbl_timer_inc
	clr.l	vbl_timer
	
freq_da:
	
	move.l	vbl_timer(PC),D0
	add.l	vbl_timer_inc(PC),D0
	cmp.l	#(50*1000),D0
	blt.s	lvt
	sub.l	#(50*1000),D0
lvt:
	move.l	D0,vbl_timer

	divu	#1000,D0
	move.w	lv(PC),D1
	move.w	D0,lv
	sub.w	D1,D0
	tst.w	D0
	bne.s	dorep
	rts


;; replay_music:
dorep:
	moveq	#0,D4
	lea	$FFFF8800.w,A5	;a5 points to YM
	subq.w	#1,L013A
	bne.s	L0007
L0002:	move.w	L0002,L013A
L0003	=	*-8
	movea.l	CurPatPtr(PC),A1
	move.w	PatPos(PC),D0
	move.w	D0,D1
	lsl.w	#3,D0
	lsl.w	#2,D1		;	mul 12

	add.w	D1,D0
	adda.w	D0,A1
	move.l	A1,PatPtr
	tst.b	PatBreakFlag
	bpl.s	L0004
	move	#$40,PatPos	; $$$ ben: pattern break fix
	sf	PatBreakFlag
	bra.s	L0005
	
L0004:	addq.w	#1,PatPos
L0005:	cmpi.w	#$0040,PatPos	; $$$
	bne.s	L0006
	
	bsr	ReadSong
	
L0006:	lea	VoiceData_A(PC),A0
	bsr	L0022
	
	lea	VoiceData_B(PC),A0
	bsr	L0022
	
	lea	VoiceData_C(PC),A0
	bsr	L0022

L0007:	lea	VoiceData_B(PC),A0
	bsr	L0059
	bsr	L004A
	bsr	L004E
	
	lea	VoiceData_C(PC),A0
	bsr	L0059
	bsr	L004A
	bsr	L004E
	
	lea	VoiceData_A(PC),A0
	bsr	L0059
	bsr	L004A
	bsr	L004E


	;; DO sid stuff
	move	#$2700,SR	
	
	lea	VoiceData_A(PC),A0
	tst.b	58(A0)
	bne.s	L000B
	
	tst.w	SidOnOffA
	bpl.s	L000B
	cmpi.b	#5,63(A0)
	bgt.s	L000B
	cmpi.b	#3,63(A0)
	blt.s	L000B
	lea	L00B5(PC),A6
	move.w	0(A0),D1
L0008:	tst.w	(A6)
	bmi.s	L000B
	cmp.w	(A6)+,D1
	blt.s	L0009
	addq.l	#4,A6
	bra.s	L0008
	
L0009:	move.w	(A6)+,D2
	move.w	(A6)+,D3
	move.l	#$01900000,D0
	mulu	#$00A3,D2
	divu	D2,D0
	mulu	D1,D0
	tst.w	SidDephaseA
	bne.s	L000A
	addi.l	#$00002000,D0
L000A:	addi.l	#$00002000,D0
	add.l	D0,D0
	add.l	D0,D0
	swap	D0
	;move.b	14(A0),tb1+4.w

	;move.b	d0,$fffffa21.w	;Timer B
	;move.b	d3,$fffffa1b.w
	;or.b	#1,$fffffa07.w
	bra.s	DoSidVoiceB
	
L000B:	
	bclr	#0,$FFFFFA07.w

	cmpi.b	#5,63(A0)
	bgt.s	DoSidVoiceB
	cmpi.b	#3,63(A0)
	blt.s	DoSidVoiceB
	bclr	#0,44(A0)

	;; Sid Voice B
	
DoSidVoiceB:
	lea	VoiceData_B(PC),A0
	tst.b	58(A0)
	bne.s	L0011
	
	tst.w	SidOnOffB
	bpl.s	L0011
	cmpi.b	#5,63(A0)
	bgt.s	L0011
	cmpi.b	#3,63(A0)
	blt.s	L0011
	lea	L00B5,A6
L000D	= *-4
	move.w	0(A0),D1
L000E:	tst.w	(A6)
	bmi.s	L0011
	cmp.w	(A6)+,D1
	blt.s	L000F
	addq.l	#4,A6
	bra.s	L000E
L000F:	move.w	(A6)+,D2
	move.w	(A6)+,D3
	move.l	#$01900000,D0
	mulu	#$00A3,D2
	divu	D2,D0
	mulu	D1,D0
	tst.w	SidDephaseB
	bne.s	L0010
	addi.l	#$00002000,D0
L0010:	addi.l	#$00002000,D0
	lsl.l	#2,D0
	swap	D0
	move.b	14(A0),gwem_on+3	; SMC volume in SID routine

	move.b	D0,$FFFFFA1F.w		; Timer A
	move.b	D3,$FFFFFA19.w
	bset	#5,$FFFFFA07.w
	bra.s	DoSidVoiceC
	
L0011:	bclr	#5,$FFFFFA07.w
	cmpi.b	#5,63(A0)
	bgt.s	DoSidVoiceC
	cmpi.b	#3,63(A0)
	blt.s	DoSidVoiceC
	bclr	#0,44(A0)

	
DoSidVoiceC:
	lea	VoiceData_C(PC),A0
	tst.b	58(A0)
	bne.s	L0016
	tst.w	SidOnOffC
	bpl.s	L0016
	cmpi.b	#5,63(A0)
	bgt.s	L0016
	cmpi.b	#3,63(A0)
	blt.s	L0016
	lea	L00B5(PC),A6
	move.w	0(A0),D1
L0013:	tst.w	(A6)
	bmi.s	L0016
	cmp.w	(A6)+,D1
	blt.s	L0014
	addq.l	#4,A6
	bra.s	L0013
L0014:	move.w	(A6)+,D2
	move.w	(A6)+,D3
	move.l	#$01900000,D0
	mulu	#$00A3,D2
	divu	D2,D0
	mulu	D1,D0
	tst.w	SidDephaseC
	bne.s	L0015
	addi.l	#$00002000,D0
L0015:	addi.l	#$00002000,D0
	lsl.l	#2,D0
	swap	D0
	;move.b	14(A0),td1+4.w

	;andi.b	#$F0,$FFFFFA1D.w	;Timer D
	;or.b	D3,$FFFFFA1D.w
	;move.b	D0,$FFFFFA25.w
	;bset	#4,$FFFFFA09.w
	bra.s	L0017
	
L0016:	;bclr	#4,$FFFFFA09.w
	cmpi.b	#5,63(A0)
	bgt.s	L0017
	cmpi.b	#3,63(A0)
	blt.s	L0017
	bclr	#0,44(A0)

L0017:	;move.w	#$2300,SR		;interrupts on
	move.b	#$FF,D0	; All OFF
	
	lea	VoiceData_C(PC),A0
	moveq	#2,D6
	moveq	#5,D7
	bsr	SetMixerAndNoise
	
	lea	VoiceData_B(PC),A0
	moveq	#1,D6
	moveq	#4,D7
	bsr	SetMixerAndNoise
	
	lea	VoiceData_A(PC),A0
	btst	#1,58(A0)
	bne.s	SetMixer
	moveq	#0,D6
	moveq	#3,D7
	bsr	SetMixerAndNoise

	
SetMixer:
	move.w	#$0700,D7
	move.b	D0,D7
	movep.w D7,0(A5)
	
SetVoiceA:
	lea	VoiceData_A(PC),A0
	btst	#1,58(A0)
	bne.s	SetVoiceB

	;; Set voice A period
	move.w	0(A0),D0
	move.b	0(A0),D1
	moveq	#0,D7
	move.b	D0,D7
	movep.w D7,0(A5)
	move.w	#$0100,D7
	move.b	D1,D7
	movep.w D7,0(A5)
	
	tst.b	58(A0)
	bne.s	L0019
	tst.b	80(A0)
	beq.s	L0019
	btst	#2,44(A0)
	beq.s	L0019
	btst	#3,44(A0)
	beq.s	L0019

	;; Set envelop period maaped to channel A
	lsr.w	#4,D0
	move.w	#$0B00,D7
	move.b	D0,D7
	movep.w D7,0(A5)
	move.w	#$0C00,D7
	movep.w D7,0(A5)
	
L0019:	tst.w	SidOnOffA
	bpl.s	L001A
	cmpi.b	#3,63(A0)
	blt.s	L001A
	cmpi.b	#5,63(A0)
	bgt.s	L001A
	bra.s	SetVoiceB
	
L001A:
	;; Set Voice A volume
	move.w	#$0800,D7
	move.b	14(A0),D7
	movep.w D7,0(A5)

	
SetVoiceB:

	lea	VoiceData_B(PC),A0

	;; Set voice B period
	move.w	0(A0),D0
	move.b	0(A0),D1
	move.w	#$0200,D7
	move.b	D0,D7
	movep.w D7,0(A5)
	move.w	#$0300,D7
	move.b	D1,D7
	movep.w D7,0(A5)
	
	tst.b	58(A0)
	bne.s	L001C
	tst.b	80(A0)
	beq.s	L001C
	btst	#2,44(A0)
	beq.s	L001C
	btst	#3,44(A0)
	beq.s	L001C

	
	;; Set envelop period to channel B
	lsr.w	#4,D0
	move.w	#$0B00,D7
	move.b	D0,D7
	movep.w D7,0(A5)
	move.w	#$0C00,D7
	movep.w D7,0(A5)
	
L001C:	tst.w	SidOnOffB
	bpl.s	L001D
	cmpi.b	#3,63(A0)
	blt.s	L001D
	cmpi.b	#5,63(A0)
	bgt.s	L001D
	bra.s	SetVoiceC
	
L001D:
	;; Set Voice B volume
	move.w	#$0900,D7
	move.b	14(A0),D7
	movep.w D7,0(A5)

	
SetVoiceC:
	lea	VoiceData_C(PC),A0
	;; Set voice B period
	
	move.w	0(A0),D0
	move.b	0(A0),D1
	move.w	#$0400,D7
	move.b	D0,D7
	movep.w D7,0(A5)
	move.w	#$0500,D7
	move.b	D1,D7
	movep.w D7,0(A5)
	tst.b	58(A0)
	bne.s	L001F
	tst.b	80(A0)
	beq.s	L001F
	btst	#2,44(A0)
	beq.s	L001F
	btst	#3,44(A0)
	beq.s	L001F
	lsr.w	#4,D0
	move.w	#$0B00,D7
	move.b	D0,D7
	movep.w D7,0(A5)
	move.w	#$0C00,D7
	movep.w D7,0(A5)
L001F:	tst.w	SidOnOffC
	bpl.s	L0020
	cmpi.b	#3,63(A0)
	blt.s	L0020
	cmpi.b	#5,63(A0)
	bgt.s	L0020
	bra.s	L0021
L0020:
	;; Set Voice B volume
	move.w	#$0A00,D7
	move.b	14(A0),D7
	movep.w D7,0(A5)
	
L0021:	move.b	#$9,(a5)	;YM volume B
	move.w	#$2300,sr	;interrupts on
	rts

	
; IN	a0	Voice struct
;	a1	Pattern Ptr
; 

L0022:	tst.b	(A1)
	beq	L002D
	bmi	L003D
	move.b	2(A1),D1
	cmpi.b	#$3F,D1
	bhi	L0028
	move.b	D1,57(A0)
	move.w	D4,76(A0)
	move.b	D4,56(A0)
	lea	CurInfo(PC),A6
	moveq	#0,D0
	move.b	57(A0),D0
	add.w	D0,D0
	add.w	D0,D0
	move.l	0(A6,D0.w),D0
	move.l	D0,60(A0)
	lsr.l	#8,D0
	tst.b	D0
	beq.s	L0023
	lea	L00BB(PC),A6
	moveq	#0,D1
	move.b	D0,D1
	subq.b	#1,D1
	add.w	D1,D1
	add.w	D1,D1
	move.l	0(A6,D1.w),72(A0)
L0023:	lsr.l	#8,D0
	tst.b	D0
	beq.s	L0024
	lea	L00BA(PC),A6
	moveq	#0,D1
	move.b	D0,D1
	subq.b	#1,D1
	add.w	D1,D1
	add.w	D1,D1
	move.l	0(A6,D1.w),68(A0)
L0024:	lsr.w	#8,D0
	tst.b	D0
	beq.s	L0025
	lea	NoiseSeqTbl(PC),A6
	moveq	#0,D1
	move.b	D0,D1
	subq.w	#1,D1
	add.w	D1,D1
	add.w	D1,D1
	move.l	0(A6,D1.w),64(A0)

L0025:	move.b	57(A0),D1
	andi.w	#$003F,D1
L0026:	lea	L0026,A2
InstBasePtr	= *-4
	asl.w	#8,D1
	adda.w	D1,A2
	move.w	0(A2),D0
	move.w	D0,42(A0)
	move.b	2(A2),44(A0)
	move.w	4(A2),46(A0)
	move.b	3(A2),45(A0)
	move.l	6(A2),10(A0)
	move.l	252(A2),48(A0)
	move.w	D4,20(A0)
	move.l	10(A2),22(A0)
	move.w	14(A2),26(A0)
	lea	16(A2),A3
	move.l	A3,16(A0)
	move.w	D4,32(A0)
	move.l	240(A2),34(A0)
	move.w	244(A2),38(A0)
	lea	128(A2),A3
	moveq	#0,D0
	move.b	(A1),D0
	move.w	D0,D1
	lsr.w	#4,D1
	lea	YmPerTbl(PC),A2
	andi.w	#$000F,D0

	move.l	A3,28(A0)
	st	40(A0)
	andi.w	#$000F,D0
	move.w	D0,D2
	add.w	D2,D2
	move.w	0(A2,D2.w),D2
	lsr.w	D1,D2
	move.w	D2,2(A0)
	move.w	D0,D3
	add.w	48(A0),D3
	add.w	D3,D3
	move.w	0(A2,D3.w),D3
	lsr.w	D1,D3
	sub.w	D2,D3
	move.w	D3,52(A0)
	add.w	50(A0),D0
	add.w	D0,D0
	move.w	0(A2,D0.w),D0
	lsr.w	D1,D0
	sub.w	D2,D0
	
	move.w	D0,54(A0)
	
L0028:	move.b	1(A1),D1
	beq.s	L002B
	sub.w	4(A0),D2
	ext.l	D2
	andi.l	#$000000FF,D1
L0029:	muls	L0029,D1
L002A	= *-4
	divs	D1,D2
	beq.s	L002B
	move.w	D2,6(A0)
	bra.s	L002C
	
L002B:	move.w	2(A0),4(A0)
	move.w	D4,6(A0)
L002C:	move.b	3(A1),D0
	andi.w	#$001F,D0
	move.b	D0,15(A0)
	
L002D:	addq.l	#3,A1
	move.b	(A1)+,D1
	lsr.b	#6,D1
	tst.b	D1
	beq.s	L0030
	
	btst	#2,44(A0)
	bne.s	L0031
	cmpi.b	#1,D1
	beq.s	L002F
	cmpi.b	#2,D1
	beq.s	L002E
	move.w	24(A0),20(A0)
	move.w	36(A0),32(A0)
	bclr	#0,58(A0)
	st	40(A0)
	rts
	
L002E:	move.w	22(A0),20(A0)
	move.w	34(A0),32(A0)
	bclr	#0,58(A0)
	st	40(A0)
	rts
	
L002F:	move.w	D4,8(A0)
	move.w	D4,20(A0)
	move.w	D4,32(A0)
	bclr	#0,58(A0)
	st	40(A0)
	bclr	#1,58(A0)
	
L0030:	rts
	
L0031:	moveq	#$0B,D7
	moveq	#$0C,D6
	moveq	#$0D,D5
	tst.b	D1
	beq.s	L0036
	cmpi.b	#2,D1
	beq.s	L0037
	cmpi.b	#3,D1
	beq	L003C
	move	#$2700,SR
	btst	#3,44(A0)
	bne.s	L0032
	move.b	D7,(A5)
	move.b	47(A0),2(A5)
	move.b	D6,(A5)
	move.b	46(A0),2(A5)
L0032:	move.b	D5,(A5)
	btst	#0,45(A0)
	bne.s	L0033
	move.b	(A5),D0
	cmp.b	45(A0),D0
	beq.s	L0034
L0033:	move.b	45(A0),2(A5)
L0034:	move.w	D4,8(A0)
	move.w	D4,32(A0)
	st	40(A0)
	bclr	#0,58(A0)
	bclr	#1,58(A0)
	beq.s	L0035
	bclr	#5,$FFFFFA07.w
	bclr	#0,$FFFFFA07.w	
L0035:	move.b	#9,(a5)
	move	#$2300,SR
L0036:	rts
	
L0037:	move	#$2700,SR
	btst	#3,44(A0)
	bne.s	L0038
	move.b	D7,(A5)
	move.b	47(A0),2(A5)
	move.b	D6,(A5)
	move.b	46(A0),2(A5)
L0038:	move.b	D5,(A5)
	btst	#0,45(A0)
	bne.s	L0039
	move.b	(A5),D0
	cmp.b	45(A0),D0
	beq.s	L003A
L0039:	move.b	45(A0),2(A5)
L003A:	move.w	D4,8(A0)
	move.w	34(A0),32(A0)
	st	40(A0)
	bclr	#0,58(A0)
	bclr	#1,58(A0)
	beq.s	L003B
	bclr	#5,$FFFFFA07.w
	bclr	#0,$FFFFFA07.w
L003B:	move.b	#9,(a5)
	move	#$2300,SR
	rts
L003C:	bset	#0,58(A0)
	rts
	
L003D:	btst	#2,58(A0)
	bne.s	L0040
	cmpi.b	#$0E,2(A1)
	bne.s	L003E
	move.w	#$FFFF,PatBreakFlag
	bra.s	L003F
	
L003E:	cmpi.b	#$0F,2(A1)
	bne.s	L003F
	move.w	#$FFFF,L0120
L003F:	move.b	2(A1),D0
	andi.w	#$000F,D0
	asl.w	#2,D0
	tst.w	L0120
	bmi.s	L0041
	moveq	#0,D0
	move.b	3(A1),D0
	ext.w	D0
	add.w	D0,D0
	add.w	D0,D0
	movea.l FxJmpTbl(PC,D0.w),A6
	jsr	(A6)
L0040:	addq.l	#4,A1
	rts
	
L0041:	move.b	3(A1),D0
	ext.w	D0
	move.w	D0,L002A
	addq.l	#4,A1
	move.w	D4,L0120
	rts
	
FxJmpTbl:	
	DC.L FxNone
	DC.L ToggleSidDephaseA
	DC.L ToggleSidDephaseB
	DC.L ToggleSidDephaseC
	DC.L ActivSidVoiceA
	DC.L StopSidVoiceA
	DC.L ActivSidVoiceB
	DC.L StopSidVoiceB
	DC.L ActivSidVoiceC
	DC.L StopSidVoiceC
	DC.L L008E
	DC.L L008F
	DC.L L0090
	DC.L L0092
	DC.L FxNone
	DC.L FxNone
	
	
L004A:	move.l	#$01010100,D6
	tst.b	61(A0)
	beq.s	L004C
	movea.l 68(A0),A6
	moveq	#0,D1
	move.b	(A6)+,D1

	;; $$$ ben: that's my fix for the bug below
	cmp.b	#$FE,d1
	blo.s	L004B
	subq	#1,a6
	bra.s	L004B_bis

	;; $$$ ben:
	;; Meaningless! Previous moveq prevent $FE in d1 !!!
	;; Btw, $FE will not be matched if the moveq was removed
	;; since previous test with $FF skips the $FE test code.
	;; Currently the whole thing can be replaced by:
	;; cmp.b	#$FF,D1
	;; seq	d1
	;; But more likely this is not what it intends to do.
		
;	cmp.b	#$FF,D1		; NOP
;	bne.s	L004B
;	moveq	#0,D1

;	cmp.b	#$FE,D1		; END
;	bne.s	L004B
;	subq.l	#1,A6
;	move.b	-1(A6),D1
	
L004B:	move.l	A6,68(A0)
	add.w	D1,D1
	add.w	D1,D1
	move.l	MaskTbl(PC,D1.w),D7
	move.l	D7,78(A0)
	rts

L004B_bis:		
	move.l	A6,68(A0)	
L004C:	move.l	D6,78(A0)
	rts
	
MaskTbl:
	DC.L $00000000
	DC.L $01000000
	DC.L $00010000
	DC.L $01010000
	DC.L $00000100
	DC.L $01000100
	DC.L $01010100
	
L004E:	tst.b	62(A0)
	beq.s	L0051
	movea.l 72(A0),A6
	move.b	(A6)+,D1
	
	cmpi.b	#$FF,D1		; NOP 
	beq.s	L0050

	cmpi.b	#$FE,D1		; End
	bne.s	L004F

	; $$$ ben:	
	; subq.b #1,d1 is useless since d1 value is written by the
	; move.b -1(A6),D1 (which is always the current d1 value !!!)
	; According to other part in this source I assume it is a:
	; subq #1,a6
	; Which has the effect to load previous value. That seems more
	; meaningfull to me.
	; This bug is probably the reason of time calculation bugs in
	; many SidSound file...
	;
	;	subq.b	#1,D1

	subq	#1,a6
	move.b	-1(A6),D1
	
L004F:	move.l	A6,72(A0)
	tst.b	D1
	bne.s	L0051
	
L0050:	bclr	#2,44(A0)
L0051:	rts

; 
; 
; IN:	d6	sound-bit
;	d7	noise-bit
;	d0	current mixer bits
;	a0	Voice data
;	a5	YM hardware
;
; OUT:	d0	updated
;	YM noise period updated 
;
; 
SetMixerAndNoise:
	btst	#0,44(A0)
	beq.s	.toneOFF
	
	tst.b	61(A0)
	bne.s	.toneON
	
	tst.b	79(A0)
	beq.s	.toneOFF
.toneON:	
	bclr	D6,D0
	
.toneOFF:

	btst	#1,44(A0)
	beq.s	.exit
	tst.b	60(A0)
	bne.s	.noNoiseCtl
	
	move.w	#$0600,D5
	move.b	43(A0),D5
	movep.w D5,0(A5)
	bra.s	.noiseON
	
.noNoiseCtl:

	movea.l 64(A0),A6
	move.b	(A6)+,D1
	cmpi.b	#$FF,D1		; NOP
	beq.s	.exit
	cmpi.b	#$FE,D1		; END
	bne.s	.okSequence
	
	subq.l	#1,A6
	move.b	-1(A6),D1
	
.okSequence

	move.l	A6,64(A0)
	move.w	#$0600,D5
	move.b	D1,D5
	movep.w D5,0(A5)
	tst.b	78(A0)
	beq.s	.exit
.noiseON:
	bclr	D7,D0
.exit:	
	rts



	
L0059:	tst.b	58(A0)
	bne	L007B
	btst	#2,44(A0)
	beq.s	L005D

	cmpi.b	#$0D,$003F(A0)	;******; ???
	bne.s	L005C
	moveq	#1,D7
L005A:	movea.w #$8800,A6
	moveq	#0,D0
	move.b	0(A0),D0
	add.b	83(A0),D0
	lea	L007C(PC),A2
	andi.w	#$003F,D0

	move.w	#$2700,sr
	move.b	#$B,(a6)		;buzzer frequency
	move.b	0(A2,D0.w),2(a6)
	move.l	#$0C000000,(a6)
	move.b	#$09,(a6)		;channel B volume
	move.w	#$2300,sr

	addq.b	#1,83(A0)
	cmpi.b	#$3F,83(A0)
	ble.s	L005B
	move.b	D4,83(A0)
L005B:	bra.s	L0060
L005C:	move.b	D4,83(A0)
	move.b	#$10,14(A0)
	bra.s	L0060
	
L005D:	move.w	20(A0),D0
	movea.l 16(A0),A2
	move.b	0(A2,D0.w),D1
	move.b	15(A0),D2
	asl.b	#4,D2
	add.b	D1,D2
	andi.w	#$00FF,D2
	lea	L0122(PC),A2
	move.b	0(A2,D2.w),14(A0)
	addq.w	#1,D0
	cmp.w	24(A0),D0
	bne.s	L005E
	move.w	22(A0),D0
L005E:	cmp.w	26(A0),D0
	bcs.s	L005F
	bset	#0,58(A0)
L005F:	move.w	D0,20(A0)
L0060:	move.w	6(A0),D0
	beq.s	L0064
	bmi.s	L0062
	add.w	4(A0),D0
	cmp.w	2(A0),D0
	blt.s	L0061
	move.w	D4,6(A0)
	move.w	2(A0),D0
L0061:	move.w	D0,4(A0)
	bra.s	L0064
L0062:	add.w	4(A0),D0
	cmp.w	2(A0),D0
	bgt.s	L0063
	move.w	D4,6(A0)
	move.w	2(A0),D0
L0063:	move.w	D0,4(A0)
L0064:	move.w	8(A0),D1
	add.w	10(A0),D1
	cmpi.w	#$003B,D1
	bls.s	L0065
	moveq	#0,D1
L0065:	move.w	D1,8(A0)
	add.w	D1,D1
	lea	L011C(PC),A2
	move.w	0(A2,D1.w),D1
	move.w	12(A0),D2
	asr.w	D2,D1
	add.w	4(A0),D1
.noPatBrk:		
	cmpi.b	#1,63(A0)
	bne.s	L0066
	lea	L007D(PC),A1
	move.b	76(A0),D7
	ext.w	D7
	move.b	0(A1,D7.w),56(A0)
	addq.b	#1,76(A0)
	cmpi.b	#1,76(A0)
	blt.s	L0066
	move.b	#1,76(A0)
	
L0066:	cmpi.b	#4,63(A0)
	bne.s	L0067
	lea	L007D(PC),A1
	move.b	76(A0),D7
	ext.w	D7
	move.b	0(A1,D7.w),56(A0)
	addq.b	#1,76(A0)
	cmpi.b	#1,76(A0)
	blt.s	L0067
	move.b	#1,76(A0)
	
L0067:	cmpi.b	#5,63(A0)
	bne.s	L0068
	lea	L0080(PC),A1
	move.b	77(A0),D7
	ext.w	D7
	move.b	0(A1,D7.w),56(A0)
	addq.b	#2,77(A0)
	cmpi.b	#$0C,77(A0)
	blt	L0072
	move.b	D4,77(A0)
	
L0068:	cmpi.b	#6,63(A0)
	bne.s	L0069
	lea	L007E(PC),A1
	move.b	76(A0),D7
	ext.w	D7
	move.b	0(A1,D7.w),56(A0)
	addq.b	#1,76(A0)
	cmpi.b	#$40,76(A0)
	blt.s	L0069
	move.b	#1,76(A0)
	
L0069:	cmpi.b	#7,63(A0)
	bne.s	L006A
	lea	L007F(PC),A1
	move.b	77(A0),D7
	ext.w	D7
	move.b	0(A1,D7.w),56(A0)
	addq.b	#2,77(A0)
	cmpi.b	#$20,77(A0)
	blt.s	L006A
	move.b	#2,77(A0)
	
L006A:	cmpi.b	#8,63(A0)
	bne.s	L006B
	lea	L0081(PC),A1
	move.b	76(A0),D7
	ext.w	D7
	move.b	0(A1,D7.w),56(A0)
	addq.b	#1,76(A0)
	cmpi.b	#$30,76(A0)
	blt.s	L006B
	move.b	D4,76(A0)
	
L006B:	cmpi.b	#9,63(A0)
	bne.s	L006C
	lea	L0082(PC),A1
	move.b	77(A0),D7
	ext.w	D7
	move.b	0(A1,D7.w),56(A0)
	addq.b	#1,77(A0)
	cmpi.b	#$20,77(A0)
	blt.s	L006C
	move.b	D4,77(A0)
	
L006C:	cmpi.b	#$0A,63(A0)
	bne.s	L006E
	lea	L0082(PC),A1
	move.b	77(A0),D7
	ext.w	D7
	move.b	0(A1,D7.w),56(A0)
	addq.b	#1,77(A0)
	cmpi.b	#$20,77(A0)
	blt.s	L006D
	move.b	D4,77(A0)
L006D:	lea	L0080(PC),A1
	move.b	76(A0),D7
	ext.w	D7
	move.b	0(A1,D7.w),56(A0)
	addq.b	#1,76(A0)
	cmpi.b	#4,76(A0)
	blt.s	L006E
	move.b	D4,76(A0)
	
L006E:	cmpi.b	#$0B,63(A0)
	bne.s	L0070
	lea	L0084(PC),A1
	move.b	76(A0),D7
	ext.w	D7
	move.b	0(A1,D7.w),56(A0)
	addq.b	#1,76(A0)
	cmpi.b	#$10,76(A0)
	blt.s	L006F
	move.b	D4,76(A0)
L006F:	lea	L007F(PC),A1
	move.b	77(A0),D7
	ext.w	D7
	move.b	0(A1,D7.w),56(A0)
	addq.b	#1,77(A0)
	cmpi.b	#$12,77(A0)
	blt.s	L0070
	move.b	D4,77(A0)
	
L0070:	cmpi.b	#$0C,63(A0)
	bne.s	L0071
	tst.b	58(A0)
	bne.s	L0071
	btst	#2,44(A0)
	beq.s	L0071
	lea	L0083(PC),A1
	move.b	82(A0),D7
	ext.w	D7
	move.b	0(A1,D7.w),D0
	move.b	D0,56(A0)
	andi.w	#$003F,D0
	add.w	D0,32(A0)
	addq.b	#1,82(A0)
	cmpi.b	#$2A,82(A0)
	blt.s	L0071
	move.b	D4,82(A0)
	
L0071:	cmpi.b	#2,63(A0)
	bne.s	L0072
	lea	L0080(PC),A1
	move.b	77(A0),D7
	ext.w	D7
	move.b	0(A1,D7.w),56(A0)
	addq.b	#2,77(A0)
	cmpi.b	#$0C,77(A0)
	blt.s	L0072
	move.b	D4,77(A0)
L0072:	move.b	56(A0),D0
	beq.s	L0074

	cmpi.b	#1,D0
	beq.s	L0073
	add.w	54(A0),D1
	move.b	D4,56(A0)
	bra.s	L0075
L0073:	add.w	52(A0),D1
L0074:	addq.b	#1,56(A0)

L0075:	tst.b	40(A0)
	beq.s	L0079
	move.w	32(A0),D0
	movea.l 28(A0),A2
	move.b	0(A2,D0.w),D2
	ext.w	D2
	tst.b	60(A0)
	beq.s	L0076
	add.w	D2,D1
	add.w	D2,D1
	add.w	D2,D1
L0076:	add.w	D2,D1
	addq.w	#1,D0
	cmp.w	36(A0),D0
	bne.s	L0077
	move.w	34(A0),D0
L0077:	cmp.w	38(A0),D0
	bcs.s	L0078
	move.b	D4,40(A0)
L0078:	move.w	D0,32(A0)
L0079:	move.w	D1,0(A0)
	cmpi.b	#$0D,63(A0)
	bne.s	L007A
	dbra	D7,L005A
L007A:	moveq	#0,D7
	rts
L007B:	move.b	D4,14(A0)
	rts
L007C:	DC.B $F0,$E2,$D4,$C8,$BE,$B2,$A8,$9E
	DC.B $96,$8E,$86,'~xqjd'
	DC.B '_YTOKGC?'
	DC.B '<852/-;('
	DC.B '&','$',$22,' ',$1E,$1C,$1B,$19
	DC.B $18,$16,$15,$14,$13,$12,$11,$10
	DC.B $0F,$0E,$0D,$0C,$0B,$0A,$09,$08
	DC.B $07,$06,$05,$04,$03,$02,$01,$00
L007D:	DC.B $01,$00,$FF
L007E:	DC.B $01,$00,$01,$00,$02,$00,$02,$00,$03
	DC.B $00,$FF
L007F:	DC.B $00,$00,$01,$01,$02,$02,$03,$03
	DC.B $04,$04,$05,$05,$06,$06,$05,$05
	DC.B $04,$04,$03,$03,$02,$02,$01,$01
	DC.B $00,$00,$FF
L0080:	DC.B $00,$00,$01,$01,$02,$02,$FF
L0081:	DC.B $09,$09,$05,$05,$03,$03,$01,$01
	DC.B $02,$01,$01,$02,$02,$03,$03,$03
	DC.B $04,$04,$05,$00,$01,$02,$FF
L0082:	DC.B $00,$08,$00,$07,$00,$06,$00,$05,$00
	DC.B $04,$00,$03,$00,$02,$00,$01,$00
	DC.B $01,$01,$00,$02,$00,$03,$00,$04
	DC.B $00,$05,$00,$06,$00,$FF,$01,$01
	DC.B $01,$00,$00,$00,$02,$02,$02,$00
	DC.B $00,$00,$03,$03,$03,$00,$00,$00
	DC.B $04,$04,$04,$00,$00,$00,$05,$05
	DC.B $05,$FF
L0083:	DC.B $10,$0F,$10,$0E,$10,$0D,$10,$0C
	DC.B $10,$0B,$10,$0A,$10,$09,$10,$08
	DC.B $10,$07,$10,$06,$10,$05,$10,$04
	DC.B $10,$03,$10,$02,$10,$01,$10,$10
	DC.B $10,$10,$09,$08,$06,$04,$02,$00
	DC.B $02,$FF
L0084:	DC.B $00,$09,$00,$08,$00,$07,$00,$06
	DC.B $00,$05,$00,$04,$00,$03,$00,$02
	DC.B $00,$01,$00,$01,$02,$03,$04,$05
	DC.B $06,$07,$08,$09,$FF,$00
	
ToggleSidDephaseA:
	not.w	SidDephaseA
	rts
	
ToggleSidDephaseB:	
	not.w	SidDephaseB
	rts
	
ToggleSidDephaseC:	
	not.w	SidDephaseC
	rts
	
ActivSidVoiceA: 
	;move.l	#tb0,$00000120.w	;Timer B
	st	SidOnOffA
	rts
	
ActivSidVoiceB: 
	move.l	#gwem_on,$00000134.w
	st	SidOnOffB
	rts
	
ActivSidVoiceC: 
	;move.l	#td0,$00000110.w
	st	SidOnOffC
	rts

StopSidVoiceA:
	;move.l	#VoidIrq,$00000120.w	;Timer B
	sf	SidOnOffA
	rts
	
StopSidVoiceB:	
	move.l	#VoidIrq,$00000134.w
	sf	SidOnOffB
	rts

StopSidVoiceC:	
	;move.l	#VoidIrq,$00000110.w
	sf	SidOnOffC
	rts

L008E:	move.l	#L00B5,L000D
	rts
	
L008F:	move.l	#L00B6,L000D
	rts
	
L0090:	move.l	#L00B7,L000D
	
FxNone:	rts
	
	
L0092:	move.l	#L00B5,L000D
	move.w	L0121(PC),L011E
	st	SidDephaseA
	st	SidDephaseB
	st	SidDephaseC
	st	SidOnOffA
	st	SidOnOffB
	st	SidOnOffC
	rts

i_flag:	DC.W 0

init_music:
	movem.l A0-A1,-(a7)

	lea	i_flag(PC),A3
	tst.w	(A3)
	bne.s	already_in_relo
	st	(A3)

	IFEQ test
	bsr	relocate_player
	ENDC

	bsr	save_MFP
	bsr	save_h200
already_in_relo:
	movem.l (a7)+,A0-A1

	moveq	#0,D0		;3 SID-voices
	move.w	D0,L011D

	move	#$2700,SR

	move.l	A0,VoiceSetPtr	;Voiceset
	move.l	A1,SoundDataPtr	;Sounddata

	movea.l VoiceSetPtr(PC),A0
	lea	516(A0),A0
	move.l	A0,InstBasePtr
	
	movea.l SoundDataPtr(PC),A0
	addq.l	#4,A0
	move.w	(A0),L0121
	
	move.l	A0,L0003
	move.l	A0,L002A
	addq.l	#2,A0
	move.l	A0,SongRePtr
	addq.l	#2,A0
	move.l	A0,SongLenPtr
	addq.l	#2,A0
	move.l	A0,L009E
	addq.l	#2,A0
	move.l	A0,SongBasePtr
	lea	120(A0),A0
	move.l	A0,L00A0
	move.l	A0,RePatPtr
	move.l	A0,ReCurPatPtr
	lea	CurInfo(PC),A1
	
	movea.l VoiceSetPtr(PC),A0
	lea	16900(A0),A0
	cmpi.l	#"INFO",(A0)+
	beq.s	.okInfo
	lea	DefaultInfo(PC),A0
.okInfo:	
	moveq	#$1F,D0			; $$$ ben: overflow !!!
.cpyInfo:	
	move.l	(A0)+,(A1)+
	move.l	(A0)+,(A1)+
	dbra	D0,.cpyInfo
	
	bsr	L009C

	bclr	#3,$FFFFFA17.w	;auto eoi

	;bsr	copy_sid_psg_rout

	;move.l	#td0,$00000110.w ;Timer D
	;andi.b	#$F0,$FFFFFA1D.w
	;ori.b	#1,$FFFFFA1D.w
	;clr.b	$FFFFFA25.w
	;bset	#4,$FFFFFA15.w
	;bclr	#4,$FFFFFA09.w

L0096:	;move.l	#tb0,$120.w	;Timer B
	;move.b	#%11,$fffffa1b.w
	;clr.b	$fffffa21.w
	;bset	#0,$fffffa13.w
	;bclr	#0,$fffffa07.w

L0097:	move.l	#gwem_on,$00000134.w ;Timer A
	clr.b	$FFFFFA19.w
	move.b	#1,$FFFFFA19.w
	move.b	#1,$FFFFFA1F.w
	bset	#5,$FFFFFA13.w
	bclr	#5,$FFFFFA07.w
	bsr.s	YmReset

	st	do_replay_flag
	sf	music_off_flag
	move	#$2300,SR
	rts


YmReset:	
	lea	VoiceData_B(PC),A0
	bclr	#5,$FFFFFA07.w	;Timer A
	;bclr	#4,$FFFFFA09.w	;Timer D
	bset	#0,224(A0)
	bclr	#1,224(A0)
	bset	#0,60(A0)
	bset	#0,142(A0)
	st	223(A0)
	st	59(A0)
	st	141(A0)
	lea	$FFFF8800.w,A0
	lea	YmShadow(PC),A1
	moveq	#$0C,D1
.lpReg:	move.w	(A1)+,D0
	movep.w D0,0(A0)
	dbra	D1,.lpReg
	
	move.b	#7,(A0)
	move.b	(A0),D0
	andi.b	#$C0,D0
	ori.b	#$3F,D0
	move.b	D0,2(A0)
	rts

YmShadow:	
	DC.B $00,$00,$01,$00,$02,$00,$03,$00
	DC.B $04,$00,$05,$00,$06,$00,$08,$00
	DC.B $09,$00,$0A,$00,$0B,$00,$0C,$00
	DC.B $0D,$00

	
L009C:	bsr.s	L009D
	clr.w	PatPos
	;clr.b	ta1+4.w	;8
	bra	L00AD
	
L009D:	move.w	#1,L009D
L009E	= *-4
	moveq	#$1F,D0
L009F:	lea	L009F,A0
L00A0	= *-4
	move.l	#$00020005,D7
	lea	PatPtrTbl(PC),A1
L00A1:	move.l	A0,(A1)+
	lea	768(A0),A0
	dbra	D0,L00A1
	move.w	#1,L013A
	clr.w	CurSongPos
L00A2:	move.l	#L00A2,PatPtr
RePatPtr:	= *-8
L00A4:	move.l	#L00A4,CurPatPtr
ReCurPatPtr	= *-8

	lea	L012E(PC),A1
	lea	VoiceData_B(PC),A0
	moveq	#9,D1
	moveq	#2,D2
.lpChannel:
	clr.b	46(A0)
	move.l	A1,16(A0)
	move.l	D7,24(A0)
	move.w	D1,28(A0)
	move.l	A1,30(A0)
	move.l	D7,36(A0)
	move.w	D1,40(A0)
	lea	82(A0),A0
	dbra	D2,.lpChannel
	rts

		
ReadSong:	
	move.w	D4,PatPos
	move.w	CurSongPos(PC),D0
	addq.w	#1,D0
L00A8:	cmp.w	L00A8,D0
SongLenPtr:	= *-4
	bls.s	L00AC
L00AA:	move.w	L00AA,D0
SongRePtr:	= *-4
	
L00AC:	move.w	D0,CurSongPos
L00AD:	lea	L00AD,A0
SongBasePtr:	= *-4
	move.w	CurSongPos(PC),D0
	move.b	0(A0,D0.w),D0
	andi.w	#$007F,D0
	move.w	D0,CurPatNum
	lea	PatPtrTbl(PC),A0
	add.w	D0,D0
	add.w	D0,D0
	move.l	0(A0,D0.w),CurPatPtr
	rts

SidDephaseA:	DC.B $00,$01
SidDephaseB:	DC.B $00,$01
SidDephaseC:	DC.B $00,$01
	
SidOnOffA	DC.B $FF,$FF
SidOnOffB:	DC.B $FF,$FF
SidOnOffC:	DC.B $FF,$FF
	
L00B5:	DC.B $00,'h',$00,$04,$00,$01,$01,$05
	DC.B $00,$0A,$00,$02,$01,$A2,$00,$10
	DC.B $00,$03,$05,$1A,$00,'2',$00,$04
	DC.B $06,$88,$00,'@',$00,$05,$0A,'5'
	DC.B $00,'d',$00,$06,$0E,$EF,$00,$C8
	DC.B $00,$07,$FF,$FF
	
L00B6:	DC.B $00,'h',$00,$04,$00,$01,$01,$05
	DC.B $00,$14,$00,$02,$01,$A0,$00,$10
	DC.B $00,$03,$05,$19,$00,'d',$00,$04
	DC.B $03,'@',$00,'@',$00,$05,$0A,'2'
	DC.B $00,$C8,$00,$06,$0E,$A0,$01,$00
	DC.B $00,$07,$0F,'K',$00,'h',$00,$04
	DC.B $00,$01,$01,$05,$00,$14,$00,$02
	DC.B $01,$A0,$00,$10,$00,$03,$05,$19
	DC.B $00,'d',$00,$04,$03,'@',$00,'@'
	DC.B $00,$05,$0A,'2',$00,$C8,$00,$06
	DC.B $0E,$A0,$01,$00,$00,$07,$0F,'K'
	DC.B $FF,$FF
	
L00B7:	DC.B $00,'h',$00,$04,$00,$01,$01,$05
	DC.B $00,$1E,$00,$02,$01,$A0,$00,$10
	DC.B $00,$03,$05,$19,$00,$96,$00,$04
	DC.B $03,'@',$00,'@',$00,$05,$0A,'2'
	DC.B $01,',',$00,$06,$0E,$A0,$01,$00
	DC.B $00,$07,$0F,'K',$00,'h',$00,$04
	DC.B $00,$01,$01,$05,$00,$1E,$00,$02
	DC.B $01,$A0,$00,$10,$00,$03,$05,$19
	DC.B $00,$96,$00,$04,$03,'@',$00,'@'
	DC.B $00,$05,$0A,'2',$01,',',$00,$06
	DC.B $0E,$A0,$01,$00,$00,$07,$0F,'K'
	DC.B $FF,$FF
	
DefaultInfo:	
	DC.B $01,$01,$00,$00,$02,$02,$00,$00
	DC.B $00,$00,$01,$00,$00,$00,$00,$03
	DC.B $00,$00,$00,$03,$03,$03,$00,$01
	DC.B $00,$00,$00,$01,$00,$00,$00,$02
	DC.B $00,$00,$00,$02,$00,$00,$00,$02
	DC.B $00,$00,$00,$02,$00,$00,$00,$01
	DC.B $00,$00,$00,$03,$00,$00,$00,$00
	DS.W 17
	DC.B $00,$03,$00,$00,$00,$00,$00,$00
	DS.W 77

	
NoiseSeqTbl	
	DC.L L00BC
	DC.L L00BD
	DC.L L00BE
	DC.L L00BF
	DC.L L00C0
	DC.L L00C1
	DC.L L00C2
	DC.L L00C3
	DC.L L00C4
	DC.L L00C5
	DC.L L00C6
	DC.L L00C7
	DC.L L00C8
	DC.L L00C9
	DC.L L00CA
	DC.L L00CB
	DC.L L00CC
	DC.L L00CD
	DC.L L00CE
	DC.L L00CF
	DC.L L00D0
	DC.L L00D1
	DC.L L00D2
	DC.L L00D3
	DC.L L00D4
	DC.L L00D5
	DC.L L00D6
	DC.L L00D7
	DC.L L00D8
	DC.L L00D9
	DC.L L00DA
	DC.L L00DB
	DC.L L00DC
	DC.L L00DD
	DC.L L00DE
	DC.L L00DF
	DC.L L00E0
	DC.L L00E1
	DC.L L00E2
	DC.L L00E3
	DC.L L00E4
	DC.L L00E5
	DC.L L00E6
	DC.L L00E7
	DC.L L00E8
	DC.L L00E9
	DC.L L00EA
	
L00BA:	DC.L L00EB
	DC.L L00EC
	DC.L L00ED
	DC.L L00EE
	DC.L L00EF
	DC.L L00F0
	DC.L L00F1
	DC.L L00F2
	DC.L L00F3
	DC.L L00F4
	DC.L L00F5
	DC.L L00F6
	DC.L L00F7
	DC.L L00F8
	DC.L L00F9
	DC.L L00FA
	DC.L L00FB
	DC.L L00FC
	DC.L L00FD
	DC.L L00FE
	DC.L L00FF
	DC.L L0100
	DC.L L0101
	DC.L L0102
	DC.L L0103
	DC.L L0104
	DC.L L0105
	DC.L L0106
	DC.L L0107
	DC.L L0108
	DC.L L0109
	DC.L L010A
	DC.L L010B
	DC.L L010C
	
L00BB:	DC.L L010D
	DC.L L010E
	DC.L L010F
	DC.L L0110
	DC.L L0111
	DC.L L0112
	DC.L L0113
	DC.L L0114
	DC.L L0115
	DC.L L0116
	DC.L L0117
	DC.L L0118
	DC.L L0119
	DC.L L011A
	DC.L L011B
	DC.L L011B
	DC.L L011B
	DC.L L011B
	DC.L L011B
	DC.L L011B
	DC.L L011B
	DC.L L011B
	DC.L L011B
	DC.L L011B

	;; Noise sequences
	
L00BC:	DC.B $10,$FF
L00BD:	DC.B $0A,$11,$0F,$11,$0D,$0C,$08,$FF
L00BE:	DC.B $04,$FF
L00BF:	DC.B $03,$FF
L00C0:	DC.B $20,$20,$FF
L00C1:	DC.B $09,$20,$20,$FF
L00C2:	DC.B $20,$09,$0C,$20,$FF
L00C3:	DC.B $20,$04,$08,$0E,$12,$16,$1A,$1E,$FE
L00C4:	DC.B $20,$FE
L00C5:	DC.B $20,$FE
L00C6:	DC.B $11,$FE
L00C7:	DC.B $20,$08,$FE
L00C8:	DC.B $0D,$09,$FE
L00C9:	DC.B $13,$0E,$0C,$0B,$04,$FE
L00CA:	DC.B $20,$20,$19,$0A,$05,$03,$02,$01,$FE
L00CB:	DC.B $01,$02,$03,$04,$05,$06,$07,$08
	DC.B $07,$06,$05,$04,$03,$02,$01,$FE
L00CC:	DC.B $0D,$03,$0D,$05,$0D,$11,$06,$11
	DC.B $06,$FE
L00CD:	DC.B $0E,$15,$FE
L00CE:	DC.B $0F,$18,$FE
L00CF:	DC.B $18,$FF
L00D0:	DC.B $06,$15,$0C,$15,$07,$15,$04,$15
	DC.B $08,$FF
L00D1:	DC.B $20,$FF
L00D2:	DC.B $0F,$16,$14,$16,$12,$11,$0D,$FF
L00D3:	DC.B $20,$20,$18,$10,$08,$FF
L00D4:	DC.B $14,$1B,$19,$1B,$17,$16,$12,$FF
L00D5:	DC.B '0',$08,$FF
L00D6:	DC.B '/',$05,'/',$03,";",$01,$FF
L00D7:	DC.B $08,$10,'P',$FF
L00D8:	DC.B $14,$12,$10,$0E,$0C,$0A,$08,$FF
L00D9:	DC.B $12,$08,$FF
L00DA:	DC.B $16,$12,"(+;)(",$FF
L00DB:	DC.B $04,$FF
L00DC:	DC.B $02,$12,'1',$01,'%',$05,'6',$06,$FF
L00DD:	DC.B $0A,$0B,$0C,$0D,$0E,$0F,$FF
L00DE:	DC.B ')',$01,$FF
L00DF:	DC.B $0B,$FF
L00E0:	DC.B $0A,$00,$00,$00,$0E,$04,$04,$FF
L00E1:	DC.B '+',$FF
L00E2:	DC.B $15,$02,$FF
L00E3:	DC.B $0C,$01,$02,$01,$FF
L00E4:	DC.B $0D,$0D,$0D,$01,$03,$FF
L00E5:	DC.B $01,$FF
L00E6:	DC.B $14,$04,$0A,$02,$FF
L00E7:	DC.B $0C,$01,$04,$0E,$04,$10,$04,$12,$FF
L00E8:	DC.B $00,$00,$09,$FF
L00E9:	DC.B $00,$00,$09,$0C,$FF
L00EA:	DC.B $00,$00,$00,$01,$01,$01,$00,$00,$01
	DC.B $01,$00,$01,$FF

	
L00EB:	DC.B $01,$02,$FE
L00EC:	DC.B $03,$02,$02,$02,$01,$01,$FE
L00ED:	DC.B $03,$02,$FE
L00EE:	DC.B $07,$04,$04,$04,$02,$02,$FF
L00EF:	DC.B $01,$00,$00,$00,$01,$00,$0E,$0F
	DC.B $0F,$0E,$0C,$08,$00,$FE
L00F0:	DC.B $00,$02,$02,$02,$02,$03,$00,$0E
	DC.B $0D,$0C,$FE
L00F1:	DC.B $03,$00,$0E,$00,$0D,$0B,$09,$07,$05
	DC.B $03,$01,$00,$FE
L00F2:	DC.B $02,$0E,$00,$00,$02,$02,$00,$01
	DC.B $10,$FE
L00F3:	DC.B $0C,$04,$00,$00,$0C,$0D,$FE
L00F4:	DC.B $02,$03,$03,$00,$00,$0C,$0D,$FE
L00F5:	DC.B $01,$00,$00,$00,$02,$00,$0F,$0F,$0E
	DC.B $0D,$0C,$0C,$00,$FE
L00F6:	DC.B $06,$00,$00,$00,$00,$FE
L00F7:	DC.B $19,$14,$0F,$0A,$05,$00,$FE
L00F8:	DC.B $00,$01,$00,$07,$0C,$FE
L00F9:	DC.B $00,$00,$18,$0C,$00,$FE
L00FA:	DC.B $14,$0A,$00,$FE
L00FB:	DC.B $03,$04,$FE
L00FC:	DC.B $08,$05,$05,$05,$05,$05,$05,$04,$04
	DC.B $04,$03,$03,$02,$02,$01,$FE
L00FD:	DC.B $08,$07,$FE
L00FE:	DC.B $05,$04,$03,$02,$01,$02,$03,$04
	DC.B $05,$06,$07,$08,$09,$0A,$FE
L00FF:	DC.B $08,$0A,$FE
L0100:	DC.B $09,$08,$08,$08,$08,$08,$08,$08
	DC.B $07,$07,$07,$06,$06,$05,$FE
L0101:	DC.B $09,$06,$FE
L0102:	DC.B $0A,$0B,$0C,$0D,$0E,$0F,$FE
L0103:	DC.B $0B,$0C,$0D,$0E,$0F,$FE
L0104:	DC.B $01,$0B,$01,$0C,$01,$0D,$FE
L0105:	DC.B '(',$04,'(',$04,'(',$04,'(',$FE
L0106:	DC.B $01,$02,$03,$04,$05,$06,$07,$08
	DC.B $09,$0A,$09,$08,$07,$06,$05,$04
	DC.B $03,$02,$01,$FE
L0107:	DC.B $09,$08,$07,$06,$05,$04,$03,$02
	DC.B $01,$02,$03,$04,$05,$06,$07,$08
	DC.B $09,$FE
L0108:	DC.B $0A,$00,$09,$00,$08,$00,$07,$00
	DC.B $06,$00,$05,$00,$04,$00,$03,$00
	DC.B $02,$00,$01,$00,$FE
L0109:	DC.B $14,$12,$10,$0E,$0C,$0A,$08,$07,$06
	DC.B $05,$04,$03,$02,$01,$FE
L010A:	DC.B $20,$01,$10,$02,$FE
L010B:	DC.B $0A,$14,$00,$14,$0A,$FE
L010C:	DC.B $0A,$05,$FE


	
L010D:	DC.B $01,$01,$01,$FF
L010E:	DC.B $01,$01,$FF
L010F:	DC.B $01,$FF
L0110:	DC.B $01,$01,$01,$01,$FE
L0111:	DC.B $0A,$0B,$0C,$0D,$0E,$0F,$FE
L0112:	DC.B $01,$01,$01,$01,$01,$FE
L0113:	DC.B $01,$01,$01,$01,$01,$01,$FE
L0114:	DC.B '(((((((',$FE
L0115:	DC.B $01,$01,$01,$01,$01,$01,$01,$01
	DC.B $FE
L0116:	DC.B $01,$02,$01,$02,$01,$02,$01,$02,$FE
L0117:	DC.B $02,$01,$02,$01,$02,$01,$02,$01
	DC.B $FE
L0118:	DC.B $01,$03,$01,$03,$01,$03,$01,$03,$FE
L0119:	DC.B $03,$01,$03,$01,$03,$01,$03,$01,$FE
L011A:	DC.B $01,$04,$01,$04,$01,$04,$01,$04,$FE
L011B:	DC.B $01,$01,$04,$01,$04,$01,$04,$01
	DC.B $FE,$01,$01,$04,$01,$04,$01,$04
	DC.B $01,$FE,$01,$01,$04,$01,$04,$01
	DC.B $04,$01,$FE,$01,$01,$04,$01,$04
	DC.B $01,$04,$01,$FE
L011C:	DC.B $00,$00,$01,$AC,$03,'T',$04,$F2
	DC.B $06,$82,$08,$00,$09,'h',$0A,$B5
	DC.B $0B,$E4,$0C,$F2,$0D,$DB,$0E,$9E
	DC.B $0F,'8',$0F,$A6,$0F,$EA,$10,$00
	DC.B $0F,$EA,$0F,$A6,$0F,'8',$0E,$9E
	DC.B $0D,$DB,$0C,$F2,$0B,$E4,$0A,$B5
	DC.B $09,'h',$08,$00,$06,$82,$04,$F2
	DC.B $03,'T',$01,$AC,$00,$00,$FE,'T'
	DC.B $FC,$AC,$FB,$0E,$F9,'~',$F8,$00
	DC.B $F6,$98,$F5,'K',$F4,$1C,$F3,$0E
	DC.B $F2,'%',$F1,'b',$F0,$C8,$F0,'Z'
	DC.B $F0,$16,$F0,$00,$F0,$16,$F0,'Z'
	DC.B $F0,$C8,$F1,'b',$F2,'%',$F3,$0E
	DC.B $F4,$1C,$F5,'K',$F6,$98,$F8,$00
	DC.B $F9,'~',$FB,$0E,$FC,$AC,$FE,'T'
	DC.B $00,$00
L011D:	DC.B $00,$00
L011E:	DC.B $00,$00
PatBreakFlag:	
	DC.B $00,$00
L0120:	DC.B $00,$00
L0121:	DC.B $00,$00
	
L0122:	DS.W 12
	DC.B $01,$01,$01,$01,$01,$01,$01,$01
	DS.W 2
	DC.B $01,$01,$01,$01,$01,$01,$01,$01
	DC.B $02,$02,$02,$02,$00,$00,$00,$01
	DC.B $01,$01,$01,$01,$02,$02,$02,$02
	DC.B $02,$03,$03,$03,$00,$00,$01,$01
	DC.B $01,$01,$02,$02,$02,$02,$03,$03
	DC.B $03,$03,$04,$04,$00,$00,$01,$01
	DC.B $01,$02,$02,$02,$03,$03,$03,$04
	DC.B $04,$04,$05,$05,$00,$00,$01,$01
	DC.B $02,$02,$02,$03,$03,$04,$04,$04
	DC.B $05,$05,$06,$06,$00,$00,$01,$01
	DC.B $02,$02,$03,$03,$04,$04,$05,$05
	DC.B $06,$06,$07,$07,$00,$01,$01,$02
	DC.B $02,$03,$03,$04,$04,$05,$05,$06
	DC.B $06,$07,$07,$08,$00,$01,$01,$02
	DC.B $02,$03,$04,$04,$05,$05,$06,$07
	DC.B $07,$08,$08,$09,$00,$01,$01,$02
	DC.B $03,$03,$04,$05,$05,$06,$07,$07
	DC.B $08,$08,$09,$0A,$00,$01,$01,$02
	DC.B $03,$04,$04,$05,$06,$07,$07,$08
	DC.B $09,$0A,$0A,$0B,$00,$01,$02,$02
	DC.B $03,$04,$05,$06,$06,$07,$08,$09
	DC.B $0A,$0A,$0B,$0C,$00,$01,$02,$03
	DC.B $03,$04,$05,$06,$07,$08,$09,$0A
	DC.B $0A,$0B,$0C,$0D,$00,$01,$02,$03
	DC.B $04,$05,$06,$07,$07,$08,$09,$0A
	DC.B $0B,$0C,$0D,$0E,$00,$01,$02,$03
	DC.B $04,$05,$06,$07,$08,$09,$0A,$0B
	DC.B $0C,$0D,$0E,$0F,$FF,$00
	
YmPerTbl:
		DC.W $0FD1,$0EEE,$0E17,$0D4D,$0CBE,$0BD9,$0B2F,$0A8E
		DC.W $09F7,$0967,$08E0,$0861
	
		DC.W $07E8,$0777,$070C,$06A7,$0647,$05ED,$0598,$0547
		DC.W $04FC,$04B4,$0470,$0431
	
		DC.W $03F4,$03BB,$0385,$0353,$0323,$02F6,$02CB,$02A3
		DC.W $027D,$0259,$0238,$0218
	
		DC.W $01FA,$01DD,$01C2,$01A9,$0191,$017B,$0165,$0151
		DC.W $013E,$012C,$011C,$010C
	
		DC.W $00FD,$00EE,$00E1,$00D4,$00C8,$00BD,$00B2,$00A8
		DC.W $009F,$0096,$008E,$0086
	
		DC.W $007E,$0077,$0070,$006A,$0064,$005E,$0059,$0054
		DC.W $004F,$004B,$0047,$0043
		DC.W $003F,$003B,$0038,$0035,$0032,$002F,$002C,$003B
		DC.W $0027,$0025,$0023,$0021
	
		DC.W $001F,$001D,$001C,$001A,$0019,$0017,$0016,$0015
		DC.W $0013,$0012,$0011,$0010
	
		DC.W $000F,$000E,$000D,$000C,$000B,$000A,$0009,$0008
		DC.W $0007,$0006,$0005,$0004,$0003,$0002,$0001,$0000
		DC.W $0000


	
START_player_bss:

	;; $$$ ben: starting to reverse that voice struct :)
	;; 
	;; +0.W tone period
	;; +14.b current volume

	;; +43.b direct noise period
	;; +58.b flags [bit-1 desactive chan A]
	;; +60.b direct noise control (0:off)
	;; +61.b flag, affect tone-mixer (!0:force tone ON (may be sid))
	;; +78.l mask from mask table
	;; +79.b sound-flag (0:tone-off)

	;; +64.l pointer to noise sequence
	;; 
	;; 
	;; +72.l pointer to some sequence

	;; +44.b voice-flags
	;;	bit-0:tone
	;;	bit-1:noise
	;;	bit-2:involved in env control (0:no-env control)
	;;	bit-3:idem
	;; +78.b yet another noise affect flag [0:no noise but sequence read]
	
		rsreset
vc_dummy:	rs.b	82
vc_size:	rs.b	0
	

VoiceData_B:	DS.B vc_size ;43-2	;Playdata
VoiceData_C:	DS.B vc_size ;43-2	;Playdata
VoiceData_A:	DS.B vc_size ;43-2	;Playdata

CurInfo:	DS.W 126	; $$$ ben: init copies 32*8 = 256 bytes !
CurSongPos:	DC.W 0
CurPatNum:	DC.W 0
PatPtrTbl:	DS.L 120	; $$$ ben : should be 128 ?
CurPatPtr:	DC.L 0
PatPos:	DC.W 0
PatPtr	DC.L 0
L012E:	DS.W 5



end_player_bss:

L013A:	DC.B $00,$00

SoundDataPtr:	DC.L 0	; sound
VoiceSetPtr:	DC.L 0	; vset

relocate_player:
	movem.l D0-D1/A0-A3,-(a7)
	lea	r_flag(PC),A3
	tst.w	(A3)
	bne.s	already_relocated
	st	(A3)

	lea	music(PC),A3
	move.l	A3,D0

	lea	r_base(PC),A1
	adda.l	#relotab-r_base,A1

	adda.l	(A1)+,A3
	moveq	#0,D1
L013F:	add.l	D0,(A3)
L0140:	move.b	(A1)+,D1
	beq.s	L0142
	cmp.w	#2,D1
	bcs.s	L0141
	adda.w	D1,A3
	bra.s	L013F
L0141:	lea	254(A3),A3
	bra.s	L0140
L0142:

already_relocated:
	movem.l (a7)+,D0-D1/A0-A3

	rts

r_flag:	DC.W 0
r_base:

;..........................................................
	ds.b	65536+gwem_off-r_base

gwem_on:move.b	#$00,$FFFF8802.w	;SMC action
	subq.w	#1,$134.w
VoidIrq:rte

;..........................................................

relotab: