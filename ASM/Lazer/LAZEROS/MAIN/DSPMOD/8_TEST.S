
	OUTPUT 	8_test.prg

	jmp	execute_file

;-----------------------------------------------------------
	include f:\lanix\startup.s	
;-----------------------------------------------------------
wait_receive MACRO
.wait\@
	btst	#0,$ffffa202.w
	beq.s	.wait\@
	ENDM

wait_transmit MACRO
.wait\@
	btst	#1,$ffffa202.w
	beq.s	.wait\@
	ENDM
;-----------------------------------------------------------
execute_file

	shrink_memory			;Speicher zurÅck


	bsr	init			;Normales init
	save_stack
	bsr	phoenix_init		;Escapeabfrage, etc

	save_interrupts
	set_interrupts

	pea	text
	move.w	#9,-(sp)
	trap	#1
	addq	#6,sp

	bsr	player+28		;install

	lea	module,a0
	lea	vol_tab,a1
	bsr	player+36		;on

	move.l	#vbl2,$70.w
mainloop

	vsync

	move.w	#$700,$ffff8240.w
	move.w	#$777,$ffff8240.w

	clr.b	key

	move.b	$fffffc02.w,key		;Keyboard data
	move.b	#0,$fffffc02.w

	cmp.b	#78,key
	bne.s	.2
	cmp.w	#$7f00,my_vol
	bgt.s	.2
	add.w	#$ff,my_vol
	move.w	#$070,$ffff8240
.2
	cmp.b	#74,key
	bne.s	.3
	cmp.w	#$100,my_vol
	blt.s	.3
	sub.w	#$ff,my_vol
	move.w	#$007,$ffff8240
.3

	cmp.b	#$39,key		;space
	bne	mainloop	

main_exit
	move.l	#vbl,$70.w

	bsr	player+40		;off

	bsr	player+32		;deinstall
	
	restore_interrupts
	bsr	phoenix_exit
	restore_stack

	move.l	old_screen,d0
	setscreen
	restore_resolution
	mouse_on
	super_off
	terminate

;-----------------------------------------------------------
calc_volume
	move.w	my_vol,d1
	move.l	player+68,a1
i set 0
	REPT 8
	move.w	d1,24+28*i(a1)
i set i+1
	ENDR
	rts
;-----------------------------------------------------------
vbl
old_vbl jmp     $12345678	;alten vbl anspringen (ph_vbl)
;-----------------------------------------------------------
vbl2
	pusha

	bsr	calc_volume
	bsr	player+44		;play

	popa
*	rte

	jmp	old_vbl
;-----------------------------------------------------------
init
	clr_bss

	super_on
	mouse_off

        move.l  $44e.w,old_screen
	save_resolution


	cache_on

        rts
;-----------------------------------------------------------
exit
	move.l	old_screen,d0
	setscreen

	mouse_on
	super_off

	rts
;-----------------------------------------------------------
	section data

vol_tab		REPT 8
		dc.w	$5fff
		ENDR

my_vol		dc.w	$ff

oldscr          dc.l    0
oldcol          ds.l    8
oldmode		dc.w	0		;die speicherplÑtze

scr1		dc.l	0
scr2		dc.l	0

text	dc.b	"Modulereplay by Bitmaster of BSW",13,10
	dc.b	"Now playing 8 tracks stereo...",0
	even

;-----------------------------------------------------------
player
	incbin	DSPMOD2.TCE	;player source includieren
	even

*module	incbin	e:\trip8trx.mod 
module	incbin	e:\xxx.pmd 
	even

	section bss

	ds.l	1000
mystack		ds.l	0


start_bss
palette		ds.l	256	;is set every vbl
screen		ds.w	2*640*400+256
		even
end_bss

