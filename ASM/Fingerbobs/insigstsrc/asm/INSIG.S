; buggered up!


; 
; Source Code : Insignificant Demo
; 
; From : Fingerbobs            To : Inner-Circle
; Date : 24/04/90
;
; Notice to GRIFF :
;
; This is almost exactly the same as the last except
; I have thrown away the sprite waves that annoyed me!
;
; Scrolltext is slightly different too!
;
; I have elected not to use my free processor time,
; as I have to do SOME college work, which I have been
; neglecting much lately!
;
; TTFN,
;       Oberje'
;
;
*********************************************************
*					
*                 FINGERBOBS present....		
*					
*                  INSIGNIFICANT DEMO		
*					
*                  Started  28/02/90		
*                  Finished 12/03/90		
*                  And on   24/04/90 too!	
*					
*                    Code By Oberje'		
*		      GFX  By Pixar		
*		     Music by Mad Max	
*                   ( Hacked by TCC )		
*					
* Demo screen,  for Inner Circle 'Decade',	
* Copy-Party Demo.				
*					
* FullScreen ( Standard ) vertical scrolling at 2 pix
* per frame.					
* 32 16x16 Sprites on Oberjes Wicked Waves!	
* ( 32!! Yes! Well thats my optimised sprites for you!)
* 8 Different sprite & loads of colours!	
* 24x16 Crystal Nibble Scroller.		
* Some Wicked MAX music! 		
* ( Seven Gates of Jambala to be Exact )	
*				
* Assembles to Approx 70k on disk, but uses not far off
* of 300k workspace when loaded!		
* Bytestomping reduces file size to 30k!	
*				
*********************************************************
*				
* Draft v1.0 - Very rough, urgently in need of some	*
*	       tidying and optimisation.		*
* Draft v1.1 - Some tidying up/reorganisation.		*
*              Like optimising the sprites!		*
* Draft v1.2 - Changed to use no XBIOS/BIOS/GEMDOS	*
*              routines at all!				*
* Draft v1.3 - More mega optimisations.			*
* Draft v1.4 - Bug ( occasionally appearing ) seems	*
*              to have been eradicated, but we'll just	*
*              have to watch & wait!			*
*       v1.5 - Submitted to Inner Circle.		*
*				
*********************************************************

	*********
	* BEGIN *
	*********

PDS	equ	1
DESK	equ	0

nospr		equ	32	;Number of sprites

scr	macro			;Macro for scroller
	move.l	(a0),d0
	rol.l	#4,d0
	swap	d0
	move.w	d0,(a0)+
	endm

vsync	macro			;Exact equivalent of XBIOS routine.
	;move.l	d0,-(a7)
	;move.w	sr,-(a7)
	;andi.w	#$f8ff,sr
	move.l	$466.w,d0
vlp\@  cmp.l	$466.w,d0
	beq	vlp\@
	;move.w	(a7)+,sr
	;move.l	(a7)+,d0
	endm



***** ***** *   * *****
  *   *     *   *   *
  *   *      * *    *
  *   ****    *     *
  *   *      * *    *
  *   *     *   *   *
  *   ***** *   *   *

	IFNE	PDS
	OPT	D+
	OPT	P+
	org	$3000
	ENDC


*******************
*		  *
*  Program Start  *
*		  *
*******************

start	move.l	#stack,a7	;Set up own stack

	IFNE	DESK
	jsr	super_on		;super on
	ENDC
	move.w	#$2300,sr
	jsr	mouse_off		;mouse OFF
	jsr	screen_begin		;Set up screen & palette
	jsr	set_up			;set up pointers
	jsr	make_screens		;create the background!
	jsr	make_sprites		;Create sprite data
	jsr	set_sprites		;Set up sprite type
	jsr	init_music		;Set up music		
	jsr	res_sprite_wave		;Set up waveform
	jsr	do_sprites		;Set sprites
	jsr	swap_screens		;ready 
	jsr	do_sprites		;to roll...
	jsr	swap_screens		;
	jsr	do_sprites		;
	jsr	swap_screens		;
	jsr	do_sprites		;
	jsr	swap_screens		;
	jsr	convert_text		;Change scrolltext to char codes
	
	jsr	new_vectors		;Install new VBL & HBL
	jsr	program    		;main_loop
	jsr	old_vectors		;get back old vectors
	jsr	mouse_on		;put mouse back on
	jsr	return_screen		;restore screen & palette
	jsr	sound_off		;stop that noise!
	IFNE	DESK
	jsr	super_off		;back to user
	clr	-(a7)			;...EXIT...
	trap	#1
	ENDC
	IFNE	PDS
	move.w	#$2700,sr
	jmp	$140.w
	ENDC

	;......................


*************
* Sound off *
*************
sound_off
	move.l	#0,d0
	jsr	music
	rts

***************
* Start music *
***************
init_music
	move.l	#5,d0		;init and start music
	jsr	music
	rts
	
********************
* Enter Super mode *
********************
super_on
	clr.l	-(a7)		;Super mode
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	move.l	d0,old_sp


******************
* Turn mouse off *
******************
mouse_off
	move.b	#$12,$fffc02
	move.b	#200,d0
@delay	nop
	dbf	d0,@delay
	rts
	

*******************
* save resolution *
*******************
screen_begin
	vsync		;The Vsyncs smattered liberally round
	vsync		;place seem to be necessary in order
	vsync		;for the hardware to adjust
			;Otherwise, things can get
			;pretty confused
			
	move.b	$ff8260,d0	;save res
	andi.w	#%00000011,d0
	move.w	d0,oldres
	
	vsync
	vsync
	vsync

	move.b	#0,d0		;SET to low res
	move.b	d0,$ff8260
		
	vsync
	vsync
	vsync
	
	clr.l	d0		;Save screen pos
	move.b	$ff8201,d0
	lsl.l	#8,d0
	move.b	$ff8203,d0
	lsl.l	#8,d0
	move.l	d0,old_physbase
	
	movem.l	$ff8240,d0-d7	;Save old palette/blank out current one
	movem.l	d0-d7,old_palette
	movem.l	blank_palette,d0-d7
	movem.l	d0-d7,$ff8240
	rts
	
**********************
* Turn mouse back on *
**********************
mouse_on
	move.b	#$08,$fffc02
	move.b	#200,d0
@delay	nop
	dbf	d0,@delay
	rts

	
*****************
* return screen *
*****************
return_screen
	move.w	oldres,d0	;return screen...
	move.b	d0,$ff8260
	
	move.l	old_physbase,d0
	lsr.w	#8,d0
	move.b	d0,$ff8203
	swap	d0
	move.b	d0,$ff8201

	movem.l	old_palette,d0-d7
	movem.l	d0-d7,$ff8240	;..and palette
	rts
	
*************
* super off *
*************
super_off
	move.l	old_sp,-(a7)	;back to user mode
	move.w	#$20,-(a7)
	trap	#1
	addq.l	#6,a7
	rts
	
*******************************
* Set up Sprite Type & Colour *
*******************************
set_sprites
	move.l	#sprite_data1,sprite_now
	lea	sp_pal0,a0
	jsr	set_palette
	rts
	


******* VBL & MUSIC **********

***************
* VBL routine *
***************
new_vbl	
	movem.l	d0-d7/a0-a6,-(a7)
	
	addq.l	#1,$466.w		;Bump the frame count
	
	movem.l	new_palette,d0-d7
	movem.l	d0-d7,$ffff8240.w	
	
	move.b	#0,$fffffa1b.w		;Turn Timer B off
	move.b	#160,$fffffa21.w	;170 before palette change
	move.l	#hbl,$120.w		;Address of routine
	move.b	#8,$fffffa1b.w		;Turn Timer B on
					
	jsr	music+8			;Call music

	movem.l	(a7)+,d0-d7/a0-a6
	rte
		
		
hbl	move.b	#0,$fffffa1b.w		;Turn Timer B off
	move.l	#$01120223,$ffff8248.w
	move.l	#$03340445,$ffff824c.w
	bclr.b	#0,$fffffa0f.w		;Clear in-service bit
	rte
	
	
;
;Keyboard patch.
;
kybd	move.b	$fffc02,location
	bclr	#6,$fffffa11
	rte


***************************
*                         *
* THE MAIN EXECUTION LOOP *
*                         *
***************************
program	
	bsr	run_sprites	;do stuff
	bsr	swap_screens	;swap
	

	*******************************************
	
	bsr	run_sprites	;etc.....
	bsr	swap_screens
	
	
	*******************************************
	
	bsr	run_sprites
	bsr	swap_screens

	
	*******************************************
	
	move.b	location,d0
	cmpi.b	#$39,d0
	beq	exit

main_loop	
	bsr	run_sprites
	bsr	swap_screens
	
	
	*******************************************
	
	;Increment scroll variables and
	;check for end of screen.
	;
	addi.l	#1280,sp1
	addi.l	#1280,sp2
	addi.l	#1280,sp3
	addi.l	#1280,sp4
	move.l	screen_b,d0
	cmp.l	sp2,d0
	beq	rest

	bra	program
		
exit	rts

;
;End_screen reached.
;
;Set scroll pointers for next pass.
;
rest	move.l	screen_a,sp2
	move.l	screen_c,d0
	addi.l	#1280,d0
	move.l	d0,sp3
	move.l	screen_e,d0
	addi.l	#1280,d0
	move.l	d0,sp4
	move.l	screen_g,d0
	addi.l	#1280,d0
	move.l	d0,sp1
	bra	program


**************************
*                        *
* run_sprites & scroller *
*                        *
**************************
run_sprites

	bsr	scroll		;scroll
	bsr	check_char	;next char?
	bsr	display		;display new slice
	move.l	old_scroll,a2	;
	bsr	remove_scroller	;remove old scroller
	move.l	sp2,a2		;
	add.l	#$a0*179,a2	;
	move.l	a2,old_scroll	;
	bsr	print_scroller	;display new scroller
	
	
	bsr	blank_out	;Delete old sprites
	bsr	do_sprites	;Draw new sprites

	
	sub.w	#1,frames	;time for next sprite wave?
	beq	next_wave

	rts

;
;Get the next wave for the sprites.
;	
next_wave
	bsr	get_sprite_wave
	rts
	
	
***********************
*                     *
* Screen/pointer swap *
*                     *
***********************
swap_screens
	move.l	sp2,d0
	lsr.w	#8,d0
	move.b	d0,$ffff8203.w
	swap	d0
	move.b	d0,$ffff8201.w

	vsync
	
	move.l	sp1,a0
	move.l	sp2,sp1
	move.l	sp3,sp2
	move.l	sp4,sp3
	move.l	a0,sp4
	
	move.l	old_sprites,a0
	move.l	old1,old_sprites
	move.l	old2,old1
	move.l	old3,old2
	move.l	a0,old3

	move.l	old_scroll,a0
	move.l	oldscr1,old_scroll
	move.l	oldscr2,oldscr1
	move.l	oldscr3,oldscr2
	move.l	a0,oldscr3

	rts	
	
	
	
******************************
*			     *
* Set up the screen pointers *
* sprite pointers and init   *
* the scroller.		     *
*                            *
******************************
set_up	move.l	#screens,d0
	addi.l	#512,d0
	and.l	#$ffffff00,d0
	move.l	d0,screen_a
	addi.l	#32000,d0
	move.l	d0,screen_b
	addi.l	#32000,d0
	move.l	d0,screen_c
	addi.l	#32000,d0
	move.l	d0,screen_d
	addi.l	#32000,d0
	move.l	d0,screen_e
	addi.l	#32000,d0
	move.l	d0,screen_f
	addi.l	#32000,d0
	move.l	d0,screen_g
	addi.l	#32000,d0
	move.l	d0,screen_h
	
	move.l	screen_a,sp2
	move.l	screen_c,d0
	addi.l	#1280,d0
	move.l	d0,sp3
	move.l	screen_e,d0
	addi.l	#1280,d0
	move.l	d0,sp4
	move.l	screen_g,d0
	addi.l	#1280,d0
	move.l	d0,sp1

	move.l	screen_a,old_scroll
	move.l	screen_a,oldscr1
	move.l	screen_a,oldscr2
	move.l	screen_a,oldscr3
	
	move.l	#old_spr1,old_sprites
	move.l	#old_spr2,old1
	move.l	#old_spr3,old2
	move.l	#old_spr4,old3

	move.l	#message,here	;Scroller init
	move.b	#0,slice	;

	rts


	
******************
*                *
* Set up screens *
*                *
******************
make_screens
	lea	scroll_data,a0	; Clear out scroll buffer too!
	move.w	#((40*18)/4)-1,d7
@LOOP	move.l	#0,(a0)+
	dbf	d7,@LOOP

	lea	picture,a0	;Now copy it 
	move.l	screen_b,a1
	move.w	#(32000/8)-1,d0
@LOOP2
	move.l	(a0)+,(a1)+
	clr.l	(a1)+
	dbf	d0,@LOOP2
	
	lea	picture,a0	;source
	move.l	screen_a,a1	;destination
	move.w	#(32000/8)-1,d0	;1 screen
@LOOP1
	move.l	(a0)+,(a1)+
	clr.l	(a1)+
	dbf	d0,@LOOP1

	
	;now do the extra copy!
	;
	move.l	screen_a,a0
	move.l	screen_c,a1
	adda.l	#(6*$a0),a1
	move.w	#32000/4-1,d0
@LOOP3
	move.l	(a0)+,(a1)+
	dbf	d0,@LOOP3
	move.w	#32000/4-1,d0
@LOOP5
	move.l	(a0)+,(a1)+
	dbf	d0,@LOOP5
	
	move.l	screen_c,a1
	move.w	#($a0*6)/4-1,d0
@LOOP4
	move.l	(a0)+,(a1)+
	dbf	d0,@LOOP4
	
	
extra_extra_copy_my_main_man
	;now do the extra extra copy!
	;
	move.l	screen_a,a0
	move.l	screen_e,a1
	adda.l	#(4*$a0),a1
	move.w	#32000/4-1,d0
@LOOP3
	move.l	(a0)+,(a1)+
	dbf	d0,@LOOP3
	move.w	#32000/4-1,d0
@LOOP5
	move.l	(a0)+,(a1)+
	dbf	d0,@LOOP5
	
	move.l	screen_e,a1
	move.w	#($a0*4)/4-1,d0
@LOOP4
	move.l	(a0)+,(a1)+
	dbf	d0,@LOOP4
	
	
extra2
	;now do the extra extra copy!
	;
	move.l	screen_a,a0
	move.l	screen_g,a1
	adda.l	#(2*$a0),a1
	move.w	#32000/4-1,d0
@LOOP3
	move.l	(a0)+,(a1)+
	dbf	d0,@LOOP3
	move.w	#32000/4-1,d0
@LOOP5
	move.l	(a0)+,(a1)+
	dbf	d0,@LOOP5
	
	move.l	screen_g,a1
	move.w	#($a0*2)/4-1,d0
@LOOP4
	move.l	(a0)+,(a1)+
	dbf	d0,@LOOP4
	
	rts


***************
* Set Palette *
***************
; Enter - colours in a0
; places appropriate colours in bobs palette
set_palette
	lea	new_palette+8,a5
	move.w	(a0)+,d5
	move.w	d5,(a5)+
	move.w	d5,(a5)+
	move.w	d5,(a5)+
	move.w	d5,(a5)+
	move.w	(a0)+,d5
	move.w	d5,(a5)+
	move.w	d5,(a5)+
	move.w	d5,(a5)+
	move.w	d5,(a5)+
	move.w	(a0)+,d5
	move.w	d5,(a5)+
	move.w	d5,(a5)+
	move.w	d5,(a5)+
	move.w	d5,(a5)+
	rts
	

************************
*		       *
* Save old vectors,    *
* and install the new. *
*	               *
************************
new_vectors	
	move	sr,-(a7)	;Save SR
	ori.w	#$700,sr	;Raise IPL to 7
	lea	vector_store,a0	;Save old MFP values here...
	move.b	$fffffa09,(a0)+	;MFP Enable B
	move.b	$fffffa07,(a0)+	;MFP Enable A
	move.b	$fffffa13,(a0)+	;MFP I-mask A
	adda.l	#1,a0
	move.l	$118.w,(a0)+	;Keybd
	move.l	$120.w,(a0)+	;HBL   - Timer B
	move.l	$70.w,(a0)+	;VBL
	
	move.l	#kybd,$118.w	;keyboard routine
	andi.b	#$fe,$fffffa07	;Enable A - Timer B off
	andi.b	#$df,$fffffa09	;Enable B - Timer C off
	move.l	#hbl,$120.w
	ori.b	#1,$fffffa07.w	;Enable A - Timer B on	
	ori.b	#1,$fffffa13.w	;I-Mask A - Timer B on
	move.l	#new_vbl,$70.w	;New VBL
		
	move.w	(a7)+,sr	;Restore SR
	rts
	

************************
*		       *
* Restore old vectors. *
*	               *
************************
old_vectors
	move	sr,-(a7)	;Save SR
	ori.w	#$700,sr	;Raise IPL to 7
	
	move.l	#0,$4d6
	
	lea	vector_store,a0	;Get vectors from here
	move.b	(a0)+,$fffffa09 ;MFP Enable B
	move.b	(a0)+,$fffffa07 ;MFP Enable A
	move.b	(a0)+,$fffffa13 ;MFP I-Mask A
	adda.l	#1,a0
	move.l	(a0)+,$118.w	;Keyboard
	move.l	(a0)+,$120.w	;HBL
	move.l	(a0)+,$70.w	;VBL
	move.w	(a7)+,sr
	rts
	


;*********************************
;*********************************
;S P R I T E.     R O U T I N E S.
;*********************************
;*********************************
	
**********************
* Blank out a sprite *
**********************
blank	macro
	move.l	(a6)+,a4
	moveq	#0,d0
	
count	set	4	

	move.l	d0,count(a4)
	move.l	d0,count+8(a4)
count	set	count+$a0

	move.l	d0,count(a4)
	move.l	d0,count+8(a4)
count	set	count+$a0

	move.l	d0,count(a4)
	move.l	d0,count+8(a4)
count	set	count+$a0

	move.l	d0,count(a4)
	move.l	d0,count+8(a4)
count	set	count+$a0

	move.l	d0,count(a4)
	move.l	d0,count+8(a4)
count	set	count+$a0

	move.l	d0,count(a4)
	move.l	d0,count+8(a4)
count	set	count+$a0

	move.l	d0,count(a4)
	move.l	d0,count+8(a4)
count	set	count+$a0

	move.l	d0,count(a4)
	move.l	d0,count+8(a4)
count	set	count+$a0

	move.l	d0,count(a4)
	move.l	d0,count+8(a4)
count	set	count+$a0

	move.l	d0,count(a4)
	move.l	d0,count+8(a4)
count	set	count+$a0

	move.l	d0,count(a4)
	move.l	d0,count+8(a4)
count	set	count+$a0

	move.l	d0,count(a4)
	move.l	d0,count+8(a4)
count	set	count+$a0

	move.l	d0,count(a4)
	move.l	d0,count+8(a4)
count	set	count+$a0

	move.l	d0,count(a4)
	move.l	d0,count+8(a4)
count	set	count+$a0

	move.l	d0,count(a4)
	move.l	d0,count+8(a4)
count	set	count+$a0

	move.l	d0,count(a4)
	move.l	d0,count+8(a4)
count	set	count+$a0

	endm
	

	**************************
	* Place sprite ON screen *
	**************************
pon	macro
	moveq	#0,d0		;Zero regs
	moveq	#0,d1
	moveq	#0,d2
 	
	move.b	(a4)+,d0
	move.b	(a4)+,d2

	move.l	sprite_now,a0
	move.l	a3,a2		;Get screen base
	
	lsl.w	#5,d2		\
	move.w	d2,d3		|Fastest equiv for mulu #$a0,d2
	add.w	d2,d2		|
	add.w	d2,d2		|
	add.w	d3,d2		/
	add.l	d2,a2		;address of y	
	
	addi.w	#70,d0		;Add X constant offset
	move.w	d0,d1		;X
	andi.w	#$f,d1		;0-15
	asl	#8,d1		;256 Bytes per sprite data
	add.l	d1,a0		;a0=sprite we want
	andi.w	#$f0,d0		;\ Equivalent to d0=d0/16
	asr.w	#1,d0		;/		 d0=d0*8
	add.l	d0,a2		;a2=screen address we want
		
 	move.l	a2,(a5)+	;Save screen pos
	
c2	set	0

	movem.l	(a0)+,d0-d7
	and.l	d0,4+c2(a2)
	and.l	d1,12+c2(a2)
	or.l	d2,4+c2(a2)
	or.l	d3,12+c2(a2)
c2	set	$a0+c2
	and.l	d4,4+c2(a2)
	and.l	d5,12+c2(a2)
	or.l	d6,4+c2(a2)
	or.l	d7,12+c2(a2)
c2	set	$a0+c2

	movem.l	(a0)+,d0-d7
	and.l	d0,4+c2(a2)
	and.l	d1,12+c2(a2)
	or.l	d2,4+c2(a2)
	or.l	d3,12+c2(a2)
c2	set	$a0+c2
	and.l	d4,4+c2(a2)
	and.l	d5,12+c2(a2)
	or.l	d6,4+c2(a2)
	or.l	d7,12+c2(a2)
c2	set	$a0+c2

	movem.l	(a0)+,d0-d7
	and.l	d0,4+c2(a2)
	and.l	d1,12+c2(a2)
	or.l	d2,4+c2(a2)
	or.l	d3,12+c2(a2)
c2	set	$a0+c2
	and.l	d4,4+c2(a2)
	and.l	d5,12+c2(a2)
	or.l	d6,4+c2(a2)
	or.l	d7,12+c2(a2)
c2	set	$a0+c2

	movem.l	(a0)+,d0-d7
	and.l	d0,4+c2(a2)
	and.l	d1,12+c2(a2)
	or.l	d2,4+c2(a2)
	or.l	d3,12+c2(a2)
c2	set	$a0+c2
	and.l	d4,4+c2(a2)
	and.l	d5,12+c2(a2)
	or.l	d6,4+c2(a2)
	or.l	d7,12+c2(a2)
c2	set	$a0+c2

	movem.l	(a0)+,d0-d7
	and.l	d0,4+c2(a2)
	and.l	d1,12+c2(a2)
	or.l	d2,4+c2(a2)
	or.l	d3,12+c2(a2)
c2	set	$a0+c2
	and.l	d4,4+c2(a2)
	and.l	d5,12+c2(a2)
	or.l	d6,4+c2(a2)
	or.l	d7,12+c2(a2)
c2	set	$a0+c2

	movem.l	(a0)+,d0-d7
	and.l	d0,4+c2(a2)
	and.l	d1,12+c2(a2)
	or.l	d2,4+c2(a2)
	or.l	d3,12+c2(a2)
c2	set	$a0+c2
	and.l	d4,4+c2(a2)
	and.l	d5,12+c2(a2)
	or.l	d6,4+c2(a2)
	or.l	d7,12+c2(a2)
c2	set	$a0+c2

	movem.l	(a0)+,d0-d7
	and.l	d0,4+c2(a2)
	and.l	d1,12+c2(a2)
	or.l	d2,4+c2(a2)
	or.l	d3,12+c2(a2)
c2	set	$a0+c2
	and.l	d4,4+c2(a2)
	and.l	d5,12+c2(a2)
	or.l	d6,4+c2(a2)
	or.l	d7,12+c2(a2)
c2	set	$a0+c2

	movem.l	(a0)+,d0-d7
	and.l	d0,4+c2(a2)
	and.l	d1,12+c2(a2)
	or.l	d2,4+c2(a2)
	or.l	d3,12+c2(a2)
c2	set	$a0+c2
	and.l	d4,4+c2(a2)
	and.l	d5,12+c2(a2)
	or.l	d6,4+c2(a2)
	or.l	d7,12+c2(a2)
c2	set	$a0+c2
	
	endm
	
	
res_sprite_wave
	move.l	#spr_wave_tab,spr_wave	
get_sprite_wave
	move.l	spr_wave,a1
	move.w	(a1),d0
	bmi	res_sprite_wave
	move.w	d0,frames
	move.l	2(a1),sprite_now
	move.l	6(a1),a0
	bsr	set_palette
	move.w	10(a1),Xinc
	move.w	12(a1),Yinc
	move.w	14(a1),XDisp
	move.w	16(a1),YDisp
	move.w	18(a1),X2inc
	move.w	20(a1),Y2inc
	move.w	22(a1),X2Disp
	move.w	24(a1),Y2Disp
	move.w	26(a1),d0
	bmi	leev_it_art
	move.b	d0,x1
	move.w	28(a1),d0
	move.b	d0,y1
	move.w	30(a1),d0
	move.b	d0,cx1
	move.w	32(a1),d0
	move.b	d0,cy1
leev_it_art
	add.l	#34,spr_wave
	bsr	change_disp
	rts

	
	
***************************
*			  *
* The Main Sprite Routine *
*			  *
***************************
;
;This routine updates all the sine table pointers
;then creates a table of actual sprite coords by
;refrencing the sine tables and then adding the coord
;together. It is only marginally faster than the
;original method I used. ( calculating the coords
;in the sprite printing routine )
;
do_sprites
 	lea	vertical,a6	;a6=base of sine table 1
 	lea	vertical2,a5	;a5=base of sine table 2
 	
 	move.w	Xinc,d0		;Get sprite wave
 	move.w	Yinc,d1		;variables
 	move.w	X2inc,d2	;
 	move.w	Y2inc,d3	;

	moveq	#0,d4
	moveq	#0,d5
	moveq	#0,d6
	moveq	#0,d7
	
	lea	x1,a0
	lea	px1,a1
	
	do	nospr		;All 32 of 'em!
 	add.b	d0,(a0)+	;*** Save 40 cycles!
 	add.b	d1,(a0)+
 	add.b	d2,(a0)+
 	add.b	d3,(a0)+
	subq.l	#4,a0
 	
 	move.b	(a0)+,d4	;X offset
 	move.b	(a0)+,d5	;Y offset
 	move.b	(a0)+,d6	;X2 offset
 	move.b	(a0)+,d7	;Y2 offset
 	
 	move.b	(a6,d4.w),d4	;X coord
 	move.b	(a6,d5.w),d5	;Y coord
 	move.b	(a5,d6.w),d6	;X2 coord
 	move.b	(a5,d7.w),d7	;Y2 coord
 	add.b	d6,d4		;Final X coord
 	add.b	d7,d5		;Final Y coord
	move.b	d4,(a1)+
	move.b	d5,(a1)+
 	LOOP
 	
	move.l	sp2,a3		;Base of Screen data
	add.l	#6*$a0,a3	;	
 	move.l	old_sprites,a5	;Place all sprites on screen
	lea	px1,a4		;and save sprite positions for later
 	 pon	1	;
 	 pon	2	;
 	 pon	3	;
 	 pon	4	;
 	 pon	5	;
 	 pon	6	;
 	 pon	7	;
 	 pon	8	;
 	 pon	9	;
 	 pon	10	;
 	 pon	11	;
 	 pon	12	;
 	 pon	13	;
 	 pon	14	;
 	 pon	15	;
 	 pon	16	;
 	 pon	1	;
 	 pon	2	;
 	 pon	3	;
 	 pon	4	;
 	 pon	5	;
 	 pon	6	;
 	 pon	7	;
 	 pon	8	;
 	 pon	9	;
 	 pon	10	;
 	 pon	11	;
 	 pon	12	;
 	 pon	13	;
 	 pon	14	;
 	 pon	15	;
 	 pon	16	;
 	
out 	rts		;Exit
 
 	
 	
blank_out
	move.l	old_sprites,a6
	 blank	16
	 blank	15
	 blank	14
	 blank	13
	 blank	12
	 blank	11
	 blank	10
	 blank	9
	 blank	8
	 blank	7
	 blank	6	;Replace screen areas under
	 blank	5	;sprites.
	 blank	4	;Do in reverse order
	 blank	3
	 blank	2
	 blank	1
	 blank	16
	 blank	15
	 blank	14
	 blank	13
	 blank	12
	 blank	11
	 blank	10
	 blank	9
	 blank	8
	 blank	7
	 blank	6	;Replace screen areas under
	 blank	5	;sprites.
	 blank	4	;Do in reverse order
	 blank	3
	 blank	2
	 blank	1
	
	rts
	
	
**********************************
*				 *
* Change distance between 'BOBS' *
*				 *
**********************************
change_disp
	lea	x1,a0		;Point to table pointers
	move.w	XDisp,d0	;Get displacement
	move.w	YDisp,d3
	move.b	(a0),d1		;Get Start X
	move.b	1(a0),d2	;Get Start Y
	
	do	nospr		;32 Sprites
	move.b	d1,(a0)		;New X
	move.b	d2,1(a0)	;New Y
	add.b	d0,d1		;Calc Next X
	add.b	d3,d2		;Calc Next Y
	addq.l	#4,a0		;Next Pointers
	LOOP
	
	lea	x1,a0		;Point to table pointers
	move.w	X2Disp,d0	;Get displacement
	move.w	Y2Disp,d3
	move.b	2(a0),d1	;Get Start X
	move.b	3(a0),d2	;Get Start Y
	
arooga	do	nospr		;32 Sprites
	move.b	d1,2(a0)	;New X
	move.b	d2,3(a0)	;New Y
	add.b	d0,d1		;Calc Next X
	add.b	d3,d2		;Calc Next Y
	addq.l	#4,a0		;Next Pointers
	LOOP
	rts
	
	
******************
******************
******************
* Scroller Stuff *
******************
******************
******************
check_char	
	cmpi.b	#0,slice	;
	bne	chk_xit		;
	addq.l	#1,here		;
chk_xit	rts			;
		
restart	move.l	#message,here	;
	move.b	#0,slice	;
	bsr	display		;
	rts			;
		
scroll	lea	scroll_data,a0	;
	move.w	#16-1,d1	;
scloop	scr	$0		;
	scr	$8		;
	scr	$10		;
	scr	$18		;
	scr	$20		;
	scr	$28		;
	scr	$30		;
	scr	$38		;
	scr	$40		;
	scr	$48		;
	scr	$50		;
	scr	$58		;
	scr	$60		;
	scr	$68		;
	scr	$70		;
	scr	$78		;
	scr	$80		;
	scr	$88		;
	scr	$90		;
	scr	$98		;
	dbra	d1,scloop	;
	rts			;
	
***************************
* Convert ASCII text into *
* actual character no.s   *
***************************
convert_text
	lea	message,a0
@next	
	move.b	(a0),d0
	tst.b	d0
	beq	@exit_convert

	cmp.b	#65,d0		
	blt	@symbols		
	subi.b	#65,d0		
@trim	
	move.b	d0,(a0)+
	bra	@next

@symbols
	cmpi.b	#" ",d0
	beq	@space	
	cmpi.b	#"+",d0
	bgt	@above	
	subi.b	#32,d0	
	addi.b	#26,d0	
	bra	@trim	

@space	move.b	#26,d0	
	bra	@trim	

@above	subi.b	#32,d0	
	addi.b	#25,d0	
	bra	@trim
	

@exit_convert
	move.b	#$ff,(a0)+
	rts
	
*
* Display : here = addr of char to print
* 	
display	lea	char_set,a0	;
	move.l	here,a1		;
	move.b	(a1),d0		;
	
	cmpi.b	#$ff,d0		;
	beq	restart		;
	
trim	andi.l	#$ff,d0		
	mulu.w	#(16*3),d0	;

	add.l	d0,a0		;a0=addr of chars pix data
	move.b	slice,d0	;
	andi.l	#%110,d0	;
	lsr.b	#1,d0		;
	adda.l	d0,a0		;
	btst	#0,slice	;
	beq	nibble2		;

nibble1	lea	put_data,a1		;<--- Rewrite this - PLEASE!
				;----> DONE!
c1	set	0
c2	set	0

	do	16
	move.b	c2(a0),d5	;
	andi.b	#$f,d5		;
	move.b	c1(a1),d6	;
	andi.b	#$f0,d6		;
	or.b	d5,d6		;
	move.b	d6,c1(a1)	;
c1	set	40+c1
c2	set	$3+c2
	LOOP
	
nib_xit	addq.b	#1,slice	;
	cmpi.b	#6,slice	;
	beq	nib_xit2	;
	rts			;
nib_xit2
	move.b	#0,slice	;
	rts			;

nibble2	lea	put_data,a1	;
	
c1	set	0
c2	set	0
	do	16
	move.w	#16-1,d0	;
	move.b	c2(a0),d5	;
	lsr.b	#4,d5		;
	andi.b	#$f,d5		;
	move.b	c1(a1),d6	;
	andi.b	#$f0,d6		;
	or.b	d5,d6		;
	move.b	d6,c1(a1)	;
c1	set	40+c1
c2	set	$3+c2
	LOOP

	bra	nib_xit		;
				;

	
**************************************************
* Print scroller to screen, a2=address to PUT to *
**************************************************
print_scroller
	lea	scroll_data,a1
	
	do	16
	move.w	(a1)+,$0+4(a2)
	move.w	(a1)+,$8+4(a2)
	move.w	(a1)+,$10+4(a2)
	move.w	(a1)+,$18+4(a2)
	move.w	(a1)+,$20+4(a2)
	move.w	(a1)+,$28+4(a2)
	move.w	(a1)+,$30+4(a2)
	move.w	(a1)+,$38+4(a2)
	move.w	(a1)+,$40+4(a2)
	move.w	(a1)+,$48+4(a2)
	move.w	(a1)+,$50+4(a2)
	move.w	(a1)+,$58+4(a2)
	move.w	(a1)+,$60+4(a2)
	move.w	(a1)+,$68+4(a2)
	move.w	(a1)+,$70+4(a2)
	move.w	(a1)+,$78+4(a2)
	move.w	(a1)+,$80+4(a2)
	move.w	(a1)+,$88+4(a2)
	move.w	(a1)+,$90+4(a2)
	move.w	(a1)+,$98+4(a2)
	adda.l	#$a0,a2
	LOOP
	
	rts

*******************************************
* Remove scroller, a2=address to  RUB-OUT *
*******************************************
remove_scroller
	moveq.w	#0,d0
	do	8
	move.w	d0,$0+4(a2)
	move.w	d0,$8+4(a2)
	move.w	d0,$10+4(a2)
	move.w	d0,$18+4(a2)
	move.w	d0,$20+4(a2)
	move.w	d0,$28+4(a2)
	move.w	d0,$30+4(a2)
	move.w	d0,$38+4(a2)
	move.w	d0,$40+4(a2)
	move.w	d0,$48+4(a2)
	move.w	d0,$50+4(a2)
	move.w	d0,$58+4(a2)
	move.w	d0,$60+4(a2)
	move.w	d0,$68+4(a2)
	move.w	d0,$70+4(a2)
	move.w	d0,$78+4(a2)
	move.w	d0,$80+4(a2)
	move.w	d0,$88+4(a2)
	move.w	d0,$90+4(a2)
	move.w	d0,$98+4(a2)
	adda.l	#$a0,a2
	LOOP
	adda.l	#15*$a0,a2	;now the bottom lines too!
	do	8
	move.w	d0,$0+4(a2)
	move.w	d0,$8+4(a2)
	move.w	d0,$10+4(a2)
	move.w	d0,$18+4(a2)
	move.w	d0,$20+4(a2)
	move.w	d0,$28+4(a2)
	move.w	d0,$30+4(a2)
	move.w	d0,$38+4(a2)
	move.w	d0,$40+4(a2)
	move.w	d0,$48+4(a2)
	move.w	d0,$50+4(a2)
	move.w	d0,$58+4(a2)
	move.w	d0,$60+4(a2)
	move.w	d0,$68+4(a2)
	move.w	d0,$70+4(a2)
	move.w	d0,$78+4(a2)
	move.w	d0,$80+4(a2)
	move.w	d0,$88+4(a2)
	move.w	d0,$90+4(a2)
	move.w	d0,$98+4(a2)
	adda.l	#$a0,a2
	LOOP
	
	rts

		

*******************************************
* Create 16 preshifted copies of a sprite *
*******************************************
*
* Sprite is held in memory as 4 planes of 16x16 pixels
* i.e 1 word along by 16 lines ( 16 words ) x 4 planes
*     = 1 x 16 x 4 = 64 words = 128 bytes ( $80 )
* This is my standard 16x16 Character set format.
*
* The sprite data is stored at sprite_data 16 times
* one after another ( 4096 bytes ) each one shifted along
* one pixel to the right
*
* The actual sprite data and the mask are held together
* and are interleaved.
*
* The format is 1x.L First Word Mask
*		1x.L Second Word Mask
*		1x.L First Word Data
*		1x.L Second Word Data
*
* Because of this preshifting, the sprite routine does
* not have to shift every sprite it prints, but just
* refers to the preshifted sprite it requires.
*

make_sprites
	lea	sprite_data1,a1	;Sprite area
	lea	char,a0		;Address of original sprite data
	bsr	make_and_do
	
	lea	sprite_data2,a1	;Sprite area
	lea	char+(1*$80),a0	;Address of original sprite data
	bsr	make_and_do
	
	lea	sprite_data3,a1	;Sprite area
	lea	char+(2*$80),a0	;Address of original sprite data
	bsr	make_and_do
	
	lea	sprite_data4,a1	;Sprite area
	lea	char+(3*$80),a0	;Address of original sprite data
	bsr	make_and_do
	
	lea	sprite_data5,a1	;Sprite area
	lea	char+(4*$80),a0	;Address of original sprite data
	bsr	make_and_do
	
	lea	sprite_data6,a1	;Sprite area
	lea	char+(5*$80),a0	;Address of original sprite data
	bsr	make_and_do
	
	lea	sprite_data7,a1	;Sprite area
	lea	char+(6*$80),a0	;Address of original sprite data
	bsr	make_and_do
	
	lea	sprite_data8,a1	;Sprite area
	lea	char+(7*$80),a0	;Address of original sprite data
	bsr	make_and_do
	
	rts

clear_buf
	lea	work,a3
	move.w	#4*32-1,d0
@LOOP	clr.w	(a3)+
	dbf	d0,@LOOP
	rts	
	
make_and_do
	bsr	clear_buf	;
	lea	work,a3		;Work Area
	move.w	#16-1,d0	;Copy
copy_it				
	move.w	(a0)+,(a3)	;the sprite to
	move.w	(a0)+,2(a3)	;the sprite work
	move.w	(a0)+,4(a3)	;area
	move.w	(a0)+,6(a3)
	
	add.l	#16,a3
	dbra	d0,copy_it
	
	lea	work,a3		;Work Area
	move.w	#16-1,d7	;16 copies of sprite
next_sprite
	move.w	#16-1,d6	;16 lines per sprite
next_line
	move.w	(a3),d0		;Create mask 
	or.w	2(a3),d0	;By oring the two planes
	not.w	d0		;and taking the complement
	move.w	d0,(a1)+	;Store mask
	move.w	d0,(a1)+	;in sprite data
	move.w	8(a3),d0	;Get second words from work area
	or.w	10(a3),d0	;do the
	not.w	d0		;same
	move.w	d0,(a1)+	;
	move.w	d0,(a1)+	;Mask stored
	
	move.w	(a3),(a1)+	;Copy work sprite (32x16)
	move.w	2(a3),(a1)+	;into sprite area
	move.w	8(a3),(a1)+	;
	move.w	10(a3),(a1)+	;Sprite data stored

	add.l	#16,a3		;
	dbra	d6,next_line	;Next line of current sprite
	
	**************
	* Now shift! *
	**************
	
	lea	work,a3		;Work area
	move.w	#16-1,d6	;16 lines
shift
	move.l	(a3),d0		;Mask
	move.w	8(a3),d0	;d0 = Word1 Plane 1 | Word2 Plane 1
	lsr.l	#1,d0		;Shift
	move.w	d0,8(a3)	;Replace Word2 Plane 1
	swap	d0		;
	move.w	d0,(a3)		;Replace Word1 Plane 1
	
	move.l	2(a3),d0	;Mask
	move.w	10(a3),d0	;d0= Word1 Plane 2 | Word2 Plane 2
	lsr.l	#1,d0		;Shift
	move.w	d0,10(a3)	;Replace Word2 Plane 2
	swap	d0		;
	move.w	d0,2(a3)	;Replace Word1 Plane 2
	
	move.l	4(a3),d0	;Sprite
	move.w	12(a3),d0	;d0= Word1 Plane 1 | Word2 Plane 1
	lsr.l	#1,d0		;Shift
	move.w	d0,12(a3)	;Replace Word2 Plane 1
	swap	d0		;
	move.w	d0,4(a3)	;Replace Word1 Plane 1
	
	move.l	6(a3),d0	;Sprite
	move.w	14(a3),d0	;d0= Word1 Plane 2 | Word2 Plane 2
	lsr.l	#1,d0		;Shift
	move.w	d0,14(a3)	;Replace Word2 Plane 2
	swap	d0		;
	move.w	d0,6(a3)	;Replace Word1 Plane 2
	
	adda.l	#16,a3
	dbra	d6,shift	;Shift next line
	
	lea	work,a3		;
	dbra	d7,next_sprite	;Do next copy of sprite
	rts
	



**    ***  *****  ***
* *  *   *   *   *   *
*  * *   *   *   *   *
*  * *****   *   ***** 
*  * *   *   *   *   *
* *  *   *   *   *   *
**   *   *   *   *   *

	

	********
	* FONT *
	********
		
char_set	incbin	C:\ASM\INSIG\font2.dat

	even
		
message 
 dc.b " WELCOME TO          THE INSIGNIFICANT DEMO                "
 DC.B "      THIS FANTASTIC ( YET INSIGNIFICANT ) LITTLE DEMO SCREEN IS BROUGHT TO"
 DC.B " YOU BY               FINGERBOBS                     A NEW ST FORCE WITH MORE TALENT THAN A BSC YEAR I PHARMACY CLASS"
 DC.B "  (THIS IS A BIT OF AN IN-JOKE, BUT BASICALLY THERE IS LOADS OF TALENT IN THAT CLASS! IN A FEMALE SORT OF WAY, NAARMEAN! ) "
 DC.B "       YOUR CODER FOR THIS DELICIOUS SCREEN ( AND THE HOST OF THIS SCROLLER ) IS              OBERJE            "
 DC.B "       THE GREAT GRAPHICS ARE BY                  PIXAR   "
 DC.B "       MUSIC IS BY MAD MAX, AND WAS RIPPED BY                 THE CAPED CRUSADER          "
 DC.B "         FROM THE SEVEN GATES OF JAMBALA      "
 DC.B "                SOME CODE OPTIMISATIONS BY              UNDERCOVER ELEPHANT              "

 DC.B " IF YOU HANG JUST A SHORT WHILE I'LL DO THE FABBO GREETINGS, AND AFTER THAT I THINK "
 DC.B " THE COUNT WISHES TO TYPE SOMETHING!           "
 
 DC.B " OK, IF I JUST DO THE GREETS NOW, WE CAN GET BACK TO SOME SERIOUS SCROLLTEXT AFTERWARDS......"
 
 DC.B "             LOVE AND KISSES TO THE FOLLOWING CREWS..............."    
 DC.B "             ....ALL MEMBERS OF THE INNER-CIRCLE...."
 DC.B ".ELECTRONIC IMAGES...RESISTANCE...DYNAMIC DUO...ST SQUAD...RUSS PAYNE..."
 DC.B "             ....LOST BOYS - AWESOME MINDBOMB DEMO! I LOVE THE RSI VECTORBALL SCREEN - EXCELLENT!.... "
 DC.B "             ....AUTOMATION - T.H.E. BEST PACKERS....."
 DC.B "             ....THE EXCEPTIONS - ALWAYS A SPECIAL PLACE IN MY HEART FOR THE PIONEERS OF ST DEMOS...."
 DC.B "             ....CAREBEARS - YOU GUYS ARE SO CLEVER, IT MAKES ME SICK!....."
 DC.B "             ....THE UNION.... "
 DC.B "             ....ST CONNEXION - GREAT SOUNDTRACKER DEMO!...."
 DC.B "             ....THE ALLIANCE...."
 DC.B "             ....OVERLANDERS...."
 DC.B "             ....PLOOPAGONS...."
 DC.B "             ....GHOST...."
 DC.B "             ....VECTOR...."
 DC.B "             ....FLEXIBLE FRONT...."
 DC.B "             ....2LIFE CREW - ANY FAN OF CALVIN AND HOBBES IS A PAL OF MINE!....."
 DC.B "             ....REPLICANTS...."
 DC.B "             ....DELTA FORCE...."
 DC.B "             ....LEVEL 16...."
 DC.B "             ....TNT CREW...."

 DC.B "             PERSONAL GREETS FROM OBERJE TO ....       " 
 DC.B "             ....LEELEE - KEEP CODING THOSE INTROS! ...."
 DC.B "             ....GOOSE...."
 DC.B "             ....7-ZARK-7 - BRUPT BEE BOOP!...."
 DC.B "             ....GRAHAME SUPREME OVERLORD OF THE UNIVERSE ...."
 DC.B "             ....THE FATT MAN CLUB....."
 DC.B "             ....TIM...."
 DC.B "             ....GORDON...."
 DC.B "             ....XAVIER...."
 DC.B "             ....ROZEL - ARE YOU STILL ALIVE! ...."
 DC.B "             ....TAMPER...."
 DC.B "             ....THE DEMO CLUB...."
 DC.B "             ....JOE 90 - NO HORSES IN THIS DEMO!, NO! NO DALMATIONS EITHER!...."
 DC.B "             ....FLASH - YOU NOW OWE ME ABOUT 6 PINTS!...."
 DC.B "             ....BOOTS - 'COR IMAGINE GETTING YOUR DICK BETWEEN THOSE TITS!' - QUOTE OF THE YEAR!...."
 DC.B "             ....FROSTY THE SNOWMAN - WRITE SOON! ....."
 DC.B "             ....BROTHER L.O.V.E - DO YOU STILL HAVE L.O.V.E IN YOUR HEART FOR THE ST ...."
 dc.b "             ....GIZMO - ( ORM! ) GOOD LUCK WITH YOUR EXAMS...."
 dc.b "             ....PIGGY - YOU ( LIKE ME ) NEEEEED A HAIRCUT BADLY! ...."
 
 DC.B "             PERSONAL GREETS FROM THE CAPED CRUSADER TO ....       " 
 DC.B "             ....ACME...."
 DC.B "             ....BATMAN...."
 DC.B "             ....BAUDERLINE...."
 DC.B "             ....LASSIE ELDRUP...."
 DC.B "             ....ZEDHAYTEY...."
 DC.B "             ....THE JOKER...."
 DC.B "             ....STEVIE...."
 DC.B "             ....WIG...."
 DC.B "             ....FOX...."
 DC.B "             ....FLUB...."
 DC.B "             ....JIMS...."
 DC.B "             AND LOTS OF LOVE AND KISSES TO ANN.  " *********
 
 DC.B " ..............THATS IT FOR NOW,    IF I MISSED YOU OUT, I'M SORRY, I WON'T DO IT AGAIN!!!!       "

 DC.B " IF YOU WANT TO SWAP DEMOS OR SOURCE OR JUST CHAT YOU CAN WRITE TO US AT THE FOLLOWING ADDRESS..........         "
 DC.B "    FINGERBOBS            C/O OBERJE              6 CARRON TERRACE             STONEHAVEN          AB3 2HX          SCOTLAND   "
 DC.B "       OR YOU CAN LEAVE A MESSAGE FOR EITHER ME ( OBERJE ), THE COUNT OR THE CAPED CRUSADER ON THE BATCAVE BBS       "
 DC.B "      THE NUMBER IS               03586 89049             IT IS ON MOST SPEEDS AND DURING MOST EVENINGS.           "
 DC.B "    WE ARE HOWEVER NOT INTERESTED IN JUST SWAPPING THE LATEST HACKED SOFTWARE, SO NO TIME WASTERS PLEASE!          "
 
 DC.B "    GOLLY GOSH, THIS FAR INTO THE SCROLLER AND I HAVEN'T EVEN MENTIONED            PATSY KENSIT         YET!    "
 DC.B "    OK,           HERE GOES.......                PATSY KENSIT : PHOOAR!              "

 DC.B "           AND NOW,          AS A SPECIAL TREAT,     THE MAD RAMBLINGS OF THE COUNT          HA HA HA HA ETC...           "
 
 dc.b 	"................    YIP YIP WIBBLE WIBBLE WIBBLE WIBBLE"
 DC.B	"           YES, WELL, EVENTUALLY OBERJE HAS MANAGED TO ASSEMBLE A"
 DC.B	" KEYBOARD,TEXT EDITOR AND MYSELF IN ONE PLACE AT THE SAME TIME SO I GUESS I'M EXPECTED TO"
 DC.B	" MAKE SOME CONTRIBUTION TO THIS AWESOME DEMO.          AH YES MERE "
 DC.B	"WORDS DESCRIBE NOT THE VERBOSITY OF ONE KEYBOARD CLICKING, "
 DC.B	"DICKEN STICKEN   (WAHHHAAAAY) , CHICKEN PICKEN              PRICK!!!              "
 DC.B	"THIS TEXT  (SHOULD IT EVER BE INCLUDED)   WILL PROBABLY BE AT THE END, (AND OBERJE'S GUARANTEED "
 DC.B	"WILL BE AT THE START )   SO I GUESS I'M WINDING THIS DEMO UP IN A WAY      ."
 DC.B	"              KIND OF SAD REALLY           I FEEL LIKE I KNOW EACH AND EVERY ONE "
 DC.B	" OF Y'ALL PERSONALLY            HERES A SONG THAT I THINK Y'ALL GOTTA HEAR. I WROTE IT "
 DC.B	" TO TELL Y'ALL JUST HOW MUCH I'M GONNA MISS YOU       AND IT GOES KINDA LIKE THIS................"
 DC.B 	" (LEGS CROSSED, GUITAR ON KNEE, SINCERE EXPRESSION )      "
 DC.B	"  STRUM STRUM A STRUMMETY STRUMMETY     WELL THIS HERE'S 'THE COUNT' AND I'VE GOT A HANKERING TO SAY, "
 DC.B	" THAT WE'LL BE GOING SOON, BUT HOPE TO MEET Y'ALL AGAIN SOME DAY,"
 DC.B	" I WAS DRIVIN' MY OLD ST ONE DAY , UP HIGHWAY 101, WATCHIN' THE GALS , WATCHIN' THEIR TITS ,"
 DC.B	"            HECK,        WATCHIN' THEIR BUMS. "
 DC.B	"           SHOOT, I DON'T KNOW WHOSE FAULT IT WAS , I COULDN'T RIGHTLY SAY "
 DC.B	" PROBABLY ON ACCOUNT OF THE FACT THAT I WAS LOOKING THE OTHER WAY....."
 DC.B	" BUT 2 TONNE IBM CAME ROLLING T'WORDS ME , PULLING 65 (MEGAHERTZ)"
 DC.B	" SUCH A SIGHT I NEVER DID SEE, KINDA MADE ME FEEL ALIVE,   Y'ALL KNOW WHAT I'M SAYIN' "
 DC.B	" SUCH WAS MY ADMIRATION,  OF HIS TRUE RAW  POWER,  I DIDN'T CATCH A  SIGHT "
 DC.B	"       OF THIS 20 FOOT HIGH, CONCRETE FLOWER,   JEEEEZ IT GAVE ME SUCH A FRIGHT!!"
 DC.B	"       SO I YANKED THE JOYSTICK EVERY-WHICH-WAY, TRYING TO AVOID A CONFRONTATION ,"
 DC.B	" WHEN THIS BEAUTIFUL, SMILIN' FAIRY A'PEARED, PHEW ! SHE WAS  AN INVITATION!! "
 DC.B	" SHE KINDA GLANCED  AT ME , LIFE IN HER EYES , SYMBOL OF OUR  NATION. I WAITED FOR HER TO SAY 'THREE WISHES...' "
 DC.B	" FOR TH'TWO OF US BOTH TO GO , WHEN SHE SAID ..        ' FUCK YOU ASSHOLE, I'M HERE TO WATCH THE SHOW' "
 DC.B	" IT WAS NOW I STARTED TO CUSS' 'N SWEAR , START TO  LOSE MY COOL A BIT"
 DC.B	"  WHEN AT THAT MOMENT MY BOWELS GAVE WAY, AND I DROPPED A 10 TONNE SHIT "
 DC.B	" WELL JUST THEN I COULDA CRIED,  I DIDN'T BELIEVE MY LUCK,  THE SHIT WAS SOFT AND SQUIDY AN  MY BODY WAS CUSHIONED BY THE MUCK."
 DC.B	"         I SURVIVED THAT DAY, THOUGH NO ONE WOULD STAY, TO TAKE ME TO THE INFIRMARY"
 DC.B	" I KIND OF STINKED, THAT WAS TRUE, BUT I LEARNED ONE THING YOU SHOULD ALWAYS DO."
 DC.B	" IF THE SITUATION'S LOOKIN' BAD , AND YOUR BOWELS ARE FULL OF SHIT....."
 DC.B	"ACCEPT THESE THINGS FOR WHAT THEY ARE, Y'ALL BEGIN TO RELY ON IT"
 DC.B	" NEVER WORRY , DON'T DESPAIR, SO WATT IF IT DOES GET IN YOUR HAIR "
 DC.B	" LET IT OUT , DON'T BE SHY, IF THERE'S NOTHING ELSE TO DO..."
 DC.B	" Y'ALL BE SITTIN 10 FOOT HIGH ON AN ENORMOUS PILE OF "	
 DC.B	"LIFE SAVING, NASAL DAZING, GARGANTUAN HUMAN POO!!!              TA    DAAAAA "
 DC.B	"         THIS IS THE FIRST FINGERBOB DISK EVER TO GO GOLD !!!!! (USUALLY THEY ARE GREY OR BLUE, BUT I GUESS YOU KNOW THAT!!    "
 DC.B	"  OH WELL !! SIGNING OFF NOW IS , REMEMBER THE NAME, THE COUNT!!!!!!!     "
 DC.B	"AAAAAAAAAAAARRRRRRRRRRRRRRRRGGGGGGGGGGGGGGGHHHHHHHHHHHH          "
 DC.B	"                   " 

 DC.B "  HA-HA! OBERJE BACK TO WRAP UP THE SCROLLER!      "
 
 DC.B "       LETS NOT HANG ABOUT,      I'LL JUST TELL YOU WHO THE FINGERBOBS ARE THEN YOU CAN GO!         " 
 DC.B "    THE FINGERBOBS ARE       (ON THE ST)        OBERJE        THE CAPED CRUSADER           PIXAR           UNDERCOVER ELEPHANT"
 DC.B "  THE COUNT         THE CREEPER         (ON THE AMIGA)        THE COUNT           THE CREEPER            ZEN           SHADES            "
 DC.B "       WELL THE SCROLLER DRAWS TO A ( NOT UNWARRENTED ) END, IT ONLY REMAINS FOR ME TO WISH YOU WELL, AND ABOVE"
 DC.B " ALL,         BE EXCELLENT TO EACH OTHER!          "
 DC.B "       NOW LETS WRAPP................"
 DC.B "                   "
 DC.B "                                            ",0

		**************
		* The Sprite *
		**************

	EVEN

char		incbin	C:\ASM\INSIG\sprite.dat	;16x16 Character Set

		even

blank_palette	dc.w	0,0,0,0
		dc.w	0,0,0,0
		dc.w	0,0,0,0
		dc.w	0,0,0,0
					
old_palette	ds.w	16

music		incbin	C:\ASM\INSIG\seven.mus
	
pic		incbin	fingpic.img
picture		equ	pic+34
new_palette	equ	pic+2

		********************************
		* The Two 256 byte Sine Tables *
		********************************
		
vertical	incbin	C:\ASM\INSIG\table100.dat
vertical2	incbin	C:\ASM\INSIG\table40.dat

sp_pal0 	dc.w $400,$511,$622 ;Red
sp_pal1 	dc.w $112,$223,$234 ;Blue
sp_pal2 	dc.w $421,$652,$764 ;Yellow
sp_pal4 	dc.w $001,$223,$234 ;Dark blue
sp_pal6 	dc.w $112,$233,$234 ;Dark Blue
sp_pal7 	dc.w $112,$333,$244 ;Dark Blue

sp_pal3 	dc.w $030,$250,$470 ;Green
sp_pal5 	dc.w $636,$646,$656 ;Pink

sp_pal8 	dc.w $424,$534,$644 ;Lialic?
sp_pal9		dc.w $555,$666,$777 ;Grey
sp_pal10        dc.w $033,$055,$077 ;Cyan


sprite_now	dc.l	1

		even
		
vector_store	ds.l	6

		even
		
x1		dc.b	0	;X,Y Displacements for
y1		dc.b	128	;both tables
cx1		dc.b	0	;For each sprite
cy1		dc.b	0
		ds.w	(nospr-1)*4

px1		ds.b	nospr*4

Xinc		dc.w	1	;Wave control
Yinc		dc.w	1	;Variables
X2inc		dc.w	1
Y2inc		dc.w	1
Wait		dc.w	1
XDisp		dc.w	8
YDisp		dc.w	8
X2Disp		dc.w	8
Y2Disp		dc.w	8

spr_wave	ds.l	1
frames	ds.w	1

*
* Frames,Xinc,Yinc,XDisp,YDisp,X2inc,Y2inc,X2Disp,Y2Disp,x1,y1,cx1,cy1
*
* If x1 = $ffff => Ignore x1,y1,cx1,cy1, use old values
*
spr_wave_tab dc.w 400
 dc.l sprite_data1,sp_pal0
 dc.w $fffe,$fffe,$fffe,$fffe,$2,$2,$ffe6,$ffe6,$32,$7f,$4f,$91
 
 dc.w 400
 dc.l sprite_data1,sp_pal8
 dc.w $0002,$fffc,$ff08,$ff79,$0006,$fff6,$0009,$ff7c,$f5,$c1,$bf,$1e
 
 dc.w 400
 dc.l sprite_data1,sp_pal9
 dc.w $0001,$fffd,$fff8,$0008,$0004,$0000,$0008,$0008,$92,$96,$4e,$40
 
 dc.w 400
 dc.l sprite_data6,sp_pal2
 dc.w $0004,$0002,$ffa8,$ffad,$0000,$0003,$0005,$0003,$08,$cc,$66,$67
 
 dc.w 400
 dc.l sprite_data4,sp_pal3
 dc.w $fffd,$0000,$00fc,$00f4,$0004,$0003,$0016,$0017,$47,$8a,$f9,$b3
 
 dc.w 400
 dc.l sprite_data6,sp_pal5
 dc.w $0000,$0000,$ff4e,$ff4e,$0005,$fffd,$0081,$0081,$16,$e4,$b8,$4f
 
 dc.w 400
 dc.l sprite_data1,sp_pal10
 dc.w $ffff,$ffff,$ff7a,$ff7a,$0005,$fffd,$0081,$0081,$96,$dc,$6d,$81
 
 dc.w 400
 dc.l sprite_data1,sp_pal3
 dc.w $0002,$0001,$ff1a,$ff1a,$0005,$fffd,$00f4,$00f4,$52,$4b,$0e,$ea
 
 dc.w 400
 dc.l sprite_data1,sp_pal5
 dc.w $fffe,$fffd,$fffe,$fffe,$0003,$0002,$0004,$ffad,$a3,$57,$8d,$0d
 
 dc.w 400
 dc.l sprite_data6,sp_pal10
 dc.w $0003,$fffd,$0004,$0001,$0002,$0002,$0000,$ff72,$0a,$22,$7d,$0e
 
 dc.w 400
 dc.l sprite_data1,sp_pal3
 dc.w $0002,$fffe,$fe82,$feff,$fffd,$fffe,$ffc0,$0082,$5b,$2c,$8a,$f6

 dc.w 400
 dc.l sprite_data1,sp_pal0
 dc.w $0002,$fffe,$fe82,$feff,$fffd,$fffe,$ff7c,$0040,$2d,$5a,$cf,$23
 
 dc.w 400
 dc.l sprite_data1,sp_pal1
 dc.w $0001,$fffe,$0008,$0008,$0000,$fff8,$000b,$0013,$44,$18,$00,$58
 
 dc.w 400
 dc.l sprite_data1,sp_pal10
 dc.w $0002,$fffe,$0001,$ffff,$0000,$0000,$ffb7,$ffb7,$7e,$2c,$4c,$0d

 dc.w 400
 dc.l sprite_data8,sp_pal0
 dc.w $0002,$fffc,$0080,$0080,$ffff,$ffff,$00b7,$00b7,$75,$81,$8d,$ce
 
 dc.w 400
 dc.l sprite_data3,sp_pal2
 dc.w $fffe,$ffff,$0029,$0029,$fffd,$fffc,$012c,$012b,$26,$f8,$7b,$f1

 dc.w 400
 dc.l sprite_data1,sp_pal0
 dc.w $0003,$0003,$0009,$0008,$0008,$fffd,$000d,$0007,$20,$16,$0a,$0e

 dc.w 400
 dc.l sprite_data1,sp_pal9
 dc.w $0002,$0002,$0008,$0008,$0005,$fffc,$0014,$fff2,$e0,$63,$11,$af
 
 dc.w 400
 dc.l sprite_data4,sp_pal5
 dc.w $fffd,$fffc,$fe02,$fd04,$0100,$ff1f,$00ff,$01e1,$61,$4f,$73,$60

 dc.w 400
 dc.l sprite_data1,sp_pal0
 dc.w $0001,$ffff,$fe02,$fd04,$00a5,$ff23,$035d,$ffda,$c7,$4a,$4a,$19

 dc.w 400
 dc.l sprite_data1,sp_pal8
 dc.w $0002,$fffe,$fffd,$0004,$0005,$fffa,$fffb,$fff6,$fa,$2b,$5f,$33
 
 dc.w 400
 dc.l sprite_data4,sp_pal2
 dc.w $0003,$ffff,$fff2,$fffd,$0009,$fffd,$fffb,$fff6,$42,$e5,$f7,$c0
 
 dc.w 400
 dc.l sprite_data1,sp_pal3
 dc.w $0002,$0002,$0008,$0008,$0000,$0000,$0000,$0000,$ffff,$0,$0,$0
 
 dc.w 400
 dc.l sprite_data1,sp_pal5
 dc.w $fffe,$fffe,$ffe7,$ffe8,$0002,$0002,$ffe6,$ffe6,$da,$09,$c5,$07
 
 dc.w 400
 dc.l sprite_data1,sp_pal9
 dc.w $fffe,$fffe,$00e4,$00e3,$0003,$0002,$ffe6,$ffe6,$c0,$0d,$e1,$19
 
 dc.w 400
 dc.l sprite_data1,sp_pal10
 dc.w $fffe,$fffe,$0068,$0067,$0002,$0002,$ffe6,$ffe6,$aa,$f7,$d7,$19
 
 dc.w 400
 dc.l sprite_data1,sp_pal9
 dc.w $00fb,$00f9,$ffa8,$ffa6,$fff8,$fffd,$fffb,$fffc,$7f,$07,$09,$b7
 
 dc.w 400
 dc.l sprite_data1,sp_pal2
 dc.w $fffc,$fffd,$0003,$0004,$fff8,$fffd,$fffb,$fffc,$81,$24,$a9,$f3
 
 dc.w 400
 dc.l sprite_data2,sp_pal0
 dc.w $0000,$0000,$fffe,$0002,$fffe,$fffe,$fff9,$0005,$ffff,$0,$0,$0
 
 dc.w 400
 dc.l sprite_data8,sp_pal3
 dc.w $fffe,$fffe,$ffff,$ffff,$0000,$0000,$0000,$0000,$27,$cd,$00,$72 
 
 dc.w 400
 dc.l sprite_data8,sp_pal9
 dc.w $0000,$0000,$fff2,$fffa,$0006,$fff8,$000d,$fff9,$44,$91,$5a,$17
 
 dc.w 400
 dc.l sprite_data1,sp_pal0
 dc.w $0000,$0000,$0008,$0008,$0001,$0001,$0008,$0008,$57,$99,$83,$c7
 
 dc.w 400
 dc.l sprite_data5,sp_pal6
 dc.w $0000,$0000,$0008,$0008,$fffd,$fffd,$0008,$0008,$ffff,0,0,0
 
 dc.w 400
 dc.l sprite_data3,sp_pal10
 dc.w $0001,$0001,$0008,$0008,$ffff,$ffff,$0008,$0008,$ffff,0,0,0
 
 dc.w 400
 dc.l sprite_data1,sp_pal0
 dc.w $0001,$0001,$0008,$0008,$fffe,$fffe,$0005,$0005,$25,$68,$ea,$31
 
 dc.w 400
 dc.l sprite_data1,sp_pal3
 dc.w $fffe,$fffd,$0008,$0008,$0003,$fffc,$fff1,$fffe,$f9,$8f,$73,$e2
 
 dc.w 400
 dc.l sprite_data1,sp_pal1
 dc.w $0002,$0002,$0008,$0008,$0003,$fffb,$0007,$0018,$5a,$e8,$41,$64
 
 dc.w 400
 dc.l sprite_data1,sp_pal9
 dc.w $fffd,$fffc,$0008,$0003,$000a,$fffb,$ffff,$0004,$0c,$a7,$68,$53
 
 dc.w 400
 dc.l sprite_data1,sp_pal8
 dc.w $0001,$0001,$000a,$000a,$ffff,$ffff,$0014,$0014,$31,$70,$2a,$70
 
 dc.w 400
 dc.l sprite_data1,sp_pal5
 dc.w $0002,$fffe,$0008,$0008,$fffd,$fffd,$00ea,$00e9,$dd,$e9,$c9,$1c
 
 dc.w 400
 dc.l sprite_data6,sp_pal2
 dc.w $fffe,$fffe,$0006,$fffc,$0008,$fffa,$ffe8,$0010,$36,$83,$70,$8f
 
 dc.w $ffff
 dc.l $ffffffff,$ffffffff
 dc.w $ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff,$ffff
 



****   ***   ***
*   * *   * *   *
*   * *     *  
****   ***   ***
*   *     *     *
*   * *   * *   *
****   ***   ***

	


	even
		
oldres		ds.w	1
old_sp		ds.l	1
old_physbase 	ds.l	1


location	ds.l	1
	
	even

slice		ds.w	1		
stopped		ds.w	1
idle		ds.w	1
here		ds.l	1

			
sp1	ds.l	1
sp2	ds.l	1
sp3	ds.l	1
sp4	ds.l	1

old_scroll	ds.l	1
oldscr1		ds.l	1
oldscr2		ds.l	1
oldscr3		ds.l	1

	ds.l	100
stack	ds.l	1	


screen_a	ds.l	1
screen_b	ds.l	1
screen_c	ds.l	1
screen_d	ds.l	1
screen_e	ds.l	1
screen_f	ds.l	1
screen_g	ds.l	1
screen_h	ds.l	1

	even


work		ds.b	8*32	;Work Area
sprite_data1	ds.b	4096	;Sprite Data
sprite_data2	ds.b	4096	;Sprite Data
sprite_data3	ds.b	4096	;Sprite Data
sprite_data4	ds.b	4096	;Sprite Data
sprite_data5	ds.b	4096	;Sprite Data
sprite_data6	ds.b	4096	;Sprite Data
sprite_data7	ds.b	4096	;Sprite Data
sprite_data8	ds.b	4096	;Sprite Data

old_spr1	ds.l	nospr
old_spr2	ds.l	nospr
old_spr3	ds.l	nospr
old_spr4	ds.l	nospr

old_sprites	ds.l	1	;Addresses of old sprites 1
old1		ds.l	1	;Addresses of old sprites 2
old2		ds.l	1	;Addresses of old sprites 3
old3		ds.l	1	;Addresses of old sprites 4



scroll_data	ds.b	40*18
put_data	equ	scroll_data+39


		*********** END OF USED MEMORY *******

screens		ds.l	1


	
***********
* THE END *
***********






