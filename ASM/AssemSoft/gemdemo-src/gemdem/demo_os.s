;               ___________     ______   ______    ____________
;              !           \   !      ! !      !  /           /
;              ! !    _     \  ! !    !_!      ! / /  _______/
;           ___! !   !_\     \_! !             !_\ \         \____
;           :::!     !:/   / /:!       _     ! !::\_______  \ \:::
;           :::!          / /::!      !:!    ! !::/         / /:::
;           :::!___________/:::!______!:!______!:/___________/::::
;           ::::::::::::::::::::::::::::::::::::::::::::::::::::::
;           ::::::::::::::[ Dead Hackers Society ]::::::::::::::::
;           ::::::::::::::::::::::::::::::::::::::::::::::::::::::
;

screen_size:	equ	320*240*2*3		;3 16bit 320*240 screens

		move.l	4(sp),a5		;mshrink
		move.l	$0c(a5),d0		;
		add.l	$14(a5),d0		;
		add.l	$1c(a5),d0		;
		add.l	#$1000,d0		;
		add.l	#$100,d0		;
		move.l	a5,d1			;
		add.l	d0,d1			;
		and.l	#-2,d1			;
		move.l	d1,sp			;
		move.l	d0,-(sp)		;
		move.l	a5,-(sp)		;
		move.w	d0,-(sp)		;
		move.w	#$4a,-(sp)		;
		trap	#1			;
		lea	12(sp),sp		;

		clr.l	-(sp)			;Get into supervisormode
		move.w	#32,-(sp)		;
		trap	#1			;
		addq.l	#6,sp			;
		move.l	d0,save_stack		;Save old stack

		move.w	#0,-(sp)		;mxalloc - reserve stram ONLY for screens
		move.l	#screen_size+256,-(sp)	;size of screens together in bytes
		move.w	#$44,-(sp)		;
		trap	#1			;
		addq.l	#8,sp			;
		cmp.l	#0,d0			;check if there is stram enough
		beq.w	exit_nostram		;nope - exit with error msg
		move.l	d0,real_screen		;yes - store stram screenaddress

		move.b	$ff8203,save_mid	;save screen address
		move.b	$ff8201,save_high	;
		move.b	$ff820d,save_low	;

		bsr.w	save_pal		;save palette
		bsr.w	save_video		;save videl videomode

		bsr.w	vga60_16bit_320_240	;set videomode to use
		;bsr.w	rgb60_16bit_320_240	;set videomode to use

		move.l	real_screen,d0		;get ST-RAM buffer for screens
		add.l	#256,d0			;add space for even address
		move.b	#0,d0			;fix even address for screens
		move.l	d0,screen_adr 		;screen 1
		add.l	#screen_size/3,d0	;add space for next screen
		move.l	d0,screen_adr2		;screen 2
		add.l	#screen_size/3,d0	;add space for next screen
		move.l	d0,screen_adr3		;screen 3

		bsr.w	clear_screens

		move.l	screen_adr,d0		;set screen
		move.l	d0,d1			;
		lsr.w	#8,d1			;
		move.l	d1,$fff8200		;
		move.b	d0,$fff820d		;


		bsr.w	black_pal		;all colours to black

		move.l	#dummy,vbi_routine	;vbi - run 'rts' only at start
		move.l	#dummy,trash_routine	;mainloop - run 'rts' only at start

		move.w	sr,d0			;save sr
		move.w	#$2700,sr		;all ints off

		bsr.w	save_mfp		;save mfp registers

		bset	#4,$fffa09		;timer-d inits
		bset	#4,$fffa15		;
		
		move.b	#246,$fffa25		;2457600/200/246 approx 50 Hz  
		or.b	#%111,$fffa1d		;%111 = divide by 200

		move.l	$110,save_timer_d	;save old timer-d
		move.l	#demo_system,$110	;install new timer-d

		move.l	$70,save_vbi		;save vbi
		move.l	#vbi,$70		;install new vbi

		move.w	d0,sr			;all ints on

		bra.w	mainloop		;trash mainloop


; --------------------------------------------------------------
; ------------- VBI --------------------------------------------
; --------------------------------------------------------------

vbi:		movem.l	d0-a6,-(sp)		;save all

		move.l	vbi_routine,a0		;get routine address
		jsr	(a0)			;do routine

		movem.l	(sp)+,d0-a6		;restore all
		rte


; --------------------------------------------------------------
; ------------- Timer D demosystem -----------------------------
; --------------------------------------------------------------

demo_system:	movem.l	d0-a6,-(a7)		;save all

		cmp.b	#$2a,$fffc02		;left shift = pause
		beq.s	.no			;

		lea.l	partlist,a0		;parttlist = list of effects
		move.l	part_var,d0		;part_var = current effect
		move.l	4(a0,d0),a1		;get address of effect to run at 50 Hz
		move.l	8(a0,d0),a2		;get address of effect to run at VBI
		move.l	12(a0,d0),a3		;get address of effect to run in background
		move.l	16(a0,d0),do_swap	;swap screens or not

		move.l	a2,vbi_routine		;VBI routine
		move.l	a3,trash_routine	;background routine
		jsr	(a1)			;50 Hz demoroutine

		addq.l	#1,effect_count		;add 1 to framecounter of this effect

		lea.l	partlist,a0		;demot = list of effects
		move.l	part_var,d1		;demovar = current effect
		move.l	(a0,d1),d0		;
		sub.l	effect_count,d0		;

		cmp.l	#0,d0			;if d0 = 0 then change effect
		bne.s	.no			;fx not done

		clr.l	effect_count		;clear fx position
		add.l	#20,part_var		;continue to next fx
.no:
		movem.l	(a7)+,d0-a6		;restore all
		bclr	#4,$fffa11		;enable other interupts
		rte


; --------------------------------------------------------------
; ------------- Mainloop ---------------------------------------
; --------------------------------------------------------------

mainloop:	move.l	trash_routine,a0	;get routine

		move.l	do_swap,d0		;swap screens or not
		bne.s	.no			;no
		bsr.w	setscreens		;yes - set & swap screens

.no: 		jsr	(a0)			;do routine

		cmp.b	#$39,$fffc02		;space - exit?
		bne.s	mainloop		;no
		bra.w	exit			;yes


; --------------------------------------------------------------
; ------------- Clear screens  ---------------------------------
; --------------------------------------------------------------

clear_screens:	move.l	screen_adr,a6		;start of clear
		movem.l	clr_regs,d1-a5		;clear regs to use
		move.l	#screen_size/52,d0	;number of loops
.loop:		movem.l	d1-a5,(a6)		;clear 52 bytes
		add.l	#52,a6			;dest inc
		dbra	d0,.loop		;again..
		rts


; --------------------------------------------------------------
; ------------- Save mfp ---------------------------------------
; --------------------------------------------------------------

save_mfp:	lea.l	save_mfpreg,a0		;save needed mfp regs
		move.b	$fffa09,(a0)+		;
		move.b	$fffa15,(a0)+		;
		move.b	$fffa1d,(a0)+		;
		move.b	$fffa25,(a0)+		;
		rts


; --------------------------------------------------------------
; ------------- Restore mfp ------------------------------------
; --------------------------------------------------------------

restore_mfp:	lea.l	save_mfpreg,a0		;restore used mfp regs
		move.b	(a0)+,$fffa09		;
		move.b	(a0)+,$fffa15		;
		move.b	(a0)+,$fffa1d		;
		move.b	(a0)+,$fffa25		;
		rts


; --------------------------------------------------------------
; ------------- Save pal ---------------------------------------
; --------------------------------------------------------------

save_pal:	lea.l	$ffff9800,a0		;falcon pal
		lea.l	save_palette,a1		;
		move.l	#256-1,d7		;
.loop:		move.l	(a0)+,(a1)+		;
		dbra	d7,.loop		;

		lea.l	$FFFF8240,a0		;st pal
		move.l	#8-1,d7			;
.loop2:		move.l	(a0)+,(a1)+		;
		dbra	d7,.loop2		;
		rts


; --------------------------------------------------------------
; ------------- Restore pal ------------------------------------
; --------------------------------------------------------------

restore_pal:	lea.l	$ffff9800,a0		;falcon pal
		lea.l	save_palette,a1		;
		move.l	#256-1,d7		;
.loop:		move.l	(a1)+,(a0)+		;
		dbra	d7,.loop		;

		lea.l	$FFFF8240,a0		;st pal
		move.l	#8-1,d7			;
.loop2:		move.l	(a1)+,(a0)+		;
		dbra	d7,.loop2		;
		rts


; --------------------------------------------------------------
; ------------- Black pal --------------------------------------
; --------------------------------------------------------------

black_pal:	lea.l	$ffff9800,a0		;all to black
		moveq.l	#0,d0			;
		move.l	#256-1,d7		;
.loop:		move.l	d0,(a0)+		;
		dbra	d7,.loop		;
		rts


; --------------------------------------------------------------
; ------------- Save video -------------------------------------
; --------------------------------------------------------------

save_video: 	move.w	#2,-(sp)		;xbios save video
		trap	#14			;
		addq.l	#2,sp			;
		move.l	d0,save_phys		;

	    	move.w  #-1,-(sp)		;
                move.w  #$58,-(sp)		;
                trap    #14			;
                addq.l  #4,sp			;
                move.w  d0,save_scr		;
		rts


; --------------------------------------------------------------
; ------------- Restore video ----------------------------------
; --------------------------------------------------------------

restore_video: 	move.w	save_scr,-(sp)		;xbios restore video
		move.w	#-1,-(sp)		;
		move.l	save_phys,-(sp)		;
		move.l	save_phys,-(sp)		;
		move.w	#5,-(sp)		;
		add.l	#14,sp			;

                move.w  save_scr,-(sp)		;
                move.w  #$58,-(sp)		;
                trap    #14			;
                addq.l  #4,sp			;
		rts


; --------------------------------------------------------------
; ------------- Set screens & swap -----------------------------
; --------------------------------------------------------------

setscreens:	move.l	screen_adr,d0		;get stram screenaddress
		move.l	d0,d1			;
		lsr.w	#8,d1			;

		move.w	sr,save_sr		;save sr
		move.w	#$2700,sr		;all ints off

		move.l	d1,$fff8200		;$fff8200
		move.b	d0,$fff820d		;$fff820d

		move.w	save_sr,sr		;restore interupts

		move.l	screen_adr,d0		;screenswap
		move.l	screen_adr2,screen_adr	;
		move.l	screen_adr3,screen_adr2	;
		move.l	d0,screen_adr3		;
		rts


; --------------------------------------------------------------
; ------------- Exit -------------------------------------------
; --------------------------------------------------------------

exit:
		move.w	sr,d0			;save sr
		move.w	#$2700,sr		;all ints off

		bsr.w	restore_mfp		;restore mfp
		
		move.l	save_vbi,$70		;restore vbi
		move.l	save_timer_d,$110	;restore timer_b

		move.w	d0,sr			;all ints on

		bsr.w	restore_video		;restore videl

		move.b	save_mid,$ff8203	;restore screen
		move.b	save_high,$ff8201	;
		move.b	save_low,$ff820d	;

		bsr.w	restore_pal		;restore old colours		
		
		move.l	save_stack,-(sp)	;restore stack
		move.w	#32,-(sp)		;
		trap	#1			;
		addq.l	#6,sp			;

		clr.w	-(sp)			;pterm
		trap	#1			;


; --------------------------------------------------------------
; ------------- Exit no stram ----------------------------------
; --------------------------------------------------------------

exit_nostram:	move.l	#nostram_text,-(sp)	;print text
		move.w	#9,-(sp)		;
		trap	#1			;
		addq.l	#6,sp			;

.loop:		cmp.b	#$39,$fffc02		;space - exit?
		bne.s	.loop			;

		move.l	save_stack,-(sp)	;restore stack
		move.w	#32,-(sp)		;
		trap	#1			;
		addq.l	#6,sp			;

		clr.w	-(sp)			;pterm
		trap	#1			;


; --------------------------------------------------------------
; ------------- Small crap -------------------------------------
; --------------------------------------------------------------

dummy:		rts				;dummy routine

bumpmapper:	add.l	#80,.var		;Sinuscurve - X move
		andi.l  #$00001fff,.var		;
                lea     sinus,a0		;
                move.l  .var,d0			;
                move.l  0(a0,d0.w),d1		;
                muls    #88,d1			;
                asr.l   #8,d1			;
                asr.l   #7,d1			;
                add.l   d1,d1			;d1 = X add

		add.l	#48,.var2		;Sinuscurve - Y move
		andi.l  #$00001fff,.var2	;
                lea     sinus,a0		;
                move.l  .var2,d0		;
                move.l  0(a0,d0.w),d2		;
                muls    #64,d2			;
                asr.l   #8,d2			;
                asr.l   #7,d2			;
                mulu	#512,d2			;d2 = Y add

		move.l	screen_adr,a0
		lea.l	flare+512*64+96,a1
		add.l	d1,a1
		add.l	d2,a1

		lea.l	bumpmap,a2
		clr.l	d0
		move.w	#99,d7
.loop:		move.w	#143,d6
.loop2:

		move.w	(a2)+,d0
		move.w	(a1,d0.l*2),(a0)+
		addq	#2,a1

		dbra	d6,.loop2
		add.l	#640-288,a0
		add.l	#512-288,a1
		dbra	d7,.loop

		rts

.var:		ds.l	1			;sinus constant X
.var2:		ds.l	1			;sinus constant Y

; --------------------------------------------------------------
; ------------- Includes ---------------------------------------
; --------------------------------------------------------------

		section text

		even
		
		include	'video.s'		;video library


; --------------------------------------------------------------
; ------------- Section Data -----------------------------------
; --------------------------------------------------------------

		section	data


flare:		incbin	'gfx\flare.16b'
		incbin	'gfx\flare.16b'
bumpmap:	incbin	'gfx\bump.dat'
		even

sinus:		incbin	'data\sinus.dat'

partlist:


		dc.l	10000,dummy,dummy,bumpmapper,0
		dc.l	100,dummy,dummy,exit,1		;exit



nostram_text:	dc.b	"Sorry, not enough ST-RAM available",13,10
		dc.b	"----------------------------------",13,10
		dc.b	                                     13,10
		dc.b	"Press space to exit.              ",13,10
		dc.b	0

		even


; --------------------------------------------------------------
; ------------- Section BSS ------------------------------------
; --------------------------------------------------------------

		section	bss


do_swap:	ds.l	1			;swapscreen or not
trash_routine:	ds.l	1			;address to trash routine
vbi_routine:	ds.l	1			;address to vbi routine
effect_count:	ds.l	1			;current fx position
part_var:	ds.l	1			;part counter of os
real_screen:	ds.l	1			;mxalloc screenadd
clr_regs:	ds.l	16			;movem clear reg space
screen_adr:	ds.l	1			;swapping screen 1
screen_adr2:	ds.l	1			;swapping screen 2
screen_adr3:	ds.l	1			;swapping screen 3
save_sr:	ds.w	1			;save sr
save_vbi:	ds.l	1			;save vbi
save_stack:	ds.l	1			;save stack
save_scr:	ds.l	1			;save videomode
save_phys:	ds.l	1			;save physbase
save_palette:	ds.l	256+8			;save palette (falcon+st)
save_timer_d:	ds.l	1			;save timer-d
save_mfpreg:	ds.b	4			;save mfp
save_low:	ds.b	1			;save screen low
save_mid:	ds.b	1			;save screen mid
save_high:	ds.b	1			;save screen high
