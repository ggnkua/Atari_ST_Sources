;-----------------------------------------------------------------------------
; Incredibly Technical(!) Data encryption & decryption!
; Fastly typed Tony B!
; Devpac v2.25, tabs =10
;-----------------------------------------------------------------------------


	opt	d+


	lea	buffer(pc),a0	;start of data to encrypt
	lea	buff_end(pc),a1	;end of data to encrypt
	move.l	#$deadface,d0	;magic keycode!
	bsr.s	encrypt

*---------data in buffer is now totally illegible!

	lea	buffer(pc),a0	;start of data to decrypt
	lea	buff_end(pc),a1	;end of data to decrypt
	move.l	#$deadface,d0	;magic keycode!
	bsr.s	decrypt
	
*---------data in buffer is now completely restored as normal!!

	illegal


encrypt
decrypt				;same for both!
.crypt	eor.l	d0,(a0)+		;yep! that's all...hahaha!!
	cmpa.l	a1,a0
	ble.s	.crypt
	clr.l	buff_end		;clear 1 long byte, as this
				;will be the magic keycode!!!
	rts


buffer	dc.b	"   THIS IS A FILE SCRAMBLE/UNSCRAMBLE ROUTINE BY"
	dc.b	" TONY -B-, AND IT'S ALMOST FOOLPROOF!!!  ASSEMBLE IT"
	dc.b	" THEN STEP THROUGH WITH MONST TO SEE FOR YOURSELF!!"
	even
buff_end
	ds.l	1	;spare 'long' used for key-code!
