
; Example code to:
;
;  - Setup double buffered screen
;  - SNDH-player on VBL
;
; Should work with any ST, STe TT or Falcon
;
; WARNING: On TT everything will run 20% faster 
;          due to 60Hz VBL
;
; Assembles with gen/devpac v3.1
;
; Anders Eriksson
; ae@dhs.nu
;
; Sunday nov 30, 2003


		section	text

		include 'base.s'


;-------------- User inits to run before demo kicks off

inits:
		; copy degas image to both screen buffers
		lea.l	picture+34,a0
		move.l	screen_adr,a1
		move.l	screen_adr2,a2
		move.w	#32000/4-1,d7
.loop:		move.l	(a0)+,d0
		move.l	d0,(a1)+
		move.l	d0,(a2)+
		dbra	d7,.loop

		;set palette from degas picture
		movem.l	picture+2,d0-d7
		movem.l	d0-d7,$ffff8240.w

		; start sndh-music
		move.l	#sndh_song,sndh_adr
		jsr	init_sndh
		move.l	#play_sndh,sndh_vbl

		rts


;-------------- User exits, stuff to run before demo exits

exits:		
		;stop sndh-music
		jsr	exit_sndh
		move.l	#dummy,sndh_vbl

		rts



;-------------- User mainloop that runs until space is pressed
;               VBL-waiting and doublebuffer screen-flipping is
;               automatic. Always use the address in screen_adr
;		when writing to screen.

mainloop:	tst.w	waitvbl				;wait for next vbl
		beq.s	mainloop			;
		clr.w	waitvbl				;

		bsr.w	testeffect			;call shitty test effect

		rts



;-------------- Lousy test "effect"...
;		Just a graphics block moving without clearing

testeffect:	move.l	screen_adr,a0			;screen address
		add.l	.pos,a0				;add some offset tog get movement
		add.l	#160,.pos			;160 bytes == one line
		cmp.l	#160*160,.pos			;wrap at 160 lines..
		blt.s	.no				;
		clr.l	.pos				;
.no: 		lea.l	picture+34+160*50+80,a1		;source graphics for the "effect"


q:		set	0
		rept	32				;32 lines high object to copy
		movem.l	q(a1),d0-d3			;get 32 width
		movem.l	d0-d3,q(a0)			;put 32 width
q:		set	q+160				;next line
		endr

		rts
.pos:		dc.l	0



;-------------- User VBL, for small things like colourpalette
;               setting..		

vbl:		addq.w	#1,waitvbl
 
		rts




		section	data

waitvbl:	dc.w	0
sndh_song:	incbin	'stolen.snd'			;must be UNPACKED!
		even
picture:	incbin	'cat.pi1'			;must be PI1 UNPACKED!
		even

		section	text
