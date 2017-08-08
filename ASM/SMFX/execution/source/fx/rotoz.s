sintable_length				equ	2048
sintable_size				equ	sintable_length*2

viewport_width_blocks		equ 20
viewport_height_lines		equ 100

effect_frames_before_credits_start	equ 12+11+10+2+2+6+1	;38				;64

effect_fames_draw_credits			equ 46				;64 + 4
effect_frames_display_credits		equ 17	;96			;32 - 4
effect_frames_between_credits		equ 1	;100		;30 

effect_frames_total					equ 4*128+10+2+2+6+1			; 512 effect frames

fontpixels_drawn_per_effect_frame	equ 30		

    section	TEXT

init_rotozoom
	move.w	#effect_frames_before_credits_start,_creditsWait
	lea		_frameDrawList,a0
	move.w	(a0),_drawFrames

	; sort pointers
	move.l	alignpointer1,screenpointer3

	move.l	alignpointer3,c2plookuptablepointer
	move.l	alignpointer7,text1pointer
	move.l	alignpointer9,text2pointer

	move.l	savedscreenpointer,d0
	add.l	#$C000,d0
	move.l	d0,chunkytextpointer

	move.l	savedscreenpointer2,d0
	add.l	#$C000,d0
	move.l	d0,doublescanlinespointer			; 100 * 34 + 2 = 3402
	add.w	#3500,d0
	move.l	d0,rotosmcpointer


	jsr		generateC2PLookupTable
	jsr		generateTextureTables
	jsr		generateDoubleScanlines
	jsr		generateRotoCode


	move.l	savedscreenpointer,a0
	move.l	screenpointer3,a2
	move.l	#0,d0
	add.w	#200*160,a0
	add.w	#200*160,a2
	move.w	#60-1,d7
.cc	
	REPT 20
		move.l	d0,(a0)+
		move.l	d0,(a0)+
		move.l	d0,(a2)+
		move.l	d0,(a2)+
	ENDR
	dbra	d7,.cc

	move.l	savedscreenpointer,screenpointer
	move.l	savedscreenpointer2,screenpointer2

		jsr		doRotoZoom2
		jsr		doC2P						; 448400

	move.l	savedscreenpointer2,a1
	add.l	#238*160,a1

	move.w	#12-1,d7
	move.l	#0,d0
.cc2
	REPT 20
		move.l	d0,(a1)+
		move.l	d0,(a1)+
	ENDR
	dbra	d7,.cc2



triblebufferloopinit
	move.w	#$2700,sr
	move.l	#dummy,$134
	move.l	#dummy,$120
	move.l	#c2p_vbl,$70
	move.w	#$2300,sr
	move.w	#0,_vblcounter
	move.l	screenpointer2,$ffff8200
	jsr		swapscreens_c2p				; dont use jmp when it returns with rts, use branch then
	wait_for_vbl

	move.l	screenpointer,a0
	move.l	#0,d0
	add.l	#200*160,a0
	move.w	#41-1,d7
.cc	
	REPT 20
		move.l	d0,(a0)+
		move.l	d0,(a0)+
	ENDR
	dbra	d7,.cc

	move.w	#0,_vblcounter
	move.w	#0,_effectcounter
.triblebufferloop
	; without music 5200 nops left in 3 vbl
	; crystal clear song playing: 2000 nops left	--> 1100 nops per 
		jsr		doRotoZoom
		jsr		doC2P						; 448400
		jsr		drawCredits
		jsr		copyCredits
		move.l	screenpointer2,$ffff8200

		subq.w	#1,_xx
		bge		.skipzoom
			add.w	#$24,_zoom
.skipzoom
		jsr		swapscreens_c2p				; dont use jmp when it returns with rts, use branch then
		addq.w	#1,_effectcounter
				exitOnSpace		
		tst.w	_roto_exit
		beq		.triblebufferloop
	rts

_xx				dc.w	effect_frames_total

_slowroto		dc.w	3
_effectcounter	dc.w	0

c2p_vbl	
	addq.w	#1,$466
	addq.w	#1,_vblcounter
	pushall

	jsr		doLowerBorderPal

	jsr		doRotoPalette

	move.l	sndh_pointer,a0
	jsr		8(a0)

	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#199,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	tst.w	borderActive
	bne		.xxx
	move.l	#open_lower_border,$120.w
	jmp		.yyy
.xxx
	move.l	#dummy,$120.w
.yyy
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	popall

	rte
borderActiveWaiter	dc.w	4
borderActive		dc.w	-1
borderFadeWaiter	dc.w	210
borderFadeIn		dc.w	0

doLowerBorderPal
	subq.w	#1,borderFadeWaiter			; see if we want to fade or wait
	bge		.noFade						; if we are not -1, then we wait
		move.w	#3,borderFadeWaiter						; reset teh fade timer, we want to fade!
		tst.w	borderFadeIn							; check direciton of the fade, in or out
		bne		.fadeOut									; if != 0 then we fade out
.fadeIn									; we fade in!
		move.w	#0,borderActive
		sub.w	#32,border_off			; subtract 
		bne		.ok						; if we're 0, then we want to fade end
			move.w	#62,borderFadeWaiter
			move.w	#-1,borderFadeIn		
			rts
.fadeOut
		add.w	#32,border_off
		cmp.w	#224+32,border_off
		bne		.ok
			move.w	#-1,borderActive
			move.w	#282,borderFadeWaiter
			move.w	#0,borderFadeIn		
			subq.w	#1,borderActiveWaiter
			add.w	#256+32,border_select
.noFade
.ok
	rts

border_select	dc.w	0

_vblcounter
	dc.w	0


_zoom	dc.w	0

border_pal
; 505
	dc.w	$0000,$0101,$0212,$0321,$0431,$0543,$0655,$0777,$0666,$0654,$0643,$0631,$0522,$0422,$0312,$0202
	dc.w	$0000,$0001,$0112,$0221,$0331,$0443,$0555,$0677,$0566,$0554,$0543,$0531,$0422,$0322,$0212,$0102
	dc.w	$0000,$0001,$0102,$0211,$0321,$0433,$0545,$0667,$0556,$0544,$0533,$0521,$0412,$0312,$0202,$0102
	dc.w	$0000,$0001,$0002,$0111,$0221,$0333,$0445,$0567,$0456,$0444,$0433,$0421,$0312,$0212,$0102,$0002
	dc.w	$0000,$0001,$0002,$0101,$0211,$0323,$0435,$0557,$0446,$0434,$0423,$0411,$0302,$0202,$0102,$0002
	dc.w	$0000,$0000,$0001,$0000,$0100,$0212,$0324,$0446,$0335,$0323,$0312,$0300,$0201,$0101,$0001,$0001
	dc.w	$0000,$0000,$0000,$0000,$0000,$0101,$0213,$0335,$0224,$0212,$0201,$0200,$0100,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0102,$0123,$0113,$0101,$0100,$0100,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000


; modmate
	dc.w	$0000,$0101,$0202,$0311,$0421,$0533,$0645,$0777,$0565,$0553,$0542,$0530,$0421,$0321,$0211,$0101
	dc.w	$0000,$0101,$0202,$0301,$0411,$0523,$0635,$0776,$0555,$0543,$0532,$0520,$0411,$0311,$0201,$0101
	dc.w	$0000,$0100,$0200,$0300,$0410,$0521,$0633,$0665,$0553,$0541,$0530,$0520,$0410,$0310,$0200,$0100
	dc.w	$0000,$0000,$0100,$0200,$0310,$0420,$0532,$0554,$0452,$0440,$0430,$0420,$0310,$0210,$0100,$0000
	dc.w	$0000,$0000,$0100,$0200,$0300,$0410,$0521,$0443,$0441,$0430,$0420,$0410,$0300,$0200,$0100,$0000
	dc.w	$0000,$0000,$0000,$0100,$0200,$0300,$0410,$0332,$0330,$0320,$0310,$0300,$0200,$0100,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0100,$0200,$0300,$0221,$0220,$0210,$0200,$0200,$0100,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0100,$0200,$0111,$0110,$0100,$0100,$0100,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

; spkr
	dc.w	$0000,$0100,$0211,$0320,$0430,$0542,$0654,$0777,$0665,$0653,$0642,$0630,$0521,$0421,$0311,$0201
	dc.w	$0000,$0100,$0210,$0320,$0430,$0540,$0652,$0775,$0663,$0651,$0640,$0630,$0520,$0420,$0310,$0200
	dc.w	$0000,$0000,$0100,$0210,$0320,$0430,$0542,$0665,$0553,$0541,$0530,$0520,$0410,$0310,$0200,$0100
	dc.w	$0000,$0000,$0100,$0200,$0310,$0420,$0532,$0655,$0543,$0531,$0520,$0510,$0400,$0300,$0200,$0100
	dc.w	$0000,$0000,$0000,$0100,$0210,$0320,$0432,$0555,$0443,$0431,$0420,$0410,$0300,$0200,$0100,$0000
	dc.w	$0000,$0000,$0000,$0100,$0200,$0310,$0422,$0554,$0433,$0421,$0410,$0400,$0300,$0200,$0100,$0000
	dc.w	$0000,$0000,$0000,$0000,$0100,$0210,$0322,$0445,$0333,$0321,$0310,$0300,$0200,$0100,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0100,$0210,$0333,$0221,$0210,$0200,$0200,$0100,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

; ukko
	dc.w	$0000,$0001,$0112,$0221,$0331,$0443,$0555,$0777,$0665,$0653,$0642,$0630,$0521,$0421,$0311,$0201
	dc.w	$0000,$0001,$0012,$0121,$0231,$0343,$0455,$0677,$0565,$0553,$0542,$0530,$0421,$0321,$0211,$0101
	dc.w	$0000,$0001,$0002,$0111,$0221,$0333,$0445,$0667,$0555,$0543,$0532,$0520,$0411,$0311,$0201,$0101
	dc.w	$0000,$0001,$0002,$0011,$0121,$0233,$0345,$0567,$0455,$0443,$0432,$0420,$0311,$0211,$0101,$0001
	dc.w	$0000,$0001,$0002,$0001,$0111,$0223,$0335,$0557,$0445,$0433,$0422,$0410,$0301,$0201,$0101,$0001
	dc.w	$0000,$0000,$0001,$0000,$0010,$0122,$0234,$0456,$0344,$0332,$0321,$0310,$0200,$0100,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0011,$0123,$0345,$0233,$0221,$0210,$0200,$0100,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0001,$0122,$0011,$0000,$0000,$0000,$0000,$0000,$0000,$0000
	dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000

border_off		dc.w	224+32	;224

curtain_top
	move.w	#$2700,sr
	move.w	#$030,$ffff8240

	clr.b	$fffffa1b.w			;Timer B control (stop)
	move.b	#198,$fffffa21.w		;Timer B data (number of scanlines to next interrupt)
	move.l  #open_lower_border,$120.w        ;Install our own Timer B
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))

	move.w	#$2300,sr
	rte

open_lower_border
	move.w	#$2700,sr
	movem.l	d0-d7/a0/a6,-(sp)
	lea		border_pal,a6
	add.w	border_select,a6
	add.w	border_off,a6
	move.l	(a6)+,d1
	move.l	(a6)+,d2
	move.l	(a6)+,d3
	move.b  $FFFFFA21.w,D0
.tb_sync:        
	cmp.b   $FFFFFA21.w,D0  ; wait for end of the line
    beq.s   .tb_sync

    move.b  #0,$FFFF820A.w  
    	movem.l	(a6),d4-d7/a0/a6
    REPT 1
;	REPT 16
		nop			; 12 nops		;64
	ENDR
    move.b  #2,$FFFF820A.w  ; 50 hz
    movem.l	d1-d7/a0,$ffff8240
	movem.l	(sp)+,d0-d7/a0/a6
    rte

swapscreens_c2p:
	move.l	screenpointer,d0
	move.l	screenpointer2,screenpointer
	move.l	screenpointer3,screenpointer2
	move.l	d0,screenpointer3
	rts	



_transition	dc.w	0
_palWaiter	dc.w	6
_palTimes	dc.w	7
rotPalOff	dc.w	-7*32


doRotoPalette
	lea		rotoPalettes,a0
	add.w	rotPalOff,a0
	movem.l	(a0),d0-d7
	movem.l	d0-d7,$ffff8240

	tst.w	rotPalOff
	bge		.already16
		subq.w	#1,_palWaiter
		bne		.kk
			move.w	#12,_palWaiter	
			add.w	#32,rotPalOff
.already16

	tst.w	_transition
	beq		.kk
		subq.w	#1,_palWaiter
		bne		.kk
			move.w	#12,_palWaiter
			add.w	#32,rotPalOff
			subq.w	#1,_palTimes
				bne		.kk
					move.w	#0,_transition
					move.w	#7,_palTimes
.kk
	rts


list	
	dc.l	cred_ukko
	dc.l	cred_spkr
	dc.l	cred_mod
	dc.l	cred_505

listoff			dc.w	12
creditsOff		dc.l	0
credsWaiter		dc.w	2
_creditsWait	dc.w	-1


drawCredits
	subq.w	#1,_creditsWait
	bgt		.dontDraw
	lea		list,a0
	add.w	listoff,a0
	move.l	(a0),a0
	move.l	(a0)+,a6		; max size
	add.l	creditsOff,a0

	move.l	c2plookuptablepointer,a5
	move.l	text1pointer,a1
	move.l	a1,a3
	add.l	#$10000,a3
	move.l	text2pointer,a2
	move.l	a2,a4
	add.l	#$10000,a4

	cmp.l	creditsOff,a6													
	blt		.creditsDrawDone		

	; a0 source
	; a1	target1
	; a2	target2
	; a3	target3
	; a4	target4
	; a5 lookuptable
.loop	
	; taken:
	;	d0,d6
	;
	;
	;	
	REPT fontpixels_drawn_per_effect_frame			;-> 1.5kb code																					moveq	#0,d0			;4
		moveq	#0,d0				;4													moveq	#0,d0
		move.w	(a0)+,d0			;8		; oh look, new value						move.l	(a0)+,d6
		blt		.end				;8													move.w	(a0),d0
		move.l	(a0)+,d6			;12		; oh look, distance into target				blt		.end
		move.w	2(a2,d6.l),-6(a0)	;24													move.w	2(a2,d6.l),(a0)+
		move.w	d0,2(a2,d6.l)		;16													move.w	d0,2(a2,d6.l)
		move.w	d0,2(a4,d6.l)		;16													move.w	d0,2(a4,d6.l)
		lsl.w	#4,d0				;12													lsl.w	#4,d0
		move.w	d0,(a2,d6.l)		;16													....
		move.w	d0,(a4,d6.l)		;16										
		lsl.l	#4,d0				;16										
		add.l	a5,d0				;8										
		move.l	d0,(a1,d6.l)		;20										
		move.l	d0,(a3,d6.l)		;20		--> 196																							
	ENDR																	
							

; fastest:
;	move.l	(a0)+,d6			;12		offset
;	move.l	(a0)+,d0			;12 	new val
;	move.l	d0,(a2,d6.l)		;20		-
;	move.l	d0,(a4,d6.l)		;20		-
;	move.l	(a0)+,d0			;12 	new val 2
;	move.l	d0,(a1,d6.l)		;20		-
;	move.l	d0,(a3,d6.l)		;20		-			---> 116		30*80=2400 cycles won

;	REPT 10
;		movem.l	(a0)+,d0-d7/a5			;84			
;		move.l	d1,(a2,d0.l)			;20
;		move.l	d1,(a4,d0.l)			;20
;		move.l	d2,(a1,d0.l)			;20
;		move.l	d2,(a3,d0.l)			;20
;
;		move.l	d4,(a2,d3.l)			;20
;		move.l	d4,(a4,d3.l)			;20
;		move.l	d5,(a1,d3.l)			;20
;		move.l	d5,(a3,d3.l)			;20
;
;		move.l	d7,(a2,d6.l)			;20
;		move.l	d7,(a4,d6.l)			;20
;		move.l	a5,(a1,d6.l)			;20
;		move.l	a5,(a3,d6.l)			;20		--> 12*20 = 240 + 84 = 324 ==> 108 per			196-108 = 88 * 30 = 2640 per frame * 533 = 1407120	/ 160000 -> 8,7945
;	ENDR


	; ideal; store
;	move.l	(a0)+,d6						; movem.l for some more profit
;	move.l	(a0)+,d0
;	move.l	(a2,d6.l),(a0)+		28
;	move.l	d0,(a2,d6.l)	
;	move.l	d0,(a4,d6.l)
;	move.l	(a0)+,d0
;	move.l	(a1,d6.l),(a0)+		28
;	move.l	d0,(a1,d6.l)
;	move.l	d0,(a3,d6.l)

;	movem.l	(a0)+,


	; ideal; restore
;	move.l	(a0)+,d0			;12
;	move.l	(a0)+,d6			;12	
;	move.l	d0,(a2,d6.l)		;20
;	move.l	d0,(a4,d6.l)		;20
;	move.l	(a0)+,d0			;12
;	move.l	d0,(a1,d6.l)		;20
;	move.l	d0,(a3,d6.l)		;20		-> 36+80 = 116


.end
	add.l	#6*fontpixels_drawn_per_effect_frame,creditsOff
.creditsDrawDone
	subq.w	#1,_drawFrames
	bne		.drawNextFrame

		lea		_frameDrawList,a0
		add.w	_frameDrawListOff,a0
		move.w	(a0),_drawFrames

		lea		_frameDisplayList,a0
		add.w	_frameDisplayListOff,a0
		move.w	(a0),_creditsWait

		move.l	#0,creditsOff										; reset offset into buffer										

		subq.w	#1,credsWaiter
		bne		.drawNextFrame
			move.w	#-1,_transition										; if we get here, then stuff is removed and we move to the next item in list
			move.w	#0,_credActive
			subq.w	#4,listoff
			blt		.exit												; if this is negative, then effect is done
				move.w	#2,credsWaiter							
				add.w	#2,_frameDisplayListOff

				lea		_frameWaitList,a0
				add.w	_frameWaitListOff,a0
				move.w	(a0),_creditsWait
				add.w	#2,_frameWaitListOff

				add.w	#2,_frameDrawListOff
				lea		_frameDrawList,a0
				add.w	_frameDrawListOff,a0
				move.w	(a0),_drawFrames
.drawNextFrame
.dontDraw
	rts

.exit
	move.w	#12,listoff
	move.w	#2,credsWaiter
	move.w	#$7999,_creditsWait
	move.w	#-1,_roto_exit
	rts

; sequence:
;	- _creditsWait (first time)
;
;	- credits draw 1 (drawframes 1 first time)			\
;	- credits display 1 (display for 1)					 \__ must be 128
;	- credits remove 1 (drawframes 1 second time)		 /
;	- credits wait 2									/
;	

	; credits draw
	;	
_frameDrawListOff	dc.w	0
_frameDrawList		
	dc.w	50				; 505 in/out	
	dc.w	49				; modmate in/out
	dc.w	32				; spkr in/out
	dc.w	46				; ukko in/out

_frameDisplayListOff	dc.w	0
_frameDisplayList
	dc.w	24
	dc.w	18
	dc.w	26
	dc.w	35

_frameWaitListOff		dc.w	0
_frameWaitList	
	dc.w	15				;wait 505 - modmate
	dc.w	20				;wait modmate - spkr
	dc.w	22				;wait spkr - ukko
	dc.w	4

.end																		
	add.l	#(4+2)*fontpixels_drawn_per_effect_frame,creditsOff		; now duration is looped over size of pixels, should be frames		
.creditsDrawDone
	subq.w	#1,_drawFrames	
	bne		.drawNextFrame
		move.w	#effect_fames_draw_credits,_drawFrames
		move.l	#0,creditsOff										; reset offset into buffer										
		move.w	#effect_frames_display_credits,_creditsWait			; wait a few frames to display text
		subq.w	#1,credsWaiter										; tell it to do 1 more loop, if reaches 0 then switch buffer
		bne		.kkk
			move.w	#-1,_transition
			move.w	#0,_credActive
			subq.w	#4,listoff
			blt		.exit
			move.w	#2,credsWaiter
			move.w	#effect_frames_between_credits,_creditsWait
.kkk
.drawNextFrame
.dontDraw
	rts

.exit
	move.w	#$7999,_creditsWait
	move.w	#-1,_roto_exit
	rts



_roto_exit	dc.w	0
_drawFrames	dc.w	-1

	




	dc.w	$0000,$0101,$0112,$0222,$0322,$0433,$0222,$0122,$0777,$0777,$0653,$0433,$0322,$0653,$0765,$0777		;0
	dc.w	$0000,$0101,$0112,$0222,$0322,$0433,$0122,$0122,$0777,$0777,$0654,$0433,$0322,$0653,$0765,$0777		;1
	dc.w	$0000,$0101,$0112,$0222,$0322,$0433,$0122,$0022,$0777,$0777,$0655,$0443,$0332,$0653,$0765,$0777		;2
	dc.w	$0000,$0101,$0112,$0222,$0322,$0433,$0122,$0022,$0777,$0777,$0656,$0444,$0332,$0653,$0765,$0777		;3
	dc.w	$0000,$0101,$0112,$0222,$0322,$0432,$0022,$0012,$0777,$0777,$0656,$0445,$0333,$0653,$0766,$0777		;4
	dc.w	$0000,$0101,$0112,$0222,$0322,$0432,$0022,$0012,$0777,$0677,$0656,$0446,$0333,$0653,$0766,$0777		;5
	dc.w	$0000,$0101,$0112,$0222,$0322,$0432,$0022,$0012,$0777,$0677,$0666,$0446,$0334,$0653,$0776,$0777		;6
rotoPalettes
	dc.w	$0000,$0101,$0112,$0222,$0322,$0432,$0022,$0012,$0777,$0677,$0666,$0446,$0334,$0653,$0776,$0777		;1	; 505
	dc.w	$0000,$0101,$0212,$0222,$0332,$0442,$0122,$0112,$0777,$0677,$0665,$0445,$0434,$0653,$0776,$0777		;2
	dc.w	$0000,$0101,$0212,$0222,$0332,$0442,$0212,$0112,$0777,$0677,$0664,$0544,$0434,$0654,$0776,$0777		;3
	dc.w	$0000,$0211,$0222,$0333,$0433,$0443,$0212,$0102,$0777,$0577,$0664,$0544,$0423,$0654,$0676,$0777		;4
	dc.w	$0000,$0211,$0222,$0333,$0433,$0443,$0302,$0102,$0777,$0577,$0554,$0534,$0423,$0564,$0676,$0777		;5
	dc.w	$0000,$0211,$0322,$0333,$0443,$0453,$0302,$0202,$0777,$0577,$0553,$0633,$0523,$0564,$0676,$0777		;6
	dc.w	$0000,$0211,$0322,$0333,$0443,$0453,$0402,$0202,$0777,$0577,$0552,$0632,$0523,$0565,$0676,$0777		;7	spkr


	dc.w	$0000,$0211,$0322,$0333,$0443,$0453,$0402,$0202,$0777,$0577,$0552,$0632,$0523,$0565,$0676,$0777		;1
	dc.w	$0000,$0211,$0322,$0322,$0443,$0442,$0402,$0202,$0777,$0577,$0552,$0632,$0523,$0565,$0676,$0777		;2
	dc.w	$0000,$0211,$0322,$0322,$0432,$0442,$0302,$0202,$0777,$0577,$0552,$0632,$0423,$0565,$0676,$0777		;3
	dc.w	$0000,$0200,$0311,$0311,$0532,$0542,$0312,$0212,$0777,$0577,$0553,$0533,$0423,$0665,$0676,$0777		;4
	dc.w	$0000,$0200,$0311,$0311,$0531,$0542,$0311,$0212,$0777,$0676,$0553,$0533,$0433,$0665,$0765,$0777		;5
	dc.w	$0000,$0200,$0300,$0411,$0521,$0531,$0311,$0111,$0777,$0676,$0664,$0544,$0433,$0654,$0765,$0777		;6
	dc.w	$0000,$0100,$0300,$0411,$0620,$0531,$0211,$0111,$0777,$0676,$0664,$0444,$0333,$0654,$0765,$0777		;7	modmate
	dc.w	$0000,$0100,$0300,$0400,$0620,$0631,$0221,$0111,$0776,$0676,$0665,$0445,$0333,$0754,$0765,$0777




		   ;0000 0212 0323 0334 0444 0454 0601 0401 0777 0770 0750 0731 0722 0565 0676 0777				003.PAL

;	dc.w	$0000,$0100,$0300,$0400,$0620,$0631,$0221,$0111,$0776,$0676,$0665,$0445,$0333,$0754,$0765,$0777
	dc.w	$0000,$0100,$0300,$0411,$0620,$0631,$0321,$0111,$0776,$0675,$0664,$0444,$0333,$0754,$0765,$0777
	dc.w	$0000,$0200,$0301,$0411,$0521,$0532,$0311,$0211,$0776,$0675,$0664,$0544,$0433,$0654,$0765,$0777
	dc.w	$0000,$0200,$0311,$0412,$0532,$0542,$0411,$0211,$0776,$0674,$0664,$0533,$0433,$0654,$0765,$0777
	dc.w	$0000,$0211,$0311,$0412,$0532,$0543,$0511,$0301,$0776,$0674,$0752,$0632,$0522,$0665,$0676,$0777
	dc.w	$0000,$0211,$0312,$0322,$0433,$0443,$0511,$0301,$0776,$0772,$0752,$0632,$0522,$0665,$0676,$0777
	dc.w	$0000,$0212,$0322,$0323,$0443,$0453,$0601,$0401,$0776,$0772,$0750,$0731,$0622,$0565,$0676,$0777
	dc.w	$0000,$0212,$0323,$0334,$0444,$0454,$0701,$0401,$0777,$0770,$0750,$0731,$0722,$0565,$0676,$0777


; so we have:
;	- rotation 
;	- zoom
;	- movement


_frameCounter	dc.w	-40+44+2+2+6+1
_weird			dc.w	256/2-30
_flip			dc.w	128/2-1

doRotoZoom2
	lea		sine_tbl3,a0										;8
	lea		sine_tbl3+(sintable_size/4),a1						;8

	move.w	_frameCounter,d0									;12
	sub.w	#2,d0												;8
	jmp		cont


doRotoZoom
	lea		sine_tbl3,a0										;8
	lea		sine_tbl3+(sintable_size/4),a1						;8

	move.w	_frameCounter,d0									;12
	sub.w	#4,d0												;8
cont
	move.w	d0,_frameCounter			; save time				;16

	move.w	#sintable_size-1,d7			; sine max size mask

	move.w	d0,d1						; save to d1			;4
	move.w	d0,d6						; save to d6			;4

	add.w	d1,d1
	add.w	d1,d1
	add.w	d1,d1


	and.w	d7,d1												;4
	move.w	(a0,d1.w),d2				; sin() -> d2			;16
	move.w	d2,d3
	add.w	d3,d3
	add.w	d3,d3
	add.w	d2,d3

	subq.w	#1,_weird
	bge		.herp
		move.w	d2,d1
		add.w	d2,d2
		add.w	d1,d2
		subq.w	#1,_flip
		bge		.herp
			move.w	#128/2-1,_flip
			move.w	#256,_weird
.herp

	movem.w	d2/d3,center_pos									;24		--> 290

.calc_xy_rot:
	add.w	d0,d0												;4						 rotation
	add.w	d0,d0												;4


	and.w	d7,d0												;4
	move.w	(a1,d0.w),d1										; cos
	move.w	(a0,d0.w),d0										; sin

	move.w	d1,d2			; cos(x)							;4
	neg.w	d2				;-cos(x)							;4
	move.w	d0,d3			; sin(x)							;4
; d2.w: a'.x, d3.w: a'.y
	;	d2	1.x 		-cos	-y													vertical
	;	d3	1.y			sin		x
	move.w	d0,d4												;4
	move.w	d1,d5												;4
;	add.w	d5,d5
	;	d4	2.x			sin		x													horizontal
	;	d5	2.y			cos		y
; And we calculate the amount of zoom... based on time

	asl.w	#4,d6
	and.w	d7,d6												;4
	move.w	(a1,d6.w),d6
	asr.w	#6,d6				;7								;18
	add.w	#$380,d6			;280							;10		-->	184

	sub.w	_zoom,d6
	bge		.ok
		move.w	#0,d6
		subq.w	#1,_zoomtimes
		bge		.ok
			move.l	#dummy,$120
			move.w	#-1,_roto_exit
			clr.b	$fffffa1b.w			;Timer B control (stop)
.ok	

	muls.w	d6,d2												;50			1.x -cos		A
	muls.w	d6,d3												;52			1.y  sin
	muls.w	d6,d4												;52			2.x sin			B
	muls.w	d6,d5												;52			2.y cos
	add.l	d3,d3												;8
	add.l	d5,d5												;8

	swap	d2													;4
	swap	d3													;4
	swap	d4													;4
	swap	d5													;4		--> 238

	movem.w	center_pos,d6/d7									;24
	asr.w	d6													;10

	move.l	d2,d0												;4
	move.l	d3,d1												;4
	movea.l	d4,a4												;4
	movea.l	d5,a5												;4		--> 50		--> 762

	muls	#50,d0
	muls	#50,d1


	add.l	d0,d6
	add.l	d1,d7
	muls.w	#80,d4				
	muls.w	#80,d5				
	sub.l	d4,d6				; d6.l=topleft_u (8.8)	x
	sub.l	d5,d7				; d7.l=topleft_v (8.8)	y

;	sub.l	#$a00,d6


	move.l	a4,d4
	move.l	a5,d5


	; uv mappying
	;	u -> x
	;	v -> y
	move.l	#$0000FFFF,d0			; 3*8 + 12 = 36							; mask for lower word
	and.l	d0,d7					;				$----VVvv	;8			; get 8.8 position for topleft y
	ror.l	#8,d7					; d7.l=     	$vv----VV	;24			; fraction in upper byte
	move.w	d7,v_int_pos			; v_int_pos=	$------VV	;16			; save integer value
	move.w	d6,d7					; d7.l=     	$vv--UUuu	;4			; fraction y in upper byte, 8.8 x lower
	move.l	d7,uv_pos			; uv_pos=   	$vv--UUuu	;20			; save 
; a (vector on the vertical screen axis)
	and.l	d0,d3					;				$----VYvy	;8			; mask
	ror.l	#8,d3					; d3.l=     	$vy----VY	;24			; put fraction up top
	move.w	d3,v_int_inc			; v_int_inc=    $------VY	;16			; save for outer loop
	move.w	d2,d3					; d3.l=     	$vy--VXvx	;4			; put x value 
	move.l	d3,uv_inc			; uv_inc=   	$vy--VXvx	;20			; safe
; b (vector on the horizontal screen axis)
	and.l	d0,d5					;				$----HYhy	;8
	ror.l	#8,d5					; d5.l=     	$hy----HY	;24
	move.w	d5,d0					; d0.w=         $------HY	;4
	move.w	d4,d5					; d5.l=     	$hy--HXhx	;4
	move.l	d5,d3					; d3.l=     	$hy--HXhx	;4
	move.w	d0,d4					; d4.w=         $------HY	;4


	move.w	#$7FFE,d5
	moveq	#64-1,d7
	move.l	uv_pos,d0			
	move.w	v_int_pos,d1			; 

	moveq	#0,d2				;	
	move.w	d0,d2				;	$------BY
	move.b	d1,d2				; 	
	and.w	d5,d2				; %0UUUUUUUVVVVVVV0
	move.w	d2,org_offset

	; d0 uv position					; vv--UUuu
	; d1 v integer position				;     --VV
	; d2 local var						;
	; d3 								; hy--HXhx 	for addition and overflow
	; d4 								;     --HY
	; d5  $7ffe


	; 3kb code
	lea		c2ploop,a0
	move.l	rotosmcpointer,a1
	jmp		(a1)


;o set 0
;	REPT viewport_width_blocks*2
;		move.w	d0,d2					; whole part of the stepx_x		%XXXXXXXX--------	4											move.l	d0,d5		;4
;		move.b	d1,d2					; x increment					%XXXXXXXXYYYYYYYY	4											swap	d5			;4
;		and.w	d5,d2					; %0UUUUUUUVVVVVVV0				%0XXXXXXXYYYYYYY0	4											and.w	d6,d5		;4
;		add.w	d2,d2					;								%XXXXXXXYYYYYYY00	4											move.w	d2,d4		;4
;		move.w	d2,o+2(a0)				;12													12											and.w	d7,d4		;4
;		add.l	d3,d0					;													8											add.w	d4,d5		;4
;		addx.b	d4,d1					;													4	--> 40 * 64 = 2560 						move.w	d5,0(a0)	;12
;										;																								add.l	d1,d0		;8
;		move.w	d0,d2					; whole part of the stepx_x		%XXXXXXXX--------												add.w	d3,d2		;4		-> 12 * 4 = 48
;		move.b	d1,d2					; x increment					%XXXXXXXXYYYYYYYY												move.l	d0,d5
;		and.w	d5,d2					; %0UUUUUUUVVVVVVV0				%0XXXXXXXYYYYYYY0												swap	d5
;		add.w	d2,d2					;								%XXXXXXXYYYYYYY00												and.w	d6,d5
;		move.w	d2,o+6(a0)				;12																								move.w	d2,d4
;		add.l	d3,d0					;																								and.w	d7,d4
;		addx.b	d4,d1					;																								and.w	d4,d5
;										;																								move.w	d5,4(a0)
;		move.w	d0,d2					; whole part of the stepx_x		%XXXXXXXX--------
;		move.b	d1,d2					; x increment					%XXXXXXXXYYYYYYYY
;		and.w	d5,d2					; %0UUUUUUUVVVVVVV0				%0XXXXXXXYYYYYYY0
;		add.w	d2,d2					;								%XXXXXXXYYYYYYY00
;		addq.w	#2,d2																									;4 cycles * 16		4*40= 160
;		move.w	d2,o+10(a0)				;12
;		add.l	d3,d0					;	
;		addx.b	d4,d1
;
;		move.w	d0,d2					;	move absolute position to tmp	
;		move.b	d1,d2					;	
;		and.w	d5,d2					;
;		add.w	d2,d2					;
;		move.w	d2,o+14(a0)				;
;		add.l	d3,d0					;
;		addx.b	d4,d1					;
;o set o+24
;	ENDR								; ( 40 * 4 + 4 ) * 2 * 20 = 164 * 40 = 6560
;	rts


smccode
		move.w	d0,d2		;2			; whole part of the stepx_x		%XXXXXXXX--------	4											move.l	d0,d5		;4
		move.b	d1,d2		;2			; x increment					%XXXXXXXXYYYYYYYY	4											swap	d5			;4
		and.w	d5,d2		;2			; %0UUUUUUUVVVVVVV0				%0XXXXXXXYYYYYYY0	4											and.w	d6,d5		;4
		add.w	d2,d2		;2			;								%XXXXXXXYYYYYYY00	4											move.w	d2,d4		;4
		move.w	d2,o+2(a0)	;4			;12													12											and.w	d7,d4		;4
		add.l	d3,d0		;2			;													8											add.w	d4,d5		;4
		addx.b	d4,d1		;2			;													4	--> 40 * 64 = 2560 						move.w	d5,0(a0)	;12
										;																								add.l	d1,d0		;8
;		move.w	d0,d2		;2			; whole part of the stepx_x		%XXXXXXXX--------												add.w	d3,d2		;4		-> 12 * 4 = 48
;		move.b	d1,d2		;2			; x increment					%XXXXXXXXYYYYYYYY												move.l	d0,d5
;		and.w	d5,d2		;2			; %0UUUUUUUVVVVVVV0				%0XXXXXXXYYYYYYY0												swap	d5
;		add.w	d2,d2		;2			;								%XXXXXXXYYYYYYY00												and.w	d6,d5
;		move.w	d2,o+6(a0)	;4			;12																								move.w	d2,d4
;		add.l	d3,d0		;2			;																								and.w	d7,d4
;		addx.b	d4,d1		;2			;																								and.w	d4,d5
;										;																								move.w	d5,4(a0)
;		move.w	d0,d2		;2			; whole part of the stepx_x		%XXXXXXXX--------
;		move.b	d1,d2		;2			; x increment					%XXXXXXXXYYYYYYYY
;		and.w	d5,d2		;2			; %0UUUUUUUVVVVVVV0				%0XXXXXXXYYYYYYY0
;		add.w	d2,d2		;2			;								%XXXXXXXYYYYYYY00
;		addq.w	#2,d2		;2																							;4 cycles * 16		4*40= 160
;		move.w	d2,o+10(a0)	;4			;12
;		add.l	d3,d0		;2			;	
;		addx.b	d4,d1		;2
;
;		move.w	d0,d2		;2			;	move absolute position to tmp	
;		move.b	d1,d2		;2			;	
;		and.w	d5,d2		;2			;
;		add.w	d2,d2		;2			;
;		move.w	d2,o+14(a0)	;4			;
;		add.l	d3,d0		;2			;
;		addx.b	d4,d1		;2			;


generateRotoCode
	lea		smccode,a0
	move.l	rotosmcpointer,a1
	move.l	(a0)+,d0		; move.w	d0,d2	;	move.b	d1,d2
	move.l	(a0)+,d1		; and.w		d5,d2	;	add.w	d2,d2
	move.l	(a0)+,d2		; move.w	d2,x(a0)		offset
	move.l	(a0)+,d3		; add.l		d3,d0	;	addx.b	d4,d1
	move.w	#$5442,d4		; addq.w	#2,d2
	move.w	#2,d5			; offset
	moveq	#0,d6
	move.w	#24,a2
	move.w	#viewport_width_blocks*2-1,d7
.generate
		move.w	d6,d5
		addq.w	#2,d5
		; first; off = 2
		move.l	d0,(a1)+
		move.l	d1,(a1)+
		move.l	d2,(a1)+
		move.w	d5,-2(a1)
		move.l	d3,(a1)+
		; off = off + 4
		addq.w	#4,d5
		; second
		move.l	d0,(a1)+
		move.l	d1,(a1)+
		move.l	d2,(a1)+
		move.w	d5,-2(a1)
		move.l	d3,(a1)+
		; off = off + 4
		addq.w	#4,d5
		; third
		move.l	d0,(a1)+
		move.l	d1,(a1)+
		move.w	d4,(a1)+	; addq.w	#2,d2
		move.l	d2,(a1)+
		move.w	d5,-2(a1)
		move.l	d3,(a1)+
		; off = off +4
		addq.w	#4,d5
		; forth
		move.l	d0,(a1)+
		move.l	d1,(a1)+
		move.l	d2,(a1)+
		move.w	d5,-2(a1)
		move.l	d3,(a1)+
		; next!
		add.w	a2,d6
	dbra	d7,.generate
	move.w	#$4E75,(a1)+
	rts


_zoomtimes	dc.w	1

musicvbl
	addq.w	#1,$466
	rte


center_pos
	dc.w	$8000
	dc.w	$8000

v_int_pos
	dc.w	0
uv_pos
	dc.l	0
v_int_inc
	dc.w	0
uv_inc
	dc.l	0	
org_offset
	dc.w	0



doC2P
	move.l	screenpointer2,a0
	move.l	a0,a6
	move.l	text1pointer,a1
	add.l	#$10000,a1
	move.l	a1,d3
	move.l	d3,a2
	add.l	#$20000,a2
	move.l	a2,usp
	move.l	#viewport_height_lines-1,d7
	move.l	#$7ffe,d6

	move.w	v_int_pos(pc),d1												;12
	move.w	v_int_inc(pc),d2												;16
	move.l	uv_pos(pc),d4												;16
	move.l	uv_inc(pc),a4												;20
	move.w	org_offset(pc),a5											;12

	; d0 	local paint var
	; d1	y int pos
	; 
	; 1kb code
c2ploop
o	SET 0
		REPT 	viewport_width_blocks	
			move.l	1234(a1),d0			;16
			add.w	1234(a2),d0			;12
			add.w	1234(a2),d0			;12
			add.b	1234(a2),d0			;12
			move.l	d0,a3				;4
			move.l	(a3),d0				;12
			movep.l	d0,o(a0)			;24		-> 92	
	
			move.l	1234(a1),d0			
			add.w	1234(a2),d0
			add.w	1234(a2),d0
			add.b	1234(a2),d0
			move.l	d0,a3
			move.l	(a3),d0
			movep.l	d0,o+1(a0)			;*2 => 184			==> 20*184 = 3680
o			SET 	o+8
		ENDR

		lea		320(a0),a0																		;8
		add.l	a4,d4				; change absolute starting point by +1 `line' increment		;8			add uv inc to uv position
		addx.b	d2,d1				; add integer y-int plus overflow to y-position				;4			y	integer add to y position
		move.w	d4,d0				; make absolute starting point tmp var						;4			move uv position to temp
		move.b	d1,d0				; move in the lower byte									;4			move y position to temp
		and.w	d6,d0				; mask out													;4			zero out the bytes

		move.w	a5,d5																			;4			
		sub.w	d0,d5				; d5.w=offset from org offset ;)							;4
		add.w	d5,d5																			;4

		move.l	d3,a1																			;4
		add.w	d5,a1																			;8
		move.l	usp,a2																			;4
		add.w	d5,a2																			;8 ---> 17 * 4 = 68 
	dbra	d7,c2ploop																			; ( 16 + 68 + 3680 ) * 100 = 376400

	move.l	doublescanlinespointer,a0
	jmp		(a0)
	; 4 kb frames
;	REPT viewport_height_lines
;	ENDR
;	rts


cp
		movem.l	(a6)+,d0-d7/a0-a5				;56					124		;4
		movem.l	d0-d7/a0-a5,160-56(a6)			;					124		;6
		movem.l	(a6)+,d0-d7/a0-a5				;112				124		;4
		movem.l	d0-d7/a0-a5,160-56(a6)			;					124		;6
		movem.l	(a6)+,d0-d7/a0-a3				;48					108		;4
		movem.l	d0-d7/a0-a3,160-48(a6)			;					108		;6	-> 4*124 + 2*108 + 8 = 496 + 216 + 8 = 720 cycles per line 720 * 100 = 72000
		lea		160(a6),a6							;					8	;4




generateDoubleScanlines
		move.l	doublescanlinespointer,a1
		move.w	#viewport_height_lines-1,d7
		movem.l	cp,d0-d6/a0		;32
		move.w	cp+32,a2
.copy
			movem.l	d0-d6/a0,(a1)
			add.w	#32,a1
			move.w	a2,(a1)+
		dbra	d7,.copy
		move.w	#$4e75,(a1)+
		rts




_textureTablesDone	dc.w	0

generateTextureTables
	tst.w	_textureTablesDone
	bne		.done
	move.l	chunkytextpointer,a0
	move.l	text1pointer,a1
	move.l	a1,a3
	add.l	#$10000,a3
	move.l	text2pointer,a2
	move.l	a2,a4
	add.l	#$10000,a4
	move.l	c2plookuptablepointer,d1

	move.w	#2048-1,d7
.loop
	REPT 8
		moveq	#0,d0				;4
		move.b	(a0)+,d0			;8
		lsl.w	#6,d0				;20
		move.w	d0,d2				;4
		lsl.w	#4,d0				;16
		move.w	d0,(a2)+			;8
		move.w	d0,(a4)+			;8	
		move.w	d2,(a2)+			;8
		move.w	d2,(a4)+			;8
		lsl.l	#4,d0				;16
		add.l	d1,d0				;8
		move.l	d0,(a1)+			;12
		move.l	d0,(a3)+			;12				--> 16		-> 4*64kb
	ENDR
	dbra	d7,.loop
	move.w	#-1,_textureTablesDone
.done
	rts

offderp	dc.l	0




;updateTexture
;	move.l	offderp,d6
;	cmp.l	#65536,d6
;	beq		.done
;
;	move.l	chunkytextpointer2,a0
;	move.l	c2plookuptablepointer,d1
;	move.l	text1pointer,a1
;	move.l	a1,a3
;	add.l	#$10000,a3
;	move.l	text2pointer,a2
;	move.l	a2,a4
;	add.l	#$10000,a4
;
;	add.l	d6,a1
;	add.l	d6,a3
;	add.l	d6,a2
;	add.l	d6,a4
;	move.l	d6,d5
;	lsr.l	#2,d5
;	add.l	d5,a0
;
;	REPT 32
;		moveq	#0,d0				;4
;		move.b	(a0)+,d0			;8
;		lsl.w	#6,d0				;20
;		move.w	d0,2(a2)			;12
;		move.w	d0,2(a4)			;12
;		lsl.w	#4,d0				;16
;		move.w	d0,(a2)				;8
;		move.w	d0,(a4)				;8	
;		add.w	#4,a2				;8
;		add.w	#4,a4				;8
;		lsl.l	#4,d0				;16
;		add.l	d1,d0				;8
;		move.l	d0,(a1)+			;12
;		move.l	d0,(a3)+			;12		-> 152		
;	ENDR
;
;	add.l	#32*4,offderp
;.done
;	rts


;_waitTimer	dc.w	120

;updateTexture2
;	subq.w	#1,_waitTimer
;	bgt		.ok
;	move.l	text1pointer,a0
;	move.l	a0,a1
;	add.l	#$10000,a1
;	move.l	text2pointer,a2
;	move.l	a2,a3
;	add.l	#$10000,a3
;	move.l	alignpointer14,a4
;	move.l	alignpointer15,a5
;
;	move.l	offderp,d0
;	cmp.l	#65536,d0
;	bge		.ok
;	add.l	d0,a0
;	add.l	d0,a1
;	add.l	d0,a2
;	add.l	d0,a3
;	add.l	d0,a4
;	add.l	d0,a5
;o set 0
;	REPT 8*2
;		movem.l	(a4)+,d1-d7/a6				;76
;		movem.l	d1-d7/a6,o(a0)				;72
;		movem.l	d1-d7/a6,o(a1)				;72
;
;		movem.l	(a5)+,d1-d7/a6				;76
;		movem.l	d1-d7/a6,o(a2)				;72
;		movem.l	d1-d7/a6,o(a3)				;72		--> 440 ==> 110 nops
;o set o+8*4
;	ENDR
;		add.l	#8*4*8*2,d0						;
;	move.l	d0,offderp
;.ok
;	rts
;0006C05D




_c2plookupDone	dc.w	0
generateC2PLookupTable
	tst.w	_c2plookupDone
	bne		.done
	move.l	c2plookuptablepointer,a4		;	-> 16*16*16*16*4	= 262144	=	 4*64kb
.loop
	lea		TAB1,a3
	move.l	#16-1,d7
.l4
		lea		TAB2,a2
		move.l	#16-1,d6
		move.l	(a3)+,d3
.l3
			lea		TAB3,a1
			move.l	#16-1,d5
			move.l	(a2)+,d2
.l2
				lea		TAB4,a0
				move.l	(a1)+,d1
;				move.l	#16-1,d4
;.l1
				REPT 16
					move.l	(a0)+,d0
					add.l	d1,d0
					add.l	d2,d0
					add.l	d3,d0
					move.l	d0,(a4)+
;					move.l	d0,(a5)+
				ENDR
;				dbra	d4,.l1
			dbra	d5,.l2
		dbra	d6,.l3
	dbra	d7,.l4
	move.w	#-1,_c2plookupDone
.done
	rts



;prepCredits
;	lea		credits+34,a0
;	lea		credits_code,a1
;	move.w	#28-1,d7
;.ol
;x set 0
;		REPT 10
;			move.l	x(a0),(a1)+
;			move.l	x+4(a0),(a1)+
;x set x+8
;		ENDR
;		add.w	#160,a0
;	dbra	d7,.ol
;	lea		credits_code,a0
;	move.b	#0,$ffffc123
;
;
;	lea		credits+34+31*160,a0
;	lea		credits_gfx,a1
;	move.w	#28-1,d7
;.ol2
;x set 0
;		REPT 10
;			move.l	x(a0),(a1)+
;			move.l	x+4(a0),(a1)+
;x set x+8
;		ENDR
;		add.l	#160,a0
;	dbra	d7,.ol2
;	lea		credits_gfx,a0
;	move.b	#0,$ffffc123
;
;
;
;	lea		credits+34+66*160,a0
;	lea		credits_msx,a1
;	move.w	#28-1,d7
;.ol3
;x set 0
;		REPT 10
;			move.l	x(a0),(a1)+
;			move.l	x+4(a0),(a1)+
;x set x+8
;		ENDR
;		add.w	#160,a0
;		dbra	d7,.ol3
;	lea		credits_msx,a0
;	move.b	#0,$ffffc123
;
;	rts
;
;credits	incbin	fx/rotoz/credits_f.pi1
;credits_code				ds.b	10*8*30		; 2400	
;credits_gfx					ds.b	10*8*30
;credits_msx					ds.b	10*8*30



credits_list
	dc.l	credits_msx
	dc.l	credits_gfx
	dc.l	credits_code
	dc.l	credits_gfx_add


cred_step		dc.w	26*80
credits_offset	dc.w	0
_creditScreens	dc.w	3
_credActive		dc.w	0


; copy requires:
;	4*3 = 12 effect frames

copyCredits
	tst.w	_credActive
	bne		.ok
	lea		credits_list,a0
	add.w	credits_offset,a0
	move.l	(a0),a0
	move.l	screenpointer2,a1
	add.l	#32480,a1

	move.w	cred_step,d0			; we need *80
	
	add.w	d0,a0
	add.w	d0,d0
	add.w	d0,a1

y set 40
	REPT 2			; now need 10 blocks of 8 bytes = 20 registers
		movem.l	(a0)+,d0-d7/a2-a3			;  10			92			80 byes oper
		movem.l	d0-d7/a2-a3,y(a1)			;				92
		movem.l	(a0)+,d0-d7/a2-a3			;  10			92		
		movem.l	d0-d7/a2-a3,y+40(a1)		;				92			--> 4*92 = 368 * 9 = 
y set y+160
	ENDR

	subq.w	#1,_creditScreens
	bne		.ok
		move.w	#3,_creditScreens
		sub.w	#80*2,cred_step
		bgt		.ok
			REPT 10
				or.l	d7,d7
			ENDR
			move.w	#26*80,cred_step
			add.w	#4,credits_offset
			move.w	#-1,_credActive
			cmp.w	#16,credits_offset
			bne		.ok
				move.w	#0,credits_offset
.ok
	rts
	
planarToChunky
	move.l	#128-1,d6
.height
	move.l	#8-1,d7
.width
	movem.w	(a0)+,d0-d3		; 4 words
	REPT 16
		moveq	#0,d4
		moveq	#0,d5
		roxl.w	d5
		roxl.w	d3
		roxl.w	d4
		roxl.w	d2
		roxl.w	d4
		roxl.w	d1
		roxl.w	d4
		roxl.w	d0
		roxl.w	d4
		move.b	d4,(a1)+					; 128 * 8 * 16 = 16k
	ENDR
	dbra	d7,.width

	; 320 width is 160 bytes
	; 128 width is 64 bytes
	; 160-64 added
;	add.w	#160-64,a0
	dbra	d6,.height
	rts


	SECTION DATA

cred_spkr			include		"fx/rotoz/spkrf"				;	4752
cred_mod			include		"fx/rotoz/modf"					;	7050
cred_505			include		"fx/rotoz/505f"					;	7746
cred_ukko			include		"fx/rotoz/ukkof"				;	4704
credits_code		incbin		"fx/rotoz/credits_codef.bin"	;	2880
credits_gfx			incbin		"fx/rotoz/credits_gfxf.bin"		;	2880
credits_gfx_add		incbin		"fx/rotoz/credits_gfxf2.bin"		;	2880
credits_msx			incbin		"fx/rotoz/credits_msxf.bin"		;	2880


sine_tbl3:
	include	lib/rotation/sintable_amp32768_steps2048.s	;

TAB1:
    DC.B $00,$00,$00,$00		;0
    DC.B $C0,$00,$00,$00		;4
    DC.B $00,$C0,$00,$00		;8
    DC.B $C0,$C0,$00,$00		;12
    DC.B $00,$00,$C0,$00		;16
    DC.B $C0,$00,$C0,$00		;20
    DC.B $00,$C0,$C0,$00		;24
    DC.B $C0,$C0,$C0,$00		;28
    DC.B $00,$00,$00,$C0		;32
    DC.B $C0,$00,$00,$C0		;36
    DC.B $00,$C0,$00,$C0		;40
    DC.B $C0,$C0,$00,$C0		;44
    DC.B $00,$00,$C0,$C0		;48
    DC.B $C0,$00,$C0,$C0		;52
    DC.B $00,$C0,$C0,$C0		;56
    DC.B $C0,$C0,$C0,$C0		;60
TAB2:
    DC.B $00,$00,$00,$00		;0
    DC.B $30,$00,$00,$00		;4
    DC.B $00,$30,$00,$00		;8
    DC.B $30,$30,$00,$00		;12
    DC.B $00,$00,$30,$00		;16
    DC.B $30,$00,$30,$00		;20
    DC.B $00,$30,$30,$00		;24
    DC.B $30,$30,$30,$00		;28
    DC.B $00,$00,$00,$30		;32
    DC.B $30,$00,$00,$30		;36
    DC.B $00,$30,$00,$30		;40
    DC.B $30,$30,$00,$30		;44
    DC.B $00,$00,$30,$30		;48
    DC.B $30,$00,$30,$30		;52
    DC.B $00,$30,$30,$30		;56
    DC.B $30,$30,$30,$30		;60
TAB3:
    DC.B $00,$00,$00,$00		;0
    DC.B $0C,$00,$00,$00		;4
    DC.B $00,$0C,$00,$00		;8
    DC.B $0C,$0C,$00,$00		;12
    DC.B $00,$00,$0C,$00		;16
    DC.B $0C,$00,$0C,$00		;20
    DC.B $00,$0C,$0C,$00		;24
    DC.B $0C,$0C,$0C,$00		;28
    DC.B $00,$00,$00,$0C		;32
    DC.B $0C,$00,$00,$0C		;36
    DC.B $00,$0C,$00,$0C		;40
    DC.B $0C,$0C,$00,$0C		;44
    DC.B $00,$00,$0C,$0C		;48
    DC.B $0C,$00,$0C,$0C		;52
    DC.B $00,$0C,$0C,$0C		;56
    DC.B $0C,$0C,$0C,$0C		;60
TAB4:
    DC.B $00,$00,$00,$00		;0
    DC.B $03,$00,$00,$00		;4
    DC.B $00,$03,$00,$00		;8
    DC.B $03,$03,$00,$00		;12
    DC.B $00,$00,$03,$00		;16
    DC.B $03,$00,$03,$00		;20
    DC.B $00,$03,$03,$00		;24
    DC.B $03,$03,$03,$00		;28
    DC.B $00,$00,$00,$03		;32
    DC.B $03,$00,$00,$03		;36
    DC.B $00,$03,$00,$03		;40
    DC.B $03,$03,$00,$03		;44
    DC.B $00,$00,$03,$03		;48
    DC.B $03,$00,$03,$03		;52
    DC.B $00,$03,$03,$03		;56
    DC.B $03,$03,$03,$03		;60

palette
	dc.w	$000,$776,$766,$765,$763,$763,$752,$741,$731,$722,$512,$501,$401,$301,$201,$100	;0


	even

	SECTION BSS

	rsreset
chunkytextpointer			ds.l	1
c2plookuptablepointer		ds.l	1
doublescanlinespointer		ds.l	1
rotosmcpointer				ds.l	1
text1pointer				ds.l	1
text2pointer				ds.l	1

	SECTION DATA
