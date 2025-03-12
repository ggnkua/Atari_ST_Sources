;
;	BAD MOOD SFX ENGINE V.0.1
;

;	CODED BY PEYLOW OF T.O.Y.S.

; 	LAST CHANGES: 1997-05-27

Xpos	equ 1000
Ypos	equ 5000

	include	include\macros.s

	SECTION TEXT
START:
	clr.l	-(sp)
	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp
	move.l	d0,-(sp)

	moveq.l	#8,d0	; 8 channels
	moveq.l	#5,d1	; update every 5th VBL
	moveq.l	#1,d2	; 12.5kHz
	jsr	sound_init	; initiate sound

	jsr	sound_start

	lea	sound1,a0		; address to sound
	move.l	#sound2-sound1,d0	; length of sound
	move.w	#4,d1			; normal sound
	move.w	#$5000,d2		; overrule all 
	move.w	#Xpos,d3		; Xpos of sound
	move.w	#Ypos,d4		; Ypos of sound
	jsr	new_sound		; register sound

	jsr	sfx_VBL

	jsr	sound_shutdown		; shut up!

	move.w	#32,-(sp)
	trap	#1
	addq.l	#6,sp

	clr.w	-(sp)
	trap	#1



	SECTION DATA
sound1:	incbin	"e:\bad_mood\aah.raw"
	even
sound2:	incbin	"e:\bad_mood\growl.raw"
	even
sound3:	incbin	"e:\bad_mood\horned.raw"
	even
sound4:	incbin	"e:\bad_mood\shot.raw"
	even
sound5:

	SECTION BSS

	include	"sfx_init.s"	; Initial routines
	include	"sfx_main.s"	; Main core
	include	"sfx_calc.s"	; calculation of sound data
	include	"sfx_cls.s"	; close down
	include	"sfx_vbl.s"	; VBL routines
	include	"sfx_data.s"	; general data
