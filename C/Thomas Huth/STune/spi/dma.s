;-----------------------------------------------------------------------;
;			MOD Player													;
;		7 Bit Ste/TT Pro-Tracker 2.1A Driver							;
;	(C) October/November 1992 Griff of Electronic Images				;
;-----------------------------------------------------------------------;
; Quick notes about this source:										;
; - 25 khz stereo sound, with microwire control.						;
; - The ONLY player in the whole wide world to emulate TEMPO properly.  ;
; - This replay is NOT fast and nor should it be.						;
; - It is designed for QUALITY and ACCURATE replay of ProTracker MODS.  ;
; - It doe NOT pad samples and so doesn't waste any setup time/memory.  ;
; - If you use it, then please credit me.								;
;-----------------------------------------------------------------------;

;****************************************************
;* Changes made by T.Huth, 1997-99					*
;* - Some "dirty" routines changed					*
;* - The variables are now in the data-/bss-section *
;*   -> no longer write access to the text-section! *
;* - No more selfmodifying code!                    *
;* - And many other changes							*
;* - Set tabsize = 4 to read this file				*
;****************************************************

bufsize equ 5500		; maximum size of buffer
; (when tempo =32)


; Paula emulation storage structure.
sam_start equ 0			; sample start			.l
sam_length equ 4		; sample length			.l
sam_lpstart equ 8		; sample loop start		.l
sam_lplength equ 12		; sample loop length	.l
sam_period equ 16		; sample period(freq)	.w
sam_vol equ 18			; sample volume			.w
sam_strctsiz equ 20		; structure size.


; Structure produced from 'paula' data
Vaddr	equ 0		; .l
Voffy	equ 4		; .l
Vfrac	equ 8		; .l
Vfreqint equ 12		; .w
Vfreqfrac equ 14	; .l
Vvoltab equ 18		; .w
Vlpaddr equ 20		; .l
Vlpoffy equ 24		; .l
Vlpfreqint equ 28	; .w
Vlpfreqfrac equ 30	; .l
Vstrctsiz equ 34


	.text


;********************************
;**** Initialize the player: ****
;********************************
	.globl	_main
_main:
	pea 	checkcookie(pc)
	move.w	#38,-(sp)
	trap	#14				; Supexec
	addq.l	#6,sp
	tst.w	d0
	beq 	hwokay
	moveq	#0,d0
	rts
hwokay:
	bsr 	creciatb
	move.l	#spistruct,d0
	rts

; Check for dma sound!
checkcookie:
	move.l	$05a0,d0		; get cookie jar ptr
	beq.s	no_dmasnd		; nul ptr = no cookie jar
	movea.l d0,a0			; (no cookie jar= no dma snd)
search_next:
	tst.l	(a0)
	beq.s	no_dmasnd
	cmpi.l  #$5F534E44,(a0)	; '_SND' cookie found?
	beq.s	search_found
	addq.l  #8,a0
	bra.s	search_next
search_found:
	move.l  4(a0),d0		; get _SND const.
	btst	#1,d0
	beq.s	no_dmasnd
	move.w  #0,d0			; DMA SOUND FOUND!
	rts
no_dmasnd:
	move.w	#-1,d0			; NO DMA SOUND!
	rts

;** Create CIA-Emulation-Table: **
;*
;* unsigned short ciaemtab[256], tempo;
;* double hz,cia_clock=709378.92,temponum=1773447.0;
;* ciaemtab[0]=0;			/* tempo=0 case */
;* for(tempo=1 ; tempo<=255 ; tempo++) 
;*  { hz = (cia_clock/temponum)*(double)tempo;
;*    ciaemtab[tempo]=(25033.0/2/hz);		/* FRAME COUNT */
;*  }
;*
creciatb:
	movem.l	d1/a0,-(sp)
	lea 	ciaemtab,a0
	clr.w	(a0)+
	move.w	#1,d0
crecialp:
	moveq.l	#0,d1
	move.w	#31291,d1
	divu	d0,d1
	move.w	d1,(a0)+
	add.w	#1,d0
	cmp.w	#255,d0
	bls.s	crecialp
	movem.l	(sp)+,d1/a0
	rts

;***********************************
;****		Play a module		****
;***********************************
mod_play:
	move.l  4(sp),mod_addr	; Store module address
	pea 	playmod(pc)
	move.w  #38,-(sp)
	trap	#14				; Supexec
	addq.l  #6,sp
	rts
playmod:
	bsr.s	init_ints		; kill ints
	bsr 	mt_init
	bsr 	STspecific
	rts


;*********************************
;**** Stop playing the module ****
;*********************************
mod_stop:
	pea 	stopmod(pc)
	move.w  #38,-(sp)
	trap	#14				; Supexec
	addq.l  #6,sp
smret:		rts
stopmod:
	bsr 	stop_music
	bsr.s	restore_ints	; restore
	rts


; Save mfp vectors and ints and install our own. (very 'clean' setup rout)

init_ints:
	move	#$2700,sr
	lea	old_stuff,a0
	move.l  $0134,(a0)+
	move.b  $fffffa07,(a0)+
	move.b  $fffffa09,(a0)+
	move.b  $fffffa13,(a0)+
	move.b  $fffffa15,(a0)+	; Save mfp registers
	move.b  $fffffa19,(a0)+
	move.b  $fffffa1f,(a0)+
	move.b  $fffffa17,(a0)+

	bset	#6,$fffffa09
	bclr	#5,$fffffa13
	bset	#6,$fffffa15
	bclr	#3,$fffffa17	; software end of int.
	move	#$2300,sr
	rts


; Restore mfp vectors and ints.

restore_ints:
	move	#$2700,sr
	lea 	old_stuff,a0
	move.l  (a0)+,$0134
	move.b  (a0)+,$fffffa07
	move.b  (a0)+,$fffffa09
	move.b  (a0)+,$fffffa13
	move.b  (a0)+,$fffffa15	; restore mfp
	move.b  (a0)+,$fffffa19
	move.b  (a0)+,$fffffa1f
	move.b  (a0)+,$fffffa17
	move	#$2300,sr
	rts


mod_pause:
mod_forward:
mod_backward:
mod_setup:
	rts


; Toggle Tempo Control.
;mod_toggletempo:
;	tst.b	tempo_cont_flg		; toggle tempo
;	beq.s	tempoon
;	sf		tempo_cont_flg		; turn tempo control OFF
;	move.w	RealTempo,OldTempo	; save current tempo
;	move.w	#125,RealTempo		; switch to default tempo
;	bra.s	endtempo
;tempoon:st	tempo_cont_flg	; turn tempo control ON
;	move.w	OldTempo,RealTempo
;endtempo:	rts


;###### Play a sample #######
sam_play:
	move.w	12(sp),d0
	btst	#0,d0
	bne.s	sp_right
	move.l	4(sp),fxsam1addr
	move.l	8(sp),d0
	sub.l	4(sp),d0
	and.l	#-2,d0
	move.l	d0,fxsam1len
	rts
sp_right:
	move.l	4(sp),fxsam2addr
	move.l	8(sp),d0
	sub.l	4(sp),d0
	and.l	#-2,d0
	move.l	d0,fxsam2len
	rts




;**####### Here comes the module player itself: #######**

; Start up music.

start_music:
	clr.b $ffff8901
	bsr.s	Set_DMA
	move	#$2700,sr
	bset	#5,$fffffa07	;iera
	bset	#5,$fffffa13	;imra
	clr.b	$fffffa19
	move.b  #1,$fffffa1f
	move.b  #8,$fffffa19	;timer a event mode.
	move.l  #do_music,$0134
	bsr 	Start_DMA
	move	#$2300,sr
	rts


; Set DMA to play buffer(buffer len based on TEMPO)
Set_DMA:
	movem.l	d0/a0-a1,-(sp)
	movea.l	stebuf_ptrs+4,a0
	move.l	a0,-(sp)
	lea 	ciaemtab,a1
	move.w  RealTempo,d0
	add.w	d0,d0
	move.w  0(a1,d0.w),d0
	add.w	d0,d0
	add.w	d0,d0
	adda.w  d0,a0
	move.l  a0,-(sp)
	move.b  5(sp),$ffff8903
	move.b  6(sp),$ffff8905 ; set start of buffer
	move.b  7(sp),$ffff8907
	move.b  1(sp),$ffff890f
	move.b  2(sp),$ffff8911 ; set end of buffer
	move.b  3(sp),$ffff8913
	addq.l	#8,sp
	movem.l stebuf_ptrs,a0-a1
	exg	a0,a1
	movem.l a0-a1,stebuf_ptrs
	movem.l (sp)+,d0/a0-a1
	rts

Start_DMA:
	move.b  #2,$ffff8921	; set freq to 25 KHz!
	move.b  #3,$ffff8901	; start STE dma.
	rts

stop_music:
	clr.b	$ffff8901		; stop STE dma.
	move	#$2700,sr
	bclr	#5,$fffffa07	; iera
	bclr	#5,$fffffa13	; imra
	move	#$2300,sr
	rts

; Create the 65 volume lookup tables

makevoltab:
	move.l  #vols+256,d0
	clr.b	d0
	movea.l d0,a0
	move.l  a0,voltab_ptr
	lea 	16640(a0),a0
	moveq	#$40,d0
lp7:
	move.w	#$ff,d1
lp8:
	move.w	d1,d2
	ext.w	d2
	muls	d0,d2
	asr.l	#7,d2
	move.b  d2,-(a0)
	dbra	d1,lp8
	dbra	d0,lp7
	lea 	stebuf1,a0
	lea 	stebuf2,a1
	move.w  #(bufsize/2)-1,d0
	moveq	#0,d1
lp9:
	move.l	d1,(a0)+
	move.l  d1,(a1)+
	dbra	d0,lp9
	rts


; Player - This is THE  'Paula' Emulator.

do_music:
	tst.b	music_on		; music on?
	beq.s	skipit			; if not skip all!
	move	#$2500,sr
	bsr 	Set_DMA
	movem.l d0-a6,-(sp)

	moveq	#0,d4
	lea 	Voice1Set,a0	; Setup Chan 1
	lea 	ch1s,a5
	bsr.s	SetupVoice
	moveq	#1,d4
	lea 	Voice2Set,a0	;	"	2
	lea 	ch2s,a5
	bsr.s	SetupVoice
	moveq	#2,d4
	lea 	Voice3Set,a0	;	"	3
	lea 	ch3s,a5
	bsr.s	SetupVoice
	moveq	#3,d4
	lea 	Voice4Set,a0	;	"	4
	lea 	ch4s,a5
	bsr.s	SetupVoice
	bsr 	Goforit
	bsr 	mt_music
skipit1:
	movem.l (sp)+,d0-a6
skipit: rte


; Routine to add/move one voice to buffer. The real Paula emulation part!!

SetupVoice:
	movea.l sam_start(a5),a2		; current sample end address (shadow amiga!)
	move.l  sam_length(a5),d0
	movem.w sam_period(a5),d1-d2	; offset/period/volume
	cmp.w	#$40,d2
	bls.s	vol_ok
	moveq	#$40,d2
vol_ok:
	lsl.w	#8,d2			; offset into volume tab
	lea 	ftab,a6
	add.w	d1,d1
	move.w  d1,d7
	add.w	d1,d1
	add.w	d7,d1			; => d1 * 6
	adda.l  d1,a6
	move.w  (a6)+,d1		; int part
	move.l  (a6)+,d3
	neg.l	d0				; negate sample offset
	move.w  shadow_dmacon,d7
	btst	d4,d7
	bne.s	vcon2
	moveq	#0,d1			; clear freq if off.
	moveq	#0,d3			; clear freq if off.
	moveq	#0,d2			; volume off for safety!!
vcon2:
	lea 	nulsamp+2,a6
	cmpa.l  a6,a2
	bne.s	vcon
	moveq	#0,d1			; clear freq if off.
	moveq	#0,d3			; clear freq if off.
	moveq	#0,d2			; volume off for safety!!
vcon:
	movea.l sam_lpstart(a5),a6 ; loop addr
	move.l  sam_lplength(a5),d5 ; loop length
	neg.l	d5				; negate it.
	move.w  d1,d6			; freq on loop
	move.l  d3,d7
	cmp.l	#-2,d5
	bne.s	isloop
	moveq	#0,d6
	moveq	#0,d7			; no loop-no frequency
	lea 	nulsamp+2,a6	; no loop-point to nul
isloop:
	move.l  a2,(a0)+	; store address
	move.l  d0,(a0)+		; store offset int.L
	addq.l  #4,a0			; skip current frac.l
	move.w  d1,(a0)+		; store freq int.w
	move.l  d3,(a0)+		; store freq 32bit fraction
	move.w  d2,(a0)+		; address of volume tab.
	move.l  a6,(a0)+		; store loop addr
	move.l  d5,(a0)+		; store loop offset.L
	move.w  d6,(a0)+		; store loop freq int.w
	move.l  d7,(a0)+		; store loop freq frac.L
	rts


; Make that buffer! (channels are paired together!)

Goforit:
	lea 	ch1s,a2
	lea 	ch4s,a3
	lea 	Voice1Set,a5
	lea 	Voice4Set,a6
	move.w  #0,bufadd+2
	bsr.s	do2chans
	lea 	ch2s,a2
	lea 	ch3s,a3
	lea 	Voice2Set,a5
	lea 	Voice3Set,a6
	move.w  #1,bufadd+2
	bsr.s	do2chans
	rts

; Create 2 channels in the buffer.

do2chans:
	movem.l a2-a3/a5-a6,-(sp)
	move.l  voltab_ptr,d2
	move.l  d2,d3
	moveq	#0,d4
	move.w  Vvoltab(a5),d4
	add.l	d4,d2	; volume tab chan 1
	move.w  Vvoltab(a6),d4
	add.l	d4,d3	; volume tab chan 2

	movea.l Vaddr(a5),a0	; ptr to end of each sample!
	move.l  Voffy(a5),d0	; int.w offset
	move.l  Vfrac(a5),d4	; frac.w offset
	move.w  Vfreqint(a5),d6
	movea.l Vfreqfrac(a5),a2 ; frac.w/int.w freq

	movea.l Vaddr(a6),a1
	move.l  Voffy(a6),d1
	move.l  Vfrac(a6),d5
	move.w  Vfreqint(a6),d7
	movea.l Vfreqfrac(a6),a3
	swap	d6

	move.l  Vlpaddr(a5),lpvc1_1 ; loop for voice 1
	move.l  Vlpoffy(a5),lpvc1_2
	move.l  Vlpfreqfrac(a5),lpvc1_3
	move.w  Vlpfreqint(a5),lpvc1_4

	move.l  Vlpaddr(a6),lpvc2_1 ; loop for voice 1
	move.l  Vlpoffy(a6),lpvc2_2
	move.l  Vlpfreqfrac(a6),lpvc2_3
	move.w  Vlpfreqint(a6),lpvc2_4

	lea 	ciaemtab,a4
	move.w  RealTempo,d6
	add.w	d6,d6
	move.w  0(a4,d6.w),d6

	movea.l stebuf_ptrs,a4
	bsr.s	add2

	movem.l (sp)+,a2-a3/a5-a6
	neg.l	d0		; +ve offset(as original!)
	neg.l	d1
	move.l  a0,sam_start(a2) ; store voice address
	move.l  d0,sam_length(a2) ; store offset for next time
	move.l  d4,Vfrac(a5)	; store frac part
	move.l  a1,sam_start(a3) ; same for chan 2
	move.l  d1,sam_length(a3)
	move.l  d5,Vfrac(a6)
	rts


add2:
	adda.l  bufadd,a4
	movea.l a4,a6
make12_stelp:
	tst.w	bufadd+2
	bne.s	m12right
	tst.l	fxsam1len
	beq.s	m12nofxsam
	move.l	fxsam1addr,a4
	move.b	(a4)+,(a6)
	move.b	(a4)+,2(a6)
	move.l	a4,fxsam1addr
	sub.l	#2,fxsam1len
	bra.s	m12goon
m12right:
	tst.l	fxsam2len
	beq.s	m12nofxsam
	move.l	fxsam2addr,a4
	move.b	(a4)+,(a6)
	move.b	(a4)+,2(a6)
	move.l	a4,fxsam2addr
	sub.l	#2,fxsam2len
	bra.s	m12goon
m12nofxsam:
	move.b  0(a0,d0.l),d2
	movea.l d2,a4
	move.b  (a4),d2
	move.b  0(a1,d1.l),d3
	movea.l d3,a4
	add.b	(a4),d2
	move.b  d2,(a6)
	move.b  d2,2(a6)	; oversample(!)
m12goon:
	addq.l  #4,a6
	swap	d6
	add.l	a2,d4	; 32 bit fraction
	addx.w  d6,d0
	bcs.s	lpvc1ste
contlp1ste:
	swap	d6
	add.l	a3,d5
	addx.w  d7,d1
contlp2ste:
	dbcs	d6,make12_stelp
	bcs.s	lpvc2ste

	move.b  d2,(a6) 	; smooth
	move.b  d2,2(a6)	; in case!
	move.b  d2,4(a6)
	move.b  d2,6(a6)
	move.b  d2,8(a6)
	move.b  d2,10(a6)
	move.b  d2,12(a6)
	move.b  d2,14(a6)

	rts

lpvc1ste:
	ext.l	d0
	move.l 	lpvc1_1,a0
	add.l	lpvc1_2,d0
	move.l 	lpvc1_3,a2
	move.w  lpvc1_4,d6
	bra.s	contlp1ste

lpvc2ste:
	ext.l	d1
	move.l 	lpvc2_1,a1
	add.l	lpvc2_2,d1
	move.l 	lpvc2_3,a3
	move.w  lpvc2_4,d7
	move	#0,ccr
	bra.s	contlp2ste


; ST specific initialise - sets up shadow amiga registers etc

STspecific:
	bsr 	makevoltab
	lea 	nulsamp+2,a2
	moveq	#0,d0
	lea 	ch1s,a0
	bsr.s	initvoice
	lea 	ch2s,a0
	bsr.s	initvoice
	lea 	ch3s,a0
	bsr.s	initvoice
	lea 	ch4s,a0
	bsr.s	initvoice
	bsr 	start_music
	lea 	music_on,a0
	st  	(a0)
	rts

; A0-> voice data (paula voice) to initialise.

initvoice:
	move.l  a2,sam_start(a0) ; point voice to nul sample
	move.l  #2,sam_length(a0)
	move.w  d0,sam_period(a0) ; period=0
	move.w  d0,sam_vol(a0)  ; volume=0
	move.l  a2,sam_lpstart(a0) ; and loop point to nul sample
	move.l  #2,sam_lplength(a0)
	rts


;**************************************************
;*	----- Protracker V2.1A Playroutine -----	*
;* Peter "CRAYON" Hanning / Mushroom Studios 1992 *
;*	Vinterstigen 12, 14440 Ronninge, Sweden	*
;**************************************************

; CIA Version 1:
; This playroutine is not very fast, optimized or well commented,
; but all the new commands in PT2.1 should work.
; If it's not good enough, you'll have to change it yourself.
; We'll try to write a faster routine soon...

; Changes from V1.0C playroutine:
; - Vibrato depth changed to be compatible with Noisetracker 2.0.
;	You'll have to double all vib. depths on old PT modules.
; - Funk Repeat changed to Invert Loop.
; - Period set back earlier when stopping an effect.


;---- Playroutine ----

mt_init:
	movea.l	mod_addr,a0	; Address of module in A0
	move.l  a0,mt_SongDataPtr
	movea.l a0,a1
	lea 	952(a1),a1
	moveq	#127,d0
	moveq	#0,d1
mtloop:
	move.l  d1,d2
	subq.w  #1,d0
mtloop2:
	move.b  (a1)+,d1
	cmp.b	d2,d1
	bgt.s	mtloop
	dbra	d0,mtloop2
	addq.b  #1,d2

	lea 	mt_SampleStarts,a1
	asl.l	#8,d2
	asl.l	#2,d2
	add.l	#1084,d2
	add.l	a0,d2
	movea.l d2,a2
	moveq	#30,d0
mtloop3:
	clr.l	(a2)
	move.l  a2,(a1)+
	moveq	#0,d1
	move.w  42(a0),d1
	asl.l	#1,d1
	adda.l  d1,a2
	adda.l  #30,a0
	dbra	d0,mtloop3

	move.b  #6,mt_speed
	clr.b	mt_counter
	clr.b	mt_SongPos
	clr.w	mt_PatternPos
	st	mt_Enable

;(1) move_dmacon #$F
	andi.w  #$f0,shadow_dmacon ; mask bits in dmacon

	rts

mt_end: sf	mt_Enable

;(2) move_dmacon #$F
	andi.w  #$f0,shadow_dmacon

	rts

mt_music:
	tst.b	mt_Enable
	beq	mt_exit
	addq.b  #1,mt_counter
	move.b  mt_counter,d0
	cmp.b	mt_speed,d0
	blo.s	mt_NoNewNote
	clr.b	mt_counter
	tst.b	mt_PattDelTime2
	beq.s	mt_GetNewNote
	bsr.s	mt_NoNewAllChannels
	bra	mt_dskip

mt_NoNewNote:
	bsr.s	mt_NoNewAllChannels
	bra	mt_NoNewPosYet

mt_NoNewAllChannels:
	lea	ch1s,a5
	lea	mt_chan1temp,a6
	bsr	mt_CheckEfx
	lea	ch2s,a5
	lea	mt_chan2temp,a6
	bsr	mt_CheckEfx
	lea	ch3s,a5
	lea	mt_chan3temp,a6
	bsr	mt_CheckEfx
	lea	ch4s,a5
	lea	mt_chan4temp,a6
	bra	mt_CheckEfx

mt_GetNewNote:
	movea.l mt_SongDataPtr,a0
	lea	12(a0),a3
	lea	952(a0),a2	;pattpo
	lea	1084(a0),a0	;patterndata
	moveq	#0,d0
	moveq	#0,d1
	move.b  mt_SongPos,d0
	move.b  0(a2,d0.w),d1
	asl.l	#8,d1
	asl.l	#2,d1
	add.w	mt_PatternPos,d1
	clr.w	mt_DMACONtemp

	lea	ch1s,a5
	lea	mt_chan1temp,a6
	bsr.s	mt_PlayVoice
	lea	ch2s,a5
	lea	mt_chan2temp,a6
	bsr.s	mt_PlayVoice
	lea	ch3s,a5
	lea	mt_chan3temp,a6
	bsr.s	mt_PlayVoice
	lea	ch4s,a5
	lea	mt_chan4temp,a6
	bsr.s	mt_PlayVoice
	bra	mt_SetDMA

mt_PlayVoice:
	tst.l	(a6)
	bne.s	mt_plvskip
	bsr	mt_PerNop
mt_plvskip:
	move.l  0(a0,d1.l),(a6)
	addq.l  #4,d1
	moveq	#0,d2
	move.b  n_cmd(a6),d2
	and.b	#$f0,d2
	lsr.b	#4,d2
	move.b  (a6),d0
	and.b	#$f0,d0
	or.b	d0,d2
	tst.b	d2
	beq	mt_SetRegs
	moveq	#0,d3
	lea	mt_SampleStarts,a1
	move.w  d2,d4
	subq.l  #1,d2
	asl.l	#2,d2
	mulu	#30,d4
	move.l  0(a1,d2.l),n_start(a6)
	move.w  0(a3,d4.l),n_length(a6)
	move.w  0(a3,d4.l),n_reallength(a6)
	move.b  2(a3,d4.l),n_finetune(a6)
	move.b  3(a3,d4.l),n_volume(a6)
	move.w  4(a3,d4.l),d3	; Get repeat
	tst.w	d3
	beq.s	mt_NoLoop
	move.l  n_start(a6),d2  ; Get start
	asl.w	#1,d3
	add.l	d3,d2	; Add repeat
	move.l  d2,n_loopstart(a6)
	move.l  d2,n_wavestart(a6)
	move.w  4(a3,d4.l),d0	; Get repeat
	add.w	6(a3,d4.l),d0	; Add replen
	move.w  d0,n_length(a6)
	move.w  6(a3,d4.l),n_replen(a6) ; Save replen
	moveq	#0,d0
	move.b  n_volume(a6),d0
	move.w  d0,sam_vol(a5)  ; Set volume
	bra.s	mt_SetRegs
mt_NoLoop:
	move.l  n_start(a6),d2
	add.l	d3,d2
	move.l  d2,n_loopstart(a6)
	move.l  d2,n_wavestart(a6)
	move.w  6(a3,d4.l),n_replen(a6) ; Save replen
	moveq	#0,d0
	move.b  n_volume(a6),d0
	move.w  d0,sam_vol(a5)  ; Set volume
mt_SetRegs:
	move.w  (a6),d0
	and.w	#$0fff,d0
	beq	mt_CheckMoreEfx ; If no note
	move.w  2(a6),d0
	and.w	#$0ff0,d0
	cmp.w	#$0e50,d0
	beq.s	mt_DoSetFineTune
	move.b  2(a6),d0
	and.b	#$0f,d0
	cmp.b	#3,d0	; TonePortamento
	beq.s	mt_ChkTonePorta
	cmp.b	#5,d0
	beq.s	mt_ChkTonePorta
	cmp.b	#9,d0	; Sample Offset
	bne.s	mt_SetPeriod
	bsr	mt_CheckMoreEfx
	bra.s	mt_SetPeriod

mt_DoSetFineTune:
	bsr	mt_SetFineTune
	bra.s	mt_SetPeriod

mt_ChkTonePorta:
	bsr	mt_SetTonePorta
	bra	mt_CheckMoreEfx

mt_SetPeriod:
	movem.l d0-d1/a0-a1,-(sp)
	move.w  (a6),d1
	and.w	#$0fff,d1
	lea	mt_PeriodTable(pc),a1
	moveq	#0,d0
	moveq	#36,d2
mt_ftuloop:
	cmp.w	0(a1,d0.w),d1
	bhs.s	mt_ftufound
	addq.l  #2,d0
	dbra	d2,mt_ftuloop
mt_ftufound:
	moveq	#0,d1
	move.b  n_finetune(a6),d1
	mulu	#36*2,d1
	adda.l  d1,a1
	move.w  0(a1,d0.w),n_period(a6)
	movem.l (sp)+,d0-d1/a0-a1

	move.w  2(a6),d0
	and.w	#$0ff0,d0
	cmp.w	#$0ed0,d0	; Notedelay
	beq 	mt_CheckMoreEfx

;(3) move_dmacon n_dmabit(A6)
	move.w  d4,-(sp)	; save D4
	move.w  n_dmabit(a6),d4
	btst	#15,d4	; set or clear?
	bne.s	setbits3
	not.w	d4		; zero so clear
	and.w	d4,shadow_dmacon ; mask bits in dmacon
	bra.s	dmacon_set3	; and exit...
setbits3:
	or.w	d4,shadow_dmacon ; not zero so set 'em
dmacon_set3:
	move.w	(sp)+,d4	; restore D4

	btst	#2,n_wavecontrol(a6)
	bne.s	mt_vibnoc
	clr.b	n_vibratopos(a6)
mt_vibnoc:
	btst	#6,n_wavecontrol(a6)
	bne.s	mt_trenoc
	clr.b	n_tremolopos(a6)
mt_trenoc:
	move.l  n_start(a6),sam_start(a5) ; Set start
	moveq	#0,d0
	move.w  n_length(a6),d0
	add.l	d0,d0
	add.l	d0,sam_start(a5)
	move.l  d0,sam_length(a5) ; Set length

	move.w  n_period(a6),d0
	move.w  d0,sam_period(a5) ; Set period
	move.w  n_dmabit(a6),d0
	or.w	d0,mt_DMACONtemp
	bra 	mt_CheckMoreEfx

mt_SetDMA:
	move.w  mt_DMACONtemp,d0
	or.w	#$8000,d0

;(4) move_dmacon d0
	move.w  d4,-(sp)
	move.w  d0,d4
	btst	#15,d4
	bne.s	setbits4
	not.w	d4
	and.w	d4,shadow_dmacon
	bra.s	dmacon_set4
setbits4:
	or.w	d4,shadow_dmacon
dmacon_set4:
	move.w	(sp)+,d4

	lea	ch4s,a5
	lea	mt_chan4temp,a6
	move.l  n_loopstart(a6),sam_lpstart(a5)
	moveq	#0,d0
	move.w  n_replen(a6),d0
	add.l	d0,d0
	move.l  d0,sam_lplength(a5)
	add.l	d0,sam_lpstart(a5)

	lea	ch3s,a5
	lea	mt_chan3temp,a6
	move.l  n_loopstart(a6),sam_lpstart(a5)
	moveq	#0,d0
	move.w  n_replen(a6),d0
	add.l	d0,d0
	move.l  d0,sam_lplength(a5)
	add.l	d0,sam_lpstart(a5)

	lea	ch2s,a5
	lea	mt_chan2temp,a6
	move.l  n_loopstart(a6),sam_lpstart(a5)
	moveq	#0,d0
	move.w  n_replen(a6),d0
	add.l	d0,d0
	move.l  d0,sam_lplength(a5)
	add.l	d0,sam_lpstart(a5)

	lea	ch1s,a5
	lea	mt_chan1temp,a6
	move.l  n_loopstart(a6),sam_lpstart(a5)
	moveq	#0,d0
	move.w  n_replen(a6),d0
	add.l	d0,d0
	move.l  d0,sam_lplength(a5)
	add.l	d0,sam_lpstart(a5)

mt_dskip:
	addi.w  #16,mt_PatternPos
	move.b  mt_PattDelTime,d0
	beq.s	mt_dskc
	move.b  d0,mt_PattDelTime2
	clr.b	mt_PattDelTime
mt_dskc:tst.b	mt_PattDelTime2
	beq.s	mt_dska
	subq.b  #1,mt_PattDelTime2
	beq.s	mt_dska
	subi.w  #16,mt_PatternPos
mt_dska:tst.b	mt_PBreakFlag
	beq.s	mt_nnpysk
	sf	mt_PBreakFlag
	moveq	#0,d0
	move.b  mt_PBreakPos,d0
	clr.b	mt_PBreakPos
	lsl.w	#4,d0
	move.w  d0,mt_PatternPos
mt_nnpysk:
	cmpi.w  #1024,mt_PatternPos
	blo.s	mt_NoNewPosYet
mt_NextPosition:
	moveq	#0,d0
	move.b  mt_PBreakPos,d0
	lsl.w	#4,d0
	move.w  d0,mt_PatternPos
	clr.b	mt_PBreakPos
	clr.b	mt_PosJumpFlag
	addq.b  #1,mt_SongPos
	andi.b  #$7f,mt_SongPos
	move.b  mt_SongPos,d1
	movea.l mt_SongDataPtr,a0
	cmp.b	950(a0),d1
	blo.s	mt_NoNewPosYet
	clr.b	mt_SongPos
mt_NoNewPosYet:
	tst.b	mt_PosJumpFlag
	bne.s	mt_NextPosition
mt_exit:
	rts

mt_CheckEfx:
	bsr 	mt_UpdateFunk
	move.w  n_cmd(a6),d0
	and.w	#$0fff,d0
	beq.s	mt_PerNop
	move.b  n_cmd(a6),d0
	and.b	#$0f,d0
	beq.s	mt_Arpeggio
	cmp.b	#1,d0
	beq 	mt_PortaUp
	cmp.b	#2,d0
	beq 	mt_PortaDown
	cmp.b	#3,d0
	beq 	mt_TonePortamento
	cmp.b	#4,d0
	beq 	mt_Vibrato
	cmp.b	#5,d0
	beq 	mt_TonePlusVolSlide
	cmp.b	#6,d0
	beq 	mt_VibratoPlusVolSlide
	cmp.b	#$0e,d0
	beq 	mt_E_Commands
SetBack:
	move.w	n_period(a6),sam_period(a5)
	cmp.b	#7,d0
	beq 	mt_Tremolo
	cmp.b	#$0a,d0
	beq 	mt_VolumeSlide
mt_Return:
	rts

mt_PerNop:
	move.w  n_period(a6),sam_period(a5)
	rts

mt_Arpeggio:
	moveq	#0,d0
	move.b  mt_counter,d0
	divs	#3,d0
	swap	d0
	cmp.w	#0,d0
	beq.s	mt_Arpeggio2
	cmp.w	#2,d0
	beq.s	mt_Arpeggio1
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	lsr.b	#4,d0
	bra.s	mt_Arpeggio3

mt_Arpeggio1:
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	and.b	#15,d0
	bra.s	mt_Arpeggio3

mt_Arpeggio2:
	move.w  n_period(a6),d2
	bra.s	mt_Arpeggio4

mt_Arpeggio3:
	asl.w	#1,d0
	moveq	#0,d1
	move.b  n_finetune(a6),d1
	mulu	#36*2,d1
	lea	mt_PeriodTable(pc),a0
	adda.l  d1,a0
	moveq	#0,d1
	move.w  n_period(a6),d1
	moveq	#36,d3
mt_arploop:
	move.w  0(a0,d0.w),d2
	cmp.w	(a0),d1
	bhs.s	mt_Arpeggio4
	addq.l  #2,a0
	dbra	d3,mt_arploop
	rts

mt_Arpeggio4:
	move.w  d2,sam_period(a5)
	rts

mt_FinePortaUp:
	tst.b	mt_counter
	bne.s	mt_Return
	move.b  #$0f,mt_LowMask
mt_PortaUp:
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	and.b	mt_LowMask,d0
	move.b  #$ff,mt_LowMask
	sub.w	d0,n_period(a6)
	move.w  n_period(a6),d0
	and.w	#$0fff,d0
	cmp.w	#113,d0
	bpl.s	mt_PortaUskip
	andi.w  #$f000,n_period(a6)
	ori.w	#113,n_period(a6)
mt_PortaUskip:
	move.w  n_period(a6),d0
	and.w	#$0fff,d0
	move.w  d0,sam_period(a5)
	rts

mt_FinePortaDown:
	tst.b	mt_counter
	bne	mt_Return
	move.b  #$0f,mt_LowMask
mt_PortaDown:
	clr.w	d0
	move.b  n_cmdlo(a6),d0
	and.b	mt_LowMask,d0
	move.b  #$ff,mt_LowMask
	add.w	d0,n_period(a6)
	move.w  n_period(a6),d0
	and.w	#$0fff,d0
	cmp.w	#856,d0
	bmi.s	mt_PortaDskip
	andi.w  #$f000,n_period(a6)
	ori.w	#856,n_period(a6)
mt_PortaDskip:
	move.w  n_period(a6),d0
	and.w	#$0fff,d0
	move.w  d0,sam_period(a5)
	rts

mt_SetTonePorta:
	move.l  a0,-(sp)
	move.w  (a6),d2
	and.w	#$0fff,d2
	moveq	#0,d0
	move.b  n_finetune(a6),d0
	mulu	#37*2,d0
	lea	mt_PeriodTable(pc),a0
	adda.l  d0,a0
	moveq	#0,d0
mt_StpLoop:
	cmp.w	0(a0,d0.w),d2
	bhs.s	mt_StpFound
	addq.w  #2,d0
	cmp.w	#37*2,d0
	blo.s	mt_StpLoop
	moveq	#35*2,d0
mt_StpFound:
	move.b  n_finetune(a6),d2
	and.b	#8,d2
	beq.s	mt_StpGoss
	tst.w	d0
	beq.s	mt_StpGoss
	subq.w  #2,d0
mt_StpGoss:
	move.w  0(a0,d0.w),d2
	movea.l (sp)+,a0
	move.w  d2,n_wantedperiod(a6)
	move.w  n_period(a6),d0
	clr.b	n_toneportdirec(a6)
	cmp.w	d0,d2
	beq.s	mt_ClearTonePorta
	bge	mt_Return
	move.b  #1,n_toneportdirec(a6)
	rts

mt_ClearTonePorta:
	clr.w	n_wantedperiod(a6)
	rts

mt_TonePortamento:
	move.b  n_cmdlo(a6),d0
	beq.s	mt_TonePortNoChange
	move.b  d0,n_toneportspeed(a6)
	clr.b	n_cmdlo(a6)
mt_TonePortNoChange:
	tst.w	n_wantedperiod(a6)
	beq	mt_Return
	moveq	#0,d0
	move.b  n_toneportspeed(a6),d0
	tst.b	n_toneportdirec(a6)
	bne.s	mt_TonePortaUp
mt_TonePortaDown:
	add.w	d0,n_period(a6)
	move.w  n_wantedperiod(a6),d0
	cmp.w	n_period(a6),d0
	bgt.s	mt_TonePortaSetPer
	move.w  n_wantedperiod(a6),n_period(a6)
	clr.w	n_wantedperiod(a6)
	bra.s	mt_TonePortaSetPer

mt_TonePortaUp:
	sub.w	d0,n_period(a6)
	move.w  n_wantedperiod(a6),d0
	cmp.w	n_period(a6),d0
	blt.s	mt_TonePortaSetPer
	move.w  n_wantedperiod(a6),n_period(a6)
	clr.w	n_wantedperiod(a6)

mt_TonePortaSetPer:
	move.w  n_period(a6),d2
	move.b  n_glissfunk(a6),d0
	and.b	#$0f,d0
	beq.s	mt_GlissSkip
	moveq	#0,d0
	move.b  n_finetune(a6),d0
	mulu	#36*2,d0
	lea	mt_PeriodTable(pc),a0
	adda.l  d0,a0
	moveq	#0,d0
mt_GlissLoop:
	cmp.w	0(a0,d0.w),d2
	bhs.s	mt_GlissFound
	addq.w  #2,d0
	cmp.w	#36*2,d0
	blo.s	mt_GlissLoop
	moveq	#35*2,d0
mt_GlissFound:
	move.w  0(a0,d0.w),d2
mt_GlissSkip:
	move.w  d2,sam_period(a5) ; Set period
	rts

mt_Vibrato:
	move.b  n_cmdlo(a6),d0
	beq.s	mt_Vibrato2
	move.b  n_vibratocmd(a6),d2
	and.b	#$0f,d0
	beq.s	mt_vibskip
	and.b	#$f0,d2
	or.b	d0,d2
mt_vibskip:
	move.b  n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.s	mt_vibskip2
	and.b	#$0f,d2
	or.b	d0,d2
mt_vibskip2:
	move.b  d2,n_vibratocmd(a6)
mt_Vibrato2:
	move.b  n_vibratopos(a6),d0
	lea	mt_VibratoTable(pc),a4
	lsr.w	#2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b  n_wavecontrol(a6),d2
	and.b	#$03,d2
	beq.s	mt_vib_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	mt_vib_rampdown
	move.b  #255,d2
	bra.s	mt_vib_set
mt_vib_rampdown:
	tst.b	n_vibratopos(a6)
	bpl.s	mt_vib_rampdown2
	move.b  #255,d2
	sub.b	d0,d2
	bra.s	mt_vib_set
mt_vib_rampdown2:
	move.b  d0,d2
	bra.s	mt_vib_set
mt_vib_sine:
	move.b  0(a4,d0.w),d2
mt_vib_set:
	move.b  n_vibratocmd(a6),d0
	and.w	#15,d0
	mulu	d0,d2
	lsr.w	#7,d2
	move.w  n_period(a6),d0
	tst.b	n_vibratopos(a6)
	bmi.s	mt_VibratoNeg
	add.w	d2,d0
	bra.s	mt_Vibrato3
mt_VibratoNeg:
	sub.w	d2,d0
mt_Vibrato3:
	move.w  d0,sam_period(a5)
	move.b  n_vibratocmd(a6),d0
	lsr.w	#2,d0
	and.w	#$3c,d0
	add.b	d0,n_vibratopos(a6)
	rts

mt_TonePlusVolSlide:
	bsr	mt_TonePortNoChange
	bra	mt_VolumeSlide

mt_VibratoPlusVolSlide:
	bsr.s	mt_Vibrato2
	bra	mt_VolumeSlide

mt_Tremolo:
	move.b  n_cmdlo(a6),d0
	beq.s	mt_Tremolo2
	move.b  n_tremolocmd(a6),d2
	and.b	#$0f,d0
	beq.s	mt_treskip
	and.b	#$f0,d2
	or.b	d0,d2
mt_treskip:
	move.b  n_cmdlo(a6),d0
	and.b	#$f0,d0
	beq.s	mt_treskip2
	and.b	#$0f,d2
	or.b	d0,d2
mt_treskip2:
	move.b  d2,n_tremolocmd(a6)
mt_Tremolo2:
	move.b  n_tremolopos(a6),d0
	lea	mt_VibratoTable(pc),a4
	lsr.w	#2,d0
	and.w	#$1f,d0
	moveq	#0,d2
	move.b  n_wavecontrol(a6),d2
	lsr.b	#4,d2
	and.b	#$03,d2
	beq.s	mt_tre_sine
	lsl.b	#3,d0
	cmp.b	#1,d2
	beq.s	mt_tre_rampdown
	move.b  #255,d2
	bra.s	mt_tre_set
mt_tre_rampdown:
	tst.b	n_vibratopos(a6)
	bpl.s	mt_tre_rampdown2
	move.b  #255,d2
	sub.b	d0,d2
	bra.s	mt_tre_set
mt_tre_rampdown2:
	move.b  d0,d2
	bra.s	mt_tre_set
mt_tre_sine:
	move.b  0(a4,d0.w),d2
mt_tre_set:
	move.b  n_tremolocmd(a6),d0
	and.w	#15,d0
	mulu	d0,d2
	lsr.w	#6,d2
	moveq	#0,d0
	move.b  n_volume(a6),d0
	tst.b	n_tremolopos(a6)
	bmi.s	mt_TremoloNeg
	add.w	d2,d0
	bra.s	mt_Tremolo3
mt_TremoloNeg:
	sub.w	d2,d0
mt_Tremolo3:
	bpl.s	mt_TremoloSkip
	clr.w	d0
mt_TremoloSkip:
	cmp.w	#$40,d0
	bls.s	mt_TremoloOk
	move.w  #$40,d0
mt_TremoloOk:
	move.w  d0,sam_vol(a5)
	move.b  n_tremolocmd(a6),d0
	lsr.w	#2,d0
	and.w	#$3c,d0
	add.b	d0,n_tremolopos(a6)
	rts

mt_SampleOffset:
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	beq.s	mt_sononew
	move.b  d0,n_sampleoffset(a6)
mt_sononew:
	move.b  n_sampleoffset(a6),d0
	lsl.w	#7,d0
	cmp.w	n_length(a6),d0
	bge.s	mt_sofskip
	sub.w	d0,n_length(a6)
	lsl.w	#1,d0
	add.l	d0,n_start(a6)
	rts
mt_sofskip:
	move.w  #$01,n_length(a6)
	rts

mt_VolumeSlide:
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	lsr.b	#4,d0
	tst.b	d0
	beq.s	mt_VolSlideDown
mt_VolSlideUp:
	add.b	d0,n_volume(a6)
	cmpi.b  #$40,n_volume(a6)
	bmi.s	mt_vsuskip
	move.b  #$40,n_volume(a6)
mt_vsuskip:
	move.b  n_volume(a6),d0
	move.w  d0,sam_vol(a5)
	rts

mt_VolSlideDown:
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
mt_VolSlideDown2:
	sub.b	d0,n_volume(a6)
	bpl.s	mt_vsdskip
	clr.b	n_volume(a6)
mt_vsdskip:
	move.b  n_volume(a6),d0
	move.w  d0,sam_vol(a5)
	rts

mt_PositionJump:
	move.b  n_cmdlo(a6),d0
	subq.b  #1,d0
	move.b  d0,mt_SongPos
mt_pj2: clr.b	mt_PBreakPos
	st	mt_PosJumpFlag
	rts

mt_VolumeChange:
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	cmp.b	#$40,d0
	bls.s	mt_VolumeOk
	moveq	#$40,d0
mt_VolumeOk:
	move.b  d0,n_volume(a6)
	move.w  d0,sam_vol(a5)
	rts

mt_PatternBreak:
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	move.l  d0,d2
	lsr.b	#4,d0
	mulu	#10,d0
	and.b	#$0f,d2
	add.b	d2,d0
	cmp.b	#63,d0
	bhi.s	mt_pj2
	move.b  d0,mt_PBreakPos
	st	mt_PosJumpFlag
	rts

mt_SetSpeed:
	moveq	#0,d0
	move.b  3(a6),d0
	beq	mt_end
	tst.b	tempo_cont_flg  ; tempo control on?
	beq.s	notempo
	cmp.b	#32,d0	; yes then d0>=32
	bhs.s	SetTempo	; then Set Tempo
	clr.b	mt_counter
	move.b  d0,mt_speed
	rts
notempo:			; tempo control is OFF
	clr.b	mt_counter
	move.b  d0,mt_speed	; so set speed  regardless
	cmp.w	#32,d0
	blo.s	okdefspeed
	move.w  d0,OldTempo	; but store in old tempo
okdefspeed:			; for tempo turn back on.
	rts

SetTempo:
	cmp.w	#32,d0
	bhs.s	setemsk
	moveq	#32,d0
setemsk:move.w  d0,RealTempo	; set tempo speed
	rts

mt_CheckMoreEfx:
	bsr	mt_UpdateFunk
	move.b  2(a6),d0
	and.b	#$0f,d0
	cmp.b	#$09,d0
	beq	mt_SampleOffset
	cmp.b	#$0b,d0
	beq	mt_PositionJump
	cmp.b	#$0d,d0
	beq	mt_PatternBreak
	cmp.b	#$0e,d0
	beq.s	mt_E_Commands
	cmp.b	#$0f,d0
	beq.s	mt_SetSpeed
	cmp.b	#$0c,d0
	beq	mt_VolumeChange
	bra	mt_PerNop

mt_E_Commands:
	move.b  n_cmdlo(a6),d0
	and.b	#$f0,d0
	lsr.b	#4,d0
	beq.s	mt_FilterOnOff
	cmp.b	#1,d0
	beq 	mt_FinePortaUp
	cmp.b	#2,d0
	beq 	mt_FinePortaDown
	cmp.b	#3,d0
	beq.s	mt_SetGlissControl
	cmp.b	#4,d0
	beq.s	mt_SetVibratoControl
	cmp.b	#5,d0
	beq.s	mt_SetFineTune
	cmp.b	#6,d0
	beq 	mt_JumpLoop
	cmp.b	#7,d0
	beq 	mt_SetTremoloControl
	cmp.b	#9,d0
	beq 	mt_RetrigNote
	cmp.b	#$0a,d0
	beq 	mt_VolumeFineUp
	cmp.b	#$0b,d0
	beq 	mt_VolumeFineDown
	cmp.b	#$0c,d0
	beq 	mt_NoteCut
	cmp.b	#$0d,d0
	beq 	mt_NoteDelay
	cmp.b	#$0e,d0
	beq 	mt_PatternDelay
	cmp.b	#$0f,d0
	beq 	mt_FunkIt
	rts

mt_FilterOnOff:
	move.b  n_cmdlo(a6),d0
	and.b	#1,d0
	asl.b	#1,d0
;	and.b	#$FD,$BFE001		; filter!
;	or.b	D0,$BFE001		; hehe
	rts

mt_SetGlissControl:
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	andi.b  #$f0,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	rts

mt_SetVibratoControl:
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	andi.b  #$f0,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

mt_SetFineTune:
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	move.b  d0,n_finetune(a6)
	rts

mt_JumpLoop:
	tst.b	mt_counter
	bne	mt_Return
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	beq.s	mt_SetLoop
	tst.b	n_loopcount(a6)
	beq.s	mt_jumpcnt
	subq.b  #1,n_loopcount(a6)
	beq	mt_Return
mt_jmploop:move.b n_pattpos(a6),mt_PBreakPos
	st	mt_PBreakFlag
	rts

mt_jumpcnt:
	move.b  d0,n_loopcount(a6)
	bra.s	mt_jmploop

mt_SetLoop:
	move.w  mt_PatternPos,d0
	lsr.w	#4,d0
	move.b  d0,n_pattpos(a6)
	rts

mt_SetTremoloControl:
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	lsl.b	#4,d0
	andi.b  #$0f,n_wavecontrol(a6)
	or.b	d0,n_wavecontrol(a6)
	rts

mt_RetrigNote:
	move.l  d1,-(sp)
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	beq	mt_rtnend
	moveq	#0,d1
	move.b  mt_counter,d1
	bne.s	mt_rtnskp
	move.w  (a6),d1
	and.w	#$0fff,d1
	bne	mt_rtnend
	moveq	#0,d1
	move.b  mt_counter,d1
mt_rtnskp:
	divu	d0,d1
	swap	d1
	tst.w	d1
	bne.s	mt_rtnend
mt_DoRetrig:

;(5) move_dmacon n_dmabit(A6)	; Channel DMA off
	move.w  d4,-(sp)
	move.w  n_dmabit(a6),d4
	btst	#15,d4
	bne.s	setbits5
	not.w	d4
	and.w	d4,shadow_dmacon
	bra.s	dmacon_set5
setbits5:or.w	d4,shadow_dmacon
dmacon_set5:move.w (sp)+,d4

	move.l  n_start(a6),sam_start(a5) ; Set sampledata pointer
	moveq	#0,d0
	move.w  n_length(a6),d0 ; Set length
	add.l	d0,d0
	add.l	d0,sam_start(a5)
	move.l  d0,sam_length(a5) ; Set length

	move.w  n_dmabit(a6),d0
	bset	#15,d0

;(6) move_dmacon d0
	move.w  d4,-(sp)
	move.w  d0,d4
	btst	#15,d4
	bne.s	setbits6
	not.w	d4
	and.w	d4,shadow_dmacon
	bra.s	dmacon_set6
setbits6:or.w	d4,shadow_dmacon
dmacon_set6:move.w (sp)+,d4

	move.l  n_loopstart(a6),sam_lpstart(a5)
	moveq	#0,d0
	move.w  n_replen(a6),d0
	add.l	d0,d0
	add.l	d0,sam_lpstart(a5)
	move.l  d0,sam_lplength(a5)
	move.w  n_replen+2(a6),sam_period(a5)
mt_rtnend:
	move.l  (sp)+,d1
	rts

mt_VolumeFineUp:
	tst.b	mt_counter
	bne	mt_Return
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	bra	mt_VolSlideUp

mt_VolumeFineDown:
	tst.b	mt_counter
	bne	mt_Return
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	bra	mt_VolSlideDown2

mt_NoteCut:
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	cmp.b	mt_counter,d0
	bne	mt_Return
	clr.b	n_volume(a6)
	move.w  #0,sam_vol(a5)
	rts

mt_NoteDelay:
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	cmp.b	mt_counter,d0
	bne	mt_Return
	move.w  (a6),d0
	beq	mt_Return
	move.l  d1,-(sp)
	bra	mt_DoRetrig

mt_PatternDelay:
	tst.b	mt_counter
	bne	mt_Return
	moveq	#0,d0
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	tst.b	mt_PattDelTime2
	bne	mt_Return
	addq.b  #1,d0
	move.b  d0,mt_PattDelTime
	rts

mt_FunkIt:
	tst.b	mt_counter
	bne	mt_Return
	move.b  n_cmdlo(a6),d0
	and.b	#$0f,d0
	lsl.b	#4,d0
	andi.b  #$0f,n_glissfunk(a6)
	or.b	d0,n_glissfunk(a6)
	tst.b	d0
	beq	mt_Return
mt_UpdateFunk:
	movem.l d1/a0,-(sp)
	moveq	#0,d0
	move.b  n_glissfunk(a6),d0
	lsr.b	#4,d0
	beq.s	mt_funkend
	lea	mt_FunkTable(pc),a0
	move.b  0(a0,d0.w),d0
	add.b	d0,n_funkoffset(a6)
	btst	#7,n_funkoffset(a6)
	beq.s	mt_funkend
	clr.b	n_funkoffset(a6)

	move.l  n_loopstart(a6),d0
	moveq	#0,d1
	move.w  n_replen(a6),d1
	add.l	d1,d0
	add.l	d1,d0
	movea.l n_wavestart(a6),a0
	addq.l  #1,a0
	cmpa.l  d0,a0
	blo.s	mt_funkok
	movea.l n_loopstart(a6),a0
mt_funkok:
	move.l  a0,n_wavestart(a6)
	moveq	#-1,d0
	sub.b	(a0),d0
	move.b  d0,(a0)
mt_funkend:
	movem.l (sp)+,d1/a0
	rts


;**** Tables ****

mt_FunkTable:dc.b 0,5,6,7,8,10,11,13,16,19,22,26,32,43,64,128

mt_VibratoTable:
	dc.b 0,24,49,74,97,120,141,161
	dc.b 180,197,212,224,235,244,250,253
	dc.b 255,253,250,244,235,224,212,197
	dc.b 180,161,141,120,97,74,49,24

mt_PeriodTable:
; Tuning 0, Normal
	dc.w 856,808,762,720,678,640,604,570,538,508,480,453
	dc.w 428,404,381,360,339,320,302,285,269,254,240,226
	dc.w 214,202,190,180,170,160,151,143,135,127,120,113
; Tuning 1
	dc.w 850,802,757,715,674,637,601,567,535,505,477,450
	dc.w 425,401,379,357,337,318,300,284,268,253,239,225
	dc.w 213,201,189,179,169,159,150,142,134,126,119,113
; Tuning 2
	dc.w 844,796,752,709,670,632,597,563,532,502,474,447
	dc.w 422,398,376,355,335,316,298,282,266,251,237,224
	dc.w 211,199,188,177,167,158,149,141,133,125,118,112
; Tuning 3
	dc.w 838,791,746,704,665,628,592,559,528,498,470,444
	dc.w 419,395,373,352,332,314,296,280,264,249,235,222
	dc.w 209,198,187,176,166,157,148,140,132,125,118,111
; Tuning 4
	dc.w 832,785,741,699,660,623,588,555,524,495,467,441
	dc.w 416,392,370,350,330,312,294,278,262,247,233,220
	dc.w 208,196,185,175,165,156,147,139,131,124,117,110
; Tuning 5
	dc.w 826,779,736,694,655,619,584,551,520,491,463,437
	dc.w 413,390,368,347,328,309,292,276,260,245,232,219
	dc.w 206,195,184,174,164,155,146,138,130,123,116,109
; Tuning 6
	dc.w 820,774,730,689,651,614,580,547,516,487,460,434
	dc.w 410,387,365,345,325,307,290,274,258,244,230,217
	dc.w 205,193,183,172,163,154,145,137,129,122,115,109
; Tuning 7
	dc.w 814,768,725,684,646,610,575,543,513,484,457,431
	dc.w 407,384,363,342,323,305,288,272,256,242,228,216
	dc.w 204,192,181,171,161,152,144,136,128,121,114,108
; Tuning -8
	dc.w 907,856,808,762,720,678,640,604,570,538,508,480
	dc.w 453,428,404,381,360,339,320,302,285,269,254,240
	dc.w 226,214,202,190,180,170,160,151,143,135,127,120
; Tuning -7
	dc.w 900,850,802,757,715,675,636,601,567,535,505,477
	dc.w 450,425,401,379,357,337,318,300,284,268,253,238
	dc.w 225,212,200,189,179,169,159,150,142,134,126,119
; Tuning -6
	dc.w 894,844,796,752,709,670,632,597,563,532,502,474
	dc.w 447,422,398,376,355,335,316,298,282,266,251,237
	dc.w 223,211,199,188,177,167,158,149,141,133,125,118
; Tuning -5
	dc.w 887,838,791,746,704,665,628,592,559,528,498,470
	dc.w 444,419,395,373,352,332,314,296,280,264,249,235
	dc.w 222,209,198,187,176,166,157,148,140,132,125,118
; Tuning -4
	dc.w 881,832,785,741,699,660,623,588,555,524,494,467
	dc.w 441,416,392,370,350,330,312,294,278,262,247,233
	dc.w 220,208,196,185,175,165,156,147,139,131,123,117
; Tuning -3
	dc.w 875,826,779,736,694,655,619,584,551,520,491,463
	dc.w 437,413,390,368,347,328,309,292,276,260,245,232
	dc.w 219,206,195,184,174,164,155,146,138,130,123,116
; Tuning -2
	dc.w 868,820,774,730,689,651,614,580,547,516,487,460
	dc.w 434,410,387,365,345,325,307,290,274,258,244,230
	dc.w 217,205,193,183,172,163,154,145,137,129,122,115
; Tuning -1
	dc.w 862,814,768,725,684,646,610,575,543,513,484,457
	dc.w 431,407,384,363,342,323,305,288,272,256,242,228
	dc.w 216,203,192,181,171,161,152,144,136,128,121,114


;*** Freq.-table: ***
;* extern unsigned short ftab2[3840];
;* void crefrqtb()
;* {
;*  unsigned short per;
;*  double work,freq_amiga=3579545.0,freq_st=25033.0/2;
;*  unsigned short *x;
;*  x = ftab2;
;*  for (per = 1 ; per <= (1024+256) ; per++) 
;*   {
;*    work = (freq_amiga/(double)per)/freq_st; /* whole part */
;*    *x++=(unsigned short)work;
;*    *(long *)x = (65536.0*frac(work)*65536.0); /* output frac */
;*    x+=2;		
;*   }
;* }
;* double frac(double x)
;* {
;*  long i=x;
;*  return (x - i);
;* }
ftab:	ds.w 3
 dc.b $01,$1D,$FC,$70,$F1,$04,$00,$8E,$FE,$38,$78,$82,$00,$5F,$54,$25,$A5,$AC
 dc.b $00,$47,$7F,$1C,$3C,$41,$00,$39,$32,$7C,$FD,$00,$00,$2F,$AA,$12,$D2,$D6
 dc.b $00,$28,$DA,$EB,$90,$25,$00,$23,$BF,$8E,$1E,$20,$00,$1F,$C6,$B7,$37,$39
 dc.b $00,$1C,$99,$3E,$7E,$80,$00,$19,$FF,$AD,$2D,$2E,$00,$17,$D5,$09,$69,$6B
 dc.b $00,$15,$FF,$B9,$EB,$27,$00,$14,$6D,$75,$C8,$12,$00,$13,$10,$D4,$54,$55
 dc.b $00,$11,$DF,$C7,$0F,$10,$00,$10,$D2,$9D,$3B,$5A,$00,$0F,$E3,$5B,$9B,$9C
 dc.b $00,$0F,$0D,$49,$50,$0D,$00,$0E,$4C,$9F,$3F,$40,$00,$0D,$9E,$4E,$85,$61
 dc.b $00,$0C,$FF,$D6,$96,$97,$00,$0C,$6F,$26,$4D,$42,$00,$0B,$EA,$84,$B4,$B5
 dc.b $00,$0B,$70,$7F,$65,$CC,$00,$0A,$FF,$DC,$F5,$93,$00,$0A,$97,$92,$67,$BD
 dc.b $00,$0A,$36,$BA,$E4,$09,$00,$09,$DC,$91,$22,$CB,$00,$09,$88,$6A,$2A,$2A
 dc.b $00,$09,$39,$B1,$10,$08,$00,$08,$EF,$E3,$87,$88,$00,$08,$AA,$8F,$0F,$0F
 dc.b $00,$08,$69,$4E,$9D,$AD,$00,$08,$2B,$C8,$B6,$6D,$00,$07,$F1,$AD,$CD,$CE
 dc.b $00,$07,$BA,$B6,$F1,$C1,$00,$07,$86,$A4,$A8,$06,$00,$07,$55,$3D,$F9,$0D
 dc.b $00,$07,$26,$4F,$9F,$A0,$00,$06,$F9,$AB,$57,$0C,$00,$06,$CF,$27,$42,$B0
 dc.b $00,$06,$A6,$9D,$6A,$D0,$00,$06,$7F,$EB,$4B,$4B,$00,$06,$5A,$F1,$71,$71
 dc.b $00,$06,$37,$93,$26,$A1,$00,$06,$15,$B6,$25,$CF,$00,$05,$F5,$42,$5A,$5A
 dc.b $00,$05,$D6,$21,$A6,$E0,$00,$05,$B8,$3F,$B2,$E6,$00,$05,$9B,$89,$BE,$73
 dc.b $00,$05,$7F,$EE,$7A,$C9,$00,$05,$65,$5D,$E7,$90,$00,$05,$4B,$C9,$33,$DE
 dc.b $00,$05,$33,$22,$A2,$A2,$00,$05,$1B,$5D,$72,$04,$00,$05,$04,$6D,$C5,$59
 dc.b $00,$04,$EE,$48,$91,$65,$00,$04,$D8,$E3,$8A,$97,$00,$04,$C4,$35,$15,$15
 dc.b $00,$04,$B0,$34,$36,$4F,$00,$04,$9C,$D8,$88,$04,$00,$04,$8A,$1A,$2C,$75
 dc.b $00,$04,$77,$F1,$C3,$C4,$00,$04,$66,$58,$62,$3B,$00,$04,$55,$47,$87,$87
 dc.b $00,$04,$44,$B9,$16,$B3,$00,$04,$34,$A7,$4E,$D6,$00,$04,$25,$0C,$C4,$6B
 dc.b $00,$04,$15,$E4,$5B,$36,$00,$04,$07,$29,$40,$B0,$00,$03,$F8,$D6,$E6,$E7
 dc.b $00,$03,$EA,$E8,$FF,$CB,$00,$03,$DD,$5B,$78,$E0,$00,$03,$D0,$2A,$77,$44
 dc.b $00,$03,$C3,$52,$54,$03,$00,$03,$B6,$CF,$98,$BD,$00,$03,$AA,$9E,$FC,$86
 dc.b $00,$03,$9E,$BD,$61,$06,$00,$03,$93,$27,$CF,$D0,$00,$03,$87,$DB,$77,$E9
 dc.b $00,$03,$7C,$D5,$AB,$86,$00,$03,$72,$13,$DD,$E4,$00,$03,$67,$93,$A1,$58
 dc.b $00,$03,$5D,$52,$A5,$78,$00,$03,$53,$4E,$B5,$68,$00,$03,$49,$85,$B6,$43
 dc.b $00,$03,$3F,$F5,$A5,$A5,$00,$03,$36,$9C,$98,$47,$00,$03,$2D,$78,$B8,$B8
 dc.b $00,$03,$24,$88,$46,$2A,$00,$03,$1B,$C9,$93,$50,$00,$03,$13,$3B,$05,$58
 dc.b $00,$03,$0A,$DB,$12,$E7,$00,$03,$02,$A8,$43,$35,$00,$02,$FA,$A1,$2D,$2D
 dc.b $00,$02,$F2,$C4,$76,$9B,$00,$02,$EB,$10,$D3,$70,$00,$02,$E3,$85,$05,$05
 dc.b $00,$02,$DC,$1F,$D9,$73,$00,$02,$D4,$E0,$2A,$F0,$00,$02,$CD,$C4,$DF,$39
 dc.b $00,$02,$C6,$CC,$E7,$00,$00,$02,$BF,$F7,$3D,$64,$00,$02,$B9,$42,$E7,$79
 dc.b $00,$02,$B2,$AE,$F3,$C8,$00,$02,$AC,$3A,$79,$E0,$00,$02,$A5,$E4,$99,$EF
 dc.b $00,$02,$9F,$AC,$7C,$56,$00,$02,$99,$91,$51,$51,$00,$02,$93,$92,$50,$95
 dc.b $00,$02,$8D,$AE,$B9,$02,$00,$02,$87,$E5,$D0,$4A,$00,$02,$82,$36,$E2,$AC
 dc.b $00,$02,$7C,$A1,$42,$A6,$00,$02,$77,$24,$48,$B2,$00,$02,$71,$BF,$53,$04
 dc.b $00,$02,$6C,$71,$C5,$4B,$00,$02,$67,$3B,$08,$7A,$00,$02,$62,$1A,$8A,$8A
 dc.b $00,$02,$5D,$0F,$BE,$4A,$00,$02,$58,$1A,$1B,$27,$00,$02,$53,$39,$1D,$04
 dc.b $00,$02,$4E,$6C,$44,$02,$00,$02,$49,$B3,$14,$5C,$00,$02,$45,$0D,$16,$3A
 dc.b $00,$02,$40,$79,$D5,$8D,$00,$02,$3B,$F8,$E1,$E2,$00,$02,$37,$89,$CE,$45
 dc.b $00,$02,$33,$2C,$31,$1D,$00,$02,$2E,$DF,$A4,$09,$00,$02,$2A,$A3,$C3,$C3
 dc.b $00,$02,$26,$78,$30,$01,$00,$02,$22,$5C,$8B,$59,$00,$02,$1E,$50,$7B,$25
 dc.b $00,$02,$1A,$53,$A7,$6B,$00,$02,$16,$65,$BA,$C0,$00,$02,$12,$86,$62,$35
 dc.b $00,$02,$0E,$B5,$4D,$3E,$00,$02,$0A,$F2,$2D,$9B,$00,$02,$07,$3C,$B7,$45
 dc.b $00,$02,$03,$94,$A0,$58,$00,$01,$FF,$F9,$A1,$03,$00,$01,$FC,$6B,$73,$73
 dc.b $00,$01,$F8,$E9,$D3,$C2,$00,$01,$F5,$74,$7F,$E5,$00,$01,$F2,$0B,$37,$A0
 dc.b $00,$01,$EE,$AD,$BC,$70,$00,$01,$EB,$5B,$D1,$82,$00,$01,$E8,$15,$3B,$A2
 dc.b $00,$01,$E4,$D9,$C1,$2C,$00,$01,$E1,$A9,$2A,$01,$00,$01,$DE,$83,$3F,$7B
 dc.b $00,$01,$DB,$67,$CC,$5E,$00,$01,$D8,$56,$9C,$CE,$00,$01,$D5,$4F,$7E,$43
 dc.b $00,$01,$D2,$52,$3F,$7F,$00,$01,$CF,$5E,$B0,$83,$00,$01,$CC,$74,$A2,$85
 dc.b $00,$01,$C9,$93,$E7,$E8,$00,$01,$C6,$BC,$54,$2E,$00,$01,$C3,$ED,$BB,$F4
 dc.b $00,$01,$C1,$27,$F4,$EA,$00,$01,$BE,$6A,$D5,$C3,$00,$01,$BB,$B6,$36,$36
 dc.b $00,$01,$B9,$09,$EE,$F2,$00,$01,$B6,$65,$D9,$96,$00,$01,$B3,$C9,$D0,$AC
 dc.b $00,$01,$B1,$35,$AF,$A0,$00,$01,$AE,$A9,$52,$BC,$00,$01,$AC,$24,$97,$1D
 dc.b $00,$01,$A9,$A7,$5A,$B4,$00,$01,$A7,$31,$7C,$36,$00,$01,$A4,$C2,$DB,$21
 dc.b $00,$01,$A2,$5B,$57,$AF,$00,$01,$9F,$FA,$D2,$D2,$00,$01,$9D,$A1,$2E,$32
 dc.b $00,$01,$9B,$4E,$4C,$23,$00,$01,$99,$02,$0F,$A5,$00,$01,$96,$BC,$5C,$5C
 dc.b $00,$01,$94,$7D,$16,$8C,$00,$01,$92,$44,$23,$15,$00,$01,$90,$11,$67,$6F
 dc.b $00,$01,$8D,$E4,$C9,$A8,$00,$01,$8B,$BE,$30,$59,$00,$01,$89,$9D,$82,$AC
 dc.b $00,$01,$87,$82,$A8,$4E,$00,$01,$85,$6D,$89,$73,$00,$01,$83,$5E,$0E,$D1
 dc.b $00,$01,$81,$54,$21,$9A,$00,$01,$7F,$4F,$AB,$7B,$00,$01,$7D,$50,$96,$96
 dc.b $00,$01,$7B,$56,$CD,$84,$00,$01,$79,$62,$3B,$4D,$00,$01,$77,$72,$CB,$69
 dc.b $00,$01,$75,$88,$69,$B8,$00,$01,$73,$A3,$02,$85,$00,$01,$71,$C2,$82,$82
 dc.b $00,$01,$6F,$E6,$D6,$C2,$00,$01,$6E,$0F,$EC,$B9,$00,$01,$6C,$3D,$B2,$3B
 dc.b $00,$01,$6A,$70,$15,$78,$00,$01,$68,$A7,$04,$F8,$00,$01,$66,$E2,$6F,$9C
 dc.b $00,$01,$65,$22,$44,$9C,$00,$01,$63,$66,$73,$80,$00,$01,$61,$AE,$EC,$23
 dc.b $00,$01,$5F,$FB,$9E,$B2,$00,$01,$5E,$4C,$7B,$A4,$00,$01,$5C,$A1,$73,$BC
 dc.b $00,$01,$5A,$FA,$78,$0A,$00,$01,$59,$57,$79,$E4,$00,$01,$57,$B8,$6A,$E5
 dc.b $00,$01,$56,$1D,$3C,$F0,$00,$01,$54,$85,$E2,$29,$00,$01,$52,$F2,$4C,$F7
 dc.b $00,$01,$51,$62,$70,$01,$00,$01,$4F,$D6,$3E,$2B,$00,$01,$4E,$4D,$AA,$99
 dc.b $00,$01,$4C,$C8,$A8,$A8,$00,$01,$4B,$47,$2B,$F3,$00,$01,$49,$C9,$28,$4A
 dc.b $00,$01,$48,$4E,$91,$B9,$00,$01,$46,$D7,$5C,$81,$00,$01,$45,$63,$7D,$16
 dc.b $00,$01,$43,$F2,$E8,$25,$00,$01,$42,$85,$92,$8A,$00,$01,$41,$1B,$71,$56
 dc.b $00,$01,$3F,$B4,$79,$C9,$00,$01,$3E,$50,$A1,$53,$00,$01,$3C,$EF,$DD,$94
 dc.b $00,$01,$3B,$92,$24,$59,$00,$01,$3A,$37,$6B,$9C,$00,$01,$38,$DF,$A9,$82
 dc.b $00,$01,$37,$8A,$D4,$5C,$00,$01,$36,$38,$E2,$A5,$00,$01,$34,$E9,$CB,$02
 dc.b $00,$01,$33,$9D,$84,$3D,$00,$01,$32,$54,$05,$4A,$00,$01,$31,$0D,$45,$45
 dc.b $00,$01,$2F,$C9,$3B,$6C,$00,$01,$2E,$87,$DF,$25,$00,$01,$2D,$49,$27,$F8
 dc.b $00,$01,$2C,$0D,$0D,$93,$00,$01,$2A,$D3,$87,$C6,$00,$01,$29,$9C,$8E,$82
 dc.b $00,$01,$28,$68,$19,$D9,$00,$01,$27,$36,$22,$01,$00,$01,$26,$06,$9F,$4C
 dc.b $00,$01,$24,$D9,$8A,$2E,$00,$01,$23,$AE,$DB,$39,$00,$01,$22,$86,$8B,$1D
 dc.b $00,$01,$21,$60,$92,$A8,$00,$01,$20,$3C,$EA,$C6,$00,$01,$1F,$1B,$8C,$7D
 dc.b $00,$01,$1D,$FC,$70,$F1,$00,$01,$1C,$DF,$91,$5F,$00,$01,$1B,$C4,$E7,$22
 dc.b $00,$01,$1A,$AC,$6B,$AD,$00,$01,$19,$96,$18,$8E,$00,$01,$18,$81,$E7,$6B
 dc.b $00,$01,$17,$6F,$D2,$04,$00,$01,$16,$5F,$D2,$31,$00,$01,$15,$51,$E1,$E1
 dc.b $00,$01,$14,$45,$FB,$1C,$00,$01,$13,$3C,$18,$00,$00,$01,$12,$34,$32,$C2
 dc.b $00,$01,$11,$2E,$45,$AC,$00,$01,$10,$2A,$4B,$20,$00,$01,$0F,$28,$3D,$92
 dc.b $00,$01,$0E,$28,$17,$8F,$00,$01,$0D,$29,$D3,$B5,$00,$01,$0C,$2D,$6C,$B8
 dc.b $00,$01,$0B,$32,$DD,$60,$00,$01,$0A,$3A,$20,$86,$00,$01,$09,$43,$31,$1A
 dc.b $00,$01,$08,$4E,$0A,$1C,$00,$01,$07,$5A,$A6,$9F,$00,$01,$06,$69,$01,$C8
 dc.b $00,$01,$05,$79,$16,$CD,$00,$01,$04,$8A,$E0,$F8,$00,$01,$03,$9E,$5B,$A2
 dc.b $00,$01,$02,$B3,$82,$35,$00,$01,$01,$CA,$50,$2C,$00,$01,$00,$E2,$C1,$11
 dc.b $00,$00,$FF,$FC,$D0,$81,$00,$00,$FF,$18,$7A,$26,$00,$00,$FE,$35,$B9,$B9
 dc.b $00,$00,$FD,$54,$8B,$05,$00,$00,$FC,$74,$E9,$E1,$00,$00,$FB,$96,$D2,$33
 dc.b $00,$00,$FA,$BA,$3F,$F2,$00,$00,$F9,$DF,$2F,$21,$00,$00,$F9,$05,$9B,$D0
 dc.b $00,$00,$F8,$2D,$82,$1E,$00,$00,$F7,$56,$DE,$38,$00,$00,$F6,$81,$AC,$57
 dc.b $00,$00,$F5,$AD,$E8,$C1,$00,$00,$F4,$DB,$8F,$CA,$00,$00,$F4,$0A,$9D,$D1
 dc.b $00,$00,$F3,$3B,$0F,$42,$00,$00,$F2,$6C,$E0,$96,$00,$00,$F1,$A0,$0E,$50
 dc.b $00,$00,$F0,$D4,$95,$00,$00,$00,$F0,$0A,$71,$43,$00,$00,$EF,$41,$9F,$BD
 dc.b $00,$00,$EE,$7A,$1D,$23,$00,$00,$ED,$B3,$E6,$2F,$00,$00,$EC,$EE,$F7,$AA
 dc.b $00,$00,$EC,$2B,$4E,$67,$00,$00,$EB,$68,$E7,$41,$00,$00,$EA,$A7,$BF,$21
 dc.b $00,$00,$E9,$E7,$D2,$F7,$00,$00,$E9,$29,$1F,$BF,$00,$00,$E8,$6B,$A2,$7D
 dc.b $00,$00,$E7,$AF,$58,$41,$00,$00,$E6,$F4,$3E,$22,$00,$00,$E6,$3A,$51,$42
 dc.b $00,$00,$E5,$81,$8E,$CC,$00,$00,$E4,$C9,$F3,$F4,$00,$00,$E4,$13,$7D,$F5
 dc.b $00,$00,$E3,$5E,$2A,$17,$00,$00,$E2,$A9,$F5,$A6,$00,$00,$E1,$F6,$DD,$FA
 dc.b $00,$00,$E1,$44,$E0,$72,$00,$00,$E0,$93,$FA,$75,$00,$00,$DF,$E4,$29,$72
 dc.b $00,$00,$DF,$35,$6A,$E1,$00,$00,$DE,$87,$BC,$42,$00,$00,$DD,$DB,$1B,$1B
 dc.b $00,$00,$DD,$2F,$84,$FB,$00,$00,$DC,$84,$F7,$79,$00,$00,$DB,$DB,$70,$31
 dc.b $00,$00,$DB,$32,$EC,$CB,$00,$00,$DA,$8B,$6A,$F0,$00,$00,$D9,$E4,$E8,$56
 dc.b $00,$00,$D9,$3F,$62,$B5,$00,$00,$D8,$9A,$D7,$D0,$00,$00,$D7,$F7,$45,$6E
 dc.b $00,$00,$D7,$54,$A9,$5E,$00,$00,$D6,$B3,$01,$75,$00,$00,$D6,$12,$4B,$8E
 dc.b $00,$00,$D5,$72,$85,$8D,$00,$00,$D4,$D3,$AD,$5A,$00,$00,$D4,$35,$C0,$E2
 dc.b $00,$00,$D3,$98,$BE,$1B,$00,$00,$D2,$FC,$A3,$00,$00,$00,$D2,$61,$6D,$90
 dc.b $00,$00,$D1,$C7,$1B,$D4,$00,$00,$D1,$2D,$AB,$D7,$00,$00,$D0,$95,$1B,$AC
 dc.b $00,$00,$CF,$FD,$69,$69,$00,$00,$CF,$66,$93,$2C,$00,$00,$CE,$D0,$97,$19
 dc.b $00,$00,$CE,$3B,$73,$56,$00,$00,$CD,$A7,$26,$11,$00,$00,$CD,$13,$AD,$7E
 dc.b $00,$00,$CC,$81,$07,$D2,$00,$00,$CB,$EF,$33,$4D,$00,$00,$CB,$5E,$2E,$2E
 dc.b $00,$00,$CA,$CD,$F6,$BD,$00,$00,$CA,$3E,$8B,$46,$00,$00,$C9,$AF,$EA,$18
 dc.b $00,$00,$C9,$22,$11,$8A,$00,$00,$C8,$94,$FF,$F5,$00,$00,$C8,$08,$B3,$B7
 dc.b $00,$00,$C7,$7D,$2B,$35,$00,$00,$C6,$F2,$64,$D4,$00,$00,$C6,$68,$5F,$01
 dc.b $00,$00,$C5,$DF,$18,$2C,$00,$00,$C5,$56,$8E,$CB,$00,$00,$C4,$CE,$C1,$56
 dc.b $00,$00,$C4,$47,$AE,$49,$00,$00,$C3,$C1,$54,$27,$00,$00,$C3,$3B,$B1,$74
 dc.b $00,$00,$C2,$B6,$C4,$B9,$00,$00,$C2,$32,$8C,$85,$00,$00,$C1,$AF,$07,$68
 dc.b $00,$00,$C1,$2C,$33,$F8,$00,$00,$C0,$AA,$10,$CD,$00,$00,$C0,$28,$9C,$84
 dc.b $00,$00,$BF,$A7,$D5,$BD,$00,$00,$BF,$27,$BB,$1D,$00,$00,$BE,$A8,$4B,$4B
 dc.b $00,$00,$BE,$29,$84,$F2,$00,$00,$BD,$AB,$66,$C2,$00,$00,$BD,$2D,$EF,$6C
 dc.b $00,$00,$BC,$B1,$1D,$A6,$00,$00,$BC,$34,$F0,$2A,$00,$00,$BB,$B9,$65,$B4
 dc.b $00,$00,$BB,$3E,$7D,$03,$00,$00,$BA,$C4,$34,$DC,$00,$00,$BA,$4A,$8C,$03
 dc.b $00,$00,$B9,$D1,$81,$42,$00,$00,$B9,$59,$13,$67,$00,$00,$B8,$E1,$41,$41
 dc.b $00,$00,$B8,$6A,$09,$A2,$00,$00,$B7,$F3,$6B,$61,$00,$00,$B7,$7D,$65,$55
 dc.b $00,$00,$B7,$07,$F6,$5C,$00,$00,$B6,$93,$1D,$54,$00,$00,$B6,$1E,$D9,$1D
 dc.b $00,$00,$B5,$AB,$28,$9E,$00,$00,$B5,$38,$0A,$BC,$00,$00,$B4,$C5,$7E,$61
 dc.b $00,$00,$B4,$53,$82,$7C,$00,$00,$B3,$E2,$15,$FA,$00,$00,$B3,$71,$37,$CE
 dc.b $00,$00,$B3,$00,$E6,$ED,$00,$00,$B2,$91,$22,$4E,$00,$00,$B2,$21,$E8,$EA
 dc.b $00,$00,$B1,$B3,$39,$C0,$00,$00,$B1,$45,$13,$CC,$00,$00,$B0,$D7,$76,$11
 dc.b $00,$00,$B0,$6A,$5F,$94,$00,$00,$AF,$FD,$CF,$59,$00,$00,$AF,$91,$C4,$6A
 dc.b $00,$00,$AF,$26,$3D,$D2,$00,$00,$AE,$BB,$3A,$9E,$00,$00,$AE,$50,$B9,$DE
 dc.b $00,$00,$AD,$E6,$BA,$A4,$00,$00,$AD,$7D,$3C,$05,$00,$00,$AD,$14,$3D,$17
 dc.b $00,$00,$AC,$AB,$BC,$F2,$00,$00,$AC,$43,$BA,$B1,$00,$00,$AB,$DC,$35,$72
 dc.b $00,$00,$AB,$75,$2C,$54,$00,$00,$AB,$0E,$9E,$78,$00,$00,$AA,$A8,$8B,$01
 dc.b $00,$00,$AA,$42,$F1,$14,$00,$00,$A9,$DD,$CF,$DA,$00,$00,$A9,$79,$26,$7B
 dc.b $00,$00,$A9,$14,$F4,$24,$00,$00,$A8,$B1,$38,$00,$00,$00,$A8,$4D,$F1,$40
 dc.b $00,$00,$A7,$EB,$1F,$15,$00,$00,$A7,$88,$C0,$B2,$00,$00,$A7,$26,$D5,$4C
 dc.b $00,$00,$A6,$C5,$5C,$1A,$00,$00,$A6,$64,$54,$54,$00,$00,$A6,$03,$BD,$35
 dc.b $00,$00,$A5,$A3,$95,$F9,$00,$00,$A5,$43,$DD,$DF,$00,$00,$A4,$E4,$94,$25
 dc.b $00,$00,$A4,$85,$B8,$0E,$00,$00,$A4,$27,$48,$DC,$00,$00,$A3,$C9,$45,$D6
 dc.b $00,$00,$A3,$6B,$AE,$40,$00,$00,$A3,$0E,$81,$64,$00,$00,$A2,$B1,$BE,$8B
 dc.b $00,$00,$A2,$55,$65,$01,$00,$00,$A1,$F9,$74,$12,$00,$00,$A1,$9D,$EB,$0E
 dc.b $00,$00,$A1,$42,$C9,$45,$00,$00,$A0,$E8,$0E,$08,$00,$00,$A0,$8D,$B8,$AB
 dc.b $00,$00,$A0,$33,$C8,$82,$00,$00,$9F,$DA,$3C,$E4,$00,$00,$9F,$81,$15,$29
 dc.b $00,$00,$9F,$28,$50,$A9,$00,$00,$9E,$CF,$EE,$C0,$00,$00,$9E,$77,$EE,$CA
 dc.b $00,$00,$9E,$20,$50,$23,$00,$00,$9D,$C9,$12,$2C,$00,$00,$9D,$72,$34,$44
 dc.b $00,$00,$9D,$1B,$B5,$CE,$00,$00,$9C,$C5,$96,$2B,$00,$00,$9C,$6F,$D4,$C1
 dc.b $00,$00,$9C,$1A,$70,$F5,$00,$00,$9B,$C5,$6A,$2E,$00,$00,$9B,$70,$BF,$D5
 dc.b $00,$00,$9B,$1C,$71,$52,$00,$00,$9A,$C8,$7E,$12,$00,$00,$9A,$74,$E5,$81
 dc.b $00,$00,$9A,$21,$A7,$0A,$00,$00,$99,$CE,$C2,$1E,$00,$00,$99,$7C,$36,$2C
 dc.b $00,$00,$99,$2A,$02,$A5,$00,$00,$98,$D8,$26,$FB,$00,$00,$98,$86,$A2,$A2
 dc.b $00,$00,$98,$35,$75,$0E,$00,$00,$97,$E4,$9D,$B6,$00,$00,$97,$94,$1C,$0F
 dc.b $00,$00,$97,$43,$EF,$92,$00,$00,$96,$F4,$17,$B8,$00,$00,$96,$A4,$93,$FC
 dc.b $00,$00,$96,$55,$63,$D8,$00,$00,$96,$06,$86,$C9,$00,$00,$95,$B7,$FC,$4E
 dc.b $00,$00,$95,$69,$C3,$E3,$00,$00,$95,$1B,$DD,$09,$00,$00,$94,$CE,$47,$41
 dc.b $00,$00,$94,$81,$02,$0B,$00,$00,$94,$34,$0C,$EC,$00,$00,$93,$E7,$67,$67
 dc.b $00,$00,$93,$9B,$11,$00,$00,$00,$93,$4F,$09,$3D,$00,$00,$93,$03,$4F,$A6
 dc.b $00,$00,$92,$B7,$E3,$C0,$00,$00,$92,$6C,$C5,$17,$00,$00,$92,$21,$F3,$32
 dc.b $00,$00,$91,$D7,$6D,$9C,$00,$00,$91,$8D,$33,$E1,$00,$00,$91,$43,$45,$8E
 dc.b $00,$00,$90,$F9,$A2,$30,$00,$00,$90,$B0,$49,$54,$00,$00,$90,$67,$3A,$8A
 dc.b $00,$00,$90,$1E,$75,$63,$00,$00,$8F,$D5,$F9,$6E,$00,$00,$8F,$8D,$C6,$3E
 dc.b $00,$00,$8F,$45,$DB,$66,$00,$00,$8E,$FE,$38,$78,$00,$00,$8E,$B6,$DD,$09
 dc.b $00,$00,$8E,$6F,$C8,$AF,$00,$00,$8E,$28,$FB,$00,$00,$00,$8D,$E2,$73,$91
 dc.b $00,$00,$8D,$9C,$31,$FB,$00,$00,$8D,$56,$35,$D6,$00,$00,$8D,$10,$7E,$BC
 dc.b $00,$00,$8C,$CB,$0C,$47,$00,$00,$8C,$85,$DE,$11,$00,$00,$8C,$40,$F3,$B5
 dc.b $00,$00,$8B,$FC,$4C,$D1,$00,$00,$8B,$B7,$E9,$02,$00,$00,$8B,$73,$C7,$E5
 dc.b $00,$00,$8B,$2F,$E9,$18,$00,$00,$8A,$EC,$4C,$3C,$00,$00,$8A,$A8,$F0,$F0
 dc.b $00,$00,$8A,$65,$D6,$D6,$00,$00,$8A,$22,$FD,$8E,$00,$00,$89,$E0,$64,$BB
 dc.b $00,$00,$89,$9E,$0C,$00,$00,$00,$89,$5B,$F3,$00,$00,$00,$89,$1A,$19,$61
 dc.b $00,$00,$88,$D8,$7E,$C6,$00,$00,$88,$97,$22,$D6,$00,$00,$88,$56,$05,$37
 dc.b $00,$00,$88,$15,$25,$90,$00,$00,$87,$D4,$83,$88,$00,$00,$87,$94,$1E,$C9
 dc.b $00,$00,$87,$53,$F6,$FB,$00,$00,$87,$14,$0B,$C7,$00,$00,$86,$D4,$5C,$D9
 dc.b $00,$00,$86,$94,$E9,$DA,$00,$00,$86,$55,$B2,$77,$00,$00,$86,$16,$B6,$5C
 dc.b $00,$00,$85,$D7,$F5,$35,$00,$00,$85,$99,$6E,$B0,$00,$00,$85,$5B,$22,$7A
 dc.b $00,$00,$85,$1D,$10,$43,$00,$00,$84,$DF,$37,$B9,$00,$00,$84,$A1,$98,$8D
 dc.b $00,$00,$84,$64,$32,$6E,$00,$00,$84,$27,$05,$0E,$00,$00,$83,$EA,$10,$1D
 dc.b $00,$00,$83,$AD,$53,$4F,$00,$00,$83,$70,$CE,$55,$00,$00,$83,$34,$80,$E4
 dc.b $00,$00,$82,$F8,$6A,$AD,$00,$00,$82,$BC,$8B,$66,$00,$00,$82,$80,$E2,$C4
 dc.b $00,$00,$82,$45,$70,$7C,$00,$00,$82,$0A,$34,$43,$00,$00,$81,$CF,$2D,$D1
 dc.b $00,$00,$81,$94,$5C,$DB,$00,$00,$81,$59,$C1,$1A,$00,$00,$81,$1F,$5A,$45
 dc.b $00,$00,$80,$E5,$28,$16,$00,$00,$80,$AB,$2A,$43,$00,$00,$80,$71,$60,$88
 dc.b $00,$00,$80,$37,$CA,$9F,$00,$00,$7F,$FE,$68,$40,$00,$00,$7F,$C5,$39,$29
 dc.b $00,$00,$7F,$8C,$3D,$13,$00,$00,$7F,$53,$73,$BA,$00,$00,$7F,$1A,$DC,$DC
 dc.b $00,$00,$7E,$E2,$78,$35,$00,$00,$7E,$AA,$45,$82,$00,$00,$7E,$72,$44,$81
 dc.b $00,$00,$7E,$3A,$74,$F0,$00,$00,$7E,$02,$D6,$8E,$00,$00,$7D,$CB,$69,$19
 dc.b $00,$00,$7D,$94,$2C,$52,$00,$00,$7D,$5D,$1F,$F9,$00,$00,$7D,$26,$43,$CD
 dc.b $00,$00,$7C,$EF,$97,$90,$00,$00,$7C,$B9,$1B,$03,$00,$00,$7C,$82,$CD,$E8
 dc.b $00,$00,$7C,$4C,$B0,$00,$00,$00,$7C,$16,$C1,$0F,$00,$00,$7B,$E1,$00,$D7
 dc.b $00,$00,$7B,$AB,$6F,$1C,$00,$00,$7B,$76,$0B,$A1,$00,$00,$7B,$40,$D6,$2B
 dc.b $00,$00,$7B,$0B,$CE,$7E,$00,$00,$7A,$D6,$F4,$60,$00,$00,$7A,$A2,$47,$96
 dc.b $00,$00,$7A,$6D,$C7,$E5,$00,$00,$7A,$39,$75,$13,$00,$00,$7A,$05,$4E,$E8
 dc.b $00,$00,$79,$D1,$55,$2A,$00,$00,$79,$9D,$87,$A1,$00,$00,$79,$69,$E6,$13
 dc.b $00,$00,$79,$36,$70,$4B,$00,$00,$79,$03,$26,$0E,$00,$00,$78,$D0,$07,$28
 dc.b $00,$00,$78,$9D,$13,$60,$00,$00,$78,$6A,$4A,$80,$00,$00,$78,$37,$AC,$52
 dc.b $00,$00,$78,$05,$38,$A1,$00,$00,$77,$D2,$EF,$37,$00,$00,$77,$A0,$CF,$DE
 dc.b $00,$00,$77,$6E,$DA,$63,$00,$00,$77,$3D,$0E,$91,$00,$00,$77,$0B,$6C,$34
 dc.b $00,$00,$76,$D9,$F3,$17,$00,$00,$76,$A8,$A3,$09,$00,$00,$76,$77,$7B,$D5
 dc.b $00,$00,$76,$46,$7D,$49,$00,$00,$76,$15,$A7,$33,$00,$00,$75,$E4,$F9,$61
 dc.b $00,$00,$75,$B4,$73,$A0,$00,$00,$75,$84,$15,$C1,$00,$00,$75,$53,$DF,$90
 dc.b $00,$00,$75,$23,$D0,$DF,$00,$00,$74,$F3,$E9,$7B,$00,$00,$74,$C4,$29,$36
 dc.b $00,$00,$74,$94,$8F,$DF,$00,$00,$74,$65,$1D,$47,$00,$00,$74,$35,$D1,$3E
 dc.b $00,$00,$74,$06,$AB,$96,$00,$00,$73,$D7,$AC,$20,$00,$00,$73,$A8,$D2,$AE
 dc.b $00,$00,$73,$7A,$1F,$11,$00,$00,$73,$4B,$91,$1C,$00,$00,$73,$1D,$28,$A1
 dc.b $00,$00,$72,$EE,$E5,$73,$00,$00,$72,$C0,$C7,$66,$00,$00,$72,$92,$CE,$4C
 dc.b $00,$00,$72,$64,$F9,$FA,$00,$00,$72,$37,$4A,$42,$00,$00,$72,$09,$BE,$FA
 dc.b $00,$00,$71,$DC,$57,$F6,$00,$00,$71,$AF,$15,$0B,$00,$00,$71,$81,$F6,$0D
 dc.b $00,$00,$71,$54,$FA,$D3,$00,$00,$71,$28,$23,$31,$00,$00,$70,$FB,$6E,$FD
 dc.b $00,$00,$70,$CE,$DE,$0D,$00,$00,$70,$A2,$70,$39,$00,$00,$70,$76,$25,$55
 dc.b $00,$00,$70,$49,$FD,$3A,$00,$00,$70,$1D,$F7,$BE,$00,$00,$6F,$F2,$14,$B9
 dc.b $00,$00,$6F,$C6,$54,$01,$00,$00,$6F,$9A,$B5,$70,$00,$00,$6F,$6F,$38,$DD
 dc.b $00,$00,$6F,$43,$DE,$21,$00,$00,$6F,$18,$A5,$13,$00,$00,$6E,$ED,$8D,$8D
 dc.b $00,$00,$6E,$C2,$97,$68,$00,$00,$6E,$97,$C2,$7D,$00,$00,$6E,$6D,$0E,$A6
 dc.b $00,$00,$6E,$42,$7B,$BC,$00,$00,$6E,$18,$09,$99,$00,$00,$6D,$ED,$B8,$18
 dc.b $00,$00,$6D,$C3,$87,$13,$00,$00,$6D,$99,$76,$65,$00,$00,$6D,$6F,$85,$E8
 dc.b $00,$00,$6D,$45,$B5,$78,$00,$00,$6D,$1C,$04,$EF,$00,$00,$6C,$F2,$74,$2B
 dc.b $00,$00,$6C,$C9,$03,$05,$00,$00,$6C,$9F,$B1,$5A,$00,$00,$6C,$76,$7F,$07
 dc.b $00,$00,$6C,$4D,$6B,$E8,$00,$00,$6C,$24,$77,$D9,$00,$00,$6B,$FB,$A2,$B7
 dc.b $00,$00,$6B,$D2,$EC,$5F,$00,$00,$6B,$AA,$54,$AF,$00,$00,$6B,$81,$DB,$83
 dc.b $00,$00,$6B,$59,$80,$BA,$00,$00,$6B,$31,$44,$31,$00,$00,$6B,$09,$25,$C7
 dc.b $00,$00,$6A,$E1,$25,$59,$00,$00,$6A,$B9,$42,$C6,$00,$00,$6A,$91,$7D,$ED
 dc.b $00,$00,$6A,$69,$D6,$AD,$00,$00,$6A,$42,$4C,$E3,$00,$00,$6A,$1A,$E0,$71
 dc.b $00,$00,$69,$F3,$91,$34,$00,$00,$69,$CC,$5F,$0D,$00,$00,$69,$A5,$49,$DC
 dc.b $00,$00,$69,$7E,$51,$80,$00,$00,$69,$57,$75,$D9,$00,$00,$69,$30,$B6,$C8
 dc.b $00,$00,$69,$0A,$14,$2D,$00,$00,$68,$E3,$8D,$EA,$00,$00,$68,$BD,$23,$DE
 dc.b $00,$00,$68,$96,$D5,$EB,$00,$00,$68,$70,$A3,$F3,$00,$00,$68,$4A,$8D,$D6
 dc.b $00,$00,$68,$24,$93,$75,$00,$00,$67,$FE,$B4,$B4,$00,$00,$67,$D8,$F1,$74
 dc.b $00,$00,$67,$B3,$49,$96,$00,$00,$67,$8D,$BC,$FD,$00,$00,$67,$68,$4B,$8C
 dc.b $00,$00,$67,$42,$F5,$25,$00,$00,$67,$1D,$B9,$AB,$00,$00,$66,$F8,$99,$00
 dc.b $00,$00,$66,$D3,$93,$08,$00,$00,$66,$AE,$A7,$A7,$00,$00,$66,$89,$D6,$BF
 dc.b $00,$00,$66,$65,$20,$33,$00,$00,$66,$40,$83,$E9,$00,$00,$66,$1C,$01,$C3
 dc.b $00,$00,$65,$F7,$99,$A6,$00,$00,$65,$D3,$4B,$76,$00,$00,$65,$AF,$17,$17
 dc.b $00,$00,$65,$8A,$FC,$6D,$00,$00,$65,$66,$FB,$5E,$00,$00,$65,$43,$13,$CE
 dc.b $00,$00,$65,$1F,$45,$A3,$00,$00,$64,$FB,$90,$C0,$00,$00,$64,$D7,$F5,$0C
 dc.b $00,$00,$64,$B4,$72,$6C,$00,$00,$64,$91,$08,$C5,$00,$00,$64,$6D,$B7,$FD
 dc.b $00,$00,$64,$4A,$7F,$FA,$00,$00,$64,$27,$60,$A2,$00,$00,$64,$04,$59,$DB
 dc.b $00,$00,$63,$E1,$6B,$8C,$00,$00,$63,$BE,$95,$9A,$00,$00,$63,$9B,$D7,$EC
 dc.b $00,$00,$63,$79,$32,$6A,$00,$00,$63,$56,$A4,$F9,$00,$00,$63,$34,$2F,$80
 dc.b $00,$00,$63,$11,$D1,$E8,$00,$00,$62,$EF,$8C,$16,$00,$00,$62,$CD,$5D,$F3
 dc.b $00,$00,$62,$AB,$47,$65,$00,$00,$62,$89,$48,$55,$00,$00,$62,$67,$60,$AB
 dc.b $00,$00,$62,$45,$90,$4D,$00,$00,$62,$23,$D7,$24,$00,$00,$62,$02,$35,$19
 dc.b $00,$00,$61,$E0,$AA,$13,$00,$00,$61,$BF,$35,$FB,$00,$00,$61,$9D,$D8,$BA
 dc.b $00,$00,$61,$7C,$92,$37,$00,$00,$61,$5B,$62,$5C,$00,$00,$61,$3A,$49,$13
 dc.b $00,$00,$61,$19,$46,$42,$00,$00,$60,$F8,$59,$D5,$00,$00,$60,$D7,$83,$B4
 dc.b $00,$00,$60,$B6,$C3,$C8,$00,$00,$60,$96,$19,$FC,$00,$00,$60,$75,$86,$38
 dc.b $00,$00,$60,$55,$08,$66,$00,$00,$60,$34,$A0,$71,$00,$00,$60,$14,$4E,$42
 dc.b $00,$00,$5F,$F4,$11,$C3,$00,$00,$5F,$D3,$EA,$DE,$00,$00,$5F,$B3,$D9,$7F
 dc.b $00,$00,$5F,$93,$DD,$8E,$00,$00,$5F,$73,$F6,$F7,$00,$00,$5F,$54,$25,$A5
 dc.b $00,$00,$5F,$34,$69,$82,$00,$00,$5F,$14,$C2,$79,$00,$00,$5E,$F5,$30,$75
 dc.b $00,$00,$5E,$D5,$B3,$61,$00,$00,$5E,$B6,$4B,$28,$00,$00,$5E,$96,$F7,$B6
 dc.b $00,$00,$5E,$77,$B8,$F6,$00,$00,$5E,$58,$8E,$D3,$00,$00,$5E,$39,$79,$39
 dc.b $00,$00,$5E,$1A,$78,$15,$00,$00,$5D,$FB,$8B,$51,$00,$00,$5D,$DC,$B2,$DA
 dc.b $00,$00,$5D,$BD,$EE,$9B,$00,$00,$5D,$9F,$3E,$81,$00,$00,$5D,$80,$A2,$79
 dc.b $00,$00,$5D,$62,$1A,$6E,$00,$00,$5D,$43,$A6,$4C,$00,$00,$5D,$25,$46,$01
 dc.b $00,$00,$5D,$06,$F9,$79,$00,$00,$5C,$E8,$C0,$A1,$00,$00,$5C,$CA,$9B,$65
 dc.b $00,$00,$5C,$AC,$89,$B3,$00,$00,$5C,$8E,$8B,$78,$00,$00,$5C,$70,$A0,$A0
 dc.b $00,$00,$5C,$52,$C9,$19,$00,$00,$5C,$35,$04,$D1,$00,$00,$5C,$17,$53,$B4
 dc.b $00,$00,$5B,$F9,$B5,$B0,$00,$00,$5B,$DC,$2A,$B3,$00,$00,$5B,$BE,$B2,$AA
 dc.b $00,$00,$5B,$A1,$4D,$84,$00,$00,$5B,$83,$FB,$2E,$00,$00,$5B,$66,$BB,$96
 dc.b $00,$00,$5B,$49,$8E,$AA,$00,$00,$5B,$2C,$74,$58,$00,$00,$5B,$0F,$6C,$8E
 dc.b $00,$00,$5A,$F2,$77,$3C,$00,$00,$5A,$D5,$94,$4F,$00,$00,$5A,$B8,$C3,$B5
 dc.b $00,$00,$5A,$9C,$05,$5E,$00,$00,$5A,$7F,$59,$37,$00,$00,$5A,$62,$BF,$30
 dc.b $00,$00,$5A,$46,$37,$38,$00,$00,$5A,$29,$C1,$3E,$00,$00,$5A,$0D,$5D,$2F
 dc.b $00,$00,$59,$F1,$0A,$FD,$00,$00,$59,$D4,$CA,$95,$00,$00,$59,$B8,$9B,$E7
 dc.b $00,$00,$59,$9C,$7E,$E2,$00,$00,$59,$80,$73,$76,$00,$00,$59,$64,$79,$92
 dc.b $00,$00,$59,$48,$91,$27,$00,$00,$59,$2C,$BA,$22,$00,$00,$59,$10,$F4,$75
 dc.b $00,$00,$58,$F5,$40,$0F,$00,$00,$58,$D9,$9C,$E0,$00,$00,$58,$BE,$0A,$D7
 dc.b $00,$00,$58,$A2,$89,$E6,$00,$00,$58,$87,$19,$FB,$00,$00,$58,$6B,$BB,$08
 dc.b $00,$00,$58,$50,$6C,$FD,$00,$00,$58,$35,$2F,$CA,$00,$00,$58,$1A,$03,$5E
 dc.b $00,$00,$57,$FE,$E7,$AC,$00,$00,$57,$E3,$DC,$A3,$00,$00,$57,$C8,$E2,$35
 dc.b $00,$00,$57,$AD,$F8,$51,$00,$00,$57,$93,$1E,$E9,$00,$00,$57,$78,$55,$ED
 dc.b $00,$00,$57,$5D,$9D,$4F,$00,$00,$57,$42,$F4,$FF,$00,$00,$57,$28,$5C,$EF
 dc.b $00,$00,$57,$0D,$D5,$0F,$00,$00,$56,$F3,$5D,$52,$00,$00,$56,$D8,$F5,$A8
 dc.b $00,$00,$56,$BE,$9E,$02,$00,$00,$56,$A4,$56,$53,$00,$00,$56,$8A,$1E,$8B
 dc.b $00,$00,$56,$6F,$F6,$9C,$00,$00,$56,$55,$DE,$79,$00,$00,$56,$3B,$D6,$11
 dc.b $00,$00,$56,$21,$DD,$58,$00,$00,$56,$07,$F4,$40,$00,$00,$55,$EE,$1A,$B9
 dc.b $00,$00,$55,$D4,$50,$B6,$00,$00,$55,$BA,$96,$2A,$00,$00,$55,$A0,$EB,$05
 dc.b $00,$00,$55,$87,$4F,$3C,$00,$00,$55,$6D,$C2,$BE,$00,$00,$55,$54,$45,$80
 dc.b $00,$00,$55,$3A,$D7,$73,$00,$00,$55,$21,$78,$8A,$00,$00,$55,$08,$28,$B7
 dc.b $00,$00,$54,$EE,$E7,$ED,$00,$00,$54,$D5,$B6,$1E,$00,$00,$54,$BC,$93,$3D
 dc.b $00,$00,$54,$A3,$7F,$3E,$00,$00,$54,$8A,$7A,$12,$00,$00,$54,$71,$83,$AC
 dc.b $00,$00,$54,$58,$9C,$00,$00,$00,$54,$3F,$C3,$00,$00,$00,$54,$26,$F8,$A0
 dc.b $00,$00,$54,$0E,$3C,$D2,$00,$00,$53,$F5,$8F,$8A,$00,$00,$53,$DC,$F0,$BB
 dc.b $00,$00,$53,$C4,$60,$59,$00,$00,$53,$AB,$DE,$56,$00,$00,$53,$93,$6A,$A6
 dc.b $00,$00,$53,$7B,$05,$3C,$00,$00,$53,$62,$AE,$0D,$00,$00,$53,$4A,$65,$0B
 dc.b $00,$00,$53,$32,$2A,$2A,$00,$00,$53,$19,$FD,$5E,$00,$00,$53,$01,$DE,$9A
 dc.b $00,$00,$52,$E9,$CD,$D3,$00,$00,$52,$D1,$CA,$FC,$00,$00,$52,$B9,$D6,$0A
 dc.b $00,$00,$52,$A1,$EE,$EF,$00,$00,$52,$8A,$15,$A1,$00,$00,$52,$72,$4A,$12
 dc.b $00,$00,$52,$5A,$8C,$38,$00,$00,$52,$42,$DC,$07,$00,$00,$52,$2B,$39,$72
 dc.b $00,$00,$52,$13,$A4,$6E,$00,$00,$51,$FC,$1C,$EF,$00,$00,$51,$E4,$A2,$EB
 dc.b $00,$00,$51,$CD,$36,$54,$00,$00,$51,$B5,$D7,$20,$00,$00,$51,$9E,$85,$43
 dc.b $00,$00,$51,$87,$40,$B2,$00,$00,$51,$70,$09,$61,$00,$00,$51,$58,$DF,$45
 dc.b $00,$00,$51,$41,$C2,$53,$00,$00,$51,$2A,$B2,$80,$00,$00,$51,$13,$AF,$C0
 dc.b $00,$00,$50,$FC,$BA,$09,$00,$00,$50,$E5,$D1,$4F,$00,$00,$50,$CE,$F5,$87
 dc.b $00,$00,$50,$B8,$26,$A6,$00,$00,$50,$A1,$64,$A2,$00,$00,$50,$8A,$AF,$70
 dc.b $00,$00,$50,$74,$07,$04,$00,$00,$50,$5D,$6B,$54,$00,$00,$50,$46,$DC,$55
 dc.b $00,$00,$50,$30,$59,$FD,$00,$00,$50,$19,$E4,$41,$00,$00,$50,$03,$7B,$16
 dc.b $00,$00,$4F,$ED,$1E,$72,$00,$00,$4F,$D6,$CE,$4A,$00,$00,$4F,$C0,$8A,$94
 dc.b $00,$00,$4F,$AA,$53,$46,$00,$00,$4F,$94,$28,$54,$00,$00,$4F,$7E,$09,$B6
 dc.b $00,$00,$4F,$67,$F7,$60,$00,$00,$4F,$51,$F1,$48,$00,$00,$4F,$3B,$F7,$65
 dc.b $00,$00,$4F,$26,$09,$AB,$00,$00,$4F,$10,$28,$11,$00,$00,$4E,$FA,$52,$8E
 dc.b $00,$00,$4E,$E4,$89,$16,$00,$00,$4E,$CE,$CB,$A0,$00,$00,$4E,$B9,$1A,$22
 dc.b $00,$00,$4E,$A3,$74,$92,$00,$00,$4E,$8D,$DA,$E7,$00,$00,$4E,$78,$4D,$15
 dc.b $00,$00,$4E,$62,$CB,$15,$00,$00,$4E,$4D,$54,$DC,$00,$00,$4E,$37,$EA,$60
 dc.b $00,$00,$4E,$22,$8B,$98,$00,$00,$4E,$0D,$38,$7A,$00,$00,$4D,$F7,$F0,$FD
 dc.b $00,$00,$4D,$E2,$B5,$17,$00,$00,$4D,$CD,$84,$BE,$00,$00,$4D,$B8,$5F,$EA
 dc.b $00,$00,$4D,$A3,$46,$91,$00,$00,$4D,$8E,$38,$A9,$00,$00,$4D,$79,$36,$29
 dc.b $00,$00,$4D,$64,$3F,$09,$00,$00,$4D,$4F,$53,$3E,$00,$00,$4D,$3A,$72,$C0
 dc.b $00,$00,$4D,$25,$9D,$85,$00,$00,$4D,$10,$D3,$85,$00,$00,$4C,$FC,$14,$B6
 dc.b $00,$00,$4C,$E7,$61,$0F,$00,$00,$4C,$D2,$B8,$87,$00,$00,$4C,$BE,$1B,$16
 dc.b $00,$00,$4C,$A9,$88,$B2,$00,$00,$4C,$95,$01,$52,$00,$00,$4C,$80,$84,$EE
 dc.b $00,$00,$4C,$6C,$13,$7D,$00,$00,$4C,$57,$AC,$F6,$00,$00,$4C,$43,$51,$51
 dc.b $00,$00,$4C,$2F,$00,$84,$00,$00,$4C,$1A,$BA,$87,$00,$00,$4C,$06,$7F,$51
 dc.b $00,$00,$4B,$F2,$4E,$DB,$00,$00,$4B,$DE,$29,$1A,$00,$00,$4B,$CA,$0E,$07
 dc.b $00,$00,$4B,$B5,$FD,$9A,$00,$00,$4B,$A1,$F7,$C9,$00,$00,$4B,$8D,$FC,$8C
 dc.b $00,$00,$4B,$7A,$0B,$DC,$00,$00,$4B,$66,$25,$AF,$00,$00,$4B,$52,$49,$FE
 dc.b $00,$00,$4B,$3E,$78,$BF,$00,$00,$4B,$2A,$B1,$EC,$00,$00,$4B,$16,$F5,$7B
 dc.b $00,$00,$4B,$03,$43,$64,$00,$00,$4A,$EF,$9B,$A0,$00,$00,$4A,$DB,$FE,$27
 dc.b $00,$00,$4A,$C8,$6A,$EF,$00,$00,$4A,$B4,$E1,$F1,$00,$00,$4A,$A1,$63,$26
 dc.b $00,$00,$4A,$8D,$EE,$84,$00,$00,$4A,$7A,$84,$05,$00,$00,$4A,$67,$23,$A0
 dc.b $00,$00,$4A,$53,$CD,$4D,$00,$00,$4A,$40,$81,$05,$00,$00,$4A,$2D,$3E,$C0
 dc.b $00,$00,$4A,$1A,$06,$76,$00,$00,$4A,$06,$D8,$1F,$00,$00,$49,$F3,$B3,$B3
 dc.b $00,$00,$49,$E0,$99,$2B,$00,$00,$49,$CD,$88,$80,$00,$00,$49,$BA,$81,$A9
 dc.b $00,$00,$49,$A7,$84,$9E,$00,$00,$49,$94,$91,$5A,$00,$00,$49,$81,$A7,$D3
 dc.b $00,$00,$49,$6E,$C8,$02,$00,$00,$49,$5B,$F1,$E0,$00,$00,$49,$49,$25,$65
 dc.b $00,$00,$49,$36,$62,$8B,$00,$00,$49,$23,$A9,$49,$00,$00,$49,$10,$F9,$99
 dc.b $00,$00,$48,$FE,$53,$72,$00,$00,$48,$EB,$B6,$CE,$00,$00,$48,$D9,$23,$A5
 dc.b $00,$00,$48,$C6,$99,$F0,$00,$00,$48,$B4,$19,$A9,$00,$00,$48,$A1,$A2,$C7
 dc.b $00,$00,$48,$8F,$35,$44,$00,$00,$48,$7C,$D1,$18,$00,$00,$48,$6A,$76,$3C
 dc.b $00,$00,$48,$58,$24,$AA,$00,$00,$48,$45,$DC,$5A,$00,$00,$48,$33,$9D,$45
 dc.b $00,$00,$48,$21,$67,$64,$00,$00,$48,$0F,$3A,$B1,$00,$00,$47,$FD,$17,$24
 dc.b $00,$00,$47,$EA,$FC,$B7,$00,$00,$47,$D8,$EB,$62,$00,$00,$47,$C6,$E3,$1F
 dc.b $00,$00,$47,$B4,$E3,$E7,$00,$00,$47,$A2,$ED,$B3,$00,$00,$47,$91,$00,$7C
 dc.b $00,$00,$47,$7F,$1C,$3C,$00,$00,$47,$6D,$40,$EC,$00,$00,$47,$5B,$6E,$84
 dc.b $00,$00,$47,$49,$A5,$00,$00,$00,$47,$37,$E4,$57,$00,$00,$47,$26,$2C,$84
 dc.b $00,$00,$47,$14,$7D,$80,$00,$00,$47,$02,$D7,$43,$00,$00,$46,$F1,$39,$C8
 dc.b $00,$00,$46,$DF,$A5,$08,$00,$00,$46,$CE,$18,$FD,$00,$00,$46,$BC,$95,$A0
 dc.b $00,$00,$46,$AB,$1A,$EB,$00,$00,$46,$99,$A8,$D7,$00,$00,$46,$88,$3F,$5E
 dc.b $00,$00,$46,$76,$DE,$79,$00,$00,$46,$65,$86,$23,$00,$00,$46,$54,$36,$55
 dc.b $00,$00,$46,$42,$EF,$08,$00,$00,$46,$31,$B0,$37,$00,$00,$46,$20,$79,$DA
 dc.b $00,$00,$46,$0F,$4B,$ED,$00,$00,$45,$FE,$26,$68,$00,$00,$45,$ED,$09,$46
 dc.b $00,$00,$45,$DB,$F4,$81,$00,$00,$45,$CA,$E8,$11,$00,$00,$45,$B9,$E3,$F2
 dc.b $00,$00,$45,$A8,$E8,$1D,$00,$00,$45,$97,$F4,$8C,$00,$00,$45,$87,$09,$39
 dc.b $00,$00,$45,$76,$26,$1E,$00,$00,$45,$65,$4B,$35,$00,$00,$45,$54,$78,$78
 dc.b $00,$00,$45,$43,$AD,$E1,$00,$00,$45,$32,$EB,$6B,$00,$00,$45,$22,$31,$0E
 dc.b $00,$00,$45,$11,$7E,$C7,$00,$00,$45,$00,$D4,$8E,$00,$00,$44,$F0,$32,$5D
 dc.b $00,$00,$44,$DF,$98,$30,$00,$00,$44,$CF,$06,$00,$00,$00,$44,$BE,$7B,$C7
 dc.b $00,$00,$44,$AD,$F9,$80,$00,$00,$44,$9D,$7F,$25,$00,$00,$44,$8D,$0C,$B0
 dc.b $00,$00,$44,$7C,$A2,$1C,$00,$00,$44,$6C,$3F,$63,$00,$00,$44,$5B,$E4,$7F
 dc.b $00,$00,$44,$4B,$91,$6B,$00,$00,$44,$3B,$46,$21,$00,$00,$44,$2B,$02,$9B
 dc.b $00,$00,$44,$1A,$C6,$D5,$00,$00,$44,$0A,$92,$C8,$00,$00,$43,$FA,$66,$6F
 dc.b $00,$00,$43,$EA,$41,$C4,$00,$00,$43,$DA,$24,$C2,$00,$00,$43,$CA,$0F,$64
 dc.b $00,$00,$43,$BA,$01,$A4,$00,$00,$43,$A9,$FB,$7D,$00,$00,$43,$99,$FC,$E9
 dc.b $00,$00,$43,$8A,$05,$E3,$00,$00,$43,$7A,$16,$66,$00,$00,$43,$6A,$2E,$6C
 dc.b $00,$00,$43,$5A,$4D,$F0,$00,$00,$43,$4A,$74,$ED,$00,$00,$43,$3A,$A3,$5D
 dc.b $00,$00,$43,$2A,$D9,$3B,$00,$00,$43,$1B,$16,$83,$00,$00,$43,$0B,$5B,$2E
 dc.b $00,$00,$42,$FB,$A7,$37,$00,$00,$42,$EB,$FA,$9A,$00,$00,$42,$DC,$55,$51
 dc.b $00,$00,$42,$CC,$B7,$58,$00,$00,$42,$BD,$20,$A8,$00,$00,$42,$AD,$91,$3D
 dc.b $00,$00,$42,$9E,$09,$12,$00,$00,$42,$8E,$88,$21,$00,$00,$42,$7F,$0E,$67
 dc.b $00,$00,$42,$6F,$9B,$DC,$00,$00,$42,$60,$30,$7E,$00,$00,$42,$50,$CC,$46
 dc.b $00,$00,$42,$41,$6F,$30,$00,$00,$42,$32,$19,$37,$00,$00,$42,$22,$CA,$55
 dc.b $00,$00,$42,$13,$82,$87,$00,$00,$42,$04,$41,$C6,$00,$00,$41,$F5,$08,$0E
 dc.b $00,$00,$41,$E5,$D5,$5B,$00,$00,$41,$D6,$A9,$A7,$00,$00,$41,$C7,$84,$EE
 dc.b $00,$00,$41,$B8,$67,$2A,$00,$00,$41,$A9,$50,$58,$00,$00,$41,$9A,$40,$72
 dc.b $00,$00,$41,$8B,$37,$73,$00,$00,$41,$7C,$35,$56,$00,$00,$41,$6D,$3A,$18
 dc.b $00,$00,$41,$5E,$45,$B3,$00,$00,$41,$4F,$58,$22,$00,$00,$41,$40,$71,$62
 dc.b $00,$00,$41,$31,$91,$6C,$00,$00,$41,$22,$B8,$3E,$00,$00,$41,$13,$E5,$D1
 dc.b $00,$00,$41,$05,$1A,$21,$00,$00,$40,$F6,$55,$2B,$00,$00,$40,$E7,$96,$E8
 dc.b $00,$00,$40,$D8,$DF,$55,$00,$00,$40,$CA,$2E,$6D,$00,$00,$40,$BB,$84,$2C
 dc.b $00,$00,$40,$AC,$E0,$8D,$00,$00,$40,$9E,$43,$8B,$00,$00,$40,$8F,$AD,$22
 dc.b $00,$00,$40,$81,$1D,$4E,$00,$00,$40,$72,$94,$0B,$00,$00,$40,$64,$11,$52
 dc.b $00,$00,$40,$55,$95,$21,$00,$00,$40,$47,$1F,$73,$00,$00,$40,$38,$B0,$44
 dc.b $00,$00,$40,$2A,$47,$8F,$00,$00,$40,$1B,$E5,$4F,$00,$00,$40,$0D,$89,$81
 dc.b $00,$00,$3F,$FF,$34,$20,$00,$00,$3F,$F0,$E5,$28,$00,$00,$3F,$E2,$9C,$94
 dc.b $00,$00,$3F,$D4,$5A,$61,$00,$00,$3F,$C6,$1E,$89,$00,$00,$3F,$B7,$E9,$09
 dc.b $00,$00,$3F,$A9,$B9,$DD,$00,$00,$3F,$9B,$91,$00,$00,$00,$3F,$8D,$6E,$6E
 dc.b $00,$00,$3F,$7F,$52,$23,$00,$00,$3F,$71,$3C,$1A,$00,$00,$3F,$63,$2C,$50
 dc.b $00,$00,$3F,$55,$22,$C1,$00,$00,$3F,$47,$1F,$67,$00,$00,$3F,$39,$22,$40
 dc.b $00,$00,$3F,$2B,$2B,$47,$00,$00,$3F,$1D,$3A,$78,$00,$00,$3F,$0F,$4F,$CE
 dc.b $00,$00,$3F,$01,$6B,$47,$00,$00,$3E,$F3,$8C,$DD,$00,$00,$3E,$E5,$B4,$8C
 dc.b $00,$00,$3E,$D7,$E2,$52,$00,$00,$3E,$CA,$16,$29,$00,$00,$3E,$BC,$50,$0E
 dc.b $00,$00,$3E,$AE,$8F,$FC,$00,$00,$3E,$A0,$D5,$F0,$00,$00,$3E,$93,$21,$E6
 dc.b $00,$00,$3E,$85,$73,$DA,$00,$00,$3E,$77,$CB,$C8,$00,$00,$3E,$6A,$29,$AB
 dc.b $00,$00,$3E,$5C,$8D,$81,$00,$00,$3E,$4E,$F7,$45,$00,$00,$3E,$41,$66,$F4
 dc.b $00,$00,$3E,$33,$DC,$88,$00,$00,$3E,$26,$58,$00,$00,$00,$3E,$18,$D9,$56
 dc.b $00,$00,$3E,$0B,$60,$87,$00,$00,$3D,$FD,$ED,$8F,$00,$00,$3D,$F0,$80,$6B
 dc.b $00,$00,$3D,$E3,$19,$16,$00,$00,$3D,$D5,$B7,$8E,$00,$00,$3D,$C8,$5B,$CD
 dc.b $00,$00,$3D,$BB,$05,$D0,$00,$00,$3D,$AD,$B5,$94,$00,$00,$3D,$A0,$6B,$15
 dc.b $00,$00,$3D,$93,$26,$4F,$00,$00,$3D,$85,$E7,$3F,$00,$00,$3D,$78,$AD,$E0
 dc.b $00,$00,$3D,$6B,$7A,$30,$00,$00,$3D,$5E,$4C,$2A,$00,$00,$3D,$51,$23,$CB
 dc.b $00,$00,$3D,$44,$01,$0E,$00,$00,$3D,$36,$E3,$F2,$00,$00,$3D,$29,$CC,$71
 dc.b $00,$00,$3D,$1C,$BA,$89,$00,$00,$3D,$0F,$AE,$36,$00,$00,$3D,$02,$A7,$74
 dc.b $00,$00,$3C,$F5,$A6,$3F,$00,$00,$3C,$E8,$AA,$95,$00,$00,$3C,$DB,$B4,$71
 dc.b $00,$00,$3C,$CE,$C3,$D0,$00,$00,$3C,$C1,$D8,$AF,$00,$00,$3C,$B4,$F3,$09
 dc.b $00,$00,$3C,$A8,$12,$DD,$00,$00,$3C,$9B,$38,$25,$00,$00,$3C,$8E,$62,$DF
 dc.b $00,$00,$3C,$81,$93,$07,$00,$00,$3C,$74,$C8,$9A,$00,$00,$3C,$68,$03,$94
 dc.b $00,$00,$3C,$5B,$43,$F1,$00,$00,$3C,$4E,$89,$B0,$00,$00,$3C,$41,$D4,$CB
 dc.b $00,$00,$3C,$35,$25,$40,$00,$00,$3C,$28,$7B,$0B,$00,$00,$3C,$1B,$D6,$29
 dc.b $00,$00,$3C,$0F,$36,$96,$00,$00,$3C,$02,$9C,$50,$00,$00,$3B,$F6,$07,$53
 dc.b $00,$00,$3B,$E9,$77,$9B,$00,$00,$3B,$DC,$ED,$26,$00,$00,$3B,$D0,$67,$EF
 dc.b $00,$00,$3B,$C3,$E7,$F4,$00,$00,$3B,$B7,$6D,$31,$00,$00,$3B,$AA,$F7,$A4
 dc.b $00,$00,$3B,$9E,$87,$48,$00,$00,$3B,$92,$1C,$1B,$00,$00,$3B,$85,$B6,$1A
 dc.b $00,$00,$3B,$79,$55,$40,$00,$00,$3B,$6C,$F9,$8B,$00,$00,$3B,$60,$A2,$F8
 dc.b $00,$00,$3B,$54,$51,$84,$00,$00,$3B,$48,$05,$2B,$00,$00,$3B,$3B,$BD,$EA
 dc.b $00,$00,$3B,$2F,$7B,$BE,$00,$00,$3B,$23,$3E,$A4,$00,$00,$3B,$17,$06,$99
 dc.b $00,$00,$3B,$0A,$D3,$99,$00,$00,$3A,$FE,$A5,$A2,$00,$00,$3A,$F2,$7C,$B0
 dc.b $00,$00,$3A,$E6,$58,$C0,$00,$00,$3A,$DA,$39,$D0,$00,$00,$3A,$CE,$1F,$DC
 dc.b $00,$00,$3A,$C2,$0A,$E0,$00,$00,$3A,$B5,$FA,$DB,$00,$00,$3A,$A9,$EF,$C8
 dc.b $00,$00,$3A,$9D,$E9,$A5,$00,$00,$3A,$91,$E8,$6F,$00,$00,$3A,$85,$EC,$23
 dc.b $00,$00,$3A,$79,$F4,$BD,$00,$00,$3A,$6E,$02,$3C,$00,$00,$3A,$62,$14,$9B
 dc.b $00,$00,$3A,$56,$2B,$D8,$00,$00,$3A,$4A,$47,$EF,$00,$00,$3A,$3E,$68,$DF
 dc.b $00,$00,$3A,$32,$8E,$A3,$00,$00,$3A,$26,$B9,$3A,$00,$00,$3A,$1A,$E8,$9F
 dc.b $00,$00,$3A,$0F,$1C,$D0,$00,$00,$3A,$03,$55,$CB,$00,$00,$39,$F7,$93,$8C
 dc.b $00,$00,$39,$EB,$D6,$10,$00,$00,$39,$E0,$1D,$54,$00,$00,$39,$D4,$69,$57
 dc.b $00,$00,$39,$C8,$BA,$14,$00,$00,$39,$BD,$0F,$88,$00,$00,$39,$B1,$69,$B2
 dc.b $00,$00,$39,$A5,$C8,$8E,$00,$00,$39,$9A,$2C,$19,$00,$00,$39,$8E,$94,$50
 dc.b $00,$00,$39,$83,$01,$31,$00,$00,$39,$77,$72,$B9,$00,$00,$39,$6B,$E8,$E5
 dc.b $00,$00,$39,$60,$63,$B3,$00,$00,$39,$54,$E3,$1E,$00,$00,$39,$49,$67,$26
 dc.b $00,$00,$39,$3D,$EF,$C6,$00,$00,$39,$32,$7C,$FD



;**** DATA segment ****
	.data


spistruct:
	dc.b	'SPI!'
	dc.w	$0100
	dc.w	$0100
	ds.l	1
	dc.l	$0000001	; Supported functions/modes
	dc.l	0			; Flags
	dc.l	0			; res1
	dc.l	copyrt1
	dc.l	copyrt2
	dc.l	freqstr
	dc.l	freqstr
	dc.l	freqstr
	dc.l	mod_play
	dc.l	mod_stop
	dc.l	mod_setup
	dc.l	mod_pause
	dc.l	mod_forward
	dc.l	mod_backward
	dc.l	sam_play


copyrt1:
	dc.b	"DMA MOD Player",0
copyrt2:
	dc.b	"(C) by Martin Griffiths",0

freqstr:
	dc.b	" 25 kHz",0
	even


n_note  equ 0			; W
n_cmd	equ 2			; W
n_cmdlo equ 3			; B
n_start equ 4			; L
n_length equ 8			; W
n_loopstart equ 10		; L
n_replen equ 14			; W
n_period equ 16			; W
n_finetune equ 18		; B
n_volume equ 19			; B
n_dmabit equ 20			; W
n_toneportdirec equ 22	; B
n_toneportspeed equ 23	; B
n_wantedperiod equ 24	; W
n_vibratocmd equ 26		; B
n_vibratopos equ 27		; B
n_tremolocmd equ 28		; B
n_tremolopos equ 29		; B
n_wavecontrol equ 30	; B
n_glissfunk equ 31		; B
n_sampleoffset equ 32	; B
n_pattpos equ 33		; B
n_loopcount equ 34		; B
n_funkoffset equ 35		; B
n_wavestart equ 36		; L
n_reallength equ 40		; W
mt_chan1temp: dc.l 0,0,0,0,0,$010000,0,0,0,0,0
mt_chan2temp: dc.l 0,0,0,0,0,$020000,0,0,0,0,0
mt_chan3temp: dc.l 0,0,0,0,0,$040000,0,0,0,0,0
mt_chan4temp: dc.l 0,0,0,0,0,$080000,0,0,0,0,0

mt_SampleStarts:
	dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0
	dc.l 0,0,0,0,0,0,0,0,0,0,0,0,0,0,0

mt_SongDataPtr:	dc.l 0
mt_speed:		dc.b 6
mt_counter:		dc.b 0
mt_SongPos:		dc.b 0
mt_PBreakPos:	dc.b 0
mt_PosJumpFlag:	dc.b 0
mt_PBreakFlag:	dc.b 0
mt_LowMask:		dc.b 0
mt_PattDelTime:	dc.b 0
mt_PattDelTime2: dc.b 0
mt_Enable:		dc.b 0
mt_PatternPos:	dc.w 0
mt_DMACONtemp:	dc.w 0


OldTempo: dc.w 125
RealTempo: dc.w 125
tempo_cont_flg: dc.b -1
	even

music_on: dc.w 0		; music on flag

stebuf_ptrs: dc.l stebuf1,stebuf2



;**** BSS segment ****
	.bss

mod_addr: ds.l 1		; Address of module

fxsam1addr:
	ds.l	1
fxsam1len:
	ds.l	1
fxsam2addr:
	ds.l	1
fxsam2len:
	ds.l	1

old_stuff: ds.b 11
	even

ch1s:	ds.b sam_strctsiz
ch2s:	ds.b sam_strctsiz	; shadow channel regs
ch3s:	ds.b sam_strctsiz
ch4s:	ds.b sam_strctsiz


Voice1Set: ds.b Vstrctsiz
Voice2Set: ds.b Vstrctsiz	; voice data (setup from 'paula' data)
Voice3Set: ds.b Vstrctsiz
Voice4Set: ds.b Vstrctsiz


shadow_dmacon: ds.w 1
shadow_filter: ds.w 1

voltab_ptr: ds.l 1			; ptr to volume table

bufadd: ds.l 1				; To switch between left and right output channel

	ds.l 8					; (in case!!)
nulsamp: ds.l 8				; nul sample

vols: ds.l 64
	ds.l 16640/4

stebuf1: ds.w bufsize		; buffers must be this big to handle
stebuf2: ds.w bufsize		; downto tempo 32

lpvc1_1: ds.l 1
lpvc1_2: ds.l 1
lpvc1_3: ds.l 1
lpvc1_4: ds.w 1
lpvc2_1: ds.l 1
lpvc2_2: ds.l 1
lpvc2_3: ds.l 1
lpvc2_4: ds.w 1

ciaemtab:
	ds.w	256

;*** End of File ***
