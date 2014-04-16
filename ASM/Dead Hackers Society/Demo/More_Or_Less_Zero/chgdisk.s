;    ___      ___      ___   
;   /\  \    /\__\    /\  \  
;  /::\  \  /:/__/_  /::\  \ 
; /:/\:\__\/::\/\__\/\:\:\__\
; \:\/:/  /\/\::/  /\:\:\/__/
;  \::/  /   /:/  /  \::/  / 
;   \/__/    \/__/    \/__/  
;
;    DEAD HACKERS SOCIETY
;
; Atari ST/e synclock demosystem v0.3
; January 6, 2008
;
; chgdisk.s
; 
; Anders Eriksson
; ae@dhs.nu
;

; MORE OR LESS ZERO - CHANGE DISK SCREEN
; Atari STe-demo 2008 (?)


scr_w:		equ	230			;linewidth of fullscreen
scr_h:		equ	280			;max lines visible

hatari:		equ	0			;Hatari specific codepath (bug workarounds)
hatari_speedup:	equ	0			;Hatari specific speedup during init

music_sndh:	equ	0			;Play a sndh music file
music_ym:	equ	0			;Play an ym-music file (YM3 only)
music_dma:	equ	0			;Play a DMA-sample sequence (STe only)
music_mod:	equ	0

init_green:	equ	0			;1=runtime init sets bg green when done

		opt	p=68000
		output .tos

		section	text

begin:		include	'sys/fullinit.s'		;setup demosystem


;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		SYSTEM MAINLOOP
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

mainloop:	tst.l	vbl_counter
		beq.s	mainloop
		clr.l	vbl_counter

		move.l	a0,-(sp)
		move.l	main_routine,a0
		jsr	(a0)
		move.l	(sp)+,a0
	
		cmp.b	#$39,$fffffc02.w		;space?
		bne.s	mainloop
		move.l	#exit_part,part_position
		bra.s	mainloop

		include	'sys/fullexit.s'		;exit demosystem

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		SYSTEM VBL
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

vbl:
		clr.b	$fffffa19.w			;timer-a setup
		move.b	timera_delay+3,$fffffa1f.w	;
		move.b	timera_div+3,$fffffa19.w	;

	
		movem.l	d0-a6,-(sp)

		ifne	music_ym
		jsr	music_ym_play
		endc
		
		ifne	music_sndh
		jsr	music_sndh_play
		endc
		
		move.l	vbl_routine,a0
		jsr	(a0)

		ifne	music_dma
		jsr	music_dma_play
		endc

;		Micro demopart sequencer
		move.l	part_position,a0
		subq.l	#1,(a0)+
		bne.s	.no_switch
		add.l	#24,part_position
.no_switch:	move.l	(a0)+,timera_delay
		move.l	(a0)+,timera_div
		move.l	(a0)+,vbl_routine
		move.l	(a0)+,timera_routine
		move.l	(a0)+,main_routine

		addq.l	#1,vbl_counter
		addq.l	#1,global_vbl
		movem.l	(sp)+,d0-a6
		move.l	save_buffer+4,-(sp)
		rts
		;rte

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		SYSTEM HBL (PLACEHOLDER)
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

hbl:		rte

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		SYSTEM TIMER A
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

timer_a:	movem.l	d0-a6,-(sp)
		move.l	timera_routine,a0
		jsr	(a0)
		movem.l	(sp)+,d0-a6
		rte

timer_a_dummy:	clr.b	$fffffa19.w			;stop ta
		rts

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		MISC COMMON ROUTINES
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

dummy:		rts


clear_screens:	move.l	screen_adr_base,a0
		moveq.l	#0,d0
		move.w	#128*1024/8-1,d7
.clr:		move.l	d0,(a0)+
		move.l	d0,(a0)+
		dbra	d7,.clr
		rts

black_pal:	movem.l	.black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts
.black:		dcb.w	16,$0000

white_pal:	movem.l	.black,d0-d7
		movem.l	d0-d7,$ffff8240.w
		rts
.black:		dcb.w	16,$0fff


syncfix:	move.l	global_vbl,.vbls

.wait_first:	move.l	.vbls,d0			;vsync
		cmp.l	global_vbl,d0
		bge.s	.wait_first

		ifeq	hatari
		move.b	#1,$ffff8260.w			;medres
		endc

		move.l	global_vbl,.vbls
		add.l	#2,.vbls			;n

.more:		move.l	global_vbl,d0			;vsync n times
		cmp.l	.vbls,d0
		ble.s	.more

		ifeq	hatari
		move.b	#0,$ffff8260.w			;lowres
		endc
		rts
.vbls:		dc.l	0


lmc1992:	move.w	#%11111111111,$ffff8924.w	;set microwire mask
		move.w	d0,$ffff8922.w
.waitstart	cmpi.w	#%11111111111,$ffff8924.w	;wait for microwire
		beq.s	.waitstart
.waitend	cmpi.w	#%11111111111,$ffff8924.w	;wait for microwire 
		bne.s	.waitend
		rts


;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		SYSTEM INCLUDES
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		ifne	hatari_speedup
		include	'hatari/hatari.s'
		endc

		ifne	music_sndh
		include	'music/sndh.s'
		endc

		ifne	music_ym
		include	'music/ym.s'
		endc
		
		ifne	music_dma
		include	'music/dma.s'
		endc

		include	'sys/fade.s'
		;include	'sys/ice.s'
		

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		USER CODE
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

changedisk_init:		rts
changedisk_runtime_init:
		subq.w	#1,.once
		bne.w	.done


		jsr	clear_screens
		jsr	syncfix				;fix eventual bitplane corruption
		jsr	black_pal

		lea.l	changedisk_pic+32,a0
		move.l	screen_adr_base,a1
		lea.l	160(a1),a1
		move.w	#273-1,d7
.y:		move.w	#208/4-1,d6
.x:		move.l	(a0)+,(a1)+
		dbra	d6,.x
		ifne	hatari
		lea.l	22(a0),a0
		lea.l	22(a1),a1
		endc
		ifeq	hatari
		lea.l	22(a0),a0
		lea.l	16(a1),a1
		endc
		dbra	d7,.y

		ifne	init_green
		move.w	#$0070,$ffff8240.w
		endc

.done:		rts
.once:		dc.w	1

changedisk_vbl:
		move.l	screen_adr_base,d0		;set screen
		lea.l	$ffff8203.w,a0
		movep.l	d0,(a0)

		lea.l	changedisk_pal,a0
		lea.l	changedisk_pic,a1
		jsr	component_fade
		
		movem.l	changedisk_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		rts
changedisk_pal:		dcb.w	16,$0000

changedisk_vbl_out:
		move.l	screen_adr_base,d0		;set screen
		lea.l	$ffff8203.w,a0
		movep.l	d0,(a0)

		lea.l	changedisk_pal,a0
		lea.l	.outpal,a1
		jsr	component_fade
		
		movem.l	changedisk_pal,d0-d7
		movem.l	d0-d7,$ffff8240.w

		rts
.outpal:	dcb.w	16,$0000



changedisk_main:	rts

changedisk_timer_a:	
		move.w	#$2100,sr
		stop	#$2100
		move.w	#$2700,sr
		clr.b	$fffffa19.w


		movem.l d0-a6,-(sp)
		dcb.w 	52-2,$4e71

		moveq.l	#0,d7			;1
		moveq.l	#2,d6			;1


		move.b	#0,$ffff820a.w			;remove top border
		dcb.w 	6,$4e71
		lea.l	$ffff8209.w,a0
		moveq.l	#127,d1
		move.b	#2,$ffff820a.w

.sync:		tst.b	(a0)				;hardsync
		beq.s	.sync				;
		move.b	(a0),d2				;
		sub.b	d2,d1				;
		lsr.l	d1,d1				;


;		66 nops until the first scanline, use for inits etc
		dcb.w 	66-2,$4e71	
		move.w	#228-1,d5		;2


;line 1-228
.y1:
		movem.w	d0-d1,changedisk_dump	;6
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		movem.l	d0-a7,changedisk_dump	;36
		movem.l	d0-a7,changedisk_dump	;36
		movem.l	d0-d6,changedisk_dump	;18
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		movem.w	d0-a4,changedisk_dump	;17
		dbra	d5,.y1

;line 229
		dcb.w	2,$4e71			;3
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		move.b	d6,$ffff820a.w		;3
		movem.l	d0-a7,changedisk_dump	;36
		movem.l	d0-a7,changedisk_dump	;36
		movem.w	d0-a2,changedisk_dump	;15
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		movem.l	d0-d6,changedisk_dump	;18
		move.w	#44-1,d5		;2

; line 230-273
.y2:
		movem.w	d0-d1,changedisk_dump	;6
		move.b	d6,$ffff8260.w		;3
		move.b	d7,$ffff8260.w		;3
		movem.l	d0-a7,changedisk_dump	;36
		movem.l	d0-a7,changedisk_dump	;36
		movem.l	d0-d6,changedisk_dump	;18
		move.b	d7,$ffff820a.w		;3
		move.b	d6,$ffff820a.w		;3
		movem.w	d0-a4,changedisk_dump	;17
		dbra	d5,.y2

		movem.l (sp)+,d0-a6
		move.w	#$2300,sr
		rts

;--- Data ---------------------------------------------------------------------------------------------
		
		section	data


changedisk_pic:	incbin	'chgdisk.4pl'
		even

changedisk_dump:	ds.l	16


		section	text



;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		USER INIT LIST
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

initlist:	rts

		section	data

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		LIST OF DEMOPARTS
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

;format
;dc.l vbls,ta_delay,ta_div,vbl,ta,main

partlist:
		dc.l	10,99,4,dummy,timer_a_dummy,changedisk_runtime_init
		dc.l	-1,99,4,changedisk_vbl,changedisk_timer_a,changedisk_main
exit_part:	dc.l	50,99,4,changedisk_vbl_out,changedisk_timer_a,changedisk_main

		dc.l	-1,100,4,dummy,dummy,exit


;		Do not shift order of these variables
part_position:	dc.l	partlist
timera_delay:	dc.l	0
timera_div:	dc.l	0
vbl_routine:	dc.l	dummy
timera_routine:	dc.l	dummy
main_routine:	dc.l	dummy
vbl_counter:	dc.l	0
global_vbl:	dc.l	0



empty:			dcb.b	160*32+256,$00
empty_adr:		dc.l	0

		section	bss

;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
;		GENERIC MEMORY BUFFERS
;%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

		section	text

