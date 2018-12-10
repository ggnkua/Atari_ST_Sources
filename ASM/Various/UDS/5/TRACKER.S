; ProTrackerFastReplay v1.0
; This is as quick as I can make it
; Uses registers d7 and a6 only
; Output through all three sound-channels

; Sorted at 4am (!) on Thursday 26th June
; Rewritten in 2 hours, debugged in 5 more.....

; Note to Michael of Cyber Punks
; You can use this tracker replay as much as you want, but
; please don't spread it at the moment.....the player is
; based on the routine by Wizzcat, supplied with Protracker 1.2
; but this is *much* faster. For 16Khz it takes approx 45% (!!!)
; Instructions same as for original Wizzcat replay...this though
; uses the VBL and timer D, instead od Timers A and D. You must
; call play_vbl in your own vbl-routine.

; Have fun!		TAT



;------------------------------- Cut here ------------------------------;
;		    Rout to test replay. May omitted.			;

final_stos=0

	ifeq	final_stos
	clr.l	-(sp)
	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp
	move.l	d0,-(sp)

	lea	data,a0
	lea	workspc,a1
	moveq	#1,d0
	bsr	playback
	move.l	#my_play_vbl,$70.w
	move.w	#$2300,sr

waitspc:
	btst	#0,$FFFFFC00.w
	beq.s	waitspc
	cmpi.b	#$B9,$FFFFFC02.w
	bne.s	waitspc
* Fade music off:
fading:
	moveq	#3,d0
.wait1	bsr	wait_vbl
	dbf	d0,.wait1
	subq.w	#1,playback+8
	bne	fading

	move.w	#$2700,sr
	lea	data,a0
	lea	workspc,a1
	moveq	#0,d0
	bsr	playback+0

	move.w	#$20,-(sp)
	trap	#1
	addq.w	#6,sp

	illegal
	pea	$4C0000
	trap	#1
	endc

wait_vbl:
	clr.l	$466.w
.wv	tst.l	$466.w
	beq	.wv
	rts

my_play_vbl:
	addq.l	#1,$466.w
	jsr	playback+4
	rte

;----------------------------PLAYBACK ROUTINE-----------------------
; Call with:
; a0: start of module .l
; a1: END of workspace .l

; d0: 0=stop   <>0 = start  .b			luvly

pad_no	equ 5
MVOL	EQU $40				; >= $40 ($60 recommended)
FREQ	EQU 1				; 0=6.144, 1=8.192, 2=12.288
					; 3=16.384
	IFEQ FREQ
A_DATA	EQU 40				; 6.144
D_DATA	EQU 164
PARTS	EQU 3-1
LEN	EQU 41
INC	EQU $02469BC0			; 3579546/6144*65536
	ELSEIF
	IFEQ FREQ-1
A_DATA	EQU 30				; 8.192
D_DATA	EQU 123
PARTS	EQU 4-1
LEN	EQU 41
INC	EQU $01B4F4D0			; 3579546/8192*65536
	ELSEIF
	IFEQ FREQ-2
A_DATA	EQU 20				; 12.288
D_DATA	EQU 164
PARTS	EQU 6-1		5
LEN	EQU 41		41
INC	EQU $01234DE0			; 3579546/12288*65536
	ELSEIF
	IFEQ FREQ-3
A_DATA	EQU 15				; 16.384
D_DATA	EQU 123
PARTS	EQU 4-1
LEN	EQU 82
INC	EQU $00DA7A68			; 3579546/16384*65536
	ELSEIF
	FAIL
	END
	ENDC
	ENDC
	ENDC
	ENDC

playback:
	jmp start(pc)
	jmp play_vbl(pc)

master_volume:	dc.w 64
song_position:	dc.w 0
beat_count:	dc.w 0

;------------------------------- Cut here ------------------------------;
start:	tst.b d0
	bne muson
	bra musoff

;---------------------------------------------------- Interrupts on/off --
muson	move.l	a0,save_module
	move.l	a1,workspace_end
	bsr	vol			; Calculate volume tables
	bsr	incrcal			; Calculate tonetables
	bsr	clearym			; Clear soundchip registers

	jsr	init			; Initialize music
	jsr	prepare			; Prepare samples

	move	#$2700,sr

	move.l	$FFFFFA06.w,s06		; Save MFP registers
	move.l	$FFFFFA12.w,s12
	move.b	$FFFFFA1D.w,s1d

	move.l	#$FF00FF10,$FFFFFA06.w	; Timer A & D on
	move.l	#$FF00FF10,$FFFFFA12.w
	bclr	#3,$FFFFFA17.w		; Autovectors

	clr.b	$FFFFFA1D.w
	move.b	#A_DATA,$FFFFFA25.w
	move.b	#$02,$FFFFFA1D.w
	move.l	$0110.w,oldtimd
	move.l	$70.w,oldvbl
	move.l	#playvec,$0110.w
	move.l	#dummy_vbl,$70.w
	lea	sample1(pc),a6
	lea	$ffff8800.w,a5
	move	#$2300,sr
	rts

musoff	move	#$2700,sr
	move.l	oldtimd(pc),$0110.w	; Restore vectors
	move.l	oldvbl(pc),$70.w
	move.l	s06(pc),$FFFFFA06.w
	move.l	s12(pc),$FFFFFA12.w
	move.b	s1d(pc),$FFFFFA1D.w
	move	#$2300,sr
	rts

s06	DC.L 0
s12	DC.L 0
s1d	DC.B 0
	EVEN

oldtimd	DC.L 0
oldvbl	dc.l 0

dummy_vbl:
	rte

;-------------------------------------------- Clear soundchip registers --
clearym	move	#$2700,sr
	moveq	#$0A,d0
._1	move.b	d0,$FFFF8800.w
	clr.b	$FFFF8802.w
	dbra	d0,._1			; Clear soundchip registers
	clr.b	$FFFF8800.w
	clr.b	$FFFF8802.w
	move.b	#7,$FFFF8800.w
	move.b	#$FF,$FFFF8802.w
	move.b	#$08,$ffff8800.w	;be careful!
	rts

;----------------------------------------------- Calculate volume table --
vol	move.l	#vtab+256,d1
	sub.b	d1,d1
	move.l	d1,a0
	move.l	d1,save_vtab
	lea	65*256(a0),a0

	moveq	#64,d0		; 0-64
.ploop	move.w	#127,d1
.mloop	move.w	d1,d2

	add.w d2,d2
	ext.w	d2
	muls	d0,d2
	divs	#MVOL,d2		; <---- Master volume

	add.b	#$80,d2		; sign it
	AND.W	#$FF,D2
	LSR.w	#1,d2		;convert to 7 bit
	lsl.w	#3,d2		; times 8 for table
	move.w	d2,-(a0)

	dbra	d1,.mloop
	dbra	d0,.ploop
	rts

save_module:	dc.l 0
workspace_end:	dc.l 0
save_vtab:	dc.l 0
save_usp:	dc.l 0
save_usp2:	dc.l 0
reached:	dc.l 0		debug aid!

;-------------------------------------------- Calculate increment-table --
incrcal	lea	stab(pc),a0
	move.w	#$30,d1
	move.w	#$039F-$30,d0
	move.l	#INC,d2

recalc	swap	d2
	moveq	#0,d3
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	swap	d4

	swap	d2
	move.w	d2,d3
	divu	d1,d3
	move.w	d3,d4
	move.l	d4,(a0)+

	addq.w	#1,d1
	dbra	d0,recalc
	rts

itab	DS.L $30
stab	DS.L $03A0-$30

;---------------------------------------------------- Samplecalculating --
play_vbl:
	move	#$2500,sr
	move.l a6,reached
	move.l	samp1(pc),a6
	lea $ffff8800.w,a5

	clr.b	$FFFFFA1D.w
	move.b	#A_DATA,$FFFFFA25.w
	move.b	#$02,$FFFFFA1D.w
	move.l	#playvec,$0110.w

	movem.l	d0-d6/a0-a4,-(sp)

	move.l	samp2(pc),d0
	move.l	samp1(pc),samp2
	move.l	d0,samp1

	lea wiz1lc(pc),a0
	lea big_routine+2(pc),a1
	bsr self_modify

	lea wiz2lc(pc),a0
	lea big_routine+10(pc),a1
	bsr self_modify

	lea wiz3lc(pc),a0
	lea big_routine+18(pc),a1
	bsr self_modify

	lea wiz4lc(pc),a0
	lea big_routine+26(pc),a1
	bsr self_modify

	move.l #priv,$8*4.w
	move.w #$0500,sr

	move.l a7,save_usp
	lea user_stack,a7

; Set up registers for big_routine:
; Ones needed

; d0=volume 1
; d1=volume 2
; d2=volume 3
; d3=volume 4

	lea volume_handle(pc),a0
	add.w master_volume(pc),a0
	add.w master_volume(pc),a0

	moveq #0,d0
	moveq #0,d1
	moveq #0,d2
	moveq #0,d3

	move.w aud1vol(pc),d0
	add.w d0,d0
	move.w (a0,d0.w),d0
	add.l save_vtab(pc),d0

	move.w aud2vol(pc),d1
	add.w d1,d1
	move.w (a0,d1.w),d1
	add.l save_vtab(pc),d1

	move.w aud3vol(pc),d2
	add.w d2,d2
	move.w (a0,d2.w),d2
	add.l save_vtab(pc),d2

	move.w aud4vol(pc),d3
	add.w d3,d3
	move.w (a0,d3.w),d3
	add.l save_vtab(pc),d3

	move.l samp1(pc),d5
	move.w #PARTS,d6
; a0=sample 1 + position
; a1=sample 1 + position
; a2=sample 1 + position
; a3=sample 1 + position
mainloop
	move.l wiz1lc(pc),a0
	add.w wiz1pos(pc),a0
	move.l wiz2lc(pc),a1
	add.w wiz2pos(pc),a1
	move.l wiz3lc(pc),a2
	add.w wiz3pos(pc),a2
	move.l wiz4lc(pc),a3
	add.w wiz4pos(pc),a3

	bsr do_big_routine
	add.l #LEN*2,d5
	movem.l d0-d3,-(a7)

; Add on movements,
; then check for repeats:

	moveq #0,d0
	moveq #0,d1
	moveq #0,d2
; Voice 1
	move.w wiz1pos(pc),d0
	move.w wiz1frc(pc),d1
	move.w bigadd1(pc),d2
	add.w fracadd1(pc),d1		;add fractions first
	addx.w d2,d0
	cmp.l wiz1len(pc),d0
	blt.s .norep1
	sub.w wiz1rpt(pc),d0
.norep1	move.w d0,wiz1pos
	move.w d1,wiz1frc

; Voice 2
	move.w wiz2pos(pc),d0
	move.w wiz2frc(pc),d1
	move.w bigadd2(pc),d2
	add.w fracadd2(pc),d1		;add fractions first
	addx.w d2,d0
	cmp.l wiz2len(pc),d0
	blt.s .norep2
	sub.w wiz2rpt(pc),d0
.norep2	move.w d0,wiz2pos
	move.w d1,wiz2frc

; Voice 3
	move.w wiz3pos(pc),d0
	move.w wiz3frc(pc),d1
	move.w bigadd3(pc),d2
	add.w fracadd3(pc),d1		;add fractions first
	addx.w d2,d0
	cmp.l wiz3len(pc),d0
	blt.s .norep3
	sub.w wiz3rpt(pc),d0
.norep3	move.w d0,wiz3pos
	move.w d1,wiz3frc

; Voice 4
	move.w wiz4pos(pc),d0
	move.w wiz4frc(pc),d1
	move.w bigadd4(pc),d2
	add.w fracadd4(pc),d1		;add fractions first
	addx.w d2,d0
	cmp.l wiz4len(pc),d0
	blt.s .norep4
	sub.w wiz4rpt(pc),d0
.norep4	move.w d0,wiz4pos
	move.w d1,wiz4frc

	movem.l (a7)+,d0-d3
	dbf d6,mainloop
; Move a few bytes to avoid crackles
	move.l d5,a0
	move.w -2(a0),d5

	rept pad_no
	move.w d5,(a0)+
	endr

	move.l save_usp(pc),a7
	move.w #$2500,sr

priv	addq.l #6,a7
	move.w #$2500,sr

	bsr	music
	movem.l	(a7)+,d0-d6/a0-a4
	rts

volume_handle:
	dcb.w 64,0

x	set 256
	rept 64
	dc.w x
x	set x+256
	endr


;-------------------Sets up 'Paula'--------------------
; Call with a0=voice data
;           a1=area start of self_modify

self_modify:
	move.w aud1per-wiz1lc(a0),d2
	add.w d2,d2
	add.w d2,d2
	lea itab(pc),a2
	move.w 2(a2,d2.w),d3			;d3=frac add
	move.w (a2,d2.w),d2			;d2=whole add

	moveq #0,d1				;d1=frac pos
	moveq #0,d0				;d0=whole pos
; Put it in there:
o	set 0
	rept LEN
	add.w d3,d1
	addx.w d2,d0
	move.w d0,o(a1)
o	set o+34
	endr

	move.w d0,bigadd1-wiz1lc(a0)
	move.w d1,fracadd1-wiz1lc(a0)
	rts

;------------------Paula emulator-----------------

do_big_routine:
	move.l a7,save_usp2
	move.l d5,a7

big_routine:
; Self modifies at  +2 +10 +18 +26
; Main rout is 34 bytes in length
	rept LEN
	move.b 1(a0),d0
	move.l d0,a4
	move.w (a4),d4
	move.b 1(a1),d1
	move.l d1,a4
	add.w (a4),d4
	move.b 1(a2),d2
	move.l d2,a4
	add.w (a4),d4
	move.b 1(a3),d3
	move.l d3,a4
	add.w (a4),d4
	move.w d4,(a7)+
	endr
	move.l save_usp2(pc),a7
	rts


;-------------------------------------------- Hardware-registers & data --
wiz1lc	DC.L dummy
wiz1len	DC.L 320
wiz1rpt	DC.W 320
wiz1pos	DC.W 0
wiz1frc	DC.W 0
aud1lc	DC.L dummy
aud1len	DC.W 0
aud1per	DC.W 0
aud1vol	DC.W 0
	DS.W 3
bigadd1	dc.w 0
fracadd1 dc.w 0


wiz2lc	DC.L dummysam
wiz2len	DC.L 320
wiz2rpt	DC.W 320
wiz2pos	DC.W 0
wiz2frc	DC.W 0
aud2lc	DC.L dummy
aud2len	DC.W 0
aud2per	DC.W 0
aud2vol	DC.W 0
	DS.W 3
bigadd2	dc.w 0
fracadd2 dc.w 0

wiz3lc	DC.L dummysam
wiz3len	DC.L 320
wiz3rpt	DC.W 320
wiz3pos	DC.W 0
wiz3frc	DC.W 0
aud3lc	DC.L dummy
aud3len	DC.W 0
aud3per	DC.W 0
aud3vol	DC.W 0
	DS.W 3
bigadd3	dc.w 0
fracadd3 dc.w 0

wiz4lc	DC.L dummysam
wiz4len	DC.L 320
wiz4rpt	DC.W 320
wiz4pos	DC.W 0
wiz4frc	DC.W 0
aud4lc	DC.L dummy
aud4len	DC.W 0
aud4per	DC.W 0
aud4vol	DC.W 0
	ds.w 3		;what the hell is this for???
bigadd4	dc.w 0
fracadd4 dc.w 0


dummy	DC.L 0
dummysam
	dcb.w 640,$0000

dmactrl	DC.W 0

samp1	DC.L sample1
samp2	DC.L sample2

sample1
	dcb.w LEN*(PARTS+1)+pad_no,$400
sample2
	dcb.w LEN*(PARTS+1)+pad_no,$400


;--------------------------------------------------- Playback-interrupt --

playvec:
	move.w (a6)+,d7
	move.l snd_tab+4(pc,d7.w),(a5)
	move.l snd_tab(pc,d7.w),d7
	movep.l d7,0(a5)
	rte

;--------------------------------------------- Sound data for soundchip --
digi2	MACRO
	dc.b	8,(($\1>>8)&15),9,(($\1>>4)&15),10,0,(($\1)&15),0
	dc.b	8,(($\2>>8)&15),9,(($\2>>4)&15),10,0,(($\2)&15),0
	dc.b	8,(($\3>>8)&15),9,(($\3>>4)&15),10,0,(($\3)&15),0
	dc.b	8,(($\4>>8)&15),9,(($\4>>4)&15),10,0,(($\4)&15),0
	dc.b	8,(($\5>>8)&15),9,(($\5>>4)&15),10,0,(($\5)&15),0
	dc.b	8,(($\6>>8)&15),9,(($\6>>4)&15),10,0,(($\6)&15),0
	dc.b	8,(($\7>>8)&15),9,(($\7>>4)&15),10,0,(($\7)&15),0
	dc.b	8,(($\8>>8)&15),9,(($\8>>4)&15),10,0,(($\8)&15),0
	ENDM

************************
snd_tab:
	rept	24*8
	dc.l	$08000900,$0a000000
	endr
	digi2	000,000,200,300,400,500,510,600
	digi2	600,620,700,720,730,800,800,820
	digi2	830,900,910,920,930,940,950,951
	digi2	A00,A20,A30,A40,A50,A50,A52,A60
	digi2	A62,A70,A71,B00,B10,B30,B40,B40
	digi2	B50,B52,B60,B61,B70,B71,B72,B73
	digi2	B80,B81,B83,B84,B90,C00,C20,C30
	digi2	C40,C50,C51,C52,C60,C62,C70,C72
	digi2	C73,C80,C80,C82,C83,C90,C90,C92
	digi2	c93,c94,c95,c95,ca0,d00,d20,d30
	digi2	d40,d50,d50,d52,d60,d62,d70,d71
	digi2	d73,d74,d80,d82,d83,d90,d90,d92
	digi2	d93,d94,d95,d95,da0,da1,da3,da4
	digi2	da4,da5,da5,da6,da6,da7,da7,db0
	digi2	db1,db2,db3,db4,db5,db5,db6,e00
	digi2	e10,e30,e40,e41,e50,e52,e60,e61
	digi2	e70,e71,e73,e74,e80,e81,e83,e84
	digi2	e90,e92,e93,e94,e95,e95,ea0,ea1
	digi2	ea3,ea4,ea4,ea5,ea5,ea6,ea6,ea7
	digi2	ea7,ea7,eb0,eb2,eb3,eb4,eb5,eb5
	digi2	eb5,eb6,eb6,eb7,eb7,eb7,eb8,eb8
	digi2	eb8,eb8,eb9,ec0,ec1,ec3,ec4,ec4
	digi2	ec5,f00,f10,f30,f40,f41,f50,f52
	digi2	f60,f61,f70,f71,f73,f74,f80,f82
	digi2	f83,f84,f90,f92,f93,f94,f95,f95
	digi2	fa0,fa1,fa3,fa4,fa4,fa5,fa5,fa6
	digi2	fa6,fa7,fa7,fb0,fb0,fb2,fb3,fb4
	digi2	fb5,fb5,fb6,fb6,fb6,fb7,fb7,fb7
	digi2	fb8,fb8,fb8,fb8,fb9,fc0,fc1,fc3
	digi2	fc4,fc4,fc5,fc5,fc6,fc6,fc7,fc7
	digi2	fc7,fc7,fc8,fc8,fc8,fc8,fc9,fc9
	digi2	fc9,fc9,fc9,fc9,fca,fd0,fd1,fd3

	rept	32*8
	dc.l	$080f090d,$0a000300
	endr
	even
snd_tab_end


;========================================================= EMULATOR END ==

prepare	move.l	workspace_end(pc),a6
	movea.l	samplestarts(pc),a0
	movea.l	end_of_samples(pc),a1

tostack	move.w	-(a1),d1
	and.w	#$fefe,d1		;convert to 7 bit format
	move.w	d1,-(a6)
	cmpa.l	a0,a1			; Move all samples to stack
	bgt.s	tostack

	lea	samplestarts(pc),a2
	move.l	save_module(pc),a1		; Module
	;lea	data(pc),a1
	movea.l	(a2),a0			; Start of samples
	movea.l	a0,a5			; Save samplestart in a5

	moveq	#30,d7

roop	move.l	a0,(a2)+		; Sampleposition

	tst.w	$2A(a1)
	beq.s	samplok			; Len=0 -> no sample

	tst.w	$2E(a1)			; Test repstrt
	bne.s	repne			; Jump if not zero


repeq	move.w	$2A(a1),d0		; Length of sample
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a0,a4
fromstk	move.w	(a6)+,(a0)+		; Move all samples back from stack
	dbra	d0,fromstk

	bra.s	rep



repne	move.w	$2E(a1),d0
	move.w	d0,d4
	subq.w	#1,d0

	movea.l	a6,a4
get1st	move.w	(a4)+,(a0)+		; Fetch first part
	dbra	d0,get1st

	adda.w	$2A(a1),a6		; Move a6 to next sample
	adda.w	$2A(a1),a6



rep	movea.l	a0,a5
	moveq	#0,d1
toosmal	movea.l	a4,a3
	move.w	$30(a1),d0
	subq.w	#1,d0
moverep	move.w	(a3)+,(a0)+		; Repeatsample
	addq.w	#2,d1
	dbra	d0,moverep
	cmp.w	#320,d1			; Must be > 320
	blt.s	toosmal

	move.w	#320/2-1,d2
last320	move.w	(a5)+,(a0)+		; Safety 320 bytes
	dbra	d2,last320

done	add.w	d4,d4

	move.w	d4,$2A(a1)		; length
	move.w	d1,$30(a1)		; Replen
	clr.w	$2E(a1)

samplok	lea	$1E(a1),a1
	dbra	d7,roop

	cmp.l	workspace_end(pc),a0
	bgt.s	.nospac
	rts

.nospac	illegal

end_of_samples	DC.L 0

;------------------------------------------------------ Main replayrout --
init	move.l	save_module(pc),a0
	;lea	data(pc),a0
	lea	$03B8(a0),a1

	moveq	#$7F,d0
	moveq	#0,d1
loop	move.l	d1,d2
	subq.w	#1,d0
lop2	move.b	(a1)+,d1
	cmp.b	d2,d1
	bgt.s	loop
	dbra	d0,lop2
	addq.b	#1,d2

	lea	samplestarts(pc),a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#$043C,d2
	add.l	a0,d2
	movea.l	d2,a2

	moveq	#$1E,d0
lop3	clr.l	(a2)
	move.l	a2,(a1)+
	moveq	#0,d1
	move.w	42(a0),d1
	add.l	d1,d1
	adda.l	d1,a2
	adda.l	#$1E,a0
	dbra	d0,lop3

	move.l	a2,end_of_samples	;
	rts

music	move.l	save_module(pc),a0
	;lea	data(pc),a0

	move.w	counter(pc),beat_count
	addq.w	#$01,counter
	move.w	counter(pc),d0
	cmp.w	speed(pc),d0
	blt.s	nonew
	clr.w	counter
	bra	getnew

nonew	lea	voice1(pc),a4
	lea	aud1lc(pc),a3
	bsr	checkcom
	lea	voice2(pc),a4
	lea	aud2lc(pc),a3
	bsr	checkcom
	lea	voice3(pc),a4
	lea	aud3lc(pc),a3
	bsr	checkcom
	lea	voice4(pc),a4
	lea	aud4lc(pc),a3
	bsr	checkcom
	bra	endr

arpeggio
	moveq	#0,d0
	move.w	counter(pc),d0
	divs	#$03,d0
	swap	d0
	tst.w	d0
	beq.s	arp2
	cmp.w	#$02,d0
	beq.s	arp1

	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	bra.s	arp3

arp1	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	bra.s	arp3

arp2	move.w	$10(a4),d2
	bra.s	arp4

arp3	add.w	d0,d0
	moveq	#0,d1
	move.w	$10(a4),d1
	lea	periods(pc),a0
	moveq	#$24,d4
arploop	move.w	0(a0,d0.w),d2
	cmp.w	(a0),d1
	bge.s	arp4
	addq.l	#2,a0
	dbra	d4,arploop
	rts

arp4	move.w	d2,$06(a3)
	rts

getnew	move.l	save_module(pc),a0
	;lea	data(pc),a0
	lea	$043C(a0),a0
	lea	-$043C+$0C(a0),a2
	lea	-$043C+$03B8(a0),a1

	moveq	#0,d0
	move.l	d0,d1
	move.b	songpos(pc),d0
	move.w	d0,song_position
	move.b	0(a1,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	pattpos(pc),d1
	clr.w	dmacon

	lea	aud1lc(pc),a3
	lea	voice1(pc),a4
	bsr.s	playvoice
	lea	aud2lc(pc),a3
	lea	voice2(pc),a4
	bsr.s	playvoice
	lea	aud3lc(pc),a3
	lea	voice3(pc),a4
	bsr.s	playvoice
	lea	aud4lc(pc),a3
	lea	voice4(pc),a4
	bsr.s	playvoice
	bra	setdma

playvoice
	move.l	0(a0,d1.l),(a4)
	addq.l	#4,d1
	moveq	#0,d2
	move.b	$02(a4),d2
	and.b	#$F0,d2
	lsr.b	#4,d2
	move.b	(a4),d0
	and.b	#$F0,d0
	or.b	d0,d2
	tst.b	d2
	beq.s	setregs
	moveq	#0,d3
	lea	samplestarts(pc),a1
	move.l	d2,d4
	subq.l	#$01,d2
	asl.l	#2,d2
	mulu	#$1E,d4
	move.l	0(a1,d2.l),$04(a4)
	move.w	0(a2,d4.l),$08(a4)
	move.w	$02(a2,d4.l),$12(a4)
	move.w	$04(a2,d4.l),d3
	tst.w	d3
	beq.s	noloop
	move.l	$04(a4),d2
	add.w	d3,d3
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$04(a2,d4.l),d0
	add.w	$06(a2,d4.l),d0
	move.w	d0,8(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
	bra.s	setregs

noloop	move.l	$04(a4),d2
	add.l	d3,d2
	move.l	d2,$0A(a4)
	move.w	$06(a2,d4.l),$0E(a4)
	move.w	$12(a4),$08(a3)
setregs	move.w	(a4),d0
	and.w	#$0FFF,d0
	beq	checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$03,d0
	bne.s	setperiod
	bsr	setmyport
	bra	checkcom2

setperiod
	move.w	(a4),$10(a4)
	andi.w	#$0FFF,$10(a4)
	move.w	$14(a4),d0
	move.w	d0,dmactrl
	clr.b	$1B(a4)

	move.l	$04(a4),(a3)
	move.w	$08(a4),$04(a3)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	move.w	$14(a4),d0
	or.w	d0,dmacon
	bra	checkcom2

setdma	move.w	dmacon(pc),d0

	btst	#0,d0			;-------------------
	beq.s	wz_nch1			;
	move.l	aud1lc(pc),wiz1lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud1len(pc),d1		;
	move.w	voice1+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz1len		;
	move.w	d2,wiz1rpt		;
	clr.w	wiz1pos			;

wz_nch1	btst	#1,d0			;
	beq.s	wz_nch2			;
	move.l	aud2lc(pc),wiz2lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud2len(pc),d1		;
	move.w	voice2+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz2len		;
	move.w	d2,wiz2rpt		;
	clr.w	wiz2pos			;

wz_nch2	btst	#2,d0			;
	beq.s	wz_nch3			;
	move.l	aud3lc(pc),wiz3lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud3len(pc),d1		;
	move.w	voice3+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz3len		;
	move.w	d2,wiz3rpt		;
	clr.w	wiz3pos			;

wz_nch3	btst	#3,d0			;
	beq.s	wz_nch4			;
	move.l	aud4lc(pc),wiz4lc	;
	moveq	#0,d1			;
	moveq	#0,d2			;
	move.w	aud4len(pc),d1		;
	move.w	voice4+$0E(pc),d2	;
	add.l	d2,d1			;
	move.l	d1,wiz4len		;
	move.w	d2,wiz4rpt		;
	clr.w	wiz4pos			;-------------------

wz_nch4	addi.w	#$10,pattpos
	cmpi.w	#$0400,pattpos
	bne.s	endr
nex	clr.w	pattpos
	clr.b	break
	addq.b	#1,songpos
	andi.b	#$7F,songpos
	move.b	songpos(pc),d1

	move.l	a0,-(a7)
	move.l	save_module(pc),a0
	cmp.b	$03B6(a0),d1
	bne.s	no_ending
	move.b	$03B7(a0),songpos
no_ending:
	move.l	(a7)+,a0
endr	tst.b	break
	bne.s	nex
	rts

setmyport
	move.w	(a4),d2
	and.w	#$0FFF,d2
	move.w	d2,$18(a4)
	move.w	$10(a4),d0
	clr.b	$16(a4)
	cmp.w	d0,d2
	beq.s	clrport
	bge.s	rt
	move.b	#$01,$16(a4)
	rts

clrport	clr.w	$18(a4)
rt	rts

myport	move.b	$03(a4),d0
	beq.s	myslide
	move.b	d0,$17(a4)
	clr.b	$03(a4)
myslide	tst.w	$18(a4)
	beq.s	rt
	moveq	#0,d0
	move.b	$17(a4),d0
	tst.b	$16(a4)
	bne.s	mysub
	add.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	bgt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)

myok	move.w	$10(a4),$06(a3)
	rts

mysub	sub.w	d0,$10(a4)
	move.w	$18(a4),d0
	cmp.w	$10(a4),d0
	blt.s	myok
	move.w	$18(a4),$10(a4)
	clr.w	$18(a4)
	move.w	$10(a4),$06(a3)
	rts

vib	move.b	$03(a4),d0
	beq.s	vi
	move.b	d0,$1A(a4)

vi	move.b	$1B(a4),d0
	lea	sin(pc),a1
	lsr.w	#$02,d0
	and.w	#$1F,d0
	moveq	#0,d2
	move.b	0(a1,d0.w),d2
	move.b	$1A(a4),d0
	and.w	#$0F,d0
	mulu	d0,d2
	lsr.w	#$06,d2
	move.w	$10(a4),d0
	tst.b	$1B(a4)
	bmi.s	vibmin
	add.w	d2,d0
	bra.s	vib2

vibmin	sub.w	d2,d0
vib2	move.w	d0,$06(a3)
	move.b	$1A(a4),d0
	lsr.w	#$02,d0
	and.w	#$3C,d0
	add.b	d0,$1B(a4)
	rts

nop	move.w	$10(a4),$06(a3)
	rts

checkcom
	move.w	$02(a4),d0
	and.w	#$0FFF,d0
	beq.s	nop
	move.b	$02(a4),d0
	and.b	#$0F,d0
	tst.b	d0
	beq	arpeggio
	cmp.b	#$01,d0
	beq.s	portup
	cmp.b	#$02,d0
	beq	portdown
	cmp.b	#$03,d0
	beq	myport
	cmp.b	#$04,d0
	beq	vib
	cmp.b	#$05,d0
	beq	port_toneslide
	cmp.b	#$06,d0
	beq	vib_toneslide
	move.w	$10(a4),$06(a3)
	cmp.b	#$0A,d0
	beq.s	volslide
	rts

volslide
	moveq	#0,d0
	move.b	$03(a4),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	voldown
	add.w	d0,$12(a4)
	cmpi.w	#$40,$12(a4)
	bmi.s	vol2
	move.w	#$40,$12(a4)
vol2	move.w	$12(a4),$08(a3)
	rts

voldown	moveq	#0,d0
	move.b	$03(a4),d0
	and.b	#$0F,d0
	sub.w	d0,$12(a4)
	bpl.s	vol3
	clr.w	$12(a4)
vol3	move.w	$12(a4),$08(a3)
	rts

portup	moveq	#0,d0
	move.b	$03(a4),d0
	sub.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$71,d0
	bpl.s	por2
	andi.w	#$F000,$10(a4)
	ori.w	#$71,$10(a4)
por2	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

port_toneslide
	bsr	myslide
	bra.s	volslide

vib_toneslide
	bsr	vi
	bra.s	volslide

portdown
	clr.w	d0
	move.b	$03(a4),d0
	add.w	d0,$10(a4)
	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	cmp.w	#$0358,d0
	bmi.s	por3
	andi.w	#$F000,$10(a4)
	ori.w	#$0358,$10(a4)
por3	move.w	$10(a4),d0
	and.w	#$0FFF,d0
	move.w	d0,$06(a3)
	rts

checkcom2
	move.b	$02(a4),d0
	and.b	#$0F,d0
	cmp.b	#$0D,d0
	beq.s	pattbreak
	cmp.b	#$0B,d0
	beq.s	posjmp
	cmp.b	#$0C,d0
	beq.s	setvol
	cmp.b	#$0F,d0
	beq.s	setspeed
	rts

pattbreak
	st	break
	rts

posjmp	move.b	$03(a4),d0
	subq.b	#$01,d0
	move.b	d0,songpos
	st	break
	rts

setvol	moveq	#0,d0
	move.b	$03(a4),d0
	cmp.w	#$40,d0
	ble.s	vol4
	move.b	#$40,$03(a4)
vol4	move.b	$03(a4),$09(a3)
	move.b	$03(a4),$13(a4)
	rts

setspeed
	cmpi.b	#$1F,$03(a4)
	ble.s	sets
	move.b	#$1F,$03(a4)
sets	move.b	$03(a4),d0
	beq.s	rts2
	move.w	d0,speed
	clr.w	counter
rts2	rts

sin	DC.B $00,$18,$31,$4A,$61,$78,$8D,$A1,$B4,$C5,$D4,$E0,$EB,$F4,$FA,$FD
	DC.B $FF,$FD,$FA,$F4,$EB,$E0,$D4,$C5,$B4,$A1,$8D,$78,$61,$4A,$31,$18

periods	DC.W $0358,$0328,$02FA,$02D0,$02A6,$0280,$025C,$023A,$021A,$01FC,$01E0
	DC.W $01C5,$01AC,$0194,$017D,$0168,$0153,$0140,$012E,$011D,$010D,$FE
	DC.W $F0,$E2,$D6,$CA,$BE,$B4,$AA,$A0,$97,$8F,$87
	DC.W $7F,$78,$71,$00,$00

speed	DC.W $06
counter	DC.W $00
songpos	DC.B $00
break	DC.B $00
pattpos	DC.W $00

dmacon		DC.W $00
samplestarts	DS.L $1F

voice1	DS.W 10
	DC.W $01
	DS.W 3
voice2	DS.W 10
	DC.W $02
	DS.W 3
voice3	DS.W 10
	DC.W $04
	DS.W 3
voice4	DS.W 10
	DC.W $08
	DS.W 3

	ds.l 30
user_stack:

;---------------------------
; The next three lines must follow each other!
data	INCBIN a:\module.mod	; name of module
	DS.l	30000/4		; Workspace
workspc	DS.W	1
;----------------------------

vtab	DS.B 65*256
vtabend	ds.b 256
 