start:		move.l	#noisemod_x,d0
		move.l	#$50000,d1
		cmp.l 	d0,d1			; not logical!
		bhi.s	go_on_make_my_day

		pea	sorry(pc)
		move.w	#9,-(sp)
		trap	#1
		addq.l	#6,sp
		
		move.w	#7,-(sp)
		trap	#1
		addq.l	#2,sp

		clr.w	-(sp)				; terminate!
		trap	#1		

sorry:
dc.b "Insufficient lower memory for D.W.II!",0
even

go_on_make_my_day:

		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		
low:		move.w #0,-(sp)
		move.l #-1,-(sp)
		move.l #-1,-(sp)
		move.w #5,-(sp)
		trap #14
		lea 12(sp),sp

		move.l	#0,$466.w
vsync:		cmp.l	#0,$466.w
		beq.s	vsync

		lea	$ffff8240.w,a0
		moveq	#$f,d7
black:		move.w	#0,(a0)+
		dbf	d7,black
		move.w	#$2700,sr	

relo:
		lea	noisemodend_x,a0
		lea	$50000+178108,a1
		lea	$50000,a2
relocate_nmod:	move.w	-(a0),-(a1)
		cmp.l	a1,a2
		bne.s	relocate_nmod

		bsr.l	init_dma

dma_addr:	move.b	dma_st+1,$ffff8903.w
		move.b	dma_st+2,$ffff8905.w
		move.b	dma_st+3,$ffff8907.w

		move.b	dma_end+1,$ffff890f.w
		move.b	dma_end+2,$ffff8911.w
		move.b	dma_end+3,$ffff8913.w

		move.b 	#%10000000,$ffff8921.w	; 6 1/2 kHz mono
		move.b 	#0,$ffff8901.w
		move.b 	#1,$ffff8901.w		; on shit!

		move.l 	$70.w,oldvbl
		move.l	#vbl_i,$70.w
		move.w	#$2300,sr	

vsync_2:	tst.b	vbl_flg
		beq.s	vsync_2
		lea	intropic+4,a0		; digilogo pal
		movem.l	(a0),d0-d7
		movem.l	d0-d7,$ffff8240.w

loop_w:		tst.b	exit_flg
		beq.s	loop_w
		bra.L	back_i		

vbl_i:		st 	vbl_flg
		move.l	d0,-(sp)

		move.l	#intropic+128,d0
		move.b	d0,$ffff8209.w
		lsr.w	#8,d0
		move.b	d0,$ffff8207.w
		swap	d0
		move.b	d0,$ffff8205.w

		;tst.b	dmasndflg
		;bne.s	shit
		cmp.b	#0,$ffff8901.w
		bne.s	shit
		st	exit_flg
		bra.s	shitend

shit:		not.b	dmasndflg
		beq.s	shit_again
		moveq	#0,d0
		move.b	$ffff8909.w,d0
		lsl.w	#8,d0
		move.b	$ffff890b.w,d0
		lsl.l	#8,d0
		move.b	$ffff890d.w,d0
		add.l	#156,d0			; magic snd!
		move.b	d0,dma0d
		lsr.w	#8,d0
		move.b	d0,dma0b
		swap	d0
		move.b	d0,dma09
		bra.s	shitend

shit_again:	move.b	dma09,$ffff8903.w
		move.b	dma0b,$ffff8905.w
		move.b	dma0d,$ffff8907.w

		move.b	dma_end+1,$ffff890f.w
		move.b	dma_end+2,$ffff8911.w
		move.b	dma_end+3,$ffff8913.w

		move.b 	#0,$ffff8901.w
		move.b 	#1,$ffff8901.w		; on shit!

shitend:	move.l	(sp)+,d0
		rte

 
back_i:		move.w	#$2700,sr
blitt_init:	move.b 	#2,$ffff8a3a.w			; hop
		move.b 	#3,$ffff8a3b.w			; op
		move.w 	#$ffff,$ffff8a2a.w		; endmsk2
		move.w 	#$ffff,$ffff8a2c.w		; endmsk3
		move.w 	#8,$ffff8a2e.w			; des x inc

i_init:		move.l 	$120.w,oldhbl
		move.b 	$fffffa07.w,oldmfp07	;iera	(timer a & b) 
		move.b 	$fffffa09.w,oldmfp09	;ierb   (timer c & d)
		move.b 	$fffffa13.w,oldmfp13	;imra
		
		move.b #0,$fffffa09.w		;ierb    c & d obliterate
		;bclr 	#5,$fffffa09.w
		;bclr 	#4,$fffffa09.w

		move.l 	#vbl,$70.w
		move.l 	#hbl,$120.w
		bset   	#0,$fffffa07.w		;b enable
		bset   	#0,$fffffa13.w		;b mask
		move.b 	#0,$fffffa1b.w		;tbcr
		move.b 	#255,$fffffa21.w	;tbdr
		move.b 	#8,$fffffa1b.w		;even count mode
		bsr.l 	init_music
		move.w	#$2300,sr

		sf	vbl_flg
key:		tst.b 	vbl_flg
		beq.s 	key
		cmp.b	#$3b,$fffffc02.w	; f1
		beq.s	osc_1
		cmp.b	#$3c,$fffffc02.w	; f2
		beq.s	osc_2
		cmp.b	#$44,$fffffc02.w	; f10
		beq.s	pause
		cmp.b	#$43,$fffffc02.w	; f9
		beq.L	nopause
		cmp.b 	#$61,$fffffc02.w	;keyb. ACIA data reg
		beq.l 	back
		cmp.b	#$14,$fffffc02.w
		beq.s	st_hide
		tst.b	hide_flg
		beq.s	no
		cmp.b	#$11,$fffffc02.w
		beq.s	hidescreen

		sf 	hide_flg
no:		sf 	vbl_flg
		bra.s 	key
st_hide:	st	hide_flg
		sf	vbl_flg
		bra.s	key

osc_1:		move.w	#0,osc_size
		move.w	#320-260,center
		sf	vbl_flg
		bra.s	key

osc_2:		move.w	#1,osc_size
		move.w	#320-130,center
		sf	vbl_flg
		bra.L	key

pause:		st	pause_flg
		sf	vbl_flg
		bra.l	key

nopause:	sf	pause_flg
		sf	vbl_flg
		bra.l	key

hidescreen:	sf	vbl_flg
vsync_hide:	tst.b	vbl_flg
		beq.s	vsync_hide
		move.l	#vbl_hide,$70

		sf	vbl_flg
key_2:		tst.b	vbl_flg
		beq.s	key_2
		cmp.b	#185,$fffffc02.w
		beq.s	back_vbl
		bra.s	key_2
back_vbl:	move.l	#vbl,$70
		sf	vbl_flg
		bra.l	key
		
;--------------------------------------------------------------------

vbl:		st 	vbl_flg
		;move.w	#$300,$ffff8240.w
		movem.l d0-d7/a0-a6,-(sp)

		move.l	#icetop+128,d0
		move.b	d0,$ffff8209.w
		lsr.w	#8,d0
		move.b	d0,$ffff8207.w
		swap	d0
		move.b	d0,$ffff8205.w

		lea	icetop+4,a0
		movem.l	(a0)+,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.b 	#0,$fffffa1b.w		
		move.b 	#1,$fffffa21.w		
		move.b 	#8,$fffffa1b.w		

;--------------------------------------------------------------------
		lea	sinstart,a0
		add.w	sinpoint,a0
		cmp.l	#sinend,a0
		bne.s	no_restart
		move.w	#0,sinpoint

no_restart:	lea	icetop+128+160,a1
		lea	hscroll_data,a5
		lea	screenp_data,a6

		moveq	#32-1,d7
lines:		moveq	#0,d0
		moveq	#0,d1

		move.b	(a0)+,d0	; get 1st x value!
		sub.b	#42,d0		; <------ center
		cmp.b 	#$f,d0     
		bhi.s	xfix_i	 	; higher than 15 ?
		move.l	a1,d1
		bra.s	go_on

xfix_i:		ror.l	#4,d0		; /16	
		lsl.w	#3,d0		; *8
		move.w	d0,d1
		add.l	a1,d1		; new screen address
		rol.l	#4,d0		; 4 bits = $f
		addq.b	#1,d0		

go_on:		move.b	d0,(a5)+
		move.l	d1,(a6)+
		add.w	#160,a1
		dbf 	d7,lines

		lea	hscroll_data,a5
		lea	screenp_data,a6

		tst.b	pause_flg
		bne.s	suck
		addq.w	#1,sinpoint

;--------------------------------------------------------------------

		bsr.L 	b_tscrl
		bsr.L	b_globe
			
		bsr.l	oscillo

		addq.w	#1,fade_wait
		cmp.w	#960,fade_wait
		blo.s	suck

		lea	fadest,a0
		add.w	fadepek,a0
		addq.w	#2,fadepek
		cmp.l	#fadeend,a0
		beq.s	endfade
		move.w	(a0),$ffff8248.w
		bra.s	suck
		
endfade:	move.w	#0,fadepek
		move.w	#0,fade_wait
		
suck:	
		;move.w	#$020,$ffff8240.w

		bsr.l	trackmuzak

		;move.w	#$0,$ffff8240.w
		movem.l (sp)+,d0-d7/a0-a6
		rte

;--------------------------------------------------------------------

vbl_hide:	st 	vbl_flg
		movem.l	d0-d7,-(sp)
		move.l	#nicepic+128,d0
		move.b	d0,$ffff8209.w
		lsr.w	#8,d0
		move.b	d0,$ffff8207.w
		swap	d0
		move.b	d0,$ffff8205.w

		movem.l	nicepic+4,d0-d7
		movem.l	d0-d7,$ffff8240.w

		move.b 	#0,$fffffa1b.w		; hbl off

		bsr.l trackmuzak

		movem.l	(sp)+,d0-d7
		rte


;--------------------------------------------------------------------
; HBL interrupts->	Warning!  Data & Address registers not saved!

hbl:		move.b	3(a6),$ffff8209.w		
		move.b	2(a6),$ffff8207.w		
		move.b	1(a6),$ffff8205.w		
		move.b	(a5)+,$ffff8264.w		; bits
	
		addq.l	#4,a6

ready:		addq.b	#1,cntlines
		cmp.b	#33,cntlines
		bne.s 	notyet

		move.b	#0,cntlines
		move.l	#hbl2,$120
		move.b 	#0,$fffffa1b.w		
		move.b 	#200-33-32,$fffffa21.w		
		move.b 	#8,$fffffa1b.w		
		move.w	#$fff,$ffff8242.w
		move.w	#$0,$ffff8248.w		; change col HERE!!!
		move.w	#$fff,$ffff824a.w
		bclr 	#0,$fffffa0f.w		; isra 
		rte

notyet:		move.b 	#0,$fffffa1b.w		
		move.b 	#1,$fffffa21.w		
		move.b 	#8,$fffffa1b.w		
		bclr 	#0,$fffffa0f.w		; isra
		rte

;--------------------------------------------------------------------

hbl2:		move.w	#$115,$ffff8242.w	; 2 planes font pal
		move.w	#$116,$ffff8244.w
		move.w	#$117,$ffff8246.w
		move.w	#$f70,$ffff8248.w
		move.w	#$f70,$ffff824a.w
		move.w	#$f70,$ffff824c.w
		move.w	#$f70,$ffff824e.w

		move.l	#hbl_bordt,$120
		move.b 	#0,$fffffa1b.w		
		move.b 	#32,$fffffa21.w		
		move.b 	#8,$fffffa1b.w		
		bclr 	#0,$fffffa0f.w		; isra
		rte


;--------------------------------------------------------------------

hbl_bordt:	move.b	#$fc,$ffff820a.w
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		nop
		move.b	#$fe,$ffff820a.w

		move.l	#hbl,$120
		move.b 	#0,$fffffa1b.w		
		move.b 	#255,$fffffa21.w		
		move.b 	#8,$fffffa1b.w		
		bclr 	#0,$fffffa0f.w		; isra
		rte

; -----------------------------------------------------	
; ---- dma stereo xy oscilloscope                  ---- 	
; -----------------------------------------------------	

oscillo:	movem.l d0-d3/d5-d7/a0-a4,-(sp)

		tst.b	clrflg
		beq.s	noclr
		bsr.s	pixels_clear

noclr:
		move.b	$ffff8909.w,d0
		lsl.w	#8,d0
		move.b	$ffff890b.w,d0
		lsl.l	#8,d0
		move.b	$ffff890d.w,d0
		move.l	d0,a1			; dmasnd address
	
		bsr.s	pixels_out

		st	clrflg
		movem.l (sp)+,d0-d3/d5-d7/a0-a4
		rts
;-----------------------------------------------------	Subroutines

pixels_clear:
		lea	clraddrs(pc),a0

noext:		moveq	#0,d0
		move.w	#200/4-1,d7		; even
clrline:	move.l	(a0)+,a1
		move.w	d0,(a1)
		move.l	(a0)+,a1
		move.w	d0,(a1)
		move.l	(a0)+,a1
		move.w	d0,(a1)
		move.l	(a0)+,a1
		move.w	d0,(a1)
		dbf	d7,clrline
		rts

;----------------------------------------------	

pixels_out:
		lea	clraddrs(pc),a2

new:	
		moveq	#127,d3			; pixel
		move.w	osc_size,d4		; <<<
		move.w	center,d5
		move.l 	#oscillomem,d6
		
		lea	yadd_tab(pc),a4
		move.w	#200/2-1,d7

oscillo_l:
		moveq	#0,d0		; x
		moveq	#0,d1		; y
		move.l	a4,a3
		
		move.b	128(a1),d0	; x
		sub.b	d3,d0		; 128
		lsr.b	d4,d0

		move.b	(a1)+,d1	; y
		sub.b	d3,d1		; 128
		lsr.b	#1,d1		

		bsr.s	xyput
		move.l	a0,(a2)+	; screen address

oscillo_r:	moveq	#0,d0		; x
		moveq	#0,d1		; y
		move.l	a4,a3
		
		move.b	128(a1),d0	; x
		sub.b	d3,d0		; 128
		lsr.b	d4,d0
		add.w	d5,d0		; 320-130

		move.b	(a1)+,d1	; y
		sub.b	d3,d1		; 128
		lsr.b	#1,d1		

		bsr.s	xyput
		move.l	a0,(a2)+	; screen address

		dbf	d7,oscillo_l
		rts

;------------------------------------------------------
; converts x & y values to scrmem and plot on position!
; d0 = xvalue	d1 = yvalue

xyput:		move.l 	d6,a0		; screenmem
		move.w	#$8000,d2	; $8000 

; y convert algorithm

		lsl.w	#1,d1
		add.w 	(a3,d1.w),a0	; add to screen

; x convert algorithm

		cmp.w 	#$f,d0     
		bhi.l	xcon	 	; higher than 15 ?
		lsr.w 	d0,d2		; rotate

		or.w	d2,(a0)		; pixel out
		rts

xcon:		ror.l	#4,d0		; /16	
		lsl.w	#3,d0		; *8
		add.w	d0,a0		; add to screen
		rol.l	#4,d0		; 4 bits = $f
		and.w	#$f,d0
		lsr.w 	d0,d2		; rotate

		or.w	d2,(a0)		; pixel out
		rts	

; -----------------------------------------------------	
; ---- dma-tracker replay init & route             ---- 	
; -----------------------------------------------------	
init_dma:	move.w 	#$7ff,$ffff8924.w	; to mw mask
		lea	mw_set,a0		; microwire settings
		lea	$fffff8922.w,a1		; mw data		
	
		move.w	(a1),d7			; save previous
mw_loop:	move.w 	(a0)+,(a1)
mw_wait:	cmp.w	(a1),d7
		bne.s	mw_wait
		cmp.l	#mw_setend,a0
		bne.s	mw_loop
		rts

init_music:	move.l 	frames+4,d0		; startframe
		bsr.s 	set_frame2

		move.b 	#$01,$ffff8921.w	; 25 kHz stereo.
		rts

set_frame:
		move.l 	frames,d0		; startframe
set_frame2:	move.l 	d0,d1
		add.l 	#500,d1

		move.b 	d0,$ffff8907.w
		lsr.l 	#8,d0
		move.b 	d0,$ffff8905.w
		lsr.l 	#8,d0
		move.b 	d0,$ffff8903.w

		move.b 	d1,$ffff8913.w
		lsr.l 	#8,d1
		move.b 	d1,$ffff8911.w
		lsr.l 	#8,d1
		move.b 	d1,$ffff890f.w
		rts

change_frame:
		move.l 	frames,d0
		move.l 	frames+4,d1
		exg 	d0,d1
		move.l 	d0,frames
		move.l 	d1,frames+4
		rts


; -----------------------------------------------------	

trackmuzak:	movem.l d0/d1/a3,-(sp)
		move.l 	frames,a3
		jsr 	noisemod+$5128		;$5124
		bsr.L 	set_frame
		move.b 	#0,$ffff8901.w
		move.b 	#1,$ffff8901.w
		bsr.L 	change_frame
		movem.l (sp)+,d0/d1/a3
		rts

; -----------------------------------------------------	
; -----------------------------------------------------	
;   Blitter-textscroll v1.0 by Tobias Nilsson "Techwave"
;       2 bitplanes 32*32 ~ 20 SCANLINES

b_tscrl:	move.w 	#8,$ffff8a20.w			; src x inc
		move.w 	#$0000,$ffff8a28.w		; endmsk1
		move.b  #%00001100,$ffff8a3d.w		; skew

		move.l 	#scl_addr,d0		; src
		move.l 	d0,d1
		subq.l 	#8,d1			; des

;	1st
		move.l	d0,$ffff8a24.w		; src addr
		move.l	d1,$ffff8a32.w		; des addr
		move.w	#641,$ffff8a36.w	; x cnt   (20*32+1)
		move.w	#1,$ffff8a38.w		; y cnt
		move.b #%11000000,$ffff8a3c.w	; busy!

;	2nd
		addq.l	#2,d0
		addq.l	#2,d1
		move.l	d0,$ffff8a24.w		; src addr
		move.l	d1,$ffff8a32.w		; des addr
		move.w	#641,$ffff8a36.w	; x cnt   (20*32+1)
		move.w	#1,$ffff8a38.w		; y cnt
		move.b #%11000000,$ffff8a3c.w	; busy!

;---------------------------------------------	

charout:	move.w 	#$000f,$ffff8a28.w		; endmsk1
		move.w 	#160,$ffff8a22.w		; src y inc
		move.w 	#160,$ffff8a30.w		; des y inc
		move.b 	toskew(pc),$ffff8a3d.w

		move.l 	#fontimg,d0		; src
		add.w 	offset(pc),d0

		move.l 	#scl_addr,d1		; des
		add.w 	xoutadd(pc),d1

;	1st

		move.l	d0,$ffff8a24.w		; src addr
		move.l	d1,$ffff8a32.w		; des addr
		move.w	#1,$ffff8a36.w		; x cnt 
		move.w	#32,$ffff8a38.w		; y cnt
		move.b #%11000000,$ffff8a3c.w	; busy!
;	2nd	
		addq.l	#2,d0
		addq.l	#2,d1
		move.l	d0,$ffff8a24.w		; src addr
		move.l	d1,$ffff8a32.w		; des addr
		move.w	#1,$ffff8a36.w		; x cnt 
		move.w	#32,$ffff8a38.w		; y cnt
		move.b #%11000000,$ffff8a3c.w	; busy!


; reading text...

		tst.b 	spaceflg
		beq.s 	notspa
		sf 	spaceflg
		bra.s 	read

notspa:		cmp.b	#0,toskew
		bne.s 	notend

		move.b 	#12,toskew
		tst.b 	second
		bne.s 	readyt
		addq.w 	#8,offset
		st 	second
		rts
readyt:		sf 	second
		st 	spaceflg
		move.w 	#0,offset
		rts

notend:		subq.b 	#4,toskew
		rts


read:		moveq 	#0,d0
		lea 	text(pc),a0
		add.w 	tpointer(pc),a0
		move.b 	(a0),d0
		tst.b 	d0
		bne.s 	ascii	
		move.w 	#0,tpointer
		bra.s 	read

ascii:		sub.b 	#32,d0
		lsl.w 	#1,d0    		; * 2 
		lea 	char(pc),a0
		add.w 	d0,a0
		move.w 	(a0),offset
		addq.w 	#1,tpointer
		rts

;---------------------------------------------	

b_globe:	not.b	inv_flg
		beq.s	yeah
		rts

yeah:		move.w 	#$ffff,$ffff8a28.w		; endmsk1
		move.b  #0,$ffff8a3d.w			; skew
		move.w 	#2,$ffff8a20.w			; src x inc
		move.w	#80-8+2,$ffff8a22.w		; src y inc
		move.w	#160-32+8,$ffff8a30.w		; des y inc

		lea	globe_list,a1
		add.w	globe_pointer,a1
		cmp.l	#globe_listend,a1
		bne.s	inc_ani
		move.w	#0,globe_pointer
		bra.s	globe_out
inc_ani:	addq.w	#2,globe_pointer

globe_out:	lea 	globe,a0		
		add.w	(a1),a0
		lea	globescrn,a1		

;	1st
		move.l	a0,$ffff8a24.w		; src addr
		move.l	a1,$ffff8a32.w		; des addr
		move.w	#4,$ffff8a36.w		; x cnt 
		move.w	#64,$ffff8a38.w		; y cnt
		move.b  #%11000000,$ffff8a3c.w	; busy!
		rts

;---------------------------------------------	
;---------------------------------------------	
;------------------------------------- 	restore

back:		move.w	#$2700,sr
		move.l 	oldvbl,$70.w
		move.l 	oldhbl,$120.w
		move.b 	oldmfp07,$fffffa07.w
		move.b 	oldmfp09,$fffffa09.w		
		move.b 	oldmfp13,$fffffa13.w
		move.w 	#1,-(sp)
		move.l 	#-1,-(sp)
		move.l 	#-1,-(sp)
		move.w 	#5,-(sp)
		trap 	#14
		lea 	12(sp),sp
		move.w	#$003,$ffff8240.w
		move.w	#$777,$ffff8246.w
		move.b	#0,$ffff8264.w
		move.b	#0,$ffff8901.w
		move.w	#$2300,sr

		clr.l	-(sp)
		move.w	#$20,-(sp)
		trap	#1
		addq.l	#6,sp
		;clr.w	-(sp)
		;trap	#1

		rts

;------------------------------------- 	data and variables

yadd_tab:
dc.w 	0,160,320,480,640,800,960,1120,1280,1440,1600,1760
dc.w 	1920,2080,2240,2400,2560,2720,2880,3040,3200,3360
dc.w 	3520,3680,3840,4000,4160,4320,4480,4640,4800,4960
dc.w 	5120,5280,5440,5600,5760,5920,6080,6240,6400,6560
dc.w 	6720,6880,7040,7200,7360,7520,7680,7840,8000,8160
dc.w 	8320,8480,8640,8800,8960,9120,9280,9440,9600,9760
dc.w 	9920
dc.w 	10080,10240,10400,10560,10720,10880,11040,11200
dc.w 	11360,11520,11680,11840,12000,12160,12320,12480
dc.w 	12640,12800,12960,13120,13280,13440,13600,13760
dc.w 	13920,14080,14240,14400,14560,14720,14880,15040
dc.w 	15200,15360,15520,15680,15840,16000,16160,16320
dc.w 	16480,16640,16800,16960,17120,17280,17440,17600
dc.w 	17760,17920,18080,18240,18400,18560,18720,18880
dc.w 	19040,19200,19360,19520,19680,19840,20000,20160
dc.w 	20320,20480,20640,20800,20960,21120,21280,21440
dc.w 	21600,21760,21920,22080,22240,22400,22560,22720
dc.w 	22880,23040,23200,23360,23520,23680,23840,24000
dc.w 	24160,24320,24480,24640,24800,24960,25120,25280
dc.w 	25440,25600,25760,25920,26080,26240,26400,26560
dc.w 	26720,26880,27040,27200,27360,27520,27680,27840
dc.w 	28000,28160,28320,28480,28640,28800,28960,29120
dc.w 	29280,29440,29600,29760,29920,30080,30240,30400
dc.w 	30560,30720,30880,31040,31200,31360,31520,31680
dc.w 	31840,32000

;	begins with ASCII #32 (space)
char:	dc.w $0000,$0010,$0020
	dc.w $0030,$0040,$0050
	dc.w $0060,$0070,$0080
	dc.w $0090
	dc.w $1400,$1410,$1420
	dc.w $1430,$1440,$1450
	dc.w $1460,$1470,$1480
	dc.w $1490
	dc.w $2800,$2810,$2820
	dc.w $2830,$2840,$2850
	dc.w $2860,$2870,$2880
	dc.w $2890
	dc.w $3C00,$3C10,$3C20
	dc.w $3C30,$3C40,$3C50
	dc.w $3C60,$3C70,$3C80
	dc.w $3C90
	dc.w $5000,$5010,$5020
	dc.w $5030,$5040,$5050
	dc.w $5060,$5070,$5080
	dc.w $5090
	dc.w $6400,$6410,$6420
	dc.w $6430,$6440,$6450
	dc.w $6460,$6470,$6480
	dc.w $6490

globe_list:
dc.w	0,8,16,24,32,40,48,56,64,72
dc.w	5120,5120+8,5120+16,5120+24,5120+32
dc.w	5120+40,5120+48,5120+56,5120+64,5120+72
dc.w	10240,10240+8,10240+16,10240+24,10240+32
dc.w	10240+40,10240+48,10240+56,10240+64,10240+72
dc.w	15360,15360+8,15360+16,15360+24,15360+32
globe_listend:
dc.w	15360+40

fadest:	
dc.w	$888,$111,$999,$222,$aaa,$333,$bbb,$444,$ccc,$555,$ddd
dc.w	$666,$eee,$777,$fff
dc.w	$fff,$777,$eee,$666,$ddd,$555,$ccc,$444,$bbb,$333,$aaa
dc.w	$222,$999,$111,$888
fadeend:

text:
dc.b "                                         "
dc.b "THE ALMIGHTY INNER CIRCUIT EXPLORERS ARE BACK AGAIN!     "
dc.b "THIS TIME WITH DIGITAL WORLD II   - THE EXPLORATION -    "
dc.b "NOW I'LL TAKE THE CREDITS:     "
dc.b "CODE AND SOME GFXZ BY TECHWAVE OF ICE!      MEGACOOL TRACKMUZAK "
dc.b "BY AXEL OF BRAINSTORM!        THE GLOBE WAS RIPPED (I HATE TO "
dc.b "ADMIT IT!)...    RAYTRACED GFX MADE ON PC (WHY?!!!) BY UNKNOWN "
dc.b "SUCKER USING VIVID!   CONVERTED FROM GIF TO SPC TO NEO (REALLY NO "   
dc.b "BIG DIFFERENCE THIS TIME! COLOR ADJUST ONLY TO MAKE IT BETTER "
dc.b "THAN ORIGINAL!)                 "
dc.b "THIS DEMO SHOULD HAVE BEEN RELEASED ON THE 1991 TCB AND 2 LIFE "
dc.b "CREW PARTY  1-3 NOVEMBER  OUTSIDE STOCKHOLM, BUT, THERE WAS NO "
dc.b "TIME FINISH IT... (WHATTA NASTY BUG I DISCOVERED LATER, "
dc.b "MAN!)      BUT NOW IT'S READY...    PRESENT DAY:  911115    "
dc.b "TIME:  23:00:42    LET'S TAKE A PAUSE..........       I'M BACK!   "
dc.b "TIME:  00:34:32	 TODAY IT'S SATURDAY, THE DAY FOR THIS DEMO TO "
dc.b "BE LAUNCHED!    "
dc.b "IT'S NOT QUITE LIKE THE PREVIOUS DIGITAL WORLD, TOO BAD SOMEONE "
dc.b "SAYS, BUT I REALLY WANTED TO DO 'DIS SCREEN... AND I THINK IT'S "
dc.b "GOT NICE AND REALLY IS NICE!   MAYBE 'COZ IT IS - ICE - !       "
dc.b "READ CAREFULLY:   WE WANT FEMALE MEMBERS 'COZ WE ARE GOING TO BEAT"
dc.b " - THE RESPECTABLES - WHO HAVE ONE FEMALE MEMBER!!! (RECORD?!)    "
dc.b "MERIT WHICH WILL BE USEFULL:    KARATE, TAI KWON DOO, TEA BOILER "
dc.b "OR WHY NOT GFX DESIGNER?!        "  
dc.b "U PEOPLE OVER THE WORLD, CONTACT INNER CIRCUIT EXPLORERS! "
dc.b "EITHER ON THIS ADDRESS OR SOME OTHER ADDRESS:             " 
dc.b "TECHWAVE OF ICE        "
dc.b "KONVALESCENTV. 39         "
dc.b "S-439 00  ONSALA        "
dc.b "SWEDEN           OKEY, U BETTER CONTACT ME NOW!      "
dc.b "I'M RIGHT NOW LISTENING TO BOMB THE BASS - UNKNOWN TERRITORY - !  "
dc.b "   'WINTER IN JULY', 'THE AIR YOU BREATHE' AND "
dc.b "'THROUGHOUT THE ENTIRE WORLD' ARE REALLY GOOD!!             "

dc.b " GREETINGS TO:       "
dc.b "G.R.C. (YEZ, I KNOW...GRIM REAPER CREW!)"
dc.b "           "
dc.b "OMEGA (WHY NOT RELEASE SOMETHING SOMETIME?)"
dc.b "           "
dc.b "SYNC"
dc.b "           "
dc.b "UNIT 17 (DEAD?)"
dc.b "           "
dc.b "TCB "
dc.b "           "
dc.b "2 LIFE CREW"
dc.b "           "
dc.b "KRUZ"


dc.b 0
even

;---------------------------------------------	
mw_set:		dc.w	%10011000000+40		; master    0-40
		dc.w	%10101000000+20		; left	    0-20
		dc.w	%10100000000+20		; right	    0-20
		dc.w	%10010000000+6		; treble    0-12 (6=0dB)
		dc.w	%10001000000+9		; bass      0-12 (6=0dB)
		dc.w	%10000000000+2		; mix       0-03
mw_setend:

oldvbl:		dc.l 	0
oldhbl:		dc.l 	0
oldmfp07:	dc.b 	0
oldmfp09:	dc.b 	0
oldmfp13:	dc.b 	0
cntlines:	dc.b	0

toskew:		dc.b 12
spaceflg:	dc.b 0
second:		dc.b 0

vbl_flg:	dc.b 	0
scrnflg:	dc.b 	0
clrflg:		dc.b 	0
inv_flg:	dc.b	0

hscroll_data:	blk.b	32,0
		dc.b	0
exit_flg:	dc.b	0
exit_cnt:	dc.b	0
hide_flg:	dc.b	0
dmasndflg:	dc.b	0
dma09:		dc.b	0
dma0b:		dc.b	0
dma0d:		dc.b	0
pause_flg:	dc.b	0
even
tpointer:	dc.w 	0
offset:		dc.w 	0
xoutadd:	dc.w 	152
sinpoint:	dc.w	0
globe_pointer:	dc.w	0
fadepek:	dc.w	0
fade_wait:	dc.w	0
osc_size:	dc.w	1
center:		dc.w	320-130

screenp_data:	blk.l	32,0
		dc.l	icetop+128+5120+160
clraddrs:	blk.l	800,$f8000

frames:		dc.l 	noisemod,noisemod+$b61a  

icetop:		blk.b	32128+7200,0
oscillomem=icetop+128+11200-1600
scl_addr=icetop+32128-1280

dma_st:		dc.l 	talk
dma_end:	dc.l 	talkend

talk:		blk.b	30560,0
talkend:	
even					; there's the missing shit!

intropic:	blk.b	32128,0
globe:		blk.b   20520,0
globescrn=icetop+32128-2560+4+64-1280
fontimg: 	blk.b	32000,0
nicepic:	blk.b	32128,0

sinstart:	blk.b	116,159
sindist:	blk.b	3213,0
		blk.b	100,159
sinend:		blk.b	32,159
even
noisemod_x:	blk.b 178108,0 		; fix $512c(nop)
noisemodend_x:
noisemod:	equ	$50000
