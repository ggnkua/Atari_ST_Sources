***************************************************************************
***************************************************************************
**                                                                       **
**  ###### ####### ###  ## ######### ### ######  ####### ######  ####### ** 
** ###     ###     #### ##    ###    ### ###  ## ###     ###  ## ###     **
** ###     #####   #######    ###    ### ######  #####   ###  ## #####   **
** ###     ###     #######    ###    ### ###     ###     ###  ## ###     **
** ###     ###     ### ###    ###    ### ###     ###     ###  ## ###     **
**  ###### ####### ###  ##    ###    ### ###     ####### ######  ####### **
**                                                                       **
***************************************************************************
***************************************************************************
**                              CODED BY                                 **
**                            MIKE  WATSON                               **
***************************************************************************
***************************************************************************

	opt	o+
	
	include	d:\centiped.e\c_macros.s

centipede	bra	.go4it
	dc.b	'Wow you managed to unpack it, that must have '
	dc.b	'REALLY hard . . . . . . . . . . . NOT!'
	dc.b	' . . . . . . . . . . . . '
	dc.b	'There aren''t any hidden messages so don''t '
	dc.b	'bother looking for them.'
	dc.b	'To cheat you will have to train it coz there '
	dc.b	'isn''t a built in one he he!'
	dc.b	'Please Please Please do not spread the game'
	dc.b	' if it is not in this packed format because it'
	dc.b	' will probably not work on a tt or falcon!'
	dc.b	'BAAAAAAAAAAAAAAA!!!'
	even

.go4it	pea	stack
	move.w	#$20,-(a7)
	trap	#1
	addq	#6,a7
	move.l	d0,old_ssp

	bsr	load_hi_scores
	bsr	setup_everything
	bsr	shareware_message
.loop	bsr	set_up_intro
.loop2	bsr	intro
; only process keys  if not demo mode
	tst.w	demo_mode	
	bne.s	.gam
.go_on	cmp.b	#$3f,d0	; F5 and under starts game
	ble.s	.gam	
	cmp.b	#$43,d0	; F9 saves
	beq.s	.sav

; exit if appropriate key was pressed
	bra.s	.exit	; F10

; save scores if appropriate key was pressed
.sav	bsr	save_hi_scores
	bra.s	.loop2


; start game if appropriate key was pressed

.gam	tst.w	demo_mode	; if not demo mode then get wave info
	beq.s	.gam_go
	lea	demo_star,a0	; load demo wave
	move.l	a0,curr_wave
	bra.s	.gam_go2	
.gam_go	sub.b	#$3b,d0	
	lsl.w	#2,d0
	lea	parms_tab,a0
	lea	(a0,d0.w),a0
	move.l	(a0),curr_wave
.gam_go2	bsr	set_up_game
	bsr	game
	tst.w	demo_mode	; if demo mode then dont process scores
	bne.s	.loop
	sf	cheat	; game over os reset cheat flag
	clr.w	ptim1+2
	clr.w	ptim2+2
	clr.w	ccol+2	; ???
	tst.w	abortf	; if abort then dont process scores
	bmi.s	.loop

	bsr	set_up_hi_scores
	cmp.b	#16,d2	; did we get into the table
	beq	.loop	; obviously not
	bsr	hi_scores	
	bra	.loop	; back to intro

.exit	bsr	restore_everything
	move.l	old_ssp,-(a7)
	move.w	#$20,-(a7)
	trap	#1
	addq	#6,a7

	clr.l	-(a7)
	trap	#1	
;
; routine to load current hi score table
; if not found then use default
;
load_hi_scores
	move.w	#2,-(a7)
	pea	filename(pc)
	move.w	#$3D,-(a7)
	trap	#1	; open
	addq.w	#8,a7
	tst.w	d0
	bmi.s	.exit	; not here?

	move.w	d0,handle
	pea	hst
	pea	760.w
	move.w	d0,-(a7)
	move.w	#$3F,-(a7)
	trap	#1	; read
	lea	$C(a7),a7
	bsr.s	close

.exit	bsr	crypt_scores
	rts

close	move.w	handle,-(a7)
	move.w	#$3E,-(a7)
	trap	#1	; close
	addq.w	#4,a7
	rts
;
; this routine saves all the interrupts
; saves the scores and restores interrupts
; my super amazing icd board never needed the interrupt
; restore but gordons lame gasteiner did! 

save_hi_scores
	move.w	#$2700,sr		; save interrupts
	lea	crap2,a0
	move.l	$68.w,(a0)+
	move.l	$70.w,(a0)+
	move.l	$118.w,(a0)+
	move.l	$120.w,(a0)+

	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa17.w,(a0)+
	move.b	$fffffa1d.w,(a0)+

	lea	crap,a0
	move.l	(a0)+,$68.w
	move.l	(a0)+,$70.w
	move.l	(a0)+,$118.w
	move.l	(a0)+,$120.w
	addq	#4,a0
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa17.w
	move.b	(a0)+,$fffffa1d.w
	move.b	#-$40,$fffffa23.w

	move.b	#7,$ffff8800.w
	or.b	#%11000000,$ffff8802.w

	move.w	#$2300,sr

	bsr	crypt_scores	; encrypt scores
	clr.w	-(a7)
	pea	filename(PC)
	move.w	#$3C,-(a7)
	trap	#1	; create
	addq.w	#8,a7
	tst.w	d0
	bmi.s	.exit	
	move.w	d0,handle

	pea	hst
	pea	760.w
	move.w	d0,-(a7)
	move.w	#$40,-(a7)
	trap	#1	; write
	lea	$C(a7),a7
	bsr	close
.exit	bsr	crypt_scores	; de-encrypt scores

	move.w	#$2700,sr		; restore interrupts
	lea	crap2,a0
	move.l	(a0)+,$68.w
	move.l	(a0)+,$70.w
	move.l	(a0)+,$118.w
	move.l	(a0)+,$120.w

	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa17.w
	move.b	(a0)+,$fffffa1d.w
	
	move.w	#$2300,sr
	rts

; Multi purpose subroutines
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Save interrupts and other things ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
setup_everything
	move.w	#$2700,sr
	moveq	#1,d0
	jsr	mus	; init tune 1
	moveq	#1,d0
	jsr	mus2	; init tune 2

	clr.b	screen1+3		; Put screens on a page boundary
	move.l	screen1(pc),a0
	add.l	#$8000,a0
	move.l	a0,screen2
	lea	yyyyyyy,a0	; zap memory
	lea	xxxxxxx,a1
 	bsr	clr

	bsr	generate_game_sprites	; obvious!

	movem.l	$ffff8240.w,d0-7
	movem.l	d0-7,old_pal

	move.l	#int_text,txt_ptr
	bsr	set_seed	; set up init seed for rand numbers	
	lea	crap,a0

	move.l	$68.w,(a0)+	; save interrupts
	move.l	$70.w,(a0)+
	move.l	$118.w,(a0)+
	move.l	$120.w,(a0)+
	move.l	$404.w,(a0)+
	move.b	$fffffa07.w,(a0)+
	move.b	$fffffa09.w,(a0)+
	move.b	$fffffa13.w,(a0)+
	move.b	$fffffa15.w,(a0)+
	move.b	$fffffa17.w,(a0)+
	move.b	$fffffa1d.w,(a0)+
	move.b	$ffff8260.w,(a0)+
	move.b	$ffff8201.w,(a0)+
	move.b	$ffff8203.w,(a0)+
	move.b	$ffff820a.w,(a0)+

	bclr	#3,$fffffa17.w
	move.b	#1,$fffffa07.w
	move.b	#$40,$fffffa09.w
	move.b	#1,$fffffa13.w
	move.b	#$40,$fffffa15.w
	bset	#1,$ffff820a.w
	move.l	#hbl,$68.w
	move.l	#hbl,$118.w
	move.l	#hbl,$120.w
	
	move.l	#cevnt,$404.w	; stops gem alert if disk error

	move.l	#vbl,$70.w
	move.w	#$2300,sr

	bsr	vsync

	move.b	screen1+1(pc),$ffff8201.w	; set screen address
	move.b	screen1+2(pc),$ffff8203.w

	bsr	vsync

	clr.b	$ffff8260.w	; low rez	
	bsr	vsync

	move.b	#$12,d0	; mouse off	
	bsr	sikbd
	bsr	ksync
	move.b	#$1a,d0	; joy off	
	bsr	sikbd
	bsr	ksync
	move.l	#k_route1,$118.w

	rts
;
;;;;;;;;;;;;;;;;;;
; Restore things ;
;;;;;;;;;;;;;;;;;;
;
restore_everything
	move.w	#$2700,sr
	bsr	ksync
	moveq	#0,d0
	jsr	mus	; kill tune 1
	move.l	#vbl,$70.w	; restore interrupts
	lea	crap,a0
	move.l	(a0)+,$68.w
	move.l	(a0)+,-(a7)
	move.l	(a0)+,$118.w
	move.l	(a0)+,$120.w
	move.l	(a0)+,$404.w
	move.b	(a0)+,$fffffa07.w
	move.b	(a0)+,$fffffa09.w
	move.b	(a0)+,$fffffa13.w
	move.b	(a0)+,$fffffa15.w
	move.b	(a0)+,$fffffa17.w
	move.b	(a0)+,$fffffa1d.w
	move.b	#-$40,$fffffa23.w
	move.w	#$2300,sr
	bsr	vsync
	move.b	(a0)+,$ffff8260.w
	move.b	(a0)+,$ffff8201.w
	move.b	(a0)+,$ffff8203.w
	move.b	(a0)+,$ffff820a.w

	bsr	vsync

	movem.l	old_pal,d0-7	; restore dektop pallete
	movem.l	d0-7,$ffff8240.w	
;
; Turn on drive coz music kills it
;
	move.b	#7,$ffff8800.w
	or.b	#%11000000,$ffff8802.w
;
; restore IKBD
;
	moveq	#0,d0
	move.w	#$8000,d0
.1	dbf	d0,.1
	move.w	#$8000,d0
.2	dbf	d0,.2
	move.w	#$8000,d0
.3	dbf	d0,.3

	move.b	#$8,d0			; Restore ikbd
	bsr	sikbd
	move.b	#$1a,d0			; Restore ikbd
	bsr	sikbd
	move.b	#$80,d0			; Restore ikbd
	bsr	sikbd
	move.b	#$1,d0			; Restore ikbd
	bsr	sikbd
	move.l	(a7)+,$70.w	
	move.l	#$8080000,$ffff8800.w	;
	move.l	#$9090000,$ffff8800.w	; Clear soundchip
	move.l	#$a0a0000,$ffff8800.w	;
	rts
;
; display shareware messages
;

shareware_message
	move.l	#hi_vbl,$70.w
; print language choices
	lea	lang,a4	
	bsr	print_line
	bsr	zoom_in	; show them
; decide on key pressing stuff
.1	move.b	chip_val,d0
	cmp.b	#$01,d0	; escape!
	beq	.hi_dave
	cmp.b	#$02,d0	; 1
	blt.s	.1
	cmp.b	#$06,d0	; 5
	bgt.s	.1
	move.l	d0,-(a7)
	bsr	zoom_out	; clear them
	move.l	(a7)+,d0
; get appropriate text
	subq	#2,d0
	and.l	#$ff,d0
	lea	mess_tab,a0
	lsl.w	#3,d0
	lea	(a0,d0.w),a3
	move.l	(a3)+,a4
	move.l	a3,-(a7)
	bsr	print_line
	bsr	zoom_in	; show it
	bsr.s	.fuckuassholes	; a wee wait loop
; decide on key pressing stuff
.2	move.b	chip_val,d0
	cmp.b	#$01,chip_val
	blt.s	.2	
	cmp.b	#$72,chip_val
	bgt.s	.2	
	bsr	zoom_out	; clear them
	move.l	(a7)+,a3
	move.l	(a3)+,a4
	bsr	print_line	; show next page
	bsr	zoom_in
	bsr.s	.fuckuassholes	; wait again
.3	move.b	chip_val,d0
	cmp.b	#$01,chip_val
	blt.s	.3	
	cmp.b	#$72,chip_val
	bgt.s	.3	

.exit	bsr	zoom_out
	rts
; a wee 5 second delay to make sure people read the messages (bastards)
.fuckuassholes
	move.l	#5*50,d7
.fuck1	bsr	vsync
	dbf	d7,.fuck1
	rts
; special bypass screen for non lamers like baldrick(not!)
.hi_dave	bsr	zoom_out
	lea	hi_dave,a4
	bsr	print_line
	bsr	zoom_in
.4	move.b	chip_val,d0
	cmp.b	#$02,d0
	blt.s	.4
	cmp.b	#$72,d0
	bgt.s	.4
	bra.s	.exit
;
; code to set up the intro
;
set_up_intro
	bsr	flush_buffers	; kill all sprites 
	lea	free_ram,a0
	lea	xxxxxxx,a1
	bsr	clr		; zap ram

	move.w	#$2700,sr	; all kill & black pallete 
	moveq	#7,d0
	lea	$ffff8240.w,a0
.1	clr.l	(a0)+
	dbf	d0,.1

	move.l	#$8080000,$ffff8800.w	;
	move.l	#$9090000,$ffff8800.w	; Clear soundchip
	move.l	#$a0a0000,$ffff8800.w	;

; plot the centipede logo
	lea	clog,a0
	move.l	screen1(pc),a1
	move.l	screen2(pc),a2
	addq.w	#8,a1
	addq.w	#8,a2
	moveq	#23,d1
.1_logo	moveq	#35,d0
.1_line	move.l	(a0),(a1)+		
	move.l	(a0)+,(a2)+
	dbf	d0,.1_line			
	lea	16(a1),a1
	lea	16(a2),a2
	dbf	d1,.1_logo
; generate the intro sprites (uses zoom in buffer)		
	lea	ints_buff,a1
	build_spr	int_c,16,2,masked,nclip
	build_spr	int_e,16,2,masked,nclip
	build_spr	int_n,16,2,masked,nclip
	build_spr	int_t,16,2,masked,nclip
	build_spr	int_i,16,2,masked,nclip
	build_spr	int_p,16,2,masked,nclip
	build_spr	int_d,16,2,masked,nclip
; set up text displayer
	moveq	#0,d0
	move.w	d0,curr_x
	move.w	#4,curr_y
	move.l	d0,xc
	move.w	#-1,stay_cnt
	sf	demo_mode
	sf	dm
	move.l	#int_text,txt_ptr

	move.b	#$8,d0
	bsr	sikbd
	move.b	#$7,d0
	bsr	sikbd
	move.b	#%00000100,d0
	bsr	sikbd
	sf	f_p_on_intro
	bsr	ksync
	move.w	#$2300,sr	; enable all
	move.l	#k_route1,$118.w

	move.l	#intro_vbl,$70.w
	rts
;
; set up high score entry
;

set_up_hi_scores
	bsr	flush_buffers	; kill sprites
	move.l	#$00060013,namex	; curr name coords
	moveq	#79,d0
	move.l	#$00a00064,d1	; set up table of mouse coords
	lea	c_tab,a0
.loop	move.l	d1,(a0)+
	dbf	d0,.loop
	move.l	d1,hx_coord

	lea	free_ram,a0	; zap ram
	lea	xxxxxxx,a1
	bsr	clr

	move.l	#$8080000,$ffff8800.w	;
	move.l	#$9090000,$ffff8800.w	; Clear soundchip
	move.l	#$a0a0000,$ffff8800.w	;

wah	lea	score+8,a0	; end of score
	bsr	c_score		; pack into nibbles!
	move.l	d7,d1		; keep safe
	lea	hst,a1		; load table
.try_again
	lea	8(a1),a0		; end of entry
	bsr	c_score		; convert
	cmp.l	d1,d7		; is current score bigger?
	ble.s	.higher		; yep
	addq	#1,d2		
	lea	40(a1),a1		; get next score
	cmp.l	#blah,a1		; end?
	beq.s	.higher		; yep
	bra.s	.try_again	; looooop	
.higher	cmp.w	#16,d2		; lamer so exit
	beq.s	.exit
	move.l	a1,score_pos	; store position in table
	not.w	d2
	add.w	#15,d2
	bmi.s	.no_copy		; last entry!
	lea	here,a1		; move entries down	
.all	lea	40(a1),a0
	moveq	#39,d0
.loop	move.b	(a1)+,(a0)+
	dbf	d0,.loop
	lea	-80(a1),a1
	dbf	d2,.all	
.no_copy	move.l	score_pos,a0	; move your score in
	move.l	score,(a0)
	move.l	score+4,4(a0)
	add.l	#$10101010,(a0)	; convert into my format
	add.l	#$10101010,4(a0)

	move.l	#hi_vbl,$70.w
	bsr	ksync
	move.l	#hi_key2,$118.w
	move.b	#$8,d0	; mouse on
	bsr	sikbd
	bsr	ksync

	lea	hs_txt,a4		; show name select screen
	bsr	print_line
	bsr	zoom_in
	clr.b	chip_val
.exit	rts
;
; set up game
;
set_up_game
	move.l	#vbl,$70.w	; null vbl
	bsr	vsync
	bsr	flush_buffers	; kill sprites
	moveq	#0,d1
	bsr	kill_beasties	

	lea	free_ram,a0	; zap ram
	lea	xxxxxxx,a1
	bsr	clr

	movem.l	game_pal,d0-7
	movem.l	d0-7,$ffff8240.w

	move.l	#$8080000,$ffff8800.w	;
	move.l	#$9090000,$ffff8800.w	; Clear soundchip
	move.l	#$a0a0000,$ffff8800.w	;

	move.l	#firend,fire_vol		; kill sfx
	move.l	#mushend,mush_vol
	move.l	#bangend,bang_vol
	move.l	#extraend,extra_vol
	move.l	#dieend,die_vol

	tst.w	demo_mode			; if demo then no mouse
	bne.s	.no_mouse

	move.b	#$7,d0
	bsr	sikbd
	move.b	#%00000001,d0
	bsr	sikbd

	move.b	#$8,d0	; mouse on
	bsr	sikbd
	bsr	ksync

.no_mouse	move.l	#game_key2,$118.w
	move.l	#game_vbl,$70.w
	bsr	set_map			; set up mushies
	bsr	plot_screen		; plot them
	bsr.s	clear_vars		; set up variables

	tst.w	demo_mode	
	bne.s	.1
; standard screen set up - score 00000        lives 0
	bsr	set_up_score_gfx
	bsr	plot_scores
	bsr	plot_lives
	rts
; demo screen set up -         demo
.1	move.l	#game_vbl,$70.w
	bsr	plot_demo
	rts
;
; set up variables for start of game.
; includes a bit of anti lamer protection!!!
;

clear_vars	
	lea	score,a6	; take all offsets from here!

	moveq	#0,d0
	moveq	#1,d2
	move.w	lives-score(a6),d1
	eor.w	d1,lives-score(a6)	; dont ask!
	move.l	d0,score-score(a6)
	move.l	d0,score+4-score(a6)
	add.w	d2,lives-score(a6)

	move.l	curr_wave,a5	; set up wave info
	move.w	(a5),ce_cnt-score(a6)
	move.w	#8,ce_cntr-score(a6)	; no of vbls before adding centi
	move.w	(a5),c2kill-score(a6)
	move.w	(a5)+,c4level-score(a6)
	move.w	(a5)+,spider_tot-score(a6)
	move.w	(a5)+,scorp_tot-score(a6)
	move.w	(a5)+,snail_tot-score(a6)
	move.w	(a5)+,fly_tot-score(a6)
	move.w	(a5)+,bee_tot-score(a6)
	move.w	(a5)+,wave-score(a6)
	move.w	(a5)+,diff-score(a6)

	move.w	d0,scorps_on_screen		; zap these
	move.w	d0,spiders_on_screen
	move.w	d0,bees_on_screen
	move.w	d0,flys_on_screen
	move.w	d0,snails_on_screen

	move.w	#2,nxt_life-score(a6)
	sf	live_lost-score(a6)
	add.w	d2,lives-score(a6)
	move.w	#X_START,x_coord-score(a6)	; your coords
	move.w	#Y_START,y_coord-score(a6)
	move.w	#X_START,lx_coord-score(a6)	; used in player mushie c-detect
	move.w	#Y_START,ly_coord-score(a6)
	move.w	d0,pausef-score(a6)		; pause and abort flags
	move.w	d0,abortf-score(a6)
	move.l	#-1,bx_coord-score(a6)	; bullet coords
	tst.w	demo_mode-score(a6)		; if demo then set up timer
	beq.s	.exit
	move.w	#25*50,demo_count-score(a6)
.exit	add.w	d2,lives-score(a6)		; dont ask!
	rts
;
; general routine to swap physical and logical screens 
;

flip_screens
	move.l	screen2(pc),d0
	move.l	screen1(pc),screen2
	move.l	d0,screen1
	lsr.w	#8,d0
	move.b	d0,$ffff8203.w
	swap	d0
	move.b	d0,$ffff8201.w
	rts
;
; General purpose vbl
;
vbl	st	vbldone
	addq	#1,r_val
	rte

; critical event handler, kills off gem alert if disk error
cevnt	rts

; General purpose hbl

hbl	rte
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Sync in the keyboard chip ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
sikbd
.1	btst	#1,$fffffc00.w
	beq.s	.1                           
	move.b	d0,$fffffc02.w
	rts
ksync
.1	btst	#0,$fffffc00.w
	beq.s	.2
	move.b	$fffffc02.w,d0
	bra.s	.1
.2	rts
;
; Wait for a vbl
;
vsync	tst.w	vbldone
	beq.s	vsync
	sf	vbldone
	rts
;
; General purpose key route, mainly on intro 
;
k_route1	move.w	#$2500,sr
	move.w	d0,-(a7)
	tst.w	f_p_on_intro	; if fire pressed on intro then exit
	bne	.bye	
	move.b	$fffffc02.w,d0																														
	cmp.b	#$74,d0	; any packet headers
	blt.s	.nm	; nope	
	cmp.b	#$75,d0	; mouse?
	bgt.s	.nm	; no	
	st	f_p_on_intro

.nm	move.b	d0,chip_val	
	tst.w	cheat	; if cheat mode set then dont process
	bne.s	.bye
	movem.l	d0-1/a0,-(a7)
	move.l	cval,a0
	move.b	chip_val,d0
	cmp.b	#$01,d0
	blt.s	.exit
	cmp.b	#$3a,d0
	bgt.s	.exit
	move.b	(a0),d1
	cmp.b	d0,d1
	bne.s	.rs
	subq.w	#3,ccol+2
	addq	#1,a0
	cmp.l	#esick,a0
	bne.s	.rs1
	st	cheat
	move.w	#$002,ptim1+2
	move.w	#$002,ptim2+2
	bra.s	.rs1
.rs	clr.w	ccol+2
	lea	sick,a0
.rs1	move.l	a0,cval	
.exit	movem.l	(a7)+,d0-1/a0
.bye	bclr	#6,$fffffa11.w
	move.w	(a7)+,d0
	rte
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; This is one big fat mutha of a sprite routine. It actually   ;
; BUILDS the best sprite routine possible for the given sprite ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
build_sprite_routes	
	moveq	#0,d0
	move.w	d0,rot_offset
	lea	last_mask,a5
rotate	move.w	scanlines,d5
	move.l	a6,a0
	clr.w	offset	
	sf	poss_long_soon
	move.l	a1,(a2)+
loop	moveq	#0,d4
	movem.w	(a0)+,d0-3	; Get scanline

	and.l	#$ffff,d0
	and.l	#$ffff,d1
	and.l	#$ffff,d2
	and.l	#$ffff,d3
	move.w	rot_offset,d4

	swap	d0
	lsr.l	d4,d0	; Rotate plane 0
	swap	d1
	lsr.l	d4,d1	; Rotate plane 1
	swap	d2
	lsr.l	d4,d2	; Rotate plane 2
	swap	d3
	lsr.l	d4,d3	; Rotate plane 3

	tst.w	mask_flag	; see if mask required
	beq.s	.go_on

; build mask for 1st 16 pixels

	swap	d0
	move.w	d0,d4
	swap	d0
	swap	d1
	or.w	d1,d4
	swap	d1
	swap	d2
	or.w	d2,d4
	swap	d2
	swap	d3
	or.w	d3,d4
	swap	d3
	not.w	d4
	beq.s	.check2
	cmp.w	#-1,d4
	beq.s	.check2	; check for no mask
	bsr 	build_mask

; build mask for 2nd 16 pixels
	
.check2	move.w	d0,d4
	or.w	d1,d4
	or.w	d2,d4
	or.w	d3,d4
	not.w	d4

	cmp.w	#-1,d4	; check for no mask
	beq.s	.go_on
	addq	#8,offset
	bsr	build_mask
	subq	#8,offset

; Set up planes 0 & 1 (1st 16 pxls) 

.go_on	move.l	d0,d6	; P0 1st hi
	move.l	d1,d7
	swap	d7
	move.w	d7,d6	; P1 1st lo
	bsr	build_data	
	addq	#4,offset
	
; Set up planes 2 & 3 (1st 16 pxls)
 
	move.l	d2,d6	; P2 1st hi
	move.l	d3,d7
	swap	d7
	move.w	d7,d6	; P3 1st lo
	bsr	build_data	
	addq	#4,offset
	
; Set up planes 0 & 1 (2nd 16 pxls) 

	move.l	d0,d6	; P0 2nd hi
	swap	d6
	move.w	d1,d6	; P1 2nd lo
	bsr	build_data	
	addq	#4,offset

; Set up planes 2 & 3 (2nd 16 pxls)
 
	move.l	d2,d6	; P2 2nd hi
	swap	d6
	move.w	d3,d6	; P3 2nd lo
	bsr	build_data	
	add.w	#148,offset
	sf	poss_long_soon
	dbf	d5,loop	; One rotation done

	move.w	#$4e75,(a1)+	; rts
	move.w	interval,d0
	add.w	d0,rot_offset	; Next rotation
	cmp.w	#16,rot_offset	; Done ?
	bne	rotate	; No
	rts

build_rclip_sprites
	moveq	#0,d0
	move.w	d0,rot_offset
	lea	last_mask,a5
.rotate	move.w	scanlines,d5
	move.l	a6,a0
	clr.w	offset	
	sf	poss_long_soon
	move.l	a1,(a2)+
.loop	moveq	#0,d4
	movem.w	(a0)+,d0-3	; Get scanline

	and.l	#$ffff,d0
	and.l	#$ffff,d1
	and.l	#$ffff,d2
	and.l	#$ffff,d3
	move.w	rot_offset,d4

	swap	d0
	lsr.l	d4,d0	; Rotate plane 0
	swap	d1
	lsr.l	d4,d1	; Rotate plane 1
	swap	d2
	lsr.l	d4,d2	; Rotate plane 2
	swap	d3
	lsr.l	d4,d3	; Rotate plane 3

	tst.w	mask_flag	; see if mask required
	beq.s	.go_on

; build mask for 1st 16 pixels

	swap	d0
	move.w	d0,d4
	swap	d0
	swap	d1
	or.w	d1,d4
	swap	d1
	swap	d2
	or.w	d2,d4
	swap	d2
	swap	d3
	or.w	d3,d4
	swap	d3
	not.w	d4
	beq.s	.go_on
	cmp.w	#-1,d4
	beq.s	.go_on	; check for no mask
	bsr 	build_mask

; Set up planes 0 & 1 (1st 16 pxls) 

.go_on	move.l	d0,d6	; P0 1st hi
	move.l	d1,d7
	swap	d7
	move.w	d7,d6	; P1 1st lo
	bsr	build_data	
	sf	poss_long_soon
	addq	#4,offset
	
; Set up planes 2 & 3 (1st 16 pxls)
 
	move.l	d2,d6	; P2 1st hi
	move.l	d3,d7
	swap	d7
	move.w	d7,d6	; P3 1st lo
	bsr	build_data	
	add.w	#156,offset
	sf	poss_long_soon
	dbf	d5,.loop	; One rotation done
	move.w	#-1,(a5)
	move.w	#$4e75,(a1)+	; rts
	move.w	interval,d0
	add.w	d0,rot_offset	; Next rotation
	cmp.w	#16,rot_offset	; Done ?
	bne	.rotate	; No
	rts

build_lclip_sprites	
	moveq	#0,d0
	move.w	d0,rot_offset
	lea	last_mask,a5
.rotate	move.w	scanlines,d5
	move.l	a6,a0
	clr.w	offset	
	sf	poss_long_soon
	move.l	a1,(a2)+
.loop	moveq	#0,d4
	movem.w	(a0)+,d0-3	; Get scanline

	and.l	#$ffff,d0
	and.l	#$ffff,d1
	and.l	#$ffff,d2
	and.l	#$ffff,d3
	move.w	rot_offset,d4

	swap	d0
	lsr.l	d4,d0	; Rotate plane 0
	swap	d1
	lsr.l	d4,d1	; Rotate plane 1
	swap	d2
	lsr.l	d4,d2	; Rotate plane 2
	swap	d3
	lsr.l	d4,d3	; Rotate plane 3

	tst.w	mask_flag
	beq.s	.go_on

; build mask for 2nd 16 pixels
	
.check2	move.w	d0,d4
	or.w	d1,d4
	or.w	d2,d4
	or.w	d3,d4
	not.w	d4

	cmp.w	#-1,d4
	beq.s	.go_on
	bsr.s	build_mask
.go_on
; Set up planes 0 & 1 (2nd 16 pxls) 

	move.l	d0,d6	; P0 2nd hi
	swap	d6
	move.w	d1,d6	; P1 2nd lo
	bsr.s	build_data	
	sf	poss_long_soon
	addq	#4,offset

; Set up planes 2 & 3 (2nd 16 pxls)
 
	move.l	d2,d6	; P2 2nd hi
	swap	d6
	move.w	d3,d6	; P3 2nd lo
	bsr.s	build_data	
	add.w	#156,offset
	sf	poss_long_soon
	dbf	d5,.loop	; One rotation done
	move.w	#-1,(a5)

	move.w	#$4e75,(a1)+
	move.w	interval,d0
	add.w	d0,rot_offset	; Next rotation
	cmp.w	#16,rot_offset	; Done ?
	bne	.rotate	; No
	rts

; Build mask

build_mask
	move.w	(a5),d6
	cmp.w	d4,d6
	beq.s	.1
	move.w	#$203c,(a1)+	; move.l #yyyy,d0
	move.w	d4,(a1)+
	move.w	d4,(a1)+
	move.w	d4,(a5)
.1	tst.w	offset
	bne.s	.2
	move.w	#$c190,(a1)+	; andi.w d0,(a0)
	bra.s	.3	
.2	move.w	#$c1a8,(a1)+	; andi.w d0,y(a0)
	move.w	offset,(a1)+
.3	move.w	#$c1a8,(a1)+	; andi.w d0,y(a0)
	move.w	offset,(a1)
	addq	#4,(a1)+
	rts

; Build code for the data

build_data
	cmp.l	#0,d6	; Totally blank?
	beq	.e_sf

	swap	d6
	move.w	d6,d7
	swap	d6
	cmp.w	#0,d7	; P0/P2 blank
	bne.s	.test_p1p3
	moveq	#0,d7
	move.w	d6,d7	
	lsr.w	#8,d7	
	bne.s	.no_mq1
	move.b	d6,d7	
	bmi.s	.no_mq1
	move.w	#-1,(a5)
	move.b	#$70,(a1)+	; moveq #xx,d0
	move.b	d6,(a1)+
	tst.w	offset
	bne.s	.1
	move.w	#$8150,(a1)+
	bra	.exit	
.1	move.w	#$8168,(a1)+	; ori.w d0,y(a0)
	addq	#2,offset
.2	move.w	offset,(a1)+
	subq	#2,offset
	bra	.exit

.no_mq1	st	poss_long_soon	; Or on plane 1/3 only
	addq	#2,offset		; Possible to combine with next ins
	move.w	#$0068,(a1)+	; ori.w #xxxx,y(a0)
	move.w	d6,(a1)+		; #xxxx
	move.w	offset,(a1)+	; y(
	subq	#2,offset
	bra	.exit	

.test_p1p3
	cmp.w	#0,d6	; P1/P3 blank
	bne.s	.orl
	move.b	poss_long_soon,d7 ; Can we combine with
	beq.s	.norm_orw		  ; last statement
	move.w	#$00a8,-6(a1)	  ; ori.l
	move.w	-2(a1),d7		  ; Offset
	move.w	d7,(a1)+		  ; To here please
	swap	d6
	move.w	d6,-4(a1)		  ; Insert new data
	bra.s	.e_sf

.norm_orw	swap	d6
	moveq	#0,d7
	move.w	d6,d7	
	lsr.w	#8,d7	
	bne.s	.no_mq2
	move.b	d6,d7	
	bmi.s	.no_mq2
	move.w	#-1,(a5)
	move.b	#$70,(a1)+	; moveq #xx,d0 
	move.b	d6,(a1)+
	tst.w	offset
	bne.s	.3
	move.w	#$8150,(a1)+	; ori.w d0,(a0)
	bra.s	.e_sf

.3	move.w	#$8168,(a1)+	; ori.w d0,y(a0)
	bra.s	.add_oset
.no_mq2
	tst.w	offset
	bne.s	.4
	move.w	#$0050,(a1)+	; ori.w #xxxx,(a0)
	move.w	d6,(a1)+		; #xxxx
	bra.s	.e_sf

.4	move.w	#$0068,(a1)+	; ori.w #xxxx,y(a0)
	move.w	d6,(a1)+		; #xxxx
	bra.s	.add_oset	
	
.orl
	tst.w	offset
	bne.s	.5
	move.w	#$0090,(a1)+
	move.l	d6,(a1)+
	bra.s	.e_sf

.5	move.w	#$00a8,(a1)+	; ori.l #xxxxxxxx,y(a0)
	move.l	d6,(a1)+		; #xxxxxxxx
.add_oset	move.w	offset,(a1)+	; y(
.e_sf	sf	poss_long_soon
.exit	rts
;
; resets all save area pointers
;
flush_buffers
	move.l	#sav_buff1,s_buff_add1
	move.w	#0,res_count1
	move.l	#sav_2p_buff1,s2p_buff_add1
	move.w	#0,res2p_count1
	move.l	#sav_buff2,s_buff_add2
	move.w	#0,res_count2
	move.l	#sav_2p_buff2,s2p_buff_add2
	move.w	#0,res2p_count2
	move.l	#mush_buffer,mb_ptr
	rts
;
; flips buffers used in saving backgrounds
;
flip_buffers
	move.l	s_buff_add1,d0	
	move.l	s2p_buff_add1,d1
	move.w	res_count1,d2	
	move.w	res2p_count1,d6	
	move.l	s_buff_add2,d3	
	move.l	s2p_buff_add2,d4
	move.w	res_count2,d5
	move.w	res2p_count2,d7	
	move.l	d0,s_buff_add2	
	move.l	d1,s2p_buff_add2	
	move.w	d2,res_count2	
	move.w	d6,res2p_count2	
	move.l	d3,s_buff_add1	
	move.l	d4,s2p_buff_add1	
	move.w	d5,res_count1	
	move.w	d7,res2p_count1	
	rts
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Save 32*8 background from A0 to A2 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
save_back8	; 4 plane
	movem.l	(a0),d0-3
	movem.l	160(a0),d4-7
	movem.l	320(a0),a3-6
	movem.l	d0-7/a3-6,(a2)
	movem.l	480(a0),d0-3
	movem.l	640(a0),d4-7
	movem.l	800(a0),a3-6
	movem.l	d0-7/a3-6,48(a2)
	movem.l	960(a0),d0-3
	movem.l	1120(a0),d4-7
	movem.l	d0-7,96(a2)
	rts
save_2p_back8	; 2 plane
	move.l	(a0),d0
	move.l	8(a0),d1
	move.l	160(a0),d2
	move.l	168(a0),d3
	move.l	320(a0),d4
	move.l	328(a0),d5
	move.l	480(a0),d6
	move.l	488(a0),d7
	move.l	640(a0),a3
	move.l	648(a0),a4
	move.l	800(a0),a5
	move.l	808(a0),a6
	movem.l	d0-7/a3-6,(a2)	
	move.l	960(a0),d0
	move.l	968(a0),d1
	move.l	1120(a0),d2
	move.l	1128(a0),d3
	movem.l	d0-3,48(a2)	
	rts
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Restore 32*8 background from A0 to A1 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
restore_4p	; 4 plane
	move.l	s_buff_add2,a0
.again	subq.w	#1,res_count2
	bmi.s	.exit
	move.l	-(a0),a1
	lea	-128(a0),a2
	move.l	a2,a0	
	movem.l	(a2)+,d0-7/a3-6
	movem.l	d0-3,(a1)
	movem.l	d4-7,160(a1)
	movem.l	a3-6,320(a1)
	movem.l	(a2)+,d0-7/a3-6
	movem.l	d0-3,480(a1)
	movem.l	d4-7,640(a1)
	movem.l	a3-6,800(a1)
	movem.l	(a2)+,d0-7
	movem.l	d0-3,960(a1)
	movem.l	d4-7,1120(a1)
	bra.s	.again	
.exit	moveq	#0,d0
	move.w	d0,res_count2
	move.l	a0,s_buff_add2	
	rts		
restore_2p	; 2 plane
	move.l	s2p_buff_add2,a0
.again	subq.w	#1,res2p_count2
	bmi.s	.exit
	move.l	-(a0),a1
	lea	-64(a0),a2
	move.l	a2,a0	
	movem.l	(a2)+,d0-7/a3-6
	move.l	d0,(a1)
	move.l	d1,8(a1)
	move.l	d2,160(a1)
	move.l	d3,168(a1)
	move.l	d4,320(a1)
	move.l	d5,328(a1)
	move.l	d6,480(a1)
	move.l	d7,488(a1)
	move.l	a3,640(a1)
	move.l	a4,648(a1)
	move.l	a5,800(a1)
	move.l	a6,808(a1)
	movem.l	(a2)+,d0-3
	move.l	d0,960(a1)
	move.l	d1,968(a1)
	move.l	d2,1120(a1)
	move.l	d3,1128(a1)
	bra.s	.again	
.exit	moveq	#0,d0
	move.w	d0,res2p_count2
	move.l	a0,s2p_buff_add2	
	rts		
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Zoom from workscreen onto screen ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
zoom_in	movem.l	d0-a6,-(a7)
	bsr	clr2
	lea	work_screen,a1
	bsr	_64_pix
	bsr	clr2
	lea	work_screen,a1
	bsr	_32_pix
	bsr	clr2
	lea	work_screen,a1
	bsr	_16_pix
	bsr	clr2
	lea	work_screen,a1
	bsr	_8_pix
	bsr	clr2
	lea	work_screen,a1
	bsr	_4_pix
	bsr	clr2
	lea	work_screen,a1
	bsr	_2_pix
	bsr	clr2
	lea	work_screen,a1
	bsr	_1_pix
	bsr.s	sync
	lea	work_screen,a1
	bsr	_1_pix
	bsr.s	sync
	movem.l	(a7)+,d0-a6
	rts
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Zoom from screen onto screen ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
zoom_out	movem.l	d0-a6,-(a7)
	move.l	screen1(pc),a1
	bsr	_1_pix
	bsr.s	clr2
	move.l	screen1(pc),a1
	bsr	_2_pix
	bsr.s	clr2
	move.l	screen1(pc),a1
	bsr	_4_pix
	bsr.s	clr2
	move.l	screen1(pc),a1
	bsr	_8_pix
	bsr.s	clr2
	move.l	screen1(pc),a1
	bsr	_16_pix
	bsr.s	clr2
	move.l	screen1(pc),a1
	bsr	_32_pix
	bsr.s	clr2
	move.l	screen1(pc),a1
	bsr	_64_pix
	bsr.s	clr2
	movem.l	(a7)+,d0-a6
	rts

sync	bsr	flip_screens
	rept	4
	bsr	vsync
	endr
	rts

clr2	bsr	flip_screens
	rept	4
	bsr	vsync
	endr
	move.l	screen2(pc),a0
	move.l	#4000,d0
	moveq	#0,d1
.1	move.l	d1,(a0)+
	move.l	d1,(a0)+
	dbf	d0,.1
	rts

_1_pix	move.l	screen2(pc),a0
	move.l	#8000-1,d0
l	move.l	(a1)+,(a0)+
	dbf	d0,l
	rts

_2_pix	move.l	screen2(pc),a0
	move	#((200)/2)-1,d4
	move.l	#$aaaaaaaa,d3
all	moveq	#39,d2

.1_line	move.l	(a1)+,d0
	beq.s	.1
	and.l	d3,d0
	move.l	d0,d1
	lsr.l	#1,d0
	or.l	d0,d1
	move.l	d1,(a0)
	move.l	d1,160(a0)
.1	addq	#4,a0
	dbf	d2,.1_line
	lea	160(a0),a0
	lea	160(a1),a1
	dbf	d4,all
	rts

_4_pix	move.l	screen2(pc),a0
	move	#((200)/4)-1,d4
	move.l	#$88888888,d2
all4	moveq	#39,d3
.1_line	move.l	(a1)+,d0
	beq.s	.1
	and.l	d2,d0
	move.l	d0,d1
	lsr.l	#1,d0
	or.l	d0,d1
	lsr.l	#1,d0
	or.l	d0,d1
	lsr.l	#1,d0
	or.l	d0,d1

	move.l	d1,(a0)
	move.l	d1,160(a0)
	move.l	d1,320(a0)
	move.l	d1,480(a0)
.1	addq	#4,a0
	dbf	d3,.1_line
	lea	480(a0),a0
	lea	480(a1),a1
	dbf	d4,all4
	rts

_8_pix	move.l	screen2(pc),a0

	moveq	#-1,d7
	move	#((200)/8)-1,d4
all8	moveq	#79,d2
.1_line	move.w	(a1)+,d5
	beq.s	.3
	btst	#15,d5
	beq.s	.1
x	set	0	
	rept	8
	move.b	d7,x(a0)
x	set	x+160
	endr
.1	btst	#7,d5
	beq.s	.3
x	set	0	
	rept	8
	move.b	d7,x+1(a0)
x	set	x+160
	endr
.3	addq	#2,a0
	dbf	d2,.1_line
	lea	7*160(a0),a0
	lea	7*160(a1),a1
	dbf	d4,all8
	rts

_16_pix	move.l	screen2(pc),a0

	moveq	#-1,d7
	move	#((200)/16)-1,d4
all16	moveq	#79,d2
.1_line	move.w	(a1)+,d5
	beq.s	.1
	btst	#15,d5
	beq.s	.1

x	set	0	
	rept	16
	move.w	d7,x(a0)
x	set	x+160
	endr
.1	addq	#2,a0
	dbf	d2,.1_line
	lea	15*160(a0),a0
	lea	15*160(a1),a1
	dbf	d4,all16
	rts

_32_pix	move.l	screen2(pc),a0

	moveq	#-1,d7
	move	#((200)/32)-1,d4
all32	moveq	#9,d2
.1_line	
	moveq	#3,d3	
.2	move.w	(a1)+,d5
	beq	.1
	btst	#15,d5
	beq	.1
x	set	0	
	rept	32
	move.w	d7,x(a0)
	move.w	d7,x+8(a0)
x	set	x+160
	endr
.1	addq	#2,a0
	dbf	d3,.2
	addq	#8,a1
	addq	#8,a0
	dbf	d2,.1_line
	lea	31*160(a0),a0
	lea	31*160(a1),a1
	dbf	d4,all32
	rts

_64_pix	move.l	screen2(pc),a0
	moveq	#-1,d7
	move	#((200)/64)-1,d4
all64	moveq	#4,d2
.1_line	
	moveq	#3,d3	
.2	move.w	(a1)+,d5
	beq	.1
	btst	#15,d5
	beq	.1
x	set	0	
	rept	64
	move.w	d7,x(a0)
	move.w	d7,x+8(a0)
	move.w	d7,x+16(a0)
	move.w	d7,x+24(a0)
x	set	x+160
	endr
.1	addq	#2,a0
	dbf	d3,.2
	lea	24(a1),a1
	lea	24(a0),a0
	dbf	d2,.1_line
	lea	63*160(a0),a0
	lea	63*160(a1),a1
	dbf	d4,all64
	rts
;
;;;;;;;;;;;;;;;;;;;;;;
; Small memory clear ;
;;;;;;;;;;;;;;;;;;;;;;
;
clr	lea	blank,a2
	moveq	#15,d0
	moveq	#0,d1
.clr	move.l	d1,(a2)+
	dbf	d0,.clr
	lea	blank,a2
	movem.l	(a2),d0-7/a2-5
.loop	movem.l	d0-7/a2-5,(a0)
	lea	48(a0),a0
	cmp.l	a0,a1
	bgt.s	.loop
	rts
;
; (de)encrypt hi scores
;
crypt_scores
	lea	hst(pc),a0
	lea	mince(pc),a1
	moveq	#0,d0
	moveq	#0,d1
.loop	move.b	(a0),d1
	eor.b	d0,d1
	move.b	d1,(a0)+
	addq	#1,d0
	cmp.l	a0,a1
	bne.s	.loop
	rts
;
; plot 8*8 text, used for zooming messages
;
print_line
	movem.l	d0-2/a0-3,-(a7)
pagn	moveq	#0,d2
	move.l	d2,d0
	move.l	d2,d1
	move.b	(a4)+,d2
	cmp.b	#-1,d2
	beq.s	.goodbye
	bmi	codes

	move.w	curr_x,d0	; move current coords
	move.w	curr_y,d1	; into reggies
	addq.w	#1,d0		; update

	cmp.w	#40,d0		; end of line ?
	blt.s	.6		; no
	moveq	#0,d0		; set to begining
	cmp.w	#23,d1		; end of page
	bgt.s	.6		; no
	addq	#1,d1		; advance one line

.6	move.w	d0,curr_x	; store coords
	move.w	d1,curr_y	;
	
	lea	work_screen,a1
	bsr.s	do_char
	bra.s	pagn			

.goodbye	movem.l	(a7)+,d0-2/a0-3
	rts
; plot 8*8
do_char	lsl.w	#4,d1
	lea	mul160(pc),a2
	add.w	(a2,d1.w),a1	; y offset
	moveq	#0,d1
	move.w	d0,d1
	divu	#2,d1
	swap	d1
	add.w	d1,a1
	sub.w	d1,d0
	lsl.w	#2,d0
	add.w	d0,a1

	lea	font8,a0	; get correct char
	add.w	d2,d2
	add.w	d2,d2
	add.w	d2,d2
	lea	(a0,d2),a0	;

x	set	0		; plot char
y	set	0		; god i'm being lazy
	rept	8		;
	move.b	y(a0),x(a1)	;
x	set	x+160		;
y	set	y+1		;
	endr			;
.exit	rts
; my codes section
codes	
.4	cmp.b	#$fb,d2		; clear screen and home 
	bne	pagn		; cursor
	move.w	#-1,curr_x	;
	move.w	#0,curr_y	;
	bsr.s	clear_screen	;
	bra	pagn
clear_screen
	lea	work_screen,a0
	move.l	#($8000/4)-1,d0
	moveq	#0,d1
.1	move.l	d1,(a0)+
	dbf	d0,.1
	rts
;
;
; INTRO CODE STARTS HERE
;
;
intro
.1	tst.b	vbldone
	beq.s	.1
	sf	vbldone
	moveq	#0,d0
	tst.w	demo_mode
	bne.s	.exit
	move.b	chip_val,d0	
	tst.w	f_p_on_intro
	beq.s	.go_on
.11	sf	f_p_on_intro
	move.b	last_start,d0
	bne.s	.go_on
	move.b	#$3b,d0
.go_on	cmp.b	#$3b,d0
	blt.s	.1	
	cmp.b	#$3f,d0
	bgt.s	.2
	move.b	d0,last_start
	bra.s	.exit
.2	cmp.b	#$43,d0
	bne.s	.3
	bra.s	.exit	
.3	cmp.b	#$44,d0
	bne.s	.1
.exit	clr.b	chip_val
	rts

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; the main intro stuff is in here, err its a bit messy! ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
intro_vbl	MOVEM.L	D0-D7/A0-A6,-(a7)
	movem.l	pal,d0-3
	movem.l	d0-3,$ffff8250.w

	move.l	pos(pc),a0	; raster pos on logo

	move.l	a0,pos
	move.l	a0,pos2
	add.l	#14,pos
	add.l	#14,pos2
x	set	$ffff8242		; move into pallete
	rept	3
	move.l	(a0)+,x.w
x	set	x+4
	endr	
	move.w	(a0)+,x.w
	cmp.l	#endx,a0
	bne.s	.1
	lea	rasters(pc),a0
	move.l	a0,pos
.1	MOVEM.L	(a7)+,D0-D7/A0-A6
	movem.l	d0-a6,-(a7)
	jsr	mus+8	; play awesome music
	movem.l	(a7)+,d0-a6
	move.b	#22,counter	; ?
	clr.b	$fffffa1b.w
	move.l	#int_hbl1,$120.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	movem.l	d0-a6,-(a7)
	bsr	flip_buffers	; restore screen
	bsr	restore_4p
; plot 8*8 stuff
plot_let	tst.w	clr_now	; clear in progress?		
	bne.s	.wow	; yes
	tst.w	stay_cnt	; wait for a while
	bmi	.yawn
	subq	#1,stay_cnt
	tst.w	stay_cnt
	bpl	do_spr	; exit into sprite routes
	st	clr_now	; end of wait , now set clear to go
	move.w	#(25*160)+4,c_offs1	; clear a scanline
	move.w	#(25*160)+4,c_offs2
.wow	move.l	screen2(pc),a1
	add.w	c_offs2,a1
	add.w	#160,c_offs2
	cmp.w	#(199*160)+4,c_offs1
	beq.s	.no_more
	moveq	#0,d0
x	set	0
	rept	20
	move.w	d0,x(a1)
x	set	x+8
	endr
	bra	do_spr	; exit into sprite routes 
.no_more	sf	clr_now	; no more clears needed
	tst.w	dm	; demo mode set
	beq	do_spr	; no
	st	demo_mode	; yes
	bra	do_spr

.yawn	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
; plot char plotted last frame angain this frame 
; (for double buffering purposes)
	move.w	yc,d1	; current y
	beq.s	.1	; blank
	move.w	xc,d0	; current x
	move.b	pc,d2	; char 2 b printed
	move.l	screen2(pc),a1
	addq	#4,a1	; correct plane
	bsr	do_char	; do it
	moveq	#0,d0	; zeor coords
	move.b	d0,pc
	move.w	d0,xc
	move.w	d0,yc
.1	move.l	txt_ptr,a0	; current position in text
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.b	(a0)+,d2		; get char
	cmp.l	#e_int_txt,a0	; at end ?
	bne.s	.2		; no
	st	dm		; demo mode is go!
	lea	int_text,a0
.2	cmp.l	#mince,a0		; hi internal message?
	bne.s	.3		
	lea	cred,a0		; skip it
.3	move.l	a0,txt_ptr	; store pointer
	cmp.b	#$ff,d2		; end of page
	bne.s	.4
	move.w	#250,stay_cnt	; init pause
	bra	do_spr		; plot sprites
.4	cmp.b	#$fb,d2		; clear screen
	bne.s	.5
	move.w	#0,curr_x		; re-init coords
	move.w	#4,curr_y
	bra.s	do_spr		; plot sprites

.5	move.w	curr_x,d0	; move current coords
	move.w	curr_y,d1	; into reggies
	move.l	screen2(pc),a1
	addq	#4,a1
	move.b	d2,pc	; store current coords & char for next time round 
	move.w	d0,xc
	move.w	d1,yc
	move.b	(a0),d7	; ? might be getting a code
	bsr	do_char
	addq.w	#1,curr_x		; update
	cmp.w	#40,curr_x	; end of line ?
	blt.s	.6		; no
	move.w	#0,curr_x		; set to begining
	cmp.w	#23,curr_y	; end of page
	bgt.s	.6		; no
	addq.w	#1,curr_y		; advance one line
.6	cmp.b	#-1,d7
	beq.s	do_spr		; plot sprites
	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.l	screen2(pc),a1
	addq	#4,a1
	move.w	curr_x,d0		; reload coords, why?	
	move.w	curr_y,d1	
	move.b	#'<'-$20,d2	
	bsr	do_char		; plot cursor
do_spr	lea	stable,a3		; load table of pointers
	moveq	#8,d5
.3	move.l	(a3),a6		; pointer into coords
	move.w	(a6)+,d0
	bpl.s	.4		; at end?
	lea	coords,a6		; reset
	move.w	(a6)+,d0		; move in
.4	move.w	(a6)+,d1
	move.l	a6,(a3)+		; store pointer
	move.l	(a3)+,a6		; get sprite address
	movem.l	d0-a6,-(a7)
	bsr	plotit
	movem.l	(a7)+,d0-a6
	dbf	d5,.3		; loop
	move.w	c_offs2,d0	; who knows
	move.w	c_offs1,c_offs2
	move.w	d0,c_offs1	
	bsr	flip_screens
	movem.l	(a7)+,d0-a6
	st	vbldone
	rte

int_hbl1	clr.b	$fffffa1b.w 
	move.l	a0,-(a7)
	move.l	pos2(pc),a0
x	set	$ffff8242
	rept	3
	move.l	(a0)+,x.w
x	set	x+4
	endr	
	move.w	(a0)+,x.w
	cmp.l	#endx,a0
	bne.s	.1
	lea	rasters(pc),a0
.1	move.l	a0,pos2
	subq.b	#1,counter
	bpl.s	.2
	movea.l	(a7)+,a0
	move.b	#8,$fffffa1b.w
	move.b	#1,$fffffa21.w
	move.l	#int_hbl2,$120.w
	bclr	#0,$fffffa0f.w
	rte
.2	movea.l	(a7)+,a0
	move.b	#8,$fffffa1b.w
	move.b	#1,$fffffa21.w
	bclr	#0,$fffffa0f.w
	rte 

int_hbl2	move.b	#0,$FFFFFA1B.W
	movem.l	a0-a2/D0-d1,-(a7)
	movea.l	col_ptr1,a0
	lea	$FFFF8240.W,a1
	lea	$FFFFFA21.W,a2
	bclr	#0,-$12(a2)
	move.l	#int_hbl3,$120.W
	move.b	#174,(a2)
	move.b	#8,-6(a2)
	move.b	(a2),d0
.1	cmp.b	(a2),d0
	beq.s	.1
	lea	$FFFF8209.W,a2
	moveq	#$10,d0
.2	move.b	(a2),d1
	subi.b	#-$80,d1
	beq.s	.2
	sub.b	d1,d0
	lsl.w	d0,d1
	moveq	#$21,d0
.3	dbf	d0,.3
	rept	42	
	move.w	(a0)+,(a1)
	endr
	move.w	#0,(a1)
	addq.l	#2,col_ptr1
	cmpi.l	#col_tab3,col_ptr1
	bne.s	.4
	move.l	#col_tab,col_ptr1
.4	move.w	(a0),8(a1)
	move.w	#$357,2(a1)	
	move.w	#$135,4(a1)	
	move.w	#$667,6(a1)	
	movem.l	(a7)+,a0-a2/D0-d1
	rte
int_hbl3	move.b	#0,$FFFFFA1B.W
	movem.l	a0-a2/D0-d1,-(a7)
	movea.l	col_ptr2,a0
	lea	$FFFF8240.W,a1
	lea	$FFFFFA21.W,a2
	bclr	#0,-$12(a2)
	move.b	#2,(a2)
	move.l	#hbl,$120.W
	move.b	#8,-6(a2)
	move.b	(a2),d0
.1	cmp.b	(a2),d0
	beq.s	.1
	lea	$FFFF8209.W,a2
	moveq	#$10,d0
.2	move.b	(a2),d1
	subi.b	#-$80,d1
	beq.s	.2
	sub.b	d1,d0
	lsl.w	d0,d1
	moveq	#$21,d0
.3	dbf	d0,.3
	rept	42	
	move.w	(a0)+,(a1)
	endr
ccol	move.w	#0,(a1)
	movem.l	(a7)+,a0-a2/D0-d1
	addq.l	#2,col_ptr2
	cmpi.l	#col_tab3,col_ptr2
	bne.s	.4
	move.l	#col_tab,col_ptr2
.4	rte
;
; plot an intro sprite
;
plotit	move.l	screen2(pc),a0
	add.w	d1,d1		;
	lea	mul160(pc),a1	; Add y offset
	add.w	(a1,d1.w),a0	;
; calc rotation and x offset
	moveq	#15,d2
	move.w	d0,d1
	and.w	d2,d0		; roation no in d0
	eor.w	d0,d1
	lsr.w	#1,d1		; x offset in d1
	add.w	d1,a0
	move.w	d0,a1		; keep it safe
	movem.l	a0-6,-(a7)
	move.l	s_buff_add2,a2	; save background to here
	bsr	save_back8
	lea	128(a2),a2	; get to end of save zone
	move.l	a0,(a2)+		; write out source address
	lea	(160*8)(a0),a0	; next zone to save
	bsr	save_back8
	lea	128(a2),a2	; to end
	move.l	a0,(a2)+		; store source address
	move.l	a2,s_buff_add2
	addq.w	#2,res_count2	; no of blocks saved
	movem.l	(a7)+,a0-6
	move.w	a1,d0	; Rotation no
	add.w	d0,d0
	move.l	(a6,d0.w),a6	; sprite code
	jmp	(a6)		; run it
;
;
; HISCORE CODE STARTS HERE
;
;
hi_scores
.again	bsr	flip_buffers	; swap save buffers
	bsr	restore_4p	; restore screen 
	tst.b	plot_char		; char to plot
	beq.s	.ntp		; no
	sf	plot_char		
	moveq	#0,d2
	move.b	char,d2		; char to plot
	moveq	#0,d0
	moveq	#0,d1
	move.w	namex,d0		; to these coords	
	move.w	namey,d1	
	move.l	screen2(pc),a1	; to his screen
	bsr	do_char		; do it
	addq	#1,namex		; next coord
.ntp	tst.b	del_char		; any deletes?
	beq.s	.2		; no
	sf	del_char		; as above
	moveq	#0,d2
	move.b	char,d2
	moveq	#0,d0
	moveq	#0,d1
	move.w	namex,d0	
	move.w	namey,d1	
	move.l	screen2(pc),a1
	bsr	do_char
.2	cmp.b	#1,chip_val	; clicked on char?
	beq.s	.21		; no
	cmp.b	#2,chip_val
	bne	.no_click
.21	moveq	#0,d0
	moveq	#0,d1
	moveq	#0,d2
	move.w	hx_coord,d0
	move.w	hy_coord,d1
	addq	#8,d0
	lsr.w	#3,d0
	lsr.w	#3,d1

; coords in range?
	btst	#0,d0
	beq	.no_click
	btst	#0,d1
	beq	.no_click
	cmp.w	#7,d0
	blt	.no_click	
	cmp.w	#31,d0
	bgt	.no_click	
	cmp.w	#7,d1
	blt	.no_click	
	cmp.w	#17,d1
	bgt	.no_click	
; what did we click on?
	lea	hs_txt+1,a0	; start of chars
	add.w	d0,a0		; calc offset
	mulu	#40,d1		; 
	add.w	d1,a0		; 
	move.b	(a0),d2		; this is it
	cmp.b	#'%'-$20,d2	; exit
	beq	.exit
	cmp.b	#'$'-$20,d2	; delete
	bne.s	.not_del
	cmp.w	#6,namex		; at start anyway?
	beq.s	.no_click
	subq	#1,namex		
	move.b	#'='-$20,d2	; put '=' in place
	st	del_char
	bra.s	.doit		; plot it
.not_del	cmp.w	#34,namex		; at end of line?
	beq.s	.no_click

.doit	cmp.b	#'+'-$20,d2	; space?
	bne.s	.no_space
	moveq	#0,d2		; force it in
.no_space	move.b	d2,char		; char to plot next frame
	moveq	#0,d0
	moveq	#0,d1
	move.w	namex,d0		; current coords	
	move.w	namey,d1		;	
	move.l	screen2(pc),a1	; to here
	lea	hs_txt+1,a0	; store in hs text
	add.w	d0,a0
	mulu	#40,d1
	add.w	d1,a0
	move.b	d2,(a0)
	moveq	#0,d0
	moveq	#0,d1
	move.w	namex,d0	
	move.w	namey,d1	

	bsr	do_char		; plot it	
	tst.b	del_char
	bmi.s	.g
	st	plot_char		; char to plot
	bra.s	.g
.no_click	sf	plot_char	
.g	clr.b	chip_val		
; shuffle up coords for mouse pointers and plot them
; work this one out yourselves
	lea	ec_tab,a6
.3	move.l	-4(a6),(a6)
	subq	#4,a6
	cmp.l	#c_tab,a6
	bne.s	.3
	move.l	hx_coord,(a6)
	lea	ec_tab,a6
.4	move.l	-(a6),d1
	bmi.s	.5	
	move.w	4(a6),d0
	move.l	a6,-(a7)
	bsr	pshs	
	move.l	(a7)+,a6
	cmp.l	#hx_coord,a6
	beq.s	.5
	lea	-28(a6),a6
	bra.s	.4

.5	bsr	flip_screens	
	bsr	vsync
	bra	.again	; looooop
;
; exit all the hiscore stuff 
;
.exit	lea	scnam,a0		; name entered
	move.l	score_pos,a1	; position in table
	lea	10(a1),a1		;
	move.l	a1,a2
	moveq	#27,d0
.6	move.b	(a0),d1		; letter entered
	move.b	#'='-$20,(a0)+	; store a '=' in name entered	
	cmp.b	#'='-$20,d1	; is letter an '='
	bne.s	.7		
	move.b	#' '-$20,d1	; load a space
.7	move.b	d1,(a1)+		; store into table 
	dbf	d0,.6
; is it a special name, if so then modify it
fix	moveq	#18,d0	
	lea	null_name,a1
.loop	move.l	(a2),d6
	move.l	(a1),d7
	cmp.l	d6,d7
	bne.s	.1
	move.l	4(a2),d6
	move.l	4(a1),d7
	cmp.l	d6,d7
	bne.s	.1
	move.l	8(a2),d6
	move.l	8(a1),d7
	cmp.l	d6,d7
	bne.s	.1
	move.l	12(a2),d6
	move.l	12(a1),d7
	cmp.l	d6,d7
	bne.s	.1
	move.l	16(a2),d6
	move.l	16(a1),d7
	cmp.l	d6,d7
	bne.s	.1
	move.l	20(a2),d6
	move.l	20(a1),d7
	cmp.l	d6,d7
	bne.s	.1
	move.l	24(a2),d6
	move.l	24(a1),d7
	cmp.l	d6,d7
	bne.s	.1
	lea	28(a1),a1
	moveq	#(28/4)-1,d0
.fix	move.l	(a1)+,(a2)+
	dbf	d0,.fix
	bra.s	.x
.1	lea	56(a1),a1
	dbf	d0,.loop		
.x	bsr	flush_buffers
	bsr	zoom_out
	rts
;
; pack a score into nibbles
;
c_score	moveq	#0,d0
	move.l	d0,d4
	move.l	d0,d5
	move.l	d0,d6
	move.l	d0,d7
	move.b	#4,d5
	move.b	-(a0),d7
	cmp.b	#$10,d7
	blt.s	.1
	sub.b	#$10,d7
.1	moveq	#6,d4
.loop	move.l	d0,d6
	move.b	-(a0),d6
	cmp.b	#$10,d6
	blt.s	.2
	sub.b	#$10,d6

.2	lsl.l	d5,d6
	or.l	d6,d7
	addq	#4,d5	
	dbf	d4,.loop
	rts
; hi score keyboard interrupt 
hi_key2	move.w	#$2500,sr	
	move.w	d0,-(a7)
	move.b	$fffffc02.w,d0
.3	cmp.b	#$f8,d0	; any packet headers
	blt.s	.1	; nope	
	cmp.b	#$fb,d0	; mouse?
	bgt.s	.1	; no	
	and.b	#3,d0
	move.l	#hi_key3,$118.w	; install mouse hbl	
.1	bclr	#6,$fffffa11.w
	move.b	d0,chip_val
	move.w	(a7)+,d0
	rte	

; wait for x offset packet to arrive

hi_key3	move.w	#$2500,sr	
	move.l	d0,-(a7)
	move.l	d1,-(a7)
	moveq	#0,d0
	move.b	$fffffc02.w,d0	; load offset packet
	ext.w	d0
	move.w	hx_coord,d1	; load xcoord
	add.w	d0,d1		; create new coord
	bpl.s	.1		; not -ve
	moveq	#0,d1		; reset to zero
.1	cmp.w	#319-16,d1		; not past rh edge
	ble.s	.2
	move.w	#319-16,d1		; reset to rh edge
.2	move.w	d1,hx_coord	; store new coord
	move.l	(a7)+,d1
	move.l	(a7)+,d0
	move.l	#hi_key4,$118.w	; install new mouse hbl
	bclr	#6,$fffffa11.w
	rte	

; wait for y offset packet to arrive

hi_key4	move.w	#$2500,sr	
	move.l	d0,-(a7)
	move.l	d1,-(a7)
	moveq	#0,d0	
	move.b	$fffffc02.w,d0	; load offset
	ext.w	d0
	move.w	hy_coord,d1	; load y coord
	add.w	d0,d1		; create new coord
	cmp.w	#0,d1		; not less than min val
	bge.s	.1	
	move.w	#0,d1		; set to min val
.1	cmp.w	#199-16,d1	; not greater than max val
	ble.s	.2
	move.w	#199-16,d1	; set to max val
.2	move.w	d1,hy_coord	; store new coord
	move.l	(a7)+,d1
	move.l	(a7)+,d0
	move.l	#hi_key2,$118.w	
	bclr	#6,$fffffa11.w
	rte	
;
; hiscore vbl
;
hi_vbl	move.l	a0,-(a7)
	move.l	cp,c_ptr	
	move.l	cp,a0
	clr.w	$ffff8240.w
	move.w	(a0),$ffff8242.w
	addq.l	#2,cp	
	cmp.l	#col_tab3,cp
	bne.s	.1
	move.l	#col_tab,cp
.1	clr.b	$fffffa1b.w
	move.l	(a7)+,a0
	movem.l	d0-a6,-(a7)
	jsr	mus2+4
	movem.l	(a7)+,d0-a6
.2	move.l	#hi_hbl,$120.w
	move.b	#1,$fffffa21.w
	move.b	#8,$fffffa1b.w
	st	vbldone
	rte
;
; hi score rasters
;
hi_hbl	clr.b	$fffffa1b.w 
	move.l	a0,-(a7)
	move.l	c_ptr(pc),a0
	move.w	(a0)+,$ffff8242.w
	cmp.l	#col_tab3,a0
	bne.s	.1
	lea	col_tab(pc),a0
.1	move.l	a0,c_ptr
	movea.l	(a7)+,a0
	move.b	#8,$fffffa1b.w
	move.b	#1,$fffffa21.w
	bclr	#0,$fffffa0f.w
	rte 
;
;
; GAME CODE STARTS HERE
;
;
game
game_loop	
ptim1	eor.w	#$000,$ffff8240.w
	bsr	flip_buffers	; swap over save biffers
	bsr	restore_4p	; restore 4plane sprites
	bsr	restore_2p	; restore 2plane sprites
	bsr	add_mushies	; add mushies from last frame 
return	tst.w	wave		; if wave then no centis required
	bmi.s	.1
	bsr	add_centi
.1	bsr	update_everything	; update all objects
	tst.w	demo_mode		; if demo mode then no col detect
	bne.s	.2
	bsr	do_all_collision_detection
.2	bsr	plot_everything	; plot all sprites
ptim2	eor.w	#$000,$ffff8240.w
	bsr	flip_screens	; show new screen
	bsr	vsync		; wait 
	tst.w	wave		; if wave then check for end
	beq	.cont
	addq	#1,timer
	cmp.w	#WAVE_TIME,timer
	blt	.cont	
   	moveq	#0,d1	
	bsr	kill_beasties	; kill everything
	move.l	curr_wave,a5	; we are on this
	lea	16(a5),a5		; get next
	cmp.l	#end_waves,a5	; end 
	bne.s	.not_end
	lea	loop_waves,a5	; reset
.not_end	move.l	a5,curr_wave	; whack in new values
	move.w	(a5),ce_cnt
	move.w	#8,ce_cntr
	move.w	(a5),c2kill
	move.w	(a5)+,c4level
	move.w	(a5)+,spider_tot
	move.w	(a5)+,scorp_tot
	move.w	(a5)+,snail_tot
	move.w	(a5)+,fly_tot
	move.w	(a5)+,bee_tot
	move.w	(a5)+,wave
	move.w	(a5)+,diff
	move.w	#0,timer	

	move.w	scorps_on_screen,d0	; adjust values for anything on screen
	sub.w	d0,scorp_tot
	move.w	spiders_on_screen,d0
	sub.w	d0,spider_tot
	move.w	bees_on_screen,d0
	sub.w	d0,bee_tot
	move.w	flys_on_screen,d0
	sub.w	d0,fly_tot
	move.w	snails_on_screen,d0
	sub.w	d0,snail_tot

.cont	tst.w	demo_mode		; if demo mode then check for end 
	beq.s	.not_dem
	subq	#1,demo_count
	beq	live_gone
.not_dem	tst.w	cheat
	bne.s	.mike
	tst.w	live_lost		; if live lost then process it 
	bne	live_gone
.mike	tst.w	pausef		; if pause then pause
	bne.s	pause_mode
	tst.w	abortf	
	beq	game_loop
; process an abort
abort	lea	aborted(pc),a4
	bsr	plot_game_text
	bra.s	wloop		; wait a while
; process your death
dead	lea	game_over(pc),a4
	bsr	plot_game_text
; wait and then finish game
wloop	moveq	#50,d0
show	bsr	vsync
	dbf	d0,show
	bsr	zoom_out
	rts
; pause mode code 
pause_mode
	clr.w	pausef	; reset flag
	bsr	ksync		; set up new key route
	move.l	#game_key1,$118.w	;
; gfx to screen
	lea	paws,a0
	move.l	screen1(pc),a1
	lea	112(a1),a1
	moveq	#7,d0
.loop	move.w	(a0)+,(a1)
	move.w	(a0)+,8(a1)
	move.w	(a0)+,16(a1)
	lea	160(a1),a1
	dbf	d0,.loop	
	bsr	vsync
; wait for HELP again
	clr.b	chip_val
.wait_l	move.b	chip_val,d0
	cmp.b	#$62,d0
	bne.s	.wait_l
; clear gfx from screen
	clr.b	chip_val
	moveq	#7,d0
	move.l	screen1(pc),a1
	lea	112(a1),a1
	moveq	#0,d1
.loop2	move.w	d1,(a1)
	move.w	d1,8(a1)
	move.w	d1,16(a1)
	lea	160(a1),a1
	dbf	d0,.loop2	
	bsr	vsync
	bsr	ksync		; install original key route 
	move.l	#game_key2,$118.w	;
	bra	game_loop
;
; game key route 1
;
game_key1	move.w	#$2500,sr
	move.w	d0,-(a7)
	move.b	$fffffc02.w,d0
	move.b	d0,chip_val	
.1	bclr	#6,$fffffa11.w
	move.w	(a7)+,d0
	rte
;
; game key route 2
;
game_key2	move.w	#$2500,sr	
	move.w	d0,-(a7)
	tst.w	demo_mode
	bne.s	.1
	move.b	$fffffc02.w,d0
	cmp.b	#$62,d0
	bne.s	.2
	move.w	#-1,pausef	
.2	cmp.b	#$61,d0
	bne.s	.3
	move.w	#-1,abortf

.3	cmp.b	#$f8,d0	; any packet headers
	blt.s	.1	; nope	
	cmp.b	#$fb,d0	; mouse?
	bgt.s	.1	; no	
	and.b	#3,d0
	move.l	#game_key3,$118.w	; install mouse hbl	
.1	bclr	#6,$fffffa11.w
	move.b	d0,chip_val
	move.w	(a7)+,d0
	rte	

; wait for x offset packet to arrive

game_key3	move.w	#$2500,sr	
	move.l	d0,-(a7)
	move.l	d1,-(a7)
	moveq	#0,d0
	move.b	$fffffc02.w,d0	; load offset packet
	ext.w	d0
	move.w	x_coord,d1	; load xcoord
	add.w	d0,d1		; create new coord
	bpl.s	.1		; not -ve
	moveq	#0,d1		; reset to zero
.1	cmp.w	#MAX_X,d1		; not past rh edge
	ble.s	.2
	move.w	#MAX_X,d1		; reset to rh edge
.2	move.w	d1,x_coord	; store new coord
	move.l	(a7)+,d1
	move.l	(a7)+,d0
	move.l	#game_key4,$118.w	; install new mouse hbl
	bclr	#6,$fffffa11.w
	rte	

; wait for y offset packet to arrive

game_key4	move.w	#$2500,sr	
	move.l	d0,-(a7)
	move.l	d1,-(a7)
	moveq	#0,d0	
	move.b	$fffffc02.w,d0	; load offset
	ext.w	d0
	move.w	y_coord,d1	; load y coord
	add.w	d0,d1		; create new coord
	cmp.w	#MIN_Y,d1		; not less than min val
	bge.s	.1	
	move.w	#MIN_Y,d1		; set to min val
.1	cmp.w	#MAX_Y,d1		; not greater than max val
	ble.s	.2
	move.w	#MAX_Y,d1		; set to max val
.2	move.w	d1,y_coord	; store new coord
	move.l	(a7)+,d1
	move.l	(a7)+,d0
	move.l	#game_key2,$118.w	
	bclr	#6,$fffffa11.w
	rte	
;
; game rasters
;

game_hbl1	clr.b	$fffffa1b.w 
	move.w	#$557,$fffff8248.w
	move.l	#game_hbl2,$120.w
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte 
game_hbl2	clr.b	$fffffa1b.w 
	move.w	#$337,$fffff8248.w
	move.l	#game_hbl3,$120.w
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte 
game_hbl3	clr.b	$fffffa1b.w 
	move.w	#$227,$fffff8248.w
	move.l	#game_hbl4,$120.w
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte 
game_hbl4	clr.b	$fffffa1b.w 
	move.w	#$222,$fffff8248.w
	move.l	#game_hbl5,$120.w
	move.b	#144,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte 

game_hbl5	clr.b	$fffffa1b.w 
btm	move.w	#$020,$fffff8240.w
	move.l	#hbl,$120.w
	move.b	#47,$fffffa21.w
	move.b	#8,$fffffa1b.w
	bclr	#0,$fffffa0f.w
	rte 

; Main game VBL

game_vbl	addq.w	#1,r_val		; random number stuff
; set up colours
top	move.w	#$010,$fffff8240.w
	move.w	#$777,$fffff8248.w
	clr.b	$fffffa1b.w
	move.l	#game_hbl1,$120.w
	move.b	#2,$fffffa21.w
	move.b	#8,$fffffa1b.w
	movem.l	d0-a6,-(a7)
	tst.w	demo_mode		; if not demo then no sounds
	beq.s	.no_muz
	jsr	mus+8
.no_muz	lea	x_tab_pos(pc),a6
	move.l	x_tab_pos(pc),a0	; next x table pos
	addq	#2,a0
	cmp.l	#e_xtab,a0
	bne.s	.1
	move.l	#x_tab,a0
.1	move.l	a0,x_tab_pos-x_tab_pos(a6)
	move.l	y_tab_pos(pc),a0	; next y tab pos
	addq	#2,a0
	cmp.l	#e_ytab,a0
	bne.s	.2
	move.l	#y_tab,a0
.2	move.l	a0,y_tab_pos-x_tab_pos(a6)
	move.l	spt_pos(pc),a0	; next spider table pos
	addq	#4,a0
	cmp.l	#e_sp_tab,a0
	bne.s	.3
	move.l	#sp_tab,a0
.3	move.l	a0,spt_pos-x_tab_pos(a6)

	move.l	r_tab_pos(pc),a0	; next centi right anim 
	addq	#4,a0
	cmp.l	#end_anim_r,a0
	bne.s	.5
	move.l	#centi_anim_r,a0
.5	move.l	a0,r_tab_pos-x_tab_pos(a6)

	move.l	l_tab_pos(pc),a0	; next centi left anim
	addq	#4,a0
	cmp.l	#end_anim_l,a0
	bne.s	.6
	move.l	#centi_anim_l,a0
.6	move.l	a0,l_tab_pos-x_tab_pos(a6)

	move.l	hr_tab_pos(pc),a0	; next head right anim
	addq	#4,a0
	cmp.l	#end_anim_hr,a0
	bne.s	.7
	move.l	#head_anim_r,a0
.7	move.l	a0,hr_tab_pos-x_tab_pos(a6)

	move.l	hl_tab_pos(pc),a0	; next head left anim
	addq	#4,a0
	cmp.l	#end_anim_hl,a0
	bne.s	.8
	move.l	#head_anim_l,a0
.8	move.l	a0,hl_tab_pos-x_tab_pos(a6)

	move.l	scorp_a_pos(pc),a0	; next scorpion anim
	addq	#2,a0
	cmp.l	#end_scorp_anim,a0
	bne.s	.9
	move.l	#scorp_anim,a0
.9	move.l	a0,scorp_a_pos-x_tab_pos(a6)

	move.l	fly_a_pos(pc),a0	; next fly anim
	addq	#2,a0
	cmp.l	#end_fly_anim,a0
	bne.s	.11
	move.l	#fly_anim,a0
.11	move.l	a0,fly_a_pos-x_tab_pos(a6)

	move.l	bee_a_pos(pc),a0	; next bee anim
	addq	#2,a0
	cmp.l	#end_bee_anim,a0
	bne.s	.12
	move.l	#bee_anim,a0
.12	move.l	a0,bee_a_pos-x_tab_pos(a6)
	lea	ce_table,a6
	not.w	d_flag-ce_table(a6)	; swap direction flag
	eor.w	#8,cd_flag-ce_table(a6)	; swap centi direction flag
		
	bsr.s	sfx			; process sound fx
	st	vbldone-ce_table(a6)
	movem.l	(a7)+,d0-a6
	rte	
;
; all sfx processing done here
;
sfx	lea	$ffff8800.w,a0	; YM registers	
	lea	2(a0),a1
; fire sounds
	move.l	fire_vol-ce_table(a6),a2	; fire table pointers
	move.l	fire_tone-ce_table(a6),a3	;
		
	cmp.l	#"TTH!",(a2)	; end?
	beq.s	.mush		; yes
.fire	move.w	(a2)+,d0		; get vol
	move.w	(a3)+,d1		; get tone
	move.b	#7,(a0)		; set up channels 
	move.b	#%00001110,(a1)	; 

	move.b	#8,(a0)		; set vol
	move.b	d0,(a1)		;
		
	move.b	#0,(a0)		; set fine tune 
	move.b	d1,(a1)		;

	move.b	#1,(a0)		; set coarse tune
	lsr.w	#8,d1		; fuck knows
	and.w	#3,d1		;
	move.b	d1,(a1)		;
		
	move.l	a2,fire_vol-ce_table(a6)	; store new values
	move.l	a3,fire_tone-ce_table(a6)	;

; mushie sounds

.mush	move.l	mush_vol-ce_table(a6),a2
	move.l	mush_tone-ce_table(a6),a3
		
	cmp.l	#"TTH!",(a2)
	beq.s	.bang
	move.w	(a2)+,d0
	move.w	(a3)+,d1
	move.b	#6,(a0)
	move.b	#29,(a1)
	move.b	#7,(a0)
	move.b	#%00001110,(a1)

	move.b	#9,(a0)
	move.b	d0,(a1)
		
	move.b	#2,(a0)
	move.b	d1,(a1)
	move.b	#3,(a0)
	lsr.w	#8,d1
	and.w	#3,d1
	move.b	d1,(a1)
		
	move.l	a2,mush_vol-ce_table(a6)
	move.l	a3,mush_tone-ce_table(a6)

; explosion sounds

.bang	move.l	bang_vol-ce_table(a6),a2
	move.l	bang_tone-ce_table(a6),a3
		
	cmp.l	#"TTH!",(a2)
	beq.s	.extra
		
	move.b	#6,(a0)
	move.b	#29,(a1)
	move.b	#7,(a0)
	move.b	#%00001110,(a1)
	move.w	(a2)+,d0
	move.w	(a3)+,d1
	move.b	#10,(a0)
	move.b	d0,(a1)
		
	move.b	#4,(a0)
	move.b	d1,(a1)
	move.b	#5,(a0)
	lsr.w	#8,d1
	and.w	#3,d1
	move.b	d1,(a1)
		
	move.l	a2,bang_vol-ce_table(a6)
	move.l	a3,bang_tone-ce_table(a6)

; bonus live sounds

.extra	move.l	extra_vol-ce_table(a6),a2
	move.l	extra_tone-ce_table(a6),a3
		
	cmp.l	#"TTH!",(a2)
	beq.s	.die
	move.w	(a2)+,d0
	move.w	(a3)+,d1
	move.b	#7,(a0)
	move.b	#%00111101,(a1)

	move.b	#9,(a0)
	move.b	d0,(a1)
		
	move.b	#2,(a0)
	move.b	d1,(a1)
	move.b	#3,(a0)
	lsr.w	#8,d1
	and.w	#3,d1
	move.b	d1,(a1)
		
	move.l	a2,extra_vol-ce_table(a6)
	move.l	a3,extra_tone-ce_table(a6)

; death sounds

.die	move.l	die_vol-ce_table(a6),a2
	move.l	die_tone-ce_table(a6),a3
		
	cmp.l	#"TTH!",(a2)
	beq.s	.exit
	move.w	(a2)+,d0
	move.w	(a3)+,d1
	move.b	#7,(a0)
	move.b	#%00111110,(a1)
	move.b	#8,(a0)
	move.b	d0,(a1)
		
	move.b	#0,(a0)
	move.b	d1,(a1)
	move.b	#1,(a0)
	lsr.w	#8,d1
	and.w	#3,d1
	move.b	d1,(a1)
		
	move.l	a2,die_vol-ce_table(a6)
	move.l	a3,die_tone-ce_table(a6)

.exit	rts
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Routine to plot all mushies added on previous screen onto new screen ;
; Needed because of double buffering                                   ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
add_mushies
	move.l	mb_ptr,a3		; end of last entry
	lea	mush_buffer,a2	; buffer 
	moveq	#0,d7
.1	cmp.l	a3,a2		; at end?
	beq.s	.3
	move.l	(a2),a0		; screen location
	move.l	d7,(a2)+		; clear
	move.l	(a2),a1		; address of graphic
	move.l	d7,(a2)+		; clear
	rept	8
	move.l	(a1)+,(a0)+	; draw it
	move.l	(a1)+,(a0)+	; draw it
	lea	160-8(a0),a0	; next scanline
	endr
	bra.s	.1		; loop
.3	move.l	#mush_buffer,mb_ptr
	rts	
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Routine to keep all collision detection together ; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
do_all_collision_detection
	move.w	x_coord,d0
	move.w	y_coord,d1
	move.w	d0,d2
	add.w	#13,d2
	move.w	d1,d3
	addq.w	#7,d3
ce_play	lea	ce_table,a4	; load centi table
.1	move.l	(a4)+,d5		; get first coords
	bmi.s	sc_play		; minus, end of table
	bne.s	.2		; blank 
	addq	#2,a4		; next coords
	bra.s	.1		; loop	
.2	move.w	-4(a4),d4		; load x coord
	move.w	(a4)+,d7		; direction
	lea	ce_dimns(pc),a0	; dimensions coz there are different sizes
	add.w	d7,d7		; *4
	add.w	d7,d7
	lea	(a0,d7.w),a0	; got dimensions
	bsr	centi_player_collision	; do it
	tst.w	live_lost		; did we hit it?
	bne	bull_centi	; evidently!
	bra.s	.1		; and round again

sc_play	lea	sc_table,a4	; load scorp table
.1	move.l	(a4)+,d5		; get first coords
	beq.s	.1		; blank 
	bmi.s	sp_play		; minus, end of table
	move.w	-4(a4),d4		; load x coord
	bsr	scorpion_player_collision
	tst.w	live_lost		; did we hit it?
	bne	bull_centi	; yup
	bra.s	.1		; and round again

sp_play	lea	sp_table,a4	; load spider table
.1	move.l	(a4)+,d7		; get an address
	beq.s	.1		; blank
	bmi.s	fly_play
	move.l	d7,a1		; to addr reg		 
	move.w	-(a1),d5		; load coords
	move.w	-(a1),d4		;
	bsr	spider_player_collision
	tst.w	live_lost		; did we hit it?
	bne.s	bull_centi	; yes
	bra.s	.1		; and round again

fly_play	lea	fly_table,a4	; load fly table
.1	move.l	(a4)+,d5		; get first coords
	addq	#2,a4		; skip dir
	beq.s	.1		; blank
	bmi.s	bee_play		; at end
	move.w	-6(a4),d4		; load x coord
	bsr	fly_player_collision
	tst.w	live_lost		; hit?
	bne.s	bull_centi	; yep
	bra.s	.1		; and round again

bee_play	lea	bee_table,a4	; load bee table
.1	move.l	(a4)+,d5		; get first coords
	addq	#4,a4		; skip shit
	beq.s	.1		; blank
	bmi.s	snail_play	; at end
	move.w	-8(a4),d4		; load x coord
	bsr	bee_player_collision
	tst.w	live_lost		; hit it?
	bne.s	bull_centi	; yup
	bra.s	.1		; and round again

snail_play
	lea	sn_table,a4	; load fly table
.1	move.l	(a4)+,d5		; get first coords
	addq	#2,a4		; skip dir
	beq.s	.1		; blank
	cmp.l	#'END!',d5
	beq.s	bull_centi	; end
	move.w	-6(a4),d4		; load x coord
	bsr	snail_player_collision	; do it
	tst.w	live_lost		; live gone?
	bne.s	bull_centi	; yup
	bra.s	.1		; and round again

bull_centi
	tst.w	ce_cnt		; wait til all centis on screen
	bpl.s	bull_snail
	move.w	bx_coord,d0	; any bullets
	bmi	exit		; nope
	lea	ce_table,a4	; load centi table
	lea	ce_heads,a5	; load head pointers
.1	addq	#4,a5		; start of heads
	move.l	(a4)+,d5		; get first coords
	bmi.s	bull_snail	; minus, end of table
	bne.s	.2		; blank 
	addq	#2,a4		; skip dir
	bra.s	.1		; loop	
.2	move.w	-4(a4),d4		; load x coord
	move.w	(a4)+,d7		; load dir
	lea	ce_dimns(pc),a0	; dimesnsions coz of differing sizes
	add.w	d7,d7		; *4
	add.w	d7,d7
	lea	(a0,d7.w),a0	; got dimensions
	bsr	bullet_centi_collision	; do it
	tst.w	d7		; any bullets left
	bmi	exit		; nope
	bra.s	.1		; and round again

bull_snail
	move.w	bx_coord,d0	; any bullets
	bmi	exit		; nope
	lea	sn_table,a4	; load snail table
.1	move.l	(a4)+,d5		; get first coords
	bne.s	.2		; anything there
	addq	#2,a4		; skip dir
	bra.s	.1		; loop
.2	addq	#2,a4		; skip dir
	cmp.l	#'END!',d5	; at end?
	beq.s	bull_fly		; yep
	move.w	-6(a4),d4		; load in X coord
	bsr	bullet_snail_collision
	tst.w	d7		; any bullets left
	bmi	exit		; nope
	bra.s	.1		; loop
bull_fly
	move.w	bx_coord,d0	; any bullets
	bmi	exit		; nope
	lea	fly_table,a4	; load fly table
.1	move.l	(a4)+,d5		; get first coords
	bne.s	.2		; anything there
	addq	#2,a4		; skip dir
	bra.s	.1		; blank
.2	addq	#2,a4		; skip dir
	bmi.s	bull_bee		; end of table
	move.w	-6(a4),d4		; load in X coord
	bsr	bullet_fly_collision
	tst.w	d7		; any bullets left
	bmi.s	exit		; nope
	bra.s	.1		; and again

bull_bee	move.w	bx_coord,d0	; any bullets
	bmi.s	exit		; nope
	lea	bee_table,a4	; load bee table
.1	move.l	(a4)+,d5		; get first coords
	bne.s	.2		; anything there
	addq	#4,a4		; skip dirs
	bra.s	.1		; blank
.2	addq	#4,a4		; skip dirs
	bmi.s	bull_scorp	; end of table
	move.w	-8(a4),d4		; load in X coord
	bsr	bullet_bee_collision
	tst.w	d7		; any bullets left
	bmi.s	exit		; nope
	bra.s	.1		; loop

bull_scorp
	move.w	bx_coord,d0	; any bullets
	bmi.s	exit		; nope
	lea	sc_table,a4	; load scorp table
.1	move.l	(a4)+,d5		; get first coords
	beq.s	.1		; blank
	bmi.s	bull_spidey	; minus, end of table
	move.w	-4(a4),d4		; load in X coord
	bsr	bullet_scorpion_collision
	tst.w	d7		; any bullets left
	bmi.s	exit		; nope
	bra.s	.1		; and again

bull_spidey
	move.w	bx_coord,d7	; any bullets
	bmi.s	exit		; nope

	lea	sp_table,a4	; load spider table
.1	move.l	(a4)+,d1		; get an address
	beq.s	.1		; blank
	bmi.s	bull_mushie	; minus, end of table 
	move.l	d1,a1		
	move.w	-(a1),d5		; load y
	move.w	-(a1),d4		; laod x 
	bsr	bullet_spider_collision
	tst.w	d7		; any bullets left
	bmi.s	exit		; nope
	bra.s	.1		; wrap

bull_mushie
	move.w	bx_coord,d2	; any coords?
	bmi.s	exit
	bsr	bullet_mushie_collision
exit	rts
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Routine to add segment of centipede at top of screen ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
add_centi	tst.w	ce_cnt
	bmi.s	.exit
	subq	#1,ce_cntr
	bpl.s	.exit
	move.w	#8,ce_cntr
	move.w	c4level,d0
	move.w	ce_cnt,d1
	cmp.w	d0,d1
	bne.s	.1
	move.l	#ce_table,ce_heads
.1	subq	#1,ce_cnt
	move.l	ce_t_pos,a0
	move.w	#160,(a0)+	
	move.w	#8,(a0)+	
	move.w	curr_cd,(a0)+
	move.l	#-1,(a0)
	move.l	a0,ce_t_pos
.exit	rts

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Routine to keep all object updating together ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
update_everything
	tst.w	demo_mode
	bne.s	.1
	move.w	x_coord,d0	
	move.w	y_coord,d1	
	bsr	player_mushie_collision
	move.l	x_coord,lx_coord
.1	bsr	update_centi_heads
	bsr	update_centi_bodys
	bsr	update_spider
	bsr	update_scorp
	bsr	update_snail
	bsr	update_fly
	bsr	update_bee
	bsr	update_scores
	tst.w	demo_mode
	bne.s	.exit
	move.b	chip_val,d0
	cmp.b	#1,d0
	blt.s	.fire_not_pressed
	cmp.b	#3,d0
	bgt.s	.fire_not_pressed

.fire_pressed
	move.w	bx_coord,d2
	bpl.s	.fire_not_pressed
	move.w	x_coord,bx_coord
	addq	#7,bx_coord
	move.w	y_coord,by_coord
	move.l	#firvol,fire_vol
	move.l	#firtone,fire_tone
.fire_not_pressed
	move.w	by_coord,d3
	bmi.s	.exit
	bsr	update_bullet
.exit	rts
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Routine to keep all object plotting together ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
plot_everything
	lea	ce_table,a0
.1	move.l	(a0)+,d1		; load coords
	addq	#2,a0		; skip dir
	beq.s	.1		; blank?
	bmi.s	do_scores		; end?
	move.w	-6(a0),d0		; load x coord
	move.w	-2(a0),d7		; load direction
	move.l	a0,-(a7)
	move.l	-12(a0),d6	; if blanks before then its a head
	beq.s	.2
	bsr	plot_centi	; plot body
	move.l	(a7)+,a0
	bra.s	.1		; loop
.2	bsr	plot_head		; plot head
	move.l	(a7)+,a0
	bra.s	.1		; loop

do_scores	lea	scr_table,a0
	subq	#4,a0
.1	addq	#4,a0
	move.l	(a0)+,d1		; load coords
	beq.s	.1		; blank so loop
	bmi.s	do_spider		; end
	move.w	-4(a0),d0		; load x coord
	move.w	(a0),d2		; load score number
	move.l	a0,-(a7)
	bsr	plot_score	; do it
	move.l	(a7)+,a0
	bra.s	.1		; loop

do_spider	lea	sp_table,a0
.1	move.l	(a0)+,d1		; load coords
	beq.s	.1		; blank so loop
	bmi.s	do_scorp		; end
	move.l	d1,a1		; coords pointer
	move.w	-(a1),d1		; load xcoord
	move.w	-(a1),d0		; load ycoord
	bmi.s	.lclip		; off to the left
	cmp.w	#MAX_X,d0		; off to the right
	bge.s	.rclip	
	move.l	a0,-(a7)		; normal
	bsr	plot_spider
	move.l	(a7)+,a0
	bra.s	.1		; loop
.lclip	move.l	a0,-(a7)
	bsr	plot_spider_lc
	move.l	(a7)+,a0
	bra.s	.1
.rclip	move.l	a0,-(a7)
	bsr	plot_spider_rc
	move.l	(a7)+,a0
	bra.s	.1

do_scorp	lea	sc_table,a0
.1	move.l	(a0)+,d1		; load coords
	beq.s	.1		; loop coz blank
	bmi.s	do_snail		; end
	move.w	-4(a0),d0		; load xcoord
	move.l	a0,-(a7)
	bsr	plot_scorp
	move.l	(a7)+,a0
	bra.s	.1		; loop

do_snail	lea	sn_table,a0
.1	move.l	(a0)+,d1		; load coords
	bne.s	.2		; somethig there	
	addq	#2,a0		; skip dir
	bra.s	.1		; loop
.2	cmp.l	#'END!',d1	; end? 
	beq.s	do_fly
	move.w	(a0)+,dir		; load dir
	move.w	-6(a0),d0		; load xcoord
	bmi.s	.lclip		; off to the left
	cmp.w	#MAX_X,d0		; off to the right
	bge.s	.rclip	
	move.l	a0,-(a7)
	bsr	plot_snail
	move.l	(a7)+,a0
	bra.s	.1		; loop
.lclip	move.l	a0,-(a7)
	bsr	plot_snail_lc
	move.l	(a7)+,a0
	bra.s	.1		; loop
.rclip	move.l	a0,-(a7)
	bsr	plot_snail_rc
	move.l	(a7)+,a0
	bra.s	.1		; loop

do_fly	lea	fly_table,a0	; load coords table
.1	move.l	(a0)+,d1		; load coords
	bne.s	.2		; process it	
	addq	#2,a0		; nowt there
	bra.s	.1		; so loop
.2	bmi.s	do_bee		; so piss off
	move.w	(a0)+,dir		; load dir
	move.w	-6(a0),d0		; load x coord
	move.l	a0,-(a7)		; save a0
	bsr	plot_fly
	move.l	(a7)+,a0
	bra.s	.1		; loooooop!

do_bee	lea	bee_table,a0	; load coords table
.1	move.l	(a0)+,d1		; load coords
	bne.s	.2		; process it	
	addq	#4,a0		; nowt there
	bra.s	.1		; so loop
.2	bmi.s	do_bullet		; so piss off
	move.w	-4(a0),d0		; load x coord
	move.l	a0,-(a7)		; save a0
	bsr	plot_bee
	move.l	(a7)+,a0
	addq	#4,a0		
	bra.s	.1		; loooooop!

do_bullet	move.w	bx_coord,d0
	bmi.s	do_ship
	move.w	by_coord,d1
	bsr	plot_bullet

do_ship	tst.w	demo_mode
	bne.s	.exit
	bsr	plot_ship
.exit	rts	

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test if collision with mushie, alter coords if so ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
player_mushie_collision
	lea	mushie_tab,a5	; mushie stored here
	moveq	#0,d2
	moveq	#0,d3
	moveq	#15,d7

	move.w	x_coord,d0	; player coords
	move.w	y_coord,d1	;

	move.w	lx_coord,d4	; last coords
	move.w	ly_coord,d5	;

; did we collide with a mushie on our left centre

	move.w	d0,d2
	move.w	d1,d3

	addq.w	#4,d3		; fix y

	lsr.w	#4,d2
	lsr.w	#3,d3

	mul_20	d3,d2
	tst.b	(a5,d2.w)	
	beq.s	.2
	move.w	d4,x_coord
	move.w	d5,y_coord
	bra	.bye

; did we collide with a mushie on our left top

.2	move.w	d0,d2	
	move.w	d1,d3

	lsr.w	#4,d2
	lsr.w	#3,d3

	mul_20	d3,d2

	tst.b	(a5,d2.w)
	beq.s	.3
	move.w	d4,x_coord
	move.w	d5,y_coord
	bra	.bye

; did we collide with a mushie on our top centre

.3	move.w	d0,d2
	move.w	d1,d3

	addq.w	#8,d2		; fix x

	lsr.w	#4,d2
	lsr.w	#3,d3

	mul_20	d3,d2
	tst.b	(a5,d2.w)
	beq.s	.4

	move.w	d4,x_coord
	move.w	d5,y_coord
	bra	.bye

; did we collide with a mushie on our right TOP

.4	move.w	d0,d2
	move.w	d1,d3

	add.w	d7,d2		; fix x

	lsr.w	#4,d2
	lsr.w	#3,d3

	mul_20	d3,d2
	tst.b	(a5,d2.w)
	beq.s	.5
	move.w	d4,x_coord
	move.w	d5,y_coord
	bra	.bye

; did we collide with a mushie on our right centre

.5	move.w	d0,d2		; Top left
	move.w	d1,d3

	add.w	d7,d2		; fix x
	addq.w	#4,d3		; fix y

	lsr.w	#4,d2
	lsr.w	#3,d3

	mul_20	d3,d2
	tst.b	(a5,d2.w)
	beq.s	.6
	move.w	d4,x_coord
	move.w	d5,y_coord
	bra.s	.bye

; did we collide with a mushie on our right bottom

.6	move.w	d0,d2	
	move.w	d1,d3

	add.w	d7,d2		; fix x
	addq.w	#7,d3		; fix y

	lsr.w	#4,d2
	lsr.w	#3,d3

	mul_20	d3,d2

	tst.b	(a5,d2.w)
	beq.s	.7
	move.w	d4,x_coord
	move.w	d5,y_coord

	bra.s	.bye

; did we collide with a mushie on our bottom centre

.7	move.w	d0,d2
	move.w	d1,d3

	addq.w	#8,d2		; fix x
	addq.w	#7,d3		; fix y

	lsr.w	#4,d2
	lsr.w	#3,d3

	mul_20	d3,d2
	tst.b	(a5,d2.w)
	beq.s	.8
	move.w	d4,x_coord
	move.w	d5,y_coord
	bra.s	.bye

; did we collide with a mushie on our left bottom

.8	move.w	d0,d2
	move.w	d1,d3

	addq.w	#7,d3		; fix y

	lsr.w	#4,d2
	lsr.w	#3,d3

	mul_20	d3,d2
	tst.b	(a5,d2.w)
	beq.s	.bye
	move.w	d4,x_coord
	move.w	d5,y_coord
.bye	rts
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test if bullet collision with mushie, alter coords if so ;
; and update mushies on screen and on map                  ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
bullet_mushie_collision

; Test LHS first
	moveq	#0,d2
	moveq	#0,d3
	moveq	#0,d7

	move.w	bx_coord,d0	; bullet coords
	move.w	by_coord,d1

	lsr.w	#4,d0	; /16
	lsr.w	#3,d1	; /8

	lea	mushie_tab,a6	; table of mushies
	add.w	d0,a6		; add x coord
	mul_20	d1,a6
	move.b	(a6),d7		; load mushie
	bne.s	update_screen_and_map	; nowt there?

	rts	; nothing hit so bugger off!
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Update screen and map. If mushie    ;
; hit then update map and draw mushie ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
update_screen_and_map
	move.l	#mushvol,mush_vol	; play sound
	move.l	#mushtone,mush_tone


.1	subq	#1,d7		; update mushie val
	bne.s	.2		; is it dead?

	add2score	1	
	bsr	plot_scores

.2	move.w	bx_coord,d0
	move.w	by_coord,d1
	and.b	#%11110000,d0
	and.b	#%11111000,d1
	move.b	d7,(a6)		; store new val
	add.w	d1,d1		; y*4 
	move.l	screen2(pc),a0	; screen2
	move.l	screen1(pc),a5	; screen1
	lea	mul160(pc),a4		; Add y offset
	add.w	(a4,d1.w),a0	;
	add.w	(a4,d1.w),a5	;
 	moveq	#15,d2		; calc x offset
	move.w	d0,d1
	and.w	d2,d0
	eor.w	d0,d1
	lsr.w	#1,d1
	add.w	d1,a0
	add.w	d1,a5
	tst.b	d7		; blanked out
	bne.s	.4
	lea	b_mush,a4		; blank space
	bra.s	.5
.4	subq	#1,d7
	lea	m_tab(pc),a4	; mushie pointers
	lsl.w	#2,d7		; mush_state * 4
	move.l	(a4,d7.w),a4	; load mushie grafix
.5	move.l	mb_ptr,a2		; pointer to save area
	move.l	a5,(a2)+	; screen1
	move.l	a4,(a2)+	; mushie gfx	
	move.l	a2,mb_ptr		; save pointer
	moveq	#7,d7
.3	move.l	(a4)+,(a0)+	; plot mushie
	move.l	(a4)+,(a0)+
	lea	160-8(a0),a0
	dbf	d7,.3
	moveq	#-1,d0
	move.w	d0,bx_coord
	move.w	d0,by_coord
	rts			
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test if bullet collision with centipede ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
bullet_centi_collision
	move.w	bx_coord,d0
	move.w	d0,d2
	move.w	d4,d6
	addq.w	#2,d2
	add.w	(a0)+,d6

	cmp.w	d0,d4	
	bgt.s	.try_X_again	
	cmp.w	d2,d6	
	blt.s	.try_X_again2
	bra.s	.checky

.try_X_again
	cmp.w	d2,d4
	bgt.s	.exit
	blt.s	.checky

.try_X_again2
	cmp.w	d0,d6
	blt.s	.exit

.checky	move.w	by_coord,d1
	move.w	d1,d3
	move.w	d5,d7
	addq.w	#7,d3
	add.w	(a0),d7
	cmp.w	d1,d5	
	bgt.s	.try_Y_again
	cmp.w	d1,d7	
	blt.s	.try_Y_again2
	bgt.s	.hit

.try_Y_again
	cmp.w	d3,d5
	bgt.s	.exit
	blt.s	.hit
.exit	moveq	#0,d7
	rts

.try_Y_again2
	cmp.w	d3,d7
	blt.s	.exit

.hit	bsr	add_mushie_4_centi
	moveq	#0,d0
	move.l	d0,-6(a4)
	move.w	d0,-2(a4)
	move.l	#bangvol,bang_vol
	move.l	#bangtone,bang_tone
	add2score	100
	bsr	plot_scores
	move.l	-4(a5),a6
	lea	-6(a4),a2
	cmp.l	a6,a2
	bne.s	.4
	moveq	#0,d0
	move.l	d0,-4(a5)
.4	move.l	(a4),d0
	bmi.s	.3
	bne.s	.add_head
	
.3	subq	#1,c2kill
	bmi.s	.ce_all_gone
	moveq	#-1,d7
	move.w	d7,bx_coord
	move.w	d7,by_coord
	rts
.add_head	move.l	a4,(a5)
	bra.s	.3
.ce_all_gone
	move.w	cd_flag,curr_cd
	move.l	curr_wave,a5
	lea	16(a5),a5
	cmp.l	#end_waves,a5
	bne.s	.ne
	lea	loop_waves,a5
.ne	move.l	a5,curr_wave
	move.w	(a5),ce_cnt
	move.w	#8,ce_cntr
	move.w	(a5),c2kill
	move.w	(a5)+,c4level
	move.w	(a5)+,spider_tot
	move.w	(a5)+,scorp_tot
	move.w	(a5)+,snail_tot
	move.w	(a5)+,fly_tot
	move.w	(a5)+,bee_tot
	move.w	(a5)+,wave
	beq.s	.nw
	move.w	#0,timer	
	moveq	#0,d1	
	bsr	kill_beasties
.nw	move.w	(a5)+,diff
	move.w	scorps_on_screen,d0
	sub.w	d0,scorp_tot
	move.w	spiders_on_screen,d0
	sub.w	d0,spider_tot
	move.w	bees_on_screen,d0
	sub.w	d0,bee_tot
	move.w	flys_on_screen,d0
	sub.w	d0,fly_tot
	move.w	snails_on_screen,d0
	sub.w	d0,snail_tot

.nw2	moveq	#0,d1
	bsr	 kill_centis
	moveq	#-1,d7
	move.w	d7,bx_coord
	move.w	d7,by_coord
	rts
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test if bullet collision with snail ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
bullet_snail_collision
	move.w	bx_coord,d0
	move.w	d0,d2
	move.w	d4,d6
	addq.w	#2,d2
	add.w	#15,d6

	cmp.w	d0,d4	
	bgt.s	.try_X_again	
	cmp.w	d2,d6	
	blt.s	.try_X_again2
	bra.s	.checky

.try_X_again
	cmp.w	d2,d4
	bgt.s	.exit
	blt.s	.checky

.try_X_again2
	cmp.w	d0,d6
	blt.s	.exit

.checky	move.w	by_coord,d1
	move.w	d1,d3
	move.w	d5,d7
	addq.w	#5,d3
	addq.w	#7,d7
	cmp.w	d1,d5	
	bgt.s	.try_Y_again
	cmp.w	d1,d7	
	blt.s	.try_Y_again2
	bgt.s	.hit

.try_Y_again
	cmp.w	d3,d5
	bgt.s	.exit
	blt.s	.hit
.exit	moveq	#0,d7
	rts

.try_Y_again2
	cmp.w	d3,d7
	blt.s	.exit

.hit	moveq	#0,d0
	move.l	d0,-6(a4)
	move.w	d0,-2(a4)
	addq	#1,snail_tot
	subq	#1,snails_on_screen
	move.l	#bangvol,bang_vol
	move.l	#bangtone,bang_tone
	add2score	100
	bsr	plot_scores
	lea	scr_table,a0
	subq	#4,a0
.1	addq	#4,a0
	move.l	(a0)+,d1
	beq.s	.2
	bmi.s	.4
	bra.s	.1
.2	tst.w	d4
	bpl.s	.3
	moveq	#0,d4
.3	move.w	d4,-4(a0)
	move.w	d5,-2(a0)
	
	move.w	d0,(a0)+
	moveq	#SCR_TIME-1,d0
	move.w	d0,(a0)

.4	moveq	#-1,d7
	move.w	d7,bx_coord
	move.w	d7,by_coord
	rts	
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test if bullet collision with fly ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
bullet_fly_collision
	move.w	bx_coord,d0
	move.w	d0,d2
	move.w	d4,d6
	addq.w	#2,d2
	add.w	#15,d6

	cmp.w	d0,d4	
	bgt.s	.try_X_again	
	cmp.w	d2,d6	
	blt.s	.try_X_again2
	bra.s	.checky

.try_X_again
	cmp.w	d2,d4
	bgt.s	.exit
	blt.s	.checky

.try_X_again2
	cmp.w	d0,d6
	blt.s	.exit

.checky	move.w	by_coord,d1
	move.w	d1,d3
	move.w	d5,d7
	addq.w	#5,d3
	add.w	#15,d7
	cmp.w	d1,d5	
	bgt.s	.try_Y_again
	cmp.w	d1,d7	
	blt.s	.try_Y_again2
	bgt.s	.hit

.try_Y_again
	cmp.w	d3,d5
	bgt.s	.exit
	blt.s	.hit
.exit	moveq	#0,d7
	rts

.try_Y_again2
	cmp.w	d3,d7
	blt.s	.exit

.hit	moveq	#0,d0
	move.l	d0,-6(a4)
	move.w	d0,-2(a4)
	addq	#1,fly_tot
	subq	#1,flys_on_screen
	move.l	#bangvol,bang_vol
	move.l	#bangtone,bang_tone
	add2score	500
	bsr	plot_scores
	lea	scr_table,a0
	subq	#4,a0
.1	addq	#4,a0
	move.l	(a0)+,d1
	beq.s	.2
	bmi.s	.4
	bra.s	.1
.2	tst.w	d4
	bpl.s	.3
	moveq	#0,d4
.3	move.w	d4,-4(a0)
	move.w	d5,-2(a0)
	
	moveq	#1*4,d0
	move.w	d0,(a0)+
	moveq	#SCR_TIME-1,d0
	move.w	d0,(a0)

.4	moveq	#-1,d7
	move.w	d7,bx_coord
	move.w	d7,by_coord
.5	rts	
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test if bullet collision with bee ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
bullet_bee_collision
	move.w	bx_coord,d0
	move.w	d0,d2
	move.w	d4,d6
	addq.w	#2,d2
	add.w	#15,d6

	cmp.w	d0,d4	
	bgt.s	.try_X_again	
	cmp.w	d2,d6	
	blt.s	.try_X_again2
	bra.s	.checky

.try_X_again
	cmp.w	d2,d4
	bgt.s	.exit
	blt.s	.checky

.try_X_again2
	cmp.w	d0,d6
	blt.s	.exit

.checky	move.w	by_coord,d1
	move.w	d1,d3
	move.w	d5,d7
	addq.w	#5,d3
	addq.w	#7,d7
	cmp.w	d1,d5	
	bgt.s	.try_Y_again
	cmp.w	d1,d7	
	blt.s	.try_Y_again2
	bgt.s	.hit

.try_Y_again
	cmp.w	d3,d5
	bgt.s	.exit
	blt.s	.hit
.exit	moveq	#0,d7
	rts

.try_Y_again2
	cmp.w	d3,d7
	blt.s	.exit

.hit	moveq	#0,d0
	move.l	d0,-8(a4)
	move.l	d0,-4(a4)
	addq	#1,bee_tot
	subq	#1,bees_on_screen
	move.l	#bangvol,bang_vol
	move.l	#bangtone,bang_tone
	add2score	500
	bsr	plot_scores
	lea	scr_table,a0
	subq	#4,a0
.1	addq	#4,a0
	move.l	(a0)+,d1
	beq.s	.2
	bmi.s	.4
	bra.s	.1
.2	tst.w	d4
	bpl.s	.3
	moveq	#0,d4
.3	move.w	d4,-4(a0)
	move.w	d5,-2(a0)
	
	moveq	#1*4,d0
	move.w	d0,(a0)+
	moveq	#SCR_TIME-1,d0
	move.w	d0,(a0)

.4	moveq	#-1,d7
	move.w	d7,bx_coord
	move.w	d7,by_coord
.5	rts	

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test if bullet collision with scorpion ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
bullet_scorpion_collision
	move.w	bx_coord,d0
	move.w	d0,d2
	move.w	d4,d6
	addq.w	#2,d2
	add.w	#15,d6

	cmp.w	d0,d4	
	bgt.s	.try_X_again	
	cmp.w	d2,d6	
	blt.s	.try_X_again2
	bra.s	.checky

.try_X_again
	cmp.w	d2,d4
	bgt.s	.exit
	blt.s	.checky

.try_X_again2
	cmp.w	d0,d6
	blt.s	.exit

.checky	move.w	by_coord,d1
	move.w	d1,d3
	move.w	d5,d7
	addq.w	#5,d3
	add.w	#12,d7
	cmp.w	d1,d5	
	bgt.s	.try_Y_again
	cmp.w	d1,d7	
	blt.s	.try_Y_again2
	bgt.s	.hit

.try_Y_again
	cmp.w	d3,d5
	bgt.s	.exit
	blt.s	.hit
.exit	moveq	#0,d7
	rts

.try_Y_again2
	cmp.w	d3,d7
	blt.s	.exit

.hit	moveq	#0,d0
	move.l	d0,-4(a4)
	addq	#1,scorp_tot
	subq	#1,scorps_on_screen
.nw	move.l	#bangvol,bang_vol
	move.l	#bangtone,bang_tone
	add2score	500
	bsr	plot_scores
	lea	scr_table,a0
	subq	#4,a0
.1	addq	#4,a0
	move.l	(a0)+,d1
	beq.s	.2
	bmi.s	.3
	bra.s	.1
.2	move.w	d4,-4(a0)
	move.w	d5,-2(a0)
	moveq	#1*4,d0
	move.w	d0,(a0)+
	moveq	#SCR_TIME-1,d0
	move.w	d0,(a0)
.3	moveq	#-1,d7
	move.w	d7,bx_coord
	move.w	d7,by_coord
.4	rts	
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test if bullet collision with spider ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
bullet_spider_collision
	move.w	bx_coord,d0
	move.w	d0,d2
	move.w	d4,d6
	addq.w	#2,d2
	add.w	#15,d6

	cmp.w	d0,d4	
	bgt.s	.try_X_again	
	cmp.w	d2,d6	
	blt.s	.try_X_again2
	bra.s	.checky

.try_X_again
	cmp.w	d2,d4
	bgt.s	.exit
	blt.s	.checky

.try_X_again2
	cmp.w	d0,d6
	blt.s	.exit

.checky	move.w	by_coord,d1
	move.w	d1,d3
	move.w	d5,d7
	addq.w	#5,d3
	add.w	#12,d7
	cmp.w	d1,d5	
	bgt.s	.try_Y_again
	cmp.w	d1,d7	
	blt.s	.try_Y_again2
	bgt.s	.hit

.try_Y_again
	cmp.w	d3,d5
	bgt.s	.exit
	blt.s	.hit
.exit	moveq	#0,d7
	rts

.try_Y_again2
	cmp.w	d3,d7
	blt.s	.exit

.hit	moveq	#0,d0
	move.l	d0,-4(a4)
	addq	#1,spider_tot
	subq	#1,spiders_on_screen
	move.l	#bangvol,bang_vol
	move.l	#bangtone,bang_tone
	add2score	1000
	bsr	plot_scores
	lea	scr_table,a0
	subq	#4,a0
.1	addq	#4,a0
	move.l	(a0)+,d1
	beq.s	.2
	bmi.s	.3
	bra.s	.1
.2	tst.w	d4
	bpl.s	.22
	moveq	#0,d4
.22	move.w	d4,-4(a0)
	move.w	d5,-2(a0)
	move.w	#2*4,d0
	move.w	d0,(a0)+
	moveq	#SCR_TIME-1,d0
	move.w	d0,(a0)
.3	moveq	#-1,d7
	move.w	d7,bx_coord
	move.w	d7,by_coord

	rts	
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test if player collision with centipede ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
centi_player_collision
	move.w	d4,d6
	add.w	(a0)+,d6

	cmp.w	d0,d4	
	bgt.s	.try_X_again	
	cmp.w	d2,d6	
	blt.s	.try_X_again2
	bra.s	.checky

.try_X_again
	cmp.w	d2,d4
	bgt.s	.exit
	blt.s	.checky

.try_X_again2
	cmp.w	d0,d6
	blt.s	.exit

.checky	move.w	d5,d7
	add.w	(a0),d7
	cmp.w	d1,d5	
	bgt.s	.try_Y_again
	cmp.w	d1,d7	
	blt.s	.try_Y_again2
	bgt.s	.hit

.try_Y_again
	cmp.w	d3,d5
	bgt.s	.exit
	blt.s	.hit
.exit	rts

.try_Y_again2
	cmp.w	d3,d7
	blt.s	.exit

.hit	addq	#5,lives
	subq	#6,lives
	st	live_lost
	rts
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test if player collision with spider ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
spider_player_collision
	move.w	d4,d6
	add.w	#14,d6

	cmp.w	d0,d4	
	bgt.s	.try_X_again	
	cmp.w	d2,d6	
	blt.s	.try_X_again2
	bra.s	.checky

.try_X_again
	cmp.w	d2,d4
	bgt.s	.exit
	blt.s	.checky

.try_X_again2
	cmp.w	d0,d6
	blt.s	.exit

.checky	move.w	d5,d7
	add.w	#12,d7
	cmp.w	d1,d5	
	bgt.s	.try_Y_again
	cmp.w	d1,d7	
	blt.s	.try_Y_again2
	bgt.s	.hit

.try_Y_again
	cmp.w	d3,d5
	bgt.s	.exit
	blt.s	.hit
.exit	rts

.try_Y_again2
	cmp.w	d3,d7
	blt.s	.exit

.hit	addq	#5,lives
	subq	#6,lives
	st	live_lost
	rts
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test if player collision with scorpion ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
scorpion_player_collision
	move.w	d4,d6
	add.w	#15,d6

	cmp.w	d0,d4	
	bgt.s	.try_X_again	
	cmp.w	d2,d6	
	blt.s	.try_X_again2
	bra.s	.checky

.try_X_again
	cmp.w	d2,d4
	bgt.s	.exit
	blt.s	.checky

.try_X_again2
	cmp.w	d0,d6
	blt.s	.exit

.checky	move.w	d5,d7
	add.w	#12,d7
	cmp.w	d1,d5	
	bgt.s	.try_Y_again
	cmp.w	d1,d7	
	blt.s	.try_Y_again2
	bgt.s	.hit

.try_Y_again
	cmp.w	d3,d5
	bgt.s	.exit
	blt.s	.hit
.exit	rts

.try_Y_again2
	cmp.w	d3,d7
	blt.s	.exit

.hit	addq	#5,lives
	subq	#6,lives
	st	live_lost
.bye	rts
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test if player collision with fly ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
fly_player_collision
	move.w	d4,d6
	add.w	#15,d6

	cmp.w	d0,d4	
	bgt.s	.try_X_again	
	cmp.w	d2,d6	
	blt.s	.try_X_again2
	bra.s	.checky

.try_X_again
	cmp.w	d2,d4
	bgt.s	.exit
	blt.s	.checky

.try_X_again2
	cmp.w	d0,d6
	blt.s	.exit

.checky	move.w	d5,d7
	add.w	#15,d7
	cmp.w	d1,d5	
	bgt.s	.try_Y_again
	cmp.w	d1,d7	
	blt.s	.try_Y_again2
	bgt.s	.hit

.try_Y_again
	cmp.w	d3,d5
	bgt.s	.exit
	blt.s	.hit
.exit	rts

.try_Y_again2
	cmp.w	d3,d7
	blt.s	.exit

.hit	addq	#5,lives
	subq	#6,lives
	st	live_lost

.bye	rts
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test if player collision with bee ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
bee_player_collision
	move.w	d4,d6
	add.w	#15,d6

	cmp.w	d0,d4	
	bgt.s	.try_X_again	
	cmp.w	d2,d6	
	blt.s	.try_X_again2
	bra.s	.checky

.try_X_again
	cmp.w	d2,d4
	bgt.s	.exit
	blt.s	.checky

.try_X_again2
	cmp.w	d0,d6
	blt.s	.exit

.checky	move.w	d5,d7
	addq.w	#7,d7
	cmp.w	d1,d5	
	bgt.s	.try_Y_again
	cmp.w	d1,d7	
	blt.s	.try_Y_again2
	bgt.s	.hit

.try_Y_again
	cmp.w	d3,d5
	bgt.s	.exit
	blt.s	.hit
.exit	rts

.try_Y_again2
	cmp.w	d3,d7
	blt.s	.exit

.hit	addq	#5,lives
	subq	#6,lives
	st	live_lost

.bye	rts

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Test if player collision with snail ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
snail_player_collision
	move.w	d4,d6
	add.w	#15,d6

	cmp.w	d0,d4	
	bgt.s	.try_X_again	
	cmp.w	d2,d6	
	blt.s	.try_X_again2
	bra.s	.checky

.try_X_again
	cmp.w	d2,d4
	bgt.s	.exit
	blt.s	.checky

.try_X_again2
	cmp.w	d0,d6
	blt.s	.exit

.checky	move.w	d5,d7
	addq.w	#7,d7
	cmp.w	d1,d5	
	bgt.s	.try_Y_again
	cmp.w	d1,d7	
	blt.s	.try_Y_again2
	bgt.s	.hit

.try_Y_again
	cmp.w	d3,d5
	bgt.s	.exit
	blt.s	.hit
.exit	rts

.try_Y_again2
	cmp.w	d3,d7
	blt.s	.exit

.hit	addq	#5,lives
	subq	#6,lives
	st	live_lost
	rts
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Add mushie when centi gets busted ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
add_mushie_4_centi
	cmp.w	#8,d5	; dont want them on first line
	blt.s	.exit
	and.b	#%11110000,d4	; 16 pixel boundary please!
	and.b	#%11111000,d5
	move.w	d4,d6	; store coords
	move.w	d5,d7	;

	lsr.w	#4,d4	; /16
	lsr.w	#3,d5	; /8
	lea	mushie_tab,a6	; table of mushies
	add.w	d4,a6
	mul_20	d5,a6
	move.w	d7,d5

	move.b	#3,(a6)	; set up map

	add.w	d7,d7	; y*2
	move.l	screen2(pc),a0	; screen2
	move.l	screen1(pc),a3	; screen1
	lea	mul160(pc),a6		; Add y offset
	add.w	(a6,d7.w),a0	;
	add.w	(a6,d7.w),a3	;
	move.w	d6,d7
	and.w	#15,d6
	eor.w	d6,d7
	lsr.w	#1,d7
	add.w	d7,a0
	add.w	d7,a3
	lsr.w	#1,d6
	move.l	m_tab+8(pc),a6
	move.l	mb_ptr,a2	; pointer to save area
	move.l	a3,(a2)+	; screen2
	move.l	a6,(a2)+	; mushie gfx
	move.l	a2,mb_ptr	; save pointer
	moveq	#7,d7
.1	move.l	(a6)+,(a0)+	; plot mushie
	move.l	(a6)+,(a0)+
	lea	160-8(a0),a0
	dbf	d7,.1

.exit	rts

;
;;;;;;;;;;;;;;;;;;;;;;;;;
; Code to update bullet ;
;;;;;;;;;;;;;;;;;;;;;;;;;
;
update_bullet
	subq	#B_SPEED,d3
	bpl.s	.1
	move.w	d3,bx_coord
	move.w	d3,by_coord
	rts
.1	move.w	d3,by_coord
	rts
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Routine to update centipede heads ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
update_centi_heads
	lea	loop_table,a6
	lea	ce_heads,a2
	lea	pntr_table,a4
.again	move.l	(a4)+,a1		; get table to store coords
	move.l	(a6)+,d6
	move.l	(a2)+,d7		; get a head
	bmi.s	.exit		; end of table
	beq.s	.again		; blank
	move.l	d7,a3		; copy to address reg
	lea	mushie_tab,a5	; need this for coll detect	
	move.w	(a3)+,d0		; x
;	beq.s	.again
	move.w	(a3)+,d1		; y
	move.w	(a3)+,d2		; dir
	add.w	d2,d2
	add.w	d2,d2
	lea	ce_dirs(pc),a0
	move.l	(a0,d2.w),a0
	add.w	d2,r_val
	jsr	(a0)
	bra.s	.again
.exit	rts

ce_right	addq	#2,d0
	cmp.w	#MAX_X,d0		; rh edge of screen
	blt.s	.1		; no
	cmp.w	#MAX_Y-2,d1	;bottom rh corner
	blt.s	.11
	subq	#2,d1
	subq	#2,d0
	moveq	#23,d7
	bra	upd_tab	
.11	moveq	#1,d7
	bra	upd_tab
; collision check from here
.1	move.w	d0,d2
	move.w	d1,d3
	add.w	#15,d2
	lsr.w	#4,d2
	lsr.w	#3,d3
	mul_20	d3,d2
	moveq	#1,d7
; did we hit a mushie from the top
	tst.b	(a5,d2.w)	  ; top hit mushie
	bne	upd_tab	  ; yep
	moveq	#0,d7	
	bra	upd_tab	

ce_dr_1	moveq	#2,d7
	bra	upd_tab

ce_dr_2	addq	#2,d0
	moveq	#3,d7
	bra	upd_tab

ce_dr_3	addq	#2,d0
	moveq	#4,d7
	bra	upd_tab

ce_dr_4	addq	#2,d0
	addq	#2,d1
	moveq	#5,d7
	bra	upd_tab

ce_dr_5	subq	#2,d0
	addq	#2,d1
	cmp.w	#MAX_Y,d1
	ble.s	.1
	move.w	#MAX_Y,d1
.1	moveq	#6,d7
	bra	upd_tab	

ce_dr_6	subq	#2,d0
	addq	#2,d1
	cmp.w	#MAX_Y,d1
	ble.s	.1
	move.w	#MAX_Y,d1
.1	moveq	#7,d7
	bra	upd_tab	

ce_dr_7	subq	#2,d0
	addq	#2,d1
	cmp.w	#MAX_Y,d1
	ble.s	.1
	move.w	#MAX_Y,d1
.1	moveq	#8,d7
	bra	upd_tab	

ce_left	subq	#2,d0
	cmp.w	#2,d0
	bgt.s	.1	; not off edge of screen
	cmp.w	#MAX_Y-2,d1 ; bottom lhcorner of screen
	blt.s	.111	  ; nope
	subq	#2,d1
	moveq	#2,d0
	moveq	#16,d7	  ; go up now
	bra	upd_tab	
.111	moveq	#9,d7
	bra	upd_tab
.1	move.w	d0,d2
	move.w	d1,d3
	lsr.w	#4,d2
	lsr.w	#3,d3
	mul_20	d3,d2
	moveq	#9,d7
; did we hit a mushie from the top
.11	tst.b	(a5,d2.w)	  ; top hit mushie
	bne	upd_tab	  ; yep
	moveq	#8,d7	
	bra	upd_tab	

ce_dl_1	moveq	#10,d7
	bra	upd_tab
	
ce_dl_2	moveq	#11,d7
	bra	upd_tab

ce_dl_3	moveq	#12,d7
	bra	upd_tab

ce_dl_4	addq	#2,d1
	moveq	#13,d7
	bra	upd_tab

ce_dl_5	addq	#2,d1
	cmp.w	#MAX_Y,d1
	ble.s	.1
	move.w	#MAX_Y,d1
.1	moveq	#14,d7
	bra	upd_tab	

ce_dl_6	addq	#2,d1
	cmp.w	#MAX_Y,d1
	ble.s	.1
	move.w	#MAX_Y,d1
.1	moveq	#15,d7
	bra	upd_tab	

ce_dl_7	addq	#2,d1
	cmp.w	#MAX_Y,d1
	ble.s	.1
	move.w	#MAX_Y,d1
.1	moveq	#0,d7
	bra.s	upd_tab	

ce_ul_1	subq	#2,d1
	moveq	#17,d7
	bra.s	upd_tab	
ce_ul_2	subq	#2,d1
	moveq	#18,d7
	bra.s	upd_tab
ce_ul_3	subq	#2,d1
	moveq	#19,d7
	bra.s	upd_tab
ce_ul_4	subq	#2,d1
	cmp.w	#MIN_Y,d1
	bge.s	.1	
	addq	#2,d1
	moveq	#20,d7
	bra.s	upd_tab
.1	moveq	#19,d7
	bra.s	upd_tab
ce_ul_5	moveq	#21,d7
	bra.s	upd_tab
ce_ul_6	moveq	#22,d7
	bra.s	upd_tab
ce_ul_7	moveq	#0,d7
	bra.s	upd_tab
ce_ur_1	subq	#2,d1
.2	moveq	#24,d7
	bra.s	upd_tab
ce_ur_2	subq	#2,d1
	moveq	#25,d7
	bra.s	upd_tab
ce_ur_3	subq	#2,d1
	addq	#2,d0
.2	moveq	#26,d7
	bra.s	upd_tab

ce_ur_4	subq	#2,d1
	cmp.w	#MIN_Y,d1
	bge.s	.1	
	addq	#2,d1
	moveq	#27,d7
	bra.s	upd_tab
.1	moveq	#26,d7
	bra.s	upd_tab

ce_ur_5	subq	#2,d0
	cmp.w	#2,d0
	bge.s	.11
	addq	#2,d0
.11	moveq	#28,d7
	bra.s	upd_tab
ce_ur_6	subq	#2,d0
	cmp.w	#2,d0
	bge.s	.11
	addq	#2,d0
.11	moveq	#29,d7
	bra.s	upd_tab

ce_ur_7	subq	#2,d0
	cmp.w	#2,d0
	bge.s	.11
	addq	#2,d0
.11	moveq	#8,d7
;	bra.s	upd_tab

upd_tab	tst.w	d0
	bpl.s	.2
	moveq	#0,d0
.2	cmp.w	#MAX_X,d0
	ble.s	.3	
	move.w	#MAX_X,d0
.3	cmp.w	#MAX_Y,d1
	ble.s	.4
	move.w	#MAX_Y,d1
.4	move.w	d7,-(a3)	  ; update tables, actual coords
	move.w	d1,-(a3)	  ;
	move.w	d0,-(a3)	  ;
	move.w	d0,(a1)+	  ; 
	move.w	d1,(a1)+    ; stored coords
	move.w	d7,(a1)+	  ;
	cmp.l	d6,a1
	bne.s	.1	
	lea	-(6*9)(a1),a1
.1	move.l	a1,-4(a4)
	rts
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Routine to update centipede body segments ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
update_centi_bodys
	lea	ce_heads,a0	; head table
	lea	pntr_table,a1	; pntrs to tables
	lea	loop_table+4,a2
.loop	move.l	(a0)+,d0		; get a head
	bmi.s	.exit		; end of table
	bne.s	.doit		; has address so update
	addq	#4,a1		; update other regs
	addq	#4,a2
	bra.s	.loop
.doit	move.l	d0,a3		; address of coords
	addq	#6,a3
	move.l	(a3),d0
	bmi.s	.exit
	bne.s	.copy
	addq	#4,a1
	addq	#4,a2
	bra.s	.loop
.copy	move.l	(a2)+,d7
	move.l	(a1)+,a4		; copy from here
	cmp.w	#0,a4
	beq.s	.exit
	move.l	(a1),a5		; copy to here
	cmp.w	#0,a5
	beq.s	.exit
	move.l	(a4),(a5)+	; copy in coords	
	move.w	4(a4),(a5)+	
	cmp.l	d7,a5		; end of table
	bne.s	.1
	lea	-(6*9)(a5),a5	; reset to start
.1	move.l	a5,(a1)		; store it
	move.l	(a4)+,(a3)+	; move coords to table		
	move.w	(a4)+,(a3)+		
	addq	#4,a0		; next head
	move.l	(a3),d0		; are current coords blank
	beq.s	.fix		; yup!
	bmi.s	.exit		; yup!
	bra.s	.copy		; round again
.fix	addq	#4,a0
	addq	#8,a1
	addq	#8,a2
	bra.s	.loop
.exit	rts		
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Routine to update snails ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
update_snail
	lea	sn_table,a3
snail_loop	
	move.l	(a3)+,d1
	cmp.l	#'END!',d1
	beq.s	.2	
	cmp.l	#0,d1
	bne.s	.1
	lea	-4(a3),a4
	addq	#2,a3
	bra.s	snail_loop
.1	move.w	-4(a3),d0
	move.w	(a3)+,d2
	bpl.s	.3
	subq	#SN_SPEED,d0	
	cmp.w	#-16,d0
	bne	add_mushie_4_snail
	moveq	#0,d0
	move.l	d0,-6(a3)
	move.w	d0,-2(a3)
	lea	-6(a3),a4		; this entry free
	addq	#1,snail_tot
	subq	#1,snails_on_screen
	bra.s	snail_loop
.3	addq	#SN_SPEED,d0	
	cmp.w	#318,d0
	bne	add_mushie_4_snail
	moveq	#0,d0
	move.l	d0,-6(a3)
	move.w	d0,-2(a3)
	lea	-6(a3),a4		; this entry free
	addq	#1,snail_tot
	subq	#1,snails_on_screen
	bra.s	snail_loop

.2	move.w	snail_tot,d0
	bmi.s	add_poss_snail
	bne.s	add_poss_snail
	rts

add_poss_snail
	moveq	#0,d0
	move.w	r_val,d0
	add.w	val,d0
	add.b	$ffff8207.w,d0
	move.w	diff,d1
	divu	d1,d0
	add.w	d0,val
	swap	d0
	cmp.w	#1,d0
	bne.s	.1
	moveq	#0,d0
	move.l	y_tab_pos(pc),a0
	move.w	(a0),d0
	tst.w	d_flag
	bpl.s	.2
	move.w	#317,(a4)+
	move.w	d0,(a4)+
	move.w	d_flag,(a4)+	
	subq	#1,snail_tot
	addq	#1,snails_on_screen
.1	rts

.2	move.w	#-14,(a4)+
	move.w	d0,(a4)+
	move.w	d_flag,(a4)+	
	subq	#1,snail_tot
	addq	#1,snails_on_screen
	rts

add_mushie_4_snail

	move.w	d0,-6(a3)	; store x-coord
	move.w	-4(a3),d1
	cmp.w	#0,d0	; off edge of screen?
	blt	snail_loop
; should we plot it
	move.w	r_val,d7
	add.w	val,d7
	add.b	$ffff8207.w,d7
	divu	#11,d7
	add.w	d7,val
	swap	d7
	cmp.w	#1,d7
	bne	snail_loop
;
	lsr.w	#4,d0	; /16
	lsr.w	#3,d1	; /8
	move.w	d1,d2
	lea	mushie_tab,a6
	add.w	d0,a6
	mul_20	d1,a6
	move.w	d2,d1

	move.b	#3,(a6)

	lsl.w	#4,d0	; fix coords
	lsl.w	#3,d1
	add.w	d1,d1
	move.l	screen2(pc),a0	; screen2
	move.l	screen1(pc),a1	; screen1
	lea	mul160(pc),a5	; Add y offset
	add.w	(a5,d1.w),a0	;
	add.w	(a5,d1.w),a1	;
	moveq	#15,d2
	move.w	d0,d1
	and.w	d2,d0
	eor.w	d0,d1
	lsr.w	#1,d1
	add.w	d1,a0
	add.w	d1,a1
	move.l	m_tab+8(pc),a5
	move.l	mb_ptr,a2
	move.l	a1,(a2)+
	move.l	a5,(a2)+
	move.l	a2,mb_ptr
	rept	8
	move.l	(a5)+,(a0)+	; plot mushie
	move.l	(a5)+,(a0)+
	lea	160-8(a0),a0
	endr
	bra	snail_loop
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Routine to update scorpions ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
update_scorp
	lea	sc_table,a3
scorp_loop	
	move.l	(a3)+,d1
	bmi.s	.2	
	bne.s	.1
	lea	-4(a3),a4
	bra.s	scorp_loop
.1	
	addq	#SC_SPEED,d1
	cmp.w	#MIN_Y-32,d1
	blt.s	.11
	addq	#SC_SPEED,d1
.11	cmp.w	#MAX_Y2,d1
	ble.s	add_mushie_4_scorp
	moveq	#0,d0
	move.l	d0,-4(a3)
	lea	-4(a3),a4		; this entry free
	addq	#1,scorp_tot
	subq	#1,scorps_on_screen
.nw	lea	-4(a3),a4
	bra.s	scorp_loop

.2	move.w	scorp_tot,d0
	bmi.s	add_poss_scorp
	bne.s	add_poss_scorp
.v	rts

add_poss_scorp
	moveq	#0,d0
	move.w	r_val,d0
	add.w	val,d0
	add.b	$ffff8207.w,d0
	move.w	diff,d1
	divu	d1,d0
	add.w	d0,val
	swap	d0
	cmp.w	#1,d0
	bne.s	.1
	moveq	#0,d0
	move.l	x_tab_pos(pc),a0
	move.w	(a0),d0
	move.w	d0,(a4)+
	moveq	#9,d0
	move.w	d0,(a4)
	subq	#1,scorp_tot
	addq	#1,scorps_on_screen
.1	rts

add_mushie_4_scorp
	moveq	#0,d7
	move.w	d1,-2(a3)	; store y coord
	move.w	-4(a3),d0	; load x coord
;	bra	scorp_loop
; should we plot one?
	move.w	r_val,d7
	add.w	val,d7
	and.l	#$ffff,d7
	tst.w	wave
	bpl.s	.nw
	divu	#150,d7
	bra.s	.go_on
.nw	divu	#11,d7
.go_on	add.w	d7,val
	swap	d7
	cmp.w	#3,d7
	bne	scorp_loop

	move.w	-4(a3),d0		; load xcoord 

	cmp.w	#MAX_Y-16,d1	; should we plot it
	bge	scorp_loop
	lsr.w	#4,d0		; /16
	lsr.w	#3,d1		' /18
	move.w	d1,d2
	lea	mushie_tab,a6
	add.w	d0,a6
	mul_20	d1,a6
	move.w	d2,d1

	tst.b	(a6)
	bne	scorp_loop

	move.b	#3,(a6)

	lsl.w	#4,d0	; fix coords
	lsl.w	#3,d1
	add.w	d1,d1
	move.l	screen2(pc),a0	; screen2
	move.l	screen1(pc),a1	; screen1
	lea	mul160(pc),a5	; Add y offset
	add.w	(a5,d1.w),a0	;
	add.w	(a5,d1.w),a1	;
	moveq	#15,d2
	move.w	d0,d1
	and.w	d2,d0
	eor.w	d0,d1
	lsr.w	#1,d1
	add.w	d1,a0
	add.w	d1,a1
	move.l	m_tab+8(pc),a5
	move.l	mb_ptr,a2
	move.l	a1,(a2)+
	move.l	a5,(a2)+
	move.l	a2,mb_ptr
	rept	8
	move.l	(a5)+,(a0)+	; plot mushie
	move.l	(a5)+,(a0)+
	lea	160-8(a0),a0
	endr
	bra	scorp_loop
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Routine to update flies ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
update_fly
	lea	fly_table,a3	; table of flies
fly_loop	move.l	(a3)+,d1		; move in coords
	bne.s	.1		; summit there so process it
	lea	-4(a3),a4		; save free space
	addq	#2,a3		; next coords
	bra.s	fly_loop		; looooop!
.1	bmi.s	.end		; yup	
	move.w	-4(a3),d0		; load x coord
	move.w	(a3)+,d2		; load dir
	bpl.s	.right		; go right
.left	subq	#BEE_SPEEDX,d0	; update coords	
	addq	#BEE_SPEEDY,d1	
	cmp.w	#MAX_Y2,d1	; bottom of screen?
	beq.s	.btm		; yup	
	move.w	d0,-6(a3)		; store coords 
	move.w	d1,-4(a3)
	cmp.w	#0,d0
	bgt.s	.lgo
	not.w	-2(a3)

.lgo	bra	add_mushie_4_fly
.right	addq	#FLY_SPEEDX,d0	; update coords	
	addq	#FLY_SPEEDY,d1	
	cmp.w	#MAX_Y2,d1	; bottom of screen?
	beq.s	.btm
	move.w	d0,-6(a3)		; store coords
	move.w	d1,-4(a3)
	cmp.w	#320-16,d0
	blt.s	.rgo
	not.w	-2(a3)
.rgo	bra	add_mushie_4_fly		; loop
.end	move.w	fly_tot,d0	; more flies required?
	bmi.s	add_poss_fly
	bne.s	add_poss_fly
.v	rts			; bugger off
.btm	moveq	#0,d0		; zap entry
	move.l	d0,-6(a3)
	move.w	d0,-2(a3)
	lea	-6(a3),a4		; this entry free
	addq	#1,fly_tot
	subq	#1,flys_on_screen
	bra.s	fly_loop		; loop

add_poss_fly
	moveq	#0,d0
	move.w	r_val,d0
	add.w	val,d0
	add.b	$ffff8207.w,d0
	move.w	diff,d1
	divu	d1,d0
	add.w	d0,val
	swap	d0
	cmp.w	#1,d0
	bne.s	.1
	moveq	#0,d0
	move.l	x_tab_pos(pc),a0
	move.w	(a0),d0
.go_on	tst.w	d_flag
	bpl.s	.2
	move.w	d0,(a4)+
	move.w	#8,(a4)+
	move.w	d_flag,(a4)+	
	subq	#1,fly_tot
	addq	#1,flys_on_screen
.1	rts

.2	move.w	d0,(a4)+
	move.w	#8,(a4)+
	move.w	d_flag,(a4)+	
	subq	#1,fly_tot
	addq	#1,flys_on_screen
	rts

add_mushie_4_fly
	moveq	#0,d7
; should we plot one?
	move.w	r_val,d7
	add.w	val,d7
	and.l	#$ffff,d7

	divu	#11,d7
	add.w	d7,val
	swap	d7
	cmp.w	#3,d7
	bne	fly_loop

	cmp.w	#MAX_Y-16,d1	; should we plot it
	bge	fly_loop
	lsr.w	#4,d0		; /16
	lsr.w	#3,d1		' /18
	lea	mushie_tab,a6
	add.w	d0,a6
	move.w	d1,d2
	mul_20	d1,a6
	move.w	d2,d1
	move.b	(a6),d7
	beq	fly_loop
	subq	#1,d7
	move.b	d7,(a6)

	lsl.w	#4,d0	; fix coords
	lsl.w	#3,d1
	add.w	d1,d1
	move.l	screen2(pc),a0	; screen2
	move.l	screen1(pc),a1	; screen1
	lea	mul160(pc),a5	; Add y offset
	add.w	(a5,d1.w),a0	;
	add.w	(a5,d1.w),a1	;
	moveq	#15,d2
	move.w	d0,d1
	and.w	d2,d0
	eor.w	d0,d1
	lsr.w	#1,d1
	add.w	d1,a0
	add.w	d1,a1
.4	tst.b	d7
	bne.s	.5
	lea	b_mush,a5
	bra.s	.6
.5	subq	#1,d7
	lea	m_tab(pc),a5	; mushie pointers
	lsl.w	#2,d7		; mush_state * 4
	move.l	(a5,d7.w),a5	; load mushie grafix
.6	move.l	mb_ptr,a2
	move.l	a1,(a2)+
	move.l	a5,(a2)+
	move.l	a2,mb_ptr
	rept	8
	move.l	(a5)+,(a0)+	; plot mushie
	move.l	(a5)+,(a0)+
	lea	160-8(a0),a0
	endr

	bra	fly_loop
;
;;;;;;;;;;;;;;;;;;;;;;;;;;
; Routine to update bees ;
;;;;;;;;;;;;;;;;;;;;;;;;;;
;
update_bee
	lea	bee_table,a3	; table of flies
bee_loop	move.l	(a3)+,d1		; move in coords
	bne.s	.1		; summit there so process it
	lea	-4(a3),a4		; save free space
	addq	#4,a3		; next coords
	bra.s	bee_loop		; looooop!
.1	bmi.s	.end		; yup	
	move.w	-4(a3),d0		; load x coord
	move.w	(a3)+,d2		; load dir
	bpl.s	.right		; go right
.left	move.w	(a3)+,d2		; load offset
	subq	#BEE_SPEEDX,d0	; update coords	
	subq	#BEE_SPEEDY,d2	; update coords	
	cmp.w	#-16,d2		; gone far enough?
	bgt.s	.l2		; nop
	not.w	-4(a3)		; swap dir
.l2	addq	#2,d1		; incr y	
	cmp.w	#MAX_Y,d1	; bottom of screen?
	beq.s	.btm		; yup	
	move.w	d0,-8(a3)		; store coords 
	move.w	d1,-6(a3)
	move.w	d2,-2(a3)

	cmp.w	#2,d0
	bgt.s	.lgo
	not.w	-4(a3)

.lgo	bra.s	bee_loop
.right	move.w	(a3)+,d2		; load offset
	addq	#BEE_SPEEDX,d0	; update coords	
	addq	#BEE_SPEEDY,d2	; update coords	
	cmp.w	#16,d2		; enough?
	blt.s	.r2		; no
	not.w	-4(a3)		; swap dir
.r2	addq	#2,d1		; incr y 	
	cmp.w	#MAX_Y,d1	; bottom of screen?
	beq.s	.btm		; yup	
	move.w	d0,-8(a3)		; store coords 
	move.w	d1,-6(a3)
	move.w	d2,-2(a3)

	cmp.w	#312,d0		; edge of screen?
	blt.s	.rgo		; no
	not.w	-4(a3)		; swap dir

.rgo	bra.s	bee_loop
.end	move.w	bee_tot,d0	; more flies required?
	bmi.s	add_poss_bee
	bne.s	add_poss_bee
.v	rts			; bugger off


.btm	moveq	#0,d0		; zap entry
	move.l	d0,-8(a3)
	move.l	d0,-4(a3)
	lea	-8(a3),a4		; this entry free
	addq	#1,bee_tot
	subq	#1,bees_on_screen
	bra	bee_loop		; loop
;
add_poss_bee
	moveq	#0,d0
	move.w	r_val,d0
	add.w	val,d0
	add.b	$ffff8207.w,d0
	move.w	diff,d1
	divu	d1,d0
	add.w	d0,val
	swap	d0
	cmp.w	#1,d0
	bne.s	.1
	moveq	#0,d0
	move.l	x_tab_pos(pc),a0
	move.w	(a0),d0
	cmp.w	#16,d0
	bge.s	.3
	move.w	#16,d0
	bra.s	.2
.3	cmp.w	#319-32,d0
	ble.s	.2
	move.w	#319-32,d0	
.2	move.w	d0,(a4)+
	move.w	#8,(a4)+
	move.w	d_flag,(a4)+
	clr.w	(a4)+	
	subq	#1,bee_tot
	addq	#1,bees_on_screen
.1	rts
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Routine to update spiders ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
update_spider
	lea	sp_table,a0	; load spider table
.1	move.l	(a0)+,d1		; get address
	bmi.s	.4		; minus - exit loop	
	bne.s	.2		; plus - update spider	
	lea	-4(a0),a2		; store blank address
	bra.s	.1		; round again

.2	move.l	d1,a1		; get address of coords
	move.l	(a1),d0		; load x_coord
	cmp.l	#'MIKE',d0
	bne.s	.3		; if +ve go_on
	moveq	#0,d0		; -ve so kill spider 
	move.l	d0,-4(a0)		; blank table entry
	lea	-4(a0),a2		; this entry free
	addq	#1,spider_tot	; add 1 to spiders allowed
	subq	#1,spiders_on_screen
	bra.s	.1		; round again

.3	addq	#4,a1		; load next coords into
	move.l	a1,-4(a0)		; spider table
	bra.s	.1		; round again	

.4	move.w	spider_tot,d0	; can we add more?
	bmi.s	.5		; yep!
	bne.s	.5		; yep!
.v	rts			; exit updating

.5	moveq	#0,d0		;
	move.w	r_val,d0	;
	add.w	val,d0	; generate random number
	add.w	#50,d0
	add.b	$ffff8207.w,d0	;
	move.w	diff,d1
	divu	d1,d0
	add.w	d0,val		;
	swap	d0		;
	cmp.w	#1,d0		; is it 1 
	bne.s	.exit		; no so exit

	move.l	spt_pos(pc),a0	; get a coord table
	move.l	(a0),a0
	addq	#4,a0
	move.l	a0,(a2)		; move to spider table		
	subq	#1,spider_tot	; one less spider available
	addq	#1,spiders_on_screen
.exit	rts

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Routine to update score sprites on screen ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
update_scores
	lea	scr_table,a0
	subq	#4,a0
.1	addq	#4,a0
	move.l	(a0)+,d1
	bmi.s	.exit	
	bne.s	.2
	bra.s	.1
.exit	rts
.2	
	subq	#1,-2(a0)
	bmi.s	.3
	subq	#1,2(a0)
	bpl.s	.1
.3	moveq	#0,d0
	move.l	d0,-4(a0)	
	move.l	d0,(a0)
	bra.s	.1
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Code to plot ship on the screen ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
plot_ship	move.w	x_coord,d0	
	move.w	y_coord,d1	
pshs	move.l	screen2(pc),a0
	add.w	d1,d1		;
	lea	mul160(pc),a1	; Add y offset
	add.w	(a1,d1.w),a0	;
	moveq	#15,d2
	move.w	d0,d1
	and.w	d2,d0
	eor.w	d0,d1
	lsr.w	#1,d1
	add.w	d1,a0
	move.w	d0,a1
	move.l	s_buff_add2,a2
	bsr	save_back8
	lea	128(a2),a2
	move.l	a0,(a2)+
	move.l	a2,s_buff_add2
	addq.w	#1,res_count2
	move.w	a1,d0
	lsl.w	#2,d0
	lea	ship_tab,a1
	move.l	(a1,d0.w),a1
	jmp	(a1)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Code to plot centipede on the screen ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
plot_centi
	move.l	screen2(pc),a0
	add.w	d1,d1		;
	lea	mul160(pc),a1	; Add y offset
	add.w	(a1,d1.w),a0	;
 	moveq	#15,d2
	move.w	d0,d1
	and.w	d2,d0
	eor.w	d0,d1
	lsr.w	#1,d1
	add.w	d1,a0
	move.w	d0,a1

	move.l	s2p_buff_add2,a2
	move.l	d7,-(a7)
	bsr	save_2p_back8
	move.l	(a7)+,d7
	lea	64(a2),a2
	move.l	a0,(a2)+
	move.l	a2,s2p_buff_add2
	addq.w	#1,res2p_count2

	cmp.w	#0,d7
	beq.s	.1
	cmp.w	#8,d7
	beq.s	.1

	lea	(160*8)(a0),a0
	move.l	s2p_buff_add2,a2
	move.l	d7,-(a7)
	bsr	save_2p_back8
	move.l	(a7)+,d7
	lea	64(a2),a2
	move.l	a0,(a2)+
	lea	-(160*8)(a0),a0
	move.l	a2,s2p_buff_add2
	addq.w	#1,res2p_count2
.1	move.w	a1,d0		; Rotation no
	add.w	d0,d0
	cmp.w	#0,d7
	beq.s	.2
	cmp.w	#8,d7
	beq.s	.22
	bra.s	.3
.2	move.l	r_tab_pos(pc),a1
	move.l	(a1),a1
	bra.s	.4
.22	move.l	l_tab_pos(pc),a1
	move.l	(a1),a1
	bra.s	.4

.3	add.w	d7,d7
	add.w	d7,d7
	lea	ce_tab(pc),a1
	move.l	(a1,d7.w),a1
.4	move.l	(a1,d0.w),a1
	jmp	(a1)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Code to plot head on the screen ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
plot_head
	move.l	screen2(pc),a0
	add.w	d1,d1		;
	lea	mul160(pc),a1	; Add y offset
	add.w	(a1,d1.w),a0	;
 	moveq	#15,d2
	move.w	d0,d1
	and.w	d2,d0
	eor.w	d0,d1
	lsr.w	#1,d1
	add.w	d1,a0
	move.w	d0,a1

	move.l	s2p_buff_add2,a2
	move.l	d7,-(a7)
	bsr	save_2p_back8
	move.l	(a7)+,d7
	lea	64(a2),a2
	move.l	a0,(a2)+
	move.l	a2,s2p_buff_add2
	addq.w	#1,res2p_count2

	cmp.w	#0,d7
	beq.s	.1
	cmp.w	#8,d7
	beq.s	.1

	lea	(160*8)(a0),a0
	move.l	s2p_buff_add2,a2
	move.l	d7,-(a7)
	bsr	save_2p_back8
	move.l	(a7)+,d7
	lea	64(a2),a2
	move.l	a0,(a2)+
	lea	-(160*8)(a0),a0
	move.l	a2,s2p_buff_add2
	addq.w	#1,res2p_count2
.1	move.w	a1,d0		; Rotation no
	add.w	d0,d0
	cmp.w	#0,d7
	beq.s	.2
	cmp.w	#8,d7
	beq.s	.22
	bra.s	.3
.2	move.l	hr_tab_pos(pc),a1
	move.l	(a1),a1
	bra.s	.4
.22	move.l	hl_tab_pos(pc),a1
	move.l	(a1),a1
	bra.s	.4

.3	add.w	d7,d7
	add.w	d7,d7
	lea	he_tab(pc),a1
	move.l	(a1,d7.w),a1
.4	move.l	(a1,d0.w),a1
	jmp	(a1)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Code to plot a bullet on the screen ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
plot_bullet
	move.l	screen2(pc),a0
	add.w	d1,d1		;
	lea	mul160(pc),a1	; Add y offset
	add.w	(a1,d1.w),a0	;
 	moveq	#15,d2
	move.w	d0,d1
	and.w	d2,d0
	eor.w	d0,d1
	lsr.w	#1,d1
	add.w	d1,a0
	move.w	d0,a1
	move.l	s_buff_add2,a2
	bsr	save_back8
	lea	128(a2),a2
	move.l	a0,(a2)+
	move.l	a2,s_buff_add2
	addq.w	#1,res_count2
	move.w	a1,d0		; Rotation no
	lsl.w	#2,d0
	lea	bull_tab,a1
	move.l	(a1,d0.w),a1
	jmp	(a1)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Code to plot a snail on the screen ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
plot_snail
	move.l	screen2(pc),a0
	add.w	d1,d1		;
	lea	mul160(pc),a1	; Add y offset
	add.w	(a1,d1.w),a0	;
 	moveq	#15,d2
	move.w	d0,d1
	and.w	d2,d0
	eor.w	d0,d1
	lsr.w	#1,d1
	add.w	d1,a0
	move.w	d0,a1
	move.l	s_buff_add2,a2
	bsr	save_back8
	lea	128(a2),a2
	move.l	a0,(a2)+
	move.l	a2,s_buff_add2
	addq.w	#1,res_count2
	move.w	a1,d7		; Rotation no
	lsl.w	#2,d7
	tst.w	dir
	beq.s	.1
	lea	snail_tab_rc,a1
	move.l	(a1,d7.w),a1
	jsr	(a1)
	addq	#8,a0
	lea	snail_tab_lc,a1
	move.l	(a1,d7.w),a1
	moveq	#0,d0
	jmp	(a1)
.1	lea	snailr_tab_rc,a1
	move.l	(a1,d7.w),a1
	jsr	(a1)
	addq	#8,a0
	lea	snailr_tab_lc,a1
	move.l	(a1,d7.w),a1
	moveq	#0,d0
	jmp	(a1)

plot_snail_lc
	add.w	#16,d0
	move.w	d0,-(a7)
	move.l	screen2(pc),a0
	add.w	d1,d1		;
	lea	mul160(pc),a1	; Add y offset
	add.w	(a1,d1.w),a0	;
	move.l	s_buff_add2,a2
	bsr	save_back8
	lea	128(a2),a2
	move.l	a0,(a2)+
	move.l	a2,s_buff_add2
	addq.w	#1,res_count2
	move.w	(a7)+,d0
	lsl.w	#2,d0
	tst.w	dir
	beq.s	.1
	lea	snail_tab_lc,a1
	move.l	(a1,d0.w),a1
	moveq	#0,d0
	jmp	(a1)
.1	lea	snailr_tab_lc,a1
	move.l	(a1,d0.w),a1
	moveq	#0,d0
	jmp	(a1)

plot_snail_rc
	sub.w	#MAX_X,d0
	move.w	d0,-(a7)
	move.w	#MAX_X-2,d0
	move.l	screen2(pc),a0
	add.w	d1,d1		;
	lea	mul160(pc),a1	; Add y offset
	add.w	(a1,d1.w),a0	;
	lea	152(a0),a0	; X offset
	move.l	s_buff_add2,a2
	bsr	save_back8
	lea	128(a2),a2
	move.l	a0,(a2)+
	move.l	a2,s_buff_add2
	addq.w	#1,res_count2
	move.w	(a7)+,d0
	lsl.w	#2,d0
	tst.w	dir
	beq.s	.1
	lea	snail_tab_rc,a1
	move.l	(a1,d0.w),a1
	moveq	#0,d0
	jmp	(a1)
.1	lea	snailr_tab_rc,a1
	move.l	(a1,d0.w),a1
	moveq	#0,d0
	jmp	(a1)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Code to plot a spider on the screen ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
plot_spider
	move.l	screen2(pc),a0
	add.w	d1,d1		;
	lea	mul160(pc),a1	; Add y offset
	add.w	(a1,d1.w),a0	;
 	moveq	#15,d2
	move.w	d0,d1
	and.w	d2,d0
	eor.w	d0,d1
	lsr.w	#1,d1
	add.w	d1,a0
	move.w	d0,a1
	move.l	s_buff_add2,a2
	bsr	save_back8
	lea	128(a2),a2
	move.l	a0,(a2)+
	move.l	a2,s_buff_add2
	lea	160*8(a0),a0
	bsr	save_back8
	lea	128(a2),a2
	move.l	a0,(a2)+
	move.l	a2,s_buff_add2
	lea	-(160*8)(a0),a0
	addq.w	#2,res_count2
	move.w	a1,d0		; Rotation no
	add.w	d0,d0
	lea	spider1_tab_rc,a1
	move.l	scorp_a_pos(pc),a2
	move.w	(a2),d7
	add.w	d7,d0
	move.w	d0,d7
	move.l	(a1,d7.w),a1
	moveq	#0,d0
	jsr	(a1)
	addq	#8,a0
	lea	spider1_tab_lc,a1
	move.l	(a1,d7.w),a1
	moveq	#0,d0
	jmp	(a1)
plot_spider_lc
	add.w	#16,d0
	move.w	d0,-(a7)
	move.l	screen2(pc),a0
	add.w	d1,d1		;
	lea	mul160(pc),a1	; Add y offset
	add.w	(a1,d1.w),a0	;
	move.l	s_buff_add2,a2
	bsr	save_back8
	lea	128(a2),a2
	move.l	a0,(a2)+
	move.l	a2,s_buff_add2
	lea	160*8(a0),a0
	bsr	save_back8
	lea	128(a2),a2
	move.l	a0,(a2)+
	move.l	a2,s_buff_add2
	lea	-(160*8)(a0),a0
	addq.w	#2,res_count2
	move.w	(a7)+,d0
	add.w	d0,d0
	lea	spider1_tab_lc,a1
	move.l	scorp_a_pos(pc),a2
	move.w	(a2),d7
	add.w	d7,d0
	move.l	(a1,d0.w),a1
	moveq	#0,d0
	jmp	(a1)
plot_spider_rc
	sub.w	#MAX_X,d0
	move.w	d0,-(a7)
	move	#MAX_X-2,d0
	move.l	screen2(pc),a0
	add.w	d1,d1		;
	lea	mul160(pc),a1	; Add y offset
	add.w	(a1,d1.w),a0	;
	lea	152(a0),a0	; X offset
	move.l	s_buff_add2,a2
	bsr	save_back8
	lea	128(a2),a2
	move.l	a0,(a2)+
	move.l	a2,s_buff_add2
	lea	160*8(a0),a0
	bsr	save_back8
	lea	128(a2),a2
	move.l	a0,(a2)+
	move.l	a2,s_buff_add2
	lea	-(160*8)(a0),a0
	addq.w	#2,res_count2
	move.w	(a7)+,d0
	add.w	d0,d0
	lea	spider1_tab_rc,a1
	move.l	scorp_a_pos(pc),a2
	move.w	(a2),d7
	add.w	d7,d0
	move.l	(a1,d0.w),a1
	moveq	#0,d0
	jmp	(a1)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Code to plot a fly on the screen ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
plot_fly	move.l	screen2(pc),a0
	add.w	d1,d1		;
	lea	mul160(pc),a1	; Add y offset
	add.w	(a1,d1.w),a0	;
 	moveq	#15,d2
	move.w	d0,d1
	and.w	d2,d0
	eor.w	d0,d1
	lsr.w	#1,d1
	add.w	d1,a0
	move.w	d0,a1
	move.l	s_buff_add2,a2
	bsr	save_back8
	lea	128(a2),a2
	move.l	a0,(a2)+
	move.l	a2,s_buff_add2
	lea	160*8(a0),a0
	bsr	save_back8
	lea	128(a2),a2
	move.l	a0,(a2)+
	move.l	a2,s_buff_add2
	lea	-(160*8)(a0),a0
	addq.w	#2,res_count2
	move.w	a1,d0		; Rotation no
	add.w	d0,d0
	tst.w	dir
	beq.s	.1
	lea	fly2l_tab,a1
	move.l	fly_a_pos(pc),a2
	move.w	(a2),d7
	add.w	d7,d0
	move.w	d0,d7
	move.l	(a1,d7.w),a1
	moveq	#0,d0
	jmp	(a1)
.1	lea	fly2_tab,a1
	move.l	fly_a_pos(pc),a2
	move.w	(a2),d7
	add.w	d7,d0
	move.w	d0,d7
	move.l	(a1,d7.w),a1
	moveq	#0,d0
	jmp	(a1)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Code to plot a bee on the screen ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;

plot_bee	move.l	screen2(pc),a0
	add.w	d1,d1		;
	lea	mul160(pc),a1	; Add y offset
	add.w	(a1,d1.w),a0	;
	moveq	#15,d2
	move.w	d0,d1
	and.w	d2,d0
	eor.w	d0,d1
	lsr.w	#1,d1
	add.w	d1,a0
	move.w	d0,a1
	move.l	s_buff_add2,a2
	bsr	save_back8
	lea	128(a2),a2
	move.l	a0,(a2)+
	move.l	a2,s_buff_add2
	addq.w	#1,res_count2
	move.w	a1,d0
	add.w	d0,d0
	lea	bee1_tab,a1
	move.l	bee_a_pos(pc),a2
	move.w	(a2),d7
	add.w	d7,d0
	move.w	d0,d7
	move.l	(a1,d7.w),a1
	moveq	#0,d0
	jmp	(a1)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Code to plot a scorpion on the screen ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
plot_scorp
	move.l	screen2(pc),a0
	add.w	d1,d1		;
	lea	mul160(pc),a1	; Add y offset
	add.w	(a1,d1.w),a0	;
 	moveq	#15,d2
	move.w	d0,d1
	and.w	d2,d0
	eor.w	d0,d1
	lsr.w	#1,d1
	add.w	d1,a0
	move.l	s_buff_add2,a2
	bsr	save_back8
	lea	128(a2),a2
	move.l	a0,(a2)+
	move.l	a2,s_buff_add2
	lea	160*8(a0),a0
	bsr	save_back8
	lea	128(a2),a2
	move.l	a0,(a2)+
	move.l	a2,s_buff_add2
	lea	-(160*8)(a0),a0
	addq.w	#2,res_count2
	lea	scorp1_tab,a1
	move.l	scorp_a_pos(pc),a2
	move.w	(a2),d7
	beq.s	.1
	moveq	#4,d7
.1	move.l	(a1,d7.w),a1
	jmp	(a1)
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Code to plot a score on the screen ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
plot_score
	and.b	#%11110000,d0
	move.l	screen2(pc),a0
	add.w	d1,d1		;
	lea	mul160(pc),a1	; Add y offset
	add.w	(a1,d1.w),a0	;
 	moveq	#15,d3
	move.w	d0,d1
	and.w	d3,d0
	eor.w	d0,d1
	lsr.w	#1,d1
	add.w	d1,a0
	move.w	d2,-(a7)
	move.l	s_buff_add2,a2
	bsr	save_back8
	lea	128(a2),a2
	addq.w	#1,res_count2
	move.l	a0,(a2)+
	move.l	a2,s_buff_add2
	move.w	(a7)+,d2		; score no *64
	lea	sc_100_tab,a1
	move.l	(a1,d2.w),a1
	jmp	(a1)

;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Routine to plot scores onto screen ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
plot_scores
	movem.l	a0-4/d0-7,-(a7)
	move.l	screen1(pc),a0
	move.l	screen2(pc),a4
	lea	48+4(a0),a0
	lea	48+4(a4),a4
	lea	score,a1
	moveq	#0,d0
	lea	numbers,a3
x	set	0
	rept	8		
	move.b	(a1)+,d0
	ext.w	d0
	lsl.w	#4,d0
	lea	(a3,d0.w),a2
	movem.w	(a2),d0-7
	move.w	d1,x+0(a0)	
	move.w	d1,x+0(a4)	
	move.w	d2,x+160(a0)	
	move.w	d2,x+160(a4)	
	move.w	d3,x+320(a0)	
	move.w	d3,x+320(a4)	
	move.w	d4,x+480(a0)	
	move.w	d4,x+480(a4)	
	move.w	d5,x+640(a0)	
	move.w	d5,x+640(a4)	
	move.w	d6,x+800(a0)	
	move.w	d6,x+800(a4)	
	move.w	d7,x+960(a0)
	move.w	d7,x+960(a4)
x	set	x+8
	endr
	movem.l	(a7)+,a0-4/d0-7
	rts

plot_lives
	movem.l	a0-4/d0-7,-(a7)
	move.l	screen1(pc),a0
	move.l	screen2(pc),a4
	lea	160-16+4(a0),a0
	lea	160-16+4(a4),a4
	moveq	#0,d0
	lea	numbers,a3
	lea	lives,a1
	moveq	#0,d0
	move.w	(a1),d0
	divu	#10,d0
	lsl.w	#4,d0
	lea	(a3,d0.w),a2
	movem.w	(a2),d0-7
	move.w	d1,(a0)	
	move.w	d1,(a4)	
	move.w	d2,160(a0)	
	move.w	d2,160(a4)	
	move.w	d3,320(a0)	
	move.w	d3,320(a4)	
	move.w	d4,480(a0)	
	move.w	d4,480(a4)	
	move.w	d5,640(a0)	
	move.w	d5,640(a4)	
	move.w	d6,800(a0)	
	move.w	d6,800(a4)	
	move.w	d7,960(a0)
	move.w	d7,960(a4)
	move.w	(a1),d0
	divu	#10,d0
	swap	d0
	lsl.w	#4,d0
	lea	(a3,d0.w),a2
	movem.w	(a2),d0-7
	move.w	d1,8+0(a0)	
	move.w	d1,8+0(a4)	
	move.w	d2,8+160(a0)	
	move.w	d2,8+160(a4)	
	move.w	d3,8+320(a0)	
	move.w	d3,8+320(a4)	
	move.w	d4,8+480(a0)	
	move.w	d4,8+480(a4)	
	move.w	d5,8+640(a0)	
	move.w	d5,8+640(a4)	
	move.w	d6,8+800(a0)	
	move.w	d6,8+800(a4)	
	move.w	d7,8+960(a0)
	move.w	d7,8+960(a4)
	movem.l	(a7)+,a0-4/d0-7
	rts
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Route to add points to score ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
add_points
.1	move.b	(a0),d1
	add.b	d2,d1
.2	cmp.b	#$a,d1
	blt.s	.done
	move.b	#0,(a0)
	sub.b	#$a,d1
	move.b	d1,(a0)
	subq.w	#1,a0
	moveq	#1,d2
	bra.s	.1	
.done	move.b	d1,(a0)
	move.b	score+3,d1
	move.w	nxt_life,d2
	cmp.b	d2,d1
	bne.s	.bye	
	move.l	#extratone,extra_tone
	move.l	#extravol,extra_vol
	move.l	#mushend,mush_vol
	subq	#2,lives
	addq	#3,lives
	bsr	plot_lives
	addq.w	#2,nxt_life
	cmp.w	#10,nxt_life
	bne.s	.bye
	clr.w	nxt_life
.bye	rts
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Code to handle a live being lost ; 
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
live_gone	sf	live_lost
	tst.w	demo_mode
	bne.s	.ns
	move.l	#dievol,die_vol
	move.l	#dietone,die_tone
	move.l	#firend,fire_vol
.ns	bsr	ksync
	clr.b	chip_val
	move.l	#hbl,$118.w
	moveq	#20,d7
.flash	move.w	#$700,btm+2
	move.w	#$777,top+2
	bsr	vsync
	move.w	#$020,btm+2
	move.w	#$010,top+2
	bsr	vsync
	dbf	d7,.flash
	bsr	flip_buffers
	bsr	restore_4p
	bsr	restore_2p
	bsr	add_mushies
	bsr	flip_buffers
	bsr	restore_4p
	bsr	restore_2p

	bsr	flush_buffers	
	moveq	#0,d1
	bsr	kill_beasties
	tst.w	demo_mode
	bne	wloop
	tst.w	lives
	beq	dead
;	bsr	zoom_out
kill_bullets
	moveq	#-1,d0
	move.w	d0,bx_coord
	move.w	d0,by_coord
	bsr	plot_screen
	bsr	update_mushies
	
	move.w	cd_flag,curr_cd
	move.l	curr_wave,a5
	tst.w	wave
	beq.s	.nw
	lea	16(a5),a5
	cmp.l	#end_waves,a5
	bne.s	.ne
	lea	loop_waves,a5
.ne
.nw	move.l	a5,curr_wave
	move.w	(a5),ce_cnt
	move.w	#8,ce_cntr
	move.w	(a5),c2kill
	move.w	(a5)+,c4level
	move.w	(a5)+,spider_tot
	move.w	(a5)+,scorp_tot
	move.w	(a5)+,snail_tot
	move.w	(a5)+,fly_tot
	move.w	(a5)+,bee_tot
	move.w	(a5)+,wave
	move.w	(a5)+,diff
	move.w	#0,timer	
	move.w	scorps_on_screen,d0
	sub.w	d0,scorp_tot
	move.w	spiders_on_screen,d0
	sub.w	d0,spider_tot
	move.w	bees_on_screen,d0
	sub.w	d0,bee_tot
	move.w	flys_on_screen,d0
	sub.w	d0,fly_tot
	move.w	snails_on_screen,d0
	sub.w	d0,snail_tot

	move.w	#X_START,x_coord
	move.w	#Y_START,y_coord
	bsr	set_up_score_gfx
	bsr	plot_scores
	bsr	plot_lives
	bsr	vsync
	bsr	vsync
	bsr	vsync
	bsr	vsync
	bsr	vsync
	bsr	ksync
	move.l	#game_key2,$118.w
	bra	return
kill_beasties
	move.w	d1,scorps_on_screen
	move.w	d1,spiders_on_screen
	move.w	d1,bees_on_screen
	move.w	d1,flys_on_screen
	move.w	d1,snails_on_screen

kill_spiders
	lea	sp_table,a0
.1	move.l	(a0),d0
	bmi.s	kill_snails
	move.l	d1,(a0)+
	bra.s	.1
kill_snails
	lea	sn_table,a0
.1	move.l	(a0),d0
	cmp.l	#'END!',d0
	beq.s	kill_fly
	move.w	d1,(a0)+
	bra.s	.1
kill_fly
	lea	fly_table,a0
.1	move.l	(a0),d0
	bmi.s	kill_bee
	move.l	d1,(a0)+
	move.w	d1,(a0)+
	bra.s	.1

kill_bee
	lea	bee_table,a0
.1	move.l	(a0),d0
	bmi.s	kill_scorpions
	move.l	d1,(a0)+
	move.l	d1,(a0)+
	bra.s	.1

kill_scorpions
	lea	sc_table,a0
.1	move.l	(a0),d0
	bmi.s	kill_scores
	move.l	d1,(a0)+
	bra.s	.1
kill_scores
	lea	scr_table,a0
.1	move.l	(a0),d0
	bmi.s	.2
	move.l	d1,(a0)+
	bra.s	.1	
.2	bsr.s	kill_centis
	rts
kill_centis
	lea	ce_table,a0
	moveq	#47,d0
	moveq	#-1,d2
.1	move.w	d2,(a0)+
	dbf	d0,.1
	lea	table1,a0
	lea	endt,a1
	moveq	#0,d0
.2	move.w	d0,(a0)+
	cmp.l	a0,a1
	bne.s	.2
	move.l	#ce_table,ce_t_pos
	lea	ce_heads,a0
	moveq	#14,d0
.3	move.l	d1,(a0)+
	dbf	d0,.3	
	lea	pntr_table,a0
	lea	table1,a1
	moveq	#15,d0
.4	move.l	a1,(a0)+
	lea	54(a1),a1
	dbf	d0,.4
	rts
plot_game_text
.again	moveq	#0,d2
	move.l	d2,d0
	move.l	d2,d1
	move.l	d2,d3
	move.b	(a4)+,d2
	beq.s	.goodbye
	bmi	.codes

	move.w	curr_x,d0	; move current coords
	move.w	curr_y,d1	; into reggies
	addq.w	#1,d0		; update

	cmp.w	#40,d0		; end of line ?
	blt.s	.6		; no
	moveq	#0,d0		; set to begining
	cmp.w	#23,d1		; end of page
	bgt.s	.6		; no
	addq	#1,d1		; advance one line

.6	move.w	d0,curr_x	; store coords
	move.w	d1,curr_y	;
	
	bsr.s	.do_char
	bra.s	.again			

.goodbye	rts

;
; print char d2 at location d0,d1
;

.do_char	lsl.w	#4,d1
	lea	mul160(pc),a2
	move.l	screen1(pc),a1
	add.w	(a2,d1.w),a1	; y offset
	moveq	#0,d1
	move.w	d0,d1
	divu	#2,d1
	swap	d1
	add.w	d1,a1
	sub.w	d1,d0
	lsl.w	#2,d0
	add.w	d0,a1

	lea	font8,a0	; get correct char
	sub.b	#$20,d2
	add.w	d2,d2
	add.w	d2,d2
	add.w	d2,d2
	lea	(a0,d2),a0	;

x	set	0	
y	set	0	
	rept	8	
	move.b	y(a0),d3
	not.b	d3
	and.b	d3,x(a1)	
	and.b	d3,x+2(a1)	
	and.b	d3,x+4(a1)	
	and.b	d3,x+6(a1)	
	not.b	d3
	or.b	d3,x(a1)	
	or.b	d3,x+2(a1)	
	or.b	d3,x+4(a1)	
	or.b	d3,x+6(a1)	
x	set	x+160	
y	set	y+1	
	endr		
	bsr	vsync
	bsr	vsync
	bsr	vsync
	bsr	vsync
	bsr	vsync
	bsr	vsync
.exit	rts

.codes	cmp.b	#$fd,d2		; set cursor to x,y
	bne	.again		;
	move.b	(a4)+,curr_x+1	;
	move.b	(a4)+,curr_y+1	;
	bra	.again

generate_game_sprites
	lea	sp_buff,a1
	build_spr	cel2,8,2,not_masked
	build_spr	cel3,8,2,not_masked
	build_spr	cer2,8,2,not_masked
	build_spr	cer3,8,2,not_masked
	build_spr	ceup,16,2,not_masked
	build_spr	cedwn,16,2,not_masked
	build_spr	cedr1,16,2,not_masked
	build_spr	cedr2,16,2,not_masked
	build_spr	cedr3,16,2,not_masked
	build_spr	cedr5,16,2,not_masked
	build_spr	cedr6,16,2,not_masked
	build_spr	cedr7,16,2,not_masked
	build_spr	cedl1,16,2,not_masked
	build_spr	cedl2,16,2,not_masked
	build_spr	cedl3,16,2,not_masked
	build_spr	cedl5,16,2,not_masked
	build_spr	cedl6,16,2,not_masked
	build_spr	cedl7,16,2,not_masked
	build_spr	ceur1,16,2,not_masked
	build_spr	ceur2,16,2,not_masked
	build_spr	ceur3,16,2,not_masked
	build_spr	ceur5,16,2,not_masked
	build_spr	ceur6,16,2,not_masked
	build_spr	ceur7,16,2,not_masked
	build_spr	ceul1,16,2,not_masked
	build_spr	ceul2,16,2,not_masked
	build_spr	ceul3,16,2,not_masked
	build_spr	ceul5,16,2,not_masked
	build_spr	ceul6,16,2,not_masked
	build_spr	ceul7,16,2,not_masked
	build_spr	hel2,8,2,not_masked
	build_spr	hel3,8,2,not_masked
	build_spr	her2,8,2,not_masked
	build_spr	her3,8,2,not_masked
	build_spr	heup,16,2,not_masked
	build_spr	hedwn,16,2,not_masked
	build_spr	hedr1,16,2,not_masked
	build_spr	hedr2,16,2,not_masked
	build_spr	hedr3,16,2,not_masked
	build_spr	hedr5,16,2,not_masked
	build_spr	hedr6,16,2,not_masked
	build_spr	hedr7,16,2,not_masked
	build_spr	hedl1,16,2,not_masked
	build_spr	hedl2,16,2,not_masked
	build_spr	hedl3,16,2,not_masked
	build_spr	hedl5,16,2,not_masked
	build_spr	hedl6,16,2,not_masked
	build_spr	hedl7,16,2,not_masked
	build_spr	heur1,16,2,not_masked
	build_spr	heur2,16,2,not_masked
	build_spr	heur3,16,2,not_masked
	build_spr	heur5,16,2,not_masked
	build_spr	heur6,16,2,not_masked
	build_spr	heur7,16,2,not_masked
	build_spr	heul1,16,2,not_masked
	build_spr	heul2,16,2,not_masked
	build_spr	heul3,16,2,not_masked
	build_spr	heul5,16,2,not_masked
	build_spr	heul6,16,2,not_masked
	build_spr	heul7,16,2,not_masked
	build_spr	ship,8,1,masked
	build_spr	bull,6,1,not_masked
	build_spr	scorp1,13,16,masked
	build_spr	scorp2,13,16,masked
	build_spr	snail,8,1,masked,lclip
	build_spr	snail,8,1,masked,rclip
	build_spr	snailr,8,1,masked,lclip
	build_spr	snailr,8,1,masked,rclip
	build_spr	bee1,8,2,masked
	build_spr	bee2,8,2,masked
	build_spr	fly2,16,2,masked
	build_spr	fly3,16,2,masked
	build_spr	fly2l,16,2,masked
	build_spr	fly3l,16,2,masked
	build_spr	spider1,13,2,masked,lclip
	build_spr	spider1,13,2,masked,rclip
	build_spr	spider2,13,2,masked,lclip
	build_spr	spider2,13,2,masked,rclip
	build_spr	sc_100,6,16,not_masked
	build_spr	sc_500,6,16,not_masked
	build_spr	sc_1000,6,16,not_masked
	rts

; plot 'score' & 'ships' in bottom border

set_up_score_gfx
	lea	s_text,a0
	move.l	screen1(pc),a1
	move.l	screen2(pc),a2
	addq	#4,a1
	addq	#4,a2
	moveq	#6,d0
.2	moveq	#4,d1
.1	move.w	(a0),(a1)
	move.w	(a0)+,(a2)
	addq	#8,a1
	addq	#8,a2
	dbf	d1,.1
	lea	120(a1),a1
	lea	120(a2),a2
	dbf	d0,.2	
	move.l	screen1(pc),a0
	lea	160-24(a0),a0
	move.l	ship_tab,a1
	jsr	(a1)	
	move.l	screen2(pc),a0
	lea	160-24(a0),a0
	move.l	ship_tab,a1	
	jsr	(a1)	
	rts
plot_demo
	lea	demo,a0	; load gfx
	move.l	screen1(pc),a1	; put on both screens
	move.l	screen2(pc),a2	;
	lea	64+4(a1),a1	; plot here
	lea	64+4(a2),a2	;
	moveq	#7,d0	; 8 scanlines
.2	moveq	#3,d1	; 4 words per line
.1	move.w	(a0),(a1)		; onto screen1
	move.w	(a0)+,(a2)	; onto screen2
	addq	#8,a1	; next plane
	addq	#8,a2	; next plane
	dbf	d1,.1
	lea	128(a1),a1	; next scanline
	lea	128(a2),a2	; next scanline
	dbf	d0,.2	
	rts
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set up initial random mushies ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
set_map	lea	mushie_tab,a6
	move.l	#(MAX_VAL1*MAX_VAL2)-1,d0
	moveq	#0,d1
.zap	move.b	d1,(a6)+		; clear map
	dbf	d0,.zap
	move.w	#init-1,d2	; Initial mushie count
	lea	$ffff8209.w,a0
	lea	$ffff8207.w,a1
	move.w	#5,tries
.1	bsr.s	rand
	cmp.w	#1,d1		; dont want mushies on top line
	blt.s	.1
;	and.b	#%11110000,d0
;	and.b	#%11111000,d1

	lea	mushie_tab,a6	; store here
	add.w	d0,a6	; 
	mulu	#20,d1	; offset into table
	add.w	d1,a6	;

	tst.b	(a6)
	beq.s	.2
	subq	#1,tries
	bne.s	.1

.2	move.w	tries,d7
	add.w	d7,val
	move.w	#5,tries
	move.b	#3,(a6)

	dbf	d2,.1
	rts
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Set up initial seed for random number generator ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
set_seed	lea	$ffff8209.w,a0
	lea	$ffff8207.w,a1
	move.b	(a0),d7
	lsl.b	#8,d7
	move.b	(a1),d7
	mulu	#19,d7
	move.w	d7,val
	rts
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Return random numbers in d0 and d1 ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
rand	move.w	val,d7	
	move.w	val,d6
	add.w	r_val,d7

	muls	#3,d6	
	
	add.b	(a1),d7		
	add.b	(a0),d7		 
	add.b	-2(a1),d6		 
	mulu	d6,d7
	move.w	d7,d0
	mulu	#13,d0
	move.w	d0,val		;
	and.l	#%1111111111111111,d0
	divu	#MAX_VAL1,d0	; Divide by max value		
	swap	d0		; and get remainder
	cmp.w	#MAX_VAL1,d0
	bge.s	rand

	add.b	(a1),d7		
	add.b	(a0),d7		 
	add.b	-2(a1),d6		 
	
	lsl.b	d6,d7			
	add.b	(a1),d7		
	move.w	d7,d1
	mulu	#11,d1
	and.l	#%1111111111111111,d1
	divu.w	#MAX_VAL2-1,d1	; Divide by max value		
	swap	d1		; and get remainder
	rts
;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
; Plot initial random mushies ;
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;
;
plot_screen
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	screen1(pc),a2
	move.l	screen2(pc),a3
	lea	mushie_tab,a6	; from here
	moveq	#0,d6		; curr x
	move.l	d6,d7		; curr y
	moveq	#24,d2		; no of rows -1 
.loop2	move	#19,d1		; no of cols -1
.loop1	move.b	(a6)+,d0		; get data	
	cmp.b	#3,d0		; not 3 so loop round
	bne.s	.2
	move.w	d6,d3		; move coords for calcs	
	move.w	d7,d4		;
	add.w	d4,d4		;
	move.l	a2,a0		; screen
	move.l	a3,a1		; screen
	lea	mul160(pc),a4	; Add y offset
	add.w	(a4,d4.w),a0	;
	add.w	(a4,d4.w),a1	;

	move.w	d3,d4	;
	and.w	#15,d3	;
	eor.w	d3,d4	;
	lsr.w	#1,d4	; calc x offset
	add.w	d4,a0	;
	add.w	d4,a1	;

	move.l	m_tab+8(pc),a4	; table of mushie roots

	bsr	pm

.2	add.w	#16,d6	; next x coord
	dbf	d1,.loop1
	addq	#8,d7	; next y coord
	moveq	#0,d6	; reset x
	dbf	d2,.loop2
	rts
;
;;;;;;;;;;;;;;;;;;
; update mushies ;
;;;;;;;;;;;;;;;;;;
;
update_mushies
	moveq	#0,d0
	move.l	d0,d1
	move.l	d0,d2
	move.l	screen1(pc),a2
	move.l	screen2(pc),a3
	lea	mushie_tab,a6	; from here
	moveq	#0,d6		; curr x
	move.l	d6,d7		; curr y
	moveq	#24,d2		; no of rows -1 
.loop2	move	#19,d1		; no of cols -1
.loop1	move.b	(a6)+,d0		; get data	
	beq.s	.2
	cmp.b	#3,d0
	beq.s	.2
	move.b	#3,-1(a6)
	move.w	d6,d3		; move coords for calcs	
	move.w	d7,d4		;
	add.w	d4,d4		;
	move.l	a2,a0		; screen
	move.l	a3,a1		; screen
	lea	mul160(pc),a4	; Add y offset
	add.w	(a4,d4.w),a0	;
	add.w	(a4,d4.w),a1	;

	move.w	d3,d4	;
	and.w	#15,d3	;
	eor.w	d3,d4	;
	lsr.w	#1,d4	; calc x offset
	add.w	d4,a0	;
	add.w	d4,a1	;

	lea	grey3,a4
	moveq	#1,d3
.fade_in	movem.l	a0-1,-(a7)
	bsr.s	pm
	bsr	vsync
	movem.l	(a7)+,a0-1
	dbf	d3,.fade_in
		
	move.l	m_tab+8(pc),a4	; table of mushie roots

	bsr.s	pm

.2	add.w	#16,d6	; next x coord
	dbf	d1,.loop1
	addq	#8,d7	; next y coord
	moveq	#0,d6	; reset x
	dbf	d2,.loop2
	rts

pm	moveq	#7,d5
.1	move.l	(a4),(a0)+	; plot mushie
	move.l	(a4)+,(a1)+	; plot mushie
	move.l	(a4),(a0)+
	move.l	(a4)+,(a1)+	; plot mushie
	lea	160-8(a0),a0
	lea	160-8(a1),a1
	dbf	d5,.1
	rts
	section	data
filename	dc.b	'centi.hi',0
game_pal	dc.w	$000,$467,$246,$024,$222,$700,$060,$770
	dc.w	$333,$400,$030,$740,$555,$310,$421,$777
	dc.w	$010,$020
int_pal	dc.w	$211,$321,$431,$541,$652,$763,$774,$707
pal	dc.w	$211,$321,$431,$541,$652,$763,$774,$707
mul160	incbin	d:\centiped.e\mul.160 ; Table to multiply by 160
x_tab_pos	dc.l	x_tab	; pointer to x tab
y_tab_pos	dc.l	y_tab	; pointer to y tab
spt_pos	dc.l	sp_tab	; pointer to table below 

; pointers for animation

r_tab_pos	dc.l	centi_anim_r
l_tab_pos	dc.l	centi_anim_l
hr_tab_pos	dc.l	head_anim_r
hl_tab_pos	dc.l	head_anim_l
scorp_a_pos	dc.l	scorp_anim
bee_a_pos	dc.l	bee_anim
fly_a_pos	dc.l	fly_anim

col_ptr1	dc.l	col_tab	; line one pointer
col_ptr2	dc.l	col_tab2	; line two pointer
pos	dc.l	rasters	; more colour pointers
pos2	dc.l	rasters	; more colour pointers
cval	dc.l	sick	; pointer to current scancode
counter	dc.b	22
	even
cp	dc.l	col_tab	; pointer as below not temp though	
c_ptr	dc.l	col_tab	; temp pointer to colour table for rasters
txt_ptr	dc.l	int_text	; pointer to intro text (8*8)
1
; pointers to screens set up in set up surprsingly enough

screen1	dc.l	free_ram+254
screen2	dc.l	0

; scancodes of keys for cheat mode

sick	dc.b	$21,$16,$2E,$25,$39,$15,$18,$16
	dc.b	$39,$1E,$1F,$1F,$23,$18,$26,$12
esick	ds.b	1
	even

; game over and abort text

game_over	dc.b	$fd,15,10,'GAME OVER',$ff
	dc.b	$fd,11,12,'PLEASE TRY AGAIN!',0
aborted	dc.b	$fd,14,10,'GAME ABORTED',$ff
	even

; table of pointers to spider table

sp_tab	dc.l	sp_crds2,sp_crds3,sp_crds3,sp_crds8	
	dc.l	sp_crds1,sp_crds6,sp_crds7,sp_crds8	
	dc.l	sp_crds8,sp_crds9,sp_crds10
	dc.l	sp_crds4,sp_crds5,sp_crds6,sp_crds5	
	dc.l	sp_crds4,sp_crds1,sp_crds2,sp_crds7	
	dc.l	sp_crds8,sp_crds9,sp_crds10
e_sp_tab

; table to determine which route we will update centi with 

ce_dirs	dc.l	ce_right,ce_dr_1,ce_dr_2,ce_dr_3
	dc.l	ce_dr_4,ce_dr_5,ce_dr_6,ce_dr_7
	dc.l	ce_left,ce_dl_1,ce_dl_2,ce_dl_3
	dc.l	ce_dl_4,ce_dl_5,ce_dl_6,ce_dl_7
	dc.l	ce_ul_1,ce_ul_2,ce_ul_3,ce_ul_4
	dc.l	ce_ul_5,ce_ul_6,ce_ul_7
	dc.l	ce_ur_1,ce_ur_2,ce_ur_3,ce_ur_4
	dc.l	ce_ur_5,ce_ur_6,ce_ur_7

; Table to determine which graphic is plotted for each centi dir

ce_tab	dc.l	cer2_tab,cedr1_tab,cedr2_tab,cedr3_tab
	dc.l	cedwn_tab,cedr5_tab,cedr6_tab,cedr7_tab
	dc.l	cel2_tab,cedl1_tab,cedl2_tab,cedl3_tab
	dc.l	cedwn_tab,cedl5_tab,cedl6_tab,cedl7_tab
	dc.l	ceul1_tab,ceul2_tab,ceul3_tab,ceup_tab
	dc.l	ceul5_tab,ceul6_tab,ceul7_tab,ceur1_tab
	dc.l	ceur2_tab,ceur3_tab,ceup_tab,ceur5_tab
	dc.l	ceur6_tab,ceur7_tab,ceup_tab,ceup_tab

; Table to determine which graphic is plotted for each head dir

he_tab	dc.l	her2_tab,hedr1_tab,hedr2_tab,hedr3_tab
	dc.l	hedwn_tab,hedr5_tab,hedr6_tab,hedr7_tab
	dc.l	hel2_tab,hedl1_tab,hedl2_tab,hedl3_tab
	dc.l	hedwn_tab,hedl5_tab,hedl6_tab,hedl7_tab
	dc.l	heul1_tab,heul2_tab,heul3_tab,heup_tab
	dc.l	heul5_tab,heul6_tab,heul7_tab,heur1_tab
	dc.l	heur2_tab,heur3_tab,heup_tab,heur5_tab
	dc.l	heur6_tab,heur7_tab,heup_tab,heup_tab

; dimensions of centi for each animation 

ce_dimns	dc.w	15,07,14,10,12,12,10,14
	dc.w	07,15,10,14,12,12,14,10
	dc.w	15,07,14,10,12,12,10,14
	dc.w	07,15,10,14,12,12,14,10
	dc.w	14,10,12,12,10,14,07,15
	dc.w	10,14,12,12,14,10,14,10
	dc.w	12,12,10,14,07,15,10,14
	dc.w	12,12,14,10,07,15
	dc.w	7,15

centi_anim_r
	dc.l	cer2_tab,cer2_tab,cer2_tab
	dc.l	cer2_tab,cer2_tab,cer2_tab
	dc.l	cer2_tab,cer2_tab,cer2_tab
	dc.l	cer3_tab,cer3_tab,cer3_tab
	dc.l	cer3_tab,cer3_tab,cer3_tab
	dc.l	cer3_tab,cer3_tab,cer3_tab
end_anim_r	
centi_anim_l
	dc.l	cel2_tab,cel2_tab,cel2_tab
	dc.l	cel2_tab,cel2_tab,cel2_tab
	dc.l	cel2_tab,cel2_tab,cel2_tab
	dc.l	cel3_tab,cel3_tab,cel3_tab
	dc.l	cel3_tab,cel3_tab,cel3_tab
	dc.l	cel3_tab,cel3_tab,cel3_tab
end_anim_l	

; animation table for centi head (right) 
head_anim_r
	dc.l	her3_tab,her3_tab,her3_tab
	dc.l	her3_tab,her3_tab,her3_tab
	dc.l	her3_tab,her3_tab,her3_tab
	dc.l	her2_tab,her2_tab,her2_tab
	dc.l	her2_tab,her2_tab,her2_tab
	dc.l	her2_tab,her2_tab,her2_tab
end_anim_hr	

; animation table for centi head (left) 

head_anim_l
	dc.l	hel2_tab,hel2_tab,hel2_tab
	dc.l	hel2_tab,hel2_tab,hel2_tab
	dc.l	hel2_tab,hel2_tab,hel2_tab
	dc.l	hel3_tab,hel3_tab,hel3_tab
	dc.l	hel3_tab,hel3_tab,hel3_tab
	dc.l	hel3_tab,hel3_tab,hel3_tab
end_anim_hl	

; Table of offsets into scorp tables for animation1

scorp_anim
	dc.w	0,0,0
	dc.w	0,0,0
	dc.w	0,0,0
	dc.w	64,64,64
	dc.w	64,64,64
	dc.w	64,64,64
end_scorp_anim

; Table of offsets into fly tables for animation

fly_anim	dc.w	0,0,0
	dc.w	0,0,0
	dc.w	0,0,0
	dc.w	32,32,32
	dc.w	32,32,32
	dc.w	32,32,32
end_fly_anim

; Table of offsets into fly tables for animation

bee_anim	dc.w	0,0,0
	dc.w	0,0,0
	dc.w	0,0,0
	dc.w	32,32,32
	dc.w	32,32,32
	dc.w	32,32,32
end_bee_anim

; used when bullet hits mushroom, they are used to set coords to
; the corner of the mushie where its state is stored

off_tabx	dc.b	0,0,0,0,1,2,3,4,5,6,7
	dc.b	0,1,2,3,4,5,6,7
	dc.b	0,1,2,3,4,5,6,7
	dc.b	0,1,2,3,4,5,6,7
off_taby	dc.b	0,0,0,0,0,0,0,0,0,0,0
	dc.b	1,1,1,1,1,1,1,1
	dc.b	2,2,2,2,2,2,2,2
	dc.b	3,3,3,3,3,3,3,3

; table of pinters to mushie routes

m_tab	dc.l	mush1,mush2,mush3

x_tab	incbin	d:\centiped.e\x_tab	; table of x coords to start scorp	
e_xtab

; Table of y coords to start fly and snail 

y_tab	dc.w	40,48,56,64,72,80,88,96,104,112,120,128,136
	dc.w	144,152,160,168,176
	dc.w	80,88,96,104,112,120,128,136,176
	dc.w	8,16,24,32,40,48,56,64,72
	dc.w	8,16,24,32,144,152,160,168
	dc.w	80,88,96,104,112,120,128,136,176
	dc.w	40,48,56,64,72,80,88,96,104,112,120,128,136
e_ytab

; Rasters used on intro (thru scroller)

rasters	dc.w	$100,$000,$000,$000,$000,$000,$000
	dc.w	$100,$000,$000,$000,$000,$000,$000
	dc.w	$200,$100,$000,$000,$000,$000,$000
	dc.w	$200,$100,$000,$000,$000,$000,$000
	dc.w	$300,$200,$100,$000,$000,$000,$000
	dc.w	$300,$200,$100,$000,$000,$000,$000
	dc.w	$400,$300,$200,$100,$000,$000,$000
	dc.w	$400,$300,$200,$100,$000,$000,$000
	dc.w	$500,$400,$300,$200,$100,$000,$000
	dc.w	$500,$400,$300,$200,$100,$000,$000
	dc.w	$600,$500,$400,$300,$200,$100,$000
	dc.w	$600,$500,$400,$300,$200,$100,$000
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$710,$600,$500,$400,$300,$200,$100
	dc.w	$710,$600,$500,$400,$300,$200,$100
	dc.w	$720,$610,$500,$400,$300,$200,$100
	dc.w	$720,$610,$500,$400,$300,$200,$100
	dc.w	$730,$620,$510,$400,$300,$200,$100
	dc.w	$730,$620,$510,$400,$300,$200,$100
	dc.w	$740,$630,$520,$410,$300,$200,$100
	dc.w	$740,$630,$520,$410,$300,$200,$100
	dc.w	$750,$640,$530,$420,$310,$200,$100
	dc.w	$750,$640,$530,$420,$310,$200,$100
	dc.w	$760,$650,$540,$430,$320,$210,$100
	dc.w	$760,$650,$540,$430,$320,$210,$100
	dc.w	$770,$660,$550,$440,$330,$220,$110
	dc.w	$770,$660,$550,$440,$330,$220,$110
	dc.w	$770,$660,$550,$440,$330,$220,$110
	dc.w	$770,$660,$550,$440,$330,$220,$110
	dc.w	$770,$660,$550,$440,$330,$220,$110
	dc.w	$770,$660,$550,$440,$330,$220,$110
	dc.w	$770,$660,$550,$440,$330,$220,$110
	dc.w	$770,$660,$550,$440,$330,$220,$110
	dc.w	$670,$560,$450,$340,$230,$120,$010
	dc.w	$670,$560,$450,$340,$230,$120,$010
	dc.w	$570,$460,$350,$240,$130,$020,$010
	dc.w	$570,$460,$350,$240,$130,$020,$010
	dc.w	$470,$360,$250,$140,$030,$020,$010
	dc.w	$470,$360,$250,$140,$030,$020,$010
	dc.w	$370,$260,$150,$040,$030,$020,$010
	dc.w	$370,$260,$150,$040,$030,$020,$010
	dc.w	$270,$160,$050,$040,$030,$020,$010
	dc.w	$270,$160,$050,$040,$030,$020,$010
	dc.w	$170,$060,$050,$040,$030,$020,$010
	dc.w	$170,$060,$050,$040,$030,$020,$010
	dc.w	$070,$060,$050,$040,$030,$020,$010
	dc.w	$070,$060,$050,$040,$030,$020,$010
	dc.w	$071,$060,$050,$040,$030,$020,$010
	dc.w	$071,$060,$050,$040,$030,$020,$010
	dc.w	$072,$061,$050,$040,$030,$020,$010
	dc.w	$072,$061,$050,$040,$030,$020,$010
	dc.w	$073,$062,$051,$040,$030,$020,$010
	dc.w	$073,$062,$051,$040,$030,$020,$010
	dc.w	$074,$063,$052,$041,$030,$020,$010
	dc.w	$074,$063,$052,$041,$030,$020,$010
	dc.w	$075,$064,$053,$042,$030,$020,$010
	dc.w	$075,$064,$053,$042,$030,$020,$010
	dc.w	$076,$065,$054,$043,$032,$021,$010
	dc.w	$076,$065,$054,$043,$032,$021,$010
	dc.w	$077,$066,$055,$044,$033,$022,$011
	dc.w	$077,$066,$055,$044,$033,$022,$011
	dc.w	$077,$066,$055,$044,$033,$022,$011
	dc.w	$077,$066,$055,$044,$033,$022,$011
	dc.w	$077,$066,$055,$044,$033,$022,$011
	dc.w	$077,$066,$055,$044,$033,$022,$011
	dc.w	$077,$066,$055,$044,$033,$022,$011
	dc.w	$077,$066,$055,$044,$033,$022,$011
	dc.w	$077,$066,$055,$044,$033,$022,$011
	dc.w	$077,$066,$055,$044,$033,$022,$011
	dc.w	$067,$056,$045,$034,$023,$012,$001
	dc.w	$067,$056,$045,$034,$023,$012,$001
	dc.w	$057,$046,$035,$024,$013,$002,$001
	dc.w	$057,$046,$035,$024,$013,$002,$001
	dc.w	$047,$036,$025,$014,$003,$002,$001
	dc.w	$047,$036,$025,$014,$003,$002,$001
	dc.w	$037,$026,$015,$004,$003,$002,$001
	dc.w	$037,$026,$015,$004,$003,$002,$001
	dc.w	$027,$016,$005,$004,$003,$002,$001
	dc.w	$027,$016,$005,$004,$003,$002,$001
	dc.w	$017,$006,$005,$004,$003,$002,$001
	dc.w	$017,$006,$005,$004,$003,$002,$001
	dc.w	$007,$006,$005,$004,$003,$002,$001
	dc.w	$007,$006,$005,$004,$003,$002,$001
	dc.w	$007,$006,$005,$004,$003,$002,$001
	dc.w	$007,$006,$005,$004,$003,$002,$001
	dc.w	$007,$006,$005,$004,$003,$002,$001
	dc.w	$007,$006,$005,$004,$003,$002,$001
	dc.w	$007,$006,$005,$004,$003,$002,$001
	dc.w	$007,$006,$005,$004,$003,$002,$001
	dc.w	$107,$006,$005,$004,$003,$002,$001
	dc.w	$107,$006,$005,$004,$003,$002,$001
	dc.w	$207,$106,$005,$004,$003,$002,$001
	dc.w	$207,$106,$005,$004,$003,$002,$001
	dc.w	$307,$206,$105,$004,$003,$002,$001
	dc.w	$307,$206,$105,$004,$003,$002,$001
	dc.w	$407,$306,$205,$104,$003,$002,$001
	dc.w	$407,$306,$205,$104,$003,$002,$001
	dc.w	$507,$406,$305,$204,$103,$002,$001
	dc.w	$507,$406,$305,$204,$103,$002,$001
	dc.w	$607,$506,$405,$304,$203,$102,$001
	dc.w	$607,$506,$405,$304,$203,$102,$001
	dc.w	$707,$606,$505,$404,$303,$202,$101
	dc.w	$707,$606,$505,$404,$303,$202,$101
	dc.w	$707,$606,$505,$404,$303,$202,$101
	dc.w	$707,$606,$505,$404,$303,$202,$101
	dc.w	$707,$606,$505,$404,$303,$202,$101
	dc.w	$707,$606,$505,$404,$303,$202,$101
	dc.w	$707,$606,$505,$404,$303,$202,$101
	dc.w	$707,$606,$505,$404,$303,$202,$101
	dc.w	$606,$505,$404,$303,$202,$101,$000
	dc.w	$606,$505,$404,$303,$202,$101,$000
	dc.w	$505,$404,$303,$202,$101,$000,$000
	dc.w	$505,$404,$303,$202,$101,$000,$000
	dc.w	$404,$303,$202,$101,$000,$000,$000
	dc.w	$404,$303,$202,$101,$000,$000,$000
	dc.w	$303,$202,$101,$000,$000,$000,$000
	dc.w	$303,$202,$101,$000,$000,$000,$000
	dc.w	$202,$101,$000,$000,$000,$000,$000
	dc.w	$202,$101,$000,$000,$000,$000,$000
	dc.w	$101,$000,$000,$000,$000,$000,$000
	dc.w	$101,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000
	dc.w	$111,$000,$000,$000,$000,$000,$000
	dc.w	$111,$000,$000,$000,$000,$000,$000
	dc.w	$222,$111,$000,$000,$000,$000,$000
	dc.w	$222,$111,$000,$000,$000,$000,$000
	dc.w	$333,$222,$111,$000,$000,$000,$000
	dc.w	$333,$222,$111,$000,$000,$000,$000
	dc.w	$444,$333,$222,$111,$000,$000,$000
	dc.w	$444,$333,$222,$111,$000,$000,$000
	dc.w	$555,$444,$333,$222,$111,$000,$000
	dc.w	$555,$444,$333,$222,$111,$000,$000
	dc.w	$666,$555,$444,$333,$222,$111,$000
	dc.w	$666,$555,$444,$333,$222,$111,$000
	dc.w	$777,$666,$555,$444,$333,$222,$111
	dc.w	$777,$666,$555,$444,$333,$222,$111
	dc.w	$777,$666,$555,$444,$333,$222,$111
	dc.w	$777,$666,$555,$444,$333,$222,$111
	dc.w	$777,$666,$555,$444,$333,$222,$111
	dc.w	$777,$666,$555,$444,$333,$222,$111
	dc.w	$777,$666,$555,$444,$333,$222,$111
	dc.w	$777,$666,$555,$444,$333,$222,$111
	dc.w	$777,$666,$555,$444,$333,$222,$111
	dc.w	$777,$666,$555,$444,$333,$222,$111
	dc.w	$777,$666,$555,$444,$333,$222,$111
	dc.w	$677,$567,$456,$345,$234,$123,$012
	dc.w	$677,$567,$456,$345,$234,$123,$012
	dc.w	$567,$456,$345,$234,$123,$012,$001
	dc.w	$567,$456,$345,$234,$123,$012,$001
	dc.w	$456,$345,$234,$123,$012,$001,$000
	dc.w	$456,$345,$234,$123,$012,$001,$000
	dc.w	$345,$234,$123,$012,$001,$000,$000
	dc.w	$345,$234,$123,$012,$001,$000,$000
	dc.w	$234,$123,$012,$001,$000,$000,$000
	dc.w	$234,$123,$012,$001,$000,$000,$000
	dc.w	$123,$012,$001,$000,$000,$000,$000
	dc.w	$123,$012,$001,$000,$000,$000,$000
	dc.w	$012,$001,$000,$000,$000,$000,$000
	dc.w	$012,$001,$000,$000,$000,$000,$000
	dc.w	$001,$000,$000,$000,$000,$000,$000
	dc.w	$001,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000
	dc.w	$000,$000,$000,$000,$000,$000,$000
endx
	dc.w	$100,$000,$000,$000,$000,$000,$000
	dc.w	$100,$000,$000,$000,$000,$000,$000
	dc.w	$200,$100,$000,$000,$000,$000,$000
	dc.w	$200,$100,$000,$000,$000,$000,$000
	dc.w	$300,$200,$100,$000,$000,$000,$000
	dc.w	$300,$200,$100,$000,$000,$000,$000
	dc.w	$400,$300,$200,$100,$000,$000,$000
	dc.w	$400,$300,$200,$100,$000,$000,$000
	dc.w	$500,$400,$300,$200,$100,$000,$000
	dc.w	$500,$400,$300,$200,$100,$000,$000
	dc.w	$600,$500,$400,$300,$200,$100,$000
	dc.w	$600,$500,$400,$300,$200,$100,$000
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$700,$600,$500,$400,$300,$200,$100
	dc.w	$710,$600,$500,$400,$300,$200,$100
	dc.w	$710,$600,$500,$400,$300,$200,$100
	dc.w	$720,$610,$500,$400,$300,$200,$100
	dc.w	$720,$610,$500,$400,$300,$200,$100

; colur table for intro (horiz lines)
col_tab	dc.w	$0700,$0711,$0722,$0733,$0744,$0755,$0766,$0777
	dc.w	$0777,$0777,$0777,$0777,$0776,$0775,$0774,$0773
	dc.w	$0772,$0771,$0770,$0670,$0570,$0470,$0370,$0270
col_tab2	dc.w	$0170,$0070,$0171,$0272,$0373,$0474,$0575,$0676
	dc.w	$0777,$0777,$0777,$0777,$0777,$0677,$0577,$0477
	dc.w	$0377,$0277,$0177,$0077,$0067,$0057,$0047,$0037
	dc.w	$0027,$0017,$0007,$0117,$0227,$0337,$0447,$0557
	dc.w	$0667,$0777,$0777,$0777,$0777,$0767,$0757,$0747
	dc.w	$0737,$0727,$0717,$0707,$0706,$0705,$0704,$0703
	dc.w	$0702,$0701
col_tab3	dc.w	$0700,$0711,$0722,$0733,$0744,$0755,$0766,$0777
	dc.w	$0777,$0777,$0777,$0777,$0776,$0775,$0774,$0773
	dc.w	$0772,$0771,$0770,$0670,$0570,$0470,$0370,$0270
	dc.w	$0170,$0070,$0171,$0272,$0373,$0474,$0575,$0676
	dc.w	$0777,$0777,$0777,$0777,$0777,$0677,$0577,$0477
	dc.w	$0377,$0277
ec
;                   cent spid scor snal flys bees wave diff
wave_data	
start1	dc.w	0002,0000,0001,0001,0001,0000,0000,0200
	dc.w	0002,0000,0001,0001,0001,0000,0000,0198
	dc.w	0003,0000,0002,0002,0002,0000,0000,0196
wave01	dc.w	0000,0000,0015,0000,0000,0000,  -1,0010
	dc.w	0003,0001,0002,0002,0002,0001,0000,0194
	dc.w	0004,0001,0002,0002,0002,0001,0000,0192
	dc.w	0004,0001,0002,0002,0002,0001,0000,0190
wave02	dc.w	0000,0000,0000,0000,0015,0000,  -1,0009
	dc.w	0005,0002,0002,0002,0002,0001,0000,0188
	dc.w	0005,0002,0002,0002,0002,0001,0000,0186
	dc.w	0006,0002,0002,0002,0002,0001,0000,0184
wave03	dc.w	0000,0000,0000,0000,0000,0015,  -1,0008
	dc.w	0006,0003,0003,0003,0003,0002,0000,0182
	dc.w	0007,0003,0003,0003,0003,0002,0000,0180
	dc.w	0007,0003,0003,0003,0003,0002,0000,0178
wave04	dc.w	0000,0006,0000,0000,0002,0000,  -1,0007
	dc.w	0008,0003,0000,0003,0003,0003,0000,0176
	dc.w	0008,0003,0000,0003,0003,0003,0000,0174
	dc.w	0009,0003,0000,0003,0003,0003,0000,0172
wave05	dc.w	0000,0005,0000,0000,0001,0001,  -1,0006
start2	dc.w	0009,0003,0003,0003,0003,0003,0000,0170
	dc.w	0010,0003,0003,0003,0003,0003,0000,0168
	dc.w	0010,0003,0003,0003,0003,0003,0000,0166
wave06	dc.w	0000,0000,0015,0002,0002,0000,  -1,0005
	dc.w	0010,0003,0003,0003,0003,0003,0000,0164
	dc.w	0010,0003,0003,0003,0003,0003,0000,0162
	dc.w	0010,0003,0003,0003,0003,0003,0000,0160
wave07	dc.w	0000,0000,0002,0002,0015,0000,  -1,0004
	dc.w	0010,0003,0003,0003,0003,0003,0000,0158
	dc.w	0010,0003,0003,0003,0003,0003,0000,0156
	dc.w	0010,0003,0003,0003,0003,0003,0000,0154
wave08	dc.w	0000,0000,0002,0002,0015,0000,  -1,0003
	dc.w	0010,0003,0003,0003,0003,0003,0000,0152
	dc.w	0010,0003,0003,0003,0003,0003,0000,0150
	dc.w	0010,0003,0003,0003,0003,0003,0000,0148
wave09	dc.w	0000,0000,0002,0002,0002,0015,  -1,0003
	dc.w	0010,0003,0003,0003,0003,0003,0000,0146
	dc.w	0010,0003,0003,0003,0003,0003,0000,0144
	dc.w	0010,0003,0003,0003,0003,0003,0000,0142
wave10	dc.w	0000,0005,0002,0002,0002,0001,  -1,0003
start3	dc.w	0010,0003,0003,0003,0003,0003,0000,0140
	dc.w	0010,0003,0003,0003,0003,0003,0000,0138
	dc.w	0010,0003,0003,0003,0003,0003,0000,0136
wave11	dc.w	0000,0000,0015,0002,0002,0002,  -1,0003
	dc.w	0010,0003,0003,0003,0003,0003,0000,0134
	dc.w	0010,0003,0003,0003,0003,0003,0000,0132
	dc.w	0010,0003,0003,0003,0003,0003,0000,0130
wave12	dc.w	0000,0000,0000,0002,0012,0002,  -1,0003
	dc.w	0010,0003,0003,0003,0003,0003,0000,0128
	dc.w	0010,0003,0003,0003,0003,0003,0000,0126
	dc.w	0010,0003,0003,0003,0003,0003,0000,0124
wave13	dc.w	0000,0002,0000,0002,0002,0010,  -1,0003
	dc.w	0010,0003,0003,0003,0003,0003,0000,0122
	dc.w	0010,0003,0003,0003,0003,0003,0000,0120
	dc.w	0010,0003,0003,0003,0003,0003,0000,0110
wave14	dc.w	0000,0003,0003,0003,0003,0005,  -1,0003
	dc.w	0010,0003,0003,0003,0003,0003,0000,0105
	dc.w	0010,0003,0003,0003,0003,0003,0000,0100
	dc.w	0010,0003,0003,0003,0003,0003,0000,0095
wave15	dc.w	0000,0004,0003,0003,0003,0005,  -1,0003
start4	dc.w	0010,0003,0003,0003,0003,0003,0000,0090
	dc.w	0010,0003,0003,0003,0003,0003,0000,0085
	dc.w	0010,0003,0003,0003,0003,0003,0000,0080
wave16	dc.w	0000,0004,0003,0003,0003,0005,  -1,0003
	dc.w	0010,0003,0003,0003,0003,0003,0000,0075
	dc.w	0010,0003,0003,0003,0003,0003,0000,0070
	dc.w	0010,0003,0003,0003,0003,0003,0000,0065
wave17	dc.w	0000,0005,0000,0000,0000,0000,  -1,0003
	dc.w	0010,0003,0003,0003,0003,0003,0000,0060
	dc.w	0010,0003,0003,0003,0003,0003,0000,0055
	dc.w	0010,0003,0003,0003,0003,0003,0000,0050
wave18	dc.w	0000,0000,0015,0000,0000,0000,  -1,0003
	dc.w	0010,0003,0003,0003,0003,0003,0000,0045
	dc.w	0010,0003,0003,0003,0003,0003,0000,0040
	dc.w	0010,0003,0003,0003,0003,0003,0000,0035
wave19	dc.w	0000,0000,0000,0005,0010,0000,  -1,0003
	dc.w	0010,0003,0003,0003,0003,0003,0000,0030
	dc.w	0010,0003,0003,0003,0003,0003,0000,0025
	dc.w	0010,0003,0003,0003,0003,0003,0000,0020
wave20	dc.w	0000,0005,0002,0002,0002,0001,  -1,0003
loop_waves
start5	dc.w	0010,0003,0003,0003,0003,0003,0000,0015
	dc.w	0010,0003,0003,0003,0003,0003,0000,0015
	dc.w	0010,0003,0003,0003,0003,0003,0000,0015
wave21	dc.w	0000,0000,0015,0002,0002,0002,  -1,0003
	dc.w	0010,0003,0003,0003,0003,0003,0000,0015
	dc.w	0010,0003,0003,0003,0003,0003,0000,0015
	dc.w	0010,0003,0003,0003,0003,0003,0000,0015
wave22	dc.w	0000,0000,0000,0002,0015,0002,  -1,0003
	dc.w	0010,0003,0003,0003,0003,0003,0000,0015
	dc.w	0010,0003,0003,0003,0003,0003,0000,0015
	dc.w	0010,0003,0003,0003,0003,0003,0000,0003
wave23	dc.w	0000,0002,0000,0002,0002,0010,  -1,0008
	dc.w	0010,0003,0003,0003,0003,0003,0000,0005
	dc.w	0010,0003,0003,0003,0003,0003,0000,0015
	dc.w	0010,0003,0003,0003,0003,0003,0000,0015
wave24	dc.w	0000,0004,0003,0003,0003,0005,  -1,0003
	dc.w	0010,0003,0003,0003,0003,0003,0000,0015
	dc.w	0010,0003,0003,0003,0003,0003,0000,0015
	dc.w	0010,0003,0003,0003,0003,0003,0000,0015
wave25	dc.w	0000,0005,0000,0005,0000,0000,  -1,0003
	dc.w	0010,0003,0003,0003,0003,0003,0000,0014
	dc.w	0010,0003,0003,0003,0003,0003,0000,0013
	dc.w	0010,0003,0003,0003,0003,0003,0000,0012
wave26	dc.w	0000,0000,0010,0005,0000,0000,  -1,0003
	dc.w	0010,0003,0003,0003,0003,0003,0000,0011
	dc.w	0010,0003,0003,0003,0003,0003,0000,0010
	dc.w	0010,0003,0003,0003,0003,0003,0000,0003
wave27	dc.w	0000,0000,0000,0005,0010,0000,  -1,0004
	dc.w	0010,0003,0003,0003,0003,0003,0000,0003
	dc.w	0010,0003,0003,0003,0003,0003,0000,0007
	dc.w	0010,0003,0003,0003,0003,0003,0000,0006
wave28	dc.w	0000,0000,0000,0005,0000,0010,  -1,0003
	dc.w	0010,0003,0003,0003,0003,0003,0000,0005
	dc.w	0010,0003,0003,0003,0003,0003,0000,0004
demo_star	dc.w	0010,0003,0003,0003,0003,0003,0000,0003
end_waves
parms_tab	dc.l	start1
	dc.l	start2
	dc.l	start3
	dc.l	start4
	dc.l	start5
int_text	incbin	d:\centiped.e\int_txt.dat	; intro txt	
here	equ	*+560
blah	equ	*+640	
mince	equ	*+680	; points to internal message 		
hst	incbin	d:\centiped.e\c.def	; hi scores
cred	incbin	d:\centiped.e\cred.dat	; credits
e_int_txt

scnam	equ	*+768	; point to ============
hs_txt	incbin	d:\centiped.e\hstxt.dat	; hi score entry
ehst	EVEN
	even

null_name	incbin	d:\centiped.e\fixes.dat	; table to modify 	
end_fixes					; hiscore names

lang	incbin	d:\centiped.e\lang.dat	; select language
mess2_eng	equ	*+962			; shareware message
mess1_eng	incbin	d:\centiped.e\mess.eng	;
mess2_deu	equ	*+922			; shareware message
mess1_deu	incbin	d:\centiped.e\share.deu	;
mess2_fra	equ	*+922			; shareware message
mess1_fra	incbin	d:\centiped.e\share.fra
mess2_itl	equ	*+962			; shareware message
mess1_itl	incbin	d:\centiped.e\share.itl
mess2_esp	equ	*+962			; shareware message
mess1_esp	incbin	d:\centiped.e\share.esp

hi_dave	incbin	d:\centiped.e\hi_dave.dat
	;

	even	
clog	incbin	d:\centiped.e\clogo.img

font8	incbin	d:\centiped.e\font.fnt	; 8x8 font

x	set	0

; Music by Big Alec ripped from musical wonder demo
; slightly optimised and smaller version by me! 

mus	INCBIN	d:\centiped.e\stn.al
mus2	INCBIN	d:\centiped.e\centi.mus

; Coords used in intro. generated with coords.bas 

coords	incbin	d:\centiped.e\coords
	dc.l	-1
	dc.l	-1

mess_tab	dc.l	mess1_eng
	dc.l	mess2_eng
	dc.l	mess1_deu
	dc.l	mess2_deu
	dc.l	mess1_fra
	dc.l	mess2_fra
	dc.l	mess1_itl
	dc.l	mess2_itl
	dc.l	mess1_esp
	dc.l	mess2_esp

; Table in intro used to store pointers for coords and sprite
; route tables for each intro sprite

x	set	20
stable	dc.l	coords,int_e_tab
	dc.l	coords+x,int_d_tab
	dc.l	coords+x*2,int_e_tab
	dc.l	coords+x*3,int_p_tab
	dc.l	coords+x*4,int_i_tab
	dc.l	coords+x*5,int_t_tab
	dc.l	coords+x*6,int_n_tab
	dc.l	coords+x*7,int_e_tab
	dc.l	coords+x*8,int_c_tab

; Intro sprites (C E N T I P E D E)

int_c	equ	*
int_e	equ	*+128
int_n	equ	*+256
int_t	equ	*+384
int_i	equ	*+512
int_p	equ	*+640
int_d	equ	*+768
int_gfx	incbin	d:\centiped.e\int.gfx

; save some ram and reuse the space taken up with the 
; game graphics which are only needed when generating 
; the sprite code. Now used as a save background buffer.
sav_buff1
sav_2p_buff1	equ	sav_buff1+7000

ship	incbin	d:\centiped.e\ship.img
bull	incbin	d:\centiped.e\bullet.img
snail	incbin	d:\centiped.e\snail.img
snailr	incbin	d:\centiped.e\snailr.img
scorp1	incbin	d:\centiped.e\scorp1.img
scorp2	incbin	d:\centiped.e\scorp2.img
spider1	incbin	d:\centiped.e\spider1.img
spider2	incbin	d:\centiped.e\spider2.img
bee1	incbin	d:\centiped.e\bee1.img
bee2	incbin	d:\centiped.e\bee2.img
fly2	incbin	d:\centiped.e\fly_r_2.img
fly3	incbin	d:\centiped.e\fly_r_3.img
fly2l	incbin	d:\centiped.e\fly_l_2.img
fly3l	incbin	d:\centiped.e\fly_l_3.img
cgfx	incbin	d:\centiped.e\cgfx.img

; Lots of equates to save inbining each centi seperately

cel1	equ	cgfx
cel2	equ	cel1+64
cel3	equ	cel2+64
cer1	equ	cel3+64
cer2	equ	cer1+64
cer3	equ	cer2+64
cedwn	equ	cer3+64
ceup	equ	cedwn+128
cedr1	equ	ceup+128
cedr2	equ	cedr1+128
cedr3	equ	cedr2+128
cedr5	equ	cedr3+128
cedr6	equ	cedr5+128
cedr7	equ	cedr6+128
cedl1	equ	cedr7+128
cedl2	equ	cedl1+128
cedl3	equ	cedl2+128
cedl5	equ	cedl3+128
cedl6	equ	cedl5+128
cedl7	equ	cedl6+128
ceur1	equ	cedl7+128
ceur2	equ	ceur1+128
ceur3	equ	ceur2+128
ceur5	equ	ceur3+128
ceur6	equ	ceur5+128
ceur7	equ	ceur6+128
ceul1	equ	ceur7+128
ceul2	equ	ceul1+128
ceul3	equ	ceul2+128
ceul5	equ	ceul3+128
ceul6	equ	ceul5+128
ceul7	equ	ceul6+128
hel1	equ	ceul7+128
hel2	equ	hel1+64
hel3	equ	hel2+64
her1	equ	hel3+64
her2	equ	her1+64
her3	equ	her2+64
hedwn	equ	her3+64
heup	equ	hedwn+128
hedr1	equ	heup+128
hedr2	equ	hedr1+128
hedr3	equ	hedr2+128
hedr5	equ	hedr3+128
hedr6	equ	hedr5+128
hedr7	equ	hedr6+128
hedl1	equ	hedr7+128
hedl2	equ	hedl1+128
hedl3	equ	hedl2+128
hedl5	equ	hedl3+128
hedl6	equ	hedl5+128
hedl7	equ	hedl6+128
heur1	equ	hedl7+128
heur2	equ	heur1+128
heur3	equ	heur2+128
heur5	equ	heur3+128
heur6	equ	heur5+128
heur7	equ	heur6+128
heul1	equ	heur7+128
heul2	equ	heul1+128
heul3	equ	heul2+128
heul5	equ	heul3+128
heul6	equ	heul5+128
heul7	equ	heul6+128
sc_100	incbin	d:\centiped.e\100.img
sc_500	incbin	d:\centiped.e\500.img
sc_1000	incbin	d:\centiped.e\1000.img
	ds.l	200
b_mush	ds.l	16
mush1	incbin	d:\centiped.e\mush.1
mush2	incbin	d:\centiped.e\mush.2
mush3	incbin	d:\centiped.e\mush.3
grey3	incbin	d:\centiped.e\mushie.g3
grey4	incbin	d:\centiped.e\mushie.g4

; This stuff goes in the bottom border

numbers	incbin	d:\centiped.e\numbers.1p	; for score/lives
s_text	incbin	d:\centiped.e\s_text.1p	; 'SCORE'
demo	incbin	d:\centiped.e\demo.1p	; 'DEMO'
ships	incbin	d:\centiped.e\ships.1p	; 'SHIPS'
paws	incbin	d:\centiped.e\pause.1p	' 'PAUSE'

; Sound fx data
firtone	incbin	d:\centiped.e\fire.tne
firvol	incbin	d:\centiped.e\fire.vol
firend	dc.l	'TTH!'
mushtone	incbin	d:\centiped.e\thrust.tne
mushvol	incbin	d:\centiped.e\thrust.vol
mushend	dc.l	'TTH!'
bangtone	incbin	d:\centiped.e\explode.tne
bangvol	incbin	d:\centiped.e\explode.vol
bangend	dc.l	'TTH!'
extratone	incbin	d:\centiped.e\extra.tne
extravol	incbin	d:\centiped.e\extra.vol
extraend	dc.l	'TTH!'
dietone	incbin	d:\centiped.e\die.tne
dievol	incbin	d:\centiped.e\die.vol
dieend	dc.l	'TTH!'

; These tables hold predefined spider coords 

sp_crds1	incbin	d:\centiped.e\sp.1	
sp_crds2	incbin	d:\centiped.e\sp.2	
sp_crds3	incbin	d:\centiped.e\sp.3		
sp_crds4	incbin	d:\centiped.e\sp.4		
sp_crds5	incbin	d:\centiped.e\sp.5		
sp_crds6	incbin	d:\centiped.e\sp.6		
sp_crds7	incbin	d:\centiped.e\sp.7		
sp_crds8	incbin	d:\centiped.e\sp.8		
sp_crds9	incbin	d:\centiped.e\sp.9		
sp_crds10	incbin	d:\centiped.e\sp.10		

; Table to hold coords of the centipede segments 
; I could probably use the coords in the other tables
; mentioned further down but this way works so why 
; tamper with it.
	ds.w	3	
ce_table
	rept	17
	dc.l	-1
	dc.w	-1
	endr

; current position in centipede table, used for adding them
; always reset at start of game/when live lost or when the
; centipede has been wiped out.
 
ce_t_pos	dc.l	ce_table

; Table to store centipede heads
; Format is simple, each long points to the relevant coords 

ce_heads
	rept	15
	dc.l	0
	endr
	dc.l	-1
	dc.l	-1
	dc.l	-1

; Table to store spiders on screen.
; Spider coords are stored in predefined tables.
; format is simple, each long is 0 or points to a set of coords  

sp_table	ds.l	6
	dc.l	-1

; table to store scorpions on screen
; format is 1 word xcoord, 1 word ycoord 
; max of 3 scorps except in wave when there are 21 

sc_table	ds.l	16
	dc.l	-1

; Table to store snails on screen.
; format is 1 word xcoord, 1 word ycoord and one word dir (+ve/-ve)
; -ve signifies left. We need a end marker because we cant use -1
; as snail has -ve coords 
; MAX OF 3 snails

sn_table	ds.l	5
	ds.w	5
	dc.l	'END!'

; Table to store bees on screen.
; format is 1 word xcoord, 1 word ycoord and one word x offset

bee_table	ds.l	15
	ds.l	15
	dc.l	-1

; Table to store flies on screen.
; format is 1 word xcoord, 1 word ycoord and one word dir (+ve/-ve)
; -ve signifies left. We need a end marker because we cant use -1
; as fly has -ve coords 
; MAX OF 3 flies except in wave when there are 16

fly_table	ds.l	16
	ds.w	16
	dc.l	-1

; Table to store scores that pop up on screen when you shoot something
; Format is 1 word xcoord, 1 word ycoord, 1 word score no * 64
; 1 word time left on screen (in frames)

scr_table	ds.l	8
	dc.l	-1

; These are used when saving and restoring sprites to the double
; buffered screen. We need two buffers and a set of pointers and 
; counters for each one. Sprites saved out to a buffer are not restored
; until that buffer becomes the save buffer again.   

s_buff_add1
	dc.l	sav_buff1

res_count1
	dc.w	0
s2p_buff_add1
	dc.l	sav_2p_buff1
res2p_count1
	dc.w	0
s_buff_add2
	dc.l	sav_buff2
res_count2	
	dc.w	0
s2p_buff_add2
	dc.l	sav_2p_buff2
res2p_count2
	dc.w	0

mb_ptr	dc.l	mush_buffer	; pointer to buffer where
				; mushies to be plotted 
				; are stored  	

; These two tables are used when storing the coords of the 
; centipede body segments. The first is a table of pointers
; to storing them whilst the second is used to loop within the
; table. I'm sure there is a better way of doing this but I wrote
; it a while ago and it works so why change it  

pntr_table
	dc.l	table1,table2,table3,table4,table5
	dc.l	table6,table7,table8,table9,table10
	dc.l	table11,table12,table13,table14,table15
	dc.l	end_tables,0
loop_table
	dc.l	table2,table3,table4,table5,table6
	dc.l	table7,table8,table9,table10,table11
	dc.l	table12,table13,table14,table15,end_tables
	dc.l	0

	section	bss
	ds.l	200
stack	ds.l	2
yyyyyyy		; used in clearing ram, don't want to clear
		; the stack now, do we!

; vars used in building sprites

offset	ds.w	1	; screen offset
interval	ds.w	1	; gap between each rotation
poss_long_soon		; set to true if the current word 
	ds.b	1	; could be combined with the next
	even		; ie plane 1 and 2
mask_flag	ds.b	1	; indicates we want masked sprites   
	even		;
scanlines	ds.w	1	; number of scanlines in sprite
rot_offset		; what we are rotating with 
	ds.w	1	;
last_mask	ds.w	1	; last mask generated. used to see if
			; we can use the same one twice or more 

old_pal	ds.l	8	; kinda obvious really	
blank	ds.l	16	; ditto

score_pos	ds.l	1	; stores address of pos in hi-score table
old_ssp	ds.l	1	; store old stack
abortf	ds.w	1	; set to true if undo pressed in game
pausef	ds.w	1	; set to true if help pressed in game
r_val	ds.w	1	; psuedo random number
handle	ds.w	1	; file handle of hi scores
val	ds.w	1	; used in random number calcs
tries	ds.w	1	; used in random number calcs
chip_val	ds.b	1	; value from keyboard chip
	even
curr_wave	ds.l	1	; current wave we are on
timer	ds.w	1
ce_cnt	ds.w	1	; centis added to level
c2kill	ds.w	1	; centis left to kill in level
c4level	ds.w	1	; No of centis in level	
ce_cntr	ds.w	1	; counter before next segment is added
wave	ds.w	1	; wave in progress
diff	ds.w	1	; difficulty level 200=easy
f_p_on_intro
	ds.w	1	; for mr cowan
last_start	
	ds.w	1	; for mr cowan 
crap	ds.l	20	; store vbl ptrs etc here
crap2	ds.l	20	; store vbl ptrs etc here
score	ds.l	2	; what else!
nxt_life	ds.w	1	; used to determine next bonus life
lives	ds.w	1	; easy 
live_lost	ds.w	1	; set to true when live lost
d_flag	ds.w	1	; flag to get direction when adding 
			; fly or snail
cd_flag	ds.w	1
curr_cd	ds.w	1
dir	ds.w	1	; used to tell sprite root the direction

vbldone	ds.w	1	; set true at end of vbl
no_music	ds.w	1
demo_mode	ds.w	1	; set true when demo mode is active	
dm	ds.w	1	; set true when demo mode is active	
demo_count
	ds.w	1	; countdown in demo til end
			; the sprite is travelling
cheat	ds.w	1	; set true for cheat mode
x_coord	ds.w	1	; xcoord of player
y_coord	ds.w	1	; ycoord of player
lx_coord	ds.w	1	; last xcoord of player
ly_coord	ds.w	1	; last ycoord of player
bx_coord	ds.w	1	; xcoord of bullet 
by_coord	ds.w	1	; ycoord of bullet
; sound fx vars
fire_vol	ds.l	1
fire_tone	ds.l	1
bang_vol	ds.l	1
bang_tone	ds.l	1
mush_vol	ds.l	1
mush_tone	ds.l	1
extra_vol	ds.l	1
extra_tone
	ds.l	1
die_vol	ds.l	1
die_tone
	ds.l	1

c_offs1	ds.w	1
c_offs2	ds.w	1
clr_now	ds.w	1

xc	ds.w	1	; store character and coords to plot it 
yc	ds.w	1	; for next frame - double buffered with 
pc	ds.w	1	; masked background saving sprites intro
			; means I can't plot both on same frame.
namex	ds.w	1	; xcoord of name entered on hs 		
namey	ds.w	1	; ycoord of name entered on hs 

char	ds.w	1	; see below 
plot_char	ds.w	1	; set to true when char to be plotted
			; on next frame of hi score input
del_char	ds.w	1	; set to true when char to be deleted
			; on next frame of hi score input

; stores mouse movements on hi score input

hx_coord	ds.w	1	; mouse xcoord on hi score input
hy_coord	ds.w	1	 ; mouse ycoord on hi score input

c_tab	ds.l	1
	rept	8*10
	ds.l	1
	endr
ec_tab	equ	*-4	; end of above table

curr_x	ds.w	1	; coords used in 8*8 font plot
curr_y	ds.w	1

; These hold the amount of that insect that can still be added 
; onto the screen 

spider_tot	ds.w	1
scorp_tot	ds.w	1
snail_tot	ds.w	1
fly_tot	ds.w	1
bee_tot	ds.w	1
spiders_on_screen	ds.w	1
bees_on_screen	ds.w	1
flys_on_screen	ds.w	1
snails_on_screen	ds.w	1
scorps_on_screen	ds.w	1

; These tables store pointers to the game sprite rootz 

ship_tab	ds.l	16
bull_tab	ds.l	16
spider1_tab_lc	ds.l	8
spider1_tab_rc	ds.l	8
spider2_tab_lc	ds.l	8
spider2_tab_rc	ds.l	8
scorp1_tab	ds.l	1
scorp2_tab	ds.l	1
snail_tab_lc	ds.l	16
snail_tab_rc	ds.l	16
snailr_tab_lc	ds.l	16
snailr_tab_rc	ds.l	16
bee1_tab	ds.l	8
bee2_tab	ds.l	8
fly2_tab	ds.l	8
fly3_tab	ds.l	8
fly2l_tab	ds.l	8
fly3l_tab	ds.l	8
cel2_tab	ds.l	8
cel3_tab	ds.l	8
cer2_tab	ds.l	8
cer3_tab	ds.l	8
ceup_tab	ds.l	8
cedwn_tab	ds.l	8
cedl1_tab	ds.l	8
cedl2_tab	ds.l	8
cedl3_tab	ds.l	8
cedl5_tab	ds.l	8
cedl6_tab	ds.l	8
cedl7_tab	ds.l	8
cedr1_tab	ds.l	8
cedr2_tab	ds.l	8
cedr3_tab	ds.l	8
cedr5_tab	ds.l	8
cedr6_tab	ds.l	8
cedr7_tab	ds.l	8
ceul1_tab	ds.l	8
ceul2_tab	ds.l	8
ceul3_tab	ds.l	8
ceul5_tab	ds.l	8
ceul6_tab	ds.l	8
ceul7_tab	ds.l	8
ceur1_tab	ds.l	8
ceur2_tab	ds.l	8
ceur3_tab	ds.l	8
ceur5_tab	ds.l	8
ceur6_tab	ds.l	8
ceur7_tab	ds.l	8
hel2_tab	ds.l	8
hel3_tab	ds.l	8
her2_tab	ds.l	8
her3_tab	ds.l	8
heup_tab	ds.l	8
hedwn_tab	ds.l	8
hedl1_tab	ds.l	8
hedl2_tab	ds.l	8
hedl3_tab	ds.l	8
hedl5_tab	ds.l	8
hedl6_tab	ds.l	8
hedl7_tab	ds.l	8
hedr1_tab	ds.l	8
hedr2_tab	ds.l	8
hedr3_tab	ds.l	8
hedr5_tab	ds.l	8
hedr6_tab	ds.l	8
hedr7_tab	ds.l	8
heul1_tab	ds.l	8
heul2_tab	ds.l	8
heul3_tab	ds.l	8
heul5_tab	ds.l	8
heul6_tab	ds.l	8
heul7_tab	ds.l	8
heur1_tab	ds.l	8
heur2_tab	ds.l	8
heur3_tab	ds.l	8
heur5_tab	ds.l	8
heur6_tab	ds.l	8
heur7_tab	ds.l	8
sc_100_tab	ds.l	1
sc_500_tab	ds.l	1
sc_1000_tab	ds.l	1
	even

; These tables store pointers to the intro sprite rootz 

int_c_tab	ds.l	16
int_e_tab	ds.l	16
int_n_tab	ds.l	16
int_t_tab	ds.l	16
int_i_tab	ds.l	16
int_p_tab	ds.l	16
int_d_tab	ds.l	16
stay_cnt	ds.w	1

; These tables store the last 8 or so coords of 
; each centi segment.

table1	ds.w	27
table2	ds.w	27
table3	ds.w	27
table4	ds.w	27
table5	ds.w	27
table6	ds.w	27
table7	ds.w	27
table8	ds.w	27
table9	ds.w	27
table10	ds.w	27
table11	ds.w	27
table12	ds.w	27
table13	ds.w	27
table14	ds.w	27
table15	ds.w	27
end_tables
	ds.w	27
endt
mush_buffer
	ds.l	120	; screen offsets and mushie route 
			; of mushies to plot next frame
mushie_tab
	ds.b	MAX_VAL1*MAX_VAL2		; mushies mapped here
endmt
sp_buff	ds.b	114800	; generated sprite code goes here
free_ram	ds.l	(256/4)+($8000/4)+($8000/4)	; space for screens
	ds.l	1000
work_screen
sav_buff2	equ	work_screen
sav_2p_buff2	equ	sav_buff2+7000
ints_buff	equ	sav_2p_buff2+3000
	ds.l	8000	; Ok this area of ram is used as
			; a buffer to save 4plane sprites
			; during the game. When zooming in
			; a screen then it is used to provide
			; the screen being zoomed in from. On
			; the intro, the sprite code is 
			; generated here!
xxxxxxx
