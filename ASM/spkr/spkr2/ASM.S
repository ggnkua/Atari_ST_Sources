vblshow				equ 0
playmusic			equ 1

part0cycles			equ 380
part1cycles			equ 740
part2cycles			equ 2700
part3cycles			equ 350
part4cycles			equ 1250
part5cycles			equ 2901

; ******* MOIRE EFFECT *******
moireblocks 		equ 20	; should me MOD 2
moireoffset 		equ 40+(20-moireblocks)*2
morenegativeoffset 	equ -80-moireblocks*2
moirecolorinterval	equ 6 ;6

pathoffset			equ 8
pathlength			equ pathoffset*400		;8x for offset

; ********** CUBE ************
number_of_vertices 	equ 8	;

; ********* CHECKER ***********
checkerposition		equ 464


; ********* SPRITES ************
spriteHeight 		equ 16
spriteWidth 		equ 2
spritePlanes 		equ 3
spriteTotalPlanes	equ 4
spriteYOff			equ 2*spriteWidth*spriteTotalPlanes-spritePlanes*2 ; 
screenYOff			equ 160-2*spritePlanes
spriteSize			equ spriteHeight*spriteTotalPlanes*2*2 ; 16*4*2*2
						; 16 pix 4 blp = 8 bytes, we have 32 pix => 16 bytes
						; 16 lines of pixels => 16*16=256
spriteSourceOffset  equ 2

; ******** STARFIELD *******
number_of_stars 	equ 200	 ;should be divded by 8
; ******* SCROLLER ***********
scrolleroffset		equ 26406
scrolleroffset2		equ 6+9*8
scrollerlength		equ 674
font_number_of_char	equ 91
fontrows 			equ 9
fontcolumns			equ 20
fontheight 			equ 28
;fontheight 			equ 22
fontwidth			equ 16
fontheightoffset	equ fontheight*160

    output	.tos
    section	text
	include	files/pushpop.s
   
start:
;................................................................
        move.l  4(sp),a5                ; address to basepage
        move.l  $0c(a5),d0              ; length of text segment
        add.l   $14(a5),d0              ; length of data segment
        add.l   $1c(a5),d0              ; length of bss segment
        add.l   #$1000,d0               ; length of stackpointer
        add.l   #$100,d0                ; length of basepage
        move.l  a5,d1                   ; address to basepage
        add.l   d0,d1                   ; end of program
        and.l   #-2,d1                  ; make address even
        move.l  d1,sp                   ; new stackspace
        move.l  d0,-(sp)                ; mshrink()
        move.l  a5,-(sp)                ;
        move.w  d0,-(sp)                ;
        move.w  #$4a,-(sp)              ;
        trap    #1                      ;
        lea     12(sp),sp               ;

	pea 	demo
	move.w	#$26,-(sp)
	trap	#14
	addq.l	#6,sp
	
	clr.w	-(sp)
	trap	#1    

demo:
    move.b	#1,raster_pos
	; save the old screen address
	lea	save_screenadr,a0    		;  the address of where to be saved
	move.b	$ffff8201.w,(a0)+		; move data in
	move.b	$ffff8203.w,(a0)+
	move.b	$ffff820d.w,(a0)+
	
	; save the palette
	movem.l $ffff8240.w,d0-d7		; load the palette bites into data regs
	movem.l	d0-d7,save_pal			; move the data to the pointed address
	
	;align new screen address
	move.l	#screen1+256,d0
	clr.b	d0
	move.l	d0,screenpointer
	lsr.w	#8,d0
	move.l	d0,screenpointershifter

	move.l	d0,$ffff8200.w

	;align new screen address for double buffer
	move.l  #screen2+256,d0
	clr.b	d0
	move.l	d0,screenpointer2
	lsr.w	#8,d0
	move.l	d0,screenpointer2shifter
	
	;save old resolution
	move.b	$ffff8260.w,save_res    ; save old
	clr.b	$ffff8260.w				; set low res

	jsr init_timerb

	;now kill all stuff and set up hbl and vbl
	IFNE playmusic
		jsr 	music+0	
	ENDC
	

	
;;;;; SETUP COMPLETE, NOW DO INIT			
	lea 	artscreen1+4,a0
	movem.l	(a0),d0-d7
	movem.l d0-d7,$ffff8240

	lea		artscreen1+128,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
	jsr		copy666

	jsr	init_fontmap
	jsr init_preshiftFont
	jsr	initstar
	jsr initSprite
	jsr initmoire
			
	;--------------------- BEGIN DEMO MAINLOOP -------------------
	jmp	.waitloop

.startover
	lea 	artscreen1+4,a0
	movem.l	(a0),d0-d7
	movem.l d0-d7,$ffff8240

	lea		artscreen1+128,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
	jsr		copy666
	move.w	#0,democounter			
	move.w	#0,scrollerVsource
	
.waitloop
	jsr	waitforvbl
	addq.w	#1,democounter
	cmp.w	#part0cycles,democounter
	beq		.mainloop1init

	;---- BEGIN SPACEBAR PRESS FOR EXIT ----
	cmp.b 	#$39,$fffffc02.w
	bne		.waitloop
	;----- END --------------------------------------------

	jsr		restore_all

.mainloop1init
	jsr		clearscreen
	jsr 	initcube	
	
	lea 	moireraster,a0
	move.l	(a0),$ff8240
	move.w	2(a0),$ff8250
	move.l	4(a0),$ff8244
	move.w	6(a0),$ff8254			
		
	move.l 	#moire_vbl,a0
	move.l 	#default_timer_b,a1
	jsr 	install_vbl_hbl

	move.w	#0,democounter
.mainloop1
	jsr waitforvbl

	addq.w	#1,democounter
	cmp.w	#part1cycles,democounter
	beq		.mainloop2init

	jsr		swapscreens				; dont use jmp when it returns with rts, use branch then
	
	IFNE vblshow
		move.w #$000,$ffff8240
	ENDC
	
	lea		path1,a6
	add.w	pathcounter,a6
	move.l	(a6),d0
	move.l	4(a6),d1
		
	move.l	#0,d2
		
	jsr		doM2SFast
		
	lea		path2,a6
	add.w	pathcounter,a6
	move.l	(a6),d0
	move.l	4(a6),d1			
		
	move.l	#2,d2
	jsr		doM2S

	move.w	pathcounter,d0		
	addq.w	#8,d0
	cmp.w	#pathlength,d0
	blt		.cont1
	move.w	#0,d0		
.cont1
	move.w	d0,pathcounter
	IFNE vblshow
		move.w #$700,$ffff8240
	ENDC	
	; ---- END ----
		
	;---- BEGIN SPACEBAR PRESS FOR EXIT ----
	cmp.b 	#$39,$fffffc02.w
	bne		.mainloop1
	;----- END --------------------------------------------

	jsr		restore_all


.mainloop2init
	jsr		clearscreen	
	
	lea		spritepallete,a5
	movem.l	(a5),d0-d7
	movem.l	d0-d7,$ffff8240
	jsr 	copychecker
	lea		checker,a0

	move.l 	#default_vbl,a0
	move.l 	#checker_hbl,a1
	jsr 	install_vbl_hbl		

	move.w	#0,democounter	
.mainloop2:
	jsr waitforvbl

	addq.w	#1,democounter
	cmp.w	#part2cycles,democounter
	beq		.mainloop3init

	IFNE vblshow
		move.w #$000,$ffff8240
	ENDC
	
	jsr		swapscreens				; dont use jmp when it returns with rts, use branch then
	
	jsr		docheckercolorsNEW
	move.w	spritepallete+4,$ffff8244.w		;color 2
	move.w	spritepallete+12,$ffff8252.w	;color 6
	move.w	spritepallete+14,$ffff8254.w	;color 7

	jsr	doscroller
	cmp.w	#1180,democounter
	blt		.nocube
	jsr 	doCube2
.nocube
	jsr	 	movestars
	
	IFNE vblshow
		move.w #$700,$ffff8240
	ENDC	
	; ---- END ----
		
	;---- BEGIN SPACEBAR PRESS FOR EXIT ----
	cmp.b 	#$39,$fffffc02.w
	bne		.mainloop2
	;----- END --------------------------------------------

	jsr		restore_all
	
.mainloop3init:
	jsr		clearscreen
	move.l 	#default_vbl,a0
	move.l 	#default_timer_b,a1
	jsr 	install_vbl_hbl

	lea 	artscreen2+4,a0
	movem.l	(a0),d0-d7
	movem.l d0-d7,$ffff8240

	lea		artscreen2+128,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
	
	move.w	#0,democounter			
.mainloop3:	
	
	jsr waitforvbl

	addq.w	#1,democounter
	cmp.w	#part3cycles,democounter
	beq		.mainloop4init	
	
	;---- BEGIN SPACEBAR PRESS FOR EXIT ----
	cmp.b 	#$39,$fffffc02.w
	bne		.mainloop3
	;----- END --------------------------------------------

	bra		restore_all	
	
.mainloop4init
	jsr		clearscreen

	lea 	moireraster,a0
	move.w	#16,d0

	move.l	(a0,d0),$ff8240
	move.l	4(a0,d0),$ff8244
	move.w	2(a0,d0),$ff8250
	move.w	6(a0,d0),$ff8254
	
		
	move.l 	#moire_vbl2,a0
	move.l 	#default_timer_b,a1
	jsr 	install_vbl_hbl
		
	move.w	#0,democounter				
.mainloop4

	jsr waitforvbl

	addq.w	#1,democounter
	cmp.w	#part4cycles,democounter
	beq		.mainloop5init
	
	jsr		swapscreens				; dont use jmp when it returns with rts, use branch then
	
	IFNE vblshow
		move.w #$000,$ffff8240
	ENDC
	
	lea		path1,a6
	add.w	pathcounter,a6
	move.l	(a6),d0
	move.l	4(a6),d1
		
	move.l	#0,d2

	jsr		doM2SFastDistort
					
	lea		path2,a6
	add.w	pathcounter,a6
	move.l	(a6),d0
	move.l	4(a6),d1			
		
	move.l	#2,d2
	jsr		doM2S
	
	move.w	pathcounter,d0		
	add.w	#8,d0
	cmp.w	#pathlength,d0
	blt		.cont4
	move.w	#0,d0
			
.cont4
	move.w	d0,pathcounter
	IFNE vblshow
		move.w #$700,$ffff8240
	ENDC	
	; ---- END ----
		
	;---- BEGIN SPACEBAR PRESS FOR EXIT ----
	cmp.b 	#$39,$fffffc02.w
	bne		.mainloop4
	;----- END --------------------------------------------

	bra		restore_all

.mainloop5init
	move.l 	#default_vbl,a0
	move.l 	#default_timer_b,a1
	jsr 	install_vbl_hbl

	lea 	artscreen3+4,a0
	movem.l	(a0),d0-d7
	movem.l d0-d7,$ffff8240
	
	lea		artscreen3+128,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
	jsr		copy666

	jsr initcube2
	move.w	#0,democounter	
		
.mainloop5
	jsr waitforvbl		
	jsr	swapscreens		

	IFNE vblshow
		move.w #$000,$ffff8240
	ENDC
	
	addq.w	#1,democounter
	cmp.w	#part5cycles,democounter
	bne		.contt
	jsr		.startover
.contt		
	move.w	scrollerVsource,d0
	cmp		#550,d0
	beq		.doit2
	
	add.w	#1,scrollerVoffset
	cmp		#28,scrollerVoffset
	bne		.doit2
	move.w	#0,scrollerVoffset
	add.w	#11,scrollerVsource
.doit2
	jsr	scrollerV		
	jsr doCube3
	
	IFNE vblshow
		move.w #$700,$ffff8240
	ENDC		

	;---- BEGIN SPACEBAR PRESS FOR EXIT ----
	cmp.b 	#$39,$fffffc02.w
	bne		.mainloop5
	;----- END --------------------------------------------

	bra		restore_all


; ***************************************** END MAINLOOP ************
copy666
o set 0
	REPT 666
		movem.l	(a0)+,d0-d7/a3-a6		; 8+4 = 12 12*4= 48
		movem.l	d0-d7/a3-a6,o(a1)
		movem.l	d0-d7/a3-a6,o(a2)
o set o+48
	ENDR
	movem.l (a0),d0-d7
	movem.l	d0-d7,o(a1)
	movem.l d0-d7,o(a2)	
	rts
	
;;;;;;;;;;;;;;;;;;;;;;;; VBL / DISPLAY CODE ;;;;;;;;;;;;;;;;;;;;;;;;;	
waitforvbl:
.mainloop
	tst.w	vblcount	;waitvbl
	beq.s	.mainloop	;if vblcount is
	clr.w 	vblcount
	
	rts
	
; default_vbl does 
; swapping the sreenpointershifter
; clearing the raster_ofs
; has no hbl
default_vbl:	
	move.l screenpointershifter,$ff8200
	addq.w	#1,vblcount
	clr.w 	raster_ofs
	IFNE	playmusic				
		pushall
		jsr music+8
		popall
	ENDC

	;Start up Timer B each VBL
	move.w	#$2700,sr			;Stop all interrupts
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#1,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	move.w	#$2300,sr			;Interrupts back on

	rte

moire_vbl:	
	move.l screenpointershifter,$ff8200
	IFNE	playmusic				
		pushall
		jsr music+8
		popall
	ENDC		

	addq.w	#1,vblcount
	addq.w	#1,screens
	
	;Start up Timer B each VBL
	move.w	#$2700,sr			;Stop all interrupts
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#1,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	move.w	#$2300,sr			;Interrupts back on

	rte		

moire_vbl2:	
	move.l screenpointershifter,$ff8200
	IFNE	playmusic				
		pushall
		jsr music+8
		popall
	ENDC		

	addq.w	#1,vblcount
	addq.w	#1,screens	
	
	;Start up Timer B each VBL
	move.w	#$2700,sr			;Stop all interrupts
	clr.b	$fffffa1b.w			;Timer B control (stop)
	bset	#0,$fffffa07.w			;Interrupt enable A (Timer B)
	bset	#0,$fffffa13.w			;Interrupt mask A (Timer B)
	move.b	#1,$fffffa21.w			;Timer B data (number of scanlines to next interrupt)
	bclr	#3,$fffffa17.w			;Automatic end of interrupt
	move.b	#8,$fffffa1b.w			;Timer B control (event mode (HBL))
	move.w	#$2300,sr			;Interrupts back on
	rte		
		
vblwait:
	move.l 	d0,-(sp)
	move.w 	vblcount,d0
	
vblwait_loop:
	cmp.w	vblcount,d0
	beq		vblwait_loop
	move.l	(sp)+,d0
	rts

;;;;;;;;;;;; INITIAL SETUP TRIGGER B CODE ;;;;;;;;;;;
;; loads the address of a0 to timer b
init_timerb:
	move.w	#$2700,sr					;Stop all interrupts (using $ means hexidecimal)
	move.l	$70.w,save_vbl				;Save old VBL
	move.l	$68.w,save_hbl				;Save old HBL
	move.l	$134.w,save_ta				;Save old Timer A
	move.l	$120.w,save_tb				;Save old Timer B
	move.l	$114.w,save_tc				;Save old Timer C
	move.l	$110.w,save_td				;Save old Timer D
	move.l	$118.w,save_acia			;Save old ACIA
	move.l	#default_vbl,$70.w					;Install our own VBL
	move.l	#dummy,$68.w				;Install our own HBL (dummy)
	move.l	#dummy,$134.w				;Install our own Timer A (dummy)
	move.l	#default_timer_b,$120.w				;Install our own Timer B
	move.l	#dummy,$114.w				;Install our own Timer C (dummy)
	move.l	#dummy,$110.w				;Install our own Timer D (dummy)
	move.l	#dummy,$118.w				;Install our own ACIA (dummy)
	move.b	$fffffa09.w,save_intb		;Save MFP state for interrupt enable B
	move.b	$fffffa15.w,save_intb_mask	;Save MFP state for interrupt mask B
	clr.b	$fffffa07.w					;Interrupt enable A (Timer-A & B)
	clr.b	$fffffa13.w					;Interrupt mask A (Timer-A & B)
	clr.b	$fffffa09.w					;Interrupt enable B (Timer-C & D)
	clr.b	$fffffa15.w					;Interrupt mask B (Timer-C & D)
	move.w	#$2300,sr					;Interrupts back on
	move.b	#$12,$fffffc02.w			;Kill mouse
	rts

; a0 vbl
; a1 hbl		
install_vbl_hbl:
	move.l	a0,-(sp)						;Save A0
	move.l	a1,-(sp)						;Save A0	
	move.w	#$2700,sr					;Stop all interrupts (using $ means hexidecimal)
	move.l	a0,$70.w					;Install our own VBL
	move.l	a1,$120.w				;Install our own Timer B
	clr.b	$fffffa07.w					;Interrupt enable A (Timer-A & B)
	clr.b	$fffffa13.w					;Interrupt mask A (Timer-A & B)
	clr.b	$fffffa09.w					;Interrupt enable B (Timer-C & D)
	clr.b	$fffffa15.w					;Interrupt mask B (Timer-C & D)
	move.w	#$2300,sr					;Interrupts back on
	move.l	(sp)+,a1
	move.l	(sp)+,a0
	rts
		
default_timer_b:
		rte
		
	; first timer b to fire, installing new count fire part
	; installs timer b
	; I can make this with an argument, that it always installs timer given in data register		
raster_ofs:				ds.w	1
raster_pos:				ds.w	1
	
checker_hbl:
	pusha0
	lea		rastercolors,a0						;12
	add.w	raster_ofs,a0									

	cmp		#checkerposition,raster_ofs				;20
	beq		.initcolor								;8
	bge		.squares								;8
		move.l	(a0),$ffff8240.l		;Set colour ;32
	jmp		.exit
.initcolor
		move.w	#$0752,$ffff8252.w	;color 6
		move.w	#$0752,$ffff8254.w	;color 7
.squares
		move.l	(a0),$ffff8242.l
.exit			
	addq.w	#4,raster_ofs
	popa0
	rte
		
dummy:		
		rte		
		
		
; swaps screens
; TRASHES:	d0
swapscreens:
	move.l	screenpointer,d0
	move.l	screenpointer2,screenpointer
	move.l	d0,screenpointer2
	
	move.l	screenpointershifter,d0
	move.l	screenpointer2shifter,screenpointershifter
	move.l	d0,screenpointer2shifter
	
	move.l	starlocpointer,d0
	move.l	starloc2pointer,starlocpointer
	move.l	d0,starloc2pointer
	
	move.l	cubelocpointer,d0
	move.l	cubeloc2pointer,cubelocpointer
	move.l	d0,cubeloc2pointer
	
	move.l	cubeprojectionpointer,d0
	move.l	cubeprojectionpointer2,cubeprojectionpointer
	move.l	d0,cubeprojectionpointer2
	
	rts

clearscreen:
	moveq.l	#0,d0
	moveq.l	#0,d1
	moveq.l	#0,d2
	moveq.l	#0,d3
	moveq.l	#0,d4
	moveq.l	#0,d5
	moveq.l	#0,d6
	moveq.l	#0,d7
	move.l	d0,a2
	move.l	d0,a3
	move.l	d0,a4
	move.l	d0,a5
	move.l	d0,a6
	move.l	screenpointer2,a0
	move.l	screenpointer,a1
	; longword is 4 bytes, 8*4 bytes = 32 bytes, 1000 keer
	REPT 615
		movem.l	d0-d7/a2-a6,(a0)
		movem.l	d0-d7/a2-a6,(a1)
		add.w	#52,a0
		add.w	#52,a1
	ENDR
	movem.l	d0-d4,(a0)
	movem.l	d0-d4,(a1)
	rts
;;;;;;;;;;;;;;;;;;;; RESTORE ALL REGISTERS CODE ;;;;;;;;;;;;;;;;;;;;;		
restore_all:
	IFNE playmusic
	jsr 	music+4
	move.l	#8*256,d0
  	move.l	#$ffff8800,a1
  	move.l	#3-1,d1
.loop:
  		movep.w	d0,(0,a1)
  		add.w	#256,d0
  	dbra	d1,.loop
	ENDC	
	move.w	#$2700,sr					;Stop all interrupts
	move.l	save_vbl,$70.w				;Restore old VBL
	move.l	save_hbl,$68.w				;Restore old HBL
	move.l	save_ta,$134.w				;Restore old Timer A
	move.l	save_tb,$120.w				;Restore old Timer B
	move.l	save_tc,$114.w				;Restore old Timer C
	move.l	save_td,$110.w				;Restore old Timer D
	move.l	save_acia,$118.w			;Restore old ACIA
	move.b	save_intb,$fffffa09.w		;Restore MFP state for interrupt enable B
	move.b	save_intb_mask,$fffffa15.w	;Restore MFP state for interrupt mask B
	clr.b	$fffffa1b.w					;Timer B control (Stop)
	move.w	#$2300,sr					;Interrupts back on
	nop
	move.b	save_res,$ffff8260.w		;Restore old resolution

	movem.l	save_pal,d0-d7				;Restore old palette
	movem.l	d0-d7,$ffff8240.w			;

	lea		save_screenadr,a0			;Restore old screen address
	move.b	(a0)+,$ffff8201.w			;
	move.b	(a0)+,$ffff8203.w			;
	move.b	(a0)+,$ffff820d.w			;

	move.b	#$8,$fffffc02.w				;Enable mouse
	rts		
	
; initializes the star locations
; 
; TRASHES:	a0,a1
;			d0,d7	
initstar:
	lea		starloc,a0
	lea		starloc2,a1
	move.l	a0,starlocpointer		
	move.l	a1,starloc2pointer
	move.l	screenpointer2,d0
	REPT number_of_stars
		move.l	d0,(a0)+
		move.l	d0,(a1)+		
	ENDR			
	rts

; move the stars according to their speed
; TRASHES:	a0,a1,a2,a3,a4
;			d0,d1,d2,d3,d4,d5,d7		
movestars:	
	moveq.l	#0,d0	; 4 cycles	
	; ----- START CLEAR STARS ------
	move.l	starloc2pointer,a0			; 20 cycles, first clear the star, load its address
	REPT number_of_stars/4
		movem.l (a0)+,a1-a4 
		move.w	d0,(a1)
		move.w	d0,(a2)
		move.w	d0,(a3)
		move.w	d0,(a4)
	ENDR

	; initialize stuff we reuse
	lea		x_block,a3
	lea		mask_add,a4
	lea		starlist,a0					; load address of starlist
	move.l	starloc2pointer,a1			; load the address of the current starloc memory
	move.w	#0,d4
	move.w	#319,d6
	move.l  screenpointer2,d5


reset_star_out_of_screen macro
		cmp.w	d4,d0						; check if we are out of screen
		bgt		.dontreset\@				; if d0 < 319, then dont reset
		move.w	d6,d0						; if d0 >= 320, reset
.dontreset\@
		move.w	d0,-6(a0)						; 16 cycles, x is determined, save it
	endm
		
	; a0 has the address of the current star in the starlist
	; a1 has the address of the current location of the star on the scren	
	REPT number_of_stars
		movem.w	(a0)+,d0-d2
		sub.w	d2,d0						; add speed to the x-position
		reset_star_out_of_screen	
		; determine the x-position where to draw
		move.l	a3,a2						; 4 cycles
		add.w	d0,d0						; 4 cycles, its .w, so the offset address wise is *2		
		add.w	d0,a2						; 4 cycles, then we add to the address, this is 1 byte size, so direct add
		move.w	(a2),d2						; 8 cycles, determine the x+y offset, totalling, this is to be added to the screen memory address				
		add.w	d1,d2						; 4 cycles, add the x-offset to the y-offset for total offset
		;d1,a2 free
		; now we have the memory offset in d3, determine the add_mask
		; mask stored in a4, move to a2
		move.l	a4,a2						; 4 cycles
		add.w	d0,a2						; 8 cycles, use table with offset
		move.w	(a2),d3						; 8 cycles, get the mask value from the table and put it in 6
		; a2 free
		; address of screen is saved in d5
		move.l	d5,a2						; 4 cycles, load screen address				
		add.w	d2,a2						; 8 cycles, add the total offset to the address
		;d2 free
		; a2 now holds the address of the screen where should be read and written to, so this is the place
		; now store this address to the value of a5
		move.l	a2,(a1)+
		or.w	d3,(a2)						; now store back the star on the address	
	ENDR
	rts			
	
init_fontmap:	
	lea		fontmap,a0	; address of fontmap
	moveq.l	#0,d6		; y_offset
	moveq.l	#8,d5
	lea		font+128,a1	; address of font, adding 128 to start with fnt data
	move.l	a1,a2		; a2 for saving
	move.l	#fontrows-1,d7         ; we want to loop 9 times
	; copy the font, 20 characters per row, 9 rows
.loopfont
	move.l	a2,a1      	; reset base address of the font
	add.l	d6,a1       	; add the y-offset to the fontmap
	REPT fontcolumns
	    move.l	a1,(a0)+; put the value of the base of the font in a0
	    add.w	d5,a1	; add teh x-offset of the current column
	endr
	add.l	#fontheightoffset,d6	; put the y-offset in the address of the current fontmap
	dbra	d7,.loopfont
	rts	

doscroller:
	move.w 	text_scroll_offset,d4
	
	move.w	d4,d2
	add.w	d2,d2
	add.w	d2,d2
	
	; trashes: d0,d1,d3 a0,a3,a5 (0)
	;
	move.l	scrollerjumptable(pc,d2.w),a0
	jsr		(a0)
;	jsr		scrollerjumptable(pc,d2.w)

	addq.w	#1,d4	
	cmp.w	#4,d4				; compare fixed value to value in d0
	beq		.resetscrolloffset
	jmp		.cont
.resetscrolloffset
	move.l	#0,d4
	add.w	#1,text_char_offset
	; here we check for end of line of text
	cmp.w	#scrollerlength,text_char_offset
	bne	.cont
	; if its turns out to be a nullbyte, reset the text offset
;	move.b	#0,$ffffc123
	move.w	#0,text_char_offset
.cont
	move.w	d4,text_scroll_offset
	rts
	
scrollerjumptable:
	dc.l		draw_string0
	dc.l		draw_string4
	dc.l		draw_string8
	dc.l		draw_string12


; no inputs
; trashes:	d0,d1
;			a0,a2,a3,a5
draw_string0
	clr.l		d0						;	4
	lea 		text,a0					;	12
	lea 		fontmap,a2				;	12
	add.w		text_char_offset,a0		;	24

	move.l		screenpointer2,a5		; 	20
	add.w		#scrolleroffset,a5		;	8
	;set up values
	moveq.l		#32,d1					;	4
										;		84

	REPT 20
		clr.l	d0						;	4
		move.b	(a0)+,d0				;	8
		sub.b	d1,d0					;	4
		add.w	d0,d0					;	4
		add.w	d0,d0					;	4
		move.l	(a2,d0),a3				; 	20
										;		44
	
	; now we have the memory location of the chosen character in a0
	; now copy 22 lines, only first bitplane to the screen
offset set 0
		REPT fontheight
		move.w	offset(a3),offset(a5)	;	20*22= 440
offset set offset+160
		ENDR
		addq.l	#8,a5					;	8
										;		448+48+84=  580*20 => 11600
	ENDR
										
	rts  
 
; no inputs
; trashes:	d0,d1
;			a0,a2,a3,a5
draw_string4
	clr.l		d0						;	4
	lea 		text,a0					;	12
	add.w		text_char_offset,a0		;	24
	lea 		fontmapPreshift,a2		;	12
	move.l		screenpointer2,a5		;   20 
	add.w		#scrolleroffset,a5		;	8
	moveq.l		#32,d1					;	4
	
	; first character is special!
	clr.l		d0						;	4
	move.b		(a0)+,d0				;	8
	sub.b		d1,d0					;	4
	add.w		d0,d0					;	4
	add.w		d0,d0					;	4
	move.l		(a2,d0),a3				;	20 --> 84+44 = 128
offseta	set 0
offsetb set 0
		REPT fontheight	
offseta set offseta+1					; skip first 4px
		move.b	offseta(a3),offsetb(a5) ;	20*22 = 440
offseta set offseta+1
offsetb set offsetb+1
		move.b	offseta(a3),offsetb(a5) ;	20*22 = 440
offseta set offseta+1
offsetb set offsetb+159
		ENDR	
	addq.l	#8,a5						;	8
										;		880 + 136 => 1016
	
	REPT 19
	clr.l		d0						;	4
	move.b		(a0)+,d0				;	8
	sub.b		d1,d0					;	4
	add.w		d0,d0					;	4
	add.w		d0,d0					;	4
	move.l		(a2,d0),a3				;	20 --> 44  
	
offseta set 0
offsetb set -8
		REPT fontheight
			move.b	(a3)+,d2			;8	; load the first 4 pixels to d2
offsetb set offsetb+1
			or.b	d2,offsetb(a5)		;16
offsetb set offsetb+7
			move.b	(a3)+,offsetb(a5)  	;16
offsetb set offsetb+1 
			move.b	(a3)+,offsetb(a5)	;16
offsetb set offsetb+151
		ENDR							; 56*22 = 1232 => *19= 23408

	addq.l	#8,a5						;	8
	ENDR
	
	clr.l		d0						;	4
	move.b		(a0)+,d0				;	8
	sub.b		d1,d0					;	4
	add.w		d0,d0					;	4
	add.w		d0,d0					;	4
	move.l		(a2,d0),a3				; 	20 --> 44
	
offseta set 0
offsetb set -8
		REPT fontheight
offsetb set offsetb+1
			move.b	offseta(a3),d2		;	12	
			or.b	d2,offsetb(a5)		;	16	
offseta set offseta+3
offsetb set offsetb+159
		ENDR
								;	--> 28*22 = 616 + 48 = 664 ==> 1016+23408+664 => 25066
	rts   

; no inputs
; trashes:	d0,d1,d2
;			a0,a2,a3,a5
draw_string8
	clr.l		d0						;	4
	lea 		text,a0					;	12
	add.w		text_char_offset,a0		;	24
	lea 		fontmap,a2				;	12
	move.l		screenpointer2,a5		;   20
	add.w		#scrolleroffset,a5		;	8
	moveq.l		#32,d1					;	4	--> 84
	
	;;;; FIRST CHARACTER IS SPECIAL
	move.b		(a0)+,d0				;	8
	sub.b		d1,d0					;	4
	add.w		d0,d0					;	4
	add.w		d0,d0					;	4
	move.l		(a2,d0),a3				;	20 --> 44
	
offseta set 1
offsetb set 0
	rept fontheight
	    move.b	offseta(a3),d3			;	12
		move.b	d3,offsetb(a5)			;	8
offseta set offseta+160
offsetb set offsetb+160
	endr								;	--> 20*22 = 440
	
	addq.l	#8,a5						;	8	

										; => 8+440+48+84==> 580
	REPT 19
	clr.l		d0						;	4
	move.b		(a0)+,d0				;	8
	sub.w		d1,d0					;	4
	add.w		d0,d0					;	4
	add.w		d0,d0					;	4
	move.l		(a2,d0),a3				;	20 --> 44
	
offseta set 0
offsetb set -7
		REPT fontheight
			move.b	offseta(a3),offsetb(a5)	;20
offseta set offseta+1	
offsetb set offsetb+7	
			move.b	offseta(a3),offsetb(a5)	;20
offseta set offseta+159
offsetb set offsetb+153
		ENDR							;--> 40*22 = 880
	addq.l	#8,a5						;	8
	ENDR
										; --> 880+8 + 48 => 17784
	
	;;;; LAST CHARACTER IS SPECIAL
	clr.l		d0						;	4
	move.b		(a0)+,d0				;	8
	sub.w		d1,d0					;	4
	add.w		d0,d0					;	4
	add.w		d0,d0					;	4
	move.l		(a2,d0),a3				;	20
	
	
	; now we have the memory location of the chosen character in a0
	; now copy 22 lines, only first bitplane to the screen
offseta set 0
offsetb set -7
	rept fontheight
		move.b	offseta(a3),offsetb(a5)			;20in
offseta set offseta+160
offsetb set offsetb+160
	endr										; 22*20 = 440
												;==> 440+ 48 + 17784 ==> 18272
	rts  
; no inputs
; trashes:	d0,d1,d3
;			a0,a2,a3,a5
draw_string12
	lea 		fontmapPreshift,a2		;	12
	lea 		text,a0					;	12
	add.w		text_char_offset,a0		;	24
	move.l		screenpointer2,a5		; 	20   
	add.w		#scrolleroffset,a5		;	8
	moveq.l		#32,d1					;	4	--> 84

	clr.l		d0						;	4
	move.b		(a0)+,d0				;	8
	sub.w		d1,d0					;	4
	add.w		d0,d0					;	4
	add.w		d0,d0					;	4
	move.l		(a2,d0),a3				;	20
	
offsetb set 0
offseta set 0
	rept fontheight	
offseta set offseta+2
		move.b	offseta(a3),offsetb(a5) 		;	22*20 = 440
offseta set offseta+1
offsetb set offsetb+160
	endr
	
	addq.l	#8,a5						;	8
										;	440 + 48 + 84 ==> 574
	
	REPT 19
	clr.l		d0						;	4
	move.b		(a0)+,d0				;	8
	sub.w		d1,d0					;	4
	add.w		d0,d0					;	4
	add.w		d0,d0					;	4
	move.l		(a2,d0),a3				;	20

;	move.b	#0,$ffffc123
offseta1 set 0
offseta3 set 0
	REPT fontheight
		; first get previous part
		; move.w -8(a1) -------> xxxx 0000 0000 0000
offseta1 set offseta1-8
		move.b	(a3)+,d3				;	8
		or.b	d3,offseta1(a5)			;	16 		
offseta1 set offseta1+1					;			
		move.b	(a3)+,offseta1(a5)		;	16
offseta1 set offseta1+7
		move.b	(a3)+,offseta1(a5)		;	16
offseta1 set offseta1+160				;			
										;--> 56*22 ->1232 + 8 = 1240 			
	ENDR								
	addq.l	#8,a5						;
	
	ENDR								; 1240*19 = 23560
	
	clr.l		d0						;	4
	move.b		(a0)+,d0				;	8
	sub.w		d1,d0					;	4
	add.w		d0,d0					;	4
	add.w		d0,d0					;	4
	move.l		(a2,d0),a3				;	20
	
	; now we have the memory location of the chosen character in a0
	; now copy 22 lines, only first bitplane to the screen
offseta1 set 0
offseta3 set 0
	REPT fontheight
offseta1 set offseta1-8					;			
		move.b	offseta3(a3),d3			;	12 		move.b (a3)+,d3 		; 8
		or.b	d3,offseta1(a5)			;	16 		
offseta3 set offseta3+1
offseta1 set offseta1+1
		move.b	offseta3(a3),offseta1(a5);	20
offseta3 set offseta3+2
offseta1 set offseta1+167
	ENDR								; -> 48*22 = 1056 ===> 574 + 23560 + 1056 = 25190
	
	rts     

; preshift code
init_preshiftFont
	lea		fontmap,a0					; load the address of the fontmap
	lea		fontPreshift,a1				; load address for the destination memory
	
	move.l	#font_number_of_char-1,d7
	move.l	#160,d3
.getoffsetforchar
	move.l	#font_number_of_char-1,d0	; dont modify d7, so move to d0
	sub		d7,d0	; max number of chars minus where we are at now give the actual character in the map:
	add.w	d0,d0	; d0 *= 2
	add.w	d0,d0	; d0 *= 2
	move.l  (a0,d0),a2	; start of the desired character in the font memory is loaded in a3
	move.l	#fontheight-1,d6
.shiftlineofchar
	move.w	(a2),d0						; load the upper byte of data from the address, but we only use first bitplane
										; now we got 	d0: xxxxxxxx ???????? 
   	lsr.w	#4,d0						; 				d0: 0000xxxx xxxx???? 
	move.l	#0,d1						; lets just clear d1 to be sure
	move.w	d0,d1						; move the 4 pixels to d1
	move.b	d1,1(a1)
	lsr.w	#8,d0
	move.w	d0,d1
	move.b	d1,0(a1)


	move.w	(a2),d0
	lsl.w	#8,d0
	lsl.w	#4,d0
	lsr.w	#8,d0
	move.l	#0,d1
	move.b	d0,d1
	move.b	d1,2(a1)
	
	add.l 	d3,a2	; source font has 160 bytes
	add.w	#3,a1	; dest +3

	dbra	d6,.shiftlineofchar			
	dbra	d7,.getoffsetforchar	; when we hit this, a2 will be reset, so the offsets added to it dont care,
	
	move.l	#font_number_of_char-1,d7
	move.l	#3*fontheight,d0
	lea		fontmapPreshift,a0		; this is where I want to write to
	lea		fontPreshift,a1			; this is the base address

.assignFontmap
	move.l	a1,(a0)+
	add.l	d0,a1
	dbra	d7,.assignFontmap
	
	rts

	
;********************** START MOIRE CODE ***************

; prepares the moire preshift code
initmoire:
	lea	moiresource0,a0
	lea moiresource1,a1
	jsr prepareMoireSource
	
	lea	moiresource1,a0
	lea moiresource2,a1
	jsr prepareMoireSource
	
	lea	moiresource2,a0
	lea moiresource3,a1
	jsr prepareMoireSource
	
	lea	moiresource3,a0
	lea moiresource4,a1
	jsr prepareMoireSource
	
	lea	moiresource4,a0
	lea moiresource5,a1
	jsr prepareMoireSource
	
	lea	moiresource5,a0
	lea moiresource6,a1
	jsr prepareMoireSource
	
	lea	moiresource6,a0
	lea moiresource7,a1
	jsr prepareMoireSource
	
	lea	moiresource7,a0
	lea moiresource8,a1
	jsr prepareMoireSource
	
	lea	moiresource8,a0
	lea moiresource9,a1
	jsr prepareMoireSource
	
	lea	moiresource9,a0
	lea moiresource10,a1
	jsr prepareMoireSource	
	
	lea	moiresource10,a0
	lea moiresource11,a1
	jsr prepareMoireSource	
	
	lea	moiresource11,a0
	lea moiresource12,a1
	jsr prepareMoireSource	
	
	lea	moiresource12,a0
	lea moiresource13,a1	
	jsr prepareMoireSource	
	
	lea	moiresource13,a0
	lea moiresource14,a1
	jsr prepareMoireSource		
	
	lea	moiresource14,a0
	lea moiresource15,a1
	jsr prepareMoireSource	

	move.l	#0,pathcounter
	rts
	

	
	
; IN: 	d0 the x offset of the source font
; OUT:	sets a0 with the value of 
load_moire_source_a0_by_d0:
	pushd0
	lea 	moirejmpsource,a6
	add.w	d0,d0
	add.w	d0,d0
	add.w	d0,a6
	move.l	(a6),a0
	popd0
	rts	
	
; a0 address of moire source
; a1 address of the target screen address
; d0 x_offset to source font
; d1 y_offset to source font
doM2S:
;	pushall	
	move.l  #moireoffset,d5	; this is the `rest' of the offeset, since a0 is incremented after moving
	move.l	screenpointer2,a1

	add.l	d2,a1	; take the offset into account

;	bsr		load_moire_source_a0_by_d0

	lea 	moirejmpsource,a6
	add.w	d0,d0
	move.w	d0,d3
	add.w	d0,d0
	add.w	d0,a6
	move.l	(a6),a0

	lea		moire_x,a4
	add.w	(a4,d3),a0

	lea		moire_y,a5
	
	move.w	d1,d2	; save y-offset
	
	add.w	d1,d1
	move.w	(a5,d1.w),d4
	add.w	d4,a0	
	move.w 	#199,d1
	
macro1 macro		
		cmp.w	d1,d2	; check if we reached line 200
		bne .goo\@		; if not, continue
		move.w	#morenegativeoffset,d5
.goo\@	
	endm
			
copyMoireToScreen:
yoffset1 set 0
offseta0 set 0
	REPT 200	; do this 200 times
	macro1
	addq.w	#1,d2	; increase y-offset by one
offset set 0+yoffset1
		REPT moireblocks				; line has 20 blocks
		move.w	(a0)+,offset(a1)		;	16*20 = 320
offset set offset+8
		ENDR


	; now we add 42 + 36
yoffset1 set yoffset1+160
	;add.l	d6,a1
	add.w	d5,a0
	ENDR

;	popall
	rts

; a0 address of moire source
; a1 address of the target screen address
; d0 x_offset to source font
; d1 y_offset to source font
doM2SFast:
;	pushall	

	move.l  #moireoffset,d5	; this is the `rest' of the offeset, since a0 is incremented after moving
	move.l	screenpointer2,a1
	add.l	d2,a1	; take the offset into account

	lea 	moirejmpsource,a6
	add.w	d0,d0
	move.w	d0,d3
	add.w	d0,d0
	add.w	d0,a6
	move.l	(a6),a0

	lea		moire_x,a4
	add.w	(a4,d3),a0
		
	lea		moire_y,a5
	
	move.w	d1,d2	; save y-offset
	
	add.w	d1,d1
	move.w	(a5,d1.w),d4
	add.w	d4,a0			; add y-offset
	move.w 	#199,d1
	
macro1 macro		
		cmp.w	d1,d2	; check if we reached line 200
		bne .goo\@		; if not, continue
		move.l	#morenegativeoffset,d5
.goo\@
	endm

	; use: d1,d2,a0,a1,d5
	; thus: a2,a3,a4,a5,a6
	;		d0,d3,d4,d6,d7
	
yoffset1 set 6
	REPT 200	; do this 200 times
	macro1
	addq.w	#1,d2	; increase y-offset by one
offset set 0+yoffset1
		REPT moireblocks/2				; line has 20 blocks
		move.l	(a0)+,offset(a1)					;a0 has done +, so thats +18*2 = +36		
offset set offset+16
		ENDR
yoffset1 set yoffset1+160
	add.l	d5,a0
	ENDR			; inner: 16*10 =160

;	popall
	rts

; d0 x_offset to source font
; d1 y_offset to source font
; d2 offset to target address
doM2SFastDistort:
	move.l  #moireoffset,d5	; this is the `rest' of the offeset, since a0 is incremented after moving
	move.l	screenpointer2,a1
	move.w	d1,d2				; line offset for counter later on

	lea		moire_y,a5
	add.w	d1,d1
	move.w	(a5,d1.w),d4

	lea		disttable,a5	

	move.w	moiredistortoffset,d1		;16
	cmp.w	#800,d1						;8
	bne		.noreset					;12
	moveq.l	#0,d1
.noreset
	addq.w	#4,d1						;4
	add.w	d1,a5						;8
	move.w	d1,moiredistortoffset		;16

	move.w 	#199,d1				; for comparison to see if we passed the last line

macro1 macro		
		cmp.w	d1,d2	; check if we reached line 200
		bne .goo\@		; if not, continue
		move.w	#-80,a4
.goo\@
	endm

; d0 : x-offset
; d1,d2 taken,			
	moveq.l #0,d5
	move.l #80,a4
	lea moire_x,a2 	
offset set 6
	REPT 200	; do this 200 times			

; somehow, determine what we have for x-distortion
	; get x-offset-distortion
	move.w	(a5)+,d3				; x-distortion offset, absolute
	add.w	d0,d3					; original x-offset added to distortion
	add.w	d3,d3	
	move.w (a2,d3.w),d7	 			; determine the block offset 
	; ***** DETERMINE SOURCE OFFSET
	lea 	moirejmpsource,a6		;4
	add.w	d3,d3
	add.w	d3,a6					;4
	move.l	(a6),a0					;12 address of the moiresource is now in a0
	; then a0 is the new moire source
	; then we should add the y-offset to the source
	add.w	d4,d7		
	add.w	d7,a0				; 8 cycle
	macro1
	addq.w	#1,d2	; increase y-offset by one
	
	; in use: d0,d1,d2,d4
	; free: d3,d5,d6,d7,a2
		REPT moireblocks/2				; line has 20 blocks
			move.l	(a0)+,offset(a1)					;a0 has done +, so thats +18*2 = +36		
offset set offset+16
		ENDR
offset set offset+(20-moireblocks)*8
	; now we add 42 + 36
	add.w	a4,d4
	ENDR
	rts

	
; this routine moves from right to left, from bottom to top
; a0 source moire
; a1 destination moire
prepareMoireSource:
	pushall
	moveq.l	#0,d7				; initialize for clearing the shifting bit
	move.w	#200-1,d5			; we only do 200 because we mirror it
	; for all lines (400), do:	
.loopy	
	
	move.l	a0,a2	; save a0 so we dont modify our actual base address
	move.l	a1,a3	; save a1 so we dont modify our actual base address
	move.w	d5,d4	; save the y-location
	move.w	d5,d6	;
	
	lsl		#4,d6
	move.l	d6,d4
	lsl		#2,d6
	add.w	d6,d4
	; free d6
	
	; now we have y-number in d5
	; each line is 640 px width, each 16xp is 2 byte, so 40 bytes
	;mulu	#80,d4	; multiply the offset by its y-lines	
	; now determine the line offset for a2 and a0
	
	move.w	#20-1,d6	; do the loop 20 times, starting from the 19th word offset
	move.w	d6,d3		; save it so we dont modify it
	add.w	d3,d3		
	add.w	d3,d3		; do the x-offset block*4, ebcause we start at the right, which is +76	
	
	add.w	d4,d3		; add y-offset to x-offset
	
	add.w	d3,a2		; do the total offset to a2
	add.w	d3,a3		; do the total offset to a3
	; nowe we start with the pointers set to the utmost right, an utmost bottom, and we can
	; start moving back and up, the x-counter moves left (d6) (by subtraction trhrough loop),
	; and the y-counter moves up as well
.loopx	

	; for each line
	roxl.l	#1,d7			; make sure the register is cleared
	; 	shift the longword one px; longword is 32 bits, 4 bytes
	;	line is 640 pix, so 80 bytes
	move.l	(a2),d0			;move longword from a2 to d0, and set a2 to the next
	roxl.l	#1,d0			;shift left one place, we start at utmost right, first time we shift 0 in
	move.l	d0,(a3)			;assign the newly 1 bit shifted data into our destination memory	
offset set -4
	rept 19
		move.l	offset(a2),d0			;move longword from a2 to d0, and set a2 to the next
		roxl.l	#1,d0			;shift left one place, we start at utmost right, first time we shift 0 in
		move.l	d0,offset(a3)			;assign the newly 1 bit shifted data into our destination memory
offset set offset-4	
	endr
	; then goto next line
	dbra	d6,.loopx			

	dbra	d5,.loopy
	popall
	rts

text2:
;			 1234567890123
	dc.b	"           "		;1
	dc.b	"           "		;1	
	dc.b	"           "		;1
	dc.b	"           "		;1
	dc.b	"           "		;2
	dc.b	"           "		;3
	dc.b	"           "		;4
	dc.b	"           "		;5
	dc.b	"           "		;6
	dc.b	"           "		;7
	dc.b	"           "		;8
	dc.b	"code:      "		;9
	dc.b	"       spkr"		;10
	dc.b	"balls:     "		;11
	dc.b	"      havoc"		;12
	dc.b	"  (lineout)"		;13
	dc.b	"music:     "		;14
	dc.b	"       tyan"		;15
	dc.b	"     (stax)"		;16
	dc.b    "           "		;17
	dc.b    "           "		;18
	dc.b    "           "		;19
	dc.b    "           "		;20
	dc.b    "           "		;21
	dc.b	"thanks to: "		;22
	dc.b	"  britelite"		;23
	dc.b	"        cyg"		;24
	dc.b	"       dbug"		;25
	dc.b	"     defjam"		;26
	dc.b	"        evl"		;27
	dc.b	"       grey"		;28
	dc.b    "        xia"		;29
	dc.b    "       you!"		;30
	dc.b    "           "		;31
	dc.b    "           "		;32	
	dc.b	"           "		;33
	dc.b    "           "		;34	
	dc.b    "greetings: "		;35
	dc.b	"        505"		;36
	dc.b	"       earx"		;37
	dc.b	"        ggn"		;38
	dc.b	"      gloky"	
	dc.b	"   paranoid"		;39
	dc.b	"       ukko"
	dc.b	"    zerkman"
	dc.b	"           "		;40
	dc.b	"           "		;41
	dc.b	"           "		;42
	dc.b	"           "		;43	
	dc.b	"           "		;44
	dc.b	"           "		;45
	dc.b	" stay cool "		;46
	dc.b	"           "		;47
	dc.b	"   stay    "		;48	
	dc.b	"  atari!   "		;49
	dc.b	"           "		;50
	dc.b	"           "		;51
	dc.b	"           "		;52
	dc.b	"           "		;53
	dc.b	"           "		;54
	dc.b	"           "		;55
	dc.b	"           "		;56
	dc.b	"           "		;26
	dc.b	"           "		;27
	dc.b	"           "		;28
	dc.b	"           "		;29	
	even
text_char_offset2:
	ds.w		1
scrollerVoffset:
	ds.w		1
scrollerVsource
	ds.w		1
	
; input: d2, amount of lines displaced
scrollerV:
	clr.l		d0						;	4
	lea 		text2,a0				;	12
	lea 		fontmap,a2				;	12
	add.w		text_char_offset2,a0	;	24
	add.w		scrollerVsource,a0

	move.l		screenpointer2,a5		; 	20
	add.w		#scrolleroffset2,a5		;	8
	move.l		a5,a4
	;set up values
	moveq.l		#32,d1					;	4
										;		84
	move.l		#fontheight,d7
	move.w		scrollerVoffset,d2	
	move.l		d7,d6
	sub.w		d2,d6
	
	lea			y_block,a3
	add.w		d2,d2
	add.w		d2,a3
	move.w		(a3),d2
	
drawlines macro
.drawline\@
		move.w	(a3),(a6)	;	20*22= 440
		add.l	#160,a3
		add.l	#160,a6	
		dbra	d5,.drawline\@			
	endm	
	
	REPT 11
		clr.l	d0						;	4
		move.b	(a0)+,d0				;	8
		sub.b	d1,d0					;	4
		add.w	d0,d0					;	4
		add.w	d0,d0					;	4
		move.l	(a2,d0),a3				; 	20
		add.w	d2,a3
		move.l	a5,a6
		move.l	d6,d5
		drawlines
		addq.l	#8,a5					;	8
	ENDR	
	sub.l	#88,a5
	move.w	#4480,d3
	sub.w	d2,d3
	add.w	d3,a5
 	

; a4 is position for the screen
	REPT 6
		REPT 11
			clr.l	d0						;	4
			move.b	(a0)+,d0				;	8
			sub.b	d1,d0					;	4
			add.w	d0,d0					;	4
			add.w	d0,d0					;	4
			move.l	(a2,d0),a3				; 	20		
			move.l	a5,a6
			REPT	fontheight
				move.w	(a3),(a6)	;	20*22= 440
				add.l	#160,a3
				add.l	#160,a6	
			ENDR
			addq.l	#8,a5					;	8
		ENDR		
		sub.l	#88,a5
		add.l	#4480,a5
	ENDR
	

drawlines2 macro
.drawline2\@
		move.w	(a3),(a6)	;	20*22= 440
		add.l	#160,a3
		add.l	#160,a6	
		dbra	d5,.drawline2\@			
	endm		
	
		REPT 11
			clr.l	d0						;	4
			move.b	(a0)+,d0				;	8
			sub.b	d1,d0					;	4
			add.w	d0,d0					;	4
			add.w	d0,d0					;	4
			move.l	(a2,d0),a3				; 	20		
			move.l	a5,a6
			move.w	scrollerVoffset,d5
			drawlines2
			addq.l	#8,a5					;	8
		ENDR		
;		sub.l	#88,a5
;		add.l	#4480,a5
	
	rts
		

	
	
	
	
; ************* CUBE CODE ****************
; ************* CUBE CODE ****************
; ************* CUBE CODE ****************

; initializes the cube
; TRASHES:	a0,a1
;			d0,d7	
initcube:
		lea		cubeloc,a0
		lea		cubeloc2,a1
		move.l	a0,cubelocpointer		
		move.l	a1,cubeloc2pointer
		move.l	screenpointer2,d0
		move.l	#0,d1
		move.l	#number_of_vertices-1,d7
		
		lea		cubeprojection,a2
		lea		cubeprojection2,a3
		move.l	a2,cubeprojectionpointer
		move.l	a3,cubeprojectionpointer2
		
.initCubeBuffer
		move.l	d0,(a0)+
		move.l	d0,(a1)+		
		move.w	d1,(a2)+
		move.w	d1,(a2)+
		move.w	d1,(a2)+
		move.w	d1,(a3)+
		move.w	d1,(a3)+
		move.w	d1,(a3)+
		dbra	d7,.initCubeBuffer				
		
		rts
		
initcube2:
		lea		cubeloc,a0
		lea		cubeloc2,a1
		move.l	a0,cubelocpointer		
		move.l	a1,cubeloc2pointer
		move.l	screenpointer2,d0
		move.l	#59,d1
		move.l	#153,d2
		move.l	#number_of_vertices-1,d7
		
		lea		cubeprojection,a2
		lea		cubeprojection2,a3
		move.l	a2,cubeprojectionpointer
		move.l	a3,cubeprojectionpointer2
		
.initCubeBuffer
		move.l	d0,(a0)+
		move.l	d0,(a1)+		
		move.w	d1,(a2)+
		move.w	d2,(a2)+
		move.w	d1,(a2)+
		move.w	d1,(a3)+
		move.w	d2,(a3)+
		move.w	d1,(a3)+
		dbra	d7,.initCubeBuffer				
		
		rts		

; ****************** DEMO CUBE *********************
; ****************** DEMO CUBE *********************
; ****************** DEMO CUBE *********************
doCube2:
	; ----- START CLEAR CUBE VERTICES -----
	lea		cubeprojectionpointer2,a2			;4
	move.l	a2,a4
	move.l	(a2),a1								;12
	moveq.l	#0,d0								;4
	move.l	screenpointer2,a6					;20
offset set 0
	REPT number_of_vertices						;
		move.l	a6,a0							;4
		move.w	offset(a1),d0					;8
offset set offset+2
		move.w	offset(a1),d1					;12
offset set offset-2		
offset set offset+6
		jsr clearSpriteQ3
	ENDR										;*8
	; load the sintable address
	lea		sintable,a0							;4
	; load the costable address
	lea		costable,a1							;4
	; load the counter of the cube
	move.w	cubecounter,d0						;12	
	add.w	#1,d0						;4

	cmp.w	#255,d0								
	bne		.nocounterreset
	moveq.l	#0,d0						;16
.nocounterreset	
	move.w	d0,cubecounter
	move.w	d0,d3
	add.w	d0,d0						; *2 offset long
	move.w	(a0,d0),d1					; sinx
	move.w	(a1,d0),d2					; cosx
	move.w	d3,d0
	add.w	d0,d0						; *2
	add.w	d3,d0						; *3
	add.w	d0,d0
	move.w	(a0,d0),a4					; siny
	move.w	(a1,d0),a5					; cosy

	move.w	d1,a6					; sinz
	move.w	d2,a0					; cosz
	
	
	
	; load the address of the vertices data


	lea		cubeprojectionpointer2,a2			;4
	move.l	(a2),a3								;12
	lea		vertices,a2	
	
	;move.w	#153,a5						;12
	;move.w	#60,a6						;12
	;move.w	#120,a4						;12

	REPT number_of_vertices
		move.w	2(a2),d3		;vert.y		;12				8 if (a2)+
		move.w	d3,d4						;4
		move.w	4(a2),d5		;vert.z		;12				8 if (a2)+
		move.w	d5,d6						;4	;32
		; xy = cosx*y - sinx*z;
 	  	muls	d2,d3						;42
 	  	muls	d1,d5						;42
	   	sub.w	d5,d3						;8
	   	asr.w	#8,d3						;22 d3=xy ;114			
		
		; xz = sinx*y + cosx*z;
		muls	d1,d4						;42
		muls	d2,d6						;42
		add.w	d6,d4						;8
		asr.w	#8,d4						;22 d4=xz ;114

		move.w	(a2),d0			;vert.x		;8  			12 if -4(a2)
		move.w	d0,d6						;4
		move.w	d4,d5						;4	;16
		; yx = siny*xz + cosy*x;		    	
		move.w	a4,d1
		move.w	a5,d2
  		muls	d1,d5						;42
  		muls	d2,d0						;42
  		add.w	d0,d5						;8
		asr.w	#8,d5						;22 d5=yx ; 114
	
		; yz = cosy*xz - siny*x
		; if you dont need z, turn this off
		muls	d2,d4						;42
		muls	d1,d6						;42
		sub.w	d6,d4						;8
		asr.w	#8,d4						;22 d4=z ; 114	
				

		move.w	d5,d0						;4 
		move.w	d3,d6						;4	;8	
		; zx = cosz*yx - sinz*xy;		'
		move.w	a6,d1
		move.w	a0,d2
		muls	d2,d0						;42
		muls	d1,d6						;42
		sub.l	d6,d0						;8
		asr.l	#8,d0						;22 d0=x ;114		

		
		; zy = sinz*yx + cosz*xy;
		muls	d1,d5						;42
		muls	d2,d3						;42
		add.l	d5,d3						;8
		asr.l	#8,d3						;22 d3=y ; 114
		

		
		; 6* 114 + 32 +16 + 8 -> 740
		;***** total: 740
		; now we have x and y, plot!
		; d0=x, d3=y, d4 =z
		;move.b	#0,$ffffc123
				
		; fix focal length
		move.w	#120,d6	
;		move.w	a4,d6			; focallength		;4
		move.w	d6,d7			; d6,d7				;4
		asl.l	#8,d7								;24
		add.w	d4,d6			; d6 = d6+yz (z)	;4
		divs	d6,d7								;138
		ext.l	d7									;4
		
		; d7 is factor focal length
		muls	d7,d0								;50
		muls	d7,d3								;50

		asr.w	#8,d0								;24
		asr.w	#8,d3								;24

		add.w	#153,d0
		add.w	#55,d3
;		add.w	a5,d0								;4
;		add.w	a6,d3								;4
		
		movem.w	d0/d3/d4,(a3)		;; order is important
		
		; add offset to vertices
		addq.w	#6,a2								;8 x,y,z each 2 bytes, 6 bytes total for offset
		addq.w	#6,a3								;8
												;390
	ENDR
	;1130 total

drawZlower0 macro
		cmp.w	#0,d3
		blt		.cont\@
		jsr		drawSpriteQ3
.cont\@
	endm


	move.l	cubeprojectionpointer2,a1
	REPT number_of_vertices
		move.l	screenpointer2,a0
		movem.w	(a1)+,d0/d1/d3			;	24
		drawZlower0		
	ENDR
		
drawZlarger0 macro
		cmp.w	#0,d3
		bge		.cont\@
		jsr		drawSpriteQ3C
.cont\@
	endm

	move.l	cubeprojectionpointer2,a1
	REPT number_of_vertices
		move.l	screenpointer2,a0
		movem.w	(a1)+,d0/d1/d3			;	24
		drawZlarger0		
	ENDR

		

	rts	
	
clearit:
		ds.w	1	
doCube3:
;	move.b	#0,$ffffc123
	; ----- START CLEAR CUBE VERTICES -----
	lea		cubeprojectionpointer2,a2			;4
	move.l	a2,a4
	move.l	(a2),a1								;12
	moveq.l	#0,d0								;4
	move.l	screenpointer2,a6					;20
offset set 0
	REPT number_of_vertices						;
		move.l	a6,a0							;4
		move.w	offset(a1),d0					;8
offset set offset+2
		move.w	offset(a1),d1					;12
offset set offset-2		
offset set offset+6
		jsr clearSpriteQ3
	ENDR										;*8
.doit	
	; load the sintable address
	lea		sintable,a0							;4
	; load the costable address
	lea		costable,a1							;4
	; load the counter of the cube
	move.w	cubecounter,d0						;12	
	add.w	#1,d0						;4

	cmp.w	#255,d0								
	bne		.nocounterreset
	moveq.l	#0,d0						;16
.nocounterreset	
	move.w	d0,cubecounter
	move.w	d0,d3
	add.w	d0,d0						; *2 offset long
	move.w	(a0,d0),d1					; sinx
	move.w	(a1,d0),d2					; cosx
	move.w	d3,d0
	add.w	d0,d0						; *2
;	add.w	d3,d0						; *3
	add.w	d0,d0
	move.w	(a0,d0),a4					; siny
	move.w	(a1,d0),a5					; cosy

	move.w	d1,a6					; sinz
	move.w	d2,a0					; cosz
	
	
	
	; load the address of the vertices data


	lea		cubeprojectionpointer2,a2			;4
	move.l	(a2),a3								;12
	lea		vertices2,a2	
	
	;move.w	#153,a5						;12
	;move.w	#60,a6						;12
	;move.w	#120,a4						;12

	REPT number_of_vertices
		move.w	2(a2),d3		;vert.y		;12				8 if (a2)+
		move.w	d3,d4						;4
		move.w	4(a2),d5		;vert.z		;12				8 if (a2)+
		move.w	d5,d6						;4	;32
		; xy = cosx*y - sinx*z;
 	  	muls	d2,d3						;42
 	  	muls	d1,d5						;42
	   	sub.w	d5,d3						;8
	   	asr.w	#8,d3						;22 d3=xy ;114			
		
		; xz = sinx*y + cosx*z;
		muls	d1,d4						;42
		muls	d2,d6						;42
		add.w	d6,d4						;8
		asr.w	#8,d4						;22 d4=xz ;114

		move.w	(a2),d0			;vert.x		;8  			12 if -4(a2)
		move.w	d0,d6						;4
		move.w	d4,d5						;4	;16
		; yx = siny*xz + cosy*x;		    	
		move.w	a4,d1
		move.w	a5,d2
  		muls	d1,d5						;42
  		muls	d2,d0						;42
  		add.w	d0,d5						;8
		asr.w	#8,d5						;22 d5=yx ; 114
	
		; yz = cosy*xz - siny*x
		; if you dont need z, turn this off
		muls	d2,d4						;42
		muls	d1,d6						;42
		sub.w	d6,d4						;8
		asr.w	#8,d4						;22 d4=z ; 114	
				

		move.w	d5,d0						;4 
		move.w	d3,d6						;4	;8	
		; zx = cosz*yx - sinz*xy;		'
		move.w	a6,d1
		move.w	a0,d2
		muls	d2,d0						;42
		muls	d1,d6						;42
		sub.l	d6,d0						;8
		asr.l	#8,d0						;22 d0=x ;114		

		
		; zy = sinz*yx + cosz*xy;
		muls	d1,d5						;42
		muls	d2,d3						;42
		add.l	d5,d3						;8
		asr.l	#8,d3						;22 d3=y ; 114
		

		
		; 6* 114 + 32 +16 + 8 -> 740
		;***** total: 740
		; now we have x and y, plot!
		; d0=x, d3=y, d4 =z
		;move.b	#0,$ffffc123
				
		; fix focal length
		move.w	#120,d6	
;		move.w	a4,d6			; focallength		;4
		move.w	d6,d7			; d6,d7				;4
		asl.l	#8,d7								;24
		add.w	d4,d6			; d6 = d6+yz (z)	;4
		divs	d6,d7								;138
		ext.l	d7									;4
		
		; d7 is factor focal length
		muls	d7,d0								;50
		muls	d7,d3								;50

		asr.w	#8,d0								;24
		asr.w	#8,d3								;24

		add.w	#59,d0
		add.w	#131,d3
;		add.w	a5,d0								;4
;		add.w	a6,d3								;4
		
		movem.w	d0/d3/d4,(a3)		;; order is important
		
		; add offset to vertices
		addq.w	#6,a2								;8 x,y,z each 2 bytes, 6 bytes total for offset
		addq.w	#6,a3								;8
												;390
	ENDR
	;1130 total

drawZlower0 macro
		cmp.w	#0,d3
		blt		.cont\@
		jsr		drawSpriteQ3
.cont\@
	endm


	move.l	cubeprojectionpointer2,a1
	REPT number_of_vertices
		move.l	screenpointer2,a0
		movem.w	(a1)+,d0/d1/d3			;	24
		drawZlower0		
	ENDR
		
drawZlarger0 macro
		cmp.w	#0,d3
		bge		.cont\@
		jsr		drawSpriteQ3C
.cont\@
	endm

	move.l	cubeprojectionpointer2,a1
	REPT 8
		move.l	screenpointer2,a0
		movem.w	(a1)+,d0/d1/d3			;	24
		drawZlarger0		
	ENDR

		

	rts		
	

;************ SPRITE CODE ******************
initSprite:
	;move.b #0,$ffffc123
	lea	sprite0_0,a0
	lea	sprite0_1,a1
	jsr	prepareSpriteSource

	lea	sprite0_1,a0
	lea	sprite0_2,a1
	jsr	prepareSpriteSource

	lea	sprite0_2,a0
	lea	sprite0_3,a1
	jsr	prepareSpriteSource

	lea	sprite0_3,a0
	lea	sprite0_4,a1
	jsr	prepareSpriteSource

	lea	sprite0_4,a0
	lea	sprite0_5,a1
	jsr	prepareSpriteSource

	lea	sprite0_5,a0
	lea	sprite0_6,a1
	jsr	prepareSpriteSource

	lea	sprite0_6,a0
	lea	sprite0_7,a1
	jsr	prepareSpriteSource

	lea	sprite0_7,a0
	lea	sprite0_8,a1
	jsr	prepareSpriteSource

	lea	sprite0_8,a0
	lea	sprite0_9,a1
	jsr	prepareSpriteSource

	lea	sprite0_9,a0
	lea	sprite0_10,a1
	jsr	prepareSpriteSource

	lea	sprite0_10,a0
	lea	sprite0_11,a1
	jsr	prepareSpriteSource

	lea	sprite0_11,a0
	lea	sprite0_12,a1
	jsr	prepareSpriteSource

	lea	sprite0_12,a0
	lea	sprite0_13,a1
	jsr	prepareSpriteSource

	lea	sprite0_13,a0
	lea	sprite0_14,a1
	jsr	prepareSpriteSource

	lea	sprite0_14,a0
	lea	sprite0_15,a1
	jsr	prepareSpriteSource

	
	; sprite 1
	lea	sprite1_0,a0
	lea	sprite1_1,a1
	jsr	prepareSpriteSource

	lea	sprite1_1,a0
	lea	sprite1_2,a1
	jsr	prepareSpriteSource

	lea	sprite1_2,a0
	lea	sprite1_3,a1
	jsr	prepareSpriteSource

	lea	sprite1_3,a0
	lea	sprite1_4,a1
	jsr	prepareSpriteSource

	lea	sprite1_4,a0
	lea	sprite1_5,a1
	jsr	prepareSpriteSource

	lea	sprite1_5,a0
	lea	sprite1_6,a1
	jsr	prepareSpriteSource

	lea	sprite1_6,a0
	lea	sprite1_7,a1
	jsr	prepareSpriteSource

	lea	sprite1_7,a0
	lea	sprite1_8,a1
	jsr	prepareSpriteSource

	lea	sprite1_8,a0
	lea	sprite1_9,a1
	jsr	prepareSpriteSource

	lea	sprite1_9,a0
	lea	sprite1_10,a1
	jsr	prepareSpriteSource

	lea	sprite1_10,a0
	lea	sprite1_11,a1
	jsr	prepareSpriteSource

	lea	sprite1_11,a0
	lea	sprite1_12,a1
	jsr	prepareSpriteSource

	lea	sprite1_12,a0
	lea	sprite1_13,a1
	jsr	prepareSpriteSource

	lea	sprite1_13,a0
	lea	sprite1_14,a1
	jsr	prepareSpriteSource

	lea	sprite1_14,a0
	lea	sprite1_15,a1
	jsr	prepareSpriteSource	

	; sprite 2
	lea	sprite2_0,a0
	lea	sprite2_1,a1
	jsr	prepareSpriteSource

	lea	sprite2_1,a0
	lea	sprite2_2,a1
	jsr	prepareSpriteSource

	lea	sprite2_2,a0
	lea	sprite2_3,a1
	jsr	prepareSpriteSource

	lea	sprite2_3,a0
	lea	sprite2_4,a1
	jsr	prepareSpriteSource

	lea	sprite2_4,a0
	lea	sprite2_5,a1
	jsr	prepareSpriteSource

	lea	sprite2_5,a0
	lea	sprite2_6,a1
	jsr	prepareSpriteSource

	lea	sprite2_6,a0
	lea	sprite2_7,a1
	jsr	prepareSpriteSource

	lea	sprite2_7,a0
	lea	sprite2_8,a1
	jsr	prepareSpriteSource

	lea	sprite2_8,a0
	lea	sprite2_9,a1
	jsr	prepareSpriteSource

	lea	sprite2_9,a0
	lea	sprite2_10,a1
	jsr	prepareSpriteSource

	lea	sprite2_10,a0
	lea	sprite2_11,a1
	jsr	prepareSpriteSource

	lea	sprite2_11,a0
	lea	sprite2_12,a1
	jsr	prepareSpriteSource

	lea	sprite2_12,a0
	lea	sprite2_13,a1
	jsr	prepareSpriteSource

	lea	sprite2_13,a0
	lea	sprite2_14,a1
	jsr	prepareSpriteSource

	lea	sprite2_14,a0
	lea	sprite2_15,a1
	jsr	prepareSpriteSource	
	
	
	
	; sprite mask
	lea	sprite_mask0,a0
	lea	sprite_mask1,a1
	jsr	prepareSpritemaskSource

	lea	sprite_mask1,a0
	lea	sprite_mask2,a1
	jsr	prepareSpritemaskSource

	lea	sprite_mask2,a0
	lea	sprite_mask3,a1
	jsr	prepareSpritemaskSource

	lea	sprite_mask3,a0
	lea	sprite_mask4,a1
	jsr	prepareSpritemaskSource

	lea	sprite_mask4,a0
	lea	sprite_mask5,a1
	jsr	prepareSpritemaskSource

	lea	sprite_mask5,a0
	lea	sprite_mask6,a1
	jsr	prepareSpritemaskSource

	lea	sprite_mask6,a0
	lea	sprite_mask7,a1
	jsr	prepareSpritemaskSource

	lea	sprite_mask7,a0
	lea	sprite_mask8,a1
	jsr	prepareSpritemaskSource

	lea	sprite_mask8,a0
	lea	sprite_mask9,a1
	jsr	prepareSpritemaskSource

	lea	sprite_mask9,a0
	lea	sprite_mask10,a1
	jsr	prepareSpritemaskSource

	lea	sprite_mask10,a0
	lea	sprite_mask11,a1
	jsr	prepareSpritemaskSource

	lea	sprite_mask11,a0
	lea	sprite_mask12,a1
	jsr	prepareSpritemaskSource

	lea	sprite_mask12,a0
	lea	sprite_mask13,a1
	jsr	prepareSpritemaskSource

	lea	sprite_mask13,a0
	lea	sprite_mask14,a1
	jsr	prepareSpritemaskSource

	lea	sprite_mask14,a0
	lea	sprite_mask15,a1
	jsr	prepareSpritemaskSource	
	
	
	rts
	

; a0 sprite source
; a1 sprite target
prepareSpriteSource:
	move.l	#spriteHeight-1,d7	
	addq.w	#spriteSourceOffset,a0
	addq.w	#spriteSourceOffset,a1
	
.yloop
	move.l	#spritePlanes-1,d6
	moveq.l	#spriteYOff,d1
.doplane
		move.w	(a0),d0
		roxr.w	#1,d0		; shift bit out
		move.w	d0,(a1)
		
		move.w	8(a0),d0
		roxr.w	#1,d0		; shift bit in
		move.w	d0,8(a1)
	
		addq.w	#2,a0
		addq.w	#2,a1
	
		dbra	d6,.doplane

		add.w	d1,a0
		add.w	d1,a1
	dbra	d7,.yloop
	rts

; a0 sprite source
; a1 sprite target
prepareSpritemaskSource:
	move.l	#spriteHeight-1,d7	
	addq.w	#spriteSourceOffset,a0
	addq.w	#spriteSourceOffset,a1
	
.yloop
	move.l	#spritePlanes-1,d6
	moveq.l	#spriteYOff,d1
.doplane
		move.w	#1,d2
		roxr.w	#1,d2
		move.w	(a0),d0
		roxr.w	#1,d0		; shift bit out
		
		move.w	d0,(a1)
		
		move.w	8(a0),d0
		roxr.w	#1,d0		; shift bit in
		move.w	d0,8(a1)
	
		addq.w	#2,a0
		addq.w	#2,a1
	
		dbra	d6,.doplane

		add.w	d1,a0
		add.w	d1,a1
	dbra	d7,.yloop
	rts	


; a0 screen address
; a1 location list
; d0 x
; d1 y
drawSpriteQ3:
	; first determine which source we take, by the x-position
	lea		x_block,a4
	lea		y_block,a2
	add.w	d0,d0
	add.w	d0,a4
	move.w	(a4),d2
	add.w	d1,d1
	add.w	d1,a2
	add.w	(a2),d2
	add.w	d2,a0			; a0 is start position for drawing
	
	; save the a0 to the location list
	;move.l	a0,(a1)+
	; determine the source	
	cmp.w	#-20,d3			; lesser is bigger
	ble		.big
	jmp		.check
.big	
	lea		spritejmpsource0,a2
	jmp		.cont
.check
	cmp.w	#10,d3
	ble		.small
	lea		spritejmpsource2,a2
	jmp		.cont	
.small	
	lea		spritejmpsource1,a2
.cont
	add.w	d0,d0
	add.w	d0,a2
	move.l	(a2),a4
	; source determined, start drawing
offset set 0
offset2 set 0
	REPT spriteHeight		;16x
		; load sprite plane
offset set offset+spriteSourceOffset
offset2 set offset2+spriteSourceOffset			
		move.w	offset2(a4),d0				;12
		or.w	d0,offset(a0)				;16
offset set offset+8	
offset2 set offset2+8	
		move.w	offset2(a4),d0				;12
		or.w	d0,offset(a0)				;16
offset set offset-8		
offset2 set offset2-8

offset set offset-spriteSourceOffset
offset2 set offset2-spriteSourceOffset			

offset set offset+4		
offset2 set offset2+4
		; load sprite plane
		move.l	offset2(a4),d0				;12
		or.l	d0,offset(a0)				;16
offset set offset+8	
offset2 set offset2+8	
		move.l	offset2(a4),d0				;12
		or.l	d0,offset(a0)				;16
offset set offset-8		
offset2 set offset2-8
offset set offset+2		
offset2 set offset2+2


offset set offset+screenYOff
offset2 set offset2+spriteYOff
	ENDR
	rts	


; a0 screen address
; a1 location list
; d0 x
; d1 y
drawSpriteQ3C:
	; first determine which source we take, by the x-position
	lea		x_block,a4
	lea		y_block,a2
	add.w	d0,d0
	add.w	d0,a4
	move.w	(a4),d2
	add.w	d1,d1
	add.w	d1,a2
	add.w	(a2),d2
	add.w	d2,a0			; a0 is start position for drawing
	
	; save the a0 to the location list
	;move.l	a0,(a1)+
	; determine the source	
	cmp.w	#-20,d3			; lesser is bigger
	ble		.big
	jmp		.check
.big	
	lea		spritejmpsource0,a2
	jmp		.cont
.check
	nop
	cmp.w	#10,d3
	ble		.small
	lea		spritejmpsource2,a2
	jmp		.cont	
.small	
	lea		spritejmpsource1,a2
.cont
	add.w	d0,d0
	add.w	d0,a2
	move.l	(a2),a4
	; source determined, start drawing
	lea		spritejmpsourcemask,a3
	add.w	d0,a3
	move.l	(a3),a5

offset set 0
offset2 set 0
	REPT spriteHeight		;16x
		; load sprite plane
offset set offset+spriteSourceOffset
offset2 set offset2+spriteSourceOffset		
offset set offset+2
		move.w	offset2(a4),d0				;12
		move.w	offset2(a5),d1
		and.w	d1,offset(a0)
		or.w	d0,offset(a0)				;16
offset set offset-2
offset set offset-spriteSourceOffset
offset2 set offset2-spriteSourceOffset			
		
offset set offset+8	
offset2 set offset2+8	
offset set offset+2
		move.w	offset2(a4),d0				;12
		move.w	offset2(a5),d1
		and.w	d1,offset(a0)
		or.w	d0,offset(a0)				;16
offset set offset-2		
offset set offset-8		
offset2 set offset2-8
offset set offset+4		
offset2 set offset2+4

		; load sprite plane
		move.l	offset2(a4),d0				;12
		move.l	offset2(a5),d1		
		and.l	d1,offset(a0)
		or.l	d0,offset(a0)				;16
		
		
offset set offset+8	
offset2 set offset2+8	
		move.l	offset2(a4),d0				;12
		move.l	offset2(a5),d1	
		and.l	d1,offset(a0)
		or.l	d0,offset(a0)				;16
		
offset set offset-8		
offset2 set offset2-8
offset set offset+2		
offset2 set offset2+2


offset set offset+screenYOff
offset2 set offset2+spriteYOff
	ENDR
	rts	

; d0, x
; d1, y
; a0, screenpointer
clearSpriteQ3:
;	move.b	#0,$ffffc123
	lea		x_block,a3
	lea		y_block,a5
	add.w	d0,d0
	add.w	d0,a3
	move.w	(a3),d2				; x_off
	add.w	d1,d1
	add.w	d1,a5
	add.w	(a5),d2				; x_off + y_off
	add.w	d2,a0
	moveq.l	#0,d3									;68 cycles that can be optimized, by just using the clear address
offset set 0
	REPT spriteHeight
offset set offset+2
			move.w	d3,offset(a0)
offset set offset+8			
			move.w	d3,offset(a0)
offset set offset-8
offset set offset-2			
offset set offset+4
			move.l	d3,offset(a0)
offset set offset+8			
			move.l	d3,offset(a0)
offset set offset-8			
offset set offset+2
offset set offset+screenYOff
	ENDR
	rts
	
;************ CHECKER BOARD CODE ******************
copychecker:
	lea		checker+128,a0
	move.l	screenpointer,a1
	move.l	screenpointer2,a2
	lea		y_block,a3
	move.l	#112,d0
	add.l	d0,d0	
	add.l	d0,a3
	move.w	(a3),d0
	add.w	d0,a0
	add.w	d0,a1
	add.w	d0,a2
	
offset set 0
	REPT 88
		REPT 20
			move.l	offset(a0),offset(a1)
			move.l	offset(a0),offset(a2)			
offset set offset+8
		ENDR
	ENDR
	rts
	
; 82 lines
docheckercolorsNEW:
	lea		rastercolors,a0
	add.w	#checkerposition,a0
	move.w	checkercolor1,d0
	move.w	checkercolor2,d1
	lea		checkeroffsets,a1
	move.w	checkercounter,d6
	add.w	d6,a1
	
	movem.w	(a1),d2/d3/d4/d5
	
.square0	
	cmp		#0,d2
	beq		.square1
	subq.w	#1,d2
	move.w	d2,d7
.dosquare0
		move.w	d0,(a0)+
		move.w	d1,(a0)+		
	dbra	d7,.dosquare0
	
.square1
	cmp		#0,d3
	beq		.square2
	subq.w	#1,d3
	move.w	d3,d7
.dosquare1
		move.w	d1,(a0)+
		move.w	d0,(a0)+	
	dbra	d7,.dosquare1
	
.square2
	cmp		#0,d4
	beq		.square3
	subq.w	#1,d4
	move.w	d4,d7
.dosquare2
		move.w	d0,(a0)+
		move.w	d1,(a0)+
	dbra	d7,.dosquare2	
	
.square3
	cmp		#0,d5
	beq		.cont
	subq.w	#1,d5
	move.w	d5,d7
.dosquare3
		move.w	d1,(a0)+
		move.w	d0,(a0)+
	dbra	d7,.dosquare3		

.cont
	cmp.w	#312,d6
	bne		.cont2
	move.w	#0,d6
	; and flip colors
	move.w	d0,checkercolor2
	move.w	d1,checkercolor1
	jmp		.end
.cont2
	add.w	#24,d6
.end
	move	d6,checkercounter
	rts

section data

checkeroffsets:
			dc.w	0,13,25,45		;0
			dc.w	0,13,25,45		;1
			dc.w	0,13,27,43		;2
			dc.w	1,13,26,42		;3
			dc.w	1,13,27,42		;4
			dc.w	2,13,28,40		;5
			dc.w	2,13,28,40		;6
			dc.w	2,14,28,39		;7
			dc.w	2,14,29,38		;8
			dc.w	2,15,30,36		;9
			dc.w	3,14,30,36		;10
			dc.w	3,14,32,34		;11
			dc.w	4,14,32,33		;12
			dc.w	4,14,34,31		;13
			dc.w	4,15,33,31		;14
			dc.w	4,15,33,31		;15
			dc.w	5,15,35,28		;16
			dc.w	5,15,35,28		;17
			dc.w	6,16,36,25		;18
			dc.w	6,16,36,25		;19
			dc.w	6,17,38,22		;20
			dc.w	6,17,39,21		;21
			dc.w	6,17,41,19		;22
			dc.w	7,17,41,18		;23
			dc.w	7,18,43,15		;24
			dc.w	8,18,42,15		;25
			dc.w	8,18,43,14		;26
			dc.w	9,19,43,12		;27
			dc.w	9,19,45,10		;28
			dc.w	10,19,46,8		;29
			dc.w	10,19,48,6		;30
			dc.w	10,21,49,3		;31
			dc.w	11,20,50,2		;32
			dc.w	11,20,51,1		;33
			dc.w	12,20,51,0		;34
			dc.w	12,21,50,0		;35
			dc.w	13,21,49,0		;36
			dc.w	13,21,49,0		;37
			dc.w	13,23,47,0		;38
			dc.w	13,23,47,0		;39
			dc.w	13,25,45,0		;40

checkercolor1:
			dc.w	$0404
checkercolor2:
			dc.w	$0203


	include files/sprite0.s

			
disttable:
	include files/distval2.s

vertices:
		dc.w	-25,25,25	;vlb 1
		dc.w	25,25,25	;vrb 2
		dc.w	-25,-25,25	;vlo 3
		dc.w	25,-25,25	;vro 4
		
		dc.w	-25,25,-25	; 5
		dc.w	25,25,-25	; 6
		dc.w	-25,-25,-25	; 7
		dc.w	25,-25,-25	; 8		

vertices2:
		dc.w	-7,7,7	;vlb 1
		dc.w	7,7,7	;vrb 2
		dc.w	-7,-7,7	;vlo 3
		dc.w	7,-7,7	;vro 4
		
		dc.w	-7,7,-7	; 5
		dc.w	7,7,-7	; 6
		dc.w	-7,-7,-7	; 7
		dc.w	7,-7,-7	; 8				
		
	include files/tables2.s

rasters:
		dc.w	$0170,$0200,$0300,$0400,$0500,$0600,$0700,$0701,$0702,$0703 ;18
		dc.w	$0704,$0705,$0704,$0703,$0702,$0701,$0700,$0600,$0500,$0400
		dc.w	$0300,$0200,$0100,$0000,$0000,$0000,$0000,$0000,$0000,$0000
		rept 25
		dc.w	$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000,$0000
        endr
		
mask_add:
		rept 20
		dc.w	$8000,$4000,$2000,$1000
		dc.w	$0800,$0400,$0200,$0100
		dc.w	$0080,$0040,$0020,$0010
		dc.w	$0008,$0004,$0002,$0001
		endr
				
x_block:
val set 0
	REPT 20
		REPT 16
		dc.w	val
		endr
val set val+8		
	endr
	
y_block:
val set 0
	REPT 200
		dc.w	val
val set val+160		
	endr

spritejmpsource0
	REPT 20
		dc.l	sprite0_0
		dc.l	sprite0_1
		dc.l	sprite0_2
		dc.l	sprite0_3
		dc.l	sprite0_4
		dc.l	sprite0_5
		dc.l	sprite0_6
		dc.l	sprite0_7
		dc.l	sprite0_8
		dc.l	sprite0_9
		dc.l	sprite0_10
		dc.l	sprite0_11
		dc.l	sprite0_12
		dc.l	sprite0_13
		dc.l	sprite0_14
		dc.l	sprite0_15
	ENDR

spritejmpsource1
	REPT 20
		dc.l	sprite1_0
		dc.l	sprite1_1
		dc.l	sprite1_2
		dc.l	sprite1_3
		dc.l	sprite1_4
		dc.l	sprite1_5
		dc.l	sprite1_6
		dc.l	sprite1_7
		dc.l	sprite1_8
		dc.l	sprite1_9
		dc.l	sprite1_10
		dc.l	sprite1_11
		dc.l	sprite1_12
		dc.l	sprite1_13
		dc.l	sprite1_14
		dc.l	sprite1_15
	ENDR	
	
spritejmpsource2
	REPT 20
		dc.l	sprite2_0
		dc.l	sprite2_1
		dc.l	sprite2_2
		dc.l	sprite2_3
		dc.l	sprite2_4
		dc.l	sprite2_5
		dc.l	sprite2_6
		dc.l	sprite2_7
		dc.l	sprite2_8
		dc.l	sprite2_9
		dc.l	sprite2_10
		dc.l	sprite2_11
		dc.l	sprite2_12
		dc.l	sprite2_13
		dc.l	sprite2_14
		dc.l	sprite2_15
	ENDR		
	
spritejmpsourcemask
	REPT 20
		dc.l	sprite_mask0
		dc.l	sprite_mask1
		dc.l	sprite_mask2
		dc.l	sprite_mask3
		dc.l	sprite_mask4
		dc.l	sprite_mask5
		dc.l	sprite_mask6
		dc.l	sprite_mask7
		dc.l	sprite_mask8
		dc.l	sprite_mask9
		dc.l	sprite_mask10
		dc.l	sprite_mask11
		dc.l	sprite_mask12
		dc.l	sprite_mask13
		dc.l	sprite_mask14
		dc.l	sprite_mask15
	ENDR	
	
moirejmpsource:
	REPT 40
			dc.l	moiresource0
			dc.l	moiresource1
			dc.l	moiresource2
			dc.l	moiresource3
			dc.l	moiresource4
			dc.l	moiresource5
			dc.l	moiresource6
			dc.l	moiresource7
			dc.l	moiresource8
			dc.l	moiresource9
			dc.l	moiresource10
			dc.l	moiresource11
			dc.l	moiresource12
			dc.l	moiresource13
			dc.l	moiresource14
			dc.l	moiresource15
	ENDR
	
moire_y
offset set 0
	REPT 400
		dc.w	offset
offset set offset+80
	ENDR
	
moire_x
offset set 0
	REPT 20
		REPT 16
			dc.w	offset
		ENDR
offset set offset+2
	ENDR
	
	include files/moirepath.s
	
text:
		dc.b	"                                   well hello there sillyventure! another little demo from me....       "
		dc.b	"since outline 2013 i've come some way....      although still learning the basics, i stuck to the atari st....       "
		dc.b	"so no fancy blitter graphics, dma sounds or funky palette tricks (yet)....       for now just rotating sprites, some rasters and a few stars....       "
		dc.b	"on good advice of #atariscne i stopped messing around with c, and moved on to asm....      "
		dc.b	"and i must say that it made me love the atari even more!     "
		dc.b	"unlike last time, i will not let you gaze at the stars (or my balls) for 3 minutes....      there's one more thing i'd like to show you....       "
		dc.b	"                                                ",0

	even

moireraster:
;	dc.l	$00000004,$00040000
	dc.l	$00000204,$03050000
	dc.l	$00000F0F,$03F30000
	dc.l	$00000205,$02050000
	dc.l	$000000F0,$0F0F0000
	
	include files/stars.s
	even

checker:
	incbin files/CHECKERF.NEO

font:	
	incbin files/belly.neo
	
music:	
	incbin files/revotus.snd
	even
	
	include	files/sprite.s
	even
moiresource0:
	incbin	files/m640x200.bin

artscreen1:
	incbin	files/test2.neo
	
artscreen2:
	incbin	files/SCREEN2.NEO
	
artscreen3:
	incbin	files/ENDSCRE2.NEO	
	
	section bss
democounter				ds.w	1
fontmap:				ds.l	180
fontmapPreshift:		ds.l	180
fontPreshift:			ds.b	91*3*fontheight
raster_dis:				ds.w	1
; raster_ofs:				ds.w	1
; raster_pos:				ds.w	1
screen_pointer			ds.l	1
	even
screenpointer			ds.l	1
screenpointer2			ds.l	1
screenpointershifter	ds.l	1
screenpointer2shifter	ds.l	1
vblcount:				ds.w	1
	even
screen1:				ds.b	32000+256
screen2:				ds.b	32000+256
save_pal:				ds.w	16
save_screenadr:			ds.l	1
save_vbl:				ds.l	1
save_hbl:				ds.l	1
save_ta:				ds.l	1
save_tb:				ds.l	1
save_tc:				ds.l	1
save_td:				ds.l	1
save_acia:				ds.l	1
save_intb:				ds.b	1
save_intb_mask:			ds.b	1
save_res:				ds.b	1
	even
starlocpointer			ds.l	1
starloc2pointer			ds.l	1
starloc:				ds.l	number_of_stars
starloc2:				ds.l	number_of_stars
text_char_offset		ds.w	1
text_scroll_offset		ds.w	1
selected_pixel_rout		ds.l	1
pathcounter				ds.l	1
screens					ds.w	1
moirerasteroffset		ds.w	1
moiredistortoffset		ds.w	1
cubecounter				ds.w	1
cubelocpointer			ds.l	1
cubeloc2pointer			ds.l	1
cubeloc					ds.l	number_of_vertices
cubeloc2				ds.l	number_of_vertices
cubeprojectionpointer	ds.l	1
cubeprojectionpointer2	ds.l	1
cubeprojection			ds.w	3*2*number_of_vertices
cubeprojection2			ds.w	3*2*number_of_vertices
moiresource1			ds.b	16000
moiresource2			ds.b	16000
moiresource3			ds.b	16000
moiresource4			ds.b	16000
moiresource5			ds.b	16000
moiresource6			ds.b	16000
moiresource7			ds.b	16000
moiresource8			ds.b	16000
moiresource9			ds.b	16000
moiresource10			ds.b	16000
moiresource11			ds.b	16000
moiresource12			ds.b	16000
moiresource13			ds.b	16000
moiresource14			ds.b	16000
moiresource15			ds.b	16000
cubesize				ds.w	1
cubedirection			ds.w	1
checkercounter			ds.w	1
sprite0_1				ds.b	spriteSize
sprite0_2				ds.b	spriteSize
sprite0_3				ds.b	spriteSize
sprite0_4				ds.b	spriteSize
sprite0_5				ds.b	spriteSize
sprite0_6				ds.b	spriteSize`
sprite0_7				ds.b	spriteSize
sprite0_8				ds.b	spriteSize
sprite0_9				ds.b	spriteSize
sprite0_10				ds.b	spriteSize
sprite0_11				ds.b	spriteSize
sprite0_12				ds.b	spriteSize
sprite0_13				ds.b	spriteSize
sprite0_14				ds.b	spriteSize
sprite0_15				ds.b	spriteSize
sprite1_1				ds.b	spriteSize
sprite1_2				ds.b	spriteSize
sprite1_3				ds.b	spriteSize
sprite1_4				ds.b	spriteSize
sprite1_5				ds.b	spriteSize
sprite1_6				ds.b	spriteSize
sprite1_7				ds.b	spriteSize
sprite1_8				ds.b	spriteSize
sprite1_9				ds.b	spriteSize
sprite1_10				ds.b	spriteSize
sprite1_11				ds.b	spriteSize
sprite1_12				ds.b	spriteSize
sprite1_13				ds.b	spriteSize
sprite1_14				ds.b	spriteSize
sprite1_15				ds.b	spriteSize
sprite2_1				ds.b	spriteSize
sprite2_2				ds.b	spriteSize
sprite2_3				ds.b	spriteSize
sprite2_4				ds.b	spriteSize
sprite2_5				ds.b	spriteSize
sprite2_6				ds.b	spriteSize
sprite2_7				ds.b	spriteSize
sprite2_8				ds.b	spriteSize
sprite2_9				ds.b	spriteSize
sprite2_10				ds.b	spriteSize
sprite2_11				ds.b	spriteSize
sprite2_12				ds.b	spriteSize
sprite2_13				ds.b	spriteSize
sprite2_14				ds.b	spriteSize
sprite2_15				ds.b	spriteSize
sprite_mask1			ds.b	spriteSize
sprite_mask2			ds.b	spriteSize
sprite_mask3			ds.b	spriteSize
sprite_mask4			ds.b	spriteSize
sprite_mask5			ds.b	spriteSize
sprite_mask6			ds.b	spriteSize
sprite_mask7			ds.b	spriteSize
sprite_mask8			ds.b	spriteSize
sprite_mask9			ds.b	spriteSize
sprite_mask10			ds.b	spriteSize
sprite_mask11			ds.b	spriteSize
sprite_mask12			ds.b	spriteSize
sprite_mask13			ds.b	spriteSize
sprite_mask14			ds.b	spriteSize
sprite_mask15			ds.b	spriteSize
